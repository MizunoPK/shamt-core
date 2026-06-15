# Testing Reference

Expanded detail for Shamt's **required** testing stage. `SHAMT_RULES.template.md` keeps the normative
contract (Phase 5 is required; what it runs; the bug→feedback rule); this file holds the worked detail.
Mirrors `reference/implementation_plan_reference.md` / `reference/spec_protocol_reference.md`.

## Source of truth: TESTING_STANDARDS.md

Each child project carries `.shamt-core/project-specific-files/TESTING_STANDARDS.md` (seeded at init,
completed via the project-doc completion prompt). It **replaces** the old `testing: enabled/disabled`
config flag: it declares the **agent-as-user** driving procedures (always applicable) and whether
**automated suites** are **Present** or **None**. `/e5-execute-tests` and `/e3b-write-testing-plan`
key off this doc, not a config flag.

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

## Bug-as-feedback loop (test failure → Polish)

A Phase-5 `FAIL` is a **post-implementation bug**. It is treated as a feedback comment:

1. **Document** it as a feedback item (the failing scenario + observed-vs-expected evidence).
2. **Route to `/e7-resolve-feedback`** — the fix is applied and logged in `addressed_feedback.md`.
3. **Required root-cause section** — `addressed_feedback.md` must record **which phase let the bug
   through** (Spec — missing requirement; Plan — missing/incorrect step; Build — execution defect) and
   the **prevention** (what would have caught it earlier).
4. **Re-run Phase 5 to green** before Finalize. Finalize (`/e8`) blocks until Test PASSes.

## Manual test plan

`/e5b-write-manual-testing-plan {slug}` produces `manual_test_plan.md` — an on-demand **human-walkthrough**
for scenarios the agent cannot simulate (real UI, cloud infra, external integrations, multi-user). Per-story,
on demand; not part of the required Phase-5 pass.
