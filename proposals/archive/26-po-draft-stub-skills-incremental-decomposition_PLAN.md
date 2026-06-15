# Implementation Plan: po-draft-stub-skills-incremental-decomposition (index)

**Proposal:** proposals/26-po-draft-stub-skills-incremental-decomposition.md
**Created:** 2026-06-14
**File operations:** 37 (CREATE: 8, MOVE: 10, DELETE: 2, EDIT: 17)

> **Operation-count note.** The proposal's Proposed Changes table lists 37 *rows*. The 10 MOVE rows (rows 9–18) are each a `git mv` **plus** an in-body rewrite, so they expand into more than one mechanical edit apiece (the rename + N internal locate/replace edits); the post-execution cross-check below maps every plan step back to its source row, not the other way around. The 17 EDIT rows are rows 21–37 — section D (Engineer-flow boundary, rows 21–24, 4 rows), section E (reference/template/rules cross-refs, rows 25–35, 11 rows), and section F (install/sync scripts, rows 36–37, 2 rows) — matching the `EDIT: 17` count in the header above. See the per-row mapping in each phase file.

## Why this plan is phase-decomposed

This is a 37-row reorganization spanning 10 full command/skill body rewrites (each 40–220 lines, internally referencing the old `/pN` name dozens of times), 8 new command+skill CREATEs that mirror existing siblings, 2 DELETEs, and 17 cross-reference EDITs across README / rules / model_selection / four tracker profiles / four templates / two install scripts / the e1+e8 consumer boundary. A single-file plan would exceed ~1500 lines and compact a single Phase-4 session. Per `/f2-plan-update-implementation` Step 2 (phase-decomposition rule, mirroring the Principle 1 single-session sizing constraint), it is split into an index + 5 phase files, each independently validatable.

**Ordering constraint (declared):** the phases are ordered so the new grid command names exist on disk before the cross-reference EDITs point at them, and the renames happen before the references to the old names are rewritten. Execute phases in order 1 → 2 → 3 → 4 → 5. Within a phase, execute steps in listed order. No step in a later phase is a prerequisite of an earlier phase.

## Phase files

| Phase | File | Scope | Source rows | Steps |
|-------|------|-------|-------------|-------|
| 1 | `proposals/26-po-draft-stub-skills-incremental-decomposition_PLAN_phase_1.md` | New draft/define command+skill CREATEs | 1–8 | 8 |
| 2 | `proposals/26-po-draft-stub-skills-incremental-decomposition_PLAN_phase_2.md` | Epic-lane MOVEs (`pe1` / `pe2` / `pe3` + skills) | 9–12, 17–18 | 6 |
| 3 | `proposals/26-po-draft-stub-skills-incremental-decomposition_PLAN_phase_3.md` | Feature-lane MOVEs (`pf1` / `pf2` + skills) | 13–16 | 4 |
| 4 | `proposals/26-po-draft-stub-skills-incremental-decomposition_PLAN_phase_4.md` | `/p6` DELETEs + e1/e8 consumer EDITs | 19–24 | 6 |
| 5 | `proposals/26-po-draft-stub-skills-incremental-decomposition_PLAN_phase_5.md` | Reference + template + rules + script cross-ref EDITs | 25–37 | 13 |

## Pre-execution checklist (applies to every phase)

- [ ] On a clean working tree (the shared working tree for this `/f-all` run; `/f3-implement-update` creates `proposal/26-po-draft-stub-skills-incremental-decomposition` before edits).
- [ ] `proposals/26-po-draft-stub-skills-incremental-decomposition.md` carries its `Validated …` footer (present — 2026-06-14, 7 rounds).
- [ ] **Never touch `.claude/`.** Every path in every phase file is canonical (`shamt-core/host/templates/claude/…`, `templates/…`, `reference/…`, `README.md`, `init-shamt.sh`, `import-shamt.sh`). Generated `.claude/` propagation is the separate `/f4-regen-framework` step (framework-update-flow Phase 5), run *after* this plan's five phases complete — not part of any plan phase here.
- [ ] Each MOVE step is `git mv {old} {new}` (history-preserving) **then** the listed in-body EDITs against the new path. Do the `git mv` first so the subsequent EDITs land on the renamed file.

