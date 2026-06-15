# Proposal: scrub-stale-back-ref-header-language

**Created:** 2026-06-14
**Status:** Draft
**Number:** 29
**Proposed by:** [master-local]
**Project context:** [master-local]

---

## Problem

Proposal #14 (`po-nested-folder-layout`, archived) replaced the back-ref-header parentage model with **path-parentage**: a story/feature's parent is encoded by its folder path, not by `**Parent Epic:**` / `**Parent Feature:**` headers in the artifact body. The authoritative sources state this unambiguously — `templates/SHAMT_RULES.template.md:159` ("Parentage is encoded by the path — there are **no `**Parent Epic:**` / `**Parent Feature:**` back-ref headers**"), `README.md:150` ("There are no `**Parent Epic:**` / `**Parent Feature:**` back-ref headers … `/e1-start-story` derives parentage by walking up the resolved path"), and `README.md:175` ("derived by walking up the active-story pointer's path (not from back-ref headers)"). The **mechanism** matches: `statusline.sh` walks the path, `e1-start-story.md:128`'s live stub-detection keys off folder-path nesting, and `p4-decompose-feature.md:220` writes no headers.

But #14 did **not** fully scrub the leftover "back-ref header" language from three of the bodies it touched. Eight sites still describe — in Purpose blurbs, Notes asides, a validation footer, and one README status-line table — a header-reading mechanism that no longer exists, contradicting the authoritative model and, in two cases, contradicting **themselves** a few lines later. This is a D2/D9 (cross-doc consistency / duplication-contradiction) violation surfaced by the `/f5-audit-framework` sweep on 2026-06-14, classified **HIGH** (a live contradiction in the agent-instruction path sends two readers to two mental models) and **intricate** (coordinated multi-file edit + the e1 stub/freeform discriminator and the README status-line condition require phrasing judgment, not a mechanical synonym-swap).

The audit's own 7-site list was itself **incomplete**, and the reason is a second, systemic gap. The independent root-cause diagnosis (Opus `root-cause-diagnoser` + Haiku `validation-checker` confirmation, run during this proposal's authoring) found an 8th survivor the markdown-oriented sweep missed — `host/templates/claude/statusline.sh:196`, whose validation-footer comment reads "story rendering + **back-ref reader** preserved from Phase 7", asserting a reader that no longer exists. It was missed because the audit's terminology/scope dimensions are worded for markdown docs: `f5-audit-framework.md` D7 sweeps "all canonical **docs**", D8 "canonical **content**", D11 "the **agent-instruction path**", and `reference/audit_dimensions.md` mirrors the same doc-oriented wording (lines 22, 38, 40). The audit's read-surface list (`f5-audit-framework.md:34`) **does** already include `host/templates/claude/` and `scripts/`, so the surface is nominally in scope — but the dimension *verbs* read as "markdown only", so a retired-term leak into a managed shell-script comment/footer slips through. Closing only the prose-scrub instance would leave that class open for the next retired term.

## Proposed Changes

A flat list of canonical files the proposal will touch. Two tracks: the **prose scrub** (the 8-site instance, rows 1–4) and the **class fix** (the audit-dimension scope clarification, rows 5–6).

| # | Canonical path | Operation | One-line change description |
|---|----------------|-----------|------------------------------|
| 1 | `shamt-core/host/templates/claude/commands/p4-decompose-feature.md` | EDIT | **Purpose (line 7):** replace "back-ref headers for parent feature + scope one-liner" with path-parentage wording ("scope one-liner; parentage is the folder path"), removing the self-contradiction with the same line's parenthetical and with p4:220. **Step-8 Notes (line 199):** rewrite "`/e1-start-story` … detects the back-ref headers in `ticket.md` and preserves them" to "detects the stub by its nested folder path and preserves the scope one-liner", matching e1's actual path-based detection. |
| 2 | `shamt-core/host/templates/claude/commands/e1-start-story.md` | EDIT | **Stub case (line 46):** drop "the back-ref headers and" / "without rewriting the back-ref headers"; keep the scope one-liner as the preserved-verbatim element, consistent with the path-based detection already stated in the same sentence. **Freeform discriminator (line 47):** reword the stub-vs-freeform test to key off **path nesting** ("a populated `ticket.md` resolving to a flat/non-nested folder is a pre-existing freeform story"), aligning with e1:128 ("nested parentage is the signal"). **Validation footer (line 136):** change "Notes-section documentation of the back-ref-header signal" to "…of the path-nesting signal". |
| 3 | `shamt-core/README.md` | EDIT | **Status-line registration table — row 1 condition (line 318):** rewrite "when ticket.md carries `Parent Feature` / `Parent Epic` headers" to the real trigger ("when the active-story pointer's path has a parent feature / epic segment"), matching README:175 and the script. **Row 2 condition (line 319):** rewrite "when feature.md carries `**Parent Epic:**`" to "when the feature's path has a parent-epic segment — omitted for standalone features". (Condition column describes a *trigger*; rewrite the trigger, not a synonym.) |
| 4 | `shamt-core/host/templates/claude/statusline.sh` | EDIT | **Validation-footer comment (line 196):** rewrite "story rendering + back-ref reader preserved from Phase 7" to "story rendering + path-walk parentage preserved from Phase 7" (the script walks the path; no reader exists). |
| 5 | `shamt-core/host/templates/claude/commands/f5-audit-framework.md` | EDIT | **D7 (line 135), D8 (line 137), D11 (line 143):** clarify each dimension's sweep surface so the markdown-oriented verbs ("canonical docs" / "canonical content" / "agent-instruction path") explicitly include **managed shell scripts under `host/templates/claude/` and `scripts/` — their comments and validation-footer lines included** (the surface list at f5:34 already lists these dirs; this makes the dimension verbs cover non-`.md` text there). Smallest change that would have surfaced `statusline.sh:196`. |
| 6 | `shamt-core/reference/audit_dimensions.md` | EDIT | **D8 cell (line 22), D7 cell (line 38), D11 cell (line 40):** mirror the same surface clarification into the dimension-definition cells so "canonical body" / "canonical docs" / "the instruction path" explicitly cover managed shell-script comments/footers — keeping the reference catalog in step with the f5 body (D2 rules↔ref consistency). |

