# Implementation Plan — Phase 4b: Flag-reference cleanup (Engineer bodies + templates)

**Proposal:** `proposals/21-formalize-testing-standards-and-stages.md`
**Index:** `proposals/21-formalize-testing-standards-and-stages_PLAN.md`
**Phase:** 4b of 5 — the **rote** half of Phase 4: rework every remaining `testing: enabled/disabled`
reference in `e2`/`e3`/`e4`/`e6`/`e8` command+skill bodies, the `e5b` command+skill (human-walkthrough
vs agent-as-user), and the per-story test templates for **required** testing (no config flag; automated
gated on `TESTING_STANDARDS.md`). Uniform rewordings.
**Depends on:** Phase 3 (the rules contract) + 4a (the e5/e3b/e7 logic). **Executor:** `plan-executor`.

## Files manifest

`e2-define-spec`, `e3-plan-implementation`, `e4-execute-plan`, `e8-finalize-story` (command + skill),
`e6-review-changes` (command), `e5b-write-manual-testing-plan` (command + skill),
`templates/spec.template.md`, `templates/testing_plan.template.md`,
`templates/manual_test_plan.template.md`, `templates/active_artifacts.template.md`. All EDIT.

**Global rewording rule (apply at every located anchor):** `testing: "enabled"` / "when testing is
enabled" → **gated on `TESTING_STANDARDS.md` declaring automated suites** (for automated artifacts) or
**required / always** (for the Phase-5 gate); `testing: "disabled"` / "when disabled" → **when
`TESTING_STANDARDS.md` declares no automated suites**; the §`#when-automated-testing-is-enabled` rules
anchor → `#testing-phase-5--required`. The literal edits below are the complete set.

---

## Step 1 — `e2-define-spec` (command + skill): Test Strategy always-relevant

1a — `commands/e2-define-spec.md:102` — locate the **entire** bullet (single line) `- **`Test Strategy`** (when `.shamt-core/shamt-config.json` sets `testing: "enabled"`) — see [`SHAMT_RULES.template.md`](../../../../templates/SHAMT_RULES.template.md#when-automated-testing-is-enabled). Approval-relevant at Gate 2b. List test kinds in scope, existing test files relevant, new test files needed, and project conventions to follow. Quick path with ≤5 test steps and no new file may use the spec's inline `Quick path inline test checklist`; otherwise the full `testing_plan.md` is produced in Phase 3.`
→ replace the whole bullet with: `- **`Test Strategy`** (testing is a **required** phase — see [`reference/testing.md`](../../../../reference/testing.md)). Approval-relevant at Gate 2b. Describe how this story is verified in Phase 5: the agent-as-user scenarios always, and (when `TESTING_STANDARDS.md` declares automated suites) the automated test kinds in scope, existing test files relevant, new test files needed, and project conventions to follow. Quick path with ≤5 test steps and no new file may use the spec's inline `Quick path inline test checklist`; otherwise the full `testing_plan.md` is produced in Phase 3.`
1b — `:124` `- The Test Strategy (when testing is enabled).` → `- The Test Strategy (always — testing is required).`
1c — `:143` `The Test Strategy section is approval-relevant at Gate 2b only when testing is enabled. Omit
it entirely when `testing: "disabled"`.` → `The Test Strategy section is always approval-relevant at
Gate 2b (testing is required); it always covers the agent-as-user scenarios and adds automated detail
when `TESTING_STANDARDS.md` declares suites.`
1d — `skills/e2-define-spec/SKILL.md:33` `Test Strategy (when `testing: "enabled"`)` → `Test Strategy
(required)`.

## Step 2 — `e3-plan-implementation` (command + skill)

