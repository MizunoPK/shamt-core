# Implementation Plan — Phase 1: command + skill renames

**Proposal:** proposals/flow-phase-command-prefixes.md
**Parent plan:** proposals/flow-phase-command-prefixes_PLAN.md
**Created:** 2026-05-30
**File operations:** 44 MOVE (22 command files + 22 skill folders)

Covers **proposal rows 1–22**. Each row is **two** `git mv` operations executed together: the command `.md` file and its mirrored skill folder. History-preserving renames. **No file content changes in this phase** — frontmatter/title/footer edits are Phase 2.

## Pre-execution checklist

- [ ] On branch `framework-update/flow-phase-command-prefixes` (or the confirmed reuse branch).
- [ ] Working tree clean except for this proposal's own files.
- [ ] `cd host/templates/claude` is **not** assumed — every path below is repo-root-relative from `shamt-core/`.

## Files manifest

| # | From | To | Op |
|---|------|----|----|
| 1 | `host/templates/claude/commands/start-story.md` | `…/commands/e1-start-story.md` | MOVE |
| 1 | `host/templates/claude/skills/start-story/` | `…/skills/e1-start-story/` | MOVE |
| 2 | `…/commands/define-spec.md` | `…/commands/e2-define-spec.md` | MOVE |
| 2 | `…/skills/define-spec/` | `…/skills/e2-define-spec/` | MOVE |
| 3 | `…/commands/plan-implementation.md` | `…/commands/e3-plan-implementation.md` | MOVE |
| 3 | `…/skills/plan-implementation/` | `…/skills/e3-plan-implementation/` | MOVE |
| 4 | `…/commands/write-testing-plan.md` | `…/commands/e3b-write-testing-plan.md` | MOVE |
| 4 | `…/skills/write-testing-plan/` | `…/skills/e3b-write-testing-plan/` | MOVE |
| 5 | `…/commands/execute-plan.md` | `…/commands/e4-execute-plan.md` | MOVE |
| 5 | `…/skills/execute-plan/` | `…/skills/e4-execute-plan/` | MOVE |
| 6 | `…/commands/execute-tests.md` | `…/commands/e5-execute-tests.md` | MOVE |
| 6 | `…/skills/execute-tests/` | `…/skills/e5-execute-tests/` | MOVE |
| 7 | `…/commands/write-manual-testing-plan.md` | `…/commands/e5b-write-manual-testing-plan.md` | MOVE |
| 7 | `…/skills/write-manual-testing-plan/` | `…/skills/e5b-write-manual-testing-plan/` | MOVE |
| 8 | `…/commands/review-changes.md` | `…/commands/e6-review-changes.md` | MOVE |
| 8 | `…/skills/review-changes/` | `…/skills/e6-review-changes/` | MOVE |
| 9 | `…/commands/resolve-feedback.md` | `…/commands/e7-resolve-feedback.md` | MOVE |
| 9 | `…/skills/resolve-feedback/` | `…/skills/e7-resolve-feedback/` | MOVE |
| 10 | `…/commands/start-epic.md` | `…/commands/p1-start-epic.md` | MOVE |
| 10 | `…/skills/start-epic/` | `…/skills/p1-start-epic/` | MOVE |
| 11 | `…/commands/decompose-epic.md` | `…/commands/p2-decompose-epic.md` | MOVE |
| 11 | `…/skills/decompose-epic/` | `…/skills/p2-decompose-epic/` | MOVE |
| 12 | `…/commands/start-feature.md` | `…/commands/p3-start-feature.md` | MOVE |
| 12 | `…/skills/start-feature/` | `…/skills/p3-start-feature/` | MOVE |
| 13 | `…/commands/decompose-feature.md` | `…/commands/p4-decompose-feature.md` | MOVE |
| 13 | `…/skills/decompose-feature/` | `…/skills/p4-decompose-feature/` | MOVE |
| 14 | `…/commands/propose-update.md` | `…/commands/f1-propose-update.md` | MOVE |
| 14 | `…/skills/propose-update/` | `…/skills/f1-propose-update/` | MOVE |
| 15 | `…/commands/plan-update-implementation.md` | `…/commands/f2-plan-update-implementation.md` | MOVE |
| 15 | `…/skills/plan-update-implementation/` | `…/skills/f2-plan-update-implementation/` | MOVE |
| 16 | `…/commands/implement-update.md` | `…/commands/f3-implement-update.md` | MOVE |
| 16 | `…/skills/implement-update/` | `…/skills/f3-implement-update/` | MOVE |
| 17 | `…/commands/regen-framework.md` | `…/commands/f4-regen-framework.md` | MOVE |
| 17 | `…/skills/regen-framework/` | `…/skills/f4-regen-framework/` | MOVE |
| 18 | `…/commands/audit-framework.md` | `…/commands/f5-audit-framework.md` | MOVE |
| 18 | `…/skills/audit-framework/` | `…/skills/f5-audit-framework/` | MOVE |
| 19 | `…/commands/archive-proposal.md` | `…/commands/f6-archive-proposal.md` | MOVE |
| 19 | `…/skills/archive-proposal/` | `…/skills/f6-archive-proposal/` | MOVE |
| 20 | `…/commands/submit-proposal.md` | `…/commands/sync-submit-proposal.md` | MOVE |
| 20 | `…/skills/submit-proposal/` | `…/skills/sync-submit-proposal/` | MOVE |
| 21 | `…/commands/import-shamt.md` | `…/commands/sync-import-shamt.md` | MOVE |
| 21 | `…/skills/import-shamt/` | `…/skills/sync-import-shamt/` | MOVE |
| 22 | `…/commands/triage-proposals.md` | `…/commands/sync-triage-proposals.md` | MOVE |
| 22 | `…/skills/triage-proposals/` | `…/skills/sync-triage-proposals/` | MOVE |

