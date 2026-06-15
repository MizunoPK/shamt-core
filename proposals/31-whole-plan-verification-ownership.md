# Proposal: whole-plan-verification-ownership

**Created:** 2026-06-14
**Status:** Draft
**Number:** 31
**Proposed by:**
**Project context:**

---

## Problem

During the `/f-all 26` run (the PO-flow grid rename), the `plan-executor` builder returned its terminal contract message `All steps completed. Verification passed.` after the final phase of a phase-decomposed plan — yet the plan-index's mandatory post-execution **whole-tree zero-match sweep** (`grep -rnE '/p[1-6]-(start|decompose|finalize|draft)' README.md templates reference host/templates init-shamt.sh import-shamt.sh` must return zero; also the proposal's own zero-old-name acceptance criterion) had **not** actually passed: ~24 dangling references to the renamed/deleted old PO command names survived inside the six new command/skill files that an *earlier* phase had created. The failure was caught **only** because the `/f-all` driver, acting as the `/f3` architect, exercised a judgment call to re-run the sweep itself.

**Root cause (confirmed by an independent adversarial diagnosis — Opus `root-cause-diagnoser` + Haiku zero-bias confirmation): a phase-decomposed plan's *whole-plan / cross-phase-invariant* verifications are an unowned slot under `/f3-implement-update`'s architect/builder contract.** Three coupled gaps:

1. **`host/templates/claude/commands/f3-implement-update.md` has no post-build verification step.** Step 3 ("Diff coverage gate") checks only "every Proposed Changes row corresponds to a real change in the diff" + a per-row canonical-only check (lines 109–116). It never walks the plan's (or plan-**index**'s) post-execution `## Verification` section. The story-altitude sibling **`host/templates/claude/commands/e4-execute-plan.md` Step 4 (lines 87–94) already does exactly this** — "Walk the plan's `## Verification` section end-to-end. Every item must pass; re-run any verification the builder skipped…". The gap is **asymmetric**: `/f3` is missing the post-build verification `/e4` already has.
2. **`host/templates/claude/agents/plan-executor.md` Post-execution Step 1 (line 60)** says "Run the plan's **Verification** section end-to-end," but at the framework altitude the persona is handed a single `plan_path` = one phase file (Step 2 of `/f3` hands off "one phase at a time"). The builder's mental model of "the plan" is that one phase file — it never sees the index's whole-plan section and, as a Haiku-tier mechanical executor handed only its phase, structurally **cannot** own a cross-phase invariant. So a "no file in the tree contains pattern X" sweep that depends on outputs of *all* phases is owned by no one.
3. **`host/templates/claude/commands/f2-plan-update-implementation.md` Step 2** lets the architect author a plan whose post-execution verification depends on every phase's output (the index's whole-plan section), but does **not** distinguish *per-step* verifications (builder-owned, scoped to one file) from *whole-plan / cross-phase-invariant* verifications (which must be architect-owned). `templates/implementation_plan.template.md` likewise offers no labeled slot with an owner.

This admits a **class** of silent failure: any verification expressing a global invariant — whole-tree zero-match sweep, expected footer count, link-resolution sweep — that depends on more than one phase's output goes un-run under `/f3`'s architect/builder path, with the builder's `All steps completed. Verification passed.` accepted as authoritative. (Symptom-level framings — "the builder lied", "make the success string echo the grep output" — miss this: even an honest, fully-verbose phase-5 executor legitimately passes, because the failing sweep was never in the phase file it was handed.)

---

## Proposed Changes

> Change set finalized (OQ1: keep the success string; OQ2: comprehensive — close the class at both altitudes). 5 rows ≤ 10, so no Phase 3 plan is required.

