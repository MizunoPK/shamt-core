# Proposal: regen-render-child-rules-file

**Created:** 2026-06-22
**Status:** Implemented
**Number:** 53
**Proposed by:** Wedding
**Project context:** Observed during a `/sync-import-shamt` pull that changed `SHAMT_RULES.template.md`; the child's root `CLAUDE.md` silently stayed stale.

---

## Problem

A child project's root `CLAUDE.md` — the single most load-bearing artifact in any install, since it is the instruction set every Claude Code session loads as project rules — **has no mechanism that keeps it in sync with `templates/SHAMT_RULES.template.md` after the initial install.** The gap is confirmed across four canonical sources:

1. `init-shamt.sh` (§"Step: seed top-level docs", lines 362–402) seeds `<target>/CLAUDE.md` from `SHAMT_RULES.template.md` as a **one-time, verbatim, seed-once-when-absent** `cp` (line 375). A pre-existing child `CLAUDE.md` is preserved untouched (line 373); a freshly seeded one is git-ignored via the `CLAUDE_SEEDED` flag (line 398).
2. `scripts/regenerate-framework.sh` walks **only** `host/templates/claude/` into `<target>/.claude/` (`CANONICAL_ROOT`, line 63; `canonical_relpaths` restricted to `commands/`, `agents/`, `skills/`, `statusline.sh`, lines 151–155). It has **zero awareness** of `templates/SHAMT_RULES.template.md` or the child's root `CLAUDE.md`.
3. `import-shamt.sh`'s `MASTER_SYNC_FILES` array (lines 234–241) lists `"CLAUDE.md"` (line 235), but `apply_one` writes it to `<child>/.shamt-core/CLAUDE.md` — that is the **master primer** landing under `.shamt-core/`, **not** the child's root `CLAUDE.md`. `import-shamt.sh` then re-runs regen (which, per #2, never touches the root rules file).
4. Net effect: after `init-shamt.sh` runs, the child's root `CLAUDE.md` is **terminally orphaned**. Every subsequent `/sync-import-shamt` pulls a fresh `SHAMT_RULES.template.md` into `.shamt-core/templates/` and rewrites `.claude/`, while the rules file the agent actually obeys stays pinned to the pre-install version.

**Concrete instance (the trigger).** A sync brought in the #51 standard ("standing Tech Stories fixtures are numbered `T1`/`T2`/`T3` tickets"). The template under `.shamt-core/` updated; the root `CLAUDE.md` did not. Three doc lines drifted (a missing §PO-tree-resolution "Standing reserved folders" bullet; the "Standing fixtures" and Ticket-IDs Allocation bullets still claiming the fixtures "carry no ticket ID"). An agent reading the stale `CLAUDE.md` cited the **old** rule and nearly blocked a correct migration request — its loaded instructions contradicted the synced template. Manual remediation was `cp .shamt-core/templates/SHAMT_RULES.template.md CLAUDE.md`, which only works because in that project the root `CLAUDE.md` is a verbatim copy of the template. This is a **per-sync recurring** gap, not a one-off.

**Doc-vs-reality contradiction (root cause confirmed adversarially).** The master primer (`CLAUDE.md`) *already promises* this mechanism exists: §"What lives here" describes a child keeping "`CLAUDE.md` (a managed section rendered from `SHAMT_RULES.template.md`)", and the install-footprint paragraph calls the seeded `/CLAUDE.md` re-derivable "from master (`import-shamt`) + regen." Neither is true today — no code path renders the template into the root `CLAUDE.md` after install. The fix makes the existing promise real rather than inventing a new concept.

> Confirmed root cause (adversarial diagnosis — `root-cause-diagnoser` Opus + Haiku `validation-checker` zero-bias confirmation, 2026-06-22): the gap is an install/sync-surface omission spanning `init-shamt.sh` (seeds the root `CLAUDE.md` once and never revisits it) and `scripts/regenerate-framework.sh` (does no rules-file rendering at all). The seed explanation ("regen omission only") was sharpened: `init-shamt.sh` is also implicated because its one-time seed + conditional git-ignore are what leave the file orphaned. (The diagnosis recommended a managed-block/footer ownership signal; the operator subsequently chose the simpler **always-override** model adopted in Proposed Changes — see Resolved Questions.)

---

## Proposed Changes

> **Mechanism (resolved): always override, no ownership signal.** The child's root `CLAUDE.md` is treated as a fully Shamt-managed generated artifact: regen **unconditionally** renders it as a verbatim copy of `templates/SHAMT_RULES.template.md` on every run (write-if-different, so the existing `wrote`/`unchanged`/`DRIFT` reporting still works). There is **no footer, no `is_managed()` gate, no managed-block marker** — adopting Shamt means accepting that the root rules file is managed by it. The only guard is **self-host**: regen detects self-host as `SHAMT_CORE_ROOT == TARGET_DIR` (in a child the script lives at `<child>/.shamt-core/scripts/` so the paths differ; in self-host the script lives at `<master>/scripts/` and they are equal) and **skips** the `CLAUDE.md` render there, because `<master>/CLAUDE.md` is the master-dev primer, not a child rules rendering. No footer is needed for human clarity either: the template's own intro line ("This file is a **template** rendered into a child project's `CLAUDE.md`… Generated copies are overwritten") is copied verbatim into the rendered file, so it self-documents as generated. `init-shamt.sh` already guards its whole seed step with `if [ "$SELF_HOST" -eq 0 ]`, so the master primer is safe on the init side too.

| # | Canonical path | Operation | One-line change description |
|---|----------------|-----------|------------------------------|
| 1 | `shamt-core/scripts/regenerate-framework.sh` | EDIT | Add a `CLAUDE.md`-render step: verbatim-copy `<SHAMT_CORE_ROOT>/templates/SHAMT_RULES.template.md` → `<target>/CLAUDE.md` (write-if-different), guarded by `[ "$SHAMT_CORE_ROOT" != "$TARGET_DIR" ]` (skip in self-host); emit `wrote`/`unchanged CLAUDE.md` lines + a `DRIFT CLAUDE.md` line under `--check`, matching the existing per-file contract; update the header-comment "Modes/Footer contract" block (lines 2–23) to note `CLAUDE.md` is always overwritten (not footer-gated). |
| 2 | `shamt-core/init-shamt.sh` | EDIT | §"Step: seed top-level docs" — drop the "pre-existing `CLAUDE.md` → preserve" branch so init **always** overwrites `<target>/CLAUDE.md` from the template; in the `.gitignore` block, make `/CLAUDE.md` **unconditional** (remove the `CLAUDE_SEEDED` gate and the variable) since the rules file is always managed now; update the §"Step: seed top-level docs" + gitignore inline comments (lines 26–28, 386–388) accordingly. |
| 3 | `shamt-core/host/templates/claude/commands/f4-regen-framework.md` | EDIT | Note that regen now also renders the root `CLAUDE.md` (always overwritten, self-host-guarded); add the `wrote/unchanged CLAUDE.md` + `--check` `DRIFT CLAUDE.md` lines to the surfaced output contract. |
| 4 | `shamt-core/host/templates/claude/commands/sync-import-shamt.md` | EDIT | Step 5 "Surface regen output" — add the `CLAUDE.md` line to the surfaced-output expectations so the refreshed rules file is visible after a pull. |
| 5 | `shamt-core/CLAUDE.md` | EDIT | §"What lives here" (line 22 install paragraph: `/CLAUDE.md` is **always** git-ignored + overwritten — remove "a pre-existing child `CLAUDE.md` is preserved and stays tracked"; line 16 caption) and the surfaces table (line 33 "Generated" row: "managed-section `CLAUDE.md`" → whole-file regenerated `CLAUDE.md`). Make the doc match the always-override reality. |
| 6 | `shamt-core/README.md` | EDIT | Fix the now-inaccurate `CLAUDE.md` claims: line 15 ("at init" → at init **and every regen/sync**), lines 53–59 + 280 (always git-ignored + overwritten — drop "only when init seeded it / pre-existing stays tracked"), and the regen description (lines 306, 312–313) to note regen renders `CLAUDE.md` too. |
| 7 | `shamt-core/templates/SHAMT_RULES.template.md` | EDIT | Intro line 6 — remove the now-inaccurate "(or a managed section of it)" parenthetical; the rules file is rendered whole-file into the child's `CLAUDE.md` and always overwritten (net-negative on the D12 size budget). |

---

## Risks

- **Regression risk — overwriting a project's own `CLAUDE.md`.** By design (per the resolved approach), regen and init now **always** overwrite the child's root `CLAUDE.md`. A project that adopts Shamt while already having a hand-authored `CLAUDE.md` loses that content (recoverable via git only if it was committed before install). This is the accepted trade-off: adopting Shamt means the root rules file is Shamt-managed; project-specific guidance belongs in `.shamt-core/project-specific-files/`, not the root rules file.
- **Self-host risk — clobbering the master primer.** When regen runs in self-host (`--target` = the master repo), `<target>/CLAUDE.md` is the master-dev primer, **not** a child rendering. The `SHAMT_CORE_ROOT == TARGET_DIR` self-host guard must be present and correct in the new regen step, or the primer is destroyed on every master regen. This is the single highest-severity row for validation to verify against the actual script. (init is already safe — its whole seed step is `SELF_HOST`-guarded.)
- **Drift risk** — purely *reduced* by this change: it closes the canonical-vs-loaded-rules drift the incident describes. The new drift surface (rendered `CLAUDE.md` vs the template) is exactly what `--check` now catches.
- **Child-project compatibility** — existing children pick this up automatically on their next `/sync-import-shamt` (→ regen overwrites their now-stale `CLAUDE.md` with the current template). No migration step, no marker to add — the always-override behavior is self-healing. A child that had hand-edited its root `CLAUDE.md` loses those edits on the next sync (same accepted trade-off as the regression risk).
- **Open-questions debt** — none remaining; the mechanism, the init-time override behavior, and the self-host guard are all resolved below.

---

## Rollback Plan

1. `git revert <commit-sha>` on the canonical edit commit.
2. Run `/f4-regen-framework` to propagate the revert into `.claude/` (the reverted regen script no longer renders `CLAUDE.md`).
3. Child-side: after the revert, the next `/sync-import-shamt` (→ regen) reverts to `.claude/`-only behavior and stops touching the root `CLAUDE.md`; the child keeps whatever `CLAUDE.md` it last rendered (git-ignored, re-derivable from the template by hand if needed — the prior manual remediation).
4. Communication: note in the master changelog that `CLAUDE.md` is (no longer) an always-regenerated artifact.

---

## Validation Considerations

- **Problem clarity** — the term "managed" is overloaded across the codebase: the master primer says "managed section," `.gitignore` has a "managed block," and `.claude/` files use the `Managed by Shamt` footer. The doc edits (rows 5–7) must land the always-override model cleanly **without** implying `CLAUDE.md` uses any of those three marker mechanisms — it uses none; it is unconditionally overwritten.
- **Change-list completeness** — the load-bearing pair is `init-shamt.sh` (always overwrite + always git-ignore `/CLAUDE.md`) and `regenerate-framework.sh` (always render, self-host-guarded). Verify the doc rows (5, 6, 7) actually remove **every** stale "pre-existing CLAUDE.md is preserved / git-ignored only when seeded / managed section" claim — these are scattered (primer lines 16/22/33; README lines 15/53–59/280/306/312–313; template line 6). A missed claim is a D2/D7 contradiction. The `f4-regen-framework` and `sync-import-shamt` **command** bodies need the output-contract edit, but their `SKILL.md` Protocols are pointer-only (Command → Skill pointer rule) — **no** paired SKILL edits.
- **Risk coverage** — verify the `SHAMT_CORE_ROOT != TARGET_DIR` self-host guard against the *actual* script (the master primer must survive a self-host regen). Confirm the existing `is_managed()`/footer logic and `.claude/` pruning are untouched — the `CLAUDE.md` render is an additive, separate branch, not a change to the managed-`.claude/` walk.
- **Rollback feasibility** — additive to regen behavior; revert is `git revert` + regen. No destructive DELETE/MOVE of canonical files.
- **Affected surfaces** — scripts (`regenerate-framework.sh`, `init-shamt.sh`), commands (`f4-regen-framework`, `sync-import-shamt`), root docs (master `CLAUDE.md`, `README.md`), and the rules template intro (`SHAMT_RULES.template.md` line 6).
- **Propagation plan** — takes effect for a child on its next `/sync-import-shamt` (→ regen overwrites the stale `CLAUDE.md`). No migration step required; the always-override behavior is self-healing for existing children.

---

## Open Questions

_None — all resolved (see below)._

---

## Resolved Questions

<!-- Append as questions resolve. One line each. -->

- ~~Q: OQ1 — ownership/refresh mechanism for the child root `CLAUDE.md`?~~ → A: **Superseded.** User chose **always override**: regen unconditionally renders `CLAUDE.md` from the template (no footer, no marker, no `is_managed()` gate). Adopting Shamt = accepting the root rules file is Shamt-managed. The only guard is self-host (`SHAMT_CORE_ROOT == TARGET_DIR` → skip, to protect the master primer).
- ~~Q: OQ2 — migration of existing children with a markerless seeded `CLAUDE.md`?~~ → A: **Dissolved by always-override.** No migration needed: existing children are overwritten with the current template on their next `/sync-import-shamt` (→ regen). Self-healing, no marker to add.
- ~~Q: OQ3 — does regen seed `CLAUDE.md` when absent, or only refresh?~~ → A: **Dissolved by always-override.** regen always writes `CLAUDE.md` (seed-when-absent is subsumed by unconditional render).
- ~~Q: At first install, should init override a pre-existing `CLAUDE.md`, and back it up?~~ → A: **Override silently, no backup** (symmetric with regen, simplest). init drops its pre-existing-preserve branch and always git-ignores `/CLAUDE.md`.

---

---
Validated 2026-06-23 — 2 rounds, 1 adversarial sub-agent confirmed
