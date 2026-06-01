# Implementation Plan: deprecate-changes-md

**Proposal:** proposals/deprecate-changes-md.md
**Created:** 2026-05-29
**File operations:** 13 (CREATE: 0, EDIT: 13, DELETE: 0, MOVE: 0)

> **Path convention.** All file paths in this plan are relative to the
> `shamt-core` repository root, which is the current working directory
> (`/home/kai/code/shamt-ai-dev-v2/shamt-core`). The proposal's Proposed
> Changes table writes these same paths with a leading `shamt-core/` segment
> (container-relative); strip that segment when operating from the repo root.
> The `shamt-core/…` strings that appear *inside* LOCATE / REPLACE blocks are
> literal document text and must be reproduced verbatim — do not strip those.
>
> **Fence convention.** LOCATE and REPLACE blocks are wrapped in `~~~` (tilde)
> fences so that locate strings which themselves contain triple-backtick code
> fences nest cleanly. The content *between* the tilde fences is the exact
> string — reproduce it byte-for-byte (including leading spaces).

## Pre-execution checklist
- [ ] On a clean working tree (or a worktree dedicated to this proposal).
- [ ] `proposals/deprecate-changes-md.md` validation footer present (`Validated 2026-05-29 — 2 rounds, 1 adversarial sub-agent confirmed`).
- [ ] `proposals/archive/deprecate-changes-md.md` does **not** exist.
- [ ] Branch created: `framework-update/deprecate-changes-md` from the configured remote development branch.

## Files manifest

| # | Path | Operation | Proposal row(s) | Sibling / template |
|---|------|-----------|-----------------|--------------------|
| 1 | `host/templates/claude/commands/archive-proposal.md` | EDIT | 1 | core rewrite (Steps 1–10) |
| 2 | `host/templates/claude/skills/archive-proposal/SKILL.md` | EDIT | 2 | mirror of #1 (Steps 11–15) |
| 3 | `reference/model_selection.md` | EDIT | 3 | Step 16 |
| 4 | `CHEATSHEET.md` | EDIT | 4 | Step 17 |
| 5 | `CLAUDE.md` | EDIT | 5 | Step 18 |
| 6 | `templates/SHAMT_RULES.template.md` | EDIT | 6 | Steps 19–20 |
| 7 | `proposals/_template.md` | EDIT | 7 | Step 21 |
| 8 | `host/templates/claude/commands/propose-update.md` | EDIT | 8 | Steps 22–23 |
| 9 | `host/templates/claude/commands/implement-update.md` | EDIT | 9 | Step 24 |
| 10 | `host/templates/claude/skills/implement-update/SKILL.md` | EDIT | 10 | Step 25 |
| 11 | `host/templates/claude/commands/import-shamt.md` | EDIT | 11 | Step 26 |
| 12 | `host/templates/claude/commands/submit-proposal.md` | EDIT | 12 | Step 27 |
| 13 | `host/templates/claude/commands/triage-proposals.md` | EDIT | 13 | Step 28 |

> **Step count vs. file count.** 28 steps over 13 files. Files #1 and #2 are
> "core rewrites" (the command + its mirror skill) and decompose into multiple
> single-site edits. Every step traces back to exactly one Proposed Changes
> row (column above). No step is scope creep.

---

## Step-by-step

### Step 1 — archive-proposal command: frontmatter description

**Operation:** EDIT
**File:** `host/templates/claude/commands/archive-proposal.md`
**Proposal row:** 1
**Locate:**
~~~text
description: Phase 7 of the framework-update flow — move proposals/{slug}.md (and {slug}_PLAN.md if it exists) to proposals/archive/, preserving the validation footer, and append a CHANGES.md entry when the change is upstream-worthy
~~~
**Replace:**
~~~text
description: Phase 7 of the framework-update flow — move proposals/{slug}.md (and {slug}_PLAN.md if it exists) to proposals/archive/, preserving the validation footer
~~~
**Verification:**
- `grep -c 'append a CHANGES.md entry' host/templates/claude/commands/archive-proposal.md` returns `0`.

### Step 2 — archive-proposal command: Purpose paragraph

