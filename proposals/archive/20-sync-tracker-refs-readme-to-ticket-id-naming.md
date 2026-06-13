# Proposal: sync-tracker-refs-readme-to-ticket-id-naming

**Created:** 2026-06-13
**Status:** Implemented
**Number:** 20
**Proposed by:** [master-local]
**Project context:** [master-local]

---

## Problem

Proposal **#11 (ticket-ids-for-epic-feature-story)** changed the canonical
folder-naming + resolution contract to `{ID}-{slug}-{brief}/` folders addressed
by **ticket ID *or* slug** (the both-positions union glob), defined in
`templates/SHAMT_RULES.template.md` (Principle 1.2, Global Story Invariants, the
`# Ticket IDs` section, Core files, and the path-map tables). The post-#11
`/f5-audit-framework` captured a **D9/D2 cross-doc-consistency ripple**: several
canonical docs **outside #11's 21-file scope** still describe the **old slug-only**
naming/resolution. Re-confirmed still-stale on disk (line numbers have shifted
since capture; cited by content):

- **`reference/trackers/local.md`** — **one outright-stale factual claim**: *"the
  folder name is `{slug}-{brief}`"* (now `{ID}-{slug}-{brief}` for new tickets).
  Plus slug-only resolution globs (`stories/{slug}-*/ticket.md`,
  `epics/*/features/{slug}-*/feature.md`, `epics/{slug}-*/epic.md`) at three
  spots that already say "resolved per §PO-tree resolution".
- **`reference/trackers/ado.md`** + **`reference/trackers/github.md`** — the raw-
  payload write path shown as `stories/{slug}-*/raw/issue.json` (+ `epics/…` /
  `features/…` PO-flow variants) — the `e1`/`p1`/`p3` bodies now resolve by
  ID-or-slug.
- **`README.md`** — the command tables list `/command {slug}`, and the prose
  ("Every command above is **slug-first** … pass a slug …") predates the
  ID-or-slug handle.

**Documentation-consistency only — no behavior change.** All targets are canonical
(`reference/trackers/`, `README.md`); none under `.claude/`.

