# Implementation Plan — Phase 3: cross-reference sweeps in other canonical surfaces

**Proposal:** proposals/flow-phase-command-prefixes.md
**Parent plan:** proposals/flow-phase-command-prefixes_PLAN.md
**Created:** 2026-05-30
**File operations:** 20 EDIT (CHEATSHEET, SHAMT_RULES.template, 5 artifact templates, _template, 7 reference files, 3 personas, 2 scripts)

Covers **proposal rows 26–32** (row 31 persona set: plan-executor + test-executor + audit-checker). Independent of Phases 1–2 in target (non-renamed surfaces) but run last so the whole rename is internally consistent. Apply the parent-plan rename map with **both guards**.

> **Token lists below are authoritative** — each was derived from a per-file
> `grep -oE '/<token>' | sort | uniq -c` inventory of the *current* tree, then the
> `/import-shamt` rows were split into command-form vs `.sh`-path-form by a second
> `grep -oE '/import-shamt([^.]|$)'`. Only tokens actually present in a file are listed.

## Per-step mechanic (uniform)

Each step is an **EDIT** on one file. For every listed old slash token, `replace_all` it with its mapped new token. Then run the per-step verification grep — it must return nothing.

**Guards (every step):**
- `/validate-artifact` → **leave unchanged** wherever it appears.
- `/import-shamt` → `/sync-import-shamt` **only when not followed by `.`**. Never touch `import-shamt.sh`, `.shamt-core/import-shamt.sh`, or `regenerate-framework.sh`.
- **Bare (non-slash) operation mentions are out of scope** — backticked `` `import-shamt` ``, the word "regen", `import-shamt.sh`, `regenerate-framework.sh` — denote the *operation/script*, not a slash-command invocation, and are **kept**. (Specifically: CHEATSHEET.md lines 3, 49, 216 `` `import-shamt` `` are deliberate KEEPs.)

---

## Pre-execution checklist

- [ ] Phases 1–2 complete (so the final whole-tree grep can confirm global consistency).

---

## Step-by-step

### Step 1 — CHEATSHEET.md (row 26)
**Operation:** EDIT
**File:** `CHEATSHEET.md`
**Tokens present → rewrite (replace_all each):**
`/archive-proposal`→`/f6-archive-proposal`, `/audit-framework`→`/f5-audit-framework`, `/decompose-epic`→`/p2-decompose-epic`, `/decompose-feature`→`/p4-decompose-feature`, `/define-spec`→`/e2-define-spec`, `/execute-plan`→`/e4-execute-plan`, `/execute-tests`→`/e5-execute-tests`, `/implement-update`→`/f3-implement-update`, `/import-shamt`→`/sync-import-shamt` *(4 command-form occurrences — lines ~38, 60, 180, 249)*, `/plan-implementation`→`/e3-plan-implementation`, `/plan-update-implementation`→`/f2-plan-update-implementation`, `/propose-update`→`/f1-propose-update`, `/regen-framework`→`/f4-regen-framework`, `/resolve-feedback`→`/e7-resolve-feedback`, `/review-changes`→`/e6-review-changes`, `/start-epic`→`/p1-start-epic`, `/start-feature`→`/p3-start-feature`, `/start-story`→`/e1-start-story`, `/submit-proposal`→`/sync-submit-proposal`, `/triage-proposals`→`/sync-triage-proposals`, `/write-manual-testing-plan`→`/e5b-write-manual-testing-plan`, `/write-testing-plan`→`/e3b-write-testing-plan`.
**Leave unchanged:** `/validate-artifact` (3); bare `` `import-shamt` `` (lines 3, 49, 216); all `import-shamt.sh` path forms (count is invariant — the edit rewrites only the `/import-shamt` command form, never the `.sh` path form).
**Covers:** Engineer/PO/framework-update/sync command tables, the persona "Used by" table (the `/execute-plan`, `/implement-update`, `/audit-framework`, `/execute-tests`, `/review-changes` mentions are swept by the same replace_all). The auto-triggered-skills note names no command token — no change.
**Verification:**
```
grep -nE '/(start-story|define-spec|plan-implementation|write-testing-plan|execute-plan|execute-tests|write-manual-testing-plan|review-changes|resolve-feedback|start-epic|decompose-epic|start-feature|decompose-feature|propose-update|plan-update-implementation|implement-update|regen-framework|audit-framework|archive-proposal|submit-proposal|triage-proposals|import-shamt)([^.]|$)' CHEATSHEET.md | grep -v 'import-shamt\.sh'
```
returns nothing (the `([^.]|$)` suffix excludes the `import-shamt.sh` path form, so a stale **command-form** `/import-shamt` is still caught — consistent with the Step 8 / Step 9 verifications). `grep -c '/validate-artifact' CHEATSHEET.md` == 3. `grep -c 'import-shamt\.sh' CHEATSHEET.md` is **unchanged** before vs after this step (the edit rewrites only the `/import-shamt` command form, never the `.sh` path form; the literal `.sh` path-form count is 8).

