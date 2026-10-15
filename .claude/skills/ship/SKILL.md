---
name: ship
description: Stage, commit and push the current work. Use when the user asks to commit, to push, to ship, or to "save this to git" - optionally for named files only.
allowed-tools: Read, Bash(git:*)
---

# Commit and push

## Steps

1. `git status --short`, `git diff --stat` and `git branch --show-current` -
   read what is actually changing before writing a message about it.
2. If the branch is `main`, branch first: `git checkout -b <topic-branch>`.
   Never commit straight to the default branch.
3. Stage only the paths the user named, or all changes if they named none.
   Leave anything that looks like a secret or a local build artifact
   (`local.properties`, `.env`, `build/`) unstaged and say you did.
4. Commit with the message shape below.
5. `git push -u origin <branch>`.
6. Report the short hash, the subject line, and the files committed.

## Message shape

```
<imperative subject, <=72 chars, says what changed and why it matters>

<optional body: one short paragraph, only when the subject cannot carry it>

Co-Authored-By: Claude Opus 5 <noreply@anthropic.com>
```

Match the repo's own history (`git log --oneline -10`): scoped and specific,
e.g. `MG-30 V5: decode and import a QuickTone patch export`. Never `updates`
or `fixes`.

## Never without being asked

`--amend`, `--force`, `rebase`, `reset --hard`, or committing a version bump
together with unrelated work. If the working tree holds several unrelated
changes, say so and ask which to commit rather than bundling them.
