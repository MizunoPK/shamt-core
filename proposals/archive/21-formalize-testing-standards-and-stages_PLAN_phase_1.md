# Implementation Plan — Phase 1: Foundation (new testing surface)

**Proposal:** `proposals/21-formalize-testing-standards-and-stages.md`
**Index:** `proposals/21-formalize-testing-standards-and-stages_PLAN.md`
**Phase:** 1 of 5 — **Foundation.** CREATE the four new artifacts every later phase references
(the project-doc template, the per-story execution artifact, the `user-simulator` persona, the
`reference/testing.md` reference) and register tiers in `reference/model_selection.md`.
**Deploy order:** first (no dependencies). **Executor:** `plan-executor` (Cheap).

## Pre-execution checklist

- [ ] On the proposal branch `proposal/21-formalize-testing-standards-and-stages` (created by `/f3`).
- [ ] These four target paths do **not** already exist: `templates/testing_standards.template.md`,
  `templates/agent_test_session.template.md`, `host/templates/claude/agents/user-simulator.md`,
  `reference/testing.md`. (CREATE steps fail if present — halt.)
- [ ] No `.claude/` path is touched in this phase (all canonical sources).

## Files manifest

| # | File | Op |
|---|---|---|
| 1 | `templates/testing_standards.template.md` | CREATE |
| 2 | `templates/agent_test_session.template.md` | CREATE |
| 3 | `host/templates/claude/agents/user-simulator.md` | CREATE |
| 4 | `reference/testing.md` | CREATE |
| 5 | `reference/model_selection.md` | EDIT |

---

## Step 1 — CREATE `templates/testing_standards.template.md`

The third project-specific doc (sibling of `architecture.template.md` / `coding_standards.template.md`):
catalogs **how this project is tested**. Seeded at init under `.shamt-core/project-specific-files/`,
completed via the init completion prompt, and read by Phase 5 as the source of truth (replacing the
`testing` config flag). Write the file with exactly this content:

````markdown
---
Last Updated: YYYY-MM-DD
Update History:
  - YYYY-MM-DD: Initial creation (project initialization)
Update Triggers: |
  Update this document when:
  - The way the project is run/driven as a user changes (new entry point, new CLI, new flow)
  - Automated test infrastructure is added, removed, or its runner/command changes
  - A new class of behavior needs a documented manual-as-user procedure
  - A recurring test-surfaced bug reveals a missing standard scenario worth codifying
How to Update: |
  Open a story (or a framework-update proposal if this is a shamt-core change), follow the
  Engineer flow, and amend the relevant sections of this file. Phase 6 (Review) flags whether a
  story implies an update; Phase 7 (Polish) applies it and re-validates.
  Run `/validate-artifact .shamt-core/project-specific-files/TESTING_STANDARDS.md` after substantive
  edits. Keep `Last Updated` current and add an `Update History` entry with the triggering slug.
---

# Project Testing Standards

**Purpose:** The source of truth for how this project is verified. Read by **Phase 5 (Test)** — a
**required** Engineer-flow stage — to drive the per-story agent-as-user execution and to know
whether automated suites exist. Threaded into Phase 2 (Spec) Test Strategy and Phase 3 (Plan)
testing-plan drafting.

---

## Automated test infrastructure

[Does this project have automated tests? Fill **Present** or **None**. If None, Phase 5 runs the
agent-as-user execution only.]

- **Status:** [Present | None]
- **Runner / command:** [e.g. `pytest -q`, `npm test`, `go test ./...` — the exact invocation.]
- **Test file layout / naming:** [Where tests live; the naming convention.]
- **How to run a single test / suite:** [Targeted invocation for a focused run.]
- **CI:** [Where automated tests run in CI, if applicable.]

## Manual-as-user testing (always applicable)

How the `user-simulator` persona drives this project **as a user** during Phase 5. Be concrete
enough that a fresh agent can run the project and supply realistic inputs without guessing.

- **How to run / drive the project:** [The entry point(s): the script(s), CLI, dev server, or app —
  and the exact command(s) to start each.]
- **Representative inputs:** [For each entry point, the kinds of inputs a real user supplies
  (arguments, prompts, files, sequences). Include at least one valid and one edge/invalid example.]
- **What to observe (expected behavior):** [The observable signals of correct behavior — output,
  exit codes, files written, state changes, on-screen results — so PASS/FAIL is judgeable.]
