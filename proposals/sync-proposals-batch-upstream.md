# Proposal: sync-proposals-batch-upstream

**Created:** 2026-06-19
**Status:** Draft (f0 — audit capture, unrefined)
**Number:**
**Proposed by:**
**Project context:**

> **f0 DRAFT — unrefined capture.** Quick-captured by the framework audit
> or a user; not yet through the open-questions dialog. Run
> `/f1-propose-update sync-proposals-batch-upstream` to flesh it out.

## Scratch Notes (f0 capture)

Rework the child-side upstream-submission command. Today it is `/sync-submit-proposal {slug}` (canonical body `host/templates/claude/commands/sync-submit-proposal.md` + skill `host/templates/claude/skills/sync-submit-proposal/SKILL.md`), which prepares **one** validated child-local proposal at a time for upstream copy-paste and moves that single copy to `.shamt-core/proposals/submitted/{slug}.md`.

Desired change:

- **Rename** the command to **`/sync-proposals`** (slugless / batch — no longer takes a single `{slug}`).
- **Batch semantics:** send **all proposals active in the child project** up to the master version in one run, not one at a time. "Active" = the proposals living at the top level of `.shamt-core/proposals/` (presumably excluding the `submitted/`, `already-merged/`, `archive/`, `rejected/`, `deferred/` subfolders — confirm in f1).
- **Delete from the child after submission:** each submitted proposal should be **removed from the child** as part of the process (vs. today's move-to-`submitted/`). Need to reconcile this with the existing `submitted/` "awaiting decision" marker convention — is the move-to-`submitted/` replaced by a hard delete, or does "deleted from the child" just mean it leaves the active top level? (resolve in f1).
- **Accepted input states:** it is **expected** that all submitted proposals are **f0 drafts** (`Status: Draft (f0 — audit capture, unrefined)`). **Validated** proposals are **also accepted**, but on submission a validated proposal must be **stripped of any numeric identifier** it carries (the master-side `{NN}-` filename prefix and the `**Number:**` header) — child-side proposals are unnumbered by convention, so a numeric ID should never travel upstream. (Master assigns its own number at `/sync-triage-proposals` promote / `/f1-propose-update`.)

Implicated canonical files (informal):
- `host/templates/claude/commands/sync-submit-proposal.md` → rename/rewrite to `sync-proposals.md`
- `host/templates/claude/skills/sync-submit-proposal/SKILL.md` → rename to `sync-proposals/SKILL.md`
- `README.md` (sync section listing `/sync-submit-proposal`)
- Any cross-references in `/f0-draft-proposal`, `/f1-propose-update` exit text ("then `/sync-submit-proposal {slug}` to send it upstream — child only"), `/f5-audit-framework` redirect text, `/sync-triage-proposals`, and `shamt-core/CLAUDE.md`.
- `templates/SHAMT_RULES.template.md` if it names the command.

Open questions to resolve in f1 (non-exhaustive): hard-delete vs. keep a `submitted/` audit trail; how the batch run reports the master-side target paths for N proposals (one block per proposal, `proposals/incoming/{project}-{slug}.md`); whether a validated proposal's validation footer survives the upstream copy; ordering / partial-failure behavior.

## Problem

[Deferred to /f1-propose-update.]

## Proposed Changes

[Deferred to /f1-propose-update.]

## Risks

[Deferred to /f1-propose-update.]

## Rollback Plan

[Deferred to /f1-propose-update.]

## Validation Considerations

[Deferred to /f1-propose-update.]
