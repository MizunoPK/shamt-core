# PR Review Prevention Gates

This reference shifts common PR-review findings into Spec, Context, and Implementation Planning. Use it during targeted research and planning when a story touches one of the listed surfaces.

**Stack-agnostic by design.** The gates below name *categories* of risk surface (auth, data, deployment, etc.) rather than specific runtimes or services. Projects that want stack-specific gates (e.g., serverless-runtime monitoring obligations, framework-X session-handling rules) add them via a framework-update proposal — see `proposals/` and Part 3 of the framework-update flow.

## When To Apply

Apply these gates for any new or changed:

- Deployment unit, service entry point, API route, event contract, or deployment boundary
- Auth, authorization, tenant isolation, session/token/redirect, or any other security boundary
- Regulated, sensitive, tenant-identifying, user-identifying, or internal-only data path
- Database read/write path, schema migration, data backfill, or storage role/credential routing
- Infrastructure resource — networking, permissions/access-policy, secrets/config, monitoring, logging, build/packaging
- Frontend fetch, rendering, auth flow, cookie/cache/CORS behavior, or secret/config exposure
- Test data, branching logic, or verification strategy
- Removed or weakened validation, tenant scoping, role check, redirect allowlist, session/token check, or other security gate

If one of these surfaces is a Shamt risk trigger, use the **Standard path**. If the story still qualifies for the **Quick path**, record compact evidence and checklist items inline in `spec.md`.

## Spec Risk Inventory

Specs should include an approval-facing inventory. Each applicable surface needs a requirement or an explicit N/A / deferred reason.

| Surface | Applies? | Required prevention | Evidence source |
|---------|----------|---------------------|-----------------|
| Regulated / sensitive data | Yes / No | No regulated or sensitive data in logs, responses, metrics, alarms, browser DOM, or test fixtures unless explicitly approved. | `context.md` section or researched file path |
| Tenant isolation | Yes / No | Tenant identity source and enforcement point are named; non-DB paths include tenant-scoping rules. | `context.md` section or researched file path |
| Auth / route contract | Yes / No | Authorizer/middleware, route chain, session/token/redirect, and deployment expectations are stated. | `context.md` section or researched file path |
| Database read/write | Yes / No | Database role/credential, replication/writer behavior, transitive write paths, and cross-service read/write lineage are planned. | `context.md` section or researched file path |
| Infrastructure / deployment | Yes / No | Entry point, application stack, route/networking, monitoring, packaging/build, env vars, permissions, log retention, and deployment topology are covered or N/A. | `context.md` section or researched file path |
| Frontend safety | Yes / No | Fetch errors, safe DOM rendering, secrets/config exposure, cookies/cache/CORS, and auth-flow expectations are covered. | `context.md` section or researched file path |
| Testing / test data | Yes / No | Automated tests, manual verification, and synthetic-only test-data obligations are stated. | `context.md` section or researched file path |
| Removed / weakened checks | Yes / No | Existing boundary is preserved or a replacement boundary is specified before code edits. | `context.md` section or researched file path |

## Context Evidence Matrix

Use `templates/context.template.md` for the detailed evidence shape. The context should answer:

- **Data classification:** What inputs/outputs/logs/metrics/alarms/browser surfaces may carry regulated data, tenant identifiers, user details, raw rows, query strings, stack traces, or internal details?
- **Tenant / auth / route boundaries:** Where does tenant identity come from? Where is it enforced? Which route chain, authorizer/middleware, redirect, session, or token behavior applies?
- **Persistence and writer routing:** Which paths read or write? Which helpers perform transitive writes? Which database role or credential applies? Which migration, replication, or read-replica behavior applies? Have you traced the end-to-end read/write lineage across service boundaries (e.g., a sibling service's configuration-retrieval API)?
- **Infrastructure completion:** Which entry point, application stack, route, monitoring template, packaging path, environment variable, access policy / permission, log retention, networking, and deployment-stage surfaces are in scope?
- **Frontend safety:** How are fetch failures handled? Is DOM rendering safe? Are secrets/config, cookies, cache, CORS, and auth-flow expectations preserved?
- **Verification and test data:** Which tests or manual checks cover the change? Is all test data synthetic?
- **Removed / weakened checks:** What check existed, what boundary did it protect, and what replacement or preservation proves the boundary still holds?

## Plan Prevention Gates

Before implementation steps are validated, every applicable risk must map to exact plan step(s), exact verification, or an explicit N/A / deferral reason. A plan is not mechanical if the builder must infer prevention work.

Hard expectations:

- DB writes require direct and transitive write tracing before the code-edit step, plus a concrete writer-routing step (the project's equivalent of "use the primary/writer endpoint") when applicable.
- New or changed deployment units / routes require manifest coverage or explicit N/A for entry point, application stack, route/networking, monitoring, packaging, environment variables, permissions, log retention, and deployment-stage updates.
- Tenant / path / object / document changes require a tenant-A-to-tenant-B bypass verification when feasible, or a stated reason why it cannot be run.
- Removed or weakened checks require a replacement-analysis step before the code-edit step.
- Testing gates must name the test command, manual check, or accepted reason for no automated test.

## Examples

### New API Route on an Existing Service

Spec requirement: "Add `GET /items/{id}` behind the existing tenant authorizer; no regulated or sensitive data in logs/responses/metrics; add standard error and latency alarms per project monitoring conventions."

Context evidence:

- route chain: `Api` → `ItemsResource` → `{id}` → `GET`
- handler env vars / config: `DB_SECRET_REF`, `TENANT_TABLE`
- monitoring template: project's service-monitoring definition
- outbound auth: sibling handlers generate machine-auth tokens

Plan mapping:

- Step 1 creates the handler.
- Step 2 updates the application stack: env vars, permissions, log retention, networking.
- Step 3 updates the route stack: authorizer, integration, deployment.
- Step 4 updates packaging / build manifest.
- Step 5 adds error and latency alarms per project monitoring conventions.
- Verification imports the handler, checks route resources, and checks alarm dimensions/actions.

### DB Write Path

Spec requirement: "Update status with writer routing; preserve role-based access behavior."

Context evidence:

- direct write: `update_status`
- transitive write: `save_status_history`
- writer requirement: both execute `INSERT` / `UPDATE`

Plan mapping:

- Step 1 traces direct/transitive writes and records the call graph.
- Step 2 sets the project's writer-routing flag (or equivalent helper) before both write paths.
- Verification greps for write helpers and runs targeted tests.

### Tenant-Scoped Object Path

Spec requirement: "Object access must be scoped by tenant ID from the authenticated request."

Context evidence:

- tenant source: authorizer / session claims
- object path shape: `tenant/{tenant_id}/documents/{document_id}`
- bypass: tenant A should not read tenant B object paths

Plan mapping:

- Step 1 edits path construction to use authenticated tenant ID.
- Verification runs or documents a tenant-A-to-tenant-B denial check.

### Removed Validation Check

Spec requirement: "Preserve redirect allowlist protection while replacing the parsing helper."

Context evidence:

- existing check: `validate_redirect_uri`
- boundary protected: external redirect target
- replacement: new parser calls the same allowlist before returning

Plan mapping:

- Step 1 performs replacement analysis and records the exact protected boundary.
- Step 2 edits the parser only after the replacement is named.
- Verification covers allowed and blocked redirect values.
