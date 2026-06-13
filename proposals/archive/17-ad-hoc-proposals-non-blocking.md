# Proposal: ad-hoc-proposals-non-blocking

**Created:** 2026-06-12
**Status:** Implemented
**Number:** 17
**Proposed by:** [master-local]
**Project context:** [master-local]

---

## Problem

The framework-update flow **blocks on unrelated working-tree state**, but in practice
the most common "unrelated" state is a user adding **ad-hoc new proposals** — dropping
an f0 capture into `proposals/`, or committing one onto the current branch. Users may
do this at any time and it is **explicitly encouraged** (that is what `/f0-draft-proposal`
is for); it is not an error. Yet today the flow treats it as a fault and forces the
agent to halt, ask, or consider reverting:

- **`/f3-implement-update` preflight** (`host/templates/claude/commands/f3-implement-update.md`,
  Prerequisites): *"Working tree is clean except for the proposal/plan files. **Halt and
  confirm** if the tree has unrelated staged or unstaged changes."* A stray f0 proposal
  in `proposals/` trips this halt.
- **`/f3` Diff coverage gate** (Step 3): *"If the diff contains extra changes not in the
  table, treat it as **scope creep — halt and surface to the user**."* An ad-hoc proposal
  file is "extra," so it reads as scope creep.
- **`/f6-archive-proposal` pre-merge guard** (`host/templates/claude/commands/f6-archive-proposal.md`):
  already says `git status` is *"**not** a halt gate"* and that `/f6` commits the whole
  working tree — but frames it as *"the user is responsible for keeping it free of
  genuinely-unrelated work,"* which contradicts "ad-hoc proposals are encouraged."

This bit the #16 trim flow directly: the agent halted twice — once on an untracked
`proposals/formalize-testing-standards-and-stages.md` f0 capture, once on a commit
(`b1e4222`) that added two f0 captures onto the proposal branch — asking the user how
to handle each, when the correct behavior was simply to proceed and let them ride the
landing.

