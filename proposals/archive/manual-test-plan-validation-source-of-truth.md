# Proposal: manual-test-plan-validation-source-of-truth

**Created:** 2026-05-29
**Status:** Implemented
**Proposed by:** [blank — master-local]
**Project context:** [blank — master-local]

---

## Problem

The validation **exit criterion** for a manual test plan is stated two different ways across canonical surfaces:

- `shamt-core/host/templates/claude/commands/write-manual-testing-plan.md` (Step 3 counter logic, line 90; Patch mode, line 135; Exit criteria, line 143) and its mirrored skill `shamt-core/host/templates/claude/skills/write-manual-testing-plan/SKILL.md` (lines 40, 50–52), plus `shamt-core/templates/manual_test_plan.template.md` (Validation Dimensions, line 97), all define the exit as **"2 consecutive clean rounds"** (`consecutive_clean = 2`), attributed to INFRASTRUCTURE.md §1.15.
- `shamt-core/host/templates/claude/commands/validate-artifact.md` lists "Manual test plan" in its dimension table (line 75) as a validatable artifact type, and `/validate-artifact` exits on the **standard Pattern 1** rule: a single primary clean round (`consecutive_clean = 1`) plus a Standard-path adversarial sub-agent.

These disagree. Routing a manual test plan through `/validate-artifact` applies one *fewer* required clean primary round than the bespoke inline loop in `/write-manual-testing-plan`. A maintainer cannot tell which rigor is authoritative.

**Decision (user, 2026-05-29):** `/validate-artifact` is the single source of truth for how validations are performed. Manual test plans **standardize to the Pattern 1 exit** (primary clean + Standard-path adversarial). The bespoke "2 consecutive clean rounds" rule is removed from the canonical surfaces, which instead defer to `validate-artifact` / Pattern 1.

Surfaced by the framework audit (D2 cross-doc consistency), 2026-05-29.

---

## Proposed Changes

| # | Canonical path | Operation | One-line change description |
|---|----------------|-----------|------------------------------|
| 1 | `shamt-core/host/templates/claude/commands/write-manual-testing-plan.md` | EDIT | In Step 3 "Counter logic" (lines 84–90), the Step 4 trigger (line 94), Patch mode (line 135), and Exit criteria (line 143): replace the `consecutive_clean = 2` / "2 consecutive clean rounds" exit with the standard Pattern 1 exit (primary clean round + Standard-path `validation-checker` adversarial; Quick path = single primary pass unless a HIGH+ finding), and drop the "per §1.15 — 2 consecutive clean rounds exit" attribution in favor of citing `validate-artifact` / Pattern 1 as the authority. **The artifact-specific 4 dimensions stay; only the exit rule changes.** Separately, at Note line 152: **keep** the statement that the loop runs inline (the inline execution is what keeps Author / Patch / Re-validate modes cohesive — that does not change), but adjust the wording so it no longer implies a *divergent exit contract*: the loop runs inline yet follows `validate-artifact`'s Pattern 1 exit. Do **not** change line 152 to route execution through `/validate-artifact`. |
| 2 | `shamt-core/host/templates/claude/skills/write-manual-testing-plan/SKILL.md` | EDIT | Mirror the command edit: lines 40 and 50–52 — replace `consecutive_clean = 2` exit with the Pattern 1 exit deferring to `validate-artifact`. |
| 3 | `shamt-core/templates/manual_test_plan.template.md` | EDIT | "Validation Dimensions" section, line 97: replace `Exit: 2 consecutive clean rounds (...)` with the Pattern 1 exit (primary clean + Standard-path adversarial), deferring to `validate-artifact`. Keep the 4 dimension definitions unchanged. |
| 4 | `shamt-core/host/templates/claude/commands/validate-artifact.md` | EDIT | Manual-test-plan row (line 75) / Notes: add a one-line statement that `validate-artifact` is the authoritative exit for manual test plans (standard Pattern 1 exit), so the inline `/write-manual-testing-plan` loop is understood to defer to it. |

**Path discipline:**

