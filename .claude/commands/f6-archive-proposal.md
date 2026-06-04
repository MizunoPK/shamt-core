---
description: Phase 7 of the framework-update flow — move proposals/{slug}.md (and {slug}_PLAN.md if it exists) to proposals/archive/, preserving the validation footer
---

# /f6-archive-proposal

**Purpose:** Run Phase 7 of the framework-update flow. Move the implemented proposal (and any companion `{slug}_PLAN.md` or phase files) from `proposals/` to `proposals/archive/`, preserving the validation footer intact.

**Recommended model:** Cheap (Haiku). Archiving is mechanical: a file move and a status update. See [`reference/model_selection.md`](../../../../reference/model_selection.md).

---

## Usage

```
/f6-archive-proposal {slug}
```

## Arguments

- `{slug}` (required) — proposal slug. Resolves to `proposals/{slug}.md` (the implemented proposal) and `proposals/archive/{slug}.md` (the destination).

## Prerequisites

- `proposals/{slug}.md` exists and carries a validation footer (Phase 2 complete).
- The proposal has been implemented: the working tree contains the canonical edits the proposal described, and `/f4-regen-framework` has propagated them to `.claude/` (or the proposal explicitly did not require regen).
- **Recommended (not enforced):** `/f5-audit-framework` has been run and exited cleanly. The archive command does not block on the audit — the user may legitimately archive after a known-clean audit run earlier in the session, or accept lingering findings that are out of scope for the current proposal.
- `proposals/archive/{slug}.md` does **not** already exist. If it does, halt and report — this slug was already archived. A re-archival would either overwrite the prior record or shadow it depending on filesystem semantics; neither is safe.

## Step-by-step

### Step 1 — Read and confirm the proposal

1. Read `proposals/{slug}.md` top-to-bottom. Confirm the validation footer is present (`Validated YYYY-MM-DD — N rounds[, 1 adversarial sub-agent confirmed]`).
2. Check for companions:
   - `proposals/{slug}_PLAN.md` — Phase 3 ran. If present, must also carry a validation footer.
   - `proposals/{slug}_PLAN_phase_{N}.md` — phase-decomposed plan. Each phase file must also carry a validation footer.
3. Update the proposal's header `Status:` field from `Draft` (or whatever the current value is) to `Implemented`.

### Step 2 — Move to archive

1. Ensure `proposals/archive/` exists. If not, create it.
2. Move `proposals/{slug}.md` → `proposals/archive/{slug}.md` (use `git mv` when the proposal is tracked; plain `mv` when untracked).
3. Move any `{slug}_PLAN.md` / `{slug}_PLAN_phase_*.md` companions to `proposals/archive/` alongside the proposal.
4. Confirm the validation footer is intact in each archived file — it must not be stripped by the move.

### Step 3 — Commit suggestion

The archive is a logical commit point. Suggest a `git status` / `git diff` review followed by a commit, e.g.:

```text
git add proposals/archive/{slug}.md  # plus the canonical-source edits + .claude/ regen output
git commit -m "framework: implement {slug}"
```

Do not commit on behalf of the user — the canonical edits, the regen output, and the archive should ideally land together so a single revert undoes the whole change, and the user's commit conventions / signing / hook setup take over.

### Step 4 — Exit

State the exit clearly:

```text
Proposal {slug} archived to proposals/archive/{slug}.md.
{If companions moved: list them.}
Framework-update flow complete.
```

No next-phase suggestion. The framework-update flow ends at Phase 7.

## Exit criteria

- `proposals/{slug}.md` (and companions) moved to `proposals/archive/` with validation footers intact.
- The user has been prompted (but not forced) to commit the change.

## Notes

- **Validation footer preservation** — the move must not strip the footer. `git mv` and plain `mv` preserve content; the risk is only if the proposal is opened and re-saved by tooling mid-move. Read the destination file after the move to confirm.
- **No re-archive.** The command halts if `proposals/archive/{slug}.md` exists. Re-archival is a hard ambiguity; the user must rename the prior archive or pick a new slug for the follow-up proposal.
- **Reject and defer paths.** This command implements the archive path only. The `proposals/rejected/` and `proposals/deferred/` folders are documented as expected (see `proposals/_template.md` and §3.4) and used by the (future) `/sync-triage-proposals` command on the master side — `/f6-archive-proposal` itself does not handle rejection or deferral. To reject or defer a proposal, the user moves the file manually with a brief note explaining the disposition.
- **Fresh-agent runnable** — proposal + companion files + working-tree state are sufficient. No conversation history required.

---
Validated 2026-05-28 — 4 rounds, 1 adversarial sub-agent confirmed (Phase 8 implementation loop)

<!-- Managed by Shamt — do not edit. Regenerate from shamt-core/host/templates/claude/commands/f6-archive-proposal.md. -->
