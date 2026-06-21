# Proposal: engineer-flow-single-integer-phase-numbering

**Created:** 2026-06-21
**Status:** Draft
**Number:** 49
**Proposed by:**
**Project context:**

---

## Problem

The Engineer flow advertises a clean phase sequence (1. Intake → 8. Finalize) but two of its commands carry a `b` suffix — `/e3b-write-testing-plan` and `/e5b-write-manual-testing-plan` — instead of single-integer phase numbers. The `README.md` Engineer-flow table (lines 86–96) lists them out of sequence ("3 sub-phase (automated suites present)", "Post-Build (optional)"), wedged around the numbered phases. A reader cannot tell from `e3b`/`e5b` where they sit in the flow, whether they always run, or how they relate to their numeric parent. The user reports this `{n}b` form as the specific source of confusion.

The naming reflects a deeper design fact: large parts of the Engineer flow are **conditional**, not unconditional steps, governed by a pervasive **Quick path / Standard path** classification:

- `/e3-plan-implementation` runs on the **Standard path only** (Quick path skips planning and builds inline) — `README.md` line 88.
- `/e3b-write-testing-plan` **no-ops** when `TESTING_STANDARDS.md` declares no automated suites (`host/templates/claude/commands/e3b-write-testing-plan.md` Prerequisites / Notes); it is auto-invoked by `/e3`.
- `/e5b-write-manual-testing-plan` is **optional, orthogonal** to the required Phase-5 agent-as-user run — a human walkthrough that the Phase-5 `user-simulator` does not even read (the simulator improvises from `TESTING_STANDARDS.md` instead — `host/templates/claude/commands/e5-execute-tests.md` Step 0). The manual-plan artifact is therefore **disconnected** from execution.
- The **Quick/Standard** split also drives validation rigor (`validate-artifact`: Quick = single primary pass; Standard / risk-triggered = + adversarial Haiku sub-agent — `reference/validation_exit_criteria.md`), whether a `context.md` is produced, Gate 3 plan approval, inline-vs-full test checklists, and the architect/builder split. The same Quick/Standard validation-rigor selector is reused **framework-wide** — by PO validations (`/pe2`/`/pf2`/`/ps2`), and by the framework-update flow's own proposal/plan validations (`/f1`, `/f2`, `/f3`, `/f-all`).

The user wants the Engineer flow rebuilt as a clean, uniform, fully-mandatory `e1…e9` linear sequence with single-integer phase numbers, and the Quick/Standard concept retired **everywhere** (including the validation-rigor selector — all validation becomes uniform: one primary clean round + one adversarial sub-agent, always). The user further wants the testing architecture restructured to fix the disconnect above: the agent-as-user test plan becomes a **mandatory** planning artifact that the Phase-6 agent-as-user execution actually **runs** after the build (rather than improvising). Because "manual" is a misnomer once the agent executes it, `manual_test_plan.md` is renamed to `user_test_plan.md`.

This is a large, framework-wide change (~55 canonical files) — far over the 10-file-op threshold, so **Phase 3 (`/f2-plan-update-implementation`) is required** before implementation. The Proposed Changes table below is the authoritative scope; the Phase 3 plan decomposes it into exact, locate-string-anchored steps (and decomposes each MOVE into its paired CREATE + DELETE).

### Target flow (resolved via the Open Questions dialog)

```
e1  Intake          (was e1, unchanged)
e2  Spec            (was e2; no Path selection — spec always full + context.md)
e3  Plan            (was e3; now MANDATORY for every story — Quick path retired)
e4  Test Plan       (NEW — merges e3b + e5b; MANDATORY)
      · user_test_plan.md (agent-as-user scenarios) — always
      · testing_plan.md (automated) — when TESTING_STANDARDS.md declares suites
e5  Build           (was e4-execute-plan; plan-executor always — no inline Quick build)
e6  Test            (was e5-execute-tests; MANDATORY; blocks until green)
      · user-simulator EXECUTES user_test_plan.md
      · test-executor executes testing_plan.md (when suites exist)
e7  Review          (was e6-review-changes)
e8  Polish          (was e7-resolve-feedback)
e9  Finalize        (was e8-finalize-story)
```

