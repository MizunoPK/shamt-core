---
name: e7-resolve-feedback
description: >
  Run Phase 7 (Polish) of the Shamt Engineer flow. Apply each comment from a
  union of feedback sources rebuilt every run — the latest local review_vN.md
  plus, when a PR is recorded and pr_provider == github, the latest PR comments
  (pull-only; deduped by comment-ID) — log dispositions in addressed_feedback.md,
  push fix commits to the PR branch, perform the
  .shamt-core/project-specific-files/ARCHITECTURE.md / .shamt-core/project-specific-files/CODING_STANDARDS.md / .shamt-core/project-specific-files/TESTING_STANDARDS.md updates the Review phase flagged, and
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

Follow the canonical `/e7-resolve-feedback` command body verbatim — see [`commands/e7-resolve-feedback.md`](../../commands/e7-resolve-feedback.md). Resolve the story folder per `templates/SHAMT_RULES.template.md` §PO-tree resolution (tree-wide glob + legacy-flat fallback).

## Recommended models

- Mechanical fixes: Balanced (Sonnet).
- Root-cause / upstream-proposal synthesis: Reasoning (Opus).

See [`reference/model_selection.md`](../../../../../reference/model_selection.md).

## Exit criteria

`addressed_feedback.md` fully dispositioned (union of local `review_vN.md` findings + — when `pr_provider == github` and a PR is recorded — the latest PR comments, deduped by comment-ID); fix commits pushed to the PR branch (pull-only — no thread reply / resolve); `Required` doc updates applied + re-validated; TODO gate passes; generalizable root causes filed under `.shamt-core/proposals/`; user has signalled complete. No `Pending` rows remain. Re-runnable N times as new PR comments arrive.

## Re-baseline trigger

If applying a comment would make the active spec or plan misleading, stop and invoke the **Re-baseline Protocol** per [`SHAMT_RULES.template.md`](../../../../../templates/SHAMT_RULES.template.md#requirement-re-baseline-protocol). Do not silently rewrite the active artifact.

---
Validated 2026-05-28 — 4 rounds, 1 adversarial sub-agent confirmed (Phase 6 implementation loop)

<!-- Managed by Shamt — do not edit. Regenerate from shamt-core/host/templates/claude/skills/e7-resolve-feedback/SKILL.md. -->
