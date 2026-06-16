---
name: pe0-draft
description: >
  Quick-capture an unrefined DRAFT epic from a one-line blurb — title + a
  Scratch Notes (stage-0 capture) section marked with the distinct
  `Draft (f0 — epic-idea capture, unrefined)` status and a banner — with NO
  open-questions dialog and NO formal Goal / Success Criteria / Scope
  structure. The full drafting pass is deferred to /pe1-define, which ingests
  a pe0 draft as its intake. Non-interactive; directly resolves a slug and
  writes to epics/{ID}-{slug}-{brief}/epic.md. Invoke when the user wants to
  quick-capture an epic idea, jot down an epic stub, or draft an epic for
  later.
triggers:
  - "draft an epic idea"
  - "quick-capture an epic"
  - "stub an epic"
  - "jot down an epic"
  - "draft this as a pe0"
---

## Overview

Mirrors the `/pe0-draft {slug} [blurb]` slash command. Same canonical body, two host wirings.

## Protocol

Follow the canonical `/pe0-draft` command body verbatim — see [`commands/pe0-draft.md`](../../commands/pe0-draft.md).

## Recommended model

Cheap (Haiku) — pe0 is mechanical: resolve a slug, seed a file, drop the blurb into Scratch Notes. No design judgment. See [`reference/model_selection.md`](../../../../../reference/model_selection.md).

## Exit criteria

`epics/{ID}-{slug}-{brief}/epic.md` exists with the draft marker status, the banner, and a Scratch Notes section; no formal Goal / Success Criteria / Scope structure, no open-questions dialog, no validation footer; the slug has been reported.

---

<!-- Managed by Shamt — do not edit. Regenerate from shamt-core/host/templates/claude/skills/pe0-draft/SKILL.md. -->
