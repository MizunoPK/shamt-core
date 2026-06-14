# Implementation Plan — Phase 4a: Test-execution + bug-loop logic

**Proposal:** `proposals/21-formalize-testing-standards-and-stages.md`
**Index:** `proposals/21-formalize-testing-standards-and-stages_PLAN.md`
**Phase:** 4a of 5 — the **substantive** half of Phase 4: rewire `/e5` (required; orchestrate
`user-simulator` + automated), `/e3b` (key off `TESTING_STANDARDS.md`), `/e7` (required phase-attributed
root-cause for test bugs), and `test-executor` (automated-only). Phase **4b** does the rote flag-reference
cleanup (e2/e3/e4/e6/e8 + test templates).
**Depends on:** Phase 1 (`user-simulator` persona) + Phase 3 (the rules contract: required Phase 5).
**Executor:** `plan-executor` (Cheap). Each command edit is paired with its skill edit (D2).

## Files manifest

| File | Op |
|---|---|
| `host/templates/claude/commands/e5-execute-tests.md` + `skills/e5-execute-tests/SKILL.md` | EDIT |
| `host/templates/claude/commands/e3b-write-testing-plan.md` + `skills/e3b-write-testing-plan/SKILL.md` | EDIT |
| `host/templates/claude/commands/e7-resolve-feedback.md` + `skills/e7-resolve-feedback/SKILL.md` | EDIT |
| `host/templates/claude/agents/test-executor.md` | EDIT |

---

## Step 1 — `e5-execute-tests.md`: remove the no-op gate (testing is required)

**Operation:** EDIT. Locate (verbatim — the entire `## No-op gate` section, line 30 through line 40):
```
## No-op gate

Read `.shamt-core/shamt-config.json` → `testing`.

- `"disabled"` → print one line and exit. Do not touch any file, do not invoke the test-executor.
  ```
  Testing is disabled in .shamt-core/shamt-config.json — Phase 5 is not part of this project's flow. Run /e6-review-changes {slug} next.
  ```
- `"enabled"` → continue.

Per [`SHAMT_RULES.template.md`](../../../../templates/SHAMT_RULES.template.md#when-automated-testing-is-enabled), this command is safe to invoke unconditionally — the no-op keeps automation simple.
```
Replace with:
```
## Required phase

Phase 5 runs on **every** story (per `templates/SHAMT_RULES.template.md` §Testing and
[`reference/testing.md`](../../../../reference/testing.md)) — there is no `testing` config flag and no
no-op. It always runs the **agent-as-user execution** (Step 2) and, when
`.shamt-core/project-specific-files/TESTING_STANDARDS.md` declares **automated suites present**, the
**automated** execution (Step 3). It **blocks until green**.
```

## Step 2 — `e5-execute-tests.md`: description + purpose

2a — Locate the frontmatter `description:` line and replace:
```
description: Phase 5 (Test) — execute the validated testing_plan.md (or the spec's inline checklist) via the test-executor persona; blocks until every step passes; no-op when testing is disabled
```
with:
```
description: Phase 5 (Test, required) — drive the project as a user via the user-simulator persona (always) plus the automated testing_plan.md via test-executor (when TESTING_STANDARDS.md declares suites); a failure routes to /e7 with a required root-cause section; blocks until green
```
2b — Locate (verbatim — the `**Purpose:**` paragraph on line 7, the blank line, and the
"When `testing: "disabled"`…" line on line 9):
```
**Purpose:** Run Phase 5 of the Engineer flow when `.shamt-core/shamt-config.json` sets `testing: "enabled"`. Hand off the validated testing plan to the `test-executor` persona, watch for failures, route Story-bug / Test-bug / Spec-gap diagnoses appropriately, and **block until every step in the plan reports `PASS`**.

When `testing: "disabled"`, this command is a no-op with a single-line message — see the no-op gate below.
```
Replace with:
```
**Purpose:** Run the **required** Phase 5 (Test). Always perform the **agent-as-user execution** — hand off to the `user-simulator` persona, which drives the project as a user per `TESTING_STANDARDS.md` and writes `agent_test_session.md`. When `TESTING_STANDARDS.md` declares automated suites, also run them via the `test-executor` persona. **Block until every scenario / step reports `PASS`.** A failure is a post-implementation bug → route to `/e7-resolve-feedback` (see Step 3).
```

## Step 3 — `e5-execute-tests.md`: orchestration steps

3a-i — Retitle the Prerequisites heading. Locate (verbatim, line 42):
```
## Prerequisites (testing enabled)
```
Replace with:
```
## Prerequisites
```

