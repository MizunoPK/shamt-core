# Implementation Plan — Phase 3: Personas + Templates

**Proposal:** proposals/49-engineer-flow-single-integer-phase-numbering.md
**Plan index:** proposals/49-engineer-flow-single-integer-phase-numbering_PLAN.md
**Covers:** Proposed Changes rows 27–40 (host/templates/claude/agents/ + templates/)
**Created:** 2026-06-21

> Renumber map applied throughout: e4-execute-plan → e5 (Phase 4 → 5, Build); e5-execute-tests → e6 (Phase 5 → 6, Test); e6-review-changes → e7 (Phase 6 → 7, Review); e7-resolve-feedback → e8 (Polish); e8-finalize-story → e9 (Finalize). Artifact rename: `manual_test_plan.md` → `user_test_plan.md`. Quick/Standard concept fully retired.
>
> Canonical sources only — no `.claude/` paths. Row 31 (`templates/SHAMT_RULES.template.md`) is handled by a separate phase; not planned here.

## Steps

### Step 3.1 — Row 27: rewrite `user-simulator.md` to EXECUTE `user_test_plan.md`

**Operation:** EDIT
**File:** `host/templates/claude/agents/user-simulator.md`

This is a substantive rewrite: the persona must read and execute `user_test_plan.md` scenarios rather than improvise from `TESTING_STANDARDS.md`, with `TESTING_STANDARDS.md` retained as a conventions/how-to-drive input. Phase 5 → Phase 6, `/e5`/`/e7` references renumbered to `/e6`/`/e8`, `manual_test_plan.md` reference dropped. Replace the body in the discrete edits below (frontmatter `name`/`model`/`tools` block unchanged).

#### Step 3.1a — frontmatter `description`

**Locate:**
```
description: Phase 5 agent-as-user executor — drives the project as a real user (runs the scripts/app, supplies realistic inputs, observes behavior) per TESTING_STANDARDS.md, logging PASS/FAIL/HALT into agent_test_session.md. Halts on ambiguity rather than passing; never fabricates a green.
```
**Replace:**
```
description: Phase 6 agent-as-user executor — executes the scenarios in user_test_plan.md by driving the project as a real user (runs the scripts/app, supplies the plan's inputs, observes behavior) using TESTING_STANDARDS.md as the how-to-drive conventions, logging PASS/FAIL/HALT into agent_test_session.md. Halts on ambiguity rather than passing; never fabricates a green.
```
**Verification:** `grep -n 'Phase 6 agent-as-user executor' host/templates/claude/agents/user-simulator.md` returns 1 line; `grep -c 'Phase 5' host/templates/claude/agents/user-simulator.md` after all 3.1 sub-steps returns 0.

#### Step 3.1b — opening paragraph (Phase 5 → Phase 6; execute the plan)

**Locate:**
```
You are the **user-simulator** for Shamt **Phase 5 (Test)** — the agent-as-user execution that runs
on **every** story (the required half of Phase 5; automated suites, when present, are run by
`test-executor`). You **act as a real user** of the project: you run its scripts/app, supply
realistic inputs, and judge whether the observed behavior matches what is expected. Your output is
`stories/{slug}/agent_test_session.md`.
```
**Replace:**
```
You are the **user-simulator** for Shamt **Phase 6 (Test)** — the agent-as-user execution that runs
on **every** story (the required half of Phase 6; automated suites, when present, are run by
`test-executor`). You **execute the scenarios in `user_test_plan.md`** — the mandatory agent-as-user
plan authored in Phase 4 (Test Plan). For each scenario you **act as a real user** of the project:
you run its scripts/app, supply the plan's inputs, and judge whether the observed behavior matches
the scenario's expected outcome. You do **not** improvise a testing approach the plan does not
declare. Your output is `stories/{slug}/agent_test_session.md`.
```
**Verification:** `grep -n 'execute the scenarios in .user_test_plan.md' host/templates/claude/agents/user-simulator.md` returns the new paragraph.

#### Step 3.1c — Inputs section (add `user_test_plan_path`; reframe `testing_standards_path`)

**Locate:**
```
## Inputs (provided by the caller)

- `slug` — story slug. Resolve the story folder per `templates/SHAMT_RULES.template.md` §PO-tree
  resolution (halt on multiple or zero).
- `testing_standards_path` — `.shamt-core/project-specific-files/TESTING_STANDARDS.md`. **Required** —
  it is the source of truth for how to drive the project as a user. If absent or still all
  placeholders, halt and direct the user to complete it.
```
**Replace:**
```
## Inputs (provided by the caller)

- `slug` — story slug. Resolve the story folder per `templates/SHAMT_RULES.template.md` §PO-tree
  resolution (halt on multiple or zero).
- `user_test_plan_path` — `stories/{slug}/user_test_plan.md` (or `user_test_plan_vN.md` per
  `active_artifacts.md`). **Required** — it is the validated, mandatory script you execute. If absent,
  halt and direct the caller to run Phase 4 (`/e4-write-test-plan {slug}`) first.
- `testing_standards_path` — `.shamt-core/project-specific-files/TESTING_STANDARDS.md`. **Required** —
  the conventions source for *how to drive* the project as a user (entry points, representative-input
  shapes, what to observe). It informs execution; it does not replace the plan's scenarios. If absent
  or still all placeholders, halt and direct the user to complete it.
```
**Verification:** `grep -n 'user_test_plan_path' host/templates/claude/agents/user-simulator.md` returns 1 line.

#### Step 3.1d — Pre-flight (read the plan, not improvise scenarios)

**Locate:**
```
## Pre-flight

1. Resolve the story folder; read `spec.md` (or the active baseline) for the story's acceptance
   criteria and `active_artifacts.md` when present.
2. Read `TESTING_STANDARDS.md` — the "Agent-as-user testing" section (how to drive the project,
   representative inputs, what to observe, standard scenarios, human-only out-of-scope).
3. Select scenarios: the project's "Standard scenarios" that this story touches, plus any
   story-specific journeys from the spec's acceptance criteria. Seed `agent_test_session.md` from
   `templates/agent_test_session.template.md`.
```
**Replace:**
```
## Pre-flight

1. Resolve the story folder; read `active_artifacts.md` when present (honour it ahead of unversioned
   defaults), and `spec.md` (or the active baseline) for the story's acceptance criteria.
2. Read `user_test_plan.md` completely — its Setup, every Scenario (Steps / Expected outcome /
   Pass-fail criterion), and Teardown. Confirm its validation footer is present; if missing, halt — an
   unvalidated user test plan must not be executed.
3. Read `TESTING_STANDARDS.md` "Agent-as-user testing" section for the how-to-drive conventions
   (entry points, representative-input shapes, what to observe) the plan's scenarios assume.
4. Seed `agent_test_session.md` from `templates/agent_test_session.template.md`, one block per
   `user_test_plan.md` scenario. You execute the plan's scenarios as written — you do **not** select
   or invent your own.
```
**Verification:** `grep -n 'Read .user_test_plan.md. completely' host/templates/claude/agents/user-simulator.md` returns 1 line.

#### Step 3.1e — Execution heading (reference the plan as the source)

