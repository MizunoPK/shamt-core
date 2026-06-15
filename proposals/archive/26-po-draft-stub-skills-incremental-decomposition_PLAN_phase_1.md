# Implementation Plan — Phase 1: New draft/define command + skill CREATEs

**Proposal:** proposals/26-po-draft-stub-skills-incremental-decomposition.md
**Index:** proposals/26-po-draft-stub-skills-incremental-decomposition_PLAN.md
**Source rows:** 1–8 (section A)
**Operations:** 8 CREATE (4 commands + 4 mirror skills)

> Read the index's Pre-execution checklist first. All paths canonical; never touch `.claude/`.

## Files manifest

| # | Path | Operation | Sibling / template |
|---|------|-----------|---------------------|
| 1 | `shamt-core/host/templates/claude/commands/pe0-draft.md` | CREATE | structural mirror of `commands/f0-draft-proposal.md` (f0-style capture), adapted to the epic altitude |
| 2 | `shamt-core/host/templates/claude/skills/pe0-draft/SKILL.md` | CREATE | mirror of `skills/f0-draft-proposal/SKILL.md` shape |
| 3 | `shamt-core/host/templates/claude/commands/pf0-draft.md` | CREATE | mirror of `pe0-draft.md` (this phase) + single-stub append contract from `commands/p2-decompose-epic.md` Step 8 |
| 4 | `shamt-core/host/templates/claude/skills/pf0-draft/SKILL.md` | CREATE | mirror of `skills/pe0-draft/SKILL.md` |
| 5 | `shamt-core/host/templates/claude/commands/ps0-draft.md` | CREATE | absorbs `commands/p6-draft-tech-story.md` + single-stub append contract from `commands/p4-decompose-feature.md` Step 8 |
| 6 | `shamt-core/host/templates/claude/skills/ps0-draft/SKILL.md` | CREATE | mirror of `skills/pf0-draft/SKILL.md` (Step 4) + `skills/p6-draft-tech-story/SKILL.md` trigger phrasing |
| 7 | `shamt-core/host/templates/claude/commands/ps1-define.md` | CREATE | structural mirror of `commands/p3-start-feature.md` (define + dialog) with an inline Pattern-1 validation loop |
| 8 | `shamt-core/host/templates/claude/skills/ps1-define/SKILL.md` | CREATE | mirror of `skills/p3-start-feature/SKILL.md` |

## Shared CREATE conventions (apply to every step below)

