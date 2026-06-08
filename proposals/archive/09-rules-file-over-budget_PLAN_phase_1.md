# Implementation Plan — Phase 1 — rules-file-over-budget (#09)

**Created:** 2026-06-08
**Index:** `proposals/09-rules-file-over-budget_PLAN.md`
**Proposal:** `proposals/09-rules-file-over-budget.md` (Validated 2026-06-07)
**Cuts in this phase:** C1 (Part 3 phase narratives → pointer), C2 (per-phase model table → pointer).
**File edited:** `templates/SHAMT_RULES.template.md` only.

> **Deploy order:** Phase 1 runs first. Re-confirm anchors against the live file; cited line numbers are pre-edit/approximate.

---

## Step 0: Create the proposal branch
**Operation:** BRANCH
**Details:**
- Run `git checkout -b proposal/09-rules-file-over-budget` from `main`. If it exists, stop and report.
- Capture baseline size: `wc -m templates/SHAMT_RULES.template.md` (expect **40281**); record it.

**Verification:** `git branch --show-current` → `proposal/09-rules-file-over-budget`.

---

## Step 1: C1 — replace the Part 3 phase-narrative section with a pointer (proposal row 1)
**Operation:** EDIT
**File:** `templates/SHAMT_RULES.template.md`

**Coverage proof (run FIRST — confirm every removed normative invariant lives in a command before deleting):**
```
grep -ci "blocks until\|all tests pass\|no exceptions"        host/templates/claude/commands/e5-execute-tests.md      # Phase 5 blocks → ≥1
grep -ci "root.cause\|generaliz\|framework-update\|proposals/" host/templates/claude/commands/e7-resolve-feedback.md  # Phase 7 routing → ≥1
grep -ci "plan-executor\|architect.*not execute\|does not execute" host/templates/claude/commands/e4-execute-plan.md  # Phase 4 handoff → ≥1
grep -ci "Gate 2a\|Gate 2b"                                    host/templates/claude/commands/e2-define-spec.md        # Spec gates → ≥1
grep -ci "Gate 3"                                              host/templates/claude/commands/e3-plan-implementation.md# Plan gate → ≥1
grep -ci "Plan Alignment\|Documentation Impact"               host/templates/claude/commands/e6-review-changes.md     # Review pre-passes → ≥1
```
All must return ≥1. If any returns 0, **halt** — that invariant is not covered; keep it inline rather than dropping it.

**Details — one block replacement:**
- **Locate** the entire Part 3 section: the span beginning at the line `# Part 3: Engineer Flow — Phase Narratives` and ending at the line that finishes Phase 7 — `**Phase 7: Polish.** Apply reviewer feedback and capture generalizable lessons.` … `Models: Sonnet (fixes), Opus (root cause).` (the last paragraph before the `---` that precedes `# Requirement Re-baseline Protocol`). This span is the heading + intro sentence + the seven `**Phase N: …**` paragraphs.
- **Replace** that entire span with exactly:
  ```
  # Part 3: Engineer Flow — Phase Narratives

  Each phase's purpose, minimum-viable artifact, gate, recommended model, and per-phase invariants live authoritatively in its **command body** — `/e1-start-story`, `/e2-define-spec`, `/e3-plan-implementation` (+ `/e3b-write-testing-plan`), `/e4-execute-plan`, `/e5-execute-tests`, `/e6-review-changes`, `/e7-resolve-feedback` (under `host/templates/claude/commands/`). Gates are summarized in the Quick / Standard path-map tables above; per-phase model tiers are in `reference/model_selection.md`. Resume any phase with its slug-first command (e.g. `/e4-execute-plan {slug}`).
  ```
- Do **not** touch the `---` separators bounding the section; only the heading-through-Phase-7 span is replaced.

**Verification:** `grep -c "^\*\*Phase [0-9]: " templates/SHAMT_RULES.template.md` → `0` (no phase-narrative paragraphs remain); `grep -c "live authoritatively in its \*\*command body\*\*" templates/SHAMT_RULES.template.md` → `1`; the `# Part 3` heading still present (`grep -c "^# Part 3: Engineer Flow — Phase Narratives" …` → `1`).

---

## Step 2: C2 — replace the per-phase model table with a pointer (proposal row 2)
**Operation:** EDIT
**File:** `templates/SHAMT_RULES.template.md`

**Coverage proof (run FIRST):**
```
grep -cE "^\| 1\. Intake|^\| 2\. Spec|^\| 6\. Review|^\| 7\. Polish" reference/model_selection.md   # per-phase rows present → ≥4
```
Must return ≥4 (the authoritative per-phase table exists in `model_selection.md`). If 0, **halt**.

**Details — one block replacement:**
- **Locate** the span from the heading `## Recommended models per phase (Engineer flow)` through the line `Personas can override the global table per their definition (see \`host/templates/claude/\`).` (the heading, the `| Phase | Model |` table with all its rows, and the trailing "Personas can override…" sentence).
- **Replace** that entire span with exactly:
  ```
  ## Recommended models per phase (Engineer flow)

  The per-phase model tiers for the Engineer flow live in `reference/model_selection.md` (the authoritative table). Personas can override per their definition (see `host/templates/claude/`).
  ```

**Verification:** `grep -c "^| 1. Intake | Haiku |" templates/SHAMT_RULES.template.md` → `0` (the table is gone); `grep -c "the authoritative table" templates/SHAMT_RULES.template.md` → `1`; the `## Recommended models per phase (Engineer flow)` heading still present.

---

## Phase 1 exit
- Both blocks replaced; coverage proofs passed; the two headings retained with pointer bodies.
- `wc -m templates/SHAMT_RULES.template.md` should be ≈ **36,200** (40,281 − ~4,080). Record it (informational; the hard check is at Phase 4).
- **No commit.** Next phase: Phase 2 (C3).

---

## Notes
- Pure de-dup: both removed blocks restate content authoritative elsewhere (the `e1`–`e7` command bodies; `reference/model_selection.md`). The coverage proofs above are the rule-preservation guarantee.
- Only `templates/SHAMT_RULES.template.md` is edited. No `.claude/`, no destination-file edits, no commit.

---
Validated 2026-06-08 — adversarial sub-agent confirmed. C1/C2 are pure de-dup; coverage proofs verified that the removed content lives in the destinations (e1–e7 carry the phase invariants — e5 blocks-rule, e7 root-cause-routing, e4 handoff, e2/e3 gates, e6 pre-passes; model_selection.md carries the per-phase table). Block anchors exact + unique; headings retained with pointer bodies.