**Locate:**
```
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
```
**Replace:**
```
## Execution (per scenario in `user_test_plan.md`)

1. **Drive** — run the scenario's Steps as written, driving the project as a user per the plan and
   the `TESTING_STANDARDS.md` conventions; **supply** the scenario's declared inputs. Capture the
   verbatim output (stdout + stderr + exit code) and any state change (files written, etc.).
2. **Judge** — compare Observed against the scenario's **Expected outcome** and **Pass/fail
   criterion** in `user_test_plan.md`:
   - **PASS** — the scenario's pass/fail criterion is satisfied in full. Log evidence (short, relevant
     excerpt).
   - **FAIL** — any mismatch. Log it; this scenario's bug routes to Phase 8 (see Failure handling).
   - **HALT** — cannot judge (the plan's expected/criterion is unclear, broken env). Log the reason;
     do not pass.
3. Update `agent_test_session.md` in place (Scenario block + Results row). Do not keep results in
   chat-only memory.
```
**Verification:** `grep -n 'Execution (per scenario in .user_test_plan.md' host/templates/claude/agents/user-simulator.md` returns 1 line; `grep -n 'routes to Phase 8' host/templates/claude/agents/user-simulator.md` returns 1 line.

#### Step 3.1f — Failure handling (Phase 5 re-run → Phase 6; `/e7` → `/e8`)

**Locate:**
```
A `FAIL` is a **post-implementation bug**. Per `reference/testing.md` and the rules, it routes through
`/e7-resolve-feedback`: log it as a feedback item, the fix is applied, and Phase 5 is **re-run to
green**. Polish requires a **root-cause section** in `addressed_feedback.md` (which of Spec / Plan /
Build let the bug through + the prevention). You do not fix code yourself — you report the failure
with enough observed-vs-expected detail for diagnosis.
```
**Replace:**
```
A `FAIL` is a **post-implementation bug**. Per `reference/testing.md` and the rules, it routes through
`/e8-resolve-feedback`: log it as a feedback item, the fix is applied, and Phase 6 is **re-run to
green**. Polish requires a **root-cause section** in `addressed_feedback.md` (which of Spec / Plan /
Build / Test Plan let the bug through + the prevention). You do not fix code yourself — you report the
failure with enough observed-vs-expected detail for diagnosis.
```
**Verification:** `grep -n '/e8-resolve-feedback' host/templates/claude/agents/user-simulator.md` returns 1 line; `grep -c '/e7-resolve-feedback' host/templates/claude/agents/user-simulator.md` returns 0.

#### Step 3.1g — Reports block (`/e7` → `/e8`)

**Locate:**
```
- `Session BLOCKED: N scenario(s) FAIL/HALT — routed to /e7-resolve-feedback.` (list them)
- `Cannot run: TESTING_STANDARDS.md missing/incomplete — complete it first.`
```
**Replace:**
```
- `Session BLOCKED: N scenario(s) FAIL/HALT — routed to /e8-resolve-feedback.` (list them)
- `Cannot run: user_test_plan.md missing/unvalidated — run /e4-write-test-plan first.`
- `Cannot run: TESTING_STANDARDS.md missing/incomplete — complete it first.`
```
**Verification:** `grep -n 'routed to /e8-resolve-feedback' host/templates/claude/agents/user-simulator.md` returns 1 line.

#### Step 3.1h — Hard rules (source of truth = the plan; drop `manual_test_plan.md`)

**Locate:**
```
- Source of truth is `TESTING_STANDARDS.md`; do not improvise a testing approach it does not declare.
- Never silently pass an ambiguous scenario — `HALT` and surface it.
- Human-only scenarios (real UI, cloud infra, multi-user) are **out of scope** here — they belong in
  an on-demand `manual_test_plan.md` for a human tester, not this required pass.
```
**Replace:**
```
- Source of truth is the validated `user_test_plan.md`; `TESTING_STANDARDS.md` supplies how-to-drive
  conventions only. Do not improvise scenarios the plan does not declare.
- Never silently pass an ambiguous scenario — `HALT` and surface it.
- Human-only scenarios (real UI, cloud infra, multi-user) belong out of band, not in this required
  pass; the `user_test_plan.md` scopes only the agent-executable scenarios.
```
**Verification:** `grep -c 'manual_test_plan' host/templates/claude/agents/user-simulator.md` returns 0; `grep -n 'validated .user_test_plan.md' host/templates/claude/agents/user-simulator.md` returns 1 line.

---

### Step 3.2 — Row 28: `test-executor.md` — opening paragraph (Phase 5 → 6; remove Quick/Standard planning split)

**Operation:** EDIT
**File:** `host/templates/claude/agents/test-executor.md`

**Locate:**
```
You are the **test executor** for Shamt Phase 5 (Test) — the **automated**-suite half (the agent-as-user execution is the `user-simulator` persona's job; you run only when `TESTING_STANDARDS.md` declares automated suites). The planning was done earlier — on the Standard path during Phase 3 (Plan) as `stories/{slug}/testing_plan.md`; on the Quick path with small test scope during Phase 2 (Spec) as the inline checklist in `spec.md`. Either way, the testing artifact was validated and approved before you spawn. Your job is to **run** the listed steps and log results back into the artifact.
```
**Replace:**
```
You are the **test executor** for Shamt Phase 6 (Test) — the **automated**-suite half (the agent-as-user execution is the `user-simulator` persona's job; you run only when `TESTING_STANDARDS.md` declares automated suites). The planning was done earlier — during Phase 4 (Test Plan) as `stories/{slug}/testing_plan.md`. The testing plan was validated and approved before you spawn. Your job is to **run** the listed steps and log results back into the artifact.
```
**Verification:** `grep -n 'Shamt Phase 6 (Test)' host/templates/claude/agents/test-executor.md` returns 1 line.

---

### Step 3.3 — Row 28: `test-executor.md` — `testing_plan_path` input (remove Quick-path inline-checklist case)

**Operation:** EDIT
**File:** `host/templates/claude/agents/test-executor.md`

**Locate:**
```
- `testing_plan_path` — the path to the validated `testing_plan.md` (or `testing_plan_vN.md` per `active_artifacts.md`). On the Quick path with the inline checklist, this is the active `spec.md` and the executor reads `### Quick path inline test checklist` instead of the full artifact.
```
**Replace:**
```
- `testing_plan_path` — the path to the validated `testing_plan.md` (or `testing_plan_vN.md` per `active_artifacts.md`).
```
**Verification:** `grep -c 'Quick path inline test checklist' host/templates/claude/agents/test-executor.md` returns 0.

---

### Step 3.4 — Row 28: `test-executor.md` — delete the whole "Quick-path inline checklist case" block

**Operation:** EDIT
**File:** `host/templates/claude/agents/test-executor.md`

**Locate:**
```
**Quick-path inline checklist case.** When `testing_plan_path` points to the active `spec.md` and you are reading `### Quick path inline test checklist`, the artifact has neither a `## Results Log` table nor a `## Failure Diagnosis` section (per `templates/spec.template.md`). Adapt the contract:

- The inline checklist's bullet shape is `- [ ] [Test name] - [invocation] - [pass criterion]`. On PASS, flip the checkbox to `- [x]` and append `— PASS YYYY-MM-DD <evidence excerpt>` after the pass criterion on the same line.
- On FAIL, leave the checkbox `- [ ]`, append `— FAIL YYYY-MM-DD <one-line diagnosis>` after the pass criterion, halt, and report via the standard `Step [N] failed: …` message. Do not invent a `## Failure Diagnosis` section in the spec — the orchestrator decides whether to escalate to a full `testing_plan.md` artifact via `/e3b-write-testing-plan {slug}`.
- The pre-flight footer check still applies — the spec's `Validated …` footer is what gates execution, since the inline checklist lives inside the validated spec.
- Post-execution: walk the checklist instead of a `Results Log` table — every bullet must be `- [x] … — PASS …`. Any bullet still `- [ ]` means Phase 5 has not exited; halt and report.

