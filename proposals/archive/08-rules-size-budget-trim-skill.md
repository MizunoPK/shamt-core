# Proposal: rules-size-budget-trim-skill

**Created:** 2026-06-07
**Status:** Implemented
**Number:** 08
**Proposed by:**
**Project context:**

---

## Problem

The rules file that renders into every child project's `CLAUDE.md` — the canonical `templates/SHAMT_RULES.template.md` — has grown to **40,281 characters** with no guardrail against further bloat. That text is loaded into the AI's context on every interaction in a child project, so its size is a direct, recurring context-budget cost; left unchecked it only ratchets upward as the framework accretes rules. Nothing in the framework currently *measures* it, let alone flags it or offers a disciplined way to bring it back down.

Two gaps:

1. **No size signal.** `/f5-audit-framework`'s D1–D11 sweep checks sync drift, consistency, references, counts, etc., but never the rules file's size. An author has no automated nudge when the rules file crosses a sustainability line.
2. **No disciplined reduction path.** Even noticing the bloat, there's no dedicated tool to *shrink* the rules file while preserving every normative rule — the reductions (de-duplicate, extract to `reference/`, rephrase tighter, move procedural detail into commands/skills) require judgment and must not silently drop a rule.

This proposal adds both: a new audit dimension **D12 — rules-file size budget** that measures `SHAMT_RULES.template.md` against a configurable character budget and, when over, emits a finding + f0 capture pointing at a new dedicated **`/trim-rules-file`** skill; and that skill, which analyzes the rules file for reduction opportunities and authors a proposal draft enumerating concrete cuts toward a ~30k target. The size budget is intentionally **measured on the canonical source** (`SHAMT_RULES.template.md`) because the audit runs master / self-host only — there is no rendered child `CLAUDE.md` to measure on the self-host, and the template is the lever the framework actually controls (resolved question 1).

