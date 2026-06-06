# Implementation Plan — #04 §-citation purge — Phase 2: Engineer flow

This phase abolishes every dangling `§N.N` citation across the nine Engineer-flow canonical files, applying the proposal's §-token resolution table per-site. Each `§` is either re-pointed to its v2 named home or deleted where a named reference / inline statement already co-exists. Locate strings are verbatim and unique (`grep -cF` → 1) in their target file.

## Files Touched

| # | Canonical path | Operation | §-tokens |
|---|----------------|-----------|----------|
| 1 | `host/templates/claude/commands/e5-execute-tests.md` | EDIT | §1.14 |
| 2 | `host/templates/claude/commands/e5b-write-manual-testing-plan.md` | EDIT | §1.15 (×4) |
| 3 | `host/templates/claude/commands/e6-review-changes.md` | EDIT | §3.5, §1.11 |
| 4 | `host/templates/claude/commands/e7-resolve-feedback.md` | EDIT | §1.12 |
| 5 | `host/templates/claude/agents/test-executor.md` | EDIT | §1.14 |
| 6 | `host/templates/claude/skills/e5-execute-tests/SKILL.md` | EDIT | §1.14 |
| 7 | `host/templates/claude/skills/e5b-write-manual-testing-plan/SKILL.md` | EDIT | §1.15 (×2) |
| 8 | `host/templates/claude/skills/e6-review-changes/SKILL.md` | EDIT | §1.11, §1.12 |
| 9 | `host/templates/claude/skills/e7-resolve-feedback/SKILL.md` | EDIT | §1.12 |

All paths are canonical sources at the repo root. **No `.claude/` files** are touched (host bodies regenerate via `/f4-regen-framework` in Phase 5).

---

## Implementation Steps

### Step 1

**Operation:** EDIT
**File:** `host/templates/claude/commands/e5-execute-tests.md`

**Details:**

- §1.14 (testing-plan escalation threshold facet, line 49). Re-point per the §-table to the named escalation rule (`/e3b`).
  - **Locate:** `because test scope exceeded the Quick-path inline threshold (>5 steps or any new test file, per §1.14).`
  - **Replace:** `because test scope exceeded the Quick-path inline threshold (>5 steps or any new test file) — the testing-plan escalation threshold (\`/e3b\`).`

**Verification:** `grep -cE "§[0-9]+\.[0-9]+" host/templates/claude/commands/e5-execute-tests.md` → `0`

---

### Step 2

**Operation:** EDIT
**File:** `host/templates/claude/commands/e5b-write-manual-testing-plan.md`

**Details:**

- §1.15 (model-tier facet — **two** quoted reproductions of the `reference/model_selection.md` `## Per-phase guidance` cell, at lines 13 AND 151). Both are identical and get the identical change, so apply ONE **`replace_all`** edit on the shared fragment (it occurs exactly 2× in THIS command file — verified — at lines 13 & 151; lines 103/150 of this file use a different `§1.15` form, handled by their own steps below). `replace_all` is **file-scoped**, so it does not affect the e5b **skill**'s separate model-tier reproduction (line 47), which this phase's e5b-skill step handles independently. Mirror the row-30 cell change (`per \`§1.15\`` → `per the manual-test-plan rule`).
  - **Locate (replace_all: true):** the fragment `per \`§1.15\`").` (verbatim, with backticks around the token and `").` after — appears exactly 2× = lines 13 & 151)
  - **Replace:** `per the manual-test-plan rule").`
  - (Avoids the line-13-vs-151 distinguishability concern entirely: both identical reproductions are updated in a single `replace_all`.)

- §1.15 (validation-sub-agent facet, line 103). Re-point per the §-table to Pattern 1's risk-triggered sub-agent.
  - **Locate:** `**unless** the validation loop produced a HIGH or above on any round (per §1.15 — "Sub-agent adversarial confirmation`
  - **Replace:** `**unless** the validation loop produced a HIGH or above on any round (per Pattern 1's risk-triggered sub-agent — "Sub-agent adversarial confirmation`

- §1.15 (the rule itself / always-available facet, line 150). Re-point to "the manual-test-plan rule".
  - **Locate:** `It is always available, on every story, per §1.15.`
  - **Replace:** `It is always available, on every story, per the manual-test-plan rule.`

