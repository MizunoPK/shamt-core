---
name: e3b-write-testing-plan
description: >
  Plan sub-phase invoked when .shamt-core/shamt-config.json sets testing: "enabled".
  Produces and validates either the inline test checklist in spec.md (Quick
  path, ≤5 steps, no new test file) or the full testing_plan.md artifact
  (Standard path, or Quick path with larger scope). Invoke when the user wants
  to draft or update the testing plan for a story, write a test plan, plan
  Phase 5 testing, or escalate an inline checklist to a full artifact. No-op
  with a clear message when testing is disabled.
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

Mirrors the `/e3b-write-testing-plan {slug}` slash command. Same canonical body, two host wirings. Invoked by `/e3-plan-implementation` when testing is enabled; also runnable standalone for re-planning.

## Protocol

Follow the canonical `/e3b-write-testing-plan` command body verbatim — see [`commands/e3b-write-testing-plan.md`](../../commands/e3b-write-testing-plan.md). Summary:

1. **No-op gate** — if `.shamt-core/shamt-config.json` sets `testing: "disabled"`, print one line and exit. Do not touch any file.
2. **Read the spec's `## Test Strategy`** — extract test kinds, existing files, new files, conventions.

Resolve the story folder per `templates/SHAMT_RULES.template.md` §PO-tree resolution (tree-wide glob + legacy-flat fallback); `stories/{slug}/` below denotes that resolved folder.

3. **Decide artifact shape:**
   - **Quick path + small scope** (≤5 steps **and** no new test file) → update the spec's inline `### Quick path inline test checklist`.
   - **Quick path + larger scope** OR **Standard path** → create `stories/{slug}/testing_plan.md` from [`templates/testing_plan.template.md`](../../../../../templates/testing_plan.template.md).
4. **Draft** — each step has an exact invocation and binary pass criterion; cross-reference `.shamt-core/project-specific-files/ARCHITECTURE.md` and `.shamt-core/project-specific-files/CODING_STANDARDS.md` for runner / file naming / fixture / assertion conventions. Apply the **open-questions iterative dialog** principle.
5. **Validate** via `/validate-artifact stories/{slug}/testing_plan.md` (or re-validate `spec.md` when the inline checklist was used). Primary clean + 1 sub-agent confirmation (Standard default for plan validation). Footer.
6. **Exit** — report shape produced; return control to caller (or suggest `/e5-execute-tests {slug}` after Build).

## Recommended models

- Authoring: Balanced (Sonnet).
- Validation loop primary: Reasoning (Opus). Sub-agent: Cheap (Haiku) via `validation-checker`.

See [`reference/model_selection.md`](../../../../../reference/model_selection.md).

## Exit criteria

Either the spec's inline checklist is populated, or `testing_plan.md` exists with a validation footer; Open Questions empty or deferred with reason. Phase 5 (Test) executes this plan and **blocks until all tests pass** — see [`SHAMT_RULES.template.md`](../../../../../templates/SHAMT_RULES.template.md#when-automated-testing-is-enabled).

---
Validated 2026-05-28 — 2 rounds, 1 adversarial sub-agent confirmed (Phase 5 implementation loop)

<!-- Managed by Shamt — do not edit. Regenerate from shamt-core/host/templates/claude/skills/e3b-write-testing-plan/SKILL.md. -->
