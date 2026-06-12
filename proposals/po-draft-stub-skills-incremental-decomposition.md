# Proposal: po-draft-stub-skills-incremental-decomposition

**Created:** 2026-06-12
**Status:** Draft (f0 — audit capture, unrefined)
**Number:** [NN — assigned by /f1-propose-update]
**Proposed by:**
**Project context:**

> **f0 DRAFT — unrefined capture.** Quick-captured by the framework audit
> or a user; not yet through the open-questions dialog. Run
> `/f1-propose-update po-draft-stub-skills-incremental-decomposition` to flesh it out.

---

## Problem

[Deferred to /f1-propose-update.]

## Scratch Notes (f0 capture)

Want to add PO skills for drafting new epics, features, and stories. The idea:
be able to **stub out** an initial epic, feature, or story, then run the
corresponding `start-*` skill to flesh it out — mirroring how
`/p2-decompose-epic` already writes feature stubs that `/p3-start-feature`
fleshes out (Mode A), and how `/p4-decompose-feature` writes story stubs that
`/e1-start-story` fleshes out.

This implies being able to **add** features to an already-created epic, or
stories to an already-created feature — i.e. incremental decomposition after the
fact, not only the one-shot decompose pass. Today `/p2-decompose-epic` and
`/p4-decompose-feature` produce the full stub set up front; there's no
first-class "draft one more feature stub under this existing epic" / "draft one
more story stub under this existing feature" entry point, and no standalone
"stub a brand-new epic" entry point either.

Likely implicated canonical surfaces (informal, for f1 to confirm):
- New PO-flow draft/stub commands + skills (e.g. a `draft-epic` / `draft-feature`
  / `draft-story` family), or extending `/p2-decompose-epic` /
  `/p4-decompose-feature` with an additive "stub one more" mode.
- The `start-*` skills that consume stubs: `p1-start-epic`, `p3-start-feature`,
  `e1-start-story` — they already have stub-aware modes; this would generalize
  the producer side.
- Stub shape / parentage conventions (the nested-folder layout from #14), the
  Decomposition Context breadth section, and ID/sequencing assignment when
  appending into an existing epic/feature subtree.
- README / SHAMT_RULES PO-flow overview.

Note: interacts with the in-flight #14 `po-nested-folder-layout` (folder/parentage
model) — f1 should reconcile against the nested layout rather than assume the
flat one.

---

## Proposed Changes

[Deferred to /f1-propose-update — template placeholder.]

---

## Risks

[Deferred to /f1-propose-update — template placeholder.]

---

## Rollback Plan

[Deferred to /f1-propose-update — template placeholder.]

---

## Validation Considerations

[Deferred to /f1-propose-update — template placeholder.]

---

## Open Questions

[Deferred to /f1-propose-update.]
