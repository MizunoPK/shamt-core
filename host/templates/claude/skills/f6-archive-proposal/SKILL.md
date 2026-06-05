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

Follow the canonical `/f6-archive-proposal` command body verbatim — see [`commands/f6-archive-proposal.md`](../../commands/f6-archive-proposal.md). Summary:

1. **Read and confirm** — resolve the proposal exact-then-glob (`proposals/{slug}.md`, then `proposals/*-{slug}.md` for the master-side `{NN}-` prefix); confirm a validation footer. Check for companions (`{NN}-{slug}_PLAN.md`, `{NN}-{slug}_PLAN_phase_N.md`); each must also carry a footer. **Determine numbered-ness** from the resolved filename's leading `^[0-9]+-` run (present = numbered, drives the `#NN` commit subject + `proposal/{NN}-{slug}` branch; absent = grandfathered, drops `#NN`, branch `proposal/{slug}`). Update `Status:` to `Implemented`.
2. **Move to archive** — ensure `proposals/archive/` exists; `git mv` (tracked) or `mv` the proposal + companions into it, **preserving the `{NN}-` prefix**. Confirm footers intact post-move. Halt if `proposals/archive/{slug}.md` (or `archive/*-{slug}.md`) already exists.
3. **Commit + squash-merge + delete branch** — behind pre-merge guards (HEAD on the proposal branch; working tree holds the canonical edits + archive move + regen output **plus any in-flow audit auto-fixes / captured f0 stubs**, which fold into this landing — `git status` is shown for visibility, not as a halt gate; regen has run; branch is a descendant of base). Commit with subject `shamt-core: land #{NN} {slug} (…)` (drop `#{NN}` when grandfathered), `git merge --squash` the proposal branch into the base branch as that one commit, then `git branch -D` the proposal branch **only after the merge commit succeeds**. Halt on any guard failure or git error.

## Recommended model

Balanced (Sonnet) — archiving now commits, squash-merges the `proposal/{NN}-{slug}` branch into the base branch, and deletes the branch behind pre-merge guards — an irreversible git-state mutation, not just a file move. See [`reference/model_selection.md`](../../../../../reference/model_selection.md).

## Exit criteria

Proposal (and companions) at `proposals/archive/{NN}-{slug}.md` with footers intact; the change committed + squash-merged to the base branch and the `proposal/{NN}-{slug}` branch deleted (after all guards held).

## Reject and defer

Not handled here. `/f6-archive-proposal` is the success path only. Use a manual `mv` to `proposals/rejected/` (with a top-of-file note) or `proposals/deferred/` for the other dispositions — these folders are documented in [`proposals/_template.md`](../../../../../proposals/_template.md) and `§3.4`.

---
Validated 2026-05-28 — 4 rounds, 1 adversarial sub-agent confirmed (Phase 8 implementation loop)

<!-- Managed by Shamt — do not edit. Regenerate from shamt-core/host/templates/claude/skills/f6-archive-proposal/SKILL.md. -->
