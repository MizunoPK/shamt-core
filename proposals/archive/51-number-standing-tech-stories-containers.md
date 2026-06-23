# Proposal: number-standing-tech-stories-containers

**Created:** 2026-06-22
**Status:** Implemented
**Number:** 51
**Proposed by:**
**Project context:**

---

## Problem

The standing **Tech Stories** epic and its two standing features (**Bugs**, **Quick Wins**) are the one deliberate exception to Shamt's "every epic / feature / story is a numbered ticket" rule. Today they are seeded under **fixed reserved folder names with no ticket ID** — `epics/tech-stories/`, `.../features/bugs/`, `.../features/quick-wins/` — and `templates/SHAMT_RULES.template.md` §Ticket IDs explicitly excludes them from allocation: *"The reserved standing-epic folders (`tech-stories`, `bugs`, `quick-wins`) carry no `T{N}-` prefix and contribute zero."* The same carve-out is stated in §Standing Tech Stories epic (*"under fixed reserved folder names … not the `{ID}-{slug}-{brief}` convention, since they carry no ticket ID"*) and mirrored in `README.md` (§Standing Tech Stories epic note).

The seeding happens in two shell scripts: `init-shamt.sh` (`seed_tech_stories_epic()`, ~line 521) writes `$root/epics/tech-stories` + `features/{bugs,quick-wins}` at install time, and `import-shamt.sh` (~line 412) re-seeds the same fixed paths create-if-absent on each sync.

The user wants the standing containers to **take the first available ticket numbers upon `shamt` init or import** — i.e., the Tech Stories epic and its Bugs / Quick Wins features should be allocated real `T{N}` ticket IDs (folder prefixes) like every other ticket, rather than being a permanent unnumbered special case. This removes the lone carve-out in the ticket-ID rule, makes the standing containers first-class numbered tickets, and (at a fresh init, where the tree is empty) gives them the foundational low numbers `T1` / `T2` / `T3`. Reserved-name addressing (`/ps0-draft bugs`) must keep working without the user ever typing the number.

---

## Proposed Changes

A flat list of canonical files the proposal will touch. **Every file the proposal will edit, create, delete, or move must appear here** — Phase 2 (validate-artifact) and Phase 4 (implement-update) both read this list as the source of truth for change scope.

| # | Canonical path | Operation | One-line change description |
|---|----------------|-----------|------------------------------|
| 1 | `shamt-core/init-shamt.sh` | EDIT | In `seed_tech_stories_epic()`: add a `max(T{N})` disk-scan helper over the work tree, allocate three consecutive IDs, and create the containers as `epics/{ID}-tech-stories/`, `.../features/{ID}-bugs/`, `.../features/{ID}-quick-wins/` (still create-if-absent / idempotent; skip if a reserved-slug container already exists under any prefix). |
| 2 | `shamt-core/import-shamt.sh` | EDIT | Re-seed block (~line 412): replace the create-if-absent block with a three-way branch keyed on the reserved-slug container's state — **absent** → seed numbered (shared `max+1` scan); **present but unnumbered** → migrate: `mv` the epic + two feature folders to their `{ID}-{slug}` form (next free numbers) and **rewrite** `shamt-state/active-{epic,feature,story}` pointers + any in-progress ticket paths whose prefix changed; **already numbered** → no-op (idempotent across repeated imports). Per OQ1 (rename-on-import). |
| 3 | `shamt-core/templates/SHAMT_RULES.template.md` | EDIT | §Ticket IDs — remove the "reserved standing-epic folders … carry no `T{N}-` prefix and contribute zero" carve-out; state that the standing containers are now numbered tickets that participate in the max-scan. §Standing Tech Stories epic — replace "fixed reserved folder names … not the `{ID}-{slug}-{brief}` convention, since they carry no ticket ID" with "numbered `{ID}-{reserved-slug}` folders (ID prefix + reserved slug tail, no `-{brief}`)" and note reserved-name resolution globs the ID prefix. §PO-tree resolution — add the reserved-folder resolution glob (`epics/*-tech-stories/`, `.../features/*-{bugs|quick-wins}/`). |
| 4 | `shamt-core/host/templates/claude/commands/ps0-draft.md` | EDIT | Tech-story-mode resolution (Prerequisites ~line 31 + Step ~line 38, ~line 44): resolve `bugs` / `quick-wins` / the `{tech-stories-folder}` placeholder by globbing the reserved slug under any `T{N}-` prefix (e.g. `epics/*-tech-stories/features/*-bugs/`), not the bare literal `features/bugs/`. |
| 5 | `shamt-core/host/templates/claude/commands/e9-finalize-story.md` | EDIT | Tech-Stories archive path (~line 82) + epic re-derivation (~line 86): confirm the `{tech-stories-folder}` / `{bugs\|quick-wins}` placeholders resolve under the numbered prefix; adjust the literal-glob wording if needed. |
| 6 | `shamt-core/README.md` | EDIT | §Standing Tech Stories epic note (~line 155): update `epics/tech-stories/` … "fixed reserved names" to the numbered `{ID}-tech-stories` form. Spot-check the statusline note (~line 182) and §linking note (~line 162) for the literal folder name. |

