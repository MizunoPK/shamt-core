---
name: pe2-decompose
description: >
  Run Phase 2 of the Shamt PO flow at the Epic altitude. Reads a validated
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

Mirrors the `/pe2-decompose {slug}` slash command. Same canonical body, two host wirings.

## Protocol

Follow the canonical `/pe2-decompose` command body verbatim — see [`commands/pe2-decompose.md`](../../commands/pe2-decompose.md). Summary:

1. **Resolve `{id-or-slug}`** — a ticket ID globs `epics/{ID}-*/`; a slug tries `epics/{slug}/` (exact) then **both** `epics/{slug}-*/` and `epics/*-{slug}-*/` (glob). Halt if missing — direct to `/pe1-define {slug}`. Each New feature gets an allocated ticket ID (`T{N}`); the parent epic is determined by the nested folder path.
2. **Check the `Validated …` footer** on `epic.md`. Halt with a clear message if absent unless `--allow-unvalidated` was passed (discouraged; one-line notice + continue).
3. **Re-entry detection.** If a prior `Decomposed YYYY-MM-DD — …` line is present, treat as re-decomposition: warn the user, confirm proceed, then once the new list is approved in step 5, **partition it against the prior list by `{feature-slug}`** into Kept (slug appears in both — existing `feature.md` preserved untouched; collision check exempt), New (slug only in the new list — fresh stub written, collision check applies), and Orphaned (slug only in the prior list — folder left in place, warning surfaced in step 10).
4. **Read the epic** (`Goal`, `Success Criteria`, `Scope / Non-Scope`, optional `Architecture impact`, optional `All Remaining Fields`) and **propose the feature list** — flat enumeration: title + one-line goal per entry. Derive `{feature-slug}` (kebab-case from title) and `{brief}` (kebab-case from goal one-liner) per entry. Draft the **parallelization analysis**: `Recommended order` (sequenced by dependency) and `Parallelizable` (concurrent-work callout, or `None — strictly sequential.`).
5. **Gate the whole batch once** with the user. Surface the list + derived slugs + parallelization analysis together. Iterate as a single batch — add / remove / reword / re-sequence. Per-feature deep dialog is **deferred to `/pf1-define`** — do not start drafting per-feature scope, success criteria, or stories here. Open-questions dialog applies only to global scoping questions about the list as a whole.
6. **Decomposition exit gate** — **2-condition check, run before stubs are written**: (1) every feature has a stated goal one-liner; (2) every feature appears in the parent epic's `Sequencing & Parallelization` analysis. **Distinct from `/validate-artifact`**.
7. **Detect global feature-slug collisions** — resolve per §PO-tree resolution (tree-wide feature glob) on the **New** partition; halt and return to Step 5 if any New candidate slug collides. **Kept** slugs are exempt — their collision with the prior stub of the same epic is expected.
8. **Write the feature stubs** from [`templates/feature.template.md`](../../../../../templates/feature.template.md) nested under `epics/{epic-folder}/features/`: for **New** features, write `## Goal` one-liner + a `## Scope / Non-Scope` boundary + a `## Decomposition Context` breadth section (parent epic is the folder path); depth sections (`Success Criteria`, `Open Questions`) empty; no validation footer. For **Kept** features (re-decomposition only), **do not touch** the existing `feature.md` — preserve any in-progress work; surface a notice if the user-approved one-liner differs from the existing `## Goal`.
9. **Append to parent epic** — rewrite `## Target Features` + `## Sequencing & Parallelization` wholesale to match the full new list (Kept + New); insert (or replace, on re-decomposition) a `Decomposed YYYY-MM-DD — N feature stubs at features/{slug-1}, features/{slug-2}, …` line (slug-only — actual folders resolved via `features/{slug}-*/` glob via §PO-tree resolution) **immediately above the validation footer** so the footer stays last. Preserve the existing validation footer; do not strip or duplicate it.
10. **Re-decomposition orphan handling.** Surface a warning listing the **Orphaned** folders (slugs in the prior list, absent from the new list) and ask the user to delete or repurpose manually — **do not auto-delete**. Kept stubs are not orphans.
11. **Suggest** `/clear` + `/pf1-define {feature-slug-N}` per stub. Do **not** auto-invoke — per [Principle 1](../../../../../templates/SHAMT_RULES.template.md#principle-1-phase-per-command--slug-resumability), each stub is independently resumable.

## Key distinctions

- **Decomposition exit gate ≠ `/validate-artifact`.** The gate is a 2-condition stub-batch check run **before** stubs land on disk. `/validate-artifact` runs the full Pattern 1 loop against `epic.md` (already, before this command) and against each `feature.md` (later, after `/pf1-define` completes its dialog). Do not conflate.
- **No tracker fetch** at this altitude — `/pe2-decompose` operates entirely on the already-written `epic.md`.
- **No epic-level review.** The 16-category code-review framework stays story-level per Pattern 4.
- **No `/pf1-define` auto-invocation.** Per Principle 1, every command stays independently runnable.

## Recommended model

Reasoning (Opus) — see [`reference/model_selection.md`](../../../../../reference/model_selection.md). Decomposition is the highest-value design work in the PO flow; dependency analysis + parallelization callout + global-slug discipline benefit from Opus's reasoning depth.

## Exit criteria

N feature-stub folders exist nested under `epics/{epic-folder}/features/`: New stubs (and every stub on first decomposition) carry `## Goal` + `## Scope / Non-Scope` + `## Decomposition Context` filled (parent epic is the folder path), with the depth sections (`## Success Criteria` / `## Open Questions`) empty; Kept stubs (re-decomposition only) are preserved unchanged from before the invocation, including any in-progress user work inside. The parent epic's `Target Features` + `Sequencing & Parallelization` sections carry the approved list and analysis; a slug-only `Decomposed YYYY-MM-DD — N feature stubs at features/{slug-1}, features/{slug-2}, …` line is present directly above the preserved `Validated …` footer (actual folder paths recovered via `features/{slug}-*/` glob via §PO-tree resolution); orphaned stubs (on re-decomposition) surfaced as a warning, not auto-deleted; the user approved the batch.

<!-- Managed by Shamt — do not edit. Regenerate from shamt-core/host/templates/claude/skills/pe2-decompose/SKILL.md. -->
