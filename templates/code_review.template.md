# Code Review Template

Use this template for code reviews in Shamt. Two modes:

- **Story mode:** `stories/{slug}/feedback/review_v1.md` — inside the feedback folder; no `overview.md` (the story folder provides context via `ticket.md`, `spec.md`, and `implementation_plan.md`). Re-reviews use the next available `feedback/review_vN.md`.
- **Formal mode:** `code_reviews/<branch>/overview.md` + `review_v1.md` — use when reviewing someone else's branch or PR.

The 16 review categories below are the runtime contract. Detailed per-category guidance lives in `reference/review_categories.md`; the severity ladder lives in `reference/severity_classification.md`.

---

## Overview Document (Formal Mode Only)

**Filename:** `overview.md`
**When:** Reviewing an external branch or PR (not used in story mode)

```markdown
# Branch Overview: <branch-name>

**Date:** YYYY-MM-DD
**Base:** <base branch> (merge base: <short SHA>)
**Commits:** N commits (<first SHA>..<last SHA>)
**Files changed:** N files (+X -Y lines)

---

## ELI5 — What Changed?

<2-4 sentences in plain English. No jargon. Focus on what the user would notice, not implementation details.>

## What Does This Branch Do?

<Clear description of purpose and outcomes. What problem does it solve? What
feature does it add? What does the system do differently after this is merged?>

## Why Was It Built?

<Intent and motivation from commit messages, PR description, and code reading.
If intent is not explicit, state "inferred from commit messages / code structure.">

## How Does It Work?

<Technical walkthrough: which files were changed, what the key logic is, how
components interact, notable design choices. Organize by area when multiple
subsystems are touched.>

---
Validated YYYY-MM-DD — N rounds, 1 adversarial sub-agent confirmed
*Branch: <branch> | Base: <base>*
```

---

## Review Document (Both Modes)

**Filename:** `review_v1.md` (or `review_v2.md`, `review_v3.md` on re-review — never overwrite; discover the next version by listing existing `review_v*.md` in the folder)

**Story mode path:** `stories/{slug}/feedback/review_v1.md`
**Formal mode path:** `code_reviews/<branch>/review_v1.md`

```markdown
# Code Review: <branch-name or story-slug>

**Reviewed:** YYYY-MM-DD
**Base:** <base branch> (merge base: <short SHA>)
**Commits:** N commits | **Files changed:** N files (+X -Y lines)
[Formal mode: **Overview:** See `overview.md`]
[Story mode: **Story:** stories/{slug}/]
[When multiple baselines exist: **Baseline reviewed:** vN]

[Story mode only:
## Plan Alignment

- **Quick path (no plan):** Plan Alignment: N/A — Quick path used the spec Build Checklist instead of `implementation_plan.md`.
- **Standard path (plan exists):** [Run the Plan-Alignment Pre-Pass and list check results: Step Coverage, Change Fidelity, Scope Discipline, Verification Passage, Zero Builder Design Decisions]
]

---

## Summary

<Concise summary of what was reviewed and the main outcome.>

## Verdict

<Approve | Approve with comments | Request changes | Block>

## Degree of Risk

<1-10 plus one sentence explaining the risk.>

## Changed File Inventory

<Group changed files by area. Use the project's natural groupings — e.g., backend handlers, infrastructure / IaC, frontend, migrations / data, config / scripts / test data, and other files. Do not invent groupings the project does not use.>

## Review Comments

<Grouped by leadership section, then severity, then category. Omit sections with no findings.>

## Blockers

<BLOCKING findings. Omit if none.>

### BLOCKING

<Must be fixed before merge — correctness bug, security vulnerability, data-loss risk>

#### [BLOCKING] — <Category Name>

**File:** `path/to/file.ext`, line N

<Description: what it does wrong and what the consequence is.>

**Suggested fix:** <What to change and why.>

---

## Required Changes

<CONCERN findings unless explicitly non-blocking. Omit if none.>

### CONCERN

<Should be addressed — quality, performance, or maintainability issue>

#### [CONCERN] — <Category Name>

**File:** `path/to/file.ext`, line N

<Description>

**Suggested fix:** <Direction>

---

## Suggestions

<SUGGESTION findings and NITPICK findings when useful.>

### SUGGESTION

<Optional improvement — code works but could be better>

#### [SUGGESTION] — <Category Name>

**File:** `path/to/file.ext`, line N

<Description>

**Suggested fix:** <Direction>

---

### NITPICK

<Minor style or preference — author decides>

#### [NITPICK] — <Category Name>

**File:** `path/to/file.ext`, line N

<Description>

---

## Monitoring Checklist

<For any new deployment unit / service entry point: project monitoring conventions applied (e.g., standard error/latency alarms), notification routing in both alarm and OK actions, dimensions, thresholds, environment-tier conditions, and no regulated or sensitive data in alarm names/descriptions. Reference: the project's `.shamt-core/project-specific-files/ARCHITECTURE.md` and `.shamt-core/project-specific-files/CODING_STANDARDS.md` for monitoring rules.>

## Security Checklist

<Regulated data, tenant isolation, removed/weakened checks, state/token/redirect handling, input validation at boundaries, permissions / access policy, encryption, CORS / cache / cookie behavior. Reference: `reference/pr_review_prevention.md` and the project's `.shamt-core/project-specific-files/ARCHITECTURE.md`.>

## Positive Notes

<Specific strengths worth preserving.>

## Documentation Impact

[Story mode only — the Documentation Impact Assessment from `/e6-review-changes` Step 4. Omit in formal mode.]

- **.shamt-core/project-specific-files/ARCHITECTURE.md:** Required | Not required — <one-line reason>
- **.shamt-core/project-specific-files/CODING_STANDARDS.md:** Required | Not required — <one-line reason>
- **Polish action:** <Specific update Polish must apply, or "None.">

---
Validated YYYY-MM-DD — N rounds, 1 adversarial sub-agent confirmed
*Review generated using the Shamt code review workflow*
```