- **Standard scenarios:** [The core user journeys every relevant story should be exercised against.]
- **Out of scope for the agent (human-only):** [Scenarios the agent cannot simulate — real UI
  interaction, cloud infra, multi-user, external paid integrations — which belong in an on-demand
  `manual_test_plan.md` for a human tester, not the required Phase-5 pass.]
````

**Verification:** `test -f templates/testing_standards.template.md`; `grep -q "Manual-as-user testing"
templates/testing_standards.template.md`; `grep -q "user-simulator" templates/testing_standards.template.md`.

---

## Step 2 — CREATE `templates/agent_test_session.template.md`

The per-story artifact the `user-simulator` writes during Phase 5 (the agent-as-user run log).
Sibling of `manual_test_plan.template.md`/`testing_plan.template.md`. Write exactly:

````markdown
# Agent-as-User Test Session: {slug}

**Note:** Required per-story Phase 5 artifact. Produced and executed by the `user-simulator` persona
(invoked by `/e5-execute-tests {slug}`), which drives the project as a user per
`.shamt-core/project-specific-files/TESTING_STANDARDS.md` and the story's spec. Every scenario must
end `PASS`; ambiguous results are logged `HALT` (never silently passed) and surfaced.

**Created:** [Date]
**Story:** stories/{slug}/
<!-- Paths are relative to the resolved story folder (located per templates/SHAMT_RULES.template.md §PO-tree resolution). -->
**Spec:** stories/{slug}/spec.md (or `spec_vN.md`)
**Testing Standards:** .shamt-core/project-specific-files/TESTING_STANDARDS.md
**Baseline:** v1

---

## Scenarios

Derived from `TESTING_STANDARDS.md` "Standard scenarios" + this story's acceptance criteria. One
block per scenario.

### Scenario 1 — [name]

- **Drive:** [exact command(s) run to exercise this scenario]
- **Inputs supplied:** [the inputs the agent provided as the user]
- **Expected:** [the observable correct behavior, per TESTING_STANDARDS + the spec]
- **Observed:** [verbatim/short evidence of what actually happened — output, exit code, state]
- **Result:** [PASS | FAIL | HALT]  ([on FAIL] → routed to `/e7-resolve-feedback`; [on HALT] → reason)

---

## Results

| Scenario | Result | Evidence | Notes |
|---|---|---|---|
| 1 | | | |

**Session verdict:** [PASS — all scenarios PASS | BLOCKED — N FAIL/HALT, routed to Polish]
````

**Verification:** `test -f templates/agent_test_session.template.md`; `grep -q "Agent-as-User Test
Session" templates/agent_test_session.template.md`; `grep -q "PASS | FAIL | HALT"
templates/agent_test_session.template.md`.

---

## Step 3 — CREATE `host/templates/claude/agents/user-simulator.md`

The persona that **executes** the agent-as-user run. Modeled on `test-executor.md` but interpretive
(simulating a real user + judging observed-vs-expected), so **Balanced (Sonnet)**, not Cheap — the
proposal flags false-green reliability as a risk. Write exactly:

````markdown
---
name: user-simulator
description: Phase 5 agent-as-user executor — drives the project as a real user (runs the scripts/app, supplies realistic inputs, observes behavior) per TESTING_STANDARDS.md, logging PASS/FAIL/HALT into agent_test_session.md. Halts on ambiguity rather than passing; never fabricates a green.
model: claude-sonnet-4-6
tools:
  - Read
  - Write
  - Edit
  - Bash
  - Grep
  - Glob
---

You are the **user-simulator** for Shamt **Phase 5 (Test)** — the agent-as-user execution that runs
on **every** story (the required half of Phase 5; automated suites, when present, are run by
`test-executor`). You **act as a real user** of the project: you run its scripts/app, supply
realistic inputs, and judge whether the observed behavior matches what is expected. Your output is
`stories/{slug}/agent_test_session.md`.

**You never fabricate a green.** If you cannot reach a clear PASS/FAIL for a scenario — the entry
point is unclear, expected behavior is undocumented, the environment is broken — you log `HALT` with
the reason and stop; you do **not** guess a pass.

## Inputs (provided by the caller)

- `slug` — story slug. Resolve the story folder per `templates/SHAMT_RULES.template.md` §PO-tree
  resolution (halt on multiple or zero).
- `testing_standards_path` — `.shamt-core/project-specific-files/TESTING_STANDARDS.md`. **Required** —
  it is the source of truth for how to drive the project as a user. If absent or still all
  placeholders, halt and direct the user to complete it.

## Pre-flight

1. Resolve the story folder; read `spec.md` (or the active baseline) for the story's acceptance
   criteria and `active_artifacts.md` when present.