The one remaining genuine conditional is **internal to e4**: the automated `testing_plan.md` is physically impossible without a test framework, so it is produced only when `TESTING_STANDARDS.md` declares suites. This is a sub-part of a mandatory stage, not a skipped stage — the `user_test_plan.md` is always produced, so **e4 always runs**.

---

## Proposed Changes

Grouped by surface; numbering is continuous. Every MOVE = `git mv` of the canonical source + body renumber/rewrite (Phase 3 decomposes each into paired CREATE + DELETE rows per path discipline). Generated `.claude/` files are never listed — `/f4-regen-framework` propagates (the rename is a delete-old + create-new on the `.claude/` side; deletion-propagation per proposal #47).

### Engineer command bodies — `host/templates/claude/commands/`

| # | Canonical path | Operation | One-line change description |
|---|----------------|-----------|------------------------------|
| 1 | `host/templates/claude/commands/e1-start-story.md` | EDIT | Remove any Quick/Standard path-setting; update the "next phase" pointer to `/e2`; renumber downstream phase mentions. |
| 2 | `host/templates/claude/commands/e2-define-spec.md` | EDIT | Remove the `Path:` Quick/Standard selection step; spec is always full + `context.md` always produced; keep Gate 2a/2b but drop path branching; next-phase → `/e3`. |
| 3 | `host/templates/claude/commands/e3-plan-implementation.md` | EDIT | Make Plan mandatory for every story (remove Standard-only gating + Quick-path skip); remove the auto-invoke of `/e3b` (testing-plan authoring moves to the new `/e4`); next-phase → `/e4-write-test-plan`. |
| 4 | `host/templates/claude/commands/e4-write-test-plan.md` | CREATE | NEW merged "Test Plan" command (Phase 4, mandatory): authors `user_test_plan.md` always (agent-as-user scenarios) and `testing_plan.md` when `TESTING_STANDARDS.md` declares suites; runs the open-questions dialog + validation on each; next-phase → `/e5`. Folds in the surviving logic of e3b + e5b. |
| 5 | `host/templates/claude/commands/e3b-write-testing-plan.md` | DELETE | Merged into `/e4-write-test-plan` (automated-plan branch). |
| 6 | `host/templates/claude/commands/e5b-write-manual-testing-plan.md` | DELETE | Merged into `/e4-write-test-plan` (agent-as-user-plan branch) + executed by `/e6` (renamed artifact `user_test_plan.md`). |
| 7 | `host/templates/claude/commands/e4-execute-plan.md` | MOVE | → `host/templates/claude/commands/e5-execute-plan.md`. Renumber to Phase 5 (Build); remove Quick-path inline build — `plan-executor` always runs; next-phase → `/e6`. |
| 8 | `host/templates/claude/commands/e5-execute-tests.md` | MOVE | → `host/templates/claude/commands/e6-execute-tests.md`. Renumber to Phase 6; Step 0 `user-simulator` now **executes `user_test_plan.md`** instead of improvising from `TESTING_STANDARDS.md`; remove Quick/Standard branches; route failures to `/e8`; next-phase → `/e7`. |
| 9 | `host/templates/claude/commands/e6-review-changes.md` | MOVE | → `host/templates/claude/commands/e7-review-changes.md`. Renumber to Phase 7; remove Quick/Standard; next-phase → `/e8`. |
| 10 | `host/templates/claude/commands/e7-resolve-feedback.md` | MOVE | → `host/templates/claude/commands/e8-resolve-feedback.md`. Renumber to Phase 8; update inbound routing refs from `/e6`/`/e7`; next-phase → `/e9`. |
| 11 | `host/templates/claude/commands/e8-finalize-story.md` | MOVE | → `host/templates/claude/commands/e9-finalize-story.md`. Renumber to Phase 9; remove Quick/Standard. |
| 12 | `host/templates/claude/commands/e-all.md` | EDIT | Rewrite the dispatch chain to `e1 → e2 → e3 → e4 → e5 → e6 → e7 → e8 → e9` (all mandatory); drop optional `/e3`+`/e3b` / Quick-Standard branches; merged e4; `user_test_plan` references; renumber gate set. |
| 13 | `host/templates/claude/commands/validate-artifact.md` | EDIT | Retire the Quick/Standard validation-rigor selector — uniform exit: one primary clean round + one adversarial Haiku sub-agent, always; remove the "Quick = single pass / one-LOW allowance" branch; update `manual_test_plan` → `user_test_plan` in the artifact-type list. |

### Engineer skill dirs — `host/templates/claude/skills/{name}/SKILL.md`

| # | Canonical path | Operation | One-line change description |
|---|----------------|-----------|------------------------------|
| 14 | `host/templates/claude/skills/e1-start-story/SKILL.md` | EDIT | Update frontmatter `description` + Exit criteria for the renumbered next-phase; Protocol pointer unchanged in form. |
| 15 | `host/templates/claude/skills/e2-define-spec/SKILL.md` | EDIT | Update `description` (no path selection; context always); renumber. |
| 16 | `host/templates/claude/skills/e3-plan-implementation/SKILL.md` | EDIT | Update `description` (mandatory plan; no Quick/Standard); renumber. |
| 17 | `host/templates/claude/skills/e3b-write-testing-plan/SKILL.md` | DELETE | Skill for the deleted `/e3b` command. |
| 18 | `host/templates/claude/skills/e5b-write-manual-testing-plan/SKILL.md` | DELETE | Skill for the deleted `/e5b` command. |
| 19 | `host/templates/claude/skills/e4-write-test-plan/SKILL.md` | CREATE | NEW skill for the merged `/e4-write-test-plan` (Protocol = pointer to `commands/e4-write-test-plan.md`; description = mandatory dual test-plan authoring). |
| 20 | `host/templates/claude/skills/e4-execute-plan/SKILL.md` | MOVE | → `host/templates/claude/skills/e5-execute-plan/SKILL.md`; update `description` + pointer target to `e5-execute-plan`. |
| 21 | `host/templates/claude/skills/e5-execute-tests/SKILL.md` | MOVE | → `host/templates/claude/skills/e6-execute-tests/SKILL.md`; update `description` (executes user_test_plan) + pointer target. |
| 22 | `host/templates/claude/skills/e6-review-changes/SKILL.md` | MOVE | → `host/templates/claude/skills/e7-review-changes/SKILL.md`; update `description` + pointer target. |
| 23 | `host/templates/claude/skills/e7-resolve-feedback/SKILL.md` | MOVE | → `host/templates/claude/skills/e8-resolve-feedback/SKILL.md`; update `description` + pointer target. |
| 24 | `host/templates/claude/skills/e8-finalize-story/SKILL.md` | MOVE | → `host/templates/claude/skills/e9-finalize-story/SKILL.md`; update `description` + pointer target. |
| 25 | `host/templates/claude/skills/e-all/SKILL.md` | EDIT | Update `description` for the e1→e9 chain + merged e4 + no Quick/Standard. |
| 26 | `host/templates/claude/skills/validate-artifact/SKILL.md` | EDIT | Update `description` for uniform validation (no Quick/Standard rigor selector). |

### Personas — `host/templates/claude/agents/`

| # | Canonical path | Operation | One-line change description |
|---|----------------|-----------|------------------------------|
| 27 | `host/templates/claude/agents/user-simulator.md` | EDIT | Rewrite to **execute `user_test_plan.md` scenarios** (read the plan, perform each step, log PASS/FAIL/HALT) rather than improvise from `TESTING_STANDARDS.md` (kept as conventions input); renumber Phase 5 → Phase 6. |
| 28 | `host/templates/claude/agents/test-executor.md` | EDIT | Renumber Phase 5 → Phase 6 + `/e5`→`/e6`; remove Quick/Standard; `manual`→`user` plan references. |
| 29 | `host/templates/claude/agents/plan-executor.md` | EDIT | Build always runs via plan-executor (remove Quick-path inline-build framing); renumber Phase 4 → Phase 5 + `/e4`→`/e5`. |
| 30 | `host/templates/claude/agents/review-executor.md` | EDIT | Renumber Phase 6 → Phase 7 + `/e6`→`/e7`. |

### Templates — `templates/`

| # | Canonical path | Operation | One-line change description |
|---|----------------|-----------|------------------------------|
| 31 | `templates/SHAMT_RULES.template.md` | EDIT | Major: renumber the Engineer-flow phase narratives to e1–e9; add the merged Phase-4 Test Plan stage; mark all stages mandatory; **remove Quick/Standard everywhere** (story-path + validation rigor → uniform Pattern 1: primary clean + adversarial sub-agent, always); update gates, re-baseline, Testing phase, `user_test_plan` naming. Net likely a size reduction (D12-favorable). |
| 32 | `templates/spec.template.md` | EDIT | Remove the `Path:` (Quick/Standard) header and the `### Quick path inline test checklist`; spec is always full. |
| 33 | `templates/context.template.md` | EDIT | Context is always produced (remove Quick/Standard "Standard-only" framing). |
| 34 | `templates/implementation_plan.template.md` | EDIT | Remove Quick/Standard conditionals; plan always produced. |
| 35 | `templates/testing_plan.template.md` | EDIT | Remove Quick/Standard; update cross-refs to the merged `/e4` + `user_test_plan`. |
| 36 | `templates/manual_test_plan.template.md` | MOVE | → `templates/user_test_plan.template.md`. Reframe from human walkthrough to **agent-as-user-executable** scenario plan; mandatory; remove Quick/Standard; add a Results/execution-log section the `user-simulator` populates in e6. |
| 37 | `templates/active_artifacts.template.md` | EDIT | Rename the `Manual Test Plan` row → `User Test Plan` (`user_test_plan.md` / `_vN`); remove Quick/Standard. |
| 38 | `templates/code_review.template.md` | EDIT | Remove Quick/Standard references; renumber phase mentions. |
| 39 | `templates/agent_test_session.template.md` | EDIT | Renumber Phase 5 → Phase 6; reference `user_test_plan.md` as the executed source. |
| 40 | `templates/testing_standards.template.md` | EDIT | `manual`→`user` test-plan references; renumber phase mentions. |

### References — `reference/`

| # | Canonical path | Operation | One-line change description |
|---|----------------|-----------|------------------------------|
| 41 | `reference/testing.md` | EDIT | Rewrite the testing model around e4 (mandatory dual plan) + e6 (execute both; user-simulator runs user_test_plan); remove Quick/Standard; `manual`→`user`. |
| 42 | `reference/model_selection.md` | EDIT | Renumber per-phase guidance (e1–e9, merged e4); remove Quick/Standard validation tiers; `manual`→`user` plan rows. |
| 43 | `reference/validation_exit_criteria.md` | EDIT | Retire the Quick/Standard exit distinction — single uniform exit (primary clean + adversarial sub-agent). |
| 44 | `reference/spec_protocol_reference.md` | EDIT | Remove the Path-selection step; context always; renumber. |
| 45 | `reference/implementation_plan_reference.md` | EDIT | Remove Quick/Standard conditionals; renumber. |
| 46 | `reference/rebaseline_protocol.md` | EDIT | Remove Quick/Standard branches (e.g. "context_vN + plan_vN on Standard only" → always); renumber phase refs. |
| 47 | `reference/epic_status_board.md` | EDIT | Renumber the transition-trigger phase refs (`/e4`/`/e8` → `/e5`/`/e9`, etc.) feeding the Building/Released derivation. |
| 48 | `reference/audit_dimensions.md` | EDIT | Update D-dimension examples referencing Quick/Standard, `e3b`/`e5b`, and the renumbered phases. |
| 49 | `reference/pr_review_prevention.md` | EDIT | Remove Quick/Standard references; renumber phase mentions. |
| 50 | `reference/review_categories.md` | EDIT | Remove Quick/Standard references; renumber. |
| 51 | `reference/batch_validation_handoff.md` | EDIT | Remove Quick/Standard validation-rigor references (uniform now). |
| 52 | `reference/mermaid_recipes.md` | EDIT | Update any flow diagram / Quick-Standard / e3b-e5b example to the e1–e9 mandatory flow. |
| 53 | `reference/mermaid_diagram_standards.md` | EDIT | Update Quick/Standard / phase-number example fragments. |
| 54 | `reference/trackers/_contract.md` | EDIT | Renumber the Engineer-phase pointers in the tracker contract. |
| 55 | `reference/trackers/ado.md` | EDIT | Renumber phase references. |
| 56 | `reference/trackers/github.md` | EDIT | Renumber phase references. |

### Root docs + cross-flow references

| # | Canonical path | Operation | One-line change description |
|---|----------------|-----------|------------------------------|
| 57 | `README.md` | EDIT | Rewrite the Engineer-flow table to e1–e9 (drop e3b/e5b rows, add merged e4), update the flow diagram, the personas table (user-simulator executes user_test_plan), and remove Quick/Standard mentions. |
| 58 | `CLAUDE.md` | EDIT | Update the `/e-all` reconciliation paragraph (e1→e9 chain, merged e4, gate set), the "Validation expectations" line (uniform — no Quick/Standard), and any Quick/Standard mention. |
| 59 | `host/templates/claude/commands/validate-artifact.md` cross-consumers — `host/templates/claude/commands/pe2-validate.md`, `pf2-validate.md`, `ps2-validate.md` | EDIT | PO validation stages: remove Quick/Standard rigor selection (uniform validation). |
| 60 | `host/templates/claude/commands/f1-propose-update.md`, `f2-plan-update-implementation.md`, `f3-implement-update.md`, `f5-audit-framework.md`, `f-all.md` | EDIT | Framework-update flow: remove Quick/Standard validation-rigor references (proposal/plan validation is uniform now); update any `e3b`/`e5b` / renamed-phase mentions. |
| 61 | `host/templates/claude/commands/pe3-decompose.md`, `pe4-finalize.md`, `pf3-decompose.md`, `ps0-draft.md`, `ps1-define.md` | EDIT | PO decomposition/draft commands: remove Quick/Standard story-sizing references; `manual`→`user` test-plan mentions; renumber downstream phase pointers. |

> **Phase 3 required — file count ≫ 10.** Run `/f2-plan-update-implementation engineer-flow-single-integer-phase-numbering` before `/f3-implement-update`. The plan must verify each rolled-up row in #59–#61 against its file (some entries bundle several files for readability) and decompose every MOVE into paired CREATE + DELETE.

---

## Risks

- **Regression risk (high)** — this is the largest cross-cutting change in the framework's history. A missed reference leaves a dangling `/e3b`/`/e5b`/`/e4-e8` pointer, a wrong "next phase" suggestion, or an orphaned `manual_test_plan` mention. The renumber + Quick/Standard removal + rename interlock, so partial application produces an incoherent flow. Mitigation: Phase 3 mechanical plan + the `/f5-audit-framework` D1–D12 sweep (especially D2 cross-doc consistency, D4 reference validity, D7 terminology) after `/f4`.
- **Drift risk** — renamed canonical command/skill dirs must regenerate cleanly into `.claude/`; the regen prune + deletion-propagation (#47) must remove the old `e3b`/`e5b`/`e4–e8` slash commands and skill dirs. A stale generated file with the old name would survive a non-pruning regen.
- **Child-project compatibility** — installed children pick up the renamed commands + retired Quick/Standard on next `import-shamt`; any in-flight story carrying a `Path: Quick`/`Standard` header or a `manual_test_plan.md` needs reconciliation (the header becomes inert; the file should be renamed). Muscle-memory `/e3b`, `/e5b`, `/e4`-as-Build usage breaks. Document in the rollback/comms.
- **Behavior-change risk** — making every stage mandatory + uniform validation makes small/trivial stories heavier (always plan, always context.md, always dual test plans, always adversarial validation). This is the user's explicit intent, but it raises per-story cost; flag in the README so users expect it.
- **Open-questions debt** — none outstanding; all design forks resolved in the dialog below.

---

## Rollback Plan

1. `git revert` the squash-merge commit for `proposal/49-engineer-flow-single-integer-phase-numbering` on the base branch.
2. Run `/f4-regen-framework` to propagate the revert into `.claude/` (restores the old `e3b`/`e5b`/`e4–e8` command + skill names, deletes the new ones).
3. Child-side: each installed child re-runs `/sync-import-shamt` to pull the reverted canonical sources; any story already migrated to the new artifact names (`user_test_plan.md`) keeps the file (harmless) but should re-add the prior `manual_test_plan.md` if mid-flight.
4. Communication: notify all child-project owners — command names + the Quick/Standard model changed (and reverted); muscle-memory and any scripts referencing the old/new command names are affected.

---

## Validation Considerations

- **Change-list completeness** — the rolled-up rows #59–#61 each cover multiple files; Phase 3 must expand them to one row per file and confirm none were missed. Re-run the discovery greps (`Quick path|Standard path`, `manual_test_plan`, `/e[4-8][b]?-`, `e3b|e5b`) after implementation to prove **zero** residual references. A `skills/{name}/SKILL.md` `## Protocol` is a **pointer**, not a paraphrase (D2 rule) — rename/repoint the pointer target; never paraphrase the command's numbered steps into a SKILL.
- **Risk coverage** — watch for the failure-routing graph in `/e6`-`/e8` (test failure → `/e8-resolve-feedback` → re-`/e6`): every inbound/outbound phase pointer must be renumbered consistently, or the loop dead-ends.
- **Rollback feasibility** — MOVEs are `git mv`, so history is preserved; DELETEs (e3b/e5b command + skill) are recoverable via revert. No destructive data loss.
- **Affected surfaces** — commands, skills, personas, templates, references, root docs, the `e-all` driver, AND the validation Pattern (framework-wide). This touches nearly every surface; the full `/f5-audit-framework` sweep is warranted as Phase 6.
- **Propagation plan** — requires `/f4-regen-framework` + child `/sync-import-shamt`. The rename is delete-old + create-new on the `.claude/` side; confirm the regen prune (proposal #47 deletion-propagation) removes the old slash commands in a clean child.
- **Terminology (D7)** — after the change, "Quick path", "Standard path", "manual test plan", "e3b", "e5b", and "Phase {N}" with the old numbering must not survive anywhere except historical archive proposals.

---

## Open Questions

_None — all design decisions resolved in the dialog (see Resolved Questions)._

---

## Resolved Questions

- ~~Q: What does "make every stage required" mean given e3b/e5b are conditional by design?~~ → A: Truly mandatory, **and** restructure how the stages function so "mandatory" is coherent — the agent-as-user test plan is always created and later executed by the agent simulating a user after the build.
- ~~Q: Overall shape of the renumbered, mandatory flow?~~ → A: **Merge plan authoring** — one mandatory Phase-4 "Test Plan" stage (agent-as-user plan always + automated plan when suites exist) and one mandatory Phase-6 "Test" stage (user-simulator runs the agent-as-user plan; test-executor runs the automated plan). Yields a linear e1–e9.
- ~~Q: Does e3 Plan (currently Standard-only) also become mandatory?~~ → A: Yes — make Plan mandatory for every story.
- ~~Q: How far does retiring Quick/Standard go (it also controls context.md, gates, validation rigor)?~~ → A: **Fully retire Quick/Standard** — one uniform flow (every story plans, produces context.md, full test plans, all gates).
- ~~Q: Does retiring Quick/Standard also retire validate-artifact's Quick/Standard validation-rigor selector used by non-story artifacts (proposals)?~~ → A: Yes — **retire validation rigor everywhere**; all validation becomes uniform (primary clean + adversarial sub-agent, always).
- ~~Q: Keep the `manual_test_plan.md` filename or rename it (the agent, not a human, now executes it)?~~ → A: **Rename to `user_test_plan.md`** (+ its template) to reflect agent-as-user execution.
