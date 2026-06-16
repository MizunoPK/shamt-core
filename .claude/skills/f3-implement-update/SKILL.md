---
name: f3-implement-update
description: >
  Phase 4 of the Shamt framework-update flow. Read a validated proposal at
  proposals/{slug}.md (and validated proposals/{slug}_PLAN.md when Phase 3
  ran) and apply the canonical edits — either inline by the primary agent
  (≤10 file ops) or via handoff to the plan-executor builder persona
  (architect/builder split, when a plan is present). Hard rule: edits go to
  canonical sources only; generated .claude/ files are NEVER edited
  directly. Invoke when the user wants to implement a framework update,
  apply the proposal, execute the proposal's plan, or land the canonical
  edits for proposals/{slug}.md.
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

Follow the canonical `/f3-implement-update` command body verbatim — see [`commands/f3-implement-update.md`](../../commands/f3-implement-update.md). Summary:

1. **Preflight** — resolve the proposal exact-then-glob (`proposals/{slug}.md`, then `proposals/*-{slug}.md` for the master-side `{NN}-` prefix); confirm it has a validation footer; confirm the companion `{NN}-{slug}_PLAN.md` (when present) has one; halt if `proposals/archive/{slug}.md` (or `archive/*-{slug}.md`) exists; unrelated working-tree state (ad-hoc proposal captures or other in-progress work) is accepted and rides the landing — never a halt.
2. **Path selection** — inline (≤10 file ops, no plan) or architect/builder (plan present, handoff to `plan-executor`). State the choice in one line. **Then create the proposal branch** `proposal/{NN}-{slug}` (`proposal/{slug}` grandfathered) from the base branch — inline path creates it directly (halt if it exists); architect/builder path lets `plan-executor` create it from the plan's pre-execution checklist. Branch creation moved here from f1/sync-triage; it is not a commit.
3. **Hard rule — canonical-only**: enumerate every path the proposal/plan will touch. Halt if any falls under `.claude/` or any non-canonical path not justified in the proposal. Canonical roots: `shamt-core/templates/`, `shamt-core/reference/`, `shamt-core/host/templates/claude/`, `shamt-core/scripts/`, `shamt-core/proposals/`, and the root-level canonical docs (`CLAUDE.md`, `README.md`, `shamt-config.example.json`).
4. **Apply edits** — inline: do each operation, verify after each row. Architect/builder: spawn `plan-executor` via the Task tool; monitor for `All steps completed. Verification passed.` / `Step [N] failed:` / `Step [N] is ambiguous:` / `Plan defect at Step [N]:`. For phase-decomposed plans, one phase at a time in deploy order.
5. **Post-build verification (architect/builder path)** — after the builder's `All steps completed. Verification passed.`, the architect **independently** runs the plan's post-execution `## Verification` section (for a phase-decomposed plan, the *index* file's whole-plan `## Verification (post-execution, whole plan)` section) — the cross-phase invariants the builder, handed one phase, cannot own. Any failure is a `Step failed`, never delegated back to `plan-executor`. (Inline path: no plan, no builder — proceed straight to the diff-coverage gate.) Mirrors `/e4-execute-plan` Step 4.
6. **Diff coverage gate** — `git status` + `git diff --stat`. Every Proposed Changes row covered; no edits outside canonical roots; no edits in `.claude/`.
7. **Suggest next phase** — `/clear` + `/f4-regen-framework`.

## Recommended models

- Orchestration (this command): Balanced (Sonnet).
- Builder (when Phase 3 ran): Cheap (Haiku) via [`agents/plan-executor.md`](../../agents/plan-executor.md).

See [`reference/model_selection.md`](../../../../../reference/model_selection.md).

## Exit criteria

Every Proposed Changes row covered by a real diff entry; no generated-file edits; `/f4-regen-framework` suggested. This command creates the `proposal/{NN}-{slug}` branch (or `proposal/{slug}` grandfathered) before editing but makes **no commit** — the commit + squash-merge to the base branch land at `/f6-archive-proposal` (Phase 7), after regen.

## Hard rule

**Never edit generated `.claude/` files.** Edits go to canonical sources; regen (Phase 5) propagates. Editing a generated file is always wrong — it gets overwritten on the next regen and the canonical source still carries the old version. If a step's path looks like `.claude/...`, halt unconditionally and report the path back as a proposal scope issue.

---
Validated 2026-05-28 — 4 rounds, 1 adversarial sub-agent confirmed (Phase 8 implementation loop)

<!-- Managed by Shamt — do not edit. Regenerate from shamt-core/host/templates/claude/skills/f3-implement-update/SKILL.md. -->
