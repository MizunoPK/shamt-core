# Proposal: f-all-accept-and-fold-parallel-work

**Created:** 2026-06-15
**Status:** Draft
**Number:** 34
**Proposed by:**
**Project context:**

---

## Problem

Shamt is multi-session and parallel **by design** — the framework openly assumes "we always have a user working on new proposals or updating proposals in parallel to an ongoing proposal implementation" (`host/templates/claude/commands/sync-triage-proposals.md`), and the slug-resumability contract (Principle 1) is built on on-disk artifacts being the record of work. The two **flow-drivers** — `/f-all` (the framework-update meta-driver) and `/e-all` (the Engineer-flow story driver) — dispatch one independent sub-agent per phase across that shared, concurrently-mutated working tree.

During a live `/f-all 27` run the driver and its dispatched per-phase agents **repeatedly reverted unrelated in-tree proposal work**. Two f0 stubs that *other parallel sessions* had renamed + fleshed out into numbered proposals (`32-d5-…` and `33-agents-trust-cross-session-provenance`) were treated as "stray off-script edits" and `git checkout`/`rm`-reverted phase after phase. This destroyed legitimate parallel work — `33` was briefly unrecoverable, its content gone before it was captured. **This is irreversible data loss caused by the driver, on the exact parallel-authoring pattern the framework says is normal.**

The correct rule already exists in the framework — but only at two commands, not at the drivers. `/f3-implement-update` and `/f6-archive-proposal` both state it in their bodies (and skill mirrors):

> `/f6-archive-proposal.md:54` — "Unrelated tree state — ad-hoc proposal captures or other in-progress work — is expected and accepted; it folds into this landing; **never halt or revert on it.**"
> `/f3-implement-update.md:34` — "Unrelated working-tree state is **expected and accepted** … **Never halt or revert on unrelated tree state.**"

Neither flow-driver carries any equivalent. A grep of `host/templates/claude/commands/f-all.md`, `host/templates/claude/skills/f-all/SKILL.md`, `host/templates/claude/commands/e-all.md`, and `host/templates/claude/skills/e-all/SKILL.md` finds **no** revert / accept-and-fold / "unrelated tree state" language.

**Root cause (confirmed by an adversarial Opus `root-cause-diagnoser` diagnosis + Haiku zero-bias confirmation, 2026-06-15).** It is *not* enough to say "the drivers lack the rule." `/f-all` dispatches `/f3` and `/f6` as self-contained agents that **do** inherit those commands' accept-and-fold rule — yet the revert still happened. The gap is at the two surfaces of the drivers that touch the tree **without** running `/f3` or `/f6`:

1. **The driver itself, between phases (the load-bearing gap).** The driver derives its start phase from disk (Step 1) and inspects each phase's report (Step 3), scanning `proposals/` and classifying tree state as clean / inconsistent. Its strict-halt machinery trains it to be suspicious of anything it cannot map to a contract — and it carries **zero** counter-rule that unrelated in-tree proposal work is *expected and accepted*. This is where the revert reflex (compounded by operator-memory notes about reverting *the agent's own* stray edits) bleeds in, with nothing to stop it.
2. **The inline-step phases that never run `/f3`/`/f6`.** Per `/f-all`'s dispatch topology (Step 2, "the infeasible approach, ruled out"), the Phase 2 validation primary, the Phase 3 plan-validation primary, and the **Phase 6 audit primary** run *inline instructions*, explicitly **not** the `/fX` command — so they never see the accept-and-fold rule that lives in the `/f3`/`/f6` command bodies. The audit primary in particular sweeps `proposals/` and is the most likely site to "tidy" an unfamiliar stub. (`/f-all`'s Phase 4 architect/builder path, by contrast, runs `/f3`'s *inline steps*, which already state the rule at `f3-implement-update.md:116` — so it inherits it; the gap is the validation/audit inlines and the driver's own disk inspection.)

The error class is **not** `/f-all`-specific. `/e-all` has the identical inline-phase topology (Phases 2/3/3b/6 run inline validation; the driver inspects disk between phases), and `/e7-resolve-feedback` (Phase 7) *actively writes* to `.shamt-core/proposals/` when routing generalizable root causes — so an `/e-all` run is exposed to the same loss, and additionally must not revert *other* proposals when its own `/e7` adds one.

**This is the action-angle of a single gap.** Its sibling, `proposals/33-agents-trust-cross-session-provenance.md`, attacks the **belief-angle** (an agent must not infer "I didn't see X this session" ⇒ "X never happened") by adding a new cross-cutting **Principle 3 — Disk-authoritative cross-session work** to the rules file + primer. The existing "never halt or revert on unrelated tree state" rules in `/f3` and `/f6` are the *action consequence* of that belief principle; this proposal extends that action consequence to the two flow-drivers, where it is currently missing. The two proposals are deliberately coordinated to land **separately, off the same files** (a D9 duplication-avoidance decision): `33` owns the rules-file principle (`templates/SHAMT_RULES.template.md`, `CLAUDE.md`); this proposal owns the driver-body action-rule (the four host `f-all`/`e-all` files). Each cross-references the other.