## Failure handling
```
**Replace:**
```
## Failure handling
```
**Verification:** `grep -c 'e3b-write-testing-plan' host/templates/claude/agents/test-executor.md` returns 0; `grep -c 'inline checklist' host/templates/claude/agents/test-executor.md` returns 0.

---

### Step 3.5 — Row 28: `test-executor.md` — Post-execution Phase 5 → Phase 6

**Operation:** EDIT
**File:** `host/templates/claude/agents/test-executor.md`

**Locate:**
```
1. Walk the entire `Results Log`. Every row must read `PASS`. If any row is still `BLOCKED`, `FAIL`, or `PENDING`, you have not exited Phase 5 — halt and report.
```
**Replace:**
```
1. Walk the entire `Results Log`. Every row must read `PASS`. If any row is still `BLOCKED`, `FAIL`, or `PENDING`, you have not exited Phase 6 — halt and report.
```
**Verification:** `grep -c 'have not exited Phase 5' host/templates/claude/agents/test-executor.md` returns 0.

---

### Step 3.6 — Row 28: `test-executor.md` — Reports `Phase 5` → `Phase 6` (validation footer parenthetical)

**Operation:** EDIT
**File:** `host/templates/claude/agents/test-executor.md`

> Note: line 100's footer `(Phase 6 implementation loop)` is a historical provenance marker referring to proposal #'s own implementation phase, NOT an Engineer-flow phase label — leave it unchanged. Only the in-body "Phase 5" Engineer-flow references are renumbered, all covered by Steps 3.2 and 3.5. After those, run the sweep below to confirm no other Engineer-flow "Phase 5" survives.

**Verification (whole-file sweep, no edit in this step):** `grep -n 'Phase 5' host/templates/claude/agents/test-executor.md` returns 0 lines; `grep -c '/e5\b' host/templates/claude/agents/test-executor.md` returns 0 (no `/e5` Engineer-phase reference survives — confirms the row-28 `/e5`→`/e6` requirement; if any line matches, halt as PLAN-BLOCKER for an unmapped reference).

---

### Step 3.7 — Row 29: `plan-executor.md` — story-altitude caller `/e4` → `/e5`

**Operation:** EDIT
**File:** `host/templates/claude/agents/plan-executor.md`

**Locate:**
```
- **Story altitude** (caller is `/e4-execute-plan`) — plan lives under `stories/{slug}/`; the working tree is on a `feature/{slug}/<owner-or-team>` branch baseline.
```
**Replace:**
```
- **Story altitude** (caller is `/e5-execute-plan`) — plan lives under `stories/{slug}/`; the working tree is on a `feature/{slug}/<owner-or-team>` branch baseline.
```
**Verification:** `grep -n 'caller is .\/e5-execute-plan' host/templates/claude/agents/plan-executor.md` returns 1 line.

---

### Step 3.8 — Row 29: `plan-executor.md` — Phase 4 (Build) → Phase 5 (Build) in the description frontmatter

**Operation:** EDIT
**File:** `host/templates/claude/agents/plan-executor.md`

**Locate:**
```
description: Mechanical Shamt builder — executes a validated implementation plan step by step at either the story altitude (Phase 4 Build, plan at stories/{slug}/implementation_plan.md) or the framework-update altitude (Phase 4 of /f3-implement-update, plan at proposals/{slug}_PLAN.md). Halts on ambiguity, verification failure, or any step that would require design judgment.
```
**Replace:**
```
description: Mechanical Shamt builder — executes a validated implementation plan step by step at either the story altitude (Phase 5 Build, plan at stories/{slug}/implementation_plan.md) or the framework-update altitude (Phase 4 of /f3-implement-update, plan at proposals/{slug}_PLAN.md). Halts on ambiguity, verification failure, or any step that would require design judgment.
```
**Verification:** `grep -n 'story altitude (Phase 5 Build' host/templates/claude/agents/plan-executor.md` returns 1 line.

> Note: the `(Phase 4 of /f3-implement-update …)` mention is a **framework-update** flow phase, NOT an Engineer-flow phase — it stays `Phase 4`. Only the story-altitude "Phase 4 Build" → "Phase 5 Build" changes.

---

### Step 3.9 — Row 29: `plan-executor.md` — Post-execution `/e4-execute-plan` Step 4 → `/e5-execute-plan` Step 4 (two sites)

**Operation:** EDIT
**File:** `host/templates/claude/agents/plan-executor.md`

**Locate:**
```
belong to the **architect**, who runs them at `/f3-implement-update` post-build (and `/e4-execute-plan` Step 4 at the story altitude). You were handed one phase; you cannot observe the others' output, so those invariants are not yours to grade.
```
**Replace:**
```
belong to the **architect**, who runs them at `/f3-implement-update` post-build (and `/e5-execute-plan` Step 4 at the story altitude). You were handed one phase; you cannot observe the others' output, so those invariants are not yours to grade.
```
**Verification:** `grep -c 'e4-execute-plan' host/templates/claude/agents/plan-executor.md` after Steps 3.7 + 3.9 + 3.10 returns 0.

---

### Step 3.10 — Row 29: `plan-executor.md` — report-target + hard-rule `/e4-execute-plan` → `/e5-execute-plan`

**Operation:** EDIT
**File:** `host/templates/claude/agents/plan-executor.md`

**Locate:**
```
3. Report back to the orchestrator (`/e4-execute-plan` at story altitude; `/f3-implement-update` at framework altitude) with one of the expected messages below.
```
**Replace:**
```
3. Report back to the orchestrator (`/e5-execute-plan` at story altitude; `/f3-implement-update` at framework altitude) with one of the expected messages below.
```
**Verification:** `grep -n '/e5-execute-plan. at story altitude' host/templates/claude/agents/plan-executor.md` returns 1 line.

---

### Step 3.11 — Row 29: `plan-executor.md` — hard-rule whole-plan invariant `/e4` Step 4 → `/e5` Step 4

**Operation:** EDIT
**File:** `host/templates/claude/agents/plan-executor.md`

**Locate:**
```
A whole-plan / cross-phase invariant — a zero-match sweep, an expected count, a link sweep depending on phases other than yours — is the architect's, run at `/f3` (and `/e4` Step 4) post-build.
```
**Replace:**
```
A whole-plan / cross-phase invariant — a zero-match sweep, an expected count, a link sweep depending on phases other than yours — is the architect's, run at `/f3` (and `/e5` Step 4) post-build.
```
**Verification:** `grep -c '(and /e4 Step 4)' host/templates/claude/agents/plan-executor.md` returns 0; `grep -n '(and /e5 Step 4)' host/templates/claude/agents/plan-executor.md` returns 1 line.

> Note: lines 92–93 footers `(Phase 6 implementation loop)` and `(Phase 8 implementation loop)` are framework-update-flow provenance markers, not Engineer-flow phase labels — leave unchanged.

---

### Step 3.12 — Row 30: `review-executor.md` — `/e6-review-changes` → `/e7-review-changes` (template reference)

**Operation:** verification-only
**File:** `host/templates/claude/agents/review-executor.md`

> Verified no-op: this step performs **no edit** — it runs the sweep below to confirm `review-executor.md` has no Engineer-flow `/e6`/`Phase 6` reference to renumber (see the Phase-author finding at the end of this step). Labeled `verification-only` to match the plan's no-op convention (cf. Step 3.26).

**Locate:**
```
- **Polish action:** <Specific update Polish must apply, or "None.">
```
> This line lives in `code_review.template.md`, not review-executor.md — see Step 3.20. The only Engineer-flow phase reference in `review-executor.md` is the `code_review.template.md` "Documentation Impact" pointer, which is in that template, not here. Re-locate the actual `/e6` reference below.

**Locate:**
```
[Story mode only — the Documentation Impact Assessment from `/e6-review-changes` Step 4. Omit in formal mode.]
```
> PLAN-BLOCKER check: this string is in `templates/code_review.template.md` (handled by Step 3.20), not `review-executor.md`. Re-verify the real review-executor.md content below before applying.

**Verification (no-edit locate-confirmation sweep):** `grep -n '/e6\|Phase 6\|Phase 7\|Quick\|Standard\|manual_test' host/templates/claude/agents/review-executor.md`. Per the full read, `review-executor.md` contains **no** Engineer-flow `/e6`/`Phase 6` reference, no Quick/Standard, and no `manual_test_plan` mention (its phase markers at line 165 are the historical `(Phase 6 implementation loop)` provenance footer only). Therefore **row 30 requires no edit** — confirm the sweep returns only the line-165 provenance footer; if it returns any other match, halt as PLAN-BLOCKER (the proposal row assumed a `/e6`/`Phase 6` reference that the file does not contain).

> **Phase-author finding:** Row 30 ("renumber Phase 6 → Phase 7 + `/e6`→`/e7`") has **no applicable site** in `host/templates/claude/agents/review-executor.md`. The file's only `Phase 6` token is the validation-footer provenance marker `(Phase 6 implementation loop)` (line 165), which is a framework-update-flow implementation-loop label, not an Engineer-flow phase label, and must NOT be renumbered. The `/e6-review-changes` reference the row targets lives in `templates/code_review.template.md` (row 38, Step 3.20 here) and in the `e6-review-changes.md` command body (row 9, a different phase). The builder should make **no edit** to `review-executor.md` and record this as a no-op, verified by the sweep above.

---

### Step 3.13 — Row 32: `spec.template.md` — remove the `Path:` header + `Context:` Standard-only framing

**Operation:** EDIT
**File:** `templates/spec.template.md`

#### Step 3.13a — header `Path:` + `Context:` rows

**Locate:**
```
**Path:** Quick path (default) | Standard path
**Status:** Draft
**Context:** stories/{slug}/context.md (Standard path or escalation only)
```
**Replace:**
```
**Status:** Draft
**Context:** stories/{slug}/context.md
```
**Verification:** `grep -c 'Quick path (default)' templates/spec.template.md` returns 0.

#### Step 3.13b — Test Strategy guidance: old-numbering `Phase-5` → `Phase-6`

> The Test (agent-as-user) stage is Phase 5 under the old numbering → Phase 6 under the new. This line is a row-32 old-numbering Engineer-flow phase reference (D7 / Terminology: no old-numbering "Phase {N}" may survive); the analogous `Phase 5 (Test)` references in the sibling templates are renumbered by Steps 3.22 / 3.31 / 3.35 / 3.36, so this one must be too.

**Locate:**
```
[Required (testing is a required phase). Always describe the Phase-5 agent-as-user scenarios; add automated detail when `TESTING_STANDARDS.md` declares suites.]
```
**Replace:**
```
[Required (testing is a required phase). Always describe the Phase-6 agent-as-user scenarios; add automated detail when `TESTING_STANDARDS.md` declares suites.]
```
**Verification:** `grep -c 'Phase-5' templates/spec.template.md` returns 0; `grep -n 'Phase-6 agent-as-user scenarios' templates/spec.template.md` returns 1 line.

---

### Step 3.14 — Row 32: `spec.template.md` — Test Strategy: drop the inline-checklist cross-ref

**Operation:** EDIT
**File:** `templates/spec.template.md`

**Locate:**
```
This section is approval-relevant at Gate 2b. The full plan lives in `testing_plan.md` (or, on the Quick path with simple scope, in the inline checklist below).

