# Implementation Plan — Phase 5 (#13 finalize-command revisit: /p5-finalize-epic + /e8-finalize-story): po-nested-folder-layout (#14)

**Index:** [`14-po-nested-folder-layout_PLAN.md`](14-po-nested-folder-layout_PLAN.md) · **Rows:** 47–48 + the row-1 rules-sweep extension · **Deploy order:** LAST (after Phase 4).

> Added by in-place amendment when the Phase-4 diff-coverage gate surfaced that #13's `/p5-finalize-epic` (and the #13-added rules remnants) still read `**Parent Epic:**` back-ref headers — which Phases 1–4 removed. Under nesting the fix is *simpler*: children nest inside the epic folder, so child-discovery is a tree walk and archiving is a whole-subtree move. Canonical-only; no `.claude/`.

---

## Step 47 — `commands/p5-finalize-epic.md` (row 47)

- **47a (child-discovery → tree walk).** Step 1 item 1 (`Find the epic's children. On the **current flat layout**, children live in sibling top-level dirs linked by back-ref headers: features in features/*/feature.md carrying **Parent Epic:** {this-epic-slug} …`) → `Find the epic's children by walking the nested tree inside the epic folder (parentage is the path, per §PO-tree resolution): features at epics/{epic-folder}/features/*/feature.md, stories at epics/{epic-folder}/features/*/stories/*/ticket.md.`
- **47b (archive → whole-subtree move).** Step 4 item 2 (`… **Move-epic-only:** the epic's child features/stories stay in their sibling top-level dirs — their **Parent Epic:** back-ref headers keep resolving …`) + the "Forward note" blockquote → `… **Whole-subtree move:** under the nested layout the epic's features and stories live inside the epic folder, so moving the folder carries the entire subtree in one operation (parentage is the path, nothing dangles).` (Delete the "Forward note" — it is now realized.)
- **47c (sweep the remaining flat/back-ref mentions).** Update the frontmatter `description` ("move-epic-only on the flat layout" → "a whole-subtree move under the nested layout"); the Step-6 exit line (`{N} child features / stories left in place (flat layout).` → `… archived with the epic (nested subtree).`); and the Notes "Move-epic-only (flat layout)" bullet → "Whole-subtree archive (nested layout)".
- **VERIFY:** `grep -c "Parent Epic\|Parent Feature" host/templates/claude/commands/p5-finalize-epic.md` = 0; `grep -c "whole-subtree" …/p5-finalize-epic.md` ≥ 1.

## Step 48 — `skills/p5-finalize-epic/SKILL.md` (row 48)

- Mirror Step 47 in the skill: the frontmatter description ("move-epic-only on the flat layout" → "a whole-subtree move under the nested layout"); the "Guard — children finalized" item (`found via **Parent Epic:** back-ref headers on the flat layout`) → nested-tree walk; the "Move to archive" item (`move-epic-only; children stay … keep resolving via back-refs`) → whole-subtree move.
- **VERIFY:** `grep -c "Parent Epic\|Parent Feature" …/p5-finalize-epic/SKILL.md` = 0; `grep -c "whole-subtree" …` ≥ 1.

## Step R1-ext — `templates/SHAMT_RULES.template.md` (row-1 rules-sweep extension)

The #13-added back-ref remnants in the rules (added after Phase 1's Step 1 was authored) are swept:

- The §Finalize-phase `/p5-finalize-epic` bullet (`On the current flat layout this is **move-epic-only** — the epic's child features/stories stay in their sibling top-level dirs, their **Parent Epic:** back-refs still resolving.`) → nested whole-subtree wording.
- The §Ticket-IDs section: DELETE the `- **Parent back-refs** use T{N} (slug) …` bullet (obsolete — no back-refs); reword **Allocation** (`max … across epics/, features/, AND stories/`) to the nested-tree scan; reword **Addressing** (the flat both-positions glob) to "resolved per §PO-tree resolution".
- **VERIFY:** the only `Parent Epic`/`Parent Feature` mention remaining in `SHAMT_RULES.template.md` is the single §PO-tree-resolution line **declaring their absence** ("there are no `**Parent Epic:**` / `**Parent Feature:**` back-ref headers") — i.e. `grep -c "Parent Epic\|Parent Feature" templates/SHAMT_RULES.template.md` = 1, and that one match is the absence-declaration.

---

## Step 49 — `commands/e8-finalize-story.md` (row 49)

- `/e8-finalize-story` resolves the story folder by a root-level flat glob (`stories/{slug}/`, then `stories/{slug}-*/`) — which finds only legacy-flat stories, not nested ones. Repoint the Arguments resolution line to §PO-tree resolution (tree-wide glob + legacy-flat fallback). Artifact literals (`feedback/…`, `ticket.md`, `testing_plan.md`) are path-relative shorthand — leave intact.
- **VERIFY:** `grep -c "§PO-tree resolution" host/templates/claude/commands/e8-finalize-story.md` ≥ 1; no root-level `stories/{slug}/` resolution glob remains as the resolver.

## Step 50 — `skills/e8-finalize-story/SKILL.md` (row 50)

- Mirror Step 49: the skill's "Resolve the story folder" item → §PO-tree resolution.
- **VERIFY:** `grep -c "§PO-tree resolution" …/e8-finalize-story/SKILL.md` ≥ 1.

## Phase 5 verification

- [ ] `grep -rn "Parent Epic\|Parent Feature" host/templates/claude/ templates/` returns only the rules' single absence-declaration line — no back-ref reads/writes anywhere.
- [ ] `/p5-finalize-epic` (command + skill) does child-discovery by nested-tree walk and archives by whole-subtree move.
- [ ] No `.claude/` file edited.

Report `All steps completed. Verification passed.`


---
Validated 2026-06-12 — in-place amendment (p5+e8 finalize-command fold) re-validated
