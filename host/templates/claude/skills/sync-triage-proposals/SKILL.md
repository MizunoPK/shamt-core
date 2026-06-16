---
name: sync-triage-proposals
description: >
  Master-side step of the v2 master/child sync. Walk proposals/incoming/ in
  alphabetical order and decide promote / reject / defer / skip for each
  child-submitted proposal. Promote strips the {project}- filename prefix
  (derived from the proposal's Proposed by header) and moves the file to
  proposals/{slug}.md, then suggests /validate-artifact as the next command —
  it does NOT invoke validation itself (phase-per-command resumability per
  Principle 1). Reject moves to proposals/rejected/{slug}.md with a top-of-file
  note explaining why. Defer moves to proposals/deferred/{slug}.md. Skip leaves
  the file in incoming/ for a later pass. Invoke when the user wants to triage
  incoming proposals, walk the incoming queue, promote a child proposal,
  reject / defer a child submission, or process upstream-submitted proposals.
triggers:
  - "triage incoming proposals"
  - "walk proposals/incoming"
  - "process child-submitted proposals"
  - "promote / reject / defer this proposal"
  - "review the incoming proposal queue"
  - "decide on the incoming proposals"
---

## Overview

Mirrors the `/sync-triage-proposals` slash command. Same canonical body, two host wirings.

## Protocol

Follow the canonical `/sync-triage-proposals` command body verbatim — see [`commands/sync-triage-proposals.md`](../../commands/sync-triage-proposals.md).

## Recommended model

Balanced (Sonnet) — reading, surfacing, routing with light judgment per file. See [`reference/model_selection.md`](../../../../../reference/model_selection.md).

## Exit criteria

Every file in `proposals/incoming/` has been dispositioned or explicitly skipped. The triage summary has been printed. Promoted slugs have their next command stated.

## Why no auto-validation

Promote moves the file and stops. `/validate-artifact` is a separate phase, runnable by a fresh agent off `proposals/{slug}.md` alone. This matches every other master-side phase in the framework-update flow and keeps the slug-resumability contract intact (Principle 1).

---
Validated 2026-05-28 — 8 rounds (4 primary + 4 adversarial), final adversarial sub-agent confirmed (Phase 9 implementation re-validation). Mirrors the command-side fixes: derived-slug kebab-case check + inline regex-difference note.

<!-- Managed by Shamt — do not edit. Regenerate from shamt-core/host/templates/claude/skills/sync-triage-proposals/SKILL.md. -->
