---
name: project-docs
description: >
  Maintain project documentation: docs/ (design, as-built architecture, decision
  records, specs, plans, glossary), CLAUDE.md and .claude/rules/. Each project's
  docs/README.md says where every kind of doc lives. Distill conversations into
  concise insights routed to the right home, deduping, resolving contradictions and
  removing stale entries in the same pass. Use when user says "update docs",
  "document the project", "distill session", "capture learnings", "forget X",
  "clean up docs", "close the milestone", "where should this doc go", or asks to
  record/remove architecture, decisions, conventions, or gotchas.
allowed-tools: Read, Write, Edit, Glob, Grep, Bash(git *), Bash(ls *)
---

# Project Docs

Route verified project insights into in-repo documentation that's **portable**, **inspectable**, and serves both humans and Claude in future sessions. This is the **promotion layer** on top of auto-memory:

- **Auto-memory** = Claude's private scratch pad. Freeform, per-user, per-machine.
- **Project docs** = Shared project knowledge. In-repo, travels with the repo.
- During distill, check auto-memory as an additional source — promote anything worth making permanent and shared, then delete the memory it replaces.

## The home map

Every project keeps one file that says where each kind of knowledge lives and how docs are written: **`docs/README.md`**. It holds, in order: a one-line intro, the home map (kind / location / format), the rules (frontmatter, decisions, writing, plus renders and diagrams if the project has them), and a status table with one row per doc. It is the authority for placement. This skill never overrides it, and proposes a change to it when a new kind of doc appears.

`docs/README.md` is not auto-loaded, so `CLAUDE.md` must say to read it before adding, moving or writing a doc.

Template: `references/docs-readme-template.md`. Skeletons for the `CLAUDE.md` "Where to look" table, a decision record and the decisions index: `references/skeletons.md`.

## Documentation Targets

| Target | Loaded by Claude | Purpose | Style |
|---|---|---|---|
| `CLAUDE.md` (project root) | **Always, session start** | One-line description, status line, "Where to look" table, docs workflow, commands, conventions, project-wide gotchas | Imperative, terse |
| `.claude/rules/*.md` | **When matching files are touched** (no `paths` frontmatter = always) | Path-scoped code rules. Docs rules live in `docs/README.md`, not here | Imperative, scoped |
| Homes in `docs/README.md` | On-demand | Design, as-built architecture, decisions, specs, plans, glossary, and any project-specific kinds | Per the home map |
| Code comments | When file is read | Line/function-specific gotchas | Inline comments |
| `README.md` (repo root) | On-demand | User-facing: what it is, install, usage | Prose; update when the public interface changes |

## Phase 1: Read State

**Full audit** — no prior conversation, user asks to "create/update docs", or targets don't exist yet.
**Session distill** — mid-conversation, user asks to capture learnings/decisions/gotchas.
**Milestone close-out** — a milestone's plan is finished. Run the distill, then the close-out checklist below.

1. Read `docs/README.md`. If it has no home map:
   - If the project keeps one in `.claude/rules/docs.md` (an older layout), propose merging that file into `docs/README.md` verbatim and deleting it, then repoint references to it.
   - Otherwise propose a home map from the template, adapted to the folders the project actually has: keep the core kinds that apply, add project-specific kinds that already exist (spikes, evals, results, sources…), and drop optional sections the project doesn't use.
   - Write it only after the user confirms. It sets a convention for the repo.
2. Read project-root `CLAUDE.md` and `.claude/rules/`.
3. Read the docs the session's findings touch, per the home map (e.g. `docs/architecture.md`, the open spec and plan, `docs/decisions/README.md`).
4. Scan auto-memory for insights worth promoting to project docs.
5. **Full audit**: also map the codebase — `ls` root and key dirs, read config files (`package.json`, `Cargo.toml`, etc.), identify entry points and test structure — and check every doc on disk has a status-table row.

## Phase 2: Distill + Audit

**Distill new findings** (from this session):