3a-ii — Make the automated-artifact bullet conditional on declared suites (the agent-as-user run needs
only a completed `TESTING_STANDARDS.md`). Locate (verbatim, line 47):
```
- One of the following is true (per the path):
```
Replace with:
```
- `.shamt-core/project-specific-files/TESTING_STANDARDS.md` exists and is validated (the agent-as-user run reads it; if all-placeholder, halt and direct the user to complete it via the init completion prompt).
- **When `TESTING_STANDARDS.md` declares automated suites,** one of the following is true (per the path):
```

3b — Insert a new **Step 0 — Agent-as-user execution (always)** immediately before the existing
`### Step 1 — Resolve the active testing artifact`. Locate:
```
## Step-by-step

### Step 1 — Resolve the active testing artifact
```
Replace with:
```
## Step-by-step

### Step 0 — Agent-as-user execution (always)

Hand off to the `user-simulator` persona (see [`agents/user-simulator.md`](../agents/user-simulator.md)).
Provide `slug` and `testing_standards_path = .shamt-core/project-specific-files/TESTING_STANDARDS.md`. It
drives the project as a user, writes `stories/{slug}/agent_test_session.md`, and reports
`Session PASS` / `Session BLOCKED: …`. On `BLOCKED`, route the failing scenario(s) per Step 3 (bug →
`/e7`). If `TESTING_STANDARDS.md` declares **no automated suites**, Step 0 is the whole required pass —
on `Session PASS`, skip to Step 4.

### Step 1 — Resolve the active testing artifact (automated suites only)
```

3c — Add the agent-as-user bug route to the failure handling. Locate (verbatim substring of the Step 3 monitor/route list — line 92):
```
- **`Step [N] failed: Story bug — …`** — the implementation is wrong.
```
Replace with (the new bullet inserted immediately before the located bullet, which is restated verbatim):
```
- **`Session BLOCKED:` (agent-as-user FAIL)** — a scenario's observed behavior did not match expected. This is a **post-implementation bug**: route it through `/e7-resolve-feedback {slug}` as a feedback item (it requires the phase-attributed root-cause section — see `/e7`), apply the fix, and **re-invoke `/e5-execute-tests {slug}`** to re-run Phase 5 to green. (`HALT` results are not passes — resolve the ambiguity, do not proceed to Review.)
- **`Step [N] failed: Story bug — …`** — the implementation is wrong.
```

3d — Repoint the dead rules anchor in the Environment-blocked bullet (line 97) to the Phase-3
required-Phase-5 heading. Replace both occurrences of the link anchor `#when-automated-testing-is-enabled`
with `#testing-phase-5--required` in `commands/e5-execute-tests.md`. (`replace_all` on the anchor token —
the Step-1 section removal eliminates the line-40 occurrence first, leaving only the line-97 occurrence;
`replace_all` is safe regardless of edit order.)

## Step 4 — `skills/e5-execute-tests/SKILL.md`: mirror

The skill summarizes the command; keep it consistent (D2). Five exact edits:

4a-pre — Description opening (drop the config-flag clause). Locate (verbatim, lines 4–5 of the frontmatter `description:` block):
```
  Run Phase 5 (Test) of the Shamt Engineer flow when .shamt-core/shamt-config.json sets
  testing: "enabled". Hands off the validated testing plan to the test-executor
```
Replace with:
```
  Run the required Phase 5 (Test) of the Shamt Engineer flow. Hands off the validated testing plan to the test-executor
```

4a — Description. Locate (verbatim, lines 7–8 of the frontmatter `description:` block):
```
  diagnoses, and blocks until every step PASSes. No-op with a clear message
  when testing is disabled. Invoke when the user wants to run the tests, execute
```
Replace with:
```
  diagnoses, and blocks until every scenario / step PASSes. Phase 5 is required —
  it always runs the agent-as-user execution via the user-simulator persona and the
  automated suites via test-executor when TESTING_STANDARDS.md declares them; a failure
  routes to /e7 with a required root-cause section. Invoke when the user wants to run the tests, execute
```

4b — No-op gate bullet. Locate (verbatim, line 28):
```
1. **No-op gate** — if `.shamt-core/shamt-config.json` sets `testing: "disabled"`, print the one-line skip message and exit. Do not touch any file.
```
Replace with:
```
1. **Agent-as-user execution (always)** — hand off to the `user-simulator` persona ([`agents/user-simulator.md`](../../agents/user-simulator.md)); it drives the project as a user per `.shamt-core/project-specific-files/TESTING_STANDARDS.md`, writes `stories/{slug}/agent_test_session.md`, and reports `Session PASS` / `Session BLOCKED: …`. On `Session BLOCKED`, route the failing scenario through `/e7-resolve-feedback {slug}` as a feedback item (required phase-attributed root-cause), fix, and re-invoke `/e5-execute-tests {slug}`. If `TESTING_STANDARDS.md` declares no automated suites, this is the whole required pass.
```

