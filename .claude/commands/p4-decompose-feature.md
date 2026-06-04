---
description: Phase 4 of the PO flow — break a validated feature into N story-ticket stubs via the stub-list-then-drill-in pattern, gating the whole list once, enforcing the individually-testable rubric, and recording parallelization analysis on the parent feature
---

# /p4-decompose-feature

**Purpose:** Run Phase 4 of the PO flow. Read a validated `feature.md`, propose a list of stories (title + one-line scope each), enforce the **individually-testable rubric**, gate the whole list with the user once, derive story slugs, run the decomposition exit gate, then write N story-ticket-stub folders under `stories/` (each carrying `**Parent Feature:**` and `**Parent Epic:**` back-ref headers + scope one-liner) and append `Target Stories` + `Sequencing & Parallelization` back onto the parent feature. Per-story deep dialog is deferred to `/e1-start-story` (stub-aware).

**Recommended model:** Reasoning (Opus). Decomposition involves the individually-testable rubric, dependency analysis, parallelization callout, and global-slug discipline — all benefit from Opus's reasoning depth. Same justification as `/p2-decompose-epic`. See [`reference/model_selection.md`](../../../../reference/model_selection.md).

---

## Usage

```
/p4-decompose-feature {slug} [--allow-unvalidated]
```

## Arguments

- `{slug}` (required) — feature slug. Resolved against `features/`.
- `--allow-unvalidated` (optional, discouraged) — proceed even if `feature.md` carries no `Validated …` footer. Use only when the PO explicitly wants to decompose a draft to test the breakdown shape; rerun `/validate-artifact` afterwards. Same semantics as `/p2-decompose-epic`'s flag of the same name.

## Prerequisites

- `features/{slug}-*/feature.md` must exist. If not, halt and direct the user to `/p3-start-feature {slug}` first.
- `feature.md` should carry a `Validated …` footer. If it does not, halt with a clear message and direct the user to `/validate-artifact features/{slug}-*/feature.md` — unless `--allow-unvalidated` is passed.

## Step-by-step

### Step 1 — Resolve the slug to a feature folder

Apply the global slug-resolution rule from [`SHAMT_RULES.template.md`](../../../../templates/SHAMT_RULES.template.md) (Principle 1):

1. Try `features/{slug}/feature.md` (exact match).
2. If not found, glob `features/{slug}-*/feature.md`.
3. **Multiple matches** → halt; ask the user which folder to use.
4. **One match** → that folder is the feature folder.
5. **Zero matches** → halt; direct the user to `/p3-start-feature {slug}`.

### Step 2 — Check the validation footer

1. Read the last non-blank line of `feature.md`.
2. If it matches `Validated YYYY-MM-DD — …`, proceed to Step 3.
3. Otherwise, **halt** with: `feature.md is not validated — run /validate-artifact features/{slug}-{brief}/feature.md first, or re-invoke with --allow-unvalidated to proceed against the draft.`
4. If `--allow-unvalidated` was passed, surface a one-line notice (`proceeding against an unvalidated feature — re-run /validate-artifact after decomposition`) and continue.

### Step 3 — Re-entry detection

Read the parent feature. If a `Decomposed YYYY-MM-DD — N story stubs at stories/{slug-1}, stories/{slug-2}, …` line is already present (immediately above the validation footer), treat this as a **re-decomposition** invocation:

1. Read the prior list of story stubs from the existing line.
2. Tell the user: "this feature has already been decomposed into N stories — proceeding will replace the prior list."
3. Confirm before continuing. The re-decomposition rule in Step 9 governs what happens to the prior `Target Stories` + `Sequencing & Parallelization` sections and to any orphaned stubs.
4. Once Step 5 produces an approved new story list, **partition it against the prior list** by `{story-slug}` (the slug portion only — the `{brief}` suffix is allowed to drift):
   - **Kept** — the new slug matches a slug in the prior `Decomposed …` line. The existing stub folder is reused as-is (Step 8); the collision check is exempt (Step 7); only the parent feature's `Target Stories` / `Sequencing & Parallelization` sections are rewritten to reflect the new list (Step 9). Kept stories may have user work in progress that must be preserved.
   - **New** — the slug does not match the prior list. A fresh stub is written (Step 8); the collision check applies normally (Step 7).
   - **Orphaned** — a slug in the prior list does not appear in the new list. The folder is left in place; Step 9 surfaces a warning.

On first decomposition (no prior `Decomposed …` line), every approved story is **New**; the partition concepts above are inert. Same partition rule as `/p2-decompose-epic` Step 3.

