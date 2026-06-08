# Proposal: ticket-ids-for-epic-feature-story

**Created:** 2026-06-07
**Status:** Draft (f0 — audit capture, unrefined)
**Number:** [NN — master-side only; assigned by /f1-propose-update]
**Proposed by:**
**Project context:**

> **f0 DRAFT — unrefined capture.** Quick-captured by the framework audit
> or a user; not yet through the open-questions dialog. Run
> `/f1-propose-update ticket-ids-for-epic-feature-story` to flesh it out.

---

## Scratch Notes (f0 capture)

Update epic/feature/story creation to make use of **IDs in addition to slugs**.

Motivation: a full slug is hard to type out and remember. Want a short ID like the way other Agile platforms tag tickets (e.g. `PROJ-123`).

Core idea:

- Consider every epic, feature, and story to each be a **"ticket."** We are just establishing parent and child tickets through the epic / feature / story structure.
- Every ticket should have a **unique ID**.
- Tickets are represented on disk as `{ID}-{slug}.{type}.md` where `{type}` is one of `epic` / `feat` / `story`.

Implicated canonical surfaces (informal — to be confirmed in f1):

- PO flow commands/skills that create the artifacts: `p1-start-epic`, `p2-decompose-epic`, `p3-start-feature`, `p4-decompose-feature` (host command + skill pairs).
- Engineer flow intake that creates the story folder: `e1-start-story`.
- Templates: `epic.template.md`, `feature.template.md`, `ticket.template.md` (and any folder/back-ref conventions — Parent Epic / Parent Feature headers).
- Slug-resumability mechanics across all phase-per-command flows — every command currently resolves a `{slug}` to a folder; introducing an ID changes the addressing/resolution contract (Principle 1).
- `SHAMT_RULES.template.md` wherever the slug/folder naming convention is described.
- Possibly the decompose commands' parallelization analysis output and the back-ref headers.

Open threads to resolve in f1 (not decided here):

- How is the unique ID generated/allocated? (Monotonic counter? Per-type prefix like `E-`/`F-`/`S-`? Global across all tickets vs per-parent?) Is there a counter file, or is it scanned from disk like the proposal `{NN}` convention?
- Does the ID replace the slug in folder/file names or sit alongside it? The blurb says `{ID}-{slug}.{type}.md` — confirm this is the file naming and whether folders also change.
- How do commands accept the ID as input — resolve `{ID}` → folder the same way `{slug}` resolves today? Both accepted?
- Relationship between parent/child IDs — does a child ID encode its parent (hierarchical) or is it flat?
- Migration: do existing child projects with slug-only artifacts need a backfill, or is this new-tickets-only?

---

## Proposed Changes

[Deferred to /f1-propose-update — no formal change list captured at f0.]

| # | Canonical path | Operation | One-line change description |
|---|----------------|-----------|------------------------------|
| 1 | [TBD] | [TBD] | [TBD] |

---

## Risks

[Deferred to /f1-propose-update.]

---

## Rollback Plan

[Deferred to /f1-propose-update.]

---

## Validation Considerations

[Deferred to /f1-propose-update.]

---

## Open Questions

[Deferred to /f1-propose-update — f0 runs no open-questions dialog.]
