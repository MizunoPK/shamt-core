# Implementation Plan — Phase 2 — rules-file-over-budget (#09)

**Created:** 2026-06-08
**Index:** `proposals/09-rules-file-over-budget_PLAN.md`
**Proposal:** `proposals/09-rules-file-over-budget.md` (Validated 2026-06-07)
**Cut in this phase:** C3 — condense `## Pattern 3: Spec Protocol`, dropping the section-placement mechanics (owned by `/e2-define-spec`) and tightening verbose prose, **keeping every normative check**.
**File edited:** `templates/SHAMT_RULES.template.md` only.

> **Deploy order:** runs after Phase 1. Re-confirm the anchor against the live file (Phase 1 did not touch Pattern 3, so it is intact, but its line numbers shifted — use the text anchors).

---

## Step 1: C3 — replace Pattern 3 with the condensed version (proposal row 3)
**Operation:** EDIT
**File:** `templates/SHAMT_RULES.template.md`

**Coverage proof (run FIRST — confirm the dropped section-placement mechanics live in e2, and that the kept normative checks are intact in the replacement):**
```
grep -ci "Review Prevention Gates.*after Requirements\|Database Schema Changes.*after\|after .Interfaces" host/templates/claude/commands/e2-define-spec.md   # e2 owns section-placement → ≥1
```
Must return ≥1. If 0, **halt** — do not drop the placement mechanics (keep them inline). The condensed replacement below **retains** the data-lineage trace (the canonical owner that proposal C5 cross-refs to), the full prevention-requirement list, and the Gate 2a/2b contracts — verify post-edit (Verification block).

**Details — one block replacement:**
- **Locate** the entire Pattern 3 section: the span from the heading line `## Pattern 3: Spec Protocol` through the end of Step 7 — the line ending `…standard monitoring requirements must appear in Requirements or be explicitly Deferred with reason.` (the last line before the `## Pattern 4: Code Review Process` heading).
- **Replace** that entire span with exactly:

````
## Pattern 3: Spec Protocol

**Purpose:** Targeted research + design dialog + validated user-facing spec and supporting context. (The exact spec-template section placement — which section follows which — lives in the `/e2-define-spec` command body + `templates/spec.template.md`; this Pattern is the normative contract.)

### The 7-Step Spec Protocol

**Step 1 — Ingest the ticket.** Apply the active-artifact pointer and global story-folder resolution. Read `ticket.md` (or provided content); extract ask, acceptance criteria, links, due dates, constraints; output a 3–5 bullet in-agent summary; do not write to disk yet. Empty/missing content → halt and ask.

**Step 2 — Targeted research.** Scope to ticket references, not broad exploration: grep referenced files/functions/features; read `.shamt-core/project-specific-files/ARCHITECTURE.md` + `CODING_STANDARDS.md`; skim related code. Record findings in `context.md` (Standard) or `spec.md` Evidence (Quick). Required captures: **code shapes** (exact shapes needed for planning); **pre-existing gaps** (when refactoring — bring into scope or defer with reason; if none, say so); **current flow** (ASCII current-state once research suffices, unless narrowly in-process → record the N/A reason); **review-prevention risk inventory** (classify whether the story touches regulated/sensitive data, tenant isolation, auth/authorization, route/API contract, DB reads/writes, migrations, new service, monitoring, frontend rendering/auth flow, tests/test data, or removed/weakened checks — use `reference/pr_review_prevention.md`); **boundary-diagram evidence** (Mermaid is required for boundary-crossing stories — collect real source-backed component/interface names and flow evidence; a diagram cannot be the only place a component appears); **file placement** (record the governing rule under Architecture And Standards Notes when shared-utility placement matters).

**Step 3 — Draft skeletons.**

