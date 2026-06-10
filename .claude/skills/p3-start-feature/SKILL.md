---
name: p3-start-feature
description: >
  Run Phase 3 of the Shamt PO flow at the Feature altitude. Three input modes:
  (A) flesh out an existing feature stub written by /p2-decompose-epic — preserve
  the **Parent Epic:** back-ref + Goal one-liner and drive the open-questions
  dialog — seeded by the stub's Decomposition Context when present — to populate Success Criteria + deepen Scope; (B) create a standalone feature
  from scratch with **Parent Epic:** left blank; (C) seed from a tracker
  work-item payload when the active profile (read from .shamt-core/shamt-config.json)
  supports the Feature type — ADO does; GitHub does not, falls through to
  Mode A or B. Mode disambiguation is filesystem-first: Mode A wins when a
  stub exists, Mode C wins next when the tracker + slug shape align, Mode B
  is the default fallback. Consults .shamt-core/project-specific-files/ARCHITECTURE.md for architectural impact
  in all three modes. Invoke when the user wants to start, flesh out, define,
  or open a feature; capture an ADO Feature; or scope a feature for an
  upcoming initiative.
triggers:
  - "start a feature"
  - "flesh out feature {slug}"
  - "begin feature"
  - "open a new feature"
  - "scope this feature"
  - "create feature"
  - "pull this ADO feature"
  - "capture this work as a feature"
---

## Overview

Mirrors the `/p3-start-feature {slug}` slash command. Same canonical body, two host wirings — invoke either via natural language ("flesh out the payments-revamp feature stub") or via the explicit slash command.

## Protocol

Follow the canonical `/p3-start-feature` command body verbatim — see [`commands/p3-start-feature.md`](../../commands/p3-start-feature.md). Summary:

1. **Read configuration.** `.shamt-core/shamt-config.json` → `work_item_tracker`; honor `--tracker={ado|github|local}` override. Read the corresponding profile in [`reference/trackers/`](../../../../../reference/trackers/). The override only affects Mode C — a no-op in Mode A and Mode B (a one-line notice surfaces if the flag is supplied in those modes).
2. **Resolve `{id-or-slug}`** — a ticket ID globs `features/{ID}-*/`; a slug tries `features/{slug}/` (exact) then **both** `features/{slug}-*/` and `features/*-{slug}-*/` (glob). Halt on multiple matches. A new feature gets an allocated ticket ID; a Mode A stub preserves its ID. On a one-match resolution, **inspect `feature.md`** to decide Mode A vs. re-entry:
   - Stub shape (decomposition-authored fields — `**Parent Epic:**` + `## Goal`, plus `## Scope / Non-Scope` + `## Decomposition Context` on a richer-cataloging stub — filled, but the depth sections `## Success Criteria` / `## Open Questions` empty) → Mode A.
   - Depth sections drafted (a prior `/p3-start-feature` deep-dive ran) → re-entry. Confirm refetch / overwrite / extend / exit. **Preserve `**Parent Epic:**` and (when present) `**Parent Feature:**` back-ref headers verbatim** regardless of branch; strip any prior `Validated …` footer when extending.
3. **For new features** (zero matches): ask the user for a 2–4-word brief description; propose and create `features/{ID}-{slug}-{brief}/`. Mode B or Mode C depending on tracker + slug shape.
4. **Mode disambiguation order** (filesystem-first):
   - **Mode A** — stub exists. Preserve `**Parent Epic:** {epic-slug}` back-ref + `## Goal` one-liner verbatim. Open-questions dialog populates `Success Criteria` + `Scope / Non-Scope`.
   - **Mode C** — no stub, but the active profile supports Feature AND the slug parses to a tracker ID. ADO supports Feature natively; GitHub does not. Fetch the payload, apply the profile's `## Field mapping` to seed `feature.md`. **No `raw/` subfolder** — preserve fidelity data inline in an `## All Remaining Fields` appendix at the bottom of `feature.md` (above the eventual validation footer). Same rule as `/p1-start-epic`.
   - **Mode B** — no stub, tracker doesn't apply. Create `feature.md` from [`templates/feature.template.md`](../../../../../templates/feature.template.md) with `**Parent Epic:**` **left blank** — standalone (no parent epic).
5. **Consult `.shamt-core/project-specific-files/ARCHITECTURE.md`** (advisory). Flag architectural impact inline in `Scope / Non-Scope` as `**Architecture impact:** {…}` when the feature implies a new service / boundary / data store / external integration. **Do NOT consult `.shamt-core/project-specific-files/CODING_STANDARDS.md`** — coding style is irrelevant at the feature altitude. Same rule as `/p1-start-epic`.
6. **Open-questions iterative dialog** ([Principle 2](../../../../../templates/SHAMT_RULES.template.md#principle-2-open-questions-iterative-dialog)) — surface each question one at a time via `AskUserQuestion`, update the feature with each answer, drain the section before exit. Drafts `Success Criteria` and `Scope / Non-Scope` (and in Mode B / Mode C, `Goal`). **Mode A preserves the stub's `## Goal` verbatim.** **Leaves `Target Stories` and `Sequencing & Parallelization` empty** — owned by `/p4-decompose-feature`.
7. **Detect slug collisions; confirm the intake summary with the user.** Feature slugs are globally unique per the flat folder layout.
8. **Suggest** `/clear` + `/validate-artifact features/{ID}-{slug}-{brief}/feature.md` as the next command. Do **not** auto-invoke — per [Principle 1](../../../../../templates/SHAMT_RULES.template.md#principle-1-phase-per-command--slug-resumability), every command stays independently runnable.

## Tracker fallback

When the active profile lacks Feature support (GitHub today), surface the one-line freeform-fallback notice (`tracker profile {name} has no Feature work-item type — proceeding freeform`) and fall through to Mode A (if a stub exists) or Mode B. **Do not silently fail; do not halt.** Per the freeform-fallback rule in [`reference/trackers/_contract.md`](../../../../../reference/trackers/_contract.md).

## Recommended model

Reasoning (Opus) — see [`reference/model_selection.md`](../../../../../reference/model_selection.md). Feature drafting is a design / multi-dimensional scoping task; the open-questions dialog benefits from Opus's reasoning depth. Same justification as `/p1-start-epic`.

## Exit criteria

Non-empty `features/{ID}-{slug}-{brief}/feature.md` exists with `Goal`, `Success Criteria`, `Scope / Non-Scope` drafted; `Target Stories` and `Sequencing & Parallelization` empty; `## Open Questions` empty; `**Parent Epic:**` reflects the input mode (stub-preserved in Mode A, blank in Mode B, seeded if a tracker parent maps to a local epic in Mode C); no validation footer yet; user has confirmed slug + content.

<!-- Managed by Shamt — do not edit. Regenerate from shamt-core/host/templates/claude/skills/p3-start-feature/SKILL.md. -->
