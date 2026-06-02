# Implementation Plan — Phase 2: PO command citation sweep

**Proposal:** proposals/shamt-core-standalone-repo.md
**Index:** proposals/shamt-core-standalone-repo_PLAN.md
**Created:** 2026-06-01
**Covers:** Proposed Changes rows 11, 12, 13, 14
**Character:** Heaviest phase — 35 `INFRASTRUCTURE.md` citation removals across the four PO commands. Every removal is link-removal policy case (a): the rule is stated inline; drop the citation markup, keep the prose.

No cross-step ordering constraint. Each sub-edit's locate string is unique within its file.

---

## Step 1 — Sweep `p1-start-epic.md` (row 11 — 7 citations)

**Operation:** EDIT
**File:** `host/templates/claude/commands/p1-start-epic.md`

### 1a — line 21
**Locate:**
```
- `{slug}` (required) — epic slug. Globally unique across `epics/` (flat layout per [INFRASTRUCTURE.md §2.1](../../../../../INFRASTRUCTURE.md#21-what-epicfeature-work-actually-needs)). Form depends on the active tracker profile:
```
**Replace:**
```
- `{slug}` (required) — epic slug. Globally unique across `epics/` (flat layout). Form depends on the active tracker profile:
```

### 1b — line 80 (trailing sentence only)
**Locate:**
```
 (numbered item 1). Per [INFRASTRUCTURE.md §1.11](../../../../../INFRASTRUCTURE.md#111-issue-tracker-integration-ado--github-cli) `Field mapping` row.
```
**Replace:**
```
 (numbered item 1).
```

### 1c — line 84
**Locate:**
```
3. **Do not write `raw/issue.json`.** Per [INFRASTRUCTURE.md §2.1](../../../../../INFRASTRUCTURE.md#21-what-epicfeature-work-actually-needs) "Epic/feature/story folder structure", epic folders contain **only** `epic.md` — no `raw/` subfolder, no `feedback/`.
```
**Replace:**
```
3. **Do not write `raw/issue.json`.** Epic folders contain **only** `epic.md` — no `raw/` subfolder, no `feedback/`.
```

### 1d — line 101 (case (c) — inline the threading rule the dropped link headed)
**Locate:**
```
Per [INFRASTRUCTURE.md §1.12](../../../../../INFRASTRUCTURE.md#112-architecture--coding-standards-maintenance) PO-threading row:
```
**Replace:**
```
Thread architecture / coding-standards consultation at the PO altitude as follows:
```

### 1e — line 150 (trailing clause)
**Locate:**
```
instantiated here with `<Type>` = `Epic`) and the `Field mapping` row in [INFRASTRUCTURE.md §1.11](../../../../../INFRASTRUCTURE.md#111-issue-tracker-integration-ado--github-cli). Do **not** silently fail; do **not** halt.
```
**Replace:**
```
instantiated here with `<Type>` = `Epic`). Do **not** silently fail; do **not** halt.
```

### 1f — line 152
**Locate:**
```
there is no `raw/` subfolder at the epic altitude per [INFRASTRUCTURE.md §2.1](../../../../../INFRASTRUCTURE.md#21-what-epicfeature-work-actually-needs) "Epic/feature/story folder structure".
```
**Replace:**
```
there is no `raw/` subfolder at the epic altitude.
```

### 1g — line 165
**Locate:**
```
- **Epic-level validation is `/validate-artifact`.** Per [INFRASTRUCTURE.md §2.1](../../../../../INFRASTRUCTURE.md#21-what-epicfeature-work-actually-needs) epic-level review row, epics have no review phase — Pattern 1 validation only.
```
**Replace:**
```
- **Epic-level validation is `/validate-artifact`.** Epics have no review phase — Pattern 1 validation only.
```

**Verification:** `grep -c "INFRASTRUCTURE" host/templates/claude/commands/p1-start-epic.md` returns `0`.

---

## Step 2 — Sweep `p2-decompose-epic.md` (row 12 — 9 citations)

**Operation:** EDIT
**File:** `host/templates/claude/commands/p2-decompose-epic.md`

