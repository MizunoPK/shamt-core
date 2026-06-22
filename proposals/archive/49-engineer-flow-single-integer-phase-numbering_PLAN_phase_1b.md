# Implementation Plan — Phase 1b: Engineer command renames + e-all + validate-artifact (rows 7–13)

**Proposal:** proposals/49-engineer-flow-single-integer-phase-numbering.md
**Plan index:** proposals/49-engineer-flow-single-integer-phase-numbering_PLAN.md
**Covers:** Proposed Changes rows 7–13 (host/templates/claude/commands/ — the five MOVE renames e4→e5 / e5→e6 / e6→e7 / e7→e8 / e8→e9, plus e-all.md and validate-artifact.md EDITs)
**Created:** 2026-06-21

All paths below are relative to the repo root `/home/kai/code/shamt-core/`. Every EDIT/MOVE targets a **canonical source** under `host/templates/claude/commands/` — never `.claude/`. The renamed e6/e7/e8/e-all files carry proposal #50's PR-centric behavior at HEAD; every step preserves it (renumber + Quick/Standard-removal + manual→user deltas ONLY). (Step numbering is shared with Phase 1a — IDs `Step 1.30`–`Step 1.107` live here; `Step 1.1`–`Step 1.29` live in Phase 1a. **Run Phase 1a before Phase 1b.**)

## Steps

### Step 1.30 — MOVE e4-execute-plan.md → e5-execute-plan.md, sub-step A: git mv (row 7)

**Operation:** MOVE-as-paired-CREATE+DELETE (sub-step A — rename)
**Command:** `git mv host/templates/claude/commands/e4-execute-plan.md host/templates/claude/commands/e5-execute-plan.md`
**Verification:** `test ! -f host/templates/claude/commands/e4-execute-plan.md && test -f host/templates/claude/commands/e5-execute-plan.md`. (Body edits follow in Steps 1.31–1.39; sub-step B verification is Step 1.40.)

### Step 1.31 — EDIT e5-execute-plan.md frontmatter description (Phase 5; remove Quick inline build)

**Operation:** EDIT
**File:** `host/templates/claude/commands/e5-execute-plan.md`
**Locate:**
```
description: Phase 4 (Build) — execute the approved implementation_plan.md (Standard path, via the plan-executor builder persona) or run the spec's Build Checklist directly (Quick path)
```
**Replace:**
```
description: Phase 5 (Build) — execute the approved implementation_plan.md via the plan-executor builder persona (architect/builder split); plan-executor always runs; next phase is /e6-execute-tests
```
**Verification:** `grep -F 'Phase 5 (Build)' host/templates/claude/commands/e5-execute-plan.md` returns ≥1. `grep -F 'Build Checklist directly (Quick path)' host/templates/claude/commands/e5-execute-plan.md` returns 0.

### Step 1.32 — EDIT e5-execute-plan.md title + Purpose

**Operation:** EDIT
**File:** `host/templates/claude/commands/e5-execute-plan.md`
**Locate:**
```
# /e4-execute-plan

**Purpose:** Run Phase 4 (Build) of the Engineer flow. Standard path hands off the validated `implementation_plan.md` to the `plan-executor` builder persona (architect/builder split — the architect's planning ended at Gate 3; the cheap-tier builder executes mechanically). Quick path executes the spec's Build Checklist inline because no separate plan exists.
```
**Replace:**
```
# /e5-execute-plan

**Purpose:** Run Phase 5 (Build) of the Engineer flow. Hand off the validated `implementation_plan.md` to the `plan-executor` builder persona (architect/builder split — the architect's planning ended at Gate 3; the cheap-tier builder executes mechanically). Every story has a validated plan (Plan is mandatory), so the builder handoff is **unconditional** — there is no inline build path.
```
**Verification:** `grep -F '# /e5-execute-plan' host/templates/claude/commands/e5-execute-plan.md` returns 1. `grep -F '# /e4-execute-plan' host/templates/claude/commands/e5-execute-plan.md` returns 0. `grep -F 'Quick path executes the spec' host/templates/claude/commands/e5-execute-plan.md` returns 0.

### Step 1.33 — EDIT e5-execute-plan.md Recommended-models (drop Quick-path execution row)

**Operation:** EDIT
**File:** `host/templates/claude/commands/e5-execute-plan.md`
**Locate:**
```
- Orchestration (this command): Balanced (Sonnet) — the orchestrator monitors the builder, surfaces ambiguity to the user, and decides whether to patch the plan, re-baseline, or re-hand off.
- Standard-path execution: Cheap (Haiku) via [`agents/plan-executor.md`](../agents/plan-executor.md).
- Quick-path execution: Balanced (Sonnet) — the primary agent executes the Build Checklist directly.
```
**Replace:**
```
- Orchestration (this command): Balanced (Sonnet) — the orchestrator monitors the builder, surfaces ambiguity to the user, and decides whether to patch the plan, re-baseline, or re-hand off.
- Execution: Cheap (Haiku) via [`agents/plan-executor.md`](../agents/plan-executor.md).
```
**Verification:** `grep -F 'Quick-path execution:' host/templates/claude/commands/e5-execute-plan.md` returns 0.

### Step 1.34 — EDIT e5-execute-plan.md Usage block

**Operation:** EDIT
**File:** `host/templates/claude/commands/e5-execute-plan.md`
**Locate:**
```
/e4-execute-plan {slug}
```
**Replace:**
```
/e5-execute-plan {slug}
```
**Verification:** `grep -F '/e4-execute-plan {slug}' host/templates/claude/commands/e5-execute-plan.md` returns 0.

### Step 1.35 — EDIT e5-execute-plan.md Prerequisites (drop Quick-path prereq + collapse Standard-path label)

**Operation:** EDIT
**File:** `host/templates/claude/commands/e5-execute-plan.md`
**Locate:**
```
- **Standard path:** the active `implementation_plan.md` (or the active phase file from a phase-decomposed plan) exists with a validation footer and is approved at Gate 3. If missing or unfootered, halt and direct the user to `/e3-plan-implementation {slug}`.
- **Quick path:** the active `spec.md` has a populated `## Build Checklist` section. If missing, halt and direct the user back to `/e2-define-spec {slug}`.
```
**Replace:**
```
- The active `implementation_plan.md` (or the active phase file from a phase-decomposed plan) exists with a validation footer and is approved at Gate 3. If missing or unfootered, halt and direct the user to `/e3-plan-implementation {slug}`.
```
**Verification:** `grep -F '**Quick path:** the active `spec.md`' host/templates/claude/commands/e5-execute-plan.md` returns 0.

### Step 1.36 — EDIT e5-execute-plan.md remove the "## Path selection" section

**Operation:** EDIT
**File:** `host/templates/claude/commands/e5-execute-plan.md`
**Locate:**
```
## Path selection

Read the active spec's `Path:` header.

- `Path: Quick path` → run the **Quick build** flow below.
- `Path: Standard path` → run the **Standard build** flow below.

State the chosen flow and reason in one line before the first action.

## Standard build (architect/builder split)
```
**Replace:**
```
## Build (architect/builder split)
```
**Verification:** `grep -c '## Path selection' host/templates/claude/commands/e5-execute-plan.md` returns 0. `grep -F '## Build (architect/builder split)' host/templates/claude/commands/e5-execute-plan.md` returns 1.

### Step 1.37 — EDIT e5-execute-plan.md Step 5 Exit next-phase pointer (→ /e6) + drop e5b suggestion

**Operation:** EDIT
**File:** `host/templates/claude/commands/e5-execute-plan.md`
**Locate:**
```
- Always → `/clear`, then `/e5-execute-tests {slug}` (Phase 5 — **required**). Phase 5 runs the
  agent-as-user execution (and automated suites when `TESTING_STANDARDS.md` declares them), then suggests
  `/e6-review-changes {slug}`.

Suggest `/e5b-write-manual-testing-plan {slug}` (orthogonal to the required Phase-5 agent-as-user execution) when the story touched UI behavior, cloud infra, external integrations, or multi-user flows — per [`SHAMT_RULES.template.md`](../../../../templates/SHAMT_RULES.template.md#optional-post-build-artifact).
```
**Replace:**
```
- Always → `/clear`, then `/e6-execute-tests {slug}` (Phase 6 — Test, **required**). Phase 6 runs the
  agent-as-user execution of `user_test_plan.md` (and automated suites when `TESTING_STANDARDS.md` declares them), then suggests
  `/e7-review-changes {slug}`.
```
**Verification:** `grep -F '/e6-execute-tests {slug}` (Phase 6 — Test' host/templates/claude/commands/e5-execute-plan.md` returns 1. (The `/e5b-write-manual-testing-plan` zero-check is deferred to Step 1.38's verification — a second e5b reference lives in the `## Quick build` section that Step 1.38 removes, so the file-wide e5b-zero assertion can only hold after Step 1.38.)

### Step 1.38 — EDIT e5-execute-plan.md remove the entire "## Quick build (direct execution)" section

**Operation:** EDIT
**File:** `host/templates/claude/commands/e5-execute-plan.md`
**Locate:** the whole block beginning with the heading `## Quick build (direct execution)` and ending with the sentence `that is the escalation signal.` — i.e. from:
```
## Quick build (direct execution)

No `implementation_plan.md` exists on the Quick path — the spec's `## Build Checklist` is the executable artifact (per Pattern 5 in [`SHAMT_RULES.template.md`](../../../../templates/SHAMT_RULES.template.md#pattern-5-implementation-planning)). The primary agent (you) executes the checklist directly.
```
through (inclusive):
```
Quick-path Build does not hand off to `plan-executor` (no validated plan to feed it). If you find yourself wanting a builder, that is the escalation signal.
```
**Replace:** (delete the entire block — replace with nothing/empty)
**Verification:** `grep -c '## Quick build (direct execution)' host/templates/claude/commands/e5-execute-plan.md` returns 0. `grep -F 'Quick-path Build does not hand off' host/templates/claude/commands/e5-execute-plan.md` returns 0. `grep -F '/e5b-write-manual-testing-plan' host/templates/claude/commands/e5-execute-plan.md` returns 0 (deferred from Step 1.37 — now that the Quick build section is removed, no e5b reference remains anywhere in the file).

### Step 1.39 — EDIT e5-execute-plan.md Exit-criteria + footer-comment Quick/Standard residue + regen path

**Operation:** EDIT
**File:** `host/templates/claude/commands/e5-execute-plan.md`
**Locate:**
```
- The plan's (or spec's) `## Verification` section passes end-to-end.
- The plan's `## Review Prevention Gate Mapping` (Standard) or the spec's `## Review Prevention Checklist` (Quick) is satisfied or explicitly N/A per stored reason.
- The builder (Standard) reported `All steps completed. Verification passed.` and you confirmed it post-builder.
```
**Replace:**
```
- The plan's `## Verification` section passes end-to-end.
- The plan's `## Review Prevention Gate Mapping` is satisfied or explicitly N/A per stored reason.
- The builder reported `All steps completed. Verification passed.` and you confirmed it post-builder.
```
**Verification:** `grep -nE 'Quick path|Standard path|Quick-path|Standard-path|\(Quick\)|\(Standard\)' host/templates/claude/commands/e5-execute-plan.md` returns 0 matches.

### Step 1.39b — EDIT e5-execute-plan.md regen-path footer comment

**Operation:** EDIT
**File:** `host/templates/claude/commands/e5-execute-plan.md`
**Locate:**
```
<!-- Managed by Shamt — do not edit. Regenerate from shamt-core/host/templates/claude/commands/e4-execute-plan.md. -->
```
**Replace:**
```
<!-- Managed by Shamt — do not edit. Regenerate from shamt-core/host/templates/claude/commands/e5-execute-plan.md. -->
```
**Verification:** `grep -F 'Regenerate from shamt-core/host/templates/claude/commands/e5-execute-plan.md.' host/templates/claude/commands/e5-execute-plan.md` returns 1. `grep -F 'e4-execute-plan.md.' host/templates/claude/commands/e5-execute-plan.md` returns 0.

> Note: the body of e5-execute-plan.md retains its existing `/e5-execute-tests`/`/e6-review-changes` Step-5 references only where renumbered above; Step 3's `/e3-plan-implementation` patch-the-plan references stay correct (Plan is still Phase 3). The Step 1.37 patch is the only next-phase pointer needing renumber. **The `#optional-post-build-artifact` SHAMT_RULES anchor that the old e4 Step-5 linked is removed entirely (the e5b suggestion is deleted), so e5-execute-plan.md carries no inbound link to that anchor after Step 1.37 — the only surviving inbound link to it is in validate-artifact.md (Step 1.61). This resolves the proposal row 7 "e4/e5-execute-plan.md anchor inbound link" concern by deletion.**

### Step 1.40 — MOVE row 7 sub-step B verification (rename + #50-N/A + renumber-only diff)

**Operation:** MOVE-as-paired-CREATE+DELETE (sub-step B — verify)
**Verification:**
- `test ! -f host/templates/claude/commands/e4-execute-plan.md && test -f host/templates/claude/commands/e5-execute-plan.md`.
- `git diff HEAD -- host/templates/claude/commands/e4-execute-plan.md host/templates/claude/commands/e5-execute-plan.md` (eyeball — via `git log --follow`/rename detection): the delta is renumber (Phase 4→5; `/e4`→`/e5`; next-phase `/e5-execute-tests`→`/e6-execute-tests`, `/e6-review-changes`→`/e7-review-changes`) + Quick/Standard removal (Path selection section, Quick build section, Quick-path prereq/exit clauses) + the e5b-suggestion removal ONLY. No behavior added or dropped beyond those deltas.
- #50 does not touch this file, so no #50-marker survival grep applies here. `grep -nE 'Quick path|Standard path|Quick-path|Standard-path|\(Quick\)|\(Standard\)|Quick build' host/templates/claude/commands/e5-execute-plan.md` returns 0 matches. (Precise retired-concept patterns — a bare `Quick|Standard` would false-match benign doc names like "Coding Standards".)
- **No stale phase numbers survive in the body** (the historical validation-footer `(Phase 6 implementation loop)` provenance line is **left intact** per Principle 3): `grep -F 'Phase 4 (Build)' host/templates/claude/commands/e5-execute-plan.md` returns 0 (the old Build self-label "Phase 4 (Build)" is renumbered to "Phase 5 (Build)"). A **bare** "Phase 4" is NOT forbidden — Phase 4 is now Test Plan, a legitimate sibling reference. NOTE: the Notes "single-session sizing constraint" bullet legitimately references **Phase 3** (Plan, which keeps its number) — `grep -F 'split at Phase 3' host/templates/claude/commands/e5-execute-plan.md` returns 1 and is **correct**, not a stale ref.

### Step 1.41 — MOVE e5-execute-tests.md → e6-execute-tests.md, sub-step A: git mv (row 8)

**Operation:** MOVE-as-paired-CREATE+DELETE (sub-step A — rename)
**Command:** `git mv host/templates/claude/commands/e5-execute-tests.md host/templates/claude/commands/e6-execute-tests.md`
**Verification:** `test ! -f host/templates/claude/commands/e5-execute-tests.md && test -f host/templates/claude/commands/e6-execute-tests.md`. (Body edits follow in Steps 1.42–1.51c; sub-step B verification is Step 1.52.)

### Step 1.42 — EDIT e6-execute-tests.md frontmatter description (Phase 6; route failures to /e8; next /e7; user_test_plan)

**Operation:** EDIT
**File:** `host/templates/claude/commands/e6-execute-tests.md`
**Locate:**
```
description: Phase 5 (Test, required) — drive the project as a user via the user-simulator persona (always) plus the automated testing_plan.md via test-executor (when TESTING_STANDARDS.md declares suites); a failure routes to /e7 with a required root-cause section; blocks until green
```
**Replace:**
```
description: Phase 6 (Test, required) — execute user_test_plan.md as a user via the user-simulator persona (always) plus the automated testing_plan.md via test-executor (when TESTING_STANDARDS.md declares suites); a failure routes to /e8 with a required root-cause section; blocks until green
```
**Verification:** `grep -F 'Phase 6 (Test, required)' host/templates/claude/commands/e6-execute-tests.md` returns 1. `grep -F 'a failure routes to /e8' host/templates/claude/commands/e6-execute-tests.md` returns 1. `grep -F 'execute user_test_plan.md as a user' host/templates/claude/commands/e6-execute-tests.md` returns 1.

### Step 1.43 — EDIT e6-execute-tests.md title + Purpose (execute user_test_plan; route to /e8)

**Operation:** EDIT
**File:** `host/templates/claude/commands/e6-execute-tests.md`
**Locate:**
```
# /e5-execute-tests

**Purpose:** Run the **required** Phase 5 (Test). Always perform the **agent-as-user execution** — hand off to the `user-simulator` persona, which drives the project as a user per `TESTING_STANDARDS.md` and writes `agent_test_session.md`. When `TESTING_STANDARDS.md` declares automated suites, also run them via the `test-executor` persona. **Block until every scenario / step reports `PASS`.** A failure is a post-implementation bug → route to `/e7-resolve-feedback` (see Step 3).
```
**Replace:**
```
# /e6-execute-tests

**Purpose:** Run the **required** Phase 6 (Test). Always perform the **agent-as-user execution** — hand off to the `user-simulator` persona, which **executes `stories/{slug}/user_test_plan.md`** by driving the project as a user (using `TESTING_STANDARDS.md` as conventions input) and writes `agent_test_session.md`. When `TESTING_STANDARDS.md` declares automated suites, also run them via the `test-executor` persona. **Block until every scenario / step reports `PASS`.** A failure is a post-implementation bug → route to `/e8-resolve-feedback` (see Step 3).
```
**Verification:** `grep -F '# /e6-execute-tests' host/templates/claude/commands/e6-execute-tests.md` returns 1. `grep -F '# /e5-execute-tests' host/templates/claude/commands/e6-execute-tests.md` returns 0. `grep -F 'executes `stories/{slug}/user_test_plan.md`' host/templates/claude/commands/e6-execute-tests.md` returns 1.

### Step 1.44 — EDIT e6-execute-tests.md Usage block

**Operation:** EDIT
**File:** `host/templates/claude/commands/e6-execute-tests.md`
**Locate:**
```
/e5-execute-tests {slug}
```
**Replace:**
```
/e6-execute-tests {slug}
```
**Verification:** `grep -F '/e5-execute-tests {slug}' host/templates/claude/commands/e6-execute-tests.md` returns 0.

### Step 1.45 — EDIT e6-execute-tests.md "## Required phase" (renumber + user_test_plan execution)

