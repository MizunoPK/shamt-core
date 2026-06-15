# Proposal: agents-trust-cross-session-provenance

Created: 2026-06-15
Status: Draft (f0 — capture, unrefined)
Proposed by:
Project context:

> **f0 DRAFT — unrefined capture.** Quick-captured by a user/agent; not yet through the
> open-questions dialog. Run `/f1-propose-update agents-trust-cross-session-provenance` to flesh it out.

## Scratch Notes (f0 capture)

During a live `/f-all 27` run, the driver wrongly concluded that a parallel proposal's content was
**fabricated** because it cited work the *current* session had not performed. Specifically, a
restored proposal (`32-d5-…`) carried the line *"Confirmed root cause (adversarial diagnosis — Opus
`root-cause-diagnoser` + Haiku zero-bias confirmation, 2026-06-15)"*. The driver had not spawned a
`root-cause-diagnoser` in its own session, so it labeled the provenance "fabricated" and reverted
the work. **This assumption was false** — a *different, parallel session* had genuinely run the
`root-cause-diagnoser`. The work was real; the current session simply had no visibility into it.

**The class of error:** an agent treating "I didn't do/see X in this conversation" as evidence that
"X never happened," and then destroying or distrusting an artifact on that basis. Shamt is explicitly
multi-session and parallel — multiple sessions author/update proposals and run personas (root-cause-
diagnoser, validation-checker, etc.) concurrently. An agent's own conversation history is **not** a
complete record of what work has occurred.

**Proposed direction (to refine).**
- Add a normative note (candidate homes: `CLAUDE.md` master-dev primer, `templates/SHAMT_RULES.template.md`
  Principle-2 / open-questions area, and/or the `/f-all` + `/e-all` driver bodies and the persona
  dispatch guidance) stating: **agents must not assume an on-disk artifact's claimed provenance is
  fabricated, or that referenced work "never happened," merely because it is absent from the current
  session.** Parallel sessions do real work; cross-session artifacts and their provenance are to be
  trusted and accepted, not reverted.
- Tie this to `f-all-accept-and-fold-parallel-work` (sibling f0): the cross-session-provenance
  misjudgment is *why* the accept-and-fold rule matters — the revert reflex and the false-fabrication
  assumption are the same failure mode from two angles.
- If verification of a cross-session claim is genuinely needed, the move is to **ask the user / check
  git history across branches**, never to silently delete the artifact.

## Proposed Changes

<!-- f0 stub — change list deferred to /f1-propose-update -->

## Risks

<!-- deferred to /f1 -->

## Rollback Plan

<!-- deferred to /f1 -->

## Validation Considerations

<!-- deferred to /f1 -->
