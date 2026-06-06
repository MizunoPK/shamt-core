# Implementation Plan — #04 §-citation purge — Phase 1: PO flow

Scope: the 7 PO-flow canonical files (commands `p1`–`p4` + the `p2`/`p3`/`p4` skills). Every `§N.N` token is resolved per the proposal's §-token resolution table — re-pointed to its v2 named home or deleted where a named reference / inline statement already co-exists. Edits target **only** these canonical `host/templates/claude/` sources; the generated `.claude/` copies are never touched (they regenerate via `/f4-regen-framework`).

## Files Touched

| # | Operation | File |
|---|-----------|------|
| 1 | EDIT | `host/templates/claude/commands/p1-start-epic.md` |
| 2 | EDIT | `host/templates/claude/commands/p2-decompose-epic.md` |
| 3 | EDIT | `host/templates/claude/commands/p3-start-feature.md` |
| 4 | EDIT | `host/templates/claude/commands/p4-decompose-feature.md` |
| 5 | EDIT | `host/templates/claude/skills/p2-decompose-epic/SKILL.md` |
| 6 | EDIT | `host/templates/claude/skills/p3-start-feature/SKILL.md` |
| 7 | EDIT | `host/templates/claude/skills/p4-decompose-feature/SKILL.md` |

## Implementation Steps

### Step 1

**Operation:** EDIT
**File:** `host/templates/claude/commands/p1-start-epic.md`
**Details:** 3 `§`-occurrences (§1.12 ×2, §2.1 ×1).

- **§1.12 (L103 — architecture-impact / Standards-check chat notice; rule named inline as "Standards check invariant" → delete the bare `per §1.12`):**
  - **Locate:** `bootstrap via init-shamt is the canonical fix per §1.12.`
  - **Replace:** `bootstrap via init-shamt is the canonical fix.`
- **§2.1 (L166 — stub-list-then-drill-in deferral → re-point to the named decomposition pattern):**
  - **Locate:** `keeps deep dialog at the right altitude per §2.1 stub-list-then-drill-in.`
  - **Replace:** `keeps deep dialog at the right altitude per the stub-list-then-drill-in decomposition.`
- **§1.12 (L167 — PO-threading row; rule stated inline → delete `per §1.12 PO-threading row`):**
  - **Locate:** `Coding style is irrelevant at the epic altitude per §1.12 PO-threading row.`
  - **Replace:** `Coding style is irrelevant at the epic altitude.`

**Verification:** `grep -cE "§[0-9]+\.[0-9]+" host/templates/claude/commands/p1-start-epic.md` → 0

### Step 2

**Operation:** EDIT
**File:** `host/templates/claude/commands/p2-decompose-epic.md`
**Details:** 5 `§`-occurrences (§2.1 ×3, §2.3 ×1, §1.11 ×1).

- **§2.1 (L87 — deep-dialog deferral → re-point to the named decomposition pattern):**
  - **Locate:** `success criteria, or stories here — that is the next altitude's work per §2.1.`
  - **Replace:** `success criteria, or stories here — that is the next altitude's work per the stub-list-then-drill-in decomposition.`
- **§2.3 (L172 — parallelization-is-not-runtime-coordination → re-point to the decomposition / parallelization step):**
  - **Locate:** `no runtime coordination machinery per §2.3). Order is suggested by the `Recommended order` line just written to the epic.`
  - **Replace:** `no runtime coordination machinery per the decomposition / parallelization step). Order is suggested by the `Recommended order` line just written to the epic.`
- **§1.11 (L185 — freeform-fallback rule → re-point to the tracker freeform-fallback rule):**
  - **Locate:** `The §1.11 freeform-fallback rule does not apply at this altitude`
  - **Replace:** `The tracker freeform-fallback rule does not apply at this altitude`
- **§2.1 (L186 — stub-list-then-drill-in deferral → re-point to the named decomposition pattern):**
  - **Locate:** ``/p3-start-feature`'s job per §2.1 stub-list-then-drill-in.``
  - **Replace:** ``/p3-start-feature`'s job per the stub-list-then-drill-in decomposition.``
