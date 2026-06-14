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
