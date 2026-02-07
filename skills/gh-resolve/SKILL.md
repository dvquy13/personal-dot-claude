---
name: gh-resolve
description: Wrap up the current task — commit, push, and close the GitHub issue. Use when the user invokes "/gh-resolve", asks to "close the issue", "wrap up this task", or "finish and push".
argument-hint: [#issue-number]
model: haiku
allowed-tools: Bash(gh *), Bash(git *), Read, Glob, Grep
---

# GitHub Issue Resolve

Wrap up the current task — commit changes (with approval), push to remote, close the GitHub issue, and clean up the marker file.

## Phase 1: Resolve Issue Number

Determine the active issue number using this resolution order (first match wins):

1. **Explicit argument** — check if `$ARGUMENTS` contains `#N` (e.g. `#42`). Extract the number.
2. **Branch name** — run `git branch --show-current`. Match leading digits (`42-fix-auth`) or patterns `issue-42`, `gh-42`. Extract the number.
3. **Marker file** — read `.gh-issue` in the repo root. It contains a bare issue number.

If no issue number is found, stop with:
> No active issue found. Provide an issue number (e.g. `/gh-resolve #42`), work on a branch named like `42-fix-auth`, or create an issue first with `/gh-note`.

Validate the issue exists and is open: `gh issue view <number> --json number,state,title -q .state`. If already closed, stop with: "Issue #N is already closed."

## Phase 2: Check Working Tree

Run these commands and report state to the user:

- `git status` — show uncommitted changes
- `git diff --stat` — show changed files summary
- `git log @{push}..HEAD --oneline 2>/dev/null || git log origin/$(git branch --show-current)..HEAD --oneline 2>/dev/null` — show unpushed commits

Summarize: how many uncommitted changes, how many unpushed commits.

## Phase 3: Commit (With Approval)

Skip this phase if there are no uncommitted changes (both staged and unstaged).

1. **Compose commit message**: Summarize the changes. Include `Closes #N` in the message body (not the subject line) so GitHub auto-closes the issue on merge/push to default branch.
2. **Show the proposed commit** to the user: the commit message and the list of files to be staged. Wait for explicit approval.
3. **Stage and commit**: Stage the relevant files (prefer specific files over `git add -A`) and commit. Use the standard Co-Authored-By trailer.

## Phase 4: Push

1. Push to remote: `git push`. If no upstream is set, try `git push -u origin <branch>`.
2. If push fails, **stop immediately**. Do NOT proceed to close the issue. Report the error.

## Phase 5: Close Issue

1. Check issue state first: `gh issue view <number> --json state -q .state` — if already closed by the push (via `Closes #N`), skip to Phase 6.
2. **Post a closing comment**: Brief summary of what was done (reference key commits or changes). Post via `gh issue comment <number> --body "<body>"`.
3. **Close the issue**: `gh issue close <number>`.

## Phase 6: Cleanup

1. **Remove marker file**: Delete `.gh-issue` from the repo root if it exists.
2. **Branch suggestion**: If on a feature branch (not `main` or `master`), suggest merging or creating a PR to the default branch.
