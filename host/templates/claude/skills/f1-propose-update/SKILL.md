---
name: f1-propose-update
description: >
  Author or edit a framework-update proposal at .shamt-core/proposals/{slug}.md. Phase 1
  of the Shamt framework-update flow: seed from the canonical template, draft
  the Problem and Proposed Changes (canonical paths only — never .claude/),
  fill Risks / Rollback / Validation Considerations, and apply the
  open-questions iterative dialog until the Open Questions section is empty.
  Invoke when the user wants to propose a framework change, write up a
  framework fix, draft a proposal, or capture an upstream-worthy idea.
triggers:
  - "propose a framework update"
  - "propose a framework change"
  - "write up a proposal"
  - "draft a proposal"
  - "edit the proposal"
  - "propose an update to shamt"
  - "capture this as a framework proposal"
  - "upstream this idea"
---

## Overview

Mirrors the `/f1-propose-update {slug}` slash command. Same canonical body, two host wirings.

## Protocol

Follow the canonical `/f1-propose-update` command body verbatim — see [`commands/f1-propose-update.md`](../../commands/f1-propose-update.md). Summary:

1. **Resolve slug** to `.shamt-core/proposals/{slug}.md`. Re-entry on an existing draft = confirm extend / overwrite. Halt if `.shamt-core/proposals/archive/{slug}.md` already exists unless the user confirms a follow-up.
2. **Seed from template** at [`.shamt-core/proposals/_template.md`](../../../../../proposals/_template.md). Fill header (date, status, `Proposed by:` / `Project context:` for child-authored).
3. **Draft Problem** — concrete, cites canonical files/sections.
4. **Build Proposed Changes** — table of every canonical file the change will touch. CREATE/EDIT/DELETE/MOVE rows. **No `.claude/` paths.** Cross-check paired edits (rule ↔ template, command ↔ skill, ref ↔ rule pointer). If row count > 10, note Phase 3 is required.
5. **Risks / Rollback / Validation Considerations** — fill out per the template's prompts.
6. **Open-questions iterative dialog** ([Principle 2](../../../../../templates/SHAMT_RULES.template.md#principle-2-open-questions-iterative-dialog)) — surface each question one at a time, update the proposal with each answer, move resolved to `## Resolved Questions`. The proposal is not "drafted" while Open Questions is non-empty.
7. **Exit gate** — proposal non-empty; Problem, Proposed Changes, Risks, Rollback, Validation Considerations filled; Open Questions empty; no validation footer yet.
8. **Suggest next phase** — `/clear` + `/validate-artifact .shamt-core/proposals/{slug}.md` (and `/f2-plan-update-implementation {slug}` when row count > 10).

## Recommended model

Balanced (Sonnet) — structural analysis. The Phase 2 validation loop escalates to Reasoning (Opus). See [`reference/model_selection.md`](../../../../../reference/model_selection.md).

## Exit criteria

`.shamt-core/proposals/{slug}.md` exists, has no open questions, every Proposed Changes row points at a canonical (non-`.claude/`) path, and the next phase has been suggested.

---
Validated 2026-05-28 — 4 rounds, 1 adversarial sub-agent confirmed (Phase 8 implementation loop)

<!-- Managed by Shamt — do not edit. Regenerate from shamt-core/host/templates/claude/skills/f1-propose-update/SKILL.md. -->
