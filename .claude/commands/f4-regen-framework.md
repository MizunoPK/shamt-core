---
description: Phase 5 of the framework-update flow (slugless) — wrap scripts/regenerate-framework.sh to propagate canonical edits into .claude/ and confirm zero drift; also runnable standalone for everyday regen / drift checks
---

# /f4-regen-framework

**Purpose:** Run Phase 5 of the framework-update flow. Propagate canonical edits under `shamt-core/host/templates/claude/` (and the `statusline.sh` companion) into the target project's `.claude/` directory by invoking `scripts/regenerate-framework.sh`, then re-run the script in `--check` mode to confirm zero drift. Also available as a standalone command for routine regen / drift checks outside the framework-update flow.

**Recommended model:** Cheap (Haiku). Regen is mechanical — running the script, reading its output, surfacing drift findings. No design judgment. See [`reference/model_selection.md`](../../../../reference/model_selection.md).

---

## Usage

```
/f4-regen-framework [--target <dir>]
```

## Arguments

- **Slugless.** Regen is global. There is no proposal slug — the script reads every file under the canonical root and propagates it.
- `--target <dir>` (optional) — target project directory. Defaults to the current working directory. Pass-through to `regenerate-framework.sh --target`.

## Prerequisites

- The regen script exists and is executable — `scripts/regenerate-framework.sh` on the shamt-core self-host (master), or `.shamt-core/scripts/regenerate-framework.sh` in a child project (resolved in Step 1). If not, halt and report.
- The target project directory exists and is the place you intend to regenerate (i.e., the project's root where `.claude/` should live). When run inside `shamt-core/` development, the target is the project that consumes `shamt-core` — the master self-host or a child project — **not** `shamt-core/` itself, unless `shamt-core/` happens to also be a project that uses its own canonical sources (the self-host pattern).

  **Self-host detection rule of thumb** (the same master-vs-child signal `/f1-propose-update` and `/sync-triage-proposals` use): the resolved target is the self-host iff it has a top-level `{target}/proposals/` directory — corroborated by canonical sources at the root (`{target}/host/templates/claude/`, `{target}/templates/`, `{target}/scripts/regenerate-framework.sh`). It is a consumer project iff `{target}/.shamt-core/` carries the imported copy. The distinction matters for the audit (D6 not-applicable case below) and for setting user expectations about which `.claude/` is being written.
- Working tree state: regen will write to `.claude/` and possibly patch `.claude/settings.json` (statusLine wiring). If the target's `.claude/` has uncommitted changes you want to keep, commit them first.

## Step-by-step

### Step 1 — Resolve the script path

1. Locate `regenerate-framework.sh`. Preference order:
   1. `scripts/regenerate-framework.sh` — the **self-host master** form, when run from the shamt-core repo root (canonical sources live at the root, no `.shamt-core/` wrapper).
   2. `.shamt-core/scripts/regenerate-framework.sh` — the **child project** form (the imported copy under `.shamt-core/`, relative to the project root).
   3. An installed copy at the path documented in the project's `.shamt-core/shamt-config.json` (when available).
2. Confirm the script is executable. If not, run `chmod +x` once and proceed.

### Step 2 — Resolve the target directory

1. If `--target <dir>` was passed, use it.
2. Otherwise, default to the current working directory (the script's default).
3. State the resolved target path in chat in one line before invoking the script (e.g., `Target: /path/to/project — will write .claude/ here.`).

### Step 3 — Run regen

Invoke the script in default mode:

```bash
bash {script} --target {target_dir}    # {script} resolved in Step 1: scripts/… on the self-host master, .shamt-core/scripts/… in a child
```

Capture the full output. Surface to the user any `wrote`, `removed`, `unchanged`, or `WARN:` lines.

Common warnings to surface explicitly:

- `WARN: preserving unmanaged file (no 'Managed by Shamt' footer): {path}` — a target file collides with a canonical file but lacks the managed footer. Tell the user; either rename the target file or add the footer (only if the file is meant to be managed). Decision is the user's.
- `WARN: jq not installed — leaving settings.json unchanged.` — `.claude/settings.json` was not patched for the statusLine. Show the user the snippet to paste manually (from the warning text).
- `WARN: settings.json failed to parse (jq error) …` — the user's `settings.json` is broken. Surface and stop suggesting a re-run until they fix it.

### Step 4 — Run drift check

Invoke the script in `--check` mode against the same target:

```bash
bash {script} --check --target {target_dir}
```

Expected output: `no drift` (exit 0). Any other output is a Phase 5 failure.

Output cases:

- **`no drift`** — Phase 5 exit gate met. Proceed to Step 5.
- **`DRIFT {path}`** lines — canonical and target diverged after regen. This is a script defect or an external write between the regen and the check. Halt, report the drifting paths, and ask the user to investigate before proceeding to Phase 6.
- **`STALE {path}`** lines — target has a managed file the canonical root no longer carries, but the regen didn't prune it. Same disposition as DRIFT: halt and report.
- **`UNMANAGED {path} (preserved)`** lines — informational. Lists files preserved without the managed footer. Do not treat as drift; surface only if the user explicitly asks.

### Step 5 — Suggest the next phase

Suggest a context-clear and the next command. The choice depends on context:

- **In the framework-update flow** (this regen followed an `/f3-implement-update` run on a specific proposal): `/clear`, then `/f5-audit-framework`. The audit is Phase 6.
- **Standalone regen** (no in-flight proposal): no next-phase suggestion is needed. Report `no drift` and exit.

If the user wants to run the audit even on a standalone regen (e.g., as part of a periodic sweep), `/f5-audit-framework` is the right command — its body is identical inside and outside the update flow.

## Exit criteria

- `regenerate-framework.sh` exited 0 in default mode.
- `regenerate-framework.sh --check` reported `no drift` (exit 0).
- Any surfaced warnings are visible to the user and either resolved or explicitly acknowledged.

## Notes

- **Slugless by design.** The script reads the entire canonical root; there is no concept of "regen this one proposal." That is intentional — partial regen would let canonical and generated drift on the unwritten files.
- **`--check` after regen is the drift gate.** Some scenarios (a stale `settings.json` patch, a script bug, a race with an external editor) can produce drift even right after regen. Running `--check` is what makes the exit gate trustworthy.
- **`.claude/settings.json` is partially user-owned.** The script only patches the `statusLine` field via `jq` and leaves the rest. `--check` deliberately does not flag `settings.json` drift; the regen's success is the gate.
- **Footer contract.** Only files with `<!-- Managed by Shamt -->` (or `# Managed by Shamt` for `.sh`) in their last 5 lines are overwritten or pruned. User-authored host files without the footer are preserved with a warning.
- **Standalone use** is encouraged. Run `/f4-regen-framework` after pulling master updates (`/sync-import-shamt` in child projects), after rebasing canonical work, or before opening a PR that touches `.shamt-core/host/templates/claude/`.

---
Validated 2026-05-28 — 4 rounds, 1 adversarial sub-agent confirmed (Phase 8 implementation loop)

<!-- Managed by Shamt — do not edit. Regenerate from shamt-core/host/templates/claude/commands/f4-regen-framework.md. -->
