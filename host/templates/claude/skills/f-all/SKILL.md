---
name: f-all
description: >
  Meta-driver (master / self-host only) that walks a validated framework-update
  proposal through every remaining phase end-to-end — validate(proposal) →
  (optional /f2 + validate(plan) when the proposal carries the >10-file-ops
  note) → /f3-implement-update → /f4-regen-framework → /f5-audit-framework →
  /f6-archive-proposal — by dispatching one independent Agent sub-agent per
  phase in the shared working tree, deriving the start phase from on-disk
  artifacts (so it is itself slug-resumable), and pausing only when a phase
  surfaces a structured open question (lifted to the user via AskUserQuestion)
  or halting on any other non-clean outcome (failure, drift, ambiguity,
  non-convergence) with the report surfaced verbatim. /f5-audit-framework
  (Phase 6) runs in-chain between /f4 and /f6 via the driver-lifted
  audit-checker topology; its auto-fixes + f0 captures fold into the /f6
  squash commit.
  A stateless, disk-derived dispatcher of the canonical phase commands — not a
  replacement for them; each /fX stays independently runnable, honoring
  Principle 1. Invoked in a child it halts and redirects to the per-phase
  commands. Invoke when the user wants to run the rest of the framework update,
  drive a proposal to merge, finish all the framework-update phases, or
  auto-run f3 → f4 → f6 for a validated proposal.
triggers:
  - "run the rest of the framework update"
  - "drive this proposal to merge"
  - "finish the framework update for {slug}"
  - "run all the remaining framework-update phases"
  - "auto-run f3 f4 f6"
  - "land this proposal end to end"
  - "orchestrate the framework-update flow for {slug}"
---

## Overview

Mirrors the `/f-all {slug}` slash command. Same canonical body, two host wirings. `/f-all` is the **optional one-shot driver** over the numbered framework-update phases; the per-phase commands (`/validate-artifact`, `/f2`, `/f3`, `/f4`, `/f6`) remain the supported manual path and each stays independently runnable.

## Master / self-host only

The phases `/f-all` drives — branch creation, canonical edits, regen, squash-merge — are master-side only. **Invoked in a child it halts immediately** and redirects to the per-phase commands (`/f1-propose-update {slug}` → `/sync-submit-proposal {slug}`). Mirrors `/f5-audit-framework`'s child-side behavior.

## Protocol

Follow the canonical `/f-all` command body verbatim — see [`commands/f-all.md`](../../commands/f-all.md). The one-nesting-level dispatch pattern it reproduces lives in [`reference/batch_validation_handoff.md`](../../../../../reference/batch_validation_handoff.md). Summary:

