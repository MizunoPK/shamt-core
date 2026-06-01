---
description: Phase 6 of the framework-update flow (slugless) — sweep the framework across 11 audit dimensions, classify findings, and exit on Pattern 1's loop (1 primary clean round + 1 adversarial Haiku sub-agent confirmation); also runnable standalone for periodic framework audits
---

# /f5-audit-framework

**Purpose:** Run the framework-wide audit. Sweeps every canonical surface against eleven dimensions (sync drift, cross-doc consistency, bidirectional coverage, reference validity, template-protocol alignment, project-doc currency, terminology consistency, content completeness, duplication/contradiction, count/claim accuracy, scope-clarity), classifies findings with CRITICAL/HIGH/MEDIUM/LOW severity per Pattern 2, and exits on **Pattern 1's loop — 1 primary clean round plus 1 adversarial Haiku sub-agent confirmation** (the `audit-checker` persona). Acts as post-implementation verification when invoked inside the framework-update flow (after `/f4-regen-framework`); also runnable standalone for periodic sweeps.

The audit's loop is Pattern 1's exit verbatim (see `templates/SHAMT_RULES.template.md` §Pattern 1): the primary agent sweeps until a clean round, then one adversarial Haiku sub-agent (`audit-checker`) re-runs the sweep with zero bias — any finding it surfaces (even a single LOW; no one-LOW allowance for the sub-agent) resets the loop. The dimensions D2 and D7/D9 then check the framework's own bodies against that same Pattern 1 definition. Findings are reported in chat only — there are no `audit_logs/{date}.md` artifacts in v2.

**Recommended models:**

- Primary issue-finding loop: Reasoning (Opus) — D2, D3, D5, D6 currency interpretation, and the synthesis-heavy new dimensions D7 (terminology), D9 (duplication/contradiction), and D11 (scope-clarity) require synthesis across many files.
- Mechanical sub-checks (D1, D4, D8, D10): Cheap (Haiku) — running the regen drift check, walking link targets, confirming file existence, grepping for stray `TODO`/`TBD`/placeholders, and cross-checking explicit counts against reality.
- Adversarial confirmation sub-agent (`audit-checker`): Cheap (Haiku) — the zero-bias re-sweep on the clean round. See [`agents/audit-checker.md`](../agents/audit-checker.md).

See [`reference/model_selection.md`](../../../../reference/model_selection.md) and [`reference/audit_dimensions.md`](../../../../reference/audit_dimensions.md).

---

## Usage

```
/f5-audit-framework [--target <dir>]
```

## Arguments

- **Slugless.** The audit is framework-wide.
- `--target <dir>` (optional) — target project root used for the D1 regen drift check. Defaults to the current working directory. Pass-through to `regenerate-framework.sh --check --target`.

## Prerequisites

- The canonical root (`shamt-core/`) is accessible from the working directory. The audit reads files under `shamt-core/templates/`, `shamt-core/reference/`, `shamt-core/host/templates/claude/`, and `shamt-core/scripts/`.
- For D1 (sync drift), `shamt-core/scripts/regenerate-framework.sh` exists and is executable.
- For D6 (project-doc currency), `.shamt-core/shamt-config.json` exists at `.shamt-core/` and either declares `doc_staleness_threshold_days` (integer) or implicitly uses the default of **60 days**. If both `.shamt-core/project-specific-files/ARCHITECTURE.md` and `.shamt-core/project-specific-files/CODING_STANDARDS.md` are missing (legitimate for an in-development shamt-core), D6 reports a structured `not-applicable` finding rather than a HIGH miss — see Step 2 (D6) below.

## The audit dimensions

