# Proposal: rules-over-budget-post-nested-layout

**Created:** 2026-06-12
**Status:** Implemented
**Number:** 16
**Proposed by:** [master-local]
**Project context:** [master-local]

---

## Problem

`templates/SHAMT_RULES.template.md` — the canonical rules file rendered into every
child project's `CLAUDE.md` and loaded into the agent's context on every
interaction — is **over the D12 size budget**. It measures **42,915 chars**
(`wc -m`) against the `rules_size_budget_chars` default of **40,000** — **over by
~2,915 chars**. The `/f5-audit-framework` D12 sweep (post-implementation
verification of #14 + #15) flagged this and f0-captured it; `/trim-rules-file`
developed the concrete cut list this proposal carries.

The overflow was introduced by the two PO-layout proposals that just landed:

- **#14 (po-nested-folder-layout)** added the `### §PO-tree resolution` section and
  the `### Standing Tech Stories epic` scaffold (nested-layout spec + resolution
  table + body-text shorthand + active-pointer scheme).
- **#15 (tech-stories-epic)** filled in the Standing Tech Stories normative
  description (fixed reserved names, local-only containers, fast-path, per-feature
  archive).

Together these pushed the file from ~39,332 → 42,915 chars. This was **not** a
blocker for #14/#15 landing (D12 is captured, not auto-fixed); it is the follow-up
trim, the same situation the prior `09-rules-file-over-budget` trim handled.

The fix brings the file back under budget **while preserving every normative
rule** — each cut is an extraction (to a `reference/` doc), a de-duplication
against content already owned elsewhere (a `reference/` doc or a command body, left
as a one-line cross-reference), or a tightening rephrase in place. No normative
rule is silently deleted; every removed passage maps to where its content now
lives. Per the resolved trim-depth question, the scope clears the budget with
comfortable headroom (~37,465, ~2.5k margin) rather than forcing aggressive cuts
toward the ~30,000 target.

---

## Proposed Changes

| File | Op | What |
|---|---|---|
| `templates/SHAMT_RULES.template.md` | EDIT | Apply all 7 cuts in place — extract Spec Protocol detail to the new reference (Cut 1); tighten Pattern 5 hard-checks to a name-list + existing pointer (Cut 2); de-dup §PO-tree / Tech Stories prose to command cross-refs + rephrase the active-pointer paragraph in place (Cut 3); rephrase the "What is Shamt?" breadth/depth sentence (Cut 4); consolidate the branch-baseline rule (Cut 5); de-dup Finalize-phase prose to command cross-refs (Cut 6); collapse Pattern 1 Step 2 hard-checks to Pattern/reference pointers (Cut 7). |
| `reference/spec_protocol_reference.md` | CREATE | New reference holding the *expanded* Spec Protocol Step 2 "required captures" enumeration and Step 5 prevention-requirement + schema-lineage detail extracted from the rules (Cut 1). Mirrors the existing `reference/implementation_plan_reference.md` (Pattern 5's expanded per-check detail) and `reference/pr_review_prevention.md`. |

Two canonical files. Cut 2's destination (`reference/implementation_plan_reference.md`)
and Cuts 3/6's destinations (the `/p6-draft-tech-story`, `/p5-finalize-epic`,
`/e8-finalize-story` command bodies) **already own** the relocated detail
(verified: `implementation_plan_reference.md` carries the expanded checks; `p6`
owns the fast-path/archive prose, `p5-finalize-epic` the whole-subtree archive
move, `e8` the clean-tree guard), so those cuts are de-duplications that only edit
the rules file + leave a one-line cross-reference — no destination edit. The
active-pointer paragraph (Cut 3) is only weakly owned by `/e1-start-story`, so it
stays normative in the rules (rephrased in place, not relocated). Row count ≤ 10 →
no `/f2-plan-update-implementation` phase required.

### Detailed cut list

Sized by `awk` section-length scan. Deltas are **estimates** — exact bytes get
nailed during `/f3-implement-update`.

**Cut 1 — Spec Protocol Steps 2 & 5 → new `reference/spec_protocol_reference.md`** *(extraction)*.
`### The 7-Step Spec Protocol` is the file's largest section (**6,941 chars**);
Step 2's "Required captures" enumeration and Step 5's prevention-requirement +
schema-lineage walls are the densest passages. Move the *expanded* per-capture and
per-prevention-surface detail into the new reference; leave a tightened normative
summary (the capture/prevention *names* + the schema-lineage requirement stated
once) and a one-line pointer. Patterns stay the normative contract; the reference
holds the worked detail. **Destination:** `reference/spec_protocol_reference.md`.
**Est. −2,000.**

**Cut 2 — Pattern 5 "Hard planning checks" → existing `reference/implementation_plan_reference.md`** *(de-duplication)*.
`### The 5-Step Process` (**4,517**) already cites "expanded per-check detail in
`reference/implementation_plan_reference.md`," which already holds it. Tighten the
rules' 10-bullet restatement to a terse name-list + the existing pointer; keep the
contract sentence (each check maps to a step / verification / explicit N/A).
**Destination:** `reference/implementation_plan_reference.md` (already owns it).
**Est. −1,300.**

**Cut 3 — §PO-tree resolution + Standing Tech Stories epic → command cross-refs + rephrase** *(de-duplication + rephrase)*.
`### §PO-tree resolution` (**1,889**) and `### Standing Tech Stories epic`
(**1,562**). The body-text-shorthand paragraph and the four Standing-Tech-Stories
bullets restate mechanics already owned by `/p6-draft-tech-story` /
`/p5-finalize-epic` — replace with terse invariants + one-line cross-references.
The active-pointer paragraph stays normative in the rules (only weakly owned by
`/e1-start-story`), rephrased tighter in place. **Destination:** command bodies
(already own the relocated bullets) + in-place restatement for the pointer scheme.
**Est. −700.**

**Cut 4 — "What is Shamt?" decomposition sentence → rephrase in place** *(rephrase)*.
The breadth/depth sentence is a single ~600-char run; tighten to two short
sentences. No rule lost (the breadth/depth split is also normative in the `/p*`
command bodies). **Destination:** restated in place. **Est. −350.**

**Cut 5 — Story branch baseline rule ↔ Pattern 5 branch-prep → consolidate** *(de-duplication)*.
`# Global Story Invariants` "Story branch baseline rule" and Pattern 5's branch-prep
contract state the same fetch-remote-then-branch rule twice. Keep the full
statement once in Global Story Invariants; replace Pattern 5's restatement with a
one-line cross-reference. **Destination:** Global Story Invariants (canonical) ←
Pattern 5 cross-ref. **Est. −300.**

**Cut 6 — Finalize phase (terminal) prose → command cross-refs** *(de-duplication)*.
`### Finalize phase (terminal)` (**1,365**) restates `/e8-finalize-story` /
`/p5-finalize-epic` behavior (clean-tree guard, whole-subtree archive move) those
command bodies already own. Keep the terminal-phase invariant + gate names; move
behavioral detail to one-line cross-references. **Destination:** `/e8-finalize-story`,
`/p5-finalize-epic` command bodies (already own it). **Est. −400.**

**Cut 7 — Pattern 1 Step 2 "Hard checks" clauses → cross-ref owning Patterns** *(de-duplication)*.
In `### The 8-Step Validation Process` (**3,316**), Step 2's per-artifact "Hard
checks:" clauses restate requirements already normative in Pattern 3 / Pattern 5 /
`reference/review_categories.md`. Replace each with a one-line "per Pattern 3 /
Pattern 5 / `reference/review_categories.md`" pointer (several already start this
way — finish the consolidation). **Destination:** Pattern 3, Pattern 5,
`reference/review_categories.md`. **Est. −400.**

