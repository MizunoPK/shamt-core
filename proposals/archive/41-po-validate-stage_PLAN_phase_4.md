# Implementation Plan — po-validate-stage — Phase 4 (row-20 reference-rename sweep)

**Proposal:** proposals/41-po-validate-stage.md
**Index:** proposals/41-po-validate-stage_PLAN.md
**Scope:** Proposed Changes row 20 — the mechanical reference rename `/pe2-decompose`→`/pe3-decompose`, `/pe3-finalize`→`/pe4-finalize`, `/pf2-decompose`→`/pf3-decompose` across **every remaining canonical site** surfaced by the plan-time grep. Runs **last** so every renamed-command reference resolves to a file already on disk under its new name (Phase 2 done).

> **Site enumeration (grep-driven).** This phase was built from:
> `grep -rnE 'pe2-decompose|pf2-decompose|pe3-finalize' --include='*.md' templates reference host README.md CLAUDE.md`
> at plan time. The sites already covered by other rows are excluded here:
> - The 6 renamed files themselves (rows 7–12) — self-refs fixed in Phase 2.
> - The named-EDIT files `pe1-define.md`, `pf1-define.md`, `ps1-define.md`, `e1-start-story.md` (the `/ps1-define`-attribution part), `README.md`, `epic_status_board.md`, `model_selection.md` (rows 13–19) — handled in Phase 3.
>
> What remains below are the 13 *other* sites. CLAUDE.md had **zero** matches (confirmed at plan time) — it is correctly absent. Each step is one file with its exact old→new strings.
>
> **All renames in this phase are pure command-name token substitutions** — no prose/behavior change. `/pe2-decompose`→`/pe3-decompose`, `/pf2-decompose`→`/pf3-decompose`, `/pe3-finalize`→`/pe4-finalize`.

> **Verification ownership:** per-step verifications are the builder's (per-file zero-old-token). The whole-tree zero-dangling sweep is the architect's whole-plan check in the INDEX.

---

## Step 1 — EDIT `host/templates/claude/commands/pf0-draft.md` (sweep; row 20a)

**Operation:** EDIT
**File:** `host/templates/claude/commands/pf0-draft.md`

Replace each `/pe2-decompose` / bare `pe2-decompose` token with the `pe3-decompose` form (this file references the epic-decompose batch producer multiple times). Concrete sites:

- **Locate:** `marked as an unrefined idea capture. pf0 is the **single-stub incremental** producer: write **one** feature stub without re-running `/pe2-decompose` and without re-gating the whole batch.`
  **Replace:** `marked as an unrefined idea capture. pf0 is the **single-stub incremental** producer: write **one** feature stub without re-running `/pe3-decompose` and without re-gating the whole batch.`
- **Locate:** `**Purpose:** The single-stub *incremental* producer — write **one** feature stub under an already-decomposed (or any existing) epic without re-running `/pe2-decompose` and without re-gating the whole batch. Contrast explicitly with `/pe2-decompose` (the batch producer).`
  **Replace:** `**Purpose:** The single-stub *incremental* producer — write **one** feature stub under an already-decomposed (or any existing) epic without re-running `/pe3-decompose` and without re-gating the whole batch. Contrast explicitly with `/pe3-decompose` (the batch producer).`
- **Locate:** `If the slug is taken anywhere, halt and ask for a different slug (PO-flow slugs are user-chosen and globally unique, matching `/pe2-decompose` semantics, not `/f0-draft-proposal`'s numeric-suffix fallback).`
  **Replace:** `If the slug is taken anywhere, halt and ask for a different slug (PO-flow slugs are user-chosen and globally unique, matching `/pe3-decompose` semantics, not `/f0-draft-proposal`'s numeric-suffix fallback).`
