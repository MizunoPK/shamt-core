---
name: e4-execute-plan
description: >
  Run Phase 4 (Build) of the Shamt Engineer flow. Standard path hands the
  validated implementation_plan.md to the plan-executor builder persona
  (architect/builder split) and monitors; Quick path executes the spec's
  Build Checklist directly. Invoke when the user wants to build the story,
  execute the plan, run Phase 4, hand off to the builder, or run the
  implementation steps. Stops on builder-reported failure or ambiguity so
  the architect can patch / re-baseline / re-hand off.
triggers:
  - "execute the plan"
  - "build the story"
  - "run the implementation plan"
  - "hand off to the builder"
  - "start the build"
  - "run phase 4"
  - "execute build for"
  - "build {slug}"
---

## Overview

Mirrors the `/e4-execute-plan {slug}` slash command. Same canonical body, two host wirings. Resolve the story folder per `templates/SHAMT_RULES.template.md` §PO-tree resolution (tree-wide glob + legacy-flat fallback).

## Protocol

Follow the canonical `/e4-execute-plan` command body verbatim — see [`commands/e4-execute-plan.md`](../../commands/e4-execute-plan.md). Summary:

1. **Resolve & path-check** — apply the active-artifact pointer; confirm the active spec (and plan, on Standard) has a validation footer + approved gate. Halt on Quick path with no Build Checklist or Standard path with no validated plan.
2. **Standard path** — hand off the active `implementation_plan.md` (or one phase file at a time for phase-decomposed plans) to the `plan-executor` Haiku persona — see [`agents/plan-executor.md`](../../agents/plan-executor.md). Builder executes mechanically; architect re-engages only on failure / ambiguity / plan defect.
3. **Quick path** — primary agent executes the spec's `## Build Checklist` directly. Escalate to a full plan if the checklist exceeds ~10 steps, exact locate/replace detail is needed, a builder sub-agent becomes necessary, or the user requests Gate 3.
4. **Monitor and route** — `All steps completed. Verification passed.` → continue. `Step N failed / ambiguous / plan defect` → diagnose, patch the plan via `/e3-plan-implementation`, re-hand off (Standard) or fix inline (Quick). Substantial changes trigger the **Re-baseline Protocol**.
5. **Post-build verification** — walk the plan's `## Verification`, `## Review Prevention Gate Mapping`, and `## CODING_STANDARDS Compliance` rows. Every item must pass.
6. **Exit** — suggest `/clear` + `/e5-execute-tests {slug}` (when `testing: "enabled"`), `/e6-review-changes {slug}` (when testing is disabled), and optionally `/e5b-write-manual-testing-plan {slug}` for UI / cloud-infra / external-integration / multi-user scope.

## Recommended models

- Orchestration: Balanced (Sonnet).
- Standard-path execution: Cheap (Haiku) via [`agents/plan-executor.md`](../../agents/plan-executor.md).
- Quick-path execution: Balanced (Sonnet).

See [`reference/model_selection.md`](../../../../../reference/model_selection.md).

## Exit criteria

Working tree reflects the plan / Build Checklist; the plan's (or spec's) `## Verification` section passes end-to-end; the `## Review Prevention Gate Mapping` (Standard) / `## Review Prevention Checklist` (Quick) is satisfied; builder reported `All steps completed. Verification passed.` (Standard) and you confirmed it.

---
Validated 2026-05-28 — 4 rounds, 1 adversarial sub-agent confirmed (Phase 6 implementation loop)

<!-- Managed by Shamt — do not edit. Regenerate from shamt-core/host/templates/claude/skills/e4-execute-plan/SKILL.md. -->
