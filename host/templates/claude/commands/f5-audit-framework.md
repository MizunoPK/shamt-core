---
description: Phase 6 of the framework-update flow (slugless) — sweep the framework across 11 audit dimensions, classify findings, and exit on Pattern 1's loop (1 primary clean round + 1 adversarial Haiku sub-agent confirmation); also runnable standalone for periodic framework audits
---

# /f5-audit-framework

**Purpose:** Run the framework-wide audit — a **single continuous improvement loop, master / self-host only** — that pursues two goals at once: keep applying small, targeted *simple* fixes (completeness / correctness / consistency) **and** keep surfacing *intricate* findings as proposal candidates, halting only when it can find no more of **either**. Sweeps every canonical surface against eleven dimensions (sync drift, cross-doc consistency, bidirectional coverage, reference validity, template-protocol alignment, project-doc currency, terminology consistency, content completeness, duplication/contradiction, count/claim accuracy, scope-clarity), classifies findings with CRITICAL/HIGH/MEDIUM/LOW severity per Pattern 2, auto-fixes simple findings in place and **captures each intricate finding as an f0 draft proposal** (via `/f0-draft-proposal`) so the loop continues instead of halting, and exits on **Pattern 1's exit *shape* — 1 primary clean round plus 1 adversarial Haiku sub-agent confirmation** (the `audit-checker` persona) with a *clean-round condition adapted for the capture track* (defined below). Acts as post-implementation verification when invoked inside the framework-update flow (after `/f4-regen-framework`); also runnable standalone for periodic sweeps. **Invoked in a child project it halts immediately and redirects** to `/f0-draft-proposal` → `/f1-propose-update` → `/sync-submit-proposal` (see Step 0) — the audit's two clearing actions (auto-fix, f0-capture) both require editable canonical sources, which a child's read-only imported `.shamt-core/` lacks.

The audit keeps **Pattern 1's exit *shape*** (see `templates/SHAMT_RULES.template.md` Pattern 1): the primary agent sweeps until a clean round, then one adversarial Haiku sub-agent (`audit-checker`) re-runs the sweep with zero bias and any finding it surfaces (even a single LOW; no one-LOW allowance for the sub-agent) resets the loop. But it uses an **adapted clean-round definition** for the capture track: a round is *clean* when it needed **no new auto-fix AND no new f0 draft**. Unlike canonical Pattern 1's "zero issues / one LOW" clean round, a clean *audit* round may still **report captured intricate findings** — intricate findings that already have an addressing draft in `proposals/` (the agent reads the folder and judges this, exactly as it judges every other finding). This adaptation is stated explicitly here so the audit's own D2/D9 checks do not later flag the f5 body as self-contradictory. The dimensions D2 and D7/D9 then check the framework's own bodies against the Pattern 1 definition **as adapted here**. This is the same best-effort convergence Pattern 1 already relies on — not a provably-cannot-spin guarantee. Findings are reported in chat only — there are no `audit_logs/{date}.md` artifacts in v2.

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

- The canonical root is the current working directory (the shamt-core repo root). The audit reads files under `templates/`, `reference/`, `host/templates/claude/`, and `scripts/`.
- For D1 (sync drift), `scripts/regenerate-framework.sh` exists and is executable.
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

The audit runs on **Pattern 1's exit *shape*** with a clean-round condition adapted for the capture track (see Purpose above). **Step 0** confirms the target is master / self-host (in a child the command halts and redirects — it does not sweep). Each **primary round** then runs Steps 1–4: sweep D1, then D2–D11, classify and handle findings (auto-fix simple, f0-capture intricate), then evaluate the round. Repeat primary rounds until one is **clean** — it needed **no new auto-fix AND no new f0 draft**. A clean round may still *report* intricate findings that already have an addressing draft in `proposals/`; this is the deliberate difference from canonical Pattern 1's "zero issues / one LOW" clean round. On the first clean round, Step 5 spawns the `audit-checker` adversarial sub-agent; Step 6 exits. Any sub-agent finding that is a **new simple finding or a genuinely-uncaptured intricate finding** (even one LOW — **no** one-LOW allowance for the sub-agent) resets the loop back to Step 1; an already-addressed intricate finding the primary captured this run does **not** reset it.

