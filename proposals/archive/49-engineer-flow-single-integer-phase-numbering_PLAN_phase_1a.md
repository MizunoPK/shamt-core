# Implementation Plan — Phase 1a: Engineer command bodies (non-rename — rows 1–6)

**Proposal:** proposals/49-engineer-flow-single-integer-phase-numbering.md
**Plan index:** proposals/49-engineer-flow-single-integer-phase-numbering_PLAN.md
**Covers:** Proposed Changes rows 1–6 (host/templates/claude/commands/ — e1/e2/e3 EDITs, the new e4-write-test-plan CREATE, the e3b/e5b DELETEs)
**Created:** 2026-06-21

All paths below are relative to the repo root `/home/kai/code/shamt-core/`. Every EDIT/CREATE/DELETE targets a **canonical source** under `host/templates/claude/commands/` — never `.claude/`. (Step numbering is shared with Phase 1b — IDs `Step 1.1`–`Step 1.29` live here, plus the two sub-lettered inserts `Step 1.10a`/`Step 1.10b`; `Step 1.30`–`Step 1.107` live in Phase 1b. The two phase files together cover proposal rows 1–13.)

## Steps

### Step 1.1 — VERIFY e1-start-story.md frontmatter description (no edit needed)

**Operation:** NONE (verify-only — no `Edit` call)
**File:** `host/templates/claude/commands/e1-start-story.md`
**Confirm in place:** the frontmatter `description` already reads exactly:
```
description: Phase 1 (Intake) — resolve a slug, fetch the tracker payload (or fall through to freeform), and produce a validated ticket.md
```
Phase 1 keeps its number and its `/e2` next-phase pointer — no renumber, no text change. **Do not invoke `Edit` for this step** (an identical Locate/Replace would error); it is a confirmation that e1's frontmatter is already correct.
**Verification:** `grep -c 'Phase 1 (Intake)' host/templates/claude/commands/e1-start-story.md` returns 1. The only e1 residual risk is a stray Quick/Standard mention (Step 1.2).

### Step 1.2 — VERIFY e1-start-story.md is already Quick/Standard-clean (no edit needed)

**Operation:** NONE (verify-only — no `Edit` call)
**File:** `host/templates/claude/commands/e1-start-story.md`
**Confirm in place:** e1 carries **no** Quick/Standard path-setting text and **no** `Path:` selection line, so row 1's "remove any Quick/Standard path-setting" reduces to a confirm-zero sweep. **Do not invoke `Edit`** — there is nothing to replace.
**Verification:** `grep -nE 'Quick path|Standard path|Quick/Standard|Path: (Quick|Standard)' host/templates/claude/commands/e1-start-story.md` returns 0 matches. `grep -c '/e2-define-spec' host/templates/claude/commands/e1-start-story.md` returns 2 (next-phase pointers in Step 6 + Notes intact, both already `/e2`). No body edit performed — this step is a guard that e1 is already clean.

### Step 1.3 — EDIT e2-define-spec.md frontmatter description (drop the 7-step path framing wording is already number-clean; keep Phase 2 / Gate 2a / Gate 2b; no number change)

**Operation:** EDIT
**File:** `host/templates/claude/commands/e2-define-spec.md`
**Locate:**
```
description: Phase 2 (Spec) — run the 7-step Spec Protocol, dialog through design at Gate 2a, validate, and deliver an approved spec at Gate 2b
```
**Replace:**
```
description: Phase 2 (Spec) — run the Spec Protocol, dialog through design at Gate 2a, validate, and deliver an approved spec at Gate 2b (no path selection; context.md always produced)
```
**Verification:** `grep -F 'no path selection; context.md always produced' host/templates/claude/commands/e2-define-spec.md` returns 1.

### Step 1.4 — EDIT e2-define-spec.md remove the "## Path selection" section

**Operation:** EDIT
**File:** `host/templates/claude/commands/e2-define-spec.md`
**Locate:**
```
## Path selection

After ingesting the ticket, decide Quick vs Standard per the path-selection rules in [`SHAMT_RULES.template.md`](../../../../templates/SHAMT_RULES.template.md) (Engineer Flow — Path Selection). Apply Standard when any risk trigger fires (>10 steps, multiple deploy boundaries, new service / DB table / migration / backfill, auth or tenant boundary, public API or event contract change, material architecture boundary crossing, significant design ambiguity after research, or explicit user request). When uncertain, default to Standard.

State the chosen path and the reason in one line before drafting.

## The 7-step Spec Protocol
```
**Replace:**
```
## The Spec Protocol
```
**Verification:** `grep -c '## Path selection' host/templates/claude/commands/e2-define-spec.md` returns 0. `grep -F '## The Spec Protocol' host/templates/claude/commands/e2-define-spec.md` returns 1.

### Step 1.5 — EDIT e2-define-spec.md Step 2 record-findings (context.md always)

**Operation:** EDIT
**File:** `host/templates/claude/commands/e2-define-spec.md`
**Locate:**
```
4. Record:
   - **Standard path:** detailed findings in `stories/{slug}/context.md` (drafted from [`templates/context.template.md`](../../../../templates/context.template.md)).
   - **Quick path:** compact findings inline in `stories/{slug}/spec.md` under `## Evidence` (drafted from [`templates/spec.template.md`](../../../../templates/spec.template.md)).
