# Proposal: agents-trust-cross-session-provenance

**Created:** 2026-06-15
**Status:** Implemented
**Number:** 33
**Proposed by:**
**Project context:**

---

## Problem

Shamt is multi-session and parallel **by design**. Multiple agents author and update proposals, run personas (`root-cause-diagnoser`, `validation-checker`, `audit-checker`, …), and advance stories concurrently — the slug-resumability contract (`templates/SHAMT_RULES.template.md` Principle 1; `host/templates/claude/commands/sync-triage-proposals.md` explicitly licenses parallel sessions) is built on the premise that on-disk artifacts, not any one agent's conversation history, are the record of work performed. Yet the framework states this premise **only implicitly** — the "Fresh-agent runnable. No conversation history required." note recurs in 10+ command bodies, but it encodes disk-authority for the *fresh agent's resume* case, never the general rule binding a **session-having** agent that encounters work outside its own history.

The gap surfaced concretely during a live `/f-all 27` run. The driver encountered an on-disk proposal (`32-d5-…`) carrying the provenance line *"Confirmed root cause (adversarial diagnosis — Opus `root-cause-diagnoser` + Haiku zero-bias confirmation, 2026-06-15)"*. Because the driver's **own session** had not spawned a `root-cause-diagnoser`, it concluded the provenance was **fabricated** and reverted the work. The assumption was false: a *different, parallel session* had genuinely run the diagnoser. The work was real; the current session simply had no visibility into it.

**The root cause (confirmed by an adversarial Opus `root-cause-diagnoser` diagnosis + Haiku zero-bias confirmation, 2026-06-15):** the framework carries **no normative cross-cutting principle** establishing that on-disk artifacts are the authoritative record of cross-session work and an agent's session history is not. The missing instruction is the *contrapositive* of the implicit disk-authority assumption — an agent must not infer that "I did not perform or observe X this session" means "X never happened," and must not distrust, revert, or delete an on-disk artifact on that basis. This is the **belief-angle** of the same gap the sibling f0 `proposals/f-all-accept-and-fold-parallel-work.md` attacks from the **action-angle** (agents `git checkout`/`rm`-reverting in-tree parallel work). The existing "never halt or revert on unrelated tree state" rules in `host/templates/claude/commands/f3-implement-update.md` and `host/templates/claude/commands/f6-archive-proposal.md` are the action consequence of the missing belief principle — the framework already half-knows the rule but lacks its principled altitude. The error class is **not** driver-specific: it can fire in any agent that reads on-disk state it didn't author — `validation-checker` re-reading a footer, `/e7-resolve-feedback` reading a prior session's feedback, `audit-checker` scanning `proposals/` for already-captured findings — so the fix must bind every agent, not just the two flow-drivers.

---

## Proposed Changes

A flat list of canonical files the proposal will touch. **Every file the proposal will edit, create, delete, or move must appear here** — Phase 2 (validate-artifact) and Phase 4 (implement-update) both read this list as the source of truth for change scope.

| # | Canonical path | Operation | One-line change description |
|---|----------------|-----------|------------------------------|
| 1 | `shamt-core/templates/SHAMT_RULES.template.md` | EDIT | Add **Principle 3 — Disk-authoritative cross-session work** to §Cross-Cutting Design Principles, after Principle 2 (the four-bullet text drafted under "Principle 3 wording" below); update the section preamble "These two principles apply…" → "These three principles apply…" (line 36); **and** update the file-header **Purpose** line (line 4) "…and the two cross-cutting design principles" → "…three cross-cutting design principles" (stale count claim). Principle 2's closing "Applies to every artifact-generation flow…" stays as-is. Child-facing — renders into every child's `CLAUDE.md`. |
| 2 | `shamt-core/CLAUDE.md` | EDIT | Rename §"Two cross-cutting principles you must follow" → "Three cross-cutting principles you must follow"; add a master-side mirror of Principle 3 (condensed) after the Open-questions principle; update the `/f-all` reconciliation paragraph's stale count phrase "the doc that already states the **two** principles are 'inherited by every flow Shamt defines'" → "three principles"; and reword the line under the heading "**Both** are normative … **They** are inherited by every flow Shamt defines" — "Both"/"They" reads as a dual-count claim — to "**All** are normative … they are inherited by every flow Shamt defines". |

**Principle 3 wording** (child-facing `SHAMT_RULES.template.md` form; the `CLAUDE.md` mirror is a condensed paraphrase):