- **Locate:** `3. Create the folder `epics/{epic-folder}/features/{ID}-{feature-slug}-{brief}/` and write `feature.md` with the **identical core stub-section shape the decompose command writes** (per `/pe2-decompose`'s Step 8 stub-section contract):`
  **Replace:** `3. Create the folder `epics/{epic-folder}/features/{ID}-{feature-slug}-{brief}/` and write `feature.md` with the **identical core stub-section shape the decompose command writes** (per `/pe3-decompose`'s Step 8 stub-section contract):`
- **Locate:** `   - **`## Target Stories` section:** left empty (to be filled by `/pf2-decompose`).`
  **Replace:** `   - **`## Target Stories` section:** left empty (to be filled by `/pf3-decompose`).`
- **Locate:** `   - **`## Sequencing & Parallelization` section:** left empty (to be filled by `/pf2-decompose`).`
  **Replace:** `   - **`## Sequencing & Parallelization` section:** left empty (to be filled by `/pf3-decompose`).`
- **Locate:** `- **Preserve re-decomposition partition structure.** Step 4's additive-append rule preserves the `Decomposed YYYY-MM-DD — …` line format that `/pe2-decompose` reads on re-entry for the re-decomposition partition logic (Kept / New / Orphaned).`
  **Replace:** `- **Preserve re-decomposition partition structure.** Step 4's additive-append rule preserves the `Decomposed YYYY-MM-DD — …` line format that `/pe3-decompose` reads on re-entry for the re-decomposition partition logic (Kept / New / Orphaned).`

**Verification:** `grep -c 'pe2-decompose\|pf2-decompose\|pe3-finalize' host/templates/claude/commands/pf0-draft.md` returns 0.

---

## Step 2 — EDIT `host/templates/claude/commands/ps0-draft.md` (sweep; row 20b)

**Operation:** EDIT
**File:** `host/templates/claude/commands/ps0-draft.md`

This file references the feature-decompose batch producer (`/pf2-decompose`). Concrete sites:

- **Locate:** `ps0 is the **single-story-stub incremental** producer: write **one** story stub without re-running `/pf2-decompose` and without re-gating the whole batch.`
  **Replace:** `ps0 is the **single-story-stub incremental** producer: write **one** story stub without re-running `/pf3-decompose` and without re-gating the whole batch.`
- **Locate:** `ps0 supports **two parent modes**, both writing the **same story-ticket stub shape `/pf2-decompose` emits**:`
  **Replace:** `ps0 supports **two parent modes**, both writing the **same story-ticket stub shape `/pf3-decompose` emits**:`
- **Locate:** `4. Create the folder `epics/{epic-folder}/features/{feature-folder}/stories/{ID}-{story-slug}-{brief}/` and write `ticket.md` with the **same core stub shape `/pf2-decompose` emits** (per its Step 8 stub-section contract):`
  **Replace:** `4. Create the folder `epics/{epic-folder}/features/{feature-folder}/stories/{ID}-{story-slug}-{brief}/` and write `ticket.md` with the **same core stub shape `/pf3-decompose` emits** (per its Step 8 stub-section contract):`
- **Locate:** `- **Single-story-stub incremental.** Add one story at a time without re-decomposing the whole feature. Contrast with `/pf2-decompose` (the batch producer).`
  **Replace:** `- **Single-story-stub incremental.** Add one story at a time without re-decomposing the whole feature. Contrast with `/pf3-decompose` (the batch producer).`
- **Locate:** `- **Tracker-template selection per active profile.** Same template-selection semantics as `/pf2-decompose` Step 8 and the former tech-story fast-path.`
  **Replace:** `- **Tracker-template selection per active profile.** Same template-selection semantics as `/pf3-decompose` Step 8 and the former tech-story fast-path.`

**Verification:** `grep -c 'pe2-decompose\|pf2-decompose\|pe3-finalize' host/templates/claude/commands/ps0-draft.md` returns 0.

---

## Step 3 — EDIT `host/templates/claude/commands/e8-finalize-story.md` (sweep; row 20c)

**Operation:** EDIT
**File:** `host/templates/claude/commands/e8-finalize-story.md`

