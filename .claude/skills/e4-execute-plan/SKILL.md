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

Follow the canonical `/e4-execute-plan` command body verbatim — see [`commands/e4-execute-plan.md`](../../commands/e4-execute-plan.md).

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