| # | Canonical path | Operation | One-line change description |
|---|----------------|-----------|------------------------------|
| 1 | `shamt-core/host/templates/claude/commands/f3-implement-update.md` | EDIT | Add a **post-build verification** step (the architect, after the final phase's `All steps completed. Verification passed.`, independently runs the plan's post-execution `## Verification` section — for a phase-decomposed plan, the **index** file's whole-plan section — verbatim; any failure is a `Step failed`, never delegated back to `plan-executor`). Mirror `/e4` Step 4. Renumber the existing diff-coverage gate accordingly (or fold the post-build verification in ahead of it). |
| 2 | `shamt-core/host/templates/claude/commands/f2-plan-update-implementation.md` | EDIT | In Step 2 (plan authoring) + the plan-shape skeleton + hard rules, name the **per-step vs. whole-plan/cross-phase-invariant** verification split with explicit owners: per-step → `plan-executor` (in the phase file); whole-plan invariants (zero-match sweeps, expected counts, link sweeps that depend on >1 phase) → the architect at `/f3` post-build, living in the index file's `## Verification (post-execution, whole plan)` section. |
| 3 | `shamt-core/host/templates/claude/agents/plan-executor.md` | EDIT | Scope Post-execution Step 1 to "the **phase file's** (or single-file plan's) own `## Verification` section you were handed — not a plan-index's whole-plan section; those are the architect's (see `/f3` post-build verification and `/e4` Step 4)." Add a hard rule: never grade a global invariant it cannot fully observe. **(Does NOT touch the `All steps completed. Verification passed.` report string — kept per OQ1.)** |
| 4 | `shamt-core/templates/implementation_plan.template.md` | EDIT | Label the post-execution verification slot: a **whole-plan / cross-phase verifications** subsection explicitly noted as **run by the architect at Build/Phase-4 post-build**, never by the builder; for phase-decomposed plans it lives in the index file. |
| 5 | `shamt-core/host/templates/claude/commands/e4-execute-plan.md` | EDIT | Clarify that for a **phase-decomposed** plan, Step 4's "walk the plan's `## Verification` section" means the **index** file's whole-plan section, run after the final phase — closing the same latent ambiguity at the story altitude (the shared `plan-executor` makes this symmetry load-bearing). |

**Path discipline:** all canonical (`host/templates/claude/commands/`, `host/templates/claude/agents/`, `templates/`). Command ↔ no mirrored-skill pairing needed (these are command/persona/template bodies, not skill-backed `/pX` commands — though each command regenerates its `.claude/` skill via `/f4`). No `.claude/` paths. **The builder's `All steps completed. Verification passed.` success string is kept unchanged (OQ1 resolved)** — so the ~8 verbatim control-flow + contract match sites (`/f3`, `/e4`, `/f-all`, the rules builder-contract, the plan reference) are **not** touched, and `reference/implementation_plan_reference.md` / `templates/SHAMT_RULES.template.md` need no edit.

---

## Risks

- **Regression risk (success-string coupling) — AVOIDED.** The string `All steps completed. Verification passed.` is verbatim-matched as **control flow** at ~8 sites (`/f3` 102/107, `/e4` 54/80/128, `/f-all` ~127/144, `reference/implementation_plan_reference.md`, `templates/SHAMT_RULES.template.md` ~329). Per OQ1 we **keep** the string, so this proposal touches none of them — the ripple/halt risk does not apply. (The persona scope-fix in row 3 makes "Verification passed." already mean "the verifications in the plan I was handed passed," so no rename is needed for correctness.)
- **Regression risk (step renumbering)** — adding/reordering a step in `/f3` must keep `/f-all`'s Phase-4 dispatch description and any "Step N" cross-references consistent.
- **Drift risk** — command + persona + template edits propagate to `.claude/` via `/f4-regen-framework`; skipping regen leaves the generated bodies stale. Standard regen covers it.
- **Child-project compatibility** — children pick up the regenerated commands/persona/template on next `import-shamt`; no artifact migration (this hardens flow contracts, doesn't change on-disk artifact shapes).
- **Open-questions debt** — two load-bearing decisions (success-string rename; fix scope minimal-vs-comprehensive) are resolved in the dialog below before drafting completes.

---

## Rollback Plan

1. `git revert <commit-sha>` on the canonical edit commit.
2. Run `/f4-regen-framework` to propagate the revert into `.claude/`.
3. Child-side: none required for the revert itself (re-sync picks up the reverted bodies on next `import-shamt`).
4. Communication: standard archive note.

---

## Validation Considerations

- **Problem clarity** — the subtle point is *why the builder isn't at fault*: it was handed one phase file and cannot own a cross-phase invariant. Verify the Problem keeps "unowned slot" distinct from "builder mis-reported."
- **Change-list completeness** — confirm **no edit alters the `All steps completed. Verification passed.` string** (OQ1: kept): a `grep -rn 'All steps completed. Verification passed.' host/templates/claude/ reference/ templates/` before vs. after must be unchanged. Also confirm `/e4` Step 4 and the `plan-executor` persona stay mutually consistent (shared persona across both altitudes).
- **Risk coverage** — confirm the step-renumbering ripple into `/f-all`'s Phase-4 dispatch wording is addressed.
- **Rollback feasibility** — trivial; all EDITs, fully reverted by `git revert` + regen.
- **Affected surfaces** — commands (`/f3`, `/f2`, optionally `/e4`), the `plan-executor` persona, the implementation-plan template, optionally the rules builder-contract line + the plan reference. Cross-doc consistency: the architect's post-build verification clause in `/f3` should read parallel to `/e4` Step 4.
- **Propagation plan** — requires `/f4-regen-framework` + child `import-shamt`. No Phase 3 (≤10 rows).

---

## Open Questions

_None — all resolved (see below)._

---

## Resolved Questions

- ~~OQ1 — Rename the builder success-report string for scope-honesty?~~ → A: **Keep** `All steps completed. Verification passed.` unchanged. The structural fix doesn't require it (scoping the persona's Post-execution to its handed phase file already makes the string accurate), and a rename would ripple through ~8 verbatim control-flow + contract sites with a silent-halt risk. Rows 1–5 touch none of those match sites.
- ~~OQ2 — Fix scope: minimal (`/f3` only) or comprehensive (harden the shared contract)?~~ → A: **Comprehensive.** Add the post-build verification step to `/f3` (row 1) AND name the per-step-vs-whole-plan verification split with owners in `/f2` + the implementation-plan template (rows 2, 4), scope the `plan-executor` persona to its handed phase file (row 3), and clarify `/e4` runs the index's whole-plan section for decomposed plans (row 5). Closes the unowned-slot class at both altitudes and matches `/f1`'s default stance that an incident signals a genuine framework gap, not a one-off. Still ≤10 rows (no Phase 3).

---
