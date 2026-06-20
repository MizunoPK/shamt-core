# Proposal: sync-proposals-assume-local-master

**Created:** 2026-06-19
**Status:** Draft
**Number:** 46
**Proposed by:** FantasyFootballHelperScripts
**Project context:** `/sync-proposals` dumped full proposal contents into chat for manual copy-paste, which is wasted effort when master is a local path on the same machine.

---

## Problem

The child-side `/sync-proposals` command (canonical body `host/templates/claude/commands/sync-proposals.md`) **unconditionally** prints the full contents of every active proposal into chat as fenced copy-paste blocks (Step 3, sub-step 5), expecting the user to manually paste each into master's `proposals/incoming/`. Step 3 has **no branch on `master_url` shape** — it produces copy-paste blocks whether master is a remote git URL or a local directory the user already has checked out on the same machine. A real run at FantasyFootballHelperScripts (whose `master_url` is the local path `/home/kai/code/shamt-core`) emitted three full proposals as a large wall of text the user then had to hand-paste — wasted effort, since the agent could have written each file directly into the local master.

The root cause is twofold. First, the submit half of the master/child sync **forgot the local-vs-remote `master_url` discrimination the import half already ships**: `import-shamt.sh` already branches via `is_git_url()` (matching `https://`, `http://`, `git://`, `ssh://`, `git@`) — cloning for a git URL, and using `master_url` directly as an absolute local path otherwise (lines ~170-189), a behavior `sync-import-shamt.md` documents in its Notes ("**`master_url` formats.** Git URL (cloned `--depth 1`) or absolute local path (used directly with no copy). The script auto-detects via prefix"). Second, the `/sync-proposals` Notes bullet "**Manual copy is the design.** … No automation that pushes to master — that would re-introduce upstream tooling (PR creation, GitHub auth) that v2 explicitly omitted" **conflates two genuinely different things**: (a) pushing to a *remote* master / opening PRs / using GitHub auth (genuinely out of v2 scope per `CLAUDE.md` §"What's deliberately out of scope"), and (b) writing a file into a *local directory the user already has checked out* — which is a plain filesystem write the user still reviews/commits/pushes by hand, the exact symmetric mirror of the import side's local-path read. Conflating (b) with (a) is the rationalization that locks the copy-paste-only behavior in place; left unfixed, a future reviewer or `/f5` audit would push back on a Step 3 change while citing that Notes bullet. The fix must mend both Step 3 and the Notes.

This proposal was raised by the child project FantasyFootballHelperScripts (original f0 capture). The `/sync-submit-proposal` per-proposal sibling the f0 informally implicated **no longer exists** — proposal #42 removed it and replaced it with this slugless batch `/sync-proposals` — so `/sync-proposals` is the only command in scope.

---

## Proposed Changes

