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

Follow the canonical `/pf0-draft` command body verbatim — see [`commands/pf0-draft.md`](../../commands/pf0-draft.md). Summary:

1. **Resolve the parent epic** — confirm `epics/{epic-slug}-*/epic.md` exists (per §PO-tree resolution). If not, halt and direct to `/pe1-define {epic-slug}`.
2. **Slug-collision rule — non-destructive, non-interactive** — never overwrite, never prompt. If `{feature-slug}` is taken globally (tree-wide feature glob), halt and ask for a different slug. (Feature slugs are user-chosen and globally unique, per the PO-flow design.)
3. **Allocate ticket ID** (`max` across the tree + 1). Confirm or derive the feature slug.
4. **Seed the feature stub** — create `epics/{epic-folder}/features/{ID}-{feature-slug}-{brief}/` and write `feature.md` with the **identical core stub-section shape `/pe2-decompose` emits** (per its Step 8 stub-section contract): H1; `**Ticket ID:** T{N}`; `**Status:** Draft (f0 — feature-idea capture, unrefined)` (the distinct marker); `## Goal` (from blurb); `## Scope / Non-Scope` (boundary or placeholder); `## Decomposition Context` ("none" or initial breadth bullets); `## Open Questions` / `## Success Criteria` / `## Target Stories` / `## Sequencing & Parallelization` left empty; a `## Scratch Notes (stage-0 capture)` section holding the blurb (the additive draft-only overlay `/pf1-define` strips). **No** validation footer.
5. **Additively append** to the parent epic's `## Target Features` section (one line; **do NOT rewrite** the section wholesale — preserve the `Decomposed YYYY-MM-DD — …` line format for re-decomposition partition logic).
6. **Exit** — report the created path and slug. Suggest `/pf1-define {feature-slug}` next.

## Recommended model

Cheap (Haiku) — pf0 is mechanical: resolve an epic, allocate an ID, seed a file, drop the blurb into Scratch Notes. No design judgment. See [`reference/model_selection.md`](../../../../../reference/model_selection.md).

## Exit criteria

`epics/{epic-folder}/features/{ID}-{feature-slug}-{brief}/feature.md` exists with the stub shape (Goal, Scope/Non-Scope, Decomposition Context populated or placeholder; Open Questions / Success Criteria / Target Stories / Sequencing empty), the draft marker status, and a Scratch Notes section; parent epic's `## Target Features` section has the feature appended; no wholesale rewrite; no open-questions dialog, no validation footer; slug reported.

## Single-stub incremental

This is the feature-level analogue of `/ps0-draft` (story-level fast-path) — add one feature without re-decomposing the whole epic. Contrast with `/pe2-decompose` (the batch producer).

---

<!-- Managed by Shamt — do not edit. Regenerate from shamt-core/host/templates/claude/skills/pf0-draft/SKILL.md. -->
