# Proposal: po-flow-phase-stage-numbering-incoherent

**Created:** 2026-06-19
**Status:** Implemented
**Number:** 48
**Proposed by:**
**Project context:**

---

## Problem

The Shamt PO-flow command and skill bodies self-label their position in the flow with **two incompatible numbering models at once**, producing genuinely incoherent per-altitude sequences (a D2 cross-doc-consistency / D9 contradiction / D11 comprehension-risk finding, surfaced as an f0 audit capture during the Phase-6 sweep of proposal #41 `po-validate-stage`).

The canonical model is the **per-altitude stage grid** the `README.md` already defines (`README.md:105`): *"prefix by altitude (`pe`/`pf`/`ps`), number by stage (`0-draft`, `1-define`, `2-validate`, `3-decompose`, `4-finalize`)."* Under this model every altitude numbers its own stages independently — define = 1, validate = 2, decompose = 3, finalize = 4. The README command tables (`README.md:119-130`) and the `*-validate` commands (`pe2-validate`, `pf2-validate`, `ps2-validate`, all "Stage 2") and `ps1-define` ("Stage 1") already follow it.

But five command bodies still carry **legacy flow-wide cross-altitude "Phase N" numbers** that #41 left untouched when it relabeled only the renamed epic-track commands:

- **Epic track** — `host/templates/claude/commands/pe1-define.md` ("Phase 1"), `pe3-decompose.md` ("Phase 3"), `pe4-finalize.md` ("Phase 4 (Finalize)"). The *numbers* happen to coincide with per-altitude stage numbers, but the *noun* is the wrong "Phase" rather than "Stage".
- **Feature track** — `pf1-define.md` ("Phase 3", the pre-#41 flow-wide number) and `pf3-decompose.md` ("Phase 4"). Here both the noun *and* the number are wrong: the feature altitude reads "Phase 3 define → Stage 2 validate → Phase 4 decompose" — the validate stage's number (2) is *lower* than the define stage it follows (3), so the sequence is **non-monotonic**.

The collisions across the flow: **two "Phase 3"s** (`pe3-decompose` and `pf1-define`) and **two "Phase 4"s** (`pe4-finalize` and `pf3-decompose`). The mirror SKILL.md descriptions repeat the wrong labels — and `host/templates/claude/skills/pf3-decompose/SKILL.md` is even *internally* inconsistent with its own command body, saying **"Phase 5"** where the command says "Phase 4" (an independent drift the original capture missed; confirmed by adversarial sweep).

**Root cause** (verified by an independent adversarial root-cause diagnosis): #41 renumbered only the epic track's self-labels (its rows 7–8 explicitly say "Update self-labels Phase 2 → Phase 3" / "Phase 3 → Phase 4") and left the feature track's legacy flow-wide "Phase 3"/"Phase 4" labels in place, while the README/grid and the new `-validate` commands moved to the per-altitude "Stage" model. The framework now mixes a flow-wide cross-altitude phase sequence with a per-altitude stage grid. **Resolution (Open Question 1):** commit fully to the README-aligned per-altitude model and unify the noun to **"Stage"** throughout the PO flow, reserving **"Phase"** for the Engineer flow (Phases 1–8) and the framework-update flow (Phases 0–7) — the two genuinely flow-wide, single-altitude sequences.

## Proposed Changes

Scope is the **incident fix only**: collapse the nine legacy "Phase N" PO-flow self-labels to per-altitude "Stage N" (capital, free-standing — the form `pe2`/`pf2`/`ps2`/`ps1` already use). The lowercase hyphenated `stage-N` form (README grid prose, README command tables, and the `pe0`/`pf0`/`ps0` draft commands) is **deliberately left untouched** — see Open Question 2 and Risks: it is a load-bearing identifier convention, not a cosmetic self-label.

Generated `.claude/` paths never appear below; `/f4-regen-framework` propagates each canonical edit into `.claude/`.

| # | Canonical path | Op | Change |
|---|----------------|-----|--------|
| 1 | `host/templates/claude/commands/pe1-define.md` | EDIT | Frontmatter `description:` (L2) + `**Purpose:**` (L7): "Phase 1 of the PO flow" / "Run Phase 1 of the PO flow at the **Epic** altitude" → "Stage 1 …". (2 line-edits.) Leave the L112/L175 "Phase 2 / Phase 6 / Phase 7" mentions — those are **Engineer-flow** story-altitude references, not PO self-labels. |
| 2 | `host/templates/claude/commands/pe3-decompose.md` | EDIT | `description:` (L2) + `**Purpose:**` (L7): "Phase 3 of the PO flow" / "Run Phase 3 of the PO flow." → "Stage 3 …". (2 line-edits.) |
| 3 | `host/templates/claude/commands/pe4-finalize.md` | EDIT | `description:` (L2) only: "Phase 4 (Finalize) of the Shamt PO flow at the Epic altitude" → "Stage 4 (Finalize) …". The L7 Purpose ("the terminal PO-flow command at the Epic altitude") carries no number — leave it. (1 line-edit.) |
| 4 | `host/templates/claude/commands/pf1-define.md` | EDIT | `description:` (L2) + `**Purpose:**` (L7): "Phase 3 of the PO flow" / "Run Phase 3 of the PO flow at the **Feature** altitude" → "Stage 1 …". (2 line-edits.) Leave the L141 "Phase 2 / Phase 6 / Phase 7" mention — Engineer-flow reference. |
| 5 | `host/templates/claude/commands/pf3-decompose.md` | EDIT | `description:` (L2) + `**Purpose:**` (L7): "Phase 4 of the PO flow" / "Run Phase 4 of the PO flow." → "Stage 3 …". (2 line-edits.) |
| 6 | `host/templates/claude/skills/pe1-define/SKILL.md` | EDIT | Frontmatter `description:` body (L4): "Run Phase 1 of the Shamt PO flow at the Epic altitude" → "Run Stage 1 …". |
| 7 | `host/templates/claude/skills/pe3-decompose/SKILL.md` | EDIT | `description:` body (L4): "Run Phase 3 of the Shamt PO flow at the Epic altitude" → "Run Stage 3 …". |
| 8 | `host/templates/claude/skills/pf1-define/SKILL.md` | EDIT | `description:` body (L4): "Run Phase 3 of the Shamt PO flow at the Feature altitude" → "Run Stage 1 …". |
| 9 | `host/templates/claude/skills/pf3-decompose/SKILL.md` | EDIT | `description:` body (L4): "Run **Phase 5** of the Shamt PO flow at the Feature altitude" → "Run Stage 3 …". (Fixes the extra command↔skill drift the original capture missed.) |

**9 canonical file operations** (≤ 10 → no Phase 3 plan required). 13 individual line-edits total. The `pe2-validate`/`pf2-validate`/`ps2-validate` ("Stage 2") and `ps1-define` ("Stage 1") self-labels are already correct and are **not** touched. `README.md` and `templates/SHAMT_RULES.template.md` need **no** change — the README grid is already the per-altitude target the fix converges on, and §PO-tree references PO commands by name with no numeric self-labels.

## Risks

- **Regression / over-reach.** The nearest trap is recasing an Engineer-flow "Phase N" reference (the `pe1`/`pf1` story-altitude "Phase 2 / 6 / 7" mentions) or the `ps1`/`*2-validate` labels that are already correct. Mitigated by the per-row "leave" notes above; validation must re-confirm no Engineer-flow reference was altered.
- **`stage-N` casing convention left in place (deliberate).** The lowercase hyphenated `stage-N` form survives in three places, by design, because it is **not** a free-standing prose self-label and is load-bearing or identifier-echoing:
  1. `## Scratch Notes (stage-0 capture)` is a **programmatically-matched literal heading string** — `pe0`/`pf0`/`ps0` *write* it (pf0 calls it "the shared PO-stage-0 heading string") and `pe1`/`pf1`/`ps1` *detect and strip* it on f0-draft ingestion. Recasing it would silently break that producer↔consumer contract across six files. Out of scope.
  2. README `README.md:105` `` `0-draft`, `1-define`, … `` are the literal command-name numeric prefixes (the commands *are* `pe0-draft` etc.) — not recasable to a "Stage" noun.
  3. The README command-table rows (`README.md:119-130`, "Epic stage-1 define") echo that command-name-prefix style; recasing them is purely cosmetic and was explicitly deferred (Open Question 2). The capital/lowercase split is therefore *meaningful* (capital = free-standing prose self-label; lowercase = command-name-prefix echo / matched heading), and this proposal preserves it rather than flattening it.
- **Drift (canonical vs generated `.claude/`).** All edits are to canonical `host/templates/claude/` sources; `/f4-regen-framework` must run so `.claude/` mirrors stay in sync. A `--check` zero-drift pass is the gate.
- **Child-project compatibility.** Pure label text in command/skill descriptions; no behavior, path, or contract change. Next `import-shamt` + regen propagates cleanly with no child action required.
- **Meta-gap (out of scope, flagged).** The deeper *why* is that #41 had no contract requiring it to sweep every sibling command's self-label when introducing a new altitude×stage axis, and `/f5-audit-framework`'s D2/D9 sweep has no explicit "PO-flow self-label coherence" check that would have caught the mid-sequence collision (or the pre-existing pf3 command↔skill "Phase 4"/"Phase 5" split) before merge. This proposal fixes the symptom; a future audit-dimension hardening is a separate upstream-worthy idea, not bundled here (least-machinery).

## Rollback Plan

Purely textual, additive-equivalent relabeling. Rollback: `git revert` the squash commit, then `/f4-regen-framework` to restore the prior `.claude/` mirrors. No child-side action required (next `import-shamt` re-syncs). No one to notify beyond the normal landing.

## Validation Considerations

- **Surfaces affected:** commands + skills (descriptions only). No rules / templates / references / scripts / personas touched.
- **Hardest-to-get-right rows:** the five command files each carry the label in *two* spots (frontmatter `description:` **and** the `**Purpose:**` line) — except `pe4-finalize` (description only; Purpose has no number). The validator should confirm **both** spots were updated where applicable and that no stray third occurrence (e.g. a body cross-reference) was missed.
- **Negative checks (must stay unchanged):** the Engineer-flow "Phase 2 / 6 / 7" mentions in `pe1-define`/`pf1-define`; every lowercase `stage-N` occurrence (especially the `Scratch Notes (stage-0 capture)` heading); the already-correct `pe2`/`pf2`/`ps2`/`ps1` "Stage" labels; `README.md` and `SHAMT_RULES.template.md`.
- **Cross-document consistency to verify after edits:** every PO command/skill self-label now reads "Stage N" per the per-altitude grid (Epic: Stage 1→2→3→4; Feature: Stage 1→2→3; Story: Stage 1→2), monotonic at each altitude, no "Phase N" PO self-label remaining, and the `pf3` command↔skill numbers now agree.
- **Propagation:** `/f4-regen-framework` then `--check` for zero drift; confirm the `.claude/` command + skill mirrors carry the new labels.

## Resolved Questions

~~Q1: Which canonical numbering model should the PO-flow self-labels converge on — (A) per-altitude "Stage" numbering aligned to the README grid, or (B) a single flow-wide cross-altitude "Phase" sequence?~~ → **A — per-altitude "Stage" numbering, README-aligned.** Every altitude numbers draft=0/define=1/validate=2/decompose=3/finalize=4 and the noun is unified to "Stage" across the PO flow; "Phase" is reserved for the Engineer flow (1–8) and framework-update flow (0–7). Model B was rejected: it contradicts the recently-landed #41 per-altitude direction and would force churn on the already-clean README grid and the already-correct "Stage 2" validate labels.

~~Q2: Should this proposal also normalize the lowercase `stage-N` form (README grid/tables, `pe0`/`pf0`/`ps0`) to capital "Stage N"?~~ → **No — keep lowercase as-is; fix only the nine incoherent "Phase N" sites.** The lowercase form is mostly load-bearing (the matched `Scratch Notes (stage-0 capture)` heading contract) or a command-name-prefix echo (`0-draft`), not a cosmetic self-label, so recasing it is either risky or pointless. The capital/lowercase split is a meaningful convention and is preserved; documented in Risks.

## Open Questions

*(none — all resolved)*

<!-- Phase 2 validation appends the footer below on a clean exit. Do not pre-fill. -->

---
Validated 2026-06-21 — 1 round, 1 adversarial sub-agent confirmed
