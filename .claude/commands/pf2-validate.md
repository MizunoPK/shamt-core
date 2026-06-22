---
description: Stage 2 of the PO flow at the Feature altitude — run the /validate-artifact Pattern-1 loop on feature.md and stamp the Validated footer; a parent epic slug batch-validates every feature under the epic sequentially (stateless disk-derived dispatcher, resumable). Refreshes the epic STATUS.md per validated child
---

# /pf2-validate

**Purpose:** Run Stage 2 of the PO flow at the **Feature** altitude — the dedicated *validate* stage between define (`/pf1-define`) and decompose (`/pf3-decompose`). In single mode, resolve a feature slug and run the **`/validate-artifact` Pattern-1 loop** on its `feature.md`, stamping the `Validated …` footer, then refresh the epic's `STATUS.md`. **Parent-slug batch mode:** passing the parent **epic** slug runs this command's single-feature validation across every feature under that epic, sequentially — a stateless, disk-derived dispatcher (the parent-slug batch mode introduced by #39).

**Recommended model:** Reasoning (Opus) — the Pattern-1 validation loop escalates to Reasoning per the `/validate-artifact` guidance. See [`reference/model_selection.md`](../../../../reference/model_selection.md).

---

## Usage

```
/pf2-validate {slug}
```

## Arguments

- `{slug}` (required) — a **feature** slug (own altitude → validate the one `feature.md`) **or** a parent **epic** slug (parent altitude → batch-validate every feature under the epic). Resolved per [`templates/SHAMT_RULES.template.md`](../../../../templates/SHAMT_RULES.template.md) §PO-tree resolution (tree-wide feature glob; epic glob for the parent case).

## Prerequisites

- The slug resolves to a feature folder (own altitude) or an epic folder (parent altitude). If it resolves to neither, halt (see Step 1).

## Step-by-step

### Step 1 — Resolve the slug and dispatch on altitude (own vs. parent vs. neither)

Resolve `{slug}` per §PO-tree resolution and branch on the altitude of the folder it resolves to:

- **Own altitude (the slug resolves to a *feature* folder)** → run the single-feature validation below (Steps 2–4).
- **Parent altitude (the slug resolves to an *epic* folder)** → enter **[Parent-slug batch mode](#parent-slug-batch-mode-epic--all-features)**: validate every feature under that epic, sequentially. Hand off to that section and do not run the single-feature steps directly.
- **Neither (the slug resolves to no feature and no epic, or to a story)** → halt and report `slug {slug} resolves to neither a feature (own altitude) nor an epic (parent altitude) — nothing to validate`.

### Step 2 — Run the `/validate-artifact` Pattern-1 loop on `feature.md`

Run the **same Pattern-1 validation loop `/validate-artifact` runs** against `epics/{epic-folder}/features/{feature-folder}/feature.md`. **Cite the sibling command [`validate-artifact.md`](validate-artifact.md) (Steps 1–8) as the source of truth** for the loop mechanics — do **not** re-derive the dimensions. Uniform validation exit (primary clean round + one adversarial `validation-checker` Haiku sub-agent; no one-LOW allowance). On a clean exit, stamp the two-line footer block on `feature.md` exactly as `/validate-artifact` Step 8 does.

### Step 3 — Refresh the epic STATUS.md

After the footer is stamped, **re-derive the parent epic's `STATUS.md` from disk** per [`commands/po-status.md`](po-status.md) (resolve the epic from the feature's folder path) — this feature now shows as `Validated`. Re-derive the **whole table** (never patch a cell); the rollup is a derived VIEW per [`reference/epic_status_board.md`](../../../../reference/epic_status_board.md). In parent-slug batch mode, refresh once per child after that child's footer is stamped.

### Step 4 — Exit

```text
Feature {slug} is validated.
Next: /pf3-decompose {slug} to break it into stories.
```

## Parent-slug batch mode (epic → all features)

Entered from Step 1's altitude dispatch when the slug resolves to an **epic** folder (the parent altitude) rather than a feature folder. The command then runs its own single-feature validation logic across every feature under that epic, sequentially. This is **horizontal sibling fan-out at one altitude** — it validates each feature; it does **not** decompose them (that stays `/pf3-decompose`) and does **not** chain into any other altitude's command. The batch loop is a **stateless, disk-derived dispatcher of this command's own single-feature logic** — the worklist comes from the epic's on-disk decomposition output, and re-invocation is resumable (see Principle 1 reconciliation in Notes).

1. **Derive the ordered worklist from disk.** Read the epic's `epic.md` and take its child features in the order given by `## Sequencing & Parallelization` (`Recommended order`), falling back to `## Target Features` list order when no sequencing is recorded. Resolve each listed slug to its feature folder per §PO-tree resolution.
   - **Empty / un-decomposed parent.** If the epic has no children (its `## Target Features` decomposition list is empty / absent — e.g. the epic has not yet been run through `/pe3-decompose`), the worklist is empty: report `parent {slug} has no children to process — run the decompose phase (/pe3-decompose {slug}) first` and **exit cleanly** (a no-op, distinct from the Step 1 "neither own nor parent altitude → halt" dispatch case).
2. **Skip-already-validated-with-notice (resumability).** For each feature in worklist order, first check whether its `feature.md` already carries a `Validated …` footer (the single-slug completion signal this command stamps). If so, emit a one-line notice (`skipping {feature-slug} — already validated`) and move to the next child. This makes re-invocation resumable: a batch interrupted partway resumes at the first incomplete child without re-prompting completed ones.
3. **Per-child execution.** For each not-yet-validated feature, run this command's **single-feature** Step-by-step verbatim on that feature's slug — the full Pattern-1 validation loop (Step 2) that stamps the child's `Validated …` footer, plus the per-child STATUS.md refresh (Step 3). Each child runs its **own complete validation before the next child starts**; never bulk-bomb the union of all children's findings across the batch.
4. **Halt-at-child on an unresolvable outcome.** If any child hits a condition it cannot resolve (slug collision, ambiguous resolution, a validation loop that cannot converge — e.g. a finding that needs a re-draft), **stop the batch at that child** and surface its report verbatim. The user fixes it and re-invokes; resumability (step 2) resumes at that child without re-validating the children already validated ahead of it.
5. **Final summary.** When the worklist is exhausted, report a one-line-per-child summary: each child slug and its outcome (`validated` / `skipped — already validated`), then the next-command suggestion (`/clear`, then `/pf3-decompose {epic-slug}` to decompose the validated features).

## Exit criteria

- (Single mode) `feature.md` carries a `Validated …` footer stamped by this run's Pattern-1 loop; the epic's `STATUS.md` has been re-derived; `/pf3-decompose {slug}` suggested.
- (Batch mode) every feature under the epic has been validated per the above, skipping any already-validated child and halting at the first unresolvable child, with a one-line-per-child summary reported.

## Notes

- **Thin wrapper over `/validate-artifact`.** Adds nothing to the Pattern-1 loop itself — it resolves the artifact, runs `/validate-artifact`'s loop on it, refreshes `STATUS.md`. Loop mechanics + dimensions are owned by `/validate-artifact`, cited by reference, never re-implemented.
- **Parent-slug batch mode is horizontal fan-out, not vertical chaining — and honors Principle 1.** Passing an **epic** slug (the parent altitude) runs this command's single-feature validation across every feature under the epic (`## Parent-slug batch mode`). This is **horizontal sibling fan-out at one altitude** — distinct from vertical cross-altitude chaining: batch `/pf2-validate` over an epic validates the features; it does **not** then decompose them (that stays `/pf3-decompose`). It honors Principle 1 by the same argument `CLAUDE.md` homes for the `/f-all` / `/e-all` drivers and #39 homes in `/pf1-define` / `/pf3-decompose`: it is a **stateless, disk-derived dispatcher** of this command's own single-feature logic (worklist derived from the epic's on-disk `Target Features` / `Sequencing & Parallelization`, resumable by re-invocation via the skip-already-validated check, each child independently runnable via its own single slug) — not a state-holding mega-orchestrator.
- **Validate is its own stage at every altitude.** Define stages no longer stamp a footer; validation is the dedicated stage 2.
- **Fresh-agent runnable.** The feature/epic folders + their artifacts live on disk; no conversation history required.

---

<!-- Managed by Shamt — do not edit. Regenerate from shamt-core/host/templates/claude/commands/pf2-validate.md. -->