**Path discipline:** all six rows are EDITs on canonical sources (`host/templates/claude/`, `reference/`, root-level `README.md`). No `.claude/` paths. No paths outside the canonical allow-list. Row count = 6 ≤ 10, so no Phase 3 plan is required.

The authoritative sources (`templates/SHAMT_RULES.template.md:159`, `README.md:150`, `README.md:175`) are **already correct** and are **not** edited — they are the target wording the scrub aligns to.

---

## Risks

- **Regression risk** — Low. Every edit is a wording change to descriptive prose, a Notes aside, a footer comment, or a status-line table *condition* column. None touches an executable code path: `statusline.sh:196` is a comment line, and the README table documents (does not drive) the script. The e1 freeform-discriminator reword (row 2) is the one edit with behavioral phrasing — it must be reworded to the **path-nesting** test that e1:128 already specifies, so it aligns two already-present statements rather than introducing new logic.
- **Drift risk** — Rows 1, 2, 4, 5 edit files under `host/templates/claude/`, so `/f4-regen-framework` must run after the edits or `.claude/` falls out of sync (itself a D1 finding). Rows 3 (README) and 6 (reference) are canonical-only, no regen needed, but the regen in Phase 5 covers the whole change set.
- **Child-project compatibility** — Clean. Installed children pick up the rewordings on the next `import-shamt` like any other canonical edit; no manual reconciliation. The change is purely textual and removes contradictions, so no child-side behavior shifts.
- **Open-questions debt** — None. The one design decision (close the class vs. split it) was resolved in the open-questions dialog (close the class).
- **Class-fix over-reach risk (rows 5–6)** — The audit-dimension clarification widens what the sweep is expected to read, which could surface previously-tolerated findings in script comments on the next audit. This is the intended effect, not a regression; any such finding is a genuine retired-term leak.

---

## Rollback Plan

1. `git revert <commit-sha>` on the squash commit (`shamt-core: land #29 scrub-stale-back-ref-header-language (…)`).
2. Run `/f4-regen-framework` to propagate the revert into `.claude/` (rows 1, 2, 4, 5 are under `host/templates/claude/`).
3. No child-side action required beyond the next routine `import-shamt`.
4. Communication: none needed — the change only removes contradictory wording and clarifies audit scope.

---

## Validation Considerations

- **Problem clarity** — The Problem distinguishes the **instance** (8 stale prose/footer sites) from the **class** (audit dimensions worded markdown-only). Verify the validator does not conflate "the mechanism is wrong" (it is not — the mechanism is path-based everywhere) with "the prose describing it is stale" (it is). Every cited line number should be spot-checked against the live files, since line numbers drift.
- **Change-list completeness** — The cross-check that matters: do the **command bodies** carry the stale language while their **SKILL.md mirrors** do not? Confirmed during authoring — the p2/p3/p4/e1 SKILL.md files use "parent feature/epic" only as the *relationship* concept (correct), never as `Parent Feature:` header language, so no skill row is needed. Re-verify this, plus confirm no 9th survivor exists (grep `back-ref` / `Parent Feature` / `Parent Epic` headers across `templates/`, `reference/`, `host/templates/claude/`, `README.md`, `CLAUDE.md`, excluding the correct "no back-ref headers" affirmations and the `epics/`/`features/` relationship mentions).
- **Risk coverage** — The e1 freeform-discriminator reword (row 2) is the highest-judgment edit; verify the reworded test is logically equivalent to e1:128's "nested parentage is the signal" and does not invert the stub/freeform branches.
- **Rollback feasibility** — All EDITs, no DELETE/MOVE, no git-history loss. Revert is a clean single-commit revert + regen.
- **Affected surfaces** — Commands (p4, e1, f5), a script (statusline.sh), a root doc (README), a reference (audit_dimensions.md). Cross-doc consistency to verify: rows 5↔6 (f5 body ↔ reference catalog must agree, D2); row 3 ↔ README:175/150 (status-line table ↔ narrative must agree); rows 1–4 ↔ the authoritative sources (SHAMT_RULES:159, README:150/175).
- **Propagation plan** — Requires `/f4-regen-framework` (rows 1, 2, 4, 5 under `host/templates/claude/`). Already-installed children pick it up on the next `import-shamt`; no manual nudge.

---

## Open Questions

*(none — resolved below)*

---

## Resolved Questions

- ~~Q: Should this proposal also close the systemic class (sharpen the f5 D7/D8/D11 dimension verbs + the `audit_dimensions.md` mirror so managed shell-script comments/footers are explicitly in audit scope), or stay scoped to the 8-site prose scrub?~~ → A: **Close the class.** Include rows 5–6 (f5-audit-framework.md + audit_dimensions.md) alongside the prose scrub. Matches the incident-origin default stance — fix the gap that let the term leak into a script, not just the instance — so the next retired-term leak into a non-`.md` canonical surface is caught by the audit.
