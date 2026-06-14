# Proposal: agent-as-user-terminology-clarify

**Created:** 2026-06-14
**Status:** Draft (f0 — audit capture, unrefined)
**Number:**
**Proposed by:**
**Project context:**

> **f0 DRAFT — unrefined capture.** Quick-captured by the framework audit
> or a user; not yet through the open-questions dialog. Run
> `/f1-propose-update agent-as-user-terminology-clarify` to flesh it out — f1 ingests this file as
> its intake, normalizes the status to plain `Draft`, and develops the
> Scratch Notes below into a full Problem + Proposed Changes + Risks /
> Rollback / Validation Considerations.

---

## Problem

### Scratch Notes (f0 capture)

Proposal #21 names the required Phase-5 execution concept **"agent-as-user execution"**
nearly everywhere. But the *driving-procedure source* it reads is labeled
**"Manual-as-user testing"** in coupled instruction-path spots:

- `templates/testing_standards.template.md:39` — section heading `## Manual-as-user testing (always applicable)`.
- `host/templates/claude/agents/user-simulator.md:36` — instructs reading *the "Manual-as-user testing" section* (must match the heading verbatim to resolve).
- `reference/testing.md:11` — "it declares the **manual-as-user** driving procedures".
- `templates/testing_standards.template.md:9` — Update Trigger: "a documented manual-as-user procedure".

**Conflation risk:** the framework also has a genuinely distinct **human-walkthrough**
surface — `manual_test_plan.md` / `/e5b`, explicitly *for a human tester, not the agent*.
"Manual-as-user testing" sits between the two meanings: a reader can plausibly read it as
the human manual-test surface rather than the agent-driven Phase-5 surface — exactly the
conflation #21's naming was meant to avoid. The heading↔persona-instruction pair is
internally consistent, so this is not a broken reference; it is a comprehension/terminology
risk (D7), MEDIUM.

**Why intricate (not auto-fixed):** the two terms arguably name genuinely different things
(the *procedure category* documented in the standard vs the *Phase-5 run* that executes it),
so a rename is **load-bearing**, not a uniquely-determined mechanical swap. It would touch
the template heading + the persona instruction (which must stay verbatim-aligned) + the
reference + the update-trigger together, and needs a deliberate decision on the canonical
name (e.g. keep both as a deliberate layered distinction and add a one-line clarifier, or
rename the section to something like "Agent-as-user driving procedures"). The user may also
decide the current naming is intentional and reject. Captured for that judgment call.

## Proposed Changes

[Deferred to /f1-propose-update.]

## Risks

[Deferred to /f1-propose-update.]

## Rollback Plan

[Deferred to /f1-propose-update.]

## Validation Considerations

[Deferred to /f1-propose-update.]

## Open Questions

[Deferred to /f1-propose-update.]