**Path discipline:**

- **CREATE** must give the exact target path and a one-line content sketch.
- **EDIT** must name the exact section / heading the edit lands in.
- **DELETE** must justify the removal.
- **MOVE** is recorded as paired CREATE + DELETE rows.
- Generated `.claude/` files are **never** listed. Edits go to canonical sources.

Row count = 6 canonical file operations (≤ 10) — no Phase 3 plan required. `ps0-draft`'s SKILL Protocol is the command-body pointer (not a paraphrase), so a command-step edit needs **no** paired SKILL edit; SKILL frontmatter carries no literal `epics/tech-stories/` path, so it is unaffected.

Note: `init-shamt.sh` and `import-shamt.sh` are top-level canonical files synced by `import-shamt` (master-owned sync set), not under `host/templates/claude/`, so they are **not** regenerated into `.claude/` — they take effect directly on the next init/import. Listed here for completeness; Phase 5 regen does not touch them.

---

## Risks

- **Regression risk (resolution breakage).** The reserved-name lookups (`/ps0-draft bugs`, the `{tech-stories-folder}` placeholder in `ps0-draft` / `e9`) currently assume the bare literal folder `epics/tech-stories/`. If any site still matches the literal name after the rename, tech-story filing/finalize breaks. Mitigation: convert every reserved-name resolution to a slug-tail glob (`*-tech-stories`, `*-bugs`, `*-quick-wins`) and exercise the `/ps0-draft bugs` path.
- **Collision risk at import-into-populated-tree.** If the standing epic is seeded into a child that already holds `T{N}` tickets, hardcoding `T1/T2/T3` would collide with the §Ticket IDs uniqueness halt-check. Mitigation: the seeder does a real `max+1` disk-scan (not a hardcode), so it always allocates the next free numbers.
- **Drift risk.** Two seeders (`init` + `import`) must implement identical allocation; the rule text (§Ticket IDs, §Standing Tech Stories epic) and `README` must agree on the new numbered form. Mitigation: a single shared scan helper if both scripts can share it; otherwise keep the logic byte-aligned and verify in the D2/D7 audit pass.
- **Child-project compatibility / migration risk (active, per OQ1 = rename-on-import).** `import-shamt` renames already-installed children's unnumbered `epics/tech-stories/` (+ features) to the numbered form. This `mv` changes the path prefix of any **in-progress** ticket folders under the standing epic and invalidates the absolute paths stored in `shamt-state/active-{epic,feature,story}`. Mitigations: (a) the migration must rewrite those pointer files (replace old prefix → new prefix) in the same step; (b) it must be **idempotent** — detect "already numbered" and no-op so repeated imports do not re-rename or re-number; (c) it runs only when the container is present-but-unnumbered, so a clean fresh init (handled by `init-shamt.sh`, which halts on re-init) never hits the rename path.
- **Statusline drift during migration.** The statusline reads `shamt-state/active-*`; if the pointer rewrite is missed, the active-story line breaks until the next `/ps*`/`/e1` pointer refresh. Covered by the pointer-rewrite mitigation above.

