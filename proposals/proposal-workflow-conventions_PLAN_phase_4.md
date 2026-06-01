# Implementation Plan — Phase 4: cheatsheet, import script, persona, out-of-band repo-root edits

**Proposal:** proposals/proposal-workflow-conventions.md
**Index:** proposals/proposal-workflow-conventions_PLAN.md
**Created:** 2026-05-30
**Covers:** Proposed Changes rows 13, 14, 15 + the two **Mandatory out-of-band edits** (`../CLAUDE.md`, `../INFRASTRUCTURE.md`).
**File operations:** 5 EDIT (3 canonical + 2 out-of-band).

> **Out-of-band edits (OOB-1, OOB-2) are intentional and mandatory.** `../CLAUDE.md` and `../INFRASTRUCTURE.md` live **above** `shamt-core/` and are NOT regen-managed. `plan-executor` must still apply them — the proposal's "Mandatory out-of-band edits" table authorizes them, and they must land in the same change or the three governance docs self-contradict once numbering lands. They are the only edits in this whole plan outside the `shamt-core/` canonical roots.

## Files manifest (this phase)

| Path | Operation |
|------|-----------|
| `shamt-core/CHEATSHEET.md` | EDIT (row 13) |
| `shamt-core/import-shamt.sh` | EDIT (row 14) |
| `shamt-core/host/templates/claude/agents/plan-executor.md` | EDIT (row 15) |
| `../CLAUDE.md` (repo-root primer) | EDIT (OOB-1) |
| `../INFRASTRUCTURE.md` (planning doc) | EDIT (OOB-2) |

No `.claude/` paths. No CREATE/DELETE/MOVE. Rows 13–15 are under `shamt-core/`; OOB-1/OOB-2 are above it.

---

## Step 13 — `shamt-core/CHEATSHEET.md` (row 13)

### Step 13a — Add a "Proposal conventions" subsection after the framework-update flow table

**Operation:** EDIT
**Locate:**
```
| `/f6-archive-proposal {slug}` | Phase 7 — archive the implemented proposal | shipped |

### Master / child sync (Part 4)
```
**Replace:**
```
| `/f6-archive-proposal {slug}` | Phase 7 — archive the implemented proposal | shipped |

#### Proposal conventions (master-side)

Master-side proposals follow a pinned set of conventions (full mechanics in the `/f1`, `/f3`, `/f6` command bodies; summary in [`CLAUDE.md`](CLAUDE.md) §Conventions):

- **Number.** Filename-prefixed `proposals/{NN}-{slug}.md` — a two-digit zero-padded, `ls`-orderable organizational ID, `max(NN across proposals/, archive/, deferred/, rejected/) + 1` (first `01`). Assigned at `/f1-propose-update` (master-local) or `/sync-triage-proposals` promote (child-submitted). **Not** the v1 SHAMT-N design-doc lifecycle. Child-local + pre-convention proposals stay unnumbered (`{slug}.md`).
- **Branch.** `proposal/{NN}-{slug}` (`proposal/{slug}` when unnumbered), created by `/f3-implement-update` from the base branch immediately before the canonical edits — not during authoring/validation/planning. Exists only for the implement→merge window.
- **Commit + merge.** `/f6-archive-proposal` commits the proposal branch, squash-merges it into the base branch as one `shamt-core: land #NN {slug} (…)` commit (drop `#NN` when unnumbered), and deletes the branch — behind explicit pre-merge guards.

These are master-dev conventions; child projects author unnumbered proposals and submit upstream via `/sync-submit-proposal`.

