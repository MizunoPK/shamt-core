# Implementation Plan: 42-sync-proposals-batch-upstream

**Proposal:** proposals/42-sync-proposals-batch-upstream.md
**Created:** 2026-06-19
**File operations:** 18 (CREATE: 2, EDIT: 14, DELETE: 2)

> Rows #1/#2 and #3/#4 are MOVE pairs (rename of the `/sync-submit-proposal` command + its skill to `/sync-proposals`), executed as CREATE-new + DELETE-old per the proposal's framing. The new command body is a full rewrite (slugless batch shape), so this is not a plain `git mv` of unchanged content — the plan writes the new file from a complete content block and deletes the old one. All edits land in **canonical sources only** (`host/templates/`, `reference/`, `README.md`, `*.sh`); generated `.claude/` files are NEVER touched — `/f4-regen-framework` propagates the rename and deletes the stale generated `sync-submit-proposal` command/skill.

## Pre-execution checklist
- [ ] On a clean working tree (or working in a worktree dedicated to this proposal).
- [ ] `proposals/42-sync-proposals-batch-upstream.md` validation footer present (`Validated 2026-06-19 — 1 round, 1 adversarial sub-agent confirmed`).
- [ ] Branch created by `/f3-implement-update`: `proposal/42-sync-proposals-batch-upstream` from the base branch, immediately before the canonical edits. (Authoring/validation/planning happen on the base branch; the architect/builder path's executor creates this branch when it runs this pre-execution checklist at Phase 4.)

## Files manifest

| # | Path | Operation | Sibling / template (if any) |
|---|------|-----------|------------------------------|
| 1 | `host/templates/claude/commands/sync-proposals.md` | CREATE | rewrite of `host/templates/claude/commands/sync-submit-proposal.md` |
| 2 | `host/templates/claude/commands/sync-submit-proposal.md` | DELETE | paired with #1 (MOVE) |
| 3 | `host/templates/claude/skills/sync-proposals/SKILL.md` | CREATE | mirror of `host/templates/claude/skills/sync-submit-proposal/SKILL.md` (pointer-form Protocol) |
| 4 | `host/templates/claude/skills/sync-submit-proposal/SKILL.md` | DELETE | paired with #3 (MOVE) |
| 5 | `host/templates/claude/commands/f0-draft-proposal.md` | EDIT | — |
| 6 | `host/templates/claude/commands/f1-propose-update.md` | EDIT | — |
| 7 | `host/templates/claude/commands/f5-audit-framework.md` | EDIT | — |
| 8 | `host/templates/claude/commands/f-all.md` | EDIT | — |
| 9 | `host/templates/claude/commands/sync-import-shamt.md` | EDIT | — |
| 10 | `host/templates/claude/commands/sync-triage-proposals.md` | EDIT | — |
| 11 | `host/templates/claude/commands/trim-rules-file.md` | EDIT | — |
| 12 | `host/templates/claude/skills/f5-audit-framework/SKILL.md` | EDIT | — |
| 13 | `host/templates/claude/skills/f-all/SKILL.md` | EDIT | — |
| 14 | `host/templates/claude/skills/sync-import-shamt/SKILL.md` | EDIT | — |
| 15 | `import-shamt.sh` | EDIT | — |
| 16 | `init-shamt.sh` | EDIT | — |
| 17 | `README.md` | EDIT | — |
| 18 | `reference/audit_dimensions.md` | EDIT | — |

## Step-by-step

### Step 1 — CREATE the new `/sync-proposals` batch command body

**Operation:** CREATE
**File:** `host/templates/claude/commands/sync-proposals.md`
**Content (write the file with exactly this):**

````markdown
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
````

**Verification:**
- `test -f host/templates/claude/commands/sync-proposals.md` succeeds.
- `grep -F '# /sync-proposals' host/templates/claude/commands/sync-proposals.md` returns one match.
- `grep -c 'sync-submit-proposal' host/templates/claude/commands/sync-proposals.md` returns 0 (no stale name leaked into the new body).

### Step 2 — DELETE the old `/sync-submit-proposal` command body

**Operation:** DELETE
**File:** `host/templates/claude/commands/sync-submit-proposal.md`
**Justification:** Replaced by `sync-proposals.md` (Step 1) — paired MOVE. The generated `.claude/` mirror is removed by `/f4-regen-framework`, not here.
**Action:** `git rm host/templates/claude/commands/sync-submit-proposal.md` (or `rm` if untracked).
**Verification:**
- `test ! -f host/templates/claude/commands/sync-submit-proposal.md` succeeds (file gone).

### Step 3 — CREATE the new `/sync-proposals` skill wrapper

**Operation:** CREATE
**File:** `host/templates/claude/skills/sync-proposals/SKILL.md`
**Content (write the file with exactly this; `## Protocol` stays pointer-form per D2):**

````markdown
---
name: sync-proposals
description: >
  Child-side step of the v2 master/child sync. Batch-prepare every active
  child-local proposal under .shamt-core/proposals/ for upstream submission to
  master. Iterates all top-level *.md proposals regardless of status (f0 draft,
  validated, or in-progress Draft — no validation-footer gate), strips any
  numeric ID, reads project_name from .shamt-core/shamt-config.json, prints one
  copy-paste block per proposal with its master-side target path
  (proposals/incoming/{project}-{slug}.md) for manual copy-paste, and moves each
  local copy to .shamt-core/proposals/submitted/{slug}.md to mark "awaiting
  decision". Does NOT push to master, open PRs, or file issues — the submission
  is manual copy. Invoke when the user wants to send proposals upstream, ship
  proposals to master, submit framework changes, or push proposals up.
triggers:
  - "sync proposals"
  - "submit the proposals"
  - "send the proposals upstream"
  - "ship these proposals to master"
  - "push these framework changes up"
  - "submit framework updates"
---

## Overview

Mirrors the `/sync-proposals` slash command. Same canonical body, two host wirings.

## Protocol

Follow the canonical `/sync-proposals` command body verbatim — see [`commands/sync-proposals.md`](../../commands/sync-proposals.md).

## Recommended model

Cheap (Haiku) — list files, read them, print, move. Mechanical. See [`reference/model_selection.md`](../../../../../reference/model_selection.md).

## Exit criteria

- Each active proposal now lives at `.shamt-core/proposals/submitted/{slug}.md` with its numeric ID stripped, and no longer at its original top-level location.
- One fenced copy-paste block per proposal has been printed to chat with the master-side target path stated above it.
- The top-level active proposal set is now empty.

## Re-submission

If master rejected a prior submission and the user wants to revise: manually move `.shamt-core/proposals/submitted/{slug}.md` back to `.shamt-core/proposals/{slug}.md`, edit, then re-run `/sync-proposals`.

## Already-merged follow-up

After master triages each submitted proposal and (if promoted) implements / archives it, the next `/sync-import-shamt` run on the child auto-moves `.shamt-core/proposals/submitted/{slug}.md` → `.shamt-core/proposals/already-merged/{slug}.md` when it detects the matching `proposals/archive/{slug}.md` on master. No manual cleanup needed for the promoted-and-merged path.

<!-- Managed by Shamt — do not edit. Regenerate from shamt-core/host/templates/claude/skills/sync-proposals/SKILL.md. -->
````

**Verification:**
- `test -f host/templates/claude/skills/sync-proposals/SKILL.md` succeeds.
- `grep -F 'name: sync-proposals' host/templates/claude/skills/sync-proposals/SKILL.md` returns one match.
- `grep -F 'Follow the canonical' host/templates/claude/skills/sync-proposals/SKILL.md` returns one match (the pointer-form Protocol line "Follow the canonical /sync-proposals command body verbatim — see commands/sync-proposals.md", not a paraphrase of the command steps).
- `grep -c 'sync-submit-proposal' host/templates/claude/skills/sync-proposals/SKILL.md` returns 0.

### Step 4 — DELETE the old `/sync-submit-proposal` skill

**Operation:** DELETE
**File:** `host/templates/claude/skills/sync-submit-proposal/SKILL.md`
**Justification:** Replaced by Step 3 — paired MOVE. The generated `.claude/` mirror is removed by `/f4-regen-framework`.
**Action:** `git rm host/templates/claude/skills/sync-submit-proposal/SKILL.md` (or `rm`), then remove the now-empty `host/templates/claude/skills/sync-submit-proposal/` directory if it remains.
**Verification:**
- `test ! -f host/templates/claude/skills/sync-submit-proposal/SKILL.md` succeeds.
- `test ! -d host/templates/claude/skills/sync-submit-proposal` succeeds (empty dir removed).

### Step 5 — EDIT f0-draft-proposal.md (exit text + Notes)

**Operation:** EDIT
**File:** `host/templates/claude/commands/f0-draft-proposal.md`

Two replacements in this file.

**5a — Exit text (Step 3):**
**Locate:**
```
Next: /f1-propose-update {final-slug} to flesh it out{, then /sync-submit-proposal {final-slug} to send it upstream — child only}.
```
**Replace:**
```
Next: /f1-propose-update {final-slug} to flesh it out{, then /sync-proposals to send it upstream (batch, slugless) — child only}.
```

**5b — Notes line:**
**Locate:**
```
so a child user may run `/f0-draft-proposal` (then `/f1-propose-update`, then `/sync-submit-proposal`) directly.
```
**Replace:**
```
so a child user may run `/f0-draft-proposal` (then `/f1-propose-update`, then `/sync-proposals`) directly.
```

**Verification:**
- `grep -c 'sync-submit-proposal' host/templates/claude/commands/f0-draft-proposal.md` returns 0.
- `grep -c 'sync-proposals' host/templates/claude/commands/f0-draft-proposal.md` returns 2.

### Step 6 — EDIT f1-propose-update.md (Notes line)

**Operation:** EDIT
**File:** `host/templates/claude/commands/f1-propose-update.md`
**Locate:**
```
- This command is reused by child projects when they author proposals locally before `/sync-submit-proposal` ships them up. The body is identical on both sides.
```
**Replace:**
```
- This command is reused by child projects when they author proposals locally before `/sync-proposals` ships them up (batch, slugless). The body is identical on both sides.
```
**Verification:**
- `grep -c 'sync-submit-proposal' host/templates/claude/commands/f1-propose-update.md` returns 0.
- `grep -F '/sync-proposals' host/templates/claude/commands/f1-propose-update.md` returns one match (the "ships them up" Notes line).

### Step 7 — EDIT f5-audit-framework.md (Purpose + Step-0 redirect + Notes)

**Operation:** EDIT
**File:** `host/templates/claude/commands/f5-audit-framework.md`

Three replacements in this file.

**7a — Purpose line redirect chain:**
**Locate:**
```
redirects** to `/f0-draft-proposal` → `/f1-propose-update` → `/sync-submit-proposal` (see Step 0) — the audit's two clearing actions
```
**Replace:**
```
redirects** to `/f0-draft-proposal` → `/f1-propose-update` → `/sync-proposals` (see Step 0) — the audit's two clearing actions
```

**7b — Step-0 redirect list item:**
**Locate:**
```
    3. /sync-submit-proposal {slug}         — send it upstream to master
```
**Replace:**
```
    3. /sync-proposals                      — send them upstream to master (batch)
```

**7c — Notes line redirect chain:**
**Locate:**
```
redirects to `/f0-draft-proposal` → `/f1-propose-update` → `/sync-submit-proposal` — a child's `.shamt-core/` canonical copies
```
**Replace:**
```
redirects to `/f0-draft-proposal` → `/f1-propose-update` → `/sync-proposals` — a child's `.shamt-core/` canonical copies
```

**Verification:**
- `grep -c 'sync-submit-proposal' host/templates/claude/commands/f5-audit-framework.md` returns 0.
- `grep -c 'sync-proposals' host/templates/claude/commands/f5-audit-framework.md` returns 3.

### Step 8 — EDIT f-all.md (child-redirect block)

**Operation:** EDIT
**File:** `host/templates/claude/commands/f-all.md`
**Locate:**
```
    /sync-submit-proposal {slug}     — send it upstream to master
```
**Replace:**
```
    /sync-proposals                  — send them upstream to master (batch)
```
**Verification:**
- `grep -c 'sync-submit-proposal' host/templates/claude/commands/f-all.md` returns 0.
- `grep -F '/sync-proposals' host/templates/claude/commands/f-all.md` returns one match.

### Step 9 — EDIT sync-import-shamt.md ("No reverse direction" note)

**Operation:** EDIT
**File:** `host/templates/claude/commands/sync-import-shamt.md`
**Locate:**
```
- **No reverse direction.** This command only pulls. The reverse direction is `/sync-submit-proposal {slug}` (per-proposal, manual copy).
```
**Replace:**
```
- **No reverse direction.** This command only pulls. The reverse direction is `/sync-proposals` (batch, manual copy — ships every active child-local proposal upstream at once).
```
**Verification:**
- `grep -c 'sync-submit-proposal' host/templates/claude/commands/sync-import-shamt.md` returns 0.
- `grep -F '/sync-proposals' host/templates/claude/commands/sync-import-shamt.md` returns one match (the "batch, manual copy" reverse-direction note).

### Step 10 — EDIT sync-triage-proposals.md (halt message + naming cross-ref + rejection note)

**Operation:** EDIT
**File:** `host/templates/claude/commands/sync-triage-proposals.md`

Three replacements in this file.

**10a — Child-detection halt message:**
**Locate:**
```
*"proposals/incoming/ does not exist — this looks like a child project. Use `/sync-submit-proposal {slug}` to send proposals upstream instead."*
```
**Replace:**
```
*"proposals/incoming/ does not exist — this looks like a child project. Use `/sync-proposals` to send proposals upstream instead."*
```

**10b — Naming-rule cross-ref:**
**Locate:**
```
the filename's prefix matches the project name the child declared in the header (per `/sync-submit-proposal`'s `{project_name}-{slug}.md` naming rule).
```
**Replace:**
```
the filename's prefix matches the project name the child declared in the header (per `/sync-proposals`'s `{project_name}-{slug}.md` naming rule).
```

**10c — Rejection-cleanup note:**
**Locate:**
```
v2 does not include a notification mechanism — `/sync-submit-proposal` warned the user that rejections require manual cleanup of `proposals/submitted/{slug}.md` on the child side.
```
**Replace:**
```
v2 does not include a notification mechanism — `/sync-proposals` notes that rejections require manual cleanup of `proposals/submitted/{slug}.md` on the child side.
```

**Verification:**
- `grep -c 'sync-submit-proposal' host/templates/claude/commands/sync-triage-proposals.md` returns 0.
- `grep -c 'sync-proposals' host/templates/claude/commands/sync-triage-proposals.md` returns 3.

### Step 11 — EDIT trim-rules-file.md (child-redirect chain)

**Operation:** EDIT
**File:** `host/templates/claude/commands/trim-rules-file.md`
**Locate:**
```
contribute via `/f0-draft-proposal` → `/f1-propose-update` → `/sync-submit-proposal` instead.
```
**Replace:**
```
contribute via `/f0-draft-proposal` → `/f1-propose-update` → `/sync-proposals` instead.
```
**Verification:**
- `grep -c 'sync-submit-proposal' host/templates/claude/commands/trim-rules-file.md` returns 0.
- `grep -F '/sync-proposals' host/templates/claude/commands/trim-rules-file.md` returns one match (the "instead." child-redirect chain).

### Step 12 — EDIT f5-audit-framework SKILL.md (frontmatter description redirect chain)

**Operation:** EDIT
**File:** `host/templates/claude/skills/f5-audit-framework/SKILL.md`
**Locate:**
```
  /sync-submit-proposal. Findings are chat-only — no audit log artifacts.
```
**Replace:**
```
  /sync-proposals. Findings are chat-only — no audit log artifacts.
```
**Verification:**
- `grep -c 'sync-submit-proposal' host/templates/claude/skills/f5-audit-framework/SKILL.md` returns 0.
- `grep -F '/sync-proposals. Findings are chat-only' host/templates/claude/skills/f5-audit-framework/SKILL.md` returns one match.

### Step 13 — EDIT f-all SKILL.md (frontmatter/body description)

**Operation:** EDIT
**File:** `host/templates/claude/skills/f-all/SKILL.md`
**Locate:**
```
redirects to the per-phase commands (`/f1-propose-update {slug}` → `/sync-submit-proposal {slug}`). Mirrors `/f5-audit-framework`'s child-side behavior.
```
**Replace:**
```
redirects to the per-phase commands (`/f1-propose-update {slug}` → `/sync-proposals`). Mirrors `/f5-audit-framework`'s child-side behavior.
```
**Verification:**
- `grep -c 'sync-submit-proposal' host/templates/claude/skills/f-all/SKILL.md` returns 0.
- `grep -F '/sync-proposals' host/templates/claude/skills/f-all/SKILL.md` returns one match (the "). Mirrors" child-redirect line).

### Step 14 — EDIT sync-import-shamt SKILL.md (frontmatter/body reverse-direction mention)

**Operation:** EDIT
**File:** `host/templates/claude/skills/sync-import-shamt/SKILL.md`
**Locate:**
```
This skill only pulls. To send a proposal upstream, use `/sync-submit-proposal {slug}` — manual copy per the manual-copy sync design.
```
**Replace:**
```
This skill only pulls. To send proposals upstream, use `/sync-proposals` — batch, manual copy per the manual-copy sync design.
```
**Verification:**
- `grep -c 'sync-submit-proposal' host/templates/claude/skills/sync-import-shamt/SKILL.md` returns 0.
- `grep -F '/sync-proposals' host/templates/claude/skills/sync-import-shamt/SKILL.md` returns one match (the "— batch, manual copy" reverse-direction line).

### Step 15 — EDIT import-shamt.sh (header comment block)

**Operation:** EDIT
**File:** `import-shamt.sh`
**Locate:**
```
# <child>/.shamt-core/proposals/submitted/{slug}.md (submitted via
# /sync-submit-proposal, awaiting master's decision). If a master archive entry
```
**Replace:**
```
# <child>/.shamt-core/proposals/submitted/{slug}.md (submitted via
# /sync-proposals, awaiting master's decision). If a master archive entry
```
> The already-merged auto-move continues to scan `submitted/` (per Resolved Q1, the batch command moves each proposal to `submitted/`), so no logic change is needed — only the comment's command name updates.
**Verification:**
- `grep -c 'sync-submit-proposal' import-shamt.sh` returns 0.
- `grep -F '# /sync-proposals, awaiting master' import-shamt.sh` returns one match.
- `grep -F 'submitted/' import-shamt.sh` still returns at least one match (the already-merged scan still walks `submitted/`).

### Step 16 — EDIT init-shamt.sh (project_name prompt help text)

**Operation:** EDIT
**File:** `init-shamt.sh`
**Locate:**
```
  "Project name (used by /sync-submit-proposal to namespace upstream submissions)" \
```
**Replace:**
```
  "Project name (used by /sync-proposals to namespace upstream submissions)" \
```
**Verification:**
- `grep -c 'sync-submit-proposal' init-shamt.sh` returns 0.
- `grep -F 'used by /sync-proposals to namespace' init-shamt.sh` returns one match.

### Step 17 — EDIT README.md (command table, sync-flow table, config row, discrimination paragraph, f5 row)

**Operation:** EDIT
**File:** `README.md`

Five replacements in this file.

**17a — master-`proposals/` discrimination paragraph:**
**Locate:**
```
Master's presence is what `/sync-submit-proposal` and `/sync-triage-proposals` use to discriminate the two sides
```
**Replace:**
```
Master's presence is what `/sync-proposals` and `/sync-triage-proposals` use to discriminate the two sides
```

**17b — sync-flow table (Child → master) row:**
**Locate:**
```
| Child → master | **Proposals only.** Manual copy-paste via `/sync-submit-proposal`. | A single proposal file (`proposals/incoming/{project_name}-{slug}.md` on master). |
```
**Replace:**
```
| Child → master | **Proposals only.** Manual copy-paste via `/sync-proposals` (batch — ships every active child-local proposal at once). | One file per proposal (`proposals/incoming/{project_name}-{slug}.md` on master). |
```

**17c — f5 row redirect:**
**Locate:**
```
| `/f5-audit-framework` | Phase 6 — continuous dual-track D1–D12 sweep: auto-fix simple findings + capture intricate ones as f0 drafts (also standalone). **Master / self-host only** — in a child it halts and redirects to f0 → f1 → `/sync-submit-proposal` | shipped |
```
**Replace:**
```
| `/f5-audit-framework` | Phase 6 — continuous dual-track D1–D12 sweep: auto-fix simple findings + capture intricate ones as f0 drafts (also standalone). **Master / self-host only** — in a child it halts and redirects to f0 → f1 → `/sync-proposals` | shipped |
```

**17d — command table row:**
**Locate:**
```
| `/sync-submit-proposal {slug}` | Child | Prepare a validated proposal for upstream manual copy. Moves local copy to `.shamt-core/proposals/submitted/`. | shipped |
```
**Replace:**
```
| `/sync-proposals` | Child | Batch-prepare **every active** child-local proposal (f0 / validated / in-progress) for upstream manual copy; strips any numeric ID. Moves each local copy to `.shamt-core/proposals/submitted/`. | shipped |
```

**17e — `project_name` config row:**
**Locate:**
```
| `project_name` | string (`^[A-Za-z0-9._-]+$`) | Used by `/sync-submit-proposal` to namespace upstream submissions (`proposals/incoming/{project_name}-{slug}.md` on master) |
```
**Replace:**
```
| `project_name` | string (`^[A-Za-z0-9._-]+$`) | Used by `/sync-proposals` to namespace upstream submissions (`proposals/incoming/{project_name}-{slug}.md` on master) |
```

**Verification:**
- `grep -c 'sync-submit-proposal' README.md` returns 0.
- `grep -c 'sync-proposals' README.md` returns 5.

### Step 18 — EDIT reference/audit_dimensions.md (child-redirect chain)

**Operation:** EDIT
**File:** `reference/audit_dimensions.md`
**Locate:**
```
**halts immediately at Step 0 and redirects** the user to `/f0-draft-proposal` → `/f1-propose-update` → `/sync-submit-proposal` — it does not sweep, auto-fix, capture, or run the sub-agent.
```
**Replace:**
```
**halts immediately at Step 0 and redirects** the user to `/f0-draft-proposal` → `/f1-propose-update` → `/sync-proposals` — it does not sweep, auto-fix, capture, or run the sub-agent.
```
**Verification:**
- `grep -c 'sync-submit-proposal' reference/audit_dimensions.md` returns 0.
- `grep -F '/sync-proposals' reference/audit_dimensions.md` returns one match (the "— it does not sweep" child-redirect chain).

## Verification (post-execution, whole plan)

<!-- Whole-plan / cross-phase invariants — run by the architect at /f3-implement-update post-build (Step 3), never by the builder. -->

- [ ] Every row in the Proposed Changes table (1–18) has a corresponding step (1–18, one-to-one).
- [ ] **Zero live `sync-submit-proposal` references remain across canonical sources.** Run `grep -rn 'sync-submit-proposal' host/templates/ reference/ templates/ README.md import-shamt.sh init-shamt.sh CLAUDE.md | grep -v 'proposals/archive'` — must return **zero** matches (historical proposals under `proposals/archive/` are frozen and correctly left untouched).
- [ ] Both CREATE files exist: `host/templates/claude/commands/sync-proposals.md` and `host/templates/claude/skills/sync-proposals/SKILL.md`.
- [ ] Both DELETE targets are gone: `host/templates/claude/commands/sync-submit-proposal.md` and `host/templates/claude/skills/sync-submit-proposal/SKILL.md` (and the now-empty `skills/sync-submit-proposal/` directory).
- [ ] The new skill `## Protocol` is the **pointer form** (D2 rule, `reference/audit_dimensions.md`) — not a paraphrase of the command's numbered steps. `grep -F 'Follow the canonical' host/templates/claude/skills/sync-proposals/SKILL.md` returns one match (the line "Follow the canonical /sync-proposals command body verbatim — see commands/sync-proposals.md").
- [ ] No edits landed in generated `.claude/` paths — `git diff --name-only` shows no path under `.claude/`. (`/f4-regen-framework` propagates the rename and deletes the stale generated `sync-submit-proposal` command/skill in Phase 5.)
- [ ] The rules file was **not** touched: `git diff --name-only` does not list `templates/SHAMT_RULES.template.md` (it never named the command — confirmed by the proposal's Validation Considerations).
- [ ] `import-shamt.sh`'s already-merged auto-move still scans `submitted/` (no logic change — only the comment command name updated).
- [ ] Mermaid / link / reference targets in edited and created files still resolve — in particular the new `commands/sync-proposals.md` ↔ `skills/sync-proposals/SKILL.md` relative link and the `<!-- Managed by Shamt — Regenerate from … -->` footer paths in both CREATE files point at their own new canonical paths.

## Notes

- **MOVE framing.** Per the proposal note, rows #2+#1 and #4+#3 are MOVE pairs. The new command body is a full rewrite (slugless batch shape), so this plan executes the moves as CREATE-new + DELETE-old rather than `git mv` of unchanged content. The generated `.claude/` mirror is never edited directly here.
- **Ordering.** Steps 1–4 (the MOVE pairs) come first so the new canonical command/skill exist before the cross-references that point at them are updated; Steps 5–18 are independent of each other and may run in any order, but the listed order matches the Proposed Changes table.
- **Footer paths in CREATE files.** Both new files carry a `<!-- Managed by Shamt — do not edit. Regenerate from … -->` footer that must reference the **new** canonical path (`.../commands/sync-proposals.md`, `.../skills/sync-proposals/SKILL.md`), not the old `sync-submit-proposal` paths — already baked into the Step 1 / Step 3 content blocks.
- **No validation footer on the new command/skill content blocks.** The Step 1 / Step 3 content intentionally omits a `Validated …` footer line — those files are new canonical sources whose footer (if any) is the regeneration footer only; the proposal's own validation footer governs this change set, not the individual files.
- **Out of scope for this plan:** `/f4-regen-framework` (Phase 5) and the `--check` zero-drift confirmation, including deletion of the stale generated `.claude/` `sync-submit-proposal` command + skill. Not a plan step.

---
Validated 2026-06-19 — 1 round, 1 adversarial sub-agent confirmed