### Step 4 — Read the feature and propose the story list

1. Read `feature.md`: `Goal`, `Success Criteria`, `Scope / Non-Scope` (including any `**Architecture impact:** …` line), `**Parent Epic:**` back-ref header (if present — needed for the back-ref headers in Step 8), and (when present) the **All Remaining Fields** appendix.
2. Draft a proposed story list. Each entry: **title** + **one-line scope**. Capture the list as a flat enumerated proposal — no nested sub-stories, no per-story deep dialog (that is `/e1-start-story`'s job).
3. **Enforce the individually-testable rubric** — **the rubric, in full:**

   > A story is **individually testable** when it carries a self-contained verification path (automated or manual) that exercises its own contribution without re-verifying any sibling story's success criterion.
   >
   > - "Verification path" can be a unit test, an integration test, a manual checklist step from a `manual_test_plan.md`, or any other observable check the engineer can run to confirm the story's scope.
   > - "Self-contained" means the check does not require a sibling story's code to be present to *pass*. It may require a sibling's code to be present to *run* (development-order dependency) — that is fine; see the rubric exception below.
   > - "Without re-verifying any sibling's success criterion" means the story's check is targeted at its own contribution. A check that, to fail, requires *another* story's bug is not self-contained.
   >
   > **Rubric exception — development-order dependencies are allowed.** Story B can use an interface defined by Story A, so B cannot be built first. That's a sequencing fact, recorded in the parallelization analysis (sub-step 4 below) — **not** a testability violation. The rubric tests testability, not buildability. Do not reject candidate stories that have sibling dependencies on the build axis.

   For each candidate story, walk the rubric: does the story have a self-contained verification path? If yes, mark it acceptable. If no, the candidate fails the rubric — surface the gap to the user and either:
   - **Decompose further** — split the candidate into two stories where the testability gap lives in a new sibling that owns the verification path.
   - **Expand scope** — fold the missing verification path into the candidate's scope so the story owns its own check.

   **Do not write a stub that violates the rubric.** Iterate with the user in Step 5 until every candidate passes the rubric or is dropped from the list.

4. For each entry that passes the rubric, derive:
   - `{story-slug}` — kebab-case from the title. Form depends on the active tracker (read `work_item_tracker` from `.shamt-core/shamt-config.json`):
     - **ado / github** — descriptive kebab-case is allowed at the stub stage (the engineer can rename to the tracker-native form during `/e1-start-story` if a ticket is later filed). The PO flow does not create tracker work items.
     - **local / none** — any descriptive kebab-case slug.
   - `{brief}` suffix — kebab-case from the scope one-liner. Keep `{brief}` short — 2–4 words.
   - **Re-decomposition Kept exception:** if a prior `Decomposed …` line is present (Step 3) and the derived `{story-slug}` matches one of its entries, **do not** re-derive `{brief}`. Resolve the existing folder via `stories/{story-slug}-*/` glob (slugs are globally unique; the prior line records slugs only, so the actual `{brief}` is read off the existing folder name) and reuse that folder verbatim. Same Kept-exception rule as `/p2-decompose-epic`.

5. Draft the **parallelization analysis**:
   - **Recommended order** — sequenced enumeration of stories by dependency; for each, a one-line "why this comes first; dependencies" note. Development-order dependencies between siblings (rubric exception above) live here.
   - **Parallelizable** — which stories can be worked concurrently and why, or `None — strictly sequential.`

### Step 5 — Gate the whole batch with the user (once)

Per the stub-list pattern, the user gates **the entire list at once** — not per-story.

Present, in chat:

1. The proposed story list (each entry: title, one-line scope, derived `{story-slug}-{brief}` folder name).
2. The individually-testable rubric verdict per candidate (passes / fails, with the rationale when a candidate fails).
3. The parallelization analysis (recommended order + parallelizable callout).

Surface global scoping questions about the list **as a whole** via `AskUserQuestion` per [`SHAMT_RULES.template.md`](../../../../templates/SHAMT_RULES.template.md) Principle 2 (open-questions iterative dialog). Examples of legitimate questions at this altitude: "Should X be its own story or absorbed into Y?", "Does the ordering reflect the hard dependency I mentioned in Goal?", "Is the proposed verification path for story Z actually self-contained, or does it lean on story Y's success criterion?", "Can A and B really be worked concurrently, given they touch the same module?"

Iterate with the user until they approve: they may add / remove / reword entries, adjust the derived slugs, fix testability gaps by expanding scope or splitting, or revise the parallelization analysis. Each iteration is a single batch — re-present the updated list + rubric verdicts + analysis together.

**Per-story deep dialog is deferred to `/e1-start-story` (stub-aware).** Do not start drafting per-story acceptance criteria, spec content, or implementation plans here — that is the Engineer flow's work per §2.1.

### Step 6 — Decomposition exit gate

Check **before** writing any stubs to disk. The gate is a **2-condition check** on the approved batch — distinct from `/validate-artifact`:

1. **Every story stub has an individually-testable scope one-liner** per the rubric in Step 4 sub-step 3. No blanks, no "TBD", no placeholder text, no rubric-failing candidates surviving into the approved list.
2. **Every story appears in the parent feature's `Sequencing & Parallelization` analysis** — either in the `Recommended order` enumeration, or in the `Parallelizable` callout, or both.

If either condition fails, surface the gap to the user and return to Step 5. Do not write stubs while the gate is failing.

### Step 7 — Detect global story-slug collisions

Story slug uniqueness is **global** (flat layout). Before writing:

1. **For stories in the New partition** (per Step 3 — and for all stories on first decomposition): glob `stories/{story-slug}-*/` and `stories/{story-slug}/`. If **any** candidate slug collides with an existing story folder, halt with: `story slug "{slug}" collides with existing story at stories/{existing-folder}/. Choose a different title, or rename the existing story.` Surface the conflict and let the user adjust the title (return to Step 5).
2. **Exemption — re-decomposition Kept partition.** A Kept slug (per Step 3) is expected to collide with its own prior stub folder under the current feature. That is not a collision in the gate sense — proceed without halting and reuse the existing folder in Step 8. Apply the exemption only when the colliding folder appears in the prior `Decomposed …` line of *this* feature; collisions against stories outside that prior list (e.g., a stub created by a different feature that happens to share the slug) are real and still halt.
3. Repeat until every New candidate is unique (modulo the Kept exemption above).

### Step 8 — Write the story-ticket stubs

For each approved story entry:

- **New partition (per Step 3) — and every story on first decomposition:** create `stories/{story-slug}-{brief}/ticket.md` from the active tracker's per-provider ticket template. **Template selection rule:** read `work_item_tracker` from `.shamt-core/shamt-config.json`:
  - `ado` → [`templates/ticket.ado.template.md`](../../../../templates/ticket.ado.template.md)
  - `github` → [`templates/ticket.github.template.md`](../../../../templates/ticket.github.template.md)
  - `local` or `none` → [`templates/ticket.github.template.md`](../../../../templates/ticket.github.template.md) as the **generic baseline** (GitHub-flavored sections are closer to the generic structural shape). **Replace the template's `**Tracker profile:** GitHub (see …)` metadata line with `**Tracker profile:** {local|none}` to match the active config** — leaving the static GitHub text would mislead a fresh agent reading the stub. The rest of the template body (Summary, Description, etc.) is generic-enough to carry over unchanged.

  Populate **only** these fields:
  - **Back-ref headers** under H1, in order:
    - `**Parent Feature:** {feature-slug}` — required for every stub written by this command.
    - `**Parent Epic:** {parent-epic-slug}` — populated from the parent feature's `**Parent Epic:**` header (read in Step 4 sub-step 1). **Omit the Parent Epic line entirely** when the parent feature is standalone (i.e., the feature's `**Parent Epic:**` header is blank or absent).
  - **Body section** (under the existing template's free-form intake area — the paragraph immediately after the back-ref headers and metadata block, marked by the template as "Paste ticket content here — any format accepted"): write the story's scope one-liner verbatim. The Spec phase extracts structure later.
  - Other template sections (Summary, Description, Acceptance Criteria, Related Work, Comments, Update History, All Remaining Fields, Open Questions, etc.) are **left empty / placeholder** as they appear in the template. This matches how a freeform `/e1-start-story` would leave them; `/e1-start-story` (stub-aware) fills them in later.
  - No `Validated …` footer — `/e1-start-story` and the subsequent Engineer-flow phases own validation at the story altitude.
- **Kept partition (re-decomposition only):** **do not touch** the existing `ticket.md`. The user (or `/e1-start-story`) may have already done in-progress work inside (spec drafting, plan, build artifacts under the same story folder). Preserve it untouched — Step 9 only rewrites the parent feature's references, not the story artifacts themselves. If the user-approved scope one-liner for a Kept story differs meaningfully from the current body of the existing `ticket.md`, surface a notice (`Kept story {story-slug}: existing ticket body differs from new scope one-liner — leaving existing ticket.md untouched; revise it via /e1-start-story {story-slug} if intended.`) and continue without editing.

### Step 9 — Append decomposition output to the parent feature

Update `feature.md`:

1. **Rewrite `## Target Stories` wholesale** with the approved list — one bullet per story: `` `{story-slug}` — {one-line scope} ``. If this is a re-decomposition (Step 3), replace the prior section's content entirely.
2. **Rewrite `## Sequencing & Parallelization` wholesale** with the approved analysis (recommended order + parallelizable callout). Same wholesale-replace rule on re-decomposition.
3. **Add (or replace) a `Decomposed YYYY-MM-DD — N story stubs at stories/{slug-1}, stories/{slug-2}, …` line** immediately **above** the `Validated …` footer, so the validation footer remains the last line of the file. Use today's date.
   - **Slug-only format.** Record the slug portion of each folder (`{story-slug}`), not the full `{story-slug}-{brief}` path. Slugs are globally unique, so the actual folder is always recoverable via `stories/{slug}-*/` glob — recording only the slug keeps the line parseable on re-decomposition (Step 3 reads slugs directly without having to split a slug-brief concatenation, which is ambiguous because both are kebab-case). Same format as `/p2-decompose-epic` Step 9.
   - On first decomposition: insert the line.
   - On re-decomposition: replace the prior `Decomposed …` line in place. Only the latest decomposition is recorded.
4. **Preserve the existing validation footer** as-is. The feature was validated before decomposition; decomposition does not re-invalidate it. Do not strip or duplicate the footer.

**Re-decomposition partition handling.** Per Step 3, the new list partitions against the prior `Decomposed …` line into Kept / New / Orphaned:

- **Kept** stories carry forward — their existing `ticket.md` (and any other artifacts under the story folder — `spec.md`, `implementation_plan.md`, `feedback/`, etc.) is preserved per Step 8. The new `Target Stories` and `Sequencing & Parallelization` sections reference them with the user-approved one-liner from Step 5 (which may differ from the existing body inside the Kept stub — see Step 8 notice).
- **New** stories got fresh stubs in Step 8.
- **Orphaned** stories (in the prior list but not the new list) are **not auto-deleted**. Surface a warning listing the orphaned story folders and ask the user to delete or repurpose them manually — auto-deletion risks silently destroying in-progress engineer work in those folders (spec, plan, code-review feedback, etc.).

```
Warning: re-decomposition orphaned the following story folders
(slug → folder; folders resolved via stories/{slug}-*/ glob):

  - payment-webhook-handler → stories/payment-webhook-handler-stripe-events/
  - dashboard-summary-card  → stories/dashboard-summary-card-billing/

These are NOT auto-deleted. Review each and either delete or repurpose manually.
```

The left column is the slug as it appeared in the prior `Decomposed …` line; the right column is the actual folder path on disk (the `{brief}` suffix is recovered via glob). The user sees both so they can navigate to the folder and recognize the slug they had in mind. Same format as `/p2-decompose-epic`'s orphan warning.

### Step 10 — Exit gate

Verify before exiting:

- [ ] N story-stub folders exist at `stories/{story-slug}-{brief}/` with `ticket.md` files.
- [ ] **New stubs** (per Step 3 partition; and every stub on first decomposition) carry `**Parent Feature:** {feature-slug}` and (when the parent feature has an epic) `**Parent Epic:** {parent-epic-slug}` back-ref headers under H1, plus the scope one-liner in the body. **Parent Epic is omitted** when the parent feature is standalone.
- [ ] **Kept stubs** (re-decomposition only) are preserved unchanged from before this invocation — any user / engineer work inside (Spec / Plan / Build / Review artifacts) survives untouched. The "other sections empty" rule does not apply to Kept stubs.
- [ ] Every stub's scope one-liner passes the individually-testable rubric (Step 4 sub-step 3) per the gate in Step 6.
- [ ] Parent feature's `## Target Stories` lists each stub with its one-liner.
- [ ] Parent feature's `## Sequencing & Parallelization` carries the approved analysis (recommended order + parallelizable callout).
- [ ] Parent feature has a `Decomposed YYYY-MM-DD — N story stubs at stories/{slug-1}, stories/{slug-2}, …` line immediately above the validation footer. **Slug-only format** — the actual folder paths (with their `{brief}` suffixes) are recoverable via `stories/{slug}-*/` glob, not embedded in the line. For Kept entries, the cited slug points to the existing preserved folder per Step 4 sub-step 4 Kept exception.
- [ ] Parent feature's existing `Validated …` footer is preserved as the last line.
- [ ] On re-decomposition: orphaned stubs (if any) surfaced as a warning, not auto-deleted.

If any item fails, return to the relevant step.

### Step 11 — Suggest the next commands

Surface, but do **not** auto-invoke:

```
/clear
/e1-start-story {story-slug-1}     # flesh out the first stub
/e1-start-story {story-slug-2}     # ...and so on
```

Each story stub is **independently resumable**. The engineer can drive `/e1-start-story` on each stub in sequence, or run them in parallel by opening additional terminal tabs (the framework provides no runtime coordination machinery per §2.3). Order is suggested by the `Recommended order` line just written to the feature. `/e1-start-story` is **stub-aware** — it detects the back-ref headers in `ticket.md` and preserves them when fleshing out the rest of the Intake content (see `commands/e1-start-story.md`).

## Exit criteria

- N story-stub folders exist at `stories/{story-slug}-{brief}/ticket.md`. **New** stubs (and every stub on first decomposition) carry `**Parent Feature:** {feature-slug}` (always) and `**Parent Epic:** {parent-epic-slug}` (when the parent feature has an epic) back-ref headers + scope one-liner in the body with every other template section empty. **Kept** stubs (re-decomposition) are preserved unchanged from before this invocation.
- Every stub's scope one-liner passes the individually-testable rubric per Step 4 sub-step 3.
- The parent feature's `Target Stories` and `Sequencing & Parallelization` sections carry the approved list and analysis.
- The parent feature has a slug-only `Decomposed YYYY-MM-DD — N story stubs at stories/{slug-1}, stories/{slug-2}, …` line directly above the preserved `Validated …` footer; actual folders are recoverable via `stories/{slug}-*/` glob. For Kept entries, the cited slug points to the preserved existing folder.
- The user has approved the list (gated once, with rubric verdicts surfaced) and confirmed any derived-slug overrides.

## Notes

- **Fresh-agent runnable.** Every input lives on disk (`feature.md`, the active tracker's ticket template, the existing `stories/` tree, `.shamt-core/shamt-config.json`). No conversation history required.
- **Decomposition exit gate ≠ `/validate-artifact`.** The gate in Step 6 is a 2-condition stub-batch check run **before** stubs are written; `/validate-artifact` is the full Pattern 1 loop that runs against `feature.md` (already, before `/p4-decompose-feature`) and against each story-level artifact (later, after `/e2-define-spec`, `/e3-plan-implementation`, etc. — Engineer-flow validations). Do not conflate the two.
- **The individually-testable rubric is the hard constraint** on output. The Engineer flow can refuse a story that violates this; PO-flow enforcement at decomposition time is the contract. The rubric is reproduced in full inline in Step 4 sub-step 3 — not just by reference — so a fresh agent reading this command can apply it without external lookup.
- **Development-order dependencies between siblings are allowed.** They live in the parallelization analysis (`Recommended order`) and are not testability violations. Do not reject candidate stories that have sibling build-order dependencies.
- **No tracker fetch at this altitude.** This command operates entirely on the already-written `feature.md`. The §1.11 freeform-fallback rule does not apply at this altitude — there is no tracker payload to fall through from. The active tracker is read only to pick the **ticket template** for the stub bodies (Step 8 — `ado` vs. `github` vs. baseline).
- **No per-story deep dialog here.** That is `/e1-start-story` (stub-aware)'s job per §2.1 stub-list-then-drill-in. Resist the urge to start drafting story acceptance criteria, spec sections, or implementation plans — it produces low-value batched dialog at this altitude and pre-empts the open-questions iterative dialog at the next altitude.
- **No feature-level review phase.** Per §2.1, the 16-category code-review framework stays story-level. This command does not invoke `/e6-review-changes`.
- **No `/e1-start-story` auto-invocation.** Per Principle 1, every command stays independently runnable. Chaining would force a multi-phase session and would couple resumability across altitudes.
- **Parallelization is PO-flow output, not runtime coordination.** The `Parallelizable` callout informs the engineer; running stories concurrently is a "second terminal tab" exercise.
- **Parent Epic back-ref propagation.** Step 8 reads the parent feature's `**Parent Epic:** {epic-slug}` header and copies it onto each new story stub. When the parent feature is standalone (no parent epic), the `**Parent Epic:**` line is **omitted** from the stub — not written as blank — so the back-ref headers remain grep-clean.

---
<!-- Managed by Shamt — do not edit. Regenerate from shamt-core/host/templates/claude/commands/p4-decompose-feature.md. -->
