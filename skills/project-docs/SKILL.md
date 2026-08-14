---
name: project-docs
description: >
  Maintain project documentation across docs/, CLAUDE.md or .claude/CLAUDE.md, and
  .claude/rules/. Distill conversations into concise, actionable insights routed
  to the right target, always deduping, resolving contradictions, and removing
  stale entries from existing docs as part of the same pass. Use when user says
  "update docs", "document the project", "distill session", "capture learnings",
  "forget X", "clean up docs", "consolidate docs", or asks to record/remove
  architecture, decisions, conventions, or gotchas.
allowed-tools: Read, Write, Edit, Glob, Grep, Bash(git *), Bash(ls *)
---

# Project Docs

Route verified project insights into in-repo documentation that's **portable**, **inspectable**, and serves both humans and Claude in future sessions. This is the **promotion layer** on top of auto-memory:

- **Auto-memory** = Claude's private scratch pad. Freeform, per-user, per-machine.
- **Project docs** = Shared project knowledge. In-repo, travels with the repo.
- During distill, check auto-memory as an additional source — promote anything worth making permanent and shared.
- Do NOT duplicate what auto-memory already captured unless it belongs in project-level docs.

## Documentation Targets

| Target | Loaded by Claude | Purpose | Style |
|---|---|---|---|
| `README.md` | On-demand | User-facing entry point — what it is, how to install/use, key commands | User-oriented prose; update when public interface changes |
| `docs/*.md` | On-demand | Project map: starts as `ARCHITECTURE.md`, splits into topic files when it grows | Descriptive, scannable |
| `CLAUDE.md` (project root) | **Always, session start** | Conventions, commands, patterns, project-wide gotchas | Imperative, terse instructions |
| `.claude/rules/*.md` | **When matching files are touched** (no `paths` frontmatter = always) | Path-specific rules activated by file context | Imperative, scoped |
| Code comments | When file is read | Line/function-specific gotchas | Inline comments |

## Phase 1: Read State

**Full audit** — no prior conversation, user asks to "create/update docs", or targets don't exist yet.
**Session distill** — mid-conversation, user asks to capture learnings/decisions/gotchas.

1. Read `docs/ARCHITECTURE.md` if it exists. Check for topic files in `docs/`.
2. Read project-root `CLAUDE.md` if it exists.
3. List `.claude/rules/` and read existing rule files.
4. Scan auto-memory for insights worth promoting to project docs.
5. Note what exists and what's missing.
6. **Full audit**: also map the codebase — `ls` root and key dirs, read config files (`package.json`, `Cargo.toml`, etc.), identify entry points and test structure.

## Phase 2: Distill + Audit

**Distill new findings** (from this session):

1. Review conversation for: decisions + rationale, bugs + root causes, architectural insights, conventions discovered, gotchas, environment quirks, and other things user was confused with.
   **Non-obvious filter**: after identifying each finding, ask "would a new developer hit this as a surprise?" — if no, skip it.
   **Only include what was verified or completed this session.** Skip anything discussed as a future plan, proposed design, or approach not yet taken.

**Audit existing docs** — every target read in Phase 1, not just new findings; adding is not the only responsibility here, and docs accumulate rot if nothing ever checks them. For a quick session distill, scope this to targets actually touched by this session's findings rather than the whole doc tree — but always run it on those targets, don't skip straight to appending. Go entry-by-entry and check each one against present-day reality:

1. **Stale**: does this entry reference a file, function, command, dependency, or pattern that no longer exists or was replaced? Collect all such references first, then verify them in one batched `Grep`/`Glob`/`ls` pass rather than one lookup per entry — don't trust the doc's own claim. If unverifiable, flag it rather than silently trusting it.
2. **Duplicate**: is the same fact stated in more than one target, or more than once within a target (possibly reworded)?
3. **Contradiction**: do two entries (same or different targets) disagree? Resolve to whichever is confirmed by the current codebase or git history; if neither is verifiable, prefer the one from the more specific target — see Placement Scope.
4. **Misplaced**: does this entry violate Placement Scope (e.g. a code-comment-level detail sitting in CLAUDE.md, or a "what" instead of a "why/gotcha")?
5. **Superseded**: for anything ambiguous, check recent `git log`/session history (qrec, if available) to see whether a later decision already overrode it.

Tag each existing entry: `KEEP`, `STALE → remove`, `DUPLICATE → merge into <entry>`, `CONTRADICTION → resolve to <X>`, `RELOCATE → <target>`.

## Phase 3: Plan + Dedup

