# Implementation Plan: proposal-workflow-conventions

**Proposal:** proposals/proposal-workflow-conventions.md
**Created:** 2026-06-03
**File operations:** 15 (CREATE: 0, EDIT: 15, DELETE: 0, MOVE: 0) — plus one BRANCH pre-step (Step 0), which is not a file operation.

> **On-disk path note.** This is the standalone `shamt-core` repository, so the repo root **is** `shamt-core/`. The proposal's Proposed Changes table names canonical paths with a logical `shamt-core/` prefix (e.g. `shamt-core/CLAUDE.md`); on disk those files live at the repo root **without** the prefix (`CLAUDE.md`, `host/templates/claude/...`, `proposals/_template.md`, `import-shamt.sh`, `CHEATSHEET.md`). Every **File:** and **Verification:** below uses the on-disk (repo-root-relative) path. The mapping is 1:1: `shamt-core/X` (proposal) = `X` (disk).

## Pre-execution checklist
- [ ] On a clean working tree (the in-flight proposal file `proposals/proposal-workflow-conventions.md` and this `_PLAN.md` may be present/modified; no other unrelated changes).
- [ ] `proposals/proposal-workflow-conventions.md` validation footer present (Validated 2026-06-03 — line 113).
- [ ] Branch created: `proposal/proposal-workflow-conventions` from `main` (Step 0 below). **This proposal is grandfathered/unnumbered** (it predates the convention it introduces — see the proposal's Resolved Questions, "Bootstrap"), so the branch is `proposal/{slug}` with **no** `{NN}-` prefix, not `framework-update/{slug}` and not `proposal/{NN}-{slug}`. This dogfoods the very convention the proposal pins.

## Files manifest

| # | Path (on disk) | Proposal row | Operation | Sibling / template (if any) |
|---|----------------|--------------|-----------|------------------------------|
| 1 | `CLAUDE.md` | 1 | EDIT | — |
| 2 | `proposals/_template.md` | 2 | EDIT | — |
| 3 | `host/templates/claude/commands/f1-propose-update.md` | 3 | EDIT | paired with #4 |
| 4 | `host/templates/claude/skills/f1-propose-update/SKILL.md` | 4 | EDIT | mirror of #3 |
| 5 | `host/templates/claude/commands/f2-plan-update-implementation.md` | 5 | EDIT | paired with #6 |
| 6 | `host/templates/claude/skills/f2-plan-update-implementation/SKILL.md` | 6 | EDIT | mirror of #5 |
| 7 | `host/templates/claude/commands/f3-implement-update.md` | 7 | EDIT | paired with #8 |
| 8 | `host/templates/claude/skills/f3-implement-update/SKILL.md` | 8 | EDIT | mirror of #7 |
| 9 | `host/templates/claude/commands/f6-archive-proposal.md` | 9 | EDIT | paired with #10 |
| 10 | `host/templates/claude/skills/f6-archive-proposal/SKILL.md` | 10 | EDIT | mirror of #9 |
| 11 | `host/templates/claude/commands/sync-triage-proposals.md` | 11 | EDIT | paired with #12 |
| 12 | `host/templates/claude/skills/sync-triage-proposals/SKILL.md` | 12 | EDIT | mirror of #11 |
| 13 | `CHEATSHEET.md` | 13 | EDIT | — |
| 14 | `import-shamt.sh` | 14 | EDIT | — |
| 15 | `host/templates/claude/agents/plan-executor.md` | 15 | EDIT | standalone persona, no skill mirror |

**Operation-contract reminder for the executor:** every EDIT step below gives one or more exact **Locate → Replace** pairs. Locate strings are copied verbatim from the current files, including leading whitespace and table/box alignment. If a locate string is not present exactly as written, **halt and report — do not approximate** (per the `plan-executor` EDIT contract). Several steps bundle multiple Locate/Replace pairs in the same file; apply them in the order given.

---

## Step-by-step

### Step 0 — Create the proposal branch

**Operation:** BRANCH
**Details:**
- Run: `git checkout -b proposal/proposal-workflow-conventions` from `main` (the base branch framework changes land on).
- If the branch already exists, halt and report instead of overwriting/resetting it.
- Grandfathered proposal → unnumbered branch name `proposal/proposal-workflow-conventions` (no `{NN}-`).

**Verification:** `git rev-parse --abbrev-ref HEAD` prints `proposal/proposal-workflow-conventions`.

---

### Step 1 — CLAUDE.md: pin the Conventions section and reconcile the out-of-scope line (row 1)

**Operation:** EDIT
**File:** `CLAUDE.md`

**Locate (1a — the TBD section):**
```
## Commit conventions (TBD)

Not pinned yet. Decide before the first feature commit and document here.
```
**Replace:**
```
## Conventions

Pinned 2026-06-03 (proposal `proposal-workflow-conventions`). The authoritative mechanics live in the `/f1-propose-update` and `/f6-archive-proposal` command bodies; this section is the concise overview.

- **Commit subject** — one squash commit per proposal: `shamt-core: land #NN {slug} (short description)`. A grandfathered/unnumbered proposal drops the `#NN`: `shamt-core: land {slug} (short description)`.
- **Proposal number** — a lightweight organizational ID, **master-side only**. Proposals are filename-prefixed `proposals/{NN}-{slug}.md` with a matching `**Number:**` header. The number is two-digit zero-padded (`01`, `02`, … widening to three digits only past `99`), assigned at `/f1-propose-update` (master-local) or `/sync-triage-proposals` promote (child-submitted) as `max(existing NN across proposals/, proposals/archive/, proposals/deferred/, proposals/rejected/) + 1`. There is no counter file — the max is scanned from disk, parsing a leading `^[0-9]+-` run on each filename (so unnumbered/grandfathered files contribute nothing and the first number assigned is `01`), and numbers are never reused. Child-side proposals stay unnumbered (`.shamt-core/proposals/{slug}.md`); numbering happens only on master. This is the lightweight org-ID permitted by the out-of-scope note above — **not** a SHAMT-N design-doc lifecycle.
- **Branch per proposal** — `proposal/{NN}-{slug}` (`proposal/{slug}` for a grandfathered/unnumbered proposal), created by `/f3-implement-update` from the base branch immediately before the canonical edits. Authoring, validation, and planning happen on the base branch; the proposal branch exists only for the implement→merge window.
- **Archive commits + merges** — `/f6-archive-proposal` commits the canonical edits + regen output + archive move, squash-merges `proposal/{NN}-{slug}` into the base branch as the single commit above, then deletes the branch.
```

**Locate (1b — the out-of-scope line):**
```
- **No SHAMT-N numbering for framework changes.** Proposal slugs are descriptive.
```
**Replace:**
```
- **No SHAMT-N design-doc lifecycle.** Proposals carry a lightweight filename-prefixed organizational **number** (`{NN}-{slug}.md`, master-side only — see the Conventions section below) purely as a stable, `ls`-ordered identifier. Slugs remain the primary descriptive identifier. This is *not* a revival of v1's heavyweight SHAMT-N design-doc lifecycle (per-doc statuses, state machine, numbering ceremony).
```

**Verification:**
- `grep -F '## Conventions' CLAUDE.md` returns one match.
- `grep -F 'No SHAMT-N design-doc lifecycle' CLAUDE.md` returns one match.
- `grep -c 'Commit conventions (TBD)' CLAUDE.md` returns 0.

---

### Step 2 — proposals/_template.md: add the Number header and document the numbering/branch convention (row 2)

**Operation:** EDIT
**File:** `proposals/_template.md`

**Locate (2a — the ASCII layout box; copied verbatim incl. alignment):**
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
  proposals/                                    (master-side filenames shown; child-side stay unnumbered {slug}.md)
  ├── _template.md                              (this file — copy when authoring a new proposal)
  ├── {NN}-{slug}.md                            (active proposals — Phase 1 through Phase 4)
  ├── {NN}-{slug}_PLAN.md                       (Phase 3 plan, only for proposals >10 file ops)
  ├── archive/{NN}-{slug}.md                    (post-implementation, set by /f6-archive-proposal)
  ├── archive/{NN}-{slug}.draft-{timestamp}.md  (abandoned drafts, set by /f1-propose-update on start-over re-entry)
  ├── rejected/{NN}-{slug}.md                   (explicit rejections with a top-of-file note)
  └── deferred/{NN}-{slug}.md                   (on hold)
```

**Locate (2b — the comment's closing prose + the `-->` terminator):**
```
rejected/ and deferred/ folders are populated manually by the user (or by
/sync-triage-proposals on the master side, when that ships).
-->
```
**Replace:**
```
rejected/ and deferred/ folders are populated manually by the user (or by
/sync-triage-proposals on the master side, when that ships).

Numbering + branch convention (master-side only; see shamt-core/CLAUDE.md
§Conventions): each master-side proposal carries a filename prefix {NN}- and a
matching **Number:** header, assigned as max(existing NN across proposals/,
archive/, deferred/, rejected/) + 1 at /f1-propose-update (master-local) or
/sync-triage-proposals promote (child-submitted). Child-side proposals under
.shamt-core/proposals/ stay unnumbered {slug}.md. /f3-implement-update creates
the proposal/{NN}-{slug} branch; /f6-archive-proposal squash-merges it to the
base branch and deletes it.
-->
```

**Locate (2c — the header block):**
```
**Created:** [YYYY-MM-DD]
**Status:** Draft
**Proposed by:** [Project name, or blank for master-local proposals]
**Project context:** [One-line context for child-submitted proposals; blank for master-local]
```
**Replace:**
```
**Created:** [YYYY-MM-DD]
**Status:** Draft
**Number:** [NN — master-side only; assigned by /f1-propose-update or /sync-triage-proposals promote. Blank/omitted on the child side and for grandfathered proposals.]
**Proposed by:** [Project name, or blank for master-local proposals]
**Project context:** [One-line context for child-submitted proposals; blank for master-local]
```

**Verification:**
- `grep -F '**Number:**' proposals/_template.md` returns one match.
- `grep -F '{NN}-{slug}.md' proposals/_template.md` returns at least one match.
- `grep -F 'Numbering + branch convention' proposals/_template.md` returns one match.

---

### Step 3 — f1 command: add the master-side-guarded number-assignment step (row 3, part 1)

**Operation:** EDIT
**File:** `host/templates/claude/commands/f1-propose-update.md`

**Locate (3a — the Step 1 skip-banner):**
```
> **Input Mode 3 (existing f0 draft): skip this step.** The f0 file already follows the template shape — per Slug resolution, just normalize `Status:` to plain `Draft`, drop the f0 banner, and resume at Step 2 using the Scratch Notes as the seed.
```
**Replace:**
```
> **Input Mode 3 (existing f0 draft): skip this step** for the template-seed — the f0 file already follows the template shape — but **still run the master-side number-assignment sub-step (items 5–6 below)**: an f0 draft is unnumbered, so on master it must be numbered + renamed during ingestion. Per Slug resolution, normalize `Status:` to plain `Draft`, drop the f0 banner, and resume at Step 2 using the Scratch Notes as the seed.
```

**Locate (3b — Step 1 item 4):**
```
4. **Input Mode 2 (blurb passed):** drop the blurb verbatim into the Problem section as raw starting material — Step 2 sharpens it against the canonical sources.
```
**Replace:**
```
4. **Input Mode 2 (blurb passed):** drop the blurb verbatim into the Problem section as raw starting material — Step 2 sharpens it against the canonical sources.
5. **Assign the proposal number — master-side only (guard).** This sub-step runs **only on the master side**, gated behind the same master-vs-child detection the Prerequisites already use (master = the repo with a top-level `proposals/` directory; child = the `.shamt-core/`-synced project root).
   - **On the child side:** skip number assignment entirely. The proposal stays unnumbered at `.shamt-core/proposals/{slug}.md` — no `**Number:**` header, no filename prefix. Numbering happens only on master; `/sync-triage-proposals` assigns it at promote time.
   - **On the master side** (top-level `proposals/`): scan every folder a numbered proposal can come to rest in — `proposals/`, `proposals/archive/`, `proposals/deferred/`, `proposals/rejected/` (**not** `proposals/incoming/`, which holds still-unnumbered child submissions). For each filename, parse a leading `^[0-9]+-` digit run; the proposal number is `max(parsed NN) + 1`, or `01` when no numbered file exists (unnumbered/grandfathered files contribute nothing to the max). Format two-digit zero-padded (`01`, `02`, … widening to three digits only past `99`). There is no counter file — re-scan disk each time.
   - Write the `**Number:** {NN}` header into the proposal and **name the file with the `{NN}-` prefix**: `proposals/{NN}-{slug}.md`. If the Step 1 item 2 copy (or the Mode-3 ingested f0 file) wrote an unnumbered `{slug}.md`, rename it now (`git mv` when tracked).
6. **Branch creation is NOT f1's job** (either side). Authoring, validation, and planning all happen on the base branch; `/f3-implement-update` creates the `proposal/{NN}-{slug}` branch immediately before the canonical edits. Do not create or switch branches here.
```

**Verification:**
- `grep -F 'Assign the proposal number — master-side only (guard).' host/templates/claude/commands/f1-propose-update.md` returns one match.
- `grep -F 'Branch creation is NOT f1' host/templates/claude/commands/f1-propose-update.md` returns one match.

---

### Step 4 — f1 command: glob slug-resolution, glob archive-collision, and number-aware next-phase path (row 3, part 2)

**Operation:** EDIT
**File:** `host/templates/claude/commands/f1-propose-update.md`

**Locate (4a — Slug resolution first bullet):**
```
- Try `.shamt-core/proposals/{slug}.md` (exact match).
```
**Replace:**
```
- Try `.shamt-core/proposals/{slug}.md` (exact match), then the numbered glob `.shamt-core/proposals/*-{slug}.md` (master-side proposals carry a `{NN}-` filename prefix). A bare numbered stem `{NN}-{slug}` passed as the slug resolves directly. Slugs are unique, so the glob matches **at most one** file; per the established "halt and ask on multiple matches" invariant, halt if it ever matches more than one.
```

**Locate (4b — the archive-collision bullet):**
```
- **`.shamt-core/proposals/archive/{slug}.md` exists** — a proposal with this slug was already implemented. Halt, report the archive location, and ask the user to pick a different slug or explicitly confirm they want a follow-up proposal under the same slug (uncommon).
```
**Replace:**
```
- **`.shamt-core/proposals/archive/{slug}.md` or `.shamt-core/proposals/archive/*-{slug}.md` exists** (exact or numbered-prefix match) — a proposal with this slug was already implemented. Halt, report the archive location, and ask the user to pick a different slug or explicitly confirm they want a follow-up proposal under the same slug (uncommon).
```

**Locate (4c — Step 7 next-phase suggestions):**
```
- Row count ≤ 10 → `/clear`, then `/validate-artifact .shamt-core/proposals/{slug}.md`.
- Row count > 10 → `/clear`, then `/validate-artifact .shamt-core/proposals/{slug}.md`, then `/f2-plan-update-implementation {slug}`.
```
**Replace:**
```
- Row count ≤ 10 → `/clear`, then `/validate-artifact {path}`, where `{path}` is the proposal's actual on-disk path (`proposals/{NN}-{slug}.md` on master, `.shamt-core/proposals/{slug}.md` on child).
- Row count > 10 → `/clear`, then `/validate-artifact {path}` (same path), then `/f2-plan-update-implementation {slug}` (resolves the proposal by bare slug or numbered stem).
```

**Verification:**
- `grep -F '.shamt-core/proposals/*-{slug}.md' host/templates/claude/commands/f1-propose-update.md` returns at least one match.
- `grep -F 'archive/*-{slug}.md' host/templates/claude/commands/f1-propose-update.md` returns at least one match.
- `grep -F "the proposal's actual on-disk path" host/templates/claude/commands/f1-propose-update.md` returns one match.

---

### Step 5 — f1 skill: mirror the f1 command change (row 4)

**Operation:** EDIT
**File:** `host/templates/claude/skills/f1-propose-update/SKILL.md`

**Locate (5a — resolve-slug lead-in):**
```
1. **Resolve slug** to `.shamt-core/proposals/{slug}.md`. **Three input modes:**
```
**Replace:**
```
1. **Resolve slug** to `.shamt-core/proposals/{slug}.md` (exact-then-numbered-glob `*-{slug}.md`; master-side proposals carry a `{NN}-` prefix). **Three input modes:**
```

**Locate (5b — the archive halt clause):**
```
Halt if `.shamt-core/proposals/archive/{slug}.md` already exists unless the user confirms a follow-up.
```
**Replace:**
```
Halt if `.shamt-core/proposals/archive/{slug}.md` (or numbered `archive/*-{slug}.md`) already exists unless the user confirms a follow-up.
```

**Locate (5c — Seed-from-template item 2):**
```
2. **Seed from template** at [`.shamt-core/proposals/_template.md`](../../../../../proposals/_template.md). Fill header (date, status, `Proposed by:` / `Project context:` for child-authored). **Mode 3 skips this step** — the f0 file already follows the template shape.
```
**Replace:**
```
2. **Seed from template** at [`.shamt-core/proposals/_template.md`](../../../../../proposals/_template.md). Fill header (date, status, `Proposed by:` / `Project context:` for child-authored). **Mode 3 skips this step** — the f0 file already follows the template shape. **Master-side only (guarded):** assign the proposal **Number** (`max(existing NN across proposals/, archive/, deferred/, rejected/) + 1`, two-digit zero-padded, no counter file) — write the `**Number:**` header and the `{NN}-` filename prefix (`proposals/{NN}-{slug}.md`), renaming an unnumbered seed/f0 file. Child-side proposals stay unnumbered. **Branch creation is NOT f1's job** — `/f3-implement-update` creates `proposal/{NN}-{slug}`.
```

**Locate (5d — Suggest-next-phase item 8):**
```
8. **Suggest next phase** — `/clear` + `/validate-artifact .shamt-core/proposals/{slug}.md` (and `/f2-plan-update-implementation {slug}` when row count > 10).
```
**Replace:**
```
8. **Suggest next phase** — `/clear` + `/validate-artifact {resolved path}` (`proposals/{NN}-{slug}.md` on master, `.shamt-core/proposals/{slug}.md` on child), and `/f2-plan-update-implementation {slug}` when row count > 10.
```

**Verification:**
- `grep -F 'Master-side only (guarded):' host/templates/claude/skills/f1-propose-update/SKILL.md` returns one match.
- `grep -F 'archive/*-{slug}.md' host/templates/claude/skills/f1-propose-update/SKILL.md` returns at least one match.

---

### Step 6 — f2 command: glob path resolution + reconcile the embedded plan-shape branch line (row 5)

**Operation:** EDIT
**File:** `host/templates/claude/commands/f2-plan-update-implementation.md`

**Locate (6a — the Arguments line):**
```
- `{slug}` (required) — proposal slug. Resolves to `proposals/{slug}.md` (the validated proposal) and writes `proposals/{slug}_PLAN.md` (the implementation plan).
```
**Replace:**
```
- `{slug}` (required) — proposal slug, resolvable from the bare descriptive slug or the numbered stem `{NN}-{slug}`. Resolves the validated proposal exact-then-glob — `proposals/{slug}.md`, then `proposals/*-{slug}.md` (master-side proposals carry a `{NN}-` filename prefix; the glob matches at most one, halt on multiple). Writes the plan alongside it with the **same stem**: `proposals/{NN}-{slug}_PLAN.md` (or `proposals/{slug}_PLAN.md` for a grandfathered/unnumbered proposal).
```

**Locate (6b — the embedded plan-shape pre-execution-checklist branch line):**
```
- [ ] Branch created: `framework-update/{slug}` from the configured remote development branch.
```
**Replace:**
```
- [ ] Branch created by `/f3-implement-update`: `proposal/{NN}-{slug}` (`proposal/{slug}` for a grandfathered/unnumbered proposal) from the base branch, immediately before the canonical edits. (Authoring/validation/planning happen on the base branch; the architect/builder path's executor creates this branch when it runs this pre-execution checklist at Phase 4.)
```

**Verification:**
- `grep -F 'proposals/{NN}-{slug}_PLAN.md' host/templates/claude/commands/f2-plan-update-implementation.md` returns at least one match.
- `grep -F 'Branch created by `/f3-implement-update`' host/templates/claude/commands/f2-plan-update-implementation.md` returns one match.
- `grep -c 'framework-update/{slug}' host/templates/claude/commands/f2-plan-update-implementation.md` returns 0.

---

### Step 7 — f2 skill: mirror the f2 path-resolution change (row 6)

**Operation:** EDIT
**File:** `host/templates/claude/skills/f2-plan-update-implementation/SKILL.md`

**Locate (7a — author-the-plan lead-in):**
```
2. **Author the plan** at `proposals/{slug}_PLAN.md` using
```
**Replace:**
```
2. **Author the plan** at `proposals/{NN}-{slug}_PLAN.md` (same stem as the proposal; `proposals/{slug}_PLAN.md` when grandfathered/unnumbered) using
```

**Locate (7b — exit-criteria lead-in):**
```
`proposals/{slug}_PLAN.md` (or index + phase files) exists with one step
```
**Replace:**
```
`proposals/{NN}-{slug}_PLAN.md` (numbered stem; `{slug}_PLAN.md` when grandfathered) (or index + phase files) exists with one step
```

**Verification:**
- `grep -F 'proposals/{NN}-{slug}_PLAN.md' host/templates/claude/skills/f2-plan-update-implementation/SKILL.md` returns at least one match.

---

### Step 8 — f3 command: glob resolution, prerequisite branch reconcile, and commit-timing note (row 7, part 1)

**Operation:** EDIT
**File:** `host/templates/claude/commands/f3-implement-update.md`

**Locate (8a — the Arguments line):**
```
- `{slug}` (required) — proposal slug. Resolves to `proposals/{slug}.md` and (optionally) `proposals/{slug}_PLAN.md` or phase-decomposed plan files.
```
**Replace:**
```
- `{slug}` (required) — proposal slug (bare descriptive slug or numbered stem `{NN}-{slug}`). Resolves the proposal exact-then-glob — `proposals/{slug}.md`, then `proposals/*-{slug}.md` (master-side proposals carry a `{NN}-` prefix; matches at most one, halt on multiple) — and the companion `proposals/{NN}-{slug}_PLAN.md` (or phase files) with the same stem.
```

**Locate (8b — the clean-tree prerequisite):**
```
- Working tree is clean (or the user has confirmed working on a dedicated `framework-update/{slug}` branch). Halt and confirm if the tree has unrelated staged or unstaged changes.
```
**Replace:**
```
- Working tree is clean except for the proposal/plan files. Halt and confirm if the tree has unrelated staged or unstaged changes. (Authoring/validation/planning ran on the base branch; this command creates the proposal branch — see Step 1.5.)
```

**Locate (8c — the "No commits here" note):**
```
- **No commits here.** This command leaves changes in the working tree. The user commits explicitly after Phase 5 (regen) confirms the propagation worked, so the canonical edit and the generated `.claude/` update land in one commit.
```
**Replace:**
```
- **No commits here.** This command creates the `proposal/{NN}-{slug}` branch (Step 1.5) and leaves the canonical edits uncommitted in the working tree — creating a branch is not a commit. The commit + squash-merge to the base branch now land at `/f6-archive-proposal` (Phase 7), after `/f4-regen-framework` (Phase 5) has propagated the canonical edits into `.claude/`, so the canonical edit, the regen output, and the archive move land together in one squash commit.
```

**Verification:**
- `grep -F 'proposals/*-{slug}.md' host/templates/claude/commands/f3-implement-update.md` returns at least one match.
- `grep -c 'framework-update/{slug}' host/templates/claude/commands/f3-implement-update.md` returns 0.
- `grep -F 'see Step 1.5' host/templates/claude/commands/f3-implement-update.md` returns one match.

---

### Step 9 — f3 command: add the branch-creation step (row 7, part 2)

**Operation:** EDIT
**File:** `host/templates/claude/commands/f3-implement-update.md`

**Locate (the Step 2 header — insert the new step immediately before it):**
```
### Step 2 — Apply edits
```
**Replace:**
```
### Step 1.5 — Create the proposal branch

Branch creation moved to this command — it is **not** done at `/f1-propose-update` or `/sync-triage-proposals`. Create the branch from the base branch immediately before applying canonical edits:

- **Branch name:** `proposal/{NN}-{slug}` using the proposal's resolved numbered stem (`proposal/{slug}` for a grandfathered/unnumbered proposal with no `{NN}-` prefix). Read numbered-ness from the resolved filename's leading `^[0-9]+-` run: present = numbered, absent = grandfathered.
- **Inline path:** create it directly — `git checkout -b proposal/{NN}-{slug}` from the base branch (the branch framework changes land on). Halt and report if the branch already exists.
- **Architect/builder path:** do **not** create it here — the validated plan's pre-execution checklist declares the branch, and `plan-executor` creates it when it runs that checklist (pre-flight Step 4). Confirm the plan's pre-execution checklist names `proposal/{NN}-{slug}` before handing off.

Creating a branch is not a commit — the "No commits here" rule (Notes) still holds. The commit + squash-merge happen later at `/f6-archive-proposal` (Phase 7).

### Step 2 — Apply edits
```

**Verification:**
- `grep -F '### Step 1.5 — Create the proposal branch' host/templates/claude/commands/f3-implement-update.md` returns one match.
- `grep -c '### Step 2 — Apply edits' host/templates/claude/commands/f3-implement-update.md` returns 1 (not duplicated).

---

### Step 10 — f3 skill: mirror the f3 changes (row 8)

**Operation:** EDIT
**File:** `host/templates/claude/skills/f3-implement-update/SKILL.md`

**Locate (10a — Preflight item 1):**
```
1. **Preflight** — confirm `proposals/{slug}.md` has a validation footer; confirm `{slug}_PLAN.md` (when present) has one; halt if `proposals/archive/{slug}.md` exists; halt if working tree is dirty with unrelated changes.
```
**Replace:**
```
1. **Preflight** — resolve the proposal exact-then-glob (`proposals/{slug}.md`, then `proposals/*-{slug}.md` for the master-side `{NN}-` prefix); confirm it has a validation footer; confirm the companion `{NN}-{slug}_PLAN.md` (when present) has one; halt if `proposals/archive/{slug}.md` (or `archive/*-{slug}.md`) exists; halt if working tree is dirty with unrelated changes.
```

**Locate (10b — Path-selection item 2):**
```
2. **Path selection** — inline (≤10 file ops, no plan) or architect/builder (plan present, handoff to `plan-executor`). State the choice in one line.
```
**Replace:**
```
2. **Path selection** — inline (≤10 file ops, no plan) or architect/builder (plan present, handoff to `plan-executor`). State the choice in one line. **Then create the proposal branch** `proposal/{NN}-{slug}` (`proposal/{slug}` grandfathered) from the base branch — inline path creates it directly (halt if it exists); architect/builder path lets `plan-executor` create it from the plan's pre-execution checklist. Branch creation moved here from f1/sync-triage; it is not a commit.
```

**Locate (10c — exit criteria):**
```
Every Proposed Changes row covered by a real diff entry; no generated-file edits; `/f4-regen-framework` suggested. No commits — the user commits after regen confirms propagation.
```
**Replace:**
```
Every Proposed Changes row covered by a real diff entry; no generated-file edits; `/f4-regen-framework` suggested. This command creates the `proposal/{NN}-{slug}` branch (or `proposal/{slug}` grandfathered) before editing but makes **no commit** — the commit + squash-merge to the base branch land at `/f6-archive-proposal` (Phase 7), after regen.
```

**Verification:**
- `grep -F 'Then create the proposal branch' host/templates/claude/skills/f3-implement-update/SKILL.md` returns one match.
- `grep -F 'proposals/*-{slug}.md' host/templates/claude/skills/f3-implement-update/SKILL.md` returns at least one match.

---

### Step 11 — f6 command: model bump, glob resolution, numbered-ness, archive move (row 9, part 1)

**Operation:** EDIT
**File:** `host/templates/claude/commands/f6-archive-proposal.md`

**Locate (11a — Recommended model):**
```
**Recommended model:** Cheap (Haiku). Archiving is mechanical: a file move and a status update. See [`reference/model_selection.md`](../../../../reference/model_selection.md).
```
**Replace:**
```
**Recommended model:** Balanced (Sonnet). Archiving now performs an irreversible git-state mutation — it commits the change, squash-merges the `proposal/{NN}-{slug}` branch into the base branch, and deletes the branch — gated behind pre-merge guards that must be evaluated, not just a file move and a status update. See [`reference/model_selection.md`](../../../../reference/model_selection.md).
```

**Locate (11b — the Arguments line):**
```
- `{slug}` (required) — proposal slug. Resolves to `proposals/{slug}.md` (the implemented proposal) and `proposals/archive/{slug}.md` (the destination).
```
**Replace:**
```
- `{slug}` (required) — proposal slug (bare descriptive slug or numbered stem `{NN}-{slug}`). Resolves the implemented proposal exact-then-glob — `proposals/{slug}.md`, then `proposals/*-{slug}.md` (master-side proposals carry a `{NN}-` prefix; matches at most one, halt on multiple) — and archives it to `proposals/archive/{resolved-filename}`, preserving the `{NN}-` prefix (or its absence for a grandfathered proposal).
```

**Locate (11c — the re-archive prerequisite):**
```
- `proposals/archive/{slug}.md` does **not** already exist. If it does, halt and report — this slug was already archived. A re-archival would either overwrite the prior record or shadow it depending on filesystem semantics; neither is safe.
```
**Replace:**
```
- `proposals/archive/{slug}.md` (or numbered `proposals/archive/*-{slug}.md`) does **not** already exist. If it does, halt and report — this slug was already archived. A re-archival would either overwrite the prior record or shadow it depending on filesystem semantics; neither is safe.
```

**Locate (11d — Step 1 item 1):**
```
1. Read `proposals/{slug}.md` top-to-bottom. Confirm the validation footer is present (`Validated YYYY-MM-DD — N rounds[, 1 adversarial sub-agent confirmed]`).
```
**Replace:**
```
1. Resolve and read the proposal (exact-then-glob per Arguments). Confirm the validation footer is present (`Validated YYYY-MM-DD — N rounds[, 1 adversarial sub-agent confirmed]`). **Determine numbered-ness** from the resolved filename's leading `^[0-9]+-` digit run: present = numbered (`{NN}-{slug}`, commit subject includes `#NN`, branch `proposal/{NN}-{slug}`); absent = grandfathered (`{slug}`, commit subject drops `#NN`, branch `proposal/{slug}`).
```

**Locate (11e — Step 2 items 2–3):**
```
2. Move `proposals/{slug}.md` → `proposals/archive/{slug}.md` (use `git mv` when the proposal is tracked; plain `mv` when untracked).
3. Move any `{slug}_PLAN.md` / `{slug}_PLAN_phase_*.md` companions to `proposals/archive/` alongside the proposal.
```
**Replace:**
```
2. Move the resolved proposal file → `proposals/archive/{same-filename}` (preserving the `{NN}-` prefix when present; use `git mv` when the proposal is tracked, plain `mv` when untracked).
3. Move any companion `{NN}-{slug}_PLAN.md` / `{NN}-{slug}_PLAN_phase_*.md` (or the unnumbered forms for a grandfathered proposal) to `proposals/archive/` alongside the proposal.
```

**Verification:**
- `grep -F '**Recommended model:** Balanced (Sonnet).' host/templates/claude/commands/f6-archive-proposal.md` returns one match.
- `grep -F 'Determine numbered-ness' host/templates/claude/commands/f6-archive-proposal.md` returns one match.
- `grep -F 'proposals/*-{slug}.md' host/templates/claude/commands/f6-archive-proposal.md` returns at least one match.

---

### Step 12 — f6 command: replace Step 3 with commit + squash-merge + branch-delete, and update exit criteria (row 9, part 2)

**Operation:** EDIT
**File:** `host/templates/claude/commands/f6-archive-proposal.md`

**Locate (12a — the entire Step 3 block, including its fenced code):**
````
### Step 3 — Commit suggestion

The archive is a logical commit point. Suggest a `git status` / `git diff` review followed by a commit, e.g.:

```text
git add proposals/archive/{slug}.md  # plus the canonical-source edits + .claude/ regen output
git commit -m "framework: implement {slug}"
```

Do not commit on behalf of the user — the canonical edits, the regen output, and the archive should ideally land together so a single revert undoes the whole change, and the user's commit conventions / signing / hook setup take over.
````
**Replace:**
````
### Step 3 — Commit, squash-merge, and delete the branch

The archive is the landing point. `/f6-archive-proposal` now commits the change, squash-merges the proposal branch into the base branch, and deletes the branch — replacing the old "suggest a commit, don't run it" behavior. This is an irreversible git-state mutation; evaluate every pre-merge guard before touching git, and **halt** (do not merge) on any failure.

**Pre-merge guards** (all must hold):

- [ ] HEAD is on the proposal branch — `proposal/{NN}-{slug}` for a numbered proposal, `proposal/{slug}` for a grandfathered one (Step 1 determined which). If not, halt and report.
- [ ] The working tree contains exactly the expected change: the canonical-source edits the proposal described, the archive move (Step 2), and the `.claude/` regen output from Phase 5. No unrelated staged/unstaged changes — run `git status` and confirm.
- [ ] `/f4-regen-framework` has run (or the proposal explicitly required no regen). If `.claude/` is out of sync with the canonical edits, halt and direct the user to run `/f4-regen-framework` first.
- [ ] The base branch (`main` for shamt-core) exists and the proposal branch is a descendant of it (a clean squash-merge target).

**Commit + merge** (only after every guard holds):

1. Stage and commit the change on the proposal branch. **Commit subject** (per `shamt-core/CLAUDE.md` §Conventions; derive the short description from the proposal title / Problem):
   - Numbered: `shamt-core: land #{NN} {slug} (short description)`
   - Grandfathered/unnumbered: `shamt-core: land {slug} (short description)`
2. Squash-merge the proposal branch into the base branch as the **single** commit above:

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
````

**Locate (12b — the exit-criteria bullets):**
```
- `proposals/{slug}.md` (and companions) moved to `proposals/archive/` with validation footers intact.
- The user has been prompted (but not forced) to commit the change.
```
**Replace:**
```
- `proposals/{slug}.md` (and companions) moved to `proposals/archive/` with validation footers intact, preserving the `{NN}-` prefix.
- The change has been committed and squash-merged to the base branch, and the `proposal/{NN}-{slug}` branch deleted (after all pre-merge guards held).
```

**Verification:**
- `grep -F '### Step 3 — Commit, squash-merge, and delete the branch' host/templates/claude/commands/f6-archive-proposal.md` returns one match.
- `grep -F 'git merge --squash proposal/{NN}-{slug}' host/templates/claude/commands/f6-archive-proposal.md` returns one match.
- `grep -c 'Commit suggestion' host/templates/claude/commands/f6-archive-proposal.md` returns 0.

---

### Step 13 — f6 skill: mirror the f6 changes (row 10)

**Operation:** EDIT
**File:** `host/templates/claude/skills/f6-archive-proposal/SKILL.md`

**Locate (13a — Recommended model):**
```
Cheap (Haiku) — archive is mechanical: file move and status update. See [`reference/model_selection.md`](../../../../../reference/model_selection.md).
```
**Replace:**
```
Balanced (Sonnet) — archiving now commits, squash-merges the `proposal/{NN}-{slug}` branch into the base branch, and deletes the branch behind pre-merge guards — an irreversible git-state mutation, not just a file move. See [`reference/model_selection.md`](../../../../../reference/model_selection.md).
```

**Locate (13b — the protocol items 1–3):**
```
1. **Read and confirm** — `proposals/{slug}.md` exists with a validation footer. Check for companions (`{slug}_PLAN.md`, `{slug}_PLAN_phase_N.md`); each must also carry a footer. Update the proposal's `Status:` header to `Implemented`.
2. **Move to archive** — ensure `proposals/archive/` exists; `git mv` (when tracked) or plain `mv` the proposal and companions into it. Confirm footers intact post-move. Halt if `proposals/archive/{slug}.md` already exists.
3. **Commit suggestion** — do not commit on the user's behalf. Suggest a `git status` / `git diff` review + a unified commit covering canonical edits + regen output + archive.
```
**Replace:**
```
1. **Read and confirm** — resolve the proposal exact-then-glob (`proposals/{slug}.md`, then `proposals/*-{slug}.md` for the master-side `{NN}-` prefix); confirm a validation footer. Check for companions (`{NN}-{slug}_PLAN.md`, `{NN}-{slug}_PLAN_phase_N.md`); each must also carry a footer. **Determine numbered-ness** from the resolved filename's leading `^[0-9]+-` run (present = numbered, drives the `#NN` commit subject + `proposal/{NN}-{slug}` branch; absent = grandfathered, drops `#NN`, branch `proposal/{slug}`). Update `Status:` to `Implemented`.
2. **Move to archive** — ensure `proposals/archive/` exists; `git mv` (tracked) or `mv` the proposal + companions into it, **preserving the `{NN}-` prefix**. Confirm footers intact post-move. Halt if `proposals/archive/{slug}.md` (or `archive/*-{slug}.md`) already exists.
3. **Commit + squash-merge + delete branch** — behind pre-merge guards (HEAD on the proposal branch; working tree is exactly the canonical edits + archive move + regen output; regen has run; branch is a descendant of base). Commit with subject `shamt-core: land #{NN} {slug} (…)` (drop `#{NN}` when grandfathered), `git merge --squash` the proposal branch into the base branch as that one commit, then `git branch -D` the proposal branch **only after the merge commit succeeds**. Halt on any guard failure or git error.
```

**Locate (13c — exit criteria):**
```
Proposal (and companions) at `proposals/archive/{slug}.md` with footers intact; commit prompted but not executed.
```
**Replace:**
```
Proposal (and companions) at `proposals/archive/{NN}-{slug}.md` with footers intact; the change committed + squash-merged to the base branch and the `proposal/{NN}-{slug}` branch deleted (after all guards held).
```

**Verification:**
- `grep -F 'Balanced (Sonnet) — archiving now commits' host/templates/claude/skills/f6-archive-proposal/SKILL.md` returns one match.
- `grep -F 'Commit + squash-merge + delete branch' host/templates/claude/skills/f6-archive-proposal/SKILL.md` returns one match.

---

### Step 14 — sync-triage command: assign the master-side number on promote, no branch (row 11, part 1)

**Operation:** EDIT
**File:** `host/templates/claude/commands/sync-triage-proposals.md`

**Locate (14a — the Promote sub-block of Step 2d):**
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
2. **Assign the master-side number.** Scan every folder a numbered proposal can come to rest in — `proposals/`, `proposals/archive/`, `proposals/deferred/`, `proposals/rejected/` (**not** `proposals/incoming/`, which still holds unnumbered child submissions). Parse the leading `^[0-9]+-` digit run on each filename; the number is `max(parsed NN) + 1`, or `01` when none is numbered. Format two-digit zero-padded (widening to three digits past `99`). **Re-read from disk per promote** — never cache `max(NN)` across promotes, or two proposals promoted in the same run would collide. This is the same algorithm `/f1-propose-update` uses for master-local proposals (one shared master namespace).
3. Halt if `proposals/{slug}.md` or `proposals/*-{slug}.md` already exists — slug collision, the user must resolve manually (rename one or re-author).
4. `git mv proposals/incoming/{filename} proposals/{NN}-{slug}.md` (or plain `mv` if untracked) — apply the `{NN}-` prefix. Also write the `**Number:** {NN}` header into the promoted proposal.
5. Confirm the validation footer (if present) is intact post-move.
6. **No branch.** Branch creation is deferred to `/f3-implement-update` for all proposals (master-local and promoted alike), so triage stays a pure router — it assigns the number and moves the file, nothing more.
7. Note in chat the next command to run: `/validate-artifact proposals/{NN}-{slug}.md`. Do not invoke it from this command — phase-per-command resumability (Principle 1) keeps every phase independently runnable by a fresh agent.
```

**Verification:**
- `grep -F 'Assign the master-side number.' host/templates/claude/commands/sync-triage-proposals.md` returns one match.
- `grep -F 'Re-read from disk per promote' host/templates/claude/commands/sync-triage-proposals.md` returns one match.
- `grep -F '6. **No branch.**' host/templates/claude/commands/sync-triage-proposals.md` returns one match.

---

### Step 15 — sync-triage command: number-aware next-command paths in the summary + exit criteria (row 11, part 2)

**Operation:** EDIT
**File:** `host/templates/claude/commands/sync-triage-proposals.md`

**Locate (15a — the one-promoted `Next:` block; copy verbatim incl. 2/4-space indents):**
```
  Next:
    /clear
    /validate-artifact proposals/{slug}.md
```
**Replace:**
```
  Next:
    /clear
    /validate-artifact proposals/{NN}-{slug}.md
```

**Locate (15b — the two-or-more handoff-prompt clause):**
```
fill the template in [`reference/batch_validation_handoff.md`](../../../../reference/batch_validation_handoff.md) with the actual promoted `proposals/{slug}.md` paths (each with its governing references)
```
**Replace:**
```
fill the template in [`reference/batch_validation_handoff.md`](../../../../reference/batch_validation_handoff.md) with the actual promoted `proposals/{NN}-{slug}.md` paths (each with its governing references)
```

**Locate (15c — the fallback list, first slug line):**
```
    /validate-artifact proposals/{slug-1}.md
```
**Replace:**
```
    /validate-artifact proposals/{NN}-{slug-1}.md
```

**Locate (15d — the fallback list, second slug line):**
```
    /validate-artifact proposals/{slug-2}.md
```
**Replace:**
```
    /validate-artifact proposals/{NN}-{slug-2}.md
```

**Locate (15e — the exit-criteria bullet):**
```
- For each promoted slug, the next command (`/validate-artifact proposals/{slug}.md`) has been stated.
```
**Replace:**
```
- For each promoted slug, the next command (`/validate-artifact proposals/{NN}-{slug}.md`) has been stated.
```

**Locate (15f — the Purpose statement's promote clause):**
```
**promote** (move to `proposals/{slug}.md` and hand off to the framework-update flow starting at Phase 2)
```
**Replace:**
```
**promote** (move to `proposals/{NN}-{slug}.md` and hand off to the framework-update flow starting at Phase 2)
```

**Locate (15g — the Promote disposition-option blurb in Step 2c):**
```
- **Promote** — accept the proposal; it will be moved to `proposals/{slug}.md` and the framework-update flow will resume at Phase 2 (validate-artifact).
```
**Replace:**
```
- **Promote** — accept the proposal; it will be moved to `proposals/{NN}-{slug}.md` and the framework-update flow will resume at Phase 2 (validate-artifact).
```

**Verification:**
- `grep -c -F 'proposals/{NN}-{slug}.md' host/templates/claude/commands/sync-triage-proposals.md` returns at least 5 (the one-promoted `Next:` block, the two-or-more clause, the exit-criteria bullet, the Purpose clause, and the Promote option — plus any from Step 14).
- The bare `proposals/{slug}.md` form intentionally **remains** at exactly three spots and nowhere else: the malformed-case kebab-convention illustration (Step 2b, "outside the project-wide kebab-case slug convention"), the `Canonical slug → proposals/{slug}.md` display in Step 2b (the number is assigned later, at promote, so the pre-numbering canonical-slug display is correct), and the `proposals/{slug}.md` half of the new Step 14 collision check (`proposals/{slug}.md` or `proposals/*-{slug}.md`). The frontmatter `description:` line keeps its high-level generic phrasing. Confirm by reading the three contexts — do **not** treat a non-zero `grep -c` as a failure.

---

### Step 16 — sync-triage skill: mirror the promote + summary changes (row 12)

**Operation:** EDIT
**File:** `host/templates/claude/skills/sync-triage-proposals/SKILL.md`

**Locate (16a — the Promote apply bullet):**
```
     - Promote → `git mv` (or `mv`) to `proposals/{slug}.md`. Halt on slug collision. State next command: `/clear` then `/validate-artifact proposals/{slug}.md`.
```
**Replace:**
```
     - Promote → **assign the master-side number** (`max(existing NN across proposals/, archive/, deferred/, rejected/) + 1`, two-digit zero-padded, **re-read from disk per promote** so same-run promotes don't collide; same algorithm as `/f1-propose-update`), write the `{NN}-` prefix + `**Number:**` header, then `git mv` (or `mv`) to `proposals/{NN}-{slug}.md`. Halt on slug collision (`proposals/{slug}.md` or `*-{slug}.md`). **No branch** — branch creation is deferred to `/f3-implement-update`, so triage stays a pure router. State next command: `/clear` then `/validate-artifact proposals/{NN}-{slug}.md`.
```

**Locate (16b — the Summary item 4):**
```
4. **Summary** — counts and next-command suggestion. One proposal promoted: the single `/clear` + `/validate-artifact proposals/{slug}.md`. Two or more promoted (a batch): emit a **batch-validation handoff prompt** (recommended) filled with the promoted `proposals/{slug}.md` paths per [`reference/batch_validation_handoff.md`](../../../../../reference/batch_validation_handoff.md), plus the sequential per-slug `/clear` + `/validate-artifact` list as the fallback. Same Pattern 1 rigor per proposal either way.
```
**Replace:**
```
4. **Summary** — counts and next-command suggestion. One proposal promoted: the single `/clear` + `/validate-artifact proposals/{NN}-{slug}.md`. Two or more promoted (a batch): emit a **batch-validation handoff prompt** (recommended) filled with the promoted `proposals/{NN}-{slug}.md` paths per [`reference/batch_validation_handoff.md`](../../../../../reference/batch_validation_handoff.md), plus the sequential per-slug `/clear` + `/validate-artifact` list as the fallback. Same Pattern 1 rigor per proposal either way.
```

**Verification:**
- `grep -F 'assign the master-side number' host/templates/claude/skills/sync-triage-proposals/SKILL.md` returns one match.
- `grep -F 'proposals/{NN}-{slug}.md' host/templates/claude/skills/sync-triage-proposals/SKILL.md` returns at least three matches (the 16a promote target + next-command, and the 16b one-promoted + two-or-more paths).
- The bare `proposals/{slug}.md` form intentionally **remains** at: the frontmatter `description:` (generic summary), the 16a collision-halt clause (`proposals/{slug}.md` or `*-{slug}.md`), and the "Why no auto-validation" generic principle line (`runnable … off proposals/{slug}.md alone`). Do **not** treat their presence as a failure.

---

### Step 17 — CHEATSHEET.md: document the pinned conventions (row 13)

**Operation:** EDIT
**File:** `CHEATSHEET.md`

**Locate (the end of the Part 3 table + the Part 4 header):**
```
| `/f6-archive-proposal {slug}` | Phase 7 — archive the implemented proposal | shipped |

### Master / child sync (Part 4)
```
**Replace:**
```
| `/f6-archive-proposal {slug}` | Phase 7 — archive the implemented proposal | shipped |

> **Proposal conventions (master-side).** Master-side proposals carry a lightweight organizational **number**: filenames are `proposals/{NN}-{slug}.md` with a matching `**Number:**` header, assigned at `/f1-propose-update` (master-local) or `/sync-triage-proposals` promote (child-submitted) as `max(existing NN across proposals/, archive/, deferred/, rejected/) + 1` (two-digit zero-padded, no counter file, never reused). **Child-side proposals stay unnumbered** (`.shamt-core/proposals/{slug}.md`). Each proposal lands on its own branch `proposal/{NN}-{slug}` (`proposal/{slug}` when grandfathered/unnumbered), created by `/f3-implement-update` from the base branch immediately before the canonical edits; `/f6-archive-proposal` commits the change as `shamt-core: land #{NN} {slug} (…)`, squash-merges the branch into the base branch, and deletes it. See `CLAUDE.md` §Conventions and the `/f1-propose-update` / `/f6-archive-proposal` command bodies for the authoritative mechanics.

### Master / child sync (Part 4)
```

**Verification:**
- `grep -F 'Proposal conventions (master-side).' CHEATSHEET.md` returns one match.
- `grep -c '### Master / child sync (Part 4)' CHEATSHEET.md` returns 1 (not duplicated).

---

### Step 18 — import-shamt.sh: make the already-merged matcher number-tolerant (row 14)

**Operation:** EDIT
**File:** `import-shamt.sh`

**Locate (the matcher block; copy verbatim incl. 6-space indentation):**
```
      if [ -f "$MASTER_ARCHIVE/$base" ]; then
        dest_dir="$CHILD_PROPOSALS/already-merged"
        mkdir -p "$dest_dir"
        mv "$local_proposal" "$dest_dir/$base"
        src_label=".shamt-core/proposals${scan_rel:+/$scan_rel}/$base"
        log "  moved    $src_label → .shamt-core/proposals/already-merged/$base (matched master archive)"
        PROMOTED_PROPOSAL_COUNT=$((PROMOTED_PROPOSAL_COUNT + 1))
      fi
```
**Replace:**
```
      # Master archive filenames carry a {NN}- numeric prefix (master-side
      # numbering; see shamt-core/CLAUDE.md §Conventions) while child-local
      # proposals stay unnumbered {slug}.md. Match the child basename against
      # both the exact name (grandfathered/unnumbered archives) and the
      # numbered-prefix glob {NN}-{slug}.md.
      matched_archive=""
      if [ -f "$MASTER_ARCHIVE/$base" ]; then
        matched_archive="$MASTER_ARCHIVE/$base"
      else
        for cand in "$MASTER_ARCHIVE"/[0-9]*-"$base"; do
          [ -e "$cand" ] || continue
          matched_archive="$cand"
          break
        done
      fi
      if [ -n "$matched_archive" ]; then
        dest_dir="$CHILD_PROPOSALS/already-merged"
        mkdir -p "$dest_dir"
        mv "$local_proposal" "$dest_dir/$base"
        src_label=".shamt-core/proposals${scan_rel:+/$scan_rel}/$base"
        log "  moved    $src_label → .shamt-core/proposals/already-merged/$base (matched master archive)"
        PROMOTED_PROPOSAL_COUNT=$((PROMOTED_PROPOSAL_COUNT + 1))
      fi
```

**Verification:**
- `bash -n import-shamt.sh` exits 0 (syntax check — no parse error introduced).
- `grep -F 'for cand in "$MASTER_ARCHIVE"/[0-9]*-"$base"' import-shamt.sh` returns one match.
- `grep -F 'if [ -n "$matched_archive" ]; then' import-shamt.sh` returns one match.

---

### Step 19 — plan-executor: reconcile the stale framework-altitude branch + plan-path examples (row 15)

**Operation:** EDIT
**File:** `host/templates/claude/agents/plan-executor.md`

**Locate (19a — the framework-altitude bullet, line ~21):**
```
- **Framework-update altitude** (caller is `/f3-implement-update`) — plan lives under `proposals/{slug}_PLAN.md`; the working tree is on a `framework-update/{slug}` branch (or whatever the proposal declared); `active_artifacts.md` does not apply (proposals carry their own versioning via `_PLAN_phase_N.md` decomposition rather than active-baseline pointers).
```
**Replace:**
```
- **Framework-update altitude** (caller is `/f3-implement-update`) — plan lives under `proposals/{NN}-{slug}_PLAN.md`; the working tree is on a `proposal/{NN}-{slug}` branch (or whatever the proposal declared); `active_artifacts.md` does not apply (proposals carry their own versioning via `_PLAN_phase_N.md` decomposition rather than active-baseline pointers).
```

**Locate (19b — the `plan_path` input bullet, line ~26):**
```
- `plan_path` — path to the validated plan. Story altitude: `stories/{slug}/implementation_plan.md` or one phase file (e.g., `implementation_plan_phase_1.md`). Framework altitude: `proposals/{slug}_PLAN.md` or one phase file (e.g., `proposals/{slug}_PLAN_phase_1.md`).
```
**Replace:**
```
- `plan_path` — path to the validated plan. Story altitude: `stories/{slug}/implementation_plan.md` or one phase file (e.g., `implementation_plan_phase_1.md`). Framework altitude: `proposals/{NN}-{slug}_PLAN.md` or one phase file (e.g., `proposals/{NN}-{slug}_PLAN_phase_1.md`).
```

**Locate (19c — the pre-execution-checklist pre-flight item, line ~34):**
```
4. **Run any pre-execution checklist items** the plan declares (e.g., branch-baseline steps `Step 0-A`, `Step 0-B`). At story altitude, the branch-baseline rule (Global Story Invariants in `templates/SHAMT_RULES.template.md`) requires fetching the configured remote development branch and creating `feature/{slug}/<owner-or-team>` from the fetched remote ref — do not branch from local HEAD. At framework altitude, the plan's pre-execution checklist names its own branch convention (typically `framework-update/{slug}`); follow it as written. Halt and report if the named branch already exists.
```
**Replace:**
```
4. **Run any pre-execution checklist items** the plan declares (e.g., branch-baseline steps `Step 0-A`, `Step 0-B`). At story altitude, the branch-baseline rule (Global Story Invariants in `templates/SHAMT_RULES.template.md`) requires fetching the configured remote development branch and creating `feature/{slug}/<owner-or-team>` from the fetched remote ref — do not branch from local HEAD. At framework altitude, the plan's pre-execution checklist names its own branch convention (typically `proposal/{NN}-{slug}`); follow it as written. Halt and report if the named branch already exists.
```

**Verification:**
- `grep -c 'framework-update/{slug}' host/templates/claude/agents/plan-executor.md` returns 0.
- `grep -F 'proposal/{NN}-{slug}' host/templates/claude/agents/plan-executor.md` returns at least one match.
- `grep -F 'proposals/{NN}-{slug}_PLAN.md' host/templates/claude/agents/plan-executor.md` returns at least one match.

---

## Verification (post-execution)

- [ ] Every row in the Proposed Changes table has a corresponding step (see the Coverage map below).
- [ ] No CREATE files (this plan is EDIT-only) — confirm no new files appeared except this `_PLAN.md`.
- [ ] No edits landed in generated `.claude/` paths. Run `git status` and confirm every changed path is one of the 15 canonical files in the manifest (plus the proposal + this plan).
- [ ] `grep -rn 'framework-update/{slug}' host/templates/claude/` returns **zero** matches (the pinned `proposal/{NN}-{slug}` convention left none behind — covers rows 5, 7, 8, 15 and the D2/D7 consistency check in Validation Considerations).
- [ ] `grep -rn 'Commit conventions (TBD)' .` returns zero matches.
- [ ] `bash -n import-shamt.sh` exits 0.
- [ ] The `proposal/{NN}-{slug}` branch name, the `shamt-core: land #NN {slug} (…)` commit subject, and the `{NN}-{slug}.md` filename form read consistently across `CLAUDE.md`, `proposals/_template.md`, the f1/f2/f3/f6 + sync-triage command+skill bodies, `plan-executor.md`, and `CHEATSHEET.md`.
- [ ] Markdown link / reference targets in edited files still resolve (no links were added or repointed; spot-check `CLAUDE.md` §Conventions has no broken links).

## Coverage map (plan step ↔ Proposed Changes row)

| Proposal row | Canonical path | Plan step(s) | Op match |
|--------------|----------------|--------------|----------|
| 1 | `shamt-core/CLAUDE.md` | Step 1 | EDIT ✓ |
| 2 | `shamt-core/proposals/_template.md` | Step 2 | EDIT ✓ |
| 3 | `…/commands/f1-propose-update.md` | Steps 3, 4 | EDIT ✓ |
| 4 | `…/skills/f1-propose-update/SKILL.md` | Step 5 | EDIT ✓ |
| 5 | `…/commands/f2-plan-update-implementation.md` | Step 6 | EDIT ✓ |
| 6 | `…/skills/f2-plan-update-implementation/SKILL.md` | Step 7 | EDIT ✓ |
| 7 | `…/commands/f3-implement-update.md` | Steps 8, 9 | EDIT ✓ |
| 8 | `…/skills/f3-implement-update/SKILL.md` | Step 10 | EDIT ✓ |
| 9 | `…/commands/f6-archive-proposal.md` | Steps 11, 12 | EDIT ✓ |
| 10 | `…/skills/f6-archive-proposal/SKILL.md` | Step 13 | EDIT ✓ |
| 11 | `…/commands/sync-triage-proposals.md` | Steps 14, 15 | EDIT ✓ |
| 12 | `…/skills/sync-triage-proposals/SKILL.md` | Step 16 | EDIT ✓ |
| 13 | `shamt-core/CHEATSHEET.md` | Step 17 | EDIT ✓ |
| 14 | `shamt-core/import-shamt.sh` | Step 18 | EDIT ✓ |
| 15 | `…/agents/plan-executor.md` | Step 19 | EDIT ✓ |

Every plan step traces back to exactly one Proposed Changes row; no plan step is scope creep. Step 0 (BRANCH) is the pre-execution-checklist branch step, not a file operation.

## Notes

- **Bootstrap / dogfooding.** This proposal is **grandfathered** (it predates the convention it introduces). It lands unnumbered: branch `proposal/proposal-workflow-conventions` (Step 0), and when `/f6-archive-proposal` later archives it, the commit subject drops `#NN` → `shamt-core: land proposal-workflow-conventions (…)` and the archived filename stays unnumbered. The `max(NN)` scan ignores it; the first proposal authored via the amended `/f1-propose-update` gets `#01`. (Confirmed against the current `proposals/archive/` — every entry is unnumbered, so `max(NN) = 0` and the next assignment is `01`.)
- **Branch-creation chicken-and-egg is benign.** This plan edits `/f3-implement-update` to *gain* branch creation, but the `/f3-implement-update` orchestrating *this* plan is the pre-edit version. That doesn't matter: the architect/builder path hands off to `plan-executor`, whose pre-flight Step 4 already says it follows whatever branch the plan's pre-execution checklist declares. Step 0 + the pre-execution checklist declare `proposal/proposal-workflow-conventions`, so the executor creates it regardless of which f3 version is running.
- **On-disk vs. logical paths.** The proposal's table uses `shamt-core/`-prefixed canonical names; on disk in this standalone repo they are repo-root-relative. The mapping is in the Files manifest. All grep verifications use the on-disk form.
- **Out-of-scope items left intentionally untouched (per the proposal's Phase-3 sweep, lines 53 & 110 of the proposal):** `sync-import-shamt.md` + its skill (altitude-appropriate "slugs match" prose stays true once Step 18 makes the matcher number-tolerant); `templates/SHAMT_RULES.template.md` (its only proposal-path refs are the child-side unnumbered `.shamt-core/proposals/{slug}.md`); `/sync-submit-proposal` + its skill (children author unnumbered; the submit path is unchanged); and **no new `CONTRIBUTING.md`/reference doc** (Q5 — conventions live in the concise `CLAUDE.md` §Conventions pointing at the f1/f6 bodies).
- **`import-shamt.sh` footer comment — deliberately not touched (not a judgment call).** The script carries a dated validation footer (line ~367: `# Validated 2026-05-28 … No changes to this file in this round; sweep covered the master/child sync surface end-to-end.`). That line is a **historical record of the 2026-05-28 round** — it remains true *for that round* and is not retroactively falsified by Step 18's later edit. This plan re-stamps **no** edited file's footer (all 15 targets carry one — `CLAUDE.md`, the f-command/skill bodies, etc.); re-validating and re-stamping canonical-file footers is not the job of a framework-update implementation plan, and the proposal's change list scopes only the matcher logic, not a footer rewrite. So **no step edits the footer** — this is a fixed scope boundary, identical to how every other edited file's footer is handled, **not** a decision left to the executor. Footer currency across the canonical surface is the concern of Phase 5 (`/f4-regen-framework`) and the Phase 6 audit (D10), not this plan.
- **`{base-branch}` is `main`.** shamt-core's framework changes have always landed directly on `main` (proposal Problem statement); the f6 git block and guards name `main` as the base branch.
- **No `.claude/` edits.** Phase 5 (`/f4-regen-framework`) propagates these canonical host-template changes into `.claude/`. Editing `.claude/` directly at any step is a hard halt.

---
Validated 2026-06-03 — 2 rounds, 1 adversarial sub-agent confirmed (round-1 adversarial pass surfaced the import-shamt.sh footer-comment Note as an unresolved-judgment-call ambiguity; rewrote Note to frame the footer as a dated historical record, make the no-footer-edit decision consistent with all 15 edited files, and remove the executor-judgment-call phrasing; round-2 sub-agent confirmed zero issues)
