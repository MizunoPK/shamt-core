# Proposal: decompose-catalog-start-validate-deepdive

**Created:** 2026-06-07
**Status:** Draft (f0 — audit capture, unrefined)
**Number:**
**Proposed by:**
**Project context:**

> **f0 DRAFT — unrefined capture.** Quick-captured by the framework audit
> or a user; not yet through the open-questions dialog. Run
> `/f1-propose-update decompose-catalog-start-validate-deepdive` to flesh it out — f1 ingests this file as
> its intake, normalizes the status to plain `Draft`, and develops the
> Scratch Notes below into a full Problem + Proposed Changes + Risks /
> Rollback / Validation Considerations.

---

## Scratch Notes (f0 capture)

Raw blurb (verbatim, original framing):

> After epic or feature decomposition results in new files, then the agent should provide a prompt for doing a validation loop on the new files similar to what happens in the framework update flow when we have multiple implementation plan files created.

**Refined direction (supersedes the original "validate-right-after-decomposition" framing):**

Rebalance *where the work happens* across the decompose → start-* boundary:

1. **Decomposition catalogs more, up front.** `/p2-decompose-epic` and `/p4-decompose-feature` should research and write **far more substantive detail into each created file** than today's near-empty stub (which carries only Parent back-refs + a one-line goal/scope). The decomposition pass becomes a real cataloging pass — capturing researched context for each child so the created file is a richer starting point, not a placeholder.
2. **Validation + deep dive happens at the start-* stage.** The validation loop is **not** emitted right after decomposition. Instead, it moves into the corresponding **start-* phase** — `/p3-start-feature` for features, `/e1-start-story` for stories — where it runs **alongside a more focused, targeted deep dive**: further research and development of that one document. So start-* = (a) validate what decomposition cataloged + (b) deepen/target the research and flesh the document out.

Net effect: decomposition does broad-but-richer cataloging across all children; start-* does narrow-but-deep validation + research on the single child being started. The original "batch validation prompt right after decomposition" is replaced by a **per-document validation loop folded into start-*'s existing deep-dive**.

Context / notes for f1:

- The PO decomposition phases each emit **multiple new artifacts in one run**:
  - `/p2-decompose-epic` writes N `features/{feature-slug}-{brief}/feature.md` files **and** appends Target Features + Sequencing & Parallelization back onto the parent `epic.md`.
  - `/p4-decompose-feature` writes N `stories/{story-slug}-{brief}/ticket.md` files **and** appends Target Stories + Sequencing & Parallelization back onto the parent `feature.md`.
- The start-* phases are where per-document deepening already lives: `/p3-start-feature` (flesh out a feature stub via open-questions dialog) and `/e1-start-story` (stub-aware intake). The refined direction **adds a validation loop** to these phases and **strengthens the research/deep-dive** they already do.
- Today's design deliberately keeps decomposition stubs minimal and defers deep dialog to start-*. This proposal **shifts that balance**, not just adds a validation step — f1 must weigh that against the existing rationale (decomposition = breadth/sequencing decision; start-* = depth) before committing.
- The original idea referenced `reference/batch_validation_handoff.md` (the framework-update batch-validation prompt; see archived proposal `proposals/archive/batch-validation-handoff.md`). Under the refined direction the **batch handoff is likely no longer the mechanism** — validation is per-document at start-* (one artifact, fits one session), so a plain `/validate-artifact` loop inside start-* may suffice rather than a fan-out prompt. f1 to confirm.

Open design questions to resolve in f1 (NOT decided here):

- **How much richer should decomposition stubs get?** Where is the line between "catalog enough researched context to seed start-*" and "do start-*'s deep-dive prematurely / duplicate it"? What sections of the feature/ticket templates does decomposition now populate vs. leave for start-*?
- **What exactly does the start-* validation loop validate** — the decomposition-cataloged content, the deepened document, or both at the end of the deep dive? Is it a standard `/validate-artifact` Pattern 1 loop folded into the phase's exit, or something lighter?
- **Does the batch-validation handoff still play any role**, or is it fully replaced by per-document validation at start-*?
- Which commands/skills change (decomposition side: `p2-decompose-epic`, `p4-decompose-feature`; start-* side: `p3-start-feature`, `e1-start-story` — each command + mirrored skill), and whether the feature/ticket **templates** need new sections to hold the richer cataloged content.

Implicated canonical files (informal — f1 produces the authoritative Proposed Changes table):

- `host/templates/claude/commands/p2-decompose-epic.md` (+ mirrored skill) — richer cataloging into feature files
- `host/templates/claude/commands/p4-decompose-feature.md` (+ mirrored skill) — richer cataloging into ticket files
- `host/templates/claude/commands/p3-start-feature.md` (+ mirrored skill) — add validation loop + strengthen deep dive
- `host/templates/claude/commands/e1-start-story.md` (+ mirrored skill) — add validation loop + strengthen deep dive
- the feature / ticket **templates** under `templates/` (if richer decomposition content needs dedicated sections)
- possibly `README.md` and `reference/batch_validation_handoff.md` (only if the batch handoff is retained for any path)

---

## Problem

[Deferred to /f1-propose-update.]

---

## Proposed Changes

[Deferred to /f1-propose-update.]

---

## Risks

[Deferred to /f1-propose-update.]

---

## Rollback Plan

[Deferred to /f1-propose-update.]

---

## Validation Considerations

[Deferred to /f1-propose-update.]
