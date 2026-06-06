---
description: Phase 3 (Plan, Standard path) — turn an approved spec into a mechanical, validated implementation plan; chains to /e3b-write-testing-plan when testing is enabled
---

# /e3-plan-implementation

**Purpose:** Run the Pattern 5 Implementation Planning protocol on a story whose spec has been approved at Gate 2b. Produce a mechanical, validated `implementation_plan.md` ready for builder handoff. When `.shamt-core/shamt-config.json` sets `testing: "enabled"`, this command also invokes `/e3b-write-testing-plan {slug}` as a sub-phase before exit.

**Recommended models:**

- Authoring: Balanced (Sonnet) — structural step decomposition.
- Validation loop primary: Reasoning (Opus). Sub-agent: Cheap (Haiku) via `validation-checker`.

See [`reference/model_selection.md`](../../../../reference/model_selection.md).

---

## Usage

```
/e3-plan-implementation {slug}
```

## Arguments

- `{slug}` (required) — story slug. Resolved via the global story-folder rules (exact `stories/{slug}/`, then `stories/{slug}-*/` glob; halt on multiple or zero matches).

## Path applicability

**Standard path only.** Quick-path stories skip Phase 3 entirely — the spec's `Build Checklist` is the executable artifact. If the active spec declares `Path: Quick path`, report:

```text
Quick path is active for {slug}; skipping separate implementation plan.
Execute the spec's Build Checklist directly. Escalate to a full plan if the
checklist exceeds 10 steps, you need a builder sub-agent, exact locate/replace
detail is required, verification is complex, or the user asks for Gate 3.
```

…then exit without writing `implementation_plan.md`.

If the user explicitly requests Gate 3 planning on a Quick story, escalate to Standard for this command's run and continue with the steps below.

## Prerequisites

- Story folder resolves; if `stories/{slug}/active_artifacts.md` exists, read it first and use the Active Files instead of unversioned baselines.
- `spec.md` (or the active baseline) exists, has a validation footer, and is approved at Gate 2b. If not, halt and direct the user to `/e2-define-spec {slug}`.
- On Standard path, `context.md` (or the active baseline) exists with a validation footer.
- `Open Questions` in the active spec is empty (or contains only explicitly deferred items with reasons). If unresolved questions remain, halt and ask.

## The 5-step process

### Step 1 — Read spec / context and confirm decisions

1. Apply the active-artifact pointer.
2. Read the active spec and context completely. Re-read sections referenced by Key Design Decision IDs.
3. Research repo conventions for file placement, sibling shapes, naming, and deployment. For new services, plan the standard monitoring template, verify outbound auth from siblings, confirm required configuration.
4. For EDIT steps, look up only the 5–10 lines around each target symbol; reuse code shapes recorded in `context.md` (or in Quick-path `spec.md` if this is a Quick-to-Standard escalation).

### Step 2 — Create the mechanical plan

Draft `stories/{slug}/implementation_plan.md` from [`templates/implementation_plan.template.md`](../../../../templates/implementation_plan.template.md). Every step must be executable without design judgment.

**Skeleton-first authoring** (recommended for plans with 5+ steps): write all headers, sanity-check structure, then fill locate strings and verification just-in-time.

**Plan contract** (see [`reference/implementation_plan_reference.md`](../../../../reference/implementation_plan_reference.md) for expanded examples):

- No optional branches, vague gates, unresolved `if / when / consider`, or executor judgment.
- Stop planning if any step is unclear — do not paper over with executor judgment.
- Verification failure is **stop-and-escalate**, not permission to improvise.
- Plans over one deploy boundary, any phase over 10 steps, or about 1500+ lines require a **validated index plus validated phase files** — split the plan and re-validate.
- Plans touching multiple repos include `Step 0-A`, `Step 0-B`, etc.; each branch-prep step must fetch the configured remote development branch and create `feature/{slug}/<owner-or-team>` from the fetched remote branch. Commits use the `#{slug}: {message}` form.
- Include metadata, pre-execution checklist, files manifest with no optional rows, Review Prevention Gate Mapping, numbered steps, verification, Notes, and `CODING_STANDARDS` compliance mapping.

**Operation contracts:**

- **CREATE** — concrete workspace-relative path plus full initial content (or named in-repo template / copied sibling with concrete deltas).
- **EDIT** — exact locate string plus exact replacement.
- **DELETE** — file / section plus justification.
- **MOVE** — separate CREATE and DELETE sub-steps, each verified.

**Hard planning checks:**

