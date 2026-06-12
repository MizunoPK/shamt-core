# Adversarial, Independent Feedback Review When Drafting Proposals

**Status:** Draft (f0 — audit capture, unrefined)

> ⚠️ f0 capture — this is an unrefined idea stub. The blurb below is recorded verbatim in Scratch Notes. Resolving it into a formal proposal (Problem statement, Proposed Changes table, Risks / Rollback / Validation Considerations, open-questions dialog) is deferred to `/f1-propose-update`.

## Scratch Notes (f0 capture)

I want to increase the thouroughness of the review of feedback and issues when drafting shamt lite proposals. The agent should assume that any bugs or feedback recieved indicates that updates to shamt are required. It should make use of adversarial independant agents with no bias to determine what went wrong and how to fix things

### Informal implicated areas (not yet verified)

- `/f1-propose-update` (Phase 1 of the framework-update flow) — the proposal-drafting process; add a more thorough feedback/issue-review step.
- Default stance: any bug or feedback received → assume a Shamt update is required (root-cause routing rather than one-off patching).
- Adversarial independent sub-agents (zero-bias, Haiku/Opus per Pattern 1/2) to diagnose what went wrong and propose the fix — analogous to the validation/audit sub-agent confirmation pattern.
- Possible overlap with `/e7-resolve-feedback` root-cause-to-proposal routing and the companion f0 draft `formalize-testing-standards-and-stages` (bug-as-feedback loop).

## Proposed Changes

_TODO (deferred to /f1-propose-update)_

## Risks / Rollback / Validation Considerations

_TODO (deferred to /f1-propose-update)_
