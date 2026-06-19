# Implementation Plan — po-validate-stage — Phase 1 (the 6 CREATEs)

**Proposal:** proposals/41-po-validate-stage.md
**Index:** proposals/41-po-validate-stage_PLAN.md
**Scope:** Proposed Changes rows 1–6 — three new `-validate` commands + three mirror skills.

> Execute these 6 steps in order. They have no dependency on the Phase-2 renames, but S3 (`ps2-validate.md`) authors the inline validation loop that Phase 3 S3 later removes from `ps1-define.md` — so this phase must run before Phase 3.

> **Verification ownership:** every step below carries a *per-step* verification the builder runs. Whole-plan invariants (zero-dangling sweep, git-history-preserved, footer counts) live in the INDEX file's `## Verification (post-execution, whole plan)` and are the architect's at `/f3` post-build — do not run them here.

---

## Step 1 — CREATE `commands/pe2-validate.md` (epic-altitude validate; row 1)

**Operation:** CREATE
**File:** `host/templates/claude/commands/pe2-validate.md`
**Sibling shape:** body pointer to `validate-artifact.md` (the loop source of truth); slug-resolution + prereq shape mirrors `commands/pe2-decompose.md` Steps 1–2; STATUS.md refresh hook mirrors `commands/pe2-decompose.md` Step 9b.

**Content (write verbatim):**

```markdown
---
description: Stage 2 of the PO flow at the Epic altitude — run the /validate-artifact Pattern-1 loop on the epic's epic.md and stamp the Validated footer (single mode only; epic is the top altitude, no parent to batch from), then refresh the epic STATUS.md
---

# /pe2-validate

**Purpose:** Run Stage 2 of the PO flow at the **Epic** altitude — the dedicated *validate* stage between define (`/pe1-define`) and decompose (`/pe3-decompose`). Resolve the epic slug, run the **`/validate-artifact` Pattern-1 loop** on the epic's `epic.md` (stamping the `Validated …` footer exactly as `/validate-artifact` does), then refresh the epic's `STATUS.md`. Epic is the top altitude — there is **no parent to batch from**, so `/pe2-validate` is **single mode only** (no parent-slug batch section).

**Recommended model:** Reasoning (Opus) — the Pattern-1 validation loop escalates to Reasoning per the `/validate-artifact` guidance. See [`reference/model_selection.md`](../../../../reference/model_selection.md).

---

## Usage

\`\`\`
/pe2-validate {slug}
\`\`\`

## Arguments

- `{slug}` (required) — epic slug or ticket ID (`T{N}`). Resolved against `epics/` per [`templates/SHAMT_RULES.template.md`](../../../../templates/SHAMT_RULES.template.md) §PO-tree resolution (`epics/{ID}-*/` · `epics/{slug}-*/` · `epics/*-{slug}-*/`; matches at most one, halt on multiple; `epics/archive/` excluded).

## Prerequisites

- `epics/{slug}-*/epic.md` must exist. If not, halt and direct the user to `/pe1-define {slug}` first.
- `epic.md`'s `## Open Questions` section should be drained (the define stage leaves it empty). If open questions remain, the validation loop will fail them — surface that rather than footering.

## Step-by-step

### Step 1 — Resolve the slug to an epic folder

Resolve `{slug}` to its epic folder per §PO-tree resolution (the same resolution `/pe3-decompose` Step 1 uses). Halt on zero (direct to `/pe1-define {slug}`) or multiple matches.

### Step 2 — Run the `/validate-artifact` Pattern-1 loop on `epic.md`

Run the **same Pattern-1 validation loop `/validate-artifact` runs** against `epics/{epic-folder}/epic.md`. **Cite the sibling command [`validate-artifact.md`](validate-artifact.md) (Steps 1–8) as the source of truth** for the loop mechanics — do **not** re-derive or re-enumerate the Pattern-1 dimensions here. Epic-validate always takes the **Standard** path (primary clean round + one adversarial `validation-checker` Haiku sub-agent confirmation; no one-LOW allowance). On a clean exit, the loop stamps the two-line footer block on `epic.md` exactly as `/validate-artifact` Step 8 does:

