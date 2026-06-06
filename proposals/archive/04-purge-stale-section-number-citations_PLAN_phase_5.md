# Implementation Plan — #04 §-citation purge — Phase 5: templates / references / CHEATSHEET

This phase covers proposal rows 25–35 (templates, reference docs, and `CHEATSHEET.md`) of `04-purge-stale-section-number-citations.md`. Resolutions follow the proposal's §-token resolution table, the per-site classification, and the abolish policy: re-point each `§N.N` to its v2 named home, or delete the dangling `§` where a named reference / inline statement already co-exists.

These files are **not** regenerated — they land in child projects on next `/sync-import-shamt`. No `.claude/` paths are touched.

## Files Touched

| Path | Operation | §-tokens |
|------|-----------|----------|
| `templates/architecture.template.md` | EDIT | §1.12 |
| `templates/coding_standards.template.md` | EDIT | §1.12 |
| `templates/epic.template.md` | EDIT | §1.12 |
| `templates/feature.template.md` | EDIT | §1.12, §2.3 |
| `templates/testing_plan.template.md` | EDIT | §1.14 |
| `reference/model_selection.md` | EDIT | §1.15 |
| `reference/trackers/_contract.md` | EDIT | §2.2 (×2) |
| `reference/trackers/ado.md` | EDIT | §2.1, §1.11 (×2) |
| `reference/trackers/github.md` | EDIT | §2.1, §1.11 (×2) |
| `reference/trackers/local.md` | EDIT | §2.1 |
| `CHEATSHEET.md` | EDIT | §1.12 |

## Implementation Steps

### Step 1

- **Operation:** EDIT
- **File:** `templates/architecture.template.md`
- **Details:**
  - §1.12 — architecture-impact / audit-reads-this. A named reference ("the framework-update audit") already co-exists in the sentence, so the dangling parenthetical `§` is deleted.
    - **Locate:** `Header metadata block above is required — the framework-update audit reads it (§1.12).*`
    - **Replace:** `Header metadata block above is required — the framework-update audit reads it.*`
- **Verification:** `grep -cE "§[0-9]+\.[0-9]+" templates/architecture.template.md` → 0

### Step 2

- **Operation:** EDIT
- **File:** `templates/coding_standards.template.md`
- **Details:**
  - §1.12 — Standards check / audit-reads-this. The named reference ("the framework-update audit") co-exists, so the dangling parenthetical `§` is deleted.
    - **Locate:** `Header metadata block above is required — the framework-update audit reads it (§1.12).*`
    - **Replace:** `Header metadata block above is required — the framework-update audit reads it.*`
- **Verification:** `grep -cE "§[0-9]+\.[0-9]+" templates/coding_standards.template.md` → 0

### Step 3

- **Operation:** EDIT
- **File:** `templates/epic.template.md`
- **Details:**
  - §1.12 — architecture-impact consult. Re-point the bare `(per §1.12)` to the named architecture-impact concept.
    - **Locate:** `consulted `.shamt-core/project-specific-files/ARCHITECTURE.md` (per §1.12) and identified an architectural change implied by this epic.`
    - **Replace:** `consulted `.shamt-core/project-specific-files/ARCHITECTURE.md` (architecture-impact) and identified an architectural change implied by this epic.`
- **Verification:** `grep -cE "§[0-9]+\.[0-9]+" templates/epic.template.md` → 0

### Step 4

- **Operation:** EDIT
- **File:** `templates/feature.template.md`
- **Details:**
  - §1.12 — architecture-impact consult. Re-point the bare `(per §1.12)` to the named architecture-impact concept.
    - **Locate:** `consulted `.shamt-core/project-specific-files/ARCHITECTURE.md` (per §1.12) and identified an architectural change implied by this feature.`
    - **Replace:** `consulted `.shamt-core/project-specific-files/ARCHITECTURE.md` (architecture-impact) and identified an architectural change implied by this feature.`
  - §2.3 — decomposition exit gate (named inline). Drop the `§2.3 ` token; the surrounding text already names the decomposition exit.
    - **Locate:** `[one-line scope; must be individually testable per the §2.3 decomposition exit gate]`
    - **Replace:** `[one-line scope; must be individually testable per the decomposition exit gate]`
