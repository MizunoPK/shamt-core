# Testing Plan: {slug}

**Note:** Produced during Phase 4 (Test Plan) when `.shamt-core/project-specific-files/TESTING_STANDARDS.md` declares automated suites — the automated half of the mandatory Test Plan stage (the agent-as-user `user_test_plan.md` is the always-produced half). Executed during Phase 6 (Test) by the `test-executor` persona (see `reference/model_selection.md` — Haiku tier).

**Created:** [Date]
**Story:** stories/{slug}/
<!-- Paths are relative to the resolved story folder (located per templates/SHAMT_RULES.template.md §PO-tree resolution; the folder nests under epics/.../features/.../). -->
**Spec:** stories/{slug}/spec.md (or `spec_vN.md` for re-baselined stories)
**Implementation Plan:** stories/{slug}/implementation_plan.md
**Baseline:** v1
**Baseline status:** Active

---

## Test Strategy

[Summarize the coverage shape for this story. Cite specific sections of the spec's Test Strategy and the project's `.shamt-core/project-specific-files/CODING_STANDARDS.md` / `.shamt-core/project-specific-files/ARCHITECTURE.md` for runner choice, file naming, fixture patterns, assertion style.]

- **End-to-end:** [Scenarios that exercise the full path; or N/A reason]
- **Integration:** [Components and boundaries crossed; or N/A reason]
- **Unit:** [Modules/functions covered; or N/A reason]
- **Test runner:** [Project test command — e.g., `pytest`, `npm test`, `go test ./...`]
- **Test file conventions:** [Per `.shamt-core/project-specific-files/CODING_STANDARDS.md` — naming, location, fixture/setup patterns]
- **Project assumptions checked:** [e.g., "Test DB seeded from `fixtures/`", "Mocks per `tests/mocks.py`"]

---

## Test Plan Steps

Each step is one runnable test or test group, with the exact invocation and a binary pass criterion. Steps are listed in execution order. Setup/teardown that applies to all steps lives in the next section.

### Step 1: [Test name]
**Type:** [unit | integration | e2e]
**File:** `path/to/test_file.ext`
**Invocation:** `<exact command>`
**Pass criterion:** [What output proves the test passes — exit code, output line, assertion count.]
**Covers:** [Which spec requirement(s) or plan step(s) this test verifies.]

---

### Step 2: [Test name]
**Type:** [unit | integration | e2e]
**File:** `path/to/test_file.ext`
**Invocation:** `<exact command>`
**Pass criterion:** [...]
**Covers:** [...]

---

[Add more steps as needed]

---

## Shared Setup / Teardown

[Required if any step assumes pre-existing state — fixtures loaded, services started, DB migrated, env vars set. Otherwise: `N/A — each step is self-contained.`]

- **Setup:**
  - [Command or manual step]
- **Teardown:**
  - [Command or manual step]

---

## Results Log

Populated by the `test-executor` during Phase 6. Each step records pass/fail, evidence, and (if failed) the failure-diagnosis pointer.

| Step | Status | Run at | Evidence | Notes |
|------|--------|--------|----------|-------|
| 1 | PENDING | — | — | — |
| 2 | PENDING | — | — | — |

**Status values:** `PENDING`, `PASS`, `FAIL`, `BLOCKED`. Phase 6 blocks until every step is `PASS` (the Phase-6 blocking rule — no exceptions or documented deferrals).

---

## Failure Diagnosis

Populated only when one or more steps fail. The `test-executor` distinguishes story failures (the implementation is wrong) from infrastructure flakiness (environment, fixture, runner config) and records the root cause before patching. If diagnosis reveals a spec/plan gap, the re-baseline protocol applies — stop and re-baseline rather than patching misleadingly.

### Failure 1: [Step N — Test name]
**Observed:** [What actually happened — exit code, stack trace excerpt, assertion failure.]
**Suspected cause:** [Story bug / infrastructure / fixture / test bug / spec gap]
**Root cause analysis:** [What was traced and ruled in/out. Reference relevant files.]
**Resolution:** [Code patch / fixture fix / re-baseline trigger. Link to commit or to `active_artifacts.md` update.]
**Re-run result:** [Status after fix.]

---

## Open Questions

[Only unresolved questions about test design or coverage that block planning. Per the open-questions iterative-dialog principle in `templates/SHAMT_RULES.template.md`, surface each question to the user one at a time and update the plan with each answer before moving on. Code-research every question first.]

---

## Validation

This plan is validated via Pattern 1 (Validation Loops) before execution. Dimensions mirror `implementation_plan.template.md`:

- **Step clarity** — Each step has an unambiguous invocation and a binary pass criterion.
- **Executability** — Commands resolve in the project's test environment; pre-existing state is documented under Shared Setup.
- **Verification completeness** — Every spec requirement and every approval-relevant plan step maps to at least one test step, or has an explicit `Not testable here — covered by user_test_plan.md` reason.

Severity ladder for findings: see `reference/severity_classification.md`. Exit: one primary clean round + one adversarial sub-agent confirmation (uniform Pattern 1 exit — always).

---
[Append the validation footer only after Pattern 1 completes for the testing plan.]
