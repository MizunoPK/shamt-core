# Shamt Rules

**Version:** v2 (template)
**Purpose:** Canonical agent rules: story workflow, validation, spec, code review, implementation planning, and the two cross-cutting design principles.

> This file is a **template** rendered into a child project's `CLAUDE.md` (or a managed section of it) at install or regen time. Edit only here, in `shamt-core/templates/`. Generated copies are overwritten; the canonical source is this file.

---

## What is Shamt?

Shamt is a quality framework for AI-assisted development under Claude Code. It defines:

- **5 core patterns** — validation loops, severity classification, spec protocol, code review, implementation planning.
- **Two role flows** — an **Engineer flow** (six-phase story workflow; seven phases when automated testing is enabled) and a **Product Owner flow** (Epic → Feature → Story decomposition).
- **The story** as the handoff artifact between the two roles.
- **A path system inside the Engineer flow** — every story runs the **Quick path** (default, low-ceremony) unless a risk trigger escalates it to the **Standard path**.

The Engineer flow is the load-bearing surface. The PO flow exists for initiatives large enough to warrant top-down decomposition; standalone stories with no parent epic/feature are first-class and run the Engineer flow directly.

Core files:

- `SHAMT_RULES.template.md` — these rules (this file).
- `.shamt-core/CHEATSHEET.md` — host wiring quick reference (commands, skills, personas).
- `reference/` — expanded examples, standards, recipes.
- `templates/` — artifact skeletons.
- `stories/{slug}-{brief-description}/` — per-story artifacts.
- `epics/{slug}-{brief}/`, `features/{slug}-{brief}/` — PO-flow artifacts.
- `.shamt-core/proposals/` — framework-update proposals.
- `.shamt-core/shamt-config.json` — per-project configuration (tracker, testing opt-in, etc.).

---

# Cross-Cutting Design Principles

These two principles apply to **every** multi-phase flow and every artifact-generation flow Shamt defines.

## Principle 1: Phase-per-command + slug resumability

Every multi-phase flow follows this pattern:

1. **One slash command per phase.** No single mega-orchestrator. Each phase is invoked explicitly: `/e1-start-story`, `/e2-define-spec`, `/e3-plan-implementation` are separate commands, not steps inside one `/run-story`.
2. **Every command takes a slug.** `/command {slug}` resolves to a folder via the standard rules (try exact match `{root}/{slug}/`, then glob `{root}/{slug}-*/`, halt if ambiguous, halt if none).
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

---

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

### Quick path map (no automated testing)

| Phase | Artifact | Gate |
|---|---|---|
| 1. Intake | `stories/{slug}-{brief-description}/ticket.md` | User confirms slug + content |
| 2. Compact Spec | `stories/{slug}/spec.md` (Evidence, Code Shapes, Build Checklist, Verification inline) | Gate 2b: user approves spec/checklist |
| 3. Build | code changes | Verification checklist in spec |
| 4. Review | chat/spec summary; `feedback/review_v1.md` only on findings, risk, or user request | Review completed |
| 5. Polish | no-op unless feedback exists | TODO scan passes; feedback handled if present |

### Standard path map (no automated testing)

| Phase | Artifact | Gate |
|---|---|---|
| 1. Intake | `stories/{slug}-{brief-description}/ticket.md` | User confirms slug + content |
| 2. Spec | `stories/{slug}/spec.md` + `stories/{slug}/context.md` | Gate 2a design approval; Gate 2b validated-spec approval |
| 3. Plan | `stories/{slug}/implementation_plan.md` | Gate 3 approved |
| 4. Build | code changes | Verification checklist in plan |
| 5. Review | `stories/{slug}/feedback/review_v1.md` | Review artifact exists after Build |
| 6. Polish | `feedback/addressed_feedback.md` + commits | User signals complete |

### When automated testing is enabled

When `.shamt-core/shamt-config.json` sets `testing: "enabled"`, a **Phase 5: Test** is inserted between Build and Review. Spec gains a **Test Strategy** section (approval-relevant at Gate 2b). Plan produces a `testing_plan.md` alongside `implementation_plan.md`. The Test phase executes the plan via the `test-executor` persona and blocks until all tests pass. Quick-path testing uses an inline checklist in `spec.md` and escalates to a full `testing_plan.md` artifact if test scope >5 steps or introduces a new test file.

