# Implementation Plan — Phase 5: References

**Proposal:** proposals/49-engineer-flow-single-integer-phase-numbering.md
**Plan index:** proposals/49-engineer-flow-single-integer-phase-numbering_PLAN.md
**Covers:** Proposed Changes rows 41–56 (reference/)
**Created:** 2026-06-21

Renumber map applied throughout: e1 Intake · e2 Spec · e3 Plan · e4 Test Plan (NEW, merges e3b+e5b) · e5 Build (was e4) · e6 Test (was e5; user-simulator EXECUTES `user_test_plan.md`) · e7 Review (was e6, opens PR) · e8 Polish (was e7, iterative pull-only PR loop) · e9 Finalize (was e8, `gh pr merge`). `/e-all` drives e1→e7. `manual_test_plan` → `user_test_plan`. Quick/Standard retired everywhere; validation is uniform (one primary clean round + one adversarial sub-agent, always).

All edits are to canonical sources under `reference/` only — never `.claude/`.

## Steps

### Step 5.1 — reference/testing.md: rewrite header note (e5/e3b → e4/e6 keys)

**Operation:** EDIT
**File:** `reference/testing.md`
**Locate:**
```
# Testing Reference

Expanded detail for Shamt's **required** testing stage. `SHAMT_RULES.template.md` keeps the normative
contract (Phase 5 is required; what it runs; the bug→feedback rule); this file holds the worked detail.
Mirrors `reference/implementation_plan_reference.md` / `reference/spec_protocol_reference.md`.
```
**Replace:**
```
# Testing Reference

Expanded detail for Shamt's **mandatory** testing stages. `SHAMT_RULES.template.md` keeps the normative
contract (Phase 4 Test Plan and Phase 6 Test are both mandatory; what each runs; the bug→feedback rule);
this file holds the worked detail. Mirrors `reference/implementation_plan_reference.md` /
`reference/spec_protocol_reference.md`.
```
**Verification:** `grep -n "Phase 4 Test Plan and Phase 6 Test are both mandatory" reference/testing.md` returns one line; `grep -n "Phase 5 is required" reference/testing.md` returns nothing.

### Step 5.2 — reference/testing.md: rewrite "Source of truth" e5/e3b keys

**Operation:** EDIT
**File:** `reference/testing.md`
**Locate:**
```
config flag: it declares the **agent-as-user** driving procedures (always applicable) and whether
**automated suites** are **Present** or **None**. `/e5-execute-tests` and `/e3b-write-testing-plan`
key off this doc, not a config flag.
```
**Replace:**
```
config flag: it declares the **agent-as-user** driving procedures (always applicable) and whether
**automated suites** are **Present** or **None**. `/e6-execute-tests` and `/e4-write-test-plan`
key off this doc, not a config flag.
```
**Verification:** `grep -n "/e5-execute-tests\|/e3b-write-testing-plan" reference/testing.md` returns nothing.

### Step 5.3 — reference/testing.md: rewrite the "Required Phase 5 (Test)" section into mandatory dual-plan e4/e6 model

**Operation:** EDIT
**File:** `reference/testing.md`
**Locate:**
```
## Required Phase 5 (Test)

Phase 5 runs on **every** story, between Build and Review, and **blocks until green**:

1. **Agent-as-user execution (always)** — the `user-simulator` persona drives the project as a user
   per `TESTING_STANDARDS.md`, writing `stories/{slug}/agent_test_session.md`. Every scenario must
   `PASS`; ambiguous → `HALT` (never a silent pass).
2. **Automated suites (when present)** — when `TESTING_STANDARDS.md` declares automated tests, the
   `test-executor` persona runs `testing_plan.md` (Standard) or the Quick-path inline checklist.

`manual_test_plan.md` is **not** part of the required pass — it is an on-demand human-walkthrough for
scenarios the agent cannot simulate (real UI, cloud infra, multi-user). It stays available on every
story via `/e5b-write-manual-testing-plan`.

## Quick vs Standard path

- **Quick path** — a compact agent-as-user run (the scenarios relevant to the Quick-path story); automated
  testing uses the inline checklist in `spec.md` and escalates to a full `testing_plan.md` only if
  scope > 5 steps or a new test file is introduced.
- **Standard path** — the full `agent_test_session.md` + (when present) the full `testing_plan.md`.
```
**Replace:**
```
## Mandatory Phase 4 (Test Plan)

Phase 4 runs on **every** story, between Plan and Build, and authors the test plans the Phase-6 Test
stage later executes:

1. **`user_test_plan.md` (always)** — the agent-as-user scenario plan: a spec-derived, step-by-step
   script the `user-simulator` later **executes** as if it were a real user. Authored on every story
   via `/e4-write-test-plan` and validated under the uniform Pattern 1 loop.
2. **`testing_plan.md` (when automated suites exist)** — the automated-suite plan, authored only when
   `TESTING_STANDARDS.md` declares suites (a test framework is physically required). When suites are
   `None`, no `testing_plan.md` is produced — but `user_test_plan.md` is, so **Phase 4 always runs**.

## Mandatory Phase 6 (Test)

Phase 6 runs on **every** story, between Build and Review, and **blocks until green**:

1. **Agent-as-user execution (always)** — the `user-simulator` persona **executes** the
   `user_test_plan.md` authored in Phase 4, driving the project per each scenario and consulting
   `TESTING_STANDARDS.md` for project conventions, writing `stories/{slug}/agent_test_session.md`.
   Every scenario must `PASS`; ambiguous → `HALT` (never a silent pass).
2. **Automated suites (when present)** — when `TESTING_STANDARDS.md` declares automated tests, the
   `test-executor` persona runs `testing_plan.md`.
```
**Verification:** `grep -n "Quick vs Standard\|Quick path\|Standard path\|inline checklist\|manual_test_plan\|/e5b" reference/testing.md` returns nothing; `grep -n "Mandatory Phase 4 (Test Plan)" reference/testing.md` and `grep -n "Mandatory Phase 6 (Test)" reference/testing.md` each return one line; `grep -n "executes\*\*\? the\? *.user_test_plan" reference/testing.md` confirms the execute-the-plan wording is present.

### Step 5.4 — reference/testing.md: renumber the bug-as-feedback loop (Phase 5 → Phase 6; /e7→/e8; /e8→/e9)

**Operation:** EDIT
**File:** `reference/testing.md`
**Locate:**
```
## Bug-as-feedback loop (test failure → Polish)

A Phase-5 `FAIL` is a **post-implementation bug**. It is treated as a feedback comment:

1. **Document** it as a feedback item (the failing scenario + observed-vs-expected evidence).
2. **Route to `/e7-resolve-feedback`** — the fix is applied and logged in `addressed_feedback.md`.
3. **Required root-cause section** — `addressed_feedback.md` must record **which phase let the bug
   through** (Spec — missing requirement; Plan — missing/incorrect step; Build — execution defect) and
   the **prevention** (what would have caught it earlier).
4. **Re-run Phase 5 to green** before Finalize. Finalize (`/e8`) blocks until Test PASSes.
```
**Replace:**
```
## Bug-as-feedback loop (test failure → Polish)

A Phase-6 `FAIL` is a **post-implementation bug**. It is treated as a feedback comment:

1. **Document** it as a feedback item (the failing scenario + observed-vs-expected evidence).
2. **Route to `/e8-resolve-feedback`** — the fix is applied and logged in `addressed_feedback.md`.
3. **Required root-cause section** — `addressed_feedback.md` must record **which phase let the bug
   through** (Spec — missing requirement; Plan — missing/incorrect step; Build — execution defect) and
   the **prevention** (what would have caught it earlier).
4. **Re-run Phase 6 to green** before Finalize. Finalize (`/e9`) blocks until Test PASSes.
```
**Verification:** `grep -n "Phase-5 \`FAIL\`\|/e7-resolve-feedback\|Re-run Phase 5\|(\`/e8\`) blocks" reference/testing.md` returns nothing; `grep -n "Phase-6 \`FAIL\`\|/e8-resolve-feedback\|Re-run Phase 6\|(\`/e9\`) blocks" reference/testing.md` returns the renumbered lines.

### Step 5.5 — reference/testing.md: replace the trailing "Manual test plan" section with the user-test-plan model

**Operation:** EDIT
**File:** `reference/testing.md`
**Locate:**
```
## Manual test plan

`/e5b-write-manual-testing-plan {slug}` produces `manual_test_plan.md` — an on-demand **human-walkthrough**
for scenarios the agent cannot simulate (real UI, cloud infra, external integrations, multi-user). Per-story,
on demand; not part of the required Phase-5 pass.
```
**Replace:**
```
## User test plan

`/e4-write-test-plan {slug}` produces `user_test_plan.md` — the **agent-as-user scenario plan**, a
spec-derived step-by-step script the `user-simulator` **executes** in Phase 6 (driving the project as a
real user). It is **mandatory** on every story (always produced in Phase 4) and is the executed source
for the Phase-6 agent-as-user run — not an on-demand human walkthrough. The per-run results are logged
separately in `agent_test_session.md`.
```
**Verification:** `grep -n "## Manual test plan\|/e5b-write-manual-testing-plan\|manual_test_plan\|human-walkthrough" reference/testing.md` returns nothing; `grep -n "## User test plan\|/e4-write-test-plan" reference/testing.md` returns the new lines; final whole-file sweep `grep -nE "Quick|Standard|manual|e3b|e5b|Phase 5|Phase-5|/e[4-8][^-]" reference/testing.md` returns no residual Engineer-renumber/Quick-Standard hits.

### Step 5.6 — reference/model_selection.md: drop manual-test-plan-drafting from the Balanced tier line

**Operation:** EDIT
**File:** `reference/model_selection.md`
**Locate:**
```
| **Balanced** | Sonnet | Code reading, structural analysis, spec research, plan creation, medium-complexity validation, formal-mode code review metadata, manual-test-plan drafting |
```
**Replace:**
```
| **Balanced** | Sonnet | Code reading, structural analysis, spec research, plan creation, medium-complexity validation, formal-mode code review metadata, user-test-plan drafting |
```
**Verification:** `grep -n "manual-test-plan drafting" reference/model_selection.md` returns nothing; `grep -n "user-test-plan drafting" reference/model_selection.md` returns one line.

### Step 5.7 — reference/model_selection.md: renumber the user-simulator persona row (Phase 5 → Phase 6)

**Operation:** EDIT
**File:** `reference/model_selection.md`
**Locate:**
```
| `user-simulator` | Balanced (Sonnet) | Phase 5 agent-as-user execution — drives the project as a user, supplies inputs, judges observed-vs-expected; interpretive, so not Cheap |
```
**Replace:**
```
| `user-simulator` | Balanced (Sonnet) | Phase 6 agent-as-user execution — executes `user_test_plan.md`, supplies inputs, judges observed-vs-expected; interpretive, so not Cheap |
```
**Verification:** `grep -n "Phase 5 agent-as-user" reference/model_selection.md` returns nothing; `grep -n "Phase 6 agent-as-user execution — executes \`user_test_plan.md\`" reference/model_selection.md` returns one line.

