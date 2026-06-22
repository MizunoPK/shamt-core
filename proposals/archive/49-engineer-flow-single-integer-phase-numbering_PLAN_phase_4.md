# Implementation Plan — Phase 4: SHAMT_RULES.template.md

**Proposal:** proposals/49-engineer-flow-single-integer-phase-numbering.md
**Plan index:** proposals/49-engineer-flow-single-integer-phase-numbering_PLAN.md
**Covers:** Proposed Changes row 31 (templates/SHAMT_RULES.template.md)
**Created:** 2026-06-21

## Steps

### Step 4.1 — "What is Shamt?" role-flows bullet (drop Quick/Standard phase counts)
**Operation:** EDIT
**File:** templates/SHAMT_RULES.template.md
**Locate:**
```
- **Two role flows** — an **Engineer flow** (Quick path 7 phases / Standard path 8 phases — testing is a **required** phase) and a **Product Owner flow** (Epic → Feature → Story decomposition).
```
**Replace:**
```
- **Two role flows** — an **Engineer flow** (a uniform 9-phase linear sequence, e1–e9; every phase is mandatory for story completion) and a **Product Owner flow** (Epic → Feature → Story decomposition).
```
**Verification:** `grep -c 'Quick path 7 phases' templates/SHAMT_RULES.template.md` returns 0; `grep -F 'a uniform 9-phase linear sequence, e1–e9' templates/SHAMT_RULES.template.md` returns 1.

### Step 4.2 — Remove the "path system inside the Engineer flow" bullet
**Operation:** EDIT
**File:** templates/SHAMT_RULES.template.md
**Locate:**
```
- **The story** as the handoff artifact between the two roles.
- **A path system inside the Engineer flow** — every story runs the **Quick path** (default, low-ceremony) unless a risk trigger escalates it to the **Standard path**.
```
**Replace:**
```
- **The story** as the handoff artifact between the two roles.
```
**Verification:** `grep -c 'path system inside the Engineer flow' templates/SHAMT_RULES.template.md` returns 0.

### Step 4.3 — Replace the "Engineer Flow — Path Selection" heading + intro line
**Operation:** EDIT
**File:** templates/SHAMT_RULES.template.md
**Locate:**
```
# Engineer Flow — Path Selection

Determine the path after Phase 1 (Intake).

**Quick path (default):** Use when all are true:

- expected implementation is ≤10 steps;
- one repo or deployable surface;
- no new service, database table, auth/tenant boundary, public API contract, or data migration;
- no unresolved design decision after targeted research;
- user did not explicitly request the Standard path.

**Standard path:** Use when any risk trigger applies:

- \>10 implementation steps;
- multiple deployment boundaries with ordering risk;
- new service, new significant module, or significant handler refactor;
- database table creation, destructive migration, or data backfill;
- auth, security, or tenant-isolation behavior;
- public API or event contract change;
- material architecture boundary crossing;
- significant design ambiguity remaining after targeted research;
- user explicitly requests the Standard path.

When uncertain, default to Standard.

### Quick path map

| Phase | Artifact | Gate |
|---|---|---|
| 1. Intake | `stories/{ID}-{slug}-{brief-description}/ticket.md` | User confirms slug + content |
| 2. Compact Spec | `stories/{slug}/spec.md` (Evidence, Code Shapes, Build Checklist, Verification inline) | Gate 2b: user approves spec/checklist |
| 3. Build | code changes | Verification checklist in spec |
| 4. Test | `stories/{slug}/agent_test_session.md` (+ inline automated checklist when present) | Phase 4 (Test) PASSes (agent-as-user; automated when present) |
| 5. Review | chat/spec summary; `feedback/review_v1.md` only on findings, risk, or user request | Review completed |
| 6. Polish | no-op unless feedback exists | TODO scan passes; feedback handled if present |
| 7. Finalize | scoped commit + work item marked done (`ticket.md` `**Status: Done**`) | `/e8-finalize-story`: prior phases complete, scoped clean-tree commit, explicit confirmation |

### Standard path map

| Phase | Artifact | Gate |
|---|---|---|
| 1. Intake | `stories/{ID}-{slug}-{brief-description}/ticket.md` | User confirms slug + content |
| 2. Spec | `stories/{slug}/spec.md` + `stories/{slug}/context.md` | Gate 2a design approval; Gate 2b validated-spec approval |
| 3. Plan | `stories/{slug}/implementation_plan.md` | Gate 3 approved |
| 4. Build | code changes | Verification checklist in plan |
| 5. Test | `stories/{slug}/agent_test_session.md` + `testing_plan.md` (when automated suites present) | Phase 5 (Test) PASSes |
| 6. Review | `stories/{slug}/feedback/review_v1.md` | Review artifact exists after Test |
| 7. Polish | `feedback/addressed_feedback.md` + commits | User signals complete |
| 8. Finalize | scoped commit + work item marked done (`ticket.md` `**Status: Done**`) | `/e8-finalize-story`: prior phases complete, scoped clean-tree commit, explicit confirmation |
```
**Replace:**
```
# Engineer Flow — Phase Map

The Engineer flow is a uniform, linear **nine-phase** sequence, e1–e9. Every phase is **mandatory for a story to be considered complete** — there is no Quick/Standard split, no skipped planning, no optional context. (Mandatory means required-for-completion, not driver-auto-run: `/e-all` drives e1 → e7 and stops at Review; Polish (e8) and Finalize (e9) are operator-initiated — see §Finalize phase.)

| Phase | Artifact | Gate |
|---|---|---|
| 1. Intake | `stories/{ID}-{slug}-{brief-description}/ticket.md` | User confirms slug + content |
| 2. Spec | `stories/{slug}/spec.md` + `stories/{slug}/context.md` | Gate 2a design approval; Gate 2b validated-spec approval |
| 3. Plan | `stories/{slug}/implementation_plan.md` | Gate 3 approved |
| 4. Test Plan | `stories/{slug}/user_test_plan.md` (always) + `testing_plan.md` (when `TESTING_STANDARDS.md` declares suites) | Each plan validated (Pattern 1) |
| 5. Build | code changes | Verification checklist in plan |
| 6. Test | `stories/{slug}/agent_test_session.md` (user-simulator executes `user_test_plan.md`) + `testing_plan.md` run (when suites present) | Phase 6 (Test) PASSes |
| 7. Review | `stories/{slug}/feedback/review_v1.md`; opens the PR when `pr_provider == github` | Review artifact exists after Test |
| 8. Polish | `feedback/addressed_feedback.md` + commits | User signals complete |
| 9. Finalize | scoped commit + work item marked done (`ticket.md` `**Status: Done**`) | `/e9-finalize-story`: prior phases complete, scoped clean-tree commit, explicit confirmation |
```
**Verification:** `grep -c '### Quick path map\|### Standard path map\|Engineer Flow — Path Selection' templates/SHAMT_RULES.template.md` returns 0; `grep -F '# Engineer Flow — Phase Map' templates/SHAMT_RULES.template.md` returns 1; `grep -F '| 4. Test Plan |' templates/SHAMT_RULES.template.md` returns 1; `grep -F '| 9. Finalize |' templates/SHAMT_RULES.template.md` returns 1.

