# Implementation Plan: flow-phase-command-prefixes

**Proposal:** proposals/flow-phase-command-prefixes.md
**Created:** 2026-05-30
**File operations:** 108 (CREATE: 0, EDIT: 64, DELETE: 0, MOVE: 44) — MOVE: 22 command files + 22 skill folders; EDIT: 44 renamed-file bodies (Phase 2) + 20 other surfaces (Phase 3)

> **Decomposed plan.** This index plus three phase files. Each phase file is validated
> independently via `/validate-artifact`. Execute the phases in order: Phase 1 (renames)
> must complete before Phase 2 (edits inside the renamed files). Phase 3 edits independent
> surfaces; run it last so the whole rename is internally consistent.
>
> - [`flow-phase-command-prefixes_PLAN_phase_1.md`](flow-phase-command-prefixes_PLAN_phase_1.md) — the 22 command + 22 skill `git mv` renames (rows 1–22).
> - [`flow-phase-command-prefixes_PLAN_phase_2.md`](flow-phase-command-prefixes_PLAN_phase_2.md) — in-renamed-file edits: frontmatter / title / usage / footer + inter-command cross-reference sweeps (rows 23–25).
> - [`flow-phase-command-prefixes_PLAN_phase_3.md`](flow-phase-command-prefixes_PLAN_phase_3.md) — cross-reference sweeps in the other canonical surfaces (rows 26–32; row 31's persona set is plan-executor + test-executor + audit-checker).

---

## The rename map (canonical — referenced by all three phases)

Every step in every phase applies **this map and only this map**. A token not in the left column is never rewritten.

| Old slash command | New slash command | Flow / phase |
|-------------------|-------------------|--------------|
| `/start-story` | `/e1-start-story` | Engineer 1 |
| `/define-spec` | `/e2-define-spec` | Engineer 2 |
| `/plan-implementation` | `/e3-plan-implementation` | Engineer 3 |
| `/write-testing-plan` | `/e3b-write-testing-plan` | Engineer 3 sub-phase |
| `/execute-plan` | `/e4-execute-plan` | Engineer 4 |
| `/execute-tests` | `/e5-execute-tests` | Engineer 5 |
| `/write-manual-testing-plan` | `/e5b-write-manual-testing-plan` | Engineer post-Build |
| `/review-changes` | `/e6-review-changes` | Engineer 6 |
| `/resolve-feedback` | `/e7-resolve-feedback` | Engineer 7 |
| `/start-epic` | `/p1-start-epic` | PO 1 |
| `/decompose-epic` | `/p2-decompose-epic` | PO 2 |
| `/start-feature` | `/p3-start-feature` | PO 3 |
| `/decompose-feature` | `/p4-decompose-feature` | PO 4 |
| `/propose-update` | `/f1-propose-update` | framework-update 1 |
| `/plan-update-implementation` | `/f2-plan-update-implementation` | framework-update 2 |
| `/implement-update` | `/f3-implement-update` | framework-update 3 |
| `/regen-framework` | `/f4-regen-framework` | framework-update 4 |
| `/audit-framework` | `/f5-audit-framework` | framework-update 5 |
| `/archive-proposal` | `/f6-archive-proposal` | framework-update 6 |
| `/submit-proposal` | `/sync-submit-proposal` | sync (child→master) |
| `/import-shamt` | `/sync-import-shamt` | sync (master→child) |
| `/triage-proposals` | `/sync-triage-proposals` | sync (master) |

**Two hard guards (apply in every phase):**

1. **`/validate-artifact` is NOT renamed.** It stays `/validate-artifact` everywhere — cross-cutting, the only command with no row in the map. Leave every occurrence untouched.
2. **`/import-shamt` is the *command*, `import-shamt.sh` is the *script*.** Rewrite `/import-shamt` → `/sync-import-shamt` **only when the next character is not `.`** (i.e. not the `/import-shamt.sh` path form). Path references such as `bash <child>/.shamt-core/import-shamt.sh`, `import-shamt.sh`, and the `regenerate-framework.sh` script keep their bare filenames.

There are **no substring collisions** among the other tokens (`/plan-implementation` ⊄ `/plan-update-implementation`; `/write-testing-plan` ⊄ `/write-manual-testing-plan`; `/start-epic` / `/start-feature` / `/start-story` and `/decompose-epic` / `/decompose-feature` are distinct prefixes). A token-exact `replace_all` per slash token is therefore deterministic for every token except `/import-shamt`, which carries guard 2.

---

## Pre-execution checklist

- [ ] On a clean working tree (or a worktree dedicated to this proposal).
- [ ] `proposals/flow-phase-command-prefixes.md` validation footer present (it is — Validated 2026-05-28, re-validated 2026-05-30).
- [ ] Branch created: `framework-update/flow-phase-command-prefixes` from the configured remote development branch. *(Currently on `framework-update/deprecate-changes-md` — confirm with the user whether to reuse or cut a fresh branch before Phase 1.)*

---

## Files manifest (all phases)

| Operation | Count | Where |
|-----------|-------|-------|
| MOVE (`git mv`) | 44 | 22 command files + 22 skill folders (Phase 1) |
| EDIT | 22 | renamed command bodies — frontmatter/title/usage/footer + inter-command sweep (Phase 2) |
| EDIT | 22 | renamed `SKILL.md` bodies — frontmatter/title/mirror/footer + protocol-body command refs (Phase 2) |
| EDIT | 20 | CHEATSHEET, SHAMT_RULES.template, 5 artifact templates, _template, 7 reference files, 3 personas, 2 scripts (Phase 3) |

`/validate-artifact.md` and `skills/validate-artifact/` are **not** moved or renamed.

---

## Verification (post-execution — run after all three phases)

- [ ] Every row in the proposal's Proposed Changes table maps to at least one executed step (cross-check table below).
- [ ] No old-named command/skill remains:
      `ls host/templates/claude/commands/ | grep -vE '^(e[0-9]|p[0-9]|f[0-9]|sync-|validate-artifact)'` returns nothing.
- [ ] **No edits landed in generated `.claude/` paths** — `git status --short` shows no `.claude/` changes.
- [ ] Zero stale slash references survive (excluding the two guards):
      `grep -rEn '/(start-story|define-spec|plan-implementation|write-testing-plan|execute-plan|execute-tests|write-manual-testing-plan|review-changes|resolve-feedback|start-epic|decompose-epic|start-feature|decompose-feature|propose-update|plan-update-implementation|implement-update|regen-framework|audit-framework|archive-proposal|submit-proposal|triage-proposals)' CHEATSHEET.md templates/ reference/ proposals/_template.md *.sh host/templates/claude/ | grep -v 'import-shamt\.sh'`
      returns **nothing**.
- [ ] No stale command-form `/import-shamt` survives (the sweep above omits `import-shamt` to protect the `.sh` path form; this catches a missed command rewrite, the `([^.]|$)` suffix skipping `import-shamt.sh`):
      `grep -rEn '/import-shamt([^.]|$)' CHEATSHEET.md templates/ reference/ proposals/_template.md *.sh host/templates/claude/`
      returns **nothing**.
- [ ] `/import-shamt.sh` path form not corrupted: `grep -rn 'sync-import-shamt\.sh' .` returns nothing.
- [ ] `git log --follow --oneline host/templates/claude/commands/e2-define-spec.md` shows pre-rename history (proves `git mv` preserved history).

---

## Proposed-Changes → plan-step cross-check

| Proposal row | Operation | Covered by |
|--------------|-----------|------------|
| 1–22 (command + skill renames) | MOVE | Phase 1, Steps 1–22 (each = two `git mv`) |
| 23 (skill frontmatter/path/footer) | EDIT | Phase 2, Steps S1–S22 |
| 24 (command title/usage/footer) | EDIT | Phase 2, Steps C1–C22 |
| 25 (inter-command cross-ref sweep) | EDIT | Phase 2, folded into each C/S step (per-file token list) |
| 26 (CHEATSHEET.md) | EDIT | Phase 3, Step 1 |
| 27 (SHAMT_RULES.template.md) | EDIT | Phase 3, Step 2 |
| 28 (5 artifact templates) | EDIT | Phase 3, Steps 3–7 |
| 29 (proposals/_template.md) | EDIT | Phase 3, Step 8 |
| 30 (reference/ — 7 files) | EDIT | Phase 3, Steps 9–15 |
| 31 (personas — plan-executor + test-executor + audit-checker) | EDIT | Phase 3, Steps 16–17, 20 |
| 32 (init-shamt.sh + import-shamt.sh) | EDIT | Phase 3, Steps 18–19 (both edited — `import-shamt.sh` carries `/submit-proposal` + `/propose-update` in comments) |

All 32 rows covered. Step 20 (`audit-checker.md`) covers the third row-31 persona; `review-executor.md` and `validation-checker.md` are correctly out of scope (they reference only `/validate-artifact`).

---

## Notes

- **Framework-altitude omissions** (per the `/plan-update-implementation` command body): this plan carries **no** Review Prevention Gate Mapping and **no** CODING_STANDARDS Compliance mapping. `plan-executor` treats both as N/A.
- **`scripts/regenerate-framework.sh` is NOT edited.** It iterates `commands/*` and `skills/*` by directory, so renamed files propagate and old ones prune automatically on the next regen.
- **Out of scope (not edited):** `../INFRASTRUCTURE.md`, `../CLAUDE.md`, in-flight proposals (e.g. `proposals/dot-shamt-core-layout.md`), `agents/validation-checker.md`, `agents/review-executor.md` (they reference only `/validate-artifact`), and `templates/architecture.template.md` / `templates/coding_standards.template.md` (they reference only `/validate-artifact`). **`agents/audit-checker.md` IS edited** (Phase 3, Step 20 — it carries `/audit-framework` ×2).
- **Phase 5 (regen) follows this plan, not part of it:** after `/f3-implement-update` lands these edits, run `/f4-regen-framework` (or `bash scripts/regenerate-framework.sh` directly, since `.claude/` will by then carry the renamed regen command) to propagate into `.claude/`, then `--check` for zero drift.
- **`statusline.sh` is correctly out of scope** — it emits phase *names* + `P{N}`, no command names.

---
Validated 2026-05-30 — 3 rounds, 1 adversarial sub-agent confirmed (corrected 2 CRITICAL — review-executor was a spurious edit/banner; audit-checker was a missed `/audit-framework` ×2 persona — and 1 HIGH: Phase 2 ALSO-token tables re-derived from the tree, ~38/44 rows had been wrong. One repeated Haiku sub-agent "Step 9 count" finding adjudicated FALSE: `grep -oE '/audit-framework' reference/audit_dimensions.md | wc -l` = 4, exactly as the plan states.)