### Step 5.8 — reference/model_selection.md: rewrite the per-phase guidance table (rows 1–8, merged e4, no Quick/Standard build, manual→user)

**Operation:** EDIT
**File:** `reference/model_selection.md`
**Locate:**
```
| Phase | Default tier | Notes |
|-------|--------------|-------|
| 1. Intake | Cheap | Ticket fetch + freeform capture is mechanical |
| 2. Spec — research | Balanced | Code reading and structural analysis |
| 2. Spec — Gate 2a design dialog | Reasoning | Multi-option design comparison |
| 2. Spec — validation loop | Reasoning | Primary; sub-agent always Cheap |
| 3. Plan — drafting | Balanced | Structural step decomposition |
| 3. Plan — validation loop | Reasoning | Primary; sub-agent always Cheap |
| 3. Plan — `testing_plan.md` drafting | Balanced | Same shape as the main plan |
| 4. Build (Quick path) | Balanced | Primary agent executes inline |
| 4. Build (Standard path) | Cheap (`plan-executor`) | Mechanical plan execution by the builder persona; the architect's planning happened in Phase 3 and the architect only re-engages on builder-reported failure / ambiguity |
| 5. Test — agent-as-user | Balanced (`user-simulator`) | Required; drives the project as a user per TESTING_STANDARDS.md |
| 5. Test — automated suites | Cheap (`test-executor`) | When TESTING_STANDARDS.md declares automated tests |
| 6. Review (story-mode) | Balanced | 16-category sweep at the story altitude |
| 6. Review (formal-mode issue-finding) | Reasoning (`review-executor`) | Dedicated Opus persona for branch / PR review |
| 6. Review (formal-mode git metadata) | Cheap | Fetch branch commits, diff stats, file inventory; mechanical |
| 7. Polish — code edits | Balanced | Apply reviewer feedback; mechanical fixes |
| 7. Polish — root cause / upstream proposals | Reasoning | Generalize recurring feedback into framework-update proposals; multi-piece synthesis |
| 8. Finalize (`/e8-finalize-story`) | Cheap | Mechanical: evaluate three guards, scoped commit, one tracker-close command, status flip — mirrors `/f6-archive-proposal` |
```
**Replace:**
```
| Phase | Default tier | Notes |
|-------|--------------|-------|
| 1. Intake | Cheap | Ticket fetch + freeform capture is mechanical |
| 2. Spec — research | Balanced | Code reading and structural analysis |
| 2. Spec — Gate 2a design dialog | Reasoning | Multi-option design comparison |
| 2. Spec — validation loop | Reasoning | Primary; sub-agent always Cheap |
| 3. Plan — drafting | Balanced | Structural step decomposition; mandatory for every story |
| 3. Plan — validation loop | Reasoning | Primary; sub-agent always Cheap |
| 4. Test Plan — `user_test_plan.md` drafting | Balanced | Mandatory; spec-derived agent-as-user scenario plan |
| 4. Test Plan — `testing_plan.md` drafting | Balanced | When TESTING_STANDARDS.md declares automated suites; same shape as the main plan |
| 4. Test Plan — validation loop | Reasoning | Primary; sub-agent always Cheap |
| 5. Build (`plan-executor`) | Cheap (`plan-executor`) | Mechanical plan execution by the builder persona; the architect's planning happened in Phases 3–4 and the architect only re-engages on builder-reported failure / ambiguity |
| 6. Test — agent-as-user | Balanced (`user-simulator`) | Mandatory; executes `user_test_plan.md`, driving the project as a user per TESTING_STANDARDS.md |
| 6. Test — automated suites | Cheap (`test-executor`) | When TESTING_STANDARDS.md declares automated tests |
| 7. Review (story-mode) | Balanced | 16-category sweep at the story altitude |
| 7. Review (formal-mode issue-finding) | Reasoning (`review-executor`) | Dedicated Opus persona for branch / PR review |
| 7. Review (formal-mode git metadata) | Cheap | Fetch branch commits, diff stats, file inventory; mechanical |
| 8. Polish — code edits | Balanced | Apply reviewer feedback; mechanical fixes |
| 8. Polish — root cause / upstream proposals | Reasoning | Generalize recurring feedback into framework-update proposals; multi-piece synthesis |
| 9. Finalize (`/e9-finalize-story`) | Cheap | Mechanical: evaluate the guards, scoped commit, `gh pr merge` (when `pr_provider == github`), one tracker-close command, status flip — mirrors `/f6-archive-proposal` |
```
**Verification:** `grep -n "Build (Quick path)\|Build (Standard path)\|5. Test\|6. Review\|7. Polish\|8. Finalize (\`/e8" reference/model_selection.md` returns nothing; `grep -n "4. Test Plan\|5. Build (\`plan-executor\`)\|6. Test\|7. Review\|8. Polish\|9. Finalize (\`/e9-finalize-story\`)" reference/model_selection.md` returns the renumbered rows.

### Step 5.9 — reference/model_selection.md: renumber the `/e5b` PO/Engineer rows (manual-test-plan + e-all phase span)

**Operation:** EDIT
**File:** `reference/model_selection.md`
**Locate:**
```
| Manual-test-plan drafting (`/e5b-write-manual-testing-plan`) | Balanced | Drafting + validation loop per the manual-test-plan rule |
| Engineer flow — `/e-all` driver (spans Phases 1–6, through Review) | Balanced | Meta-driver: sequences phases, dispatches one sub-agent per phase, inspects each report, and pauses on each interactive gate / halts on failure. The heavy per-phase reasoning lives in the dispatched agents at their own tiers (spec / plan-validation primary Reasoning; `plan-executor` Cheap; `user-simulator` Balanced; `test-executor` / `validation-checker` Cheap; story-review primary Balanced). Child-facing analog of the `/f-all` driver row below |
```
**Replace:**
```
| Test-plan drafting (`/e4-write-test-plan`) | Balanced | Drafting + validation loop for the mandatory `user_test_plan.md` (always) and `testing_plan.md` (when suites exist) |
| Engineer flow — `/e-all` driver (spans Phases 1–7, through Review) | Balanced | Meta-driver: sequences phases, dispatches one sub-agent per phase, inspects each report, and pauses on each interactive gate / halts on failure. The heavy per-phase reasoning lives in the dispatched agents at their own tiers (spec / plan-validation / test-plan-validation primary Reasoning; `plan-executor` Cheap; `user-simulator` Balanced; `test-executor` / `validation-checker` Cheap; story-review primary Balanced). Child-facing analog of the `/f-all` driver row below |
```
**Verification:** `grep -n "/e5b-write-manual-testing-plan\|spans Phases 1–6" reference/model_selection.md` returns nothing; `grep -n "Test-plan drafting (\`/e4-write-test-plan\`)\|spans Phases 1–7" reference/model_selection.md` returns the two new rows. (The whole-file Quick/Standard sweep is deferred to Step 5.9a, which clears the last residual — the framework-update "Standard path execution" row — so the sweep can pass.)

### Step 5.9a — reference/model_selection.md: de-Quick/Standard the framework-update Phase-4 builder row

