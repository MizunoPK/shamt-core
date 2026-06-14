# Adversarial, Independent Root-Cause Diagnosis When Drafting Incident-Originated Proposals

**Created:** 2026-06-14
**Status:** Implemented
**Number:** 24
**Proposed by:**
**Project context:**

---

## Problem

When a Shamt framework-update proposal originates from a **bug or a piece of feedback** — a Phase-5 test failure routed to `/e7-resolve-feedback`, a recurring review finding, a child-submitted issue, or an audit capture — the drafting in `/f1-propose-update` currently relies on the **primary agent alone** to diagnose what went wrong and decide the fix. The command body (`host/templates/claude/commands/f1-propose-update.md` Step 2 "Draft the Problem section") tells the agent to "state the concrete problem" and "verify and sharpen" a seed against the canonical sources, but it adds **no independent, zero-bias check** that the diagnosis reaches the true root cause rather than the first plausible one. The agent that drafts the proposal is the same agent that decided what the problem is — there is no skeptic.

This is a gap relative to the rest of the framework, which already treats independent adversarial review as load-bearing everywhere a conclusion matters: `/validate-artifact` spawns a zero-bias `validation-checker` sub-agent (`templates/SHAMT_RULES.template.md` Pattern 1 Step 7), `/f5-audit-framework` spawns an `audit-checker`, and `reference/model_selection.md:15` pins **root-cause analysis** to the Reasoning (Opus) tier. The one place that *produces* the root-cause diagnosis a framework change is built on — proposal drafting — has none of that rigor. `/e7-resolve-feedback` Step 2 already forces a phase-attributed root cause for a Phase-5 bug and Step 5 routes generalizable root causes into `.shamt-core/proposals/`, but once the proposal reaches `/f1-propose-update` that root cause is taken at face value and developed without challenge.

The intended behaviour: when a proposal is **incident-originated** (bug / feedback / issue / audit capture), `/f1-propose-update` should (a) adopt the default stance that the incident indicates a *genuine framework gap requiring a Shamt update* — not a one-off to paper over — and (b) drive an **independent, adversarial, zero-bias root-cause diagnosis** (one or more sub-agents with no stake in the first explanation) to determine what actually went wrong and what the fix should be, folding that diagnosis into the Problem + Proposed Changes before the open-questions dialog. Proactive / non-incident proposals (a clean-slate improvement, a new recipe) are unaffected.

---

## Proposed Changes

