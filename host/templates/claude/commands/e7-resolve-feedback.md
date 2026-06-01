---
description: Phase 7 (Polish) — apply review feedback to code, log each comment's disposition in addressed_feedback.md, apply any flagged .shamt-core/project-specific-files/ARCHITECTURE.md / .shamt-core/project-specific-files/CODING_STANDARDS.md updates, surface root-cause proposals to the framework-update flow
---

# /e7-resolve-feedback

**Purpose:** Run Phase 7 (Polish) of the Engineer flow. Apply the findings from the latest story-mode `review_vN.md`, log each comment's handling in `addressed_feedback.md`, perform any **Documentation Impact** updates the Review phase flagged, and route generalizable root-cause patterns to the framework-update flow rather than patching in-story.

**Recommended models:**

- Mechanical fixes (apply a reviewer's `Suggested fix`): Balanced (Sonnet).
- Root-cause / upstream-proposal synthesis (recurring findings → `.shamt-core/proposals/<proposal-slug>.md` — descriptive slug, not the story slug): Reasoning (Opus).

See [`reference/model_selection.md`](../../../../reference/model_selection.md).

---

## Usage

```
/e7-resolve-feedback {slug}
```

## Arguments

- `{slug}` (required) — story slug. Resolved via the global story-folder rules (exact `stories/{slug}/`, then `stories/{slug}-*/` glob; halt on multiple or zero matches).

## Prerequisites

- Story folder resolves; if `stories/{slug}/active_artifacts.md` exists, read it first.
- The active spec exists with a validation footer.
- `stories/{slug}/feedback/` contains at least one `review_vN.md` with a validation footer. If `feedback/` is empty (Quick-path no-issue path used the `## Post-Build Review` block in the spec instead), this command is mostly a TODO-scan no-op — see Step 6.
- `.shamt-core/project-specific-files/ARCHITECTURE.md` and `.shamt-core/project-specific-files/CODING_STANDARDS.md` paths are known (read the active review's `## Documentation Impact` block to learn whether either needs an update).

## Step-by-step

### Step 1 — Inventory feedback

1. Walk `stories/{slug}/feedback/` and pick the **latest** `review_vN.md` (highest N). Older `review_v*.md` files are historical — do not re-resolve closed comments.
2. Read its `## Plan Alignment`, leadership sections (`## Blockers`, `## Required Changes`, `## Suggestions`), `## Monitoring Checklist`, `## Security Checklist`, and `## Documentation Impact`.
3. Build a working list of every finding, keyed by section (BLOCKING → CONCERN → SUGGESTION → NITPICK).
4. If `stories/{slug}/feedback/addressed_feedback.md` already exists from a prior Polish pass, read it — comments already marked `Resolved` stay closed; comments marked `Pending` or `Needs user decision` go into this pass.

### Step 2 — Open or update `addressed_feedback.md`

Create (or update) `stories/{slug}/feedback/addressed_feedback.md`. Track every reviewer comment with this row shape:

```markdown
### [SEVERITY] — <Category> — <one-line summary>

- **Source:** `feedback/review_vN.md` (`Blockers` / `Required Changes` / `Suggestions` / `Monitoring Checklist` / `Security Checklist`)
- **Disposition:** `Pending` | `Resolved` | `Deferred — <reason>` | `Needs user decision`
- **Action taken:** <commit SHA(s), file(s) changed, or `N/A — deferred / needs decision`>
- **Root cause:** <one-line summary of why the issue existed — needed for Step 5>
- **Notes:** <anything else worth carrying forward>
```

Start every comment as `Pending`. Move to `Resolved` only after the fix is committed and verified.

### Step 3 — Resolve comments one at a time

Process comments in **descending severity** order — BLOCKING first, then CONCERN, SUGGESTION, NITPICK. Within a severity, any order is fine.

Per comment:

1. **Understand** — re-read the finding and the file/line it cites. If unclear, surface a one-question dialog to the user via `AskUserQuestion` (open-questions iterative dialog, Principle 2). Update `addressed_feedback.md`'s `Notes` with the answer.
2. **Decide disposition**:
   - **Fix in-story** — apply the change; commit per the project's commit convention (the same one the plan used, e.g., `#{slug}: address review BLOCKING <category>`); update `Action taken` with the commit SHA.
   - **Defer** — only when the user explicitly accepts deferral. Capture the reason and a forward link (e.g., `Deferred — captured at .shamt-core/proposals/<slug>.md` or `Deferred — tracker work-item <id>`).
   - **Needs user decision** — when a comment cannot be dispositioned without product/platform input. Surface the question to the user; do not leave the comment dangling on `Needs user decision` past the end of the pass.
3. **Verify** — re-run the relevant part of the active plan's `## Verification` section (Standard) or the spec's `## Verification` (Quick) for any code path the fix touched. For Standard path, if a fix is non-trivial, re-hand off to the `plan-executor` builder for the modified step.
4. **Reflect on root cause** — write the one-line `Root cause` in `addressed_feedback.md` (e.g., `Validation missed at Step 4 — locate string ambiguity`, `Spec under-specified Logging convention`, `CODING_STANDARDS rule X was not surfaced in Plan Compliance map`). Required even for SUGGESTION / NITPICK fixes — Step 5 reads these.
5. **Close** — mark the comment `Resolved` (or `Deferred` / `Needs user decision` if applicable).

### Step 4 — Documentation Impact update

If the active review's `## Documentation Impact` block declared either doc `Required`:

1. Apply the `Polish action` from that block to `.shamt-core/project-specific-files/ARCHITECTURE.md` and/or `.shamt-core/project-specific-files/CODING_STANDARDS.md`. Update the `Last Updated` field; append a one-line entry to `Update History` referencing this story's slug.
2. Re-validate the touched doc via `/validate-artifact .shamt-core/project-specific-files/ARCHITECTURE.md` (or `/validate-artifact .shamt-core/project-specific-files/CODING_STANDARDS.md`). Uses the 5 general dimensions. Footer.
3. Commit the doc change with the project's commit convention.

If both docs were `Not required`, skip this step.

### Step 5 — Root-cause / upstream proposals

For each comment's `Root cause`, ask: **is this a pattern that generalizes beyond this story?**

- **Yes** (recurring across stories, framework-wide gap, missing Review Prevention Gate, model-tier mis-pinning, etc.) → route through the **framework-update flow** per [`SHAMT_RULES.template.md`](../../../../templates/SHAMT_RULES.template.md#framework-maintenance). Create a `.shamt-core/proposals/<proposal-slug>.md` rather than patching framework files directly — the **proposal slug is descriptive** (e.g., `add-tenant-bypass-gate`, `pin-haiku-for-formal-git-metadata`), not necessarily the story slug; a single story can surface multiple distinct proposals. Reference the proposal(s) in the comment's `Notes`.
- **No** (story-specific bug, ad-hoc edge case, one-off naming preference) → no proposal; the fix in-story is enough.

This is the §1.12 + Part 3 lesson — durable framework improvements happen via proposals, not in-story shortcuts.

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

Suggest the user push and open a PR (manual — no tracker postback from any v2 command). When a re-review is requested, re-run `/e6-review-changes {slug}` (produces `review_v{N+1}.md`) and re-invoke this command.

## Exit criteria

- `addressed_feedback.md` exists and every comment is dispositioned.
- All `Required` doc-impact updates are applied and re-validated.
- TODO gate passes.
- Generalizable root causes are filed under `.shamt-core/proposals/`.
- The user has explicitly signalled complete.

## Notes

- This command is **fresh-agent runnable**: the latest `review_vN.md`, `addressed_feedback.md`, active spec/plan, and `active_artifacts.md` all live on disk. Resume from any point by re-reading them.
- **Re-baseline trigger.** If applying a comment would make the active spec or plan misleading (e.g., the comment reveals a design gap, not just a code defect), stop and invoke the **Re-baseline Protocol** per [`SHAMT_RULES.template.md`](../../../../templates/SHAMT_RULES.template.md#requirement-re-baseline-protocol). Do not silently rewrite the active artifact.
- **No tracker postback.** Polish does not push, open PRs, or post to the tracker. The user does those manually.
- **No `Pending` rows at exit.** A comment left as `Pending` blocks the exit gate. `Deferred` with an explicit reason and forward link is fine.
- **Root cause is required** for every comment, including SUGGESTION / NITPICK. Step 5's proposal synthesis depends on it.
- **Quick-path no-issue Polish** is mostly a no-op — TODO scan + Documentation Impact pass + (rarely) a forward proposal from a noted lesson. `addressed_feedback.md` is not required when there are no findings.
- Per [`reference/model_selection.md`](../../../../reference/model_selection.md), the mechanical fix tier is Sonnet; jump to Opus only when root-cause synthesis would benefit from multi-piece reasoning.

---
Validated 2026-05-28 — 4 rounds, 1 adversarial sub-agent confirmed (Phase 6 implementation loop)

<!-- Managed by Shamt — do not edit. Regenerate from shamt-core/host/templates/claude/commands/e7-resolve-feedback.md. -->
