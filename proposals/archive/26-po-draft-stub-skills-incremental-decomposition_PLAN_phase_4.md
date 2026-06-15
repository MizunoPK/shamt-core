# Implementation Plan — Phase 4: `/p6` deletions + e1/e8 consumer EDITs

**Proposal:** proposals/26-po-draft-stub-skills-incremental-decomposition.md
**Index:** proposals/26-po-draft-stub-skills-incremental-decomposition_PLAN.md
**Source rows:** 19–24 (sections C + D)
**Operations:** 2 DELETE + 4 EDIT (e1 cmd+skill, e8 cmd+skill)

> The `/p6` content is **not lost** — it was folded into `/ps0-draft` in Phase 1 Step 5. These DELETEs remove the now-redundant fast-path command/skill. The e1 edit adds the **ready-ticket pickup branch** (the one substantive consumer change); e8 is pure rename substitution.

---

## Step 1 — DELETE `commands/p6-draft-tech-story.md` (row 19)

**Operation:** DELETE
**File:** `shamt-core/host/templates/claude/commands/p6-draft-tech-story.md`
**Command:** `git rm shamt-core/host/templates/claude/commands/p6-draft-tech-story.md`
**Justification:** folded into `/ps0-draft` (Phase 1 Step 5) — a tech story is a story drafted under the Tech Stories `bugs`/`quick-wins` feature. The standing-feature archive note + tracker-template selection + prerequisite check were carried into `/ps0-draft`. No legacy alias (proposal Resolved Question).

**Precondition (before `git rm`):** confirm the `/p6-draft-tech-story` content is already folded into `/ps0-draft` per Phase 1 Step 5 — `grep -F 'bugs' shamt-core/host/templates/claude/commands/ps0-draft.md` returns ≥1 match (the fold target exists). Run this check BEFORE the `git rm`; do not delete the source until it passes.

**Execution order:** precondition → `git rm` → post-delete verification.

**Verification (after `git rm`):**
- `test ! -f shamt-core/host/templates/claude/commands/p6-draft-tech-story.md` — the file no longer exists.

---

## Step 2 — DELETE `skills/p6-draft-tech-story/SKILL.md` (row 20)

**Operation:** DELETE
**File:** `shamt-core/host/templates/claude/skills/p6-draft-tech-story/SKILL.md` (and its now-empty directory)
**Command:** `git rm -r shamt-core/host/templates/claude/skills/p6-draft-tech-story`
**Justification:** mirror skill removed; trigger phrasing folded into `skills/ps0-draft/SKILL.md` (Phase 1 Step 6).

**Verification:**
- `test ! -d shamt-core/host/templates/claude/skills/p6-draft-tech-story`

---

## Step 3 — EDIT `commands/e1-start-story.md` — ready-ticket pickup branch + `/p4`/`/p6` ref updates (row 21)

**Operation:** EDIT
**File:** `shamt-core/host/templates/claude/commands/e1-start-story.md`

**3a. Add the ready-ticket pickup branch** by extending the existing Step-2 folder-path detection with the validation-footer signal. The current stub-case text is the single `**Stub case (PO-flow handoff).**` bullet at **line 46**. The detection today is binary (nested-under-feature ⇒ stub vs. not). Make it three-way per the proposal's Resolved Question. This is a **whole-bullet replacement**: the locate is the entire line-46 bullet (both of its `/p4-decompose-feature` references, the stale "back-ref headers" phrasing, and the stub-aware continuation are all inside the replaced span — nothing is left dangling).

- **Locate** (the complete line-46 bullet, verbatim — one line):
```
   - **Stub case (PO-flow handoff).** If the resolved ticket.md folder is nested under a feature (per its path: epics/<e>/features/<f>/stories/<s>/), this is a stub written by `/p4-decompose-feature`. Mark the invocation as **stub-aware**: the back-ref headers and the scope one-liner in the body are preserved verbatim throughout the rest of this command. The stub's `## Decomposition Context` (when present — pre-#12 / freeform stubs lack it) seeds the intake deepening as the research starting point; fall back to the scope one-liner alone when absent. Proceed to Step 4 (the rest of the Intake flow — tracker fetch when the active profile supports Story, else freeform open-questions dialog — merges its output into the existing template sections without rewriting the back-ref headers or the scope one-liner). The Engineer-flow Intake gate (Step 6) still applies. Stub-derived stories are individually testable per `/p4-decompose-feature`'s exit gate — no rubric re-check at Intake.
