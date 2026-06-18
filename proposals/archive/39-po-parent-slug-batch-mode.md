# Proposal: po-parent-slug-batch-mode

**Created:** 2026-06-17
**Status:** Implemented
**Number:** 39
**Proposed by:**
**Project context:**

---

## Problem

Today the three deepening / decomposing PO-flow commands each operate on exactly one artifact at its own altitude:

- `/pf1-define {feature-slug}` fleshes out **one** feature stub (`host/templates/claude/commands/pf1-define.md` Step 2 resolves the slug to a single feature folder).
- `/ps1-define {story-slug}` defines **one** story ticket (`host/templates/claude/commands/ps1-define.md` Step 2 resolves a single story folder, then runs the inline Pattern-1 validation loop).
- `/pf2-decompose {feature-slug}` decomposes **one** feature into story stubs (`host/templates/claude/commands/pf2-decompose.md` Step 1 resolves a single feature folder).

After a `/pe2-decompose` produces N feature stubs under an epic — or a `/pf2-decompose` produces N story stubs under a feature — the PO has to invoke the next define/decompose command **once per child**, copying each child slug by hand off the parent's `Target Features` / `Target Stories` list (`host/templates/claude/commands/pe2-decompose.md` Step 11 explicitly emits one suggested `/pf1-define {feature-slug}` line per stub). For a wide epic this is N manual invocations of the *same* phase across *sibling* artifacts — pure mechanical fan-out that the agent could derive from disk.

