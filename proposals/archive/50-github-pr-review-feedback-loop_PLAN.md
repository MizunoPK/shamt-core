# Implementation Plan: github-pr-review-feedback-loop

**Proposal:** proposals/50-github-pr-review-feedback-loop.md
**Created:** 2026-06-21
**File operations:** 14 (CREATE: 0, EDIT: 14, DELETE: 0, MOVE: 0)

## Pre-execution checklist
- [ ] On a clean working tree (or working in a worktree dedicated to this proposal).
- [ ] `proposals/50-github-pr-review-feedback-loop.md` validation footer present.
- [ ] Branch created by `/f3-implement-update`: `proposal/50-github-pr-review-feedback-loop` from the base branch, immediately before the canonical edits. (Authoring/validation/planning happen on the base branch; the architect/builder path's executor creates this branch when it runs this pre-execution checklist at Phase 4.)

## Files manifest

| # | Path | Operation | Sibling / template (if any) |
|---|------|-----------|------------------------------|
| 1 | `host/templates/claude/commands/e6-review-changes.md` | EDIT | — |
| 2 | `host/templates/claude/commands/e7-resolve-feedback.md` | EDIT | — |
| 3 | `host/templates/claude/commands/e-all.md` | EDIT | — |
| 4 | `host/templates/claude/commands/e8-finalize-story.md` | EDIT | — |
| 5 | `host/templates/claude/skills/e6-review-changes/SKILL.md` | EDIT | — |
| 6 | `host/templates/claude/skills/e7-resolve-feedback/SKILL.md` | EDIT | — |
| 7 | `host/templates/claude/skills/e-all/SKILL.md` | EDIT | — |
| 8 | `host/templates/claude/skills/e8-finalize-story/SKILL.md` | EDIT | — |
| 9 | `reference/trackers/github.md` | EDIT | — |
| 10 | `reference/trackers/_contract.md` | EDIT | — |
| 11 | `reference/trackers/ado.md` | EDIT | — |
| 12 | `reference/trackers/local.md` | EDIT | — |
| 13 | `templates/SHAMT_RULES.template.md` | EDIT | — |
| 14 | `README.md` | EDIT | — |

> **Ordering note.** Steps are ordered references-first (the tracker-contract + profile sections the commands invoke), then commands, then skills, then rules + README. This lets each command edit cite a profile section that already exists. Within the references, `_contract.md` (the required-section list) precedes the three profiles so the contract surface is declared before the profiles that must satisfy it. No step depends on the working-tree output of another beyond section existence, which the whole-plan verification re-confirms.

> **All paths are repo-root-relative canonical sources** (master / self-host: the repo root). No step touches `.claude/` — regen (Phase 5) propagates these edits.

---

## Step-by-step

### Step 1 — github.md: add `## PR create` / `## PR comment fetch` / `## PR merge` sections (proposal row 9)

**Operation:** EDIT
**File:** `reference/trackers/github.md`
**Locate:**
```
## PR comment posting

**Not invoked by v2.** Documented for future use only — `/e6-review-changes` produces a local artifact at `code_reviews/` and does not post upstream (resolved open question).
```
**Replace:**
```
## PR create

Used by `/e6-review-changes` (story mode) at the end of the Review stage when `pr_provider == github`: push the story branch and open the PR. Confirm-gated by the consuming command (outward action).

```bash
# Push the story's current (feature) branch and open the PR
git push -u origin HEAD
gh pr create --repo <org>/<repo> --base <base> --head <head> \
  --title "<title>" --body "<markdown body>" --json number,url
```

`gh pr create` prints the new PR URL; pass `--json number,url` (or follow with `gh pr view --json number,url`) to capture the PR number the consuming command records in the story folder.

## PR comment fetch

Used by `/e7-resolve-feedback` when a PR is recorded for the story and `pr_provider == github`: fetch the latest PR comments + review threads to fold into the feedback inventory. Pull-only — `/e7` never posts back (see `## PR comment posting`).

```bash
# Conversation comments + review summaries
gh pr view {id} --repo <org>/<repo> --json comments,reviews

# Review-thread comments (per-line / per-file), keyed by comment id for dedup
gh api repos/<org>/<repo>/pulls/{id}/comments --paginate
```

Each returned comment carries a stable `id` — the consuming command dedups against `addressed_feedback.md` by that comment-ID so a re-run never re-processes an already-resolved comment.

## PR merge

Used by `/e8-finalize-story` when `pr_provider == github`: merge the story's PR. Confirm-gated by the consuming command (outward, irreversible action), and preceded by a mergeability check.

```bash
# Mergeability guard — halt if not mergeable (unresolved reviews / failing checks)
gh pr view {id} --repo <org>/<repo> --json mergeable,mergeStateStatus,reviewDecision,statusCheckRollup

# Squash-merge and delete the branch
gh pr merge {id} --repo <org>/<repo> --squash --delete-branch
```

`mergeable` (`MERGEABLE` / `CONFLICTING` / `UNKNOWN`) plus `reviewDecision` (`APPROVED` / `REVIEW_REQUIRED` / `CHANGES_REQUESTED`) and `statusCheckRollup` let the consuming command halt before merging an un-mergeable PR.

## PR comment posting

**Not invoked by v2.** Documented for future use only — `/e6-review-changes` produces a local artifact at `code_reviews/` and does not post upstream (resolved open question). `/e7-resolve-feedback` is **pull-only** (see `## PR comment fetch`): it fetches comments and pushes fix commits, but never replies to or resolves threads.
```
**Verification:**
- `grep -nF '## PR create' reference/trackers/github.md` returns one match.
- `grep -nF '## PR comment fetch' reference/trackers/github.md` returns one match.
- `grep -nF '## PR merge' reference/trackers/github.md` returns one match.
- `grep -nF '--squash --delete-branch' reference/trackers/github.md` returns one match.
- `grep -cnF '## PR comment posting' reference/trackers/github.md` returns 1 (the section was preserved, not duplicated).

---

### Step 2 — _contract.md: add the three PR sections to Required sections (proposal row 10)

**Operation:** EDIT
**File:** `reference/trackers/_contract.md`
**Locate:**
```
| `## PR fetch` | CLI to retrieve PR metadata and diff for a given PR ID, parameterized on `{id}`. Used by `/e6-review-changes` when `pr_provider` is set to this tracker. |
| `## PR comment posting` | CLI to post a Markdown comment to a PR. **Documented for future use only — `/e6-review-changes` does not post back to external trackers in v2.** A profile is still required to declare this so the contract surface stays complete for future use. |
```
**Replace:**
```
| `## PR fetch` | CLI to retrieve PR metadata and diff for a given PR ID, parameterized on `{id}`. Used by `/e6-review-changes` when `pr_provider` is set to this tracker. |
| `## PR create` | CLI to push a branch and open a PR. Used by `/e6-review-changes` (story mode) at the end of Review when `pr_provider == github`. Required of every profile so the contract surface stays complete; a profile with no PR concept (`local`) declares `n/a`, and a profile not yet wired (`ado`) may declare the command shape or a not-yet-wired note. |
| `## PR comment fetch` | CLI to fetch the latest PR comments + review threads (keyed by comment-ID). Used by `/e7-resolve-feedback` when a PR is recorded and `pr_provider == github`. Required of every profile (same may-be-stubbed rule as `## PR create`). |
| `## PR merge` | CLI to merge a PR (squash + delete branch), with a mergeability check. Used by `/e8-finalize-story` when `pr_provider == github`. Required of every profile (same may-be-stubbed rule as `## PR create`). |
| `## PR comment posting` | CLI to post a Markdown comment to a PR. **Documented for future use only — `/e6-review-changes` does not post back to external trackers in v2, and `/e7-resolve-feedback` is pull-only (it fetches comments but never replies).** A profile is still required to declare this so the contract surface stays complete for future use. |
```
**Verification:**
- `grep -nF '| `## PR create` |' reference/trackers/_contract.md` returns one match.
- `grep -nF '| `## PR comment fetch` |' reference/trackers/_contract.md` returns one match.
- `grep -nF '| `## PR merge` |' reference/trackers/_contract.md` returns one match.

---

### Step 3 — _contract.md: add the three PR sections to the "Where the contract is exercised" table (proposal row 10)

**Operation:** EDIT
**File:** `reference/trackers/_contract.md`
**Locate:**
```
| `/e6-review-changes {slug}` | `## PR fetch`, `## Auth failure modes`. Driven by `pr_provider` (which may differ from `work_item_tracker`). | Phase 6 (Review) |
```
**Replace:**
```
| `/e6-review-changes {slug}` | `## PR fetch`, `## Auth failure modes`; `## PR create` (story mode, when `pr_provider == github`). Driven by `pr_provider` (which may differ from `work_item_tracker`). | Phase 6 (Review) |
| `/e7-resolve-feedback {slug}` | `## PR comment fetch` (when a PR is recorded and `pr_provider == github`). Driven by `pr_provider`. | Phase 7 (Polish) |
| `/e8-finalize-story {slug}` | `## PR merge` (when `pr_provider == github`). Driven by `pr_provider`. The work-item close stays `work_item_tracker`-routed, independent of `pr_provider`. | Phase 8 (Finalize) |
```
**Verification:**
- `grep -nF '`## PR comment fetch` (when a PR is recorded' reference/trackers/_contract.md` returns one match.
- `grep -nF '| `/e8-finalize-story {slug}` | `## PR merge`' reference/trackers/_contract.md` returns one match.

---

### Step 4 — ado.md: add `## PR create` / `## PR comment fetch` / `## PR merge` sections (proposal row 11)

**Operation:** EDIT
**File:** `reference/trackers/ado.md`
**Locate:**
```
## PR comment posting

**Not invoked by v2.** Documented for future use only — `/e6-review-changes` produces a local artifact at `code_reviews/` and does not post upstream (resolved open question).

For reference, the command shape is:
```
**Replace:**
```
## PR create

`/e6-review-changes` / `/e7-resolve-feedback` / `/e8-finalize-story` invoke `## PR create` / `## PR comment fetch` / `## PR merge` **only when `pr_provider == github`**. On ADO these are **not yet wired** — the consuming commands take no PR action for `pr_provider == ado`. The `az repos pr` command shapes below are recorded for when ADO PR support is added; declaring the sections keeps this profile contract-conformant.

```bash
# Open a PR (forward-looking — not invoked by v2)
az repos pr create --source-branch <head> --target-branch <base> \
  --title "<title>" --description "<markdown body>" --output json
```

## PR comment fetch

**Not yet wired** — see `## PR create`. Forward-looking shape:

```bash
az repos pr show --id {id} --output json   # plus thread fetch via az rest .../pullRequests/{id}/threads
```

## PR merge

**Not yet wired** — see `## PR create`. Forward-looking shape:

```bash
az repos pr update --id {id} --status completed --delete-source-branch true --squash true --output json
```

## PR comment posting

**Not invoked by v2.** Documented for future use only — `/e6-review-changes` produces a local artifact at `code_reviews/` and does not post upstream (resolved open question).

For reference, the command shape is:
```
**Verification:**
- `grep -nF '## PR create' reference/trackers/ado.md` returns one match.
- `grep -nF '## PR comment fetch' reference/trackers/ado.md` returns one match.
- `grep -nF '## PR merge' reference/trackers/ado.md` returns one match.
- `grep -cnF '## PR comment posting' reference/trackers/ado.md` returns 1 (section preserved, not duplicated).

---

### Step 5 — local.md: add `## PR create` / `## PR comment fetch` / `## PR merge` as `n/a` (proposal row 12)

**Operation:** EDIT
**File:** `reference/trackers/local.md`
**Locate:**
```
## PR comment posting

None. Not applicable.
```
**Replace:**
```
## PR create

`n/a — local has no PR.` PR creation is governed independently by `pr_provider`; `local` is a work-item-tracker mode only.

## PR comment fetch

`n/a — local has no PR.`

## PR merge

`n/a — local has no PR.`

## PR comment posting

None. Not applicable.
```
**Verification:**
- `grep -nF '## PR create' reference/trackers/local.md` returns one match.
- `grep -nF '## PR comment fetch' reference/trackers/local.md` returns one match.
- `grep -nF '## PR merge' reference/trackers/local.md` returns one match.
- `grep -cF 'n/a — local has no PR.' reference/trackers/local.md` returns 3.

---

### Step 6 — e6-review-changes.md: add the PR-create outcome after review validates, story mode (proposal row 1)

**Operation:** EDIT
**File:** `host/templates/claude/commands/e6-review-changes.md`
**Locate:**
```
### Step 7 — Exit

Present the validated `review_vN.md` to the user. Suggest:

- **Findings present** → `/clear`, then `/e7-resolve-feedback {slug}` (Phase 7 — Polish).
- **No findings** (Quick-path inline `## Post-Build Review`) → user-driven next step (Polish is usually a no-op).
```
**Replace:**
```
### Step 6b — Open the PR when `pr_provider == github`

After the review artifact validates (Step 6), read `.shamt-core/shamt-config.json` → `pr_provider`.

- **`pr_provider == github`** — push the story branch and open the PR so human review happens on the PR:
  1. **Confirm.** Present, in one message: the branch that will be pushed, the resolved base, and the PR title/body — then **wait for an explicit "yes."** Pushing a branch and opening a PR are outward-facing; never run them without confirmation.
  2. On confirmation, run the github profile's `## PR create` (`reference/trackers/github.md`): push the story's current feature branch and `gh pr create`. Resolve the base per the project default branch (or `.shamt-core/project-specific-files/ARCHITECTURE.md`'s declared base).
  3. **Record the PR number** into the story folder so `/e7-resolve-feedback` and `/e8-finalize-story` can resolve it without conversation history: write `stories/{slug}/feedback/pr.md` with the PR number and URL (e.g. `PR: #1234` / `URL: <pr url>`). This is the single source for the fetch + dedup in `/e7` and the merge in `/e8`.
- **`pr_provider != github`** (`ado` / `none` / unset) — **no-op.** No branch push, no PR; today's local-only behavior is unchanged.

### Step 7 — Exit

Present the validated `review_vN.md` to the user. Suggest:

- **Findings present, `pr_provider == github`, PR opened** → `/clear`, then `/e7-resolve-feedback {slug}` (Phase 7 — Polish), which now also pulls the PR's comments. Re-runnable N times as new comments arrive.
- **Findings present, `pr_provider != github`** → `/clear`, then `/e7-resolve-feedback {slug}` (Phase 7 — Polish).
- **No findings** (Quick-path inline `## Post-Build Review`) → user-driven next step (Polish is usually a no-op).
```
**Verification:**
- `grep -nF '### Step 6b — Open the PR when `pr_provider == github`' host/templates/claude/commands/e6-review-changes.md` returns one match.
- `grep -nF 'feedback/pr.md' host/templates/claude/commands/e6-review-changes.md` returns one match.
- `grep -cnF '### Step 7 — Exit' host/templates/claude/commands/e6-review-changes.md` returns 1.

---

### Step 7 — e6-review-changes.md: add the PR-create outcome to Exit criteria (proposal row 1)

**Operation:** EDIT
**File:** `host/templates/claude/commands/e6-review-changes.md`
**Locate:**
```
- **Story mode:** `stories/{slug}/feedback/review_vN.md` exists with validation footer (or, on a Quick-path no-issue review, `## Post-Build Review` appended to the active spec); `## Documentation Impact` block populated; `Baseline reviewed: vN` set when multiple baselines exist.
```
**Replace:**
```
- **Story mode:** `stories/{slug}/feedback/review_vN.md` exists with validation footer (or, on a Quick-path no-issue review, `## Post-Build Review` appended to the active spec); `## Documentation Impact` block populated; `Baseline reviewed: vN` set when multiple baselines exist. When `pr_provider == github`, the story branch is pushed and the PR opened (confirm-gated), with the PR number recorded at `stories/{slug}/feedback/pr.md`; when `pr_provider != github` no PR action is taken.
```
**Verification:**
- `grep -nF 'recorded at `stories/{slug}/feedback/pr.md`' host/templates/claude/commands/e6-review-changes.md` returns one match.

---

### Step 8 — e7-resolve-feedback.md: make Step 1 a union of local findings + PR comments (proposal row 2)

**Operation:** EDIT
**File:** `host/templates/claude/commands/e7-resolve-feedback.md`
**Locate:**
```
### Step 1 — Inventory feedback

1. Walk `stories/{slug}/feedback/` and pick the **latest** `review_vN.md` (highest N). Older `review_v*.md` files are historical — do not re-resolve closed comments.
2. Read its `## Plan Alignment`, leadership sections (`## Blockers`, `## Required Changes`, `## Suggestions`), `## Monitoring Checklist`, `## Security Checklist`, and `## Documentation Impact`.
3. Build a working list of every finding, keyed by section (BLOCKING → CONCERN → SUGGESTION → NITPICK).
4. If `stories/{slug}/feedback/addressed_feedback.md` already exists from a prior Polish pass, read it — comments already marked `Resolved` stay closed; comments marked `Pending` or `Needs user decision` go into this pass.
```
**Replace:**
```
### Step 1 — Inventory feedback (union of all sources, rebuilt every run)

The inventory is a **union of every feedback source, rebuilt on each run** — this command is **re-runnable N times** as new PR comments arrive. The two sources:

1. **Local self-review findings (unchanged).** Walk `stories/{slug}/feedback/` and pick the **latest** `review_vN.md` (highest N). Older `review_v*.md` files are historical — do not re-resolve closed comments. Read its `## Plan Alignment`, leadership sections (`## Blockers`, `## Required Changes`, `## Suggestions`), `## Monitoring Checklist`, `## Security Checklist`, and `## Documentation Impact`. Build a working list of every finding, keyed by section (BLOCKING → CONCERN → SUGGESTION → NITPICK).
2. **PR comments (additive — only when a PR is recorded and `pr_provider == github`).** If `stories/{slug}/feedback/pr.md` exists (written by `/e6-review-changes`) **and** `.shamt-core/shamt-config.json` → `pr_provider == github`, fetch the **latest** PR comments + review threads via the github profile's `## PR comment fetch` (`reference/trackers/github.md`). Each comment carries a stable **comment-ID**. This source is **additive** to the local findings, never a replacement; when no PR is recorded or `pr_provider != github`, skip this source entirely (the local-only path is exactly today's behavior). **Pull-only — never reply to or resolve PR threads** (Pattern 4 no-postback stance preserved on the write side; the pushed fix commits are the response, and the human resolves threads on GitHub).
3. **Dedup against the durable ledger.** `addressed_feedback.md` is the durable dedup ledger. If `stories/{slug}/feedback/addressed_feedback.md` already exists from a prior Polish pass, read it. An item already marked `Resolved` stays closed and is **not** re-processed; any **new** item from **either** source — a new PR comment keyed by its comment-ID, or a newer local `review_v{N+1}.md` finding — is added as `Pending` and worked this pass. Items marked `Pending` or `Needs user decision` also go into this pass.
```
**Verification:**
- `grep -nF 'union of every feedback source, rebuilt on each run' host/templates/claude/commands/e7-resolve-feedback.md` returns one match.
- `grep -nF 'Pull-only — never reply to or resolve PR threads' host/templates/claude/commands/e7-resolve-feedback.md` returns one match.
- `grep -nF 'keyed by its comment-ID' host/templates/claude/commands/e7-resolve-feedback.md` returns one match.

---

### Step 9 — e7-resolve-feedback.md: push fix commits to the PR branch in Step 3 (proposal row 2)

**Operation:** EDIT
**File:** `host/templates/claude/commands/e7-resolve-feedback.md`
**Locate:**
```
   - **Fix in-story** — apply the change; commit per the project's commit convention (the same one the plan used, e.g., `#{slug}: address review BLOCKING <category>`); update `Action taken` with the commit SHA.
```
**Replace:**
```
   - **Fix in-story** — apply the change; commit per the project's commit convention (the same one the plan used, e.g., `#{slug}: address review BLOCKING <category>`); update `Action taken` with the commit SHA. **When a PR is recorded + `pr_provider == github`, push the fix commits to the PR branch** (`git push`) so the human reviewer sees them on the PR — this push **is** the response (pull-only; no thread reply / no thread-resolve).
```
**Verification:**
- `grep -nF 'push the fix commits to the PR branch' host/templates/claude/commands/e7-resolve-feedback.md` returns one match.

---

### Step 10 — e7-resolve-feedback.md: update the Step-7 exit + Notes for the iterative PR loop (proposal row 2)

**Operation:** EDIT
**File:** `host/templates/claude/commands/e7-resolve-feedback.md`
**Locate:**
```
Present the populated `addressed_feedback.md` to the user. Wait for the user to explicitly signal complete — Polish has no automatic completion gate; the user calls it done.

Suggest the user push and open a PR (manual — no tracker postback from any v2 command). When a re-review is requested, re-run `/e6-review-changes {slug}` (produces `review_v{N+1}.md`) and re-invoke this command.
```
**Replace:**
```
Present the populated `addressed_feedback.md` to the user. Wait for the user to explicitly signal complete — Polish has no automatic completion gate; the user calls it done.

- **`pr_provider == github` + a PR recorded** — the fix commits have been pushed to the PR branch. Polish is **iterative**: as new human reviewer comments arrive on the PR, **re-run `/e7-resolve-feedback {slug}`** — each run re-inventories the latest PR comments (Step 1) and works any new ones, deduped against `addressed_feedback.md`. Pull-only: the command never replies to or resolves threads; the human resolves them on GitHub. When all feedback is addressed and the PR is approved, proceed to `/e8-finalize-story {slug}` (which merges the PR).
- **`pr_provider != github`** — unchanged: suggest the user push and open a PR manually (no tracker postback from any v2 command). When a re-review is requested, re-run `/e6-review-changes {slug}` (produces `review_v{N+1}.md`) and re-invoke this command.
```
**Verification:**
- `grep -nF 'Polish is **iterative**' host/templates/claude/commands/e7-resolve-feedback.md` returns one match.
- `grep -nF 'proceed to `/e8-finalize-story {slug}` (which merges the PR)' host/templates/claude/commands/e7-resolve-feedback.md` returns one match.

---

### Step 11 — e7-resolve-feedback.md: relax the "No tracker postback" Note to pull-only (proposal row 2)

**Operation:** EDIT
**File:** `host/templates/claude/commands/e7-resolve-feedback.md`
**Locate:**
```
- **No tracker postback.** Polish does not push, open PRs, or post to the tracker. The user does those manually.
```
**Replace:**
```
- **Pull-only PR participation (Pattern 4 no-postback preserved on the write side).** When `pr_provider == github` and a PR is recorded, Polish **pulls** the latest PR comments and **pushes** fix commits to the PR branch — neither is "postback" in the Pattern 4 sense (it never replies to, resolves, or posts review content to PR threads; the human resolves threads on GitHub). When `pr_provider != github`, Polish does not push, open PRs, or post to the tracker — the user does those manually.
```
**Verification:**
- `grep -nF 'Pull-only PR participation (Pattern 4 no-postback preserved on the write side)' host/templates/claude/commands/e7-resolve-feedback.md` returns one match.
- `grep -cnF '**No tracker postback.**' host/templates/claude/commands/e7-resolve-feedback.md` returns 0 (the old Note bullet was replaced).

---

### Step 12 — e-all.md: stop the chain at the end of `/e6` in the chain table (proposal row 3)

**Operation:** EDIT
**File:** `host/templates/claude/commands/e-all.md`
**Locate:**
```
Phase 6  /e6-review-changes                           [always]
Phase 7  /e7-resolve-feedback                          [always]
Phase 8  /e8-finalize-story                            [always — terminal, user-gated commit]
```
**Replace:**
```
Phase 6  /e6-review-changes                           [always — terminal for /e-all; opens the PR when pr_provider == github]
         /e7-resolve-feedback (Polish, iterative)     [operator-driven — NOT auto-run by /e-all]
         /e8-finalize-story  (Finalize)               [operator-driven — NOT auto-run by /e-all]
```
**Verification:**
- `grep -nF 'terminal for /e-all; opens the PR when pr_provider == github' host/templates/claude/commands/e-all.md` returns one match.
- `grep -nF 'operator-driven — NOT auto-run by /e-all' host/templates/claude/commands/e-all.md` returns two matches.

---

### Step 13 — e-all.md: update the chain-intro one-liner + the gate list (proposal row 3)

**Operation:** EDIT
**File:** `host/templates/claude/commands/e-all.md`
**Locate:**
```
description: Driver — walk a single story through every remaining Engineer-flow phase (e1 → e2 → optional e3+e3b → e4 → e5 → e6 → e7 → e8) by dispatching one independent agent per phase, deriving the start phase from on-disk artifacts, pausing on each interactive gate or structured open question via AskUserQuestion, and halting on any failure it cannot resolve
```
**Replace:**
```
description: Driver — walk a single story through every remaining Engineer-flow phase up to and including Review (e1 → e2 → optional e3+e3b → e4 → e5 → e6, opening the PR when pr_provider == github) by dispatching one independent agent per phase, deriving the start phase from on-disk artifacts, pausing on each interactive gate or structured open question via AskUserQuestion, and halting on any failure it cannot resolve. Polish (/e7, iterative) and Finalize (/e8) are operator-driven — not auto-run
```
**Verification:**
- `grep -nF 'up to and including Review' host/templates/claude/commands/e-all.md` returns one match.
- `grep -nF 'Polish (/e7, iterative) and Finalize (/e8) are operator-driven' host/templates/claude/commands/e-all.md` returns one match.

---

### Step 14 — e-all.md: update the Step-1 start-phase derivation table for the Review-terminal chain (proposal row 3)

**Operation:** EDIT
**File:** `host/templates/claude/commands/e-all.md`
**Locate:**
```
| Tests pass; `feedback/review_vN.md` **not** footed (and no Quick-path `## Post-Build Review` block on the footed spec) | Review not done | Phase 6 (`/e6`) |
| Review done; `feedback/addressed_feedback.md` **not** dispositioned | Polish not done | Phase 7 (`/e7`) |
| Polish done; `ticket.md` does **not** carry `**Status: Done**` | Finalize not done | Phase 8 (`/e8`) |
| `ticket.md` carries `**Status: Done**` | Finalized | Nothing — report already-complete and exit |
```
**Replace:**
```
| Tests pass; `feedback/review_vN.md` **not** footed (and no Quick-path `## Post-Build Review` block on the footed spec) | Review not done | Phase 6 (`/e6`) — **terminal** for `/e-all` |
| Review done (`feedback/review_vN.md` footed; PR opened when `pr_provider == github`) | `/e-all` is complete — Polish (`/e7`) and Finalize (`/e8`) are **operator-driven** | Nothing — `/e-all` exits at the end of Review; direct the user to `/e7-resolve-feedback {slug}` (iterative) then `/e8-finalize-story {slug}` |
```
**Verification:**
- `grep -nF 'Phase 6 (`/e6`) — **terminal** for `/e-all`' host/templates/claude/commands/e-all.md` returns one match.
- `grep -nF '/e-all` exits at the end of Review' host/templates/claude/commands/e-all.md` returns one match.
- `grep -cnF "Phase 7 (\`/e7\`)" host/templates/claude/commands/e-all.md` returns 0 (the only `Phase 7 (`/e7`)` literal was the derivation-table row this step deletes; the Phase-7 *dispatch* section is headed `**Phase 7 — `/e7-resolve-feedback`.**`, which does not contain that parenthesized substring, and is removed separately in Step 15).
- `grep -cnF 'Phase 8 (`/e8`)' host/templates/claude/commands/e-all.md` returns 0 (the derivation-table Phase-8 row this step deletes was the only occurrence).

---

### Step 15 — e-all.md: drop the Phase-7 / Phase-8 dispatch sections (proposal row 3)

**Operation:** EDIT
**File:** `host/templates/claude/commands/e-all.md`
**Locate:**
```
**Phase 7 — `/e7-resolve-feedback`.** Run `/e7`'s **inline** steps in the phase agent: apply each comment from `feedback/review_vN.md`, log dispositions in `feedback/addressed_feedback.md`, perform any flagged ARCHITECTURE / CODING_STANDARDS / TESTING_STANDARDS updates, and route generalizable root causes to `.shamt-core/proposals/`. The `/e7` polish dialog is a **pause**.

**Phase 8 — `/e8-finalize-story`.** Self-contained — dispatch one `Agent` to run `/e8-finalize-story {slug}`. **Before this (irreversible) commit + tracker-close**, the driver re-confirms `/e8`'s **own three guards** are evaluated, not bypassed: prior phases complete; scoped clean-tree commit; **explicit user confirmation**. `/e8`'s built-in explicit-confirm guard means the irreversible step is **always user-gated** — the driver surfaces that confirm via `AskUserQuestion` (a Step-3 pause) rather than performing it unattended. This is **softer** than `/f-all`'s autonomous squash-merge: the terminal step here is never autonomous.
```
**Replace:**
```
**`/e-all` stops here — Polish and Finalize are operator-driven.** `/e-all` terminates at the end of Phase 6 (Review). Because Polish (`/e7-resolve-feedback`) is now an **iterative** human-in-the-loop PR cycle (each run pulls the latest PR comments and pushes fix commits) and Finalize (`/e8-finalize-story`) merges the PR, neither is auto-run by the driver — the operator invokes `/e7-resolve-feedback {slug}` (N times, as comments arrive) and then `/e8-finalize-story {slug}` by hand. Both remain independently runnable per-phase commands.
```
**Verification:**
- `grep -cnF '**Phase 8 — `/e8-finalize-story`.**' host/templates/claude/commands/e-all.md` returns 0.
- `grep -nF '`/e-all` stops here — Polish and Finalize are operator-driven' host/templates/claude/commands/e-all.md` returns one match.

---

### Step 16 — e-all.md: update the exit message + Exit criteria for the Review-terminal chain (proposal row 3)

**Operation:** EDIT
**File:** `host/templates/claude/commands/e-all.md`
**Locate:**
```
## Step 4 — Exit

When `/e8` reports the story committed + tracker-closed, state the exit clearly:

```text
/e-all complete for {slug}. Phases run: {list, e.g. e2 → e3 → e4 → e5 → e6 → e7 → e8}.
The story is committed and its work item is marked done.
```

If the run **paused**, the pause is not an exit — it is one round-trip through `AskUserQuestion`; the driver resumes automatically after the answer. If the run **halted**, report the halting phase's verbatim message and the per-phase command to resume from; do not present the run as complete.

## Exit criteria

- The story walked from its derived start phase through `/e8-finalize-story` (committed + tracker-closed), **or** the run paused on an interactive gate / structured open question (resumed in-place) / halted on a non-clean outcome with the verbatim report surfaced.
```
**Replace:**
```
## Step 4 — Exit

When `/e6` reports the validated review (and, when `pr_provider == github`, the opened PR), state the exit clearly:

```text
/e-all complete for {slug}. Phases run: {list, e.g. e2 → e3 → e4 → e5 → e6}.
The review is validated{, and the PR is open at <url> when pr_provider == github}.
Next (operator-driven): /e7-resolve-feedback {slug} (iterative — re-run as PR comments arrive), then /e8-finalize-story {slug}.
```

`/e-all` ends at the end of Review. Polish (`/e7`, iterative) and Finalize (`/e8`) are **operator-driven** — the driver does not auto-run them. If the run **paused**, the pause is not an exit — it is one round-trip through `AskUserQuestion`; the driver resumes automatically after the answer. If the run **halted**, report the halting phase's verbatim message and the per-phase command to resume from; do not present the run as complete.

## Exit criteria

- The story walked from its derived start phase through `/e6-review-changes` (review validated; PR opened when `pr_provider == github`), **or** the run paused on an interactive gate / structured open question (resumed in-place) / halted on a non-clean outcome with the verbatim report surfaced. Polish (`/e7`) and Finalize (`/e8`) are operator-driven and not part of the `/e-all` chain.
```
**Verification:**
- `grep -nF 'When `/e6` reports the validated review' host/templates/claude/commands/e-all.md` returns one match.
- `grep -nF 'through `/e6-review-changes` (review validated; PR opened when `pr_provider == github`)' host/templates/claude/commands/e-all.md` returns one match.

---

### Step 16b — e-all.md: drop the stale terminal-`/e8`-guards Exit-criteria bullet (proposal row 3)

**Operation:** EDIT
**File:** `host/templates/claude/commands/e-all.md`
**Locate:**
```
- Exactly one nesting level throughout (driver → phase agent; driver → inner persona); no sub-agent invoked an `/eX` command that would auto-spawn a second-level sub-agent.
- The terminal `/e8` commit + tracker-close ran behind `/e8`'s own three guards (prior phases complete; scoped clean tree; explicit user confirmation surfaced via `AskUserQuestion`), never bypassed.
```
**Replace:**
```
- Exactly one nesting level throughout (driver → phase agent; driver → inner persona); no sub-agent invoked an `/eX` command that would auto-spawn a second-level sub-agent.
```
**Verification:**
- `grep -cnF 'The terminal `/e8` commit + tracker-close ran behind' host/templates/claude/commands/e-all.md` returns 0 (the chain no longer ends at `/e8`; this guarantee is now stale — Finalize is operator-driven).
- `grep -cnF 'no sub-agent invoked an `/eX` command that would auto-spawn a second-level sub-agent.' host/templates/claude/commands/e-all.md` returns 1 (the nesting-level bullet is preserved — still valid for the Review-terminal chain).

---

### Step 17 — e-all.md: update the "Terminal `/e8` is user-gated" Note for the Review-terminal chain (proposal row 3)

**Operation:** EDIT
**File:** `host/templates/claude/commands/e-all.md`
**Locate:**
```
- **Terminal `/e8` is user-gated.** `/e-all` ends at `/e8-finalize-story`, whose own explicit-confirm guard means the irreversible commit + tracker-close is always user-gated — surfaced via `AskUserQuestion`, with `/e8`'s other two guards (prior phases complete; scoped clean tree) re-confirmed. Strictly safer than `/f-all`'s autonomous squash-merge.
```
**Replace:**
```
- **Terminal at Review — Polish + Finalize are operator-driven.** `/e-all` ends at `/e6-review-changes` (Review), opening the PR when `pr_provider == github`. It does **not** auto-run Polish (`/e7`) or Finalize (`/e8`), because Polish is now an **iterative** human-in-the-loop PR cycle (re-run as comments arrive) and Finalize merges the PR — both operator-driven, invoked by hand. The PR open at the end of Review is itself confirm-gated (a Step-3 pause). This makes `/e-all` strictly safer than `/f-all`'s autonomous squash-merge: it never autonomously merges or closes anything.
```
**Verification:**
- `grep -nF '**Terminal at Review — Polish + Finalize are operator-driven.**' host/templates/claude/commands/e-all.md` returns one match.
- `grep -cnF '**Terminal `/e8` is user-gated.**' host/templates/claude/commands/e-all.md` returns 0.

---

### Step 18 — e8-finalize-story.md: add the confirm-gated PR merge step when `pr_provider == github` (proposal row 4)

**Operation:** EDIT
**File:** `host/templates/claude/commands/e8-finalize-story.md`
**Locate:**
```
### Step 4 — Mark the work item done (active tracker profile)

Read `work_item_tracker` from `.shamt-core/shamt-config.json` (or the `--tracker=` override). Then, per profile:
```
**Replace:**
```
### Step 3b — Merge the PR when `pr_provider == github`

Read `pr_provider` from `.shamt-core/shamt-config.json`. This step is **independent of** the work-item close (Step 4, `work_item_tracker`-routed) — a `pr_provider: github` + `work_item_tracker: ado` project merges the GitHub PR here and still closes its ADO work item via `az boards` in Step 4.

- **`pr_provider == github`** — the **only** `pr_provider == github`-gated addition:
  1. **Resolve the PR.** Read the PR number from `stories/{slug}/feedback/pr.md` (written by `/e6-review-changes`). If absent, halt and direct the user to open the PR first via `/e6-review-changes {slug}`.
  2. **Mergeable guard.** Run the github profile's mergeability check (`reference/trackers/github.md` `## PR merge`). If the PR is **not** mergeable (unresolved reviews / failing checks / conflicts), **halt** and report — do not merge.
  3. **Merge** under the **existing Step-3 explicit-confirm guard** (already obtained for the commit): `gh pr merge {pr} --squash --delete-branch`. Outward, irreversible — never run without the Step-3 confirmation.
- **`pr_provider != github`** (`ado` / `none` / unset) — **no-op.** No PR merge; today's commit-on-branch behavior is unchanged.

Sequence when `pr_provider == github`: mergeable-guard → confirm-gated PR merge (this step) → existing `work_item_tracker`-routed close (Step 4, unchanged) → write `**Status: Done**` (Step 5).

### Step 4 — Mark the work item done (active tracker profile)

Read `work_item_tracker` from `.shamt-core/shamt-config.json` (or the `--tracker=` override). This is **independent of `pr_provider`** — do not gate it on `pr_provider` or hardcode a PR-merge close here. Then, per profile:
```
**Verification:**
- `grep -nF '### Step 3b — Merge the PR when `pr_provider == github`' host/templates/claude/commands/e8-finalize-story.md` returns one match.
- `grep -nF 'gh pr merge {pr} --squash --delete-branch' host/templates/claude/commands/e8-finalize-story.md` returns one match.
- `grep -nF 'This is **independent of** the work-item close' host/templates/claude/commands/e8-finalize-story.md` returns one match.
- `grep -nF 'independent of `pr_provider`** — do not gate it on `pr_provider`' host/templates/claude/commands/e8-finalize-story.md` returns one match.

---

### Step 19 — e8-finalize-story.md: drop the "PR merge out of scope" Note line (proposal row 4)

**Operation:** EDIT
**File:** `host/templates/claude/commands/e8-finalize-story.md`
**Locate:**
```
- **No squash-merge.** Unlike `/f6-archive-proposal`, the story is not on a proposal branch; finalize commits the story's work on its feature branch and stops. PR creation / merge is the `pr_provider`'s concern, out of scope here.
```
**Replace:**
```
- **PR merge is `pr_provider`-gated.** When `pr_provider == github`, Finalize merges the story's PR (`gh pr merge --squash --delete-branch`, behind the Step-3 confirm + a mergeable-guard — Step 3b); this is the **only** `pr_provider == github`-gated addition. The **work-item close (Step 4) stays `work_item_tracker`-routed** (ado / github / local), independent of `pr_provider`. When `pr_provider != github`, finalize commits the story's work on its feature branch and stops — no PR merge.
```
**Verification:**
- `grep -nF '**PR merge is `pr_provider`-gated.**' host/templates/claude/commands/e8-finalize-story.md` returns one match.
- `grep -cnF '**No squash-merge.**' host/templates/claude/commands/e8-finalize-story.md` returns 0.

---

### Step 20 — e6 SKILL: update `description:` + `## Exit criteria` (proposal row 5)

**Operation:** EDIT
**File:** `host/templates/claude/skills/e6-review-changes/SKILL.md`
**Locate:**
```
  Impact Assessment. Formal mode (--branch=<name> or --pr=<id>): hands off to
  the review-executor Opus persona, which produces code_reviews/<branch>/
  overview.md + review_vN.md. Local artifact only — never posts back to
  external trackers. Invoke when the user wants to review the changes, run
  the code review, do a formal PR review, or review a branch.
```
**Replace:**
```
  Impact Assessment, and — when pr_provider == github — pushes the story branch
  and opens the PR via gh pr create (confirm-gated), recording the PR number in
  the story folder. Formal mode (--branch=<name> or --pr=<id>): hands off to
  the review-executor Opus persona, which produces code_reviews/<branch>/
  overview.md + review_vN.md. The review artifact is local only — never posts
  review content back to external trackers. Invoke when the user wants to review
  the changes, run the code review, do a formal PR review, or review a branch.
```
**Second Locate (same file):**
```
- **Story mode:** validated `stories/{slug}/feedback/review_vN.md` (or `## Post-Build Review` block in the spec on a Quick-path no-issue review); `## Documentation Impact` populated.
```
**Second Replace:**
```
- **Story mode:** validated `stories/{slug}/feedback/review_vN.md` (or `## Post-Build Review` block in the spec on a Quick-path no-issue review); `## Documentation Impact` populated; when `pr_provider == github`, the story branch pushed and the PR opened (confirm-gated) with the PR number recorded at `stories/{slug}/feedback/pr.md`.
```
**Verification:**
- `grep -nF 'opens the PR via gh pr create (confirm-gated)' host/templates/claude/skills/e6-review-changes/SKILL.md` returns one match.
- `grep -nF 'PR number recorded at `stories/{slug}/feedback/pr.md`' host/templates/claude/skills/e6-review-changes/SKILL.md` returns one match.
- `grep -cnF '## Protocol' host/templates/claude/skills/e6-review-changes/SKILL.md` returns 1 (Protocol section untouched — still the verbatim pointer).

---

### Step 21 — e7 SKILL: update `description:` + `## Exit criteria` (proposal row 6)

**Operation:** EDIT
**File:** `host/templates/claude/skills/e7-resolve-feedback/SKILL.md`
**Locate:**
```
  Run Phase 7 (Polish) of the Shamt Engineer flow. Apply each comment from the
  latest review_vN.md, log dispositions in addressed_feedback.md, perform the
```
**Replace:**
```
  Run Phase 7 (Polish) of the Shamt Engineer flow. Apply each comment from a
  union of feedback sources rebuilt every run — the latest local review_vN.md
  plus, when a PR is recorded and pr_provider == github, the latest PR comments
  (pull-only; deduped by comment-ID) — log dispositions in addressed_feedback.md,
  push fix commits to the PR branch, perform the
```
**Second Locate (same file):**
```
`addressed_feedback.md` fully dispositioned; `Required` doc updates applied + re-validated; TODO gate passes; generalizable root causes filed under `.shamt-core/proposals/`; user has signalled complete. No `Pending` rows remain.
```
**Second Replace:**
```
`addressed_feedback.md` fully dispositioned (union of local `review_vN.md` findings + — when `pr_provider == github` and a PR is recorded — the latest PR comments, deduped by comment-ID); fix commits pushed to the PR branch (pull-only — no thread reply / resolve); `Required` doc updates applied + re-validated; TODO gate passes; generalizable root causes filed under `.shamt-core/proposals/`; user has signalled complete. No `Pending` rows remain. Re-runnable N times as new PR comments arrive.
```
**Verification:**
- `grep -nF 'union of feedback sources rebuilt every run' host/templates/claude/skills/e7-resolve-feedback/SKILL.md` returns one match.
- `grep -nF 'Re-runnable N times as new PR comments arrive.' host/templates/claude/skills/e7-resolve-feedback/SKILL.md` returns one match.
- `grep -cnF '## Protocol' host/templates/claude/skills/e7-resolve-feedback/SKILL.md` returns 1 (Protocol untouched).

---

### Step 22 — e-all SKILL: update `description:` + `## Exit criteria` (chain ends at `/e6`) (proposal row 7)

**Operation:** EDIT
**File:** `host/templates/claude/skills/e-all/SKILL.md`
**Locate:**
```
  Driver that walks a single story through every remaining Engineer-flow phase
  end-to-end — /e1-start-story → /e2-define-spec → (optional /e3-plan-implementation
  + /e3b-write-testing-plan on the Standard path) → /e4-execute-plan →
  /e5-execute-tests → /e6-review-changes → /e7-resolve-feedback →
  /e8-finalize-story — by dispatching one independent Agent sub-agent per phase
```
**Replace:**
```
  Driver that walks a single story through every remaining Engineer-flow phase
  up to and including Review — /e1-start-story → /e2-define-spec → (optional
  /e3-plan-implementation + /e3b-write-testing-plan on the Standard path) →
  /e4-execute-plan → /e5-execute-tests → /e6-review-changes (opening the PR when
  pr_provider == github) — by dispatching one independent Agent sub-agent per phase
```
**Second Locate (same file):**
```
  cannot resolve (test failure, ambiguity, inconsistent state) with the report
  surfaced verbatim. A stateless, disk-derived dispatcher of the canonical
```
**Second Replace:**
```
  cannot resolve (test failure, ambiguity, inconsistent state) with the report
  surfaced verbatim. Polish (/e7, iterative) and Finalize (/e8) are operator-driven
  — not auto-run by /e-all. A stateless, disk-derived dispatcher of the canonical
```
**Third Locate (same file):**
```
The story walked from its derived start phase through `/e8-finalize-story` (committed + tracker-closed), **or** the run paused on an interactive gate / structured open question (resumed in-place) / halted on a non-clean outcome with the verbatim report surfaced. Every phase ran as an independent `Agent` in the shared working tree (no worktree isolation); exactly one nesting level throughout; the terminal `/e8` commit + tracker-close ran behind `/e8`'s own three guards (never bypassed). Child-facing — runs wherever the Engineer flow runs, with no master-only guard.
```
**Third Replace:**
```
The story walked from its derived start phase through `/e6-review-changes` (review validated; PR opened when `pr_provider == github`), **or** the run paused on an interactive gate / structured open question (resumed in-place) / halted on a non-clean outcome with the verbatim report surfaced. Every phase ran as an independent `Agent` in the shared working tree (no worktree isolation); exactly one nesting level throughout. Polish (`/e7`, iterative) and Finalize (`/e8`) are operator-driven — not part of the `/e-all` chain. Child-facing — runs wherever the Engineer flow runs, with no master-only guard.
```
**Verification:**
- `grep -nF 'up to and including Review' host/templates/claude/skills/e-all/SKILL.md` returns one match.
- `grep -nF 'through `/e6-review-changes` (review validated; PR opened when `pr_provider == github`)' host/templates/claude/skills/e-all/SKILL.md` returns one match.
- `grep -cnF '## Protocol' host/templates/claude/skills/e-all/SKILL.md` returns 1 (Protocol untouched).

---

### Step 23 — e8 SKILL: mirror the PR-merge Finalize in `description:` + `## Exit criteria` (proposal row 8)

**Operation:** EDIT
**File:** `host/templates/claude/skills/e8-finalize-story/SKILL.md`
**Locate:**
```
  Run Phase 8 (Finalize) of the Shamt Engineer flow — the terminal step. Commit
  the story's work as a scoped unit and mark the originating work item done via
  the active tracker profile (ADO state / GitHub close / local Status flip),
  behind three guards: prior phases complete, scoped clean-tree commit, and
  explicit user confirmation. Writes the local Status: Done marker the status
  line reads. Invoke when the user wants to finalize a story, close it out,
```
**Replace:**
```
  Run Phase 8 (Finalize) of the Shamt Engineer flow — the terminal step. Commit
  the story's work as a scoped unit and mark the originating work item done via
  the active tracker profile (ADO state / GitHub close / local Status flip),
  behind three guards: prior phases complete, scoped clean-tree commit, and
  explicit user confirmation. When pr_provider == github, also merges the story's
  PR (gh pr merge --squash --delete-branch, behind the same confirm + a
  mergeable-guard) — independent of the work_item_tracker-routed close. Writes the
  local Status: Done marker the status line reads. Invoke when the user wants to
  finalize a story, close it out,
```
**Second Locate (same file):**
```
The story's scoped work is committed (after the three guards held); the work item is marked done via the active tracker (or local-only); `ticket.md` carries `**Status: Done**`. Finalize does **not** move the story folder — epic archiving is `/pe4-finalize`'s job.
```
**Second Replace:**
```
The story's scoped work is committed (after the three guards held); the work item is marked done via the active tracker (or local-only), independent of `pr_provider`; `ticket.md` carries `**Status: Done**`. When `pr_provider == github`, the story's PR is merged (`gh pr merge --squash --delete-branch`, behind the Step-3 confirm + a mergeable-guard). Finalize does **not** move the story folder — epic archiving is `/pe4-finalize`'s job.
```
**Verification:**
- `grep -nF 'also merges the story' host/templates/claude/skills/e8-finalize-story/SKILL.md` returns one match.
- `grep -nF 'independent of the work_item_tracker-routed close' host/templates/claude/skills/e8-finalize-story/SKILL.md` returns one match.
- `grep -cnF '## Protocol' host/templates/claude/skills/e8-finalize-story/SKILL.md` returns 1 (Protocol untouched).

---

### Step 24 — SHAMT_RULES.template.md: update Pattern 4 with the PR loop (proposal row 13)

**Operation:** EDIT
**File:** `templates/SHAMT_RULES.template.md`
**Locate:**
```
**Story mode:** Review code just built for an active story. Output `stories/{slug}/feedback/review_v1.md` only when findings, risk, or user request require it; re-reviews use `review_v2.md`, etc. No `overview.md`. Before findings, perform Plan Alignment: resolve the active plan, read it alongside the diff, and check Step Coverage, Change Fidelity, Scope Discipline, Verification Passage, and Zero Builder Design Decisions. Write `## Plan Alignment` at the top of the review. If no plan exists (Quick path), record N/A. Story-mode validation uses 7 dimensions (the 7th is Plan Alignment).
```
**Replace:**
```
**Story mode:** Review code just built for an active story. Output `stories/{slug}/feedback/review_v1.md` only when findings, risk, or user request require it; re-reviews use `review_v2.md`, etc. No `overview.md`. Before findings, perform Plan Alignment: resolve the active plan, read it alongside the diff, and check Step Coverage, Change Fidelity, Scope Discipline, Verification Passage, and Zero Builder Design Decisions. Write `## Plan Alignment` at the top of the review. If no plan exists (Quick path), record N/A. Story-mode validation uses 7 dimensions (the 7th is Plan Alignment). **When `pr_provider == github`**, story-mode Review also opens the PR after the review validates (push branch + `gh pr create`, confirm-gated, PR number recorded in the story folder); Polish (`/e7`) is then an **iterative** loop that re-pulls the latest PR comments each run and pushes fix commits (pull-only — no thread postback); Finalize (`/e8`) **merges** the PR (`gh pr merge --squash`, mergeable-guarded). `/e-all` stops at the end of Review. When `pr_provider != github`, all three keep today's local-only behavior.
```
**Verification:**
- `grep -nF 'When `pr_provider == github`**, story-mode Review also opens the PR' templates/SHAMT_RULES.template.md` returns one match.
- The added sentence keeps Pattern 4 minimal (one trailing sentence on the existing Story-mode paragraph; no new heading) — D12 size budget respected.

---

### Step 25 — SHAMT_RULES.template.md: update the Finalize-phase narrative for `/e8`'s PR merge (proposal row 13)

**Operation:** EDIT
**File:** `templates/SHAMT_RULES.template.md`
**Locate:**
```
- **`/e8-finalize-story {slug}`** — the Engineer flow's terminal phase: commits the story's work as a scoped unit (clean-tree guard), confirms prior phases complete (Test PASSes — required; Review + feedback resolved), marks the work item done via the active tracker, and writes `**Status: Done**` into `ticket.md` — the profile-independent signal the status line reads.
```
**Replace:**
```
- **`/e8-finalize-story {slug}`** — the Engineer flow's terminal phase: commits the story's work as a scoped unit (clean-tree guard), confirms prior phases complete (Test PASSes — required; Review + feedback resolved), marks the work item done via the active tracker, and writes `**Status: Done**` into `ticket.md` — the profile-independent signal the status line reads. When `pr_provider == github` it also merges the story's PR (`gh pr merge --squash`, mergeable-guarded, behind the same confirm) — independent of the `work_item_tracker`-routed close.
```
**Verification:**
- `grep -nF 'When `pr_provider == github` it also merges the story' templates/SHAMT_RULES.template.md` returns one match.

---

### Step 26 — README.md: update the `/e6` / `/e7` Engineer-flow table rows (proposal row 14)

**Operation:** EDIT
**File:** `README.md`
**Locate:**
```
| `/e6-review-changes [{slug}\|--branch=<name>\|--pr=<id>]` | 6. Review | shipped |
| `/e7-resolve-feedback {slug}` | 7. Polish | shipped |
```
**Replace:**
```
| `/e6-review-changes [{slug}\|--branch=<name>\|--pr=<id>]` | 6. Review — story mode also opens the PR when `pr_provider == github` (push branch + `gh pr create`, confirm-gated) | shipped |
| `/e7-resolve-feedback {slug}` | 7. Polish — iterative: re-pulls the latest PR comments each run + pushes fix commits when `pr_provider == github` (pull-only) | shipped |
```
**Verification:**
- `grep -nF 'story mode also opens the PR when `pr_provider == github`' README.md` returns one match.
- `grep -nF 're-pulls the latest PR comments each run' README.md` returns one match.

---

### Step 27 — README.md: update the `/e-all` meta-driver row (chain ends at Review) (proposal row 14)

**Operation:** EDIT
**File:** `README.md`
**Locate:**
```
| `/e-all {slug}` | Meta-driver (spans Phases 1–8, not a numbered phase) — walk a story through every remaining phase end-to-end (`/e1` → `/e2` → optional `/e3`+`/e3b` on Standard → `/e4` → `/e5` → `/e6` → `/e7` → `/e8`) by dispatching one independent agent per phase, deriving the start phase from on-disk artifacts, pausing on each interactive gate (Gate 2a design dialog, Gate 2b / Gate 3 approvals, `/e7` polish dialog, `/e8` finalize confirm) via `AskUserQuestion`, and halting on any failure it cannot resolve. **Child-facing** — runs wherever the Engineer flow runs (every child, and master self-host); no master-only guard | shipped |
```
**Replace:**
```
| `/e-all {slug}` | Meta-driver (spans Phases 1–6, not a numbered phase) — walk a story through every remaining phase up to and including Review (`/e1` → `/e2` → optional `/e3`+`/e3b` on Standard → `/e4` → `/e5` → `/e6`, opening the PR when `pr_provider == github`) by dispatching one independent agent per phase, deriving the start phase from on-disk artifacts, pausing on each interactive gate (Gate 2a design dialog, Gate 2b / Gate 3 approvals) via `AskUserQuestion`, and halting on any failure it cannot resolve. **Stops at the end of Review** — Polish (`/e7`, iterative) and Finalize (`/e8`) are operator-driven, not auto-run. **Child-facing** — runs wherever the Engineer flow runs (every child, and master self-host); no master-only guard | shipped |
```
**Verification:**
- `grep -nF 'Meta-driver (spans Phases 1–6, not a numbered phase)' README.md` returns one match.
- `grep -nF '**Stops at the end of Review** — Polish (`/e7`, iterative) and Finalize (`/e8`) are operator-driven' README.md` returns one match.

---

### Step 28 — README.md: update the `/e-all` Principle-1 note (chain ends at Review) (proposal row 14)

**Operation:** EDIT
**File:** `README.md`
**Locate:**
```
> **`/e-all` and Principle 1.** `/e-all` is an **optional** one-shot driver over the numbered Engineer-flow phases — a convenience layer, not a replacement. The per-phase commands remain the supported manual path and each stays independently runnable. It honors Principle 1's "no single mega-orchestrator / no state file" because it is a **stateless, disk-derived dispatcher**: it holds no state of its own (it derives its start phase from on-disk artifacts and advances on each dispatched phase agent's report), and it dispatches the canonical phase commands rather than reimplementing them. Unlike master-only `/f-all`, it is **child-facing** (runs wherever the Engineer flow runs) and **gate-heavy** (it pauses on the flow's many interactive gates). The authoritative reconciliation lives beside `/f-all`'s in `CLAUDE.md` §"How changes land".
```
**Replace:**
```
> **`/e-all` and Principle 1.** `/e-all` is an **optional** one-shot driver over the Engineer-flow phases through Review (`/e1` … `/e6`) — a convenience layer, not a replacement. It **stops at the end of Review** (opening the PR when `pr_provider == github`); Polish (`/e7`, an iterative human-in-the-loop PR-comment loop) and Finalize (`/e8`, which merges the PR) are operator-driven, invoked by hand. The per-phase commands remain the supported manual path and each stays independently runnable. It honors Principle 1's "no single mega-orchestrator / no state file" because it is a **stateless, disk-derived dispatcher**: it holds no state of its own (it derives its start phase from on-disk artifacts and advances on each dispatched phase agent's report), and it dispatches the canonical phase commands rather than reimplementing them. Unlike master-only `/f-all`, it is **child-facing** (runs wherever the Engineer flow runs) and **gate-heavy** (it pauses on the flow's many interactive gates). The authoritative reconciliation lives beside `/f-all`'s in `CLAUDE.md` §"How changes land".
```
**Verification:**
- `grep -nF 'over the Engineer-flow phases through Review (`/e1` … `/e6`)' README.md` returns one match.
- `grep -nF 'Finalize (`/e8`, which merges the PR) are operator-driven' README.md` returns one match.

---

### Step 29 — README.md: update the `pr_provider` config-key description (proposal row 14)

**Operation:** EDIT
**File:** `README.md`
**Locate:**
```
| `pr_provider` | `"ado"` / `"github"` / `"none"` | Which PR provider `/e6-review-changes` formal mode uses |
```
**Replace:**
```
| `pr_provider` | `"ado"` / `"github"` / `"none"` | Which PR provider the PR-aware Engineer phases use. `/e6-review-changes` formal mode uses it for `--pr` fetch; when `pr_provider == github`, story-mode `/e6` opens the PR, `/e7-resolve-feedback` pulls PR comments + pushes fixes (iterative), and `/e8-finalize-story` merges the PR. Independent of `work_item_tracker` (which routes the work-item close). |
```
**Verification:**
- `grep -nF 'Which PR provider the PR-aware Engineer phases use' README.md` returns one match.
- `grep -nF 'Independent of `work_item_tracker` (which routes the work-item close).' README.md` returns one match.

---

## Verification (post-execution, whole plan)

<!-- Whole-plan / cross-phase invariants — run by the architect at /f3-implement-update post-build (Step 3), never by the builder. -->

- [ ] Every row in the Proposed Changes table (14 rows) has at least one corresponding step:
  - Row 1 (e6 command) → Steps 6, 7
  - Row 2 (e7 command) → Steps 8, 9, 10, 11
  - Row 3 (e-all command) → Steps 12, 13, 14, 15, 16, 16b, 17
  - Row 4 (e8 command) → Steps 18, 19
  - Row 5 (e6 SKILL) → Step 20
  - Row 6 (e7 SKILL) → Step 21
  - Row 7 (e-all SKILL) → Step 22
  - Row 8 (e8 SKILL) → Step 23
  - Row 9 (github.md) → Step 1
  - Row 10 (_contract.md) → Steps 2, 3
  - Row 11 (ado.md) → Step 4
  - Row 12 (local.md) → Step 5
  - Row 13 (SHAMT_RULES) → Steps 24, 25
  - Row 14 (README) → Steps 26, 27, 28, 29
- [ ] No edits landed in generated `.claude/` paths: `git diff --name-only | grep -c '^\.claude/'` returns 0.
- [ ] **Contract conformance — every profile declares all three new required sections.** For each of `github.md`, `ado.md`, `local.md`: `grep -c -E '^## PR (create|comment fetch|merge)$' reference/trackers/<file>` returns 3. (The `_contract.md` Required-sections table requires `## PR create` / `## PR comment fetch` / `## PR merge` of every profile — Steps 2/3 add the requirement, Steps 1/4/5 satisfy it for the three day-one profiles.)
- [ ] **Both contract tables list the three new sections:** `grep -c -E '`## PR (create|comment fetch|merge)`' reference/trackers/_contract.md` returns ≥ 6 (3 in Required sections + 3 in Where-exercised), and the Where-exercised table now has rows for `/e6` (PR create), `/e7` (PR comment fetch), `/e8` (PR merge).
- [ ] **SKILL Protocol sections are untouched** (D2 Command→Skill Protocol pointer rule): for each of the four SKILLs (e6/e7/e-all/e8), `git diff -- host/templates/claude/skills/<name>/SKILL.md` shows no change inside the `## Protocol` section (only `description:` + `## Exit criteria` changed). Each SKILL still contains its verbatim `Follow the canonical `/eX … command body verbatim` pointer.
- [ ] **`/e8` work-item close is NOT gated on `pr_provider`** and does NOT hardcode `gh issue close` as the universal close: `grep -nF 'independent of `pr_provider`** — do not gate it on `pr_provider`' host/templates/claude/commands/e8-finalize-story.md` returns one match; Step-4's existing `work_item_tracker`-routed close block (ado → `az boards`, github → `gh issue close`, local/freeform → none) is unchanged.
- [ ] **Cross-doc consistency — where the `/e-all` chain ends.** All four surfaces agree the chain ends at Review (`/e6`): the e-all command chain table (Step 12), the e-all command exit/derivation (Steps 14, 16, 16b, 17), the e-all SKILL (Step 22), and the README table + Principle-1 note (Steps 27, 28). `grep -rnF 'e7' host/templates/claude/commands/e-all.md` returns only operator-driven / Polish references (no auto-run dispatch), and no surface still lists `/e7` or `/e8` as an auto-run `/e-all` phase.
- [ ] **Non-github path provably unchanged.** Each of the four command edits (`/e6` Step 6, `/e7` Steps 8-11, `/e8` Step 18, `/e-all` PR-open) explicitly states the `pr_provider != github` branch is a no-op / today's behavior; `grep -nF 'no-op' host/templates/claude/commands/e6-review-changes.md host/templates/claude/commands/e8-finalize-story.md` returns matches for both files.
- [ ] Mermaid / link / reference targets in edited files still resolve (the new github.md `## PR create` / `## PR comment fetch` / `## PR merge` section names are referenced by the e6/e7/e8 command bodies; confirm those `reference/trackers/github.md` `## …` citations name sections that now exist).
- [ ] D12 size budget: the SHAMT_RULES.template.md edits (Steps 24, 25) add only two sentences total to existing paragraphs — no new headings, no new tables. Re-confirm the rules file did not gain a section.

## Notes

- **Ordering is references-first, then commands, then skills, then rules + README.** Each command edit (Steps 6-19) cites a github.md PR section that Step 1 already created and a contract surface Steps 2-3 already declared, so the command bodies never forward-reference a not-yet-existing section. No step depends on another step's working-tree *content* beyond section/heading existence, which the whole-plan verification re-confirms.
- **PR-number artifact location (Phase-3 mechanical detail, per the proposal's Design decisions).** The plan fixes the PR-number record at `stories/{slug}/feedback/pr.md` (alongside `review_vN.md` and `addressed_feedback.md` in the existing `feedback/` folder) — a single, fresh-agent-resumable source read by `/e7` (fetch + dedup) and `/e8` (merge). This is the one detail the proposal explicitly deferred to Phase 3; it is not new scope.
- **`## PR comment posting` is preserved, not removed**, in github.md and ado.md — the new `## PR comment fetch` is a *distinct* pull-side section; the postback section stays declared (contract-required, future-use) with its text updated to note `/e7` is pull-only.
- **Pattern 4 no-postback stance preserved.** `/e7`'s only relaxation is read (pull comments) + push (fix commits); it never replies to / resolves / posts review content to PR threads. The plan's e7 edits (Steps 8-11) and SKILL edit (Step 21) all carry the "pull-only" qualifier; the rules-file Pattern 4 sentence (Step 24) does too.
- **`/e8` independence of `pr_provider` and `work_item_tracker` is load-bearing** (proposal Validation Considerations): Step 18 adds the PR merge as a separate Step 3b gated on `pr_provider == github`, and explicitly annotates Step 4's work-item close as `work_item_tracker`-routed and *not* gated on `pr_provider`. The whole-plan verification asserts the close is not re-routed.
- **Regen is Phase 5, not this plan.** None of these steps touches `.claude/`. After `/f3` lands these canonical edits, `/f4-regen-framework` propagates the four command + four skill edits into `.claude/`. The reference/rules/README files are not host-regenerated (they live outside `host/templates/claude/`) but feed the rendered child `CLAUDE.md` (SHAMT_RULES) and the shipped `.shamt-core/README.md` on import.
- **Builder note on the `/e7` / `/e8` references that legitimately remain in e-all.md.** Step 14 deletes the derivation-table Phase-7 and Phase-8 rows (the only `Phase 7 (`/e7`)` / `Phase 8 (`/e8`)` parenthesized literals), and Step 15 deletes the §"Phase 7 — `/e7-resolve-feedback`" + §"Phase 8 — `/e8-finalize-story`" *dispatch* sections. After those, the **only** remaining `/e7` / `/e8` mentions in e-all.md are the *operator-driven / Polish-and-Finalize-are-not-auto-run* pointers added by Steps 13/14/16/16b/17 — none of which reinstate an auto-run dispatch. The whole-plan cross-doc check confirms no surface still lists `/e7` / `/e8` as an auto-run `/e-all` phase.

---
Validated 2026-06-21 — 2 rounds, 1 adversarial sub-agent confirmed (/f-all Phase 3 plan inline-validation).
