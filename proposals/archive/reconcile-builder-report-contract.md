# Proposal: reconcile-builder-report-contract

**Created:** 2026-05-29
**Status:** Implemented
**Proposed by:** [blank — master-local]
**Project context:** [blank — master-local]

---

## Problem

The executor **report-string contract** is stated inconsistently across canonical surfaces. Two related defects:

**(A) Builder report contract understated.** `shamt-core/templates/SHAMT_RULES.template.md` Pattern 5, Step 4 ("Hand off to builder", line 318) lists the builder's expected reports as a three-item list:

> Expected reports: `All steps completed.`, `Step N failed: ...`, `Step N is ambiguous: ...`.

`shamt-core/reference/implementation_plan_reference.md` (lines 117–121) restates the **same** three-item list (`success: All steps completed.`). But the surfaces that actually implement and consume the contract use a **four-item** list with a different success message:

- `shamt-core/host/templates/claude/agents/plan-executor.md` ("Reports") emits `All steps completed. Verification passed.` · `Step [N] failed: …` · `Step [N] is ambiguous: …` · `Plan defect at Step [N]: …`.
- `shamt-core/host/templates/claude/commands/execute-plan.md` keys on those exact strings (lines 54, 80, 127), as does `implement-update.md` (lines 92, 97) and `skills/implement-update/SKILL.md` (line 34) — all using the full `All steps completed. Verification passed.` and the `Plan defect` report.

So two authoritative-looking surfaces (the rules file and the plan reference) understate the contract (missing `Plan defect`; success lacks the `Verification passed.` suffix), while one skill summary truncates it: `skills/execute-plan/SKILL.md` (line 33) uses the bare `All steps completed.` in its "Monitor and route" line, where its own Exit-criteria line (47) uses the full string.

**(B) Test-executor report-string truncation (folded in — was audit finding F3).** The authoritative success report for the Phase 5 test runner is `All steps passed. Results logged.` — used verbatim in `agents/test-executor.md` ("Reports", line 79) and keyed on exactly by `commands/execute-tests.md` (lines 91, 119) and `skills/execute-tests/SKILL.md` (line 50). But the **truncated** `All steps passed.` appears in three spots: `test-executor.md:73`, `execute-tests.md:101`, and `skills/execute-tests/SKILL.md:32`.

Runtime is unaffected (the persona ↔ orchestrator pairs agree on the full strings), but readers implementing or auditing from the rules file, the plan reference, or the skill summaries would build an incomplete/inconsistent handler.

Surfaced by the framework audit (D2 cross-doc consistency), 2026-05-29. The builder-report mismatch was MEDIUM (F1); the test-executor truncation was LOW (F3), folded here as the same fix class. The full surface inventory was completed during this proposal's own Phase 2 adversarial validation.

---

## Proposed Changes

Goal: every surface that **enumerates the full report contract** lists all four builder reports / the full test-report string; every surface that **references the success token** uses the full verbatim form (`All steps completed. Verification passed.` / `All steps passed. Results logged.`).

| # | Canonical path | Operation | One-line change description |
|---|----------------|-----------|------------------------------|
| 1 | `shamt-core/templates/SHAMT_RULES.template.md` | EDIT | Pattern 5 → Step 4 "Builder contract" sentence (line 318): bring "Expected reports" to all 4 items. **Two substantive deltas:** (a) success becomes `All steps completed. Verification passed.`; (b) add `Plan defect at Step N: …`. The two existing items stay. **Keep the rules file's bracketless `N` placeholder** (do not adopt the persona's `[N]`; `N` and `[N]` are the same step-number placeholder). |
| 2 | `shamt-core/reference/implementation_plan_reference.md` | EDIT | "Expected reports" list (lines 117–121): same correction as #1 — `success: All steps completed. Verification passed.` and add `defect: Plan defect at Step N: …`. Keep bracketless `N` to match the file's existing style. |
| 3 | `shamt-core/host/templates/claude/skills/execute-plan/SKILL.md` | EDIT | "Monitor and route" (line 33): change the bare success token `All steps completed.` → `All steps completed. Verification passed.` to match the command/persona. (The compressed failure paraphrase `Step N failed / ambiguous / plan defect` may stay as skill shorthand; the *success token* is the one routing relies on.) |
| 4 | `shamt-core/host/templates/claude/agents/test-executor.md` | EDIT | Post-execution Step 3 (line 73): `Report \`All steps passed.\`` → `Report \`All steps passed. Results logged.\`` to match the persona's own "Reports" string (line 79). |
| 5 | `shamt-core/host/templates/claude/commands/execute-tests.md` | EDIT | Line 101 ("After the executor reports `All steps passed.`:"): truncated `All steps passed.` → `All steps passed. Results logged.` to match the strings this command already keys on (lines 91, 119). |
| 6 | `shamt-core/host/templates/claude/skills/execute-tests/SKILL.md` | EDIT | "Monitor and route" (line 32): `All steps passed.` → `All steps passed. Results logged.` to match its own Exit-criteria line (50) and the command. |

