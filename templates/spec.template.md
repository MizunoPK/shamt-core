# Spec: {slug}

**Created:** [Date]
**Story:** stories/{slug}/
<!-- Paths are relative to the resolved story folder (located per templates/SHAMT_RULES.template.md §PO-tree resolution; the folder nests under epics/.../features/.../). -->
**Status:** Draft
**Context:** stories/{slug}/context.md
**Baseline:** v1
**Baseline status:** Active

---

## Ticket Summary

[3-5 bullets: what's being asked, acceptance criteria (explicit or implied), links, due dates, constraints]

---

## Problem Summary

[1-3 short paragraphs: what needs to change and why]

---

## Proposed Architecture

TBD - awaiting user alignment (Gate 2a)

[If this section preserves multiple options for review after Gate 2a, each option must include its own explicit Pros and Cons list. Do not use one shared tradeoff paragraph across options.]

---

## Proposed Code Flow

TBD - awaiting user alignment (Gate 2a)

[After Gate 2a: describe the changed path in plain language or with a compact ASCII flow. Keep detailed current-state flow and evidence in context.md.]
[If this section presents multiple flow options for review, each option must include its own explicit Pros and Cons list.]

---

## Design Diagram

**Mermaid diagram:** TBD / N/A / `stories/{slug}/diagram.md`. Spec does not author Mermaid diagrams directly; use the dedicated diagram generation workflow once the active artifacts contain enough source-backed design evidence. See `reference/mermaid_diagram_standards.md` and `reference/mermaid_recipes.md`.

[If N/A: **Diagram: N/A -** <one-line reason>. If generated later, link to the diagram file rather than editing a validated spec without revalidation.]

---

## Key Design Decisions

| ID | Decision | Summary |
|----|----------|---------|
| D1 | [Decision name] | [High-level user-readable summary. Detailed rationale lives in context.md.] |

---

## Requirements

**Functional:**
- [ ] [requirement]

**Non-functional:**
- [ ] [performance / security / compatibility constraint, if applicable]

---

## Test Strategy

[Required (testing is a required phase). Always describe the Phase-6 agent-as-user scenarios; add automated detail when `TESTING_STANDARDS.md` declares suites.]

- **Test kinds in scope:** [e2e / integration / unit — what coverage shape this story needs]
- **Existing test files relevant:** [`path/to/test.ext` - reason]
- **New test files needed:** [`path/to/new_test.ext` - purpose]
- **Project conventions:** [pointers to the relevant `.shamt-core/project-specific-files/CODING_STANDARDS.md` sections — test runner, file naming, fixture patterns, assertion style]

This section is approval-relevant at Gate 2b. The full test plans are authored in Phase 4 (Test Plan): the always-produced `user_test_plan.md` (agent-as-user scenarios) and, when `TESTING_STANDARDS.md` declares suites, `testing_plan.md` (automated).

---

## Review Prevention Gates

<!-- For each applicable surface, point to the corresponding section of context.md (the always-produced evidence artifact). See `reference/pr_review_prevention.md`. -->

| Surface | Applies? | Requirement / Prevention | Evidence |
|---------|----------|--------------------------|----------|
| Regulated / sensitive data | Yes / No | [No regulated or sensitive data in logs/responses/metrics/alarms/DOM/test fixtures, or N/A reason] | [context section or file path] |
| Tenant isolation | Yes / No | [Source of tenant identity and enforcement point] | [context section or file path] |
| Auth / route contract | Yes / No | [Authorizer/middleware, route chain, state/token/redirect expectation] | [context section or file path] |
| Database read/write | Yes / No | [Database role/credential, writer-routing for writes, cross-service lineage] | [context section or file path] |
| Infrastructure / deployment | Yes / No | [Entry point/application stack/route or networking/monitoring/packaging/env vars/permissions/log retention/deployment topology] | [context section or file path] |
| Frontend safety | Yes / No | [Fetch errors, safe DOM, secrets/config, cookies/cache/CORS, auth flow] | [context section or file path] |
| Testing / test data | Yes / No | [Tests, manual verification, synthetic data] | [context section or file path] |
| Removed/weakened checks | Yes / No | [Replacement boundary or preserved existing check] | [context section or file path] |

---

## Interfaces and Boundaries

[Optional - APIs, events, data contracts that are design outputs but not file-level inventory. File-level changes live in `implementation_plan.md`.]

---

## Database Schema Changes

> **Database Schema Changes — Cross-Service Lineage Trace Required:** For any DB schema changes, trace the end-to-end read and write data lineage across service boundaries (e.g., frontend API writes vs. backend background-worker read paths).

[Include this section whenever the story adds or modifies database schema. This is where approval-relevant schema design is shown to the user. For each new table, include a column table with name, type, nullable, and description. For each modified existing table, include a delta table covering only the added or changed columns.]

```md
### New table: <schema>.<table_name>

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| <table_name>_id | uuid | NO | Primary key (gen_random_uuid()) |
| ... | ... | ... | ... |
```

```md
### Modified table: <schema>.<table_name> (existing columns omitted)

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| new_column | text | YES | Added by this story - purpose |
```

[If the schema approach is still an open design question, include candidate schema tables for each option so the tradeoffs are visible at spec time. If a DB change is deferred, say that explicitly and explain why.]

---

## Out of Scope

[What this spec explicitly does NOT cover]

---

## Open Questions

[Only unresolved questions that affect approval or planning. Per the open-questions iterative-dialog principle in `templates/SHAMT_RULES.template.md`, surface each question to the user one at a time and update the spec with each answer before moving on. Code-research every question first — Open Questions cannot contain answerable file/function/column questions.]

---
[Append the validation footer only after Pattern 1 completes.]