### Running total

| | chars |
|---|---|
| Current (`wc -m`) | 42,915 |
| Budget | 40,000 |
| Cut 1 — Spec Protocol → new reference | −2,000 |
| Cut 2 — Plan hard-checks → existing reference | −1,300 |
| Cut 3 — PO-tree / Tech Stories → cross-refs + rephrase | −700 |
| Cut 4 — "What is Shamt?" rephrase | −350 |
| Cut 5 — branch-baseline de-dup | −300 |
| Cut 6 — Finalize prose → cross-refs | −400 |
| Cut 7 — Pattern 1 hard-checks → cross-ref | −400 |
| **Estimated total reduction** | **−5,450** |
| **Projected size** | **~37,465** |
| **Headroom under budget** | **~2,535** |

The new `reference/spec_protocol_reference.md` absorbs the chars Cut 1 removes from
the rules — net framework size is roughly flat, but the **budgeted** surface (the
rules file, loaded every interaction) drops below 40,000. That is the point of the
D12 budget: shrink what loads on every turn, not the total corpus.

---

## Risks

- **Rule loss during extraction/de-dup (primary risk).** A cut could drop a
  normative requirement instead of relocating it. *Mitigation:* the mandatory
  guardrail — every cut names a destination and is an extraction / de-dup /
  rephrase, never a deletion; Cuts 2/3/6 were verified to target content the
  destination **already** owns; `/validate-artifact` on this proposal and the next
  D2 (cross-doc consistency) / D7 (terminology) audit catch any dropped pattern or
  term.
