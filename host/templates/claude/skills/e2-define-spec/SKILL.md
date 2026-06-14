---
name: e2-define-spec
description: >
  Run Phase 2 (Spec) of the Shamt Engineer flow on a story whose ticket has
  been captured. Targeted research; design dialog at Gate 2a with 1–3 option
  comparisons; spec/context drafting (Standard) or compact spec (Quick);
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

Follow the canonical `/e2-define-spec` command body verbatim — see [`commands/e2-define-spec.md`](../../commands/e2-define-spec.md). Resolve the story folder per `templates/SHAMT_RULES.template.md` §PO-tree resolution (tree-wide glob + legacy-flat fallback); `stories/{slug}/` below denotes that resolved folder. Summary:

1. **Ingest the ticket** (`stories/{slug}/ticket.md`). Halt if missing or empty.
2. **Targeted research** — grep referenced files; read `.shamt-core/project-specific-files/ARCHITECTURE.md` and `.shamt-core/project-specific-files/CODING_STANDARDS.md`; capture findings (Standard: `context.md`; Quick: `spec.md` Evidence). Populate the review-prevention risk inventory using [`reference/pr_review_prevention.md`](../../../../../reference/pr_review_prevention.md); full required-captures detail in [`reference/spec_protocol_reference.md`](../../../../../reference/spec_protocol_reference.md).
3. **Draft skeletons** from [`templates/spec.template.md`](../../../../../templates/spec.template.md) (and [`templates/context.template.md`](../../../../../templates/context.template.md) on Standard).
4. **Design dialog (Gate 2a)** — present 1–3 options inline with pros/cons (each option needs its own pros/cons; no shared tradeoff paragraph). Apply the **open-questions iterative dialog** principle — surface each question to the user one at a time via `AskUserQuestion`, update the artifact, repeat. Code-research every question first.
5. **Flesh out** — record the agreed approach. Required sections: Review Prevention Gates, Database Schema Changes (when applicable), Test Strategy (required), Key Design Decisions.
6. **Validation** — invoke `/validate-artifact` on the active artifact(s). Standard: spec+context pair. Quick: spec only (single primary pass unless risk-triggered).
7. **Gate 2b approval** — present the validated spec; wait for explicit user approval. Suggest `/clear` + `/e3-plan-implementation {slug}` (Standard) or direct Build (Quick).

## Recommended models

- Research: Balanced (Sonnet).
- Gate 2a design dialog: Reasoning (Opus).
- Validation loop primary: Reasoning (Opus). Sub-agent: Cheap (Haiku) via `validation-checker`.

See [`reference/model_selection.md`](../../../../../reference/model_selection.md).

## Exit criteria

Validated `spec.md` (and `context.md` on Standard) approved by the user at Gate 2b; Open Questions empty or deferred with reason.

---
Validated 2026-05-28 — 2 rounds, 1 adversarial sub-agent confirmed (Phase 5 implementation loop)

<!-- Managed by Shamt — do not edit. Regenerate from shamt-core/host/templates/claude/skills/e2-define-spec/SKILL.md. -->
