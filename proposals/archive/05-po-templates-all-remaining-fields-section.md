# Proposal: po-templates-all-remaining-fields-section

**Created:** 2026-05-31
**Status:** Implemented
**Number:** 05
**Proposed by:**
**Project context:**
**Note (2026-06-06, f1 re-entry):** stripped the stale `shamt-core/` path prefix from Proposed Changes rows 1–2 (post-`shamt-core-standalone-repo` layout). Line numbers verified current against HEAD (epic last section `## Sequencing & Parallelization` line 44, feature line 46, `## All Remaining Fields` in ticket templates at ado:68 / github:71, producer sub-step instructions at `p1-start-epic.md:90` (B.5) / `p3-start-feature.md:120` (C.5), with Notes back-refs at `:152` / `:180`) — #04's §-edits were in-line and did not shift them. Numbered #05.

---

## Problem

The PO-flow producers write a `## All Remaining Fields` tracker-payload appendix that the epic and feature templates do not carry — a template-protocol alignment gap (D5, surfaced by `/f5-audit-framework`).

`/p1-start-epic` (Step 4 sub-step B, item 5, `host/templates/claude/commands/p1-start-epic.md:90`) and `/p3-start-feature` (Step 4 Mode C, item 5, `host/templates/claude/commands/p3-start-feature.md:120`) both instruct the agent to preserve any extra tracker fields inline in a `## All Remaining Fields` subsection "immediately above the validation footer slot (i.e., below `Sequencing & Parallelization`)", explicitly noting it is the "same pattern the story ticket templates use" (p1; p3 says "same pattern as `/p1-start-epic`"). (Each command also carries a Notes back-reference to that appendix at `p1-start-epic.md:152` / `p3-start-feature.md:180`.) The story ticket templates do carry that section as a skeleton heading — `templates/ticket.ado.template.md:68` and `templates/ticket.github.template.md:71` both have `## All Remaining Fields`. But `templates/epic.template.md` and `templates/feature.template.md` do **not**: their last section is `## Sequencing & Parallelization` (epic line 44, feature line 46), with no appendix section.

The result: a producing protocol writes a section the consuming template doesn't model, and the cross-template "same pattern as the ticket templates" claim is false for epics/features. A fresh agent following `/p1-start-epic`/`/p3-start-feature` has no skeleton to place the preserved fields into, and the section is easy to forget entirely.

---

## Proposed Changes

Add the `## All Remaining Fields` section to both PO-flow artifact templates, mirroring the ticket-template treatment, with the producers' "omit when empty / freeform" rule encoded as instructional text (epics/features have no `raw/` subfolder, so the fields are preserved inline only).

| # | Canonical path | Operation | One-line change description |
|---|----------------|-----------|------------------------------|
| 1 | `templates/epic.template.md` | EDIT | Add a `## All Remaining Fields` section immediately after `## Sequencing & Parallelization` (the producer's stated placement, above the validation-footer slot), with an instructional placeholder: tracker-seeded epics preserve every non-empty tracker field not already captured above, inline (no `raw/` subfolder at the epic altitude); omit the whole section when authored freeform or when nothing is worth preserving. |
| 2 | `templates/feature.template.md` | EDIT | Same addition at the feature altitude (after `## Sequencing & Parallelization`), with the same conditional/omittable instructional text, referencing the `/p3-start-feature` Step 4 Mode C (item 5) behavior. |

**Exact section text to add** (append after `## Sequencing & Parallelization`, before the validation-footer slot — identical for both templates except the altitude noun *epics* / *features*):

```markdown
## All Remaining Fields

*(Tracker-seeded {epics|features} only — omit this entire section when authored freeform or when there is nothing worth preserving.)* Every non-empty tracker payload field not already captured above, preserved inline ({epics|features} have no `raw/` subfolder at this altitude). Use the durable tracker field name as the heading/key.

- `{field}`: `{value}`
```

This mirrors the ticket templates' `## All Remaining Fields` skeleton (heading + instructional line + a `{key}: {value}` example row) — `templates/ticket.ado.template.md:68` / `templates/ticket.github.template.md:71` — adapted for the PO altitude: tracker-agnostic field naming, the "no `raw/` subfolder" note, and the omittable-when-freeform conditional the producers state. Row 1 uses *epics*; row 2 uses *features*.

Row count: 2 ≤ 10 — no Phase 3 plan required.

No producer edit is needed: `/p1-start-epic` and `/p3-start-feature` already instruct writing the section correctly — this change makes the templates match what they already write, so the "same pattern as the ticket templates" claim becomes true.

---

## Risks

- **Regression risk** — none. Purely additive template sections; no producer or executable-instruction change. Existing epics/features authored before this change are unaffected (the section is optional and append-only).
- **Drift risk** — both files are under `templates/` (canonical, not `.claude`-managed), so no regen is required; the change takes effect on the next `import-shamt`. No D1 exposure.
- **Child-project compatibility** — picked up cleanly on next `import-shamt`. Children that already authored epics/features simply gain the option going forward.
- **Open-questions debt** — none; the fix direction (add to template, mirror tickets) is determined by the producers' own "same pattern as the ticket templates" instruction.

---

## Rollback Plan

Revert the commit. No `/f4-regen-framework` needed (templates are not regenerated into `.claude/`); no child-side action required. Purely additive.

---

## Validation Considerations

- **Change-list completeness** — confirm only the two PO templates need the section; the ticket templates already have it and the producers already write it, so no `p1`/`p3` command/skill edits are in scope. Re-confirm no other artifact template (spec, context, plan, etc.) is missing a section its producer writes.
- **Placement fidelity** — the section must land **after** `## Sequencing & Parallelization` and above the validation-footer slot, matching the producers' "immediately above the validation footer slot" instruction. A misplacement (e.g., before Target Features/Stories) would diverge from the producer.
- **Conditional-section wording** — verify the instructional text captures the producers' "omit entirely when there is nothing worth preserving" rule and the "no `raw/` subfolder at the epic/feature altitude" distinction (epics/features preserve fields inline; only stories have `raw/`).
- **Affected surfaces** — templates only. No rules, references, host commands/skills, personas, or scripts.
- **Propagation plan** — takes effect on next `import-shamt`; no regen.

---

## Open Questions

(none remaining)

---

## Resolved Questions

<!-- Drafting-only log -->

- ~~Q: Add `## All Remaining Fields` as a permanent skeleton section, or change the producers to not imply a template section?~~ → A: Add the section to the templates (mirror the ticket templates), encoding the conditional "omit when empty/freeform" rule as instructional text. The producers explicitly say "same pattern the story ticket templates use," so the template should carry what the producer writes — determined by the producer instructions, not an open choice.

---
Validated 2026-06-06 — 3 rounds, 1 adversarial sub-agent confirmed (round 1 fixed a line-citation mispairing — the All-Remaining-Fields sub-step instruction is at p1:90 / p3:120, not the Notes back-refs at :152 / :180; the first sub-agent pass added the exact `## All Remaining Fields` section text to the Proposed Changes and corrected the "Mode C sub-step C.5" notation to "Mode C, item 5"; second pass confirmed)
