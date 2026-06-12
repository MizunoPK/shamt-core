---
name: p6-draft-tech-story
description: >
  Fast-path PO command for one-off work that doesn't belong to any real epic —
  file a bug or quick win directly under the standing Tech Stories epic's Bugs /
  Quick Wins feature, bypassing the epic→feature→story decomposition cascade,
  then hand to /e1-start-story (stub-aware). Invoke when the user wants to draft
  a tech story, file a one-off bug, capture a quick win, or create a standalone
  ticket without the full PO drill-down.
triggers:
  - "draft a tech story"
  - "file a bug"
  - "log a bug"
  - "capture a quick win"
  - "create a one-off ticket"
  - "add a tech story under bugs"
  - "new quick win"
---

## Overview

Mirrors the `/p6-draft-tech-story [bugs|quick-wins] [slug] [blurb]` slash command. Same canonical body, two host wirings. The fast-path entry into the PO/Engineer flow that bypasses the decomposition cascade.

## Protocol

Follow the canonical `/p6-draft-tech-story` command body verbatim — see [`commands/p6-draft-tech-story.md`](../../commands/p6-draft-tech-story.md). Summary:

1. **Pick the feature** — `bugs` (broken) or `quick-wins` (small improvement), resolved under the standing Tech Stories epic (`epics/{tech-stories-folder}/features/{bugs|quick-wins}/`, per §PO-tree resolution). Halt if the standing epic is absent (re-run `import-shamt` to seed it).
2. **Allocate ID + slug** — `T{N}` per the # Ticket IDs rules; globally-unique slug (collision-check per §PO-tree resolution).
3. **Write the ticket stub** — `…/stories/{ID}-{slug}-{brief}/ticket.md` from the active tracker's per-provider ticket template (ado / github / local); populate the scope one-liner; parentage is the folder path (no back-ref headers); leave other sections for `/e1`.
4. **Hand off** — `/e1-start-story {slug}` (stub-aware) for intake, then the normal Engineer flow.

## Recommended model

Cheap (Haiku) — mechanical: pick a feature, allocate an ID, write a stub, hand off. See [`reference/model_selection.md`](../../../../../reference/model_selection.md).

## Exit criteria

A story-ticket stub exists under `epics/{tech-stories-folder}/features/{bugs|quick-wins}/stories/{ID}-{slug}-{brief}/ticket.md` with the scope one-liner; `/e1-start-story` suggested or run. On completion, `/e8-finalize-story` archives the finished ticket into the feature's `archive/`.

---

<!-- Managed by Shamt — do not edit. Regenerate from shamt-core/host/templates/claude/skills/p6-draft-tech-story/SKILL.md. -->