### Step 2 — templates/SHAMT_RULES.template.md (row 27)
**Operation:** EDIT
**Tokens present → rewrite:** `/define-spec`→`/e2-define-spec`, `/execute-plan`→`/e4-execute-plan`, `/plan-implementation`→`/e3-plan-implementation`, `/resolve-feedback`→`/e7-resolve-feedback`, `/start-story`→`/e1-start-story`, `/write-manual-testing-plan`→`/e5b-write-manual-testing-plan`.
**Verification:** `grep -nE '/(define-spec|execute-plan|plan-implementation|resolve-feedback|start-story|write-manual-testing-plan)' templates/SHAMT_RULES.template.md` returns nothing.

### Step 3 — templates/epic.template.md (row 28a)
**Operation:** EDIT
**Tokens present → rewrite:** `/decompose-epic`→`/p2-decompose-epic` (2), `/start-epic`→`/p1-start-epic` (3).
**Leave unchanged:** `/validate-artifact` (1).
**Verification:** `grep -nE '/(decompose-epic|start-epic)' templates/epic.template.md` returns nothing; `grep -c '/validate-artifact' templates/epic.template.md` == 1.

### Step 4 — templates/feature.template.md (row 28b)
**Operation:** EDIT
**Tokens present → rewrite:** `/decompose-feature`→`/p4-decompose-feature` (2), `/start-feature`→`/p3-start-feature` (4).
**Leave unchanged:** `/validate-artifact` (1).
**Verification:** `grep -nE '/(decompose-feature|start-feature)' templates/feature.template.md` returns nothing; `grep -c '/validate-artifact' templates/feature.template.md` == 1.

### Step 5 — templates/manual_test_plan.template.md (row 28c)
**Operation:** EDIT
**Tokens present → rewrite:** `/write-manual-testing-plan`→`/e5b-write-manual-testing-plan` (1).
**Leave unchanged:** `/validate-artifact` (1).
**Verification:** `grep -nE '/write-manual-testing-plan' templates/manual_test_plan.template.md` returns nothing; `grep -c '/validate-artifact' templates/manual_test_plan.template.md` == 1.

### Step 6 — templates/ticket.ado.template.md (row 28d)
**Operation:** EDIT
**Tokens present → rewrite:** `/decompose-feature`→`/p4-decompose-feature` (1), `/start-story`→`/e1-start-story` (1).
**Verification:** `grep -nE '/(decompose-feature|start-story)' templates/ticket.ado.template.md` returns nothing.

### Step 7 — templates/ticket.github.template.md (row 28e)
**Operation:** EDIT
**Tokens present → rewrite:** `/decompose-feature`→`/p4-decompose-feature` (1), `/start-story`→`/e1-start-story` (1).
**Verification:** `grep -nE '/(decompose-feature|start-story)' templates/ticket.github.template.md` returns nothing.

### Step 8 — proposals/_template.md (row 29)
**Operation:** EDIT
**File:** `proposals/_template.md` (the **canonical** proposal template)
**Tokens present → rewrite:** `/archive-proposal`→`/f6-archive-proposal` (3), `/implement-update`→`/f3-implement-update` (1), `/import-shamt`→`/sync-import-shamt` (1 command-form, line ~86), `/plan-update-implementation`→`/f2-plan-update-implementation` (1), `/propose-update`→`/f1-propose-update` (3), `/regen-framework`→`/f4-regen-framework` (2), `/triage-proposals`→`/sync-triage-proposals` (1).
**Leave unchanged:** `/validate-artifact` (3).
**Verification:** `grep -nE '/(archive-proposal|implement-update|import-shamt|plan-update-implementation|propose-update|regen-framework|triage-proposals)([^.]|$)' proposals/_template.md` returns nothing; `grep -c '/validate-artifact' proposals/_template.md` == 3.

