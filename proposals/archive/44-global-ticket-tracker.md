# Proposal: global-ticket-tracker

**Number:** 44
**Created:** 2026-06-19
**Status:** Implemented
**Proposed by:** FantasyFootballHelperScripts
**Project context:** Tech-stories tickets were created with duplicate ticket IDs (T1/T2/T3) colliding with an existing open epic's T1–T12; the disk-scan allocation under-counted because the producer command bodies paraphrase the scan as a non-recursive top-level glob.

---

## Problem

In a child project (FantasyFootballHelperScripts), `/ps0-draft` created tech-stories tickets with ticket IDs `T1`/`T2`/`T3` that **collided** with the already-open epic `T1-win-rate-sim-overhaul`, which spans `T1`–`T12` across its nested epic/features/stories. Three tickets had to be hand-renumbered to `T13`/`T14`/`T15` (folder renames + `**Ticket ID:**` lines + sibling cross-refs) to restore the global-uniqueness invariant the framework promises.

**Confirmed root cause (adversarial diagnosis — `root-cause-diagnoser` Opus + Haiku zero-bias confirmation, both clean).** This is a **D2 rules↔host consistency drift**, not a rules gap. The canonical contract at `templates/SHAMT_RULES.template.md` §"# Ticket IDs" *Allocation* (line 357) is **correct**: it specifies a recursive whole-tree scan — "parse a leading `^T([0-9]+)-` run on each epic/feature/story folder name, **walking the nested tree under `epics/` plus any legacy flat folders**". But **eight producer command bodies** that allocate a new ticket ID paraphrase that scan as a **non-recursive top-level glob**: verbatim "`max` of the `^T([0-9]+)-` prefixes across `epics/`, `features/`, `stories/`, + 1 — per **# Ticket IDs**" (`pe1-define` inserts "and" but is otherwise identical). After proposal #14 (nested-folder layout), new features live at `epics/*/features/{ID}-*/` and new stories at `epics/*/features/*/stories/{ID}-*/`; the top-level `features/`/`stories/` directories hold **only** legacy-flat artifacts (per §PO-tree resolution, line 167). A producer following the literal wording globs three non-recursive directories, sees **only epic-level prefixes** (and nothing under the empty top-level `features/`/`stories/`), under-counts `max`, and re-issues IDs that already exist on nested feature/story folders — exactly the observed collision against `T1-win-rate-sim-overhaul`'s nested T1–T12 children. The producers cite "per **# Ticket IDs**" yet *paraphrase* the rule in their own (wrong-since-#14) words — paraphrase is the very drift class proposal #37 removed for the command↔skill `## Protocol` pointer.

The eight drifted producers (the f0 capture named six; the diagnosis found two more — `pe0-draft`, `pf0-draft`):
`host/templates/claude/commands/{ps0-draft, pe0-draft, pe1-define, pe3-decompose, pf0-draft, pf1-define, pf3-decompose, ps1-define}.md`. (`e1-start-story.md` mentions allocation only narratively, with no literal formula — it inherits the corrected contract and needs no edit.)

