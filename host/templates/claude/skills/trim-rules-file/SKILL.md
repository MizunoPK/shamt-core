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

Follow the canonical `/trim-rules-file` command body verbatim — see [`commands/trim-rules-file.md`](../../commands/trim-rules-file.md).

## Recommended model

Reasoning (Opus) — preserving every rule while cutting is design judgment, not mechanical. See [`reference/model_selection.md`](../../../../../reference/model_selection.md).

## Exit criteria

A proposal draft at `proposals/{slug}.md` enumerating concrete cuts toward the budget with the rule-preservation guardrail stated; no edit to the rules file itself; master / self-host only.

---
Created 2026-06-07 — by /f3-implement-update for proposals/08-rules-size-budget-trim-skill.md (new /trim-rules-file skill mirror).

<!-- Managed by Shamt — do not edit. Regenerate from shamt-core/host/templates/claude/skills/trim-rules-file/SKILL.md. -->
