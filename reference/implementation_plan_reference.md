# Implementation Plan Reference

Expanded formatting and execution details for Pattern 5. `SHAMT_RULES.template.md` keeps the normative planning contract; this file holds the longer examples and formatting guidance.

**Stack-agnostic by design.** Examples below name *categories* of work (route, write path, schema migration) rather than specific runtimes. Project-specific planning conventions belong in the project's `.shamt-core/project-specific-files/CODING_STANDARDS.md` or `.shamt-core/project-specific-files/ARCHITECTURE.md`; add stack-specific gates via a framework-update proposal if a pattern keeps recurring across stories.

## Checklist vs Full Plan Escalation

The **Quick path** embeds a compact `## Build Checklist` inside `spec.md` instead of creating `implementation_plan.md`.

**Escalate to a full Implementation Plan at `stories/{slug}/implementation_plan.md` when:**

- The build checklist exceeds 10 steps.
- The build will be delegated to a builder sub-agent.
- Exact locate / replace strings or byte-for-byte copy-file compatibility checks are necessary to prevent ambiguity in shared files.
- Verification steps depend on a complex multi-step deployment or database migration sequence.
- The user explicitly requests Gate 3 planning.

## Recommended plan structure

Use `templates/implementation_plan.template.md` as the main shape. A typical plan contains:

- metadata
- pre-execution checklist
- files manifest
- step-by-step implementation sequence
- notes, including `CODING_STANDARDS` compliance

## Repository preparation steps

When a plan touches more than one git repository, include `Step 0-A`, `Step 0-B`, and so on inside the plan before implementation steps. Each repo gets its own prepare step.

Branch naming convention:

- `feature/{slug}/<owner-or-team>`

Branch baseline sequence for every affected repo:

1. `git fetch origin <development-branch>`
2. `git checkout -b feature/{slug}/<owner-or-team> origin/<development-branch>`
3. Verify `git status --short --branch` shows the story branch and `git log -1 --oneline` matches the fetched `origin/<development-branch>` tip at branch creation.

If the feature branch already exists, halt and report it. Do not overwrite, reset, or recreate the existing branch without explicit user direction.

Commit message convention:

- `#{slug}: {message}`

## Operation contracts

- **CREATE:** full workspace-relative path, file purpose, and either complete initial content or an explicit in-repo template / copied sibling with concrete deltas.
- **EDIT:** exact locate string plus exact replacement string.
- **DELETE:** file or section plus justification.
- **MOVE:** always split into two sub-steps: create destination, then delete source, each with its own verification.

## Migration CREATE checklist (example pattern)

New-table migration scripts typically specify:

1. `CREATE TABLE IF NOT EXISTS` with all columns and constraints
2. Row-level access policy (the project's equivalent — e.g., RLS policy, application-layer tenant scope check) declared alongside the table in the same transaction or migration block
3. A verification `SELECT` (or equivalent introspection query) confirming the table matches the declared shape

Primary key conventions and constraint-naming patterns are project-specific — defer to the project's `.shamt-core/project-specific-files/CODING_STANDARDS.md`. A common pattern: surrogate UUID primary key as the first column; constraint names of shape `<table>_primary_key`, `<table>_<referenced_table>_foreign_key`, `<table>_unique`, `<table>_index_N`.

## Review Prevention Gate Examples

Use `reference/pr_review_prevention.md` with the plan template's `## Review Prevention Gate Mapping` section. The examples below show the level of mechanical specificity expected before validation.

### New Service Route

Map the infrastructure-and-deployment gate to separate steps for:

1. Entry-point handler CREATE / EDIT
2. Application stack environment variables, permissions, log retention, networking
3. Route stack: resource chain, authorizer / middleware, integration, deployment, stage
4. Packaging / build manifest update
5. Monitoring update per the project's monitoring template (error and latency alarms or equivalent)

Verification should include a handler import / smoke test, route-chain inspection, and alarm-or-equivalent monitoring inspection.

### DB Write Path

Before editing the write code, include a step that traces direct and transitive writes:

- direct write helpers called by the changed handler
- helper functions that perform `INSERT`, `UPDATE`, `DELETE`, or write-like stored procedures
- the exact point where writer routing applies (the project's equivalent of "use the primary endpoint" — e.g., a `use_writer=True` flag, a write-replica binding, an explicit primary-connection helper)

Verification should run the targeted tests or a grep / manual check proving every traced write path routes to the writer.

### Tenant-Scoped Object / Document Path

Plan the tenant identity source and object path construction separately from the code edit. Verification should include a tenant-A-to-tenant-B denial check when feasible. If the check cannot run locally, state the exact reason and the closest observable substitute.

### Removed Validation Or Security Check

Add a replacement-analysis step before the edit. The step names:

- the existing check
- the boundary it protects
- the replacement or preservation mechanism
- the bypass scenario that proves the boundary still holds

Only after that analysis step should the plan edit the code.

## Builder handoff template

Use the validated plan as the only execution source of truth. The builder should be told to:

1. Follow steps exactly as written
2. Execute sequentially
3. Run step-level verification when specified
4. Stop on failed verification
5. Stop on ambiguity

Expected reports:

- success: `All steps completed. Verification passed.`
- error: `Step N failed: ...`
- unclear: `Step N is ambiguous: ...`
- defect: `Plan defect at Step N: ...`