### Optional post-Build artifact

After Phase 4 (or Phase 5 when testing is enabled), `/e5b-write-manual-testing-plan {slug}` produces `manual_test_plan.md` for scenarios automated tests cannot exercise (UI behavior, cloud infra, external integrations, multi-user flows). Per-story, on demand — no project-level opt-in.

### Context-clear breakpoints

- **Standard path:** strong breakpoints after Gate 2b and after Gate 3.
- **Quick path:** strong breakpoint after Gate 2b.
- **Advisory** anywhere: before spec validation, after Gate 2b, before plan validation, after Build, after Review.

Resume any phase with the slug-first command: `/e4-execute-plan {slug}`, `/e7-resolve-feedback {slug}`, etc.

---

# Global Story Invariants

Apply across Spec, Plan, Build, Test (when enabled), Review, and Polish:

- **Story folder resolution.** For `{slug}`, resolve the folder using file-based anchors. Try `stories/{slug}/ticket.md` first; if not found, glob `stories/{slug}-*/ticket.md` and derive the folder from the matched path. Multiple matches → halt and ask. No matches → halt and report.
- **Active artifact pointer.** When `stories/{slug}/active_artifacts.md` exists, read it first and use files listed under "Active Files" instead of assuming unversioned names.
- **TODO gate.** TODO comments are allowed only for team-discussion placeholders or temporary debug logging that must be removed before merge. Polish cannot complete while any TODO remains in the implementation plan or code. If `.shamt-core/project-specific-files/CODING_STANDARDS.md` is stricter, follow it.
- **Re-baseline rule.** When a post-approval requirement change makes the active spec or plan misleading, stop and create a new baseline instead of patching the old one in place. See the Re-baseline Protocol below.
- **Story branch baseline rule.** Before creating a story branch in any affected repo, fetch the latest configured development branch and create the feature branch from the fetched remote development branch (e.g., `git fetch origin <development-branch>` then `git checkout -b feature/{slug}/<owner-or-team> origin/<development-branch>`). Do not create story branches from current local HEAD. If the feature branch already exists, halt and report.
- **Standards check.** `.shamt-core/project-specific-files/ARCHITECTURE.md` and `.shamt-core/project-specific-files/CODING_STANDARDS.md` are governing references for artifacts and reviews. Note absence only if either file does not exist.

---

# Part 1: Core Patterns

## Pattern 1: Validation Loops

**Purpose:** Iterative self-review until the artifact meets the quality threshold.

**Exit criteria:**

- **Quick path:** one primary self-review before build and one post-build review against spec/diff. Add an adversarial sub-agent only when a risk trigger applies.
- **Standard path or risk-triggered validation:** primary clean round + 1 independent adversarial sub-agent confirmation.

**Risk triggers:** security / auth / tenant isolation / permissions; database schema, migrations, or backfills; new service or significant module creation; public API or event contracts; multi-repo or multi-deploy ordering; irreversible deletes or destructive edits; payment, billing, regulated, safety-critical, or other high-risk behavior.

### The 8-Step Validation Process

**Step 1 — Read and investigate.** Re-read the entire artifact top-to-bottom each round. Research Pending / Open questions and important claims using code, project docs, and other verifiable sources. Cite evidence for resolved answers; if a product / platform decision is required, say so instead of guessing. Update the artifact with verified answers before Step 2.

**Step 2 — Identify issues across dimensions.** First check alignment with `.shamt-core/project-specific-files/ARCHITECTURE.md` and `.shamt-core/project-specific-files/CODING_STANDARDS.md`.

**Specs (8 dimensions):** Completeness; Correctness; Consistency; Helpfulness; Improvements; Missing proposals; Open questions; Standards/architecture alignment. Hard checks: multi-option designs must give each option explicit pros/cons; Open Questions must first be code-researched and cannot contain answerable file/function/column questions; every applicable review-prevention surface has a spec requirement plus evidence or an explicit N/A or deferred reason; when database schema, tables, or columns are modified or added, the spec must explicitly trace the end-to-end cross-service read and write data lineage of both writes (saving) and reads/queries (loading at runtime), ensuring all backend, admin, and backchannel retrieval paths are accounted for.

