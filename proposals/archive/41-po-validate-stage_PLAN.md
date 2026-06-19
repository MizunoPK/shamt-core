# Implementation Plan: po-validate-stage (INDEX)

**Proposal:** proposals/41-po-validate-stage.md
**Created:** 2026-06-19
**File operations:** 33 (CREATE: 6, EDIT: 21, MOVE: 6) — maps to the proposal's 20 Proposed Changes rows; rows 7–12 are 6 MOVEs, rows 13–19 are 7 named EDITs, row 20 is a 14-site sweep folded across phases (13 distinct-file sweep sites + 1 residual second-EDIT of row-16's file).

This is a **phase-decomposed** plan. The index holds the manifest, the global ordering rationale, the whole-plan post-execution verification, and the cross-phase notes. Each phase file is independently executable and independently validated.

> **Plan-executor:** execute the phase files **in order** — Phase 1 → 2 → 3 → 4. The ordering is load-bearing: the MOVEs (Phase 2) must complete before the sweep (Phase 4) so every renamed-command reference resolves to a file that already exists under its new name. Do **not** reorder.

## Phase files

| Phase | File | Scope | Steps |
|-------|------|-------|-------|
| 1 | `proposals/41-po-validate-stage_PLAN_phase_1.md` | The 6 CREATEs — three new `-validate` commands (rows 1–3) + three mirror skills (rows 4–6). No dependency on the renames; written first so the new commands exist before docs point at them. | 6 |
| 2 | `proposals/41-po-validate-stage_PLAN_phase_2.md` | The 6 MOVEs (rows 7–12) — `git mv` the three commands + three skill folders, each followed by its internal self-label / cross-reference / regen-pointer edits. | 6 |
| 3 | `proposals/41-po-validate-stage_PLAN_phase_3.md` | The behavioral + named-reference EDITs (rows 13–19) — `/pe1-define`, `/pf1-define`, `/ps1-define` (validation-loop removal), `/e1-start-story`, README, `epic_status_board.md`, `model_selection.md`. | 7 |
| 4 | `proposals/41-po-validate-stage_PLAN_phase_4.md` | Row 20 — the grep-driven mechanical reference-rename sweep across every remaining canonical site. Each swept site is a concrete step with its exact file + old→new string. Step 14 is a residual second-EDIT of `e1-start-story.md` (row 16) for the 5 `/pf2-decompose` tokens deferred from Phase 3. | 14 |

**Total steps: 33** (6 + 6 + 7 + 14).

## Files manifest

| # | Path | Operation | Sibling / template (if any) | Phase / Step |
|---|------|-----------|------------------------------|--------------|
| 1 | `host/templates/claude/commands/pe2-validate.md` | CREATE | mirror of `commands/validate-artifact.md` body-pointer shape + `commands/pe2-decompose.md` slug-resolution/prereq shape | P1 S1 |
| 2 | `host/templates/claude/commands/pf2-validate.md` | CREATE | mirror of row-1 body + `commands/pf1-define.md` `## Parent-slug batch mode` section | P1 S2 |
| 3 | `host/templates/claude/commands/ps2-validate.md` | CREATE | mirror of row-1 body + `commands/ps1-define.md` Step-7 inline loop (moved) + `ps1-define.md` `## Parent-slug batch mode` section | P1 S3 |
| 4 | `host/templates/claude/skills/pe2-validate/SKILL.md` | CREATE | mirror of `skills/pe1-define/SKILL.md` (pointer-form Protocol) | P1 S4 |
| 5 | `host/templates/claude/skills/pf2-validate/SKILL.md` | CREATE | mirror of `skills/pe1-define/SKILL.md` | P1 S5 |
| 6 | `host/templates/claude/skills/ps2-validate/SKILL.md` | CREATE | mirror of `skills/pe1-define/SKILL.md` | P1 S6 |
| 7 | `host/templates/claude/commands/pe2-decompose.md` → `pe3-decompose.md` | MOVE | — | P2 S1 |
| 8 | `host/templates/claude/commands/pe3-finalize.md` → `pe4-finalize.md` | MOVE | — | P2 S2 |
| 9 | `host/templates/claude/commands/pf2-decompose.md` → `pf3-decompose.md` | MOVE | — | P2 S3 |
| 10 | `host/templates/claude/skills/pe2-decompose/` → `skills/pe3-decompose/` | MOVE | — | P2 S4 |
| 11 | `host/templates/claude/skills/pe3-finalize/` → `skills/pe4-finalize/` | MOVE | — | P2 S5 |
| 12 | `host/templates/claude/skills/pf2-decompose/` → `skills/pf3-decompose/` | MOVE | — | P2 S6 |
| 13 | `host/templates/claude/commands/pe1-define.md` | EDIT | — | P3 S1 |
| 14 | `host/templates/claude/commands/pf1-define.md` | EDIT | — | P3 S2 |
| 15 | `host/templates/claude/commands/ps1-define.md` | EDIT | — | P3 S3 |
| 16 | `host/templates/claude/commands/e1-start-story.md` | EDIT | — | P3 S4 + P4 S14 |
| 17 | `README.md` | EDIT | — | P3 S5 |
| 18 | `reference/epic_status_board.md` | EDIT | — | P3 S6 |
| 19 | `reference/model_selection.md` | EDIT | — | P3 S7 |
| 20a | `host/templates/claude/commands/pf0-draft.md` | EDIT (sweep) | — | P4 S1 |
| 20b | `host/templates/claude/commands/ps0-draft.md` | EDIT (sweep) | — | P4 S2 |
| 20c | `host/templates/claude/commands/e8-finalize-story.md` | EDIT (sweep) | — | P4 S3 |
| 20d | `host/templates/claude/skills/pe1-define/SKILL.md` | EDIT (sweep) | — | P4 S4 |
| 20e | `host/templates/claude/skills/pf0-draft/SKILL.md` | EDIT (sweep) | — | P4 S5 |
| 20f | `host/templates/claude/skills/pf1-define/SKILL.md` | EDIT (sweep) | — | P4 S6 |
| 20g | `host/templates/claude/skills/e8-finalize-story/SKILL.md` | EDIT (sweep) | — | P4 S7 |
| 20h | `reference/trackers/local.md` | EDIT (sweep) | — | P4 S8 |
| 20i | `templates/epic.template.md` | EDIT (sweep) | — | P4 S9 |
| 20j | `templates/feature.template.md` | EDIT (sweep) | — | P4 S10 |
| 20k | `templates/ticket.ado.template.md` | EDIT (sweep) | — | P4 S11 |
| 20l | `templates/ticket.github.template.md` | EDIT (sweep) | — | P4 S12 |
| 20m | `templates/SHAMT_RULES.template.md` | EDIT (sweep) | — | P4 S13 |
| 20n | `host/templates/claude/commands/e1-start-story.md` | EDIT (sweep — `/pf2-decompose` residual; row 16) | — | P4 S14 |

