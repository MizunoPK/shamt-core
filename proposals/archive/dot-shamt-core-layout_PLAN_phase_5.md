# Implementation Plan — Phase 5: Agents + templates + reference

**Parent plan:** [`dot-shamt-core-layout_PLAN.md`](dot-shamt-core-layout_PLAN.md)
**Proposal:** proposals/dot-shamt-core-layout.md
**Surface:** 4 persona files (E3), 10 templates (D5, E4), 8 reference docs (D4, E4). Pure config/doc sweeps.

No proposals (Group F) edits here — `plan-executor.md`'s `proposals/…` references describe the master-side framework-update implement role and are **left unchanged** (allow-listed; see index).

## Files manifest

| # | File | Sweeps |
|---|------|--------|
| 1 | `host/templates/claude/agents/plan-executor.md` | E (doc); proposals left |
| 2 | `host/templates/claude/agents/review-executor.md` | E (doc ×2) |
| 3 | `host/templates/claude/agents/test-executor.md` | E (doc) |
| 4 | `host/templates/claude/agents/validation-checker.md` | E (doc) |
| 5 | `templates/spec.template.md` | D (config) + E (doc ×2) |
| 6 | `templates/context.template.md` | E (doc) |
| 7 | `templates/code_review.template.md` | E (doc ×4) |
| 8 | `templates/implementation_plan.template.md` | E (doc) |
| 9 | `templates/epic.template.md` | E (doc) |
| 10 | `templates/feature.template.md` | E (doc) |
| 11 | `templates/testing_plan.template.md` | D (config) + E (doc ×2) |
| 12 | `templates/manual_test_plan.template.md` | D (config) |
| 13 | `templates/architecture.template.md` | E (doc ×2) — EDIT (architect ruling) |
| 14 | `templates/coding_standards.template.md` | E (doc ×2) — EDIT (architect ruling) |
| 15 | `reference/story_support.md` | D (config) |
| 16 | `reference/trackers/_contract.md` | D (config ×3) |
| 17 | `reference/trackers/ado.md` | D (config) |
| 18 | `reference/trackers/github.md` | D (config) |
| 19 | `reference/trackers/local.md` | D (config ×2) |
| 20 | `reference/implementation_plan_reference.md` | E (doc ×2) |
| 21 | `reference/mermaid_diagram_standards.md` | E (doc) |
| 22 | `reference/review_categories.md` | E (doc ×5) |

---

## Step 1 — `agents/plan-executor.md`

**O1 (53):** ``   - The plan contradicts `ARCHITECTURE.md`, `CODING_STANDARDS.md`, or the active spec.`` → repoint both docs

**Left unchanged (allow-listed, not Group F):** `proposals/{slug}_PLAN.md`, `proposals/{slug}_PLAN_phase_N.md`, `proposals/{slug}.md`, `proposals/`, `shamt-core/proposals/` (lines 3, 21, 26, 31, 78, 84).

**Verification:** docs regex → 0; `grep -c '.shamt-core/project-specific-files/' …/plan-executor.md` → 1; `grep -c 'proposals/' …/plan-executor.md` → unchanged.

## Step 2 — `agents/review-executor.md`

**O1 (28):** ``- `base` (optional) — explicit review base. If not provided, resolve in this order: (a) the PR's target branch when known, (b) the project's formal-review base from `ARCHITECTURE.md` when declared, (c) the repository default branch.`` → `.shamt-core/project-specific-files/ARCHITECTURE.md`
**O2 (29):** ``- `governing_refs` — paths to `ARCHITECTURE.md` and `CODING_STANDARDS.md`. Read both before findings.`` → repoint both

**Verification:** docs regex → 0; `grep -c '.shamt-core/project-specific-files/' …/review-executor.md` → 2.

## Step 3 — `agents/test-executor.md`

**O1 (29):** ``4. Read the project's `ARCHITECTURE.md` and `CODING_STANDARDS.md` to confirm test runner, fixture, and naming conventions match what the plan documents.`` → repoint both

**Verification:** docs regex → 0.