- **Verification:** `grep -cE "§[0-9]+\.[0-9]+" templates/feature.template.md` → 0

### Step 5

- **Operation:** EDIT
- **File:** `templates/testing_plan.template.md`
- **Details:**
  - §1.14 — Phase-5 execution-blocking facet. The rule ("Phase 5 blocks until every step is `PASS`") is stated inline; drop the dangling parenthetical `§`, re-pointing to the named Phase-5 blocking rule.
    - **Locate:** `Phase 5 blocks until every step is `PASS` (per §1.14 — no exceptions or documented deferrals).`
    - **Replace:** `Phase 5 blocks until every step is `PASS` (the Phase-5 blocking rule — no exceptions or documented deferrals).`
- **Verification:** `grep -cE "§[0-9]+\.[0-9]+" templates/testing_plan.template.md` → 0

### Step 6

- **Operation:** EDIT
- **File:** `reference/model_selection.md`
- **Details:**
  - §1.15 — manual-test-plan model-tier facet. Re-point to "the manual-test-plan rule" (NOT Pattern 1 — this site backs the rule itself, not its validation sub-agent).
    - **Locate:** `| Manual-test-plan drafting (`/e5b-write-manual-testing-plan`) | Balanced | Drafting + validation loop per `§1.15` |`
    - **Replace:** `| Manual-test-plan drafting (`/e5b-write-manual-testing-plan`) | Balanced | Drafting + validation loop per the manual-test-plan rule |`
- **Verification:** `grep -cE "§[0-9]+\.[0-9]+" reference/model_selection.md` → 0

### Step 7

- **Operation:** EDIT
- **File:** `reference/trackers/_contract.md`
- **Details:**
  - §2.2 (occurrence 1, `/p1-start-epic` row) — "PO flow" already named in the cell; delete the dangling `§`.
    - **Locate:** `| `/p1-start-epic {slug}` | Same as above, filtered on `Epic` | PO flow (§2.2) |`
    - **Replace:** `| `/p1-start-epic {slug}` | Same as above, filtered on `Epic` | PO flow |`
  - §2.2 (occurrence 2, `/p3-start-feature` row) — same delete.
    - **Locate:** `| `/p3-start-feature {slug}` | Same as above, filtered on `Feature` | PO flow (§2.2) |`
    - **Replace:** `| `/p3-start-feature {slug}` | Same as above, filtered on `Feature` | PO flow |`
- **Verification:** `grep -cE "§[0-9]+\.[0-9]+" reference/trackers/_contract.md` → 0

### Step 8

- **Operation:** EDIT
- **File:** `reference/trackers/ado.md`
- **Details:**
  - §2.1 — flat folder layout. Re-point the bare `folder layout per §2.1` to the named flat folder layout.
    - **Locate:** `for the PO-flow variants once `/p1-start-epic` and `/p3-start-feature` ship — folder layout per §2.1).`
    - **Replace:** `for the PO-flow variants once `/p1-start-epic` and `/p3-start-feature` ship — flat folder layout).`
  - §1.11 (occurrence 1, `pr_provider` independence) — tracker integration. Re-point to "the tracker contract".
    - **Locate:** ``pr_provider` is read independently of `work_item_tracker` per §1.11, so this fetch may run against ADO even when work items live elsewhere.`
    - **Replace:** ``pr_provider` is read independently of `work_item_tracker` per the tracker contract, so this fetch may run against ADO even when work items live elsewhere.`
  - §1.11 (occurrence 2, no-postback) — the no-postback rule is stated inline ("does not post upstream"); drop the dangling parenthetical `§`.
    - **Locate:** ``/e6-review-changes` produces a local artifact at `code_reviews/` and does not post upstream (§1.11 resolved open question).`
    - **Replace:** ``/e6-review-changes` produces a local artifact at `code_reviews/` and does not post upstream (resolved open question).`