This keeps the audit's exit *shape* aligned with Pattern 1 — the way every other validated Shamt artifact confirms its clean state — superseding v2's earlier "2 consecutive clean rounds, no sub-agent" exit. Only the clean-round *condition* is adapted, and that adaptation is stated explicitly throughout this body so the audit's own D2/D9 checks do not flag it as self-contradictory.

### Step 0 — Confirm target context (master / self-host only)

Before sweeping anything, resolve the target context using the **self-host detection rule** D6 uses — the same master-vs-child signal `/f1-propose-update` and `/sync-triage-proposals` use: the resolved target is the shamt-core self-host iff a top-level `{target}/proposals/` directory is present (corroborated by canonical sources at the root — `{target}/host/templates/claude/`, `{target}/templates/`, `{target}/scripts/regenerate-framework.sh`); it is a child project iff `{target}/.shamt-core/` carries the imported copy:

- **Master / self-host target** → proceed to Step 1. The continuous dual-track loop (auto-fix simple findings + f0-capture intricate findings) runs only here, where canonical sources are editable.
- **Child project target** → **halt immediately.** Do not sweep, auto-fix, capture, or run the sub-agent — not even a D1-only drift check. Print the redirect:

  ```text
  /f5-audit-framework does not run in a child project. A child's .shamt-core/
  canonical sources are read-only imported copies of master, so the audit's two
  clearing actions (auto-fix, f0-capture) are both unavailable here.
  To contribute a framework change from this project:
    1. /f0-draft-proposal {slug} [blurb]   — quick-capture the idea
    2. /f1-propose-update {slug}            — flesh it out
    3. /sync-submit-proposal {slug}         — send it upstream to master
  Local drift (canonical -> .claude/) is covered by /sync-import-shamt's regen
  and by /f4-regen-framework --check.
  ```

This early check is the **single** child guard; the rest of the body assumes a master / self-host target and carries no per-finding child branch.

### Step 1 — Run D1 (sync drift)

1. Invoke `bash scripts/regenerate-framework.sh --check --target {target_dir}`.
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

