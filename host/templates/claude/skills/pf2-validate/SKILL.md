---
name: pf2-validate
description: >
  Run Stage 2 of the Shamt PO flow at the Feature altitude — the dedicated
  validate stage between /pf1-define and /pf3-decompose. In single mode resolves
  a feature slug and runs the /validate-artifact Pattern-1 loop on feature.md,
  stamping the Validated footer, then refreshes the epic STATUS.md. Parent-slug
  batch mode: passing the parent epic slug batch-validates every feature under
  the epic sequentially — a stateless, disk-derived dispatcher that is itself
  resumable (skips already-validated children). Invoke when the user wants to
  validate a feature, run the validate stage for a feature, footer a feature, or
  validate all features in the epic.
triggers:
  - "validate the feature"
  - "validate feature {slug}"
  - "run the validate stage for this feature"
  - "footer the feature"
  - "validate all features in the epic"
  - "validate every feature under this epic"
---

## Overview

Mirrors the `/pf2-validate {slug}` slash command. Same canonical body, two host wirings. A thin altitude-aware wrapper over the `/validate-artifact` Pattern-1 loop, plus the #39 parent-slug batch mode (parent epic slug → validate all features).

## Protocol

Follow the canonical `/pf2-validate` command body verbatim — see [`commands/pf2-validate.md`](../../commands/pf2-validate.md).

## Recommended model

Reasoning (Opus) — the Pattern-1 validation loop escalates to Reasoning per the `/validate-artifact` guidance. See [`reference/model_selection.md`](../../../../../reference/model_selection.md).

## Exit criteria

(Single mode) `feature.md` carries a `Validated …` footer stamped by the Pattern-1 loop; the epic's `STATUS.md` has been re-derived; `/pf3-decompose {slug}` suggested. (Parent-slug batch mode, an epic slug is passed) every feature under the epic has been validated, skipping any already-validated child and halting at the first unresolvable child, with a one-line-per-child summary reported.

<!-- Managed by Shamt — do not edit. Regenerate from shamt-core/host/templates/claude/skills/pf2-validate/SKILL.md. -->
