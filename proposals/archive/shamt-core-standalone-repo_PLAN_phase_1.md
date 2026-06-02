# Implementation Plan — Phase 1: Primer narrative, structural detection, scripts

**Proposal:** proposals/shamt-core-standalone-repo.md
**Index:** proposals/shamt-core-standalone-repo_PLAN.md
**Created:** 2026-06-01
**Covers:** Proposed Changes rows 1, 2, 3, 29, 30
**Character:** Judgment-heavy — narrative rewrite (row 1), structural-detection rewording (rows 2–3), script-comment citation removal (rows 29–30).

No cross-step ordering constraint within this phase. Every step is a self-contained EDIT.

---

## Step 1 — Restate the primer as a standalone repo (row 1)

**Operation:** EDIT
**File:** `CLAUDE.md`

Four sub-edits. Apply all four.

### 1a — Drop the repo-root-`CLAUDE.md` container note (line 5)

**Locate:**
```
This file is for shamt-core contributors. The repo-root `CLAUDE.md` (one level up, in the v2 development container) is a separate document — it primes the v2-development context and references this folder.
```
**Replace:**
```
This file is for shamt-core contributors. shamt-core is its own standalone git repository.
```

### 1b — Drop the dead `../INFRASTRUCTURE.md` rationale link (line 73)

**Locate:**
```
Carried forward from v1 lessons (see `../INFRASTRUCTURE.md` for full rationale):
```
**Replace:**
```
Carried forward from v1 lessons:
```

### 1c — Drop the repo-root-`CLAUDE.md` TBD note (Commit conventions, line 87)

**Locate:**
```
Not pinned yet. Decide before the first feature commit and document here. The repo-root `CLAUDE.md` calls out the same TBD; resolve them together.
```
**Replace:**
```
Not pinned yet. Decide before the first feature commit and document here.
```

### 1d — Delete the obsolete `## Working alongside _reference/` section (lines 95–104)

This section is the file's last block and the only genuine sibling-`_reference/` reference in the canonical surface. Delete the whole section including the `---` separator that precedes it.

**Locate:**
```
---

## Working alongside `_reference/`

While shamt-core is being built inside the `shamt-ai-dev-v2/` development container, the sibling `_reference/` folder (one level up) holds two read-only prior-art trees:

- `_reference/shamt-lite-transfer/` — the lightweight standalone bundle this rewrite is based on. Primary baseline.
- `_reference/shamt-ai-dev/` — the full v1 master repo. Mine for patterns; do not copy structure wholesale.

Both are **gitignored** in v2. Never edit, never stage, never delete. Once shamt-core is extracted into its own repository, `_reference/` won't follow; this folder must stand on its own.
```
**Replace:** *(empty — delete the entire block, leaving the file ending at the preceding section)*

**Verification:**
- `grep -c "INFRASTRUCTURE" CLAUDE.md` returns `0`.
- `grep -c "v2 development container\|one level up\|Working alongside\|_reference/" CLAUDE.md` returns `0`.

---

## Step 2 — Reword `/f1-propose-update` master-side detection (row 2)

**Operation:** EDIT
**File:** `host/templates/claude/commands/f1-propose-update.md`

The master is now the repo itself (top-level `proposals/`), not a project root containing a nested `shamt-core/` subdirectory. Row 2 mandates this exact standalone wording: "master-side = running inside the shamt-core repo with top-level `proposals/`; child-side = a synced framework + `.shamt-core/proposals/`" — so the "the repo with a top-level `proposals/` directory" phrasing in the Replace is proposal-authorized, not invented.

**Locate:**
```
- Run from a project root that has `shamt-core/` (master-side) or a synced framework + `.shamt-core/proposals/` folder (child-side). If neither exists, halt and direct the user to either run this from `shamt-core/` or install Shamt first.
```
**Replace:**
```
- Run from the shamt-core repository root (master-side) — the repo with a top-level `proposals/` directory — or from a project with a synced framework + `.shamt-core/proposals/` folder (child-side). If neither exists, halt and direct the user to either run this from the shamt-core repo root or install Shamt first.
```

