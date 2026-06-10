---
description: Phase 5 (Test) — execute the validated testing_plan.md (or the spec's inline checklist) via the test-executor persona; blocks until every step passes; no-op when testing is disabled
---

# /e5-execute-tests

**Purpose:** Run Phase 5 of the Engineer flow when `.shamt-core/shamt-config.json` sets `testing: "enabled"`. Hand off the validated testing plan to the `test-executor` persona, watch for failures, route Story-bug / Test-bug / Spec-gap diagnoses appropriately, and **block until every step in the plan reports `PASS`**.

When `testing: "disabled"`, this command is a no-op with a single-line message — see the no-op gate below.

**Recommended models:**

- Orchestration (this command): Balanced (Sonnet) — interpret test-executor reports, decide between fix-in-place / patch-the-plan / re-baseline.
- Execution: Cheap (Haiku) via [`agents/test-executor.md`](../agents/test-executor.md).

See [`reference/model_selection.md`](../../../../reference/model_selection.md).

---

## Usage

```
/e5-execute-tests {slug}
```

## Arguments

- `{id-or-slug}` (required) — story ticket ID (`T{N}`) or slug. Resolved via the global story-folder rules (ID glob `stories/{ID}-*/`, else the both-positions slug glob; halt on multiple or zero matches).

## No-op gate

Read `.shamt-core/shamt-config.json` → `testing`.

- `"disabled"` → print one line and exit. Do not touch any file, do not invoke the test-executor.
  ```
  Testing is disabled in .shamt-core/shamt-config.json — Phase 5 is not part of this project's flow. Run /e6-review-changes {slug} next.
  ```
- `"enabled"` → continue.

Per [`SHAMT_RULES.template.md`](../../../../templates/SHAMT_RULES.template.md#when-automated-testing-is-enabled), this command is safe to invoke unconditionally — the no-op keeps automation simple.

## Prerequisites (testing enabled)

- Story folder resolves; if `stories/{slug}/active_artifacts.md` exists, read it first and use the artifact paths listed under **Active Files**.
- The active spec exists with a validation footer.
- The active plan exists with a validation footer **and Phase 4 (Build) has completed** — code-under-test is in the working tree. If Build has not run yet, halt and direct the user to `/e4-execute-plan {slug}` first.
- One of the following is true (per the path):
  - **Standard path:** `stories/{slug}/testing_plan.md` (or `testing_plan_vN.md`) exists with a validation footer.
  - **Quick path with full artifact:** same as Standard — the artifact was produced via `/e3b-write-testing-plan {slug}` because test scope exceeded the Quick-path inline threshold (>5 steps or any new test file) — the testing-plan escalation threshold (`/e3b`). Quick path itself still skips Phase 3 (Plan); the escalation only adds a `testing_plan.md` without escalating the whole story to Standard.
  - **Quick path with inline checklist:** the active `spec.md` has a populated `### Quick path inline test checklist` under `## Test Strategy`.

If the active testing artifact is not validated, halt and direct the user to `/e3b-write-testing-plan {slug}` (or `/validate-artifact stories/{slug}/spec.md` when the inline checklist was recently edited).

## Step-by-step

### Step 1 — Resolve the active testing artifact

1. Apply the active-artifact pointer.
2. Read the spec's `Path:` header and the spec's `## Test Strategy`.
3. Determine the executable surface:
   - **Full artifact:** `stories/{slug}/testing_plan.md` (or `_vN`).
   - **Inline checklist:** `stories/{slug}/spec.md` `### Quick path inline test checklist`.
4. Confirm the artifact's validation footer. If missing, halt.

### Step 2 — Hand off to the test-executor

Spawn the `test-executor` persona — see [`agents/test-executor.md`](../agents/test-executor.md). Provide:

- `slug`,
- `testing_plan_path` (the resolved artifact path; for the inline checklist, pass the active `spec.md` path),
- `active_artifacts_path` when present.

Example invocation (Claude Code Task tool):

```text
subagent_type: test-executor
description: Execute {slug} testing plan
prompt: |
  slug: {slug}
  testing_plan_path: stories/{slug}/testing_plan.md  # or spec.md for inline checklist
  active_artifacts_path: stories/{slug}/active_artifacts.md  # when present
  Execute the testing plan per the persona contract. Resolve environmental issues; do not skip them. Halt on the first Story-bug / Test-bug / Spec-gap failure and report.
```

The persona logs every step's `PASS / FAIL / BLOCKED / PENDING` row into the artifact's `## Results Log` and populates `## Failure Diagnosis` on failures.

### Step 3 — Monitor and route

Watch the executor's report. Route per the message form (see [`agents/test-executor.md`](../agents/test-executor.md)):

- **`All steps passed. Results logged.`** — proceed to Step 4.
- **`Step [N] failed: Story bug — …`** — the implementation is wrong. Re-engage the architect/builder loop: read the failing step's `Failure Diagnosis`, decide whether the fix is a plan amendment (rare for a test failure — only when the plan missed a step) or an implementation correction the builder can re-execute. For Standard path, route the fix through `/e4-execute-plan` (the orchestrator may patch the plan or hand a corrective step to the builder); for Quick path, the primary agent applies the fix inline. After fixing, re-invoke `/e5-execute-tests {slug}` — the executor will read existing `Results Log` rows and walk the plan per its persona contract (see [`agents/test-executor.md`](../agents/test-executor.md)).
- **`Step [N] failed: Test bug — …`** — the test itself is wrong. The testing plan needs to change. Halt and invoke `/e3b-write-testing-plan {slug}` to patch and re-validate, then re-invoke `/e5-execute-tests {slug}`.
- **`Step [N] failed: Spec gap — …`** — the test correctly proved that the spec is incomplete. Invoke the **Re-baseline Protocol** per [`SHAMT_RULES.template.md`](../../../../templates/SHAMT_RULES.template.md#requirement-re-baseline-protocol) — create new `spec_vN.md` (and `context_vN.md` + `implementation_plan_vN.md` on Standard path only — Quick path has neither artifact), update `active_artifacts.md`, re-validate, re-approve at Gate 2b (and Gate 3 on Standard path only), redo any affected Build steps, then re-invoke `/e5-execute-tests`. Do **not** patch the existing spec in place.
- **`Step [N] is ambiguous: …`** — clarify with the user via `AskUserQuestion` (open-questions iterative dialog, Principle 2). Update the testing plan if the answer is design-level; re-validate; re-hand off.
- **`Plan defect at Step [N]: …`** — the testing plan itself is broken. Patch via `/e3b-write-testing-plan`, re-validate, re-hand off.
- **`Environment blocked at Step [N]: …`** — the executor tried and failed to resolve the environment. Surface the failure to the user with a one-question dialog: which infrastructure piece is missing (credentials? service? dependency?). After the user resolves it externally, re-invoke `/e5-execute-tests`. **Do not** allow "document and skip" — Phase 5 blocks until every step passes (per [`SHAMT_RULES.template.md`](../../../../templates/SHAMT_RULES.template.md#when-automated-testing-is-enabled)).

### Step 4 — Post-execution

After the executor reports `All steps passed. Results logged.`:

1. Walk the `## Results Log` table in the artifact. Confirm every row reads `PASS` (no `PENDING`, `BLOCKED`, or `FAIL`). If any row is still non-`PASS`, this command has **not** exited — re-hand off.
2. Walk the `## Failure Diagnosis` section. Each documented failure should have a `Re-run result` of `PASS` and a non-empty `Resolution`.
3. Confirm the `## Shared Teardown` (if declared) was executed.
4. Phase 5 is complete.

### Step 5 — Exit

Suggest the next phase: `/clear`, then `/e6-review-changes {slug}` (Phase 6 — Story-mode review).

Also suggest `/e5b-write-manual-testing-plan {slug}` when the story touched UI / cloud infra / external integrations / multi-user flows — automated tests cover the structural surface; manual scenarios cover what they cannot.

## Exit criteria

- `## Results Log` shows `PASS` for every step.
- `## Failure Diagnosis` (when populated) has a `Re-run result: PASS` row for every documented failure.
- No `Step failed`, `Plan defect`, or `Environment blocked` report is outstanding.
- The executor reported `All steps passed. Results logged.`.

## Notes

- This command is **fresh-agent runnable**: the active spec, plan, testing plan, and active-artifacts pointer all live on disk. State is determined by the `## Results Log` rows.
- **Blocks-until-pass is intentional** — the framework explicitly forbids "if failure appears environmental, document and skip." Resolve the environment instead. There is no `--skip-failing` flag, no per-step opt-out.
- The **architect/builder split** still applies for Story-bug failures: the orchestrator (this command + the user) decides what to fix; the builder (re-invoked via `/e4-execute-plan`) applies the fix.
- **No tracker postback.** Test results stay in the artifact. The user posts to the tracker manually if they want to.
- Per `reference/model_selection.md`, mis-tiering the executor (e.g., spawning Sonnet for mechanical test execution) is a configuration finding — fix the tier and re-invoke.

---
Validated 2026-05-28 — 4 rounds, 1 adversarial sub-agent confirmed (Phase 6 implementation loop)

<!-- Managed by Shamt — do not edit. Regenerate from shamt-core/host/templates/claude/commands/e5-execute-tests.md. -->
