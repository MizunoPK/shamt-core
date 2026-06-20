---
description: Child-side. Batch-prepare every active child-local proposal for upstream submission to master. Iterates all top-level .shamt-core/proposals/*.md regardless of status (f0 draft / validated / in-progress Draft), strips any numeric ID, and direct-writes each one into the local master's proposals/incoming/{project}-{slug}.md (read from master_url) behind an overwrite guard, then moves each written/unchanged local copy to proposals/submitted/{slug}.md. Halts with actionable guidance when master_url is not a usable local checkout (e.g. a git URL) — no copy-paste blocks.
---

# /sync-proposals

**Purpose:** Run the child-side batch submit step of the v2 master/child sync (Part 4). Iterate **every active** top-level `.shamt-core/proposals/*.md` proposal — regardless of status (an `f0` draft, a validated proposal, or an in-progress plain-`Draft`) — and for each one **direct-write** the content into the **local** master's `proposals/incoming/` (resolved from `master_url`), then move the local copy to `proposals/submitted/{slug}.md` so the child tracks "submitted, awaiting decision" state and does not re-ship the same idea next run.

This is a **batch** command (slugless): one run clears the whole active set. It does **not** classify or gate on status — there is no validation-footer requirement. The child is primarily an *idea-capture* surface, so the common payload is an f0 draft (master does the f1 fleshing + validation), but a validated or in-progress proposal is shipped just the same; master triages whatever arrives.

The submission is a **direct local-filesystem write** into the master checkout the user already has on the same machine — the symmetric mirror of the import side's local-path read (`import-shamt.sh`). This command **assumes a local `master_url`**: it resolves `master_url` to a local directory and writes each proposal into its `proposals/incoming/`. If `master_url` is not a usable local checkout (e.g. a git URL), it **halts with actionable guidance** — there is no copy-paste fallback. It does not push to master, does not open PRs, does not file issues; the user reviews / commits / pushes the written files on master by hand.

**Recommended model:** Cheap (Haiku). The command lists files, reads them, writes them into the local master, and moves the local copies. No design judgment. See [`reference/model_selection.md`](../../../../reference/model_selection.md).

---

## Usage

```
/sync-proposals
```

## Arguments

None — the command is slugless and batches every active top-level proposal.

## Prerequisites

- This command runs **on the child side**. Master-side projects do not submit upstream — they author proposals locally and run the framework-update flow directly. Detect master vs. child by checking for `proposals/incoming/` at the cwd: the incoming folder is master's, and child projects never have it. If `proposals/incoming/` exists, halt and direct the user to `/f1-propose-update` + the rest of the Part 3 framework-update flow instead.
- `.shamt-core/shamt-config.json` exists at the project root and declares `project_name`. If missing, halt and direct the user to set it: `project_name` namespaces upstream submissions.
- At least one active proposal exists at top-level `.shamt-core/proposals/*.md` (excluding `_template.md` and the `submitted/ archive/ already-merged/ rejected/ deferred/` subfolders). If none, report "No active proposals to submit." and exit cleanly.

## Step-by-step

### Step 1 — Read .shamt-core/shamt-config.json

1. Read `.shamt-core/shamt-config.json` at the project root.
2. Extract `project_name`. If empty or missing, halt with: *".shamt-core/shamt-config.json must declare project_name — set it and re-run."*
3. Validate that `project_name` matches `^[A-Za-z0-9._-]+$`. Halt if not — the value will appear in each master-side filename `proposals/incoming/{project_name}-{slug}.md` and must be filesystem-safe.

### Step 1.5 — Resolve the local master

This command **direct-writes** into a *local* master checkout. Resolve it now and halt early if it is not usable — there is **no copy-paste fallback**.

1. Read `master_url` from `.shamt-core/shamt-config.json`. Mirror `import-shamt.sh`'s reader exactly: prefer `jq` when available — `jq -r '.master_url // empty' .shamt-core/shamt-config.json` — and fall back to the tolerant sed pair otherwise — `sed -n 's/.*"master_url"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' .shamt-core/shamt-config.json | head -n 1`. Halt if empty.
2. Determine whether `master_url` is a git URL using the same prefix test `import-shamt.sh`'s `is_git_url()` uses — it matches `https://`, `http://`, `git://`, `ssh://`, or `git@`. If `master_url` is a git URL, **halt** with the actionable error:

   > `/sync-proposals` direct-writes into a local master; `master_url` is a git URL (`{master_url}`). Set `master_url` to a local shamt-core checkout, or copy proposals upstream manually.

3. Otherwise treat `master_url` as a local filesystem path. Resolve it (e.g. `cd "$master_url" && pwd -P`). If it is **not an existing directory**, or it has **no `proposals/incoming/` subdirectory**, **halt** with the same actionable error (the absent `proposals/incoming/` is the signal it is not a usable master checkout):

   > `/sync-proposals` direct-writes into a local master; `{master_url}` is not a usable local shamt-core checkout (no `proposals/incoming/`). Set `master_url` to a local shamt-core checkout, or copy proposals upstream manually.

4. The resolved absolute path is the **master root** used by Step 3's write target `{master}/proposals/incoming/{project_name}-{slug}.md`.

### Step 2 — Enumerate the active proposal set

1. List the **top-level** files matching `.shamt-core/proposals/*.md`.
2. **Exclude** `_template.md` and anything under the `submitted/`, `archive/`, `already-merged/`, `rejected/`, and `deferred/` subfolders (these are not active — `*.md` is a top-level glob, so subfolders are already excluded; the explicit list documents intent).
3. For each remaining file, compute its **submission slug**: take the filename without `.md`, and strip any leading `{NN}-` numeric run (a `^[0-9]+-` prefix). The result is the unnumbered slug. Child-side proposals are unnumbered by convention, but a proposal that originated on master or was hand-numbered must shed its number before going upstream so master assigns its own at triage.
4. If the set is empty, report "No active proposals to submit." and exit cleanly.

### Step 3 — Per-proposal: read, strip number, compute target path, write

Process each proposal in the active set, in `ls`-sorted order. For each:

1. Read the proposal file top-to-bottom.
2. Confirm the proposal's header carries `Proposed by:` and `Project context:` fields with non-empty values. Child-submitted proposals fill these in so master's `/sync-triage-proposals` can attribute the change. If either is empty, surface to the user via `AskUserQuestion` what value to fill in, then update the header in place before submission.
3. **Strip the numeric ID from the emitted content:** remove the `**Number:** {NN}` header line entirely (master assigns its own number at triage). Do not alter any other header.
4. Compute the master target path using the stripped slug and the master root resolved in Step 1.5:

   ```
   {master}/proposals/incoming/{project_name}-{slug}.md
   ```

   The content to write is the full proposal with the `**Number:**` header removed (Step 3.3), including any validation footer if present — byte-for-byte the proposal body, no wrapper.

5. **Write the target behind an overwrite guard:**
   - If the target file **already exists and is byte-identical** to the content to write, **do not write** — log `unchanged  {master}/proposals/incoming/{project_name}-{slug}.md` and record this proposal's outcome as **unchanged**.
   - If the target file **already exists and differs**, surface the conflict to the user via `AskUserQuestion` (**overwrite** / **skip**). On **overwrite**, write the file and record the outcome as **written**. On **skip**, do not write and record the outcome as **skipped**.
   - Otherwise (target does not exist), write the file and record the outcome as **written**.
6. Print a one-line per-proposal confirmation: `wrote {path}`, `unchanged {path}`, or `skipped {path}`. The recorded outcome (written / unchanged / skipped) drives Step 4's conditional move.

### Step 4 — Move each written/unchanged local copy to submitted/

After writing all proposals, move each *submitted* proposal out of the active set. **The move is conditional on the Step 3 outcome:**

1. Ensure `.shamt-core/proposals/submitted/` exists. Create it if not.
2. For each proposal whose Step 3 outcome was **written** or **unchanged**, move `.shamt-core/proposals/{original-name}.md` → `.shamt-core/proposals/submitted/{slug}.md` — using the **unnumbered** `{slug}.md` name (normalize the name on the way in, consistent with the strip-the-number rule) (use `git mv` when tracked, `mv` otherwise).
3. A proposal whose Step 3 outcome was **skipped** (the user declined to overwrite a differing master target) is **not moved** — it stays active at its top-level location so the next `/sync-proposals` run can retry it.
4. "Deleted from the child" means removed from the *active* top-level set, not a hard `rm` — the move to `submitted/` preserves recovery and keeps the import-shamt `submitted/ → already-merged/` "landed upstream" auto-move working.

The moved copies are the child's "I submitted these and am waiting for master's decision" markers. When master eventually triages and either promotes or rejects each proposal, the next `/sync-import-shamt` cycle will:

- **Promoted:** master's archive carries `archive/{slug}.md`; `/sync-import-shamt` moves `.shamt-core/proposals/submitted/{slug}.md` to `.shamt-core/proposals/already-merged/{slug}.md` automatically (see `import-shamt.sh`).
- **Rejected / deferred:** no master-side archive exists. The submitted copy stays in `.shamt-core/proposals/submitted/` until the user cleans it up by hand. Master communicates the rejection out-of-band (chat, the rejected proposal note, etc.).

### Step 5 — Exit

State the exit, listing each proposal's per-slug outcome (written / unchanged / skipped):

```text
Submitted {N} proposal(s) for upstream review ({W} written, {U} unchanged, {S} skipped).
  {slug-1}:  written    {master}/proposals/incoming/{project_name}-{slug-1}.md   →  .shamt-core/proposals/submitted/{slug-1}.md
  {slug-2}:  unchanged  {master}/proposals/incoming/{project_name}-{slug-2}.md   →  .shamt-core/proposals/submitted/{slug-2}.md
  {slug-3}:  skipped    (master target differed; left active for retry)
  ...

The proposals were written directly into the local master at the paths above.
Review / commit / push them on master, then run /sync-triage-proposals on master
to promote / reject / defer.
```

No next-phase command on the child side — the next action is master-side.

## Exit criteria

- Each **written** or **unchanged** proposal now lives at `.shamt-core/proposals/submitted/{slug}.md` (unnumbered name), and no longer at its original top-level location. A **skipped** proposal stays active at its top-level location for retry.
- Each written/unchanged proposal has been direct-written to (or confirmed identical at) `{master}/proposals/incoming/{project_name}-{slug}.md`, with the `**Number:**` header stripped, behind the overwrite guard — no silent overwrite of a differing master target.
- The top-level active proposal set contains only the proposals the user chose to skip (empty when none were skipped).

## Notes

- **Batch, slugless.** One run ships every active proposal. There is no per-slug invocation and no validation gate — the child is an idea-capture surface and master triages whatever arrives (f0 draft, validated, or in-progress Draft).
- **Numeric-ID stripping.** Any proposal carrying a leading `{NN}-` filename prefix and/or a `**Number:**` header is stripped of that number before going upstream — both in the emitted content and in the `submitted/{slug}.md` name — so no stale number travels with it and master assigns its own at triage.
- **Direct local-FS write is the design.** This command writes each proposal straight into the user's *local* master checkout's `proposals/incoming/` (resolved from `master_url` in Step 1.5) — a plain filesystem write, the symmetric mirror of `import-shamt.sh`'s local-path read on the import side. This is **not** the upstream tooling v2 omits: pushing to a *remote* master, opening PRs, and using GitHub auth are out of scope (per `CLAUDE.md` §"What's deliberately out of scope") and remain so — this command does none of them. Writing a file into a local directory the user already has checked out, which the user still reviews / commits / pushes by hand, is categorically different from remote push automation. Because the design assumes a local master, a child whose `master_url` is a git URL halts at the Step 1.5 guard (set a local `master_url` or copy upstream by hand) rather than emitting copy-paste blocks — there is no copy-paste fallback.
- **`project_name` namespacing** prevents collision when two child projects both author a proposal with the same slug. Master's incoming folder de-duplicates via the `{project}-{slug}.md` prefix.
- **Re-submission.** If a submission was rejected and the user wants to revise, move `.shamt-core/proposals/submitted/{slug}.md` back to `.shamt-core/proposals/{slug}.md` by hand, edit, then re-run `/sync-proposals`.
- **Fresh-agent runnable.** `.shamt-core/shamt-config.json` + the `.shamt-core/proposals/*.md` set are sufficient. No conversation history required.

<!-- Managed by Shamt — do not edit. Regenerate from shamt-core/host/templates/claude/commands/sync-proposals.md. -->