---

## Severity Definitions

| Severity | Meaning |
|----------|---------|
| **BLOCKING** | Must be fixed before merge — correctness bug, security vulnerability, data-loss risk |
| **CONCERN** | Should be addressed — quality, performance, or maintainability issue |
| **SUGGESTION** | Optional improvement — code works but could be better |
| **NITPICK** | Minor style or preference — author decides |

**Leadership section mapping:** BLOCKING → Blockers; CONCERN → Required Changes unless explicitly non-blocking; SUGGESTION → Suggestions; NITPICK → Suggestions or a short Nitpicks subsection.

The internal Pattern 1 / Pattern 2 validation loop on this artifact uses the CRITICAL/HIGH/MEDIUM/LOW ladder from `reference/severity_classification.md`. The BLOCKING/CONCERN/SUGGESTION/NITPICK ladder above is the *finding-severity* ladder reported back to the reviewee.

---

## Review Categories

The 16 mandatory categories — see `reference/review_categories.md` for the per-category checks:

1. **Correctness** — Logic errors, bugs, incorrect behavior
2. **Security** — Vulnerabilities and unsafe practices (and the inverse: defensive code on values this system owns)
3. **Performance** — Inefficiencies, scalability issues
4. **Maintainability** — Clarity, organization, complexity; trailing newlines
5. **Testing** — Coverage and test quality
6. **Edge Cases** — Unhandled scenarios, missing validation (and the inverse: guards on impossible states)
7. **Naming** — Names vs. the project's `.shamt-core/project-specific-files/CODING_STANDARDS.md` and established in-file patterns
8. **Documentation** — Comments, docstrings, README updates
9. **Error Handling** — Exception handling, error recovery
10. **Concurrency** — Race conditions, thread safety
11. **Dependencies** — Library usage, version constraints
12. **Architecture** — Design patterns, structure, coupling against `.shamt-core/project-specific-files/ARCHITECTURE.md`
13. **CSS Scope** — CSS changes scoped to the minimum necessary selector
14. **State Ownership** — Each piece of UI state managed in exactly one place
15. **Response Field Uniformity** — API response fields and HTML input attributes consistent across siblings
16. **Monitoring** — New deployment units carry the project's standard alarms / observability per the project's monitoring conventions

---

*Template for Code Reviews in Shamt*
