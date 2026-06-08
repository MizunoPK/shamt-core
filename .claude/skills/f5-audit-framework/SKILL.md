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
  /sync-submit-proposal. Findings are chat-only — no audit log artifacts.
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

Follow the canonical `/f5-audit-framework` command body verbatim — see [`commands/f5-audit-framework.md`](../../commands/f5-audit-framework.md). Full D1–D12 definitions, the fix-track rubric with worked examples, and the known-exceptions list live in [`reference/audit_dimensions.md`](../../../../../reference/audit_dimensions.md). Summary:

0. **Step 0 — target context (master / self-host only).** Resolve the target via the D6 self-host detection rule. **Master / self-host** → proceed. **Child project** → **halt immediately** and redirect to `/f0-draft-proposal` → `/f1-propose-update` → `/sync-submit-proposal`; do not sweep, auto-fix, capture, or run the sub-agent (a child's `.shamt-core/` canonical sources are read-only imports; local drift is covered by `/sync-import-shamt` regen and `/f4-regen-framework --check`). This is the single child guard — the rest of the loop assumes master / self-host.
1. **D1 sync drift** — run `bash scripts/regenerate-framework.sh --check --target {dir}` (self-host master form; f5 is master/self-host only). `DRIFT`/`STALE` lines = HIGH findings (one per path).
2. **D2 cross-doc consistency** — for every pattern / invariant in `templates/SHAMT_RULES.template.md`, confirm matching skill/command/persona bodies describe the same steps, exit criteria, and naming.
3. **D3 bidirectional coverage** — every documented pattern has a host implementation; every host file cites a pattern or rule it implements. Missing implementation = HIGH; orphan host file = MEDIUM.
4. **D4 reference validity** — mechanical walk of every markdown link, template reference, profile name, and persona name across canonical files. Broken target = HIGH.
5. **D5 template-protocol alignment** — every template has every section the producing/consuming protocol expects; no orphan sections. Missing required section = HIGH; orphan section = MEDIUM.
6. **D6 project-doc currency** — `.shamt-core/project-specific-files/ARCHITECTURE.md` + `.shamt-core/project-specific-files/CODING_STANDARDS.md` present in the child project; `Last Updated` within `doc_staleness_threshold_days` (default 60 per `.shamt-core/shamt-config.json`). Missing required doc = HIGH; stale doc = MEDIUM; not-applicable case for in-development `shamt-core/` = single LOW informational.
7. **D7 terminology consistency** — one canonical term per concept across all canonical docs ("Quick"/"Standard" never "Small"/"Full", "Build" never "Implement"). Non-canonical synonym in an instruction path = HIGH.
8. **D8 content completeness** — no stray `TODO`/`TBD`/`FIXME`/unfilled `[placeholder]` brackets in canonical content (templates' intentional fill-ins excepted). Stray marker = MEDIUM (HIGH in template instructional prose).
9. **D9 duplication/contradiction** — no two canonical files give conflicting instructions for the same protocol (host↔host / reference↔reference; distinct from D2's rules↔host check). Live contradiction = HIGH.
10. **D10 count/claim accuracy** — explicit counts and claims match reality ("12 dimensions", "5 patterns", phase numbers, persona counts). Mismatched count = HIGH.
11. **D11 scope-clarity** — each command/skill states its scope unambiguously near its heading; no leftover migration notes or stale "(was X)" parentheticals inline. Stale aside = MEDIUM; missing/ambiguous scope = HIGH.
12. **D12 rules-file size budget** — `wc -m templates/SHAMT_RULES.template.md` within `rules_size_budget_chars` (default 40000). Over budget = MEDIUM, **always intricate** → f0-capture pointing at `/trim-rules-file`; never auto-fixed.
13. **Classify** per Pattern 2 (borderline → HIGHER). See [`reference/severity_classification.md`](../../../../../reference/severity_classification.md). **Dual-track fix policy (master / self-host):** *simple* findings (mechanical + single-file + uniquely-determined) are fixed immediately and re-verified by re-running their dimension (regen after any `host/templates/claude/` edit); *intricate* and borderline findings are **captured as an f0 draft** via `/f0-draft-proposal` — after reading `proposals/` in all states and skipping any finding that already has an addressing draft (judgment, not a key match) — and the audit **continues** rather than implementing the fix. In-flow, each auto-fix **and** each f0 draft captured is logged in chat for attribution but **folded into the in-flight proposal's landing commit** (ridden into the `/f6-archive-proposal` squash-merge, not held separate from the proposal's scope).
14. **Evaluate the primary round (adapted clean-round)** — clean = **no new auto-fix AND no new f0 draft** (a clean round may still *report* intricate findings that already have an addressing draft — the deliberate difference from canonical Pattern 1's "zero issues / one LOW"). Not clean → re-sweep; the loop **continues** past a captured intricate finding (capture-and-continue) instead of halting. Converges on agent judgment — no round cap, no provable-non-spin claim.
15. **Exit (Pattern 1 exit *shape*):** on the first clean round, spawn the **`audit-checker`** Haiku sub-agent ([`agents/audit-checker.md`](../../agents/audit-checker.md)) to re-run the D1–D12 sweep with zero bias; **pass it the findings captured this run (one-line description + draft slug)** so it does not reset on an already-addressed intricate finding. Any *new* simple finding or genuinely-uncaptured intricate finding it surfaces (even one LOW — no allowance) resets the loop; a `CONFIRMED` reply (nothing resettable) exits. State the exit clearly, reporting the f0 drafts captured this run. **No log artifact.** When following `/f4-regen-framework` for a specific proposal, suggest `/clear` + `/f6-archive-proposal {slug}`. Standalone: no next-phase suggestion.

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
