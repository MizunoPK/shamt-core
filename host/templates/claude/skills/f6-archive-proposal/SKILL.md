---
name: f6-archive-proposal
description: >
  Phase 7 of the Shamt framework-update flow. Move proposals/{slug}.md (and
  any companion {slug}_PLAN.md or phase files) to proposals/archive/,
  preserving the validation footer. Updates the proposal's Status header to
  Implemented before the move, then commits the change, squash-merges the
  proposal/{NN}-{slug} branch into the base branch, and deletes the branch —
  behind pre-merge guards (an irreversible git-state mutation). Invoke when
  the user wants to archive a proposal, finalize a proposal, mark a proposal
  implemented, or close out the framework-update flow.
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

Follow the canonical `/f6-archive-proposal` command body verbatim — see [`commands/f6-archive-proposal.md`](../../commands/f6-archive-proposal.md).

## Recommended model

Balanced (Sonnet) — archiving now commits, squash-merges the `proposal/{NN}-{slug}` branch into the base branch, and deletes the branch behind pre-merge guards — an irreversible git-state mutation, not just a file move. See [`reference/model_selection.md`](../../../../../reference/model_selection.md).

## Exit criteria

Proposal (and companions) at `proposals/archive/{NN}-{slug}.md` with footers intact; the change committed + squash-merged to the base branch and the `proposal/{NN}-{slug}` branch deleted (after all guards held).

## Reject and defer

Not handled here. `/f6-archive-proposal` is the success path only. Use a manual `mv` to `proposals/rejected/` (with a top-of-file note) or `proposals/deferred/` for the other dispositions — these folders are documented in [`proposals/_template.md`](../../../../../proposals/_template.md).

---
Validated 2026-05-28 — 4 rounds, 1 adversarial sub-agent confirmed (Phase 8 implementation loop)

<!-- Managed by Shamt — do not edit. Regenerate from shamt-core/host/templates/claude/skills/f6-archive-proposal/SKILL.md. -->
