---
name: project-docs
description: >
  Maintain project documentation across docs/ARCHITECTURE.md, CLAUDE.md, and
  .claude/rules/. Distill conversations into concise, actionable insights routed
  to the right target. Use when user says "update docs", "document the project",
  "distill session", "capture learnings", or asks to record architecture,
  decisions, conventions, or gotchas.
model: sonnet
allowed-tools: Read, Write, Edit, Glob, Grep, Bash(git *), Bash(ls *)
---

# Project Docs

Maintain project knowledge across three targets, each with a distinct audience and purpose.

## Documentation Targets

| Target | Audience | Purpose | Style |
|---|---|---|---|
| `docs/ARCHITECTURE.md` | Humans + AI | Project structure, architecture, data flow, key concepts | Descriptive, scannable |
| `CLAUDE.md` (project root) | AI (Claude) | Conventions, commands, patterns, project-wide gotchas | Imperative, terse instructions |
| `.claude/rules/*.md` | AI (Claude) | Path-specific rules activated by file context | Imperative, scoped |
| Code comments | Humans + AI | Line/function-specific gotchas | `// GOTCHA:` or `// NOTE:` inline |

## Mode Detection

**Full audit** — no prior conversation, or user asks to "create/update docs", or targets don't exist yet.
**Session distill** — mid-conversation, user asks to capture learnings/decisions/gotchas.

## Phase 1: Read State

1. Read `docs/ARCHITECTURE.md` if it exists. Check for topic files in `docs/`.
2. Read project-root `CLAUDE.md` if it exists.
3. List `.claude/rules/` and read existing rule files.
4. Note what exists and what's missing.

## Phase 2A: Full Audit

1. Map the codebase: `ls` root and key dirs, read config files (`package.json`, `Cargo.toml`, etc.), identify entry points and test structure.
2. Draft content for each target per the formats below.
3. Show draft for approval before writing.

## Phase 2B: Session Distill

1. Review conversation for: decisions + rationale, bugs + root causes, architectural insights, conventions discovered, gotchas, environment quirks, and other things user was confused with.
2. Read existing docs (all three targets).
3. For each finding, determine placement using the Placement Scope rules.
4. Show proposed changes for approval — grouped by target.

## Phase 3: Write

1. Write to the appropriate targets. Create `docs/` or `.claude/rules/` dirs if needed.
2. Add code comments for function/line-specific findings.
3. Never duplicate information across targets. Each fact lives in exactly one place.

## Placement Scope

Route each finding to where it will be discovered at the right time:

**`docs/ARCHITECTURE.md`** when:
- Project structure, directory layout, what lives where
- Key concepts and domain terminology
- Entry points and data flow
- Architectural decisions and rationale ("why we chose X over Y")
- Dependencies and what they're for

**`CLAUDE.md`** when:
- Build, test, lint, deploy commands
- Coding conventions (naming, patterns, style)
- Project-wide gotchas that affect how AI should write code
- Workflow rules ("always run X before Y", "never do Z")
- Important constraints AI must follow

**`.claude/rules/<topic>.md`** when:
- Rules specific to a directory or file pattern
- "When editing files in `src/api/`, always..."
- Test conventions for a specific test directory
- Component patterns for a specific framework area

**Code comment** when:
- Specific to one function or code block
- Explains non-obvious local behavior
- A developer reading that code would hit this issue
- Format: `// GOTCHA: ...` or `// NOTE: ...` near the relevant line

**When in doubt:** code comments > rules > CLAUDE.md > ARCHITECTURE.md (prefer the most specific, contextual location).

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
- Keep under ~50 lines. If it grows, move path-specific items to `.claude/rules/`

## Format: .claude/rules/*.md

- One clear topic per file, filename reflects scope
- Open with "When working with..." or "When editing..." to define scope
- Imperative voice, bullet lists
- Keep each file under ~30 lines

## Conciseness Rules (all targets)

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

- Do NOT duplicate across targets. Each fact in exactly one place.
- Do NOT duplicate README content. Reference it.
- Do NOT document external library APIs. Link to their docs.
- Do NOT add "last updated" timestamps — git handles that.
- Do NOT add code comments that restate what the code does.
- Do NOT put architecture descriptions in CLAUDE.md — that's for ARCHITECTURE.md.
- Do NOT put AI instructions in ARCHITECTURE.md — that's for CLAUDE.md.

## References
- You can always consult claude-code-guide agents for anything related to how Claude-specific files (CLAUDE.md, .claude/rules etc.) work.