### 2a — line 69
**Locate:**
```
Resolve the existing folder via `features/{feature-slug}-*/` glob (slugs are globally unique per [§2.1](../../../../../INFRASTRUCTURE.md#21-what-epicfeature-work-actually-needs); the prior line records slugs only
```
**Replace:**
```
Resolve the existing folder via `features/{feature-slug}-*/` glob (slugs are globally unique; the prior line records slugs only
```

### 2b — line 70
**Locate:**
```
4. Draft the **parallelization analysis** per [INFRASTRUCTURE.md §2.1](../../../../../INFRASTRUCTURE.md#21-what-epicfeature-work-actually-needs) parallelization row:
```
**Replace:**
```
4. Draft the **parallelization analysis**:
```

### 2c — line 76
**Locate:**
```
Per [INFRASTRUCTURE.md §2.1](../../../../../INFRASTRUCTURE.md#21-what-epicfeature-work-actually-needs) stub-list pattern, the user gates **the entire list at once** — not per-feature.
```
**Replace:**
```
Per the stub-list pattern, the user gates **the entire list at once** — not per-feature.
```

### 2d — line 91
**Locate:**
```
Per [INFRASTRUCTURE.md §2.3](../../../../../INFRASTRUCTURE.md#23-open-meta-questions-specific-to-this-layer), check **before** writing any stubs to disk.
```
**Replace:**
```
Check **before** writing any stubs to disk.
```

### 2e — line 100
**Locate:**
```
Feature slug uniqueness is **global** per [INFRASTRUCTURE.md §2.1](../../../../../INFRASTRUCTURE.md#21-what-epicfeature-work-actually-needs) (flat layout). Before writing:
```
**Replace:**
```
Feature slug uniqueness is **global** (flat layout). Before writing:
```

### 2f — line 124
**Locate:**
```
Slugs are globally unique per [§2.1](../../../../../INFRASTRUCTURE.md#21-what-epicfeature-work-actually-needs), so the actual folder is always recoverable
```
**Replace:**
```
Slugs are globally unique, so the actual folder is always recoverable
```

### 2g — line 172
**Locate:**
```
Per [INFRASTRUCTURE.md §2.1](../../../../../INFRASTRUCTURE.md#21-what-epicfeature-work-actually-needs), each feature stub is **independently resumable**.
```
**Replace:**
```
Each feature stub is **independently resumable**.
```

### 2h — line 184
**Locate:**
```
- **Decomposition exit gate ≠ `/validate-artifact`.** Per [INFRASTRUCTURE.md §2.1](../../../../../INFRASTRUCTURE.md#21-what-epicfeature-work-actually-needs) epic-level review row, the gate in Step 6 is a 2-condition stub-batch check
```
**Replace:**
```
- **Decomposition exit gate ≠ `/validate-artifact`.** The gate in Step 6 is a 2-condition stub-batch check
```

### 2i — line 189
**Locate:**
```
- **Parallelization is PO-flow output, not runtime coordination.** Per [INFRASTRUCTURE.md §2.1](../../../../../INFRASTRUCTURE.md#21-what-epicfeature-work-actually-needs) parallelization row and §2.3 resolution. The `Parallelizable` callout
```
**Replace:**
```
- **Parallelization is PO-flow output, not runtime coordination.** The `Parallelizable` callout
```

**Verification:** `grep -c "INFRASTRUCTURE" host/templates/claude/commands/p2-decompose-epic.md` returns `0`.

---

## Step 3 — Sweep `p3-start-feature.md` (row 13 — 8 citations)

**Operation:** EDIT
**File:** `host/templates/claude/commands/p3-start-feature.md`

### 3a — line 21
**Locate:**
```
- `{slug}` (required) — feature slug. **Globally unique across `features/`** (flat layout per [INFRASTRUCTURE.md §2.1](../../../../../INFRASTRUCTURE.md#21-what-epicfeature-work-actually-needs)). Form depends on the active tracker profile:
```
**Replace:**
```
- `{slug}` (required) — feature slug. **Globally unique across `features/`** (flat layout). Form depends on the active tracker profile:
```

