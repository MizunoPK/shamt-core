---
description: Child-side. Prepare a validated, child-local proposal for upstream submission to master. Outputs copy-paste-ready content + target path on master (proposals/incoming/{project}-{slug}.md), then moves the local copy to proposals/submitted/{slug}.md.
---

# /sync-submit-proposal

**Purpose:** Run the child-side submit step of the v2 master/child sync (Part 4). Resolve a slug to `proposals/{slug}.md`, confirm the proposal is validated (Phase 2 footer present), display the content with the master-side target path so the user can copy it into master's `proposals/incoming/`, then move the local copy to `proposals/submitted/{slug}.md` so the child tracks "submitted, awaiting decision" state.

The submission itself is **manual copy-paste**. This command does not push to master, does not open PRs, does not file issues. It produces the artifact the user pastes upstream.

**Recommended model:** Cheap (Haiku). The command reads a file, checks a footer, prints to chat, and moves a file. No design judgment. See [`reference/model_selection.md`](../../../../reference/model_selection.md).

---

## Usage

```
/sync-submit-proposal {slug}
```

## Arguments

- `{slug}` (required) — proposal slug. Resolves to `.shamt-core/proposals/{slug}.md` (child-local).

## Prerequisites

- This command runs **on the child side**. Master-side projects do not submit upstream — they author proposals locally and run the framework-update flow directly. Detect master vs. child by checking for `proposals/incoming/` at the cwd: the incoming folder is master's, and child projects never have it. If `proposals/incoming/` exists, halt and direct the user to `/f1-propose-update` + `/validate-artifact` + the rest of the Part 3 framework-update flow (Phase 8) instead.
- `.shamt-core/shamt-config.json` exists at the project root and declares `project_name`. If missing, halt and direct the user to set it: `project_name` namespaces upstream submissions per §4.3 / §4.4.
- `.shamt-core/proposals/{slug}.md` exists, is non-empty, and carries a Phase 2 validation footer (`Validated YYYY-MM-DD — N rounds[, 1 adversarial sub-agent confirmed]`). If the footer is missing, halt and direct the user to `/validate-artifact .shamt-core/proposals/{slug}.md` first — master will not promote an un-validated proposal.
- `.shamt-core/proposals/submitted/{slug}.md` does **not** already exist. If it does, halt: this slug has already been submitted. Either wait for master's decision, or rename the slug and re-author via `/f1-propose-update`.

## Step-by-step

### Step 1 — Read .shamt-core/shamt-config.json

1. Read `.shamt-core/shamt-config.json` at the project root.
2. Extract `project_name`. If empty or missing, halt with: *".shamt-core/shamt-config.json must declare project_name — set it and re-run."*
3. Validate that `project_name` matches `^[A-Za-z0-9._-]+$`. Halt if not — the value will appear in the master-side filename `proposals/incoming/{project_name}-{slug}.md` and must be filesystem-safe.

### Step 2 — Read and confirm the proposal

1. Read `.shamt-core/proposals/{slug}.md` top-to-bottom.
2. Confirm the validation footer is present in the last ~5 lines (`Validated YYYY-MM-DD — …`). Halt if not.
3. Confirm the proposal's header carries `Proposed by:` and `Project context:` fields with non-empty values. Per §4.13, child-submitted proposals fill these in so master's `/sync-triage-proposals` can attribute the change. If either is empty, surface to the user via `AskUserQuestion` what value to fill in, then update the header in place before submission.

### Step 3 — Compute target path

The target path on master is:

```
proposals/incoming/{project_name}-{slug}.md
```

State the resolved path in chat in one line before any file move:

```text
Master target: proposals/incoming/{project_name}-{slug}.md
```

### Step 4 — Output copy-paste-ready content

Print to chat, in this exact shape, so the user can copy verbatim:

````markdown
# Copy the block below into the master repo at: proposals/incoming/{project_name}-{slug}.md

```markdown
{Full contents of .shamt-core/proposals/{slug}.md, including the validation footer.}
```
````

No commentary inside the fenced block. The user copies the fenced content into the master file, then runs `/sync-triage-proposals` on the master side.

### Step 5 — Move the local copy

1. Ensure `.shamt-core/proposals/submitted/` exists. Create it if not.
2. Move `.shamt-core/proposals/{slug}.md` → `.shamt-core/proposals/submitted/{slug}.md` (use `git mv` when tracked, `mv` otherwise).
3. Confirm the validation footer survived the move.

The moved copy is the child's "I submitted this and am waiting for master's decision" marker. When master eventually triages and either promotes or rejects the proposal, the next `/sync-import-shamt` cycle will:

- **Promoted:** master's archive carries `archive/{slug}.md`; `/sync-import-shamt` moves `.shamt-core/proposals/submitted/{slug}.md` to `.shamt-core/proposals/already-merged/{slug}.md` automatically (see `import-shamt.sh`).
- **Rejected / deferred:** no master-side archive exists. The submitted copy stays in `.shamt-core/proposals/submitted/` until the user cleans it up by hand. Master communicates the rejection out-of-band (chat, the rejected proposal note, etc.).

### Step 6 — Exit

State the exit:

```text
Proposal {slug} prepared for submission.
  Local copy moved to:  .shamt-core/proposals/submitted/{slug}.md
  Master target:        proposals/incoming/{project_name}-{slug}.md

Paste the copy-paste block above into the master repo at the target path,
then run /sync-triage-proposals on master to promote / reject / defer.
```

No next-phase command on the child side — the next action is manual + master-side.

## Exit criteria

- `.shamt-core/proposals/submitted/{slug}.md` exists, carries the validation footer intact.
- The fenced copy-paste block has been printed to chat with the master-side target path.
- `.shamt-core/proposals/{slug}.md` no longer exists at the original location (it has been moved, not copied).

## Notes

- **Manual copy is the design.** Per §4.3 the user copies the file across repos. No automation that pushes to master — that would re-introduce upstream tooling (PR creation, GitHub auth) that v2 explicitly omitted from the master/child surface.
- **`project_name` namespacing** prevents collision when two child projects both author a proposal with the same slug. Master's incoming folder de-duplicates via the `{project}-{slug}.md` prefix.
- **Pre-validation requirement.** Master will not promote an un-validated proposal. Catching that here (locally) saves a triage round-trip.
- **Re-submission.** If a submission was rejected and the user wants to revise, move `.shamt-core/proposals/submitted/{slug}.md` back to `.shamt-core/proposals/{slug}.md` by hand, edit, re-validate with `/validate-artifact`, then re-run `/sync-submit-proposal {slug}`.
- **Fresh-agent runnable.** `.shamt-core/shamt-config.json` + `.shamt-core/proposals/{slug}.md` are sufficient. No conversation history required.

---
Validated 2026-05-28 — 8 rounds (4 primary + 4 adversarial), final adversarial sub-agent confirmed (Phase 9 implementation re-validation). No changes to this file in this round.

<!-- Managed by Shamt — do not edit. Regenerate from shamt-core/host/templates/claude/commands/sync-submit-proposal.md. -->