**Implementation Plans (8 dimensions):** Step clarity; Mechanical executability; File coverage; Operation specificity; Verification completeness; Dependency ordering; Requirements alignment; Naming clarity. Hard checks: no optional / if / consider executor branches; EDIT steps need exact locate/replace; CREATE steps need concrete paths; imports listed for a file must be used there; every applicable review-prevention gate maps to concrete implementation step(s), verification, or explicit N/A reason.

**Code Reviews (6 dimensions):** Correctness; Completeness; Helpfulness; Severity accuracy; Evidence; Standards/architecture alignment. Hard checks: review every changed file/function/branch independently; do not assume parallel files are identical; review removed or weakened security checks and verify equivalent protection still exists; for tenant/path/object/document access changes, explicitly consider a tenant-A-to-tenant-B bypass.

**General Artifacts (5 dimensions):** Completeness; Clarity; Accuracy; Actionability; Standards/architecture alignment.

**Step 3 — Classify severity.** CRITICAL blocks workflow / causes failure / serious risk. HIGH causes confusion or wrong decisions. MEDIUM noticeably reduces quality. LOW is cosmetic. Borderline cases classify higher.

**Step 4 — Fix all issues immediately.** Do not defer or batch.

**Step 5 — Update `consecutive_clean`.** Clean round = zero issues, or exactly one LOW issue fixed. Not clean = 2+ LOW or any MEDIUM/HIGH/CRITICAL. Clean increments to 1; not clean resets to 0.

**Step 6 — Check exit.** If `consecutive_clean = 0`, return to Step 1. If `consecutive_clean = 1`, run Step 7. If the sub-agent finds any issue, fix it, reset to 0, and return to Step 1.

**Step 7 — Adversarial review.** Spawn one independent adversarial sub-agent using the configured cheap-tier model (Haiku). Prompt contract: identify the artifact and applicable dimensions; require zero-bias, distrust-by-default reread; verify claims from evidence; report any unsupported assertion, hidden assumption, ambiguity, missing dependency, or edge case; if and only if no issue is found, reply exactly `CONFIRMED: Zero issues found after adversarial review.` **Sub-agents have no one-LOW allowance.** See `reference/validation_exit_criteria.md` for expanded examples.

**Step 8 — Add footer.** When complete, append:

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

**Purpose:** Targeted research + design dialog + validated user-facing spec and supporting context.

### The 7-Step Spec Protocol

**Step 1 — Ingest the ticket.** Apply the active-artifact pointer and global story-folder resolution. Read `ticket.md` or provided ticket content. Extract ask, acceptance criteria, links, due dates, and constraints. Output a 3–5 bullet in-agent summary. Do not write to disk yet. If content is empty or missing, halt and ask.

**Step 2 — Targeted research.** Scope research to ticket references, not a broad exploration: grep referenced files / functions / features; read `.shamt-core/project-specific-files/ARCHITECTURE.md` and `.shamt-core/project-specific-files/CODING_STANDARDS.md`; skim related code. Record detailed findings in `context.md` (Standard path) or `spec.md` Evidence (Quick path).

Required research captures:

- **Code shapes:** exact shapes needed for planning.
- **Pre-existing gaps:** when refactoring, document touched gaps; bring into scope or explicitly defer with reason; if none, say so.
- **Current flow:** add an ASCII current-state flow once research is sufficient, unless narrowly in-process (record the N/A reason).
- **Review-prevention risk inventory:** classify whether the story touches regulated/sensitive data, tenant isolation, auth/authorization, route/API contract, DB reads/writes, migrations, new service, monitoring, frontend rendering/auth flow, tests/test data, or removed/weakened checks. Use `reference/pr_review_prevention.md`.
- **Boundary diagram evidence:** Mermaid is required for boundary-crossing stories. During Spec, collect real component/interface names and flow evidence so a Mermaid diagram can be generated against source-backed components. Diagrams cannot be the only place a component appears.
- **File placement:** when shared-utility placement matters, record the governing rule under Architecture And Standards Notes.

**Step 3 — Draft skeletons.**

