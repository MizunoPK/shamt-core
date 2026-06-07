# Implementation Plan — rename-cheatsheet-to-readme (#07)

**Created:** 2026-06-07
**Proposal:** `proposals/07-rename-cheatsheet-to-readme.md` (Validated 2026-06-07)
**Altitude:** Framework-update (Part 3). Executor: `plan-executor` (Haiku) via `/f3-implement-update` architect/builder path.
**Base branch:** `main`

---

## Planning Status

- **Blocked on proposal:** None — proposal validated, 14 rows, all locate strings exact-quoted below.
- **Blocked on open questions:** None.
- **Ready for mechanical validation:** [x] Yes — one `git mv` (Step 1) plus uniform textual filename-repoint EDITs, each with an exact locate + replacement; no optional branches.

---

## Pre-Execution Checklist

- [ ] **Proposal branch** `proposal/07-rename-cheatsheet-to-readme` created from `main` (Step 0). Halt if it already exists.
- [ ] All 14 affected paths exist on disk (verified at plan time): `CHEATSHEET.md` + the 13 reference-carriers.
- [ ] No unresolved optional branches.
- [ ] **Hard rule:** edits go to canonical sources only — **never** `.claude/`. Every path below is under `host/templates/claude/`, `templates/`, `reference/`, `proposals/`, or a root canonical doc (`CLAUDE.md`, `README.md`, `shamt-config.example.json`, `init-shamt.sh`, `import-shamt.sh`).
- [ ] Review-Prevention Gate Mapping: **N/A at framework altitude** (no app code, data, auth, tenancy, infra, or tests — a documentation-file rename + filename-reference repoints).
- [ ] Plan validated (Phase 2 footer present).

---

## Files Touched (manifest)

| Operation | Path |
|-----------|------|
| BRANCH | `proposal/07-rename-cheatsheet-to-readme` (from `main`) |
| MOVE + EDIT | `CHEATSHEET.md` → `README.md` (+ 2 internal self-references) |
| EDIT | `CLAUDE.md` |
| EDIT | `templates/SHAMT_RULES.template.md` |
| EDIT | `proposals/_template.md` |
| EDIT | `host/templates/claude/commands/f1-propose-update.md` |
| EDIT | `host/templates/claude/commands/f3-implement-update.md` |
| EDIT | `host/templates/claude/commands/f5-audit-framework.md` |
| EDIT | `host/templates/claude/commands/sync-import-shamt.md` |
| EDIT | `host/templates/claude/skills/f3-implement-update/SKILL.md` |
| EDIT | `host/templates/claude/skills/sync-import-shamt/SKILL.md` |
| EDIT | `reference/trackers/_contract.md` |
| EDIT | `shamt-config.example.json` |
| EDIT | `init-shamt.sh` |
| EDIT | `import-shamt.sh` |

No optional rows. If a path is not in this manifest, it must not be created or edited during execution.

---

## Review Prevention Gate Mapping

**N/A — framework-update altitude.** Every step is a documentation-file rename or a filename / path / link-string repoint in agent-instruction / prose / config. No regulated data, tenant isolation, auth/route, database, infrastructure, frontend, test, or security-check surface is touched. No gate applies.

---

## Implementation Steps

### Step 0: Create the proposal branch
**Operation:** BRANCH
**Details:**
- Run: `git checkout -b proposal/07-rename-cheatsheet-to-readme` from `main`.
- If the branch already exists, stop and report (do not overwrite/reset).

**Verification:** `git branch --show-current` prints `proposal/07-rename-cheatsheet-to-readme`.

---

### Step 1: Rename the file and repoint its 2 internal self-references (Proposed Changes row 1)
**Operation:** MOVE + EDIT
**File:** `CHEATSHEET.md` → `README.md`
**Details:**
- **1a — MOVE:** Run `git mv CHEATSHEET.md README.md`. Content is otherwise kept verbatim — the `# Shamt — Cheatsheet` title and the word "cheatsheet" (content-type wording) stay.
- **1b — internal tree-diagram self-reference (in the now-renamed `README.md`):**
  - Locate: `│   ├── CHEATSHEET.md               #   copy of this file`
  - Replace: `│   ├── README.md                   #   copy of this file`
  - (The `#   copy of this file` comment stays accurate; the replacement re-pads to keep the `#` column aligned with its sibling rows.)
