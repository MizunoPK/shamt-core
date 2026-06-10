---
name: p4-decompose-feature
description: >
  Run Phase 4 of the Shamt PO flow at the Feature altitude. Reads a validated
  feature.md, proposes a list of stories (title + one-line scope each),
  enforces the individually-testable rubric, gates the whole list with the user
  once, produces a parallelization analysis (recommended development order +
  concurrent-work callout), checks the decomposition exit gate, then writes
  N story-ticket-stub folders under stories/{ID}-{story-slug}-{brief}/ticket.md
  (each carrying **Parent Feature:** + **Parent Epic:** back-ref headers under
  H1 plus the scope one-liner in the body intake area + a Decomposition Context breadth section; all other template
  sections empty) and appends Target Stories + Sequencing & Parallelization
  back onto the parent feature. Per-story deep dialog is deferred to
  /e1-start-story (stub-aware). Invoke when the user wants to decompose a feature,
  break it into stories, lay out the story breakdown for a feature, or plan
  parallel story work.
triggers:
  - "decompose feature"
  - "decompose this feature"
  - "break this feature into stories"
  - "story breakdown for {feature-slug}"
  - "plan the stories for this feature"
  - "lay out the story work for"
  - "decompose {feature-slug}"
---

## Overview

Mirrors the `/p4-decompose-feature {slug}` slash command. Same canonical body, two host wirings.

## Protocol

Follow the canonical `/p4-decompose-feature` command body verbatim — see [`commands/p4-decompose-feature.md`](../../commands/p4-decompose-feature.md). Summary:

1. **Resolve `{id-or-slug}`** — a ticket ID globs `features/{ID}-*/`; a slug tries `features/{slug}/` (exact) then **both** `features/{slug}-*/` and `features/*-{slug}-*/` (glob). Halt if missing — direct to `/p3-start-feature {slug}`. Each New story gets an allocated ticket ID (`T{N}`) + `**Parent Feature:** T{N} (slug)` (+ `**Parent Epic:** T{N} (slug)` when present) back-refs.
2. **Check the `Validated …` footer** on `feature.md`. Halt with a clear message if absent unless `--allow-unvalidated` was passed (discouraged; one-line notice + continue).
3. **Re-entry detection.** If a prior `Decomposed YYYY-MM-DD — …` line is present, treat as re-decomposition: warn the user, confirm proceed, then once the new list is approved in step 5, **partition it against the prior list by `{story-slug}`** into Kept (slug appears in both — existing story folder preserved untouched, including any Spec / Plan / Build / Review artifacts inside; collision check exempt), New (slug only in the new list — fresh stub written, collision check applies), and Orphaned (slug only in the prior list — folder left in place, warning surfaced in step 10).
4. **Read the feature** (`Goal`, `Success Criteria`, `Scope / Non-Scope`, optional `Architecture impact`, `**Parent Epic:**` back-ref, optional `All Remaining Fields`) and **propose the story list** — flat enumeration: title + one-line scope per entry. **Enforce the individually-testable rubric** and the decomposition exit-criterion resolution:
   > A story is **individually testable** when it carries a self-contained verification path (automated or manual) that exercises its own contribution without re-verifying any sibling story's success criterion.
   > - Verification path = automated test, manual checklist step, or other observable check.
   > - Self-contained = the check does not require a sibling story's code to be present to *pass* (it may require sibling code to *run* — that's a sequencing fact, recorded in the parallelization analysis below).
   > - **Rubric exception:** development-order dependencies between siblings are explicitly allowed. They live in the `Recommended order` callout, not as a testability violation.

   For each candidate that fails the rubric, surface the gap and either decompose further (split off the verification path into a new sibling) or expand the candidate's scope to include its own check. **Do not write a stub that violates the rubric.**

   Derive `{story-slug}` (kebab-case from title) and `{brief}` (kebab-case from scope one-liner) per entry — re-decomposition Kept exception reuses the existing folder via `stories/{story-slug}-*/` glob. Draft the **parallelization analysis**: `Recommended order` (sequenced by dependency) and `Parallelizable` (concurrent-work callout, or `None — strictly sequential.`).
