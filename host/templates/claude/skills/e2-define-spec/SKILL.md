---
name: e2-define-spec
description: >
  Run Phase 2 (Spec) of the Shamt Engineer flow on a story whose ticket has
  been captured. Targeted research; design dialog at Gate 2a with 1–3 option
  comparisons; spec.md + context.md drafting (always full — no path selection);
  validation; and Gate 2b approval. Invoke when the user wants to spec a
  story, design the approach, run the spec protocol, write a spec, draft
  spec/context, or work through the design dialog for an intaken ticket.
triggers:
  - "spec this ticket"
  - "spec this story"
  - "write a spec for"
  - "define the spec"
  - "design this story"
  - "run the spec protocol"
  - "do the spec phase"
  - "draft spec and context"
---

## Overview

Mirrors the `/e2-define-spec {slug}` slash command. Same canonical body, two host wirings.

## Protocol

Follow the canonical `/e2-define-spec` command body verbatim — see [`commands/e2-define-spec.md`](../../commands/e2-define-spec.md). Resolve the story folder per `templates/SHAMT_RULES.template.md` §PO-tree resolution (tree-wide glob + legacy-flat fallback); `stories/{slug}/` below denotes that resolved folder.

## Recommended models

- Research: Balanced (Sonnet).
- Gate 2a design dialog: Reasoning (Opus).
- Validation loop primary: Reasoning (Opus). Sub-agent: Cheap (Haiku) via `validation-checker`.

See [`reference/model_selection.md`](../../../../../reference/model_selection.md).

## Exit criteria

Validated `spec.md` and `context.md` approved by the user at Gate 2b; Open Questions empty or deferred with reason.

---
Validated 2026-05-28 — 2 rounds, 1 adversarial sub-agent confirmed (Phase 5 implementation loop)

<!-- Managed by Shamt — do not edit. Regenerate from shamt-core/host/templates/claude/skills/e2-define-spec/SKILL.md. -->
