---
name: pe3-finalize
description: >
  Run the terminal PO-flow command at the Epic altitude. Guard that every child
  feature/story of the epic is finalized, mark the epic done via the active
  tracker profile, write the local Status: Done marker, and move the done epic
  subtree into epics/archive/ (a whole-subtree move under the nested layout) — analogous to
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

Mirrors the `/pe3-finalize {slug}` slash command. Same canonical body, two host wirings. The terminal PO-flow command at the Epic altitude, modelled on `/f6-archive-proposal`.

## Protocol

Follow the canonical `/pe3-finalize` command body verbatim — see [`commands/pe3-finalize.md`](../../commands/pe3-finalize.md). Summary:

1. **Resolve the epic folder** — per §PO-tree resolution (epics are top-level: `epics/{slug}-*/` etc.), excluding `epics/archive/`; halt on zero/multiple or if `epics/archive/{name}` already exists.
2. **Guard — children finalized** — every child feature/story (found by walking the nested tree *inside* the epic folder — `epics/{epic}/features/*/feature.md`, `epics/{epic}/features/*/stories/*/ticket.md`; parentage is the path) carries `**Status: Done**`. Halt and list unfinished children (`/e8-finalize-story` each) on any gap.
3. **Guard — explicit confirmation** — show the epic + finalized children, the mark-done method, the `epics/{slug}/ → epics/archive/{slug}/` move, and the `epic.md` `Status: Done` marker; wait for a yes.
4. **Mark done + local marker** — per profile (ado `az boards work-item update --state`; github has no Epic type → skip remote; local = marker); write `**Status: Done**` into `epic.md` for all profiles.
5. **Move to archive** — `epics/{slug}/ → epics/archive/{slug}/`, a **whole-subtree move** (the nested features/stories ride along inside the epic folder; parentage is the path, nothing dangles).
6. **Commit** — stage the status flip + archive move; commit (no squash-merge).
7. **Exit** — terminal; no next-phase suggestion.

## Recommended model

Cheap (Haiku) — mechanical: evaluate the children-done guard, run one close command, flip a status line, move a folder, commit. See [`reference/model_selection.md`](../../../../../reference/model_selection.md).

## Exit criteria

Every child was finalized before the move; the epic is marked done (tracker + `epic.md` `**Status: Done**`) and moved to `epics/archive/{slug}/`; the change is committed. There is no per-feature finalize command — features close implicitly when their stories are finalized.

---

<!-- Managed by Shamt — do not edit. Regenerate from shamt-core/host/templates/claude/skills/pe3-finalize/SKILL.md. -->
