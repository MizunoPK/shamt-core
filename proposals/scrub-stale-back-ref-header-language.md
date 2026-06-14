# Proposal: scrub-stale-back-ref-header-language

**Created:** 2026-06-14
**Status:** Draft (f0 — audit capture, unrefined)
**Number:** [NN — master-side only; assigned by /f1-propose-update or /sync-triage-proposals promote.]
**Proposed by:** [master-local]
**Project context:** [master-local]

> **f0 DRAFT — unrefined capture.** Quick-captured by the framework audit
> or a user; not yet through the open-questions dialog. Run
> `/f1-propose-update scrub-stale-back-ref-header-language` to flesh it out — f1 ingests this file as
> its intake, normalizes the status to plain `Draft`, and develops the
> Scratch Notes below into a full Problem + Proposed Changes + Risks /
> Rollback / Validation Considerations.

---

## Problem

See Scratch Notes below (f0 capture — not yet refined).

## Scratch Notes (f0 capture)

**Source:** `/f5-audit-framework` D2/D9 finding (2026-06-14 sweep). Classified **HIGH**, **intricate** (coordinated multi-file edit + design judgment) → captured rather than auto-fixed.

**The contradiction.** Stale "back-ref headers" language survives in several canonical/host bodies and contradicts the authoritative path-parentage model.

Authoritative sources (correct):
- `templates/SHAMT_RULES.template.md:159` — "Parentage is encoded by the path — there are **no `**Parent Epic:**` / `**Parent Feature:**` back-ref headers**."
- `README.md:150` and `README.md:175` — no back-ref headers; `/e1-start-story` derives parentage by walking up the resolved path; the `feat:` / `epic:` status-line segments are derived by walking up the active-story pointer's path "(not from back-ref headers)".

Stale leftover language (contradicts the above):
1. `host/templates/claude/commands/p4-decompose-feature.md:7` — Purpose says story stubs each carry "back-ref headers for parent feature" while the same parenthesis says "parentage is the folder path" (self-contradictory; p4:220 correctly says "no back-ref headers are written").
2. `host/templates/claude/commands/p4-decompose-feature.md:199` — "`/e1-start-story` is **stub-aware** — it detects the back-ref headers in `ticket.md` and preserves them" — contradicts e1's actual path-based detection.
3. `host/templates/claude/commands/e1-start-story.md:46` — stub case: "the **back-ref headers** and the scope one-liner … are preserved verbatim … without rewriting the **back-ref headers**" — but the detection in the same sentence keys off the path ("nested under a feature (per its path …)").
4. `host/templates/claude/commands/e1-start-story.md:47` — freeform case uses header-absence ("carries **no** back-ref headers") as the stub/freeform discriminator, but e1:128 says the stub signal is "inspecting the **folder path** — nested parentage is the signal." The discriminator wording needs reworking to key off path nesting consistently.
5. `host/templates/claude/commands/e1-start-story.md:136` — validation footer historical note references "the back-ref-header signal."
6. `README.md:318` — status-line row: feat:/epic: shown "when ticket.md carries `Parent Feature` / `Parent Epic` headers" — contradicts README:175 (walk the path).
7. `README.md:319` — feature mode: epic shown "when feature.md carries `**Parent Epic:**`" — same contradiction.

**Why intricate (not auto-fixed).** The fix spans three files (`p4-decompose-feature.md`, `e1-start-story.md`, `README.md`), and the e1:46-47 stub/freeform discriminator and the README:318-319 status-line resolution mechanism require judgment about correct phrasing (they describe a *detection mechanism*, not just a stray phrase). Coordinated multi-file + design judgment → intricate per the audit's simple-fix boundary. Editing the host bodies also requires a follow-on `/f4-regen-framework`.

**Likely root cause.** Proposal #14 (`po-nested-folder-layout`, archived) replaced the back-ref-header model with path-parentage but did not fully scrub the leftover language from p4, e1, and the README.

**Suggested fix direction (for f1 to refine).** Scrub all "back-ref header" references in p4/e1/README to the path-parentage wording the authoritative sources use; reword the e1 stub/freeform discriminator to key off path nesting (nested-under-feature = stub; populated-but-flat = freeform); align README:318-319 status-line resolution language with README:175 (derive feat:/epic: by walking the active-pointer path). Then regen `.claude/`.

## Proposed Changes

[Deferred to /f1-propose-update.]

## Risks / Rollback / Validation Considerations

[Deferred to /f1-propose-update.]
