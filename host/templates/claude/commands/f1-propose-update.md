---
description: Phase 1 of the framework-update flow — author or edit a proposal at .shamt-core/proposals/{slug}.md, applying the open-questions iterative dialog as the change set firms up
---

# /f1-propose-update

**Purpose:** Run Phase 1 of the framework-update flow. Resolve a slug to `.shamt-core/proposals/{slug}.md`, draft (or edit) the proposal against the canonical template, and apply the open-questions iterative dialog until every question is resolved and every affected canonical file is listed.

**Recommended model:** Balanced (Sonnet). Drafting a proposal is structural analysis (reading the canonical sources the change will touch, naming them precisely, and writing a clear problem statement). The validation loop in Phase 2 escalates to Opus. See [`reference/model_selection.md`](../../../../reference/model_selection.md).

---

## Usage

```
/f1-propose-update {slug} [blurb]
```

## Arguments

- `{slug}` (required) — descriptive kebab-case slug for the proposal (e.g., `fix-spec-template-missing-section`, `add-mermaid-recipe`). The slug becomes the filename `.shamt-core/proposals/{slug}.md`. Slugs are descriptive, not numbered — there is no SHAMT-N convention in v2.
- `[blurb]` (optional) — a free-text idea or problem statement used to seed the Problem section (Input Mode 2 below). Ignored when an f0 draft already exists at the slug (Input Mode 3 supplies the seed from the draft's Scratch Notes instead).

## Input modes

`/f1-propose-update` accepts three starting points; the mode is auto-detected from the slug + optional blurb:

1. **Blank (default)** — `/f1-propose-update {slug}` with no blurb and no existing file. Seed a fresh proposal from the template and draft from scratch.
2. **Free-text blurb** — `/f1-propose-update {slug} {blurb}`. The blurb is a raw idea / problem statement (like the text a user would type into the dialog). Seed the template, then use the blurb as the starting material for the Problem section before the open-questions dialog refines it.
3. **Existing f0 draft** — `/f1-propose-update {slug}` where `{slug}.md` already exists and carries the **f0-draft marker** (`Status: Draft (f0 — audit capture, unrefined)` + the f0 banner), as written by `/f0-draft-proposal` (e.g. captured by the audit). Ingest the draft as the intake rather than prompting extend / overwrite: normalize the status to plain `Draft`, drop the banner, and develop the **Scratch Notes (f0 capture)** content into the full Problem + Proposed Changes + Risks / Rollback / Validation Considerations.

Modes 2 and 3 only change the *seed*; the rest of the flow — Proposed Changes, Risks / Rollback / Validation, the open-questions dialog, the exit gate — is identical.

## Prerequisites

- Run from the shamt-core repository root (master-side) — the repo with a top-level `proposals/` directory — or from a project with a synced framework + `.shamt-core/proposals/` folder (child-side). If neither exists, halt and direct the user to either run this from the shamt-core repo root or install Shamt first.
- `.shamt-core/proposals/_template.md` must exist. If not, halt and report — the template is the source of truth for proposal shape.

## Slug resolution

Proposals are **flat files**, not folders. There is no `_PLAN.md` companion at this phase; that comes in Phase 3.

- Try `.shamt-core/proposals/{slug}.md` (exact match), then the numbered glob `.shamt-core/proposals/*-{slug}.md` (master-side proposals carry a `{NN}-` filename prefix). A bare numbered stem `{NN}-{slug}` passed as the slug resolves directly. Slugs are unique, so the glob matches **at most one** file; per the established "halt and ask on multiple matches" invariant, halt if it ever matches more than one.
- **File exists and is an f0 draft** (its `Status:` is `Draft (f0 — audit capture, unrefined)` and/or it carries the f0 banner) — **Input Mode 3: ingest it; do NOT prompt extend / overwrite.** Read the file, normalize `Status:` to plain `Draft`, remove the f0 banner, and lift the **Scratch Notes (f0 capture)** content as the seed for the Problem + Proposed Changes drafting (Step-by-step Step 2 onward); delete the Scratch Notes section once its content has been developed into the formal Problem. An f0 draft never carries a Phase 2 validation footer (f0 does not append one), so there is nothing to strip. Skip the template-seed step (Step 1) — the f0 file already follows the template shape.
- **File exists, non-empty, and is NOT an f0 draft** — treat as re-entry. Read the file, confirm with the user whether to extend the existing proposal or start over. If extending, skip the template-seed step (Step-by-step Step 1 below) and resume drafting at Step-by-step Step 2; **if a prior Phase 2 validation footer is present, strip it before continuing — extending the proposal invalidates the prior validation, and Phase 2 must re-run on the extended content (the Step 6 exit gate enforces this).** If starting over, move the abandoned draft to `.shamt-core/proposals/archive/{slug}.draft-{timestamp}.md` (using `git mv` when tracked) before overwriting. The archive folder is the documented home for retired proposal files; the `.draft-{timestamp}` infix distinguishes abandoned drafts from implemented archives.
- **File does not exist** — continue to Step-by-step Step 1 below (Input Mode 1, or Input Mode 2 when a blurb was passed).
- **`.shamt-core/proposals/archive/{slug}.md` or `.shamt-core/proposals/archive/*-{slug}.md` exists** (exact or numbered-prefix match) — a proposal with this slug was already implemented. Halt, report the archive location, and ask the user to pick a different slug or explicitly confirm they want a follow-up proposal under the same slug (uncommon).

## Step-by-step

### Step 1 — Seed from the template

> **Input Mode 3 (existing f0 draft): skip this step** for the template-seed — the f0 file already follows the template shape — but **still run the master-side number-assignment sub-step (items 5–6 below)**: an f0 draft is unnumbered, so on master it must be numbered + renamed during ingestion. Per Slug resolution, normalize `Status:` to plain `Draft`, drop the f0 banner, and resume at Step 2 using the Scratch Notes as the seed.

1. Read [`.shamt-core/proposals/_template.md`](../../../../proposals/_template.md) top-to-bottom.
2. Copy it to `.shamt-core/proposals/{slug}.md`.
3. Fill in the header block: `Created: {today's YYYY-MM-DD}`, `Status: Draft`, `Proposed by:` (blank for master-local; the child's project name for child-authored), `Project context:` (one-line context for child-authored; blank otherwise).
4. **Input Mode 2 (blurb passed):** drop the blurb verbatim into the Problem section as raw starting material — Step 2 sharpens it against the canonical sources.
5. **Assign the proposal number — master-side only (guard).** This sub-step runs **only on the master side**, gated behind the same master-vs-child detection the Prerequisites already use (master = the repo with a top-level `proposals/` directory; child = the `.shamt-core/`-synced project root).
   - **On the child side:** skip number assignment entirely. The proposal stays unnumbered at `.shamt-core/proposals/{slug}.md` — no `**Number:**` header, no filename prefix. Numbering happens only on master; `/sync-triage-proposals` assigns it at promote time.
   - **On the master side** (top-level `proposals/`): scan every folder a numbered proposal can come to rest in — `proposals/`, `proposals/archive/`, `proposals/deferred/`, `proposals/rejected/` (**not** `proposals/incoming/`, which holds still-unnumbered child submissions). For each filename, parse a leading `^[0-9]+-` digit run; the proposal number is `max(parsed NN) + 1`, or `01` when no numbered file exists (unnumbered/grandfathered files contribute nothing to the max). Format two-digit zero-padded (`01`, `02`, … widening to three digits only past `99`). There is no counter file — re-scan disk each time.
   - Write the `**Number:** {NN}` header into the proposal and **name the file with the `{NN}-` prefix**: `proposals/{NN}-{slug}.md`. If the Step 1 item 2 copy (or the Mode-3 ingested f0 file) wrote an unnumbered `{slug}.md`, rename it now (`git mv` when tracked).
6. **Branch creation is NOT f1's job** (either side). Authoring, validation, and planning all happen on the base branch; `/f3-implement-update` creates the `proposal/{NN}-{slug}` branch immediately before the canonical edits. Do not create or switch branches here.

### Step 2 — Draft the Problem section

1. Read enough of the canonical sources to state the concrete problem without hedging. Cite the specific files and sections (e.g., `templates/SHAMT_RULES.template.md` §Pattern X, `reference/severity_classification.md`, `host/templates/claude/commands/Z.md`).
   - **Seeded from a blurb (Mode 2) or an f0 draft's Scratch Notes (Mode 3):** treat that text as the raw problem statement — verify and sharpen it against the canonical sources, don't just paste it. For **Mode 3**, once the Scratch Notes content is folded into the formal Problem, **remove the `## Scratch Notes (f0 capture)` section** so it does not survive into validation.
2. Write the Problem section as 1–3 short paragraphs. If the trigger was a story-level incident or a recurring review finding, link the story slug or the [Review Prevention Gates](../../../../reference/pr_review_prevention.md) gate the change is meant to address.
3. If you cannot yet state the problem precisely — for example, the user has described a symptom but the root canonical-source location is unclear — add the gap to **Open Questions** and surface it via the dialog in Step 5 before proceeding.

### Step 3 — Build the Proposed Changes list

This is the single most load-bearing section. The validator and `/f3-implement-update` both treat it as the authoritative change scope.

1. For every canonical file the change will touch, add a row to the **Proposed Changes** table with: `#`, canonical path, operation (CREATE / EDIT / DELETE / MOVE), one-line change description.
2. Apply the path discipline rules in the template:
   - **CREATE** rows give the exact target path and a one-line content sketch.
   - **EDIT** rows name the exact section / heading the edit lands in.
   - **DELETE** rows justify the removal.
   - **MOVE** rows decompose into paired CREATE + DELETE rows.
   - Generated `.claude/` paths **never** appear. Canonical sources are:
     - `shamt-core/templates/`
     - `shamt-core/reference/`
     - `shamt-core/host/templates/claude/`
     - `shamt-core/scripts/`
     - `shamt-core/proposals/` (when the proposal updates the proposal template or folder docs)
     - the root-level canonical docs: `shamt-core/CLAUDE.md`, `shamt-core/CHEATSHEET.md`, `shamt-core/shamt-config.example.json`.

   Any path under `shamt-core/` outside this list is allowed **only if** the proposal explicitly justifies it in **Validation Considerations** or **Risks** (e.g., introducing a new top-level canonical folder). `/f3-implement-update` enforces the same list at edit time.
3. Cross-check the list. For every rule edit, ask: does the corresponding template need to change? Does the mirrored skill need to change? For every command edit, ask: does the skill need to change? For every reference change, ask: does the rule body that points at it need to change?
4. **Count the rows.** If the total exceeds **10 canonical file operations**, append a note to the proposal: `Phase 3 required — file count {N} > 10. Run /f2-plan-update-implementation {slug} before /f3-implement-update.`

### Step 4 — Draft Risks, Rollback, Validation Considerations

1. **Risks** — fill out at minimum: regression, drift (canonical vs. generated `.claude/`), child-project compatibility on next `import-shamt`, open-questions debt. Add any change-specific risks.
2. **Rollback Plan** — write concrete steps: revert commit, `/f4-regen-framework`, child-side action required (or "none"), who to tell. For purely additive changes use the one-line rollback shortcut from the template.
3. **Validation Considerations** — dimension hints for Phase 2. Tell the validator where to look hardest: which change-list rows are easy to forget paired edits for, which risks the list might miss, which surfaces are affected (rules / refs / templates / commands / skills / personas / scripts), what propagation steps are needed (regen + child import).

### Step 5 — Open-questions iterative dialog

Apply the **open-questions iterative dialog** principle (see [`SHAMT_RULES.template.md`](../../../../templates/SHAMT_RULES.template.md#principle-2-open-questions-iterative-dialog) Principle 2):

1. Maintain the `## Open Questions` section as you draft. Add a checkbox-prefixed entry the moment a question surfaces.
2. Surface each question to the user **one at a time** via `AskUserQuestion`. Never bulk-bomb.
3. Update the proposal with each answer before moving to the next question. Move the resolved question to `## Resolved Questions` as `~~Q: …~~ → A: …`.
4. The proposal is not "drafted" while `## Open Questions` is non-empty. Do not exit, do not append a validation footer, do not suggest the next phase.
5. Never proceed on a silent assumption. If an answer changes a Proposed Changes row, edit the row. If it changes a Risk, edit the risk. If it changes Rollback, edit Rollback.

### Step 6 — Exit gate (drafted)

Before exiting, verify:

- [ ] Proposal exists at `.shamt-core/proposals/{slug}.md` and is non-empty.
- [ ] **Problem** is concrete and cites at least one specific canonical file / section.
- [ ] **Proposed Changes** lists at least one row, and every row gives a canonical (non-`.claude/`) path.
- [ ] If row count > 10, the Phase 3 note is present.
- [ ] **Risks**, **Rollback Plan**, **Validation Considerations** are filled.
- [ ] **Open Questions** is empty (all questions resolved, with answers folded into the proposal and the originals moved to **Resolved Questions**).
- [ ] No validation footer yet. Phase 2 (`/validate-artifact`) appends it.

If any item fails, return to the relevant step.

### Step 7 — Suggest the next phase

Suggest a context-clear and the next command:

- Row count ≤ 10 → `/clear`, then `/validate-artifact {path}`, where `{path}` is the proposal's actual on-disk path (`proposals/{NN}-{slug}.md` on master, `.shamt-core/proposals/{slug}.md` on child).
- Row count > 10 → `/clear`, then `/validate-artifact {path}` (same path), then `/f2-plan-update-implementation {slug}` (resolves the proposal by bare slug or numbered stem).

## Exit criteria

- `.shamt-core/proposals/{slug}.md` exists, non-empty, no open questions, all Proposed Changes rows on canonical paths.
- The next phase has been suggested in chat.

## Notes

- **Fresh-agent runnable**: the template, the canonical sources cited in Problem, and the prior draft (when re-entering) all live on disk. No conversation history required.
- **`Proposed by:` and `Project context:`** are part of the v2 master/child contract — master-local proposals leave them blank; child-authored proposals fill them in so `/sync-triage-proposals` can attribute the change.
- The proposal **never** edits generated `.claude/` files. That rule is enforced again in Phase 4; surfacing it here keeps Phase 4 honest.
- This command is reused by child projects when they author proposals locally before `/sync-submit-proposal` ships them up. The body is identical on both sides — Phase 9 wires the child-side submission.

---
Validated 2026-05-28 — 4 rounds, 1 adversarial sub-agent confirmed (Phase 8 implementation loop)
Touched 2026-05-28 — added explicit re-entry footer-stripping clarification under Slug resolution so the agent removes a stale Phase 2 footer up front rather than discovering the issue only at the Step 6 exit gate. Re-validated under the Phase 8 implementation-validation loop (1 primary clean round + 1 adversarial sub-agent confirmed).
Touched 2026-06-02 — added three input modes (blank / free-text blurb / existing f0 draft) and the optional `[blurb]` argument; new f0-draft ingestion branch under Slug resolution (normalize the f0 marker to `Draft`, develop the Scratch Notes, no extend/overwrite prompt). Per proposals/audit-continuous-f0-draft-capture.md.

<!-- Managed by Shamt — do not edit. Regenerate from shamt-core/host/templates/claude/commands/f1-propose-update.md. -->
