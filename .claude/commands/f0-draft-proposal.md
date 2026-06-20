---
description: Phase 0 (optional) of the framework-update flow — quick-capture an unrefined DRAFT proposal at proposals/{slug}.md (child: .shamt-core/proposals/{slug}.md) from a one-line blurb, with no open-questions dialog and no formal change list. Used by the audit to capture intricate findings, and by users for fast idea capture.
---

# /f0-draft-proposal

**Purpose:** Quickly create a bare-minimum **DRAFT** proposal file — a title plus the supplied `blurb` written into a **Scratch Notes (f0 capture)** section — marked as an unrefined audit/idea capture. f0 runs **no** open-questions dialog and writes **no** formal Proposed Changes table; it is the fast pre-proposal stage. The full drafting pass (Problem + Proposed Changes + Risks / Rollback / Validation Considerations, with the open-questions dialog) is deferred to `/f1-propose-update {slug}`, which ingests an f0 draft as its intake.

Two callers use f0:

- **The framework audit** (`/f5-audit-framework`, master / self-host only) drafts one f0 proposal per *intricate* finding so the continuous loop can capture it and move on instead of halting.
- **A user**, directly, for fast idea capture — the only audit-side framework-update activity available in a child project (the audit itself does not run there; see Notes).

**Recommended model:** Cheap (Haiku). f0 is mechanical: resolve a slug, seed a file from the template, drop the blurb into Scratch Notes. No design judgment. See [`reference/model_selection.md`](../../../../reference/model_selection.md).

---

## Usage

```
/f0-draft-proposal {slug} [blurb]
```

## Arguments

- `{slug}` (required) — descriptive kebab-case slug for the proposal (e.g., `audit-loop-spins-on-intricate`, `add-mermaid-recipe`). Descriptive, not numbered — no SHAMT-N convention.
- `[blurb]` (optional) — free-text describing the idea or audit finding. Written verbatim (or lightly tidied) into the **Scratch Notes (f0 capture)** section. May name implicated canonical files informally. If omitted, f0 writes an empty Scratch Notes section with a fill-in prompt.

## Prerequisites

- A proposals directory is reachable: a top-level `proposals/` (master / self-host) **or** `.shamt-core/proposals/` (a project with a synced framework, child-side). If neither exists, halt and direct the user to run this from the shamt-core repo root or install Shamt first.
- `proposals/_template.md` (child: `.shamt-core/proposals/_template.md`) exists. If not, halt and report — the template is the source of truth for proposal shape, including the f0-draft marker convention.

## Slug resolution

Proposals are **flat files**, not folders. f0 resolves the proposals directory the same way `/f1-propose-update` does: prefer a top-level `proposals/` (master / self-host); otherwise use `.shamt-core/proposals/` (child). The target file is `{proposals-dir}/{slug}.md`.

**Slug-collision rule — non-destructive, non-interactive.** f0 **never overwrites** and **never prompts**. Before writing, check whether `{slug}.md` already exists in **any** proposal state — the active top level **and** the `archive/`, `rejected/`, `deferred/`, `submitted/`, and `already-merged/` subfolders (whichever exist for this side). If the bare slug is taken anywhere, append the lowest free numeric suffix — `{slug}-2`, then `{slug}-3`, … — and use that for the filename. Report the final slug actually written.

> Recognizing whether an **addressing draft already exists for a given finding** is the *caller's* judgment, not a mechanical check inside f0. The audit reads `proposals/` (all states) and judges whether a draft already covers a finding *before* deciding to call f0 — see [`commands/f5-audit-framework.md`](f5-audit-framework.md). f0's collision rule only guarantees it never clobbers an existing file; it makes no claim about semantic duplicates.

## Step-by-step

### Step 1 — Resolve the target path

1. Resolve the proposals directory (master top-level `proposals/` vs child `.shamt-core/proposals/`).
2. Apply the slug-collision rule above to pick the final filename. Record the final slug.

### Step 2 — Seed a bare-minimum f0 draft

1. Read the proposal template (`_template.md`) for the current shape, including the **f0-draft capture variant** comment in the header block and the **Scratch Notes (f0 capture)** comment under Problem.
2. Write `{proposals-dir}/{final-slug}.md` with:
   - **Title:** `# Proposal: {final-slug}`.
   - **Header block:** `Created: {today's YYYY-MM-DD}`; **`Status: Draft (f0 — audit capture, unrefined)`** (the distinct f0 marker — not plain `Draft`); `Proposed by:` / `Project context:` filled for a child-authored capture, blank for master-local.
   - **Banner line** immediately under the header block:

     ```text
     > **f0 DRAFT — unrefined capture.** Quick-captured by the framework audit
     > or a user; not yet through the open-questions dialog. Run
     > `/f1-propose-update {final-slug}` to flesh it out.
     ```

   - **A `## Scratch Notes (f0 capture)` section** holding the `blurb` verbatim (or lightly tidied), with any implicated canonical files mentioned informally inline. If no blurb was supplied, write a one-line fill-in prompt.
   - Leave the formal **Proposed Changes** table and the **Risks / Rollback Plan / Validation Considerations** sections as template placeholders. **Do not** fill a change list, run the open-questions dialog, or append a validation footer — all of that is f1's job.

### Step 3 — Exit

State the exit clearly:

```text
f0 draft captured at {proposals-dir}/{final-slug}.md (Status: Draft (f0 — audit capture, unrefined)).
{If the slug was suffixed: note the requested slug was taken and the draft was written as {final-slug}.}
Unrefined — no open-questions dialog ran and no change list was written.
Next: /f1-propose-update {final-slug} to flesh it out{, then /sync-proposals to send it upstream (batch, slugless) — child only}.
```

When f0 is invoked **by the audit** per intricate finding, no next-command suggestion is printed for the user — the audit reports the captured draft slug in its own loop output and continues sweeping.

## Exit criteria

- `{proposals-dir}/{final-slug}.md` exists, non-empty, carrying the f0 marker status, the banner, and a Scratch Notes section.
- No formal change list, no open-questions dialog, no validation footer (those belong to `/f1-propose-update` and `/validate-artifact`).
- The final slug actually written has been reported (including any collision suffix).

## Notes

- **No open-questions dialog.** f0 is deliberately fast and unrefined. Surfacing forks one-at-a-time and resolving them is `/f1-propose-update`'s job (Principle 2 applies there, not here).
- **Non-destructive by construction.** The collision rule appends a numeric suffix rather than overwriting or prompting, so an audit run capturing many findings — or two runs capturing the same idea — can never clobber an existing proposal. A rare duplicate draft is a harmless, user-reviewable outcome.
- **Addressing-draft recognition is the caller's job.** f0 does not decide whether a finding is already covered by an existing draft; the audit makes that judgment by reading `proposals/` before calling f0. f0 only guarantees non-destructive file creation.
- **Master and child both run f0 *the command*; only the audit is master-only.** Creating a new proposal file is not editing an imported canonical copy, so a child user may run `/f0-draft-proposal` (then `/f1-propose-update`, then `/sync-proposals`) directly. But `/f5-audit-framework` does **not** run in a child, so f0 is never *audit-driven* there — only user-driven.
- **Fresh-agent runnable** — the template and the supplied blurb are sufficient. No conversation history required.

---
Created 2026-06-02 — by /f3-implement-update for proposals/audit-continuous-f0-draft-capture.md (Phase 0 of the framework-update flow). Verified under the proposal's Phase 6 /f5-audit-framework sweep.

<!-- Managed by Shamt — do not edit. Regenerate from shamt-core/host/templates/claude/commands/f0-draft-proposal.md. -->