- **Verification:** `grep -cE "§[0-9]+\.[0-9]+" reference/trackers/ado.md` → 0

### Step 9

- **Operation:** EDIT
- **File:** `reference/trackers/github.md`
- **Details:**
  - §2.1 — flat folder layout. Re-point the bare `folder layout per §2.1` to the named flat folder layout.
    - **Locate:** `(`epics/{slug}-*/raw/issue.json`, `features/{slug}-*/raw/issue.json` — folder layout per §2.1) do not apply here,`
    - **Replace:** `(`epics/{slug}-*/raw/issue.json`, `features/{slug}-*/raw/issue.json` — flat folder layout) do not apply here,`
  - §1.11 (occurrence 1, `pr_provider` independence) — tracker integration. Re-point to "the tracker contract".
    - **Locate:** ``pr_provider` is read independently of `work_item_tracker` per §1.11. This fetch may run against GitHub even when work items live in ADO.`
    - **Replace:** ``pr_provider` is read independently of `work_item_tracker` per the tracker contract. This fetch may run against GitHub even when work items live in ADO.`
  - §1.11 (occurrence 2, no-postback) — the no-postback rule is stated inline; drop the dangling parenthetical `§`.
    - **Locate:** ``/e6-review-changes` produces a local artifact at `code_reviews/` and does not post upstream (§1.11 resolved open question).`
    - **Replace:** ``/e6-review-changes` produces a local artifact at `code_reviews/` and does not post upstream (resolved open question).`
- **Verification:** `grep -cE "§[0-9]+\.[0-9]+" reference/trackers/github.md` → 0

### Step 10

- **Operation:** EDIT
- **File:** `reference/trackers/local.md`
- **Details:**
  - §2.1 — flat folder layout. The sentence names the flat layout inline ("flat layout, globally unique slugs"); re-point the bare `follows §2.1:` to the named flat folder layout.
    - **Locate:** `folder layout follows §2.1: `epics/{slug}-*/epic.md`, `features/{slug}-*/feature.md` (flat layout, globally unique slugs;`
    - **Replace:** `folder layout follows the flat folder layout: `epics/{slug}-*/epic.md`, `features/{slug}-*/feature.md` (flat layout, globally unique slugs;`
- **Verification:** `grep -cE "§[0-9]+\.[0-9]+" reference/trackers/local.md` → 0

### Step 11

- **Operation:** EDIT
- **File:** `CHEATSHEET.md`
- **Details:**
  - §1.12 — architecture-impact heading. Drop the `(§1.12 PO-threading)` parenthetical from the heading.
    - **Locate:** `#### Architecture-impact flag (§1.12 PO-threading)`
    - **Replace:** `#### Architecture-impact flag`
- **Verification:** `grep -cE "§[0-9]+\.[0-9]+" CHEATSHEET.md` → 0

## Phase-5 final verification

Run across all 11 files; every count must be `0` and the aggregate grep must return nothing:

```
grep -cE "§[0-9]+\.[0-9]+" \
  templates/architecture.template.md \
  templates/coding_standards.template.md \
  templates/epic.template.md \
  templates/feature.template.md \
  templates/testing_plan.template.md \
  reference/model_selection.md \
  reference/trackers/_contract.md \
  reference/trackers/ado.md \
  reference/trackers/github.md \
  reference/trackers/local.md \
  CHEATSHEET.md

grep -REn "§[0-9]+\.[0-9]+" \
  templates/architecture.template.md \
  templates/coding_standards.template.md \
  templates/epic.template.md \
  templates/feature.template.md \
  templates/testing_plan.template.md \
  reference/model_selection.md \
  reference/trackers/_contract.md \
  reference/trackers/ado.md \
  reference/trackers/github.md \
  reference/trackers/local.md \
  CHEATSHEET.md
```

Expected: each per-file count `0`; the second (aggregate) grep prints nothing (exit 1 = no matches across all 11 files).

---
Validated 2026-06-06 — 1 round, 1 adversarial sub-agent confirmed (batch validation; validation-checker independently verified all locate strings exact + unique against HEAD, replacements clean, and per-file §-coverage → 0)
