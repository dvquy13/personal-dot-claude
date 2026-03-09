---
name: project-docs
description: >
  Maintain project documentation across docs/, CLAUDE.md or .claude/CLAUDE.md, and
  .claude/rules/. Distill conversations into concise, actionable insights routed
  to the right target. Use when user says "update docs", "document the project",
  "distill session", "capture learnings", "forget X", or asks to record/remove
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
6. **Full audit only**: map the codebase — `ls` root and key dirs, read config files (`package.json`, `Cargo.toml`, etc.), identify entry points and test structure.

## Phase 2: Distill

1. Review conversation for: decisions + rationale, bugs + root causes, architectural insights, conventions discovered, gotchas, environment quirks, and other things user was confused with.
   **Non-obvious filter**: after identifying each finding, ask "would a new developer hit this as a surprise?" — if no, skip it.
   **Only include what was verified or completed this session.** Skip anything discussed as a future plan, proposed design, or approach not yet taken.
2. Read existing docs (all targets).

## Phase 3: Plan + Dedup

Before writing, list every intended change (ADD/UPDATE/REMOVE per target). Then scan the full list:
- Same fact in multiple targets → keep only the most specific, drop the rest
- Near-duplicates within a target → merge into one
- Contradictions → resolve

Only proceed to Phase 4 with the deduplicated plan.

## Phase 4: Execute

1. Apply the finalized plan — write, edit, or remove entries across all targets. Create `docs/` or `.claude/rules/` dirs if needed.
2. **Merge into existing sections** — organize semantically by topic, not chronologically.
3. Summarize what changed and where (additions, updates, removals) so the user can review via `git diff`.

## Placement Scope

Route each finding based on **when it needs to be discovered**. Only capture what isn't self-evident from reading the code or README — every entry should answer "why" or "gotcha", not "what".

**`CLAUDE.md`** (always loaded) — build/test/lint/deploy commands; coding conventions; project-wide gotchas; workflow rules ("always run X before Y", "never do Z"); important constraints needed from session start. **Treat as valuable real estate: every line competes for Claude's attention at session start. Be ruthless — if it can live in inline comments, rules or other docs, put it there instead. Keep under ~50 lines.**

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

## Splitting

When `docs/ARCHITECTURE.md` exceeds ~300 lines:
1. Extract sections into `docs/[topic].md`
2. Replace in ARCHITECTURE.md with: `See [topic](topic.md)`
3. ARCHITECTURE.md becomes an index
