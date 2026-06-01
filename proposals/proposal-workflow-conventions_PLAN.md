# Implementation Plan (index): proposal-workflow-conventions

**Proposal:** proposals/proposal-workflow-conventions.md (validated 2026-05-30)
**Created:** 2026-05-30
**File operations:** 17 (EDIT: 17 — 15 canonical rows + 2 mandatory out-of-band edits; CREATE: 0, DELETE: 0, MOVE: 0)
**Decomposed:** this index + four phase files (`_PLAN_phase_1.md` … `_PLAN_phase_4.md`). Each phase file is validated independently and executed one at a time in deploy order.

> **Why decomposed:** ~50 locate/replace operations across 17 files would compact a single Phase-4 Haiku session (Principle 1, single-session sizing). Phases are grouped by cohesion, not hard deploy-ordering — every edit is plain text, so there is no compile dependency between phases. Recommended order is 1→2→3→4 (convention/foundation first, then consumers, then the script/persona/out-of-band edits), but any order is safe.

---

## Pre-execution checklist (whole plan)

- [ ] On a clean working tree.
- [ ] `proposals/proposal-workflow-conventions.md` carries its Phase 2 validation footer.
- [ ] **Branch:** `/f3-implement-update` creates the `proposal/proposal-workflow-conventions` branch (unnumbered — this proposal is grandfathered) from the base branch before any edits. **This is the convention this very proposal introduces (branch created at f3, not f1) — dogfood it.** Do not create a branch named with a number; this proposal lands unnumbered.
- [ ] All edits target **canonical sources only**. No `.claude/` path is ever edited. (Regen in Phase 5 / `/f4-regen-framework` propagates to `.claude/`.)
- [ ] Two of the 17 edits are **out-of-band** repo-root files (`../CLAUDE.md`, `../INFRASTRUCTURE.md`) — outside `shamt-core/` and not touched by regen, but mandatory in the same change (Phase 4 of this plan). `plan-executor` must apply them even though they are above the `shamt-core/` canonical roots; they are justified in the proposal's "Mandatory out-of-band edits" section + Validation Considerations.

---

## Files manifest (all 17 operations)

