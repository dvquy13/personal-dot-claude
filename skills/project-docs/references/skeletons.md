# Skeletons

Copy-ready starting points. Replace each `{placeholder}`, then delete the lines and comments that the project doesn't need.

## CLAUDE.md shape

Use when creating or restructuring the project's root `CLAUDE.md`. Keep the whole file under about 50 lines.

````markdown
# {Project name}

{One sentence: what the project is, and who it is for.}

**Status:** {milestone} done ({YYYY-MM-DD}): {what is true now}. Next: {next milestone or step}.

## Where to look

| Question | Read |
|---|---|
| What is the system and why is it shaped this way? | `docs/design/{name}.md` |
| What is actually built right now? | `docs/architecture.md` |
| Why was this decided? | `docs/decisions/` (index in its `README.md`) |
| What does a term mean? | `docs/glossary.md`. Use these terms exactly in code and docs. |
| What does milestone N build, and how is it verified? | `docs/specs/` |
| What's the task order and progress? | `docs/plans/` (Tracker at the top of each plan; open milestones only) |
| Map of all docs with status | `docs/README.md` |

## Docs workflow

- Where docs go and how to write them: `docs/README.md`. Read it before adding, moving or writing a doc.
- Distilling a session into docs: use the `project-docs` skill.

## Commands

```bash
{install command}
{test command}
{lint or check command}
```

## Conventions

- {Convention every change follows.}
- {Hard constraint, such as a rule about secrets.}
````

## Decision record

Use for one choice with its context, consequences and rejected alternatives. Save as `docs/decisions/{NNNN}-{kebab-slug}.md`. Never rewrite an accepted record. To change a decision, write a new record and set `supersedes:` on it.

````markdown
---
title: {Title in sentence case}
status: accepted
updated: {YYYY-MM-DD}
supersedes: {NNNN}
superseded_by: {NNNN}
---

# {NNNN} {Title}

## Context

<!-- The facts and forces behind the choice. Link the spike or spec that found them. -->

{Context.}

## Decision

{The choice, in one or two sentences.}

## Consequences

- {What becomes easier or possible.}
- {What becomes harder, or what must now be done.}

## Alternatives considered

- **{Alternative}.** {Why it was rejected.}
````

Delete `supersedes:` if the record replaces nothing. Set `superseded_by:` on the old record only, and change its `status` to `superseded`.

## decisions/README.md

Use as the decisions index. Add a row for each new record, and list open questions under Deferred until they are decided.

````markdown
# Decisions

One file per decision. Format and rules: `docs/README.md`.

| # | Decision | Status | Date |
|---|---|---|---|
| [{NNNN}]({NNNN}-{slug}.md) | {Decision as a short statement} | accepted | {YYYY-MM-DD} |

## Deferred

| Question | When | Notes |
|---|---|---|
| {Open question} | {milestone or trigger that forces the decision} | {What the decision will be based on, and who decides} |
````

## Spec results block

Use at milestone close-out, at the end of the spec. Each check's evidence lives under `docs/results/{milestone}/`.

````markdown
## Results

Run: {YYYY-MM-DD}, commit {hash}, {machine or environment}.

<!-- Outcome is one of: pass, fail, deferred. -->
| # | Outcome | Evidence |
|---|---|---|
| {1} | {pass} | `docs/results/{milestone}/{check}.txt` |

### What differed from the spec

- {Difference, and where it goes: the design doc, a new decision record, or architecture.md.}
````
