# Proposal: po-engineer-finalize-archive-stage

**Created:** 2026-06-08
**Status:** Implemented
**Number:** 13
**Proposed by:** [master-local]
**Project context:** [master-local]

---

## Problem

Two of Shamt's three role flows end without a terminal "finalize" ritual, and
the framework-update flow — the one that *does* have one — shows exactly what is
missing.

- The **Engineer flow** ends at Phase 6 Polish (`/e7-resolve-feedback`), whose
  gate in `templates/SHAMT_RULES.template.md` (Standard path map) is simply
  *"User signals complete"* with a `feedback/addressed_feedback.md` + commits
  artifact. `e7-resolve-feedback.md` confirms Polish "has no automatic
  completion gate; the user calls it done." There is no explicit step that
  commits the story's work as a coherent unit and marks the originating work
  item finished — commits happen ad hoc during Polish, and closing the tracker
  item (ADO / GitHub / local) is left entirely to the user.
- The **PO flow** ends at `/p4-decompose-feature` (Feature → story stubs). Once
  every child feature/story of an epic has been delivered, the epic has no
  "done" state and no archive. It sits in `epics/` indefinitely,
  indistinguishable from in-flight epics, and the status-line `EPIC {slug}`
  fallback (`host/templates/claude/statusline.sh`) keeps surfacing completed
  initiatives.
- The **framework-update flow**, by contrast, ends cleanly: `/f6-archive-proposal`
  flips the proposal Status to `Implemented`, commits the canonical edits + regen
  output + the archive move, squash-merges the proposal branch, and moves the
  file into `proposals/archive/`. That is the model the other two flows lack.

This proposal adds a formalized **finalize** stage — one new terminal command per
flow, each modelled on `/f6-archive-proposal`: `/e8-finalize-story` (Engineer)
and `/p5-finalize-epic` (PO, epic altitude). Each commits the work, marks the
originating work item finished via the active tracker profile, and — at the epic
altitude — moves the done epic into an `epics/archive/` folder analogous to
`proposals/archive/`.

