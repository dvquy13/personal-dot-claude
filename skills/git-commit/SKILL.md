---
name: git-commit
description: Review the current git unstaged changes and the current conversation session with user, then think about how to make a good commit messages that captures firstly the why, then what. If straightforward, commit directly. Otherwise, show a plan for approval.
disable-model-invocation: true
model: sonnet
allowed-tools: Bash(git *), Read, Glob, Grep
---

For the commit title, it should focus on the WHY but if possible be specific enough so that it's easy to look at the list of commit titles and recall what they were.

For the commit message details, be concise about the what.
