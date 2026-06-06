---
name: e7-resolve-feedback
description: >
  Run Phase 7 (Polish) of the Shamt Engineer flow. Apply each comment from the
  latest review_vN.md, log dispositions in addressed_feedback.md, perform the
  .shamt-core/project-specific-files/ARCHITECTURE.md / .shamt-core/project-specific-files/CODING_STANDARDS.md updates the Review phase flagged, and
  route generalizable root causes to .shamt-core/proposals/ rather than patching framework
  files in-story. Invoke when the user wants to address review feedback,
  resolve comments, polish the story, run phase 7, or apply review fixes.
triggers:
  - "address the review feedback"
  - "resolve the review comments"
  - "polish the story"
  - "run phase 7"
  - "apply review fixes"
  - "work the addressed_feedback list"
  - "polish {slug}"
---

## Overview

Mirrors the `/e7-resolve-feedback {slug}` slash command. Same canonical body, two host wirings.

## Protocol

Follow the canonical `/e7-resolve-feedback` command body verbatim — see [`commands/e7-resolve-feedback.md`](../../commands/e7-resolve-feedback.md). Summary:

1. **Inventory feedback** — pick the latest `feedback/review_vN.md`; read its leadership sections, checklists, and `## Documentation Impact`. Carry forward `Pending` / `Needs user decision` rows from a prior `addressed_feedback.md`.
2. **Open or update `addressed_feedback.md`** — one row per reviewer comment; fields `Source`, `Disposition`, `Action taken`, `Root cause`, `Notes`.
3. **Resolve one at a time** — descending severity. Understand the finding; choose Fix in-story / Defer (explicit user accept + forward link) / Needs user decision; verify against the active plan's (or spec's) `## Verification`; reflect on root cause. For Standard-path non-trivial fixes, re-hand off to the `plan-executor` builder for the modified step.
4. **Documentation Impact update** — when the Review flagged `Required`, apply the `Polish action` to `.shamt-core/project-specific-files/ARCHITECTURE.md` / `.shamt-core/project-specific-files/CODING_STANDARDS.md`, update `Last Updated` + `Update History`, re-validate via `/validate-artifact`. Commit.
5. **Root-cause / upstream proposals** — generalizable patterns → `.shamt-core/proposals/<proposal-slug>.md` (descriptive slug, not the story slug) via the framework-update flow. Story-specific patterns stay in-story.
6. **TODO scan** — Global Story Invariants TODO gate; remove or explicitly justify every remaining marker; honour stricter `.shamt-core/project-specific-files/CODING_STANDARDS.md` rules.
7. **Exit gate** — every comment `Resolved` / `Deferred — <reason>` / `Needs user decision` with active follow-up; doc updates applied; TODO gate passes; proposals filed. **User explicitly signals complete.**

## Recommended models

- Mechanical fixes: Balanced (Sonnet).
- Root-cause / upstream-proposal synthesis: Reasoning (Opus).

See [`reference/model_selection.md`](../../../../../reference/model_selection.md).

## Exit criteria

`addressed_feedback.md` fully dispositioned; `Required` doc updates applied + re-validated; TODO gate passes; generalizable root causes filed under `.shamt-core/proposals/`; user has signalled complete. No `Pending` rows remain.

## Re-baseline trigger

If applying a comment would make the active spec or plan misleading, stop and invoke the **Re-baseline Protocol** per [`SHAMT_RULES.template.md`](../../../../../templates/SHAMT_RULES.template.md#requirement-re-baseline-protocol). Do not silently rewrite the active artifact.

---
Validated 2026-05-28 — 4 rounds, 1 adversarial sub-agent confirmed (Phase 6 implementation loop)

<!-- Managed by Shamt — do not edit. Regenerate from shamt-core/host/templates/claude/skills/e7-resolve-feedback/SKILL.md. -->