> ## Principle 3: Disk-authoritative cross-session work
>
> Shamt is multi-session and parallel by design: multiple agents author and update artifacts, run personas, and advance work concurrently (per the slug-resumability rule, items can be worked in any order across parallel sessions). The on-disk artifacts — not any one agent's conversation history — are the authoritative record of work performed.
>
> 1. **Disk is the record; the session is not.** An agent reasons about what work has occurred from on-disk artifacts (proposals and their footers/banners, story folders, `feedback/`, `active_artifacts.md`, the archive/deferred/rejected folders) and from git history — never from the assumption that its own session observed everything.
> 2. **Absence-from-session is not evidence of fabrication.** An agent must not infer that "I did not perform or observe X in this session" means "X never happened." A provenance claim recorded in an artifact (a validation footer, an f0 capture banner, a `Confirmed root cause (adversarial diagnosis — …)` line, a tracker attribution) is **presumed genuine** — a parallel session did real work the current session has no visibility into.
> 3. **Verify by reading, never by destroying.** If a cross-session claim genuinely needs verification, the evidence is git history across branches, the cited artifact/folder, or the user — never silent deletion, revert, or rename-back of the artifact. (This is the belief the existing "never halt or revert on unrelated tree state" rules in `/f3-implement-update` and `/f6-archive-proposal` already depend on.)
> 4. **This does not relax Pattern 1.** Pattern 1's adversarial validation still distrusts unsupported *claims about reality* (code, governing docs) and verifies them from evidence, and agents still never fabricate a claim of work they did not do. Session-absence is simply not the evidence Pattern 1 demands: distrusting a claim about the codebase is in scope; distrusting an artifact's cross-session **provenance** merely because this session didn't author it is not.

**`CLAUDE.md` master-mirror (exact text to add):** the condensed prose subsection added under §"Three cross-cutting principles you must follow", after the `### Open-questions iterative dialog` subsection — matching that section's `### {Title}` + short-prose house style (not the four numbered bullets, which live only in the child-facing rules file):

> ### Disk-authoritative cross-session work
>
> Shamt is multi-session and parallel by design — multiple agents author and update artifacts, run personas, and advance work concurrently — so the on-disk artifacts, not any one agent's conversation history, are the authoritative record of work performed.
>
> An agent must not treat the fact that it "did not perform or observe X this session" as evidence that X never happened, and must never distrust, revert, rename-back, or delete an artifact on that basis. A parallel session does real work the current session has no visibility into, so a provenance claim recorded in an artifact (a validation footer, an f0 capture banner, a `Confirmed root cause (adversarial diagnosis — …)` line) is presumed genuine. If such a claim genuinely needs verifying, the evidence is git history across branches, the cited artifact/folder, or the user — never silent deletion.
>
> This does **not** relax Pattern 1: its adversarial validation still distrusts unsupported claims about reality (code, governing docs) and verifies them from evidence, **and agents still never fabricate a claim of work they did not do**. Session-absence is simply not the evidence Pattern 1 demands.

**Path discipline:**

- **EDIT** rows name the exact section the edit lands in (above).
- Generated `.claude/` files are **never** listed; regen (Phase 5) propagates Principle 3 into every child's rendered `CLAUDE.md` and into the `.claude/` command/skill copies if rows 3+ are added.

Row count is **2** (final, per the resolved Open Questions — principle-only, no driver/command reinforcement rows) — well under the 10-op Phase-3 threshold, so no `/f2-plan-update-implementation` is required.

---

## Risks

- **Regression risk** — Low. Principle 3 is additive normative text; it does not change any existing flow's mechanics. The one behavioral change is *suppressing* a harmful reflex (false-fabrication revert), which is the intended effect.
- **Pattern 1 contradiction risk** — **The load-bearing risk.** A carelessly-worded Principle 3 could read as "trust all on-disk claims," undercutting Pattern 1's distrust-by-default and the never-fabricate stance (the `f-all-validation-primary-fabricates-footer` failure, where an agent *claimed* work it didn't do). Bullet 4 of the drafted wording is the explicit reconciliation — validation distrusts claims-about-reality and verifies from evidence; session-absence is simply not such evidence. Phase 2 must scrutinize this bullet hardest.
- **Drift risk** — Standard: the child-facing edit (row 1) only takes effect in children after regen + `import-shamt`. The master `CLAUDE.md` mirror (row 2) is not regenerated (CLAUDE.md is hand-written). Keep the two homes consistent.
- **Child-project compatibility** — Clean. Purely additive rules text; installed children pick it up on the next `import-shamt`. No manual reconciliation.
- **D9 duplication/contradiction risk with the sibling proposal** — **Resolved (Q2):** the two land **separately and cross-reference**. This proposal owns **Principle 3** (belief-angle); the sibling `f-all-accept-and-fold-parallel-work` owns the `/f-all` + `/e-all` driver "never revert" **action-rule**, worded as a *consequence* of Principle 3 ("per Principle 3, … never revert"). Each references the other. To keep the two independently-landing proposals off the same files (the D9 trigger), this proposal stays principle-only and leaves the driver-body action edits to the sibling.
- **Rules-file size (D12)** — The rules file is 431 lines against its size budget; Principle 3 adds ~12–15 lines. Modest but non-zero; the wording is kept compact and the master mirror condensed. (Scope confirmed at full Principle 3, both homes — resolved Q1.)
- **Open-questions debt** — Three open questions (scope/home, sibling coordination, driver reinforcement) are resolved in the dialog before this proposal is considered drafted.

