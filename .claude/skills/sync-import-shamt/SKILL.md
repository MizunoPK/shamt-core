---
name: sync-import-shamt
description: >
  Child-side framework pull for the v2 master/child sync. Wraps .shamt-core/
  import-shamt.sh: reads master_url from .shamt-core/shamt-config.json (git URL or local
  path), pulls master HEAD, overwrites canonical sources under <child>/
  .shamt-core/ from master's sync set, auto-moves child-local proposals whose
  slugs match master's proposals/archive/ into .shamt-core/proposals/already-merged/, and
  re-runs regenerate-framework.sh so <child>/.claude/ stays current. Reports
  new / updated / unchanged / preserved counts plus any preserved-unmanaged or
  jq-missing warnings. Always-latest (no version pinning). Invoke when the user
  wants to pull master updates, sync the framework,
  upgrade shamt in this project, refresh canonical sources, or run import-shamt.
triggers:
  - "pull master updates"
  - "sync the framework"
  - "upgrade shamt in this project"
  - "refresh canonical sources"
  - "run import-shamt"
  - "import the latest framework"
---

## Overview

Mirrors the `/sync-import-shamt` slash command. Same canonical body, two host wirings.

## Protocol

Follow the canonical `/sync-import-shamt` command body verbatim — see [`commands/sync-import-shamt.md`](../../commands/sync-import-shamt.md).

## Recommended model

Cheap (Haiku) — script wrapper, output parsing, no design. See [`reference/model_selection.md`](../../../../../reference/model_selection.md).

## Exit criteria

`import-shamt.sh` exited 0; counts surfaced; regen ran (or its absence was called out); the user knows how to review the diff.

## Footer contract

Subtree-level, not per-file. Every path in master's sync set (`CLAUDE.md`, `README.md`, `shamt-config.example.json`, `init-shamt.sh`, `import-shamt.sh`, `proposals/_template.md`, `scripts/`, `templates/`, `reference/`, `host/`) is master-owned and overwritten on import. Files the child adds under `.shamt-core/{templates,reference,host,scripts}/` outside that set are preserved with a warning. This is the practical interpretation of the subtree-level sync rule, justified in `commands/sync-import-shamt.md` Notes.

## Why no reverse direction

This skill only pulls. To send a proposal upstream, use `/sync-submit-proposal {slug}` — manual copy per the manual-copy sync design.

---
Validated 2026-05-28 — 8 rounds (4 primary + 4 adversarial), final adversarial sub-agent confirmed (Phase 9 implementation re-validation). No changes to this file in this round.

<!-- Managed by Shamt — do not edit. Regenerate from shamt-core/host/templates/claude/skills/sync-import-shamt/SKILL.md. -->
