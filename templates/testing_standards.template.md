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