**Verification:** `grep -c "a project root that has \`shamt-core/\`" host/templates/claude/commands/f1-propose-update.md` returns `0`; `grep -c "the shamt-core repository root (master-side)" host/templates/claude/commands/f1-propose-update.md` returns `1`.

---

## Step 3 — Reword `/sync-triage-proposals` master detection + drop dead citation (row 3)

**Operation:** EDIT
**File:** `host/templates/claude/commands/sync-triage-proposals.md`

Drop the dead `§4.4 / §4.8` citation **and** the now-false `shamt-core/`-subdirectory parenthetical. Keep the `proposals/incoming/`-presence discriminator (unchanged behavior).

**Locate:**
```
- This command runs **on the master side**. Master vs. child is decided by `proposals/incoming/` presence at the cwd: master has it per [§4.4 / §4.8](../../../../../INFRASTRUCTURE.md#44-masters-handling-of-imported-proposals); child projects never do. (Both sides have `shamt-core/` as a subdirectory, so its presence is NOT a master indicator.)
```
**Replace:**
```
- This command runs **on the master side**. Master vs. child is decided by `proposals/incoming/` presence at the cwd: master has it; child projects never do.
```

**Verification:** `grep -c "INFRASTRUCTURE" host/templates/claude/commands/sync-triage-proposals.md` returns `0`; `grep -c "as a subdirectory, so its presence is NOT a master indicator" host/templates/claude/commands/sync-triage-proposals.md` returns `0`.

---

## Step 4 — Sweep dead citation from `import-shamt.sh` (row 29)

**Operation:** EDIT
**File:** `import-shamt.sh`

Link-removal policy case (a): keep the inline rationale (the per-file "Managed by Shamt" footer contract it interprets), drop the dead `§4.7` reference.

**Locate:**
```
# This is a pragmatic interpretation of INFRASTRUCTURE.md §4.7 which proposed a
# per-file "Managed by Shamt" footer contract: most canonical files under
```
**Replace:**
```
# This is a pragmatic interpretation of an earlier proposed per-file
# "Managed by Shamt" footer contract: most canonical files under
```

**Verification:** `grep -c "INFRASTRUCTURE" import-shamt.sh` returns `0`; `grep -c "Managed by Shamt" import-shamt.sh` returns `2` (the retained footer-contract phrase in this comment plus the existing line-368 managed-file banner).

---

## Step 5 — Sweep dead citation from `init-shamt.sh` (row 30)

**Operation:** EDIT
**File:** `init-shamt.sh`

Link-removal policy case (a): keep the inline rationale (no remote-hosted curl-bash; invoked locally), drop the dead `§4.12` reference. (The `Phase 9` build-phase label is a bare tag, not a dead link — out of this plan's scope; left as-is.)

**Locate:**
```
# Per Phase 9 / INFRASTRUCTURE.md §4.12: no remote-hosted curl-bash; invoked
```
**Replace:**
```
# Per Phase 9: no remote-hosted curl-bash; invoked
```

**Verification:** `grep -c "INFRASTRUCTURE" init-shamt.sh` returns `0`; `grep -c "no remote-hosted curl-bash" init-shamt.sh` returns `1`.

---

## Phase 1 cross-check

- Rows covered: 1, 2, 3, 29, 30 — one step each (Step 1 = row 1 with four sub-edits; Steps 2–5 = rows 2, 3, 29, 30). ✓
- All EDIT; no CREATE / DELETE / MOVE; no `.claude/` path touched. ✓
- `grep -rn "INFRASTRUCTURE\.md" CLAUDE.md host/templates/claude/commands/f1-propose-update.md host/templates/claude/commands/sync-triage-proposals.md import-shamt.sh init-shamt.sh` returns zero lines after this phase.

---
*Validated 2026-06-01 — 3 rounds, 1 adversarial sub-agent confirmed.*
