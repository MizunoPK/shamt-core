# Implementation Plan — Phase 2: edits inside the renamed files

**Proposal:** proposals/flow-phase-command-prefixes.md
**Parent plan:** proposals/flow-phase-command-prefixes_PLAN.md
**Created:** 2026-05-30
**File operations:** 44 EDIT (22 renamed command bodies + 22 renamed `SKILL.md` bodies)

Covers **proposal rows 23, 24, 25**. **Run after Phase 1** — these edits target the *new* paths. Apply the rename map from the parent plan, honoring both guards (`/validate-artifact` untouched; `/import-shamt` → `/sync-import-shamt` only when not followed by `.`).

## Pre-execution checklist

- [ ] Phase 1 complete — all 22 command files and 22 skill folders carry their new names.
- [ ] A renamed file still carries its **old** title in its body — e.g. `grep -n '# /start-story' host/templates/claude/commands/e1-start-story.md` returns the old `# /start-story` title. (Phase 1 renamed the file; Phase 2 has not yet rewritten the body — proves Phase 2 not yet run.)

---

## The uniform per-file recipe

Phase 1 only changed filenames; every renamed file's **content still says the old name**. Two uniform shapes plus a per-file inter-command sweep.

### Recipe A — every renamed command body (`commands/{new}.md`)

For a file renamed `{old}.md` → `{new}.md` (e.g. `define-spec` → `e2-define-spec`):

1. **Title** — replace `# /{old}` with `# /{new}`. (Exactly one occurrence, line ~5.)
2. **Usage block** — replace the fenced `/{old} {slug}` (or `/{old} <path>`, `/{old} [...]`, or bare `/{old}`) with the `/{new}` form. Match the exact argument signature already present; only the command token changes.
3. **Managed footer** — replace `Regenerate from shamt-core/host/templates/claude/commands/{old}.md.` with `…/commands/{new}.md.` (Exactly one occurrence, last line.)
4. **`description:` frontmatter** — **no change** (contains no command token).
5. **Inter-command sweep (row 25)** — for every *other* old token listed for this file in the table below, replace each occurrence with its mapped new token (`replace_all`). Leave `/validate-artifact` as-is.

### Recipe B — every renamed skill body (`skills/{new}/SKILL.md`)

For a folder renamed `skills/{old}/` → `skills/{new}/`:

1. **`name:` frontmatter** — replace `name: {old}` with `name: {new}`. (Line 2.) This is the skill's **only** title surface: `SKILL.md` files carry **no Markdown H1** — the first body line is `## Overview` (verified across all 23 skills), so there is **no `# {old}` heading to rewrite**. Do not attempt one.
2. **Mirror line** — rewrite the `/{old}` token to `/{new}` *inside* the "mirrors the `/{old} …` slash command" sentence (preserve the exact argument signature). 21 skills read ``Mirrors the `/{old} {slug}` slash command``; **`start-story` (S1) instead reads "This skill mirrors the `/start-story {slug}` slash command"** — match the `/{old}` token, not a fixed lead-in phrase, so the rewrite lands regardless of wording.
3. **Command path reference** — replace `commands/{old}.md` with `commands/{new}.md` (the "see [`commands/{new}.md`]" protocol pointer; one or more occurrences — use `replace_all`).
4. **Managed footer** — replace `Regenerate from shamt-core/host/templates/claude/skills/{old}/SKILL.md.` with `…/skills/{new}/SKILL.md.`
5. **Inter-command sweep (row 25)** — for every *other* old token listed for this skill in the table below, replace each occurrence with its mapped new token. Leave `/validate-artifact` as-is.

> **Skill `description:` frontmatter** generally contains no slash-command token, but **verify per file** — if a `description:` line does contain an old token (it does not in the current set, per the grep inventory), apply the map there too.

---

## Per-file edit table

`SELF` = the file's own token (title/usage/name/mirror/footer, Recipes A1–A4 / B1–B4). `ALSO` = the extra old tokens to sweep in the body (Recipe A5 / B5). Tokens map per the parent plan. `/validate-artifact` is shown where present **only to flag it as intentionally left unchanged** — do **not** rewrite it.

### Command bodies (Steps C1–C22)

