# Proposal: po-nested-folder-layout

**Created:** 2026-06-10
**Status:** Draft
**Number:** 14
**Proposed by:** [master-local]
**Project context:** [master-local]

---

## Problem

The Product Owner hierarchy was *intended* to nest — features as subfolders of
the epic they belong to, stories as subfolders of their feature — but what
shipped is a **flat** layout. `README.md` §Hierarchy + folder layout (lines
~110–126) documents three sibling top-level directories, `epics/`, `features/`,
`stories/`, each with globally-unique slugs, with parent/child relationships
carried only by plain-markdown back-ref header lines (`**Parent Epic:** {slug}`,
`**Parent Feature:** {slug}`) read by `host/templates/claude/statusline.sh` and
written by `/p2-decompose-epic` / `/p4-decompose-feature`.

The flat layout has two costs. First, a delivered initiative is scattered across
three sibling trees rather than living in one self-contained folder — so
"archive a done epic" (proposal #13's `/p5-finalize-epic`) cannot be a single
folder move; it is a move-epic-only operation that strands the epic's features
and stories in their top-level dirs. Second, parentage lives in a redundant
header line that must be kept in sync by hand and walked by a reader, rather than
being encoded by the path itself.

This proposal reworks the PO layout to the intended nesting:

```
epics/{ID}-{epic-slug}-{brief}/
  epic.md
  features/{ID}-{feature-slug}-{brief}/
    feature.md
    stories/{ID}-{story-slug}-{brief}/
      ticket.md, spec.md, implementation_plan.md, feedback/, raw/, ...
```

Under nesting, the folder path is the single source of truth for parentage (the
back-ref headers are dropped), a done epic becomes one movable subtree (the #13
archive cascade resolves naturally), and the work is self-contained per
initiative. Because `stories/{slug}/`-style paths are hardcoded across nearly the
entire Engineer + PO canonical surface, the change is large (~46 canonical files)
and **Phase 3 (`/f2-plan-update-implementation`) is required.**

**Cross-proposal dependency.** Strict nesting removes the top-level `features/`
and `stories/` orphan home. Parentless work (bugs, quick wins, one-off tech
stories) must land somewhere — that home is the standing **Tech Stories** epic
from the sibling `tech-stories-epic` proposal. `tech-stories-epic` must therefore
land alongside or before this proposal's nested layout.

---

## Proposed Changes

> Row count is **46 canonical file operations (> 10)** → **Phase 3 required.**
> Run `/f2-plan-update-implementation po-nested-folder-layout` after validation;
> the implementation will need phase-file splitting. All design questions are
> resolved (see Resolved Questions): row 1 already includes the shared
> **§PO-tree resolution** section, and row 3 captures the root-level
> active-pointer model.

**Group A — rules, top-level docs, status line (4)**

| # | Canonical path | Operation | One-line change description |
|---|----------------|-----------|------------------------------|
| 1 | `shamt-core/templates/SHAMT_RULES.template.md` | EDIT | Replace the flat-layout description with the nested layout; add a named **§PO-tree resolution** section (tree-wide glob + both-shapes legacy fallback + global slug uniqueness) that the commands reference; remove the back-ref-header convention; reconcile the "standalone stories run the Engineer flow directly" statement; update any path literals. |
| 2 | `shamt-core/README.md` | EDIT | Rewrite §Hierarchy + folder layout (nested tree), the §Back-ref headers and the story handoff section (removed), and the §Status-line PO modes section (active resolution via root-level pointer files; parentage derived from the pointer path). |
| 3 | `shamt-core/host/templates/claude/statusline.sh` | EDIT | Read the active story/feature/epic from root-level pointer files (replacing the `{parent}/.active` + most-recently-modified scan); derive `feat:`/`epic:` segments from the pointer path instead of back-ref headers. (The commands in Groups B–C write/refresh those pointers.) |
| 4 | `shamt-core/reference/review_categories.md` | EDIT | Update the `stories/{slug}/feedback/review_v1.md` path literal to the nested/path-relative form. |

**Group B — PO commands + skills (8)**

| # | Canonical path | Operation | One-line change description |
|---|----------------|-----------|------------------------------|
| 5 | `shamt-core/host/templates/claude/commands/p1-start-epic.md` | EDIT | Epic folder stays top-level `epics/{slug}/`; update resolution wording + drop any back-ref/flat-layout references. |
| 6 | `shamt-core/host/templates/claude/skills/p1-start-epic/SKILL.md` | EDIT | Mirror the p1 command edits. |
| 7 | `shamt-core/host/templates/claude/commands/p2-decompose-epic.md` | EDIT | Write feature stubs nested under `epics/{epic}/features/`; stop writing `**Parent Epic:**` back-ref headers (path encodes it). |
| 8 | `shamt-core/host/templates/claude/skills/p2-decompose-epic/SKILL.md` | EDIT | Mirror the p2 command edits. |
| 9 | `shamt-core/host/templates/claude/commands/p3-start-feature.md` | EDIT | Resolve/write the feature folder nested under its epic; remove standalone top-level `features/` writes (orphans → Tech Stories); drop back-ref header writes. |
| 10 | `shamt-core/host/templates/claude/skills/p3-start-feature/SKILL.md` | EDIT | Mirror the p3 command edits. |
| 11 | `shamt-core/host/templates/claude/commands/p4-decompose-feature.md` | EDIT | Write story stubs nested under `epics/{epic}/features/{feature}/stories/`; drop `**Parent Feature:** / **Parent Epic:**` back-ref writes. |
| 12 | `shamt-core/host/templates/claude/skills/p4-decompose-feature/SKILL.md` | EDIT | Mirror the p4 command edits. |

**Group C — Engineer commands + skills (18)**

| # | Canonical path | Operation | One-line change description |
|---|----------------|-----------|------------------------------|
| 13 | `shamt-core/host/templates/claude/commands/e1-start-story.md` | EDIT | Resolve the story folder by tree-wide glob (nested + legacy flat); derive parentage from the path instead of preserving back-ref headers; update artifact path literals. |
| 14 | `shamt-core/host/templates/claude/skills/e1-start-story/SKILL.md` | EDIT | Mirror the e1 command edits. |
| 15 | `shamt-core/host/templates/claude/commands/e2-define-spec.md` | EDIT | Tree-wide story-folder resolution; update `stories/{slug}/…` artifact path literals. |
| 16 | `shamt-core/host/templates/claude/skills/e2-define-spec/SKILL.md` | EDIT | Mirror the e2 command edits. |
| 17 | `shamt-core/host/templates/claude/commands/e3-plan-implementation.md` | EDIT | Tree-wide story-folder resolution; update artifact path literals. |
| 18 | `shamt-core/host/templates/claude/skills/e3-plan-implementation/SKILL.md` | EDIT | Mirror the e3 command edits. |
| 19 | `shamt-core/host/templates/claude/commands/e3b-write-testing-plan.md` | EDIT | Tree-wide story-folder resolution; update artifact path literals. |
| 20 | `shamt-core/host/templates/claude/skills/e3b-write-testing-plan/SKILL.md` | EDIT | Mirror the e3b command edits. |
| 21 | `shamt-core/host/templates/claude/commands/e4-execute-plan.md` | EDIT | Tree-wide story-folder resolution; update artifact path literals. |
| 22 | `shamt-core/host/templates/claude/skills/e4-execute-plan/SKILL.md` | EDIT | Mirror the e4 command edits. |
| 23 | `shamt-core/host/templates/claude/commands/e5-execute-tests.md` | EDIT | Tree-wide story-folder resolution; update artifact path literals. |
| 24 | `shamt-core/host/templates/claude/skills/e5-execute-tests/SKILL.md` | EDIT | Mirror the e5 command edits. |
| 25 | `shamt-core/host/templates/claude/commands/e5b-write-manual-testing-plan.md` | EDIT | Tree-wide story-folder resolution; update artifact path literals. |
| 26 | `shamt-core/host/templates/claude/skills/e5b-write-manual-testing-plan/SKILL.md` | EDIT | Mirror the e5b command edits. |
| 27 | `shamt-core/host/templates/claude/commands/e6-review-changes.md` | EDIT | Tree-wide story-folder resolution; update `stories/{slug}/feedback/…` path literals. |
| 28 | `shamt-core/host/templates/claude/skills/e6-review-changes/SKILL.md` | EDIT | Mirror the e6 command edits. |
| 29 | `shamt-core/host/templates/claude/commands/e7-resolve-feedback.md` | EDIT | Tree-wide story-folder resolution; update artifact path literals. |
| 30 | `shamt-core/host/templates/claude/skills/e7-resolve-feedback/SKILL.md` | EDIT | Mirror the e7 command edits. |

**Group D — artifact templates (8)**

| # | Canonical path | Operation | One-line change description |
|---|----------------|-----------|------------------------------|
| 31 | `shamt-core/templates/spec.template.md` | EDIT | Update `**Story:** stories/{slug}/` + related path literals to the nested/path-relative form. |
| 32 | `shamt-core/templates/context.template.md` | EDIT | Update story/spec path literals to nested form. |
| 33 | `shamt-core/templates/implementation_plan.template.md` | EDIT | Update story/spec/context path literals to nested form. |
| 34 | `shamt-core/templates/testing_plan.template.md` | EDIT | Update story/spec/plan path literals to nested form. |
| 35 | `shamt-core/templates/manual_test_plan.template.md` | EDIT | Update story/spec/plan path literals to nested form. |
| 36 | `shamt-core/templates/code_review.template.md` | EDIT | Update story-mode `stories/{slug}/feedback/…` path literals to nested form. |
| 37 | `shamt-core/templates/active_artifacts.template.md` | EDIT | Update the active-artifacts pointer path literals (`stories/{slug}/…`) to nested form. |
| 38 | `shamt-core/templates/feature.template.md` | EDIT | Update the "Lives at `features/{slug}/feature.md`" header to the nested `epics/{epic}/features/{slug}/feature.md`; drop the `**Parent Epic:**` back-ref header line. |

**Group E — ticket templates (2)**

| # | Canonical path | Operation | One-line change description |
|---|----------------|-----------|------------------------------|
| 39 | `shamt-core/templates/ticket.ado.template.md` | EDIT | Drop the `**Parent Feature:** / **Parent Epic:**` back-ref header lines (path encodes parentage). |
| 40 | `shamt-core/templates/ticket.github.template.md` | EDIT | Drop the `**Parent Feature:** / **Parent Epic:**` back-ref header lines. |

**Group F — tracker reference profiles (4)**

| # | Canonical path | Operation | One-line change description |
|---|----------------|-----------|------------------------------|
| 41 | `shamt-core/reference/trackers/local.md` | EDIT | Rewrite the flat-layout resolution table (`stories/{slug}-*/`, `features/{slug}-*/`, `epics/{slug}-*/`) to nested tree-wide glob resolution. |
| 42 | `shamt-core/reference/trackers/ado.md` | EDIT | Update the `raw/issue.json` write paths + flat-layout notes for nested PO folders. |
| 43 | `shamt-core/reference/trackers/github.md` | EDIT | Update the `stories/{slug}-*/raw/issue.json` path literal + flat-layout notes. |
| 44 | `shamt-core/reference/implementation_plan_reference.md` | EDIT | Update the `stories/{slug}/implementation_plan.md` path literal to nested form. |

**Group G — execution personas (2)**

| # | Canonical path | Operation | One-line change description |
|---|----------------|-----------|------------------------------|
| 45 | `shamt-core/host/templates/claude/agents/plan-executor.md` | EDIT | The builder persona resolves the **story-altitude** folder by globbing `stories/{slug}/` from the project root (Step 1) — repoint it at the §PO-tree resolution convention (tree-wide glob); update story-altitude path literals. The framework-altitude (`proposals/`) path is unaffected. |
| 46 | `shamt-core/host/templates/claude/agents/test-executor.md` | EDIT | The test persona resolves the story folder "via the global rules" (`stories/{slug}-*/` glob) — repoint at §PO-tree resolution; update `stories/{slug}/testing_plan.md` / `active_artifacts.md` path literals. |

**Path discipline note.** The inclusion criterion is: a file changes iff it
**resolves a folder from the project root** or **documents the top-level
location** of one. Two canonical files that match the broad path-grep are
intentionally **excluded** because neither resolves from root:

- `templates/epic.template.md` — epics remain top-level, so its "Lives at
  `epics/{slug}/epic.md`" header stays correct and its Target Features section
  references features by (still-global) slug.
- `host/templates/claude/commands/validate-artifact.md` — layout-agnostic (it
  validates whatever absolute path it is given); its `stories/42-add-export/…`
  literals are illustrative examples, and `stories/{slug}/` remains the *tail* of
  the nested path, so they do not mislead about resolution.

No generated `.claude/` paths appear.

---

## Risks

- **Regression risk** — the entire Engineer + PO flow depends on story-folder
  resolution. A resolution bug strands every command. The tree-wide glob must be
  specified once and applied identically; Phase 3 must verify each command.
- **Drift risk** — every command edit has a mirrored `SKILL.md`; with 13
  command/skill pairs the pairing is the dominant drift hazard. Each pair is
  listed explicitly above.
- **Cross-proposal dependency** — `tech-stories-epic` must land alongside/before
  this, or parentless work has no home once the top-level orphan dirs stop being
  written. Sequencing is load-bearing.
- **Backward-compatibility** — installed children have flat data. Resolvers must
  glob **both** shapes (nested + legacy flat) so existing work keeps resolving;
  the framework stops *writing* flat but never deletes existing flat folders. A
  resolver that only globs the nested tree silently loses pre-existing work.
- **Status-line breakage** — the `.active` override + most-recently-modified
  resolution assumes a flat parent dir per altitude. Under nesting there is no
  top-level `stories/` / `features/` to scan, so the resolution model is reworked
  to root-level active-pointer files (row 3). If row 3 is missed, the status line
  goes blank/wrong.
- **#13 coupling** — proposal #13's `/p5-finalize-epic` archives move-epic-only;
  once this lands, its archive step should cascade the whole subtree. This
  proposal does not edit #13's command (it is additive to the layout); the
  cascade revisit is tracked as a follow-up, not folded here.
- **Open-questions debt** — none; all design questions (resolver phrasing,
  active-resolution model, standalone-statement reconciliation) are resolved in
  Resolved Questions below and reflected in the change list.

---

## Rollback Plan

1. `git revert <commit-sha>` on the canonical edit commit (the change is large
   but edit-only — no destructive deletes; new work simply reverts to writing the
   flat layout).
2. Run `/f4-regen-framework` to propagate the revert into `.claude/`.
3. Child-side: re-run `/sync-import-shamt` on each installed child. Any work a
   child already created in the nested layout stays nested on disk; after the
   revert, commands resolve it via the both-shapes glob if that path is retained,
   otherwise the child relocates those folders manually.
4. Communication: note the layout revert + any nested folders needing manual
   relocation in the changelog.

---

## Validation Considerations

- **Problem clarity** — "nested" must be read as a physical folder move for
  features/stories, with epics staying top-level. Watch for the assumption that
  epics also move (they do not).
- **Change-list completeness** — 13 command/skill pairs must each be paired;
  every artifact template and tracker reference that hardcodes a `stories/{slug}/`
  literal must appear; and the two **execution personas** (`plan-executor`,
  `test-executor`, rows 45–46) that resolve the story folder from root must not
  be forgotten (they were the easy omission). The validator should diff the
  change list against a fresh grep of `stories/{slug}` / `features/{slug}` /
  `Parent (Epic|Feature)` / `resolve_active` across `templates/`, `reference/`,
  and `host/templates/claude/` (including `agents/`) and flag any omission.
  Confirm the `epic.template.md` and `validate-artifact.md` exclusions (both
  layout-agnostic) are correct.
- **Risk coverage** — backward-compat (both-shapes resolver), the
  `tech-stories-epic` dependency, and the status-line active-pointer rework
  (row 3) are the scenarios most likely to be under-covered.
- **Rollback feasibility** — edit-only, no destructive deletes; revert is clean
  except for nested folders a child already created (called out in Rollback).
- **Affected surfaces** — rules, README, all Engineer + PO commands + skills, the
  `plan-executor` / `test-executor` execution personas, artifact templates,
  ticket templates, tracker references, and the status-line script. This is
  essentially the whole story/PO surface; cross-doc consistency (D2/D3/D7) is the
  dominant validation axis.
- **Propagation plan** — requires regen + child import. No automatic data
  migration (new layout for new work only); the both-shapes resolver is what
  keeps existing child data working.

---

## Open Questions

_(none — all resolved below)_

---

## Resolved Questions

<!-- Carried over from the #13 split dialog (decisions, not re-litigated). -->

- ~~Where do standalone (parentless) features/stories live under nesting?~~ → A: **No true orphans** — every story nests under a feature, every feature under an epic. One-off/parentless work lands under the ever-present **Tech Stories** epic (`tech-stories-epic` proposal). Top-level `features/` / `stories/` are no longer *written*.
- ~~Keep or drop the back-ref header lines under nesting?~~ → A: **Drop them.** The path is the single source of truth; consumers (status line) derive parentage by walking the path.
- ~~Global slug uniqueness vs unique-within-parent?~~ → A: **Keep global uniqueness.** Slug-first commands resolve by a tree-wide glob matching exactly one folder; collision checks widen to the tree.
- ~~How to handle existing flat-layout child data?~~ → A: **New layout for new work only — no migration.** Resolvers glob **both** shapes (nested + legacy flat); existing flat folders stay and remain resolvable; the framework stops writing flat.
- ~~Resolver phrasing: shared convention vs inline per command?~~ → A: **Shared convention.** Document the tree-wide-glob resolution + both-shapes legacy fallback once as a named **§PO-tree resolution** section in `SHAMT_RULES.template.md` (row 1 grows to add it); each Engineer/PO command references it instead of repeating the logic. Single source of truth, shorter per-command edits, no ~13× duplication.
- ~~Active-resolution model under nesting?~~ → A: **Root-level pointer files.** Each altitude has a pointer (e.g. `active-story` / `active-feature` / `active-epic`) holding the full nested path; the status line reads one file per altitude (cheap, deterministic). The commands write/refresh the pointer as work advances (folded into the existing command edit rows). Pointers live in the **project work tree** (not under `.shamt-core/`, so `/sync-import-shamt` does not clobber them). Replaces the per-altitude `{parent}/.active` + most-recently-modified scan, which has no flat parent to scan under nesting.
- ~~Rules "standalone stories run the Engineer flow directly" statement — reword here or defer?~~ → A: **Reword in this proposal** (row 1). The rules edit updates the statement so standalone/one-off work is described as living under the standing **Tech Stories** epic (cross-referencing `tech-stories-epic`) rather than as a top-level home, keeping the rules internally consistent the moment nesting lands instead of leaving a transient window where the rules describe a removed top-level home.

---
Validated 2026-06-10 — 3 rounds, 1 adversarial sub-agent confirmed
