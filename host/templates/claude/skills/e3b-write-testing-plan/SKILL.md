---
name: e3b-write-testing-plan
description: >
  Plan sub-phase invoked when .shamt-core/project-specific-files/TESTING_STANDARDS.md declares automated suites.
  Produces and validates either the inline test checklist in spec.md (Quick
  path, ≤5 steps, no new test file) or the full testing_plan.md artifact
  (Standard path, or Quick path with larger scope). Invoke when the user wants
  to draft or update the testing plan for a story, write a test plan, plan
  Phase 5 testing, or escalate an inline checklist to a full artifact. No-op
  with a clear message when TESTING_STANDARDS.md declares no automated suites.
triggers:
  - "write the testing plan"
  - "draft the testing plan"
  - "plan the tests for"
  - "make a test plan for"
  - "testing plan for"
  - "escalate inline test checklist"
  - "update the testing plan"
---

## Overview

Mirrors the `/e3b-write-testing-plan {slug}` slash command. Same canonical body, two host wirings. Invoked by `/e3-plan-implementation` when `TESTING_STANDARDS.md` declares automated suites; also runnable standalone for re-planning.

## Protocol

Follow the canonical `/e3b-write-testing-plan` command body verbatim — see [`commands/e3b-write-testing-plan.md`](../../commands/e3b-write-testing-plan.md).

## Recommended models

- Authoring: Balanced (Sonnet).
- Validation loop primary: Reasoning (Opus). Sub-agent: Cheap (Haiku) via `validation-checker`.

See [`reference/model_selection.md`](../../../../../reference/model_selection.md).

## Exit criteria

Either the spec's inline checklist is populated, or `testing_plan.md` exists with a validation footer; Open Questions empty or deferred with reason. Phase 5 (Test) executes this plan and **blocks until all tests pass** — see [`SHAMT_RULES.template.md`](../../../../../templates/SHAMT_RULES.template.md#testing-phase-5--required).

---
Validated 2026-05-28 — 2 rounds, 1 adversarial sub-agent confirmed (Phase 5 implementation loop)

<!-- Managed by Shamt — do not edit. Regenerate from shamt-core/host/templates/claude/skills/e3b-write-testing-plan/SKILL.md. -->
