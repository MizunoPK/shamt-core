# Implementation Plan — purge-build-phase-numbers-from-host-bodies (#03)

**Created:** 2026-06-06
**Proposal:** `proposals/03-purge-build-phase-numbers-from-host-bodies.md` (Validated 2026-06-06)
**Altitude:** Framework-update (Part 3). Executor: `plan-executor` (Haiku) via `/f3-implement-update` architect/builder path.
**Base branch:** `main`

---

## Planning Status

- **Blocked on proposal:** None — proposal validated, 11 rows, all locate strings exact-quoted below.
- **Blocked on open questions:** None.
- **Ready for mechanical validation:** [x] Yes — every step is a uniform textual EDIT with an exact locate + replacement; no optional branches.

---

## Pre-Execution Checklist

- [ ] **Proposal branch** `proposal/03-purge-build-phase-numbers-from-host-bodies` created from `main` (Step 0). Halt if it already exists.
- [ ] All 11 affected files exist on disk (verified at plan time).
- [ ] No unresolved optional branches.
- [ ] **Hard rule:** edits go to canonical sources only — **never** `.claude/`. Every path below is under `host/templates/claude/` or a root canonical doc (`CLAUDE.md`, `CHEATSHEET.md`).
- [ ] Review-Prevention Gate Mapping: **N/A at framework altitude** (no app code, data, auth, tenancy, infra, or tests — pure documentation-prose edits).
- [ ] Plan validated (Phase 2 footer present).

---

## Files Touched (manifest)

| Operation | Path |
|-----------|------|
| BRANCH | `proposal/03-purge-build-phase-numbers-from-host-bodies` (from `main`) |
| EDIT | `host/templates/claude/commands/sync-triage-proposals.md` |
| EDIT | `host/templates/claude/skills/sync-triage-proposals/SKILL.md` |
| EDIT | `host/templates/claude/commands/sync-submit-proposal.md` |
| EDIT | `host/templates/claude/commands/e3-plan-implementation.md` |
| EDIT | `CLAUDE.md` |
| EDIT | `host/templates/claude/commands/f1-propose-update.md` |
| EDIT | `host/templates/claude/commands/f4-regen-framework.md` |
| EDIT | `host/templates/claude/commands/sync-import-shamt.md` |
| EDIT | `host/templates/claude/skills/sync-import-shamt/SKILL.md` |
| EDIT | `host/templates/claude/commands/e1-start-story.md` |
| EDIT | `CHEATSHEET.md` |

No optional rows. If a path is not in this manifest, it must not be edited during execution.

---

## Review Prevention Gate Mapping

**N/A — framework-update altitude.** Every step is a textual deletion / rephrase in agent-instruction / Notes / heading prose. No regulated data, tenant isolation, auth/route, database, infrastructure, frontend, test, or security-check surface is touched. No gate applies.

---

## Implementation Steps

### Step 0: Create the proposal branch
**Operation:** BRANCH
**Details:**
- Run: `git checkout -b proposal/03-purge-build-phase-numbers-from-host-bodies` from `main`.
- If the branch already exists, stop and report (do not overwrite/reset).

**Verification:** `git branch --show-current` prints `proposal/03-purge-build-phase-numbers-from-host-bodies`.

---

### Step 1: Remove "(Phase 8)" at two sites in sync-triage command (Proposed Changes row 1)
**Operation:** EDIT
**File:** `host/templates/claude/commands/sync-triage-proposals.md`
**Details — two replacements:**
- **1a (line 9):**
  - Locate: `The rest of the framework-update flow (Phase 8) runs as separate commands.`
  - Replace: `The rest of the framework-update flow runs as separate commands.`
- **1b (line 170):**
  - Locate: `This matches every other master-side phase in the framework-update flow (Phase 8) and keeps each phase independently runnable.`
  - Replace: `This matches every other master-side phase in the framework-update flow and keeps each phase independently runnable.`

**Verification:** `grep -n "(Phase 8)" host/templates/claude/commands/sync-triage-proposals.md` returns nothing.

---

### Step 2: Rephrase "in Phase 8" → "in the framework-update flow" in sync-triage skill (row 2)
**Operation:** EDIT
**File:** `host/templates/claude/skills/sync-triage-proposals/SKILL.md`
**Details:**
- Locate: `This matches every other master-side phase in Phase 8 and keeps the slug-resumability contract intact`
- Replace: `This matches every other master-side phase in the framework-update flow and keeps the slug-resumability contract intact`
- (Pure-delete is wrong here — "Phase 8" stands in for the flow name, so it is replaced, not removed.)

