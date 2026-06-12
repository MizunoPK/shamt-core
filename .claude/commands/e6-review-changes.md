---
description: Phase 6 (Review) — story-mode review of a story's own changes against the spec/plan, or formal-mode review of a named branch/PR via the review-executor persona. Local artifact only; never posts back to external trackers.
---

# /e6-review-changes

**Purpose:** Run Pattern 4 (Code Review). Two modes:

- **Story mode** — `/e6-review-changes {slug}`: review the code just built for a story against its own spec / plan / Build Checklist. The primary agent runs the 16-category sweep at story altitude. Output lives in `stories/{slug}/feedback/review_vN.md`.
- **Formal mode** — `/e6-review-changes --branch=<name>` or `/e6-review-changes --pr=<id>`: review someone else's branch or PR. Hands off to the `review-executor` Opus persona. Output lives in `code_reviews/<sanitized-branch>/overview.md` + `review_vN.md`.

The artifact is **local only** in both modes. Even when the active tracker profile documents a PR-comment command, this command does not invoke it (per [`SHAMT_RULES.template.md`](../../../../templates/SHAMT_RULES.template.md#pattern-4-code-review-process)).

**Recommended models:**

- **Story mode:** Balanced (Sonnet) — 16-category sweep at story altitude.
- **Formal mode:** Reasoning (Opus) via [`agents/review-executor.md`](../agents/review-executor.md) for issue-finding; Cheap (Haiku) is acceptable for the git-metadata gathering inside the persona.

See [`reference/model_selection.md`](../../../../reference/model_selection.md).

---

## Usage

```
/e6-review-changes {slug}                # story mode
/e6-review-changes --branch=<name>       # formal mode — named branch
/e6-review-changes --pr=<id>             # formal mode — tracker PR / MR ID
```

Exactly one of `{slug}`, `--branch=<name>`, or `--pr=<id>` is required. If none or more than one is provided, halt and ask.

## Arguments

- `{id-or-slug}` (story mode) — story ticket ID (`T{N}`) or slug. Resolved via the global story-folder rules (ID glob `stories/{ID}-*/`, else the both-positions slug glob; halt on multiple or zero matches).
- `--branch=<name>` (formal mode) — a local or remote feature branch name. Slashes are sanitized for the output folder (e.g., `feature/123-foo` → `feature-123-foo`).
- `--pr=<id>` (formal mode) — tracker PR or MR ID. Resolved to a head branch and base branch via the active tracker profile (`reference/trackers/<profile>.md` `## PR fetch` command).

Optional in both modes:

- `--base=<name>` — explicit review base. When omitted, the base is resolved per the rule in [`SHAMT_RULES.template.md`](../../../../templates/SHAMT_RULES.template.md#pattern-4-code-review-process) — (a) PR target branch when available, (b) project default formal-review base from `.shamt-core/project-specific-files/ARCHITECTURE.md`, (c) repository default branch.

## Prerequisites

- `.shamt-core/project-specific-files/ARCHITECTURE.md` and `.shamt-core/project-specific-files/CODING_STANDARDS.md` exist at the project root (note their absence inline if missing — `## Standards check` invariant — and continue).
- **Story mode:** story folder resolves; the active spec is present; Build (and Test, when enabled) has completed.
- **Formal mode:** `git` is available; the configured remote is reachable for the fetch. If the current local branch is the feature branch being reviewed, run `git status --short` first — if there are uncommitted changes, halt and ask whether to include, stash, commit, or ignore them.

## Mode selection

If `{slug}` is the first positional argument and `--branch` / `--pr` is absent → **story mode**.
If `--branch=<name>` or `--pr=<id>` is provided → **formal mode**.

State the chosen mode in one line before the first action.

---

## Story mode

### Step 1 — Resolve story artifacts

1. Apply the active-artifact pointer; resolve `spec`, `context` (Standard only), `implementation_plan` (Standard only), and `testing_plan` (when testing is enabled **and** the story uses a full artifact rather than the Quick-path inline checklist in `spec.md`) paths.
2. Confirm each resolved artifact has a validation footer. If any is missing, halt — review starts after approved gates. (Quick-path inline test checklists live under the spec's footered surface and don't need a separate footer check.)
3. Resolve the story folder per `templates/SHAMT_RULES.template.md` §PO-tree resolution (tree-wide glob + legacy-flat fallback); `stories/{slug}/` below denotes that resolved folder. Walk `stories/{slug}/feedback/` (when present) for existing `review_v*.md` files; the next review version is `vN+1`.

### Step 2 — Plan Alignment pre-pass

Required for **Story mode** (per [`SHAMT_RULES.template.md`](../../../../templates/SHAMT_RULES.template.md#pattern-4-code-review-process)):

| Path | Plan Alignment input |
|------|----------------------|
| Quick path | `N/A — Quick path used the spec Build Checklist instead of implementation_plan.md.` |
| Standard path | Read the active plan alongside the diff. Walk: **Step Coverage** (every plan step is reflected in the diff), **Change Fidelity** (every code change traces to a plan step), **Scope Discipline** (no out-of-plan changes), **Verification Passage** (the plan's `## Verification` section is satisfied), **Zero Builder Design Decisions** (no design choices were made during Build). |

Write the `## Plan Alignment` section at the top of `review_vN.md`. On Quick path it is one line; on Standard path it lists each check's result.

### Step 3 — 16-category sweep

Walk the 16 categories per [`reference/review_categories.md`](../../../../reference/review_categories.md). **Every category must be considered**, even when no finding is recorded.

For each changed file, read the full file (not just the diff hunks) when surrounding context controls a finding. Categories that almost always require the full file: logging, exception handling, function decomposition, auth, tenant isolation, state / token handling, database routing, monitoring.

Apply the **Review Prevention Gates** overlay from [`reference/pr_review_prevention.md`](../../../../reference/pr_review_prevention.md). Each applicable surface should map to a checklist entry under `Monitoring Checklist` or `Security Checklist` (per [`templates/code_review.template.md`](../../../../templates/code_review.template.md)).

Hard checks (Pattern 1 code-review dimensions in [`SHAMT_RULES.template.md`](../../../../templates/SHAMT_RULES.template.md#pattern-1-validation-loops)):

- Review every changed file / function / branch **independently**. Do not assume parallel files are identical.
- Review **removed or weakened security checks** and verify equivalent protection still exists.
- For tenant / path / object / document access changes, explicitly consider a tenant-A-to-tenant-B bypass.
- For DB schema work, trace the end-to-end cross-service read/write data lineage.

### Step 4 — Documentation Impact Assessment

At the end of the sweep, answer **explicitly**: does this change require an `.shamt-core/project-specific-files/ARCHITECTURE.md` or `.shamt-core/project-specific-files/CODING_STANDARDS.md` update?

Triggers include: new service / boundary / data store added; deprecated pattern; new convention introduced; or this change actually touches a doc whose `Last Updated` field is stale (older than `.shamt-core/shamt-config.json` → `doc_staleness_threshold_days`). Story-level Doc Impact only fires when this change touches the doc — pure staleness without a touching change is the audit's D6 (doc currency) dimension, not Phase 6's responsibility.

Record the assessment as a `## Documentation Impact` block at the bottom of `review_vN.md`. Format:

```markdown
## Documentation Impact

- **.shamt-core/project-specific-files/ARCHITECTURE.md:** Required | Not required — <one-line reason>
- **.shamt-core/project-specific-files/CODING_STANDARDS.md:** Required | Not required — <one-line reason>
- **Polish action:** <Specific update Polish must apply, or "None.">
```

When `Required`, Polish (`/e7-resolve-feedback`) applies the update and re-validates the doc — see [`SHAMT_RULES.template.md`](../../../../templates/SHAMT_RULES.template.md#part-3-engineer-flow--phase-narratives) Phase 7.

### Step 5 — Write the review artifact

Write `stories/{slug}/feedback/review_vN.md` using the **Review Document** shape from [`templates/code_review.template.md`](../../../../templates/code_review.template.md). Required sections:

- Header metadata (`Reviewed`, `Base`, `Commits`, `Files changed`, `Story: stories/{slug}/`, `Baseline reviewed: vN` when multiple baselines exist).
- `## Plan Alignment` (from Step 2).
- `## Summary`, `## Verdict`, `## Degree of Risk`, `## Changed File Inventory`.
- `## Blockers` / `## Required Changes` / `## Suggestions` (omit a leadership section entirely when it has no findings).
- `## Monitoring Checklist` and `## Security Checklist` (always present; `N/A — <reason>` when nothing applies).
- `## Positive Notes`.
- `## Documentation Impact` (from Step 4).

Severities follow Pattern 4's reporting ladder: **BLOCKING / CONCERN / SUGGESTION / NITPICK**. Each finding uses [`reference/review_categories.md`](../../../../reference/review_categories.md)'s finding format (severity, category, file + line, description, suggested fix).

**Quick-path no-issue shortcut:** when the path is Quick and no issues are found, the durable `review_vN.md` is optional — append a `## Post-Build Review` block to the spec instead (per [`reference/review_categories.md`](../../../../reference/review_categories.md#quick-path-no-artifact-reviews)). If any finding exists (or the user explicitly asked for the artifact), still write `review_vN.md`.

### Step 6 — Validate the review artifact

Invoke `/validate-artifact stories/{slug}/feedback/review_vN.md`. Uses the **7 dimensions** for story-mode review (6 review dimensions + Plan Alignment). Exit per [`SHAMT_RULES.template.md`](../../../../templates/SHAMT_RULES.template.md#pattern-1-validation-loops): Standard path uses primary clean + 1 adversarial sub-agent; Quick path may use a single primary pass unless a risk trigger applies. Footer.

If `active_artifacts.md` exists, add `Baseline reviewed: vN` to the review's header — confirms which spec/plan baseline this review evaluated.

### Step 7 — Exit

Present the validated `review_vN.md` to the user. Suggest:

- **Findings present** → `/clear`, then `/e7-resolve-feedback {slug}` (Phase 7 — Polish).
- **No findings** (Quick-path inline `## Post-Build Review`) → user-driven next step (Polish is usually a no-op).

---

## Formal mode

### Step 1 — Resolve target and base

1. If `--pr=<id>` was provided, read `.shamt-core/shamt-config.json` → `pr_provider`, then read `reference/trackers/<provider>.md`'s `## PR fetch` command and run it to get head branch + target branch. If the provider is `none` or the profile does not declare a PR fetch, halt and direct the user to pass `--branch` explicitly.
2. If `--branch=<name>` was provided, that is the feature branch.
3. Resolve the base per the rule in Arguments. State the resolved base in one line.

### Step 2 — Hand off to review-executor

Spawn the `review-executor` persona — see [`agents/review-executor.md`](../agents/review-executor.md). Provide:

- `branch` or `pr` (the form the user passed),
- `base` (resolved),
- `governing_refs` (`.shamt-core/project-specific-files/ARCHITECTURE.md`, `.shamt-core/project-specific-files/CODING_STANDARDS.md`).

Example invocation (Claude Code Task tool):

```text
subagent_type: review-executor
description: Formal review — {branch or PR ID}
prompt: |
  branch: feature/123-foo-bar         # or pr: 4567
  base: main                          # resolved
  governing_refs: [.shamt-core/project-specific-files/ARCHITECTURE.md, .shamt-core/project-specific-files/CODING_STANDARDS.md]
  Produce overview.md and review_vN.md under code_reviews/<sanitized-branch>/.
  Read-only git; no checkout, no push, no tracker postback. Apply the 16
  Pattern 4 categories. Validate each artifact via /validate-artifact.
```

### Step 3 — Monitor

Watch the executor's report. Route per the message form (see [`agents/review-executor.md`](../agents/review-executor.md)):

- **`Formal review complete. Artifacts at code_reviews/<sanitized-branch>/...`** — proceed to Step 4.
- **`Formal review complete with N findings — <BLOCKING / CONCERN counts>.`** — same as above; surface the counts in the exit message.
- **`Halted at <phase>: …`** — surface the specific blocker (fetch failed, uncommitted changes, governing doc missing) to the user via `AskUserQuestion`; resolve and re-invoke.

### Step 4 — Exit

Surface the artifact paths and the verdict / risk to the user. The user posts back to the tracker manually if they want to (no tracker postback from this command).

---

## Exit criteria

- **Story mode:** `stories/{slug}/feedback/review_vN.md` exists with validation footer (or, on a Quick-path no-issue review, `## Post-Build Review` appended to the active spec); `## Documentation Impact` block populated; `Baseline reviewed: vN` set when multiple baselines exist.
- **Formal mode:** `code_reviews/<sanitized-branch>/overview.md` + `review_vN.md` exist, each with a validation footer.

## Notes

- This command is **fresh-agent runnable**: story mode reads on-disk artifacts; formal mode reads the git tree read-only. State is determined by artifact presence.
- The 16 categories are mandatory **considerations**, not mandatory findings. A category with no finding is still considered — note `N/A` for `Monitoring Checklist` / `Security Checklist` when no applicable surface was touched, but do not skip the category.
- **No tracker postback.** Even when the tracker profile documents a PR-comment command, this command does not call it. The user posts back manually if desired. This is the Pattern 4 resolution.
- **Severity ladders are distinct.** Findings use the **BLOCKING / CONCERN / SUGGESTION / NITPICK** ladder (Pattern 4). The internal Pattern 1 / Pattern 2 validation on `review_vN.md` itself uses the CRITICAL / HIGH / MEDIUM / LOW ladder.
- **Quick-path shortcut** is opt-in only when zero issues are found. The moment one finding exists, write the durable `review_vN.md` artifact even on Quick path.
- **Single-session sizing constraint** (Principle 1): if a branch is large enough to compact within a session, the review-executor produces phase-decomposed output (`overview.md` + multiple `review_vN_section_<area>.md` files) and reports each piece. The 16 categories still apply across all sections.

---
Validated 2026-05-28 — 4 rounds, 1 adversarial sub-agent confirmed (Phase 6 implementation loop)

<!-- Managed by Shamt — do not edit. Regenerate from shamt-core/host/templates/claude/commands/e6-review-changes.md. -->