4c — Hand-off / monitor description line. Locate (verbatim, line 30 — keep the automated description but scope it to suites):
```
3. **Hand off to the `test-executor`** — Haiku persona ([`agents/test-executor.md`](../../agents/test-executor.md)). The executor runs each step's exact invocation, logs `PASS / FAIL / BLOCKED / PENDING` into the artifact's `## Results Log`, and fills `## Failure Diagnosis` on the first failure.
```
Replace with:
```
3. **Automated suites (when `TESTING_STANDARDS.md` declares them) — hand off to the `test-executor`** — Haiku persona ([`agents/test-executor.md`](../../agents/test-executor.md)). The executor runs each step's exact invocation, logs `PASS / FAIL / BLOCKED / PENDING` into the artifact's `## Results Log`, and fills `## Failure Diagnosis` on the first failure.
```

4d — Add the agent-as-user bug route to the monitor list. Locate (verbatim, line 33):
```
   - `Step N failed: Story bug` → re-engage the architect/builder loop via `/e4-execute-plan` or an inline Quick-path fix; re-invoke this command.
```
Replace with:
```
   - `Session BLOCKED` (agent-as-user FAIL) → route through `/e7-resolve-feedback {slug}` (required phase-attributed root-cause); fix; re-invoke this command.
   - `Step N failed: Story bug` → re-engage the architect/builder loop via `/e4-execute-plan` or an inline Quick-path fix; re-invoke this command.
```

**Verification:** `grep -c 'testing: "\|## No-op gate\|No-op gate\|testing is disabled\|testing is enabled' commands/e5-execute-tests.md skills/e5-execute-tests/SKILL.md`
→ `0` (the Step-1 replacement keeps the descriptive phrase "there is no … no-op", which is intentional and not a residual flag/gate — so the grep targets the config-flag token `testing: "` and the removed `No-op gate` heading, not the bare word "no-op"); both cite `user-simulator` and `TESTING_STANDARDS.md`.

## Step 5 — `e3b-write-testing-plan.md` (+ skill): key off `TESTING_STANDARDS.md`

Locate the no-op prerequisite:
```
- `.shamt-core/shamt-config.json` exists. Read `testing`. If `disabled`, **this command is a no-op**: print one line — `Testing is disabled in .shamt-core/shamt-config.json — no testing plan needed.` — and exit. Do not create or modify any file.
```
Replace with:
```
- `.shamt-core/project-specific-files/TESTING_STANDARDS.md` exists and is validated. Read its **Automated test infrastructure** section. If it declares **None**, **this command is a no-op**: print one line — `TESTING_STANDARDS.md declares no automated suites — no testing plan needed (Phase 5 runs the agent-as-user execution).` — and exit. Do not create or modify any file.
```
**Command `description:` (line 2).** Locate (verbatim):
```
description: Plan sub-phase (testing enabled) — produce and validate testing_plan.md from an approved spec; inline checklist on Quick-path stories with small scope
```
Replace with:
```
description: Plan sub-phase (automated suites present) — produce and validate testing_plan.md from an approved spec; inline checklist on Quick-path stories with small scope
```

**Command `**Purpose:**` (line 7).** Locate (verbatim):
```
**Purpose:** Produce and validate the testing plan for a story whose spec is approved at Gate 2b. Invoked automatically by `/e3-plan-implementation` when `testing: "enabled"` is set in `.shamt-core/shamt-config.json`. Also runnable standalone for re-planning after the Plan phase (e.g., test strategy changes mid-Build).
```
Replace with:
```
**Purpose:** Produce and validate the testing plan for a story whose spec is approved at Gate 2b. Invoked automatically by `/e3-plan-implementation` when `.shamt-core/project-specific-files/TESTING_STANDARDS.md` declares automated suites. Also runnable standalone for re-planning after the Plan phase (e.g., test strategy changes mid-Build).
```

**Command Notes no-op sentence (line 119).** Locate (verbatim):
```
- **No-op when testing is disabled.** The single-line message above is intentional — the command must remain safe to invoke unconditionally from `/e3-plan-implementation` regardless of project configuration.
```
Replace with:
```
- **No-op when `TESTING_STANDARDS.md` declares no automated suites.** The single-line message above is intentional — the command must remain safe to invoke unconditionally from `/e3-plan-implementation` regardless of the project's testing approach.
```

