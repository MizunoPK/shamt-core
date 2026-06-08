# Implementation Plan — rules-size-budget-trim-skill (#08)

**Created:** 2026-06-07
**Proposal:** `proposals/08-rules-size-budget-trim-skill.md` (Validated 2026-06-07)
**Altitude:** Framework-update (Part 3). Executor: `plan-executor` (Haiku) via `/f3-implement-update` architect/builder path.
**Base branch:** `main`

---

## Planning Status

- **Blocked on proposal:** None — proposal validated, 9 rows, all locate strings exact-quoted below.
- **Blocked on open questions:** None.
- **Ready for mechanical validation:** [x] Yes — Step 0 branch; the D12 count-ripple is a set of exact textual EDITs; Steps 6–7 are CREATEs with full file content given inline; no optional branches.

---

## Pre-Execution Checklist

- [ ] **Proposal branch** `proposal/08-rules-size-budget-trim-skill` created from `main` (Step 0). Halt if it already exists.
- [ ] All 7 EDIT-target paths exist on disk (verified at plan time); the 2 CREATE paths do not yet exist.
- [ ] No unresolved optional branches.
- [ ] **Hard rule:** edits go to canonical sources only — **never** `.claude/`. Every path below is under `host/templates/claude/`, `reference/`, or a root canonical doc (`README.md`, `shamt-config.example.json`).
- [ ] Review-Prevention Gate Mapping: **N/A at framework altitude** (no app code, data, auth, tenancy, infra, or tests — documentation + agent-instruction edits and two new command/skill bodies).
- [ ] Plan validated (Phase 2 footer present).

---

## Files Touched (manifest)

| Operation | Path |
|-----------|------|
| BRANCH | `proposal/08-rules-size-budget-trim-skill` (from `main`) |
| EDIT | `reference/audit_dimensions.md` |
| EDIT | `host/templates/claude/commands/f5-audit-framework.md` |
| EDIT | `host/templates/claude/skills/f5-audit-framework/SKILL.md` |
| EDIT | `host/templates/claude/agents/audit-checker.md` |
| EDIT | `reference/model_selection.md` |
| CREATE | `host/templates/claude/commands/trim-rules-file.md` |
| CREATE | `host/templates/claude/skills/trim-rules-file/SKILL.md` |
| EDIT | `shamt-config.example.json` |
| EDIT | `README.md` |

No optional rows. If a path is not in this manifest, it must not be created or edited during execution.

---

## Review Prevention Gate Mapping

**N/A — framework-update altitude.** Every step is a documentation / agent-instruction edit or a new command/skill body. No regulated data, tenant isolation, auth/route, database, infrastructure, frontend, test, or security-check surface is touched. No gate applies.

---

## Implementation Steps

### Step 0: Create the proposal branch
**Operation:** BRANCH
**Details:**
- Run: `git checkout -b proposal/08-rules-size-budget-trim-skill` from `main`.
- If the branch already exists, stop and report (do not overwrite/reset).

**Verification:** `git branch --show-current` prints `proposal/08-rules-size-budget-trim-skill`.

---

### Step 1: Add D12 to `reference/audit_dimensions.md` + count ripple (Proposed Changes row 1)
**Operation:** EDIT
**File:** `reference/audit_dimensions.md`
**Details — five replacements:**
- **1a (title, line 1):**
  - Locate: `# Framework Audit Dimensions (D1–D11)`
  - Replace: `# Framework Audit Dimensions (D1–D12)`
- **1b (purpose, line 5):**
  - Locate: `Full definitions of the eleven audit dimensions grouped under the three C's`
  - Replace: `Full definitions of the twelve audit dimensions grouped under the three C's`
- **1c (add the D12 row to the Completeness table — append after the D8 row):**
  - Locate: `` `| D8 | Content completeness | No half-finished content — no stray `TODO` / `TBD` / `FIXME` / unfilled `[placeholder]` left in a canonical body. |` ``
  - Replace:
    ```
    | D8 | Content completeness | No half-finished content — no stray `TODO` / `TBD` / `FIXME` / unfilled `[placeholder]` left in a canonical body. |
    | D12 | Rules-file size budget | The canonical rules file (`templates/SHAMT_RULES.template.md`, rendered into every child `CLAUDE.md`) stays within `rules_size_budget_chars` (default 40000 chars) — small enough to load economically into context on every interaction. Over budget is **always intricate** (trimming needs judgment) → f0-capture pointing at `/trim-rules-file`, never auto-fixed. |
    ```
