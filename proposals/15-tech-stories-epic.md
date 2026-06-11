# Proposal: tech-stories-epic

**Created:** 2026-06-08
**Status:** Draft
**Number:** 15
**Proposed by:** [master-local]
**Project context:** [master-local]

---

## Problem

Shamt's Product Owner flow is built for **top-down decomposition**: an epic
(`/p1-start-epic`) is broken into features (`/p2-decompose-epic`,
`/p3-start-feature`), which are broken into stories (`/p4-decompose-feature`),
which hand off to the Engineer flow (`/e1-start-story`). That cascade is the
right shape for an initiative large enough to warrant it. But there is **no
fast path** for the steady stream of work that does *not* belong to any real
epic — one-off bug fixes and small, standalone technical improvements. Today
such work either gets forced through the full epic→feature→story drill-down
(ceremony far exceeding its size) or runs as a freeform standalone story.

Proposal #14 (`po-nested-folder-layout`) sharpens this into a hard requirement.
Under the nested layout, there are **no top-level orphans**: every story must
nest under a feature, every feature under an epic. #14's resolved design
explicitly routes all parentless/one-off work to *"the ever-present **Tech
Stories** epic"* — but that epic does not yet exist. This proposal defines it.

This proposal establishes a standing **Tech Stories** epic that is a permanent
fixture of the PO flow (not created per-initiative by `/p1-start-epic`),
containing two standing features — **Bugs** and **Quick Wins**. A new fast-path
command, `/p6-draft-tech-story`, creates a ticket directly under the chosen
feature, bypassing the decomposition cascade and handing straight to the
Engineer flow. When a tech-story ticket is completed it is moved into an archive
folder within its feature, keeping the standing features from growing without
bound (mirroring how `/f6-archive-proposal` retires implemented proposals).

> **Sibling proposals.** This is one of a coordinated set: #13
> (`po-engineer-finalize-archive-stage`, the finalize/commit/close + epic-archive
> stage) and #14 (`po-nested-folder-layout`, flat→nested). #14 depends on this
> proposal for the orphan home, so the two must land together; the completion-
> archive mechanism here must align with #13's finalize stage rather than
> duplicate it.

---

## Proposed Changes

All design questions are resolved (see Resolved Questions). **8 file operations
(≤ 10) — Phase 3 (`/f2-plan-update-implementation`) is not required.**

