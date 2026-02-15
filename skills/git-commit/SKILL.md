---
name: git-commit
description: Review the current git unstaged changes and think about how to make a good commit messages that captures firstly the why, then what. If straightforward, commit directly. Otherwise, show a plan for approval.
disable-model-invocation: true
model: haiku
allowed-tools: Bash(git *), Read, Glob, Grep
---

# Git Commit

Review the current git unstaged changes and the current conversation session with users then think about how to make a good commit messages that captures firstly the why, then what.

If it's straight-forward then go ahead and git add and commit.

Otherwise, prepare a plan to show to the users and asking for feedback before proceeding to git add and commit.

For the commit title, it should focus on the WHY but if possible be specific enough so that it's easy to look at the list of commit titles and recall what they were.

For the commit message details, be concise about the what.