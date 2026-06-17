# Proposal: rules-file-over-budget

**Created:** 2026-06-16
**Number:** 38
**Status:** Implemented
**Proposed by:**
**Project context:**

---

## Problem

`templates/SHAMT_RULES.template.md` is **42,392 characters (440 lines)**, over its `rules_size_budget_chars` budget of **40,000** by **~2,392 chars** (D12 — rules-file size budget, MEDIUM, always-intricate). The rules file renders into every child project's `CLAUDE.md` and is loaded into the agent's context on **every** interaction, so its size is a recurring per-interaction context cost — the reason the budget exists.

**Proximate cause:** proposal 33 (`agents-trust-cross-session-provenance`) added **Principle 3 — Disk-authoritative cross-session work** (~2 KB) to §Cross-Cutting Design Principles, tipping the file from just-under to over budget. This is the recurring D12 follow-up pattern — archived proposals 08 / 09 / 16 each trimmed the file back under budget after prior growth.

**Structural root cause (the class, not just this instance):** the rules file repeatedly drifts over budget because it accretes **expanded procedural detail** that belongs in `reference/` companions or command/skill bodies, rather than holding only the **normative contracts** (patterns, dimensions, gates, exit criteria, tier names). Several of its largest passages *already* route detail to a `reference/` doc or command body via an explicit pointer, yet also restate that detail inline — so the rules-file copy is partially redundant. The durable fix for the class is to push expanded detail down to its companion and keep the rules file to the contract + a pointer; this proposal applies that discipline as a concrete trim and is sized to give lasting headroom (target ~75% of budget, ~30,000 chars), not merely to scrape back under 40,000.

This proposal **does not edit the rules file via `/trim-rules-file`** (that command only authors the cut list — this draft was developed from its f0 capture); the trim lands here through the normal framework-update flow, where `/validate-artifact` and the next `/f5-audit-framework` D2/D3/D7/D10 sweep enforce that **every normative rule survives**.

**Scope (resolved):** **Tier A + Tier B together** — all 11 cuts, targeting ~33,090 chars (within ~10% of the ~30,000 stretch target). Tier A (8 lower-risk cuts) alone clears the 40,000 budget; Tier B (3 cuts) extracts the framework's three spine protocols into their `reference/` companions to reach the headroom target. Under the resolved Tier-A+B scope **A3 is subsumed by B1** — B1's full 7-Step walkthrough extraction already carries Step 5's enumerated detail to the same destination, so A3 contributes **no independent delta** (it is not double-counted in the running total). (See Resolved Questions.)

---

## Proposed Changes

The change set is one large content **migration**: tighten / extract 11 passages out of the rules file, each into a named destination. **Every cut is an extraction, rephrase, or relocation — never a silent deletion of a normative rule.** The rules file retains every **pattern / dimension / tier / gate name and every count claim**; only expanded *detail* moves. One row per canonical file touched:

| # | Canonical path | Operation | One-line change description |
|---|----------------|-----------|------------------------------|
| 1 | `templates/SHAMT_RULES.template.md` | EDIT | Apply all 11 cuts (Tier A1–A8, Tier B1–B3 in the Cut inventory below): tighten in place or replace an inline restatement with a one-line pointer to the destination doc, preserving every pattern/dimension/tier/gate name + count. Est. **~−9,300 chars** → ~33,090 (from 42,392). Under the resolved Tier-A+B scope A3 is subsumed by B1 (Step-5 detail moves as part of B1's walkthrough extraction), so A3 adds no independent delta. |
| 2 | `reference/rebaseline_protocol.md` | CREATE | New companion receiving the Requirement Re-baseline Protocol trigger list + 10-step contract (A1). **Structure sketch** (headings the CREATE must contain; full prose is `/f3`'s job): a one-line title/intro naming this as the expanded Re-baseline Protocol companion; **## When to re-baseline** — the trigger list moved from rules §Requirement Re-baseline Protocol lines 381–387; **## Re-baseline contract** — the 10-step contract moved from lines 389–400. The rules file keeps the §header, the one-sentence "use when" rule, the "unversioned names remain baseline v1; do not rename/overwrite" rule, and a pointer to this doc. |
| 3 | `reference/spec_protocol_reference.md` | EDIT | Receive the Spec-protocol detail the rules file currently restates: Step-5 enumerated prevention/lineage/split detail (A3) and the full 7-step walkthrough prose (B1). The rules file keeps Pattern 3's purpose, the Gate 2a/2b contract, the Standard-vs-Quick artifact table, and the five validation pair-checks. |
| 4 | `reference/implementation_plan_reference.md` | EDIT | Receive the three "stay stated here" hard checks (transitive call graph, byte-for-byte copy, CODING_STANDARDS mapping) (A4) and the per-step + operation-contract walkthrough of the 5-Step Process (B3). The rules file keeps the required-plan-contract bullets, the operation-contract names (CREATE/EDIT/DELETE/MOVE), the hard-check **names**, and the builder contract/report strings. |
| 5 | `reference/validation_exit_criteria.md` | EDIT | Receive the 8-Step Validation Process per-step mechanics (B2), alongside the exit-criteria examples it already holds. The rules file keeps Pattern 1's exit criteria, the risk-trigger list, the Step-2 dimension lists (Specs/Plans/Reviews/General), and the footer format. |

**File-operation count = 5 (≤ 10) → no Phase 3 plan is *required* by the >10-file rule.** However, this is a substantial content migration (≈10 KB moving across 5 files, including the three spine protocols), so `/f2-plan-update-implementation` is **recommended-optional**: a mechanical plan would make the per-passage move/keep boundaries exact for `/f3`. Left to operator discretion at Phase 3 (not forced).

### Cut inventory (preserved from the `/trim-rules-file` capture — the per-passage detail `/f3` executes)

**Reading the line ranges — locator, not deletion span (binding for every extraction row).** A cited line range on an extraction/relocate row is the **section locator**: the passage the cut operates *within*, used to find the content — it is **never** an instruction to delete that whole range wholesale. Within the located section every extraction cut splits its content two ways: **MOVE** = the expanded per-step walkthrough / enumerated detail that relocates to the named destination doc, and **KEEP-INLINE** = the normative contract bits (pattern/dimension/tier/gate names, exit criteria, contracts, tables, hard-check names) that **stay in the rules file**. A `/f3` executor must move only the MOVE content and must preserve every KEEP-INLINE item **even when it falls inside the cited locator range** (several do — e.g. dimension lists, artifact tables, and gate contracts sit mid-section). Where a row names a keep-item, that item is retained verbatim in meaning regardless of whether it sits inside or outside the locator.

**Tier A — clears the budget (lower-risk: dedup/extract content that already has a pointer):**

| ID | Rules-file location | Category | Move → destination | Est. Δ |
|----|---------------------|----------|--------------------|--------|
| A1 | §Requirement Re-baseline Protocol (locator: lines 377–402) | Extraction | **MOVE** the trigger list (lines 381–387) + the 10-step Re-baseline contract (lines 389–400) → **new** `reference/rebaseline_protocol.md`. **KEEP-INLINE** — *inside* the locator — the §header (line 377), the one-sentence "use when" rule (line 379), and the "unversioned names remain baseline v1; do not rename/overwrite" rule (line 402), plus add the pointer. | −1000 |
| A2 | Pattern 4 → "Formal steps" (line 292) | Relocate (dedup) | full steps already in the `review-executor` persona + `/e6` + `reference/review_categories.md`; reduce to a pointer naming those homes | −850 |
| A3 | Pattern 3 → Step 5 (locator: line 271) | Relocate (dedup) | **MOVE** the enumerated prevention/lineage/split detail (the per-surface prevention requirements, the schema/lineage column-delta listing, and the path-specific spec/context split — already mirrored in `reference/spec_protocol_reference.md`). **KEEP-INLINE** Step 5's normative core: answer-Open-Questions-from-code first, the per-surface **prevention requirement** rule, the schema/migration end-to-end read+write data-lineage trace requirement, and the Gate-2a/2b Blocker-listing rule, plus the pointer. **Subsumed by B1 under the resolved Tier-A+B scope** — B1 extracts the whole 7-Step walkthrough (Step 5 included) to the same `reference/spec_protocol_reference.md`, so Step 5's detail moves as part of B1's extraction and A3 carries **no independent delta**. (A3 is retained as a named cut only to document Step 5's move/keep boundary; its budget impact is counted once, under B1.) | subsumed by B1 (no independent Δ) |
| A4 | Pattern 5 → "Hard planning checks" (locator: lines 326–330) | Relocate/tighten | **MOVE** the three "stay stated here" expanded checks (transitive call graph, byte-for-byte copy, CODING_STANDARDS mapping — lines 328–330) → `reference/implementation_plan_reference.md`, reducing each to its **name**. **KEEP-INLINE** — *inside* the locator — the six already-routed hard-check **names** + the "maps to a step / verification / explicit N/A" rule (line 326), and add the three moved checks' names there too, plus the pointer. | −650 |
| A5 | §Standing Tech Stories epic → "Entry + archive" (line 178) | Relocate | mechanics already in `/ps0-draft` + `/e8-finalize-story`; keep standing-fixtures rule + one-line pointer | −550 |
| A6 | §What is Shamt? decomposition paragraph (line 19) | Rephrase/relocate | compress the long parenthetical to one sentence + the existing command-body pointer | −450 |
| A7 | §PO-tree resolution write-side paragraph (line 168) | Tighten (in place) | **preserve `{epic-folder}`/`{feature-folder}` placeholders + the no-collapse rule + work-root rule verbatim in meaning** (recently hardened by #30); compress surrounding prose | −400 |
| A8 | Principle 3 (lines 62–69) | Rephrase (in place) | preserve all 4 numbered rules; compress parenthetical expansions/examples (newly landed by #33 — keep every normative clause) | −400 |

**Tier B — reaches the ~30,000 headroom target (higher-risk: extract the three spine protocols, keep the normative contract + pointer):**

| ID | Rules-file location | Category | Move → destination | Est. Δ |
|----|---------------------|----------|--------------------|--------|
| B1 | Pattern 3 → "The 7-Step Spec Protocol" (locator: lines 254–280) | Extraction | **MOVE** the per-step walkthrough prose (the Step 1–7 bodies) → `reference/spec_protocol_reference.md`. **KEEP-INLINE** the Pattern-3 purpose line (line 252, outside the locator), and — *inside* the locator — the Gate 2a/2b contract (Steps 4 & 7), the Standard-vs-Quick artifact table (Step 3), and the five validation pair-checks (Step 6). | −2200 |
| B2 | Pattern 1 → "The 8-Step Validation Process" (locator: lines 208–237) | Extraction | **MOVE** the per-step mechanics (the Step 1–8 bodies) → `reference/validation_exit_criteria.md`. **KEEP-INLINE** the exit-criteria block + risk-trigger list (lines 201–206, outside the locator), and — *inside* the locator — the Step-2 dimension lists (Specs/Plans/Reviews/General, lines 214–220) and the footer format block (lines 234–237); these stay even though they fall within the section, only the per-step mechanics move. | −1500 |
| B3 | Pattern 5 → "The 5-Step Process" (locator: lines 304–340) | Extraction | **MOVE** the expanded per-step + operation-contract walkthrough → `reference/implementation_plan_reference.md`. **KEEP-INLINE** — *inside* the locator — the required-plan-contract bullets (lines 310–317), the operation-contract names CREATE/EDIT/DELETE/MOVE (lines 319–324), the hard-check **names** (line 326), and the builder contract/report strings (line 338). | −1300 |

**Running total:** 42,392 − ~4,300 (Tier A: A1 −1000, A2 −850, A4 −650, A5 −550, A6 −450, A7 −400, A8 −400; **A3 subsumed by B1 — no independent delta**) − ~5,000 (Tier B: B1 −2200, B2 −1500, B3 −1300) ≈ **~33,090 chars** (≈10% above the ~30,000 target; the residual closes with modest additional A8-class prose tightening during `/f3` if wanted). All estimates are approximate; the binding constraint is **under 40,000** with healthy margin, which both tiers clear comfortably.

---

## Risks

- **Rule loss (the load-bearing risk — HIGH).** Extracting prose can drop a normative rule if a cut removes content without a faithful destination. **Mitigation:** the mandatory guardrail — every cut names a destination; the rules file keeps every pattern/dimension/tier/gate **named** (only expanded detail moves); `/validate-artifact` and the post-regen `/f5-audit-framework` D3 (bidirectional coverage) / D7 (terminology) / D10 (count-claim) sweep catch a dropped pattern/term/count. Tier B (spine-protocol extraction) is the highest-risk subset and must be validated hardest — confirm the rules file retains each protocol's exit criteria, gate names, and hard-check names.
- **Cross-doc anchor breakage (D4).** Other docs/commands link rules-file anchors (e.g. `#requirement-re-baseline-protocol`, `#principle-1-…`, `#pattern-1-validation-loops`). **Mitigation:** keep every section/pattern/principle **heading** intact (only the body shrinks); the new `reference/rebaseline_protocol.md` must exist before the rules-file pointer lands, and every new/edited pointer must resolve. `/e2`/`/e3` already point at the rules-file §Re-baseline header, which survives.
- **#30 / #33 regression (A7 / A8).** A7 touches the recently-hardened §PO-tree write-side rule and A8 the just-landed Principle 3. **Mitigation:** A7/A8 are *in-place tightening* only — the canonical placeholders, the no-collapse rule, the work-root rule, and all four Principle-3 rules survive verbatim in meaning; validation diffs these passages hardest.
- **Drift (canonical ↔ generated).** The rules file propagates to child `CLAUDE.md` via `import-shamt`, **not** via `/f4-regen-framework` (which manages `.claude/` from `host/templates/claude/` — untouched here). So `/f4 --check` shows **zero `.claude/` drift** (expected — `templates/` and `reference/` are outside the `.claude/` regen surface); children pick up the trimmed rules on the next `/sync-import-shamt`. Reference docs are not rendered into `.claude/` either.
- **Child-project compatibility.** Purely a docs reorganization; no artifact-shape, schema, or behavioral change. Children re-import the trimmed rules + new/edited reference docs on next sync; no manual reconciliation.
- **Open-questions debt.** Resolved — the single load-bearing decision (scope: Tier A + Tier B) is settled before drafting completes.

---

## Rollback Plan

1. `git revert <commit-sha>` on the landing commit — reverts the rules-file trim, the new reference doc (CREATE reverts to deletion), and the three reference-doc edits atomically (one squash commit).
2. Run `/f4-regen-framework` for form (it will report no `.claude/` drift, since no `.claude/`-surface file changed).
3. Child-side: none required for the revert itself; the next `/sync-import-shamt` re-syncs the reverted rules + reference docs.
4. Communication: standard archive note.

Purely additive/relocational documentation edits — no destructive DELETE/MOVE of canonical content (the f0→numbered rename of *this* proposal is authoring bookkeeping, not part of the change set). Revert is `git revert` + (formal) regen.

---

## Validation Considerations

Dimension hints for the Phase 2 validation loop (`/validate-artifact proposals/38-rules-file-over-budget.md`):

- **Rule-preservation audit (the hardest check).** For each of the 11 cuts, confirm the touched normative content has a **named, faithful destination** and that the rules file still **names** every pattern/dimension/tier/gate it had. Reject any cut that drops a rule without a destination. Tier B is the focus: verify each spine protocol's exit criteria + gate names + hard-check names remain in the rules file.
- **Char-budget arithmetic.** The estimates are approximate; the binding requirement is the trimmed file lands **under 40,000 with healthy margin** (target ~33,090). Treat a cut that does not clearly reduce size, or an estimate that would leave the file ≥40,000, as a finding. Confirm the running total counts **A3 under B1 only** (A3 is subsumed by B1 in the resolved Tier-A+B scope — no double-count): Tier A ≈ −4,300, Tier B ≈ −5,000, total ≈ −9,300.
- **Anchor integrity (D4).** Confirm every rules-file section/pattern/principle heading survives (cross-doc anchors), the new `reference/rebaseline_protocol.md` is created with the moved content, and every rules-file pointer (old + new) resolves to a real doc/section.
- **Destination completeness.** For A1/B1/B2/B3 (the extractions), confirm the destination reference doc actually *receives* the moved content (not just a pointer left behind with the content dropped). For A2/A5 (relocate-to-existing), confirm the persona/command body already carries the content the rules file now points at (so nothing is lost).
- **Affected surfaces:** rules file + 4 reference docs (1 CREATE, 3 EDIT). **No** command/skill/template/persona/script change is *required* (A2/A5 destinations already hold their content). Confirm no command/skill that paraphrases a rules-file passage needs a paired edit (per the #37 pointer rule, SKILL Protocols are pointers — no paraphrase to keep in sync).
- **Propagation:** `/f4-regen-framework` runs for form and reports zero `.claude/` drift; real propagation to children is the next `/sync-import-shamt`. No child needs a manual nudge.
- **Phase 3:** not required (5 file ops ≤ 10); `/f2` is optional given the migration's size — the validator may recommend it but must not treat its absence as a defect.

---

## Open Questions

_None — all resolved (see below)._

---

## Resolved Questions

- ~~Q: Scope — Tier A only (clears the 40,000 budget at lowest risk; Tier B as a follow-up), Tier A + Tier B together (reaches the ~30,000 stretch target but extracts the three spine protocols), or Tier A + raise the budget?~~ → A: **Tier A + Tier B together** (user-decided). Land all 11 cuts in one proposal, targeting ~33,090 chars (A3 subsumed by B1 under this scope — counted once). Tier B's spine-protocol extraction is accepted as the higher-risk subset and is flagged for the hardest validation; the budget itself is not raised (the budget is the contract — trim to fit, with headroom).

---
Validated 2026-06-16 — 3 rounds (round 2: adversarial checker flagged a CRITICAL clarity defect — extraction rows read their cited line range as a deletion span; fixed by re-wording every extraction cut to mark the range as a section *locator* and split MOVE vs KEEP-INLINE explicitly, with a binding preamble note. Round 3: adversarial checker flagged two more — HIGH A3/B1 overlap double-count (A3 −650 and B1 −2200 both move Step-5 detail to the same `reference/spec_protocol_reference.md`, so A3's delta was counted twice under the resolved Tier-A+B scope) and MEDIUM missing structure sketch for the `reference/rebaseline_protocol.md` CREATE. Fixed: A3 marked **subsumed by B1 — no independent delta**, running total recomputed to Tier A ≈ −4,300, Tier B ≈ −5,000, total ≈ −9,300 → ~33,090 chars (under the 40,000 budget, ~6,910 margin; figures made consistent across Problem scope, Proposed Changes row 1, Tier A table, Running total, Validation Considerations, Resolved Questions), and a `## When to re-baseline` / `## Re-baseline contract` structure sketch added to the CREATE row. Primary clean after fix; adversarial validation-checker confirmed: zero issues after re-review.)