| Path | Required artifact shape |
|---|---|
| Standard | Create `spec.md` from `templates/spec.template.md` and `context.md` from `templates/context.template.md`. `spec.md` is the approval contract; `context.md` is evidence/planning handoff. Approval-relevant persistence design and review-prevention requirements must appear in `spec.md`, not only `context.md`. Key Design Decision IDs appear in both. |
| Quick | Create `spec.md` only. Populate Evidence, compact Review Prevention Evidence, Code Shapes, Review Prevention Checklist, Build Checklist, and Verification inline. Do not create `context.md` or `implementation_plan.md` unless the story escalates or a risk trigger applies. |

Optional Standard-path plan skeleton: after `spec.md`/`context.md`, create `implementation_plan.md` with exploratory headers only, mark unresolved decisions as `Blocked:`, and set Planning Status to "Blocked on spec (Gate 2a)". Do not fill locate strings until after Gate 2a.

**Step 4 — Architecture/design dialog (Gate 2a).** Present 1–3 design options inline in chat, not in `spec.md` yet. One option is fine when the choice is obvious; 2–3 options are required for non-trivial user-facing forks. Each option needs description, pros, cons, effort (S/M/L), and a recommendation. If an option has no meaningful downside, say so. If open sub-questions exist, use `reference/question_brainstorm_categories.md` and omit empty categories.

Mermaid diagrams are not part of Spec creation. For boundary-crossing stories, record enough approved design-option, workflow, schema, and source-backed component evidence for a later Mermaid generation step. If a Mermaid block already exists in the active story artifacts, treat it as optional supporting material; do not create or update Mermaid during Spec.

Wait for explicit user confirmation before proceeding.

**Step 5 — Flesh out spec/context.** Record the agreed approach. For Standard path, keep `spec.md` concise and approval-facing while `context.md` carries detailed rationale, evidence, current flow, standards notes, and code shapes. For Quick path, keep all of that inline in `spec.md`.

Before placing anything in Open Questions, try to answer it from the codebase. Only product, team, or external-system decisions remain open — and even these are surfaced one at a time via the open-questions iterative-dialog principle.

Add `Review Prevention Gates` after Requirements or Interfaces for applicable regulated/sensitive data, tenant, auth/route, DB, infra, frontend, testing, or removed-check surfaces. For each applicable high-risk surface, state the approval-facing prevention requirement: no regulated or sensitive data in logs / responses / metrics / alarms; tenant identity source and enforcement point; route authorizer/integration expectation; DB writer routing for direct and transitive writes; standard monitoring on new services; tests or verification strategy; replacement/preservation for removed or weakened checks. Standard path stores detailed evidence in `context.md`; Quick path stores compact evidence inline in `spec.md`. If a prevention surface is itself a risk trigger, escalate to Standard path.

Add `Database Schema Changes` after `Interfaces and Boundaries` whenever schema is added or modified or candidate persistence designs need approval. For any schema, migration, or table-level change, the spec must explicitly trace the end-to-end cross-service read and write data lineage across service boundaries to ensure data is not written but ignored or dropped at runtime. If a required backchannel API, query route, or configuration endpoint does not exist yet, the spec must either include its creation as in-scope or list it as a Blocker under Open Questions and escalate for pre-approval vetting at Gate 2a/2b. New tables list columns; existing-table changes list deltas only. Candidate schema options must be reviewable when undecided. Explicitly defer schema changes when out of scope.

Standard path does not add a Files Affected inventory to the spec; file-level work belongs in the plan. Quick path uses Review Prevention Checklist and Build Checklist for files, prevention gates, and sequential mechanical steps. If a parallel plan skeleton exists, resolve all `Blocked:` markers after Gate 2a.

**Step 6 — Validate.**

- **Standard path:** run Pattern 1 on the `spec.md` + `context.md` pair using spec dimensions plus five pair checks: every factual claim in `spec.md` is supported by `context.md`; every Key Design Decision ID appears in both without contradiction; approval-relevant schema/persistence described in `context.md` appears in `spec.md` unless deferred/out of scope; implementation-relevant prevention evidence in `context.md` appears in `spec.md` when approval-relevant; multi-option comparisons give each option explicit pros/cons. Treat schema-only-in-context, approval-relevant prevention-only-in-context, and missing per-option pros/cons as HIGH by default. If an existing Mermaid diagram is recorded in the active story artifacts, verify it renders, every node/edge is supported by research or an approved decision, it does not contradict spec/context, and it conforms to `reference/mermaid_diagram_standards.md`. Exit: primary clean + 1 adversarial sub-agent; footer both files.
- **Quick path:** run Pattern 1 on `spec.md` alone. Validate Requirements, Evidence, Review Prevention Gates/Evidence/Checklist, Code Shapes, Build Checklist, and Verification. One primary clean pass is enough unless a risk trigger requires an adversarial sub-agent. Footer `spec.md`.

