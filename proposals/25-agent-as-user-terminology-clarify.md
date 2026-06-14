# Proposal: agent-as-user-terminology-clarify

**Created:** 2026-06-14
**Status:** Draft
**Number:** 25
**Proposed by:**
**Project context:**

---

## Problem

Proposal #21 standardized the required Phase-5 run as **"agent-as-user execution"** — the term now used in the rules, the `user-simulator` persona, `reference/testing.md`, and even the *Purpose* paragraph of `templates/testing_standards.template.md` itself (lines 22, 31: "to drive the per-story agent-as-user execution", "Phase 5 runs the agent-as-user execution only"). But the **driving-procedure source** that this run reads — the section of `TESTING_STANDARDS.md` that documents *how* to drive the project as a user — is still labeled **"Manual-as-user testing"** in four coupled instruction-path spots:

- `templates/testing_standards.template.md:39` — the section heading `## Manual-as-user testing (always applicable)`.
- `host/templates/claude/agents/user-simulator.md:36` — the persona's pre-flight instructs reading *the "Manual-as-user testing" section*, which must match the heading **verbatim** to resolve.
- `reference/testing.md:11` — "it declares the **manual-as-user** driving procedures (always applicable)".
- `templates/testing_standards.template.md:9` — the Update Trigger: "a documented **manual-as-user** procedure".

This is a comprehension/terminology risk (D7), MEDIUM — not a broken reference (the heading↔persona-instruction pair is internally consistent). The word **"Manual"** collides with a genuinely *distinct* surface the framework also has: the human-walkthrough `manual_test_plan.md` / `/e5b`, which is explicitly **for a human tester, not the agent** (`reference/testing.md:48–51`, `templates/testing_standards.template.md:51–53`). A reader landing on "Manual-as-user testing" can plausibly read it as that human manual-test surface rather than the agent-driven Phase-5 surface — exactly the conflation #21's naming was meant to avoid. The template file is also internally inconsistent: its Purpose says "agent-as-user execution" while its section heading says "Manual-as-user testing".

The resolution (chosen via the open-questions dialog) is a clean one-word rename: **"Manual-as-user" → "Agent-as-user"** across all four spots. This aligns the procedure-source label with #21's established term, removes the collision with the human `manual_test_plan.md` surface, and fixes the template's internal inconsistency. The `-as-user` framing is preserved, so the parallel with "agent-as-user execution" reads naturally.

---

## Proposed Changes

| # | Canonical path | Operation | One-line change description |
|---|----------------|-----------|------------------------------|
| 1 | `shamt-core/templates/testing_standards.template.md` | EDIT | Rename the `## Manual-as-user testing (always applicable)` section heading (line 39) → `## Agent-as-user testing (always applicable)`; and in the Update Trigger (line 9) "a documented manual-as-user procedure" → "a documented agent-as-user procedure". |
| 2 | `shamt-core/host/templates/claude/agents/user-simulator.md` | EDIT | In the Pre-flight step (line 36), update the verbatim section reference `the "Manual-as-user testing" section` → `the "Agent-as-user testing" section` so it stays aligned with the renamed heading in change #1. |
| 3 | `shamt-core/reference/testing.md` | EDIT | In the "Source of truth" section (line 11), "it declares the **manual-as-user** driving procedures" → "it declares the **agent-as-user** driving procedures". |

**Path discipline:** all three are EDITs to canonical sources (`templates/`, `host/templates/claude/`, `reference/`). No `.claude/` paths; no CREATE/DELETE/MOVE. 3 rows ≤ 10 — no Phase 3 plan required.

---

## Risks

- **Regression risk (verbatim-alignment break)** — the load-bearing coupling is the heading (change #1) ↔ the persona's section reference (change #2). If only one lands, the `user-simulator` pre-flight grep for the section name will miss and the agent could `HALT` or read the wrong section. Mitigation: changes #1 and #2 are a mandatory pair and validation must confirm both moved together; this proposal lists them as adjacent rows for exactly that reason.
- **Drift risk** — purely textual; once the canonical edits land, `/f4-regen-framework` propagates the persona change into `.claude/agents/user-simulator.md`. Skipping regen would leave the generated persona reading the old heading name. Standard regen step covers it.
- **Child-project compatibility** — a child's already-completed `TESTING_STANDARDS.md` (instantiated from this template) will still carry the old `## Manual-as-user testing` heading after `import-shamt`, because import does not rewrite an already-filled project doc. The freshly-regenerated `user-simulator` persona will then look for "Agent-as-user testing" and not find it. This is a low-severity, self-healing nuisance (the persona `HALT`s with a clear "section not found" rather than mis-passing), but it is the one place a child needs a manual nudge — noted in Validation Considerations and Rollback.
- **Open-questions debt** — none; the single load-bearing decision (rename vs. clarifier vs. reject) was resolved in the dialog (see Resolved Questions).

---

## Rollback Plan

1. `git revert <commit-sha>` on the canonical edit commit.
2. Run `/f4-regen-framework` to propagate the revert into `.claude/agents/user-simulator.md`.
3. Child-side: none required for the revert itself. (Children that had already re-synced and hand-updated their `TESTING_STANDARDS.md` heading to "Agent-as-user" would, after a revert, want to restore the old heading — but the persona reverts in lockstep, so a child that did nothing stays consistent.)
4. Communication: none beyond the standard archive note.

---

## Validation Considerations

- **Problem clarity** — the Problem leans on a subtle distinction (the *procedure category* in the standard vs. the *human* `manual_test_plan.md` surface vs. the *Phase-5 run*). Verify the rename does not accidentally blur the still-distinct human `manual_test_plan.md` / `/e5b` surface — those references must stay "manual" (they are correctly human-only) and must **not** be swept into the rename.
- **Change-list completeness** — the easy-to-forget pairing is heading (#1) ↔ persona verbatim reference (#2): both must move together. Also confirm the grep is exhaustive — a fresh `grep -rni "manual-as-user"` across `templates/ reference/ host/templates/claude/ scripts/ CLAUDE.md README.md` should return **zero** hits after the edits (the four current hits are the three rows, with #1 covering two sites in one file).
- **Risk coverage** — the child-side `TESTING_STANDARDS.md` heading-staleness scenario (already-filled project docs don't get rewritten by import) is the main non-obvious risk; confirm it is acceptable as a self-healing `HALT` rather than a silent mis-pass.
- **Rollback feasibility** — trivial; three textual EDITs, fully reverted by `git revert` + regen. No DELETE/MOVE, no lost history.
- **Affected surfaces** — templates, references, personas (via `host/templates/claude/agents/`). No rules, commands, skills, or scripts touched. Cross-doc consistency to verify: the renamed heading appears identically in the template heading and the persona's quoted section name.
- **Propagation plan** — requires `/f4-regen-framework` to push the persona edit into `.claude/`. Already-installed children pick up the regenerated persona on next `import-shamt`; their pre-existing filled `TESTING_STANDARDS.md` heading is the one spot needing a manual one-line rename (or a re-derive from the template).

---

## Open Questions

*(none — resolved below)*

---

## Resolved Questions

- ~~Q: #21 names the Phase-5 run "agent-as-user execution" but the procedure-source section is labeled "Manual-as-user testing" (colliding with the human-only `manual_test_plan.md`). Rename, add a clarifier, or reject as intentional?~~ → A: **Rename** "Manual-as-user" → "Agent-as-user" across all four spots (heading + verbatim persona reference + reference doc + update-trigger). Aligns with #21's established term, removes the human-manual-test collision, and fixes the template's own internal inconsistency (its Purpose already says "agent-as-user").