---

## Proposed Changes

A flat list of canonical files the proposal will touch. **Every file the proposal will edit, create, delete, or move must appear here** — Phase 2 (validate-artifact) and Phase 4 (implement-update) both read this list as the source of truth for change scope.

| # | Canonical path | Operation | One-line change description |
|---|----------------|-----------|------------------------------|
| 1 | `shamt-core/host/templates/claude/commands/f-all.md` | EDIT | Add the **accept-and-fold invariant** as a first-class driver rule, at three reinforcing sites: (a) **load-bearing** — a clause in the Step 2 dispatch-prompt guidance + the Step 3 sentinel paragraph instructing that *every dispatched phase agent's prompt* must carry "unrelated in-tree work already present on entry is expected and accepted — never revert/rename-back/delete it; you may revert only your own this-dispatch off-task edits"; (b) a Step 1 strict-halt clarification that unrelated `proposals/` additions are **not** an "inconsistent state" the driver halts/reverts on; (c) a Notes bullet ("Never revert parallel work") cross-referencing the live `/f3`/`/f6` accept-and-fold rule and (forward-compatibly) Principle 3. |
| 2 | `shamt-core/host/templates/claude/skills/f-all/SKILL.md` | EDIT | Mirror the invariant into the Protocol summary — one clause in point 1 (start-derivation: unrelated additions ≠ inconsistent state) and point 3/4 (dispatch topology / advance-pause-halt: the dispatch prompt carries "never revert parallel work"). Keep the command ↔ skill wording consistent. |
| 3 | `shamt-core/host/templates/claude/commands/e-all.md` | EDIT | Same invariant as row 1, adapted to `/e-all`: Step 1 strict-halt clause, Step 2/Step 3 dispatch-prompt + sentinel clause, Notes bullet. **Additionally** note that because `/e7-resolve-feedback` (Phase 7) writes to `.shamt-core/proposals/` when routing root causes, the driver must not revert *other* proposals present alongside the one `/e7` adds. *(Conditional on Open Question 1 resolving "both drivers".)* |
| 4 | `shamt-core/host/templates/claude/skills/e-all/SKILL.md` | EDIT | Mirror the invariant into `/e-all`'s Protocol summary (points 1 and 3/4), matching the command. *(Conditional on Open Question 1 resolving "both drivers".)* |

**Path discipline:**

- All four rows are **canonical host-template** paths (`host/templates/claude/…`), not generated `.claude/` paths. Regen (Phase 5) propagates them into each child's `.claude/`.
- **Deliberately OFF `33`'s files.** This proposal does **not** touch `templates/SHAMT_RULES.template.md` or `CLAUDE.md` — those are `33`'s, where Principle 3 lives. The two proposals share the concept but not the files (D9).
- Paired edits: each command ↔ its SKILL.md mirror (rows 1↔2, 3↔4).

**The load-bearing edit is the dispatch-prompt clause, not the Notes bullet.** A dispatched phase agent runs in a fresh context and reads only what its dispatch prompt carries — a Notes bullet is documentation the agent never sees. The Notes bullet documents the invariant for a human reading the command; the **dispatch-prompt clause (Step 2/Step 3) is what actually reaches each inline phase agent** and is the edit Phase 2 validation must confirm landed.

Row count is **4** (or **2** if Open Question 1 scopes to `/f-all` only) — well under the 10-op Phase-3 threshold, so no `/f2` implementation plan is required.

**Author-vs-revert wording (the highest-risk line).** The invariant must disambiguate on **provenance + timing**, not on "is this proposal unfamiliar to me," so it coexists with — rather than contradicts — the existing guardrails against an agent's *own* off-script authoring (the operator-memory `f-all-primary-fleshes-out-stray-f0-drafts` / `root-cause-diagnoser-off-script-edits` reflex, and `/f3`'s in-place-amendment path):

