# Implementation Plan — Phase 4 — rules-file-over-budget (#09)

**Created:** 2026-06-08
**Index:** `proposals/09-rules-file-over-budget_PLAN.md`
**Proposal:** `proposals/09-rules-file-over-budget.md` (Validated 2026-06-07)
**Cut in this phase:** C6 (de-dup the Pattern 4 16-category enumeration → pointer; the broader Principle 2 / path-bullet prose-rephrase originally scoped to C6 is **deferred** per the amended proposal row 6 — not mechanizable without risking a path-trigger) + the **final budget measurement** (the proposal's exit gate).
**File edited:** `templates/SHAMT_RULES.template.md` only.

> **Deploy order:** runs last — **after Phases 1–3 have executed**. Pattern 4 was not touched by Phases 1–3 (use the text anchor for C6); but Step 2's whole-file check verifies the *cumulative* result of all four phases, so it depends on Phases 1–3 having run (the cross-ref / pointer greps confirm Phase 2's & Phase 3's edits landed).

---

## Step 1: C6 — de-dup the Pattern 4 16-category enumeration to a pointer (proposal row 6)
**Operation:** EDIT
**File:** `templates/SHAMT_RULES.template.md`

**Coverage proof (run FIRST — the 16 category NAMES must live in `review_categories.md`):**
```
grep -ciE "Correctness|Security|Performance|Maintainability|Testing|Edge Cases|Naming|Documentation|Error Handling|Concurrency|Dependencies|Architecture|CSS Scope|State Ownership|Response Field Uniformity|Monitoring" reference/review_categories.md   # → ≥10
```
Must return ≥10 (the categories are enumerated in the reference). If lower, **halt** — keep the inline list.

**Details:**
- **Locate:** `Every review must consider all 16 categories even when no finding is recorded: Correctness, Security, Performance, Maintainability, Testing, Edge Cases, Naming, Documentation, Error Handling, Concurrency, Dependencies, Architecture, CSS Scope, State Ownership, Response Field Uniformity, Monitoring. Use \`reference/review_categories.md\` for mechanical checks and finding format.`
- **Replace:** `Every review must consider all 16 categories even when no finding is recorded; the category list, the mechanical checks, and the finding format all live in \`reference/review_categories.md\`.`

**Verification:**
```
grep -c "16 categories even when no finding is recorded; the category list" templates/SHAMT_RULES.template.md   # → 1
grep -c "Correctness, Security, Performance, Maintainability, Testing, Edge Cases" templates/SHAMT_RULES.template.md   # → 0 (inline 16-name list gone)
```

---

## Step 2: Final budget measurement (the proposal's exit gate)
**Operation:** VERIFY (no edit)
**Details:**
- Run `wc -m templates/SHAMT_RULES.template.md`. Record the final figure.
- **PASS condition (hard floor):** ≤ **40,000** chars — this clears the D12 finding (the mandatory requirement).
- **Target:** ≤ **30,000** chars (~75% of budget). Report the achieved figure against both lines. Expected landing is **~30,700–31,200** — under the 40,000 budget (D12 cleared), at/near the 30,000 target.

**Whole-file rule-preservation check (the load-bearing exit):**
```
# Every cross-ref / pointer left behind resolves, and the dropped duplicates still live in a destination.
# 1. exactly one canonical data-lineage statement remains (Pattern 3 Step 5):
grep -c "trace the end-to-end cross-service read and write data lineage" templates/SHAMT_RULES.template.md   # → 1
# 2. cross-refs present:
grep -c "per Pattern 3 (Spec Protocol)" templates/SHAMT_RULES.template.md      # → 1
grep -c "per Pattern 5 (Implementation Planning)" templates/SHAMT_RULES.template.md   # → 1
grep -c "per \`reference/review_categories.md\`" templates/SHAMT_RULES.template.md     # → 1
# 3. pointers present (C1/C2):
grep -c "live authoritatively in its \*\*command body\*\*" templates/SHAMT_RULES.template.md   # → 1
grep -c "the authoritative table" templates/SHAMT_RULES.template.md            # → 1
# 4. no broken inline list (C6):
grep -c "Response Field Uniformity, Monitoring\. Use" templates/SHAMT_RULES.template.md   # → 0
```
**If any grep above returns a value other than the one marked, halt and report** — a rule was lost, a cross-ref/pointer is missing, or a prior phase did not land; do not proceed to `/f4-regen-framework`. (This whole-file check verifies the cumulative result of Phases 1–4, so it requires all prior phases to have executed.)

**If `wc -m` > 40,000:** halt and report — the budget is not cleared (would mean a cut under-delivered); do not proceed past this plan to `/f4-regen-framework`.
**If 30,000 < `wc -m` ≤ 40,000:** PASS (D12 cleared); report the figure and note the file is under budget, slightly above the 30,000 target. A further optional rephrase pass (a separate small proposal) could close the remaining gap; it is **not** required for this proposal's exit.
**If `wc -m` ≤ 30,000:** PASS, target met.

---

## Phase 4 exit
- C6 applied; final `wc -m` recorded and checked against the 40,000 budget (hard) + 30,000 target.
- Whole-file rule-preservation greps all pass (every cross-ref/pointer resolves; the data-lineage rule survives exactly once).
- **No commit.** Next: `/f4-regen-framework` (no-op — confirm `no drift`), then `/f5-audit-framework` (re-runs D12 to confirm under budget), then `/f6-archive-proposal`.

---

## Notes
- C6 is the one clean Pattern-4 de-dup (the 16 category names live in `review_categories.md`). The broader "rephrase Principle 2 / path bullets" framing from the proposal is intentionally **scoped down to mechanically-safe edits only** here — free-form prose tightening is not mechanizable for the executor and risks dropping a path trigger; the achieved figure is under budget regardless.
- Only `templates/SHAMT_RULES.template.md` is edited. No `.claude/`, no destination edits, no commit.

---
Validated 2026-06-08 — adversarial sub-agent confirmed. C6 is the one mechanically-safe Pattern-4 16-category de-dup (names verified present in review_categories.md); the budget gate (≤40k hard / ≤30k target) + whole-file rule-preservation greps form the exit. Validation fixed the "/f4" ambiguity (→ "/f4-regen-framework"), added an explicit halt clause to the whole-file check, and clarified the deploy-order dependency (Step 2's greps verify the cumulative post-Phase-1–3 state — running them pre-execution is expected to fail, by design). Reconciled with the amended proposal C6 + index (Principle 2 / path-bullet rephrase deferred).
