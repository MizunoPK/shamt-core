---
name: ps0-draft
description: >
  Quick-capture a DRAFT story-ticket stub under a feature or under the
  standing Tech Stories epic (bugs/quick-wins fast-path) — single-story
  incremental producer (one story at a time, no feature re-decomposition).
  Scope one-liner + a Scratch Notes (stage-0 capture) section marked with
  `Draft (f0 — story-idea capture, unrefined)` status and a banner — NO
  open-questions dialog, NO formal Acceptance Criteria. The full drafting
  pass is deferred to /ps1-define, which ingests a ps0 draft as its intake.
  Replaces the former Tech Stories fast-path command (fast-path tech story
  = story under standing Tech Stories epic bugs/quick-wins feature).
  Additively appends to
  the parent feature's Target Stories list (feature-parent mode only). Invoke
  when the user wants to draft one more story under a feature, file a bug, or
  capture a quick win.
triggers:
  - "draft a story under a feature"
  - "file a bug"
  - "capture a quick win"
  - "draft a tech story"
  - "add a story stub"
  - "one more story"
---

## Overview

Mirrors the `/ps0-draft {feature-slug | bugs | quick-wins} [story-slug] [blurb]` slash command. Same canonical body, two host wirings.

## Protocol

Follow the canonical `/ps0-draft` command body verbatim — see [`commands/ps0-draft.md`](../../commands/ps0-draft.md).

## Two parent modes

- **Feature-parent mode** — `{feature-slug}` resolves to an existing feature; write stub under it, append to `## Target Stories`.
- **Tech-story mode** (absorbs the former tech-story fast-path) — `bugs` / `quick-wins` resolves the standing Tech Stories epic's reserved feature; write stub there (no `## Target Stories` append — standing features carry no decomposition list).

## Tracker-template selection

Read `work_item_tracker` from `.shamt-core/shamt-config.json`:

- **ado** → `templates/ticket.ado.template.md`
- **github** → `templates/ticket.github.template.md`
- **local** or **none** → `templates/ticket.github.template.md` (generic baseline); replace the template's `**Tracker profile:**` line with `{local|none}` to match the config.

## Recommended model

Cheap (Haiku) — ps0 is mechanical: resolve a parent, allocate an ID, seed a file, drop the blurb into Scratch Notes. No design judgment. See [`reference/model_selection.md`](../../../../../reference/model_selection.md).

## Exit criteria

`epics/{epic-folder}/features/{feature-folder}/stories/{ID}-{story-slug}-{brief}/ticket.md` exists with the ticket template shape (metadata, body intake with scope one-liner, Decomposition Context placeholder or populated, all other sections empty), the draft marker status, and a Scratch Notes section; feature-parent mode: parent feature's `## Target Stories` appended (one line); tech-story mode: no append; no open-questions dialog, no validation footer; slug reported.

---

<!-- Managed by Shamt — do not edit. Regenerate from shamt-core/host/templates/claude/skills/ps0-draft/SKILL.md. -->
