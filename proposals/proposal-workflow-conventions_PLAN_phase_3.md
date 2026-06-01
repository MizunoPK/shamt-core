# Implementation Plan — Phase 3: f6 commit/squash-merge + model bump, sync-triage numbering

**Proposal:** proposals/proposal-workflow-conventions.md
**Index:** proposals/proposal-workflow-conventions_PLAN.md
**Created:** 2026-05-30
**Covers:** Proposed Changes rows 9, 10, 11, 12.
**File operations:** 4 EDIT.

> **Densest phase.** Row 9 (f6 command) carries the highest-risk change in the whole proposal — folding commit + squash-merge + `git branch -D` into Phase 7 behind pre-merge guards. Apply Step 9 carefully; the guards in Step 9g are load-bearing.

## Files manifest (this phase)

| Path | Operation |
|------|-----------|
| `shamt-core/host/templates/claude/commands/f6-archive-proposal.md` | EDIT (row 9) |
| `shamt-core/host/templates/claude/skills/f6-archive-proposal/SKILL.md` | EDIT (row 10) |
| `shamt-core/host/templates/claude/commands/sync-triage-proposals.md` | EDIT (row 11) |
| `shamt-core/host/templates/claude/skills/sync-triage-proposals/SKILL.md` | EDIT (row 12) |

No `.claude/` paths. No CREATE/DELETE/MOVE.

---

## Step 9 — `shamt-core/host/templates/claude/commands/f6-archive-proposal.md` (row 9)

### Step 9a — Recommended model: Haiku → Sonnet

**Operation:** EDIT
**Locate:**
```
**Recommended model:** Cheap (Haiku). Archiving is mechanical: a file move and a status update. See [`reference/model_selection.md`](../../../../reference/model_selection.md).
```
**Replace:**
```
**Recommended model:** Balanced (Sonnet). Archiving now mutates git state — it commits the proposal branch, squash-merges it into the base branch, and deletes the branch behind explicit pre-merge guards. That irreversible git work and guard evaluation outgrow the cheap-tier "mechanical file move" justification. See [`reference/model_selection.md`](../../../../reference/model_selection.md).
```
**Verification:** `grep -c "Recommended model:\*\* Balanced (Sonnet)" shamt-core/host/templates/claude/commands/f6-archive-proposal.md` returns `1`; `grep -c "Cheap (Haiku). Archiving is mechanical" shamt-core/host/templates/claude/commands/f6-archive-proposal.md` returns `0`.

### Step 9b — Purpose: add commit + squash-merge

