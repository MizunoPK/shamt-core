---
name: p5-finalize-epic
description: >
  Run the terminal PO-flow command at the Epic altitude. Guard that every child
  feature/story of the epic is finalized, mark the epic done via the active
  tracker profile, write the local Status: Done marker, and move the done epic
  folder into epics/archive/ (move-epic-only on the flat layout) — analogous to
  /f6-archive-proposal. Invoke when the user wants to finalize an epic, mark an
  epic done, archive a completed epic, or close out an epic.
triggers:
  - "finalize the epic"
  - "finalize epic {slug}"
  - "mark the epic done"
  - "archive the completed epic"
  - "close out the epic"
  - "wrap up the epic"
---

## Overview

Mirrors the `/p5-finalize-epic {slug}` slash command. Same canonical body, two host wirings. The terminal PO-flow command at the Epic altitude, modelled on `/f6-archive-proposal`.

## Protocol

Follow the canonical `/p5-finalize-epic` command body verbatim — see [`commands/p5-finalize-epic.md`](../../commands/p5-finalize-epic.md). Summary:

1. **Resolve the epic folder** — `epics/{slug}/` exact-then-glob (`epics/{slug}-*/`), excluding `epics/archive/`; halt on zero/multiple or if `epics/archive/{name}` already exists.
2. **Guard — children finalized** — every child feature/story (found via `**Parent Epic:**` back-ref headers on the flat layout) carries `**Status: Done**`. Halt and list unfinished children (`/e8-finalize-story` each) on any gap.
3. **Guard — explicit confirmation** — show the epic + finalized children, the mark-done method, the `epics/{slug}/ → epics/archive/{slug}/` move, and the `epic.md` `Status: Done` marker; wait for a yes.
4. **Mark done + local marker** — per profile (ado `az boards work-item update --state`; github has no Epic type → skip remote; local = marker); write `**Status: Done**` into `epic.md` for all profiles.
5. **Move to archive** — `epics/{slug}/ → epics/archive/{slug}/` (move-epic-only; children stay in their sibling top-level dirs and keep resolving via back-refs). Revisited as a whole-subtree cascade under proposal #14's nested layout.
6. **Commit** — stage the status flip + archive move; commit (no squash-merge).
7. **Exit** — terminal; no next-phase suggestion.

## Recommended model

Cheap (Haiku) — mechanical: evaluate the children-done guard, run one close command, flip a status line, move a folder, commit. See [`reference/model_selection.md`](../../../../../reference/model_selection.md).

## Exit criteria

Every child was finalized before the move; the epic is marked done (tracker + `epic.md` `**Status: Done**`) and moved to `epics/archive/{slug}/`; the change is committed. There is no per-feature finalize command — features close implicitly when their stories are finalized.

---

<!-- Managed by Shamt — do not edit. Regenerate from shamt-core/host/templates/claude/skills/p5-finalize-epic/SKILL.md. -->
