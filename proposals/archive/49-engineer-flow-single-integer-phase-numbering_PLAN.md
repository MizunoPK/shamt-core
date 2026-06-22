# Implementation Plan: engineer-flow-single-integer-phase-numbering (INDEX)

**Proposal:** proposals/49-engineer-flow-single-integer-phase-numbering.md
**Created:** 2026-06-21
**File operations:** 71 across 7 phase files (CREATE: 2, EDIT: 54, DELETE: 4, MOVE: 11) — the file-level expansion of the proposal's 61 change-list rows (rolled-up rows 59–61 expand to their 13 constituent files). See the Files manifest below.
**Plan shape:** phase-decomposed — this index + 7 phase files (`_PLAN_phase_1a`, `_phase_1b`, `_phase_2`, `_phase_3`, `_phase_4`, `_phase_5`, `_phase_6`).

This is the largest cross-cutting change in the framework's history: the Engineer flow is rebuilt as a uniform single-integer `e1…e9` linear sequence (no `{n}b` suffixes), every stage made mandatory-for-completion, the Quick/Standard concept retired framework-wide (story path **and** the `validate-artifact` validation-rigor selector), and `manual_test_plan.md` renamed to `user_test_plan.md` with the agent-as-user plan becoming a mandatory artifact that Phase 6 executes. Proposal #50's PR-centric Review/Polish/Finalize tail (PR-open at Review, iterative pull-only Polish, `gh pr merge` Finalize, `/e-all` terminal at Review, the `## PR` tracker sections) is **preserved** — the renumber layers on top of #50, never reverting it.

## Renumber map (the single contract every phase applies)

| New | Stage | Was | #50 behavior to preserve |
|-----|-------|-----|--------------------------|
| e1 | Intake | e1-start-story | — |
| e2 | Spec | e2-define-spec (no Path selection; spec always full + context.md) | — |
| e3 | Plan | e3-plan-implementation (now mandatory; no Quick-skip) | — |
| e4 | Test Plan | **NEW** (merges e3b + e5b; user_test_plan always + testing_plan when suites exist) | — |
| e5 | Build | e4-execute-plan (plan-executor always; no inline Quick build) | — |
| e6 | Test | e5-execute-tests (user-simulator **executes** user_test_plan.md) | — |
| e7 | Review | e6-review-changes | **opens the PR when `pr_provider == github`** |
| e8 | Polish | e7-resolve-feedback (operator-initiated) | **iterative pull-only PR-comment loop + `addressed_feedback.md` ledger + push-as-response** |
| e9 | Finalize | e8-finalize-story (operator-initiated) | **`gh pr merge` + work-item close routing** |

`/e-all` drives `e1 → … → e7` (terminal at Review); Polish (`/e8`) + Finalize (`/e9`) stay operator-initiated. `manual_test_plan.md` → `user_test_plan.md` everywhere.

## Pre-execution checklist
- [ ] On a clean working tree (or a worktree dedicated to this proposal).
- [ ] `proposals/49-engineer-flow-single-integer-phase-numbering.md` validation footer present (it is — `Validated 2026-06-21`).
- [ ] Every phase file carries its own `Validated …` footer before `/f3-implement-update` runs (see "Validation handoff" below).
- [ ] Branch created by `/f3-implement-update`: `proposal/49-engineer-flow-single-integer-phase-numbering` from the base branch, immediately before the canonical edits.

## Phase files (run in this order)

`/f3-implement-update` hands the `plan-executor` builder one phase file at a time, in this order. Phase 1a must precede Phase 1b. The other phases are independent of one another but Phase 4 (SHAMT_RULES) **fixes the anchor names** that Phase 1a/1b's two inbound links target — if Phase 4 lands different heading text than the assumed anchors, those two link fragments must be corrected to match (see the anchor note in each affected phase file).

