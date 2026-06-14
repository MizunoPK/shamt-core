# Proposal: d6-currency-include-testing-standards

**Created:** 2026-06-14
**Status:** Draft (f0 — audit capture, unrefined)
**Number:**
**Proposed by:**
**Project context:**

> **f0 DRAFT — unrefined capture.** Quick-captured by the framework audit
> or a user; not yet through the open-questions dialog. Run
> `/f1-propose-update d6-currency-include-testing-standards` to flesh it out — f1 ingests this file as
> its intake, normalizes the status to plain `Draft`, and develops the
> Scratch Notes below into a full Problem + Proposed Changes + Risks /
> Rollback / Validation Considerations.

---

## Problem

### Scratch Notes (f0 capture)

Proposal #21 added `TESTING_STANDARDS.md` as a **third** required project-specific
doc — seeded at init alongside `ARCHITECTURE.md` / `CODING_STANDARDS.md`, carrying the
same `Last Updated:` header contract (`templates/testing_standards.template.md:2`), and
`README.md:233` + `init-shamt.sh:267` already describe the staleness threshold as
governing **"the three project-specific docs."**

But audit dimension **D6 (project-doc currency)** still checks only `ARCHITECTURE.md`
and `CODING_STANDARDS.md`. The dimension lags its own documented intent — an internal
inconsistency surfaced by the post-#21 `/f5` sweep. D6 is defined in three canonical
places that would all need updating:

- `reference/audit_dimensions.md` — D6 row (~:21) and the Correctness/Completeness table (~:47).
- `host/templates/claude/commands/f5-audit-framework.md` — Prerequisites (~:36), the D6
  dimension-table row (~:47), and the Step-2 D6 logic (~:128–:133), plus the Notes recap (~:231).
- `host/templates/claude/skills/f5-audit-framework/SKILL.md` — the D6 summary bullet.

**Why intricate (not auto-fixed by the audit):** multi-file (reference + command + skill,
host edits require regen), and the self-host **"both missing → single LOW informational"**
not-applicable branch needs a deliberate design call for three docs — is it "all three
missing", what happens on a partial set (e.g. TESTING present, others absent), and is a
missing `TESTING_STANDARDS.md` HIGH by parity with the other two? Resolving that is a
coordinated, judgment-bearing edit, so the audit captured it rather than patching in place.

Likely shape: extend each D6 passage to enumerate `TESTING_STANDARDS.md` everywhere
`ARCHITECTURE.md`/`CODING_STANDARDS.md` appear, generalize the "both present"/"both missing"
wording to "all three", and confirm the severity ladder (missing = HIGH; stale = MEDIUM;
self-host all-absent = single LOW) carries over. Re-run D1 after the host/skill edits.

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
