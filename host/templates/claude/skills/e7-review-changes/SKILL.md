---
name: e7-review-changes
description: >
  Run Phase 7 (Review) — Pattern 4 in two modes. Story mode (/e7-review-changes
  {slug}): the primary agent runs the 16-category sweep against the story's
  own diff, writes feedback/review_vN.md, includes the Documentation
  Impact Assessment, and — when pr_provider == github — pushes the story branch
  and opens the PR via gh pr create (confirm-gated), recording the PR number in
  the story folder. Formal mode (--branch=<name> or --pr=<id>): hands off to
  the review-executor Opus persona, which produces code_reviews/<branch>/
  overview.md + review_vN.md. The review artifact is local only — never posts
  review content back to external trackers. Invoke when the user wants to review
  the changes, run the code review, do a formal PR review, or review a branch.
triggers:
  - "review the changes"
  - "review my branch"
  - "review the pr"
  - "run the code review"
  - "do a formal review"
  - "review story"
  - "review the story diff"
  - "run phase 7"
---

## Overview

Mirrors the `/e7-review-changes` slash command. Same canonical body, two host wirings. Two argument forms select the mode:

- `{slug}` → story mode (primary agent, Sonnet).
- `--branch=<name>` or `--pr=<id>` → formal mode (delegates to the `review-executor` Opus persona).

## Protocol

Follow the canonical `/e7-review-changes` command body verbatim — see [`commands/e7-review-changes.md`](../../commands/e7-review-changes.md).

## Recommended models

- **Story mode:** Balanced (Sonnet).
- **Formal mode:** Reasoning (Opus) via [`agents/review-executor.md`](../../agents/review-executor.md) for issue-finding; Cheap (Haiku) inside the persona for git metadata.

See [`reference/model_selection.md`](../../../../../reference/model_selection.md).

## Exit criteria

- **Story mode:** validated `stories/{slug}/feedback/review_vN.md`; `## Documentation Impact` populated; when `pr_provider == github`, the story branch pushed and the PR opened (confirm-gated) with the PR number recorded at `stories/{slug}/feedback/pr.md`.
- **Formal mode:** validated `code_reviews/<sanitized-branch>/overview.md` + `review_vN.md`.

---
Validated 2026-05-28 — 4 rounds, 1 adversarial sub-agent confirmed (Phase 6 implementation loop)

<!-- Managed by Shamt — do not edit. Regenerate from shamt-core/host/templates/claude/skills/e7-review-changes/SKILL.md. -->
