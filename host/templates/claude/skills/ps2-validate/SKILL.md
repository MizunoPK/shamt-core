---
name: ps2-validate
description: >
  Run Stage 2 of the Shamt PO flow at the Story altitude — the dedicated validate
  stage after /ps1-define. In single mode resolves a story slug and runs the
  inline /validate-artifact Pattern-1 loop on ticket.md, stamping the Validated
  footer (the readiness signal /e1-start-story keys on), then refreshes the epic
  STATUS.md. Parent-slug batch mode: passing the parent feature slug
  batch-validates every story under the feature sequentially — a stateless,
  disk-derived dispatcher that is itself resumable (skips already-validated
  children). Grandparent-slug batch mode: passing a parent epic slug
  batch-validates every story in the epic's full story subtree, sequentially,
  by dispatching the feature→stories validate batch per feature — still a
  single-phase (story-validate-only) stateless dispatcher. Invoke when the user
  wants to validate a story, run the validate stage for a story, footer a
  ticket, validate all stories in the feature, or validate all stories in
  the epic.
triggers:
  - "validate the story"
  - "validate story {slug}"
  - "run the validate stage for this story"
  - "footer the ticket"
  - "validate all stories in the feature"
  - "validate every story under this feature"
  - "validate all stories in the epic"
  - "validate every story under this epic"
---

## Overview

Mirrors the `/ps2-validate {slug}` slash command. Same canonical body, two host wirings. A thin altitude-aware wrapper over the `/validate-artifact` Pattern-1 loop (the loop moved out of `/ps1-define`), plus the #39 parent-slug batch mode (parent feature slug → validate all stories).

## Protocol

Follow the canonical `/ps2-validate` command body verbatim — see [`commands/ps2-validate.md`](../../commands/ps2-validate.md).

## Recommended model

Reasoning (Opus) — the Pattern-1 validation loop escalates to Reasoning per the `/validate-artifact` guidance. See [`reference/model_selection.md`](../../../../../reference/model_selection.md).

## Exit criteria

(Single mode) `ticket.md` carries a `Validated …` footer stamped by the inline Pattern-1 loop; the epic's `STATUS.md` has been re-derived; `/e1-start-story {slug}` suggested. (Parent-slug batch mode, a feature slug is passed) every story under the feature has been validated, skipping any already-validated child and halting at the first unresolvable child, with a one-line-per-child summary reported. (Grandparent-slug batch mode, an epic slug is passed) every story under every feature of the epic has been validated, skipping already-validated stories and halting at the first unresolvable feature/story, with a one-line-per-feature summary reported.

<!-- Managed by Shamt — do not edit. Regenerate from shamt-core/host/templates/claude/skills/ps2-validate/SKILL.md. -->