### 3b — line 109 (trailing sentence)
**Locate:**
```
 otherwise fall through to **Mode B**. Per [INFRASTRUCTURE.md §1.11](../../../../../INFRASTRUCTURE.md#111-issue-tracker-integration-ado--github-cli) `Field mapping` row.
```
**Replace:**
```
 otherwise fall through to **Mode B**.
```

### 3c — line 113 (drop the §2.1 citation; leave the bare `per §1.4` tag per index Notes)
**Locate:**
```
3. **Do not write `raw/issue.json`.** Per [INFRASTRUCTURE.md §2.1](../../../../../INFRASTRUCTURE.md#21-what-epicfeature-work-actually-needs) "Epic/feature/story folder structure", feature folders contain **only** `feature.md` — no `raw/` subfolder, no `feedback/`.
```
**Replace:**
```
3. **Do not write `raw/issue.json`.** Feature folders contain **only** `feature.md` — no `raw/` subfolder, no `feedback/`.
```

### 3d — line 126 (case (c) — inline the threading rule)
**Locate:**
```
Per [INFRASTRUCTURE.md §1.12](../../../../../INFRASTRUCTURE.md#112-architecture--coding-standards-maintenance) PO-threading row:
```
**Replace:**
```
Thread architecture / coding-standards consultation at the PO altitude as follows:
```

### 3e — line 147
**Locate:**
```
Feature slugs are **globally unique** per [INFRASTRUCTURE.md §2.1](../../../../../INFRASTRUCTURE.md#21-what-epicfeature-work-actually-needs).
```
**Replace:**
```
Feature slugs are **globally unique**.
```

### 3f — line 178 (trailing clause)
**Locate:**
```
instantiated here with `<Type>` = `Feature`) and the `Field mapping` row in [INFRASTRUCTURE.md §1.11](../../../../../INFRASTRUCTURE.md#111-issue-tracker-integration-ado--github-cli). Do **not** silently fail; do **not** halt.
```
**Replace:**
```
instantiated here with `<Type>` = `Feature`). Do **not** silently fail; do **not** halt.
```

### 3g — line 180
**Locate:**
```
there is no `raw/` subfolder at the feature altitude per [INFRASTRUCTURE.md §2.1](../../../../../INFRASTRUCTURE.md#21-what-epicfeature-work-actually-needs) "Epic/feature/story folder structure". Same pattern as `/p1-start-epic`.
```
**Replace:**
```
there is no `raw/` subfolder at the feature altitude. Same pattern as `/p1-start-epic`.
```

### 3h — line 194
**Locate:**
```
- **Feature-level validation is `/validate-artifact`.** Per [INFRASTRUCTURE.md §2.1](../../../../../INFRASTRUCTURE.md#21-what-epicfeature-work-actually-needs) epic-level review row (which applies identically at the feature altitude), features have no review phase — Pattern 1 validation only.
```
**Replace:**
```
- **Feature-level validation is `/validate-artifact`.** Features have no review phase — Pattern 1 validation only.
```

**Verification:** `grep -c "INFRASTRUCTURE" host/templates/claude/commands/p3-start-feature.md` returns `0`.

---

## Step 4 — Sweep `p4-decompose-feature.md` (row 14 — 11 citations)

**Operation:** EDIT
**File:** `host/templates/claude/commands/p4-decompose-feature.md`

### 4a — line 7
**Locate:**
```
enforce the **individually-testable rubric** per [INFRASTRUCTURE.md §2.1](../../../../../INFRASTRUCTURE.md#21-what-epicfeature-work-actually-needs), gate the whole list with the user once,
```
**Replace:**
```
enforce the **individually-testable rubric**, gate the whole list with the user once,
```

### 4b — line 66
**Locate:**
```
3. **Enforce the individually-testable rubric** per [§2.1](../../../../../INFRASTRUCTURE.md#21-what-epicfeature-work-actually-needs) parallelization row and the §2.3 decomposition exit-criterion resolution. **The rubric, in full:**
```
**Replace:**
```
3. **Enforce the individually-testable rubric** — **the rubric, in full:**
```

### 4c — line 87
**Locate:**
```
Resolve the existing folder via `stories/{story-slug}-*/` glob (slugs are globally unique per [§2.1](../../../../../INFRASTRUCTURE.md#21-what-epicfeature-work-actually-needs); the prior line records slugs only
```
**Replace:**
```
Resolve the existing folder via `stories/{story-slug}-*/` glob (slugs are globally unique; the prior line records slugs only
```

