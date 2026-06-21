# Proposal: import-deletion-propagation

**Created:** 2026-06-20
**Status:** Implemented
**Number:** 47
**Proposed by:** FantasyFootballHelperScripts
**Project context:** Found during a routine `/sync-import-shamt` pull from a local master; the import left stale renamed command/skill files behind as live ghost slash commands.

---

## Problem

`import-shamt.sh` propagates master *additions* and *updates* to a child but never propagates master *deletions* or *renames*. The sync is add/update-only: `apply_one` copies every path in master's sync set into the child (master wins on every diff), and Pass 2 (lines ~313-327) walks the child's files under the wholly-master-owned subtrees (`scripts/`, `templates/`, `reference/`, `host/`) and, for any file **absent from master**, emits `WARN: preserving local file not in master sync set: …` and tallies it as `preserved`. The script's own header states the contract as *"every path in the explicit MASTER_SYNC_PATHS set is master-owned. Master wins on every diff"* — but only the add/update arm of that contract is implemented; the **delete arm is missing**.

The consequence is a two-state conflation. A child file under a master-owned subtree that is absent from master can mean either **(A)** the child genuinely authored it (a local addition → preserve, correct today) or **(B)** master *owned and then deleted/renamed it* (→ should be removed). Pass 2 collapses both into the same `preserving local file` warning, so the user cannot tell "I added this" from "master deleted this." Worse, because the stale **canonical source** survives under `.shamt-core/host/templates/claude/...`, `regenerate-framework.sh` still sees it as present and keeps emitting the generated `.claude/` copy — surfacing the dropped command/skill as a **live ghost slash command** (e.g. both `/pe2-decompose` and its successor `/pe3-decompose` exposed at once). Regen is **not** at fault: its Step 2 prune (lines ~224-250) already removes a managed `.claude/` file once its canonical source disappears; the ghost persists only because import never removed the canonical source.

**Confirmed root cause (adversarial diagnosis — `root-cause-diagnoser` Opus + Haiku zero-bias confirmation, 2026-06-20).** The root cause is at the canonical-source altitude: `import-shamt.sh`'s stated contract is *"master wins on every diff"*, but only the add/update arm is implemented — the **delete arm is missing**. The fix is a **mirror-with-delete** of the master-owned subtrees: those subtrees (`scripts/`, `templates/`, `reference/`, `host/`) are treated as **wholly** master-owned (no child-authored files live there), so a child file **absent from master** under them is unambiguously a master-deletion → **remove** it (and report a distinct `removed: N` count). Once the stale canonical source is removed, `regenerate-framework.sh`'s existing prune (Step 2) drops the matching `.claude/` ghost on the same import — **no regen change is needed** (verified: regen prunes managed `.claude/` files whose canonical source disappeared). This closes the **whole** deletion/rename class in one mechanism across all four subtrees, with no new state file or content marker.