- Markdown links of the form `[text](path)` in every canonical file under the repo root: confirm the target file exists. Relative paths resolve to disk; halt the audit immediately if any path leaves the canonical root unexpectedly (e.g., `../../../../../etc/passwd`-style traversal — should not occur, surface as CRITICAL if it does).
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
   - **Both missing** — distinguish via the **self-host detection rule** (same rule used by `/f4-regen-framework`): the resolved target is the shamt-core self-host iff a top-level `{target}/proposals/` directory is present (corroborated by canonical sources at the root — `{target}/host/templates/claude/`, `{target}/templates/`, `{target}/scripts/regenerate-framework.sh`); it is a child project iff `{target}/.shamt-core/` carries the imported copy.
     - If self-host (shamt-core developing itself), record a single LOW informational finding (`D6 not applicable: target is shamt-core development repo, no project docs expected`).
     - Otherwise — record CRITICAL (the project is misconfigured; the Engineer flow can't run).

**D7 — Terminology consistency.** Sweep all canonical docs for concepts named more than one way. The canonical terms are fixed by `templates/SHAMT_RULES.template.md` and the reference catalog: "Quick" / "Standard" (never "Small" / "Full"), "Build" (never "Implement" as a phase name), "Engineer flow" / "Product Owner (PO) flow", "finding" / "issue" (interchangeable by design — not a violation). A concept rendered with a non-canonical synonym in an agent-instruction path is HIGH (it sends two readers to two mental models); a one-off in a historical/aside line is MEDIUM. See [`reference/audit_dimensions.md`](../../../../reference/audit_dimensions.md) for the canonical-term table.

**D8 — Content completeness.** Mechanical grep across canonical content for stray `TODO`, `TBD`, `FIXME`, and unfilled `[placeholder]`-style brackets. **Exclude** the intentional fill-in placeholders that templates carry by design (e.g., `{slug}`, `[one-line description]` inside `templates/*.template.md`) — those are listed in the known-exceptions section of [`reference/audit_dimensions.md`](../../../../reference/audit_dimensions.md). A stray marker in a non-template canonical body is MEDIUM; in a template's instructional (non-fill) prose it is HIGH.

**D9 — Duplication / contradiction.** Look for two canonical files giving conflicting instructions for the same protocol — e.g. one command body says the audit requires a sub-agent confirmation and another says it does not; two references defining the same exit criterion differently. This is **distinct from D2**: D2 checks rules↔host agreement (does the host body faithfully implement the rule?); D9 catches host↔host and reference↔reference contradictions where neither is the rules file. A live contradiction in agent-instruction paths is HIGH; benign restatement that agrees is not a finding.

**D10 — Count / claim accuracy.** Confirm every explicit count or enumerated claim matches reality: "11 dimensions" matches the dimension table row count, "5 patterns" matches `SHAMT_RULES.template.md`, "8 plan dimensions", phase numbers (6 / 7 phases per the testing flag), persona counts in the CHEATSHEET table. A frontmatter `description` or body line advertising a count that no longer matches the thing it counts is HIGH (it regenerates into the child skill registry and misleads at a glance).

**D11 — Scope-clarity / comprehension risk.** Confirm each command and skill states its scope unambiguously near its heading, and that no leftover migration notes, dead cross-references, or stale "(was X)" / "(formerly Y)" parentheticals survive inline in the agent-instruction path. A reader hitting a stale aside mid-instruction is MEDIUM; an ambiguous or missing scope statement on a command/skill is HIGH.

### Step 3 — Classify and handle every finding (dual-track: auto-fix + f0-capture)

Apply Pattern 2 severity per finding. Borderline classifies HIGHER. The target is master / self-host (Step 0 already halted a child), so both clearing tracks are in scope. Handle each finding per the policy below.

**Dual-track fix policy:**

- **Simple finding → fix immediately, then verify by re-running its dimension.** A finding is *simple* only when its fix is **mechanical, single-file, AND uniquely determined by the finding** — e.g. a broken link path, a count/number correction (D10), terminology normalization to the one canonical term (D7), removing a stray `TODO`/placeholder (D8). Apply the canonical edit, then re-run that dimension to confirm the finding clears. **If the edited file is under `host/templates/claude/`, follow the fix with `/f4-regen-framework` (or re-run D1) so `.claude/` stays synced** — an unsynced auto-fix is itself a D1 finding.
- **Intricate finding → capture it as an f0 draft, then continue (do not implement the fix).** Anything needing design judgment, coordinated multi-file edits (rule↔template↔skill), or protocol-semantic changes. Handle it in two sub-steps:
  1. **Check for an existing addressing draft.** Read `proposals/` in **all** states (active top level + `archive/`, `rejected/`, `deferred/`, `submitted/`, `already-merged/` where present) and **judge** whether a draft already covers this finding — the same judgment Pattern 1 uses for finding identity and severity throughout the loop, **not** a mechanical key match.
     - **A draft already addresses it** → the finding is **captured**: report it (slug + one-line description), do **not** re-draft, and it does **not** reset the loop.
     - **No draft addresses it** → **capture it now** via `/f0-draft-proposal {descriptive-slug} {one-line finding blurb}`. This writes a new f0 draft — which counts as a *new draft*, so the round is **not** clean and a re-sweep follows. Report the created slug.
  2. The audit **never** implements an intricate fix in place — its fix lives in the captured draft, fleshed out later by `/f1-propose-update {slug}` → `/validate-artifact` → `/f3-implement-update`.
- **Borderline → treated as intricate.** When in doubt whether a fix is uniquely determined or single-file, capture it as an f0 draft rather than auto-fixing. The three criteria above (mechanical + single-file + uniquely-determined) plus this borderline rule are the **normative boundary**; [`reference/audit_dimensions.md`](../../../../reference/audit_dimensions.md) only elaborates them with worked examples — it introduces no new boundary logic.
- **In-flow logging (folded into the proposal's landing commit).** When the audit runs as Phase 6 of the framework-update flow, a proposal is already in flight. **Both** clearing actions — each simple auto-fix **and** each f0 draft captured — are logged in chat so a reader can always tell which edits/drafts came from the audit versus the proposal. They are **not** held out of the proposal's scope, however: audit auto-fixes (and their regen output) and captured f0 stubs **ride into the in-flight proposal's landing commit and squash-merge** at `/f6-archive-proposal` (Phase 7). The chat log is for attribution/traceability, not a hard scope boundary — no commit-body audit marker is added; the git diff of the squash commit is the durable record.

### Step 4 — Evaluate the primary round

After handling every finding per Step 3, classify the round using the **adapted clean-round condition**:

- **Clean round** = this round needed **no new auto-fix AND no new f0 draft**. It may still *report* intricate findings that already had an addressing draft (those are *captured*, not new) — that is the deliberate difference from canonical Pattern 1's "zero issues / one LOW" clean round.
- **Not clean** = this round applied at least one auto-fix, OR captured at least one **new** intricate finding as a fresh f0 draft.

Then:

- **Not clean** → return to Step 1 and re-sweep. A re-sweep confirms the simple fixes cleared **and** confirms each freshly-captured intricate finding is now recognized as already-addressed (so it no longer counts as new). The loop **continues** — it does not halt on an intricate finding the way the prior design did. Capture-and-continue is exactly what lets the audit pursue both tracks (simple fixes + proposal candidates) to exhaustion in one run.
- **Clean** → proceed to Step 5 (the adversarial sub-agent confirmation).

The loop converges on agent judgment, exactly as Pattern 1 does — no round cap, no separate dedup machinery, and **no claim that it provably cannot spin**. A re-detected intricate finding is recognized as already-captured (by reading `proposals/`) and so stops resetting the loop; a rare duplicate draft is harmless and user-reviewable.

State the round result explicitly, with the per-dimension findings count and how each was handled (e.g., `Round 2: D1 clean, D2 1 HIGH→f0 draft "audit-rule-skill-mismatch", D4 2 LOW→fixed, D7 clean, D9 1 HIGH→already captured ("audit-loop-spins"), D10 1 LOW→fixed, … rest clean. Not clean (new draft + auto-fixes) — re-sweeping.`).

### Step 5 — Adversarial sub-agent confirmation

On the first clean primary round, spawn the **`audit-checker`** sub-agent (Cheap / Haiku — see [`agents/audit-checker.md`](../agents/audit-checker.md)) to re-run the D1–D11 sweep across the canonical surface with zero bias. Pass it:

- the **target context** — always master / self-host (a child already halted at Step 0);
- the **dimension list**; and
- the **findings captured this run** — each intricate finding the primary captured, as a one-line description + its draft slug — so the sub-agent, like the primary, does **not** reset on an intricate finding that already has an addressing draft.

The sub-agent also reads `proposals/` itself for pre-existing addressing drafts. It reports ANY finding it independently surfaces — **no one-LOW allowance** — and replies `CONFIRMED: Zero issues found after adversarial review.` only when it finds nothing resettable.

- **Sub-agent surfaces a new simple finding or a genuinely-uncaptured intricate finding (even one LOW)** → the loop resets: handle it per Step 3 (auto-fix or f0-capture), then return to Step 1 for another primary round (which must again reach clean before the sub-agent re-runs).
- **Sub-agent reports only already-captured intricate findings, or nothing** → it does not reset the loop; proceed to Step 6.

This is Pattern 1's exit *shape* with the capture-track adaptation: 1 primary clean round + 1 adversarial Haiku confirmation. The `audit-checker` persona is framework-sweep-scoped, distinct from the single-artifact-scoped `validation-checker` used by `/validate-artifact`.

### Step 6 — Exit

State the exit clearly:

```text
Framework audit complete. 1 primary clean round + audit-checker sub-agent confirmation.
Dimensions swept: D1 sync drift, D2 cross-doc consistency, D3 bidirectional
coverage, D4 reference validity, D5 template-protocol alignment, D6 project-doc
currency, D7 terminology consistency, D8 content completeness, D9 duplication/
contradiction, D10 count/claim accuracy, D11 scope-clarity.
Target: master / self-host.
Findings: {one-line summary of what was auto-fixed, or "none"}.
f0 drafts captured this run: {comma-separated slugs, or "none"}.
Already-captured intricate findings reported: {slugs, or "none"}.
```

The **f0 drafts captured this run** line is the audit's hand-off to the framework-update flow: each captured draft is an intricate finding awaiting `/f1-propose-update {slug}` to flesh it out. The audit does not run that flow — it reports the slugs and lets the user prioritize.

**No log artifact is written.** Findings live in chat only; the conversation is the audit record.

When inside the framework-update flow (after `/f4-regen-framework` on a specific proposal), suggest a context-clear and the next phase: `/clear`, then `/f6-archive-proposal {slug}`.

When standalone, no next-phase suggestion is needed.

## Exit criteria

- 1 primary clean round (**no new auto-fix and no new f0 draft** — it may still report already-captured intricate findings) followed by an `audit-checker` sub-agent confirmation that surfaces nothing resettable — Pattern 1's exit *shape* with the capture-track adaptation.
- All findings surfaced; simple findings auto-fixed (and re-verified), intricate findings captured as f0 drafts (or reported as already-captured). Master / self-host only — a child invocation halts at Step 0 and redirects.
- Each f0 draft captured this run is reported by slug for later `/f1-propose-update {slug}`.

## Notes

- **Slugless** — there is no proposal slug. The audit is framework-wide regardless of how it was triggered.
- **Master / self-host only.** The continuous loop and its two clearing actions (auto-fix, f0-capture) run only where canonical sources are editable. Invoked in a child the command halts at **Step 0** and redirects to `/f0-draft-proposal` → `/f1-propose-update` → `/sync-submit-proposal` — a child's `.shamt-core/` canonical copies are read-only imports of master, so there is nothing local to fix and no local loop to converge. Local drift in a child is covered instead by `/sync-import-shamt`'s regen and `/f4-regen-framework --check`.
- **Runnable in two flow contexts** (both master / self-host) — inside the framework-update flow (as Phase 6, acting as post-impl verification) and standalone (periodic sweeps, after pulling master updates, before a release). The body is identical; the only differences are the next-phase suggestion at Step 6 and the in-flow logging of every auto-fix **and** every f0 draft captured (each folded into the in-flight proposal's landing commit, not held separate from it).
- **Pattern 1 exit *shape*, adapted clean-round.** The audit confirms its clean state with Pattern 1's *shape* — one primary clean round plus one adversarial Haiku (`audit-checker`) sub-agent re-sweep — but with an adapted clean-round *condition*: clean = no new auto-fix and no new f0 draft, which may still *report* already-captured intricate findings. This supersedes v2's earlier "2 consecutive clean rounds, no sub-agent" rule. The adaptation is stated explicitly throughout this body (Purpose, the audit-loop intro, Steps 4–6) so the D2/D7/D9 dimensions the audit runs against its own bodies do not flag it as a self-contradiction.
- **Dual-track fix policy.** The audit auto-fixes *simple* findings (mechanical + single-file + uniquely-determined) and re-verifies each by re-running its dimension; everything else and every borderline case is **captured as an f0 draft** (`/f0-draft-proposal`) — reported and then continued past, not implemented in place. Before capturing, the audit reads `proposals/` (all states) and skips findings that already have an addressing draft (judgment, not a key match). See Step 3 and [`reference/audit_dimensions.md`](../../../../reference/audit_dimensions.md).
- **D6 has a not-applicable case** for the in-development `shamt-core/` repo itself — recorded as a single LOW informational finding, not a hard miss. Other projects must have both `.shamt-core/project-specific-files/ARCHITECTURE.md` and `.shamt-core/project-specific-files/CODING_STANDARDS.md` per the templates' seed-at-init contract.
- **Borderline severity → HIGHER** per Pattern 2. A finding that affects planning is MEDIUM; one that affects approval is HIGH. See [`reference/severity_classification.md`](../../../../reference/severity_classification.md).
- **The sub-agent is `audit-checker`, not `validation-checker`.** `validation-checker` is single-artifact-scoped ("re-read the entire artifact"); the audit is a framework-wide D1–D11 sweep, so it spawns the sweep-scoped `audit-checker` persona on the clean round.

---
Validated 2026-05-28 — 4 rounds, 1 adversarial sub-agent confirmed (Phase 8 implementation loop)
Touched 2026-06-02 — continuous dual-track loop: intricate findings captured as f0 drafts (capture-and-continue) instead of halting; early Step 0 child halt-and-redirect; child report-only mode removed; Pattern 1 exit *shape* with adapted clean-round. Per proposals/audit-continuous-f0-draft-capture.md.

<!-- Managed by Shamt — do not edit. Regenerate from shamt-core/host/templates/claude/commands/f5-audit-framework.md. -->
