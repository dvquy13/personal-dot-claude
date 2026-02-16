---
name: project-docs
description: >
  Maintain concise project documentation in docs/. Covers architecture, structure,
  decisions, gotchas, and learnings — optimized for fast developer onboarding.
  Use when user says "update docs", "document the project", "distill session",
  "capture learnings", or asks to record architecture, decisions, or gotchas.
  Also use mid-conversation when user wants to capture session insights into project docs.
model: sonnet
allowed-tools: Read, Write, Edit, Glob, Grep, Bash(git *), Bash(ls *)
disable-model-invocation: true
---

# Project Docs

Maintain `docs/ARCHITECTURE.md` — concise, scannable, useful for both humans and Claude.

## Mode Detection

**Full audit** — no prior conversation, or user asks to "create/update docs", or no `docs/` exists.
**Session distill** — mid-conversation, user asks to capture learnings/decisions/gotchas.

## Phase 1: Read State

1. Check if `docs/ARCHITECTURE.md` exists. Read it.
2. Check for topic files in `docs/` (prior split).
3. Check if project `CLAUDE.md` references `docs/`.

## Phase 2A: Full Audit

1. Map the codebase: `ls` root and key dirs, read config files (`package.json`, `Cargo.toml`, etc.), identify entry points and test structure.
2. Draft documentation per format below. Show draft for approval.

## Phase 2B: Session Distill

1. Review conversation above for: decisions + rationale, bugs + root causes, architectural insights, gotchas, environment quirks.
2. Read existing docs.
3. For each finding, determine scope (see "Placement Scope" below).
4. Show proposed changes — both doc entries and code comments — for approval.

## Phase 3: Write

1. Write to `docs/ARCHITECTURE.md`. Create `docs/` if needed.
2. Add code comments for file-specific findings (inline, near relevant code).
3. If `CLAUDE.md` doesn't reference docs, add: `For project architecture, decisions, and gotchas, see docs/ARCHITECTURE.md.`
4. If file exceeds ~300 lines, split — see "Splitting."

## Placement Scope

Each learning/gotcha goes where a developer would encounter it:

**Code comment** when:
- Specific to one function/file
- Explains non-obvious local behavior ("why this line does X")
- A developer reading that code would hit this issue
- Format: concise `// GOTCHA: ...` or `// NOTE: ...` near the relevant line

**Centralized docs** when:
- Cross-cutting, affects multiple areas
- About infrastructure, environment, or config
- Architectural decision affecting the project
- "Why we chose X over Y"

When in doubt, prefer code comments — they're discovered in context.

## Format

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

## Conciseness Rules

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

- Do NOT duplicate README content. Reference it.
- Do NOT document external library APIs. Link to their docs.
- Do NOT add "last updated" timestamps — git handles that.
- Do NOT add code comments that restate what the code does. Only non-obvious behavior.