0. **Step 0 — target context (master / self-host only).** Resolve via the self-host detection rule. **Master / self-host** → proceed. **Child** → halt and redirect to `/f1-propose-update` → `/sync-submit-proposal`.
1. **Derive the starting phase from disk, once at launch** (the resumability guarantee). Discriminators: no validation footer → Phase 2 (validate); footed + Phase-3 note + no footed plan → Phase 3 (`/f2` + validate plan); footed + ready + no `proposal/{NN}-{slug}` branch → Phase 4 (`/f3`); branch present + `/f3` diff-coverage gate passes → Phase 5 (`/f4`); zero-drift `--check` → Phase 6 (audit — the audit leaves no disk marker, so a clean post-`/f4` and a clean post-audit state both route here; resume re-runs the whole harmless audit phase); proposal under `proposals/archive/` → already complete. A partially-applied / inconsistent state → **halt** (strict-halt; never guess). Thereafter advance on each phase agent's report, not by re-scanning disk.
2. **The chain:** validate(proposal) → (`/f2` + validate(plan), **only** when the proposal carries the `Phase 3 required — file count {N} > 10.` note — single-file plan = inline driver-lifted validation, phase-decomposed plan = batch-validation handoff) → `/f3` → `/f4` → `/f5-audit-framework` → `/f6`. **`/f5-audit-framework` (Phase 6) is included** — always-on, between `/f4` and `/f6` (the normal Phase 5→6→7 order). The audit runs the same driver-lifted-inner-persona topology as Phase 2: the audit phase agent runs f5's inline Steps 1–4 to a clean round (no new auto-fix AND no new f0 draft; f0-capture is an inline stub-write applying `/f0-draft-proposal`'s logic, spawning nothing) and **halts before f5's Step 5 without invoking `/f5-audit-framework`**; the **driver** then lifts the `audit-checker` confirmation, re-dispatching the primary on any resettable finding until `CONFIRMED`. The audit's only sub-agent is that `audit-checker`. Its auto-fixes + this-run f0 captures **fold into the `/f6` squash commit** (per `f5-audit-framework.md` Step 3's "In-flow logging"). Resumability is **idempotency-based** — no new disk marker; the zero-drift `--check` discriminator routes to **Phase 6**, and a resumed run re-runs the entire harmless audit phase (primary loop AND `audit-checker`) before `/f6`. The audit never prompts the user, so Phase 6 has no open-question pause sentinel.
3. **Dispatch topology — exactly one nesting level.** Self-contained phases (`/f2` authoring, `/f4`, `/f6`, `/f3`'s inline ≤10-ops path) are **invoked directly** in their own `Agent`. Phases that internally need a sub-agent (every `/validate-artifact` run's `validation-checker`; `/f3`'s `plan-executor`) run the command's **inline steps**, halt at the hand-off, and the **driver** dispatches the inner persona itself. Dispatching a sub-agent to *invoke* `/validate-artifact` or `/f3` (which would auto-spawn a second-level sub-agent) is the infeasible approach and is ruled out. **Always the shared working tree — never `isolation: worktree`** (`/f3`'s branch + edits must reach `/f4` and `/f6`). No persona edit — `validation-checker` / `plan-executor` are reused unchanged.
4. **Advance / pause / halt off each phase's report contract.** Advance: clean `/validate-artifact` exit, `plan-executor` `All steps completed. Verification passed.`, a self-contained `/fX` reporting its documented exit. **Pause (the one resume case):** a structured open question — `plan-executor` `Step [N] is ambiguous: …`, or an inline-validation primary returning the verbatim `Open question: … | To resolve: …` sentinel the driver's dispatch prompt defines — lift to the user via `AskUserQuestion`, feed the answer back, re-dispatch. **Halt:** `plan-executor` `Step [N] failed: …` / `Plan defect at Step [N]: …`, any failed / non-convergent validation, any `/fX` gate failure, any inconsistent state — surface verbatim, no retry, no remediation.
5. **Pre-archive guard.** Before the autonomous `/f6` squash-merge + branch delete, re-confirm `/f6`'s own pre-merge guards are evaluated, not bypassed.

## Recommended models

- Driver (this command): Balanced (Sonnet) — sequences phases, dispatches sub-agents, inspects reports, halts/pauses. The heavy per-phase reasoning lives in the dispatched agents at their own tiers (proposal-validation primary Reasoning; `plan-executor` Cheap; `validation-checker` Cheap; `/f4` / `/f6` Cheap).

See [`reference/model_selection.md`](../../../../../reference/model_selection.md).

## Exit criteria

The proposal walked from its derived start phase through `/f6-archive-proposal` (archived + squash-merged), **or** the run paused on a structured open question (resumed in-place) / halted on a non-clean outcome with the verbatim report surfaced. Every phase ran as an independent `Agent` in the shared working tree (no worktree isolation); exactly one nesting level throughout; `/f5-audit-framework` **was** run as Phase 6 of the chain (between `/f4` and `/f6`, via the driver-lifted `audit-checker` topology), its auto-fixes + this-run f0 captures folding into the `/f6` squash commit. Master / self-host only — a child invocation halts at Step 0.

---
Created 2026-06-14 — by /f3-implement-update for proposals/23-f-all-orchestrate-framework-update.md (the /f-all framework-update meta-driver, Phase 4 of the framework-update flow).

<!-- Managed by Shamt — do not edit. Regenerate from shamt-core/host/templates/claude/skills/f-all/SKILL.md. -->