| Step | File (post-Phase-1 path) | SELF token | ALSO tokens to sweep | leave unchanged |
|------|--------------------------|-----------|----------------------|-----------------|
| C1 | `commands/e1-start-story.md` | `/start-story` | `/decompose-feature`, `/define-spec` | — |
| C2 | `commands/e2-define-spec.md` | `/define-spec` | `/plan-implementation`, `/start-story` | `/validate-artifact` |
| C3 | `commands/e3-plan-implementation.md` | `/plan-implementation` | `/define-spec`, `/execute-plan`, `/write-testing-plan` | `/validate-artifact` |
| C4 | `commands/e3b-write-testing-plan.md` | `/write-testing-plan` | `/execute-tests`, `/plan-implementation` | `/validate-artifact` |
| C5 | `commands/e4-execute-plan.md` | `/execute-plan` | `/define-spec`, `/execute-tests`, `/plan-implementation`, `/review-changes`, `/write-manual-testing-plan` | — |
| C6 | `commands/e5-execute-tests.md` | `/execute-tests` | `/execute-plan`, `/review-changes`, `/write-manual-testing-plan`, `/write-testing-plan` | `/validate-artifact` |
| C7 | `commands/e5b-write-manual-testing-plan.md` | `/write-manual-testing-plan` | `/execute-plan`, `/execute-tests`, `/resolve-feedback`, `/review-changes`, `/write-testing-plan` | `/validate-artifact` |
| C8 | `commands/e6-review-changes.md` | `/review-changes` | `/resolve-feedback` | `/validate-artifact` |
| C9 | `commands/e7-resolve-feedback.md` | `/resolve-feedback` | `/review-changes` | `/validate-artifact` |
| C10 | `commands/p1-start-epic.md` | `/start-epic` | `/decompose-epic`, `/start-story` | `/validate-artifact` |
| C11 | `commands/p2-decompose-epic.md` | `/decompose-epic` | `/decompose-feature`, `/review-changes`, `/start-epic`, `/start-feature` | `/validate-artifact` |
| C12 | `commands/p3-start-feature.md` | `/start-feature` | `/decompose-epic`, `/decompose-feature`, `/start-epic`, `/start-story` | `/validate-artifact` |
| C13 | `commands/p4-decompose-feature.md` | `/decompose-feature` | `/decompose-epic`, `/define-spec`, `/plan-implementation`, `/review-changes`, `/start-feature`, `/start-story` | `/validate-artifact` |
| C14 | `commands/f1-propose-update.md` | `/propose-update` | `/implement-update`, `/plan-update-implementation`, `/regen-framework`, `/submit-proposal`, `/triage-proposals` | `/validate-artifact` |
| C15 | `commands/f2-plan-update-implementation.md` | `/plan-update-implementation` | `/implement-update`, `/propose-update`, `/start-story` | `/validate-artifact` |
| C16 | `commands/f3-implement-update.md` | `/implement-update` | `/plan-update-implementation`, `/propose-update`, `/regen-framework` | `/validate-artifact` |
| C17 | `commands/f4-regen-framework.md` | `/regen-framework` | `/audit-framework`, `/implement-update`, `/import-shamt` | — |
| C18 | `commands/f5-audit-framework.md` | `/audit-framework` | `/archive-proposal`, `/implement-update`, `/import-shamt`, `/propose-update`, `/regen-framework`, `/submit-proposal` | `/validate-artifact` |
| C19 | `commands/f6-archive-proposal.md` | `/archive-proposal` | `/audit-framework`, `/regen-framework`, `/triage-proposals` | — |
| C20 | `commands/sync-submit-proposal.md` | `/submit-proposal` | `/import-shamt`, `/propose-update`, `/triage-proposals` | `/validate-artifact` |
| C21 | `commands/sync-import-shamt.md` | `/import-shamt` | `/audit-framework`, `/regen-framework`, `/submit-proposal` | — |
| C22 | `commands/sync-triage-proposals.md` | `/triage-proposals` | `/submit-proposal` | `/validate-artifact` |

> **`/import-shamt` ALSO-token guard (C17 / C18 / C20):** map `/import-shamt` → `/sync-import-shamt` (only when not followed by `.`). The bare-slash `replace_all` over-reach this guard protects against does **not** actually arise in these three — `regen-framework` (C17) and `audit-framework` (C18) contain **no** `import-shamt.sh` reference, and `submit-proposal` (C20) mentions `import-shamt.sh` only **without** a leading slash (so `/import-shamt` never matches it). The slash-prefixed `/import-shamt.sh` collision is confined to **C21 / S21** (see their guards). The guard is stated here for uniformity; applying it is a harmless no-op in C17/C18/C20.
> **C21 self-token guard:** `commands/sync-import-shamt.md` is the command body that *documents the `import-shamt.sh` script*. The SELF rewrite changes the command title/usage/footer (`/import-shamt` → `/sync-import-shamt`, `commands/import-shamt.md` → `commands/sync-import-shamt.md`) but must **not** touch any `import-shamt.sh` filename, `.shamt-core/import-shamt.sh` path, or `regenerate-framework.sh` reference in the body.