- **1c — internal seeding-prose self-reference (in `README.md`):**
  - Locate: `` `CHEATSHEET.md` and `proposals/_template.md` travel inside the `.shamt-core/` canonical-source copy ``
  - Replace: `` `README.md` and `proposals/_template.md` travel inside the `.shamt-core/` canonical-source copy ``

**Verification:** `test -f README.md && ! test -f CHEATSHEET.md` (rename done); `grep -c "CHEATSHEET" README.md` → `0` (no internal self-reference survives); `grep -c "# Shamt — Cheatsheet" README.md` → `1` (title intact); `grep -c "Validated 2026-05-28 — Phase 12 implementation loop" README.md` → `1` (the doc's validation footer was **not** stripped by the MOVE — the proposal's Risks bullet mandates this check).

---

### Step 2: Repoint the 4 `CHEATSHEET.md` references in `CLAUDE.md` (row 2)
**Operation:** EDIT
**File:** `CLAUDE.md`
**Details — four replacements:**
- **2a (line 3 — §intro pointer):**
  - Locate: `` see `CHEATSHEET.md` (commands + skills + personas) ``
  - Replace: `` see `README.md` (commands + skills + personas) ``
- **2b (line 14 — "what lives here" tree-diagram row):**
  - Locate: `├── CHEATSHEET.md                   # hand-written quick reference (commands, skills, personas)`
  - Replace: `├── README.md                       # hand-written quick reference (commands, skills, personas)`
  - (Re-pads to keep the `#` column aligned with the sibling `├── CLAUDE.md` row.)
- **2c (line 22 — install-layout list):**
  - Locate: `` (initialized from the example), `CHEATSHEET.md`, the `proposals/` working area ``
  - Replace: `` (initialized from the example), `README.md`, the `proposals/` working area ``
- **2d (line 33 — two-surfaces table):**
  - Locate: `` its installed `.shamt-core/CHEATSHEET.md` ``
  - Replace: `` its installed `.shamt-core/README.md` ``

**Verification:** `grep -c "CHEATSHEET" CLAUDE.md` → `0`.

---

### Step 3: Repoint the host-wiring pointer in `SHAMT_RULES.template.md` (row 3)
**Operation:** EDIT
**File:** `templates/SHAMT_RULES.template.md`
**Details:**
- Locate: `- `.shamt-core/CHEATSHEET.md` — host wiring quick reference (commands, skills, personas).`
- Replace: `- `.shamt-core/README.md` — host wiring quick reference (commands, skills, personas).`

**Verification:** `grep -c "CHEATSHEET" templates/SHAMT_RULES.template.md` → `0`.

---

### Step 4: Repoint the canonical-roots list in `proposals/_template.md` (row 4)
**Operation:** EDIT
**File:** `proposals/_template.md`
**Details:**
- Locate: `the root-level canonical docs: `shamt-core/CLAUDE.md`, `shamt-core/CHEATSHEET.md`, `shamt-core/shamt-config.example.json`.`
- Replace: `the root-level canonical docs: `shamt-core/CLAUDE.md`, `shamt-core/README.md`, `shamt-core/shamt-config.example.json`.`

**Verification:** `grep -c "CHEATSHEET" proposals/_template.md` → `0`.

---

### Step 5: Repoint the canonical-roots list in `f1-propose-update` command (row 5)
**Operation:** EDIT
**File:** `host/templates/claude/commands/f1-propose-update.md`
**Details:**
- Locate: `the root-level canonical docs: `shamt-core/CLAUDE.md`, `shamt-core/CHEATSHEET.md`, `shamt-core/shamt-config.example.json`.`
- Replace: `the root-level canonical docs: `shamt-core/CLAUDE.md`, `shamt-core/README.md`, `shamt-core/shamt-config.example.json`.`

**Verification:** `grep -c "CHEATSHEET" host/templates/claude/commands/f1-propose-update.md` → `0`.

---