`validate-artifact.md` and `skills/validate-artifact/` are **not** in this manifest — they are not renamed.

---

## Step-by-step

> All steps run from the repo root (`shamt-core/`). Each step is two `git mv` commands.
> If a `git mv` reports the source missing, **halt** — a prior step already moved it or
> the working tree is not at the expected baseline.

### Step 1 — Rename Engineer Phase 1 (start-story)
**Operation:** MOVE
**Commands:**
```
git mv host/templates/claude/commands/start-story.md host/templates/claude/commands/e1-start-story.md
git mv host/templates/claude/skills/start-story host/templates/claude/skills/e1-start-story
```
**Verification:** `test -f host/templates/claude/commands/e1-start-story.md && test -f host/templates/claude/skills/e1-start-story/SKILL.md && ! test -e host/templates/claude/commands/start-story.md`

### Step 2 — Rename Engineer Phase 2 (define-spec)
**Operation:** MOVE
**Commands:**
```
git mv host/templates/claude/commands/define-spec.md host/templates/claude/commands/e2-define-spec.md
git mv host/templates/claude/skills/define-spec host/templates/claude/skills/e2-define-spec
```
**Verification:** `test -f host/templates/claude/commands/e2-define-spec.md && test -f host/templates/claude/skills/e2-define-spec/SKILL.md && ! test -e host/templates/claude/commands/define-spec.md`

### Step 3 — Rename Engineer Phase 3 (plan-implementation)
**Operation:** MOVE
**Commands:**
```
git mv host/templates/claude/commands/plan-implementation.md host/templates/claude/commands/e3-plan-implementation.md
git mv host/templates/claude/skills/plan-implementation host/templates/claude/skills/e3-plan-implementation
```
**Verification:** `test -f host/templates/claude/commands/e3-plan-implementation.md && test -f host/templates/claude/skills/e3-plan-implementation/SKILL.md && ! test -e host/templates/claude/commands/plan-implementation.md`

### Step 4 — Rename Engineer Phase 3 sub-phase (write-testing-plan)
**Operation:** MOVE
**Commands:**
```
git mv host/templates/claude/commands/write-testing-plan.md host/templates/claude/commands/e3b-write-testing-plan.md
git mv host/templates/claude/skills/write-testing-plan host/templates/claude/skills/e3b-write-testing-plan
```
**Verification:** `test -f host/templates/claude/commands/e3b-write-testing-plan.md && test -f host/templates/claude/skills/e3b-write-testing-plan/SKILL.md && ! test -e host/templates/claude/commands/write-testing-plan.md`