**Operation:** EDIT
**Locate:**
```
**Purpose:** Run Phase 7 of the framework-update flow. Move the implemented proposal (and any companion `{slug}_PLAN.md` or phase files) from `proposals/` to `proposals/archive/`, preserving the validation footer intact.
```
**Replace:**
```
**Purpose:** Run Phase 7 of the framework-update flow. Move the implemented proposal (and any companion `{NN}-{slug}_PLAN.md` or phase files) from `proposals/` to `proposals/archive/` preserving the validation footer, then commit the change, squash-merge the `proposal/{NN}-{slug}` branch into the base branch as one `shamt-core: land #NN {slug} (…)` commit, and delete the branch — all behind explicit pre-merge guards.
```
**Verification:** `grep -c "squash-merge the \`proposal/{NN}-{slug}\` branch" shamt-core/host/templates/claude/commands/f6-archive-proposal.md` returns `1`.

### Step 9c — Arguments: glob resolution + numbered archive destination

**Operation:** EDIT
**Locate:**
```
- `{slug}` (required) — proposal slug. Resolves to `proposals/{slug}.md` (the implemented proposal) and `proposals/archive/{slug}.md` (the destination).
```
**Replace:**
```
- `{slug}` (required) — proposal slug. Resolves the implemented proposal exact-then-glob: `proposals/{slug}.md`, else `proposals/*-{slug}.md` (numbered `{NN}-{slug}.md`; also accepts a numbered `{NN}-{slug}` stem directly). The glob matches at most one file (slugs are unique) — halt and ask on multiple matches. The archive destination preserves the matched stem: `proposals/archive/{NN}-{slug}.md` (numbered) or `proposals/archive/{slug}.md` (unnumbered/grandfathered).
```
**Verification:** `grep -c "exact-then-glob" shamt-core/host/templates/claude/commands/f6-archive-proposal.md` returns at least `1`.

### Step 9d — Prerequisite: resolved proposal path

**Operation:** EDIT
**Locate:**
```
- `proposals/{slug}.md` exists and carries a validation footer (Phase 2 complete).
```
**Replace:**
```
- The proposal file (resolved exact-then-glob: `proposals/{slug}.md` or `proposals/*-{slug}.md`) exists and carries a validation footer (Phase 2 complete).
```
**Verification:** `grep -c "resolved exact-then-glob" shamt-core/host/templates/claude/commands/f6-archive-proposal.md` returns at least `1`.

### Step 9e — Prerequisite: archive-collision glob

**Operation:** EDIT
**Locate:**
```
- `proposals/archive/{slug}.md` does **not** already exist. If it does, halt and report — this slug was already archived. A re-archival would either overwrite the prior record or shadow it depending on filesystem semantics; neither is safe.
```
**Replace:**
```
- Neither `proposals/archive/{slug}.md` nor `proposals/archive/*-{slug}.md` already exists. If either does, halt and report — this slug was already archived. A re-archival would either overwrite the prior record or shadow it depending on filesystem semantics; neither is safe.
```
**Verification:** `grep -c "archive/\*-{slug}.md\` already exists" shamt-core/host/templates/claude/commands/f6-archive-proposal.md` returns `1`.

### Step 9f — Step 1: resolved read + companion stem + record the stem

**Operation:** EDIT
**Locate:**
```
### Step 1 — Read and confirm the proposal

1. Read `proposals/{slug}.md` top-to-bottom. Confirm the validation footer is present (`Validated YYYY-MM-DD — N rounds[, 1 adversarial sub-agent confirmed]`).
2. Check for companions:
   - `proposals/{slug}_PLAN.md` — Phase 3 ran. If present, must also carry a validation footer.
   - `proposals/{slug}_PLAN_phase_{N}.md` — phase-decomposed plan. Each phase file must also carry a validation footer.
3. Update the proposal's header `Status:` field from `Draft` (or whatever the current value is) to `Implemented`.
```
**Replace:**
```
### Step 1 — Read and confirm the proposal

1. Read the resolved proposal file (`proposals/{slug}.md` or `proposals/*-{slug}.md`) top-to-bottom. Confirm the validation footer is present (`Validated YYYY-MM-DD — N rounds[, 1 adversarial sub-agent confirmed]`). **Record the matched filename stem** — `{NN}-{slug}` when numbered, `{slug}` when grandfathered/unnumbered. The stem drives the archive destination, the branch name, and the commit subject in Steps 2–3.
2. Check for companions (same stem as the matched proposal):
   - `proposals/{NN}-{slug}_PLAN.md` (or `proposals/{slug}_PLAN.md`) — Phase 3 ran. If present, must also carry a validation footer.
   - `proposals/{NN}-{slug}_PLAN_phase_{M}.md` — phase-decomposed plan. Each phase file must also carry a validation footer.
3. Update the proposal's header `Status:` field from `Draft` (or whatever the current value is) to `Implemented`.
```
**Verification:** `grep -c "Record the matched filename stem" shamt-core/host/templates/claude/commands/f6-archive-proposal.md` returns `1`.

### Step 9g — Step 2: move with the matched stem

**Operation:** EDIT
**Locate:**
```
### Step 2 — Move to archive

