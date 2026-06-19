---
name: pf1-define
description: >
  Run Phase 3 of the Shamt PO flow at the Feature altitude. Three input modes:
  (A) flesh out an existing feature stub written by /pe3-decompose — preserve
  the Goal one-liner and drive the open-questions dialog — seeded by the stub's Decomposition Context when present — to populate Success Criteria + deepen Scope (parentage is the folder path); (B) create a standalone feature
  under the Tech Stories epic (per #15); (C) seed from a tracker
  work-item payload when the active profile (read from .shamt-core/shamt-config.json)
  supports the Feature type — ADO does; GitHub does not, falls through to
  Mode A or B. Mode disambiguation is filesystem-first: Mode A wins when a
  stub exists, Mode C wins next when the tracker + slug shape align, Mode B
  is the default fallback. Consults .shamt-core/project-specific-files/ARCHITECTURE.md for architectural impact
  in all three modes. Parent-slug batch mode: passing the parent **epic** slug
  defines every feature under that epic, sequentially — a stateless,
  disk-derived dispatch of the single-feature logic that is itself resumable.
  Invoke when the user wants to start, flesh out, define,
  or open a feature; define all features in the epic; capture an ADO Feature;
  or scope a feature for an upcoming initiative.
triggers:
  - "start a feature"
  - "flesh out feature {slug}"
  - "begin feature"
  - "open a new feature"
  - "scope this feature"
  - "create feature"
  - "pull this ADO feature"
  - "capture this work as a feature"
  - "define all features in the epic"
---

## Overview

Mirrors the `/pf1-define {slug}` slash command. Same canonical body, two host wirings — invoke either via natural language ("flesh out the payments-revamp feature stub") or via the explicit slash command.

## Protocol

Follow the canonical `/pf1-define` command body verbatim — see [`commands/pf1-define.md`](../../commands/pf1-define.md).

## Tracker fallback

When the active profile lacks Feature support (GitHub today), surface the one-line freeform-fallback notice (`tracker profile {name} has no Feature work-item type — proceeding freeform`) and fall through to Mode A (if a stub exists) or Mode B. **Do not silently fail; do not halt.** Per the freeform-fallback rule in [`reference/trackers/_contract.md`](../../../../../reference/trackers/_contract.md).

## Recommended model

Reasoning (Opus) — see [`reference/model_selection.md`](../../../../../reference/model_selection.md). Feature drafting is a design / multi-dimensional scoping task; the open-questions dialog benefits from Opus's reasoning depth. Same justification as `/pe1-define`.

## Exit criteria

Non-empty `epics/{epic-folder}/features/{ID}-{slug}-{brief}/feature.md` exists nested with `Goal`, `Success Criteria`, `Scope / Non-Scope` drafted; `Target Stories` and `Sequencing & Parallelization` empty; `## Open Questions` empty; nesting reflects the input mode (stub's parent in Mode A, Tech Stories epic in Mode B, matched or Tech Stories epic in Mode C); `shamt-state/active-feature` and `shamt-state/active-epic` pointers written; no validation footer yet; user has confirmed slug + content. **Parent-slug batch mode** (a parent **epic** slug is passed): every feature under the epic has been defined per the above, skipping any already-defined child, with a one-line-per-child summary reported.

<!-- Managed by Shamt — do not edit. Regenerate from shamt-core/host/templates/claude/skills/pf1-define/SKILL.md. -->
