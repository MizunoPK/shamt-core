---
name: sync-proposals
description: >
  Child-side step of the v2 master/child sync. Batch-prepare every active
  child-local proposal under .shamt-core/proposals/ for upstream submission to
  master. Iterates all top-level *.md proposals regardless of status (f0 draft,
  validated, or in-progress Draft — no validation-footer gate), strips any
  numeric ID, reads project_name from .shamt-core/shamt-config.json, prints one
  copy-paste block per proposal with its master-side target path
  (proposals/incoming/{project}-{slug}.md) for manual copy-paste, and moves each
  local copy to .shamt-core/proposals/submitted/{slug}.md to mark "awaiting
  decision". Does NOT push to master, open PRs, or file issues — the submission
  is manual copy. Invoke when the user wants to send proposals upstream, ship
  proposals to master, submit framework changes, or push proposals up.
triggers:
  - "sync proposals"
  - "submit the proposals"
  - "send the proposals upstream"
  - "ship these proposals to master"
  - "push these framework changes up"
  - "submit framework updates"
---

## Overview

Mirrors the `/sync-proposals` slash command. Same canonical body, two host wirings.

## Protocol

Follow the canonical `/sync-proposals` command body verbatim — see [`commands/sync-proposals.md`](../../commands/sync-proposals.md).

## Recommended model

Cheap (Haiku) — list files, read them, print, move. Mechanical. See [`reference/model_selection.md`](../../../../../reference/model_selection.md).

## Exit criteria

- Each active proposal now lives at `.shamt-core/proposals/submitted/{slug}.md` with its numeric ID stripped, and no longer at its original top-level location.
- One fenced copy-paste block per proposal has been printed to chat with the master-side target path stated above it.
- The top-level active proposal set is now empty.

## Re-submission

If master rejected a prior submission and the user wants to revise: manually move `.shamt-core/proposals/submitted/{slug}.md` back to `.shamt-core/proposals/{slug}.md`, edit, then re-run `/sync-proposals`.

## Already-merged follow-up

After master triages each submitted proposal and (if promoted) implements / archives it, the next `/sync-import-shamt` run on the child auto-moves `.shamt-core/proposals/submitted/{slug}.md` → `.shamt-core/proposals/already-merged/{slug}.md` when it detects the matching `proposals/archive/{slug}.md` on master. No manual cleanup needed for the promoted-and-merged path.

<!-- Managed by Shamt — do not edit. Regenerate from shamt-core/host/templates/claude/skills/sync-proposals/SKILL.md. -->