### Step 5 — Rename Engineer Phase 4 (execute-plan)
**Operation:** MOVE
**Commands:**
```
git mv host/templates/claude/commands/execute-plan.md host/templates/claude/commands/e4-execute-plan.md
git mv host/templates/claude/skills/execute-plan host/templates/claude/skills/e4-execute-plan
```
**Verification:** `test -f host/templates/claude/commands/e4-execute-plan.md && test -f host/templates/claude/skills/e4-execute-plan/SKILL.md && ! test -e host/templates/claude/commands/execute-plan.md`

### Step 6 — Rename Engineer Phase 5 (execute-tests)
**Operation:** MOVE
**Commands:**
```
git mv host/templates/claude/commands/execute-tests.md host/templates/claude/commands/e5-execute-tests.md
git mv host/templates/claude/skills/execute-tests host/templates/claude/skills/e5-execute-tests
```
**Verification:** `test -f host/templates/claude/commands/e5-execute-tests.md && test -f host/templates/claude/skills/e5-execute-tests/SKILL.md && ! test -e host/templates/claude/commands/execute-tests.md`

### Step 7 — Rename Engineer post-Build optional (write-manual-testing-plan)
**Operation:** MOVE
**Commands:**
```
git mv host/templates/claude/commands/write-manual-testing-plan.md host/templates/claude/commands/e5b-write-manual-testing-plan.md
git mv host/templates/claude/skills/write-manual-testing-plan host/templates/claude/skills/e5b-write-manual-testing-plan
```
**Verification:** `test -f host/templates/claude/commands/e5b-write-manual-testing-plan.md && test -f host/templates/claude/skills/e5b-write-manual-testing-plan/SKILL.md && ! test -e host/templates/claude/commands/write-manual-testing-plan.md`

### Step 8 — Rename Engineer Phase 6 (review-changes)
**Operation:** MOVE
**Commands:**
```
git mv host/templates/claude/commands/review-changes.md host/templates/claude/commands/e6-review-changes.md
git mv host/templates/claude/skills/review-changes host/templates/claude/skills/e6-review-changes
```
**Verification:** `test -f host/templates/claude/commands/e6-review-changes.md && test -f host/templates/claude/skills/e6-review-changes/SKILL.md && ! test -e host/templates/claude/commands/review-changes.md`

### Step 9 — Rename Engineer Phase 7 (resolve-feedback)
**Operation:** MOVE
**Commands:**
```
git mv host/templates/claude/commands/resolve-feedback.md host/templates/claude/commands/e7-resolve-feedback.md
git mv host/templates/claude/skills/resolve-feedback host/templates/claude/skills/e7-resolve-feedback
```
**Verification:** `test -f host/templates/claude/commands/e7-resolve-feedback.md && test -f host/templates/claude/skills/e7-resolve-feedback/SKILL.md && ! test -e host/templates/claude/commands/resolve-feedback.md`

### Step 10 — Rename PO Phase 1 (start-epic)
**Operation:** MOVE
**Commands:**
```
git mv host/templates/claude/commands/start-epic.md host/templates/claude/commands/p1-start-epic.md
git mv host/templates/claude/skills/start-epic host/templates/claude/skills/p1-start-epic
```
**Verification:** `test -f host/templates/claude/commands/p1-start-epic.md && test -f host/templates/claude/skills/p1-start-epic/SKILL.md && ! test -e host/templates/claude/commands/start-epic.md`

### Step 11 — Rename PO Phase 2 (decompose-epic)
**Operation:** MOVE
**Commands:**
```
git mv host/templates/claude/commands/decompose-epic.md host/templates/claude/commands/p2-decompose-epic.md
git mv host/templates/claude/skills/decompose-epic host/templates/claude/skills/p2-decompose-epic
```
**Verification:** `test -f host/templates/claude/commands/p2-decompose-epic.md && test -f host/templates/claude/skills/p2-decompose-epic/SKILL.md && ! test -e host/templates/claude/commands/decompose-epic.md`

### Step 12 — Rename PO Phase 3 (start-feature)
**Operation:** MOVE
**Commands:**
```
git mv host/templates/claude/commands/start-feature.md host/templates/claude/commands/p3-start-feature.md
git mv host/templates/claude/skills/start-feature host/templates/claude/skills/p3-start-feature
```
**Verification:** `test -f host/templates/claude/commands/p3-start-feature.md && test -f host/templates/claude/skills/p3-start-feature/SKILL.md && ! test -e host/templates/claude/commands/start-feature.md`

