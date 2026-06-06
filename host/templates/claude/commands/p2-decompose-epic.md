---
description: Phase 2 of the PO flow — break a validated epic into N feature stubs via the stub-list-then-drill-in pattern, gating the whole list once and recording parallelization analysis on the parent epic
---

# /p2-decompose-epic

**Purpose:** Run Phase 2 of the PO flow. Read a validated `epic.md`, propose a list of features (title + one-line goal each), gate the whole list with the user once, derive feature slugs, run the decomposition exit gate, then write N feature-stub folders under `features/` and append `Target Features` + `Sequencing & Parallelization` back onto the parent epic. Per-feature deep dialog is deferred to `/p3-start-feature`.

**Recommended model:** Reasoning (Opus). Decomposition is the highest-value design work in the PO flow — dependency analysis, parallelization callout, and global-slug discipline benefit from Opus's reasoning depth. See [`reference/model_selection.md`](../../../../reference/model_selection.md).

---

## Usage

```
/p2-decompose-epic {slug} [--allow-unvalidated]
```

## Arguments

- `{slug}` (required) — epic slug. Resolved against `epics/`.
- `--allow-unvalidated` (optional, discouraged) — proceed even if `epic.md` carries no `Validated …` footer. Use only when the PO explicitly wants to decompose a draft to test the breakdown shape; rerun `/validate-artifact` afterwards. The recommended path is to validate first.

## Prerequisites

- `epics/{slug}-*/epic.md` must exist. If not, halt and direct the user to `/p1-start-epic {slug}` first.
- `epic.md` should carry a `Validated …` footer. If it does not, halt with a clear message and direct the user to `/validate-artifact epics/{slug}-*/epic.md` — unless `--allow-unvalidated` is passed.

## Step-by-step

### Step 1 — Resolve the slug to an epic folder

Apply the global slug-resolution rule from [`SHAMT_RULES.template.md`](../../../../templates/SHAMT_RULES.template.md) (Principle 1):

1. Try `epics/{slug}/epic.md` (exact match).
2. If not found, glob `epics/{slug}-*/epic.md`.
3. **Multiple matches** → halt; ask the user which folder to use.
4. **One match** → that folder is the epic folder.
5. **Zero matches** → halt; direct the user to `/p1-start-epic {slug}`.

### Step 2 — Check the validation footer

1. Read the last non-blank line of `epic.md`.
2. If it matches `Validated YYYY-MM-DD — …`, proceed to Step 3.
3. Otherwise, **halt** with: `epic.md is not validated — run /validate-artifact epics/{slug}-{brief}/epic.md first, or re-invoke with --allow-unvalidated to proceed against the draft.`
4. If `--allow-unvalidated` was passed, surface a one-line notice (`proceeding against an unvalidated epic — re-run /validate-artifact after decomposition`) and continue.

### Step 3 — Re-entry detection

Read the parent epic. If a `Decomposed YYYY-MM-DD — N feature stubs at features/{slug-1}, features/{slug-2}, …` line is already present (immediately above the validation footer), treat this as a **re-decomposition** invocation:

1. Read the prior list of feature stubs from the existing line.
2. Tell the user: "this epic has already been decomposed into N features — proceeding will replace the prior list."
3. Confirm before continuing. The re-decomposition rule in Step 9 governs what happens to the prior `Target Features` + `Sequencing & Parallelization` sections and to any orphaned stubs.
4. Once Step 5 produces an approved new feature list, **partition it against the prior list** by `{feature-slug}` (the slug portion only — the `{brief}` suffix is allowed to drift):
   - **Kept** — the new slug matches a slug in the prior `Decomposed …` line. The existing stub folder is reused as-is (Step 8); the collision check is exempt (Step 7); only the parent epic's `Target Features` / `Sequencing & Parallelization` sections are rewritten to reflect the new list (Step 9). Kept features may have user work in progress that must be preserved.
   - **New** — the slug does not match the prior list. A fresh stub is written (Step 8); the collision check applies normally (Step 7).
   - **Orphaned** — a slug in the prior list does not appear in the new list. The folder is left in place; Step 9 surfaces a warning.

On first decomposition (no prior `Decomposed …` line), every approved feature is **New**; the partition concepts above are inert.

### Step 4 — Read the epic and propose the feature list