### Skill bodies (Steps S1–S22)

| Step | File (post-Phase-1 path) | SELF token (name/mirror) + path | ALSO tokens to sweep | leave unchanged |
|------|--------------------------|-------------------------------------|----------------------|-----------------|
| S1 | `skills/e1-start-story/SKILL.md` | `start-story` | `/define-spec` | — |
| S2 | `skills/e2-define-spec/SKILL.md` | `define-spec` | `/plan-implementation` | `/validate-artifact` |
| S3 | `skills/e3-plan-implementation/SKILL.md` | `plan-implementation` | `/execute-plan`, `/write-testing-plan` | `/validate-artifact` |
| S4 | `skills/e3b-write-testing-plan/SKILL.md` | `write-testing-plan` | `/execute-tests`, `/plan-implementation` | `/validate-artifact` |
| S5 | `skills/e4-execute-plan/SKILL.md` | `execute-plan` | `/execute-tests`, `/plan-implementation`, `/review-changes`, `/write-manual-testing-plan` | — |
| S6 | `skills/e5-execute-tests/SKILL.md` | `execute-tests` | `/execute-plan`, `/review-changes`, `/write-manual-testing-plan`, `/write-testing-plan` | — |
| S7 | `skills/e5b-write-manual-testing-plan/SKILL.md` | `write-manual-testing-plan` | `/execute-tests`, `/resolve-feedback`, `/review-changes`, `/write-testing-plan` | `/validate-artifact` |
| S8 | `skills/e6-review-changes/SKILL.md` | `review-changes` | `/resolve-feedback` | `/validate-artifact` |
| S9 | `skills/e7-resolve-feedback/SKILL.md` | `resolve-feedback` | *(none)* | `/validate-artifact` |
| S10 | `skills/p1-start-epic/SKILL.md` | `start-epic` | `/decompose-epic` | `/validate-artifact` |
| S11 | `skills/p2-decompose-epic/SKILL.md` | `decompose-epic` | `/start-epic`, `/start-feature` | `/validate-artifact` |
| S12 | `skills/p3-start-feature/SKILL.md` | `start-feature` | `/decompose-epic`, `/decompose-feature`, `/start-epic` | `/validate-artifact` |
| S13 | `skills/p4-decompose-feature/SKILL.md` | `decompose-feature` | `/decompose-epic`, `/start-feature`, `/start-story` | `/validate-artifact` |
| S14 | `skills/f1-propose-update/SKILL.md` | `propose-update` | `/plan-update-implementation` | `/validate-artifact` |
| S15 | `skills/f2-plan-update-implementation/SKILL.md` | `plan-update-implementation` | `/implement-update`, `/propose-update` | `/validate-artifact` |
| S16 | `skills/f3-implement-update/SKILL.md` | `implement-update` | `/regen-framework` | — |
| S17 | `skills/f4-regen-framework/SKILL.md` | `regen-framework` | `/audit-framework` | — |
| S18 | `skills/f5-audit-framework/SKILL.md` | `audit-framework` | `/archive-proposal`, `/propose-update`, `/regen-framework`, `/submit-proposal` | — |
| S19 | `skills/f6-archive-proposal/SKILL.md` | `archive-proposal` | *(none)* | — |
| S20 | `skills/sync-submit-proposal/SKILL.md` | `submit-proposal` | `/archive-proposal`, `/import-shamt`, `/propose-update` | `/validate-artifact` |
| S21 | `skills/sync-import-shamt/SKILL.md` | `import-shamt` | `/audit-framework`, `/regen-framework`, `/submit-proposal` (guard `.sh` on `/import-shamt`) | — |
| S22 | `skills/sync-triage-proposals/SKILL.md` | `triage-proposals` | `/archive-proposal`, `/audit-framework`, `/implement-update`, `/plan-update-implementation`, `/propose-update`, `/regen-framework`, `/submit-proposal` | `/validate-artifact` |

