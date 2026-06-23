---
name: f3-implement-update
description: >
  Phase 4 of the Shamt framework-update flow. Read a validated proposal and
  apply the edits — framework class (proposals/{slug}.md): canonical sources
  only, either inline (≤10 file ops) or via plan-executor (architect/builder
  split); project-specific class (child only,
  proposals/project-specific/{slug}.md): .shamt-core/project-specific-files/
  only (inline or via plan-executor the same way, per row count), no branch
  created, next phase is /f6 (skips /f4 regen). Hard rule: generated .claude/
  files are NEVER edited directly for
  either class. Invoke when the user wants to implement a framework update,
  apply the proposal, execute the proposal's plan, or land the canonical
  edits for any proposal.
triggers:
  - "implement the framework update"
  - "implement the proposal"
  - "apply the proposal"
  - "execute the proposal plan"
  - "land the framework changes"
  - "apply proposals/{slug}.md"
  - "do the canonical edits for the proposal"
---

## Overview

Mirrors the `/f3-implement-update {slug}` slash command. Same canonical body, two host wirings.

## Protocol

Follow the canonical `/f3-implement-update` command body verbatim — see [`commands/f3-implement-update.md`](../../commands/f3-implement-update.md).

## Recommended models

- Orchestration (this command): Balanced (Sonnet).
- Builder (when Phase 3 ran): Cheap (Haiku) via [`agents/plan-executor.md`](../../agents/plan-executor.md).

See [`reference/model_selection.md`](../../../../../reference/model_selection.md).

## Exit criteria

Every Proposed Changes row covered by a real diff entry; no generated-file edits.
- **Framework class:** `/f4-regen-framework` suggested; `proposal/{NN}-{slug}` branch created before editing, no commit — commit + squash-merge land at `/f6-archive-proposal` (Phase 7), after regen.
- **Project-specific class (child only):** `/f6-archive-proposal {slug}` suggested (skips `/f4`); no branch created (`.shamt-core/` is git-ignored); no commit.

## Hard rule

**Never edit generated `.claude/` files** — for either proposal class. For the **framework class**, edits go to canonical sources; regen (Phase 5) propagates. For the **project-specific class**, edits go to `.shamt-core/project-specific-files/` only; no regen is run. If a step's path looks like `.claude/...`, halt unconditionally and report the path back as a proposal scope issue.

---
Validated 2026-05-28 — 4 rounds, 1 adversarial sub-agent confirmed (Phase 8 implementation loop)

<!-- Managed by Shamt — do not edit. Regenerate from shamt-core/host/templates/claude/skills/f3-implement-update/SKILL.md. -->