## Verification (post-execution, whole plan)

- [ ] Every row 1–37 in the Proposed Changes table maps to a step (per-phase row mapping confirms one-to-one coverage; MOVE rows map to a rename step + its in-body edits).
- [ ] Every CREATE file (rows 1–8) exists and mirrors its named sibling shape.
- [ ] No `git mv` or EDIT landed in a generated `.claude/` path: `git status --porcelain | grep -E '^\s*[ACMRD].*\.claude/'` returns nothing.
- [ ] No dangling old name remains in active canonical surfaces: `grep -rnE '/p[1-6]-(start|decompose|finalize|draft)' README.md templates reference host/templates init-shamt.sh import-shamt.sh` returns **zero** matches (archived/historical references under `proposals/archive/` are intentionally left, per the proposal's Risks → Archived-history references).
- [ ] `grep -rn "Managed by Shamt" shamt-core/host/templates/claude/commands shamt-core/host/templates/claude/skills` returns the expected footer count after the 8 CREATEs, 10 renames, and 2 deletions (net command/skill file count: +8 −2 = +6 over the prior set; renames preserve count).
- [ ] Markdown link / `Regenerate from …` footer / cross-reference targets in every edited and renamed file resolve (each renamed file's `Regenerate from shamt-core/host/templates/claude/…/{old}.md` footer is updated to the new filename — see per-phase steps).

## Notes for the executor

- **Stub-shape parity (proposal Risks → Regression risk; Resolved Questions → draft↔define ingestion + distinct draft status).** The two new single-stub producers `/pf0-draft` (row 3) and `/ps0-draft` (row 5) must emit the **same core stub sections** the batch decompose commands `/pe2-decompose` (row 11) and `/pf2-decompose` (row 15) emit — Goal/scope one-liner, `## Decomposition Context` (where applicable), parentage-by-folder-path, allocated Ticket ID — because the define stage and the re-decomposition partition both read that core shape. The draft producers additionally carry two **additive, draft-only** elements layered on top: a `**Status:** Draft (f0 — {epic|feature|story}-idea capture, unrefined)` marker line directly beneath the `**Ticket ID:** {ID}` line, and a `## Scratch Notes (stage-0 capture)` section. This overlay is **not** a parity violation: define (`/pe1-define` / `/pf1-define` / `/ps1-define`) detects the marker → ingests (seeds dialog from Scratch Notes, then strips both the marker line and the Scratch Notes section on completion, exactly as `/f1-propose-update` ingests + clears an f0 draft); marker absent → the existing seed-from-scratch / bare-decompose-stub path is unchanged. The batch decompose commands stay **unchanged** (no marker). Phase 1's CREATE steps reference the exact core stub-section contract from the decompose commands plus this additive overlay; do not invent a divergent **core** shape.
- **e1 detection (proposal Risks → Engineer-boundary regression).** Row 21's e1 edit extends the **existing** Step-2 folder-path detection with the validation-footer signal — no new flag, no new template, no new status marker. Phase 4 Step 3 gives the exact locate/replace; do not add a flag.
- **MOVE = `git mv` + body rewrite, not delete+recreate.** Preserve git history. The body rewrite updates: the `# /pN-...` H1, the `name:` front-matter (skills), every internal `/pN-...` self-reference and cross-reference, the next-phase suggestion, and the trailing `Regenerate from …{old}.md` HTML comment. Exact strings are enumerated per step.
- **Re-grep before declaring done.** The proposal's Validation Considerations (b) require a final `grep -rnE '/p[1-6]-(start|decompose|finalize|draft)'` over the canonical tree. If a *new* reference site appears that is not covered by a step here, that is a missing Proposed Changes row → the executor halts and the architect performs an in-place amendment (append the row, strip the footer, re-validate) per `/f2` Step 3; it is not silently fixed.

## Open Questions

None — the proposal resolved all architecture decisions (see its Resolved Questions); every step below is mechanical.

---
Validated 2026-06-14 — batch-validated (Standard path), 1 adversarial sub-agent confirmed
