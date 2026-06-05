# Proposal: fold-audit-changes-into-framework-update-commit

**Created:** 2026-06-04
**Status:** Implemented
**Number:** 01
**Proposed by:**
**Project context:**

---

## Problem

When `/f5-audit-framework` runs as **Phase 6** of the framework-update flow (its post-implementation verification role), its two clearing actions produce real working-tree changes: **simple auto-fixes** (canonical edits + their `/f4-regen-framework` output) and **captured f0 draft files** (new `proposals/{slug}.md` stubs). The framework currently mandates that these be kept **out-of-band — "explicitly distinct from the in-flight proposal's scope, so the proposal's validated change-set and its validation footer stay clean."** This rule is stated in four canonical sites:

- `shamt-core/host/templates/claude/commands/f5-audit-framework.md:157` (Step 3 "In-flow out-of-band logging") and `:224` (Notes).
- `shamt-core/host/templates/claude/skills/f5-audit-framework/SKILL.md:59` (step 12 trailing sentence).
- `shamt-core/reference/audit_dimensions.md` §"In-flow logging".

That "keep them separate" rule directly **collides** with `/f6-archive-proposal`'s Phase 7 commit/merge contract. Its Step 3 pre-merge guard (`shamt-core/host/templates/claude/commands/f6-archive-proposal.md:54`) requires:

> *"The working tree contains exactly the expected change: the canonical-source edits the proposal described, the archive move (Step 2), and the `.claude/` regen output from Phase 5. **No unrelated staged/unstaged changes — run `git status` and confirm.**"*

So when Phase 6 (audit) has just auto-fixed a file or dropped an f0 stub, Phase 7 (archive) **halts** on those changes as "unrelated" — forcing the user to manually split the working tree (stash, separate commit, or revert) before they can land the proposal. That friction is the opposite of what the user wants: an audit auto-fix *is* a legitimate canonical edit that should travel with the change it was triggered alongside, and a stray un-committed audit fix is itself a future D1-drift risk. The user's directive: **audit-originated changes made during a framework update should be folded into that update's commit and squash-merge**, not separated out — while staying *traceable* (a reader should still be able to tell which changes came from the audit).

This proposal reconciles the two sides: it reframes f5's "out-of-band, kept separate" rule into "logged distinctly **and folded into the in-flight proposal's landing commit**," and relaxes f6's pre-merge guard so it accepts in-flow audit changes instead of halting on them.

---

## Proposed Changes

| # | Canonical path | Operation | One-line change description |
|---|----------------|-----------|------------------------------|
| 1 | `shamt-core/host/templates/claude/commands/f5-audit-framework.md` | EDIT | Reframe Step 3 "In-flow out-of-band logging" (line 157) and the Notes line (224): audit auto-fixes and captured f0 stubs are **still logged distinctly** but are **folded into the in-flight proposal's landing commit**, not held out of scope. Drop "the proposal's validated change-set … stay clean" framing; keep the distinct-attribution (traceability) purpose. |
| 2 | `shamt-core/host/templates/claude/skills/f5-audit-framework/SKILL.md` | EDIT | Mirror row 1 in the step-12 trailing sentence (line 59). |
| 3 | `shamt-core/reference/audit_dimensions.md` | EDIT | Reframe the "### In-flow logging" subsection to match rows 1–2 (logged distinctly + folded into the proposal commit). |
| 4 | `shamt-core/host/templates/claude/commands/f6-archive-proposal.md` | EDIT | **Remove** the "No unrelated staged/unstaged changes — run `git status` and confirm" clause from the Step 3 pre-merge guard checklist item (the working-tree-contents bullet) — the other three guards (HEAD on the proposal branch, regen ran, branch descends from base) **stay**. `/f6` then commits **whatever is in the working tree** (proposal change + archive move + regen + any in-flow audit changes). Reword that guard bullet to "the working tree contains the proposal's change, the archive move, the Phase 5 regen output, **and any in-flow audit auto-fixes / captured f0 stubs**; `git status` is shown for visibility, not as a halt gate." Also relax the matching **Prerequisite** ("The proposal has been implemented: the working tree contains the canonical edits the proposal described…") so it likewise allows in-flow audit changes. Per OQ3, **no** commit-body audit marker is added. |
| 5 | `shamt-core/host/templates/claude/skills/f6-archive-proposal/SKILL.md` | EDIT | Mirror the row-4 guard change in the step-3 summary ("working tree is exactly the canonical edits + archive move + regen output" → drop "exactly", allow in-flow audit changes). |