5. If the change crosses a meaningful boundary (API, persistence, queue, file, service), record an ASCII current-state flow in `context.md` (Standard) or under `## Evidence` (Quick). If genuinely narrow in-process, record the N/A reason explicitly.
```
**Replace:**
```
4. Record detailed findings in `stories/{slug}/context.md` (drafted from [`templates/context.template.md`](../../../../templates/context.template.md)) — `context.md` is **always** produced.
5. If the change crosses a meaningful boundary (API, persistence, queue, file, service), record an ASCII current-state flow in `context.md`. If genuinely narrow in-process, record the N/A reason explicitly.
```
**Verification:** `grep -nE 'Quick path|Standard path' host/templates/claude/commands/e2-define-spec.md` no longer matches in the Step 2 region (lines around "Record"). `grep -F 'is **always** produced' host/templates/claude/commands/e2-define-spec.md` returns 1.

### Step 1.6 — EDIT e2-define-spec.md Step 3 draft-skeletons table (single uniform skeleton)

**Operation:** EDIT
**File:** `host/templates/claude/commands/e2-define-spec.md`
**Locate:**
```
| Path | Skeleton |
|------|----------|
| Standard | Create `stories/{slug}/spec.md` from [`templates/spec.template.md`](../../../../templates/spec.template.md) and `stories/{slug}/context.md` from [`templates/context.template.md`](../../../../templates/context.template.md). `spec.md` is the Gate 2b approval contract; `context.md` carries detailed rationale, evidence, current flow, standards notes, and code shapes. Approval-relevant persistence design and review-prevention requirements appear in `spec.md`, not only `context.md`. Key Design Decision IDs (`D1`, `D2`, …) appear in both. |
| Quick | Create `stories/{slug}/spec.md` only. Populate Evidence, compact Review Prevention Evidence, Code Shapes, Review Prevention Checklist, Build Checklist, and Verification inline. Do **not** create `context.md` or `implementation_plan.md` unless the story escalates. |

Optional Standard-path plan skeleton: after `spec.md` / `context.md`, create `implementation_plan.md` with only exploratory headers and `Blocked:` markers. Set Planning Status to "Blocked on spec (Gate 2a)". Do not fill locate strings until Gate 2a clears.
```
**Replace:**
```
Create `stories/{slug}/spec.md` from [`templates/spec.template.md`](../../../../templates/spec.template.md) and `stories/{slug}/context.md` from [`templates/context.template.md`](../../../../templates/context.template.md). `spec.md` is the Gate 2b approval contract; `context.md` carries detailed rationale, evidence, current flow, standards notes, and code shapes. Approval-relevant persistence design and review-prevention requirements appear in `spec.md`, not only `context.md`. Key Design Decision IDs (`D1`, `D2`, …) appear in both.

Optional plan skeleton: after `spec.md` / `context.md`, create `implementation_plan.md` with only exploratory headers and `Blocked:` markers. Set Planning Status to "Blocked on spec (Gate 2a)". Do not fill locate strings until Gate 2a clears.
```
**Verification:** `grep -nE '\| Quick \||\| Standard \|' host/templates/claude/commands/e2-define-spec.md` returns 0. `grep -F 'Optional plan skeleton:' host/templates/claude/commands/e2-define-spec.md` returns 1.

### Step 1.7 — EDIT e2-define-spec.md Step 4 Open-Questions artifact list (drop path branching)

**Operation:** EDIT
**File:** `host/templates/claude/commands/e2-define-spec.md`
**Locate:**
```
- Maintain an `## Open Questions` section in the active artifact (`spec.md` for Quick path; `spec.md` + `context.md` for Standard) as you draft.
```
**Replace:**
```
- Maintain an `## Open Questions` section in the active artifacts (`spec.md` + `context.md`) as you draft.
```
**Verification:** `grep -F 'for Quick path; ' host/templates/claude/commands/e2-define-spec.md` returns 0.

### Step 1.8 — EDIT e2-define-spec.md Step 5 flesh-out path bullets

**Operation:** EDIT
**File:** `host/templates/claude/commands/e2-define-spec.md`
**Locate:**
```
Record the agreed approach.

- **Standard path:** keep `spec.md` concise and approval-facing; `context.md` carries detailed rationale, evidence, current flow, standards notes, and code shapes.
- **Quick path:** keep all of that inline in `spec.md`.

Required elements:
```
**Replace:**
```
Record the agreed approach. Keep `spec.md` concise and approval-facing; `context.md` carries detailed rationale, evidence, current flow, standards notes, and code shapes.