| Order | Phase file | Covers (proposal rows) | Surface |
|-------|-----------|------------------------|---------|
| 1 | `49-…_PLAN_phase_1a.md` | rows 1–6 | Engineer command bodies — e1/e2/e3 EDITs, e4-write-test-plan CREATE, e3b/e5b DELETEs |
| 2 | `49-…_PLAN_phase_1b.md` | rows 7–13 | Engineer command renames (5 MOVEs) + e-all + validate-artifact |
| 3 | `49-…_PLAN_phase_2.md` | rows 14–26 | Engineer skill dirs (5 MOVEs + e4 skill CREATE + e3b/e5b skill DELETEs + EDITs) |
| 4 | `49-…_PLAN_phase_3.md` | rows 27–30, 32–40 | Personas (4 EDITs) + templates (manual→user template MOVE + EDITs) — row 31 (SHAMT_RULES) is Phase 4 |
| 5 | `49-…_PLAN_phase_4.md` | row 31 | `templates/SHAMT_RULES.template.md` (Major — sets the new anchors) |
| 6 | `49-…_PLAN_phase_5.md` | rows 41–56 | References (incl. tracker #50-preservation renumbers) |
| 7 | `49-…_PLAN_phase_6.md` | rows 57–61 | Root docs (README, CLAUDE.md) + PO/framework-update command bodies (rolled-up rows 59–61 expanded one step per file) |

> **Sequencing note.** Phase 4 produces the SHAMT_RULES Test-Plan-section and Testing-section headings whose anchors Phase 1a (new `e4-write-test-plan.md` → `#testing-phase-6--required`) and Phase 1b (`validate-artifact.md` dimension row → `#test-plan-phase-4--required`) link to. Both phases were authored against those exact assumed anchors, and Phase 4 was authored to **produce** exactly those anchors, so the contract holds as written. If, when executing Phase 4, the builder produces heading text whose derived anchor differs from these assumed `#test-plan-phase-4--required` / `#testing-phase-6--required`, it must report the actual anchors so the Phase 1a/1b link fragments are corrected.

## Files manifest

One row per file operation. MOVEs are shown as a single row (decomposed into paired `git mv` + body-edit + DELETE-verification sub-steps inside the phase file).

| # | Path | Operation | Phase | Sibling / template (if any) |
|---|------|-----------|-------|------------------------------|
| 1 | `host/templates/claude/commands/e1-start-story.md` | EDIT | 1a | — |
| 2 | `host/templates/claude/commands/e2-define-spec.md` | EDIT | 1a | — |
| 3 | `host/templates/claude/commands/e3-plan-implementation.md` | EDIT | 1a | — |
| 4 | `host/templates/claude/commands/e4-write-test-plan.md` | CREATE | 1a | merge of e3b + e5b; shape mirrors e3-plan-implementation.md |
| 5 | `host/templates/claude/commands/e3b-write-testing-plan.md` | DELETE | 1a | — |
| 6 | `host/templates/claude/commands/e5b-write-manual-testing-plan.md` | DELETE | 1a | — |
| 7 | `host/templates/claude/commands/e4-execute-plan.md` → `e5-execute-plan.md` | MOVE | 1b | — |
| 8 | `host/templates/claude/commands/e5-execute-tests.md` → `e6-execute-tests.md` | MOVE | 1b | — |
| 9 | `host/templates/claude/commands/e6-review-changes.md` → `e7-review-changes.md` | MOVE | 1b | #50 PR-open preserved |
| 10 | `host/templates/claude/commands/e7-resolve-feedback.md` → `e8-resolve-feedback.md` | MOVE | 1b | #50 iterative pull-only loop preserved |
| 11 | `host/templates/claude/commands/e8-finalize-story.md` → `e9-finalize-story.md` | MOVE | 1b | #50 `gh pr merge` preserved |
| 12 | `host/templates/claude/commands/e-all.md` | EDIT | 1b | #50 terminal-at-Review preserved |
| 13 | `host/templates/claude/commands/validate-artifact.md` | EDIT | 1b | — |
| 14 | `host/templates/claude/skills/e1-start-story/SKILL.md` | EDIT | 2 | — |
| 15 | `host/templates/claude/skills/e2-define-spec/SKILL.md` | EDIT | 2 | — |
| 16 | `host/templates/claude/skills/e3-plan-implementation/SKILL.md` | EDIT | 2 | — |
| 17 | `host/templates/claude/skills/e3b-write-testing-plan/SKILL.md` | DELETE | 2 | — |
| 18 | `host/templates/claude/skills/e5b-write-manual-testing-plan/SKILL.md` | DELETE | 2 | — |
| 19 | `host/templates/claude/skills/e4-write-test-plan/SKILL.md` | CREATE | 2 | mirror of e3-plan-implementation/SKILL.md; Protocol = pointer |
| 20 | `host/templates/claude/skills/e4-execute-plan/` → `e5-execute-plan/SKILL.md` | MOVE | 2 | — |
| 21 | `host/templates/claude/skills/e5-execute-tests/` → `e6-execute-tests/SKILL.md` | MOVE | 2 | — |
| 22 | `host/templates/claude/skills/e6-review-changes/` → `e7-review-changes/SKILL.md` | MOVE | 2 | — |
| 23 | `host/templates/claude/skills/e7-resolve-feedback/` → `e8-resolve-feedback/SKILL.md` | MOVE | 2 | — |
| 24 | `host/templates/claude/skills/e8-finalize-story/` → `e9-finalize-story/SKILL.md` | MOVE | 2 | — |
| 25 | `host/templates/claude/skills/e-all/SKILL.md` | EDIT | 2 | #50 operator-driven wording preserved |
| 26 | `host/templates/claude/skills/validate-artifact/SKILL.md` | EDIT | 2 | — |
| 27 | `host/templates/claude/agents/user-simulator.md` | EDIT | 3 | rewrite to execute user_test_plan.md |
| 28 | `host/templates/claude/agents/test-executor.md` | EDIT | 3 | — |
| 29 | `host/templates/claude/agents/plan-executor.md` | EDIT | 3 | — |
| 30 | `host/templates/claude/agents/review-executor.md` | EDIT | 3 | confirming no-op (no Engineer `/e6`/Phase-6 ref; only FW-flow footer) |
| 31 | `templates/SHAMT_RULES.template.md` | EDIT | 4 | sets `#test-plan-phase-4--required` + `#testing-phase-6--required` |
| 32 | `templates/spec.template.md` | EDIT | 3 | — |
| 33 | `templates/context.template.md` | EDIT | 3 | — |
| 34 | `templates/implementation_plan.template.md` | EDIT | 3 | — |
| 35 | `templates/testing_plan.template.md` | EDIT | 3 | — |
| 36 | `templates/manual_test_plan.template.md` → `templates/user_test_plan.template.md` | MOVE | 3 | — |
| 37 | `templates/active_artifacts.template.md` | EDIT | 3 | — |
| 38 | `templates/code_review.template.md` | EDIT | 3 | — |
| 39 | `templates/agent_test_session.template.md` | EDIT | 3 | — |
| 40 | `templates/testing_standards.template.md` | EDIT | 3 | — |
| 41 | `reference/testing.md` | EDIT | 5 | — |
| 42 | `reference/model_selection.md` | EDIT | 5 | — |
| 43 | `reference/validation_exit_criteria.md` | EDIT | 5 | — |
| 44 | `reference/spec_protocol_reference.md` | EDIT | 5 | — |
| 45 | `reference/implementation_plan_reference.md` | EDIT | 5 | — |
| 46 | `reference/rebaseline_protocol.md` | EDIT | 5 | — |
| 47 | `reference/epic_status_board.md` | EDIT | 5 | — |
| 48 | `reference/audit_dimensions.md` | EDIT | 5 | — |
| 49 | `reference/pr_review_prevention.md` | EDIT | 5 | — |
| 50 | `reference/review_categories.md` | EDIT | 5 | — |
| 51 | `reference/batch_validation_handoff.md` | EDIT | 5 | — |
| 52 | `reference/mermaid_recipes.md` | EDIT | 5 | — |
| 53 | `reference/mermaid_diagram_standards.md` | EDIT | 5 | — |
| 54 | `reference/trackers/_contract.md` | EDIT | 5 | #50 `## PR` section defs preserved |
| 55 | `reference/trackers/ado.md` | EDIT | 5 | #50 `## PR` shapes + not-yet-wired notes preserved |
| 56 | `reference/trackers/github.md` | EDIT | 5 | #50 `## PR` command bodies preserved |
| 57 | `README.md` | EDIT | 6 | #50 e-all-stops-at-Review wording preserved |
| 58 | `CLAUDE.md` | EDIT | 6 | #50 PR detail preserved; must NOT revert to "e1→e9 driven" |
| 59 | `host/templates/claude/commands/pe2-validate.md` | EDIT | 6 | rolled-up row 59 (1/3) |
| 60 | `host/templates/claude/commands/pf2-validate.md` | EDIT | 6 | rolled-up row 59 (2/3) |
| 61 | `host/templates/claude/commands/ps2-validate.md` | EDIT | 6 | rolled-up row 59 (3/3) |
| 62 | `host/templates/claude/commands/f1-propose-update.md` | EDIT | 6 | rolled-up row 60 (1/5) |
| 63 | `host/templates/claude/commands/f2-plan-update-implementation.md` | EDIT | 6 | rolled-up row 60 (2/5) — confirming no-op (no QS/e3b/e5b residue) |
| 64 | `host/templates/claude/commands/f3-implement-update.md` | EDIT | 6 | rolled-up row 60 (3/5) |
| 65 | `host/templates/claude/commands/f5-audit-framework.md` | EDIT | 6 | rolled-up row 60 (4/5) |
| 66 | `host/templates/claude/commands/f-all.md` | EDIT | 6 | rolled-up row 60 (5/5) |
| 67 | `host/templates/claude/commands/pe3-decompose.md` | EDIT | 6 | rolled-up row 61 (1/5) |
| 68 | `host/templates/claude/commands/pe4-finalize.md` | EDIT | 6 | rolled-up row 61 (2/5) |
| 69 | `host/templates/claude/commands/pf3-decompose.md` | EDIT | 6 | rolled-up row 61 (3/5) |
| 70 | `host/templates/claude/commands/ps0-draft.md` | EDIT | 6 | rolled-up row 61 (4/5) |
| 71 | `host/templates/claude/commands/ps1-define.md` | EDIT | 6 | rolled-up row 61 (5/5) — confirming no-op (only `/e1` refs) |

> `reference/trackers/local.md` is intentionally **not** in the manifest — it has no Engineer-phase references (proposal row 56 parenthetical). Confirmed no-op rows (30, 63, 71, and the CLAUDE.md Validation-expectations line) carry a zero-match grep verification in their phase file rather than an edit, with the no-op stated explicitly.

The manifest lists 71 file-operation rows (the proposal's 61 change-list entries, with rolled-up rows 59–61 expanded to their 13 constituent files: row 59 → 3 PO-validate commands, row 60 → 5 framework-update commands, row 61 → 5 PO-decompose/draft commands; 61 − 3 + 13 = 71). Counting by operation: **CREATE 2, EDIT 54, DELETE 4, MOVE 11** = 71 file-ops, matching the metadata header above. (At the *proposal-table-row* level the tally is CREATE 2, EDIT 44, DELETE 4, MOVE 11 = 61 rows; the EDIT delta — 44 → 54 — is the +10 EDIT rows from expanding rows 59–61's 13 files, which are all EDITs, minus the 3 collapsed rolled-up rows.)

## Verification (post-execution, whole plan)

<!-- Whole-plan / cross-phase invariants — run by the architect at /f3-implement-update post-build (Step 3), never by the builder. These depend on more than one phase's output, so no single phase file can own them. -->

**Coverage + operation match**
- [ ] Every Proposed Changes row (1–61, with 59–61 expanded to their files) maps to at least one plan step; every plan step traces back to a row. (Manifest above is the row↔file↔phase trace.)
- [ ] Every CREATE file exists: `test -f host/templates/claude/commands/e4-write-test-plan.md && test -f host/templates/claude/skills/e4-write-test-plan/SKILL.md`.
- [ ] Every MOVE's old path is gone and new path exists (11 MOVEs):
  - `for p in commands/e5-execute-plan.md commands/e6-execute-tests.md commands/e7-review-changes.md commands/e8-resolve-feedback.md commands/e9-finalize-story.md; do test -f host/templates/claude/$p || echo "MISSING $p"; done`
  - `for d in e5-execute-plan e6-execute-tests e7-review-changes e8-resolve-feedback e9-finalize-story; do test -f host/templates/claude/skills/$d/SKILL.md || echo "MISSING skill $d"; done`
  - `test -f templates/user_test_plan.template.md`
  - Old paths gone: `for p in commands/e4-execute-plan.md commands/e5-execute-tests.md commands/e6-review-changes.md commands/e7-resolve-feedback.md commands/e8-finalize-story.md commands/e3b-write-testing-plan.md commands/e5b-write-manual-testing-plan.md; do test ! -f host/templates/claude/$p || echo "STILL PRESENT $p"; done`
  - `test ! -d host/templates/claude/skills/e4-execute-plan && test ! -d host/templates/claude/skills/e5-execute-tests && test ! -d host/templates/claude/skills/e6-review-changes && test ! -d host/templates/claude/skills/e7-resolve-feedback && test ! -d host/templates/claude/skills/e8-finalize-story && test ! -d host/templates/claude/skills/e3b-write-testing-plan && test ! -d host/templates/claude/skills/e5b-write-manual-testing-plan`
  - `test ! -f templates/manual_test_plan.template.md`

**Zero-residual sweeps (D7 terminology + D2 consistency)** — these are the proposal's "prove zero residual references" greps. Run across the whole canonical tree (excluding `proposals/` archives):
- [ ] `grep -rnE 'Quick path|Standard path|Quick-path|Standard-path' templates/ reference/ host/templates/claude/ README.md CLAUDE.md` returns **0** matches. (Historical archive proposals under `proposals/` are out of scope.)
- [ ] `grep -rnE '/e3b|/e5b|e3b-write|e5b-write' templates/ reference/ host/templates/claude/ README.md CLAUDE.md` returns **0** matches.
- [ ] `grep -rnE 'manual_test_plan|manual-test-plan|Manual Test Plan' templates/ reference/ host/templates/claude/ README.md CLAUDE.md` returns **0** matches.
- [ ] `grep -rnE '/e4-execute-plan|/e5-execute-tests|/e6-review-changes|/e7-resolve-feedback|/e8-finalize-story' templates/ reference/ host/templates/claude/ README.md CLAUDE.md` returns **0** matches (no dangling old-numbered command pointer survives). Note `/e1`–`/e3` keep their names; only the renamed commands are swept.
- [ ] `grep -rn 'optional-post-build-artifact' templates/ reference/ host/templates/claude/ README.md CLAUDE.md` returns **0** matches (the retired anchor; every inbound link repointed).

**Anchor-link validity (D4)** — the two anchors Phase 4 produced must be the targets the Phase 1a/1b links use:
- [ ] `grep -n '#test-plan-phase-4--required\|#testing-phase-6--required' templates/SHAMT_RULES.template.md` shows both headings exist (i.e. the link targets resolve). If Phase 4 used different heading text, confirm Phase 1a (`e4-write-test-plan.md`) and Phase 1b (`validate-artifact.md`) link fragments were corrected to the actual anchors.
- [ ] Every other Markdown link/reference target in edited files still resolves (spot-check the edited references' cross-links).

**#50-preservation (re-base verification)** — the renamed/edited #50 surfaces must retain #50's behavior:
- [ ] `grep -F 'pr_provider' host/templates/claude/commands/e7-review-changes.md` ≥ 1 (PR-open at Review survives).
- [ ] `grep -F 'addressed_feedback' host/templates/claude/commands/e8-resolve-feedback.md` ≥ 1 (iterative pull-only ledger survives).
- [ ] `grep -F 'gh pr merge' host/templates/claude/commands/e9-finalize-story.md` ≥ 1 (`gh pr merge` finalize survives).
- [ ] `grep -nE '## PR create|## PR comment fetch|## PR merge|## PR comment posting' reference/trackers/_contract.md reference/trackers/github.md reference/trackers/ado.md` shows the `## PR` sections survive in each tracker.
- [ ] `/e-all` is terminal at Review: `grep -F 'e7' host/templates/claude/commands/e-all.md` shows the chain ends at `/e7` (Review); CLAUDE.md `/e-all` reconciliation paragraph still ends at `/e7` (NOT rewritten "e1→e9 driven").
- [ ] `git diff <base> -- host/templates/claude/commands/e7-review-changes.md host/templates/claude/commands/e8-resolve-feedback.md host/templates/claude/commands/e9-finalize-story.md host/templates/claude/commands/e-all.md` shows **only** renumber + Quick/Standard-removal + manual→user deltas — no #50 logic deleted or garbled.

**No generated-file leakage**
- [ ] No edits landed in generated `.claude/` paths: `git diff --name-only <base> | grep '^\.claude/'` returns nothing (regen, framework-update Phase 5, owns `.claude/`).
- [ ] `grep -rn "Managed by Shamt" host/templates/claude/` returns the expected footer count. Baseline before this plan was 87 across `host/templates/claude/`; net change = **+2** (new `e4-write-test-plan.md` command footer + new `e4-write-test-plan/SKILL.md` footer) **−2** (deleted `e3b`/`e5b` command footers) **−2** (deleted `e3b`/`e5b` skill footers) **= 85** (the 11 MOVEs keep their footers, repointing the `Regenerate from …` path). Expect **85**. (Confirm the arithmetic against the actual baseline at `/f3` time — parallel work may have shifted it.)

**SKILL pointer discipline (D2)**
- [ ] Each renamed/created SKILL.md `## Protocol` is a **pointer** to its command body, not a paraphrase: `grep -A2 '## Protocol' host/templates/claude/skills/e4-write-test-plan/SKILL.md` shows a single `commands/e4-write-test-plan.md` pointer; spot-check the 5 renamed skills point at their renamed command.

## Validation handoff (Phase 3 → /validate-artifact)

This is a phase-decomposed plan: the index plus 7 phase files. That is **8 validations** (index under the phase-index dimensions; each phase file under the plan dimensions). The **recommended** path is the batch-validation handoff (one fresh orchestrator session); the **fallback** is sequential per-file. Both run the same Pattern 1 loop per file — no rigor difference.

### Recommended — batch-validation handoff prompt (paste into a fresh session)

```text
You are the batch-validation orchestrator. Validate each artifact below by
fanning out to sub-agents — do NOT read the artifact bodies into your own
context. Hold only this manifest and each sub-agent's short verdict.

Artifacts to validate:
  1. proposals/49-engineer-flow-single-integer-phase-numbering_PLAN.md          — governing references: host/templates/claude/commands/f2-plan-update-implementation.md (phase-index shape), reference/batch_validation_handoff.md, the proposal proposals/49-engineer-flow-single-integer-phase-numbering.md
  2. proposals/49-engineer-flow-single-integer-phase-numbering_PLAN_phase_1a.md — governing references: templates/implementation_plan.template.md, reference/implementation_plan_reference.md, host/templates/claude/commands/f2-plan-update-implementation.md, the proposal (rows 1–6)
  3. proposals/49-engineer-flow-single-integer-phase-numbering_PLAN_phase_1b.md — governing references: same plan refs, the proposal (rows 7–13), #50 commit ca37b5e for preservation
  4. proposals/49-engineer-flow-single-integer-phase-numbering_PLAN_phase_2.md  — governing references: same plan refs, the proposal (rows 14–26)
  5. proposals/49-engineer-flow-single-integer-phase-numbering_PLAN_phase_3.md  — governing references: same plan refs, the proposal (rows 27–40)
  6. proposals/49-engineer-flow-single-integer-phase-numbering_PLAN_phase_4.md  — governing references: same plan refs, the proposal (row 31), templates/SHAMT_RULES.template.md
  7. proposals/49-engineer-flow-single-integer-phase-numbering_PLAN_phase_5.md  — governing references: same plan refs, the proposal (rows 41–56), #50 commit ca37b5e for tracker preservation
  8. proposals/49-engineer-flow-single-integer-phase-numbering_PLAN_phase_6.md  — governing references: same plan refs, the proposal (rows 57–61), #50 commit ca37b5e for README/CLAUDE preservation

For EACH artifact, in order:

  A. Spawn a primary validation sub-agent (Reasoning tier) with these instructions:
       - Run the Pattern 1 primary loop, Steps 1–6 of /validate-artifact, on {path}.
         Pick the dimension set for this artifact type (implementation plan / phase-index).
         Re-read fresh each round; classify severity per Pattern 2; fix every issue in place.
       - HALT after Step 6 at consecutive_clean = 1. Do NOT spawn a checker.
         Do NOT invoke the /validate-artifact command itself. Return a short verdict.

  B. YOU (the orchestrator) spawn the validation-checker persona (Haiku) for {path},
     with its dimension list and governing references. The checker re-reads cold and
     reports ANY issue (no one-LOW allowance). On any finding: re-spawn a fresh primary
     for {path} (Step A), then re-run the checker. Repeat until the checker replies
     "CONFIRMED: Zero issues found after adversarial review." Then stamp the footer
     `Validated YYYY-MM-DD — N rounds, 1 adversarial sub-agent confirmed`.

After every artifact exits clean, report an aggregate: per artifact, the path taken and clean/needs-work status.
```

### Fallback — sequential per-file

```text
/clear
/validate-artifact proposals/49-engineer-flow-single-integer-phase-numbering_PLAN.md
/clear
/validate-artifact proposals/49-engineer-flow-single-integer-phase-numbering_PLAN_phase_1a.md
/clear
/validate-artifact proposals/49-engineer-flow-single-integer-phase-numbering_PLAN_phase_1b.md
/clear
/validate-artifact proposals/49-engineer-flow-single-integer-phase-numbering_PLAN_phase_2.md
/clear
/validate-artifact proposals/49-engineer-flow-single-integer-phase-numbering_PLAN_phase_3.md
/clear
/validate-artifact proposals/49-engineer-flow-single-integer-phase-numbering_PLAN_phase_4.md
/clear
/validate-artifact proposals/49-engineer-flow-single-integer-phase-numbering_PLAN_phase_5.md
/clear
/validate-artifact proposals/49-engineer-flow-single-integer-phase-numbering_PLAN_phase_6.md
```

## Notes

- **Fresh-agent runnable.** The proposal (footered) and every canonical file cited in the manifest live on disk; no conversation history is required to execute any phase.
- **Plan-executor reuse.** `/f3-implement-update` hands each phase file to the same `plan-executor` builder persona used for story-level Build. Review-Prevention Gate Mapping and CODING_STANDARDS Compliance mapping are **omitted** (framework-altitude, N/A) per the `/f2` contract — the builder treats both as N/A.
- **Phase 4 fixes the anchors.** Phases 1a and 1b were authored against the assumed anchors `#testing-phase-6--required` and `#test-plan-phase-4--required`; Phase 4 was authored to produce exactly those. If a builder diverges, the cross-phase invariant in the post-execution Anchor-link section catches it.
- **#50 is preserved, not reverted.** Disk-authoritative cross-session rule applies: #50 landed in parallel (commit `ca37b5e`); every renamed/edited #50 surface carries an explicit survival grep. Treat any drop in a #50-marker count as a plan defect, not a "stale" artifact to remove.
- **Re-baseline.** If Phase 4 (the framework-update build phase) reports a plan defect, patch the affected phase file, re-run `/validate-artifact` on it, then re-invoke `/f3-implement-update`. Do not edit a phase file in place mid-execution without re-validating.

---
Validated 2026-06-21 — 2 rounds, 1 adversarial sub-agent confirmed
