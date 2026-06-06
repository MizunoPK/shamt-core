<!-- REJECTED 2026-06-06 — duplicate / absorbed. This f0 capture's sites (the "Phase 9" ×4 and "original Phase 5 path" ×2 dev-build-phase leaks) were folded into the widened **#03 purge-build-phase-numbers-from-host-bodies** proposal (its load-bearing "widen vs. separate" question resolved to *widen*, user choice 2026-06-06). That proposal now covers all 13 sites across 11 files and corrects the false "only Phase 8 / build-plan leaks" completeness claim this stub flagged. Nothing further to act on here. -->

# Proposal: purge-build-phase-numbers-remaining-sites

**Created:** 2026-06-03
**Status:** Draft (f0 — audit capture, unrefined)
**Proposed by:**
**Project context:**

---

> **f0 capture — unrefined.** This is a quick audit-capture stub from `/f5-audit-framework`. It has **no** resolved Open Questions, **no** formal Proposed Changes table, and **no** validation footer. `/f1-propose-update purge-build-phase-numbers-remaining-sites` ingests it as intake and fleshes it out.

---

## Scratch Notes (f0 capture)

Shipped host instruction prose carries **v2 dev-build phase-number leaks** of the **same class** as the existing `purge-build-phase-numbers-from-host-bodies` proposal — but that proposal's change-list is **closed at 5 rows** and its Completeness-risk note explicitly asserts *"the sweep confirmed these are the only 'Phase 8' / 'build plan' leaks in shipped host bodies."* That completeness claim is **false**: it greps only `Phase 8` / `build plan` and misses two other dev-build-phase strings. Implementing that proposal as-written leaves these sites in place.

**Uncaptured same-class sites surfaced by `/f5-audit-framework` D11:**

- **"Phase 9"** (the v2 dev-build sync-implementation phase) in instruction prose / Notes / a heading:
  - `host/templates/claude/commands/f1-propose-update.md:141` — "The body is identical on both sides — **Phase 9** wires the child-side submission."
  - `host/templates/claude/commands/f4-regen-framework.md:101` — "after pulling master updates (`/sync-import-shamt` in child projects, **Phase 9**)".
  - `host/templates/claude/commands/sync-import-shamt.md:116` — "The pragmatic **Phase 9** rule is subtree-level…".
  - `host/templates/claude/skills/sync-import-shamt/SKILL.md:46` — heading "## Footer contract (**Phase 9** pragmatic rule)".
- **"original Phase 5 path"** (the v2 dev-build phase in which freeform Intake was first built; in the *shipped* Engineer flow Phase 5 = Test, so a reader mismaps it):
  - `host/templates/claude/commands/e1-start-story.md:48` — "this is a pre-existing freeform story (the **original Phase 5 path**)".
  - `CHEATSHEET.md:134` — "Pre-existing freeform stories (the **original Phase 5 path**, no headers) behave unchanged."

All are dated-footer-free instruction prose (validation footers carrying "Phase 8/9 implementation loop" are acceptable and out of scope). Rows under `host/templates/claude/` regenerate into every child `.claude/`, where the dev-build phase number is meaningless — exactly the harm `purge-build-phase-numbers-from-host-bodies` describes.

**Relationship to the existing proposal (load-bearing decision for `/f1`):** prefer to **widen `purge-build-phase-numbers-from-host-bodies`** to (a) re-grep `Phase [0-9]` and `original Phase \d path` across all shipped host bodies + `CHEATSHEET.md`, (b) add these rows, and (c) correct/remove its now-false "only Phase 8 / build-plan leaks" Completeness-risk sentence — then this stub can be rejected/merged as a duplicate. If the two are kept separate, implement this as the existing proposal's **complement**. Replacement strategy mirrors the sibling: drop the dev-build-phase parenthetical/label entirely (surrounding prose already names the real thing), do **not** substitute another number; for the `sync-import-shamt` heading, rephrase to "## Footer contract" (the "pragmatic rule" wording can stay without the phase label). Edits under `host/templates/claude/` need `/f4-regen-framework` (Phase 5) afterward; `CHEATSHEET.md` does not regenerate but lands on next `import-shamt`.

---

## Problem

_(deferred to `/f1-propose-update` — see Scratch Notes above)_

## Proposed Changes

_(deferred to `/f1-propose-update`)_

## Risks

_(deferred)_

## Rollback

_(deferred)_

## Validation Considerations

_(deferred)_

## Open Questions

_(deferred to `/f1-propose-update` — the load-bearing one: widen `purge-build-phase-numbers-from-host-bodies` to absorb these sites, or keep this as a separate complement?)_
