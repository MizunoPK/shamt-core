---
name: e5b-write-manual-testing-plan
description: >
  Produce and validate stories/{slug}/manual_test_plan.md — a human-walkthrough
  artifact for verification automated tests cannot cover (UI behavior, cloud
  infra, external integrations, multi-user flows). Slug-resumable: Author /
  Patch / Re-validate / Author-continue modes depending on existing state.
  Orthogonal to .shamt-core/shamt-config.json testing — always available, every story. The
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

Mirrors the `/e5b-write-manual-testing-plan {slug}` slash command. Same canonical body, two host wirings. **Always available** regardless of `.shamt-core/shamt-config.json` `testing` — no no-op gate (this is the §1.15 rule that distinguishes it from `/e3b-write-testing-plan` and `/e5-execute-tests`).

## Protocol

Follow the canonical `/e5b-write-manual-testing-plan` command body verbatim — see [`commands/e5b-write-manual-testing-plan.md`](../../commands/e5b-write-manual-testing-plan.md). Summary:

1. **Resolve mode** — apply the active-artifact pointer; pick **Author / Patch / Re-validate / Author-continue** based on whether the artifact exists and whether the footer is present.
2. **Read spec / plan / context / testing_plan** — extract scope, requirements, Review Prevention Gates, verification, file manifest, and what automated tests already cover (so the `## Coverage Note` can delineate cleanly).
3. **Draft `manual_test_plan.md`** from [`templates/manual_test_plan.template.md`](../../../../../templates/manual_test_plan.template.md). Required sections: header metadata, `## Open Questions`, `## Setup`, `## Scenarios` (numbered; each with Starting state / Steps / Expected outcome / Pass-fail criterion), `## Teardown`, `## Coverage Note`. Apply the **open-questions iterative dialog** (Principle 2) — one question at a time via `AskUserQuestion`, code-research first.
4. **Inline validation loop (4 dimensions)** — runs here, not via `/validate-artifact`:
   - **Scope coverage** (gap = HIGH)
   - **Step reproducibility** (vague step = MEDIUM)
   - **Observable pass/fail** ("looks right" = HIGH)
   - **Setup completeness** (missing creds/data = HIGH)
   Counter logic: clean = 0 issues or 1 LOW fixed; not clean = 2+ LOW or any MEDIUM/HIGH/CRITICAL. **Exit at `consecutive_clean = 1`** — one primary clean round (standard Pattern 1 exit per `/validate-artifact`), then the Standard-path adversarial sub-agent.
5. **Adversarial sub-agent** — on Standard path (or Quick when any HIGH+ was found), spawn `validation-checker` Haiku per [`agents/validation-checker.md`](../../agents/validation-checker.md). No one-LOW allowance — any finding resets to 0.
6. **Footer** — `Validated YYYY-MM-DD — N rounds, 1 adversarial sub-agent confirmed` (Standard) or `Validated YYYY-MM-DD — N rounds (Quick path)` (Quick no-sub-agent). Update `active_artifacts.md` when present.
7. **Exit** — report mode + path + final dimension counts; link the artifact. Suggest the next phase (`/e6-review-changes` or `/e7-resolve-feedback`).

## Recommended models

- Authoring + inline validation-loop primary: **Balanced (Sonnet)** — both phases are structural analysis per [`reference/model_selection.md`](../../../../../reference/model_selection.md) `## Per-phase guidance` ("Manual-test-plan drafting | Balanced | Drafting + validation loop per `§1.15`"). This deliberately overrides the global default of Opus for primary validation loops.
- Sub-agent: Cheap (Haiku) via [`agents/validation-checker.md`](../../agents/validation-checker.md).

## Exit criteria

Validated `manual_test_plan.md` exists; `## Open Questions` is empty or deferred-with-reason; `consecutive_clean = 1` (one primary clean round) was reached; on Standard path, the `validation-checker` returned `CONFIRMED: Zero issues found after adversarial review.`; `active_artifacts.md` (when present) lists the artifact under Active Files.

## Slug-resumable

A fresh agent reads the artifact + active-artifact pointer + footer status, picks Author / Patch / Re-validate / Author-continue, and runs the appropriate slice. No conversation history required.

---
Validated 2026-05-28 — 4 rounds, 1 adversarial sub-agent confirmed (Phase 6 implementation loop)

<!-- Managed by Shamt — do not edit. Regenerate from shamt-core/host/templates/claude/skills/e5b-write-manual-testing-plan/SKILL.md. -->