For each new finding and each tagged existing entry from Phase 2, assign it to **exactly one target** using the Placement Scope rules — every tagged entry converts to exactly one plan line, except `KEEP`, which converts to no line.
Write the plan as: `[FINDING] → [TARGET] (ADD/UPDATE/REMOVE/RELOCATE)`

**Constraint**: each finding appears in the plan exactly once. If a finding seems to belong in multiple places, pick the most specific target only (code comment > rules > CLAUDE.md > ARCHITECTURE.md).

Before proceeding, scan the plan for:
- Same fact assigned to multiple targets → remove all but the most specific
- Near-duplicates within a target → merge into one entry
- Contradictions with existing docs → resolve

Only proceed to Phase 4 with the deduplicated plan.

## Phase 4: Execute

1. If any target this plan touches had existing content in Phase 1 (i.e. this isn't a net-new file), check `git status` on it before editing — if dirty with unrelated changes, ask the user to commit or stash first, since git diff is the review/undo mechanism for this skill's edits.
2. Apply the finalized plan — write, edit, or remove entries across all targets. Create `docs/` or `.claude/rules/` dirs if needed.
3. **Merge into existing sections** — organize semantically by topic, not chronologically.
4. Summarize what changed and where. If the plan included any REMOVE/RELOCATE from the housekeeping audit, lead with those counts (`N stale removed, N duplicates merged, N contradictions resolved, N relocated`) before the addition summary — subtraction is easy to under-report next to a list of additions.

## Placement Scope

Route each finding based on **when it needs to be discovered**. Only capture what isn't self-evident from reading the code or README — every entry should answer "why" or "gotcha", not "what".

**`CLAUDE.md`** (always loaded) — build/test/lint/deploy commands; coding conventions; project-wide gotchas; workflow rules ("always run X before Y", "never do Z"); important constraints needed from session start. **Treat as valuable real estate: every line competes for Claude's attention at session start. Be ruthless — if it can live in inline comments, rules or other docs, put it there instead. Target under ~50 lines; ~200 lines is a hard ceiling — see Splitting.**

**`.claude/rules/<topic>.md`** — rules specific to a directory or file pattern; test conventions; component patterns for a specific framework area. Need paths frontmatter to trigger on relevant files.

**`docs/ARCHITECTURE.md`** — project structure; key concepts and domain terminology; entry points and data flow; architectural decisions and rationale ("why we chose X over Y"); dependencies and what they're for.

**`README.md`** — user-facing: what the project is, install/usage, key commands. Update when the public interface changes.

**Code comment** — specific to one function or code block; non-obvious local behavior; a developer reading that code would hit this issue.

**When in doubt:** code comments > rules > CLAUDE.md > ARCHITECTURE.md (prefer the most specific, contextual location).

**Promotion test:** if something is in auto-memory or ARCHITECTURE.md but you find yourself needing it at session start, promote it to CLAUDE.md or rules.

## Formats

**`docs/ARCHITECTURE.md`**
```markdown
# [Project Name]
> One-line description
## Structure
## Key Concepts
## Entry Points
## Data Flow
## Decisions
## Gotchas
## Dependencies
```

## IMPORTANT Rules

- **Verified only**: only document what was verified or completed this session. Skip future plans, proposed designs, or approaches not yet taken.
- **Non-obvious only**: skip anything self-evident from reading the code or README. Every entry should answer "why" or "gotcha", not "what".
- **One place only**: each fact lives in exactly one target. If it fits as a code comment, don't also add it to CLAUDE.md.
- **Don't default to KEEP**: housekeeping's job is to remove and merge, not just add — an unverifiable claim sitting in CLAUDE.md costs attention at every session start, more than no claim at all. When genuinely unsure whether something is stale, say so in the plan and let the user decide.

## Splitting

When `docs/ARCHITECTURE.md` exceeds ~300 lines:
1. Extract sections into `docs/[topic].md`
2. Replace in ARCHITECTURE.md with: `See [topic](topic.md)`
3. ARCHITECTURE.md becomes an index

When top-level `CLAUDE.md` exceeds ~200 lines (a hard ceiling — well past the ~50-line target), treat the overage itself as a housekeeping finding in Phase 2, not just an addition problem:
1. Re-route existing entries per Placement Scope: path-specific rules → `.claude/rules/`, descriptive/architectural content → `docs/ARCHITECTURE.md`, function-local detail → code comments.
2. Keep only what's genuinely needed at every session start: commands, project-wide conventions, and hard constraints.
3. Note the line-count reduction in the Phase 4 summary alongside the other housekeeping counts.