> **S15 path note:** `skills/f2-plan-update-implementation/SKILL.md` references `commands/plan-update-implementation.md` (line 31 protocol pointer, Recipe B3) and its own `skills/plan-update-implementation/SKILL.md` managed footer (line 53, Recipe B4) — rewrite both to their `f2-` forms. It **also** links `agents/plan-executor.md` (line 42): **do not** rewrite that path — the persona file is not renamed (only its body is swept in Phase 3, Step 16). ALSO tokens `/implement-update`, `/propose-update` per the table.
> **S16 note:** `skills/f3-implement-update/SKILL.md` carries **no** `/plan-update-implementation` reference (confirmed by grep) — its only ALSO token is `/regen-framework`. There is no `skills/plan-update-implementation/` path pointer in this body.
> **S21 guard:** leave `import-shamt.sh` / `.shamt-core/import-shamt.sh` filenames intact; only the `/import-shamt` command form and `commands/import-shamt.md` path change. The ALSO tokens (`/audit-framework`, `/regen-framework`, `/submit-proposal`) carry no `.sh` collision.

---

## Step-by-step

### Steps C1–C22 — rewrite each renamed command body
**Operation:** EDIT (one step per row in the *Command bodies* table)
**For each file:** apply **Recipe A** (title A1, usage A2, footer A3, frontmatter A4-noop) using the SELF token, then **Recipe A5** for every ALSO token. Honor the `/validate-artifact` and `/import-shamt`-vs-`.sh` guards.
**Verification (per file `{new}`):**
```
grep -c '# /{new-token}' commands/{new}.md            # == 1 (title rewritten)
grep -c 'commands/{new}.md' commands/{new}.md          # >= 1 (footer rewritten)
grep -cE '/{old-self-token}([^a-z]|$)' commands/{new}.md   # == 0 (no stale self token)
```
Plus the whole-file guard at the end of this phase.

> **`import-shamt` self-token grep exception (C21 — and S21 below):** the line-`grep -cE '/{old-self-token}([^a-z]|$)'` form **false-fails** for `import-shamt`, because the retained `.shamt-core/import-shamt.sh` / `import-shamt.sh` path (which must **not** be rewritten) contains a `/import-shamt` substring followed by `.`. For C21 use `grep -cE '/import-shamt([^a-z.]|$)' commands/sync-import-shamt.md  # == 0` (the added `.` in the negated class skips the `.sh`/`.md` path forms), or pipe the un-anchored grep through `| grep -v 'import-shamt\.sh'`. Expect `0` command-form `/import-shamt` occurrences after the rewrite; the `.sh` path lines legitimately remain.

### Steps S1–S22 — rewrite each renamed skill body
**Operation:** EDIT (one step per row in the *Skill bodies* table)
**For each file:** apply **Recipe B** (name B1, mirror B2, command-path B3, footer B4) using the SELF token, then **Recipe B5** for every ALSO token. Honor both guards.
**Verification (per file `{new}`):**
```
grep -c 'name: {new}' skills/{new}/SKILL.md            # == 1
grep -c 'skills/{new}/SKILL.md' skills/{new}/SKILL.md  # >= 1 (footer)
grep -c 'commands/{new}.md' skills/{new}/SKILL.md      # >= 1 (path pointer)
grep -cE '\b{old-self-token}\b' skills/{new}/SKILL.md  # == 0 (no stale self token)
```

> **S21 self-token grep exception:** `\bimport-shamt\b` **false-fails** in `skills/sync-import-shamt/SKILL.md` — it matches the legitimately-retained `import-shamt.sh` script references **and** the `description:` natural-language triggers ("…or run import-shamt"), none of which are command-form references and none of which Recipe B rewrites. For S21, verify the SELF rewrite by its concrete surfaces instead: `grep -c 'name: sync-import-shamt' …  # == 1`, `grep -c 'commands/sync-import-shamt.md' …  # >= 1`, and `grep -cE '/import-shamt([^a-z.]|$)' …  # == 0` (command/slash form only — the `.sh`/`.md` and bare-word `import-shamt` occurrences stay).

---

## Verification (post-phase)

Run from `shamt-core/`:

- [ ] **No stale command title anywhere in the renamed set:**
      `grep -rEn '# /(start-story|define-spec|plan-implementation|write-testing-plan|execute-plan|execute-tests|write-manual-testing-plan|review-changes|resolve-feedback|start-epic|decompose-epic|start-feature|decompose-feature|propose-update|plan-update-implementation|implement-update|regen-framework|audit-framework|archive-proposal|submit-proposal|triage-proposals)\b' host/templates/claude/`
      returns nothing.
