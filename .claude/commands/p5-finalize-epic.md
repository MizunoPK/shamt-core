---
description: Phase 5 (Finalize) of the Shamt PO flow at the Epic altitude — guard that every child feature/story is finalized, commit, mark the epic done via the active tracker, and move the done epic into epics/archive/ (move-epic-only on the flat layout)
---

# /p5-finalize-epic

**Purpose:** Run the terminal PO-flow command at the Epic altitude. Confirm every child feature/story of the epic has been finalized, commit, mark the epic done via the active tracker profile, and move the done epic folder into `epics/archive/` — analogous to `/f6-archive-proposal` moving an implemented proposal into `proposals/archive/`.

**Recommended model:** Cheap (Haiku). Finalize is mechanical — evaluate the children-done guard, run one tracker-close command, flip a status line, move a folder, commit. No design judgment. See [`reference/model_selection.md`](../../../../reference/model_selection.md).

---

## Usage

```
/p5-finalize-epic {slug}
```

## Arguments

- `{slug}` (required) — epic slug or ticket ID (`T{N}`). Resolves the epic folder exact-then-glob — `epics/{slug}/`, then `epics/{slug}-*/` (the `{ID}-{slug}-{brief}` folder shape; matches at most one, halt on multiple). The `epics/archive/` subdirectory is **excluded** from resolution.
- `--tracker={ado|github|local}` (optional) — one-off override of the project's default `work_item_tracker`, per [`reference/trackers/_contract.md`](../../../../reference/trackers/_contract.md).

## Prerequisites

- `.shamt-core/shamt-config.json` exists at the project root. If not, halt and direct the user to `init-shamt`.
- The epic folder resolves to exactly one directory under `epics/` (not `epics/archive/`). Halt on zero or multiple matches.
- `epics/archive/{resolved-folder-name}` does **not** already exist. If it does, halt and report — this epic was already finalized.

## Step-by-step

### Step 1 — Guard: every child feature/story finalized

The epic finalizes only after all its work is done.

1. Find the epic's children. On the **current flat layout**, children live in sibling top-level dirs linked by back-ref headers: features in `features/*/feature.md` carrying `**Parent Epic:** {this-epic-slug}`, and stories in `stories/*/ticket.md` carrying `**Parent Epic:** {this-epic-slug}`.
2. For each child, confirm it is finalized: its artifact carries `**Status: Done**` (written by `/e8-finalize-story` for stories; features close implicitly when all their stories are done — confirm each child story of each child feature is `**Status: Done**`).
3. If any child is not finalized, **halt** and list the unfinished children with their remediation (`/e8-finalize-story {story-slug}` for each). Do not proceed.

### Step 2 — Guard: explicit confirmation

Present, in one message: (a) the epic and its finalized children, (b) how the epic will be marked done (per the active profile, Step 4), (c) the `epics/{slug}/ → epics/archive/{slug}/` move, and (d) the local `**Status: Done**` marker for `epic.md`. **Wait for an explicit "yes"** — the remote close and the folder move are not silently performed.

### Step 3 — Mark the epic done + write the local marker

Read `work_item_tracker` from `.shamt-core/shamt-config.json` (or `--tracker=`). Per profile:

- **ado** — `az boards work-item update --id {id} --state "Done"` (or the project's done state). Outward-facing — gated by Step 2.
- **github** — GitHub has no Epic work-item type; skip the remote close (the epic was freeform). The local marker is the record.
- **local** — no remote; the local marker is the mark-done.

**In all profiles**, write `**Status: Done**` into `epic.md`'s header (replacing any prior `**Status:**` line).

### Step 4 — Move the epic to archive

1. Ensure `epics/archive/` exists. If not, create it.
2. Move the resolved epic folder → `epics/archive/{same-folder-name}` (`git mv` when tracked, plain `mv` when untracked). **Move-epic-only:** the epic's child features/stories stay in their sibling top-level `features/` / `stories/` dirs — their `**Parent Epic:**` back-ref headers keep resolving to the now-archived epic.

> **Forward note.** When `po-nested-folder-layout` (proposal #14) lands, features/stories nest *inside* the epic folder, so this move becomes a natural whole-subtree cascade and the move-epic-only caveat above is revisited.

### Step 5 — Commit

Stage the epic finalize (the `epic.md` status flip + the archive move) and commit. Commit subject: `{ticket-id-or-slug}: finalize epic — {one-line summary}`. The user's signing / hook setup applies. (Like `/e8-finalize-story`, this commits but does not squash-merge a branch.)

### Step 6 — Exit

```text
Epic {slug} finalized and archived to epics/archive/{slug}/.
Epic work item: {marked Done via ado | local Status: Done | github n/a}.
{N} child features / stories left in place (flat layout).
PO flow complete for this epic.
```

No next-phase suggestion. The PO flow ends at the epic-finalize for a delivered epic.

## Exit criteria

- Every child feature/story was finalized before the move (Step 1 guard held).
- The epic is marked done (tracker + `epic.md` `**Status: Done**`) and moved to `epics/archive/{slug}/`; the change is committed.

## Notes

- **Move-epic-only (flat layout).** Only the epic folder moves; children stay put and keep resolving via back-ref headers. This is intentional for the current flat layout; the cascade is revisited under proposal #14's nested layout.
- **Status-line exclusion.** `epics/archive/` is excluded from active-epic resolution (see `statusline.sh`), so an archived epic does not surface as the active `EPIC {slug}`.
- **Epic only.** There is no per-feature finalize command; features close implicitly when their stories are finalized. Stories finalize via `/e8-finalize-story`.
- **Fresh-agent runnable** — epic folder, its children, config, and working-tree state are sufficient. No conversation history required.

---

<!-- Managed by Shamt — do not edit. Regenerate from shamt-core/host/templates/claude/commands/p5-finalize-epic.md. -->