5. **Gate the whole batch once** with the user. Surface the list + derived slugs + per-candidate rubric verdict + parallelization analysis together. Iterate as a single batch — add / remove / reword / re-sequence / fix testability gaps. Per-story deep dialog is **deferred to `/e1-start-story` (stub-aware)** — do not start drafting per-story acceptance criteria, spec sections, or implementation plans here. Open-questions dialog applies only to global scoping / rubric / parallelization questions at this altitude.
6. **Decomposition exit gate** — **2-condition check, run before stubs are written**: (1) every story stub has an individually-testable scope one-liner per the rubric above; (2) every story appears in the parent feature's `Sequencing & Parallelization` analysis. **Distinct from `/validate-artifact`**.
7. **Detect global story-slug collisions** — `stories/{story-slug}-*/` glob on the **New** partition; halt and return to Step 5 if any New candidate slug collides. **Kept** slugs are exempt — their collision with the prior stub of the same feature is expected.
8. **Write the story-ticket stubs** from the active tracker's per-provider ticket template — read `work_item_tracker` from `.shamt-core/shamt-config.json`:
   - `ado` → [`templates/ticket.ado.template.md`](../../../../../templates/ticket.ado.template.md)
   - `github` → [`templates/ticket.github.template.md`](../../../../../templates/ticket.github.template.md)
   - `local` or `none` → [`templates/ticket.github.template.md`](../../../../../templates/ticket.github.template.md) as the generic baseline; replace the template's static `**Tracker profile:** GitHub (see …)` line with `**Tracker profile:** {local|none}` to match the active config.

   For each **New** story, write `**Parent Feature:** {feature-slug}` (always) and `**Parent Epic:** {parent-epic-slug}` (when the parent feature has an epic; **omit entirely** when the parent feature is standalone) under H1, plus the scope one-liner verbatim in the body intake area; every other template section is left empty / placeholder; no validation footer. For **Kept** stories (re-decomposition only), **do not touch** the existing `ticket.md` (or any other story-folder artifacts — `spec.md`, `implementation_plan.md`, `feedback/`, etc.) — preserve all in-progress work; surface a notice if the user-approved scope one-liner differs from the existing body.
9. **Append to parent feature** — rewrite `## Target Stories` + `## Sequencing & Parallelization` wholesale to match the full new list (Kept + New); insert (or replace, on re-decomposition) a `Decomposed YYYY-MM-DD — N story stubs at stories/{slug-1}, stories/{slug-2}, …` line (slug-only — actual folders resolved via `stories/{slug}-*/` glob) **immediately above the validation footer** so the footer stays last. Preserve the existing validation footer; do not strip or duplicate it.
10. **Re-decomposition orphan handling.** Surface a warning listing the **Orphaned** folders (slugs in the prior list, absent from the new list) and ask the user to delete or repurpose manually — **do not auto-delete**. Kept stubs are not orphans.
11. **Suggest** `/clear` + `/e1-start-story {story-slug-N}` per stub. Do **not** auto-invoke — per [Principle 1](../../../../../templates/SHAMT_RULES.template.md#principle-1-phase-per-command--slug-resumability), each stub is independently resumable. `/e1-start-story` is **stub-aware** — it detects the back-ref headers in `ticket.md` and preserves them when fleshing out the rest of the Intake content.

## Key distinctions

- **Decomposition exit gate ≠ `/validate-artifact`.** The gate is a 2-condition stub-batch check run **before** stubs land on disk. `/validate-artifact` runs the full Pattern 1 loop against `feature.md` (already, before this command) and against each story-level artifact (later, via the Engineer flow). Do not conflate.
- **The individually-testable rubric is the hard constraint** on output. The Engineer flow can refuse a story that violates this; PO-flow enforcement at decomposition time is the contract.
- **Development-order dependencies between siblings are allowed** — they live in the parallelization analysis, not as a testability violation.
- **No tracker fetch** at this altitude — `/p4-decompose-feature` operates entirely on the already-written `feature.md`. The active tracker is read only to pick the **ticket template** for the stub bodies (Step 8).
- **No feature-level review.** The 16-category code-review framework stays story-level per Pattern 4.
- **No `/e1-start-story` auto-invocation.** Per Principle 1, every command stays independently runnable.

## Recommended model

Reasoning (Opus) — see [`reference/model_selection.md`](../../../../../reference/model_selection.md). Decomposition involves the individually-testable rubric, dependency analysis, parallelization callout, and global-slug discipline — all benefit from Opus's reasoning depth. Same justification as `/p2-decompose-epic`.

## Exit criteria

N story-stub folders exist: New stubs (and every stub on first decomposition) carry `**Parent Feature:** {feature-slug}` (always) and `**Parent Epic:** {parent-epic-slug}` (when the parent feature has an epic) back-ref headers under H1, plus the scope one-liner in the body and a `## Decomposition Context` breadth section, with all other template sections empty; Kept stubs (re-decomposition only) are preserved unchanged from before the invocation, including any in-progress engineer work inside. Every stub's scope one-liner passes the individually-testable rubric. The parent feature's `Target Stories` + `Sequencing & Parallelization` sections carry the approved list and analysis; a slug-only `Decomposed YYYY-MM-DD — N story stubs at stories/{slug-1}, stories/{slug-2}, …` line is present directly above the preserved `Validated …` footer (actual folder paths recovered via `stories/{slug}-*/` glob); orphaned stubs (on re-decomposition) surfaced as a warning, not auto-deleted; the user approved the batch with rubric verdicts surfaced.

<!-- Managed by Shamt — do not edit. Regenerate from shamt-core/host/templates/claude/skills/p4-decompose-feature/SKILL.md. -->
