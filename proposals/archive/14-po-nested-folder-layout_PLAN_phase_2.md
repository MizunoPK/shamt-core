# Implementation Plan — Phase 2 (PO flow): po-nested-folder-layout (#14)

**Index:** [`14-po-nested-folder-layout_PLAN.md`](14-po-nested-folder-layout_PLAN.md) · **Rows:** 5–12 · **Deploy order:** after Phase 1 (cites §PO-tree resolution C1, active-pointer C2, back-ref drop C3).

> Canonical-only; no `.claude/`. Each command edit is mirrored in its skill. Recurring transforms:
> - **R-RESOLVE:** a root-level resolution/recovery glob → "resolve per `templates/SHAMT_RULES.template.md` §PO-tree resolution" (feature/story globs become tree-wide; the epic glob stays — epics are top-level).
> - **R-CREATE:** a feature creation path `features/{ID}-…/` → `epics/{epic-folder}/features/{ID}-…/`; a story creation path `stories/{ID}-…/` → `epics/{e}/features/{feature-folder}/stories/{ID}-…/`.
> - **R-BACKREF (full sweep, not just writes):** back-ref headers are removed *everywhere* in each file, not only at the write instruction. For each PO command/skill: `grep -n "Parent Epic\|Parent Feature"` the file and handle **every** hit — (i) **write** instructions / bullets → DELETE; (ii) **read / preserve** instructions ("read the `**Parent Epic:**` header", "preserve verbatim") → DELETE or reword to "derive the parent from the folder path"; (iii) **descriptive / exit-gate / Notes** mentions ("each stub carries `**Parent Epic:**` …", "`**Parent Epic:**` header reflects the input mode") → reword to "parentage is the folder path". The enumerated line numbers in each Step are the **known anchors**; the sweep catches the rest. The Step's VERIFY `grep -c "Parent Epic\|Parent Feature" = 0` is the achievable end-state of a complete sweep. **If any occurrence's rewording is not obvious, the executor halts (`Step [N] is ambiguous`) for the architect** — back-ref-sweep rewordings are the one place this plan permits a judgment escalation.
> - **R-PTR:** after creating/advancing an item, write its full resolved path to `.shamt-state/active-{epic|feature|story}` (C2).

---

## Step 5 — `commands/p1-start-epic.md` (row 5)

Epics stay top-level — the only changes are the active-pointer write and dropping the "globally unique across `epics/`" flat framing.

- **5a (R-PTR).** Write the active-epic pointer in a place **every** code path reaches — not only the freeform write (L95). Add to the **exit/confirm step** (the Step listing the L121/L128 folder-confirm `epics/{ID}-*/` glob + `epic.md` exists check, which runs after fetch, freeform, **and** local-resolve paths) the sentence: `Before exiting, write the resolved epic-folder path to .shamt-state/active-epic (create .shamt-state/ if absent) — the status-line active-epic pointer.` This covers all of Step 4's sub-paths uniformly.
- **5b (resolution note).** The epic resolution globs at L43/L44/L121 are valid as-is (epics are top-level); **add** a parenthetical to the L43 resolution sentence: `(epics are top-level; see §PO-tree resolution).` No glob string change.
- **5c.** No back-ref writes exist in p1 (epics have no parent) — nothing to remove.
- **VERIFY:** `grep -c ".shamt-state/active-epic" host/templates/claude/commands/p1-start-epic.md` ≥ 1; `grep -c "§PO-tree resolution" …/p1-start-epic.md` ≥ 1.

## Step 6 — `skills/p1-start-epic/SKILL.md` (row 6)

- Mirror 5a/5b: in the Resolve/create summary (L33–L34), add the `.shamt-state/active-epic` write and the "(epics top-level; §PO-tree resolution)" note. **VERIFY:** `grep -c ".shamt-state/active-epic" …/p1-start-epic/SKILL.md` ≥ 1.

## Step 7 — `commands/p2-decompose-epic.md` (row 7)

