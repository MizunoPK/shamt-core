---
name: f2-plan-update-implementation
description: >
  Phase 3 (optional) of the Shamt framework-update flow. When a validated
  proposal touches more than 10 canonical files, the architect drafts a
  mechanical implementation plan at proposals/{slug}_PLAN.md decomposing the
  Proposed Changes table into ordered, individually executable steps with
  exact locate strings and verifications. The plan itself goes through
  /validate-artifact before /f3-implement-update runs. Invoke when the user
  wants to plan a framework-update implementation, mechanically decompose a
  large proposal, or draft a plan for proposals/{slug}.md.
triggers:
  - "plan this framework update"
  - "plan the implementation of the proposal"
  - "decompose the proposal into a plan"
  - "draft a plan for the framework update"
  - "write the proposal plan"
  - "build the implementation plan for the proposal"
---

## Overview

Mirrors the `/f2-plan-update-implementation {slug}` slash command. Same canonical body, two host wirings.

## When to invoke

Only when the proposal's Proposed Changes table has **more than 10 rows**. Smaller proposals skip this phase entirely — `/f3-implement-update` reads the proposal directly. If the user invokes against a ≤10-row proposal, report the row count and decline; honor an explicit override.

## Protocol

Follow the canonical `/f2-plan-update-implementation` command body verbatim — see [`commands/f2-plan-update-implementation.md`](../../commands/f2-plan-update-implementation.md). Summary:

1. **Read proposal**, confirm validation footer, walk every Proposed Changes row. Note paired-file dependencies (rule ↔ template, command ↔ skill, ref ↔ rule pointer). Halt if any pair is missing from the table — direct the user back to `/f1-propose-update`.
2. **Author the plan** at `proposals/{slug}_PLAN.md` using the operation contracts (CREATE / EDIT / DELETE / MOVE) from [`templates/implementation_plan.template.md`](../../../../../templates/implementation_plan.template.md). Exact locate strings, exact replacements, concrete paths. No `if / when / consider` branches. Every step has a verification. **Never touch `.claude/`.** Decompose into phase files if the plan would compact a single Phase-4 session.
3. **Cross-check** plan steps against Proposed Changes rows. One-to-one coverage; operation match.
4. **Suggest validation** — single-file plan: `/clear` + `/validate-artifact proposals/{slug}_PLAN.md`. Phase-decomposed plan (index + ≥1 phase file → ≥2 validations): emit a **batch-validation handoff prompt** (recommended) filled with the resolved on-disk paths per [`reference/batch_validation_handoff.md`](../../../../../reference/batch_validation_handoff.md), plus the sequential per-file `/clear` + `/validate-artifact` list naming the index and **every** phase file as the fallback. The plan is not approved for execution until every file carries its own validation footer.

## Recommended models

- This command (architect): Balanced (Sonnet) — structural step decomposition.
- Validation primary (Phase 2 of the plan itself): Reasoning (Opus); sub-agent: Cheap (Haiku) via `validation-checker`.
- Phase 4 executor: Cheap (Haiku) via [`agents/plan-executor.md`](../../agents/plan-executor.md), reused as-is.

See [`reference/model_selection.md`](../../../../../reference/model_selection.md).

## Exit criteria

`proposals/{slug}_PLAN.md` (or index + phase files) exists with one step per Proposed Changes row, no generated-file edits, and `/validate-artifact` has been suggested. The plan carries no footer yet.

---
Validated 2026-05-28 — 4 rounds, 1 adversarial sub-agent confirmed (Phase 8 implementation loop)

<!-- Managed by Shamt — do not edit. Regenerate from shamt-core/host/templates/claude/skills/f2-plan-update-implementation/SKILL.md. -->