| Dim | Name | What it checks | Default tier |
|-----|------|----------------|--------------|
| D1 | Sync drift | `scripts/regenerate-framework.sh --check` exits 0; no DRIFT or STALE lines | Cheap (mechanical) |
| D2 | Cross-doc consistency | The 5 patterns and global invariants in `templates/SHAMT_RULES.template.md` describe the same steps, exit criteria, and naming as the matching skill / command / persona bodies | Reasoning |
| D3 | Bidirectional coverage | Every documented pattern (in the rules file, in references) has at least one skill/command that exercises it; every skill/command body cites a pattern or rule it implements | Reasoning |
| D4 | Reference validity | Every file path, internal link target, template path, and reference doc citation across canonical files resolves on disk | Cheap (mechanical) |
| D5 | Template-protocol alignment | Each template (`spec.template.md`, `implementation_plan.template.md`, `testing_plan.template.md`, `manual_test_plan.template.md`, `context.template.md`, `code_review.template.md`, `active_artifacts.template.md`, `ticket.ado.template.md`, `ticket.github.template.md`, `architecture.template.md`, `coding_standards.template.md`, `.shamt-core/proposals/_template.md`) produces artifacts shaped exactly as the protocol that consumes it expects. The `local` tracker profile carries no ticket template (the ticket is hand-authored or PO-flow-produced); D5 records no finding for its absence | Reasoning |
| D6 | Project-doc currency | `.shamt-core/project-specific-files/ARCHITECTURE.md` and `.shamt-core/project-specific-files/CODING_STANDARDS.md` exist; their `Last Updated:` header is within `doc_staleness_threshold_days` (default 60) — header contract per [`templates/architecture.template.md`](../../../../templates/architecture.template.md) and [`templates/coding_standards.template.md`](../../../../templates/coding_standards.template.md) | Reasoning (HIGH+ findings) / Cheap (mechanical existence + date math) |
| D7 | Terminology consistency | One canonical term per concept across all canonical docs — e.g. "Quick"/"Standard" never "Small"/"Full", "Build" never "Implement", "Engineer flow" / "PO flow" used consistently. A concept named two ways in two canonical files is a finding | Reasoning |
| D8 | Content completeness | No stray `TODO` / `TBD` / `FIXME` / unfilled `[placeholder]` brackets left in canonical content (templates' intentional fill-in placeholders excepted — see the known-exceptions section of [`reference/audit_dimensions.md`](../../../../reference/audit_dimensions.md)) | Cheap (mechanical) |
| D9 | Duplication / contradiction | Two canonical files must not give conflicting instructions for the same protocol (e.g. one body says the audit sub-agent is required, another says it is not). Distinct from D2 (which checks rules↔host agreement); D9 catches host↔host and reference↔reference contradictions | Reasoning |
| D10 | Count / claim accuracy | Explicit counts and claims match reality — "11 dimensions", "5 patterns", "8 plan dimensions", phase numbers, persona counts. A body that advertises a count which no longer matches the thing it counts is a finding | Cheap (mechanical) |
| D11 | Scope-clarity / comprehension risk | Each command and skill states its scope unambiguously near its heading; no leftover migration notes, dead cross-references, or stale "(was X)" parentheticals left inline in the agent-instruction path | Reasoning |

## The audit loop (Pattern 1)

The audit runs Pattern 1's loop verbatim. Each **primary round** runs Steps 1–4: sweep D1, then D2–D11, classify and handle findings, then evaluate the round. Repeat primary rounds until one is **clean** (0 findings, or exactly 1 LOW that was fixed — the primary-round one-LOW allowance). On the first clean round, Step 5 spawns the `audit-checker` adversarial sub-agent; Step 6 exits. Any sub-agent finding (even one LOW — **no** one-LOW allowance for the sub-agent) resets the loop back to Step 1.

This replaces v2's earlier "2 consecutive clean rounds, no sub-agent" exit — the audit now confirms its clean state the same way every other validated Shamt artifact does.

### Step 1 — Run D1 (sync drift)

1. Invoke `bash shamt-core/scripts/regenerate-framework.sh --check --target {target_dir}`.
2. Outcomes:
   - **`no drift`** (exit 0) — record D1 clean.
   - **`DRIFT {path}`** lines — record one finding per path. Severity: HIGH (canonical and generated are out of sync; consumers will see the stale generated content).
   - **`STALE {path}`** lines — record one finding per path. Severity: HIGH (managed target file no longer exists canonically; regen didn't prune).
   - Script error (non-zero, no drift output) — record one CRITICAL finding (audit cannot proceed without a trustworthy D1).
3. `UNMANAGED {path} (preserved)` lines are informational, not findings.

### Step 2 — Run D2–D11 (finding identification)

For each dimension, walk the relevant files and identify findings. Apply Pattern 2 severity per finding (borderline → HIGHER). See [`reference/severity_classification.md`](../../../../reference/severity_classification.md) for examples, and [`reference/audit_dimensions.md`](../../../../reference/audit_dimensions.md) for the full D1–D11 definitions (grouped under Completeness / Correctness / Consistency), worked fix-track examples, and the known-exceptions list. ("Finding" is the audit-wide term of art; Pattern 1 uses "issue" for the same concept — they are interchangeable.)

**D2 — Cross-doc consistency.** For each pattern in `templates/SHAMT_RULES.template.md` (the 5 patterns plus the global invariants and cross-cutting principles), open the skill / command / persona bodies that claim to implement it and check:

- Step count and order match (or the body explicitly says "Summary: see canonical command body" and the summary is faithful).
- Exit criteria match.
- Naming matches (artifact names, phase names, tier names, persona names).
- Mismatch examples: Pattern 1 says a Standard-path loop needs an adversarial sub-agent confirmation but a command body omits it; rules name a phase "Build" but a skill calls it "Implement". These are HIGH.

**D3 — Bidirectional coverage.** Two passes:

1. **Rules → host.** For every pattern, command, or rule named in `templates/SHAMT_RULES.template.md` (and the reference catalog under `reference/`), confirm a corresponding skill / command / persona exists under `host/templates/claude/`. Missing implementations are HIGH (the rule is unimplementable as written).
2. **Host → rules.** For every command / skill / persona under `host/templates/claude/`, confirm its body cites at least one pattern, rule, or reference doc it implements. Orphan commands (no rule mapping) are MEDIUM (the framework grew an undocumented capability).

**D4 — Reference validity.** Mechanical walk:

- Markdown links of the form `[text](path)` in every canonical file under `shamt-core/`: confirm the target file exists. Relative paths resolve to disk; halt the audit immediately if any path leaves the canonical root unexpectedly (e.g., `../../../../../etc/passwd`-style traversal — should not occur, surface as CRITICAL if it does).
- Template references (e.g., `templates/spec.template.md`): confirm the named file exists.
- Tracker profile names referenced in command bodies (`ado`, `github`, `local`): confirm the profile file exists at `reference/trackers/{name}.md`.
- Persona references in command bodies (e.g., `plan-executor`, `validation-checker`, `test-executor`, `review-executor`): confirm `host/templates/claude/agents/{name}.md` exists.

Broken-link findings are HIGH (the rule or command sends the reader nowhere).

**D5 — Template-protocol alignment.** For each template, find the command/skill that produces or consumes it and confirm:

- Every section the protocol writes to exists in the template.
- Every section the validator reads (per `/validate-artifact`'s dimensions for that artifact type) exists in the template.
- Templates do not carry sections the protocol no longer writes (drift in the opposite direction).

Missing required sections are HIGH; orphan sections are MEDIUM.

**D6 — Project-doc currency.**

1. Read `.shamt-core/shamt-config.json`. Resolve `doc_staleness_threshold_days` (default 60).
2. Check for `.shamt-core/project-specific-files/ARCHITECTURE.md` and `.shamt-core/project-specific-files/CODING_STANDARDS.md`.
   - **Both present** — read each file's `Last Updated:` header. If absent, record HIGH (the header contract is defined in [`templates/architecture.template.md`](../../../../templates/architecture.template.md) / [`templates/coding_standards.template.md`](../../../../templates/coding_standards.template.md)). If present, compute `today - Last Updated`; if greater than the threshold, record MEDIUM (`stale doc: {path}, {N} days since Last Updated, threshold {T}`).
   - **One missing** — record HIGH (`required project doc missing: {path}`). Both are required at init per the seed-at-init contract documented in the templates above.
   - **Both missing** — distinguish via the **self-host detection rule** (same rule used by `/f4-regen-framework`): the resolved target is the shamt-core self-host iff `{target}/shamt-core/` exists and the canonical sources at `{target}/shamt-core/host/templates/claude/` match the canonical sources that produced this audit command's body (resolved by path identity).
     - If self-host (shamt-core developing itself), record a single LOW informational finding (`D6 not applicable: target is shamt-core development repo, no project docs expected`).
     - Otherwise — record CRITICAL (the project is misconfigured; the Engineer flow can't run).

**D7 — Terminology consistency.** Sweep all canonical docs for concepts named more than one way. The canonical terms are fixed by `templates/SHAMT_RULES.template.md` and the reference catalog: "Quick" / "Standard" (never "Small" / "Full"), "Build" (never "Implement" as a phase name), "Engineer flow" / "Product Owner (PO) flow", "finding" / "issue" (interchangeable by design — not a violation). A concept rendered with a non-canonical synonym in an agent-instruction path is HIGH (it sends two readers to two mental models); a one-off in a historical/aside line is MEDIUM. See [`reference/audit_dimensions.md`](../../../../reference/audit_dimensions.md) for the canonical-term table.

**D8 — Content completeness.** Mechanical grep across canonical content for stray `TODO`, `TBD`, `FIXME`, and unfilled `[placeholder]`-style brackets. **Exclude** the intentional fill-in placeholders that templates carry by design (e.g., `{slug}`, `[one-line description]` inside `templates/*.template.md`) — those are listed in the known-exceptions section of [`reference/audit_dimensions.md`](../../../../reference/audit_dimensions.md). A stray marker in a non-template canonical body is MEDIUM; in a template's instructional (non-fill) prose it is HIGH.

**D9 — Duplication / contradiction.** Look for two canonical files giving conflicting instructions for the same protocol — e.g. one command body says the audit requires a sub-agent confirmation and another says it does not; two references defining the same exit criterion differently. This is **distinct from D2**: D2 checks rules↔host agreement (does the host body faithfully implement the rule?); D9 catches host↔host and reference↔reference contradictions where neither is the rules file. A live contradiction in agent-instruction paths is HIGH; benign restatement that agrees is not a finding.

**D10 — Count / claim accuracy.** Confirm every explicit count or enumerated claim matches reality: "11 dimensions" matches the dimension table row count, "5 patterns" matches `SHAMT_RULES.template.md`, "8 plan dimensions", phase numbers (6 / 7 phases per the testing flag), persona counts in the CHEATSHEET table. A frontmatter `description` or body line advertising a count that no longer matches the thing it counts is HIGH (it regenerates into the child skill registry and misleads at a glance).

**D11 — Scope-clarity / comprehension risk.** Confirm each command and skill states its scope unambiguously near its heading, and that no leftover migration notes, dead cross-references, or stale "(was X)" / "(formerly Y)" parentheticals survive inline in the agent-instruction path. A reader hitting a stale aside mid-instruction is MEDIUM; an ambiguous or missing scope statement on a command/skill is HIGH.

### Step 3 — Classify and surface all findings; apply the two-track fix policy

Apply Pattern 2 severity per finding. Borderline classifies HIGHER. Then handle each finding per the fix policy below.

**First, resolve the target context.** Use the **same self-host detection rule D6 uses** (the resolved target is the shamt-core self-host iff `{target}/shamt-core/` exists and its canonical sources at `{target}/shamt-core/host/templates/claude/` are the ones that produced this command body, by path identity):

- **Master / self-host target** → the two-track fix policy applies (auto-fix is in scope).
- **Child project target** → the audit stays **report-only** (see below). A child's canonical sources under `.shamt-core/` are read-only imported copies of master; auto-editing them would be clobbered on the next `/sync-import-shamt` and silently diverge the child from master.

**Two-track fix policy (master / self-host target only):**

- **Simple finding → fix immediately, then verify by re-running its dimension.** A finding is *simple* only when its fix is **mechanical, single-file, AND uniquely determined by the finding** — e.g. a broken link path, a count/number correction (D10), terminology normalization to the one canonical term (D7), removing a stray `TODO`/placeholder (D8). Apply the canonical edit, then re-run that dimension to confirm the finding clears. **If the edited file is under `host/templates/claude/`, follow the fix with `/f4-regen-framework` (or re-run D1) so `.claude/` stays synced** — an unsynced auto-fix is itself a D1 finding.
- **Intricate finding → draft a `/f1-propose-update` proposal; stop short of editing.** Anything needing design judgment, coordinated multi-file edits (rule↔template↔skill), or protocol-semantic changes. The audit suggests a descriptive proposal slug and routes it through `/f1-propose-update` → `/validate-artifact` → `/f3-implement-update`; it does **not** edit canonical sources for an intricate finding.
- **Borderline → treated as intricate.** When in doubt whether a fix is uniquely determined or single-file, route it to a proposal. The three criteria above (mechanical + single-file + uniquely-determined) plus this borderline rule are the **normative boundary**; [`reference/audit_dimensions.md`](../../../../reference/audit_dimensions.md) only elaborates them with worked examples — it introduces no new boundary logic.
- **Both flow contexts.** On a master target, the auto-fix track runs in **both** standalone audits and inside the framework-update flow (Phase 6). When in-flow, apply each simple fix **and log it in chat as an out-of-band correction, explicitly distinct from the in-flight proposal's scope** — so the proposal's validated change-set and its validation footer stay clean and a reader can always tell which edits belong to the proposal versus the audit.

**Report-only policy (child project target):** surface every finding with its severity; for anything upstream-worthy, suggest routing it to master via `/f1-propose-update` → `/sync-submit-proposal`. The only edits permitted are the genuinely-local mechanical re-verifications allowed everywhere — running `/f4-regen-framework` if D1 reported drift from a missed regen, or re-running `--check` to confirm a transient error. The fix-immediately track does **not** edit a child's imported `.shamt-core/` canonical copies.

### Step 4 — Evaluate the primary round

After handling every finding per Step 3, classify the round (Pattern 1 primary-round semantics):

- **Clean round** = zero findings, OR exactly **one LOW finding** that was fixed (the primary-round one-LOW allowance).
- **Not clean** = 2+ findings, or any MEDIUM / HIGH / CRITICAL.

Then:

- **Intricate findings routed to a proposal block the loop.** If this round surfaced any intricate finding (routed to `/f1-propose-update`, not auto-fixable), the audit **cannot** reach a clean round on its own — re-sweeping won't clear a finding whose fix lives in an unimplemented proposal. State the routed proposal slug(s) and **halt the loop here**, directing the user to run the framework-update flow for them and re-audit afterward. Do not spin.
- **Not clean (only auto-fixable findings)** → the simple fixes from Step 3 have been applied; return to Step 1 and re-sweep to confirm they cleared.
- **Clean** → proceed to Step 5 (the adversarial sub-agent confirmation).

State the round result explicitly, with the per-dimension findings count (e.g., `Round 2: D1 clean, D2 1 HIGH→proposal, D4 2 LOW→fixed, D7 clean, D10 1 LOW→fixed, … rest clean. Not clean — re-sweeping.`).

### Step 5 — Adversarial sub-agent confirmation

On the first clean primary round, spawn the **`audit-checker`** sub-agent (Cheap / Haiku — see [`agents/audit-checker.md`](../agents/audit-checker.md)) to re-run the D1–D11 sweep across the canonical surface with zero bias. Pass it the target context (master / self-host vs child) and the dimension list. The sub-agent reports ANY finding it independently surfaces — **no one-LOW allowance** — and replies `CONFIRMED: Zero issues found after adversarial review.` only when it finds nothing.

- **Sub-agent finds any issue (even one LOW)** → the loop resets: fix/route per Step 3, then return to Step 1 for another primary round (which must again reach clean before the sub-agent re-runs).
- **Sub-agent confirms zero issues** → proceed to Step 6.

This is Pattern 1's exit verbatim: 1 primary clean round + 1 adversarial Haiku confirmation. The `audit-checker` persona is framework-sweep-scoped, distinct from the single-artifact-scoped `validation-checker` used by `/validate-artifact`.

### Step 6 — Exit

State the exit clearly:

```text
Framework audit complete. 1 primary clean round + audit-checker sub-agent confirmation.
Dimensions swept: D1 sync drift, D2 cross-doc consistency, D3 bidirectional
coverage, D4 reference validity, D5 template-protocol alignment, D6 project-doc
currency, D7 terminology consistency, D8 content completeness, D9 duplication/
contradiction, D10 count/claim accuracy, D11 scope-clarity.
Target: {master/self-host | child}.
Findings: {one-line summary of what was auto-fixed / routed to proposals, or "none"}.
```

**No log artifact is written.** Findings live in chat only; the conversation is the audit record (§3.6 / §3.9).

When inside the framework-update flow (after `/f4-regen-framework` on a specific proposal), suggest a context-clear and the next phase: `/clear`, then `/f6-archive-proposal {slug}`.

When standalone, no next-phase suggestion is needed.

## Exit criteria

- 1 primary clean round (0 findings or 1 LOW fixed) followed by an `audit-checker` sub-agent confirmation that independently finds nothing — Pattern 1's exit.
- All findings have been surfaced to the user; on a master/self-host target, simple findings auto-fixed (and re-verified) and intricate findings routed to proposals.

## Notes

- **Slugless** — there is no proposal slug. The audit is framework-wide regardless of how it was triggered.
- **Runnable in both contexts** — inside the framework-update flow (as Phase 6, acting as post-impl verification) and standalone (periodic sweeps, after pulling master updates, before a release). The body is identical; the only difference is the next-phase suggestion at Step 6 and the in-flow out-of-band logging of any auto-fix.
- **Pattern 1 exit, not consecutive-clean.** The audit confirms its clean state the way every validated Shamt artifact does — one primary clean round plus one adversarial Haiku (`audit-checker`) sub-agent re-sweep that resets the loop on any finding. This supersedes v2's earlier "2 consecutive clean rounds, no sub-agent" rule and keeps the audit's loop semantics word-for-word consistent with the Pattern 1 definition that D2/D7/D9 then check the framework against.
- **Two-track fix policy, master-target only.** On a master / self-host target the audit auto-fixes *simple* findings (mechanical + single-file + uniquely-determined) and re-verifies each by re-running its dimension; everything else and every borderline case routes to `/f1-propose-update`. Against a child project the audit stays report-only — its `.shamt-core/` canonical copies are imported from master and would be clobbered on the next `/sync-import-shamt`. See Step 3 and [`reference/audit_dimensions.md`](../../../../reference/audit_dimensions.md).
- **D6 has a not-applicable case** for the in-development `shamt-core/` repo itself — recorded as a single LOW informational finding, not a hard miss. Other projects must have both `.shamt-core/project-specific-files/ARCHITECTURE.md` and `.shamt-core/project-specific-files/CODING_STANDARDS.md` per the templates' seed-at-init contract.
- **Borderline severity → HIGHER** per Pattern 2. A finding that affects planning is MEDIUM; one that affects approval is HIGH. See [`reference/severity_classification.md`](../../../../reference/severity_classification.md).
- **The sub-agent is `audit-checker`, not `validation-checker`.** `validation-checker` is single-artifact-scoped ("re-read the entire artifact"); the audit is a framework-wide D1–D11 sweep, so it spawns the sweep-scoped `audit-checker` persona on the clean round.

---
Validated 2026-05-28 — 4 rounds, 1 adversarial sub-agent confirmed (Phase 8 implementation loop)

<!-- Managed by Shamt — do not edit. Regenerate from shamt-core/host/templates/claude/commands/f5-audit-framework.md. -->