- All EDITs name the exact section/line above.
- Changes 1 and 2 are regen-managed (`commands/`, `skills/`), so **Phase 5 (`/regen-framework`) must run** to propagate into `.claude/`, followed by a `--check` drift confirmation. Changes 3 and 4: change 3 (`templates/`) is rendered/imported, not `.claude/`-regenerated; change 4 is regen-managed.
- 4 canonical file ops (≤10) → Phase 3 (`/plan-update-implementation`) not required.

---

## Risks

- **Behavior change** — This *reduces* the required clean rounds for manual test plans from 2 to 1 (plus adversarial on Standard). A reviewer relying on the extra clean round loses it. Acceptable per the source-of-truth decision; uniformity with every other Pattern 1 artifact is the gain.
- **Stale parent-doc attribution** — INFRASTRUCTURE.md §1.15 (lines 411, 435) — a **parent planning doc, NOT a canonical `shamt-core/` file** — still asserts "2 consecutive clean rounds." The canonical edits above deliberately stop citing §1.15 for the exit (citing `validate-artifact`/Pattern 1 instead), so no canonical file will depend on the stale text. INFRASTRUCTURE.md §1.15 should be updated **out of band** (it is outside this proposal's canonical-path scope); flagged here so it is not forgotten. See Validation Considerations.
- **Drift risk** — Command and mirrored skill must change together (regen would otherwise surface a D2/D1 mismatch). Both are in the change-list.
- **Child-project compatibility** — Children pick up the command/skill via `/import-shamt` + regen, and the template via render. No manual reconciliation; the change is to validation rigor, not artifact shape.
- **Open-questions debt** — None; the fix shape and the exit value were both resolved before drafting.

---

## Rollback Plan

1. `git revert <commit-sha>` on the canonical edit commit.
2. Run `/regen-framework` to propagate the revert into `.claude/` (changes 1, 2, 4 are regen-managed).
3. Children re-run `/import-shamt` to pick up the reverted command/skill; the template re-renders on next import.
4. No data migration; the change is documentation/validation-rigor only.

---

## Validation Considerations

- **Problem clarity** — Confirm the validator reads this as standardizing the *exit* only; the 4 manual-test-plan dimensions are unchanged.
- **Change-list completeness** — The easy-to-miss companion is the **mirrored skill** (change 2): the command and skill must state the same exit or regen surfaces a mismatch. Also confirm no *other* canonical file restates "2 consecutive clean" for manual test plans (audit grep found only the command, skill, template, and the non-canonical INFRASTRUCTURE §1.15).
- **Cross-reference hygiene** — After the edit, grep canonical files for residual "per §1.15 — 2 consecutive clean" attributions tied to the manual-test-plan exit; all should now cite `validate-artifact`/Pattern 1. The `§1.15` citations that are about **model tier** (model_selection.md "validation loop per §1.15") are unrelated and stay.
- **Out-of-band item** — INFRASTRUCTURE.md §1.15 (parent doc) update is required for full consistency but is outside canonical scope; verify it is tracked separately (it is not a regen target and not shipped to children).
- **Affected surfaces** — commands, skills, templates (edited); INFRASTRUCTURE.md (flagged, out of scope). Run the D1 `--check` and a D2 re-sweep after implementation.
- **Propagation plan** — Requires regen + child import for changes 1/2/4; render for change 3.

---

## Open Questions

[None — resolved before drafting. See Resolved Questions.]

---

## Resolved Questions

- ~~Q: Resolve the manual-test-plan exit divergence by clarifying validate-artifact's table, removing manual test plan from it, or aligning validate-artifact's exit?~~ → A: Make `/validate-artifact` the single source of truth for how validations are performed. (User decision, 2026-05-29.)
- ~~Q: Should validate-artifact codify §1.15's stricter "2 consecutive clean rounds" exit for manual test plans, or should manual test plans conform to validate-artifact's standard Pattern 1 exit?~~ → A: Standardize manual test plans to the Pattern 1 exit (primary clean + Standard-path adversarial); drop the bespoke 2-consecutive-clean rule and update INFRASTRUCTURE §1.15 out of band. (User decision, 2026-05-29.)

---
Validated 2026-05-29 — 2 rounds, 1 adversarial sub-agent confirmed
