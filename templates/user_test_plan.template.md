# User Test Plan: {slug}

**Note:** Mandatory per-story artifact. Authored during Phase 4 (Test Plan) by `/e4-write-test-plan {slug}` — the always-produced half of the Test Plan stage (the automated `testing_plan.md` is produced alongside only when `TESTING_STANDARDS.md` declares suites). It is the **agent-as-user execution script**: in Phase 6 (Test) the `user-simulator` persona reads this plan and executes every scenario by driving the project as a real user, logging the per-run results into `stories/{slug}/agent_test_session.md` (this plan holds the scenarios, not the run log). The agent runs an inline validation loop using `reference/severity_classification.md` (Pattern 2) with the four dimensions listed at the bottom of this file before considering the plan drafted.

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
