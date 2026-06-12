# Spec Protocol Reference

Expanded research-capture and prevention-requirement detail for Pattern 3 (Spec Protocol). `SHAMT_RULES.template.md` keeps the normative contract — the 7 steps, the gates, and the requirement *names*; this file holds the worked enumeration each step expects. Mirrors `reference/implementation_plan_reference.md` (Pattern 5) and `reference/pr_review_prevention.md`.

**Stack-agnostic by design.** Surfaces below name *categories* of risk (regulated data, tenant isolation, writer routing) rather than specific runtimes. Project-specific conventions belong in `.shamt-core/project-specific-files/ARCHITECTURE.md` / `CODING_STANDARDS.md`.

## Step 2 — Required research captures

Targeted research is scoped to the ticket's references, not broad exploration: grep the referenced files / functions / features; read `.shamt-core/project-specific-files/ARCHITECTURE.md` + `CODING_STANDARDS.md`; skim related code. Record findings in `context.md` (Standard) or `spec.md` Evidence (Quick). The required captures:

- **Code shapes** — the exact shapes (signatures, types, payloads, call sites) needed for planning, recorded verbatim enough that the Plan phase can write locate/replace strings without re-discovery.
- **Pre-existing gaps** — when refactoring, surface gaps in the touched code; either bring each into scope or defer it with a stated reason. If none exist, say so explicitly.
- **Current flow** — an ASCII current-state diagram once research suffices to draw it, unless the work is narrowly in-process — in which case record the N/A reason instead of a diagram.
- **Review-prevention risk inventory** — classify whether the story touches any of: regulated / sensitive data, tenant isolation, auth / authorization, route / API contract, DB reads / writes, migrations, new service, monitoring, frontend rendering / auth flow, tests / test data, or removed / weakened checks. Use `reference/pr_review_prevention.md`.
- **Boundary-diagram evidence** — for boundary-crossing stories a Mermaid diagram is required later; during research collect real source-backed component / interface names and flow evidence. A diagram cannot be the only place a component appears — every node/edge must trace to research or an approved decision.
- **File placement** — when shared-utility placement matters, record the governing rule under Architecture And Standards Notes.

## Step 5 — Prevention requirements per high-risk surface

Before placing anything in Open Questions, answer it from the codebase — only product / team / external-system decisions remain open, surfaced one at a time (Principle 2). For each applicable high-risk surface, state the approval-facing **prevention requirement**. Standard path stores detailed evidence in `context.md`; Quick stores compact evidence inline in `spec.md`. If a prevention surface is itself a risk trigger, escalate to the Standard path.

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

## Path-specific spec/context split (Step 5)

- **Standard** keeps `spec.md` concise and approval-facing while `context.md` carries detailed rationale, evidence, current flow, standards notes, and code shapes.
- **Quick** keeps all of that inline in `spec.md`.
- Standard path does **not** add a Files Affected inventory to the spec (file-level work belongs in the plan); Quick uses the Review Prevention Checklist and Build Checklist for files, prevention gates, and sequential mechanical steps.
- Resolve all parallel-skeleton `Blocked:` markers after Gate 2a.