Each round ask, "What code should I have read that I haven't?" — and read it.

**Step 7 — User approval (Gate 2b).** Present the validated `spec.md` as the approval artifact and link `context.md` as supporting detail (Standard path). If a new service is in scope, standard monitoring requirements must appear in Requirements or be explicitly Deferred with reason.

## Pattern 4: Code Review Process

**Purpose:** Structured review with validated, copy-paste-ready feedback.

**Story mode:** Review code just built for an active story. Output `stories/{slug}/feedback/review_v1.md` only when findings, risk, or user request require it; re-reviews use `review_v2.md`, etc. No `overview.md`. Before findings, perform Plan Alignment: resolve the active plan, read it alongside the diff, and check Step Coverage, Change Fidelity, Scope Discipline, Verification Passage, and Zero Builder Design Decisions. Write `## Plan Alignment` at the top of the review. If no plan exists (Quick path), record N/A. Story-mode validation uses 7 dimensions (the 7th is Plan Alignment).

**Formal mode:** Review someone else's branch or PR. Never check out the branch; use read-only `git fetch`, `merge-base`, `log`, and `diff`. Resolve the review base in this order: explicit user-provided base; active PR target branch when available; project default formal-review base from `.shamt-core/project-specific-files/ARCHITECTURE.md`; repository default branch otherwise. Fetch base and target branch read-only, then diff against the fetched remote base (e.g., `origin/<base>...<feature-branch>`). If fetch fails or base/branch cannot be resolved, halt and report. Output `code_reviews/<sanitized-branch>/overview.md` + `review_vN.md`.

### Formal steps

1. Fetch branch metadata read-only. When reviewing the current local feature branch, run `git status --short` first; if uncommitted changes exist, halt and ask whether to include, stash, commit, or ignore them. Gather commits, name-status, diff stats, and full diff against the fetched base. Create a changed-file inventory grouped by type before findings.
2. Create `code_reviews/<sanitized-branch>/`.
3. Write `overview.md` with ELI5, What, Why, How sections.
4. Validate overview with Pattern 1 general dimensions; footer it.
5. Read full changed files where surrounding context controls the finding — logging, exception handling, function decomposition, auth, tenant isolation, state/token handling, database routing, monitoring. Write review output with Summary, Verdict, Degree of Risk, Changed File Inventory, Blockers, Required Changes, Suggestions, Monitoring Checklist, Security Checklist, Positive Notes, and findings grouped by severity then category. Severities: BLOCKING, CONCERN, SUGGESTION, NITPICK.
6. Validate review with Pattern 1 review dimensions; footer it.
7. On re-review, create the next `review_vN.md` without overwriting. In story mode, write inside `stories/{slug}/feedback/`; in formal mode, keep using `code_reviews/<branch>/`. If `active_artifacts.md` exists, add `Baseline reviewed: vN`. v2 does not post formal-mode reviews back to external trackers — the artifact stays local; the user posts manually if desired.

Every review must consider all 16 categories even when no finding is recorded: Correctness, Security, Performance, Maintainability, Testing, Edge Cases, Naming, Documentation, Error Handling, Concurrency, Dependencies, Architecture, CSS Scope, State Ownership, Response Field Uniformity, Monitoring. Use `reference/review_categories.md` for mechanical checks and finding format.

## Pattern 5: Implementation Planning

**Purpose:** Create mechanical plans that separate planning from execution.

The Quick path skips `implementation_plan.md` by default and executes the spec Build Checklist directly. Escalate to a full plan if the checklist exceeds 10 steps, a builder sub-agent is needed, exact locate/replace details are necessary, verification is complex, or the user asks for Gate 3 planning.

The Standard path requires a validated implementation plan after spec approval and before Build.

### The 5-Step Process

