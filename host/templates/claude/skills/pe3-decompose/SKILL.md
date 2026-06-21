---
name: pe3-decompose
description: >
  Run Stage 3 of the Shamt PO flow at the Epic altitude. Reads a validated
  epic.md, proposes a list of features (title + one-line goal each), gates the
  whole list with the user once, produces a parallelization analysis
  (recommended development order + concurrent-work callout), checks the
  decomposition exit gate, then writes N feature-stub folders nested under
  epics/{epic-folder}/features/{ID}-{feature-slug}-{brief}/feature.md (each carrying Goal one-liner + a Scope/Non-Scope boundary + a Decomposition Context breadth section; depth sections empty; parent epic is the folder path) and appends Target
  Features + Sequencing & Parallelization back onto the parent epic. Per-
  feature deep dialog is deferred to /pf1-define. Invoke when the user
  wants to decompose an epic, break it into features, lay out the feature
  breakdown for an epic, or plan parallel feature work.
triggers:
  - "decompose epic"
  - "decompose this epic"
  - "break this epic into features"
  - "feature breakdown for {epic-slug}"
  - "plan the features for this epic"
  - "lay out the feature work for"
  - "decompose {epic-slug}"
---

## Overview

Mirrors the `/pe3-decompose {slug}` slash command. Same canonical body, two host wirings.

## Protocol

Follow the canonical `/pe3-decompose` command body verbatim — see [`commands/pe3-decompose.md`](../../commands/pe3-decompose.md).

## Key distinctions

- **Decomposition exit gate ≠ `/validate-artifact`.** The gate is a 2-condition stub-batch check run **before** stubs land on disk. `/validate-artifact` runs the full Pattern 1 loop against `epic.md` (already, via `/pe2-validate`, before `/pe3-decompose`) and against each `feature.md` (later, via `/pf2-validate`, after `/pf1-define` completes its dialog). Do not conflate.
- **No tracker fetch** at this altitude — `/pe3-decompose` operates entirely on the already-written `epic.md`.
- **No epic-level review.** The 16-category code-review framework stays story-level per Pattern 4.
- **No `/pf1-define` auto-invocation.** Per Principle 1, every command stays independently runnable.

## Recommended model

Reasoning (Opus) — see [`reference/model_selection.md`](../../../../../reference/model_selection.md). Decomposition is the highest-value design work in the PO flow; dependency analysis + parallelization callout + global-slug discipline benefit from Opus's reasoning depth.

## Exit criteria

N feature-stub folders exist nested under `epics/{epic-folder}/features/`: New stubs (and every stub on first decomposition) carry `## Goal` + `## Scope / Non-Scope` + `## Decomposition Context` filled (parent epic is the folder path), with the depth sections (`## Success Criteria` / `## Open Questions`) empty; Kept stubs (re-decomposition only) are preserved unchanged from before the invocation, including any in-progress user work inside. The parent epic's `Target Features` + `Sequencing & Parallelization` sections carry the approved list and analysis; a slug-only `Decomposed YYYY-MM-DD — N feature stubs at features/{slug-1}, features/{slug-2}, …` line is present directly above the preserved `Validated …` footer (actual folder paths recovered via `features/{slug}-*/` glob via §PO-tree resolution); orphaned stubs (on re-decomposition) surfaced as a warning, not auto-deleted; the user approved the batch.

<!-- Managed by Shamt — do not edit. Regenerate from shamt-core/host/templates/claude/skills/pe3-decompose/SKILL.md. -->