## Pre-execution checklist (applies to every phase)

- [ ] On a clean working tree (or working in a worktree dedicated to this proposal).
- [ ] `proposals/41-po-validate-stage.md` validation footer present (it is — stamped 2026-06-19).
- [ ] Branch `proposal/41-po-validate-stage` created by `/f3-implement-update` from the base branch immediately before the canonical edits. (Authoring/validation/planning happen on the base branch; `/f3` creates this branch when it runs this checklist at Phase 4.)

## Global ordering rationale (so no dangling reference survives mid-execution)

1. **Phase 1 (CREATEs) first.** The three `-validate` commands have no dependency on the renames; creating them first means the next-phase suggestions added in Phase 3 (`/pe2-validate {slug}`, `/pf2-validate {slug}`, `/ps2-validate {slug}`) point at files that already exist. `ps2-validate.md` also receives the inline validation loop *moved out of* `ps1-define.md` — author the new home (Phase 1 S3) **before** removing it from `ps1-define.md` (Phase 3 S3) so the loop content is never momentarily absent from the tree.
2. **Phase 2 (MOVEs) second.** `git mv` each command + skill folder to its new name and fix internal self-labels. After Phase 2, the canonical files `pe3-decompose.md`, `pe4-finalize.md`, `pf3-decompose.md` (and their skill folders) exist under their **new** names.
3. **Phase 3 (named EDITs) third.** These repoint `/pe1-define`/`/pf1-define`/`/ps1-define`/`/e1-start-story`/README/references at the new command names and at the new `-validate` stage — all targets now exist (Phases 1 + 2 done).
4. **Phase 4 (sweep) last.** The mechanical reference rename across the remaining sites. Running it last guarantees every `→ new name` reference resolves to a file already on disk under that name.

Within this ordering **no dangling reference survives at a phase boundary**: a renamed file always exists under its new name (Phase 2) before any reference is repointed to it (Phases 3–4), and the new commands exist (Phase 1) before any doc points at them (Phase 3).

## Verification (post-execution, whole plan)

<!-- Whole-plan / cross-phase invariants — run by the architect at /f3-implement-update post-build (Step 3), NEVER by the builder. These depend on more than one phase's output. -->

