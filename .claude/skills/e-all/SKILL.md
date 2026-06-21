---
name: e-all
description: >
  Driver that walks a single story through every remaining Engineer-flow phase
  up to and including Review — /e1-start-story → /e2-define-spec → (optional
  /e3-plan-implementation + /e3b-write-testing-plan on the Standard path) →
  /e4-execute-plan → /e5-execute-tests → /e6-review-changes (opening the PR when
  pr_provider == github) — by dispatching one independent Agent sub-agent per phase
  in the shared working tree, deriving the start phase from on-disk artifacts (so
  it is itself slug-resumable), pausing on each interactive gate (Gate 2a design
  dialog, Gate 2b / Gate 3 approvals) or structured open question via AskUserQuestion, and halting on any failure it
  cannot resolve (test failure, ambiguity, inconsistent state) with the report
  surfaced verbatim. Polish (/e7, iterative) and Finalize (/e8) are operator-driven
  — not auto-run by /e-all. A stateless, disk-derived dispatcher of the canonical
  Engineer-phase commands — not a replacement for them; each /eX stays
  independently runnable, honoring Principle 1. Child-facing — runs wherever the
  Engineer flow runs (every child project, and master self-host), with no
  master-only guard. Invoke when the user wants to run the rest of the story,
  drive this story through Review, take a story through build / test / review,
  or auto-run the remaining Engineer-flow phases up to Review for a story.
triggers:
  - "run the rest of the story"
  - "drive this story to done"
  - "take this story through build/test/review"
  - "finish the story for {slug}"
  - "run all the remaining story phases"
  - "auto-run e2 through e6"
  - "orchestrate the engineer flow for {slug}"
---

## Overview

Mirrors the `/e-all {slug}` slash command. Same canonical body, two host wirings. `/e-all` is the **optional one-shot driver** over the numbered Engineer-flow phases; the per-phase commands (`/e1-start-story`, `/e2-define-spec`, `/e3-plan-implementation`, `/e3b-write-testing-plan`, `/e4-execute-plan`, `/e5-execute-tests`, `/e6-review-changes`, `/e7-resolve-feedback`, `/e8-finalize-story`) remain the supported manual path and each stays independently runnable.

## Child-facing — no master guard

Unlike `/f-all`, `/e-all` runs **wherever the Engineer flow runs** — every child project, and master self-host. The Engineer flow is the story-execution flow every child runs, so there is **no** master-only Step-0 child halt. A contributor adapting `/f-all` must **not** copy its master-only guard.

## Protocol

Follow the canonical `/e-all` command body verbatim — see [`commands/e-all.md`](../../commands/e-all.md). The one-nesting-level dispatch pattern it reproduces lives in [`reference/batch_validation_handoff.md`](../../../../../reference/batch_validation_handoff.md).

## Recommended models

- Driver (this command): Balanced (Sonnet) — sequences phases, dispatches sub-agents, inspects reports, halts/pauses. The heavy per-phase reasoning lives in the dispatched agents at their own tiers (spec / plan-validation primary Reasoning; `plan-executor` Cheap; `user-simulator` Balanced; `test-executor` / `validation-checker` Cheap; story-review primary Balanced).

See [`reference/model_selection.md`](../../../../../reference/model_selection.md).

## Exit criteria

The story walked from its derived start phase through `/e6-review-changes` (review validated; PR opened when `pr_provider == github`), **or** the run paused on an interactive gate / structured open question (resumed in-place) / halted on a non-clean outcome with the verbatim report surfaced. Every phase ran as an independent `Agent` in the shared working tree (no worktree isolation); exactly one nesting level throughout. Polish (`/e7`, iterative) and Finalize (`/e8`) are operator-driven — not part of the `/e-all` chain. Child-facing — runs wherever the Engineer flow runs, with no master-only guard.

---
Created 2026-06-15 — by /f3-implement-update for proposals/27-e-all-orchestrate-engineer-flow.md (the /e-all Engineer-flow story driver, Phase 4 of the framework-update flow).

<!-- Managed by Shamt — do not edit. Regenerate from shamt-core/host/templates/claude/skills/e-all/SKILL.md. -->
