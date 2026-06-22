# Agent-as-User Test Session: {slug}

**Note:** Required per-story Phase 6 artifact — the run log of the agent-as-user execution. Produced
by the `user-simulator` persona (invoked by `/e6-execute-tests {slug}`), which **executes the
scenarios in `stories/{slug}/user_test_plan.md`** (the mandatory Phase-4 plan), driving the project
as a user with the how-to-drive conventions from
`.shamt-core/project-specific-files/TESTING_STANDARDS.md`. Every scenario must end `PASS`; ambiguous
results are logged `HALT` (never silently passed) and surfaced.

**Created:** [Date]
**Story:** stories/{slug}/
<!-- Paths are relative to the resolved story folder (located per templates/SHAMT_RULES.template.md §PO-tree resolution). -->
**Spec:** stories/{slug}/spec.md (or `spec_vN.md`)
**Testing Standards:** .shamt-core/project-specific-files/TESTING_STANDARDS.md
**Baseline:** v1

---

## Scenarios

One block per scenario in `stories/{slug}/user_test_plan.md` — this session logs the execution of
that plan's scenarios (driven with the `TESTING_STANDARDS.md` how-to-drive conventions), not a
separately derived scenario set.

### Scenario 1 — [name]

- **Drive:** [exact command(s) run to exercise this scenario]
- **Inputs supplied:** [the inputs the agent provided as the user]
- **Expected:** [the observable correct behavior, per TESTING_STANDARDS + the spec]
- **Observed:** [verbatim/short evidence of what actually happened — output, exit code, state]
- **Result:** [PASS | FAIL | HALT]  ([on FAIL] → routed to `/e8-resolve-feedback`; [on HALT] → reason)

---

## Results

| Scenario | Result | Evidence | Notes |
|---|---|---|---|
| 1 | | | |

**Session verdict:** [PASS — all scenarios PASS | BLOCKED — N FAIL/HALT, routed to Polish]
