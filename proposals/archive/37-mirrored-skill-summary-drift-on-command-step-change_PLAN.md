# Implementation Plan: mirrored-skill-summary-drift-on-command-step-change (INDEX)

**Proposal:** proposals/37-mirrored-skill-summary-drift-on-command-step-change.md
**Created:** 2026-06-16
**File operations:** 38 (CREATE: 0, EDIT: 38, DELETE: 0, MOVE: 0)
**Shape:** Phase-decomposed — this index + 3 phase files. Validate each file independently (see "Validation" below).

This plan decomposes the proposal's 6-row Proposed Changes table into 38 ordered, individually executable EDIT steps:

- **Phase 1** (`_PLAN_phase_1.md`) — the **5 forward-guard edits** (rows 1, 2, 3, 4, 6): `reference/audit_dimensions.md`, `host/templates/claude/commands/f1-propose-update.md`, `host/templates/claude/commands/validate-artifact.md`, `proposals/_template.md`, `host/templates/claude/commands/f5-audit-framework.md`.
- **Phase 2** (`_PLAN_phase_2.md`) — the **first 17 of 33 SKILL Protocol-summary migrations** (row 5): the 11 `e*` skills (`e1-start-story` … `e8-finalize-story`, `e-all`) plus the **early** `f*` skills `f0-draft-proposal` through `f5-audit-framework` (6 of them). Phase 2's f-skills stop at `f5-audit-framework`; `f6-archive-proposal` and `f-all` are in Phase 3.
- **Phase 3** (`_PLAN_phase_3.md`) — the **remaining 16 of 33 SKILL Protocol-summary migrations** (row 5): the **late** `f*` skills `f6-archive-proposal` and `f-all`, plus the `pe*` / `pf*` / `ps*` / `sync-*` / `trim-rules-file` / `validate-artifact` skills.

**Deploy order:** Phase 1 → Phase 2 → Phase 3. The phases are independent (disjoint file sets); the order is for review legibility, not a data dependency.

---

## The shared migration contract (row 5 — applies to every step in Phases 2 and 3)

Every row-5 SKILL migration is the **same mechanical edit**, differing only by the file path and the exact pointer line. The contract, stated once here and referenced by each per-step block:

Each `host/templates/claude/skills/{name}/SKILL.md` `## Protocol` section has this shape:

```
## Protocol

{pointer line — ends with the literal " Summary:"}

1. {step paraphrase}
2. {step paraphrase}
…            ← (may include interstitial "Resolve the story folder per …" paragraphs,
              and, for e6-review-changes, "### Story mode" / "### Formal mode" sub-headings)
N. {step paraphrase}

## {next heading}
```

**The edit (identical for all 33):**

1. **Strip the trailing ` Summary:`** from the pointer line (the pointer line is unique per file — it names the command — and is the *only* line in the file containing the string `Summary:`, verified across all 33 files).
2. **Delete the entire numbered "Summary:" block** — every line from the first blank line after the pointer line through the last line before the next `## ` heading (i.e. the numbered list `1.`…`N.` plus any interstitial paragraphs it contains, plus, for `e6-review-changes`, the `### Story mode` and `### Formal mode` sub-headings and their numbered lists).
3. **Leave exactly one blank line** between the (now Summary-less) pointer line and the next `## ` heading.

**What is preserved, untouched, in every file:** the `## Protocol` heading itself; the pointer sentence(s) (only the trailing ` Summary:` token is removed); any **unique prose** in the pointer line that is *not* a step paraphrase — specifically:
  - `e2-define-spec` / `e5b-write-manual-testing-plan` / `e7-resolve-feedback`: the "Resolve the story folder per `templates/SHAMT_RULES.template.md` §PO-tree resolution …" sentence that sits **before** ` Summary:` on the pointer line stays (it is a resolution rule, not a step paraphrase).
  - `e-all` / `f-all`: the "The one-nesting-level dispatch pattern it reproduces lives in [`reference/batch_validation_handoff.md`] …" sentence before ` Summary:` stays.
  - `f5-audit-framework`: the "Full D1–D12 definitions, the fix-track rubric … live in [`reference/audit_dimensions.md`] …" sentence before ` Summary:` stays.
- All other SKILL sections are **never touched**: `## Overview`, `## Recommended model(s)`, `## Exit criteria`, any `## Hard rule`, the YAML frontmatter, and the managed-file trailer (`<!-- Managed by Shamt … -->`).