2. Read `TESTING_STANDARDS.md` — the "Manual-as-user testing" section (how to drive the project,
   representative inputs, what to observe, standard scenarios, human-only out-of-scope).
3. Select scenarios: the project's "Standard scenarios" that this story touches, plus any
   story-specific journeys from the spec's acceptance criteria. Seed `agent_test_session.md` from
   `templates/agent_test_session.template.md`.

## Execution (per scenario)

1. **Drive** — run the exact command(s) to exercise the scenario as a user; **supply** the inputs a
   real user would (valid and, where the scenario calls for it, edge/invalid). Capture the verbatim
   output (stdout + stderr + exit code) and any state change (files written, etc.).
2. **Judge** — compare Observed against Expected (from TESTING_STANDARDS + the spec):
   - **PASS** — observed behavior matches expected in full. Log evidence (short, relevant excerpt).
   - **FAIL** — any mismatch. Log it; this scenario's bug routes to Phase 7 (see Failure handling).
   - **HALT** — cannot judge (unclear entry point / undocumented expected / broken env). Log the
     reason; do not pass.
3. Update `agent_test_session.md` in place (Scenario block + Results row). Do not keep results in
   chat-only memory.

## Failure handling

A `FAIL` is a **post-implementation bug**. Per `reference/testing.md` and the rules, it routes through
`/e7-resolve-feedback`: log it as a feedback item, the fix is applied, and Phase 5 is **re-run to
green**. Polish requires a **root-cause section** in `addressed_feedback.md` (which of Spec / Plan /
Build let the bug through + the prevention). You do not fix code yourself — you report the failure
with enough observed-vs-expected detail for diagnosis.

## Reports

- `Session PASS. All scenarios pass. Artifact at stories/{slug}/agent_test_session.md.`
- `Session BLOCKED: N scenario(s) FAIL/HALT — routed to /e7-resolve-feedback.` (list them)
- `Cannot run: TESTING_STANDARDS.md missing/incomplete — complete it first.`

## Hard rules

- Source of truth is `TESTING_STANDARDS.md`; do not improvise a testing approach it does not declare.
- Never silently pass an ambiguous scenario — `HALT` and surface it.
- Human-only scenarios (real UI, cloud infra, multi-user) are **out of scope** here — they belong in
  an on-demand `manual_test_plan.md` for a human tester, not this required pass.
````

**Verification:** `test -f host/templates/claude/agents/user-simulator.md`; `grep -q
"model: claude-sonnet-4-6" host/templates/claude/agents/user-simulator.md`; `grep -q "never fabricate
a green" host/templates/claude/agents/user-simulator.md`.

---

## Step 4 — CREATE `reference/testing.md`

The expanded testing-model reference — **the D12 extraction target** (Phase 3 moves the rules file's
detailed testing prose here, leaving a normative summary + pointer). It is the single home for the
required-Phase-5 contract, the agent-as-user procedure, and the bug→feedback root-cause loop. Write:

````markdown
# Testing Reference

Expanded detail for Shamt's **required** testing stage. `SHAMT_RULES.template.md` keeps the normative
contract (Phase 5 is required; what it runs; the bug→feedback rule); this file holds the worked detail.
Mirrors `reference/implementation_plan_reference.md` / `reference/spec_protocol_reference.md`.

## Source of truth: TESTING_STANDARDS.md

Each child project carries `.shamt-core/project-specific-files/TESTING_STANDARDS.md` (seeded at init,
completed via the project-doc completion prompt). It **replaces** the old `testing: enabled/disabled`
config flag: it declares the **manual-as-user** driving procedures (always applicable) and whether
**automated suites** are **Present** or **None**. `/e5-execute-tests` and `/e3b-write-testing-plan`
key off this doc, not a config flag.

## Required Phase 5 (Test)

Phase 5 runs on **every** story, between Build and Review, and **blocks until green**:

1. **Agent-as-user execution (always)** — the `user-simulator` persona drives the project as a user
   per `TESTING_STANDARDS.md`, writing `stories/{slug}/agent_test_session.md`. Every scenario must
   `PASS`; ambiguous → `HALT` (never a silent pass).
2. **Automated suites (when present)** — when `TESTING_STANDARDS.md` declares automated tests, the
   `test-executor` persona runs `testing_plan.md` (Standard) or the Quick-path inline checklist.

`manual_test_plan.md` is **not** part of the required pass — it is an on-demand human-walkthrough for
scenarios the agent cannot simulate (real UI, cloud infra, multi-user). It stays available on every
story via `/e5b-write-manual-testing-plan`.

