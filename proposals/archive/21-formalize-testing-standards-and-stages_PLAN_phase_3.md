# Implementation Plan — Phase 3: Rules file (required testing + D12)

**Proposal:** `proposals/21-formalize-testing-standards-and-stages.md`
**Index:** `proposals/21-formalize-testing-standards-and-stages_PLAN.md`
**Phase:** 3 of 5 — **Rules file.** Make Phase 5 (Test) a **required** phase in
`templates/SHAMT_RULES.template.md`: insert it into both path maps, fix the phase-count statement,
add the new artifact to Story Artifact Naming, fix the e8 finalize gate, drop the "testing opt-in" config
residual, add the bug→`/e7` rule, and
**extract** the expanded testing prose to `reference/testing.md` (Phase 1) to stay under the D12 budget.
**Depends on:** Phase 1 (`reference/testing.md` must exist as the extraction target).
**Executor:** `plan-executor` (Cheap), BUT the D12 re-measure (Step 8) is a hard gate — halt if over.

## Pre-execution checklist

- [ ] Phase 1 landed: `reference/testing.md` exists with the full testing-model detail.
- [ ] Record the starting size: `wc -m templates/SHAMT_RULES.template.md` (expect ~39,870).

## D12 budget plan (net target ≈ neutral-to-negative)

The exact-string edits below net roughly: **+** path-map Test rows + bug rule + Story-Artifact line
(~+540); **−** the "When automated testing is enabled" → short-summary-+-pointer extraction and the
"Optional post-Build artifact" trim. Step 8 re-measures with `wc -m`; if ≥ 40,000, the fallback trim
(Step 8) extracts the Optional-post-Build paragraph wholesale to `reference/testing.md`.

**`/f3` outcome (amendment):** the original Step 4 summary + the Step 8 fallback together still landed the
file at **40,273** (over budget). The proposal-authorized **compensating trim** was applied: Step 4's
summary was tightened further (terser normative contract; all worked detail in `reference/testing.md`) and
the redundant "between Build and Review" clause dropped (the path maps already position Test there). The
tightened Step 4 block above is the as-landed text. Re-measured: **39,969 < 40,000** (~31 margin).

## Execution status (as-landed at `/f3`, 2026-06-14)

This plan has been **executed**. As with every executed Shamt plan, the Step 1–7b `Locate` strings below
reference the **pre-Phase-3 baseline** of `templates/SHAMT_RULES.template.md` (the state a fresh executor
starts from, before any Phase-3 edit) — they intentionally no longer match the now-edited on-disk file. A
fresh re-run from the clean baseline reproduces the as-landed state. As-landed summary:

- **Step 4** applied the tightened Testing section (the compensating trim); the rules file's
  `### Testing (Phase 5 — required)` section matches Step 4's `Replace with` block verbatim.
