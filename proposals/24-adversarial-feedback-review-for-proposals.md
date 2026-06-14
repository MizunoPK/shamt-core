# Adversarial, Independent Root-Cause Diagnosis When Drafting Incident-Originated Proposals

**Created:** 2026-06-14
**Status:** Draft
**Number:** 24
**Proposed by:**
**Project context:**

---

## Problem

When a Shamt framework-update proposal originates from a **bug or a piece of feedback** — a Phase-5 test failure routed to `/e7-resolve-feedback`, a recurring review finding, a child-submitted issue, or an audit capture — the drafting in `/f1-propose-update` currently relies on the **primary agent alone** to diagnose what went wrong and decide the fix. The command body (`host/templates/claude/commands/f1-propose-update.md` Step 2 "Draft the Problem section") tells the agent to "state the concrete problem" and "verify and sharpen" a seed against the canonical sources, but it adds **no independent, zero-bias check** that the diagnosis reaches the true root cause rather than the first plausible one. The agent that drafts the proposal is the same agent that decided what the problem is — there is no skeptic.

This is a gap relative to the rest of the framework, which already treats independent adversarial review as load-bearing everywhere a conclusion matters: `/validate-artifact` spawns a zero-bias `validation-checker` sub-agent (`templates/SHAMT_RULES.template.md` Pattern 1 Step 7), `/f5-audit-framework` spawns an `audit-checker`, and `reference/model_selection.md:15` pins **root-cause analysis** to the Reasoning (Opus) tier. The one place that *produces* the root-cause diagnosis a framework change is built on — proposal drafting — has none of that rigor. `/e7-resolve-feedback` Step 2 already forces a phase-attributed root cause for a Phase-5 bug and Step 5 routes generalizable root causes into `.shamt-core/proposals/`, but once the proposal reaches `/f1-propose-update` that root cause is taken at face value and developed without challenge.

The intended behaviour: when a proposal is **incident-originated** (bug / feedback / issue), `/f1-propose-update` should (a) adopt the default stance that the incident indicates a *genuine framework gap requiring a Shamt update* — not a one-off to paper over — and (b) drive an **independent, adversarial, zero-bias root-cause diagnosis** (one or more sub-agents with no stake in the first explanation) to determine what actually went wrong and what the fix should be, folding that diagnosis into the Problem + Proposed Changes before the open-questions dialog. Proactive / non-incident proposals (a clean-slate improvement, a new recipe) are unaffected.

---

## Proposed Changes

> Provisional — several rows are gated on the Open Questions below (mechanism/tier, rules-stance placement, e7 linkage). Finalized once the dialog resolves.

| # | Canonical path | Operation | One-line change description |
|---|----------------|-----------|------------------------------|
| 1 | `host/templates/claude/commands/f1-propose-update.md` | EDIT | Add an **incident-origin detection + adversarial root-cause diagnosis** step (between Step 2 Problem and Step 3 Proposed Changes): detect incident origin, adopt the "assume a Shamt update is warranted" default stance, spawn the independent zero-bias diagnoser(s), fold the diagnosis into Problem + Proposed Changes. |
| 2 | `host/templates/claude/skills/f1-propose-update/SKILL.md` | EDIT | Mirror the new step into the skill summary + frontmatter description (rule ↔ mirrored skill pairing). |
| 3 | `reference/model_selection.md` | EDIT | Add a Sub-agent-roster row for the new Opus `root-cause-diagnoser` persona, and note that its diagnosis is adversarially confirmed by a Haiku zero-bias sub-agent (reusing the Pattern 1 contract). |
| 4 | `host/templates/claude/agents/root-cause-diagnoser.md` | CREATE | New Opus root-cause-diagnoser persona: zero-bias, distrust-by-default; given the incident + canonical sources, determines the true root cause and recommends the fix. The Haiku confirmation reuses the existing Pattern 1 adversarial sub-agent contract — no second new persona. |
| 5 | _(gated on OQ4)_ `host/templates/claude/commands/e7-resolve-feedback.md` + mirrored skill | EDIT | Make Step 5's bug→proposal routing point at the new f1 diagnosis step, if explicit linkage is wanted. |