**Severity nuance (drives the scope question):** only `local.md`'s *"the folder
name is `{slug}-{brief}`"* is **outright wrong**. The slug-only **globs** are not
*wrong* — slug-position is one of the union globs the §PO-tree contract resolves,
and every glob already says "per §PO-tree resolution" — they are merely
**incomplete** (they don't show the ID position). The README `{slug}` examples are
likewise valid common usage. So the change ranges from "fix the one stale line" to
"make every slug-only reference id-or-slug-complete" — settled in Open Questions.

**Orthogonality:** the work-tree base of these paths is already handled by #18's
work-root convention (bare `stories/…` paths are work-root-relative); this proposal
is purely the **ID-naming** axis, independent of #18.

---

## Proposed Changes

**Resolved approach (comprehensive):** make every slug-only reference
id-or-slug-complete, aligning each to the `{ID}-{slug}-{brief}` + ID-or-slug
contract that `templates/SHAMT_RULES.template.md` (§PO-tree resolution, # Ticket
IDs) already defines — the globs *defer* to §PO-tree, so the fix is to show the
new folder shape and the ID-or-slug handle. README tables keep `{slug}` as
common-usage shorthand + one note. All edits are documentation; no behavior change.

| File | Op | What |
|---|---|---|
| `reference/trackers/local.md` | EDIT | Fix the **outright-stale** factual claim "the folder name is `{slug}-{brief}`" → `{ID}-{slug}-{brief}` for new tickets (pre-ID folders stay `{slug}-{brief}`). Update the slug-only resolution globs at the three spots (`epics/{slug}-*/epic.md`, `epics/*/features/{slug}-*/feature.md`, `stories/{slug}-*/ticket.md`) to show the `{ID}-{slug}-{brief}` shape and note "located by ticket ID or slug per §PO-tree resolution". |
| `reference/trackers/ado.md` | EDIT | Update the raw-payload write path `stories/{slug}-*/raw/issue.json` (+ `epics/…` / `features/…` PO-flow variants) to the `{ID}-{slug}-{brief}/raw/issue.json` shape resolved by ID or slug per §PO-tree resolution. |
| `reference/trackers/github.md` | EDIT | Same raw-payload glob update (`stories/{slug}-*/raw/issue.json` → ID-or-slug shape). |
| `README.md` | EDIT | Keep the ~25 `/command {slug}` table rows; add **one note** (by the command tables) that every command also accepts a **ticket ID** (`/command {id-or-slug}`); fix the prose at `:122` ("Every command above is **slug-first** … pass a slug …") to **ID-or-slug-first** wording. (Leave the tracker-plumbing "slug-to-ID parse" untouched — that's the tracker work-item ID, a different concept.) |

Four canonical files (`reference/trackers/` ×3 + `README.md`); ≤ 10 rows → no Phase 3.
The rules file is **not** touched (it already defines the contract correctly), so D12
is unaffected.

---

## Risks

- **Re-introducing or missing a slug-only form.** A doc-sync could leave a stray
  slug-only reference or mis-state the union glob. *Mitigation:* the globs defer to
  §PO-tree resolution (the single source of truth) — align wording to it, not to a
  re-invented glob; post-implementation `/f5-audit-framework` D2/D4 sweep + a grep
  for residual `{slug}-{brief}` folder-name claims and bare slug-only globs.
- **Over-correcting valid shorthand.** Changing every `{slug}` everywhere could
  make docs verbose/less readable. *Mitigation:* the resolved scope keeps README
  table `{slug}` shorthand (+ one note) and only rewords genuinely-stale/incomplete
  spots; the "slug-to-ID parse" tracker-plumbing phrase is explicitly preserved
  (different "ID").
- **Low blast radius.** Documentation-only, no command/skill/script behavior
  changes, no rules-file edit — the worst case is a doc still slightly imprecise,
  caught by the next audit.

## Rollback Plan

Single squash commit (`shamt-core: land #20 …`) via `/f6-archive-proposal`;
`git revert` restores the prior tracker-doc + README wording. No code, no scripts,
no master data. Fully reversible.

## Validation Considerations

- **Outright-stale line fixed.** Confirm `local.md` no longer claims "the folder
  name is `{slug}-{brief}`" as the current convention.
- **Globs reflect id-or-slug.** The updated `local.md` / `ado.md` / `github.md`
  globs show the `{ID}-{slug}-{brief}` shape and the ID-or-slug handle (or defer
  cleanly to §PO-tree resolution) — no bare slug-only glob presented as the whole
  rule.
- **README accuracy.** The note that commands accept a ticket ID is present; the
  `:122` prose says id-or-slug-first; the ~25 `{slug}` table rows are intentionally
  kept (shorthand); the tracker-plumbing "slug-to-ID parse" phrase is untouched.
- **No contract drift (D2/D4).** The reworded globs agree with
  `templates/SHAMT_RULES.template.md` §PO-tree resolution / # Ticket IDs; every
  §PO-tree cross-reference still resolves.
- This proposal is validated (`/validate-artifact`) before `/f3`.

---

## Resolved Questions

- **OQ1 — Scope.** *Resolved (user):* **Comprehensive.** Make every slug-only
  reference id-or-slug-complete across `local.md` / `ado.md` / `github.md` +
  `README.md`, not just the one outright-stale `local.md` line — fully resolving
  the D9/D2 ripple the audit keeps re-flagging.
- **OQ2 — README command-table treatment.** *Resolved (user):* **keep `{slug}` +
  one note + fix the prose.** Leave the ~25 `/command {slug}` rows as common-usage
  shorthand; add a single note that commands also accept a ticket ID; reword the
  `:122` "slug-first" prose to id-or-slug-first. (Not 25 verbose `{id-or-slug}`
  substitutions.)

---

## Open Questions

None — all resolved above.

---
Validated 2026-06-13 — 1 round, 1 adversarial sub-agent confirmed
