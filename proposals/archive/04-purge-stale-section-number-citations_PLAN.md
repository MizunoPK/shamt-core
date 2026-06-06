# Implementation Plan (index) — purge-stale-section-number-citations (#04)

**Created:** 2026-06-06
**Proposal:** `proposals/04-purge-stale-section-number-citations.md` (Validated 2026-06-06)
**Altitude:** Framework-update (Part 3). Executor: `plan-executor` (Haiku) via `/f3-implement-update` architect/builder path, **one phase file at a time in deploy order**.
**Base branch:** `main`

This is a **phase-decomposed** plan: this index + 5 phase files. It abolishes all **71 dangling `§N.N` citations across 35 files** (relics of the deleted INFRASTRUCTURE.md), re-pointing each to its v2 named home or deleting it where a named reference / inline statement co-exists, per the proposal's §-token resolution table.

---

## Pre-Execution Checklist

- [ ] **Proposal branch** `proposal/04-purge-stale-section-number-citations` created from `main` (the first phase handed off creates it; halt if it already exists).
- [ ] All 35 affected files exist on disk (verified at plan time).
- [ ] **Hard rule:** edits target canonical sources only — **never** `.claude/`. Every path is under `host/templates/claude/`, `templates/`, `reference/`, or a root doc (`CHEATSHEET.md`). (No `.claude/` appears as an edit target in any phase file — confirmed.)
- [ ] Review-Prevention Gate Mapping: **N/A** (documentation-prose edits only).
- [ ] This index **and all 5 phase files** carry their own Phase-2 validation footer before `/f3` executes.

---

## Phases (deploy order — phases are independent; any order is safe)

| Phase | File | Area | Files | §-occurrences |
|-------|------|------|-------|---------------|
| 1 | `04-purge-stale-section-number-citations_PLAN_phase_1.md` | PO flow (`p1`–`p4` commands + `p2`/`p3`/`p4` skills) | 7 | 24 |
| 2 | `04-purge-stale-section-number-citations_PLAN_phase_2.md` | Engineer flow (`e5`,`e5b`,`e6`,`e7` cmd+skill, `test-executor`) | 9 | 15 |
| 3 | `04-purge-stale-section-number-citations_PLAN_phase_3.md` | framework-update / audit (`f5`, `f6` cmd+skill) | 3 | 4 |
| 4 | `04-purge-stale-section-number-citations_PLAN_phase_4.md` | sync (`sync-import`/`sync-submit` cmd+skill, `sync-triage` skill) | 5 | 11 |
| 5 | `04-purge-stale-section-number-citations_PLAN_phase_5.md` | templates + references + `CHEATSHEET.md` | 11 | 17 |

**Totals: 35 files, 71 occurrences** (matches the proposal's 35-row Proposed Changes and the HEAD grep `grep -roE "§[0-9]+\.[0-9]+"` = 71). Occurrence counts exceed Locate-step counts where one line carries two tokens (e.g. f5 `(§3.6 / §3.9)`, sync `per §4.3 / §4.4` and `per §4.4 / §4.8`) — a single edit clears both.

## Cross-phase dependencies

**None.** Each phase edits a disjoint set of files; no phase depends on another's output. The `plan-executor` still runs them one at a time in deploy order (Phase N+1 only after Phase N reports `All steps completed. Verification passed.`), per the architect/builder contract.

**Cross-phase consistency note (not a dependency):** the `§1.15` model-tier citations reproduced verbatim in `e5b-*` (Phase 2) and the source cell in `reference/model_selection.md` (Phase 5) are both re-pointed to "the manual-test-plan rule" so the quoted reproductions stay consistent — already encoded identically in both phase files.

---

## Files Touched (manifest — all EDIT)

Phase 1: `host/templates/claude/commands/{p1-start-epic,p2-decompose-epic,p3-start-feature,p4-decompose-feature}.md`, `host/templates/claude/skills/{p2-decompose-epic,p3-start-feature,p4-decompose-feature}/SKILL.md`
Phase 2: `host/templates/claude/commands/{e5-execute-tests,e5b-write-manual-testing-plan,e6-review-changes,e7-resolve-feedback}.md`, `host/templates/claude/agents/test-executor.md`, `host/templates/claude/skills/{e5-execute-tests,e5b-write-manual-testing-plan,e6-review-changes,e7-resolve-feedback}/SKILL.md`
Phase 3: `host/templates/claude/commands/{f5-audit-framework,f6-archive-proposal}.md`, `host/templates/claude/skills/f6-archive-proposal/SKILL.md`
Phase 4: `host/templates/claude/commands/{sync-import-shamt,sync-submit-proposal}.md`, `host/templates/claude/skills/{sync-import-shamt,sync-submit-proposal,sync-triage-proposals}/SKILL.md`
Phase 5: `templates/{architecture,coding_standards,epic,feature,testing_plan}.template.md`, `reference/model_selection.md`, `reference/trackers/{_contract,ado,github,local}.md`, `CHEATSHEET.md`

No optional rows. If a path is not in a phase file's manifest, it must not be edited.

---

## Final verification (after all 5 phases)

Run the proposal's mandated completeness grep across the whole canonical surface:

```
grep -rnE "§[0-9]+\.[0-9]+" host/templates/claude/ templates/ reference/ CHEATSHEET.md
```

**Expected: zero results.** (`§N.N` tokens never appear in validation footers, so no exclusion filter is needed — unlike the dev-build-phase purge.) Any remaining hit = an uncovered citation; halt and report.

---

## Propagation & commit

- The 24 `host/templates/claude/` files (Phases 1–4 + Phase 5 has none under host) regenerate into `.claude/` via `/f4-regen-framework` (Phase 5 of the flow). The Phase-5-of-this-plan files (`templates/`, `reference/`, `CHEATSHEET.md`) are **not** regenerated and won't appear in the `--check` diff.
- **No commit during Phase 4 (build).** The commit + squash-merge land at `/f6-archive-proposal`.

## Notes

- Every edit is a textual deletion / re-point / rephrase in documentation prose; no executable instruction, step ordering, or heading body changes (a few `##`/`####` headings lose a parenthetical label only).
- Per-site tokens (`§1.12`, `§1.14`, `§1.15`, `§2.1`, `§4.x`) were resolved per-occurrence in the phase files against each citation's actual sentence (see the proposal's §-resolution table + classification).

## CODING_STANDARDS Compliance

N/A — documentation-prose edits to canonical framework sources; no project `CODING_STANDARDS.md` applies at the framework-update altitude.

---

## Open Questions

(none — every phase step is mechanical with an exact locate + replacement)

---
[Append the validation footer only after Pattern 1 completes for this index. Each phase file carries its own footer.]

---
Validated 2026-06-06 — 1 round, 1 adversarial sub-agent confirmed (batch validation; validation-checker independently verified all locate strings exact + unique against HEAD, replacements clean, and per-file §-coverage → 0)
