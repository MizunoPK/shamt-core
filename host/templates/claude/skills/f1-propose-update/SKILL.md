---
name: f1-propose-update
description: >
  Author or edit a framework-update proposal at .shamt-core/proposals/{slug}.md. Phase 1
  of the Shamt framework-update flow: seed from the canonical template — from
  scratch, from a free-text [blurb], or by ingesting an existing f0
  audit-capture draft — draft the Problem and Proposed Changes (canonical
  paths only — never .claude/), fill Risks / Rollback / Validation
  Considerations, and apply the open-questions iterative dialog until the Open
  Questions section is empty. For an incident-originated proposal (bug /
  feedback / issue / audit capture) it first drives an independent adversarial
  root-cause diagnosis (Opus root-cause-diagnoser + Haiku zero-bias
  confirmation) before drafting the change set. Invoke when the user wants to propose a framework
  change, write up a framework fix, draft a proposal, flesh out an f0 draft, or
  capture an upstream-worthy idea.
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

`.shamt-core/proposals/{slug}.md` exists, has no open questions, every Proposed Changes row points at a canonical (non-`.claude/`) path, and the next phase has been suggested.

---
Validated 2026-05-28 — 4 rounds, 1 adversarial sub-agent confirmed (Phase 8 implementation loop)
Touched 2026-06-02 — mirrored the f1 command's three input modes (blank / blurb / f0-draft ingestion) and the f0-draft slug-resolution branch into the summary + frontmatter description. Per proposals/audit-continuous-f0-draft-capture.md.

<!-- Managed by Shamt — do not edit. Regenerate from shamt-core/host/templates/claude/skills/f1-propose-update/SKILL.md. -->
