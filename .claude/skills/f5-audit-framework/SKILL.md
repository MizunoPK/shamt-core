---
name: f5-audit-framework
description: >
  Run the Shamt framework-wide audit (slugless). Sweeps every canonical
  surface across twelve dimensions — D1 sync drift, D2 cross-doc consistency,
  D3 bidirectional coverage, D4 reference validity, D5 template-protocol
  alignment, D6 project-doc currency, D7 terminology consistency, D8 content
  completeness, D9 duplication/contradiction, D10 count/claim accuracy, D11
  scope-clarity, D12 rules-file size budget — classifies findings with CRITICAL/HIGH/MEDIUM/LOW per
  Pattern 2, and runs a continuous dual-track loop: it auto-fixes simple
  findings in place and captures each intricate finding as an f0 draft
  proposal (via /f0-draft-proposal) so the loop continues instead of halting,
  exiting on Pattern 1's exit shape (1 primary clean round + 1 adversarial
  Haiku audit-checker sub-agent confirmation) with a clean-round condition
  adapted for the capture track (clean = no new auto-fix and no new draft).
  Master / self-host only — invoked in a child project it halts immediately
  and redirects to /f0-draft-proposal -> /f1-propose-update ->
  /sync-proposals. Findings are chat-only — no audit log artifacts.
  Acts as post-implementation verification at Phase 6 of the framework-update
  flow; also runnable standalone for periodic sweeps. Invoke when the user
  wants to audit the framework, check for drift / orphans / broken links, run
  a framework-wide consistency sweep, or verify the framework after a
  framework update.
triggers:
  - "audit the framework"
  - "run a framework audit"
  - "sweep the framework"
  - "check the framework for drift"
  - "check the framework for broken links"
  - "verify the framework after the update"
  - "framework consistency check"
  - "audit shamt-core"
---

## Overview

Mirrors the `/f5-audit-framework` slash command. Same canonical body, two host wirings.

## Slugless

The audit is framework-wide. It does not take a proposal slug — even when invoked as Phase 6 of the framework-update flow, the slug context lives in the surrounding conversation, not in the command arguments.

## Protocol

Follow the canonical `/f5-audit-framework` command body verbatim — see [`commands/f5-audit-framework.md`](../../commands/f5-audit-framework.md). Full D1–D12 definitions, the fix-track rubric with worked examples, and the known-exceptions list live in [`reference/audit_dimensions.md`](../../../../../reference/audit_dimensions.md).

## Recommended models

- Primary issue-finding (D2, D3, D5, D6 interpretation, D7, D9, D11): Reasoning (Opus).
- Mechanical sub-checks (D1, D4, D8, D10, D12, D6 file existence + date math): Cheap (Haiku).
- Adversarial confirmation (`audit-checker`): Cheap (Haiku) — zero-bias re-sweep on the clean round.

See [`reference/model_selection.md`](../../../../../reference/model_selection.md).

## Exit criteria

1 primary clean round (no new auto-fix and no new f0 draft) + an `audit-checker` sub-agent confirmation that surfaces nothing resettable (Pattern 1's exit *shape*, capture-track adaptation); all findings surfaced, simple ones auto-fixed and intricate ones captured as f0 drafts (or reported as already-captured), with each captured slug named for later `/f1-propose-update`. Master / self-host only — a child invocation halts at Step 0. No audit log artifact written.

## Two invocation contexts

(Both master / self-host — the audit does not run in a child.)

- **Inside the framework-update flow** (Phase 6) — acts as post-impl verification of a specific proposal's changes; the user takes the next phase (`/f6-archive-proposal`).
- **Standalone** — periodic sweep, after master pulls, before a release. Same body, no next-phase suggestion.

---
Validated 2026-05-28 — 4 rounds, 1 adversarial sub-agent confirmed (Phase 8 implementation loop)
Touched 2026-06-02 — mirrored the f5 command's continuous dual-track loop (f0-capture replaces route-and-halt), Step 0 child halt-and-redirect (report-only removed), and Pattern 1 exit *shape* with adapted clean-round into the frontmatter description + summary. Per proposals/audit-continuous-f0-draft-capture.md.

<!-- Managed by Shamt — do not edit. Regenerate from shamt-core/host/templates/claude/skills/f5-audit-framework/SKILL.md. -->
