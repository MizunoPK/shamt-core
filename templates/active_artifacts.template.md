# Active Story Artifacts

**Story:** {slug}
**Path:** Quick path | Standard path
**Active baseline:** vN
**Updated:** YYYY-MM-DD
**Reason:** [Why the re-baseline occurred — e.g., "Requirements changed after build/checklist execution."]

---

## Active Files

<!-- Paths are relative to the resolved story folder (located per templates/SHAMT_RULES.template.md §PO-tree resolution; the folder nests under epics/.../features/.../). -->

| Artifact | Path |
|---|---|
| Spec | `stories/{slug}/spec_vN.md` |
| Context | `stories/{slug}/context_vN.md` (or `N/A — Quick path`) |
| Implementation Plan | `stories/{slug}/implementation_plan_vN.md` (or `N/A — Quick path`) |
| Testing Plan | `stories/{slug}/testing_plan_vN.md` (or `N/A — no automated suites` / `N/A — Quick path inline checklist`) |
| Manual Test Plan | `stories/{slug}/manual_test_plan_vN.md` (or `N/A — not produced`) |
| Agent Test Session | `stories/{slug}/agent_test_session_vN.md` |
| Mermaid Diagram | `stories/{slug}/diagram_vN.md` (optional supporting metadata; use `N/A — not generated`) |

## Superseded Baselines

| Baseline | Files | Reason |
|---|---|---|
| v1 | `spec.md`, `context.md`, `implementation_plan.md` | [Why superseded — e.g., "Superseded by requirements change received after Build"] |

## Current Code State

[Required. Describe whether code from the superseded plan remains in the working tree, was reverted, or must be adapted by the active plan. This is the single source of truth for builders encountering prior code changes.]

---

**Rules for agents:**

- If this file exists, use the files listed under "Active Files" for all story work. Do not infer the active version from filename or modification time.
- Do not overwrite or rename any file listed under "Superseded Baselines."
- Any command that creates a new baseline must update this file in the same pass.
