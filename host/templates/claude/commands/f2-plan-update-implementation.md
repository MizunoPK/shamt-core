---
description: Phase 3 (optional) of the framework-update flow — when a proposal touches more than 10 canonical files, produce a mechanical, validated implementation plan at proposals/{slug}_PLAN.md before edits begin
---

# /f2-plan-update-implementation

**Purpose:** Run the optional Phase 3 of the framework-update flow. When a validated proposal exceeds the **10 canonical file operations** threshold, the architect produces a mechanical implementation plan that decomposes the proposal's Proposed Changes table into ordered, individually executable steps with locate strings and verifications. The plan itself goes through `/validate-artifact` before `/f3-implement-update` runs.

The 10-op threshold is a framework-altitude expression of the [single-session sizing constraint](../../../../templates/SHAMT_RULES.template.md#principle-1-phase-per-command--slug-resumability) (Principle 1): plans that would compact a single Phase-4 session should be split or escalated to the architect/builder split. At the story altitude the analogous trigger is implementation-step count; at the framework altitude file-operation count is the better proxy because each row maps to at least one mechanical edit.

**Recommended models:**

- Architect (this command, plan authoring): Balanced (Sonnet) — structural step decomposition.
- Validation loop primary: Reasoning (Opus); sub-agent: Cheap (Haiku) via `validation-checker` — invoked through `/validate-artifact` (not this command).
- Executor in Phase 4: Cheap (Haiku) via [`agents/plan-executor.md`](../agents/plan-executor.md), reused as-is.

See [`reference/model_selection.md`](../../../../reference/model_selection.md).

---

## Usage

```
/f2-plan-update-implementation {slug}
```

## Arguments

- `{slug}` (required) — proposal slug. Resolves to `proposals/{slug}.md` (the validated proposal) and writes `proposals/{slug}_PLAN.md` (the implementation plan).

## Path applicability

**Only when the proposal's Proposed Changes table has more than 10 rows.** Smaller proposals skip Phase 3: `/f3-implement-update` reads the proposal directly and the primary agent applies edits inline.

When invoked on a ≤10-row proposal, report:

```text
Proposal {slug} has {N} canonical file operations (≤10). Phase 3 plan not
required. Proceed directly to /f3-implement-update {slug}.
```

…then exit without writing `{slug}_PLAN.md`.

If the user explicitly requests a plan for a smaller proposal, honor the request and continue.

## Prerequisites

- `proposals/{slug}.md` exists with a validation footer (Phase 2 complete). If missing or unfootered, halt and direct the user to `/validate-artifact proposals/{slug}.md`.
- The proposal's `## Open Questions` section is empty (validation would not have footered it otherwise — but re-check).
- `proposals/archive/{slug}.md` does **not** exist. If it does, halt and report — this slug has already been implemented.

## Step-by-step

### Step 1 — Read the proposal and confirm scope

1. Read `proposals/{slug}.md` top-to-bottom. Confirm the validation footer is present.
2. Walk the **Proposed Changes** table row by row. For each row:
   - Read the named canonical file (5–10 lines around the target section for EDIT rows; full file for CREATE/DELETE rows).
   - Record the sibling shape if a CREATE is meant to mirror an existing file (e.g., a new skill mirroring `skills/e1-start-story/SKILL.md`).
   - Note any paired files the row implies (rule ↔ template; command ↔ skill; reference ↔ rule pointer). These pairs must already appear as rows in the table — if they don't, halt and direct the user back to `/f1-propose-update` to expand the change list.
3. Re-count the rows. Confirm `N > 10`. If not, exit with the message above.

### Step 2 — Author the plan

Write `proposals/{slug}_PLAN.md`. The plan reuses the **operation contracts** from story-level implementation plans (see [`templates/implementation_plan.template.md`](../../../../templates/implementation_plan.template.md) and [`reference/implementation_plan_reference.md`](../../../../reference/implementation_plan_reference.md)) — CREATE / EDIT / DELETE / MOVE semantics, exact locate strings, verification per step. It does **not** carry the story-altitude sections that do not apply at the framework altitude:

- **Review Prevention Gate Mapping** is omitted. Review-prevention surfaces (regulated/sensitive data, tenant isolation, auth/route, DB writes, infra, frontend safety) are story-altitude concepts; framework canonical edits do not have them.
- **CODING_STANDARDS Compliance mapping** is omitted. Project coding standards apply to project code, not to canonical Shamt prose / templates / scripts.

`plan-executor` (the Phase 4 builder) treats both omissions as N/A; see [`agents/plan-executor.md`](../agents/plan-executor.md) Pre-flight Step 2 and Post-execution Step 2.

**Plan shape:**

```markdown
# Implementation Plan: {slug}

**Proposal:** proposals/{slug}.md
**Created:** {YYYY-MM-DD}
**File operations:** {N} (CREATE: a, EDIT: b, DELETE: c, MOVE: d)

## Pre-execution checklist
- [ ] On a clean working tree (or working in a worktree dedicated to this proposal).
- [ ] `proposals/{slug}.md` validation footer present.
- [ ] Branch created: `framework-update/{slug}` from the configured remote development branch.

## Files manifest

| # | Path | Operation | Sibling / template (if any) |
|---|------|-----------|------------------------------|
| 1 | … | EDIT | — |
| 2 | … | CREATE | mirror of {sibling path} |

## Step-by-step

### Step 1 — {short verb-led title}

**Operation:** EDIT
**File:** {canonical path}
**Locate:**
```
{exact string to find}
```
**Replace:**
```
{exact replacement}
```
**Verification:**
- `grep -F '{replacement marker}' {file}` returns one match.

### Step 2 — …

…

## Verification (post-execution)

- [ ] Every row in the Proposed Changes table has a corresponding step.
- [ ] Every CREATE file exists and matches the sibling shape where one was named.
- [ ] No edits landed in generated `.claude/` paths.
- [ ] `grep -rn "Managed by Shamt" shamt-core/host/templates/claude/` returns the expected footer count (no new generated files leaked in).
- [ ] Mermaid / link / reference targets in edited files still resolve.

## Notes

{Anything the executor needs to know but cannot infer from individual steps:
declared ordering constraints, related-but-out-of-scope items, escalation
triggers, etc.}
```

**Hard rules for the plan body:**

- **No design judgment in steps.** Every EDIT has an exact locate string and exact replacement. Every CREATE has a concrete path and either a full initial content block or a named template/sibling with concrete deltas. Every DELETE has a justification. MOVE = paired CREATE + DELETE rows with verification between them.
- **No `if / when / consider` branches.** Plan order encodes dependency ordering. Each step has a single deterministic outcome.
- **Every step has a verification.** A step without a verification is a plan defect.
- **No generated-file edits.** The plan never touches `.claude/`. Regen (Phase 5) propagates canonical changes into `.claude/`.
- **Phase decomposition** — if the plan would exceed ~1500 lines or a single Phase-4 session would compact, split it into `proposals/{slug}_PLAN_phase_1.md`, `_phase_2.md`, etc., plus an index file `{slug}_PLAN.md`. Each phase file is validated independently. Mirrors the [story-level phase decomposition rule](../../../../templates/SHAMT_RULES.template.md#principle-1-phase-per-command--slug-resumability) (Principle 1, single-session sizing constraint).

### Step 3 — Cross-check against the proposal

Walk the Proposed Changes table again. Confirm:

- **One-to-one row coverage** — every Proposed Changes row maps to at least one step in the plan; every plan step traces back to a Proposed Changes row. Plan steps that don't trace back are scope creep — halt, surface to the user, decide whether to remove the step or extend the proposal via re-baseline.
- **Operation match** — a row marked EDIT in the proposal is an EDIT step in the plan (and so on).

### Step 4 — Suggest validation

The plan is **not** approved for execution until every plan file carries its own validation footer.

- **Single-file plan** (`{slug}_PLAN.md` only) — exit by suggesting `/clear` + `/validate-artifact proposals/{slug}_PLAN.md`.
- **Phase-decomposed plan** (index `{slug}_PLAN.md` + ≥1 `_PLAN_phase_*.md` files) — this is always ≥2 validations (index under the phase-index dimensions, each phase file under the plan dimensions). Emit a **batch-validation handoff prompt** as the **recommended** path — fill the template in [`reference/batch_validation_handoff.md`](../../../../reference/batch_validation_handoff.md) with the actual resolved on-disk paths (the index and each phase file, each with its governing references), and print it for the user to paste into a fresh session. Also print the **sequential per-file fallback** for a user who prefers to drive each step:

  ```text
  /clear
  /validate-artifact proposals/{slug}_PLAN.md
  /clear
  /validate-artifact proposals/{slug}_PLAN_phase_1.md
  /clear
  /validate-artifact proposals/{slug}_PLAN_phase_2.md
  ...
  ```

  Both paths run the same Pattern 1 loop per file — there is no rigor difference. Name **every** file the user must validate (the index and each phase file), not just the index.

## Exit criteria

- `proposals/{slug}_PLAN.md` (or the index + phase files for decomposed plans) exists, non-empty, with one step per Proposed Changes row.
- No step touches `.claude/`.
- Validation has been suggested. The plan does **not** yet carry a footer — that comes from `/validate-artifact`.

## Notes

- **Fresh-agent runnable**: the proposal (with footer) and the canonical files cited in Proposed Changes all live on disk. No conversation history required.
- **Plan-executor reuse** — Phase 4 hands this plan off to the same `plan-executor` persona used for story-level Build (see [`agents/plan-executor.md`](../agents/plan-executor.md)). The plan body conforms to that persona's expected shape; the executor does not know or care that the plan came from a proposal versus a spec.
- **Architect/builder split** — author the plan precisely enough that the cheap-tier builder in Phase 4 executes it mechanically. If you find yourself wanting to defer a design decision into a step ("the builder can figure it out"), halt and either resolve the decision now or return to `/f1-propose-update` to expand the proposal.
- **Re-baseline** — if Phase 4 reports a plan defect, patch the plan, re-run `/validate-artifact proposals/{slug}_PLAN.md`, then re-invoke `/f3-implement-update`. Do not edit the plan in place after Phase 4 has already started executing against it without re-validating.

---
Validated 2026-05-28 — 4 rounds, 1 adversarial sub-agent confirmed (Phase 8 implementation loop)

<!-- Managed by Shamt — do not edit. Regenerate from shamt-core/host/templates/claude/commands/f2-plan-update-implementation.md. -->