2a — `commands/e3-plan-implementation.md:2` description — locate `chains to /e3b-write-testing-plan when testing is enabled` → `chains to /e3b-write-testing-plan when TESTING_STANDARDS.md declares automated suites`.
2b — `:7` purpose — locate `When `.shamt-core/shamt-config.json` sets `testing: "enabled"`, this command also invokes `/e3b-write-testing-plan {slug}` as a sub-phase before exit.` → `When `TESTING_STANDARDS.md` declares automated suites, this command also invokes `/e3b-write-testing-plan {slug}` as a sub-phase before exit.`.
2c — `:101` heading `### Step 4 — Write the testing plan (when enabled)` → `### Step 4 — Write the testing
plan (when automated suites present)`.
2d — `:103` — locate `Read `.shamt-core/shamt-config.json` → `testing`. If `enabled`, invoke `/e3b-write-testing-plan {slug}` as a sub-phase.` → `Read `TESTING_STANDARDS.md`'s Automated section. If it declares suites present, invoke `/e3b-write-testing-plan {slug}` as a sub-phase.`.
2e — `:105` — locate `If `testing: "disabled"`, skip this step. `/e3b-write-testing-plan` would be a no-op anyway, but skipping the invocation keeps the chat output clean.` → `If `TESTING_STANDARDS.md` declares no automated suites, skip this step. `/e3b-write-testing-plan` would be a no-op anyway, but skipping the invocation keeps the chat output clean.`.
2f — `:123` — locate `When testing is enabled, `stories/{slug}/testing_plan.md` (or the spec's inline checklist on Quick escalations) exists with its validation footer.` → `When `TESTING_STANDARDS.md` declares automated suites, `stories/{slug}/testing_plan.md` (or the spec's inline checklist on Quick escalations) exists with its validation footer.`.
2g — `skills/e3-plan-implementation/SKILL.md`, four anchors (the YAML `description:` block wraps the
sentence across lines `:6`→`:7`, so it is two separate single-line EDITs — `:6` ends with `testing is`,
`:7` begins with `enabled.`):
  - `:6` — locate `builder handoff at Gate 3. Chains into /e3b-write-testing-plan when testing is` → `builder handoff at Gate 3. Chains into /e3b-write-testing-plan when TESTING_STANDARDS.md declares`.
  - `:7` — locate `enabled. Invoke when the user wants to plan the implementation,` → `automated suites. Invoke when the user wants to plan the implementation,`.
  - `:37` — locate `5. **Chain into `/e3b-write-testing-plan {slug}`** when `.shamt-core/shamt-config.json` sets `testing: "enabled"`. Wait for the testing plan to validate before Gate 3.` → `5. **Chain into `/e3b-write-testing-plan {slug}`** when `TESTING_STANDARDS.md` declares automated suites. Wait for the testing plan to validate before Gate 3.`.
  - `:49` — locate `Validated `implementation_plan.md` (and `testing_plan.md` when testing is enabled) approved at Gate 3` → `Validated `implementation_plan.md` (and `testing_plan.md` when TESTING_STANDARDS.md declares automated suites) approved at Gate 3`.

## Step 3 — `e4-execute-plan` (command + skill): exit always points to required Phase 5

3a — `commands/e4-execute-plan.md:100–101` — locate:
```
- `testing: "enabled"` → `/clear`, then `/e5-execute-tests {slug}` (Phase 5).
- `testing: "disabled"` → `/clear`, then `/e6-review-changes {slug}` (Phase 6).
```
Replace with:
```
- Always → `/clear`, then `/e5-execute-tests {slug}` (Phase 5 — **required**). Phase 5 runs the
  agent-as-user execution (and automated suites when `TESTING_STANDARDS.md` declares them), then suggests
  `/e6-review-changes {slug}`.
```
3b — `skills/e4-execute-plan/SKILL.md:35` — locate the **entire** bullet `6. **Exit** — suggest `/clear` + `/e5-execute-tests {slug}` (when `testing: "enabled"`), `/e6-review-changes {slug}` (when testing is disabled), and optionally `/e5b-write-manual-testing-plan {slug}` for UI / cloud-infra / external-integration / multi-user scope.` → replace the whole bullet with `6. **Exit** — suggest `/clear` + `/e5-execute-tests {slug}` (Phase 5 — **required**), then `/e6-review-changes {slug}`, and optionally `/e5b-write-manual-testing-plan {slug}` for UI / cloud-infra / external-integration / multi-user scope.`.

## Step 4 — `e6-review-changes.md:62`: testing_plan resolution

4a — `commands/e6-review-changes.md:62` — locate `1. Apply the active-artifact pointer; resolve `spec`, `context` (Standard only), `implementation_plan` (Standard only), and `testing_plan` (when testing is enabled **and** the story uses a full artifact rather than the Quick-path inline checklist in `spec.md`) paths.` → `1. Apply the active-artifact pointer; resolve `spec`, `context` (Standard only), `implementation_plan` (Standard only), `agent_test_session` (the required Phase-5 run), and `testing_plan` (when `TESTING_STANDARDS.md` declares automated suites **and** the story uses a full artifact rather than the Quick-path inline checklist in `spec.md`) paths.`

