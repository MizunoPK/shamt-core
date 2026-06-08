---
name: trim-rules-file
description: >
  Analyze the canonical rules file (templates/SHAMT_RULES.template.md,
  rendered into every child CLAUDE.md) for size-reduction opportunities and
  author a proposal draft enumerating concrete cuts toward the size budget,
  without editing the rules file directly. Master / self-host only. Triggered
  by the /f5-audit-framework D12 finding or run on demand. Natural-language
  triggers like "trim the rules file" / "shrink CLAUDE.md" / "the rules file
  is too big".
---

## Overview

Mirrors the `/trim-rules-file [slug]` slash command. Same canonical body, two host wirings.

## Protocol

Follow the canonical `/trim-rules-file` command body verbatim — see [`commands/trim-rules-file.md`](../../commands/trim-rules-file.md). Summary:

1. **Master / self-host only** — the rules file is master-owned; halt in a child and redirect to `/f0-draft-proposal` → `/f1-propose-update` → `/sync-submit-proposal`.
2. **Measure** — `wc -m templates/SHAMT_RULES.template.md` vs `rules_size_budget_chars` (fallback 40000); target ~75% of budget (~30000).
3. **Analyze** — find concrete reductions: duplication/repetition, extraction to `reference/`, rephrase/tighten, relocate to command/skill bodies, other improvements. Record location, category, change, char delta per candidate.
4. **Author a proposal draft** in the `/f0-draft-proposal` file shape (so `/f1-propose-update` ingests it), with the cut list + running total toward target in Scratch Notes. **Quality guardrail:** every cut is an extraction / rephrase / relocation — never a silent deletion of a normative rule; the draft preserves the full rule set and names where each touched rule now lives.
5. **Exit** — report draft path + current/target chars; suggest `/f1-propose-update {slug}`. Does **not** edit `SHAMT_RULES.template.md`.

## Recommended model

Reasoning (Opus) — preserving every rule while cutting is design judgment, not mechanical. See [`reference/model_selection.md`](../../../../../reference/model_selection.md).

## Exit criteria

A proposal draft at `proposals/{slug}.md` enumerating concrete cuts toward the budget with the rule-preservation guardrail stated; no edit to the rules file itself; master / self-host only.

---
Created 2026-06-07 — by /f3-implement-update for proposals/08-rules-size-budget-trim-skill.md (new /trim-rules-file skill mirror).

<!-- Managed by Shamt — do not edit. Regenerate from shamt-core/host/templates/claude/skills/trim-rules-file/SKILL.md. -->