1. Read `epic.md`: `Goal`, `Success Criteria`, `Scope / Non-Scope` (including any `**Architecture impact:** …` line), and (when present) the **All Remaining Fields** appendix.
2. Draft a proposed feature list. Each entry: **title** + **one-line goal**. Capture the list as a flat enumerated proposal — no nested sub-features, no per-feature deep dialog (that is `/p3-start-feature`'s job).
3. For each entry, derive:
   - `{feature-slug}` — kebab-case from the title (e.g., "Billing integration" → `billing-integration`).
   - `{brief}` suffix — kebab-case from the goal one-liner (e.g., goal "wire Stripe webhooks into the ledger service" → `stripe-webhook-ledger`). Keep `{brief}` short — 2–4 words.
   - **Re-decomposition Kept exception:** if a prior `Decomposed …` line is present (Step 3) and the derived `{feature-slug}` matches one of its entries, **do not** re-derive `{brief}`. Resolve the existing folder via `features/{feature-slug}-*/` glob (slugs are globally unique; the prior line records slugs only, so the actual `{brief}` is read off the existing folder name) and reuse that folder verbatim. Step 5 user iteration may move entries in or out of this set; the final Kept partition is the slug match against the prior list at the moment Step 5 approval lands (per Step 3.4). Downstream: Step 7 exempts Kept slugs from the collision halt; Step 8 preserves the existing `feature.md`; Step 9 cites the slug in the new `Decomposed …` line (the folder is recoverable via the same glob).
4. Draft the **parallelization analysis**:
   - **Recommended order** — sequenced enumeration of features by dependency; for each, a one-line "why this comes first; dependencies" note.
   - **Parallelizable** — which features can be worked concurrently and why, or `None — strictly sequential.`

### Step 5 — Gate the whole batch with the user (once)

Per the stub-list pattern, the user gates **the entire list at once** — not per-feature.

Present, in chat:

1. The proposed feature list (each entry: title, one-liner, derived `{feature-slug}-{brief}` folder name).
2. The parallelization analysis (recommended order + parallelizable callout).

Surface global scoping questions about the list **as a whole** via `AskUserQuestion` per [`SHAMT_RULES.template.md`](../../../../templates/SHAMT_RULES.template.md) Principle 2 (open-questions iterative dialog). Examples of legitimate questions at this altitude: "Should X be its own feature or absorbed into Y?", "Does the ordering reflect the hard dependency I mentioned in Goal?", "Is parallelization between A and B real, given they touch the same module?"

Iterate with the user until they approve: they may add / remove / reword entries, adjust the derived slugs, or revise the parallelization analysis. Each iteration is a single batch — re-present the updated list + analysis together.

**Per-feature deep dialog is deferred to `/p3-start-feature`.** Do not start drafting per-feature goals, scope, success criteria, or stories here — that is the next altitude's work per the stub-list-then-drill-in decomposition.

### Step 6 — Decomposition exit gate

Check **before** writing any stubs to disk. The gate is a **2-condition check** on the approved batch — distinct from `/validate-artifact`:

1. **Every feature stub has a stated goal one-liner.** No blanks, no "TBD", no placeholder text.
2. **Every feature appears in the parent epic's `Sequencing & Parallelization` analysis** — either in the `Recommended order` enumeration, or in the `Parallelizable` callout, or both.

If either condition fails, surface the gap to the user and return to Step 5. Do not write stubs while the gate is failing.

### Step 7 — Detect global feature-slug collisions

Feature slug uniqueness is **global** (flat layout). Before writing:

1. **For features in the New partition** (per Step 3 — and for all features on first decomposition): glob `features/{feature-slug}-*/` and `features/{feature-slug}/`. If **any** candidate slug collides with an existing feature folder, halt with: `feature slug "{slug}" collides with existing feature at features/{existing-folder}/. Choose a different title, or rename the existing feature.` Surface the conflict and let the user adjust the title (return to Step 5).
2. **Exemption — re-decomposition Kept partition.** A Kept slug (per Step 3) is expected to collide with its own prior stub folder under the current epic. That is not a collision in the gate sense — proceed without halting and reuse the existing folder in Step 8. Apply the exemption only when the colliding folder appears in the prior `Decomposed …` line of *this* epic; collisions against features outside that prior list (e.g., a stub created by a different epic that happens to share the slug) are real and still halt.
3. Repeat until every New candidate is unique (modulo the Kept exemption above).

### Step 8 — Write the feature stubs

For each approved feature entry:

- **New partition (per Step 3) — and every feature on first decomposition:** create `features/{feature-slug}-{brief}/feature.md` from [`templates/feature.template.md`](../../../../templates/feature.template.md). Populate **only** these fields:
  - `**Parent Epic:** {epic-slug}` — back-ref header line directly under the H1. Plain markdown; no parser.
  - `## Goal` — the one-liner approved by the user in Step 5.
  - All other sections (`Open Questions`, `Success Criteria`, `Scope / Non-Scope`, `Target Stories`, `Sequencing & Parallelization`) are **left empty** — `/p3-start-feature {feature-slug}` and `/p4-decompose-feature {feature-slug}` flesh them out later.
  - No `Validated …` footer — that comes from `/validate-artifact` once `/p3-start-feature` finishes.
- **Kept partition (re-decomposition only):** **do not touch** the existing `feature.md`. The user may have already done in-progress work inside (open questions, scope decisions, started decomposition). Preserve it untouched — Step 9 only rewrites the parent epic's references, not the feature artifacts themselves. If the user-approved goal one-liner for a Kept feature differs from the current `## Goal` of the existing `feature.md`, surface a notice (`Kept feature {feature-slug}: existing Goal differs from new one-liner — leaving existing feature.md untouched; revise it via /p3-start-feature {feature-slug} if intended.`) and continue without editing.

### Step 9 — Append decomposition output to the parent epic

Update `epic.md`:

1. **Rewrite `## Target Features` wholesale** with the approved list — one bullet per feature: `` `{feature-slug}` — {one-line goal} ``. If this is a re-decomposition (Step 3), replace the prior section's content entirely.
2. **Rewrite `## Sequencing & Parallelization` wholesale** with the approved analysis (recommended order + parallelizable callout). Same wholesale-replace rule on re-decomposition.
3. **Add (or replace) a `Decomposed YYYY-MM-DD — N feature stubs at features/{slug-1}, features/{slug-2}, …` line** immediately **above** the `Validated …` footer, so the validation footer remains the last line of the file. Use today's date.
   - **Slug-only format.** Record the slug portion of each folder (`{feature-slug}`), not the full `{feature-slug}-{brief}` path. Slugs are globally unique, so the actual folder is always recoverable via `features/{slug}-*/` glob — recording only the slug keeps the line parseable on re-decomposition (Step 3 reads slugs directly without having to split a slug-brief concatenation, which is ambiguous because both are kebab-case).
   - On first decomposition: insert the line.
   - On re-decomposition: replace the prior `Decomposed …` line in place. Only the latest decomposition is recorded.
4. **Preserve the existing validation footer** as-is. The epic was validated before decomposition; decomposition does not re-invalidate it. Do not strip or duplicate the footer.

**Re-decomposition partition handling.** Per Step 3, the new list partitions against the prior `Decomposed …` line into Kept / New / Orphaned:

- **Kept** features carry forward — their existing `feature.md` is preserved per Step 8. The new `Target Features` and `Sequencing & Parallelization` sections reference them with the user-approved one-liner from Step 5 (which may differ from the existing `## Goal` inside the Kept stub — see Step 8 notice).
- **New** features got fresh stubs in Step 8.
- **Orphaned** features (in the prior list but not the new list) are **not auto-deleted**. Surface a warning listing the orphaned feature folders and ask the user to delete or repurpose them manually — auto-deletion risks silently destroying in-progress work in those folders.

```
Warning: re-decomposition orphaned the following feature folders
(slug → folder; folders resolved via features/{slug}-*/ glob):

  - billing-integration → features/billing-integration-stripe-webhook-ledger/
  - reporting-summary   → features/reporting-summary-daily-export/

These are NOT auto-deleted. Review each and either delete or repurpose manually.
```

The left column is the slug as it appeared in the prior `Decomposed …` line; the right column is the actual folder path on disk (the `{brief}` suffix is recovered via glob). The user sees both so they can navigate to the folder and recognize the slug they had in mind.

### Step 10 — Exit gate

Verify before exiting:

- [ ] N feature-stub folders exist at `features/{feature-slug}-{brief}/` with `feature.md` files.
- [ ] **New stubs** (per Step 3 partition; and every stub on first decomposition) carry `**Parent Epic:** {epic-slug}` and a filled `## Goal`, with every other section empty.
- [ ] **Kept stubs** (re-decomposition only) are preserved unchanged from before this invocation — any user work inside (Open Questions / Success Criteria / Scope / Target Stories / Sequencing) survives untouched. The "other sections empty" rule does not apply to Kept stubs.
- [ ] Parent epic's `## Target Features` lists each stub with its one-liner.
- [ ] Parent epic's `## Sequencing & Parallelization` carries the approved analysis (recommended order + parallelizable callout).
- [ ] Parent epic has a `Decomposed YYYY-MM-DD — N feature stubs at features/{slug-1}, features/{slug-2}, …` line immediately above the validation footer. **Slug-only format** — the actual folder paths (with their `{brief}` suffixes) are recoverable via `features/{slug}-*/` glob, not embedded in the line. For Kept entries, the cited slug points to the existing preserved folder per Step 4.3 Kept exception.
- [ ] Parent epic's existing `Validated …` footer is preserved as the last line.
- [ ] On re-decomposition: orphaned stubs (if any) surfaced as a warning, not auto-deleted.

If any item fails, return to the relevant step.

### Step 11 — Suggest the next commands

Surface, but do **not** auto-invoke:

```
/clear
/p3-start-feature {feature-slug-1}     # flesh out the first stub
/p3-start-feature {feature-slug-2}     # ...and so on
```

Each feature stub is **independently resumable**. The PO can drive `/p3-start-feature` on each stub in sequence, or run them in parallel by opening additional terminal tabs (the framework provides no runtime coordination machinery per the decomposition / parallelization step). Order is suggested by the `Recommended order` line just written to the epic.

## Exit criteria

- N feature-stub folders exist at `features/{feature-slug}-{brief}/feature.md`. **New** stubs (and every stub on first decomposition) carry `**Parent Epic:** {epic-slug}` + `## Goal` filled with every other section empty. **Kept** stubs (re-decomposition) are preserved unchanged from before this invocation.
- The parent epic's `Target Features` and `Sequencing & Parallelization` sections carry the approved list and analysis.
- The parent epic has a slug-only `Decomposed YYYY-MM-DD — N feature stubs at features/{slug-1}, features/{slug-2}, …` line directly above the preserved `Validated …` footer; actual folders are recoverable via `features/{slug}-*/` glob. For Kept entries, the cited slug points to the preserved existing folder.
- The user has approved the list (gated once) and confirmed any derived-slug overrides.

## Notes

- **Fresh-agent runnable.** Every input lives on disk (`epic.md`, `feature.template.md`, the existing `features/` tree). No conversation history required.
- **Decomposition exit gate ≠ `/validate-artifact`.** The gate in Step 6 is a 2-condition stub-batch check run **before** stubs are written; `/validate-artifact` is the full Pattern 1 loop that runs against `epic.md` (already, before `/p2-decompose-epic`) and against each `feature.md` (later, after `/p3-start-feature` completes its dialog). Do not conflate the two.
- **No tracker fetch.** This command operates entirely on the already-written `epic.md`. The tracker freeform-fallback rule does not apply at this altitude — there is no tracker payload to fall through from.
- **No per-feature deep dialog here.** That is `/p3-start-feature`'s job per the stub-list-then-drill-in decomposition. Resist the urge to start drafting feature scope or success criteria — it produces low-value batched dialog at this altitude and pre-empts the open-questions iterative dialog at the next altitude.
- **No epic-level review phase.** Per Pattern 4, the 16-category code-review framework stays story-level. This command does not invoke `/e6-review-changes`.
- **No `/p3-start-feature` auto-invocation.** Per Principle 1, every command stays independently runnable. Chaining would force a multi-phase session and would couple resumability across altitudes.
- **Parallelization is PO-flow output, not runtime coordination.** The `Parallelizable` callout informs the PO; running features concurrently is a "second terminal tab" exercise.

---
<!-- Managed by Shamt — do not edit. Regenerate from shamt-core/host/templates/claude/commands/p2-decompose-epic.md. -->
