---
name: e5-execute-tests
description: >
  Run the required Phase 5 (Test) of the Shamt Engineer flow. Hands off the validated testing plan to the test-executor
  Haiku persona, watches for failures, routes Story-bug / Test-bug / Spec-gap
  diagnoses, and blocks until every scenario / step PASSes. Phase 5 is required —
  it always runs the agent-as-user execution via the user-simulator persona and the
  automated suites via test-executor when TESTING_STANDARDS.md declares them; a failure
  routes to /e7 with a required root-cause section. Invoke when the user wants to run the tests, execute
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

Mirrors the `/e5-execute-tests {slug}` slash command. Same canonical body, two host wirings. Resolve the story folder per `templates/SHAMT_RULES.template.md` §PO-tree resolution (tree-wide glob + legacy-flat fallback).

## Protocol

Follow the canonical `/e5-execute-tests` command body verbatim — see [`commands/e5-execute-tests.md`](../../commands/e5-execute-tests.md).

## Recommended models

- Orchestration: Balanced (Sonnet).
- Execution: Cheap (Haiku) via [`agents/test-executor.md`](../../agents/test-executor.md).

See [`reference/model_selection.md`](../../../../../reference/model_selection.md).

## Exit criteria

Every row in `## Results Log` is `PASS`; every documented failure has a `Re-run result: PASS`; the executor reported `All steps passed. Results logged.`. No `Pending`, `Blocked`, or `Failed` row remains.

---
Validated 2026-05-28 — 4 rounds, 1 adversarial sub-agent confirmed (Phase 6 implementation loop)

<!-- Managed by Shamt — do not edit. Regenerate from shamt-core/host/templates/claude/skills/e5-execute-tests/SKILL.md. -->
