---
description: Post-Build optional artifact — produce and validate manual_test_plan.md for scenarios automated tests cannot exercise (UI, cloud infra, external integrations, multi-user flows). Slug-resumable; available regardless of the testing config flag
---

# /e5b-write-manual-testing-plan

**Purpose:** Produce and validate `stories/{slug}/manual_test_plan.md` — a human-walkthrough artifact for verification that automated tests cannot cover. Invocable any time after Phase 4 (Build) completes, **orthogonal to the project-level automated-testing opt-in** (no `.shamt-core/shamt-config.json` no-op check — this command is always available).

Slug-resumable: if the artifact already exists, re-validate or patch on request rather than starting from scratch.

**Recommended models:**

- Authoring + inline validation-loop primary: Balanced (Sonnet) — both drafting and the 4-dimension validation loop are structural analysis per [`reference/model_selection.md`](../../../../reference/model_selection.md) `## Per-phase guidance` ("Manual-test-plan drafting | Balanced | Drafting + validation loop per the manual-test-plan rule").
- Sub-agent: Cheap (Haiku) via `validation-checker`.

See [`reference/model_selection.md`](../../../../reference/model_selection.md).

---

## Usage

```
/e5b-write-manual-testing-plan {slug}
```

## Arguments

- `{slug}` (required) — story slug. Resolved via the global story-folder rules (exact `stories/{slug}/`, then `stories/{slug}-*/` glob; halt on multiple or zero matches per the Global Story Invariants in [`SHAMT_RULES.template.md`](../../../../templates/SHAMT_RULES.template.md#global-story-invariants)).

## Prerequisites

- Story folder resolves; if `stories/{slug}/active_artifacts.md` exists, read it first and use the artifact paths listed under **Active Files**.
- The active spec exists with a validation footer and is approved at Gate 2b.
- On the Standard path, the active `implementation_plan.md` exists with a validation footer (preferred but not required — drafting can proceed from the spec alone if the user explicitly wants a manual test plan before Plan validates).
- Phase 4 (Build) has completed for the story — this artifact walks a tester through verifying *what got built*. Halt and direct the user to `/e4-execute-plan {slug}` if Build has not run.
- **No `.shamt-core/shamt-config.json` `testing` check.** This command does **not** no-op on `testing: "disabled"` — it is independently available on every story.

## Slug-resumable mode

After applying the active-artifact pointer, decide whether to **author** or **patch**:

| Existing state | Mode | Action |
|----------------|------|--------|
| No `manual_test_plan.md` (or `manual_test_plan_vN.md` per pointer) exists | **Author** | Draft from scratch using the template. Run the full inline validation loop. |
| Artifact exists with a validation footer, and the user invoked without further direction | **Re-validate** | Re-run the inline validation loop (re-reads the spec; checks scope coverage against current spec/Verification). Update or refresh the footer. |
| Artifact exists with a validation footer, and the user asked to patch (e.g., "add a scenario for X" / "the setup is incomplete") | **Patch** | Update the named sections; re-run the inline validation loop on the changed artifact; re-stamp the footer. |
| Artifact exists **without** a validation footer (interrupted prior pass) | **Author-continue** | Pick up where the prior pass stopped — resolve any `## Open Questions` first, then re-run the inline validation loop in full. |

State the chosen mode in one line before drafting.

## Step-by-step (Author mode)

### Step 1 — Read spec / plan / context

1. Apply the active-artifact pointer.
2. Read the active `spec.md` completely. Extract `## Scope`, `## Requirements`, `## Review Prevention Gates`, and `## Verification`.
3. On Standard path, read `context.md` for code shapes and the current end-to-end flow.
4. On Standard path, read `implementation_plan.md` (when present) — file manifest, verification section, Review Prevention Gate Mapping. These show *what got built*; scenarios should exercise that surface.
5. If `testing: "enabled"` and `testing_plan.md` exists, read its `## Test Strategy` and `## Test Plan Steps` to know which surfaces automated tests already cover. The `## Coverage Note` will explicitly delineate the boundary later.
6. Read `.shamt-core/project-specific-files/ARCHITECTURE.md` and `.shamt-core/project-specific-files/CODING_STANDARDS.md` for any project-level UI / infra / multi-user conventions the walkthrough must respect.

### Step 2 — Draft `manual_test_plan.md`

Write `stories/{slug}/manual_test_plan.md` from [`templates/manual_test_plan.template.md`](../../../../templates/manual_test_plan.template.md). Required sections:

- Header metadata (`Created`, `Story`, `Spec`, `Implementation Plan`, `Testing Plan`, `Path`, `Baseline`).
- `## Open Questions` — populated and resolved one-at-a-time per the open-questions iterative dialog.
- `## Setup` — environment state, test data, accounts, feature flags, external service state, tooling. Anything the tester needs before step 1 of scenario 1.
- `## Scenarios` — numbered. Each scenario: **Name**, **Starting state**, **Steps** (numbered, imperative, specific), **Expected outcome** (concrete and observable — name the UI element / response value / log line / error message), **Pass/fail criterion** (binary check; not "looks right").
- `## Teardown` — how to clean up. A one-line `N/A — no shared state changed.` is acceptable when true.
- `## Coverage Note` — one paragraph: what automated tests cover vs. what this plan covers. When `testing_plan.md` does not exist for this story, say so and describe the rationale for manual-only coverage.

**Open-questions iterative dialog** (Principle 2 in [`SHAMT_RULES.template.md`](../../../../templates/SHAMT_RULES.template.md#principle-2-open-questions-iterative-dialog)) is mandatory: maintain the `## Open Questions` section as you draft, surface each question to the user **one at a time** via `AskUserQuestion`, update the artifact with each answer before moving to the next, code-research every question first.

### Step 3 — Inline validation loop (4 dimensions)

Run Pattern 1 inline — do **not** delegate to `/validate-artifact` here, because the dimension set is artifact-specific. Per [`templates/manual_test_plan.template.md`](../../../../templates/manual_test_plan.template.md), the 4 dimensions are:

1. **Scope coverage** — every risk area named in the spec's `Scope` / Requirements / Review Prevention Gates has at least one scenario that exercises it. A gap is **HIGH**.
2. **Step reproducibility** — each step is unambiguous enough that someone unfamiliar with the codebase can execute it without asking a question. Vague steps ("navigate to the admin page") are **MEDIUM**.
3. **Observable pass/fail** — every scenario's pass/fail criterion is a binary check the tester can perform without judgment (specific UI element, response value, log line, error message). "Looks right" or "works correctly" is **HIGH**.
4. **Setup completeness** — the `## Setup` section provides enough detail that a tester can reach the starting state of scenario 1 without external help. Missing credentials or undocumented data dependencies are **HIGH**.

Counter logic:

- Clean round = 0 issues OR exactly one LOW issue fixed.
- Not clean = 2+ LOW or any MEDIUM / HIGH / CRITICAL.
- Clean → `consecutive_clean = consecutive_clean + 1`.
- Not clean → `consecutive_clean = 0`.
- **Exit at `consecutive_clean = 1`** — one primary clean round. This follows `/validate-artifact`'s standard Pattern 1 exit (the source of truth for validation exits): on the Standard path (or risk-triggered Quick), continue to the Step 4 adversarial sub-agent; on Quick path with no HIGH+ finding, the single primary clean pass exits here.

### Step 4 — Adversarial sub-agent (Standard path only)

Once `consecutive_clean = 1` (one primary clean round), decide whether to spawn the `validation-checker` sub-agent:

- **Standard path** (per the active spec's `Path:` header) → spawn the sub-agent. Provide:
  - `artifact_path`: `stories/{slug}/manual_test_plan.md`
  - `dimensions`: the 4 dimensions above
  - `governing_references`: active `spec.md`, active `implementation_plan.md` (when present), `.shamt-core/project-specific-files/ARCHITECTURE.md`, `.shamt-core/project-specific-files/CODING_STANDARDS.md`, [`reference/severity_classification.md`](../../../../reference/severity_classification.md)

  Sub-agent **has no one-LOW allowance** — any finding (even LOW) resets `consecutive_clean = 0` and the loop continues. Only `CONFIRMED: Zero issues found after adversarial review.` exits.

- **Quick path** (per the active spec's `Path:` header) → no sub-agent required, **unless** the validation loop produced a HIGH or above on any round (per Pattern 1's risk-triggered sub-agent — "Sub-agent adversarial confirmation follows the Standard-path rule (applies on Standard path; Quick-path stories use a single primary pass unless a finding is HIGH or above)").

### Step 5 — Footer

Append the validation footer to `manual_test_plan.md`:

```text
---
Validated YYYY-MM-DD — N rounds, 1 adversarial sub-agent confirmed
```

On a Quick-path no-sub-agent exit:

```text
---
Validated YYYY-MM-DD — N rounds (Quick path)
```

Update `active_artifacts.md` (when it exists) to point at `manual_test_plan.md` (or `manual_test_plan_vN.md` when this is a re-baselined version).

### Step 6 — Exit

Report which mode was run (Author / Patch / Re-validate / Author-continue), the resolved Path (Quick / Standard), and the dimension counts from the final round. Link the validated artifact.

Suggest the next phase based on where the story is in the flow: typically `/e6-review-changes {slug}` (Phase 6) if Review has not yet run, or `/e7-resolve-feedback {slug}` (Phase 7) if Polish is next.

## Step-by-step (Patch mode)

When the user invokes the command on an existing footered artifact with a specific patch ask:

1. Confirm the patch scope inline (the named sections / scenarios) — `AskUserQuestion` if the ask is ambiguous.
2. Apply the patch to `manual_test_plan.md`. Do not re-author untouched sections.
3. Re-run the inline validation loop from Step 3 — the 4 dimensions still apply, and the sub-agent rule still applies. Exit at `consecutive_clean = 1` (one primary clean round; + Standard-path adversarial).
4. Re-stamp the footer (overwrite the prior date / round count).
5. Exit per Step 6.

## Exit criteria

- `stories/{slug}/manual_test_plan.md` exists, fully populated, with the validation footer.
- `## Open Questions` is empty (or contains only explicitly deferred items with reasons).
- `consecutive_clean = 1` (one primary clean round) was reached.
- On Standard path (or risk-triggered Quick), the `validation-checker` sub-agent returned `CONFIRMED: Zero issues found after adversarial review.`.
- `active_artifacts.md` (when present) lists the manual test plan under Active Files.

## Notes

- This command is **fresh-agent runnable**: every input lives on disk (active spec, plan, context, testing plan, active-artifact pointer, governing docs). State is determined by artifact presence + footer presence.
- **No `.shamt-core/shamt-config.json` no-op gate.** Unlike `/e5-execute-tests` and `/e3b-write-testing-plan`, this command does **not** check `testing` and does **not** print a no-op message. It is always available, on every story, per the manual-test-plan rule.
- **Recommended model tier: Sonnet** for both authoring and the inline validation-loop primary (per [`reference/model_selection.md`](../../../../reference/model_selection.md) `## Per-phase guidance` — "Manual-test-plan drafting | Balanced | Drafting + validation loop per the manual-test-plan rule"). The sub-agent stays at Haiku. This is a deliberate override of the per-phase default "Opus for primary validation loops" — the 4-dimension manual-test-plan loop is balanced/structural rather than multi-piece synthesis.
- The inline validation loop runs **here** (not delegated to `/validate-artifact`) so the Author / Patch / Re-validate modes stay cohesive — but it follows `/validate-artifact`'s standard Pattern 1 exit, which is the source of truth for how validations exit (one primary clean round + Standard-path adversarial). Only the **dimension set** is artifact-specific (the 4 dimensions in this command + the template); the exit rule is not bespoke.
- **Slug-resumable.** A fresh agent reads the artifact + active pointer + footer status, decides Author / Patch / Re-validate / Author-continue, and proceeds. No conversation history required.
- **Re-baseline.** If the spec or plan was re-baselined after this artifact was produced, the active-artifact pointer's `Manual Test Plan` row should reference the new `manual_test_plan_vN.md` per `templates/active_artifacts.template.md`. Re-running this command produces the new versioned file rather than overwriting v1.
- **Coverage Note discipline.** When `testing_plan.md` exists, the Coverage Note must explicitly state the manual/automated boundary so a reviewer can read both artifacts as a complete testing picture.

---
Validated 2026-05-28 — 4 rounds, 1 adversarial sub-agent confirmed (Phase 6 implementation loop)

<!-- Managed by Shamt — do not edit. Regenerate from shamt-core/host/templates/claude/commands/e5b-write-manual-testing-plan.md. -->