### Step 9 — reference/audit_dimensions.md (row 30a)
**Operation:** EDIT
**Tokens present → rewrite:** `/audit-framework`→`/f5-audit-framework` (4 **occurrences**, spanning lines 3 and 92 — `grep -c` reports 2 *lines*, but the binding count is occurrences per the preamble; `grep -oE '/audit-framework' reference/audit_dimensions.md | wc -l` == 4), `/import-shamt`→`/sync-import-shamt` (1 command-form), `/propose-update`→`/f1-propose-update` (4), `/regen-framework`→`/f4-regen-framework` (1), `/submit-proposal`→`/sync-submit-proposal` (1).
**Verification:** `grep -nE '/(audit-framework|import-shamt|propose-update|regen-framework|submit-proposal)([^.]|$)' reference/audit_dimensions.md` returns nothing.

### Step 10 — reference/model_selection.md (row 30b)
**Operation:** EDIT
**Tokens present → rewrite:** `/archive-proposal`→`/f6-archive-proposal` (1), `/audit-framework`→`/f5-audit-framework` (2), `/implement-update`→`/f3-implement-update` (1), `/plan-update-implementation`→`/f2-plan-update-implementation` (1), `/propose-update`→`/f1-propose-update` (1), `/regen-framework`→`/f4-regen-framework` (1), `/write-manual-testing-plan`→`/e5b-write-manual-testing-plan` (1).
**Leave unchanged:** `/validate-artifact` (1).
**Verification:** `grep -nE '/(archive-proposal|audit-framework|implement-update|plan-update-implementation|propose-update|regen-framework|write-manual-testing-plan)' reference/model_selection.md` returns nothing; `grep -c '/validate-artifact' reference/model_selection.md` == 1.

### Step 11 — reference/story_support.md (row 30c)
**Operation:** EDIT
**Tokens present → rewrite:** `/write-manual-testing-plan`→`/e5b-write-manual-testing-plan` (1).
**Verification:** `grep -nE '/write-manual-testing-plan' reference/story_support.md` returns nothing.

### Step 12 — reference/trackers/_contract.md (row 30d)
**Operation:** EDIT
**Tokens present → rewrite:** `/review-changes`→`/e6-review-changes` (4), `/start-epic`→`/p1-start-epic` (4), `/start-feature`→`/p3-start-feature` (4), `/start-story`→`/e1-start-story` (7).
**Verification:** `grep -nE '/(review-changes|start-epic|start-feature|start-story)' reference/trackers/_contract.md` returns nothing.

### Step 13 — reference/trackers/ado.md (row 30e)
**Operation:** EDIT
**Tokens present → rewrite:** `/review-changes`→`/e6-review-changes` (3), `/start-epic`→`/p1-start-epic` (6), `/start-feature`→`/p3-start-feature` (6), `/start-story`→`/e1-start-story` (5).
**Verification:** `grep -nE '/(review-changes|start-epic|start-feature|start-story)' reference/trackers/ado.md` returns nothing.

### Step 14 — reference/trackers/github.md (row 30f)
**Operation:** EDIT
**Tokens present → rewrite:** `/review-changes`→`/e6-review-changes` (3), `/start-epic`→`/p1-start-epic` (7), `/start-feature`→`/p3-start-feature` (7), `/start-story`→`/e1-start-story` (6).
**Verification:** `grep -nE '/(review-changes|start-epic|start-feature|start-story)' reference/trackers/github.md` returns nothing.

### Step 15 — reference/trackers/local.md (row 30g)
**Operation:** EDIT
**Tokens present → rewrite:** `/decompose-feature`→`/p4-decompose-feature` (1), `/start-epic`→`/p1-start-epic` (3), `/start-feature`→`/p3-start-feature` (3), `/start-story`→`/e1-start-story` (7).
**Verification:** `grep -nE '/(decompose-feature|start-epic|start-feature|start-story)' reference/trackers/local.md` returns nothing.