**Operation:** EDIT
**File:** `reference/model_selection.md`
**Locate:**
```
| Framework update — Phase 4 (Standard path execution via `plan-executor`) | Cheap | Mechanical execution of the validated plan; identical persona contract to story-altitude builder |
```
**Replace:**
```
| Framework update — Phase 4 (plan execution via `plan-executor`) | Cheap | Mechanical execution of the validated plan; identical persona contract to story-altitude builder |
```
**Verification:** `grep -n "Phase 4 (Standard path execution via" reference/model_selection.md` returns nothing; `grep -n "Phase 4 (plan execution via \`plan-executor\`)" reference/model_selection.md` returns one line; whole-file sweep `grep -nE "Quick path|Standard path|e3b|e5b|manual" reference/model_selection.md` returns no residual hits after Steps 5.6–5.9a land. (This row is the framework-update flow's builder line; "Standard path" here was the retired story-path term reused as a label — the framework-update build always runs via `plan-executor` once a plan exists, so the path qualifier is dropped, not replaced with a branch.)

### Step 5.10 — reference/validation_exit_criteria.md: retire the Quick/Standard exit distinction (single uniform exit)

**Operation:** EDIT
**File:** `reference/validation_exit_criteria.md`
**Locate:**
```
## Exit Criterion (by path)

- **Standard path:** Primary clean round + **1 independent Haiku adversarial review sub-agent confirmation**. Applies to all Standard-path validation loops (specs, plans, code reviews, and ad-hoc artifacts).
- **Quick path:** A single primary self-review pass. An adversarial sub-agent is only required if a risk trigger applies (e.g. database migrations, security controls, new service creation, auth/tenant boundary changes, etc.).
```
**Replace:**
```
## Exit Criterion (uniform)

Every validation loop exits the same way: **a primary clean round + 1 independent Haiku adversarial review sub-agent confirmation**. There is no path-based rigor selector — this uniform exit applies to all validation loops (specs, plans, test plans, code reviews, and ad-hoc artifacts) regardless of story size or risk.
```
**Verification:** `grep -n "Exit Criterion (by path)\|Standard path:\|Quick path:" reference/validation_exit_criteria.md` returns nothing; `grep -n "Exit Criterion (uniform)" reference/validation_exit_criteria.md` returns one line.

### Step 5.11 — reference/validation_exit_criteria.md: rename the Counter Logic heading (drop "Standard path or risk-triggered")

**Operation:** EDIT
**File:** `reference/validation_exit_criteria.md`
**Locate:**
```
## Counter Logic (Standard path or risk-triggered)
```
**Replace:**
```
## Counter Logic
```
**Verification:** `grep -n "Counter Logic (Standard path or risk-triggered)" reference/validation_exit_criteria.md` returns nothing; `grep -n "^## Counter Logic$" reference/validation_exit_criteria.md` returns one line.

### Step 5.12 — reference/validation_exit_criteria.md: relabel the "Scenario 1: Quick exit" example (Quick is now a v1 term)

**Operation:** EDIT
**File:** `reference/validation_exit_criteria.md`
**Locate:**
```
**Scenario 1: Quick exit (2 rounds)**
```
**Replace:**
```
**Scenario 1: Fast exit (2 rounds)**
```
**Verification:** `grep -n "Scenario 1: Quick exit" reference/validation_exit_criteria.md` returns nothing; `grep -n "Scenario 1: Fast exit (2 rounds)" reference/validation_exit_criteria.md` returns one line; whole-file sweep `grep -nE "Quick path|Standard path|Quick exit" reference/validation_exit_criteria.md` returns no residual hits. (The "Quick exit" label was descriptive prose, not a path name; renaming avoids any D7 "Quick" residue.)

### Step 5.13 — reference/spec_protocol_reference.md: drop the Standard-vs-Quick artifact-table mention from the 7-step intro

**Operation:** EDIT
**File:** `reference/spec_protocol_reference.md`
**Locate:**
```
The rules file keeps Pattern 3's purpose, the Gate 2a/2b contract, the Standard-vs-Quick artifact table, and the five validation pair-checks; this is the expanded per-step prose.
```
**Replace:**
```
The rules file keeps Pattern 3's purpose, the Gate 2a/2b contract, the artifact-shape contract, and the five validation pair-checks; this is the expanded per-step prose.
```
**Verification:** `grep -n "Standard-vs-Quick" reference/spec_protocol_reference.md` returns nothing.

### Step 5.14 — reference/spec_protocol_reference.md: Step 2 research — context always produced (drop the Quick alternative)

**Operation:** EDIT
**File:** `reference/spec_protocol_reference.md`
**Locate:**
```
**Step 2 — Targeted research.** Scope to ticket references, not broad exploration: grep referenced files/functions/features; read `.shamt-core/project-specific-files/ARCHITECTURE.md` + `CODING_STANDARDS.md`; skim related code. Record findings in `context.md` (Standard) or `spec.md` Evidence (Quick). The required captures — code shapes, pre-existing gaps, current flow, review-prevention risk inventory, boundary-diagram evidence, and file placement — are enumerated under [Step 2 — Required research captures](#step-2--required-research-captures) below.
```
**Replace:**
```
**Step 2 — Targeted research.** Scope to ticket references, not broad exploration: grep referenced files/functions/features; read `.shamt-core/project-specific-files/ARCHITECTURE.md` + `CODING_STANDARDS.md`; skim related code. Record findings in `context.md` (always produced). The required captures — code shapes, pre-existing gaps, current flow, review-prevention risk inventory, boundary-diagram evidence, and file placement — are enumerated under [Step 2 — Required research captures](#step-2--required-research-captures) below.
```
**Verification:** `grep -n "(Standard) or \`spec.md\` Evidence (Quick)" reference/spec_protocol_reference.md` returns nothing in the Step 2 line; line now contains `context.md\` (always produced)`.

### Step 5.15 — reference/spec_protocol_reference.md: Step 3 skeletons — spec + context always; remove the Path-selection / Quick-only branch

**Operation:** EDIT
**File:** `reference/spec_protocol_reference.md`
**Locate:**
```
**Step 3 — Draft skeletons.** Standard path drafts `spec.md` (from `templates/spec.template.md`) + `context.md` (from `templates/context.template.md`): `spec.md` is the approval contract; `context.md` is the evidence/planning handoff; approval-relevant persistence design and review-prevention requirements must appear in `spec.md`, not only `context.md`; Key Design Decision IDs appear in both. Quick path drafts `spec.md` only — populate Evidence, compact Review Prevention Evidence, Code Shapes, Review Prevention Checklist, Build Checklist, and Verification inline; do not create `context.md` or `implementation_plan.md` unless the story escalates or a risk trigger applies. Optional Standard-path plan skeleton: after `spec.md`/`context.md`, create `implementation_plan.md` with exploratory headers only, mark unresolved decisions `Blocked:`, set Planning Status to "Blocked on spec (Gate 2a)"; do not fill locate strings until after Gate 2a. (The artifact-shape table is the KEEP-INLINE contract in the rules file.)
```
**Replace:**
```
**Step 3 — Draft skeletons.** Always draft `spec.md` (from `templates/spec.template.md`) + `context.md` (from `templates/context.template.md`): `spec.md` is the approval contract; `context.md` is the evidence/planning handoff; approval-relevant persistence design and review-prevention requirements must appear in `spec.md`, not only `context.md`; Key Design Decision IDs appear in both. Optional plan skeleton: after `spec.md`/`context.md`, create `implementation_plan.md` with exploratory headers only, mark unresolved decisions `Blocked:`, set Planning Status to "Blocked on spec (Gate 2a)"; do not fill locate strings until after Gate 2a. (The artifact-shape contract is the KEEP-INLINE contract in the rules file.)
```
**Verification:** `grep -n "Standard path drafts\|Quick path drafts \`spec.md\` only\|Build Checklist, and Verification inline\|Standard-path plan skeleton" reference/spec_protocol_reference.md` returns nothing; `grep -n "Always draft \`spec.md\`" reference/spec_protocol_reference.md` returns one line.

### Step 5.16 — reference/spec_protocol_reference.md: Step 5 flesh-out — drop the path-specific spec/context split + risk-escalate-to-Standard

**Operation:** EDIT
**File:** `reference/spec_protocol_reference.md`
**Locate:**
```
**Step 5 — Flesh out spec/context.** Record the agreed approach into the Step 3 artifacts (Standard: approval-facing `spec.md` + detailed `context.md`; Quick: all inline in `spec.md`). Before placing anything in Open Questions, answer it from the codebase — only product/team/external-system decisions remain open, surfaced one at a time (Principle 2). For each applicable high-risk surface state the approval-facing **prevention requirement**, and if a prevention surface is itself a risk trigger escalate to Standard path. For any schema, migration, or table-level change the spec must trace the end-to-end cross-service read **and** write data lineage across service boundaries (so data is not written but ignored at runtime), including any missing backchannel API / query route / config endpoint as in-scope **or** listing it a Blocker for Gate 2a/2b vetting. The enumerated prevention requirements, the schema/lineage detail (column/delta listing, reviewable candidate options, explicit deferral), and the path-specific spec/context split are in the [Step 5](#step-5--prevention-requirements-per-high-risk-surface) sections below. Resolve all parallel-skeleton `Blocked:` markers after Gate 2a.
```
**Replace:**
```
**Step 5 — Flesh out spec/context.** Record the agreed approach into the Step 3 artifacts: the approval-facing `spec.md` + detailed `context.md`. Before placing anything in Open Questions, answer it from the codebase — only product/team/external-system decisions remain open, surfaced one at a time (Principle 2). For each applicable high-risk surface state the approval-facing **prevention requirement**. For any schema, migration, or table-level change the spec must trace the end-to-end cross-service read **and** write data lineage across service boundaries (so data is not written but ignored at runtime), including any missing backchannel API / query route / config endpoint as in-scope **or** listing it a Blocker for Gate 2a/2b vetting. The enumerated prevention requirements and the schema/lineage detail (column/delta listing, reviewable candidate options, explicit deferral) are in the [Step 5](#step-5--prevention-requirements-per-high-risk-surface) sections below. Resolve all parallel-skeleton `Blocked:` markers after Gate 2a.
```
**Verification:** `grep -n "(Standard: approval-facing\|if a prevention surface is itself a risk trigger escalate to Standard\|the path-specific spec/context split are in" reference/spec_protocol_reference.md` returns nothing.

### Step 5.17 — reference/spec_protocol_reference.md: Step 6 validate — uniform exit (drop the Quick-only single-pass branch)

**Operation:** EDIT
**File:** `reference/spec_protocol_reference.md`
**Locate:**
```
**Step 6 — Validate.** Standard path runs Pattern 1 on the `spec.md` + `context.md` pair using spec dimensions plus the five pair checks (kept in the rules file as the normative contract); exit is primary clean + 1 adversarial sub-agent, footer both files. Quick path runs Pattern 1 on `spec.md` alone (Requirements, Evidence, Review Prevention Gates/Evidence/Checklist, Code Shapes, Build Checklist, Verification); one primary clean pass is enough unless a risk trigger requires an adversarial sub-agent; footer `spec.md`. If a Mermaid diagram is recorded in the active artifacts, verify it renders, every node/edge is research- or decision-backed, it does not contradict spec/context, and it conforms to `reference/mermaid_diagram_standards.md`. Each round ask, "What code should I have read that I haven't?" — and read it.
```
**Replace:**
```
**Step 6 — Validate.** Run Pattern 1 on the `spec.md` + `context.md` pair using spec dimensions plus the five pair checks (kept in the rules file as the normative contract); exit is the uniform primary clean + 1 adversarial sub-agent, footer both files. If a Mermaid diagram is recorded in the active artifacts, verify it renders, every node/edge is research- or decision-backed, it does not contradict spec/context, and it conforms to `reference/mermaid_diagram_standards.md`. Each round ask, "What code should I have read that I haven't?" — and read it.
```
**Verification:** `grep -n "Standard path runs Pattern 1\|Quick path runs Pattern 1 on \`spec.md\` alone\|one primary clean pass is enough" reference/spec_protocol_reference.md` returns nothing.

### Step 5.18 — reference/spec_protocol_reference.md: Step 7 approval — drop "(Standard path)" qualifier

**Operation:** EDIT
**File:** `reference/spec_protocol_reference.md`
**Locate:**
```
**Step 7 — User approval (Gate 2b).** Present the validated `spec.md` as the approval artifact and link `context.md` as supporting detail (Standard path). If a new service is in scope, standard monitoring requirements must appear in Requirements or be explicitly Deferred with reason.
```
**Replace:**
```
**Step 7 — User approval (Gate 2b).** Present the validated `spec.md` as the approval artifact and link `context.md` as supporting detail. If a new service is in scope, standard monitoring requirements must appear in Requirements or be explicitly Deferred with reason.
```
**Verification:** `grep -n "supporting detail (Standard path)" reference/spec_protocol_reference.md` returns nothing.

### Step 5.19 — reference/spec_protocol_reference.md: Step 2 captures intro — context always (drop the Quick alternative)

**Operation:** EDIT
**File:** `reference/spec_protocol_reference.md`
**Locate:**
```
Targeted research is scoped to the ticket's references, not broad exploration: grep the referenced files / functions / features; read `.shamt-core/project-specific-files/ARCHITECTURE.md` + `CODING_STANDARDS.md`; skim related code. Record findings in `context.md` (Standard) or `spec.md` Evidence (Quick). The required captures:
```
**Replace:**
```
Targeted research is scoped to the ticket's references, not broad exploration: grep the referenced files / functions / features; read `.shamt-core/project-specific-files/ARCHITECTURE.md` + `CODING_STANDARDS.md`; skim related code. Record findings in `context.md` (always produced). The required captures:
```
**Verification:** `grep -c "(Standard) or \`spec.md\` Evidence (Quick)" reference/spec_protocol_reference.md` returns 0.

### Step 5.20 — reference/spec_protocol_reference.md: Step 5 prevention section — drop the Standard/Quick storage split + risk-escalate

**Operation:** EDIT
**File:** `reference/spec_protocol_reference.md`
**Locate:**
```
Before placing anything in Open Questions, answer it from the codebase — only product / team / external-system decisions remain open, surfaced one at a time (Principle 2). For each applicable high-risk surface, state the approval-facing **prevention requirement**. Standard path stores detailed evidence in `context.md`; Quick stores compact evidence inline in `spec.md`. If a prevention surface is itself a risk trigger, escalate to the Standard path.
```
**Replace:**
```
Before placing anything in Open Questions, answer it from the codebase — only product / team / external-system decisions remain open, surfaced one at a time (Principle 2). For each applicable high-risk surface, state the approval-facing **prevention requirement**. Detailed evidence is stored in `context.md`.
```
**Verification:** `grep -n "Standard path stores detailed evidence\|Quick stores compact evidence\|escalate to the Standard path" reference/spec_protocol_reference.md` returns nothing.

### Step 5.21 — reference/spec_protocol_reference.md: rewrite the "Path-specific spec/context split (Step 5)" section into a single uniform split

**Operation:** EDIT
**File:** `reference/spec_protocol_reference.md`
**Locate:**
```
## Path-specific spec/context split (Step 5)

- **Standard** keeps `spec.md` concise and approval-facing while `context.md` carries detailed rationale, evidence, current flow, standards notes, and code shapes.
- **Quick** keeps all of that inline in `spec.md`.
- Standard path does **not** add a Files Affected inventory to the spec (file-level work belongs in the plan); Quick uses the Review Prevention Checklist and Build Checklist for files, prevention gates, and sequential mechanical steps.
- Resolve all parallel-skeleton `Blocked:` markers after Gate 2a.
```
**Replace:**
```
## Spec/context split (Step 5)

- `spec.md` stays concise and approval-facing while `context.md` carries detailed rationale, evidence, current flow, standards notes, and code shapes.
- The spec does **not** add a Files Affected inventory (file-level work belongs in the plan).
- Resolve all parallel-skeleton `Blocked:` markers after Gate 2a.
```
**Verification:** `grep -n "Path-specific spec/context split\|- \*\*Standard\*\* keeps\|- \*\*Quick\*\* keeps" reference/spec_protocol_reference.md` returns nothing; `grep -n "## Spec/context split (Step 5)" reference/spec_protocol_reference.md` returns one line; whole-file sweep `grep -nE "Quick|Standard|Build Checklist" reference/spec_protocol_reference.md` returns no residual hits (the anchor `#step-5--prevention-requirements-per-high-risk-surface` is unchanged, so the inbound link in Step 5 stays valid).

### Step 5.22 — reference/implementation_plan_reference.md: Step 3 validate — drop "Exit: primary clean + 1 adversarial sub-agent" path-neutral (no change needed) / confirm wording

Note: Step 3's "Exit: primary clean + 1 adversarial sub-agent" is already uniform — no Quick/Standard branch. No edit. (Recorded so the index can confirm this site was inspected.)

**Operation:** (no-op inspection — see Phase notes)
**Verification:** `grep -n "Exit: primary clean + 1 adversarial sub-agent" reference/implementation_plan_reference.md` returns one line (already uniform); confirms no Quick/Standard branch exists at this site.

### Step 5.23 — reference/implementation_plan_reference.md: Step 4 handoff — builder always (remove Quick-path inline build branch)

**Operation:** EDIT
**File:** `reference/implementation_plan_reference.md`
**Locate:**
```
**Step 4 — Hand off to builder.** In the Standard path, builder handoff is unconditional after Gate 3. Single-file plans hand off `implementation_plan.md`; phase-decomposed plans hand off one phase at a time in deploy order. In the Quick path, the primary agent executes the Build Checklist unless delegation is explicitly requested. The builder contract (follow steps exactly, execute sequentially, run specified verification, stop on failed verification or ambiguity; report strings `All steps completed. Verification passed.` / `Step N failed: ...` / `Step N is ambiguous: ...` / `Plan defect at Step N: ...`; cheap-tier builder) is kept in the rules file; the full handoff template is under [Builder handoff template](#builder-handoff-template) below.
```
**Replace:**
```
**Step 4 — Hand off to builder.** Builder handoff is unconditional after Gate 3 — every story plans, and `plan-executor` always executes the plan. Single-file plans hand off `implementation_plan.md`; phase-decomposed plans hand off one phase at a time in deploy order. The builder contract (follow steps exactly, execute sequentially, run specified verification, stop on failed verification or ambiguity; report strings `All steps completed. Verification passed.` / `Step N failed: ...` / `Step N is ambiguous: ...` / `Plan defect at Step N: ...`; cheap-tier builder) is kept in the rules file; the full handoff template is under [Builder handoff template](#builder-handoff-template) below.
```
**Verification:** `grep -n "In the Standard path, builder handoff\|In the Quick path, the primary agent executes the Build Checklist" reference/implementation_plan_reference.md` returns nothing; `grep -n "Builder handoff is unconditional after Gate 3 — every story plans" reference/implementation_plan_reference.md` returns one line.

### Step 5.24 — reference/implementation_plan_reference.md: rewrite the "Checklist vs Full Plan Escalation" section (plan always; remove Quick inline-checklist path)

**Operation:** EDIT
**File:** `reference/implementation_plan_reference.md`
**Locate:**
```
## Checklist vs Full Plan Escalation

The **Quick path** embeds a compact `## Build Checklist` inside `spec.md` instead of creating `implementation_plan.md`.

**Escalate to a full Implementation Plan at `stories/{slug}/implementation_plan.md` (the resolved story folder, per §PO-tree resolution) when:**

- The build checklist exceeds 10 steps.
- The build will be delegated to a builder sub-agent.
- Exact locate / replace strings or byte-for-byte copy-file compatibility checks are necessary to prevent ambiguity in shared files.
- Verification steps depend on a complex multi-step deployment or database migration sequence.
- The user explicitly requests Gate 3 planning.
```
**Replace:**
```
## Plan decomposition

Every story produces a full `implementation_plan.md` at `stories/{slug}/implementation_plan.md` (the resolved story folder, per §PO-tree resolution) — Plan is mandatory; there is no inline-checklist alternative. Decompose the single plan into an index + validated phase files (`{slug}_PLAN.md` + `_PLAN_phase_*.md`) when the plan crosses more than one deploy boundary, any phase exceeds ~10 steps, or the plan approaches ~1500 lines (the index + phase-file rule kept in the rules file). Use the index/phase split especially when:

- The plan exceeds ~10 steps in any single phase.
- Exact locate / replace strings or byte-for-byte copy-file compatibility checks are necessary to prevent ambiguity in shared files.
- Verification steps depend on a complex multi-step deployment or database migration sequence.
```
**Verification:** `grep -n "## Checklist vs Full Plan Escalation\|The \*\*Quick path\*\* embeds a compact\|build checklist exceeds 10 steps" reference/implementation_plan_reference.md` returns nothing; `grep -n "## Plan decomposition" reference/implementation_plan_reference.md` returns one line.

### Step 5.25 — reference/implementation_plan_reference.md: Step 1 read — drop the Quick-path `spec.md` code-shapes alternative

**Operation:** EDIT
**File:** `reference/implementation_plan_reference.md`
**Locate:**
```
For EDIT steps, look up only the 5–10 lines around each target symbol; use code shapes recorded in `context.md` / Quick-path `spec.md`.
```
**Replace:**
```
For EDIT steps, look up only the 5–10 lines around each target symbol; use code shapes recorded in `context.md`.
```
**Verification:** `grep -n "Quick-path \`spec.md\`" reference/implementation_plan_reference.md` returns nothing.

### Step 5.26 — reference/implementation_plan_reference.md: Step 2 mechanical-plan — drop the Quick-path `spec.md` code-shapes alternative

**Operation:** EDIT
**File:** `reference/implementation_plan_reference.md`
**Locate:**
```
- **CODING_STANDARDS mapping** — each applicable `.shamt-core/project-specific-files/CODING_STANDARDS.md` rule maps to a step or explicit N/A in `## CODING_STANDARDS Compliance` (saying it was read is insufficient).
```
Note: this site has no Quick/Standard reference — confirm via the verification below; the Step 2 prose itself carries none. The whole-file sweep below catches any residual.
**Replace:** (no replacement — site confirmed clean; see Phase notes for the whole-file residual sweep)
**Verification:** whole-file sweep `grep -nE "Quick|Standard|Build Checklist" reference/implementation_plan_reference.md` returns no residual hits after Steps 5.23–5.25 land. (If the sweep surfaces an unanticipated site, halt and report `PLAN-BLOCKER`.)

### Step 5.27 — reference/rebaseline_protocol.md: add the mandatory test plans to the re-baseline artifact set (steps 4 + 7)

**Operation:** EDIT
**File:** `reference/rebaseline_protocol.md`
**Locate:**
```
4. Create `spec_vN.md` and `context_vN.md`, carrying forward only still-valid material.
5. Record prior baseline and current code state in `context_vN.md`.
6. Validate the new spec/context pair.
7. Create `implementation_plan_vN.md` and any phase files needed.
8. Validate the new plan.
```
**Replace:**
```
4. Create `spec_vN.md` and `context_vN.md`, carrying forward only still-valid material.
5. Record prior baseline and current code state in `context_vN.md`.
6. Validate the new spec/context pair.
7. Create `implementation_plan_vN.md` and any phase files needed, plus the mandatory spec-derived test plans: `user_test_plan_vN.md` always, and `testing_plan_vN.md` when `TESTING_STANDARDS.md` declares automated suites.
8. Validate the new plan and test plan(s).
```
**Verification:** `grep -n "user_test_plan_vN.md" reference/rebaseline_protocol.md` returns one line; `grep -n "testing_plan_vN.md when \`TESTING_STANDARDS.md\` declares automated suites" reference/rebaseline_protocol.md` returns one line; gate labels in step 10 (`Resume at Gate 2b, then Gate 3`) are unchanged — `grep -n "Resume at Gate 2b, then Gate 3" reference/rebaseline_protocol.md` still returns one line.

### Step 5.28 — reference/epic_status_board.md: renumber the Released-trigger phase ref (/e8 → /e9)

**Operation:** EDIT
**File:** `reference/epic_status_board.md`
**Locate:**
```
4. **Released** — the story's `ticket.md` carries `**Status: Done**` (written by `/e8-finalize-story`).
```
**Replace:**
```
4. **Released** — the story's `ticket.md` carries `**Status: Done**` (written by `/e9-finalize-story`).
```
**Verification:** `grep -n "/e8-finalize-story" reference/epic_status_board.md` returns nothing.

### Step 5.29 — reference/epic_status_board.md: renumber the Building-derivation artifact mention (add user_test_plan; keep spec/plan)

**Operation:** EDIT
**File:** `reference/epic_status_board.md`
**Locate:**
```
3. **Building** — Engineer-flow artifacts are present under the story folder (e.g. `spec.md`, `implementation_plan.md`) and the story is **not** yet finalized.
```
**Replace:**
```
3. **Building** — Engineer-flow artifacts are present under the story folder (e.g. `spec.md`, `implementation_plan.md`, `user_test_plan.md`) and the story is **not** yet finalized.
```
**Verification:** `grep -n "\`user_test_plan.md\`) and the story is" reference/epic_status_board.md` returns one line.

### Step 5.30 — reference/epic_status_board.md: collapse the auto-refresh hook list to renumbered phases (/e4→/e5 Build; /e8→/e9 Released)

**Operation:** EDIT
**File:** `reference/epic_status_board.md`
**Locate:**
```
- **Auto-refresh hooks** — transition commands re-derive the parent epic's `STATUS.md` after their own work, so the rollup stays live: `/pe3-decompose` (new features → New), `/pf3-decompose` (new stories → New), the `-validate` stage `/pe2-validate` / `/pf2-validate` / `/ps2-validate` (epic / feature / story → Validated), `/e4-execute-plan` (story → Building), `/e8-finalize-story` (story → Released; feature rollup recomputed).
```
**Replace:**
```
- **Auto-refresh hooks** — transition commands re-derive the parent epic's `STATUS.md` after their own work, so the rollup stays live: `/pe3-decompose` (new features → New), `/pf3-decompose` (new stories → New), the `-validate` stage `/pe2-validate` / `/pf2-validate` / `/ps2-validate` (epic / feature / story → Validated), `/e5-execute-plan` (story → Building), `/e9-finalize-story` (story → Released; feature rollup recomputed).
```
**Verification:** `grep -n "/e4-execute-plan\|/e8-finalize-story" reference/epic_status_board.md` returns nothing; `grep -n "/e5-execute-plan\` (story → Building), \`/e9-finalize-story\`" reference/epic_status_board.md` returns one line; whole-file sweep `grep -nE "Quick|Standard|/e[4-8][^-]|/e8-|/e4-|manual" reference/epic_status_board.md` returns no residual hits.

Note: `reference/epic_status_board.md` carries the four-state story-derivation precedence (Steps 5.28–5.29) and the auto-refresh hook list (Step 5.30); it does **not** carry a Quick/Standard artifact→phase *cascade* table (that lives only in the README phase-detection table, row 57). The proposal's row 47 "collapse the cascade" instruction is satisfied here by keeping this file's state-derivation aligned to the uniform 9-phase flow — there is no two-column Quick/Standard table in this file to collapse. The cascade-collapse mirror is verified against the README in Phase notes.

### Step 5.31 — reference/audit_dimensions.md: D11 example — renumber the "(was X)" stale-parenthetical illustration scope

Note: D11's text ("no leftover migration notes or stale "(was X)" parentheticals") is generic and needs no Engineer-renumber edit. The Engineer-specific Quick/Standard sites in this file are the D7 canonical-term table (Step 5.32), the D7 "simple finding" example that names "Quick path" as the canonical term (Step 5.33a), the D2-boundary "Phase 4" example (Step 5.33), and the "Known exceptions" phase-count note (Step 5.34). This step records that D11 was inspected and is clean.

**Operation:** (no-op inspection — see Phase notes)
**Verification:** `grep -n "Quick/Standard\|Quick path\|Standard path" reference/audit_dimensions.md` after Steps 5.32–5.33 land returns only intentional historical-context hits, if any — see those steps' verifications.

### Step 5.32 — reference/audit_dimensions.md: D7 canonical-term table — retire the Quick/Standard story-tier row, fix Phase 4 → Phase 5 (Build)

**Operation:** EDIT
**File:** `reference/audit_dimensions.md`
**Locate:**
```
| Concept | Canonical term | Never |
|---------|----------------|-------|
| Story complexity tier | Quick / Standard | Small / Full (those are v1 lane names) |
| Phase 4 | Build | Implement |
| Role flows | Engineer flow / Product Owner (PO) flow | "lite mode" / "full mode" |
| An audit observation | finding (audit) / issue (Pattern 1) | *interchangeable by design — not a violation* |
```
**Replace:**
```
| Concept | Canonical term | Never |
|---------|----------------|-------|
| Phase 5 | Build | Implement |
| Role flows | Engineer flow / Product Owner (PO) flow | "lite mode" / "full mode" |
| An audit observation | finding (audit) / issue (Pattern 1) | *interchangeable by design — not a violation* |
```
**Verification:** `grep -n "Story complexity tier | Quick / Standard\|| Phase 4 | Build | Implement |" reference/audit_dimensions.md` returns nothing; `grep -n "| Phase 5 | Build | Implement |" reference/audit_dimensions.md` returns one line.

### Step 5.33 — reference/audit_dimensions.md: D2-boundary example — fix "Phase 4" → "Phase 5" (Build)

**Operation:** EDIT
**File:** `reference/audit_dimensions.md`
**Locate:**
```
A command body that says "2 consecutive clean rounds" while the rules file's Pattern 1 says "1 primary clean + sub-agent" is **D2**. Two command bodies that disagree with *each other* about whether the audit needs a sub-agent is **D9**. The word "Implement" used where the canonical phase name is "Build" is **D7**.
```
**Replace:**
```
A command body that says "2 consecutive clean rounds" while the rules file's Pattern 1 says "1 primary clean + sub-agent" is **D2**. Two command bodies that disagree with *each other* about whether the audit needs a sub-agent is **D9**. The word "Implement" used where the canonical Phase-5 name is "Build" is **D7**.
```
**Verification:** `grep -n "the canonical Phase-5 name is \"Build\"" reference/audit_dimensions.md` returns one line.

### Step 5.33a — reference/audit_dimensions.md: D7 "simple finding" example — replace the now-retired "Quick path" canonical-term illustration

**Operation:** EDIT
**File:** `reference/audit_dimensions.md`
**Locate:**
```
| D7: one body writes "Small Story Lane" where every other body says "Quick path" | Normalizing to the single canonical term; no judgment. |
```
**Replace:**
```
| D7: one body writes "Implement" where every other body says "Build" | Normalizing to the single canonical term; no judgment. |
```
**Verification:** `grep -n "every other body says \"Quick path\"" reference/audit_dimensions.md` returns nothing; `grep -n "one body writes \"Implement\" where every other body says \"Build\"" reference/audit_dimensions.md` returns one line. (The example must not cite a retired term — after Step 5.32 "Quick path" is no longer a canonical term; the surviving D7 canonical pair Implement→Build is used as the illustration instead.)

### Step 5.34 — reference/audit_dimensions.md: rewrite the "Phase count varies by path" known-exception → fixed uniform 9-phase count

**Operation:** EDIT
**File:** `reference/audit_dimensions.md`
**Locate:**
```
- **Phase count varies by path.** Testing is a required phase, so the count is 7 on the Quick path and 8 on the Standard path (Standard adds Phase 3 Plan; the terminal phase is Finalize, `/e8-finalize-story`). D10 treats both as correct — a body must match the count *for the path it describes*, not a single fixed number, and there is no `testing` config flag.
```
**Replace:**
```
- **Fixed nine-phase flow.** The Engineer flow has a single uniform nine-phase sequence — Intake, Spec, Plan, Test Plan, Build, Test, Review, Polish, Finalize (terminal phase `/e9-finalize-story`) — all mandatory for story completion. D10 treats "9 phases" / "e1–e9" as the correct count everywhere; there is no path-dependent count, no Quick/Standard tier, and no `testing` config flag.
```
**Verification:** `grep -n "Phase count varies by path\|count is 7 on the Quick path and 8 on the Standard path\|/e8-finalize-story" reference/audit_dimensions.md` returns nothing; `grep -n "Fixed nine-phase flow\|/e9-finalize-story" reference/audit_dimensions.md` returns the new lines; whole-file sweep `grep -nE "Quick path|Standard path|Quick / Standard|e3b|e5b|manual_test_plan|/e8-finalize" reference/audit_dimensions.md` returns no residual hits.

### Step 5.35 — reference/pr_review_prevention.md: "When To Apply" — drop the Quick/Standard path-selection paragraph

**Operation:** EDIT
**File:** `reference/pr_review_prevention.md`
**Locate:**
```
If one of these surfaces is a Shamt risk trigger, use the **Standard path**. If the story still qualifies for the **Quick path**, record compact evidence and checklist items inline in `spec.md`.
```
**Replace:**
```
When one of these surfaces applies, record the prevention requirement in `spec.md` and the detailed evidence in `context.md`.
```
**Verification:** `grep -n "use the \*\*Standard path\*\*\|qualifies for the \*\*Quick path\*\*" reference/pr_review_prevention.md` returns nothing.

### Step 5.36 — reference/pr_review_prevention.md: "Spec Risk Inventory" Testing row — manual → user wording

**Operation:** EDIT
**File:** `reference/pr_review_prevention.md`
**Locate:**
```
| Testing / test data | Yes / No | Automated tests, manual verification, and synthetic-only test-data obligations are stated. | `context.md` section or researched file path |
```
**Replace:**
```
| Testing / test data | Yes / No | Automated tests, agent-as-user verification, and synthetic-only test-data obligations are stated. | `context.md` section or researched file path |
```
**Verification:** `grep -n "Automated tests, manual verification" reference/pr_review_prevention.md` returns nothing; `grep -n "Automated tests, agent-as-user verification" reference/pr_review_prevention.md` returns one line.

### Step 5.37 — reference/pr_review_prevention.md: "Context Evidence Matrix" + "Plan Prevention Gates" manual-check wording → agent-as-user

**Operation:** EDIT
**File:** `reference/pr_review_prevention.md`
**Locate:**
```
- **Verification and test data:** Which tests or manual checks cover the change? Is all test data synthetic?
```
**Replace:**
```
- **Verification and test data:** Which tests or agent-as-user checks cover the change? Is all test data synthetic?
```
**Verification:** `grep -n "Which tests or manual checks cover the change" reference/pr_review_prevention.md` returns nothing.

### Step 5.38 — reference/pr_review_prevention.md: "Plan Prevention Gates" testing-gate manual wording → agent-as-user

**Operation:** EDIT
**File:** `reference/pr_review_prevention.md`
**Locate:**
```
- Testing gates must name the test command, manual check, or accepted reason for no automated test.
```
**Replace:**
```
- Testing gates must name the test command, agent-as-user check, or accepted reason for no automated test.
```
**Verification:** `grep -n "the test command, manual check, or accepted reason" reference/pr_review_prevention.md` returns nothing; whole-file sweep `grep -nE "Quick path|Standard path|manual verification|manual check" reference/pr_review_prevention.md` returns no residual hits. (Note: "manual check" in the Context-evidence answers `Which tests or manual checks` is removed by Step 5.37; this sweep confirms both Context- and Plan-side manual wording cleared.)

### Step 5.39 — reference/review_categories.md: rewrite the "Quick Path No-Artifact Reviews" section to the uniform review model

**Operation:** EDIT
**File:** `reference/review_categories.md`
**Locate:**
```
## Quick Path No-Artifact Reviews

In the **Quick path**, when no issues are found, creating a separate `review_v1.md` is not required. Instead, document the review directly in chat or append a `## Post-Build Review` section to `spec.md` matching this format:

```markdown
## Post-Build Review

**Plan Alignment:** N/A — Quick path used the spec Build Checklist instead of `implementation_plan.md`.

**Findings:** No issues found. Verified all Build Checklist steps sequentially.
```

If issues are found, the reviewer should create a durable review artifact at `stories/{slug}/feedback/review_v1.md` (the resolved story folder, located per `templates/SHAMT_RULES.template.md` §PO-tree resolution — nested under `epics/.../features/...`) following the standard template and categories.
```
**Replace:**
```
## No-Issue Reviews

When no issues are found, creating a separate `review_v1.md` is not required. Instead, document the review directly in chat or append a `## Post-Build Review` section to `spec.md` matching this format:

```markdown
## Post-Build Review

**Plan Alignment:** Verified against `implementation_plan.md` — all steps executed as planned.

**Findings:** No issues found. Verified all plan steps sequentially.
```

If issues are found, the reviewer should create a durable review artifact at `stories/{slug}/feedback/review_v1.md` (the resolved story folder, located per `templates/SHAMT_RULES.template.md` §PO-tree resolution — nested under `epics/.../features/...`) following the standard template and categories.
```
**Verification:** `grep -n "## Quick Path No-Artifact Reviews\|In the \*\*Quick path\*\*\|N/A — Quick path used the spec Build Checklist\|all Build Checklist steps" reference/review_categories.md` returns nothing; `grep -n "## No-Issue Reviews" reference/review_categories.md` returns one line; whole-file sweep `grep -nE "Quick path|Standard path|Build Checklist|Phase 5|/e[4-8][^-]" reference/review_categories.md` returns no residual hits. (The file has no `/eN` phase pointers to renumber — only the Quick-path section above.)

### Step 5.40 — reference/batch_validation_handoff.md: remove the Quick/Standard path-selection step (Step 2 of the orchestration)

**Operation:** EDIT
**File:** `reference/batch_validation_handoff.md`
**Locate:**
```
2. **Apply `/validate-artifact`'s path selection.** Spawn the adversarial checker for a **Standard-path or risk-triggered** artifact; **skip** it for a **Quick-path artifact with no risk trigger** (that artifact exits after the primary's clean pass, per `/validate-artifact` Step 6 → Step 8). The two producers wired today emit only non-story framework artifacts, which default to Standard, so the checker always runs there; path-awareness matters for a future Quick-capable producer that adopts this reference.
```
**Replace:**
```
2. **Spawn the adversarial checker (always).** Validation is uniform — every artifact gets the adversarial checker after its primary clean pass; there is no path-based skip. (The two producers wired today emit non-story framework artifacts; the checker runs on every artifact a batch carries.)
```
**Verification:** `grep -n "Apply \`/validate-artifact\`'s path selection\|Standard-path or risk-triggered\|Quick-path artifact with no risk trigger" reference/batch_validation_handoff.md` returns nothing.

### Step 5.41 — reference/batch_validation_handoff.md: Step 5 footer-stamp — single uniform footer (drop Quick/Standard footer fork)

**Operation:** EDIT
**File:** `reference/batch_validation_handoff.md`
**Locate:**
```
5. **Stamp the footer.** Each artifact gets its own `/validate-artifact` footer on clean exit (Quick: `Validated YYYY-MM-DD — 1 round (Quick path)`; Standard: `Validated YYYY-MM-DD — N rounds, 1 adversarial sub-agent confirmed`), written by the agent that finished it.
```
**Replace:**
```
5. **Stamp the footer.** Each artifact gets its own `/validate-artifact` footer on clean exit (`Validated YYYY-MM-DD — N rounds, 1 adversarial sub-agent confirmed`), written by the agent that finished it.
```
**Verification:** `grep -n "1 round (Quick path)\|Standard: \`Validated YYYY-MM-DD" reference/batch_validation_handoff.md` returns nothing.

### Step 5.42 — reference/batch_validation_handoff.md: handoff-prompt template — drop the Quick/Standard path-selection step B + Quick footer skip

**Operation:** EDIT
**File:** `reference/batch_validation_handoff.md`
**Locate:**
```
  B. Apply /validate-artifact path selection. If the artifact is Standard-path
     or risk-triggered, continue to C. If it is Quick-path with no risk
     trigger, skip C: have the primary stamp the Quick-path footer and move on.

  C. YOU (the orchestrator) spawn the validation-checker persona (Haiku) for
     {path}, with its dimension list and governing references. The checker
     re-reads cold and reports ANY issue (no one-LOW allowance). On any
     finding: re-spawn a fresh primary for {path} (Step A), then re-run the
     checker. Repeat until the checker replies
     "CONFIRMED: Zero issues found after adversarial review."
     Then stamp the Standard footer.
