---
description: Driver — walk a single story through every remaining Engineer-flow phase (e1 → e2 → optional e3+e3b → e4 → e5 → e6 → e7 → e8) by dispatching one independent agent per phase, deriving the start phase from on-disk artifacts, pausing on each interactive gate or structured open question via AskUserQuestion, and halting on any failure it cannot resolve
---

# /e-all

**Purpose:** Drive a single story through every **remaining** Engineer-flow phase end-to-end, so the operator does not have to babysit the `/clear` + per-phase-command pipeline by hand. `/e-all {slug}` is a **stateless, disk-derived dispatcher** of the canonical Engineer-phase commands — it holds no state of its own (every decision is re-derived from on-disk artifacts) and every underlying `/eX` command remains independently runnable. It is a convenience layer over the per-phase commands, **not** a replacement for them, which is the line that keeps it compatible with Principle 1's "no single mega-orchestrator / no state file" clauses (see the authoritative reconciliation in `CLAUDE.md` §"How changes land").

**Child-facing — no master guard.** Unlike `/f-all`, `/e-all` runs **wherever the Engineer flow runs** — every child project, and master self-host. The Engineer flow is the story-execution flow every child runs, so there is **no** master-only Step-0 child halt. (This is the single biggest divergence from the `/f-all` template `/e-all` mirrors; a contributor adapting `/f-all` must **not** copy its master-only guard.)

