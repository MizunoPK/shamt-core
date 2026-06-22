---
name: e4-write-test-plan
description: >
  Run Phase 4 (Test Plan) of the Shamt Engineer flow — mandatory for every story.
  Authors stories/{slug}/user_test_plan.md always (agent-as-user scenarios the
  Phase-6 user-simulator executes after the build) and stories/{slug}/testing_plan.md
  when TESTING_STANDARDS.md declares automated suites; runs the open-questions
  dialog + a Pattern-1 validation loop on each. Merges the two retired
  test-planning sub-phases (automated-suite planning + agent-as-user planning).
  Invoke when the user wants to write the test
  plans for a story, draft the agent-as-user test plan, plan Phase 6 testing, or
  author user_test_plan.md / testing_plan.md.
triggers:
  - "write the test plan"
  - "write the test plans"
  - "draft the user test plan"
  - "draft the testing plan"
  - "plan the tests for"
  - "run the test-plan phase"
  - "author user_test_plan and testing_plan"
  - "test plan for"
---

## Overview

Mirrors the `/e4-write-test-plan {slug}` slash command. Same canonical body, two host wirings. Resolve the story folder per `templates/SHAMT_RULES.template.md` §PO-tree resolution (tree-wide glob + legacy-flat fallback). The merged Phase-4 Test Plan stage: `user_test_plan.md` is always produced; `testing_plan.md` is produced when `TESTING_STANDARDS.md` declares automated suites.

## Protocol

Follow the canonical `/e4-write-test-plan` command body verbatim — see [`commands/e4-write-test-plan.md`](../../commands/e4-write-test-plan.md).

## Recommended models

- Authoring: Balanced (Sonnet).
- Validation loop primary: Reasoning (Opus). Sub-agent: Cheap (Haiku) via [`agents/validation-checker.md`](../../agents/validation-checker.md).

See [`reference/model_selection.md`](../../../../../reference/model_selection.md).

## Exit criteria

Validated `user_test_plan.md` exists (always); `testing_plan.md` exists with a validation footer when `TESTING_STANDARDS.md` declares automated suites; `## Open Questions` empty or deferred with reason. Phase 6 (Test) executes these plans and **blocks until every scenario / step passes** — see [`SHAMT_RULES.template.md`](../../../../../templates/SHAMT_RULES.template.md).

---

<!-- Managed by Shamt — do not edit. Regenerate from shamt-core/host/templates/claude/skills/e4-write-test-plan/SKILL.md. -->
