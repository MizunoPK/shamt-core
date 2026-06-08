# Proposal: rules-file-over-budget

**Created:** 2026-06-07
**Status:** Draft (f0 — audit capture, unrefined)

> ⚠️ **f0 draft — unrefined capture.** Captured by the `/f5-audit-framework` **D12** check (rules-file size budget). Not yet a validated proposal: no formal Proposed Changes table, no Risks/Rollback/Validation, no open-questions dialog, no validation footer. The dedicated trimmer develops it: run `/trim-rules-file rules-file-over-budget` to analyze concrete cuts and flesh out this draft, then `/f1-propose-update rules-file-over-budget`.

---

## Scratch Notes (f0 capture)

**D12 finding (2026-06-07):** `templates/SHAMT_RULES.template.md` is **over budget**.

- Measured: `wc -m templates/SHAMT_RULES.template.md` = **40,281 chars**
- Budget: `rules_size_budget_chars` = **40,000** (default)
- Over by: ~281 chars; target after trim: ~75% of budget (**~30,000 chars**)

The rules file renders into every child `CLAUDE.md` and is loaded into the AI's context on every interaction, so its size is a recurring context cost.

**Next action:** run **`/trim-rules-file`** — it scans `SHAMT_RULES.template.md` for concrete reductions (duplication/repetition, content extractable to `reference/`, verbose passages to rephrase, procedural detail movable into command/skill bodies) and authors the detailed cut proposal toward the ~30k target. **Quality guardrail:** every cut is an extraction / rephrase / relocation — never a silent deletion of a normative rule.

This stub is the lightweight D12 capture (per `proposals/archive/08-rules-size-budget-trim-skill.md`, the dimension that detected it). The detailed cut list is deferred to the `/trim-rules-file` run.

---

## Proposed Changes

*(Placeholder — `/trim-rules-file` populates the concrete cut list; `/f1-propose-update` builds the formal CREATE/EDIT/DELETE/MOVE table.)*

---

## Risks

*(Placeholder — filled at f1.)*

---

## Rollback Plan

*(Placeholder — filled at f1.)*

---

## Validation Considerations

*(Placeholder — filled at f1.)*

---

## Open Questions

*(Deferred to f1.)*