\`\`\`text
---
Validated {YYYY-MM-DD} — N rounds, 1 adversarial sub-agent confirmed
\`\`\`

### Step 3 — Refresh the epic STATUS.md

After the footer is stamped, **re-derive the epic's `STATUS.md` from disk** per [`commands/po-status.md`](po-status.md) (resolve the epic from the folder path) — the epic's rollup now reflects its `Validated` state. Re-derive the **whole table** (never patch a cell); the rollup is a derived VIEW per [`reference/epic_status_board.md`](../../../../reference/epic_status_board.md).

### Step 4 — Exit

\`\`\`text
Epic {slug} is validated.
Next: /pe3-decompose {slug} to break it into features.
\`\`\`

## Exit criteria

- `epics/{epic-folder}/epic.md` carries a `Validated …` footer stamped by this run's Pattern-1 loop.
- The epic's `STATUS.md` has been re-derived.
- The next command (`/pe3-decompose {slug}`) has been suggested in chat.

## Notes

- **Thin wrapper over `/validate-artifact`.** This command adds nothing to the Pattern-1 loop itself — it resolves the epic's `epic.md`, runs `/validate-artifact`'s loop on it, and refreshes `STATUS.md`. The loop mechanics and dimensions are owned by `/validate-artifact`; this command cites them by reference and never re-implements them.
- **Single mode only — no parent-slug batch.** Epic is the top altitude; there is no parent above it to fan out from. `/pf2-validate` and `/ps2-validate` (which *do* have a parent altitude) carry parent-slug batch modes; `/pe2-validate` does not.
- **Validate is its own stage at every altitude.** Define stages (`/pe1-define`) no longer stamp a footer; validation is the dedicated stage 2 (`define → validate → decompose`). This is the uniformity the validate stage establishes.
- **Fresh-agent runnable.** The epic folder + `epic.md` live on disk; no conversation history required.

---

<!-- Managed by Shamt — do not edit. Regenerate from shamt-core/host/templates/claude/commands/pe2-validate.md. -->
```

**Verification:**
- `test -s host/templates/claude/commands/pe2-validate.md` succeeds (file exists, non-empty).
- `grep -F 'validate-artifact.md' host/templates/claude/commands/pe2-validate.md` returns ≥1 match (cites the loop source of truth).
- `grep -F 'po-status.md' host/templates/claude/commands/pe2-validate.md` returns ≥1 match (STATUS.md refresh hook present).
- `grep -F '/pe3-decompose {slug}' host/templates/claude/commands/pe2-validate.md` returns ≥1 match (next-phase suggestion points at the renamed decompose).
- `grep -c 'Parent-slug batch' host/templates/claude/commands/pe2-validate.md` returns 0 (single mode only; the Notes mention it but as a "no batch" statement — the heading `## Parent-slug batch mode` must be absent: `grep -c '^## Parent-slug batch mode' …` returns 0).

---

## Step 2 — CREATE `commands/pf2-validate.md` (feature-altitude validate + parent-epic batch; row 2)

**Operation:** CREATE
**File:** `host/templates/claude/commands/pf2-validate.md`
**Sibling shape:** Step-2/3 single-mode logic mirrors row-1's `pe2-validate.md`; the `## Parent-slug batch mode (epic → all features)` section mirrors `commands/pf1-define.md`'s `## Parent-slug batch mode` section (worklist derivation, skip-with-notice, halt-at-child, final summary) and its Notes Principle-1 reconciliation paragraph.

**Content (write verbatim):**

