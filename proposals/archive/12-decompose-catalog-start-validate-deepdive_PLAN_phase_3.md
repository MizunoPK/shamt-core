# Implementation Plan — Phase 3 — decompose-catalog-start-validate-deepdive (#12)

**Created:** 2026-06-09
**Index:** `proposals/12-decompose-catalog-start-validate-deepdive_PLAN.md`
**Proposal:** `proposals/12-decompose-catalog-start-validate-deepdive.md` (Validated 2026-06-09)
**Cuts in this phase:** proposal rows 8, 9, 10, 11 — the start-* side (`/p3`, `/e1` + skills) consumes the stub's `## Decomposition Context` as a research seed before its existing terminal gate.
**Files edited:** `host/templates/claude/commands/{p3-start-feature,e1-start-story}.md` + their skills.

> **Deploy order:** runs after Phases 1–2 (the section exists and decomposition populates it). Each terminal gate is preserved verbatim — no `/validate-artifact` is folded in. Re-confirm anchors against the live files.

---

## Step 1: p3-start-feature command — consume the seed in Mode A (proposal row 8)
**Operation:** EDIT — `host/templates/claude/commands/p3-start-feature.md`

- **1a — Mode A intro: note the richer stub.**
  - **Locate:** `The folder exists; \`feature.md\` already carries the \`**Parent Epic:** {epic-slug}\` back-ref header and a populated \`## Goal\` from \`/p2-decompose-epic\` Step 8.`
  - **Replace:** `The folder exists; \`feature.md\` already carries the \`**Parent Epic:** {epic-slug}\` back-ref header and a populated \`## Goal\` from \`/p2-decompose-epic\` Step 8 — and, for a stub created under richer-cataloging decomposition, a populated \`## Scope / Non-Scope\` boundary and a \`## Decomposition Context\` section.`
  - *(The Locate is preserved verbatim and the richer-stub note is appended — `{epic-slug}` is kept unchanged; #12 does not touch the back-ref format.)*

- **1b — Mode A Step 2: consume the Decomposition Context seed, then deepen.**
  - **Locate:** `2. Proceed to Step 5 (architecture consult), then Step 6 (open-questions dialog) to populate \`Success Criteria\` and \`Scope / Non-Scope\`.`
  - **Replace:** `2. **Consume the stub's \`## Decomposition Context\` as a research seed when present** — a stub created before #12 (or via a path that didn't catalog it) lacks the section, so fall back to the existing \`## Goal\` alone (and \`## Scope / Non-Scope\` if it was already populated), with no failure. Then proceed to Step 5 (architecture consult) and Step 6 (open-questions dialog) to populate \`Success Criteria\` + \`Open Questions\` and the \`## Scope / Non-Scope\` boundary — **deepening** it when decomposition pre-populated it (a richer-cataloging stub), or **populating it from scratch** when it is empty (an older stub). The existing \`/validate-artifact\` handoff at the end of the command is unchanged; validation is not folded in here.`

**Verification:** `grep -Fc "Consume the stub's \`## Decomposition Context\` as a research seed" host/templates/claude/commands/p3-start-feature.md` → `1`; `grep -Fc "validation is not folded in here" host/templates/claude/commands/p3-start-feature.md` → `1`; `grep -Fc "chaining validation here would couple the two phases" host/templates/claude/commands/p3-start-feature.md` → `1` (the Principle-1 independence note is preserved, untouched).

---

## Step 2: p3-start-feature skill — mirror (proposal row 9)
**Operation:** EDIT — `host/templates/claude/skills/p3-start-feature/SKILL.md`
- **Locate:** `dialog to populate Success Criteria + Scope`
- **Replace:** `dialog — seeded by the stub's Decomposition Context when present — to populate Success Criteria + deepen Scope`

**Verification:** `grep -Fc "seeded by the stub's Decomposition Context when present" host/templates/claude/skills/p3-start-feature/SKILL.md` → `1`.

---

## Step 3: e1-start-story command — consume the seed in the stub-aware case (proposal row 10)
**Operation:** EDIT — `host/templates/claude/commands/e1-start-story.md`
- **Locate:** `Mark the invocation as **stub-aware**: the back-ref headers and the scope one-liner in the body are preserved verbatim throughout the rest of this command.`
- **Replace:** `Mark the invocation as **stub-aware**: the back-ref headers and the scope one-liner in the body are preserved verbatim throughout the rest of this command. The stub's \`## Decomposition Context\` (when present — pre-#12 / freeform stubs lack it) seeds the intake deepening as the research starting point; fall back to the scope one-liner alone when absent.`

**Verification:** `grep -Fc "seeds the intake deepening as the research starting point" host/templates/claude/commands/e1-start-story.md` → `1`; `grep -Fc "The user explicitly confirms the slug and ticket content" host/templates/claude/commands/e1-start-story.md` → `1` (the Intake confirmation gate is preserved, untouched — no `/validate-artifact` added).

---

## Step 4: e1-start-story skill — mirror (proposal row 11)
**Operation:** EDIT — `host/templates/claude/skills/e1-start-story/SKILL.md`
- **Locate:** `a PO-flow stub already has its ID — preserve it.`
- **Replace:** `a PO-flow stub already has its ID — preserve it, and its \`## Decomposition Context\` (when present) seeds the intake deepening.`

**Verification:** `grep -Fc "its \`## Decomposition Context\` (when present) seeds the intake deepening" host/templates/claude/skills/e1-start-story/SKILL.md` → `1`.

---

## Phase 3 exit
- `/p3` (Mode A) and `/e1` (stub-aware) consume the stub's `## Decomposition Context` as a research seed **when present**, with graceful fallback to the boundary alone when absent; both then deepen the depth detail. Each terminal gate is preserved verbatim — `/p3`'s `/validate-artifact` handoff + the Principle-1 independence note; `/e1`'s Intake confirmation gate. Skills mirror.
- **No commit.** All of #12's 12 rows are now implemented across Phases 1–3.

---

## Notes
- **Terminal gates untouched.** No `/validate-artifact` is folded into start-*; the edits add only a "consume the seed, then deepen" instruction before the existing gate. The `p3-start-feature.md` independence note and `e1-start-story.md` Intake gate are preserved (verified by grep above).
- **Graceful degradation.** Both consume points are guarded "when present" with an explicit fallback, so pre-#12 / freeform stubs (no Decomposition Context) do not break.
- Only `host/templates/claude/` files edited → `/f4-regen-framework` propagates them. No `.claude/`, no commit.

---
Validated 2026-06-09 — 2 rounds, 1 adversarial sub-agent confirmed (round 1 forked the Step-1b Scope/Non-Scope handling — deepen when decomposition pre-populated it, populate from scratch on an empty pre-#12 stub — and restored the `{epic-slug}` back-ref verbatim in Step 1a so #12 does not touch the back-ref format)
