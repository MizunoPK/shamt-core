---
name: f0-draft-proposal
description: >
  Phase 0 (optional) of the Shamt framework-update flow. Quick-capture an
  unrefined DRAFT proposal at proposals/{slug}.md (child:
  .shamt-core/proposals/{slug}.md) from a one-line blurb — title + a Scratch
  Notes (f0 capture) section marked with the distinct
  `Draft (f0 — audit capture, unrefined)` status and a banner — with NO
  open-questions dialog and NO formal Proposed Changes table. Resolving and
  fleshing it out is deferred to /f1-propose-update, which ingests an f0 draft
  as its intake. Non-destructive: never overwrites — appends a numeric slug
  suffix on collision. Used by /f5-audit-framework (master / self-host only) to
  capture each intricate finding so the audit loop continues instead of
  halting, and by a user directly for fast idea capture (the only audit-side
  framework-update activity available in a child, since the audit does not run
  there). Invoke when the user wants to quick-capture a framework idea, jot
  down a proposal stub, draft an f0 capture, or note an audit finding for later.
triggers:
  - "draft a proposal stub"
  - "quick-capture a framework idea"
  - "jot down a framework proposal"
  - "capture this as an f0 draft"
  - "note this framework finding for later"
  - "f0 draft this"
---

## Overview

Mirrors the `/f0-draft-proposal {slug} [blurb]` slash command. Same canonical body, two host wirings.

## Protocol

Follow the canonical `/f0-draft-proposal` command body verbatim — see [`commands/f0-draft-proposal.md`](../../commands/f0-draft-proposal.md). Summary:

1. **Resolve the target path** — prefer a top-level `proposals/` (master / self-host); otherwise `.shamt-core/proposals/` (child). Target is `{proposals-dir}/{slug}.md`.
2. **Slug-collision rule — non-destructive, non-interactive** — never overwrite, never prompt. If `{slug}.md` exists in **any** state (active top level or the `archive/` / `rejected/` / `deferred/` / `submitted/` / `already-merged/` subfolders), append the lowest free numeric suffix (`{slug}-2`, `{slug}-3`, …). Report the final slug written. (Recognizing whether an *addressing* draft already exists for a finding is the **caller's** judgment — the audit reads `proposals/` before deciding to capture — not a mechanical check inside f0.)
3. **Seed a bare-minimum f0 draft** — title; `Status: Draft (f0 — audit capture, unrefined)` (the distinct marker, not plain `Draft`); the banner line; a `## Scratch Notes (f0 capture)` section holding the `blurb` verbatim (implicated files mentioned informally if known). Leave the formal Proposed Changes table and Risks / Rollback / Validation Considerations as template placeholders. **No** open-questions dialog, **no** change list, **no** validation footer — all deferred to `/f1-propose-update`.
4. **Exit** — report the created path and the final slug (including any collision suffix). Suggest `/f1-propose-update {final-slug}` next (then `/sync-submit-proposal {final-slug}` on a child). When invoked **by the audit**, print no user next-command suggestion — the audit reports the captured slug in its own loop output and continues.

## Recommended model

Cheap (Haiku) — f0 is mechanical: resolve a slug, seed a file, drop the blurb into Scratch Notes. No design judgment. See [`reference/model_selection.md`](../../../../../reference/model_selection.md).

## Exit criteria

`{proposals-dir}/{final-slug}.md` exists with the f0 marker status, the banner, and a Scratch Notes section; no formal change list, no open-questions dialog, no validation footer; the final slug actually written (including any collision suffix) has been reported.

## Two callers

- **The framework audit** (`/f5-audit-framework`, master / self-host only) — drafts one f0 proposal per *intricate* finding so the continuous loop captures it and moves on instead of halting.
- **A user**, directly — fast idea capture. In a child project this is the only audit-side framework-update activity, because the audit itself does not run there; creating a new proposal file is not editing an imported canonical copy.

---
Created 2026-06-02 — by /f3-implement-update for proposals/audit-continuous-f0-draft-capture.md (Phase 0 of the framework-update flow). Verified under the proposal's Phase 6 /f5-audit-framework sweep.

<!-- Managed by Shamt — do not edit. Regenerate from shamt-core/host/templates/claude/skills/f0-draft-proposal/SKILL.md. -->
