---
description: Stage 2 of the PO flow at the Story altitude — run the inline /validate-artifact Pattern-1 loop on ticket.md and stamp the Validated footer (the readiness signal /e1-start-story keys on); a parent feature slug batch-validates every story under the feature sequentially (stateless disk-derived dispatcher, resumable). Refreshes the epic STATUS.md per validated child
---

# /ps2-validate

**Purpose:** Run Stage 2 of the PO flow at the **Story** altitude — the dedicated *validate* stage after define (`/ps1-define`). In single mode, resolve a story slug and run the **`/validate-artifact` Pattern-1 loop** on its `ticket.md`, stamping the `Validated …` footer (this footer is the readiness signal `/e1-start-story` keys on), then refresh the epic's `STATUS.md`. **Parent-slug batch mode:** passing the parent **feature** slug runs this command's single-story validation across every story under that feature, sequentially — a stateless, disk-derived dispatcher (the parent-slug batch mode introduced by #39). The story altitude has no decompose/finalize, so `/ps2-validate` is purely additive after `/ps1-define`.

**Recommended model:** Reasoning (Opus) — the Pattern-1 validation loop escalates to Reasoning per the `/validate-artifact` guidance. See [`reference/model_selection.md`](../../../../reference/model_selection.md).

---

## Usage

```
/ps2-validate {slug}
```

## Arguments

- `{slug}` (required) — a **story** slug (own altitude → validate the one `ticket.md`) **or** a parent **feature** slug (parent altitude → batch-validate every story under the feature). Globally unique, resolved per [`templates/SHAMT_RULES.template.md`](../../../../templates/SHAMT_RULES.template.md) §PO-tree resolution (tree-wide story glob; feature glob for the parent case).

## Prerequisites

- The slug resolves to a story folder (own altitude) or a feature folder (parent altitude). If it resolves to neither, halt (see Step 1).
- (Own altitude) `ticket.md`'s `## Open Questions` is drained (the define stage leaves it empty). Remaining open questions will fail the loop — surface that rather than footering.

## Step-by-step

### Step 1 — Resolve the slug and dispatch on altitude (own vs. parent vs. neither)

Resolve `{slug}` per §PO-tree resolution and branch on the altitude of the folder it resolves to:

- **Own altitude (the slug resolves to a *story* folder)** → run the single-story validation below (Steps 2–4).
- **Parent altitude (the slug resolves to a *feature* folder)** → enter **[Parent-slug batch mode](#parent-slug-batch-mode-feature--all-stories)**: validate every story under that feature, sequentially. Hand off to that section.
- **Neither (the slug resolves to no story and no feature, or to an epic)** → halt and report `slug {slug} resolves to neither a story (own altitude) nor a feature (parent altitude) — nothing to validate`.

### Step 2 — Inline Pattern-1 validation loop on `ticket.md`

Run the **same Pattern-1 validation loop `/validate-artifact` runs** against `epics/{epic-folder}/features/{feature-folder}/stories/{story-folder}/ticket.md`. **Cite the sibling command [`validate-artifact.md`](validate-artifact.md) (Steps 1–8) as the source of truth** for the loop mechanics — do **not** re-derive or re-enumerate the Pattern-1 dimensions.

#### Pattern-1 validation loop (inline):

1. **Primary clean round** — the primary agent self-reviews `ticket.md` against the applicable Pattern-1 dimensions (per `templates/SHAMT_RULES.template.md` Pattern 1), tracking `consecutive_clean` starting at 0 (clean → +1; not clean → reset to 0 and re-draft), exactly as `/validate-artifact` Steps 1–6 do. Dimensions appropriate for story-altitude artifacts (scope clarity, spec coverage, acceptance-criteria defensibility, open-questions drained, etc.) — cite `templates/SHAMT_RULES.template.md` normatively rather than re-listing.
2. **Standard exit (not Quick)** — story-validate always takes the **Standard** path: on `consecutive_clean = 1` it spawns **one independent adversarial `validation-checker` sub-agent (Haiku tier)** that re-reads `ticket.md` from scratch with zero bias and replies `CONFIRMED: Zero issues found after adversarial review.` only if clean — mirroring `/validate-artifact` Step 7. **No one-LOW allowance**: any sub-agent finding (even a single LOW) resets `consecutive_clean = 0` and returns to the primary round.
3. **Stamp the footer** — on `consecutive_clean = 1` primary-clean **plus** the sub-agent `CONFIRMED`, append the exact **two-line footer block** to `ticket.md`:

   ```text
   ---
   Validated {YYYY-MM-DD} — N rounds, 1 adversarial sub-agent confirmed
   ```

   (The `---` delimiter is part of the footer, not optional. This matches `/validate-artifact` Step 8 verbatim.)

The command body specifies this by **reference to `/validate-artifact`** (Steps 1–8) for the loop mechanics and **names the `ticket.md` footer** as the stamped output — it does not re-enumerate the dimensions or re-implement the checker.

### Step 3 — Refresh the epic STATUS.md

After the loop stamps the `Validated …` footer (Step 2), **re-derive the parent epic's `STATUS.md` from disk** per [`commands/po-status.md`](po-status.md) (resolve the epic from the story's folder path) — this story now shows as `Validated`. Re-derive the **whole table** (never patch a cell); the rollup is a derived VIEW per [`reference/epic_status_board.md`](../../../../reference/epic_status_board.md). In parent-slug batch mode, refresh once per child after that child's footer is stamped.

### Step 4 — Exit

```text
Story ticket {slug} is validated.
Next: /e1-start-story {slug} (stub-aware) to proceed to engineering intake.
```

The `/e1-start-story` ready-ticket pickup branch keys on the `Validated …` footer's presence on `ticket.md`.

## Parent-slug batch mode (feature → all stories)

Entered from Step 1's altitude dispatch when the slug resolves to a **feature** folder (the parent altitude) rather than a story folder. The command then runs its own single-story validation logic — its inline Pattern-1 validation loop / footer stamp (Step 2) — across every story under that feature, sequentially. This is **horizontal sibling fan-out at one altitude** — it validates each story; it does **not** chain into any other altitude's command. The batch loop is a **stateless, disk-derived dispatcher of this command's own single-story logic** — the worklist comes from the feature's on-disk decomposition output, and re-invocation is resumable (see Principle 1 reconciliation in Notes).

1. **Derive the ordered worklist from disk.** Read the feature's `feature.md` and take its child stories in the order given by `## Sequencing & Parallelization` (`Recommended order`), falling back to `## Target Stories` list order when no sequencing is recorded. Resolve each listed slug to its story folder per §PO-tree resolution.
   - **Empty / un-decomposed parent.** If the feature has no children (its `## Target Stories` decomposition list is empty / absent — e.g. the feature has not yet been run through `/pf3-decompose`), the worklist is empty: report `parent {slug} has no children to process — run the decompose phase (/pf3-decompose {slug}) first` and **exit cleanly** (a no-op, distinct from the Step 1 "neither own nor parent altitude → halt" dispatch case).
2. **Skip-already-validated-with-notice (resumability).** For each story in worklist order, first check whether its `ticket.md` already carries a `Validated …` footer (the single-slug completion signal this command stamps). If so, emit a one-line notice (`skipping {story-slug} — already validated`) and move to the next child. This makes re-invocation resumable: a batch interrupted partway resumes at the first incomplete child without re-prompting completed ones.
3. **Per-child execution.** For each not-yet-validated story, run this command's **single-story** Step-by-step verbatim on that story's slug — the inline Pattern-1 validation loop (Step 2) that stamps the child's `Validated …` footer, plus the per-child STATUS.md refresh (Step 3). Each child runs its **own complete validation before the next child starts**; never bulk-bomb the union of all children's findings across the batch.
4. **Halt-at-child on an unresolvable outcome.** If any child hits a condition it cannot resolve (slug collision, ambiguous resolution, a validation loop that cannot converge), **stop the batch at that child** and surface its report verbatim. The user fixes it and re-invokes; resumability (step 2) resumes at that child without re-validating the children already validated ahead of it.
5. **Final summary.** When the worklist is exhausted, report a one-line-per-child summary: each child slug and its outcome (`validated` / `skipped — already validated`), then the next-command suggestion (`/clear`, then `/e1-start-story {story-slug}` on each newly validated story to proceed to engineering intake).

## Exit criteria

- (Single mode) `ticket.md` carries a `Validated …` footer stamped by this run's inline Pattern-1 loop; the epic's `STATUS.md` has been re-derived; `/e1-start-story {slug}` suggested.
- (Batch mode) every story under the feature has been validated per the above, skipping any already-validated child and halting at the first unresolvable child, with a one-line-per-child summary reported.

## Notes

- **Thin wrapper over `/validate-artifact`.** The inline loop is the *same loop `/validate-artifact` runs* (cited by reference, not re-derived); this command resolves `ticket.md`, runs that loop, stamps the footer, and refreshes `STATUS.md`.
- **Carries the loop moved out of `/ps1-define`.** The inline Pattern-1 validation loop + footer stamp formerly lived in `/ps1-define` Step 7; it moves here so the story altitude matches epic/feature (`define → validate`). `/ps1-define` now ends defined-but-unvalidated. `/e1-start-story`'s readiness signal still keys on the footer's *presence* on `ticket.md` (unchanged location), now stamped by this command.
- **Parent-slug batch mode is horizontal fan-out, not vertical chaining — and honors Principle 1.** Passing a **feature** slug (the parent altitude) runs this command's single-story validation across every story under the feature (`## Parent-slug batch mode`). This is **horizontal sibling fan-out at one altitude** — it validates each story and does **not** chain into any other altitude's command. It honors Principle 1 by the same argument `CLAUDE.md` homes for the `/f-all` / `/e-all` drivers and #39 homes in `/ps1-define`: it is a **stateless, disk-derived dispatcher** of this command's own single-story logic (worklist derived from the feature's on-disk `Target Stories` / `Sequencing & Parallelization`, resumable by re-invocation via the skip-already-validated check, each child independently runnable via its own single slug) — not a state-holding mega-orchestrator.
- **Validate is its own stage at every altitude.** Define stages no longer stamp a footer; validation is the dedicated stage.
- **Fresh-agent runnable.** The story/feature folders + their artifacts live on disk; no conversation history required.

---

<!-- Managed by Shamt — do not edit. Regenerate from shamt-core/host/templates/claude/commands/ps2-validate.md. -->