**Policy (per the resolved scoping question): never halt or revert on _any_ unrelated
working-tree state during a framework-update flow.** Unrelated work — ad-hoc proposal
captures or any other in-progress change — is **accepted**: it rides the flow and folds
into the eventual `/f6` squash landing. The flow's only blocking concern is its **own**
completeness (every Proposed Changes row covered) and its **own** canonical-only
discipline (the proposal's edits never touch `.claude/`) — not the surrounding tree.

This is a command/skill-body clarification only. **`templates/SHAMT_RULES.template.md`
is deliberately not touched** — the behavior lives in the f3/f6 bodies, and the rules
file sits at 39,854 chars (146 under the D12 budget after #16), so adding to it would
re-breach the budget.

---

## Proposed Changes

| File | Op | What |
|---|---|---|
| `host/templates/claude/commands/f3-implement-update.md` | EDIT | **(a) Preflight** — replace the "Halt and confirm if the tree has unrelated staged or unstaged changes" prerequisite with: *unrelated tree state is expected and accepted — it rides the flow and folds into the landing; never halt or revert on it.* **(b) Diff coverage gate (Step 3) extra-changes sentence** — replace "extra changes not in the table → scope creep → halt and surface" with: *extra/unrelated tree state is accepted (it rides the landing), not scope creep; the gate halts only on an **uncovered Proposed Changes row***. **(c) Preserve the in-place-amendment path** for the distinct case where the agent's **own** work legitimately needs a canonical change not yet in the table (a genuinely-missing row — strip footer, append the row, re-`/validate-artifact`); this is unchanged and must not be conflated with unrelated tree state. **(d) Convert** the gate's two "no file outside the canonical roots / no `.claude/` file **in the diff**" checks into **per-described-change** checks: each Proposed Changes row's edit must touch only canonical roots and never `.claude/`. The gate **no longer scans the whole working-tree diff** for non-canonical or `.claude/` files — unrelated tree state (including unrelated non-canonical files) is not policed. *(This is a logic change, not a word-swap: the two checks move from global-diff scope to per-row scope.)* |
| `host/templates/claude/skills/f3-implement-update/SKILL.md` | EDIT | Preflight bullet: drop "halt if working tree is dirty with unrelated changes"; replace with "unrelated tree state is accepted (rides the landing), never a halt." |
| `host/templates/claude/commands/f6-archive-proposal.md` | EDIT | Pre-merge guard (the `git status` bullet): replace "the user is responsible for keeping it free of genuinely-unrelated work" with "unrelated tree state — ad-hoc proposal captures or other in-progress work — is accepted and folds into this landing; never halt or revert on it. The landing-commit body **may** note any folded-in unrelated additions for honest history." |
| `host/templates/claude/skills/f6-archive-proposal/SKILL.md` | EDIT | Mirror: extend the "`git status` is shown for visibility, not a halt gate" clause with "(unrelated tree state — ad-hoc proposals or other in-progress work — is accepted and folds into the landing)." |

Four files — two command↔skill pairs (cross-checked: both halves of each pair edited
so the summarized skill stays consistent with its command body, D2). All under
`host/templates/claude/` (canonical); **no `.claude/` paths**; no rules-file edit. Row
count 4 ≤ 10 → no `/f2-plan-update-implementation` phase.

`/f5-audit-framework` and `/f0-draft-proposal` need no change: the audit already
captures-and-continues (never halts on existing `proposals/` files), and `/f0` is
non-destructive append-only.

---

## Risks

- **Unrelated work silently folds into a proposal's squash landing (primary trade-off).**
  Because `/f6` squash-merges the whole working tree, making the flow non-blocking on
  *any* unrelated change means a genuinely-unrelated canonical-source edit (e.g. a stray
  edit to a shared template) could ride a proposal's "land #NN" commit, mislabeled.
  *Accepted by design* (resolved scoping question — maximally permissive). *Mitigation:*
  the f6 edit recommends the landing-commit body note folded-in unrelated additions (as
  #16's commit did for its two f0 captures), keeping history honest; and `git status`
  remains shown for visibility so the user can intervene if they choose.
- **Diff-coverage gate weakened.** Relaxing "extra changes → halt" could let a real
  defect (an unintended edit by the agent) pass unnoticed. *Mitigation:* the gate still
  fails on any **uncovered Proposed Changes row** (the proposal's own work must be
  complete), and the proposal's-own-edits canonical-only / no-`.claude/` rule is retained
  — only *unrelated* tree state is de-policed.
- **Command↔skill drift.** Editing one half of a pair and not the other is a D2 finding.
  *Mitigation:* all four files (both pairs) are in the table; a post-implementation
  `/f5` D2 sweep confirms consistency.

## Rollback Plan

Single-commit, fully reversible. Lands as one squash commit
(`shamt-core: land #17 ad-hoc-proposals-non-blocking (...)`) via `/f6-archive-proposal`.
Rollback = `git revert` that commit, restoring the prior halt-on-unrelated language in
all four bodies. No data, no child-project state, no schema. The next `import-shamt`
re-propagates whichever version is current.

## Validation Considerations

- **Behavioral intent check.** Validation confirms each edited body now states the
  non-blocking-on-unrelated-tree-state policy clearly and that no *blocking* concern was
  accidentally dropped — specifically that the f3 diff-coverage gate still fails on an
  uncovered Proposed Changes row and still forbids the proposal's own edits from touching
  `.claude/`.
- **Pair consistency (D2).** The f3 command and skill, and the f6 command and skill, must
  describe the same relaxed behavior — no half-edited pair.
- **No rules-file edit.** Confirm `templates/SHAMT_RULES.template.md` is untouched (D12
  budget unaffected).
- **D4 reference validity.** The edits add no new cross-references; confirm none are
  broken.
- This proposal goes through `/validate-artifact` (Pattern 1) before `/f3-implement-update`.

---

## Resolved Questions

- **Carve-out scope — ad-hoc proposal files only, or any unrelated change?**
  *Resolved 2026-06-12:* **Any unrelated change.** The flow never halts on any unrelated
  working-tree state during f3/f6 — ad-hoc proposal captures and other in-progress changes
  alike ride the landing. Maximally permissive; the entanglement trade-off (unrelated work
  folding into a proposal's squash commit) is accepted, mitigated by an honest
  landing-commit body note and the still-visible `git status`.

## Open Questions

None — all resolved above.

---
Validated 2026-06-12 — 4 primary rounds + 4 adversarial sub-agent passes. Substantive
findings resolved rounds 1–3 (header convention [dispositioned valid], Problem-phrasing
clarity, Row-1 actionability incl. in-place-amendment preservation and explicit per-row
canonical-check semantics). Final-pass HIGH findings dispositioned as invalid: a
verbatim-replacement-text demand (wrong altitude — exact wording is `/f3`'s job per the
descriptive-cell norm of #14–#16) and a propose-vs-implement misread (the f3 body
correctly still carries pre-change language; the proposal is not yet implemented).
Primary-validator convergence.
