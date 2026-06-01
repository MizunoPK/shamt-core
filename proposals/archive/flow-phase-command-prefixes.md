# Proposal: flow-phase-command-prefixes

**Created:** 2026-05-28
**Status:** Implemented
**Proposed by:**
**Project context:**

---

## Problem

Shamt exposes ~23 slash commands across three flows (Engineer, Product Owner, framework-update) plus the Part 4 master/child sync commands. The command names today are purely descriptive (`/start-story`, `/define-spec`, `/decompose-epic`, `/propose-update`, …). Nothing in a command's name tells the user **which flow it belongs to or where in that flow's phase sequence it sits**. A user scanning the slash-command menu, or a fresh agent resolving "what comes next," has to consult `CHEATSHEET.md` to recover that ordering.

The flows are already strictly phase-ordered — the CHEATSHEET tables (`CHEATSHEET.md` §Slash commands) number every command by phase: Engineer 1–7 (Intake → Polish), PO 1–4 (Epic → Feature decomposition), framework-update 1–7 (propose → archive). That ordering is load-bearing — every command's "suggest the next phase" step (e.g., `host/templates/claude/commands/propose-update.md` Step 7) names the next command by hand. Encoding the flow + phase directly in the command name (`/e1-start-story`, `/e2-define-spec`, `/p1-start-epic`, `/p2-decompose-epic`, `/f1-propose-update`, …) makes the sequence self-documenting at the point of invocation, groups each flow's commands together alphabetically in the menu, and removes a layer of CHEATSHEET lookups.

The change is mechanically wide but conceptually simple: rename each canonical command file under `host/templates/claude/commands/`, rename the mirrored skill under `host/templates/claude/skills/` 1:1, and update every textual cross-reference to the old command names across canonical command bodies, skill bodies, `CHEATSHEET.md`, `templates/SHAMT_RULES.template.md`, the artifact templates, the proposal template (`proposals/_template.md`), `reference/` (including `reference/trackers/`), the persona definitions, and the bootstrap scripts (`init-shamt.sh` / `import-shamt.sh`, whose user-facing output names commands). The regen script (`scripts/regenerate-framework.sh`) iterates the `commands/` and `skills/` directories rather than hardcoding names, so renamed files propagate into `.claude/` automatically — no script edit is required for the file moves themselves.

---

## Proposed Changes

**Naming scheme (resolved):** Engineer = `e{N}[b]-`, PO = `p{N}-`, framework-update = `f{N}-`, sync = `sync-` (no number). `/validate-artifact` stays unprefixed (cross-cutting). The full new-name map is the rename rows below.

**MOVE convention:** each rename row is a single `git mv old new` (history-preserving). Per the template, a MOVE is conceptually paired CREATE+DELETE; the Phase 3 plan records each as the rename it is. Every renamed **command** file has a paired **skill** rename (folder + `SKILL.md`), so the two are listed together in one row to keep the map readable — Phase 3 splits them into discrete steps.

### A. Command + skill renames (each row = `git mv` of the command file *and* its mirrored skill folder)

