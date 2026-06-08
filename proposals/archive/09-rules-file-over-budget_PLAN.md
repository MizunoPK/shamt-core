# Implementation Plan (Index) — rules-file-over-budget (#09)

**Created:** 2026-06-08
**Proposal:** `proposals/09-rules-file-over-budget.md` (Validated 2026-06-07)
**Altitude:** Framework-update (Part 3). Executor: `plan-executor` (Haiku) via `/f3-implement-update`, **one phase at a time in deploy order**.
**Base branch:** `main`

---

## Planning Status

- **Phase-decomposed** — 4 phase files, all editing the single file `templates/SHAMT_RULES.template.md`. Decomposed because the cuts are delicate rule-preserving rewrites (especially C3) that would compact a single Phase-4 session.
- **Ready for mechanical validation:** [x] Yes — each phase file carries exact anchors + replacement prose + a per-cut coverage proof; no optional branches.

---

## Deploy order (MANDATORY — line numbers shift after each phase)

Every phase edits the **same file** (`templates/SHAMT_RULES.template.md`), so each removal renumbers the lines below it. **Locate strings are unique text anchors, not line numbers** (cited line numbers are *pre-edit, approximate*). Run phases strictly in this order; re-confirm anchors against the live file at the start of each phase:

| Phase | File | Cuts | Section(s) touched | Est. Δ |
|-------|------|------|--------------------|--------|
| 1 | `proposals/09-rules-file-over-budget_PLAN_phase_1.md` | C1, C2 | `# Part 3` phase narratives; `## Recommended models per phase` table | −4,080 |
| 2 | `proposals/09-rules-file-over-budget_PLAN_phase_2.md` | C3 | `## Pattern 3: Spec Protocol` | −2,500 |
| 3 | `proposals/09-rules-file-over-budget_PLAN_phase_3.md` | C4, C5 | `## Pattern 5` Hard planning checks; `## Pattern 1` Step 2 dimension hard-checks | −2,800 |
| 4 | `proposals/09-rules-file-over-budget_PLAN_phase_4.md` | C6 + final measure | Pattern 4 16-category line → pointer (the `## Principle 2` / path-bullet prose-rephrase originally scoped to C6 is **deferred** per amended proposal row 6); then `wc -m` | −200 |

The phases touch **non-overlapping sections**, so order is for line-stability + measurement clarity, not data dependency. **Phase 4 ends with the budget measurement** (`wc -m ≤ 30,000`, hard floor ≤ 40,000) — the proposal's exit gate.

---

## Pre-Execution Checklist

- [ ] **Proposal branch** `proposal/09-rules-file-over-budget` created from `main` (Phase 1, Step 0). Halt if it already exists.
- [ ] `templates/SHAMT_RULES.template.md` exists; capture its starting `wc -m` (expect 40,281) before Phase 1.
- [ ] **Hard rule:** the ONLY file edited is `templates/SHAMT_RULES.template.md` (a root canonical doc under `templates/`). **Never** `.claude/`, never the de-dup destination files (`e1`–`e7`, `reference/*`) — they already carry the content and are not edited.
- [ ] Review-Prevention Gate Mapping: **N/A at framework altitude** (documentation-prose condensation; no app code/data/auth/tests).
- [ ] Each phase file validated (Phase 2 footer present) before its execution.

---

## Files Touched (manifest)

| Operation | Path |
|-----------|------|
| BRANCH | `proposal/09-rules-file-over-budget` (from `main`, in Phase 1) |
| EDIT | `templates/SHAMT_RULES.template.md` (all 4 phases) |

No other path is created or edited. The de-dup destinations are read-only references, not edit targets.

---

## Cross-check vs Proposed Changes (one phase-step per proposal row)

- Proposal row 1 (C1) → Phase 1 Step 1
- Proposal row 2 (C2) → Phase 1 Step 2
- Proposal row 3 (C3) → Phase 2 Step 1
- Proposal row 4 (C4) → Phase 3 Step 1
- Proposal row 5 (C5) → Phase 3 Step 2
- Proposal row 6 (C6) → Phase 4 Step 1

---

## Global guardrail (every phase)

**No normative rule may be lost.** Each cut is a de-dup (remove a duplicate, leave a pointer), an intra-file cross-ref (replace a restatement with a pointer to the owning Pattern), or a rephrase. Every phase file includes a **coverage proof**: for each removed passage, a grep/Read confirming the rule still lives in its destination (a command body, a `reference/` doc, or another Pattern in this same file). A passage whose rule cannot be located in a destination is **kept inline**, not removed — halt and report rather than drop it.

---

## Notes

- **No `.claude/` / no regen.** `templates/SHAMT_RULES.template.md` is not rendered by `regenerate-framework.sh` (it renders into a child's `CLAUDE.md` at install/`sync-import`). `/f4-regen-framework` is a no-op but is run to confirm `no drift`. The post-`/f3` `/f5-audit-framework` re-runs D12 to confirm the file is back under budget.
- **No commit in Phase 4 builds.** The commit + squash-merge land at `/f6-archive-proposal`.

---
Validated 2026-06-08 — adversarial sub-agent confirmed. Phase coverage (6 cuts → 4 phases), deploy-order soundness (single file, text anchors, non-overlapping sections), single-file manifest, and the global rule-preservation guardrail all verified. Phase-4 row reconciled to the amended C6 (Pattern-4 de-dup −200; Principle 2 / path-bullet rephrase deferred); per-phase Δ sum to −9,580.
