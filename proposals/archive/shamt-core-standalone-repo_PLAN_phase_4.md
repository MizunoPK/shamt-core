# Implementation Plan — Phase 4: personas + mirrored skills

**Proposal:** proposals/shamt-core-standalone-repo.md
**Index:** proposals/shamt-core-standalone-repo_PLAN.md
**Created:** 2026-06-01
**Covers:** Proposed Changes rows 20, 21, 22, 23, 24, 25, 26, 27, 28
**Character:** 12 `INFRASTRUCTURE.md` citation removals across 2 personas and 7 mirrored skills. Includes three YAML frontmatter `description:` folded-scalar wraps (rows 26, 27, 28) — preserve the two-space continuation indent and folded-line wrapping.

These edits **mirror** the Phase 2/3 command edits (skills 22–25 mirror PO commands 11–14; skill 26 mirrors e5b command 16; skill 27 mirrors sync-import command 18; skill 28 mirrors sync-submit command 19). The command ↔ skill pairing must land consistently — that is why both halves are enumerated in this plan.

No cross-step ordering constraint. Each sub-edit's locate string is unique within its file.

---

## Step 1 — Sweep `agents/test-executor.md` (row 20 — 1 citation)

**Operation:** EDIT
**File:** `host/templates/claude/agents/test-executor.md`

**Locate:**
```
This phase **blocks until every step passes** (per `templates/SHAMT_RULES.template.md` and INFRASTRUCTURE.md §1.14). There is no `--skip-failing` flag
```
**Replace:**
```
This phase **blocks until every step passes** (per `templates/SHAMT_RULES.template.md`). There is no `--skip-failing` flag
```

**Verification:** `grep -c "INFRASTRUCTURE" host/templates/claude/agents/test-executor.md` returns `0`.

---

## Step 2 — Sweep `agents/review-executor.md` (row 21 — 1 citation)

**Operation:** EDIT
**File:** `host/templates/claude/agents/review-executor.md`

**Locate:**
```
- **No tracker postback.** Even when the active tracker profile documents a PR-comment command, you do not call it (per `templates/SHAMT_RULES.template.md` Pattern 4 and INFRASTRUCTURE.md §1.11). The artifact is the deliverable.
```
**Replace:**
```
- **No tracker postback.** Even when the active tracker profile documents a PR-comment command, you do not call it (per `templates/SHAMT_RULES.template.md` Pattern 4). The artifact is the deliverable.
```

**Verification:** `grep -c "INFRASTRUCTURE" host/templates/claude/agents/review-executor.md` returns `0`.

---

## Step 3 — Sweep `skills/p1-start-epic/SKILL.md` (row 22 — 1 citation; mirrors command row 11)

**Operation:** EDIT
**File:** `host/templates/claude/skills/p1-start-epic/SKILL.md`

**Locate:**
```
Per the freeform-fallback rule in [`reference/trackers/_contract.md`](../../../../../reference/trackers/_contract.md) (and INFRASTRUCTURE.md §1.11 for the design rationale).
```
**Replace:**
```
Per the freeform-fallback rule in [`reference/trackers/_contract.md`](../../../../../reference/trackers/_contract.md).
```

**Verification:** `grep -c "INFRASTRUCTURE" host/templates/claude/skills/p1-start-epic/SKILL.md` returns `0`.

---

## Step 4 — Sweep `skills/p2-decompose-epic/SKILL.md` (row 23 — 2 citations; mirrors command row 12)

**Operation:** EDIT
**File:** `host/templates/claude/skills/p2-decompose-epic/SKILL.md`

### 4a — line 38
**Locate:**
```
6. **Decomposition exit gate** (per INFRASTRUCTURE.md §2.3) — **2-condition check, run before stubs are written**: (1) every feature has a stated goal one-liner; (2) every feature appears in the parent epic's `Sequencing & Parallelization` analysis. **Distinct from `/validate-artifact`**.
```
**Replace:**
```
6. **Decomposition exit gate** — **2-condition check, run before stubs are written**: (1) every feature has a stated goal one-liner; (2) every feature appears in the parent epic's `Sequencing & Parallelization` analysis. **Distinct from `/validate-artifact`**.
```

### 4b — line 47
**Locate:**
```
- **Decomposition exit gate ≠ `/validate-artifact`.** Per INFRASTRUCTURE.md §2.1 epic-level review row, the gate is a 2-condition stub-batch check run **before** stubs land on disk.
```
**Replace:**
```
- **Decomposition exit gate ≠ `/validate-artifact`.** The gate is a 2-condition stub-batch check run **before** stubs land on disk.
```

**Verification:** `grep -c "INFRASTRUCTURE" host/templates/claude/skills/p2-decompose-epic/SKILL.md` returns `0`.

---

## Step 5 — Sweep `skills/p3-start-feature/SKILL.md` (row 24 — 1 citation; mirrors command row 13)

**Operation:** EDIT
**File:** `host/templates/claude/skills/p3-start-feature/SKILL.md`

**Locate:**
```
Per the freeform-fallback rule in [`reference/trackers/_contract.md`](../../../../../reference/trackers/_contract.md) (and INFRASTRUCTURE.md §1.11 for the design rationale).
```
**Replace:**
```
Per the freeform-fallback rule in [`reference/trackers/_contract.md`](../../../../../reference/trackers/_contract.md).
```

**Verification:** `grep -c "INFRASTRUCTURE" host/templates/claude/skills/p3-start-feature/SKILL.md` returns `0`.

---

## Step 6 — Sweep `skills/p4-decompose-feature/SKILL.md` (row 25 — 2 citations; mirrors command row 14)

**Operation:** EDIT
**File:** `host/templates/claude/skills/p4-decompose-feature/SKILL.md`

