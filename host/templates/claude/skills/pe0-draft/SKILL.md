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

Follow the canonical `/pe0-draft` command body verbatim — see [`commands/pe0-draft.md`](../../commands/pe0-draft.md). Summary:

1. **Resolve the target path** — confirm `epics/` exists. Apply slug-collision rule to detect a global collision. Record the slug.
2. **Slug-collision rule — non-destructive, non-interactive** — never overwrite, never prompt. If `{slug}` is taken globally (per §PO-tree resolution), halt and ask for a different slug. (Epic slugs are user-chosen and globally unique, unlike `/f0-draft-proposal`'s numeric-suffix fallback — per the PO-flow design.)
3. **Seed a bare-minimum pe0 draft** — allocate ticket ID (`max` across the tree + 1); ask for a 2–4-word brief; create `epics/{ID}-{slug}-{brief}/` and write `epic.md` with: H1; `**Ticket ID:** T{N}`; `**Status:** Draft (f0 — epic-idea capture, unrefined)` (the distinct marker); the banner line; a `## Scratch Notes (stage-0 capture)` section holding the blurb verbatim (or a fill-in prompt if no blurb). Leave formal Goal / Success Criteria / Scope / Target Features / Sequencing as template placeholders. **No** open-questions dialog, **no** change list, **no** validation footer — all deferred to `/pe1-define`.
4. **Exit** — report the created path and slug. Suggest `/pe1-define {slug}` next.

## Recommended model

Cheap (Haiku) — pe0 is mechanical: resolve a slug, seed a file, drop the blurb into Scratch Notes. No design judgment. See [`reference/model_selection.md`](../../../../../reference/model_selection.md).

## Exit criteria

`epics/{ID}-{slug}-{brief}/epic.md` exists with the draft marker status, the banner, and a Scratch Notes section; no formal Goal / Success Criteria / Scope structure, no open-questions dialog, no validation footer; the slug has been reported.

---

<!-- Managed by Shamt — do not edit. Regenerate from shamt-core/host/templates/claude/skills/pe0-draft/SKILL.md. -->