1. Review conversation for: decisions + rationale, bugs + root causes, architectural insights, conventions discovered, gotchas, environment quirks, and other things user was confused with.
   **Non-obvious filter**: after identifying each finding, ask "would a new developer hit this as a surprise?" — if no, skip it.
   **Only include what was verified or completed this session.** Skip anything discussed as a future plan, proposed design, or approach not yet taken. (Exception: an agreed design change goes into the design doc, because design describes intent.)

**Audit existing docs** — every target read in Phase 1, not just new findings; adding is not the only responsibility here, and docs accumulate rot if nothing ever checks them. For a quick session distill, scope this to targets actually touched by this session's findings rather than the whole doc tree — but always run it on those targets, don't skip straight to appending. Go entry-by-entry and check each one against present-day reality:

1. **Stale**: does this entry reference a file, function, command, dependency, or pattern that no longer exists or was replaced? Collect all such references first, then verify them in one batched `Grep`/`Glob`/`ls` pass rather than one lookup per entry — don't trust the doc's own claim. If unverifiable, flag it rather than silently trusting it.
2. **Duplicate**: is the same fact stated in more than one target, or more than once within a target (possibly reworded)?
3. **Contradiction**: do two entries (same or different targets) disagree? Resolve to whichever is confirmed by the current codebase or git history; if neither is verifiable, prefer the one from the more specific target — see Placement Scope.
4. **Misplaced**: does this entry violate Placement Scope or the home map (e.g. a decision's rationale sitting in `architecture.md`, a planned feature described in `architecture.md`, a code-comment-level detail in CLAUDE.md)?
5. **Superseded**: for anything ambiguous, check recent `git log`/session history (qrec, if available) to see whether a later decision already overrode it.
6. **Home-map hygiene**: frontmatter present with `status` and `updated`; status-table rows match the files on disk and their frontmatter; CLAUDE.md's "Where to look" and status line match reality.

Tag each existing entry: `KEEP`, `STALE → remove`, `DUPLICATE → merge into <entry>`, `CONTRADICTION → resolve to <X>`, `RELOCATE → <target>`.

Accepted decision records are never rewritten. If one is stale, the fix is a new record that supersedes it (see the home map's decision rules), not an edit.

## Phase 3: Plan + Dedup

For each new finding and each tagged existing entry from Phase 2, assign it to **exactly one target** using the Placement Scope rules — every tagged entry converts to exactly one plan line, except `KEEP`, which converts to no line.
Write the plan as: `[FINDING] → [TARGET] (ADD/UPDATE/REMOVE/RELOCATE)`

**Constraint**: each finding appears in the plan exactly once. If a finding seems to belong in multiple places, put it in the most specific home and link to it from the others, never restate it.

Before proceeding, scan the plan for:
- Same fact assigned to multiple targets → keep the most specific, link from the rest
- Near-duplicates within a target → merge into one entry
- Contradictions with existing docs → resolve

Only proceed to Phase 4 with the deduplicated plan.

## Phase 4: Execute

1. If any target this plan touches had existing content in Phase 1 (i.e. this isn't a net-new file), check `git status` on it before editing — if dirty with unrelated changes, ask the user to commit or stash first, since git diff is the review/undo mechanism for this skill's edits.
2. Apply the finalized plan — write, edit, or remove entries across all targets. Create folders the home map names if needed.
3. **Merge into existing sections** — organize semantically by topic, not chronologically.
4. Bump `updated:` on every doc whose content changed, and sync the status table in `docs/README.md`.
5. If the home map says the project renders docs, run its render check.
6. Summarize what changed and where. If the plan included any REMOVE/RELOCATE from the housekeeping audit, lead with those counts (`N stale removed, N duplicates merged, N contradictions resolved, N relocated`) before the addition summary — subtraction is easy to under-report next to a list of additions.

## Milestone close-out

When a milestone's plan is finished, also:

1. **Keep the spec, set to `status: done`.** Later docs, code comments and test names cite its requirement IDs, and its results are the acceptance record.
2. **Results go in the spec**: each acceptance check's outcome and evidence path, plus a "What differed from the spec" list.
3. **Each difference goes to its home:** a change of intent goes into the design doc (bump `version` if the project versions it), a choice with rationale becomes a new decision record, and what got built goes into `architecture.md`.
4. **Distill the plan, then delete it.** A finished plan's job (task order, contracts between tasks) is over, nobody maintains it, so it drifts from the code and misleads whoever greps the docs later. Move what only it holds to its home first: a decision it settled to the spec's Decisions or a decision record, a reusable way of working to `docs/README.md`, what got built to `architecture.md`. Repoint every link to it, and strip plan task IDs (`T3`, `W0`) from code comments, since they restart in each plan. Git keeps its history.
5. **Status:** update the status table, and the status line in `CLAUDE.md` (what's done, with date, and what's next).

## Placement Scope

Route each finding based on **what kind of knowledge it is** and **when it needs to be discovered**. Only capture what isn't self-evident from reading the code or README — every entry should answer "why" or "gotcha", not "what". The home map names the files; these are the usual kinds:

**`CLAUDE.md`** (always loaded) — status line; "Where to look" table; docs workflow (including "read `docs/README.md` before adding, moving or writing a doc"); build/test/lint/deploy commands; coding conventions; project-wide gotchas; workflow rules; hard constraints. **Treat as valuable real estate: every line competes for Claude's attention at session start. Be ruthless — if it can live in inline comments, rules or other docs, put it there instead. Target under ~50 lines; ~200 lines is a hard ceiling — see Splitting.**

**`.claude/rules/<topic>.md`** — rules specific to a directory or file pattern; test conventions; component patterns for a specific framework area. Need paths frontmatter to trigger on relevant files.

**Design doc** — what the system is meant to be and why: goals, shape, intended behavior, risks and open questions. Living and versioned.

**`docs/architecture.md`** — only what exists in code: structure, entry points, data flow, contracts between parts, dependencies. Link to decision records for the why; never describe planned work here.

**Decision record** (`docs/decisions/NNNN-{slug}.md`) — one choice with its context, consequences and rejected alternatives. Append-only. Undecided questions go in the decisions index under "Deferred".

**Spec / plan** — one milestone's testable requirements and results (kept) / its task order with a Tracker on top (open milestones only).

**Glossary** — a term the project uses with a specific meaning. Add it before using it.

**Code comment** — specific to one function or code block; non-obvious local behavior; a developer reading that code would hit this issue.

**`README.md`** (repo root) — user-facing: what the project is, install/usage, key commands. Update when the public interface changes.

**When in doubt:** code comments > rules > CLAUDE.md > the docs/ homes (prefer the most specific, contextual location).

**Promotion test:** if something is in auto-memory or a docs/ home but you find yourself needing it at session start, promote it to CLAUDE.md or rules.

## IMPORTANT Rules

- **The home map decides**: place docs where `docs/README.md` says. If nothing fits, propose a new row to the user, never improvise a folder.
- **Verified only**: only document what was verified or completed this session. Skip future plans, proposed designs, or approaches not yet taken.
- **Non-obvious only**: skip anything self-evident from reading the code or README. Every entry should answer "why" or "gotcha", not "what".
- **One place only**: each fact lives in exactly one target, and other targets link to it. If it fits as a code comment, don't also add it to CLAUDE.md.
- **Never delete a finished spec**: close it out. A finished plan is distilled, then deleted (see Milestone close-out).
- **Don't default to KEEP**: housekeeping's job is to remove and merge, not just add — an unverifiable claim sitting in CLAUDE.md costs attention at every session start, more than no claim at all. When genuinely unsure whether something is stale, say so in the plan and let the user decide.

## Splitting

When `docs/architecture.md` exceeds ~300 lines:
1. Extract sections into `docs/architecture/[topic].md`
2. Replace in architecture.md with: `See [topic](architecture/topic.md)`
3. architecture.md becomes an index, and the home map gets a row for the folder

When top-level `CLAUDE.md` exceeds ~200 lines (a hard ceiling — well past the ~50-line target), treat the overage itself as a housekeeping finding in Phase 2, not just an addition problem:
1. Re-route existing entries per Placement Scope: path-specific rules → `.claude/rules/`, descriptive/architectural content → the docs/ homes, function-local detail → code comments.
2. Keep only what's genuinely needed at every session start: commands, project-wide conventions, and hard constraints.
3. Note the line-count reduction in the Phase 4 summary alongside the other housekeeping counts.