**Operation:** EDIT
**File:** `host/templates/claude/commands/e6-execute-tests.md`
**Locate:**
```
Phase 5 runs on **every** story (per `templates/SHAMT_RULES.template.md` §Testing and
[`reference/testing.md`](../../../../reference/testing.md)) — there is no `testing` config flag and no
no-op. It always runs the **agent-as-user execution** (Step 0) and, when
`.shamt-core/project-specific-files/TESTING_STANDARDS.md` declares **automated suites present**, the
**automated** execution (Step 2). It **blocks until green**.
```
**Replace:**
```
Phase 6 runs on **every** story (per `templates/SHAMT_RULES.template.md` §Testing and
[`reference/testing.md`](../../../../reference/testing.md)) — there is no `testing` config flag and no
no-op. It always runs the **agent-as-user execution** (Step 0 — the `user-simulator` executes
`user_test_plan.md`) and, when
`.shamt-core/project-specific-files/TESTING_STANDARDS.md` declares **automated suites present**, the
**automated** execution (Step 2). It **blocks until green**.
```
**Verification:** `grep -F 'Phase 6 runs on **every** story' host/templates/claude/commands/e6-execute-tests.md` returns 1. `grep -F 'Phase 5 runs on **every** story' host/templates/claude/commands/e6-execute-tests.md` returns 0.

### Step 1.46 — EDIT e6-execute-tests.md Prerequisites (renumber /e4→/e5; drop Quick/Standard testing-artifact branches; /e3b→/e4)

**Operation:** EDIT
**File:** `host/templates/claude/commands/e6-execute-tests.md`
**Locate:**
```
- The active plan exists with a validation footer **and Phase 4 (Build) has completed** — code-under-test is in the working tree. If Build has not run yet, halt and direct the user to `/e4-execute-plan {slug}` first.
- `.shamt-core/project-specific-files/TESTING_STANDARDS.md` exists and is validated (the agent-as-user run reads it; if all-placeholder, halt and direct the user to complete it via the init completion prompt).
- **When `TESTING_STANDARDS.md` declares automated suites,** one of the following is true (per the path):
  - **Standard path:** `stories/{slug}/testing_plan.md` (or `testing_plan_vN.md`) exists with a validation footer.
  - **Quick path with full artifact:** same as Standard — the artifact was produced via `/e3b-write-testing-plan {slug}` because test scope exceeded the Quick-path inline threshold (>5 steps or any new test file) — the testing-plan escalation threshold (`/e3b`). Quick path itself still skips Phase 3 (Plan); the escalation only adds a `testing_plan.md` without escalating the whole story to Standard.
  - **Quick path with inline checklist:** the active `spec.md` has a populated `### Quick path inline test checklist` under `## Test Strategy`.

If the active testing artifact is not validated, halt and direct the user to `/e3b-write-testing-plan {slug}` (or `/validate-artifact stories/{slug}/spec.md` when the inline checklist was recently edited).
```
**Replace:**
```
- The active plan exists with a validation footer **and Phase 5 (Build) has completed** — code-under-test is in the working tree. If Build has not run yet, halt and direct the user to `/e5-execute-plan {slug}` first.
- `stories/{slug}/user_test_plan.md` exists with a validation footer (authored in Phase 4 — Test Plan). If missing or unfootered, halt and direct the user to `/e4-write-test-plan {slug}`.
- `.shamt-core/project-specific-files/TESTING_STANDARDS.md` exists and is validated (the agent-as-user run reads it as conventions input; if all-placeholder, halt and direct the user to complete it via the init completion prompt).
- **When `TESTING_STANDARDS.md` declares automated suites,** `stories/{slug}/testing_plan.md` (or `testing_plan_vN.md`) exists with a validation footer. If the active testing artifact is not validated, halt and direct the user to `/e4-write-test-plan {slug}`.
```
**Verification:** `grep -F '/e3b-write-testing-plan' host/templates/claude/commands/e6-execute-tests.md` returns 0. `grep -F 'Quick path inline test checklist' host/templates/claude/commands/e6-execute-tests.md` returns 0. `grep -F '/e5-execute-plan {slug}` first' host/templates/claude/commands/e6-execute-tests.md` returns 1. `grep -F 'user_test_plan.md` exists with a validation footer' host/templates/claude/commands/e6-execute-tests.md` returns 1.

### Step 1.47 — EDIT e6-execute-tests.md Step 0 (user-simulator EXECUTES user_test_plan.md; route to /e8)

**Operation:** EDIT
**File:** `host/templates/claude/commands/e6-execute-tests.md`
**Locate:**
```
Hand off to the `user-simulator` persona (see [`agents/user-simulator.md`](../agents/user-simulator.md)).
Provide `slug` and `testing_standards_path = .shamt-core/project-specific-files/TESTING_STANDARDS.md`. It
drives the project as a user, writes `stories/{slug}/agent_test_session.md`, and reports
`Session PASS` / `Session BLOCKED: …`. On `BLOCKED`, route the failing scenario(s) per Step 3 (bug →
`/e7`). If `TESTING_STANDARDS.md` declares **no automated suites**, Step 0 is the whole required pass —
on `Session PASS`, skip to Step 4.
```
**Replace:**
```
Hand off to the `user-simulator` persona (see [`agents/user-simulator.md`](../agents/user-simulator.md)).
Provide `slug`, `user_test_plan_path = stories/{slug}/user_test_plan.md`, and
`testing_standards_path = .shamt-core/project-specific-files/TESTING_STANDARDS.md`. It **executes the
scenarios in `user_test_plan.md`** by driving the project as a user (using `TESTING_STANDARDS.md` as
conventions input, not as the scenario source), writes `stories/{slug}/agent_test_session.md`, and reports
`Session PASS` / `Session BLOCKED: …`. On `BLOCKED`, route the failing scenario(s) per Step 3 (bug →
`/e8`). If `TESTING_STANDARDS.md` declares **no automated suites**, Step 0 is the whole required pass —
on `Session PASS`, skip to Step 4.
```
**Verification:** `grep -F 'executes the\nscenarios in `user_test_plan.md`' host/templates/claude/commands/e6-execute-tests.md` may not match across newline — instead use `grep -F 'executes the' host/templates/claude/commands/e6-execute-tests.md` returns ≥1 AND `grep -F 'user_test_plan_path = stories/{slug}/user_test_plan.md' host/templates/claude/commands/e6-execute-tests.md` returns 1 AND `grep -F 'bug →\n`/e8`' ` — use the simpler `grep -F '`/e8`).' host/templates/claude/commands/e6-execute-tests.md` returns ≥1.

### Step 1.48 — EDIT e6-execute-tests.md Step 1 (drop Quick/Standard testing-artifact resolution)

**Operation:** EDIT
**File:** `host/templates/claude/commands/e6-execute-tests.md`
**Locate:**
```
1. Apply the active-artifact pointer.
2. Read the spec's `Path:` header and the spec's `## Test Strategy`.
3. Determine the executable surface:
   - **Full artifact:** `stories/{slug}/testing_plan.md` (or `_vN`).
   - **Inline checklist:** `stories/{slug}/spec.md` `### Quick path inline test checklist`.
4. Confirm the artifact's validation footer. If missing, halt.
```
**Replace:**
```
1. Apply the active-artifact pointer.
2. Read the spec's `## Test Strategy`.
3. Resolve the executable surface: `stories/{slug}/testing_plan.md` (or `_vN`).
4. Confirm the artifact's validation footer. If missing, halt.
```
**Verification:** `grep -F 'Inline checklist:' host/templates/claude/commands/e6-execute-tests.md` returns 0. `grep -F "spec's `Path:` header" host/templates/claude/commands/e6-execute-tests.md` returns 0.

### Step 1.49 — EDIT e6-execute-tests.md Step 2 invocation comment (drop inline-checklist)

**Operation:** EDIT
**File:** `host/templates/claude/commands/e6-execute-tests.md`
**Locate:**
```
- `testing_plan_path` (the resolved artifact path; for the inline checklist, pass the active `spec.md` path),
```
**Replace:**
```
- `testing_plan_path` (the resolved artifact path),
```
**Verification:** `grep -F 'for the inline checklist, pass the active' host/templates/claude/commands/e6-execute-tests.md` returns 0.

### Step 1.49b — EDIT e6-execute-tests.md Step 2 prompt example testing_plan_path comment

**Operation:** EDIT
**File:** `host/templates/claude/commands/e6-execute-tests.md`
**Locate:**
```
  testing_plan_path: stories/{slug}/testing_plan.md  # or spec.md for inline checklist
```
**Replace:**
```
  testing_plan_path: stories/{slug}/testing_plan.md