**Command anchor refs (lines 32 and 122).** Replace both occurrences of the link anchor
`#when-automated-testing-is-enabled` with `#testing-phase-5--required` (the Phase-3 rules heading) in
`commands/e3b-write-testing-plan.md`. (`replace_all` on the anchor token.)

**e3b SKILL — `skills/e3b-write-testing-plan/SKILL.md`:**

5-skill-a — Description. Locate (verbatim, line 4):
```
  Plan sub-phase invoked when .shamt-core/shamt-config.json sets testing: "enabled".
```
Replace with:
```
  Plan sub-phase invoked when .shamt-core/project-specific-files/TESTING_STANDARDS.md declares automated suites.
```

5-skill-b — Trailing no-op description sentence. Locate (verbatim, lines 9–10):
```
  Phase 5 testing, or escalate an inline checklist to a full artifact. No-op
  with a clear message when testing is disabled.
```
Replace with:
```
  Phase 5 testing, or escalate an inline checklist to a full artifact. No-op
  with a clear message when TESTING_STANDARDS.md declares no automated suites.
```

5-skill-c — No-op gate bullet. Locate (verbatim, line 29):
```
1. **No-op gate** — if `.shamt-core/shamt-config.json` sets `testing: "disabled"`, print one line and exit. Do not touch any file.
```
Replace with:
```
1. **No-op gate** — if `.shamt-core/project-specific-files/TESTING_STANDARDS.md` declares no automated suites, print one line and exit. Do not touch any file.
```

5-skill-c2 — Overview "when testing is enabled" clause. Locate (verbatim, line 23):
```
Mirrors the `/e3b-write-testing-plan {slug}` slash command. Same canonical body, two host wirings. Invoked by `/e3-plan-implementation` when testing is enabled; also runnable standalone for re-planning.
```
Replace with:
```
Mirrors the `/e3b-write-testing-plan {slug}` slash command. Same canonical body, two host wirings. Invoked by `/e3-plan-implementation` when `TESTING_STANDARDS.md` declares automated suites; also runnable standalone for re-planning.
```

5-skill-d — Exit-criteria anchor. Locate (verbatim, line 50):
```
Either the spec's inline checklist is populated, or `testing_plan.md` exists with a validation footer; Open Questions empty or deferred with reason. Phase 5 (Test) executes this plan and **blocks until all tests pass** — see [`SHAMT_RULES.template.md`](../../../../../templates/SHAMT_RULES.template.md#when-automated-testing-is-enabled).
```
Replace with:
```
Either the spec's inline checklist is populated, or `testing_plan.md` exists with a validation footer; Open Questions empty or deferred with reason. Phase 5 (Test) executes this plan and **blocks until all tests pass** — see [`SHAMT_RULES.template.md`](../../../../../templates/SHAMT_RULES.template.md#testing-phase-5--required).
```

**Verification:** `grep -c 'shamt-config.json.*testing\|testing: "\|when testing is enabled\|testing is disabled' commands/e3b-write-testing-plan.md skills/e3b-write-testing-plan/SKILL.md` → `0`;
`grep -q "TESTING_STANDARDS.md" commands/e3b-write-testing-plan.md skills/e3b-write-testing-plan/SKILL.md`.

## Step 6 — `e7-resolve-feedback.md` (+ skill): phase-attributed root-cause for test bugs

