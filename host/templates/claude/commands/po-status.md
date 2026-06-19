---
description: Regenerate an epic's STATUS.md — a derived per-feature/per-story state rollup (New / Validated / Building / Released) re-computed from on-disk signals; the single regenerate entry point
---

# /po-status

**Purpose:** (Re)derive the per-epic `STATUS.md` state rollup from the epic's on-disk subtree. `STATUS.md` is a **derived VIEW**, not an authoritative source — this command recomputes the whole table from each artifact's own state signals, so re-running it always yields truth. The state-derivation rules are the contract in [`reference/epic_status_board.md`](../../../../reference/epic_status_board.md); this command applies them.

## Usage

```
/po-status {epic-slug}
```

## Arguments

- `{epic-slug}` (required) — epic ticket ID (`T{N}`) or slug. Resolves to exactly one epic folder per the **Epic** rule in [`SHAMT_RULES.template.md`](../../../../templates/SHAMT_RULES.template.md#po-tree-resolution) §PO-tree resolution (tree-wide glob + legacy-flat fallback); halt on zero or multiple matches.

## Prerequisites

- The resolved epic folder exists and contains `epic.md`. If not, halt and report.

## Step-by-step

### Step 1 — Resolve the epic folder

Resolve `{epic-slug}` to its epic folder per §PO-tree resolution (work-root-relative — `.shamt-core/` in a child). `epics/{epic-folder}/` below denotes the resolved folder.

### Step 2 — Re-derive the whole table from disk

Walk the epic's subtree and compute every row from on-disk signals per [`reference/epic_status_board.md`](../../../../reference/epic_status_board.md):

1. For each feature under `epics/{epic-folder}/features/`, and for each story under that feature's `stories/`, compute the **story state** by the story-derivation precedence (Released if `ticket.md` has `**Status: Done**`; else Building if an Engineer-flow artifact — `spec.md` / `implementation_plan.md` incl. `_vN`/`_phase_*` — exists; else Validated if `ticket.md` carries a `Validated …` footer; else New).
2. Compute each **feature state** by the feature-rollup precedence (any child Building/Released → Building; all children Released and ≥1 exists → Released; else `feature.md` `Validated` footer → Validated; else New).
3. **Re-derive the entire table** — never patch a single cell. This whole-table recomputation is the hard rule (see the reference doc) that keeps the rollup drift-free.

### Step 3 — Write STATUS.md

Write (overwriting) `epics/{epic-folder}/STATUS.md` from [`templates/epic_status.template.md`](../../../../templates/epic_status.template.md): the provenance banner, today's date, the states legend, and one row per feature (each followed by its nested child-story rows).

### Step 4 — Exit

Report the path written and a one-line state tally, e.g. `STATUS.md refreshed: N features, M stories.`

## Exit criteria

- `epics/{epic-folder}/STATUS.md` exists, regenerated wholesale (no cell patched), with one row per feature and nested rows per story, each carrying a derived state.

## Notes

- **Derived, never hand-authored.** `STATUS.md` mirrors no state of its own — it is recomputed from the artifacts. This is the deliberate anti-mirror-drift design (proposal `epic-state-tracker`).
- **Not a tracker.** `STATUS.md` (a local state rollup) is distinct from the **work-item tracker** profile (`reference/trackers/`, the external ticket-content source).
- **Fresh-agent runnable** per Principle 1: the slug resolves the folder; all state lives on disk.

<!-- Managed by Shamt — do not edit. Regenerate from shamt-core/host/templates/claude/commands/po-status.md. -->