| # | Phase file | Path | Operation | Pair / note |
|---|-----------|------|-----------|-------------|
| 1 | phase_1 | `shamt-core/CLAUDE.md` | EDIT | rule ↔ template (with #2) |
| 2 | phase_1 | `shamt-core/proposals/_template.md` | EDIT | rule ↔ template (with #1) |
| 3 | phase_1 | `shamt-core/host/templates/claude/commands/f1-propose-update.md` | EDIT | command ↔ skill (with #4) |
| 4 | phase_1 | `shamt-core/host/templates/claude/skills/f1-propose-update/SKILL.md` | EDIT | command ↔ skill (with #3) |
| 5 | phase_2 | `shamt-core/host/templates/claude/commands/f2-plan-update-implementation.md` | EDIT | command ↔ skill (with #6) |
| 6 | phase_2 | `shamt-core/host/templates/claude/skills/f2-plan-update-implementation/SKILL.md` | EDIT | command ↔ skill (with #5) |
| 7 | phase_2 | `shamt-core/host/templates/claude/commands/f3-implement-update.md` | EDIT | command ↔ skill (with #8) |
| 8 | phase_2 | `shamt-core/host/templates/claude/skills/f3-implement-update/SKILL.md` | EDIT | command ↔ skill (with #7) |
| 9 | phase_3 | `shamt-core/host/templates/claude/commands/f6-archive-proposal.md` | EDIT | command ↔ skill (with #10) |
| 10 | phase_3 | `shamt-core/host/templates/claude/skills/f6-archive-proposal/SKILL.md` | EDIT | command ↔ skill (with #9) |
| 11 | phase_3 | `shamt-core/host/templates/claude/commands/sync-triage-proposals.md` | EDIT | command ↔ skill (with #12) |
| 12 | phase_3 | `shamt-core/host/templates/claude/skills/sync-triage-proposals/SKILL.md` | EDIT | command ↔ skill (with #11) |
| 13 | phase_4 | `shamt-core/CHEATSHEET.md` | EDIT | standalone doc |
| 14 | phase_4 | `shamt-core/import-shamt.sh` | EDIT | sync script |
| 15 | phase_4 | `shamt-core/host/templates/claude/agents/plan-executor.md` | EDIT | standalone persona (no skill) |
| OOB-1 | phase_4 | `../CLAUDE.md` (repo-root primer) | EDIT | out-of-band (not regen-touched) |
| OOB-2 | phase_4 | `../INFRASTRUCTURE.md` (planning doc) | EDIT | out-of-band (not regen-touched) |

---

## Canonical convention text (single source — keep these three renderings byte-aligned)

Three files state the convention and must agree (the proposal's Drift risk + Validation Considerations call this out as the highest D2/D7 exposure):

1. `shamt-core/CLAUDE.md` `## Conventions` section (Step 1.1, phase_1).
2. `shamt-core/proposals/_template.md` layout comment + `**Number:**` header (Step 1.2, phase_1).
3. The f1 number-assignment step (Step 1.3, phase_1).

The pinned facts they must all express identically:

- Number = two-digit zero-padded `NN`, `max(leading ^[0-9]+- run across proposals/, archive/, deferred/, rejected/) + 1`, first = `01`, widen to 3 digits past 99, unnumbered/grandfathered files ignored.
- Filename `proposals/{NN}-{slug}.md`; child-local + grandfathered stay `proposals/{slug}.md`.
- Branch `proposal/{NN}-{slug}` (or `proposal/{slug}`), created by `/f3-implement-update`, deleted by `/f6-archive-proposal`.
- Commit `shamt-core: land #NN {slug} (…)` (drop `#NN` when unnumbered).
- Master-only: number assigned at f1 (master-local) / sync-triage promote (child-submitted); children author unnumbered.

---

## Verification (post-execution, after all four phases)

- [ ] Every Proposed Changes row (1–15) + both out-of-band edits has a corresponding applied step. (Phase files map 1:1 — see each phase's cross-check.)
- [ ] No edit landed in any `.claude/` path: `git diff --name-only | grep -c '\.claude/'` returns `0`.
- [ ] No stray `framework-update/{slug}` remains anywhere in canonical sources: `grep -rn "framework-update/{slug}" shamt-core/host shamt-core/CLAUDE.md shamt-core/CHEATSHEET.md` returns nothing (the archived `proposals/archive/*_PLAN*.md` historical mentions are out of scope and may remain).
- [ ] `proposal/{NN}-{slug}` branch convention appears consistently in f2, f3, f6, and plan-executor: `grep -rln "proposal/{NN}-{slug}\|proposal/{slug}" shamt-core/host/templates/claude/commands/f2-plan-update-implementation.md shamt-core/host/templates/claude/commands/f3-implement-update.md shamt-core/host/templates/claude/commands/f6-archive-proposal.md shamt-core/host/templates/claude/agents/plan-executor.md` lists all four.
- [ ] The `## Conventions` section exists in `shamt-core/CLAUDE.md` and `## Commit conventions (TBD)` is gone: `grep -c "Commit conventions (TBD)" shamt-core/CLAUDE.md` returns `0`.
- [ ] `**Number:**` header present in `shamt-core/proposals/_template.md`.
- [ ] f6 model recommendation reads Balanced (Sonnet), not Cheap (Haiku), in both `commands/f6-archive-proposal.md` and `skills/f6-archive-proposal/SKILL.md`.
- [ ] Three convention renderings (CLAUDE.md / _template.md / f1 step) agree on the pinned facts above.
- [ ] Both out-of-band files reconciled: `grep -c "No fixed convention yet" ../CLAUDE.md` returns `0`; `grep -c "SHAMT-N numbering for proposals" ../INFRASTRUCTURE.md` returns `0`.
- [ ] Mermaid / link / reference targets in edited files still resolve (spot-check the `[Conventions](#conventions)` anchor in CLAUDE.md and any cross-doc links touched).

---

## Notes (for the executor)

- **Branch-shape dogfooding.** This proposal introduces "branch created at f3." When implementing *this* proposal via `/f3-implement-update`, create `proposal/proposal-workflow-conventions` (unnumbered) before editing — exactly the convention being landed. f6 will commit `shamt-core: land proposal-workflow-conventions (…)` (no `#NN`), squash-merge to the base branch, delete the branch.
- **Review Prevention Gate Mapping — N/A** at the framework altitude (review-prevention surfaces are story concepts; `plan-executor` Pre-flight Step 2 treats absence as N/A).
- **CODING_STANDARDS Compliance — N/A** at the framework altitude (project coding standards apply to project code, not canonical Shamt prose / templates / scripts).
- **Out-of-band edits (phase_4) are intentional.** `../CLAUDE.md` and `../INFRASTRUCTURE.md` live above `shamt-core/` and are NOT regen-managed; `plan-executor` must still apply them (the proposal's "Mandatory out-of-band edits" table authorizes them). They keep the three governance docs from self-contradicting after numbering lands.
- **Escalation triggers (halt + report to the architect):** any locate string that does not match exactly (file drifted since planning); any situation that would require a design decision (all design is settled in the proposal — if a step seems to need judgment, that is a plan defect, not a builder call); any edit whose target turns out to be under `.claude/`.
- **Re-baseline:** if a step is wrong, the architect patches the relevant phase file, re-runs `/validate-artifact` on it, and re-hands off — do not edit a phase file in place mid-execution without re-validation.
