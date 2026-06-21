---
name: e8-finalize-story
description: >
  Run Phase 8 (Finalize) of the Shamt Engineer flow — the terminal step. Commit
  the story's work as a scoped unit and mark the originating work item done via
  the active tracker profile (ADO state / GitHub close / local Status flip),
  behind three guards: prior phases complete, scoped clean-tree commit, and
  explicit user confirmation. When pr_provider == github, also merges the story's
  PR (gh pr merge --squash --delete-branch, behind the same confirm + a
  mergeable-guard) — independent of the work_item_tracker-routed close. Writes the
  local Status: Done marker the status line reads. Invoke when the user wants to
  finalize a story, close it out, commit and mark it done, wrap up the story, or run phase 8.
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

Follow the canonical `/e8-finalize-story` command body verbatim — see [`commands/e8-finalize-story.md`](../../commands/e8-finalize-story.md).

## Recommended model

Cheap (Haiku) — mechanical: evaluate guards, stage a scoped commit, run one close command, flip a status line. See [`reference/model_selection.md`](../../../../../reference/model_selection.md).

## Exit criteria

The story's scoped work is committed (after the three guards held); the work item is marked done via the active tracker (or local-only), independent of `pr_provider`; `ticket.md` carries `**Status: Done**`. When `pr_provider == github`, the story's PR is merged (`gh pr merge --squash --delete-branch`, behind the Step-3 confirm + a mergeable-guard). Finalize does **not** move the story folder — epic archiving is `/pe4-finalize`'s job.

---

<!-- Managed by Shamt — do not edit. Regenerate from shamt-core/host/templates/claude/skills/e8-finalize-story/SKILL.md. -->