| # | Canonical path (old → new) | Operation | One-line change description |
|---|----------------------------|-----------|------------------------------|
| 1 | `host/templates/claude/commands/start-story.md` → `e1-start-story.md` (+ `skills/start-story/` → `skills/e1-start-story/`) | MOVE | Engineer Phase 1. |
| 2 | `…/commands/define-spec.md` → `e2-define-spec.md` (+ skill) | MOVE | Engineer Phase 2. |
| 3 | `…/commands/plan-implementation.md` → `e3-plan-implementation.md` (+ skill) | MOVE | Engineer Phase 3. |
| 4 | `…/commands/write-testing-plan.md` → `e3b-write-testing-plan.md` (+ skill) | MOVE | Engineer Phase 3 testing sub-phase. |
| 5 | `…/commands/execute-plan.md` → `e4-execute-plan.md` (+ skill) | MOVE | Engineer Phase 4 (Build). |
| 6 | `…/commands/execute-tests.md` → `e5-execute-tests.md` (+ skill) | MOVE | Engineer Phase 5 (Test). |
| 7 | `…/commands/write-manual-testing-plan.md` → `e5b-write-manual-testing-plan.md` (+ skill) | MOVE | Engineer post-Build optional, grouped with Test. |
| 8 | `…/commands/review-changes.md` → `e6-review-changes.md` (+ skill) | MOVE | Engineer Phase 6 (Review). |
| 9 | `…/commands/resolve-feedback.md` → `e7-resolve-feedback.md` (+ skill) | MOVE | Engineer Phase 7 (Polish). |
| 10 | `…/commands/start-epic.md` → `p1-start-epic.md` (+ skill) | MOVE | PO Phase 1. |
| 11 | `…/commands/decompose-epic.md` → `p2-decompose-epic.md` (+ skill) | MOVE | PO Phase 2. |
| 12 | `…/commands/start-feature.md` → `p3-start-feature.md` (+ skill) | MOVE | PO Phase 3. |
| 13 | `…/commands/decompose-feature.md` → `p4-decompose-feature.md` (+ skill) | MOVE | PO Phase 4. |
| 14 | `…/commands/propose-update.md` → `f1-propose-update.md` (+ skill) | MOVE | Framework-update Phase 1. |
| 15 | `…/commands/plan-update-implementation.md` → `f2-plan-update-implementation.md` (+ skill) | MOVE | Framework-update Phase 3 → renumbered f2 (validate-artifact dropped from count). |
| 16 | `…/commands/implement-update.md` → `f3-implement-update.md` (+ skill) | MOVE | Framework-update Phase 4 → f3. |
| 17 | `…/commands/regen-framework.md` → `f4-regen-framework.md` (+ skill) | MOVE | Framework-update Phase 5 → f4. |
| 18 | `…/commands/audit-framework.md` → `f5-audit-framework.md` (+ skill) | MOVE | Framework-update Phase 6 → f5. |
| 19 | `…/commands/archive-proposal.md` → `f6-archive-proposal.md` (+ skill) | MOVE | Framework-update Phase 7 → f6. |
| 20 | `…/commands/submit-proposal.md` → `sync-submit-proposal.md` (+ skill) | MOVE | Sync (child→master). |
| 21 | `…/commands/import-shamt.md` → `sync-import-shamt.md` (+ skill) | MOVE | Sync (master→child). |
| 22 | `…/commands/triage-proposals.md` → `sync-triage-proposals.md` (+ skill) | MOVE | Sync (master side). |

`host/templates/claude/commands/validate-artifact.md` and `skills/validate-artifact/` are **not** renamed.

### B. In-place edits inside the renamed files (each renamed `SKILL.md` + command body)

| # | Canonical path | Operation | One-line change description |
|---|----------------|-----------|------------------------------|
| 23 | every renamed `…/skills/{new}/SKILL.md` | EDIT | Update `name:` frontmatter, the `commands/{new}.md` relative-path reference, and the `Regenerate from …/commands/{new}.md` managed footer to the new name. |
| 24 | every renamed `…/commands/{new}.md` body | EDIT | Update self-title (`# /e2-define-spec`), `Usage` block, and the `Regenerate from …/commands/{new}.md` managed footer to the new name. |
| 25 | every command/skill body's cross-references | EDIT | Sweep "suggest next phase" steps and inline `/old-name` mentions to `/new-name` (e.g. `f1-propose-update` Step 7 → `/f2-plan-update-implementation`, and its Notes' `/implement-update`/`/regen-framework`). Bodies that reference no renamed command — e.g. `validate-artifact` (which mentions only itself + the `validation-checker` persona) — need no sweep. |

### C. Cross-reference sweeps in other canonical surfaces