### Step 13 — Rename PO Phase 4 (decompose-feature)
**Operation:** MOVE
**Commands:**
```
git mv host/templates/claude/commands/decompose-feature.md host/templates/claude/commands/p4-decompose-feature.md
git mv host/templates/claude/skills/decompose-feature host/templates/claude/skills/p4-decompose-feature
```
**Verification:** `test -f host/templates/claude/commands/p4-decompose-feature.md && test -f host/templates/claude/skills/p4-decompose-feature/SKILL.md && ! test -e host/templates/claude/commands/decompose-feature.md`

### Step 14 — Rename framework-update Phase 1 (propose-update)
**Operation:** MOVE
**Commands:**
```
git mv host/templates/claude/commands/propose-update.md host/templates/claude/commands/f1-propose-update.md
git mv host/templates/claude/skills/propose-update host/templates/claude/skills/f1-propose-update
```
**Verification:** `test -f host/templates/claude/commands/f1-propose-update.md && test -f host/templates/claude/skills/f1-propose-update/SKILL.md && ! test -e host/templates/claude/commands/propose-update.md`

### Step 15 — Rename framework-update Phase 2 (plan-update-implementation)
**Operation:** MOVE
**Commands:**
```
git mv host/templates/claude/commands/plan-update-implementation.md host/templates/claude/commands/f2-plan-update-implementation.md
git mv host/templates/claude/skills/plan-update-implementation host/templates/claude/skills/f2-plan-update-implementation
```
**Verification:** `test -f host/templates/claude/commands/f2-plan-update-implementation.md && test -f host/templates/claude/skills/f2-plan-update-implementation/SKILL.md && ! test -e host/templates/claude/commands/plan-update-implementation.md`

### Step 16 — Rename framework-update Phase 3 (implement-update)
**Operation:** MOVE
**Commands:**
```
git mv host/templates/claude/commands/implement-update.md host/templates/claude/commands/f3-implement-update.md
git mv host/templates/claude/skills/implement-update host/templates/claude/skills/f3-implement-update
```
**Verification:** `test -f host/templates/claude/commands/f3-implement-update.md && test -f host/templates/claude/skills/f3-implement-update/SKILL.md && ! test -e host/templates/claude/commands/implement-update.md`

### Step 17 — Rename framework-update Phase 4 (regen-framework)
**Operation:** MOVE
**Commands:**
```
git mv host/templates/claude/commands/regen-framework.md host/templates/claude/commands/f4-regen-framework.md
git mv host/templates/claude/skills/regen-framework host/templates/claude/skills/f4-regen-framework
```
**Verification:** `test -f host/templates/claude/commands/f4-regen-framework.md && test -f host/templates/claude/skills/f4-regen-framework/SKILL.md && ! test -e host/templates/claude/commands/regen-framework.md`

### Step 18 — Rename framework-update Phase 5 (audit-framework)
**Operation:** MOVE
**Commands:**
```
git mv host/templates/claude/commands/audit-framework.md host/templates/claude/commands/f5-audit-framework.md
git mv host/templates/claude/skills/audit-framework host/templates/claude/skills/f5-audit-framework
```
**Verification:** `test -f host/templates/claude/commands/f5-audit-framework.md && test -f host/templates/claude/skills/f5-audit-framework/SKILL.md && ! test -e host/templates/claude/commands/audit-framework.md`

### Step 19 — Rename framework-update Phase 6 (archive-proposal)
**Operation:** MOVE
**Commands:**
```
git mv host/templates/claude/commands/archive-proposal.md host/templates/claude/commands/f6-archive-proposal.md
git mv host/templates/claude/skills/archive-proposal host/templates/claude/skills/f6-archive-proposal
```
**Verification:** `test -f host/templates/claude/commands/f6-archive-proposal.md && test -f host/templates/claude/skills/f6-archive-proposal/SKILL.md && ! test -e host/templates/claude/commands/archive-proposal.md`

