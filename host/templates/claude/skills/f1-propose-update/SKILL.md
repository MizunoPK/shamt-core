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

Follow the canonical `/f1-propose-update` command body verbatim — see [`commands/f1-propose-update.md`](../../commands/f1-propose-update.md). Summary:

1. **Resolve slug** to `.shamt-core/proposals/{slug}.md` (exact-then-numbered-glob `*-{slug}.md`; master-side proposals carry a `{NN}-` prefix). **Three input modes:** (1) **blank** — seed fresh from the template; (2) **free-text `[blurb]`** — seed the Problem from the blurb; (3) **existing f0 draft** (`Status: Draft (f0 — audit capture, unrefined)` + banner, written by `/f0-draft-proposal`, e.g. an audit capture) — **ingest it** (normalize the status to plain `Draft`, drop the banner, develop the Scratch Notes into the full proposal, then remove the Scratch Notes section), with **no** extend / overwrite prompt and nothing to footer-strip (f0 drafts carry no validation footer). A non-f0 existing draft = the usual confirm extend / overwrite (strip any stale Phase 2 footer when extending). Halt if `.shamt-core/proposals/archive/{slug}.md` (or numbered `archive/*-{slug}.md`) already exists unless the user confirms a follow-up.
2. **Seed from template** at [`.shamt-core/proposals/_template.md`](../../../../../proposals/_template.md). Fill header (date, status, `Proposed by:` / `Project context:` for child-authored). **Mode 3 skips this step** — the f0 file already follows the template shape. **Master-side only (guarded):** assign the proposal **Number** (`max(existing NN across proposals/, archive/, deferred/, rejected/) + 1`, two-digit zero-padded, no counter file) — write the `**Number:**` header and the `{NN}-` filename prefix (`proposals/{NN}-{slug}.md`), renaming an unnumbered seed/f0 file. Child-side proposals stay unnumbered. **Branch creation is NOT f1's job** — `/f3-implement-update` creates `proposal/{NN}-{slug}`.
3. **Draft Problem** — concrete, cites canonical files/sections.
4. **(Incident-originated only) Root-cause diagnosis** — when the proposal stems from a bug / feedback / issue / audit capture (not a clean-slate idea), adopt the command-local default stance that the incident signals a **genuine framework gap requiring a Shamt update** (not a one-off to paper over), and drive an **independent adversarial diagnosis**: spawn the Opus `root-cause-diagnoser` persona to find the true root cause at the canonical-source altitude, then a Haiku `validation-checker` zero-bias confirmation (reusing the Pattern 1 Step 7 contract — no second new persona); fold the confirmed root cause into Problem + Proposed Changes. Proactive proposals skip this step.
5. **Build Proposed Changes** — table of every canonical file the change will touch. CREATE/EDIT/DELETE/MOVE rows. **No `.claude/` paths.** Cross-check paired edits (rule ↔ template, command ↔ skill, ref ↔ rule pointer). If row count > 10, note Phase 3 is required.
6. **Risks / Rollback / Validation Considerations** — fill out per the template's prompts.
7. **Open-questions iterative dialog** ([Principle 2](../../../../../templates/SHAMT_RULES.template.md#principle-2-open-questions-iterative-dialog)) — surface each question one at a time, update the proposal with each answer, move resolved to `## Resolved Questions`. The proposal is not "drafted" while Open Questions is non-empty.
8. **Exit gate** — proposal non-empty; Problem, Proposed Changes, Risks, Rollback, Validation Considerations filled; Open Questions empty; no validation footer yet.
9. **Suggest next phase** — `/clear` + `/validate-artifact {resolved path}` (`proposals/{NN}-{slug}.md` on master, `.shamt-core/proposals/{slug}.md` on child), and `/f2-plan-update-implementation {slug}` when row count > 10.

> **In-place amendment** — when a downstream phase (`/f2-plan-update-implementation`, `/f3-implement-update`) finds an already-validated proposal's Proposed Changes table is missing a row, it amends in place (strip footer → append row → re-run `/validate-artifact`) rather than re-running `/f1-propose-update`; see the **In-place amendment** section in the command body.

## Recommended model

Balanced (Sonnet) — structural analysis. The Phase 2 validation loop escalates to Reasoning (Opus). See [`reference/model_selection.md`](../../../../../reference/model_selection.md).

## Exit criteria

`.shamt-core/proposals/{slug}.md` exists, has no open questions, every Proposed Changes row points at a canonical (non-`.claude/`) path, and the next phase has been suggested.

---
Validated 2026-05-28 — 4 rounds, 1 adversarial sub-agent confirmed (Phase 8 implementation loop)
Touched 2026-06-02 — mirrored the f1 command's three input modes (blank / blurb / f0-draft ingestion) and the f0-draft slug-resolution branch into the summary + frontmatter description. Per proposals/audit-continuous-f0-draft-capture.md.

<!-- Managed by Shamt — do not edit. Regenerate from shamt-core/host/templates/claude/skills/f1-propose-update/SKILL.md. -->