> **Scope note.** A sibling proposal, `po-nested-folder-layout` (now drafted and
> validated as **proposal #14**), reworks the PO hierarchy from the current **flat**
> layout (`epics/`, `features/`, `stories/` as three top-level dirs linked by
> back-ref headers) to a **nested** one (features under their epic, stories under
> their feature). This proposal (#13) is deliberately scoped to the finalize
> stage **on the current flat layout**: `/p5-finalize-epic` moves the epic folder
> only (its features/stories stay in their sibling top-level dirs; back-ref
> headers keep resolving to the archived epic). When the nested-layout proposal
> lands, the epic-archive move becomes a natural whole-subtree cascade and
> `/p5-finalize-epic`'s archive step is revisited then. The two are separated
> because the layout rework touches ~46 canonical files (proposal #14) and
> warrants its own Phase 3 plan; the finalize stage is 10 files and ships
> independently.

---

## Proposed Changes

| # | Canonical path | Operation | One-line change description |
|---|----------------|-----------|------------------------------|
| 1 | `shamt-core/host/templates/claude/commands/e8-finalize-story.md` | CREATE | New Engineer terminal command: finalize a story — scoped commit + mark the work item done via the active tracker profile, behind the three guards (prior phases complete, clean-tree/scoped commit, explicit confirmation). |
| 2 | `shamt-core/host/templates/claude/skills/e8-finalize-story/SKILL.md` | CREATE | Mirrored skill for `/e8-finalize-story` (same canonical body, host wiring + frontmatter description). |
| 3 | `shamt-core/host/templates/claude/commands/p5-finalize-epic.md` | CREATE | New PO terminal command: finalize an epic — guard that every child feature/story is finalized, scoped commit, mark the epic done via the tracker, and move `epics/{slug}/ → epics/archive/{slug}/` (move-epic-only on the flat layout). |
| 4 | `shamt-core/host/templates/claude/skills/p5-finalize-epic/SKILL.md` | CREATE | Mirrored skill for `/p5-finalize-epic`. |
| 5 | `shamt-core/templates/SHAMT_RULES.template.md` | EDIT | Add the **Finalize** phase to the Engineer-flow Quick + Standard phase maps and a PO-flow finalize/epic-archive note; update the "six-phase story workflow; seven phases when automated testing is enabled" count claim to account for the new terminal phase; document the `epics/archive/` convention. |
| 6 | `shamt-core/README.md` | EDIT | Add `/e8-finalize-story` and `/p5-finalize-epic` rows to the Engineer + PO command tables; document the `epics/archive/` folder in the §Hierarchy + folder layout section; **and update the Phase-detection table** (the `(7 phases)` / `(6 phases)` column headers → `(8)` / `(7)`, plus a Finalize row keyed on the `**Status: Done**` `ticket.md` marker). |
| 7 | `shamt-core/host/templates/claude/statusline.sh` | EDIT | Three coordinated edits: (a) exclude the `epics/archive/` subdirectory from active-epic resolution so an archived epic is not surfaced as the active `EPIC {slug}`; (b) update the Engineer-flow **phase-numbering scheme comment** (lines ~37–44: "testing enabled = 7 phases, disabled = 6 phases" → 8 / 7, adding `Finalize` to both enumerations and the default-scheme note); (c) add a **Finalize-phase render branch** to the story phase-detection logic (lines ~120–140) so a finalized story shows `P{N} Finalize` rather than remaining on Polish — keyed on the local `**Status: Done**` marker `/e8-finalize-story` writes into `ticket.md` (the profile-independent finalize signal, see Q3/Q5). |
| 8 | `shamt-core/reference/model_selection.md` | EDIT | Add the Engineer-flow Finalize phase (and the PO finalize) to the per-phase model-tier table — Cheap, mechanical commit + status update, mirroring the `/f6-archive-proposal` row. |
| 9 | `shamt-core/reference/audit_dimensions.md` | EDIT | Update the D10 phase-count claim (line ~117: "6 phases when `testing: "disabled"`, 7 when `"enabled"`") to the new "7 / 8" counts so the audit guidance stays factually correct. |
| 10 | `shamt-core/host/templates/claude/commands/f5-audit-framework.md` | EDIT | Update the D10 check description (line ~141: "phase numbers (6 / 7 phases per the testing flag)") to "7 / 8 phases" so the audit checks against the new count. |

10 file operations (≤ 10) — Phase 3 (`/f2-plan-update-implementation`) is **not** required (at the threshold; a single added row would tip it over).

---

## Risks

- **Regression risk** — a terminal phase that auto-commits could sweep unrelated
  working-tree changes into the commit or close a tracker item prematurely. The
  three guards (prior phases complete, scoped clean-tree commit with halt-and-ask
  on unrelated changes, explicit confirmation) are load-bearing and must be
  specified in both command bodies.
- **Drift risk** — each new command has a mirrored `SKILL.md`; forgetting the
  pair leaves canonical/`.claude/` out of sync. Both pairs are listed above.
  Regen (Phase 5) propagates to `.claude/`.
- **Count-claim drift (the dominant completeness hazard)** — the Engineer-flow
  phase count is hardcoded in **five** canonical sites, all of which Finalize
  makes stale: the rules ("six-phase…seven phases", row 5), `statusline.sh`'s
  numbering-scheme comment + rendering (row 7), the README Phase-detection table
  (`(7 phases)`/`(6 phases)`, row 6), `reference/audit_dimensions.md`'s D10 note
  (row 9), and `f5-audit-framework.md`'s D10 check description (row 10). Missing
  any one is a D10/D2 audit finding. All five are captured (rows 5, 6, 7, 9, 10).
- **Status-line regression** — moving an epic into `epics/archive/` would, without
  the row-7 guard, make `archive` resolve as the active epic. The exclusion must
  land with the archive command.
- **Child-project compatibility** — new commands + the `epics/archive/`
  convention are picked up on the next `import-shamt`; no manual reconciliation.
  Existing child epics already in `epics/` are untouched (the archive move acts
  only on an explicit `/p5-finalize-epic`).
- **Forward-compatibility with the layout rework** — `/p5-finalize-epic`'s archive
  step is intentionally the flat "move-epic-only" form. When
  `po-nested-folder-layout` lands, that step is revisited to cascade the whole
  subtree. The dependency is one-directional (layout does not depend on #13).
- **Open-questions debt** — none; all design questions (and the scope-fork
  decision) are resolved below.

---

## Rollback Plan

1. `git revert <commit-sha>` on the canonical edit commit (the new command/skill
   files are additive; the rules/README/statusline/model edits revert cleanly).
2. Run `/f4-regen-framework` to propagate the revert into `.claude/`.
3. Child-side: re-run `/sync-import-shamt` on each installed child. Any epic a
   child already moved into `epics/archive/` stays archived — the revert removes
   the *command*, not already-archived data; a child wanting it back moves the
   folder manually.
4. Communication: note the finalize stage was reverted in the changelog.

---

## Validation Considerations

- **Problem clarity** — "finalize" must read as one lightweight terminal command
  per flow mirroring `/f6-archive-proposal`, **not** a heavyweight stage-gate.
  Watch for collision with the existing Polish-phase "commits" artifact — the
  finalize commit is the explicit, guarded, scoped commit Polish leaves implicit.
- **Change-list completeness** — each new command needs its mirrored
  `SKILL.md` (rows 2, 4). The rules phase map (row 5), README command tables +
  layout doc (row 6), status-line archive exclusion (row 7), and the
  model-selection table (row 8) all move together. The phase-count claim is the
  easy-to-forget paired edit — it appears in **five** sites that must stay in
  lock-step (rows 5, 6, 7, 9, 10: rules, README phase-detection table,
  statusline, `audit_dimensions.md`, `f5-audit-framework.md`); the validator
  should re-grep `6 phase|7 phase|six-phase|seven-phase|(6 phases)|(7 phases)`
  across `templates/`, `reference/`, `host/templates/claude/`, and `README.md`
  to confirm none is missed. (The `f5-audit-framework` **skill** is deliberately
  **not** listed: its D10 line says "phase numbers" generically with no `6/7`
  count, so Finalize does not make it stale — only the command body carries the
  numeric form, row 10.) Confirm `active_artifacts.template.md` carries
  **no** per-phase list (it does not — verified during drafting) so no row is
  owed there.
- **Risk coverage** — premature commit/close; unrelated working-tree changes
  swept into the commit; archived epic surfacing as active in the status line.
- **Rollback feasibility** — additive commands revert cleanly; the epic-archive
  *move* is a data relocation a revert does not undo (called out in Rollback).
- **Affected surfaces** — commands (new finalize pair + the `f5-audit-framework`
  D10 description), skills, rules, README, reference (`model_selection` +
  `audit_dimensions`), and the status-line script. No template-artifact changes
  (finalize writes status into existing `epic.md` / `ticket.md`, not a new
  artifact).
- **Tracker semantics** — "mark finished" reuses the same profile plumbing
  `/e1-start-story` and the `p*` commands already use: ADO sets State, GitHub
  closes the issue, local flips a Status line. The remote close is outward-facing
  → gated behind explicit confirmation (verify both command bodies enforce this).
- **Cross-proposal sequencing** — #13 must not assume the nested layout. Confirm
  `/p5-finalize-epic`'s archive step is the flat move-epic-only form and that the
  Problem's scope note correctly defers the cascade to `po-nested-folder-layout`.
- **Propagation plan** — requires regen + child import; no manual child nudge
  beyond the next `import-shamt`.

---

## Open Questions

_(none — all resolved below)_

---

## Resolved Questions

<!-- Append as questions resolve. -->

- ~~Q1: New command per flow, or extend the existing terminal phases?~~ → A: **New commands per flow**, each mirroring `/f6-archive-proposal` as a distinct, slug-resumable terminal phase (`/e8-finalize-story`, `/p5-finalize-epic`). Keeps the one-command-per-phase principle clean; accepted the larger change set (each new command = body + mirrored `SKILL.md`).
- ~~Q2: Which PO altitudes get a finalize command?~~ → A: **Epic only** (`/p5-finalize-epic`). Matches the f0 capture's emphasis (mark epic done + archive). Stories finalize via `/e8-finalize-story`; features close implicitly when their stories are done — no per-feature finalize command. Total new commands: **two**.
- ~~Q3: What does "mark finished" do per tracker?~~ → A: **Mutate the tracker** via the active profile — ADO sets State = Done/Closed, GitHub closes the issue (`gh issue close`), local flips **Status: Done** in the artifact (`epic.md` / `ticket.md`). Reuses the `/e1-start-story` + `p*` profile plumbing. The remote close is outward-facing, so it is **gated behind explicit user confirmation**. **In all profiles**, finalize also writes the local `**Status: Done**` marker into the artifact (it *is* the local profile's mark-done; under ADO/GitHub it is written in addition to the remote close) — this gives the status line a profile-independent, no-network finalize signal to key its Finalize render branch on (rows 6, 7).
- ~~Q5: Commit scope + guards for finalize?~~ → A: **Finalize commits** (not close-only), gated by three guards: **(1) prior phases complete** — `/e8-finalize-story` refuses unless Review ran and feedback is resolved (and Test passes when testing is enabled); `/p5-finalize-epic` refuses unless every child feature/story is finalized; **(2) scoped clean-tree commit** — commits only the work's own files, halting and asking on unrelated working-tree changes (mirrors `/e6-review-changes`'s `git status --short` guard); **(3) explicit user confirmation** — shows exactly what it will commit and which tracker item it will close, and waits for a yes. For `/p5-finalize-epic` the commit covers the status flip + the `epics/{slug}/ → epics/archive/{slug}/` move.
- ~~Q4: Epic archive location + cascade?~~ → A: **`epics/archive/{slug}/`, move-epic-only on the flat layout.** Mirrors `proposals/archive/`. The epic's child features/stories stay in their sibling top-level dirs; their back-ref headers keep resolving to the (now archived) epic. The whole-subtree cascade is deferred to the sibling `po-nested-folder-layout` proposal, which is where nesting makes the move a single folder operation.
- ~~Scope fork: fold the flat→nested layout rework into #13, or split?~~ → A: **Split.** The fold would reach ~50+ canonical files (the layout rework's 46 and the finalize stage's 10, overlapping on a few shared files like the rules / README / statusline — essentially the entire Engineer + PO surface, since `stories/{slug}/`-style paths are hardcoded throughout) — larger than any prior proposal. The layout rework (now validated as **proposal #14**, 46 files) was spun into a separate `po-nested-folder-layout` proposal with its own Phase 3 plan; #13 keeps the finalize stage (10 files) and ships on the current flat layout. Sequencing: layout proposal lands, then #13's archive cascade is revisited.

---
Validated 2026-06-10 — 8 rounds, 1 adversarial sub-agent confirmed
