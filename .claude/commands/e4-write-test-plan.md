---
description: Phase 4 (Test Plan, mandatory) — author the agent-as-user user_test_plan.md (always) and the automated testing_plan.md (when TESTING_STANDARDS.md declares suites); run the open-questions dialog + validation on each; next phase is /e5-execute-plan
---

# /e4-write-test-plan

**Purpose:** Run the **mandatory** Phase 4 (Test Plan) of the Engineer flow. Author the **agent-as-user** test plan `stories/{slug}/user_test_plan.md` (always — the `user-simulator` executes it in Phase 6) and, when `.shamt-core/project-specific-files/TESTING_STANDARDS.md` declares automated suites, the automated `stories/{slug}/testing_plan.md` (the `test-executor` runs it in Phase 6). Each artifact runs the open-questions iterative dialog and a validation loop before exit. The `user_test_plan.md` is always produced, so **this stage always runs**; the automated `testing_plan.md` is the one sub-part gated on a test framework being declared.

**Recommended models:**

- Authoring (both plans) + the `user_test_plan.md` inline validation-loop primary: Balanced (Sonnet) — structural scenario / step decomposition, per [`reference/model_selection.md`](../../../../reference/model_selection.md).
- `testing_plan.md` validation loop primary: Reasoning (Opus). Sub-agent: Cheap (Haiku) via `validation-checker`.

See [`reference/model_selection.md`](../../../../reference/model_selection.md).

---

## Usage

```
/e4-write-test-plan {slug}
```

## Arguments