### Master / child sync (Part 4)
```
**Verification:** `grep -c "#### Proposal conventions (master-side)" shamt-core/CHEATSHEET.md` returns `1`.

---

## Step 14 — `shamt-core/import-shamt.sh` (row 14) — make the already-merged matcher number-tolerant

### Step 14a — Update the header comment to note number-tolerant matching

**Operation:** EDIT
**Locate:**
```
# /sync-submit-proposal, awaiting master's decision). If a master archive entry
# <master>/proposals/archive/{slug}.md matches the basename, the proposal landed
# upstream and came back via this sync; move the local copy to
# <child>/.shamt-core/proposals/already-merged/{slug}.md per §4.7 / §4.9.
```
**Replace:**
```
# /sync-submit-proposal, awaiting master's decision). If a master archive entry
# matches the child basename — either exactly (<master>/proposals/archive/{slug}.md)
# or with a leading number prefix ({NN}-{slug}.md, per the master-side
# proposal-numbering convention) — the proposal landed upstream and came back via
# this sync; move the local copy to
# <child>/.shamt-core/proposals/already-merged/{slug}.md per §4.7 / §4.9.
```
**Verification:** `grep -c "with a leading number prefix" shamt-core/import-shamt.sh` returns `1`.

### Step 14b — Replace the exact-basename matcher with exact-then-numbered-glob

**Operation:** EDIT
**Locate:**
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
      # The child's proposal is unnumbered ({slug}.md). Master's archive may hold
      # either an old unnumbered {slug}.md or a numbered {NN}-{slug}.md (per the
      # proposal-numbering convention). Try the exact basename first, then a
      # leading-number glob. nullglob is not assumed: when the glob matches
      # nothing it stays literal, and the [ -f ] test rejects the literal.
      matched_archive=""
      if [ -f "$MASTER_ARCHIVE/$base" ]; then
        matched_archive="$MASTER_ARCHIVE/$base"
      else
        for cand in "$MASTER_ARCHIVE"/[0-9]*-"$base"; do
          [ -f "$cand" ] && { matched_archive="$cand"; break; }
        done
      fi
      if [ -n "$matched_archive" ]; then
        dest_dir="$CHILD_PROPOSALS/already-merged"
        mkdir -p "$dest_dir"
        mv "$local_proposal" "$dest_dir/$base"
        src_label=".shamt-core/proposals${scan_rel:+/$scan_rel}/$base"
        log "  moved    $src_label → .shamt-core/proposals/already-merged/$base (matched master archive $(basename "$matched_archive"))"
        PROMOTED_PROPOSAL_COUNT=$((PROMOTED_PROPOSAL_COUNT + 1))
      fi
```
**Verification:**
- `bash -n shamt-core/import-shamt.sh` exits 0 (syntax check — this is a real script).
- `grep -c 'for cand in "$MASTER_ARCHIVE"/\[0-9\]\*-"$base"' shamt-core/import-shamt.sh` returns `1`.

---

## Step 15 — `shamt-core/host/templates/claude/agents/plan-executor.md` (row 15) — reconcile stale framework-altitude examples

### Step 15a — Line 21: branch + plan-path examples

**Operation:** EDIT
**Locate:**
```
- **Framework-update altitude** (caller is `/f3-implement-update`) — plan lives under `proposals/{slug}_PLAN.md`; the working tree is on a `framework-update/{slug}` branch (or whatever the proposal declared); `active_artifacts.md` does not apply (proposals carry their own versioning via `_PLAN_phase_N.md` decomposition rather than active-baseline pointers).
```
**Replace:**
```
- **Framework-update altitude** (caller is `/f3-implement-update`) — plan lives under `proposals/{NN}-{slug}_PLAN.md` (or `proposals/{slug}_PLAN.md` for an unnumbered/grandfathered proposal); the working tree is on the `proposal/{NN}-{slug}` branch that `/f3-implement-update` created (or `proposal/{slug}`, or whatever the plan's pre-execution checklist declared); `active_artifacts.md` does not apply (proposals carry their own versioning via `_PLAN_phase_N.md` decomposition rather than active-baseline pointers).
```
**Verification:** `grep -c "the \`proposal/{NN}-{slug}\` branch that \`/f3-implement-update\` created" shamt-core/host/templates/claude/agents/plan-executor.md` returns `1`.

### Step 15b — Line 26: plan_path framework-altitude example

**Operation:** EDIT
**Locate:**
```
- `plan_path` — path to the validated plan. Story altitude: `stories/{slug}/implementation_plan.md` or one phase file (e.g., `implementation_plan_phase_1.md`). Framework altitude: `proposals/{slug}_PLAN.md` or one phase file (e.g., `proposals/{slug}_PLAN_phase_1.md`).
```
**Replace:**
```
- `plan_path` — path to the validated plan. Story altitude: `stories/{slug}/implementation_plan.md` or one phase file (e.g., `implementation_plan_phase_1.md`). Framework altitude: `proposals/{NN}-{slug}_PLAN.md` (or `proposals/{slug}_PLAN.md`) or one phase file (e.g., `proposals/{NN}-{slug}_PLAN_phase_1.md`).
```
**Verification:** `grep -c "proposals/{NN}-{slug}_PLAN_phase_1.md" shamt-core/host/templates/claude/agents/plan-executor.md` returns `1`.

### Step 15c — Line 34: branch-convention example in the pre-execution-checklist guidance

**Operation:** EDIT
**Locate:**
```
At framework altitude, the plan's pre-execution checklist names its own branch convention (typically `framework-update/{slug}`); follow it as written. Halt and report if the named branch already exists.
```
**Replace:**
```
At framework altitude, the plan's pre-execution checklist names its own branch convention (the pinned default is `proposal/{NN}-{slug}`, or `proposal/{slug}` for an unnumbered/grandfathered proposal — created from the base branch as a Step 0 pre-execution item); follow it as written. Halt and report if the named branch already exists.
```
**Verification:** `grep -c "the pinned default is \`proposal/{NN}-{slug}\`" shamt-core/host/templates/claude/agents/plan-executor.md` returns `1`; `grep -c "framework-update/{slug}" shamt-core/host/templates/claude/agents/plan-executor.md` returns `0`.

---

## Step OOB-1 — `../CLAUDE.md` (repo-root primer) — reconcile Commits/Branches TBD