### Quick path inline test checklist

[Quick path only, and only when test scope is small (≤5 steps, no new test file). Otherwise escalate to a full `testing_plan.md` artifact.]

- [ ] [Test name] - [invocation] - [pass criterion]

---
```
**Replace:**
```
This section is approval-relevant at Gate 2b. The full test plans are authored in Phase 4 (Test Plan): the always-produced `user_test_plan.md` (agent-as-user scenarios) and, when `TESTING_STANDARDS.md` declares suites, `testing_plan.md` (automated).

---
```
**Verification:** `grep -c 'Quick path inline test checklist' templates/spec.template.md` returns 0.

---

### Step 3.15 — Row 32: `spec.template.md` — Review Prevention Gates HTML comment (drop Quick/Standard branch)

**Operation:** EDIT
**File:** `templates/spec.template.md`

**Locate:**
```
<!-- Quick path: if a surface applies, document the requirement and write a brief inline trace of the evidence/lineage under the 'Evidence' column or in a compact bullet list below this table. Standard path: point to the corresponding section of context.md. See `reference/pr_review_prevention.md`. -->
```
**Replace:**
```
<!-- For each applicable surface, point to the corresponding section of context.md (the always-produced evidence artifact). See `reference/pr_review_prevention.md`. -->
```
**Verification:** `grep -c 'Quick path:' templates/spec.template.md` returns 0.

---

### Step 3.16 — Row 32: `spec.template.md` — remove the Quick-path inline sections block

**Operation:** EDIT
**File:** `templates/spec.template.md`

The spec is always full (context.md + implementation_plan.md always produced), so the entire "Optional Quick path sections" block (the inline Evidence / Code Shapes / Build Checklist / Review Prevention Checklist / Verification / Post-Build Review sections used only when Quick path collapses everything into the spec) is removed. The validation footer line is preserved.

**Locate:**
```
---

## Optional Quick path sections

[If Quick path is selected, delete the separate context.md and implementation_plan.md and use these sections inline.]

## Evidence

### Research Findings
- [Targeted research findings with file paths]

### Current End-to-End Flow
```text
+-----------------------------+
| Surface/Path                |
+-----------------------------+
              |
              v
```

### Architecture And Standards Notes
- [Relevant `.shamt-core/project-specific-files/ARCHITECTURE.md` / `.shamt-core/project-specific-files/CODING_STANDARDS.md` notes — monitoring conventions, deployment patterns, naming, etc.]

### Review Prevention Evidence
- [Compact prevention evidence for applicable surfaces from `reference/pr_review_prevention.md`; if a surface is a risk trigger, escalate to Standard path instead.]

---

## Code Shapes

- `path/to/file.ext` - [what this function or code shape is]

---

## Build Checklist

0. BRANCH - In each affected repo, run `git fetch origin <development-branch>`, then `git checkout -b feature/{slug}/<owner-or-team> origin/<development-branch>`. If the feature branch already exists, stop and report instead of overwriting or resetting it.
1. EDIT `path/to/file.ext` - [short mechanical action]
2. VERIFY - [command or observable behavior]

---

## Review Prevention Checklist

- [ ] [Each applicable prevention gate maps to a build step, verification step, or N/A reason]
- [ ] [No regulated/sensitive data, tenant, auth, DB, infrastructure, frontend, testing, or removed-check obligation is left for build-time inference]

---

## Verification

- [ ] [Verification command or manual step]

---

## Post-Build Review

**Plan Alignment:** N/A - Quick path used spec Build Checklist instead of implementation_plan.md.

**Findings:** No issues found. / [If findings, document here or create feedback/review_v1.md]