References `/pf2-decompose` (stub provenance, already handled in e1; here the bare provenance refs) and `/pe3-finalize` (epic-archive comparison). Concrete sites:

- **Locate:** `This keeps the standing Bugs / Quick Wins features from growing without bound (mirroring how `/pe3-finalize` archives a done epic and `/f6-archive-proposal` archives an implemented proposal).`
  **Replace:** `This keeps the standing Bugs / Quick Wins features from growing without bound (mirroring how `/pe4-finalize` archives a done epic and `/f6-archive-proposal` archives an implemented proposal).`
- **Locate:** `- **Not an epic archive.** `/e8-finalize-story` finalizes a single story; it does **not** move the story folder. Epic-level archiving (moving a done epic into `epics/archive/`) is `/pe3-finalize`'s job.`
  **Replace:** `- **Not an epic archive.** `/e8-finalize-story` finalizes a single story; it does **not** move the story folder. Epic-level archiving (moving a done epic into `epics/archive/`) is `/pe4-finalize`'s job.`

> NOTE — at plan time the grep showed e8-finalize-story.md matched only on `pe3-finalize` (lines 70, 96). If a `/pf2-decompose` token also surfaces here at execution time, rename it to `/pf3-decompose`. The verification below catches any survivor regardless.

**Verification:** `grep -c 'pe2-decompose\|pf2-decompose\|pe3-finalize' host/templates/claude/commands/e8-finalize-story.md` returns 0.

---

## Step 4 — EDIT `host/templates/claude/skills/pe1-define/SKILL.md` (sweep; row 20d)

**Operation:** EDIT
**File:** `host/templates/claude/skills/pe1-define/SKILL.md`

- **Locate:** `  Features and Sequencing & Parallelization empty for /pe2-decompose. Invoke`
  **Replace:** `  Features and Sequencing & Parallelization empty for /pe3-decompose. Invoke`

**Verification:** `grep -c 'pe2-decompose\|pf2-decompose\|pe3-finalize' host/templates/claude/skills/pe1-define/SKILL.md` returns 0.

---

## Step 5 — EDIT `host/templates/claude/skills/pf0-draft/SKILL.md` (sweep; row 20e)

**Operation:** EDIT
**File:** `host/templates/claude/skills/pf0-draft/SKILL.md`

- **Locate:** `This is the feature-level analogue of `/ps0-draft` (story-level fast-path) — add one feature without re-decomposing the whole epic. Contrast with `/pe2-decompose` (the batch producer).`
  **Replace:** `This is the feature-level analogue of `/ps0-draft` (story-level fast-path) — add one feature without re-decomposing the whole epic. Contrast with `/pe3-decompose` (the batch producer).`

**Verification:** `grep -c 'pe2-decompose\|pf2-decompose\|pe3-finalize' host/templates/claude/skills/pf0-draft/SKILL.md` returns 0.

---

## Step 6 — EDIT `host/templates/claude/skills/pf1-define/SKILL.md` (sweep; row 20f)

**Operation:** EDIT
**File:** `host/templates/claude/skills/pf1-define/SKILL.md`

- **Locate:** `  (A) flesh out an existing feature stub written by /pe2-decompose — preserve`
  **Replace:** `  (A) flesh out an existing feature stub written by /pe3-decompose — preserve`

**Verification:** `grep -c 'pe2-decompose\|pf2-decompose\|pe3-finalize' host/templates/claude/skills/pf1-define/SKILL.md` returns 0.

---

## Step 7 — EDIT `host/templates/claude/skills/e8-finalize-story/SKILL.md` (sweep; row 20g)

**Operation:** EDIT
**File:** `host/templates/claude/skills/e8-finalize-story/SKILL.md`