- **1d (D10 row example, line 30 — "11 dimensions" → "12 dimensions"):**
  - Locate: `| D10 | Count / claim accuracy | Every explicit count or enumerated claim matches reality — "11 dimensions", "5 patterns", "8 plan dimensions", phase numbers, persona counts. |`
  - Replace: `| D10 | Count / claim accuracy | Every explicit count or enumerated claim matches reality — "12 dimensions", "5 patterns", "8 plan dimensions", phase numbers, persona counts. |`
- **1e (D10 worked example, line 69):**
  - Locate: `after the table grew to eleven`
  - Replace: `after the table grew to twelve`

**Verification:** `grep -cE "D1.D11|eleven|\"11 dimensions\"" reference/audit_dimensions.md` → `0`; `grep -c "| D12 | Rules-file size budget |" reference/audit_dimensions.md` → `1`.

---

### Step 2: Add D12 to the f5 command + count/range ripple (row 2)
**Operation:** EDIT
**File:** `host/templates/claude/commands/f5-audit-framework.md`
**Details — eleven replacements:**
- **2a (frontmatter, line 2):**
  - Locate: `sweep the framework across 11 audit dimensions`
  - Replace: `sweep the framework across 12 audit dimensions`
- **2b (purpose parenthetical, line 7):**
  - Locate: `Sweeps every canonical surface against eleven dimensions (sync drift, cross-doc consistency, bidirectional coverage, reference validity, template-protocol alignment, project-doc currency, terminology consistency, content completeness, duplication/contradiction, count/claim accuracy, scope-clarity),`
  - Replace: `Sweeps every canonical surface against twelve dimensions (sync drift, cross-doc consistency, bidirectional coverage, reference validity, template-protocol alignment, project-doc currency, terminology consistency, content completeness, duplication/contradiction, count/claim accuracy, scope-clarity, rules-file size budget),`
- **2c (D10 table row, line 51 — "11 dimensions" → "12 dimensions"):**
  - Locate: `| D10 | Count / claim accuracy | Explicit counts and claims match reality — "11 dimensions", "5 patterns", "8 plan dimensions", phase numbers, persona counts. A body that advertises a count which no longer matches the thing it counts is a finding | Cheap (mechanical) |`
  - Replace: `| D10 | Count / claim accuracy | Explicit counts and claims match reality — "12 dimensions", "5 patterns", "8 plan dimensions", phase numbers, persona counts. A body that advertises a count which no longer matches the thing it counts is a finding | Cheap (mechanical) |`
- **2d (add the D12 row to the dimension table — append after the D11 row):**
  - Locate: `| D11 | Scope-clarity / comprehension risk | Each command and skill states its scope unambiguously near its heading; no leftover migration notes, dead cross-references, or stale "(was X)" parentheticals left inline in the agent-instruction path | Reasoning |`
  - Replace:
    ```
    | D11 | Scope-clarity / comprehension risk | Each command and skill states its scope unambiguously near its heading; no leftover migration notes, dead cross-references, or stale "(was X)" parentheticals left inline in the agent-instruction path | Reasoning |
    | D12 | Rules-file size budget | `wc -m templates/SHAMT_RULES.template.md` is within `rules_size_budget_chars` (default 40000); over budget is a finding | Cheap (mechanical) |
    ```
- **2e (audit-loop prose, line 56):**
  - Locate: `runs Steps 1–4: sweep D1, then D2–D11, classify and handle findings`
  - Replace: `runs Steps 1–4: sweep D1, then D2–D12, classify and handle findings`
- **2f (Step 2 heading, line 91):**
  - Locate: `### Step 2 — Run D2–D11 (finding identification)`
  - Replace: `### Step 2 — Run D2–D12 (finding identification)`
- **2g (definitions pointer, line 93):**
  - Locate: `for the full D1–D11 definitions (grouped under Completeness / Correctness / Consistency)`
  - Replace: `for the full D1–D12 definitions (grouped under Completeness / Correctness / Consistency)`