- [ ] **No stale managed-footer path:**
      `grep -rEn 'commands/(start-story|define-spec|plan-implementation|write-testing-plan|execute-plan|execute-tests|write-manual-testing-plan|review-changes|resolve-feedback|start-epic|decompose-epic|start-feature|decompose-feature|propose-update|plan-update-implementation|implement-update|regen-framework|audit-framework|archive-proposal|submit-proposal|triage-proposals)\.md' host/templates/claude/`
      returns nothing.
- [ ] **No stale skill `name:`:** every `SKILL.md` `name:` matches its folder name —
      `for d in host/templates/claude/skills/*/; do n=$(grep -m1 '^name:' "$d/SKILL.md" | sed 's/name: //'); b=$(basename "$d"); [ "$n" = "$b" ] || echo "MISMATCH $b -> $n"; done` prints nothing.
- [ ] **No stale inter-command slash refs in any body (guards excluded):**
      `grep -rEn '/(start-story|define-spec|plan-implementation|write-testing-plan|execute-plan|execute-tests|write-manual-testing-plan|review-changes|resolve-feedback|start-epic|decompose-epic|start-feature|decompose-feature|propose-update|plan-update-implementation|implement-update|regen-framework|audit-framework|archive-proposal|submit-proposal|triage-proposals)' host/templates/claude/commands/ host/templates/claude/skills/ | grep -v 'import-shamt\.sh'`
      returns nothing.
- [ ] **`/import-shamt` command rename landed** (`import-shamt` is excluded from the three alternations above — *required* only for the bare-slash sweep on the inter-command check, where `/import-shamt` would collide with `import-shamt.sh`; it is carried through to the title and footer alternations for consistency, though those `# /`- and `\.md`-anchored forms have no `.sh` collision. The dedicated, `.sh`-aware checks below cover all three surfaces):
      - `grep -rEn '# /import-shamt\b' host/templates/claude/` (stale command **title**) returns nothing.
      - `grep -rn 'commands/import-shamt\.md' host/templates/claude/` (stale **footer / path** pointer) returns nothing.
      - `grep -rEn '/import-shamt([^.]|$)' host/templates/claude/commands/ host/templates/claude/skills/` (stale **command-form / ALSO** ref — the `[^.]` already skips `import-shamt.sh` and `import-shamt.md`) returns nothing.
- [ ] **`/validate-artifact` preserved:** `grep -rc '/validate-artifact' host/templates/claude/` shows the same count as before this phase (it must not have been rewritten).
- [ ] **`import-shamt.sh` not corrupted:** `grep -rn 'sync-import-shamt\.sh' host/templates/claude/` returns nothing.

## Notes

- The "ALSO tokens" column was re-derived 2026-05-30 by `grep -oE '/<token>'` over each body (command bodies and `SKILL.md`) for every old slash token, deduplicated and sorted, against the current tree. `*(none)*` means the body references only its own token (plus possibly `/validate-artifact`, shown in the "leave unchanged" column, which stays). The builder should still run the per-file inter-command verification grep — if a token shows up that the table does **not** list for that file (whether marked `(none)` or just absent from its ALSO set), **halt and report** rather than silently rewriting; likewise the end-of-phase whole-tree grep is the authoritative backstop.
- The `e3b` / `e5b` and `sync-*` files: confirm the usage signature when rewriting (e.g. `/review-changes [{slug}|--branch=<name>|--pr=<id>]`, `/validate-artifact <path>` is not in this set). Only the leading command token changes; arguments are copied verbatim.

---
Validated 2026-05-30 — 3 rounds, 1 adversarial sub-agent confirmed (ALSO-token tables re-derived from the tree and machine-diffed: all 44 rows — C1–C22, S1–S22 — match actual non-self token sets)
Re-validated 2026-05-30 — 3 rounds, 1 adversarial sub-agent confirmed (fixed 1 CRITICAL: Recipe B2 skill-H1 rewrite targeted a non-existent line — no SKILL.md has a Markdown H1; 1 HIGH: Phase 2's own verification block had no working `/import-shamt`→`/sync-import-shamt` command-rename check — added `.sh`-aware title/footer/command-form greps; 2 MEDIUM: Recipe B mirror target mismatched `start-story`'s phrasing, and the per-file C21/S21 self-token greps false-failed on the retained `import-shamt.sh`; 2 LOW: pre-exec `grep -rl '# /'` contradicted its stated purpose, and the import-shamt-omission rationale over-generalized to the title/footer alternations. Recipe-B steps renumbered B1–B5 after dropping the phantom H1 step.)
