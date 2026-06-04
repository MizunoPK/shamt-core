---
name: e6-review-changes
description: >
  Run Phase 6 (Review) — Pattern 4 in two modes. Story mode (/e6-review-changes
  {slug}): the primary agent runs the 16-category sweep against the story's
  own diff, writes feedback/review_vN.md, and includes the Documentation
  Impact Assessment. Formal mode (--branch=<name> or --pr=<id>): hands off to
  the review-executor Opus persona, which produces code_reviews/<branch>/
  overview.md + review_vN.md. Local artifact only — never posts back to
  external trackers. Invoke when the user wants to review the changes, run
  the code review, do a formal PR review, or review a branch.
triggers:
  - "review the changes"
  - "review my branch"
  - "review the pr"
  - "run the code review"
  - "do a formal review"
  - "review story"
  - "review the story diff"
  - "run phase 6"
---

## Overview

Mirrors the `/e6-review-changes` slash command. Same canonical body, two host wirings. Two argument forms select the mode:

- `{slug}` → story mode (primary agent, Sonnet).
- `--branch=<name>` or `--pr=<id>` → formal mode (delegates to the `review-executor` Opus persona).

## Protocol

Follow the canonical `/e6-review-changes` command body verbatim — see [`commands/e6-review-changes.md`](../../commands/e6-review-changes.md). Summary:

### Story mode

1. **Resolve & gate-check** — apply the active-artifact pointer; confirm spec / plan / testing artifact validation footers.
2. **Plan Alignment pre-pass** — Quick: `N/A`. Standard: walk Step Coverage, Change Fidelity, Scope Discipline, Verification Passage, Zero Builder Design Decisions. Write `## Plan Alignment` at the top of `review_vN.md`.
3. **16-category sweep** — apply every category from [`reference/review_categories.md`](../../../../../reference/review_categories.md); apply the Review Prevention Gates overlay from [`reference/pr_review_prevention.md`](../../../../../reference/pr_review_prevention.md); hard checks include per-file-and-function fresh review, removed-check replacement analysis, tenant-A-to-tenant-B bypass consideration, end-to-end DB lineage.
4. **Documentation Impact Assessment** (§1.12) — does the change require `.shamt-core/project-specific-files/ARCHITECTURE.md` or `.shamt-core/project-specific-files/CODING_STANDARDS.md` updates? Write `## Documentation Impact` with `Required | Not required` + reason + Polish action.
5. **Write `review_vN.md`** — Severities BLOCKING / CONCERN / SUGGESTION / NITPICK; required sections per [`templates/code_review.template.md`](../../../../../templates/code_review.template.md). Quick-path no-issue shortcut: append a `## Post-Build Review` block to the spec instead of writing a durable artifact.
6. **Validate** — `/validate-artifact stories/{slug}/feedback/review_vN.md` (7 dimensions — 6 review + Plan Alignment). Footer.
7. **Exit** — `/e7-resolve-feedback {slug}` if findings exist.

### Formal mode

1. **Resolve target / base** — `--pr=<id>` resolves via the active tracker profile's `## PR fetch`; `--branch=<name>` is direct.
2. **Hand off to the `review-executor`** — Opus persona ([`agents/review-executor.md`](../../agents/review-executor.md)). Read-only git; never `git checkout`. Produces `overview.md` (5-dim validated) + `review_vN.md` (6-dim validated).
3. **Monitor** — surface findings counts to the user. **No tracker postback** — user posts manually if desired (per §1.11 / Pattern 4).

## Recommended models

- **Story mode:** Balanced (Sonnet).
- **Formal mode:** Reasoning (Opus) via [`agents/review-executor.md`](../../agents/review-executor.md) for issue-finding; Cheap (Haiku) inside the persona for git metadata.

See [`reference/model_selection.md`](../../../../../reference/model_selection.md).

## Exit criteria

- **Story mode:** validated `stories/{slug}/feedback/review_vN.md` (or `## Post-Build Review` block in the spec on a Quick-path no-issue review); `## Documentation Impact` populated.
- **Formal mode:** validated `code_reviews/<sanitized-branch>/overview.md` + `review_vN.md`.

---
Validated 2026-05-28 — 4 rounds, 1 adversarial sub-agent confirmed (Phase 6 implementation loop)

<!-- Managed by Shamt — do not edit. Regenerate from shamt-core/host/templates/claude/skills/e6-review-changes/SKILL.md. -->
