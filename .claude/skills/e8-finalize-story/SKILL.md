---
name: e8-finalize-story
description: >
  Run Phase 8 (Finalize) of the Shamt Engineer flow — the terminal step. Commit
  the story's work as a scoped unit and mark the originating work item done via
  the active tracker profile (ADO state / GitHub close / local Status flip),
  behind three guards: prior phases complete, scoped clean-tree commit, and
  explicit user confirmation. Writes the local Status: Done marker the status
  line reads. Invoke when the user wants to finalize a story, close it out,
  commit and mark it done, wrap up the story, or run phase 8.
triggers:
  - "finalize the story"
  - "finalize {slug}"
  - "close out the story"
  - "commit and mark the story done"
  - "wrap up the story"
  - "run phase 8"
  - "mark the work item done"
---

## Overview

Mirrors the `/e8-finalize-story {slug}` slash command. Same canonical body, two host wirings. The terminal Engineer-flow phase, modelled on `/f6-archive-proposal`.

## Protocol

Follow the canonical `/e8-finalize-story` command body verbatim — see [`commands/e8-finalize-story.md`](../../commands/e8-finalize-story.md). Summary:

1. **Resolve the story folder** — `stories/{slug}/` exact-then-glob (`stories/{slug}-*/`); halt on zero or multiple.
2. **Guard — prior phases complete** — Review ran + `addressed_feedback.md` has no `Pending` rows; Test PASSes when testing is enabled. Halt to the specific remediation command (`/e6` / `/e7` / `/e5`) on any failure.
3. **Guard — scoped clean-tree commit** — `git status --short`; commit only the story's own files; halt-and-ask on unrelated working-tree changes (mirrors `/e6-review-changes`).
4. **Guard — explicit confirmation** — show the exact files to commit + the work item to close + the `Status: Done` marker; wait for a yes (the remote close is outward-facing).
5. **Commit + mark done** — scoped commit on the feature branch; then per the active tracker profile: ado `az boards work-item update --state`, github `gh issue close`, local = the marker itself.
6. **Local finalize marker** — write `**Status: Done**` into `ticket.md` for all profiles (the status line's profile-independent Finalize signal).
7. **Exit** — terminal; no next-phase suggestion. The Engineer flow ends here.

## Recommended model

Cheap (Haiku) — mechanical: evaluate guards, stage a scoped commit, run one close command, flip a status line. See [`reference/model_selection.md`](../../../../../reference/model_selection.md).

## Exit criteria

The story's scoped work is committed (after the three guards held); the work item is marked done via the active tracker (or local-only); `ticket.md` carries `**Status: Done**`. Finalize does **not** move the story folder — epic archiving is `/p5-finalize-epic`'s job.

---

<!-- Managed by Shamt — do not edit. Regenerate from shamt-core/host/templates/claude/skills/e8-finalize-story/SKILL.md. -->
