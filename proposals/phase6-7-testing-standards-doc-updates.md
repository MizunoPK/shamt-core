# Proposal: phase6-7-testing-standards-doc-updates

**Created:** 2026-06-14
**Status:** Draft (f0 — audit capture, unrefined)
**Number:**
**Proposed by:**
**Project context:**

> **f0 DRAFT — unrefined capture.** Quick-captured by the framework audit
> or a user; not yet through the open-questions dialog. Run
> `/f1-propose-update phase6-7-testing-standards-doc-updates` to flesh it out — f1 ingests this file as
> its intake, normalizes the status to plain `Draft`, and develops the
> Scratch Notes below into a full Problem + Proposed Changes + Risks /
> Rollback / Validation Considerations.

---

## Problem

### Scratch Notes (f0 capture)

`templates/testing_standards.template.md:11-16` ("How to Update") promises the same
maintenance mechanism its sibling docs get: *"Phase 6 (Review) flags whether a story
implies an update; Phase 7 (Polish) applies it and re-validates. Run `/validate-artifact
.shamt-core/project-specific-files/TESTING_STANDARDS.md` after substantive edits."*

But the Phase 6/7 bodies that implement that mechanism only enumerate the **two original**
project docs — `TESTING_STANDARDS.md` was given the template prose but never wired into the
machinery it points at:

- `host/templates/claude/commands/e6-review-changes.md:92-104` — the **Documentation Impact
  Assessment** (`## Documentation Impact` block) asks only about `ARCHITECTURE.md` and
  `CODING_STANDARDS.md`. The skill mirror (`e6-review-changes/SKILL.md:39`) and the
  `## Standards check` prerequisite (`e6 cmd:45`) likewise list only the two.
- `host/templates/claude/commands/e7-resolve-feedback.md:33, :79-80` (+ the skill description)
  — the doc-update step applies/`Last Updated`-bumps/re-validates only `ARCHITECTURE.md` /
  `CODING_STANDARDS.md`.

Net effect: `TESTING_STANDARDS.md` would silently **never be updated through the normal
Engineer flow** despite its own template instructing that Phase 6/7 maintain it. The
architecture/coding_standards templates carry identical "How to Update" prose and ARE wired
into e6/e7; this is the one that was missed.

**Why intricate (not auto-fixed):** multi-file (e6 command + skill, e7 command + skill, and
likely the SHAMT_RULES Pattern 4 "Standards check" :182 / review-alignment :203 / research
digest :343 passages), plus a design call — does Review assess TESTING_STANDARDS impact on
the same footing as the other two, or under a testing-specific trigger (a recurring
test-surfaced bug, a changed run procedure) given Phase 5 already exercises the project?
Resolving that is coordinated, judgment-bearing work.

**Shared root cause** with `[[d6-currency-include-testing-standards]]` — both stem from
`TESTING_STANDARDS.md` being added as a third project doc (#21) without being wired into the
mechanisms that treat the project-doc set as a unit (the audit's D6 currency check there; the
Engineer flow's Review/Polish doc-impact mechanics here). `/f1` may choose to merge the two
into a single "wire the third project doc into all doc-set mechanics" proposal.

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
