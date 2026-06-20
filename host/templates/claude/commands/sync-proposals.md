---
description: Child-side. Batch-prepare every active child-local proposal for upstream submission to master. Iterates all top-level .shamt-core/proposals/*.md regardless of status (f0 draft / validated / in-progress Draft), strips any numeric ID, prints one copy-paste block per proposal with its master-side target path (proposals/incoming/{project}-{slug}.md), then moves each local copy to proposals/submitted/{slug}.md.
---

# /sync-proposals

**Purpose:** Run the child-side batch submit step of the v2 master/child sync (Part 4). Iterate **every active** top-level `.shamt-core/proposals/*.md` proposal — regardless of status (an `f0` draft, a validated proposal, or an in-progress plain-`Draft`) — and for each one display the content with the master-side target path so the user can copy it into master's `proposals/incoming/`, then move the local copy to `proposals/submitted/{slug}.md` so the child tracks "submitted, awaiting decision" state and does not re-ship the same idea next run.

This is a **batch** command (slugless): one run clears the whole active set. It does **not** classify or gate on status — there is no validation-footer requirement. The child is primarily an *idea-capture* surface, so the common payload is an f0 draft (master does the f1 fleshing + validation), but a validated or in-progress proposal is shipped just the same; master triages whatever arrives.

The submission itself is **manual copy-paste**. This command does not push to master, does not open PRs, does not file issues. It produces the artifacts the user pastes upstream.

**Recommended model:** Cheap (Haiku). The command lists files, reads them, prints to chat, and moves them. No design judgment. See [`reference/model_selection.md`](../../../../reference/model_selection.md).

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

### Step 2 — Enumerate the active proposal set

1. List the **top-level** files matching `.shamt-core/proposals/*.md`.
2. **Exclude** `_template.md` and anything under the `submitted/`, `archive/`, `already-merged/`, `rejected/`, and `deferred/` subfolders (these are not active — `*.md` is a top-level glob, so subfolders are already excluded; the explicit list documents intent).
3. For each remaining file, compute its **submission slug**: take the filename without `.md`, and strip any leading `{NN}-` numeric run (a `^[0-9]+-` prefix). The result is the unnumbered slug. Child-side proposals are unnumbered by convention, but a proposal that originated on master or was hand-numbered must shed its number before going upstream so master assigns its own at triage.
4. If the set is empty, report "No active proposals to submit." and exit cleanly.

### Step 3 — Per-proposal: read, strip number, compute target path, output

Process each proposal in the active set, in `ls`-sorted order. For each:

1. Read the proposal file top-to-bottom.
2. Confirm the proposal's header carries `Proposed by:` and `Project context:` fields with non-empty values. Child-submitted proposals fill these in so master's `/sync-triage-proposals` can attribute the change. If either is empty, surface to the user via `AskUserQuestion` what value to fill in, then update the header in place before submission.
3. **Strip the numeric ID from the emitted content:** remove the `**Number:** {NN}` header line entirely (master assigns its own number at triage). Do not alter any other header.
4. Compute the master target path using the stripped slug:

   ```
   proposals/incoming/{project_name}-{slug}.md
   ```

5. State the resolved path in chat in one line, then print the copy-paste block, in this exact shape:

   ````markdown
   Master target: proposals/incoming/{project_name}-{slug}.md

   # Copy the block below into the master repo at: proposals/incoming/{project_name}-{slug}.md

   ```markdown
   {Full contents of the proposal with the **Number:** header removed, including any validation footer if present.}
   ```
   ````

   No commentary inside the fenced block. The user copies each fenced content into the corresponding master file.

### Step 4 — Move each local copy to submitted/

After printing all copy-paste blocks, move each submitted proposal out of the active set:

1. Ensure `.shamt-core/proposals/submitted/` exists. Create it if not.
2. For each proposal, move `.shamt-core/proposals/{original-name}.md` → `.shamt-core/proposals/submitted/{slug}.md` — using the **unnumbered** `{slug}.md` name (normalize the name on the way in, consistent with the strip-the-number rule) (use `git mv` when tracked, `mv` otherwise).
3. "Deleted from the child" means removed from the *active* top-level set, not a hard `rm` — the move to `submitted/` preserves recovery and keeps the import-shamt `submitted/ → already-merged/` "landed upstream" auto-move working.

The moved copies are the child's "I submitted these and am waiting for master's decision" markers. When master eventually triages and either promotes or rejects each proposal, the next `/sync-import-shamt` cycle will:

- **Promoted:** master's archive carries `archive/{slug}.md`; `/sync-import-shamt` moves `.shamt-core/proposals/submitted/{slug}.md` to `.shamt-core/proposals/already-merged/{slug}.md` automatically (see `import-shamt.sh`).
- **Rejected / deferred:** no master-side archive exists. The submitted copy stays in `.shamt-core/proposals/submitted/` until the user cleans it up by hand. Master communicates the rejection out-of-band (chat, the rejected proposal note, etc.).

### Step 5 — Exit

State the exit, naming each submitted proposal:

```text
Submitted {N} proposal(s) for upstream review.
  {slug-1}:  .shamt-core/proposals/submitted/{slug-1}.md  →  proposals/incoming/{project_name}-{slug-1}.md
  {slug-2}:  ...

Paste each copy-paste block above into the master repo at its stated target path,
then run /sync-triage-proposals on master to promote / reject / defer.
```

No next-phase command on the child side — the next action is manual + master-side.

## Exit criteria

- Each active proposal now lives at `.shamt-core/proposals/submitted/{slug}.md` (unnumbered name), and no longer at its original top-level location.
- One fenced copy-paste block per proposal has been printed to chat, each with its master-side target path and with the `**Number:**` header stripped.
- The top-level active proposal set is now empty (every active proposal was processed).

## Notes

- **Batch, slugless.** One run ships every active proposal. There is no per-slug invocation and no validation gate — the child is an idea-capture surface and master triages whatever arrives (f0 draft, validated, or in-progress Draft).
- **Numeric-ID stripping.** Any proposal carrying a leading `{NN}-` filename prefix and/or a `**Number:**` header is stripped of that number before going upstream — both in the emitted content and in the `submitted/{slug}.md` name — so no stale number travels with it and master assigns its own at triage.
- **Manual copy is the design.** The user copies each file across repos. No automation that pushes to master — that would re-introduce upstream tooling (PR creation, GitHub auth) that v2 explicitly omitted from the master/child surface.
- **`project_name` namespacing** prevents collision when two child projects both author a proposal with the same slug. Master's incoming folder de-duplicates via the `{project}-{slug}.md` prefix.
- **Re-submission.** If a submission was rejected and the user wants to revise, move `.shamt-core/proposals/submitted/{slug}.md` back to `.shamt-core/proposals/{slug}.md` by hand, edit, then re-run `/sync-proposals`.
- **Fresh-agent runnable.** `.shamt-core/shamt-config.json` + the `.shamt-core/proposals/*.md` set are sufficient. No conversation history required.

<!-- Managed by Shamt — do not edit. Regenerate from shamt-core/host/templates/claude/commands/sync-proposals.md. -->