---

## Rollback Plan

1. `git revert <commit-sha>` on the canonical edit commit (removes Principle 3 from `SHAMT_RULES.template.md` and `CLAUDE.md`, plus any reinforcement rows).
2. Run `/f4-regen-framework` to propagate the revert into `.claude/` and the rendered child `CLAUDE.md`.
3. Child-side action: re-run `/sync-import-shamt` on each installed child to drop the principle. (Harmless to leave — it is additive guidance.)
4. Communication: none beyond the normal landing note.

Purely additive — rollback is `git revert` + regen.

---

## Validation Considerations

Dimension hints for the Phase 2 validation loop (`/validate-artifact proposals/33-agents-trust-cross-session-provenance.md`):

- **Problem clarity** — The Pattern 1 vs. Principle 3 boundary is the term most likely to be misread. Verify the Problem and bullet 4 make crisp the distinction between a *claim about reality* (Pattern 1 verifies from evidence) and a *cross-session provenance claim* (session-absence ≠ fabrication).
- **Change-list completeness** — The paired edit is the `SHAMT_RULES.template.md` ↔ `CLAUDE.md` mirror: both must state Principle 3 consistently (master "Three…" heading + child "These three…" preamble). Beyond the principle text itself, **every stale dual-count claim** must flip with it: `SHAMT_RULES.template.md` line 4 Purpose ("the two cross-cutting design principles"), `CLAUDE.md` line 51 `/f-all` reconciliation ("the doc that already states the two principles…"), and `CLAUDE.md` line 59 ("Both are normative … They are inherited"). A canonical-tree sweep for `two cross-cutting` / `two principles` / `Both are normative` confirmed these are the only count-claim sites; references to `Principle 1`/`Principle 2` individually need no edit. No command/skill rows (resolved principle-only).
- **Risk coverage** — Hardest scenario: an agent reading Principle 3 as license to *stop* validating provenance claims entirely. Confirm bullet 4 forecloses that reading.
- **Rollback feasibility** — Trivial (additive); no destructive DELETE/MOVE.
- **Affected surfaces** — Rules (child-facing) + master primer only. No command/skill, reference-doc, or persona edits (the diagnosis ruled persona edits non-load-bearing — `audit-checker`/`validation-checker`/`root-cause-diagnoser` distrust the artifact *under review*, orthogonal to outer cross-session state). Cross-doc consistency to verify: the master/child Principle-3 mirror states the same rule consistently.
- **Propagation plan** — Requires regen + child import for the child-facing principle to take effect. No special nudge beyond the normal `import-shamt`.

---

## Open Questions

_(none — all resolved; see Resolved Questions below.)_

---

## Resolved Questions

<!-- Append as questions resolve. -->

- ~~Q1: Scope/home — full cross-cutting Principle 3 vs. narrower driver-only vs. master-only?~~ → A: **Full Principle 3 in both homes** (`SHAMT_RULES.template.md` child-facing + condensed `CLAUDE.md` mirror). Rationale: the false-fabrication error binds every agent reading on-disk state it didn't author (by-hand phases, personas), not just the flow-drivers — so the principle must live at the cross-cutting altitude beside Principles 1–2. (Rows 1–2 reflect this.)
- ~~Q2: Sibling coordination with `f-all-accept-and-fold-parallel-work` (D9)?~~ → A: **Separate, cross-reference, land independently.** This proposal owns Principle 3 (belief); the sibling owns the `/f-all`+`/e-all` driver "never revert" action-rule, worded "per Principle 3". To avoid two independently-landing proposals racing on the same files (the D9 trigger), this one stays principle-only and leaves the driver-body edits to the sibling.
- ~~Q3: Driver-body reinforcement — principle-only vs. add "per Principle 3" pointers here?~~ → A: **Principle-only (rows 1–2).** The `/f-all` + `/e-all` "per Principle 3" pointers ride along in the sibling proposal (which already edits those bodies), so the two proposals never touch the same files. Principle 3 binds the dispatched/by-hand agents regardless — they read the rules. No rows 3+.

---

Validated 2026-06-15 — 4 rounds, 1 adversarial sub-agent confirmed