- `{id-or-slug}` (required) — story ticket ID (`T{N}`) or slug. Resolved via the global story-folder rules (ID glob `stories/{ID}-*/`, else the both-positions slug glob; halt on multiple or zero matches per the Global Story Invariants in [`SHAMT_RULES.template.md`](../../../../templates/SHAMT_RULES.template.md#global-story-invariants)).

## Prerequisites

- Resolve the story folder per `templates/SHAMT_RULES.template.md` §PO-tree resolution (tree-wide glob + legacy-flat fallback); `stories/{slug}/` below denotes that resolved folder. Apply the active-artifact pointer if `stories/{slug}/active_artifacts.md` exists.
- The active spec exists with a validation footer and is approved at Gate 2b. The spec must include a `## Test Strategy` section per [`SHAMT_RULES.template.md`](../../../../templates/SHAMT_RULES.template.md#testing-phase-6--required).
- The active `implementation_plan.md` exists with a validation footer and is approved at Gate 3 (Plan is mandatory — Phase 3 ran).
- `.shamt-core/project-specific-files/TESTING_STANDARDS.md` exists and is validated. Read its **Automated test infrastructure** section to learn whether automated suites are declared.
- If `.shamt-core/project-specific-files/ARCHITECTURE.md` and `.shamt-core/project-specific-files/CODING_STANDARDS.md` exist, read them for test runner / file naming / fixture / assertion / UI / infra / multi-user conventions both plans must respect.

## Slug-resumable mode

After applying the active-artifact pointer, decide per artifact whether to **author** or **patch**:

| Existing state | Mode | Action |
|----------------|------|--------|
| Plan absent | **Author** | Draft from scratch using the template. Run the full validation loop. |
| Plan exists with a validation footer, no further direction | **Re-validate** | Re-run the validation loop; refresh the footer. |
| Plan exists with a validation footer, user asked to patch | **Patch** | Update the named sections; re-run the validation loop on the changed artifact; re-stamp the footer. |
| Plan exists **without** a validation footer (interrupted prior pass) | **Author-continue** | Resolve any `## Open Questions` first, then re-run the validation loop in full. |

State the chosen mode per artifact in one line before drafting.

## Step-by-step

### Step 1 — Read the spec's Test Strategy and the plan

1. Read `## Test Strategy` from the active spec. Extract: agent-as-user scenarios in scope; automated test kinds (e2e / integration / unit); existing test files relevant; new test files needed; project conventions (runner, naming, fixtures, assertions).
2. Read the active `implementation_plan.md` — file manifest, `## Verification`, Review Prevention Gate Mapping. These show *what will be built*; both plans exercise that surface.
3. Cross-reference `.shamt-core/project-specific-files/ARCHITECTURE.md` and `.shamt-core/project-specific-files/CODING_STANDARDS.md` for test / UI / infra / multi-user rules.

### Step 2 — Author `user_test_plan.md` (always)

Write `stories/{slug}/user_test_plan.md` from [`templates/user_test_plan.template.md`](../../../../templates/user_test_plan.template.md). This is the **agent-as-user execution script** the `user-simulator` runs in Phase 6 — not a human walkthrough. Required sections:

- Header metadata (`Created`, `Story`, `Spec`, `Implementation Plan`, `Testing Plan`, `Baseline`).
- `## Open Questions` — populated and resolved one-at-a-time per the open-questions iterative dialog.
- `## Setup` — environment state, test data, accounts, feature flags, external service state, tooling. Everything the agent-as-user needs before scenario 1, step 1.
- `## Scenarios` — numbered. Each scenario: **Name**, **Starting state**, **Steps** (numbered, imperative, specific — runnable by the agent driving the project as a user), **Expected outcome** (concrete and observable — name the output value / response / log line / error message), **Pass/fail criterion** (binary check; not "looks right").
- `## Teardown` — how to clean up. `N/A — no shared state changed.` is acceptable when true.
- `## Coverage Note` — one paragraph: what automated tests cover vs. what these agent-as-user scenarios cover. When `testing_plan.md` does not exist for this story, say so and describe the rationale for agent-as-user-only coverage.

The per-run execution log is **not** kept here — the `user-simulator` writes it to `agent_test_session.md` in Phase 6. This plan is the script, not the results log.

**Open-questions iterative dialog (Principle 2 in [`SHAMT_RULES.template.md`](../../../../templates/SHAMT_RULES.template.md#principle-2-open-questions-iterative-dialog))** is mandatory: maintain the `## Open Questions` section as you draft, surface each question to the user **one at a time** via `AskUserQuestion`, update the artifact with each answer before the next, code-research every question first.

### Step 3 — Validate `user_test_plan.md` (4 dimensions)

Invoke `/validate-artifact stories/{slug}/user_test_plan.md`. The 4 scenario-specific dimensions are:

1. **Scope coverage** — every risk area named in the spec's `Scope` / Requirements / Review Prevention Gates has at least one scenario that exercises it. A gap is **HIGH**.
2. **Step reproducibility** — each step is unambiguous enough that the agent-as-user can execute it without asking a question. Vague steps are **MEDIUM**.
3. **Observable pass/fail** — every scenario's pass/fail criterion is a binary check (specific output value, response, log line, error message). "Looks right" / "works correctly" is **HIGH**.
4. **Setup completeness** — `## Setup` provides enough detail to reach scenario 1's starting state without external help. Missing credentials or undocumented data dependencies are **HIGH**.

Exit: primary clean + 1 adversarial sub-agent (uniform — no Quick/Standard rigor selector). Footer the plan.

### Step 4 — Author `testing_plan.md` (when automated suites present)

Read `TESTING_STANDARDS.md`'s **Automated test infrastructure** section. **If it declares None,** print one line — `TESTING_STANDARDS.md declares no automated suites — no testing_plan.md needed (Phase 6 runs the agent-as-user execution of user_test_plan.md).` — and skip to Step 6. Do not create `testing_plan.md`.

When suites are declared, write `stories/{slug}/testing_plan.md` from [`templates/testing_plan.template.md`](../../../../templates/testing_plan.template.md). Required sections:

- Header metadata (`Created`, `Story`, `Spec`, `Implementation Plan`, `Baseline`).
- `## Test Strategy` (mirror the spec, expanded with runner, file conventions, and project assumptions).
- `## Test Plan Steps` — each step is one runnable test or test group, with **exact invocation** and **binary pass criterion**, in execution order.
- `## Shared Setup / Teardown` — required if any step assumes pre-existing state; otherwise `N/A — each step is self-contained.`.
- `## Results Log` — table with PENDING / PASS / FAIL / BLOCKED status; populated by the `test-executor` during Phase 6.
- `## Failure Diagnosis` — empty until failures occur.
- `## Open Questions` — only unresolved test-design questions.
- `## Validation` — note that Pattern 1 will validate this plan.

**Per-step requirements:** **Type** (unit / integration / e2e); **File** (workspace-relative test path); **Invocation** (exact command, e.g. `pytest tests/foo_test.py::test_bar`); **Pass criterion** (what output proves pass — exit code, output line, assertion count); **Covers** (the spec requirement IDs or implementation-plan step numbers this verifies, OR an explicit `Not testable here — covered by user_test_plan.md` reason).

**Open-questions iterative dialog** is mandatory here too: maintain `## Open Questions`, surface one at a time via `AskUserQuestion`, update before moving on, code-research first.

### Step 5 — Validate `testing_plan.md`

Invoke `/validate-artifact stories/{slug}/testing_plan.md`. Dimensions mirror the implementation-plan dimensions but emphasize **Step clarity** (unambiguous invocation + binary pass criterion), **Executability** (commands resolve in the test environment; pre-existing state documented under Shared Setup), and **Verification completeness** (every spec requirement and every approval-relevant plan step maps to a test step, or an explicit `Not testable here — covered by user_test_plan.md` reason). Exit: primary clean + 1 adversarial sub-agent (uniform). Footer the plan.

### Step 6 — Exit

Report which artifacts were produced (`user_test_plan.md` always; `testing_plan.md` when suites are declared) and the final-round dimension counts. Link the validated files. Suggest a context-clear breakpoint: `/clear`, then `/e5-execute-plan {slug}` (Phase 5 — Build).

## Exit criteria

- `stories/{slug}/user_test_plan.md` exists, fully populated, with the validation footer.
- When `TESTING_STANDARDS.md` declares automated suites, `stories/{slug}/testing_plan.md` exists, fully populated, with its validation footer.
- `## Open Questions` in each produced artifact is empty (or contains only explicitly deferred items with reasons).

## Notes

- **Mandatory stage.** The `user_test_plan.md` is always authored, so Phase 4 always runs. The automated `testing_plan.md` is the one genuine conditional — physically impossible without a declared test framework.
- **The agent executes the user plan.** `user_test_plan.md` is the `user-simulator`'s execution script in Phase 6 (Test) — it is not a human walkthrough. Write each scenario so an agent driving the project as a user can run it step by step.
- This command is **fresh-agent runnable**: input lives on disk (config, spec, plan, governing docs). State is determined by artifact presence + footer presence.
- The per-run execution log lives in `agent_test_session.md` (written in Phase 6), never duplicated into `user_test_plan.md`.
- Phase 6 (Test) executes both plans — see [`SHAMT_RULES.template.md`](../../../../templates/SHAMT_RULES.template.md#testing-phase-6--required) and Part 3's Engineer Flow phase narratives. Phase 6 **blocks until green**.

---

<!-- Managed by Shamt — do not edit. Regenerate from shamt-core/host/templates/claude/commands/e4-write-test-plan.md. -->