```markdown
---
description: Stage 2 of the PO flow at the Feature altitude — run the /validate-artifact Pattern-1 loop on feature.md and stamp the Validated footer; a parent epic slug batch-validates every feature under the epic sequentially (stateless disk-derived dispatcher, resumable). Refreshes the epic STATUS.md per validated child
---

# /pf2-validate

**Purpose:** Run Stage 2 of the PO flow at the **Feature** altitude — the dedicated *validate* stage between define (`/pf1-define`) and decompose (`/pf3-decompose`). In single mode, resolve a feature slug and run the **`/validate-artifact` Pattern-1 loop** on its `feature.md`, stamping the `Validated …` footer, then refresh the epic's `STATUS.md`. **Parent-slug batch mode:** passing the parent **epic** slug runs this command's single-feature validation across every feature under that epic, sequentially — a stateless, disk-derived dispatcher (the parent-slug batch mode introduced by #39).

**Recommended model:** Reasoning (Opus) — the Pattern-1 validation loop escalates to Reasoning per the `/validate-artifact` guidance. See [`reference/model_selection.md`](../../../../reference/model_selection.md).

---

## Usage

\`\`\`
/pf2-validate {slug}
\`\`\`

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

Run the **same Pattern-1 validation loop `/validate-artifact` runs** against `epics/{epic-folder}/features/{feature-folder}/feature.md`. **Cite the sibling command [`validate-artifact.md`](validate-artifact.md) (Steps 1–8) as the source of truth** for the loop mechanics — do **not** re-derive the dimensions. Standard path (primary clean round + one adversarial `validation-checker` Haiku sub-agent; no one-LOW allowance). On a clean exit, stamp the two-line footer block on `feature.md` exactly as `/validate-artifact` Step 8 does.

### Step 3 — Refresh the epic STATUS.md

After the footer is stamped, **re-derive the parent epic's `STATUS.md` from disk** per [`commands/po-status.md`](po-status.md) (resolve the epic from the feature's folder path) — this feature now shows as `Validated`. Re-derive the **whole table** (never patch a cell); the rollup is a derived VIEW per [`reference/epic_status_board.md`](../../../../reference/epic_status_board.md). In parent-slug batch mode, refresh once per child after that child's footer is stamped.

### Step 4 — Exit

\`\`\`text
Feature {slug} is validated.
Next: /pf3-decompose {slug} to break it into stories.
\`\`\`

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
- **Parent-slug batch mode is horizontal fan-out, not vertical chaining — and honors Principle 1.** Passing an **epic** slug (the parent altitude) runs this command's single-feature validation across every feature under the epic (`## Parent-slug batch mode`). This is **horizontal sibling fan-out at one altitude** — distinct from vertical cross-altitude chaining: batch `/pf2-validate` over an epic validates the features; it does **not** then decompose them (that stays `/pf3-decompose`). It honors Principle 1 by the same argument `CLAUDE.md` homes for the `/f-all` / `/e-all` drivers and #39 homes in `/pf1-define` / `/pf2-decompose`: it is a **stateless, disk-derived dispatcher** of this command's own single-feature logic (worklist derived from the epic's on-disk `Target Features` / `Sequencing & Parallelization`, resumable by re-invocation via the skip-already-validated check, each child independently runnable via its own single slug) — not a state-holding mega-orchestrator.
- **Validate is its own stage at every altitude.** Define stages no longer stamp a footer; validation is the dedicated stage 2.
- **Fresh-agent runnable.** The feature/epic folders + their artifacts live on disk; no conversation history required.

---

<!-- Managed by Shamt — do not edit. Regenerate from shamt-core/host/templates/claude/commands/pf2-validate.md. -->
```

**Verification:**
- `test -s host/templates/claude/commands/pf2-validate.md` succeeds.
- `grep -F 'validate-artifact.md' host/templates/claude/commands/pf2-validate.md` returns ≥1 match.
- `grep -c '^## Parent-slug batch mode (epic → all features)' host/templates/claude/commands/pf2-validate.md` returns 1.
- `grep -F 'skipping {feature-slug} — already validated' host/templates/claude/commands/pf2-validate.md` returns 1 (skip-with-notice resumability).
- `grep -F '/pf3-decompose {slug}' host/templates/claude/commands/pf2-validate.md` returns ≥1 match (renamed decompose).
- `grep -F 'po-status.md' host/templates/claude/commands/pf2-validate.md` returns ≥1 match.

---

## Step 3 — CREATE `commands/ps2-validate.md` (story-altitude validate + parent-feature batch; row 3)

**Operation:** CREATE
**File:** `host/templates/claude/commands/ps2-validate.md`
**Sibling shape:** single-mode loop is the **inline Pattern-1 loop lifted verbatim from `commands/ps1-define.md` Step 7** (story-altitude wording preserved); the `## Parent-slug batch mode (feature → all stories)` section mirrors `commands/ps1-define.md`'s existing `## Parent-slug batch mode (feature → all stories)` section; STATUS.md refresh mirrors `ps1-define.md` Step 7b.

