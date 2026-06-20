# Proposal: import-flow-self-overwrite-crash

**Created:** 2026-06-19
**Status:** Implemented
**Number:** 45
**Proposed by:** FantasyFootballHelperScripts
**Project context:** Hit during a routine `/sync-import-shamt` pull from a local-path master.

---

## Problem

`shamt-core/import-shamt.sh` lists **itself** in its own sync set — `import-shamt.sh` is an entry in `MASTER_SYNC_FILES` (`shamt-core/import-shamt.sh:215`) — and `apply_one` rewrites each sync-set file in place with `cp "$src" "$dst"` (`shamt-core/import-shamt.sh:258`). When the row for `import-shamt.sh` is processed, that `cp` overwrites the **running** script on disk mid-execution. bash does not load a script into memory up front; it reads the file lazily by **byte offset** as it executes. When the on-disk file's length changes underneath the running process, bash's next read lands at a now-stale offset inside the *new* content and parses a fragment of a token, producing a failure like `import-shamt.sh: line 278: k: command not found` (exit 127) — which trips `set -euo pipefail` (`shamt-core/import-shamt.sh:40`) and aborts the sync partway through. This was hit live by the child project FantasyFootballHelperScripts on a first `/sync-import-shamt` against a local-path master; the reported error line/token are artifacts of the offset mismatch, not a real defect at any specific source line. A second run completes cleanly because by then the on-disk copy is byte-identical to master (no length change → offsets stay valid) and `apply_one` is idempotent (it `cmp`s first and only rewrites changed files) — so the crash is transient and self-healing on retry, but a user reasonably reads exit 127 mid-sync as "the framework is broken / the tree is half-synced."

The framework also actively documents a **false** premise about this behavior. The `## Notes` → "Self-updating" bullet in `shamt-core/host/templates/claude/commands/sync-import-shamt.md:113` asserts: *"A new version overwrites the on-disk copy mid-run. The running script is already in memory and continues with the previous logic; the new version takes effect on the next invocation."* That is not how bash reads scripts — there is no "already in memory" guarantee — and the same false/over-optimistic claim is repeated in the script's own header comment (`shamt-core/import-shamt.sh:35-38`) and, in a milder form, in `shamt-core/README.md:297`. This false premise is what let the bug ship through design and validation, so the fix must correct the documentation as well as the script.

An independent adversarial root-cause diagnosis (Opus `root-cause-diagnoser` + Haiku zero-bias confirmation) confirmed the mechanism and the change scope, and corrected two points from the original incident notes: (1) the `main() { … }; main "$@"` wrapper floated in the f0 capture is **not** a sufficient fix as stated — bash re-reads the file by byte offset *after* `main "$@"` returns, so garbage from the new content can still execute unless the call is `main "$@"; exit "$?"` on a single parsed line (fragile under future edits); the robust fix is a **copy-then-reexec** preamble; and (2) `init-shamt.sh` and `scripts/regenerate-framework.sh` — both also in a sync set — do **not** have the bug under any supported flow (see Validation Considerations), so they are out of the required change set.

## Proposed Changes

| # | Canonical path | Operation | One-line change description |
|---|----------------|-----------|------------------------------|
| 1 | `shamt-core/import-shamt.sh` | EDIT | Add a **copy-then-reexec preamble** at the top of the file (immediately after the shebang block, before the symlink-resolution preamble): on first entry, set `_SHAMT_IMPORT_ORIG` to the resolved absolute path of `${BASH_SOURCE[0]}`, `cp` it to a `mktemp` temp script, `export _SHAMT_IMPORT_REEXEC=1 _SHAMT_IMPORT_ORIG _SHAMT_IMPORT_TMP`, and `exec bash "$_SHAMT_IMPORT_TMP" "$@"`; on second entry (`_SHAMT_IMPORT_REEXEC` set) skip the preamble. Change the symlink-preamble seed (currently `SCRIPT_PATH="${BASH_SOURCE[0]}"`, `shamt-core/import-shamt.sh:44`) to `SCRIPT_PATH="${_SHAMT_IMPORT_ORIG:-${BASH_SOURCE[0]}}"` so `SCRIPT_DIR`, the `TARGET_DIR` default (`SCRIPT_DIR/..`, line 124), and all path-identity logic still resolve the **installed** location rather than the temp copy. Add `rm -f "${_SHAMT_IMPORT_TMP:-}"` to the existing `cleanup()` EXIT trap (lines 163-168). Rewrite the false "Self-updating" header comment (lines 35-38) to describe the real copy-then-reexec behavior. |
| 2 | `shamt-core/host/templates/claude/commands/sync-import-shamt.md` | EDIT | (a) Rewrite the `## Notes` → "**Self-updating.**" bullet (line 113) to drop the false "already in memory and continues with the previous logic" claim and describe the actual mechanism: the script copies itself to a temp file and re-execs from there so a mid-sync length-changing self-overwrite cannot corrupt the run; the new version takes effect on the next invocation. (b) Add a short recovery note (to the same "Self-updating" bullet or a sibling Notes line) advising that if a sync crashes mid-run with a token-not-found / exit-127 error — possible on the crossover import from a pre-fix child copy — re-running `/sync-import-shamt` once completes cleanly (the second pass is byte-identical and idempotent). |
| 3 | `shamt-core/README.md` | EDIT | Correct the milder "Self-updating" bullet in the import-shamt behavior list (line 297) to match the rewritten Notes — `import-shamt.sh` copies itself and re-execs to survive being overwritten mid-sync; new version applies next invocation. |

**Not changed (justified in Validation Considerations):** `shamt-core/init-shamt.sh`, `shamt-core/scripts/regenerate-framework.sh`, `shamt-core/host/templates/claude/skills/sync-import-shamt/SKILL.md`.

