# Proposal: formalize-testing-standards-and-stages

**Created:** 2026-06-13
**Status:** Implemented
**Number:** 21
**Proposed by:** [master-local]
**Project context:** [master-local]

---

## Problem

Shamt's testing today is **opt-in and thin**. `init-shamt.sh` asks one question —
*"Automated testing infrastructure present in this project?"* (`:260`) — and writes
`testing: "enabled" | "disabled"` to `shamt-config.json` (default `disabled`). When
`enabled`, a **Phase 5 (Test)** is inserted between Build and Review (spec gains a
Test Strategy section, plan produces `testing_plan.md`, `/e5-execute-tests` runs it
via the `test-executor` persona and blocks until pass; `/e5-execute-tests` **no-ops**
when `disabled`). Separately, `/e5b-write-manual-testing-plan` produces a per-story
`manual_test_plan.md` — but it is a **human-walkthrough document** (a plan for a
*human* tester), always available but never executed by the agent.

Three gaps the f0 capture targets:

1. **No project-level testing standard.** A child has `ARCHITECTURE.md` and
   `CODING_STANDARDS.md` under `.shamt-core/project-specific-files/` but **no
   `TESTING_STANDARDS.md`** — nothing catalogs *how this project is tested* (the
   manual procedures, how to drive the scripts/app as a user, and the automated
   suites when present). The one init testing question is too coarse to capture this.

2. **Testing is skippable.** With `testing: disabled` (the default), the Test phase
   is a no-op and `manual_test_plan.md` is optional — a story can ship with **no
   verification at all**. The f0 wants testing to be a **required** stage: testing
   must pass after implementation.

3. **Manual testing is never actually run, and bugs aren't learned from.**
   `manual_test_plan.md` is a doc for a human; the f0 wants the **agent to simulate
   a user** — run the scripts/app, provide inputs, observe behavior. And when a test
   surfaces a bug post-implementation, there is no defined loop: the f0 wants it
   **treated as a feedback comment** routed through the `/e7-resolve-feedback`
   mechanics — document the issue, fix + re-test, and perform a **root-cause
   analysis** of how it escaped Spec / Plan / Build.

The f0's named target areas (verified against the current surface): `init-shamt.sh`
(move the testing question out; seed a new `TESTING_STANDARDS.md`),
`.shamt-core/project-specific-files/` (the new doc), a doc-authoring process for
`TESTING_STANDARDS.md`, the Engineer-flow Phase 5 + the `testing` config flag (opt-in
→ required), and a bug-as-feedback loop spanning `/e5-execute-tests` ↔
`/e7-resolve-feedback`.

This is a **large, multi-stage redesign** (Phase 3 is certain — well over 10 canonical
files: the rules file, `init-shamt.sh`, a new `templates/testing_standards.template.md`,
a new TESTING_STANDARDS authoring command+skill, `e3b`/`e5`/`e5b`/`e7` command+skill
bodies, `test-executor`, `shamt-config.example.json`, reference docs). The
foundational design decisions are settled in the Open Questions before the change set
is fixed. **D12 note:** the rules file is at 39,870 / 40,000 (130-char margin); any
required-testing prose will breach it, so a compensating trim or extraction to a
`reference/` doc is in scope.

---

## Proposed Changes

**Resolved design.** Testing becomes a **required Phase 5** driven by a new
project-level `TESTING_STANDARDS.md` (replacing the `testing` config flag): every
story runs an **agent-as-user execution** (a new persona drives the scripts/app,
logging PASS/FAIL into a new per-story artifact) plus the **automated** `testing_plan.md`
when the standard declares suites; a post-implementation bug routes `/e5` → `/e7` with
a **required root-cause section** in `addressed_feedback.md`. `manual_test_plan.md` is
retained as on-demand human-walkthrough.

> **Phase 3 is certain** — this is a multi-stage Engineer-flow redesign touching ~20+
> canonical files. The table below is **area-level**; `/f2-plan-update-implementation`
> decomposes it into ordered, individually-verifiable steps.

