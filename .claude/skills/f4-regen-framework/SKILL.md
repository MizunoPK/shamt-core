---
name: f4-regen-framework
description: >
  Phase 5 of the Shamt framework-update flow (slugless). Propagate canonical
  edits in shamt-core/host/templates/claude/ into a target project's .claude/
  by invoking scripts/regenerate-framework.sh, then run the script in --check
  mode to confirm zero drift. Also available standalone for routine regen /
  drift checks outside the update flow. Invoke when the user wants to
  regenerate the framework, propagate canonical edits, run regen, check for
  drift, sync .claude/ from canonical sources, or rebuild .claude/ after a
  framework change.
triggers:
  - "regenerate the framework"
  - "run regen"
  - "regen framework"
  - "sync .claude/ from canonical"
  - "propagate canonical edits"
  - "check for framework drift"
  - "drift check"
  - "rebuild .claude/"
---

## Overview

Mirrors the `/f4-regen-framework` slash command. Same canonical body, two host wirings.

## Slugless

Regen is global. There is no proposal slug — the script reads every file under `shamt-core/host/templates/claude/` (and `statusline.sh`) and propagates each. Partial regen would let canonical and generated drift on unwritten files.

## Protocol

Follow the canonical `/f4-regen-framework` command body verbatim — see [`commands/f4-regen-framework.md`](../../commands/f4-regen-framework.md). Summary:

1. **Resolve script path** — `scripts/regenerate-framework.sh` on the shamt-core self-host (master), or `.shamt-core/scripts/regenerate-framework.sh` in a child project. Confirm executable.
2. **Resolve target** — `--target <dir>` override or current working directory. State the target path in chat in one line.
3. **Run regen** — `bash {script} --target {dir}` (the path resolved in step 1). Surface `wrote` / `removed` / `WARN:` lines. Special-case warnings: unmanaged file collisions, missing `jq`, broken `settings.json`.
4. **Run drift check** — `bash {script} --check --target {dir}`. Expected: `no drift` (exit 0). Any `DRIFT` or `STALE` lines halt Phase 5.
5. **Suggest next phase** — in-flow: `/clear` + `/f5-audit-framework`. Standalone: no suggestion; report `no drift` and exit.

## Recommended model

Cheap (Haiku) — running the script, reading output, surfacing warnings. No design judgment. See [`reference/model_selection.md`](../../../../../reference/model_selection.md).

## Exit criteria

Regen exited 0; `--check` reported `no drift`; warnings surfaced and acknowledged.

## Standalone use

Encouraged after pulling master updates, after rebasing canonical work, or before opening a PR touching `shamt-core/host/templates/claude/`. The body is identical in or out of the framework-update flow.

---
Validated 2026-05-28 — 4 rounds, 1 adversarial sub-agent confirmed (Phase 8 implementation loop)

<!-- Managed by Shamt — do not edit. Regenerate from shamt-core/host/templates/claude/skills/f4-regen-framework/SKILL.md. -->
