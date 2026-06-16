---
description: Phase 4 (Build) — execute the approved implementation_plan.md (Standard path, via the plan-executor builder persona) or run the spec's Build Checklist directly (Quick path)
---

# /e4-execute-plan

**Purpose:** Run Phase 4 (Build) of the Engineer flow. Standard path hands off the validated `implementation_plan.md` to the `plan-executor` builder persona (architect/builder split — the architect's planning ended at Gate 3; the cheap-tier builder executes mechanically). Quick path executes the spec's Build Checklist inline because no separate plan exists.

**Recommended models:**

- Orchestration (this command): Balanced (Sonnet) — the orchestrator monitors the builder, surfaces ambiguity to the user, and decides whether to patch the plan, re-baseline, or re-hand off.
- Standard-path execution: Cheap (Haiku) via [`agents/plan-executor.md`](../agents/plan-executor.md).
- Quick-path execution: Balanced (Sonnet) — the primary agent executes the Build Checklist directly.

See [`reference/model_selection.md`](../../../../reference/model_selection.md).

---

## Usage

```
/e4-execute-plan {slug}
```

## Arguments

- `{id-or-slug}` (required) — story ticket ID (`T{N}`) or slug. Resolved via the global story-folder rules (ID glob `stories/{ID}-*/`, else the both-positions slug glob; halt on multiple or zero matches per the Global Story Invariants in [`SHAMT_RULES.template.md`](../../../../templates/SHAMT_RULES.template.md#global-story-invariants)).

## Prerequisites

- Resolve the story folder per `templates/SHAMT_RULES.template.md` §PO-tree resolution (tree-wide glob + legacy-flat fallback); `stories/{slug}/` below denotes that resolved folder. If `stories/{slug}/active_artifacts.md` exists, read it first and use the artifact paths listed under **Active Files**.
- The active spec exists with a validation footer and is approved at Gate 2b.
- **Standard path:** the active `implementation_plan.md` (or the active phase file from a phase-decomposed plan) exists with a validation footer and is approved at Gate 3. If missing or unfootered, halt and direct the user to `/e3-plan-implementation {slug}`.
- **Quick path:** the active `spec.md` has a populated `## Build Checklist` section. If missing, halt and direct the user back to `/e2-define-spec {slug}`.
- The story branch will be created during Build per the **Story branch baseline rule** in [`SHAMT_RULES.template.md`](../../../../templates/SHAMT_RULES.template.md#global-story-invariants) — fetched from the configured remote development branch, created as `feature/{slug}/<owner-or-team>`. **Sanity check before delegating:** if the `feature/{slug}/...` branch already exists locally, halt and report rather than letting the build silently rebase or overwrite it. (Multi-repo plans encode branch creation as `Step 0-A`, `Step 0-B`, etc.; single-repo plans either include a `Step 0` for branch creation or rely on the user having created the branch correctly before invocation.)

## Path selection

Read the active spec's `Path:` header.

- `Path: Quick path` → run the **Quick build** flow below.
- `Path: Standard path` → run the **Standard build** flow below.

State the chosen flow and reason in one line before the first action.

## Standard build (architect/builder split)

The plan was validated and approved at Gate 3 specifically so the builder can run it mechanically. Builder handoff is **unconditional** — the orchestrator (you) does not execute steps itself.

### Step 1 — Plan preflight

1. Apply the active-artifact pointer; resolve the plan path (`implementation_plan.md` or `implementation_plan_vN.md`; or one phase file from a phase-decomposed plan).
2. Read the plan top-to-bottom. Confirm footer + Gate 3 approval. Confirm the `## Verification` section exists.
3. For phase-decomposed plans (per the single-session sizing constraint in [`SHAMT_RULES.template.md`](../../../../templates/SHAMT_RULES.template.md#principle-1-phase-per-command--slug-resumability) Principle 1), hand off **one phase at a time in deploy order**. Do not hand off `implementation_plan_phase_2.md` until phase 1 has reported `All steps completed. Verification passed.`.

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

- Always → `/clear`, then `/e5-execute-tests {slug}` (Phase 5 — **required**). Phase 5 runs the
  agent-as-user execution (and automated suites when `TESTING_STANDARDS.md` declares them), then suggests
  `/e6-review-changes {slug}`.

Suggest `/e5b-write-manual-testing-plan {slug}` (orthogonal to the required Phase-5 agent-as-user execution) when the story touched UI behavior, cloud infra, external integrations, or multi-user flows — per [`SHAMT_RULES.template.md`](../../../../templates/SHAMT_RULES.template.md#optional-post-build-artifact).

## Quick build (direct execution)

No `implementation_plan.md` exists on the Quick path — the spec's `## Build Checklist` is the executable artifact (per Pattern 5 in [`SHAMT_RULES.template.md`](../../../../templates/SHAMT_RULES.template.md#pattern-5-implementation-planning)). The primary agent (you) executes the checklist directly.

1. Apply the active-artifact pointer; resolve the spec path.
2. Read the spec completely — `## Code Shapes`, `## Review Prevention Checklist`, `## Build Checklist`, `## Verification`.
3. Execute the Build Checklist steps in order. Each step is a small, sequential, mechanical action — the same operation contracts apply (CREATE / EDIT / DELETE / MOVE).
4. On ambiguity or a failed verification, **stop and investigate**. Quick-path mid-Build escalations:
   - If the checklist has grown past ~10 steps during execution, you have crossed the Quick→Standard threshold. Halt, suggest escalation: `/e3-plan-implementation {slug}` (architect for what remains) per Pattern 5's escalation triggers.
   - If exact locate/replace detail is now required (e.g., touching a sensitive code path the checklist skimmed), halt and escalate to a plan.
   - If a builder sub-agent is now needed (e.g., the remaining work is large enough to compact within this session), halt and escalate.
   - If the user explicitly asks for Gate 3, halt and escalate.
5. Run the spec's `## Verification` end-to-end. Every item must pass.
6. Exit per Step 5 above (suggest `/e5-execute-tests`, `/e6-review-changes`, `/e5b-write-manual-testing-plan` per config and scope).

Quick-path Build does not hand off to `plan-executor` (no validated plan to feed it). If you find yourself wanting a builder, that is the escalation signal.

## Exit criteria

- Working tree contains the changes the active plan / Build Checklist describes.
- The plan's (or spec's) `## Verification` section passes end-to-end.
- The plan's `## Review Prevention Gate Mapping` (Standard) or the spec's `## Review Prevention Checklist` (Quick) is satisfied or explicitly N/A per stored reason.
- The builder (Standard) reported `All steps completed. Verification passed.` and you confirmed it post-builder.

## Notes

- This command is **fresh-agent runnable**: the active spec, plan, and active-artifact pointer all live on disk. The builder reads the plan itself; the orchestrator reads the plan footer + verification section + active-artifacts pointer. No conversation history is required to resume.
- The **architect/builder split** is the single biggest token-discipline lever in the Standard path. Do not let an Opus orchestrator wander into mechanical edits — those belong to the Haiku builder.
- **Single-session sizing constraint** ([`SHAMT_RULES.template.md`](../../../../templates/SHAMT_RULES.template.md#principle-1-phase-per-command--slug-resumability) Principle 1): if a plan would compact a single Build session, it should already have been split at Phase 3. If you discover the constraint is being violated mid-Build, halt and split the plan rather than continuing past compaction.
- **Branch baseline rule** is non-negotiable — branches are created from the fetched remote development branch, not from local HEAD.
- **No tracker postback.** Build phase produces commits per the plan's convention (e.g., `#{slug}: {message}`); pushing, opening a PR, and posting to the tracker stay manual operations the user runs after Polish.

---
Validated 2026-05-28 — 4 rounds, 1 adversarial sub-agent confirmed (Phase 6 implementation loop)

<!-- Managed by Shamt — do not edit. Regenerate from shamt-core/host/templates/claude/commands/e4-execute-plan.md. -->
