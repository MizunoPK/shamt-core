---
description: Phase 7 of the framework-update flow — move proposals/{slug}.md (and {slug}_PLAN.md if it exists) to proposals/archive/, preserving the validation footer
---

# /f6-archive-proposal

**Purpose:** Run Phase 7 of the framework-update flow. Move the implemented proposal (and any companion `{slug}_PLAN.md` or phase files) from `proposals/` to `proposals/archive/`, preserving the validation footer intact.

**Recommended model:** Balanced (Sonnet). Archiving now performs an irreversible git-state mutation — it commits the change, squash-merges the `proposal/{NN}-{slug}` branch into the base branch, and deletes the branch — gated behind pre-merge guards that must be evaluated, not just a file move and a status update. See [`reference/model_selection.md`](../../../../reference/model_selection.md).

---

## Usage

```
/f6-archive-proposal {slug}
```

## Arguments

- `{slug}` (required) — proposal slug (bare descriptive slug or numbered stem `{NN}-{slug}`). Resolves the implemented proposal exact-then-glob — `proposals/{slug}.md`, then `proposals/*-{slug}.md` (master-side proposals carry a `{NN}-` prefix; matches at most one, halt on multiple) — and archives it to `proposals/archive/{resolved-filename}`, preserving the `{NN}-` prefix (or its absence for a grandfathered proposal).

## Prerequisites

- `proposals/{slug}.md` exists and carries a validation footer (Phase 2 complete).
- The proposal has been implemented: the working tree contains the canonical edits the proposal described (plus any in-flow audit auto-fixes / captured f0 stubs from a Phase 6 `/f5-audit-framework` run, which fold into this landing), and `/f4-regen-framework` has propagated them to `.claude/` (or the proposal explicitly did not require regen).
- **Recommended (not enforced):** `/f5-audit-framework` has been run and exited cleanly. The archive command does not block on the audit — the user may legitimately archive after a known-clean audit run earlier in the session, or accept lingering findings that are out of scope for the current proposal.
- `proposals/archive/{slug}.md` (or numbered `proposals/archive/*-{slug}.md`) does **not** already exist. If it does, halt and report — this slug was already archived. A re-archival would either overwrite the prior record or shadow it depending on filesystem semantics; neither is safe.

## Step-by-step

### Step 1 — Read and confirm the proposal

1. Resolve and read the proposal (exact-then-glob per Arguments). Confirm the validation footer is present (`Validated YYYY-MM-DD — N rounds[, 1 adversarial sub-agent confirmed]`). **Determine numbered-ness** from the resolved filename's leading `^[0-9]+-` digit run: present = numbered (`{NN}-{slug}`, commit subject includes `#NN`, branch `proposal/{NN}-{slug}`); absent = grandfathered (`{slug}`, commit subject drops `#NN`, branch `proposal/{slug}`).
2. Check for companions:
   - `proposals/{slug}_PLAN.md` — Phase 3 ran. If present, must also carry a validation footer.
   - `proposals/{slug}_PLAN_phase_{N}.md` — phase-decomposed plan. Each phase file must also carry a validation footer.
3. Update the proposal's header `Status:` field from `Draft` (or whatever the current value is) to `Implemented`.

### Step 2 — Move to archive

1. Ensure `proposals/archive/` exists. If not, create it.
2. Move the resolved proposal file → `proposals/archive/{same-filename}` (preserving the `{NN}-` prefix when present; use `git mv` when the proposal is tracked, plain `mv` when untracked).
3. Move any companion `{NN}-{slug}_PLAN.md` / `{NN}-{slug}_PLAN_phase_*.md` (or the unnumbered forms for a grandfathered proposal) to `proposals/archive/` alongside the proposal.
4. Confirm the validation footer is intact in each archived file — it must not be stripped by the move. **(This read is the pre-commit *early* check; it runs against the working tree while the validated content is still present and so cannot catch a commit that stages the wrong blob. The Step 3 post-commit gate below is the authoritative assertion.)**

### Step 3 — Commit, squash-merge, and delete the branch

The archive is the landing point. `/f6-archive-proposal` now commits the change, squash-merges the proposal branch into the base branch, and deletes the branch — replacing the old "suggest a commit, don't run it" behavior. This is an irreversible git-state mutation; evaluate every pre-merge guard before touching git, and **halt** (do not merge) on any failure.

**Pre-merge guards** (all must hold):

- [ ] HEAD is on the proposal branch — `proposal/{NN}-{slug}` for a numbered proposal, `proposal/{slug}` for a grandfathered one (Step 1 determined which). If not, halt and report.
- [ ] The working tree contains the proposal's change: the canonical-source edits the proposal described, the archive move (Step 2), the `.claude/` regen output from Phase 5, **and any in-flow audit auto-fixes / captured f0 stubs from a Phase 6 `/f5-audit-framework` run** (these fold into this landing per the audit's in-flow logging rule). Run `git status` for visibility — it is **not** a halt gate; `/f6` commits the whole working tree. **Unrelated tree state — ad-hoc proposal captures or other in-progress work — is expected and accepted; it folds into this landing; never halt or revert on it.** The landing-commit body **may** note any folded-in unrelated additions for honest history.
- [ ] `/f4-regen-framework` has run (or the proposal explicitly required no regen). If `.claude/` is out of sync with the canonical edits, halt and direct the user to run `/f4-regen-framework` first.
- [ ] The base branch (`main` for shamt-core) exists and the proposal branch is a descendant of it (a clean squash-merge target).

