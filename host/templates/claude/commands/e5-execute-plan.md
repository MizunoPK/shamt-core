---
description: Phase 5 (Build) — execute the approved implementation_plan.md via the plan-executor builder persona (architect/builder split); plan-executor always runs; next phase is /e6-execute-tests
---

# /e5-execute-plan

**Purpose:** Run Phase 5 (Build) of the Engineer flow. Hand off the validated `implementation_plan.md` to the `plan-executor` builder persona (architect/builder split — the architect's planning ended at Gate 3; the cheap-tier builder executes mechanically). Every story has a validated plan (Plan is mandatory), so the builder handoff is **unconditional** — there is no inline build path.

**Recommended models:**

- Orchestration (this command): Balanced (Sonnet) — the orchestrator monitors the builder, surfaces ambiguity to the user, and decides whether to patch the plan, re-baseline, or re-hand off.
- Execution: Cheap (Haiku) via [`agents/plan-executor.md`](../agents/plan-executor.md).

See [`reference/model_selection.md`](../../../../reference/model_selection.md).

---

## Usage

```
/e5-execute-plan {slug}
```

## Arguments

- `{id-or-slug}` (required) — story ticket ID (`T{N}`) or slug. Resolved via the global story-folder rules (ID glob `stories/{ID}-*/`, else the both-positions slug glob; halt on multiple or zero matches per the Global Story Invariants in [`SHAMT_RULES.template.md`](../../../../templates/SHAMT_RULES.template.md#global-story-invariants)).

## Prerequisites

- Resolve the story folder per `templates/SHAMT_RULES.template.md` §PO-tree resolution (tree-wide glob + legacy-flat fallback); `stories/{slug}/` below denotes that resolved folder. If `stories/{slug}/active_artifacts.md` exists, read it first and use the artifact paths listed under **Active Files**.
- The active spec exists with a validation footer and is approved at Gate 2b.
- The active `implementation_plan.md` (or the active phase file from a phase-decomposed plan) exists with a validation footer and is approved at Gate 3. If missing or unfootered, halt and direct the user to `/e3-plan-implementation {slug}`.
- The story branch will be created during Build per the **Story branch baseline rule** in [`SHAMT_RULES.template.md`](../../../../templates/SHAMT_RULES.template.md#global-story-invariants) — fetched from the configured remote development branch, created as `feature/{slug}/<owner-or-team>`. **Sanity check before delegating:** if the `feature/{slug}/...` branch already exists locally, halt and report rather than letting the build silently rebase or overwrite it. (Multi-repo plans encode branch creation as `Step 0-A`, `Step 0-B`, etc.; single-repo plans either include a `Step 0` for branch creation or rely on the user having created the branch correctly before invocation.)

## Build (architect/builder split)

The plan was validated and approved at Gate 3 specifically so the builder can run it mechanically. Builder handoff is **unconditional** — the orchestrator (you) does not execute steps itself.

### Step 1 — Plan preflight

1. Apply the active-artifact pointer; resolve the plan path (`implementation_plan.md` or `implementation_plan_vN.md`; or one phase file from a phase-decomposed plan).
2. Read the plan top-to-bottom. Confirm footer + Gate 3 approval. Confirm the `## Verification` section exists.
3. For phase-decomposed plans (per the single-session sizing constraint in [`SHAMT_RULES.template.md`](../../../../templates/SHAMT_RULES.template.md#principle-1-phase-per-command--slug-resumability) Principle 1), hand off **one phase at a time in deploy order**. Do not hand off `implementation_plan_phase_2.md` until phase 1 has reported `All steps completed. Verification passed.`.
4. **Refresh the epic STATUS.md.** On Build entry, **re-derive the parent epic's `STATUS.md` from disk** per [`commands/po-status.md`](po-status.md) (resolve the epic from the story's folder path) — this story now shows as `Building`. Re-derive the **whole table** (never patch a cell); the rollup is a derived VIEW per [`reference/epic_status_board.md`](../../../../reference/epic_status_board.md).

### Step 2 — Builder handoff

Spawn the `plan-executor` persona — see [`agents/plan-executor.md`](../agents/plan-executor.md). Provide:

- `slug`,
- `plan_path` (resolved in Step 1),
- `active_artifacts_path` when present.

Example invocation (Claude Code Task tool):

```text
subagent_type: plan-executor
description: Execute {slug} implementation plan
prompt: |
  slug: {slug}
  plan_path: stories/{slug}/implementation_plan.md  # or _vN / _phase_N variant
  active_artifacts_path: stories/{slug}/active_artifacts.md  # when present
  Execute the plan per the persona contract. Halt on the first failure or ambiguity.
```

### Step 3 — Monitor and route

Watch the builder's report. Route per the message form (see [`agents/plan-executor.md`](../agents/plan-executor.md)):

- **`All steps completed. Verification passed.`** — proceed to Step 4.
- **`Step [N] failed: …`** — the architect must diagnose. Read the failed step in context, decide whether the plan is wrong (patch it via `/e3-plan-implementation`, re-validate, re-hand off) or the implementation drifted (the builder reports specifically enough that the architect can correct the plan or escalate). On a substantial change, invoke the **Re-baseline Protocol** per [`SHAMT_RULES.template.md`](../../../../templates/SHAMT_RULES.template.md#requirement-re-baseline-protocol).
- **`Step [N] is ambiguous: …`** — clarify with the user via `AskUserQuestion` (open-questions iterative dialog, Principle 2). Update the plan if the answer is product-level; re-validate; re-hand off. If the answer is a pure mechanical disambiguation that does not change the plan's intent, you may pass the clarification back to the builder for the same plan version.
- **`Plan defect at Step [N]: …`** — the plan itself is broken. Patch via `/e3-plan-implementation`, re-validate, re-hand off.

The architect (this orchestrator) re-engages **only** on builder-reported failure / ambiguity / plan defect. Do not interleave architect-style edits with passing steps.

### Step 4 — Post-build verification

After the builder reports completion:

1. Walk the plan's `## Verification` section end-to-end. Every item must pass; re-run any verification the builder skipped or that needs orchestrator-side context (e.g., reading the rendered output of a CREATE step). **For a phase-decomposed plan, this means the *index* file's whole-plan `## Verification (post-execution, whole plan)` section, run here after the final phase reports `All steps completed. Verification passed.`** — those cross-phase invariants (zero-match sweeps, expected counts, link sweeps depending on more than one phase's output) are the architect's to run, never the builder's, since `plan-executor` handed a single phase file cannot observe the others' output (see [`agents/plan-executor.md`](../agents/plan-executor.md) Post-execution Step 1).
2. Walk the plan's `## Review Prevention Gate Mapping`. For each gate, confirm the change either covers it concretely or matches the explicit N/A reason.
3. Walk the plan's `## CODING_STANDARDS Compliance` mapping (when present). Re-confirm each row against the changes you made.
4. If a verification fails post-builder, treat it as a `Step [N] failed` report — diagnose, patch the plan, re-hand off; do **not** improvise a fix.

### Step 5 — Exit

Suggest the next phase:

- Always → `/clear`, then `/e6-execute-tests {slug}` (Phase 6 — Test, **required**). Phase 6 runs the
  agent-as-user execution of `user_test_plan.md` (and automated suites when `TESTING_STANDARDS.md` declares them), then suggests
  `/e7-review-changes {slug}`.

## Exit criteria

- The plan's `## Verification` section passes end-to-end.
- The plan's `## Review Prevention Gate Mapping` is satisfied or explicitly N/A per stored reason.
- The builder reported `All steps completed. Verification passed.` and you confirmed it post-builder.

## Notes

- This command is **fresh-agent runnable**: the active spec, plan, and active-artifact pointer all live on disk. The builder reads the plan itself; the orchestrator reads the plan footer + verification section + active-artifacts pointer. No conversation history is required to resume.
- The **architect/builder split** is the single biggest token-discipline lever in the Build phase. Do not let an Opus orchestrator wander into mechanical edits — those belong to the Haiku builder.
- **Single-session sizing constraint** ([`SHAMT_RULES.template.md`](../../../../templates/SHAMT_RULES.template.md#principle-1-phase-per-command--slug-resumability) Principle 1): if a plan would compact a single Build session, it should already have been split at Phase 3. If you discover the constraint is being violated mid-Build, halt and split the plan rather than continuing past compaction.
- **Branch baseline rule** is non-negotiable — branches are created from the fetched remote development branch, not from local HEAD.
- **No tracker postback.** Build phase produces commits per the plan's convention (e.g., `#{slug}: {message}`); pushing, opening a PR, and posting to the tracker stay manual operations the user runs after Polish.

---
Validated 2026-05-28 — 4 rounds, 1 adversarial sub-agent confirmed (Phase 6 implementation loop)

<!-- Managed by Shamt — do not edit. Regenerate from shamt-core/host/templates/claude/commands/e5-execute-plan.md. -->