- **§2.1 (L187 — "16-category review stays story-level" → re-point to Pattern 4):**
  - **Locate:** `**No epic-level review phase.** Per §2.1, the 16-category code-review framework stays story-level.`
  - **Replace:** `**No epic-level review phase.** Per Pattern 4, the 16-category code-review framework stays story-level.`

**Verification:** `grep -cE "§[0-9]+\.[0-9]+" host/templates/claude/commands/p2-decompose-epic.md` → 0

### Step 3

**Operation:** EDIT
**File:** `host/templates/claude/commands/p3-start-feature.md`
**Details:** 6 `§`-occurrences (§2.1 ×3, §1.12 ×2, §1.4 ×1).

- **§2.1 (L61 — back-refs are decomposition-owned → re-point to the decomposition step):**
  - **Locate:** `they are decomposition-owned per §2.1. Only the body sections are touched.`
  - **Replace:** `they are decomposition-owned per the decomposition step. Only the body sections are touched.`
- **§2.1 (L94 — "standalone features have no parent epic"; statement is inline → delete the parenthetical, keep the inline statement):**
  - **Locate:** `standalone features have no parent epic (per §2.1 — the back-ref is optional and absent for standalone work).`
  - **Replace:** `standalone features have no parent epic — the back-ref is optional and absent for standalone work.`
- **§1.4 (L113 — story-vs-feature artifact layout; rule stated inline "stories ... *do* have `raw/`" → delete the bare `per §1.4`):**
  - **Locate:** ``distinct from stories, which *do* have `raw/` per §1.4.``
  - **Replace:** ``distinct from stories, which *do* have `raw/`.``
- **§1.12 (L128 — architecture-impact / Standards-check chat notice; rule named inline → delete the bare `per §1.12`):**
  - **Locate:** `bootstrap via init-shamt is the canonical fix per §1.12.`
  - **Replace:** `bootstrap via init-shamt is the canonical fix.`
- **§2.1 (L195 — stub-list-then-drill-in deferral → re-point to the named decomposition pattern):**
  - **Locate:** `keeps deep dialog at the right altitude per §2.1 stub-list-then-drill-in.`
  - **Replace:** `keeps deep dialog at the right altitude per the stub-list-then-drill-in decomposition.`
- **§1.12 (L196 — PO-threading row; rule stated inline → delete `per §1.12 PO-threading row`):**
  - **Locate:** `Coding style is irrelevant at the feature altitude per §1.12 PO-threading row.`
  - **Replace:** `Coding style is irrelevant at the feature altitude.`

**Verification:** `grep -cE "§[0-9]+\.[0-9]+" host/templates/claude/commands/p3-start-feature.md` → 0

### Step 4

**Operation:** EDIT
**File:** `host/templates/claude/commands/p4-decompose-feature.md`
**Details:** 5 `§`-occurrences (§2.1 ×3, §2.3 ×1, §1.11 ×1).

- **§2.1 (L107 — deep-dialog deferral → re-point to the named decomposition pattern):**
  - **Locate:** `that is the Engineer flow's work per §2.1.`
  - **Replace:** `that is the Engineer flow's work per the stub-list-then-drill-in decomposition.`
- **§2.3 (L200 — parallelization-is-not-runtime-coordination → re-point to the decomposition / parallelization step):**
  - **Locate:** `no runtime coordination machinery per §2.3). Order is suggested by the `Recommended order` line just written to the feature.`
  - **Replace:** `no runtime coordination machinery per the decomposition / parallelization step). Order is suggested by the `Recommended order` line just written to the feature.`
- **§1.11 (L216 — freeform-fallback rule → re-point to the tracker freeform-fallback rule):**
  - **Locate:** `The §1.11 freeform-fallback rule does not apply at this altitude`
  - **Replace:** `The tracker freeform-fallback rule does not apply at this altitude`
