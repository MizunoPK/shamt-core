# Implementation Plan (Index): formalize-testing-standards-and-stages

**Proposal:** `proposals/21-formalize-testing-standards-and-stages.md` (validated 2026-06-13)
**Plan type:** Phase-decomposed (index + 6 phase files — Phase 4 is split into 4a/4b). The change
touches ~20+ canonical files and authors 4 new artifacts (a project-doc template, a per-story
execution-artifact template, a new persona, a reference doc) — well over the single-session / 1500-line
threshold, so it is decomposed into deploy-ordered phases. Each phase file is authored,
validated (Pattern 1), and executed (`plan-executor`) independently; the slug + this index
make every phase fresh-agent-resumable.

**Status:** Index drafted; this index file is not yet footered (the validation footer is stamped
once Pattern 1 completes for the index). All six phase files are authored in deploy order (see
Sequencing): `phase_1`, `phase_2`, `phase_3`, `phase_4a`, `phase_4b`, `phase_5`. Each phase file is
validated **independently** and carries its own footer; per the "Next" note below, a phase is not
approved for `/f3` execution until its own file is footered (authoring ≠ validated).

---

## Design decisions carried from the proposal (binding on every phase)

1. **`TESTING_STANDARDS.md` is the source of truth** — replaces the `testing: enabled/disabled`
   config flag. Declares the project's testing approach: **manual-as-user procedures always**;
   **automated suites when present**.
2. **Phase 5 (Test) is required** on every story. It runs: the **agent-as-user execution**
   (always) + the **automated** `testing_plan.md` (only when `TESTING_STANDARDS.md` declares
   suites). `manual_test_plan.md` stays an on-demand human-walkthrough (not part of the
   required pass — the agent cannot execute it).
3. **Agent-as-user execution = new artifact + persona** (`{user-simulator}` persona drives the
   scripts/app, supplies inputs, observes, logs PASS/FAIL into `{agent-test-session}.md`).
   *Names finalized in Phase 1.*
4. **Bug → `/e5`→`/e7` handoff + required root-cause section** in `addressed_feedback.md`
   (which of Spec/Plan/Build let it through + the prevention). No new sub-flow.
