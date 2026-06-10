# Proposal: sync-tracker-refs-readme-to-ticket-id-naming

**Status:** Draft (f0 — audit capture, unrefined)

> ⚠️ **f0 audit capture.** This is an unrefined stub created by `/f5-audit-framework` to record an intricate finding so the audit could continue. It has no formal Proposed Changes table, no open-questions dialog, and no validation footer. Run `/f1-propose-update sync-tracker-refs-readme-to-ticket-id-naming` to develop it into a full proposal before implementing.

## Scratch Notes (f0 capture)

Captured by the post-implementation `/f5-audit-framework` of proposal **#11 ticket-ids-for-epic-feature-story** (D9/D2 cross-doc-consistency ripple).

#11 changed the canonical folder-naming + resolution contract to `{ID}-{slug}-{brief}/` folders addressed by **ticket ID or slug** (both-positions glob), defined in `templates/SHAMT_RULES.template.md` (Principle 1.2, Global Story Invariants, the new `# Ticket IDs` section, Core files + the path-map tables). But several canonical docs **outside #11's 21-file scope** still describe the OLD slug-only naming/resolution and are now inconsistent:

1. **`reference/trackers/local.md`**
   - `:27` states *"the folder name is `{slug}-{brief}`"* — now wrong for new tickets (`{ID}-{slug}-{brief}`).
   - `:23`, `:33`, `:71` show resolution globs `stories/{slug}-*/ticket.md`, `features/{slug}-*/feature.md`, `epics/{slug}-*/epic.md` without the ID position / ID-or-slug handle.
2. **`reference/trackers/ado.md:56`** and **`reference/trackers/github.md:50`** show the raw-payload write path as `stories/{slug}-*/raw/issue.json` (and the PO-flow `epics/…` / `features/…` variants) — but the `e1`/`p1`/`p3` command bodies now write to `{ID}-{slug}-{brief}/raw/issue.json`.
3. **`README.md`** — the command tables list `/command {slug}` and line 106 calls the commands "slug-first"; commands now accept `{id-or-slug}`.

**Fix direction:** update these `reference/trackers/*.md` + `README.md` mentions to reflect the `{ID}-{slug}-{brief}` naming and ID-or-slug (both-positions) resolution, consistent with the `# Ticket IDs` contract — noting **new-tickets-only** back-compat (existing slug-only folders still resolve via the slug glob, so `{slug}-*/`-style references aren't *wrong*, just incomplete; local.md:27's flat factual claim is the one outright-stale line). **Documentation-consistency only — no behavior change.** All implicated files are canonical (`reference/trackers/`, `README.md`); none under `.claude/`.

## Problem

[To be developed by /f1-propose-update from the Scratch Notes above.]

## Proposed Changes

[To be developed by /f1-propose-update — table of canonical files touched, CREATE/EDIT/DELETE/MOVE.]

## Risks

[To be developed by /f1-propose-update.]

## Rollback

[To be developed by /f1-propose-update.]

## Validation Considerations

[To be developed by /f1-propose-update.]