The driver runs in the main agent loop and dispatches **one independent `Agent` sub-agent per phase, in order**, in the **shared working tree** (never with worktree isolation — `/e4`'s build edits must be visible to `/e5` test, `/e6` review, `/e7` polish, and `/e8` commit). After each phase agent returns, the driver inspects its report and either **advances** (clean exit), **pauses** (the phase surfaced an interactive gate or a structured open question — lift it to the user via `AskUserQuestion`, feed the answer back, re-dispatch the same phase against its on-disk artifact), or **halts** (any other non-clean outcome — failure, ambiguity it cannot frame as a user question, inconsistent state — surfaced verbatim, no retry).

`/e-all` is **gate-heavy.** The Engineer flow has genuine interactive judgment gates — `/e2` Gate 2a design dialog and Gate 2b approval, `/e3` Gate 3 approval, `/e7` polish dialog, `/e8`'s explicit finalize confirmation — where `/f-all`'s chain mostly auto-advanced. So `/e-all` **pauses far more often** than `/f-all`: each gate is a structured pause surfaced to the user and re-dispatched on the answer. The driver never makes a design call itself; it only sequences phases and relays the gate.

**Recommended model:** Balanced (Sonnet) — the driver sequences phases, dispatches sub-agents, inspects results, and halts/pauses; the heavy per-phase reasoning lives in the dispatched agents at their own tiers (a spec/plan-validation primary at Reasoning, `plan-executor` at Cheap, `user-simulator` at Balanced, `test-executor` / `validation-checker` at Cheap, the story-review primary at Balanced). See [`reference/model_selection.md`](../../../../reference/model_selection.md).

---

## Usage

```
/e-all {slug}
```

## Arguments

- `{slug}` (required) — story slug. Resolves to the story folder under `stories/{slug}/` (child: `.shamt-core/stories/{slug}/` — the Shamt work root), exactly as `/e1-start-story` and the rest of the Engineer-flow commands resolve it.

## Prerequisites

- `stories/{slug}/` resolves (the story exists). The driver's first phase may be `/e1-start-story` (intake), which produces `ticket.md` — but the folder/slug must already resolve. If nothing resolves for the slug, halt and direct the user to `/ps0-draft` / `/ps1-define` (PO flow) or `/e1-start-story {slug}`.
- `ticket.md` does **not** already carry `**Status: Done**`. If it does, the story was already finalized — halt and report (the driver would otherwise re-derive a start past `/e8` and have nothing to do).

---

## The chain

`/e-all` runs the remaining Engineer-flow phases in order. The README §"Engineer flow (Part 1 — story-level execution)" Phase numbers are used here:

```text
Phase 1  /e1-start-story                              [always, if ticket not yet captured]
Phase 2  /e2-define-spec                              [always]
Phase 3  /e3-plan-implementation + validate           [Standard path only]
         /e3b-write-testing-plan + validate           [Standard path AND TESTING_STANDARDS declares suites]
Phase 4  /e4-execute-plan                             [always]
Phase 5  /e5-execute-tests                            [always — required]
Phase 6  /e6-review-changes                           [always]
Phase 7  /e7-resolve-feedback                          [always]
Phase 8  /e8-finalize-story                            [always — terminal, user-gated commit]
```

**Quick-path stories skip `/e3` / `/e3b`** — the build (`/e4`) runs the spec's Build Checklist directly. The spec's `Path:` header (Quick vs Standard), read off `spec.md`, selects this for the rest of the chain.

**`/e3b` runs only when TESTING_STANDARDS declares automated suites** (and the path is Standard). The driver reads `.shamt-core/project-specific-files/TESTING_STANDARDS.md` to know whether `/e3b` and the automated-suite half of `/e5` apply. These are **mechanical disk/config reads, not user questions.** If TESTING_STANDARDS.md declares suites but is itself missing/incomplete, the driver does **not** pre-flight-fail on it — the case surfaces at Phase 5, where the dispatched `user-simulator` returns its `Cannot run: TESTING_STANDARDS.md missing/incomplete — complete it first.` exit, which the driver classifies as a **halt** (the user completes/fixes the file and re-invokes).

**`/e5b-write-manual-testing-plan` is excluded from the chain** — it is optional, on-demand, and orthogonal to the required Phase-5 agent-as-user run, mirroring `/f5`'s exclusion from `/f-all`. The user runs it by hand when a human walkthrough is wanted.

---

## Step 1 — Derive the starting phase from on-disk artifacts (once, at launch)

`/e-all` is slug-resumable because it derives its **starting** phase entirely from artifact presence (and, where no artifact exists, a disk/working-tree **gate**), **once, at launch** — that single derivation (not a per-phase re-scan) is the resumability guarantee: a fresh invocation after the driver was interrupted picks up at the right phase. Thereafter, within the same run, the driver advances through subsequent phases on each phase agent's returned report (Step 3), **not** by re-deriving from disk after every phase. There is no mode to detect — always derive the start, then run forward on reports.

Phase resolution is at **phase-boundary granularity** — the driver dispatches each phase as a sub-agent and blocks until it returns, so there is no mid-phase resume to reconstruct. Like `/f-all` — which resolves its `/f3` boundary via a working-tree diff-coverage gate and its `/f4` boundary via a `regen --check` zero-drift gate rather than a dedicated artifact — `/e-all` uses a **gate** for any phase that records no durable artifact (most notably `/e4`). The discriminators, checked in order under `stories/{slug}/`:

| Signal on disk | Means | Start at |
|----------------|-------|----------|
| `ticket.md` **absent** | Intake not done | Phase 1 (`/e1`) |
| `ticket.md` present; `spec.md` **not** footed (or, on Standard, `context.md` not footed) | Spec not done | Phase 2 (`/e2`) |
| `spec.md` footed (its `Path:` header selects Quick vs Standard for the rest of the chain); **Standard** path and `implementation_plan.md` **not** footed | Plan not done | Phase 3 (`/e3`) |
| Standard, `implementation_plan.md` footed; TESTING_STANDARDS declares suites and the testing plan (`testing_plan.md` footed / spec inline checklist validated) **not** yet present | Testing plan not done | Phase 3 (`/e3b`) |
| Plan done (Standard: `implementation_plan.md` footed; Quick: spec footed) and `/e3b` done/non-applicable; **build gate** does **not** walk clean | Build not done | Phase 4 (`/e4`) |
| Build gate walks clean; `agent_test_session.md` verdict **not** `Session PASS` (or, when suites exist, `testing_plan.md` Results Log not all PASS) | Test not done | Phase 5 (`/e5`) |
| Tests pass; `feedback/review_vN.md` **not** footed (and no Quick-path `## Post-Build Review` block on the footed spec) | Review not done | Phase 6 (`/e6`) |
| Review done; `feedback/addressed_feedback.md` **not** dispositioned | Polish not done | Phase 7 (`/e7`) |
| Polish done; `ticket.md` does **not** carry `**Status: Done**` | Finalize not done | Phase 8 (`/e8`) |
| `ticket.md` carries `**Status: Done**` | Finalized | Nothing — report already-complete and exit |

**`/e4` done is gate-derived, not artifact-derived.** `/e4-execute-plan` writes **no** "build complete" marker — its output is working-tree edits + commits per the plan's convention. So the `/e4` discriminator is the **build gate**: the plan's `## Verification` section (Standard) or the spec's Build Checklist (Quick) walks clean against the working tree, mirroring `/f-all`'s diff-coverage gate.

**Strict-halt on an inconsistent state.** A working tree that matches none of these cleanly — a partially-applied phase left by an interrupted sub-agent, e.g. a build gate that would **not** walk clean while later artifacts already exist — is an inconsistent state the driver **halts** on rather than guessing. Surface what was found and direct the user to finish or reset that phase by hand with the per-phase command. This mirrors the strict-halt rule (Step 3): the driver never re-dispatches a phase whose exit gate it cannot confirm from disk.

**Unrelated `.shamt-core/proposals/` additions are NOT an inconsistent state.** New files under `.shamt-core/proposals/` (from a parallel session — or from this story's own `/e7`, which writes a generalizable root cause there) that the slug derivation does not map to *this* story's phase signals are **expected and accepted** parallel-session work — Shamt is multi-session and parallel by design (Principle 3 — disk-authoritative cross-session work). They are **never** an "inconsistent state" the driver halts on, and the driver **never** reverts, renames-back, or deletes them. In particular, because `/e7-resolve-feedback` (Phase 7) *actively writes* to `.shamt-core/proposals/`, the driver must not revert *other* proposals present alongside the one this story's `/e7` adds. The strict-halt above fires only on a partially-applied phase of *this* story whose exit gate cannot be confirmed — not on unrelated tree state. This is the driver-level analog of the live `/f3`/`/f6` accept-and-fold rule (`/f3-implement-update.md:34`, `/f6-archive-proposal.md`).

State the derived starting phase in one line before dispatching anything (e.g. `Starting at Phase 4 — spec footed (Standard), plan footed, build gate not yet clean.`).

---

## Step 2 — Dispatch topology (exactly one nesting level)

A sub-agent cannot spawn another sub-agent, yet several Engineer-flow phases need an inner persona. This is the **same** constraint `reference/batch_validation_handoff.md` already solves, and `/e-all` adopts its solution verbatim — keeping the topology at **exactly one nesting level**: driver → phase agent, and separately driver → inner persona. `/e-all` spans **more** inner personas than `/f-all` (`validation-checker`, `plan-executor`, `user-simulator`, `test-executor`), each lifted up to the driver under the same one-nesting-level rule.

There are two kinds of phase:

- **Self-contained phases — invoke the `/eX` command directly in their own sub-agent.** `/e1-start-story` and `/e8-finalize-story` (and any Quick-path phase that spawns nothing). Dispatch one `Agent` whose prompt tells it to run `/eX {slug}` to completion in the shared working tree and report its terminal message.

- **Phases that internally need a sub-agent — run the command's inline steps and halt at the hand-off point; the driver then dispatches the inner persona itself.** `/e2` / `/e3` / `/e3b` / `/e6` validation → `validation-checker`; `/e4` build hand-off → `plan-executor`; `/e5` → `user-simulator` (+ `test-executor` when suites exist). The per-phase agent is driven by the phase command's **inline instructions** and stops at the hand-off point; the **driver** then dispatches the canonical inner persona against the on-disk artifacts, exactly as the batch-validation orchestrator lifts the checker-spawn up to itself.

**The infeasible approach, ruled out:** naively dispatching a sub-agent to *invoke* `/eX` and expecting it to halt is wrong — invoking `/e2` / `/e3` / `/e3b` / `/e6` auto-proceeds to spawn `validation-checker`, invoking `/e4` auto-hands-off to `plan-executor`, invoking `/e5` auto-spawns `user-simulator` / `test-executor` — each a forbidden second nesting level. The per-phase agent for those phases must run the **inline steps**, never the `/eX` command.

**No persona edit is required.** `/e-all` reuses `validation-checker`, `plan-executor`, `user-simulator`, and `test-executor` unchanged — the driver branches off their existing verbatim report contracts (Step 3), so the change set adds no new persona.

**Accept-and-fold — every dispatch prompt carries it (load-bearing).** A dispatched phase agent runs in a fresh context and reads **only** what its dispatch prompt carries — so the accept-and-fold invariant has to live *in the dispatch prompt*, not just in this command's Notes. **Every** dispatched phase agent's prompt (every kind above — self-contained `/eX`, inline-instruction primary, `plan-executor`, `validation-checker`, `user-simulator`, `test-executor`) must carry this clause verbatim:

```text
Unrelated in-tree work already present on entry is expected and accepted — never
revert, rename-back, or delete it. You may revert only your own this-dispatch
off-task edits.
```

The disambiguator is **provenance + timing**, never "is this proposal/artifact unfamiliar to me": work *already present in the tree when this agent started* (or authored by another session) is accepted and folds into the landing; only an edit *this agent itself made this dispatch, off-task* may be reverted (the agent's own scope creep — the existing own-stray-edit guardrail stands). This is the same two-case split `/f3-implement-update.md:125` encodes (unrelated/parallel state → never revert; the agent's own genuinely-missing change → in-place amendment). This matters most for `.shamt-core/proposals/`: because `/e7-resolve-feedback` writes a generalizable root cause there, a later phase agent (or the driver) must not "tidy" *other* proposals sitting alongside the one `/e7` adds.

### Note — the Engineer flow's architect/builder split spans two phases

Unlike `/f-all`'s `/f3` (which both plans and hands off within one phase), the Engineer flow splits the architect and builder across **two** phases: the architect plans at `/e3` and the cheap-tier builder executes at `/e4`. So the `plan-executor` dispatch is **`/e4`'s**, not `/e3`'s. `/e3` is a validation phase (`validation-checker`); `/e4` is the build hand-off (`plan-executor`).

### Phase-by-phase dispatch

**Phase 1 — `/e1-start-story`.** Self-contained — dispatch one `Agent` to run `/e1-start-story {slug}` to completion (it produces the validated `ticket.md`). It may surface an intake open question; route per Step 3.

**Phase 2 — `/e2-define-spec`.** Inline + driver-lifted validation + gate. Dispatch a primary sub-agent to run `/e2`'s **inline** steps (research → Gate 2a design dialog → spec/context drafting → halt at the validation hand-off **without** spawning `validation-checker` and **without** invoking the `/e2` command). The driver then dispatches `validation-checker` (Cheap) itself on `spec.md` (and `context.md` on Standard); on any checker finding, re-dispatch a fresh primary, then re-run the checker, until `CONFIRMED: Zero issues found after adversarial review.` Gate 2a (design dialog, 1–3 options) and Gate 2b (approval) are **pauses** — see Step 3's sentinel mechanics.

**Phase 3 — `/e3-plan-implementation` + `/e3b-write-testing-plan`** *(Standard path only; `/e3b` only when TESTING_STANDARDS declares suites)*:
1. **`/e3` plan** — run `/e3`'s **inline** steps in the phase agent up to the validation hand-off; the driver lifts `validation-checker` on `implementation_plan.md`, re-converging to `CONFIRMED`. Gate 3 (plan approval) is a **pause**.
2. **`/e3b` testing plan** — same inline + driver-lifted-`validation-checker` topology on `testing_plan.md` (or the spec's inline checklist). Skipped when TESTING_STANDARDS declares no suites.

**Phase 4 — `/e4-execute-plan`.** Build hand-off. Run `/e4`'s **inline** steps in the phase agent up to the `plan-executor` hand-off (Standard path), then the **driver** dispatches `plan-executor` (Cheap) against `implementation_plan.md`. On a Quick-path story, `/e4` executes the spec's Build Checklist directly — dispatch it as a self-contained phase that spawns nothing. Branch off `plan-executor`'s report per Step 3.

**Phase 5 — `/e5-execute-tests`.** Run `/e5`'s **inline** steps in the phase agent up to the hand-off, then the **driver** dispatches `user-simulator` (Balanced — the required agent-as-user run) and, when TESTING_STANDARDS declares suites, `test-executor` (Cheap — the automated suites) against the testing artifacts in the shared tree. Branch off each persona's report per Step 3 — `Session PASS` / `All steps passed. Results logged.` advance; failures halt; an ambiguous exit pauses.

**Phase 6 — `/e6-review-changes`.** Story mode. Run `/e6`'s **inline** steps in the phase agent (the 16-category sweep against the story's own diff, writing `feedback/review_vN.md`) up to the validation hand-off; the driver lifts `validation-checker` on the review, re-converging to `CONFIRMED`. (`/e-all` always runs `/e6` in **story mode** against the story's own diff — the `--branch=` / `--pr=` formal modes are not part of the per-story chain.)

**Phase 7 — `/e7-resolve-feedback`.** Run `/e7`'s **inline** steps in the phase agent: apply each comment from `feedback/review_vN.md`, log dispositions in `feedback/addressed_feedback.md`, perform any flagged ARCHITECTURE / CODING_STANDARDS / TESTING_STANDARDS updates, and route generalizable root causes to `.shamt-core/proposals/`. The `/e7` polish dialog is a **pause**.

**Phase 8 — `/e8-finalize-story`.** Self-contained — dispatch one `Agent` to run `/e8-finalize-story {slug}`. **Before this (irreversible) commit + tracker-close**, the driver re-confirms `/e8`'s **own three guards** are evaluated, not bypassed: prior phases complete; scoped clean-tree commit; **explicit user confirmation**. `/e8`'s built-in explicit-confirm guard means the irreversible step is **always user-gated** — the driver surfaces that confirm via `AskUserQuestion` (a Step-3 pause) rather than performing it unattended. This is **softer** than `/f-all`'s autonomous squash-merge: the terminal step here is never autonomous.

---

## Step 3 — Inspect each phase's report: advance, pause, or halt

The driver branches on the **dispatched agent's own already-shipped report contract**, never on ad-hoc prose-guessing. The pause-and-resume cases are the Engineer flow's **interactive gates** plus any structured open question a phase surfaces; every other non-clean outcome halts. No persona edit is required — every contract below already ships.

**Advance** (dispatch the next phase):
- A clean validation exit (primary clean + `CONFIRMED: Zero issues found after adversarial review.` from `validation-checker`, footer stamped) — for `/e2` / `/e3` / `/e3b` / `/e6`.
- `plan-executor` → `All steps completed. Verification passed.` (Phase 4).
- `test-executor` → `All steps passed. Results logged.`; `user-simulator` → `Session PASS` (Phase 5).
- A self-contained phase agent reporting its `/eX` command completed at its documented exit (`/e1` ticket captured; `/e8` committed + tracker-closed).

**Pause** (lift the question to the user via `AskUserQuestion`, feed the answer back, **re-dispatch** the same phase with the answer):
- An **interactive gate** — Gate 2a design dialog (`/e2`), Gate 2b approval (`/e2`), Gate 3 plan approval (`/e3`), `/e7` polish dialog, `/e8` finalize confirmation. Gate 2a's 1–3 design options and the 2b / 3 / `/e8` approvals each map cleanly onto **one** `AskUserQuestion` round-trip; **multi-round** design dialog is handled by **successive re-dispatches off the now-updated on-disk artifact**.
- `plan-executor` → `Step [N] is ambiguous: …` (its contract states what would disambiguate — surface that as the question).
- `test-executor` → `Step [N] is ambiguous: …` — a structured open question lifted to the user as a pause (mirroring `plan-executor`'s identically-named ambiguous exit, and **distinct from a test failure** that halts). The driver surfaces it via `AskUserQuestion` and re-dispatches Phase 5 against the on-disk testing artifact on the answer, exactly as the gate-pause cases do.
- An inline-instruction primary surfacing an unresolved Principle-2 open question.

**Sentinel contract (two row-authoring details, both inherited from `/f-all`'s sentinel mechanics — not a persona edit):**

1. The gate-bearing phases (`/e2`, `/e3`, `/e7`) run as **inline-instruction** sub-agents that **cannot** prompt the user themselves (only a top-level invocation of `/eX` would). So the driver's **dispatch prompt** for every inline-instruction phase must instruct that agent to **return** any gate prompt / unresolved open question to the driver rather than prompting the user itself, using a **verbatim sentinel** the driver matches — mirroring `plan-executor`'s `Step [N] is ambiguous: …` shape:

   ```text
   Open question: {the question} | To resolve: {what input is needed}
   ```

   The driver matches that `Open question: … | To resolve: …` line to trigger the pause; any other terminal text routes to the relevant advance / halt branch. (`validation-checker` is untouched — it still only runs the adversarial re-read the driver lifts.)

2. Because each re-dispatch starts a **fresh** sub-agent context, the dispatch prompt must **point the re-dispatched agent at the on-disk artifact** (`spec.md` / `implementation_plan.md` / `feedback/review_vN.md`) so it resumes from saved state rather than lost conversation — the same disk-derived continuity the whole driver relies on.

3. **Accept-and-fold travels in the same dispatch prompt (load-bearing).** Every phase agent's dispatch prompt also carries the accept-and-fold clause from Step 2 verbatim — *unrelated in-tree work already present on entry is expected and accepted; never revert/rename-back/delete it; you may revert only your own this-dispatch off-task edits.* This is the channel that actually reaches each inline phase agent (it never reads this command's Notes), so the clause is load-bearing here, not optional documentation. A phase agent that returns a report claiming it reverted/removed unrelated `.shamt-core/proposals/` work has violated the invariant — the driver does **not** accept such a revert; per Step 1 unrelated `.shamt-core/proposals/` additions are never an inconsistent state, and `/e7`'s own proposal-write must not cause *other* proposals to be reverted.

**Halt** (surface the report verbatim, no retry, no remediation — the user's next move is to fix and re-run the per-phase command):
- `plan-executor` → `Step [N] failed: …` or `Plan defect at Step [N]: …`.
- **Any Phase-5 *failure* exit** (Q-testloop → strict halt): `test-executor` → `Step [N] failed: Story bug — …` / `Test bug — …` / `Spec gap — …` / `Plan defect at Step [N]: …` / `Environment blocked at Step [N]: …`; `user-simulator` → `Session BLOCKED: …` or `Cannot run: TESTING_STANDARDS.md missing/incomplete — complete it first.` The Engineer flow routes a Phase-5 failure to `/e7` for a root-cause loop, but **`/e-all` does NOT drive that loop unattended** — it halts and surfaces the executor's verbatim report; resuming via `/e7` (or fixing the build / plan / TESTING_STANDARDS) is the user's next move. The `/e5` → `/e7` → re-`/e5` loop stays a **manual** operation; **do not build an auto-fix loop**. (For `Environment blocked` specifically this is a **deliberate divergence** from the per-phase `/e5-execute-tests`, which runs a one-question "which infrastructure piece is missing?" dialog and re-invokes `/e5` after the user resolves it externally; `/e-all` instead **halts** under the same strict-halt / no-autonomous-loop safety rule — the divergence is intentional, not an oversight.)
- Any failed or non-convergent validation (a `validation-checker` that never reaches `CONFIRMED`, a primary that cannot reach a clean round).
- A self-contained phase agent reporting its `/eX` command halted (`/e1` intake blocked; `/e8` a guard failed).
- Any inconsistent-state detection (Step 1) or any terminal text the driver cannot map to a contract above.

**The driver never retries** (not even a "transient" failure), never does design work, and never re-dispatches a phase whose exit gate it cannot confirm. The driver never autonomously edits code to chase a green. Remediation past a halt is always the user's next move. This strict-halt rule is the load-bearing runaway-safety property; combined with the per-phase exit gates and the user-gated `/e8` confirm, it bounds the autonomous run.

---

## Step 4 — Exit

When `/e8` reports the story committed + tracker-closed, state the exit clearly:

```text
/e-all complete for {slug}. Phases run: {list, e.g. e2 → e3 → e4 → e5 → e6 → e7 → e8}.
The story is committed and its work item is marked done.
```

If the run **paused**, the pause is not an exit — it is one round-trip through `AskUserQuestion`; the driver resumes automatically after the answer. If the run **halted**, report the halting phase's verbatim message and the per-phase command to resume from; do not present the run as complete.

## Exit criteria

- The story walked from its derived start phase through `/e8-finalize-story` (committed + tracker-closed), **or** the run paused on an interactive gate / structured open question (resumed in-place) / halted on a non-clean outcome with the verbatim report surfaced.
- Every phase ran as an independent `Agent` in the **shared working tree** (no worktree isolation).
- Exactly one nesting level throughout (driver → phase agent; driver → inner persona); no sub-agent invoked an `/eX` command that would auto-spawn a second-level sub-agent.
- The terminal `/e8` commit + tracker-close ran behind `/e8`'s own three guards (prior phases complete; scoped clean tree; explicit user confirmation surfaced via `AskUserQuestion`), never bypassed.

## Notes

- **Stateless / disk-derived — honors Principle 1.** `/e-all` holds no state of its own: it derives its start phase from on-disk artifacts (Step 1) and advances on each phase agent's report. Every `/eX` it dispatches remains independently runnable by a fresh agent. It is a dispatcher of the canonical phase commands, not a state-holding monolith that reimplements them — the carve-out a future `/f5-audit-framework` D9 (contradiction) sweep consults lives in `CLAUDE.md` §"How changes land", beside `/f-all`'s.
- **Child-facing — no master guard.** `/e-all` runs wherever the Engineer flow runs (every child project, and master self-host); there is **no** Step-0 child halt. This is the single biggest divergence from the `/f-all` template `/e-all` mirrors — do not copy `/f-all`'s master-only guard.
- **Shared working tree, never worktree isolation.** The chain depends on cross-phase working-tree state: `/e4`'s build edits must reach `/e5` (test), `/e6` (review), `/e7` (polish), and `/e8` (commit). Dispatching any phase with `isolation: worktree` would hide those edits from later phases and break the chain.
- **One nesting level (per `reference/batch_validation_handoff.md`).** Phases that internally need a sub-agent run inline steps and halt at the hand-off; the driver lifts the `validation-checker` / `plan-executor` / `user-simulator` / `test-executor` spawn up to itself. Dispatching a sub-agent to *run the `/eX` command* and expecting it to halt is the infeasible reading and is explicitly ruled out.
- **Gate-heavy — pauses far more than `/f-all`.** The Engineer flow's many interactive gates mean `/e-all` pauses often. Each gate is a structured pause surfaced to the user via `AskUserQuestion` and re-dispatched on the answer — the driver never makes a design call itself, it only sequences and relays.
- **Strict halt on test failure (no autonomous `/e7` loop).** On any Phase-5 *failure* exit the driver halts and surfaces the verbatim report; the `/e5` → `/e7` → re-`/e5` loop stays a manual operation. The lone Phase-5 *ambiguous* exit is a user-gated pause, not an autonomous retry. The driver never autonomously edits code to chase a green.
- **Terminal `/e8` is user-gated.** `/e-all` ends at `/e8-finalize-story`, whose own explicit-confirm guard means the irreversible commit + tracker-close is always user-gated — surfaced via `AskUserQuestion`, with `/e8`'s other two guards (prior phases complete; scoped clean tree) re-confirmed. Strictly safer than `/f-all`'s autonomous squash-merge.
- **Never revert parallel work.** Unrelated in-tree work — new `.shamt-core/proposals/` files from a parallel session, **or** the *other* proposals sitting alongside the one this story's `/e7-resolve-feedback` writes — is expected and accepted: it folds into the landing and is **never** reverted, renamed-back, or deleted by the driver or any phase agent it dispatches. This is the driver-level expression of the live `/f3`/`/f6` accept-and-fold rule (`/f3-implement-update.md:34` and `:125`, `/f6-archive-proposal.md`) and the now-live cross-cutting **Principle 3 — disk-authoritative cross-session work** (`CLAUDE.md` / the rules file). The disambiguator is provenance + timing — already-present-on-entry / another session = accepted; this-dispatch own off-task edit = revertable — and the **load-bearing** carrier is the Step 2 / Step 3 dispatch-prompt clause every phase agent reads, not this Notes bullet (a dispatched agent never reads Notes). The rule is self-standing — anchored on the live `/f3`/`/f6` rules — so it holds regardless of Principle 3's landing order.
- **Fresh-agent runnable.** Story folder artifacts + working-tree state are sufficient inputs; the start phase is re-derived from disk. No conversation history required.

---
Created 2026-06-15 — by /f3-implement-update for proposals/27-e-all-orchestrate-engineer-flow.md (the /e-all Engineer-flow story driver, Phase 4 of the framework-update flow).

<!-- Managed by Shamt — do not edit. Regenerate from shamt-core/host/templates/claude/commands/e-all.md. -->