### Step 16 — host/templates/claude/agents/plan-executor.md (row 31a)
**Operation:** EDIT
**Tokens present → rewrite:** `/execute-plan`→`/e4-execute-plan` (2), `/implement-update`→`/f3-implement-update` (3).
**Note:** the persona **file is not renamed** — only its body is swept.
**Verification:** `grep -nE '/(execute-plan|implement-update)' host/templates/claude/agents/plan-executor.md` returns nothing.

### Step 17 — host/templates/claude/agents/test-executor.md (row 31b)
**Operation:** EDIT
**Tokens present → rewrite:** `/write-testing-plan`→`/e3b-write-testing-plan` (1, line ~49).
**Note:** persona file not renamed; body only. test-executor references **no** `/execute-tests` slash token. `validation-checker.md` and `review-executor.md` reference only `/validate-artifact` → **no edit** (confirmed by the final whole-tree grep). `audit-checker.md` **does** need an edit — see Step 20.
**Verification:** `grep -nE '/write-testing-plan' host/templates/claude/agents/test-executor.md` returns nothing.

### Step 18 — init-shamt.sh (row 32a)
**Operation:** EDIT
**File:** `init-shamt.sh` — user-facing prompt/log strings and comments only; script *logic* untouched.
**Tokens present → rewrite (command-form):**
- `/submit-proposal`→`/sync-submit-proposal` (line ~244, prompt string).
- `/start-story`→`/e1-start-story` (lines ~249 prompt, ~503 log).
- `/review-changes`→`/e6-review-changes` (line ~254, prompt string).
- `/propose-update`→`/f1-propose-update` (line ~392, comment).
**Leave unchanged:** `/validate-artifact` (lines ~525, ~527); **all 5 `/import-shamt` occurrences are the `import-shamt.sh` path form** (lines ~95, 159, 162, 498, 500) — keep them; `import-shamt.sh` / `regenerate-framework.sh` filenames untouched.
**Verification:** `grep -nE '/(submit-proposal|start-story|review-changes|propose-update)' init-shamt.sh` returns nothing; `grep -c '/validate-artifact' init-shamt.sh` == 2; `grep -c 'import-shamt.sh' init-shamt.sh` unchanged.

### Step 19 — import-shamt.sh (row 32b)
**Operation:** EDIT
**File:** `import-shamt.sh` — comments only; script *logic* untouched. **(NOT a no-op.)**
**Tokens present → rewrite (command-form):**
- `/submit-proposal`→`/sync-submit-proposal` (line ~27, comment).
- `/propose-update`→`/f1-propose-update` (line ~308, comment).
**Leave unchanged:** **all 5 `/import-shamt` occurrences are the `import-shamt.sh` path form** (lines ~5, 83, 88, 123, 368) — keep them. The script's own filename, the managed footer `Regenerate from shamt-core/import-shamt.sh`, and every `.shamt-core/import-shamt.sh` path stay verbatim. **The script file is NOT renamed.**
**Verification:** `grep -nE '/(submit-proposal|propose-update)' import-shamt.sh` returns nothing; `grep -c 'import-shamt.sh' import-shamt.sh` unchanged; `grep -c 'sync-import-shamt' import-shamt.sh` == 0.

### Step 20 — host/templates/claude/agents/audit-checker.md (row 31c)
**Operation:** EDIT
**Tokens present → rewrite:** `/audit-framework`→`/f5-audit-framework` (2 — line 3 `description:` frontmatter and line 12 body).
**Leave unchanged:** nothing else — `audit-checker.md` names `/audit-framework` only (no `/validate-artifact`, no other command token).
**Note:** persona file not renamed; `description:` frontmatter + body only. This file was **omitted from the proposal's original row 31** (which wrongly stated audit-checker references only `/validate-artifact`); row 31 was corrected on 2026-05-30 to include it. `review-executor.md` and `validation-checker.md` genuinely reference only `/validate-artifact` → no edit. (Persona row 31c; numbered Step 20 — after the row-32 script steps — to match the parent plan's "personas → Steps 16–17, 20" mapping.)
**Verification:** `grep -c '/audit-framework' host/templates/claude/agents/audit-checker.md` == 0 and `grep -c '/f5-audit-framework' host/templates/claude/agents/audit-checker.md` == 2. (`/f5-audit-framework` does not contain the literal `/audit-framework`, so the zero-count check is exact.)