### Step 4.4 — Retitle the Testing section to Phase 6 + renumber its body
**Operation:** EDIT
**File:** templates/SHAMT_RULES.template.md
**Locate:**
```
### Testing (Phase 5 — required)

**Phase 5 (Test)** is **required** on every story and **blocks until green**: the `user-simulator` persona
drives the project per `TESTING_STANDARDS.md` (source of truth; no `testing` flag), writing
`agent_test_session.md`, plus the **automated** `testing_plan.md` when that doc declares suites. A failure
routes to `/e7-resolve-feedback` with a **required root-cause section** (which of Spec/Plan/Build let it
through + the prevention). Full detail in [`reference/testing.md`](reference/testing.md).
```
**Replace:**
```
### Testing (Phase 6 — required)

**Phase 6 (Test)** is **required** on every story and **blocks until green**: the `user-simulator` persona
**executes the `user_test_plan.md` scenarios** authored in Phase 4 (driving the project per
`TESTING_STANDARDS.md` as conventions input), writing `agent_test_session.md`, plus the **automated**
`testing_plan.md` run by `test-executor` when `TESTING_STANDARDS.md` declares suites. A failure routes to
`/e8-resolve-feedback` with a **required root-cause section** (which of Spec/Plan/Build let it through + the
prevention). Full detail in [`reference/testing.md`](reference/testing.md).
```
**Verification:** `grep -c 'Testing (Phase 5 — required)' templates/SHAMT_RULES.template.md` returns 0; `grep -F '### Testing (Phase 6 — required)' templates/SHAMT_RULES.template.md` returns 1; `grep -F 'executes the `user_test_plan.md` scenarios' templates/SHAMT_RULES.template.md` returns 1; `grep -c '/e7-resolve-feedback' templates/SHAMT_RULES.template.md` (this site) trending down.