## Step 4 — `agents/validation-checker.md`

**O1 (17):** ``- `governing_references` — paths to `ARCHITECTURE.md` and `CODING_STANDARDS.md` and any artifact-specific references (e.g., the approved spec when validating a plan; `reference/pr_review_prevention.md` for risk-surface checks; `reference/severity_classification.md` for severity guidance).`` → repoint both

**Verification:** docs regex → 0.

## Step 5 — `templates/spec.template.md`

**O1 (70, config):** ``[Required when `shamt-config.json` sets `testing: "enabled"`. Omit when testing is disabled.]`` → `.shamt-core/shamt-config.json`
**O2 (75, doc):** ``- **Project conventions:** [pointers to the relevant CODING_STANDARDS.md sections — test runner, file naming, fixture patterns, assertion style]`` → `.shamt-core/project-specific-files/CODING_STANDARDS.md`
**O3 (168, doc):** ``- [Relevant ARCHITECTURE.md / CODING_STANDARDS.md notes — monitoring conventions, deployment patterns, naming, etc.]`` → repoint both

**Verification:** config regex → 0; docs regex → 0; `grep -c '.shamt-core/' …/spec.template.md` → 3.

## Step 6 — `templates/context.template.md`

**O1 (77):** ``[Relevant project `ARCHITECTURE.md`, project `CODING_STANDARDS.md`, monitoring, migration, naming, service, deployment, or test conventions. Schema rationale may go here, but `context.md` must support rather than replace the `spec.md` Database Schema Changes section.]`` → repoint both

**Verification:** docs regex → 0.

## Step 7 — `templates/code_review.template.md`

**O1 (168):** ``...Reference: the project's `ARCHITECTURE.md` and `CODING_STANDARDS.md` for monitoring rules.>`` → repoint both
**O2 (172):** ``...Reference: `reference/pr_review_prevention.md` and the project's `ARCHITECTURE.md`.>`` → `.shamt-core/project-specific-files/ARCHITECTURE.md`
**O3 (210):** ``7. **Naming** — Names vs. the project's `CODING_STANDARDS.md` and established in-file patterns`` → `.shamt-core/project-specific-files/CODING_STANDARDS.md`
**O4 (215):** ``12. **Architecture** — Design patterns, structure, coupling against `ARCHITECTURE.md``` → `.shamt-core/project-specific-files/ARCHITECTURE.md`

**Verification:** docs regex → 0; `grep -c '.shamt-core/project-specific-files/' …/code_review.template.md` → 4 lines (6 path tokens).

## Step 8 — `templates/implementation_plan.template.md`

**O1 (121):** ``[Required when applicable: map each relevant rule from the project `CODING_STANDARDS.md` to a cited plan step or a one-line non-applicable reason.]`` → `.shamt-core/project-specific-files/CODING_STANDARDS.md`

**Verification:** docs regex → 0.

## Step 9 — `templates/epic.template.md` (E4 — confirmed EDIT)

**O1 (24):** ``[Optional `**Architecture impact:** …` inline flag — present only when `/start-epic` consulted `ARCHITECTURE.md` (per §1.12) and identified an architectural change implied by this epic. Omit entirely otherwise.]`` → repoint the `ARCHITECTURE.md` file ref (leave `**Architecture impact:**` label)

**Verification:** docs regex → 0; `grep -c '.shamt-core/project-specific-files/ARCHITECTURE.md' …/epic.template.md` → 1.

## Step 10 — `templates/feature.template.md` (E4 — confirmed EDIT)

**O1 (26):** ``[Optional `**Architecture impact:** …` inline flag — present only when `/start-feature` consulted `ARCHITECTURE.md` (per §1.12) and identified an architectural change implied by this feature. Omit entirely otherwise.]`` → repoint the `ARCHITECTURE.md` file ref (leave label)

**Verification:** docs regex → 0.

## Step 11 — `templates/testing_plan.template.md`