**Verification:** `grep -cF 'every other master-side phase in Phase 8 and keeps' host/templates/claude/skills/sync-triage-proposals/SKILL.md` → 0 (locate gone); `grep -cF 'every other master-side phase in the framework-update flow and keeps' host/templates/claude/skills/sync-triage-proposals/SKILL.md` → 1 (replacement present). (Footer-immune — does not grep a bare "Phase 8".)

---

### Step 3: Remove "(Phase 8)" in sync-submit command (row 3)
**Operation:** EDIT
**File:** `host/templates/claude/commands/sync-submit-proposal.md`
**Details:**
- Locate: `the rest of the Part 3 framework-update flow (Phase 8) instead.`
- Replace: `the rest of the Part 3 framework-update flow instead.`

**Verification:** `grep -n "(Phase 8)" host/templates/claude/commands/sync-submit-proposal.md` returns nothing.

---

### Step 4: Drop "— lands in Phase 6 of the build plan" in e3 (row 4)
**Operation:** EDIT
**File:** `host/templates/claude/commands/e3-plan-implementation.md`
**Details:**
- Locate: `/e4-execute-plan {slug}` (Phase 4, Build — lands in Phase 6 of the build plan).
  - Exact string: `` `/e4-execute-plan {slug}` (Phase 4, Build — lands in Phase 6 of the build plan). ``
  - Replace with: `` `/e4-execute-plan {slug}` (Phase 4, Build). ``

**Verification:** `grep -n "build plan" host/templates/claude/commands/e3-plan-implementation.md` returns nothing.

---

### Step 5: Refresh CLAUDE.md §"How changes land" — three sub-edits (row 5)
**Operation:** EDIT
**File:** `CLAUDE.md`
**Details — three replacements:**
- **5a (line 41 — delete the now-satisfied conditional prefix, capitalize "The"):**
  - Locate: `Once Phase 8 is built, the **framework-update flow** is the supported way to change anything in this folder:`
  - Replace: `The **framework-update flow** is the supported way to change anything in this folder:`
- **5b (line 49 — delete the obsolete pre-ship fallback sentence and the blank line above it):**
  - Locate (note: includes the preceding list item line + the blank line + the sentence):
    ```
    5. Archive the proposal to `proposals/archive/{slug}.md`.

    Until Phase 8 lands, treat this list as the **target shape** — propose changes in chat, validate manually using Pattern 1, edit the canonical file, and note what should later become a `proposals/` entry.
    ```
  - Replace:
    ```
    5. Archive the proposal to `proposals/archive/{slug}.md`.
    ```
- **5c (line 46 — `-Check` → `--check` spelling only; the rest of the line is untouched):**
  - Locate: ``4. Run the regen script in `-Check` mode against a known-clean child project to verify generated output stays sync'd.``
  - Replace: ``4. Run `scripts/regenerate-framework.sh --check` against a known-clean child project to verify generated output stays sync'd.``

**Verification:** `grep -nE "Phase 8|-Check" CLAUDE.md` returns nothing (the §"How changes land" block now reads present-tense with the `--check` spelling).

---

### Step 6: Drop "— Phase 9 wires the child-side submission" in f1 command (row 6)
**Operation:** EDIT
**File:** `host/templates/claude/commands/f1-propose-update.md`
**Details:**
- Locate: `The body is identical on both sides — Phase 9 wires the child-side submission.`
- Replace: `The body is identical on both sides.`
- (No substitute — the prior sentence already names `/sync-submit-proposal`.)

**Verification:** `grep -cF 'on both sides — Phase 9 wires the child-side submission.' host/templates/claude/commands/f1-propose-update.md` → 0 (locate gone); `grep -cF 'The body is identical on both sides.' host/templates/claude/commands/f1-propose-update.md` → 1 (replacement present).

---

### Step 7: Drop ", Phase 9" in f4 command (row 7)
**Operation:** EDIT
**File:** `host/templates/claude/commands/f4-regen-framework.md`
**Details:**
- Locate: `(`/sync-import-shamt` in child projects, Phase 9)`
- Replace: `(`/sync-import-shamt` in child projects)`

**Verification:** `grep -cF '(`/sync-import-shamt` in child projects, Phase 9)' host/templates/claude/commands/f4-regen-framework.md` → 0 (locate gone); `grep -cF '(`/sync-import-shamt` in child projects)' host/templates/claude/commands/f4-regen-framework.md` → 1 (replacement present).

---

