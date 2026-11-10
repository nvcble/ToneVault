---
name: handoff
description: Write a session handoff document - everything asked, found, decided and changed this session, plus the exact next steps - so the developer can restart with a fresh session and lose nothing. Use when the user says /handoff, "hand off", "wrap up this session", "I'm restarting", or wants to save context before starting over.
allowed-tools: Read, Write, Glob, Bash(git:*)
---

# Session handoff

Produce one self-contained document that lets a brand-new session continue
this work without the conversation. The reader has **no memory of this
session** - write for them, not for the user who was here.

## Steps

1. **Ground it in facts, not recall.** Run `git branch --show-current`,
   `git status --short`, `git diff --stat` and `git log --oneline -10`. Then
   re-read the conversation from the top. List every user request, question and
   decision in order - including ones that were answered with "no change
   needed" or "not possible".
2. **Check the newest outcomes.** Anything still running or unverified (a test
   run, a build, a capture) is recorded as such, with what to run to find out.
   Never write "passes" for something you did not see pass.
3. **Write the file** to `docs/handoff/handoff-YYYY-MM-DD-<short-topic>.md`
   (create the folder if needed; take the date from the system, never guess).
   Then write the same content to `docs/handoff/LATEST.md`, overwriting it.
4. **Do not commit or push it.** Tell the user the path and that it is
   uncommitted. Mention `/ship` if they want it in git.
5. **Reply briefly**: the path, a three-line summary, and the one-line prompt
   to paste into the new session (see the last section below).

## Required sections, in this order

### 1. Snapshot
Date, branch, last commit hash and subject, and whether the working tree is
clean. One line on the goal of the session.

### 2. What the user asked
Every request and question, in order, each with its **outcome**: done / answered
/ blocked / declined / still open. Quote the user's own wording for any
requirement or decision that shapes the design.

**Carry forward open requirements.** Read the previous `LATEST.md` and the
newest earlier handoffs for the same feature area. Every user requirement that
is still open (not built, or built only in part) is listed here under
"Carried-over requirements" and given a numbered next step, even if this
session never touched it. A requirement that falls out of the latest handoff
is silently lost.

### 3. What was done
Grouped by topic. For each change: what and why, and the file paths touched.
Mark each file `new`, `modified` or `deleted`. Include generated files
separately (for example `*.g.dart`) so they are not mistaken for hand edits.

### 4. What was found (investigation, no code)
Findings that cost effort to obtain and are not visible in the code: tool or
file locations on the machine, protocol facts, dead ends, things ruled out and
why. Give each a confidence label - **Verified**, **Official**, **Inferred** or
**Unknown** - and say what it was verified against.

### 5. Decisions and constraints
Decisions the user made, rules they stated, and project rules that applied
(file-size limit, no invented protocol behaviour, and so on). Include what was
deliberately *not* done and why.

### 6. State of verification
Tests and analysis: what ran, the counts, and what failed and how it was fixed.
Anything not run, skipped or only partly checked is listed plainly. State
whether the running build or device has the changes (a source edit is not an
installed build).

### 7. Open items and risks
Known gaps, uncommitted work, things that could surprise the next session
(for example a migration that has not met a real phone, a test-harness trap
that cost time). Be specific.

### 8. Next steps
A numbered, **ordered** list. Each step has: the action, why it is next, the
file or command to start from, and its blocker if any. Mark which steps need
the user (hardware, a decision, an install) and which can proceed alone.
Nothing discussed this session may be left out - if it was mentioned and not
finished, it appears here or in section 7.

### 9. First move for the new session
The exact first three things to do on restart, and the one-line prompt to
paste, for example:

> Read `docs/handoff/LATEST.md`, check `git status`, then continue with next
> step 1.

## Rules

- **Faithful over flattering.** Failures, retractions, skipped checks and
  wrong turns go in. A handoff that hides them sends the next session down the
  same hole.
- **No invention.** If a detail is not in the conversation or the repo, leave
  it out or mark it Unknown. Do not reconstruct file paths or numbers from
  memory - check them.
- **No secrets.** Never write tokens, keys, passwords or personal data into the
  document, even if they appeared in the session.
- **Self-contained.** Use full relative paths, not "the file we edited". Do not
  say "as discussed" or "above".
- **Concise, not thin.** Bullets and short sentences; every line should save
  the next session a lookup. Target one screenful per section.
- If the repo keeps persistent memory notes, flag any that the session made
  stale in section 7 rather than editing them silently.
