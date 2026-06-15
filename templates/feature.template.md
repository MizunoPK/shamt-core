<!-- Feature artifact. Lives at epics/{ID}-{epic-slug}-{brief}/features/{ID}-{slug}-{brief}/feature.md — nested under its parent epic (epics are top-level). Globally unique slug; resolved per §PO-tree resolution. -->
# Feature {slug}

**Ticket ID:** {ID}

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

[Optional `**Architecture impact:** …` inline flag — present only when `/pf1-define` consulted `.shamt-core/project-specific-files/ARCHITECTURE.md` (architecture-impact) and identified an architectural change implied by this feature. Omit entirely otherwise.]

### In Scope

- [What this feature covers]

### Out of Scope

- [What this feature explicitly does not cover; defer to a future feature or note as dropped]

---

## Decomposition Context

<!-- Cataloged at decomposition (/pe2-decompose for features, /pf2-decompose for stories) — bounded breadth context discovered by researching the whole sibling set. NOT a depth dump (design/acceptance/implementation detail belongs in the depth sections, filled at start-*). /pf1-define and /e1-start-story consume this as a research seed. Leave the placeholder bullets if nothing was cataloged. -->

- **Dependencies on siblings:** [which sibling features/stories this one depends on or blocks — "none" if independent]
- **Shared context:** [context spanning the set this child needs — shared modules, data, infra, conventions]
- **Boundary rationale:** [why this child is scoped as drawn rather than merged into a sibling]

---

## Target Stories

[Populated by `/pf2-decompose`. Left empty on `/pf1-define` exit. Each line: story slug + one-line scope.]

- `{story-slug}` — [one-line scope; must be individually testable per the decomposition exit gate]

---

## Sequencing & Parallelization

[Populated by `/pf2-decompose`. Left empty on `/pf1-define` exit.]

**Recommended order:**

1. `{story-slug}` — [why this comes first; dependencies]

**Parallelizable:**

- [Which stories can be worked concurrently and why; or "None — strictly sequential."]

---

## Scratch Notes (stage-0 capture)

[`/pf0-draft` writes a feature stub (incremental single-add) ingested by `/pf1-define`. Omit entirely for non-draft features.]

---

## All Remaining Fields

*(Tracker-seeded features only — omit this entire section when authored freeform or when there is nothing worth preserving.)* Every non-empty tracker payload field not already captured above, preserved inline (features have no `raw/` subfolder at this altitude). Use the durable tracker field name as the heading/key.

- `{field}`: `{value}`

---
[Append the validation footer only after Pattern 1 completes, e.g., `Validated YYYY-MM-DD — N rounds, 1 adversarial sub-agent confirmed`.]
