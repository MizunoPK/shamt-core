# Formalize Testing Standards & Required Testing Stages

**Status:** Draft (f0 — audit capture, unrefined)

> ⚠️ f0 capture — this is an unrefined idea stub. The blurb below is recorded verbatim in Scratch Notes. Resolving it into a formal proposal (Problem statement, Proposed Changes table, Risks / Rollback / Validation Considerations, open-questions dialog) is deferred to `/f1-propose-update`.

## Scratch Notes (f0 capture)

i want to formalize the testing stages of the engineer development. On project init, I want to create a TESTING_STANDARDS.md doc alongside CODING_STANDARDS and ARCHITECTURE. In this, the agent should be trying to catalog the best way to test the project this should involve how to manually test the scripts and any automated tests (if automated tests are present). Move the questions about testing out of the init script and into the prompt/process for the creation of this document. Manual testing should also include having the agent simulate being a user by running scripts and providing inputs to the scripts if applicable. The testing stages of the engineer flow should then become required. Testing must pass after implementation. If there are any bugs, then the situation must be treated as if it is a feedback comment that is getting resolved via resolve-feedback stage. The issue should be documented, a fix should be found and tested, an analysis of why the issue got through spec/plan/builder stages should be performed, etc.

### Informal implicated areas (not yet verified)

- `init-shamt.sh` / init flow — move testing questions out; seed a new `TESTING_STANDARDS.md` doc-creation step.
- `.shamt-core/project-specific-files/` — add `TESTING_STANDARDS.md` alongside `ARCHITECTURE.md` / `CODING_STANDARDS.md`.
- A new doc-authoring prompt/process for TESTING_STANDARDS.md (manual test cataloging + agent-as-user simulation + automated-test cataloging).
- Engineer flow Phase 5 (`/e5-execute-tests`) and the `testing` config flag — make testing required rather than opt-in (interaction with current `testing: enabled/disabled` config).
- Bug-as-feedback loop — route post-implementation test failures through `/e7-resolve-feedback` mechanics: document the issue, fix + test, root-cause analysis of how it escaped spec/plan/build.

## Proposed Changes

_TODO (deferred to /f1-propose-update)_

## Risks / Rollback / Validation Considerations

_TODO (deferred to /f1-propose-update)_
