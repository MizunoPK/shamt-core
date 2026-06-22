---
description: Phase 8 (Polish) — apply review feedback to code, log each comment's disposition in addressed_feedback.md, apply any flagged .shamt-core/project-specific-files/ARCHITECTURE.md / .shamt-core/project-specific-files/CODING_STANDARDS.md / .shamt-core/project-specific-files/TESTING_STANDARDS.md updates, surface root-cause proposals to the framework-update flow
---

# /e8-resolve-feedback

**Purpose:** Run Phase 8 (Polish) of the Engineer flow. Apply the findings from the latest story-mode `review_vN.md`, log each comment's handling in `addressed_feedback.md`, perform any **Documentation Impact** updates the Review phase flagged, and route generalizable root-cause patterns to the framework-update flow rather than patching in-story.

**Recommended models:**

- Mechanical fixes (apply a reviewer's `Suggested fix`): Balanced (Sonnet).
- Root-cause / upstream-proposal synthesis (recurring findings → `.shamt-core/proposals/<proposal-slug>.md` — descriptive slug, not the story slug): Reasoning (Opus).

See [`reference/model_selection.md`](../../../../reference/model_selection.md).

---

## Usage

```
/e8-resolve-feedback {slug}
```

## Arguments

- `{id-or-slug}` (required) — story ticket ID (`T{N}`) or slug. Resolved via the global story-folder rules (ID glob `stories/{ID}-*/`, else the both-positions slug glob; halt on multiple or zero matches).

## Prerequisites

- Resolve the story folder per `templates/SHAMT_RULES.template.md` §PO-tree resolution (tree-wide glob + legacy-flat fallback); `stories/{slug}/` below denotes that resolved folder. If `stories/{slug}/active_artifacts.md` exists, read it first.
- The active spec exists with a validation footer.
- A feedback source exists: a story-mode `review_vN.md` (with a validation footer) under `stories/{slug}/feedback/`, **and/or a Phase-6 bug routed here by `/e6-execute-tests`** (an `agent_test_session.md` scenario that FAILed, or a `test-executor` Story-bug). A Phase-6 bug is logged as a feedback item with the required phase-attributed root-cause (Step 2). If there is no source at all (no findings + Phase 6 green), this command is mostly a TODO-scan no-op — see Step 6.
- `.shamt-core/project-specific-files/ARCHITECTURE.md`, `.shamt-core/project-specific-files/CODING_STANDARDS.md`, and `.shamt-core/project-specific-files/TESTING_STANDARDS.md` paths are known (read the active review's `## Documentation Impact` block to learn whether any needs an update).

## Step-by-step

### Step 1 — Inventory feedback (union of all sources, rebuilt every run)

The inventory is a **union of every feedback source, rebuilt on each run** — this command is **re-runnable N times** as new PR comments arrive. The two sources:

1. **Local self-review findings (unchanged).** Walk `stories/{slug}/feedback/` and pick the **latest** `review_vN.md` (highest N). Older `review_v*.md` files are historical — do not re-resolve closed comments. Read its `## Plan Alignment`, leadership sections (`## Blockers`, `## Required Changes`, `## Suggestions`), `## Monitoring Checklist`, `## Security Checklist`, and `## Documentation Impact`. Build a working list of every finding, keyed by section (BLOCKING → CONCERN → SUGGESTION → NITPICK).
2. **PR comments (additive — only when a PR is recorded and `pr_provider == github`).** If `stories/{slug}/feedback/pr.md` exists (written by `/e7-review-changes`) **and** `.shamt-core/shamt-config.json` → `pr_provider == github`, fetch the **latest** PR comments + review threads via the github profile's `## PR comment fetch` (`reference/trackers/github.md`). Each comment carries a stable **comment-ID**. This source is **additive** to the local findings, never a replacement; when no PR is recorded or `pr_provider != github`, skip this source entirely (the local-only path is exactly today's behavior). **Pull-only — never reply to or resolve PR threads** (Pattern 4 no-postback stance preserved on the write side; the pushed fix commits are the response, and the human resolves threads on GitHub).
3. **Dedup against the durable ledger.** `addressed_feedback.md` is the durable dedup ledger. If `stories/{slug}/feedback/addressed_feedback.md` already exists from a prior Polish pass, read it. An item already marked `Resolved` stays closed and is **not** re-processed; any **new** item from **either** source — a new PR comment keyed by its comment-ID, or a newer local `review_v{N+1}.md` finding — is added as `Pending` and worked this pass. Items marked `Pending` or `Needs user decision` also go into this pass.

### Step 2 — Open or update `addressed_feedback.md`

Create (or update) `stories/{slug}/feedback/addressed_feedback.md`. Track every reviewer comment with this row shape:

```markdown
### [SEVERITY] — <Category> — <one-line summary>

- **Source:** `feedback/review_vN.md` (`Blockers` / `Required Changes` / `Suggestions` / `Monitoring Checklist` / `Security Checklist`)
- **Disposition:** `Pending` | `Resolved` | `Deferred — <reason>` | `Needs user decision`
- **Action taken:** <commit SHA(s), file(s) changed, or `N/A — deferred / needs decision`>
- **Root cause:** <one-line summary of why the issue existed — needed for Step 5>. **For a Phase-6 test-surfaced bug this is required and must name which phase let it through — Spec (missing requirement) / Plan (missing or wrong step) / Build (execution defect) — plus the prevention (what would have caught it earlier).**
- **Notes:** <anything else worth carrying forward>
```

Start every comment as `Pending`. Move to `Resolved` only after the fix is committed and verified.

### Step 3 — Resolve comments one at a time

Process comments in **descending severity** order — BLOCKING first, then CONCERN, SUGGESTION, NITPICK. Within a severity, any order is fine.

Per comment:

1. **Understand** — re-read the finding and the file/line it cites. If unclear, surface a one-question dialog to the user via `AskUserQuestion` (open-questions iterative dialog, Principle 2). Update `addressed_feedback.md`'s `Notes` with the answer.
2. **Decide disposition**:
   - **Fix in-story** — apply the change; commit per the project's commit convention (the same one the plan used, e.g., `#{slug}: address review BLOCKING <category>`); update `Action taken` with the commit SHA. **When a PR is recorded + `pr_provider == github`, push the fix commits to the PR branch** (`git push`) so the human reviewer sees them on the PR — this push **is** the response (pull-only; no thread reply / no thread-resolve).
   - **Defer** — only when the user explicitly accepts deferral. Capture the reason and a forward link (e.g., `Deferred — captured at .shamt-core/proposals/<slug>.md` or `Deferred — tracker work-item <id>`).
   - **Needs user decision** — when a comment cannot be dispositioned without product/platform input. Surface the question to the user; do not leave the comment dangling on `Needs user decision` past the end of the pass.
3. **Verify** — re-run the relevant part of the active plan's `## Verification` section for any code path the fix touched. If a fix is non-trivial, re-hand off to the `plan-executor` builder for the modified step.
4. **Reflect on root cause** — write the one-line `Root cause` in `addressed_feedback.md` (e.g., `Validation missed at Step 4 — locate string ambiguity`, `Spec under-specified Logging convention`, `CODING_STANDARDS rule X was not surfaced in Plan Compliance map`). Required even for SUGGESTION / NITPICK fixes — Step 5 reads these.
5. **Close** — mark the comment `Resolved` (or `Deferred` / `Needs user decision` if applicable).

### Step 4 — Documentation Impact update

If the active review's `## Documentation Impact` block declared any doc `Required`:

1. Apply the `Polish action` from that block to `.shamt-core/project-specific-files/ARCHITECTURE.md`, `.shamt-core/project-specific-files/CODING_STANDARDS.md`, and/or `.shamt-core/project-specific-files/TESTING_STANDARDS.md`. Update the `Last Updated` field; append a one-line entry to `Update History` referencing this story's slug.
2. Re-validate the touched doc via `/validate-artifact .shamt-core/project-specific-files/ARCHITECTURE.md` (or `/validate-artifact .shamt-core/project-specific-files/CODING_STANDARDS.md` / `/validate-artifact .shamt-core/project-specific-files/TESTING_STANDARDS.md`). Uses the 5 general dimensions. Footer.
3. Commit the doc change with the project's commit convention.

If all docs were `Not required`, skip this step.

### Step 5 — Root-cause / upstream proposals

For each comment's `Root cause`, ask: **is this a pattern that generalizes beyond this story?**

- **Yes** (recurring across stories, framework-wide gap, missing Review Prevention Gate, model-tier mis-pinning, etc.) → route through the **framework-update flow** per [`SHAMT_RULES.template.md`](../../../../templates/SHAMT_RULES.template.md#framework-maintenance). Create a `.shamt-core/proposals/<proposal-slug>.md` rather than patching framework files directly — the **proposal slug is descriptive** (e.g., `add-tenant-bypass-gate`, `pin-haiku-for-formal-git-metadata`), not necessarily the story slug; a single story can surface multiple distinct proposals. Reference the proposal(s) in the comment's `Notes`. Because this proposal is **bug-originated**, `/f1-propose-update` will run its incident-origin **adversarial root-cause diagnosis** (Step 2.5) over it — the phase-attributed root cause you recorded in Step 2 is the *seed* that diagnosis distrusts and deepens, not the final word.
- **No** (story-specific bug, ad-hoc edge case, one-off naming preference) → no proposal; the fix in-story is enough.

Durable framework improvements happen via the framework-update flow (proposals), not in-story shortcuts.

### Step 6 — TODO scan

Per the **TODO gate** in [`SHAMT_RULES.template.md`](../../../../templates/SHAMT_RULES.template.md#global-story-invariants): grep the implementation plan, spec, and changed source files for `TODO` markers. The gate allows TODO comments only for:

- explicit team-discussion placeholders, or
- temporary debug logging that must be removed before merge.

Every TODO must be either removed (commit the removal) or explicitly justified inline. The gate **fails** if any unexplained TODO remains.

If `.shamt-core/project-specific-files/CODING_STANDARDS.md` is stricter (e.g., no TODOs in production code at all), follow the stricter rule.

### Step 7 — Exit gate

Polish completes when:

- Every comment in the latest `review_vN.md` is `Resolved` or `Deferred — <reason>` or `Needs user decision` with an active follow-up. No `Pending` rows remain.
- Any `Required` Documentation Impact updates have been applied and re-validated.
- The TODO scan passes.
- Any root-cause proposals are filed under `.shamt-core/proposals/` as `.shamt-core/proposals/<proposal-slug>.md` (descriptive slug per Step 5, not the story slug).

Present the populated `addressed_feedback.md` to the user. Wait for the user to explicitly signal complete — Polish has no automatic completion gate; the user calls it done.

- **`pr_provider == github` + a PR recorded** — the fix commits have been pushed to the PR branch. Polish is **iterative**: as new human reviewer comments arrive on the PR, **re-run `/e8-resolve-feedback {slug}`** — each run re-inventories the latest PR comments (Step 1) and works any new ones, deduped against `addressed_feedback.md`. Pull-only: the command never replies to or resolves threads; the human resolves them on GitHub. When all feedback is addressed and the PR is approved, proceed to `/e9-finalize-story {slug}` (which merges the PR).
- **`pr_provider != github`** — unchanged: suggest the user push and open a PR manually (no tracker postback from any v2 command). When a re-review is requested, re-run `/e7-review-changes {slug}` (produces `review_v{N+1}.md`) and re-invoke this command.

## Exit criteria

- `addressed_feedback.md` exists and every comment is dispositioned.
- All `Required` doc-impact updates are applied and re-validated.
- TODO gate passes.
- Generalizable root causes are filed under `.shamt-core/proposals/`.
- The user has explicitly signalled complete.

## Notes

- This command is **fresh-agent runnable**: the latest `review_vN.md`, `addressed_feedback.md`, active spec/plan, and `active_artifacts.md` all live on disk. Resume from any point by re-reading them.
- **Re-baseline trigger.** If applying a comment would make the active spec or plan misleading (e.g., the comment reveals a design gap, not just a code defect), stop and invoke the **Re-baseline Protocol** per [`SHAMT_RULES.template.md`](../../../../templates/SHAMT_RULES.template.md#requirement-re-baseline-protocol). Do not silently rewrite the active artifact.
- **Pull-only PR participation (Pattern 4 no-postback preserved on the write side).** When `pr_provider == github` and a PR is recorded, Polish **pulls** the latest PR comments and **pushes** fix commits to the PR branch — neither is "postback" in the Pattern 4 sense (it never replies to, resolves, or posts review content to PR threads; the human resolves threads on GitHub). When `pr_provider != github`, Polish does not push, open PRs, or post to the tracker — the user does those manually.
- **No `Pending` rows at exit.** A comment left as `Pending` blocks the exit gate. `Deferred` with an explicit reason and forward link is fine.
- **Root cause is required** for every comment, including SUGGESTION / NITPICK. Step 5's proposal synthesis depends on it.
- **No-issue Polish** is mostly a no-op — TODO scan + Documentation Impact pass + (rarely) a forward proposal from a noted lesson. `addressed_feedback.md` is not required when there are no findings.
- Per [`reference/model_selection.md`](../../../../reference/model_selection.md), the mechanical fix tier is Sonnet; jump to Opus only when root-cause synthesis would benefit from multi-piece reasoning.

---
Validated 2026-05-28 — 4 rounds, 1 adversarial sub-agent confirmed (Phase 6 implementation loop)

<!-- Managed by Shamt — do not edit. Regenerate from shamt-core/host/templates/claude/commands/e8-resolve-feedback.md. -->
