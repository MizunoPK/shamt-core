---
description: Child-side. Pull master HEAD canonical sources into <child>/.shamt-core/ via import-shamt.sh, then re-run regen so <child>/.claude/ stays current. Reports new / updated / unchanged / preserved counts and any already-merged proposals auto-moved into .shamt-core/proposals/already-merged/.
---

# /sync-import-shamt

**Purpose:** Run the child-side framework pull. Invoke `.shamt-core/import-shamt.sh` to clone (or local-copy) master, overwrite child-side canonical sources from master's sync set, auto-move any child-local proposals whose slugs match master's archive into `.shamt-core/proposals/already-merged/`, and re-run `regenerate-framework.sh` so `<child>/.claude/` reflects the new canonical state. Surface a summary of changes plus any preserved-unmanaged warnings.

The pull is **always-latest**: it pulls master HEAD with no version pinning.

**Recommended model:** Cheap (Haiku). The command is a script wrapper: invoke the shell script, parse its output, surface warnings, report. No design judgment. See [`reference/model_selection.md`](../../../../reference/model_selection.md).

---

## Usage

```
/sync-import-shamt [--target <dir>]
```

## Arguments

- **Slugless.** The pull is whole-framework. There is no per-file or per-proposal pull.
- `--target <dir>` (optional) — target child project directory. Defaults to the parent of the directory holding the script (i.e., `<child>` when the script is at `<child>/.shamt-core/import-shamt.sh`). Pass-through to `import-shamt.sh --target`.

## Prerequisites

- `.shamt-core/import-shamt.sh` exists at `<child>/.shamt-core/import-shamt.sh` and is executable. If not, halt — the project was never installed via `init-shamt.sh`, or the installed copy was deleted. Direct the user to either reinstall via `init-shamt.sh` or `chmod +x` the script.
- `.shamt-core/shamt-config.json` exists at `<child>/` and declares a non-empty `master_url`. The script validates this; this command surfaces the error if it fails.
- Working tree state: `import-shamt.sh` will overwrite files under `<child>/.shamt-core/` and re-run regen (which rewrites `<child>/.claude/`). If the user has uncommitted changes to either subtree, recommend committing first so the diff after import is reviewable.

## Step-by-step

### Step 1 — Resolve the script path

1. The expected location is `<child>/.shamt-core/import-shamt.sh`. If the user is running from inside the child project, this is reachable as `.shamt-core/import-shamt.sh` relative to cwd.
2. If not found, halt and direct the user to reinstall via `init-shamt.sh` or to confirm cwd is the child project root.

### Step 2 — Confirm clean(ish) working tree

1. Run `git status --porcelain .shamt-core/ .claude/` (when the target is a git repo).
2. If unstaged or staged changes are present in either path, surface them to the user and ask via `AskUserQuestion` whether to:
   - Commit first (recommended),
   - Proceed anyway (the user accepts that local changes inside the sync set will be overwritten),
   - Cancel.
3. If the target is not a git repo, skip this check — the user has chosen to operate without version control.

### Step 3 — Run import-shamt.sh

Invoke:

```bash
bash .shamt-core/import-shamt.sh [--target {target_dir}]
```

The script handles:

- Reading `master_url` from `.shamt-core/shamt-config.json` (jq when available; tolerant sed fallback otherwise).
- Cloning master (`git clone --depth 1`) when `master_url` is a git URL (`https://`, `http://`, `git@`, `ssh://`, `git://`); using `master_url` directly when it is an absolute local filesystem path.
- Overwriting every file in master's sync set (`CLAUDE.md`, `README.md`, `shamt-config.example.json`, `init-shamt.sh`, `import-shamt.sh`, `proposals/_template.md`, plus the `scripts/`, `templates/`, `reference/`, `host/` subtrees).
- Preserving (with warnings) any local-only files the child added under the managed subtrees.
- Auto-moving child-local proposals whose slugs match a file in master's `proposals/archive/` into `.shamt-core/proposals/already-merged/`.
- Re-running `regenerate-framework.sh --target <target>` after the file sync.

Capture the full output.

### Step 4 — Surface the result

The script prints per-file lines only for *new* and *updated* files (`  new      <path>` and `  updated  <path>`); identical files are tallied silently into the unchanged count. The script's own end-of-run summary already has the structured shape:

```text
import-shamt complete:
  new:        N    (files added that didn't exist before)
  updated:    N    (files whose content changed)
  unchanged:  N    (files identical to master)
  preserved:  N    (local files outside master's sync set)
  proposals → already-merged: N
```

Reproduce that summary in chat verbatim, then list:

- Each `WARN: preserving local file not in master sync set: …` line verbatim so the user can decide whether to keep, remove, or upstream the local content.
- Each `moved .shamt-core/proposals/{slug}.md → .shamt-core/proposals/already-merged/…` line so the user can see which of their submissions landed upstream.

### Step 5 — Surface regen output

After the file sync, `import-shamt.sh` runs `regenerate-framework.sh --target <target>` internally. The regen output appears in the script's stdout. Apply the same surface rules as `/f4-regen-framework`:

- `wrote`, `removed`, `unchanged` lines — informational, summary only.
- `WARN: preserving unmanaged file (no 'Managed by Shamt' footer)` — list verbatim.
- `WARN: jq not installed — leaving settings.json unchanged.` — show the user the snippet to paste manually.
- `WARN: settings.json failed to parse …` — surface and stop suggesting follow-ups until they fix it.

### Step 6 — Suggest follow-ups

Suggest:

1. Review the diff: `git diff .shamt-core/ .claude/`.
2. Run drift check independently: `/f4-regen-framework` (verifies zero drift after the import).
3. Optionally `/f5-audit-framework` if the user wants a deeper post-import sweep (D1 will run the drift check; D4 may flag dangling references introduced by canonical edits the user hasn't yet noticed).
4. To see what this import pulled in, review the per-file new / updated / unchanged / preserved counts surfaced above (also listed under Exit criteria). For the full upstream history, browse `git log` against `master_url` directly (the clone temp dir, or the source repo for a local-path `master_url`).

## Exit criteria

- `import-shamt.sh` exited 0.
- Per-file counts (new / updated / unchanged / preserved / already-merged-moved) have been surfaced.
- Regen ran (or its absence has been called out) and any warnings are visible.
- The user has been told how to review the diff.

## Notes

- **Always-latest.** No version pinning. `import-shamt.sh` pulls master HEAD every invocation. This is intentional — the framework's surface is small enough that a flag day isn't needed.
- **Self-updating.** `import-shamt.sh` is itself in the sync set, so a sync overwrites the on-disk copy mid-run. bash reads a script lazily by byte offset (not all up front), so a length-changing self-overwrite of the running file could otherwise corrupt execution. To prevent that, on first invocation the script copies itself to a temp file and re-execs from there — the re-execed process runs from the stable temp copy, so the in-place overwrite cannot corrupt it; the temp copy is removed by the EXIT trap, and the newly-installed version takes effect on the next invocation.
- **Mid-sync crash recovery.** If a sync crashes mid-run with a token-not-found / `command not found` (exit 127) error, simply re-run `/sync-import-shamt` once — the second pass completes cleanly. This is only possible on the *crossover* import that first pulls the fix into a pre-fix child copy (the still-running old script lacks the re-exec guard); once the fixed `import-shamt.sh` is installed, subsequent imports re-exec from a stable copy and never hit this. The retry is safe because by then the on-disk copy is byte-identical to master (no length change → offsets stay valid) and the sync is idempotent (`cmp`-first, rewrites only changed files).
- **`master_url` formats.** Git URL (cloned `--depth 1`) or absolute local path (used directly with no copy). The script auto-detects via prefix.
- **No automatic git commit.** The script does not commit on the user's behalf — the diff is the user's to review.
- **Footer contract.** The pragmatic footer-contract rule is **subtree-level**: every path in master's sync set is master-owned (no per-file footer check). Any file the child adds under `.shamt-core/{templates,reference,host,scripts}/` outside that sync set is preserved with a warning. This is a tighter rule than the per-file footer check originally proposed, justified by the fact that most canonical files under `templates/` and `reference/` do not yet carry footers — applying the strict footer rule would leave the bulk of canonical content un-synced.
- **No reverse direction.** This command only pulls. The reverse direction is `/sync-proposals` (batch — ships every active child-local proposal upstream at once). `/sync-proposals` **direct-writes** each proposal into a *local* `master_url`'s `proposals/incoming/`, the symmetric mirror of this command's local-path read on the import side (both resolve `master_url` as a local checkout and read/write the filesystem directly with no remote tooling) — keeping the two halves of the sync surface conceptually paired against future drift. Like this command, it has no remote-push automation; unlike this command, it assumes a local `master_url` and halts on a git URL.
- **Fresh-agent runnable.** The script + `.shamt-core/shamt-config.json` are sufficient. No conversation history required.

---
Validated 2026-05-28 — 8 rounds (4 primary + 4 adversarial), final adversarial sub-agent confirmed (Phase 9 implementation re-validation). No changes to this file in this round.

<!-- Managed by Shamt — do not edit. Regenerate from shamt-core/host/templates/claude/commands/sync-import-shamt.md. -->
