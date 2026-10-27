<!--
How to use this template:
1. Copy it to the project's docs/README.md.
2. Keep only the rows and sections the project has. Rows and sections marked "keep only if" are optional: delete them unless the project has that kind of doc, and delete the marker comment either way.
3. Replace each {placeholder} with the project's value.
4. Delete this comment.
-->

# docs

Where each kind of doc lives, the rules for writing them, and the status of every doc. Read this before adding, moving or writing a doc.

## Where each kind of doc lives

| Kind | Location | Format |
|---|---|---|
| System design (whole system, why) | `docs/design/{name}.md` | living, versioned via frontmatter `version` |
| As-built architecture | `docs/architecture.md` | describes only what exists in code |
| Decisions | `docs/decisions/{NNNN}-{slug}.md` | one decision per file, append-only |
| Specs (one milestone, testable) | `docs/specs/{milestone}-{slug}.md` | |
| Plans (task order) | `docs/plans/{milestone}-{slug}.md` | Tracker section at the top. Open milestones only: distilled, then deleted at close-out |
| Terms | `docs/glossary.md` | |
| Diagrams | `docs/assets/{name}.svg` | standalone SVG, see Diagrams |
| Spike findings <!-- keep only if the project has it --> | `docs/spikes/{id}-{slug}.md` | question, method, numbers, verdict |
| Milestone report <!-- keep only if the project has it --> | `docs/spikes/{milestone}-report.md` | one page over a milestone's spikes, for the user. Links to spikes for detail |
| Eval setup <!-- keep only if the project has it --> | `docs/evals/eval-setup.md` | living: label sets, evals, current numbers. Updated in place when labels, prompts or models change |
| Eval results <!-- keep only if the project has it --> | `docs/evals/{YYYY-MM-DD}-{slug}.md` | what changed, numbers, conclusion |
| Source connector notes <!-- keep only if the project has it --> | `docs/sources/{source}.md` | limits, quirks, terms of use |
| Acceptance evidence <!-- keep only if the project has it --> | `docs/results/{milestone}/` | captured output for each acceptance check in the spec |

If a fact fits two homes, put it in one and link from the other. Don't duplicate it.

## Frontmatter

Every doc in `docs/` (except READMEs and the glossary) starts with:

```yaml
---
title: {Title}
status: draft | accepted | superseded | done
updated: {YYYY-MM-DD}
---
```

Update `updated:` on every content change, and keep `docs/README.md`'s table in sync when adding, renaming or changing the status of a doc.

## Decisions

- Number sequentially and never reuse a number. Filenames are `{NNNN}-{kebab-slug}.md`.
- Sections: Context, Decision, Consequences, Alternatives considered.
- Never rewrite an accepted decision. To change one, write a new record with `supersedes: {NNNN}`, and set the old one's status to `superseded` with `superseded_by: {NNNN}`.
- Deferred questions are listed in `docs/decisions/README.md` under "Deferred" until decided.

## Writing

- No angle-bracket placeholders (`<name>`) in markdown. Use `{name}`.
- Use glossary terms exactly. Add a new term to the glossary before using it.

<!-- Optional section. Keep only if the project renders docs to HTML. Keep variant (a) or (b) and delete the other. -->
## Renders

<!-- Variant (a): renders are committed next to their source. -->
- Each render is a `.html` file beside its `.md` source. A tool generates it: `{render tool}`.
- Each doc with a render carries `rendered: {path to .html}` in its frontmatter.
- Never edit content in the HTML directly. Edit the `.md`, then re-render.
- After editing a `.md` that has `rendered:`, its HTML is stale. Re-render before asking anyone to review it, and run `{check command}`.
- Renders are standalone pages opened locally. They link other rendered docs by `.html`. Don't publish them to a shared host.

<!-- Variant (b): renders are made on demand and never committed. agent-docs is the example renderer. -->
- Renders are not committed. Make one to read it: `agent-docs open docs/{path}.md`.
- Check that every doc renders: `agent-docs check docs/`.
- Don't add generated `.html` renders to git.

<!-- Optional section. Keep only if the project has diagrams in docs/assets/. -->
## Diagrams

- Each SVG is standalone: `xmlns`, `class="{prefix}-d"`, `data-asset="{name}.svg"`, `role="img"`, an `aria-label` stating its claim, and an embedded `<style>`. Copy the `<style>` from an existing asset.
- Colors use `var(--page-token, var(--d-fallback))`. Standalone (GitHub, image viewers), the `--d-*` fallbacks apply, including a dark-mode media query. Inlined into a rendered page, the page's tokens win, so the page's theme switch works.
- A doc references a diagram as an image, followed by an italic caption line:

```markdown
![{aria-label}](../assets/{name}.svg)

*{Caption: what the reader should take from the diagram.}*
```

## Status

<!-- One row per doc on disk. Add a Render column only if the project renders docs. -->
| Doc | Status | Updated |
|---|---|---|
| [design/{name}.md](design/{name}.md) | draft v1 | {YYYY-MM-DD} |
