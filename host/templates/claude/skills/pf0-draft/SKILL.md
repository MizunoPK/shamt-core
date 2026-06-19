---
name: pf0-draft
description: >
  Quick-capture a DRAFT feature stub under an existing epic from a one-line
  blurb — single-stub incremental producer (one feature at a time, no epic
  re-decomposition). Title + a Scratch Notes (stage-0 capture) section marked
  with `Draft (f0 — feature-idea capture, unrefined)` status and a banner —
  NO open-questions dialog, NO formal Success Criteria. The full drafting
  pass is deferred to /pf1-define, which ingests a pf0 draft as its intake.
  Additively appends to the parent epic's Target Features list (no wholesale
  rewrite). Invoke when the user wants to draft one more feature under an
  epic, add a feature stub incrementally, or capture a feature idea.
triggers:
  - "draft one more feature under an epic"
  - "add a feature stub"
  - "incremental feature"
  - "quick-capture a feature"
  - "stub a feature"
---

## Overview

Mirrors the `/pf0-draft {epic-slug} [feature-slug] [blurb]` slash command. Same canonical body, two host wirings.

## Protocol

Follow the canonical `/pf0-draft` command body verbatim — see [`commands/pf0-draft.md`](../../commands/pf0-draft.md).

## Recommended model

Cheap (Haiku) — pf0 is mechanical: resolve an epic, allocate an ID, seed a file, drop the blurb into Scratch Notes. No design judgment. See [`reference/model_selection.md`](../../../../../reference/model_selection.md).

## Exit criteria

`epics/{epic-folder}/features/{ID}-{feature-slug}-{brief}/feature.md` exists with the stub shape (Goal, Scope/Non-Scope, Decomposition Context populated or placeholder; Open Questions / Success Criteria / Target Stories / Sequencing empty), the draft marker status, and a Scratch Notes section; parent epic's `## Target Features` section has the feature appended; no wholesale rewrite; no open-questions dialog, no validation footer; slug reported.

## Single-stub incremental

This is the feature-level analogue of `/ps0-draft` (story-level fast-path) — add one feature without re-decomposing the whole epic. Contrast with `/pe3-decompose` (the batch producer).

---

<!-- Managed by Shamt — do not edit. Regenerate from shamt-core/host/templates/claude/skills/pf0-draft/SKILL.md. -->