**O1 (3, config):** ``**Note:** Produced during Phase 3 (Plan) when `shamt-config.json` sets `testing: "enabled"`. ...`` → `.shamt-core/shamt-config.json`
**O2 (17, doc):** ``[Summarize the coverage shape for this story. Cite specific sections of the spec's Test Strategy and the project's `CODING_STANDARDS.md` / `ARCHITECTURE.md` for runner choice, file naming, fixture patterns, assertion style.]`` → repoint both
**O3 (23, doc):** ``- **Test file conventions:** [Per `CODING_STANDARDS.md` — naming, location, fixture/setup patterns]`` → `.shamt-core/project-specific-files/CODING_STANDARDS.md`

**Verification:** config regex → 0; docs regex → 0.

## Step 12 — `templates/manual_test_plan.template.md`

**O1 (3, config):** ``...this artifact is available regardless of `testing` in `shamt-config.json`. The agent runs an inline validation loop...`` → `.shamt-core/shamt-config.json`

**Verification:** config regex → 0.

## Step 13 — `templates/architecture.template.md` (E4 — EDIT per architect ruling; repointed because this template renders into the child's `.shamt-core/project-specific-files/ARCHITECTURE.md`)

**O1 (17):** ``  Run `/validate-artifact ARCHITECTURE.md` after substantive edits. Keep `Last Updated``` → ``  Run `/validate-artifact .shamt-core/project-specific-files/ARCHITECTURE.md` after substantive edits. Keep `Last Updated```
**O2 (155):** ``*Template for project `ARCHITECTURE.md` in Shamt. Header metadata block above is required — the framework-update audit reads it (§1.12).*`` → ``*Template for project `.shamt-core/project-specific-files/ARCHITECTURE.md` in Shamt. Header metadata block above is required — the framework-update audit reads it (§1.12).*``

**Verification:** docs regex → 0; `grep -c '.shamt-core/project-specific-files/ARCHITECTURE.md' …/architecture.template.md` → 2.

## Step 14 — `templates/coding_standards.template.md` (E4 — EDIT per architect ruling)

**O1 (16):** ``  Run `/validate-artifact CODING_STANDARDS.md` after substantive edits. Keep `Last Updated``` → ``  Run `/validate-artifact .shamt-core/project-specific-files/CODING_STANDARDS.md` after substantive edits. Keep `Last Updated```
**O2 (230):** ``*Template for project `CODING_STANDARDS.md` in Shamt. Header metadata block above is required — the framework-update audit reads it (§1.12).*`` → ``*Template for project `.shamt-core/project-specific-files/CODING_STANDARDS.md` in Shamt. Header metadata block above is required — the framework-update audit reads it (§1.12).*``

**Verification:** docs regex → 0; `grep -c '.shamt-core/project-specific-files/CODING_STANDARDS.md' …/coding_standards.template.md` → 2.

## Step 15 — `reference/story_support.md`

**O1 (76):** ``When `shamt-config.json` sets `testing: "enabled"`, both paths gain a `testing_plan.md` ...`` → `.shamt-core/shamt-config.json`

**Verification:** config regex → 0.

## Step 16 — `reference/trackers/_contract.md`

**O1 (5):** ``The active profile is selected by `work_item_tracker` in `shamt-config.json` (see [`shamt-config.example.json`](../../shamt-config.example.json)).`` → repoint the `shamt-config.json` mention (leave the `shamt-config.example.json` link)
**O2 (43):** ``The flag is a one-off override for that invocation only; the default comes from `shamt-config.json`. Every profile in this directory is a valid value for the flag.`` → `.shamt-core/shamt-config.json`
**O3 (69):** ``4. Add the new `{name}` as a legal value for `work_item_tracker` and/or `pr_provider` in [`shamt-config.example.json`](../../shamt-config.example.json) and the `shamt-config.json` schema notes in [`CHEATSHEET.md`](../../CHEATSHEET.md).`` → repoint the bare `shamt-config.json` mention (leave the `shamt-config.example.json` link; the `CHEATSHEET.md` relative link is a within-`shamt-core/` path — left)

