# Proposal: po-validate-stage

**Created:** 2026-06-19
**Status:** Implemented
**Number:** 41
**Proposed by:**
**Project context:**

---

## Problem

A follow-up to **#39 (po-parent-slug-batch-mode, landed)**, which gave `/pf1-define`, `/ps1-define`, and `/pf2-decompose` a parent-slug batch mode (pass a parent altitude's slug → the command runs its own single-artifact phase across every child sequentially, as a stateless disk-derived dispatcher). #41 extends that pattern to a missing phase: **validation has no first-class PO-flow stage.**

Today the PO flow has no explicit *validate* stage, and the three altitudes are inconsistent about it:

- **Epic** — `/pe1-define` produces `epic.md` with **no** `Validated …` footer and tells the user to run `/validate-artifact epics/{slug}-*/epic.md` by hand; `/pe2-decompose` then *requires* that footer as a prerequisite (`host/templates/claude/commands/pe2-decompose.md` Prerequisites). The validation step is real and load-bearing but unnamed — an ad-hoc `/validate-artifact` invocation the PO must remember to run, with the artifact path copied by hand.
- **Feature** — identical: `/pf1-define` defers validation to `/validate-artifact`; `/pf2-decompose` requires the footer.
- **Story** — the odd one out: `/ps1-define` runs an **inline Pattern-1 validation loop** and stamps the footer itself (`host/templates/claude/commands/ps1-define.md` Step 7), so the story altitude has *no* separate validate step while the other two do. This asymmetry is called out in that command's own Notes ("Unlike `/pe1-define` and `/pf1-define` …").

So there is no command whose name says "validate this artifact," validation is a hand-copied `/validate-artifact {path}` at two altitudes and a baked-in loop at the third, and — unlike define and decompose after #39 — there is **no batch form**: after `/pe2-decompose` writes N feature stubs and the PO fleshes them all out via batch `/pf1-define {epic-slug}`, validating them is still N manual `/validate-artifact {feature.md}` invocations, each path copied by hand off the epic's `Target Features` list.

**The change.** Introduce a first-class `-validate` stage at each altitude, slotted as **stage 2** (between define and decompose/finalize), making the PO flow uniformly **define → validate → decompose/finalize** at every altitude:

- `/pe2-validate {epic-slug}` — equivalent to `/validate-artifact` on that epic's `epic.md`.
- `/pf2-validate {feature-slug}` — `/validate-artifact` on `feature.md`; **or** pass the parent **epic** slug → batch-validate every feature under the epic.
- `/ps2-validate {story-slug}` — `/validate-artifact` on `ticket.md`; **or** pass the parent **feature** slug → batch-validate every story under the feature.

Each `-validate` command is a thin **altitude-aware wrapper over the existing `/validate-artifact` Pattern-1 loop** (single mode = validate the one resolved artifact, footer stamped exactly as `/validate-artifact` does it), plus — for features and stories — the **parent-slug batch mode introduced by #39** (parent epic / parent feature → run the single-artifact validation across every child sequentially; epic is the top altitude so `/pe2-validate` is single-only). Batch validation reuses #39's documented dispatcher contract verbatim: disk-derived ordered worklist from the parent's `Target …` / `Sequencing & Parallelization`, skip-already-validated-with-notice resumability, halt-at-child on an unresolvable outcome, and a final per-child summary — exactly as `/pf2-decompose`'s and `/ps1-define`'s batch modes already do, and analogous to validating a batch of plans in the framework-update flow.

Inserting a stage 2 renumbers the stages below it (the user-directed intent — "this will become the -2 stage, and the decompose stage will become -3"):

- Epic: `/pe2-decompose` → **`/pe3-decompose`**, and `/pe3-finalize` → **`/pe4-finalize`** (forced — decompose cannot occupy `pe3` alongside finalize; finalize moves to keep the sequence contiguous).
- Feature: `/pf2-decompose` → **`/pf3-decompose`**.
- Story: no renumber — the story altitude has no decompose/finalize, so `/ps2-validate` is purely additive after `/ps1-define`.