### 4d — line 89
**Locate:**
```
5. Draft the **parallelization analysis** per [INFRASTRUCTURE.md §2.1](../../../../../INFRASTRUCTURE.md#21-what-epicfeature-work-actually-needs) parallelization row:
```
**Replace:**
```
5. Draft the **parallelization analysis**:
```

### 4e — line 95
**Locate:**
```
Per [INFRASTRUCTURE.md §2.1](../../../../../INFRASTRUCTURE.md#21-what-epicfeature-work-actually-needs) stub-list pattern, the user gates **the entire list at once** — not per-story.
```
**Replace:**
```
Per the stub-list pattern, the user gates **the entire list at once** — not per-story.
```

### 4f — line 111
**Locate:**
```
Per [INFRASTRUCTURE.md §2.3](../../../../../INFRASTRUCTURE.md#23-open-meta-questions-specific-to-this-layer), check **before** writing any stubs to disk.
```
**Replace:**
```
Check **before** writing any stubs to disk.
```

### 4g — line 120
**Locate:**
```
Story slug uniqueness is **global** per [INFRASTRUCTURE.md §2.1](../../../../../INFRASTRUCTURE.md#21-what-epicfeature-work-actually-needs) (flat layout). Before writing:
```
**Replace:**
```
Story slug uniqueness is **global** (flat layout). Before writing:
```

### 4h — line 151
**Locate:**
```
Slugs are globally unique per [§2.1](../../../../../INFRASTRUCTURE.md#21-what-epicfeature-work-actually-needs), so the actual folder is always recoverable
```
**Replace:**
```
Slugs are globally unique, so the actual folder is always recoverable
```

### 4i — line 200
**Locate:**
```
Per [INFRASTRUCTURE.md §2.1](../../../../../INFRASTRUCTURE.md#21-what-epicfeature-work-actually-needs), each story stub is **independently resumable**.
```
**Replace:**
```
Each story stub is **independently resumable**.
```

### 4j — line 213
**Locate:**
```
- **Decomposition exit gate ≠ `/validate-artifact`.** Per [INFRASTRUCTURE.md §2.1](../../../../../INFRASTRUCTURE.md#21-what-epicfeature-work-actually-needs) epic-level review row (which applies identically at the feature altitude), the gate in Step 6 is a 2-condition stub-batch check
```
**Replace:**
```
- **Decomposition exit gate ≠ `/validate-artifact`.** The gate in Step 6 is a 2-condition stub-batch check
```

### 4k — line 220
**Locate:**
```
- **Parallelization is PO-flow output, not runtime coordination.** Per [INFRASTRUCTURE.md §2.1](../../../../../INFRASTRUCTURE.md#21-what-epicfeature-work-actually-needs) parallelization row and §2.3 resolution. The `Parallelizable` callout
```
**Replace:**
```
- **Parallelization is PO-flow output, not runtime coordination.** The `Parallelizable` callout
```

**Verification:** `grep -c "INFRASTRUCTURE" host/templates/claude/commands/p4-decompose-feature.md` returns `0`.

---

## Phase 2 cross-check

- Rows covered: 11 (Step 1, 7 edits), 12 (Step 2, 9 edits), 13 (Step 3, 8 edits), 14 (Step 4, 11 edits) = 35 citation removals. ✓
- All EDIT; no CREATE / DELETE / MOVE; no `.claude/` path touched. ✓
- `grep -rn "INFRASTRUCTURE\.md" host/templates/claude/commands/p1-start-epic.md host/templates/claude/commands/p2-decompose-epic.md host/templates/claude/commands/p3-start-feature.md host/templates/claude/commands/p4-decompose-feature.md` returns zero lines after this phase.
- Residual bare `§1.4` (3c), `§1.12` (1d/3d sub-item bodies), `§2.3` (2g/4i bodies) tags are intentionally retained per the index's "Residual bare `§N` section tags" note.

---
*Validated 2026-06-01 — 1 round, 1 adversarial sub-agent confirmed.*