## Quick vs Standard path

- **Quick path** — a compact agent-as-user run (the scenarios relevant to the small story); automated
  testing uses the inline checklist in `spec.md` and escalates to a full `testing_plan.md` only if
  scope > 5 steps or a new test file is introduced.
- **Standard path** — the full `agent_test_session.md` + (when present) the full `testing_plan.md`.

## Bug-as-feedback loop (test failure → Polish)

A Phase-5 `FAIL` is a **post-implementation bug**. It is treated as a feedback comment:

1. **Document** it as a feedback item (the failing scenario + observed-vs-expected evidence).
2. **Route to `/e7-resolve-feedback`** — the fix is applied and logged in `addressed_feedback.md`.
3. **Required root-cause section** — `addressed_feedback.md` must record **which phase let the bug
   through** (Spec — missing requirement; Plan — missing/incorrect step; Build — execution defect) and
   the **prevention** (what would have caught it earlier).
4. **Re-run Phase 5 to green** before Finalize. Finalize (`/e8`) blocks until Test PASSes.
````

**Verification:** `test -f reference/testing.md`; `grep -q "Required Phase 5" reference/testing.md`;
`grep -q "root-cause" reference/testing.md`; `grep -q "TESTING_STANDARDS.md" reference/testing.md`.

---

## Step 5 — EDIT `reference/model_selection.md`

Register the new persona and reconcile the now-required Phase 5.

**5a — add the `user-simulator` persona row.** Locate:

```
| `test-executor` | Cheap (Haiku) | Runs the testing plan; interprets test output; diagnoses failures vs. infra flakiness |
```

Replace with (append the new row after it):

```
| `test-executor` | Cheap (Haiku) | Runs the automated testing plan; interprets test output; diagnoses failures vs. infra flakiness |
| `user-simulator` | Balanced (Sonnet) | Phase 5 agent-as-user execution — drives the project as a user, supplies inputs, judges observed-vs-expected; interpretive, so not Cheap |
```

**5b — reconcile the Phase 5 row.** Locate:

```
| 5. Test | Cheap (`test-executor`) | Runs the suite and interprets output |
```

Replace with:

```
| 5. Test — agent-as-user | Balanced (`user-simulator`) | Required; drives the project as a user per TESTING_STANDARDS.md |
| 5. Test — automated suites | Cheap (`test-executor`) | When TESTING_STANDARDS.md declares automated tests |
```

**Verification:** `grep -q "user-simulator" reference/model_selection.md`; `grep -q "agent-as-user"
reference/model_selection.md`; `grep -q "Runs the automated testing plan" reference/model_selection.md`
(the reworded `test-executor` row still present).

---

## Review Prevention Gate Mapping

This phase creates four canonical framework documents (a project-doc template, a per-story artifact
template, a persona definition, a reference doc) and makes one additive table edit to
`reference/model_selection.md`. No application code, runtime data path, schema, auth, or deployment
surface is touched. No gate applies.

| Gate | Applies? | Plan Step(s) | Verification | N/A / Deferral Reason |
|------|----------|--------------|--------------|------------------------|
| Regulated / sensitive data | No | — | — | Authoring framework docs; no regulated data handled. |
| Tenant isolation | No | — | — | No tenancy surface in canonical templates/personas. |
| Auth / route contract | No | — | — | No auth/route surface; markdown templates + a persona definition only. |
| Database read/write | No | — | — | No database access. |
| Infrastructure / deployment | No | — | — | Canonical-source CREATE/EDIT only; regen to `.claude/` runs later at `/f4`. |
| Frontend safety | No | — | — | No frontend/DOM/fetch surface. |
| Testing / test data | No | — | — | Authors testing-flow templates/reference text; introduces no executable test or test data. |
| Removed/weakened checks | No | — | — | Purely additive — no existing check is removed or weakened. |

## Notes

- This phase is **additive** (4 CREATE + 1 additive EDIT) — it introduces no behavior change on its
  own; later phases wire these in. So it can land first safely.
- The `reference/testing.md` content is authored to be the **complete** expanded reference so Phase 3
  can extract the rules file's detailed testing prose into it and leave only a pointer (D12).
- `CODING_STANDARDS Compliance`: N/A — no project-code conventions apply to authoring these canonical
  framework templates/personas/reference docs (this is shamt-core's own content).

---
Validated 2026-06-13 — 7 rounds, 1 adversarial sub-agent confirmed