## Step 5 — `e8-finalize-story` (command + skill): Test PASSes required + phase count

5a — `commands/e8-finalize-story.md:37` — locate:
```
3. When testing is enabled (`.shamt-core/shamt-config.json` `testing: "enabled"`), confirm **Test passed**: the active `testing_plan.md` (or the Quick-path inline checklist) shows every step `PASS`. If any step is unrun or failing, halt and direct the user to `/e5-execute-tests {slug}`.
```
Replace with:
```
3. Confirm **Test passed** (Phase 5 is required): `stories/{slug}/agent_test_session.md` shows the session verdict `PASS`, and — when `TESTING_STANDARDS.md` declares automated suites — the active `testing_plan.md` (or the Quick-path inline checklist) shows every step `PASS`. If any is unrun or failing, halt and direct the user to `/e5-execute-tests {slug}`.
```
5b — `:93` — locate `(N = 7 normally, 8 when automated testing is enabled)` → `(N = 7 on the Quick path,
8 on the Standard path — testing is a required phase)`.
5c — `skills/e8-finalize-story/SKILL.md:30` — locate `Test PASSes when testing is enabled` → `Test PASSes
(required — agent-as-user, plus automated when TESTING_STANDARDS.md declares suites)`.

## Step 6 — Test templates

6a — `templates/spec.template.md:71` — locate `[Required when `.shamt-core/shamt-config.json` sets
`testing: "enabled"`. Omit when testing is disabled.]` → `[Required (testing is a required phase). Always
describe the Phase-5 agent-as-user scenarios; add automated detail when `TESTING_STANDARDS.md` declares
suites.]`.
6b — `templates/testing_plan.template.md:3` — locate `Produced during Phase 3 (Plan) when
`.shamt-core/shamt-config.json` sets `testing: "enabled"`.` → `Produced during Phase 3 (Plan) when
`.shamt-core/project-specific-files/TESTING_STANDARDS.md` declares automated suites.`
6c — `templates/manual_test_plan.template.md:3` — locate `Produced by `/e5b-write-manual-testing-plan {slug}` after Phase 4 (Build) — or after Phase 5 (Test) when automated testing is enabled. Orthogonal to the project-level automated testing opt-in: this artifact is available regardless of `testing` in `.shamt-core/shamt-config.json`.` →
`Produced by `/e5b-write-manual-testing-plan {slug}` after Phase 4 (Build) or Phase 5 (Test). It is the on-demand **human-walkthrough** for scenarios the agent cannot simulate (real UI, cloud infra, multi-user) — **not** part of the required Phase-5 pass (which is the agent-as-user execution). Available on every story.` Also `:10` — locate `**Testing Plan:** stories/{slug}/testing_plan.md (or N/A when testing is disabled)` → `**Testing Plan:** stories/{slug}/testing_plan.md (or N/A when TESTING_STANDARDS.md declares no automated suites)`.
6d — `templates/active_artifacts.template.md:20` — locate `(or `N/A — testing disabled` / `N/A — Quick
path inline checklist`)` → `(or `N/A — no automated suites` / `N/A — Quick path inline checklist`)`. Then
insert a new table row for the required Phase-5 artifact **immediately after** the `:21` Manual Test Plan
row (`| Manual Test Plan | `stories/{slug}/manual_test_plan_vN.md` (or `N/A — not produced`) |`) and
**before** the `:22` Mermaid Diagram row — locate `| Manual Test Plan | `stories/{slug}/manual_test_plan_vN.md` (or `N/A — not produced`) |` and replace it with that same line followed by a newline and `| Agent Test Session | `stories/{slug}/agent_test_session_vN.md` |` (the required Phase-5 run log; no `N/A` — always produced).

## Step 7 — `e5b-write-manual-testing-plan` (command + skill): human-walkthrough vs agent-as-user

`/e5b` keeps producing the on-demand `manual_test_plan.md`; the edit clarifies its relationship to the
new **required** agent-as-user Phase-5 pass and retires the dropped-flag references. (`/e5b` itself stays
unconditionally available — it never gated on the flag; the rewordings just retire the stale `testing:
"disabled"` mentions and point at the new model.)