- **2h (add the D12 detail subsection — insert immediately before the Step 3 heading):**
  - Locate: `### Step 3 — Classify and handle every finding (dual-track: auto-fix + f0-capture)`
  - Replace:
    ```
    **D12 — Rules-file size budget.** Measure the canonical rules file with `wc -m templates/SHAMT_RULES.template.md` and compare to `rules_size_budget_chars` read from `shamt-config.json` (fallback **40000** when the key is absent). The rules file renders into every child `CLAUDE.md`, so its size is a recurring per-interaction context cost. Over budget is a **MEDIUM** finding and is **always intricate** — trimming requires judgment (de-duplicate, extract to `reference/`, rephrase, relocate detail into command/skill bodies) and is never auto-fixed. Capture it as an f0 draft (Step 3) pointing at `/trim-rules-file`, the dedicated command that authors the detailed reduction proposal.

    ### Step 3 — Classify and handle every finding (dual-track: auto-fix + f0-capture)
    ```
- **2i (D10 prose example, line 140):**
  - Locate: `"11 dimensions" matches the dimension table row count`
  - Replace: `"12 dimensions" matches the dimension table row count`
- **2j (sub-agent re-sweep, line 177):**
  - Locate: `to re-run the D1–D11 sweep across the canonical surface with zero bias. Pass it:`
  - Replace: `to re-run the D1–D12 sweep across the canonical surface with zero bias. Pass it:`
- **2k (sub-agent rationale, line 229):**
  - Locate: `the audit is a framework-wide D1–D11 sweep, so it spawns the sweep-scoped`
  - Replace: `the audit is a framework-wide D1–D12 sweep, so it spawns the sweep-scoped`

**Verification:** `grep -cE "D1.D11|D2.D11|eleven|11 (audit )?dimension|\"11 dimensions\"" host/templates/claude/commands/f5-audit-framework.md` → `0`; `grep -c "**D12 — Rules-file size budget.**" host/templates/claude/commands/f5-audit-framework.md` → `1`; `grep -c "| D12 | Rules-file size budget |" host/templates/claude/commands/f5-audit-framework.md` → `1`.

---

### Step 3: Add D12 to the f5 skill summary + renumber + count ripple (row 3 — pairs with Step 2)
**Operation:** EDIT
**File:** `host/templates/claude/skills/f5-audit-framework/SKILL.md`
**Details — seven replacements:**
- **3a (frontmatter "eleven", line 5):**
  - Locate: `surface across eleven dimensions — D1 sync drift, D2 cross-doc consistency,`
  - Replace: `surface across twelve dimensions — D1 sync drift, D2 cross-doc consistency,`
- **3b (frontmatter enumeration — append D12 after the D11 name):**
  - Locate: `scope-clarity — classifies findings with CRITICAL/HIGH/MEDIUM/LOW per`
  - Replace: `scope-clarity, D12 rules-file size budget — classifies findings with CRITICAL/HIGH/MEDIUM/LOW per`
- **3c (definitions pointer, line 45):**
  - Locate: `Full D1–D11 definitions, the fix-track rubric with worked examples`
  - Replace: `Full D1–D12 definitions, the fix-track rubric with worked examples`
- **3d (D10 summary example, line 57):**
  - Locate: `10. **D10 count/claim accuracy** — explicit counts and claims match reality ("11 dimensions", "5 patterns", phase numbers, persona counts). Mismatched count = HIGH.`
  - Replace: `10. **D10 count/claim accuracy** — explicit counts and claims match reality ("12 dimensions", "5 patterns", phase numbers, persona counts). Mismatched count = HIGH.`
- **3e (insert the D12 summary item — append after the D11 item, line 58):**
  - Locate: `11. **D11 scope-clarity** — each command/skill states its scope unambiguously near its heading; no leftover migration notes or stale "(was X)" parentheticals inline. Stale aside = MEDIUM; missing/ambiguous scope = HIGH.`
  - Replace:
    ```
    11. **D11 scope-clarity** — each command/skill states its scope unambiguously near its heading; no leftover migration notes or stale "(was X)" parentheticals inline. Stale aside = MEDIUM; missing/ambiguous scope = HIGH.
    12. **D12 rules-file size budget** — `wc -m templates/SHAMT_RULES.template.md` within `rules_size_budget_chars` (default 40000). Over budget = MEDIUM, **always intricate** → f0-capture pointing at `/trim-rules-file`; never auto-fixed.
    ```
