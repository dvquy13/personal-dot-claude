---
name: retro
description: >
  Review the current session to surface frictions, blockers, and root causes,
  then propose the right fixes to prevent them from recurring. Use when the
  user says "retro", "what went wrong", "lessons learned", "improve the workflow", 
  or wants to reflect on a session.
allowed-tools: Read, Write, Edit, Glob, Grep, Bash(git *), Bash(ls *)
---

# Retro

Run a lightweight retrospective on the current session, then surface **only actionable changes** that would prevent the same frictions next time.

## Phase 1: Identify Frictions

Scan the conversation for signals of friction:
- Misunderstandings or repeated clarifications
- Wrong assumptions that caused backtracking
- Missing context that had to be fetched mid-task
- Tool failures, unexpected errors, or environment surprises
- Tasks that took longer than they should have
- Anything the user had to correct or push back on

For each friction, identify the **root cause** — not just the symptom. Ask: "Why did this happen?" until you reach something fixable.

## Phase 2: Propose Fixes

For each root cause, propose the right fix.