```
**Replace:**
```
  B. YOU (the orchestrator) spawn the validation-checker persona (Haiku) for
     {path}, with its dimension list and governing references. The checker
     re-reads cold and reports ANY issue (no one-LOW allowance). On any
     finding: re-spawn a fresh primary for {path} (Step A), then re-run the
     checker. Repeat until the checker replies
     "CONFIRMED: Zero issues found after adversarial review."
     Then stamp the footer.
```
**Verification:** `grep -n "Apply /validate-artifact path selection\|skip C: have the primary stamp the Quick-path footer\|Then stamp the Standard footer" reference/batch_validation_handoff.md` returns nothing.

### Step 5.43 — reference/batch_validation_handoff.md: handoff-prompt primary instruction — drop "(path taken — Quick or Standard …)"

**Operation:** EDIT
**File:** `reference/batch_validation_handoff.md`
**Locate:**
```
       - HALT after Step 6 at consecutive_clean = 1. Do NOT spawn a checker.
         Do NOT invoke the /validate-artifact command. Return a short verdict
         (path taken — Quick or Standard — and consecutive_clean reached).
```
**Replace:**
```
       - HALT after Step 6 at consecutive_clean = 1. Do NOT spawn a checker.
         Do NOT invoke the /validate-artifact command. Return a short verdict
         (consecutive_clean reached).
