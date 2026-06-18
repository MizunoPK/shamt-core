---
name: pf2-decompose
description: >
  Run Phase 4 of the Shamt PO flow at the Feature altitude. Reads a validated
  feature.md, proposes a list of stories (title + one-line scope each),
  enforces the individually-testable rubric, gates the whole list with the user
  once, produces a parallelization analysis (recommended development order +
  concurrent-work callout), checks the decomposition exit gate, then writes
  N story-ticket-stub folders nested under epics/{epic-folder}/features/{feature-folder}/stories/{ID}-{story-slug}-{brief}/ticket.md
  (each carrying the scope one-liner in the body intake area + a Decomposition Context breadth section; parentage is the folder path; all other template
  sections empty) and appends Target Stories + Sequencing & Parallelization
  back onto the parent feature. Per-story deep dialog is deferred to
  /e1-start-story (stub-aware). Parent-slug batch mode: passing the parent
  **epic** slug decomposes every feature under that epic, sequentially — a
  stateless, disk-derived dispatch of the single-feature decompose logic that
  is itself resumable (halts at the first feature lacking a Validated footer).
  Invoke when the user wants to decompose a feature,
  break it into stories, lay out the story breakdown for a feature, plan
  parallel story work, or decompose all features in the epic.
triggers:
  - "decompose feature"
  - "decompose this feature"
  - "break this feature into stories"
  - "story breakdown for {feature-slug}"
  - "plan the stories for this feature"
  - "lay out the story work for"
  - "decompose {feature-slug}"
  - "decompose all features in the epic"
---

## Overview

Mirrors the `/pf2-decompose {slug}` slash command. Same canonical body, two host wirings.

## Protocol

Follow the canonical `/pf2-decompose` command body verbatim — see [`commands/pf2-decompose.md`](../../commands/pf2-decompose.md).

## Key distinctions

- **Decomposition exit gate ≠ `/validate-artifact`.** The gate is a 2-condition stub-batch check run **before** stubs land on disk. `/validate-artifact` runs the full Pattern 1 loop against `feature.md` (already, before this command) and against each story-level artifact (later, via the Engineer flow). Do not conflate.
- **The individually-testable rubric is the hard constraint** on output. The Engineer flow can refuse a story that violates this; PO-flow enforcement at decomposition time is the contract.
- **Development-order dependencies between siblings are allowed** — they live in the parallelization analysis, not as a testability violation.
- **No tracker fetch** at this altitude — `/pf2-decompose` operates entirely on the already-written `feature.md`. The active tracker is read only to pick the **ticket template** for the stub bodies (Step 8).
- **No feature-level review.** The 16-category code-review framework stays story-level per Pattern 4.
- **No `/e1-start-story` auto-invocation.** Per Principle 1, every command stays independently runnable.

## Recommended model

Reasoning (Opus) — see [`reference/model_selection.md`](../../../../../reference/model_selection.md). Decomposition involves the individually-testable rubric, dependency analysis, parallelization callout, and global-slug discipline — all benefit from Opus's reasoning depth. Same justification as `/pe2-decompose`.

## Exit criteria

N story-stub folders exist nested under `epics/{epic-folder}/features/{feature-folder}/stories/`: New stubs (and every stub on first decomposition) carry the scope one-liner in the body and a `## Decomposition Context` breadth section (parentage is the folder path), with all other template sections empty; Kept stubs (re-decomposition only) are preserved unchanged from before the invocation, including any in-progress engineer work inside. Every stub's scope one-liner passes the individually-testable rubric. The parent feature's `Target Stories` + `Sequencing & Parallelization` sections carry the approved list and analysis; a slug-only `Decomposed YYYY-MM-DD — N story stubs at stories/{slug-1}, stories/{slug-2}, …` line is present directly above the preserved `Validated …` footer (actual folder paths recovered via tree-wide story glob per §PO-tree resolution); orphaned stubs (on re-decomposition) surfaced as a warning, not auto-deleted; the user approved the batch with rubric verdicts surfaced. **Parent-slug batch mode** (a parent **epic** slug is passed): every feature under the epic has been decomposed per the above, skipping any already-decomposed child and halting at the first feature lacking a `Validated …` footer, with a one-line-per-child summary reported.

<!-- Managed by Shamt — do not edit. Regenerate from shamt-core/host/templates/claude/skills/pf2-decompose/SKILL.md. -->
