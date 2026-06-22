---
description: Phase 6 (Test, required) — execute user_test_plan.md as a user via the user-simulator persona (always) plus the automated testing_plan.md via test-executor (when TESTING_STANDARDS.md declares suites); a failure routes to /e8 with a required root-cause section; blocks until green
---

# /e6-execute-tests

**Purpose:** Run the **required** Phase 6 (Test). Always perform the **agent-as-user execution** — hand off to the `user-simulator` persona, which **executes `stories/{slug}/user_test_plan.md`** by driving the project as a user (using `TESTING_STANDARDS.md` as conventions input) and writes `agent_test_session.md`. When `TESTING_STANDARDS.md` declares automated suites, also run them via the `test-executor` persona. **Block until every scenario / step reports `PASS`.** A failure is a post-implementation bug → route to `/e8-resolve-feedback` (see Step 3).

**Recommended models:**

- Orchestration (this command): Balanced (Sonnet) — interpret test-executor reports, decide between fix-in-place / patch-the-plan / re-baseline.
- Execution: Cheap (Haiku) via [`agents/test-executor.md`](../agents/test-executor.md).

See [`reference/model_selection.md`](../../../../reference/model_selection.md).

---

## Usage

```
/e6-execute-tests {slug}
```

## Arguments

- `{id-or-slug}` (required) — story ticket ID (`T{N}`) or slug. Resolved via the global story-folder rules (ID glob `stories/{ID}-*/`, else the both-positions slug glob; halt on multiple or zero matches).

## Required phase

Phase 6 runs on **every** story (per `templates/SHAMT_RULES.template.md` §Testing and
[`reference/testing.md`](../../../../reference/testing.md)) — there is no `testing` config flag and no
no-op. It always runs the **agent-as-user execution** (Step 0 — the `user-simulator` executes
`user_test_plan.md`) and, when
`.shamt-core/project-specific-files/TESTING_STANDARDS.md` declares **automated suites present**, the
**automated** execution (Step 2). It **blocks until green**.

## Prerequisites

- Resolve the story folder per `templates/SHAMT_RULES.template.md` §PO-tree resolution (tree-wide glob + legacy-flat fallback); `stories/{slug}/` below denotes that resolved folder. If `stories/{slug}/active_artifacts.md` exists, read it first and use the artifact paths listed under **Active Files**.
- The active spec exists with a validation footer.
- The active plan exists with a validation footer **and Phase 5 (Build) has completed** — code-under-test is in the working tree. If Build has not run yet, halt and direct the user to `/e5-execute-plan {slug}` first.
- `stories/{slug}/user_test_plan.md` exists with a validation footer (authored in Phase 4 — Test Plan). If missing or unfootered, halt and direct the user to `/e4-write-test-plan {slug}`.
- `.shamt-core/project-specific-files/TESTING_STANDARDS.md` exists and is validated (the agent-as-user run reads it as conventions input; if all-placeholder, halt and direct the user to complete it via the init completion prompt).
- **When `TESTING_STANDARDS.md` declares automated suites,** `stories/{slug}/testing_plan.md` (or `testing_plan_vN.md`) exists with a validation footer. If the active testing artifact is not validated, halt and direct the user to `/e4-write-test-plan {slug}`.

## Step-by-step

### Step 0 — Agent-as-user execution (always)

Hand off to the `user-simulator` persona (see [`agents/user-simulator.md`](../agents/user-simulator.md)).
Provide `slug`, `user_test_plan_path = stories/{slug}/user_test_plan.md`, and
`testing_standards_path = .shamt-core/project-specific-files/TESTING_STANDARDS.md`. It **executes the
scenarios in `user_test_plan.md`** by driving the project as a user (using `TESTING_STANDARDS.md` as
conventions input, not as the scenario source), writes `stories/{slug}/agent_test_session.md`, and reports
`Session PASS` / `Session BLOCKED: …`. On `BLOCKED`, route the failing scenario(s) per Step 3 (bug →
`/e8`). If `TESTING_STANDARDS.md` declares **no automated suites**, Step 0 is the whole required pass —
on `Session PASS`, skip to Step 4.

### Step 1 — Resolve the active testing artifact (automated suites only)

1. Apply the active-artifact pointer.
2. Read the spec's `## Test Strategy`.
3. Resolve the executable surface: `stories/{slug}/testing_plan.md` (or `_vN`).
4. Confirm the artifact's validation footer. If missing, halt.

### Step 2 — Hand off to the test-executor

Spawn the `test-executor` persona — see [`agents/test-executor.md`](../agents/test-executor.md). Provide:

- `slug`,
- `testing_plan_path` (the resolved artifact path),
- `active_artifacts_path` when present.

Example invocation (Claude Code Task tool):

```text
subagent_type: test-executor
description: Execute {slug} testing plan
prompt: |
  slug: {slug}
  testing_plan_path: stories/{slug}/testing_plan.md
  active_artifacts_path: stories/{slug}/active_artifacts.md  # when present
  Execute the testing plan per the persona contract. Resolve environmental issues; do not skip them. Halt on the first Story-bug / Test-bug / Spec-gap failure and report.
```