Cross-checks: rule (5) ↔ template; command (1) ↔ mirrored skill (2); command (6) ↔ its mirrored skill; reference (3) ↔ the rule/command bodies that cite the tier. Final row count depends on the Open Questions; if it exceeds 10, the Phase 3 note will be added.

---

## Risks

- **Regression risk** — a new mandatory diagnosis step could slow or block *every* f1 run if incident-origin detection is too broad; mis-scoping (OQ1) is the main lever. Keeping it gated to incident-originated proposals contains the blast radius.
- **Cost risk** — spawning Opus diagnosers on every incident proposal is expensive; tier choice (OQ2) trades depth against cost. `model_selection.md` already warns that one Opus loop costs more than 10 Haiku passes.
- **Drift risk** — f1 command ↔ mirrored skill, and (if touched) the rules-template stance ↔ any reference pointer, must move together or `--check` regen drift appears.
- **Child-project compatibility** — additive command/skill text propagates cleanly on the next `import-shamt`; no manual reconciliation. A new agent persona file (OQ2) is likewise additive.
- **Open-questions debt** — the four design forks below must be resolved before this proposal is "drafted"; none should survive into validation.
- **Overlap risk** — must not duplicate `/e7-resolve-feedback`'s existing phase-attributed root-cause requirement; the f1 step *consumes/deepens* that root cause, it does not replace it.

---

## Rollback Plan

1. `git revert <commit-sha>` on the canonical edit commit.
2. Run `/f4-regen-framework` to propagate the revert into `.claude/`.
3. Delete the new agent persona file (if OQ2 added one) — already covered by the revert.
4. No child-side action beyond the next routine `import-shamt`. Communication: note in the land commit.

---

## Validation Considerations

- **Problem clarity** — distinguish "incident-originated proposal" (the new trigger) from the existing `/e7` phase-attributed root cause so the validator does not read them as duplicates.
- **Change-list completeness** — easy-to-forget paired edits: f1 command ↔ mirrored skill; if the rules stance is added, the rules file ↔ any reference pointer; if a persona is added, `model_selection.md` ↔ the persona file ↔ the agent-type description.
- **Risk coverage** — confirm the cost/tier risk and the "does not block proactive proposals" scoping are both addressed.
- **Rollback feasibility** — purely additive; revert + regen is sufficient.
- **Affected surfaces** — commands, skills, references, possibly rules and a new persona. Cross-doc: the adversarial-sub-agent contract wording should stay consistent with Pattern 1 Step 7.
- **Propagation plan** — regen + child import; no manual nudge.

---

## Open Questions

- [ ] **OQ4 — `/e7` linkage.** Should `/e7-resolve-feedback` Step 5 explicitly require/point at the new f1 diagnosis step when routing a bug-originated root cause to a proposal, or is f1 self-contained (detects origin on its own)?

---

## Resolved Questions

<!-- Append as questions resolve. -->

- ~~OQ1: Run the diagnosis for every f1 proposal, or only incident-originated ones?~~ → A: **Incident-originated only** (bug / feedback / issue / audit finding). The new step is conditional: it detects incident origin and fires only then; proactive/clean-slate proposals skip it. Smallest cost/latency footprint and matches the f0 blurb's "feedback and issues" framing.
- ~~OQ2: How are the independent diagnosers spawned (Haiku skeptics / dedicated Opus / hybrid)?~~ → A: **Hybrid** — a primary Opus `root-cause-diagnoser` persona determines the true root cause + recommended fix (root-cause work is Opus-tier per `model_selection.md:15`), then one or more **Haiku** zero-bias sub-agents adversarially confirm/refute it (reusing the Pattern 1 Step 7 contract — no second new persona). One new persona file + one `model_selection.md` row.
- ~~OQ3: Default stance in SHAMT_RULES.template.md or command-local?~~ → A: **Command-local to `/f1-propose-update`** (+ mirrored skill). Avoids adding bytes to the recurrently-over-budget rules file (D12). The stance is stated exactly where it is actioned. Drops the SHAMT_RULES.template.md row from the change list.

---