| # | Canonical path | Operation | One-line change description |
|---|----------------|-----------|------------------------------|
| 26 | `CHEATSHEET.md` | EDIT | Rewrite the Engineer / PO / framework-update / sync command tables, the persona "Used by" table, and the auto-triggered-skills note with the new names. |
| 27 | `templates/SHAMT_RULES.template.md` | EDIT | Update the 6 command references (≈ lines 42, 117, 125: `/start-story`, `/define-spec`, `/plan-implementation`, `/write-manual-testing-plan`, `/execute-plan`, `/resolve-feedback`) to new names. |
| 28 | `templates/` artifact templates — `ticket.ado.template.md`, `ticket.github.template.md`, `epic.template.md`, `feature.template.md`, `manual_test_plan.template.md` | EDIT | Update command-name references in each (`/start-epic`, `/decompose-epic`, `/start-feature`, `/decompose-feature`, `/write-manual-testing-plan`, …). |
| 29 | `proposals/_template.md` | EDIT | The **canonical** proposal template (the framework-update flow seeds from it; the propose-update body calls it "the source of truth for proposal shape"). Update its `/propose-update`, `/plan-update-implementation`, `/implement-update`, `/archive-proposal`, `/triage-proposals`, `/regen-framework`, `/import-shamt` references. |
| 30 | `reference/` (recursive — 7 files: `audit_dimensions.md`, `model_selection.md`, `story_support.md`, `trackers/ado.md`, `trackers/github.md`, `trackers/local.md`, `trackers/_contract.md`) | EDIT | Update command-name references. |
| 31 | `host/templates/claude/agents/plan-executor.md`, `agents/test-executor.md`, `agents/audit-checker.md` | EDIT | Update persona-body command references (`/execute-plan`→`/e4-execute-plan`, `/implement-update`→`/f3-implement-update` in plan-executor; `/write-testing-plan`→`/e3b-write-testing-plan` in test-executor; `/audit-framework`→`/f5-audit-framework` in audit-checker, which names it in both its `description:` frontmatter and body). `review-executor.md` and `validation-checker.md` reference only `/validate-artifact` (unchanged) — no edit. |
| 32 | `init-shamt.sh`, `import-shamt.sh` | EDIT | Update **command names printed in user-facing output / comments** (e.g. init's "run `/start-story`…", `/submit-proposal`, `/import-shamt`, `/review-changes`, `/propose-update`). Script *logic* is untouched — see disambiguation note. |

**Phase 3 required — file count far exceeds 10.** The rows above name every *category* of reference site and the authoritative rename map; the exact per-file / per-line edit list (especially the §B/§C sweeps — `/validate-artifact`, though itself unchanged, co-occurs in ~40 canonical files, showing how dense the command cross-referencing is) is produced by `/plan-update-implementation flow-phase-command-prefixes` before `/implement-update`.

**`import-shamt` command-vs-script disambiguation:** the `/import-shamt` *command* renames to `/sync-import-shamt`, but the **script** `import-shamt.sh` keeps its filename — renaming it would break `init-shamt.sh`'s invocation and the self-update sync set. The sweep therefore targets the `/import-shamt` command form only; references to `import-shamt.sh` (and to `regenerate-framework.sh`) must be left untouched. The Phase 3 plan must encode this so a blanket find/replace does not corrupt script-file references.

**Scripts — what changes and what doesn't:** `scripts/regenerate-framework.sh` needs **no** edit — it iterates the `commands/`/`skills/` directories (`find ./commands/*`, `./skills/*`) rather than hardcoding names, so renamed files propagate to `.claude/` and the old ones are pruned automatically (confirmed by inspection). `init-shamt.sh` and `import-shamt.sh` (row 32) **do** need edits, but only to the command names they print in user-facing guidance — not to their logic.

**Out of scope (non-canonical / working docs):** `../INFRASTRUCTURE.md` and `../CLAUDE.md` (the v2-dev container planning + primer docs) and in-flight proposals such as `proposals/dot-shamt-core-layout.md` reference old command names but are not part of the `shamt-core/` sync set or the regenerated framework, so they are **not** in this table. The implementer may optionally refresh the container docs for currency; in-flight proposals are historical working docs and are left as-authored.

---

## Risks

- **Regression risk — broken cross-references.** The rename touches a large fan-out of files; any missed reference leaves a stale `/old-name` pointer in a "suggest next phase" step, the CHEATSHEET, or a skill body. The Phase 3 plan must enumerate every reference site so none is missed.
- **Muscle-memory / discoverability churn.** Users who have memorized `/define-spec` must relearn `/e2-define-spec`. This is a one-time cost; mitigated by the names being more discoverable afterward. No back-compat aliases (resolved — clean rename); old names are dropped on the next regen.
- **Drift risk.** Standard canonical↔`.claude/` drift if regen is skipped after the rename. Mitigated by the Phase 5 `/regen-framework` + `--check` step.
- **Child-project compatibility.** On the next `import-shamt`, a child's `.claude/commands/` will gain the new-named files and (via regen pruning of managed files no longer in canonical) drop the old-named ones. Any child muscle memory / local docs referencing old names break. No data loss — these are generated files.
- **Open-questions debt.** The naming scheme itself (numbering semantics, cross-cutting/helper/sync handling, skill renaming) must be fully resolved here, not deferred — they determine the literal new filenames.

---

## Rollback Plan

1. `git revert <commit-sha>` on the rename commit (the MOVEs and text edits land together).
2. Re-run regen to restore the old-named files in `.claude/` and prune the new-named ones. **Invoke the script directly — `bash scripts/regenerate-framework.sh` — not the slash command**, because at rollback time `.claude/` already carries the renamed `/f4-regen-framework` (the old `/regen-framework` no longer exists until this regen completes).
3. Child-side action: each installed child re-runs the import (post-rename the command is `/sync-import-shamt`, or `bash shamt-core/import-shamt.sh` directly) to pick up the revert.
4. Communication: describe the revert in the `git revert` commit message; child projects pick it up on the next `import-shamt`, whose diff report plus git history are the record of what changed (per the `deprecate-changes-md` update, `CHANGES.md` no longer exists).

---

## Validation Considerations

Dimension hints for the Phase 2 validation loop (`/validate-artifact proposals/flow-phase-command-prefixes.md`).

- **Problem clarity** — confirm the numbering scheme described in Resolved Questions is internally consistent across all three flows (no duplicate prefixes, no gaps the scheme doesn't intend).
- **Change-list completeness** — the highest-risk dimension. For every renamed command, the mirrored skill folder + its `name:` frontmatter + its `commands/{name}.md` relative-path reference + its "Regenerate from …" managed footer must all move together. Every command body's "suggest next phase" step must update. Beyond the bodies, all §C surfaces must be swept: `CHEATSHEET.md`, `templates/SHAMT_RULES.template.md`, the five artifact templates, the canonical `proposals/_template.md`, `reference/` (incl. `trackers/`), the `plan-executor` / `test-executor` / `audit-checker` personas, and the command names in `init-shamt.sh`/`import-shamt.sh` output. (Phase 3 produces the enumerated list; validation checks the proposal didn't omit a *category* of reference site.)
- **Risk coverage** — the list accounts for the persona "Used by" table in `CHEATSHEET.md` (row 26). `statusline.sh` was checked and references **no** command names (it emits phase *names* + `P{N}`), so it is correctly outside the sweep.
- **Rollback feasibility** — MOVEs preserve git history when done via `git mv`; confirm the plan specifies `git mv`.
- **Affected surfaces** — commands, skills, CHEATSHEET, rules template, all artifact templates (ticket/epic/feature/manual-test-plan), the canonical proposal template (`proposals/_template.md`), `reference/` (incl. `trackers/`), the `plan-executor` + `test-executor` + `audit-checker` personas, and the bootstrap scripts (`init-shamt.sh` / `import-shamt.sh`, command names in user-facing output). Scripts: `regenerate-framework.sh` needs no edit (iterates directories); `import-shamt.sh` filename is preserved (only the `/import-shamt` command form is swept). Out-of-canonical (`../INFRASTRUCTURE.md`, `../CLAUDE.md`, in-flight proposals) is explicitly excluded.
- **Propagation plan** — requires `/regen-framework` after edits; each installed child needs `/import-shamt`.

---

## Open Questions

_(none — all resolved; see Resolved Questions)_

---

## Resolved Questions

<!-- Append as questions resolve. -->

- ~~Q: How is cross-cutting `/validate-artifact` named, and how are the framework-flow commands numbered (given validate-artifact sits at canonical Phase 2)?~~ → A: **Contiguous per-flow numbering; `/validate-artifact` stays unprefixed** (it's cross-cutting across the Engineer and framework-update flows). The remaining core commands in each flow number contiguously from 1, skipping over validate-artifact. Result — Engineer: `e1-start-story`, `e2-define-spec`, `e3-plan-implementation`, `e4-execute-plan`, `e5-execute-tests`, `e6-review-changes`, `e7-resolve-feedback`. PO: `p1-start-epic`, `p2-decompose-epic`, `p3-start-feature`, `p4-decompose-feature`. Framework: `f1-propose-update`, `f2-plan-update-implementation`, `f3-implement-update`, `f4-regen-framework`, `f5-audit-framework`, `f6-archive-proposal`. (Engineer phases happen to remain 1–7 with no gap; framework renumbers contiguously because validate-artifact's Phase-2 slot is dropped.)
- ~~Q: Should the Engineer testing-plan helpers (`/write-testing-plan`, `/write-manual-testing-plan`) be prefixed?~~ → A: **Yes — sub-phase letter prefixes** tied to where they attach: `e3b-write-testing-plan` (Phase 3 testing sub-phase) and `e5b-write-manual-testing-plan` (post-Build, groups with the Test phase). They sort next to their phase in the menu. (`/validate-artifact` remains the only unprefixed cross-cutting command.)
- ~~Q: Should the Part 4 master/child sync commands be prefixed?~~ → A: **Yes — a non-numbered `sync-` group prefix** (they cluster in the menu but aren't a phase sequence): `sync-submit-proposal` (child→master), `sync-import-shamt` (master→child), `sync-triage-proposals` (master side).
- ~~Q: Should the mirrored skills be renamed to match the new command names?~~ → A: **Yes — rename skills 1:1.** Each skill folder + its `name:` frontmatter is renamed to the new command name (`skills/e2-define-spec/`, `name: e2-define-spec`, etc.), preserving the strict command↔skill mirror invariant. (`validate-artifact` skill stays as-is, matching its unchanged command.)
- ~~Q: Should old command names be kept as back-compat aliases?~~ → A: **No — clean rename, no aliases.** The request was to rename, not to add a parallel surface; aliases would double the command count and the maintenance/regen surface. Old names are dropped (regen prunes the old `.claude/` files). This is the one assumption folded in without a separate dialog turn, as it follows directly from the "update the commands" framing; flagged here for visibility.

---

<!-- Phase 2 validation appends the footer below on a clean exit. Do not pre-fill. -->

---
Validated 2026-05-28 — 4 rounds, 1 adversarial sub-agent confirmed
Re-validated 2026-05-30 — 3 rounds, 1 adversarial sub-agent confirmed (fixed 2 HIGH — row 30 reference-sweep list omitted `audit_dimensions.md`; rollback step 4 pointed at the deprecated `CHANGES.md` — and 1 LOW: the `/validate-artifact` co-occurrence count).
Re-validated 2026-05-30 — corrected row 31 persona coverage: added `agents/audit-checker.md` (carries `/audit-framework` ×2) and confirmed `review-executor.md` + `validation-checker.md` are `/validate-artifact`-only (no edit). Surfaced during `/validate-artifact` of the companion `_PLAN`; 1 adversarial sub-agent confirmed.