- [ ] **Zero dangling old command names.** `grep -rnE '/pe2-decompose|/pf2-decompose|/pe3-finalize|\bpe2-decompose\b|\bpf2-decompose\b|\bpe3-finalize\b' --include='*.md' templates reference host README.md CLAUDE.md` returns **zero** matches. (Run the bare-word form too — comment text and folder-name mentions are not always slash-prefixed. The only legitimate survivors would be inside `proposals/` history, which is out of the sweep roots.)
- [ ] **All three new command files exist** and each is non-empty: `commands/pe2-validate.md`, `commands/pf2-validate.md`, `commands/ps2-validate.md`.
- [ ] **All three new skill files exist:** `skills/pe2-validate/SKILL.md`, `skills/pf2-validate/SKILL.md`, `skills/ps2-validate/SKILL.md`. Each `## Protocol` is the canonical-command-body pointer form (D2 / #37) — `grep -L 'Follow the canonical' skills/p{e2,f2,s2}-validate/SKILL.md` returns nothing.
- [ ] **The three MOVEs preserved git history.** `git log --follow --oneline host/templates/claude/commands/pe3-decompose.md` (and `pe4-finalize.md`, `pf3-decompose.md`) shows pre-move history — i.e. each was a `git mv`, not delete+recreate.
- [ ] **No old-name command/skill files remain on disk:** `ls host/templates/claude/commands/pe2-decompose.md host/templates/claude/commands/pe3-finalize.md host/templates/claude/commands/pf2-decompose.md host/templates/claude/skills/pe2-decompose host/templates/claude/skills/pe3-finalize host/templates/claude/skills/pf2-decompose` all return "No such file".
- [ ] **`/ps1-define` no longer stamps a footer.** `grep -n 'Inline Pattern-1 validation\|stamps the .*Validated.* footer itself\|consecutive_clean' host/templates/claude/commands/ps1-define.md` returns zero; the command ends defined-but-unvalidated.
- [ ] **`/e1-start-story` ready-ticket detection logic is byte-unchanged** except the doc-reference repoint: the footer-presence branch (Step 2 / lines ~46–48) still keys on the `Validated …` footer's *presence*; only the parenthetical attribution now names `/ps2-validate`.
- [ ] **Each `-validate` command refreshes STATUS.md** (po-status hook present): `grep -l 'po-status' host/templates/claude/commands/p{e2,f2,s2}-validate.md` lists all three.
- [ ] **No edits landed in generated `.claude/` paths.** `git status --porcelain | grep '\.claude/'` returns nothing (regen is Phase 5 `/f4`, not this plan).
- [ ] **No new generated-file footers leaked.** `grep -rln 'Managed by Shamt' host/templates/claude/` count increased by exactly 6 (the 3 new commands + 3 new skills) vs. base, and decreased by 0 for the renames (renamed files keep their footer with the new path).
- [ ] **Mermaid / link / reference targets in edited files still resolve** — spot-check the relative links repointed in Phases 3–4 (e.g. README's `(reference/epic_status_board.md)`, skill `commands/…` pointers) open to a real file.
- [ ] **One-to-one row coverage:** all 20 Proposed Changes rows have ≥1 step; no plan step lacks a row.

## Notes

- **MOVE = `git mv`, never delete+recreate.** Every row 7–12 step uses `git mv` to preserve blame/history (proposal Validation Considerations / Rollback feasibility). The whole-plan verification re-checks this with `git log --follow`.
- **The inline-validation loop moves, not copies.** Phase 1 S3 *authors* `ps2-validate.md` carrying the full Step-7 inline Pattern-1 loop + footer stamp (lifted verbatim from `ps1-define.md` with story-altitude wording preserved); Phase 3 S3 *removes* that loop from `ps1-define.md`. The two steps are in different phases but the index ordering (P1 before P3) guarantees the loop content is authored at its new home before it is removed from the old one.
- **po-status hook moves with the validation transition.** Phase 1 adds a STATUS.md refresh hook to each `-validate` command (rows 1–3); Phase 3 S3 removes the now-orphaned Step-7b hook from `/ps1-define` (row 15); Phase 3 S6 updates `epic_status_board.md`'s auto-refresh-hook list (row 18). All three must land for STATUS.md not to drift.
- **SHAMT_RULES.template.md is sweep-only (row 20m).** It receives the mechanical command-name rename only — **no** new normative `-validate` content (size-budgeted D12; the §PO-tree resolution already resolves any slug to its altitude folder, which is all dispatch needs). Confirm no new prose is added there.
- **`.claude/` is never touched.** Regen (Phase 5 `/f4-regen-framework`) propagates the canonical edits + the renamed/removed generated files. The MOVEs mean stale generated `.claude/` files for the old command/skill names must be *removed* by regen — flagged for the `/f4 --check`, out of scope for this plan.
- **Principle-1 reconciliation is homed in each new command's Notes** (horizontal sibling fan-out, not vertical chaining; stateless disk-derived dispatcher), beside #39's existing reconciliation — NOT in `CLAUDE.md` and NOT in `SHAMT_RULES.template.md` (per the proposal's "Deliberately NOT edited").
- **Fresh-agent runnable:** the proposal (footered) + the canonical files cited in every step live on disk. Each phase file resolves its targets by exact locate string.

---
Validated 2026-06-19 — 2 rounds, 1 adversarial sub-agent confirmed