```
**Verification:** `grep -n "path taken — Quick or Standard" reference/batch_validation_handoff.md` returns nothing.

### Step 5.44 — reference/batch_validation_handoff.md: aggregate-report wording — drop the per-artifact "path taken" (uniform now)

**Operation:** EDIT
**File:** `reference/batch_validation_handoff.md`
**Locate:**
```
After all artifacts are done, the orchestrator reports an aggregate result: per artifact, the path taken and whether it exited clean.
```
**Replace:**
```
After all artifacts are done, the orchestrator reports an aggregate result: per artifact, whether it exited clean.
```
**Verification:** `grep -n "per artifact, the path taken and whether it exited clean" reference/batch_validation_handoff.md` returns nothing.

### Step 5.45 — reference/batch_validation_handoff.md: handoff-prompt closing line — drop "the path taken and"

**Operation:** EDIT
**File:** `reference/batch_validation_handoff.md`
**Locate:**
```
After every artifact exits clean, report an aggregate: per artifact, the path
taken and clean/needs-work status.
```
**Replace:**
```
After every artifact exits clean, report an aggregate: per artifact, the
clean/needs-work status.
```
**Verification:** `grep -n "the path$\|taken and clean/needs-work status" reference/batch_validation_handoff.md` returns nothing.

### Step 5.46 — reference/batch_validation_handoff.md: "Relationship to single-artifact validation" — drop the Quick/Standard same-rigor enumeration residue

**Operation:** EDIT
**File:** `reference/batch_validation_handoff.md`
**Locate:**
```
This is an orchestration layer over the ordinary `/validate-artifact` loop, not a different loop. Anything true of a single-artifact run is true of each artifact in a batch: same dimensions, same severity rubric, same exit criteria, same footer, same no-one-LOW-allowance on the checker. See `validation_exit_criteria.md` for the counter logic and the `/validate-artifact` command body for the canonical 8-step process. If in doubt, fall back to validating one artifact at a time — the result is identical, only slower.
```
Note: this paragraph carries no Quick/Standard term — it is already uniform-safe. Confirm via the whole-file sweep below; no edit unless the sweep surfaces residue.
**Replace:** (no replacement — confirmed clean; see Phase notes)
**Verification:** whole-file sweep `grep -nE "Quick|Standard|path taken|path selection" reference/batch_validation_handoff.md` returns no residual hits after Steps 5.40–5.45 land. (If any residual surfaces, halt and report `PLAN-BLOCKER`.)

### Step 5.47 — reference/mermaid_recipes.md: "Putting recipes into specs" — collapse the Standard/Quick spec guidance to a single rule

**Operation:** EDIT
**File:** `reference/mermaid_recipes.md`
**Locate:**
```
## Putting recipes into specs

