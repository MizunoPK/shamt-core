---
name: f6-archive-proposal
description: >
  Phase 7 of the Shamt framework-update flow. Move proposals/{slug}.md (and
  any companion {slug}_PLAN.md or phase files) to proposals/archive/,
  preserving the validation footer. Updates the proposal's Status header to
  Implemented before the move. Does NOT commit on the user's behalf —
  surfaces a suggested commit. Invoke when the user wants to archive a
  proposal, finalize a proposal, mark a proposal implemented, or close out
  the framework-update flow.
triggers:
  - "archive the proposal"
  - "archive proposals/{slug}.md"
  - "finalize the proposal"
  - "close out the framework update"
  - "mark the proposal implemented"
---

## Overview

Mirrors the `/f6-archive-proposal {slug}` slash command. Same canonical body, two host wirings.

## Protocol

Follow the canonical `/f6-archive-proposal` command body verbatim — see [`commands/f6-archive-proposal.md`](../../commands/f6-archive-proposal.md). Summary:

1. **Read and confirm** — `proposals/{slug}.md` exists with a validation footer. Check for companions (`{slug}_PLAN.md`, `{slug}_PLAN_phase_N.md`); each must also carry a footer. Update the proposal's `Status:` header to `Implemented`.
2. **Move to archive** — ensure `proposals/archive/` exists; `git mv` (when tracked) or plain `mv` the proposal and companions into it. Confirm footers intact post-move. Halt if `proposals/archive/{slug}.md` already exists.
3. **Commit suggestion** — do not commit on the user's behalf. Suggest a `git status` / `git diff` review + a unified commit covering canonical edits + regen output + archive.
4. **Exit** — state the archive path and that the framework-update flow is complete. No next-phase suggestion.

## Recommended model

Cheap (Haiku) — archive is mechanical: file move and status update. See [`reference/model_selection.md`](../../../../../reference/model_selection.md).

## Exit criteria

Proposal (and companions) at `proposals/archive/{slug}.md` with footers intact; commit prompted but not executed.

## Reject and defer

Not handled here. `/f6-archive-proposal` is the success path only. Use a manual `mv` to `proposals/rejected/` (with a top-of-file note) or `proposals/deferred/` for the other dispositions — these folders are documented in [`proposals/_template.md`](../../../../../proposals/_template.md) and `§3.4`.

---
Validated 2026-05-28 — 4 rounds, 1 adversarial sub-agent confirmed (Phase 8 implementation loop)

<!-- Managed by Shamt — do not edit. Regenerate from shamt-core/host/templates/claude/skills/f6-archive-proposal/SKILL.md. -->