| Path | Required artifact shape |
|---|---|
| Standard | `spec.md` (from `templates/spec.template.md`) + `context.md` (from `templates/context.template.md`). `spec.md` is the approval contract; `context.md` is evidence/planning handoff. Approval-relevant persistence design and review-prevention requirements must appear in `spec.md`, not only `context.md`. Key Design Decision IDs appear in both. |
| Quick | `spec.md` only — populate Evidence, compact Review Prevention Evidence, Code Shapes, Review Prevention Checklist, Build Checklist, and Verification inline. Do not create `context.md` or `implementation_plan.md` unless the story escalates or a risk trigger applies. |

Optional Standard-path plan skeleton: after `spec.md`/`context.md`, create `implementation_plan.md` with exploratory headers only, mark unresolved decisions `Blocked:`, set Planning Status to "Blocked on spec (Gate 2a)"; do not fill locate strings until after Gate 2a.

**Step 4 — Architecture/design dialog (Gate 2a).** Present 1–3 design options inline in chat, not in `spec.md` yet: one option is fine when the choice is obvious, 2–3 are required for non-trivial user-facing forks; each needs description, pros, cons, effort (S/M/L), and a recommendation (if an option has no meaningful downside, say so). For open sub-questions, use `reference/question_brainstorm_categories.md` and omit empty categories. Mermaid diagrams are not part of Spec creation — for boundary-crossing stories, record enough approved design-option, workflow, schema, and source-backed component evidence for a later Mermaid generation step; an existing Mermaid block is optional supporting material, do not create or update it during Spec. **Wait for explicit user confirmation before proceeding.**

**Step 5 — Flesh out spec/context.** Record the agreed approach: Standard keeps `spec.md` concise and approval-facing while `context.md` carries detailed rationale, evidence, current flow, standards notes, and code shapes; Quick keeps all of that inline in `spec.md`. Before placing anything in Open Questions, answer it from the codebase — only product/team/external-system decisions remain open, surfaced one at a time (Principle 2). For each applicable high-risk surface, state the approval-facing **prevention requirement**: no regulated or sensitive data in logs / responses / metrics / alarms; tenant identity source and enforcement point; route authorizer/integration expectation; DB writer routing for direct and transitive writes; standard monitoring on new services; tests or verification strategy; replacement/preservation for removed or weakened checks — Standard stores detailed evidence in `context.md`, Quick stores compact evidence inline in `spec.md`; if a prevention surface is itself a risk trigger, escalate to Standard path. For any schema, migration, or table-level change, the spec must explicitly trace the end-to-end cross-service read and write data lineage across service boundaries to ensure data is not written but ignored or dropped at runtime; if a required backchannel API, query route, or configuration endpoint does not exist yet, the spec must either include its creation as in-scope or list it as a Blocker under Open Questions and escalate for Gate 2a/2b pre-approval vetting; new tables list columns, existing-table changes list deltas only, candidate schema options must be reviewable when undecided, and explicitly defer schema changes when out of scope. Standard path does not add a Files Affected inventory to the spec (file-level work belongs in the plan); Quick uses Review Prevention Checklist and Build Checklist for files, prevention gates, and sequential mechanical steps. Resolve all parallel-skeleton `Blocked:` markers after Gate 2a.

**Step 6 — Validate.**

- **Standard path:** run Pattern 1 on the `spec.md` + `context.md` pair using spec dimensions plus five pair checks — every factual claim in `spec.md` is supported by `context.md`; every Key Design Decision ID appears in both without contradiction; approval-relevant schema/persistence in `context.md` appears in `spec.md` unless deferred/out of scope; implementation-relevant prevention evidence in `context.md` appears in `spec.md` when approval-relevant; multi-option comparisons give each option explicit pros/cons. Treat schema-only-in-context, approval-relevant prevention-only-in-context, and missing per-option pros/cons as HIGH by default. If a Mermaid diagram is recorded in the active artifacts, verify it renders, every node/edge is research- or decision-backed, it does not contradict spec/context, and it conforms to `reference/mermaid_diagram_standards.md`. Exit: primary clean + 1 adversarial sub-agent; footer both files.
- **Quick path:** run Pattern 1 on `spec.md` alone (Requirements, Evidence, Review Prevention Gates/Evidence/Checklist, Code Shapes, Build Checklist, Verification); one primary clean pass is enough unless a risk trigger requires an adversarial sub-agent; footer `spec.md`.