Required elements:
```
**Verification:** `grep -nE 'Standard path:|Quick path:' host/templates/claude/commands/e2-define-spec.md` returns 0 in the Step 5 region.

### Step 1.9 — EDIT e2-define-spec.md Step 5 Test Strategy bullet (drop Quick inline-checklist clause; next plan is /e4)

**Operation:** EDIT
**File:** `host/templates/claude/commands/e2-define-spec.md`
**Locate:**
```
- **`Test Strategy`** (testing is a **required** phase — see [`reference/testing.md`](../../../../reference/testing.md)). Approval-relevant at Gate 2b. Describe how this story is verified in Phase 5: the agent-as-user scenarios always, and (when `TESTING_STANDARDS.md` declares automated suites) the automated test kinds in scope, existing test files relevant, new test files needed, and project conventions to follow. Quick path with ≤5 test steps and no new file may use the spec's inline `Quick path inline test checklist`; otherwise the full `testing_plan.md` is produced in Phase 3.
```
**Replace:**
```
- **`Test Strategy`** (testing is a **required** phase — see [`reference/testing.md`](../../../../reference/testing.md)). Approval-relevant at Gate 2b. Describe how this story is verified in Phase 6 (Test): the agent-as-user scenarios always, and (when `TESTING_STANDARDS.md` declares automated suites) the automated test kinds in scope, existing test files relevant, new test files needed, and project conventions to follow. The `user_test_plan.md` is always authored in Phase 4 (Test Plan); the automated `testing_plan.md` is added there when `TESTING_STANDARDS.md` declares suites.
```
**Verification:** `grep -F 'Quick path inline test checklist' host/templates/claude/commands/e2-define-spec.md` returns 0. `grep -F 'Phase 4 (Test Plan)' host/templates/claude/commands/e2-define-spec.md` returns 1.

### Step 1.10 — EDIT e2-define-spec.md Step 5 Files-Affected/Build-Checklist path note

**Operation:** EDIT
**File:** `host/templates/claude/commands/e2-define-spec.md`
**Locate:**
```
Standard path does **not** add a Files Affected inventory to the spec; file-level work belongs in the plan. Quick path uses the Review Prevention Checklist and Build Checklist for files, prevention gates, and sequential mechanical steps. If a parallel plan skeleton exists, resolve all `Blocked:` markers after Gate 2a clears.
```
**Replace:**
```
The spec does **not** add a Files Affected inventory; file-level work belongs in the plan (Phase 3). If a parallel plan skeleton exists, resolve all `Blocked:` markers after Gate 2a clears.
```
**Verification:** `grep -F 'Quick path uses the Review Prevention Checklist' host/templates/claude/commands/e2-define-spec.md` returns 0.

### Step 1.10a — EDIT e2-define-spec.md Step 5 Review-Prevention-Gates bullet (drop Standard/Quick evidence split + escalate-to-Standard)

**Operation:** EDIT
**File:** `host/templates/claude/commands/e2-define-spec.md`
**Locate:**
```
- **`Review Prevention Gates`** (after Requirements or Interfaces) — for each applicable surface (regulated/sensitive data; tenant; auth/route; DB; infra; frontend; testing; removed/weakened checks), state the approval-facing prevention requirement. Standard path stores detailed evidence in `context.md`; Quick path stores compact evidence inline. If a prevention surface is itself a risk trigger, **escalate to Standard path**.
```
**Replace:**
```
- **`Review Prevention Gates`** (after Requirements or Interfaces) — for each applicable surface (regulated/sensitive data; tenant; auth/route; DB; infra; frontend; testing; removed/weakened checks), state the approval-facing prevention requirement. Detailed evidence is stored in `context.md`.
```
**Verification:** `grep -F 'escalate to Standard path' host/templates/claude/commands/e2-define-spec.md` returns 0. `grep -F 'Quick path stores compact evidence' host/templates/claude/commands/e2-define-spec.md` returns 0. `grep -F 'Detailed evidence is stored in `context.md`.' host/templates/claude/commands/e2-define-spec.md` returns 1.

### Step 1.10b — EDIT e2-define-spec.md Step 5 Key-Design-Decisions bullet (drop "(Standard path)" parenthetical)

**Operation:** EDIT
**File:** `host/templates/claude/commands/e2-define-spec.md`
**Locate:**
```
- **`Key Design Decisions`** table — assign `D1`, `D2`, … IDs. Same IDs appear in both `spec.md` and `context.md` (Standard path) without contradiction.
```
**Replace:**
```
- **`Key Design Decisions`** table — assign `D1`, `D2`, … IDs. Same IDs appear in both `spec.md` and `context.md` without contradiction.
```
**Verification:** `grep -F '`context.md` (Standard path) without contradiction' host/templates/claude/commands/e2-define-spec.md` returns 0. `grep -F 'Same IDs appear in both `spec.md` and `context.md` without contradiction.' host/templates/claude/commands/e2-define-spec.md` returns 1.

### Step 1.11 — EDIT e2-define-spec.md Step 6 Validation (uniform exit)

**Operation:** EDIT
**File:** `host/templates/claude/commands/e2-define-spec.md`
**Locate:**
```
Invoke `/validate-artifact` against the active artifact(s):

- **Standard path:** validate the pair — `/validate-artifact stories/{slug}/spec.md + stories/{slug}/context.md`. Uses 8 spec dimensions + 5 pair-consistency checks. Exit: primary clean + 1 adversarial sub-agent. Footer both files.
- **Quick path:** validate `stories/{slug}/spec.md` alone. 8 spec dimensions. Exit: single primary clean pass, **unless** a risk trigger applies — then escalate to a sub-agent confirmation. Footer `spec.md`.

Each round, ask "What code should I have read that I haven't?" and read it.
```
**Replace:**
```
Invoke `/validate-artifact` against the active artifact pair — `/validate-artifact stories/{slug}/spec.md + stories/{slug}/context.md`. Uses 8 spec dimensions + 5 pair-consistency checks. Exit: primary clean + 1 adversarial sub-agent (uniform — no Quick/Standard rigor selector). Footer both files.