- **3f (renumber Classify 12 → 13, and Evaluate 13 → 14):** two number-only edits.
  - Locate: `12. **Classify** per Pattern 2 (borderline → HIGHER).`
  - Replace: `13. **Classify** per Pattern 2 (borderline → HIGHER).`
  - Locate: `13. **Evaluate the primary round (adapted clean-round)** — clean`
  - Replace: `14. **Evaluate the primary round (adapted clean-round)** — clean`
- **3g (renumber Exit 14 → 15 AND D1–D11 → D1–D12 in the same item):**
  - Locate: `` `14. **Exit (Pattern 1 exit *shape*):** on the first clean round, spawn the **`audit-checker`** Haiku sub-agent ([`agents/audit-checker.md`](../../agents/audit-checker.md)) to re-run the D1–D11 sweep with zero bias;` ``
  - Replace: `` `15. **Exit (Pattern 1 exit *shape*):** on the first clean round, spawn the **`audit-checker`** Haiku sub-agent ([`agents/audit-checker.md`](../../agents/audit-checker.md)) to re-run the D1–D12 sweep with zero bias;` ``

**Verification:** `grep -cE "D1.D11|eleven|\"11 dimensions\"" host/templates/claude/skills/f5-audit-framework/SKILL.md` → `0`; the numbered list reads `11.`→`12. **D12`→`13. **Classify`→`14. **Evaluate`→`15. **Exit` (run `grep -nE "^1[0-5]\. " host/templates/claude/skills/f5-audit-framework/SKILL.md` and confirm 10–15 are each present exactly once, in order).

---

### Step 4: Update D1–D11 references in the audit-checker agent (row 4)
**Operation:** EDIT
**File:** `host/templates/claude/agents/audit-checker.md`
**Details — three replacements:**
- **4a (line 3):**
  - Locate: `re-runs the Shamt D1–D11 framework audit across the canonical surface`
  - Replace: `re-runs the Shamt D1–D12 framework audit across the canonical surface`
- **4b (line 18):**
  - Locate: `the D1–D11 dimension list applied during the primary sweep`
  - Replace: `the D1–D12 dimension list applied during the primary sweep`
- **4c (line 29):**
  - Locate: `across all eleven dimensions:`
  - Replace: `across all twelve dimensions:`

**Verification:** `grep -cE "D1.D11|eleven" host/templates/claude/agents/audit-checker.md` → `0`.

---

### Step 5: Update D1–D11 references in `reference/model_selection.md` (row 5)
**Operation:** EDIT
**File:** `reference/model_selection.md`
**Details — two replacements:**
- **5a (line 27):**
  - Locate: `zero-bias D1–D11 re-sweep, not depth`
  - Replace: `zero-bias D1–D12 re-sweep, not depth`
- **5b (line 64):**
  - Locate: `Zero-bias D1–D11 re-sweep on the clean round; fresh eyes, not depth`
  - Replace: `Zero-bias D1–D12 re-sweep on the clean round; fresh eyes, not depth`

**Verification:** `grep -cE "D1.D11" reference/model_selection.md` → `0`.

---

### Step 6: CREATE the `/trim-rules-file` command (row 6 — pairs with Step 7)
**Operation:** CREATE
**File:** `host/templates/claude/commands/trim-rules-file.md`
**Details:** Write the file with exactly this content:

````markdown
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
````

**Note:** write the file exactly as shown — **including** the closing `<!-- Managed by Shamt … -->` line. The canonical host source carries its own marker; `/f4-regen-framework` copies host files **verbatim** and uses that marker to decide which `.claude/` files it manages — it does **not** inject the comment. A new host file missing the marker would not be managed/pruned by regen.

**Verification:** `test -f host/templates/claude/commands/trim-rules-file.md`; `grep -c "^# /trim-rules-file" host/templates/claude/commands/trim-rules-file.md` → `1`; `grep -c "wc -m templates/SHAMT_RULES.template.md" host/templates/claude/commands/trim-rules-file.md` → at least `1`; `tail -n 5 host/templates/claude/commands/trim-rules-file.md | grep -c "Managed by Shamt"` → `1` (marker present so regen manages it).

---

### Step 7: CREATE the `/trim-rules-file` skill mirror (row 7 — mirrors Step 6)
**Operation:** CREATE
**File:** `host/templates/claude/skills/trim-rules-file/SKILL.md`
**Details:** Write the file with exactly this content:

````markdown
---
name: trim-rules-file
description: >
  Analyze the canonical rules file (templates/SHAMT_RULES.template.md,
  rendered into every child CLAUDE.md) for size-reduction opportunities and
  author a proposal draft enumerating concrete cuts toward the size budget,
  without editing the rules file directly. Master / self-host only. Triggered
  by the /f5-audit-framework D12 finding or run on demand. Natural-language
  triggers like "trim the rules file" / "shrink CLAUDE.md" / "the rules file
  is too big".
---

## Overview

Mirrors the `/trim-rules-file [slug]` slash command. Same canonical body, two host wirings.

## Protocol

Follow the canonical `/trim-rules-file` command body verbatim — see [`commands/trim-rules-file.md`](../../commands/trim-rules-file.md). Summary:

1. **Master / self-host only** — the rules file is master-owned; halt in a child and redirect to `/f0-draft-proposal` → `/f1-propose-update` → `/sync-submit-proposal`.
2. **Measure** — `wc -m templates/SHAMT_RULES.template.md` vs `rules_size_budget_chars` (fallback 40000); target ~75% of budget (~30000).
3. **Analyze** — find concrete reductions: duplication/repetition, extraction to `reference/`, rephrase/tighten, relocate to command/skill bodies, other improvements. Record location, category, change, char delta per candidate.
4. **Author a proposal draft** in the `/f0-draft-proposal` file shape (so `/f1-propose-update` ingests it), with the cut list + running total toward target in Scratch Notes. **Quality guardrail:** every cut is an extraction / rephrase / relocation — never a silent deletion of a normative rule; the draft preserves the full rule set and names where each touched rule now lives.
5. **Exit** — report draft path + current/target chars; suggest `/f1-propose-update {slug}`. Does **not** edit `SHAMT_RULES.template.md`.

## Recommended model

Reasoning (Opus) — preserving every rule while cutting is design judgment, not mechanical. See [`reference/model_selection.md`](../../../../../reference/model_selection.md).

## Exit criteria

A proposal draft at `proposals/{slug}.md` enumerating concrete cuts toward the budget with the rule-preservation guardrail stated; no edit to the rules file itself; master / self-host only.

---
Created 2026-06-07 — by /f3-implement-update for proposals/08-rules-size-budget-trim-skill.md (new /trim-rules-file skill mirror).

<!-- Managed by Shamt — do not edit. Regenerate from shamt-core/host/templates/claude/skills/trim-rules-file/SKILL.md. -->
````

**Note:** write the file exactly as shown — including the closing `<!-- Managed by Shamt … -->` line (per the Step 6 note: regen copies host files verbatim and keys off that marker; it does not inject the comment).

**Verification:** `test -f host/templates/claude/skills/trim-rules-file/SKILL.md`; `grep -c "Mirrors the \`/trim-rules-file\`" host/templates/claude/skills/trim-rules-file/SKILL.md` → `1`; `tail -n 5 host/templates/claude/skills/trim-rules-file/SKILL.md | grep -c "Managed by Shamt"` → `1` (marker present).

---

### Step 8: Add the `rules_size_budget_chars` key to `shamt-config.example.json` (row 8)
**Operation:** EDIT
**File:** `shamt-config.example.json`
**Details:**
- Locate: `"doc_staleness_threshold_days": 60`
- Replace: `"doc_staleness_threshold_days": 60,
  "rules_size_budget_chars": 40000`
- (The existing `60` carries no trailing comma; the replacement adds the comma + the new key line. The closing `}` on the next line is untouched, leaving valid JSON.)

**Verification:** `grep -c "rules_size_budget_chars" shamt-config.example.json` → `1`; `python3 -c "import json; json.load(open('shamt-config.example.json'))"` exits `0` (still valid JSON).

---

### Step 9: Reflect the new skill + config key in `README.md` (row 9)
**Operation:** EDIT
**File:** `README.md`
**Details — three replacements:**
- **9a (command table — add a `/trim-rules-file` row after the f6 row):**
  - Locate: `` `| `/f6-archive-proposal {slug}` | Phase 7 — archive the implemented proposal | shipped |` ``
  - Replace:
    ```
    | `/f6-archive-proposal {slug}` | Phase 7 — archive the implemented proposal | shipped |
    | `/trim-rules-file [slug]` | Maintenance — analyze `SHAMT_RULES.template.md` for size-reduction opportunities and author a trim proposal (D12 budget). **Master / self-host only** | shipped |
    ```