**Per-step expression in Phases 2 and 3.** Each step gives two exact anchor strings so the deletion region is fully determined with no body embed:
- **Pointer line (before):** the exact current pointer line, ending in ` Summary:`.
- **Pointer line (after):** the same line with ` Summary:` removed.
- **Next-heading anchor:** the exact `## …` heading that immediately follows the Protocol section (the first `## ` line after the block).
The executor replaces everything from the "(before)" pointer line through the blank line preceding the next-heading anchor with the "(after)" pointer line followed by a single blank line, leaving the next-heading anchor in place. Per-step **Verification** (builder-owned) confirms the file no longer matches `^[0-9]+\. ` inside its Protocol and still contains the "(after)" pointer line.

**Scope boundary (non-scope, carried from the proposal):** only the `## Protocol` numbered step paraphrase is removed. `## Recommended model(s)` and `## Exit criteria` — which also lightly restate command content — are **out of scope** and must not be touched.

---

## Files manifest (all 38 EDIT operations)

| #  | Phase | Path | Operation | Row |
|----|-------|------|-----------|-----|
| 1  | 1 | `reference/audit_dimensions.md` | EDIT | 1 |
| 2  | 1 | `host/templates/claude/commands/f1-propose-update.md` | EDIT | 2 |
| 3  | 1 | `host/templates/claude/commands/validate-artifact.md` | EDIT | 3 |
| 4  | 1 | `proposals/_template.md` | EDIT | 4 |
| 5  | 1 | `host/templates/claude/commands/f5-audit-framework.md` | EDIT | 6 |
| 6  | 2 | `host/templates/claude/skills/e1-start-story/SKILL.md` | EDIT | 5 |
| 7  | 2 | `host/templates/claude/skills/e2-define-spec/SKILL.md` | EDIT | 5 |
| 8  | 2 | `host/templates/claude/skills/e3-plan-implementation/SKILL.md` | EDIT | 5 |
| 9  | 2 | `host/templates/claude/skills/e3b-write-testing-plan/SKILL.md` | EDIT | 5 |
| 10 | 2 | `host/templates/claude/skills/e4-execute-plan/SKILL.md` | EDIT | 5 |
| 11 | 2 | `host/templates/claude/skills/e5-execute-tests/SKILL.md` | EDIT | 5 |
| 12 | 2 | `host/templates/claude/skills/e5b-write-manual-testing-plan/SKILL.md` | EDIT | 5 |
| 13 | 2 | `host/templates/claude/skills/e6-review-changes/SKILL.md` | EDIT | 5 |
| 14 | 2 | `host/templates/claude/skills/e7-resolve-feedback/SKILL.md` | EDIT | 5 |
| 15 | 2 | `host/templates/claude/skills/e8-finalize-story/SKILL.md` | EDIT | 5 |
| 16 | 2 | `host/templates/claude/skills/e-all/SKILL.md` | EDIT | 5 |
| 17 | 2 | `host/templates/claude/skills/f0-draft-proposal/SKILL.md` | EDIT | 5 |
| 18 | 2 | `host/templates/claude/skills/f1-propose-update/SKILL.md` | EDIT | 5 |
| 19 | 2 | `host/templates/claude/skills/f2-plan-update-implementation/SKILL.md` | EDIT | 5 |
| 20 | 2 | `host/templates/claude/skills/f3-implement-update/SKILL.md` | EDIT | 5 |
| 21 | 2 | `host/templates/claude/skills/f4-regen-framework/SKILL.md` | EDIT | 5 |
| 22 | 2 | `host/templates/claude/skills/f5-audit-framework/SKILL.md` | EDIT | 5 |
| 23 | 3 | `host/templates/claude/skills/f6-archive-proposal/SKILL.md` | EDIT | 5 |
| 24 | 3 | `host/templates/claude/skills/f-all/SKILL.md` | EDIT | 5 |
| 25 | 3 | `host/templates/claude/skills/pe0-draft/SKILL.md` | EDIT | 5 |
| 26 | 3 | `host/templates/claude/skills/pe1-define/SKILL.md` | EDIT | 5 |
| 27 | 3 | `host/templates/claude/skills/pe2-decompose/SKILL.md` | EDIT | 5 |
| 28 | 3 | `host/templates/claude/skills/pe3-finalize/SKILL.md` | EDIT | 5 |
| 29 | 3 | `host/templates/claude/skills/pf0-draft/SKILL.md` | EDIT | 5 |
| 30 | 3 | `host/templates/claude/skills/pf1-define/SKILL.md` | EDIT | 5 |
| 31 | 3 | `host/templates/claude/skills/pf2-decompose/SKILL.md` | EDIT | 5 |
| 32 | 3 | `host/templates/claude/skills/ps0-draft/SKILL.md` | EDIT | 5 |
| 33 | 3 | `host/templates/claude/skills/ps1-define/SKILL.md` | EDIT | 5 |
| 34 | 3 | `host/templates/claude/skills/sync-import-shamt/SKILL.md` | EDIT | 5 |
| 35 | 3 | `host/templates/claude/skills/sync-submit-proposal/SKILL.md` | EDIT | 5 |
| 36 | 3 | `host/templates/claude/skills/sync-triage-proposals/SKILL.md` | EDIT | 5 |
| 37 | 3 | `host/templates/claude/skills/trim-rules-file/SKILL.md` | EDIT | 5 |
| 38 | 3 | `host/templates/claude/skills/validate-artifact/SKILL.md` | EDIT | 5 |

