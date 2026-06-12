# Implementation Plan — Phase 3 (Engineer flow): po-nested-folder-layout (#14)

**Index:** [`14-po-nested-folder-layout_PLAN.md`](14-po-nested-folder-layout_PLAN.md) · **Rows:** 13–30 · **Deploy order:** after Phase 2 (cites §PO-tree resolution C1, active-pointer C2, back-ref drop C3).

> Canonical-only; no `.claude/`. Per C1, `stories/{slug}/...` artifact literals are **path-relative shorthand** for the resolved story folder and are left intact; the real edits are: (a) point the **story-folder resolution** at §PO-tree resolution (this also annotates the literals), (b) `/e1` drops back-ref preservation + writes the active-story pointer + uses a nested create path. The default per-file edit is the **resolution citation** (R-CITE); only `e1` carries more.
>
> **R-CITE pattern:** at the file's story-folder-resolution line (the Prerequisites "Story folder resolves…" line or the resolution Step), make it read: `Resolve the story folder per `templates/SHAMT_RULES.template.md` §PO-tree resolution (tree-wide glob + legacy-flat fallback); `stories/{slug}/` below denotes that resolved folder.` This single edit satisfies the row and annotates every `stories/{slug}/` literal in the file as resolved-relative.

---

## Step 13 — `commands/e1-start-story.md` (row 13) — substantive

- **13a (R-RESOLVE).** Replace the two resolution sub-steps L43 (`1. If {id-or-slug} is a ticket ID …, glob stories/{ID}-*/ticket.md; otherwise try stories/{slug}/ticket.md (exact match).`) and L44 (`2. If still not found (a slug), glob both stories/{slug}-*/ticket.md and stories/*-{slug}-*/ticket.md.`) with **this exact text** (one numbered item replacing both):
  > `1. Resolve the story folder per `templates/SHAMT_RULES.template.md` §PO-tree resolution (tree-wide glob + legacy-flat fallback): a ticket ID matches `…/stories/{ID}-*/`, a slug matches `…/stories/{slug}-*/` ∪ `…/stories/*-{slug}-*/` anywhere in the nested tree, with the legacy-flat `stories/{slug}-*/` as fallback. Exactly one match — halt on zero or multiple. `stories/{slug}/` below denotes that resolved folder.`
  Apply the **same** replacement to the L101 folder-confirm glob (`Glob stories/{ID}-*/ … and confirm only one folder exists`) → `Confirm §PO-tree resolution matched exactly one story folder for this ticket.`