### Step 4.5 — Retitle the "Optional post-Build artifact" section to the mandatory Test Plan (Phase 4) section
**Operation:** EDIT
**File:** templates/SHAMT_RULES.template.md
**Locate:**
```
### Optional post-Build artifact

Manual-test-plan detail: see [`reference/testing.md`](reference/testing.md).
```
**Replace:**
```
### Test Plan (Phase 4 — required)

**Phase 4 (Test Plan)** is **required** on every story: it authors `user_test_plan.md` (agent-as-user
scenarios — always) and `testing_plan.md` (automated suites — when `TESTING_STANDARDS.md` declares them),
each validated under Pattern 1. The `user_test_plan.md` is the script the Phase-6 `user-simulator`
executes; it is not a human-only walkthrough. Full detail in [`reference/testing.md`](reference/testing.md).
```
**Verification:** `grep -c 'Optional post-Build artifact' templates/SHAMT_RULES.template.md` returns 0; `grep -F '### Test Plan (Phase 4 — required)' templates/SHAMT_RULES.template.md` returns 1. NOTE — anchor handling: the new GitHub-style anchor for this section is `#test-plan-phase-4--required` (see Phase notes). The single surviving inbound link to it is repointed in Phase 1b, Step 1.102 (validate-artifact.md dimension table); the former e5b-suggestion link is deleted, not repointed (Phase 1b, Step 1.37). Phase 4 does not edit those files.

### Step 4.6 — Collapse the Context-clear breakpoints bullets (remove Quick/Standard split)
**Operation:** EDIT
**File:** templates/SHAMT_RULES.template.md
**Locate:**
```
### Context-clear breakpoints

- **Standard path:** strong breakpoints after Gate 2b and after Gate 3.
- **Quick path:** strong breakpoint after Gate 2b.
- **Advisory** anywhere: before spec validation, after Gate 2b, before plan validation, after Build, after Review.
```
**Replace:**
```
### Context-clear breakpoints

- **Strong** breakpoints after Gate 2b and after Gate 3.
- **Advisory** anywhere: before spec validation, after Gate 2b, before plan validation, after Build, after Review.
```
**Verification:** `grep -c 'Standard path:\*\* strong breakpoints\|Quick path:\*\* strong breakpoint' templates/SHAMT_RULES.template.md` returns 0; `grep -F '**Strong** breakpoints after Gate 2b and after Gate 3.' templates/SHAMT_RULES.template.md` returns 1.

### Step 4.7 — Renumber the Finalize terminal command (`/e8` → `/e9`)
**Operation:** EDIT
**File:** templates/SHAMT_RULES.template.md
**Locate:**
```
- **`/e8-finalize-story {slug}`** — the Engineer flow's terminal phase: commits the story's work as a scoped unit (clean-tree guard), confirms prior phases complete (Test PASSes — required; Review + feedback resolved), marks the work item done via the active tracker, and writes `**Status: Done**` into `ticket.md` — the profile-independent signal the status line reads. When `pr_provider == github` it also merges the story's PR (`gh pr merge --squash`, mergeable-guarded, behind the same confirm) — independent of the `work_item_tracker`-routed close.
```
**Replace:**
```
- **`/e9-finalize-story {slug}`** — the Engineer flow's terminal phase: commits the story's work as a scoped unit (clean-tree guard), confirms prior phases complete (Test PASSes — required; Review + feedback resolved), marks the work item done via the active tracker, and writes `**Status: Done**` into `ticket.md` — the profile-independent signal the status line reads. When `pr_provider == github` it also merges the story's PR (`gh pr merge --squash`, mergeable-guarded, behind the same confirm) — independent of the `work_item_tracker`-routed close.
```
**Verification:** `grep -F '`/e9-finalize-story {slug}`' templates/SHAMT_RULES.template.md` returns 1; the `/e8-finalize-story {slug}` form is gone from this site.

### Step 4.8 — Renumber the standing Tech Stories finalize pointer (`/e8` → `/e9`)
**Operation:** EDIT
**File:** templates/SHAMT_RULES.template.md
**Locate:**
```
- **Entry + archive.** Entry is via `/ps0-draft [bugs|quick-wins]` (seeds a ticket stub under the chosen feature, hands to `/e1-start-story`, bypassing the `/pe1-define`→`/pf3-decompose` cascade); archive-on-finalize moves the folder into the feature's `archive/`. Mechanics live in the `/ps0-draft` + `/e8-finalize-story` command bodies.
```
**Replace:**
```
- **Entry + archive.** Entry is via `/ps0-draft [bugs|quick-wins]` (seeds a ticket stub under the chosen feature, hands to `/e1-start-story`, bypassing the `/pe1-define`→`/pf3-decompose` cascade); archive-on-finalize moves the folder into the feature's `archive/`. Mechanics live in the `/ps0-draft` + `/e9-finalize-story` command bodies.
```
**Verification:** `grep -F '`/ps0-draft` + `/e9-finalize-story` command bodies' templates/SHAMT_RULES.template.md` returns 1.

