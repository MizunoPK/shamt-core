# Proposal: decompose-catalog-start-validate-deepdive

**Created:** 2026-06-07
**Status:** Implemented
**Number:** 12

---

## Resolved Questions

*(Open-questions dialog, Principle 2 — recorded as each is answered.)*

1. **Discriminating axis → Breadth vs. depth (proposed).** Decomposition catalogs **breadth-context** — what's knowable only by seeing the siblings (child boundaries, inter-child dependencies, sequencing/parallelization rationale, shared cross-set context). start-* captures **depth-detail** — everything internal to one child (design options, acceptance criteria, implementation approach). The two phases populate **disjoint** content; this is the rule that resolves the duplication risk.
2. **Principle-1 conflict → Keep each start-* phase's existing terminal gate; strengthen the pre-gate deep-dive.** Validation is **not** folded into start-*. Each start-* phase keeps the terminal gate it has today, preserving Principle-1 fresh-agent resumability: `/p3-start-feature` ends by **handing off to `/validate-artifact`** (`feature.md` gets a Pattern-1 pass — `p3-start-feature.md:171`); `/e1-start-story` ends at its **Intake confirmation gate** (the user confirms `ticket.md` — `e1-start-story.md:112,120`; the story's first Pattern-1 `/validate-artifact` follows downstream at the Spec phase, `/e2-define-spec`). #12's start-* novelty is therefore the **strengthened, more-targeted research/deep-dive that runs before that terminal gate** — not a coupled validation loop. Honest delta: the start-* terminal gates already exist, so #12's real weight is (a) richer cataloging at decomposition + (b) deeper, breadth-seeded research at start-*.
3. **Scope → Bundle as one proposal.** Both halves — (a) richer breadth-cataloging at decomposition (`/p2`, `/p4`) and (b) strengthened breadth-seeded research at start-* (`/p3`, `/e1`) before the existing handoff — ship together. They share the breadth-vs-depth axis and the same feature/ticket template changes; Q2 removed the riskiest element. The remaining contested point (half (a)'s resumability/atomicity load) is addressed in Risks, not by splitting.
4. **Cataloging depth → Boundaries + a new "Decomposition Context" section.** Decomposition adds two things per child beyond today's Parent back-refs + Goal one-liner: (i) **Scope / Non-Scope** (the in/out boundary — pure breadth, drawn by seeing siblings) and (ii) a **new `## Decomposition Context` section** capturing the researched breadth (inter-child dependencies, shared context, why-this-boundary). start-* fills the **depth** sections it owns today — Success Criteria detail, Open Questions, design options, implementation approach. Clean disjoint mapping. The Decomposition Context section is **bounded** (a few bullets of breadth context, explicitly not a depth dump) to keep the decompose run's resumability load in check.
5. **Gates → Strengthen the existing decomposition exit gate; add no new gate** *(derived from Q1+Q2, not separately asked).* The `/p2`/`/p4` Step-6 decomposition exit gate (a 2-condition stub-batch check, distinct from `/validate-artifact`) is **strengthened** to also confirm each stub carries the now-required cataloged content (Scope/Non-Scope + Decomposition Context). No new decomposition-time `/validate-artifact` is introduced — that was the original framing Q2 rejected.
6. **Validation mechanism → per-document at start-*, via the existing handoff; the batch-validation fan-out is NOT used** *(derived from Q2, not separately asked).* Because validation stays the existing per-command `/validate-artifact` handoff at the end of start-* (one artifact, one session), `reference/batch_validation_handoff.md` (the framework-update fan-out prompt) is **not** the mechanism here. No reference to it is added.

*(Open Questions: none remaining — the proposal is drafted.)*

---

## Problem

The Shamt PO flow splits work across two altitudes joined by a decompose → start-* boundary:

- **Decomposition** (`/p2-decompose-epic`, `/p4-decompose-feature`) proposes the child list, gates it once, then writes one stub per child. Today each stub is **near-empty**: `/p2` writes a feature stub carrying only the `**Parent Epic:**` back-ref + a one-line Goal; `/p4` writes a story `ticket.md` carrying only `**Parent Feature:**`/`**Parent Epic:**` back-refs + the scope one-liner in the intake area. Every other template section is left empty (`p4-decompose-feature.md` Step 8; `p2-decompose-epic.md` Step 8).
- **start-*** (`/p3-start-feature`, `/e1-start-story`) then does *all* per-child depth work — the open-questions dialog and research that flesh out the document — starting from that near-empty stub, and ends at its terminal gate: `/p3-start-feature` hands off to `/validate-artifact` (`p3-start-feature.md:171,174`); `/e1-start-story` ends at the Intake confirmation gate (`e1-start-story.md:112,120`), with the story's first `/validate-artifact` pass coming later at the Spec phase.

Two concrete pains follow from this balance:

1. **In-session breadth research is not persisted.** To draw the child list, decomposition must research the *whole set* — boundaries between children, inter-child dependencies, sequencing/parallelization rationale, shared context. Today that breadth understanding is **not written to the stubs** (only a one-line Goal/scope survives — `p2`/`p4` Step 8), so it is unavailable to start-*, which re-derives whatever sibling-level context it needs when each child is later started.
2. **Structural decomposition errors surface late.** A wrong boundary, a missing child, or bad sequencing is currently only felt when a child is *started* — possibly long after the decomposition run, when the error is most expensive to correct. The existing Step-6 decomposition exit gate is a 2-condition stub-batch check (`p4-decompose-feature.md` Step 6, ~:109, ending before Step 7 at :118) that does not capture or check any researched per-child context.

This proposal **rebalances where the work happens** — without violating the deliberate phase-per-command independence that `p3-start-feature.md:174` protects ("chaining validation here would couple the two phases … stays independently runnable by a fresh agent off on-disk state per Principle 1"). Per the Resolved Questions: decomposition **catalogs breadth-context** into a bounded new `## Decomposition Context` section plus the **breadth boundary** on each stub — for a feature that is its `## Scope / Non-Scope` section; for a story (whose ticket template has no such section) it is the existing **scope one-liner** in the intake area — capturing the sibling-level understanding while it is fresh; start-* **consumes that seed and goes deep** on the single child, then hands off to the *existing* `/validate-artifact` (unchanged). The breadth-vs-depth axis keeps the two phases populating **disjoint** content, so nothing is duplicated.

This is a **rebalance of an existing baseline, not new validation where there is none** — start-* validation already exists as the `/validate-artifact` handoff, and decomposition already has its exit gate. #12 strengthens and relocates; it does not invent a parallel mechanism.

---

## Proposed Changes

All paths are canonical sources. The `.claude/` generated copies are produced by `/f4-regen-framework`, never edited here. Command ↔ skill pairs move together; the writer-command ↔ template pairs (p2 ↔ feature.template; p4 ↔ ticket templates) move together.

| # | Path | Op | Change |
|---|------|----|--------|
| 1 | `templates/feature.template.md` | EDIT | Add a bounded **`## Decomposition Context`** section (placeholder prompting the breadth bullets: inter-child dependencies, shared context, why-this-boundary), placed **immediately after the `## Scope / Non-Scope` block (after `### Out of Scope`, before `## Target Stories`)** — keeping it adjacent to the other breadth section. (Current template order: `## Success Criteria` precedes `## Scope / Non-Scope`.) Annotate `## Scope / Non-Scope` as **populated at decomposition** (breadth boundary), and the depth sections (Success Criteria, Open Questions) as **start-* (`/p3`)**. |
| 2 | `templates/ticket.github.template.md` | EDIT | Add the same bounded **`## Decomposition Context`** section (story-level breadth), placed **immediately before `## Summary`** (a content section common to both ticket templates; note a `## Markdown Normalization Rules` fetch-helper section precedes `## Summary`, so anchor on `## Summary`). **Note the feature/story asymmetry:** the ticket template has **no `## Scope / Non-Scope` section** — a story's breadth boundary is the **scope one-liner in the intake area** (existing), so Decomposition Context is the *only* new section here. This template is also the **generic baseline** used for `local`/`none` trackers (`p4-decompose-feature.md:133`), so it covers the non-ADO case. |
| 3 | `templates/ticket.ado.template.md` | EDIT | Add the same **`## Decomposition Context`** section for the ADO ticket template, **same placement — immediately before `## Summary`** (the ADO template's pre-`Summary` helper is `## HTML Normalization Rules`), kept in lockstep with the GitHub/generic one. (Same asymmetry — no Scope/Non-Scope section.) |
| 4 | `host/templates/claude/commands/p2-decompose-epic.md` | EDIT | In Step 8 (stub creation), populate each feature stub's **Scope / Non-Scope** boundary + the new **Decomposition Context** breadth bullets from the whole-set research done to draw the list. Strengthen the **Step-6 decomposition exit gate** to also confirm each stub carries the required cataloged content (bounded — breadth only, not depth). Keep deep per-feature dialog deferred to `/p3`. |
| 5 | `host/templates/claude/skills/p2-decompose-epic/SKILL.md` | EDIT | Mirror row 4 (skill summary). |
| 6 | `host/templates/claude/commands/p4-decompose-feature.md` | EDIT | Same as row 4 at the story altitude, **with one asymmetry**: the ticket template has no `## Scope / Non-Scope` section, so populate each story stub's **scope one-liner** (the breadth boundary in the intake area — as p4 does today, Step 8) **+** the new **Decomposition Context** breadth bullets. Strengthen the Step-6 exit gate to confirm the cataloged content is present (bounded — breadth only). Keep deep per-story dialog deferred to `/e1` (stub-aware). |
| 7 | `host/templates/claude/skills/p4-decompose-feature/SKILL.md` | EDIT | Mirror row 6. |
| 8 | `host/templates/claude/commands/p3-start-feature.md` | EDIT | Strengthen the **pre-handoff deep-dive**: consume the stub's `## Decomposition Context` (**when present** — a feature stub created before #12 landed, or via a path that didn't catalog it, lacks the section; fall back to `## Scope / Non-Scope` alone with no failure) + Scope/Non-Scope as the **research seed**, then do deeper, more-targeted research to fill the **depth** sections (Success Criteria, Open Questions, design). **Preserve the existing `/validate-artifact` handoff and the Principle-1 independence note at `p3-start-feature.md:174` verbatim** — validation is NOT folded in. |
| 9 | `host/templates/claude/skills/p3-start-feature/SKILL.md` | EDIT | Mirror row 8. |
| 10 | `host/templates/claude/commands/e1-start-story.md` | EDIT | Same as row 8 at the story altitude (stub-aware Mode): consume the story stub's `## Decomposition Context` (**when present** — pre-#12 / freeform stubs lack it; fall back to the scope one-liner alone) + scope one-liner as the seed, deepen, then keep the existing **Intake confirmation gate** on `ticket.md` unchanged (no `/validate-artifact` is added — the story validates downstream at the Spec phase). |
| 11 | `host/templates/claude/skills/e1-start-story/SKILL.md` | EDIT | Mirror row 10. |
| 12 | `templates/SHAMT_RULES.template.md` | EDIT | **Append one sentence** to the PO-flow description paragraph in `## What is Shamt?` (the paragraph at ~:19 ending "…run the Engineer flow directly.") recording the **breadth-at-decompose / depth-at-start-*** invariant: decomposition catalogs breadth-context (a bounded `## Decomposition Context` + the breadth boundary) and start-* deepens depth before its existing terminal gate (`/p3` → `/validate-artifact` handoff; `/e1` → Intake confirmation). **One sentence only** — no new section heading — for D12 headroom (~37.2k current vs 40k budget). |

**Row count: 12 > 10 → Phase 3 (`/f2-plan-update-implementation`) is required.** Natural phase grouping: (1) the three templates + the rules-file invariant note; (2) the decompose side (`/p2`, `/p4` + skills — cataloging + strengthened exit gate); (3) the start-* side (`/p3`, `/e1` + skills — seeded deep-dive, existing handoff preserved).

---

## Risks

- **Resumability / atomicity load (the contested half (a)).** Richer cataloging makes decomposition do N-children's-worth of *breadth* research in one run — heavier, and partially complete if interrupted. **Mitigations:** the Decomposition Context section is **bounded** to breadth bullets (explicitly not a depth dump — Resolved Q4); `/p2` and `/p4` already write N files in one run, so this is a *degree* increase, not a new failure mode; the existing **Kept/New partitioning** (`p4-decompose-feature.md:56–57`) already preserves in-progress work on re-decomposition, so an interrupted/redone run does not clobber started children.
- **Duplication between decomposition and start-*.** If both phases researched the same thing, work would be redone. **Mitigation:** the breadth-vs-depth axis (Resolved Q1) makes them populate **disjoint** sections — decomposition owns Scope/Non-Scope + Decomposition Context; start-* owns Success Criteria detail + Open Questions + design.
- **Principle-1 regression.** Folding validation into start-* would break fresh-agent resumability. **Mitigation:** explicitly out of scope — Resolved Q2 keeps the existing `/validate-artifact` handoff; row 8/10 preserve the `p3-start-feature.md:174` note verbatim.
- **Gate confusion.** Strengthening the decomposition exit gate risks conflating it with `/validate-artifact`. **Mitigation:** the gate stays a stub-batch check distinct from Pattern 1 (preserve the `p4-decompose-feature.md:213` and `p3-start-feature.md:194` "do not conflate" notes); it only adds a content-presence check, not a validation loop.
- **Canonical-surface growth.** One new template section (×3 templates) + longer decompose/start-* command bodies add maintenance cost. **Mitigation:** a single bounded section; minimal command additions; the rules-file note is kept small.
- **D12 rules-file size.** The rules-file invariant note (row 12) grows `SHAMT_RULES.template.md` (~37.2k current). **Mitigation:** keep the note to a few sentences; confirm `wc -m` stays ≤ 40,000 at implementation.
- **Backward compatibility — stubs created before #12 lack `## Decomposition Context`.** After #12 lands, start-* (`/p3`, `/e1`) will meet a mix of new stubs (with the section) and pre-#12 stubs (without it); the section is also absent on freeform-created stories. **Mitigation:** rows 8/10 specify start-* consumes Decomposition Context **only when present** and falls back to Scope/Non-Scope (feature) / the scope one-liner (story) alone — no failure, graceful degradation. The change is **not retroactive**: pre-existing stubs are not rewritten, and Kept stubs on re-decomposition are not retrofitted (the `p4`/`p2` "do not touch Kept stubs" rule stands); the section simply accrues to new stubs going forward.

---

## Rollback Plan

`git revert <commit-sha>` restores the prior decompose/start-* balance (minimal stubs; start-* researches from near-scratch) and removes the `## Decomposition Context` section from the three templates; `/f4-regen-framework` re-propagates the host bodies. The change is **additive and data-safe**: any feature/ticket stubs already written with a populated Decomposition Context keep that content on disk (an extra section is harmless to a reverted reader), and the reverted start-* commands simply stop being *instructed* to treat it as a seed — they still read the whole stub. No artifacts are deleted or renamed. Children pick up the reverted contract on the next `/sync-import-shamt`.

---

## Validation Considerations

- **Risk-triggered → Standard path** (multi-file instruction-contract change across templates + commands + rules). Primary clean round + 1 adversarial sub-agent.
- **Affected surfaces:** `templates/feature.template.md`, `templates/ticket.github.template.md`, `templates/ticket.ado.template.md`, `host/templates/claude/{commands,skills}/{p2-decompose-epic,p4-decompose-feature,p3-start-feature,e1-start-story}`, and `templates/SHAMT_RULES.template.md`.
- **Cross-doc consistency (D2/D9):** the breadth-at-decompose / depth-at-start-* split must be described consistently across the rules-file note, the writer commands (`/p2`, `/p4`), the reader commands (`/p3`, `/e1`), and the templates. The new `## Decomposition Context` section must appear in **all three** templates and be referenced by both the writers (populate) and readers (consume).
- **Feature/story breadth-boundary asymmetry:** confirm the change consistently treats the breadth boundary as `feature.template.md`'s `## Scope / Non-Scope` **section** for features vs. the **scope one-liner in the intake area** for stories (the ticket templates have **no** `## Scope / Non-Scope` section — none is added). `/p4` and `/e1` must reference the scope one-liner, not a non-existent section.
- **Principle-1 preservation:** confirm `p3-start-feature.md:174`'s independence note is **not** weakened and that no `/validate-artifact` is folded into start-*'s deep-dive. Each start-* phase keeps its existing terminal gate unchanged — `/p3` the `/validate-artifact` handoff, `/e1` the Intake confirmation gate.
- **Gate distinctness:** confirm the strengthened decomposition exit gate stays a stub-batch check **distinct from** `/validate-artifact` (the "do not conflate" notes survive).
- **Paired edits:** every command ↔ skill pair (rows 4↔5, 6↔7, 8↔9, 10↔11) and writer ↔ template pair (p2 ↔ feature.template; p4 ↔ ticket templates) must move together.
- **Templates ↔ tracker coverage:** because `/p4` selects the ticket template by `work_item_tracker` (ado / github / local-or-none→github baseline), the Decomposition Context section must exist in **both** ticket templates so every tracker path produces a stub with the section.
- **D12 size:** after the rules-file note, `wc -m templates/SHAMT_RULES.template.md` ≤ 40,000.
- **>10 rows → Phase 3 plan required** (`/f2-plan-update-implementation`), and the plan itself is validated before `/f3-implement-update`.

---

Validated 2026-06-09 — 6 rounds, 1 adversarial sub-agent confirmed (round 1 split the feature/story Scope-boundary asymmetry — features have a `## Scope / Non-Scope` section, stories use the scope one-liner — and added template-placement anchors; round 2 corrected the e1 terminal gate — `/e1` ends at the Intake confirmation gate, not a `/validate-artifact` handoff like `/p3` — and softened the "discarded research" framing; round 3 fixed an impossible placement anchor introduced in round 2 — `## Success Criteria` precedes `## Scope / Non-Scope`; round 4 made the p4 exit-gate citation robust and gave row 12 a precise rules-file anchor; round 5 added graceful-degradation handling for pre-#12 stubs lacking `## Decomposition Context`).