**Operation:** EDIT
**File:** `host/templates/claude/commands/archive-proposal.md`
**Proposal row:** 1
**Locate:**
~~~text
**Purpose:** Run Phase 7 of the framework-update flow. Move the implemented proposal (and any companion `{slug}_PLAN.md` or phase files) from `proposals/` to `proposals/archive/`, preserving the validation footer intact. When the change is upstream-worthy — meaning child projects on the next `import-shamt` will want it — append an entry to `CHANGES.md`. Seed `CHANGES.md` if it does not yet exist.
~~~
**Replace:**
~~~text
**Purpose:** Run Phase 7 of the framework-update flow. Move the implemented proposal (and any companion `{slug}_PLAN.md` or phase files) from `proposals/` to `proposals/archive/`, preserving the validation footer intact.
~~~
**Verification:**
- `grep -c 'append an entry to .CHANGES.md.' host/templates/claude/commands/archive-proposal.md` returns `0`.

### Step 3 — archive-proposal command: Recommended model

**Operation:** EDIT
**File:** `host/templates/claude/commands/archive-proposal.md`
**Proposal row:** 1
**Locate:**
~~~text
**Recommended model:** Cheap (Haiku). Archiving is mechanical: a file move, an optional CHANGES.md append, a status update. See [`reference/model_selection.md`](../../../../reference/model_selection.md).
~~~
**Replace:**
~~~text
**Recommended model:** Cheap (Haiku). Archiving is mechanical: a file move and a status update. See [`reference/model_selection.md`](../../../../reference/model_selection.md).
~~~
**Verification:**
- `grep -c 'optional CHANGES.md append' host/templates/claude/commands/archive-proposal.md` returns `0`.

### Step 4 — archive-proposal command: fix dangling Step-3 cross-reference in Prerequisites

> Renumbering (Step 5 below) removes the old "Decide upstream-worthiness" step.
> The Prerequisites bullet's "— see Step 3 below" clause then points at the
> wrong step. The proposal's Risks section ("Phase 3 enumerates every intra-file
> 'Step N' cross-reference … a post-edit grep for stale step numbers gates
> implementation") mandates resolving this. The clause has no surviving target,
> so drop it.

**Operation:** EDIT
**File:** `host/templates/claude/commands/archive-proposal.md`
**Proposal row:** 1
**Locate:**
~~~text
- The proposal has been implemented: the working tree contains the canonical edits the proposal described, and `/regen-framework` has propagated them to `.claude/` (or the proposal explicitly did not require regen — see Step 3 below).
~~~
**Replace:**
~~~text
- The proposal has been implemented: the working tree contains the canonical edits the proposal described, and `/regen-framework` has propagated them to `.claude/` (or the proposal explicitly did not require regen).
~~~
**Verification:**
- `grep -c 'see Step 3 below' host/templates/claude/commands/archive-proposal.md` returns `0`.

### Step 5 — archive-proposal command: remove Steps 3 & 4, renumber Commit suggestion to Step 3

> Single deterministic edit: matches the contiguous block from the old
> "Step 3 — Decide upstream-worthiness" header through the old "Step 5 — Commit
> suggestion" header, and replaces the whole span with the renamed
> "Step 3 — Commit suggestion" header. This deletes the upstream-worthiness
> gate and the CHANGES.md append in one operation and renumbers the survivor.

**Operation:** EDIT
**File:** `host/templates/claude/commands/archive-proposal.md`
**Proposal row:** 1
**Locate:**
~~~text
### Step 3 — Decide upstream-worthiness

Surface the upstream-worthiness question to the user via `AskUserQuestion`. The choice drives whether Step 4 writes a `CHANGES.md` entry.

A change is **upstream-worthy** when child projects on the next `import-shamt` will benefit from it. Examples:

- A new pattern, command, or skill that improves story execution.
- A bug fix or clarification in the rules / templates / references.
- A new audit dimension that catches a class of problem.

A change is **not upstream-worthy** when:

- It is master-local plumbing (e.g., a fix to `shamt-core/CLAUDE.md` that has no analogue in child projects).
- It is purely cosmetic (typo, spacing).
- It is a documentation rephrase that does not change behavior.
- It is internal to a specific in-progress refactor and the user prefers to roll it up under a single CHANGES entry later.

Default to upstream-worthy when in doubt — under-logging is worse than over-logging.

### Step 4 — Update CHANGES.md (when upstream-worthy)

If the user confirmed upstream-worthy:

1. Determine the project context. For master-local proposals, the entry has no `Proposed by:` field. For child-originated proposals (the proposal's header carries a non-empty `Proposed by:`), include the field in the entry.
2. **Locate `CHANGES.md`** at the project root (typically `shamt-core/CHANGES.md` for master-local proposals).
3. **If `CHANGES.md` does not exist**, seed it with this skeleton:

   ```markdown
   # CHANGES

   Upstream-worthy framework changes — entries added by `/archive-proposal` when
   a proposal is marked upstream-worthy. Child projects read this file on
   `import-shamt` to surface what they are picking up.

   Entries are reverse-chronological (newest at the top, under the heading).

   ---

   ```

4. **Append the entry** at the top of the entries (immediately after the `---` separator below the heading), reverse-chronological:

   ```markdown
   ## {YYYY-MM-DD} — {slug}

   {One-paragraph summary of what changed and why. Cite the canonical files
   touched.}

   **Proposed by:** {project name}  <!-- omit this line for master-local proposals -->
   **Archived:** proposals/archive/{slug}.md
   ```

5. Confirm the entry landed at the top of the entries (not appended below). Reverse-chronological is the file's convention; misplacing the entry confuses child projects reading the diff.

### Step 5 — Commit suggestion
~~~
**Replace:**
~~~text
### Step 3 — Commit suggestion
~~~
**Verification:**
- `grep -c '### Step 3 — Decide upstream-worthiness' host/templates/claude/commands/archive-proposal.md` returns `0`.
- `grep -c '### Step 4 — Update CHANGES.md' host/templates/claude/commands/archive-proposal.md` returns `0`.
- `grep -c '### Step 3 — Commit suggestion' host/templates/claude/commands/archive-proposal.md` returns `1`.
- `grep -c '### Step 5 — Commit suggestion' host/templates/claude/commands/archive-proposal.md` returns `0`.

### Step 6 — archive-proposal command: renumber Exit step

**Operation:** EDIT
**File:** `host/templates/claude/commands/archive-proposal.md`
**Proposal row:** 1
**Locate:**
~~~text
### Step 6 — Exit
~~~
**Replace:**
~~~text
### Step 4 — Exit
~~~
**Verification:**
- `grep -c '### Step 4 — Exit' host/templates/claude/commands/archive-proposal.md` returns `1`.
- `grep -c '### Step 6 — Exit' host/templates/claude/commands/archive-proposal.md` returns `0`.

### Step 7 — archive-proposal command: drop CHANGES.md from the git add example

**Operation:** EDIT
**File:** `host/templates/claude/commands/archive-proposal.md`
**Proposal row:** 1
**Locate:**
~~~text
git add proposals/archive/{slug}.md CHANGES.md  # plus the canonical-source edits + .claude/ regen output
~~~
**Replace:**
~~~text
git add proposals/archive/{slug}.md  # plus the canonical-source edits + .claude/ regen output
~~~
**Verification:**
- `grep -c 'git add proposals/archive/{slug}.md CHANGES.md' host/templates/claude/commands/archive-proposal.md` returns `0`.

### Step 8 — archive-proposal command: drop CHANGES.md line from the Exit template

**Operation:** EDIT
**File:** `host/templates/claude/commands/archive-proposal.md`
**Proposal row:** 1
**Locate:**
~~~text
Proposal {slug} archived to proposals/archive/{slug}.md.
{If upstream-worthy: "CHANGES.md updated."}
{If companions moved: list them.}
Framework-update flow complete.
~~~
**Replace:**
~~~text
Proposal {slug} archived to proposals/archive/{slug}.md.
{If companions moved: list them.}
Framework-update flow complete.
~~~
**Verification:**
- `grep -c 'If upstream-worthy: ' host/templates/claude/commands/archive-proposal.md` returns `0`.

### Step 9 — archive-proposal command: drop CHANGES.md bullet from Exit criteria

**Operation:** EDIT
**File:** `host/templates/claude/commands/archive-proposal.md`
**Proposal row:** 1
**Locate:**
~~~text
- `proposals/{slug}.md` (and companions) moved to `proposals/archive/` with validation footers intact.
- `CHANGES.md` updated when upstream-worthy (seeded if it did not exist).
- The user has been prompted (but not forced) to commit the change.
~~~
**Replace:**
~~~text
- `proposals/{slug}.md` (and companions) moved to `proposals/archive/` with validation footers intact.
- The user has been prompted (but not forced) to commit the change.
~~~
**Verification:**
- `grep -c 'updated when upstream-worthy (seeded' host/templates/claude/commands/archive-proposal.md` returns `0`.

### Step 10 — archive-proposal command: remove the two CHANGES.md Notes bullets

**Operation:** EDIT
**File:** `host/templates/claude/commands/archive-proposal.md`
**Proposal row:** 1
**Locate:**
~~~text
- **Upstream-worthiness is per-entry** — every proposal makes its own decision via Step 3. There is no global "always log to CHANGES" or "never log". The user has the final say.
- **`Proposed by:` provenance** — child-originated proposals carry the field through to `CHANGES.md`. Master-local proposals omit it. This is how downstream child projects on the next `import-shamt` know who contributed what.
- **No re-archive.**
~~~
**Replace:**
~~~text
- **No re-archive.**
~~~
**Verification:**
- `grep -c 'Upstream-worthiness is per-entry' host/templates/claude/commands/archive-proposal.md` returns `0`.
- `grep -c 'Proposed by:` provenance' host/templates/claude/commands/archive-proposal.md` returns `0`.
- `grep -c '**No re-archive.**' host/templates/claude/commands/archive-proposal.md` returns `1` (bullet preserved).
- **Final file check:** `grep -c 'CHANGES' host/templates/claude/commands/archive-proposal.md` returns `0`.

### Step 11 — archive-proposal SKILL: frontmatter description

**Operation:** EDIT
**File:** `host/templates/claude/skills/archive-proposal/SKILL.md`
**Proposal row:** 2
**Locate:**
~~~text
  Phase 7 of the Shamt framework-update flow. Move proposals/{slug}.md (and
  any companion {slug}_PLAN.md or phase files) to proposals/archive/,
  preserving the validation footer, and append an entry to CHANGES.md when
  the change is upstream-worthy. Seeds CHANGES.md if it does not yet exist.
  Updates the proposal's Status header to Implemented before the move. Does
  NOT commit on the user's behalf — surfaces a suggested commit. Invoke when
  the user wants to archive a proposal, finalize a proposal, mark a proposal
  implemented, update CHANGES.md, or close out the framework-update flow.
~~~
**Replace:**
~~~text
  Phase 7 of the Shamt framework-update flow. Move proposals/{slug}.md (and
  any companion {slug}_PLAN.md or phase files) to proposals/archive/,
  preserving the validation footer. Updates the proposal's Status header to
  Implemented before the move. Does NOT commit on the user's behalf —
  surfaces a suggested commit. Invoke when the user wants to archive a
  proposal, finalize a proposal, mark a proposal implemented, or close out
  the framework-update flow.
~~~
**Verification:**
- `grep -c 'append an entry to CHANGES.md' host/templates/claude/skills/archive-proposal/SKILL.md` returns `0`.
- `grep -c 'Seeds CHANGES.md' host/templates/claude/skills/archive-proposal/SKILL.md` returns `0`.

### Step 12 — archive-proposal SKILL: remove the two CHANGES.md trigger lines

**Operation:** EDIT
**File:** `host/templates/claude/skills/archive-proposal/SKILL.md`
**Proposal row:** 2
**Locate:**
~~~text
  - "mark the proposal implemented"
  - "update CHANGES.md for the proposal"
  - "log the change to CHANGES.md"
~~~
**Replace:**
~~~text
  - "mark the proposal implemented"
~~~
**Verification:**
- `grep -c 'update CHANGES.md for the proposal' host/templates/claude/skills/archive-proposal/SKILL.md` returns `0`.
- `grep -c 'log the change to CHANGES.md' host/templates/claude/skills/archive-proposal/SKILL.md` returns `0`.

### Step 13 — archive-proposal SKILL: remove protocol Steps 3 & 4, renumber survivors

**Operation:** EDIT
**File:** `host/templates/claude/skills/archive-proposal/SKILL.md`
**Proposal row:** 2
**Locate:**
~~~text
3. **Upstream-worthiness** — surface to the user via `AskUserQuestion`. Upstream-worthy = child projects on next `import-shamt` benefit; not = master-local plumbing, cosmetic, or pre-rollup. Default to upstream-worthy when in doubt.
4. **Update CHANGES.md** (when upstream-worthy) — seed at the project root with the standard skeleton if missing; append the entry at the top of the entries (reverse-chronological). Include `Proposed by:` for child-originated proposals; omit for master-local.
5. **Commit suggestion** — do not commit on the user's behalf. Suggest a `git status` / `git diff` review + a unified commit covering canonical edits + regen output + archive + CHANGES.md.
6. **Exit** — state the archive path, CHANGES.md update, and that the framework-update flow is complete. No next-phase suggestion.
~~~
**Replace:**
~~~text
3. **Commit suggestion** — do not commit on the user's behalf. Suggest a `git status` / `git diff` review + a unified commit covering canonical edits + regen output + archive.
4. **Exit** — state the archive path and that the framework-update flow is complete. No next-phase suggestion.
~~~
**Verification:**
- `grep -c '4. **Update CHANGES.md**' host/templates/claude/skills/archive-proposal/SKILL.md` returns `0`.
- `grep -c '3. **Commit suggestion**' host/templates/claude/skills/archive-proposal/SKILL.md` returns `1`.
- `grep -c '4. **Exit**' host/templates/claude/skills/archive-proposal/SKILL.md` returns `1`.

### Step 14 — archive-proposal SKILL: Recommended model

**Operation:** EDIT
**File:** `host/templates/claude/skills/archive-proposal/SKILL.md`
**Proposal row:** 2
**Locate:**
~~~text
Cheap (Haiku) — archive is mechanical: file move, optional CHANGES.md append, status update. See [`reference/model_selection.md`](../../../../../reference/model_selection.md).
~~~
**Replace:**
~~~text
Cheap (Haiku) — archive is mechanical: file move and status update. See [`reference/model_selection.md`](../../../../../reference/model_selection.md).
~~~
**Verification:**
- `grep -c 'optional CHANGES.md append' host/templates/claude/skills/archive-proposal/SKILL.md` returns `0`.

### Step 15 — archive-proposal SKILL: Exit criteria

**Operation:** EDIT
**File:** `host/templates/claude/skills/archive-proposal/SKILL.md`
**Proposal row:** 2
**Locate:**
~~~text
Proposal (and companions) at `proposals/archive/{slug}.md` with footers intact; CHANGES.md updated when upstream-worthy (seeded if missing); commit prompted but not executed.
~~~
**Replace:**
~~~text
Proposal (and companions) at `proposals/archive/{slug}.md` with footers intact; commit prompted but not executed.
~~~
**Verification:**
- `grep -c 'CHANGES.md updated when upstream-worthy' host/templates/claude/skills/archive-proposal/SKILL.md` returns `0`.
- **Final file check:** `grep -c 'CHANGES' host/templates/claude/skills/archive-proposal/SKILL.md` returns `0`.

### Step 16 — model_selection.md: Phase 7 row

**Operation:** EDIT
**File:** `reference/model_selection.md`
**Proposal row:** 3
**Locate:**
~~~text
| Framework update — Phase 7 (`/archive-proposal`) | Cheap | File move + optional `CHANGES.md` append + status update |
~~~
**Replace:**
~~~text
| Framework update — Phase 7 (`/archive-proposal`) | Cheap | File move + status update |
~~~
**Verification:**
- `grep -c 'CHANGES' reference/model_selection.md` returns `0`.

### Step 17 — CHEATSHEET.md: archive-proposal row

**Operation:** EDIT
**File:** `CHEATSHEET.md`
**Proposal row:** 4
**Locate:**
~~~text
| `/archive-proposal {slug}` | Phase 7 — archive + optional `CHANGES.md` entry | shipped |
~~~
**Replace:**
~~~text
| `/archive-proposal {slug}` | Phase 7 — archive the implemented proposal | shipped |
~~~
**Verification:**
- `grep -c 'CHANGES' CHEATSHEET.md` returns `0`.

### Step 18 — CLAUDE.md: "How changes land" list — remove CHANGES.md step, renumber

**Operation:** EDIT
**File:** `CLAUDE.md`
**Proposal row:** 5
**Locate:**
~~~text
3. Implement the change against canonical sources.
4. Run the regen script in `-Check` mode against a known-clean child project to verify generated output stays sync'd.
5. Update `CHANGES.md` if the change is upstream-worthy (i.e., other child projects will want it).
6. Archive the proposal to `proposals/archive/{slug}.md`.
~~~
**Replace:**
~~~text
3. Implement the change against canonical sources.
4. Run the regen script in `-Check` mode against a known-clean child project to verify generated output stays sync'd.
5. Archive the proposal to `proposals/archive/{slug}.md`.
~~~
**Verification:**
- `grep -c 'CHANGES' CLAUDE.md` returns `0`.
- `grep -c '5. Archive the proposal' CLAUDE.md` returns `1`.

### Step 19 — SHAMT_RULES.template.md: Phase 6 Polish output cell

**Operation:** EDIT
**File:** `templates/SHAMT_RULES.template.md`
**Proposal row:** 6
**Locate:**
~~~text
| 6. Polish | `feedback/addressed_feedback.md` + commits + `CHANGES.md` entries | User signals complete |
~~~
**Replace:**
~~~text
| 6. Polish | `feedback/addressed_feedback.md` + commits | User signals complete |
~~~
**Verification:**
- `grep -c 'CHANGES.md` entries' templates/SHAMT_RULES.template.md` returns `0`.

### Step 20 — SHAMT_RULES.template.md: Framework Maintenance sentence

**Operation:** EDIT
**File:** `templates/SHAMT_RULES.template.md`
**Proposal row:** 6
**Locate:**
~~~text
Use the per-phase framework-update commands for changes to canonical framework files. Do not edit live generated files (`CLAUDE.md`, `.claude/`) directly. Edit canonical sources in `shamt-core/`, run regen, run `-Check` against a known-clean child project, verify semantic consistency and generated sizes, update `CHANGES.md` when upstream-worthy, then archive the proposal.
~~~
**Replace:**
~~~text
Use the per-phase framework-update commands for changes to canonical framework files. Do not edit live generated files (`CLAUDE.md`, `.claude/`) directly. Edit canonical sources in `shamt-core/`, run regen, run `-Check` against a known-clean child project, verify semantic consistency and generated sizes, then archive the proposal.
~~~
**Verification:**
- `grep -c 'CHANGES' templates/SHAMT_RULES.template.md` returns `0` (both occurrences removed across Steps 19–20).

### Step 21 — proposals/_template.md: path-discipline canonical-docs list

**Operation:** EDIT
**File:** `proposals/_template.md`
**Proposal row:** 7
**Locate:**
~~~text
  - `shamt-core/proposals/` (when the proposal updates the proposal template, folder docs, or `CHANGES.md` format)
  - the root-level canonical docs: `shamt-core/CLAUDE.md`, `shamt-core/CHEATSHEET.md`, `shamt-core/shamt-config.example.json`, `shamt-core/CHANGES.md`.
~~~
**Replace:**
~~~text
  - `shamt-core/proposals/` (when the proposal updates the proposal template or folder docs)
  - the root-level canonical docs: `shamt-core/CLAUDE.md`, `shamt-core/CHEATSHEET.md`, `shamt-core/shamt-config.example.json`.
~~~
**Verification:**
- `grep -c 'CHANGES' proposals/_template.md` returns `0`.

### Step 22 — propose-update.md: path-discipline canonical-docs list

**Operation:** EDIT
**File:** `host/templates/claude/commands/propose-update.md`
**Proposal row:** 8
**Locate:**
~~~text
     - `shamt-core/proposals/` (when the proposal updates the proposal template, folder docs, or `CHANGES.md` format)
     - the root-level canonical docs: `shamt-core/CLAUDE.md`, `shamt-core/CHEATSHEET.md`, `shamt-core/shamt-config.example.json`, `shamt-core/CHANGES.md`.
~~~
**Replace:**
~~~text
     - `shamt-core/proposals/` (when the proposal updates the proposal template or folder docs)
     - the root-level canonical docs: `shamt-core/CLAUDE.md`, `shamt-core/CHEATSHEET.md`, `shamt-core/shamt-config.example.json`.
~~~
**Verification:**
- `grep -c 'CHANGES.md. format' host/templates/claude/commands/propose-update.md` returns `0`.

### Step 23 — propose-update.md: `Proposed by:` provenance note

**Operation:** EDIT
**File:** `host/templates/claude/commands/propose-update.md`
**Proposal row:** 8
**Locate:**
~~~text
- **`Proposed by:` and `Project context:`** are part of the v2 master/child contract — master-local proposals leave them blank; child-authored proposals fill them in so `/triage-proposals` and `CHANGES.md` (Phase 7) can attribute the change.
~~~
**Replace:**
~~~text
- **`Proposed by:` and `Project context:`** are part of the v2 master/child contract — master-local proposals leave them blank; child-authored proposals fill them in so `/triage-proposals` can attribute the change.
~~~
**Verification:**
- `grep -c 'CHANGES' host/templates/claude/commands/propose-update.md` returns `0` (both occurrences removed across Steps 22–23).

### Step 24 — implement-update.md: root-level canonical-docs enumeration

**Operation:** EDIT
**File:** `host/templates/claude/commands/implement-update.md`
**Proposal row:** 9
**Locate:**
~~~text
   - `shamt-core/CLAUDE.md`, `shamt-core/CHEATSHEET.md`, `shamt-core/shamt-config.example.json`, `shamt-core/CHANGES.md` (root-level canonical docs)
~~~
**Replace:**
~~~text
   - `shamt-core/CLAUDE.md`, `shamt-core/CHEATSHEET.md`, `shamt-core/shamt-config.example.json` (root-level canonical docs)
~~~
**Verification:**
- `grep -c 'CHANGES' host/templates/claude/commands/implement-update.md` returns `0`.

### Step 25 — implement-update SKILL: canonical-roots enumeration

**Operation:** EDIT
**File:** `host/templates/claude/skills/implement-update/SKILL.md`
**Proposal row:** 10
**Locate:**
~~~text
3. **Hard rule — canonical-only**: enumerate every path the proposal/plan will touch. Halt if any falls under `.claude/` or any non-canonical path not justified in the proposal. Canonical roots: `shamt-core/templates/`, `shamt-core/reference/`, `shamt-core/host/templates/claude/`, `shamt-core/scripts/`, `shamt-core/proposals/`, and the root-level canonical docs (`CLAUDE.md`, `CHEATSHEET.md`, `shamt-config.example.json`, `CHANGES.md`).
~~~
**Replace:**
~~~text
3. **Hard rule — canonical-only**: enumerate every path the proposal/plan will touch. Halt if any falls under `.claude/` or any non-canonical path not justified in the proposal. Canonical roots: `shamt-core/templates/`, `shamt-core/reference/`, `shamt-core/host/templates/claude/`, `shamt-core/scripts/`, `shamt-core/proposals/`, and the root-level canonical docs (`CLAUDE.md`, `CHEATSHEET.md`, `shamt-config.example.json`).
~~~
**Verification:**
- `grep -c 'CHANGES' host/templates/claude/skills/implement-update/SKILL.md` returns `0`.

### Step 26 — import-shamt.md: Step 6 follow-up item 4

**Operation:** EDIT
**File:** `host/templates/claude/commands/import-shamt.md`
**Proposal row:** 11
**Locate:**
~~~text
4. Read `CHANGES.md` on master (in the clone temp dir) to see the upstream-worthy diff log — though the import-shamt.sh script does not copy `CHANGES.md` into the child, the user can browse it in `master_url` directly.
~~~
**Replace:**
~~~text
4. To see what this import pulled in, review the per-file new / updated / unchanged / preserved counts surfaced above (also listed under Exit criteria). For the full upstream history, browse `git log` against `master_url` directly (the clone temp dir, or the source repo for a local-path `master_url`).
~~~
**Verification:**
- `grep -c 'CHANGES' host/templates/claude/commands/import-shamt.md` returns `0`.
- `grep -c 'git log` against `master_url`' host/templates/claude/commands/import-shamt.md` returns `1`.

### Step 27 — submit-proposal.md: provenance rationale

**Operation:** EDIT
**File:** `host/templates/claude/commands/submit-proposal.md`
**Proposal row:** 12
**Locate:**
~~~text
3. Confirm the proposal's header carries `Proposed by:` and `Project context:` fields with non-empty values. Per §4.13, child-submitted proposals fill these in so master's `/triage-proposals` and `CHANGES.md` can attribute the change. If either is empty, surface to the user via `AskUserQuestion` what value to fill in, then update the header in place before submission.
~~~
**Replace:**
~~~text
3. Confirm the proposal's header carries `Proposed by:` and `Project context:` fields with non-empty values. Per §4.13, child-submitted proposals fill these in so master's `/triage-proposals` can attribute the change. If either is empty, surface to the user via `AskUserQuestion` what value to fill in, then update the header in place before submission.
~~~
**Verification:**
- `grep -c 'CHANGES' host/templates/claude/commands/submit-proposal.md` returns `0`.

### Step 28 — triage-proposals.md: "Provenance preserved" note

**Operation:** EDIT
**File:** `host/templates/claude/commands/triage-proposals.md`
**Proposal row:** 13
**Locate:**
~~~text
- **Provenance preserved.** The promoted proposal still carries its `Proposed by:` and `Project context:` headers, which `/archive-proposal` reads later to attribute the change in `CHANGES.md` (see `commands/archive-proposal.md` Step 4).
~~~
**Replace:**
~~~text
- **Provenance preserved.** The promoted proposal still carries its `Proposed by:` and `Project context:` headers. The `Proposed by:` header drives the promote-time filename-prefix strip (the `{project}-` prefix is derived from it).
~~~
**Verification:**
- `grep -c 'CHANGES' host/templates/claude/commands/triage-proposals.md` returns `0`.

---

## Verification (post-execution)

- [ ] Every row in the Proposed Changes table (1–13) has at least one corresponding step (see the Files manifest "Proposal row(s)" column). One-to-one coverage confirmed; no plan step lacks a row.
- [ ] No edits landed in generated `.claude/` paths: `git status --porcelain .claude/` returns empty.
- [ ] **Completeness backstop (proposal's Phase-6 gate, scoped to canonical sources):**
  ```
  grep -rn 'CHANGES' CLAUDE.md CHEATSHEET.md reference/ templates/ proposals/_template.md host/templates/claude/
  ```
  returns **no matches**. (This scope is the canonical surface only — it deliberately excludes `.claude/` generated copies, `_reference/`, `proposals/archive/`, and the active working proposals under `proposals/`. See Notes for the sibling-proposal caveat.)
- [ ] **Stale step-number check (proposal's renumber-risk gate)** in the two rewritten files:
  ```
  grep -nE 'Step (3|4|5|6)' host/templates/claude/commands/archive-proposal.md
  grep -nE 'Step (3|4|5|6)' host/templates/claude/skills/archive-proposal/SKILL.md
  ```
  The only matches should be the renamed headers (`### Step 3 — Commit suggestion`, `### Step 4 — Exit` in the command; `3. **Commit suggestion**`, `4. **Exit**` in the skill). No dangling cross-reference to a removed step (e.g., no `see Step 3 below`, no `whether Step 4 writes`).
- [ ] `Proposed by:` / `Project context:` headers and their triage role survive — `propose-update.md`, `submit-proposal.md`, and `triage-proposals.md` still mention `/triage-proposals`; only the CHANGES.md clauses were dropped:
  ```
  grep -c 'triage-proposals' host/templates/claude/commands/propose-update.md host/templates/claude/commands/submit-proposal.md host/templates/claude/commands/triage-proposals.md
  ```
  each returns ≥ 1.
- [ ] The legitimate "upstream-worthy" trigger in `skills/propose-update/SKILL.md` is untouched (this file is NOT in the change list):
  ```
  grep -c 'upstream-worthy idea' host/templates/claude/skills/propose-update/SKILL.md
  ```
  returns `1`.
- [ ] Markdown links / reference targets in edited files still resolve (no link text was altered; only CHANGES.md prose removed).

## Notes

- **Sibling-proposal caveat.** `proposals/flow-phase-command-prefixes.md` (active, not yet implemented) also touches `archive-proposal` and references `CHANGES.md` in its own Rollback section. It is a *working proposal*, not canonical content, so it is intentionally outside the completeness-backstop grep scope above. The proposal's Risks section flags the cross-proposal collision: if `flow-phase-command-prefixes` lands first, re-confirm the `archive-proposal.md` / SKILL locate strings here at `/implement-update` time, because its renumbering edits would shift them.
- **No DELETE / MOVE / CREATE.** No `CHANGES.md` file exists at the repo root, so there is nothing to delete. All 13 operations are in-place EDITs.
- **Generated `.claude/` mirrors are out of scope.** The six command/skill bodies edited here regenerate into `.claude/` via `/regen-framework` (Phase 5). Never edit `.claude/` directly.
- **Step 5 is the only large-block edit.** Its LOCATE block contains nested triple-backtick code fences (the old CHANGES.md skeleton); that is why every LOCATE/REPLACE in this plan uses `~~~` tilde fences as the outer delimiter. Reproduce the block byte-for-byte, including the 3-space indentation on the skeleton lines.
- **Architect/builder split.** This plan is precise enough for a cheap-tier `plan-executor` to apply mechanically. If any locate string fails to match (e.g., because a sibling proposal already shifted the file), halt and report a plan defect rather than guessing — do not re-baseline in place mid-execution.

---
Validated 2026-05-29 — 1 round, 1 adversarial sub-agent confirmed
