# Proposal: f6-archive-preserve-uncommitted-footer

**Created:** 2026-06-15
**Status:** Implemented
**Number:** 36
**Proposed by:** (master-local)
**Project context:**

---

## Problem

The framework-update flow deliberately leaves the proposal's validated content — the `Validated …` footer and every Phase-2 fix — **uncommitted in the working tree** from `/f3-implement-update` (whose Notes state "No commits here") all the way through `/f4-regen-framework` and the Phase-6 audit, until `/f6-archive-proposal` lands everything in one squash commit. So when `/f6` runs, the only copy of the validated proposal content lives in the working tree; the committed blob on the proposal branch is still the *pre-validation* `Status: Draft` version.

`/f6`'s Step 3 ("Commit + merge") is where this becomes dangerous. Step 2 moves the proposal with `git mv proposals/{slug}.md → proposals/archive/{slug}.md`. **`git mv` of a file that carries uncommitted content modifications stages only the rename of the committed (pre-validation) blob — the validated content modification remains an *unstaged* change at the new archive path.** Step 3 substep 1 then says only "Stage and commit the change on the proposal branch" — it never says `git add -A`, and it never warns that the `git mv` left the real content unstaged. A literal reading commits the **stale pre-validation blob** (`Status: Draft`, footer stripped). The subsequent `git checkout {base-branch}` (Step 3 substep 2) then runs against a working tree that still holds the validated content as unstaged work; git either **aborts on the would-be-overwritten/untracked-path condition** (leaving a partially-checked-out tree) or proceeds after a cleanup that discards the validated bytes — and the `git merge --squash` lands the committed `Status: Draft` content on the base branch as "Implemented." This actually happened during a live `/f-all 27` run: only the agent's ad-hoc post-move footer re-check caught the revert and reconstructed the content before merging — one missed check from landing Draft content as Implemented.

The single safety net that exists today — the footer-intact read at `host/templates/claude/commands/f6-archive-proposal.md` Step 2.4 (and the Notes "Read the destination file after the move to confirm") — runs **pre-commit**, against the working tree while the validated content is still present and intact, so it structurally **cannot** catch a commit that stages the wrong blob. There is no post-commit assertion that the blob actually committed to the archive path carries the validated content. The same staging gap silently drops the `/f4` regen output and any Phase-6 audit auto-fixes / f0 captures that `/f-all` instructs the agent to fold into this one squash commit (`host/templates/claude/commands/f-all.md` Phase 7 dispatch lists *what* must be in the tree but never names *how* it gets staged).

**Confirmed root cause (adversarial diagnosis — Opus `root-cause-diagnoser` + Haiku `validation-checker` zero-bias confirmation).** The root cause is the underspecified staging in `/f6` Step 3.1, not the `git checkout` abort. The abort is a *symptom*: a complete `git add -A` in Step 3.1 stages the validated content (and the regen output, audit fixes, and f0 captures, including untracked ones), leaving a clean tree against which `git checkout {base-branch}` cannot abort. The structural fix is therefore (a) stage **all** tree state with `git add -A` before the proposal-branch commit, and (b) add a **mandatory post-commit halt gate** asserting the committed archive-path blob carries `Status: Implemented` + the `Validated …` footer and that the tree is clean (`git status --porcelain` empty) before the checkout — making the failure impossible to land silently, rather than relying on a "remember to re-check" patch.

---

## Proposed Changes

A flat list of canonical files the proposal will touch.

| # | Canonical path | Operation | One-line change description |
|---|----------------|-----------|------------------------------|
| 1 | `shamt-core/host/templates/claude/commands/f6-archive-proposal.md` | EDIT | In Step 3 ("Commit + merge"), replace substep 1 ("Stage and commit the change on the proposal branch") with: (1a) `git add -A` to stage **all** working-tree state with an explicit rationale (after `git mv`, only the pre-validation rename is staged; the validated content modification at the archive path, the `/f3` canonical edits, the `/f4` `.claude/` regen output, and any Phase-6 audit auto-fixes / f0 captures are all unstaged); (1b) the `git commit`; (1c) a **mandatory post-commit halt gate** — read the archive-path blob out of HEAD (`git show HEAD:proposals/archive/{resolved-filename}`) and assert it contains `Status: Implemented` + the `Validated YYYY-MM-DD …` footer, and assert `git status --porcelain` is empty (nothing escaped `-A`); halt (do NOT `git checkout {base-branch}`) on either failure, surfacing the verbatim diff. Renumber the existing `git checkout`/`git merge --squash`/`git commit`/`git branch -D` sequence to run only after the gate passes. Add a one-line note at Step 2.4 that its read is the pre-commit early check and the new Step 3 gate is the authoritative post-commit assertion. |
| 2 | `shamt-core/host/templates/claude/skills/f6-archive-proposal/SKILL.md` | EDIT | Update Protocol bullet 3 (the "Commit + squash-merge + delete branch" summary) to mirror the command: name the `git add -A` requirement (and *why* — `git mv` stages only the rename) and the mandatory post-commit assertion (`git show HEAD:`archive-path carries `Status: Implemented` + footer, `git status --porcelain` empty) before the `git merge --squash`. |
| 3 | `shamt-core/host/templates/claude/commands/f-all.md` | EDIT | In the "### Phase-by-phase dispatch" subsection, **Phase 7 — `/f6-archive-proposal`** paragraph (the named anchor is authoritative; ~line 145): after the existing guard list (which names *what* must be in the working tree — canonical edits + archive move + regen output + audit auto-fixes + f0 captures), add that the dispatched agent must `git add -A` before the proposal-branch commit so the regen output, audit auto-fixes, and f0 captures actually land in the squash commit — naming the staging *mechanism*, not just the contents. |

