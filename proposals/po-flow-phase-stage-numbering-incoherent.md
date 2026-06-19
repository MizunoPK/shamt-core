# Proposal: po-flow-phase-stage-numbering-incoherent

**Created:** 2026-06-19
**Status:** Draft (f0 — audit capture, unrefined)
**Proposed by:**
**Project context:**

> **f0 DRAFT — unrefined capture.** Quick-captured by the framework audit
> or a user; not yet through the open-questions dialog. Run
> `/f1-propose-update po-flow-phase-stage-numbering-incoherent` to flesh it out.

---

## Scratch Notes (f0 capture)

Audit finding surfaced during the Phase-6 sweep of proposal #41 (`po-validate-stage`,
the new per-altitude `-validate` stage + the pe2-decompose→pe3-decompose /
pe3-finalize→pe4-finalize / pf2-decompose→pf3-decompose renames). The PO-flow
self-labels in the command/skill bodies now use **two incompatible numbering
models at once**, producing genuinely incoherent per-altitude sequences (D2
cross-doc-consistency / D9 contradiction / D11 comprehension-risk class). The
README altitude × stage grid (`0-draft / 1-define / 2-validate / 3-decompose /
4-finalize`) is the clean per-altitude model; the command bodies disagree with it
and with each other.

Observed self-labels in the `**Purpose:**` lines (and mirrored skill descriptions):

- **Epic track (internally consistent, per-altitude):** `/pe1-define` = "Phase 1",
  `/pe2-validate` = "Stage 2", `/pe3-decompose` = "Phase 3", `/pe4-finalize` =
  "Phase 4". #41 deliberately relabeled the renamed epic commands to per-altitude
  numbers (proposal rows 7–8), so the epic track reads coherently — apart from the
  Phase/Stage word swap on the validate stage.

- **Feature track (incoherent):** `/pf1-define` = **"Phase 3"** (the OLD flow-wide
  cross-altitude number, pre-#41, left untouched), `/pf2-validate` = "Stage 2"
  (new, per-altitude), `/pf3-decompose` = **"Phase 4"** (old flow-wide number,
  inherited from old `/pf2-decompose`). So the feature altitude reads
  "Phase 3 (define) → Stage 2 (validate) → Phase 4 (decompose)" — the validate
  stage's number (2) is *lower* than the define stage it follows (3), and the
  sequence is non-monotonic.

- **Story track:** `/ps1-define` = "Stage 1", `/ps2-validate` = "Stage 2" —
  internally fine (per-altitude), but uses "Stage" while the epic/feature define
  stages use "Phase".

Resulting collisions across the flow: **two "Phase 3"s** (`/pe3-decompose` and
`/pf1-define`) and **two "Phase 4"s** (`/pe4-finalize` and `/pf3-decompose`).

Root cause: #41 renumbered only the epic track's self-labels (its rows 7–8
explicitly say "Update self-labels Phase 2 → Phase 3" / "Phase 3 → Phase 4") and
left the feature track's legacy flow-wide "Phase 3"/"Phase 4" labels in place,
while the README/grid and the new `-validate` commands moved to a per-altitude
"stage" model. The framework now mixes a flow-wide cross-altitude phase sequence
with a per-altitude stage grid.

Why this is intricate (capture, not auto-fix): the fix is a *design decision* on
the canonical numbering model — either (A) commit fully to per-altitude numbering
(renumber `/pf1-define` "Phase 3" → "1", `/pf3-decompose` "Phase 4" → "3", and
unify the Phase-vs-Stage word so define/validate/decompose/finalize all use one
noun per altitude), or (B) keep a single flow-wide sequence and renumber the
validate stages to fit it. Whichever is chosen, it spans multiple command bodies
**and** their mirror SKILL.md descriptions, and the README grid / SHAMT_RULES
§PO-tree must stay aligned. Multi-file + judgment + not-uniquely-determined →
intricate.

Implicated canonical files (informal — f1/f2 enumerate exactly):
`host/templates/claude/commands/{pe1-define,pe2-validate,pe3-decompose,pe4-finalize,pf1-define,pf2-validate,pf3-decompose,ps1-define,ps2-validate}.md`
and their mirror `host/templates/claude/skills/*/SKILL.md` descriptions; cross-check
against `README.md` (altitude × stage grid + command tables) and
`templates/SHAMT_RULES.template.md` §PO-tree for the canonical model to converge on.

---

## Problem

<!-- Filled by /f1-propose-update. -->

## Proposed Changes

<!-- Filled by /f1-propose-update. -->

## Risks

<!-- Filled by /f1-propose-update. -->

## Rollback Plan

<!-- Filled by /f1-propose-update. -->

## Validation Considerations

<!-- Filled by /f1-propose-update. -->

<!-- Phase 2 validation appends the footer below on a clean exit. Do not pre-fill. -->