---

## Risks

- **Regression risk (re-exec preamble).** The copy-then-reexec changes how the script bootstraps. If the original installed path is not threaded through correctly, `SCRIPT_DIR`/`TARGET_DIR` default derivation breaks (the temp file lives in `/tmp`, so `SCRIPT_DIR/..` would resolve to `/`). Mitigated by the `_SHAMT_IMPORT_ORIG` env-var hand-off and the `SCRIPT_PATH="${_SHAMT_IMPORT_ORIG:-…}"` seed; Phase 2 must verify a `--target`-less invocation still defaults `TARGET_DIR` to `<child>`. The `exec` replaces the process, so the outer-shell trap never fires — temp cleanup must live in the re-execed body's `cleanup()` trap (covered by the change).
- **Regression risk (re-exec under `set -euo pipefail`).** `mktemp`/`cp`/`exec` failures must not leave a half-state; with `set -e` a failed `cp` or `mktemp` aborts before `exec`, which is the safe outcome (nothing synced yet).
- **Drift risk.** This touches `import-shamt.sh` (a `MASTER_SYNC_FILES` member) plus two docs; one of the docs (`commands/sync-import-shamt.md`) is host-managed, so `/f4-regen-framework` must propagate it into `.claude/`. `README.md` and `import-shamt.sh` are root canonical (not regen-managed) — no `.claude/` mirror.
- **Child-project compatibility.** Already-installed children only pick up the fixed `import-shamt.sh` *via an import* — and that import is the very flow that can still crash on the old (in-memory-running) copy. The crash remains transient/self-healing on re-run, so the worst case is "first import after the fix may need one retry, every import after that is clean." No manual reconciliation step is required, but the recovery note (Open Question 2) governs whether we tell users this explicitly.
- **Open-questions debt.** Two scoping decisions are open (preventive hardening of `init`/`regen`; whether to add a re-run recovery note). Both are resolved before the footer is stamped.

---

## Rollback Plan

1. `git revert <commit-sha>` on the squash commit (`shamt-core: land #45 import-flow-self-overwrite-crash …`).
2. Run `/f4-regen-framework` to propagate the revert into `.claude/` (only `commands/sync-import-shamt.md` is regen-managed).
3. Child-side action: none required to roll back — children that already imported the fixed script keep working (re-exec is backward-compatible); a child wanting the old behavior re-runs `/sync-import-shamt` after the revert lands on master.
4. Communication: note in the next sync summary that the re-exec change was reverted, since the crash class returns.

---

## Validation Considerations

Dimension hints for the Phase 2 validation loop (`/validate-artifact proposals/45-import-flow-self-overwrite-crash.md`):

- **Problem clarity** — the failing line number (`line 278`) is an *artifact* of the byte-offset mismatch, not a real defect at line 278 of either version; the validator should not chase a literal line-278 bug.
- **Change-list completeness** — the false "Self-updating" claim lives in **three** places (script header `import-shamt.sh:35-38`, command Notes `sync-import-shamt.md:113`, README `README.md:297`); all three must change together or the corrected behavior contradicts a stale doc. The `sync-import-shamt` **SKILL** (`host/templates/claude/skills/sync-import-shamt/SKILL.md`) is a pure `## Protocol` pointer and does **not** repeat the claim — per the Command → Skill Protocol pointer rule it needs **no** edit; a Proposed Changes row must not add one.
- **`init-shamt.sh` is out of scope (verify the ruling).** It copies *from* master *to* a different file (`<child>/.shamt-core/init-shamt.sh`), never the running script; self-host skips the copy entirely (`if [ "$SELF_HOST" -eq 0 ]`, `init-shamt.sh:346`); and a child re-run halts on the already-installed config guard (`init-shamt.sh:166`) before any copy. No supported flow overwrites the running `init-shamt.sh`.
- **`scripts/regenerate-framework.sh` is out of scope (verify the ruling).** It is in the import sync set but is overwritten by import *before* it is launched as a subprocess (`import-shamt.sh:365`), so it runs from already-stable bytes; during its own run it writes only into `<target>/.claude/`, never into `scripts/`. No self-overwrite path.
- **Risk coverage** — the re-exec must preserve: the symlink-resolution preamble's identity logic, the `TARGET_DIR` default, the `cleanup()`/`trap … EXIT` temp removal, and argument pass-through (`"$@"`). Verify each in the implemented diff (this is the MEDIUM finding the adversarial confirmation flagged).
- **Affected surfaces** — scripts (`import-shamt.sh`), commands (`sync-import-shamt.md`), root docs (`README.md`). One regen-managed file → regen + drift check required.
- **Propagation plan** — `/f4-regen-framework` after implement; children pick up the fixed script on their next `/sync-import-shamt` (which may need one retry on the crossover import, per the Risks note).

---

## Open Questions

_(none — all resolved.)_

---

## Resolved Questions

- ~~Q: Should the copy-then-reexec preamble also be applied preventively to `init-shamt.sh` and/or `scripts/regenerate-framework.sh`?~~ → A: No — **fix `import-shamt.sh` only**. The diagnosis confirmed neither other script has the bug under any supported flow; the targeted fix keeps the change set at 3 files and avoids adding bootstrap boilerplate (and an env-var hand-off to init's self-host detection) to scripts that don't need it.
- ~~Q: Should the `/sync-import-shamt` command body add explicit re-run recovery guidance for a mid-sync crash?~~ → A: Yes — **add the re-run recovery note** to `commands/sync-import-shamt.md` (folded into row 2, same file, no new row). The crossover import from a pre-fix child copy can still crash once; telling users the second run self-heals (byte-identical + idempotent) keeps the one-time failure from reading as a broken framework.

---
Validated 2026-06-20 — 1 round, 1 adversarial sub-agent confirmed