- **Locate:** `The story's scoped work is committed (after the three guards held); the work item is marked done via the active tracker (or local-only); `ticket.md` carries `**Status: Done**`. Finalize does **not** move the story folder — epic archiving is `/pe3-finalize`'s job.`
  **Replace:** `The story's scoped work is committed (after the three guards held); the work item is marked done via the active tracker (or local-only); `ticket.md` carries `**Status: Done**`. Finalize does **not** move the story folder — epic archiving is `/pe4-finalize`'s job.`

**Verification:** `grep -c 'pe2-decompose\|pf2-decompose\|pe3-finalize' host/templates/claude/skills/e8-finalize-story/SKILL.md` returns 0.

---

## Step 8 — EDIT `reference/trackers/local.md` (sweep; row 20h)

**Operation:** EDIT
**File:** `reference/trackers/local.md`

- **Locate:** `**Conforms to** [`_contract.md`](_contract.md) in shape but is a no-fetch profile: the ticket file is already a local Markdown artifact — authored by the user, or written as a stub by the PO flow's `/pf2-decompose` and then fleshed out by `/e1-start-story` (Engineer flow, Phase 1).`
  **Replace:** `**Conforms to** [`_contract.md`](_contract.md) in shape but is a no-fetch profile: the ticket file is already a local Markdown artifact — authored by the user, or written as a stub by the PO flow's `/pf3-decompose` and then fleshed out by `/e1-start-story` (Engineer flow, Phase 1).`

**Verification:** `grep -c 'pe2-decompose\|pf2-decompose\|pe3-finalize' reference/trackers/local.md` returns 0.

---

## Step 9 — EDIT `templates/epic.template.md` (sweep; row 20i)

**Operation:** EDIT
**File:** `templates/epic.template.md`

- **Locate:** `[Populated by `/pe2-decompose`. Left empty on `/pe1-define` exit. Each line: feature slug + one-line goal.]`
  **Replace:** `[Populated by `/pe3-decompose`. Left empty on `/pe1-define` exit. Each line: feature slug + one-line goal.]`
- **Locate:** `[Populated by `/pe2-decompose`. Left empty on `/pe1-define` exit.]`
  **Replace:** `[Populated by `/pe3-decompose`. Left empty on `/pe1-define` exit.]`

**Verification:** `grep -c 'pe2-decompose\|pf2-decompose\|pe3-finalize' templates/epic.template.md` returns 0.

---

## Step 10 — EDIT `templates/feature.template.md` (sweep; row 20j)

**Operation:** EDIT
**File:** `templates/feature.template.md`

- **Locate:** `<!-- Cataloged at decomposition (/pe2-decompose for features, /pf2-decompose for stories) — bounded breadth context discovered by researching the whole sibling set. NOT a depth dump (design/acceptance/implementation detail belongs in the depth sections, filled at start-*). /pf1-define and /e1-start-story consume this as a research seed. Leave the placeholder bullets if nothing was cataloged. -->`
  **Replace:** `<!-- Cataloged at decomposition (/pe3-decompose for features, /pf3-decompose for stories) — bounded breadth context discovered by researching the whole sibling set. NOT a depth dump (design/acceptance/implementation detail belongs in the depth sections, filled at start-*). /pf1-define and /e1-start-story consume this as a research seed. Leave the placeholder bullets if nothing was cataloged. -->`
- **Locate:** `[Populated by `/pf2-decompose`. Left empty on `/pf1-define` exit. Each line: story slug + one-line scope.]`
  **Replace:** `[Populated by `/pf3-decompose`. Left empty on `/pf1-define` exit. Each line: story slug + one-line scope.]`
- **Locate:** `[Populated by `/pf2-decompose`. Left empty on `/pf1-define` exit.]`
  **Replace:** `[Populated by `/pf3-decompose`. Left empty on `/pf1-define` exit.]`

**Verification:** `grep -c 'pe2-decompose\|pf2-decompose\|pe3-finalize' templates/feature.template.md` returns 0.

---

## Step 11 — EDIT `templates/ticket.ado.template.md` (sweep; row 20k)

**Operation:** EDIT
**File:** `templates/ticket.ado.template.md`