### Step 4.9 — Pattern 1 exit criteria: collapse Quick/Standard to one uniform exit
**Operation:** EDIT
**File:** templates/SHAMT_RULES.template.md
**Locate:**
```
**Exit criteria:**

- **Quick path:** one primary self-review before build and one post-build review against spec/diff. Add an adversarial sub-agent only when a risk trigger applies.
- **Standard path or risk-triggered validation:** primary clean round + 1 independent adversarial sub-agent confirmation.

**Risk triggers:** security / auth / tenant isolation / permissions; database schema, migrations, or backfills; new service or significant module creation; public API or event contracts; multi-repo or multi-deploy ordering; irreversible deletes or destructive edits; payment, billing, regulated, safety-critical, or other high-risk behavior.
```
**Replace:**
```
**Exit criteria:** every validation is uniform — a **primary clean round + 1 independent adversarial sub-agent confirmation**. There is no lower-rigor single-pass tier; the sub-agent always runs (no one-LOW allowance). The former Quick/Standard rigor selector is retired framework-wide.
```
**Verification:** `grep -c 'Quick path:\*\* one primary self-review\|Standard path or risk-triggered validation' templates/SHAMT_RULES.template.md` returns 0; `grep -F 'every validation is uniform' templates/SHAMT_RULES.template.md` returns 1.

### Step 4.10 — Pattern 3 Step-3 artifact-shape table: single uniform shape (drop Quick/Standard rows)
**Operation:** EDIT
**File:** templates/SHAMT_RULES.template.md
**Locate:**
```
**Step 3 — artifact shape per path:**

| Path | Required artifact shape |
|---|---|
| Standard | `spec.md` (from `templates/spec.template.md`) + `context.md` (from `templates/context.template.md`). `spec.md` is the approval contract; `context.md` is evidence/planning handoff. Approval-relevant persistence design and review-prevention requirements must appear in `spec.md`, not only `context.md`. Key Design Decision IDs appear in both. |
| Quick | `spec.md` only — populate Evidence, compact Review Prevention Evidence, Code Shapes, Review Prevention Checklist, Build Checklist, and Verification inline. Do not create `context.md` or `implementation_plan.md` unless the story escalates or a risk trigger applies. |
```
**Replace:**
```
**Step 3 — required artifact shape (every story).** Produce `spec.md` (from `templates/spec.template.md`) **and** `context.md` (from `templates/context.template.md`). `spec.md` is the approval contract; `context.md` is the evidence/planning handoff. Approval-relevant persistence design and review-prevention requirements must appear in `spec.md`, not only `context.md`. Key Design Decision IDs appear in both.
```
**Verification:** `grep -c '| Path | Required artifact shape |' templates/SHAMT_RULES.template.md` returns 0; `grep -F '**Step 3 — required artifact shape (every story).**' templates/SHAMT_RULES.template.md` returns 1.

### Step 4.11 — Pattern 3 Step-6 validation pair checks (drop the (Standard path) label + Quick-path parenthetical)
**Operation:** EDIT
**File:** templates/SHAMT_RULES.template.md
**Locate:**
```
**Step 6 — validation pair checks (Standard path).** Run Pattern 1 on the `spec.md` + `context.md` pair using spec dimensions plus five pair checks — every factual claim in `spec.md` is supported by `context.md`; every Key Design Decision ID appears in both without contradiction; approval-relevant schema/persistence in `context.md` appears in `spec.md` unless deferred/out of scope; implementation-relevant prevention evidence in `context.md` appears in `spec.md` when approval-relevant; multi-option comparisons give each option explicit pros/cons. Treat schema-only-in-context, approval-relevant prevention-only-in-context, and missing per-option pros/cons as HIGH by default. Exit: primary clean + 1 adversarial sub-agent; footer both files. (Quick path: Pattern 1 on `spec.md` alone; one primary clean pass unless a risk trigger requires an adversarial sub-agent.)
```
**Replace:**
```
**Step 6 — validation pair checks.** Run Pattern 1 on the `spec.md` + `context.md` pair using spec dimensions plus five pair checks — every factual claim in `spec.md` is supported by `context.md`; every Key Design Decision ID appears in both without contradiction; approval-relevant schema/persistence in `context.md` appears in `spec.md` unless deferred/out of scope; implementation-relevant prevention evidence in `context.md` appears in `spec.md` when approval-relevant; multi-option comparisons give each option explicit pros/cons. Treat schema-only-in-context, approval-relevant prevention-only-in-context, and missing per-option pros/cons as HIGH by default. Exit: primary clean + 1 adversarial sub-agent; footer both files.
```
**Verification:** `grep -c 'validation pair checks (Standard path)\|(Quick path: Pattern 1 on' templates/SHAMT_RULES.template.md` returns 0; `grep -F '**Step 6 — validation pair checks.**' templates/SHAMT_RULES.template.md` returns 1.

