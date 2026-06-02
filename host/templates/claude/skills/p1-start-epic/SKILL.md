---
name: p1-start-epic
description: >
  Run Phase 1 of the Shamt PO flow at the Epic altitude. Resolves a slug to an
  epic folder, fetches the work-item payload via the active tracker profile
  when the profile declares Epic support (ADO does; GitHub does not — falls
  through to freeform), consults .shamt-core/project-specific-files/ARCHITECTURE.md for architectural impact, and
  drives an open-questions iterative dialog over Goal, Success Criteria, and
  Scope / Non-Scope to produce epics/{slug}-{brief}/epic.md. Leaves Target
  Features and Sequencing & Parallelization empty for /p2-decompose-epic. Invoke
  when the user wants to start, create, or open a new epic; capture an ADO
  Epic; or scope an epic for an upcoming initiative.
triggers:
  - "start an epic"
  - "create epic"
  - "new epic {slug}"
  - "open a new epic"
  - "scope this epic"
  - "begin an epic for"
  - "pull this ADO epic"
  - "capture this initiative as an epic"
---

## Overview

Mirrors the `/p1-start-epic {slug}` slash command. Same canonical body, two host wirings — invoke either via natural language ("start an epic for the billing revamp") or via the explicit slash command.

## Protocol

Follow the canonical `/p1-start-epic` command body verbatim — see [`commands/p1-start-epic.md`](../../commands/p1-start-epic.md). Summary:

1. **Read configuration.** `.shamt-core/shamt-config.json` → `work_item_tracker`; honor `--tracker={ado|github|local}` override. Read the corresponding profile in [`reference/trackers/`](../../../../../reference/trackers/).
2. **Resolve `{slug}`** to `epics/{slug}/` (exact) or `epics/{slug}-*/` (glob). Halt on multiple matches. On re-entry to a populated `epic.md`, confirm extend / overwrite / exit; **strip any prior `Validated …` footer if extending**.
3. **For new epics:** ask the user for a 2–4-word brief description; propose and create `epics/{slug}-{brief}/`.
4. **Branch on the active tracker:**
   - **`ado`** — parse slug → ID; check `## Supported work-item types` for `Epic` (freeform-fallback notice if not); run `## Primary fetch`; map `Title / Type / State / Description / Acceptance Criteria` into `epic.md`'s sections per the profile's `## Field mapping`. **No `raw/` subfolder** — preserve fidelity data inline in an `## All Remaining Fields` appendix at the bottom of `epic.md` (above the eventual validation footer).
   - **`github`** — surface `tracker profile github has no Epic work-item type — proceeding freeform` and fall through to freeform capture.
   - **`local` / `none`** — freeform capture.
5. **Consult `.shamt-core/project-specific-files/ARCHITECTURE.md`** (advisory). Flag architectural impact inline in `Scope / Non-Scope` as `**Architecture impact:** {…}` when the epic implies a new service / boundary / data store / external integration. **Do NOT consult `.shamt-core/project-specific-files/CODING_STANDARDS.md`** — coding style is irrelevant at the epic altitude.
6. **Open-questions iterative dialog** ([Principle 2](../../../../../templates/SHAMT_RULES.template.md#principle-2-open-questions-iterative-dialog)) — surface each question one at a time via `AskUserQuestion`, update the epic with each answer, drain the section before exit. Drafts `Goal`, `Success Criteria`, `Scope / Non-Scope`. **Leaves `Target Features` and `Sequencing & Parallelization` empty** — owned by `/p2-decompose-epic`.
7. **Detect slug collisions; confirm the intake summary with the user.**
8. **Suggest** `/clear` + `/validate-artifact epics/{slug}-{brief}/epic.md` as the next command. Do **not** auto-invoke — per [Principle 1](../../../../../templates/SHAMT_RULES.template.md#principle-1-phase-per-command--slug-resumability), every command stays independently runnable.

## Tracker fallback

When the active profile lacks Epic support (GitHub today), surface the one-line freeform-fallback notice and continue. **Do not silently fail; do not halt.** Per the freeform-fallback rule in [`reference/trackers/_contract.md`](../../../../../reference/trackers/_contract.md).

## Recommended model

Reasoning (Opus) — see [`reference/model_selection.md`](../../../../../reference/model_selection.md). Epic drafting is a design / multi-dimensional scoping task; the open-questions dialog benefits from Opus's reasoning depth.

## Exit criteria

Non-empty `epics/{slug}-{brief}/epic.md` exists with `Goal`, `Success Criteria`, `Scope / Non-Scope` drafted; `Target Features` and `Sequencing & Parallelization` empty; `## Open Questions` empty; no validation footer yet; user has confirmed slug + content.

<!-- Managed by Shamt — do not edit. Regenerate from shamt-core/host/templates/claude/skills/p1-start-epic/SKILL.md. -->
