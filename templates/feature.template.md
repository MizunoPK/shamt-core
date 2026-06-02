<!-- Feature artifact. Lives at features/{slug}-{brief}/feature.md (flat layout; globally unique slug). -->
# Feature {slug}

**Parent Epic:** [{epic-slug} — leave blank for standalone features created via `/p3-start-feature` from scratch (no parent epic). Plain markdown; no parser.]

## Open Questions

[Only unresolved questions that affect feature scope, success criteria, or story decomposition. Per the open-questions iterative-dialog principle in `templates/SHAMT_RULES.template.md`, surface each question to the user one at a time and update the feature with each answer before moving on. This section must be empty before `/validate-artifact` runs.]

---

## Goal

[One paragraph: what this feature exists to accomplish within its parent epic (or standalone). State the user / business outcome, not the implementation path.]

---

## Success Criteria

- [ ] [Observable condition that signals the feature is done. Bullets are testable at the feature altitude — not story-level acceptance criteria.]

---

## Scope / Non-Scope

[Optional `**Architecture impact:** …` inline flag — present only when `/p3-start-feature` consulted `.shamt-core/project-specific-files/ARCHITECTURE.md` (per §1.12) and identified an architectural change implied by this feature. Omit entirely otherwise.]

### In Scope

- [What this feature covers]

### Out of Scope

- [What this feature explicitly does not cover; defer to a future feature or note as dropped]

---

## Target Stories

[Populated by `/p4-decompose-feature`. Left empty on `/p3-start-feature` exit. Each line: story slug + one-line scope.]

- `{story-slug}` — [one-line scope; must be individually testable per the §2.3 decomposition exit gate]

---

## Sequencing & Parallelization

[Populated by `/p4-decompose-feature`. Left empty on `/p3-start-feature` exit.]

**Recommended order:**

1. `{story-slug}` — [why this comes first; dependencies]

**Parallelizable:**

- [Which stories can be worked concurrently and why; or "None — strictly sequential."]

---
[Append the validation footer only after Pattern 1 completes, e.g., `Validated YYYY-MM-DD — N rounds, 1 adversarial sub-agent confirmed`.]
