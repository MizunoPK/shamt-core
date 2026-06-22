---
name: e3-plan-implementation
description: >
  Run Phase 3 (Plan) of the Shamt Engineer flow — mandatory for every story —
  turning an approved spec into a mechanical, validated implementation plan ready
  for builder handoff at Gate 3. Testing-plan authoring moves to /e4-write-test-plan
  (the next phase). Invoke when the user wants to plan the implementation, draft the
  implementation plan, run the plan phase, prepare the builder handoff, or
  break the spec into mechanical steps.
triggers:
  - "plan the implementation"
  - "implementation plan for"
  - "draft the implementation plan"
  - "run the plan phase"
  - "make the plan mechanical"
  - "prepare the builder handoff"
  - "break the spec into steps"
  - "plan this story"
---

## Overview

Mirrors the `/e3-plan-implementation {slug}` slash command. Same canonical body, two host wirings.

## Protocol

Follow the canonical `/e3-plan-implementation` command body verbatim — see [`commands/e3-plan-implementation.md`](../../commands/e3-plan-implementation.md).

## Recommended models

- Authoring: Balanced (Sonnet).
- Validation loop primary: Reasoning (Opus). Sub-agent: Cheap (Haiku) via `validation-checker`.

See [`reference/model_selection.md`](../../../../../reference/model_selection.md).

## Exit criteria

Validated `implementation_plan.md` approved at Gate 3; Open Questions empty or deferred with reason. Test-plan authoring (`user_test_plan.md` always, `testing_plan.md` when TESTING_STANDARDS.md declares suites) is the next phase, `/e4-write-test-plan`. Builder handoff is unconditional after Gate 3 — the architect plans, the cheap-tier builder executes.

---
Validated 2026-05-28 — 2 rounds, 1 adversarial sub-agent confirmed (Phase 5 implementation loop)

<!-- Managed by Shamt — do not edit. Regenerate from shamt-core/host/templates/claude/skills/e3-plan-implementation/SKILL.md. -->