5. **No legacy migration** (no legacy child projects, per #18). The config-key drop is clean.
6. **D12** — the rules file is at 39,870 / 40,000 (130-char margin). The required-testing
   rework will breach it; expanded detail is **extracted to the new `reference/testing.md`**
   (Phase 1) so the rules file keeps only the normative contract + a pointer, with a
   compensating trim if still over. Phase 3 re-measures with `wc -m` (< 40,000 exit gate).

## Naming decisions to fix in Phase 1 (used verbatim by later phases)

- **Persona file:** `host/templates/claude/agents/user-simulator.md` (final name).
- **Execution artifact:** `agent_test_session.md` (template `templates/agent_test_session.template.md`).
- These names are then referenced by Phases 3–5; once Phase 1 lands them, later phases use the
  literal names (no remaining `{…}` placeholders).

---

## Row → Phase map (every Proposed Changes row is covered exactly once)

| Proposed Changes row | Phase |
|---|---|
| `templates/testing_standards.template.md` (CREATE) | **P1** |
| `templates/agent_test_session.template.md` (CREATE) | **P1** |
| `host/templates/claude/agents/user-simulator.md` (CREATE) | **P1** |
| `reference/testing.md` (CREATE) | **P1** |
| `reference/model_selection.md` (EDIT — new persona + required-Phase-5 tier) | **P1** |
| `shamt-config.example.json` (EDIT — drop `testing` key) | **P2** |
| `init-shamt.sh` (EDIT — remove TESTING question; seed TESTING_STANDARDS; completion prompt; staleness×3) | **P2** |
| `templates/SHAMT_RULES.template.md` (EDIT — required Phase 5; path maps; count; Story Artifact Naming; bug rule; D12 extraction/trim) | **P3** |
| `e5-execute-tests` cmd+skill (EDIT — required; orchestrate agent-as-user + automated; bug→/e7) | **P4a** |
| `e3b-write-testing-plan` cmd+skill (EDIT — key off TESTING_STANDARDS) | **P4a** |
| `e7-resolve-feedback` cmd+skill (EDIT — Phase-5 bug + required root-cause section) | **P4a** |
| `test-executor` persona (EDIT — reconcile with required model + new persona) | **P4a** |
| `e5b-write-manual-testing-plan` cmd+skill (EDIT — human-walkthrough vs agent-as-user) | **P4b** |
| `e2-define-spec` cmd+skill (EDIT — Test Strategy always approval-relevant) | **P4b** |
| Catch-all flag refs: `e3`,`e4`,`e6`,`e8` cmd+skill; `spec.template.md`; `active_artifacts`/`testing_plan`/`manual_test_plan` templates; `statusline.sh`; `reference/audit_dimensions.md` | **P4b (e3/e4/e6/e8, spec.template, test templates) + P5 (statusline, audit_dimensions)** |
| `CLAUDE.md`, `README.md` (EDIT — 3 project docs; required testing) | **P5** |

## Phases (deploy order + dependencies)

- **Phase 1 — Foundation (CREATE the new surface).** `testing_standards.template.md`,
  `agent_test_session.template.md`, `user-simulator.md` persona, `reference/testing.md`,
  `reference/model_selection.md` tier rows. *No dependency.* Everything downstream references
  these, so they land first and fix the names + the normative testing contract (which
  `reference/testing.md` holds, ready for the Phase 3 D12 extraction).
  File: `proposals/21-formalize-testing-standards-and-stages_PLAN_phase_1.md`.

- **Phase 2 — Config + install.** `shamt-config.example.json` (drop `testing`), `init-shamt.sh`
  (remove the TESTING question; seed `TESTING_STANDARDS.md`; add it to the completion prompt;
  extend the staleness threshold to all three docs). *Depends on P1* (the template to seed).
  File: `…_PLAN_phase_2.md`.

- **Phase 3 — Rules file.** Rework "When automated testing is enabled" → required Phase 5;
  update the Quick/Standard path-map tables + the phase-count statements; add `agent_test_session.md`
  to Story Artifact Naming; add the bug→`/e7` root-cause rule; **extract** the expanded testing
  detail into `reference/testing.md` (P1) leaving a pointer; pull a compensating trim if needed;
  re-measure `wc -m` < 40,000. *Depends on P1* (reference target). Single file, D12-sensitive →
  its own phase. File: `…_PLAN_phase_3.md`.

- **Phase 4 — Engineer-flow bodies (split into 4a + 4b at authoring; the largest phase).**
  *Depends on P1 (persona/artifact) + P3 (rules contract).*
  - **Phase 4a — Test-execution + bug-loop logic (substantive).** `e5` (required; orchestrate
    agent-as-user `user-simulator` + automated), `e3b` (key off `TESTING_STANDARDS.md`), `e7`
    (required phase-attributed root-cause for test bugs; `/e5`→`/e7` routing), and `test-executor`
    (automated-only) command+skill bodies. File: `…_PLAN_phase_4a.md`.
  - **Phase 4b — Flag-reference cleanup (rote).** `e2`,`e3`,`e4`,`e6`,`e8` command+skill bodies,
    the `e5b` command+skill (human-walkthrough vs agent-as-user), `templates/spec.template.md`, and
    the per-story test artifact templates (`testing_plan.template.md`, `manual_test_plan.template.md`,
    `active_artifacts.template.md`): rework every residual `testing` flag reference for required
    testing. *Depends on P3 + 4a.* File: `…_PLAN_phase_4b.md`.

- **Phase 5 — Docs + status line + audit dimension.** `CLAUDE.md`, `README.md` (3 project docs;
  required testing), `host/templates/claude/statusline.sh` (phase-count 7/8 logic → required Phase 5),
  `reference/audit_dimensions.md` (D10 phase-count expectation). (`templates/spec.template.md` is
  handled in Phase 4b, not here.) *Depends on P1–P4* (describes the now-final behavior).
  File: `…_PLAN_phase_5.md`.

## Verification approach (per phase)

Each phase file carries, per step: exact **locate** string + exact **replacement** (EDIT) or full
**content** (CREATE), and a **verification** (grep the new text present / old gone; `bash -n` for
scripts; `wc -m` < 40,000 after Phase 3; `regenerate-framework.sh --check` is run once at
`/f4-regen-framework` after all phases, not per phase). Cross-phase: Phase 4/5 verify no residual
`testing: enabled/disabled` reference remains (the post-impl `/f5` D2 sweep is the backstop).

## Next

Author the 6 phase files in deploy order, then validate. Because this is a phase-decomposed plan
(index + 6 phase files = 7 artifacts), the recommended validation is the **batch-validation handoff**
(one fresh session fans out a validation sub-agent per file); the sequential per-file
`/clear` + `/validate-artifact` list is the fallback. No phase is approved for `/f3` execution until
its file carries a validation footer.

---
Validated 2026-06-13 — 7 rounds, 1 adversarial sub-agent confirmed