### Step 4.12 — Pattern 3 Gate 2b: drop the "(Standard path)" qualifier
**Operation:** EDIT
**File:** templates/SHAMT_RULES.template.md
**Locate:**
```
**Gate 2b (Step 7).** Present the validated `spec.md` as the approval artifact and link `context.md` as supporting detail (Standard path). If a new service is in scope, standard monitoring requirements must appear in Requirements or be explicitly Deferred with reason.
```
**Replace:**
```
**Gate 2b (Step 7).** Present the validated `spec.md` as the approval artifact and link `context.md` as supporting detail. If a new service is in scope, standard monitoring requirements must appear in Requirements or be explicitly Deferred with reason.
```
**Verification:** `grep -F 'link `context.md` as supporting detail (Standard path)' templates/SHAMT_RULES.template.md` returns 0; `grep -F 'link `context.md` as supporting detail. If a new service' templates/SHAMT_RULES.template.md` returns 1.

### Step 4.13 — Pattern 4 story-mode: drop the Quick-path Plan-Alignment N/A branch + renumber the #50 PR sentence
**Operation:** EDIT
**File:** templates/SHAMT_RULES.template.md
**Locate:**
```
**Story mode:** Review code just built for an active story. Output `stories/{slug}/feedback/review_v1.md` only when findings, risk, or user request require it; re-reviews use `review_v2.md`, etc. No `overview.md`. Before findings, perform Plan Alignment: resolve the active plan, read it alongside the diff, and check Step Coverage, Change Fidelity, Scope Discipline, Verification Passage, and Zero Builder Design Decisions. Write `## Plan Alignment` at the top of the review. If no plan exists (Quick path), record N/A. Story-mode validation uses 7 dimensions (the 7th is Plan Alignment). **When `pr_provider == github`**, story-mode Review also opens the PR after the review validates (push branch + `gh pr create`, confirm-gated, PR number recorded in the story folder); Polish (`/e7`) is then an **iterative** loop that re-pulls the latest PR comments each run and pushes fix commits (pull-only — no thread postback); Finalize (`/e8`) **merges** the PR (`gh pr merge --squash`, mergeable-guarded). `/e-all` stops at the end of Review. When `pr_provider != github`, all three keep today's local-only behavior.
```
**Replace:**
```
**Story mode:** Review code just built for an active story. Output `stories/{slug}/feedback/review_v1.md` only when findings, risk, or user request require it; re-reviews use `review_v2.md`, etc. No `overview.md`. Before findings, perform Plan Alignment: resolve the active plan (always present — Plan is a mandatory phase), read it alongside the diff, and check Step Coverage, Change Fidelity, Scope Discipline, Verification Passage, and Zero Builder Design Decisions. Write `## Plan Alignment` at the top of the review. Story-mode validation uses 7 dimensions (the 7th is Plan Alignment). **When `pr_provider == github`**, story-mode Review also opens the PR after the review validates (push branch + `gh pr create`, confirm-gated, PR number recorded in the story folder); Polish (`/e8`) is then an **iterative** loop that re-pulls the latest PR comments each run and pushes fix commits (pull-only — no thread postback); Finalize (`/e9`) **merges** the PR (`gh pr merge --squash`, mergeable-guarded). `/e-all` stops at the end of Review. When `pr_provider != github`, all three keep today's local-only behavior.
```
**Verification:** `grep -c 'If no plan exists (Quick path), record N/A' templates/SHAMT_RULES.template.md` returns 0; `grep -F 'Polish (`/e8`) is then an **iterative** loop' templates/SHAMT_RULES.template.md` returns 1; `grep -F 'Finalize (`/e9`) **merges** the PR' templates/SHAMT_RULES.template.md` returns 1; `grep -F '`/e-all` stops at the end of Review' templates/SHAMT_RULES.template.md` returns 1.

### Step 4.14 — Pattern 4 formal-mode steps: renumber the `/e6-review-changes` pointer
**Operation:** EDIT
**File:** templates/SHAMT_RULES.template.md
**Locate:**
```
The formal-mode procedure is executed by the `review-executor` persona — full steps live in that agent body + the `/e6-review-changes` command + `reference/review_categories.md`:
```
**Replace:**
```
The formal-mode procedure is executed by the `review-executor` persona — full steps live in that agent body + the `/e7-review-changes` command + `reference/review_categories.md`:
```
**Verification:** `grep -F '+ the `/e7-review-changes` command +' templates/SHAMT_RULES.template.md` returns 1; the `/e6-review-changes` form is gone from this site.

### Step 4.15 — Pattern 5: replace the Quick-path-skip + Standard-path-requires paragraphs with a uniform mandatory-plan statement
**Operation:** EDIT
**File:** templates/SHAMT_RULES.template.md
**Locate:**
```
The Quick path skips `implementation_plan.md` by default and executes the spec Build Checklist directly. Escalate to a full plan if the checklist exceeds 10 steps, a builder sub-agent is needed, exact locate/replace details are necessary, verification is complex, or the user asks for Gate 3 planning.

