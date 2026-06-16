---
name: pe1-define
description: >
  Run Phase 1 of the Shamt PO flow at the Epic altitude. Resolves a slug to an
  epic folder, fetches the work-item payload via the active tracker profile
  when the profile declares Epic support (ADO does; GitHub does not — falls
  through to freeform), consults .shamt-core/project-specific-files/ARCHITECTURE.md for architectural impact, and
  drives an open-questions iterative dialog over Goal, Success Criteria, and
  Scope / Non-Scope to produce epics/{ID}-{slug}-{brief}/epic.md. Leaves Target
  Features and Sequencing & Parallelization empty for /pe2-decompose. Invoke
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

Mirrors the `/pe1-define {slug}` slash command. Same canonical body, two host wirings — invoke either via natural language ("start an epic for the billing revamp") or via the explicit slash command.

## Protocol

Follow the canonical `/pe1-define` command body verbatim — see [`commands/pe1-define.md`](../../commands/pe1-define.md).

## Tracker fallback

When the active profile lacks Epic support (GitHub today), surface the one-line freeform-fallback notice and continue. **Do not silently fail; do not halt.** Per the freeform-fallback rule in [`reference/trackers/_contract.md`](../../../../../reference/trackers/_contract.md).

## Recommended model

Reasoning (Opus) — see [`reference/model_selection.md`](../../../../../reference/model_selection.md). Epic drafting is a design / multi-dimensional scoping task; the open-questions dialog benefits from Opus's reasoning depth.

## Exit criteria

Non-empty `epics/{ID}-{slug}-{brief}/epic.md` exists with `Goal`, `Success Criteria`, `Scope / Non-Scope` drafted; `Target Features` and `Sequencing & Parallelization` empty; `## Open Questions` empty; no validation footer yet; user has confirmed slug + content.

<!-- Managed by Shamt — do not edit. Regenerate from shamt-core/host/templates/claude/skills/pe1-define/SKILL.md. -->
