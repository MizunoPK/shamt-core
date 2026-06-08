# Proposal: init-default-work-tracker-local

**Created:** 2026-06-07
**Status:** Draft (f0 — audit capture, unrefined)

> ⚠️ **f0 draft — unrefined capture.** Seeded by `/f0-draft-proposal` as fast idea capture. Not yet a validated proposal: no formal Proposed Changes table, no Risks/Rollback/Validation, no open-questions dialog, no validation footer. Develop it with `/f1-propose-update init-default-work-tracker-local` before validating.

---

## Scratch Notes (f0 capture)

**Blurb (verbatim):** make the init script have 'local' be the default for the work tracker

**Idea:** In `init-shamt.sh`, the interactive setup prompts for the work-item tracker with `github` as the default. Change the default to `local` so a fresh install defaults to the no-external-tracker (local stories) workflow rather than assuming GitHub Issues.

**Implicated files (informal — confirm/refine at f1):**
- `init-shamt.sh` (~line 248–251) — `prompt_choice WORK_ITEM_TRACKER "…" "github" "ado" "github" "local" "none"`. The 3rd argument (`"github"`) is the default; change it to `"local"`. (`local` is already a legal choice in the list, so this is a default-only change.)
- `shamt-config.example.json` (line 4) — `"work_item_tracker": "github"`. Open question for f1: should the example config default flip to `"local"` too, for consistency with the init default? (The example is the schema-by-example a child copies; the init script is what an interactive install writes. They could diverge intentionally or move together.)

**Why `local`:** a brand-new Shamt install has no tracker wired yet; defaulting to `local` lets the e-flow (stories) work out of the box without an external integration, and the user opts *into* `github`/`ado` deliberately.

**Things f1 should resolve:**
- Whether to also flip `shamt-config.example.json` (and any docs/CHEATSHEET→README quick-reference that state the default tracker) — i.e., the true reference surface for "the default work-item tracker."
- Whether `pr_provider` (currently defaults `github`) should be left as-is (the blurb only names the work tracker — likely leave PR provider untouched, but note the asymmetry).
- Any reference doc / `reference/trackers/` text or `README.md` that documents the default tracker value.

---

## Proposed Changes

*(Placeholder — `/f1-propose-update` builds the formal CREATE/EDIT/DELETE/MOVE table of every canonical file the change touches.)*

---

## Risks

*(Placeholder — filled at f1.)*

---

## Rollback Plan

*(Placeholder — filled at f1.)*

---

## Validation Considerations

*(Placeholder — filled at f1.)*

---

## Open Questions

*(Deferred to f1.)*