Each round, ask "What code should I have read that I haven't?" and read it.
```
**Verification:** `grep -nE 'Standard path:|Quick path:' host/templates/claude/commands/e2-define-spec.md` returns 0 in the Step 6 region. `grep -F 'no Quick/Standard rigor selector' host/templates/claude/commands/e2-define-spec.md` returns 1.

### Step 1.12 — EDIT e2-define-spec.md Step 7 approval next-phase line

**Operation:** EDIT
**File:** `host/templates/claude/commands/e2-define-spec.md`
**Locate:**
```
Present the validated `spec.md` as the approval artifact. On Standard path, link `context.md` as supporting detail. Highlight:
```
**Replace:**
```
Present the validated `spec.md` as the approval artifact; link `context.md` as supporting detail. Highlight:
```
**Verification:** `grep -F 'On Standard path, link' host/templates/claude/commands/e2-define-spec.md` returns 0.

### Step 1.13 — EDIT e2-define-spec.md Step 7 context-clear suggestion (single next phase)

**Operation:** EDIT
**File:** `host/templates/claude/commands/e2-define-spec.md`
**Locate:**
```
Wait for explicit user approval. Once approved, suggest a context-clear breakpoint: `/clear`, then `/e3-plan-implementation {slug}` (Standard path) or `/clear`, then build directly from the Build Checklist (Quick path).
```
**Replace:**
```
Wait for explicit user approval. Once approved, suggest a context-clear breakpoint: `/clear`, then `/e3-plan-implementation {slug}` (Phase 3 — Plan).
```
**Verification:** `grep -F 'build directly from the Build Checklist' host/templates/claude/commands/e2-define-spec.md` returns 0.

### Step 1.14 — EDIT e2-define-spec.md Exit criteria (context.md unconditional)

**Operation:** EDIT
**File:** `host/templates/claude/commands/e2-define-spec.md`
**Locate:**
```
- `stories/{slug}/spec.md` exists, fully populated, with the validation footer.
- On Standard path, `stories/{slug}/context.md` exists with the validation footer.
- Open Questions section is empty (or contains only explicitly deferred items with reasons).
```
**Replace:**
```
- `stories/{slug}/spec.md` exists, fully populated, with the validation footer.
- `stories/{slug}/context.md` exists with the validation footer.
- Open Questions section is empty (or contains only explicitly deferred items with reasons).
```
**Verification:** `grep -F 'On Standard path, `stories/{slug}/context.md`' host/templates/claude/commands/e2-define-spec.md` returns 0.

### Step 1.15 — EDIT e2-define-spec.md Notes (next-phase + Test Strategy lines)

**Operation:** EDIT
**File:** `host/templates/claude/commands/e2-define-spec.md`
**Locate:**
```
- Standard path next: `/e3-plan-implementation {slug}`. Quick path next: build from the spec's Build Checklist directly (no `/e3-plan-implementation` required).
```
**Replace:**
```
- Next phase: `/e3-plan-implementation {slug}` (Plan — mandatory for every story).
```
**Verification:** `grep -F 'Quick path next:' host/templates/claude/commands/e2-define-spec.md` returns 0. Final whole-file check: `grep -nE 'Quick path|Standard path' host/templates/claude/commands/e2-define-spec.md` returns 0 matches.

### Step 1.16 — EDIT e3-plan-implementation.md frontmatter description (mandatory plan; next → /e4)

**Operation:** EDIT
**File:** `host/templates/claude/commands/e3-plan-implementation.md`
**Locate:**
```
description: Phase 3 (Plan, Standard path) — turn an approved spec into a mechanical, validated implementation plan; chains to /e3b-write-testing-plan when TESTING_STANDARDS.md declares automated suites
```
**Replace:**
```
description: Phase 3 (Plan) — turn an approved spec into a mechanical, validated implementation plan; mandatory for every story; next phase is /e4-write-test-plan
```
**Verification:** `grep -F '/e3b-write-testing-plan' host/templates/claude/commands/e3-plan-implementation.md` returns 0 in the frontmatter (line 2). `grep -F 'mandatory for every story; next phase is /e4-write-test-plan' host/templates/claude/commands/e3-plan-implementation.md` returns 1.

### Step 1.17 — EDIT e3-plan-implementation.md Purpose (drop e3b auto-invoke)

**Operation:** EDIT
**File:** `host/templates/claude/commands/e3-plan-implementation.md`
**Locate:**
```
**Purpose:** Run the Pattern 5 Implementation Planning protocol on a story whose spec has been approved at Gate 2b. Produce a mechanical, validated `implementation_plan.md` ready for builder handoff. When `TESTING_STANDARDS.md` declares automated suites, this command also invokes `/e3b-write-testing-plan {slug}` as a sub-phase before exit.
```
**Replace:**
```
**Purpose:** Run the Pattern 5 Implementation Planning protocol on a story whose spec has been approved at Gate 2b. Produce a mechanical, validated `implementation_plan.md` ready for builder handoff. Plan is **mandatory for every story** — there is no path that skips it. Test-plan authoring (the agent-as-user `user_test_plan.md` always, plus `testing_plan.md` when `TESTING_STANDARDS.md` declares automated suites) is the next phase, `/e4-write-test-plan {slug}`.
```
**Verification:** `grep -F 'invokes `/e3b-write-testing-plan {slug}` as a sub-phase' host/templates/claude/commands/e3-plan-implementation.md` returns 0. `grep -F 'mandatory for every story' host/templates/claude/commands/e3-plan-implementation.md` returns ≥1.

### Step 1.18 — EDIT e3-plan-implementation.md remove the "## Path applicability" section

**Operation:** EDIT
**File:** `host/templates/claude/commands/e3-plan-implementation.md`
**Locate:**
```
## Path applicability

**Standard path only.** Quick-path stories skip Phase 3 entirely — the spec's `Build Checklist` is the executable artifact. If the active spec declares `Path: Quick path`, report:

```text
Quick path is active for {slug}; skipping separate implementation plan.
Execute the spec's Build Checklist directly. Escalate to a full plan if the
checklist exceeds 10 steps, you need a builder sub-agent, exact locate/replace
detail is required, verification is complex, or the user asks for Gate 3.
```

…then exit without writing `implementation_plan.md`.

If the user explicitly requests Gate 3 planning on a Quick story, escalate to Standard for this command's run and continue with the steps below.

