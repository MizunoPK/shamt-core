# Implementation Plan — Phase 4 (Templates / tickets / trackers / personas): po-nested-folder-layout (#14)

**Index:** [`14-po-nested-folder-layout_PLAN.md`](14-po-nested-folder-layout_PLAN.md) · **Rows:** 31–46 · **Deploy order:** LAST (cites §PO-tree resolution C1, back-ref drop C3).

> Canonical-only; no `.claude/`. Artifact-template path literals are path-relative shorthand (C1) → **annotate** the header block once. The real rewrites: `feature.template` "Lives at" + back-ref drop, ticket templates' back-ref drop, `trackers/local.md` resolution table, and the two execution personas' story-folder globs.

---

## Group D — artifact templates (rows 31–38)

**T-ANNOTATE pattern.** Each template (rows 31–37) has a header metadata block with `**Story:** stories/{slug}/` (and related `stories/{slug}/...` lines). Add **one line** immediately under the `**Story:**` line: `<!-- Paths are relative to the resolved story folder (located per templates/SHAMT_RULES.template.md §PO-tree resolution; the folder nests under epics/.../features/.../). -->`. Leave the existing `stories/{slug}/...` literals intact — they denote the resolved folder.

| Step | Row | File | Action |
|---|---|---|---|
| 31 | 31 | `templates/spec.template.md` | T-ANNOTATE under L4 `**Story:** stories/{slug}/`. (L7 context + L44 mermaid literals left intact.) |
| 32 | 32 | `templates/context.template.md` | T-ANNOTATE under L6 `**Story:** stories/{slug}/`. |
| 33 | 33 | `templates/implementation_plan.template.md` | T-ANNOTATE under L6 `**Story:** stories/{slug}/`. (L25 active-artifacts literal intact.) |
| 34 | 34 | `templates/testing_plan.template.md` | T-ANNOTATE under L6 `**Story:** stories/{slug}/`. |
| 35 | 35 | `templates/manual_test_plan.template.md` | T-ANNOTATE under L6 `**Story:** stories/{slug}/`. |
| 36 | 36 | `templates/code_review.template.md` | T-ANNOTATE under L68 `[Story mode: **Story:** stories/{slug}/]`. (L5/L58 story-mode path literals intact.) |
| 37 | 37 | `templates/active_artifacts.template.md` | T-ANNOTATE above the L15–L20 path table (insert the note as a line before the table). |

For each: **VERIFY** `grep -c "§PO-tree resolution" <file>` ≥ 1.

### Step 38 — `templates/feature.template.md` (row 38) — substantive

- **38a.** L1 `<!-- Feature artifact. Lives at features/{ID}-{slug}-{brief}/feature.md ({ID}- prefix is the ticket ID; globally unique slug). -->` → `<!-- Feature artifact. Lives at epics/{ID}-{epic-slug}-{brief}/features/{ID}-{slug}-{brief}/feature.md — nested under its parent epic (epics are top-level). Globally unique slug; resolved per §PO-tree resolution. -->`.
- **38b (C3).** DELETE L6 `**Parent Epic:** [T{N} ({epic-slug}) — the parent epic's ticket ID + slug; leave blank for standalone … Plain markdown; no parser.]` — the parent epic is the path. (A standalone-ish feature now lives under the Tech Stories epic, so there is no blank-parent case.)
- **VERIFY:** `grep -c "Parent Epic" templates/feature.template.md` = 0; `grep -c "epics/{ID}-{epic-slug}-{brief}/features/" templates/feature.template.md` = 1.

## Group E — ticket templates (rows 39–40)

### Step 39 — `templates/ticket.ado.template.md` (row 39)
- DELETE L4 `**Parent Feature:** {feature-slug}` and L5 `**Parent Epic:** {epic-slug}` (parentage is the path, C3).
- **VERIFY:** `grep -c "Parent Feature\|Parent Epic" templates/ticket.ado.template.md` = 0.

### Step 40 — `templates/ticket.github.template.md` (row 40)
- DELETE L4 `**Parent Feature:** {feature-slug}` and L5 `**Parent Epic:** {epic-slug}`.
- **VERIFY:** `grep -c "Parent Feature\|Parent Epic" templates/ticket.github.template.md` = 0.

## Group F — tracker references (rows 41–44)

### Step 41 — `reference/trackers/local.md` (row 41) — substantive
- **41a.** L23 resolution-table row `| {slug} | stories/{slug}-*/ (the existing folder). If zero or multiple folders match, the command halts with a clear error. |` → `| {slug} | the story folder resolved per §PO-tree resolution (tree-wide glob + legacy-flat fallback). If zero or multiple folders match, the command halts with a clear error. |`.
- **41b.** Replace the **entire L27 sentence** (`For the PO-flow commands (/p1-start-epic / /p3-start-feature), folder layout follows the flat folder layout: epics/{slug}-*/epic.md, features/{slug}-*/feature.md (flat layout, globally unique slugs; the folder name is {slug}-{brief} and is matched by glob the same way stories are). Same rule: the file must already exist or be created by the PO-flow command itself.`) with **this exact text:**
  > `For the PO-flow commands (`/p1-start-epic` / `/p3-start-feature`), folders resolve per `templates/SHAMT_RULES.template.md` §PO-tree resolution: epics are top-level (`epics/{slug}-*/epic.md`), features nest under their epic (`epics/*/features/{slug}-*/feature.md`), with the legacy-flat fallback. Globally unique slugs; the folder name is `{slug}-{brief}`. Same rule as stories: the file must already exist or be created by the PO-flow command itself.`
