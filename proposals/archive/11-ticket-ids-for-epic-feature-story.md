# Proposal: ticket-ids-for-epic-feature-story

**Created:** 2026-06-07
**Status:** Implemented
**Number:** 11
**Proposed by:**
**Project context:**

---

## Problem

Every epic, feature, and story is addressed today by its **slug** — a descriptive kebab-case name resolved to a folder via Principle 1.2 (`/command {slug}` → exact `{root}/{slug}/`, then glob `{root}/{slug}-*/`). Slugs are descriptive but **long and hard to type/remember**; other Agile platforms tag work items with a short ID (`PROJ-123`) precisely because a short stable handle is easier to reference.

This proposal treats every epic/feature/story as a **ticket** with a short, unique **ticket ID**, used alongside the slug. The ID is the easy-to-type addressing handle; the slug stays for readability and back-compat.

**Design decisions resolved with the user (see Resolved Questions):**

- **ID as a folder prefix (folders kept).** Tickets stay folder-based (a story folder holds many artifacts — ticket.md, spec.md, context.md, plan, feedback/). The ID prefixes the folder, mirroring the `proposals/{NN}-{slug}.md` convention: `epics/{ID}-{slug}-{brief}/`, `features/{ID}-{slug}-{brief}/`, `stories/{ID}-{slug}-{brief}/`. (The blurb's flat `{ID}-{slug}.{type}.md` is incompatible with the multi-file story folder.)
- **Global, disk-scanned ID (`T1`, `T2`, …).** One sequence across **all** tickets regardless of type (an epic might be `T1`, its feature `T2`, a story `T3`); the type lives in the folder location, not the ID. Allocated as `max(existing T-number across epics/, features/, stories/) + 1`, **scanned from disk, no counter file, never reused** — exactly the proposal `{NN}` precedent. **Flat** (an ID does not encode its parent).
- **Resolver accepts both ID and slug.** `/command {id-or-slug}` tries the ID glob (`{root}/{ID}-*/`) first, then the slug glob — ID for convenience, slug still works.
- **New-tickets-only (no backfill).** Existing slug-only folders are untouched and keep resolving via the slug glob; only newly-created tickets get IDs. The allocator scans existing IDs from disk, so the first new ticket is `T1` regardless of how many slug-only folders exist.
- **Parent back-refs = `T{N} (slug)`.** Feature/story back-refs carry the stable parent ID plus the slug in parens for readability (e.g. `**Parent Epic:** T1 (auth-overhaul)`).

The change is **centred on the rules file** (the resolution + naming contract is canonical there) plus the artifact-**creating** commands (which allocate IDs + write the new folder names / back-refs) and the two PO templates.

---

## Proposed Changes

The resolution + naming + ID-allocation **contract** is defined once in `templates/SHAMT_RULES.template.md`; the creating commands implement it. Commands that only *consume* an already-created folder resolve via the central Global Story Invariants — but where one **inline-restates** the slug glob (in its Arguments/description), that restatement goes stale and must be updated. An audit of all e/p commands found exactly **8 e-commands** that inline-restate (e2, e3, e3b, e4, e5, e5b, e6, e7 — rows 14–21); their **skills do not** restate (they reference the command), so no skill edit is needed there.

| # | Canonical path | Operation | One-line change description |
|---|----------------|-----------|------------------------------|
| 1 | `templates/SHAMT_RULES.template.md` | EDIT | The canonical contract. (a) **Principle 1.2** resolver → `/command {id-or-slug}`: if the key is an ID (`^T[0-9]+$`), glob `{root}/{ID}-*/`; else treat it as a slug and glob **both** `{root}/{slug}-*/` (slug at the folder start — pre-existing slug-only folders) **and** `{root}/*-{slug}-*/` (slug after an ID prefix — new `{ID}-{slug}-{brief}/` folders), union the matches; halt if ambiguous, halt if none. The both-positions slug glob is what makes "address by slug" keep working for **both** old and ID-prefixed folders. (b) **Global Story Invariants** "Story folder resolution" → the same ID-or-slug, both-positions resolver for `stories/`. (c) **Core files** (line 28) + the **path-map tables** → folder naming `{ID}-{slug}-{brief}/`. (d) A new **"Ticket IDs"** subsection (near Story Artifact Naming, line 367): every epic/feature/story is a ticket with a global `T{N}` ID, allocated `max(existing T№ across epics//features//stories/) + 1` (disk-scanned, no counter file, never reused), prefixing the folder; resolver accepts ID or slug; **new-tickets-only** (existing slug-only folders keep resolving by slug). Modest size add (~+1.5k chars → ~36.6k, still under the 40k D12 budget). |
| 2 | `host/templates/claude/commands/p1-start-epic.md` | EDIT | Allocate a global ticket ID for the new epic; create `epics/{ID}-{slug}-{brief}/epic.md`. Resolve an existing epic by ID-or-slug. |
| 3 | `host/templates/claude/skills/p1-start-epic/SKILL.md` | EDIT | Mirror row 2 (skill summary). |
| 4 | `host/templates/claude/commands/p2-decompose-epic.md` | EDIT | When stubbing each feature, allocate its ticket ID + create `features/{ID}-{slug}-{brief}/`; write the `**Parent Epic:** T{N} (slug)` back-ref using the parent epic's ID. Resolve the parent epic by ID-or-slug. Reference children as `T{N} (slug)` in the parallelization analysis. |
| 5 | `host/templates/claude/skills/p2-decompose-epic/SKILL.md` | EDIT | Mirror row 4. |
| 6 | `host/templates/claude/commands/p3-start-feature.md` | EDIT | Allocate a ticket ID for a new feature; create `features/{ID}-{slug}-{brief}/`; write the `**Parent Epic:** T{N} (slug)` back-ref. **Mode A** (fleshing a `/p2` stub) preserves the stub's existing ID + back-ref. Resolve by ID-or-slug. |
| 7 | `host/templates/claude/skills/p3-start-feature/SKILL.md` | EDIT | Mirror row 6. |
| 8 | `host/templates/claude/commands/p4-decompose-feature.md` | EDIT | When stubbing each story, allocate its ticket ID + create `stories/{ID}-{slug}-{brief}/`; write `**Parent Feature:** T{N} (slug)` + `**Parent Epic:** T{N} (slug)` back-refs. Resolve the parent feature by ID-or-slug. Reference children as `T{N} (slug)` in the parallelization analysis. (Both restates resolution and creates artifacts.) |
| 9 | `host/templates/claude/skills/p4-decompose-feature/SKILL.md` | EDIT | Mirror row 8. |
| 10 | `host/templates/claude/commands/e1-start-story.md` | EDIT | Allocate a ticket ID when creating a freeform story; create `stories/{ID}-{slug}-{brief}/`. **Stub-aware:** a PO-flow story stub from `/p4` already has its ID — preserve it (do not re-allocate). Resolve an existing story by ID-or-slug (the two-key resolver, replacing the current slug-only glob). |
| 11 | `host/templates/claude/skills/e1-start-story/SKILL.md` | EDIT | Mirror row 10. |
| 12 | `templates/epic.template.md` | EDIT | Add the epic's own ticket-ID header (`**Ticket ID:** {ID}`) so it appears in the artifact, not only the folder name. |
| 13 | `templates/feature.template.md` | EDIT | Add the feature's `**Ticket ID:** {ID}` header and update the `**Parent Epic:**` back-ref to the `T{N} (slug)` format. |
| 14 | `host/templates/claude/commands/e2-define-spec.md` | EDIT | Its Arguments section **inline-restates** the slug glob ("Resolved via the global story-folder rules — exact `stories/{slug}/`, then `stories/{slug}-*/` glob"). Update that restatement to the two-key resolver (input `{id-or-slug}`; try `stories/{ID}-*/`, then the slug glob). No artifact creation; resolution-consumer only. |
| 15 | `host/templates/claude/commands/e3-plan-implementation.md` | EDIT | Same inline-resolution-restatement update as row 14. |
| 16 | `host/templates/claude/commands/e3b-write-testing-plan.md` | EDIT | Same inline-resolution-restatement update as row 14. |
| 17 | `host/templates/claude/commands/e4-execute-plan.md` | EDIT | Same inline-resolution-restatement update as row 14. |
| 18 | `host/templates/claude/commands/e5-execute-tests.md` | EDIT | Same inline-resolution-restatement update as row 14. |
| 19 | `host/templates/claude/commands/e5b-write-manual-testing-plan.md` | EDIT | Same inline-resolution-restatement update as row 14. |
| 20 | `host/templates/claude/commands/e6-review-changes.md` | EDIT | Same inline-resolution-restatement update as row 14 (story-mode slug). |
| 21 | `host/templates/claude/commands/e7-resolve-feedback.md` | EDIT | Same inline-resolution-restatement update as row 14. |

Row count: **21 > 10 → Phase 3 (`/f2-plan-update-implementation`) required.** Natural phase grouping: (1) the rules-file contract; (2) PO commands+skills p1–p4 + the two templates; (3) e1 (create) + e2–e7/e3b/e5b (resolution-restatement updates, rows 14–21). The e-command **skills** were checked and do **not** inline-restate resolution (they reference the command body), so they need no edit — only the 8 e-command bodies do.

**Paired files:** every command↔skill pair (rows 2↔3, 4↔5, 6↔7, 8↔9, 10↔11) moves together. The templates (12, 13) pair with the creating commands that fill them (p1 ↔ epic.template; p3 ↔ feature.template). Rows 14–21 are resolution-consumer commands whose skills are unaffected.

---

## Risks

- **Addressing-contract change (the load-bearing one).** Principle 1.2 + Global Story Invariants define how *every* phase-per-command flow resolves an artifact. Getting the two-key resolver wrong (ambiguity handling, ID-vs-slug precedence) breaks resumability across the whole framework. Mitigation: the resolver is defined once centrally; the 8 commands that inline-restate the glob are enumerated as rows 14–21 (each updated to the two-key form); validation walks the resolver against both an ID-prefixed and a slug-only folder.
- **Backward compatibility + slug-glob position (load-bearing).** "Address by slug" must work for both an old slug-only folder (`{slug}-{brief}/`, slug at the start) **and** a new ID-prefixed folder (`{ID}-{slug}-{brief}/`, slug after the prefix). The current single glob `{root}/{slug}-*/` only matches slug-at-start, so the resolver must glob **both** `{slug}-*/` and `*-{slug}-*/` and union them — otherwise a new ticket can't be addressed by its bare slug. Mitigation: row 1 specifies the both-positions slug glob; validation tests addressing an ID-prefixed folder by its bare slug.
- **Global allocator correctness.** `max(existing T№) + 1` must scan **all three** roots (`epics/`, `features/`, `stories/`) so the sequence is genuinely global and never reused. A scan that misses a root would reuse an ID. Mitigation: the allocator spec names all three roots; the disk-scan parses a leading `^T[0-9]+-` run (slug-only folders contribute nothing → first ID is `T1`).
- **Stub-handoff ID preservation.** `/p2`/`/p4` allocate a child's ID at stub time; `/p3`/`/e1` must *preserve* that ID (not re-allocate) when fleshing the stub out. A double-allocation would orphan the stub's folder. Mitigation: the creating commands distinguish "new ticket" (allocate) from "flesh out existing stub" (preserve), keyed off the existing folder/back-ref.
- **Rules-file size (D12).** The new Ticket IDs subsection + resolver edits grow the rules file (~+1.5k chars). Confirmed still under the 40,000 D12 budget (~36.6k projected). If it ever approached the budget, `/trim-rules-file` is available.
- **No backfill = mixed state.** A project will have some slug-only and some ID-prefixed folders for a while. Accepted (the resolver handles both); documented as the intended new-tickets-only behavior.

---

## Rollback Plan

`git revert <commit-sha>` restores the slug-only contract (Principle 1.2, Global Story Invariants, the two templates) and removes ID allocation from the creating commands; `/f4-regen-framework` re-propagates the host bodies. Any ID-prefixed folders already created in a child remain on disk and lose no data, but the **reverted** resolver only globs `{root}/{slug}-*/` (slug-at-start), so an ID-prefixed folder would resolve only by an **exact match** on its full folder name (`/command T7-foo-bar`), not by its bare slug — the user renames such a folder to drop the prefix if they want bare-slug addressing back. Children pick up the reverted contract on next `/sync-import-shamt`.

---

## Validation Considerations

- **Two-key resolver correctness (highest-risk).** Validate the Principle 1.2 + Global Story Invariants resolver against three cases: an ID-prefixed folder addressed by ID; the same addressed by slug; a pre-existing slug-only folder addressed by slug (must still resolve — backward compat). Ambiguity (two matches) halts; no match halts.
- **Global allocation never reuses.** Confirm the allocator scans all three roots (`epics/`, `features/`, `stories/`) and parses `^T[0-9]+-`; a project with only slug-only folders allocates `T1` first.
- **Stub ID preservation.** `/p3`/`/e1` fleshing out a `/p2`/`/p4` stub must keep the stub's ID, not re-allocate. Validate the "new vs flesh-out" branch.
- **Back-ref format consistency.** All `**Parent Epic:**` / `**Parent Feature:**` back-refs across templates + the commands that write them use `T{N} (slug)`.
- **Command↔skill parity.** Rows 2↔3, 4↔5, 6↔7, 8↔9, 10↔11 describe the same body (D2).
- **e-command resolution restatements (rows 14–21).** Confirm each of the 8 enumerated e-commands (e2, e3, e3b, e4, e5, e5b, e6, e7) has its inline slug-glob restatement updated to the two-key form, and that their skills (which don't restate) remain untouched. A residual `stories/{slug}-*/`-only restatement in any of them is a D2 finding.
- **D12 size.** After the rules-file edits, `wc -m templates/SHAMT_RULES.template.md` stays ≤ 40,000.
- **Affected surfaces.** `templates/SHAMT_RULES.template.md`, `templates/epic.template.md`, `templates/feature.template.md`, and the p1–p4 + e1 command/skill bodies under `host/templates/claude/` (the latter regenerate via `/f4`). **>10 rows → Phase 3 plan required.**

---

## Open Questions

(none remaining)

---

## Resolved Questions

<!-- Drafting-only log -->

- ~~Q1 (load-bearing): how does the ID integrate with the structure, given the blurb's flat `{ID}-{slug}.{type}.md` collides with the multi-file story folder?~~ → A: **ID as a folder prefix; folders kept** (user, 2026-06-07). `epics/{ID}-{slug}-{brief}/`, `features/{ID}-{slug}-{brief}/`, `stories/{ID}-{slug}-{brief}/` — mirrors `proposals/{NN}-{slug}.md`.
- ~~Q2 (load-bearing): what does an ID look like and how is it allocated?~~ → A: **Global disk-scanned `T{N}`** (user, 2026-06-07). One sequence across all tickets; type lives in the folder; `max(existing T№ across the three roots) + 1`, no counter file, never reused; **flat** (no parent encoding).
- ~~Q3 (load-bearing): what input does a command accept — ID, slug, or both?~~ → A: **Both** (user, 2026-06-07). Resolver tries the ID glob first, then the slug glob.
- ~~Q4 (load-bearing): backfill existing slug-only artifacts, or new-tickets-only?~~ → A: **New-tickets-only, no backfill** (user, 2026-06-07). Existing folders keep resolving by slug; the allocator scans from disk so the first new ID is `T1`.
- ~~Q5 (load-bearing): what do parent back-refs reference now?~~ → A: **`T{N} (slug)`** (user, 2026-06-07) — the stable parent ID plus the slug in parens for readability.

---

---
Validated 2026-06-08 — 3 rounds, 1 adversarial sub-agent confirmed (round 1 added the 8 e-command resolution-restatement rows the table had deferred — e2/e3/e3b/e4/e5/e5b/e6/e7, rows 14–21; round 2 fixed the two-key resolver to glob the slug at BOTH positions — `{slug}-*/` for old folders and `*-{slug}-*/` for slug-after-ID-prefix — without which an ID-prefixed folder could not be addressed by its bare slug, plus corrected the Rollback glob claim; p1/p2/p3 skills verified not to restate resolution, p4/e1 skills covered by their mirror rows).