- **Locate:** `<!-- Cataloged at decomposition (/pe2-decompose for features, /pf2-decompose for stories) — bounded breadth context discovered by researching the whole sibling set. NOT a depth dump (design/acceptance/implementation detail belongs in the depth sections, filled at start-*). /pf1-define and /e1-start-story consume this as a research seed. Leave the placeholder bullets if nothing was cataloged. -->`
  **Replace:** `<!-- Cataloged at decomposition (/pe3-decompose for features, /pf3-decompose for stories) — bounded breadth context discovered by researching the whole sibling set. NOT a depth dump (design/acceptance/implementation detail belongs in the depth sections, filled at start-*). /pf1-define and /e1-start-story consume this as a research seed. Leave the placeholder bullets if nothing was cataloged. -->`

**Verification:** `grep -c 'pe2-decompose\|pf2-decompose\|pe3-finalize' templates/ticket.ado.template.md` returns 0.

---

## Step 12 — EDIT `templates/ticket.github.template.md` (sweep; row 20l)

**Operation:** EDIT
**File:** `templates/ticket.github.template.md`

- **Locate:** `<!-- Cataloged at decomposition (/pe2-decompose for features, /pf2-decompose for stories) — bounded breadth context discovered by researching the whole sibling set. NOT a depth dump (design/acceptance/implementation detail belongs in the depth sections, filled at start-*). /pf1-define and /e1-start-story consume this as a research seed. Leave the placeholder bullets if nothing was cataloged. -->`
  **Replace:** `<!-- Cataloged at decomposition (/pe3-decompose for features, /pf3-decompose for stories) — bounded breadth context discovered by researching the whole sibling set. NOT a depth dump (design/acceptance/implementation detail belongs in the depth sections, filled at start-*). /pf1-define and /e1-start-story consume this as a research seed. Leave the placeholder bullets if nothing was cataloged. -->`

**Verification:** `grep -c 'pe2-decompose\|pf2-decompose\|pe3-finalize' templates/ticket.github.template.md` returns 0.

---

## Step 13 — EDIT `templates/SHAMT_RULES.template.md` (sweep — command-name rename ONLY; row 20m)

**Operation:** EDIT (mechanical command-name rename only — **no new normative content**, size-budgeted D12)
**File:** `templates/SHAMT_RULES.template.md`

Four matched sites (per plan-time grep — lines 19, 147, 179, 360). Each is a pure token rename:

- **Locate:** `Within the PO flow, **decomposition catalogs breadth-context** and **define-\* deepens depth** from that seed before its terminal gate — see the `/pe2-decompose`/`/pf2-decompose` and `/pf1-define`/`/e1` command bodies for per-altitude detail.`
  **Replace:** `Within the PO flow, **decomposition catalogs breadth-context** and **define-\* deepens depth** from that seed before its terminal gate — see the `/pe3-decompose`/`/pf3-decompose` and `/pf1-define`/`/e1` command bodies for per-altitude detail.`
- **Locate:** `- **`/pe3-finalize {slug}`** — the PO flow's terminal command at the Epic altitude: after confirming every child feature/story is finalized, marks the epic done and **moves the epic folder into `epics/archive/`** as a **whole-subtree move**`
  **Replace:** `- **`/pe4-finalize {slug}`** — the PO flow's terminal command at the Epic altitude: after confirming every child feature/story is finalized, marks the epic done and **moves the epic folder into `epics/archive/`** as a **whole-subtree move**`
- **Locate:** `- **Entry + archive.** Entry is via `/ps0-draft [bugs|quick-wins]` (seeds a ticket stub under the chosen feature, hands to `/e1-start-story`, bypassing the `/pe1-define`→`/pf2-decompose` cascade); archive-on-finalize moves the folder into the feature's `archive/`.`
  **Replace:** `- **Entry + archive.** Entry is via `/ps0-draft [bugs|quick-wins]` (seeds a ticket stub under the chosen feature, hands to `/e1-start-story`, bypassing the `/pe1-define`→`/pf3-decompose` cascade); archive-on-finalize moves the folder into the feature's `archive/`.`