- **41c.** L33 (`/e1-start-story {slug} reads stories/{slug}-*/ticket.md directly …`) → append, immediately after the `stories/{slug}-*/ticket.md` path, the parenthetical ` (resolved per §PO-tree resolution)`. L71 (`each reading the corresponding local file (stories/{slug}-*/ticket.md, features/{slug}-*/feature.md, epics/{slug}-*/epic.md)`) → change the **feature** entry to nested `epics/*/features/{slug}-*/feature.md` and append ` (resolved per §PO-tree resolution)` after the closing paren of the list. (Inline prose annotation — not an HTML comment; these are reference-doc sentences.)
- **VERIFY:** `grep -c "flat folder layout" reference/trackers/local.md` = 0; `grep -c "§PO-tree resolution" reference/trackers/local.md` ≥ 1.

### Step 42 — `reference/trackers/ado.md` (row 42)
- L56 `… writes the verbatim JSON to stories/{slug}-*/raw/issue.json (or epics/{slug}-*/raw/issue.json / features/{slug}-*/raw/issue.json for the PO-flow variants … — flat folder layout).` → replace `— flat folder layout` with `— resolved per §PO-tree resolution; the feature variant nests under its epic (epics/*/features/{slug}-*/raw/issue.json)`.
- **VERIFY:** `grep -c "flat folder layout" reference/trackers/ado.md` = 0.

### Step 43 — `reference/trackers/github.md` (row 43)
- L50 `PO-flow variants (epics/{slug}-*/raw/issue.json, features/{slug}-*/raw/issue.json — flat folder layout) do not apply here …` → replace `— flat folder layout` with `— under the nested layout per §PO-tree resolution`.
- **VERIFY:** `grep -c "flat folder layout" reference/trackers/github.md` = 0.

### Step 44 — `reference/implementation_plan_reference.md` (row 44)
- L11 `**Escalate to a full Implementation Plan at stories/{slug}/implementation_plan.md when:**` → append after the path `(the resolved story folder, per §PO-tree resolution)`.
- **VERIFY:** `grep -c "§PO-tree resolution" reference/implementation_plan_reference.md` = 1.

## Group G — execution personas (rows 45–46)

### Step 45 — `host/templates/claude/agents/plan-executor.md` (row 45)
- L31 story-altitude resolution `at story altitude, glob stories/{slug}/ (exact) then stories/{slug}-*/ (halt on multiple or zero matches)` → `at story altitude, resolve the story folder per templates/SHAMT_RULES.template.md §PO-tree resolution (tree-wide glob + legacy-flat fallback; halt on multiple or zero)`. The framework-altitude `proposals/` path is unchanged.
- **VERIFY:** `grep -c "§PO-tree resolution" host/templates/claude/agents/plan-executor.md` ≥ 1.

### Step 46 — `host/templates/claude/agents/test-executor.md` (row 46)
- Edit **L20 only** — `Resolve the folder via the global rules (exact, then stories/{slug}-*/ glob; halt on multiple or zero matches).` → `Resolve the story folder per templates/SHAMT_RULES.template.md §PO-tree resolution (tree-wide glob + legacy-flat fallback; halt on multiple or zero).` The subsequent lines (L21 `testing_plan_path …` and L22 `active_artifacts_path …`) reference `testing_plan.md` / `active_artifacts.md` as path-relative shorthand inside the resolved folder — **leave both lines unchanged**.
- **VERIFY:** `grep -c "§PO-tree resolution" host/templates/claude/agents/test-executor.md` ≥ 1.

---

## Phase 4 verification

- [ ] `grep -rn "Parent Epic\|Parent Feature" templates/feature.template.md templates/ticket.ado.template.md templates/ticket.github.template.md` returns 0.
- [ ] No `flat folder layout` phrase remains in `reference/trackers/*.md`.
- [ ] Both personas resolve the story folder per §PO-tree resolution.
- [ ] Every Group-D template carries the resolved-relative annotation; `feature.template` "Lives at" is nested.
- [ ] No `.claude/` file edited.

## Cross-phase final check (run after Phase 4)

- [ ] `grep -rn "Parent Epic\|Parent Feature" host/templates/claude/ templates/` → only intentional historical/relative mentions (no write instructions, no template header lines).
- [ ] `grep -rln "flat folder layout\|flat layout" templates/ reference/ host/templates/claude/ README.md` → none (or only where explicitly contrasted with the legacy fallback).
- [ ] All 46 rows have a corresponding edit; `epic.template.md` + `commands/validate-artifact.md` deliberately untouched (per #14 path-discipline).

Report `All steps completed. Verification passed.`

---
Validated 2026-06-11 — adversarial sub-agent review (4 rounds; converged findings fixed)
