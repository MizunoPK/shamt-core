# Implementation Plan — Phase 1 — decompose-catalog-start-validate-deepdive (#12)

**Created:** 2026-06-09
**Index:** `proposals/12-decompose-catalog-start-validate-deepdive_PLAN.md`
**Proposal:** `proposals/12-decompose-catalog-start-validate-deepdive.md` (Validated 2026-06-09)
**Cuts in this phase:** proposal rows 1, 2, 3, 12 — add the `## Decomposition Context` section to the three templates + append the breadth/depth invariant to the rules file.
**Files edited:** `templates/feature.template.md`, `templates/ticket.github.template.md`, `templates/ticket.ado.template.md`, `templates/SHAMT_RULES.template.md`.

> **Deploy order:** Phase 1 runs first — the section must exist in the templates before Phases 2–3 reference it. Re-confirm anchors against the live files; cited line numbers are pre-edit/approximate.

---

## The shared section block (used verbatim in Steps 1–3)

All three templates receive the **identical** block below (call it **`BLOCK`**). It is breadth-only and generic across "sibling children" (features under an epic, or stories under a feature):

````
## Decomposition Context

<!-- Cataloged at decomposition (/p2-decompose-epic for features, /p4-decompose-feature for stories) — bounded breadth context discovered by researching the whole sibling set. NOT a depth dump (design/acceptance/implementation detail belongs in the depth sections, filled at start-*). /p3-start-feature and /e1-start-story consume this as a research seed. Leave the placeholder bullets if nothing was cataloged. -->

- **Dependencies on siblings:** [which sibling features/stories this one depends on or blocks — "none" if independent]
- **Shared context:** [context spanning the set this child needs — shared modules, data, infra, conventions]
- **Boundary rationale:** [why this child is scoped as drawn rather than merged into a sibling]
````

---

## Step 0: Create the proposal branch
**Operation:** BRANCH
- Run `git checkout -b proposal/12-decompose-catalog-start-validate-deepdive` from `main`. If it exists, stop and report.
- Capture baseline rules size: `wc -m templates/SHAMT_RULES.template.md` (expect **37245**); record it.

**Verification:** `git branch --show-current` → `proposal/12-decompose-catalog-start-validate-deepdive`.

---

## Step 1: feature.template.md — insert `## Decomposition Context` after the Scope/Non-Scope block (row 1)
**Operation:** EDIT
**File:** `templates/feature.template.md`
**Details:** insert `BLOCK` (above) immediately before `## Target Stories` (i.e., after the `### Out of Scope` block + its trailing `---`).
- **Locate:** `## Target Stories`
- **Replace:** (BLOCK, then a separator, then the original heading)

````
## Decomposition Context

<!-- Cataloged at decomposition (/p2-decompose-epic for features, /p4-decompose-feature for stories) — bounded breadth context discovered by researching the whole sibling set. NOT a depth dump (design/acceptance/implementation detail belongs in the depth sections, filled at start-*). /p3-start-feature and /e1-start-story consume this as a research seed. Leave the placeholder bullets if nothing was cataloged. -->

- **Dependencies on siblings:** [which sibling features/stories this one depends on or blocks — "none" if independent]
- **Shared context:** [context spanning the set this child needs — shared modules, data, infra, conventions]
- **Boundary rationale:** [why this child is scoped as drawn rather than merged into a sibling]

---

## Target Stories
````

**Verification:** `grep -Fc "## Decomposition Context" templates/feature.template.md` → `1`; `grep -Fc "## Target Stories" templates/feature.template.md` → `1` (still present, now after the new section); `grep -Fc "Boundary rationale:" templates/feature.template.md` → `1`. Confirm `## Decomposition Context` appears **after** `## Scope / Non-Scope` and **before** `## Target Stories` (`grep -n` line order).

---

## Step 2: ticket.github.template.md — insert `## Decomposition Context` before `## Summary` (row 2)
**Operation:** EDIT
**File:** `templates/ticket.github.template.md`
**Details:** insert `BLOCK` immediately before `## Summary` (after the `## Markdown Normalization Rules` section).
- **Locate:** `## Summary`
- **Replace:** (BLOCK, then a blank line, then the original heading)

````
## Decomposition Context

<!-- Cataloged at decomposition (/p2-decompose-epic for features, /p4-decompose-feature for stories) — bounded breadth context discovered by researching the whole sibling set. NOT a depth dump (design/acceptance/implementation detail belongs in the depth sections, filled at start-*). /p3-start-feature and /e1-start-story consume this as a research seed. Leave the placeholder bullets if nothing was cataloged. -->

