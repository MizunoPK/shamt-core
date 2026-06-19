---
name: po-status
description: >
  Regenerate an epic's STATUS.md — a derived per-feature/per-story state
  rollup (New / Validated / Building / Released) re-computed from each
  artifact's on-disk signals, never hand-edited. STATUS.md is a VIEW, not an
  authoritative source: re-running always yields truth, so it is drift-free by
  construction. Distinct from the work-item tracker profile (the external
  ticket-content source). Invoke when the user wants to refresh the epic
  status, see the state of every feature / story under an epic, regenerate
  STATUS.md, or get a board-style rollup of an epic's progress.
triggers:
  - "refresh the status for {epic-slug}"
  - "regenerate STATUS.md"
  - "epic status rollup"
  - "state of every story under this epic"
  - "po-status {epic-slug}"
  - "show the epic status board"
---

## Overview

Mirrors the `/po-status {epic-slug}` slash command. Same canonical body, two host wirings.

## Protocol

Follow the canonical `/po-status` command body verbatim — see [`commands/po-status.md`](../../commands/po-status.md).

## Key distinction

- **Derived rollup, not a tracker.** `STATUS.md` is a re-computed VIEW of state the artifacts already carry (the anti-mirror-drift design); it is **not** the external work-item **tracker** profile (`reference/trackers/`). Every refresh re-derives the whole table from disk — never patch a single cell.

## Recommended model

Cheap (Haiku) — mechanical disk walk + table regeneration, no design judgment. See [`reference/model_selection.md`](../../../../../reference/model_selection.md).

## Exit criteria

`epics/{epic-folder}/STATUS.md` regenerated wholesale from on-disk signals, one row per feature with nested story rows, each carrying a derived New / Validated / Building / Released state.

<!-- Managed by Shamt — do not edit. Regenerate from shamt-core/host/templates/claude/skills/po-status/SKILL.md. -->