Because the story altitude gains a dedicated validate stage, **`/ps1-define`'s inline Pattern-1 validation loop (Step 7) and footer stamp are removed** and moved into `/ps2-validate`, eliminating the long-standing asymmetry: define no longer validates at *any* altitude (the design intent confirmed in drafting — define stages do not produce footers; validation is its own stage). The `Validated …` footer still lands on `ticket.md`, so `/e1-start-story`'s flagless ready-ticket detection (which keys on the footer's *presence*, `host/templates/claude/commands/e1-start-story.md` Step 2 / lines 46–48) is functionally unchanged — only the doc reference to "stamped by `/ps1-define`'s inline validation loop" repoints to `/ps2-validate`.

This is **horizontal sibling fan-out at one altitude** (validate every sibling under a parent), the same shape #39 established — distinct from vertical cross-altitude chaining, which the PO commands deliberately forbid. Batch `/pf2-validate` over an epic validates the features; it does **not** then decompose them (that stays `/pf3-decompose`). Each `-validate` command stays independently runnable via its own single slug.

---

## Proposed Changes

A flat list of canonical files the proposal will touch. **Every file the proposal will edit, create, delete, or move must appear here** — Phase 2 (validate-artifact) and Phase 4 (implement-update) both read this list as the source of truth for change scope.

| # | Canonical path | Operation | One-line change description |
|---|----------------|-----------|------------------------------|
| 1 | `shamt-core/host/templates/claude/commands/pe2-validate.md` | CREATE | New epic-altitude validate command. Resolves the epic slug, then runs the `/validate-artifact` Pattern-1 loop on `epic.md` (single mode only — epic is the top altitude, no parent to batch from), stamps the footer, and refreshes the epic `STATUS.md` (po-status hook, per #40). Body cites `validate-artifact.md` as the loop source of truth (no dimension re-derivation), mirrors `/pe2-decompose`'s slug-resolution + prereq shape, and suggests `/pe3-decompose {slug}` next. |
| 2 | `shamt-core/host/templates/claude/commands/pf2-validate.md` | CREATE | New feature-altitude validate command. Step-1 altitude-dispatch: own altitude (feature slug) → `/validate-artifact` on `feature.md`; parent altitude (epic slug) → batch over the epic's features; neither → halt. Includes a `## Parent-slug batch mode (epic → validate all features)` section reusing #39's dispatcher contract (disk-derived worklist from the epic's `Target Features` / `Sequencing & Parallelization`, skip-already-validated-with-notice resumability, halt-at-child on unresolvable outcome, final summary), refreshes `STATUS.md` once per validated child, and the horizontal-vs-vertical Principle-1 reconciliation in Notes. Suggests `/pf3-decompose {slug}` next. |
| 3 | `shamt-core/host/templates/claude/commands/ps2-validate.md` | CREATE | New story-altitude validate command. Carries the **full inline Pattern-1 validation loop + footer stamp removed from `/ps1-define`** (single mode = `/validate-artifact` on `ticket.md`). Step-1 altitude-dispatch: own (story slug) → validate the one ticket; parent (feature slug) → batch over the feature's stories; neither → halt. `## Parent-slug batch mode (feature → validate all stories)` section reusing #39's contract; refreshes `STATUS.md` per validated child. Suggests `/e1-start-story {slug}` next (the footer it stamps is `/e1-start-story`'s readiness signal). |
| 4 | `shamt-core/host/templates/claude/skills/pe2-validate/SKILL.md` | CREATE | Mirror skill for `/pe2-validate`. `## Protocol` is the canonical-command-body pointer ("Follow the canonical `/pe2-validate` command body verbatim — see `commands/pe2-validate.md`") — no step paraphrase (D2 Command → Skill Protocol pointer rule / #37). Frontmatter `description` + triggers surface "validate the epic." |
| 5 | `shamt-core/host/templates/claude/skills/pf2-validate/SKILL.md` | CREATE | Mirror skill for `/pf2-validate`; Protocol = pointer; description surfaces single + parent-epic batch ("validate all features in the epic"). |
| 6 | `shamt-core/host/templates/claude/skills/ps2-validate/SKILL.md` | CREATE | Mirror skill for `/ps2-validate`; Protocol = pointer; description surfaces single + parent-feature batch ("validate all stories in the feature"). |
| 7 | `shamt-core/host/templates/claude/commands/pe2-decompose.md` → `pe3-decompose.md` | MOVE | Rename the epic-decompose command. Update self-labels "Phase 2" → "Phase 3" of the PO flow, repoint its prerequisite from a hand-run `/validate-artifact` to `/pe2-validate {slug}`, and repoint its next-phase suggestion to `/pe4-finalize`. Existing `/pe2-decompose` parent-slug behavior and the po-status hook (#40) are preserved under the new name. |
| 8 | `shamt-core/host/templates/claude/commands/pe3-finalize.md` → `pe4-finalize.md` | MOVE | Rename the epic-finalize command (forced by the renumber). Update self-labels "Phase 3" → "Phase 4" and any prereq references to the decompose stage to `/pe3-decompose`. No behavioral change. |
| 9 | `shamt-core/host/templates/claude/commands/pf2-decompose.md` → `pf3-decompose.md` | MOVE | Rename the feature-decompose command. Update self-labels (PO-flow phase number), repoint its prerequisite from a hand-run `/validate-artifact` to `/pf2-validate {slug}`, preserve the existing parent-slug batch mode + po-status hook under the new name. |
| 10 | `shamt-core/host/templates/claude/skills/pe2-decompose/` → `skills/pe3-decompose/SKILL.md` | MOVE | Rename the epic-decompose skill folder to match; update the managed-file regen pointer comment + frontmatter description; Protocol stays the pointer. |
| 11 | `shamt-core/host/templates/claude/skills/pe3-finalize/` → `skills/pe4-finalize/SKILL.md` | MOVE | Rename the epic-finalize skill folder to match; update regen pointer comment + description. |
| 12 | `shamt-core/host/templates/claude/skills/pf2-decompose/` → `skills/pf3-decompose/SKILL.md` | MOVE | Rename the feature-decompose skill folder to match; update regen pointer comment + description. |
| 13 | `shamt-core/host/templates/claude/commands/pe1-define.md` | EDIT | Repoint the next-phase suggestion from `/validate-artifact epics/{slug}-*/epic.md` to `/pe2-validate {slug}`; update the Exit-criteria / Notes line "`/validate-artifact` adds it" to name `/pe2-validate` as the validate stage; rename any `/pe2-decompose` reference to `/pe3-decompose`. |
| 14 | `shamt-core/host/templates/claude/commands/pf1-define.md` | EDIT | Repoint the next-phase suggestion to `/pf2-validate {slug}`; rename `/pf2-decompose` references to `/pf3-decompose`. (#39 parent-epic batch "define all features" mode is unchanged.) |
| 15 | `shamt-core/host/templates/claude/commands/ps1-define.md` | EDIT | **Remove the inline Pattern-1 validation loop (Step 7) and the footer stamp**; remove the footer-stamp-tied `STATUS.md` po-status refresh hook (it moves to `/ps2-validate`); the command now ends after the open-questions dialog with `ticket.md` defined-but-unvalidated. Repoint the next-phase suggestion to `/ps2-validate {slug}`. Update the `## Parent-slug batch mode` section + Notes so the story batch is "define all stories" (no inline validation / footer); its skip-resumability signal becomes "already-defined" rather than "already-validated footer present." Update the Purpose/Notes asymmetry callout (define now defers validation at *every* altitude). |
| 16 | `shamt-core/host/templates/claude/commands/e1-start-story.md` | EDIT | Repoint the ready-ticket detection doc reference (Step 2 / lines 46–48) from "the `Validated …` footer (stamped by `/ps1-define`'s inline validation loop)" to `/ps2-validate`. Detection logic is unchanged — it keys on the footer's *presence* on `ticket.md`. |
| 17 | `shamt-core/README.md` | EDIT | Under the Product Owner flow sections: insert the three `-validate` rows into the command tables, renumber the decompose/finalize rows + phase numbers, and add a short note (beside the existing #39 batch note) that passing a **parent** slug to `/pf2-validate` / `/ps2-validate` validates every child sequentially — disk-derived and resumable. |
| 18 | `shamt-core/reference/epic_status_board.md` | EDIT | Renumber command references (`/pe2-decompose` → `/pe3-decompose`, etc.); note that the **New → Validated** state transition is now produced by the `-validate` stage (`/pe2-validate` / `/pf2-validate` / `/ps2-validate`) rather than `/ps1-define` / a hand-run `/validate-artifact`. The footer-presence derivation rule itself is unchanged. |
| 19 | `shamt-core/reference/model_selection.md` | EDIT | Renumber PO-command references to the renamed commands; **revise the existing `/ps1-define` row** (currently line ~66) — its rationale "Open-questions dialog **plus** an inline Pattern-1 validation loop" must drop the inline-validation-loop clause (the loop moves to `/ps2-validate`), leaving it a pure define/dialog stage; re-tier it consistently with the other define stages if the inline loop was the sole reason it sat above Balanced (`/pe1-define` / `/pf1-define` are Balanced); and add the three new `-validate` commands at the validation tier (the loop escalates to Reasoning per the existing `/validate-artifact` row guidance). |
| 20 | (sweep) remaining canonical files referencing the renamed commands | EDIT | Mechanical reference rename `/pe2-decompose`→`/pe3-decompose`, `/pe3-finalize`→`/pe4-finalize`, `/pf2-decompose`→`/pf3-decompose` across the remaining sites surfaced by grep: `host/templates/claude/commands/{pf0-draft,ps0-draft,e8-finalize-story}.md`, `host/templates/claude/skills/{pe1-define,pf0-draft,pf1-define,e8-finalize-story}/SKILL.md`, `reference/trackers/local.md`, `templates/{epic.template.md,feature.template.md,SHAMT_RULES.template.md,ticket.ado.template.md,ticket.github.template.md}`. Phase 3 (`/f2`) enumerates every exact site. |

**Path discipline:**

- **CREATE** rows (1–6) give exact target paths + one-line content sketches.
- **EDIT** rows (13–20) name the exact section / heading.
- **MOVE** rows (7–12) are renames preserving git history (`git mv`); each is one logical rename of a file (or skill folder + its single `SKILL.md`).
- Generated `.claude/` files are **never** listed — all rows are under `host/templates/claude/`, `reference/`, `templates/`, or root-level `README.md`. Regen (Phase 5) propagates to `.claude/`.

**Phase 3 required — file count 20 > 10. Run /f2-plan-update-implementation po-validate-stage before /f3-implement-update.** The plan must mechanically enumerate every cross-reference site behind row 20 (grep-driven) and order the renames so no dangling reference survives.

**Deliberately NOT edited:**

- `templates/SHAMT_RULES.template.md` carries **no per-command flow detail** (size-budgeted, D12) — the batch/validate behavior is command-level, exactly as #39's batch mode and `/f-all` / `/e-all` are kept out of the rules file. The §PO-tree resolution already resolves any slug to its altitude folder, which is all the dispatch needs. SHAMT_RULES appears in row 20 **only** for the mechanical command-name rename (if it names the renamed commands), not for any new normative content.
- `shamt-core/CLAUDE.md` — the `/f-all` / `/e-all` reconciliations live there as master-dev-primer driver concepts; this is child-facing PO-flow command behavior, so its Principle-1 reconciliation is homed inline in each command's Notes (beside the #39 reconciliation), not in the primer.
- `/pe1-define` / `/pf1-define` define-stage *behavior* — they already defer validation; only their next-phase suggestion + decompose references change (rows 13–14). No validation logic is added to them.
- `/pe2-validate` batch mode — epic is the top altitude with no parent, so `/pe2-validate` is single-only (no batch section). Only `/pf2-validate` and `/ps2-validate` get parent-slug batch modes.

---

## Risks

- **Regression risk (renumber sweep)** — the rename touches ~25 canonical files; a missed reference site leaves a dangling `/pe2-decompose` / `/pf2-decompose` / `/pe3-finalize` link. Mitigation: row 20 is a grep-driven sweep, the mandatory Phase 3 plan enumerates every site, and Phase 6 `/f5-audit-framework` D4 (reference validity) catches any survivor.
- **Regression risk (ps1 validation removal)** — removing `/ps1-define`'s inline loop must not break `/e1-start-story`'s ready-ticket pickup. Mitigation: the footer still lands on `ticket.md` (now stamped by `/ps2-validate`), and `/e1-start-story` keys on the footer's *presence*, not the stamping command — row 16 is a doc-reference repoint only, the detection logic is byte-for-byte unchanged. The PO flow gains one explicit step (`/ps1-define` → `/ps2-validate` → `/e1-start-story`) where before it was two; this is the intended uniformity, surfaced in the README + each command's next-phase suggestion.
- **Principle-1 / mega-orchestrator risk** — batch `-validate` could be misread as a state-holding orchestrator. Mitigation: framed as a stateless, disk-derived dispatcher of the command's *own* single-artifact `/validate-artifact` logic — the same reconciliation #39 already homes in each command's Notes and `CLAUDE.md` homes for `/f-all` / `/e-all` — and explicitly horizontal (validate siblings) not vertical (no chaining into decompose).
- **Interactivity risk** — validation can surface findings requiring a re-draft; in batch mode this must stay per-child. Mitigation: each child runs its own complete `/validate-artifact` loop before the next starts; halt-at-child on a loop that won't converge (#39's contract). No bulk-bombing.
- **Resumability / partial-completion risk** — a batch interrupted partway must resume cleanly. Mitigation: skip-already-validated-with-notice is disk-derived per child (the `Validated …` footer on the child artifact), so re-invocation resumes at the first unvalidated child.
- **STATUS.md (#40) drift risk** — the New→Validated transition moves from `/ps1-define` to the `-validate` stage; if the po-status refresh hook is not moved/added, STATUS.md goes stale. Mitigation: rows 1–3 add the refresh hook to each `-validate` command; row 15 removes the now-orphaned hook from `/ps1-define`; row 18 updates the derivation contract's command references.
- **Canonical/`.claude/` drift** — if regen is missed. Mitigation: Phase 5 `/f4-regen-framework --check`. Note the MOVEs mean stale generated `.claude/` files for the old command names must be removed by regen, not just overwritten — flag this for the `/f4` check.
- **Child-project compatibility** — installed children pick this up on the next `import-shamt` + regen. The renamed commands are a breaking change to muscle memory / any child scripts referencing `/pe2-decompose` etc., but Shamt commands are invoked interactively, not scripted; regen removes the old generated command files and installs the new ones. No data migration — epics/features/stories on disk are unaffected (the rename is to *commands*, not artifacts).
- **Open-questions debt** — none outstanding. Both drafting questions are resolved below and folded into the change list / risks.

---

## Rollback Plan

Revert the commit and re-run `/f4-regen-framework` (which restores the old command names in `.claude/` and removes the new ones). No child-side action required beyond the next routine `import-shamt`. On-disk epics/features/stories are untouched by the change, so there is no artifact migration to undo. Any artifact validated via the new `/ps2-validate` keeps its `Validated …` footer (footer format is unchanged), so a revert does not invalidate already-validated work.

---

## Validation Considerations

Dimension hints for the Phase 2 validation loop.

- **Problem clarity** — the horizontal-fan-out vs. vertical-chaining distinction (inherited from #39) is the concept most likely to be misread. Verify the proposal never implies batch `/pf2-validate` decomposes the features it validates. Also verify the "define no longer validates at *any* altitude" claim is stated consistently (it is the whole point of moving ps1's loop out).
- **Change-list completeness** — the load-bearing edits are the three CREATEs (rows 1–3), the three command MOVEs (7–9), and the `/ps1-define` validation-removal (row 15). Easy-to-forget paired edits: (a) each MOVE'd command needs its skill folder renamed too (rows 10–12) — a command rename without the skill rename breaks the mirror; (b) the po-status hook must move with the validation transition (rows 1–3 add, row 15 removes); (c) `/e1-start-story` references ps1 by name (row 16). The three new SKILL `## Protocol` sections must be the **pointer form**, never a step paraphrase (D2 Command → Skill Protocol pointer rule / #37). Confirm row 20's grep covers every site — re-run `grep -rE 'pe2-decompose|pf2-decompose|pe3-finalize'` over `templates reference host README.md CLAUDE.md` and check the count matches the plan.
- **Risk coverage** — confirm the regression risks (renumber sweep + ps1 removal) and the Principle-1 reconciliation are addressed in the command Notes, not only in this proposal. Confirm the `/e1-start-story` footer-presence invariant is preserved.
- **Rollback feasibility** — the MOVEs use `git mv` to preserve history; verify no MOVE is implemented as delete+recreate (which would lose blame). No artifact-level migration.
- **Affected surfaces** — commands (3 new + 3 renamed + 4 edited), skills (3 new + 3 renamed + edits), references (2), templates (sweep), README (1). Heavy cross-doc consistency load: the three new `-validate` command bodies and the two batch sections should use **parallel structure** with #39's existing batch sections (same section-name shape, same skip-resumability wording, same summary shape) so D7 terminology stays consistent across the now-larger PO-command family.
- **Propagation plan** — requires Phase 5 regen into `.claude/`, including **removal** of the stale generated command/skill files for the old names (a rename, not just an overwrite). Installed children pick it up on the next `import-shamt`. No manual child nudge beyond that.

---

## Open Questions

_All resolved — see Resolved Questions below._

---

## Resolved Questions

<!-- Drafting-only log. -->

- ~~Q-A1: How does #41 relate to #39 (parent-slug batch mode), which was still in draft when drafting began?~~ → A: **Build directly on #39 — it is now landed.** A parallel session landed both #39 and #40 during drafting (git `f47cd7d` / `bb581c7`; both proposals now in `proposals/archive/`, batch mode confirmed present in the canonical command bodies). #41 reuses #39's parent-slug batch dispatcher contract *by reference* for the new `-validate` batch modes rather than re-specifying it, and renames `/pf2-decompose` → `/pf3-decompose` on top of #39's edits.
- ~~Q-A2: `/ps1-define` runs an inline Pattern-1 validation loop + footer stamp today (unlike `/pe1-define` / `/pf1-define`). With a dedicated `/ps2-validate` stage, keep it or remove it?~~ → A: **Remove it; move validation into `/ps2-validate`.** Define stages do not produce validation footers — validation is its own stage at every altitude (the user-confirmed design intent). This makes the story altitude match epic/feature (define → validate → …) and eliminates the asymmetry `/ps1-define`'s own Notes call out. `/e1-start-story`'s readiness signal keys on the footer's presence on `ticket.md` (unchanged location), so only a doc-reference repoint is needed (row 16), not a logic change.
- ~~Q-A3: Does inserting validate as stage 2 force renaming `/pe3-finalize`?~~ → A: **Yes — `/pe3-finalize` → `/pe4-finalize`.** With `/pe2-validate` new and `/pe2-decompose` → `/pe3-decompose`, finalize cannot stay at `pe3` (collision); it moves to `pe4` to keep the epic stage sequence contiguous. This is forced arithmetic from the user's directive ("decompose becomes -3"), recorded here so the renumber cascade is explicit. The story altitude has no decompose/finalize, so `/ps2-validate` is purely additive with no renumber.

---

<!-- Phase 2 validation appends the footer below on a clean exit. Do not pre-fill. -->

---
Validated 2026-06-19 — 3 rounds, 1 adversarial sub-agent confirmed
