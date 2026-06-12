# Manual Test Plan: {slug}

**Note:** Optional per-story artifact. Produced by `/e5b-write-manual-testing-plan {slug}` after Phase 4 (Build) — or after Phase 5 (Test) when automated testing is enabled. Orthogonal to the project-level automated testing opt-in: this artifact is available regardless of `testing` in `.shamt-core/shamt-config.json`. The agent runs an inline validation loop using `reference/severity_classification.md` (Pattern 2) with the four dimensions listed at the bottom of this file before considering the plan drafted.

**Created:** [Date]
**Story:** stories/{slug}/
<!-- Paths are relative to the resolved story folder (located per templates/SHAMT_RULES.template.md §PO-tree resolution; the folder nests under epics/.../features/.../). -->
**Spec:** stories/{slug}/spec.md (or `spec_vN.md` for re-baselined stories)
**Implementation Plan:** stories/{slug}/implementation_plan.md (or N/A on Quick path)
**Testing Plan:** stories/{slug}/testing_plan.md (or N/A when testing is disabled)
**Path:** Quick path | Standard path
**Baseline:** v1
**Baseline status:** Active

---

## Open Questions

[Only unresolved questions about coverage, environment, or scenario design that block plan completion. Per the open-questions iterative-dialog principle in `templates/SHAMT_RULES.template.md`, surface each question to the user one at a time and update the plan with each answer before moving on. Code-research every question first.]

---

## Setup

[Everything the tester needs before step 1 of scenario 1. The Setup section is complete if a tester unfamiliar with the codebase can reach the starting state of scenario 1 without external help.]

- **Environment state:** [Local dev / staging / production-shadow / etc. — be specific about which environment.]
- **Test data:** [Records, files, fixtures that must exist. Include how to create them — script, fixture file, manual seed.]
- **Accounts:** [Test users, roles, tenant identifiers required. Note where credentials are stored.]
- **Feature flags:** [Flags that must be on/off; how to toggle.]
- **External service state:** [Third-party sandboxes, webhook endpoints, mock servers. Note any auth or quota constraints.]
- **Tooling:** [Browsers, CLI tools, mobile devices, screen readers, etc.]

---

## Scenarios

Each scenario is independently runnable. Steps are imperative and specific; the expected outcome is concrete and observable (not "looks right"); the pass/fail criterion is a binary check the tester can perform without judgment.

### Scenario 1: [Name]

**Starting state:** [What is true before you start — references the Setup section's resulting state.]

**Steps:**
1. [Imperative step. Be specific: "Click the **Save** button at the top right of the Account Settings page" — not "save the form".]
2. [Step]
3. [Step]

**Expected outcome:** [Concrete, observable. Name the UI element / response value / log line / error message the tester should see, read, measure, or receive. Avoid "looks right" or "works correctly".]

**Pass/fail criterion:** [Binary check. Example: "The toast message reads `Saved` AND the row in `audit_log` shows `event=settings_updated` for the test user within 5 seconds." NOT "Page loads correctly."]

---

### Scenario 2: [Name]

**Starting state:** [...]

**Steps:**
1. [...]

**Expected outcome:** [...]

**Pass/fail criterion:** [...]

---

[Add more scenarios as needed]

---

## Teardown

[How to clean up after the test run. Required even if minimal — a one-line `N/A — no shared state changed.` is acceptable when true.]

- [Delete created test data — command or manual step]
- [Reset feature flag state]
- [Revoke temporary credentials]
- [Restart services to clear in-memory state, if applicable]

---

## Coverage Note

[One paragraph: what automated tests cover for this story vs. what this plan covers. Gives the reviewer the full testing picture without re-reading both artifacts. If `testing_plan.md` does not exist for this story, say so and describe the rationale for choosing manual-only coverage.]

---

## Validation Dimensions

Inline validation runs Pattern 1 with these four dimensions (each finding classified per `reference/severity_classification.md`):

1. **Scope coverage** — Every risk area named in the spec's `Scope` / Requirements / Review Prevention Gates has at least one scenario that exercises it. A gap is **HIGH**.
2. **Step reproducibility** — Each step is unambiguous enough that someone unfamiliar with the codebase can execute it without asking a question. Vague steps (e.g., "navigate to the admin page") are **MEDIUM**.
3. **Observable pass/fail** — Every scenario's pass/fail criterion is a binary check the tester can perform without judgment (specific UI element, response value, log line, error message). "Looks right" or "works correctly" is **HIGH**.
4. **Setup completeness** — The Setup section provides enough detail that a tester can reach the starting state of scenario 1 without external help. Missing credentials or undocumented data dependencies are **HIGH**.

Exit: standard Pattern 1 exit per `/validate-artifact` (the source of truth for validation exits) — one primary clean round (0 issues or at most 1 LOW fixed) plus, on the Standard path (or risk-triggered Quick), one adversarial sub-agent confirmation. Quick-path plans use a single primary pass unless a finding is HIGH or above.

---
[Append the validation footer only after the validation loop completes for the manual test plan.]
