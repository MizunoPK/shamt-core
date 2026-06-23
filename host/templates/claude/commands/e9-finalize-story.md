---
description: Phase 9 (Finalize) of the Shamt Engineer flow — commit the story's work as a scoped unit and mark the originating work item done via the active tracker, behind three guards (prior phases complete, clean-tree/scoped commit, explicit confirmation)
---

# /e9-finalize-story

**Purpose:** Run Phase 9 (Finalize) of the Engineer flow — the terminal step. Commit the story's work as a coherent, scoped unit and mark the originating work item finished via the active tracker profile, then write the local `**Status: Done**` marker that signals the story is finalized. Modelled on `/f6-archive-proposal` (the framework-update flow's terminal command); this is its story-altitude analogue.

**Recommended model:** Cheap (Haiku). Finalize is mechanical — evaluate three guards, stage a scoped commit, run one tracker-close command, flip a status line. No design judgment. See [`reference/model_selection.md`](../../../../reference/model_selection.md).

---

## Usage

```
/e9-finalize-story {slug}
```

## Arguments

- `{slug}` (required) — story slug or ticket ID (`T{N}`). Resolves the story folder per `templates/SHAMT_RULES.template.md` §PO-tree resolution (tree-wide glob + legacy-flat fallback; matches at most one, halt on zero or multiple). `stories/{slug}/` below denotes that resolved folder.
- `--tracker={ado|github|local}` (optional) — one-off override of the project's default `work_item_tracker` for this invocation only, per [`reference/trackers/_contract.md`](../../../../reference/trackers/_contract.md).

## Prerequisites

- `.shamt-core/shamt-config.json` exists at the project root (for the `work_item_tracker` default). If not, halt and direct the user to `init-shamt`.
- The story folder resolves to exactly one directory. Halt on zero or multiple matches.

## Step-by-step

### Step 1 — Guard: prior phases complete

Finalize is the terminal phase; it refuses to run on a story still mid-flow.

1. Confirm **Review** ran: a `feedback/review_vN.md` exists (or there were no findings and the user has signalled Polish complete). If Review never ran, halt and direct the user to `/e7-review-changes {slug}`.
2. Confirm **feedback is resolved**: if `feedback/addressed_feedback.md` exists, every row is `Resolved` / `Deferred — <reason>` / `Needs user decision` with an active follow-up — **no `Pending` rows**. If unresolved rows remain, halt and direct the user to `/e8-resolve-feedback {slug}`.
3. Confirm **Test passed** (Phase 6 is required): `stories/{slug}/agent_test_session.md` shows the session verdict `PASS`, and — when `TESTING_STANDARDS.md` declares automated suites — the active `testing_plan.md` shows every step `PASS`. If any is unrun or failing, halt and direct the user to `/e6-execute-tests {slug}`.

If any guard fails, halt with the specific remediation command — do not proceed.

### Step 2 — Guard: scoped, clean-tree commit

1. Run `git status --short`. Inventory the working-tree changes.
2. The commit covers **only the story's own work** — the files this story created or modified. If the tree contains changes that are **not** part of this story (unrelated edits, other in-flight work), **halt and ask** the user whether to include, stash, commit-separately, or ignore them (mirrors `/e7-review-changes`'s `git status --short` guard). Do not sweep unrelated changes into the finalize commit.
3. Build the explicit list of paths the commit will stage.

### Step 3 — Guard: explicit confirmation, then commit + mark done

1. Present, in one message: (a) the exact list of files to be committed, (b) the work item that will be marked done and **how** (per the active profile, Step 4), and (c) the local `**Status: Done**` marker that will be written to `ticket.md`.
2. **Wait for an explicit "yes."** The remote tracker close (Step 4, ado/github) is outward-facing — never perform it without confirmation.
3. On confirmation, stage the scoped path list and commit on the story's current (feature) branch. Commit subject: `{ticket-id-or-slug}: finalize — {one-line summary}`. The user's signing / hook setup applies.

### Step 3b — Merge the PR when `pr_provider == github`

Read `pr_provider` from `.shamt-core/shamt-config.json`. This step is **independent of** the work-item close (Step 4, `work_item_tracker`-routed) — a `pr_provider: github` + `work_item_tracker: ado` project merges the GitHub PR here and still closes its ADO work item via `az boards` in Step 4.

- **`pr_provider == github`** — the **only** `pr_provider == github`-gated addition:
  1. **Resolve the PR.** Read the PR number from `stories/{slug}/feedback/pr.md` (written by `/e7-review-changes`). If absent, halt and direct the user to open the PR first via `/e7-review-changes {slug}`.
  2. **Mergeable guard.** Run the github profile's mergeability check (`reference/trackers/github.md` `## PR merge`). If the PR is **not** mergeable (unresolved reviews / failing checks / conflicts), **halt** and report — do not merge.
  3. **Merge** under the **existing Step-3 explicit-confirm guard** (already obtained for the commit): `gh pr merge {pr} --squash --delete-branch`. Outward, irreversible — never run without the Step-3 confirmation.
