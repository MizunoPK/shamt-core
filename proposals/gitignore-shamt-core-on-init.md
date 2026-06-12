# Proposal: gitignore-shamt-core-on-init

**Created:** 2026-06-11
**Status:** Draft (f0 — audit capture, unrefined)
**Number:** [NN — assigned by /f1-propose-update]
**Proposed by:**
**Project context:**

> **f0 DRAFT — unrefined capture.** Quick-captured by the framework audit
> or a user; not yet through the open-questions dialog. Run
> `/f1-propose-update gitignore-shamt-core-on-init` to flesh it out.

---

## Problem

[Deferred to /f1-propose-update.]

## Scratch Notes (f0 capture)

shamt-core should be added to a project's gitignore on init.

The `.shamt-core/` directory installed into a child project holds copied
canonical sources, the proposals working area, project-specific files, and
config — most of which is regenerated from master and shouldn't be committed to
the child's own repo. When Shamt is initialized in a child, the init flow should
ensure `.shamt-core/` (in whole or in the appropriate part) lands in the
child's `.gitignore` so it isn't tracked by the child project's git.

Open question for f1 to resolve: whether to gitignore the *entire* `.shamt-core/`
directory or only the regenerated/transient parts (the child's own
`.shamt-core/proposals/` drafts and `project-specific-files/` may be content the
child *does* want tracked). Likely implicated canonical file: the init script
(`scripts/init-shamt.sh` or equivalent) and possibly `shamt-core/CLAUDE.md` /
`README.md` docs describing the child layout.

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