**Verification:** `grep -cE "§[0-9]+\.[0-9]+" host/templates/claude/commands/e5b-write-manual-testing-plan.md` → `0`

---

### Step 3

**Operation:** EDIT
**File:** `host/templates/claude/commands/e6-review-changes.md`

**Details:**

- §3.5 (audit doc-currency facet, line 96). Re-point per the §-table to the audit's D6.
  - **Locate:** `pure staleness without a touching change is the framework audit's §3.5 D6 dimension, not Phase 6's responsibility.`
  - **Replace:** `pure staleness without a touching change is the audit's D6 (doc currency) dimension, not Phase 6's responsibility.`

- §1.11 (tracker / no-postback facet, line 194 — Pattern 4 co-named). Delete the dangling `§1.11 / `, keeping "the Pattern 4 resolution".
  - **Locate:** `This is the §1.11 / Pattern 4 resolution.`
  - **Replace:** `This is the Pattern 4 resolution.`

**Verification:** `grep -cE "§[0-9]+\.[0-9]+" host/templates/claude/commands/e6-review-changes.md` → `0`

---

### Step 4

**Operation:** EDIT
**File:** `host/templates/claude/commands/e7-resolve-feedback.md`

**Details:**

- §1.12 (improvements-via-proposals facet, line 92 — "framework-update flow" co-named via Part 3). Delete the "the §1.12 + Part 3 lesson —" wording; restate the sentence around the framework-update flow.
  - **Locate:** `This is the §1.12 + Part 3 lesson — durable framework improvements happen via proposals, not in-story shortcuts.`
  - **Replace:** `Durable framework improvements happen via the framework-update flow (proposals), not in-story shortcuts.`

**Verification:** `grep -cE "§[0-9]+\.[0-9]+" host/templates/claude/commands/e7-resolve-feedback.md` → `0`

---

### Step 5

**Operation:** EDIT
**File:** `host/templates/claude/agents/test-executor.md`

**Details:**

- §1.14 (environmental-resolution facet, line 93 — the rule is stated inline in the same bullet). Delete the dangling "This is the §1.14 rule." sentence; the rule already reads inline ("Resolve environmental issues; do not skip them.").
  - **Locate:** `- **Resolve environmental issues; do not skip them.** This is the §1.14 rule. If \`gh\` is unauthenticated, authenticate.`
  - **Replace:** `- **Resolve environmental issues; do not skip them.** If \`gh\` is unauthenticated, authenticate.`

**Verification:** `grep -cE "§[0-9]+\.[0-9]+" host/templates/claude/agents/test-executor.md` → `0`

---

### Step 6

**Operation:** EDIT
**File:** `host/templates/claude/skills/e5-execute-tests/SKILL.md`

**Details:**

- §1.14 (Phase-5 execution-blocking facet, line 37 — the rule is stated inline: "Phase 5 blocks until every step passes"). Delete the dangling parenthetical `(§1.14)`.
  - **Locate:** `Phase 5 blocks until every step passes (§1.14).`
  - **Replace:** `Phase 5 blocks until every step passes.`

**Verification:** `grep -cE "§[0-9]+\.[0-9]+" host/templates/claude/skills/e5-execute-tests/SKILL.md` → `0`

---

### Step 7

**Operation:** EDIT
**File:** `host/templates/claude/skills/e5b-write-manual-testing-plan/SKILL.md`

**Details:**

- §1.15 (the rule itself / always-available facet, line 26). Re-point to "the manual-test-plan rule".
  - **Locate:** `no no-op gate (this is the §1.15 rule that distinguishes it from \`/e3b-write-testing-plan\` and \`/e5-execute-tests\`).`
  - **Replace:** `no no-op gate (this is the manual-test-plan rule that distinguishes it from \`/e3b-write-testing-plan\` and \`/e5-execute-tests\`).`

- §1.15 (model-tier facet, line 47 — quoted reproduction of the `reference/model_selection.md` `## Per-phase guidance` cell). Mirror that cell's Phase-4 change.
  - **Locate:** `("Manual-test-plan drafting | Balanced | Drafting + validation loop per \`§1.15\`").`
  - **Replace:** `("Manual-test-plan drafting | Balanced | Drafting + validation loop per the manual-test-plan rule").`