```
**Verification:** `grep -F '# or spec.md for inline checklist' host/templates/claude/commands/e6-execute-tests.md` returns 0.

### Step 1.50 — EDIT e6-execute-tests.md Step 3 routing (renumber /e7→/e8, /e4→/e5, /e3b→/e4; drop Quick/Standard)

**Operation:** EDIT
**File:** `host/templates/claude/commands/e6-execute-tests.md`
**Locate:**
```
- **`Session BLOCKED:` (agent-as-user FAIL)** — a scenario's observed behavior did not match expected. This is a **post-implementation bug**: route it through `/e7-resolve-feedback {slug}` as a feedback item (it requires the phase-attributed root-cause section — see `/e7`), apply the fix, and **re-invoke `/e5-execute-tests {slug}`** to re-run Phase 5 to green. (`HALT` results are not passes — resolve the ambiguity, do not proceed to Review.)
- **`Step [N] failed: Story bug — …`** — the implementation is wrong. Re-engage the architect/builder loop: read the failing step's `Failure Diagnosis`, decide whether the fix is a plan amendment (rare for a test failure — only when the plan missed a step) or an implementation correction the builder can re-execute. For Standard path, route the fix through `/e4-execute-plan` (the orchestrator may patch the plan or hand a corrective step to the builder); for Quick path, the primary agent applies the fix inline. After fixing, re-invoke `/e5-execute-tests {slug}` — the executor will read existing `Results Log` rows and walk the plan per its persona contract (see [`agents/test-executor.md`](../agents/test-executor.md)).
- **`Step [N] failed: Test bug — …`** — the test itself is wrong. The testing plan needs to change. Halt and invoke `/e3b-write-testing-plan {slug}` to patch and re-validate, then re-invoke `/e5-execute-tests {slug}`.
- **`Step [N] failed: Spec gap — …`** — the test correctly proved that the spec is incomplete. Invoke the **Re-baseline Protocol** per [`SHAMT_RULES.template.md`](../../../../templates/SHAMT_RULES.template.md#requirement-re-baseline-protocol) — create new `spec_vN.md` (and `context_vN.md` + `implementation_plan_vN.md` on Standard path only — Quick path has neither artifact), update `active_artifacts.md`, re-validate, re-approve at Gate 2b (and Gate 3 on Standard path only), redo any affected Build steps, then re-invoke `/e5-execute-tests`. Do **not** patch the existing spec in place.
- **`Step [N] is ambiguous: …`** — clarify with the user via `AskUserQuestion` (open-questions iterative dialog, Principle 2). Update the testing plan if the answer is design-level; re-validate; re-hand off.
- **`Plan defect at Step [N]: …`** — the testing plan itself is broken. Patch via `/e3b-write-testing-plan`, re-validate, re-hand off.
- **`Environment blocked at Step [N]: …`** — the executor tried and failed to resolve the environment. Surface the failure to the user with a one-question dialog: which infrastructure piece is missing (credentials? service? dependency?). After the user resolves it externally, re-invoke `/e5-execute-tests`. **Do not** allow "document and skip" — Phase 5 blocks until every step passes (per [`SHAMT_RULES.template.md`](../../../../templates/SHAMT_RULES.template.md#testing-phase-5--required)).
```
**Replace:**
```
- **`Session BLOCKED:` (agent-as-user FAIL)** — a scenario's observed behavior did not match expected. This is a **post-implementation bug**: route it through `/e8-resolve-feedback {slug}` as a feedback item (it requires the phase-attributed root-cause section — see `/e8`), apply the fix, and **re-invoke `/e6-execute-tests {slug}`** to re-run Phase 6 to green. (`HALT` results are not passes — resolve the ambiguity, do not proceed to Review.)
- **`Step [N] failed: Story bug — …`** — the implementation is wrong. Re-engage the architect/builder loop: read the failing step's `Failure Diagnosis`, decide whether the fix is a plan amendment (rare for a test failure — only when the plan missed a step) or an implementation correction the builder can re-execute. Route the fix through `/e5-execute-plan` (the orchestrator may patch the plan or hand a corrective step to the builder). After fixing, re-invoke `/e6-execute-tests {slug}` — the executor will read existing `Results Log` rows and walk the plan per its persona contract (see [`agents/test-executor.md`](../agents/test-executor.md)).
- **`Step [N] failed: Test bug — …`** — the test itself is wrong. The testing plan needs to change. Halt and invoke `/e4-write-test-plan {slug}` to patch and re-validate, then re-invoke `/e6-execute-tests {slug}`.
- **`Step [N] failed: Spec gap — …`** — the test correctly proved that the spec is incomplete. Invoke the **Re-baseline Protocol** per [`SHAMT_RULES.template.md`](../../../../templates/SHAMT_RULES.template.md#requirement-re-baseline-protocol) — create new `spec_vN.md`, `context_vN.md`, and `implementation_plan_vN.md`, update `active_artifacts.md`, re-validate, re-approve at Gate 2b and Gate 3, redo any affected Build steps, then re-invoke `/e6-execute-tests`. Do **not** patch the existing spec in place.
- **`Step [N] is ambiguous: …`** — clarify with the user via `AskUserQuestion` (open-questions iterative dialog, Principle 2). Update the testing plan if the answer is design-level; re-validate; re-hand off.
- **`Plan defect at Step [N]: …`** — the testing plan itself is broken. Patch via `/e4-write-test-plan`, re-validate, re-hand off.
- **`Environment blocked at Step [N]: …`** — the executor tried and failed to resolve the environment. Surface the failure to the user with a one-question dialog: which infrastructure piece is missing (credentials? service? dependency?). After the user resolves it externally, re-invoke `/e6-execute-tests`. **Do not** allow "document and skip" — Phase 6 blocks until every step passes (per [`SHAMT_RULES.template.md`](../../../../templates/SHAMT_RULES.template.md#testing-phase-6--required)).
```
**Verification:** `grep -F '/e3b-write-testing-plan' host/templates/claude/commands/e6-execute-tests.md` returns 0. `grep -F '/e7-resolve-feedback {slug}' host/templates/claude/commands/e6-execute-tests.md` returns 0. `grep -F '/e8-resolve-feedback {slug}' host/templates/claude/commands/e6-execute-tests.md` returns 1. `grep -nE 'Quick path|Standard path' host/templates/claude/commands/e6-execute-tests.md` returns 0 in the Step 3 region.

### Step 1.50b — EDIT e6-execute-tests.md Step 4 Post-execution closing line (Phase 5→6)

**Operation:** EDIT
**File:** `host/templates/claude/commands/e6-execute-tests.md`
**Locate:**
```
4. Phase 5 is complete.
```
**Replace:**
```
4. Phase 6 is complete.
```
**Verification:** `grep -F '4. Phase 6 is complete.' host/templates/claude/commands/e6-execute-tests.md` returns 1. `grep -F '4. Phase 5 is complete.' host/templates/claude/commands/e6-execute-tests.md` returns 0.

### Step 1.51 — EDIT e6-execute-tests.md Step 5 Exit (next → /e7; drop e5b suggestion) + Notes /e4→/e5 + footer comment

**Operation:** EDIT
**File:** `host/templates/claude/commands/e6-execute-tests.md`
**Locate:**
```
Suggest the next phase: `/clear`, then `/e6-review-changes {slug}` (Phase 6 — Story-mode review).

Also suggest `/e5b-write-manual-testing-plan {slug}` when the story touched UI / cloud infra / external integrations / multi-user flows — automated tests cover the structural surface; manual scenarios cover what they cannot.
```
**Replace:**
```
Suggest the next phase: `/clear`, then `/e7-review-changes {slug}` (Phase 7 — Story-mode review).
```
**Verification:** `grep -F '/e5b-write-manual-testing-plan' host/templates/claude/commands/e6-execute-tests.md` returns 0. `grep -F '/e7-review-changes {slug}` (Phase 7' host/templates/claude/commands/e6-execute-tests.md` returns 1.

### Step 1.51b — EDIT e6-execute-tests.md Notes architect/builder line (/e4→/e5)

**Operation:** EDIT
**File:** `host/templates/claude/commands/e6-execute-tests.md`
**Locate:**
```
- The **architect/builder split** still applies for Story-bug failures: the orchestrator (this command + the user) decides what to fix; the builder (re-invoked via `/e4-execute-plan`) applies the fix.
```
**Replace:**
```
- The **architect/builder split** still applies for Story-bug failures: the orchestrator (this command + the user) decides what to fix; the builder (re-invoked via `/e5-execute-plan`) applies the fix.
```
**Verification:** `grep -F 're-invoked via `/e4-execute-plan`' host/templates/claude/commands/e6-execute-tests.md` returns 0.

### Step 1.51c — EDIT e6-execute-tests.md regen-path footer comment

**Operation:** EDIT
**File:** `host/templates/claude/commands/e6-execute-tests.md`
**Locate:**
```
<!-- Managed by Shamt — do not edit. Regenerate from shamt-core/host/templates/claude/commands/e5-execute-tests.md. -->
```
**Replace:**
```
<!-- Managed by Shamt — do not edit. Regenerate from shamt-core/host/templates/claude/commands/e6-execute-tests.md. -->
```
**Verification:** `grep -F 'Regenerate from shamt-core/host/templates/claude/commands/e6-execute-tests.md.' host/templates/claude/commands/e6-execute-tests.md` returns 1. `grep -F 'e5-execute-tests.md.' host/templates/claude/commands/e6-execute-tests.md` returns 0.

### Step 1.52 — MOVE row 8 sub-step B verification

**Operation:** MOVE-as-paired-CREATE+DELETE (sub-step B — verify)
**Verification:**
- `test ! -f host/templates/claude/commands/e5-execute-tests.md && test -f host/templates/claude/commands/e6-execute-tests.md`.
- `git diff` (rename-followed) shows renumber (Phase 5→6; `/e5`→`/e6`; routing `/e7`→`/e8`, `/e4`→`/e5`; `/e3b`→`/e4`; next `/e6-review-changes`→`/e7-review-changes`) + Quick/Standard removal + the Step-0 `user-simulator`-executes-`user_test_plan.md` behavior change + e5b-suggestion removal ONLY.
- #50 does not modify this file. `grep -nE 'Quick path|Standard path|inline checklist|/e3b|manual_test_plan' host/templates/claude/commands/e6-execute-tests.md` returns 0 matches.
- **No stale phase-label pairings survive in the body** (the historical validation-footer `(Phase 6 implementation loop)` provenance line is **left intact** per Principle 3): `grep -F 'Phase 5 (Test)' host/templates/claude/commands/e6-execute-tests.md` returns 0 (the old Test self-label is renumbered to "Phase 6 (Test)"); `grep -F 'Phase 4 (Build)' host/templates/claude/commands/e6-execute-tests.md` returns 0 (the old Build label is renumbered to "Phase 5 (Build)"). The correct **new** cross-references — "Phase 6 (Test)" (self), "Phase 5 (Build)" and "Phase 4 — Test Plan" (prerequisites), "Phase 7" (next) — are **allowed**; do NOT assert bare "Phase 4"/"Phase 5" to 0.

### Step 1.53 — MOVE e6-review-changes.md → e7-review-changes.md, sub-step A: git mv (row 9)

**Operation:** MOVE-as-paired-CREATE+DELETE (sub-step A — rename)
**Command:** `git mv host/templates/claude/commands/e6-review-changes.md host/templates/claude/commands/e7-review-changes.md`
**Verification:** `test ! -f host/templates/claude/commands/e6-review-changes.md && test -f host/templates/claude/commands/e7-review-changes.md`. (Body edits 1.54–1.55k follow; sub-step B verification is Step 1.56.)

### Step 1.54 — EDIT e7-review-changes.md frontmatter description + title (Phase 7; #50 PR-open preserved)

**Operation:** EDIT
**File:** `host/templates/claude/commands/e7-review-changes.md`
**Locate:**
```
description: Phase 6 (Review) — story-mode review of a story's own changes against the spec/plan, or formal-mode review of a named branch/PR via the review-executor persona. Local artifact only; never posts back to external trackers.
```
**Replace:**
```
description: Phase 7 (Review) — story-mode review of a story's own changes against the spec/plan, or formal-mode review of a named branch/PR via the review-executor persona. Opens the PR when pr_provider == github. Local artifact in both modes; never posts review content back to trackers.
```
**Verification:** `grep -F 'Phase 7 (Review)' host/templates/claude/commands/e7-review-changes.md` returns 1.

### Step 1.55 — EDIT e7-review-changes.md title line

**Operation:** EDIT
**File:** `host/templates/claude/commands/e7-review-changes.md`
**Locate:**
```
# /e6-review-changes
```
**Replace:**
```
# /e7-review-changes
```
**Verification:** `grep -F '# /e7-review-changes' host/templates/claude/commands/e7-review-changes.md` returns 1. `grep -F '# /e6-review-changes' host/templates/claude/commands/e7-review-changes.md` returns 0.

### Step 1.55a — EDIT e7-review-changes.md self-references /e6→/e7 (Purpose, Usage, mode lines)

**Operation:** EDIT
**File:** `host/templates/claude/commands/e7-review-changes.md`
**Locate:**
```
- **Story mode** — `/e6-review-changes {slug}`: review the code just built for a story against its own spec / plan / Build Checklist. The primary agent runs the 16-category sweep at story altitude. Output lives in `stories/{slug}/feedback/review_vN.md`.
- **Formal mode** — `/e6-review-changes --branch=<name>` or `/e6-review-changes --pr=<id>`: review someone else's branch or PR. Hands off to the `review-executor` Opus persona. Output lives in `code_reviews/<sanitized-branch>/overview.md` + `review_vN.md`.
```
**Replace:**
```
- **Story mode** — `/e7-review-changes {slug}`: review the code just built for a story against its own spec / plan. The primary agent runs the 16-category sweep at story altitude. Output lives in `stories/{slug}/feedback/review_vN.md`.
- **Formal mode** — `/e7-review-changes --branch=<name>` or `/e7-review-changes --pr=<id>`: review someone else's branch or PR. Hands off to the `review-executor` Opus persona. Output lives in `code_reviews/<sanitized-branch>/overview.md` + `review_vN.md`.
```
**Verification:** `grep -F '/e6-review-changes --branch' host/templates/claude/commands/e7-review-changes.md` returns 0.

### Step 1.55b — EDIT e7-review-changes.md Usage block (3 lines /e6→/e7)

**Operation:** EDIT
**File:** `host/templates/claude/commands/e7-review-changes.md`
**Locate:**
```
/e6-review-changes {slug}                # story mode
/e6-review-changes --branch=<name>       # formal mode — named branch
/e6-review-changes --pr=<id>             # formal mode — tracker PR / MR ID
```
**Replace:**
```
/e7-review-changes {slug}                # story mode
/e7-review-changes --branch=<name>       # formal mode — named branch
/e7-review-changes --pr=<id>             # formal mode — tracker PR / MR ID
```
**Verification:** `grep -cF '/e6-review-changes' host/templates/claude/commands/e7-review-changes.md` returns 0.

### Step 1.55c — EDIT e7-review-changes.md Story-mode Step 1 (drop Standard/Quick artifact qualifiers; user_test_plan)

**Operation:** EDIT
**File:** `host/templates/claude/commands/e7-review-changes.md`
**Locate:**
```
1. Apply the active-artifact pointer; resolve `spec`, `context` (Standard only), `implementation_plan` (Standard only), `agent_test_session` (the required Phase-5 run), and `testing_plan` (when `TESTING_STANDARDS.md` declares automated suites **and** the story uses a full artifact rather than the Quick-path inline checklist in `spec.md`) paths.
2. Confirm each resolved artifact has a validation footer. If any is missing, halt — review starts after approved gates. (Quick-path inline test checklists live under the spec's footered surface and don't need a separate footer check.)
```
**Replace:**
```
1. Apply the active-artifact pointer; resolve `spec`, `context`, `implementation_plan`, `user_test_plan`, `agent_test_session` (the required Phase-6 run), and `testing_plan` (when `TESTING_STANDARDS.md` declares automated suites) paths.
2. Confirm each resolved artifact has a validation footer. If any is missing, halt — review starts after approved gates.
```
**Verification:** `grep -F 'Quick-path inline test checklist' host/templates/claude/commands/e7-review-changes.md` returns 0. `grep -F '(Standard only)' host/templates/claude/commands/e7-review-changes.md` returns 0 in Step 1.

### Step 1.55d — EDIT e7-review-changes.md Step 2 Plan Alignment (drop Quick N/A row; uniform Standard checks)

**Operation:** EDIT
**File:** `host/templates/claude/commands/e7-review-changes.md`
**Locate:**
```
| Path | Plan Alignment input |
|------|----------------------|
| Quick path | `N/A — Quick path used the spec Build Checklist instead of implementation_plan.md.` |
| Standard path | Read the active plan alongside the diff. Walk: **Step Coverage** (every plan step is reflected in the diff), **Change Fidelity** (every code change traces to a plan step), **Scope Discipline** (no out-of-plan changes), **Verification Passage** (the plan's `## Verification` section is satisfied), **Zero Builder Design Decisions** (no design choices were made during Build). |

Write the `## Plan Alignment` section at the top of `review_vN.md`. On Quick path it is one line; on Standard path it lists each check's result.
```
**Replace:**
```
Read the active plan alongside the diff. Walk: **Step Coverage** (every plan step is reflected in the diff), **Change Fidelity** (every code change traces to a plan step), **Scope Discipline** (no out-of-plan changes), **Verification Passage** (the plan's `## Verification` section is satisfied), **Zero Builder Design Decisions** (no design choices were made during Build).

Write the `## Plan Alignment` section at the top of `review_vN.md`, listing each check's result.
```
**Verification:** `grep -F '| Quick path |' host/templates/claude/commands/e7-review-changes.md` returns 0. `grep -F 'On Quick path it is one line' host/templates/claude/commands/e7-review-changes.md` returns 0.

### Step 1.55e — EDIT e7-review-changes.md Step 4 Doc-Impact Polish pointer (/e7→/e8) + Phase narrative

**Operation:** EDIT
**File:** `host/templates/claude/commands/e7-review-changes.md`
**Locate:**
```
When `Required`, Polish (`/e7-resolve-feedback`) applies the update and re-validates the doc — see [`SHAMT_RULES.template.md`](../../../../templates/SHAMT_RULES.template.md#part-3-engineer-flow--phase-narratives) Phase 7.
```
**Replace:**
```
When `Required`, Polish (`/e8-resolve-feedback`) applies the update and re-validates the doc — see [`SHAMT_RULES.template.md`](../../../../templates/SHAMT_RULES.template.md#part-3-engineer-flow--phase-narratives) Phase 8.
```
**Verification:** `grep -F 'Polish (`/e8-resolve-feedback`)' host/templates/claude/commands/e7-review-changes.md` returns 1. `grep -F 'Polish (`/e7-resolve-feedback`)' host/templates/claude/commands/e7-review-changes.md` returns 0.

### Step 1.55f — EDIT e7-review-changes.md Step 5 Quick-path no-issue shortcut (remove)

**Operation:** EDIT
**File:** `host/templates/claude/commands/e7-review-changes.md`
**Locate:**
```
**Quick-path no-issue shortcut:** when the path is Quick and no issues are found, the durable `review_vN.md` is optional — append a `## Post-Build Review` block to the spec instead (per [`reference/review_categories.md`](../../../../reference/review_categories.md#quick-path-no-artifact-reviews)). If any finding exists (or the user explicitly asked for the artifact), still write `review_vN.md`.

### Step 6 — Validate the review artifact
```
**Replace:**
```
### Step 6 — Validate the review artifact
```
**Verification:** `grep -F 'Quick-path no-issue shortcut' host/templates/claude/commands/e7-review-changes.md` returns 0. `grep -F '## Post-Build Review' host/templates/claude/commands/e7-review-changes.md` returns 0.

### Step 1.55g — EDIT e7-review-changes.md Step 6 validation exit (uniform)

**Operation:** EDIT
**File:** `host/templates/claude/commands/e7-review-changes.md`
**Locate:**
```
Invoke `/validate-artifact stories/{slug}/feedback/review_vN.md`. Uses the **7 dimensions** for story-mode review (6 review dimensions + Plan Alignment). Exit per [`SHAMT_RULES.template.md`](../../../../templates/SHAMT_RULES.template.md#pattern-1-validation-loops): Standard path uses primary clean + 1 adversarial sub-agent; Quick path may use a single primary pass unless a risk trigger applies. Footer.
```
**Replace:**
```
Invoke `/validate-artifact stories/{slug}/feedback/review_vN.md`. Uses the **7 dimensions** for story-mode review (6 review dimensions + Plan Alignment). Exit per [`SHAMT_RULES.template.md`](../../../../templates/SHAMT_RULES.template.md#pattern-1-validation-loops): uniform — primary clean + 1 adversarial sub-agent, always. Footer.
```
**Verification:** `grep -F 'Quick path may use a single primary pass' host/templates/claude/commands/e7-review-changes.md` returns 0.

### Step 1.55h — EDIT e7-review-changes.md Step 6b PR-open inbound pointers (/e7→/e8, /e8→/e9; #50 preserved)

**Operation:** EDIT
**File:** `host/templates/claude/commands/e7-review-changes.md`
**Locate:**
```
  3. **Record the PR number** into the story folder so `/e7-resolve-feedback` and `/e8-finalize-story` can resolve it without conversation history: write `stories/{slug}/feedback/pr.md` with the PR number and URL (e.g. `PR: #1234` / `URL: <pr url>`). This is the single source for the fetch + dedup in `/e7` and the merge in `/e8`.
```
**Replace:**
```
  3. **Record the PR number** into the story folder so `/e8-resolve-feedback` and `/e9-finalize-story` can resolve it without conversation history: write `stories/{slug}/feedback/pr.md` with the PR number and URL (e.g. `PR: #1234` / `URL: <pr url>`). This is the single source for the fetch + dedup in `/e8` and the merge in `/e9`.
```
**Verification:** `grep -F 'the fetch + dedup in `/e8` and the merge in `/e9`' host/templates/claude/commands/e7-review-changes.md` returns 1. `grep -F 'pr_provider' host/templates/claude/commands/e7-review-changes.md` returns ≥3 (#50 Step 6b PR-open logic preserved). `grep -F '## PR create' host/templates/claude/commands/e7-review-changes.md` returns ≥1.

### Step 1.55i — EDIT e7-review-changes.md Step 7 Exit suggestions (renumber + drop Quick Post-Build)

**Operation:** EDIT
**File:** `host/templates/claude/commands/e7-review-changes.md`
**Locate:**
```
- **Findings present, `pr_provider == github`, PR opened** → `/clear`, then `/e7-resolve-feedback {slug}` (Phase 7 — Polish), which now also pulls the PR's comments. Re-runnable N times as new comments arrive.
- **Findings present, `pr_provider != github`** → `/clear`, then `/e7-resolve-feedback {slug}` (Phase 7 — Polish).
- **No findings** (Quick-path inline `## Post-Build Review`) → user-driven next step (Polish is usually a no-op).
```
**Replace:**
```
- **Findings present, `pr_provider == github`, PR opened** → `/clear`, then `/e8-resolve-feedback {slug}` (Phase 8 — Polish), which now also pulls the PR's comments. Re-runnable N times as new comments arrive.
- **Findings present, `pr_provider != github`** → `/clear`, then `/e8-resolve-feedback {slug}` (Phase 8 — Polish).
- **No findings** → Polish is usually a no-op; the user drives the next step (`/e8-resolve-feedback {slug}` if any doc-impact or PR comment follow-up is wanted).
```
**Verification:** `grep -F '## Post-Build Review' host/templates/claude/commands/e7-review-changes.md` returns 0. `grep -F '/e8-resolve-feedback {slug}` (Phase 8 — Polish)' host/templates/claude/commands/e7-review-changes.md` returns ≥1.

### Step 1.55j — EDIT e7-review-changes.md Notes (drop Quick-path shortcut bullet)

**Operation:** EDIT
**File:** `host/templates/claude/commands/e7-review-changes.md`
**Locate:**
```
- **Quick-path shortcut** is opt-in only when zero issues are found. The moment one finding exists, write the durable `review_vN.md` artifact even on Quick path.
```
**Replace:** (delete this bullet line entirely)
**Verification:** `grep -F '**Quick-path shortcut**' host/templates/claude/commands/e7-review-changes.md` returns 0.

### Step 1.55j2 — EDIT e7-review-changes.md Prerequisites Story-mode line (inbound test-phase ref Phase 5→6; renumber-only)

**Operation:** EDIT
**File:** `host/templates/claude/commands/e7-review-changes.md`
**Locate:**
```
- **Story mode:** story folder resolves; the active spec is present; Build and Test (Phase 5, required) have completed.
```
**Replace:**
```
- **Story mode:** story folder resolves; the active spec is present; Build and Test (Phase 6, required) have completed.
```
**Verification:** `grep -F 'Build and Test (Phase 6, required)' host/templates/claude/commands/e7-review-changes.md` returns 1. `grep -F 'Build and Test (Phase 5, required)' host/templates/claude/commands/e7-review-changes.md` returns 0.

### Step 1.55j3 — EDIT e7-review-changes.md Step 4 Doc-Impact self-phase reference (Phase 6→7)

**Operation:** EDIT
**File:** `host/templates/claude/commands/e7-review-changes.md`
**Locate:**
```
Triggers include: new service / boundary / data store added; deprecated pattern; new convention introduced; or this change actually touches a doc whose `Last Updated` field is stale (older than `.shamt-core/shamt-config.json` → `doc_staleness_threshold_days`). Story-level Doc Impact only fires when this change touches the doc — pure staleness without a touching change is the audit's D6 (doc currency) dimension, not Phase 6's responsibility.
```
**Replace:**
```
Triggers include: new service / boundary / data store added; deprecated pattern; new convention introduced; or this change actually touches a doc whose `Last Updated` field is stale (older than `.shamt-core/shamt-config.json` → `doc_staleness_threshold_days`). Story-level Doc Impact only fires when this change touches the doc — pure staleness without a touching change is the audit's D6 (doc currency) dimension, not Phase 7's responsibility.
```
**Verification:** `grep -F "not Phase 7's responsibility" host/templates/claude/commands/e7-review-changes.md` returns 1. `grep -F "not Phase 6's responsibility" host/templates/claude/commands/e7-review-changes.md` returns 0.

### Step 1.55k — EDIT e7-review-changes.md regen-path footer comment

**Operation:** EDIT
**File:** `host/templates/claude/commands/e7-review-changes.md`
**Locate:**
```
<!-- Managed by Shamt — do not edit. Regenerate from shamt-core/host/templates/claude/commands/e6-review-changes.md. -->
```
**Replace:**
```
<!-- Managed by Shamt — do not edit. Regenerate from shamt-core/host/templates/claude/commands/e7-review-changes.md. -->
```
**Verification:** `grep -F 'Regenerate from shamt-core/host/templates/claude/commands/e7-review-changes.md.' host/templates/claude/commands/e7-review-changes.md` returns 1.

### Step 1.56 — MOVE row 9 sub-step B verification (#50-marker survival)

**Operation:** MOVE-as-paired-CREATE+DELETE (sub-step B — verify)
**Verification:**
- `test ! -f host/templates/claude/commands/e6-review-changes.md && test -f host/templates/claude/commands/e7-review-changes.md`.
- **#50 markers SURVIVE:** `grep -F 'pr_provider == github' host/templates/claude/commands/e7-review-changes.md` returns ≥2; `grep -F 'Step 6b' host/templates/claude/commands/e7-review-changes.md` returns ≥1; `grep -F '## PR create' host/templates/claude/commands/e7-review-changes.md` returns ≥1; `grep -F 'feedback/pr.md' host/templates/claude/commands/e7-review-changes.md` returns ≥1.
- `git diff` (rename-followed) shows renumber (Phase 6→7; `/e6`→`/e7`; the inbound test-phase ref Phase 5→6 in Prerequisites; the self Doc-Impact ref Phase 6→7; downstream `/e7`→`/e8`, `/e8`→`/e9`) + Quick/Standard removal (Plan Alignment Quick row, Quick-path no-issue shortcut, `## Post-Build Review`, Quick validation branch) ONLY — #50's PR-open logic byte-preserved aside from the `/e7`→`/e8` / `/e8`→`/e9` pointer renumbers.
- `grep -nE 'Quick path|Standard path|Post-Build Review' host/templates/claude/commands/e7-review-changes.md` returns 0 matches.
- **No stale phase-label pairings survive** (the historical validation-footer `(Phase 6 implementation loop)` provenance line is **left intact** per Principle 3): `grep -F 'Phase 6 (Review)' host/templates/claude/commands/e7-review-changes.md` returns 0 and `grep -F "Phase 6's responsibility" host/templates/claude/commands/e7-review-changes.md` returns 0 (the old Review self-label is renumbered to "Phase 7 (Review)" / "Phase 7's responsibility"). The correct **new** cross-references — "Phase 7 (Review)" (self), the Build (Phase 5) / Test (Phase 6) completed-prerequisite refs, and "Phase 8" (Polish, next) — are **allowed**; do NOT assert bare "Phase 5"/"Phase 6" to 0 (Build=5 and Test=6 are legitimate prerequisite mentions, and "(Phase 6 implementation loop)" is the allowed footer).

### Step 1.57 — MOVE e7-resolve-feedback.md → e8-resolve-feedback.md, sub-step A: git mv (row 10)

**Operation:** MOVE-as-paired-CREATE+DELETE (sub-step A — rename)
**Command:** `git mv host/templates/claude/commands/e7-resolve-feedback.md host/templates/claude/commands/e8-resolve-feedback.md`
**Verification:** `test ! -f host/templates/claude/commands/e7-resolve-feedback.md && test -f host/templates/claude/commands/e8-resolve-feedback.md`. (Body edits 1.58–1.59f follow; sub-step B verification is Step 1.60.)

### Step 1.58 — EDIT e8-resolve-feedback.md frontmatter description (Phase 7→8)

**Operation:** EDIT
**File:** `host/templates/claude/commands/e8-resolve-feedback.md`
**Locate:**
```
description: Phase 7 (Polish) — apply review feedback to code, log each comment's disposition in addressed_feedback.md, apply any flagged .shamt-core/project-specific-files/ARCHITECTURE.md / .shamt-core/project-specific-files/CODING_STANDARDS.md / .shamt-core/project-specific-files/TESTING_STANDARDS.md updates, surface root-cause proposals to the framework-update flow
```
**Replace:**
```
description: Phase 8 (Polish) — apply review feedback to code, log each comment's disposition in addressed_feedback.md, apply any flagged .shamt-core/project-specific-files/ARCHITECTURE.md / .shamt-core/project-specific-files/CODING_STANDARDS.md / .shamt-core/project-specific-files/TESTING_STANDARDS.md updates, surface root-cause proposals to the framework-update flow
```
**Verification:** `grep -F 'description: Phase 8 (Polish)' host/templates/claude/commands/e8-resolve-feedback.md` returns 1.

### Step 1.59 — EDIT e8-resolve-feedback.md title + Purpose (Phase 7→8)

**Operation:** EDIT
**File:** `host/templates/claude/commands/e8-resolve-feedback.md`
**Locate:**
```
# /e7-resolve-feedback

**Purpose:** Run Phase 7 (Polish) of the Engineer flow.
```
**Replace:**
```
# /e8-resolve-feedback

**Purpose:** Run Phase 8 (Polish) of the Engineer flow.
```
**Verification:** `grep -F '# /e8-resolve-feedback' host/templates/claude/commands/e8-resolve-feedback.md` returns 1. `grep -F '# /e7-resolve-feedback' host/templates/claude/commands/e8-resolve-feedback.md` returns 0.

### Step 1.59a — EDIT e8-resolve-feedback.md Usage block

**Operation:** EDIT
**File:** `host/templates/claude/commands/e8-resolve-feedback.md`
**Locate:**
```
/e7-resolve-feedback {slug}
```
**Replace:**
```
/e8-resolve-feedback {slug}
```
**Verification:** `grep -F '/e7-resolve-feedback {slug}' host/templates/claude/commands/e8-resolve-feedback.md` returns 0.

### Step 1.59b — EDIT e8-resolve-feedback.md Prerequisites (Phase 5→6 bug-routing reference)

**Operation:** EDIT
**File:** `host/templates/claude/commands/e8-resolve-feedback.md`
**Locate:**
```
- A feedback source exists: a story-mode `review_vN.md` (with a validation footer) under `stories/{slug}/feedback/`, **and/or a Phase-5 bug routed here by `/e5-execute-tests`** (an `agent_test_session.md` scenario that FAILed, or a `test-executor` Story-bug). A Phase-5 bug is logged as a feedback item with the required phase-attributed root-cause (Step 2). If there is no source at all (Quick-path no-issue + Phase 5 green), this command is mostly a TODO-scan no-op — see Step 6.
```
**Replace:**
```
- A feedback source exists: a story-mode `review_vN.md` (with a validation footer) under `stories/{slug}/feedback/`, **and/or a Phase-6 bug routed here by `/e6-execute-tests`** (an `agent_test_session.md` scenario that FAILed, or a `test-executor` Story-bug). A Phase-6 bug is logged as a feedback item with the required phase-attributed root-cause (Step 2). If there is no source at all (no findings + Phase 6 green), this command is mostly a TODO-scan no-op — see Step 6.
```
**Verification:** `grep -F 'Phase-6 bug routed here by `/e6-execute-tests`' host/templates/claude/commands/e8-resolve-feedback.md` returns 1. `grep -F 'Quick-path no-issue + Phase 5 green' host/templates/claude/commands/e8-resolve-feedback.md` returns 0.

### Step 1.59c — EDIT e8-resolve-feedback.md Step 2 root-cause phase list (Spec/Plan/Build phase names unchanged — confirm only)

**Operation:** EDIT
**File:** `host/templates/claude/commands/e8-resolve-feedback.md`
**Locate:**
```
- **Root cause:** <one-line summary of why the issue existed — needed for Step 5>. **For a Phase-5 test-surfaced bug this is required and must name which phase let it through — Spec (missing requirement) / Plan (missing or wrong step) / Build (execution defect) — plus the prevention (what would have caught it earlier).**
```
**Replace:**
```
- **Root cause:** <one-line summary of why the issue existed — needed for Step 5>. **For a Phase-6 test-surfaced bug this is required and must name which phase let it through — Spec (missing requirement) / Plan (missing or wrong step) / Build (execution defect) — plus the prevention (what would have caught it earlier).**
```
**Verification:** `grep -F 'For a Phase-6 test-surfaced bug' host/templates/claude/commands/e8-resolve-feedback.md` returns 1.

### Step 1.59d — EDIT e8-resolve-feedback.md Step 3 verify sub-step (remove Standard/Quick Verification-path branch)

**Operation:** EDIT
**File:** `host/templates/claude/commands/e8-resolve-feedback.md`
**Locate:**
```
3. **Verify** — re-run the relevant part of the active plan's `## Verification` section (Standard) or the spec's `## Verification` (Quick) for any code path the fix touched. For Standard path, if a fix is non-trivial, re-hand off to the `plan-executor` builder for the modified step.
```
**Replace:**
```
3. **Verify** — re-run the relevant part of the active plan's `## Verification` section for any code path the fix touched. If a fix is non-trivial, re-hand off to the `plan-executor` builder for the modified step.
```
**Verification:** `grep -F "the spec's `## Verification` (Quick)" host/templates/claude/commands/e8-resolve-feedback.md` returns 0. `grep -nE '\(Standard\)|\(Quick\)' host/templates/claude/commands/e8-resolve-feedback.md` returns 0 matches.

### Step 1.59e — EDIT e8-resolve-feedback.md Step 7 exit-gate PR pointers (/e8→/e9, /e6→/e7; #50 iterative loop preserved)

**Operation:** EDIT
**File:** `host/templates/claude/commands/e8-resolve-feedback.md`
**Locate:**
```
- **`pr_provider == github` + a PR recorded** — the fix commits have been pushed to the PR branch. Polish is **iterative**: as new human reviewer comments arrive on the PR, **re-run `/e7-resolve-feedback {slug}`** — each run re-inventories the latest PR comments (Step 1) and works any new ones, deduped against `addressed_feedback.md`. Pull-only: the command never replies to or resolves threads; the human resolves them on GitHub. When all feedback is addressed and the PR is approved, proceed to `/e8-finalize-story {slug}` (which merges the PR).
- **`pr_provider != github`** — unchanged: suggest the user push and open a PR manually (no tracker postback from any v2 command). When a re-review is requested, re-run `/e6-review-changes {slug}` (produces `review_v{N+1}.md`) and re-invoke this command.
```
**Replace:**
```
- **`pr_provider == github` + a PR recorded** — the fix commits have been pushed to the PR branch. Polish is **iterative**: as new human reviewer comments arrive on the PR, **re-run `/e8-resolve-feedback {slug}`** — each run re-inventories the latest PR comments (Step 1) and works any new ones, deduped against `addressed_feedback.md`. Pull-only: the command never replies to or resolves threads; the human resolves them on GitHub. When all feedback is addressed and the PR is approved, proceed to `/e9-finalize-story {slug}` (which merges the PR).
- **`pr_provider != github`** — unchanged: suggest the user push and open a PR manually (no tracker postback from any v2 command). When a re-review is requested, re-run `/e7-review-changes {slug}` (produces `review_v{N+1}.md`) and re-invoke this command.
```
**Verification:** `grep -F 're-run `/e8-resolve-feedback {slug}`' host/templates/claude/commands/e8-resolve-feedback.md` returns 1. `grep -F 'proceed to `/e9-finalize-story {slug}`' host/templates/claude/commands/e8-resolve-feedback.md` returns 1. `grep -F 're-run `/e7-review-changes {slug}`' host/templates/claude/commands/e8-resolve-feedback.md` returns 1.

### Step 1.59f — EDIT e8-resolve-feedback.md Notes (drop "Quick-path no-issue Polish" bullet) + regen footer

**Operation:** EDIT
**File:** `host/templates/claude/commands/e8-resolve-feedback.md`
**Locate:**
```
- **Quick-path no-issue Polish** is mostly a no-op — TODO scan + Documentation Impact pass + (rarely) a forward proposal from a noted lesson. `addressed_feedback.md` is not required when there are no findings.
```
**Replace:**
```
- **No-issue Polish** is mostly a no-op — TODO scan + Documentation Impact pass + (rarely) a forward proposal from a noted lesson. `addressed_feedback.md` is not required when there are no findings.
```
**Verification:** `grep -F '**Quick-path no-issue Polish**' host/templates/claude/commands/e8-resolve-feedback.md` returns 0.

### Step 1.59g — EDIT e8-resolve-feedback.md regen-path footer comment

**Operation:** EDIT
**File:** `host/templates/claude/commands/e8-resolve-feedback.md`
**Locate:**
```
<!-- Managed by Shamt — do not edit. Regenerate from shamt-core/host/templates/claude/commands/e7-resolve-feedback.md. -->
```
**Replace:**
```
<!-- Managed by Shamt — do not edit. Regenerate from shamt-core/host/templates/claude/commands/e8-resolve-feedback.md. -->
```
**Verification:** `grep -F 'Regenerate from shamt-core/host/templates/claude/commands/e8-resolve-feedback.md.' host/templates/claude/commands/e8-resolve-feedback.md` returns 1.

### Step 1.60 — MOVE row 10 sub-step B verification (#50-marker survival)

**Operation:** MOVE-as-paired-CREATE+DELETE (sub-step B — verify)
**Verification:**
- `test ! -f host/templates/claude/commands/e7-resolve-feedback.md && test -f host/templates/claude/commands/e8-resolve-feedback.md`.
- **#50 markers SURVIVE:** `grep -F 'addressed_feedback' host/templates/claude/commands/e8-resolve-feedback.md` returns ≥3; `grep -F 'pull-only' -i host/templates/claude/commands/e8-resolve-feedback.md` returns ≥1; `grep -F '## PR comment fetch' host/templates/claude/commands/e8-resolve-feedback.md` returns ≥1; `grep -F 'push the fix commits to the PR branch' host/templates/claude/commands/e8-resolve-feedback.md` returns ≥1; `grep -F 'iterative' -i host/templates/claude/commands/e8-resolve-feedback.md` returns ≥2.
- `git diff` (rename-followed) shows renumber (Phase 7→8; `/e7`→`/e8`; downstream `/e8`→`/e9`, `/e6`→`/e7`, `/e5`→`/e6`) + Quick/Standard removal (Step-3 verify branch, Quick-path-no-issue Notes bullet) ONLY — #50's iterative PR-comment loop / addressed_feedback ledger / push-as-response preserved.
- `grep -nE 'Quick path|Quick-path|\(Quick\)|\(Standard\)' host/templates/claude/commands/e8-resolve-feedback.md` returns 0 matches. (NOTE: "Standard path" never appeared in this file's body except via the removed Verification branch; confirm `grep -F 'Standard path' host/templates/claude/commands/e8-resolve-feedback.md` returns 0.)

### Step 1.61 — MOVE e8-finalize-story.md → e9-finalize-story.md, sub-step A: git mv (row 11)

**Operation:** MOVE-as-paired-CREATE+DELETE (sub-step A — rename)
**Command:** `git mv host/templates/claude/commands/e8-finalize-story.md host/templates/claude/commands/e9-finalize-story.md`
**Verification:** `test ! -f host/templates/claude/commands/e8-finalize-story.md && test -f host/templates/claude/commands/e9-finalize-story.md`. (Body edits 1.62–1.67 follow; sub-step B verification is Step 1.68.)

### Step 1.62 — EDIT e9-finalize-story.md frontmatter description (Phase 8→9)

**Operation:** EDIT
**File:** `host/templates/claude/commands/e9-finalize-story.md`
**Locate:**
```
description: Phase 8 (Finalize) of the Shamt Engineer flow — commit the story's work as a scoped unit and mark the originating work item done via the active tracker, behind three guards (prior phases complete, clean-tree/scoped commit, explicit confirmation)
```
**Replace:**
```
description: Phase 9 (Finalize) of the Shamt Engineer flow — commit the story's work as a scoped unit and mark the originating work item done via the active tracker, behind three guards (prior phases complete, clean-tree/scoped commit, explicit confirmation)
```
**Verification:** `grep -F 'description: Phase 9 (Finalize)' host/templates/claude/commands/e9-finalize-story.md` returns 1.

### Step 1.63 — EDIT e9-finalize-story.md title + Purpose (Phase 8→9)

**Operation:** EDIT
**File:** `host/templates/claude/commands/e9-finalize-story.md`
**Locate:**
```
# /e8-finalize-story

**Purpose:** Run Phase 8 (Finalize) of the Engineer flow — the terminal step.
```
**Replace:**
```
# /e9-finalize-story

**Purpose:** Run Phase 9 (Finalize) of the Engineer flow — the terminal step.
```
**Verification:** `grep -F '# /e9-finalize-story' host/templates/claude/commands/e9-finalize-story.md` returns 1. `grep -F '# /e8-finalize-story' host/templates/claude/commands/e9-finalize-story.md` returns 0.

### Step 1.63a — EDIT e9-finalize-story.md Usage block

**Operation:** EDIT
**File:** `host/templates/claude/commands/e9-finalize-story.md`
**Locate:**
```
/e8-finalize-story {slug}
```
**Replace:**
```
/e9-finalize-story {slug}
```
**Verification:** `grep -F '/e8-finalize-story {slug}' host/templates/claude/commands/e9-finalize-story.md` returns 0.

### Step 1.64 — EDIT e9-finalize-story.md Step 1 guards (inbound routing /e6→/e7, /e7→/e8, /e5→/e6; user_test_plan)

**Operation:** EDIT
**File:** `host/templates/claude/commands/e9-finalize-story.md`
**Locate:**
```
1. Confirm **Review** ran: a `feedback/review_vN.md` exists (or the story is Quick-path with no findings and the user has signalled Polish complete). If Review never ran, halt and direct the user to `/e6-review-changes {slug}`.
2. Confirm **feedback is resolved**: if `feedback/addressed_feedback.md` exists, every row is `Resolved` / `Deferred — <reason>` / `Needs user decision` with an active follow-up — **no `Pending` rows**. If unresolved rows remain, halt and direct the user to `/e7-resolve-feedback {slug}`.
3. Confirm **Test passed** (Phase 5 is required): `stories/{slug}/agent_test_session.md` shows the session verdict `PASS`, and — when `TESTING_STANDARDS.md` declares automated suites — the active `testing_plan.md` (or the Quick-path inline checklist) shows every step `PASS`. If any is unrun or failing, halt and direct the user to `/e5-execute-tests {slug}`.
```
**Replace:**
```
1. Confirm **Review** ran: a `feedback/review_vN.md` exists (or there were no findings and the user has signalled Polish complete). If Review never ran, halt and direct the user to `/e7-review-changes {slug}`.
2. Confirm **feedback is resolved**: if `feedback/addressed_feedback.md` exists, every row is `Resolved` / `Deferred — <reason>` / `Needs user decision` with an active follow-up — **no `Pending` rows**. If unresolved rows remain, halt and direct the user to `/e8-resolve-feedback {slug}`.
3. Confirm **Test passed** (Phase 6 is required): `stories/{slug}/agent_test_session.md` shows the session verdict `PASS`, and — when `TESTING_STANDARDS.md` declares automated suites — the active `testing_plan.md` shows every step `PASS`. If any is unrun or failing, halt and direct the user to `/e6-execute-tests {slug}`.
```
**Verification:** `grep -F '`/e7-review-changes {slug}`' host/templates/claude/commands/e9-finalize-story.md` returns ≥1. `grep -F '`/e8-resolve-feedback {slug}`' host/templates/claude/commands/e9-finalize-story.md` returns ≥1. `grep -F '`/e6-execute-tests {slug}`' host/templates/claude/commands/e9-finalize-story.md` returns ≥1. `grep -F 'Quick-path inline checklist' host/templates/claude/commands/e9-finalize-story.md` returns 0.

### Step 1.65 — EDIT e9-finalize-story.md Step 2 guard cross-ref (/e6-review-changes → /e7-review-changes)

**Operation:** EDIT
**File:** `host/templates/claude/commands/e9-finalize-story.md`
**Locate:**
```
2. The commit covers **only the story's own work** — the files this story created or modified. If the tree contains changes that are **not** part of this story (unrelated edits, other in-flight work), **halt and ask** the user whether to include, stash, commit-separately, or ignore them (mirrors `/e6-review-changes`'s `git status --short` guard). Do not sweep unrelated changes into the finalize commit.
```
**Replace:**
```
2. The commit covers **only the story's own work** — the files this story created or modified. If the tree contains changes that are **not** part of this story (unrelated edits, other in-flight work), **halt and ask** the user whether to include, stash, commit-separately, or ignore them (mirrors `/e7-review-changes`'s `git status --short` guard). Do not sweep unrelated changes into the finalize commit.
```
**Verification:** `grep -F "mirrors `/e7-review-changes`'s" host/templates/claude/commands/e9-finalize-story.md` returns 1.

### Step 1.66 — EDIT e9-finalize-story.md Step 3b PR-resolve pointer (/e6-review-changes → /e7-review-changes; #50 gh pr merge preserved)

**Operation:** EDIT
**File:** `host/templates/claude/commands/e9-finalize-story.md`
**Locate:**
```
  1. **Resolve the PR.** Read the PR number from `stories/{slug}/feedback/pr.md` (written by `/e6-review-changes`). If absent, halt and direct the user to open the PR first via `/e6-review-changes {slug}`.
```
**Replace:**
```
  1. **Resolve the PR.** Read the PR number from `stories/{slug}/feedback/pr.md` (written by `/e7-review-changes`). If absent, halt and direct the user to open the PR first via `/e7-review-changes {slug}`.
```
**Verification:** `grep -F 'written by `/e7-review-changes`' host/templates/claude/commands/e9-finalize-story.md` returns 1. `grep -F 'gh pr merge' host/templates/claude/commands/e9-finalize-story.md` returns ≥1.

### Step 1.67 — EDIT e9-finalize-story.md Exit + Notes (Phase 8→9; remove Quick/Standard "Terminal phase" N=7/8 clause)

**Operation:** EDIT
**File:** `host/templates/claude/commands/e9-finalize-story.md`
**Locate:**
```
No next-phase suggestion. The Engineer flow ends at Phase 8 (Finalize).
```
**Replace:**
```
No next-phase suggestion. The Engineer flow ends at Phase 9 (Finalize).
```
**Verification:** `grep -F 'The Engineer flow ends at Phase 9 (Finalize).' host/templates/claude/commands/e9-finalize-story.md` returns 1.

### Step 1.67a — EDIT e9-finalize-story.md Notes "Terminal phase" bullet (remove Quick/Standard N=7/8)

**Operation:** EDIT
**File:** `host/templates/claude/commands/e9-finalize-story.md`
**Locate:**
```
- **Terminal phase.** Finalize is the last Engineer phase. The status line renders `P{N} Finalize` once `ticket.md` carries `**Status: Done**` (N = 7 on the Quick path, 8 on the Standard path — testing is a required phase).
```
**Replace:**
```
- **Terminal phase.** Finalize is the last Engineer phase (Phase 9). The status line renders `P9 Finalize` once `ticket.md` carries `**Status: Done**`.
```
**Verification:** `grep -F 'N = 7 on the Quick path' host/templates/claude/commands/e9-finalize-story.md` returns 0. `grep -F 'The status line renders `P9 Finalize`' host/templates/claude/commands/e9-finalize-story.md` returns 1.

### Step 1.67b — EDIT e9-finalize-story.md regen-path footer comment

**Operation:** EDIT
**File:** `host/templates/claude/commands/e9-finalize-story.md`
**Locate:**
```
<!-- Managed by Shamt — do not edit. Regenerate from shamt-core/host/templates/claude/commands/e8-finalize-story.md. -->
```
**Replace:**
```
<!-- Managed by Shamt — do not edit. Regenerate from shamt-core/host/templates/claude/commands/e9-finalize-story.md. -->
```
**Verification:** `grep -F 'Regenerate from shamt-core/host/templates/claude/commands/e9-finalize-story.md.' host/templates/claude/commands/e9-finalize-story.md` returns 1.

### Step 1.68 — MOVE row 11 sub-step B verification (#50-marker survival)

**Operation:** MOVE-as-paired-CREATE+DELETE (sub-step B — verify)
**Verification:**
- `test ! -f host/templates/claude/commands/e8-finalize-story.md && test -f host/templates/claude/commands/e9-finalize-story.md`.
- **#50 markers SURVIVE:** `grep -F 'gh pr merge' host/templates/claude/commands/e9-finalize-story.md` returns ≥1; `grep -F 'pr_provider == github' host/templates/claude/commands/e9-finalize-story.md` returns ≥2; `grep -F 'Mergeable guard' host/templates/claude/commands/e9-finalize-story.md` returns ≥1; `grep -F 'work_item_tracker' host/templates/claude/commands/e9-finalize-story.md` returns ≥2; `grep -F 'feedback/pr.md' host/templates/claude/commands/e9-finalize-story.md` returns ≥1.
- `git diff` (rename-followed) shows renumber (Phase 8→9; `/e8`→`/e9`; inbound `/e6`→`/e7`, `/e7`→`/e8`, `/e5`→`/e6`) + Quick/Standard removal (N=7/8 Terminal-phase clause, Quick-path inline-checklist guard clause) ONLY — #50's `gh pr merge` finalize + work-item close routing preserved.
- `grep -nE 'Quick path|Quick-path|Standard path' host/templates/claude/commands/e9-finalize-story.md` returns 0 matches.

---

> **Row 12 (e-all.md) note.** `e-all.md` is an EDIT (no rename — `/e-all` is unnumbered). It carries #50's terminal-at-Review behavior. Every step below preserves that: `/e-all` still stops at Review; Polish + Finalize stay operator-initiated; the PR-open at Review is preserved. The renumber re-labels the *chain* to `e1 → e2 → e3 → e4(merged) → e5(build) → e6(test) → e7(review)`, drops the optional `/e3`+`/e3b` branch (Plan + Test Plan are mandatory), removes Quick/Standard (incl. #50's "Quick-path `## Post-Build Review`" routing), and renames Polish→`/e8` / Finalize→`/e9`.

### Step 1.69 — EDIT e-all.md frontmatter description (renumber chain; merged e4; drop Quick/Standard; Polish /e8, Finalize /e9)

**Operation:** EDIT
**File:** `host/templates/claude/commands/e-all.md`
**Locate:**
```
description: Driver — walk a single story through every remaining Engineer-flow phase up to and including Review (e1 → e2 → optional e3+e3b → e4 → e5 → e6, opening the PR when pr_provider == github) by dispatching one independent agent per phase, deriving the start phase from on-disk artifacts, pausing on each interactive gate or structured open question via AskUserQuestion, and halting on any failure it cannot resolve. Polish (/e7, iterative) and Finalize (/e8) are operator-driven — not auto-run
```
**Replace:**
```
description: Driver — walk a single story through every remaining Engineer-flow phase up to and including Review (e1 → e2 → e3 → e4 → e5 → e6 → e7, opening the PR when pr_provider == github) by dispatching one independent agent per phase, deriving the start phase from on-disk artifacts, pausing on each interactive gate or structured open question via AskUserQuestion, and halting on any failure it cannot resolve. Polish (/e8, iterative) and Finalize (/e9) are operator-driven — not auto-run
```
**Verification:** `grep -F 'e1 → e2 → e3 → e4 → e5 → e6 → e7' host/templates/claude/commands/e-all.md` returns ≥1. `grep -F 'optional e3+e3b' host/templates/claude/commands/e-all.md` returns 0. `grep -F 'Polish (/e8, iterative) and Finalize (/e9)' host/templates/claude/commands/e-all.md` returns 1.

### Step 1.70 — EDIT e-all.md Purpose para shared-tree phase list (/e4..→ renumbered)

**Operation:** EDIT
**File:** `host/templates/claude/commands/e-all.md`
**Locate:**
```
The driver runs in the main agent loop and dispatches **one independent `Agent` sub-agent per phase, in order**, in the **shared working tree** (never with worktree isolation — `/e4`'s build edits must be visible to `/e5` test, `/e6` review, `/e7` polish, and `/e8` commit). After each phase agent returns, the driver inspects its report and either **advances** (clean exit), **pauses** (the phase surfaced an interactive gate or a structured open question — lift it to the user via `AskUserQuestion`, feed the answer back, re-dispatch the same phase against its on-disk artifact), or **halts** (any other non-clean outcome — failure, ambiguity it cannot frame as a user question, inconsistent state — surfaced verbatim, no retry).
```
**Replace:**
```
The driver runs in the main agent loop and dispatches **one independent `Agent` sub-agent per phase, in order**, in the **shared working tree** (never with worktree isolation — `/e5`'s build edits must be visible to `/e6` test, `/e7` review, `/e8` polish, and `/e9` commit). After each phase agent returns, the driver inspects its report and either **advances** (clean exit), **pauses** (the phase surfaced an interactive gate or a structured open question — lift it to the user via `AskUserQuestion`, feed the answer back, re-dispatch the same phase against its on-disk artifact), or **halts** (any other non-clean outcome — failure, ambiguity it cannot frame as a user question, inconsistent state — surfaced verbatim, no retry).
```
**Verification:** `grep -F "`/e5`'s build edits must be visible to `/e6` test, `/e7` review, `/e8` polish, and `/e9` commit" host/templates/claude/commands/e-all.md` returns 1.

### Step 1.71 — EDIT e-all.md gate-heavy para (Gate-bearing phase refs + Polish/Finalize renumber)

**Operation:** EDIT
**File:** `host/templates/claude/commands/e-all.md`
**Locate:**
```
`/e-all` is **gate-heavy.** The phases `/e-all` dispatches (through Review) carry genuine interactive judgment gates — `/e2` Gate 2a design dialog and Gate 2b approval, `/e3` Gate 3 approval — where `/f-all`'s chain mostly auto-advanced. So `/e-all` **pauses far more often** than `/f-all`: each gate is a structured pause surfaced to the user and re-dispatched on the answer. The driver never makes a design call itself; it only sequences phases and relays the gate. (The later `/e7` polish dialog and `/e8` finalize confirmation are gates too, but they belong to the operator-driven Polish / Finalize phases `/e-all` does not auto-run — so `/e-all` never pauses on them.)
```
**Replace:**
```
`/e-all` is **gate-heavy.** The phases `/e-all` dispatches (through Review) carry genuine interactive judgment gates — `/e2` Gate 2a design dialog and Gate 2b approval, `/e3` Gate 3 approval — where `/f-all`'s chain mostly auto-advanced. So `/e-all` **pauses far more often** than `/f-all`: each gate is a structured pause surfaced to the user and re-dispatched on the answer. The driver never makes a design call itself; it only sequences phases and relays the gate. (The later `/e8` polish dialog and `/e9` finalize confirmation are gates too, but they belong to the operator-driven Polish / Finalize phases `/e-all` does not auto-run — so `/e-all` never pauses on them.)
```
**Verification:** `grep -F 'The later `/e8` polish dialog and `/e9` finalize confirmation are gates too' host/templates/claude/commands/e-all.md` returns 1.

### Step 1.72 — EDIT e-all.md "The chain" code block (renumber to e1→e7; merged e4; drop Quick/Standard branch rows)

**Operation:** EDIT
**File:** `host/templates/claude/commands/e-all.md`
**Locate:**
```
Phase 1  /e1-start-story                              [always, if ticket not yet captured]
Phase 2  /e2-define-spec                              [always]
Phase 3  /e3-plan-implementation + validate           [Standard path only]
         /e3b-write-testing-plan + validate           [Standard path AND TESTING_STANDARDS declares suites]
Phase 4  /e4-execute-plan                             [always]
Phase 5  /e5-execute-tests                            [always — required]
Phase 6  /e6-review-changes                           [always — terminal for /e-all; opens the PR when pr_provider == github]
         /e7-resolve-feedback (Polish, iterative)     [operator-driven — NOT auto-run by /e-all]
         /e8-finalize-story  (Finalize)               [operator-driven — NOT auto-run by /e-all]
```
**Replace:**
```
Phase 1  /e1-start-story                              [always, if ticket not yet captured]
Phase 2  /e2-define-spec                              [always]
Phase 3  /e3-plan-implementation + validate           [always — Plan is mandatory]
Phase 4  /e4-write-test-plan + validate               [always — user_test_plan.md always; testing_plan.md when TESTING_STANDARDS declares suites]
Phase 5  /e5-execute-plan                             [always — Build]
Phase 6  /e6-execute-tests                            [always — required]
Phase 7  /e7-review-changes                           [always — terminal for /e-all; opens the PR when pr_provider == github]
         /e8-resolve-feedback (Polish, iterative)     [operator-driven — NOT auto-run by /e-all]
         /e9-finalize-story  (Finalize)               [operator-driven — NOT auto-run by /e-all]
```
**Verification:** `grep -F '/e4-write-test-plan + validate' host/templates/claude/commands/e-all.md` returns 1. `grep -F '/e3b-write-testing-plan + validate' host/templates/claude/commands/e-all.md` returns 0. `grep -F 'Standard path only' host/templates/claude/commands/e-all.md` returns 0. `grep -F '/e7-review-changes' host/templates/claude/commands/e-all.md` returns ≥1.

### Step 1.73 — EDIT e-all.md post-chain paragraphs (remove Quick-path skip + e3b-conditional + e5b-exclusion; replace with mandatory-flow + testing_plan-conditional)

**Operation:** EDIT
**File:** `host/templates/claude/commands/e-all.md`
**Locate:**
```
**Quick-path stories skip `/e3` / `/e3b`** — the build (`/e4`) runs the spec's Build Checklist directly. The spec's `Path:` header (Quick vs Standard), read off `spec.md`, selects this for the rest of the chain.

**`/e3b` runs only when TESTING_STANDARDS declares automated suites** (and the path is Standard). The driver reads `.shamt-core/project-specific-files/TESTING_STANDARDS.md` to know whether `/e3b` and the automated-suite half of `/e5` apply. These are **mechanical disk/config reads, not user questions.** If TESTING_STANDARDS.md declares suites but is itself missing/incomplete, the driver does **not** pre-flight-fail on it — the case surfaces at Phase 5, where the dispatched `user-simulator` returns its `Cannot run: TESTING_STANDARDS.md missing/incomplete — complete it first.` exit, which the driver classifies as a **halt** (the user completes/fixes the file and re-invokes).

**`/e5b-write-manual-testing-plan` is excluded from the chain** — it is optional, on-demand, and orthogonal to the required Phase-5 agent-as-user run, mirroring `/f5`'s exclusion from `/f-all`. The user runs it by hand when a human walkthrough is wanted.
```
**Replace:**
```
**Every story runs the full chain** — Plan (`/e3`), Test Plan (`/e4`), Build (`/e5`), and Test (`/e6`) are all mandatory; there is no Quick/Standard split and no skipped phase. The build (`/e5`) always hands off to `plan-executor` against the validated `implementation_plan.md`.

**The automated `testing_plan.md` (authored in `/e4`) and the automated-suite half of `/e6` run only when TESTING_STANDARDS declares automated suites.** The `user_test_plan.md` is always authored in `/e4` and always executed in `/e6`. The driver reads `.shamt-core/project-specific-files/TESTING_STANDARDS.md` to know whether the automated `testing_plan.md` + the `test-executor` half of `/e6` apply. These are **mechanical disk/config reads, not user questions.** If TESTING_STANDARDS.md declares suites but is itself missing/incomplete, the driver does **not** pre-flight-fail on it — the case surfaces at Phase 6, where the dispatched `user-simulator` returns its `Cannot run: TESTING_STANDARDS.md missing/incomplete — complete it first.` exit, which the driver classifies as a **halt** (the user completes/fixes the file and re-invokes).
```
**Verification:** `grep -F 'Quick-path stories skip' host/templates/claude/commands/e-all.md` returns 0. `grep -F '/e5b-write-manual-testing-plan` is excluded' host/templates/claude/commands/e-all.md` returns 0. `grep -F 'Every story runs the full chain' host/templates/claude/commands/e-all.md` returns 1.

### Step 1.74 — EDIT e-all.md Step-1 gate-derivation intro (/e4 → /e5 the no-artifact phase)

**Operation:** EDIT
**File:** `host/templates/claude/commands/e-all.md`
**Locate:**
```
Phase resolution is at **phase-boundary granularity** — the driver dispatches each phase as a sub-agent and blocks until it returns, so there is no mid-phase resume to reconstruct. Like `/f-all` — which resolves its `/f3` boundary via a working-tree diff-coverage gate and its `/f4` boundary via a `regen --check` zero-drift gate rather than a dedicated artifact — `/e-all` uses a **gate** for any phase that records no durable artifact (most notably `/e4`). The discriminators, checked in order under `stories/{slug}/`:
```
**Replace:**
```
Phase resolution is at **phase-boundary granularity** — the driver dispatches each phase as a sub-agent and blocks until it returns, so there is no mid-phase resume to reconstruct. Like `/f-all` — which resolves its `/f3` boundary via a working-tree diff-coverage gate and its `/f4` boundary via a `regen --check` zero-drift gate rather than a dedicated artifact — `/e-all` uses a **gate** for any phase that records no durable artifact (most notably `/e5`, Build). The discriminators, checked in order under `stories/{slug}/`:
```
**Verification:** `grep -F 'most notably `/e5`, Build' host/templates/claude/commands/e-all.md` returns 1.

### Step 1.75 — EDIT e-all.md Step-1 discriminator table (renumber + merged e4 + drop Quick/Standard)

**Operation:** EDIT
**File:** `host/templates/claude/commands/e-all.md`
**Locate:**
```
| `ticket.md` **absent** | Intake not done | Phase 1 (`/e1`) |
| `ticket.md` present; `spec.md` **not** footed (or, on Standard, `context.md` not footed) | Spec not done | Phase 2 (`/e2`) |
| `spec.md` footed (its `Path:` header selects Quick vs Standard for the rest of the chain); **Standard** path and `implementation_plan.md` **not** footed | Plan not done | Phase 3 (`/e3`) |
| Standard, `implementation_plan.md` footed; TESTING_STANDARDS declares suites and the testing plan (`testing_plan.md` footed / spec inline checklist validated) **not** yet present | Testing plan not done | Phase 3 (`/e3b`) |
| Plan done (Standard: `implementation_plan.md` footed; Quick: spec footed) and `/e3b` done/non-applicable; **build gate** does **not** walk clean | Build not done | Phase 4 (`/e4`) |
| Build gate walks clean; `agent_test_session.md` verdict **not** `Session PASS` (or, when suites exist, `testing_plan.md` Results Log not all PASS) | Test not done | Phase 5 (`/e5`) |
| Tests pass; `feedback/review_vN.md` **not** footed (and no Quick-path `## Post-Build Review` block on the footed spec) | Review not done | Phase 6 (`/e6`) — **terminal** for `/e-all` |
| Review done (`feedback/review_vN.md` footed; PR opened when `pr_provider == github`) | `/e-all` is complete — Polish (`/e7`) and Finalize (`/e8`) are **operator-driven** | Nothing — `/e-all` exits at the end of Review; direct the user to `/e7-resolve-feedback {slug}` (iterative) then `/e8-finalize-story {slug}` |
```
**Replace:**
```
| `ticket.md` **absent** | Intake not done | Phase 1 (`/e1`) |
| `ticket.md` present; `spec.md` **not** footed (or `context.md` not footed) | Spec not done | Phase 2 (`/e2`) |
| `spec.md` + `context.md` footed; `implementation_plan.md` **not** footed | Plan not done | Phase 3 (`/e3`) |
| `implementation_plan.md` footed; `user_test_plan.md` **not** footed (or, when TESTING_STANDARDS declares suites, `testing_plan.md` **not** footed) | Test plan not done | Phase 4 (`/e4`) |
| Test plan done (`user_test_plan.md` footed; `testing_plan.md` footed when suites declared); **build gate** does **not** walk clean | Build not done | Phase 5 (`/e5`) |
| Build gate walks clean; `agent_test_session.md` verdict **not** `Session PASS` (or, when suites exist, `testing_plan.md` Results Log not all PASS) | Test not done | Phase 6 (`/e6`) |
| Tests pass; `feedback/review_vN.md` **not** footed | Review not done | Phase 7 (`/e7`) — **terminal** for `/e-all` |
| Review done (`feedback/review_vN.md` footed; PR opened when `pr_provider == github`) | `/e-all` is complete — Polish (`/e8`) and Finalize (`/e9`) are **operator-driven** | Nothing — `/e-all` exits at the end of Review; direct the user to `/e8-resolve-feedback {slug}` (iterative) then `/e9-finalize-story {slug}` |
```
**Verification:** `grep -F '`/e3b`' host/templates/claude/commands/e-all.md` returns 0 in the table region. `grep -F 'Quick-path `## Post-Build Review`' host/templates/claude/commands/e-all.md` returns 0. `grep -F 'Phase 7 (`/e7`) — **terminal** for `/e-all`' host/templates/claude/commands/e-all.md` returns 1. `grep -F 'user_test_plan.md` **not** footed' host/templates/claude/commands/e-all.md` returns 1.

### Step 1.76 — EDIT e-all.md "/e4 done is gate-derived" para (→ /e5)

**Operation:** EDIT
**File:** `host/templates/claude/commands/e-all.md`
**Locate:**
```
**`/e4` done is gate-derived, not artifact-derived.** `/e4-execute-plan` writes **no** "build complete" marker — its output is working-tree edits + commits per the plan's convention. So the `/e4` discriminator is the **build gate**: the plan's `## Verification` section (Standard) or the spec's Build Checklist (Quick) walks clean against the working tree, mirroring `/f-all`'s diff-coverage gate.
```
**Replace:**
```
**`/e5` done is gate-derived, not artifact-derived.** `/e5-execute-plan` writes **no** "build complete" marker — its output is working-tree edits + commits per the plan's convention. So the `/e5` discriminator is the **build gate**: the plan's `## Verification` section walks clean against the working tree, mirroring `/f-all`'s diff-coverage gate.
```
**Verification:** `grep -F '**`/e5` done is gate-derived' host/templates/claude/commands/e-all.md` returns 1. `grep -F 'the spec's Build Checklist (Quick)' host/templates/claude/commands/e-all.md` returns 0.

### Step 1.77 — EDIT e-all.md "/e7 writes proposals" inconsistent-state para (Phase 7→8 reference for Polish)

**Operation:** EDIT
**File:** `host/templates/claude/commands/e-all.md`
**Locate:**
```
**Unrelated `.shamt-core/proposals/` additions are NOT an inconsistent state.** New files under `.shamt-core/proposals/` (from a parallel session — or from this story's own `/e7`, which writes a generalizable root cause there) that the slug derivation does not map to *this* story's phase signals are **expected and accepted** parallel-session work — Shamt is multi-session and parallel by design (Principle 3 — disk-authoritative cross-session work). They are **never** an "inconsistent state" the driver halts on, and the driver **never** reverts, renames-back, or deletes them. In particular, because `/e7-resolve-feedback` (Phase 7) *actively writes* to `.shamt-core/proposals/`, the driver must not revert *other* proposals present alongside the one this story's `/e7` adds. The strict-halt above fires only on a partially-applied phase of *this* story whose exit gate cannot be confirmed — not on unrelated tree state. This is the driver-level analog of the live `/f3`/`/f6` accept-and-fold rule (`/f3-implement-update.md:34`, `/f6-archive-proposal.md`).
```
**Replace:**
```
**Unrelated `.shamt-core/proposals/` additions are NOT an inconsistent state.** New files under `.shamt-core/proposals/` (from a parallel session — or from this story's own `/e8`, which writes a generalizable root cause there) that the slug derivation does not map to *this* story's phase signals are **expected and accepted** parallel-session work — Shamt is multi-session and parallel by design (Principle 3 — disk-authoritative cross-session work). They are **never** an "inconsistent state" the driver halts on, and the driver **never** reverts, renames-back, or deletes them. In particular, because `/e8-resolve-feedback` (Phase 8) *actively writes* to `.shamt-core/proposals/`, the driver must not revert *other* proposals present alongside the one this story's `/e8` adds. The strict-halt above fires only on a partially-applied phase of *this* story whose exit gate cannot be confirmed — not on unrelated tree state. This is the driver-level analog of the live `/f3`/`/f6` accept-and-fold rule (`/f3-implement-update.md:34`, `/f6-archive-proposal.md`).
```
**Verification:** `grep -F 'because `/e8-resolve-feedback` (Phase 8) *actively writes*' host/templates/claude/commands/e-all.md` returns 1.

### Step 1.78 — EDIT e-all.md Step-1 example derived-start line (Phase 4 → Phase 5 build wording)

**Operation:** EDIT
**File:** `host/templates/claude/commands/e-all.md`
**Locate:**
```
State the derived starting phase in one line before dispatching anything (e.g. `Starting at Phase 4 — spec footed (Standard), plan footed, build gate not yet clean.`).
```
**Replace:**
```
State the derived starting phase in one line before dispatching anything (e.g. `Starting at Phase 5 — spec/context footed, plan footed, test plan footed, build gate not yet clean.`).
```
**Verification:** `grep -F 'Starting at Phase 5 — spec/context footed' host/templates/claude/commands/e-all.md` returns 1. `grep -F 'spec footed (Standard)' host/templates/claude/commands/e-all.md` returns 0.

### Step 1.79 — EDIT e-all.md Step-2 worktree justification line (/e4..→ renumbered)

**Operation:** EDIT
**File:** `host/templates/claude/commands/e-all.md`
**Locate:**
```
A sub-agent cannot spawn another sub-agent, yet several Engineer-flow phases need an inner persona. This is the **same** constraint `reference/batch_validation_handoff.md` already solves, and `/e-all` adopts its solution verbatim — keeping the topology at **exactly one nesting level**: driver → phase agent, and separately driver → inner persona. `/e-all` spans **more** inner personas than `/f-all` (`validation-checker`, `plan-executor`, `user-simulator`, `test-executor`), each lifted up to the driver under the same one-nesting-level rule.
```
**Replace:**
```
A sub-agent cannot spawn another sub-agent, yet several Engineer-flow phases need an inner persona. This is the **same** constraint `reference/batch_validation_handoff.md` already solves, and `/e-all` adopts its solution verbatim — keeping the topology at **exactly one nesting level**: driver → phase agent, and separately driver → inner persona. `/e-all` spans **more** inner personas than `/f-all` (`validation-checker`, `plan-executor`, `user-simulator`, `test-executor`), each lifted up to the driver under the same one-nesting-level rule.

(Phase numbers below are the renumbered chain: `/e1` Intake, `/e2` Spec, `/e3` Plan, `/e4` Test Plan, `/e5` Build, `/e6` Test, `/e7` Review.)
```
**Verification:** `grep -F '`/e4` Test Plan, `/e5` Build, `/e6` Test, `/e7` Review' host/templates/claude/commands/e-all.md` returns 1.

### Step 1.80 — EDIT e-all.md Step-2 two-kinds-of-phase bullets (self-contained = /e1 + /e9; inner-persona phase refs)

**Operation:** EDIT
**File:** `host/templates/claude/commands/e-all.md`
**Locate:**
```
- **Self-contained phases — invoke the `/eX` command directly in their own sub-agent.** `/e1-start-story` and `/e8-finalize-story` (and any Quick-path phase that spawns nothing). Dispatch one `Agent` whose prompt tells it to run `/eX {slug}` to completion in the shared working tree and report its terminal message.

- **Phases that internally need a sub-agent — run the command's inline steps and halt at the hand-off point; the driver then dispatches the inner persona itself.** `/e2` / `/e3` / `/e3b` / `/e6` validation → `validation-checker`; `/e4` build hand-off → `plan-executor`; `/e5` → `user-simulator` (+ `test-executor` when suites exist). The per-phase agent is driven by the phase command's **inline instructions** and stops at the hand-off point; the **driver** then dispatches the canonical inner persona against the on-disk artifacts, exactly as the batch-validation orchestrator lifts the checker-spawn up to itself.
```
**Replace:**
```
- **Self-contained phases — invoke the `/eX` command directly in their own sub-agent.** `/e1-start-story` (and `/e9-finalize-story` when run by hand — though `/e-all` stops at Review and never dispatches it). Dispatch one `Agent` whose prompt tells it to run `/eX {slug}` to completion in the shared working tree and report its terminal message.

- **Phases that internally need a sub-agent — run the command's inline steps and halt at the hand-off point; the driver then dispatches the inner persona itself.** `/e2` / `/e3` / `/e4` / `/e7` validation → `validation-checker`; `/e5` build hand-off → `plan-executor`; `/e6` → `user-simulator` (+ `test-executor` when suites exist). The per-phase agent is driven by the phase command's **inline instructions** and stops at the hand-off point; the **driver** then dispatches the canonical inner persona against the on-disk artifacts, exactly as the batch-validation orchestrator lifts the checker-spawn up to itself.
```
**Verification:** `grep -F '`/e2` / `/e3` / `/e4` / `/e7` validation → `validation-checker`' host/templates/claude/commands/e-all.md` returns 1. `grep -F '`/e5` build hand-off → `plan-executor`' host/templates/claude/commands/e-all.md` returns 1. `grep -F '`/e6` → `user-simulator`' host/templates/claude/commands/e-all.md` returns 1.

### Step 1.81 — EDIT e-all.md Step-2 "infeasible approach" para (renumber phase refs)

**Operation:** EDIT
**File:** `host/templates/claude/commands/e-all.md`
**Locate:**
```
**The infeasible approach, ruled out:** naively dispatching a sub-agent to *invoke* `/eX` and expecting it to halt is wrong — invoking `/e2` / `/e3` / `/e3b` / `/e6` auto-proceeds to spawn `validation-checker`, invoking `/e4` auto-hands-off to `plan-executor`, invoking `/e5` auto-spawns `user-simulator` / `test-executor` — each a forbidden second nesting level. The per-phase agent for those phases must run the **inline steps**, never the `/eX` command.
```
**Replace:**
```
**The infeasible approach, ruled out:** naively dispatching a sub-agent to *invoke* `/eX` and expecting it to halt is wrong — invoking `/e2` / `/e3` / `/e4` / `/e7` auto-proceeds to spawn `validation-checker`, invoking `/e5` auto-hands-off to `plan-executor`, invoking `/e6` auto-spawns `user-simulator` / `test-executor` — each a forbidden second nesting level. The per-phase agent for those phases must run the **inline steps**, never the `/eX` command.
```
**Verification:** `grep -F '`/e3b`' host/templates/claude/commands/e-all.md` returns 0 (whole file after this step except the Phase-by-phase section handled next — re-check at Step 1.91). `grep -F 'invoking `/e2` / `/e3` / `/e4` / `/e7` auto-proceeds' host/templates/claude/commands/e-all.md` returns 1.

### Step 1.82 — EDIT e-all.md Step-2 accept-and-fold para (proposals-write phase /e7→/e8)

**Operation:** EDIT
**File:** `host/templates/claude/commands/e-all.md`
**Locate:**
```
The disambiguator is **provenance + timing**, never "is this proposal/artifact unfamiliar to me": work *already present in the tree when this agent started* (or authored by another session) is accepted and folds into the landing; only an edit *this agent itself made this dispatch, off-task* may be reverted (the agent's own scope creep — the existing own-stray-edit guardrail stands). This is the same two-case split `/f3-implement-update.md:125` encodes (unrelated/parallel state → never revert; the agent's own genuinely-missing change → in-place amendment). This matters most for `.shamt-core/proposals/`: because `/e7-resolve-feedback` writes a generalizable root cause there, a later phase agent (or the driver) must not "tidy" *other* proposals sitting alongside the one `/e7` adds.
```
**Replace:**
```
The disambiguator is **provenance + timing**, never "is this proposal/artifact unfamiliar to me": work *already present in the tree when this agent started* (or authored by another session) is accepted and folds into the landing; only an edit *this agent itself made this dispatch, off-task* may be reverted (the agent's own scope creep — the existing own-stray-edit guardrail stands). This is the same two-case split `/f3-implement-update.md:125` encodes (unrelated/parallel state → never revert; the agent's own genuinely-missing change → in-place amendment). This matters most for `.shamt-core/proposals/`: because `/e8-resolve-feedback` writes a generalizable root cause there, a later phase agent (or the driver) must not "tidy" *other* proposals sitting alongside the one `/e8` adds.
```
**Verification:** `grep -F 'because `/e8-resolve-feedback` writes a generalizable root cause there' host/templates/claude/commands/e-all.md` returns 1.

### Step 1.83 — EDIT e-all.md architect/builder-split Note (/e3 plans, /e4→/e5 builds)

**Operation:** EDIT
**File:** `host/templates/claude/commands/e-all.md`
**Locate:**
```
Unlike `/f-all`'s `/f3` (which both plans and hands off within one phase), the Engineer flow splits the architect and builder across **two** phases: the architect plans at `/e3` and the cheap-tier builder executes at `/e4`. So the `plan-executor` dispatch is **`/e4`'s**, not `/e3`'s. `/e3` is a validation phase (`validation-checker`); `/e4` is the build hand-off (`plan-executor`).
```
**Replace:**
```
Unlike `/f-all`'s `/f3` (which both plans and hands off within one phase), the Engineer flow splits the architect and builder across **two** phases: the architect plans at `/e3` and the cheap-tier builder executes at `/e5` (Build). So the `plan-executor` dispatch is **`/e5`'s**, not `/e3`'s. `/e3` is a validation phase (`validation-checker`); `/e5` is the build hand-off (`plan-executor`).
```
**Verification:** `grep -F 'the cheap-tier builder executes at `/e5` (Build)' host/templates/claude/commands/e-all.md` returns 1. `grep -F 'So the `plan-executor` dispatch is **`/e5`'s**' host/templates/claude/commands/e-all.md` returns 1.

### Step 1.84 — EDIT e-all.md Phase-by-phase: Phase-3 block (drop Standard-only/e3b; mandatory Plan)

**Operation:** EDIT
**File:** `host/templates/claude/commands/e-all.md`
**Locate:**
```
**Phase 3 — `/e3-plan-implementation` + `/e3b-write-testing-plan`** *(Standard path only; `/e3b` only when TESTING_STANDARDS declares suites)*:
1. **`/e3` plan** — run `/e3`'s **inline** steps in the phase agent up to the validation hand-off; the driver lifts `validation-checker` on `implementation_plan.md`, re-converging to `CONFIRMED`. Gate 3 (plan approval) is a **pause**.
2. **`/e3b` testing plan** — same inline + driver-lifted-`validation-checker` topology on `testing_plan.md` (or the spec's inline checklist). Skipped when TESTING_STANDARDS declares no suites.

**Phase 4 — `/e4-execute-plan`.** Build hand-off. Run `/e4`'s **inline** steps in the phase agent up to the `plan-executor` hand-off (Standard path), then the **driver** dispatches `plan-executor` (Cheap) against `implementation_plan.md`. On a Quick-path story, `/e4` executes the spec's Build Checklist directly — dispatch it as a self-contained phase that spawns nothing. Branch off `plan-executor`'s report per Step 3.

**Phase 5 — `/e5-execute-tests`.** Run `/e5`'s **inline** steps in the phase agent up to the hand-off, then the **driver** dispatches `user-simulator` (Balanced — the required agent-as-user run) and, when TESTING_STANDARDS declares suites, `test-executor` (Cheap — the automated suites) against the testing artifacts in the shared tree. Branch off each persona's report per Step 3 — `Session PASS` / `All steps passed. Results logged.` advance; failures halt; an ambiguous exit pauses.

**Phase 6 — `/e6-review-changes`.** Story mode. Run `/e6`'s **inline** steps in the phase agent (the 16-category sweep against the story's own diff, writing `feedback/review_vN.md`) up to the validation hand-off; the driver lifts `validation-checker` on the review, re-converging to `CONFIRMED`. (`/e-all` always runs `/e6` in **story mode** against the story's own diff — the `--branch=` / `--pr=` formal modes are not part of the per-story chain.)

**`/e-all` stops here — Polish and Finalize are operator-driven.** `/e-all` terminates at the end of Phase 6 (Review). Because Polish (`/e7-resolve-feedback`) is now an **iterative** human-in-the-loop PR cycle (each run pulls the latest PR comments and pushes fix commits) and Finalize (`/e8-finalize-story`) merges the PR, neither is auto-run by the driver — the operator invokes `/e7-resolve-feedback {slug}` (N times, as comments arrive) and then `/e8-finalize-story {slug}` by hand. Both remain independently runnable per-phase commands.
```
**Replace:**
```
**Phase 3 — `/e3-plan-implementation`** *(always — Plan is mandatory)*: run `/e3`'s **inline** steps in the phase agent up to the validation hand-off; the driver lifts `validation-checker` on `implementation_plan.md`, re-converging to `CONFIRMED`. Gate 3 (plan approval) is a **pause**.

**Phase 4 — `/e4-write-test-plan`** *(always — `user_test_plan.md` always; `testing_plan.md` when TESTING_STANDARDS declares suites)*: run `/e4`'s **inline** steps in the phase agent up to each validation hand-off; the driver lifts `validation-checker` on `user_test_plan.md` (always) and on `testing_plan.md` (when suites are declared), re-converging each to `CONFIRMED`.

**Phase 5 — `/e5-execute-plan`.** Build hand-off. Run `/e5`'s **inline** steps in the phase agent up to the `plan-executor` hand-off, then the **driver** dispatches `plan-executor` (Cheap) against `implementation_plan.md`. Branch off `plan-executor`'s report per Step 3.

**Phase 6 — `/e6-execute-tests`.** Run `/e6`'s **inline** steps in the phase agent up to the hand-off, then the **driver** dispatches `user-simulator` (Balanced — the required agent-as-user run, executing `user_test_plan.md`) and, when TESTING_STANDARDS declares suites, `test-executor` (Cheap — the automated suites) against the testing artifacts in the shared tree. Branch off each persona's report per Step 3 — `Session PASS` / `All steps passed. Results logged.` advance; failures halt; an ambiguous exit pauses.

**Phase 7 — `/e7-review-changes`.** Story mode. Run `/e7`'s **inline** steps in the phase agent (the 16-category sweep against the story's own diff, writing `feedback/review_vN.md`) up to the validation hand-off; the driver lifts `validation-checker` on the review, re-converging to `CONFIRMED`. (`/e-all` always runs `/e7` in **story mode** against the story's own diff — the `--branch=` / `--pr=` formal modes are not part of the per-story chain.)

**`/e-all` stops here — Polish and Finalize are operator-driven.** `/e-all` terminates at the end of Phase 7 (Review). Because Polish (`/e8-resolve-feedback`) is now an **iterative** human-in-the-loop PR cycle (each run pulls the latest PR comments and pushes fix commits) and Finalize (`/e9-finalize-story`) merges the PR, neither is auto-run by the driver — the operator invokes `/e8-resolve-feedback {slug}` (N times, as comments arrive) and then `/e9-finalize-story {slug}` by hand. Both remain independently runnable per-phase commands.
```
**Verification:** `grep -F '`/e3b`' host/templates/claude/commands/e-all.md` returns 0 (whole file). `grep -F '**Phase 4 — `/e4-write-test-plan`**' host/templates/claude/commands/e-all.md` returns 1. `grep -F '**Phase 7 — `/e7-review-changes`.**' host/templates/claude/commands/e-all.md` returns 1. `grep -F '`/e-all` terminates at the end of Phase 7 (Review)' host/templates/claude/commands/e-all.md` returns 1.

### Step 1.85 — EDIT e-all.md Step-3 Advance bullets (phase refs renumber)

**Operation:** EDIT
**File:** `host/templates/claude/commands/e-all.md`
**Locate:**
```
- A clean validation exit (primary clean + `CONFIRMED: Zero issues found after adversarial review.` from `validation-checker`, footer stamped) — for `/e2` / `/e3` / `/e3b` / `/e6`.
- `plan-executor` → `All steps completed. Verification passed.` (Phase 4).
- `test-executor` → `All steps passed. Results logged.`; `user-simulator` → `Session PASS` (Phase 5).
- A self-contained phase agent reporting its `/eX` command completed at its documented exit (`/e1` ticket captured; `/e8` committed + tracker-closed).
```
**Replace:**
```
- A clean validation exit (primary clean + `CONFIRMED: Zero issues found after adversarial review.` from `validation-checker`, footer stamped) — for `/e2` / `/e3` / `/e4` / `/e7`.
- `plan-executor` → `All steps completed. Verification passed.` (Phase 5).
- `test-executor` → `All steps passed. Results logged.`; `user-simulator` → `Session PASS` (Phase 6).
- A self-contained phase agent reporting its `/eX` command completed at its documented exit (`/e1` ticket captured; `/e9` committed + tracker-closed when run by hand).
```
**Verification:** `grep -F 'for `/e2` / `/e3` / `/e4` / `/e7`.' host/templates/claude/commands/e-all.md` returns 1. `grep -F '(Phase 5).' host/templates/claude/commands/e-all.md` returns ≥1.

### Step 1.86 — EDIT e-all.md Step-3 Pause bullets (gate phase refs; Polish/Finalize /e7→/e8, /e8→/e9; Phase 5→6)

**Operation:** EDIT
**File:** `host/templates/claude/commands/e-all.md`
**Locate:**
```
- An **interactive gate** — Gate 2a design dialog (`/e2`), Gate 2b approval (`/e2`), Gate 3 plan approval (`/e3`). (Polish `/e7` and Finalize `/e8` carry their own gates — the `/e7` polish dialog, the `/e8` finalize confirmation — but `/e-all` stops at Review and never dispatches them, so those gates are surfaced only when the operator runs `/e7` / `/e8` by hand.) Gate 2a's 1–3 design options and the 2b / 3 approvals each map cleanly onto **one** `AskUserQuestion` round-trip; **multi-round** design dialog is handled by **successive re-dispatches off the now-updated on-disk artifact**.
- `plan-executor` → `Step [N] is ambiguous: …` (its contract states what would disambiguate — surface that as the question).
- `test-executor` → `Step [N] is ambiguous: …` — a structured open question lifted to the user as a pause (mirroring `plan-executor`'s identically-named ambiguous exit, and **distinct from a test failure** that halts). The driver surfaces it via `AskUserQuestion` and re-dispatches Phase 5 against the on-disk testing artifact on the answer, exactly as the gate-pause cases do.
```
**Replace:**
```
- An **interactive gate** — Gate 2a design dialog (`/e2`), Gate 2b approval (`/e2`), Gate 3 plan approval (`/e3`). (Polish `/e8` and Finalize `/e9` carry their own gates — the `/e8` polish dialog, the `/e9` finalize confirmation — but `/e-all` stops at Review and never dispatches them, so those gates are surfaced only when the operator runs `/e8` / `/e9` by hand.) Gate 2a's 1–3 design options and the 2b / 3 approvals each map cleanly onto **one** `AskUserQuestion` round-trip; **multi-round** design dialog is handled by **successive re-dispatches off the now-updated on-disk artifact**.
- `plan-executor` → `Step [N] is ambiguous: …` (its contract states what would disambiguate — surface that as the question).
- `test-executor` → `Step [N] is ambiguous: …` — a structured open question lifted to the user as a pause (mirroring `plan-executor`'s identically-named ambiguous exit, and **distinct from a test failure** that halts). The driver surfaces it via `AskUserQuestion` and re-dispatches Phase 6 against the on-disk testing artifact on the answer, exactly as the gate-pause cases do.
```
**Verification:** `grep -F '(Polish `/e8` and Finalize `/e9` carry their own gates' host/templates/claude/commands/e-all.md` returns 1. `grep -F 're-dispatches Phase 6 against the on-disk testing artifact' host/templates/claude/commands/e-all.md` returns 1.

### Step 1.87 — EDIT e-all.md Step-3 sentinel-contract gate-bearing phases (/e2, /e3 unchanged numbers — confirm artifact path list)

**Operation:** EDIT
**File:** `host/templates/claude/commands/e-all.md`
**Locate:**
```
2. Because each re-dispatch starts a **fresh** sub-agent context, the dispatch prompt must **point the re-dispatched agent at the on-disk artifact** (`spec.md` / `implementation_plan.md` / `feedback/review_vN.md`) so it resumes from saved state rather than lost conversation — the same disk-derived continuity the whole driver relies on.
```
**Replace:**
```
2. Because each re-dispatch starts a **fresh** sub-agent context, the dispatch prompt must **point the re-dispatched agent at the on-disk artifact** (`spec.md` / `context.md` / `implementation_plan.md` / `user_test_plan.md` / `testing_plan.md` / `feedback/review_vN.md`) so it resumes from saved state rather than lost conversation — the same disk-derived continuity the whole driver relies on.
```
**Verification:** `grep -F 'user_test_plan.md` / `testing_plan.md` / `feedback/review_vN.md`' host/templates/claude/commands/e-all.md` returns 1.

### Step 1.88 — EDIT e-all.md Step-3 sentinel accept-and-fold detail (/e7 proposal-write → /e8)

**Operation:** EDIT
**File:** `host/templates/claude/commands/e-all.md`
**Locate:**
```
This is the channel that actually reaches each inline phase agent (it never reads this command's Notes), so the clause is load-bearing here, not optional documentation. A phase agent that returns a report claiming it reverted/removed unrelated `.shamt-core/proposals/` work has violated the invariant — the driver does **not** accept such a revert; per Step 1 unrelated `.shamt-core/proposals/` additions are never an inconsistent state, and `/e7`'s own proposal-write must not cause *other* proposals to be reverted.
```
**Replace:**
```
This is the channel that actually reaches each inline phase agent (it never reads this command's Notes), so the clause is load-bearing here, not optional documentation. A phase agent that returns a report claiming it reverted/removed unrelated `.shamt-core/proposals/` work has violated the invariant — the driver does **not** accept such a revert; per Step 1 unrelated `.shamt-core/proposals/` additions are never an inconsistent state, and `/e8`'s own proposal-write must not cause *other* proposals to be reverted.
```
**Verification:** `grep -F "and `/e8`'s own proposal-write must not cause *other* proposals to be reverted" host/templates/claude/commands/e-all.md` returns 1.

### Step 1.89 — EDIT e-all.md Step-3 Halt bullets (Phase-5→6 failure routing; /e7→/e8 loop refs; /e5→/e6; /e8 guard→/e9)

**Operation:** EDIT
**File:** `host/templates/claude/commands/e-all.md`
**Locate:**
```
- **Any Phase-5 *failure* exit** (Q-testloop → strict halt): `test-executor` → `Step [N] failed: Story bug — …` / `Test bug — …` / `Spec gap — …` / `Plan defect at Step [N]: …` / `Environment blocked at Step [N]: …`; `user-simulator` → `Session BLOCKED: …` or `Cannot run: TESTING_STANDARDS.md missing/incomplete — complete it first.` The Engineer flow routes a Phase-5 failure to `/e7` for a root-cause loop, but **`/e-all` does NOT drive that loop unattended** — it halts and surfaces the executor's verbatim report; resuming via `/e7` (or fixing the build / plan / TESTING_STANDARDS) is the user's next move. The `/e5` → `/e7` → re-`/e5` loop stays a **manual** operation; **do not build an auto-fix loop**. (For `Environment blocked` specifically this is a **deliberate divergence** from the per-phase `/e5-execute-tests`, which runs a one-question "which infrastructure piece is missing?" dialog and re-invokes `/e5` after the user resolves it externally; `/e-all` instead **halts** under the same strict-halt / no-autonomous-loop safety rule — the divergence is intentional, not an oversight.)
- Any failed or non-convergent validation (a `validation-checker` that never reaches `CONFIRMED`, a primary that cannot reach a clean round).
- A self-contained phase agent reporting its `/eX` command halted (`/e1` intake blocked; `/e8` a guard failed).
```
**Replace:**
```
- **Any Phase-6 *failure* exit** (Q-testloop → strict halt): `test-executor` → `Step [N] failed: Story bug — …` / `Test bug — …` / `Spec gap — …` / `Plan defect at Step [N]: …` / `Environment blocked at Step [N]: …`; `user-simulator` → `Session BLOCKED: …` or `Cannot run: TESTING_STANDARDS.md missing/incomplete — complete it first.` The Engineer flow routes a Phase-6 failure to `/e8` for a root-cause loop, but **`/e-all` does NOT drive that loop unattended** — it halts and surfaces the executor's verbatim report; resuming via `/e8` (or fixing the build / plan / TESTING_STANDARDS) is the user's next move. The `/e6` → `/e8` → re-`/e6` loop stays a **manual** operation; **do not build an auto-fix loop**. (For `Environment blocked` specifically this is a **deliberate divergence** from the per-phase `/e6-execute-tests`, which runs a one-question "which infrastructure piece is missing?" dialog and re-invokes `/e6` after the user resolves it externally; `/e-all` instead **halts** under the same strict-halt / no-autonomous-loop safety rule — the divergence is intentional, not an oversight.)
- Any failed or non-convergent validation (a `validation-checker` that never reaches `CONFIRMED`, a primary that cannot reach a clean round).
- A self-contained phase agent reporting its `/eX` command halted (`/e1` intake blocked; `/e9` a guard failed when run by hand).
```
**Verification:** `grep -F '**Any Phase-6 *failure* exit**' host/templates/claude/commands/e-all.md` returns 1. `grep -F 'The `/e6` → `/e8` → re-`/e6` loop stays a **manual** operation' host/templates/claude/commands/e-all.md` returns 1.

### Step 1.90 — EDIT e-all.md Step-4 Exit block (/e6 → /e7; example phase list; Polish/Finalize /e7→/e8, /e8→/e9)

**Operation:** EDIT
**File:** `host/templates/claude/commands/e-all.md`
**Locate:**
```
When `/e6` reports the validated review (and, when `pr_provider == github`, the opened PR), state the exit clearly:

```text
/e-all complete for {slug}. Phases run: {list, e.g. e2 → e3 → e4 → e5 → e6}.
The review is validated{, and the PR is open at <url> when pr_provider == github}.
Next (operator-driven): /e7-resolve-feedback {slug} (iterative — re-run as PR comments arrive), then /e8-finalize-story {slug}.
```

`/e-all` ends at the end of Review. Polish (`/e7`, iterative) and Finalize (`/e8`) are **operator-driven** — the driver does not auto-run them.
```
**Replace:**
```
When `/e7` reports the validated review (and, when `pr_provider == github`, the opened PR), state the exit clearly:

```text
/e-all complete for {slug}. Phases run: {list, e.g. e2 → e3 → e4 → e5 → e6 → e7}.
The review is validated{, and the PR is open at <url> when pr_provider == github}.
Next (operator-driven): /e8-resolve-feedback {slug} (iterative — re-run as PR comments arrive), then /e9-finalize-story {slug}.
```

`/e-all` ends at the end of Review. Polish (`/e8`, iterative) and Finalize (`/e9`) are **operator-driven** — the driver does not auto-run them.
```
**Verification:** `grep -F 'Next (operator-driven): /e8-resolve-feedback {slug}' host/templates/claude/commands/e-all.md` returns 1. `grep -F 'When `/e7` reports the validated review' host/templates/claude/commands/e-all.md` returns 1.

### Step 1.91 — EDIT e-all.md Step-4 pause/halt resumption sentence (/e7→/e8, /e8→/e9)

**Operation:** EDIT
**File:** `host/templates/claude/commands/e-all.md`
**Locate:**
```
If the run **paused**, the pause is not an exit — it is one round-trip through `AskUserQuestion`; the driver resumes automatically after the answer. If the run **halted**, report the halting phase's verbatim message and the per-phase command to resume from; do not present the run as complete.
```
**Replace:**
```
If the run **paused**, the pause is not an exit — it is one round-trip through `AskUserQuestion`; the driver resumes automatically after the answer. If the run **halted**, report the halting phase's verbatim message and the per-phase command to resume from; do not present the run as complete. (Polish `/e8` and Finalize `/e9` are the operator's by-hand next moves.)
```
**Verification:** `grep -F '(Polish `/e8` and Finalize `/e9` are the operator's by-hand next moves.)' host/templates/claude/commands/e-all.md` returns 1.

### Step 1.92 — EDIT e-all.md Exit criteria first bullet (/e6→/e7; Polish/Finalize /e7→/e8, /e8→/e9)

**Operation:** EDIT
**File:** `host/templates/claude/commands/e-all.md`
**Locate:**
```
- The story walked from its derived start phase through `/e6-review-changes` (review validated; PR opened when `pr_provider == github`), **or** the run paused on an interactive gate / structured open question (resumed in-place) / halted on a non-clean outcome with the verbatim report surfaced. Polish (`/e7`) and Finalize (`/e8`) are operator-driven and not part of the `/e-all` chain.
```
**Replace:**
```
- The story walked from its derived start phase through `/e7-review-changes` (review validated; PR opened when `pr_provider == github`), **or** the run paused on an interactive gate / structured open question (resumed in-place) / halted on a non-clean outcome with the verbatim report surfaced. Polish (`/e8`) and Finalize (`/e9`) are operator-driven and not part of the `/e-all` chain.
```
**Verification:** `grep -F 'through `/e7-review-changes` (review validated' host/templates/claude/commands/e-all.md` returns 1.

### Step 1.93 — EDIT e-all.md Notes: shared-tree bullet (/e4→/e5 build edits; downstream renumber)

**Operation:** EDIT
**File:** `host/templates/claude/commands/e-all.md`
**Locate:**
```
- **Shared working tree, never worktree isolation.** The chain depends on cross-phase working-tree state: `/e4`'s build edits must reach `/e5` (test), `/e6` (review), `/e7` (polish), and `/e8` (commit). Dispatching any phase with `isolation: worktree` would hide those edits from later phases and break the chain.
```
**Replace:**
```
- **Shared working tree, never worktree isolation.** The chain depends on cross-phase working-tree state: `/e5`'s build edits must reach `/e6` (test), `/e7` (review), `/e8` (polish), and `/e9` (commit). Dispatching any phase with `isolation: worktree` would hide those edits from later phases and break the chain.
```
**Verification:** `grep -F "`/e5`'s build edits must reach `/e6` (test), `/e7` (review), `/e8` (polish), and `/e9` (commit)" host/templates/claude/commands/e-all.md` returns 1.

### Step 1.94 — EDIT e-all.md Notes: strict-halt bullet (Phase-5→6; /e7→/e8 loop)

**Operation:** EDIT
**File:** `host/templates/claude/commands/e-all.md`
**Locate:**
```
- **Strict halt on test failure (no autonomous `/e7` loop).** On any Phase-5 *failure* exit the driver halts and surfaces the verbatim report; the `/e5` → `/e7` → re-`/e5` loop stays a manual operation. The lone Phase-5 *ambiguous* exit is a user-gated pause, not an autonomous retry. The driver never autonomously edits code to chase a green.
```
**Replace:**
```
- **Strict halt on test failure (no autonomous `/e8` loop).** On any Phase-6 *failure* exit the driver halts and surfaces the verbatim report; the `/e6` → `/e8` → re-`/e6` loop stays a manual operation. The lone Phase-6 *ambiguous* exit is a user-gated pause, not an autonomous retry. The driver never autonomously edits code to chase a green.
```
**Verification:** `grep -F '**Strict halt on test failure (no autonomous `/e8` loop).**' host/templates/claude/commands/e-all.md` returns 1.

### Step 1.95 — EDIT e-all.md Notes: terminal-at-Review bullet (/e6→/e7; Polish/Finalize /e7→/e8, /e8→/e9; #50 preserved)

**Operation:** EDIT
**File:** `host/templates/claude/commands/e-all.md`
**Locate:**
```
- **Terminal at Review — Polish + Finalize are operator-driven.** `/e-all` ends at `/e6-review-changes` (Review), opening the PR when `pr_provider == github`. It does **not** auto-run Polish (`/e7`) or Finalize (`/e8`), because Polish is now an **iterative** human-in-the-loop PR cycle (re-run as comments arrive) and Finalize merges the PR — both operator-driven, invoked by hand. The PR open at the end of Review is itself confirm-gated (a Step-3 pause). This makes `/e-all` strictly safer than `/f-all`'s autonomous squash-merge: it never autonomously merges or closes anything.
```
**Replace:**
```
- **Terminal at Review — Polish + Finalize are operator-driven.** `/e-all` ends at `/e7-review-changes` (Review), opening the PR when `pr_provider == github`. It does **not** auto-run Polish (`/e8`) or Finalize (`/e9`), because Polish is now an **iterative** human-in-the-loop PR cycle (re-run as comments arrive) and Finalize merges the PR — both operator-driven, invoked by hand. The PR open at the end of Review is itself confirm-gated (a Step-3 pause). This makes `/e-all` strictly safer than `/f-all`'s autonomous squash-merge: it never autonomously merges or closes anything.
```
**Verification:** `grep -F '`/e-all` ends at `/e7-review-changes` (Review)' host/templates/claude/commands/e-all.md` returns 1. `grep -F 'It does **not** auto-run Polish (`/e8`) or Finalize (`/e9`)' host/templates/claude/commands/e-all.md` returns 1.

### Step 1.96 — EDIT e-all.md Notes: never-revert-parallel-work bullet (/e7-resolve-feedback → /e8-resolve-feedback)

**Operation:** EDIT
**File:** `host/templates/claude/commands/e-all.md`
**Locate:**
```
- **Never revert parallel work.** Unrelated in-tree work — new `.shamt-core/proposals/` files from a parallel session, **or** the *other* proposals sitting alongside the one this story's `/e7-resolve-feedback` writes — is expected and accepted: it folds into the landing and is **never** reverted, renamed-back, or deleted by the driver or any phase agent it dispatches.
```
**Replace:**
```
- **Never revert parallel work.** Unrelated in-tree work — new `.shamt-core/proposals/` files from a parallel session, **or** the *other* proposals sitting alongside the one this story's `/e8-resolve-feedback` writes — is expected and accepted: it folds into the landing and is **never** reverted, renamed-back, or deleted by the driver or any phase agent it dispatches.
```
**Verification:** `grep -F "the one this story's `/e8-resolve-feedback` writes" host/templates/claude/commands/e-all.md` returns 1.

### Step 1.97 — EDIT e-all.md whole-file residual-sweep verification (no body edit)

**Operation:** EDIT
**File:** `host/templates/claude/commands/e-all.md`
**Locate:** (no edit — verification-only step)
**Replace:** (none)
**Verification (whole file, after Steps 1.69–1.96):**
- `grep -nE 'Quick path|Quick-path|Standard path|Standard-path|/e3b|e5b|Post-Build Review|Build Checklist' host/templates/claude/commands/e-all.md` returns 0 matches.
- No stale low-numbered Engineer pointers survive in renumbered roles: `grep -F '/e4-execute-plan' host/templates/claude/commands/e-all.md` returns 0; `grep -F '/e5-execute-tests' host/templates/claude/commands/e-all.md` returns 0; `grep -F '/e6-review-changes' host/templates/claude/commands/e-all.md` returns 0; `grep -F '/e7-resolve-feedback' host/templates/claude/commands/e-all.md` returns 0; `grep -F '/e8-finalize-story' host/templates/claude/commands/e-all.md` returns 0.
- #50 terminal-at-Review wording survives: `grep -F 'Terminal at Review' host/templates/claude/commands/e-all.md` returns ≥1; `grep -F 'pr_provider == github' host/templates/claude/commands/e-all.md` returns ≥3; `grep -F 'iterative' -i host/templates/claude/commands/e-all.md` returns ≥3.
- The `Created 2026-06-15 — by /f3-implement-update for proposals/27-e-all-orchestrate-engineer-flow.md` provenance line is **left intact** (Principle 3 — never rewrite another session's provenance).

---

### Step 1.98 — EDIT validate-artifact.md frontmatter + Purpose (manual → user test plan)

**Operation:** EDIT
**File:** `host/templates/claude/commands/validate-artifact.md`
**Locate:**
```
description: Run a Shamt Pattern 1 validation loop on any artifact — spec, plan, code review, testing plan, manual test plan, proposal, or general document
```
**Replace:**
```
description: Run a Shamt Pattern 1 validation loop on any artifact — spec, plan, code review, testing plan, user test plan, proposal, or general document
```
**Verification:** `grep -F 'testing plan, user test plan, proposal' host/templates/claude/commands/validate-artifact.md` returns 1.

### Step 1.99 — EDIT validate-artifact.md Purpose sentence (manual → user)

**Operation:** EDIT
**File:** `host/templates/claude/commands/validate-artifact.md`
**Locate:**
```
**Purpose:** Run a Shamt Pattern 1 validation loop on a named artifact. The same primitive validates specs, implementation plans, code reviews, testing plans, manual test plans, framework-update proposals, and general documents.
```
**Replace:**
```
**Purpose:** Run a Shamt Pattern 1 validation loop on a named artifact. The same primitive validates specs, implementation plans, code reviews, testing plans, user test plans, framework-update proposals, and general documents.
```
**Verification:** `grep -F 'testing plans, user test plans, framework-update proposals' host/templates/claude/commands/validate-artifact.md` returns 1.

### Step 1.100 — EDIT validate-artifact.md Arguments example (manual_test_plan → user_test_plan)

**Operation:** EDIT
**File:** `host/templates/claude/commands/validate-artifact.md`
**Locate:**
```
  - `stories/42-add-export/manual_test_plan.md`
```
**Replace:**
```
  - `stories/42-add-export/user_test_plan.md`
```
**Verification:** `grep -F 'stories/42-add-export/manual_test_plan.md' host/templates/claude/commands/validate-artifact.md` returns 0. `grep -F 'stories/42-add-export/user_test_plan.md' host/templates/claude/commands/validate-artifact.md` returns 1.

### Step 1.101 — EDIT validate-artifact.md replace "## Path selection (Quick vs Standard)" with uniform exit

**Operation:** EDIT
**File:** `host/templates/claude/commands/validate-artifact.md`
**Locate:**
```
## Path selection (Quick vs Standard)

Pattern 1 has two exit shapes (see [`SHAMT_RULES.template.md`](../../../../templates/SHAMT_RULES.template.md) Pattern 1 and [`reference/validation_exit_criteria.md`](../../../../reference/validation_exit_criteria.md)):

- **Quick path:** a single primary self-review pass. No adversarial sub-agent required unless a risk trigger applies.
- **Standard path (or risk-triggered):** primary clean round + 1 independent adversarial sub-agent confirmation via the `validation-checker` persona. **Sub-agents have no one-LOW allowance** — any finding by the sub-agent (including a single LOW) resets `consecutive_clean` to 0.

Determine the path:

1. If the artifact lives under `stories/{slug}/` and the active spec declares **Path: Quick path**, use Quick.
2. If the artifact lives under `stories/{slug}/` and the active spec declares **Path: Standard path**, use Standard.
3. If the artifact is not story-scoped (e.g., `proposals/<slug>.md`), default to Standard.
4. Regardless of the declared path, if any **risk trigger** from Pattern 1 applies to the artifact's subject matter (security / auth / tenant isolation / permissions; DB schema, migrations, backfills; new service or significant module creation; public API or event contracts; multi-repo or multi-deploy ordering; irreversible deletes; payment / regulated / safety-critical behavior), upgrade to the Standard exit even if the spec said Quick.
5. If the user explicitly requested adversarial confirmation, use Standard.

State the chosen path and the reason in one line before the first round.
```
**Replace:**
```
## Exit shape (uniform)

Pattern 1 has a single, uniform exit shape (see [`SHAMT_RULES.template.md`](../../../../templates/SHAMT_RULES.template.md) Pattern 1 and [`reference/validation_exit_criteria.md`](../../../../reference/validation_exit_criteria.md)): **one primary clean round + 1 independent adversarial sub-agent confirmation** via the `validation-checker` persona — always, for every artifact. There is no Quick/Standard rigor selector and no single-pass / one-LOW-allowance shortcut. **Sub-agents have no one-LOW allowance** — any finding by the sub-agent (including a single LOW) resets `consecutive_clean` to 0.
```
**Verification:** `grep -c '## Path selection (Quick vs Standard)' host/templates/claude/commands/validate-artifact.md` returns 0. `grep -F '## Exit shape (uniform)' host/templates/claude/commands/validate-artifact.md` returns 1. `grep -F 'Path: Quick path' host/templates/claude/commands/validate-artifact.md` returns 0.

### Step 1.102 — EDIT validate-artifact.md Step-2 dimension table (manual → user; anchor cross-phase dep)

**Operation:** EDIT
**File:** `host/templates/claude/commands/validate-artifact.md`
**Locate:**
```
| Manual test plan | 4 scenario-specific dimensions — Scope coverage, Step reproducibility, Observable pass/fail, Setup completeness (see [`SHAMT_RULES.template.md`](../../../../templates/SHAMT_RULES.template.md#optional-post-build-artifact)) |
```
**Replace:**
```
| User test plan | 4 scenario-specific dimensions — Scope coverage, Step reproducibility, Observable pass/fail, Setup completeness (see [`SHAMT_RULES.template.md`](../../../../templates/SHAMT_RULES.template.md#test-plan-phase-4--required)) |
```
**Verification:** `grep -F '| Manual test plan |' host/templates/claude/commands/validate-artifact.md` returns 0. `grep -F '| User test plan |' host/templates/claude/commands/validate-artifact.md` returns 1.

> **CROSS-PHASE DEPENDENCY (anchor link).** The replacement above re-targets the inbound link from the retired SHAMT_RULES `#optional-post-build-artifact` anchor (which the SHAMT_RULES edit in **Phase 4 of this plan**, proposal row 31, removes — the manual-test-plan section becomes a **mandatory** Phase-4 Test-Plan section, no longer "optional/post-build"). The new anchor name is **decided in the SHAMT_RULES phase**. This step assumes that phase renames the heading to `### Test Plan (Phase 4 — required)` → anchor `#test-plan-phase-4--required`. **If Phase 4 produces a different heading/anchor for the merged mandatory test-plan section, the builder MUST set the link target here to match the actual SHAMT_RULES anchor.** Do not leave the link pointing at `#optional-post-build-artifact` (that anchor will not exist). The locate string for the current (old) link is the `#optional-post-build-artifact` fragment in this table row; the replacement fragment must equal the Phase-4 anchor. See Phase notes.

### Step 1.102b — EDIT validate-artifact.md Step-2 dimension table Spec rows (collapse Quick/Standard; context always produced)

**Operation:** EDIT
**File:** `host/templates/claude/commands/validate-artifact.md`
**Locate:**
```
| Spec (alone, Quick path) | 8 spec dimensions — see Pattern 1 in [`SHAMT_RULES.template.md`](../../../../templates/SHAMT_RULES.template.md) |
| Spec + context pair (Standard path) | 8 spec dimensions + 5 pair-consistency checks |
```
**Replace:**
```
| Spec + context pair | 8 spec dimensions + 5 pair-consistency checks (every spec is validated alongside its always-produced `context.md` — see Pattern 1 in [`SHAMT_RULES.template.md`](../../../../templates/SHAMT_RULES.template.md)) |
```
**Verification:** `grep -F '| Spec (alone, Quick path) |' host/templates/claude/commands/validate-artifact.md` returns 0. `grep -F '| Spec + context pair (Standard path) |' host/templates/claude/commands/validate-artifact.md` returns 0. `grep -F '| Spec + context pair |' host/templates/claude/commands/validate-artifact.md` returns 1.

### Step 1.103 — EDIT validate-artifact.md Step 6 exit-check (collapse Quick/Standard branches)

**Operation:** EDIT
**File:** `host/templates/claude/commands/validate-artifact.md`
**Locate:**
```
- `consecutive_clean = 0` → return to Step 1.
- `consecutive_clean = 1` on the **Quick path** with no risk trigger → skip to Step 8 (no sub-agent required).
- `consecutive_clean = 1` on the **Standard path** or **risk-triggered Quick** → continue to Step 7.
```
**Replace:**
```
- `consecutive_clean = 0` → return to Step 1.
- `consecutive_clean = 1` → continue to Step 7 (the adversarial sub-agent is always required).
```
**Verification:** `grep -F 'on the **Quick path** with no risk trigger' host/templates/claude/commands/validate-artifact.md` returns 0. `grep -F 'the adversarial sub-agent is always required' host/templates/claude/commands/validate-artifact.md` returns 1.

### Step 1.104 — EDIT validate-artifact.md Step 8 footer (remove Quick-path single-pass variant)

**Operation:** EDIT
**File:** `host/templates/claude/commands/validate-artifact.md`
**Locate:**
```
When the artifact exits cleanly (Quick: primary clean pass; Standard: primary clean + sub-agent CONFIRMED), append a single-line footer to the artifact. For spec/context pairs, append the footer to both files.

```text
---
Validated {YYYY-MM-DD} — N rounds, 1 adversarial sub-agent confirmed
```

On Quick-path single-pass exit, drop the "1 adversarial sub-agent confirmed" suffix:

```text
---
Validated {YYYY-MM-DD} — 1 round (Quick path)
```

The footer is the **only** persistent record of validation. Do not create separate `_VALIDATION_LOG.md` artifacts.
```
**Replace:**
```
When the artifact exits cleanly (primary clean round + sub-agent CONFIRMED), append a single-line footer to the artifact. For spec/context pairs, append the footer to both files.

```text
---
Validated {YYYY-MM-DD} — N rounds, 1 adversarial sub-agent confirmed
```

The footer is the **only** persistent record of validation. Do not create separate `_VALIDATION_LOG.md` artifacts.
```
**Verification:** `grep -F 'Validated {YYYY-MM-DD} — 1 round (Quick path)' host/templates/claude/commands/validate-artifact.md` returns 0. `grep -F 'On Quick-path single-pass exit' host/templates/claude/commands/validate-artifact.md` returns 0.

### Step 1.105 — EDIT validate-artifact.md Exit criteria (uniform)

**Operation:** EDIT
**File:** `host/templates/claude/commands/validate-artifact.md`
**Locate:**
```
- The relevant `consecutive_clean` threshold reached (Quick: 1 primary clean pass; Standard / risk-triggered: 1 primary clean + 1 sub-agent CONFIRMED).
- The validation footer appended.
```
**Replace:**
```
- `consecutive_clean = 1` (one primary clean round) + the adversarial sub-agent returned `CONFIRMED`.
- The validation footer appended.
```
**Verification:** `grep -F 'Quick: 1 primary clean pass' host/templates/claude/commands/validate-artifact.md` returns 0.

### Step 1.106 — EDIT validate-artifact.md Notes (manual-test-plan bullet → user; drop e5b inline-exit reference + Quick/Standard)

**Operation:** EDIT
**File:** `host/templates/claude/commands/validate-artifact.md`
**Locate:**
```
- This command is reused across the framework — Engineer flow phases (Spec, Plan, Testing Plan, Manual Test Plan, Review), and the framework-update flow (proposal validation). Keep its body story-agnostic — do not bake story-specific assumptions in.
- **Manual test plans** validate under this command's standard Pattern 1 exit — `/validate-artifact` is the source of truth for the validation exit. `/e5b-write-manual-testing-plan` runs the same 4-dimension loop inline (for Author / Patch / Re-validate mode cohesion) but defers to this exit; it does **not** use a bespoke "2 consecutive clean rounds" rule.
```
**Replace:**
```
- This command is reused across the framework — Engineer flow phases (Spec, Plan, Test Plan, Review), and the framework-update flow (proposal validation). Keep its body story-agnostic — do not bake story-specific assumptions in.
- **User test plans** validate under this command's uniform Pattern 1 exit — `/validate-artifact` is the source of truth for the validation exit. `/e4-write-test-plan` invokes this command on `user_test_plan.md` (the 4 scenario dimensions) and on `testing_plan.md` (the plan dimensions); both use this exit.
```
**Verification:** `grep -F '/e5b-write-manual-testing-plan' host/templates/claude/commands/validate-artifact.md` returns 0. `grep -F '**User test plans** validate under this command' host/templates/claude/commands/validate-artifact.md` returns 1.

### Step 1.107 — EDIT validate-artifact.md whole-file residual sweep (verification-only)

**Operation:** EDIT
**File:** `host/templates/claude/commands/validate-artifact.md`
**Locate:** (no edit — verification-only step)
**Replace:** (none)
**Verification (whole file, after Steps 1.98–1.106, including 1.102b):**
- `grep -nE 'Quick path|Quick-path|Standard path|Standard-path|risk-triggered Quick|one-LOW allowance.*Quick' host/templates/claude/commands/validate-artifact.md` returns 0 matches. (The Step-2 dimension-table Spec rows were collapsed to a single `Spec + context pair` row in Step 1.102b — without that step this sweep would still hit the `Spec (alone, Quick path)` / `Spec + context pair (Standard path)` rows.) (The standalone "no one-LOW allowance" sub-agent rule in Step 7 / the example invocation remains — it is the sub-agent exception, not a Quick/Standard selector; do not remove it.)
- `grep -F 'manual_test_plan' host/templates/claude/commands/validate-artifact.md` returns 0; `grep -iF 'manual test plan' host/templates/claude/commands/validate-artifact.md` returns 0.
- `grep -F '#optional-post-build-artifact' host/templates/claude/commands/validate-artifact.md` returns 0 (the only inbound link to that retired anchor is re-targeted in Step 1.102).


## Phase notes

**Scope split.** This file (Phase 1b) covers the **rename + driver** engineer-command work — rows 7–13: the five MOVE renames (`e4-execute-plan`→`e5-execute-plan`, `e5-execute-tests`→`e6-execute-tests`, `e6-review-changes`→`e7-review-changes`, `e7-resolve-feedback`→`e8-resolve-feedback`, `e8-finalize-story`→`e9-finalize-story`), plus `e-all.md` (row 12) and `validate-artifact.md` (row 13). The non-rename rows 1–6 live in **Phase 1a** (`_PLAN_phase_1a.md`), Steps 1.1–1.29. **Phase 1a must run first.**

**Ordering within this phase.** Run the steps in numeric order. Each rename's `git mv` sub-step A (1.30, 1.41, 1.53, 1.57, 1.61) must run **before** its body-edit steps (which target the *new* path). Recommended order: 1.30–1.40 (MOVE e4→e5) → 1.41–1.52 (MOVE e5→e6) → 1.53–1.56 (MOVE e6→e7) → 1.57–1.60 (MOVE e7→e8) → 1.61–1.68 (MOVE e8→e9) → 1.69–1.97 (e-all) → 1.98–1.107 (validate-artifact).

**Cross-phase dependency — SHAMT_RULES anchor (CRITICAL).** Step 1.102 (`validate-artifact.md` dimension table, the "User test plan" row) links to the SHAMT_RULES Test-Plan section anchor, assumed `#test-plan-phase-4--required`, produced by **Phase 4** (`templates/SHAMT_RULES.template.md`, proposal row 31). If Phase 4 lands different heading text, the builder MUST update the link fragment to match. Per proposal row 7, `e5-execute-plan.md` no longer links to that anchor at all (its e5b suggestion was deleted in Step 1.37), so `validate-artifact.md` is the **only** surviving inbound link — this resolves the proposal's two-inbound-link concern down to one. This anchor is **not** caught by the Quick/Standard or `manual_test_plan` greps (per the proposal's "Anchor-link validity (D4)" note), so it is tracked explicitly.

**#50-preservation (CRITICAL — re-verify after the MOVE steps).** Proposal #50 (commit `ca37b5e`) landed PR-centric Review/Polish/Finalize on the e6/e7/e8/e-all surface this phase renumbers. The MOVE steps for rows 9–11 (1.53–1.56 e7-review, 1.57–1.60 e8-resolve, 1.61–1.68 e9-finalize) and the e-all EDITs (1.69–1.97) **preserve every #50 behavior** — the deltas are renumber + Quick/Standard-removal + manual→user ONLY. Each MOVE's sub-step B carries an explicit #50-marker-survival grep (`pr_provider`, `## PR create`, `addressed_feedback`, `gh pr merge`, `iterative`, terminal-at-Review wording). The builder must run those greps and **halt** if any #50 marker count drops.

**Quick/Standard residual sweep (run after Phase 1a + this phase).** After all rows-1–13 steps, run:
`grep -rnE 'Quick path|Standard path|Quick-path|Standard-path|/e3b|e5b|manual_test_plan|## Post-Build Review' host/templates/claude/commands/e5-execute-plan.md host/templates/claude/commands/e6-execute-tests.md host/templates/claude/commands/e7-review-changes.md host/templates/claude/commands/e8-resolve-feedback.md host/templates/claude/commands/e9-finalize-story.md host/templates/claude/commands/e-all.md host/templates/claude/commands/validate-artifact.md`
Expected: **0 matches** (the `## Verification (Standard)/(Quick)` branch #50 added to the old e7-resolve-feedback is covered by Step 1.59d; the `## Post-Build Review` routing #50 added to e-all is covered by Step 1.75). Any hit is a missed renumber/removal — fix before advancing.

**Renamed-command outbound-pointer note.** This phase renumbers Engineer-command **bodies** only. Sibling skills, personas, templates, references, and root docs that reference these commands are renumbered in other plan phases (proposal rows 14–61). Cross-file pointer consistency (e.g. that no skill still points at `/e4-execute-plan`) is verified by the whole-plan post-execution sweep in the **index** file.

**Regen note.** No `.claude/` edits (canonical sources only). The command renames propagate via `/f4-regen-framework` (framework-update Phase 5) using the regen prune + deletion-propagation (#47) to remove the old `e3b`/`e5b`/`e4`–`e8` slash commands — out of scope for this plan phase.

---
Validated 2026-06-21 — 2 rounds, 1 adversarial sub-agent confirmed