---

## Verification (post-phase)

Run from `shamt-core/`:

- [ ] **Whole-tree zero-stale sweep** (the single most important check):
```
grep -rEn '/(start-story|define-spec|plan-implementation|write-testing-plan|execute-plan|execute-tests|write-manual-testing-plan|review-changes|resolve-feedback|start-epic|decompose-epic|start-feature|decompose-feature|propose-update|plan-update-implementation|implement-update|regen-framework|audit-framework|archive-proposal|submit-proposal|triage-proposals)' CHEATSHEET.md templates/ reference/ proposals/_template.md *.sh host/templates/claude/ | grep -v 'import-shamt\.sh'
```
returns **nothing**.
- [ ] **`/validate-artifact` untouched:** total count across the swept surfaces equals the pre-Phase-3 count.
- [ ] **No stale command-form `/import-shamt`** (the 21-token sweep above excludes `import-shamt` to avoid the `.sh` path form; this dedicated check catches a missed command rewrite while the `([^.]|$)` suffix still skips `import-shamt.sh`):
```
grep -rEn '/import-shamt([^.]|$)' CHEATSHEET.md templates/ reference/ proposals/_template.md *.sh host/templates/claude/
```
returns **nothing**.
- [ ] **No `.sh` corruption:** `grep -rn 'sync-import-shamt\.sh' .` returns nothing.
- [ ] **No `.claude/` edits:** `git status --short` shows no `.claude/` paths.
- [ ] **Out-of-scope files untouched:** `git status --short` shows no changes to `../INFRASTRUCTURE.md`, `../CLAUDE.md`, `proposals/dot-shamt-core-layout.md`, `scripts/regenerate-framework.sh`, or `agents/{validation-checker,review-executor}.md`. (`audit-checker.md` **is** edited — Step 20.)

## Notes

- **`scripts/regenerate-framework.sh` is intentionally absent** — it iterates directories, not command names (proposal § "Scripts").
- **Counts in each step are advisory** (from a `uniq -c` inventory); the binding instruction is `replace_all` per token + the per-step zero-stale grep. A large discrepancy at execution time warrants a halt-and-report.
- **Both scripts edit comments / user-facing strings only** — no control-flow, no variable names, no `import-shamt.sh`/`regenerate-framework.sh` filenames. If a proposed rewrite would land inside a code line (assignment, `if`, path construction), **halt** — that is outside row 32's scope.
- **After this phase:** proceed to Phase 5 — `/f4-regen-framework` (or `bash scripts/regenerate-framework.sh`) to propagate all renames into `.claude/`, then `--check` for zero drift.

---
Validated 2026-05-30 — 3 rounds, 1 adversarial sub-agent confirmed (Step 20 retargeted to audit-checker; Step 1 + index/backstop verification extended with a dedicated `/import-shamt([^.]|$)` command-form check; Steps 1–19 token counts re-confirmed against the tree)
Re-validated 2026-05-30 — 2 rounds + 1 adversarial sub-agent. Fixed this pass: **HIGH** — Step 1 CHEATSHEET verification asserted `import-shamt.sh == 5` but the path-form count is 8 (invariant under the edit); rewritten as an invariant check. **MEDIUM** — step numbering was non-monotonic (…17, 20, 18, 19); reordered so headers read 1→20, with audit-checker kept at Step 20 (last) to match the parent plan's "personas → Steps 16–17, 20" mapping. **LOW** — bare backticked `import-shamt` enumerated as lines 3/49/216 (was "~49"). All 20 files' token counts independently re-verified against the tree. The sub-agent's sole finding — Step 9 `/audit-framework` "should be 2" — was adjudicated **FALSE**: 4 *occurrences* across 2 lines (3, 92); `grep -oE '/audit-framework' reference/audit_dimensions.md | wc -l` == 4. This is the same line-vs-occurrence misread the parent plan already adjudicated FALSE; Step 9 was annotated to preempt a third recurrence.