**Path discipline:**

- **Regen-managed** (`agents/`, `commands/`, `skills/` under `host/templates/claude/`): changes 3, 4, 5, 6 — **Phase 5 (`/regen-framework`) must run** to propagate into `.claude/`, then a `--check` drift confirmation.
- **Import/render** (not `.claude/`-regenerated): change 1 (`templates/`, rendered into a child's `CLAUDE.md`) and change 2 (`reference/`, copied into a child's `.shamt-core/` on import). Picked up on next `/import-shamt`.
- Generated `.claude/` files are never listed; all edits go to the canonical sources above.

6 file ops (≤10), so Phase 3 (`/plan-update-implementation`) is not required.

---

## Risks

- **Regression risk** — None to runtime. The persona/orchestrator pairs already use the full strings; this brings the rules file, the plan reference, and the skill summaries into agreement. Removing the truncated success tokens removes a latent risk that a future reader keys off the bare `All steps completed.` / `All steps passed.` form.
- **Drift risk** — Changes 3–6 are regen-managed: skipping regen surfaces drift on `--check` (D1). After this proposal, all enumerating surfaces (rules, plan reference, plan-executor, execute-plan) agree on the builder contract, and all success-token references (test-executor, execute-tests command + skill) agree on the test string.
- **Child-project compatibility** — Changes 1–2 land via next `/import-shamt`/render; 3–6 via `/import-shamt` + regen. No manual reconciliation; all edits are descriptive text.
- **Open-questions debt** — None. The F1 design question (full enumeration vs. pointer) and the F3 fold were resolved before drafting; the newly-found surfaces (plan reference, two skills) are completeness additions with no new design choice.

---

## Rollback Plan

1. `git revert <commit-sha>` on the canonical edit commit.
2. Run `/regen-framework` to propagate the revert of changes 3–6 into `.claude/` (changes 1–2 are outside the `.claude/` regen set; children re-render/import them).
3. Children re-run `/import-shamt` to pick up the reverted files. No data migration; all edits are descriptive text.

---

## Validation Considerations

- **Problem clarity** — All six edits are documentation-consistency corrections; confirm the validator does not read them as behavioral changes to the builder or test-executor loops.
- **Change-list completeness** — This was the gap caught in the first validation pass. Verify (via `grep -rn 'All steps completed' 'All steps passed' templates/ reference/ host/`) that the change-list now covers **every** surface that enumerates the contract or references the bare success token, and that the alignment targets (plan-executor.md:68, execute-plan.md:54/80/127, implement-update.md:92/97, skills/implement-update/SKILL.md:34, test-executor.md:79, execute-tests.md:91/119, skills/execute-tests/SKILL.md:50, skills/execute-plan/SKILL.md:47) already carry the full strings and are NOT edit targets.
- **Risk coverage** — Confirm changes 1–2 are outside the `.claude/` regen-managed subtrees (`commands`, `agents`, `skills`, `statusline.sh`) so their "import/render only" claim holds, and that changes 3–6 *are* inside them so regen is required.
- **Affected surfaces** — rules + plan reference + execute-plan skill (builder side); test-executor persona + execute-tests command + execute-tests skill (test side). Edited surfaces span `templates/`, `reference/`, `agents/`, `commands/`, and `skills/`. After the edits, cross-check that the builder strings are byte-identical across rules/plan-reference/plan-executor/execute-plan and the test strings byte-identical across test-executor/execute-tests command+skill.
- **Propagation plan** — Changes 1–2: render/import. Changes 3–6: regen + `--check` + child import.

---

## Open Questions

[None — resolved before drafting. See Resolved Questions.]

---

## Resolved Questions

- ~~Q: Should the rules list all 4 messages verbatim, point to the plan-executor persona, or just note the persona is the authoritative superset?~~ → A: Full enumeration — list all 4 messages in Pattern 5 Step 4 (and in the plan reference) so both enumerating surfaces are complete. (User decision, 2026-05-29.)
- ~~Q: Should the F3 test-executor report-string LOW be its own proposal or folded into F1?~~ → A: Folded into F1 — same fix class (executor report-string consistency). (User decision, 2026-05-29.)
- ~~Q: (Found in Phase 2 validation) Are there other canonical surfaces restating the contract beyond SHAMT_RULES and the three orchestrator/persona files?~~ → A: Yes — `reference/implementation_plan_reference.md` (3rd enumeration) and the `execute-plan` / `execute-tests` skill summaries truncate the success token. All added to the change-list (#2, #3, #6). (Resolved by adversarial sub-agent, 2026-05-29.)

---
Validated 2026-05-29 — 3 rounds, 1 adversarial sub-agent confirmed