---
[Append the validation footer only after Pattern 1 completes.]
```
**Replace:**
```
---
[Append the validation footer only after Pattern 1 completes.]
```
**Verification:** `grep -c 'Optional Quick path sections' templates/spec.template.md` returns 0; `grep -c 'Quick path' templates/spec.template.md` returns 0; `grep -c 'Standard path' templates/spec.template.md` returns 0; `tail -1 templates/spec.template.md` contains `[Append the validation footer only after Pattern 1 completes.]`; the footer line is the final content line with no stray trailing blank lines after the deleted block — `tail -2 templates/spec.template.md` shows that footer line as the last non-empty line (its `tail -1` is non-empty, i.e. `[ -n "$(tail -1 templates/spec.template.md)" ]`).

---

### Step 3.17 — Row 33: `context.template.md` — remove "Optional for Quick path" framing (context always produced)

**Operation:** EDIT
**File:** `templates/context.template.md`

**Locate:**
```
**Note:** Optional for Quick path (embedded Evidence section in spec.md is used instead). Created for Standard path, escalation, or when evidence becomes too large to keep inline.
```
**Replace:**
```
**Note:** Always produced — one of the mandatory spec-time artifacts (alongside `spec.md` and `implementation_plan.md`). Holds the story's research evidence, design rationale, and review-prevention investigation.
```
**Verification:** `grep -c 'Quick path' templates/context.template.md` returns 0; `grep -c 'Standard path' templates/context.template.md` returns 0.

---

### Step 3.18 — Row 34: `implementation_plan.template.md` — remove Quick/Standard from the Note + headers

**Operation:** EDIT
**File:** `templates/implementation_plan.template.md`

**Locate:**
```
**Note:** Optional for Quick path (embedded Build Checklist in spec.md is used instead). Required for Standard path, delegated builder execution, or when the checklist exceeds 10 steps.
```
**Replace:**
```
**Note:** Always produced — the mandatory Phase-3 (Plan) build artifact. Executed by the `plan-executor` builder during Phase 5 (Build).
```
**Verification:** `grep -c 'Quick path' templates/implementation_plan.template.md` after this + Step 3.19 returns 0.

---

### Step 3.19 — Row 34: `implementation_plan.template.md` — Context header + post-execution owner phase references

**Operation:** EDIT
**File:** `templates/implementation_plan.template.md`

#### Step 3.19a — Context header (drop the Quick-path N/A)

**Locate:**
```
**Context:** stories/{slug}/context.md (or `context_vN.md` for re-baselined stories) (Optional/N/A for Quick path)
**Path:** Quick path (escalation only) | Standard path
```
**Replace:**
```
**Context:** stories/{slug}/context.md (or `context_vN.md` for re-baselined stories)
```
**Verification:** `grep -c 'Optional/N/A for Quick path' templates/implementation_plan.template.md` returns 0; `grep -c '**Path:**' templates/implementation_plan.template.md` returns 0.

#### Step 3.19b — whole-plan Verification owner: `/e4-execute-plan` Step 4 → `/e5-execute-plan` Step 4, Phase 4 → Phase 5 (Build) — two sites

**Locate:**
```
**Owner: the architect, run at Phase 4 (Build) post-build** — `/e4-execute-plan` Step 4 (story altitude) / `/f3-implement-update` post-build (framework altitude). **Never the builder:** `plan-executor` is handed a single phase and cannot observe the other phases' output. **For a phase-decomposed plan this section lives in the *index* file, not any phase file**, and the architect runs it after the final phase reports `All steps completed. Verification passed.`
```
**Replace:**
```
**Owner: the architect, run at Phase 5 (Build) post-build** — `/e5-execute-plan` Step 4 (story altitude) / `/f3-implement-update` post-build (framework altitude). **Never the builder:** `plan-executor` is handed a single phase and cannot observe the other phases' output. **For a phase-decomposed plan this section lives in the *index* file, not any phase file**, and the architect runs it after the final phase reports `All steps completed. Verification passed.`
```
**Verification:** `grep -n 'run at Phase 5 (Build) post-build' templates/implementation_plan.template.md` returns 1 line; `grep -c '/e4-execute-plan Step 4' templates/implementation_plan.template.md` returns 0.

---

### Step 3.20 — Row 35: `testing_plan.template.md` — Note: remove Quick/Standard; point to Phase 4 + user_test_plan

**Operation:** EDIT
**File:** `templates/testing_plan.template.md`

**Locate:**
```
**Note:** Produced during Phase 3 (Plan) when `.shamt-core/project-specific-files/TESTING_STANDARDS.md` declares automated suites. On the Quick path, when test scope is small (≤5 steps, no new test file), the inline checklist in `spec.md` replaces this artifact. Executed during Phase 5 (Test) by the `test-executor` persona (see `reference/model_selection.md` — Haiku tier).
```
**Replace:**
```
**Note:** Produced during Phase 4 (Test Plan) when `.shamt-core/project-specific-files/TESTING_STANDARDS.md` declares automated suites — the automated half of the mandatory test-plan stage (the agent-as-user `user_test_plan.md` is the always-produced half). Executed during Phase 6 (Test) by the `test-executor` persona (see `reference/model_selection.md` — Haiku tier).
```
**Verification:** `grep -n 'Produced during Phase 4 (Test Plan)' templates/testing_plan.template.md` returns 1 line; `grep -c 'Quick path' templates/testing_plan.template.md` after this + Steps 3.21–3.23 returns 0.

---

### Step 3.21 — Row 35: `testing_plan.template.md` — headers: Implementation Plan + Path

**Operation:** EDIT
**File:** `templates/testing_plan.template.md`

**Locate:**
```
**Implementation Plan:** stories/{slug}/implementation_plan.md (or N/A on Quick path)
**Path:** Quick path | Standard path
**Baseline:** v1
```
**Replace:**
```
**Implementation Plan:** stories/{slug}/implementation_plan.md
**Baseline:** v1
```
**Verification:** `grep -c 'or N/A on Quick path' templates/testing_plan.template.md` returns 0; `grep -c '**Path:**' templates/testing_plan.template.md` returns 0.

---

### Step 3.22 — Row 35: `testing_plan.template.md` — Results Log Phase 5 → Phase 6 (two sites)

**Operation:** EDIT
**File:** `templates/testing_plan.template.md`

#### Step 3.22a

**Locate:**
```
Populated by the `test-executor` during Phase 5. Each step records pass/fail, evidence, and (if failed) the failure-diagnosis pointer.
```
**Replace:**
```
Populated by the `test-executor` during Phase 6. Each step records pass/fail, evidence, and (if failed) the failure-diagnosis pointer.
```
**Verification:** `grep -n 'test-executor. during Phase 6' templates/testing_plan.template.md` returns 1 line.

#### Step 3.22b

**Locate:**
```
**Status values:** `PENDING`, `PASS`, `FAIL`, `BLOCKED`. Phase 5 blocks until every step is `PASS` (the Phase-5 blocking rule — no exceptions or documented deferrals).
```
**Replace:**
```
**Status values:** `PENDING`, `PASS`, `FAIL`, `BLOCKED`. Phase 6 blocks until every step is `PASS` (the Phase-6 blocking rule — no exceptions or documented deferrals).
```
**Verification:** `grep -c 'Phase 5' templates/testing_plan.template.md` returns 0 after Steps 3.20 + 3.22.

---

### Step 3.23 — Row 35: `testing_plan.template.md` — Verification completeness cross-ref + exit (manual→user; remove Quick/Standard)

**Operation:** EDIT
**File:** `templates/testing_plan.template.md`

#### Step 3.23a — manual_test_plan → user_test_plan cross-ref

**Locate:**
```
- **Verification completeness** — Every spec requirement and every approval-relevant plan step maps to at least one test step, or has an explicit `Not testable here — covered by manual_test_plan.md` reason.
```
**Replace:**
```
- **Verification completeness** — Every spec requirement and every approval-relevant plan step maps to at least one test step, or has an explicit `Not testable here — covered by user_test_plan.md` reason.
```
**Verification:** `grep -c 'manual_test_plan' templates/testing_plan.template.md` returns 0.

#### Step 3.23b — exit line: remove Quick/Standard conditional (uniform exit)

**Locate:**
```
Severity ladder for findings: see `reference/severity_classification.md`. Exit: primary clean round + (on Standard path or risk-triggered) one adversarial sub-agent confirmation.
```
**Replace:**
```
Severity ladder for findings: see `reference/severity_classification.md`. Exit: one primary clean round + one adversarial sub-agent confirmation (uniform Pattern 1 exit — always).
```
**Verification:** `grep -c 'Standard path or risk-triggered' templates/testing_plan.template.md` returns 0; `grep -c 'Quick path' templates/testing_plan.template.md` returns 0; `grep -c 'Standard path' templates/testing_plan.template.md` returns 0.

---

### Step 3.24 — Row 36 (sub-step A): `git mv manual_test_plan.template.md` → `user_test_plan.template.md`

**Operation:** MOVE (CREATE half via `git mv`)
**File:** `templates/manual_test_plan.template.md` → `templates/user_test_plan.template.md`

**Details:**
- Run: `git mv templates/manual_test_plan.template.md templates/user_test_plan.template.md`

**Verification:** `test -f templates/user_test_plan.template.md && echo OK` prints `OK`.

---

### Step 3.25 — Row 36 (sub-step A cont.): full-content rewrite of `user_test_plan.template.md`

**Operation:** EDIT (whole-file replacement of the moved file)
**File:** `templates/user_test_plan.template.md`

The reframe is substantial: from a human-walkthrough on-demand artifact to a **mandatory, agent-as-user-executable** scenario plan that the `user-simulator` reads as its execution script in Phase 6. Remove Quick/Standard, drop the "human tester" framing, drop the Implementation-Plan "N/A on Quick path" caveat, retire the inline `Path:` header, and keep the per-run results log OUT of this template (it lives in `agent_test_session.md`, row 39). Replace the entire file body with the content below.

**Locate (whole current file body):**
```
# Manual Test Plan: {slug}

