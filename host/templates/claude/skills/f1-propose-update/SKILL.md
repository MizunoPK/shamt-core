---
name: f1-propose-update
description: >
  Author or edit a framework-update proposal at .shamt-core/proposals/{slug}.md
  (framework class) or .shamt-core/proposals/project-specific/{slug}.md
  (project-specific class — child-side only, strictly local). Phase 1 of the
  Shamt framework-update flow: on the child side, first asks whether the change
  is project-specific (edit this project's .shamt-core/project-specific-files/
  docs) or framework (would benefit master Shamt and every project); seed from
  the canonical template — from scratch, from a free-text [blurb], or by
  ingesting an existing f0 audit-capture draft — draft the Problem and Proposed
  Changes (canonical paths only for framework class, project-specific-files/
  only for project-specific class — never .claude/), fill Risks / Rollback /
  Validation Considerations, and apply the open-questions iterative dialog until
  the Open Questions section is empty. For an incident-originated proposal (bug /
  feedback / issue / audit capture) it first drives an independent adversarial
  root-cause diagnosis (Opus root-cause-diagnoser + Haiku zero-bias
  confirmation) before drafting the change set. Invoke when the user wants to propose a framework
  change, write up a framework fix, draft a proposal, flesh out an f0 draft,
  capture an upstream-worthy idea, or update this project's architecture /
  coding-standards / testing-standards docs under a governed proposal loop.
triggers:
  - "propose a framework update"
  - "propose a framework change"
  - "write up a proposal"
  - "draft a proposal"
  - "edit the proposal"
  - "flesh out the f0 draft"
  - "propose an update to shamt"
  - "capture this as a framework proposal"
  - "upstream this idea"
---

## Overview

Mirrors the `/f1-propose-update {slug}` slash command. Same canonical body, two host wirings.

## Protocol

Follow the canonical `/f1-propose-update` command body verbatim — see [`commands/f1-propose-update.md`](../../commands/f1-propose-update.md).

## Recommended model

Balanced (Sonnet) — structural analysis. The Phase 2 validation loop escalates to Reasoning (Opus). See [`reference/model_selection.md`](../../../../../reference/model_selection.md).

## Exit criteria

The proposal file exists and has no open questions:
- Framework class: `.shamt-core/proposals/{slug}.md` (child) or `proposals/{NN}-{slug}.md` (master) — every Proposed Changes row points at a canonical (non-`.claude/`) path.
- Project-specific class (child only): `.shamt-core/proposals/project-specific/{slug}.md` — every Proposed Changes row points at a `.shamt-core/project-specific-files/` path.

The next phase has been suggested in chat.

---
Validated 2026-05-28 — 4 rounds, 1 adversarial sub-agent confirmed (Phase 8 implementation loop)
Touched 2026-06-02 — mirrored the f1 command's three input modes (blank / blurb / f0-draft ingestion) and the f0-draft slug-resolution branch into the summary + frontmatter description. Per proposals/audit-continuous-f0-draft-capture.md.

<!-- Managed by Shamt — do not edit. Regenerate from shamt-core/host/templates/claude/skills/f1-propose-update/SKILL.md. -->
