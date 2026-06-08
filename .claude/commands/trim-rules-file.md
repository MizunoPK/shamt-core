---
description: Analyze the canonical rules file (templates/SHAMT_RULES.template.md, rendered into every child CLAUDE.md) for size-reduction opportunities and author a proposal draft enumerating concrete cuts toward the size budget — without editing the rules file directly. Master / self-host only. Triggered by the D12 audit finding or run on demand.
---

# /trim-rules-file

**Purpose:** Bring the canonical rules file — `templates/SHAMT_RULES.template.md`, which renders into every child project's `CLAUDE.md` and is loaded into the AI's context on every interaction — back under its character budget while **preserving every normative rule**. The command does **not** edit the rules file directly: it analyzes the file for concrete reduction opportunities and **authors a proposal draft** so the trim goes through the normal framework-update flow (`/f1-propose-update` → `/validate-artifact` → `/f3` …) before anything lands.

Two callers:

- **The D12 audit finding** — `/f5-audit-framework` flags the rules file over `rules_size_budget_chars` and f0-captures a stub pointing here.
- **A user**, directly, to tighten the rules file on demand.

**Recommended model:** Reasoning (Opus) — distinguishing genuine redundancy / extraction candidates from load-bearing rules, and preserving every rule while cutting, is design judgment, not mechanical. See [`reference/model_selection.md`](../../../../reference/model_selection.md).

---

## Usage

```
/trim-rules-file [slug]
```

## Arguments

- `[slug]` (optional) — slug for the proposal this command authors. Defaults to `trim-rules-file`. Resolved with the same non-destructive collision rule `/f0-draft-proposal` uses (append the lowest free numeric suffix if taken in any proposal state).

## Prerequisites

- **Master / self-host only.** The rules file is master-owned; a child's `.shamt-core/templates/SHAMT_RULES.template.md` is a read-only import, and the audit that triggers this does not run in a child. Resolve the target with the self-host detection rule (a top-level `proposals/` plus canonical roots at the repo root). **In a child project, halt** and explain that the rules file is master-owned — contribute via `/f0-draft-proposal` → `/f1-propose-update` → `/sync-submit-proposal` instead.
- `templates/SHAMT_RULES.template.md` exists.
- A top-level `proposals/` directory and `proposals/_template.md` exist.

## Step-by-step

### Step 1 — Measure

1. Run `wc -m templates/SHAMT_RULES.template.md`; record the current character count.
2. Read `rules_size_budget_chars` from `shamt-config.json` (fallback **40000** when absent). The **target** is ~75% of budget (~30000 chars at the default).
3. If the file is already at or under the budget and the command was triggered by the audit, report "already within budget" and exit without authoring a proposal. When run on demand, the user may proceed to tighten further.

### Step 2 — Analyze for reductions

Read the full rules file and identify **concrete** reduction opportunities, each in one of these categories:

- **Duplication / repetition** — the same rule or explanation stated in multiple places; consolidate to one statement and cross-reference.
- **Extraction to `reference/`** — detailed examples, recipes, or expanded rationale that can move to a `reference/` doc with a one-line pointer left behind.
- **Rephrase / tighten** — verbose passages that can be said in fewer words without losing normative content.
- **Relocate to a command / skill body** — procedural detail that belongs in a specific command/skill rather than the global rules.
- **Other system improvements** — any change that reduces size while maintaining or improving clarity.

For each candidate record: the location (section + a short quote), the category, the proposed change, and an estimated character delta.

### Step 3 — Author the proposal draft

1. Resolve the proposals directory and slug (collision rule as above). If an audit-captured D12 f0 stub already addresses this (judgment — read `proposals/` in all states), **develop that stub** rather than creating a duplicate.
2. Write the draft in the `/f0-draft-proposal` file shape (so `/f1-propose-update` ingests it as an f0 draft): the title, `Status: Draft (f0 — audit capture, unrefined)`, the f0 banner, and a rich `## Scratch Notes (f0 capture)` section containing the cut list — one entry per candidate from Step 2 with its category, quote, proposed change, and char delta — plus a **running total** showing the path from the current count to the target.
3. **Quality guardrail (mandatory, stated in the draft):** every cut must be an **extraction, rephrase, or relocation** — **never a silent deletion of a normative rule**. The draft must preserve the full rule set; map each removed passage to where its content now lives (a reference doc, a command/skill body, or a tightened restatement). A cut that cannot name a destination for the rule it touches is not a valid cut.

### Step 4 — Exit

State the draft path, the current → target character counts, the estimated total reduction, and:

```
Next: /f1-propose-update {slug} to refine + number the trim proposal, then /validate-artifact.
```

## Exit criteria

- A proposal draft exists at `proposals/{slug}.md` enumerating concrete cuts toward the budget, with the rule-preservation guardrail stated.
- **No edit to `templates/SHAMT_RULES.template.md` itself** — the trim lands via the authored proposal's own framework-update flow.
- Master / self-host only; a child invocation halts at the prerequisite check.

## Notes

- **Does not edit the rules file.** The output is a proposal, so the trim is reviewed and validated before it lands — the rule-preservation guardrail is enforced by the normal flow (`/validate-artifact`, the user's review, and the next D2/D7 audit which catches a missing pattern/term), not by this command alone.
- **Reuses the f0 shape.** Writing the draft in `/f0-draft-proposal`'s shape lets `/f1-propose-update` pick it up via its f0-ingestion mode with no special-casing.
- **Fresh-agent runnable** — the rules file, the config budget, and the proposal template are sufficient. No conversation history required.

---
Created 2026-06-07 — by /f3-implement-update for proposals/08-rules-size-budget-trim-skill.md (new /trim-rules-file command + the D12 rules-file-size-budget audit dimension).

<!-- Managed by Shamt — do not edit. Regenerate from shamt-core/host/templates/claude/commands/trim-rules-file.md. -->