The Standard path requires a validated implementation plan after spec approval and before Build.
```
**Replace:**
```
Every story requires a validated `implementation_plan.md` (Phase 3) after spec approval and before Build — planning is mandatory; there is no inline-build shortcut.
```
**Verification:** `grep -c 'The Quick path skips `implementation_plan.md`\|The Standard path requires a validated' templates/SHAMT_RULES.template.md` returns 0; `grep -F 'planning is mandatory; there is no inline-build shortcut' templates/SHAMT_RULES.template.md` returns 1.

### Step 4.16 — Part 3 Phase Narratives pointer paragraph: renumber the e-command list, drop e3b, add e4/e9, drop the Quick/Standard path-map reference
**Operation:** EDIT
**File:** templates/SHAMT_RULES.template.md
**Locate:**
```
Each phase's purpose, minimum-viable artifact, gate, recommended model, and per-phase invariants live authoritatively in its **command body** — `/e1-start-story`, `/e2-define-spec`, `/e3-plan-implementation` (+ `/e3b-write-testing-plan`), `/e4-execute-plan`, `/e5-execute-tests`, `/e6-review-changes`, `/e7-resolve-feedback` (under `host/templates/claude/commands/`). Gates are summarized in the Quick / Standard path-map tables above; per-phase model tiers are in `reference/model_selection.md`. Resume any phase with its slug-first command (e.g. `/e4-execute-plan {slug}`).
```
**Replace:**
```
Each phase's purpose, minimum-viable artifact, gate, recommended model, and per-phase invariants live authoritatively in its **command body** — `/e1-start-story`, `/e2-define-spec`, `/e3-plan-implementation`, `/e4-write-test-plan`, `/e5-execute-plan`, `/e6-execute-tests`, `/e7-review-changes`, `/e8-resolve-feedback`, `/e9-finalize-story` (under `host/templates/claude/commands/`). Gates are summarized in the Phase Map table above; per-phase model tiers are in `reference/model_selection.md`. Resume any phase with its slug-first command (e.g. `/e5-execute-plan {slug}`).
```
**Verification:** `grep -c 'e3b-write-testing-plan' templates/SHAMT_RULES.template.md` returns 0; `grep -F '`/e4-write-test-plan`, `/e5-execute-plan`, `/e6-execute-tests`, `/e7-review-changes`, `/e8-resolve-feedback`, `/e9-finalize-story`' templates/SHAMT_RULES.template.md` returns 1; `grep -F 'summarized in the Phase Map table above' templates/SHAMT_RULES.template.md` returns 1.

### Step 4.17 — Token Discipline operational rules: drop the Quick-path operational bullet
**Operation:** EDIT
**File:** templates/SHAMT_RULES.template.md
**Locate:**
```
## Operational rules

- Use the **Quick path** for ≤10 low-risk steps to avoid unnecessary `context.md`, `implementation_plan.md`, clean `review_v1.md`, and no-op `addressed_feedback.md`.
- Generated host skills should route to canonical rules/templates rather than duplicate full protocol text.
```
**Replace:**
```
## Operational rules

