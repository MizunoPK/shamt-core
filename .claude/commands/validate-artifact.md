---
description: Run a Shamt Pattern 1 validation loop on any artifact — spec, plan, code review, testing plan, user test plan, proposal, or general document
---

# /validate-artifact

**Purpose:** Run a Shamt Pattern 1 validation loop on a named artifact. The same primitive validates specs, implementation plans, code reviews, testing plans, user test plans, framework-update proposals, and general documents.

**Recommended model:** Reasoning (Opus) for the primary loop. Adversarial sub-agent confirmations always use Cheap (Haiku) — see [`reference/model_selection.md`](../../../../reference/model_selection.md) and [`reference/validation_exit_criteria.md`](../../../../reference/validation_exit_criteria.md).

---

## Usage

```
/validate-artifact <path>
```

## Arguments

- `<path>` (required) — repo-relative or absolute path to the artifact. Examples:
  - `stories/42-add-export/spec.md`
  - `stories/42-add-export/context.md` (pass alongside `spec.md` as a pair using `+`: `stories/42-add-export/spec.md + stories/42-add-export/context.md`)
  - `stories/42-add-export/implementation_plan.md`
  - `stories/42-add-export/testing_plan.md`
  - `stories/42-add-export/user_test_plan.md`
  - `stories/42-add-export/feedback/review_v1.md`
  - `proposals/<slug>.md`
  - any other Markdown artifact (uses 5 general dimensions)

## Prerequisites

- The artifact must exist and be non-empty. If not, halt and report.
- If `stories/{slug}/active_artifacts.md` exists in the artifact's story folder, read it first and validate the file named under **Active Files**, not the unversioned baseline. Halt if the artifact passed in conflicts with the active pointer.

## Exit shape (uniform)

Pattern 1 has a single, uniform exit shape (see [`SHAMT_RULES.template.md`](../../../../templates/SHAMT_RULES.template.md) Pattern 1 and [`reference/validation_exit_criteria.md`](../../../../reference/validation_exit_criteria.md)): **one primary clean round + 1 independent adversarial sub-agent confirmation** via the `validation-checker` persona — always, for every artifact. There is no Quick/Standard rigor selector and no single-pass / one-LOW-allowance shortcut. **Sub-agents have no one-LOW allowance** — any finding by the sub-agent (including a single LOW) resets `consecutive_clean` to 0.

## The 8-step process (per round)

Track `consecutive_clean`, starting at 0. Repeat Steps 1–6 each round.

### Step 1 — Read and investigate (fresh eyes)

Re-read the entire artifact top-to-bottom every round; do not rely on memory of prior rounds. Vary reading order across rounds (top-to-bottom, section-by-section, reverse) to catch different classes of issues.

While reading, research any Pending / Open questions and any factual claims against the codebase, project docs (`.shamt-core/project-specific-files/ARCHITECTURE.md`, `.shamt-core/project-specific-files/CODING_STANDARDS.md`), tracker payload (`raw/issue.json` when present), or other verifiable sources. Cite evidence inline as you resolve answers. If a question requires a product / platform decision, surface it via the open-questions iterative dialog (see [`SHAMT_RULES.template.md`](../../../../templates/SHAMT_RULES.template.md) Principle 2) and update the artifact with each answer before continuing.

Each round, ask "What code should I have read that I haven't?" and read it.

### Step 2 — Identify issues across dimensions

Pick the dimension set that matches the artifact. First check alignment with `.shamt-core/project-specific-files/ARCHITECTURE.md` and `.shamt-core/project-specific-files/CODING_STANDARDS.md`.