**Path discipline:** all three are canonical host-template paths (`host/templates/claude/...`). No `.claude/` paths. Regen (Phase 5) propagates the command + SKILL edits to `.claude/`.

This is **3 canonical file operations** (≤10) — no Phase 3 plan required; `/f3` runs the inline path. The three sites are a tight cluster: the `/f6` command is the primary fix, its SKILL.md is the mandatory canonical-sync mirror, and the `/f-all` Phase-7 dispatch is the driver-side reinforcement where the audit-fold-into-`/f6` makes complete staging most load-bearing.

---

## Risks

- **Regression risk** — The post-commit assertion adds a halt gate to the previously-uninterrupted commit→merge sequence. If the `git show HEAD:`archive-path / `git status --porcelain` checks are written too strictly (e.g., a grandfathered proposal whose footer wording differs, or a proposal that legitimately required no regen so `.claude/` has no diff), `/f6` could halt on a healthy landing. Mitigation: the assertion keys on the two stable invariants only — `Status: Implemented` and the `Validated …` footer line in the *archived proposal blob* — and `git status --porcelain` emptiness is exactly the precondition the subsequent `git checkout` already requires, so the gate cannot reject a state the checkout would have accepted.
- **Behavioral-only change** — No file structure, template, or schema changes; the edits sharpen the git command sequence in one command body + its mirror + the driver note. Already-installed children pick it up on the next `import-shamt` + regen with no manual reconciliation.
- **Drift risk** — The command and its SKILL.md mirror must move together (canonical-sync); `/f5-audit-framework` D1/D2 would catch a missed mirror. The `/f-all` reinforcement must stay consistent with the `/f6` Step 3 wording it points at.
- **Child-project compatibility** — Purely additive hardening of an existing flow; no child-side action beyond the standard import + regen.
- **Open-questions debt** — One open question (scope of the `/f-all` reinforcement) is resolved in the dialog below before validation.

---

## Rollback Plan

Behavioral hardening of three host-template docs; revert is clean.

1. `git revert <commit-sha>` on the landing commit (or restore the prior `/f6` Step 3, SKILL.md bullet 3, and `/f-all` Phase-7 paragraph).
2. Run `/f4-regen-framework` to propagate the revert into `.claude/`.
3. No child-side action required beyond the next routine `import-shamt` + regen.

---

## Validation Considerations

Dimension hints for the Phase 2 validation loop (`/validate-artifact proposals/36-f6-archive-preserve-uncommitted-footer.md`):

- **Problem clarity** — The crux is that `git mv` of a *modified* file stages only the rename of the committed blob, leaving the content modification unstaged. Verify the validator follows the git mechanics (rename-staged vs. content-unstaged) rather than assuming "the commit captures whatever is in the working tree."
- **Change-list completeness** — The `/f6` command and its SKILL.md mirror must change together (canonical-sync). Confirm no *other* site restates the `/f6` Step 3 git sequence that would also need updating (e.g., a reference doc) — it should not. The `/f-all` Phase-7 paragraph is the only driver-side restatement.
- **Risk coverage** — The chief risk is a too-strict post-commit assertion halting a healthy landing (grandfathered footer wording; no-regen proposals). Verify the assertion is scoped to the two stable invariants and to `git status --porcelain` emptiness (which the downstream checkout already demands).
- **Rollback feasibility** — Pure doc edits + regen; no destructive DELETE/MOVE of canonical content (the f0→numbered rename of *this* proposal is authoring bookkeeping, not part of the change set). Revert is `git revert` + regen.
- **Affected surfaces** — Commands (`/f6`, `/f-all`) + one skill (`f6-archive-proposal`). No rules-file, template, reference, or persona changes. Cross-doc consistency: command ↔ SKILL mirror, and `/f-all` ↔ `/f6` Step 3 wording.
- **Propagation plan** — Requires regen + child import to take effect. No already-installed child needs a manual nudge beyond the routine import.

---

## Open Questions

(empty — resolved below)

---

## Resolved Questions

- ~~Q: Should the fix also tighten `/f-all`'s Phase-7 dispatch paragraph, or stay minimal to `/f6` + its SKILL.md mirror (since `/f-all` Phase 7 already dispatches the real `/f6` command, which inherits the fix automatically)?~~ → A: **Include the `/f-all` reinforcement (Change #3).** `/f-all` Phase 7 does dispatch the fixed `/f6`, so the fix propagates functionally either way — but the `/f-all` Phase-7 paragraph is the canonical statement of *what lands in the squash commit* (it explicitly enumerates the regen output + audit auto-fixes + f0 captures that must fold in) and currently names only the *contents*, never the *staging mechanism*. The incident proved that omission is exactly where data is lost. Naming `git add -A` there keeps the driver's contract honest and is where complete staging is most load-bearing. Reinforcement, not redundancy.

---

<!-- Phase 2 validation appends the footer below on a clean exit. Do not pre-fill. -->

---
Validated 2026-06-16 — 2 rounds (primary clean + adversarial validation-checker confirmed: zero issues)