Row count: 5 ≤ 10 — no Phase 3 plan required. **Paired-edit discipline:** rows 1↔2 (f5 cmd↔skill) and rows 4↔5 (f6 cmd↔skill) must move together. _(Per OQ3, no `CLAUDE.md` §Conventions edit: the squash commit carries no audit-origin marker — traceability is the in-session audit report + the git diff itself.)_

---

## Risks

- **Regression risk (accepted tradeoff per OQ2)** — `/f6` now commits the **entire working tree** (the "no unrelated changes" guard is removed). A genuinely-unrelated edit left in the tree during a framework-update flow **will** ride into the proposal's squash-merge. This is an accepted tradeoff for the lowest-friction landing: the user is responsible for keeping the working tree free of unrelated work while a framework-update flow is in progress. `/f6` still **shows `git status`** before committing so the user can spot a stray change, but it no longer halts on one.
- **Drift risk** — rows 1–2 and 4–5 are under `host/templates/claude/`, so the edits need `/f4-regen-framework` (Phase 5) before archive; a missed regen is itself a D1 finding. Row 3 (`reference/`) does not regenerate but lands on next `import-shamt`.
- **Traceability risk (accepted per OQ3)** — folding audit changes into one squash commit means the commit does **not** label which lines were audit-origin; the in-session audit report is the only narrative record and is ephemeral. Accepted: the **git diff** of the squash commit still shows exactly what changed, and the audit's changes are small and self-evident (a stray `(future)` removal, a new `proposals/*.md` stub). No commit-body marker is added.
- **Child-project compatibility** — children pick up the reworded bodies on the next `import-shamt`; no manual reconciliation. The commit/merge contract is master-side only, so children are unaffected operationally.
- **Cross-doc consistency** — the four "out-of-band" sites (rows 1–3) and the f6 guard (rows 4–5) must end up mutually consistent, or D9 (the audit itself) will flag the contradiction on the next run.

---

## Rollback Plan

Revert the canonical-edit commit and re-run `/f4-regen-framework`. No child-side action required beyond the next routine `import-shamt`. Purely textual/contract wording — no destructive operation.

---

## Validation Considerations

- **Problem clarity** — the crux is the **collision** between f5's "keep audit changes out of scope" and f6's "halt on unrelated changes" guard. Confirm the validator reads this as reconciling two contradicting rules, not just softening one.
- **Change-list completeness** — the easy-to-miss paired edits: f5 command↔skill (rows 1↔2) and f6 command↔skill (rows 4↔5). Also confirm the row-3 reference subsection isn't left stating the old "stay clean" rule (a stranded D9 contradiction).
- **Risk coverage** — the load-bearing risk is that the row-4 guard removal commits the *entire* working tree, so a genuinely-unrelated edit can ride into the squash-merge. Per OQ2 this is an **accepted** tradeoff (not a defect to re-litigate); verify the proposal flags it as accepted, that `/f6` still surfaces `git status` for visibility, and that the Risks section states the user's responsibility to keep the tree clean during the flow.
- **Affected surfaces** — commands (f5, f6), skills (f5, f6), one reference (audit_dimensions). No CLAUDE.md (per OQ3), no templates, scripts, or personas.
- **Propagation plan** — requires `/f4-regen-framework` after Phase 4; children update on next `import-shamt`.
- **Self-consistency** — after this lands, a future `/f5-audit-framework` D9 sweep must find f5 ↔ f6 ↔ audit_dimensions agreeing on the folded-in behavior.

---

## Open Questions

(none remaining)

---

## Resolved Questions

<!-- Drafting-only log -->

- ~~OQ1 (scope): fold both auto-fix edits and captured f0 stubs, or only auto-fix edits?~~ → A: **Both.** Auto-fix edits + regen **and** captured f0 stub files all fold into the in-flight proposal's squash commit (matches the "any changes that came from an audit" directive; f0 stubs landing on the base branch is normal future-work marking).
- ~~OQ2 (guard mechanism): user-confirm sweep / audit-written manifest / commit everything?~~ → A: **Commit everything in tree.** Remove the "no unrelated staged/unstaged changes" halt clause from `/f6` Step 3 entirely; `/f6` commits the whole working tree, showing `git status` for visibility only. Lowest friction; the accepted tradeoff (a stray unrelated edit can ride in) is noted under Risks — the user keeps the tree clean of unrelated work during the flow.
- ~~OQ3 (traceability): commit-body audit-changes note, or chat-log only?~~ → A: **Chat-log only, no marker.** No commit-body trailer and no `CLAUDE.md` §Conventions change (row 6 dropped). The git diff of the squash commit shows what changed; the in-session audit report is the narrative record. Consistent with the low-ceremony OQ2 choice.

---
Validated 2026-06-04 — 2 rounds, 1 adversarial sub-agent confirmed