- **§2.1 (L217 — stub-list-then-drill-in deferral → re-point to the named decomposition pattern):**
  - **Locate:** ``/e1-start-story` (stub-aware)'s job per §2.1 stub-list-then-drill-in.``
  - **Replace:** ``/e1-start-story` (stub-aware)'s job per the stub-list-then-drill-in decomposition.``
- **§2.1 (L218 — "16-category review stays story-level" → re-point to Pattern 4):**
  - **Locate:** `**No feature-level review phase.** Per §2.1, the 16-category code-review framework stays story-level.`
  - **Replace:** `**No feature-level review phase.** Per Pattern 4, the 16-category code-review framework stays story-level.`

**Verification:** `grep -cE "§[0-9]+\.[0-9]+" host/templates/claude/commands/p4-decompose-feature.md` → 0

### Step 5

**Operation:** EDIT
**File:** `host/templates/claude/skills/p2-decompose-epic/SKILL.md`
**Details:** 1 `§`-occurrence (§2.1 ×1).

- **§2.1 (L49 — "16-category review stays story-level" → re-point to Pattern 4):**
  - **Locate:** `The 16-category code-review framework stays story-level per §2.1.`
  - **Replace:** `The 16-category code-review framework stays story-level per Pattern 4.`

**Verification:** `grep -cE "§[0-9]+\.[0-9]+" host/templates/claude/skills/p2-decompose-epic/SKILL.md` → 0

### Step 6

**Operation:** EDIT
**File:** `host/templates/claude/skills/p3-start-feature/SKILL.md`
**Details:** 1 `§`-occurrence (§2.1 ×1).

- **§2.1 (L47 — "globally unique" / flat layout → re-point to the flat folder layout):**
  - **Locate:** `Feature slugs are globally unique per §2.1 (flat folder layout).`
  - **Replace:** `Feature slugs are globally unique per the flat folder layout.`

**Verification:** `grep -cE "§[0-9]+\.[0-9]+" host/templates/claude/skills/p3-start-feature/SKILL.md` → 0

### Step 7

**Operation:** EDIT
**File:** `host/templates/claude/skills/p4-decompose-feature/SKILL.md`
**Details:** 3 `§`-occurrences (§2.1 ×2, §2.3 ×1).

- **§2.1 + §2.3 (L38 — the individually-testable rubric (decomposition, not review) + the decomposition exit-criterion resolution, both already named inline → delete both bare tokens):**
  - **Locate:** `**Enforce the individually-testable rubric** per §2.1 and the §2.3 decomposition exit-criterion resolution:`
  - **Replace:** `**Enforce the individually-testable rubric** and the decomposition exit-criterion resolution:`
- **§2.1 (L66 — "16-category review stays story-level" → re-point to Pattern 4):**
  - **Locate:** `The 16-category code-review framework stays story-level per §2.1.`
  - **Replace:** `The 16-category code-review framework stays story-level per Pattern 4.`

**Verification:** `grep -cE "§[0-9]+\.[0-9]+" host/templates/claude/skills/p4-decompose-feature/SKILL.md` → 0

## Phase-1 final verification

```
grep -cE "§[0-9]+\.[0-9]+" \
  host/templates/claude/commands/p1-start-epic.md \
  host/templates/claude/commands/p2-decompose-epic.md \
  host/templates/claude/commands/p3-start-feature.md \
  host/templates/claude/commands/p4-decompose-feature.md \
  host/templates/claude/skills/p2-decompose-epic/SKILL.md \
  host/templates/claude/skills/p3-start-feature/SKILL.md \
  host/templates/claude/skills/p4-decompose-feature/SKILL.md
```

Every file returns `0` — no `§N.N` citation remains anywhere in the Phase-1 set.

---
Validated 2026-06-06 — 1 round, 1 adversarial sub-agent confirmed (batch validation; validation-checker independently verified all locate strings exact + unique against HEAD, replacements clean, and per-file §-coverage → 0)