### Step 8: Rephrase "Phase 9 rule" → "footer-contract rule" in sync-import command (row 8)
**Operation:** EDIT
**File:** `host/templates/claude/commands/sync-import-shamt.md`
**Details:**
- Locate: `The pragmatic Phase 9 rule is **subtree-level**`
- Replace: `The pragmatic footer-contract rule is **subtree-level**`
- (Replace, not pure-delete — "Phase 9 rule" needs a noun; the section is the Footer contract.)

**Verification:** `grep -cF 'The pragmatic Phase 9 rule' host/templates/claude/commands/sync-import-shamt.md` → 0 (locate gone); `grep -cF 'The pragmatic footer-contract rule' host/templates/claude/commands/sync-import-shamt.md` → 1 (replacement present). (Footer-immune.)

---

### Step 9: Drop the "(Phase 9 pragmatic rule)" heading label in sync-import skill (row 9)
**Operation:** EDIT
**File:** `host/templates/claude/skills/sync-import-shamt/SKILL.md`
**Details:**
- Locate: `## Footer contract (Phase 9 pragmatic rule)`
- Replace: `## Footer contract`

**Verification:** `grep -cF '(Phase 9 pragmatic rule)' host/templates/claude/skills/sync-import-shamt/SKILL.md` → 0 (the parenthetical label is gone); the heading line now reads exactly `## Footer contract`. (Footer-immune.)

---

### Step 10: Drop "(the original Phase 5 path)" in e1 command (row 10)
**Operation:** EDIT
**File:** `host/templates/claude/commands/e1-start-story.md`
**Details:**
- Locate: `this is a pre-existing freeform story (the original Phase 5 path).`
- Replace: `this is a pre-existing freeform story.`

**Verification:** `grep -cF 'a pre-existing freeform story (the original Phase 5 path).' host/templates/claude/commands/e1-start-story.md` → 0 (locate gone); `grep -cF 'this is a pre-existing freeform story. Confirm with the user' host/templates/claude/commands/e1-start-story.md` → 1 (replacement present). **Do NOT** grep a bare "original Phase 5" here — the line-136 validation footer ("…original Phase 5 flow preserved…") is a dated record and correctly remains.

---

### Step 11: Drop "the original Phase 5 path, " in CHEATSHEET.md (row 11)
**Operation:** EDIT
**File:** `CHEATSHEET.md`
**Details:**
- Locate: `Pre-existing freeform stories (the original Phase 5 path, no headers) behave unchanged.`
- Replace: `Pre-existing freeform stories (no headers) behave unchanged.`

**Verification:** `grep -cF 'Pre-existing freeform stories (the original Phase 5 path, no headers)' CHEATSHEET.md` → 0 (locate gone); `grep -cF 'Pre-existing freeform stories (no headers) behave unchanged.' CHEATSHEET.md` → 1 (replacement present). (CHEATSHEET's only other dev-build-phase strings — Phase 9/12 at the line-314 footer — are out of scope and untouched.)

---

## Final verification (after all steps)

Run the proposal's mandated completeness grep:

```
grep -rnE "Phase 8|Phase 9|build plan|original Phase [0-9]" host/templates/claude/ CHEATSHEET.md CLAUDE.md | grep -vE "implementation loop|implementation re-validation|implementation-validation|Validated 2026|Touched 2026"
```

**Expected:** zero results — every remaining `Phase 8|Phase 9|...` match must be a dated validation-footer line (out of scope). Any non-footer hit = an uncovered leak; halt and report.

---

## Notes

- All edits are pure textual deletions / rephrases in documentation prose. No executable instruction, step ordering, or heading body changes (Step 9 changes only a heading's parenthetical label).
- **No `.claude/` edits.** Phase 5 (`/f4-regen-framework`) propagates the 9 `host/templates/claude/` edits into `.claude/`; `CLAUDE.md` (Step 5) and `CHEATSHEET.md` (Step 11) are root canonical docs, not regenerated, and will not appear in the `--check` diff.
- **No commit in Phase 4.** The commit + squash-merge land at `/f6-archive-proposal`.

## CODING_STANDARDS Compliance

N/A — no project `CODING_STANDARDS.md` applies at the framework-update altitude; these are documentation-prose edits to canonical framework sources.

---

## Open Questions

(none — every step is mechanical with an exact locate + replacement)

---
Validated 2026-06-06 — 2 rounds, 1 adversarial sub-agent confirmed (round 1 hardened 7 per-step verifications from footer-collision-prone bare-phrase greps to the footer-immune old-locate-gone / new-string-present form — notably Step 10, whose bare "original Phase 5" grep would have false-failed on e1-start-story.md's line-136 validation footer; all 13 locate strings verified exact + unique against HEAD)
