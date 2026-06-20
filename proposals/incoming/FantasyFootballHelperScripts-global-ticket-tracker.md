# Proposal: global-ticket-tracker

**Created:** 2026-06-19
**Status:** Draft (f0 — audit capture, unrefined)
**Proposed by:** FantasyFootballHelperScripts
**Project context:** Tech-stories tickets were created with duplicate ticket IDs (T1/T2/T3) colliding with an existing open epic's T1–T12; the disk-scan allocation rule under-scanned.

> **f0 DRAFT — unrefined capture.** Quick-captured by the framework audit
> or a user; not yet through the open-questions dialog. Run
> `/f1-propose-update global-ticket-tracker` to flesh it out.

---

## Problem

[To be developed by /f1-propose-update from the Scratch Notes below.]

## Scratch Notes (f0 capture)

**Incident that triggered this.** In this project the standing Tech Stories epic's tickets were created with ticket IDs `T1`, `T2`, `T3` — duplicating the open `T1-win-rate-sim-overhaul` epic, which already spans `T1`–`T12` across its epic/features/stories. Three tech-stories tickets had to be hand-renumbered to `T13`/`T14`/`T15` (folder renames + `**Ticket ID:**` lines + sibling cross-refs) to restore the global-uniqueness invariant.

**Root cause (preliminary — to be confirmed in /f1's adversarial diagnosis).** The Ticket IDs rule in `templates/SHAMT_RULES.template.md` §"# Ticket IDs" specifies allocation as `max(existing T-number across the WHOLE epic/feature/story tree) + 1`, scanned from disk with no counter file. The producing command(s) — likely `/ps0-draft` (and possibly the `/pe2-decompose` / `/pf2-decompose` stub allocators) — appear to scan only their own subtree (e.g. just under `epics/tech-stories/`) rather than the full work-root tree, so the standing Tech Stories epic restarts numbering at T1 instead of continuing past the open epic's max. The standing epic + its `bugs` / `quick-wins` features use fixed reserved folder names (no `T{N}-` prefix), which may also confuse a scanner that keys on the prefix.

**Why a "global ticket tracker" of some sort.** The disk-scan `max+1` rule is a stateless allocator that is correct only if *every* producer scans the *entire* work-root tree (`epics/**` plus any legacy flat `stories/`/`features/`) every time. That is fragile: every new producer must reimplement the full-tree walk identically, and any subtree-local scan silently re-collides. Candidate directions to weigh in f1:
  - **(A) Audit + tighten the rule/commands only** — make the §"# Ticket IDs" allocation contract unambiguous that the scan is whole-tree work-root-relative (including the reserved-name standing epic), and fix each producer (`/ps0-draft`, `/pe2-decompose`, `/pf2-decompose`, `/pe1-define`, `/pf1-define`, `/e1-start-story`) to honor it. No new state. Cheapest; keeps the "no counter file" design.
  - **(B) A single shared allocation helper** — one canonical "allocate next ticket ID" routine (described once, referenced by every producer) so the full-tree scan lives in exactly one place instead of being re-described per command. Still disk-scan, still no counter file, but DRY.
  - **(C) A global ticket tracker / counter** — an authoritative `shamt-state/`-style ledger (e.g. `shamt-state/ticket-counter` or a `tickets.json` index) that records the last-allocated ID and/or maps every ID→path. Removes the full-tree-scan-correctness dependency entirely and makes duplicate detection O(1). BUT this is in tension with the framework's stated "No state file, no orchestrator memory — state lives in the filesystem" principle (Principle 1) and the §"# Ticket IDs" "no counter file, never reused" wording — so adopting it means amending those rules and justifying the exception (the `shamt-state/active-*` pointers are the existing precedent for a small state file under `shamt-state/`). Decide in f1 whether the counter is authoritative (write-side source of truth) or merely a derived/advisory index validated against the disk scan.

**Also worth capturing for f1.** Consider a cheap guard: a validation/lint step (or an addition to the relevant command exit criteria, or `/f5-audit-framework` D10 count/claim track) that flags duplicate ticket IDs across the whole tree so a future collision is caught mechanically rather than by a human noticing.

**Implicated canonical files (informal — f1 to confirm the real change set).**
  - `templates/SHAMT_RULES.template.md` §"# Ticket IDs" (allocation contract; standing Tech Stories epic note).
  - `host/templates/claude/commands/ps0-draft.md`, `pe2-decompose.md`, `pf2-decompose.md`, `pe1-define.md`, `pf1-define.md`, `e1-start-story.md` (the ID-allocating / ID-preserving producers).
  - possibly `host/templates/claude/skills/.../SKILL.md` pointers for the above (pointers only — no paraphrase).
  - if direction (C): `shamt-core/CLAUDE.md` §Principles + `shamt-state/` docs, and a new `shamt-state/` ledger convention; reconcile with Principle 1's "no state file" wording.
  - possibly `reference/audit_dimensions.md` (D10) and `init-shamt.sh` / `import-shamt.sh` (the standing-epic seeders) if reserved-name handling changes.

---

## Proposed Changes

A flat list of canonical files the proposal will touch. **Every file the proposal will edit, create, delete, or move must appear here** — Phase 2 (validate-artifact) and Phase 4 (implement-update) both read this list as the source of truth for change scope.

| # | Canonical path | Operation | One-line change description |
|---|----------------|-----------|------------------------------|
| 1 | `shamt-core/templates/SHAMT_RULES.template.md` | EDIT | [What changes in this file and why] |
| 2 | `shamt-core/host/templates/claude/commands/...` | CREATE / EDIT / DELETE / MOVE | [What changes in this file and why] |

**Path discipline:**

- **CREATE** must give the exact target path and a one-line content sketch.
- **EDIT** must name the exact section / heading the edit lands in.
- **DELETE** must justify the removal.
- **MOVE** is recorded as paired CREATE + DELETE rows.
- Generated `.claude/` files are **never** listed. Edits go to canonical sources.

---

## Risks

[To be filled by /f1-propose-update.]

---

## Rollback Plan

[To be filled by /f1-propose-update.]

---

## Validation Considerations

[To be filled by /f1-propose-update.]

---

## Open Questions

Maintain this section as you draft. Surface questions one at a time via `AskUserQuestion` and update the proposal with each answer before moving on.

- [ ] [To be populated by /f1-propose-update.]

---

## Resolved Questions

[Append as questions resolve.]