> This step authors the new home for the inline validation loop **before** Phase 3 S3 removes it from `ps1-define.md`. The loop content is lifted from `ps1-define.md` Step 7 (read at plan time: it cites `validate-artifact.md` Steps 1–8 as the source of truth, runs the Standard path with one Haiku `validation-checker`, no one-LOW allowance, and stamps the two-line footer).

**Content (write verbatim):**

```markdown
---
description: Stage 2 of the PO flow at the Story altitude — run the inline /validate-artifact Pattern-1 loop on ticket.md and stamp the Validated footer (the readiness signal /e1-start-story keys on); a parent feature slug batch-validates every story under the feature sequentially (stateless disk-derived dispatcher, resumable). Refreshes the epic STATUS.md per validated child
---

# /ps2-validate

**Purpose:** Run Stage 2 of the PO flow at the **Story** altitude — the dedicated *validate* stage after define (`/ps1-define`). In single mode, resolve a story slug and run the **`/validate-artifact` Pattern-1 loop** on its `ticket.md`, stamping the `Validated …` footer (this footer is the readiness signal `/e1-start-story` keys on), then refresh the epic's `STATUS.md`. **Parent-slug batch mode:** passing the parent **feature** slug runs this command's single-story validation across every story under that feature, sequentially — a stateless, disk-derived dispatcher (the parent-slug batch mode introduced by #39). The story altitude has no decompose/finalize, so `/ps2-validate` is purely additive after `/ps1-define`.

**Recommended model:** Reasoning (Opus) — the Pattern-1 validation loop escalates to Reasoning per the `/validate-artifact` guidance. See [`reference/model_selection.md`](../../../../reference/model_selection.md).

---

## Usage

\`\`\`
/ps2-validate {slug}
\`\`\`

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

   \`\`\`text
   ---
   Validated {YYYY-MM-DD} — N rounds, 1 adversarial sub-agent confirmed
   \`\`\`

   (The `---` delimiter is part of the footer, not optional. This matches `/validate-artifact` Step 8 verbatim.)

The command body specifies this by **reference to `/validate-artifact`** (Steps 1–8) for the loop mechanics and **names the `ticket.md` footer** as the stamped output — it does not re-enumerate the dimensions or re-implement the checker.

### Step 3 — Refresh the epic STATUS.md

After the loop stamps the `Validated …` footer (Step 2), **re-derive the parent epic's `STATUS.md` from disk** per [`commands/po-status.md`](po-status.md) (resolve the epic from the story's folder path) — this story now shows as `Validated`. Re-derive the **whole table** (never patch a cell); the rollup is a derived VIEW per [`reference/epic_status_board.md`](../../../../reference/epic_status_board.md). In parent-slug batch mode, refresh once per child after that child's footer is stamped.

### Step 4 — Exit

\`\`\`text
Story ticket {slug} is validated.
Next: /e1-start-story {slug} (stub-aware) to proceed to engineering intake.
\`\`\`

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
```

**Verification:**
- `test -s host/templates/claude/commands/ps2-validate.md` succeeds.
- `grep -F 'validate-artifact.md' host/templates/claude/commands/ps2-validate.md` returns ≥1 match.
- `grep -F 'consecutive_clean' host/templates/claude/commands/ps2-validate.md` returns ≥1 match (the inline loop moved in).
- `grep -c '^## Parent-slug batch mode (feature → all stories)' host/templates/claude/commands/ps2-validate.md` returns 1.
- `grep -F '/e1-start-story {slug}' host/templates/claude/commands/ps2-validate.md` returns ≥1 match (next-phase suggestion).
- `grep -F '/pf3-decompose {slug}' host/templates/claude/commands/ps2-validate.md` returns ≥1 match (renamed decompose in the empty-parent message).
- `grep -F 'po-status.md' host/templates/claude/commands/ps2-validate.md` returns ≥1 match.

---

## Step 4 — CREATE `skills/pe2-validate/SKILL.md` (mirror skill; row 4)

