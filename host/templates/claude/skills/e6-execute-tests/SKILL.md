---
name: e6-execute-tests
description: >
  Run the required Phase 6 (Test) of the Shamt Engineer flow. Blocks until every
  scenario / step PASSes. Phase 6 is required — the user-simulator persona
  EXECUTES user_test_plan.md (the agent-as-user scenarios authored in Phase 4) and
  the test-executor Haiku persona executes testing_plan.md when TESTING_STANDARDS.md
  declares automated suites; it routes Story-bug / Test-bug / Spec-gap diagnoses,
  and a failure routes to /e8 with a required root-cause section. Invoke when the
  user wants to run the tests, execute the test plan, run phase 6, or verify the
  build via the test plans.
triggers:
  - "execute the tests"
  - "run the test plan"
  - "run phase 6"
  - "run tests for"
  - "verify with automated tests"
  - "execute the testing plan"
  - "kick off the test phase"
---

## Overview

Mirrors the `/e6-execute-tests {slug}` slash command. Same canonical body, two host wirings. Resolve the story folder per `templates/SHAMT_RULES.template.md` §PO-tree resolution (tree-wide glob + legacy-flat fallback).

## Protocol

Follow the canonical `/e6-execute-tests` command body verbatim — see [`commands/e6-execute-tests.md`](../../commands/e6-execute-tests.md).

## Recommended models

- Orchestration: Balanced (Sonnet).
- Execution: Cheap (Haiku) via [`agents/test-executor.md`](../../agents/test-executor.md).

See [`reference/model_selection.md`](../../../../../reference/model_selection.md).

## Exit criteria

Every row in `## Results Log` is `PASS`; every documented failure has a `Re-run result: PASS`; the executor reported `All steps passed. Results logged.`. No `Pending`, `Blocked`, or `Failed` row remains.

---
Validated 2026-05-28 — 4 rounds, 1 adversarial sub-agent confirmed (Phase 6 implementation loop)

<!-- Managed by Shamt — do not edit. Regenerate from shamt-core/host/templates/claude/skills/e6-execute-tests/SKILL.md. -->