**Design decisions resolved with the user (see Resolved Questions):** measure `SHAMT_RULES.template.md` (not a rendered child CLAUDE.md); over-budget → **finding + f0 capture pointing at the skill** (preserves the audit's capture-and-continue, no-auto-fix invariant — the audit never runs the skill itself); unit = **characters** via `wc -m` (40k budget / ~30k target, zero dependency); the skill **analyzes and authors a rich proposal draft** (concrete cut list with char estimates), which the user then refines via `/f1-propose-update` → validate → implement.

---

## Proposed Changes

The change has three parts: **(A)** the new D12 audit dimension (+ the D10 count-accuracy ripple of going from 11 to 12 dimensions across every site that states the count), **(B)** the new `/trim-rules-file` command + skill, and **(C)** the configurable budget key. No `.claude/` paths — the 5 `host/templates/claude/` rows regenerate via `/f4-regen-framework`.

| # | Canonical path | Operation | One-line change description |
|---|----------------|-----------|------------------------------|
| 1 | `reference/audit_dimensions.md` | EDIT | Add the full **D12 — rules-file size budget** definition (what's measured: `wc -m templates/SHAMT_RULES.template.md`; budget from `rules_size_budget_chars`, default 40000; over-budget = **MEDIUM**, always **intricate → f0 capture** pointing at `/trim-rules-file`, never auto-fixed). Update title `(D1–D11)` → `(D1–D12)`, "the eleven audit dimensions" → "twelve", the D10 row's "11 dimensions" example → "12 dimensions", and the line-69 D10 worked example "grew to eleven" → "twelve". Group D12 under **Completeness** (the rules artifact stays within a loadable budget). |
| 2 | `host/templates/claude/commands/f5-audit-framework.md` | EDIT | Add the D12 row to the dimension table (after D11) + a `**D12 — Rules-file size budget.**` detail subsection under Step 2 (the `wc -m` check, budget-key read with 40000 fallback, MEDIUM/intricate→f0-capture-pointing-at-`/trim-rules-file`, never auto-fix). Update **every** count / range / sweep-reference site to 12: frontmatter "11 audit dimensions" (line 2), purpose "eleven dimensions (…)" incl. the parenthetical dimension list (line 7), D10 row "11 dimensions" example (line 51), round-structure "sweep D1, then **D2–D11**" (line 56) → `D2–D12`, the `### Step 2 — Run **D2–D11**` heading (line 91) → `D2–D12`, "full **D1–D11** definitions" (line 93), D10 prose "11 dimensions" (line 140), "re-run the **D1–D11** sweep" (line 177), "framework-wide **D1–D11** sweep" (line 229). |
| 3 | `host/templates/claude/skills/f5-audit-framework/SKILL.md` | EDIT | Mirror D12 in the dimension summary: insert a `12. **D12 — rules-file size budget …**` bullet after D11 (line 58) **and renumber the three following items** — `12. Classify`→`13.` (line 59), `13. Evaluate`→`14.` (line 60), `14. Exit`→`15.` (line 61) — so the numbered list stays sequential. Also update "across eleven dimensions" + the D1 enumeration (line 5), "D1–D11 definitions" (line 45), the D10 "11 dimensions" example (line 57), and "D1–D11 sweep" (in the renumbered Exit item, line 61). |
| 4 | `host/templates/claude/agents/audit-checker.md` | EDIT | Update the D1–D11 references → D1–D12: frontmatter description (line 3), the `dimensions` input note (line 18), and "all eleven dimensions" (line 29). The sub-agent re-sweeps all 12 on the clean round. |
| 5 | `reference/model_selection.md` | EDIT | Update the two `audit-checker` "D1–D11 re-sweep" references (lines 27, 64) → "D1–D12". |
| 6 | `host/templates/claude/commands/trim-rules-file.md` | CREATE | New standalone command `/trim-rules-file` (master / self-host only). Body: measure the current rules-file size; scan `SHAMT_RULES.template.md` for reduction opportunities (duplication/repetition, content extractable to `reference/`, verbose passages to rephrase, procedural detail movable into command/skill bodies); **author a proposal draft** at `proposals/{slug}.md` enumerating each concrete cut with a before/after char estimate and a running total toward the budget's ~75% target (~30k). **Quality guardrail:** every cut maps to extraction / rephrase / relocation — never a silent deletion of a normative rule; the draft must preserve the full rule set. If an audit-captured D12 f0 stub already exists, develop it rather than creating a duplicate. Exit suggests `/f1-propose-update {slug}`. |
| 7 | `host/templates/claude/skills/trim-rules-file/SKILL.md` | CREATE | The mirrored auto-triggered skill (natural-language phrases like "trim the rules file" / "shrink CLAUDE.md"), routing to the command body verbatim per Principle 1's "skills mirror slash commands." |
| 8 | `shamt-config.example.json` | EDIT | Add `"rules_size_budget_chars": 40000` (optional; default 40000). Primarily a self-host knob — the D12 audit reads it with a 40000 fallback when absent. |
| 9 | `README.md` | EDIT | (a) Add a `/trim-rules-file` row to the commands/skills quick-reference table; (b) update the `/f5-audit-framework` row's "D1–D11 sweep" → "D1–D12"; (c) add a `rules_size_budget_chars` row to the Configuration table (marked optional, default 40000, "D12: budget for `SHAMT_RULES.template.md` size in chars"). |

Row count: **9 ≤ 10** — Phase 3 (`/f2-plan-update-implementation`) is **not required**, but rows 6–7 author two substantial new files; a plan is recommended-not-required and the user may opt into one.

**Paired files:** rows 2↔3 (f5 command ↔ skill) and rows 6↔7 (new command ↔ skill) move together. Row 9's README catalog + config-table reflect rows 6–8.

---

## Risks

- **D10 count-ripple completeness (the load-bearing one)** — going 11 → 12 dimensions touches **two-dozen-plus** count / range / reference sites across 6 files (rows 1–5, 9), including range strings (`D1–D11`, `D2–D11`) and a numbered-list renumber in the f5 skill summary (Classify/Evaluate/Exit shift 12/13/14 → 13/14/15). Missing one is itself a D10 finding the next audit would flag. Validation must grep the full surface for residual `D1.D11` / `D2.D11` / `eleven` / `11 dimension` after the edits.
- **Recursive irony / self-trigger** — adding D12 + its detail subsection slightly *grows* `f5-audit-framework.md` (a host body, not the rules file) — fine. But note the subject file `SHAMT_RULES.template.md` is **already at 40,281 chars**, so the very first post-merge audit will fire D12 and capture a trim f0. That is the intended behavior, not a defect; the trim itself is a separate downstream proposal (the skill's output), deliberately out of scope here.
- **Budget-key placement** — `rules_size_budget_chars` is a master/self-host concern (the template is master-owned; the audit doesn't run in children), so it sits slightly oddly in the child-facing `shamt-config.example.json`. Mitigated by the 40000 fallback (the key is optional) and the README note scoping it to D12. No `init-shamt.sh` prompt is added (keeps install unchanged) — see Resolved Questions.
- **Quality-preservation in the trim skill** — the real hazard of any rules-shrinking is silently dropping a normative rule. Mitigated structurally: the skill's *output is a proposal*, so it goes through `/validate-artifact` + the user's review + the next D2/D7 audit (which catches a missing pattern/term) before anything lands. The skill body additionally mandates that each cut be an extraction/rephrase/relocation, never a deletion of a rule.
- **Scope discipline** — this proposal adds the *mechanism* (check + skill + budget). It does **not** trim the rules file. The actual reduction is the skill's first real run, landed as its own proposal. Conflating the two would balloon scope.
- **Regen drift** — rows 2–4, 6–7 are `host/templates/claude/` files; `/f4-regen-framework` must propagate them (the 2 new files appear as new `.claude/` entries). Rows 1, 5, 8, 9 don't regenerate.

---

## Rollback Plan

`git revert <commit-sha>` removes D12 (restoring the D1–D11 counts everywhere), deletes the `/trim-rules-file` command + skill, and drops the config key; `/f4-regen-framework` re-propagates the host bodies and prunes the two generated `.claude/` files. Children pick up the reverted state on the next `/sync-import-shamt` (the orphaned `.claude/trim-rules-file*` files are pruned by regen's managed-subtree pruning). No data loss; no proposal authored by the skill is affected (those are independent files).

---

## Validation Considerations

- **Count-ripple completeness (highest-risk)** — after the edits, `grep -rniE "D1.D11|eleven|11 (audit )?dimension" host/templates/claude/ reference/ README.md` must return **zero** non-historical hits (a dated footer/"Touched" line referencing the old count is out of scope). Every dimension-count statement must read 12 / "twelve" / "D1–D12".
- **D12 definition coherence** — `reference/audit_dimensions.md` D12 entry, the f5 command detail subsection, and the f5 skill summary bullet must agree on: what's measured (`SHAMT_RULES.template.md` via `wc -m`), the budget source (`rules_size_budget_chars`, 40000 fallback), severity (MEDIUM), and fix-track (intricate → f0 capture pointing at `/trim-rules-file`, never auto-fix). A divergence is a D2 finding.
- **Command ↔ skill parity** — rows 2↔3 and 6↔7 must describe the same body (D2). The new skill must route to the command per Principle 1, not duplicate full protocol text (cf. `SHAMT_RULES.template.md` line 331).
- **New-file regen** — after `/f4-regen-framework`, `.claude/commands/trim-rules-file.md` and `.claude/skills/trim-rules-file/SKILL.md` exist and `--check` reports `no drift`.
- **Config + catalog reflection** — `shamt-config.example.json` stays valid JSON; the README Configuration table and command catalog list the new key and skill (D3 bidirectional coverage: the new skill cites D12 as the rule it implements).
- **Affected surfaces** — `reference/` (audit_dimensions, model_selection), `host/templates/claude/` (f5 command + skill, audit-checker agent, the 2 new files), root docs (`README.md`, `shamt-config.example.json`). No `templates/SHAMT_RULES.template.md` edit (it neither enumerates dimensions nor config keys — it points to README for the catalog), and **deliberately** so: trimming the template is the skill's downstream job, not this proposal's.

---

## Open Questions

(none remaining)

---

## Resolved Questions

<!-- Drafting-only log -->

- ~~Q1 (load-bearing): what does the size check measure — the canonical `SHAMT_RULES.template.md`, the rendered child `CLAUDE.md`, or both?~~ → A: **`SHAMT_RULES.template.md`** (user, 2026-06-07). The audit runs master/self-host where no rendered child CLAUDE.md exists; the template is what renders into every child and is the lever the framework controls. Currently 40,281 chars.
- ~~Q2 (load-bearing): over budget → does the audit auto-invoke the trim skill, emit a finding + f0 capture pointing at it, or report a finding only?~~ → A: **Finding + f0 capture pointing at the skill** (user, 2026-06-07). Preserves the audit's capture-and-continue / no-auto-fix invariant; the user runs `/trim-rules-file` deliberately.
- ~~Q3 (load-bearing): measure in characters or tokens?~~ → A: **Characters** (user, 2026-06-07). `wc -m`, zero-dependency, deterministic; 40k budget / ~30k target per the blurb. (Tokens are the truer constraint but need a tokenizer; rejected for portability.)
- ~~Q4 (load-bearing): how much does the skill do, and how does its output enter the flow?~~ → A: **Analyze + author a rich draft** (user, 2026-06-07). The skill scans for concrete cuts (de-dup, extract-to-reference, rephrase, move-to-command/skill) and writes a proposal draft with char estimates toward ~30k; the user then runs `/f1-propose-update` to refine + number it, then validate → implement.
- ~~Q5 (f1 default): where does the budget value live?~~ → A (resolved by f1 default): a **config key `rules_size_budget_chars` (default 40000)** in `shamt-config.example.json`, mirroring `doc_staleness_threshold_days`; the D12 audit reads it with a 40000 fallback. **No `init-shamt.sh` prompt** is added — the budget is a master/self-host concern (children can't change the master-owned template), so prompting every child installer for it would be noise; it stays an optional, rarely-touched key.
- ~~Q6 (f1 default): trim-skill name + the dimension's category/severity?~~ → A (resolved by f1 default): command/skill named **`trim-rules-file`** (bare, un-prefixed — it's an on-demand maintenance utility like `validate-artifact`, not a linear-flow phase). D12 grouped under **Completeness**, severity **MEDIUM**, fix-track **always intricate → f0 capture** (trimming is never mechanical). The audit's D12 f0 stub is lightweight ("rules file at N chars, over budget — run `/trim-rules-file`"); the skill's own run produces the detailed cut proposal, developing the stub if present to avoid duplicates.

---
Validated 2026-06-07 — 2 rounds, 1 adversarial sub-agent confirmed