**33 row-5 SKILL files (steps 6–38)** match the proposal's row-5 enumeration exactly: every `skills/{name}/` has a matching `commands/{name}.md`; no command-backed SKILL is omitted, no non-command skill is included.

---

## Pre-execution checklist

- [ ] On a clean working tree (or working in the shared working tree dedicated to this proposal — accept-and-fold: leave any unrelated in-tree proposal additions untouched).
- [ ] `proposals/37-mirrored-skill-summary-drift-on-command-step-change.md` validation footer present.
- [ ] Each phase file (`_PLAN_phase_1.md`, `_PLAN_phase_2.md`, `_PLAN_phase_3.md`) carries its own validation footer before `/f3-implement-update` executes it.
- [ ] Branch created by `/f3-implement-update`: `proposal/37-mirrored-skill-summary-drift-on-command-step-change` from the base branch, immediately before the canonical edits. (Authoring/validation/planning happen on the base branch; the architect/builder path's executor creates this branch when it runs this pre-execution checklist at Phase 4.)

---

## Verification (post-execution, whole plan)

<!-- Whole-plan / cross-phase invariants — run by the architect at /f3-implement-update post-build (Step 3), never by the builder. This section lives in the INDEX file, not any phase file (per #31: whole-plan/cross-phase verification is architect-owned). -->

The two-part acceptance invariant from the proposal's Validation Considerations is the load-bearing whole-plan check — both halves must hold across **all 33** migrated SKILL files:

- [ ] **Zero retained step paraphrases.** `grep -rnE '^[0-9]+\. ' host/templates/claude/skills/*/SKILL.md` returns **zero** matches. (Every SKILL `## Protocol` numbered "Summary:" list has been removed; no SKILL Protocol retains a numbered step paraphrase. No SKILL section other than Protocol contains a top-of-line `^[0-9]+\. ` numbered list, so a whole-file sweep is sufficient — confirm the zero-match result; any match is a missed or partial migration.)
- [ ] **Every pointer line preserved.** For each of the 33 migrated files, the file still contains its `Follow the canonical \`/{name}\` command body verbatim — see [\`commands/{name}.md\`](…).` pointer line. Confirm with: `for d in e1-start-story e2-define-spec e3-plan-implementation e3b-write-testing-plan e4-execute-plan e5-execute-tests e5b-write-manual-testing-plan e6-review-changes e7-resolve-feedback e8-finalize-story e-all f0-draft-proposal f1-propose-update f2-plan-update-implementation f3-implement-update f4-regen-framework f5-audit-framework f6-archive-proposal f-all pe0-draft pe1-define pe2-decompose pe3-finalize pf0-draft pf1-define pf2-decompose ps0-draft ps1-define sync-import-shamt sync-submit-proposal sync-triage-proposals trim-rules-file validate-artifact; do grep -q "Follow the canonical \`/$d\` command body verbatim" "host/templates/claude/skills/$d/SKILL.md" || echo "MISSING pointer: $d"; done` — prints nothing when all 33 pass.
- [ ] **No `Summary:` token survives in any migrated Protocol.** `grep -rn 'Summary:' host/templates/claude/skills/*/SKILL.md` returns zero matches (the trailing ` Summary:` was stripped from every pointer line).
- [ ] **Forward-guard rows landed.** Each of the 5 Phase-1 edits is present: `grep` the new pointer-rule wording in `reference/audit_dimensions.md` (D2 entry), `commands/f1-propose-update.md` (Step 3 item 3), `commands/validate-artifact.md` (Step 2 row), `proposals/_template.md` (Change-list completeness), `commands/f5-audit-framework.md` (Step 2 D2 check, ~line 98).
- [ ] **One step per Proposed Changes row.** All 6 rows covered: rows 1/2/3/4/6 → Phase-1 steps; row 5 → the 33 Phase-2/Phase-3 steps. No plan step traces to a row absent from the table.
- [ ] **No edits landed in generated `.claude/` paths.** `git diff --stat` shows no `.claude/` path touched (regen at `/f4` propagates the 33 SKILL edits + the 3 command-body edits into `.claude/`).
- [ ] **Out-of-scope sections untouched.** `git diff` for each migrated SKILL shows changes confined to the `## Protocol` section — no diff in `## Recommended model(s)`, `## Exit criteria`, frontmatter, or the managed trailer.
- [ ] Markdown / link / reference targets in the 5 forward-guard files still resolve (the new pointer-rule references point at `reference/audit_dimensions.md` by name).

---

## Notes

- **Ordering constraints:** none across phases — the three phase file sets are disjoint. Within each phase, steps are independent single-file EDITs.
- **Accept-and-fold:** an unrelated parallel proposal (e.g. `proposals/rules-file-over-budget.md` if present) is out of scope — never touch it. Other in-tree proposal additions ride the landing untouched (Principle 3).
- **No regen-script change:** regen keeps copying `SKILL.md` verbatim; removing the paraphrase needs no `scripts/regenerate-framework.sh` edit. `.claude/` propagation happens at `/f4-regen-framework` (Phase 5), not in this plan.
- **Self-application:** `f1-propose-update` (step 18) and `validate-artifact` (step 38) SKILLs are themselves in the migration set, so the new pointer rule applies to them too — no residual mirror remains anywhere.
- **Re-baseline:** if `/f3` reports a plan defect, patch the offending phase file, re-run `/validate-artifact` on that file, then re-invoke `/f3-implement-update`.

---

## Validation

This is a **phase-decomposed plan** (index + 3 phase files = 4 validations). The plan is **not** approved for execution until every file carries its own validation footer.

**Recommended — batch-validation handoff** (paste into a fresh session):

```text
Run a Shamt Pattern 1 validation loop on each of the following framework-update implementation-plan artifacts, one at a time, each in its own /clear-ed context. Each is part of one phase-decomposed plan for proposal 37-mirrored-skill-summary-drift-on-command-step-change.

1. proposals/37-mirrored-skill-summary-drift-on-command-step-change_PLAN.md
   — governing references: the index file's own "Verification (post-execution, whole plan)" section + Files manifest; validate under the 4 phase-index dimensions (Phase Coverage, Deploy Ordering, Cross-phase Dependencies, Completeness). Confirm: all 6 Proposed Changes rows are covered across the 3 phases; the whole-plan invariant lives here (not in a phase file); the 33-file row-5 set matches the proposal exactly.
2. proposals/37-mirrored-skill-summary-drift-on-command-step-change_PLAN_phase_1.md
   — governing references: proposal rows 1/2/3/4/6 + the 5 target canonical files (reference/audit_dimensions.md, commands/f1-propose-update.md, commands/validate-artifact.md, proposals/_template.md, commands/f5-audit-framework.md); validate under the 8 plan dimensions. Confirm each EDIT's locate string matches the live file and each replacement is exact.
3. proposals/37-mirrored-skill-summary-drift-on-command-step-change_PLAN_phase_2.md
   — governing references: proposal row 5 + the shared migration contract in the index + the 17 target SKILL.md files (e1…f5-audit-framework); validate under the 8 plan dimensions. Confirm each step's pointer-line anchors and next-heading anchor match the live file.
4. proposals/37-mirrored-skill-summary-drift-on-command-step-change_PLAN_phase_3.md
   — governing references: proposal row 5 + the shared migration contract in the index + the 16 target SKILL.md files (f6-archive-proposal…validate-artifact); validate under the 8 plan dimensions. Confirm each step's pointer-line anchors and next-heading anchor match the live file.

Each file runs the standard Pattern 1 loop (primary clean + 1 adversarial validation-checker sub-agent, no one-LOW allowance). Stamp each file's own footer on a clean+CONFIRMED exit.
```

**Sequential per-file fallback** (drive each step by hand):

```text
/clear
/validate-artifact proposals/37-mirrored-skill-summary-drift-on-command-step-change_PLAN.md
/clear
/validate-artifact proposals/37-mirrored-skill-summary-drift-on-command-step-change_PLAN_phase_1.md
/clear
/validate-artifact proposals/37-mirrored-skill-summary-drift-on-command-step-change_PLAN_phase_2.md
/clear
/validate-artifact proposals/37-mirrored-skill-summary-drift-on-command-step-change_PLAN_phase_3.md
```

Both paths run the same Pattern 1 rigor per file. Validate **all four** files (the index and every phase file), not just the index.

---
Validated 2026-06-16 — primary clean (2 rounds, 4 phase-index dimensions; round 2 fixed a MEDIUM: Phase 2/Phase 3 intro prose now names the f-skill split explicitly — f0-draft-proposal…f5-audit-framework in Phase 2, f6-archive-proposal + f-all in Phase 3 — matching the manifest) + adversarial validation-checker confirmed: zero issues
