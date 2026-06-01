# Implementation Plan — Phase 2: f2 + f3 (glob resolution, f3 branch creation, commit-note)

**Proposal:** proposals/proposal-workflow-conventions.md
**Index:** proposals/proposal-workflow-conventions_PLAN.md
**Created:** 2026-05-30
**Covers:** Proposed Changes rows 5, 6, 7, 8.
**File operations:** 4 EDIT.

## Files manifest (this phase)

| Path | Operation |
|------|-----------|
| `shamt-core/host/templates/claude/commands/f2-plan-update-implementation.md` | EDIT (row 5) |
| `shamt-core/host/templates/claude/skills/f2-plan-update-implementation/SKILL.md` | EDIT (row 6) |
| `shamt-core/host/templates/claude/commands/f3-implement-update.md` | EDIT (row 7) |
| `shamt-core/host/templates/claude/skills/f3-implement-update/SKILL.md` | EDIT (row 8) |

No `.claude/` paths. No CREATE/DELETE/MOVE.

---

## Step 5 — `shamt-core/host/templates/claude/commands/f2-plan-update-implementation.md` (row 5)

### Step 5a — Arguments: glob resolution + same-stem plan filename

**Operation:** EDIT
**Locate:**
```
- `{slug}` (required) — proposal slug. Resolves to `proposals/{slug}.md` (the validated proposal) and writes `proposals/{slug}_PLAN.md` (the implementation plan).
```
**Replace:**
```
- `{slug}` (required) — proposal slug. Resolves the proposal exact-then-glob: `proposals/{slug}.md`, else `proposals/*-{slug}.md` (a master-side numbered `{NN}-{slug}.md`; also accepts a numbered `{NN}-{slug}` stem passed directly). The glob matches at most one file (slugs are unique) — halt and ask on multiple matches. Writes the plan alongside the matched proposal using the **same stem**: `proposals/{NN}-{slug}_PLAN.md` for a numbered proposal, `proposals/{slug}_PLAN.md` for an unnumbered/grandfathered one.
```
**Verification:** `grep -c "exact-then-glob" shamt-core/host/templates/claude/commands/f2-plan-update-implementation.md` returns at least `1`.

### Step 5b — Prerequisite: resolved proposal path

**Operation:** EDIT
**Locate:**
```
- `proposals/{slug}.md` exists with a validation footer (Phase 2 complete). If missing or unfootered, halt and direct the user to `/validate-artifact proposals/{slug}.md`.
```
**Replace:**
```
- The proposal file (resolved exact-then-glob: `proposals/{slug}.md` or `proposals/*-{slug}.md`) exists with a validation footer (Phase 2 complete). If missing or unfootered, halt and direct the user to `/validate-artifact` on the resolved path.
```
**Verification:** `grep -c "resolved exact-then-glob" shamt-core/host/templates/claude/commands/f2-plan-update-implementation.md` returns at least `1`.

### Step 5c — Prerequisite: archive-collision glob

**Operation:** EDIT
**Locate:**
```
- `proposals/archive/{slug}.md` does **not** exist. If it does, halt and report — this slug has already been implemented.
```
**Replace:**
```
- Neither `proposals/archive/{slug}.md` nor `proposals/archive/*-{slug}.md` exists. If either does, halt and report — this slug has already been implemented.
```
**Verification:** `grep -c "archive/\*-{slug}.md" shamt-core/host/templates/claude/commands/f2-plan-update-implementation.md` returns at least `1`.

### Step 5d — Step 1 read: resolved file

**Operation:** EDIT
**Locate:**
```
1. Read `proposals/{slug}.md` top-to-bottom. Confirm the validation footer is present.
```
**Replace:**
```
1. Read the resolved proposal file (`proposals/{slug}.md` or `proposals/*-{slug}.md`) top-to-bottom. Confirm the validation footer is present.
```
**Verification:** `grep -c "Read the resolved proposal file" shamt-core/host/templates/claude/commands/f2-plan-update-implementation.md` returns `1`.

### Step 5e — Embedded plan-shape: Proposal line

**Operation:** EDIT
**Locate:**
```
**Proposal:** proposals/{slug}.md
**Created:** {YYYY-MM-DD}
```
**Replace:**
```
**Proposal:** proposals/{NN}-{slug}.md (or proposals/{slug}.md for an unnumbered/grandfathered proposal)
**Created:** {YYYY-MM-DD}
```
**Verification:** `grep -c "Proposal:\*\* proposals/{NN}-{slug}.md" shamt-core/host/templates/claude/commands/f2-plan-update-implementation.md` returns `1`.

### Step 5f — Embedded plan-shape: branch checklist item is the create-step

**Operation:** EDIT
**Locate:**
```
- [ ] Branch created: `framework-update/{slug}` from the configured remote development branch.
```
**Replace:**
```
- [ ] Branch `proposal/{NN}-{slug}` created from the base branch (`proposal/{slug}` for an unnumbered/grandfathered proposal). This pre-execution checklist item is where the architect/builder path **creates** the proposal branch at the start of Phase 4 — it does not exist during authoring, validation, or planning.
```
**Verification:** `grep -c "proposal/{NN}-{slug}\` created from the base branch" shamt-core/host/templates/claude/commands/f2-plan-update-implementation.md` returns `1`; `grep -c "framework-update/{slug}" shamt-core/host/templates/claude/commands/f2-plan-update-implementation.md` returns `0`.

### Step 5g — Phase-decomposition note: numbered phase-file naming

**Operation:** EDIT
**Locate:**
```
- **Phase decomposition** — if the plan would exceed ~1500 lines or a single Phase-4 session would compact, split it into `proposals/{slug}_PLAN_phase_1.md`, `_phase_2.md`, etc., plus an index file `{slug}_PLAN.md`. Each phase file is validated independently. Mirrors the [story-level phase decomposition rule](../../../../templates/SHAMT_RULES.template.md#principle-1-phase-per-command--slug-resumability) (Principle 1, single-session sizing constraint).
```
**Replace:**
```
- **Phase decomposition** — if the plan would exceed ~1500 lines or a single Phase-4 session would compact, split it into `proposals/{NN}-{slug}_PLAN_phase_1.md`, `_phase_2.md`, etc., plus an index file `{NN}-{slug}_PLAN.md` (drop the `{NN}-` for an unnumbered/grandfathered proposal). Each phase file is validated independently. Mirrors the [story-level phase decomposition rule](../../../../templates/SHAMT_RULES.template.md#principle-1-phase-per-command--slug-resumability) (Principle 1, single-session sizing constraint).
```
**Verification:** `grep -c "proposals/{NN}-{slug}_PLAN_phase_1.md" shamt-core/host/templates/claude/commands/f2-plan-update-implementation.md` returns `1`.

### Step 5h — Step 4 next-phase suggestion: matched-stem plan path

**Operation:** EDIT
**Locate:**
```
Exit by suggesting `/clear` + `/validate-artifact proposals/{slug}_PLAN.md`. The plan is **not** approved for execution until it carries its own validation footer.
```
**Replace:**
```
Exit by suggesting `/clear` + `/validate-artifact` on the plan you just wrote (`proposals/{NN}-{slug}_PLAN.md`, or `proposals/{slug}_PLAN.md` for an unnumbered/grandfathered proposal). The plan is **not** approved for execution until it carries its own validation footer.
```
**Verification:** `grep -c "on the plan you just wrote" shamt-core/host/templates/claude/commands/f2-plan-update-implementation.md` returns `1`.

### Step 5i — Exit criteria: matched-stem plan path

**Operation:** EDIT
**Locate:**
```
- `proposals/{slug}_PLAN.md` (or the index + phase files for decomposed plans) exists, non-empty, with one step per Proposed Changes row.
```
**Replace:**
```
- `proposals/{NN}-{slug}_PLAN.md` (or `proposals/{slug}_PLAN.md` for an unnumbered proposal; or the index + phase files for decomposed plans) exists, non-empty, with one step per Proposed Changes row.
```
**Verification:** `grep -c "proposals/{NN}-{slug}_PLAN.md\` (or" shamt-core/host/templates/claude/commands/f2-plan-update-implementation.md` returns `1`.

---

## Step 6 — `shamt-core/host/templates/claude/skills/f2-plan-update-implementation/SKILL.md` (row 6) — mirror

### Step 6a — Frontmatter description: numbered plan path

**Operation:** EDIT
**Locate:**
```
  mechanical implementation plan at proposals/{slug}_PLAN.md decomposing the
```
**Replace:**
```
  mechanical implementation plan at proposals/{NN}-{slug}_PLAN.md decomposing the
```
**Verification:** `grep -c "proposals/{NN}-{slug}_PLAN.md decomposing" shamt-core/host/templates/claude/skills/f2-plan-update-implementation/SKILL.md` returns `1`.

### Step 6b — Protocol item 2: author at matched-stem path

**Operation:** EDIT
**Locate:**
```
2. **Author the plan** at `proposals/{slug}_PLAN.md` using the operation contracts (CREATE / EDIT / DELETE / MOVE) from [`templates/implementation_plan.template.md`](../../../../../templates/implementation_plan.template.md). Exact locate strings, exact replacements, concrete paths. No `if / when / consider` branches. Every step has a verification. **Never touch `.claude/`.** Decompose into phase files if the plan would compact a single Phase-4 session.
```
**Replace:**
```
2. **Author the plan** at `proposals/{NN}-{slug}_PLAN.md` (same stem as the glob-resolved proposal; `proposals/{slug}_PLAN.md` for an unnumbered/grandfathered proposal) using the operation contracts (CREATE / EDIT / DELETE / MOVE) from [`templates/implementation_plan.template.md`](../../../../../templates/implementation_plan.template.md). Exact locate strings, exact replacements, concrete paths. No `if / when / consider` branches. Every step has a verification. **Never touch `.claude/`.** Decompose into phase files if the plan would compact a single Phase-4 session.
```
**Verification:** `grep -c "proposals/{NN}-{slug}_PLAN.md\` (same stem" shamt-core/host/templates/claude/skills/f2-plan-update-implementation/SKILL.md` returns `1`.

### Step 6c — Protocol item 4: validate matched-stem path

**Operation:** EDIT
**Locate:**
```
4. **Suggest validation** — `/clear` + `/validate-artifact proposals/{slug}_PLAN.md`. The plan is not approved for execution until it carries its own validation footer.
```
**Replace:**
```
4. **Suggest validation** — `/clear` + `/validate-artifact` on the plan just written (`proposals/{NN}-{slug}_PLAN.md`, or `proposals/{slug}_PLAN.md` for an unnumbered proposal). The plan is not approved for execution until it carries its own validation footer.
```
**Verification:** `grep -c "on the plan just written" shamt-core/host/templates/claude/skills/f2-plan-update-implementation/SKILL.md` returns `1`.

### Step 6d — Exit criteria: matched-stem path

**Operation:** EDIT
**Locate:**
```
`proposals/{slug}_PLAN.md` (or index + phase files) exists with one step per Proposed Changes row, no generated-file edits, and `/validate-artifact` has been suggested. The plan carries no footer yet.
```
**Replace:**
```
`proposals/{NN}-{slug}_PLAN.md` (or `proposals/{slug}_PLAN.md` for an unnumbered proposal; or index + phase files) exists with one step per Proposed Changes row, no generated-file edits, and `/validate-artifact` has been suggested. The plan carries no footer yet.
```
**Verification:** `grep -c "proposals/{NN}-{slug}_PLAN.md\` (or \`proposals/{slug}_PLAN.md\` for an unnumbered proposal; or index" shamt-core/host/templates/claude/skills/f2-plan-update-implementation/SKILL.md` returns `1`.

---

## Step 7 — `shamt-core/host/templates/claude/commands/f3-implement-update.md` (row 7)

### Step 7a — Arguments: glob resolution + same-stem plan companion

**Operation:** EDIT
**Locate:**
```
- `{slug}` (required) — proposal slug. Resolves to `proposals/{slug}.md` and (optionally) `proposals/{slug}_PLAN.md` or phase-decomposed plan files.
```
**Replace:**
```
- `{slug}` (required) — proposal slug. Resolves the proposal exact-then-glob: `proposals/{slug}.md`, else `proposals/*-{slug}.md` (numbered `{NN}-{slug}.md`; also accepts a numbered `{NN}-{slug}` stem directly). The matching plan companion uses the same stem: `proposals/{NN}-{slug}_PLAN.md` (or `proposals/{slug}_PLAN.md`) and phase-decomposed `_PLAN_phase_*.md` files. The glob matches at most one file (slugs are unique) — halt and ask on multiple matches.
```
**Verification:** `grep -c "exact-then-glob" shamt-core/host/templates/claude/commands/f3-implement-update.md` returns at least `1`.

### Step 7b — Prerequisite: resolved proposal path

**Operation:** EDIT
**Locate:**
```
- `proposals/{slug}.md` exists with a Phase 2 validation footer. If missing or unfootered, halt and direct the user to `/f1-propose-update {slug}` and then `/validate-artifact proposals/{slug}.md`.
```
**Replace:**
```
- The proposal file (resolved exact-then-glob: `proposals/{slug}.md` or `proposals/*-{slug}.md`) exists with a Phase 2 validation footer. If missing or unfootered, halt and direct the user to `/f1-propose-update {slug}` and then `/validate-artifact` on the resolved path.
```
**Verification:** `grep -c "resolved exact-then-glob" shamt-core/host/templates/claude/commands/f3-implement-update.md` returns at least `1`.

### Step 7c — Prerequisite: plan companion stem

**Operation:** EDIT
**Locate:**
```
- If the proposal declares a Phase 3 note (`Phase 3 required — file count {N} > 10.`) or `proposals/{slug}_PLAN.md` exists, the plan must also carry a validation footer. If missing or unfootered, halt and direct the user to `/f2-plan-update-implementation {slug}` then `/validate-artifact proposals/{slug}_PLAN.md`.
```
**Replace:**
```
- If the proposal declares a Phase 3 note (`Phase 3 required — file count {N} > 10.`) or a `proposals/{NN}-{slug}_PLAN.md` / `proposals/{slug}_PLAN.md` companion exists, the plan must also carry a validation footer. If missing or unfootered, halt and direct the user to `/f2-plan-update-implementation {slug}` then `/validate-artifact` on the resolved plan path.
```
**Verification:** `grep -c "{NN}-{slug}_PLAN.md\` / \`proposals/{slug}_PLAN.md\` companion" shamt-core/host/templates/claude/commands/f3-implement-update.md` returns `1`.

### Step 7d — Prerequisite: archive-collision glob

**Operation:** EDIT
**Locate:**
```
- `proposals/archive/{slug}.md` does **not** exist. If it does, halt and report — this slug has already been implemented.
```
**Replace:**
```
- Neither `proposals/archive/{slug}.md` nor `proposals/archive/*-{slug}.md` exists. If either does, halt and report — this slug has already been implemented.
```
**Verification:** `grep -c "archive/\*-{slug}.md" shamt-core/host/templates/claude/commands/f3-implement-update.md` returns at least `1`.

### Step 7e — Prerequisite: working-tree clean + f3 creates the branch

**Operation:** EDIT
**Locate:**
```
- Working tree is clean (or the user has confirmed working on a dedicated `framework-update/{slug}` branch). Halt and confirm if the tree has unrelated staged or unstaged changes.
```
**Replace:**
```
- Working tree is clean. Halt and confirm if the tree has unrelated staged or unstaged changes. (This command **creates** the `proposal/{NN}-{slug}` branch in Step 1 — the proposal was authored, validated, and planned on the base branch, so there is no pre-existing proposal branch to be on.)
```
**Verification:** `grep -c "creates\*\* the \`proposal/{NN}-{slug}\` branch in Step 1" shamt-core/host/templates/claude/commands/f3-implement-update.md` returns `1`.

### Step 7f — Step 1 read line: resolved file

**Operation:** EDIT
**Locate:**
```
1. Read `proposals/{slug}.md` top-to-bottom. Re-confirm the validation footer is present.
```
**Replace:**
```
1. Read the resolved proposal file (`proposals/{slug}.md` or `proposals/*-{slug}.md`) top-to-bottom. Re-confirm the validation footer is present.
```
**Verification:** `grep -c "Read the resolved proposal file" shamt-core/host/templates/claude/commands/f3-implement-update.md` returns `1`.

### Step 7g — Insert the branch-creation sub-step at the end of Step 1 (Preflight)

**Operation:** EDIT
**Locate:**
```
   If any path falls under generated `.claude/` (or its child-side equivalent), **halt immediately**. Edits to generated files are always wrong — they get overwritten on the next regen and the canonical source still carries the old version. Direct the user back to `/f1-propose-update` to correct the change list.

### Step 2 — Apply edits
```
**Replace:**
```
   If any path falls under generated `.claude/` (or its child-side equivalent), **halt immediately**. Edits to generated files are always wrong — they get overwritten on the next regen and the canonical source still carries the old version. Direct the user back to `/f1-propose-update` to correct the change list.

5. **Create the proposal branch** (last preflight action, before any edit). From the base branch (the configured remote development branch, or current `main`), create `proposal/{NN}-{slug}` — `proposal/{slug}` for an unnumbered/grandfathered proposal (numbered-ness is the resolved filename's leading `^[0-9]+-` run). For the **inline path** the orchestrator creates it directly here. For the **architect/builder path** the branch is created by the plan's pre-execution checklist (`plan-executor` runs it as Step 0) — do **not** also create it here. Halt and report if the branch already exists. This is where the `proposal/{NN}-{slug}` branch is born; authoring, validation, and planning happened on the base branch (branch creation is f3's job, not f1's).

### Step 2 — Apply edits
```
**Verification:** `grep -c "Create the proposal branch\*\* (last preflight action" shamt-core/host/templates/claude/commands/f3-implement-update.md` returns `1`.

### Step 7h — Example plan-executor invocation: matched-stem plan_path

**Operation:** EDIT
**Locate:**
```
     plan_path: proposals/{slug}_PLAN.md  # or _phase_N variant
```
**Replace:**
```
     plan_path: proposals/{NN}-{slug}_PLAN.md  # resolved stem; or _phase_N variant (drop {NN}- when unnumbered)
```
**Verification:** `grep -c "plan_path: proposals/{NN}-{slug}_PLAN.md" shamt-core/host/templates/claude/commands/f3-implement-update.md` returns `1`.

### Step 7i — Notes: reconcile the commit-timing note (commit lands at f6)

**Operation:** EDIT
**Locate:**
```
- **No commits here.** This command leaves changes in the working tree. The user commits explicitly after Phase 5 (regen) confirms the propagation worked, so the canonical edit and the generated `.claude/` update land in one commit.
```
**Replace:**
```
- **No commits here.** This command creates the `proposal/{NN}-{slug}` branch and leaves the canonical edits in the working tree on it. The commit + squash-merge to the base branch happens at Phase 7 (`/f6-archive-proposal`), so the canonical edit, the generated `.claude/` regen output, and the archived proposal all land in one commit. (Creating a branch is not a commit — "no commits here" still holds for f3.)
```
**Verification:** `grep -c "The commit + squash-merge to the base branch happens at Phase 7" shamt-core/host/templates/claude/commands/f3-implement-update.md` returns `1`.

---

## Step 8 — `shamt-core/host/templates/claude/skills/f3-implement-update/SKILL.md` (row 8) — mirror

### Step 8a — Protocol item 1: glob resolve + create branch

**Operation:** EDIT
**Locate:**
```
1. **Preflight** — confirm `proposals/{slug}.md` has a validation footer; confirm `{slug}_PLAN.md` (when present) has one; halt if `proposals/archive/{slug}.md` exists; halt if working tree is dirty with unrelated changes.
```
**Replace:**
```
1. **Preflight** — resolve the proposal exact-then-glob (`proposals/{slug}.md`, else `proposals/*-{slug}.md`); confirm it has a validation footer; confirm the `{NN}-{slug}_PLAN.md` / `{slug}_PLAN.md` companion (when present) has one; halt if `proposals/archive/{slug}.md` or `archive/*-{slug}.md` exists; halt if working tree is dirty with unrelated changes. **Then create the `proposal/{NN}-{slug}` branch** (`proposal/{slug}` if unnumbered) from the base branch — inline path directly; architect/builder path via the plan's pre-execution checklist. Authoring/validation/planning happened on the base branch (branch creation is f3's job, not f1's).
```
**Verification:** `grep -c "Then create the \`proposal/{NN}-{slug}\` branch" shamt-core/host/templates/claude/skills/f3-implement-update/SKILL.md` returns `1`.

### Step 8b — Exit criteria: reconcile commit-timing note

**Operation:** EDIT
**Locate:**
```
Every Proposed Changes row covered by a real diff entry; no generated-file edits; `/f4-regen-framework` suggested. No commits — the user commits after regen confirms propagation.
```
**Replace:**
```
Every Proposed Changes row covered by a real diff entry; no generated-file edits; `/f4-regen-framework` suggested. No commits here — f3 creates the `proposal/{NN}-{slug}` branch but does not commit; the commit + squash-merge lands at Phase 7 (`/f6-archive-proposal`).
```
**Verification:** `grep -c "the commit + squash-merge lands at Phase 7" shamt-core/host/templates/claude/skills/f3-implement-update/SKILL.md` returns `1`.

---

## Cross-check (this phase vs. Proposed Changes rows)

| Row | File | Steps | Operation match |
|-----|------|-------|-----------------|
| 5 | f2 command | 5a–5i | EDIT ✓ |
| 6 | f2 skill | 6a–6d | EDIT ✓ |
| 7 | f3 command | 7a–7i | EDIT ✓ |
| 8 | f3 skill | 8a, 8b | EDIT ✓ |

All four rows covered; every step is an EDIT; no `.claude/` path touched. The f3 branch-creation step (7g/8a) and the f6 squash-merge (Phase 3, row 9) are the two halves of the revised branch lifecycle — confirm they reference the same `proposal/{NN}-{slug}` shape. No stray `framework-update/{slug}` remains in f2 (5f) or f3 (7e) after this phase.
