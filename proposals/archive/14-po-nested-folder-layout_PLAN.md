# Implementation Plan (index): po-nested-folder-layout (#14)

**Proposal:** [`proposals/14-po-nested-folder-layout.md`](14-po-nested-folder-layout.md) (Validated 2026-06-10 — 3 rounds, 1 adversarial sub-agent confirmed)
**Plan shape:** phase-decomposed — this index + 5 phase files. 50 Proposed Changes rows across the whole Engineer + PO surface exceed a single Phase-4 session. (Phase 5 + rows 47–50 added by in-place amendment during implementation — the #13 `/p5-finalize-epic` revisit surfaced at the diff-coverage gate.)
**Branch:** `proposal/14-po-nested-folder-layout` (created by `/f3-implement-update` from the base branch, per the pre-execution checklist below).

> **Sequencing precondition (from #14 Risks).** This proposal is #14's nested layout; it assumes the Tech Stories epic (#15) is the home for parentless work, and #13's `/e8-finalize-story` already exists (landed). Land **#14 + #15 together**. The plan-executor does not enforce cross-proposal order — the operator confirms #15 lands alongside before regen/archive.

---

## Pre-execution checklist (plan-executor reads this first)

- [ ] HEAD is on the base branch (`main` for shamt-core) and the working tree is clean except this plan + the proposal.
- [ ] `/f3-implement-update` has created and checked out `proposal/14-po-nested-folder-layout`.
- [ ] **Canonical-only.** Every step edits a path under `templates/`, `reference/`, or `host/templates/claude/` (commands / skills / agents), or the root `README.md`. **No `.claude/` edits** — regen (Phase 5) propagates. Halt if any step's path is `.claude/...`.
- [ ] Phases execute **strictly in deploy order 1 → 2 → 3 → 4.** Do not start Phase 2 until Phase 1 reports `All steps completed. Verification passed.` (Phases 2–4 reference the §PO-tree resolution section and the active-pointer scheme that Phase 1 creates.)

---

## Locate-string contract (read by the executor before any step)

`LOCATE` entries in the phase files are **line-anchored descriptive fragments**, not necessarily byte-exact strings: each cites a line number (valid against the current pre-edit file) plus the distinctive text on that line. To apply a step:

1. Open the cited line; **confirm** the fragment matches its distinctive text. If the live line carries formatting the fragment omits (e.g. inner backticks around `` `**Parent Epic:** {epic-slug}` `` or `` `## Goal` ``), that is expected — the fragment identifies the line; the **transform preserves the live line's exact formatting**.
2. After any step that **deletes** lines within a file, subsequent line numbers in that file shift — **re-locate later edits by their text**, not the printed absolute line number.
3. If a fragment matches **zero or more than one** line, **halt** (`Step [N] is ambiguous`) rather than guess — the plan-executor contract already requires this.

This contract lets the prose-transform edits below be applied unambiguously without reproducing every line's exact backtick formatting in the plan.

---

## Shared conventions (defined by Phase 1; every later phase references these)

These three definitions are created in Phase 1 and are the contract the other phases rely on. They are restated here so each phase file can cite them without redefining.

### C1 — `§PO-tree resolution` (new rules section, Phase 1 Step 1)

The nested layout is:

```
epics/{ID}-{epic-slug}-{brief}/
  epic.md
  features/{ID}-{feature-slug}-{brief}/
    feature.md
    stories/{ID}-{story-slug}-{brief}/
      ticket.md, spec.md, implementation_plan.md, feedback/, raw/, ...
```

Folders resolve by a **tree-wide glob with a legacy-flat fallback** (slugs stay globally unique, so the `{slug}-*` tail is unambiguous; exactly one match — halt on zero/multiple):

| Altitude | Nested glob | Legacy-flat fallback |
|---|---|---|
| Epic | `epics/{ID}-*/` · `epics/{slug}-*/` · `epics/*-{slug}-*/` (epics stay top-level) | — (epics already top-level) |
| Feature | `epics/*/features/{ID}-*/` · `epics/*/features/{slug}-*/` · `epics/*/features/*-{slug}-*/` | `features/{slug}-*/` |
| Story | `epics/*/features/*/stories/{ID}-*/` · `…/stories/{slug}-*/` · `…/stories/*-{slug}-*/` | `stories/{slug}-*/` |

**Body-text shorthand.** Throughout command / skill / template / reference bodies, `stories/{slug}/`, `features/{slug}/`, and `epics/{slug}/` denote **the resolved folder** (located via the globs above), whose leaf is still named `stories/{slug}-{brief}/` etc. They are **path-relative shorthands**, not literal top-level paths. This is why most artifact-path literals (`stories/{slug}/spec.md`) are left intact and only **annotated** as relative — the real rewrites are the *resolution globs*, the *back-ref writes*, and the *layout-documentation* sites (README hierarchy, `trackers/local.md` resolution table, `feature.template.md` "Lives at"). New work is **written nested**; existing flat folders stay and resolve via the fallback (no migration).

### C2 — Active-pointer scheme (Phase 1 Step 3, statusline + commands)

Root-level pointer files in the **project work tree** (not under `.shamt-core/`, so `import-shamt` never clobbers them): `.shamt-state/active-epic`, `.shamt-state/active-feature`, `.shamt-state/active-story`, each holding the full resolved nested path of the active item. `statusline.sh` reads them (replacing the `{parent}/.active` + most-recently-modified scan, which has no flat parent to scan under nesting); the `p*` / `e1` commands write/refresh the matching pointer when they create or advance an item. Parentage in the status line is derived by walking up the pointer path (no back-ref headers).

### C3 — Back-ref headers dropped

`**Parent Epic:**` / `**Parent Feature:**` header lines are **removed** from what `/p2`, `/p3`, `/p4` write and from `feature.template.md` / `ticket.*.template.md`; `/e1-start-story` stops *preserving* them and derives parentage from the path. The path is the single source of truth. (One-off / parentless work has no top-level home — it lives under the standing **Tech Stories** epic from #15.)

---

## Phase map (deploy order)

| Phase | File | Rows (from #14) | Scope |
|---|---|---|---|
| 1 | [`_PLAN_phase_1.md`](14-po-nested-folder-layout_PLAN_phase_1.md) | 1–4 | **Foundation.** Rules (add §PO-tree resolution C1, nested layout, drop back-ref convention, reword "standalone stories", active-pointer C2), README (hierarchy + back-ref section + status-line section), `statusline.sh` (pointer-file resolution + path-derived parentage), `review_categories.md` (annotate path-relative). |
| 2 | [`_PLAN_phase_2.md`](14-po-nested-folder-layout_PLAN_phase_2.md) | 5–12 | **PO flow.** `p1`–`p4` commands + skills: write nested folders (`epics/{e}/features/…`, `…/stories/…`), resolve per §PO-tree resolution, drop back-ref writes (C3), write the active pointer (C2). |
| 3 | [`_PLAN_phase_3.md`](14-po-nested-folder-layout_PLAN_phase_3.md) | 13–30 | **Engineer flow.** `e1`–`e7` (+`e3b`,`e5b`) commands + skills: resolve the story folder per §PO-tree resolution (replace the root globs), `e1` stops preserving back-refs (C3) + writes the active-story pointer (C2), annotate artifact-path literals as path-relative. |
| 4 | [`_PLAN_phase_4.md`](14-po-nested-folder-layout_PLAN_phase_4.md) | 31–46 | **Templates / tickets / trackers / personas.** Artifact templates (annotate path-relative + `feature.template` "Lives at" nested + drop its back-ref), ticket templates (drop back-ref lines), tracker references (`local.md` resolution table → tree glob; `ado.md`/`github.md` raw-path notes; `implementation_plan_reference.md` annotate), execution personas (`plan-executor`/`test-executor` resolve per §PO-tree resolution). |
| 5 | [`_PLAN_phase_5.md`](14-po-nested-folder-layout_PLAN_phase_5.md) | 47–50 + row-1 rules sweep | **#13 `/p5-finalize-epic` revisit** (folded in at the Phase-4 diff-coverage gate). Child-discovery → nested-tree walk; archive → whole-subtree move; sweep the #13-added back-ref remnants in the rules. |

**Row coverage:** 4 + 8 + 18 + 16 + 4 = 50. One-to-one with #14's Proposed Changes (Groups A–H, rows 47–50). `epic.template.md` and `commands/validate-artifact.md` are excluded per #14's path-discipline note (epics stay top-level; validate-artifact is layout-agnostic). Phase 5 (rows 47–50) was added by in-place amendment during implementation.

---

## Verification (per phase)

Each phase file ends with a verification block. Cross-phase invariants checked at the end of Phase 4:

- [ ] `grep -rnE 'glob .stories/\{slug\}-\*/' host/templates/claude/` returns **no root-level story globs** outside the §PO-tree resolution section / legacy-fallback mentions (all resolution now cites §PO-tree resolution).
- [ ] `grep -rn 'Parent Epic\|Parent Feature' host/templates/claude/ templates/` returns **no back-ref *write* instructions** (only historical/relative mentions where intentional) and the ticket/feature templates carry no back-ref header line.
- [ ] `bash scripts/regenerate-framework.sh --check --target .` is run only at Phase 5 (`/f4-regen-framework`), not here — the plan touches canonical sources only.

---

## Next phase

This is a phase-decomposed plan (index + 4 phase files → 5 validations). Per [`reference/batch_validation_handoff.md`](../reference/batch_validation_handoff.md), `/f2` emits a **batch-validation handoff prompt** (below) alongside the sequential fallback. The plan is **not** approved for `/f3-implement-update` until the index and all four phase files each carry a validation footer.

**Sequential fallback:**
```
/clear
/validate-artifact proposals/14-po-nested-folder-layout_PLAN.md
/validate-artifact proposals/14-po-nested-folder-layout_PLAN_phase_1.md
/validate-artifact proposals/14-po-nested-folder-layout_PLAN_phase_2.md
/validate-artifact proposals/14-po-nested-folder-layout_PLAN_phase_3.md
/validate-artifact proposals/14-po-nested-folder-layout_PLAN_phase_4.md
```



---
Validated 2026-06-12 — in-place amendment (p5+e8 finalize-command fold) re-validated
