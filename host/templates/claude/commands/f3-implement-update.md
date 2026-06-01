---
description: Phase 4 of the framework-update flow — apply a validated proposal to canonical sources, either inline (≤10 file ops) or by handing off to plan-executor (Phase 3 ran)
---

# /f3-implement-update

**Purpose:** Run Phase 4 of the framework-update flow. Read the validated proposal (and validated `{slug}_PLAN.md` when Phase 3 ran), apply edits to canonical sources, and confirm that the diff covers every item in the proposal's Proposed Changes table.

**Recommended models:**

- Orchestration (this command, ≤10 file ops): Balanced (Sonnet) — reads the proposal, applies edits, monitors verification.
- Standard-path orchestration (when Phase 3 ran): Balanced (Sonnet) — same architect/builder split as the story-level Build phase; the architect monitors the builder.
- Executor (Phase 3 ran): Cheap (Haiku) via [`agents/plan-executor.md`](../agents/plan-executor.md), reused.

See [`reference/model_selection.md`](../../../../reference/model_selection.md).

---

## Usage

```
/f3-implement-update {slug}
```

## Arguments

- `{slug}` (required) — proposal slug. Resolves to `proposals/{slug}.md` and (optionally) `proposals/{slug}_PLAN.md` or phase-decomposed plan files.

## Prerequisites

- `proposals/{slug}.md` exists with a Phase 2 validation footer. If missing or unfootered, halt and direct the user to `/f1-propose-update {slug}` and then `/validate-artifact proposals/{slug}.md`.
- If the proposal declares a Phase 3 note (`Phase 3 required — file count {N} > 10.`) or `proposals/{slug}_PLAN.md` exists, the plan must also carry a validation footer. If missing or unfootered, halt and direct the user to `/f2-plan-update-implementation {slug}` then `/validate-artifact proposals/{slug}_PLAN.md`.
- `proposals/archive/{slug}.md` does **not** exist. If it does, halt and report — this slug has already been implemented.
- Working tree is clean (or the user has confirmed working on a dedicated `framework-update/{slug}` branch). Halt and confirm if the tree has unrelated staged or unstaged changes.

## Path selection

Decide which path to run, state it in one line before any edit:

- **Inline path** — proposal has ≤10 canonical file operations and no `{slug}_PLAN.md` exists. The primary agent applies edits directly.
- **Architect/builder path** — `{slug}_PLAN.md` (or phase files) exists with a validation footer. Hand off to `plan-executor`.

## Step-by-step

### Step 1 — Preflight

1. Read `proposals/{slug}.md` top-to-bottom. Re-confirm the validation footer is present.
2. Walk the **Proposed Changes** table. Build a local checklist mirroring it — one row, one verification slot. This is the artifact of record for the exit gate.
3. Confirm path selection (inline vs. architect/builder).
4. **Hard rule — canonical-only**: enumerate the set of paths the proposal (or plan) will touch. For every path, confirm it lives under one of:
   - `shamt-core/templates/`
   - `shamt-core/reference/`
   - `shamt-core/host/templates/claude/`
   - `shamt-core/scripts/`
   - `shamt-core/proposals/` (when the proposal itself is updating the proposal template or related folder docs)
   - `shamt-core/CLAUDE.md`, `shamt-core/CHEATSHEET.md`, `shamt-core/shamt-config.example.json` (root-level canonical docs)
   - Any path under `shamt-core/` outside the above list **only if** the proposal explicitly justifies it in Validation Considerations or Risks.

   If any path falls under generated `.claude/` (or its child-side equivalent), **halt immediately**. Edits to generated files are always wrong — they get overwritten on the next regen and the canonical source still carries the old version. Direct the user back to `/f1-propose-update` to correct the change list.

### Step 2 — Apply edits

**Inline path:**

1. For each Proposed Changes row, apply the operation directly. CREATE writes the new file. EDIT applies the named edit in the named section. DELETE removes the file or section. MOVE is paired CREATE + DELETE.
2. After each row, run an inline verification appropriate to the operation:
   - **CREATE** — confirm the file exists, has the expected sibling shape (when one was named), carries the `<!-- Managed by Shamt -->` footer for host-template files.
   - **EDIT** — `grep` for the new content to confirm it landed; spot-read the edited section for context.
   - **DELETE** — confirm the file is gone or the section is removed.