| File / area | Op | What |
|---|---|---|
| `templates/testing_standards.template.md` | CREATE | New project-specific doc template — catalogs the project's testing approach: manual-as-user driving procedures (how to run the scripts/app + representative inputs), and automated suites + how to run them when present. Sibling of `architecture.template.md` / `coding_standards.template.md`. |
| `templates/{agent-test-session}.template.md` | CREATE | New per-story **agent-as-user execution** artifact template (the run log: scenarios driven, inputs supplied, observed behavior, PASS/FAIL). Naming finalized in Phase 3. |
| `host/templates/claude/agents/{user-simulator}.md` | CREATE | New persona that **executes** the agent-as-user run — drives the scripts/app as a user, supplies inputs, observes, logs results. Tier set in `reference/model_selection.md`. |
| `init-shamt.sh` | EDIT | Remove the `TESTING` question (`:260`); seed `TESTING_STANDARDS.md` under `.shamt-core/project-specific-files/` (like the other two docs, `Last Updated` = today); add it to the project-doc completion prompt; extend the staleness-threshold question to cover all three docs. |
| `shamt-config.example.json` | EDIT | Drop the `testing` key (the doc is now the source of truth). |
| `templates/SHAMT_RULES.template.md` | EDIT | Testing is **required** (Phase 5 always present, not config-gated): rework "When automated testing is enabled" → required-Phase-5; update the Quick/Standard **path-map tables** + the "seven-phase / eight phases" count; add the new agent-as-user artifact to **Story Artifact Naming**; add the bug→`/e7` root-cause rule. **D12: this breaches the 130-char margin — extract the expanded testing detail to a new `reference/testing.md` and/or pull a compensating trim; re-measure at `/f3`.** |
| **All remaining files referencing the dropped `testing` flag** | EDIT | The completeness sweep found the flag / "when testing is enabled" referenced well beyond the rows above. Every one must be reworked for **required** testing (no residual `testing: enabled/disabled`): `e3-plan-implementation`, `e4-execute-plan`, `e6-review-changes`, `e8-finalize-story` command+skill bodies (esp. **e8's** "Test PASSes when testing is enabled" finalize gate → always, and the N=7/8 phase-count note); `templates/spec.template.md` (Test Strategy always-present); `host/templates/claude/statusline.sh` (the 7-vs-8 phase-count logic → required Phase 5); `templates/{active_artifacts,testing_plan,manual_test_plan}.template.md`; and `reference/audit_dimensions.md`. `/f2` enumerates each; the post-impl `/f5` D2 sweep asserts zero residual flag references. |
| `host/templates/claude/commands/e5-execute-tests.md` + skill | EDIT | No longer no-ops — required. Orchestrates the agent-as-user execution (new persona) + the automated `testing_plan.md` (when present); on failure, routes to `/e7` with the root-cause requirement; blocks until green. |
| `host/templates/claude/commands/e3b-write-testing-plan.md` + skill | EDIT | Key off `TESTING_STANDARDS.md` (not the dropped config flag); produce `testing_plan.md` when the standard declares automated suites. |
| `host/templates/claude/commands/e7-resolve-feedback.md` + skill | EDIT | Accept a Phase-5 bug as a feedback item; require the **root-cause section** (which of Spec/Plan/Build let it through + prevention) in `addressed_feedback.md`; re-run Phase 5 to green. |
| `host/templates/claude/commands/e5b-write-manual-testing-plan.md` + skill | EDIT | Clarify the relationship to the new agent-as-user execution (it stays the on-demand **human-walkthrough** for non-agent-simulable scenarios). |
| `host/templates/claude/commands/e2-define-spec.md` + skill | EDIT | Test Strategy is now always approval-relevant (testing required); align the spec contract. |
| `host/templates/claude/agents/test-executor.md` | EDIT | Reconcile with the required model + the new agent-as-user persona (automated-suite execution). |
| `reference/testing.md` | CREATE | Expanded testing-model reference (the D12 extraction target) — `TESTING_STANDARDS.md` shape, agent-as-user procedure, the required-Phase-5 contract, the bug→feedback root-cause loop. The rules file cross-references it. |
| `reference/model_selection.md` | EDIT | Add the new agent-as-user persona's tier + the (now-required) Phase 5 per-phase tier. |
| `CLAUDE.md`, `README.md` | EDIT | Project-specific-files is now **three** docs; testing is a required phase — update the layout/flow descriptions. |

**Phase 3 required** (row count + per-row expansion well over 10). `/f2-plan-update-implementation`
decomposes; the plan is validated before `/f3`.

---

## Risks

- **Large blast radius (primary).** This redesigns the Engineer flow's verification
  stage end-to-end (config → doc, optional → required, new persona/artifact, bug-loop).
  A regression could break every story's Phase 5. *Mitigation:* Phase 3 mechanical
  decomposition + its own validation; reuse existing artifacts where possible
  (`addressed_feedback.md`, `testing_plan.md`, `manual_test_plan.md`); the bug-loop is
  a documented `/e5`↔`/e7` handoff, not a new sub-flow.
- **D12 budget breach (certain).** Required-testing prose + the bug-loop rule will push
  the rules file past 40,000. *Mitigation:* extract the expanded testing detail to the
  new `reference/testing.md` (keep only the normative contract + a pointer in the
  rules), and/or a compensating trim; `/f3` re-measures with `wc -m`.
- **Required-testing friction.** Every story — even a trivial Quick-path one — now must
  pass Phase 5. *Mitigation:* the agent-as-user run scales to the story (a one-step CLI
  story gets a one-step run); Quick path uses the inline/compact form, not a full
  `testing_plan.md`.
- **Agent-as-user execution reliability.** Driving scripts / supplying inputs / judging
  PASS-FAIL is genuinely hard and can produce false greens. *Mitigation:* the persona
  logs concrete observed-vs-expected per scenario; ambiguous results halt rather than
  pass; `TESTING_STANDARDS.md` gives the project-specific driving procedure so the run
  isn't improvised.
- **Config-key removal.** Dropping `testing` changes the config schema. *Mitigation:*
  no legacy child projects exist (OQ5); `/e5`/`/e3b` switch to keying off
  `TESTING_STANDARDS.md` presence/content.

## Rollback Plan

Single squash commit (`shamt-core: land #21 …`) via `/f6-archive-proposal`; `git revert`
restores the opt-in config flag, the two-doc project-specific set, and the
optional-Phase-5 wording, and removes the new template/persona/reference. Large but
fully reversible; no master data, no child state (no legacy projects). A child that
installed the new model between landing and revert would have a `TESTING_STANDARDS.md` +
no `testing` key — re-syncable.

## Validation Considerations

- **Required-testing consistency (D2/D10).** After the change, the rules file's path
  maps, the "N-phase" count, the Finalize "Test PASSes" gate, and the `/e5`/`/e3b`/`/e7`
  bodies all agree that Phase 5 is required and keys off `TESTING_STANDARDS.md` (no
  residual `testing: enabled/disabled` config references anywhere).
- **D12 re-measure.** `wc -m templates/SHAMT_RULES.template.md` < 40,000 after the
  extraction/trim.
- **New-surface coverage (D3/D5).** The new template, persona, and `reference/testing.md`
  are each cited by the protocol that uses them; the agent-as-user artifact template has
  every section `/e5` expects.
- **Bug-loop trace.** A simulated Phase-5 failure correctly routes to `/e7`, requires the
  root-cause section in `addressed_feedback.md`, and re-runs Phase 5 to green.
- **Init.** A child `init` seeds all three project docs + drops the `testing` key; the
  completion prompt covers `TESTING_STANDARDS.md`; self-host is unaffected (gated).
- The Phase 3 plan is validated before `/f3`; this proposal is validated before planning.

---

## Resolved Questions

- **OQ1 — "Required testing" + config-flag fate.** *Resolved (user):* **Replace the
  flag with `TESTING_STANDARDS.md`.** Drop `testing: enabled/disabled` + the init
  question; `TESTING_STANDARDS.md` (authored at init) is the source of truth,
  declaring the project's testing approach — **manual-as-user always; automated
  suites when present**. **Phase 5 (Test) becomes a required stage** that runs
  whatever the doc declares (at minimum the manual-as-user pass).

- **OQ2 — Manual-as-user execution model.** *Resolved (user):* **a new agent-as-user
  execution artifact + persona** (distinct from `manual_test_plan.md`). A new persona
  drives the scripts/app as a user — supplying inputs, observing behavior, logging
  PASS/FAIL into a new per-story execution artifact (template + command/skill to
  follow). `manual_test_plan.md` stays the human-walkthrough doc for scenarios the
  agent cannot simulate (real UI, cloud infra, multi-user).
- **OQ3 — `TESTING_STANDARDS.md` ↔ per-story plans (corollary of OQ1/OQ2).**
  *Resolved:* layered — `TESTING_STANDARDS.md` is the project-level source ("how to
  test this project": manual-as-user driving procedures + automated suites when
  present); it **informs** the per-story artifacts. Required Phase 5 on every story
  runs the **agent-as-user execution** (always, derived from the standard) **+
  automated** `testing_plan.md` (when the standard declares automated suites);
  `manual_test_plan.md` is **retained** as on-demand human-walkthrough (the agent
  cannot execute it, so it is not part of the required pass).

- **OQ4 — Bug-as-feedback loop formality.** *Resolved (user):* **documented
  `/e5` (Test) → `/e7` (Polish) handoff + a required root-cause section** — no new
  sub-flow. A Phase-5 test failure routes into the existing `/e7-resolve-feedback`
  mechanics (log the bug as a feedback item, fix, re-run Phase 5 to green), and a
  **required root-cause section** is added to the existing `addressed_feedback.md`
  naming which phase (Spec / Plan / Build) let the bug through and the prevention.
  Reuses existing artifacts; adds the `/e5`↔`/e7` routing rule + the required section.

- **OQ5 — Init migration + config-key fate.** *Resolved (user):* **drop the key; the
  doc is the source of truth.** Remove the init `TESTING` question + the `testing` key
  from `shamt-config.example.json`; `TESTING_STANDARDS.md` (seeded at init, completed
  via the project-doc completion prompt alongside `ARCHITECTURE`/`CODING_STANDARDS`)
  declares the approach; `/e5` and `/e3b` key off it; the staleness threshold covers
  all three docs; no legacy migration (no legacy projects).

## Open Questions

None — all resolved above.

---
Validated 2026-06-13 — 3 rounds, 1 adversarial sub-agent confirmed