In a Standard-path `spec.md`, every architectural / data-shape claim that travels through multiple nodes warrants a Mermaid diagram in its own code block. Place the diagram immediately after the prose that introduces it. Keep the prose explanatory; let the diagram carry the structure.

In a Quick-path `spec.md`, prefer ASCII for narrow flows. Escalate to Mermaid the moment a boundary crosses or the node count exceeds ~8.
```
**Replace:**
```
## Putting recipes into specs

In a `spec.md`, every architectural / data-shape claim that travels through multiple nodes warrants a Mermaid diagram in its own code block. Place the diagram immediately after the prose that introduces it. Keep the prose explanatory; let the diagram carry the structure.

Prefer ASCII for narrow flows; escalate to Mermaid the moment a boundary crosses or the node count exceeds ~8 (see `mermaid_diagram_standards.md`).
```
**Verification:** `grep -n "In a Standard-path \`spec.md\`\|In a Quick-path \`spec.md\`" reference/mermaid_recipes.md` returns nothing; whole-file sweep `grep -nE "Quick|Standard|e3b|e5b" reference/mermaid_recipes.md` returns no residual hits.

### Step 5.48 — reference/mermaid_diagram_standards.md: "When to use Mermaid" — drop the Standard-path architecture bullet

**Operation:** EDIT
**File:** `reference/mermaid_diagram_standards.md`
**Locate:**
```
- The story will produce or evolve the diagram as a long-lived artifact (a Mermaid block is editable; an ASCII grid is not)
- The story is on the **Standard path** and touches architecture (any architecture-relevant diagram is Mermaid)
```
**Replace:**
```
- The story will produce or evolve the diagram as a long-lived artifact (a Mermaid block is editable; an ASCII grid is not)
- The story touches architecture (any architecture-relevant diagram is Mermaid)
```
**Verification:** `grep -n "The story is on the \*\*Standard path\*\* and touches architecture" reference/mermaid_diagram_standards.md` returns nothing.

### Step 5.49 — reference/mermaid_diagram_standards.md: "Source contract" render-verification — drop "Standard-path" qualifier

**Operation:** EDIT
**File:** `reference/mermaid_diagram_standards.md`
**Locate:**
```
Render verification: when an existing Mermaid diagram is recorded in `active_artifacts.md`, the Standard-path spec validation confirms it renders (no syntax errors), every node and edge is source-backed, it does not contradict spec / context, and it conforms to this file. See `validation_exit_criteria.md` for the dimension list.
```
**Replace:**
```
Render verification: when an existing Mermaid diagram is recorded in `active_artifacts.md`, the spec validation confirms it renders (no syntax errors), every node and edge is source-backed, it does not contradict spec / context, and it conforms to this file. See `validation_exit_criteria.md` for the dimension list.
```
**Verification:** `grep -n "the Standard-path spec validation confirms it renders" reference/mermaid_diagram_standards.md` returns nothing; whole-file sweep `grep -nE "Quick|Standard|e3b|e5b" reference/mermaid_diagram_standards.md` returns no residual hits. (`stateDiagram-v2` "story phases" mention in the recipe/table is a generic example, not a phase-number reference — no edit.)

### Step 5.50 — reference/trackers/_contract.md: §Required-sections — renumber the `## PR create` / `## PR comment fetch` / `## PR merge` consumer attributions