7a — `commands/e5b-write-manual-testing-plan.md:2` — description, locate `available regardless of the
testing config flag` → `available on every story (orthogonal to the required agent-as-user Phase 5 — it
covers scenarios the agent cannot simulate)`.
7b — `:7` — purpose, locate `**orthogonal to the project-level automated-testing opt-in** (no `.shamt-core/shamt-config.json` no-op check — this command is always available).` → `**orthogonal to the required Phase-5 agent-as-user execution** — it is the on-demand **human-walkthrough** for scenarios the agent cannot simulate (real UI, cloud infra, multi-user), always available (no no-op check).`.
7c — `:36` — locate `- **No `.shamt-core/shamt-config.json` `testing` check.** This command does **not**
no-op on `testing: "disabled"` — it is independently available on every story.` → `- **Always
available.** Unlike the required Phase-5 agent-as-user run, this on-demand human-walkthrough is invocable
on every story; it has no no-op gate.`
7d — `:59` — locate `If `testing: "enabled"` and `testing_plan.md` exists, read its` → `If a
`testing_plan.md` exists (i.e. `TESTING_STANDARDS.md` declares automated suites), read its`.
7e — `:150` — locate `**No `.shamt-core/shamt-config.json` no-op gate.** Unlike `/e5-execute-tests` and
`/e3b-write-testing-plan`, this command does **not** check `testing` and does **not** print a no-op
message.` → `**No no-op gate.** Unlike `/e5-execute-tests` (the required Phase-5 run) and
`/e3b-write-testing-plan` (gated on `TESTING_STANDARDS.md` declaring suites), this on-demand
human-walkthrough does **not** check anything and does **not** print a no-op message.`
7f — `skills/e5b-write-manual-testing-plan/SKILL.md`, two anchors (keep consistent with the command — D2):
  - `:8` — locate `Orthogonal to .shamt-core/shamt-config.json testing — always available, every story. The` → `The on-demand human-walkthrough for scenarios the agent cannot simulate — always available, every story, orthogonal to the required Phase-5 agent-as-user execution. The`.
  - `:26` — locate `**Always available** regardless of `.shamt-core/shamt-config.json` `testing` — no no-op gate (this is the manual-test-plan rule that distinguishes it from `/e3b-write-testing-plan` and `/e5-execute-tests`).` → `**Always available** on every story — no no-op gate; this on-demand human-walkthrough is orthogonal to the required Phase-5 agent-as-user run, which distinguishes it from `/e3b-write-testing-plan` and `/e5-execute-tests`.`.

---

## Review Prevention Gate Mapping

This phase edits canonical Claude-Code command / skill markdown bodies and per-story artifact
templates only (no application code, data, schema, or runtime surface). No gate applies.

| Gate | Applies? | Plan Step(s) | Verification | N/A / Deferral Reason |
|------|----------|--------------|--------------|------------------------|
| Regulated / sensitive data | No | — | — | Edits doc/template bodies only; no data handled. |
| Tenant isolation | No | — | — | No tenancy in framework markdown. |
| Auth / route contract | No | — | — | No auth/route surface; command/skill/template prose only. |
| Database read/write | No | — | — | No database access. |
| Infrastructure / deployment | No | — | — | No infra/deploy change; regen runs later at `/f4`. |
| Frontend safety | No | — | — | No frontend/DOM/fetch surface. |
| Testing / test data | No | — | — | Edits reword testing-flow prose but introduce no executable test/test data. |
| Removed/weakened checks | No | — | — | No security/validation check is removed; the `testing: disabled` config branches reworded here are config gates, not safety checks. |

---

## Verification (4b exit)

- `grep -rcE 'testing: "(enabled|disabled)"|when (automated )?testing is (enabled|disabled)'`
  across all 4b files → `0` (the `(automated )?` alternation also catches the e8 `:93` /
  `manual_test_plan.template.md:3` "automated testing is enabled" phrasing).
- `grep -rc 'TESTING_STANDARDS.md' host/templates/claude/commands/e2-define-spec.md
  host/templates/claude/commands/e3-plan-implementation.md` (and the other edited bodies) is non-zero —
  the rewordings landed.
- Each command↔skill pair (e2/e3/e4/e8/e5b) is mutually consistent (D2).

## Notes

- After 4b, the **only** remaining flag references are in Phase 5's files (CLAUDE/README/statusline/
  audit_dimensions). The post-impl `/f5` D2 sweep is the global backstop asserting zero residual flag.
- `CODING_STANDARDS Compliance`: N/A — canonical bodies/templates.

---
Validated 2026-06-13 — 10 rounds, 1 adversarial sub-agent confirmed