- Generated host skills should route to canonical rules/templates rather than duplicate full protocol text.
```
**Verification:** `grep -c 'Use the \*\*Quick path\*\* for ≤10 low-risk steps' templates/SHAMT_RULES.template.md` returns 0.

### Step 4.18 — Token Discipline operational rules: drop the "Standard-path mechanical Build" bullet
**Operation:** EDIT
**File:** templates/SHAMT_RULES.template.md
**Locate:**
```
- The Standard-path mechanical Build is executed by the cheap-tier builder persona; the architect plans, the builder executes.
```
**Replace:**
```
- The mechanical Build is executed by the cheap-tier builder persona; the architect plans, the builder executes.
```
**Verification:** `grep -c 'The Standard-path mechanical Build' templates/SHAMT_RULES.template.md` returns 0; `grep -F 'The mechanical Build is executed by the cheap-tier builder persona' templates/SHAMT_RULES.template.md` returns 1.

### Step 4.19 — Default tier mapping: rename "manual-testing-plan authoring" → "user-test-plan authoring"
**Operation:** EDIT
**File:** templates/SHAMT_RULES.template.md
**Locate:**
```
| **Balanced** | Sonnet | Code reading, structural analysis, spec research, plan creation, medium-complexity validation, formal-mode code-review metadata, manual-testing-plan authoring |
```
**Replace:**
```
| **Balanced** | Sonnet | Code reading, structural analysis, spec research, plan creation, medium-complexity validation, formal-mode code-review metadata, user-test-plan authoring |
```
**Verification:** `grep -c 'manual-testing-plan authoring' templates/SHAMT_RULES.template.md` returns 0; `grep -F 'user-test-plan authoring' templates/SHAMT_RULES.template.md` returns 1.

### Step 4.20 — Story Artifact Naming: elevate user_test_plan to the always-v1 + re-baselined sets, drop the stale single-baseline bullet, renumber the agent_test_session phase ref

**Why this is more than a rename:** `user_test_plan.md` is now a **mandatory, always-produced** Phase-4 artifact (proposal Target flow) and is a **dedicated re-baseline artifact** created in `rebaseline_protocol.md` steps 4/7 (proposal row 46), exactly parallel to `spec`/`context`/`implementation_plan`/`testing_plan`. So it migrates from the old `manual_test_plan` "single-baseline" bullet into the always-v1 list (line 368) and the re-baselined list (line 369); the standalone single-baseline bullet is removed (keeping it would leave SHAMT_RULES contradicting row 46's re-baseline set — a D2 inconsistency). `agent_test_session.md` stays single-baseline (it is a per-run log, not a planning baseline) and only renumbers Phase-5 → Phase-6.

**Operation:** EDIT
**File:** templates/SHAMT_RULES.template.md
**Locate:**
```
- `spec.md`, `context.md`, `implementation_plan.md`, and `testing_plan.md` are always baseline v1;
- `spec_vN.md`, `context_vN.md`, `implementation_plan_vN.md`, `testing_plan_vN.md` are re-baselined artifacts;
- `active_artifacts.md` is the authoritative pointer once multiple baselines exist;
- `review_vN.md` files are append-only versioned review artifacts;
- `manual_test_plan.md` is single-baseline; if re-baselined, follow the same `_vN.md` convention.
- `agent_test_session.md` is the required Phase-5 agent-as-user run log; single-baseline (`_vN.md` if re-baselined).
```
**Replace:**
```
- `spec.md`, `context.md`, `implementation_plan.md`, `testing_plan.md`, and `user_test_plan.md` are always baseline v1;
- `spec_vN.md`, `context_vN.md`, `implementation_plan_vN.md`, `testing_plan_vN.md`, `user_test_plan_vN.md` are re-baselined artifacts;
- `active_artifacts.md` is the authoritative pointer once multiple baselines exist;
- `review_vN.md` files are append-only versioned review artifacts;
- `agent_test_session.md` is the required Phase-6 agent-as-user run log; single-baseline (`_vN.md` if re-baselined).
```
**Verification:** `grep -c 'manual_test_plan' templates/SHAMT_RULES.template.md` returns 0; `grep -F 'and `user_test_plan.md` are always baseline v1' templates/SHAMT_RULES.template.md` returns 1; `grep -F '`testing_plan_vN.md`, `user_test_plan_vN.md` are re-baselined artifacts' templates/SHAMT_RULES.template.md` returns 1; `grep -c 'is single-baseline; if re-baselined' templates/SHAMT_RULES.template.md` returns 0 (the standalone single-baseline bullet is gone); `grep -F 'required Phase-6 agent-as-user run log' templates/SHAMT_RULES.template.md` returns 1.

### Step 4.21 — Final whole-file residual sweep (no edit unless a stray remains)
**Operation:** EDIT (only if the sweep finds a residual; otherwise N/A — no further edit)
**File:** templates/SHAMT_RULES.template.md
**Locate:** N/A — verification-only sweep.
**Replace:** N/A.
**Verification:** all of the following return 0 over `templates/SHAMT_RULES.template.md`:
`grep -ci 'Quick path'`; `grep -ci 'Standard path'`; `grep -c 'e3b'`; `grep -c 'e5b'`; `grep -c 'manual_test_plan'`; `grep -c 'manual-test'`; `grep -c 'optional-post-build'`; `grep -c 'Optional post-Build artifact'`; `grep -c '/e8-finalize-story'`; `grep -c '/e7-resolve-feedback'`; `grep -c '/e6-review-changes'`; `grep -c '/e4-execute-plan'`; `grep -c '/e5-execute-tests'`; `grep -c 'Phase 5 (Test)'`; `grep -c 'Testing (Phase 5'`. If any returns nonzero, the prior step that owns that site was mis-applied — re-apply it; do not patch a new site here.

## Phase notes

**Anchors RENAMED by this phase (Phase 4 edits SHAMT_RULES.template.md only):**
- **Test-Plan anchor.** Step 4.5 retitles the section heading from `### Optional post-Build artifact` to `### Test Plan (Phase 4 — required)`, changing its GitHub-style anchor from `#optional-post-build-artifact` to **`#test-plan-phase-4--required`**. The old anchor ceases to exist after this phase.
- **Testing anchor.** Step 4.4 retitles `### Testing (Phase 5 — required)` to `### Testing (Phase 6 — required)`, changing its anchor from `#testing-phase-5--required` to **`#testing-phase-6--required`**. The old anchor ceases to exist after this phase.
- Anchor slug derivation note: GitHub lowercases, drops the `### `, replaces spaces with `-`, drops the parentheses, and the em-dash `—` (a non-alphanumeric) collapses to a hyphen with its surrounding spaces — yielding the double-hyphen `phase-4--required` / `phase-6--required` forms. These match the exact anchors the other phase agents assumed.

