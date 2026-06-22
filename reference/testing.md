# Testing Reference

Expanded detail for Shamt's **mandatory** testing stages. `SHAMT_RULES.template.md` keeps the normative
contract (Phase 4 Test Plan and Phase 6 Test are both mandatory; what each runs; the bug→feedback rule);
this file holds the worked detail. Mirrors `reference/implementation_plan_reference.md` /
`reference/spec_protocol_reference.md`.

## Source of truth: TESTING_STANDARDS.md

Each child project carries `.shamt-core/project-specific-files/TESTING_STANDARDS.md` (seeded at init,
completed via the project-doc completion prompt). It **replaces** the old `testing: enabled/disabled`
config flag: it declares the **agent-as-user** driving procedures (always applicable) and whether
**automated suites** are **Present** or **None**. `/e6-execute-tests` and `/e4-write-test-plan`
key off this doc, not a config flag.

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

## Bug-as-feedback loop (test failure → Polish)

A Phase-6 `FAIL` is a **post-implementation bug**. It is treated as a feedback comment:

1. **Document** it as a feedback item (the failing scenario + observed-vs-expected evidence).
2. **Route to `/e8-resolve-feedback`** — the fix is applied and logged in `addressed_feedback.md`.
3. **Required root-cause section** — `addressed_feedback.md` must record **which phase let the bug
   through** (Spec — missing requirement; Plan — missing/incorrect step; Build — execution defect) and
   the **prevention** (what would have caught it earlier).
4. **Re-run Phase 6 to green** before Finalize. Finalize (`/e9`) blocks until Test PASSes.

## User test plan

`/e4-write-test-plan {slug}` produces `user_test_plan.md` — the **agent-as-user scenario plan**, a
spec-derived step-by-step script the `user-simulator` **executes** in Phase 6 (driving the project as a
real user). It is **mandatory** on every story (always produced in Phase 4) and is the executed source
for the Phase-6 agent-as-user run — not an on-demand human walkthrough. The per-run results are logged
separately in `agent_test_session.md`.