```
- **Replace** (exact — three child bullets under the existing `**One match** → … detect the stub case:` line; the leading three-space indent matches the original bullet so the list nesting is preserved):
```
   - **Ready-ticket pickup (PO-flow handoff, validated).** If the resolved nested `ticket.md` carries a Pattern-1 `Validated …` footer, this is a `/ps1-define`-validated planning ticket. Mark the invocation as **ready-ticket pickup**: do the tracker fetch/reconcile + confirm of Step 4, then **skip re-authoring intake** — proceed straight to the Intake gate (Step 6) without re-running the open-questions dialog (the ticket is already authored and validated). The scope one-liner and `## Decomposition Context` are preserved verbatim.
   - **Bare-stub merge (PO-flow handoff, unvalidated).** If the resolved nested `ticket.md` carries **no** `Validated …` footer, this is a bare stub written by `/pf2-decompose` (or `/ps0-draft`). Mark the invocation as **stub-aware**: the scope one-liner in the body is preserved verbatim throughout the rest of this command. The stub's `## Decomposition Context` (when present — pre-#12 / freeform stubs lack it) seeds the intake deepening as the research starting point; fall back to the scope one-liner alone when absent. Proceed to Step 4 (the rest of the Intake flow — tracker fetch when the active profile supports Story, else freeform open-questions dialog — merges its output into the existing template sections without rewriting the scope one-liner). The Engineer-flow Intake gate (Step 6) still applies. Stub-derived stories are individually testable per `/pf2-decompose`'s exit gate — no rubric re-check at Intake.
   - **Detection is flagless.** The three-way split keys solely on the resolved folder's nested parentage plus the presence/absence of the `Validated …` footer (stamped by `/ps1-define`'s inline validation loop): **no new command flag, no new template, no new status marker** — consistent with e1's existing flagless stub detection.