The persona logs every step's `PASS / FAIL / BLOCKED / PENDING` row into the artifact's `## Results Log` and populates `## Failure Diagnosis` on failures.

### Step 3 — Monitor and route

Watch the executor's report. Route per the message form (see [`agents/test-executor.md`](../agents/test-executor.md)):

- **`All steps passed. Results logged.`** — proceed to Step 4.
- **`Session BLOCKED:` (agent-as-user FAIL)** — a scenario's observed behavior did not match expected. This is a **post-implementation bug**: route it through `/e8-resolve-feedback {slug}` as a feedback item (it requires the phase-attributed root-cause section — see `/e8`), apply the fix, and **re-invoke `/e6-execute-tests {slug}`** to re-run Phase 6 to green. (`HALT` results are not passes — resolve the ambiguity, do not proceed to Review.)
- **`Step [N] failed: Story bug — …`** — the implementation is wrong. Re-engage the architect/builder loop: read the failing step's `Failure Diagnosis`, decide whether the fix is a plan amendment (rare for a test failure — only when the plan missed a step) or an implementation correction the builder can re-execute. Route the fix through `/e5-execute-plan` (the orchestrator may patch the plan or hand a corrective step to the builder). After fixing, re-invoke `/e6-execute-tests {slug}` — the executor will read existing `Results Log` rows and walk the plan per its persona contract (see [`agents/test-executor.md`](../agents/test-executor.md)).
- **`Step [N] failed: Test bug — …`** — the test itself is wrong. The testing plan needs to change. Halt and invoke `/e4-write-test-plan {slug}` to patch and re-validate, then re-invoke `/e6-execute-tests {slug}`.
- **`Step [N] failed: Spec gap — …`** — the test correctly proved that the spec is incomplete. Invoke the **Re-baseline Protocol** per [`SHAMT_RULES.template.md`](../../../../templates/SHAMT_RULES.template.md#requirement-re-baseline-protocol) — create new `spec_vN.md`, `context_vN.md`, and `implementation_plan_vN.md`, update `active_artifacts.md`, re-validate, re-approve at Gate 2b and Gate 3, redo any affected Build steps, then re-invoke `/e6-execute-tests`. Do **not** patch the existing spec in place.
- **`Step [N] is ambiguous: …`** — clarify with the user via `AskUserQuestion` (open-questions iterative dialog, Principle 2). Update the testing plan if the answer is design-level; re-validate; re-hand off.
- **`Plan defect at Step [N]: …`** — the testing plan itself is broken. Patch via `/e4-write-test-plan`, re-validate, re-hand off.
- **`Environment blocked at Step [N]: …`** — the executor tried and failed to resolve the environment. Surface the failure to the user with a one-question dialog: which infrastructure piece is missing (credentials? service? dependency?). After the user resolves it externally, re-invoke `/e6-execute-tests`. **Do not** allow "document and skip" — Phase 6 blocks until every step passes (per [`SHAMT_RULES.template.md`](../../../../templates/SHAMT_RULES.template.md#testing-phase-6--required)).

### Step 4 — Post-execution

After the executor reports `All steps passed. Results logged.`:

1. Walk the `## Results Log` table in the artifact. Confirm every row reads `PASS` (no `PENDING`, `BLOCKED`, or `FAIL`). If any row is still non-`PASS`, this command has **not** exited — re-hand off.
2. Walk the `## Failure Diagnosis` section. Each documented failure should have a `Re-run result` of `PASS` and a non-empty `Resolution`.
3. Confirm the `## Shared Teardown` (if declared) was executed.
4. Phase 6 is complete.

### Step 5 — Exit

Suggest the next phase: `/clear`, then `/e7-review-changes {slug}` (Phase 7 — Story-mode review).

## Exit criteria

- `## Results Log` shows `PASS` for every step.
- `## Failure Diagnosis` (when populated) has a `Re-run result: PASS` row for every documented failure.
- No `Step failed`, `Plan defect`, or `Environment blocked` report is outstanding.
- The executor reported `All steps passed. Results logged.`.

## Notes

- This command is **fresh-agent runnable**: the active spec, plan, testing plan, and active-artifacts pointer all live on disk. State is determined by the `## Results Log` rows.
- **Blocks-until-pass is intentional** — the framework explicitly forbids "if failure appears environmental, document and skip." Resolve the environment instead. There is no `--skip-failing` flag, no per-step opt-out.
- The **architect/builder split** still applies for Story-bug failures: the orchestrator (this command + the user) decides what to fix; the builder (re-invoked via `/e5-execute-plan`) applies the fix.
- **No tracker postback.** Test results stay in the artifact. The user posts to the tracker manually if they want to.
- Per `reference/model_selection.md`, mis-tiering the executor (e.g., spawning Sonnet for mechanical test execution) is a configuration finding — fix the tier and re-invoke.

---
Validated 2026-05-28 — 4 rounds, 1 adversarial sub-agent confirmed (Phase 6 implementation loop)

<!-- Managed by Shamt — do not edit. Regenerate from shamt-core/host/templates/claude/commands/e6-execute-tests.md. -->
