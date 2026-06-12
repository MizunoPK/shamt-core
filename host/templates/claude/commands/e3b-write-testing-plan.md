---
description: Plan sub-phase (testing enabled) — produce and validate testing_plan.md from an approved spec; inline checklist on Quick-path stories with small scope
---

# /e3b-write-testing-plan

**Purpose:** Produce and validate the testing plan for a story whose spec is approved at Gate 2b. Invoked automatically by `/e3-plan-implementation` when `testing: "enabled"` is set in `.shamt-core/shamt-config.json`. Also runnable standalone for re-planning after the Plan phase (e.g., test strategy changes mid-Build).

**Recommended models:**

- Authoring: Balanced (Sonnet) — same shape as `implementation_plan.md` drafting.
- Validation loop primary: Reasoning (Opus). Sub-agent: Cheap (Haiku) via `validation-checker`.

See [`reference/model_selection.md`](../../../../reference/model_selection.md).

---

## Usage

```
/e3b-write-testing-plan {slug}
```

## Arguments

- `{id-or-slug}` (required) — story ticket ID (`T{N}`) or slug. Resolved via the global story-folder rules (ID glob `stories/{ID}-*/`, else the both-positions slug glob; halt on multiple or zero matches).

## Prerequisites

- `.shamt-core/shamt-config.json` exists. Read `testing`. If `disabled`, **this command is a no-op**: print one line — `Testing is disabled in .shamt-core/shamt-config.json — no testing plan needed.` — and exit. Do not create or modify any file.
- Resolve the story folder per `templates/SHAMT_RULES.template.md` §PO-tree resolution (tree-wide glob + legacy-flat fallback); `stories/{slug}/` below denotes that resolved folder. Apply the active-artifact pointer if `stories/{slug}/active_artifacts.md` exists.
- The active spec exists with a validation footer and is approved at Gate 2b. The spec must include a `## Test Strategy` section per [`SHAMT_RULES.template.md`](../../../../templates/SHAMT_RULES.template.md#when-automated-testing-is-enabled).
- If `.shamt-core/project-specific-files/ARCHITECTURE.md` and `.shamt-core/project-specific-files/CODING_STANDARDS.md` exist, read them for test runner / file naming / fixture / assertion conventions.

## Path selection (Quick vs Standard, inline vs full artifact)

After reading the spec's `## Test Strategy`, decide the artifact shape:

| Condition | Output |
|-----------|--------|
| Quick path **and** test scope is small (≤5 steps **and** no new test file) | Update the spec's `### Quick path inline test checklist` (under `## Test Strategy`) in place. Do not create `testing_plan.md`. |
| Quick path **and** test scope exceeds the inline threshold (>5 steps **or** any new test file) | Escalate. Create `stories/{slug}/testing_plan.md` from [`templates/testing_plan.template.md`](../../../../templates/testing_plan.template.md). |
| Standard path | Always create `stories/{slug}/testing_plan.md` from [`templates/testing_plan.template.md`](../../../../templates/testing_plan.template.md). |

State the chosen shape and the threshold-trigger in one line before drafting.

## Step-by-step

### Step 1 — Read the spec's Test Strategy

1. Read `## Test Strategy` from the active spec. Extract:
   - Test kinds in scope (e2e / integration / unit).
   - Existing test files relevant.
   - New test files needed.
   - Project conventions (runner, naming, fixtures, assertions).
2. Cross-reference with `.shamt-core/project-specific-files/ARCHITECTURE.md` and `.shamt-core/project-specific-files/CODING_STANDARDS.md` for any test-related rules.

### Step 2 — Decide artifact shape

Apply the Path-selection table above.

### Step 3 — Draft the plan

**For the inline checklist (Quick path, small scope):**

- Edit the spec's `### Quick path inline test checklist` under `## Test Strategy`.
- Each row: `- [ ] {Test name} - {exact invocation} - {binary pass criterion}`.
- No prose — checklist only.
- Keep the spec validated; do not require re-validation when only the inline checklist is filled. (If the checklist content changes after the spec's footer was stamped, re-run `/validate-artifact stories/{slug}/spec.md`.)

**For the full `testing_plan.md`:**

Use [`templates/testing_plan.template.md`](../../../../templates/testing_plan.template.md). Required sections:

- Header metadata (`Created`, `Story`, `Spec`, `Implementation Plan`, `Path`, `Baseline`).
- `## Test Strategy` (mirror the spec, expanded with runner, file conventions, and project assumptions).
- `## Test Plan Steps` — each step is one runnable test or test group, with **exact invocation** and **binary pass criterion**. Listed in execution order.
- `## Shared Setup / Teardown` — required if any step assumes pre-existing state; otherwise `N/A — each step is self-contained.`.
- `## Results Log` — table with PENDING / PASS / FAIL / BLOCKED status; populated by the `test-executor` during Phase 5.
- `## Failure Diagnosis` — empty until failures occur.
- `## Open Questions` — only unresolved test-design questions.
- `## Validation` — note that Pattern 1 will validate this plan.

**Per-step requirements:**

- **Type** (unit / integration / e2e).
- **File** — workspace-relative test path.
- **Invocation** — the exact command (e.g., `pytest tests/foo_test.py::test_bar`, `npm test -- --runInBand path/to/test`).
- **Pass criterion** — what output proves pass (exit code, output line, assertion count).
- **Covers** — the spec requirement IDs or implementation-plan step numbers this verifies.

**Open-questions iterative dialog (Principle 2 in [`SHAMT_RULES.template.md`](../../../../templates/SHAMT_RULES.template.md)):** maintain an `## Open Questions` section while drafting. Surface each unresolved test-design question to the user one at a time via `AskUserQuestion`. Update the plan with each answer before moving on. Code-research every question first.

### Step 4 — Validate

Invoke `/validate-artifact stories/{slug}/testing_plan.md`. Dimensions mirror the implementation-plan dimensions but emphasize:

- **Step clarity** — each step has an unambiguous invocation and a binary pass criterion.
- **Executability** — commands resolve in the project's test environment; pre-existing state is documented under Shared Setup.
- **Verification completeness** — every spec requirement and every approval-relevant plan step maps to at least one test step, OR has an explicit `Not testable here — covered by manual_test_plan.md` reason.

Exit: primary clean + 1 adversarial sub-agent (Standard path is the default for plan validation). Footer the plan.

If the artifact is the inline checklist, run `/validate-artifact stories/{slug}/spec.md` instead — the checklist is part of the spec.

### Step 5 — Exit

Report which shape was produced (inline vs full artifact) and link the validated file. If invoked by `/e3-plan-implementation`, return control to it. If invoked standalone, suggest the next phase (`/e5-execute-tests {slug}` after Build).

## Exit criteria

- One of:
  - `stories/{slug}/spec.md` has a populated `### Quick path inline test checklist`, OR
  - `stories/{slug}/testing_plan.md` exists, fully populated, with the validation footer.
- Open Questions in the artifact is empty (or contains only explicitly deferred items with reasons).

## Notes

- **No-op when testing is disabled.** The single-line message above is intentional — the command must remain safe to invoke unconditionally from `/e3-plan-implementation` regardless of project configuration.
- This command is **fresh-agent runnable**: input lives on disk (config, spec, governing docs). State is determined by artifact presence.
- The inline-vs-artifact threshold (>5 steps OR any new test file) is the only criterion that escalates a Quick-path story to the full artifact. Do not invent additional escalation rules; if you find yourself wanting to, the test scope is large enough to warrant the full file anyway.
- Phase 5 (Test) executes this plan via the `test-executor` persona — see [`SHAMT_RULES.template.md`](../../../../templates/SHAMT_RULES.template.md#when-automated-testing-is-enabled) and Part 3's Engineer Flow phase narratives. Phase 5 **blocks until all tests pass**.

---
Validated 2026-05-28 — 2 rounds, 1 adversarial sub-agent confirmed (Phase 5 implementation loop)

<!-- Managed by Shamt — do not edit. Regenerate from shamt-core/host/templates/claude/commands/e3b-write-testing-plan.md. -->