**Verification:** `grep -nE '(^|[^./a-z-])shamt-config\.json' …/_contract.md | grep -v 'shamt-config\.example'` → 0; `grep -c '.shamt-core/shamt-config.json' …/_contract.md` → 3.

## Step 17 — `reference/trackers/ado.md`

**O1 (3):** ``Set `work_item_tracker: "ado"` (and/or `pr_provider: "ado"`) in [`shamt-config.json`](../../shamt-config.example.json) to make this the active profile.`` → display text `[`.shamt-core/shamt-config.json`]` (leave the href to the example)

**Verification:** config regex → 0 (excluding example).

## Step 18 — `reference/trackers/github.md`

**O1 (3):** ``Set `work_item_tracker: "github"` (and/or `pr_provider: "github"`) in [`shamt-config.json`](../../shamt-config.example.json) to make this the active profile.`` → `[`.shamt-core/shamt-config.json`]`

**Verification:** config regex → 0 (excluding example).

## Step 19 — `reference/trackers/local.md`

**O1 (3):** ``Set `work_item_tracker: "local"` in [`shamt-config.json`](../../shamt-config.example.json) to make this the active profile.`` → `[`.shamt-core/shamt-config.json`]`
**O2 (53):** ``None — `local` is a work-item-tracker mode only. PR fetching is governed independently by `pr_provider` in `shamt-config.json` (which may be set to `ado`, `github`, or `none`); see the corresponding tracker profile for PR-fetch details.`` → `.shamt-core/shamt-config.json`

**Verification:** config regex → 0 (excluding example); `grep -c '.shamt-core/shamt-config.json' …/local.md` → 2.

## Step 20 — `reference/implementation_plan_reference.md`

**O1 (5):** ``Project-specific planning conventions belong in the project's `CODING_STANDARDS.md` or `ARCHITECTURE.md`; add stack-specific gates via a framework-update proposal if a pattern keeps recurring across stories.`` → repoint both
**O2 (64):** ``Primary key conventions and constraint-naming patterns are project-specific — defer to the project's `CODING_STANDARDS.md`. ...`` → `.shamt-core/project-specific-files/CODING_STANDARDS.md`

**Verification:** docs regex → 0.

## Step 21 — `reference/mermaid_diagram_standards.md`

**O1 (60):** ``- **Avoid abbreviations** unless they appear in the project's `CODING_STANDARDS.md` or `ARCHITECTURE.md`.`` → repoint both

**Verification:** docs regex → 0.

## Step 22 — `reference/review_categories.md`

**O1 (5):** ``...live in the project's `CODING_STANDARDS.md` and are consulted by the **Naming**, **Documentation**, and **Architecture** categories below.`` → `.shamt-core/project-specific-files/CODING_STANDARDS.md`
**O2 (38):** ``   - Follow the project's `CODING_STANDARDS.md` for language-specific conventions (class usage, function signature limits, module structure).`` → repoint
**O3 (48):** ``   - Check names against the project's `CODING_STANDARDS.md` and local file conventions.`` → repoint
**O4 (72):** ``    - Check structure, coupling, and design fit against the project's `ARCHITECTURE.md`.`` → `.shamt-core/project-specific-files/ARCHITECTURE.md`
**O5 (90):** ``    - Missing standard alarms for a new or renamed deployment unit is BLOCKING when the project's `CODING_STANDARDS.md` or `ARCHITECTURE.md` documents a monitoring rule.`` → repoint both

**Verification:** docs regex → 0; `grep -c '.shamt-core/project-specific-files/' …/review_categories.md` → 5 lines.

---

## Cross-check vs Proposed Changes (Phase 5 coverage)

| Proposal row | Covered by |
|---|---|
| E3 (agents doc sweep) | Steps 1–4 |
| D4 (reference config sweep) | Steps 15–19 |
| D5 (templates config sweep) | Steps 5 (spec), 11 (testing_plan), 12 (manual_test_plan) |
| E4 (templates + reference doc sweep, incl. architecture/coding_standards/epic/feature) | Steps 5–14, 20–22 |

---

Validated 2026-05-28 — 1 round, 1 adversarial sub-agent confirmed
