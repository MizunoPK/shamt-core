# Proposal: github-pr-review-feedback-loop

**Created:** 2026-06-21
**Status:** Implemented
**Number:** 50
**Proposed by:**
**Project context:**

---

## Problem

The Engineer flow's Review → Polish → Finalize tail (`/e6-review-changes`, `/e7-resolve-feedback`, `/e8-finalize-story`) is **entirely local and one-shot** today, and never touches a real pull request even when the project is configured for one:

- `/e6-review-changes` story mode produces a local `feedback/review_vN.md` and stops. Its Notes (`host/templates/claude/commands/e6-review-changes.md:195`) explicitly say *no tracker postback*, and `/e8-finalize-story`'s Notes (`host/templates/claude/commands/e8-finalize-story.md:99`) declare *PR creation / merge is the `pr_provider`'s concern, out of scope here* — so a GitHub-configured project still has to open (and merge) the PR by hand.
- `/e7-resolve-feedback` resolves only the **local** `review_vN.md` self-review findings (`host/templates/claude/commands/e7-resolve-feedback.md` Step 1) and is written as a **single pass to a user-signalled exit** (Step 7). It has no notion of an external PR, of human reviewer comments, or of being re-run repeatedly as new comments arrive. Its exit even tells the user to *push and open a PR manually*.
- `/e-all` (`host/templates/claude/commands/e-all.md`) drives the whole chain `/e1 … /e8` unattended (gate-paused), terminating only at `/e8`'s finalize commit.

The desired model is PR-centric for GitHub-configured projects. At the **end of the Review stage**, when `pr_provider == github`, the agent should push the story branch and open the PR via the `gh` CLI, so human review happens on the PR. `/e-all` should then **stop at the end of Review** rather than auto-running Polish + Finalize — because Polish is no longer a single pass. Instead, the user invokes `/e7-resolve-feedback` **N times**, and **each** invocation pulls the *latest* PR comments (review comments + conversation), folds them into `addressed_feedback.md` alongside the local self-review findings, resolves them, and pushes the fixes back to the PR branch. This turns the Review/Polish tail into an iterative human-in-the-loop PR cycle while leaving the `pr_provider != github` path on today's local-only behavior.

This **preserves** the standing Pattern 4 *no tracker postback* stance on the write side: `/e7` is **pull-only** — it fetches comments, applies fixes, and pushes commits to the PR branch (the commits are the response), but it never replies to or resolves comment threads on the PR. The human reviewer sees the new commits and resolves the threads on GitHub. The only relaxation is on the **read + push** side (pull comments in; push fix commits) — neither is "postback" in the Pattern 4 sense (posting review content upstream).

---

## Proposed Changes

