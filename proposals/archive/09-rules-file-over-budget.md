# Proposal: rules-file-over-budget

**Created:** 2026-06-07
**Status:** Implemented
**Number:** 09
**Proposed by:**
**Project context:**

---

## Problem

`templates/SHAMT_RULES.template.md` — the canonical rules file rendered into every child project's `CLAUDE.md` and loaded into the AI's context on **every** interaction — is **40,281 characters**, over the **40,000** budget (`rules_size_budget_chars`). The `/f5-audit-framework` **D12** check fired on it (captured as this proposal's f0 origin) and `/trim-rules-file` analyzed concrete reductions. Target: **~30,000 chars** (~75% of budget); **~10,300 chars to cut**.

The opportunity is almost entirely **redundancy**: the rules file restates, in full, content that already lives authoritatively in the per-phase command bodies (`e1`–`e7`) and the `reference/` expansion docs it explicitly cites. A reader following the rules file is sent to those same sources anyway. Removing the duplicated prose and leaving a pointer shrinks the per-interaction context cost **without removing a single normative rule** — each rule continues to live in its authoritative home.

**Verified during drafting + validation (de-dup vs. relocate):** all six cuts keep every rule in the canonical surface, and the change touches **only `templates/SHAMT_RULES.template.md`** (a single file). Four cuts are **de-dup against an existing destination** (`e1`–`e7` commands for the phase narratives; `reference/model_selection.md` for the per-phase tiers; `e2-define-spec` for the spec section-placement; `reference/implementation_plan_reference.md` for the hard planning checks — those files already carry the content and are *not edited*). One is a **de-dup via cross-ref** (C5: the Pattern-1 Step-2 per-dimension hard-checks restate checks already owned canonically elsewhere — Pattern 3 Step 5 and Pattern 5's contract *in this same file*, and `reference/review_categories.md` for the reviews checks — replaced with cross-refs to each owning home, so no rule is lost). One is a **de-dup of an enumeration** (C6: the Pattern 4 16-category name list → pointer to `reference/review_categories.md`, which enumerates them; the broader prose-tightening originally scoped to C6 is deferred as not mechanizable). Removing a duplicate (or replacing a restatement with a cross-ref) cannot lose a rule, provided validation confirms the destination's coverage before each removal.

*(An earlier draft of C5 relocated the Pattern-1 hard-checks into `reference/validation_exit_criteria.md`; validation rejected that — `validation_exit_criteria.md` is framed as "extended mechanics / examples", the wrong home for normative MUSTs. The intra-file cross-ref keeps the rules canonical in their owning Pattern.)*

---

## Proposed Changes

**Guardrail (load-bearing):** every row is a de-dup / cross-ref / rephrase — **never a silent deletion of a normative rule.** For each de-dup row (C1–C4), validation must confirm the destination fully covers the removed passage *before* the removal lands. For the intra-file de-dup row (C5), each removed restatement is replaced by a cross-ref that must resolve to a home which genuinely states the rule; an unconfirmed check stays inline. Where content is removed, a one-line pointer or cross-ref stays so a reader still reaches the rule. (Rows 5 and 6 are independent: C5 is the cross-ref de-dup, C6 is the Pattern-4 enumeration de-dup — they are not a coupled pair.)

| # | Canonical path | Operation | One-line change description | Est. Δ |
|---|----------------|-----------|------------------------------|--------|
| 1 | `templates/SHAMT_RULES.template.md` | EDIT | **C1** — replace the entire `# Part 3: Engineer Flow — Phase Narratives` section (the 7 per-phase paragraphs) with a ~350-ch pointer to the `e1`–`e7` command bodies (purpose/steps), the Quick/Standard path-map tables already in this file (gates), and `reference/model_selection.md` (models). **De-dup** — every phase's detail is already authoritative in its command body. | −3,400 |
| 2 | `templates/SHAMT_RULES.template.md` | EDIT | **C2** — replace the `## Recommended models per phase (Engineer flow)` table with a ~120-ch pointer to `reference/model_selection.md`, which already carries the per-phase tiers. Keep the short `## Default tier mapping` + `## Operational rules` in place (resolved: they stay). **De-dup.** | −680 |
| 3 | `templates/SHAMT_RULES.template.md` | EDIT | **C3** — in `## Pattern 3: Spec Protocol`, tighten the verbose Step 2 / Step 5 prose and drop the exact section-placement mechanics ("Add `Review Prevention Gates` after Requirements…", "Add `Database Schema Changes` after `Interfaces and Boundaries`…") that `e2-define-spec` already carries. **Keep all normative checks** (end-to-end schema data-lineage trace; review-prevention surface inventory; Gate 2a/2b contracts). **Mostly de-dup** (section-placement lives in e2). | −2,500 |
| 4 | `templates/SHAMT_RULES.template.md` | EDIT | **C4** — in `## Pattern 5: Implementation Planning`, condense the detailed **Hard planning checks** enumeration to a **normative summary that keeps every MUST** (each check named in one clause) + the existing pointer to `reference/implementation_plan_reference.md`, which carries the expanded per-check detail (writer-routing trace, service-manifest coverage, tenant-A→B bypass, removed-checks analysis, transitive call-graph, byte-for-byte copy rule, migration RLS). The rule set stays in the rules file as a summary; only the *expanded prose* (already in the reference) is trimmed. **De-dup of expansion, not of rules.** | −1,800 |
| 5 | `templates/SHAMT_RULES.template.md` | EDIT | **C5** — *de-dup via cross-ref* (revised; see Resolved Q3). In `## Pattern 1` Step 2, the per-dimension "Hard checks: …" sentences **restate** checks already owned canonically elsewhere: Specs' end-to-end data-lineage check duplicates **Pattern 3 Step 5** (line 237, same file); Plans' "no optional/if/consider branches + exact locate/replace + concrete paths" duplicates **Pattern 5's plan contract** (286–298, same file); Reviews' "removed/weakened checks + tenant-A→B bypass" is owned by **`reference/review_categories.md`** (line 29 — "deleted or weakened security checks require boundary analysis and bypass tracing"), which Pattern 4 already points to (line 268) — **not** Pattern 4's own steps, which do not state these checks. Replace each inline restatement with a one-line cross-ref to its owning home (Specs→Pattern 3 Step 5; Plans→Pattern 5 contract; Reviews→`reference/review_categories.md` via Pattern 4), keeping the 8-spec / 8-plan / 6-review dimension **names** + the exit contract. **Per the mitigation, any check whose owner cannot be confirmed stays inline.** No rule is lost; every cross-ref resolves to where the rule canonically lives. | −1,000 |
| 6 | `templates/SHAMT_RULES.template.md` | EDIT | **C6** — de-dup the Pattern 4 16-category enumeration → pointer: replace the inline list of all 16 category names with a pointer to `reference/review_categories.md` (which enumerates them with the mechanical checks). This is the one **mechanically-safe** C6 cut — the names live in the reference, so no rule is dropped. The broader `## Principle 2` / path-selection prose-tightening originally scoped here is **deferred**: free-form rephrase is not mechanizable for the builder without risking a dropped path-trigger, and the file already lands under the 40,000 budget. | −200 |

Row count: **6 ≤ 10**, and **every row edits the single file `templates/SHAMT_RULES.template.md`** (the change touches no other canonical file). Phase 3 (`/f2`) is **not required**, but every row demands careful rule-preservation verification; a plan is **recommended** so each cut's destination-coverage check is pinned mechanically.

**Running total: −9,580 → 40,281 → ~30,700 chars** — **under the 40,000 budget (clears D12)**, just above the ~30,000 target after C6 was scoped down to the mechanically-safe de-dup. The hard floor is ≤ 40,000; the implementation re-measures `wc -m` and the exit **reports the achieved figure**. A further prose-tightening pass (a separate small proposal) could close the remaining ~700-char gap to 30,000; it is **not required** for this proposal's exit.

**Single-file change.** Rows 1–4 are **de-dup** whose destinations (`e1`–`e7`, `model_selection.md`, `e2`, `implementation_plan_reference.md`) **already contain the content** — those files are *not edited*; validation confirms full coverage before each removal. Rows 5–6 are intra-file de-dup / rephrase. No paired cross-file edit; no `host/templates/claude/` or `reference/` edit.

---

## Risks

- **Rule loss on a de-dup removal (the load-bearing one).** If a destination does *not* fully cover a passage removed from the rules file (rows 1–4), a normative rule could silently vanish. Mitigation: validation does a per-cut coverage diff — for each removed passage, point to the exact destination text that carries the rule; a passage with no destination match is **kept**, not removed. The D2 (cross-doc consistency) + D3 (bidirectional coverage) audit re-check after implementation is the backstop.
- **C5 cross-ref accuracy.** Each Pattern-1 Step-2 hard-check replaced with a cross-ref must point to a home that genuinely owns an equivalent check (Specs data-lineage → Pattern 3 Step 5; Plans branches/locate/paths → Pattern 5 contract; Reviews removed-checks/tenant-bypass → `reference/review_categories.md`, *not* Pattern 4's own steps). Mitigation: validation diffs each removed restatement against the cited owning home; a check with no equivalent owner is **kept inline**, not cross-ref'd.
- **Dangling pointer / cross-ref.** A pointer or cross-ref left behind must resolve to where the content actually lives. Mitigation: D4 reference-validity + a re-read confirming each cross-ref'd Pattern still states the rule.
- **Over/under-shoot of the budget.** Estimates are approximate; the real `wc -m` may land above 30k. Mitigation: the implementation re-measures and the exit confirms ≤ 30,000 (adding a small additional C6 tighten if needed); the hard requirement is only ≤ 40,000 (budget), with 30,000 as the target.
- **Regen scope.** All 6 rows edit only `templates/SHAMT_RULES.template.md` — which is **not regenerated** by `regenerate-framework.sh` (it renders into a child's `CLAUDE.md` at install / `sync-import`, not into `.claude/`). The de-dup destinations (`e1`–`e7`, `model_selection.md`, `implementation_plan_reference.md`, `review_categories.md`) are **not edited**. **No `host/templates/claude/` or `reference/` edit** in this proposal, so `/f4-regen-framework` is a no-op here — but run it anyway to confirm `no drift`.
- **Readability regression.** Aggressively tightened prose could become terse. Mitigation: C3/C6 are rephrase-for-concision, not information removal; the validator checks clarity (general-artifact dimension).

---

## Rollback Plan

`git revert <commit-sha>` restores the full rules file (the single file this proposal edits). The rules file is not regenerated, so no `.claude/` propagation is involved; children pick up the reverted rules on the next `/sync-import-shamt`. No data loss. Because every cut is a de-dup / cross-ref / rephrase, a revert simply re-expands content that still exists in its destination — harmless.

---

## Validation Considerations

- **Per-cut coverage proof (highest-risk).** For each of rows 1–4, the validator must produce the destination evidence: the exact `e1`–`e7` / `model_selection.md` / `e2` / `implementation_plan_reference.md` text that carries each removed rule. Any removed passage lacking a destination match is a HIGH finding → keep it in the rules file (or make it a true paired relocation like C5).
- **C5 cross-ref coverage.** For each Pattern-1 Step-2 hard-check replaced by a cross-ref, confirm the cited owning home — Pattern 3 Step 5 (specs), Pattern 5 contract (plans), or `reference/review_categories.md` (reviews; *not* Pattern 4's steps) — still states that exact rule. Any check without an owner stays inline.
- **No rule deleted (whole-file invariant).** Diff the *set of normative rules* before/after: every "must / required / hard check / Gate" statement in the original rules file must still be reachable (still in the rules file — in its owning Pattern — or via a pointer to an existing reference doc that demonstrably carries it). Enumerate them; none may disappear.
- **Pointers resolve (D4).** Every pointer left behind names a real file/section.
- **Size target.** Final `wc -m templates/SHAMT_RULES.template.md` ≤ 30,000 (or report the achieved figure; hard floor is ≤ 40,000 to clear D12). The proposal's exit and the post-implementation `/f5-audit-framework` D12 re-run confirm it.
- **Post-implementation audit.** `/f5-audit-framework` after `/f3` must show D2 (cross-doc consistency), D3 (bidirectional coverage), D7 (terminology), and D12 (now under budget) all clean — the relocated rules remain discoverable, non-contradictory, and the file is back in budget.
- **Affected surfaces.** **`templates/SHAMT_RULES.template.md` only** — all 6 rows edit the single rules file; no other canonical file is touched (the de-dup destinations already carry the content and are not edited). No `host/templates/claude/` edits → no regen drift. **>10-row note N/A** (6 rows); `/f2` recommended for the per-cut coverage discipline, not required.

---

## Open Questions

(none remaining)

---

## Resolved Questions

<!-- Drafting-only log -->

- ~~Q (load-bearing): full 6-cut scope (hit ~30k target, incl. the riskier Pattern 3 tighten C3) vs a conservative 5-cut subset (~32.4k, under the 40k budget, defer C3)?~~ → A: **All 6 cuts → ~29.9k** (user, 2026-06-07). Hit the 30k target; C3's rule-preservation gets extra validation scrutiny.
- ~~Q: does the `## Default tier mapping` (Cheap/Balanced/Reasoning) also move to `reference/model_selection.md` (C2)?~~ → A (resolved by f1 default): **No — keep it in the rules file.** It is short (~760 ch) and core (referenced throughout); only the longer *per-phase* table moves. Keeps a frequently-needed lookup inline.
- ~~Q (codebase research, not a user fork): is each cut a de-dup (content already in destination) or a true relocation (must be added)?~~ → A (researched during drafting; **C5 revised during validation**): **C1, C2 = pure de-dup** (content in `e1`–`e7` + `model_selection.md`); **C3, C4 = de-dup of expansion** (section-placement in `e2`; expanded hard-check detail in `implementation_plan_reference.md`, with the normative summary kept in the rules file); **C5 = de-dup via cross-ref** — the Pattern-1 Step-2 hard-checks restate checks owned by Pattern 3 Step 5 + Pattern 5's contract (same file) and `reference/review_categories.md` (reviews), so they become cross-refs (no relocation to an extension doc); **C6 = rephrase in place.** Single-file change (all 6 rows edit only the rules file).
- ~~Q (raised by validation's adversarial sub-agent): C5 originally relocated the Pattern-1 hard-checks into `reference/validation_exit_criteria.md` — is that the right home?~~ → A: **No — reframed to de-dup via cross-ref.** `validation_exit_criteria.md` is framed as "extended mechanics / examples", not the normative home; moving MUSTs there inverted the authority structure and mixed checks from three dimensions ambiguously. The cross-ref approach keeps each rule canonical in its existing owning home — **Pattern 3 Step 5** (specs data-lineage), **Pattern 5 contract** (plans branches/locate/paths), and **`reference/review_categories.md`** (reviews removed-checks/tenant-bypass; Pattern 4's own steps do *not* state these, so the cross-ref targets review_categories.md, where the rule lives) — and drops the cross-file paired edit (the proposal edits only the rules file).

---

---
Validated 2026-06-08 — re-validated after in-place amendment, adversarial sub-agent confirmed. C6 rescoped to the mechanically-safe Pattern-4 enumeration de-dup (−200); running total −9,580 → ~30,700 (under the 40k budget, clears D12; ~700 above the 30k target — prose-rephrase deferred as non-mechanizable). Prior history: 4 rounds (sub-agent caught the validation_exit_criteria relocation, the false Reviews→Pattern 4 mapping, and stale phrasings — all fixed; C5 owners verified: specs→Pattern 3 Step 5, plans→Pattern 5 contract, reviews→review_categories.md).