> Out-of-band: above `shamt-core/`, not regen-managed. Mandatory per the proposal's "Mandatory out-of-band edits" table.

**Operation:** EDIT
**File:** `../CLAUDE.md` (relative to `shamt-core/`; i.e., the repo-root `CLAUDE.md` one level up)
**Locate:**
```
- **Commits:** No fixed convention yet. v1 used `feat/SHAMT-N: …`; v2 may not need SHAMT-N numbering. Decide before the first feature commit and document it here.
- **Branches:** No convention pinned yet.
```
**Replace:**
```
- **Commits:** `shamt-core: land #NN {slug} (short summary)` for landing a framework proposal (drop `#NN` for an unnumbered/grandfathered proposal). See [`shamt-core/CLAUDE.md`](shamt-core/CLAUDE.md) §Conventions for the authoritative mechanics.
- **Branches:** Branch-per-proposal — `proposal/{NN}-{slug}` (or `proposal/{slug}`), created by `/f3-implement-update` and squash-merged into `main` + deleted by `/f6-archive-proposal`. See `shamt-core/CLAUDE.md` §Conventions.
```
**Verification:** `grep -c "No fixed convention yet" ../CLAUDE.md` returns `0`; `grep -c "shamt-core: land #NN {slug}" ../CLAUDE.md` returns `1`.

---

## Step OOB-2 — `../INFRASTRUCTURE.md` (planning doc) — reconcile SHAMT-N + filename references

> Out-of-band: above `shamt-core/`, not regen-managed. Mandatory per the proposal's "Mandatory out-of-band edits" table.

### Step OOB-2a — §3.1 proposals-folder row: numbered filename

**Operation:** EDIT
**File:** `../INFRASTRUCTURE.md`
**Locate:**
```
| `proposals/` folder | Active proposals at `proposals/{slug}.md`. |
```
**Replace:**
```
| `proposals/` folder | Active proposals at `proposals/{NN}-{slug}.md` (master-side, numbered) / `proposals/{slug}.md` (child-side, unnumbered). |
```
**Verification:** `grep -c "proposals/{NN}-{slug}.md\` (master-side, numbered)" ../INFRASTRUCTURE.md` returns `1`.

### Step OOB-2b — §3.3 rejected-list line: reconcile "No SHAMT-N numbering"

**Operation:** EDIT
**File:** `../INFRASTRUCTURE.md`
**Locate:**
```
- **SHAMT-N numbering for proposals.** Slug + date is enough.
```
**Replace:**
```
- **SHAMT-N design-doc lifecycle for proposals.** Proposals carry a lightweight, `ls`-orderable `{NN}-` org-ID (master-side) — but **not** the v1 SHAMT-N design-doc lifecycle (no per-number doc, status machine, or cross-reference convention). Slug + date + the lightweight number is enough; see `shamt-core/CLAUDE.md` §Conventions.
```
**Verification:** `grep -c "SHAMT-N numbering for proposals" ../INFRASTRUCTURE.md` returns `0`; `grep -c "SHAMT-N design-doc lifecycle for proposals" ../INFRASTRUCTURE.md` returns `1`.

### Step OOB-2c — §3.6 new-artifacts line: numbered active-proposal path

**Operation:** EDIT
**File:** `../INFRASTRUCTURE.md`
**Locate:**
```
- `proposals/{slug}.md` — active proposal (carries validation footer when validated)
```
**Replace:**
```
- `proposals/{NN}-{slug}.md` — active proposal (master-side, numbered; `proposals/{slug}.md` child-side/unnumbered; carries validation footer when validated)
```
**Verification:** `grep -c "proposals/{NN}-{slug}.md\` — active proposal" ../INFRASTRUCTURE.md` returns `1`.

---

## Cross-check (this phase vs. Proposed Changes rows + out-of-band)

| Row / OOB | File | Steps | Operation match |
|-----------|------|-------|-----------------|
| 13 | CHEATSHEET.md | 13a | EDIT ✓ |
| 14 | import-shamt.sh | 14a, 14b | EDIT ✓ |
| 15 | plan-executor.md | 15a, 15b, 15c | EDIT ✓ |
| OOB-1 | ../CLAUDE.md | OOB-1 | EDIT ✓ (out-of-band, authorized) |
| OOB-2 | ../INFRASTRUCTURE.md | OOB-2a, 2b, 2c | EDIT ✓ (out-of-band, authorized) |

All three canonical rows + both mandatory out-of-band edits covered; every step is an EDIT. The only non-`shamt-core/` edits in the whole plan are OOB-1 and OOB-2 (authorized by the proposal). After this phase, the three governance docs (`shamt-core/CLAUDE.md` §Conventions from Phase 1, repo-root `CLAUDE.md`, `INFRASTRUCTURE.md`) agree, and no stray `framework-update/{slug}` remains in `plan-executor.md`.

**Post-phase whole-plan verification:** run the index file's "Verification (post-execution)" checklist after all four phases complete.