### 6a — line 48
**Locate:**
```
6. **Decomposition exit gate** (per INFRASTRUCTURE.md §2.3) — **2-condition check, run before stubs are written**: (1) every story stub has an individually-testable scope one-liner per the rubric above; (2) every story appears in the parent feature's `Sequencing & Parallelization` analysis. **Distinct from `/validate-artifact`**.
```
**Replace:**
```
6. **Decomposition exit gate** — **2-condition check, run before stubs are written**: (1) every story stub has an individually-testable scope one-liner per the rubric above; (2) every story appears in the parent feature's `Sequencing & Parallelization` analysis. **Distinct from `/validate-artifact`**.
```

### 6b — line 62
**Locate:**
```
- **Decomposition exit gate ≠ `/validate-artifact`.** Per INFRASTRUCTURE.md §2.1 (which applies at the feature altitude as at the epic altitude), the gate is a 2-condition stub-batch check run **before** stubs land on disk.
```
**Replace:**
```
- **Decomposition exit gate ≠ `/validate-artifact`.** The gate is a 2-condition stub-batch check run **before** stubs land on disk.
```

**Verification:** `grep -c "INFRASTRUCTURE" host/templates/claude/skills/p4-decompose-feature/SKILL.md` returns `0`.

---

## Step 7 — Sweep `skills/e5b-write-manual-testing-plan/SKILL.md` (row 26 — 1 citation; mirrors command row 16)

**Operation:** EDIT
**File:** `host/templates/claude/skills/e5b-write-manual-testing-plan/SKILL.md`

Frontmatter `description:` folded scalar (line 9). Case (c) — repoint the dimension source from the dead log to the canonical template that actually defines them (named in prose; this is a `description:` field, not a markdown link). Preserve the two-space continuation indent.

**Locate:**
```
  inline validation loop uses the 4 dimensions in INFRASTRUCTURE.md §1.15.
```
**Replace:**
```
  inline validation loop uses the 4 dimensions in templates/manual_test_plan.template.md.
```

**Verification:** `grep -c "INFRASTRUCTURE" host/templates/claude/skills/e5b-write-manual-testing-plan/SKILL.md` returns `0`; `grep -c "4 dimensions in templates/manual_test_plan.template.md" host/templates/claude/skills/e5b-write-manual-testing-plan/SKILL.md` returns `1`.

---

## Step 8 — Sweep `skills/sync-import-shamt/SKILL.md` (row 27 — 2 citations; mirrors command row 18)

**Operation:** EDIT
**File:** `host/templates/claude/skills/sync-import-shamt/SKILL.md`

### 8a — lines 11–12 (frontmatter `description:` folded scalar; the citation wraps across two lines — re-wrap cleanly)
**Locate:**
```
  jq-missing warnings. Always-latest (no version pinning) per INFRASTRUCTURE.md
  §4.13. Invoke when the user wants to pull master updates, sync the framework,
```
**Replace:**
```
  jq-missing warnings. Always-latest (no version pinning). Invoke when the user
  wants to pull master updates, sync the framework,
```

### 8b — line 48 (body — case (a))
**Locate:**
```
This is the practical interpretation of INFRASTRUCTURE.md §4.7, justified in `commands/sync-import-shamt.md` Notes.
```
**Replace:**
```
This is the practical interpretation of the subtree-level sync rule, justified in `commands/sync-import-shamt.md` Notes.
```

**Verification:** `grep -c "INFRASTRUCTURE" host/templates/claude/skills/sync-import-shamt/SKILL.md` returns `0`.

---

## Step 9 — Sweep `skills/sync-submit-proposal/SKILL.md` (row 28 — 1 citation; mirrors command row 19)

**Operation:** EDIT
**File:** `host/templates/claude/skills/sync-submit-proposal/SKILL.md`

Frontmatter `description:` folded scalar (line 12). The citation wraps across two lines — re-wrap cleanly. Preserve the two-space continuation indent.

**Locate:**
```
  NOT push to master, open PRs, or file issues — the submission is manual copy
  per INFRASTRUCTURE.md §4.3 Option B. Invoke when the user wants to send a
```
**Replace:**
```
  NOT push to master, open PRs, or file issues — the submission is manual copy.
  Invoke when the user wants to send a
```

**Verification:** `grep -c "INFRASTRUCTURE" host/templates/claude/skills/sync-submit-proposal/SKILL.md` returns `0`.

---

## Phase 4 cross-check

- Rows covered: 20, 21, 22, 23, 24, 25, 26, 27, 28 — one step each (Steps 1–9). ✓
- All EDIT; no CREATE / DELETE / MOVE; no `.claude/` path touched. ✓
- **Mirror integrity:** skills 22/23/24/25/26/27/28 (Steps 3–9) are swept consistently with their paired commands 11/12/13/14/16/18/19 (Phases 2–3). p2/p4 skills carry 2 citations each (matching the index manifest); sync-submit skill (Step 9) carries the citation originally easy to miss.
- `grep -rn "INFRASTRUCTURE\.md" host/templates/claude/agents/test-executor.md host/templates/claude/agents/review-executor.md host/templates/claude/skills/p1-start-epic/SKILL.md host/templates/claude/skills/p2-decompose-epic/SKILL.md host/templates/claude/skills/p3-start-feature/SKILL.md host/templates/claude/skills/p4-decompose-feature/SKILL.md host/templates/claude/skills/e5b-write-manual-testing-plan/SKILL.md host/templates/claude/skills/sync-import-shamt/SKILL.md host/templates/claude/skills/sync-submit-proposal/SKILL.md` returns zero lines after this phase.

---
*Validated 2026-06-01 — 2 rounds, 1 adversarial sub-agent confirmed.*
