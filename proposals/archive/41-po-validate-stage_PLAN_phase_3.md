# Implementation Plan — po-validate-stage — Phase 3 (named EDITs, rows 13–19)

**Proposal:** proposals/41-po-validate-stage.md
**Index:** proposals/41-po-validate-stage_PLAN.md
**Scope:** Proposed Changes rows 13–19 — the behavioral + named-reference edits to `/pe1-define`, `/pf1-define`, `/ps1-define`, `/e1-start-story`, README, `epic_status_board.md`, `model_selection.md`. Runs after Phases 1–2 (the `-validate` commands and the renamed decompose/finalize commands now exist).

> **Verification ownership:** per-step verifications below are the builder's. The whole-tree zero-dangling sweep + footer-count + e1-detection-byte-unchanged invariants are whole-plan checks in the INDEX file.

---

## Step 1 — EDIT `commands/pe1-define.md` (next-phase repoint + decompose rename; row 13)

**Operation:** EDIT
**File:** `host/templates/claude/commands/pe1-define.md`

- **EDIT — Step 9 next-phase suggestion: hand-run `/validate-artifact` → `/pe2-validate`.**
  **Locate:**
  ```
  ```
  /clear
  /validate-artifact epics/{ID}-{slug}-{brief}/epic.md
  ```

  After validation appends the footer, `/pe2-decompose {slug}` can run. This command stays independently runnable by a fresh agent off on-disk state per Principle 1 — chaining validation here would couple the two phases.
  ```
  **Replace:**
  ```
  ```
  /clear
  /pe2-validate {slug}
  ```

  After `/pe2-validate` appends the footer, `/pe3-decompose {slug}` can run. This command stays independently runnable by a fresh agent off on-disk state per Principle 1 — chaining validation here would couple the two phases.
  ```

- **EDIT — Step 5 `/pe2-decompose` ownership reference.**
  **Locate:** `5. **Do not populate `Target Features` or `Sequencing & Parallelization`** in this command. Those sections are owned by `/pe2-decompose`; leave them present-but-empty per the template.`
  **Replace:** `5. **Do not populate `Target Features` or `Sequencing & Parallelization`** in this command. Those sections are owned by `/pe3-decompose`; leave them present-but-empty per the template.`

- **EDIT — Exit-criteria checklist `/pe2-decompose` ownership reference.**
  **Locate:** `- [ ] `Target Features` and `Sequencing & Parallelization` are **left empty** (owned by `/pe2-decompose`).`
  **Replace:** `- [ ] `Target Features` and `Sequencing & Parallelization` are **left empty** (owned by `/pe3-decompose`).`

- **EDIT — Exit-criteria "validate adds it" line names the validate stage.**
  **Locate:** `- No validation footer yet — `/validate-artifact` adds it.`
  **Replace:** `- No validation footer yet — `/pe2-validate` (the epic-altitude validate stage) adds it.`

- **EDIT — Notes "Epic-level validation" + `/pe2-decompose` references.**
  **Locate:** `- **Epic-level validation is `/validate-artifact`.** Epics have no review phase — Pattern 1 validation only. The decomposition exit gate run inside `/pe2-decompose` is a stub-batch check on that command's output and is **distinct from `/validate-artifact`**; do not conflate.`
  **Replace:** `- **Epic-level validation is `/pe2-validate`** (a thin wrapper over `/validate-artifact`). Epics have no review phase — Pattern 1 validation only. The decomposition exit gate run inside `/pe3-decompose` is a stub-batch check on that command's output and is **distinct from `/validate-artifact`**; do not conflate.`

- **EDIT — Notes "No Target Features work here" `/pe2-decompose` reference.**
  **Locate:** `- **No `Target Features` work here.** This command writes the epic with the decomposition sections empty; `/pe2-decompose` fills them.`
  **Replace:** `- **No `Target Features` work here.** This command writes the epic with the decomposition sections empty; `/pe3-decompose` fills them.`

**Verification:**
- `grep -c 'pe2-decompose' host/templates/claude/commands/pe1-define.md` returns 0.
- `grep -F '/pe2-validate {slug}' host/templates/claude/commands/pe1-define.md` returns ≥1.
- `grep -F '/pe3-decompose {slug}' host/templates/claude/commands/pe1-define.md` returns ≥1.

---

## Step 2 — EDIT `commands/pf1-define.md` (next-phase repoint + decompose rename; row 14)

**Operation:** EDIT
**File:** `host/templates/claude/commands/pf1-define.md`

> #39's parent-epic batch "define all features" mode is **unchanged** — only the next-phase suggestion and `/pf2-decompose` token references change. Replace every `pf2-decompose` token with `pf3-decompose`, and repoint the hand-run-`/validate-artifact` next step to `/pf2-validate`.

- **EDIT — frontmatter description deferral reference.**
  **Locate:** `description: Phase 3 of the PO flow — flesh out a feature (stub from /pe2-decompose, standalone, or tracker-seeded) into a feature.md ready for /validate-artifact`
  **Replace:** `description: Phase 3 of the PO flow — flesh out a feature (stub from /pe3-decompose, standalone, or tracker-seeded) into a feature.md ready for /pf2-validate`

- **EDIT — Purpose line `/pf2-decompose` reference.**
  **Locate:** `Leaves `Target Stories` and `Sequencing & Parallelization` empty — `/pf2-decompose` fills them later.`
  **Replace:** `Leaves `Target Stories` and `Sequencing & Parallelization` empty — `/pf3-decompose` fills them later.`