- Every applicable review-prevention item from spec / context maps to concrete step(s), verification step(s), or explicit N/A reason in `## Review Prevention Gate Mapping`.
- DB write paths: trace direct and transitive writes and plan the writer-routing decision before any build step proceeds.
- New or changed services / routes: require manifest coverage or explicit N/A for handler, application module, route module, monitoring template, packaging, environment, IAM/secrets, log retention, networking, and deployment / stage updates.
- Tenant / path / object / document changes: plan a tenant-A-to-tenant-B bypass verification when feasible, or state why it cannot be run.
- Removed / weakened checks: include replacement analysis before the code-edit step.
- New service handlers: enumerate transitive call graph for imported shared utilities, reachable environment-variable keys, and reachable external resource accesses **before** drafting environment / IAM steps; add any missing symbols / env / IAM steps before proceeding.
- Byte-for-byte copy files: verify every called function has identical signature/behavior in every repo maintaining that file; if any dependency differs, place the function repo-specifically and record why.
- `.shamt-core/project-specific-files/CODING_STANDARDS.md`: map each applicable rule to an existing step, new step, or explicit N/A in `## CODING_STANDARDS Compliance`. Merely saying it was read is insufficient.
- Migration CREATE steps: cover table creation, any required row-level security policy in the same block, and information-schema verification.

**Open-questions iterative dialog (Principle 2 in [`SHAMT_RULES.template.md`](../../../../templates/SHAMT_RULES.template.md)):** maintain an `## Open Questions` section in the plan as you draft. Surface each question to the user **one at a time** via `AskUserQuestion`. Update the plan with each answer before moving on. The plan is not "drafted" while open questions remain. Code-research every question first — only product / platform / team decisions remain open.

### Step 3 — Validate the plan

Invoke `/validate-artifact stories/{slug}/implementation_plan.md`. Uses the 8 plan dimensions. Exit: primary clean + 1 adversarial sub-agent (Standard path is the default for plan validation; the plan never runs Quick-path validation). Footer the plan.

If validation finds CRITICAL / HIGH issues that originate in the spec, halt and either re-baseline (per the Re-baseline Protocol in [`SHAMT_RULES.template.md`](../../../../templates/SHAMT_RULES.template.md)) or patch the spec via `/e2-define-spec` and re-validate.

### Step 4 — Write the testing plan (when enabled)

Read `.shamt-core/shamt-config.json` → `testing`. If `enabled`, invoke `/e3b-write-testing-plan {slug}` as a sub-phase. It produces `stories/{slug}/testing_plan.md` (or escalates the Quick-path inline checklist when scope is small) and runs its own validation loop before returning. Do not advance to Gate 3 until the testing plan is validated.

If `testing: "disabled"`, skip this step. `/e3b-write-testing-plan` would be a no-op anyway, but skipping the invocation keeps the chat output clean.

### Step 5 — Gate 3 (user approval)

Present the validated plan (and, when applicable, the validated testing plan) for user approval. Highlight:

- The Files Touched manifest.
- The Review Prevention Gate Mapping.
- Any multi-repo branch-prep steps.
- Any CODING_STANDARDS rules mapped to specific steps.

Wait for explicit user approval at Gate 3.

On approval, suggest a context-clear breakpoint: `/clear`, then `/e4-execute-plan {slug}` (Phase 4, Build). Builder handoff is **unconditional** after Gate 3 — the architect plans, the cheap-tier builder executes.

## Exit criteria

- `stories/{slug}/implementation_plan.md` exists, fully populated, with the validation footer.
- When testing is enabled, `stories/{slug}/testing_plan.md` (or the spec's inline checklist on Quick escalations) exists with its validation footer.
- Open Questions in the plan is empty (or contains only explicitly deferred items with reasons).
- User has approved at Gate 3.

## Notes

- This command is **fresh-agent runnable**: every input lives on disk (active artifacts pointer, spec, context, governing docs, config). State is determined by artifact presence; no conversation history required.
- **Single-session sizing constraint:** if the plan would compact within a session, split it. Either decompose into phase files (`implementation_plan_phase_1.md`, `…_phase_2.md`, …) with an index, or hand individual phases to a builder one at a time after Gate 3.
- Builder handoff is **unconditional** after Gate 3 — the architect does not execute steps themselves. Single-file plans hand off `implementation_plan.md`; phase-decomposed plans hand off one phase at a time in deploy order.
- Plans never run Quick-path validation — the 1-LOW-allowance grace + sub-agent confirmation pattern applies because the plan determines mechanical execution.
- Multi-repo plans include `Step 0-A`, `Step 0-B`, etc. — each branch-prep step fetches the configured remote development branch and creates `feature/{slug}/<owner-or-team>` from it.

---
Validated 2026-05-28 — 2 rounds, 1 adversarial sub-agent confirmed (Phase 5 implementation loop)

<!-- Managed by Shamt — do not edit. Regenerate from shamt-core/host/templates/claude/commands/e3-plan-implementation.md. -->