**Inbound-link repoints are owned by OTHER phases, NOT by Phase 4** (this phase touches no file other than `templates/SHAMT_RULES.template.md`; the links into these two anchors live in `host/templates/claude/commands/` files renamed/edited elsewhere). The proposal-row-7 reference in an earlier draft of this note was a conflation — row 7 is the `e4-execute-plan.md → e5-execute-plan.md` command **MOVE**, not a link edit. The true owners, verified against the sibling phase plans:
- `→ #test-plan-phase-4--required`: the only surviving inbound link is the `validate-artifact.md` Step-2 dimension-table "User test plan" row, repointed by **Phase 1b, Step 1.102**. The former second inbound link (the e5b suggestion in `e4-execute-plan.md`) is **deleted, not repointed** — it is removed when that file becomes `e5-execute-plan.md` (**Phase 1b, Step 1.37**), so it carries no link to this anchor afterward.
- `→ #testing-phase-6--required`: the inbound link in `e5-execute-tests.md`'s Step-3 routing is repointed when that file becomes `e6-execute-tests.md` (**Phase 1b, Step 1.50**). The other former inbound links (in `e3b-write-testing-plan.md`) are not repointed either — `e3b-write-testing-plan.md` is **deleted** (**Phase 1a, Step 1.28**) and its surviving logic folds into the newly-created `e4-write-test-plan.md`, which is authored pointing at `#testing-phase-6--required` from the start (**Phase 1a, Step 1.27**).

**#50 preservation (do NOT revert):** Step 4.13 preserves #50's Pattern-4 story-mode PR sentence verbatim except for the two label renumbers (`/e7`→`/e8` Polish, `/e8`→`/e9` Finalize); PR-open-at-Review, iterative pull-only Polish, `gh pr merge` Finalize, and `/e-all` stops at Review all carry forward unchanged. The only other deletion in that sentence is the now-moot "If no plan exists (Quick path), record N/A" Plan-Alignment branch (Plan is mandatory), which is not #50 content.

**D12 size note:** Net change is a size **reduction** — the two path-map tables (Quick + Standard, ~24 rows) collapse to one 9-row map; the Path Selection trigger lists, the Quick/Standard exit-criteria split, the artifact-shape table, and three operational/parenthetical Quick-path mentions are removed; only the merged Test-Plan/Test section prose and the Phase-Map intro are net-new (small). D12-favorable, as the proposal predicts.

**Renumber-map coverage in this file:** e1/e2/e3 narrative numbers unchanged; the previously-numbered Build/Test/Review/Polish/Finalize map rows (old Quick 3–7 / Standard 4–8) are replaced wholesale by the single 9-phase map (Step 4.3); `/e6→/e7` (Step 4.14 formal pointer), `/e7→/e8` (Step 4.13 Polish), `/e8→/e9` (Steps 4.7, 4.8, 4.13 Finalize), `/e3b`/`/e4-execute-plan`/`/e5-execute-tests`/`/e6-review-changes`/`/e7-resolve-feedback` all repointed to their renumbered command names (Step 4.16). Phase 5/6 testing-narrative renumber in Steps 4.4 (Testing → Phase 6) and 4.20 (agent_test_session → Phase-6). `manual` → `user` test-plan rename in Steps 4.19, 4.20 (and the new Test-Plan/Test prose).

---
Validated 2026-06-21 — 2 rounds, 1 adversarial sub-agent confirmed