| # | Canonical path | Operation | One-line change description |
|---|----------------|-----------|------------------------------|
| 1 | `shamt-core/host/templates/claude/commands/e6-review-changes.md` | EDIT | Story mode: after the review artifact validates, when `pr_provider == github`, push the story branch and open the PR via `gh pr create` (the github profile's `## PR create`), behind an explicit-confirm guard; record the PR number into the story folder. No-op when `pr_provider != github`. |
| 2 | `shamt-core/host/templates/claude/commands/e7-resolve-feedback.md` | EDIT | Make the Step-1 inventory a **union of all feedback sources, re-built every run**: the latest local `review_vN.md` findings (existing behavior, unchanged) **plus** — when a PR is recorded + `pr_provider == github` — the latest PR comments (github profile's `## PR comment fetch`). `addressed_feedback.md` is the durable dedup ledger: items already `Resolved` stay closed; any *new* item from **either** source (a new PR comment keyed by comment-ID, or a newer local `review_v{N+1}.md` finding) is added as `Pending` and worked this pass. Resolve them, push the fix commits to the PR branch. **Pull-only — no thread replies / no thread-resolve (Pattern 4 no-postback stance preserved on the write side).** Re-runnable N times; exit unchanged for the `pr_provider != github` (local-only) path. |
| 3 | `shamt-core/host/templates/claude/commands/e-all.md` | EDIT | Stop the chain at the end of `/e6-review-changes` (Review). Update the chain table, the Step-1 start-phase derivation table (terminal signal = Review done / PR opened), Step-3 advance/exit handling, the exit message, and the Notes — Polish (`/e7`, iterative) and Finalize (`/e8`) become operator-driven, no longer auto-run by `/e-all`. |
| 4 | `shamt-core/host/templates/claude/commands/e8-finalize-story.md` | EDIT | When `pr_provider == github`, Finalize adds **one** step — **merge the PR**: `gh pr merge {pr} --squash --delete-branch` (behind the existing Step-3 explicit-confirm guard), preceded by a pre-merge guard that **halts if the PR is not mergeable** (unresolved reviews / failing checks). This is the **only** `pr_provider == github`-gated addition. The **work-item close is unchanged** — it stays Step 4's existing `work_item_tracker`-routed close (**ado** → `az boards work-item update`, **github** → `gh issue close`, **local**/freeform → none; today's lines ~54-62), independent of `pr_provider`. Sequence when `pr_provider == github`: mergeable-guard → confirm-gated PR merge → existing `work_item_tracker`-routed close (unchanged) → write `**Status: Done**`. The `pr_provider != github` path is fully today's behavior (no PR merge; commit-on-branch + the same tracker-routed close). Drop the Notes line that says PR merge is out of scope. |
| 5 | `shamt-core/host/templates/claude/skills/e6-review-changes/SKILL.md` | EDIT | Update `description:` + `## Exit criteria` to add the GitHub PR-create outcome (story mode, `pr_provider == github`). Protocol stays the verbatim pointer. |
| 6 | `shamt-core/host/templates/claude/skills/e7-resolve-feedback/SKILL.md` | EDIT | Update `description:` + `## Exit criteria` to add the iterative PR-comment-pull source. Protocol stays the verbatim pointer. |
| 7 | `shamt-core/host/templates/claude/skills/e-all/SKILL.md` | EDIT | Update `description:` (chain now ends at `/e6`) + `## Exit criteria` (terminal phase is Review / PR opened). Protocol stays the verbatim pointer. |
| 8 | `shamt-core/host/templates/claude/skills/e8-finalize-story/SKILL.md` | EDIT | Mirror the e8 command's PR-merge Finalize (`gh pr merge` when `pr_provider == github`, mergeable-guard) in `description:` + `## Exit criteria`. Protocol stays the verbatim pointer. |
| 9 | `shamt-core/reference/trackers/github.md` | EDIT | Add `## PR create` (`gh pr create`), `## PR comment fetch` (`gh pr view --json comments,reviews` + review-thread fetch), and `## PR merge` (`gh pr merge --squash --delete-branch` + a mergeability check) sections — the concrete commands `/e6` / `/e7` / `/e8` invoke; cross-reference from the existing `## PR fetch` / `## PR comment posting` sections. |
| 10 | `shamt-core/reference/trackers/_contract.md` | EDIT | Add `## PR create`, `## PR comment fetch`, and `## PR merge` to the **Required sections** table (contract-required of every profile, matching how `## PR comment posting` is required-but-may-be-stubbed); name which consumer reads each (`/e6`, `/e7`, `/e8`). Update the `## Where the contract is exercised` table. |
| 11 | `shamt-core/reference/trackers/ado.md` | EDIT | Add `## PR create` / `## PR comment fetch` / `## PR merge` sections with concrete `az repos pr create/show/update` forms (or an explicit "not yet wired — `/e6`/`/e7`/`/e8` invoke these only on `pr_provider == github`" note), satisfying the now-required contract sections. |
| 12 | `shamt-core/reference/trackers/local.md` | EDIT | Add `## PR create` / `## PR comment fetch` / `## PR merge` as `n/a — local has no PR`, satisfying the now-required contract sections. |
| 13 | `shamt-core/templates/SHAMT_RULES.template.md` | EDIT | Pattern 4 + Engineer-flow phase narrative: Review opens the PR (GitHub); Polish is an iterative PR-comment loop; Finalize merges the PR (GitHub). Keep minimal — size-budgeted (D12). |
| 14 | `shamt-core/README.md` | EDIT | Engineer-flow table rows for `/e6` / `/e7` / `/e-all` (chain ends at Review), the `/e-all` Principle-1 note, and the `pr_provider` config-key description. |

**Phase 3 required — file count 14 > 10. Run `/f2-plan-update-implementation github-pr-review-feedback-loop` before `/f3-implement-update`.**

---

## Risks

- **Regression risk** — the `pr_provider != github` (and `none`) path must keep today's exact local-only behavior for `/e6` / `/e7` / `/e-all`. A botched gate could push branches or open PRs in projects that never wanted one. Mitigation: every PR action is guarded on `pr_provider == github` **and** explicit user confirmation.
- **Outward-action risk** — `gh pr create` and pushing fix commits are outward-facing and not cleanly reversible. Mitigation: explicit-confirm guard (consistent with `/e8`'s outward-action gating); never run unattended without the confirm surfacing as an `/e-all` pause.
- **Idempotency / dedup risk** — `/e7` run N times must not re-process already-addressed PR comments, double-apply fixes, or create a second PR. Mitigation: record the PR number in the story folder (single source); dedup PR comments by comment-ID against `addressed_feedback.md`.
- **Drift risk** — canonical command/skill/rules/README edits must regen into `.claude/` together; a missed regen leaves the generated surface stale. Mitigation: `/f4-regen-framework --check` in the flow.
- **Child-project compatibility** — children pick this up on next `import-shamt` + regen; no manual reconciliation. Projects with `pr_provider: none`/`ado` see no behavior change: the new contract sections are wired only on `pr_provider == github`, and ado/local declare them as stub/n-a.
- **Contract-surface risk** — making `## PR create` / `## PR comment fetch` / `## PR merge` contract-required means every existing profile must declare them or a consuming command's "halt on missing required section" check fires. Mitigation: rows 11–12 add the sections to ado/local in the same change set, so no profile is left non-conformant.

---

## Rollback Plan

1. `git revert <commit-sha>` of the squash-merged proposal commit.
2. Run `/f4-regen-framework` to propagate the revert into `.claude/`.
3. Child-side: re-run `/sync-import-shamt` on each installed child to pull the reverted canonical sources.
4. Communication: notify any project already relying on the GitHub PR flow that they revert to manual PR creation + local-only feedback.

---

## Validation Considerations

- **Problem clarity** — the change is conditional on `pr_provider == github`; the validator should confirm every new behavior is gated and the non-github path is provably unchanged. Watch terminology: `pr_provider` (PR provider) is independent of `work_item_tracker` (the contract already states this, `reference/trackers/github.md:111`). **This independence is load-bearing for row 4:** at Finalize, the **only** thing `pr_provider == github` adds is the PR merge; the **work-item close stays routed through `work_item_tracker`** (ado/github/local) exactly as today's `/e8` Step 4, so a `pr_provider: github` + `work_item_tracker: ado` project merges the GitHub PR but closes its ADO work item via `az boards` — row 4 must not gate the work-item close on `pr_provider` or hardcode `gh issue close`.
- **Change-list completeness** — the command↔skill pairing: `/e6`, `/e7`, `/e-all`, and `/e8` each have a SKILL (rows 5–8) whose `description:` + `## Exit criteria` need the paired edit, while the SKILL `## Protocol` stays the verbatim pointer (never a paraphrase — D2 Command → Skill Protocol pointer rule). The tracker-contract change (row 10) must stay consistent with all three profiles (rows 9/11/12) — the contract's Required-sections table and the `## Where the contract is exercised` table must both list the three new sections. The rules-file + README narrative must match the command bodies (where the `/e-all` chain ends; the Finalize-merges-PR behavior).
- **Risk coverage** — verify the unattended-run safety: `/e-all` stopping at `/e6` plus the explicit-confirm PR-create guard must bound outward actions; confirm no path opens a PR or pushes without confirmation.
- **Rollback feasibility** — all edits are reversible via revert + regen; no destructive DELETE or history-losing MOVE. An *already-opened* PR is not rolled back by revert (it lives on GitHub) — note this in the comms step.
- **Affected surfaces** — commands, skills, references (tracker profiles + contract), rules template, README. Cross-doc consistency: the Engineer-flow phase table in the rules file, the README flow table, and the `/e-all` chain table must all agree on where the chain ends.
- **Propagation plan** — requires `/f4-regen-framework` + child `import-shamt`. No already-installed child needs a manual nudge beyond the standard import.

---

## Open Questions

_(All open questions resolved — see Resolved Questions.)_

---

## Resolved Questions

<!-- Appended as questions resolve, one line each. -->

- ~~Q1: What does `/e8-finalize-story` do once the story has a GitHub PR?~~ → A: When `pr_provider == github`, `/e8` adds exactly one step — **merge the PR** — `gh pr merge {pr} --squash --delete-branch` behind the explicit-confirm guard, preceded by a mergeable-guard (halts on unresolved reviews / failing checks). The **work-item close is unchanged**: it stays Step 4's existing `work_item_tracker`-routed close (ado → `az boards work-item update`, github → `gh issue close`, local/freeform → none), which is independent of `pr_provider` — a `pr_provider: github` + `work_item_tracker: ado` project merges the GitHub PR but still closes its ADO work item via `az boards`. Sequence: mergeable-guard → PR merge → `work_item_tracker`-routed close → `**Status: Done**`. The `pr_provider != github` path keeps today's commit-on-branch behavior (no PR merge).
- ~~Q2: Does `/e7` post anything back to the PR, or pull-only?~~ → A: **Pull-only.** `/e7` fetches comments, applies fixes, and pushes commits to the PR branch; it never replies to or resolves threads. The human resolves threads on GitHub. Pattern 4's *no postback* stance is preserved on the write side.
- ~~Q3: Generalize the PR-create/fetch/merge sections through the tracker contract, or github-only?~~ → A: **Generalize.** Make `## PR create` / `## PR comment fetch` / `## PR merge` contract-required sections; github.md gets concrete `gh` commands, ado.md gets `az repos pr` forms (or a not-yet-wired note), local.md gets `n/a`. Keeps the contract surface uniform (matches the existing required-but-stubbable `## PR comment posting`).

---

## Design decisions (not open — recorded for the validator)

- **PR-create is explicit-confirm-gated.** Consistent with `/e8`'s outward-action gating; in `/e-all` it surfaces as a Step-3 pause. Not an open question.
- **`/e6` still runs its 16-category self-review first**, then creates the PR. The local `review_vN.md` self-review findings and the PR's human comments are *both* feedback sources `/e7` resolves. Each `/e7` run **re-inventories every source** (latest local review + latest PR comments) — the PR-comment source is **additive**, not a replacement; the local-findings path is unchanged. `addressed_feedback.md` dedupes (already-`Resolved` stays closed; new items from either source become `Pending`), keyed by local-finding identity and PR comment-ID.
- **PR number is recorded in the story folder** when `/e6` creates it (single source for `/e7`'s fetch + dedup, fresh-agent resumable). Exact artifact location is a Phase-3 mechanical detail.

---
Validated 2026-06-21 — 3 rounds, 1 adversarial sub-agent confirmed (/f-all Phase 2 inline-validation).
