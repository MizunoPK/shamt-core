---
description: Meta-driver (master / self-host only) — walk a validated proposal through every remaining framework-update phase (validate → optional f2+plan-validate → f3 → f4 → f6) by dispatching one independent agent per phase, deriving the start phase from on-disk artifacts, and pausing only on a structured open question or halting on any other non-clean outcome
---

# /f-all

**Purpose:** Drive a single proposal through every **remaining** framework-update phase end-to-end, so the operator does not have to babysit the `/clear` + per-phase-command pipeline by hand. `/f-all {slug}` is a **stateless, disk-derived dispatcher** of the canonical phase commands — it holds no state of its own (every decision is re-derived from on-disk artifacts) and every underlying `/fX` command remains independently runnable. It is a convenience layer over the per-phase commands, **not** a replacement for them, which is the line that keeps it compatible with Principle 1's "no single mega-orchestrator / no state file" clauses (see the authoritative reconciliation in `CLAUDE.md` §"How changes land"). **Master / self-host only** — invoked in a child it halts and redirects to the per-phase commands (the numbered / branch / squash-merge flow is inherently master-side), mirroring `/f5-audit-framework`'s child behavior.

The driver runs in the main agent loop and dispatches **one independent `Agent` sub-agent per phase, in order**, in the **shared working tree** (never with worktree isolation — `/f3`'s `proposal/{NN}-{slug}` branch and canonical edits must be visible to `/f4` and `/f6`). After each phase agent returns, the driver inspects its report and either **advances** (clean exit), **pauses** (the phase surfaced a structured open question — lift it to the user via `AskUserQuestion`, feed the answer back, re-dispatch), or **halts** (any other non-clean outcome — failure, drift, ambiguity it cannot frame as a user question, non-convergence — surfaced verbatim, no retry).

**Recommended model:** Balanced (Sonnet) — the driver sequences phases, dispatches sub-agents, inspects results, and halts/pauses; the heavy per-phase reasoning lives in the dispatched agents at their own tiers (a proposal-validation primary at Reasoning, `plan-executor` at Cheap, `validation-checker` / inline-validation primaries at their own tiers, `/f4` / `/f6` at Cheap). See [`reference/model_selection.md`](../../../../reference/model_selection.md).

---

## Usage

```
/f-all {slug}
```

## Arguments

- `{slug}` (required) — proposal slug (bare descriptive slug or numbered stem `{NN}-{slug}`). Resolves the proposal exact-then-glob — `proposals/{slug}.md`, then `proposals/*-{slug}.md` (master-side proposals carry a `{NN}-` prefix; matches at most one, halt on multiple) — exactly as `/f3-implement-update` and `/f6-archive-proposal` resolve it.

## Prerequisites

- **Master / self-host target.** The chain creates a branch, applies canonical edits, runs regen, and squash-merges — all master-side. A child invocation halts at Step 0 (see below).
- `proposals/{slug}.md` exists. (It need not yet carry a validation footer — the driver's first phase is validation, which produces it. If the proposal is missing entirely, halt and direct the user to `/f1-propose-update {slug}`.)
- `proposals/archive/{slug}.md` (or `archive/*-{slug}.md`) does **not** exist. If it does, the proposal was already landed — halt and report (the driver would otherwise re-derive a start past `/f6` and have nothing to do).

---

## The chain

`/f-all` runs the remaining framework-update phases in order. The README §"Framework update flow (Part 3 — master-side)" Phase numbers are used here:

```text
Phase 2  validate(proposal)                                    [always]
Phase 3  /f2-plan-update-implementation  +  validate(plan)     [only when the proposal carries the >10-file-ops note]
Phase 4  /f3-implement-update                                  [always]
Phase 5  /f4-regen-framework                                   [always]
Phase 7  /f6-archive-proposal                                  [always]
```

**`/f5-audit-framework` (Phase 6) is deliberately excluded.** Its sub-agent fan-out and f0-draft *creation* are surprising inside an unattended archive run; run it separately (`/f5-audit-framework`) when wanted, before invoking `/f-all` or after it lands.

**Conditional Phase 3.** `/f-all` runs `/f2` + plan-validation **only when** the proposal carries the note `/f1-propose-update` stamps once the Proposed Changes table exceeds 10 rows. The greppable signal is the stable prefix:

```text
Phase 3 required — file count {N} > 10.
```

Grep the proposal for that `Phase 3 required — file count` prefix. Present → Phase 3 runs; absent → skip straight from validation to `/f3`.

---

## Step 0 — Confirm target context (master / self-host only)

Resolve the target via the **self-host detection rule** the rest of the framework-update flow uses: the target is the shamt-core self-host iff a top-level `proposals/` directory is present (corroborated by canonical sources at the root — `host/templates/claude/`, `templates/`, `scripts/regenerate-framework.sh`); it is a child project iff `.shamt-core/` carries the imported copy.

- **Master / self-host** → proceed to Step 1.
- **Child project** → **halt immediately.** Do not dispatch any phase. Print the redirect:

  ```text
  /f-all does not run in a child project. The framework-update phases it drives
  (branch creation, canonical edits, regen, squash-merge) are master-side only.
  To run a framework change from this project, use the per-phase commands by hand:
    /f1-propose-update {slug}        — author / edit the proposal
    /sync-submit-proposal {slug}     — send it upstream to master
  Master is where the numbered / branch / merge flow runs.
  ```

This is the single child guard; the rest of the body assumes a master / self-host target.

---

## Step 1 — Derive the starting phase from on-disk artifacts (once, at launch)

`/f-all` is slug-resumable because it derives its **starting** phase entirely from artifact presence, **once, at launch** — that single derivation (not a per-phase re-scan) is the resumability guarantee: a fresh invocation after the driver was interrupted picks up at the right phase. Thereafter, within the same run, the driver advances through subsequent phases on each phase agent's returned report (Step 3), **not** by re-deriving from disk after every phase. There is no mode to detect — always derive the start, then run forward on reports.

Phase resolution is at **phase-boundary granularity** — the driver dispatches each phase as a sub-agent and blocks until it returns, so there is no mid-phase resume to reconstruct. The discriminators, checked in order:

| Signal on disk | Means | Start at |
|----------------|-------|----------|
| Proposal carries **no** validation footer | Validation not done | Phase 2 (validate) |
| Proposal footed; carries the `Phase 3 required — file count` note **and** no `{slug}_PLAN.md` (or the plan is present but unfooted) | `/f2` / plan-validation outstanding | Phase 3 |
| Proposal footed; (no Phase-3 note, **or** `{slug}_PLAN.md` present and footed); `proposal/{NN}-{slug}` branch does **not** exist | Ready to implement | Phase 4 (`/f3`) |
| Branch exists **and** `/f3`'s diff-coverage gate passes against the working tree (every Proposed Changes row present as an edit — uncommitted, since `/f3` does not commit) | `/f3` done | Phase 5 (`/f4`) |
| `regenerate-framework.sh --check` reports zero drift (and branch exists) | `/f4` done | Phase 7 (`/f6`) |
| Proposal moved under `proposals/archive/` | `/f6` done | Nothing — report already-complete and exit |

**Strict-halt on an inconsistent state.** A working tree that matches none of these cleanly — a partially-applied phase left by an interrupted sub-agent (e.g. the `proposal/{NN}-{slug}` branch exists but `/f3`'s diff-coverage gate would **not** pass, so not every Proposed Changes row is present as an edit) — is an inconsistent state the driver **halts** on rather than guessing. Surface what was found and direct the user to finish or reset that phase by hand with the per-phase command. This mirrors the strict-halt rule (Step 3): the driver never re-dispatches a phase whose exit gate it cannot confirm from disk.

State the derived starting phase in one line before dispatching anything (e.g. `Starting at Phase 4 — proposal validated, no Phase-3 note, no proposal branch yet.`).

---

## Step 2 — Dispatch topology (exactly one nesting level)

A sub-agent cannot spawn another sub-agent, yet `/validate-artifact` (Standard) needs `validation-checker` and `/f3` may hand off to `plan-executor`. This is the **same** constraint `reference/batch_validation_handoff.md` already solves, and `/f-all` adopts its solution verbatim — keeping the topology at **exactly one nesting level**: driver → phase agent, and separately driver → inner persona.

There are two kinds of phase:

- **Self-contained phases — invoke the `/fX` command directly in their own sub-agent.** `/f2-plan-update-implementation` authoring, `/f4-regen-framework`, `/f6-archive-proposal`, and `/f3-implement-update`'s **inline ≤10-ops path** (which spawns nothing). Dispatch one `Agent` whose prompt tells it to run `/fX {slug}` to completion in the shared working tree and report its terminal message.

- **Phases that internally need a sub-agent — run the command's inline steps and halt at the hand-off point; the driver then dispatches the inner persona itself.** Every `/validate-artifact` run (proposal validation; plan validation when `/f2` ran) and `/f3`'s **architect/builder path** (`plan-executor`). The per-phase agent is driven by the phase command's **inline instructions** and stops at the hand-off point; the **driver** then dispatches the canonical inner persona (`validation-checker` / `plan-executor`) against the on-disk artifacts, exactly as the batch-validation orchestrator lifts the checker-spawn up to itself.

**The infeasible approach, ruled out:** naively dispatching a sub-agent to *invoke* `/validate-artifact` or `/f3` and expecting it to halt is wrong — invoking `/validate-artifact` auto-proceeds to Step 7 and spawns its own checker (a forbidden second nesting level); invoking `/f3` auto-hands-off to `plan-executor`. The per-phase agent for those phases must run the **inline steps**, never the `/fX` command.

**No persona edit is required.** `/f-all` reuses `validation-checker` and `plan-executor` unchanged — the driver branches off their existing verbatim report contracts (Step 3), so the change set adds no new persona.

### Phase-by-phase dispatch

**Phase 2 — validate(proposal).** Inline-validation topology. Dispatch a primary validation sub-agent (Reasoning) to run `/validate-artifact`'s Pattern 1 primary loop (Steps 1–6) on `proposals/{slug}.md`, halting at `consecutive_clean = 1` **without** spawning a checker and **without** invoking the `/validate-artifact` command. The driver then dispatches `validation-checker` (Haiku) itself; on any checker finding, re-dispatch a fresh primary, then re-run the checker, until the checker replies `CONFIRMED: Zero issues found after adversarial review.` The primary stamps the footer on clean exit. (Inline-validation open-question handling — the pause sentinel — is in Step 3.)

**Phase 3 — `/f2` + validate(plan)** *(only when the Phase-3 note is present)*:
1. **`/f2` authoring** is self-contained — dispatch one `Agent` to run `/f2-plan-update-implementation {slug}` to completion. It emits either a single `{slug}_PLAN.md` or a phase-decomposed plan (`{slug}_PLAN.md` index + `{slug}_PLAN_phase_*.md` files).
2. **validate(plan)** — detect the plan shape:
   - **Single-file plan** (`{slug}_PLAN.md`, no `_phase_*` files) → run the same inline-validation topology as Phase 2 (driver-lifted `validation-checker`) on `proposals/{slug}_PLAN.md`.
   - **Phase-decomposed plan** (`{slug}_PLAN_phase_*.md` present alongside the index) → this is ≥2 artifacts, so run the **batch-validation handoff** per [`reference/batch_validation_handoff.md`](../../../../reference/batch_validation_handoff.md): the driver acts as the batch orchestrator (it already holds exactly the one-nesting-level role that reference defines), fanning out one primary per artifact and lifting each `validation-checker` spawn up to itself.

**Phase 4 — `/f3-implement-update`.** Path-dependent:
- **Inline ≤10-ops path** (proposal has ≤10 file ops and no `{slug}_PLAN.md`) → self-contained: dispatch one `Agent` to run `/f3-implement-update {slug}` to completion (it creates the `proposal/{NN}-{slug}` branch and applies edits; it spawns nothing).
- **Architect/builder path** (`{slug}_PLAN.md` present and footed) → run `/f3`'s inline steps in the phase agent up to the `plan-executor` hand-off (including creating the branch per the plan's pre-execution checklist), then the **driver** dispatches `plan-executor` (Haiku) against the plan. For a phase-decomposed plan, hand off **one phase file at a time in deploy order** — do not dispatch phase 2 until phase 1 reports `All steps completed. Verification passed.`

**Phase 5 — `/f4-regen-framework`.** Self-contained — dispatch one `Agent` to run `/f4-regen-framework` (propagate canonical edits into `.claude/`, then `--check` for zero drift) in the shared tree.

**Phase 7 — `/f6-archive-proposal`.** Self-contained — dispatch one `Agent` to run `/f6-archive-proposal {slug}`. **Before this autonomous archive** (an irreversible squash-merge + branch delete), the driver re-confirms `/f6`'s own pre-merge guards are evaluated, not bypassed: instruct the dispatched agent to evaluate every pre-merge guard and **halt without merging** on any failure (HEAD on the proposal branch; working tree carries the canonical edits + archive move + `.claude/` regen output; `/f4` has run; the proposal branch is a clean descendant of the base branch). `/f-all` never bypasses these guards.

---

## Step 3 — Inspect each phase's report: advance, pause, or halt

The driver branches on the **dispatched agent's own already-shipped report contract**, never on ad-hoc prose-guessing. There is exactly **one** pause-and-resume case; every other non-clean outcome halts.

**Advance** (dispatch the next phase):
- A clean `/validate-artifact` exit (primary clean + `CONFIRMED: Zero issues found after adversarial review.` from `validation-checker`, footer stamped).
- `plan-executor` → `All steps completed. Verification passed.`
- A self-contained phase agent reporting its `/fX` command completed at its documented exit (e.g. `/f4` zero-drift `--check`; `/f6` archived + squash-merged).

**Pause** (lift the question to the user via `AskUserQuestion`, feed the answer back, **re-dispatch** the same phase with the answer):
- `plan-executor` → `Step [N] is ambiguous: …` (its contract states what would disambiguate — surface that as the question).
- An inline-validation primary surfacing an unresolved Principle-2 open question. **Sentinel contract (a row-1 authoring detail, not a persona edit):** a single-artifact `/validate-artifact` run resolves such questions via its *own* `AskUserQuestion` because it runs at top level; an inline-validation primary dispatched here runs as a sub-agent and **cannot** prompt the user. So the driver's **dispatch prompt** for every inline-validation phase must instruct that agent to **return** any unresolved open question to the driver rather than prompting the user itself, using a **verbatim sentinel** the driver matches — mirroring `plan-executor`'s `Step [N] is ambiguous: …` shape:

  ```text
  Open question: {the question} | To resolve: {what input is needed}
  ```

  The driver matches that `Open question: … | To resolve: …` line to trigger the pause; any other terminal text from the primary routes to the relevant advance / halt branch. (`validation-checker` is untouched — it still only runs the adversarial re-read the driver lifts.)

**Halt** (surface the report verbatim, no retry, no remediation — the user's next move is to fix and re-run the per-phase command):
- `plan-executor` → `Step [N] failed: …` or `Plan defect at Step [N]: …`.
- Any failed or non-convergent validation (a checker that never reaches `CONFIRMED`, a primary that cannot reach a clean round).
- A self-contained phase agent reporting its `/fX` command halted (e.g. `/f3`'s canonical-only or diff-coverage gate failed; `/f4` reported drift it could not resolve; `/f6` a pre-merge guard failed).
- Any inconsistent-state detection (Step 1) or any terminal text the driver cannot map to a contract above.

**The driver never retries** (not even a "transient" failure), never does design work, and never re-dispatches a phase whose exit gate it cannot confirm. Remediation past a halt is always the user's next move. This strict-halt rule is the load-bearing runaway-safety property; combined with the per-phase exit gates it bounds the autonomous run.

---

## Step 4 — Exit

When `/f6` reports the proposal archived + squash-merged, state the exit clearly:

```text
/f-all complete for {slug}. Phases run: {list, e.g. validate → f3 → f4 → f6}.
The proposal is archived under proposals/archive/ and squash-merged to {base-branch}.
```

If the run **paused**, the pause is not an exit — it is one round-trip through `AskUserQuestion`; the driver resumes automatically after the answer. If the run **halted**, report the halting phase's verbatim message and the per-phase command to resume from; do not present the run as complete.

## Exit criteria

- The proposal walked from its derived start phase through `/f6-archive-proposal`, archived and squash-merged, **or** the run paused on a structured open question (resumed in-place) / halted on a non-clean outcome with the verbatim report surfaced.
- Every phase ran as an independent `Agent` in the **shared working tree** (no worktree isolation).
- Exactly one nesting level throughout (driver → phase agent; driver → inner persona); no sub-agent invoked a `/fX` command that would auto-spawn a second-level sub-agent.
- `/f5-audit-framework` was **not** run as part of the chain.

## Notes

- **Stateless / disk-derived — honors Principle 1.** `/f-all` holds no state of its own: it derives its start phase from on-disk artifacts (Step 1) and advances on each phase agent's report. Every `/fX` it dispatches remains independently runnable by a fresh agent. It is a dispatcher of the canonical phase commands, not a state-holding monolith that reimplements them — the carve-out a future `/f5-audit-framework` D9 (contradiction) sweep consults lives in `CLAUDE.md` §"How changes land".
- **Master / self-host only.** The numbered / branch / squash-merge flow is inherently master-side; a child invocation halts at Step 0 and redirects to the per-phase commands. Mirrors `/f5-audit-framework`.
- **Shared working tree, never worktree isolation.** The chain depends on cross-phase git + disk state: `/f3` creates `proposal/{NN}-{slug}` and writes canonical edits that `/f4` (regen) and `/f6` (commit + squash-merge) must see. Dispatching any phase with `isolation: worktree` would hide that branch / those edits from later phases and break the landing.
- **One nesting level (per `reference/batch_validation_handoff.md`).** Phases that internally need a sub-agent run inline steps and halt at the hand-off; the driver lifts the `validation-checker` / `plan-executor` spawn up to itself. Dispatching a sub-agent to *run the `/fX` command* and expecting it to halt is the infeasible reading and is explicitly ruled out.
- **Autonomous archive is accepted (with guards).** `/f-all` ends at `/f6-archive-proposal`, so it performs the irreversible squash-merge + branch delete without a per-step human confirm. Mitigations: the whole chain runs on the `proposal/{NN}-{slug}` branch (recoverable via reflog), the driver halts before archive on any earlier-phase failure, and `/f6`'s own pre-merge guards are re-confirmed (never bypassed).
- **Fresh-agent runnable.** Proposal + companion plan (when present) + working-tree / branch state are sufficient inputs; the start phase is re-derived from disk. No conversation history required.

---
Created 2026-06-14 — by /f3-implement-update for proposals/23-f-all-orchestrate-framework-update.md (the /f-all framework-update meta-driver, Phase 4 of the framework-update flow).

<!-- Managed by Shamt — do not edit. Regenerate from shamt-core/host/templates/claude/commands/f-all.md. -->
