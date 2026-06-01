# Implementation Plan — Phase 1: Convention foundation + numbering source

**Proposal:** proposals/proposal-workflow-conventions.md
**Index:** proposals/proposal-workflow-conventions_PLAN.md
**Created:** 2026-05-30
**Covers:** Proposed Changes rows 1, 2, 3, 4.
**File operations:** 4 EDIT.

## Files manifest (this phase)

| Path | Operation |
|------|-----------|
| `shamt-core/CLAUDE.md` | EDIT (row 1) |
| `shamt-core/proposals/_template.md` | EDIT (row 2) |
| `shamt-core/host/templates/claude/commands/f1-propose-update.md` | EDIT (row 3) |
| `shamt-core/host/templates/claude/skills/f1-propose-update/SKILL.md` | EDIT (row 4) |

No `.claude/` paths. No CREATE/DELETE/MOVE.

---

## Step 1 — `shamt-core/CLAUDE.md` (row 1)

### Step 1a — Replace the `## Commit conventions (TBD)` section with a pinned `## Conventions` section

**Operation:** EDIT
**File:** `shamt-core/CLAUDE.md`
**Locate:**
```
## Commit conventions (TBD)

Not pinned yet. Decide before the first feature commit and document here. The repo-root `CLAUDE.md` calls out the same TBD; resolve them together.
```
**Replace:**
```
## Conventions

These are pinned. The authoritative mechanics live in the `/f1-propose-update`, `/f3-implement-update`, and `/f6-archive-proposal` command bodies; this section is the at-a-glance summary.

- **Proposal numbers.** Every master-side proposal carries a lightweight organizational number — a two-digit, zero-padded `NN` prefix on its filename (`proposals/{NN}-{slug}.md`) plus a `**Number:**` header. The number is `max(existing NN across proposals/, proposals/archive/, proposals/deferred/, proposals/rejected/) + 1` (the first numbered proposal is `01`; all four folders are scanned so a deferred or rejected number is never reused). It is **not** a revival of v1's SHAMT-N design-doc lifecycle — there is no per-number doc, status machine, or cross-reference convention; it is only an `ls`-orderable identifier so a human can say "proposal 12". Proposals authored before this convention stay unnumbered; the scan ignores them. Child-authored proposals stay unnumbered until master assigns the number — at `/f1-propose-update` (master-local) or `/sync-triage-proposals` promote (child-submitted).
- **Branch per proposal.** Each proposal lands on a `proposal/{NN}-{slug}` branch (`proposal/{slug}` for an unnumbered/grandfathered proposal), created by `/f3-implement-update` from the base branch immediately before the canonical edits — not during authoring, validation, or planning, which happen on the base branch. The branch exists only for the implement→merge window.
- **Commit subject.** `shamt-core: land #NN {slug} (short summary)` — codifies the de-facto subject and adds the number (drop `#NN` for an unnumbered/grandfathered proposal).
- **Archive commits + merges.** `/f6-archive-proposal` commits the work on the proposal branch, squash-merges it into `main` as that one commit, then deletes the branch. The canonical edits, the regen output, and the archived proposal land together so a single revert undoes the whole change.
```
**Verification:**
- `grep -c "^## Conventions" shamt-core/CLAUDE.md` returns `1`.
- `grep -c "Commit conventions (TBD)" shamt-core/CLAUDE.md` returns `0`.
- `grep -c "ls\`-orderable identifier" shamt-core/CLAUDE.md` returns `1`.

### Step 1b — Reconcile the "No SHAMT-N numbering" out-of-scope line

**Operation:** EDIT
**File:** `shamt-core/CLAUDE.md`
**Locate:**
```
- **No SHAMT-N numbering for framework changes.** Proposal slugs are descriptive.
```
**Replace:**
```
- **No SHAMT-N design-doc lifecycle.** Proposals carry a lightweight, `ls`-orderable `NN` number (see [Conventions](#conventions)) — but there is no per-number design-doc, status machine, or cross-reference convention; the v1 SHAMT-N lifecycle stays out.
```
**Verification:**
- `grep -c "No SHAMT-N design-doc lifecycle" shamt-core/CLAUDE.md` returns `1`.
- `grep -c "No SHAMT-N numbering for framework changes" shamt-core/CLAUDE.md` returns `0`.

---

## Step 2 — `shamt-core/proposals/_template.md` (row 2)

### Step 2a — Add the `**Number:**` header field

**Operation:** EDIT
**File:** `shamt-core/proposals/_template.md`
**Locate:**
```
**Created:** [YYYY-MM-DD]
**Status:** Draft
**Proposed by:** [Project name, or blank for master-local proposals]
```
**Replace:**
```
**Created:** [YYYY-MM-DD]
**Number:** [NN — assigned on master at /f1-propose-update (master-local) or /sync-triage-proposals promote (child-submitted); blank for child-local drafts and grandfathered proposals]
**Status:** Draft
**Proposed by:** [Project name, or blank for master-local proposals]
```
**Verification:**
- `grep -c "^\*\*Number:\*\*" shamt-core/proposals/_template.md` returns `1`.

### Step 2b — Update the layout comment tree to show numbered filenames

**Operation:** EDIT
**File:** `shamt-core/proposals/_template.md`
**Locate:**
```
  proposals/
  ├── _template.md                              (this file — copy when authoring a new proposal)
  ├── {slug}.md                                 (active proposals — Phase 1 through Phase 4)
  ├── {slug}_PLAN.md                            (Phase 3 plan, only for proposals >10 file ops)
  ├── archive/{slug}.md                         (post-implementation, set by /f6-archive-proposal)
  ├── archive/{slug}.draft-{timestamp}.md       (abandoned drafts, set by /f1-propose-update on start-over re-entry)
  ├── rejected/{slug}.md                        (explicit rejections with a top-of-file note)
  └── deferred/{slug}.md                        (on hold)
```
**Replace:**
```
  proposals/
  ├── _template.md                                 (this file — copy when authoring a new proposal)
  ├── {NN}-{slug}.md                               (active proposals — Phase 1 through Phase 4; NN assigned master-side)
  ├── {NN}-{slug}_PLAN.md                          (Phase 3 plan, only for proposals >10 file ops)
  ├── {NN}-{slug}_PLAN_phase_{M}.md                (phase-decomposed plan, when the plan is split)
  ├── archive/{NN}-{slug}.md                       (post-implementation, set by /f6-archive-proposal)
  ├── archive/{slug}.draft-{timestamp}.md          (abandoned drafts, set by /f1-propose-update on start-over re-entry)
  ├── rejected/{NN}-{slug}.md                      (explicit rejections with a top-of-file note)
  └── deferred/{NN}-{slug}.md                      (on hold)
```
**Verification:**
- `grep -c "{NN}-{slug}.md " shamt-core/proposals/_template.md` returns at least `1`.

### Step 2c — Update the layout-comment prose to document the numbering + branch convention

**Operation:** EDIT
**File:** `shamt-core/proposals/_template.md`
**Locate:**
```
Active proposals live at the top level. /f6-archive-proposal moves implemented
proposals (and any companion *_PLAN.md / *_PLAN_phase_N.md files) into
archive/; /f1-propose-update moves abandoned drafts into archive/ with a
.draft-{timestamp} infix when the user picks "start over" on re-entry. The
rejected/ and deferred/ folders are populated manually by the user (or by
/sync-triage-proposals on the master side, when that ships).
```
**Replace:**
```
Active proposals live at the top level. **Master-side proposals carry a two-digit
zero-padded `NN` prefix** (`{NN}-{slug}.md`) — an `ls`-orderable organizational
number assigned by /f1-propose-update (master-local) or /sync-triage-proposals
promote (child-submitted) as `max(existing NN across proposals/, archive/,
deferred/, rejected/) + 1` (first proposal is `01`; all four folders scanned so a
deferred/rejected number is never reused). **Child-local drafts stay unnumbered**
(`{slug}.md`) until master assigns the number; proposals authored before this
convention also remain unnumbered and the scan simply ignores them. The
`proposal/{NN}-{slug}` branch is created by /f3-implement-update (not at authoring
time); /f6-archive-proposal commits, squash-merges it into the base branch, and
deletes it.

/f6-archive-proposal moves implemented proposals (and any companion
*_PLAN.md / *_PLAN_phase_N.md files) into archive/; /f1-propose-update moves
abandoned drafts into archive/ with a .draft-{timestamp} infix when the user
picks "start over" on re-entry. The rejected/ and deferred/ folders are
populated manually by the user (or by /sync-triage-proposals on the master side).
```
**Verification:**
- `grep -c "two-digit" shamt-core/proposals/_template.md` returns at least `1`.
- `grep -c "when that ships" shamt-core/proposals/_template.md` returns `0` (stale clause removed).

---

## Step 3 — `shamt-core/host/templates/claude/commands/f1-propose-update.md` (row 3)

### Step 3a — Arguments: numbering note (master assigns number; no branch)

**Operation:** EDIT
**File:** `shamt-core/host/templates/claude/commands/f1-propose-update.md`
**Locate:**
```
- `{slug}` (required) — descriptive kebab-case slug for the proposal (e.g., `fix-spec-template-missing-section`, `add-mermaid-recipe`). The slug becomes the filename `.shamt-core/proposals/{slug}.md`. Slugs are descriptive, not numbered — there is no SHAMT-N convention in v2.
```
**Replace:**
```
- `{slug}` (required) — descriptive kebab-case slug for the proposal (e.g., `fix-spec-template-missing-section`, `add-mermaid-recipe`). On the child side the slug becomes the filename `.shamt-core/proposals/{slug}.md` (unnumbered). On the master side `/f1-propose-update` prefixes a lightweight two-digit organizational number, producing `proposals/{NN}-{slug}.md` (see Step 1). The number is an `ls`-orderable identifier — **not** a revival of v1's SHAMT-N design-doc lifecycle. f1 does **not** create a git branch; the `proposal/{NN}-{slug}` branch is created later by `/f3-implement-update`.
```
**Verification:**
- `grep -c "does \*\*not\*\* create a git branch" shamt-core/host/templates/claude/commands/f1-propose-update.md` returns `1`.

### Step 3b — Replace the entire `## Slug resolution` section with the exact-then-glob form

**Operation:** EDIT
**File:** `shamt-core/host/templates/claude/commands/f1-propose-update.md`
**Locate:**
```
## Slug resolution

Proposals are **flat files**, not folders. There is no `_PLAN.md` companion at this phase; that comes in Phase 3.

- Try `.shamt-core/proposals/{slug}.md` (exact match).
- **File exists, non-empty** — treat as re-entry. Read the file, confirm with the user whether to extend the existing proposal or start over. If extending, skip the template-seed step (Step-by-step Step 1 below) and resume drafting at Step-by-step Step 2; **if a prior Phase 2 validation footer is present, strip it before continuing — extending the proposal invalidates the prior validation, and Phase 2 must re-run on the extended content (the Step 6 exit gate enforces this).** If starting over, move the abandoned draft to `.shamt-core/proposals/archive/{slug}.draft-{timestamp}.md` (using `git mv` when tracked) before overwriting. The archive folder is the documented home for retired proposal files; the `.draft-{timestamp}` infix distinguishes abandoned drafts from implemented archives.
- **File does not exist** — continue to Step-by-step Step 1 below.
- **`.shamt-core/proposals/archive/{slug}.md` exists** — a proposal with this slug was already implemented. Halt, report the archive location, and ask the user to pick a different slug or explicitly confirm they want a follow-up proposal under the same slug (uncommon).
```
**Replace:**
```
## Slug resolution

Proposals are **flat files**, not folders. There is no `_PLAN.md` companion at this phase; that comes in Phase 3.

**Proposals directory.** Child-side authoring writes to `.shamt-core/proposals/`; master-side authoring (self-host) writes to `proposals/` under the shamt-core root — the same folder `/f2`, `/f3`, `/f6`, and `/sync-triage-proposals` use. Master vs. child is the detection in Prerequisites (`shamt-core/`-present master root vs. `.shamt-core/`-synced child root). Below, `{proposals}/` is `.shamt-core/proposals/` on the child and `proposals/` on master.

**Resolve the slug to a single file (exact-then-glob).** Try `{proposals}/{slug}.md` (exact — matches a child-local/unnumbered draft, a grandfathered pre-convention proposal, or a numbered stem passed directly as the slug arg); if absent, try `{proposals}/*-{slug}.md` (matches a master-side numbered `{NN}-{slug}.md`). Proposal slugs are unique, so the glob matches **at most one** file — if it ever matches more than one, halt and ask the user (the global story-folder slug-resolution invariant).

- **File exists, non-empty** — treat as re-entry. Read the file, confirm with the user whether to extend the existing proposal or start over. If extending, skip the template-seed step (Step-by-step Step 1 below) and resume drafting at Step-by-step Step 2; **if a prior Phase 2 validation footer is present, strip it before continuing — extending the proposal invalidates the prior validation, and Phase 2 must re-run on the extended content (the Step 6 exit gate enforces this).** If starting over, move the abandoned draft to `{proposals}/archive/{matched-stem}.draft-{timestamp}.md` (using `git mv` when tracked) before overwriting, preserving the matched filename stem (numbered or not). The archive folder is the documented home for retired proposal files; the `.draft-{timestamp}` infix distinguishes abandoned drafts from implemented archives.
- **File does not exist** — continue to Step-by-step Step 1 below.
- **`{proposals}/archive/{slug}.md` or `{proposals}/archive/*-{slug}.md` exists** — a proposal with this slug was already implemented. Halt, report the archive location, and ask the user to pick a different slug or explicitly confirm they want a follow-up proposal under the same slug (uncommon).
```
**Verification:**
- `grep -c "exact-then-glob" shamt-core/host/templates/claude/commands/f1-propose-update.md` returns `1`.
- `grep -c "archive/\*-{slug}.md" shamt-core/host/templates/claude/commands/f1-propose-update.md` returns at least `1`.

### Step 3c — Replace `### Step 1 — Seed from the template` with the master-side number-assignment version

**Operation:** EDIT
**File:** `shamt-core/host/templates/claude/commands/f1-propose-update.md`
**Locate:**
```
### Step 1 — Seed from the template

1. Read [`.shamt-core/proposals/_template.md`](../../../../proposals/_template.md) top-to-bottom.
2. Copy it to `.shamt-core/proposals/{slug}.md`.
3. Fill in the header block: `Created: {today's YYYY-MM-DD}`, `Status: Draft`, `Proposed by:` (blank for master-local; the child's project name for child-authored), `Project context:` (one-line context for child-authored; blank otherwise).
```
**Replace:**
```
### Step 1 — Seed from the template

1. Read [`.shamt-core/proposals/_template.md`](../../../../proposals/_template.md) top-to-bottom.
2. **Assign the proposal number — master side only.** Determine the side via the master-vs-child detection in Prerequisites.
   - **Master side:** scan every folder a numbered proposal can come to rest in — `proposals/`, `proposals/archive/`, `proposals/deferred/`, `proposals/rejected/` — for filenames whose basename matches `^[0-9]+-`. Take the highest leading number across all four folders; the new number is that max `+ 1`, or `01` when no numbered file exists yet. Format it two-digit zero-padded (`01`, `02`, …; widen to three digits only past `99`). This is `{NN}`. The destination filename is `proposals/{NN}-{slug}.md`. **Do not create a git branch** — branch creation happens later in `/f3-implement-update`.
   - **Child side:** assign **no** number (master assigns it later at `/sync-triage-proposals` promote). The destination filename is `.shamt-core/proposals/{slug}.md`.
3. Copy the template to the destination filename from sub-step 2.
4. Fill in the header block: `Created: {today's YYYY-MM-DD}`, `Number:` (`{NN}` on master; blank on the child side), `Status: Draft`, `Proposed by:` (blank for master-local; the child's project name for child-authored), `Project context:` (one-line context for child-authored; blank otherwise).
```
**Verification:**
- `grep -c "Assign the proposal number — master side only" shamt-core/host/templates/claude/commands/f1-propose-update.md` returns `1`.
- `grep -c "Do not create a git branch" shamt-core/host/templates/claude/commands/f1-propose-update.md` returns `1`.

### Step 3d — Purpose line: numbered path + no branch

**Operation:** EDIT
**File:** `shamt-core/host/templates/claude/commands/f1-propose-update.md`
**Locate:**
```
**Purpose:** Run Phase 1 of the framework-update flow. Resolve a slug to `.shamt-core/proposals/{slug}.md`, draft (or edit) the proposal against the canonical template, and apply the open-questions iterative dialog until every question is resolved and every affected canonical file is listed.
```
**Replace:**
```
**Purpose:** Run Phase 1 of the framework-update flow. Resolve a slug to the proposal file (`.shamt-core/proposals/{slug}.md` on the child side; `proposals/{NN}-{slug}.md` on master, where this command assigns the lightweight organizational number), draft (or edit) the proposal against the canonical template, and apply the open-questions iterative dialog until every question is resolved and every affected canonical file is listed.
```
**Verification:**
- `grep -c "where this command assigns the lightweight organizational number" shamt-core/host/templates/claude/commands/f1-propose-update.md` returns `1`.

### Step 3e — Step 6 exit gate: numbered path + Number header, no branch

**Operation:** EDIT
**File:** `shamt-core/host/templates/claude/commands/f1-propose-update.md`
**Locate:**
```
- [ ] Proposal exists at `.shamt-core/proposals/{slug}.md` and is non-empty.
```
**Replace:**
```
- [ ] Proposal exists at the resolved path (`.shamt-core/proposals/{slug}.md` on the child; `proposals/{NN}-{slug}.md` on master) and is non-empty.
- [ ] On master: the `**Number:**` header is filled with the assigned `{NN}`. (Child-side: `**Number:**` blank.) No git branch is created at this phase.
```
**Verification:**
- `grep -c "No git branch is created at this phase" shamt-core/host/templates/claude/commands/f1-propose-update.md` returns `1`.

### Step 3f — Step 7 next-phase suggestion: written-path + glob-aware /f2 arg

**Operation:** EDIT
**File:** `shamt-core/host/templates/claude/commands/f1-propose-update.md`
**Locate:**
```
### Step 7 — Suggest the next phase

Suggest a context-clear and the next command:

- Row count ≤ 10 → `/clear`, then `/validate-artifact .shamt-core/proposals/{slug}.md`.
- Row count > 10 → `/clear`, then `/validate-artifact .shamt-core/proposals/{slug}.md`, then `/f2-plan-update-implementation {slug}`.
```
**Replace:**
```
### Step 7 — Suggest the next phase

Suggest a context-clear and the next command. Use the path the proposal was actually written to (`.shamt-core/proposals/{slug}.md` on the child; `proposals/{NN}-{slug}.md` on master). `/f2-plan-update-implementation` accepts the bare slug (glob-resolved) or the numbered `{NN}-{slug}` stem.

- Row count ≤ 10 → `/clear`, then `/validate-artifact {written-path}`.
- Row count > 10 → `/clear`, then `/validate-artifact {written-path}`, then `/f2-plan-update-implementation {slug}`.
```
**Verification:**
- `grep -c "Use the path the proposal was actually written to" shamt-core/host/templates/claude/commands/f1-propose-update.md` returns `1`.

### Step 3g — Exit criteria: numbered path + Number header, no branch

**Operation:** EDIT
**File:** `shamt-core/host/templates/claude/commands/f1-propose-update.md`
**Locate:**
```
- `.shamt-core/proposals/{slug}.md` exists, non-empty, no open questions, all Proposed Changes rows on canonical paths.
```
**Replace:**
```
- The proposal file (`.shamt-core/proposals/{slug}.md` on the child; `proposals/{NN}-{slug}.md` on master) exists, non-empty, no open questions, all Proposed Changes rows on canonical paths. On master the `**Number:**` header is filled. No branch is created at this phase.
```
**Verification:**
- `grep -c "On master the \`\*\*Number:\*\*\` header is filled" shamt-core/host/templates/claude/commands/f1-propose-update.md` returns `1`.

### Step 3h — Notes: master-vs-child behavior fork

**Operation:** EDIT
**File:** `shamt-core/host/templates/claude/commands/f1-propose-update.md`
**Locate:**
```
- This command is reused by child projects when they author proposals locally before `/sync-submit-proposal` ships them up. The body is identical on both sides — Phase 9 wires the child-side submission.
```
**Replace:**
```
- This command is reused by child projects when they author proposals locally before `/sync-submit-proposal` ships them up. The body is identical on both sides, but **behavior forks on the master-vs-child detection**: master assigns the `{NN}` number and writes `proposals/{NN}-{slug}.md` (Step 1 sub-step 2); the child writes an unnumbered `.shamt-core/proposals/{slug}.md` and master assigns the number later at `/sync-triage-proposals` promote. Neither side creates a branch here — branch creation moved to `/f3-implement-update`.
```
**Verification:**
- `grep -c "behavior forks on the master-vs-child detection" shamt-core/host/templates/claude/commands/f1-propose-update.md` returns `1`.

---

## Step 4 — `shamt-core/host/templates/claude/skills/f1-propose-update/SKILL.md` (row 4) — mirror the f1 command change

### Step 4a — Resolve-slug summary: exact-then-glob

**Operation:** EDIT
**File:** `shamt-core/host/templates/claude/skills/f1-propose-update/SKILL.md`
**Locate:**
```
1. **Resolve slug** to `.shamt-core/proposals/{slug}.md`. Re-entry on an existing draft = confirm extend / overwrite. Halt if `.shamt-core/proposals/archive/{slug}.md` already exists unless the user confirms a follow-up.
```
**Replace:**
```
1. **Resolve slug** (exact-then-glob): `{proposals}/{slug}.md`, else `{proposals}/*-{slug}.md` (master-side numbered `{NN}-{slug}.md`); `{proposals}` is `.shamt-core/proposals/` on the child, `proposals/` on master. Re-entry on an existing draft = confirm extend / overwrite. Halt if `{proposals}/archive/{slug}.md` or `archive/*-{slug}.md` already exists unless the user confirms a follow-up.
```
**Verification:**
- `grep -c "exact-then-glob" shamt-core/host/templates/claude/skills/f1-propose-update/SKILL.md` returns `1`.

### Step 4b — Seed summary: master assigns number, no branch

**Operation:** EDIT
**File:** `shamt-core/host/templates/claude/skills/f1-propose-update/SKILL.md`
**Locate:**
```
2. **Seed from template** at [`.shamt-core/proposals/_template.md`](../../../../../proposals/_template.md). Fill header (date, status, `Proposed by:` / `Project context:` for child-authored).
```
**Replace:**
```
2. **Seed from template** at [`.shamt-core/proposals/_template.md`](../../../../../proposals/_template.md). **Master side only:** assign `{NN}` = `max(leading NN across proposals/, archive/, deferred/, rejected/) + 1` (first is `01`, two-digit zero-padded) and write `proposals/{NN}-{slug}.md`; **no branch** (branch creation is `/f3-implement-update`'s job). Child side: unnumbered `{slug}.md`. Fill header (date, `Number:` on master / blank on child, status, `Proposed by:` / `Project context:` for child-authored).
```
**Verification:**
- `grep -c "branch creation is \`/f3-implement-update\`'s job" shamt-core/host/templates/claude/skills/f1-propose-update/SKILL.md` returns `1`.

### Step 4c — Exit criteria: numbered path

**Operation:** EDIT
**File:** `shamt-core/host/templates/claude/skills/f1-propose-update/SKILL.md`
**Locate:**
```
`.shamt-core/proposals/{slug}.md` exists, has no open questions, every Proposed Changes row points at a canonical (non-`.claude/`) path, and the next phase has been suggested.
```
**Replace:**
```
The proposal file (`.shamt-core/proposals/{slug}.md` on the child; `proposals/{NN}-{slug}.md` on master) exists, has no open questions, every Proposed Changes row points at a canonical (non-`.claude/`) path, and the next phase has been suggested.
```
**Verification:**
- `grep -c "proposals/{NN}-{slug}.md\` on master) exists, has no open questions" shamt-core/host/templates/claude/skills/f1-propose-update/SKILL.md` returns `1`.

---

## Cross-check (this phase vs. Proposed Changes rows)

| Row | File | Steps | Operation match |
|-----|------|-------|-----------------|
| 1 | CLAUDE.md | 1a, 1b | EDIT ✓ |
| 2 | _template.md | 2a, 2b, 2c | EDIT ✓ |
| 3 | f1 command | 3a–3h | EDIT ✓ |
| 4 | f1 skill | 4a, 4b, 4c | EDIT ✓ |

All four rows covered; every step is an EDIT (matches the row operations); no `.claude/` path touched; no step requires design judgment (all replacement text is exact).

**Consistency anchor:** Steps 1a, 2c, and 3c must agree on the pinned numbering facts (two-digit zero-padded, `max(^[0-9]+-)+1` across the four folders, first `01`, branch at f3). Confirm the three renderings match before exiting this phase.