The request: give each of these three commands a **parent-slug batch mode**. When the slug passed resolves (per §PO-tree resolution — slugs are globally unique, so the resolved folder's altitude is unambiguous) to the command's **parent** altitude rather than its own, the command systematically works through every child and runs its own single-artifact phase on each, sequentially:

- `/pf1-define {epic-slug}` → define every feature under the epic.
- `/ps1-define {feature-slug}` → define every story under the feature.
- `/pf2-decompose {epic-slug}` → decompose every feature under the epic into story stubs.

**Empty / un-decomposed parent.** When the slug resolves to the parent altitude but the parent has no children yet (its `Target …` decomposition list is empty / absent — e.g. `/pf1-define {epic-slug}` on an epic not yet run through `/pe2-decompose`), the batch derives an empty worklist: report `parent {slug} has no children to process — run the decompose phase ({/pe2-decompose | /pf2-decompose} {slug}) first` and exit cleanly (a no-op, distinct from the "neither own nor parent altitude → halt" dispatch case).

This is **horizontal sibling fan-out at one altitude**, distinct from vertical cross-altitude chaining (`/pe2-decompose` auto-invoking `/pf1-define`), which the existing `host/templates/claude/commands/pe2-decompose.md` Notes deliberately forbid ("No `/pf1-define` auto-invocation… every command stays independently runnable"). Batch `/pf1-define` over an epic still does **not** decompose those features (that stays `/pf2-decompose`); it only runs the *same* phase across siblings. The batch loop is a **stateless, disk-derived dispatcher of the command's own single-artifact logic** — it derives its child worklist from the parent's on-disk decomposition output and is itself slug-resumable (re-invocation skips children already complete) — the same Principle-1 reconciliation `shamt-core/CLAUDE.md` already homes for the `/f-all` and `/e-all` drivers. Each child stays independently runnable via its own single slug.

---

## Proposed Changes

A flat list of canonical files the proposal will touch. **Every file the proposal will edit, create, delete, or move must appear here** — Phase 2 (validate-artifact) and Phase 4 (implement-update) both read this list as the source of truth for change scope.

| # | Canonical path | Operation | One-line change description |
|---|----------------|-----------|------------------------------|
| 1 | `shamt-core/host/templates/claude/commands/pf1-define.md` | EDIT | Add a parent-slug batch mode: a Step 2 altitude-dispatch (own altitude = feature slug → existing single-artifact behavior unchanged; parent altitude = epic slug → batch over the epic's features; neither → halt) plus a new "## Parent-slug batch mode (epic → all features)" section defining the disk-derived ordered worklist from the epic's `Target Features` / `Sequencing & Parallelization`, per-child execution of the existing single-feature logic (full per-child open-questions dialog), skip-already-defined-with-notice resumability, the halt-at-child-on-unresolvable-outcome policy (Q-A2) with resumable re-invocation, and the final summary; add the horizontal-vs-vertical Principle-1 reconciliation to Notes. |
| 2 | `shamt-core/host/templates/claude/commands/ps1-define.md` | EDIT | Add a parent-slug batch mode: Step 2 altitude-dispatch (own = story slug → unchanged; parent = feature slug → batch over the feature's stories; neither → halt) + "## Parent-slug batch mode (feature → all stories)" section — disk-derived ordered worklist from the feature's `Target Stories` / `Sequencing & Parallelization`, per-child execution of the existing single-story logic **including its inline Pattern-1 validation loop / footer stamp**, skip-already-validated-with-notice resumability, the halt-at-child-on-unresolvable-outcome policy (Q-A2) with resumable re-invocation, final summary; Principle-1 reconciliation in Notes. |
| 3 | `shamt-core/host/templates/claude/commands/pf2-decompose.md` | EDIT | Add a parent-slug batch mode: Step 1 altitude-dispatch (own = feature slug → unchanged; parent = epic slug → batch over the epic's features; neither → halt) + "## Parent-slug batch mode (epic → decompose all features)" section — disk-derived ordered worklist from the epic's `Target Features` / `Sequencing & Parallelization`, per-child execution of the existing single-feature decompose logic (whole-list gate + decomposition exit gate per feature), skip-already-decomposed-with-notice resumability, the halt-at-the-feature policy when a feature lacks a `Validated …` footer (Q-A1; `--allow-unvalidated` remains the explicit escape hatch) and the halt-at-child-on-unresolvable-outcome policy (Q-A2), final summary; Principle-1 reconciliation in Notes (batch decompose stays at the decompose altitude — it does not then run `/ps1-define` on the resulting story stubs). |
| 4 | `shamt-core/host/templates/claude/skills/pf1-define/SKILL.md` | EDIT | Extend the frontmatter `description` + `triggers` to surface the parent-epic batch mode ("define all features in the epic") and append a one-line batch note to Exit criteria. `## Protocol` stays the canonical-command-body pointer — no step paraphrase (per #37 / the D2 Command → Skill Protocol pointer rule). |
| 5 | `shamt-core/host/templates/claude/skills/ps1-define/SKILL.md` | EDIT | Same SKILL update for the parent-feature batch mode ("define all stories in the feature"); Protocol stays the pointer. |
| 6 | `shamt-core/host/templates/claude/skills/pf2-decompose/SKILL.md` | EDIT | Same SKILL update for the parent-epic batch decompose ("decompose all features in the epic"); Protocol stays the pointer. |
| 7 | `shamt-core/README.md` | EDIT | Under the `### Product Owner flow (Part 2)` heading (≈ line 103), annotate the command-table rows for `/pf1-define` (line 124), `/pf2-decompose` (line 125), `/ps1-define` (line 127) and add a short note (after the table's "Every command above is ID-or-slug-first…" paragraph) that passing a **parent** slug runs the phase across all children sequentially — disk-derived and resumable. |

**Path discipline:**

- **CREATE** must give the exact target path and a one-line content sketch.
- **EDIT** must name the exact section / heading the edit lands in.
- **DELETE** must justify the removal.
- **MOVE** is recorded as paired CREATE + DELETE rows.
- Generated `.claude/` files are **never** listed. Edits go to canonical sources only (all 7 rows above are under `host/templates/claude/` or root-level `README.md`). Regen (Phase 5) propagates to `.claude/`.

Row count = 7 (≤ 10) — no Phase 3 (`/f2-plan-update-implementation`) required.

**Deliberately NOT edited:**

- `templates/SHAMT_RULES.template.md` — the rules file is size-budgeted (D12) and carries no per-command flow detail; the batch mode is command-level behavior, exactly as `/f-all` / `/e-all` are kept out of the rules file. §PO-tree resolution already resolves any slug to its altitude folder, which is all the dispatch needs.
- `shamt-core/CLAUDE.md` — the `/f-all` / `/e-all` reconciliations live there because they are master-dev-primer driver concepts; this is a child-facing PO-flow command behavior, so its Principle-1 reconciliation is homed inline in each command's Notes (beside the existing "No `/pf1-define` auto-invocation" note), not in the primer.
- `/pe1-define` / `/pe2-decompose` — out of scope. The request names only `/pf1-define`, `/ps1-define`, `/pf2-decompose`. (Epic is the top altitude — `/pe1-define` has no parent altitude to batch from, and `/pe2-decompose`'s parent would be a portfolio level Shamt does not model.)

---

## Risks

- **Regression risk** — the altitude-dispatch must leave the **own-altitude (single-slug) path byte-for-byte behaviorally unchanged**. A feature slug to `/pf1-define`, a story slug to `/ps1-define`, a feature slug to `/pf2-decompose` must run exactly as today. Mitigation: the dispatch is a thin branch inserted at slug-resolution time; the existing Step-by-step is the per-child body, reused verbatim.
- **Principle-1 / mega-orchestrator risk** — a reviewer (or a future `/f5-audit-framework` D9 contradiction sweep) could read "one command loops over N children" as a state-holding orchestrator contradicting Principle 1, or as conflicting with the existing "No `/pf1-define` auto-invocation" Note. Mitigation: the proposal frames it as a stateless, disk-derived dispatcher of the command's *own* single-artifact logic (worklist derived from the parent's on-disk `Target …` list, resumable by re-invocation, each child independently runnable) — the same reconciliation `CLAUDE.md` homes for `/f-all` / `/e-all` — and explicitly distinguishes horizontal sibling fan-out (this) from vertical cross-altitude chaining (the forbidden case). The reconciliation text is added to each command's Notes.
- **Interactivity risk** — `/pf1-define` and `/ps1-define` are open-questions-dialog heavy. Batch mode must keep the dialog **per-child, one question at a time** (Principle 2) — never bulk-bomb the union of all children's questions. Mitigation: each child runs its own complete dialog before the next child starts; the batch is sequential, not parallel.
- **Resumability / partial-completion risk** — a batch interrupted partway (user exits, a child halts) must resume cleanly. Mitigation: the skip-already-complete check is disk-derived per child (pf1: depth sections drafted; ps1: `Validated …` footer present; pf2: `Decomposed …` line present), so re-invocation continues from the first incomplete child without re-prompting completed ones.
- **Mixed-state-epic risk (pf2)** — an epic's features will be in mixed states; some not yet defined+validated, which `/pf2-decompose` requires. Resolved (A1): batch pf2 **halts at** the first feature lacking a `Validated …` footer (already-decomposed features ahead of it are skipped-with-notice); the user validates it and re-invokes, and resumability resumes there. No implicit gate bypass — `--allow-unvalidated` stays the explicit escape hatch.
- **Drift risk** — canonical/`.claude/` drift if regen is missed. Mitigation: Phase 5 `/f4-regen-framework --check`.
- **Child-project compatibility** — purely additive command behavior; installed children pick it up on the next `import-shamt` + regen with no manual reconciliation. The new mode is opt-in by passing a parent slug; existing single-slug usage is unaffected.
- **Open-questions debt** — none outstanding. Both drafting questions (A1 pf2-unvalidated-feature policy, A2 per-child unresolvable-outcome policy) are resolved in **Resolved Questions** and folded into the change list / risks above.

---

## Rollback Plan

Revert the commit and re-run `/f4-regen-framework`. No child-side action required beyond the next routine `import-shamt` (the change is additive — reverting simply removes the batch mode; single-slug behavior was never altered).

---

## Validation Considerations

Dimension hints for the Phase 2 validation loop.

- **Problem clarity** — the horizontal-fan-out vs. vertical-chaining distinction is the concept most likely to be misread. Verify the proposal never implies batch `/pf1-define` invokes `/pf2-decompose` (or batch `/pf2-decompose` invokes `/ps1-define`) — it does not; each batch stays at its own altitude.
- **Change-list completeness** — the three command bodies (rows 1–3) are the load-bearing edits; the three SKILL files (rows 4–6) must update only `description` / `triggers` / `Exit criteria` and **must not** introduce a numbered step paraphrase into `## Protocol` (the D2 Command → Skill Protocol pointer rule / #37). README (row 7) is the user-facing surface. Check no *fourth* command (`/pe1-define`, `/pe2-decompose`, `/ps0-draft`, `/pf0-draft`) was implicitly dragged in.
- **Risk coverage** — confirm the regression risk (single-slug path unchanged) and the Principle-1 reconciliation are both addressed in the command Notes, not only in this proposal.
- **Rollback feasibility** — purely additive; revert is clean. No destructive DELETE / MOVE.
- **Affected surfaces** — commands (3) + skills (3) + README (1). No rules / reference / template / persona / script changes. Cross-doc consistency: the three command bodies should describe the batch mode in **parallel structure** (same section name shape, same skip-resumability wording, same summary shape) so D7 terminology stays consistent across the trio.
- **Propagation plan** — requires Phase 5 regen into `.claude/`; installed children pick it up on the next `import-shamt`. No manual child nudge.

---

## Open Questions

_All resolved — see Resolved Questions below._

---

## Resolved Questions

<!-- Drafting-only log. -->

- ~~Q-A1: pf2 batch over an epic — how to treat a feature not yet defined+validated?~~ → A: **Halt at that feature.** Batch `/pf2-decompose` stops the moment it reaches a feature lacking a `Validated …` footer and directs the user to `/pf1-define` + `/validate-artifact` it (the same gate the single-slug path enforces — `--allow-unvalidated` remains the explicit escape hatch). Already-decomposed features ahead of it were skipped-with-notice; re-invoking after the user validates resumes from that feature. Mirrors the single-slug prerequisite exactly — no implicit gate bypass.
- ~~Q-A2: per-child unresolvable outcome — halt-at-child vs. skip-and-report?~~ → A: **Halt at that child.** When any child hits an unresolvable condition mid-batch (slug collision, validation that won't converge, ambiguous resolution), the batch stops at that child and surfaces its report verbatim. The user fixes it and re-invokes; resumability (disk-derived skip-already-complete) resumes at the failure without re-prompting completed children. Consistent with A1 and with the `/f-all` / `/e-all` halt-on-non-clean-outcome contract. Applies uniformly across all three batch commands.

---

<!-- Phase 2 validation appends the footer below on a clean exit. Do not pre-fill. -->

---
Validated 2026-06-17 — 3 rounds, 1 adversarial sub-agent confirmed