**Step 1 — Read spec/context and confirm decisions.** Apply active artifacts and global story-folder resolution. Read the active spec/context completely. Research repo conventions for file placement, sibling shapes, naming, and deployment. For new services, add the standard monitoring template to the manifest, verify outbound auth from siblings, and confirm required configuration. For EDIT steps, look up only the 5–10 lines around each target symbol; use code shapes recorded in `context.md` / Quick-path `spec.md`.

**Step 2 — Create the mechanical plan.** Use `templates/implementation_plan.template.md`. Every step must be executable without design judgment.

**Required plan contract:**

- no optional branches, vague gates, unresolved `if / when / consider`, or executor judgment;
- stop planning if implementation is unclear;
- verification failure is stop-and-escalate, not permission to improvise;
- plans over one deploy boundary, any phase over 10 steps, or about 1500+ lines require a validated index plus validated phase files;
- plans touching multiple repos include `Step 0-A`, `Step 0-B`, etc.; each branch-prep step must fetch the configured remote development branch and create `feature/{slug}/<owner-or-team>` from the fetched remote branch; commit `#{slug}: {message}`;
- include metadata, pre-execution checklist, files manifest with no optional rows, review-prevention gate mapping, numbered steps, verification, Notes, and `CODING_STANDARDS` compliance mapping.

**Operation contracts:**

- **CREATE:** concrete workspace-relative path plus full initial content or named in-repo template/copied sibling with concrete deltas.
- **EDIT:** exact locate string plus exact replacement.
- **DELETE:** file/section plus justification.
- **MOVE:** separate create and delete sub-steps, each verified.

**Hard planning checks:**

- Every applicable review-prevention item from spec/context maps to concrete implementation step(s), verification step(s), or explicit N/A reason before validation.
- DB write paths: trace direct and transitive writes and plan the writer routing decision before any build step proceeds.
- New or changed services / routes: require manifest coverage or explicit N/A for handler, application module, route module, monitoring template, packaging, environment, IAM/secrets, log retention, networking, and deployment/stage updates.
- Tenant / path / object / document changes: plan a tenant-A-to-tenant-B bypass verification when feasible, or state why it cannot be run.
- Removed/weakened checks: include replacement analysis before the code-edit step.
- New service handlers: enumerate transitive call graph for imported shared utilities, reachable environment-variable keys, and reachable external resource accesses before drafting environment/IAM steps; add missing symbols/env/IAM steps before proceeding.
- Byte-for-byte copy files: before adding a function to a shared copy file, verify every called function has identical signature/behavior in every repo maintaining that file. If any dependency differs, place the function repo-specifically and record why.
- `.shamt-core/project-specific-files/CODING_STANDARDS.md`: map each applicable rule to an existing step, new step, or explicit N/A in `## CODING_STANDARDS Compliance`; merely saying it was read is insufficient.
- Migration CREATE steps: cover table creation, any required row-level security policy in the same block, and information-schema verification. See `reference/implementation_plan_reference.md` for expanded examples.

Skeleton-first authoring is recommended for plans with 5+ steps: write all headers, sanity-check structure, then fill locate strings and verification just-in-time.

**Step 3 — Validate plan.** Run Pattern 1 using the 8 plan dimensions. Exit: primary clean + 1 adversarial sub-agent. Add footer.

**Step 4 — Hand off to builder.** In the Standard path, builder handoff is unconditional after Gate 3. Single-file plans hand off `implementation_plan.md`; phase-decomposed plans hand off one phase at a time in deploy order. In the Quick path, the primary agent executes the Build Checklist unless delegation is explicitly requested.

**Builder contract:** follow steps exactly, execute sequentially, run specified verification, and stop on failed verification or ambiguity. Expected reports: `All steps completed. Verification passed.`, `Step N failed: ...`, `Step N is ambiguous: ...`, `Plan defect at Step N: ...`. Builder model: cheap-tier (Haiku).

**Step 5 — Verify completeness.** Test against spec requirements, verify no unintended side effects, confirm all verifications passed. If the builder reports failure or ambiguity, diagnose, fix the plan, and re-hand off.

---

# Part 2: Token Discipline & Model Selection

Shamt treats token cost as a design constraint. Every flow / persona / phase has a recommended model tier; cheap-tier is used wherever the task is mechanical or zero-bias.