- **7a (R-CREATE).** L111 `and create features/{ID}-{feature-slug}-{brief}/feature.md` → `and create epics/{epic-folder}/features/{ID}-{feature-slug}-{brief}/feature.md` (nested under the resolved parent epic folder). Update the exit-gate L155 `N feature-stub folders exist at features/{ID}-{feature-slug}-{brief}/` and L181 likewise → `epics/{epic-folder}/features/{ID}-{feature-slug}-{brief}/`.
- **7b (R-BACKREF).** Remove the back-ref **write** bullet L113 `**Parent Epic:** T{N} ({epic-slug}) — back-ref to the parent epic …, a header line directly under the H1. Plain markdown; no parser.` — delete this bullet entirely (parentage is the path, C3). In the **exit-gate stub-contents description** (the line near L180–181 reading `carry **Parent Epic:** {epic-slug} + ## Goal + …`), **reword** to drop the back-ref and state structure instead: `carry ## Goal + ## Scope / Non-Scope + ## Decomposition Context (the parent epic is the folder path)` (re-locate by text per the Locate-string contract — line numbers shift after the L113 deletion). This is part of the R-BACKREF sweep; the Step VERIFY below is the sweep's end-state.
- **7c (R-RESOLVE).** The collision-detection glob L105 `glob features/{feature-slug}-*/, features/*-{feature-slug}-*/ … and features/{feature-slug}/` → replace the three-glob list with: `resolve per §PO-tree resolution (tree-wide feature glob) to detect a global collision`. The "Decomposed … at features/{slug-1}, …" status lines (L50, L127, L128, L160, L182) are **path-relative shorthand recovered via the tree glob** — leave the `features/{slug}-*/` recovery-glob mentions but append once at L128 `(recovered via §PO-tree resolution)`.
- **7d (R-PTR).** Not required at decompose (decompose creates stubs, not an "active" advance) — skip; the active-feature pointer is written by `/p3-start-feature`.
- **VERIFY:** `grep -c "epics/{epic-folder}/features/" …/p2-decompose-epic.md` ≥ 2; the back-ref sweep is complete — `grep -c "Parent Epic\|Parent Feature" …/p2-decompose-epic.md` = 0.

## Step 8 — `skills/p2-decompose-epic/SKILL.md` (row 8)

- Mirror Step 7: L9 + L40 + L58 drop the `**Parent Epic:** {epic-slug}` write; L40 `create … feature stubs` path → nested `epics/{epic-folder}/features/…`; L39 collision glob → §PO-tree resolution; L41 "Decomposed … at features/{slug-1}…" recovery note appended `(via §PO-tree resolution)`.
- **VERIFY:** `grep -c "Parent Epic" …/p2-decompose-epic/SKILL.md` = 0.

## Step 9 — `commands/p3-start-feature.md` (row 9)