1. Ensure `proposals/archive/` exists. If not, create it.
2. Move `proposals/{slug}.md` → `proposals/archive/{slug}.md` (use `git mv` when the proposal is tracked; plain `mv` when untracked).
3. Move any `{slug}_PLAN.md` / `{slug}_PLAN_phase_*.md` companions to `proposals/archive/` alongside the proposal.
4. Confirm the validation footer is intact in each archived file — it must not be stripped by the move.
```
**Replace:**
```
### Step 2 — Move to archive

1. Ensure `proposals/archive/` exists. If not, create it.
2. Move the proposal → `proposals/archive/{stem}.md`, preserving the matched stem from Step 1 (`{NN}-{slug}` numbered, `{slug}` grandfathered) — use `git mv` when tracked; plain `mv` when untracked.
3. Move any `{stem}_PLAN.md` / `{stem}_PLAN_phase_*.md` companions to `proposals/archive/` alongside the proposal.
4. Confirm the validation footer is intact in each archived file — it must not be stripped by the move.
```
**Verification:** `grep -c "preserving the matched stem from Step 1" shamt-core/host/templates/claude/commands/f6-archive-proposal.md` returns `1`.

### Step 9h — Step 3: replace "Commit suggestion" with commit + squash-merge + branch delete

**Operation:** EDIT
**Locate:**
```
### Step 3 — Commit suggestion

The archive is a logical commit point. Suggest a `git status` / `git diff` review followed by a commit, e.g.:

```text
git add proposals/archive/{slug}.md  # plus the canonical-source edits + .claude/ regen output
git commit -m "framework: implement {slug}"
```

Do not commit on behalf of the user — the canonical edits, the regen output, and the archive should ideally land together so a single revert undoes the whole change, and the user's commit conventions / signing / hook setup take over.
```
**Replace:**
```
### Step 3 — Commit, squash-merge to the base branch, and delete the proposal branch

The archive is the land point for the whole proposal. `/f6-archive-proposal` folds the commit + merge into the flow (per the pinned **Conventions** in `shamt-core/CLAUDE.md`). Run these in order; **halt on the first failed guard** and report — never force past a guard.

1. **Pre-merge guards.** Confirm all of the following; if any fails, halt and report **without** committing or merging:
   - **On the proposal branch.** `git rev-parse --abbrev-ref HEAD` equals `proposal/{NN}-{slug}` (or `proposal/{slug}` for a grandfathered/unnumbered proposal — the stem recorded in Step 1). If on the base branch or any other branch, halt — `/f3-implement-update` creates the proposal branch; if it is missing the proposal was not implemented through the flow.
   - **Tree clean except this change.** `git status --short` lists only paths under `proposals/`, `proposals/archive/`, a canonical-source root (`shamt-core/templates/`, `reference/`, `host/`, `scripts/`, the root canonical docs), or `.claude/` (regen output). Any unrelated path → halt.
   - **Regen synced.** `/f4-regen-framework` has run and `regenerate-framework.sh --check` reports zero drift (or the proposal explicitly required no regen). If unverified, halt and direct the user to `/f4-regen-framework` first.
2. **Commit** the staged change on the proposal branch:

   ```text
   git add -A
   git commit -m "shamt-core: land #NN {slug} (short summary)"
   ```

   Use the pinned subject `shamt-core: land #NN {slug} (…)`. **Drop `#NN` for a grandfathered/unnumbered proposal** → `shamt-core: land {slug} (…)`. The canonical edits, the regen output, and the archived proposal are all in this one commit so a single revert undoes the whole change.
