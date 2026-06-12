---
description: Phase 2 (Spec) — run the 7-step Spec Protocol, dialog through design at Gate 2a, validate, and deliver an approved spec at Gate 2b
---

# /e2-define-spec

**Purpose:** Run the Pattern 3 Spec Protocol on a story — targeted research, design dialog (Gate 2a), spec/context production, validation, and approval (Gate 2b).

**Recommended models:**

- Research: Balanced (Sonnet) — code reading, structural analysis.
- Design dialog (Gate 2a): Reasoning (Opus) — multi-option comparison.
- Validation loop primary: Reasoning (Opus). Sub-agent: Cheap (Haiku) via `validation-checker`.

See [`reference/model_selection.md`](../../../../reference/model_selection.md) for the per-phase tier table.

---

## Usage

```
/e2-define-spec {slug}
```

## Arguments

- `{slug}` (required) — story slug. The command resolves the story folder via the standard globbing rules and requires a populated `ticket.md` to exist there.

## Prerequisites

- Resolve the story folder per `templates/SHAMT_RULES.template.md` §PO-tree resolution (tree-wide glob + legacy-flat fallback); `stories/{slug}/` below denotes that resolved folder.
- `ticket.md` exists in that folder and is non-empty. If not, halt and direct the user to `/e1-start-story {slug}`.
- `.shamt-core/project-specific-files/ARCHITECTURE.md` and `.shamt-core/project-specific-files/CODING_STANDARDS.md` exist at the project root. Note their absence inline if either is missing (per the **Standards check** invariant in [`SHAMT_RULES.template.md`](../../../../templates/SHAMT_RULES.template.md#global-story-invariants)) and continue.
- If `stories/{slug}/active_artifacts.md` exists, read it first and use the artifact paths listed under **Active Files** instead of unversioned baselines.

## Path selection

After ingesting the ticket, decide Quick vs Standard per the path-selection rules in [`SHAMT_RULES.template.md`](../../../../templates/SHAMT_RULES.template.md) (Engineer Flow — Path Selection). Apply Standard when any risk trigger fires (>10 steps, multiple deploy boundaries, new service / DB table / migration / backfill, auth or tenant boundary, public API or event contract change, material architecture boundary crossing, significant design ambiguity after research, or explicit user request). When uncertain, default to Standard.

State the chosen path and the reason in one line before drafting.

## The 7-step Spec Protocol

### Step 1 — Ingest the ticket

1. Read `stories/{slug}/ticket.md` completely. If empty or missing, halt and direct the user to `/e1-start-story`.
2. Extract: ask, acceptance criteria, links, due dates, constraints.
3. Produce a 3–5 bullet in-agent summary. **Do not write the spec yet.**

### Step 2 — Targeted research

Scope research to what the ticket references — not a broad codebase exploration.

1. Grep the referenced files / functions / features and read the relevant slices.
2. Read the project rules file (rendered from [`SHAMT_RULES.template.md`](../../../../templates/SHAMT_RULES.template.md)) plus `.shamt-core/project-specific-files/ARCHITECTURE.md` and `.shamt-core/project-specific-files/CODING_STANDARDS.md` per Pattern 3 Step 2. Record story-specific standards / architecture notes for reuse.
3. Capture **research findings** — code shapes, pre-existing gaps, the current end-to-end flow, file-placement rules, review-prevention risk inventory (use [`reference/pr_review_prevention.md`](../../../../reference/pr_review_prevention.md)); see [`reference/spec_protocol_reference.md`](../../../../reference/spec_protocol_reference.md) for the full required-captures enumeration.
4. Record:
   - **Standard path:** detailed findings in `stories/{slug}/context.md` (drafted from [`templates/context.template.md`](../../../../templates/context.template.md)).
   - **Quick path:** compact findings inline in `stories/{slug}/spec.md` under `## Evidence` (drafted from [`templates/spec.template.md`](../../../../templates/spec.template.md)).
5. If the change crosses a meaningful boundary (API, persistence, queue, file, service), record an ASCII current-state flow in `context.md` (Standard) or under `## Evidence` (Quick). If genuinely narrow in-process, record the N/A reason explicitly.

Boundary-crossing stories must collect source-backed component / interface / flow evidence so a Mermaid diagram **can later be generated** by the dedicated diagram workflow. Spec does not author Mermaid; see [`reference/mermaid_diagram_standards.md`](../../../../reference/mermaid_diagram_standards.md).

### Step 3 — Draft skeletons

| Path | Skeleton |
|------|----------|
| Standard | Create `stories/{slug}/spec.md` from [`templates/spec.template.md`](../../../../templates/spec.template.md) and `stories/{slug}/context.md` from [`templates/context.template.md`](../../../../templates/context.template.md). `spec.md` is the Gate 2b approval contract; `context.md` carries detailed rationale, evidence, current flow, standards notes, and code shapes. Approval-relevant persistence design and review-prevention requirements appear in `spec.md`, not only `context.md`. Key Design Decision IDs (`D1`, `D2`, …) appear in both. |
| Quick | Create `stories/{slug}/spec.md` only. Populate Evidence, compact Review Prevention Evidence, Code Shapes, Review Prevention Checklist, Build Checklist, and Verification inline. Do **not** create `context.md` or `implementation_plan.md` unless the story escalates. |

Optional Standard-path plan skeleton: after `spec.md` / `context.md`, create `implementation_plan.md` with only exploratory headers and `Blocked:` markers. Set Planning Status to "Blocked on spec (Gate 2a)". Do not fill locate strings until Gate 2a clears.

### Step 4 — Architecture / design dialog (Gate 2a)

Present 1–3 design options **inline in chat** — not in `spec.md` yet. Each option needs description, pros, cons, effort (S/M/L), and a recommendation. One option is fine when the choice is obvious; 2–3 are required for non-trivial user-facing forks. If an option has no meaningful downside, say so explicitly.

If open sub-questions exist, surface them using the 6 brainstorm categories ([`reference/question_brainstorm_categories.md`](../../../../reference/question_brainstorm_categories.md)) — but only show categories that produced questions.

**Open-questions iterative dialog (Principle 2 in [`SHAMT_RULES.template.md`](../../../../templates/SHAMT_RULES.template.md)):**

- Maintain an `## Open Questions` section in the active artifact (`spec.md` for Quick path; `spec.md` + `context.md` for Standard) as you draft.
- Surface each question to the user **one at a time** via `AskUserQuestion` (or equivalent). Never bulk-bomb.
- Update the artifact with each answer before moving to the next question.
- The artifact is **not drafted** while open questions remain.
- Before placing a question in Open Questions, **try to answer it from the codebase**. Code-research every question first; only product / team / external-system decisions remain open.

Wait for explicit user confirmation of the design before proceeding to Step 5.

Mermaid diagrams are **not** authored during Spec. For boundary-crossing stories, record enough approved design-option, workflow, schema, and source-backed component evidence for the later diagram-generation workflow to use. If a Mermaid block already exists in the active story artifacts, treat it as optional supporting material; do not create or update Mermaid here.

### Step 5 — Flesh out spec / context

Record the agreed approach.

- **Standard path:** keep `spec.md` concise and approval-facing; `context.md` carries detailed rationale, evidence, current flow, standards notes, and code shapes.
- **Quick path:** keep all of that inline in `spec.md`.

Required elements:

- **`Review Prevention Gates`** (after Requirements or Interfaces) — for each applicable surface (regulated/sensitive data; tenant; auth/route; DB; infra; frontend; testing; removed/weakened checks), state the approval-facing prevention requirement. Standard path stores detailed evidence in `context.md`; Quick path stores compact evidence inline. If a prevention surface is itself a risk trigger, **escalate to Standard path**.
- **`Database Schema Changes`** (after `Interfaces and Boundaries`) — required when schema is added or modified, or when candidate persistence designs need approval. For any schema change, trace the end-to-end cross-service read/write data lineage across service boundaries (ensure data is not written but ignored or dropped at runtime). New tables list columns; modified tables list deltas. Candidate options must be reviewable when undecided. Explicitly defer schema changes when out of scope.
- **`Test Strategy`** (when `.shamt-core/shamt-config.json` sets `testing: "enabled"`) — see [`SHAMT_RULES.template.md`](../../../../templates/SHAMT_RULES.template.md#when-automated-testing-is-enabled). Approval-relevant at Gate 2b. List test kinds in scope, existing test files relevant, new test files needed, and project conventions to follow. Quick path with ≤5 test steps and no new file may use the spec's inline `Quick path inline test checklist`; otherwise the full `testing_plan.md` is produced in Phase 3.
- **`Key Design Decisions`** table — assign `D1`, `D2`, … IDs. Same IDs appear in both `spec.md` and `context.md` (Standard path) without contradiction.
- **`Open Questions`** — only unresolved product / platform / team decisions remain. Code-answerable questions must have been resolved by research, not surfaced.

Standard path does **not** add a Files Affected inventory to the spec; file-level work belongs in the plan. Quick path uses the Review Prevention Checklist and Build Checklist for files, prevention gates, and sequential mechanical steps. If a parallel plan skeleton exists, resolve all `Blocked:` markers after Gate 2a clears.

### Step 6 — Validation

Invoke `/validate-artifact` against the active artifact(s):

- **Standard path:** validate the pair — `/validate-artifact stories/{slug}/spec.md + stories/{slug}/context.md`. Uses 8 spec dimensions + 5 pair-consistency checks. Exit: primary clean + 1 adversarial sub-agent. Footer both files.
- **Quick path:** validate `stories/{slug}/spec.md` alone. 8 spec dimensions. Exit: single primary clean pass, **unless** a risk trigger applies — then escalate to a sub-agent confirmation. Footer `spec.md`.

Each round, ask "What code should I have read that I haven't?" and read it.

### Step 7 — User approval (Gate 2b)

Present the validated `spec.md` as the approval artifact. On Standard path, link `context.md` as supporting detail. Highlight:

- The agreed design (with Key Design Decision IDs).
- The Requirements list.
- The Review Prevention Gates row by row.
- The Test Strategy (when testing is enabled).
- Any Database Schema Changes.

If a new service is in scope, standard monitoring requirements must appear in Requirements or be explicitly Deferred with reason.

Wait for explicit user approval. Once approved, suggest a context-clear breakpoint: `/clear`, then `/e3-plan-implementation {slug}` (Standard path) or `/clear`, then build directly from the Build Checklist (Quick path).

## Exit criteria

- `stories/{slug}/spec.md` exists, fully populated, with the validation footer.
- On Standard path, `stories/{slug}/context.md` exists with the validation footer.
- Open Questions section is empty (or contains only explicitly deferred items with reasons).
- User has approved at Gate 2b.

## Notes

- This command is **fresh-agent runnable**: every input lives on disk (config, ticket, governing docs). State is determined by artifact presence; no conversation history required.
- **Single-session sizing constraint:** if the spec would compact within a session, split the work — invoke an architect-style sub-agent for the heaviest research and have the primary agent integrate findings. See [`SHAMT_RULES.template.md`](../../../../templates/SHAMT_RULES.template.md) Principle 1.
- The open-questions iterative dialog is mandatory — one question at a time, via `AskUserQuestion`, updating the artifact with each answer. No bulk question-bombing. No proceeding on assumptions.
- The Test Strategy section is approval-relevant at Gate 2b only when testing is enabled. Omit it entirely when `testing: "disabled"`.
- Mermaid diagrams are not authored here. Use the dedicated diagram workflow after Spec — see [`reference/mermaid_diagram_standards.md`](../../../../reference/mermaid_diagram_standards.md) and [`reference/mermaid_recipes.md`](../../../../reference/mermaid_recipes.md).
- Standard path next: `/e3-plan-implementation {slug}`. Quick path next: build from the spec's Build Checklist directly (no `/e3-plan-implementation` required).

---
Validated 2026-05-28 — 2 rounds, 1 adversarial sub-agent confirmed (Phase 5 implementation loop)

<!-- Managed by Shamt — do not edit. Regenerate from shamt-core/host/templates/claude/commands/e2-define-spec.md. -->
