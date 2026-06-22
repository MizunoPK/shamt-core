# Requirement Re-baseline Protocol Reference

Expanded trigger list and step-by-step contract for the Requirement Re-baseline Protocol. `SHAMT_RULES.template.md` keeps the normative contract — the one-sentence "use when" rule and the "unversioned names remain baseline v1; do not rename or overwrite" rule; this file holds the full trigger enumeration and the 10-step contract each re-baseline executes.

## When to re-baseline

Use a re-baseline when a large requirement change arrives after Gate 2b, Gate 3, or Build execution and the active spec or plan would become misleading. Triggers include:

- accepted behavior changes materially;
- the implementation plan needs substantial replacement;
- code already changed under the superseded plan must be accounted for;
- a new architecture, data flow, API contract, persistence shape, or deployment boundary appears;
- the team would reasonably ask which spec or plan is current.

## Re-baseline contract

1. Stop the current phase.
2. State whether the change is minor or a re-baseline.
3. Determine the next version number.
4. Create `spec_vN.md` and `context_vN.md`, carrying forward only still-valid material.
5. Record prior baseline and current code state in `context_vN.md`.
6. Validate the new spec/context pair.
7. Create `implementation_plan_vN.md` and any phase files needed, plus the mandatory spec-derived test plans: `user_test_plan_vN.md` always, and `testing_plan_vN.md` when `TESTING_STANDARDS.md` declares automated suites.
8. Validate the new plan and test plan(s).
9. Create or update `active_artifacts.md` from `templates/active_artifacts.template.md`.
10. Resume at Gate 2b, then Gate 3, then continue the workflow.

Unversioned names remain baseline v1. Do not rename or overwrite them.
