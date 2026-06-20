---
description: Story stage-1 define (story altitude analogue of /pf1-define) — flesh out the planning ticket via open-questions dialog, leaving it defined-but-unvalidated; validation is the dedicated /ps2-validate stage
---

# /ps1-define

**Purpose:** Run Stage 1 of the PO flow at the **Story** altitude (the story-specific define stage). Resolve a slug, branch on three input modes (ingest an existing `/ps0-draft` stub when present, create a standalone story from scratch, or seed from a tracker work-item payload when the active profile supports Story), drive an open-questions iterative dialog over the scope one-liner + spec structure, and produce the story-ticket stub under its parent feature — `epics/{epic-folder}/features/{feature-folder}/stories/{ID}-{slug}-{brief}/ticket.md`. Like `/pe1-define` and `/pf1-define`, `/ps1-define` **defers validation to the dedicated validate stage** — here `/ps2-validate` — and does **not** stamp a `Validated …` footer itself. Define no longer validates at *any* altitude; validation is its own stage. The footer that `/ps2-validate` later stamps on `ticket.md` is the readiness signal `/e1-start-story` keys on.

**Recommended model:** Balanced (Sonnet) — open-questions dialog / define task (no inline validation loop; validation is `/ps2-validate`'s job, escalating to Reasoning there); cite [`reference/model_selection.md`](../../../../reference/model_selection.md).

---

## Usage

```
/ps1-define {slug} [--tracker={ado|github|local}]
```

## Arguments

- `{slug}` (required) — story slug. **Globally unique across the tree** (see §PO-tree resolution). Resolved per the same rules as `/e1-start-story`.
- `--tracker={ado|github|local}` (optional) — one-off override of the project's default `work_item_tracker` for this invocation only. Same semantics as `/e1-start-story` and `/pe1-define`. Legal values: any profile file in [`reference/trackers/`](../../../../reference/trackers/). The default comes from `.shamt-core/shamt-config.json`. Per [`reference/trackers/_contract.md`](../../../../reference/trackers/_contract.md).
  - **Note:** the override only changes behavior in **Mode C** (where a tracker fetch actually happens). In **Mode A** (ingesting an existing draft) and **Mode B** (standalone from scratch), no fetch occurs and `--tracker=` is a no-op. Surface a one-line notice (`--tracker={name} is a no-op in Mode {A|B} — no tracker fetch occurs`) if the flag is passed in those modes so the user is not surprised.

## Prerequisites

- `.shamt-core/shamt-config.json` must exist at the project root. If not, halt and direct the user to `init-shamt`.
- If `--tracker=` is passed, the named profile must exist at `reference/trackers/{name}.md`. If not, halt and list the available profiles.

## Step-by-step

### Step 1 — Read configuration

1. Read `.shamt-core/shamt-config.json` from the project root. Extract `work_item_tracker` (one of `ado`, `github`, `local`, `none`).
2. If the user passed `--tracker={name}`, override the value for this invocation.
3. Read the corresponding profile at `reference/trackers/{name}.md` (skip when the resolved value is `none`).

### Step 2 — Resolve the slug to a story folder

Apply the global slug-resolution rule from [`templates/SHAMT_RULES.template.md`](../../../../templates/SHAMT_RULES.template.md) (Principle 1) — resolve per §PO-tree resolution (tree-wide story glob). Slugs are globally unique, so the resolved folder's altitude is unambiguous.

**Altitude dispatch (own vs. parent vs. grandparent vs. neither).** Resolve the slug and branch on the altitude of the folder it resolves to:

- **Own altitude (the slug resolves to a *story* folder)** → the single-story behavior below (the rest of Step 2 and the Step-by-step) runs **unchanged**. This is the default, by-far-common case.
- **Parent altitude (the slug resolves to a *feature* folder)** → enter **[Parent-slug batch mode](#parent-slug-batch-mode-feature--all-stories)**: define every story under that feature, sequentially. Hand off to that section and do not run the single-story steps directly.
- **Grandparent altitude (the slug resolves to an *epic* folder)** → enter **[Grandparent-slug batch mode](#grandparent-slug-batch-mode-epic--all-stories)**: define every story in the epic's entire story subtree, sequentially, by dispatching the existing feature→stories parent batch per feature. Hand off to that section and do not run the single-story steps directly.
- **Neither (the slug resolves to no story, no feature, and no epic)** → halt and report `slug {slug} resolves to no story (own altitude), no feature (parent altitude), and no epic (grandparent altitude) — nothing to define`.

The single-story resolution that follows runs only on the own-altitude branch:

1. Glob the nested story path: `epics/*/features/*/stories/{ID}-*/ticket.md` (for a ticket ID) or, for a slug, **both** `epics/*/features/*/stories/{slug}-*/ticket.md` and `epics/*/features/*/stories/*-{slug}-*/ticket.md` (tree-wide story glob). Also check the legacy-flat fallback: `stories/{ID}-*/ticket.md`, `stories/{slug}-*/ticket.md`, or `stories/*-{slug}-*/ticket.md` (for backwards compatibility).
2. If any match is found, verify it is the only one; if multiple matches exist for the same slug, halt and ask the user which folder to use.
3. **Multiple matches** → halt and ask the user which folder to use.
4. **One match** → that folder is the story folder. **Detect Mode A vs. re-entry** by inspecting `ticket.md`:
   - If `ticket.md` carries the `**Status:** Draft (f0 — story-idea capture, unrefined)` marker line (the Stage-0 draft overlay marker) **and** a `## Scratch Notes (stage-0 capture)` section, this is a **Mode A — ingest a pe0/pf0/ps0 draft** (the additive overlay). Proceed to Mode A under Step 4 (seed from Scratch Notes, deepen via dialog, strip the marker + Scratch Notes on completion). (The parent feature is the folder path.)
   - If `ticket.md` has its **planning fields already drafted** (body intake area populated, spec structure present) **but** does **not** carry the Status marker + Scratch Notes (i.e., a prior `/ps1-define` deep-dive ran or the ticket was authored standalone), this is a **re-entry**. Confirm with the user how to proceed. **Available options depend on whether the active tracker actually has a Story fetch path** (resolved in Step 1 plus the profile's `## Supported work-item types`):
     - **Fetching profile that declares Story support** (e.g., `ado`, `github`): offer all four — **refetch**, **overwrite**, **extend**, **exit**.
     - **`local`:** the file is the source of truth. Offer **overwrite**, **extend**, **exit**.
     - **`none`:** no tracker fetch path. Offer **overwrite**, **extend**, **exit**.

     Footer handling per branch (same rules as `/pf1-define`):
     - **Refetch** (offered only when the active profile declares Story support) — re-run the tracker fetch (Step 4 Mode C) and re-author the artifact from scratch. The file is rewritten wholesale; any prior `Validated …` footer is discarded along with the prior content. **Note:** if the existing artifact was originally drafted via Mode A (stub-ingesting) or Mode B (standalone), Refetch will replace that hand-authored content with tracker-seeded content — surface a one-line warning (`current artifact was not tracker-seeded — Refetch will replace hand-authored content with tracker payload`) before proceeding so the user can opt for Extend instead.
     - **Overwrite** — start the freeform open-questions dialog (Step 6) from a fresh template. Same wholesale rewrite; prior footer discarded.
     - **Extend** — preserve existing content and add to it. **If a prior `Validated …` footer is present, strip it before continuing** — extension changes the artifact and invalidates the prior pass; re-run `/ps2-validate {slug}` afterward to re-stamp a new footer.
     - **Exit** — leave the file untouched and return. No footer change.

     **Preserve the `**Ticket ID:**` header verbatim on re-entry.** The `**Ticket ID:** …` line is never rewritten by `/ps1-define` regardless of the chosen branch — it is decomposition-owned. Only the body sections are touched.
5. **Zero matches** → continue to Step 3 (Mode B or Mode C, decided in Step 4).

### Step 3 — Derive the brief description and propose the folder name

Applies only when the slug does not yet resolve to a folder (i.e., Mode A is ruled out and we are heading into Mode B or Mode C):

1. Ask the user for a 2–4-word **brief description** of the story, or derive it from the tracker payload's title once fetched (re-propose after Step 4 Mode C).
2. **For a new (non-stub) story, allocate a ticket ID** `T{N}` (= `max` of the `^T([0-9]+)-` prefixes across `epics/`, `features/`, `stories/`, + 1 — per **# Ticket IDs**) and propose the folder path, populating the `**Ticket ID:** T{N}` header. **Mode A (stub):** the folder + its ID already exist — reuse them, do **not** allocate or re-propose. **Ask the user to confirm the brief + folder name before creating directories.**
3. On confirmation, create the folder.

### Step 4 — Branch on input mode

The command supports three input modes. **Mode disambiguation order:**

1. **Mode A — ingest an existing `/ps0-draft` or older stub** if Step 2 resolved to a folder whose `ticket.md` carries the `**Status:** Draft (f0 — story-idea capture, unrefined)` marker + `## Scratch Notes (stage-0 capture)` section (the additive draft overlay). Seed from Scratch Notes, deepen via dialog, then **strip the marker + Scratch Notes on completion** (the f1-style ingestion). (Parentage is the folder path.)
2. **Mode C — tracker-seeded** if Mode A did not apply AND the active tracker profile declares Story work-item type support AND the slug parses to a tracker ID per the profile's `## Slug resolution` rule.
3. **Mode B — standalone from scratch** otherwise. (Parentage is the parent feature's folder path.)

#### Mode A — ingest an existing draft (the common case after `/ps0-draft`)

The folder exists; `ticket.md` carries the `**Status:**` marker + `## Scratch Notes (stage-0 capture)` section (the draft overlay).

1. **Read the Scratch Notes section** to seed the user's intent.
2. **Preserve the `**Ticket ID:**` header verbatim** — decomposition-owned.
3. **Consume the stub's existing content** (body intake area, Decomposition Context if present) as a research seed, then proceed to Step 5 (consult architecture) and Step 6 (open-questions dialog) to **deepen and flesh out** the spec structure.
4. **On completion of the open-questions dialog** (Step 6), **strip the marker line and the `## Scratch Notes (stage-0 capture)` section** from `ticket.md`. This is the f1-style ingestion: the draft status + Scratch Notes are a temporary staging vehicle, removed once the story is defined.
5. Leave other template sections empty (Summary, Description, Acceptance Criteria, etc.) as they appear in the template — the Engineer flow's `/e1-start-story` will flesh them out during intake.
6. **No `## All Remaining Fields` appendix** — there was no tracker fetch in this mode.

#### Mode B — create a standalone story from scratch

The folder did not exist before Step 3. There is no explicit parent feature input from the user in the current altitude.

1. Read the active tracker's per-provider ticket template and write `epics/{epic-folder}/features/{feature-folder}/stories/{ID}-{slug}-{brief}/ticket.md` from it. After writing `ticket.md`, write its path to `shamt-state/active-story` and `shamt-state/active-feature` pointers (per `/e1-start-story` baseline).
2. **Mode B nests under the parent feature** determined by the resolved or proposed folder path (user-selected parent feature when ambient, or default to Tech Stories epic's standing feature when creating a standalone).
3. Proceed to Step 5 (architecture consult), then Step 6 (open-questions dialog) to populate the spec structure from scratch.
4. Leave other template sections empty (Summary, Description, Acceptance Criteria, etc.).
5. **No `## All Remaining Fields` appendix** — there was no tracker fetch in this mode.

#### Mode C — tracker-seeded

(Consult `/e1-start-story` Step 4 Mode C for the detailed tracker-fetch shape; the same mode logic applies here with story-altitude adaptations.)

### Step 5 — Consult `.shamt-core/project-specific-files/ARCHITECTURE.md` (advisory)

When deepening scope or drafting spec structure, flag architectural impact inline (in the ticket's body intake area or in a `**Architecture impact:** {…}` line when the story implies a new service / boundary / data store / external integration). **Do NOT consult `.shamt-core/project-specific-files/CODING_STANDARDS.md`** — coding standards are the Engineer flow's concern, not the PO flow's.

### Step 6 — Open-questions iterative dialog

Per [`templates/SHAMT_RULES.template.md`](../../../../templates/SHAMT_RULES.template.md) Principle 2 (open-questions iterative dialog) — surface each question one at a time via `AskUserQuestion`, update the ticket with each answer, drain the section before exit. Focus on scope, spec readiness, and acceptance criteria — not implementation detail (that is the Engineer flow's `/e1-start-story`).

**Leaves the ticket with:**
- Body intake area + spec structure drafted and defensible.
- `## Open Questions` section empty.
- Other template sections (Summary, Description, Acceptance Criteria, Related Work, Comments, Update History, All Remaining Fields) left as template placeholders (the Engineer flow's responsibility).

**Mode A note:** After the dialog completes, **strip the `**Status:** Draft (f0 — story-idea capture, unrefined)` marker line and the `## Scratch Notes (stage-0 capture)` section** from `ticket.md`. This is the f1-style ingestion: the draft overlay is removed once the story is defined.

### Step 8 — Exit

On completion of the open-questions dialog (ticket defined, `## Open Questions` drained), suggest the next command:

```text
Story ticket {slug} is defined (not yet validated).
Next: /ps2-validate {slug} to run the validation loop and stamp the Validated footer.
```

Validation is the dedicated `/ps2-validate` stage; the `Validated …` footer it stamps is what `/e1-start-story`'s ready-ticket pickup branch keys on.

## Parent-slug batch mode (feature → all stories)

Entered from Step 2's altitude dispatch when the slug resolves to a **feature** folder (the parent altitude) rather than a story folder. The command then runs its own single-story define logic across every story under that feature, sequentially. This is **horizontal sibling fan-out at one altitude** — it defines each story; it does **not** validate them (that stays `/ps2-validate`) and does **not** chain into any other altitude's command. The batch loop is a **stateless, disk-derived dispatcher of this command's own single-story logic** — the worklist comes from the feature's on-disk decomposition output, and re-invocation is resumable (see Principle 1 reconciliation in Notes).

1. **Derive the ordered worklist from disk.** Read the feature's `feature.md` and take its child stories in the order given by `## Sequencing & Parallelization` (`Recommended order`), falling back to `## Target Stories` list order when no sequencing is recorded. Resolve each listed slug to its story folder per §PO-tree resolution.
   - **Empty / un-decomposed parent.** If the feature has no children (its `## Target Stories` decomposition list is empty / absent — e.g. the feature has not yet been run through `/pf3-decompose`), the worklist is empty: report `parent {slug} has no children to process — run the decompose phase (/pf3-decompose {slug}) first` and **exit cleanly** (a no-op, distinct from the Step 2 "neither own nor parent altitude → halt" dispatch case).
2. **Skip-already-defined-with-notice (resumability).** For each story in worklist order, first check whether it is already defined — its `ticket.md` body intake area + spec structure are drafted and its `## Open Questions` is drained (the single-slug completion signal this command produces; `/ps1-define` no longer stamps a footer). If so, emit a one-line notice (`skipping {story-slug} — already defined`) and move to the next child. This makes re-invocation resumable: a batch interrupted partway resumes at the first incomplete child without re-prompting completed ones.
3. **Per-child execution.** For each not-yet-defined story, run this command's **single-story** Step-by-step verbatim on that story's slug — including the full per-child open-questions iterative dialog (Step 6), one question at a time per Principle 2. Each child runs its **own complete dialog before the next child starts**; never bulk-bomb the union of all children's questions across the batch. (Validation is the separate `/ps2-validate {feature-slug}` batch — run it after this define batch completes.)
4. **Halt-at-child on an unresolvable outcome.** If any child hits a condition it cannot resolve (slug collision, ambiguous resolution, a dialog that cannot converge), **stop the batch at that child** and surface its report verbatim. The user fixes it and re-invokes; resumability (step 2) resumes at that child without re-prompting the children already defined ahead of it.
5. **Final summary.** When the worklist is exhausted, report a one-line-per-child summary: each child slug and its outcome (`defined` / `skipped — already defined`), then the next-command suggestion (`/clear`, then `/ps2-validate {feature-slug}` to validate all the newly defined stories).

## Grandparent-slug batch mode (epic → all stories)

Entered from Step 2's altitude dispatch when the slug resolves to an **epic** folder (the grandparent altitude) rather than a feature or story folder. The command then processes the epic's full story subtree by dispatching the **existing feature→stories parent batch** (`## Parent-slug batch mode`) per feature, sequentially. This is **nested horizontal fan-out, still single-phase** — it defines every story under every feature of the epic; it does **not** define the features themselves (that is `/pf1-define`'s job), does **not** decompose anything (`/pf3-decompose`), and does **not** validate (`/ps2-validate`). The batch loop is a **stateless, disk-derived dispatcher** of the existing parent-batch logic — the feature worklist comes from the epic's on-disk decomposition output, and re-invocation is resumable via the parent batch's own skip-already-defined check.

1. **Derive the ordered feature worklist from disk.** Read the epic's `epic.md` and take its child features in the order given by `## Sequencing & Parallelization` (`Recommended order`), falling back to `## Target Features` list order when no sequencing is recorded. Resolve each listed slug to its feature folder per §PO-tree resolution.
   - **Empty / un-decomposed epic.** If the epic has no children (its `## Target Features` decomposition list is empty / absent — e.g. the epic has not yet been run through `/pe3-decompose`), the worklist is empty: report `epic {slug} has no features to process — run the decompose phase (/pe3-decompose {slug}) first` and **exit cleanly** (a no-op, distinct from the "neither" dispatch case).
2. **Per-feature dispatch (resumable via child batch resumability).** For each feature in worklist order, dispatch the **existing feature→stories parent batch** (`## Parent-slug batch mode`) on that feature's slug. The parent batch handles its own skip-already-defined resumability per step 2 of that section, so stories already defined within a feature are skipped without re-prompting. Run one feature batch to completion before starting the next.
3. **Halt-at-feature on an unresolvable outcome.** If any feature's parent batch hits a condition it cannot resolve (e.g. the feature is not yet decomposed, or a child story halts), **stop the grandparent batch at that feature** and surface its report verbatim. The user fixes it and re-invokes; the parent batch's resumability resumes within that feature without re-defining previously completed stories.
4. **Final summary.** When all features' batches are exhausted, report a one-line-per-feature summary (each feature slug + count of stories defined / skipped), then the next-command suggestion (`/clear`, then `/ps2-validate {epic-slug}` to validate all the newly defined stories).

## Notes

- **Parent-slug batch mode is horizontal fan-out, not vertical chaining — and honors Principle 1.** Passing a **feature** slug (the parent altitude) runs this command's single-story define logic across every story under the feature (`## Parent-slug batch mode`). This is **horizontal sibling fan-out at one altitude** — it defines each story; it does **not** validate them (that stays `/ps2-validate`) and does **not** chain into any other altitude's command. It honors Principle 1 by the same argument `CLAUDE.md` homes for the `/f-all` / `/e-all` drivers: it is a **stateless, disk-derived dispatcher** of this command's own single-story logic (worklist derived from the feature's on-disk `Target Stories` / `Sequencing & Parallelization`, resumable by re-invocation via the skip-already-defined check, each child independently runnable via its own single slug) — not a state-holding mega-orchestrator.
- **Grandparent-slug batch mode is nested horizontal fan-out, still single-phase — and honors Principle 1.** Passing an **epic** slug (the grandparent altitude) runs the existing feature→stories parent batch per feature across the epic's full story subtree (`## Grandparent-slug batch mode`). It crosses two structural levels (epic → feature → story) but remains a **single-phase, story-define-only** dispatcher — it does **not** define features, decompose, or validate. It honors Principle 1 by the same argument: a **stateless, disk-derived dispatcher** of the parent-batch logic (feature worklist derived from the epic's on-disk `Target Features` / `Sequencing & Parallelization`, resumable via the parent batch's own skip-already-defined check, each story independently runnable by its own single slug) — not a state-holding mega-orchestrator and not a cross-phase vertical pipeline. (`/ps1-define {epic}` defines-only and `/ps2-validate {epic}` validates-only are two **distinct single-phase commands** the user runs in sequence — neither chains into the other.)

---

Created 2026-06-14 — by /f3-implement-update for proposals/26-po-draft-stub-skills-incremental-decomposition.md (Phase 1).

<!-- Managed by Shamt — do not edit. Regenerate from shamt-core/host/templates/claude/commands/ps1-define.md. -->
