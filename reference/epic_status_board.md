# Epic Status Board — State-Derivation Contract

**Companion to the `/po-status` command — read [`host/templates/claude/commands/po-status.md`](../host/templates/claude/commands/po-status.md) first.** Referenced from the rules file §PO-tree resolution (the one-line pointer there; full detail lives here to respect the D12 size budget).

**Purpose:** Define, authoritatively, how each epic's per-feature/per-story `STATUS.md` rollup is **derived** from the artifacts' own on-disk signals — for stories and for features — plus the refresh semantics and `STATUS.md`'s place in the PO tree. This is the single source of truth the `/po-status` command and the five auto-refresh hooks compute against.

---

## What STATUS.md is (and is not)

`STATUS.md` is a **derived rollup** — a re-computable VIEW of state the artifacts already carry, written at `epics/{ID}-{slug}-{brief}/STATUS.md`. It is **never** an authoritative source and is **never** hand-edited: the per-artifact signals (footers, Engineer-flow artifacts, `**Status: Done**`) stay authoritative, and `STATUS.md` is recomputed from them. This keeps the framework disk-authoritative and drift-free by construction — re-running `/po-status` always reproduces truth.

**Hard rule — whole-table re-derivation.** Every refresh (the `/po-status` command and every auto-refresh hook) **re-derives the entire table from disk**. A refresh must never patch a single cell or row in place — patching re-opens the very mirror-drift class the derived model closes. The template's "GENERATED — do not hand-edit" banner states this for the reader; this contract states it for the implementer.

It is distinct from the **work-item tracker** profile concept in `reference/trackers/` (the external ADO/GitHub/local *source* of ticket content). `STATUS.md` is a local derived rollup, not a tracker.

## The four states

A work item is in exactly one of four states, in lifecycle order:

1. **New** — the artifact exists (a stub from decomposition, or defined) but carries **no** `Validated …` footer.
2. **Validated** — the artifact carries a `Validated …` footer.
3. **Building** — Engineer-flow artifacts are present under the story folder (e.g. `spec.md`, `implementation_plan.md`, `user_test_plan.md`) and the story is **not** yet finalized.
4. **Released** — the story's `ticket.md` carries `**Status: Done**` (written by `/e9-finalize-story`).

## Story state derivation

For a story folder (`epics/{epic-folder}/features/{feature-folder}/stories/{ID}-{slug}-{brief}/`), in precedence order (first match wins):

1. `ticket.md` contains `**Status: Done**` → **Released**.
2. An Engineer-flow artifact exists under the story folder (`spec.md` or `implementation_plan.md`, including `_vN`/`_phase_*` variants) → **Building**.
3. `ticket.md` carries a `Validated …` footer → **Validated**.
4. Otherwise → **New**.

## Feature state derivation (rollup of child stories)

For a feature row, aggregate its child stories with this precedence (first match wins):

1. Any child story is **Building** or **Released** → **Building**.
2. All child stories are **Released** (and ≥1 story exists) → **Released**.
3. Else if `feature.md` carries a `Validated …` footer → **Validated**.
4. Else → **New**.

## Refresh semantics

`STATUS.md` is refreshed two ways, both of which **re-derive the whole table from disk** (never patch a cell):

- **On demand** — `/po-status {epic-slug}` regenerates the epic's `STATUS.md` from the current subtree.
- **Auto-refresh hooks** — transition commands re-derive the parent epic's `STATUS.md` after their own work, so the rollup stays live: `/pe3-decompose` (new features → New), `/pf3-decompose` (new stories → New), the `-validate` stage `/pe2-validate` / `/pf2-validate` / `/ps2-validate` (epic / feature / story → Validated), `/e5-execute-plan` (story → Building), `/e9-finalize-story` (story → Released; feature rollup recomputed).

## Place in the PO tree

`STATUS.md` lives at the epic-folder root alongside `epic.md`: `epics/{ID}-{slug}-{brief}/STATUS.md`. It is generated lazily — an epic gains a `STATUS.md` the first time `/po-status` (or a hooked command) runs in its subtree; existing epics are not back-filled automatically.