- **9b (f5 row, line 171 — "D1–D11 sweep" → "D1–D12 sweep"):**
  - Locate: `Phase 6 — continuous dual-track D1–D11 sweep: auto-fix simple findings`
  - Replace: `Phase 6 — continuous dual-track D1–D12 sweep: auto-fix simple findings`
- **9c (Configuration table — add a row after the `doc_staleness_threshold_days` row):**
  - Locate: `` `| `doc_staleness_threshold_days` | integer (default 60) | `/f5-audit-framework` D6: how stale `.shamt-core/project-specific-files/ARCHITECTURE.md` / `.shamt-core/project-specific-files/CODING_STANDARDS.md` can be |` ``
  - Replace:
    ```
    | `doc_staleness_threshold_days` | integer (default 60) | `/f5-audit-framework` D6: how stale `.shamt-core/project-specific-files/ARCHITECTURE.md` / `.shamt-core/project-specific-files/CODING_STANDARDS.md` can be |
    | `rules_size_budget_chars` | integer (default 40000, optional) | `/f5-audit-framework` D12: max chars for `templates/SHAMT_RULES.template.md` (the rules file rendered into each child `CLAUDE.md`) before a size finding fires |
    ```

**Verification:** `grep -cE "D1.D11" README.md` → `0`; `grep -c "/trim-rules-file" README.md` → `2` (command-table row + config-table reference); `grep -c "rules_size_budget_chars" README.md` → `1`.

---

## Final verification (after all steps)

1. **Count-ripple completeness** — the proposal's mandated grep:
   ```
   grep -rniE "D1.D11|D2.D11|eleven|11 (audit )?dimension" host/templates/claude/ reference/ README.md | grep -vE "Validated 2026|Touched 2026"
   ```
   **Expected:** zero results — every dimension-count / range statement now reads 12 / "twelve" / "D1–D12" (a dated footer/"Touched" line is out of scope and excluded).
2. **New files present** — `test -f host/templates/claude/commands/trim-rules-file.md && test -f host/templates/claude/skills/trim-rules-file/SKILL.md`.
3. **D12 present in all three audit surfaces** — `grep -rl "D12" reference/audit_dimensions.md host/templates/claude/commands/f5-audit-framework.md host/templates/claude/skills/f5-audit-framework/SKILL.md` returns all three.

Any non-footer residual `D1–D11` / `eleven` = an uncovered ripple site; halt and report.

---

## Notes

- **No `.claude/` edits.** Phase 5 (`/f4-regen-framework`) propagates the four `host/templates/claude/` edits (Steps 2, 3, 4) **and the two new files** (Steps 6, 7) into `.claude/` — the two new command/skill files appear as new `.claude/` entries. Regen copies host files **verbatim** (it does not inject the `<!-- Managed by Shamt … -->` marker — the canonical source carries it, which is why Steps 6–7 author the marker into the new files; regen keys off that marker to decide what it manages/prunes). Steps 1, 5 (`reference/`), 8, 9 (root docs) are not regenerated.
- **D12 category = Completeness** — implemented exactly as the validated proposal specifies (the rules artifact stays within a loadable budget). The plan does not re-litigate that design choice.
- **The trim command authors a proposal, never edits the rules file** — so trimming `SHAMT_RULES.template.md` is deliberately out of scope for this proposal; it is the skill's first real run, landed as its own downstream proposal.
- **No commit in Phase 4.** The commit + squash-merge land at `/f6-archive-proposal`.

## CODING_STANDARDS Compliance

N/A — no project `CODING_STANDARDS.md` applies at the framework-update altitude; these are documentation / agent-instruction edits and two new command/skill bodies in canonical framework sources.

---

## Open Questions

(none — every step is mechanical: an exact locate + replacement, or a CREATE with full content given inline)

---
Validated 2026-06-07 — 2 rounds, 1 adversarial sub-agent confirmed (round 1 fixed two defects: (a) 5 backtick-containing Locate/Replace strings used backslash-escaped `\`` that would not match disk — rewritten as double-backtick inline spans; (b) the two CREATE bodies lacked the `<!-- Managed by Shamt -->` marker that regen keys off — added the provenance footer + marker to each, since regen copies host files verbatim and does not inject it. All ~30 locate strings re-verified exact + unique against HEAD; the f5-skill renumber 12/13/14→13/14/15 confirmed full-line-specific.)
