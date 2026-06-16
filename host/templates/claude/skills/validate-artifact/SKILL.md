---
name: validate-artifact
description: >
  Run a Shamt Pattern 1 validation loop on any named artifact — spec, spec/
  context pair, implementation plan, testing plan, manual test plan, code
  review, framework-update proposal, or general document. Quick path = single
  primary pass; Standard or risk-triggered = primary clean + 1 Haiku adversarial
  sub-agent confirmation (no one-LOW allowance). Stamps the validation footer.
  Invoke when the user wants to validate, re-validate, run a validation loop,
  apply Pattern 1, sub-agent-check, or footer an artifact.
triggers:
  - "validate this artifact"
  - "validate the spec"
  - "validate the plan"
  - "validate the testing plan"
  - "validate the manual test plan"
  - "validate the review"
  - "validate the proposal"
  - "run a validation loop"
  - "run pattern 1 on"
  - "re-validate"
  - "sub-agent check"
  - "footer this artifact"
---

## Overview

Mirrors the `/validate-artifact <path>` slash command. Same canonical body, two host wirings. The cross-phase validation primitive every other Shamt phase relies on; also reused by the framework-update flow for proposals.

## Protocol

Follow the canonical `/validate-artifact` command body verbatim — see [`commands/validate-artifact.md`](../../commands/validate-artifact.md).

## Batch handoff (≥2 artifacts)

When a caller leaves **2 or more** artifacts to validate at once (a phase-decomposed plan = index + N phase files; several proposals promoted in one triage run), the producing command can emit a **batch-validation handoff prompt** rather than a sequential `/clear` + `/validate-artifact` list. The user pastes it into one fresh session; that orchestrator fans out one validation sub-agent per artifact — each running this same Pattern 1 loop in its own context — and reports the aggregate. Same rigor per artifact (dimensions, exit, footer, no-one-LOW-allowance); the per-artifact `/validate-artifact <path>` commands stay the slug-resumable fallback. See [`reference/batch_validation_handoff.md`](../../../../../reference/batch_validation_handoff.md).

## Recommended models

- Primary loop: Reasoning (Opus) — multi-dimensional reasoning.
- Adversarial sub-agent: Cheap (Haiku) via [`agents/validation-checker.md`](../../agents/validation-checker.md). Always Cheap — mis-tiering is a configuration finding.

See [`reference/model_selection.md`](../../../../../reference/model_selection.md) and [`reference/validation_exit_criteria.md`](../../../../../reference/validation_exit_criteria.md).

## Exit criteria

Required `consecutive_clean` reached for the chosen path; validation footer appended. No separate `_VALIDATION_LOG.md` artifact — the footer is the only persistent record.

---
Validated 2026-05-28 — 2 rounds, 1 adversarial sub-agent confirmed (Phase 5 implementation loop)

<!-- Managed by Shamt — do not edit. Regenerate from shamt-core/host/templates/claude/skills/validate-artifact/SKILL.md. -->
