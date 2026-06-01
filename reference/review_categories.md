# Review Categories

Expanded guidance for Pattern 4's 16 mandatory review categories. `SHAMT_RULES.template.md` remains the runtime contract; this file carries the detailed reminders and the standard finding format.

**Stack-agnostic by design.** The bullets below describe *what to check*, not *what the project's coding standards happen to be*. Project-specific rules (logger patterns, naming conventions, framework-particular gotchas) live in the project's `.shamt-core/project-specific-files/CODING_STANDARDS.md` and are consulted by the **Naming**, **Documentation**, and **Architecture** categories below.

## Category-specific checks

1. **Correctness**
   - Check logic errors, bugs, and incorrect behavior.
   - Trace direct and transitive writes after database connection / session setup; any write path requires the project's writer-routing convention (e.g., primary endpoint, read/write replica flag).
   - Project-defined environment variables and config are accessed per the project's convention — no defensive fallbacks for values the project always sets.
   - SQL uses parameterized placeholders and tuple/named parameters.
   - Idempotency: utility scripts and migrations re-run safely without unintended side effects.

2. **Security**
   - Check vulnerabilities and unsafe practices.
   - Also check the inverse: do not recommend validation on values this system sets and owns. Ask: "Who controls this value — a user, or us?"
   - No regulated or sensitive data appears in logs, structured-log fields, exception messages, metric dimensions, alarm names/descriptions, or API responses.
   - API responses do not expose forbidden tenant IDs, raw DB rows, internal IDs, stack traces, or SQL.
   - Tenant scoping holds for database queries and non-database resources (object/blob storage paths, document routing, automation calls, content-delivery rewrites).
   - State, tokens, HMAC signatures, session IDs, and return paths are validated before trust.
   - Redirects use allow-lists or validated relative paths.
   - Secrets come from a secret manager or established secure-config source, never source code.
   - User-controlled query, path, header, and body inputs are validated or normalized at the boundary.
   - Consider SQL injection, command injection, SSRF, path traversal, unsafe deserialization, and XXE where relevant.
   - Permissions follow least privilege and data-at-rest is encrypted where applicable.
   - CORS, cache-control, and cookie flags follow existing safe patterns.
   - Deleted or weakened security checks require boundary analysis and bypass tracing, especially tenant-A-requests-tenant-B scenarios.

3. **Performance**
   - Check inefficiencies and scalability issues.

4. **Maintainability**
   - Check clarity, organization, and complexity.
   - Every changed file should end with a trailing newline; "no newline at end of file" is a NITPICK per file.
   - Functions are single-purpose and accurately named; avoid 1–2 lines of useful logic surrounded by logs.
   - Follow the project's `.shamt-core/project-specific-files/CODING_STANDARDS.md` for language-specific conventions (class usage, function signature limits, module structure).

5. **Testing**
   - Check test coverage and test quality.

6. **Edge Cases**
   - Check missing validation or unhandled scenarios.
   - Also check the inverse: do not require null or missing guards for impossible states such as required columns, primary keys, or values this system always sets.

7. **Naming**
   - Check names against the project's `.shamt-core/project-specific-files/CODING_STANDARDS.md` and local file conventions.
   - Domain-specific functions use subject-specific names (e.g. `build_account_updates_csv`, not `build_csv`).
   - Avoid generic names like `data`, `object`, `item`, `row`, and avoid unexplained abbreviations.
   - Collections use plural names; single objects, loop variables, and single-row results use singular names.
   - Query / statement variables follow the project's naming convention (e.g. `<operation>_<subject>_query`).

8. **Documentation**
   - Check comments, docstrings, and README updates.

9. **Error Handling**
   - Check exception handling and recovery.
   - Entry-point handlers wrap logic in try/except; sub-functions raise exceptions upward.
   - Every `except` logs and either re-raises or maps at the entry-point level.
   - Catch generic `Exception` only where that is the project pattern.
   - Returns are preceded by a log statement describing the return when the project uses log-on-return.
   - Function names in log/error messages match actual function names.

10. **Concurrency**
    - Check race conditions and thread safety.

11. **Dependencies**
    - Check library usage and version constraints.

12. **Architecture**
    - Check structure, coupling, and design fit against the project's `.shamt-core/project-specific-files/ARCHITECTURE.md`.
    - Route/middleware definitions match expected authorizer and integration shape.
    - Deployment-environment variables match reachable code paths: no missing required env vars, no unused env vars.
    - Database migrations, schema changes, and data-store changes are backward-compatible for at least one deploy window or document a rollout plan.

13. **CSS Scope**
    - If a shared class changes, confirm the change is intended everywhere that class appears; otherwise it belongs in a page-scoped selector.

14. **State Ownership**
    - Each UI state value should have one owner. Reset logic belongs in the open / initialise path so each invocation starts clean.

15. **Response Field Uniformity**
    - Response dict fields of the same type should use the same mapping rule.
    - Nullable columns should stay `None`; frontend defaults belong in the frontend.
    - Flag per-field coercions, `.strip()`, inline length checks, or HTML constraint attributes that are not applied consistently to sibling fields of the same type.

16. **Monitoring**
    - For any new deployment unit / service entry point, verify the project's service-monitoring template is updated per the project's monitoring conventions (e.g. standard error and latency alarms).
    - Missing standard alarms for a new or renamed deployment unit is BLOCKING when the project's `.shamt-core/project-specific-files/CODING_STANDARDS.md` or `.shamt-core/project-specific-files/ARCHITECTURE.md` documents a monitoring rule.
    - Verify alarm naming, threshold alignment with the unit's timeout/SLO, correct resource-dimension wiring, environment-tier conditions matching peer resources, notification-topic routing in both alarm and OK actions, and absence of regulated or sensitive data in alarm names/descriptions.

## Finding format

```markdown
#### [SEVERITY] — <Category Name>

**File:** `path/to/file.ext`, line N

<Description: what is wrong and what consequence it creates.>

**Suggested fix:** <Concrete direction.>
```

---

## Quick Path No-Artifact Reviews

In the **Quick path**, when no issues are found, creating a separate `review_v1.md` is not required. Instead, document the review directly in chat or append a `## Post-Build Review` section to `spec.md` matching this format:

```markdown
## Post-Build Review

**Plan Alignment:** N/A — Quick path used the spec Build Checklist instead of `implementation_plan.md`.

**Findings:** No issues found. Verified all Build Checklist steps sequentially.
```

If issues are found, the reviewer should create a durable review artifact at `stories/{slug}/feedback/review_v1.md` following the standard template and categories.
