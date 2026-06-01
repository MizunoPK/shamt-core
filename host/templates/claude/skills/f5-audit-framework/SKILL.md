---
name: f5-audit-framework
description: >
  Run the Shamt framework-wide audit (slugless). Sweeps every canonical
  surface across eleven dimensions — D1 sync drift, D2 cross-doc consistency,
  D3 bidirectional coverage, D4 reference validity, D5 template-protocol
  alignment, D6 project-doc currency, D7 terminology consistency, D8 content
  completeness, D9 duplication/contradiction, D10 count/claim accuracy, D11
  scope-clarity — classifies findings with CRITICAL/HIGH/MEDIUM/LOW per
  Pattern 2, and exits on Pattern 1's loop (1 primary clean round + 1
  adversarial Haiku audit-checker sub-agent confirmation). On a master /
  self-host target it auto-fixes simple findings and routes intricate ones to
  proposals; against a child project it stays report-only. Findings are
  chat-only — no audit log artifacts. Acts as post-implementation
  verification at Phase 6 of the framework-update flow; also runnable
  standalone for periodic sweeps. Invoke when the user wants to audit the
  framework, check for drift / orphans / broken links, run a framework-wide
  consistency sweep, or verify the framework after a framework update.
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

Follow the canonical `/f5-audit-framework` command body verbatim — see [`commands/f5-audit-framework.md`](../../commands/f5-audit-framework.md). Full D1–D11 definitions, the fix-track rubric with worked examples, and the known-exceptions list live in [`reference/audit_dimensions.md`](../../../../../reference/audit_dimensions.md). Summary:

1. **D1 sync drift** — run `bash shamt-core/scripts/regenerate-framework.sh --check --target {dir}`. `DRIFT`/`STALE` lines = HIGH findings (one per path).
2. **D2 cross-doc consistency** — for every pattern / invariant in `templates/SHAMT_RULES.template.md`, confirm matching skill/command/persona bodies describe the same steps, exit criteria, and naming.
3. **D3 bidirectional coverage** — every documented pattern has a host implementation; every host file cites a pattern or rule it implements. Missing implementation = HIGH; orphan host file = MEDIUM.
4. **D4 reference validity** — mechanical walk of every markdown link, template reference, profile name, and persona name across canonical files. Broken target = HIGH.
5. **D5 template-protocol alignment** — every template has every section the producing/consuming protocol expects; no orphan sections. Missing required section = HIGH; orphan section = MEDIUM.
6. **D6 project-doc currency** — `.shamt-core/project-specific-files/ARCHITECTURE.md` + `.shamt-core/project-specific-files/CODING_STANDARDS.md` present in the child project; `Last Updated` within `doc_staleness_threshold_days` (default 60 per `.shamt-core/shamt-config.json`). Missing required doc = HIGH; stale doc = MEDIUM; not-applicable case for in-development `shamt-core/` = single LOW informational.
7. **D7 terminology consistency** — one canonical term per concept across all canonical docs ("Quick"/"Standard" never "Small"/"Full", "Build" never "Implement"). Non-canonical synonym in an instruction path = HIGH.
8. **D8 content completeness** — no stray `TODO`/`TBD`/`FIXME`/unfilled `[placeholder]` brackets in canonical content (templates' intentional fill-ins excepted). Stray marker = MEDIUM (HIGH in template instructional prose).
9. **D9 duplication/contradiction** — no two canonical files give conflicting instructions for the same protocol (host↔host / reference↔reference; distinct from D2's rules↔host check). Live contradiction = HIGH.
10. **D10 count/claim accuracy** — explicit counts and claims match reality ("11 dimensions", "5 patterns", phase numbers, persona counts). Mismatched count = HIGH.
11. **D11 scope-clarity** — each command/skill states its scope unambiguously near its heading; no leftover migration notes or stale "(was X)" parentheticals inline. Stale aside = MEDIUM; missing/ambiguous scope = HIGH.
12. **Classify** per Pattern 2 (borderline → HIGHER). See [`reference/severity_classification.md`](../../../../../reference/severity_classification.md). **Two-track fix policy (master / self-host target only, via the D6 self-host detection rule):** *simple* findings (mechanical + single-file + uniquely-determined) are fixed immediately and re-verified by re-running their dimension (regen after any `host/templates/claude/` edit); *intricate* and borderline findings route to `/f1-propose-update` without editing. In-flow, each auto-fix is logged as an out-of-band correction distinct from the in-flight proposal's scope. **Against a child project the audit stays report-only** — its `.shamt-core/` canonical copies are imported from master; findings surface with an upstream-routing suggestion (`/f1-propose-update` → `/sync-submit-proposal`).
13. **Evaluate the primary round** — clean = 0 findings or 1 LOW fixed; intricate findings routed to a proposal halt the loop (re-audit after the proposal lands); otherwise re-sweep to confirm auto-fixes cleared.
14. **Exit (Pattern 1):** on the first clean round, spawn the **`audit-checker`** Haiku sub-agent ([`agents/audit-checker.md`](../../agents/audit-checker.md)) to re-run the D1–D11 sweep with zero bias; any finding it surfaces (even one LOW — no allowance) resets the loop, a `CONFIRMED` reply exits. State the exit clearly. **No log artifact.** When following `/f4-regen-framework` for a specific proposal, suggest `/clear` + `/f6-archive-proposal {slug}`. Standalone: no next-phase suggestion.

## Recommended models

- Primary issue-finding (D2, D3, D5, D6 interpretation, D7, D9, D11): Reasoning (Opus).
- Mechanical sub-checks (D1, D4, D8, D10, D6 file existence + date math): Cheap (Haiku).
- Adversarial confirmation (`audit-checker`): Cheap (Haiku) — zero-bias re-sweep on the clean round.

See [`reference/model_selection.md`](../../../../../reference/model_selection.md).

## Exit criteria

1 primary clean round + an `audit-checker` sub-agent confirmation that independently finds nothing (Pattern 1's exit); all findings surfaced, simple ones auto-fixed (master target) and intricate ones routed to proposals. No audit log artifact written.

## Two invocation contexts

- **Inside the framework-update flow** (Phase 6) — acts as post-impl verification of a specific proposal's changes; the user takes the next phase (`/f6-archive-proposal`).
- **Standalone** — periodic sweep, after master pulls, before a release. Same body, no next-phase suggestion.

---
Validated 2026-05-28 — 4 rounds, 1 adversarial sub-agent confirmed (Phase 8 implementation loop)

<!-- Managed by Shamt — do not edit. Regenerate from shamt-core/host/templates/claude/skills/f5-audit-framework/SKILL.md. -->
