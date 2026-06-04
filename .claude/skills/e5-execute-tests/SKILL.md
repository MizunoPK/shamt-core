---
name: e5-execute-tests
description: >
  Run Phase 5 (Test) of the Shamt Engineer flow when .shamt-core/shamt-config.json sets
  testing: "enabled". Hands off the validated testing plan to the test-executor
  Haiku persona, watches for failures, routes Story-bug / Test-bug / Spec-gap
  diagnoses, and blocks until every step PASSes. No-op with a clear message
  when testing is disabled. Invoke when the user wants to run the tests, execute
  the test plan, run phase 5, or verify the build via automated tests.
triggers:
  - "execute the tests"
  - "run the test plan"
  - "run phase 5"
  - "run tests for"
  - "verify with automated tests"
  - "execute the testing plan"
  - "kick off the test phase"
---

## Overview

Mirrors the `/e5-execute-tests {slug}` slash command. Same canonical body, two host wirings.

## Protocol

Follow the canonical `/e5-execute-tests` command body verbatim — see [`commands/e5-execute-tests.md`](../../commands/e5-execute-tests.md). Summary:

1. **No-op gate** — if `.shamt-core/shamt-config.json` sets `testing: "disabled"`, print the one-line skip message and exit. Do not touch any file.
2. **Resolve** — apply the active-artifact pointer; confirm the active spec, plan, and testing artifact (full `testing_plan.md` or the spec's `### Quick path inline test checklist`) have validation footers. Halt if Build has not run.
3. **Hand off to the `test-executor`** — Haiku persona ([`agents/test-executor.md`](../../agents/test-executor.md)). The executor runs each step's exact invocation, logs `PASS / FAIL / BLOCKED / PENDING` into the artifact's `## Results Log`, and fills `## Failure Diagnosis` on the first failure.
4. **Monitor and route** —
   - `All steps passed. Results logged.` → continue.
   - `Step N failed: Story bug` → re-engage the architect/builder loop via `/e4-execute-plan` or an inline Quick-path fix; re-invoke this command.
   - `Step N failed: Test bug` → patch via `/e3b-write-testing-plan`; re-validate; re-invoke.
   - `Step N failed: Spec gap` → invoke the **Re-baseline Protocol**; do not patch the spec in place.
   - `Plan defect / ambiguous` → patch via `/e3b-write-testing-plan`; re-validate; re-invoke.
   - `Environment blocked` → resolve externally; re-invoke. **No "document and skip" disposition** — Phase 5 blocks until every step passes (§1.14).
5. **Post-execution** — walk `## Results Log`: every row must read `PASS`. Confirm `## Failure Diagnosis` rows have `Re-run result: PASS`. Run any `## Shared Teardown`.
6. **Exit** — suggest `/clear` + `/e6-review-changes {slug}` (Phase 6). Suggest `/e5b-write-manual-testing-plan {slug}` for scope automated tests cannot cover.

## Recommended models

- Orchestration: Balanced (Sonnet).
- Execution: Cheap (Haiku) via [`agents/test-executor.md`](../../agents/test-executor.md).

See [`reference/model_selection.md`](../../../../../reference/model_selection.md).

## Exit criteria

Every row in `## Results Log` is `PASS`; every documented failure has a `Re-run result: PASS`; the executor reported `All steps passed. Results logged.`. No `Pending`, `Blocked`, or `Failed` row remains.

---
Validated 2026-05-28 — 4 rounds, 1 adversarial sub-agent confirmed (Phase 6 implementation loop)

<!-- Managed by Shamt — do not edit. Regenerate from shamt-core/host/templates/claude/skills/e5-execute-tests/SKILL.md. -->