- **Cross-reference rot.** Cuts 2–7 leave one-line pointers to `reference/` docs
  and command bodies; a wrong path is a D4 (reference-validity) finding.
  *Mitigation:* all cited targets exist today (`implementation_plan_reference.md`,
  `review_categories.md`, `/p6-draft-tech-story`, `/p5-finalize-epic`,
  `/e8-finalize-story`); Cut 1's new `spec_protocol_reference.md` is created in the
  same change.
- **Pattern-as-contract dilution.** Moving Spec Protocol detail to a reference
  could weaken Pattern 3's standing as "the normative contract." *Mitigation:* the
  rules retain the normative summary (capture/prevention names + schema-lineage
  requirement); only worked detail moves — exactly the existing Pattern 5 ↔
  `implementation_plan_reference.md` split.
- **Estimate drift.** Deltas are estimates; the real trim could land above ~37,465.
  *Mitigation:* `/f3` re-measures with `wc -m` after edits; if still over budget,
  the deferred candidates (`### Formal steps`, `# Ticket IDs` prose) are pulled in.

## Rollback Plan

Single-commit, fully reversible. The trim lands as one squash commit
(`shamt-core: land #16 rules-over-budget-post-nested-layout (...)`) via the normal
`/f6-archive-proposal` merge. Rollback = `git revert` that commit, which restores
the pre-trim `templates/SHAMT_RULES.template.md` and removes
`reference/spec_protocol_reference.md`. No data migration, no child-project state,
no generated-file coupling beyond the standard regen (the rules file renders into
child `CLAUDE.md` on the next `import-shamt` — reverting before any child syncs is
clean; a child that already synced re-syncs the reverted version).

## Validation Considerations

- **Rule-preservation audit is the core check.** Validation must confirm each cut's
  removed passage is recoverable at its named destination — for Cuts 2/3/6 by
  grepping the destination (already verified during authoring); for Cut 1 by
  confirming the new reference contains the full extracted enumeration; for Cuts
  4/5/7 by confirming the in-place restatement / consolidated single statement
  still carries the rule.
- **Post-edit size re-measure.** `/f3` runs `wc -m templates/SHAMT_RULES.template.md`
  after the edits; the exit check is **< 40,000**. If the estimate undershoots,
  pull a deferred candidate before archiving.
- **Regen + drift.** `/f4-regen-framework` then `scripts/regenerate-framework.sh
  --check` against a clean child confirms the trimmed rules render with zero drift
  and the new reference propagates.
- **D2/D7/D4 sweep.** A `/f5-audit-framework` pass after implementation confirms no
  pattern/term was dropped (D2/D7) and every new cross-reference resolves (D4).
- This proposal itself goes through `/validate-artifact` (Pattern 1) before
  `/f3-implement-update`.

---

## Resolved Questions

- **Trim depth — clear budget with headroom vs push toward the ~30,000 target?**
  *Resolved 2026-06-12:* **Stop at ~37k.** Ship the 7 cuts as scoped — clears the
  40,000 budget with ~2.5k headroom, all low-risk extractions/de-dups, matching the
  prior `09-rules-file-over-budget` trim's scope. The deferred candidates
  (`### Formal steps`, `# Ticket IDs` prose) stay noted for a future trim if a later
  proposal re-breaches the budget.
- **Cut 1 destination — new `reference/` doc vs relocate into `/e2-define-spec`?**
  *Resolved 2026-06-12:* **New `reference/spec_protocol_reference.md`.** Mirrors the
  established Pattern 5 ↔ `reference/implementation_plan_reference.md` split (Pattern
  states the contract; reference holds expanded detail), keeping the Spec Protocol
  Pattern as the normative contract rather than dispersing detail into one command
  body.

## Open Questions

None — all resolved above.

---
Validated 2026-06-12 — 1 round, 1 adversarial sub-agent confirmed