### Step 6: Repoint the canonical-roots list in `f3-implement-update` command (row 6 — pairs with Step 9)
**Operation:** EDIT
**File:** `host/templates/claude/commands/f3-implement-update.md`
**Details:**
- Locate: `- `shamt-core/CLAUDE.md`, `shamt-core/CHEATSHEET.md`, `shamt-core/shamt-config.example.json` (root-level canonical docs)`
- Replace: `- `shamt-core/CLAUDE.md`, `shamt-core/README.md`, `shamt-core/shamt-config.example.json` (root-level canonical docs)`

**Verification:** `grep -c "CHEATSHEET" host/templates/claude/commands/f3-implement-update.md` → `0`.

---

### Step 7: Repoint the bare-noun doc reference in `f5-audit-framework` command (row 7)
**Operation:** EDIT
**File:** `host/templates/claude/commands/f5-audit-framework.md`
**Details:**
- Locate: `persona counts in the CHEATSHEET table`
- Replace: `persona counts in the README table`
- (Bare-noun mention — the doc is named, not a filename; "CHEATSHEET" → "README".)

**Verification:** `grep -c "CHEATSHEET" host/templates/claude/commands/f5-audit-framework.md` → `0`.

---

### Step 8: Repoint the sync-set list in `sync-import-shamt` command (row 8 — pairs with Step 10)
**Operation:** EDIT
**File:** `host/templates/claude/commands/sync-import-shamt.md`
**Details:**
- Locate: `Overwriting every file in master's sync set (`CLAUDE.md`, `CHEATSHEET.md`, `shamt-config.example.json`, `init-shamt.sh`, `import-shamt.sh`, `proposals/_template.md`,`
- Replace: `Overwriting every file in master's sync set (`CLAUDE.md`, `README.md`, `shamt-config.example.json`, `init-shamt.sh`, `import-shamt.sh`, `proposals/_template.md`,`

**Verification:** `grep -c "CHEATSHEET" host/templates/claude/commands/sync-import-shamt.md` → `0`.

---

### Step 9: Repoint the canonical-roots list in `f3-implement-update` skill (row 9 — mirrors Step 6)
**Operation:** EDIT
**File:** `host/templates/claude/skills/f3-implement-update/SKILL.md`
**Details:**
- Locate: `the root-level canonical docs (`CLAUDE.md`, `CHEATSHEET.md`, `shamt-config.example.json`).`
- Replace: `the root-level canonical docs (`CLAUDE.md`, `README.md`, `shamt-config.example.json`).`

**Verification:** `grep -c "CHEATSHEET" host/templates/claude/skills/f3-implement-update/SKILL.md` → `0`.

---

### Step 10: Repoint the sync-set list in `sync-import-shamt` skill (row 10 — mirrors Step 8)
**Operation:** EDIT
**File:** `host/templates/claude/skills/sync-import-shamt/SKILL.md`
**Details:**
- Locate: `Every path in master's sync set (`CLAUDE.md`, `CHEATSHEET.md`, `shamt-config.example.json`, `init-shamt.sh`, `import-shamt.sh`, `proposals/_template.md`,`
- Replace: `Every path in master's sync set (`CLAUDE.md`, `README.md`, `shamt-config.example.json`, `init-shamt.sh`, `import-shamt.sh`, `proposals/_template.md`,`

**Verification:** `grep -c "CHEATSHEET" host/templates/claude/skills/sync-import-shamt/SKILL.md` → `0`.

---