- **EDIT — Step 9 next-phase suggestion.**
  **Locate:**
  ```
  ```
  /clear
  /validate-artifact epics/{epic-folder}/features/{ID}-{slug}-{brief}/feature.md
  ```

  After validation appends the footer, `/pf2-decompose {slug}` can run. This command stays independently runnable by a fresh agent off on-disk state per Principle 1 — chaining validation here would couple the two phases.
  ```
  **Replace:**
  ```
  ```
  /clear
  /pf2-validate {slug}
  ```

  After `/pf2-validate` appends the footer, `/pf3-decompose {slug}` can run. This command stays independently runnable by a fresh agent off on-disk state per Principle 1 — chaining validation here would couple the two phases.
  ```

- **EDIT — replace every remaining `/pf2-decompose` / bare `pf2-decompose` token and every `/pe2-decompose` / bare `pe2-decompose` token.** Per the plan-time grep these occur at: Step 2 stub-detection (`per the /pe2-decompose Step 8 contract`), Mode A header ("the common case after `/pe2-decompose`"), Mode A para ("already carries a populated ## Goal from `/pe2-decompose` Step 8"), Mode A item 3 ("those are `/pf2-decompose`'s output"), Step 5 ("owned by `/pf2-decompose`"), Exit-criteria checklist ("owned by `/pf2-decompose`"), the parent-slug batch-mode empty-parent message ("`/pe2-decompose {slug}`"), the batch-mode final-summary suggestion ("`/pf2-decompose {epic-slug}`"), the Notes "Feature-level validation" conflate line ("inside `/pf2-decompose`"), the Notes "No Target Stories work here" line ("`/pf2-decompose` fills them"), and the Notes Principle-1 reconciliation paragraph ("the 'No `/pf2-decompose` / Engineer-flow auto-invocation' discipline … batch `/pf1-define` over an epic still does not decompose those features (that stays `/pf2-decompose`)"). For each:
  - `pf2-decompose` → `pf3-decompose`
  - `pe2-decompose` → `pe3-decompose`
  Enumerate with `git grep -n 'pf2-decompose\|pe2-decompose' host/templates/claude/commands/pf1-define.md` and apply one Edit per unique surrounding string.

- **EDIT — Notes "Feature-level validation is `/validate-artifact`" → name `/pf2-validate`.** (Apply AFTER the bulk token-replace above; locate string uses the post-bulk-replace form with `pf3-decompose`.)
  **Locate:** `- **Feature-level validation is `/validate-artifact`.** Features have no review phase — Pattern 1 validation only. The decomposition exit gate run inside `/pf3-decompose` is a stub-batch check on that command's output and is **distinct from `/validate-artifact`**; do not conflate.`
  **Replace:** `- **Feature-level validation is `/pf2-validate`** (a thin wrapper over `/validate-artifact`). Features have no review phase — Pattern 1 validation only. The decomposition exit gate run inside `/pf3-decompose` is a stub-batch check on that command's output and is **distinct from `/validate-artifact`**; do not conflate.`

- **EDIT — batch-mode final-summary suggestion repoint.** (Apply AFTER the bulk token-replace above; locate string uses the post-bulk-replace form with `pf3-decompose`.)
  **Locate:** `then the next-command suggestion (`/clear`, then `/validate-artifact` on each newly defined feature, or `/pf3-decompose {epic-slug}` to decompose them).`
  **Replace:** `then the next-command suggestion (`/clear`, then `/pf2-validate {epic-slug}` to validate all the newly defined features, or `/pf2-validate` on each one individually, then `/pf3-decompose {epic-slug}` to decompose them).`

**Verification:**
- `grep -c 'pf2-decompose' host/templates/claude/commands/pf1-define.md` returns 0.
- `grep -c 'pe2-decompose' host/templates/claude/commands/pf1-define.md` returns 0.
- `grep -F '/pf2-validate {slug}' host/templates/claude/commands/pf1-define.md` returns ≥1.
- `grep -F '/pf3-decompose {slug}' host/templates/claude/commands/pf1-define.md` returns ≥1.

---

## Step 3 — EDIT `commands/ps1-define.md` (REMOVE inline validation loop + footer stamp + STATUS hook; repoint; row 15)

**Operation:** EDIT (the behavioral edit — most load-bearing in the plan)
**File:** `host/templates/claude/commands/ps1-define.md`

The command must end after the open-questions dialog (Step 6) with `ticket.md` **defined-but-unvalidated**. Remove Step 7 (inline Pattern-1 loop + footer stamp) and Step 7b (the footer-tied STATUS.md refresh hook), repoint the exit + next-phase, and reword the batch mode + Notes so the story batch is "define all stories" (no inline validation), with skip-resumability keyed on "already-defined" rather than "Validated footer present."

- **EDIT — frontmatter description: drop the inline-validation clause.**
  **Locate:** `description: Story stage-1 define (story altitude analogue of /pf1-define) — flesh out the planning ticket via open-questions dialog, then run an inline Pattern-1 validation loop to stamp the Validated footer; ready for /e1-start-story (stub-aware)`
  **Replace:** `description: Story stage-1 define (story altitude analogue of /pf1-define) — flesh out the planning ticket via open-questions dialog, leaving it defined-but-unvalidated; validation is the dedicated /ps2-validate stage`