| # | Canonical path | Operation | One-line change description |
|---|----------------|-----------|------------------------------|
| 1 | `host/templates/claude/commands/f1-propose-update.md` | EDIT | Add an **incident-origin detection + adversarial root-cause diagnosis** step (between Step 2 Problem and Step 3 Proposed Changes): detect incident origin, adopt the command-local "assume a Shamt update is warranted" default stance, spawn the Opus `root-cause-diagnoser` + Haiku zero-bias confirmation, fold the diagnosis into Problem + Proposed Changes. |
| 2 | `host/templates/claude/skills/f1-propose-update/SKILL.md` | EDIT | Mirror the new step + default stance into the skill summary + frontmatter description (command ↔ mirrored skill pairing). |
| 3 | `reference/model_selection.md` | EDIT | Add a **Per-persona pinning** table row for the new Opus `root-cause-diagnoser` persona; note its diagnosis is adversarially confirmed by a Haiku zero-bias sub-agent (reusing the Pattern 1 contract). |
| 4 | `host/templates/claude/agents/root-cause-diagnoser.md` | CREATE | New Opus root-cause-diagnoser persona: zero-bias, distrust-by-default; given the incident + canonical sources, determines the true root cause and recommends the fix. The Haiku confirmation reuses the existing Pattern 1 adversarial sub-agent contract — no second new persona. |
| 5 | `host/templates/claude/commands/e7-resolve-feedback.md` | EDIT | Step 5 (root-cause / upstream proposals) gains a one-line pointer: a bug-originated proposal must go through f1's adversarial root-cause diagnosis. |
| 6 | `host/templates/claude/skills/e7-resolve-feedback/SKILL.md` | EDIT | Mirror the Step 5 pointer into the e7 skill summary (command ↔ mirrored skill pairing). |
| 7 | `README.md` | EDIT | Add a row to the hand-written **Sub-agent personas** roster for the new `root-cause-diagnoser` persona (Opus tier; used by `/f1-propose-update` incident-origin diagnosis). README is hand-written canonical (not regen'd), so it must move with the persona. |

Cross-checks: command (1) ↔ mirrored skill (2); command (5) ↔ mirrored skill (6); reference (3) ↔ the new persona (4) + the f1 command body that cites the tier; the new persona (4) ↔ the README persona roster row (7); the f1 default stance is command-local (no `SHAMT_RULES.template.md` edit, per OQ3). Seven file operations — under the 10-op threshold, so no Phase 3 plan is required.

---

## Risks

- **Regression risk** — a too-broad incident-origin trigger could fire the diagnosis on proposals that aren't really incident-driven, slowing routine f1 runs. Scoping the step to genuine bug/feedback/issue/audit origin (OQ1) contains the blast radius; the f1 body must define the trigger precisely.
- **Cost risk** — the diagnosis runs an Opus `root-cause-diagnoser` plus Haiku confirmation per incident proposal. `model_selection.md` warns one Opus loop costs more than 10 Haiku passes, so the step is gated to incident origin (not every f1 run) and the Opus diagnoser stays single-pass with the cheap Haiku adversarial confirmation.
- **Drift risk** — f1 command ↔ mirrored skill (rows 1/2), e7 command ↔ mirrored skill (rows 5/6), and `model_selection.md` ↔ the new persona file (rows 3/4) must move together or `--check` regen drift appears. The README persona roster (row 7) is **hand-written** (not regenerated), so `--check` will *not* catch a missed README row — it must be updated by hand alongside the persona file, or the roster silently goes stale (a later D3/D8 audit finding).
- **Child-project compatibility** — additive command/skill text propagates cleanly on the next `import-shamt`; no manual reconciliation. The new `root-cause-diagnoser` persona file is likewise additive.
- **Overlap risk** — must not duplicate `/e7-resolve-feedback`'s existing phase-attributed root-cause requirement; the f1 step *consumes/deepens* that root cause, it does not replace it.

---

## Rollback Plan

1. `git revert <commit-sha>` on the canonical edit commit.
2. Run `/f4-regen-framework` to propagate the revert into `.claude/`.
3. The new `root-cause-diagnoser` persona file is removed by the revert (additive CREATE) — no separate step needed.
4. No child-side action beyond the next routine `import-shamt`. Communication: note in the land commit.

---

## Validation Considerations

- **Problem clarity** — distinguish "incident-originated proposal" (the new trigger) from the existing `/e7` phase-attributed root cause so the validator does not read them as duplicates.
- **Change-list completeness** — easy-to-forget paired edits: f1 command ↔ mirrored skill (rows 1/2), e7 command ↔ mirrored skill (rows 5/6), the new `root-cause-diagnoser` persona ↔ its `model_selection.md` Per-persona-pinning row (rows 3/4), and the new persona ↔ the hand-written README **Sub-agent personas** roster (row 7). The default stance is command-local — confirm no stray `SHAMT_RULES.template.md` edit creeps in.
- **Risk coverage** — confirm the cost/tier risk and the "does not block proactive proposals" scoping are both addressed.
- **Rollback feasibility** — purely additive; revert + regen is sufficient.
- **Affected surfaces** — commands (f1, e7), mirrored skills, `reference/model_selection.md`, the new `root-cause-diagnoser` persona, and the hand-written `README.md` roster. **No `SHAMT_RULES.template.md` edit** (the default stance is command-local per OQ3). Cross-doc: the adversarial-sub-agent contract wording should stay consistent with Pattern 1 Step 7.
- **Propagation plan** — regen + child import; no manual nudge.

---

## Open Questions

_All open questions resolved — see the Resolved Questions log below._

---

## Resolved Questions

<!-- Append as questions resolve. -->

- ~~OQ1: Run the diagnosis for every f1 proposal, or only incident-originated ones?~~ → A: **Incident-originated only** (bug / feedback / issue / audit finding). The new step is conditional: it detects incident origin and fires only then; proactive/clean-slate proposals skip it. Smallest cost/latency footprint and matches the f0 blurb's "feedback and issues" framing.
- ~~OQ2: How are the independent diagnosers spawned (Haiku skeptics / dedicated Opus / hybrid)?~~ → A: **Hybrid** — a primary Opus `root-cause-diagnoser` persona determines the true root cause + recommended fix (root-cause work is Opus-tier per `model_selection.md:15`), then one or more **Haiku** zero-bias sub-agents adversarially confirm/refute it (reusing the Pattern 1 Step 7 contract — no second new persona). One new persona file + one `model_selection.md` row.
- ~~OQ3: Default stance in SHAMT_RULES.template.md or command-local?~~ → A: **Command-local to `/f1-propose-update`** (+ mirrored skill). Avoids adding bytes to the recurrently-over-budget rules file (D12). The stance is stated exactly where it is actioned. Drops the SHAMT_RULES.template.md row from the change list.
- ~~OQ4: Should `/e7` Step 5 explicitly point at the new f1 diagnosis step, or is f1 self-contained?~~ → A: **Add an explicit pointer in `/e7` Step 5** (+ mirrored e7 skill). A bug-originated proposal routed by `/e7` must go through f1's adversarial root-cause diagnosis; the one-line pointer closes the loop visibly for a fresh agent. Keeps the e7 command + skill rows.

---

Validated 2026-06-14 — 3 rounds, 1 adversarial sub-agent confirmed
