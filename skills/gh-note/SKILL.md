---
name: gh-note
description: Document work via GitHub issues. Auto-creates an issue if none exists, otherwise adds a comment. Use when the user invokes "/gh-note", asks to "document this on GitHub", "create a GitHub issue", "add a note to the issue", or "log this finding".
argument-hint: [message or path/to/plan.md]
model: haiku
allowed-tools: Bash(gh *), Bash(git *), Read, Glob, Grep
---

# GitHub Issue Note

Document work in progress via GitHub issues. Auto-detect whether to create a new issue or add a comment to an existing one. The user provides a brief hint in `$ARGUMENTS`; use the full conversation context to compose a well-structured issue or comment.

## Phase 1: Detect Repository

Run `gh repo view --json nameWithOwner -q .nameWithOwner` to confirm this is a GitHub repository. If it fails, stop with: "Not in a GitHub repository."

## Phase 2: Resolve Current Issue

Determine the active issue number using this resolution order (first match wins):

1. **Explicit argument** — check if `$ARGUMENTS` contains `#N` (e.g. `#42`). Extract the number.
2. **Branch name** — run `git branch --show-current`. Match leading digits (`42-fix-auth`) or patterns `issue-42`, `gh-42`. Extract the number.
3. **Marker file** — read `.gh-issue` in the repo root. It contains a bare issue number.

If an issue number is found, validate it exists on GitHub: `gh issue view <number> --json number,state -q .number`. If valid, proceed to **Phase 4**. If the issue doesn't exist on GitHub, warn the user and proceed to **Phase 3**.

If no issue number is found, proceed to **Phase 3**.

## Phase 3: Create Issue (First-Time Path)

1. **Find plan file**: Check `$ARGUMENTS` for a `.md` file path. If none, scan `.claude/plans/*.md` for files related to the current work.
2. **Compose title and body**:
   - If a plan file is found: extract the `# heading` as the title, use the file content (trimmed to a reasonable length) as the issue body.
   - If no plan file: use conversation context to compose a concise title and descriptive body summarizing the current task.
3. **Show draft** to the user for approval. Include the proposed title and body.
4. **Create the issue**: `gh issue create --title "<title>" --body "<body>"`. Capture the issue URL and extract the issue number.
5. **GitHub Project** (optional): If `$ARGUMENTS` contains `--project <number>`, run `gh project item-add <number> --owner <owner> --url <issue-url>`.
6. **Write marker file**: Write the issue number to `.gh-issue` in the repo root.
7. **Check global gitignore**: Run `git config --global core.excludesfile` to find the global gitignore path. If `.gh-issue` is not listed there, warn:
   > `.gh-issue` is not in your global gitignore. Run: `echo '.gh-issue' >> ~/.gitignore_global && git config --global core.excludesfile ~/.gitignore_global`
8. Continue to **Phase 4** to add the note as the first comment.

## Phase 4: Add Comment

1. **Compose the comment**: Use `$ARGUMENTS` as a hint/seed. Draw from the full conversation context to write a well-structured comment. Choose the best format for the content — headers, code blocks, tables, bullet lists, timelines, etc. No predefined categories; pick whatever structure fits.
2. **Show draft** to the user for approval.
3. **Post the comment**: `gh issue comment <number> --body "<body>"`.
4. Confirm success with the issue URL.