- **EDIT — Purpose: remove the inline-validation sentences + asymmetry callout.**
  **Locate:**
  ```
  **Purpose:** Run Stage 1 of the PO flow at the **Story** altitude (the story-specific define + validation stage). Resolve a slug, branch on three input modes (ingest an existing `/ps0-draft` stub when present, create a standalone story from scratch, or seed from a tracker work-item payload when the active profile supports Story), drive an open-questions iterative dialog over the scope one-liner + spec structure, and produce the story-ticket stub under its parent feature — `epics/{epic-folder}/features/{feature-folder}/stories/{ID}-{slug}-{brief}/ticket.md`. Unlike `/pe1-define` and `/pf1-define` (which defer validation to `/validate-artifact`), `/ps1-define` runs an **inline Pattern-1 validation loop** so the command **stamps the `Validated …` footer itself**. This footer is the readiness signal `/e1-start-story` keys on.
  ```
  **Replace:**
  ```
  **Purpose:** Run Stage 1 of the PO flow at the **Story** altitude (the story-specific define stage). Resolve a slug, branch on three input modes (ingest an existing `/ps0-draft` stub when present, create a standalone story from scratch, or seed from a tracker work-item payload when the active profile supports Story), drive an open-questions iterative dialog over the scope one-liner + spec structure, and produce the story-ticket stub under its parent feature — `epics/{epic-folder}/features/{feature-folder}/stories/{ID}-{slug}-{brief}/ticket.md`. Like `/pe1-define` and `/pf1-define`, `/ps1-define` **defers validation to the dedicated validate stage** — here `/ps2-validate` — and does **not** stamp a `Validated …` footer itself. Define no longer validates at *any* altitude; validation is its own stage. The footer that `/ps2-validate` later stamps on `ticket.md` is the readiness signal `/e1-start-story` keys on.
  ```

- **EDIT — Recommended model: drop the inline-loop clause.**
  **Locate:** `**Recommended model:** Reasoning (Opus) — design/dialog task + inline validation loop; cite [`reference/model_selection.md`](../../../../reference/model_selection.md).`
  **Replace:** `**Recommended model:** Balanced (Sonnet) — open-questions dialog / define task (no inline validation loop; validation is `/ps2-validate`'s job, escalating to Reasoning there); cite [`reference/model_selection.md`](../../../../reference/model_selection.md).`

- **EDIT — Step 2 re-entry "Extend" footer-handling: the loop no longer re-stamps.**
  **Locate:** `     - **Extend** — preserve existing content and add to it. **If a prior `Validated …` footer is present, strip it before continuing** — extension changes the artifact and invalidates the prior pass; the inline validation loop will re-stamp a new footer.`
  **Replace:** `     - **Extend** — preserve existing content and add to it. **If a prior `Validated …` footer is present, strip it before continuing** — extension changes the artifact and invalidates the prior pass; re-run `/ps2-validate {slug}` afterward to re-stamp a new footer.`

- **EDIT — Mode A item 4: drop "before running the inline validation loop (below)".**
  **Locate:** `4. **On completion of the open-questions dialog** (Step 6), before running the inline validation loop (below), **strip the marker line and the `## Scratch Notes (stage-0 capture)` section** from `ticket.md`. This is the f1-style ingestion: the draft status + Scratch Notes are a temporary staging vehicle, removed once the story is defined.`
  **Replace:** `4. **On completion of the open-questions dialog** (Step 6), **strip the marker line and the `## Scratch Notes (stage-0 capture)` section** from `ticket.md`. This is the f1-style ingestion: the draft status + Scratch Notes are a temporary staging vehicle, removed once the story is defined.`

- **EDIT — Step 6 "Mode A note": drop "before the inline validation loop runs".**
  **Locate:** `**Mode A note:** After the dialog completes, before the inline validation loop runs, **strip the `**Status:** Draft (f0 — story-idea capture, unrefined)` marker line and the `## Scratch Notes (stage-0 capture)` section** from `ticket.md`. This is the f1-style ingestion: the draft overlay is removed once the story is defined.`
  **Replace:** `**Mode A note:** After the dialog completes, **strip the `**Status:** Draft (f0 — story-idea capture, unrefined)` marker line and the `## Scratch Notes (stage-0 capture)` section** from `ticket.md`. This is the f1-style ingestion: the draft overlay is removed once the story is defined.`

