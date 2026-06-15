# Proposal: f6-archive-preserve-uncommitted-footer

Created: 2026-06-15
Status: Draft (f0 — capture, unrefined)
Proposed by:
Project context:

> **f0 DRAFT — unrefined capture.** Quick-captured by a user/agent; not yet through the
> open-questions dialog. Run `/f1-propose-update f6-archive-preserve-uncommitted-footer` to flesh it out.

## Scratch Notes (f0 capture)

During a live `/f-all 27` run, `/f6-archive-proposal` hit a dangerous near-miss that nearly landed
the **wrong** (pre-validation) content as "Implemented":

- The validated proposal content (the `Validated …` footer + the Phase-2 fixes) was an
  **uncommitted working-tree modification** at the start of `/f6` — it had never been written into
  any git object (the framework-update flow deliberately leaves `/f3`/validation edits uncommitted
  until the `/f6` squash).
- `/f6`'s `git checkout {base-branch}` (the squash-merge step) **aborted on an untracked-path
  condition** and, in doing so, left a partially-checked-out tree that **silently reverted the
  archived proposal to the base branch's pre-implementation committed blob** — `Status: Draft`,
  footer stripped, all validated prose lost.
- Only the agent's post-move footer-integrity re-check caught it; it reconstructed the validated
  content and `--amend`ed before merging. One missed check from landing Draft content as Implemented.

**Root cause (to confirm at /f1).** `/f6` performs a `git mv` + commit + `git checkout base` +
`git merge --squash` sequence while the proposal's validated content exists *only* in the working
tree. Any git operation that touches the working tree between "read the validated content" and "it's
safely committed" can swap in the stale committed blob. The footer-integrity re-check is the only
safety net and it is easy to skip.

**Proposed direction (to refine).**
- Make `/f6` **commit the validated proposal content to the proposal branch FIRST** (before any
  `git checkout`/archive move that could revert it), so the validated bytes are in a git object
  before the squash sequence touches the working tree.
- Or: harden the archive sequence so `git checkout base` cannot run against a dirty/untracked-
  conflicting tree (stage everything intended first; fail loudly instead of partially checking out).
- Keep (and make mandatory, not best-effort) the post-move footer-integrity check that saved this
  run: after the archive move, assert `Status: Implemented` + the `Validated …` footer + expected
  content are present before committing/merging; halt otherwise.

## Proposed Changes

<!-- f0 stub — change list deferred to /f1-propose-update -->

## Risks

<!-- deferred to /f1 -->

## Rollback Plan

<!-- deferred to /f1 -->

## Validation Considerations

<!-- deferred to /f1 -->