**Operation:** EDIT
**File:** `reference/trackers/_contract.md`
**Locate:**
```
| `## PR fetch` | CLI to retrieve PR metadata and diff for a given PR ID, parameterized on `{id}`. Used by `/e6-review-changes` when `pr_provider` is set to this tracker. |
| `## PR create` | CLI to push a branch and open a PR. Used by `/e6-review-changes` (story mode) at the end of Review when `pr_provider == github`. Required of every profile so the contract surface stays complete; a profile with no PR concept (`local`) declares `n/a`, and a profile not yet wired (`ado`) may declare the command shape or a not-yet-wired note. |
| `## PR comment fetch` | CLI to fetch the latest PR comments + review threads (keyed by comment-ID). Used by `/e7-resolve-feedback` when a PR is recorded and `pr_provider == github`. Required of every profile (same may-be-stubbed rule as `## PR create`). |
| `## PR merge` | CLI to merge a PR (squash + delete branch), with a mergeability check. Used by `/e8-finalize-story` when `pr_provider == github`. Required of every profile (same may-be-stubbed rule as `## PR create`). |
| `## PR comment posting` | CLI to post a Markdown comment to a PR. **Documented for future use only — `/e6-review-changes` does not post back to external trackers in v2, and `/e7-resolve-feedback` is pull-only (it fetches comments but never replies).** A profile is still required to declare this so the contract surface stays complete for future use. |
```
**Replace:**
```
| `## PR fetch` | CLI to retrieve PR metadata and diff for a given PR ID, parameterized on `{id}`. Used by `/e7-review-changes` when `pr_provider` is set to this tracker. |
| `## PR create` | CLI to push a branch and open a PR. Used by `/e7-review-changes` (story mode) at the end of Review when `pr_provider == github`. Required of every profile so the contract surface stays complete; a profile with no PR concept (`local`) declares `n/a`, and a profile not yet wired (`ado`) may declare the command shape or a not-yet-wired note. |
| `## PR comment fetch` | CLI to fetch the latest PR comments + review threads (keyed by comment-ID). Used by `/e8-resolve-feedback` when a PR is recorded and `pr_provider == github`. Required of every profile (same may-be-stubbed rule as `## PR create`). |
| `## PR merge` | CLI to merge a PR (squash + delete branch), with a mergeability check. Used by `/e9-finalize-story` when `pr_provider == github`. Required of every profile (same may-be-stubbed rule as `## PR create`). |
| `## PR comment posting` | CLI to post a Markdown comment to a PR. **Documented for future use only — `/e7-review-changes` does not post back to external trackers in v2, and `/e8-resolve-feedback` is pull-only (it fetches comments but never replies).** A profile is still required to declare this so the contract surface stays complete for future use. |
```
**Verification:** `grep -nE "/e6-review-changes|/e7-resolve-feedback|/e8-finalize-story" reference/trackers/_contract.md` returns nothing; `grep -c "## PR create\|## PR comment fetch\|## PR merge\|## PR comment posting" reference/trackers/_contract.md` confirms all four section names survive (≥1 each); the four section names + the `n/a`/not-yet-wired/may-be-stubbed contract wording are preserved verbatim apart from the `/eN` renumber.

### Step 5.51 — reference/trackers/_contract.md: §Where-the-contract-is-exercised — renumber the consumer table rows (/e1 unchanged; /e6→/e7, /e7→/e8, /e8→/e9)

**Operation:** EDIT
**File:** `reference/trackers/_contract.md`
**Locate:**
```
| `/e6-review-changes {slug}` | `## PR fetch`, `## Auth failure modes`; `## PR create` (story mode, when `pr_provider == github`). Driven by `pr_provider` (which may differ from `work_item_tracker`). | Phase 6 (Review) |
| `/e7-resolve-feedback {slug}` | `## PR comment fetch` (when a PR is recorded and `pr_provider == github`). Driven by `pr_provider`. | Phase 7 (Polish) |
| `/e8-finalize-story {slug}` | `## PR merge` (when `pr_provider == github`). Driven by `pr_provider`. The work-item close stays `work_item_tracker`-routed, independent of `pr_provider`. | Phase 8 (Finalize) |
```
**Replace:**
```
| `/e7-review-changes {slug}` | `## PR fetch`, `## Auth failure modes`; `## PR create` (story mode, when `pr_provider == github`). Driven by `pr_provider` (which may differ from `work_item_tracker`). | Phase 7 (Review) |
| `/e8-resolve-feedback {slug}` | `## PR comment fetch` (when a PR is recorded and `pr_provider == github`). Driven by `pr_provider`. | Phase 8 (Polish) |
| `/e9-finalize-story {slug}` | `## PR merge` (when `pr_provider == github`). Driven by `pr_provider`. The work-item close stays `work_item_tracker`-routed, independent of `pr_provider`. | Phase 9 (Finalize) |
```
**Verification:** `grep -nE "Phase 6 \(Review\)|Phase 7 \(Polish\)|Phase 8 \(Finalize\)|/e6-review-changes \{slug\}|/e8-finalize-story \{slug\}" reference/trackers/_contract.md` returns nothing; `grep -nE "Phase 7 \(Review\)|Phase 8 \(Polish\)|Phase 9 \(Finalize\)" reference/trackers/_contract.md` returns the three renumbered rows.

### Step 5.52 — reference/trackers/_contract.md: §Purpose intro — renumber the `/e6-review-changes` consumer ref

**Operation:** EDIT
**File:** `reference/trackers/_contract.md`
**Locate:**
```
**Purpose:** Defines what every tracker profile in this directory must declare. Used by `/e1-start-story`, `/pe1-define`, `/pf1-define`, and `/e6-review-changes` to fetch work-item content from an external tracker, map it into the unified artifact shape, and degrade gracefully when the active tracker can't cover a requested work-item type.
```
**Replace:**
```
**Purpose:** Defines what every tracker profile in this directory must declare. Used by `/e1-start-story`, `/pe1-define`, `/pf1-define`, and `/e7-review-changes` to fetch work-item content from an external tracker, map it into the unified artifact shape, and degrade gracefully when the active tracker can't cover a requested work-item type.
```
**Verification:** whole-file sweep `grep -nE "/e6-review-changes|/e7-resolve-feedback|/e8-finalize-story|Phase 6 \(Review\)|Phase 7 \(Polish\)|Phase 8 \(Finalize\)" reference/trackers/_contract.md` returns no residual hits; the `## PR comment posting` standalone paragraph (`\`## PR comment posting\` is declared but not invoked by any v2 consumer.`) is unchanged and still present (`grep -n "is declared but not invoked by any v2 consumer" reference/trackers/_contract.md` returns one line).

### Step 5.53 — reference/trackers/ado.md: §PR-create — renumber the consumer attributions (preserve the not-yet-wired notes + command shapes)

**Operation:** EDIT
**File:** `reference/trackers/ado.md`
**Locate:**
```
`/e6-review-changes` / `/e7-resolve-feedback` / `/e8-finalize-story` invoke `## PR create` / `## PR comment fetch` / `## PR merge` **only when `pr_provider == github`**. On ADO these are **not yet wired** — the consuming commands take no PR action for `pr_provider == ado`. The `az repos pr` command shapes below are recorded for when ADO PR support is added; declaring the sections keeps this profile contract-conformant.
```
**Replace:**
```
`/e7-review-changes` / `/e8-resolve-feedback` / `/e9-finalize-story` invoke `## PR create` / `## PR comment fetch` / `## PR merge` **only when `pr_provider == github`**. On ADO these are **not yet wired** — the consuming commands take no PR action for `pr_provider == ado`. The `az repos pr` command shapes below are recorded for when ADO PR support is added; declaring the sections keeps this profile contract-conformant.
```
**Verification:** `grep -nE "/e6-review-changes|/e7-resolve-feedback|/e8-finalize-story" reference/trackers/ado.md` returns nothing; the not-yet-wired notes survive — `grep -c "not yet wired\|Not yet wired" reference/trackers/ado.md` returns ≥3; `grep -n "az repos pr create\|az repos pr update --id {id} --status completed\|az repos pr comment create" reference/trackers/ado.md` confirms the three PR command shapes survive.

### Step 5.54 — reference/trackers/ado.md: §PR-comment-posting — renumber the `/e6-review-changes` ref (preserve the not-invoked note + command shape)

**Operation:** EDIT
**File:** `reference/trackers/ado.md`
**Locate:**
```
**Not invoked by v2.** Documented for future use only — `/e6-review-changes` produces a local artifact at `code_reviews/` and does not post upstream (resolved open question).

For reference, the command shape is:

```bash
az repos pr comment create --id {pr_id} --content "<markdown body>" --output json
```

Threaded replies use `--parent-comment-id`. When `/e6-review-changes` (or any downstream automation) gains a post-back feature, this is the entry point.
```
**Replace:**
```
**Not invoked by v2.** Documented for future use only — `/e7-review-changes` produces a local artifact at `code_reviews/` and does not post upstream (resolved open question).

For reference, the command shape is:

```bash
az repos pr comment create --id {pr_id} --content "<markdown body>" --output json
```

Threaded replies use `--parent-comment-id`. When `/e7-review-changes` (or any downstream automation) gains a post-back feature, this is the entry point.
```
**Verification:** `grep -n "/e6-review-changes" reference/trackers/ado.md` returns nothing; `grep -c "az repos pr comment create" reference/trackers/ado.md` returns 1 (command shape preserved); the `## PR fetch` `/e6-review-changes` ref inside the diff comment (`# then: ...`) — see Step 5.55.

### Step 5.55 — reference/trackers/ado.md: §PR-fetch — renumber the `/e6-review-changes` diff-usage ref

