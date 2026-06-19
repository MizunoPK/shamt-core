<!-- Epic artifact. Lives at epics/{ID}-{slug}-{brief}/epic.md ({ID}- prefix is the ticket ID; globally unique slug). -->
# Epic {slug}

**Ticket ID:** {ID}

## Open Questions

[Only unresolved questions that affect epic scope, success criteria, or feature decomposition. Per the open-questions iterative-dialog principle in `templates/SHAMT_RULES.template.md`, surface each question to the user one at a time and update the epic with each answer before moving on. This section must be empty before `/validate-artifact` runs.]

---

## Goal

[One paragraph: what this epic exists to accomplish. State the user / business outcome, not the implementation path.]

---

## Success Criteria

- [ ] [Observable condition that signals the epic is done. Bullets are testable at the epic altitude — not story-level acceptance criteria.]

---

## Scope / Non-Scope

[Optional `**Architecture impact:** …` inline flag — present only when `/pe1-define` consulted `.shamt-core/project-specific-files/ARCHITECTURE.md` (architecture-impact) and identified an architectural change implied by this epic. Omit entirely otherwise.]

### In Scope

- [What this epic covers]

### Out of Scope

- [What this epic explicitly does not cover; defer to a future epic or note as dropped]

---

## Target Features

[Populated by `/pe3-decompose`. Left empty on `/pe1-define` exit. Each line: feature slug + one-line goal.]

- `{feature-slug}` — [one-line goal]

---

## Sequencing & Parallelization

[Populated by `/pe3-decompose`. Left empty on `/pe1-define` exit.]

**Recommended order:**

1. `{feature-slug}` — [why this comes first; dependencies]

**Parallelizable:**

- [Which features can be worked concurrently and why; or "None — strictly sequential."]

---

## Scratch Notes (stage-0 capture)

[`/pe0-draft` writes this section with raw idea notes + draft status; `/pe1-define` ingests and refines. Omit entirely for non-draft epics.]

---

## All Remaining Fields

*(Tracker-seeded epics only — omit this entire section when authored freeform or when there is nothing worth preserving.)* Every non-empty tracker payload field not already captured above, preserved inline (epics have no `raw/` subfolder at this altitude). Use the durable tracker field name as the heading/key.

- `{field}`: `{value}`

---
[Append the validation footer only after Pattern 1 completes, e.g., `Validated YYYY-MM-DD — N rounds, 1 adversarial sub-agent confirmed`.]
