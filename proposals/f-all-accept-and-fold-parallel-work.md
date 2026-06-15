# Proposal: f-all-accept-and-fold-parallel-work

Created: 2026-06-15
Status: Draft (f0 — capture, unrefined)
Proposed by:
Project context:

> **f0 DRAFT — unrefined capture.** Quick-captured by a user/agent; not yet through the
> open-questions dialog. Run `/f1-propose-update f-all-accept-and-fold-parallel-work` to flesh it out.

## Scratch Notes (f0 capture)

During a live `/f-all 27` run, the driver and its per-phase dispatch agents repeatedly **reverted
unrelated in-tree proposal work** — two f0 stubs (`d5-…`, `f5-audit-…`) that had been renamed +
fleshed out into numbered proposals (`32`, `33`) by *other parallel sessions* were treated as
"stray off-script edits" and `git checkout`/`rm`-reverted at each phase. This destroyed legitimate
parallel work (one of the two, `33`, was unrecoverable — its content was never captured before the
revert).

**This is backwards and already contradicts the framework.** `/f6-archive-proposal`'s pre-merge
guard (`host/templates/claude/commands/f6-archive-proposal.md`, the "working tree contains the
proposal's change" guard) already states the correct rule:

> "Unrelated tree state — ad-hoc proposal captures or other in-progress work — is expected and
> accepted; it folds into this landing; **never halt or revert on it**."

The accept-and-fold rule lives only at `/f6` (Phase 7), but the **earlier** `/f-all` phases (the
driver's dispatch prompts for validation/build/audit) carry no such rule — and in practice actively
instruct sub-agents to revert other-proposal edits. The framework assumes parallel proposal
authoring is normal ("we always have a user working on new proposals or updating proposals in
parallel to an ongoing proposal implementation"), so **no phase should ever gatekeep-by-deletion**.

**Proposed direction.**
- Add the accept-and-fold rule to `host/templates/claude/commands/f-all.md` (and `skills/f-all/SKILL.md`)
  as a first-class driver invariant: the driver and every dispatched phase agent must **leave
  unrelated in-tree proposal work untouched** — never revert, rename-back, or delete it; it folds
  into the `/f6` landing (with an honest commit-body note) exactly as `/f6` already specifies.
- Scope the "touch only the target proposal" instruction precisely: a phase agent must not *author
  new off-task work*, but if such work is *already present in the tree* (from a parallel session or
  a prior phase), it is accepted, not reverted. The distinction is **author vs. revert**: don't
  spawn off-task work; don't destroy in-tree work either.
- Consider mirroring the same invariant into `/e-all` (the new Engineer-flow driver, #27) so both
  flow-drivers share the accept-and-fold stance.
- Cross-reference `agents-trust-cross-session-provenance` (sibling f0): the revert reflex was
  compounded by wrongly assuming the parallel work "never happened" because it wasn't in the
  current session.

## Proposed Changes

<!-- f0 stub — change list deferred to /f1-propose-update -->

## Risks

<!-- deferred to /f1 -->

## Rollback Plan

<!-- deferred to /f1 -->

## Validation Considerations

<!-- deferred to /f1 -->
