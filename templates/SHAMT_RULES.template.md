# Shamt Rules

**Version:** v2 (template)
**Purpose:** Canonical agent rules: story workflow, validation, spec, code review, implementation planning, and the two cross-cutting design principles.

> This file is a **template** rendered into a child project's `CLAUDE.md` (or a managed section of it) at install or regen time. Edit only here, in `shamt-core/templates/`. Generated copies are overwritten; the canonical source is this file.

---

## What is Shamt?

Shamt is a quality framework for AI-assisted development under Claude Code. It defines:

- **5 core patterns** — validation loops, severity classification, spec protocol, code review, implementation planning.
- **Two role flows** — an **Engineer flow** (Quick path 7 phases / Standard path 8 phases — testing is a **required** phase) and a **Product Owner flow** (Epic → Feature → Story decomposition).
- **The story** as the handoff artifact between the two roles.
- **A path system inside the Engineer flow** — every story runs the **Quick path** (default, low-ceremony) unless a risk trigger escalates it to the **Standard path**.

The Engineer flow is the load-bearing surface. The PO flow exists for initiatives large enough to warrant top-down decomposition. There are no top-level orphans: every feature nests under an epic and every story under a feature (see §PO-tree resolution). One-off / standalone work (bugs, quick wins, tech stories) lives under the standing **Tech Stories** epic and runs the Engineer flow from there. Within the PO flow, **decomposition catalogs breadth-context** (a bounded `## Decomposition Context` plus each child's breadth boundary — `## Scope / Non-Scope` for a feature, a scope one-liner for a story) and **define-\* deepens depth** from that seed before its terminal gate — see the `/pe2-decompose`/`/pf2-decompose` decompose and `/pf1-define`/`/e1` define command bodies for per-altitude detail.

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

These two principles apply to **every** multi-phase flow and every artifact-generation flow Shamt defines.

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

### Testing (Phase 5 — required)

**Phase 5 (Test)** is **required** on every story and **blocks until green**: the `user-simulator` persona
drives the project per `TESTING_STANDARDS.md` (source of truth; no `testing` flag), writing
`agent_test_session.md`, plus the **automated** `testing_plan.md` when that doc declares suites. A failure
routes to `/e7-resolve-feedback` with a **required root-cause section** (which of Spec/Plan/Build let it
through + the prevention). Full detail in [`reference/testing.md`](reference/testing.md).

### Optional post-Build artifact

Manual-test-plan detail: see [`reference/testing.md`](reference/testing.md).

### Context-clear breakpoints

- **Standard path:** strong breakpoints after Gate 2b and after Gate 3.
- **Quick path:** strong breakpoint after Gate 2b.
- **Advisory** anywhere: before spec validation, after Gate 2b, before plan validation, after Build, after Review.

### Finalize phase (terminal)

Both role flows end with a **Finalize** command modelled on `/f6-archive-proposal`, each behind explicit user confirmation (per-tracker and clean-tree mechanics in the command bodies):

- **`/e8-finalize-story {slug}`** — the Engineer flow's terminal phase: commits the story's work as a scoped unit (clean-tree guard), confirms prior phases complete (Test PASSes — required; Review + feedback resolved), marks the work item done via the active tracker, and writes `**Status: Done**` into `ticket.md` — the profile-independent signal the status line reads.
- **`/pe3-finalize {slug}`** — the PO flow's terminal command at the Epic altitude: after confirming every child feature/story is finalized, marks the epic done and **moves the epic folder into `epics/archive/`** as a **whole-subtree move** (features/stories ride along — parentage is the path, nothing dangles). There is no per-feature finalize command (features close implicitly when their stories are done); `epics/archive/` is excluded from active-epic status-line resolution.

### §PO-tree resolution

The PO hierarchy nests — features under their epic, stories under their feature:

```
epics/{ID}-{epic-slug}-{brief}/
  epic.md
  features/{ID}-{feature-slug}-{brief}/
    feature.md
    stories/{ID}-{story-slug}-{brief}/
      ticket.md, spec.md, implementation_plan.md, feedback/, raw/, ...
```

Slug-first commands resolve a folder by a **tree-wide glob with a legacy-flat fallback** (slugs are globally unique, so the `{slug}-*` tail is unambiguous; exactly one match — halt on zero or multiple):

- **Epic** (top-level): `epics/{ID}-*/` · `epics/{slug}-*/` · `epics/*-{slug}-*/`.
- **Feature**: `epics/*/features/{ID}-*/` · `epics/*/features/{slug}-*/` · `epics/*/features/*-{slug}-*/`; legacy fallback `features/{slug}-*/`.
- **Story**: `epics/*/features/*/stories/{ID}-*/` · `…/stories/{slug}-*/` · `…/stories/*-{slug}-*/`; legacy fallback `stories/{slug}-*/`.

New work is **written nested**; pre-existing flat folders stay and resolve via the fallback (no migration). Parentage is encoded by the path — there are **no `**Parent Epic:**` / `**Parent Feature:**` back-ref headers**. Throughout command / skill / template / reference bodies, `epics/{slug}/`, `features/{slug}/`, `stories/{slug}/` denote **the resolved folder** (per the globs above; leaf still `…-{brief}/`). **Work root:** all bare `epics/`/`features/`/`stories/`/`code_reviews/`/`shamt-state/` paths are **work-root-relative** — repo root on self-host, `.shamt-core/` in a child (resolve the work root once via `.shamt-core/`-presence before globbing/writing). A child writes work-tree artifacts only under `.shamt-core/`; its project root holds only `CLAUDE.md` + `.claude/`.

**Active-item pointers.** The status line reads `{work-root}/shamt-state/active-{epic,feature,story}` (`.shamt-core/shamt-state/` in a child), each holding the active item's **work-root-relative** nested path (parentage = walk it up). The `p*`/`e1` commands write/refresh the matching pointer as work advances; `import-shamt` preserves them (outside its sync set).

### Standing Tech Stories epic

The standing **Tech Stories** epic (introduced above) is the home for one-off work — bug fixes and small standalone improvements — that strict nesting has no top-level place for.

- **Standing fixtures, fixed reserved names.** `epics/{tech-stories-folder}/` holds two standing features, **Bugs** and **Quick Wins**, under fixed reserved folder names (`tech-stories`, `bugs`, `quick-wins`) — *not* the `{ID}-{slug}-{brief}` convention, since they carry no ticket ID. Seeded once (create-if-absent) by the install/sync flow (`init-shamt.sh` / `import-shamt.sh`), never per-initiative by `/pe1-define`; their globally-unique reserved slugs make the existing collision checks refuse any reuse.
- **Local-only, tracker-agnostic.** The standing epic + features never map to tracker work items — only the tickets filed under them do, per the active profile (a bug = a GitHub issue / ADO bug).
- **Entry + archive.** `/ps0-draft [bugs|quick-wins]` seeds a ticket stub under the chosen feature and hands to `/e1-start-story` (bypassing the `/pe1-define`→`/pf2-decompose` cascade); on finalize, `/e8-finalize-story` moves the folder into the feature's `archive/`. See those command bodies for the mechanics.

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

**Exit criteria:**

- **Quick path:** one primary self-review before build and one post-build review against spec/diff. Add an adversarial sub-agent only when a risk trigger applies.
- **Standard path or risk-triggered validation:** primary clean round + 1 independent adversarial sub-agent confirmation.

**Risk triggers:** security / auth / tenant isolation / permissions; database schema, migrations, or backfills; new service or significant module creation; public API or event contracts; multi-repo or multi-deploy ordering; irreversible deletes or destructive edits; payment, billing, regulated, safety-critical, or other high-risk behavior.

### The 8-Step Validation Process

**Step 1 — Read and investigate.** Re-read the entire artifact top-to-bottom each round. Research Pending / Open questions and important claims using code, project docs, and other verifiable sources. Cite evidence for resolved answers; if a product / platform decision is required, say so instead of guessing. Update the artifact with verified answers before Step 2.

**Step 2 — Identify issues across dimensions.** First check alignment with `.shamt-core/project-specific-files/ARCHITECTURE.md` and `.shamt-core/project-specific-files/CODING_STANDARDS.md`.

**Specs (8 dimensions):** Completeness; Correctness; Consistency; Helpfulness; Improvements; Missing proposals; Open questions; Standards/architecture alignment. Hard checks per Pattern 3: multi-option pros/cons, Open-Questions-answered-from-code, review-prevention inventory, and the schema data-lineage trace.

**Implementation Plans (8 dimensions):** Step clarity; Mechanical executability; File coverage; Operation specificity; Verification completeness; Dependency ordering; Requirements alignment; Naming clarity. Hard checks per Pattern 5: no optional/if/consider branches, exact locate/replace, concrete CREATE paths, review-prevention-gate mapping; plus imports listed for a file must be used there.

**Code Reviews (6 dimensions):** Correctness; Completeness; Helpfulness; Severity accuracy; Evidence; Standards/architecture alignment. Hard checks per `reference/review_categories.md`: review every changed file/function/branch independently (do not assume parallel files are identical); boundary analysis + tenant-A→B bypass tracing for removed/weakened checks and tenant/path/object/document access changes.

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

**Purpose:** Targeted research + design dialog + validated user-facing spec and supporting context. (The exact spec-template section placement — which section follows which — lives in the `/e2-define-spec` command body + `templates/spec.template.md`; this Pattern is the normative contract.)

### The 7-Step Spec Protocol

**Step 1 — Ingest the ticket.** Apply the active-artifact pointer and global story-folder resolution. Read `ticket.md` (or provided content); extract ask, acceptance criteria, links, due dates, constraints; output a 3–5 bullet in-agent summary; do not write to disk yet. Empty/missing content → halt and ask.

**Step 2 — Targeted research.** Scope to ticket references, not broad exploration: grep referenced files/functions/features; read `.shamt-core/project-specific-files/ARCHITECTURE.md` + `CODING_STANDARDS.md`; skim related code. Record findings in `context.md` (Standard) or `spec.md` Evidence (Quick). Required captures — **code shapes**, **pre-existing gaps**, **current flow**, **review-prevention risk inventory**, **boundary-diagram evidence**, and **file placement** — each enumerated in `reference/spec_protocol_reference.md` (which routes the risk inventory to `reference/pr_review_prevention.md`).

**Step 3 — Draft skeletons.**

| Path | Required artifact shape |
|---|---|
| Standard | `spec.md` (from `templates/spec.template.md`) + `context.md` (from `templates/context.template.md`). `spec.md` is the approval contract; `context.md` is evidence/planning handoff. Approval-relevant persistence design and review-prevention requirements must appear in `spec.md`, not only `context.md`. Key Design Decision IDs appear in both. |
| Quick | `spec.md` only — populate Evidence, compact Review Prevention Evidence, Code Shapes, Review Prevention Checklist, Build Checklist, and Verification inline. Do not create `context.md` or `implementation_plan.md` unless the story escalates or a risk trigger applies. |

Optional Standard-path plan skeleton: after `spec.md`/`context.md`, create `implementation_plan.md` with exploratory headers only, mark unresolved decisions `Blocked:`, set Planning Status to "Blocked on spec (Gate 2a)"; do not fill locate strings until after Gate 2a.

**Step 4 — Architecture/design dialog (Gate 2a).** Present 1–3 design options inline in chat, not in `spec.md` yet: one option is fine when the choice is obvious, 2–3 are required for non-trivial user-facing forks; each needs description, pros, cons, effort (S/M/L), and a recommendation (if an option has no meaningful downside, say so). For open sub-questions, use `reference/question_brainstorm_categories.md` and omit empty categories. Mermaid diagrams are not part of Spec creation — for boundary-crossing stories, record enough approved design-option, workflow, schema, and source-backed component evidence for a later Mermaid generation step; an existing Mermaid block is optional supporting material, do not create or update it during Spec. **Wait for explicit user confirmation before proceeding.**

**Step 5 — Flesh out spec/context.** Record the agreed approach into the Step 3 artifacts (Standard: approval-facing `spec.md` + detailed `context.md`; Quick: all inline in `spec.md`). Before placing anything in Open Questions, answer it from the codebase — only product/team/external-system decisions remain open, surfaced one at a time (Principle 2). For each applicable high-risk surface state the approval-facing **prevention requirement**, and if a prevention surface is itself a risk trigger escalate to Standard path. For any schema, migration, or table-level change the spec must trace the end-to-end cross-service read **and** write data lineage across service boundaries (so data is not written but ignored at runtime), including any missing backchannel API / query route / config endpoint as in-scope **or** listing it a Blocker for Gate 2a/2b vetting. The per-surface prevention requirements, the schema/lineage rules (column/delta listing, reviewable candidate options, explicit deferral), and the path-specific spec/context split are enumerated in `reference/spec_protocol_reference.md`. Resolve all parallel-skeleton `Blocked:` markers after Gate 2a.

**Step 6 — Validate.**

- **Standard path:** run Pattern 1 on the `spec.md` + `context.md` pair using spec dimensions plus five pair checks — every factual claim in `spec.md` is supported by `context.md`; every Key Design Decision ID appears in both without contradiction; approval-relevant schema/persistence in `context.md` appears in `spec.md` unless deferred/out of scope; implementation-relevant prevention evidence in `context.md` appears in `spec.md` when approval-relevant; multi-option comparisons give each option explicit pros/cons. Treat schema-only-in-context, approval-relevant prevention-only-in-context, and missing per-option pros/cons as HIGH by default. If a Mermaid diagram is recorded in the active artifacts, verify it renders, every node/edge is research- or decision-backed, it does not contradict spec/context, and it conforms to `reference/mermaid_diagram_standards.md`. Exit: primary clean + 1 adversarial sub-agent; footer both files.
- **Quick path:** run Pattern 1 on `spec.md` alone (Requirements, Evidence, Review Prevention Gates/Evidence/Checklist, Code Shapes, Build Checklist, Verification); one primary clean pass is enough unless a risk trigger requires an adversarial sub-agent; footer `spec.md`.

Each round ask, "What code should I have read that I haven't?" — and read it.

**Step 7 — User approval (Gate 2b).** Present the validated `spec.md` as the approval artifact and link `context.md` as supporting detail (Standard path). If a new service is in scope, standard monitoring requirements must appear in Requirements or be explicitly Deferred with reason.

## Pattern 4: Code Review Process

**Purpose:** Structured review with validated, copy-paste-ready feedback.

**Story mode:** Review code just built for an active story. Output `stories/{slug}/feedback/review_v1.md` only when findings, risk, or user request require it; re-reviews use `review_v2.md`, etc. No `overview.md`. Before findings, perform Plan Alignment: resolve the active plan, read it alongside the diff, and check Step Coverage, Change Fidelity, Scope Discipline, Verification Passage, and Zero Builder Design Decisions. Write `## Plan Alignment` at the top of the review. If no plan exists (Quick path), record N/A. Story-mode validation uses 7 dimensions (the 7th is Plan Alignment).

**Formal mode:** Review someone else's branch or PR. Never check out the branch; use read-only `git fetch`, `merge-base`, `log`, and `diff`. Resolve the review base in this order: explicit user-provided base; active PR target branch when available; project default formal-review base from `.shamt-core/project-specific-files/ARCHITECTURE.md`; repository default branch otherwise. Fetch base and target branch read-only, then diff against the fetched remote base (e.g., `origin/<base>...<feature-branch>`). If fetch fails or base/branch cannot be resolved, halt and report. Output `code_reviews/<sanitized-branch>/overview.md` + `review_vN.md`.

### Formal steps

The formal-mode procedure is executed by the `review-executor` persona (full steps in that agent body + the `/e6-review-changes` command): a read-only fetch with a changed-file inventory (halt-and-ask on uncommitted local changes), a validated `overview.md` (ELI5 / What / Why / How), then `review_vN.md` — deep reading of files whose surrounding context controls the finding (logging, exception handling, auth, tenant isolation, state/token handling, DB routing, monitoring), the required review sections (Summary, Verdict, Degree of Risk, Changed File Inventory, Blockers, Required/Suggested Changes, Monitoring + Security Checklists, Positive Notes), and findings grouped by severity then category at **BLOCKING / CONCERN / SUGGESTION / NITPICK** — each artifact validated with Pattern 1. Re-reviews create the next `review_vN.md` without overwriting (add `Baseline reviewed: vN` when `active_artifacts.md` exists). v2 does not post formal-mode reviews back to external trackers — the artifact stays local; the user posts manually if desired.

Every review must consider all 16 categories even when no finding is recorded; the category list, the mechanical checks, and the finding format all live in `reference/review_categories.md`.

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
- plans touching multiple repos include `Step 0-A`, `Step 0-B`, etc. (one per repo); each branch-prep step follows the **Story branch baseline rule** above (fetch the remote development branch, create `feature/{slug}/<owner-or-team>` from it); commit `#{slug}: {message}`;
- include metadata, pre-execution checklist, files manifest with no optional rows, review-prevention gate mapping, numbered steps, verification, Notes, and `CODING_STANDARDS` compliance mapping.

**Operation contracts:**

- **CREATE:** concrete workspace-relative path plus full initial content or named in-repo template/copied sibling with concrete deltas.
- **EDIT:** exact locate string plus exact replacement.
- **DELETE:** file/section plus justification.
- **MOVE:** separate create and delete sub-steps, each verified.

**Hard planning checks** (each maps to a concrete step, a verification, or an explicit N/A before validation). Six checks have expanded per-check detail in `reference/implementation_plan_reference.md` — **review-prevention coverage**, **DB write routing** (direct **and** transitive writes, writer routing decided before any build step), **new-service/route manifest coverage** (handler, application/route modules, monitoring, packaging, environment, IAM/secrets, log retention, networking, deployment/stage — or N/A), **tenant-A-to-tenant-B bypass verification**, **removed/weakened-check replacement analysis** before the code-edit step, and **migration CREATE coverage** (table creation, row-level-security policy in the same block, information-schema verification). Three checks stay stated here:

- new service handlers enumerate the transitive call graph for imported shared utilities, reachable environment-variable keys, and reachable external-resource accesses, adding missing symbol/env/IAM steps before proceeding;
- byte-for-byte copy files verify every called function has identical signature/behavior in every repo maintaining that file (else place the function repo-specifically and record why);
- each applicable `.shamt-core/project-specific-files/CODING_STANDARDS.md` rule maps to a step or explicit N/A in `## CODING_STANDARDS Compliance` (saying it was read is insufficient).

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

## Default tier mapping

| Tier | Model | When to use |
|------|-------|-------------|
| **Cheap** | Haiku | File ops, git ops, mechanical execution, sub-agent confirmations, status rollups, intake / freeform ticket capture, test execution |
| **Balanced** | Sonnet | Code reading, structural analysis, spec research, plan creation, medium-complexity validation, formal-mode code-review metadata, manual-testing-plan authoring |
| **Reasoning** | Opus | Primary validation loops (artifact validation), root-cause analysis, design decisions, multi-dimensional checks, formal-mode review issue-finding, design dialog (Gate 2a), epic/feature decomposition |

Sub-agent confirmations **always** use Cheap tier — these are zero-bias re-reads, not deep reasoning.

## Recommended models per phase (Engineer flow)

The per-phase model tiers for the Engineer flow live in `reference/model_selection.md` (the authoritative table). Personas can override per their definition (see `host/templates/claude/`).

---

# Part 3: Engineer Flow — Phase Narratives

Each phase's purpose, minimum-viable artifact, gate, recommended model, and per-phase invariants live authoritatively in its **command body** — `/e1-start-story`, `/e2-define-spec`, `/e3-plan-implementation` (+ `/e3b-write-testing-plan`), `/e4-execute-plan`, `/e5-execute-tests`, `/e6-review-changes`, `/e7-resolve-feedback` (under `host/templates/claude/commands/`). Gates are summarized in the Quick / Standard path-map tables above; per-phase model tiers are in `reference/model_selection.md`. Resume any phase with its slug-first command (e.g. `/e4-execute-plan {slug}`).

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

# Ticket IDs

Every epic, feature, and story is a **ticket** with a short, globally-unique **ticket ID** of the form `T{N}` (`T1`, `T2`, …) used alongside its slug. The ID prefixes the folder — `epics/{ID}-{slug}-{brief}/`, `features/{ID}-{slug}-{brief}/`, `stories/{ID}-{slug}-{brief}/` — mirroring the `proposals/{NN}-{slug}.md` convention.

- **Allocation.** A new ticket's ID is `max(existing T-number across the whole epic/feature/story tree) + 1` — **scanned from disk** (parse a leading `^T([0-9]+)-` run on each epic/feature/story folder name, walking the nested tree under `epics/` plus any legacy flat folders), **no counter file**, never reused. The sequence is **global** (one space across all ticket types — an epic might be `T1`, its feature `T2`, a story `T3`) and **flat** (an ID does not encode its parent). A project with only slug-only folders allocates `T1` first.
- **Addressing.** Commands accept either the ID or the slug, resolved per §PO-tree resolution (tree-wide glob matching the ID or slug at the appropriate altitude anywhere in the nested tree, with the legacy-flat fallback).
- **New-tickets-only.** Existing slug-only folders are **not** renamed; they keep resolving via the slug glob. IDs accrue as new tickets are created.
- **Stub IDs are preserved.** `/pe2-decompose` and `/pf2-decompose` allocate each child's ID at stub time; `/pf1-define` (fleshing a feature stub) and `/e1-start-story` (fleshing a story stub) **preserve** that ID — they do not re-allocate.

---

# Story Artifact Naming

Core naming rules:

- `spec.md`, `context.md`, `implementation_plan.md`, and `testing_plan.md` are always baseline v1;
- `spec_vN.md`, `context_vN.md`, `implementation_plan_vN.md`, `testing_plan_vN.md` are re-baselined artifacts;
- `active_artifacts.md` is the authoritative pointer once multiple baselines exist;
- `review_vN.md` files are append-only versioned review artifacts;
- `manual_test_plan.md` is single-baseline; if re-baselined, follow the same `_vN.md` convention.
- `agent_test_session.md` is the required Phase-5 agent-as-user run log; single-baseline (`_vN.md` if re-baselined).

---

# Framework Maintenance

Use the per-phase framework-update commands for changes to canonical framework files. Do not edit live generated files (`CLAUDE.md`, `.claude/`) directly. Edit canonical sources in `shamt-core/`, run regen, run `-Check` against a known-clean child project, verify semantic consistency and generated sizes, then archive the proposal.

---

*Shamt v2 — two roles, one framework, slug-resumable phases.*

---
Validated 2026-05-26 — 5 rounds, 1 adversarial sub-agent confirmed
Touched 2026-05-27 — Part 2 per-phase tier table aligned with `reference/model_selection.md` (Plan validation = Opus; Review split into story-mode / formal-mode issue-finding / formal-mode git metadata). Re-validated under the Phase 2 reference-library validation loop.