**Operation:** EDIT
**File:** `reference/trackers/ado.md`
**Locate:**
```
For the diff (used by `/e6-review-changes` when needed):
```
**Replace:**
```
For the diff (used by `/e7-review-changes` when needed):
```
**Verification:** whole-file sweep `grep -nE "/e6-review-changes|/e7-resolve-feedback|/e8-finalize-story" reference/trackers/ado.md` returns no residual hits; the PR-section bodies survive — `grep -nE "az repos pr show|az repos pr create|az repos pr update --id \{id\} --status completed|az repos pr comment create" reference/trackers/ado.md` returns the preserved command shapes; the not-yet-wired notes survive (`grep -c "ot yet wired" reference/trackers/ado.md` ≥3). PAT-scope line ("Pull Request Threads (Read & Write)") is unchanged.

### Step 5.56 — reference/trackers/github.md: §PR-create — renumber the consumer attribution (preserve the push+create command body + confirm-gate note)

**Operation:** EDIT
**File:** `reference/trackers/github.md`
**Locate:**
```
Used by `/e6-review-changes` (story mode) at the end of the Review stage when `pr_provider == github`: push the story branch and open the PR. Confirm-gated by the consuming command (outward action).
```
**Replace:**
```
Used by `/e7-review-changes` (story mode) at the end of the Review stage when `pr_provider == github`: push the story branch and open the PR. Confirm-gated by the consuming command (outward action).
```
**Verification:** `grep -n "Used by \`/e6-review-changes\` (story mode) at the end of the Review stage" reference/trackers/github.md` returns nothing; the `## PR create` command body survives — `grep -n "git push -u origin HEAD\|gh pr create --repo" reference/trackers/github.md` returns the preserved lines.

### Step 5.57 — reference/trackers/github.md: §PR-comment-fetch — renumber the `/e7-resolve-feedback` consumer attribution (preserve pull-only note + command bodies)

**Operation:** EDIT
**File:** `reference/trackers/github.md`
**Locate:**
```
Used by `/e7-resolve-feedback` when a PR is recorded for the story and `pr_provider == github`: fetch the latest PR comments + review threads to fold into the feedback inventory. Pull-only — `/e7` never posts back (see `## PR comment posting`).
```
**Replace:**
```
Used by `/e8-resolve-feedback` when a PR is recorded for the story and `pr_provider == github`: fetch the latest PR comments + review threads to fold into the feedback inventory. Pull-only — `/e8` never posts back (see `## PR comment posting`).
```
**Verification:** `grep -n "Used by \`/e7-resolve-feedback\` when a PR is recorded\|/e7\` never posts back" reference/trackers/github.md` returns nothing; the comment-fetch command bodies survive — `grep -n "gh pr view {id} --repo <org>/<repo> --json comments,reviews\|gh api repos/<org>/<repo>/pulls/{id}/comments --paginate" reference/trackers/github.md` returns both lines.

### Step 5.58 — reference/trackers/github.md: §PR-merge — renumber the `/e8-finalize-story` consumer attribution (preserve mergeability + merge command bodies)

**Operation:** EDIT
**File:** `reference/trackers/github.md`
**Locate:**
```
Used by `/e8-finalize-story` when `pr_provider == github`: merge the story's PR. Confirm-gated by the consuming command (outward, irreversible action), and preceded by a mergeability check.
```
**Replace:**
```
Used by `/e9-finalize-story` when `pr_provider == github`: merge the story's PR. Confirm-gated by the consuming command (outward, irreversible action), and preceded by a mergeability check.
```
**Verification:** `grep -n "Used by \`/e8-finalize-story\` when \`pr_provider == github\`" reference/trackers/github.md` returns nothing; the merge command bodies survive — `grep -n "gh pr view {id} --repo <org>/<repo> --json mergeable,mergeStateStatus,reviewDecision,statusCheckRollup\|gh pr merge {id} --repo <org>/<repo> --squash --delete-branch" reference/trackers/github.md` returns both lines.

### Step 5.59 — reference/trackers/github.md: §PR-comment-posting + §PR-fetch — renumber the `/e6`/`/e7` refs (preserve not-invoked + pull-only notes + command shapes)

**Operation:** EDIT
**File:** `reference/trackers/github.md`
**Locate:**
```
**Not invoked by v2.** Documented for future use only — `/e6-review-changes` produces a local artifact at `code_reviews/` and does not post upstream (resolved open question). `/e7-resolve-feedback` is **pull-only** (see `## PR comment fetch`): it fetches comments and pushes fix commits, but never replies to or resolves threads.
```
**Replace:**
```
**Not invoked by v2.** Documented for future use only — `/e7-review-changes` produces a local artifact at `code_reviews/` and does not post upstream (resolved open question). `/e8-resolve-feedback` is **pull-only** (see `## PR comment fetch`): it fetches comments and pushes fix commits, but never replies to or resolves threads.
```
**Verification:** `grep -n "/e6-review-changes produces a local artifact\|/e7-resolve-feedback is \*\*pull-only\*\*" reference/trackers/github.md` returns nothing; the posting command shapes survive — `grep -n "gh pr comment {id} --repo <org>/<repo> --body\|gh pr review {id} --repo <org>/<repo> --comment --body" reference/trackers/github.md` returns both lines.

### Step 5.60 — reference/trackers/github.md: §PR-comment-posting review-comment note + §PR-fetch diff ref — renumber remaining `/e6` mentions

**Operation:** EDIT
**File:** `reference/trackers/github.md`
**Locate:**
```
# A full review with comments (preferred for /e6-review-changes findings if/when posting is added)
gh pr review {id} --repo <org>/<repo> --comment --body "<markdown body>"
```
**Replace:**
```
# A full review with comments (preferred for /e7-review-changes findings if/when posting is added)
gh pr review {id} --repo <org>/<repo> --comment --body "<markdown body>"
```
**Verification:** `grep -n "preferred for /e6-review-changes findings" reference/trackers/github.md` returns nothing.

### Step 5.61 — reference/trackers/github.md: §PR-fetch diff-usage ref — renumber `/e6-review-changes`

**Operation:** EDIT
**File:** `reference/trackers/github.md`
**Locate:**
```
For the diff (used by `/e6-review-changes`):
```
**Replace:**
```
For the diff (used by `/e7-review-changes`):
```
**Verification:** whole-file sweep `grep -nE "/e6-review-changes|/e7-resolve-feedback|/e8-finalize-story" reference/trackers/github.md` returns no residual hits; the four PR sections + their command bodies survive — `grep -cE "^## PR create$|^## PR comment fetch$|^## PR merge$|^## PR comment posting$" reference/trackers/github.md` returns 4; `grep -n "git push -u origin HEAD\|gh pr merge {id} --repo <org>/<repo> --squash --delete-branch\|gh pr view {id} --repo <org>/<repo> --json comments,reviews" reference/trackers/github.md` confirms create/merge/fetch command bodies all survive; the confirm-gated / pull-only notes survive (`grep -c "Confirm-gated\|pull-only\|Pull-only" reference/trackers/github.md` ≥2).

## Phase notes

### #50 preservation (rows 54–56 — trackers)
The three tracker files at HEAD (post-#50, commit `ca37b5e`) carry the four `## PR create` / `## PR comment fetch` / `## PR merge` / `## PR comment posting` sections with command bodies + consumer attributions + ADO "not-yet-wired" notes. This phase's tracker steps (5.50–5.61) renumber **only** the `/eN` phase pointers (`/e6→/e7` Review, `/e7→/e8` Polish, `/e8→/e9` Finalize) and leave every section header, command body (`git push -u origin HEAD`, `gh pr create`, `gh pr view … --json comments,reviews`, `gh api … /pulls/{id}/comments --paginate`, `gh pr view … --json mergeable,…`, `gh pr merge … --squash --delete-branch`, `gh pr comment`, `gh pr review`; `az repos pr create/update/comment create`), pull-only / confirm-gated / not-invoked / not-yet-wired note, and PAT-scope line intact. Each tracker step carries an explicit "survives" grep so a dropped #50 body is caught at execution. `reference/trackers/local.md` needs **no change** — it has no references to any *renumbered* Engineer phase (its `## PR create` / `## PR comment fetch` / `## PR merge` bodies are `n/a — local has no PR.` / `n/a` with no `/eN` pointer). Its only Engineer-command references are `/e1-start-story` (Phase 1, unchanged by this proposal), so the renumber (`/e6→/e7`, `/e7→/e8`, `/e8→/e9`) touches nothing here; confirmed by `grep -nE "/e[4-9][a-z-]" reference/trackers/local.md` returning nothing (a `/e[1-9]` scan does hit the unchanged `/e1-start-story` mentions, which are not renumbered). It is deliberately not given a step.

### Cascade-collapse (row 47) — mirror of the README phase-detection table (row 57)
`reference/epic_status_board.md` does **not** contain a two-column Quick(7)/Standard(8) artifact→phase *cascade table* — that table lives only in `README.md` (~lines 338–348, row 57). This file's row-47 obligations are: (a) renumber the transition-trigger phase refs feeding the Building/Released derivation (`/e4-execute-plan`→`/e5-execute-plan` Building; `/e8-finalize-story`→`/e9-finalize-story` Released — Steps 5.28, 5.30), and (b) update artifact names to the uniform flow (add `user_test_plan.md` to the Building-derivation signal — Step 5.29). The single uniform 9-phase artifact→phase mapping is authored by row 57 in the README; for cross-file consistency (D2/D10) it is, after row 57 lands: `**Status: Done**`→P9 Finalize · `feedback/addressed_feedback.md`→P8 Polish · `feedback/review_v*.md`→P7 Review · `agent_test_session.md`→P6 Test · `user_test_plan.md` or `testing_plan.md`→P4 Test Plan · `implementation_plan.md`→P3 Plan · `spec.md`→P2 Spec · `ticket.md`→P1 Intake (P5 Build has no artifact). This phase keeps epic_status_board.md's state-derivation precedence aligned to that mapping; it does not duplicate the cascade table into this file.

### Inspection-only / no-op steps
Steps 5.22, 5.26, 5.31, and 5.46 are inspection-only confirmations (the named site is already uniform-safe or carries no Quick/Standard term). Each records a verification grep so the index can confirm the site was checked; none performs an edit. If any of their whole-file residual sweeps surfaces an unanticipated Quick/Standard / `/eN` / `manual` hit, the executing agent must halt and report `PLAN-BLOCKER` rather than improvise an edit.

### Anchor stability
No reference file in this phase renames a markdown anchor that an inbound link targets. Step 5.21 retitles `## Path-specific spec/context split (Step 5)` → `## Spec/context split (Step 5)` in `spec_protocol_reference.md`, but the only inbound link in that file (`#step-5--prevention-requirements-per-high-risk-surface`, cited from the Step 5 prose) points at the **prevention-requirements** section heading, which is unchanged — so no link target breaks. (The SHAMT_RULES `#optional-post-build-artifact` anchor flagged in the proposal's Validation Considerations is a *template* anchor, row 31 — out of this phase's scope.)

---
Validated 2026-06-21 — 2 rounds, 1 adversarial sub-agent confirmed