## Operational rules

- Use the **Quick path** for ≤10 low-risk steps to avoid unnecessary `context.md`, `implementation_plan.md`, clean `review_v1.md`, and no-op `addressed_feedback.md`.
- Generated host skills should route to canonical rules/templates rather than duplicate full protocol text.
- Read `.shamt-core/project-specific-files/ARCHITECTURE.md` and `.shamt-core/project-specific-files/CODING_STANDARDS.md` once during research, record story-specific standards digest inline, and reuse the digest.
- The Standard-path mechanical Build is executed by the cheap-tier builder persona; the architect plans, the builder executes.
- Adversarial review confirmations always use cheap-tier (Haiku), with no one-LOW allowance.
- Strong context clears: after Gate 2b and after Gate 3.

## Default tier mapping

| Tier | Model | When to use |
|------|-------|-------------|
| **Cheap** | Haiku | File ops, git ops, mechanical execution, sub-agent confirmations, status rollups, intake / freeform ticket capture, test execution |
| **Balanced** | Sonnet | Code reading, structural analysis, spec research, plan creation, medium-complexity validation, formal-mode code-review metadata, manual-testing-plan authoring |
| **Reasoning** | Opus | Primary validation loops (artifact validation), root-cause analysis, design decisions, multi-dimensional checks, formal-mode review issue-finding, design dialog (Gate 2a), epic/feature decomposition |

Sub-agent confirmations **always** use Cheap tier — these are zero-bias re-reads, not deep reasoning.

## Recommended models per phase (Engineer flow)

| Phase | Model |
|-------|-------|
| 1. Intake | Haiku |
| 2. Spec — research | Sonnet |
| 2. Spec — design dialog (Gate 2a) | Opus |
| 2. Spec — validation | Opus |
| 3. Plan — authoring | Sonnet |
| 3. Plan — validation | Opus |
| 4. Build — Quick path | Sonnet |
| 4. Build — Standard path (mechanical) | Haiku (`plan-executor` persona) |
| 5. Test (when enabled) | Haiku (`test-executor` persona) |
| 6. Review — story-mode | Sonnet |
| 6. Review — formal-mode issue-finding | Opus (`review-executor` persona) |
| 6. Review — formal-mode git metadata | Haiku |
| 7. Polish — code edits | Sonnet |
| 7. Polish — root cause / upstream proposals | Opus |

Personas can override the global table per their definition (see `host/templates/claude/`).

---

# Part 3: Engineer Flow — Phase Narratives

Compact phase reference. For each phase: purpose, minimum viable artifact, key gate, recommended model.

**Phase 1: Intake.** Capture the ticket and establish the story folder. Ask for slug; resolve optional issue-tracker ID per `.shamt-core/shamt-config.json`; derive a 2–4 word brief description; check for slug collision; fetch tracker payload or capture manual content; confirm. Minimum viable: non-empty `ticket.md`. Gate: user confirms slug and content. Model: Haiku.

**Phase 2: Spec.** Run the full 7-step Spec Protocol (Pattern 3). Apply the active-artifact pointer before reading story artifacts. Quick path: compact `spec.md` with Evidence, Code Shapes, Build Checklist, Verification inline. Standard path: `spec.md` (approval) + `context.md` (evidence). Validate per Pattern 1. Gate 2a: design approval. Gate 2b: validated-spec approval. Models: Sonnet (research), Opus (dialog + validation).

**Phase 3: Plan.** Standard path only — Quick path skips this phase. Run the full 5-step Plan contract (Pattern 5). Reconcile `## Review Prevention Gates` from spec/context into `## Review Prevention Gate Mapping`. Every step must be mechanical; no unresolved design decisions remain. Multi-repo plans use `Step 0-A`, `Step 0-B`, etc. with branch-baseline steps. Gate 3: validated-plan approval. Model: Sonnet.

**Phase 4: Build.** Execute the approved Build Checklist (Quick) or implementation plan (Standard). Standard path hands off to the `plan-executor` persona — the architect does not execute the plan itself. Quick path: the primary agent executes the Build Checklist directly. On failed verification or ambiguity, Standard path patches the plan and re-hands off; Quick path investigates and fixes inline. Post-execution: verify changes against spec requirements and review-prevention gates. Gate: verification checklist passes. Model: Haiku (Standard mechanical) or Sonnet (Quick direct-build).

