---
description: Story stage-0 draft (replaces the former Tech Stories fast-path command) — single-story-stub incremental producer under a feature or under standing Tech Stories (bugs/quick-wins), f0-style bare capture into tracker template (Scratch Notes + draft status); suggests `/ps1-define`
---

# /ps0-draft

**Purpose:** Quickly create one **DRAFT** story-ticket stub under an existing feature or under the standing Tech Stories epic (bugs / quick-wins fast-path) — a scope one-liner plus the supplied `blurb` written into a **Scratch Notes (stage-0 capture)** section — marked as an unrefined idea capture. ps0 is the **single-story-stub incremental** producer: write **one** story stub without re-running `/pf2-decompose` and without re-gating the whole batch. ps0 runs **no** open-questions dialog and writes **no** formal Acceptance Criteria structure; it is the fast pre-story stage. The full drafting pass (scope one-liner + spec + deep dialog, with the open-questions dialog) is deferred to `/ps1-define {slug}`, which ingests a ps0 draft as its intake.

**Deprecation note:** `/ps0-draft` **replaces the former Tech Stories fast-path command**. A tech story is just a story drafted under the Tech Stories epic's standing `bugs` / `quick-wins` feature. The fast-path semantics are now unified under ps0.

**Recommended model:** Cheap (Haiku). ps0 is mechanical: pick a parent, allocate an ID, seed a file from the active tracker's ticket template, drop the blurb into Scratch Notes. No design judgment. See [`reference/model_selection.md`](../../../../reference/model_selection.md).

---

## Usage

```
/ps0-draft {feature-slug | bugs | quick-wins} [story-slug] [blurb]
```

## Arguments

- `{feature-slug | bugs | quick-wins}` (required) — the parent selector. Either an arbitrary feature slug (resolves to an existing feature per §PO-tree resolution) **or** one of the two standing reserved names `bugs` / `quick-wins` (the Tech Stories fast-path).
- `[story-slug]` (optional) — descriptive kebab-case slug for the new story. If omitted, derived from the blurb.
- `[blurb]` (optional) — a one-line scope description of the story, used as the intake area in the stub. If omitted, ps0 writes an empty intake with a fill-in prompt.

## Prerequisites

- `.shamt-core/shamt-config.json` exists (for the `work_item_tracker` default).
- **Feature-parent mode:** `epics/*/features/{feature-slug}-*/feature.md` exists (the target parent feature), resolved per §PO-tree resolution.
- **Tech-story mode:** The standing **Tech Stories** epic exists at `epics/{tech-stories-folder}/` with `features/bugs/` and `features/quick-wins/` (seeded by `init-shamt.sh` / `import-shamt.sh`). If absent, halt and direct the user to re-run `import-shamt` — `/ps0-draft` does not create the standing containers itself.

## Parent modes

ps0 supports **two parent modes**, both writing the **same story-ticket stub shape `/pf2-decompose` emits**:

1. **Feature-parent mode** — `{feature-slug}` resolves to an existing feature. Write one story stub under it and additively append to that feature's `## Target Stories`.
2. **Tech-story mode** (absorbs the former tech-story fast-path) — `bugs` / `quick-wins` resolves the standing Tech Stories epic's reserved feature (`epics/{tech-stories-folder}/features/{bugs|quick-wins}/`). Write the stub there. Carry forward the former tech-story fast-path's tracker-template selection (ado / github / local — read `work_item_tracker` from `.shamt-core/shamt-config.json`), its standing-fixture prerequisite check (halt + direct to re-run `import-shamt` if the standing containers are absent), and its completion-archive note (finalize via `/e8-finalize-story` moves the story into the feature's `archive/`).

## Step-by-step

### Step 1 — Resolve the parent

1. If `{parent-selector}` is `bugs` or `quick-wins`, resolve to the standing Tech Stories epic's feature per §PO-tree resolution. Halt and direct to `import-shamt` if the standing containers are absent.
2. Otherwise, resolve `{parent-selector}` as a feature slug per §PO-tree resolution. If not found, halt and ask for a valid feature slug (or `bugs` / `quick-wins`).

### Step 2 — Allocate the ticket ID + slug

1. Allocate a ticket ID `T{N}` (= `max` of the `^T([0-9]+)-` prefixes across `epics/`, `features/`, `stories/`, + 1 — per **# Ticket IDs**).
2. Confirm the story slug (derive from the blurb if not given). The slug is globally unique — detect collisions per §PO-tree resolution; halt and ask for a different slug on collision.

### Step 3 — Write the ticket stub

1. Read `.shamt-core/shamt-config.json` to determine the `work_item_tracker` (ado / github / local / none).
2. Select the active tracker's per-provider ticket template:
   - **ado** → [`templates/ticket.ado.template.md`](../../../../templates/ticket.ado.template.md)
   - **github** → [`templates/ticket.github.template.md`](../../../../templates/ticket.github.template.md)
   - **local** or **none** → [`templates/ticket.github.template.md`](../../../../templates/ticket.github.template.md) as the **generic baseline**. **Replace the template's `**Tracker profile:** GitHub (see …)` metadata line with `**Tracker profile:** {local|none}` to match the active config.**
3. Ask the user for a 2–4-word **brief description** of the story, or derive it from the blurb if supplied.
4. Create the folder `epics/{parent-feature-folder}/stories/{ID}-{story-slug}-{brief}/` and write `ticket.md` with the **same core stub shape `/pf2-decompose` emits** (per its Step 8 stub-section contract):
   - **Ticket metadata block** — unchanged from the template.
   - **Body intake area** (the paragraph immediately after the metadata block, marked "Paste ticket content here — any format accepted"): write the story's scope one-liner verbatim (from the blurb or prompt).
   - **`## Decomposition Context` section:** "none" (to be refined later) or initial breadth bullets (dependencies on siblings, shared context, boundary rationale) if known. **NOT a depth dump** — acceptance / spec detail is the Engineer flow's job.
   - All other template sections (Summary, Description, Acceptance Criteria, Related Work, Comments, Update History, All Remaining Fields, Open Questions, etc.) are **left empty / placeholder** as they appear in the template.
   - **Add the `## Scratch Notes (stage-0 capture)` section** (the shared PO-stage-0 heading string) holding the `blurb` verbatim (or a fill-in prompt if no blurb). **This is the additive draft-only overlay** — `/ps1-define` detects it and strips it on ingestion.
   - **Add the `**Status:** Draft (f0 — story-idea capture, unrefined)` marker line** directly under the ticket's `**Ticket ID:** {ID}` line (the distinct draft marker, detectable by `/ps1-define` for ingestion).
   - **No** `Validated …` footer — that comes from `/ps1-define` (inline validation loop) once the story is defined.

### Step 4 — Append to the parent feature's Target Stories list

**Feature-parent mode only** (tech-story mode has no `## Target Stories` append — the standing features carry no decomposition list, mirroring the former fast-path's semantics):

1. Read the parent feature's `feature.md`.
2. Locate the `## Target Stories` section.
3. **Additively append** one line (do not rewrite the section wholesale): `` `{story-slug}` — {scope one-liner} ``.

### Step 5 — Exit

State the exit clearly:

```text
ps0 draft story captured at epics/{parent-feature-folder}/stories/{ID}-{story-slug}-{brief}/ticket.md (Status: Draft (f0 — story-idea capture, unrefined)).
{If feature-parent mode: Appended to parent feature's Target Stories list.}
Unrefined — no open-questions dialog ran and no Acceptance Criteria were drafted.
Next: /ps1-define {story-slug} to flesh it out and define the story.
```

## Exit criteria

- `epics/{parent-feature-folder}/stories/{ID}-{story-slug}-{brief}/ticket.md` exists with the ticket template shape (metadata block, body intake area populated with scope one-liner, Decomposition Context placeholder or populated, all other sections empty), the Status draft marker, and a Scratch Notes section.
- **Feature-parent mode:** Parent feature's `## Target Stories` section has the story appended (one line; no wholesale rewrite).
- **Tech-story mode:** No `## Target Stories` append (standing features have no decomposition list).
- No formal open-questions dialog run.
- No `Validated …` footer (validation is `/ps1-define`'s inline responsibility).

## Notes

- **Single-story-stub incremental.** Add one story at a time without re-decomposing the whole feature. Contrast with `/pf2-decompose` (the batch producer).
- **Tech Stories fast-path unified.** `/ps0-draft` absorbs the former tech-story fast-path — the two modes are now one command. A tech story is just a story under the standing Tech Stories epic's `bugs` / `quick-wins` feature.
- **Tracker-template selection per active profile.** Same template-selection semantics as `/pf2-decompose` Step 8 and the former tech-story fast-path.
- **Completion archive for tech stories.** When a tech story is finalized via `/e8-finalize-story`, it is moved into the feature's `archive/` folder — keeping the standing features from growing without bound (same semantics as the former fast-path).
- **Non-destructive by construction.** The collision halt reflects the PO-flow design where slugs are user-chosen and globally unique.
- **Fresh-agent runnable** — the config, tracker templates, and standing epic are sufficient. No conversation history required.

---

Created 2026-06-14 — by /f3-implement-update for proposals/26-po-draft-stub-skills-incremental-decomposition.md (Phase 1).

<!-- Managed by Shamt — do not edit. Regenerate from shamt-core/host/templates/claude/commands/ps0-draft.md. -->
