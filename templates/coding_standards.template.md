---
Last Updated: YYYY-MM-DD
Update History:
  - YYYY-MM-DD: Initial creation (project initialization)
Update Triggers: |
  Update this document when:
  - A new coding pattern emerges that should be standard across the codebase
  - The team agrees on a new convention (naming, file layout, fixture pattern, etc.)
  - Linting or formatting rules change
  - A recurring code-review finding becomes a pattern worth codifying as a rule
  - Test conventions change (runner, file naming, assertion style, fixture model)
How to Update: |
  Open a story (or a framework-update proposal if this is a shamt-core change), follow the
  Engineer flow, and amend the relevant sections of this file. Phase 6 (Review) will flag
  whether a story implies an update; Phase 7 (Polish) applies the update and re-validates.
  Run `/validate-artifact .shamt-core/project-specific-files/CODING_STANDARDS.md` after substantive edits. Keep `Last Updated`
  current and add an entry to `Update History` with the triggering story or proposal slug.
---

# Project Coding Standards

**Purpose:** Define project conventions for consistent code reviews and new code. Consulted by Phase 2 (Spec) research, by the Naming / Documentation / Architecture review categories (see `reference/review_categories.md`), and by the `test-executor` persona when writing or interpreting tests.

---

## Test Runner and Test Conventions

**Test runner:** [e.g., `pytest`, `jest`, `go test`]

**Run command:** `[exact command — e.g., pytest tests/ -q]`

**Test file naming:** [e.g., `test_*.py` next to source / `*.test.ts` colocated / `*_test.go` per Go convention]

**Test directory layout:** [Where tests live — `tests/`, colocated, mirror of source tree, etc.]

**Assertion style:** [e.g., `assert ...` (pytest), `expect(...).toBe(...)` (jest), `require.Equal` (Go testify). Note any project wrappers.]

**Fixture / setup patterns:** [Fixture model in use — pytest fixtures, jest beforeEach, factory functions, golden files. Where fixtures live.]

**Mocking conventions:** [Which library, where mocks live, what the team prefers to mock vs. fake vs. stub.]

**Test data:** [Synthetic only — never real customer data. Fixture seeds, factory functions, anonymization rules.]

**Coverage expectations:** [Minimum coverage, what must be covered (happy path, edge cases, error conditions, boundary values), what is explicitly exempt.]

---

## File Naming and Organization

| Element | Convention | Example |
|---------|------------|---------|
| Source files | [snake_case / kebab-case / PascalCase] | [`user_manager.py` / `user-manager.ts` / `UserManager.cs`] |
| Test files | [pattern] | [`test_user_manager.py`] |
| Directories | [convention] | [`services/auth/`] |

**File organization rules:**
- [One class per file when practical / one default export per module / etc.]
- [Group related functionality in the same directory]
- [Separate concerns: models, services, utilities, routes, handlers]

---

## Language Conventions

**Language(s):** [e.g., Python 3.11, TypeScript 5.x]

### Naming

| Element | Convention | Example |
|---------|------------|---------|
| Variables | [snake_case / camelCase] | `user_count` / `userCount` |
| Functions | [snake_case / camelCase] | `get_user()` / `getUser()` |
| Classes / Types | [PascalCase] | `UserManager` |
| Constants | [UPPER_SNAKE_CASE] | `MAX_RETRIES` |
| Query/statement variables | [project convention] | [`<operation>_<subject>_query`] |

### Function and Module Shape

- [Function length limit, parameter count limit, single-purpose rule]
- [Module / file size guideline]
- [When to extract a helper vs. inline]

### Imports

[Order, grouping, and any project-specific rules.]

```python
# Standard library
import os

# Third-party
import requests

# Local
from .models import User
```

---

## Lint and Format

**Formatter:** [e.g., `black`, `prettier`, `gofmt`]
- Configuration: [path to config — `pyproject.toml`, `.prettierrc`, etc.]
- Run before commit: [`<command>`]

**Linter:** [e.g., `ruff`, `eslint`, `clippy`]
- Configuration: [path to config file]
- Run: [`<command>`]

**Pre-commit hooks:** [If used, list and link to config.]

---

## Documentation

### Code Comments

**When to comment:**
- Non-obvious WHY: hidden constraint, subtle invariant, workaround for a specific bug, surprising behavior
- Complex algorithms or business logic where intent is not visible

**When not to comment:**
- Restating what the code does (`i += 1  # increment i`)
- Narrating the current task or change

### Docstrings / JSDoc

**Required for:** [Public functions, exported classes, module-level entry points — adjust to project policy.]

**Format:** [e.g., Google style, NumPy style, JSDoc, TSDoc]

```python
def calculate_score(user_id: int, weight: float = 1.0) -> float:
    """Calculate weighted score for a user.

    Args:
        user_id: Unique user identifier.
        weight: Score multiplier (default 1.0).

    Returns:
        Weighted score.

    Raises:
        ValueError: If `user_id` is invalid.
    """
```

---

## Error Handling

**Do:**
- Catch specific exception types, not generic catch-all
- Log errors with context (IDs, values, state)
- Re-raise when the caller is the right place to decide
- Use context managers / `defer` for resource cleanup

**Don't:**
- Swallow exceptions silently
- Use exceptions for control flow
- Catch without logging or re-raising

**Project specifics:**
- Entry-point handlers: [project pattern for top-level try/except, log-and-map vs. let-it-propagate]
- Logging conventions: [logger name, structured-log fields, severity ladder]
- Function names in log/error messages match the actual function name

---

## Security Defaults

- Never commit secrets — use the project's secret manager / env / vault.
- Validate user input at the boundary; do not validate internal-system values.
- Sanitize output: encode for HTML, escape for SQL via parameterized queries, etc.
- Parameterized queries always — no string-built SQL.
- Authorization checked on every protected route.
- Log security-relevant events (failed auth, permission denials).
- No regulated or sensitive data in logs, metrics, alarm text, or DOM.

---

## Performance Defaults

- Avoid N+1 queries — use joins, batch loading, or DataLoader-style aggregation.
- Cache expensive idempotent operations; invalidate explicitly.
- Use the project's writer-routing convention (primary endpoint, replica flag, etc.) on writes.
- Paginate large result sets at the API boundary.
- Index database columns used in WHERE / JOIN / ORDER BY.

---

## Common Code Patterns

### Pattern 1: [Name]

**When to use:** [scenario]

**Example:**
```[language]
[code example]
```

### Pattern 2: [Name]

**When to use:** [scenario]

**Example:**
```[language]
[code example]
```

---

## Review Quick Checklist

When reviewing code in this project, check for:

- [ ] Follows naming conventions
- [ ] Has appropriate documentation
- [ ] Tests cover new functionality per the conventions above
- [ ] Error handling matches the project pattern
- [ ] No security defaults violated
- [ ] No obvious performance regressions
- [ ] Consistent with existing codebase style

The full 16-category review framework lives in `reference/review_categories.md`. This checklist is the project-specific fast pass.

---

*Template for project `.shamt-core/project-specific-files/CODING_STANDARDS.md` in Shamt. Header metadata block above is required — the framework-update audit reads it (§1.12).*