---

## Rollback Plan

1. `git revert <commit-sha>` on the canonical edit commit.
2. Run `/f4-regen-framework` to propagate the revert into `.claude/` (only the `ps0-draft` / `e9` / README-derived host files; the two shell scripts revert directly).
3. Child-side: re-run `/sync-import-shamt` to pull the reverted scripts. Any standing container *already created numbered* (`T{N}-tech-stories` / `T{N}-bugs` / `T{N}-quick-wins`) by the new seeder will **not** resolve under the reverted logic — the reverted command bodies / rules match the bare literal reserved names (`tech-stories` / `bugs` / `quick-wins`), not the numbered glob — so the revert message must instruct any affected child operator to **rename each numbered standing container back to its bare reserved name** to restore resolution. (A child that prefers to keep the numbered form can leave it as-is — there is no data loss either way; only the bare-name reserved-slug resolution is at stake.)
4. Communication: tell installed-child operators on the next sync.

---

## Validation Considerations

Dimension hints for the Phase 2 validation loop.

- **Problem clarity** — "first available ticket number" must be read as `max(existing T{N}) + 1` (disk-scan), which at a fresh init resolves to `T1/T2/T3` because the tree is empty — not a hardcoded `T1/T2/T3`.
- **Change-list completeness** — the highest-risk omission is a reserved-name resolution site still matching the bare literal `tech-stories`/`bugs`/`quick-wins` folder. Grep every `host/templates/claude/` body + the rules + README for the literal strings and confirm each is either a placeholder (`{tech-stories-folder}`, `{bugs|quick-wins}`) that resolves via glob, or an updated glob. Confirm the two shell seeders stay byte-aligned on the allocation logic (D2/D7).
- **Risk coverage** — verify the import-into-populated-tree collision path, plus the rename migration's two load-bearing properties: **idempotency** (re-import does not re-rename / re-number an already-numbered container) and **pointer rewrite** (`shamt-state/active-*` + in-progress ticket paths updated in lockstep with the `mv`).
- **Rollback feasibility** — purely additive at the rule level (removing a carve-out) + script edits; revert is clean. A numbered container created before revert is not auto-renamed back, so it will **not** resolve under the reverted bare-literal logic until a child operator renames it back to its bare reserved name (the revert message must say so); no data is lost either way.
- **Affected surfaces** — scripts (`init`/`import`), rules (`SHAMT_RULES.template.md` §Ticket IDs + §Standing Tech Stories epic + §PO-tree resolution), commands (`ps0-draft`, `e9-finalize-story`), README. No personas, no reference docs, no templates beyond the rules file.
- **Propagation plan** — `ps0-draft` / `e9` host-body edits need `/f4-regen-framework`; the two shell scripts take effect on the next init/import directly. Already-installed children pick up the new scripts on `/sync-import-shamt`.

---

## Open Questions

_None — all resolved._

---

## Resolved Questions

<!-- Drafting-only log. -->

- ~~OQ1: For already-installed children with an unnumbered standing Tech Stories epic, should `import-shamt` leave it unnumbered (new seeds only) or rename it to the numbered form?~~ → A: **Rename on import.** `import-shamt` migrates the existing unnumbered containers to `{ID}-{slug}` so all children converge on numbered standing tickets. The rename must be idempotent (no-op once numbered) and must rewrite `shamt-state/active-*` pointers + any in-progress ticket paths whose prefix changes. (Chosen over the lower-risk "no migration" option because the user wants convergence "upon init **or** import," not just on fresh installs.)

---

Validated 2026-06-22 — 2 rounds, 1 adversarial sub-agent confirmed