**Note:** Optional per-story artifact. Produced by `/e5b-write-manual-testing-plan {slug}` after Phase 4 (Build) or Phase 5 (Test). It is the on-demand **human-walkthrough** for scenarios the agent cannot simulate (real UI, cloud infra, multi-user) — **not** part of the required Phase-5 pass (which is the agent-as-user execution). Available on every story. The agent runs an inline validation loop using `reference/severity_classification.md` (Pattern 2) with the four dimensions listed at the bottom of this file before considering the plan drafted.
```
> Because this is a whole-file replacement, the builder uses `Write` to overwrite `templates/user_test_plan.template.md` with the full content below (the locate above only confirms the builder is editing the just-moved file before overwriting).

**Full replacement content:**
```markdown
# User Test Plan: {slug}

**Note:** Mandatory per-story artifact. Authored during Phase 4 (Test Plan) by `/e4-write-test-plan {slug}` — the always-produced half of the test-plan stage (the automated `testing_plan.md` is produced alongside only when `TESTING_STANDARDS.md` declares suites). It is the **agent-as-user execution script**: in Phase 6 (Test) the `user-simulator` persona reads this plan and executes every scenario by driving the project as a real user, logging the per-run results into `stories/{slug}/agent_test_session.md` (this plan holds the scenarios, not the run log). The agent runs an inline validation loop using `reference/severity_classification.md` (Pattern 2) with the four dimensions listed at the bottom of this file before considering the plan drafted.

**Created:** [Date]
**Story:** stories/{slug}/
<!-- Paths are relative to the resolved story folder (located per templates/SHAMT_RULES.template.md §PO-tree resolution; the folder nests under epics/.../features/.../). -->
**Spec:** stories/{slug}/spec.md (or `spec_vN.md` for re-baselined stories)
**Implementation Plan:** stories/{slug}/implementation_plan.md (or `implementation_plan_vN.md` for re-baselined stories)
**Testing Plan:** stories/{slug}/testing_plan.md (or N/A when TESTING_STANDARDS.md declares no automated suites)
**Baseline:** v1
**Baseline status:** Active

---

## Open Questions

[Only unresolved questions about coverage, environment, or scenario design that block plan completion. Per the open-questions iterative-dialog principle in `templates/SHAMT_RULES.template.md`, surface each question to the user one at a time and update the plan with each answer before moving on. Code-research every question first.]

---

## Setup