**Ruled out** (so scope does not bloat):
- **Reserved-name hazard — non-causal.** The standing Tech Stories epic + `bugs`/`quick-wins` features carry no `T{N}-` prefix; the `^T([0-9]+)-` regex correctly returns no match and they harmlessly contribute zero to `max`, even under a fully-recursive scan. No canonical change needed for reserved names.
- **A state-file ticket counter (the f0's option C) — rejected.** It conflicts with Principle 1 ("No state file, no orchestrator memory — state lives in the filesystem") and the §"# Ticket IDs" "no counter file" wording. The disk scan is correct **once the producer wording is fixed**; the existing `shamt-state/` files are intentionally *pointers* (active-item paths), not authoritative ledgers.

**Secondary gap.** There is **no** mechanical duplicate-ticket-ID guard anywhere — not in any command's exit criteria, not in `/f5-audit-framework`. The FFHS collision surfaced only because a human noticed. Without a guard, a future drift (a new producer, or a regen edit that subtly re-breaks the phrasing) silently re-collides. (D10 "count/claim accuracy" checks count-vs-claim, not on-disk ID uniqueness.)

## Approach

**Part 1 — make §"# Ticket IDs" the single allocation contract; collapse the producers to a pure pointer (settled).** Tighten the §"# Ticket IDs" *Allocation* bullet into an unambiguous, copy-able operational contract: explicit recursive-walk enumeration (`epics/{ID}-*/`, `epics/*/features/{ID}-*/`, `epics/*/features/*/stories/{ID}-*/`, plus the legacy-flat `features/{ID}-*/` and `stories/{ID}-*/` fallbacks), work-root-relative per §PO-tree resolution, with an explicit note that the reserved standing-epic folders (`tech-stories`, `bugs`, `quick-wins`) carry no `T{N}-` prefix and contribute zero. Then **replace each of the eight producers' inline three-dir formula with a pure pointer** — "Allocate a ticket ID `T{N}` per `templates/SHAMT_RULES.template.md` §**# Ticket IDs** *Allocation*" — no paraphrase. This mirrors the D2 SKILL-`## Protocol` pointer rule: paraphrase is the drift class, pointer is the prevention. Eight bodies become pointer-only and cannot silently re-drift; a future producer adds a one-line pointer instead of re-deriving the recursive walk.

**Part 2 — an in-flow per-producer duplicate-ID halt-check (settled — OQ1).** Add a cheap guard that fires at the write site in *every* producer's flow, on **both** master and child (the incident happened in a child, where `/f5-audit-framework` never runs — so a master-only audit dimension would not have caught it). To avoid re-introducing the exact paraphrase drift Part 1 removes, the check is **not** copied into each of the eight bodies; it is **homed once** in the §"# Ticket IDs" *Allocation* contract as a post-allocation clause — "after allocating, verify no other folder anywhere under the work-root tree already carries the chosen `T{N}` prefix; halt on collision" — which all eight producers already point to. So each producer runs the guard in-flow via its existing allocation pointer, with **no new files, no per-body paraphrase, and no audit-dimension count churn**. (A master-side `/f5` audit dimension — new or folded into D10 — was considered and rejected: it adds renumber churn across ~8 files and would not protect the child where the incident occurred.)

---

## Proposed Changes

A flat list of canonical files the proposal will touch.

| # | Canonical path | Operation | One-line change description |
|---|----------------|-----------|------------------------------|
| 1 | `shamt-core/templates/SHAMT_RULES.template.md` | EDIT | §"# Ticket IDs" *Allocation* bullet — tighten to an unambiguous operational contract: explicit recursive whole-tree enumeration (`epics/{ID}-*/`, `epics/*/features/{ID}-*/`, `epics/*/features/*/stories/{ID}-*/` + legacy-flat fallbacks), work-root-relative, reserved-name note, **plus a post-allocation uniqueness halt-check clause** (Part 2 — homed here so all eight producers inherit it via their pointer). |
| 2 | `shamt-core/host/templates/claude/commands/ps0-draft.md` | EDIT | Step 2.1 — replace the "across `epics/`, `features/`, `stories/`" formula with a pure pointer to §"# Ticket IDs" *Allocation*. |
| 3 | `shamt-core/host/templates/claude/commands/pe0-draft.md` | EDIT | Allocation line — replace the three-dir formula with the §"# Ticket IDs" *Allocation* pointer. |
| 4 | `shamt-core/host/templates/claude/commands/pe1-define.md` | EDIT | Step 2 allocation line — replace the three-dir formula ("and"-variant) with the §"# Ticket IDs" *Allocation* pointer. |
| 5 | `shamt-core/host/templates/claude/commands/pe3-decompose.md` | EDIT | Step 8 feature-ID allocation — replace the three-dir formula with the §"# Ticket IDs" *Allocation* pointer. |
| 6 | `shamt-core/host/templates/claude/commands/pf0-draft.md` | EDIT | Allocation line — replace the three-dir formula with the §"# Ticket IDs" *Allocation* pointer. |
| 7 | `shamt-core/host/templates/claude/commands/pf1-define.md` | EDIT | Step 2 allocation line — replace the three-dir formula with the §"# Ticket IDs" *Allocation* pointer. |
| 8 | `shamt-core/host/templates/claude/commands/pf3-decompose.md` | EDIT | Step 8 story-ID allocation — replace the three-dir formula with the §"# Ticket IDs" *Allocation* pointer. |
| 9 | `shamt-core/host/templates/claude/commands/ps1-define.md` | EDIT | Step 2 allocation line — replace the three-dir formula with the §"# Ticket IDs" *Allocation* pointer. |

*Part 2 (resolved OQ1) adds **no new rows**: the post-allocation uniqueness halt-check is homed in the row-1 §"# Ticket IDs" *Allocation* contract, and rows 2–9's pointer rewrites inherit it (each producer's "Allocate … per §# Ticket IDs *Allocation*" pointer now also carries the guard — no per-body paraphrase). Total: **9 file ops (≤10 — no `/f2` Phase 3 note).***

**Path discipline:**

