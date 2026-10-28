---
name: agent-browser
description: Main browser tool on this machine. Use for any task that needs a real browser — JS-heavy or interactive pages (filters, forms, clicks), logged-in sites, sites that block plain fetches, screenshots, or when the user asks to "open", "browse", "log in", "check on the site". Prefer it over Playwright/chrome-devtools MCPs and Claude in Chrome. For plain public static pages or quick lookups, WebSearch/WebFetch are cheaper.
allowed-tools: Bash(agent-browser:*)
---

# agent-browser

Rust CLI driving system Chrome over CDP. Version-matched docs: `agent-browser skills get core` (long; load only when the cheat sheet below isn't enough, or `--help` on a subcommand).

## Defaults (set in ~/.claude/settings.json env)

- `AGENT_BROWSER_SESSION=main`: one shared browser daemon; each Bash call reconnects to it, so no `export` is needed (shell env doesn't persist between Bash calls anyway).
- `AGENT_BROWSER_PROFILE=~/.agent-browser/profiles/main`: persistent Chrome profile. Logins, cookies and the user's solved captchas survive restarts.
- `AGENT_BROWSER_HEADED=1`: visible window, so the user can watch and take over.

## Core loop

```bash
agent-browser open <url>          # launches the browser if needed
agent-browser snapshot -i         # interactive elements with @eN refs (add -u for link hrefs)
agent-browser click @e3           # fill @e2 "text" · press Enter · select @e4 "opt" · scroll down
agent-browser snapshot -i         # re-snapshot after every page change
agent-browser read                # readable text of the current page (best for research)
agent-browser get text @e1        # get url · get title
agent-browser eval 'document.title'   # JS expression, not an arrow function
agent-browser screenshot /path.png
agent-browser close               # when the task is done
```

Act on `@eN` refs from the latest snapshot, not CSS guesses.

Screenshots: viewport only (scroll the target into view first). `--full` on long pages produces huge images (5000×10000 px) that cost a lot of context, and sticky headers can still cover fields. To check form values, `eval` the input values instead of reading them off a screenshot.

## Login / captcha handoff

When a page needs a login, 2FA, captcha, or consent the agent shouldn't handle:
1. Leave the page open in the visible window and tell the user exactly what to do ("log in to X in the agent-browser window, then reply 'done'"). End the turn and wait.
2. After they reply, `snapshot -i` to confirm, then continue.
Never type the user's passwords or payment details yourself. Google often shows a captcha to automated browsers; ask the user to solve it once in this profile, or use `https://html.duckduckgo.com/html/?q=...`.

## Parallel work (second browser while `main` is in use)

The profile is locked to one Chrome process, so a second session must not use it. Export the main login, then run an isolated session; prefix every command:

```bash
agent-browser state save ~/.agent-browser/state/main.json                # once, from main
env -u AGENT_BROWSER_PROFILE AGENT_BROWSER_SESSION=<task> agent-browser --state ~/.agent-browser/state/main.json open <url>
env -u AGENT_BROWSER_PROFILE AGENT_BROWSER_SESSION=<task> agent-browser snapshot -i
```

State files hold session tokens in plaintext; never commit or share them.

## Which browser

- Agent profile (default): research, reading, public pages.
- User's real Chrome: bookings, forms that submit under the user's identity, anything behind their login, and sites with bot checks (reCAPTCHA, Cloudflare). Start there for these instead of discovering the captcha first. Still confirm with the user before the final submit.

## User's real Chrome

Remote debugging is on via chrome://inspect (port 9222). `--auto-connect` does NOT work with that mode: it looks for a `DevToolsActivePort` file that this mode never writes, and fails with "No running Chrome instance found". Use `--cdp 9222`, which works from inside the sandbox:

```bash
agent-browser --cdp 9222 tab list                 # check the connection
agent-browser --cdp 9222 tab new <url>            # work in a new tab, never the user's existing ones
agent-browser --cdp 9222 read                     # then the usual commands, each with --cdp 9222
agent-browser --cdp 9222 tab close                # when done
```

- Before the first connect in a session, tell the user Chrome will show an "Allow remote debugging?" prompt to click. Until they do, commands hang until they time out.
- If a command reports `tab_gone`, run `tab new <url>` again.
- Don't diagnose with `lsof` inside the sandbox: it hides listening ports. `tab list` is the real check.
- Wrap the prefix in a shell function (`ab(){ agent-browser --cdp 9222 "$@"; }`). A `$B` variable doesn't word-split in zsh.
- `snapshot -i` can come back empty in the user's Chrome. If so, use `read` for text and targeted `eval` DOM queries (find elements by text, then `.click()`); use `fill`/`select` with CSS selectors for inputs.

## Research tasks

Thin sourcing is the known failure mode: don't stop after 2–3 retailer pages. Aim for ~6–10 sources, mixing independent/user sources (forums like voz.vn, tinhte.vn, reddit; reviews; manufacturer warranty pages) with retailers, and cite URLs actually read. Prefer `read` over full snapshots for article text.

## Cleanup

Headed sessions never idle out. Run `agent-browser close` at the end of the task unless the user wants the window kept open (e.g. mid-login). `agent-browser close --all` clears stray sessions. In the user's real Chrome, don't run `close` (untested whether it only detaches or closes their browser); close only the tabs you opened with `tab close`.