- **Stage-0 draft overlay contract (`/pe0-draft`, `/pf0-draft`, `/ps0-draft`)** — every stage-0 draft producer writes the **same core stub sections the decompose commands emit** (the Goal/scope one-liner, `## Decomposition Context` where applicable, parentage-by-folder-path, and the allocated `**Ticket ID:**`) **plus two additive draft-only elements**: (a) a `**Status:** Draft (f0 — {epic|feature|story}-idea capture, unrefined)` marker line directly beneath the `**Ticket ID:** {ID}` line, and (b) a `## Scratch Notes (stage-0 capture)` section holding the blurb. This is an **f0-style overlay** (the proposal Problem §line 27 calls draft "an `/f0`-style bare-bones capture"; Resolved Question line 165 specifies "a distinct draft status" + Scratch-Notes idea capture ingested the way `/f1-propose-update` ingests an f0 draft). The marker + Scratch Notes are **additive** — the corresponding define command (`/pe1-define` / `/pf1-define` / `/ps1-define`) detects the marker (PRESENT → ingest: seed from Scratch Notes, then **strip both the marker and the Scratch Notes section on completion**, exactly like `/f1-propose-update`; ABSENT → the seed-from-scratch / bare-decompose-stub path, unchanged). **This is NOT a stub-shape parity violation:** the *core* stub sections a draft writes match the decompose output byte-for-byte; the marker + Scratch Notes are a draft-only overlay removed on ingestion, so the decompose commands (`/pe2-decompose` / `/pf2-decompose`) stay **unchanged** and never add the marker. The heading string is **`## Scratch Notes (stage-0 capture)`** — the intentional PO-stage-0 variant of the DIFFERENT Scratch Notes heading `/f0-draft-proposal` writes, `## Scratch Notes (f0 capture)` (the heading f0's Step 2 describes in [`commands/f0-draft-proposal.md`](../host/templates/claude/commands/f0-draft-proposal.md) around line 63, where running prose instructs writing "a `## Scratch Notes (f0 capture)` section" — that line is the describing prose, not a literal heading line) — used identically across all three stage-0 producers; it is the intentional, shared PO-stage capture heading, deliberately distinct from the framework-update f0 heading.
- **Cross-phase dependency (decompose-command shape) — read this if building Phase 1 alone.** Steps 3 and 5 below state the draft stubs match "the identical stub-section shape `/pe2-decompose` / `/pf2-decompose` writes". Those decompose commands are the **renamed** `/p2-decompose-epic` / `/p4-decompose-feature` (proposal rows 11 & 15, landed in a **later** Phase of this plan). When building Phase 1 in isolation the renamed targets may not yet exist on disk — the authoritative stub-section contract to mirror is therefore the **pre-rename** canonical body: `commands/p2-decompose-epic.md` Step 8 (feature stubs) and `commands/p4-decompose-feature.md` Step 8 (story stubs). Mirror the on-disk pre-rename contract; the cross-references in the new draft bodies should name the post-rename commands (`/pe2-decompose` / `/pf2-decompose`) since those are the names that ship.
- **Front-matter `description:`** — each command file opens with a YAML front-matter block `---\ndescription: …\n---` matching the one-line description in the proposal's row (rows 1, 3, 5, 7). Each skill `SKILL.md` opens with `---\nname: {command-name}\ndescription: |\n  …\n---` mirroring the sibling skill's front-matter shape.
- **Trailing managed footer** — every new command file ends with exactly:
  `<!-- Managed by Shamt — do not edit. Regenerate from shamt-core/host/templates/claude/commands/{name}.md. -->`
  every new skill file ends with:
  `<!-- Managed by Shamt — do not edit. Regenerate from shamt-core/host/templates/claude/skills/{name}/SKILL.md. -->`
- **No validation footer** on any new command/skill body (those carry no `Validated …` line; that is for proposals/specs/plans, not command bodies). The skills end with the managed comment only; commands may carry a one-line `Created …` provenance line above the managed comment matching the f0 sibling's convention (`commands/f0-draft-proposal.md` line 94).
- **Path discipline** — every cross-reference inside these bodies uses canonical relative paths (`../../commands/…`, `../../../../reference/…`, `../../../../../templates/…`) exactly as the cited siblings do; never `.claude/`.

---

## Step 1 — CREATE `commands/pe0-draft.md` (epic stage-0 draft)

**Operation:** CREATE
**File:** `shamt-core/host/templates/claude/commands/pe0-draft.md`
**Sibling to mirror:** `shamt-core/host/templates/claude/commands/f0-draft-proposal.md` (the f0-style bare capture pattern).

**Content contract (mechanical — mirror the f0 body, retarget to the epic altitude):**

- **H1:** `# /pe0-draft`.
- **Front-matter `description:`** = proposal row 1 one-liner: "Epic stage-0 draft: f0-style bare epic-idea capture into `epics/{ID}-{slug}-{brief}/epic.md` (Scratch Notes + draft status), runnable any time; suggests `/pe1-define`."
- **Purpose:** quick-capture an unrefined DRAFT epic from a one-line blurb, no open-questions dialog, no decomposition — the PO-altitude analogue of `/f0-draft-proposal`. The flesh-out pass (Goal + Success Criteria + Scope/Non-Scope via the open-questions dialog) is deferred to `/pe1-define {slug}`, which **ingests** the draft.
- **Recommended model:** Cheap (Haiku) — mechanical capture, no design judgment (mirror f0 line 14; cite `reference/model_selection.md` via `../../../../reference/model_selection.md`).
- **Usage:** `/pe0-draft {slug} [blurb]` (epics are top-level — no parent-slug argument; contrast with `/pf0-draft`/`/ps0-draft` which take a parent slug).
- **Prerequisites:** resolves the epics tree per `templates/SHAMT_RULES.template.md` §PO-tree resolution (cite via `../../../../templates/SHAMT_RULES.template.md`); allocates a ticket ID `T{N}` per the `# Ticket IDs` rule (max across the tree + 1) and writes `epics/{ID}-{slug}-{brief}/epic.md`.
- **Step-by-step:** (1) resolve slug + allocate ticket ID + check global slug uniqueness per §PO-tree resolution (halt-and-ask on collision, same as `/p6` Step 2.2); (2) seed `epic.md` from `templates/epic.template.md`, applying the **Stage-0 draft overlay contract** (Shared CREATE conventions above): insert **a new header line `**Status:** Draft (f0 — epic-idea capture, unrefined)` directly under the `**Ticket ID:** {ID}` line** (the epic template carries no Status field today; add this one line — the additive draft marker, paralleling f0's `Status: Draft (f0 — audit capture, unrefined)` and detectable by `/pe1-define` for ingestion), a banner line directing the user to `/pe1-define {slug}` immediately under the header block, and a `## Scratch Notes (stage-0 capture)` section (the shared heading string per the overlay contract) holding the blurb verbatim; leave Goal / Success Criteria / Scope-Non-Scope / Target Features / Sequencing as template placeholders; **no** validation footer. The marker + Scratch Notes are the additive draft-only overlay `/pe1-define` strips on ingestion — not a deviation from the epic stub shape decompose-side commands consume.
- **Exit:** report the captured path + final slug; suggest `/pe1-define {slug}` to flesh it out.
- **Non-destructive collision rule:** mirror f0 — never overwrite; on slug collision halt and ask for a different slug (PO-flow slugs are user-chosen and globally unique, unlike f0's auto-suffix; match `/p6` Step 2.2 semantics, **not** f0's numeric suffix).
- **Trailing footer:** the two-line `Created …` + managed comment per Shared CREATE conventions.

**Verification:**
- `test -f shamt-core/host/templates/claude/commands/pe0-draft.md`
- `grep -F '# /pe0-draft' shamt-core/host/templates/claude/commands/pe0-draft.md` returns one match.
- `grep -F 'Regenerate from shamt-core/host/templates/claude/commands/pe0-draft.md' shamt-core/host/templates/claude/commands/pe0-draft.md` returns one match.
- `grep -F 'Scratch Notes (stage-0 capture)' shamt-core/host/templates/claude/commands/pe0-draft.md` returns ≥1 match (shared overlay heading string per Stage-0 draft overlay contract).
- `grep -F 'Draft (f0 — epic-idea capture, unrefined)' shamt-core/host/templates/claude/commands/pe0-draft.md` returns ≥1 match (additive draft marker).
- `grep -c '\.claude/' shamt-core/host/templates/claude/commands/pe0-draft.md` returns `0`.

---

## Step 2 — CREATE `skills/pe0-draft/SKILL.md` (mirror skill)

**Operation:** CREATE
**File:** `shamt-core/host/templates/claude/skills/pe0-draft/SKILL.md`
**Sibling to mirror:** `shamt-core/host/templates/claude/skills/f0-draft-proposal/SKILL.md`.

**Content contract:**
- Front-matter `name: pe0-draft` + a `description: |` block summarizing the epic stage-0 draft (natural-language triggers: "draft an epic idea", "quick-capture an epic", "stub an epic").
- Body: "Mirrors the `/pe0-draft {slug}` slash command. Same canonical body, two host wirings." + a short numbered summary pointing to `commands/pe0-draft.md` via `../../commands/pe0-draft.md`; references to the rules use `../../../../../templates/SHAMT_RULES.template.md`.
- Trailing skill managed comment: `Regenerate from shamt-core/host/templates/claude/skills/pe0-draft/SKILL.md.`

**Verification:**
- `test -f shamt-core/host/templates/claude/skills/pe0-draft/SKILL.md`
- `grep -F 'name: pe0-draft' shamt-core/host/templates/claude/skills/pe0-draft/SKILL.md` returns one match.
- `grep -c '\.claude/' shamt-core/host/templates/claude/skills/pe0-draft/SKILL.md` returns `0`.

---

## Step 3 — CREATE `commands/pf0-draft.md` (feature stage-0 draft under an existing epic)

**Operation:** CREATE
**File:** `shamt-core/host/templates/claude/commands/pf0-draft.md`
**Siblings to mirror:** `commands/pe0-draft.md` (Step 1, capture shape) **plus** the feature-stub section contract from `commands/p2-decompose-epic.md` Step 8 (the "New partition" populated-fields bullet, lines 111–117) and the parent-epic append shape from its Step 9 (lines 120–130). (Cross-phase note: `/pe2-decompose` is the renamed form of this command — see the Shared CREATE conventions cross-phase-dependency bullet; mirror the on-disk pre-rename body.)

**Content contract:**
- **H1:** `# /pf0-draft`. Front-matter `description:` = proposal row 3 one-liner.
- **Usage:** `/pf0-draft {epic-slug} [feature-slug] [blurb]` — the **required** `{epic-slug}` names the existing parent epic to place the new feature stub under.
- **Purpose:** the single-stub *incremental* producer — write **one** feature stub under an already-decomposed (or any existing) epic without re-running `/pe2-decompose` and without re-gating the whole batch. Contrast explicitly with `/pe2-decompose` (the batch producer) and the re-decomposition partition.
- **Step-by-step:**
  1. Resolve `{epic-slug}` to its epic folder per §PO-tree resolution; halt and direct to `/pe1-define {epic-slug}` if absent.
  2. Allocate ticket ID `T{N}` (max across the tree + 1) and confirm a globally-unique `{feature-slug}` (halt-and-ask on collision).
  3. Write the feature stub at `epics/{epic-folder}/features/{ID}-{feature-slug}-{brief}/feature.md` from `templates/feature.template.md` with **the identical core stub-section shape the decompose command writes** (the pre-rename `/p2-decompose-epic` Step 8 contract, lines 111–117 — the post-rename name is `/pe2-decompose`; cite it) — populated `## Goal` (from blurb), populated `## Scope / Non-Scope` boundary + `## Decomposition Context` breadth section (or "none"), and **all other sections (`Open Questions`, `Success Criteria`, `Target Stories`, `Sequencing & Parallelization`) left empty**; **no** `Validated …` footer. **Then apply the Stage-0 draft overlay** (Shared CREATE conventions): insert **a new header line `**Status:** Draft (f0 — feature-idea capture, unrefined)` directly under the `**Ticket ID:** {ID}` line** plus a `## Scratch Notes (stage-0 capture)` section (shared heading string) holding the blurb, so `/pf1-define` can detect-and-ingest it. The marker + Scratch Notes are the **additive draft-only overlay** define strips on ingestion — **not** a deviation from the decompose stub shape (the decompose command stays unchanged and adds no marker); the core sections above still match decompose output, so define's Mode-A ingestion stays uniform whether the stub came from draft or decompose.
  4. **Append** the new feature to the parent epic's `## Target Features` list (one line: feature slug + one-line goal) **without** rewriting the section wholesale and **without** re-emitting `## Sequencing & Parallelization` — additive append only, preserving the existing `Decomposed YYYY-MM-DD — …` parent line format the re-decomposition partition reads (proposal Regression-risk mitigation).
  5. Exit: report the stub path; suggest `/pf1-define {feature-slug}`.

**Verification:**
- `test -f shamt-core/host/templates/claude/commands/pf0-draft.md`
- `grep -F '# /pf0-draft' shamt-core/host/templates/claude/commands/pf0-draft.md` returns one match.
- `grep -F 'Target Features' shamt-core/host/templates/claude/commands/pf0-draft.md` returns ≥1 match (the additive-append rule is present).
- `grep -F 'Scratch Notes (stage-0 capture)' shamt-core/host/templates/claude/commands/pf0-draft.md` returns ≥1 match (shared overlay heading string).
- `grep -F 'Draft (f0 — feature-idea capture, unrefined)' shamt-core/host/templates/claude/commands/pf0-draft.md` returns ≥1 match (additive draft marker).
- `grep -c '\.claude/' shamt-core/host/templates/claude/commands/pf0-draft.md` returns `0`.

---

## Step 4 — CREATE `skills/pf0-draft/SKILL.md` (mirror skill)

**Operation:** CREATE
**File:** `shamt-core/host/templates/claude/skills/pf0-draft/SKILL.md`
**Sibling to mirror:** `skills/pe0-draft/SKILL.md` (Step 2).

**Content contract:** front-matter `name: pf0-draft` + `description: |` (triggers: "draft one more feature under an epic", "add a feature stub", "incremental feature"); body mirrors the command via `../../commands/pf0-draft.md`; note the single-stub-vs-batch distinction from `/pe2-decompose`.

**Verification:**
- `test -f shamt-core/host/templates/claude/skills/pf0-draft/SKILL.md`
- `grep -F 'name: pf0-draft' shamt-core/host/templates/claude/skills/pf0-draft/SKILL.md` returns one match.
- `grep -c '\.claude/' shamt-core/host/templates/claude/skills/pf0-draft/SKILL.md` returns `0`.

---

## Step 5 — CREATE `commands/ps0-draft.md` (story stage-0 draft; absorbs `/p6-draft-tech-story`)

**Operation:** CREATE
**File:** `shamt-core/host/templates/claude/commands/ps0-draft.md`
**Siblings to mirror:** `commands/p6-draft-tech-story.md` (the entire tech-story fast-path body — folded in) **plus** the story-stub section contract from `commands/p4-decompose-feature.md` Step 8 (lines 127–141 — the "New partition" populated-fields bullet) + the parent-feature append from its Step 9 (lines 143–153). (Cross-phase note: `/pf2-decompose` is the renamed form of `/p4-decompose-feature` — see the Shared CREATE conventions cross-phase-dependency bullet; mirror the on-disk pre-rename body.)

**Content contract:**
- **H1:** `# /ps0-draft`. Front-matter `description:` = proposal row 5 one-liner (note it absorbs `/p6-draft-tech-story`).
- **Usage:** `/ps0-draft {feature-slug | bugs | quick-wins} [story-slug] [blurb]` — the parent selector is **either** an arbitrary feature slug **or** one of the two standing reserved names `bugs` / `quick-wins` (the absorbed tech-story path).
- **Purpose:** the single-story-stub incremental producer. Two parent modes, both writing the **same story-ticket stub shape** `/pf2-decompose` emits:
  - **Feature-parent mode** — `{feature-slug}` resolves to an existing feature; write one story stub under it and additively append to that feature's `## Target Stories`.
  - **Tech-story mode (absorbs `/p6-draft-tech-story`)** — `bugs` / `quick-wins` resolves the standing Tech Stories epic's reserved feature (`epics/{tech-stories-folder}/features/{bugs|quick-wins}/`, seeded by `init-shamt.sh` / `import-shamt.sh`); write the stub there. Carry forward `/p6`'s tracker-template selection (ado/github/local — `commands/p6-draft-tech-story.md` Step 3 lines 43–49), its standing-fixture prerequisite check (`/p6` Prereqs line 28 — halt + direct to re-run `import-shamt` if the standing containers are absent; `/ps0-draft` does not create them), and its completion-archive note (`/p6` Notes line 63 — finalize via `/e8-finalize-story` moves the story into the feature's `archive/`).
- **Step-by-step:** (1) resolve parent (feature-slug vs reserved `bugs`/`quick-wins`) per §PO-tree resolution; (2) allocate ticket ID + confirm globally-unique story slug (halt-and-ask on collision); (3) write `…/stories/{ID}-{story-slug}-{brief}/ticket.md` from the active tracker's ticket template (template selection per `work_item_tracker`, carried from `/p6` Step 3) with the **same core stub shape the decompose command writes** (pre-rename `/p4-decompose-feature` Step 8, lines 127–141 — post-rename name `/pf2-decompose`): the scope one-liner in the body intake area, `## Decomposition Context` (or "none"), every other template section empty, **no** `Validated …` footer. **Then apply the Stage-0 draft overlay** (Shared CREATE conventions): insert the `**Status:** Draft (f0 — story-idea capture, unrefined)` marker directly under the ticket's `**Ticket ID:** {ID}` line plus a `## Scratch Notes (stage-0 capture)` section (shared heading string) holding the blurb, so `/ps1-define` can detect-and-ingest it. The marker + Scratch Notes are the **additive draft-only overlay** `/ps1-define` strips on ingestion — **not** a deviation from the decompose stub shape (decompose stays unchanged and adds no marker); the core sections match decompose output. (4) additively append to the parent feature's `## Target Stories` (feature-parent mode) without wholesale rewrite — in tech-story mode there is no `## Target Stories` append (the standing features carry no decomposition list; mirror `/p6`'s no-Decomposition-Context note line 49); (5) exit: suggest `/ps1-define {story-slug}`.
- **Deprecation note in body:** state that `/ps0-draft` **replaces** `/p6-draft-tech-story` (a tech story is just a story drafted under the Tech Stories `bugs`/`quick-wins` feature). No legacy alias.

**Verification:**
- `test -f shamt-core/host/templates/claude/commands/ps0-draft.md`
- `grep -F '# /ps0-draft' shamt-core/host/templates/claude/commands/ps0-draft.md` returns one match.
- `grep -E 'bugs|quick-wins' shamt-core/host/templates/claude/commands/ps0-draft.md` returns ≥1 match (tech-story mode folded in).
- `grep -F 'Scratch Notes (stage-0 capture)' shamt-core/host/templates/claude/commands/ps0-draft.md` returns ≥1 match (shared overlay heading string).
- `grep -F 'Draft (f0 — story-idea capture, unrefined)' shamt-core/host/templates/claude/commands/ps0-draft.md` returns ≥1 match (additive draft marker).
- `grep -c '\.claude/' shamt-core/host/templates/claude/commands/ps0-draft.md` returns `0`.

---

## Step 6 — CREATE `skills/ps0-draft/SKILL.md` (mirror skill)

**Operation:** CREATE
**File:** `shamt-core/host/templates/claude/skills/ps0-draft/SKILL.md`
**Siblings to mirror:** `skills/p6-draft-tech-story/SKILL.md` (the tech-story trigger phrasing) + `skills/pf0-draft/SKILL.md` shape.

**Content contract:** front-matter `name: ps0-draft` + `description: |` covering both modes (triggers: "draft a story under a feature", "file a bug", "capture a quick win", "draft a tech story", "add a story stub"); body mirrors the command via `../../commands/ps0-draft.md`; note it absorbs `/p6-draft-tech-story`.

**Verification:**
- `test -f shamt-core/host/templates/claude/skills/ps0-draft/SKILL.md`
- `grep -F 'name: ps0-draft' shamt-core/host/templates/claude/skills/ps0-draft/SKILL.md` returns one match.
- `grep -c '\.claude/' shamt-core/host/templates/claude/skills/ps0-draft/SKILL.md` returns `0`.

---

## Step 7 — CREATE `commands/ps1-define.md` (story stage-1 define, inline Pattern-1 validation)

**Operation:** CREATE
**File:** `shamt-core/host/templates/claude/commands/ps1-define.md`
**Sibling to mirror:** `commands/p3-start-feature.md` (the define + open-questions-dialog + ingest-a-stub shape), retargeted to the **story** altitude and extended with an **inline Pattern-1 validation loop**.

**Content contract:**
- **H1:** `# /ps1-define`. Front-matter `description:` = proposal row 7 one-liner.
- **Recommended model:** Reasoning (Opus) — design/dialog task; cite `reference/model_selection.md`.
- **Purpose:** flesh out the planning `ticket.md` via the open-questions iterative dialog (Principle 2), then run an **inline Pattern-1 validation loop** so the command **stamps the `Validated …` footer itself**. The footer is the readiness signal `/e1-start-story` keys on (proposal Resolved Question line 161 — only story-define folds validation inline; epic/feature define validate separately via `/validate-artifact`).
- **Input modes (mirror p3's three-mode shape):** (A) ingest an existing `/ps0-draft` stub when present — detect the `**Status:** Draft (f0 — story-idea capture, unrefined)` marker (Stage-0 draft overlay), seed from the `## Scratch Notes (stage-0 capture)` section, preserve the scope one-liner + any `## Decomposition Context`, deepen via dialog, then **strip the marker + Scratch Notes on completion** (the f1-style ingestion in the overlay contract); (B) standalone — seed + flesh from scratch when no prior draft / no marker; (C) tracker-seeded when the active profile supports Story. Mode disambiguation is filesystem-first, exactly as p3 documents.
- **Inline Pattern-1 validation loop — concrete CREATE content (do not paraphrase as intent; write these as the command body's validation section):** the `/ps1-define` body, after the dialog drains `## Open Questions`, runs the **same loop `/validate-artifact` runs** (cite `validate-artifact.md` Steps 1–8 as the source of truth rather than re-deriving the dimensions; `validate-artifact.md` is a sibling in the SAME `host/templates/claude/commands/` directory, so the in-body relative-path citation is simply `validate-artifact.md` — equivalently `./validate-artifact.md` — NOT `../host/templates/…`):
  1. **Primary clean round** — the primary agent self-reviews `ticket.md` against the applicable Pattern-1 dimensions (per `SHAMT_RULES.template.md` Pattern 1), tracking `consecutive_clean` starting at 0 (clean → +1; not clean → reset to 0 and re-draft), exactly as `/validate-artifact` Steps 1–6 / 5 / 6 do.
  2. **Standard exit (not Quick)** — story-define always takes the **Standard** path: on `consecutive_clean = 1` it spawns **one independent adversarial `validation-checker` sub-agent (Haiku tier)** that re-reads `ticket.md` from scratch with zero bias and replies `CONFIRMED: Zero issues found after adversarial review.` only if clean — mirroring `/validate-artifact` Step 7. **No one-LOW allowance**: any sub-agent finding (even a single LOW) resets `consecutive_clean = 0` and returns to the primary round.
  3. **Stamp the footer** — on `consecutive_clean = 1` primary-clean **plus** the sub-agent `CONFIRMED`, append the exact **two-line footer block** (a `---` delimiter line followed by the `Validated …` line, matching `/validate-artifact` Step 8 verbatim — see `validate-artifact.md` lines 149–152) to `ticket.md`:

     ```text
     ---
     Validated {YYYY-MM-DD} — N rounds, 1 adversarial sub-agent confirmed
     ```

     This is the precise footer `/e1-start-story`'s ready-ticket pickup branch keys on (proposal row 21 / Resolved Question line 166). Stamp the full block — the `---` delimiter is part of the footer, not optional.
  The command body specifies this by **reference to `/validate-artifact`** for the loop mechanics and **names the `ticket.md` footer** as the stamped output — it does not re-enumerate the dimensions or re-implement the checker.
- **Step-by-step:** resolve slug → detect Mode A (draft-overlay marker present) vs standalone vs tracker → open-questions dialog draining `## Open Questions` → (Mode A: strip the overlay marker + Scratch Notes) → **inline Pattern-1 validation loop above (primary clean + Haiku `validation-checker` CONFIRMED, no one-LOW allowance)** → stamp the two-line `---` + `Validated {YYYY-MM-DD} — N rounds, 1 adversarial sub-agent confirmed` footer block (per loop item 3) on `ticket.md` → exit suggesting `/e1-start-story {slug}` (the ready-ticket pickup branch). Cite Pattern 1 normatively from `templates/SHAMT_RULES.template.md` (in-body path `../../../../templates/SHAMT_RULES.template.md`) and the loop mechanics from the same-directory sibling `validate-artifact.md`.
- **Note:** preserve the `**Ticket ID:**` header verbatim (decomposition-owned), same as p3.

**Verification:**
- `test -f shamt-core/host/templates/claude/commands/ps1-define.md`
- `grep -F '# /ps1-define' shamt-core/host/templates/claude/commands/ps1-define.md` returns one match.
- `grep -F 'validation-checker' shamt-core/host/templates/claude/commands/ps1-define.md` returns ≥1 match (inline adversarial confirmation present).
- `grep -F 'validate-artifact' shamt-core/host/templates/claude/commands/ps1-define.md` returns ≥1 match (loop mechanics cited, not re-derived).
- `grep -F 'adversarial sub-agent confirmed' shamt-core/host/templates/claude/commands/ps1-define.md` returns ≥1 match (the exact `Validated …` footer string `/e1-start-story` keys on is specified).
- `grep -F 'e1-start-story' shamt-core/host/templates/claude/commands/ps1-define.md` returns ≥1 match (next-phase handoff).
- `grep -c '\.claude/' shamt-core/host/templates/claude/commands/ps1-define.md` returns `0`.

---

## Step 8 — CREATE `skills/ps1-define/SKILL.md` (mirror skill)

**Operation:** CREATE
**File:** `shamt-core/host/templates/claude/skills/ps1-define/SKILL.md`
**Sibling to mirror:** `skills/p3-start-feature/SKILL.md`.

**Content contract:** front-matter `name: ps1-define` + `description: |` (triggers: "define a story", "flesh out a ticket", "polish the planning ticket", "ready a story for the engineer"); body mirrors the command via `../../commands/ps1-define.md`; note the inline validation loop and the `/e1-start-story` handoff.

**Verification:**
- `test -f shamt-core/host/templates/claude/skills/ps1-define/SKILL.md`
- `grep -F 'name: ps1-define' shamt-core/host/templates/claude/skills/ps1-define/SKILL.md` returns one match.
- `grep -c '\.claude/' shamt-core/host/templates/claude/skills/ps1-define/SKILL.md` returns `0`.

---

## Row → step mapping (Phase 1)

| Proposal row | Plan step |
|---|---|
| 1 (`pe0-draft.md` CREATE) | Step 1 |
| 2 (`pe0-draft/SKILL.md` CREATE) | Step 2 |
| 3 (`pf0-draft.md` CREATE) | Step 3 |
| 4 (`pf0-draft/SKILL.md` CREATE) | Step 4 |
| 5 (`ps0-draft.md` CREATE) | Step 5 |
| 6 (`ps0-draft/SKILL.md` CREATE) | Step 6 |
| 7 (`ps1-define.md` CREATE) | Step 7 |
| 8 (`ps1-define/SKILL.md` CREATE) | Step 8 |

---
Validated 2026-06-14 — batch-validated (Standard path), 1 adversarial sub-agent confirmed