### Step 20 — Rename sync child→master (submit-proposal)
**Operation:** MOVE
**Commands:**
```
git mv host/templates/claude/commands/submit-proposal.md host/templates/claude/commands/sync-submit-proposal.md
git mv host/templates/claude/skills/submit-proposal host/templates/claude/skills/sync-submit-proposal
```
**Verification:** `test -f host/templates/claude/commands/sync-submit-proposal.md && test -f host/templates/claude/skills/sync-submit-proposal/SKILL.md && ! test -e host/templates/claude/commands/submit-proposal.md`

### Step 21 — Rename sync master→child (import-shamt)
**Operation:** MOVE
**Commands:**
```
git mv host/templates/claude/commands/import-shamt.md host/templates/claude/commands/sync-import-shamt.md
git mv host/templates/claude/skills/import-shamt host/templates/claude/skills/sync-import-shamt
```
**Verification:** `test -f host/templates/claude/commands/sync-import-shamt.md && test -f host/templates/claude/skills/sync-import-shamt/SKILL.md && ! test -e host/templates/claude/commands/import-shamt.md`
**Note:** This renames the **command** file only. The **script** `import-shamt.sh` (at `shamt-core/import-shamt.sh`) is **not** moved.

### Step 22 — Rename sync master-side (triage-proposals)
**Operation:** MOVE
**Commands:**
```
git mv host/templates/claude/commands/triage-proposals.md host/templates/claude/commands/sync-triage-proposals.md
git mv host/templates/claude/skills/triage-proposals host/templates/claude/skills/sync-triage-proposals
```
**Verification:** `test -f host/templates/claude/commands/sync-triage-proposals.md && test -f host/templates/claude/skills/sync-triage-proposals/SKILL.md && ! test -e host/templates/claude/commands/triage-proposals.md`

---

## Verification (post-phase)

- [ ] Command directory holds exactly the 22 renamed files + `validate-artifact.md`:
      `ls host/templates/claude/commands/` → only `e1-…e7`, `e3b`, `e5b`, `p1-…p4`, `f1-…f6`, `sync-submit-proposal`, `sync-import-shamt`, `sync-triage-proposals`, `validate-artifact`.
- [ ] Skill directory mirrors it 1:1 (same 23 folder names, each containing `SKILL.md`).
- [ ] No old-named command/skill remains:
      `ls host/templates/claude/commands/ host/templates/claude/skills/ | grep -E '^(start-story|define-spec|plan-implementation|write-testing-plan|execute-plan|execute-tests|write-manual-testing-plan|review-changes|resolve-feedback|start-epic|decompose-epic|start-feature|decompose-feature|propose-update|plan-update-implementation|implement-update|regen-framework|audit-framework|archive-proposal|submit-proposal|import-shamt|triage-proposals)(\.md)?$'`
      returns nothing.
- [ ] `import-shamt.sh` script still present at `shamt-core/import-shamt.sh`.
- [ ] `git status --short` shows only `R` (rename) entries under `host/templates/claude/`, no `.claude/` changes.

## Notes

- **File contents are unchanged in Phase 1.** The renamed files still carry their old `# /old-name` titles, old footers, and old frontmatter — those are fixed in Phase 2. Do not edit content here.
- **`git mv` (not `mv`)** is mandatory — it preserves history (rollback feasibility, proposal Risks). If `git mv` fails because the file is not tracked, halt and report.
- **No commit in this phase.** `git mv` both moves *and* stages each file, but Phase 1 creates **no commit of its own**. The renames land in the single proposal commit together with the Phase 2/3 edits — the parent plan's rollback targets one "rename commit" ("the MOVEs and text edits land together"), created when the user commits the landed work (Shamt defers commits to the user). Do **not** commit per-phase: it would fragment that single rename commit, and Phase 2 needs only the renamed working-tree files (staged-but-uncommitted is sufficient), not a commit.

---
Validated 2026-05-30 — 3 rounds, 1 adversarial sub-agent confirmed (validated as part of the decomposed plan set)
Re-validated 2026-05-30 — 2 rounds, 1 adversarial sub-agent confirmed (independent /validate-artifact; added a Notes bullet clarifying Phase 1 stages but does not commit — renames land in the single proposal commit, adjudicated LOW not CRITICAL).