- **9a (R-CREATE, mode-aware).** Every feature nests under an epic; the parent epic folder depends on the mode — **stub (Mode A):** its existing nested parent; **standalone (Mode B):** the standing **Tech Stories** epic folder (the reserved `tech-stories` epic seeded by #15, resolved per §PO-tree resolution); **tracker (Mode C):** the matched local epic, else Tech Stories. Apply the nesting at **all four creation sites**:
  - **L7 (Purpose, generic)** `produce features/{ID}-{slug}-{brief}/feature.md` → `produce the feature under its parent epic — epics/{parent-epic-folder}/features/{ID}-{slug}-{brief}/feature.md (the parent epic is the stub's epic, or the Tech Stories epic for standalone work)`.
  - **L69 (allocate-ID + propose-folder, Modes B/C)** `propose features/{ID}-{slug}-{brief-description-kebab}/` → `propose epics/{parent-epic-folder}/features/{ID}-{slug}-{brief-description-kebab}/ — {parent-epic-folder} is the matched parent epic, or the Tech Stories epic for standalone (Mode B) / unmatched-tracker-parent (Mode C) features`.
  - **L93 (Mode-B write)** `Write features/{ID}-{slug}-{brief}/feature.md` → `Write epics/{parent-epic-folder}/features/{ID}-{slug}-{brief}/feature.md (here {parent-epic-folder} is the standing Tech Stories epic — standalone features live there, #15)`.
  - **Exit-gate L153 / L184** `features/{ID}-{slug}-{brief}/feature.md exists` → `epics/{parent-epic-folder}/features/{ID}-{slug}-{brief}/feature.md exists (nested)`.
- **9b (R-RESOLVE).** L44/L45/L146 feature-resolution globs (`features/{ID}-*/feature.md`, `features/{slug}-*/feature.md`, `features/*-{slug}-*/feature.md`, the exact `features/{slug}/`) → replace with "resolve per §PO-tree resolution". L21 `Globally unique across features/ (flat layout)` → `Globally unique across the tree (see §PO-tree resolution)`.
- **9c (R-BACKREF + Mode-B home).** Mode-A preservation of the back-ref is dropped: L82 `feature.md already carries the **Parent Epic:** {epic-slug} back-ref header and a populated ## Goal` → `feature.md already carries a populated ## Goal` (the parent epic is the path now). L84 `Preserve the back-ref header and ## Goal verbatim.` → `Preserve the ## Goal verbatim.` L157/L158/L187 exit-gate back-ref checks → delete those checkboxes/clauses (the exit-gate `**Parent Epic:** header reflects the input mode …` line is removed entirely). **Mode B (standalone):** L94 currently says to leave `**Parent Epic:**` blank — replace that whole instruction with: `Mode B has no top-level home — a standalone feature is created under the standing Tech Stories epic (epics/{parent-epic-folder}/features/{ID}-{slug}-{brief}/feature.md (here {parent-epic-folder} = the Tech Stories epic), per #15). There is no blank-parent / top-level feature.` (If #15 has not landed alongside, the executor halts per the index's sequencing precondition.) **Mode C (tracker-seeded):** the Mode-C step that *populates* a `**Parent Epic:** {epic-slug}` header from the payload's parent link (`Parent work-item link … → populate **Parent Epic:** {epic-slug} only if the parent's slug resolves to an existing local epic folder … Otherwise leave blank …`) → replace with: `the parent work-item link determines the feature's nesting parent — create the feature under the matched local epic folder when the parent's slug resolves to one under epics/, else under the Tech Stories epic (#15). No **Parent Epic:** header is written (parentage is the path, C3).` This drop is what makes the Step-9 VERIFY's `grep "Parent Epic" = 0` achievable.
- **9d (R-PTR).** In the write step, append: `After writing feature.md, write its path to .shamt-state/active-feature (and .shamt-state/active-epic for its parent epic when nested).`
- **VERIFY:** `grep -c "Parent Epic" …/p3-start-feature.md` = 0; `grep -c ".shamt-state/active-feature" …` ≥ 1; `grep -c "epics/{parent-epic-folder}/features/" …` ≥ 1.

## Step 10 — `skills/p3-start-feature/SKILL.md` (row 10)

- Mirror Step 9: L6 path → nested; L37 resolution → §PO-tree resolution; L39 `Preserve **Parent Epic:** and (when present) **Parent Feature:** back-ref headers verbatim` → drop (no headers); L44 Mode-B `**Parent Epic:** left blank` → drop; L60 exit `**Parent Epic:** reflects the input mode …` → drop; add `.shamt-state/active-feature` write.
- **VERIFY:** `grep -c "Parent Epic" …/p3-start-feature/SKILL.md` = 0.

## Step 11 — `commands/p4-decompose-feature.md` (row 11)

- **11a (R-CREATE).** L131 `create stories/{ID}-{story-slug}-{brief}/ticket.md` → `epics/{e}/features/{feature-folder}/stories/{ID}-{story-slug}-{brief}/ticket.md` (nested under the resolved parent feature). Exit-gate L180 / L206 likewise.
- **11b (R-BACKREF).** Remove the back-ref **write** bullets L138 `**Parent Feature:** T{N} ({feature-slug}) — required for every stub …` and L139 `**Parent Epic:** T{N} ({parent-epic-slug}) — populated from … Omit … when standalone.` — delete both bullets (parentage is the path). L7 drop `(each carrying **Parent Feature:** and **Parent Epic:** back-ref headers + …)` → `(each carrying the scope one-liner + a ## Decomposition Context breadth section)`. L181 / L206 drop the `carry **Parent Feature:** … and … **Parent Epic:** … back-ref headers under H1, plus` clauses, keeping the scope-one-liner + Decomposition Context.
- **11c (R-RESOLVE).** Collision glob L123 (`stories/{story-slug}-*/`, `stories/*-{story-slug}-*/`, `stories/{story-slug}/`) → "resolve per §PO-tree resolution (tree-wide story glob)". L26 prereq `features/{slug}-*/feature.md must exist` + L35/L36 feature resolution → §PO-tree resolution. "Decomposed … at stories/{slug-1}…" lines (L50, L152, L153, L180-area) keep the slug recovery via the tree glob — append `(via §PO-tree resolution)` once at L153.
- **VERIFY:** `grep -c "Parent Feature\|Parent Epic" …/p4-decompose-feature.md` = 0; `grep -c "features/{feature-folder}/stories/" …` ≥ 1.

## Step 12 — `skills/p4-decompose-feature/SKILL.md` (row 12)

- Mirror Step 11: L9 path → nested; L35 resolution → §PO-tree resolution; L50 collision glob → §PO-tree resolution; L55 + L75 drop the `**Parent Feature:** {feature-slug} … **Parent Epic:** {parent-epic-slug}` write clauses (keep scope one-liner + Decomposition Context); L56 "Decomposed … at stories/{slug-1}…" recovery note appended `(via §PO-tree resolution)`.
- **VERIFY:** `grep -c "Parent Feature\|Parent Epic" …/p4-decompose-feature/SKILL.md` = 0.

---

## Phase 2 verification

- [ ] `grep -rn "Parent Epic\|Parent Feature" host/templates/claude/commands/p*.md host/templates/claude/skills/p*/SKILL.md` returns **no back-ref write instructions** (only, at most, historical mentions explicitly noting they are dropped).
- [ ] Feature creation paths are nested under `epics/{epic-folder}/features/`; story creation paths under `…/features/{feature-folder}/stories/`.
- [ ] `/p1` writes `.shamt-state/active-epic`, `/p3` writes `.shamt-state/active-feature`.
- [ ] Every resolution/collision glob cites §PO-tree resolution; no command spells out a bare root-level feature/story glob as the resolution mechanism.
- [ ] No `.claude/` file edited.

Report `All steps completed. Verification passed.` then halt for Phase 3.

---
Validated 2026-06-11 — adversarial sub-agent review (4 rounds; converged findings fixed)
