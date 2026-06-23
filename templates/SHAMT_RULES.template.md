# Shamt Rules

**Version:** v2 (template)
**Purpose:** Canonical agent rules: story workflow, validation, spec, code review, implementation planning, and the three cross-cutting design principles.

> This file is a **template** rendered into a child project's `CLAUDE.md` at install or regen time. Edit only here, in `shamt-core/templates/`. Generated copies are overwritten; the canonical source is this file.

---

## What is Shamt?

Shamt is a quality framework for AI-assisted development under Claude Code. It defines:

- **5 core patterns** — validation loops, severity classification, spec protocol, code review, implementation planning.
- **Two role flows** — an **Engineer flow** (a uniform 9-phase linear sequence, e1–e9; every phase is mandatory for story completion) and a **Product Owner flow** (Epic → Feature → Story decomposition).
- **The story** as the handoff artifact between the two roles.

The Engineer flow is the load-bearing surface. The PO flow exists for initiatives large enough to warrant top-down decomposition. There are no top-level orphans: every feature nests under an epic and every story under a feature (see §PO-tree resolution). One-off / standalone work (bugs, quick wins, tech stories) lives under the standing **Tech Stories** epic and runs the Engineer flow from there. Within the PO flow, **decomposition catalogs breadth-context** and **define-\* deepens depth** from that seed before its terminal gate — see the `/pe3-decompose`/`/pf3-decompose` and `/pf1-define`/`/e1` command bodies for per-altitude detail.

Core files:

- `SHAMT_RULES.template.md` — these rules (this file).
- `.shamt-core/README.md` — host wiring quick reference (commands, skills, personas).
- `reference/` — expanded examples, standards, recipes.
- `templates/` — artifact skeletons.
- `stories/{ID}-{slug}-{brief-description}/` — per-story artifacts (the `{ID}-` prefix is added to new tickets — see **# Ticket IDs**).
- `epics/{ID}-{slug}-{brief}/`, `features/{ID}-{slug}-{brief}/` — PO-flow artifacts.
- `.shamt-core/proposals/` — framework-update proposals.
- `.shamt-core/shamt-config.json` — per-project configuration (tracker, etc.).

---

# Cross-Cutting Design Principles

These three principles apply to **every** multi-phase flow and every artifact-generation flow Shamt defines.

## Principle 1: Phase-per-command + slug resumability

Every multi-phase flow follows this pattern:

1. **One slash command per phase.** No single mega-orchestrator. Each phase is invoked explicitly: `/e1-start-story`, `/e2-define-spec`, `/e3-plan-implementation` are separate commands, not steps inside one `/run-story`.
2. **Every command takes a ticket ID or slug.** `/command {id-or-slug}` resolves to exactly one folder (ID `^T[0-9]+$` → `{root}/{ID}-*/`; slug → exact `{root}/{slug}/` ∪ `{root}/{slug}-*/` ∪ `{root}/*-{slug}-*/`, unioned); halt if ambiguous (>1) or none. Globs are work-root-relative — see §PO-tree resolution and **# Ticket IDs**.
3. **Fresh-agent runnable.** A new agent with no conversation history reads the on-disk artifacts under the resolved folder, determines current state from artifact presence (and from `active_artifacts.md` when re-baselined), and executes the requested phase.
4. **No state file, no orchestrator memory.** State lives in the filesystem. If the prior phase's artifact exists and passes its exit gate, the next phase can run.
5. **Skills mirror slash commands.** Each slash command has a corresponding auto-triggered skill (natural-language phrases like "spec this ticket") that runs the same flow. Both surfaces, same canonical body.
6. **Context-clear breakpoints between phases.** Encouraged but not enforced. `/clear` between phases keeps context fresh and proves resumability.
7. **Single-session sizing constraint.** Every slug-started command should produce work that fits in one session without context compaction. If a phase would compact, split further (architect/builder sub-agent, phase decomposition into sub-phases) rather than spanning compacted sessions. Between-session resume is handled by the slug + `active_artifacts.md` pattern; within-session compaction is avoided.

## Principle 2: Open-questions iterative dialog

When an agent drafts a new artifact (spec, plan, proposal, epic, feature, story ticket, etc.), open questions are surfaced **one at a time** and answered before the artifact is considered drafted.

1. **Maintain an "Open Questions" section** in the artifact while drafting. Add new questions as they arise.
2. **Present each question to the user via `AskUserQuestion`** (or equivalent). One at a time. Never bulk-bomb.
3. **Update the artifact with the answer before moving to the next question.** The "Open Questions" section shrinks as the artifact firms up.
4. **An artifact is not "drafted" while open questions remain.** Validation cannot start; user approval cannot be requested; the next phase cannot run.
5. **Never proceed on an assumption when a question exists.** If the answer changes the artifact, write it down. If the answer doesn't, record the resolution inline so future agents understand why the question was closable.

Applies to every artifact-generation flow: Engineer-flow Spec / Plan / Review / Polish; PO-flow Epic / Feature / Story definition; framework-update proposals; any v2-original artifact.

## Principle 3: Disk-authoritative cross-session work

Shamt is multi-session and parallel by design: multiple agents author and update artifacts, run personas, and advance work concurrently. The on-disk artifacts — not any one agent's conversation history — are the authoritative record of work performed.

1. **Disk is the record; the session is not.** An agent reasons about what work has occurred from on-disk artifacts (proposals/footers/banners, story folders, `feedback/`, `active_artifacts.md`, the archive/deferred/rejected folders) and from git history — never from the assumption that its own session observed everything.
2. **Absence-from-session is not evidence of fabrication.** An agent must not infer that "I did not perform or observe X in this session" means "X never happened." A provenance claim recorded in an artifact (a validation footer, an f0 capture banner, a confirmed-root-cause line, a tracker attribution) is **presumed genuine** — a parallel session did real work this session has no visibility into.
3. **Verify by reading, never by destroying.** If a cross-session claim genuinely needs verification, the evidence is git history across branches, the cited artifact/folder, or the user — never silent deletion, revert, or rename-back of the artifact. (The existing "never halt or revert on unrelated tree state" rules in `/f3-implement-update` and `/f6-archive-proposal` depend on this.)
4. **This does not relax Pattern 1.** Pattern 1's adversarial validation still distrusts unsupported *claims about reality* (code, governing docs) and verifies them from evidence, and agents still never fabricate a claim of work they did not do. Session-absence is simply not the evidence Pattern 1 demands: distrusting a claim about the codebase is in scope; distrusting an artifact's cross-session **provenance** merely because this session didn't author it is not.

---

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

### Testing (Phase 6 — required)

**Phase 6 (Test)** is **required** on every story and **blocks until green**: the `user-simulator` persona
**executes the `user_test_plan.md` scenarios** authored in Phase 4 (driving the project per
`TESTING_STANDARDS.md` as conventions input), writing `agent_test_session.md`, plus the **automated**
`testing_plan.md` run by `test-executor` when `TESTING_STANDARDS.md` declares suites. A failure routes to
`/e8-resolve-feedback` with a **required root-cause section** (which of Spec/Plan/Build let it through + the
prevention). Full detail in [`reference/testing.md`](reference/testing.md).

### Test Plan (Phase 4 — required)

**Phase 4 (Test Plan)** is **required** on every story: it authors `user_test_plan.md` (agent-as-user
scenarios — always) and `testing_plan.md` (automated suites — when `TESTING_STANDARDS.md` declares them),
each validated under Pattern 1. The `user_test_plan.md` is the script the Phase-6 `user-simulator`
executes; it is not a human-only walkthrough. Full detail in [`reference/testing.md`](reference/testing.md).

### Context-clear breakpoints

- **Strong** breakpoints after Gate 2b and after Gate 3.
- **Advisory** anywhere: before spec validation, after Gate 2b, before plan validation, after Build, after Review.

### Finalize phase (terminal)

Both role flows end with a **Finalize** command modelled on `/f6-archive-proposal`, each behind explicit user confirmation (per-tracker and clean-tree mechanics in the command bodies):

- **`/e9-finalize-story {slug}`** — the Engineer flow's terminal phase: commits the story's work as a scoped unit (clean-tree guard), confirms prior phases complete (Test PASSes — required; Review + feedback resolved), marks the work item done via the active tracker, and writes `**Status: Done**` into `ticket.md` — the profile-independent signal the status line reads. When `pr_provider == github` it also merges the story's PR (`gh pr merge --squash`, mergeable-guarded, behind the same confirm) — independent of the `work_item_tracker`-routed close.
- **`/pe4-finalize {slug}`** — the PO flow's terminal command at the Epic altitude: after confirming every child feature/story is finalized, marks the epic done and **moves the epic folder into `epics/archive/`** as a **whole-subtree move** (features/stories ride along — parentage is the path, nothing dangles). There is no per-feature finalize command (features close implicitly when their stories are done); `epics/archive/` is excluded from active-epic status-line resolution.

### §PO-tree resolution

The PO hierarchy nests — features under their epic, stories under their feature:

```
epics/{ID}-{epic-slug}-{brief}/
  epic.md
  STATUS.md          # derived per-feature/per-story state rollup (regen via /po-status; never hand-edited)
  features/{ID}-{feature-slug}-{brief}/
    feature.md
    stories/{ID}-{story-slug}-{brief}/
      ticket.md, spec.md, implementation_plan.md, feedback/, raw/, ...
```

Slug-first commands resolve a folder by a **tree-wide glob with a legacy-flat fallback** (slugs are globally unique, so the `{slug}-*` tail is unambiguous; exactly one match — halt on zero or multiple):

- **Epic** (top-level): `epics/{ID}-*/` · `epics/{slug}-*/` · `epics/*-{slug}-*/`.
- **Feature**: `epics/*/features/{ID}-*/` · `epics/*/features/{slug}-*/` · `epics/*/features/*-{slug}-*/`; legacy fallback `features/{slug}-*/`.
- **Story**: `epics/*/features/*/stories/{ID}-*/` · `…/stories/{slug}-*/` · `…/stories/*-{slug}-*/`; legacy fallback `stories/{slug}-*/`.
- **Standing reserved folders** (Tech Stories — numbered `{ID}-{reserved-slug}` tickets): resolve the reserved slug under **any `T{N}-` prefix** (and the bare legacy name as a fallback) — `tech-stories` → `epics/*-tech-stories/` (∪ `epics/tech-stories/`), `bugs` → `epics/*/features/*-bugs/` (∪ `…/features/bugs/`), `quick-wins` → `epics/*/features/*-quick-wins/` (∪ `…/features/quick-wins/`). Exactly one match — halt on zero or multiple.

New work is **written nested**; pre-existing flat folders stay and resolve via the fallback (no migration). Parentage is encoded by the path — there are **no `**Parent Epic:**` / `**Parent Feature:**` back-ref headers**. Throughout command / skill / template / reference bodies, `epics/{slug}/`, `features/{slug}/`, `stories/{slug}/` denote **the resolved folder** (leaf still `…-{brief}/`). **Write-side composition.** A producer writing a child path must spell the **full nested form** using the canonical resolved-folder placeholders `{epic-folder}` and `{feature-folder}` — a feature at `epics/{epic-folder}/features/{feature-folder}/`, a story at `epics/{epic-folder}/features/{feature-folder}/stories/{ID}-…/`. **Never collapse an intermediate segment** into a single placeholder (a feature is never a direct child of `epics/`). **Work root:** all bare `epics/`/`features/`/`stories/`/`code_reviews/`/`shamt-state/` paths are **work-root-relative** — repo root on self-host, `.shamt-core/` in a child (resolve the work root once via `.shamt-core/`-presence before globbing/writing). A child writes work-tree artifacts only under `.shamt-core/`; its project root holds only `CLAUDE.md` + `.claude/`. **Epic state rollup.** Each epic folder also carries a generated `STATUS.md` — a **derived** per-feature/per-story state rollup (New / Validated / Building / Released), re-computed from on-disk signals by `/po-status {epic-slug}` and the transition commands; never hand-edited. Derivation contract: [`reference/epic_status_board.md`](../reference/epic_status_board.md).

**Active-item pointers.** The status line reads `{work-root}/shamt-state/active-{epic,feature,story}` (`.shamt-core/shamt-state/` in a child), each holding the active item's **work-root-relative** nested path (parentage = walk it up). The `p*`/`e1` commands write/refresh the matching pointer as work advances; `import-shamt` preserves them (outside its sync set).

### Standing Tech Stories epic

The standing **Tech Stories** epic (introduced above) is the home for one-off work — bug fixes and small standalone improvements — that strict nesting has no top-level place for.

- **Standing fixtures, numbered reserved slugs.** `epics/{tech-stories-folder}/` holds two standing features, **Bugs** and **Quick Wins**, as **numbered `{ID}-{reserved-slug}` tickets** (the ID prefix + the reserved slug tail, with **no** `-{brief}`) — e.g. `epics/T1-tech-stories/features/T2-bugs/` at a fresh init. They take the first available ticket numbers via the §Ticket IDs max-scan and participate in it like every other ticket. Seeded once (idempotent — skip if a reserved-slug container already exists under any prefix) by the install/sync flow (`init-shamt.sh` / `import-shamt.sh`), never per-initiative by `/pe1-define`; their globally-unique reserved slugs make the existing collision checks refuse any reuse. **Reserved-name resolution globs the ID prefix** — `bugs` / `quick-wins` / the `{tech-stories-folder}` placeholder resolve the reserved slug under any `T{N}-` prefix (see §PO-tree resolution), so the operator never types the number.
- **Local-only, tracker-agnostic.** The standing epic + features never map to tracker work items — only the tickets filed under them do, per the active profile (a bug = a GitHub issue / ADO bug).
- **Entry + archive.** Entry is via `/ps0-draft [bugs|quick-wins]` (seeds a ticket stub under the chosen feature, hands to `/e1-start-story`, bypassing the `/pe1-define`→`/pf3-decompose` cascade); archive-on-finalize moves the folder into the feature's `archive/`. Mechanics live in the `/ps0-draft` + `/e9-finalize-story` command bodies.

---

# Global Story Invariants

Apply across Spec, Plan, Build, Test, Review, and Polish:

- **Story folder resolution.** Resolve the story folder per §PO-tree resolution (globs are **work-root-relative** — `.shamt-core/` in a child), anchored on `ticket.md`: ID → `stories/{ID}-*/ticket.md`; slug → `stories/{slug}/ticket.md` ∪ `stories/{slug}-*/ticket.md` ∪ `stories/*-{slug}-*/ticket.md`. Multiple → halt and ask; none → halt and report.
- **Active artifact pointer.** When `stories/{slug}/active_artifacts.md` exists, read it first and use files listed under "Active Files" instead of assuming unversioned names.
- **TODO gate.** TODO comments are allowed only for team-discussion placeholders or temporary debug logging that must be removed before merge. Polish cannot complete while any TODO remains in the implementation plan or code. If `.shamt-core/project-specific-files/CODING_STANDARDS.md` is stricter, follow it.
- **Re-baseline rule.** When a post-approval requirement change makes the active spec or plan misleading, stop and create a new baseline instead of patching the old one in place. See the Re-baseline Protocol below.
- **Story branch baseline rule.** Before creating a story branch in any affected repo, fetch the latest configured development branch and create the feature branch from the fetched remote development branch (e.g., `git fetch origin <development-branch>` then `git checkout -b feature/{slug}/<owner-or-team> origin/<development-branch>`). Do not create story branches from current local HEAD. If the feature branch already exists, halt and report.
- **Standards check.** The `.shamt-core/project-specific-files/` docs are governing references for artifacts and reviews. Note absence only if a file does not exist.

---

# Part 1: Core Patterns

## Pattern 1: Validation Loops

**Purpose:** Iterative self-review until the artifact meets the quality threshold.

**Exit criteria:** every validation is uniform — a **primary clean round + 1 independent adversarial sub-agent confirmation**. There is no lower-rigor single-pass tier; the sub-agent always runs (no one-LOW allowance). The former Quick/Standard rigor selector is retired framework-wide.

### The 8-Step Validation Process

The eight steps — read/investigate, identify issues across dimensions, classify severity, fix immediately, update `consecutive_clean` (clean = zero issues or one LOW fixed), check exit, adversarial sub-agent review (**no one-LOW allowance**), add footer — have their full per-step mechanics + worked counter examples in [`reference/validation_exit_criteria.md`](reference/validation_exit_criteria.md). The normative dimension lists and footer format stay here:

**Step 2 — dimensions per artifact type** (first check alignment with `.shamt-core/project-specific-files/ARCHITECTURE.md` + `CODING_STANDARDS.md`):

**Specs (8 dimensions):** Completeness; Correctness; Consistency; Helpfulness; Improvements; Missing proposals; Open questions; Standards/architecture alignment. Hard checks per Pattern 3: multi-option pros/cons, Open-Questions-answered-from-code, review-prevention inventory, and the schema data-lineage trace.

**Implementation Plans (8 dimensions):** Step clarity; Mechanical executability; File coverage; Operation specificity; Verification completeness; Dependency ordering; Requirements alignment; Naming clarity. Hard checks per Pattern 5: no optional/if/consider branches, exact locate/replace, concrete CREATE paths, review-prevention-gate mapping; plus imports listed for a file must be used there.

**Code Reviews (6 dimensions):** Correctness; Completeness; Helpfulness; Severity accuracy; Evidence; Standards/architecture alignment. Hard checks per `reference/review_categories.md`: review every changed file/function/branch independently (do not assume parallel files are identical); boundary analysis + tenant-A→B bypass tracing for removed/weakened checks and tenant/path/object/document access changes.

**General Artifacts (5 dimensions):** Completeness; Clarity; Accuracy; Actionability; Standards/architecture alignment.

**Step 8 — footer format.** When complete, append:

```text
---
Validated {date} — N rounds, 1 adversarial sub-agent confirmed
```

## Pattern 2: Severity Classification

Use the four levels consistently. Quick questions:

1. If not fixed, can the workflow complete? **No** → CRITICAL.
2. Will it cause confusion or wrong decisions? **Yes** → HIGH.
3. Does it noticeably reduce quality / usability? **Yes** → MEDIUM.
4. Otherwise → LOW.

Exactly one LOW issue fixed still counts as a clean primary round. Any sub-agent issue resets validation.

## Pattern 3: Spec Protocol

**Purpose:** Targeted research + design dialog + validated user-facing spec and supporting context. (The exact spec-template section placement — which section follows which — lives in the `/e2-define-spec` command body + `templates/spec.template.md`; this Pattern is the normative contract.)

### The 7-Step Spec Protocol

The seven steps — ingest the ticket, targeted research, draft skeletons, **Gate 2a** design dialog, flesh out spec/context, validate, **Gate 2b** approval — have their full per-step walkthrough (including Step 2's required research captures and Step 5's per-surface prevention requirements + schema/lineage detail + spec/context split) in [`reference/spec_protocol_reference.md`](reference/spec_protocol_reference.md). The normative contract stays here:

**Step 3 — required artifact shape (every story).** Produce `spec.md` (from `templates/spec.template.md`) **and** `context.md` (from `templates/context.template.md`). `spec.md` is the approval contract; `context.md` is the evidence/planning handoff. Approval-relevant persistence design and review-prevention requirements must appear in `spec.md`, not only `context.md`. Key Design Decision IDs appear in both.

**Gate 2a (Step 4).** Present 1–3 design options inline in chat (not in `spec.md` yet) — each with description, pros, cons, effort (S/M/L), and a recommendation; 2–3 required for non-trivial user-facing forks. **Wait for explicit user confirmation before proceeding.**

**Step 6 — validation pair checks.** Run Pattern 1 on the `spec.md` + `context.md` pair using spec dimensions plus five pair checks — every factual claim in `spec.md` is supported by `context.md`; every Key Design Decision ID appears in both without contradiction; approval-relevant schema/persistence in `context.md` appears in `spec.md` unless deferred/out of scope; implementation-relevant prevention evidence in `context.md` appears in `spec.md` when approval-relevant; multi-option comparisons give each option explicit pros/cons. Treat schema-only-in-context, approval-relevant prevention-only-in-context, and missing per-option pros/cons as HIGH by default. Exit: primary clean + 1 adversarial sub-agent; footer both files.

**Gate 2b (Step 7).** Present the validated `spec.md` as the approval artifact and link `context.md` as supporting detail. If a new service is in scope, standard monitoring requirements must appear in Requirements or be explicitly Deferred with reason.

## Pattern 4: Code Review Process

**Purpose:** Structured review with validated, copy-paste-ready feedback.

**Story mode:** Review code just built for an active story. Output `stories/{slug}/feedback/review_v1.md` only when findings, risk, or user request require it; re-reviews use `review_v2.md`, etc. No `overview.md`. Before findings, perform Plan Alignment: resolve the active plan (always present — Plan is a mandatory phase), read it alongside the diff, and check Step Coverage, Change Fidelity, Scope Discipline, Verification Passage, and Zero Builder Design Decisions. Write `## Plan Alignment` at the top of the review. Story-mode validation uses 7 dimensions (the 7th is Plan Alignment). **When `pr_provider == github`**, story-mode Review also opens the PR after the review validates (push branch + `gh pr create`, confirm-gated, PR number recorded in the story folder); Polish (`/e8`) is then an **iterative** loop that re-pulls the latest PR comments each run and pushes fix commits (pull-only — no thread postback); Finalize (`/e9`) **merges** the PR (`gh pr merge --squash`, mergeable-guarded). `/e-all` stops at the end of Review. When `pr_provider != github`, all three keep today's local-only behavior.

**Formal mode:** Review someone else's branch or PR. Never check out the branch; use read-only `git fetch`, `merge-base`, `log`, and `diff`. Resolve the review base in this order: explicit user-provided base; active PR target branch when available; project default formal-review base from `.shamt-core/project-specific-files/ARCHITECTURE.md`; repository default branch otherwise. Fetch base and target branch read-only, then diff against the fetched remote base (e.g., `origin/<base>...<feature-branch>`). If fetch fails or base/branch cannot be resolved, halt and report. Output `code_reviews/<sanitized-branch>/overview.md` + `review_vN.md`.

### Formal steps

The formal-mode procedure is executed by the `review-executor` persona — full steps live in that agent body + the `/e7-review-changes` command + `reference/review_categories.md`: a read-only fetch with a changed-file inventory, a validated `overview.md`, then `review_vN.md` with findings grouped by severity then category at **BLOCKING / CONCERN / SUGGESTION / NITPICK**, each artifact validated with Pattern 1. v2 does not post formal-mode reviews back to external trackers — the artifact stays local.

Every review must consider all 16 categories even when no finding is recorded; the category list, the mechanical checks, and the finding format all live in `reference/review_categories.md`.

## Pattern 5: Implementation Planning

**Purpose:** Create mechanical plans that separate planning from execution.

Every story requires a validated `implementation_plan.md` (Phase 3) after spec approval and before Build — planning is mandatory; there is no inline-build shortcut.

### The 5-Step Process

The five steps — read spec/context and confirm decisions, create the mechanical plan, validate plan (Pattern 1, 8 dimensions, primary clean + 1 adversarial sub-agent), hand off to builder, verify completeness — have their full per-step walkthrough + operation-contract detail in [`reference/implementation_plan_reference.md`](reference/implementation_plan_reference.md). The normative contract stays here:

**Step 2 — Create the mechanical plan.** Use `templates/implementation_plan.template.md`. Every step must be executable without design judgment.

**Required plan contract:**

- no optional branches, vague gates, unresolved `if / when / consider`, or executor judgment;
- stop planning if implementation is unclear;
- verification failure is stop-and-escalate, not permission to improvise;
- plans over one deploy boundary, any phase over 10 steps, or about 1500+ lines require a validated index plus validated phase files;
- plans touching multiple repos include `Step 0-A`, `Step 0-B`, etc. (one per repo); each branch-prep step follows the **Story branch baseline rule** above (fetch the remote development branch, create `feature/{slug}/<owner-or-team>` from it); commit `#{slug}: {message}`;
- include metadata, pre-execution checklist, files manifest with no optional rows, review-prevention gate mapping, numbered steps, verification, Notes, and `CODING_STANDARDS` compliance mapping.

**Operation contracts:**

- **CREATE:** concrete workspace-relative path plus full initial content or named in-repo template/copied sibling with concrete deltas.
- **EDIT:** exact locate string plus exact replacement.
- **DELETE:** file/section plus justification.
- **MOVE:** separate create and delete sub-steps, each verified.

**Hard planning checks** (each maps to a concrete step, a verification, or an explicit N/A before validation). Nine checks — **review-prevention coverage**, **DB write routing** (direct **and** transitive), **new-service/route manifest coverage**, **tenant-A-to-tenant-B bypass verification**, **removed/weakened-check replacement analysis**, **migration CREATE coverage**, **transitive call graph** (imported shared utilities, env keys, external-resource accesses), **byte-for-byte copy** (identical signature/behavior in every repo maintaining the file), and **CODING_STANDARDS mapping** (every applicable rule maps to a step or explicit N/A in `## CODING_STANDARDS Compliance`) — have their expanded per-check detail in [`reference/implementation_plan_reference.md`](reference/implementation_plan_reference.md). Skeleton-first authoring is recommended for plans with 5+ steps.

**Builder contract:** follow steps exactly, execute sequentially, run specified verification, and stop on failed verification or ambiguity. Expected reports: `All steps completed. Verification passed.`, `Step N failed: ...`, `Step N is ambiguous: ...`, `Plan defect at Step N: ...`. Builder model: cheap-tier (Haiku).

---

# Part 2: Token Discipline & Model Selection

Shamt treats token cost as a design constraint. Every flow / persona / phase has a recommended model tier; cheap-tier is used wherever the task is mechanical or zero-bias.

## Operational rules

- Generated host skills should route to canonical rules/templates rather than duplicate full protocol text.
- Read `.shamt-core/project-specific-files/ARCHITECTURE.md` and `.shamt-core/project-specific-files/CODING_STANDARDS.md` once during research, record story-specific standards digest inline, and reuse the digest.
- The mechanical Build is executed by the cheap-tier builder persona; the architect plans, the builder executes.

## Default tier mapping

| Tier | Model | When to use |
|------|-------|-------------|
| **Cheap** | Haiku | File ops, git ops, mechanical execution, sub-agent confirmations, status rollups, intake / freeform ticket capture, test execution |
| **Balanced** | Sonnet | Code reading, structural analysis, spec research, plan creation, medium-complexity validation, formal-mode code-review metadata, user-test-plan authoring |
| **Reasoning** | Opus | Primary validation loops (artifact validation), root-cause analysis, design decisions, multi-dimensional checks, formal-mode review issue-finding, design dialog (Gate 2a), epic/feature decomposition |

Sub-agent confirmations **always** use Cheap tier — these are zero-bias re-reads, not deep reasoning.

## Recommended models per phase (Engineer flow)

The per-phase model tiers for the Engineer flow live in `reference/model_selection.md` (the authoritative table). Personas can override per their definition (see `host/templates/claude/`).

---

# Part 3: Engineer Flow — Phase Narratives

Each phase's purpose, minimum-viable artifact, gate, recommended model, and per-phase invariants live authoritatively in its **command body** — `/e1-start-story`, `/e2-define-spec`, `/e3-plan-implementation`, `/e4-write-test-plan`, `/e5-execute-plan`, `/e6-execute-tests`, `/e7-review-changes`, `/e8-resolve-feedback`, `/e9-finalize-story` (under `host/templates/claude/commands/`). Gates are summarized in the Phase Map table above; per-phase model tiers are in `reference/model_selection.md`. Resume any phase with its slug-first command (e.g. `/e5-execute-plan {slug}`).

---

# Requirement Re-baseline Protocol

Use a re-baseline when a large requirement change arrives after Gate 2b, Gate 3, or Build execution and the active spec or plan would become misleading. The full trigger list + the 10-step re-baseline contract live in [`reference/rebaseline_protocol.md`](reference/rebaseline_protocol.md).

Unversioned names remain baseline v1. Do not rename or overwrite them.

---

# Ticket IDs

Every epic, feature, and story is a **ticket** with a short, globally-unique **ticket ID** of the form `T{N}` (`T1`, `T2`, …) used alongside its slug. The ID prefixes the folder — `epics/{ID}-{slug}-{brief}/`, `features/{ID}-{slug}-{brief}/`, `stories/{ID}-{slug}-{brief}/` — mirroring the `proposals/{NN}-{slug}.md` convention.

- **Allocation.** A new ticket's ID is `max(existing T-number across the whole tree) + 1` — **scanned from disk**, **no counter file**, never reused. Enumerate the leading `^T([0-9]+)-` run on **every** folder name across the full work-root-relative tree (per §PO-tree resolution): `epics/{ID}-*/`, `epics/*/features/{ID}-*/`, `epics/*/features/*/stories/{ID}-*/`, plus the legacy-flat fallbacks `features/{ID}-*/` and `stories/{ID}-*/`. The standing Tech Stories containers (`tech-stories`, `bugs`, `quick-wins`) are **numbered `{ID}-{reserved-slug}` tickets** too (seeded by `init-shamt.sh` / `import-shamt.sh` via this same scan — they take the first available numbers, `T1`/`T2`/`T3` at a fresh init), so they **participate in the max-scan** like any other ticket. The sequence is **global** (one space across all ticket types — an epic might be `T1`, its feature `T2`, a story `T3`) and **flat** (an ID does not encode its parent). A project with only slug-only folders allocates `T1` first. **Post-allocation uniqueness halt-check:** after allocating, verify no other folder anywhere under the work-root tree already carries the chosen `T{N}` prefix; halt on collision.
- **Addressing.** Commands accept either the ID or the slug, resolved per §PO-tree resolution (tree-wide glob matching the ID or slug at the appropriate altitude anywhere in the nested tree, with the legacy-flat fallback).
- **New-tickets-only.** Existing slug-only folders are **not** renamed; they keep resolving via the slug glob. IDs accrue as new tickets are created.
- **Stub IDs are preserved.** `/pe3-decompose` and `/pf3-decompose` allocate each child's ID at stub time; `/pf1-define` (fleshing a feature stub) and `/e1-start-story` (fleshing a story stub) **preserve** that ID — they do not re-allocate.

---

# Story Artifact Naming

Core naming rules:

- `spec.md`, `context.md`, `implementation_plan.md`, `testing_plan.md`, and `user_test_plan.md` are always baseline v1;
- `spec_vN.md`, `context_vN.md`, `implementation_plan_vN.md`, `testing_plan_vN.md`, `user_test_plan_vN.md` are re-baselined artifacts;
- `active_artifacts.md` is the authoritative pointer once multiple baselines exist;
- `review_vN.md` files are append-only versioned review artifacts;
- `agent_test_session.md` is the required Phase-6 agent-as-user run log; single-baseline (`_vN.md` if re-baselined).

---

# Framework Maintenance

Use the per-phase framework-update commands for changes to canonical framework files. Do not edit live generated files (`CLAUDE.md`, `.claude/`) directly. Edit canonical sources in `shamt-core/`, run regen, run `-Check` against a known-clean child project, verify semantic consistency and generated sizes, then archive the proposal.

---

*Shamt v2 — two roles, one framework, slug-resumable phases.*

---
Validated 2026-05-26 — 5 rounds, 1 adversarial sub-agent confirmed
Touched 2026-05-27 — Part 2 per-phase tier table aligned with `reference/model_selection.md` (Plan validation = Opus; Review split into story-mode / formal-mode issue-finding / formal-mode git metadata). Re-validated under the Phase 2 reference-library validation loop.