- **Dependencies on siblings:** [which sibling features/stories this one depends on or blocks — "none" if independent]
- **Shared context:** [context spanning the set this child needs — shared modules, data, infra, conventions]
- **Boundary rationale:** [why this child is scoped as drawn rather than merged into a sibling]

## Summary
````

**Verification:** `grep -Fc "## Decomposition Context" templates/ticket.github.template.md` → `1`; `grep -Fc "## Summary" templates/ticket.github.template.md` → `1`; confirm `## Decomposition Context` precedes `## Summary` (`grep -n` line order).

---

## Step 3: ticket.ado.template.md — insert `## Decomposition Context` before `## Summary` (row 3)
**Operation:** EDIT
**File:** `templates/ticket.ado.template.md`
**Details:** insert `BLOCK` immediately before `## Summary` (after the `## HTML Normalization Rules` section).
- **Locate:** `## Summary`
- **Replace:** (BLOCK, then a blank line, then the original heading)

````
## Decomposition Context

<!-- Cataloged at decomposition (/p2-decompose-epic for features, /p4-decompose-feature for stories) — bounded breadth context discovered by researching the whole sibling set. NOT a depth dump (design/acceptance/implementation detail belongs in the depth sections, filled at start-*). /p3-start-feature and /e1-start-story consume this as a research seed. Leave the placeholder bullets if nothing was cataloged. -->

- **Dependencies on siblings:** [which sibling features/stories this one depends on or blocks — "none" if independent]
- **Shared context:** [context spanning the set this child needs — shared modules, data, infra, conventions]
- **Boundary rationale:** [why this child is scoped as drawn rather than merged into a sibling]

## Summary
````

**Verification:** `grep -Fc "## Decomposition Context" templates/ticket.ado.template.md` → `1`; `grep -Fc "## Summary" templates/ticket.ado.template.md` → `1`; confirm order.

---

## Step 4: SHAMT_RULES.template.md — append the breadth/depth invariant sentence (row 12)
**Operation:** EDIT
**File:** `templates/SHAMT_RULES.template.md`
**Details:** append one sentence to the PO-flow description paragraph in `## What is Shamt?`.
- **Locate:** `The Engineer flow is the load-bearing surface. The PO flow exists for initiatives large enough to warrant top-down decomposition; standalone stories with no parent epic/feature are first-class and run the Engineer flow directly.`
- **Replace:** `The Engineer flow is the load-bearing surface. The PO flow exists for initiatives large enough to warrant top-down decomposition; standalone stories with no parent epic/feature are first-class and run the Engineer flow directly. Within the PO flow, **decomposition catalogs breadth-context** — a bounded \`## Decomposition Context\` section plus each child's breadth boundary (\`## Scope / Non-Scope\` for a feature, the scope one-liner for a story) — and **start-\* deepens depth** from that seed before its existing terminal gate (\`/p3-start-feature\` → \`/validate-artifact\` handoff; \`/e1-start-story\` → Intake confirmation).`

**Verification:** `grep -Fc "decomposition catalogs breadth-context" templates/SHAMT_RULES.template.md` → `1`.

---

## Step 5: D12 budget re-measure
**Operation:** VERIFY (no edit)
- Run `wc -m templates/SHAMT_RULES.template.md`. Expect ~**37,600** (baseline 37,245 + one sentence).
- **PASS condition:** ≤ **40,000**. If over, halt and report.

**Verification:** `s=$(wc -m < templates/SHAMT_RULES.template.md); [ "$s" -le 40000 ] && echo "PASS $s"`.

---

## Phase 1 exit
- The `## Decomposition Context` section exists in all three templates (feature: after Scope/Non-Scope, before Target Stories; both tickets: before Summary). The rules file states the breadth/depth invariant. `wc -m` ≤ 40,000.
- **No commit.** Next: Phase 2 (decompose side populates the section).

---

## Notes
- **No rule removed.** Steps 1–3 ADD a section; Step 4 APPENDS one sentence — no existing template section or rule is dropped. The three template inserts are byte-identical (`BLOCK`).
- Only `templates/` files edited; **not** regenerated (render into a child at install/`sync-import`). No `.claude/`, no commit.

---
Validated 2026-06-09 — 1 round, 1 adversarial sub-agent confirmed (a sub-agent's "Index-path mismatch" finding was a false positive — a phase file's `**Index:**` field correctly points to the `_PLAN.md` index, not to itself, per the established convention)
