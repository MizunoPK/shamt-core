# Implementation Plan

**Note:** Optional for Quick path (embedded Build Checklist in spec.md is used instead). Required for Standard path, delegated builder execution, or when the checklist exceeds 10 steps.

**Created:** [Date]
**Story:** stories/{slug}/
<!-- Paths are relative to the resolved story folder (located per templates/SHAMT_RULES.template.md §PO-tree resolution; the folder nests under epics/.../features/.../). -->
**Spec:** stories/{slug}/spec.md (or `spec_vN.md` for re-baselined stories)
**Context:** stories/{slug}/context.md (or `context_vN.md` for re-baselined stories) (Optional/N/A for Quick path)
**Path:** Quick path (escalation only) | Standard path
**Baseline:** v1
**Baseline status:** Active

---

## Planning Status

- **Blocked on spec (Gate 2a):** [list any steps still waiting on design approval, or "None"]
- **Blocked on open questions:** [list spec open questions blocking mechanical steps, or "None"]
- **Ready for mechanical validation:** [ ] Yes — all steps are mechanical, no Blocked: markers remain

---

## Pre-Execution Checklist

- [ ] Active artifact pointer checked when present (`stories/{slug}/active_artifacts.md`)
- [ ] Requirements clearly documented in spec
- [ ] All affected files identified (every CREATE path researched in-repo)
- [ ] No unresolved optional branches
- [ ] Feature branch created from the latest configured remote development branch in each affected repo (Steps 0-A … 0-N)
- [ ] **Skeleton approved** (optional — check if a skeleton review occurred before locate-string detail was filled in)
- [ ] Review Prevention Gate Mapping completed from spec/context
- [ ] Every applicable gate maps to step(s) and verification
- [ ] No gate is left for the builder to infer
- [ ] Plan validated

---

## Files Touched (manifest)

| Operation | Path |
|-----------|------|
| CREATE | `path/to/new/file.ext` |
| EDIT | `path/to/existing/file.ext` |

No optional rows. If a path is not in this manifest, it must not be created or edited during execution.

---

## Review Prevention Gate Mapping

| Gate | Applies? | Plan Step(s) | Verification | N/A / Deferral Reason |
|------|----------|--------------|--------------|------------------------|
| Regulated / sensitive data | Yes / No | Step N | [command/manual check] | [reason] |
| Tenant isolation | Yes / No | Step N | [tenant-A/tenant-B check or reason] | [reason] |
| Auth / route contract | Yes / No | Step N | [route/authorizer/middleware/deployment check] | [reason] |
| Database read/write | Yes / No | Step N | [database role / writer-routing check] | [reason] |
| Infrastructure / deployment | Yes / No | Step N | [env / permissions / monitoring / packaging check] | [reason] |
| Frontend safety | Yes / No | Step N | [fetch/DOM/auth-flow check] | [reason] |
| Testing / test data | Yes / No | Step N | [test command/manual check] | [reason] |
| Removed/weakened checks | Yes / No | Step N | [replacement/bypass check] | [reason] |

---

## Implementation Steps

### Step 0-A: Create feature branch from remote development branch - [Repo name]
**Operation:** BRANCH
**Repo:** `path/to/repo`
**Details:**
- Run: `git fetch origin <development-branch>`
- Run: `git checkout -b feature/{slug}/<owner-or-team> origin/<development-branch>`
- If the feature branch already exists, stop and report the existing branch instead of overwriting or resetting it.

**Verification:** `git status --short --branch` shows `## feature/{slug}/<owner-or-team>` and `git log -1 --oneline` matches `origin/<development-branch>` at branch creation.

---

### Step 1: [Description]
**Operation:** CREATE | EDIT | DELETE | MOVE
**File:** `path/to/file.ext`
**Details:**
- [For CREATE: file purpose and initial content]
- [For EDIT: exact locate string and exact replacement string]
- [For DELETE: reason for deletion]
- [For MOVE: source → destination and reason]

**Verification:** [Required when success depends on tooling (compile, test, lint, runtime); omit for pure text/content edits]

---

### Step 2: [Description]
**Operation:** CREATE | EDIT | DELETE | MOVE
**File:** `path/to/file.ext`
**Details:**
- [Specific details for this step]

**Verification:** [Required or omit]

---

### Step 3: [Description]
**Operation:** CREATE | EDIT | DELETE | MOVE
**File:** `path/to/file.ext`
**Details:**
- [Specific details for this step]

**Verification:** [Required or omit]

---

[Add more steps as needed]

---

## Verification (post-execution, whole plan)

<!-- Cross-phase / whole-plan invariants ONLY — checks depending on more than one step's (or phase's) output: whole-tree zero-match sweeps, expected file/footer counts, link-resolution sweeps. Per-step verifications stay on each step's **Verification:** line above and are the builder's. -->

**Owner: the architect, run at Phase 4 (Build) post-build** — `/e4-execute-plan` Step 4 (story altitude) / `/f3-implement-update` post-build (framework altitude). **Never the builder:** `plan-executor` is handed a single phase and cannot observe the other phases' output. **For a phase-decomposed plan this section lives in the *index* file, not any phase file**, and the architect runs it after the final phase reports `All steps completed. Verification passed.`

- [ ] [Whole-tree zero-match sweep, expected count, or link sweep — the cross-phase invariant(s) this plan must satisfy, or "None" for a single-step plan with no global invariant.]

---

## Notes

[Optional: gotchas, constraints, implementation notes]

## CODING_STANDARDS Compliance

[Required when applicable: map each relevant rule from the project `.shamt-core/project-specific-files/CODING_STANDARDS.md` to a cited plan step or a one-line non-applicable reason.]

---

## Open Questions

[Only unresolved questions that block mechanical execution or planning decisions. Per the open-questions iterative-dialog principle in `templates/SHAMT_RULES.template.md`, surface each question to the user one at a time and update the plan with each answer before moving on. Questions answerable from the codebase are resolved by research, not by surfacing.]

---
[Append the validation footer only after Pattern 1 completes for the plan.]