### Step 11: Repoint the markdown link (text + target) in `_contract.md` (row 11)
**Operation:** EDIT
**File:** `reference/trackers/_contract.md`
**Details:**
- Locate: `[`CHEATSHEET.md`](../../CHEATSHEET.md)`
- Replace: `[`README.md`](../../README.md)`
- (A single replacement covers **both** the link text and the relative target; the new `../../README.md` resolves on disk after Step 1's MOVE.)

**Verification:** `grep -c "CHEATSHEET" reference/trackers/_contract.md` → `0`; `test -f README.md` (link target resolves).

---

### Step 12: Repoint the schema-note path in `shamt-config.example.json` (row 12)
**Operation:** EDIT
**File:** `shamt-config.example.json`
**Details:**
- Locate: `All keys are required unless marked optional in shamt-core/CHEATSHEET.md.`
- Replace: `All keys are required unless marked optional in shamt-core/README.md.`

**Verification:** `grep -c "CHEATSHEET" shamt-config.example.json` → `0`; `python3 -c "import json,sys; json.load(open('shamt-config.example.json'))"` exits 0 (still valid JSON).

---

### Step 13: Repoint the sync-set array entry + comment in `init-shamt.sh` (row 13 — pairs with Step 14)
**Operation:** EDIT
**File:** `init-shamt.sh`
**Details — two replacements:**
- **13a (sync-set array entry):**
  - Locate: `"CHEATSHEET.md"`
  - Replace: `"README.md"`
- **13b (comment):**
  - Locate: `#      CHEATSHEET.md and proposals/_template.md travel inside this set — they`
  - Replace: `#      README.md and proposals/_template.md travel inside this set — they`

**Verification:** `grep -c "CHEATSHEET" init-shamt.sh` → `0`; `bash -n init-shamt.sh` exits 0 (syntax intact).

---

### Step 14: Repoint the sync-set array entry in `import-shamt.sh` (row 14 — mirrors Step 13a)
**Operation:** EDIT
**File:** `import-shamt.sh`
**Details:**
- Locate: `"CHEATSHEET.md"`
- Replace: `"README.md"`

**Verification:** `grep -c "CHEATSHEET" import-shamt.sh` → `0`; `bash -n import-shamt.sh` exits 0 (syntax intact).

---

## Final verification (after all steps)

Run the proposal's mandated completeness grep:

```
grep -rn "CHEATSHEET" . --include="*.md" --include="*.sh" --include="*.json" | grep -vE "proposals/archive/|proposals/rejected/|proposals/07-rename|\.claude/"
```

**Expected:** zero results — every canonical `CHEATSHEET` reference has been repointed to `README.md`. (The `proposals/07-rename-…` files legitimately still name the old filename as the rename's subject; `.claude/` mirrors still carry the old name until `/f4-regen-framework` runs in Phase 5 — they are excluded here.) Any other hit = an uncovered reference; halt and report.

Confirm the renamed file is present, titled, and footer-intact: `test -f README.md && ! test -f CHEATSHEET.md && head -1 README.md` prints `# Shamt — Cheatsheet`, and `grep -c "Validated 2026-05-28 — Phase 12 implementation loop" README.md` → `1` (validation footer survived the MOVE).

---

## Notes

- **MOVE-first ordering.** Step 1 renames the file before the reference repoints so that Step 11's link target (`../../README.md`) and the Final-verification `test -f README.md` resolve against the new path.
- **`"CHEATSHEET.md"` quoted-token locates (Steps 13a, 14).** The double-quoted token is unique within each `.sh` file (the only other `CHEATSHEET` in `init-shamt.sh` is the unquoted comment handled by 13b; `import-shamt.sh` has just the array entry), so the locate is unambiguous regardless of array indentation.
- **No `.claude/` edits.** Phase 5 (`/f4-regen-framework`) propagates the 6 `host/templates/claude/` edits (Steps 5–10) into `.claude/`; the root canonical docs, templates, reference doc, config, and scripts (Steps 1–4, 11–14) are not regenerated and will not appear in the `--check` diff.
- **Child orphan-on-rename.** Out of scope for this plan — `import-shamt` overwrites but does not prune, so children keep a stale `.shamt-core/CHEATSHEET.md` alongside the new `.shamt-core/README.md`. Acceptable per the proposal's keep-syncing decision; not an edit this plan makes.
- **No commit in Phase 4.** The commit + squash-merge land at `/f6-archive-proposal`.

## CODING_STANDARDS Compliance

N/A — no project `CODING_STANDARDS.md` applies at the framework-update altitude; these are a documentation-file rename + filename-reference repoints to canonical framework sources.

---

## Open Questions

(none — every step is mechanical with an exact locate + replacement, or the `git mv` of Step 1a)

---
Validated 2026-06-07 — 2 rounds, 1 adversarial sub-agent confirmed (round 2 added a validation-footer-preservation assertion to Step 1 + the Final verification, honoring the proposal's Risks bullet "Verify the MOVE does not strip the validation footer"; all 14 locate strings re-verified exact + unique against HEAD, both tree-diagram replacements re-checked for `#`-column alignment)