- **Authored by *this* agent *this* dispatch, off-task** → may be reverted (it is the agent's own scope creep — the existing guardrail stands).
- **Already present in the tree on entry / authored by another session** → **accepted, never reverted** (it folds into the landing, exactly as `/f3`/`/f6` already specify for their own phases).

The disambiguator is simply: *was it already there when this phase agent started, or did this agent create it?* This is the same two-case split `/f3-implement-update.md:116` already encodes (unrelated/parallel state → never revert; the agent's own genuinely-missing change → in-place amendment).

---

## Risks

- **Regression risk** — Low. The change is additive normative text on two convenience drivers; it changes no phase mechanics. The one behavioral change is *suppressing* a harmful reflex (reverting parallel work), which is the intended effect.
- **Author-vs-revert contradiction risk** — **The load-bearing risk (HIGH).** A flat "never revert in-tree proposal work" would contradict the existing guardrails against an agent's *own* this-run off-script authoring (`f-all-primary-fleshes-out-stray-f0-drafts`, `root-cause-diagnoser-off-script-edits`) and `/f3`'s in-place-amendment path — a D9 contradiction, and worse, an ambiguous rule that could re-enable the wrong revert and re-cause the irreversible loss this proposal exists to stop. The mitigation is the explicit provenance+timing disambiguation in Proposed Changes (this-dispatch own edit = revertable; already-present/parallel = accepted). Phase 2 must scrutinize this wording hardest.
- **Documentation-only-patch risk (HIGH)** — If the invariant lands *only* as a Notes bullet and never in the Step 2/Step 3 dispatch-prompt text, it is documentation the inline phase agents never read, and the loss class stays open. Phase 2 must confirm the rule lands in the dispatch-prompt/sentinel surface, not solely in Notes.
- **D9 duplication/contradiction with the sibling proposal** — **Resolved (Q2 of `33`):** the two land **separately and cross-reference**. This proposal owns the `/f-all` + `/e-all` driver action-rule; `33` owns Principle 3. To keep two independently-landing proposals off the same files (the D9 trigger), this proposal touches only the four host driver files and leaves all rules-file/primer edits to `33`.
- **Dangling-reference risk (MEDIUM)** — `33` (Principle 3) may land before or after this proposal. The wording must not hard-depend on Principle 3 existing. Mitigation (Open Question 2): state the rule self-standingly, anchored on the **live** `/f3`/`/f6` accept-and-fold rules (which exist on master today), with Principle 3 named as a forward-/back-compatible elevating reference ("the action consequence of the disk-authoritative cross-session-work principle — Principle 3 in the rules file once `agents-trust-cross-session-provenance` lands").
- **Drift risk** — Standard: the host-template edits only reach children after regen + `import-shamt`. `/f4-regen-framework` (Phase 5) propagates them into `.claude/`; the `--check` confirms zero drift.
- **Child-project compatibility** — Clean. `/e-all` is child-facing, so children pick up the `/e-all` rule on the next `import-shamt`; `/f-all` is master-only and unaffected in children.

---

## Rollback Plan

1. `git revert <commit-sha>` on the canonical edit commit (removes the accept-and-fold invariant from the `f-all`/`e-all` command + skill files).
2. Run `/f4-regen-framework` to propagate the revert into `.claude/` (and, for `/e-all`, the rendered child copies).
3. Child-side action: re-run `/sync-import-shamt` on each installed child to drop the `/e-all` rule. (Harmless to leave — it is additive guidance.)
4. Communication: none beyond the normal landing note.

Purely additive — rollback is `git revert` + regen. No destructive DELETE/MOVE.

---

## Validation Considerations

Dimension hints for the Phase 2 validation loop (`/validate-artifact proposals/34-f-all-accept-and-fold-parallel-work.md`):

- **Problem clarity** — Confirm the Problem makes crisp the three-site root cause (driver between-phase disk inspection; inline validation/audit phases; the dispatch prompt as the only channel reaching them) rather than the coarser "the drivers lack the rule." The author-vs-revert distinction is the term most likely to be misread.
- **Change-list completeness** — The paired edits are command ↔ SKILL.md (rows 1↔2, 3↔4). Confirm the **load-bearing** dispatch-prompt clause (Step 2/Step 3), not just the Notes bullet, is in scope for each command. If Open Question 1 scopes to `/f-all` only, rows 3–4 drop and the count is 2.
- **Risk coverage** — Two HIGH risks dominate: (1) the author-vs-revert wording contradicting the existing own-stray-edit guardrails; (2) a documentation-only patch that never reaches the inline agents. Confirm the proposal forecloses both.
- **D9 / dangling-reference** — Confirm this proposal stays off `33`'s files (`SHAMT_RULES.template.md`, `CLAUDE.md`) and that the Principle-3 cross-reference is robust to either landing order (anchored on the live `/f3`/`/f6` rules).
- **Rollback feasibility** — Trivial (additive); no destructive operations.

---

## Resolved Questions

*(none yet)*

---

## Open Questions

1. **Scope: `/f-all` only, or both `/f-all` and `/e-all`?** The incident occurred in `/f-all`. `/e-all` (landed 2026-06-15, #27) has the identical inline-phase topology and its `/e7` writes to `.shamt-core/proposals/`, so it carries the same loss exposure — but it has not had the incident, and including it doubles the file count (2 → 4). The sibling `33` frames the gap as binding "both flow-drivers," and the diagnosis recommends both. *(Recommended: both — same architecture, same exposure, preventive parity.)*
2. **Principle-3 cross-reference wording.** How should the rule reference Principle 3 so it does not dangle if this proposal lands before `33`? *(Recommended: state the rule self-standingly on the live `/f3`/`/f6` accept-and-fold rules, with Principle 3 named as a forward-/back-compatible elevating reference — "once `agents-trust-cross-session-provenance` lands.")*
