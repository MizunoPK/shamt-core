# Story Support Reference

Supporting examples and quick-reference material for the Engineer-flow story workflow (six phases by default; seven when automated testing is enabled).

## Context-clear handoff snippets

After Gate 2a:

```text
Story: {slug} — Gate 2a complete (design approved).
Spec/context are filled in. Reconcile any draft plan skeleton and fill locate-string details just in time.
```

After Gate 2b:

```text
Story: {slug} — Gate 2b complete (spec validated and approved).
Use context.md as the planning source of truth. Fill plan details per step without broad re-reading.
```

After Gate 3:

```text
Story: {slug} — Gate 3 complete (plan validated and approved).
Hand off to the builder. For phase-decomposed plans, execute in deploy order.
```

After Review:

```text
Story: {slug} — Review complete.
Inventory the feedback folder, update addressed_feedback.md, and process remaining comments.
```

## Story artifact layout

### Quick path (no findings / clean review)

```text
stories/{slug}/
|-- ticket.md
`-- spec.md (includes embedded Evidence, Code Shapes, Build Checklist, Verification, and Post-Build Review)
```

### Quick path (with findings)

```text
stories/{slug}/
|-- ticket.md
|-- spec.md (includes embedded Evidence, Code Shapes, Build Checklist, and Verification)
`-- feedback/
    |-- review_v1.md
    `-- addressed_feedback.md
```

### Standard path layout

```text
stories/{slug}/
|-- ticket.md
|-- active_artifacts.md
|-- spec.md
|-- spec_vN.md
|-- context.md
|-- context_vN.md
|-- implementation_plan.md
|-- implementation_plan_vN.md
|-- implementation_plan_phase_1.md
`-- feedback/
    |-- review_v1.md
    |-- review_v2.md
    |-- <human-feedback>.md
    `-- addressed_feedback.md
```

When `.shamt-core/shamt-config.json` sets `testing: "enabled"`, both paths gain a `testing_plan.md` (Quick path: inline checklist in `spec.md`, escalating to a full file at >5 steps or a new test file; Standard path: dedicated artifact alongside `implementation_plan.md`). Either path may add `manual_test_plan.md` post-Build via `/e5b-write-manual-testing-plan {slug}`.

Unversioned artifact names are always baseline v1. Use `active_artifacts.md` as the authoritative pointer when v2+ baselines exist.

## Addressed feedback outline

`stories/{slug}/feedback/addressed_feedback.md` typically contains:

- a source-files table
- a comment log table
- one handling-details section per tracked comment
- final status coverage for every selected comment

Allowed statuses:

- `Pending`
- `Addressed`
- `Deferred`
- `Rejected`
- `Duplicate`
- `Not applicable`
- `Needs user decision`

---
Validated 2026-05-27 — 5 rounds, 1 adversarial sub-agent confirmed (Phase 2 reference-library loop)