**Operation:** CREATE
**File:** `host/templates/claude/skills/pe2-validate/SKILL.md`
**Sibling shape:** mirror of `skills/pe1-define/SKILL.md` — frontmatter `name`/`description`/`triggers`, `## Overview`, pointer-form `## Protocol` (D2 / #37), `## Recommended model`, `## Exit criteria`, regen footer.

**Content (write verbatim):**

```markdown
---
name: pe2-validate
description: >
  Run Stage 2 of the Shamt PO flow at the Epic altitude — the dedicated validate
  stage between /pe1-define and /pe3-decompose. Resolves the epic slug and runs
  the /validate-artifact Pattern-1 loop on the epic's epic.md, stamping the
  Validated footer, then refreshes the epic STATUS.md. Single mode only — epic
  is the top altitude, no parent to batch from. Invoke when the user wants to
  validate the epic, run the validate stage for an epic, footer an epic, or
  validate an epic before decomposing it.
triggers:
  - "validate the epic"
  - "validate epic {slug}"
  - "run the validate stage for this epic"
  - "footer the epic"
  - "validate this epic before decomposing"
---

## Overview

Mirrors the `/pe2-validate {slug}` slash command. Same canonical body, two host wirings. A thin altitude-aware wrapper over the `/validate-artifact` Pattern-1 loop; single mode only (epic is the top altitude).

## Protocol

Follow the canonical `/pe2-validate` command body verbatim — see [`commands/pe2-validate.md`](../../commands/pe2-validate.md).

## Recommended model

Reasoning (Opus) — the Pattern-1 validation loop escalates to Reasoning per the `/validate-artifact` guidance. See [`reference/model_selection.md`](../../../../../reference/model_selection.md).

## Exit criteria

`epics/{epic-folder}/epic.md` carries a `Validated …` footer stamped by the Pattern-1 loop; the epic's `STATUS.md` has been re-derived; `/pe3-decompose {slug}` has been suggested.

<!-- Managed by Shamt — do not edit. Regenerate from shamt-core/host/templates/claude/skills/pe2-validate/SKILL.md. -->
```

**Verification:**
- `test -s host/templates/claude/skills/pe2-validate/SKILL.md` succeeds.
- `grep -F 'Follow the canonical `/pe2-validate` command body verbatim' host/templates/claude/skills/pe2-validate/SKILL.md` returns 1 (pointer form, no step paraphrase).
- `grep -cE '^[0-9]+\.' host/templates/claude/skills/pe2-validate/SKILL.md` returns 0 in the `## Protocol` section (no numbered step paraphrase).
- `grep -F 'name: pe2-validate' host/templates/claude/skills/pe2-validate/SKILL.md` returns 1.

---

## Step 5 — CREATE `skills/pf2-validate/SKILL.md` (mirror skill; row 5)

**Operation:** CREATE
**File:** `host/templates/claude/skills/pf2-validate/SKILL.md`
**Sibling shape:** mirror of `skills/pe1-define/SKILL.md`; description surfaces single + parent-epic batch.

**Content (write verbatim):**

```markdown
---
name: pf2-validate
description: >
  Run Stage 2 of the Shamt PO flow at the Feature altitude — the dedicated
  validate stage between /pf1-define and /pf3-decompose. In single mode resolves
  a feature slug and runs the /validate-artifact Pattern-1 loop on feature.md,
  stamping the Validated footer, then refreshes the epic STATUS.md. Parent-slug
  batch mode: passing the parent epic slug batch-validates every feature under
  the epic sequentially — a stateless, disk-derived dispatcher that is itself
  resumable (skips already-validated children). Invoke when the user wants to
  validate a feature, run the validate stage for a feature, footer a feature, or
  validate all features in the epic.
triggers:
  - "validate the feature"
  - "validate feature {slug}"
  - "run the validate stage for this feature"
  - "footer the feature"
  - "validate all features in the epic"
  - "validate every feature under this epic"
---

## Overview

Mirrors the `/pf2-validate {slug}` slash command. Same canonical body, two host wirings. A thin altitude-aware wrapper over the `/validate-artifact` Pattern-1 loop, plus the #39 parent-slug batch mode (parent epic slug → validate all features).

## Protocol

Follow the canonical `/pf2-validate` command body verbatim — see [`commands/pf2-validate.md`](../../commands/pf2-validate.md).

## Recommended model

Reasoning (Opus) — the Pattern-1 validation loop escalates to Reasoning per the `/validate-artifact` guidance. See [`reference/model_selection.md`](../../../../../reference/model_selection.md).

## Exit criteria

(Single mode) `feature.md` carries a `Validated …` footer stamped by the Pattern-1 loop; the epic's `STATUS.md` has been re-derived; `/pf3-decompose {slug}` suggested. (Parent-slug batch mode, an epic slug is passed) every feature under the epic has been validated, skipping any already-validated child and halting at the first unresolvable child, with a one-line-per-child summary reported.

<!-- Managed by Shamt — do not edit. Regenerate from shamt-core/host/templates/claude/skills/pf2-validate/SKILL.md. -->
```

**Verification:**
- `test -s host/templates/claude/skills/pf2-validate/SKILL.md` succeeds.
- `grep -F 'Follow the canonical `/pf2-validate` command body verbatim' host/templates/claude/skills/pf2-validate/SKILL.md` returns 1.
- `grep -F 'validate all features in the epic' host/templates/claude/skills/pf2-validate/SKILL.md` returns ≥1 (description/triggers surface batch).
- `grep -F 'name: pf2-validate' host/templates/claude/skills/pf2-validate/SKILL.md` returns 1.

---

## Step 6 — CREATE `skills/ps2-validate/SKILL.md` (mirror skill; row 6)

**Operation:** CREATE
**File:** `host/templates/claude/skills/ps2-validate/SKILL.md`
**Sibling shape:** mirror of `skills/pe1-define/SKILL.md`; description surfaces single + parent-feature batch.

**Content (write verbatim):**

```markdown
---
name: ps2-validate
description: >
  Run Stage 2 of the Shamt PO flow at the Story altitude — the dedicated validate
  stage after /ps1-define. In single mode resolves a story slug and runs the
  inline /validate-artifact Pattern-1 loop on ticket.md, stamping the Validated
  footer (the readiness signal /e1-start-story keys on), then refreshes the epic
  STATUS.md. Parent-slug batch mode: passing the parent feature slug
  batch-validates every story under the feature sequentially — a stateless,
  disk-derived dispatcher that is itself resumable (skips already-validated
  children). Invoke when the user wants to validate a story, run the validate
  stage for a story, footer a ticket, or validate all stories in the feature.
triggers:
  - "validate the story"
  - "validate story {slug}"
  - "run the validate stage for this story"
  - "footer the ticket"
  - "validate all stories in the feature"
  - "validate every story under this feature"
---

## Overview

Mirrors the `/ps2-validate {slug}` slash command. Same canonical body, two host wirings. A thin altitude-aware wrapper over the `/validate-artifact` Pattern-1 loop (the loop moved out of `/ps1-define`), plus the #39 parent-slug batch mode (parent feature slug → validate all stories).

## Protocol

Follow the canonical `/ps2-validate` command body verbatim — see [`commands/ps2-validate.md`](../../commands/ps2-validate.md).

## Recommended model

Reasoning (Opus) — the Pattern-1 validation loop escalates to Reasoning per the `/validate-artifact` guidance. See [`reference/model_selection.md`](../../../../../reference/model_selection.md).

## Exit criteria

(Single mode) `ticket.md` carries a `Validated …` footer stamped by the inline Pattern-1 loop; the epic's `STATUS.md` has been re-derived; `/e1-start-story {slug}` suggested. (Parent-slug batch mode, a feature slug is passed) every story under the feature has been validated, skipping any already-validated child and halting at the first unresolvable child, with a one-line-per-child summary reported.

<!-- Managed by Shamt — do not edit. Regenerate from shamt-core/host/templates/claude/skills/ps2-validate/SKILL.md. -->
```

**Verification:**
- `test -s host/templates/claude/skills/ps2-validate/SKILL.md` succeeds.
- `grep -F 'Follow the canonical `/ps2-validate` command body verbatim' host/templates/claude/skills/ps2-validate/SKILL.md` returns 1.
- `grep -F 'validate all stories in the feature' host/templates/claude/skills/ps2-validate/SKILL.md` returns ≥1.
- `grep -F 'name: ps2-validate' host/templates/claude/skills/ps2-validate/SKILL.md` returns 1.

---
Validated 2026-06-19 — 2 rounds, 1 adversarial sub-agent confirmed