- **CREATE** must give the exact target path and a one-line content sketch.
- **EDIT** must name the exact section / heading the edit lands in.
- **DELETE** must justify the removal.
- **MOVE** is recorded as paired CREATE + DELETE rows.
- Generated `.claude/` files are **never** listed. Edits go to canonical sources.

---

## Risks

- **Regression.** Tightening the §"# Ticket IDs" wording or a pointer rewrite could mis-state the enumeration. Mitigation: the contract is verified against §PO-tree resolution's exact nested globs; validation re-reads both.
- **Drift (canonical vs generated).** All eight producer edits + the rule edit must regenerate cleanly into `.claude/`. Mitigation: `/f4-regen-framework --check` confirms zero drift before archive.
- **D12 rules-file size budget.** Part 1 + Part 2's edits *add* operational detail to the size-budgeted rules file (the §"# Ticket IDs" *Allocation* bullet grows by a few enumerated globs + a one-sentence uniqueness halt-check clause). Mitigation: keep the wording terse — net add is a handful of lines, not a new subsection; if it pushes over budget the D12 audit captures it for `/trim-rules-file`. (Choosing the in-flow-guard-in-contract design specifically *avoided* the larger churn of a new audit dimension — see below.)
- **Dimension-count churn — avoided by design (OQ1 resolution).** Minting a new audit dimension (or folding one into D10) would have rippled the "twelve dimensions" / "D1–D12" claim across ~8 files (f5 SKILL + command, `reference/audit_dimensions.md`, `audit-checker` agent, `model_selection.md`, README) — itself a D10 count-accuracy surface — and would not have protected the child where the incident occurred. The chosen in-flow-guard design touches no audit surface and adds no count churn.
- **Child-project compatibility.** Purely a wording/contract correction + an additive guard; no artifact-format change. Children pick it up on next `import-shamt` + regen. The corrected scan does not renumber any existing folder (new-tickets-only rule holds).
- **Open-questions debt.** None — OQ1 (guard scope) is resolved (see Resolved Questions).

---

## Rollback Plan

Additive + wording-correction change. Rollback: revert the landing commit, run `/f4-regen-framework` to restore `.claude/`, no child-side action required beyond the next `import-shamt`. No data migration. Tell: nobody (no external surface).

---

## Validation Considerations

- **Hardest-to-get-right row:** #1 (the rule contract). Validate the enumerated globs against §PO-tree resolution (lines 165–167) verbatim — the recursive forms must match exactly, including the legacy-flat fallbacks.
- **Pointer fidelity (rows 2–9):** confirm each producer's rewrite is a *pure pointer* with no surviving paraphrase of the scan scope (the drift class). The validator should grep all eight bodies for the old "across `epics/`, `features/`, `stories/`" string and confirm zero remain.
- **Completeness of the producer set:** confirm exactly these eight bodies carry the formula and `e1-start-story.md` does not (the diagnosis corrected the f0's six-file undercount to eight).
- **No SKILL edits needed:** the eight `skills/*/SKILL.md` `## Protocol` sections are pure command-body pointers; a command-step edit needs no paired SKILL edit (the #37 pointer rule). Confirm none crept into the change list.
- **Part 2 guard placement:** confirm the post-allocation uniqueness halt-check lives in the row-1 §"# Ticket IDs" *Allocation* contract (stated once) and that the eight producer pointers carry it implicitly — it must **not** be paraphrased into the eight bodies (that would re-create the drift class). Confirm the halt-check enumerates the same recursive whole-tree scope as allocation.
- **Surfaces affected:** rules + commands only (Part 1 + Part 2). No audit-surface edits (OQ1 chose the in-flow guard over an audit dimension).
- **Propagation:** regen + `--check`; child picks up on `import-shamt`.
- **Row count:** 9 file ops total (≤ 10) — **no** Phase 3 note; `/validate-artifact` then `/f3-implement-update` directly.

---

## Open Questions

*(none — all resolved)*

---

## Resolved Questions

- ~~**OQ1 — Part 2 guard scope.** Beyond the corrected allocation contract, how much mechanical duplicate-ticket-ID guard?~~ → **In-flow per-producer check only.** Add a post-allocation uniqueness halt-check that fires at the write site in every producer's flow (master **and** child — where the incident occurred). Realized by homing the halt-check once in the §"# Ticket IDs" *Allocation* contract that all eight producers point to (no per-body paraphrase, no new files, no audit-dimension count churn). A master-side `/f5` audit dimension (new or folded into D10) was explicitly rejected — it would not protect the child and adds renumber churn across ~8 files.

---
Validated 2026-06-20 — 1 round, 1 adversarial sub-agent confirmed
