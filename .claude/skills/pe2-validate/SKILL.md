---
name: pe2-validate
description: >
  Run Stage 2 of the Shamt PO flow at the Epic altitude — the dedicated validate
  stage between /pe1-define and /pe3-decompose. Resolves the epic slug and runs
  the /validate-artifact Pattern-1 loop on the epic's epic.md, stamping the
  Validated footer, then refreshes the epic STATUS.md. Single mode only — epic
  is the top altitude, no parent to batch from. Invoke when the user wants to
  validate the epic, run the validate stage for an epic, footer an epic, or
  validate an epic before decomposing it.
triggers:
  - "validate the epic"
  - "validate epic {slug}"
  - "run the validate stage for this epic"
  - "footer the epic"
  - "validate this epic before decomposing"
---

## Overview

Mirrors the `/pe2-validate {slug}` slash command. Same canonical body, two host wirings. A thin altitude-aware wrapper over the `/validate-artifact` Pattern-1 loop; single mode only (epic is the top altitude).

## Protocol

Follow the canonical `/pe2-validate` command body verbatim — see [`commands/pe2-validate.md`](../../commands/pe2-validate.md).

## Recommended model

Reasoning (Opus) — the Pattern-1 validation loop escalates to Reasoning per the `/validate-artifact` guidance. See [`reference/model_selection.md`](../../../../../reference/model_selection.md).

## Exit criteria

`epics/{epic-folder}/epic.md` carries a `Validated …` footer stamped by the Pattern-1 loop; the epic's `STATUS.md` has been re-derived; `/pe3-decompose {slug}` has been suggested.

<!-- Managed by Shamt — do not edit. Regenerate from shamt-core/host/templates/claude/skills/pe2-validate/SKILL.md. -->