**Mechanism alternatives weighed and rejected.** A **footer heuristic** (classify by the `Managed by Shamt` tail-marker — present → master-deleted, absent → child-local) was the diagnosis's "minimal" candidate and works for `host/` (verified 100% footer-covered, 82/82) but was rejected as brittle: it relies on a grep'd content marker as a proxy for ownership, and `templates/` (0/17), `reference/` (0/19), `scripts/` (0/1) carry **no** footers, so it would need a 37-file footer backfill (and a Phase 3 plan) merely to function subtree-wide. A **manifest snapshot** (store master's shipped path-set in the child, diff across imports) and a **tombstone ledger** (master hand-maintains a committed removed-paths list) were also weighed; both add machinery (a new state file / a hand-appended ledger that must never be pruned) that mirror-with-delete avoids. The accepted trade-off: mirror-with-delete drops the prior "preserve child-local additions under the managed subtrees" behavior — a child's custom slash commands belong directly in `.claude/commands/` (regen preserves unmanaged files there) and project docs belong in `.shamt-core/project-specific-files/`, so the dropped escape hatch is not a supported authoring location.

**Real instance (this project, 2026-06-20).** Importing into `FantasyFootballHelperScripts` from local master `/home/kai/code/shamt-core` left 4 stale `command + skill` pairs, each a master *rename* whose successor was already present in the child:

| Stale (orphaned in child) | Renamed to in master | Master commit |
|---|---|---|
| `pe2-decompose` | `pe3-decompose` | `25475fa` (#41 po-validate-stage) |
| `pf2-decompose` | `pf3-decompose` | `25475fa` |
| `pe3-finalize`  | `pe4-finalize`  | `25475fa` |
| `sync-submit-proposal` | `sync-proposals` | `380d4d5` (#42 sync-proposals-batch-upstream) |

All 8 files (4 commands + 4 skills under `.shamt-core/host/templates/claude/` plus their generated `.claude/` copies) were surfaced only as misleading "preserving local file" warnings. They were cleaned up by hand this session, but nothing prevents recurrence on the next master rename/deletion.

---

## Proposed Changes

| # | Canonical path | Operation | One-line change description |
|---|----------------|-----------|------------------------------|
| 1 | `shamt-core/import-shamt.sh` | EDIT | Convert Pass 2 (lines ~313-327) from warn-and-preserve to **mirror-with-delete**: for a child file under a `MASTER_SYNC_DIRS` subtree absent from master, `rm` it, prune now-empty parent dirs, log `removed (no longer in master): .shamt-core/<sub>/<rel>`, and increment a new `REMOVED_COUNT`. Replace `PRESERVED_COUNT` (its only producer was Pass 2). Unconditional (no prompt/flag) per the non-interactive contract. |
| 2 | `shamt-core/import-shamt.sh` | EDIT | Rewrite the header comment (lines ~12-22) — drop the "subtree-level pragmatic interpretation / preserved with a warning" framing; state the actual contract: the managed subtrees are wholly master-owned and **mirrored** (master wins on diffs; child files absent from master are removed). **Also correct the stale variable name in that comment**: line 12 references a non-existent `MASTER_SYNC_PATHS` set — the real sync-set variables are `MASTER_SYNC_FILES` (line 235, individually-owned top-level files) and `MASTER_SYNC_DIRS` (line 245, wholly-master-owned subtrees); the rewritten comment must name these accurately (or describe the two sets) rather than the bogus `MASTER_SYNC_PATHS`. Update the summary block (line ~435): replace the `preserved: N (local files outside master sync set)` line with `removed: N (local files no longer in master)`. |
| 3 | `shamt-core/host/templates/claude/commands/sync-import-shamt.md` | EDIT | Replace every `preserved` reference to the **import** count tuple with `removed`: the frontmatter `description` (line ~2, "new / updated / unchanged / preserved counts" → "… / removed counts"), the Step 3 behavior list (line ~61, the "Preserves (with warnings) any local-only files…" bullet → "Removes any child file under the managed subtrees that master no longer ships (mirror-with-delete)"), the Step 4 summary schema (line ~76, replace `preserved: N` with `removed: N`) + its `WARN: preserving local file…` surfacing line (line ~82, now `removed …` lines), the Step 6 follow-up note (line ~101, "new / updated / unchanged / preserved counts" → "… / removed counts"), the Exit-criteria tuple (line ~106, "new / updated / unchanged / preserved / already-merged-moved" → "… / removed / …"), and the Notes "Footer contract" bullet (line ~117, the `.shamt-core/` rule is now subtree-level master-wins **+ mirror**, not "preserve everything else"). **Leave untouched** the regen-side `preserved-unmanaged` references (Purpose line ~7, Step 5 `WARN: preserving unmanaged file` line ~90) — those describe `regenerate-framework.sh`'s unmanaged-`.claude/` warnings, not the import count, and are unchanged by this proposal. |
| 4 | `shamt-core/README.md` | EDIT | Update §"`import-shamt.sh` — framework pull": the "Preserves (with warnings) any local-only files the child added under the managed subtrees" bullet (line ~294) → removal-on-mirror behavior; the import-shamt `.shamt-core/` rule paragraph (line ~321, "subtree-level master-wins for the explicit sync set, preserve everything else") → mirror semantics; and the high-level ownership line (~63) to clarify the managed subtrees are mirrored (child files there absent from master are removed), while files **outside** the managed subtrees remain user-owned and preserved. |
| 5 | `shamt-core/host/templates/claude/skills/sync-import-shamt/SKILL.md` | EDIT | Two SKILL sites that independently paraphrase import behavior (the `## Protocol` body is a pointer and is **not** edited — Command → Skill Protocol pointer rule): **(a)** the frontmatter `description:` count tuple (line ~10): "new / updated / unchanged / **preserved** counts" → "… / **removed** counts" (leave the `preserved-unmanaged` phrase on that same line untouched — it is the regen-side `.claude/` warning, out of scope); **(b)** the `## Footer contract` section (line ~41), whose "Files the child adds under `.shamt-core/{templates,reference,host,scripts}/` … are **preserved with a warning**" sentence describes the old behavior → restate as the mirror-with-delete contract (the master-owned subtrees are mirrored; a child file there that master no longer ships is removed). |

---

## Risks

- **Regression risk** — import-shamt gains its **first destructive operation** (it has only ever copied, never deleted). Mirror-with-delete removes any child file under the managed subtrees absent from master. Blast radius is bounded to the four wholly-master-owned subtrees (`scripts/`, `templates/`, `reference/`, `host/`); the child's own code, `.shamt-core/project-specific-files/`, the work tree, proposals, and `shamt-state/` are all **outside** `MASTER_SYNC_DIRS` and untouched.
- **Lost-child-file risk** — a child that *did* author a file under a managed subtree loses it, and (because a child install git-ignores `/.shamt-core/`) it is not recoverable from the child's own git. This is the accepted trade-off of mirror-with-delete: those subtrees are not a supported authoring location (custom slash commands → `.claude/commands/`, preserved as unmanaged by regen; project docs → `.shamt-core/project-specific-files/`). Mitigated by **loud per-file logging** (`removed (no longer in master): <path>`) + the distinct `removed: N` count surfaced by `/sync-import-shamt`, so no deletion is silent.
- **Drift risk** — none new: the change makes canonical→child→`.claude/` *more* consistent. No `regenerate-framework.sh` change — its existing prune handles the generated `.claude/` side once the canonical source is removed.
- **Child-project compatibility** — on the first post-fix import, existing children with pre-fix orphans get them cleaned up automatically (any child file under the managed subtrees not in master is removed). A clean child sees a `removed: 0` count. No manual reconciliation required. Note the crossover caveat: `import-shamt.sh` reaches a child via its own sync, so deletion propagation takes effect on the import *after* the fixed script is installed (the crossover import runs the old, pre-fix script).
- **Open-questions debt** — none. Mechanism (mirror-with-delete), safety posture (unconditional + loud logging), and rename handling (delete-old + add-new, no special-casing) are all resolved below.

---

## Rollback Plan

1. `git revert <commit-sha>` on the canonical edit commit.
2. Run `/f4-regen-framework` to propagate the revert into `.claude/` (no-op for this change — only `import-shamt.sh` + docs change; `import-shamt.sh` reaches children on their next `/sync-import-shamt`).
3. Child-side action: none required. Reverting restores the prior add/update-only behavior; already-removed orphans stay removed (which is the desired end state regardless).
4. Communication: note in the next sync that deletion propagation was rolled back if a child relied on it.

---

## Validation Considerations

- **Problem clarity** — the canonical-source vs. generated-`.claude/` two-surface distinction is central: the ghost persists because the *canonical source* survived import, not because regen failed. Validator should confirm the Problem keeps that distinction crisp.
- **Change-list completeness** — `import-shamt.sh` is the only script edited; confirm `regenerate-framework.sh` is correctly **excluded** (its prune already handles the generated side). Confirm every site documenting the old "preserve child-local under managed subtrees" behavior is scrubbed — verified canonical sites: `import-shamt.sh` (header 12-22, Pass 2 315/323-324, `PRESERVED_COUNT` 255, summary 435), `sync-import-shamt.md` (frontmatter `description` ~2, Step 3 behavior bullet ~61, Step 4 summary schema ~76 + preserve-warning surfacing ~82, Step 6 follow-up ~101, Exit-criteria tuple ~106, Notes footer-contract bullet ~117), `README.md` (lines 63, 294, 321). The two regen-side `preserved-unmanaged` references in `sync-import-shamt.md` (Purpose ~7, Step 5 `WARN: preserving unmanaged file` ~90) are **out of scope** — they describe `regenerate-framework.sh`'s unmanaged-`.claude/` warning, not the import count. On the paired `skills/sync-import-shamt/SKILL.md`: its `## Protocol` **body** stays a pointer to the command body, so it needs **no** edit (Command → Skill Protocol pointer rule) — but the SKILL has **two** non-Protocol sites that independently paraphrase import behavior and so **do** need edits (Row 5): (a) the **frontmatter `description:`** count tuple ("new / updated / unchanged / preserved counts", line ~10), and (b) the **`## Footer contract` section** (line ~41), whose "child-added files … are preserved with a warning" sentence describes the old behavior and must restate the mirror-with-delete contract. The pointer rule governs the Protocol body only; it does not exempt the SKILL's other prose copies of the behavior. (The `preserved-unmanaged` phrase on the frontmatter line is the regen-side warning and stays untouched, per Row 5's carve-out.)
- **Risk coverage** — scrutinize the first-ever-destructive-operation risk and the lost-child-file case (irrecoverable under a git-ignored `.shamt-core/`); confirm the blast radius is genuinely bounded to `MASTER_SYNC_DIRS` and that the loud-logging mitigation is wired (per-file line + count).
- **Rollback feasibility** — straightforward; the only non-obvious point is that removed orphans stay removed after revert (acceptable — removal is the desired end state regardless).
- **Affected surfaces** — scripts (`import-shamt.sh`), commands (`sync-import-shamt.md`), the paired skill (`skills/sync-import-shamt/SKILL.md` — frontmatter `description:` + `## Footer contract` section; Protocol body untouched), root docs (`README.md`). No template/reference/host *canonical-body* edits (mirror-with-delete needs no footer backfill; the SKILL touches are behavior-paraphrase prose, not a Protocol-body edit).
- **Propagation plan** — `import-shamt.sh` is in its own sync set, so children pick the fix up on their next `/sync-import-shamt` (the crossover import runs the *old* script; deletion propagation takes effect on the import *after* the fixed script is installed). No change to `regenerate-framework.sh` itself, but `/f4-regen-framework` is **not** a no-op: it propagates the two `host/templates/claude/` edits (the `sync-import-shamt` command + SKILL) into `.claude/commands/` and `.claude/skills/`. The `import-shamt.sh` and `README.md` edits are root-level (not regen targets) and reach children via `/sync-import-shamt`.

---

## Open Questions

_(None — all resolved.)_

---

## Resolved Questions

<!-- Drafting-only log. -->

- ~~Q: Detection mechanism — how does import distinguish a master-deleted file from a genuine child-local addition (footer heuristic, manifest snapshot, tombstone ledger)?~~ → A: **Mirror-with-delete.** The managed subtrees are treated as wholly master-owned (no child authoring there), so "absent from master" = master-deleted → remove. No footer (rejected as brittle + needs a 37-file backfill to function subtree-wide), no manifest, no tombstone. Simplest / least machinery; closes the whole class across all four subtrees.
- ~~Q: Scope — host-only fix now vs. also backfill footers across `templates/`/`reference/`/`scripts/` (→ Phase 3)?~~ → A: **Moot under mirror-with-delete** — it closes all four subtrees with no footer backfill, so the proposal stays at 5 files / 5 change rows (≤10 → no Phase 3).
- ~~Q: Safety posture — unconditional removal vs. dry-run / confirmation guard?~~ → A: **Unconditional + loud logging** — matches import's existing non-interactive overwrite behavior and keeps it scriptable; every deletion is surfaced via a per-file `removed (no longer in master): <path>` line and the distinct `removed: N` summary count.
- ~~Q: Rename handling — delete-old + add-new vs. detect/report renames as `old → new`?~~ → A: **delete-old + add-new, no special-casing** — mechanically forced by mirror-with-delete (the old path is removed, the new path is already synced by the add/update arm); rename detection would be cosmetic only.

---

Validated 2026-06-20 — 1 rounds, 1 adversarial sub-agent confirmed