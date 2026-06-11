---
description: Phase 8 (Finalize) of the Shamt Engineer flow — commit the story's work as a scoped unit and mark the originating work item done via the active tracker, behind three guards (prior phases complete, clean-tree/scoped commit, explicit confirmation)
---

# /e8-finalize-story

**Purpose:** Run Phase 8 (Finalize) of the Engineer flow — the terminal step. Commit the story's work as a coherent, scoped unit and mark the originating work item finished via the active tracker profile, then write the local `**Status: Done**` marker that signals the story is finalized. Modelled on `/f6-archive-proposal` (the framework-update flow's terminal command); this is its story-altitude analogue.

**Recommended model:** Cheap (Haiku). Finalize is mechanical — evaluate three guards, stage a scoped commit, run one tracker-close command, flip a status line. No design judgment. See [`reference/model_selection.md`](../../../../reference/model_selection.md).

---

## Usage

```
/e8-finalize-story {slug}
```

## Arguments

- `{slug}` (required) — story slug or ticket ID (`T{N}`). Resolves the story folder exact-then-glob — `stories/{slug}/`, then `stories/{slug}-*/` (the `{ID}-{slug}-{brief}` folder shape; matches at most one, halt on multiple).
- `--tracker={ado|github|local}` (optional) — one-off override of the project's default `work_item_tracker` for this invocation only, per [`reference/trackers/_contract.md`](../../../../reference/trackers/_contract.md).

## Prerequisites

- `.shamt-core/shamt-config.json` exists at the project root (for the `work_item_tracker` default). If not, halt and direct the user to `init-shamt`.
- The story folder resolves to exactly one directory. Halt on zero or multiple matches.

## Step-by-step

### Step 1 — Guard: prior phases complete

Finalize is the terminal phase; it refuses to run on a story still mid-flow.

1. Confirm **Review** ran: a `feedback/review_vN.md` exists (or the story is Quick-path with no findings and the user has signalled Polish complete). If Review never ran, halt and direct the user to `/e6-review-changes {slug}`.
2. Confirm **feedback is resolved**: if `feedback/addressed_feedback.md` exists, every row is `Resolved` / `Deferred — <reason>` / `Needs user decision` with an active follow-up — **no `Pending` rows**. If unresolved rows remain, halt and direct the user to `/e7-resolve-feedback {slug}`.
3. When testing is enabled (`.shamt-core/shamt-config.json` `testing: "enabled"`), confirm **Test passed**: the active `testing_plan.md` (or the Quick-path inline checklist) shows every step `PASS`. If any step is unrun or failing, halt and direct the user to `/e5-execute-tests {slug}`.

If any guard fails, halt with the specific remediation command — do not proceed.

### Step 2 — Guard: scoped, clean-tree commit

1. Run `git status --short`. Inventory the working-tree changes.
2. The commit covers **only the story's own work** — the files this story created or modified. If the tree contains changes that are **not** part of this story (unrelated edits, other in-flight work), **halt and ask** the user whether to include, stash, commit-separately, or ignore them (mirrors `/e6-review-changes`'s `git status --short` guard). Do not sweep unrelated changes into the finalize commit.
3. Build the explicit list of paths the commit will stage.

### Step 3 — Guard: explicit confirmation, then commit + mark done

1. Present, in one message: (a) the exact list of files to be committed, (b) the work item that will be marked done and **how** (per the active profile, Step 4), and (c) the local `**Status: Done**` marker that will be written to `ticket.md`.
2. **Wait for an explicit "yes."** The remote tracker close (Step 4, ado/github) is outward-facing — never perform it without confirmation.
3. On confirmation, stage the scoped path list and commit on the story's current (feature) branch. Commit subject: `{ticket-id-or-slug}: finalize — {one-line summary}`. The user's signing / hook setup applies.

### Step 4 — Mark the work item done (active tracker profile)

Read `work_item_tracker` from `.shamt-core/shamt-config.json` (or the `--tracker=` override). Then, per profile:

- **ado** — set the work item's state to the project's done state: `az boards work-item update --id {id} --state "Done"` (or `Closed` per the project's process). Outward-facing — gated by Step 3 confirmation.
- **github** — close the issue: `gh issue close {id} --repo <org>/<repo>`. Outward-facing — gated by Step 3 confirmation.
- **local** — no remote; the local marker (Step 5) **is** the mark-done.
- **freeform / no tracker id** — skip the remote close; the local marker is the record.

If the remote close command fails, halt and report the git/CLI output — do not retry blindly. The commit (Step 3) already landed; the user resolves the close manually.

### Step 5 — Write the local finalize marker

**In all profiles**, write `**Status: Done**` into the story's `ticket.md` header (replacing any prior `**Status:**` line, or adding one). This is the profile-independent, no-network signal the status line reads to render the `Finalize` phase. Include it in the Step 3 commit (or amend it in if Step 4 ran after the commit).

### Step 6 — Exit

State the exit clearly:

```text
Story {slug} finalized.
Committed: {N} files on {branch}.
Work item {id}: {marked Done via ado/github | local Status: Done}.
Engineer flow complete.
```

No next-phase suggestion. The Engineer flow ends at Phase 8 (Finalize).

## Exit criteria

- The story's scoped work is committed (after the three guards held).
- The work item is marked done via the active tracker (or local-only), and `ticket.md` carries `**Status: Done**`.

## Notes

- **Not an epic archive.** `/e8-finalize-story` finalizes a single story; it does **not** move the story folder. Epic-level archiving (moving a done epic into `epics/archive/`) is `/p5-finalize-epic`'s job.
- **Terminal phase.** Finalize is the last Engineer phase. The status line renders `P{N} Finalize` once `ticket.md` carries `**Status: Done**` (N = 7 normally, 8 when automated testing is enabled).
- **Fresh-agent runnable** — story folder, config, and working-tree state are sufficient. No conversation history required.
- **No squash-merge.** Unlike `/f6-archive-proposal`, the story is not on a proposal branch; finalize commits the story's work on its feature branch and stops. PR creation / merge is the `pr_provider`'s concern, out of scope here.

---

<!-- Managed by Shamt — do not edit. Regenerate from shamt-core/host/templates/claude/commands/e8-finalize-story.md. -->
