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

Curate project knowledge into structured, in-repo documentation for both humans and AI. This is the **promotion layer** on top of auto-memory: auto-memory captures automatically into private `~/.claude/` files; this skill routes verified insights into in-repo files that are **portable**, **inspectable**, and serve both future developers (including future-you) and Claude in future sessions.

## Relationship with Auto-Memory

- **Auto-memory** = Claude's automatic scratch pad. Freeform, per-user, per-machine. Topic files loaded on-demand only.
- **Project docs** = Shared project knowledge. In-repo, travels with the repo, readable by humans and AI alike.
- During distill, check auto-memory as an additional source — promote anything worth making permanent and shared.
- Do NOT duplicate what auto-memory already captured unless it belongs in project-level documentation.

## Documentation Targets

| Target | Loaded by Claude | Purpose | Style |
|---|---|---|---|
| `docs/*.md` | On-demand | Project map: starts as `ARCHITECTURE.md`, splits into topic files when it grows | Descriptive, scannable |
| `CLAUDE.md` (project root) | **Always, session start** | Conventions, commands, patterns, project-wide gotchas | Imperative, terse instructions |
| `.claude/rules/*.md` | **When matching files are touched** (no `paths` frontmatter = always) | Path-specific rules activated by file context | Imperative, scoped |
| Code comments | When file is read | Line/function-specific gotchas | Inline comments |

## Mode Detection

**Full audit** — no prior conversation, or user asks to "create/update docs", or targets don't exist yet.
**Session distill** — mid-conversation, user asks to capture learnings/decisions/gotchas.

## Phase 1: Read State

1. Read `docs/ARCHITECTURE.md` if it exists. Check for topic files in `docs/`.
2. Read project-root `CLAUDE.md` if it exists.
3. List `.claude/rules/` and read existing rule files.
4. Scan auto-memory for insights worth promoting to project docs.
5. Note what exists and what's missing.

## Phase 2A: Full Audit

1. Map the codebase: `ls` root and key dirs, read config files (`package.json`, `Cargo.toml`, etc.), identify entry points and test structure.
2. For each finding, search existing docs for related entries. **Update in place** if a related entry exists; only add new entries for genuinely new information.
3. Write content directly to each target per the formats below. Create `docs/` or `.claude/rules/` dirs if needed.
4. Summarize what was written and where so the user can review via `git diff`.

## Phase 2B: Session Distill

1. Review conversation for: decisions + rationale, bugs + root causes, architectural insights, conventions discovered, gotchas, environment quirks, and other things user was confused with.
   **Only include what was verified or completed this session.** Skip anything discussed as a future plan, proposed design, or approach not yet taken.