Each round ask, "What code should I have read that I haven't?" — and read it.

**Step 7 — User approval (Gate 2b).** Present the validated `spec.md` as the approval artifact and link `context.md` as supporting detail (Standard path). If a new service is in scope, standard monitoring requirements must appear in Requirements or be explicitly Deferred with reason.
````

**Verification (every kept normative rule survives + placement mechanics dropped):**
```
# placement mechanics dropped (the "Add X after Y" instructions):
grep -c "Add \`Review Prevention Gates\` after\|Add \`Database Schema Changes\` after" templates/SHAMT_RULES.template.md   # → 0
# kept normative rules present (data-lineage owner for C5; prevention list; gates; captures):
grep -c "trace the end-to-end cross-service read and write data lineage" templates/SHAMT_RULES.template.md   # → 1 (Pattern 3 still owns it; another may exist in Pattern 1 until Phase 3 C5)
grep -c "no regulated or sensitive data in logs / responses / metrics / alarms" templates/SHAMT_RULES.template.md   # → 1
grep -c "review-prevention risk inventory" templates/SHAMT_RULES.template.md   # → 1
grep -c "Wait for explicit user confirmation before proceeding" templates/SHAMT_RULES.template.md   # → 1 (Gate 2a)
grep -c "five pair checks" templates/SHAMT_RULES.template.md   # → 1 (Gate 2b/validate)
grep -c "## Pattern 3: Spec Protocol" templates/SHAMT_RULES.template.md   # → 1
grep -c "## Pattern 4: Code Review Process" templates/SHAMT_RULES.template.md   # → 1 (boundary intact)
# modal preservation — condensation must NOT soften a normative "must" to an indicative:
grep -c "candidate schema options must be reviewable when undecided" templates/SHAMT_RULES.template.md   # → 1
grep -c "the spec must either include its creation as in-scope or list it as a Blocker" templates/SHAMT_RULES.template.md   # → 1
grep -c "standard monitoring requirements must appear in Requirements" templates/SHAMT_RULES.template.md   # → 1
```
**If any modal-preservation grep returns 0, halt** — the condensation softened a normative MUST; restore it verbatim.

---

## Phase 2 exit
- Pattern 3 condensed; placement mechanics gone; every normative check (data-lineage trace, prevention requirements, research captures, Gate 2a/2b contracts) retained.
- `wc -m templates/SHAMT_RULES.template.md` ≈ **33,700** (informational). **No commit.** Next: Phase 3 (C4 + C5).

---

## Notes
- The data-lineage trace is deliberately **kept** in Pattern 3 Step 5 — it is the canonical owner that proposal C5 (Phase 3) cross-refs Pattern 1's restatement to. Removing it here would break C5.
- Only `templates/SHAMT_RULES.template.md` is edited. The dropped section-placement lives in `/e2-define-spec` (coverage proof above). No `.claude/`, no destination edits, no commit.

---
Validated 2026-06-08 — multiple rounds, adversarial sub-agent confirmed. The C3 Pattern-3 condensation was the highest-risk cut; validation caught and fixed **five modal-softenings** (must-be-reviewable, must-either-include, Do-not-create, explicitly-defer, resolve-all — all restored to original force) and ran an **exhaustive imperative/rule-preservation diff** confirming every normative MUST/imperative/Gate/hard-check from the original Pattern 3 survives in the condensed version. The data-lineage trace is kept (C5's owner); section-placement coverage in e2 verified; modal-preservation greps added to the verification block.