- **13b (R-CREATE → route to #15).** A **brand-new parentless** story has no nested home, so `/e1` does not invent one. Replace L56 (`2. For a new (non-stub) story, allocate a ticket ID T{N} … and propose stories/{ID}-{slug}-{brief-description-kebab}/.`) with: `2. For a new story with no PO-flow parent, **halt this intake and hand off** to /p6-draft-tech-story (#15) — it seeds the nested ticket stub under the standing Tech Stories epic's Bugs / Quick Wins feature and re-enters the Engineer flow stub-aware. **Do not fall through to the folder-create/confirm steps below** (the stub already exists at its nested path). A story that already resolves to a nested folder (PO-flow stub, or an existing folder) is handled by the stub-aware path; allocate a ticket ID T{N} only when creating a genuinely new tracker-backed story whose nested parent epic/feature already exists.` The raw-payload literals at **L74 and L85** (`stories/{ID}-{slug}-{brief}/raw/issue.json`) and the freeform write at **L89** (`stories/{ID}-{slug}-{brief}/ticket.md`) are path-relative shorthand — **leave intact** (covered by 13a's annotation; note L89 is the `ticket.md` write, not a `raw/` path).
- **13c (R-BACKREF — full sweep, C3).** Back-ref reading/preservation is dropped *everywhere* in `e1-start-story.md`, not only the lines below. `grep -n "Parent Epic\|Parent Feature"` the file and handle **every** hit: write/read/preserve instructions → DELETE; descriptive / Notes mentions (e.g. the Notes-section "Back-ref headers are preserved verbatim …" and "back-refs untouched" lines, and the L95 freeform-branch stub-aware paragraph that mirrors L79) → reword to "parentage is the folder path". The exact replacements below are the **known anchors**; the sweep catches the rest. VERIFY end-state: `grep -c "Parent Epic\|Parent Feature" e1-start-story.md = 0`. Halt (`Step ambiguous`) for the architect on any non-obvious rewording. Known anchors:
  - **L47** `- **Stub case (PO-flow handoff).** If ticket.md carries **Parent Feature:** and/or **Parent Epic:** back-ref headers directly under the H1, this is a stub written by /p4-decompose-feature.` → `- **Stub case (PO-flow handoff).** If the resolved ticket.md folder is nested under a feature (per its path: epics/<e>/features/<f>/stories/<s>/), this is a stub written by /p4-decompose-feature.`
  - **L79** (the stub-aware merge intro in the fetch branch) → `**Stub-aware merge (when Step 2 marked the invocation as stub-aware).** The existing ticket.md carries the scope one-liner from /p4-decompose-feature in the body intake area, and (on a richer-cataloging stub) a ## Decomposition Context breadth section. Parentage is the folder path — there are no back-ref headers.`
  - **L81** `- **Back-ref headers:** preserved verbatim. The PO flow owns them; tracker payload's parent links do **not** overwrite them.` → DELETE this bullet entirely.
  - **L95** (the stub-aware merge intro in the freeform branch — same back-ref phrasing as L79) → **REPLACE WITH** (exact): `**Stub-aware merge (when Step 2 marked the invocation as stub-aware).** The existing ticket.md from /p4-decompose-feature already carries the scope one-liner in the body intake area, and (when present) a ## Decomposition Context breadth section. Parentage is the folder path — there are no back-ref headers.`
  - **L128** `- **Stub-aware handoff from the PO flow.** When /p4-decompose-feature has already created stories/{slug}-*/ticket.md, that stub carries **Parent Feature:** T{N} (feature-slug) and (when the parent feature has an epic) **Parent Epic:** T{N} (parent-epic-slug) back-ref headers under H1, plus a scope one-liner in the body intake area.` → `- **Stub-aware handoff from the PO flow.** When /p4-decompose-feature has already created the nested stub (…/features/<f>/stories/{slug}-*/ticket.md), that stub carries a scope one-liner in the body intake area; its parent feature/epic are the folder path, not headers.`
- **13d (R-PTR, C2).** In the folder-confirm/exit step, append: `Write the resolved story-folder path to .shamt-state/active-story (and .shamt-state/active-feature / active-epic for its parents when nested); create .shamt-state/ if absent.`
- **VERIFY:** `grep -c "Parent Feature\|Parent Epic" …/e1-start-story.md` = 0; `grep -c ".shamt-state/active-story" …` ≥ 1; `grep -c "§PO-tree resolution" …` ≥ 1.

## Step 14 — `skills/e1-start-story/SKILL.md` (row 14)

- Mirror Step 13: L30 resolution globs → §PO-tree resolution; L31 create path (new story → Tech Stories home; stub preserves its nested path) + add `.shamt-state/active-story` write; drop any back-ref-preservation phrasing.
- **VERIFY:** `grep -c "Parent" …/e1-start-story/SKILL.md` = 0; `grep -c ".shamt-state/active-story" …` ≥ 1.

## Steps 15–30 — R-CITE for the remaining Engineer commands + skills

Apply the **R-CITE** edit (above) to each file at the cited resolution line. Where a file has no explicit resolution line (skills that only reference artifacts), add the one-line note to its first `stories/{slug}/` mention.

| Step | Row | File | R-CITE anchor (locate line) |
|---|---|---|---|
| 15 | 15 | `commands/e2-define-spec.md` | L31 `Story folder resolves by ticket ID or slug (ID glob stories/{ID}-*/, else the both-positions slug glob …)` → R-CITE |
| 16 | 16 | `skills/e2-define-spec/SKILL.md` | L29 `Ingest the ticket (stories/{slug}/ticket.md)` → prepend the R-CITE note |
| 17 | 17 | `commands/e3-plan-implementation.md` | L45 `Story folder resolves; if stories/{slug}/active_artifacts.md exists …` → R-CITE |
| 18 | 18 | `skills/e3-plan-implementation/SKILL.md` | L32 first `stories/{slug}/implementation_plan.md` → prepend R-CITE note |
| 19 | 19 | `commands/e3b-write-testing-plan.md` | L31 `Story folder resolves; apply the active-artifact pointer if stories/{slug}/active_artifacts.md exists.` → R-CITE |
| 20 | 20 | `skills/e3b-write-testing-plan/SKILL.md` | L33 first `stories/{slug}/testing_plan.md` → prepend R-CITE note |
| 21 | 21 | `commands/e4-execute-plan.md` | L31 `Story folder resolves; if stories/{slug}/active_artifacts.md exists …` → R-CITE |
| 22 | 22 | `skills/e4-execute-plan/SKILL.md` | (no `stories/` literal — add a one-line note under Overview: `Story folder resolved per §PO-tree resolution.`) |
| 23 | 23 | `commands/e5-execute-tests.md` | L44 `Story folder resolves; if stories/{slug}/active_artifacts.md exists …` → R-CITE |
| 24 | 24 | `skills/e5-execute-tests/SKILL.md` | (no `stories/` literal — add the one-line §PO-tree resolution note under Overview) |
| 25 | 25 | `commands/e5b-write-manual-testing-plan.md` | L32 `Story folder resolves; if stories/{slug}/active_artifacts.md exists …` → R-CITE |
| 26 | 26 | `skills/e5b-write-manual-testing-plan/SKILL.md` | L4 description references `stories/{slug}/manual_test_plan.md` — add R-CITE note in the body Protocol |
| 27 | 27 | `commands/e6-review-changes.md` | L64 `Walk stories/{slug}/feedback/ …` (story-mode) → R-CITE at the story-mode resolution; L114 `Story: stories/{slug}/` header literal left intact (annotated) |
| 28 | 28 | `skills/e6-review-changes/SKILL.md` | L41 first `stories/{slug}/feedback/review_vN.md` → prepend R-CITE note |
| 29 | 29 | `commands/e7-resolve-feedback.md` | L30 `Story folder resolves; if stories/{slug}/active_artifacts.md exists, read it first.` → R-CITE |
| 30 | 30 | `skills/e7-resolve-feedback/SKILL.md` | (no `stories/` literal — add the one-line §PO-tree resolution note under Protocol) |

For each: **VERIFY** `grep -c "§PO-tree resolution" <file>` ≥ 1.

> **Formal-mode note (e6).** `/e6-review-changes --branch/--pr` writes to `code_reviews/<branch>/`, which is **not** story-nested and unaffected. Only the story-mode `stories/{slug}/feedback/...` resolution is annotated.

---

## Phase 3 verification

- [ ] `grep -rLn "§PO-tree resolution" host/templates/claude/commands/e[1-7]*.md host/templates/claude/commands/e3b*.md host/templates/claude/commands/e5b*.md` lists **no** Engineer command (every one cites the convention).
- [ ] `/e1-start-story` (+ skill): no back-ref preservation remains (`grep -c "Parent Feature\|Parent Epic"` = 0); writes `.shamt-state/active-story`; new freeform stories nest under the Tech Stories home.
- [ ] `stories/{slug}/...` artifact literals are intact (path-relative shorthand) — NOT rewritten to full nested paths.
- [ ] Spot-check that each R-CITE landed on the file's **resolution line** (the Prerequisites "Story folder resolves…" line or the resolution Step), not elsewhere: `grep -n "§PO-tree resolution" host/templates/claude/commands/e2-define-spec.md` points at the L31 area; same for the other commands.
- [ ] `/e1` (+ skill): the L43/L44 resolution sub-steps are replaced by the single §PO-tree resolution item; new parentless stories route to `/p6-draft-tech-story`; `.shamt-state/active-story` is written; no `Parent` back-ref read/preserve remains.
- [ ] No `.claude/` file edited.

Report `All steps completed. Verification passed.` then halt for Phase 4.

---
Validated 2026-06-11 — adversarial sub-agent review (4 rounds; converged findings fixed)
