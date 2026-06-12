# Proposal: artifacts-must-live-under-shamt-core

**Created:** 2026-06-11
**Status:** Draft (f0 — audit capture, unrefined)
**Number:** [NN — assigned by /f1-propose-update]
**Proposed by:**
**Project context:**

> **f0 DRAFT — unrefined capture.** Quick-captured by the framework audit
> or a user; not yet through the open-questions dialog. Run
> `/f1-propose-update artifacts-must-live-under-shamt-core` to flesh it out.

---

## Problem

[Deferred to /f1-propose-update.]

## Scratch Notes (f0 capture)

Just had a case of a child project creating `epics/`, `features/`, and
`stories/` folders at the **root level** of the project it was installed in.
This should not be allowed. All Shamt-generated working artifacts should live
inside the `.shamt-core/` directory — the **only** Shamt thing permitted at the
child project root is the Claude rules file (the managed-section `CLAUDE.md`)
and the `.claude/` directory Claude Code requires there.

So PO/Engineer working trees — `epics/`, `features/`, `stories/` (and presumably
`proposals/`, `code_reviews/`, etc.) — must be rooted under `.shamt-core/` in a
child, not at the project root.

Likely implicated canonical surfaces (informal, for f1 to confirm):
- The PO-flow commands/skills that create epic/feature/story folders
  (`p1-start-epic`, `p2-decompose-epic`, `p3-start-feature`, `p4-decompose-feature`)
  and the Engineer-flow story commands (`e1-start-story`, etc.) — wherever the
  base path for `epics/` / `features/` / `stories/` is resolved.
- The statusline / any path-resolution helper that assumes a root-level tree.
- `shamt-core/CLAUDE.md` and `templates/SHAMT_RULES.template.md` — the layout
  contract that says everything but the rules file lives under `.shamt-core/`.

Note: related to but distinct from #14 `po-nested-folder-layout` (nesting of the
PO tree) and `dot-shamt-core-layout` — f1 should reconcile against those rather
than duplicate. The specific gap here: the base directory for the
epic/feature/story tree must be `.shamt-core/`-relative in a child, and the
framework should not produce a root-level tree.

---

## Proposed Changes

[Deferred to /f1-propose-update — template placeholder.]

---

## Risks

[Deferred to /f1-propose-update — template placeholder.]

---

## Rollback Plan

[Deferred to /f1-propose-update — template placeholder.]

---

## Validation Considerations

[Deferred to /f1-propose-update — template placeholder.]

---

## Open Questions

[Deferred to /f1-propose-update.]