**Commit + merge** (only after every guard holds):

1. **Stage all working-tree state, then commit on the proposal branch.**

   1a. **`git add -A` — stage *everything*.** This is mandatory, not `git add {paths}`. After the Step 2 `git mv`, **only the pre-validation rename is staged** — `git mv` of a file that carries uncommitted content modifications stages the rename of the *committed (pre-validation) blob*, leaving the validated content modification at the archive path **unstaged**. A partial stage would commit the stale `Status: Draft`, footer-stripped blob. The validated content modification at the archive path, the `/f3` canonical edits, the `/f4` `.claude/` regen output, and any Phase-6 audit auto-fixes / captured f0 stubs are **all** unstaged; `git add -A` is what brings them (including untracked files) into the commit.

      ```text
      git add -A
      ```

   1b. **Commit.** **Commit subject** (per the Conventions section of `shamt-core/CLAUDE.md`; derive the short description from the proposal title / Problem):
      - Numbered: `shamt-core: land #{NN} {slug} (short description)`
      - Grandfathered/unnumbered: `shamt-core: land {slug} (short description)`

   1c. **Mandatory post-commit halt gate (the authoritative assertion).** Read the archive-path blob out of HEAD and assert it carries the validated content, and assert the tree is clean — **before** the checkout, **never after**:

      ```text
      git show HEAD:proposals/archive/{resolved-filename}   # must contain Status: Implemented + the Validated YYYY-MM-DD … footer
      git status --porcelain                                # must be empty — nothing escaped -A
      ```

      Assert the `git show HEAD:` output contains both `Status: Implemented` and the `Validated YYYY-MM-DD …` footer line, and that `git status --porcelain` is empty. **If either assertion fails, halt — do NOT `git checkout {base-branch}`** (the checkout against a dirty/wrong-blob tree is exactly what loses the validated bytes). Surface the verbatim diff (`git diff HEAD:proposals/archive/{resolved-filename}` against the intended content, or the non-empty `git status --porcelain`) and report. Only after **both** assertions pass does the gate clear.

2. **(Only after the gate passes.)** Squash-merge the proposal branch into the base branch as the **single** commit above:

   ```text
   git checkout {base-branch}                  # main for shamt-core
   git merge --squash proposal/{NN}-{slug}     # proposal/{slug} when grandfathered
   git commit -m "shamt-core: land #{NN} {slug} (…)"   # drop #{NN} when grandfathered
   ```

3. **Delete the proposal branch only after the squash-merge commit on the base branch succeeds** — never before:

   ```text
   git branch -D proposal/{NN}-{slug}          # proposal/{slug} when grandfathered
   ```

If any git step fails, halt and report the failure with the git output — do not retry blindly or force. The user's signing / hook setup applies to the commit.

### Step 4 — Exit

State the exit clearly:

```text
Proposal {slug} archived to proposals/archive/{slug}.md.
{If companions moved: list them.}
Framework-update flow complete.
```

No next-phase suggestion. The framework-update flow ends at Phase 7.

## Exit criteria

- `proposals/{slug}.md` (and companions) moved to `proposals/archive/` with validation footers intact, preserving the `{NN}-` prefix.
- The change has been committed and squash-merged to the base branch, and the `proposal/{NN}-{slug}` branch deleted (after all pre-merge guards held).

## Notes

- **Validation footer preservation** — the move must not strip the footer. `git mv` and plain `mv` preserve content; the risk is only if the proposal is opened and re-saved by tooling mid-move. Read the destination file after the move to confirm.
- **No re-archive.** The command halts if `proposals/archive/{slug}.md` exists. Re-archival is a hard ambiguity; the user must rename the prior archive or pick a new slug for the follow-up proposal.
- **Reject and defer paths.** This command implements the archive path only. The `proposals/rejected/` and `proposals/deferred/` folders are documented as expected (see `proposals/_template.md`) and used by the `/sync-triage-proposals` command on the master side — `/f6-archive-proposal` itself does not handle rejection or deferral. To reject or defer a proposal, the user moves the file manually with a brief note explaining the disposition.
- **Fresh-agent runnable** — proposal + companion files + working-tree state are sufficient. No conversation history required.

---
Validated 2026-05-28 — 4 rounds, 1 adversarial sub-agent confirmed (Phase 8 implementation loop)

<!-- Managed by Shamt — do not edit. Regenerate from shamt-core/host/templates/claude/commands/f6-archive-proposal.md. -->