**Verification:** `grep -cE "§[0-9]+\.[0-9]+" host/templates/claude/skills/e5b-write-manual-testing-plan/SKILL.md` → `0`

---

### Step 8

**Operation:** EDIT
**File:** `host/templates/claude/skills/e6-review-changes/SKILL.md`

**Details:**

- §1.12 (Documentation Impact Assessment facet, line 39 — architecture-impact). Re-point per the §-table to the architecture-impact / Standards check.
  - **Locate:** `4. **Documentation Impact Assessment** (§1.12) — does the change require`
  - **Replace:** `4. **Documentation Impact Assessment** (the architecture-impact consult / Standards check) — does the change require`

- §1.11 (tracker / no-postback facet, line 48 — Pattern 4 co-named). Delete the dangling `§1.11 / `, keeping "per Pattern 4".
  - **Locate:** `**No tracker postback** — user posts manually if desired (per §1.11 / Pattern 4).`
  - **Replace:** `**No tracker postback** — user posts manually if desired (per Pattern 4).`

**Verification:** `grep -cE "§[0-9]+\.[0-9]+" host/templates/claude/skills/e6-review-changes/SKILL.md` → `0`

---

### Step 9

**Operation:** EDIT
**File:** `host/templates/claude/skills/e7-resolve-feedback/SKILL.md`

**Details:**

- §1.12 (improvements-via-proposals facet, line 32 — "framework-update flow" co-named via Part 3). Delete the dangling parenthetical `(§1.12 + Part 3 rule)`, keeping "via the framework-update flow".
  - **Locate:** `generalizable patterns → \`.shamt-core/proposals/<proposal-slug>.md\` (descriptive slug, not the story slug) via the framework-update flow (§1.12 + Part 3 rule). Story-specific patterns stay in-story.`
  - **Replace:** `generalizable patterns → \`.shamt-core/proposals/<proposal-slug>.md\` (descriptive slug, not the story slug) via the framework-update flow. Story-specific patterns stay in-story.`

**Verification:** `grep -cE "§[0-9]+\.[0-9]+" host/templates/claude/skills/e7-resolve-feedback/SKILL.md` → `0`

---

## Phase-2 final verification

After all nine steps, the following must return `0`:

```sh
grep -cREc "§[0-9]+\.[0-9]+" \
  host/templates/claude/commands/e5-execute-tests.md \
  host/templates/claude/commands/e5b-write-manual-testing-plan.md \
  host/templates/claude/commands/e6-review-changes.md \
  host/templates/claude/commands/e7-resolve-feedback.md \
  host/templates/claude/agents/test-executor.md \
  host/templates/claude/skills/e5-execute-tests/SKILL.md \
  host/templates/claude/skills/e5b-write-manual-testing-plan/SKILL.md \
  host/templates/claude/skills/e6-review-changes/SKILL.md \
  host/templates/claude/skills/e7-resolve-feedback/SKILL.md
```

Equivalently, the aggregate count must be `0`:

```sh
grep -rhoE "§[0-9]+\.[0-9]+" \
  host/templates/claude/commands/e5-execute-tests.md \
  host/templates/claude/commands/e5b-write-manual-testing-plan.md \
  host/templates/claude/commands/e6-review-changes.md \
  host/templates/claude/commands/e7-resolve-feedback.md \
  host/templates/claude/agents/test-executor.md \
  host/templates/claude/skills/e5-execute-tests/SKILL.md \
  host/templates/claude/skills/e5b-write-manual-testing-plan/SKILL.md \
  host/templates/claude/skills/e6-review-changes/SKILL.md \
  host/templates/claude/skills/e7-resolve-feedback/SKILL.md | wc -l
```

→ `0`. No `§N.N` token remains anywhere in the Phase-2 surface, and every site reads cleanly with its v2 named home (or a clean inline statement where the `§` was deleted).

---
Validated 2026-06-06 — 1 round, 1 adversarial sub-agent confirmed (batch validation, 2 adversarial passes: pass 1 raised a non-unique-locate concern on the e5b §1.15 model-tier line — proved a FALSE POSITIVE (each plan locate was unique, count=1 verified) but reworked to a file-scoped `replace_all` for robustness; pass 2 confirmed all locate strings unique, all 15 §-occurrences covered → 0, and resolution-table correctness — flagged only an imprecise "nowhere else" note phrasing, now clarified)
