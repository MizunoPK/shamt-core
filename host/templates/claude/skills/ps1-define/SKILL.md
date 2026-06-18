---
name: ps1-define
description: >
  Run Stage 1 of the Shamt PO flow at the story altitude. Three input modes:
  (A) ingest an existing /ps0-draft stub (detect the Status: Draft marker +
  Scratch Notes section) — seed from Scratch Notes, deepen via open-questions
  dialog, strip the marker + Scratch Notes on completion (f1-style ingestion);
  (B) create a standalone story from scratch; (C) seed from a tracker
  work-item payload when the active profile supports the Story type. Mode
  disambiguation is filesystem-first: Mode A wins when the draft marker is
  present, Mode C wins next when tracker + slug shape align, Mode B is the
  default fallback. Consults .shamt-core/project-specific-files/ARCHITECTURE.md
  for architectural impact. Unlike /pe1-define and /pf1-define
  (which defer validation to /validate-artifact), /ps1-define runs an INLINE
  Pattern-1 validation loop so the command stamps the Validated footer itself
  — the readiness signal /e1-start-story keys on. Parent-slug batch mode:
  passing the parent **feature** slug defines + validates every story under
  that feature, sequentially — a stateless, disk-derived dispatch of the
  single-story logic (dialog + inline validation) that is itself resumable.
  Invoke when the user wants
  to define, flesh out, or polish a story planning ticket; or define all
  stories in the feature.
triggers:
  - "define a story"
  - "flesh out a ticket"
  - "polish the planning ticket"
  - "ready a story for the engineer"
  - "ingest a story draft"
  - "define all stories in the feature"
---

## Overview

Mirrors the `/ps1-define {slug} [--tracker={ado|github|local}]` slash command. Same canonical body, two host wirings.

## Protocol

Follow the canonical `/ps1-define` command body verbatim — see [`commands/ps1-define.md`](../../commands/ps1-define.md).

## Mode A (draft ingestion)

When the draft marker + Scratch Notes are detected (Step 2), the command seeds from Scratch Notes (Mode A input), drives the open-questions dialog (Step 6), **strips the marker + Scratch Notes on completion** (before the inline validation loop), then validates and stamps the footer.

## Tracker fallback

When the active profile lacks Story support, surface the one-line freeform-fallback notice and fall through to Mode A (if a stub exists) or Mode B. **Do not silently fail; do not halt.** Per the freeform-fallback rule in [`reference/trackers/_contract.md`](../../../../../reference/trackers/_contract.md).

## Recommended model

Reasoning (Opus) — design/dialog task + inline validation loop; see [`reference/model_selection.md`](../../../../../reference/model_selection.md).

## Exit criteria

Non-empty `epics/{epic-folder}/features/{feature-folder}/stories/{ID}-{slug}-{brief}/ticket.md` with ticket metadata + body intake area populated (scope one-liner, draft-mode seeds, deepened by dialog) + spec structure drafted; `## Open Questions` empty; other template sections (Summary, Description, Acceptance Criteria, etc.) left as template placeholders (Engineer flow's responsibility); nesting reflects the input mode (draft's parent in Mode A, resolved or default parent in Mode B/C); `shamt-state/active-story` and `shamt-state/active-feature` pointers written (Mode B/C only); **two-line footer block stamped** (`---` + `Validated {YYYY-MM-DD} — N rounds, 1 adversarial sub-agent confirmed`); user has confirmed scope + content. **Parent-slug batch mode** (a parent **feature** slug is passed): every story under the feature has been defined + validated per the above, skipping any already-validated child, with a one-line-per-child summary reported.

---

<!-- Managed by Shamt — do not edit. Regenerate from shamt-core/host/templates/claude/skills/ps1-define/SKILL.md. -->