```
- This whole-bullet rewrite **drops** the stale "back-ref headers" phrasing (e1 keys on nested folder path, not headers — consistent with lines 78/93/128) and **renames both** in-bullet `/p4-decompose-feature` references to `/pf2-decompose`. The `**Pre-existing freeform case.**` bullet on the next line (the no-nested-folder ad-hoc path) is unchanged.

**3b. Rename-substitution edits** (mechanical) across the rest of the file. Each is an EXACT full-substring locate → EXACT full-substring replacement (a single unique occurrence per line; apply with a non-`replace_all` edit). Only the command name changes in each — every other character of the located substring is reproduced verbatim in the replacement.

- **Line 55** —
  - Locate (exact): `**halt this intake and hand off** to /p6-draft-tech-story (#15) — it seeds the nested ticket stub under the standing Tech Stories epic's Bugs / Quick Wins feature and re-enters the Engineer flow stub-aware.`
  - Replace (exact): `**halt this intake and hand off** to /ps0-draft (#15) — it seeds the nested ticket stub under the standing Tech Stories epic's Bugs / Quick Wins feature and re-enters the Engineer flow stub-aware.`
  - (The `(#15)` provenance tag and the behavior description are preserved verbatim — `/ps0-draft` now absorbs that behavior, so the sentence stays accurate.)
- **Line 78** —
  - Locate (exact): `The existing ticket.md carries the scope one-liner from /p4-decompose-feature in the body intake area, and (on a richer-cataloging stub) a ## Decomposition Context breadth section.`
  - Replace (exact): `The existing ticket.md carries the scope one-liner from /pf2-decompose in the body intake area, and (on a richer-cataloging stub) a ## Decomposition Context breadth section.`
- **Line 93** —
  - Locate (exact): `The existing ticket.md from /p4-decompose-feature already carries the scope one-liner in the body intake area; its parent feature/epic are the folder path, not headers.`
  - Replace (exact): `The existing ticket.md from /pf2-decompose already carries the scope one-liner in the body intake area; its parent feature/epic are the folder path, not headers.`
- **Line 128** —
  - Locate (exact): `- **Stub-aware handoff from the PO flow.** When \`/p4-decompose-feature\` has already created the nested stub (…/features/<f>/stories/{slug}-*/ticket.md), that stub carries a scope one-liner in the body intake area; its parent feature/epic are the folder path, not headers.`
  - Replace (exact): `- **Stub-aware handoff from the PO flow.** When \`/pf2-decompose\` has already created the nested stub (…/features/<f>/stories/{slug}-*/ticket.md), that stub carries a scope one-liner in the body intake area; its parent feature/epic are the folder path, not headers.`
- **Line 132** —
  - Locate (exact): `  - The Engineer-flow Intake gate (Step 6) is unchanged — stub-handling is transparent to the gate. Stub-derived stories are individually testable per \`/p4-decompose-feature\`'s exit gate, so no rubric re-check at Intake.`
  - Replace (exact): `  - The Engineer-flow Intake gate (Step 6) is unchanged — stub-handling is transparent to the gate. Stub-derived stories are individually testable per \`/pf2-decompose\`'s exit gate, so no rubric re-check at Intake.`

**Verification:**
- `grep -nE '/p[1-6]-(start|decompose|finalize|draft)' shamt-core/host/templates/claude/commands/e1-start-story.md` returns **zero** matches.
- `grep -F 'Validated' shamt-core/host/templates/claude/commands/e1-start-story.md` returns ≥1 match (the footer-signal branch is present).
- `grep -F '/ps0-draft' shamt-core/host/templates/claude/commands/e1-start-story.md` returns ≥1 match.
- `grep -F 'no new command flag' shamt-core/host/templates/claude/commands/e1-start-story.md` returns ≥1 match (the flagless-detection invariant is restated).

---

## Step 4 — EDIT `skills/e1-start-story/SKILL.md` — mirror the e1 body changes (row 22)

**Operation:** EDIT
**File:** `shamt-core/host/templates/claude/skills/e1-start-story/SKILL.md`

**4a. Line-31 rename substitution** — EXACT full-substring locate → EXACT full-substring replacement (single unique occurrence; non-`replace_all`). Only the command name changes:
- Locate (exact): `3. For new stories with no PO-flow parent, halt and hand off to \`/p6-draft-tech-story\` (#15) — it seeds the nested stub under the Tech Stories epic's Bugs / Quick Wins feature and re-enters Engineer flow.`
- Replace (exact): `3. For new stories with no PO-flow parent, halt and hand off to \`/ps0-draft\` (#15) — it seeds the nested stub under the Tech Stories epic's Bugs / Quick Wins feature and re-enters Engineer flow.`

**4b. Append the ready-ticket summary to item 2** — the skill's numbered summary currently has a single resolve-step at item 2 (line 30), whose detection is binary (nested-stub vs. not). To mirror the command body's new three-way split, **extend the existing line-30 item-2 sentence in place** — the inserted text is **appended to the end of line 30** (it is *not* a new list item, *not* a new line, and *not* a new section; line 30 stays a single line and item numbering is unchanged). The append target is the exact tail of line 30. This is an EXACT full-substring locate (the current end of line 30) → EXACT full-substring replacement (same text with the new sentence appended after a single space):
- Locate (exact — the current trailing fragment of line 30, unique in the file): `with the legacy-flat \`stories/{slug}-*/\` as fallback. Exactly one match — halt on zero or multiple.`
- Replace (exact — same fragment, then a single space, then the new sentence; all on the same line):
```
with the legacy-flat `stories/{slug}-*/` as fallback. Exactly one match — halt on zero or multiple. A resolved nested `ticket.md` **with** a Pattern-1 `Validated …` footer → ready-ticket pickup (tracker fetch/reconcile + confirm, skip re-authoring intake); nested **without** a footer → bare-stub merge; no nested folder → full ad-hoc freeform/tracker intake — flagless (no new flag/template/status marker).
```

**4c. No `/p4-decompose-feature` rename in the skill.** The skill body carries **no** `/p4-decompose-feature` (or other decompose-producer) reference — its only `/pN` reference is the line-31 `/p6-draft-tech-story` handled in 4a (verified: `grep -nE 'p4|decompose-feature' …/skills/e1-start-story/SKILL.md` returns nothing). So no decompose-producer rename applies here; do not add one.

**Verification:**
- `grep -nE '/p[1-6]-(start|decompose|finalize|draft)' shamt-core/host/templates/claude/skills/e1-start-story/SKILL.md` returns **zero** matches.
- `grep -F '/ps0-draft' shamt-core/host/templates/claude/skills/e1-start-story/SKILL.md` returns ≥1 match (the line-31 handoff was renamed).
- `grep -F 'ready-ticket pickup (tracker fetch/reconcile + confirm, skip re-authoring intake)' shamt-core/host/templates/claude/skills/e1-start-story/SKILL.md` returns ≥1 match (the appended three-way summary landed).
- `grep -F 'no new flag/template/status marker' shamt-core/host/templates/claude/skills/e1-start-story/SKILL.md` returns ≥1 match (the flagless invariant is present in the appended text).

---

## Step 5 — EDIT `commands/e8-finalize-story.md` — `/p5-finalize-epic` → `/pe3-finalize` (row 23)

**Operation:** EDIT
**File:** `shamt-core/host/templates/claude/commands/e8-finalize-story.md`

- **Line 70** — Locate: `(mirroring how \`/p5-finalize-epic\` archives a done epic and \`/f6-archive-proposal\` archives an implemented proposal)` → Replace `/p5-finalize-epic` with `/pe3-finalize`.
- **Line 92** — Locate: `Epic-level archiving (moving a done epic into \`epics/archive/\`) is \`/p5-finalize-epic\`'s job.` → Replace `/p5-finalize-epic` with `/pe3-finalize`.
- No `/p4`/`/p6` references exist in e8 (confirmed at proposal authoring — the Tech-Stories story-archive logic is unaffected by the renames).

**Verification:**
- `grep -nF '/p5-finalize-epic' shamt-core/host/templates/claude/commands/e8-finalize-story.md` returns **zero** matches.
- `grep -F '/pe3-finalize' shamt-core/host/templates/claude/commands/e8-finalize-story.md` returns 2 matches.

---

## Step 6 — EDIT `skills/e8-finalize-story/SKILL.md` — mirror the e8 change (row 24)

**Operation:** EDIT
**File:** `shamt-core/host/templates/claude/skills/e8-finalize-story/SKILL.md`

- **Line 44** — Locate: `Finalize does **not** move the story folder — epic archiving is \`/p5-finalize-epic\`'s job.` → Replace `/p5-finalize-epic` with `/pe3-finalize`.

**Verification:**
- `grep -nF '/p5-finalize-epic' shamt-core/host/templates/claude/skills/e8-finalize-story/SKILL.md` returns **zero** matches.
- `grep -F '/pe3-finalize' shamt-core/host/templates/claude/skills/e8-finalize-story/SKILL.md` returns 1 match.

---

## Row → step mapping (Phase 4)

| Proposal row | Plan step |
|---|---|
| 19 (`p6-draft-tech-story.md` DELETE) | Step 1 |
| 20 (`p6-draft-tech-story/` skill DELETE) | Step 2 |
| 21 (`e1-start-story.md` EDIT — ready-ticket branch + refs) | Step 3 |
| 22 (`e1-start-story/SKILL.md` EDIT) | Step 4 |
| 23 (`e8-finalize-story.md` EDIT) | Step 5 |
| 24 (`e8-finalize-story/SKILL.md` EDIT) | Step 6 |

---
Validated 2026-06-14 — batch-validated (Standard path), 1 adversarial sub-agent confirmed