## Prerequisites
```
**Replace:**
```
## Prerequisites
```
**Verification:** `grep -c '## Path applicability' host/templates/claude/commands/e3-plan-implementation.md` returns 0. `grep -F 'Quick path is active for {slug}' host/templates/claude/commands/e3-plan-implementation.md` returns 0.

### Step 1.19 — EDIT e3-plan-implementation.md Prerequisites (drop Standard-only context clause)

**Operation:** EDIT
**File:** `host/templates/claude/commands/e3-plan-implementation.md`
**Locate:**
```
- On Standard path, `context.md` (or the active baseline) exists with a validation footer.
```
**Replace:**
```
- `context.md` (or the active baseline) exists with a validation footer.
```
**Verification:** `grep -F 'On Standard path, `context.md`' host/templates/claude/commands/e3-plan-implementation.md` returns 0.

### Step 1.20 — EDIT e3-plan-implementation.md Step 1 EDIT-lookup clause (drop Quick-to-Standard escalation note)

**Operation:** EDIT
**File:** `host/templates/claude/commands/e3-plan-implementation.md`
**Locate:**
```
4. For EDIT steps, look up only the 5–10 lines around each target symbol; reuse code shapes recorded in `context.md` (or in Quick-path `spec.md` if this is a Quick-to-Standard escalation).
```
**Replace:**
```
4. For EDIT steps, look up only the 5–10 lines around each target symbol; reuse code shapes recorded in `context.md`.
```
**Verification:** `grep -F 'Quick-to-Standard escalation' host/templates/claude/commands/e3-plan-implementation.md` returns 0.

### Step 1.21 — EDIT e3-plan-implementation.md Step 3 validation (drop Quick-path-validation aside)

**Operation:** EDIT
**File:** `host/templates/claude/commands/e3-plan-implementation.md`
**Locate:**
```
Invoke `/validate-artifact stories/{slug}/implementation_plan.md`. Uses the 8 plan dimensions. Exit: primary clean + 1 adversarial sub-agent (Standard path is the default for plan validation; the plan never runs Quick-path validation). Footer the plan.
```
**Replace:**
```
Invoke `/validate-artifact stories/{slug}/implementation_plan.md`. Uses the 8 plan dimensions. Exit: primary clean + 1 adversarial sub-agent (uniform validation — primary clean + adversarial sub-agent, always). Footer the plan.
```
**Verification:** `grep -F 'never runs Quick-path validation' host/templates/claude/commands/e3-plan-implementation.md` returns 0.

### Step 1.22 — EDIT e3-plan-implementation.md replace Step 4 (e3b auto-invoke → cross-reference to /e4)

**Operation:** EDIT
**File:** `host/templates/claude/commands/e3-plan-implementation.md`
**Locate:**
```
### Step 4 — Write the testing plan (when automated suites present)

Read `TESTING_STANDARDS.md`'s Automated section. If it declares suites present, invoke `/e3b-write-testing-plan {slug}` as a sub-phase. It produces `stories/{slug}/testing_plan.md` (or escalates the Quick-path inline checklist when scope is small) and runs its own validation loop before returning. Do not advance to Gate 3 until the testing plan is validated.

If `TESTING_STANDARDS.md` declares no automated suites, skip this step. `/e3b-write-testing-plan` would be a no-op anyway, but skipping the invocation keeps the chat output clean.