6a — Extend the `Root cause` row in the `addressed_feedback.md` shape. Locate:
```
- **Root cause:** <one-line summary of why the issue existed — needed for Step 5>
```
Replace with:
```
- **Root cause:** <one-line summary of why the issue existed — needed for Step 5>. **For a Phase-5 test-surfaced bug this is required and must name which phase let it through — Spec (missing requirement) / Plan (missing or wrong step) / Build (execution defect) — plus the prevention (what would have caught it earlier).**
```
6b — Add Phase 5 as a feedback source. Locate the prerequisite that `feedback/` contains a `review_vN.md`:
```
- `stories/{slug}/feedback/` contains at least one `review_vN.md` with a validation footer. If `feedback/` is empty (Quick-path no-issue path used the `## Post-Build Review` block in the spec instead), this command is mostly a TODO-scan no-op — see Step 6.
```
Replace with:
```
- A feedback source exists: a story-mode `review_vN.md` (with a validation footer) under `stories/{slug}/feedback/`, **and/or a Phase-5 bug routed here by `/e5-execute-tests`** (an `agent_test_session.md` scenario that FAILed, or a `test-executor` Story-bug). A Phase-5 bug is logged as a feedback item with the required phase-attributed root-cause (Step 2). If there is no source at all (Quick-path no-issue + Phase 5 green), this command is mostly a TODO-scan no-op — see Step 6.
```
**e7 SKILL — `skills/e7-resolve-feedback/SKILL.md`:**

6-skill-a — `addressed_feedback.md` row fields (add the phase-attributed root-cause note). Locate
(verbatim, line 29):
```
2. **Open or update `addressed_feedback.md`** — one row per reviewer comment; fields `Source`, `Disposition`, `Action taken`, `Root cause`, `Notes`.
```
Replace with:
```
2. **Open or update `addressed_feedback.md`** — one row per reviewer comment; fields `Source`, `Disposition`, `Action taken`, `Root cause`, `Notes`. For a **Phase-5 test-surfaced bug** the `Root cause` is required and must name which phase let it through — Spec (missing requirement) / Plan (missing or wrong step) / Build (execution defect) — plus the prevention.
```

6-skill-b — Inventory step (add Phase-5 bug as a feedback source). Locate (verbatim, line 28):
```
1. **Inventory feedback** — pick the latest `feedback/review_vN.md`; read its leadership sections, checklists, and `## Documentation Impact`. Carry forward `Pending` / `Needs user decision` rows from a prior `addressed_feedback.md`.
```
Replace with:
```
1. **Inventory feedback** — a feedback source is the latest `feedback/review_vN.md` **and/or a Phase-5 bug routed here by `/e5-execute-tests`** (a FAILed `agent_test_session.md` scenario or a `test-executor` Story-bug, logged as a feedback item). Read the review's leadership sections, checklists, and `## Documentation Impact`. Carry forward `Pending` / `Needs user decision` rows from a prior `addressed_feedback.md`.
```

**Verification:** `grep -q "Spec (missing requirement)" commands/e7-resolve-feedback.md skills/e7-resolve-feedback/SKILL.md`;
`grep -q "Phase-5 bug" commands/e7-resolve-feedback.md skills/e7-resolve-feedback/SKILL.md`.

## Step 7 — `test-executor.md`: scope to automated suites

Locate the opening line:
```
You are the **test executor** for Shamt Phase 5 (Test). The planning was done earlier
```
Replace with:
```
You are the **test executor** for Shamt Phase 5 (Test) — the **automated**-suite half (the agent-as-user execution is the `user-simulator` persona's job; you run only when `TESTING_STANDARDS.md` declares automated suites). The planning was done earlier
```
**Verification:** `grep -q "user-simulator" host/templates/claude/agents/test-executor.md`.

---

## Verification (phase 4a exit)

- `grep -rc 'testing: "enabled"\|testing: "disabled"\|## No-op gate\|No-op gate\|testing is disabled' commands/e5-execute-tests.md commands/e3b-write-testing-plan.md`
  → `0` (no residual config-flag or no-op *gate* in the reworked commands; the descriptive "there is no … no-op" phrase in e5's `## Required phase` section is intentional and excluded).
- `/e5` cites `user-simulator` + `TESTING_STANDARDS.md`; `/e7` has the phase-attributed root-cause; each
  command↔skill pair is consistent.
- (Regen + the full no-residual-flag sweep happen at `/f4`/`/f5` after all phases.)

## Review Prevention Gate Mapping

This phase edits canonical Claude-Code command / skill / persona markdown bodies only (no application
code, data, schema, or runtime surface). No gate applies.

| Gate | Applies? | Plan Step(s) | Verification | N/A / Deferral Reason |
|------|----------|--------------|--------------|------------------------|
| Regulated / sensitive data | No | — | — | Edits doc bodies only; no data handled. |
| Tenant isolation | No | — | — | No tenancy in framework markdown. |
| Auth / route contract | No | — | — | No auth/route surface; command/skill prose only. |
| Database read/write | No | — | — | No database access. |
| Infrastructure / deployment | No | — | — | No infra/deploy change; regen runs later at `/f4`. |
| Frontend safety | No | — | — | No frontend/DOM/fetch surface. |
| Testing / test data | No | — | — | Edits describe the testing flow but introduce no executable test/test data. |
| Removed/weakened checks | No | — | — | No security/validation check is removed; the no-op gate removed (Step 1) is a config branch, not a safety check. |

## Notes

- e5's Spec-gap / Test-bug / Story-bug routing (automated) is **retained** — it's the automated-suite
  diagnosis; the new `Session BLOCKED` route is the agent-as-user bug path. Both land in `/e7`.
- `CODING_STANDARDS Compliance`: N/A — canonical command/skill/persona bodies.

---
Validated 2026-06-13 — 8 rounds, 1 adversarial sub-agent confirmed
