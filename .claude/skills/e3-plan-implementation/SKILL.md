---
name: e3-plan-implementation
description: >
  Run Phase 3 (Plan) of the Shamt Engineer flow — Standard path only — turning
  an approved spec into a mechanical, validated implementation plan ready for
  builder handoff at Gate 3. Chains into /e3b-write-testing-plan when TESTING_STANDARDS.md declares
  automated suites. Invoke when the user wants to plan the implementation, draft the
  implementation plan, run the plan phase, prepare the builder handoff, or
  break the spec into mechanical steps. Skips with a clear notice on Quick-path
  stories (build directly from spec.md).
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

Follow the canonical `/e3-plan-implementation` command body verbatim — see [`commands/e3-plan-implementation.md`](../../commands/e3-plan-implementation.md). Summary:

1. **Path check** — if the active spec declares `Path: Quick path`, report skip-with-rationale and exit (unless the user explicitly requests Gate 3 planning).
2. **Read spec/context and confirm decisions** — apply active-artifact pointer; re-read spec/context completely; research repo conventions for file placement, sibling shapes, naming, deployment.

Resolve the story folder per `templates/SHAMT_RULES.template.md` §PO-tree resolution (tree-wide glob + legacy-flat fallback); `stories/{slug}/` below denotes that resolved folder.

3. **Create the mechanical plan** at `stories/{slug}/implementation_plan.md` from [`templates/implementation_plan.template.md`](../../../../../templates/implementation_plan.template.md). Skeleton-first authoring for 5+ steps. Apply the **open-questions iterative dialog** principle. Honor the plan contract — no optional branches, exact locate strings, concrete CREATE content, multi-repo `Step 0-A` / `0-B` branch-prep, Review Prevention Gate Mapping, CODING_STANDARDS compliance mapping.
4. **Validate** via `/validate-artifact stories/{slug}/implementation_plan.md` — 8 plan dimensions, primary clean + 1 sub-agent confirmation. Footer.
5. **Chain into `/e3b-write-testing-plan {slug}`** when `TESTING_STANDARDS.md` declares automated suites. Wait for the testing plan to validate before Gate 3.
6. **Gate 3** — present the validated plan (and testing plan when applicable) for user approval. Suggest `/clear` + `/e4-execute-plan {slug}` after approval.

## Recommended models

- Authoring: Balanced (Sonnet).
- Validation loop primary: Reasoning (Opus). Sub-agent: Cheap (Haiku) via `validation-checker`.

See [`reference/model_selection.md`](../../../../../reference/model_selection.md).

## Exit criteria

Validated `implementation_plan.md` (and `testing_plan.md` when TESTING_STANDARDS.md declares automated suites) approved at Gate 3; Open Questions empty or deferred with reason. Builder handoff is unconditional after Gate 3 — the architect plans, the cheap-tier builder executes.

---
Validated 2026-05-28 — 2 rounds, 1 adversarial sub-agent confirmed (Phase 5 implementation loop)

<!-- Managed by Shamt — do not edit. Regenerate from shamt-core/host/templates/claude/skills/e3-plan-implementation/SKILL.md. -->