- **Locate:** `- **Stub IDs are preserved.** `/pe2-decompose` and `/pf2-decompose` allocate each child's ID at stub time; `/pf1-define` (fleshing a feature stub) and `/e1-start-story` (fleshing a story stub) **preserve** that ID — they do not re-allocate.`
  **Replace:** `- **Stub IDs are preserved.** `/pe3-decompose` and `/pf3-decompose` allocate each child's ID at stub time; `/pf1-define` (fleshing a feature stub) and `/e1-start-story` (fleshing a story stub) **preserve** that ID — they do not re-allocate.`

> Builder: this file is size-budgeted (D12). Confirm the edits are pure same-length-ish token swaps (the new names are exactly one char longer per token) and that **no new `-validate` prose, no new rows, no new sections** are added. After editing, `git diff --stat templates/SHAMT_RULES.template.md` should show a tiny delta.

**Verification:**
- `grep -c 'pe2-decompose\|pf2-decompose\|pe3-finalize' templates/SHAMT_RULES.template.md` returns 0.
- `grep -c 'pe2-validate\|pf2-validate\|ps2-validate' templates/SHAMT_RULES.template.md` returns 0 (NO new normative `-validate` content was added — sweep-only per the proposal's "Deliberately NOT edited").

---

## Step 14 — EDIT `host/templates/claude/commands/e1-start-story.md` (sweep — `/pf2-decompose` rename; row 16 residual)

**Operation:** EDIT
**File:** `host/templates/claude/commands/e1-start-story.md`

> **Why this step exists.** Phase 3 Step 4 repointed only the two `/ps1-define` attribution lines in this file. The Phase 3 plan explicitly deferred the five `/pf2-decompose` token renames to this phase ("are the **sweep** (row 20c), handled in **Phase 4 Step 3**"). However, Phase 4 Step 3 covers `e8-finalize-story.md`; `e1-start-story.md` had no Phase 4 step. This step closes that gap. All five occurrences are pure command-name token renames (`/pf2-decompose` → `/pf3-decompose`) with no behavior change.

Five concrete sites (lines 47, 80, 95, 130, 134):

- **Locate:** `this is a bare stub written by `/pf2-decompose` (or `/ps0-draft`). Mark the invocation as **stub-aware**:`
  **Replace:** `this is a bare stub written by `/pf3-decompose` (or `/ps0-draft`). Mark the invocation as **stub-aware**:`
- **Locate:** `Stub-derived stories are individually testable per `/pf2-decompose`'s exit gate — no rubric re-check at Intake.`
  **Replace:** `Stub-derived stories are individually testable per `/pf3-decompose`'s exit gate — no rubric re-check at Intake.`
  > NOTE — this string appears **twice** in the file (lines 47 and 134). Apply both — or use a replace-all edit targeting this exact string; both occurrences are identical.
- **Locate:** `The existing ticket.md carries the scope one-liner from /pf2-decompose in the body intake area,`
  **Replace:** `The existing ticket.md carries the scope one-liner from /pf3-decompose in the body intake area,`
- **Locate:** `The existing ticket.md from /pf2-decompose already carries the scope one-liner in the body intake area;`
  **Replace:** `The existing ticket.md from /pf3-decompose already carries the scope one-liner in the body intake area;`
- **Locate:** `When `/pf2-decompose` has already created the nested stub (…/features/<f>/stories/{slug}-*/ticket.md),`
  **Replace:** `When `/pf3-decompose` has already created the nested stub (…/features/<f>/stories/{slug}-*/ticket.md),`

**Verification:** `grep -c 'pe2-decompose\|pf2-decompose\|pe3-finalize' host/templates/claude/commands/e1-start-story.md` returns 0.

---
Validated 2026-06-19 — 2 rounds, 1 adversarial sub-agent confirmed
