# Proposal: rules-over-budget-post-nested-layout

**Created:** 2026-06-12
**Status:** Draft (f0 — audit capture, unrefined)
**Number:** [NN — master-side only; assigned by /f1-propose-update or /sync-triage-proposals promote.]
**Proposed by:** [master-local]
**Project context:** [master-local]

> **f0 DRAFT — unrefined capture.** Captured by the `/f5-audit-framework` D12
> sweep (post-implementation verification of #14 + #15). Run
> `/trim-rules-file rules-over-budget-post-nested-layout` (or `/f1-propose-update`
> to flesh it out) — D12 is **always intricate** and is **never auto-fixed**; it
> is captured for `/trim-rules-file`.

---

## Problem

[Deferred to /trim-rules-file — see Scratch Notes below.]

## Scratch Notes (f0 capture)

`templates/SHAMT_RULES.template.md` is **over the D12 size budget**: it measures
**42,915 chars** against the `rules_size_budget_chars` default of **40,000** —
**over by ~2,915 chars**.

The overflow was introduced by the two PO-layout proposals that just landed:

- **#14 (po-nested-folder-layout)** added the `### §PO-tree resolution` section
  (the nested-layout spec + resolution table + body-text shorthand + active-pointer
  scheme) and the `### Standing Tech Stories epic` section, plus reworded the
  standalone-stories statement and the §Finalize / §Ticket-IDs sweeps — pushing
  the file from ~39,332 to ~41,400 chars.
- **#15 (tech-stories-epic)** filled in the `### Standing Tech Stories epic`
  normative description (fixed reserved names, local-only containers, fast-path,
  per-feature archive) — pushing it to 42,915.

Run `/trim-rules-file` to bring it back under 40,000 by de-duplicating / cross-
referencing / rephrasing, **preserving every normative rule** (the same approach
as the prior `09-rules-file-over-budget` trim). Likely trim candidates: the
§PO-tree resolution body-text-shorthand paragraph (long), overlapping
Tech-Stories prose between the rules section and the new commands (the rules can
cross-reference `/p6-draft-tech-story` rather than restate), and any flat↔nested
explanatory redundancy.

This is **not** a blocker for #14/#15 landing (D12 is captured, not auto-fixed);
it is a follow-up trim.

---

## Proposed Changes

[Deferred to /trim-rules-file — the trim proposal enumerates concrete cuts.]

---

## Risks

[Deferred.]

---

## Rollback Plan

[Deferred.]

---

## Validation Considerations

[Deferred.]

---

## Open Questions

[Deferred to /trim-rules-file / /f1-propose-update.]