| # | Canonical path | Operation | One-line change description |
|---|----------------|-----------|------------------------------|
| 1 | `shamt-core/templates/SHAMT_RULES.template.md` | EDIT | Describe the standing **Tech Stories** epic + **Bugs** / **Quick Wins** features normatively in the PO-flow section: local-only organizational containers (no tracker mapping) that use **fixed reserved folder names** (`tech-stories`, `bugs`, `quick-wins` — *not* the `{ID}-{slug}-{brief}` convention, since they carry no ticket ID), the `/p6-draft-tech-story` fast path that bypasses the decompose cascade, and the per-feature completion-archive convention (`epics/tech-stories/features/{f}/archive/`). |
| 2 | `shamt-core/README.md` | EDIT | Document the standing Tech Stories epic, the `/p6-draft-tech-story` fast path, and the per-feature archive in the PO-flow command table + §Hierarchy + folder layout section. |
| 3 | `shamt-core/host/templates/claude/commands/p6-draft-tech-story.md` | CREATE | New fast-path PO command: pick Bugs vs Quick Wins, seed a ticket stub under `epics/tech-stories/features/{f}/stories/{slug}/`, then hand to `/e1-start-story` (stub-aware). |
| 4 | `shamt-core/host/templates/claude/skills/p6-draft-tech-story/SKILL.md` | CREATE | Mirrored skill for `/p6-draft-tech-story`. |
| 5 | `shamt-core/host/templates/claude/commands/e8-finalize-story.md` | EDIT | **Extends the #13-created command** (hard predecessor): when finalizing a ticket under the Tech Stories epic, also move it into `epics/tech-stories/features/{f}/archive/{slug}/` within the same commit, reusing #13's commit + mark-done + guards. |
| 6 | `shamt-core/host/templates/claude/skills/e8-finalize-story/SKILL.md` | EDIT | Mirror the e8 command edit (also #13-created). |
| 7 | `shamt-core/init-shamt.sh` | EDIT | On first install, seed the standing epic at the child **project work tree** in the **nested** (#14) layout — `epics/tech-stories/epic.md` + `epics/tech-stories/features/bugs/feature.md` + `epics/tech-stories/features/quick-wins/feature.md` (fixed content) if absent. This is a **new kind of init step** (init currently sets up `.shamt-core/` + CLAUDE.md + `.claude/` but no work-tree dirs) and is **skipped on self-host** (the shamt-core repo itself does no PO work), matching the existing self-host skips. |
| 8 | `shamt-core/import-shamt.sh` | EDIT | On master→child sync, idempotently re-seed the standing epic + features for existing children (create-if-absent; never overwrite an existing one). |

**Path discipline notes.**
- Rows 5–6 (`e8-finalize-story`) target files **created by proposal #13**
  (`po-engineer-finalize-archive-stage`), a hard predecessor — they do not exist
  on disk until #13 lands. The established order is **#13 → (#14 + #15
  together)**, so e8 exists by the time #15 is implemented; their absence now is
  expected (justified in Validation Considerations).
- `init-shamt.sh` / `import-shamt.sh` are root-level canonical install/sync
  scripts (copied into every child's `.shamt-core/`); editing them is justified
  here per the "outside the standard list, justified in Validation
  Considerations" allowance.
- No `/p1-start-epic` / `/p3-start-feature` collision-check edits are needed: the
  seeded `tech-stories` / `bugs` / `quick-wins` folders make those slugs *taken*,
  so the existing global-uniqueness collision checks refuse any reuse
  automatically. No `.claude/` paths appear.

---

## Risks

- **Reserved-slug collision** — the seeded `tech-stories` / `bugs` / `quick-wins`
  slugs are reserved. Because they are seeded as real folders, the existing
  global-uniqueness collision checks already refuse any user attempt to reuse
  them (the folder exists → collision → refuse), so no new check is needed; the
  risk is only that a child created such a slug *before* seeding — `import-shamt`
  must create-if-absent and report rather than overwrite.
- **Drift risk** — `/p6-draft-tech-story` has a mirrored `SKILL.md` (rows 3–4),
  and the e8 edit has its mirror (rows 5–6); the rules ↔ README ↔ command
  descriptions must stay consistent.
- **Cross-proposal coupling + ordering** — load-bearing. This proposal (a) reuses
  #13's `/e8-finalize-story` (edits rows 5–6, so **#13 must land first**), (b) is
  #14's orphan home and assumes #14's nested layout (so **#14 + #15 land
  together**), and (c) flags that #14's nested-resolution sweep should also cover
  `/e8-finalize-story` if #13 landed first (e8 did not exist at #14 drafting).
  Net order: **#13 → (#14 + #15 together)**.
- **Child-project compatibility** — existing children get the standing epic +
  features seeded on next `import-shamt` (create-if-absent), without disturbing
  their existing `epics/`. A child mid-upgrade with no Tech Stories epic still
  resolves its own work normally.
- **Open-questions debt** — none; the seeding model, archive trigger, tracker
  interaction, layout dependency, and command shape are all resolved below and
  reflected in the change list.

---

## Rollback Plan

1. `git revert <commit-sha>` on the canonical edit commit — reverts all 8 ops
   together (the new `/p6-draft-tech-story` command/skill are additive; the
   rules/README edits, the `/e8-finalize-story` extension, and the
   `init-shamt.sh` / `import-shamt.sh` seed edits all revert cleanly).
2. Run `/f4-regen-framework` to propagate the revert into `.claude/`.
3. Child-side: re-run `/sync-import-shamt`. Any Tech Stories epic/features a child
   already created on disk stay (the revert removes the *command*, not data); a
   child wanting them gone removes the folders manually.
4. Communication: note the fast-path removal in the changelog.

---

## Validation Considerations

- **Problem clarity** — "standing epic" must read as a permanent, reserved PO
  container, distinct from a normal `/p1-start-epic` epic. Watch for collision
  with #14's orphan-routing language.
- **Change-list completeness** — `/p6-draft-tech-story` is paired with its skill
  (rows 3–4) and the e8 edit with its skill (rows 5–6); rules (1), README (2),
  and both seeding scripts (7–8) move together. `/e1-start-story` is deliberately
  **not** listed (its nested resolution from #14 already finds the seeded stub),
  and the tracker references are **not** listed (local-only containers, Q3). The
  validator should confirm these exclusions and that no PO decompose command
  needs touching (the fast path bypasses them by design).
- **`reference/model_selection.md` is deliberately excluded** — its per-phase
  model-tier table covers only the Engineer flow and the Framework-update flow;
  **no PO-flow command (`/p1`–`/p4`) appears there today**. `/p6-draft-tech-story`
  follows that established pattern and carries its own *Recommended model* line in
  its command body (rows 3–4) instead. (If a PO-flow model-tier convention later
  emerges — e.g. via #13's PO-finalize row — `/p6` can be added then.)
- **e8 forward-reference** — rows 5–6 edit `host/templates/claude/commands/e8-finalize-story.md`
  + its skill, which **do not exist on disk yet** (created by predecessor #13).
  This is expected, not an omission: the stated order is #13 → (#14 + #15). A
  path-existence check should treat rows 5–6 as justified forward-references to
  a hard-predecessor's CREATEs, not as broken paths.
- **Risk coverage** — reserved-slug collisions (auto-handled by seeded folders);
  the #13 → (#14+#15) ordering; avoiding a second archive mechanism parallel to
  #13's finalize.
- **Rollback feasibility** — the new command reverts cleanly; the e8 edit reverts
  to #13's baseline; seeded `epics/tech-stories/` folders are data a revert does
  not remove (children delete manually if desired).
- **Affected surfaces** — rules, README, a new PO command + skill, the
  #13-created `/e8-finalize-story` command + skill (extended), and the
  `init-shamt.sh` / `import-shamt.sh` install/sync scripts. Not: `/e1-start-story`,
  PO decompose commands, tracker references, or artifact templates.
- **Self-host + new-behavior nuance** — seeding the standing epic is the first
  init/import step that writes child **project-work-tree** content (epics/…);
  every prior step targets `.shamt-core/` / CLAUDE.md / `.claude/`. The validator
  should confirm the seed is gated to non-self-host targets (the shamt-core repo
  does no PO work) and is idempotent (create-if-absent, never overwrite).
- **Propagation plan** — regen + child import; existing children get a one-time
  create-if-absent seed of the standing epic on next `import-shamt`.

---

## Open Questions

_(none — all resolved below)_

---

## Resolved Questions

- ~~Q4: Assume #14's nested layout, or be layout-agnostic?~~ → A: **Assume nested (#14).** Tech Stories targets `epics/tech-stories/features/{bugs,quick-wins}/stories/{slug}/` and lands as a coordinated sibling of #14 (they land together). One layout to support; no flat-layout back-ref handling. Confirms the hard ordering: #14 lands with/before this, and this is #14's orphan home.
- ~~Q1: Real folder vs special-cased concept?~~ → A: **Real folder, seeded at init.** The nested (#14) tree `epics/tech-stories/` + `epics/tech-stories/features/bugs/` + `epics/tech-stories/features/quick-wins/` (each with a fixed `epic.md` / `feature.md`) is seeded once by the install/sync flow (`init-shamt.sh` on first install; `import-shamt.sh` idempotently re-seeds existing children on update — create-if-absent). Always present post-install; the fast-path command never has to create containers. Adds rows for both scripts + a child re-seed concern.
- ~~Q5: `draft-tech-story` command name + does it stub-then-handoff or full intake?~~ → A: **`/p6-draft-tech-story`, stub-then-handoff.** A PO-flow command (`/p6-`) that picks Bugs vs Quick Wins, seeds a ticket stub under `epics/tech-stories/features/{f}/stories/{slug}/`, then hands to `/e1-start-story` (stub-aware) for intake — reusing the stub-then-drill-in pattern `/p2`/`/p4` already use. New command + mirrored skill. `/e1-start-story` needs **no** change here: its nested-tree resolution (from #14) already finds the stub.
- ~~Q2: Archive trigger — automatic via #13's `/e8-finalize-story`, or explicit command?~~ → A: **Fold into #13's `/e8-finalize-story`.** When `/e8-finalize-story` finalizes a ticket under the Tech Stories epic, it also moves the ticket into `epics/tech-stories/features/{f}/archive/{slug}/` as part of the same commit. Reuses #13's commit + mark-done + guards; no parallel mechanism. This proposal therefore **edits the `/e8-finalize-story` command + skill that #13 creates** — establishing the order **#13 → (#14 + #15 together)**. (Sequencing caveat recorded in Risks: if #13 lands before #14, #14's nested-resolution sweep should also cover `/e8-finalize-story`, which did not exist when #14 was drafted.)
- ~~Q3: Do the standing containers map to tracker work items or stay local-only?~~ → A: **Local-only containers.** The Tech Stories epic + Bugs/Quick Wins features are local organizational folders (fixed `epic.md` / `feature.md`); they never map to ADO/GitHub work items. Individual tech-story tickets filed under them still map to tracker issues per the active profile (a bug = a GitHub issue / ADO bug). Tracker-agnostic — works identically on ADO / GitHub / local; no tracker-reference (`reference/trackers/*`) changes needed.

---
Validated 2026-06-10 — 4 rounds, 1 adversarial sub-agent confirmed