| Artifact | Dimensions |
|----------|-----------|
| Spec + context pair | 8 spec dimensions + 5 pair-consistency checks (every spec is validated alongside its always-produced `context.md` — see Pattern 1 in [`SHAMT_RULES.template.md`](../../../../templates/SHAMT_RULES.template.md)) |
| Implementation plan | 8 plan dimensions |
| Testing plan | mirror plan dimensions — Step clarity, Executability, Verification completeness (see [`templates/testing_plan.template.md`](../../../../templates/testing_plan.template.md)) |
| User test plan | 4 scenario-specific dimensions — Scope coverage, Step reproducibility, Observable pass/fail, Setup completeness (see [`SHAMT_RULES.template.md`](../../../../templates/SHAMT_RULES.template.md#test-plan-phase-4--required)) |
| Code review (story-mode) | 7 dimensions — 6 review dimensions + Plan Alignment |
| Code review (formal-mode) | 6 review dimensions |
| Phase index file | 4 phase-index dimensions — Phase Coverage, Deploy Ordering, Cross-phase Dependencies, Completeness |
| Framework-update proposal | general 5 dimensions + proposal-specific checks (affected surfaces, propagation plan, rollback path); **flag any Proposed Changes row that would (re-)introduce a numbered step-by-step paraphrase into a `skills/{name}/SKILL.md` `## Protocol`** — SKILL Protocols must stay the command-body pointer form (see the **Command → Skill Protocol pointer rule** at the D2 entry in [`reference/audit_dimensions.md`](../../../../reference/audit_dimensions.md)) |
| Any other Markdown artifact | general 5 dimensions |

Apply each dimension's hard checks where listed in [`SHAMT_RULES.template.md`](../../../../templates/SHAMT_RULES.template.md) Pattern 1 (multi-option pros/cons; Open Questions cannot contain code-answerable file/function/column questions; review-prevention surface coverage; DB cross-service lineage trace; mechanical executability for plans; per-file-and-function fresh review for code reviews; tenant-A-to-tenant-B consideration; etc.).

### Step 3 — Classify severity

Per Pattern 2 (see [`reference/severity_classification.md`](../../../../reference/severity_classification.md)):

1. If not fixed, can the workflow complete? **No** → CRITICAL.
2. Will it cause confusion or wrong decisions? **Yes** → HIGH.
3. Does it noticeably reduce quality / usability? **Yes** → MEDIUM.
4. Otherwise → LOW.

Borderline cases classify HIGHER.

### Step 4 — Fix all issues immediately

Do not defer or batch. Apply fixes to the artifact in place before incrementing the round counter.

### Step 5 — Update `consecutive_clean`

- Clean round = zero issues, OR exactly one LOW issue fixed.
- Not clean = 2+ LOW or any MEDIUM / HIGH / CRITICAL.
- Clean → `consecutive_clean = consecutive_clean + 1`.
- Not clean → `consecutive_clean = 0`.

State `consecutive_clean` explicitly at the end of each round.

### Step 6 — Check exit

- `consecutive_clean = 0` → return to Step 1.
- `consecutive_clean = 1` → continue to Step 7 (the adversarial sub-agent is always required).

### Step 7 — Adversarial sub-agent

Spawn one independent adversarial review sub-agent using the `validation-checker` persona (Haiku tier; see [`agents/validation-checker.md`](../agents/validation-checker.md)). Provide it with:

- the artifact path (or paired paths for spec/context),
- the list of dimensions used in Step 2,
- the path to `.shamt-core/project-specific-files/ARCHITECTURE.md` and `.shamt-core/project-specific-files/CODING_STANDARDS.md` for context,
- any project-doc references the artifact depends on (e.g., the active spec when validating a plan).

Do **not** imply the artifact is probably correct. The sub-agent's job is to disprove it.

Example invocation (Claude Code Task tool):

```text
subagent_type: validation-checker
description: Adversarial review — {artifact-name}
prompt: |
  Artifact: {artifact_path} (or {spec_path} + {context_path} for paired validation)
  Dimensions: {dimension list from Step 2}
  Governing references: .shamt-core/project-specific-files/ARCHITECTURE.md, .shamt-core/project-specific-files/CODING_STANDARDS.md, {any others}

  Re-read the entire artifact from scratch with zero bias. Assume the primary
  validator may have missed important things. Report ANY issue found (even one
  LOW). No one-LOW allowance.

  Reply exactly "CONFIRMED: Zero issues found after adversarial review." only if
  you independently fail to find a single issue.
```

**Sub-agent exception rule:** sub-agents do NOT get the one-LOW allowance. ANY finding (even LOW) resets `consecutive_clean = 0`. Fix it, then return to Step 1.

### Step 8 — Stamp the validation footer

When the artifact exits cleanly (primary clean round + sub-agent CONFIRMED), append a single-line footer to the artifact. For spec/context pairs, append the footer to both files.

```text
---
Validated {YYYY-MM-DD} — N rounds, 1 adversarial sub-agent confirmed
```

The footer is the **only** persistent record of validation. Do not create separate `_VALIDATION_LOG.md` artifacts.

## Exit criteria

- `consecutive_clean = 1` (one primary clean round) + the adversarial sub-agent returned `CONFIRMED`.
- The validation footer appended.

## Batch handoff (≥2 artifacts)

When a caller leaves **2 or more** artifacts to validate at once (e.g., a phase-decomposed framework-update plan = index + N phase files, or several proposals promoted in one `/sync-triage-proposals` run), the producing command can emit a **batch-validation handoff prompt** instead of a long sequential list of `/clear` + `/validate-artifact` pairs. The user pastes that prompt into one fresh session; the receiving agent (the orchestrator) fans out one validation sub-agent per artifact — each running this same Pattern 1 loop in its own isolated context — and reports the aggregate result.

The handoff is a convenience helper, not a new phase: it runs the identical per-artifact loop documented above (same dimensions, same exit, same footer, same no-one-LOW-allowance on the checker), and the per-artifact `/validate-artifact <path>` commands remain the slug-resumable fallback. See [`reference/batch_validation_handoff.md`](../../../../reference/batch_validation_handoff.md) for the orchestration topology and the fill-in-the-blanks prompt template. Single-artifact callers do not use it — emit the ordinary `/clear` + `/validate-artifact <path>` suggestion.

## Notes

- This command is **fresh-agent runnable**: every input lives on disk (the artifact, its governing references, the active-artifacts pointer when present). State is determined by artifact presence; no conversation history required.
- This command is reused across the framework — Engineer flow phases (Spec, Plan, Test Plan, Review), and the framework-update flow (proposal validation). Keep its body story-agnostic — do not bake story-specific assumptions in.
- **User test plans** validate under this command's uniform Pattern 1 exit — `/validate-artifact` is the source of truth for the validation exit. `/e4-write-test-plan` invokes this command on `user_test_plan.md` (the 4 scenario dimensions) and on `testing_plan.md` (the plan dimensions); both use this exit.
- The validation footer is the **only** persistent record. There is no `_VALIDATION_LOG.md` artifact in v2.
- Sub-agent tier is fixed at Haiku via the `validation-checker` persona. Do not override at the call site without a strong reason; mis-tiering is a configuration finding (per [`reference/model_selection.md`](../../../../reference/model_selection.md)).
- See [`reference/validation_exit_criteria.md`](../../../../reference/validation_exit_criteria.md) for extended counter-logic examples and common mistakes.

---
Validated 2026-05-28 — 2 rounds, 1 adversarial sub-agent confirmed (Phase 5 implementation loop)

<!-- Managed by Shamt — do not edit. Regenerate from shamt-core/host/templates/claude/commands/validate-artifact.md. -->