- **Step 8 fallback fired** (the re-measure exceeded 40,000): the `### Optional post-Build artifact` body
  (Step 5's `Replace with` text) was moved into `reference/testing.md` under `## Manual test plan`, and the
  rules section reduced to the one-line pointer. So the **as-landed** Optional section is the pointer, not
  Step 5's paragraph (which a fresh re-run also produces, since the fallback fires on re-run too).
- **D12 re-measure: `wc -m` = 39,969 < 40,000** (verified at `/f3`, ~31 margin). All phase-exit greps pass.

## Files manifest

| File | Op |
|---|---|
| `templates/SHAMT_RULES.template.md` | EDIT (8 in-place edits, D12-gated) |
| `reference/testing.md` (Phase 1) | EDIT — Step 8 fallback trim, **fired at `/f3`**: the re-measure exceeded 40,000, so the Optional-post-Build body was moved here and the rules section reduced to a pointer (see the `/f3` amendment note above; the compensating Step-4 trim then brought the file to 39,969). |

---

## Step 1 — phase-count statement (L15)

Locate:
```
- **Two role flows** — an **Engineer flow** (seven-phase story workflow; eight phases when automated testing is enabled) and a **Product Owner flow** (Epic → Feature → Story decomposition).
```
Replace with:
```
- **Two role flows** — an **Engineer flow** (Quick path 7 phases / Standard path 8 phases — testing is a **required** phase) and a **Product Owner flow** (Epic → Feature → Story decomposition).
```

## Step 2 — Quick path map: insert the required Test phase + renumber

Locate (verbatim — the whole `### Quick path map (no automated testing)` table):
```
### Quick path map (no automated testing)

| Phase | Artifact | Gate |
|---|---|---|
| 1. Intake | `stories/{ID}-{slug}-{brief-description}/ticket.md` | User confirms slug + content |
| 2. Compact Spec | `stories/{slug}/spec.md` (Evidence, Code Shapes, Build Checklist, Verification inline) | Gate 2b: user approves spec/checklist |
| 3. Build | code changes | Verification checklist in spec |
| 4. Review | chat/spec summary; `feedback/review_v1.md` only on findings, risk, or user request | Review completed |
| 5. Polish | no-op unless feedback exists | TODO scan passes; feedback handled if present |
| 6. Finalize | scoped commit + work item marked done (`ticket.md` `**Status: Done**`) | `/e8-finalize-story`: prior phases complete, scoped clean-tree commit, explicit confirmation |
```
Replace with (title de-qualified; Test inserted after Build as positional row **4** in this 7-row Quick map; trailing Review/Polish/Finalize bumped 4→5, 5→6, 6→7). The Test phase's canonical cross-flow name remains **Phase 5 (Test)** (its Standard-path positional number, used by the normative prose in Step 4); inside this table the gate cell cites the **positional** number, "Phase 4 (Test)", exactly as every other gate cell in this table references its own row:
```
### Quick path map

| Phase | Artifact | Gate |
|---|---|---|
| 1. Intake | `stories/{ID}-{slug}-{brief-description}/ticket.md` | User confirms slug + content |
| 2. Compact Spec | `stories/{slug}/spec.md` (Evidence, Code Shapes, Build Checklist, Verification inline) | Gate 2b: user approves spec/checklist |
| 3. Build | code changes | Verification checklist in spec |
| 4. Test | `stories/{slug}/agent_test_session.md` (+ inline automated checklist when present) | Phase 4 (Test) PASSes (agent-as-user; automated when present) |
| 5. Review | chat/spec summary; `feedback/review_v1.md` only on findings, risk, or user request | Review completed |
| 6. Polish | no-op unless feedback exists | TODO scan passes; feedback handled if present |
| 7. Finalize | scoped commit + work item marked done (`ticket.md` `**Status: Done**`) | `/e8-finalize-story`: prior phases complete, scoped clean-tree commit, explicit confirmation |
```

## Step 3 — Standard path map: insert the required Test phase + renumber

Locate (verbatim — the whole `### Standard path map (no automated testing)` table):
```
### Standard path map (no automated testing)

| Phase | Artifact | Gate |
|---|---|---|
| 1. Intake | `stories/{ID}-{slug}-{brief-description}/ticket.md` | User confirms slug + content |
| 2. Spec | `stories/{slug}/spec.md` + `stories/{slug}/context.md` | Gate 2a design approval; Gate 2b validated-spec approval |
| 3. Plan | `stories/{slug}/implementation_plan.md` | Gate 3 approved |
| 4. Build | code changes | Verification checklist in plan |
| 5. Review | `stories/{slug}/feedback/review_v1.md` | Review artifact exists after Build |
| 6. Polish | `feedback/addressed_feedback.md` + commits | User signals complete |
| 7. Finalize | scoped commit + work item marked done (`ticket.md` `**Status: Done**`) | `/e8-finalize-story`: prior phases complete, scoped clean-tree commit, explicit confirmation |
```
Replace with (title de-qualified; Test inserted after Build as positional row **5** in this 8-row Standard map — matching the canonical "Phase 5 (Test)" name; trailing Review/Polish/Finalize bumped 5→6, 6→7, 7→8):
```
### Standard path map

| Phase | Artifact | Gate |
|---|---|---|
| 1. Intake | `stories/{ID}-{slug}-{brief-description}/ticket.md` | User confirms slug + content |
| 2. Spec | `stories/{slug}/spec.md` + `stories/{slug}/context.md` | Gate 2a design approval; Gate 2b validated-spec approval |
| 3. Plan | `stories/{slug}/implementation_plan.md` | Gate 3 approved |
| 4. Build | code changes | Verification checklist in plan |
| 5. Test | `stories/{slug}/agent_test_session.md` + `testing_plan.md` (when automated suites present) | Phase 5 (Test) PASSes |
| 6. Review | `stories/{slug}/feedback/review_v1.md` | Review artifact exists after Test |
| 7. Polish | `feedback/addressed_feedback.md` + commits | User signals complete |
| 8. Finalize | scoped commit + work item marked done (`ticket.md` `**Status: Done**`) | `/e8-finalize-story`: prior phases complete, scoped clean-tree commit, explicit confirmation |
```

## Step 4 — "When automated testing is enabled" → "Testing (required)" + extract to reference

Locate (verbatim — the heading + the single paragraph that follows it):
```
### When automated testing is enabled

When `.shamt-core/shamt-config.json` sets `testing: "enabled"`, a **Phase 5: Test** is inserted between Build and Review. Spec gains a **Test Strategy** section (approval-relevant at Gate 2b). Plan produces a `testing_plan.md` alongside `implementation_plan.md`. The Test phase executes the plan via the `test-executor` persona and blocks until all tests pass. Quick-path testing uses an inline checklist in `spec.md` and escalates to a full `testing_plan.md` artifact if test scope >5 steps or introduces a new test file.
```
Replace with the short normative summary + pointer (the detail now lives in `reference/testing.md`). This
summary is deliberately terse — the worked detail (between-Build-and-Review positioning, Quick-path inline
checklist, the addressed_feedback.md mechanics, re-run-to-green) all lives in `reference/testing.md`, so the
rules file keeps only the binding contract. (Amended at `/f3` — the original longer draft landed the file at
40,273; this terser form is the proposal-authorized compensating trim, re-measured at 39,969 < 40,000.)
```
### Testing (Phase 5 — required)

**Phase 5 (Test)** is **required** on every story and **blocks until green**: the `user-simulator` persona
drives the project per `TESTING_STANDARDS.md` (source of truth; no `testing` flag), writing
`agent_test_session.md`, plus the **automated** `testing_plan.md` when that doc declares suites. A failure
routes to `/e7-resolve-feedback` with a **required root-cause section** (which of Spec/Plan/Build let it
through + the prevention). Full detail in [`reference/testing.md`](reference/testing.md).
```

## Step 5 — "Optional post-Build artifact" → trim (manual_test_plan stays human-walkthrough)

Locate (verbatim — the heading + the single paragraph that follows it):
```
### Optional post-Build artifact

After Phase 4 (or Phase 5 when testing is enabled), `/e5b-write-manual-testing-plan {slug}` produces `manual_test_plan.md` for scenarios automated tests cannot exercise (UI behavior, cloud infra, external integrations, multi-user flows). Per-story, on demand — no project-level opt-in.
```
Replace with the tighter form (the agent-as-user run is the required pass; this is the on-demand human-walkthrough):
```
### Optional post-Build artifact

`/e5b-write-manual-testing-plan {slug}` produces `manual_test_plan.md` — an on-demand **human-walkthrough**
for scenarios the agent cannot simulate (real UI, cloud infra, external integrations, multi-user). Per-story,
on demand; not part of the required Phase-5 pass. See [`reference/testing.md`](reference/testing.md).
```
> **As-landed note:** the Step 8 fallback fired, so this paragraph was **moved** to `reference/testing.md`
> (`## Manual test plan`) and the on-disk rules section is the one-line pointer instead — see Step 8 and the
> Execution status section above. A fresh re-run reproduces this (the fallback fires on re-run too).

## Step 6 — e8 finalize gate (L131): Test PASSes always

Locate (in the `### Finalize phase (terminal)` section):
```
confirms prior phases complete (Review + feedback resolved; Test PASSes when testing is enabled), marks the work item done
```
Replace with:
```
confirms prior phases complete (Test PASSes — required; Review + feedback resolved), marks the work item done
```

## Step 7 — Story Artifact Naming: add the agent-as-user artifact

Locate:
```
- `manual_test_plan.md` is single-baseline; if re-baselined, follow the same `_vN.md` convention.
```
Replace with:
```
- `manual_test_plan.md` is single-baseline; if re-baselined, follow the same `_vN.md` convention.
- `agent_test_session.md` is the required Phase-5 agent-as-user run log; single-baseline (`_vN.md` if re-baselined).
```

## Step 7b — config description: drop the "testing opt-in" residual (L30)

Locate:
```
- `.shamt-core/shamt-config.json` — per-project configuration (tracker, testing opt-in, etc.).
```
Replace with (testing is no longer config-gated; `TESTING_STANDARDS.md` is the source of truth):
```
- `.shamt-core/shamt-config.json` — per-project configuration (tracker, etc.).
```

## Step 8 — D12 re-measure (HARD GATE)

Run `wc -m templates/SHAMT_RULES.template.md`.
- **< 40,000** → pass; record the new size in the phase report.
- **≥ 40,000** → **fallback trim**: move the entire "### Optional post-Build artifact" body into
  `reference/testing.md` (under a `## Manual test plan` heading) and replace the rules section with a
  one-line pointer (`Manual-test-plan detail: see reference/testing.md`). Re-measure; if still over, halt
  and report (do not improvise rule deletions).

---

## Verification (phase exit)

- `grep -ic "testing: \"enabled\"\|when testing is enabled\|automated testing is enabled\|no automated testing\|testing opt-in" templates/SHAMT_RULES.template.md`
  → `0` (no residual config-flag wording — covers L15/L113 "automated testing is enabled", L119/L131 "when testing is enabled", and L30 "testing opt-in").
- Both path maps contain a `Test` phase row; the phase-count statement says "required".
- `grep -q "agent_test_session.md" templates/SHAMT_RULES.template.md` (Story Artifact Naming + path maps).
- `grep -q "reference/testing.md" templates/SHAMT_RULES.template.md` (the pointer resolves — `reference/testing.md` exists from Phase 1).
- `wc -m templates/SHAMT_RULES.template.md` < 40,000.

## Notes

- This phase establishes the **normative contract** (required Phase 5; what it runs; the bug rule) that
  Phase 4's command/skill bodies must match (D2). Phase 4 follows it.
- `CODING_STANDARDS Compliance`: N/A — canonical rules file.
- **Review Prevention Gate Mapping**: N/A — this is a framework-update plan editing a canonical
  documentation file (`templates/SHAMT_RULES.template.md`), not a story implementation plan; there are
  no code paths / review categories to map. The phase-exit Verification (grep + `wc -m` D12 gate) is the
  applicable check.

---
Validated 2026-06-14 — 4 rounds, 1 adversarial sub-agent confirmed (re-validated after /f3 D12 compensating-trim amendment)
