# Spec Protocol Reference

Expanded research-capture and prevention-requirement detail for Pattern 3 (Spec Protocol). `SHAMT_RULES.template.md` keeps the normative contract — the 7 steps, the gates, and the requirement *names*; this file holds the worked enumeration each step expects. Mirrors `reference/implementation_plan_reference.md` (Pattern 5) and `reference/pr_review_prevention.md`.

**Stack-agnostic by design.** Surfaces below name *categories* of risk (regulated data, tenant isolation, writer routing) rather than specific runtimes. Project-specific conventions belong in `.shamt-core/project-specific-files/ARCHITECTURE.md` / `CODING_STANDARDS.md`.

## The 7-Step Spec Protocol — per-step walkthrough

The rules file keeps Pattern 3's purpose, the Gate 2a/2b contract, the artifact-shape contract, and the five validation pair-checks; this is the expanded per-step prose.

**Step 1 — Ingest the ticket.** Apply the active-artifact pointer and global story-folder resolution. Read `ticket.md` (or provided content); extract ask, acceptance criteria, links, due dates, constraints; output a 3–5 bullet in-agent summary; do not write to disk yet. Empty/missing content → halt and ask.

**Step 2 — Targeted research.** Scope to ticket references, not broad exploration: grep referenced files/functions/features; read `.shamt-core/project-specific-files/ARCHITECTURE.md` + `CODING_STANDARDS.md`; skim related code. Record findings in `context.md` (always produced). The required captures — code shapes, pre-existing gaps, current flow, review-prevention risk inventory, boundary-diagram evidence, and file placement — are enumerated under [Step 2 — Required research captures](#step-2--required-research-captures) below.

**Step 3 — Draft skeletons.** Always draft `spec.md` (from `templates/spec.template.md`) + `context.md` (from `templates/context.template.md`): `spec.md` is the approval contract; `context.md` is the evidence/planning handoff; approval-relevant persistence design and review-prevention requirements must appear in `spec.md`, not only `context.md`; Key Design Decision IDs appear in both. Optional plan skeleton: after `spec.md`/`context.md`, create `implementation_plan.md` with exploratory headers only, mark unresolved decisions `Blocked:`, set Planning Status to "Blocked on spec (Gate 2a)"; do not fill locate strings until after Gate 2a. (The artifact-shape contract is the KEEP-INLINE contract in the rules file.)

**Step 4 — Architecture/design dialog (Gate 2a).** Present 1–3 design options inline in chat, not in `spec.md` yet: one option is fine when the choice is obvious, 2–3 are required for non-trivial user-facing forks; each needs description, pros, cons, effort (S/M/L), and a recommendation (if an option has no meaningful downside, say so). For open sub-questions, use `reference/question_brainstorm_categories.md` and omit empty categories. Mermaid diagrams are not part of Spec creation — for boundary-crossing stories, record enough approved design-option, workflow, schema, and source-backed component evidence for a later Mermaid generation step; an existing Mermaid block is optional supporting material, do not create or update it during Spec. **Wait for explicit user confirmation before proceeding.**

**Step 5 — Flesh out spec/context.** Record the agreed approach into the Step 3 artifacts: the approval-facing `spec.md` + detailed `context.md`. Before placing anything in Open Questions, answer it from the codebase — only product/team/external-system decisions remain open, surfaced one at a time (Principle 2). For each applicable high-risk surface state the approval-facing **prevention requirement**. For any schema, migration, or table-level change the spec must trace the end-to-end cross-service read **and** write data lineage across service boundaries (so data is not written but ignored at runtime), including any missing backchannel API / query route / config endpoint as in-scope **or** listing it a Blocker for Gate 2a/2b vetting. The enumerated prevention requirements and the schema/lineage detail (column/delta listing, reviewable candidate options, explicit deferral) are in the [Step 5](#step-5--prevention-requirements-per-high-risk-surface) sections below. Resolve all parallel-skeleton `Blocked:` markers after Gate 2a.

**Step 6 — Validate.** Run Pattern 1 on the `spec.md` + `context.md` pair using spec dimensions plus the five pair checks (kept in the rules file as the normative contract); exit is the uniform primary clean + 1 adversarial sub-agent, footer both files. If a Mermaid diagram is recorded in the active artifacts, verify it renders, every node/edge is research- or decision-backed, it does not contradict spec/context, and it conforms to `reference/mermaid_diagram_standards.md`. Each round ask, "What code should I have read that I haven't?" — and read it.

**Step 7 — User approval (Gate 2b).** Present the validated `spec.md` as the approval artifact and link `context.md` as supporting detail. If a new service is in scope, standard monitoring requirements must appear in Requirements or be explicitly Deferred with reason.

## Step 2 — Required research captures

Targeted research is scoped to the ticket's references, not broad exploration: grep the referenced files / functions / features; read `.shamt-core/project-specific-files/ARCHITECTURE.md` + `CODING_STANDARDS.md`; skim related code. Record findings in `context.md` (always produced). The required captures:

- **Code shapes** — the exact shapes (signatures, types, payloads, call sites) needed for planning, recorded verbatim enough that the Plan phase can write locate/replace strings without re-discovery.
- **Pre-existing gaps** — when refactoring, surface gaps in the touched code; either bring each into scope or defer it with a stated reason. If none exist, say so explicitly.
- **Current flow** — an ASCII current-state diagram once research suffices to draw it, unless the work is narrowly in-process — in which case record the N/A reason instead of a diagram.
- **Review-prevention risk inventory** — classify whether the story touches any of: regulated / sensitive data, tenant isolation, auth / authorization, route / API contract, DB reads / writes, migrations, new service, monitoring, frontend rendering / auth flow, tests / test data, or removed / weakened checks. Use `reference/pr_review_prevention.md`.
- **Boundary-diagram evidence** — for boundary-crossing stories a Mermaid diagram is required later; during research collect real source-backed component / interface names and flow evidence. A diagram cannot be the only place a component appears — every node/edge must trace to research or an approved decision.
- **File placement** — when shared-utility placement matters, record the governing rule under Architecture And Standards Notes.

## Step 5 — Prevention requirements per high-risk surface

Before placing anything in Open Questions, answer it from the codebase — only product / team / external-system decisions remain open, surfaced one at a time (Principle 2). For each applicable high-risk surface, state the approval-facing **prevention requirement**. Detailed evidence is stored in `context.md`.

- **Regulated / sensitive data** — no regulated or sensitive data in logs, responses, metrics, or alarms.
- **Tenant isolation** — name the tenant identity source and the enforcement point.
- **Route / API contract** — state the route authorizer / integration expectation.
- **DB writes** — state the writer routing for direct **and** transitive writes.
- **New service** — standard monitoring on the new service.
- **Tests** — the tests or verification strategy.
- **Removed / weakened checks** — the replacement or preservation mechanism for the removed/weakened check.

## Step 5 — Schema, migration, and data-lineage detail

For any schema, migration, or table-level change, the spec must explicitly trace the **end-to-end cross-service read and write data lineage** across service boundaries, to ensure data is not written but ignored or dropped at runtime.

- If a required backchannel API, query route, or configuration endpoint does not exist yet, the spec must either include its creation as in-scope **or** list it as a Blocker under Open Questions and escalate for Gate 2a/2b pre-approval vetting.
- **New tables** list columns; **existing-table changes** list deltas only.
- Candidate schema options must be reviewable when undecided.
- Explicitly **defer** schema changes when out of scope.

## Spec/context split (Step 5)

- `spec.md` stays concise and approval-facing while `context.md` carries detailed rationale, evidence, current flow, standards notes, and code shapes.
- The spec does **not** add a Files Affected inventory (file-level work belongs in the plan).
- Resolve all parallel-skeleton `Blocked:` markers after Gate 2a.