3. **Squash-merge into the base branch and delete the proposal branch:**

   ```text
   git checkout main
   git merge --squash proposal/{NN}-{slug}
   git commit -m "shamt-core: land #NN {slug} (short summary)"
   git branch -D proposal/{NN}-{slug}
   ```

   (Substitute `proposal/{slug}` and the no-`#NN` subject for a grandfathered proposal; substitute the project's actual base branch if it is not `main`.) The squash collapses the proposal branch into one base-branch commit, matching the one-commit-per-proposal history. **Delete the branch only after the squash commit on the base branch succeeds** — if the merge or commit fails, leave the branch intact and report.
4. Do **not** push. Pushing is the user's explicit step; their remote conventions / signing / hooks take over.
```
**Verification:** `grep -c "Commit, squash-merge to the base branch, and delete the proposal branch" shamt-core/host/templates/claude/commands/f6-archive-proposal.md` returns `1`; `grep -c "Commit suggestion" shamt-core/host/templates/claude/commands/f6-archive-proposal.md` returns `0`; `grep -c "git merge --squash" shamt-core/host/templates/claude/commands/f6-archive-proposal.md` returns `1`.

### Step 9i — Step 4 exit message: report the merge + deleted branch

**Operation:** EDIT
**Locate:**
```
```text
Proposal {slug} archived to proposals/archive/{slug}.md.
{If companions moved: list them.}
Framework-update flow complete.
```
```
**Replace:**
```
```text
Proposal {slug} archived to proposals/archive/{stem}.md and squash-merged into {base-branch} as "shamt-core: land [#NN ]{slug} (…)"; branch proposal/{stem} deleted.
{If companions moved: list them.}
Framework-update flow complete.
```
```
**Verification:** `grep -c "squash-merged into {base-branch}" shamt-core/host/templates/claude/commands/f6-archive-proposal.md` returns `1`.

### Step 9j — Exit criteria: commit + merge replaces "prompted to commit"

**Operation:** EDIT
**Locate:**
```
- `proposals/{slug}.md` (and companions) moved to `proposals/archive/` with validation footers intact.
- The user has been prompted (but not forced) to commit the change.
```
**Replace:**
```
- The proposal (and companions) moved to `proposals/archive/{stem}.md` with validation footers intact.
- The change is committed and squash-merged into the base branch as one `shamt-core: land [#NN ]{slug} (…)` commit, and the `proposal/{stem}` branch is deleted — all behind the Step 3 pre-merge guards. (Not pushed — pushing is the user's step.)
```
**Verification:** `grep -c "squash-merged into the base branch as one" shamt-core/host/templates/claude/commands/f6-archive-proposal.md` returns `1`; `grep -c "prompted (but not forced) to commit" shamt-core/host/templates/claude/commands/f6-archive-proposal.md` returns `0`.

---

## Step 10 — `shamt-core/host/templates/claude/skills/f6-archive-proposal/SKILL.md` (row 10) — mirror

### Step 10a — Frontmatter: commit/merge replaces "does NOT commit"

**Operation:** EDIT
**Locate:**
```
  Implemented before the move. Does NOT commit on the user's behalf —
  surfaces a suggested commit. Invoke when the user wants to archive a
```
**Replace:**
```
  Implemented before the move. Then commits, squash-merges the proposal
  branch into the base branch, and deletes the branch behind pre-merge
  guards (Phase 7 lands the change). Invoke when the user wants to archive a
```
**Verification:** `grep -c "squash-merges the proposal" shamt-core/host/templates/claude/skills/f6-archive-proposal/SKILL.md` returns `1`; `grep -c "Does NOT commit on the user's behalf" shamt-core/host/templates/claude/skills/f6-archive-proposal/SKILL.md` returns `0`.

### Step 10b — Protocol item 1: glob resolve + record stem

**Operation:** EDIT
**Locate:**
```
1. **Read and confirm** — `proposals/{slug}.md` exists with a validation footer. Check for companions (`{slug}_PLAN.md`, `{slug}_PLAN_phase_N.md`); each must also carry a footer. Update the proposal's `Status:` header to `Implemented`.
```
**Replace:**
```
1. **Read and confirm** — resolve the proposal exact-then-glob (`proposals/{slug}.md`, else `proposals/*-{slug}.md`); confirm a validation footer. Note the matched stem (`{NN}-{slug}` or grandfathered `{slug}`) — it drives the archive name, branch, and commit subject. Check companions (`{stem}_PLAN.md`, `{stem}_PLAN_phase_N.md`); each must also carry a footer. Update the proposal's `Status:` header to `Implemented`.
```
**Verification:** `grep -c "Note the matched stem" shamt-core/host/templates/claude/skills/f6-archive-proposal/SKILL.md` returns `1`.

### Step 10c — Protocol item 2: move with stem + archive glob

**Operation:** EDIT
**Locate:**
```
2. **Move to archive** — ensure `proposals/archive/` exists; `git mv` (when tracked) or plain `mv` the proposal and companions into it. Confirm footers intact post-move. Halt if `proposals/archive/{slug}.md` already exists.
```
**Replace:**
```
2. **Move to archive** — ensure `proposals/archive/` exists; `git mv` (when tracked) or plain `mv` the proposal and companions into it, preserving the matched stem (`proposals/archive/{stem}.md`). Confirm footers intact post-move. Halt if `proposals/archive/{slug}.md` or `archive/*-{slug}.md` already exists.
```
**Verification:** `grep -c "preserving the matched stem (\`proposals/archive/{stem}.md\`)" shamt-core/host/templates/claude/skills/f6-archive-proposal/SKILL.md` returns `1`.

### Step 10d — Protocol item 3: commit + squash-merge + delete branch

**Operation:** EDIT
**Locate:**
```
3. **Commit suggestion** — do not commit on the user's behalf. Suggest a `git status` / `git diff` review + a unified commit covering canonical edits + regen output + archive.
```
**Replace:**
```
3. **Commit + squash-merge + delete branch** — behind explicit pre-merge guards (on `proposal/{stem}`; tree clean except this change; regen synced): `git commit` the work, `git checkout` the base branch, `git merge --squash proposal/{stem}`, commit as `shamt-core: land #NN {slug} (…)` (drop `#NN` when grandfathered), then `git branch -D proposal/{stem}` only after the squash commit succeeds. Do not push. Halt on any failed guard.
```
**Verification:** `grep -c "Commit + squash-merge + delete branch" shamt-core/host/templates/claude/skills/f6-archive-proposal/SKILL.md` returns `1`.

### Step 10e — Protocol item 4: exit reports the merge

**Operation:** EDIT
**Locate:**
```
4. **Exit** — state the archive path and that the framework-update flow is complete. No next-phase suggestion.
```
**Replace:**
```
4. **Exit** — state the archive path, the squash-merge commit, and the deleted branch; the framework-update flow is complete. No next-phase suggestion.
```
**Verification:** `grep -c "the squash-merge commit, and the deleted branch" shamt-core/host/templates/claude/skills/f6-archive-proposal/SKILL.md` returns `1`.

### Step 10f — Recommended model: Haiku → Sonnet

**Operation:** EDIT
**Locate:**
```
Cheap (Haiku) — archive is mechanical: file move and status update. See [`reference/model_selection.md`](../../../../../reference/model_selection.md).
```
**Replace:**
```
Balanced (Sonnet) — archiving now mutates git state (commit, squash-merge, branch delete) behind pre-merge guards; that irreversible work outgrows the cheap-tier "mechanical file move" justification. See [`reference/model_selection.md`](../../../../../reference/model_selection.md).
```
**Verification:** `grep -c "Balanced (Sonnet) — archiving now mutates git state" shamt-core/host/templates/claude/skills/f6-archive-proposal/SKILL.md` returns `1`.

### Step 10g — Exit criteria: commit + merge

**Operation:** EDIT
**Locate:**
```
Proposal (and companions) at `proposals/archive/{slug}.md` with footers intact; commit prompted but not executed.
```
**Replace:**
```
Proposal (and companions) at `proposals/archive/{stem}.md` with footers intact; the change committed and squash-merged into the base branch as one `shamt-core: land [#NN ]{slug} (…)` commit, and the `proposal/{stem}` branch deleted (not pushed).
```
**Verification:** `grep -c "committed and squash-merged into the base branch" shamt-core/host/templates/claude/skills/f6-archive-proposal/SKILL.md` returns `1`.

---

## Step 11 — `shamt-core/host/templates/claude/commands/sync-triage-proposals.md` (row 11)

### Step 11a — Purpose: promote writes numbered filename

**Operation:** EDIT
**Locate:**
```
route per their decision: **promote** (move to `proposals/{slug}.md` and hand off to the framework-update flow starting at Phase 2), **reject** (move to `proposals/rejected/{slug}.md` with a top-of-file note), or **defer** (move to `proposals/deferred/{slug}.md`).
```
**Replace:**
```
route per their decision: **promote** (assign the master-side number and move to `proposals/{NN}-{slug}.md`, then hand off to the framework-update flow starting at Phase 2), **reject** (move to `proposals/rejected/{slug}.md` with a top-of-file note), or **defer** (move to `proposals/deferred/{slug}.md`).
```
**Verification:** `grep -c "assign the master-side number and move to \`proposals/{NN}-{slug}.md\`" shamt-core/host/templates/claude/commands/sync-triage-proposals.md` returns `1`.

### Step 11b — Step 2c promote option description: numbered destination

**Operation:** EDIT
**Locate:**
```
- **Promote** — accept the proposal; it will be moved to `proposals/{slug}.md` and the framework-update flow will resume at Phase 2 (validate-artifact).
```
**Replace:**
```
- **Promote** — accept the proposal; a master-side number is assigned and it is moved to `proposals/{NN}-{slug}.md`, then the framework-update flow resumes at Phase 2 (validate-artifact).
```
**Verification:** `grep -c "a master-side number is assigned and it is moved to" shamt-core/host/templates/claude/commands/sync-triage-proposals.md` returns `1`.

### Step 11c — Step 2d Promote: assign number, numbered filename, no branch

**Operation:** EDIT
**Locate:**
```
**Promote:**

1. Ensure `proposals/` exists at the project root (it should, on master).
2. Halt if `proposals/{slug}.md` already exists — slug collision, the user must resolve manually (rename one or re-author).
3. `git mv proposals/incoming/{filename} proposals/{slug}.md` (or plain `mv` if untracked).
4. Confirm the validation footer (if present) is intact post-move.
5. Note in chat the next command to run: `/validate-artifact proposals/{slug}.md`. Do not invoke it from this command — phase-per-command resumability (Principle 1) keeps every phase independently runnable by a fresh agent.
```
**Replace:**
```
**Promote:**

1. Ensure `proposals/` exists at the project root (it should, on master).
2. **Assign the master-side number.** Scan `proposals/`, `proposals/archive/`, `proposals/deferred/`, and `proposals/rejected/` for filenames whose basename matches `^[0-9]+-`; the new number is `max(leading NN) + 1`, or `01` if none exist. Format two-digit zero-padded. **Re-read from disk per promote** — when triaging several proposals in one run, do not cache the max, or two promotes in the same session collide on the same number.
3. Halt if `proposals/{slug}.md` or `proposals/*-{slug}.md` already exists — slug collision, the user must resolve manually (rename one or re-author).
4. `git mv proposals/incoming/{filename} proposals/{NN}-{slug}.md` (or plain `mv` if untracked). **Do not create a branch** — branch creation is deferred to `/f3-implement-update` for all proposals; sync-triage stays a pure router.
5. Fill (or add, if absent) the promoted proposal's `**Number:**` header with the assigned `{NN}`.
6. Confirm the validation footer (if present) is intact post-move.
7. Note in chat the next command to run: `/validate-artifact proposals/{NN}-{slug}.md`. Do not invoke it from this command — phase-per-command resumability (Principle 1) keeps every phase independently runnable by a fresh agent.
```
**Verification:** `grep -c "Assign the master-side number" shamt-core/host/templates/claude/commands/sync-triage-proposals.md` returns `1`; `grep -c "Do not create a branch" shamt-core/host/templates/claude/commands/sync-triage-proposals.md` returns `1`.

### Step 11d — Step 3 summary "Next:" block: numbered paths

**Operation:** EDIT
**Locate:**
```
Next:
  /clear
  /validate-artifact proposals/{slug-1}.md
  /clear
  /validate-artifact proposals/{slug-2}.md
  ...
```
**Replace:**
```
Next:
  /clear
  /validate-artifact proposals/{NN1}-{slug-1}.md
  /clear
  /validate-artifact proposals/{NN2}-{slug-2}.md
  ...
```
**Verification:** `grep -c "proposals/{NN1}-{slug-1}.md" shamt-core/host/templates/claude/commands/sync-triage-proposals.md` returns `1`.

### Step 11e — Exit criteria: numbered next-command path

**Operation:** EDIT
**Locate:**
```
- For each promoted slug, the next command (`/validate-artifact proposals/{slug}.md`) has been stated.
```
**Replace:**
```
- For each promoted slug, the next command (`/validate-artifact proposals/{NN}-{slug}.md`) has been stated.
```
**Verification:** `grep -c "/validate-artifact proposals/{NN}-{slug}.md\`) has been stated" shamt-core/host/templates/claude/commands/sync-triage-proposals.md` returns `1`.

---

## Step 12 — `shamt-core/host/templates/claude/skills/sync-triage-proposals/SKILL.md` (row 12) — mirror

### Step 12a — Frontmatter: promote assigns number + numbered destination

**Operation:** EDIT
**Locate:**
```
  (derived from the proposal's Proposed by header) and moves the file to
  proposals/{slug}.md, then suggests /validate-artifact as the next command —
```
**Replace:**
```
  (derived from the proposal's Proposed by header), assigns the master-side
  number, and moves the file to proposals/{NN}-{slug}.md, then suggests
  /validate-artifact as the next command —
```
**Verification:** `grep -c "moves the file to\n.*proposals/{NN}-{slug}.md" shamt-core/host/templates/claude/skills/sync-triage-proposals/SKILL.md` returns `1` (or confirm the `proposals/{NN}-{slug}.md` string is present in the frontmatter).

### Step 12b — Protocol Promote summary: number + numbered path + no branch

**Operation:** EDIT
**Locate:**
```
     - Promote → `git mv` (or `mv`) to `proposals/{slug}.md`. Halt on slug collision. State next command: `/clear` then `/validate-artifact proposals/{slug}.md`.
```
**Replace:**
```
     - Promote → assign the master-side number (`max(leading ^[0-9]+- across proposals/, archive/, deferred/, rejected/) + 1`, re-read from disk per promote); `git mv` (or `mv`) to `proposals/{NN}-{slug}.md`; fill the `**Number:**` header. **No branch** (deferred to `/f3-implement-update`). Halt on slug collision (`proposals/{slug}.md` or `*-{slug}.md`). State next command: `/clear` then `/validate-artifact proposals/{NN}-{slug}.md`.
```
**Verification:** `grep -c "assign the master-side number" shamt-core/host/templates/claude/skills/sync-triage-proposals/SKILL.md` returns `1`.

---

## Cross-check (this phase vs. Proposed Changes rows)

| Row | File | Steps | Operation match |
|-----|------|-------|-----------------|
| 9 | f6 command | 9a–9j | EDIT ✓ |
| 10 | f6 skill | 10a–10g | EDIT ✓ |
| 11 | sync-triage command | 11a–11e | EDIT ✓ |
| 12 | sync-triage skill | 12a, 12b | EDIT ✓ |

All four rows covered; every step is an EDIT; no `.claude/` path touched. The f6 model recommendation (9a / 10f) reads Balanced (Sonnet) in both command and skill. The f6 commit subject (`shamt-core: land #NN {slug} (…)`, drop `#NN` when grandfathered) matches the `## Conventions` section authored in Phase 1 (Step 1a) — confirm they agree. sync-triage creates **no** branch (11c / 12b), consistent with branch creation deferred to f3 (Phase 2, Step 7g).
