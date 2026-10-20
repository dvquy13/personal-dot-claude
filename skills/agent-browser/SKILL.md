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

## User's real Chrome

Only when the user asks to use their own browser/tabs: `agent-browser --auto-connect <cmd>` (Chrome remote debugging is enabled; Chrome shows an Allow prompt the first time).

## Research tasks

Thin sourcing is the known failure mode: don't stop after 2–3 retailer pages. Aim for ~6–10 sources, mixing independent/user sources (forums like voz.vn, tinhte.vn, reddit; reviews; manufacturer warranty pages) with retailers, and cite URLs actually read. Prefer `read` over full snapshots for article text.

## Cleanup

Headed sessions never idle out. Run `agent-browser close` at the end of the task unless the user wants the window kept open (e.g. mid-login). `agent-browser close --all` clears stray sessions.