3. If a verification fails, stop and diagnose. Do not patch the proposal in place — invoke the [re-baseline protocol](../../../../templates/SHAMT_RULES.template.md#requirement-re-baseline-protocol) on `proposals/{slug}.md` if the proposal itself was wrong, then re-run `/validate-artifact` before resuming. If the proposal was right and the implementation drifted, retry the row.

**Architect/builder path:**

1. Spawn the `plan-executor` persona — see [`agents/plan-executor.md`](../agents/plan-executor.md). Provide:
   - `slug` — the proposal slug.
   - `plan_path` — `proposals/{slug}_PLAN.md` (or one phase file in deploy order for decomposed plans).
   - `active_artifacts_path` — N/A at the framework altitude (no `active_artifacts.md` for proposals); pass empty.

   Example invocation (Claude Code Task tool):

   ```text
   subagent_type: plan-executor
   description: Execute {slug} framework-update plan
   prompt: |
     slug: {slug}
     plan_path: proposals/{slug}_PLAN.md  # or _phase_N variant
     Execute the plan per the persona contract. Halt on the first failure or ambiguity.
     Hard rule: canonical sources only — never edit generated .claude/ files.
   ```

2. Monitor the builder's report. Route per the message form (see [`agents/plan-executor.md`](../agents/plan-executor.md)):
   - **`All steps completed. Verification passed.`** — proceed to Step 3.
   - **`Step [N] failed: …`** — diagnose. Patch the plan and re-validate, or invoke the re-baseline protocol on the proposal.
   - **`Step [N] is ambiguous: …`** — clarify with the user via `AskUserQuestion` (open-questions iterative dialog, Principle 2). Patch and re-validate if the answer is canonical.
   - **`Plan defect at Step [N]: …`** — patch the plan, re-validate, re-hand off.

3. For phase-decomposed plans, hand off **one phase at a time in deploy order**. Do not hand off `{slug}_PLAN_phase_2.md` until phase 1 has reported `All steps completed. Verification passed.`.

### Step 3 — Diff coverage gate

Walk the Proposed Changes table one final time. For each row, confirm the working-tree diff contains the change. Run `git status` and `git diff --stat` against the project root to make the diff visible. The exit gate is:

- [ ] Every Proposed Changes row corresponds to a real change in the diff (or a deletion).
- [ ] No file outside the canonical roots is in the diff.
- [ ] No generated `.claude/` file is in the diff.

If any row is uncovered, treat it as a `Step failed` — diagnose. If the diff contains extra changes not in the table, treat it as scope creep — halt and surface to the user; decide whether to remove the changes or extend the proposal via re-baseline + re-validation.

### Step 4 — Suggest the next phase

Suggest a context-clear and the next command:

- `/clear`, then `/f4-regen-framework` (Phase 5 — propagate canonical edits into `.claude/`).

## Exit criteria

- Every Proposed Changes row covered by a change in the working tree.
- No edits in generated `.claude/` paths.
- The next phase (`/f4-regen-framework`) has been suggested.

## Notes

- **Fresh-agent runnable**: proposal, plan (when present), Proposed Changes table, and on-disk file state are sufficient inputs. No conversation history required.
- **Hard rule — canonical sources only.** The validator and `/f1-propose-update` already enforce this at draft time; `/f3-implement-update` enforces it at edit time. Editing a generated file is always wrong — it gets overwritten on the next regen and the canonical source still carries the old version. If a step's path looks like `.claude/...`, halt unconditionally.
- **No commits here.** This command leaves changes in the working tree. The user commits explicitly after Phase 5 (regen) confirms the propagation worked, so the canonical edit and the generated `.claude/` update land in one commit.
- **Architect/builder split** — the `plan-executor` persona's contract is identical at the framework altitude. The architect (this orchestrator) re-engages only on builder-reported failure / ambiguity / plan defect.
- **Re-baseline protocol** — if a Proposed Changes row turns out wrong mid-implementation, the re-baseline protocol applies to `proposals/{slug}.md` (or `{slug}_PLAN.md`). Patch, re-validate, re-run this command. Do not edit silently.

---
Validated 2026-05-28 — 4 rounds, 1 adversarial sub-agent confirmed (Phase 8 implementation loop)

<!-- Managed by Shamt — do not edit. Regenerate from shamt-core/host/templates/claude/commands/f3-implement-update.md. -->