### Step 5 — Gate 3 (user approval)
```
**Replace:**
```
### Step 4 — Gate 3 (user approval)
```
**Verification:** `grep -F '### Step 4 — Write the testing plan' host/templates/claude/commands/e3-plan-implementation.md` returns 0. `grep -F '/e3b-write-testing-plan' host/templates/claude/commands/e3-plan-implementation.md` returns 0 (whole file). `grep -F '### Step 4 — Gate 3 (user approval)' host/templates/claude/commands/e3-plan-implementation.md` returns 1.

### Step 1.23 — EDIT e3-plan-implementation.md "The 5-step process" heading → "The 4-step process"

**Operation:** EDIT
**File:** `host/templates/claude/commands/e3-plan-implementation.md`
**Locate:**
```
## The 5-step process
```
**Replace:**
```
## The 4-step process
```
**Verification:** `grep -F '## The 4-step process' host/templates/claude/commands/e3-plan-implementation.md` returns 1. `grep -F '## The 5-step process' host/templates/claude/commands/e3-plan-implementation.md` returns 0.

### Step 1.24 — EDIT e3-plan-implementation.md Gate-3 next-phase pointer (→ /e4-write-test-plan)

**Operation:** EDIT
**File:** `host/templates/claude/commands/e3-plan-implementation.md`
**Locate:**
```
On approval, suggest a context-clear breakpoint: `/clear`, then `/e4-execute-plan {slug}` (Phase 4, Build). Builder handoff is **unconditional** after Gate 3 — the architect plans, the cheap-tier builder executes.
```
**Replace:**
```
On approval, suggest a context-clear breakpoint: `/clear`, then `/e4-write-test-plan {slug}` (Phase 4 — Test Plan). Build (Phase 5) follows the test plan: the architect plans, the cheap-tier builder executes after the test plan is authored.
```
**Verification:** `grep -F '`/e4-execute-plan {slug}` (Phase 4, Build)' host/templates/claude/commands/e3-plan-implementation.md` returns 0. `grep -F '`/e4-write-test-plan {slug}` (Phase 4 — Test Plan)' host/templates/claude/commands/e3-plan-implementation.md` returns 1.

### Step 1.25 — EDIT e3-plan-implementation.md Exit criteria (drop e3b/inline-checklist clause)

**Operation:** EDIT
**File:** `host/templates/claude/commands/e3-plan-implementation.md`
**Locate:**
```
- `stories/{slug}/implementation_plan.md` exists, fully populated, with the validation footer.
- When `TESTING_STANDARDS.md` declares automated suites, `stories/{slug}/testing_plan.md` (or the spec's inline checklist on Quick escalations) exists with its validation footer.
- Open Questions in the plan is empty (or contains only explicitly deferred items with reasons).
```
**Replace:**
```
- `stories/{slug}/implementation_plan.md` exists, fully populated, with the validation footer.
- Open Questions in the plan is empty (or contains only explicitly deferred items with reasons).
```
**Verification:** `grep -F 'on Quick escalations' host/templates/claude/commands/e3-plan-implementation.md` returns 0.

### Step 1.26 — EDIT e3-plan-implementation.md Notes (drop Quick-path validation note)

**Operation:** EDIT
**File:** `host/templates/claude/commands/e3-plan-implementation.md`
**Locate:**
```
- Plans never run Quick-path validation — the 1-LOW-allowance grace + sub-agent confirmation pattern applies because the plan determines mechanical execution.
```
**Replace:**
```
- Plan validation is uniform — primary clean + adversarial sub-agent, always (no Quick/Standard rigor selector), because the plan determines mechanical execution.
```
**Verification:** `grep -F 'Plans never run Quick-path validation' host/templates/claude/commands/e3-plan-implementation.md` returns 0. Final whole-file check: `grep -nE 'Quick path|Standard path|Quick-path|Standard-path|/e3b' host/templates/claude/commands/e3-plan-implementation.md` returns 0 matches.

### Step 1.27 — CREATE e4-write-test-plan.md (NEW merged Test Plan command, row 4)

**Operation:** CREATE
**File:** `host/templates/claude/commands/e4-write-test-plan.md`
**Mirrors:** structural shape of the sibling command files (frontmatter `description` + `# /eX` + `**Purpose:**` + `**Recommended models:**` + `## Usage` + `## Arguments` + `## Prerequisites` + `## Step-by-step` + `## Exit criteria` + `## Notes` + Managed-by-Shamt footer). Folds in the surviving logic of `e3b-write-testing-plan.md` (the automated `testing_plan.md` branch — Test Strategy read, per-step requirements, `testing_plan.md` template sections, validation) **and** `e5b-write-manual-testing-plan.md` (the agent-as-user scenario branch — `user_test_plan.md` authoring from the renamed `user_test_plan.template.md`, scenario structure, the 4 dimensions, open-questions dialog). Drops both deleted commands' Quick/Standard branches, the inline-checklist escalation table, and the "manual/human walkthrough" framing (the agent now executes the plan in Phase 6).

**Full initial content block:**

````markdown
---
description: Phase 4 (Test Plan, mandatory) — author the agent-as-user user_test_plan.md (always) and the automated testing_plan.md (when TESTING_STANDARDS.md declares suites); run the open-questions dialog + validation on each; next phase is /e5-execute-plan
---

# /e4-write-test-plan

**Purpose:** Run the **mandatory** Phase 4 (Test Plan) of the Engineer flow. Author the **agent-as-user** test plan `stories/{slug}/user_test_plan.md` (always — the `user-simulator` executes it in Phase 6) and, when `.shamt-core/project-specific-files/TESTING_STANDARDS.md` declares automated suites, the automated `stories/{slug}/testing_plan.md` (the `test-executor` runs it in Phase 6). Each artifact runs the open-questions iterative dialog and a validation loop before exit. The `user_test_plan.md` is always produced, so **this stage always runs**; the automated `testing_plan.md` is the one sub-part gated on a test framework being declared.

**Recommended models:**

- Authoring (both plans) + the `user_test_plan.md` inline validation-loop primary: Balanced (Sonnet) — structural scenario / step decomposition, per [`reference/model_selection.md`](../../../../reference/model_selection.md).
- `testing_plan.md` validation loop primary: Reasoning (Opus). Sub-agent: Cheap (Haiku) via `validation-checker`.

See [`reference/model_selection.md`](../../../../reference/model_selection.md).

---

## Usage

```
/e4-write-test-plan {slug}
```

## Arguments

- `{id-or-slug}` (required) — story ticket ID (`T{N}`) or slug. Resolved via the global story-folder rules (ID glob `stories/{ID}-*/`, else the both-positions slug glob; halt on multiple or zero matches per the Global Story Invariants in [`SHAMT_RULES.template.md`](../../../../templates/SHAMT_RULES.template.md#global-story-invariants)).

## Prerequisites

- Resolve the story folder per `templates/SHAMT_RULES.template.md` §PO-tree resolution (tree-wide glob + legacy-flat fallback); `stories/{slug}/` below denotes that resolved folder. Apply the active-artifact pointer if `stories/{slug}/active_artifacts.md` exists.
- The active spec exists with a validation footer and is approved at Gate 2b. The spec must include a `## Test Strategy` section per [`SHAMT_RULES.template.md`](../../../../templates/SHAMT_RULES.template.md#testing-phase-6--required).
- The active `implementation_plan.md` exists with a validation footer and is approved at Gate 3 (Plan is mandatory — Phase 3 ran).
- `.shamt-core/project-specific-files/TESTING_STANDARDS.md` exists and is validated. Read its **Automated test infrastructure** section to learn whether automated suites are declared.
- If `.shamt-core/project-specific-files/ARCHITECTURE.md` and `.shamt-core/project-specific-files/CODING_STANDARDS.md` exist, read them for test runner / file naming / fixture / assertion / UI / infra / multi-user conventions both plans must respect.

## Slug-resumable mode

After applying the active-artifact pointer, decide per artifact whether to **author** or **patch**:

| Existing state | Mode | Action |
|----------------|------|--------|
| Plan absent | **Author** | Draft from scratch using the template. Run the full validation loop. |
| Plan exists with a validation footer, no further direction | **Re-validate** | Re-run the validation loop; refresh the footer. |
| Plan exists with a validation footer, user asked to patch | **Patch** | Update the named sections; re-run the validation loop on the changed artifact; re-stamp the footer. |
| Plan exists **without** a validation footer (interrupted prior pass) | **Author-continue** | Resolve any `## Open Questions` first, then re-run the validation loop in full. |

State the chosen mode per artifact in one line before drafting.

## Step-by-step

### Step 1 — Read the spec's Test Strategy and the plan

1. Read `## Test Strategy` from the active spec. Extract: agent-as-user scenarios in scope; automated test kinds (e2e / integration / unit); existing test files relevant; new test files needed; project conventions (runner, naming, fixtures, assertions).
2. Read the active `implementation_plan.md` — file manifest, `## Verification`, Review Prevention Gate Mapping. These show *what will be built*; both plans exercise that surface.
3. Cross-reference `.shamt-core/project-specific-files/ARCHITECTURE.md` and `.shamt-core/project-specific-files/CODING_STANDARDS.md` for test / UI / infra / multi-user rules.

### Step 2 — Author `user_test_plan.md` (always)

Write `stories/{slug}/user_test_plan.md` from [`templates/user_test_plan.template.md`](../../../../templates/user_test_plan.template.md). This is the **agent-as-user execution script** the `user-simulator` runs in Phase 6 — not a human walkthrough. Required sections:

- Header metadata (`Created`, `Story`, `Spec`, `Implementation Plan`, `Testing Plan`, `Baseline`).
- `## Open Questions` — populated and resolved one-at-a-time per the open-questions iterative dialog.
- `## Setup` — environment state, test data, accounts, feature flags, external service state, tooling. Everything the agent-as-user needs before scenario 1, step 1.
- `## Scenarios` — numbered. Each scenario: **Name**, **Starting state**, **Steps** (numbered, imperative, specific — runnable by the agent driving the project as a user), **Expected outcome** (concrete and observable — name the output value / response / log line / error message), **Pass/fail criterion** (binary check; not "looks right").
- `## Teardown` — how to clean up. `N/A — no shared state changed.` is acceptable when true.
- `## Coverage Note` — one paragraph: what automated tests cover vs. what these agent-as-user scenarios cover. When `testing_plan.md` does not exist for this story, say so and describe the rationale for agent-as-user-only coverage.

The per-run execution log is **not** kept here — the `user-simulator` writes it to `agent_test_session.md` in Phase 6. This plan is the script, not the results log.

**Open-questions iterative dialog (Principle 2 in [`SHAMT_RULES.template.md`](../../../../templates/SHAMT_RULES.template.md#principle-2-open-questions-iterative-dialog))** is mandatory: maintain the `## Open Questions` section as you draft, surface each question to the user **one at a time** via `AskUserQuestion`, update the artifact with each answer before the next, code-research every question first.

### Step 3 — Validate `user_test_plan.md` (4 dimensions)

Invoke `/validate-artifact stories/{slug}/user_test_plan.md`. The 4 scenario-specific dimensions are:

1. **Scope coverage** — every risk area named in the spec's `Scope` / Requirements / Review Prevention Gates has at least one scenario that exercises it. A gap is **HIGH**.
2. **Step reproducibility** — each step is unambiguous enough that the agent-as-user can execute it without asking a question. Vague steps are **MEDIUM**.
3. **Observable pass/fail** — every scenario's pass/fail criterion is a binary check (specific output value, response, log line, error message). "Looks right" / "works correctly" is **HIGH**.
4. **Setup completeness** — `## Setup` provides enough detail to reach scenario 1's starting state without external help. Missing credentials or undocumented data dependencies are **HIGH**.

Exit: primary clean + 1 adversarial sub-agent (uniform — no Quick/Standard rigor selector). Footer the plan.

### Step 4 — Author `testing_plan.md` (when automated suites present)

Read `TESTING_STANDARDS.md`'s **Automated test infrastructure** section. **If it declares None,** print one line — `TESTING_STANDARDS.md declares no automated suites — no testing_plan.md needed (Phase 6 runs the agent-as-user execution of user_test_plan.md).` — and skip to Step 6. Do not create `testing_plan.md`.

When suites are declared, write `stories/{slug}/testing_plan.md` from [`templates/testing_plan.template.md`](../../../../templates/testing_plan.template.md). Required sections:

- Header metadata (`Created`, `Story`, `Spec`, `Implementation Plan`, `Baseline`).
- `## Test Strategy` (mirror the spec, expanded with runner, file conventions, and project assumptions).
- `## Test Plan Steps` — each step is one runnable test or test group, with **exact invocation** and **binary pass criterion**, in execution order.
- `## Shared Setup / Teardown` — required if any step assumes pre-existing state; otherwise `N/A — each step is self-contained.`.
- `## Results Log` — table with PENDING / PASS / FAIL / BLOCKED status; populated by the `test-executor` during Phase 6.
- `## Failure Diagnosis` — empty until failures occur.
- `## Open Questions` — only unresolved test-design questions.
- `## Validation` — note that Pattern 1 will validate this plan.

**Per-step requirements:** **Type** (unit / integration / e2e); **File** (workspace-relative test path); **Invocation** (exact command, e.g. `pytest tests/foo_test.py::test_bar`); **Pass criterion** (what output proves pass — exit code, output line, assertion count); **Covers** (the spec requirement IDs or implementation-plan step numbers this verifies, OR an explicit `Not testable here — covered by user_test_plan.md` reason).

**Open-questions iterative dialog** is mandatory here too: maintain `## Open Questions`, surface one at a time via `AskUserQuestion`, update before moving on, code-research first.

### Step 5 — Validate `testing_plan.md`

Invoke `/validate-artifact stories/{slug}/testing_plan.md`. Dimensions mirror the implementation-plan dimensions but emphasize **Step clarity** (unambiguous invocation + binary pass criterion), **Executability** (commands resolve in the test environment; pre-existing state documented under Shared Setup), and **Verification completeness** (every spec requirement and every approval-relevant plan step maps to a test step, or an explicit `Not testable here — covered by user_test_plan.md` reason). Exit: primary clean + 1 adversarial sub-agent (uniform). Footer the plan.

### Step 6 — Exit

Report which artifacts were produced (`user_test_plan.md` always; `testing_plan.md` when suites are declared) and the final-round dimension counts. Link the validated files. Suggest a context-clear breakpoint: `/clear`, then `/e5-execute-plan {slug}` (Phase 5 — Build).

## Exit criteria

- `stories/{slug}/user_test_plan.md` exists, fully populated, with the validation footer.
- When `TESTING_STANDARDS.md` declares automated suites, `stories/{slug}/testing_plan.md` exists, fully populated, with its validation footer.
- `## Open Questions` in each produced artifact is empty (or contains only explicitly deferred items with reasons).

## Notes

- **Mandatory stage.** The `user_test_plan.md` is always authored, so Phase 4 always runs. The automated `testing_plan.md` is the one genuine conditional — physically impossible without a declared test framework.
- **The agent executes the user plan.** `user_test_plan.md` is the `user-simulator`'s execution script in Phase 6 (Test) — it is not a human walkthrough. Write each scenario so an agent driving the project as a user can run it step by step.
- This command is **fresh-agent runnable**: input lives on disk (config, spec, plan, governing docs). State is determined by artifact presence + footer presence.
- The per-run execution log lives in `agent_test_session.md` (written in Phase 6), never duplicated into `user_test_plan.md`.
- Phase 6 (Test) executes both plans — see [`SHAMT_RULES.template.md`](../../../../templates/SHAMT_RULES.template.md#testing-phase-6--required) and Part 3's Engineer Flow phase narratives. Phase 6 **blocks until green**.

---

<!-- Managed by Shamt — do not edit. Regenerate from shamt-core/host/templates/claude/commands/e4-write-test-plan.md. -->
````

**Verification:** `test -f host/templates/claude/commands/e4-write-test-plan.md`. `grep -F '# /e4-write-test-plan' host/templates/claude/commands/e4-write-test-plan.md` returns 1. `grep -F 'user_test_plan.md' host/templates/claude/commands/e4-write-test-plan.md` returns ≥4. `grep -F 'testing_plan.md' host/templates/claude/commands/e4-write-test-plan.md` returns ≥4. `grep -F '/e5-execute-plan {slug}' host/templates/claude/commands/e4-write-test-plan.md` returns 1. `grep -F 'Managed by Shamt' host/templates/claude/commands/e4-write-test-plan.md` returns 1. `grep -nE 'Quick path|Standard path|manual_test_plan' host/templates/claude/commands/e4-write-test-plan.md` returns 0 matches. (The phrase "not a human walkthrough" legitimately appears in the prose — it correctly states the plan is agent-executed, not human-run — so it is intentionally not a forbidden term; the old-framing guard is `manual_test_plan`.)

> Note (cross-phase): the SHAMT_RULES anchor referenced above (`#testing-phase-6--required`) must match the renumbered Testing-phase heading produced in the SHAMT_RULES edit (Phase 4 of this plan, proposal row 31). If Phase 4 keeps the heading as "Testing (Phase 5 — required)" anchored `#testing-phase-5--required`, the builder must instead use that anchor here. The current file anchors as `#testing-phase-5--required`; Phase 4 renumbers Testing to Phase 6, so `#testing-phase-6--required` is the expected new anchor. **Cross-phase dependency — see Phase notes.**

### Step 1.28 — DELETE e3b-write-testing-plan.md (row 5)

**Operation:** DELETE
**File:** `host/templates/claude/commands/e3b-write-testing-plan.md`
**Command:** `git rm host/templates/claude/commands/e3b-write-testing-plan.md`
**Justification:** The automated-plan authoring logic is folded into the new `/e4-write-test-plan` (Step 1.27). The `{n}b` suffixed command is retired.
**Verification:** `test ! -f host/templates/claude/commands/e3b-write-testing-plan.md`.

### Step 1.29 — DELETE e5b-write-manual-testing-plan.md (row 6)

**Operation:** DELETE
**File:** `host/templates/claude/commands/e5b-write-manual-testing-plan.md`
**Command:** `git rm host/templates/claude/commands/e5b-write-manual-testing-plan.md`
**Justification:** The agent-as-user scenario-plan authoring is folded into the new `/e4-write-test-plan` (Step 1.27); execution moves to Phase 6 (renamed artifact `user_test_plan.md`). The `{n}b` suffixed command is retired.
**Verification:** `test ! -f host/templates/claude/commands/e5b-write-manual-testing-plan.md`.


## Phase notes

**Scope split.** This file (Phase 1a) covers the **non-rename** engineer-command work — rows 1–6: EDITs to `e1-start-story.md` / `e2-define-spec.md` / `e3-plan-implementation.md`, the CREATE of the new merged `e4-write-test-plan.md`, and the DELETEs of `e3b-write-testing-plan.md` + `e5b-write-manual-testing-plan.md`. The five MOVE renames (rows 7–11) plus `e-all.md` (row 12) and `validate-artifact.md` (row 13) live in **Phase 1b** (`_PLAN_phase_1b.md`), Steps 1.30–1.107.

**Ordering within this phase.** Run Steps 1.1–1.26 in order — including the two sub-lettered inserts 1.10a/1.10b (e2 Review-Prevention-Gates + Key-Design-Decisions Quick/Standard cleanups) — then 1.27 (CREATE e4-write-test-plan) → 1.28–1.29 (DELETE e3b/e5b). Steps 1.1 and 1.2 are **verify-only** (no `Edit` call — e1 is already number-clean and Quick/Standard-free); every other 1.x step is a real EDIT/CREATE/DELETE. Phase 1a must run **before** Phase 1b (Phase 1b's renamed-command cross-references assume the new `/e4-write-test-plan` exists).

**Cross-phase dependency — SHAMT_RULES anchor (CRITICAL).** Step 1.27 (the new `e4-write-test-plan.md`) links to the SHAMT_RULES Testing/Phase-6 heading anchor, assumed `#testing-phase-6--required`. That anchor is produced by **Phase 4** of this plan (`templates/SHAMT_RULES.template.md`, proposal row 31). If Phase 4 lands different heading text, the builder MUST update the link fragment to match Phase 4's actual anchor. This anchor is **not** caught by the Quick/Standard or `manual_test_plan` greps (per the proposal's "Anchor-link validity (D4)" note), so it is tracked explicitly.

**Quick/Standard residual sweep (run after this phase + Phase 1b).** After all rows-1–13 steps, run:
`grep -rnE 'Quick path|Standard path|Quick-path|Standard-path|/e3b|e5b|manual_test_plan|## Post-Build Review' host/templates/claude/commands/e1-start-story.md host/templates/claude/commands/e2-define-spec.md host/templates/claude/commands/e3-plan-implementation.md host/templates/claude/commands/e4-write-test-plan.md` — Expected: **0 matches** for these four files.

**Regen note.** No `.claude/` edits (canonical sources only). The new/deleted commands propagate via `/f4-regen-framework` (framework-update Phase 5) using the regen prune + deletion-propagation (#47) — out of scope for this plan phase.

---
Validated 2026-06-21 — 2 rounds, 1 adversarial sub-agent confirmed