- **DELETE — Step 7 (the entire inline Pattern-1 validation loop, including its `#### Pattern-1 validation loop (inline):` subsection) AND Step 7b (the STATUS.md refresh hook).**
  **Justification:** the inline loop + footer stamp move to `/ps2-validate` (authored Phase 1 S3); the footer-tied STATUS.md refresh hook moves with it. `/ps1-define` ends after the dialog (Step 6) with the ticket defined-but-unvalidated.
  **Locate (delete this entire block, from the Step 7 heading through the end of Step 7b, i.e. everything between the end of Step 6 and the start of Step 8):**
  ```
  ### Step 7 — Inline Pattern-1 validation loop

  **This is the load-bearing difference:** `/ps1-define` runs the validation loop **inline** (NOT deferred to a separate `/validate-artifact` call). The validation loop is the **same loop `/validate-artifact` runs** (cite the sibling command `validate-artifact.md` Steps 1–8 as the source of truth rather than re-deriving the dimensions; `validate-artifact.md` is a sibling in the SAME `host/templates/claude/commands/` directory, so the in-body relative-path citation is simply `validate-artifact.md` — equivalently `./validate-artifact.md`).

  #### Pattern-1 validation loop (inline):

  1. **Primary clean round** — the primary agent self-reviews `ticket.md` against the applicable Pattern-1 dimensions (per `templates/SHAMT_RULES.template.md` Pattern 1), tracking `consecutive_clean` starting at 0 (clean → +1; not clean → reset to 0 and re-draft), exactly as `/validate-artifact` Steps 1–6 do:
     - Dimensions: read-and-investigate, identify-issues, classify-severity, fix-all-issues (immediately), update-consecutive-clean, check-exit.
     - Pattern 1 dimensions (cite `templates/SHAMT_RULES.template.md` normatively): appropriate for story-altitude artifacts (scope clarity, spec coverage, acceptance-criteria defensibility, open-questions drained, etc.).
  2. **Standard exit (not Quick)** — story-define always takes the **Standard** path: on `consecutive_clean = 1` it spawns **one independent adversarial `validation-checker` sub-agent (Haiku tier)** that re-reads `ticket.md` from scratch with zero bias and replies `CONFIRMED: Zero issues found after adversarial review.` only if clean — mirroring `/validate-artifact` Step 7. **No one-LOW allowance**: any sub-agent finding (even a single LOW) resets `consecutive_clean = 0` and returns to the primary round.
  3. **Stamp the footer** — on `consecutive_clean = 1` primary-clean **plus** the sub-agent `CONFIRMED`, append the exact **two-line footer block** to `ticket.md`:

       ```text
       ---
       Validated {YYYY-MM-DD} — N rounds, 1 adversarial sub-agent confirmed
       ```

       (The `---` delimiter is part of the footer, not optional. This matches `/validate-artifact` Step 8 verbatim.)

  The command body specifies this by **reference to `/validate-artifact`** (Steps 1–8) for the loop mechanics and **names the `ticket.md` footer** as the stamped output — it does not re-enumerate the dimensions or re-implement the checker.

  ### Step 7b — Refresh the epic STATUS.md

  After the inline validation loop stamps the `Validated …` footer (Step 7), **re-derive the parent epic's `STATUS.md` from disk** per [`commands/po-status.md`](po-status.md) (resolve the epic from the story's folder path) — this story now shows as `Validated`. Re-derive the **whole table** (never patch a cell); the rollup is a derived VIEW per [`reference/epic_status_board.md`](../../../../reference/epic_status_board.md). In parent-slug batch mode, refresh once per child after that child's footer is stamped.

  ```
  **Replace with:** (nothing — the block is removed; Step 8 immediately follows Step 6's content)

- **DELETE — `## Mode A note (draft ingestion)` standalone section (dangling Step-7 references).**
  **Justification:** This section (between the Parent-slug batch mode section and the Notes) references Step 7 ("the footer-stamping step (Step 7, item 3)") and the inline validation loop ("before entering the inline validation loop (Step 7)") — both of which no longer exist after the Step 7/7b deletion above. The Mode A ingestion mechanics are already fully specified at Mode A Step 4 item 4 and the Step 6 Mode A note; this duplicate section becomes dead weight with dangling references.
  **Locate (delete this entire block):**
  ```
  ## Mode A note (draft ingestion)

  When Mode A is detected (Step 2, draft marker + Scratch Notes present), the command's Step 6 exit and the footer-stamping step (Step 7, item 3) both happen. After the dialog drains `## Open Questions` (Step 6) **and before** entering the inline validation loop (Step 7), **strip the marker + Scratch Notes**. This is the f1-style ingestion: the draft overlay is a temporary staging vehicle for intake, removed once the story is defined (the same pattern `/f1-propose-update` uses to ingest `/f0-draft-proposal` drafts, but applied here to story-altitude ingestion).
  ```
  **Replace with:** (nothing — the section is removed entirely)

- **EDIT — Step 8 exit: ticket is "defined" not "defined and validated"; next is `/ps2-validate`.**
  **Locate:**
  ```
  ### Step 8 — Exit

  On successful inline validation (footer stamped), suggest the next command:

  ```text
  Story ticket {slug} is defined and validated.
  Next: /e1-start-story {slug} (stub-aware) to proceed to engineering intake.
  ```

  The `/e1-start-story` ready-ticket pickup branch keys on the `Validated …` footer's presence.
  ```
  **Replace:**
  ```
  ### Step 8 — Exit

  On completion of the open-questions dialog (ticket defined, `## Open Questions` drained), suggest the next command:

  ```text
  Story ticket {slug} is defined (not yet validated).
  Next: /ps2-validate {slug} to run the validation loop and stamp the Validated footer.
  ```

  Validation is the dedicated `/ps2-validate` stage; the `Validated …` footer it stamps is what `/e1-start-story`'s ready-ticket pickup branch keys on.
  ```

- **EDIT — `## Parent-slug batch mode (feature → all stories)` intro: drop "including its inline Pattern-1 validation loop / footer stamp (Step 7)".**
  **Locate:** `The command then runs its own single-story define logic — **including its inline Pattern-1 validation loop / footer stamp (Step 7)** — across every story under that feature, sequentially. This is **horizontal sibling fan-out at one altitude** — it defines + validates each story; it does **not** chain into any other altitude's command.`
  **Replace:** `The command then runs its own single-story define logic across every story under that feature, sequentially. This is **horizontal sibling fan-out at one altitude** — it defines each story; it does **not** validate them (that stays `/ps2-validate`) and does **not** chain into any other altitude's command.`

- **EDIT — batch-mode empty-parent message decompose-name rename (`pf2-decompose` → `pf3-decompose`).**
  **Locate:** `report `parent {slug} has no children to process — run the decompose phase (/pf2-decompose {slug}) first``
  **Replace:** `report `parent {slug} has no children to process — run the decompose phase (/pf3-decompose {slug}) first``

- **EDIT — batch-mode step 2: skip signal becomes "already-defined" not "already-validated footer present".**
  **Locate:** `2. **Skip-already-validated-with-notice (resumability).** For each story in worklist order, first check whether it is already defined + validated — its `ticket.md` carries a `Validated …` footer (the single-slug completion signal this command stamps). If so, emit a one-line notice (`skipping {story-slug} — already validated`) and move to the next child. This makes re-invocation resumable: a batch interrupted partway resumes at the first incomplete child without re-prompting completed ones.`
  **Replace:** `2. **Skip-already-defined-with-notice (resumability).** For each story in worklist order, first check whether it is already defined — its `ticket.md` body intake area + spec structure are drafted and its `## Open Questions` is drained (the single-slug completion signal this command produces; `/ps1-define` no longer stamps a footer). If so, emit a one-line notice (`skipping {story-slug} — already defined`) and move to the next child. This makes re-invocation resumable: a batch interrupted partway resumes at the first incomplete child without re-prompting completed ones.`

- **EDIT — batch-mode step 3: drop "and the inline Pattern-1 validation loop (Step 7) that stamps the child's footer".**
  **Locate:** `3. **Per-child execution.** For each not-yet-validated story, run this command's **single-story** Step-by-step verbatim on that story's slug — including the full per-child open-questions iterative dialog (Step 6), one question at a time per Principle 2, **and the inline Pattern-1 validation loop (Step 7) that stamps the child's `Validated …` footer**. Each child runs its **own complete dialog and validation before the next child starts**; never bulk-bomb the union of all children's questions across the batch.`
  **Replace:** `3. **Per-child execution.** For each not-yet-defined story, run this command's **single-story** Step-by-step verbatim on that story's slug — including the full per-child open-questions iterative dialog (Step 6), one question at a time per Principle 2. Each child runs its **own complete dialog before the next child starts**; never bulk-bomb the union of all children's questions across the batch. (Validation is the separate `/ps2-validate {feature-slug}` batch — run it after this define batch completes.)`

- **EDIT — batch-mode step 4: drop "or validation loop".**
  **Locate:** `4. **Halt-at-child on an unresolvable outcome.** If any child hits a condition it cannot resolve (slug collision, ambiguous resolution, a dialog or validation loop that cannot converge), **stop the batch at that child** and surface its report verbatim. The user fixes it and re-invokes; resumability (step 2) resumes at that child without re-prompting the children already validated ahead of it.`
  **Replace:** `4. **Halt-at-child on an unresolvable outcome.** If any child hits a condition it cannot resolve (slug collision, ambiguous resolution, a dialog that cannot converge), **stop the batch at that child** and surface its report verbatim. The user fixes it and re-invokes; resumability (step 2) resumes at that child without re-prompting the children already defined ahead of it.`

- **EDIT — batch-mode step 5: final summary outcomes + next suggestion repoint to `/ps2-validate`.**
  **Locate:** `5. **Final summary.** When the worklist is exhausted, report a one-line-per-child summary: each child slug and its outcome (`validated` / `skipped — already validated`), then the next-command suggestion (`/clear`, then `/e1-start-story {story-slug}` on each newly validated story to proceed to engineering intake).`
  **Replace:** `5. **Final summary.** When the worklist is exhausted, report a one-line-per-child summary: each child slug and its outcome (`defined` / `skipped — already defined`), then the next-command suggestion (`/clear`, then `/ps2-validate {feature-slug}` to validate all the newly defined stories).`

- **EDIT — Notes Principle-1 reconciliation: "dialog and inline validation" → "dialog" only.**
  **Locate:** `Passing a **feature** slug (the parent altitude) runs this command's single-story logic — dialog **and** inline validation — across every story under the feature (`## Parent-slug batch mode`). This is **horizontal sibling fan-out at one altitude** — it defines + validates each story and does **not** chain into any other altitude's command.`
  **Replace:** `Passing a **feature** slug (the parent altitude) runs this command's single-story define logic across every story under the feature (`## Parent-slug batch mode`). This is **horizontal sibling fan-out at one altitude** — it defines each story; it does **not** validate them (that stays `/ps2-validate`) and does **not** chain into any other altitude's command.`

- **EDIT — Notes Principle-1 reconciliation: skip check name.**
  **Locate:** `resumable by re-invocation via the skip-already-validated check, each child independently runnable via its own single slug) — not a state-holding mega-orchestrator.`
  (within the `/ps1-define` Notes paragraph)
  **Replace:** `resumable by re-invocation via the skip-already-defined check, each child independently runnable via its own single slug) — not a state-holding mega-orchestrator.`

**Verification:**
- `grep -c 'consecutive_clean' host/templates/claude/commands/ps1-define.md` returns 0 (inline loop removed).
- `grep -c '### Step 7 ' host/templates/claude/commands/ps1-define.md` returns 0 and `grep -c '### Step 7b' host/templates/claude/commands/ps1-define.md` returns 0.
- `grep -c 'po-status.md' host/templates/claude/commands/ps1-define.md` returns 0 (the STATUS.md hook moved out).
- `grep -F '/ps2-validate {slug}' host/templates/claude/commands/ps1-define.md` returns ≥1 (exit repointed).
- `grep -c 'pf2-decompose' host/templates/claude/commands/ps1-define.md` returns 0 (empty-parent message renamed).
- `grep -F 'skipping {story-slug} — already defined' host/templates/claude/commands/ps1-define.md` returns 1; `grep -c 'already validated' host/templates/claude/commands/ps1-define.md` returns 0.
- `grep -c '## Mode A note (draft ingestion)' host/templates/claude/commands/ps1-define.md` returns 0 (dangling Step-7 section removed).

---

## Step 4 — EDIT `commands/e1-start-story.md` (ready-ticket detection doc-reference repoint; row 16)

**Operation:** EDIT (doc-reference only — detection logic byte-unchanged)
**File:** `host/templates/claude/commands/e1-start-story.md`

The three-way stub detection (Step 2 / lines ~46–48) keys on the `Validated …` footer's *presence*. Only the parenthetical attribution of which command stamps it changes. **Do not touch the detection logic.**

- **EDIT — Step 2 "Detection is flagless" attribution.**
  **Locate:** `   - **Detection is flagless.** The three-way split keys solely on the resolved folder's nested parentage plus the presence/absence of the `Validated …` footer (stamped by `/ps1-define`'s inline validation loop): **no new command flag, no new template, no new status marker** — consistent with e1's existing flagless stub detection.`
  **Replace:** `   - **Detection is flagless.** The three-way split keys solely on the resolved folder's nested parentage plus the presence/absence of the `Validated …` footer (stamped by `/ps2-validate`, the story-altitude validate stage): **no new command flag, no new template, no new status marker** — consistent with e1's existing flagless stub detection.`

- **EDIT — Step 2 ready-ticket-pickup branch attribution (line ~46).**
  **Locate:** `   - **Ready-ticket pickup (PO-flow handoff, validated).** If the resolved nested `ticket.md` carries a Pattern-1 `Validated …` footer, this is a `/ps1-define`-validated planning ticket. Mark the invocation as **ready-ticket pickup**:`
  **Replace:** `   - **Ready-ticket pickup (PO-flow handoff, validated).** If the resolved nested `ticket.md` carries a Pattern-1 `Validated …` footer, this is a `/ps2-validate`-validated planning ticket. Mark the invocation as **ready-ticket pickup**:`

> NOTE — the `/pf2-decompose` references elsewhere in this file (Step 2 bare-stub branch, Step 4 stub-aware merge, Notes stub-handoff) are the **sweep** (row 20n), handled in **Phase 4 Step 14** — a dedicated `e1-start-story.md` sweep step (NOT Phase 4 Step 3, which targets `e8-finalize-story.md`) — not here. This step touches only the two `/ps1-define` attributions.

**Verification:**
- `grep -c '/ps1-define' host/templates/claude/commands/e1-start-story.md` returns 0 (both attributions repointed).
- `grep -F '/ps2-validate' host/templates/claude/commands/e1-start-story.md` returns ≥2.
- The footer-presence detection wording ("keys solely on … the presence/absence of the `Validated …` footer") is unchanged except the parenthetical — confirm by reading the two edited lines.

---

## Step 5 — EDIT `README.md` (PO-flow tables: insert `-validate` rows, renumber, batch note; row 17)

**Operation:** EDIT
**File:** `README.md`

- **EDIT — ASCII altitude grid: add `-validate` to each altitude's command list and rename decompose/finalize.**
  **Locate:**
  ```
              Epic                       <-- /pe0-draft, /pe1-define, /pe2-decompose, /pe3-finalize
               |
               v   (N features per epic, stub-list pattern)
            Feature                      <-- /pf0-draft, /pf1-define, /pf2-decompose
               |
               v   (N stories per feature, stub-list pattern)
             Story                       <-- /ps0-draft, /ps1-define, then /e1-start-story (stub-aware) → Engineer flow
  ```
  **Replace:**
  ```
              Epic                       <-- /pe0-draft, /pe1-define, /pe2-validate, /pe3-decompose, /pe4-finalize
               |
               v   (N features per epic, stub-list pattern)
            Feature                      <-- /pf0-draft, /pf1-define, /pf2-validate, /pf3-decompose
               |
               v   (N stories per feature, stub-list pattern)
             Story                       <-- /ps0-draft, /ps1-define, /ps2-validate, then /e1-start-story (stub-aware) → Engineer flow
  ```

- **EDIT — intro stage-grid paragraph: add the `2-validate` stage and renumber.**
  **Locate:** `Commands form an **altitude × stage grid** — prefix by altitude (`pe` = epic, `pf` = feature, `ps` = story), number by stage (`0-draft`, `1-define`, `2-decompose`, `3-finalize`). `draft` is an f0-style single-stub / idea capture runnable any time (the incremental-add path); `define` fleshes it out via the open-questions dialog; `decompose` (epic + feature only) batch-creates the next altitude's stubs; `finalize` (epic only) is the terminal Epic-altitude command.`
  **Replace:** `Commands form an **altitude × stage grid** — prefix by altitude (`pe` = epic, `pf` = feature, `ps` = story), number by stage (`0-draft`, `1-define`, `2-validate`, `3-decompose`, `4-finalize`). `draft` is an f0-style single-stub / idea capture runnable any time (the incremental-add path); `define` fleshes it out via the open-questions dialog; `validate` runs the Pattern-1 validation loop and stamps the `Validated …` footer (a thin wrapper over `/validate-artifact`); `decompose` (epic + feature only) batch-creates the next altitude's stubs; `finalize` (epic only) is the terminal Epic-altitude command.`

- **EDIT — command table: replace the decompose/finalize rows + insert the three `-validate` rows + update the `/ps1-define` row (drop "+ inline Pattern-1 validation").**
  **Locate:**
  ```
  | `/pe2-decompose {slug}` | Epic stage-2 → feature stubs | shipped |
  | `/pe3-finalize {slug}` | Epic stage-3 finalize → `epics/archive/` | shipped |
  | `/pf0-draft {epic-slug}` | Feature stage-0 draft (one stub under an epic) | shipped |
  | `/pf1-define {slug}` | Feature stage-1 define (intake/flesh-out; a **parent epic slug** defines all its features) | shipped |
  | `/pf2-decompose {slug}` | Feature stage-2 → story stubs (a **parent epic slug** decomposes all its features) | shipped |
  | `/ps0-draft {feature-slug \| bugs \| quick-wins}` | Story stage-0 draft (one stub; absorbs the old tech-story fast path) | shipped |
  | `/ps1-define {slug}` | Story stage-1 define (flesh-out **+ inline Pattern-1 validation** → engineer-ready ticket; a **parent feature slug** defines all its stories) | shipped |
  ```
  **Replace:**
  ```
  | `/pe2-validate {slug}` | Epic stage-2 validate → stamps the `Validated …` footer (single mode only) | shipped |
  | `/pe3-decompose {slug}` | Epic stage-3 → feature stubs | shipped |
  | `/pe4-finalize {slug}` | Epic stage-4 finalize → `epics/archive/` | shipped |
  | `/pf0-draft {epic-slug}` | Feature stage-0 draft (one stub under an epic) | shipped |
  | `/pf1-define {slug}` | Feature stage-1 define (intake/flesh-out; a **parent epic slug** defines all its features) | shipped |
  | `/pf2-validate {slug}` | Feature stage-2 validate → stamps the footer (a **parent epic slug** validates all its features) | shipped |
  | `/pf3-decompose {slug}` | Feature stage-3 → story stubs (a **parent epic slug** decomposes all its features) | shipped |
  | `/ps0-draft {feature-slug \| bugs \| quick-wins}` | Story stage-0 draft (one stub; absorbs the old tech-story fast path) | shipped |
  | `/ps1-define {slug}` | Story stage-1 define (flesh-out → engineer-ready ticket; a **parent feature slug** defines all its stories) | shipped |
  | `/ps2-validate {slug}` | Story stage-2 validate → stamps the footer `/e1-start-story` keys on (a **parent feature slug** validates all its stories) | shipped |
  ```

- **EDIT — Parent-slug batch-mode note: add `/pf2-validate` + `/ps2-validate` and rename `/pf2-decompose`.**
  **Locate:** `> **Parent-slug batch mode.** `/pf1-define`, `/ps1-define`, and `/pf2-decompose` also accept a **parent** slug — one altitude up from their own (`/pf1-define {epic-slug}`, `/ps1-define {feature-slug}`, `/pf2-decompose {epic-slug}`). Given a parent slug, the command runs its single-artifact phase across **all children** of that parent, sequentially:`
  **Replace:** `> **Parent-slug batch mode.** `/pf1-define`, `/ps1-define`, `/pf3-decompose`, `/pf2-validate`, and `/ps2-validate` also accept a **parent** slug — one altitude up from their own (`/pf1-define {epic-slug}`, `/ps1-define {feature-slug}`, `/pf3-decompose {epic-slug}`, `/pf2-validate {epic-slug}` validates every feature under the epic, `/ps2-validate {feature-slug}` validates every story under the feature). Given a parent slug, the command runs its single-artifact phase across **all children** of that parent, sequentially:`

- **EDIT — folder-layout comment: rename `/pe3-finalize`.**
  **Locate:** `    └── archive/{ID}-{epic-slug}-{brief}/        # finalized epics (/pe3-finalize); excluded from active-epic resolution`
  **Replace:** `    └── archive/{ID}-{epic-slug}-{brief}/        # finalized epics (/pe4-finalize); excluded from active-epic resolution`

- **EDIT — STATUS.md prose: rename the transition-command list (`/pe2`, `/pf2`, `/ps1`, `/e4`, `/e8`) to reflect the validate stage now producing New→Validated.**
  **Locate:** `re-computed from on-disk signals by `/po-status {epic-slug}` and the transition commands (`/pe2`, `/pf2`, `/ps1`, `/e4`, `/e8`); never hand-edited.`
  **Replace:** `re-computed from on-disk signals by `/po-status {epic-slug}` and the transition commands (`/pe3-decompose`, `/pf3-decompose`, the `-validate` stage `/pe2-validate` / `/pf2-validate` / `/ps2-validate`, `/e4`, `/e8`); never hand-edited.`

- **EDIT — `/pf2-decompose` references in the individually-testable-rubric section.**
  **Locate:** `` `/pf2-decompose` enforces this on every story stub it writes: ``
  **Replace:** `` `/pf3-decompose` enforces this on every story stub it writes: ``
  AND
  **Locate:** `the decomposition exit gate catches violations before stubs land on disk. See the `/pf2-decompose` command body for the full rubric and inline enforcement details.`
  **Replace:** `the decomposition exit gate catches violations before stubs land on disk. See the `/pf3-decompose` command body for the full rubric and inline enforcement details.`

**Verification:**
- `grep -c 'pe2-decompose\|pe3-finalize\|pf2-decompose' README.md` returns 0.
- `grep -F '/pe2-validate {slug}' README.md`, `grep -F '/pf2-validate {slug}' README.md`, `grep -F '/ps2-validate {slug}' README.md` each return ≥1.
- `grep -F '/pe4-finalize' README.md` returns ≥1; `grep -F '/pe3-decompose {slug}' README.md` and `grep -F '/pf3-decompose {slug}' README.md` each return ≥1.
- `grep -c 'inline Pattern-1 validation' README.md` returns 0 (the `/ps1-define` row clause dropped).

---

## Step 6 — EDIT `reference/epic_status_board.md` (rename refs + New→Validated transition source; row 18)

**Operation:** EDIT
**File:** `reference/epic_status_board.md`

- **EDIT — Auto-refresh hooks line: rename the decompose commands AND repoint the New→Validated producer from `/ps1-define` to the `-validate` stage.**
  **Locate:**
  ```
  - **Auto-refresh hooks** — five transition commands re-derive the parent epic's `STATUS.md` after their own work, so the rollup stays live: `/pe2-decompose` (new features → New), `/pf2-decompose` (new stories → New), `/ps1-define` (story → Validated), `/e4-execute-plan` (story → Building), `/e8-finalize-story` (story → Released; feature rollup recomputed).
  ```
  **Replace:**
  ```
  - **Auto-refresh hooks** — transition commands re-derive the parent epic's `STATUS.md` after their own work, so the rollup stays live: `/pe3-decompose` (new features → New), `/pf3-decompose` (new stories → New), the `-validate` stage `/pe2-validate` / `/pf2-validate` / `/ps2-validate` (epic / feature / story → Validated), `/e4-execute-plan` (story → Building), `/e8-finalize-story` (story → Released; feature rollup recomputed).
  ```
  > NOTE — the count word "five" is replaced with "transition commands" (no count) because the New→Validated transition is now produced by three `-validate` commands rather than one `/ps1-define`. This keeps D10 count-accuracy honest without committing to a brittle number.

> The footer-presence derivation rule itself (the New/Validated/Building/Released state-mapping rules earlier in the file) is **unchanged** — only the command attribution in the auto-refresh-hooks bullet changes. Do not touch the state-mapping rules.

**Verification:**
- `grep -c 'pe2-decompose\|pf2-decompose' reference/epic_status_board.md` returns 0.
- `grep -F '/pe2-validate' reference/epic_status_board.md` returns ≥1; `grep -F '/ps2-validate' reference/epic_status_board.md` returns ≥1.
- `grep -F '/pe3-decompose' reference/epic_status_board.md` returns ≥1; `grep -F '/pf3-decompose' reference/epic_status_board.md` returns ≥1.

---

## Step 7 — EDIT `reference/model_selection.md` (renumber + add `-validate` rows + revise `/ps1-define` row; row 19)

**Operation:** EDIT
**File:** `reference/model_selection.md`

- **EDIT — `/pe3-finalize` row rename (the finalize command).**
  **Locate:** `| PO — Epic finalize (`/pe3-finalize`) | Cheap | Mechanical: children-done guard, tracker close, `epic.md` status flip, folder move into `epics/archive/`, commit |`
  **Replace:** `| PO — Epic finalize (`/pe4-finalize`) | Cheap | Mechanical: children-done guard, tracker close, `epic.md` status flip, folder move into `epics/archive/`, commit |`

- **EDIT — `/pe2-decompose` row rename.**
  **Locate:** `| PO — Epic decompose (`/pe2-decompose`) | Balanced | Stub-list-then-drill-in batch decomposition into feature stubs; parallelization analysis; re-decomposition partition |`
  **Replace:** `| PO — Epic decompose (`/pe3-decompose`) | Balanced | Stub-list-then-drill-in batch decomposition into feature stubs; parallelization analysis; re-decomposition partition |`

- **EDIT — `/pf2-decompose` row rename.**
  **Locate:** `| PO — Feature decompose (`/pf2-decompose`) | Balanced | Stub-list-then-drill-in batch decomposition into story stubs; individually-testable rubric; parallelization analysis |`
  **Replace:** `| PO — Feature decompose (`/pf3-decompose`) | Balanced | Stub-list-then-drill-in batch decomposition into story stubs; individually-testable rubric; parallelization analysis |`

- **EDIT — REVISE the `/ps1-define` row: drop the inline-validation-loop clause and re-tier to Balanced (matching `/pe1-define` / `/pf1-define`).**
  **Locate:** `| PO — Story define (`/ps1-define`) | Reasoning | Open-questions dialog **plus** an inline Pattern-1 validation loop producing the engineer-ready planning ticket (mirrors the story-altitude design+validation tiers) |`
  **Replace:** `| PO — Story define (`/ps1-define`) | Balanced | Open-questions dialog producing the engineer-ready planning ticket — a pure define/dialog stage (validation moved to the `-validate` stage); consistent with `/pe1-define` / `/pf1-define` |`

- **EDIT — ADD three `-validate` rows at the validation tier, immediately after the `/ps0-draft` row (keeping the PO block contiguous).**
  **Locate (anchor — the `/ps1-define` row just revised, which sits after `/ps0-draft`):**
  ```
  | PO — Story define (`/ps1-define`) | Balanced | Open-questions dialog producing the engineer-ready planning ticket — a pure define/dialog stage (validation moved to the `-validate` stage); consistent with `/pe1-define` / `/pf1-define` |
  ```
  **Replace (append the three new rows directly below it):**
  ```
  | PO — Story define (`/ps1-define`) | Balanced | Open-questions dialog producing the engineer-ready planning ticket — a pure define/dialog stage (validation moved to the `-validate` stage); consistent with `/pe1-define` / `/pf1-define` |
  | PO — Epic validate (`/pe2-validate`) | Reasoning | Thin wrapper over the `/validate-artifact` Pattern-1 loop on `epic.md`; the loop escalates to Reasoning (primary) with a Cheap `validation-checker` sub-agent, per the `/validate-artifact` row. Single mode only |
  | PO — Feature validate (`/pf2-validate`) | Reasoning | Thin wrapper over `/validate-artifact` on `feature.md`; same loop tiering as the `/validate-artifact` row; a parent epic slug batch-validates all features (stateless disk-derived dispatcher) |
  | PO — Story validate (`/ps2-validate`) | Reasoning | Thin wrapper over `/validate-artifact` on `ticket.md` (the inline loop moved out of `/ps1-define`); same loop tiering; a parent feature slug batch-validates all stories |
  ```

**Verification:**
- `grep -c 'pe2-decompose\|pf2-decompose\|pe3-finalize' reference/model_selection.md` returns 0.
- `grep -F 'PO — Epic validate (`/pe2-validate`)' reference/model_selection.md` returns 1; same for `/pf2-validate` and `/ps2-validate`.
- `grep -F 'PO — Story define (`/ps1-define`) | Balanced' reference/model_selection.md` returns 1 (re-tiered).
- `grep -c 'inline Pattern-1 validation loop' reference/model_selection.md` returns 0 (the `/ps1-define` clause dropped).
- `grep -F '`/pe4-finalize`' reference/model_selection.md`, `grep -F '`/pe3-decompose`' reference/model_selection.md`, `grep -F '`/pf3-decompose`' reference/model_selection.md` each return 1.

---
Validated 2026-06-19 — 3 rounds, 1 adversarial sub-agent confirmed
