# Implementation Plan — Phase 2: Engineer skill dirs

**Proposal:** proposals/49-engineer-flow-single-integer-phase-numbering.md
**Plan index:** proposals/49-engineer-flow-single-integer-phase-numbering_PLAN.md
**Covers:** Proposed Changes rows 14–26 (host/templates/claude/skills/)
**Created:** 2026-06-21

## Steps

### Step 2.1 — Row 14: EDIT e1-start-story/SKILL.md (renumbered next-phase)

**Operation:** EDIT
**File:** host/templates/claude/skills/e1-start-story/SKILL.md

The `description` and Protocol pointer require no path/Quick-Standard wording change (Intake is unchanged at Phase 1). The Exit-criteria line does not reference a next phase. The only renumber-relevant content is the Overview line; it is invariant. No locate/replace is required for this skill's body **except** confirming there is no stale next-phase pointer. Inspection of the file shows no `/e2`…`/e9` reference and no Quick/Standard wording, so this row is a **no-op edit at the skill layer** — the renumbered next-phase pointer lives in the command body (`commands/e1-start-story.md`, Phase 1 of plan), not the SKILL.

To keep the row honest and verifiable, perform the following confirming verification (no edit applied):

**Verification:**
```
grep -nE '/e[2-9]|Quick|Standard|next phase|next-phase' host/templates/claude/skills/e1-start-story/SKILL.md
```
Expect: zero matches. (The pattern deliberately excludes `/e1` so it does not match this skill's own self-referential `/e1-start-story` Overview / Protocol / footer lines — it checks only for a stale *next-phase* pointer `/e2`…`/e9` or Quick/Standard wording. If any match appears, PLAN-BLOCKER — the description carries renumber-relevant text not seen at author time.)

### Step 2.2 — Row 15: EDIT e2-define-spec/SKILL.md description (no path selection, context always)

**Operation:** EDIT
**File:** host/templates/claude/skills/e2-define-spec/SKILL.md

**Locate:**
```
description: >
  Run Phase 2 (Spec) of the Shamt Engineer flow on a story whose ticket has
  been captured. Targeted research; design dialog at Gate 2a with 1–3 option
  comparisons; spec/context drafting (Standard) or compact spec (Quick);
  validation; and Gate 2b approval. Invoke when the user wants to spec a
  story, design the approach, run the spec protocol, write a spec, draft
  spec/context, or work through the design dialog for an intaken ticket.
```

**Replace:**
```
description: >
  Run Phase 2 (Spec) of the Shamt Engineer flow on a story whose ticket has
  been captured. Targeted research; design dialog at Gate 2a with 1–3 option
  comparisons; spec.md + context.md drafting (always full — no path selection);
  validation; and Gate 2b approval. Invoke when the user wants to spec a
  story, design the approach, run the spec protocol, write a spec, draft
  spec/context, or work through the design dialog for an intaken ticket.
```

**Verification:**
```
grep -nE 'Quick|Standard|compact spec' host/templates/claude/skills/e2-define-spec/SKILL.md
```
Expect: zero matches.

### Step 2.3 — Row 15b: EDIT e2-define-spec/SKILL.md Exit criteria (context.md always, no Standard gate)

**Operation:** EDIT
**File:** host/templates/claude/skills/e2-define-spec/SKILL.md

**Locate:**
```
Validated `spec.md` (and `context.md` on Standard) approved by the user at Gate 2b; Open Questions empty or deferred with reason.
```

**Replace:**
```
Validated `spec.md` and `context.md` approved by the user at Gate 2b; Open Questions empty or deferred with reason.
```

**Verification:**
```
grep -n 'on Standard' host/templates/claude/skills/e2-define-spec/SKILL.md
```
Expect: zero matches.

### Step 2.4 — Row 16: EDIT e3-plan-implementation/SKILL.md description (mandatory plan, no Quick/Standard, next → /e4)

**Operation:** EDIT
**File:** host/templates/claude/skills/e3-plan-implementation/SKILL.md

**Locate:**
```
description: >
  Run Phase 3 (Plan) of the Shamt Engineer flow — Standard path only — turning
  an approved spec into a mechanical, validated implementation plan ready for
  builder handoff at Gate 3. Chains into /e3b-write-testing-plan when TESTING_STANDARDS.md declares
  automated suites. Invoke when the user wants to plan the implementation, draft the
  implementation plan, run the plan phase, prepare the builder handoff, or
  break the spec into mechanical steps. Skips with a clear notice on Quick-path
  stories (build directly from spec.md).
```

**Replace:**
```
description: >
  Run Phase 3 (Plan) of the Shamt Engineer flow — mandatory for every story —
  turning an approved spec into a mechanical, validated implementation plan ready
  for builder handoff at Gate 3. Testing-plan authoring moves to /e4-write-test-plan
  (the next phase). Invoke when the user wants to plan the implementation, draft the
  implementation plan, run the plan phase, prepare the builder handoff, or
  break the spec into mechanical steps.
```

**Verification:**
```
grep -nE 'Quick|Standard|/e3b' host/templates/claude/skills/e3-plan-implementation/SKILL.md
```
Expect: zero matches in the description block (the Exit-criteria edit in Step 2.5 removes the remaining `/e3b`/Standard wording).

### Step 2.5 — Row 16b: EDIT e3-plan-implementation/SKILL.md Exit criteria (drop testing_plan + Standard gate)

**Operation:** EDIT
**File:** host/templates/claude/skills/e3-plan-implementation/SKILL.md

**Locate:**
```
Validated `implementation_plan.md` (and `testing_plan.md` when TESTING_STANDARDS.md declares automated suites) approved at Gate 3; Open Questions empty or deferred with reason. Builder handoff is unconditional after Gate 3 — the architect plans, the cheap-tier builder executes.
```

**Replace:**
```
Validated `implementation_plan.md` approved at Gate 3; Open Questions empty or deferred with reason. Test-plan authoring (`user_test_plan.md` always, `testing_plan.md` when TESTING_STANDARDS.md declares suites) is the next phase, `/e4-write-test-plan`. Builder handoff is unconditional after Gate 3 — the architect plans, the cheap-tier builder executes.
```

**Verification:**
```
grep -nE 'testing_plan\.md\) approved|when TESTING_STANDARDS\.md declares automated suites\) approved' host/templates/claude/skills/e3-plan-implementation/SKILL.md
```
Expect: zero matches (the old combined "(and testing_plan.md …) approved" phrasing is gone). Then:
```
grep -n '/e4-write-test-plan' host/templates/claude/skills/e3-plan-implementation/SKILL.md
```
Expect: ≥1 match.

### Step 2.6 — Row 17: DELETE e3b-write-testing-plan/SKILL.md

**Operation:** DELETE
**Path:** host/templates/claude/skills/e3b-write-testing-plan/ (the whole skill dir)
**Justification:** Row 17 — the `/e3b-write-testing-plan` command is deleted (proposal row 5); its mirror skill must be removed too. The automated-testing-plan logic merges into the new `/e4-write-test-plan` (and its skill, created in Step 2.8). The dir holds only `SKILL.md`.

**Command:**
```
git rm -r host/templates/claude/skills/e3b-write-testing-plan
```

**Verification:**
```
test ! -d host/templates/claude/skills/e3b-write-testing-plan && echo DELETED
```
Expect: `DELETED`.

### Step 2.7 — Row 18: DELETE e5b-write-manual-testing-plan/SKILL.md

**Operation:** DELETE
**Path:** host/templates/claude/skills/e5b-write-manual-testing-plan/ (the whole skill dir)
**Justification:** Row 18 — the `/e5b-write-manual-testing-plan` command is deleted (proposal row 6); its mirror skill must be removed too. The agent-as-user-plan logic (renamed `user_test_plan.md`) merges into the new `/e4-write-test-plan`. The dir holds only `SKILL.md`.

**Command:**
```
git rm -r host/templates/claude/skills/e5b-write-manual-testing-plan
```

**Verification:**
```
test ! -d host/templates/claude/skills/e5b-write-manual-testing-plan && echo DELETED
```
Expect: `DELETED`.

### Step 2.8 — Row 19: CREATE e4-write-test-plan/SKILL.md (NEW merged Test Plan skill)

**Operation:** CREATE
**Path:** host/templates/claude/skills/e4-write-test-plan/SKILL.md
**Sibling mirrored:** host/templates/claude/skills/e3-plan-implementation/SKILL.md (frontmatter `name`/`description` shape, `## Overview` / `## Protocol` (pointer) / `## Recommended models` / `## Exit criteria` body, and the `Managed by Shamt` footer). The Protocol section is a **pointer** to `commands/e4-write-test-plan.md` (created in Phase 1), NOT a paraphrase of its steps — D2 rule.

**Full content block:**
```
---
name: e4-write-test-plan
description: >
  Run Phase 4 (Test Plan) of the Shamt Engineer flow — mandatory for every story.
  Authors stories/{slug}/user_test_plan.md always (agent-as-user scenarios the
  Phase-6 user-simulator executes after the build) and stories/{slug}/testing_plan.md
  when TESTING_STANDARDS.md declares automated suites; runs the open-questions
  dialog + a Pattern-1 validation loop on each. Merges the retired /e3b-write-testing-plan
  and /e5b-write-manual-testing-plan. Invoke when the user wants to write the test
  plans for a story, draft the agent-as-user test plan, plan Phase 6 testing, or
  author user_test_plan.md / testing_plan.md.
triggers:
  - "write the test plan"
  - "write the test plans"
  - "draft the user test plan"
  - "draft the testing plan"
  - "plan the tests for"
  - "run the test-plan phase"
  - "author user_test_plan and testing_plan"
  - "test plan for"
---

## Overview

Mirrors the `/e4-write-test-plan {slug}` slash command. Same canonical body, two host wirings. Resolve the story folder per `templates/SHAMT_RULES.template.md` §PO-tree resolution (tree-wide glob + legacy-flat fallback). The merged Phase-4 Test Plan stage: `user_test_plan.md` is always produced; `testing_plan.md` is produced when `TESTING_STANDARDS.md` declares automated suites.

## Protocol

Follow the canonical `/e4-write-test-plan` command body verbatim — see [`commands/e4-write-test-plan.md`](../../commands/e4-write-test-plan.md).

## Recommended models

- Authoring: Balanced (Sonnet).
- Validation loop primary: Reasoning (Opus). Sub-agent: Cheap (Haiku) via [`agents/validation-checker.md`](../../agents/validation-checker.md).

See [`reference/model_selection.md`](../../../../../reference/model_selection.md).

## Exit criteria

Validated `user_test_plan.md` exists (always); `testing_plan.md` exists with a validation footer when `TESTING_STANDARDS.md` declares automated suites; `## Open Questions` empty or deferred with reason. Phase 6 (Test) executes these plans and **blocks until every scenario / step passes** — see [`SHAMT_RULES.template.md`](../../../../../templates/SHAMT_RULES.template.md).

---

<!-- Managed by Shamt — do not edit. Regenerate from shamt-core/host/templates/claude/skills/e4-write-test-plan/SKILL.md. -->
```

**Verification:**
```
test -f host/templates/claude/skills/e4-write-test-plan/SKILL.md && echo EXISTS
grep -n 'name: e4-write-test-plan' host/templates/claude/skills/e4-write-test-plan/SKILL.md
grep -n 'user_test_plan.md' host/templates/claude/skills/e4-write-test-plan/SKILL.md
grep -n 'Regenerate from shamt-core/host/templates/claude/skills/e4-write-test-plan/SKILL.md' host/templates/claude/skills/e4-write-test-plan/SKILL.md
```
Expect: `EXISTS` + one match for each grep.

Protocol-is-a-pointer check (the `## Protocol` section must point to the command body, not paraphrase its steps):
```
sed -n '/^## Protocol$/,/^## Recommended models$/p' host/templates/claude/skills/e4-write-test-plan/SKILL.md | grep -c 'commands/e4-write-test-plan.md'
```
Expect: `1` (a single pointer line). The Protocol section contains only the "Follow the canonical … verbatim — see [`commands/e4-write-test-plan.md`]" sentence and no enumerated procedure.

### Step 2.9 — Row 20A: MOVE e4-execute-plan → e5-execute-plan (git mv dir)

**Operation:** MOVE (sub-step A — rename the dir)
**Command:**
```
git mv host/templates/claude/skills/e4-execute-plan host/templates/claude/skills/e5-execute-plan
```

**Verification:**
```
test ! -d host/templates/claude/skills/e4-execute-plan && test -f host/templates/claude/skills/e5-execute-plan/SKILL.md && echo MOVED
```
Expect: `MOVED`.

### Step 2.10 — Row 20B: EDIT e5-execute-plan/SKILL.md body (description: Phase 5, plan-executor always, no Quick; pointer + name → e5)

**Operation:** EDIT
**File:** host/templates/claude/skills/e5-execute-plan/SKILL.md

**Locate (frontmatter name):**
```
name: e4-execute-plan
```
**Replace:**
```
name: e5-execute-plan
```

**Locate (description):**
```
description: >
  Run Phase 4 (Build) of the Shamt Engineer flow. Standard path hands the
  validated implementation_plan.md to the plan-executor builder persona
  (architect/builder split) and monitors; Quick path executes the spec's
  Build Checklist directly. Invoke when the user wants to build the story,
  execute the plan, run Phase 4, hand off to the builder, or run the
  implementation steps. Stops on builder-reported failure or ambiguity so
  the architect can patch / re-baseline / re-hand off.
```
**Replace:**
```
description: >
  Run Phase 5 (Build) of the Shamt Engineer flow. Hands the validated
  implementation_plan.md to the plan-executor builder persona (architect/builder
  split — always; no inline build) and monitors. Invoke when the user wants to
  build the story, execute the plan, run Phase 5, hand off to the builder, or run
  the implementation steps. Stops on builder-reported failure or ambiguity so
  the architect can patch / re-baseline / re-hand off.
```

**Locate (trigger line — renumber the phase mention):**
```
  - "run phase 4"
```
**Replace:**
```
  - "run phase 5"
```

**Locate (Overview pointer):**
```
Mirrors the `/e4-execute-plan {slug}` slash command. Same canonical body, two host wirings. Resolve the story folder per `templates/SHAMT_RULES.template.md` §PO-tree resolution (tree-wide glob + legacy-flat fallback).
```
**Replace:**
```
Mirrors the `/e5-execute-plan {slug}` slash command. Same canonical body, two host wirings. Resolve the story folder per `templates/SHAMT_RULES.template.md` §PO-tree resolution (tree-wide glob + legacy-flat fallback).
```

**Locate (Protocol pointer):**
```
Follow the canonical `/e4-execute-plan` command body verbatim — see [`commands/e4-execute-plan.md`](../../commands/e4-execute-plan.md).
```
**Replace:**
```
Follow the canonical `/e5-execute-plan` command body verbatim — see [`commands/e5-execute-plan.md`](../../commands/e5-execute-plan.md).
```

**Locate (Recommended models — drop Quick/Standard split):**
```
- Orchestration: Balanced (Sonnet).
- Standard-path execution: Cheap (Haiku) via [`agents/plan-executor.md`](../../agents/plan-executor.md).
- Quick-path execution: Balanced (Sonnet).
```
**Replace:**
```
- Orchestration: Balanced (Sonnet).
- Execution: Cheap (Haiku) via [`agents/plan-executor.md`](../../agents/plan-executor.md).
```

**Locate (Exit criteria — drop Quick/Standard branches):**
```
Working tree reflects the plan / Build Checklist; the plan's (or spec's) `## Verification` section passes end-to-end; the `## Review Prevention Gate Mapping` (Standard) / `## Review Prevention Checklist` (Quick) is satisfied; builder reported `All steps completed. Verification passed.` (Standard) and you confirmed it.
```
**Replace:**
```
Working tree reflects the plan; the plan's `## Verification` section passes end-to-end; the `## Review Prevention Gate Mapping` is satisfied; the builder reported `All steps completed. Verification passed.` and you confirmed it.
```

**Locate (footer):**
```
<!-- Managed by Shamt — do not edit. Regenerate from shamt-core/host/templates/claude/skills/e4-execute-plan/SKILL.md. -->
```
**Replace:**
```
<!-- Managed by Shamt — do not edit. Regenerate from shamt-core/host/templates/claude/skills/e5-execute-plan/SKILL.md. -->
```

**Verification:**
```
grep -nE 'e4-execute-plan|Phase 4|run phase 4|Quick|Standard' host/templates/claude/skills/e5-execute-plan/SKILL.md
```
Expect: zero matches.
```
grep -c 'commands/e5-execute-plan.md' host/templates/claude/skills/e5-execute-plan/SKILL.md
```
Expect: ≥1 (the Protocol pointer now targets the renamed command).

### Step 2.11 — Row 21A: MOVE e5-execute-tests → e6-execute-tests (git mv dir)

**Operation:** MOVE (sub-step A — rename the dir)
**Command:**
```
git mv host/templates/claude/skills/e5-execute-tests host/templates/claude/skills/e6-execute-tests
```

**Verification:**
```
test ! -d host/templates/claude/skills/e5-execute-tests && test -f host/templates/claude/skills/e6-execute-tests/SKILL.md && echo MOVED
```
Expect: `MOVED`.

### Step 2.12 — Row 21B: EDIT e6-execute-tests/SKILL.md body (Phase 6; executes user_test_plan; renumber; pointer)

**Operation:** EDIT
**File:** host/templates/claude/skills/e6-execute-tests/SKILL.md

**Locate (frontmatter name):**
```
name: e5-execute-tests
```
**Replace:**
```
name: e6-execute-tests
```

**Locate (description):**
```
description: >
  Run the required Phase 5 (Test) of the Shamt Engineer flow. Hands off the validated testing plan to the test-executor
  Haiku persona, watches for failures, routes Story-bug / Test-bug / Spec-gap
  diagnoses, and blocks until every scenario / step PASSes. Phase 5 is required —
  it always runs the agent-as-user execution via the user-simulator persona and the
  automated suites via test-executor when TESTING_STANDARDS.md declares them; a failure
  routes to /e7 with a required root-cause section. Invoke when the user wants to run the tests, execute
  the test plan, run phase 5, or verify the build via automated tests.
```
**Replace:**
```
description: >
  Run the required Phase 6 (Test) of the Shamt Engineer flow. Blocks until every
  scenario / step PASSes. Phase 6 is required — the user-simulator persona
  EXECUTES user_test_plan.md (the agent-as-user scenarios authored in Phase 4) and
  the test-executor Haiku persona executes testing_plan.md when TESTING_STANDARDS.md
  declares automated suites; it routes Story-bug / Test-bug / Spec-gap diagnoses,
  and a failure routes to /e8 with a required root-cause section. Invoke when the
  user wants to run the tests, execute the test plan, run phase 6, or verify the
  build via the test plans.
```

**Locate (trigger — renumber):**
```
  - "run phase 5"
```
**Replace:**
```
  - "run phase 6"
```

**Locate (Overview pointer):**
```
Mirrors the `/e5-execute-tests {slug}` slash command. Same canonical body, two host wirings. Resolve the story folder per `templates/SHAMT_RULES.template.md` §PO-tree resolution (tree-wide glob + legacy-flat fallback).
```
**Replace:**
```
Mirrors the `/e6-execute-tests {slug}` slash command. Same canonical body, two host wirings. Resolve the story folder per `templates/SHAMT_RULES.template.md` §PO-tree resolution (tree-wide glob + legacy-flat fallback).
```

**Locate (Protocol pointer):**
```
Follow the canonical `/e5-execute-tests` command body verbatim — see [`commands/e5-execute-tests.md`](../../commands/e5-execute-tests.md).
```
**Replace:**
```
Follow the canonical `/e6-execute-tests` command body verbatim — see [`commands/e6-execute-tests.md`](../../commands/e6-execute-tests.md).
```

**Locate (footer):**
```
<!-- Managed by Shamt — do not edit. Regenerate from shamt-core/host/templates/claude/skills/e5-execute-tests/SKILL.md. -->
```
**Replace:**
```
<!-- Managed by Shamt — do not edit. Regenerate from shamt-core/host/templates/claude/skills/e6-execute-tests/SKILL.md. -->
```

**Verification:**
```
grep -nE 'e5-execute-tests|Phase 5|run phase 5|/e7 with a required' host/templates/claude/skills/e6-execute-tests/SKILL.md
```
Expect: zero matches.
```
grep -c 'user_test_plan.md' host/templates/claude/skills/e6-execute-tests/SKILL.md
grep -c 'commands/e6-execute-tests.md' host/templates/claude/skills/e6-execute-tests/SKILL.md
```
Expect: ≥1 each (description names the executed user_test_plan; Protocol pointer targets the renamed command).

### Step 2.13 — Row 22A: MOVE e6-review-changes → e7-review-changes (git mv dir)

**Operation:** MOVE (sub-step A — rename the dir)
**Command:**
```
git mv host/templates/claude/skills/e6-review-changes host/templates/claude/skills/e7-review-changes
```

**Verification:**
```
test ! -d host/templates/claude/skills/e6-review-changes && test -f host/templates/claude/skills/e7-review-changes/SKILL.md && echo MOVED
```
Expect: `MOVED`.

### Step 2.14 — Row 22B: EDIT e7-review-changes/SKILL.md body (Phase 7; renumber; pointer; preserve #50 PR-open; drop Quick post-build)

**Operation:** EDIT
**File:** host/templates/claude/skills/e7-review-changes/SKILL.md

**Locate (frontmatter name):**
```
name: e6-review-changes
```
**Replace:**
```
name: e7-review-changes
```

**Locate (description — renumber Phase 6→7 and the `/e6-review-changes` slug):**
```
  Run Phase 6 (Review) — Pattern 4 in two modes. Story mode (/e6-review-changes
```
**Replace:**
```
  Run Phase 7 (Review) — Pattern 4 in two modes. Story mode (/e7-review-changes
```

**Locate (trigger — renumber):**
```
  - "run phase 6"
```
**Replace:**
```
  - "run phase 7"
```

**Locate (Overview pointer):**
```
Mirrors the `/e6-review-changes` slash command. Same canonical body, two host wirings. Two argument forms select the mode:
```
**Replace:**
```
Mirrors the `/e7-review-changes` slash command. Same canonical body, two host wirings. Two argument forms select the mode:
```

**Locate (Protocol pointer):**
```
Follow the canonical `/e6-review-changes` command body verbatim — see [`commands/e6-review-changes.md`](../../commands/e6-review-changes.md).
```
**Replace:**
```
Follow the canonical `/e7-review-changes` command body verbatim — see [`commands/e7-review-changes.md`](../../commands/e7-review-changes.md).
```

**Locate (Exit criteria — story mode; drop the Quick-path `## Post-Build Review` branch, preserve the #50 PR-open clause):**
```
- **Story mode:** validated `stories/{slug}/feedback/review_vN.md` (or `## Post-Build Review` block in the spec on a Quick-path no-issue review); `## Documentation Impact` populated; when `pr_provider == github`, the story branch pushed and the PR opened (confirm-gated) with the PR number recorded at `stories/{slug}/feedback/pr.md`.
```
**Replace:**
```
- **Story mode:** validated `stories/{slug}/feedback/review_vN.md`; `## Documentation Impact` populated; when `pr_provider == github`, the story branch pushed and the PR opened (confirm-gated) with the PR number recorded at `stories/{slug}/feedback/pr.md`.
```

**Locate (footer):**
```
<!-- Managed by Shamt — do not edit. Regenerate from shamt-core/host/templates/claude/skills/e6-review-changes/SKILL.md. -->
```
**Replace:**
```
<!-- Managed by Shamt — do not edit. Regenerate from shamt-core/host/templates/claude/skills/e7-review-changes/SKILL.md. -->
```

**Verification:**
```
grep -nE 'e6-review-changes|Phase 6|run phase 6|Post-Build Review|Quick' host/templates/claude/skills/e7-review-changes/SKILL.md
```
Expect: zero matches.
```
grep -c 'pr_provider == github' host/templates/claude/skills/e7-review-changes/SKILL.md
grep -c 'commands/e7-review-changes.md' host/templates/claude/skills/e7-review-changes/SKILL.md
```
Expect: ≥1 each (#50's PR-open clause preserved; Protocol pointer targets the renamed command).

### Step 2.15 — Row 23A: MOVE e7-resolve-feedback → e8-resolve-feedback (git mv dir)

**Operation:** MOVE (sub-step A — rename the dir)
**Command:**
```
git mv host/templates/claude/skills/e7-resolve-feedback host/templates/claude/skills/e8-resolve-feedback
```

**Verification:**
```
test ! -d host/templates/claude/skills/e7-resolve-feedback && test -f host/templates/claude/skills/e8-resolve-feedback/SKILL.md && echo MOVED
```
Expect: `MOVED`.

### Step 2.16 — Row 23B: EDIT e8-resolve-feedback/SKILL.md body (Phase 8; renumber; pointer; preserve #50 iterative pull-only loop)

**Operation:** EDIT
**File:** host/templates/claude/skills/e8-resolve-feedback/SKILL.md

**Locate (frontmatter name):**
```
name: e7-resolve-feedback
```
**Replace:**
```
name: e8-resolve-feedback
```

**Locate (description — renumber Phase 7→8; #50 pull-only/ledger/push wording is preserved verbatim):**
```
  Run Phase 7 (Polish) of the Shamt Engineer flow. Apply each comment from a
```
**Replace:**
```
  Run Phase 8 (Polish) of the Shamt Engineer flow. Apply each comment from a
```

**Locate (description trailing — renumber the "run phase 7" mention in the invoke list):**
```
  resolve comments, polish the story, run phase 7, or apply review fixes.
```
**Replace:**
```
  resolve comments, polish the story, run phase 8, or apply review fixes.
```

**Locate (trigger — renumber):**
```
  - "run phase 7"
```
**Replace:**
```
  - "run phase 8"
```

**Locate (Overview pointer):**
```
Mirrors the `/e7-resolve-feedback {slug}` slash command. Same canonical body, two host wirings.
```
**Replace:**
```
Mirrors the `/e8-resolve-feedback {slug}` slash command. Same canonical body, two host wirings.
```

**Locate (Protocol pointer):**
```
Follow the canonical `/e7-resolve-feedback` command body verbatim — see [`commands/e7-resolve-feedback.md`](../../commands/e7-resolve-feedback.md). Resolve the story folder per `templates/SHAMT_RULES.template.md` §PO-tree resolution (tree-wide glob + legacy-flat fallback).
```
**Replace:**
```
Follow the canonical `/e8-resolve-feedback` command body verbatim — see [`commands/e8-resolve-feedback.md`](../../commands/e8-resolve-feedback.md). Resolve the story folder per `templates/SHAMT_RULES.template.md` §PO-tree resolution (tree-wide glob + legacy-flat fallback).
```

**Locate (footer):**
```
<!-- Managed by Shamt — do not edit. Regenerate from shamt-core/host/templates/claude/skills/e7-resolve-feedback/SKILL.md. -->
```
**Replace:**
```
<!-- Managed by Shamt — do not edit. Regenerate from shamt-core/host/templates/claude/skills/e8-resolve-feedback/SKILL.md. -->
```

**Verification:**
```
grep -nE 'e7-resolve-feedback|Phase 7|run phase 7' host/templates/claude/skills/e8-resolve-feedback/SKILL.md
```
Expect: zero matches.
```
grep -c 'pull-only' host/templates/claude/skills/e8-resolve-feedback/SKILL.md
grep -c 'addressed_feedback.md' host/templates/claude/skills/e8-resolve-feedback/SKILL.md
grep -c 'commands/e8-resolve-feedback.md' host/templates/claude/skills/e8-resolve-feedback/SKILL.md
```
Expect: ≥1 each (#50's iterative pull-only PR-comment loop + ledger wording preserved; Protocol pointer targets the renamed command).

### Step 2.17 — Row 24A: MOVE e8-finalize-story → e9-finalize-story (git mv dir)

**Operation:** MOVE (sub-step A — rename the dir)
**Command:**
```
git mv host/templates/claude/skills/e8-finalize-story host/templates/claude/skills/e9-finalize-story
```

**Verification:**
```
test ! -d host/templates/claude/skills/e8-finalize-story && test -f host/templates/claude/skills/e9-finalize-story/SKILL.md && echo MOVED
```
Expect: `MOVED`.

### Step 2.18 — Row 24B: EDIT e9-finalize-story/SKILL.md body (Phase 9; renumber; pointer; preserve #50 gh pr merge + close routing)

**Operation:** EDIT
**File:** host/templates/claude/skills/e9-finalize-story/SKILL.md

**Locate (frontmatter name):**
```
name: e8-finalize-story
```
**Replace:**
```
name: e9-finalize-story
```

**Locate (description — renumber Phase 8→9; #50 gh-pr-merge + close-routing wording preserved):**
```
  Run Phase 8 (Finalize) of the Shamt Engineer flow — the terminal step. Commit
```
**Replace:**
```
  Run Phase 9 (Finalize) of the Shamt Engineer flow — the terminal step. Commit
```

**Locate (description trailing — renumber "run phase 8" in invoke list):**
```
  finalize a story, close it out, commit and mark it done, wrap up the story, or run phase 8.
```
**Replace:**
```
  finalize a story, close it out, commit and mark it done, wrap up the story, or run phase 9.
```

**Locate (trigger — renumber):**
```
  - "run phase 8"
```
**Replace:**
```
  - "run phase 9"
```

**Locate (Overview pointer):**
```
Mirrors the `/e8-finalize-story {slug}` slash command. Same canonical body, two host wirings. The terminal Engineer-flow phase, modelled on `/f6-archive-proposal`.
```
**Replace:**
```
Mirrors the `/e9-finalize-story {slug}` slash command. Same canonical body, two host wirings. The terminal Engineer-flow phase, modelled on `/f6-archive-proposal`.
```

**Locate (Protocol pointer):**
```
Follow the canonical `/e8-finalize-story` command body verbatim — see [`commands/e8-finalize-story.md`](../../commands/e8-finalize-story.md).
```
**Replace:**
```
Follow the canonical `/e9-finalize-story` command body verbatim — see [`commands/e9-finalize-story.md`](../../commands/e9-finalize-story.md).
```

**Locate (footer):**
```
<!-- Managed by Shamt — do not edit. Regenerate from shamt-core/host/templates/claude/skills/e8-finalize-story/SKILL.md. -->
```
**Replace:**
```
<!-- Managed by Shamt — do not edit. Regenerate from shamt-core/host/templates/claude/skills/e9-finalize-story/SKILL.md. -->
```

**Verification:**
```
grep -nE 'e8-finalize-story|Phase 8|run phase 8' host/templates/claude/skills/e9-finalize-story/SKILL.md
```
Expect: zero matches.
```
grep -c 'gh pr merge --squash --delete-branch' host/templates/claude/skills/e9-finalize-story/SKILL.md
grep -c 'commands/e9-finalize-story.md' host/templates/claude/skills/e9-finalize-story/SKILL.md
```
Expect: ≥1 each (#50's `gh pr merge` finalize preserved; Protocol pointer targets the renamed command).

### Step 2.19 — Row 25: EDIT e-all/SKILL.md description + Overview + Exit criteria (renumbered chain e1→e7 terminal at Review; merged e4; no Quick/Standard; preserve #50 wording)

**Operation:** EDIT
**File:** host/templates/claude/skills/e-all/SKILL.md

**Locate (description body — the chain + #50 terminal-at-Review wording):**
```
description: >
  Driver that walks a single story through every remaining Engineer-flow phase
  up to and including Review — /e1-start-story → /e2-define-spec → (optional
  /e3-plan-implementation + /e3b-write-testing-plan on the Standard path) →
  /e4-execute-plan → /e5-execute-tests → /e6-review-changes (opening the PR when
  pr_provider == github) — by dispatching one independent Agent sub-agent per phase
  in the shared working tree, deriving the start phase from on-disk artifacts (so
  it is itself slug-resumable), pausing on each interactive gate (Gate 2a design
  dialog, Gate 2b / Gate 3 approvals) or structured open question via AskUserQuestion, and halting on any failure it
  cannot resolve (test failure, ambiguity, inconsistent state) with the report
  surfaced verbatim. Polish (/e7, iterative) and Finalize (/e8) are operator-driven
  — not auto-run by /e-all. A stateless, disk-derived dispatcher of the canonical
```
**Replace:**
```
description: >
  Driver that walks a single story through every remaining Engineer-flow phase
  up to and including Review — /e1-start-story → /e2-define-spec →
  /e3-plan-implementation → /e4-write-test-plan → /e5-execute-plan →
  /e6-execute-tests → /e7-review-changes (opening the PR when
  pr_provider == github) — by dispatching one independent Agent sub-agent per phase
  in the shared working tree, deriving the start phase from on-disk artifacts (so
  it is itself slug-resumable), pausing on each interactive gate (Gate 2a design
  dialog, Gate 2b / Gate 3 approvals) or structured open question via AskUserQuestion, and halting on any failure it
  cannot resolve (test failure, ambiguity, inconsistent state) with the report
  surfaced verbatim. Polish (/e8, iterative) and Finalize (/e9) are operator-driven
  — not auto-run by /e-all. A stateless, disk-derived dispatcher of the canonical
```

**Locate (description trailing invoke clause — renumber the "auto-run the remaining … up to Review" phrasing is fine; only update the literal `e2 through e6` trigger below):**
(No replace needed in the description tail beyond the block above; the "up to Review" wording is phase-name-based, not number-based.)

**Locate (trigger — renumber the literal phase-range trigger):**
```
  - "auto-run e2 through e6"
```
**Replace:**
```
  - "auto-run e2 through e7"
```

**Locate (Overview — the per-phase command roster):**
```
Mirrors the `/e-all {slug}` slash command. Same canonical body, two host wirings. `/e-all` is the **optional one-shot driver** over the numbered Engineer-flow phases; the per-phase commands (`/e1-start-story`, `/e2-define-spec`, `/e3-plan-implementation`, `/e3b-write-testing-plan`, `/e4-execute-plan`, `/e5-execute-tests`, `/e6-review-changes`, `/e7-resolve-feedback`, `/e8-finalize-story`) remain the supported manual path and each stays independently runnable.
```
**Replace:**
```
Mirrors the `/e-all {slug}` slash command. Same canonical body, two host wirings. `/e-all` is the **optional one-shot driver** over the numbered Engineer-flow phases; the per-phase commands (`/e1-start-story`, `/e2-define-spec`, `/e3-plan-implementation`, `/e4-write-test-plan`, `/e5-execute-plan`, `/e6-execute-tests`, `/e7-review-changes`, `/e8-resolve-feedback`, `/e9-finalize-story`) remain the supported manual path and each stays independently runnable.
```

**Locate (Recommended models — renumber the inner-persona roster wording: no Quick/Standard there, but it lists no plan/no-test split; leave model tiers, update none — the line names personas, not phase numbers):**
(No replace — the Recommended models line names personas, not phase numbers, and carries no Quick/Standard wording.)

**Locate (Exit criteria — renumber the chain endpoints + #50 operator-driven tail):**
```
The story walked from its derived start phase through `/e6-review-changes` (review validated; PR opened when `pr_provider == github`), **or** the run paused on an interactive gate / structured open question (resumed in-place) / halted on a non-clean outcome with the verbatim report surfaced. Every phase ran as an independent `Agent` in the shared working tree (no worktree isolation); exactly one nesting level throughout. Polish (`/e7`, iterative) and Finalize (`/e8`) are operator-driven — not part of the `/e-all` chain. Child-facing — runs wherever the Engineer flow runs, with no master-only guard.
```
**Replace:**
```
The story walked from its derived start phase through `/e7-review-changes` (review validated; PR opened when `pr_provider == github`), **or** the run paused on an interactive gate / structured open question (resumed in-place) / halted on a non-clean outcome with the verbatim report surfaced. Every phase ran as an independent `Agent` in the shared working tree (no worktree isolation); exactly one nesting level throughout. Polish (`/e8`, iterative) and Finalize (`/e9`) are operator-driven — not part of the `/e-all` chain. Child-facing — runs wherever the Engineer flow runs, with no master-only guard.
```

**Verification:**
```
grep -nE '/e3b-write-testing-plan|/e4-execute-plan|/e5-execute-tests|/e6-review-changes|/e7-resolve-feedback|/e8-finalize-story|on the Standard path|Quick' host/templates/claude/skills/e-all/SKILL.md
```
Expect: zero matches (all old skill names + the Standard-path branch gone).
```
grep -c '/e7-review-changes' host/templates/claude/skills/e-all/SKILL.md
grep -c 'Polish (`/e8`, iterative) and Finalize (`/e9`) are operator-driven' host/templates/claude/skills/e-all/SKILL.md
grep -c '/e4-write-test-plan' host/templates/claude/skills/e-all/SKILL.md
```
Expect: ≥1 each (terminal at renumbered Review; #50's operator-driven Polish/Finalize wording renumbered + preserved; merged e4 named).

### Step 2.20 — Row 26: EDIT validate-artifact/SKILL.md description (uniform validation, no Quick/Standard rigor selector)

**Operation:** EDIT
**File:** host/templates/claude/skills/validate-artifact/SKILL.md

**Locate (description):**
```
description: >
  Run a Shamt Pattern 1 validation loop on any named artifact — spec, spec/
  context pair, implementation plan, testing plan, manual test plan, code
  review, framework-update proposal, or general document. Quick path = single
  primary pass; Standard or risk-triggered = primary clean + 1 Haiku adversarial
  sub-agent confirmation (no one-LOW allowance). Stamps the validation footer.
  Invoke when the user wants to validate, re-validate, run a validation loop,
  apply Pattern 1, sub-agent-check, or footer an artifact.
```
**Replace:**
```
description: >
  Run a Shamt Pattern 1 validation loop on any named artifact — spec, spec/
  context pair, implementation plan, testing plan, user test plan, code
  review, framework-update proposal, or general document. Uniform rigor: one
  primary clean round + 1 Haiku adversarial sub-agent confirmation, always (no
  Quick/Standard selector, no one-LOW allowance). Stamps the validation footer.
  Invoke when the user wants to validate, re-validate, run a validation loop,
  apply Pattern 1, sub-agent-check, or footer an artifact.
```

**Locate (trigger — rename the manual-test-plan trigger to user-test-plan):**
```
  - "validate the manual test plan"
```
**Replace:**
```
  - "validate the user test plan"
```

**Locate (Exit criteria — drop the per-path branch):**
```
Required `consecutive_clean` reached for the chosen path; validation footer appended. No separate `_VALIDATION_LOG.md` artifact — the footer is the only persistent record.
```
**Replace:**
```
Required `consecutive_clean` reached (one primary clean round + one adversarial sub-agent confirmation, always); validation footer appended. No separate `_VALIDATION_LOG.md` artifact — the footer is the only persistent record.
```

**Verification:**
```
grep -nE 'Quick path|Quick/Standard|chosen path|manual test plan' host/templates/claude/skills/validate-artifact/SKILL.md
```
Expect: zero matches.
```
grep -c 'user test plan' host/templates/claude/skills/validate-artifact/SKILL.md
grep -c 'Uniform rigor' host/templates/claude/skills/validate-artifact/SKILL.md
```
Expect: ≥1 each.

## Phase notes

- **SKILL Protocol is a pointer, never a paraphrase (D2).** Every SKILL.md `## Protocol` section is the single sentence "Follow the canonical `/eX-…` command body verbatim — see [`commands/eX-….md`]". On each MOVE the edit retargets that one pointer line (and the matching Overview "Mirrors the `/eX-…`" line and the footer's `Regenerate from …/SKILL.md` path) to the renamed command/skill — it never copies command steps in. The new e4-write-test-plan skill (Step 2.8) carries the same one-line pointer; its verification includes an explicit single-pointer check (`grep -c 'commands/e4-write-test-plan.md'` over the Protocol section == 1).
- **MOVE = `git mv` the whole skill DIR, then edit the SKILL.md body.** Each MOVE row is decomposed into sub-step A (`git mv host/templates/claude/skills/{old} host/templates/claude/skills/{new}`) and sub-step B (frontmatter `name:` + `description:` + trigger phase-number + Overview pointer + Protocol pointer + footer `Regenerate from …` path edits). Sub-step B verification includes `test ! -d {old} && test -f {new}/SKILL.md` plus a grep that the Protocol pointer now targets the renamed command.
- **#50 preservation (rows 22B/23B/24B/25).** The just-landed proposal #50 (`github-pr-review-feedback-loop`) wording is at HEAD and must survive the renumber untouched in substance — only its phase numbers/slugs shift: e7-review-changes keeps the `pr_provider == github` PR-open clause (drops only the Quick-path `## Post-Build Review` alternative); e8-resolve-feedback keeps the iterative pull-only PR-comment loop + `addressed_feedback.md` ledger + push-as-response wording; e9-finalize-story keeps the `gh pr merge --squash --delete-branch` finalize + work-item close routing; e-all keeps "Polish + Finalize operator-driven, not auto-run" (renumbered `/e8`+`/e9`) and terminal-at-Review (renumbered `/e7`). Each #50 clause has a dedicated `grep -c` verification asserting it is still present after the edit.
- **Renumber map** (this phase): e1→e1 (no body change; Step 2.1 is a confirming no-op), e2→e2, e3→e3, NEW e4-write-test-plan (merges deleted e3b + e5b), e4-execute-plan→e5-execute-plan, e5-execute-tests→e6-execute-tests, e6-review-changes→e7-review-changes, e7-resolve-feedback→e8-resolve-feedback, e8-finalize-story→e9-finalize-story.
- **Canonical only.** Every path is under `host/templates/claude/skills/`; no `.claude/` path is touched (regen propagates the rename as delete-old + create-new on the generated side per `/f4-regen-framework` + proposal #47 deletion propagation).
- **Footer wording note.** e8-finalize-story/SKILL.md and e-all/SKILL.md carry non-standard footer lines (e8 has only the `Managed by Shamt` comment with no `Validated`/`Created` line above it in the read; e-all carries a `Created 2026-06-15 …` line). The edits in Steps 2.18 and 2.19 touch only the `Regenerate from …/SKILL.md` path inside the `Managed by Shamt` comment (e9) and the body/description (e-all) — the `Created`/`Validated` provenance lines are left intact per the disk-authoritative principle.

---
Validated 2026-06-21 — 2 rounds, 1 adversarial sub-agent confirmed
