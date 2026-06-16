---
name: e5b-write-manual-testing-plan
description: >
  Produce and validate stories/{slug}/manual_test_plan.md — a human-walkthrough
  artifact for verification automated tests cannot cover (UI behavior, cloud
  infra, external integrations, multi-user flows). Slug-resumable: Author /
  Patch / Re-validate / Author-continue modes depending on existing state. The
  on-demand human-walkthrough for scenarios the agent cannot simulate — always available, every story, orthogonal to the required Phase-5 agent-as-user execution. The
  inline validation loop uses the 4 dimensions in templates/manual_test_plan.template.md.
  Invoke when the user wants to write a manual test plan, document manual test
  scenarios, draft a tester walkthrough, or capture UI / infra / multi-user
  verification steps.
triggers:
  - "write a manual test plan"
  - "create a manual testing guide"
  - "document manual test scenarios"
  - "draft a tester walkthrough"
  - "capture manual verification steps"
  - "manual test plan for"
  - "patch the manual test plan"
  - "re-validate manual test plan"
---

## Overview

Mirrors the `/e5b-write-manual-testing-plan {slug}` slash command. Same canonical body, two host wirings. **Always available** on every story — no no-op gate; this on-demand human-walkthrough is orthogonal to the required Phase-5 agent-as-user run, which distinguishes it from `/e3b-write-testing-plan` and `/e5-execute-tests`.

## Protocol

Follow the canonical `/e5b-write-manual-testing-plan` command body verbatim — see [`commands/e5b-write-manual-testing-plan.md`](../../commands/e5b-write-manual-testing-plan.md). Resolve the story folder per `templates/SHAMT_RULES.template.md` §PO-tree resolution (tree-wide glob + legacy-flat fallback); `stories/{slug}/` below denotes that resolved folder.

## Recommended models

- Authoring + inline validation-loop primary: **Balanced (Sonnet)** — both phases are structural analysis per [`reference/model_selection.md`](../../../../../reference/model_selection.md) `## Per-phase guidance` ("Manual-test-plan drafting | Balanced | Drafting + validation loop per the manual-test-plan rule"). This deliberately overrides the global default of Opus for primary validation loops.
- Sub-agent: Cheap (Haiku) via [`agents/validation-checker.md`](../../agents/validation-checker.md).

## Exit criteria

Validated `manual_test_plan.md` exists; `## Open Questions` is empty or deferred-with-reason; `consecutive_clean = 1` (one primary clean round) was reached; on Standard path, the `validation-checker` returned `CONFIRMED: Zero issues found after adversarial review.`; `active_artifacts.md` (when present) lists the artifact under Active Files.

## Slug-resumable

A fresh agent reads the artifact + active-artifact pointer + footer status, picks Author / Patch / Re-validate / Author-continue, and runs the appropriate slice. No conversation history required.

---
Validated 2026-05-28 — 4 rounds, 1 adversarial sub-agent confirmed (Phase 6 implementation loop)

<!-- Managed by Shamt — do not edit. Regenerate from shamt-core/host/templates/claude/skills/e5b-write-manual-testing-plan/SKILL.md. -->
