# Implementation Plan (Index) — decompose-catalog-start-validate-deepdive (#12)

**Created:** 2026-06-09
**Proposal:** `proposals/12-decompose-catalog-start-validate-deepdive.md` (Validated 2026-06-09 — 6 rounds)
**Altitude:** Framework-update. Executor: `plan-executor` (Haiku) via `/f3-implement-update`, **one phase at a time in deploy order**.
**Base branch:** `main`

---

## Planning Status

- **Phase-decomposed** — 3 phase files (12 Proposed-Changes rows). Decomposed because the change adds a new template section, rewrites decompose-side populate logic + exit gates, and rewires start-* consume logic across 11 files + the rules note; it would compact a single Phase-4 session.
- **Ready for mechanical validation:** [x] **All 3 phase files authored** with exact locate/replace; every locate verified unique on disk.

---

## Deploy order

Phase 1 adds the **`## Decomposition Context`** section to the three templates (+ the rules-file invariant note) — the scaffolding the other phases write into / read from. Phase 2 makes the **decompose** side (`/p2`, `/p4`) populate that section + the breadth boundary, and strengthens the exit gate. Phase 3 makes the **start-*** side (`/p3`, `/e1`) consume the section as a research seed. **Phase 1 must land first** (the section must exist in the template before the commands reference it); Phase 2 before Phase 3 is conventional (writer before reader) though they touch disjoint files.

| Phase | File | Proposal rows | What it does | Status |
|-------|------|---------------|--------------|--------|
| 1 | `…_PLAN_phase_1.md` | 1, 2, 3, 12 | Add `## Decomposition Context` to `feature.template.md` (after `### Out of Scope`), `ticket.github.template.md` + `ticket.ado.template.md` (before `## Summary`); append the breadth/depth invariant sentence to `SHAMT_RULES.template.md` `## What is Shamt?` | **authored** |
| 2 | `…_PLAN_phase_2.md` | 4, 5, 6, 7 | `/p2` + `/p4` (+skills): populate the breadth boundary (`## Scope / Non-Scope` for features; scope one-liner for stories) + the new `## Decomposition Context`; add a 3rd exit-gate condition (cataloged content present) | **authored** |
| 3 | `…_PLAN_phase_3.md` | 8, 9, 10, 11 | `/p3` + `/e1` (+skills): consume the stub's `## Decomposition Context` (when present) + boundary as the research seed before the existing terminal gate (p3 `/validate-artifact` handoff; e1 Intake confirm) — both preserved verbatim | **authored** |

---

## Pre-Execution Checklist

- [ ] **Proposal branch** `proposal/12-decompose-catalog-start-validate-deepdive` created from `main` (Phase 1, Step 0). Halt if it already exists.
- [ ] All affected paths exist on disk (verified at planning time).
- [ ] **Hard rule:** edits go to canonical sources only — **never** `.claude/`. Phase 1 edits `templates/{feature,ticket.github,ticket.ado}.template.md` + `templates/SHAMT_RULES.template.md`; Phases 2–3 edit `host/templates/claude/{commands,skills}/` bodies.
- [ ] Review-Prevention Gate Mapping: **N/A at framework altitude** (agent-instruction / template edits — no app code, data, auth, tenancy, infra, tests).
- [ ] Each phase file validated (footer present) before its execution.

---

## Files Touched (manifest)

| Operation | Path | Phase |
|-----------|------|-------|
| BRANCH | `proposal/12-decompose-catalog-start-validate-deepdive` (from `main`) | 1 |
| EDIT | `templates/feature.template.md` | 1 |
| EDIT | `templates/ticket.github.template.md` | 1 |
| EDIT | `templates/ticket.ado.template.md` | 1 |
| EDIT | `templates/SHAMT_RULES.template.md` | 1 |
| EDIT | `host/templates/claude/commands/p2-decompose-epic.md` + `skills/p2-decompose-epic/SKILL.md` | 2 |
| EDIT | `host/templates/claude/commands/p4-decompose-feature.md` + `skills/p4-decompose-feature/SKILL.md` | 2 |
| EDIT | `host/templates/claude/commands/p3-start-feature.md` + `skills/p3-start-feature/SKILL.md` | 3 |
| EDIT | `host/templates/claude/commands/e1-start-story.md` + `skills/e1-start-story/SKILL.md` | 3 |

No other path is created or edited.

---

## Global guardrail (every phase)

- **Bounded breadth, not depth.** The `## Decomposition Context` section is breadth-only (inter-child dependencies, shared context, why-this-boundary) — never a depth dump. The disjoint breadth/depth split (proposal Resolved Q1) is what prevents duplication with start-*.
- **Feature/story asymmetry.** Features have a real `## Scope / Non-Scope` section (the breadth boundary); the ticket templates do **not** — a story's breadth boundary is the **scope one-liner** in the intake area. `/p4` and `/e1` reference the scope one-liner, not a non-existent section.
- **Terminal gates preserved (Principle 1).** No `/validate-artifact` is folded into start-*. `/p3` keeps its `/validate-artifact` handoff + the `p3-start-feature.md` independence note verbatim; `/e1` keeps its Intake confirmation gate.
- **Graceful degradation.** start-* consumes `## Decomposition Context` **only when present** (pre-#12 / freeform stubs lack it → fall back to the boundary alone, no failure). Not retroactive: pre-existing + Kept stubs are not retrofitted.
- **Exit gate ≠ /validate-artifact.** The strengthened decomposition exit gate stays a stub-batch check distinct from Pattern 1 (preserve the "do not conflate" notes).

---

## Notes

- **No `.claude/` edits.** Phases 2–3 edit `host/templates/claude/` bodies → `/f4-regen-framework` propagates them. Phase 1's template + rules edits are not regenerated (they render into a child at install/`sync-import`).
- **D12 size:** Phase 1 appends one sentence to the rules file (currently 37,245) → still well under the 40,000 budget. Phase 1's final step re-measures `wc -m`.
- **No commit in Phase 4 builds.** The commit + squash-merge land at `/f6-archive-proposal`.

---
Validated 2026-06-09 — 1 round, 1 adversarial sub-agent confirmed