- **`pr_provider != github`** (`ado` / `none` / unset) — **no-op.** No PR merge; today's commit-on-branch behavior is unchanged.

Sequence when `pr_provider == github`: mergeable-guard → confirm-gated PR merge (this step) → existing `work_item_tracker`-routed close (Step 4, unchanged) → write `**Status: Done**` (Step 5).

### Step 4 — Mark the work item done (active tracker profile)

Read `work_item_tracker` from `.shamt-core/shamt-config.json` (or the `--tracker=` override). This is **independent of `pr_provider`** — do not gate it on `pr_provider` or hardcode a PR-merge close here. Then, per profile:

- **ado** — set the work item's state to the project's done state: `az boards work-item update --id {id} --state "Done"` (or `Closed` per the project's process). Outward-facing — gated by Step 3 confirmation.
- **github** — close the issue: `gh issue close {id} --repo <org>/<repo>`. Outward-facing — gated by Step 3 confirmation.
- **local** — no remote; the local marker (Step 5) **is** the mark-done.
- **freeform / no tracker id** — skip the remote close; the local marker is the record.

If the remote close command fails, halt and report the git/CLI output — do not retry blindly. The commit (Step 3) already landed; the user resolves the close manually.

### Step 5 — Write the local finalize marker

**In all profiles**, write `**Status: Done**` into the story's `ticket.md` header (replacing any prior `**Status:**` line, or adding one). This is the profile-independent, no-network signal the status line reads to render the `Finalize` phase. Include it in the Step 3 commit (or amend it in if Step 4 ran after the commit).

### Step 5b — Tech-story completion archive

If the resolved story folder is nested under the standing **Tech Stories** epic — the `{tech-stories-folder}` / `{bugs|quick-wins}` segments are the **numbered** `{ID}-tech-stories` / `{ID}-bugs` / `{ID}-quick-wins` folders, resolved by globbing the reserved slug under any `T{N}-` prefix per §PO-tree resolution (its path matches `epics/*-tech-stories/features/*-bugs/stories/…` ∪ `…/features/*-quick-wins/stories/…`) — **move the finalized story folder into its feature's `archive/`** — `epics/{tech-stories-folder}/features/{f}/archive/{same-folder-name}/` (`git mv` when tracked) — within the same Step 3 commit. This keeps the standing Bugs / Quick Wins features from growing without bound (mirroring how `/pe4-finalize` archives a done epic and `/f6-archive-proposal` archives an implemented proposal). For a normal (non-Tech-Stories) story, **skip this step** — the story folder stays in place.

### Step 5c — Refresh the epic STATUS.md

After writing the local `**Status: Done**` marker (Step 5), **re-derive the parent epic's `STATUS.md` from disk** per [`commands/po-status.md`](po-status.md) (resolve the epic from the story's folder path) — this story now shows as `Released`, and the feature rollup is recomputed (a feature becomes `Released` once all its stories are). Re-derive the **whole table** (never patch a cell); the rollup is a derived VIEW per [`reference/epic_status_board.md`](../../../../reference/epic_status_board.md). For a Tech-Stories story archived in Step 5b, resolve the epic to the standing Tech Stories epic.

### Step 6 — Exit

State the exit clearly:

```text
Story {slug} finalized.
Committed: {N} files on {branch}.
Work item {id}: {marked Done via ado/github | local Status: Done}.
Engineer flow complete.
```

No next-phase suggestion. The Engineer flow ends at Phase 9 (Finalize).

## Exit criteria

- The story's scoped work is committed (after the three guards held).
- The work item is marked done via the active tracker (or local-only), and `ticket.md` carries `**Status: Done**`.

## Notes

- **Not an epic archive.** `/e9-finalize-story` finalizes a single story; it does **not** move the story folder. Epic-level archiving (moving a done epic into `epics/archive/`) is `/pe4-finalize`'s job.
- **Terminal phase.** Finalize is the last Engineer phase (Phase 9). The status line renders `P9 Finalize` once `ticket.md` carries `**Status: Done**`.
- **Fresh-agent runnable** — story folder, config, and working-tree state are sufficient. No conversation history required.
- **PR merge is `pr_provider`-gated.** When `pr_provider == github`, Finalize merges the story's PR (`gh pr merge --squash --delete-branch`, behind the Step-3 confirm + a mergeable-guard — Step 3b); this is the **only** `pr_provider == github`-gated addition. The **work-item close (Step 4) stays `work_item_tracker`-routed** (ado / github / local), independent of `pr_provider`. When `pr_provider != github`, finalize commits the story's work on its feature branch and stops — no PR merge.

---

<!-- Managed by Shamt — do not edit. Regenerate from shamt-core/host/templates/claude/commands/e9-finalize-story.md. -->
