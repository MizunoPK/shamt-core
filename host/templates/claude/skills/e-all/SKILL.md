---
name: e-all
description: >
  Driver that walks a single story through every remaining Engineer-flow phase
  end-to-end — /e1-start-story → /e2-define-spec → (optional /e3-plan-implementation
  + /e3b-write-testing-plan on the Standard path) → /e4-execute-plan →
  /e5-execute-tests → /e6-review-changes → /e7-resolve-feedback →
  /e8-finalize-story — by dispatching one independent Agent sub-agent per phase
  in the shared working tree, deriving the start phase from on-disk artifacts (so
  it is itself slug-resumable), pausing on each interactive gate (Gate 2a design
  dialog, Gate 2b / Gate 3 approvals, /e7 polish dialog, /e8 finalize confirm) or
  structured open question via AskUserQuestion, and halting on any failure it
  cannot resolve (test failure, ambiguity, inconsistent state) with the report
  surfaced verbatim. A stateless, disk-derived dispatcher of the canonical
  Engineer-phase commands — not a replacement for them; each /eX stays
  independently runnable, honoring Principle 1. Child-facing — runs wherever the
  Engineer flow runs (every child project, and master self-host), with no
  master-only guard. Invoke when the user wants to run the rest of the story,
  drive this story to done, take a story through build / test / review / finalize,
  or auto-run the remaining Engineer-flow phases for a story.
triggers:
  - "run the rest of the story"
  - "drive this story to done"
  - "take this story through build/test/review"
  - "finish the story for {slug}"
  - "run all the remaining story phases"
  - "auto-run e2 through e8"
  - "orchestrate the engineer flow for {slug}"
---

## Overview

Mirrors the `/e-all {slug}` slash command. Same canonical body, two host wirings. `/e-all` is the **optional one-shot driver** over the numbered Engineer-flow phases; the per-phase commands (`/e1-start-story`, `/e2-define-spec`, `/e3-plan-implementation`, `/e3b-write-testing-plan`, `/e4-execute-plan`, `/e5-execute-tests`, `/e6-review-changes`, `/e7-resolve-feedback`, `/e8-finalize-story`) remain the supported manual path and each stays independently runnable.

## Child-facing — no master guard

Unlike `/f-all`, `/e-all` runs **wherever the Engineer flow runs** — every child project, and master self-host. The Engineer flow is the story-execution flow every child runs, so there is **no** master-only Step-0 child halt. A contributor adapting `/f-all` must **not** copy its master-only guard.

## Protocol

Follow the canonical `/e-all` command body verbatim — see [`commands/e-all.md`](../../commands/e-all.md). The one-nesting-level dispatch pattern it reproduces lives in [`reference/batch_validation_handoff.md`](../../../../../reference/batch_validation_handoff.md). Summary:

1. **Derive the starting phase from disk, once at launch** (the resumability guarantee). Discriminators under `stories/{slug}/`: `ticket.md` absent → Phase 1 (`/e1`); ticket present + `spec.md` not footed → Phase 2 (`/e2`); spec footed (its `Path:` header selects Quick vs Standard) + Standard plan not footed → Phase 3 (`/e3`); plan footed + suites declared + testing plan absent → Phase 3 (`/e3b`); plan done + **build gate** not clean → Phase 4 (`/e4` — gate-derived, since `/e4` writes no marker; the plan's `## Verification` / spec Build Checklist walks clean, mirroring `/f-all`'s diff-coverage gate); build clean + tests not `Session PASS` → Phase 5 (`/e5`); tests pass + `feedback/review_vN.md` not footed → Phase 6 (`/e6`); review done + `feedback/addressed_feedback.md` not dispositioned → Phase 7 (`/e7`); polish done + `ticket.md` not `**Status: Done**` → Phase 8 (`/e8`); ticket `**Status: Done**` → already complete. A partially-applied / inconsistent state (e.g. a build gate that would not walk clean) → **halt** (strict-halt; never guess). Thereafter advance on each phase agent's report, not by re-scanning disk.
2. **The chain:** `/e1` → `/e2` → (`/e3` + `/e3b` + validate, **Standard path only**, `/e3b` only when TESTING_STANDARDS declares suites) → `/e4` → `/e5` → `/e6` → `/e7` → `/e8`. Quick-path stories skip `/e3` / `/e3b` (build runs the spec's Build Checklist directly). `/e5b-write-manual-testing-plan` is **excluded** (optional, on-demand, orthogonal to the required Phase-5 agent-as-user run — mirrors `/f5`'s exclusion from `/f-all`). Path + suite detection are mechanical disk/config reads (spec `Path:` header; `TESTING_STANDARDS.md`), not user questions; a suites-declared-but-missing/incomplete TESTING_STANDARDS surfaces at Phase 5 as the `user-simulator`'s `Cannot run: …` halt, not a pre-flight fail.
3. **Dispatch topology — exactly one nesting level.** Self-contained phases (`/e1`, `/e8`, Quick-path phases that spawn nothing) are **invoked directly** in their own `Agent`. Phases that internally need a sub-agent (`/e2` / `/e3` / `/e3b` / `/e6` validation → `validation-checker`; `/e4` build hand-off → `plan-executor`; `/e5` → `user-simulator` + `test-executor`) run the command's **inline steps**, halt at the hand-off, and the **driver** dispatches the inner persona itself. The Engineer flow's architect/builder split spans **two** phases (architect plans at `/e3`, builder executes at `/e4`), so the `plan-executor` dispatch is `/e4`'s — unlike `/f-all`'s `/f3` which both plans and hands off within one phase. Dispatching a sub-agent to *invoke* `/eX` (which would auto-spawn a second-level sub-agent) is the infeasible approach and is ruled out. **Always the shared working tree — never `isolation: worktree`** (`/e4`'s build edits must reach `/e5` / `/e6` / `/e7` / `/e8`). No persona edit — all inner personas are reused unchanged.
4. **Advance / pause / halt off each phase's report contract.** Advance: clean validation exit (`CONFIRMED: Zero issues found after adversarial review.`), `plan-executor` `All steps completed. Verification passed.`, `test-executor` `All steps passed. Results logged.`, `user-simulator` `Session PASS`, a self-contained `/eX` reporting its documented exit. **Pause (gate-heavy — far more than `/f-all`):** each interactive gate (Gate 2a design dialog, Gate 2b / Gate 3 approvals, `/e7` polish dialog, `/e8` finalize confirm), `plan-executor` / `test-executor` `Step [N] is ambiguous: …`, or an inline-instruction primary returning the verbatim `Open question: … | To resolve: …` sentinel the driver's dispatch prompt defines — lift to the user via `AskUserQuestion`, feed the answer back, re-dispatch the phase **against its on-disk artifact** (fresh context resumes from saved state). **Halt (strict — Q-testloop):** any Phase-5 *failure* exit (`test-executor` `Step [N] failed: Story bug / Test bug / Spec gap / …`, `Plan defect at Step [N]: …`, `Environment blocked at Step [N]: …`; `user-simulator` `Session BLOCKED: …` or `Cannot run: TESTING_STANDARDS.md missing/incomplete — complete it first.`), `plan-executor` `Step [N] failed: …` / `Plan defect …`, any non-convergent validation, any `/eX` halt, any inconsistent state — surface verbatim, no retry, no remediation. The `/e5` → `/e7` → re-`/e5` loop stays **manual**; the driver never autonomously edits code to chase a green.
5. **Terminal `/e8` guard.** Before the irreversible commit + tracker-close, re-confirm `/e8`'s own three guards (prior phases complete; scoped clean tree; **explicit user confirmation** surfaced via `AskUserQuestion`) are evaluated, not bypassed. `/e8`'s built-in confirm makes the terminal step always user-gated — strictly safer than `/f-all`'s autonomous squash-merge.

## Recommended models

- Driver (this command): Balanced (Sonnet) — sequences phases, dispatches sub-agents, inspects reports, halts/pauses. The heavy per-phase reasoning lives in the dispatched agents at their own tiers (spec / plan-validation primary Reasoning; `plan-executor` Cheap; `user-simulator` Balanced; `test-executor` / `validation-checker` Cheap; story-review primary Balanced).

See [`reference/model_selection.md`](../../../../../reference/model_selection.md).

## Exit criteria

The story walked from its derived start phase through `/e8-finalize-story` (committed + tracker-closed), **or** the run paused on an interactive gate / structured open question (resumed in-place) / halted on a non-clean outcome with the verbatim report surfaced. Every phase ran as an independent `Agent` in the shared working tree (no worktree isolation); exactly one nesting level throughout; the terminal `/e8` commit + tracker-close ran behind `/e8`'s own three guards (never bypassed). Child-facing — runs wherever the Engineer flow runs, with no master-only guard.

---
Created 2026-06-15 — by /f3-implement-update for proposals/27-e-all-orchestrate-engineer-flow.md (the /e-all Engineer-flow story driver, Phase 4 of the framework-update flow).

<!-- Managed by Shamt — do not edit. Regenerate from shamt-core/host/templates/claude/skills/e-all/SKILL.md. -->
