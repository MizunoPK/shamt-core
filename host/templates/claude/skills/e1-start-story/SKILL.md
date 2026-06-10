---
name: e1-start-story
description: >
  Run Phase 1 (Intake) of the Shamt Engineer flow. Resolves a slug to a story
  folder, fetches the work-item payload via the active tracker profile (ADO /
  GitHub / local) or falls through to freeform capture, and produces a
  validated ticket.md. Invoke when the user wants to start, intake, or kick off
  a new story; capture a ticket; pull a work item from the tracker; or import a
  GitHub issue / ADO work item into the story workflow.
triggers:
  - "start a story"
  - "start a new story"
  - "intake this ticket"
  - "kick off a story"
  - "pull this issue"
  - "fetch the ticket"
  - "create a story folder"
  - "begin a story for"
---

## Overview

This skill mirrors the `/e1-start-story {slug}` slash command. Same canonical body, two host wirings — invoke either via natural language ("start a story for ticket 1234") or via the explicit slash command.

## Protocol

Follow the canonical `/e1-start-story` command body verbatim — see [`commands/e1-start-story.md`](../../commands/e1-start-story.md). Summary:

1. Read `.shamt-core/shamt-config.json`; honor `--tracker={ado|github|local}` override.
2. Resolve `{id-or-slug}`: a ticket ID globs `stories/{ID}-*/`; a slug tries `stories/{slug}/` (exact) then **both** `stories/{slug}-*/` and `stories/*-{slug}-*/` (glob). Halt on multiple matches.
3. For new stories: allocate a ticket ID `T{N}` (max across `epics/`, `features/`, `stories/` + 1), ask for a 2–4-word brief description, and create `stories/{ID}-{slug}-{brief}/`; a PO-flow stub already has its ID — preserve it, and its `## Decomposition Context` (when present) seeds the intake deepening.
4. Branch on the active tracker:
   - `ado` / `github` — parse slug → ID; check `## Supported work-item types` for `Story` (freeform-fallback notice if not); run `## Primary fetch` and `## Auxiliary fetches`; write `raw/issue.json`, `raw/*.json`; render `ticket.md` from the per-provider template using the profile's `## Field mapping`.
   - `local` — `ticket.md` must already exist; halt otherwise.
   - `none` — freeform capture.
5. Freeform capture (when applicable) applies the **open-questions iterative dialog** — surface each question to the user one at a time, update the ticket, repeat.
6. Detect slug collisions; confirm the intake summary with the user; suggest `/clear` + `/e2-define-spec {slug}`.

## Recommended model

Cheap (Haiku) — see [`reference/model_selection.md`](../../../../../reference/model_selection.md). Intake is mechanical.

## Exit criteria

Non-empty `stories/{ID}-{slug}-{brief}/ticket.md` exists and the user has confirmed the slug + content.

---
Validated 2026-05-28 — 2 rounds, 1 adversarial sub-agent confirmed (Phase 5 implementation loop)

<!-- Managed by Shamt — do not edit. Regenerate from shamt-core/host/templates/claude/skills/e1-start-story/SKILL.md. -->