2. Read existing docs (all three targets).
3. For each finding:
   a. **Cross-reference** against existing docs — does a related entry already exist?
   b. If yes, **update the existing entry** in place. Do not add a second entry.
   c. If the finding contradicts an existing entry, **replace** the old one (it's now stale).
   d. If genuinely new, determine placement using the Placement Scope rules.
4. **Prune stale entries**: flag and remove any existing entries that this session proved wrong or outdated. The conversation is your evidence — only remove what was clearly disproven.
5. **Merge into existing sections** — organize semantically by topic, not chronologically. Insert findings into the right section, don't append at the bottom.
6. Write changes directly to the appropriate targets. Add code comments for function/line-specific findings.
7. Summarize what changed and where (additions, updates, removals) so the user can review via `git diff`.

## Removal Workflow

When user says "forget X", "remove X from docs", or "stop documenting X":
1. Search all targets (ARCHITECTURE.md, CLAUDE.md, rules, code comments) for the entry.
2. Remove it. If removal leaves an empty section, remove the section heading too.
3. Confirm what was removed and from where.

## Write Rules

- Create `docs/` or `.claude/rules/` dirs if needed.
- Write directly — do not ask for approval. The user will review changes via source control.
- **Update-first**: always search for an existing related entry before adding a new one. Prefer updating over appending.
- **Organize semantically**: insert findings into the appropriate topic/section, never just append at the end of a file.

## Placement Scope

Route each finding based on **when it needs to be discovered** and **how critical it is to load every session**:

**`CLAUDE.md`** (always loaded, every session) when:
- Build, test, lint, deploy commands
- Coding conventions (naming, patterns, style)
- Project-wide gotchas that affect how code should be written
- Workflow rules ("always run X before Y", "never do Z")
- Important constraints that must be known from session start
- This is the most valuable real estate — keep it high-signal

**`.claude/rules/<topic>.md`** (loaded when matching files are touched) when:
- Rules specific to a directory or file pattern
- "When editing files in `src/api/`, always..."
- Test conventions for a specific test directory
- Component patterns for a specific framework area

**`docs/ARCHITECTURE.md`** (loaded on-demand) when:
- Project structure, directory layout, what lives where
- Key concepts and domain terminology
- Entry points and data flow
- Architectural decisions and rationale ("why we chose X over Y")
- Dependencies and what they're for
- Reference material — important but not needed every session

**Code comment** (loaded when file is read) when:
- Specific to one function or code block
- Explains non-obvious local behavior
- A developer reading that code would hit this issue

**When in doubt:** code comments > rules > CLAUDE.md > ARCHITECTURE.md (prefer the most specific, contextual location).

**Promotion test:** if something is in auto-memory or ARCHITECTURE.md but you find yourself needing it at session start, promote it to CLAUDE.md or rules.

## Format: docs/ARCHITECTURE.md

```markdown
# [Project Name]

> One-line description

## Structure
- `src/` — [purpose]
- `tests/` — [approach]

## Key Concepts
- **[Concept]** — one-line explanation

## Entry Points
- `src/main.ts` — what happens at startup

## Data Flow
[2-5 bullets: how data moves through the system]

## Decisions
- **[Decision]** — [why, not what] `(YYYY-MM-DD)`

## Gotchas
- [Non-obvious thing] — see `path/to/file.ts`

## Dependencies
- `[package]` — [why we use it]
```

## Format: CLAUDE.md

- Terse, imperative instructions — no prose, bullets and commands only
- Every line must be actionable or informative for AI
- Don't repeat what belongs in ARCHITECTURE.md
- Keep under ~50 lines. When approaching the limit:
  1. Extract path-specific items to `.claude/rules/<topic>.md`
  2. Extract related groups of conventions to a rules file
  3. CLAUDE.md should remain a concise index of project-wide rules

## Format: .claude/rules/*.md

- One clear topic per file, filename reflects scope
- Open with "When working with..." or "When editing..." to define scope
- Imperative voice, bullet lists
- Keep each file under ~30 lines

## Conciseness Rules (all targets)

- **One place only.** Each fact lives in exactly one target. If it fits as a code comment, don't also add it to CLAUDE.md.
- One line per entry. Expand only if genuinely complex.
- File paths as references, not prose: `see src/auth/` not "the authentication module."
- Skip the obvious. Don't document what code says clearly.
- Decisions record WHY. The what is in the code.
- Bullet lists over paragraphs.
- Link to PRs, issues, external docs instead of re-explaining.
- No empty sections. Omit sections that don't apply.

## Splitting

When `docs/ARCHITECTURE.md` exceeds ~300 lines:
1. Extract sections into `docs/[topic].md`
2. Replace in ARCHITECTURE.md with: `See [topic](topic.md)`
3. ARCHITECTURE.md becomes an index

## Anti-Patterns

- Do NOT document planned, proposed, or not-yet-implemented work — only capture facts verified this session.
- Do NOT save session-specific context (current task details, in-progress work, temporary state) — that's ephemeral, not documentation.
- Do NOT save unverified information — if a conclusion comes from reading a single file or a guess, verify it before writing. Low-confidence noise degrades docs over time.
- Do NOT add entries that contradict existing docs without removing the old entry first.
- Do NOT duplicate across targets. Each fact in exactly one place.
- Do NOT duplicate README content. Reference it.
- Do NOT document external library APIs. Link to their docs.
- Do NOT add "last updated" timestamps — git handles that.
- Do NOT add code comments that restate what the code does.
- Do NOT put architecture descriptions in CLAUDE.md — that's for ARCHITECTURE.md.
- Do NOT put AI instructions in ARCHITECTURE.md — that's for CLAUDE.md.
- Do NOT append findings chronologically — merge them into the right semantic section.

## References
- You can always consult claude-code-guide agents for anything related to how Claude-specific files (CLAUDE.md, .claude/rules etc.) work.