**Phase 5: Test (when `testing: "enabled"`).** Execute the testing plan via the `test-executor` persona. Run the project's test suite, perform e2e scenarios, record results in `testing_plan.md`. Diagnose failures; distinguish story failures from infrastructure flakiness. **Phase 5 blocks until all tests pass** — no exceptions or documented deferrals. Skipped entirely when testing is disabled. Model: Haiku.

**Phase 6: Review.** Pattern 4 in story mode (or formal mode for external branches/PRs). Quick path: chat/spec summary; `feedback/review_v1.md` only on findings, risk, or user request. Standard path: `review_v1.md` is mandatory, even when it only says "No issues found." Story-mode review includes the Plan Alignment pre-pass and a Documentation Impact Assessment (does this change require an `.shamt-core/project-specific-files/ARCHITECTURE.md` or `.shamt-core/project-specific-files/CODING_STANDARDS.md` update? If yes, the update is part of Polish). Models: Opus (issue-finding via `review-executor`), Haiku (git metadata).

**Phase 7: Polish.** Apply reviewer feedback and capture generalizable lessons. Inventory `stories/{slug}/feedback/` at the start of every Polish pass. Track comment handling in `addressed_feedback.md` when feedback exists. Process comments one by one: understand, fix or disposition, verify, reflect on root cause, accumulate. Root-cause proposals that generalize beyond the current story route through the framework-update flow at `.shamt-core/proposals/{slug}.md` rather than direct edits. If Phase 6 flagged a doc-impact change, Polish applies the update and re-validates the doc. Polish cannot complete while any tracked comment remains `Pending` or `Needs user decision` (unless explicitly deferred). Models: Sonnet (fixes), Opus (root cause).

---

# Requirement Re-baseline Protocol

Use a re-baseline when a large requirement change arrives after Gate 2b, Gate 3, or Build execution and the active spec or plan would become misleading.

**Triggers include:**

- accepted behavior changes materially;
- the implementation plan needs substantial replacement;
- code already changed under the superseded plan must be accounted for;
- a new architecture, data flow, API contract, persistence shape, or deployment boundary appears;
- the team would reasonably ask which spec or plan is current.

### Re-baseline contract

1. Stop the current phase.
2. State whether the change is minor or a re-baseline.
3. Determine the next version number.
4. Create `spec_vN.md` and `context_vN.md`, carrying forward only still-valid material.
5. Record prior baseline and current code state in `context_vN.md`.
6. Validate the new spec/context pair.
7. Create `implementation_plan_vN.md` and any phase files needed.
8. Validate the new plan.
9. Create or update `active_artifacts.md` from `templates/active_artifacts.template.md`.
10. Resume at Gate 2b, then Gate 3, then continue the workflow.

Unversioned names remain baseline v1. Do not rename or overwrite them.

---

# Story Artifact Naming

Core naming rules:

- `spec.md`, `context.md`, `implementation_plan.md`, and `testing_plan.md` are always baseline v1;
- `spec_vN.md`, `context_vN.md`, `implementation_plan_vN.md`, `testing_plan_vN.md` are re-baselined artifacts;
- `active_artifacts.md` is the authoritative pointer once multiple baselines exist;
- `review_vN.md` files are append-only versioned review artifacts;
- `manual_test_plan.md` is single-baseline; if re-baselined, follow the same `_vN.md` convention.

---

# Framework Maintenance

Use the per-phase framework-update commands for changes to canonical framework files. Do not edit live generated files (`CLAUDE.md`, `.claude/`) directly. Edit canonical sources in `shamt-core/`, run regen, run `-Check` against a known-clean child project, verify semantic consistency and generated sizes, then archive the proposal.

---

*Shamt v2 — two roles, one framework, slug-resumable phases.*

---
Validated 2026-05-26 — 5 rounds, 1 adversarial sub-agent confirmed
Touched 2026-05-27 — Part 2 per-phase tier table aligned with `reference/model_selection.md` (Plan validation = Opus; Review split into story-mode / formal-mode issue-finding / formal-mode git metadata). Re-validated under the Phase 2 reference-library validation loop.