| # | Canonical path | Operation | One-line change description |
|---|----------------|-----------|------------------------------|
| 1 | `shamt-core/host/templates/claude/commands/sync-proposals.md` | EDIT | Front-matter `description:` — replace "prints one copy-paste block per proposal … for manual copy-paste" with the new dual behavior (direct-write when `master_url` is a local path; copy-paste fallback for a git URL). |
| 2 | `shamt-core/host/templates/claude/commands/sync-proposals.md` | EDIT | New **Step 1.5 — Resolve local master**: read `master_url` from `.shamt-core/shamt-config.json` (jq-or-sed fallback, mirroring `import-shamt.sh`) and resolve it as a local filesystem path. If it is not an existing directory, or has no `proposals/incoming/` subdirectory (e.g. `master_url` is a git URL), **halt with a clear actionable error** ("`/sync-proposals` direct-writes into a local master; set `master_url` to a local shamt-core checkout, or copy proposals upstream manually") — no copy-paste fallback path. |
| 3 | `shamt-core/host/templates/claude/commands/sync-proposals.md` | EDIT | Step 3 (and Step 5 exit message) — replace the copy-paste-block emission with a direct write of `{master}/proposals/incoming/{project_name}-{slug}.md` (stripped `**Number:**`, content identical to today's emitted block) behind an overwrite guard: if the target is byte-identical, log "unchanged" and skip; if it differs, surface via `AskUserQuestion` (overwrite / skip); otherwise write. Print a one-line "wrote {path}" (or "unchanged" / "skipped") confirmation per proposal. Step 5 lists the per-slug outcomes and still points to `/sync-triage-proposals`. |
| 4 | `shamt-core/host/templates/claude/commands/sync-proposals.md` | EDIT | Notes — rewrite the "Manual copy is the design" bullet: the design is now a direct local-FS write into the user's master checkout (no copy-paste). Explicitly distinguish this from genuine out-of-scope (no remote push / PR / GitHub auth) — a local write the user still reviews/commits/pushes is the symmetric mirror of `import-shamt.sh`'s local-path read. |
| 5 | `shamt-core/host/templates/claude/skills/sync-proposals/SKILL.md` | EDIT | Front-matter `description:` (and the `## Exit criteria` bullet that says "printed to chat") — reflect the direct-write-to-local-master behavior. `## Protocol` stays the verbatim pointer (no paraphrase). |
| 6 | `shamt-core/host/templates/claude/commands/sync-import-shamt.md` | EDIT | Notes — append one symmetry sentence noting `/sync-proposals` direct-writes into a local `master_url` in the submit direction, the mirror of this command's local-path read, keeping the two halves of the sync surface conceptually paired against future drift. |
| 7 | `shamt-core/host/templates/claude/commands/sync-proposals.md` | EDIT | Step 4 (move to `submitted/`) — make the move conditional on the Step 3 outcome: a proposal that was **written** or found **unchanged** moves to `.shamt-core/proposals/submitted/{slug}.md` as today; a proposal the user chose to **skip** stays active (not moved) so the next run can retry it. |

---

## Risks

- **Regression risk** — A bug in the local-path resolution or the write target could send a proposal to the wrong directory or skip submission entirely. Mitigated by the Step 1.5 guard that halts with a clear message whenever `master_url` is not a usable local directory with `proposals/incoming/`.
- **Git-URL master regression** — Per Q1 the command is always-local with no copy-paste fallback, so a child whose `master_url` is a git URL can no longer submit via `/sync-proposals` (it halts with guidance to set a local `master_url` or copy manually). Accepted trade-off: the framework owner's setup always has a local master, and the halt is actionable rather than a silent failure.
- **Overwrite / data-loss risk** — Direct-write into `proposals/incoming/{project}-{slug}.md` could silently clobber a prior un-triaged submission (or a re-submission) on master. Mitigated by the overwrite guard (see Open Question 2) — no silent destructive overwrite of a differing file.
- **Scope-boundary risk** — Direct-writing into master could be misread as crossing v2's "no upstream tooling" line. Mitigated by the Notes rewrite (Change 4) that explicitly distinguishes local-FS write from remote push/PR/auth, and by the symmetry with the already-shipped import-side local-path behavior. See Open Question 3 on whether `CLAUDE.md` should also carry the clarification.
- **Drift risk** — Standard canonical→`.claude/` drift if regen is skipped. Mitigated by `/f4-regen-framework` + `--check`. The command/skill description fields and the `sync-import-shamt` cross-reference are the easy-to-miss paired edits.
- **Child-project compatibility** — Purely behavioral; picked up cleanly on the next `import-shamt`. A child whose `master_url` is a git URL now halts instead of emitting copy-paste blocks (see Git-URL master regression above) — no other manual reconciliation needed.
- **Open-questions debt** — Three decisions (always-local vs. detect-and-branch; overwrite behavior; CLAUDE.md scope note) are resolved in the dialog below before exit.

---

## Rollback Plan

1. `git revert <commit-sha>` on the canonical edit commit.
2. Run `/f4-regen-framework` to propagate the revert into `.claude/`.
3. No child-side action required — children pick up the prior behavior on their next `/sync-import-shamt`.
4. Communication: note the revert in the next sync to FantasyFootballHelperScripts (the requester).

---

## Validation Considerations

- **Problem clarity** — The "local write is not upstream tooling" distinction is the crux; the validator should confirm the Notes rewrite (Change 4) actually disentangles remote-push from local-write rather than just softening the wording.
- **Change-list completeness** — Five of the rows (1, 2, 3, 4, 7) are sub-edits of the one `sync-proposals.md` file; verify Step 5's exit message is updated alongside Step 3, and that Step 4's conditional move (Change 7) is consistent with the Step 3 skip outcome (both easy to miss). Verify the `SKILL.md` `## Protocol` stays a pointer (Command → Skill Protocol pointer rule, D2) — only its front-matter `description:` and `## Exit criteria` change. Verify the `sync-import-shamt.md` cross-reference (Change 6) is the *only* import-side edit (no behavior change there).
- **Risk coverage** — The overwrite guard is the highest-value safety check; confirm the chosen behavior (Open Question 2) is reflected in Step 3 and that the byte-identical case is a no-op, not a prompt.
- **Rollback feasibility** — Purely behavioral, no destructive DELETE/MOVE; `git revert` + regen suffices.
- **Affected surfaces** — commands (`sync-proposals`, `sync-import-shamt`) + one skill (`sync-proposals`). Confirm the jq-or-sed `master_url` reader is quoted to match `import-shamt.sh` exactly (consistency, D7/D2), and that no copy-paste fallback survives anywhere in the body after the always-local rewrite.
- **Propagation plan** — Requires regen + child import to take effect. No already-installed child needs a manual nudge; the change is backward-compatible (git-URL masters keep copy-paste).

---

## Open Questions

_All resolved — see Resolved Questions below._

---

## Resolved Questions

- ~~Q1: Always-local vs. detect-and-branch on `master_url` shape?~~ → A: **Always assume local** (per the f0 blurb). No copy-paste fallback path — Step 3 always direct-writes. Step 1.5 resolves `master_url` as a local path and halts with an actionable error when it is not a usable local directory with `proposals/incoming/` (e.g. a git URL). Accepted trade-off: a git-URL-master child can no longer submit via `/sync-proposals` (halts with guidance) — documented in Risks.
- ~~Q2: Overwrite behavior when `proposals/incoming/{project}-{slug}.md` already exists on master?~~ → A: **Prompt on differ, no-op if same.** Byte-identical target → log "unchanged", skip the write. Differing target → `AskUserQuestion` (overwrite / skip). A skipped proposal stays active (Step 4 does not move it to `submitted/`). Added as Change 3 (guard) + Change 7 (conditional move).
- ~~Q3: Where to make the "local write ≠ remote push" boundary explicit — `CLAUDE.md` out-of-scope or the `sync-proposals.md` Notes?~~ → A: **`sync-proposals.md` Notes only** (Change 4). `CLAUDE.md` stays untouched — its out-of-scope list names only remote tooling (PR creation / GitHub auth / multi-host), which the local-write design does not touch, so no new master-primer row is needed.