[Everything the agent needs before step 1 of scenario 1. The Setup section is complete if a fresh agent unfamiliar with the codebase can reach the starting state of scenario 1 by running the listed commands without external help. Defer the project's standing how-to-drive conventions (entry points, runner) to `.shamt-core/project-specific-files/TESTING_STANDARDS.md`; capture here only the story-specific preconditions.]

- **Environment state:** [Local dev / staging / production-shadow / etc. — be specific about which environment, and the exact commands to reach it.]
- **Test data:** [Records, files, fixtures that must exist. Include how to create them — script, fixture file, seed command — so the agent can produce them.]
- **Accounts / identities:** [Test users, roles, tenant identifiers required. Note where credentials are stored and how the agent supplies them.]
- **Feature flags:** [Flags that must be on/off; the exact command to toggle.]
- **External service state:** [Third-party sandboxes, webhook endpoints, mock servers. Note any auth or quota constraints.]
- **Tooling:** [CLI tools, dev server, etc. the agent invokes.]

---

## Scenarios

Each scenario is independently runnable by the `user-simulator` agent. Steps are imperative and specific (an exact command the agent runs, with the exact inputs to supply); the expected outcome is concrete and observable (not "looks right"); the pass/fail criterion is a binary check the agent can perform without judgment.

### Scenario 1: [Name]

**Starting state:** [What is true before you start — references the Setup section's resulting state.]

**Steps:**
1. [Imperative, agent-executable step. Be specific: the exact command to run and the exact input to supply — e.g., "Run `./bin/cli add --name 'Test Item'` and confirm at the prompt with `y`."]
2. [Step]
3. [Step]

**Expected outcome:** [Concrete, observable. Name the output line / response value / exit code / file written / state change the agent should observe. Avoid "looks right" or "works correctly".]

**Pass/fail criterion:** [Binary check the agent performs. Example: "stdout contains the line `Saved: Test Item` AND exit code is 0 AND `data/items.json` contains an entry with `name=Test Item`." NOT "Command runs correctly."]

---

### Scenario 2: [Name]

**Starting state:** [...]

**Steps:**
1. [...]

**Expected outcome:** [...]

**Pass/fail criterion:** [...]

---

[Add more scenarios as needed — cover at least one valid path and, where the spec implies it, one edge/invalid input path.]

---

## Teardown

[How to clean up after the run. Required even if minimal — a one-line `N/A — no shared state changed.` is acceptable when true.]

- [Delete created test data — command or step]
- [Reset feature flag state]
- [Revoke temporary credentials]
- [Restart services to clear in-memory state, if applicable]

---

## Coverage Note

[One paragraph: what the automated `testing_plan.md` covers for this story vs. what these agent-as-user scenarios cover. Gives the reviewer the full testing picture without re-reading both artifacts. If `testing_plan.md` does not exist for this story (no automated suites declared), say so and confirm the agent-as-user scenarios carry the story's verification.]

---

## Validation Dimensions

Inline validation runs Pattern 1 with these four dimensions (each finding classified per `reference/severity_classification.md`):

1. **Scope coverage** — Every risk area named in the spec's `Scope` / Requirements / Review Prevention Gates has at least one scenario that exercises it. A gap is **HIGH**.
2. **Step executability** — Each step is an unambiguous, agent-runnable command with the exact inputs to supply, so a fresh `user-simulator` agent can execute it without asking a question. Vague steps (e.g., "exercise the admin path") are **MEDIUM**.
3. **Observable pass/fail** — Every scenario's pass/fail criterion is a binary check the agent can perform without judgment (specific output line, response value, exit code, file/state change). "Looks right" or "works correctly" is **HIGH**.
4. **Setup completeness** — The Setup section provides enough detail that the agent can reach the starting state of scenario 1 without external help. Missing credentials or undocumented data dependencies are **HIGH**.

Exit: standard Pattern 1 exit per `/validate-artifact` (the source of truth for validation exits) — one primary clean round (0 issues or at most 1 LOW fixed) plus one adversarial sub-agent confirmation (uniform — always).

---
[Append the validation footer only after the validation loop completes for the user test plan.]
```
**Verification:** `head -1 templates/user_test_plan.template.md` reads `# User Test Plan: {slug}`; each pattern is asserted separately (a single combined `grep -c` returns one total count and cannot verify per-pattern results): `grep -c 'Quick path' templates/user_test_plan.template.md` returns 0, `grep -c 'Standard path' templates/user_test_plan.template.md` returns 0, `grep -c 'e5b-write-manual' templates/user_test_plan.template.md` returns 0, `grep -c 'human-walkthrough' templates/user_test_plan.template.md` returns 0, `grep -c 'human tester' templates/user_test_plan.template.md` returns 0, and `grep -c '## Scenarios' templates/user_test_plan.template.md` returns 1; `grep -c 'Results' templates/user_test_plan.template.md` returns 0 (no per-run results log duplicated into the plan); `grep -n 'user-simulator. persona reads this plan' templates/user_test_plan.template.md` returns 1 line.

---

### Step 3.26 — Row 36 (sub-step B): confirm the MOVE is complete

**Operation:** verification-only
**File:** `templates/manual_test_plan.template.md` / `templates/user_test_plan.template.md`

**Verification:** `test ! -f templates/manual_test_plan.template.md && test -f templates/user_test_plan.template.md && echo MOVE-OK` prints `MOVE-OK`.

---

### Step 3.27 — Row 37: `active_artifacts.template.md` — header `Path:` row removed

**Operation:** EDIT
**File:** `templates/active_artifacts.template.md`

**Locate:**
```
**Story:** {slug}
**Path:** Quick path | Standard path
**Active baseline:** vN
```
**Replace:**
```
**Story:** {slug}
**Active baseline:** vN
```
**Verification:** `grep -c 'Quick path | Standard path' templates/active_artifacts.template.md` returns 0.

---

### Step 3.28 — Row 37: `active_artifacts.template.md` — Active Files table rows (context/plan/testing/manual)

**Operation:** EDIT
**File:** `templates/active_artifacts.template.md`

Remove the `(or N/A — Quick path)` qualifiers from the Context, Implementation Plan, and Testing Plan rows, and rename the `Manual Test Plan` row to `User Test Plan` pointing at `user_test_plan.md`.

**Locate:**
```
| Context | `stories/{slug}/context_vN.md` (or `N/A — Quick path`) |
| Implementation Plan | `stories/{slug}/implementation_plan_vN.md` (or `N/A — Quick path`) |
| Testing Plan | `stories/{slug}/testing_plan_vN.md` (or `N/A — no automated suites` / `N/A — Quick path inline checklist`) |
| Manual Test Plan | `stories/{slug}/manual_test_plan_vN.md` (or `N/A — not produced`) |
```
**Replace:**
```
| Context | `stories/{slug}/context_vN.md` |
| Implementation Plan | `stories/{slug}/implementation_plan_vN.md` |
| Testing Plan | `stories/{slug}/testing_plan_vN.md` (or `N/A — no automated suites`) |
| User Test Plan | `stories/{slug}/user_test_plan_vN.md` |
```
**Verification:** `grep -c 'Manual Test Plan' templates/active_artifacts.template.md` returns 0; `grep -n 'User Test Plan' templates/active_artifacts.template.md` returns 1 line; `grep -c 'Quick path' templates/active_artifacts.template.md` returns 0.

---

### Step 3.29 — Row 38: `code_review.template.md` — Story-mode Plan Alignment (remove Quick/Standard branch)

**Operation:** EDIT
**File:** `templates/code_review.template.md`

**Locate:**
```
[Story mode only:
## Plan Alignment

- **Quick path (no plan):** Plan Alignment: N/A — Quick path used the spec Build Checklist instead of `implementation_plan.md`.
- **Standard path (plan exists):** [Run the Plan-Alignment Pre-Pass and list check results: Step Coverage, Change Fidelity, Scope Discipline, Verification Passage, Zero Builder Design Decisions]
]
```
**Replace:**
```
[Story mode only:
## Plan Alignment

[Run the Plan-Alignment Pre-Pass and list check results: Step Coverage, Change Fidelity, Scope Discipline, Verification Passage, Zero Builder Design Decisions. Every story has an `implementation_plan.md` (Plan is a mandatory stage), so Plan Alignment is always run.]
]
```
**Verification:** `grep -c 'Quick path' templates/code_review.template.md` returns 0; `grep -c 'Standard path' templates/code_review.template.md` returns 0.

---

### Step 3.30 — Row 38: `code_review.template.md` — Documentation Impact `/e6-review-changes` → `/e7-review-changes`

**Operation:** EDIT
**File:** `templates/code_review.template.md`

**Locate:**
```
[Story mode only — the Documentation Impact Assessment from `/e6-review-changes` Step 4. Omit in formal mode.]
```
**Replace:**
```
[Story mode only — the Documentation Impact Assessment from `/e7-review-changes` Step 4. Omit in formal mode.]
```
**Verification:** `grep -c '/e6-review-changes' templates/code_review.template.md` returns 0; `grep -n '/e7-review-changes' templates/code_review.template.md` returns 1 line.

---

### Step 3.31 — Row 39: `agent_test_session.template.md` — Note: Phase 5 → Phase 6; reference user_test_plan as executed source; `/e5`→`/e6`

**Operation:** EDIT
**File:** `templates/agent_test_session.template.md`

**Locate:**
```
**Note:** Required per-story Phase 5 artifact. Produced and executed by the `user-simulator` persona
(invoked by `/e5-execute-tests {slug}`), which drives the project as a user per
`.shamt-core/project-specific-files/TESTING_STANDARDS.md` and the story's spec. Every scenario must
end `PASS`; ambiguous results are logged `HALT` (never silently passed) and surfaced.
```
**Replace:**
```
**Note:** Required per-story Phase 6 artifact — the run log of the agent-as-user execution. Produced
by the `user-simulator` persona (invoked by `/e6-execute-tests {slug}`), which **executes the
scenarios in `stories/{slug}/user_test_plan.md`** (the mandatory Phase-4 plan), driving the project
as a user with the how-to-drive conventions from
`.shamt-core/project-specific-files/TESTING_STANDARDS.md`. Every scenario must end `PASS`; ambiguous
results are logged `HALT` (never silently passed) and surfaced.
```
**Verification:** `grep -n 'Required per-story Phase 6 artifact' templates/agent_test_session.template.md` returns 1 line; `grep -n 'executes the' templates/agent_test_session.template.md` and `grep -n 'user_test_plan.md' templates/agent_test_session.template.md` each return ≥1 line.

---

### Step 3.32 — Row 39: `agent_test_session.template.md` — Scenarios derivation source → user_test_plan.md

**Operation:** EDIT
**File:** `templates/agent_test_session.template.md`

**Locate:**
```
Derived from `TESTING_STANDARDS.md` "Standard scenarios" + this story's acceptance criteria. One
block per scenario.
```
**Replace:**
```
One block per scenario in `stories/{slug}/user_test_plan.md` — this session logs the execution of
that plan's scenarios (driven with the `TESTING_STANDARDS.md` how-to-drive conventions), not a
separately derived scenario set.
```
**Verification:** `grep -c 'Standard scenarios' templates/agent_test_session.template.md` returns 0.

---

### Step 3.33 — Row 39: `agent_test_session.template.md` — Scenario result routing `/e7` → `/e8`

**Operation:** EDIT
**File:** `templates/agent_test_session.template.md`

**Locate:**
```
- **Result:** [PASS | FAIL | HALT]  ([on FAIL] → routed to `/e7-resolve-feedback`; [on HALT] → reason)
```
**Replace:**
```
- **Result:** [PASS | FAIL | HALT]  ([on FAIL] → routed to `/e8-resolve-feedback`; [on HALT] → reason)
```
**Verification:** `grep -c '/e7-resolve-feedback' templates/agent_test_session.template.md` returns 0; `grep -n '/e8-resolve-feedback' templates/agent_test_session.template.md` returns 1 line.

---

### Step 3.34 — Row 40: `testing_standards.template.md` — How-to-Update phase references (Phase 6/7 → 7/8)

**Operation:** EDIT
**File:** `templates/testing_standards.template.md`

The front-matter `How to Update` block names "Phase 6 (Review)" and "Phase 7 (Polish)" — under the new numbering Review is Phase 7 and Polish is Phase 8.

**Locate:**
```
  Engineer flow, and amend the relevant sections of this file. Phase 6 (Review) flags whether a
  story implies an update; Phase 7 (Polish) applies it and re-validates.
```
**Replace:**
```
  Engineer flow, and amend the relevant sections of this file. Phase 7 (Review) flags whether a
  story implies an update; Phase 8 (Polish) applies it and re-validates.
```
**Verification:** `grep -n 'Phase 7 (Review)' templates/testing_standards.template.md` returns 1 line; `grep -c 'Phase 6 (Review)' templates/testing_standards.template.md` returns 0.

---

### Step 3.35 — Row 40: `testing_standards.template.md` — Purpose + threading phase references (Phase 5→6, Phase 3→4)

**Operation:** EDIT
**File:** `templates/testing_standards.template.md`

**Locate:**
```
**Purpose:** The source of truth for how this project is verified. Read by **Phase 5 (Test)** — a
**required** Engineer-flow stage — to drive the per-story agent-as-user execution and to know
whether automated suites exist. Threaded into Phase 2 (Spec) Test Strategy and Phase 3 (Plan)
testing-plan drafting.
```
**Replace:**
```
**Purpose:** The source of truth for how this project is verified. Read by **Phase 6 (Test)** — a
**required** Engineer-flow stage — to drive the per-story agent-as-user execution and to know
whether automated suites exist. Threaded into Phase 2 (Spec) Test Strategy and Phase 4 (Test Plan)
test-plan drafting (both the agent-as-user `user_test_plan.md` and the automated `testing_plan.md`).
```
**Verification:** `grep -n 'Read by \*\*Phase 6 (Test)\*\*' templates/testing_standards.template.md` returns 1 line; `grep -c 'Phase 5 (Test)' templates/testing_standards.template.md` returns 0.

---

### Step 3.36 — Row 40: `testing_standards.template.md` — body Phase 5 references (two sites) + manual→user

**Operation:** EDIT
**File:** `templates/testing_standards.template.md`

#### Step 3.36a — Automated-test-infra Phase 5 → Phase 6

**Locate:**
```
[Does this project have automated tests? Fill **Present** or **None**. If None, Phase 5 runs the
agent-as-user execution only.]
```
**Replace:**
```
[Does this project have automated tests? Fill **Present** or **None**. If None, Phase 6 runs the
agent-as-user execution only.]
```
**Verification:** `grep -c 'If None, Phase 5' templates/testing_standards.template.md` returns 0.

#### Step 3.36b — Agent-as-user section Phase 5 → Phase 6

**Locate:**
```
How the `user-simulator` persona drives this project **as a user** during Phase 5. Be concrete
enough that a fresh agent can run the project and supply realistic inputs without guessing.
```
**Replace:**
```
How the `user-simulator` persona drives this project **as a user** during Phase 6 (executing the
story's `user_test_plan.md` scenarios). Be concrete enough that a fresh agent can run the project and
supply realistic inputs without guessing.
```
**Verification:** `grep -c 'during Phase 5' templates/testing_standards.template.md` returns 0.

#### Step 3.36c — Out-of-scope manual_test_plan reference → out-of-band / user-plan framing

**Locate:**
```
- **Out of scope for the agent (human-only):** [Scenarios the agent cannot simulate — real UI
  interaction, cloud infra, multi-user, external paid integrations — which belong in an on-demand
  `manual_test_plan.md` for a human tester, not the required Phase-5 pass.]
```
**Replace:**
```
- **Out of scope for the agent (human-only):** [Scenarios the agent cannot simulate — real UI
  interaction, cloud infra, multi-user, external paid integrations — which are handled out of band by
  a human, not scoped into the story's `user_test_plan.md` or the required Phase-6 pass.]
```
**Verification:** `grep -c 'manual_test_plan' templates/testing_standards.template.md` returns 0; `grep -c 'Phase 5' templates/testing_standards.template.md` returns 0 (whole-file, after all 3.34–3.36 edits).

---

## Phase notes

- **Ordering.** Steps are independent across files; within a file they are ordered top-to-bottom so locate strings do not shift. The only multi-substep MOVE (row 36) runs `git mv` (Step 3.24) before the body rewrite (Step 3.25) and the move-completion check (Step 3.26).
- **Row 30 is a no-op (phase-author finding).** `host/templates/claude/agents/review-executor.md` contains no Engineer-flow `/e6`/`Phase 6` reference, no Quick/Standard, and no `manual_test_plan` mention — its only `Phase 6` token is the historical `(Phase 6 implementation loop)` validation-footer provenance marker (a framework-update-flow label, NOT renumbered). Step 3.12 records this as a verified no-op; the `/e6-review-changes` reference the proposal row alludes to actually lives in `templates/code_review.template.md` (handled by Step 3.30) and the `e6-review-changes.md` command body (a different phase). If the builder finds an actual `/e6` reference in `review-executor.md`, halt as a PLAN-BLOCKER.
- **user_test_plan rename.** The artifact rename `manual_test_plan.md` → `user_test_plan.md` is reflected in: the template MOVE (rows 36 / Steps 3.24–3.26), the active-artifacts row rename (row 37 / Step 3.28), the testing_plan cross-ref (row 35 / Step 3.23a), the testing_standards out-of-scope note (row 40 / Step 3.36c), and the user-simulator rewrite (row 27 / Step 3.1). No `manual_test_plan` string survives in any phase-3 file (per-file zero-count verifications above).
- **agent_test_session vs plan-template separation.** The per-run **results/log** stay in `agent_test_session.md` (template row 39); `user_test_plan.template.md` (row 36) holds **only the scenarios** (Setup / Scenarios / Teardown / Coverage / Validation Dimensions) and explicitly carries **no** Results table — the user-simulator reads the plan and writes the run log into the session artifact. Step 3.25's verification asserts `grep -c 'Results' = 0` on the plan template to enforce this; Step 3.32 repoints the session's scenario-derivation note to `user_test_plan.md`.
- **Phase-label discipline.** Validation-footer provenance markers like `(Phase 6 implementation loop)` / `(Phase 8 implementation loop)` in `test-executor.md`, `plan-executor.md`, and `review-executor.md` are framework-update-flow implementation-loop labels, NOT Engineer-flow phase labels, and are deliberately left unchanged. Likewise the `(Phase 4 of /f3-implement-update)` mention in plan-executor's description is a framework-flow phase and stays `Phase 4`. Only Engineer-flow phase labels are renumbered.
- **Uniform validation.** Where templates carried a Quick/Standard validation-exit conditional (testing_plan exit line, user_test_plan exit line), it is collapsed to the uniform Pattern-1 exit (one primary clean round + one adversarial sub-agent, always), per the proposal's framework-wide retirement of the rigor selector.
```

---
Validated 2026-06-21 — 2 rounds, 1 adversarial sub-agent confirmed
