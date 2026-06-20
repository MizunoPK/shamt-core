---
description: Feature stage-0 draft — single-stub incremental producer under an existing epic, f0-style bare capture into `epics/{epic-folder}/features/{ID}-{slug}-{brief}/feature.md` (Scratch Notes + draft status); suggests `/pf1-define`
---

# /pf0-draft

**Purpose:** Quickly create one **DRAFT** feature stub under an existing epic — a title plus the supplied `blurb` written into a **Scratch Notes (stage-0 capture)** section — marked as an unrefined idea capture. pf0 is the **single-stub incremental** producer: write **one** feature stub without re-running `/pe3-decompose` and without re-gating the whole batch. pf0 runs **no** open-questions dialog and writes **no** formal Success Criteria structure; it is the fast pre-feature stage. The full drafting pass (Goal + Success Criteria + Scope / Non-Scope + deep dialog, with the open-questions dialog) is deferred to `/pf1-define {slug}`, which ingests a pf0 draft as its intake.

**Purpose:** The single-stub *incremental* producer — write **one** feature stub under an already-decomposed (or any existing) epic without re-running `/pe3-decompose` and without re-gating the whole batch. Contrast explicitly with `/pe3-decompose` (the batch producer).

**Recommended model:** Cheap (Haiku). pf0 is mechanical: resolve an epic slug, allocate an ID, seed a file from the template, drop the blurb into Scratch Notes. No design judgment. See [`reference/model_selection.md`](../../../../reference/model_selection.md).

---

## Usage

```
/pf0-draft {epic-slug} [feature-slug] [blurb]
```

## Arguments

- `{epic-slug}` (required) — the parent epic slug. Resolved against the epic tree per §PO-tree resolution.
- `[feature-slug]` (optional) — descriptive kebab-case slug for the new feature. If omitted, derived from the blurb.
- `[blurb]` (optional) — free-text describing the feature idea. Written verbatim (or lightly tidied) into the **Scratch Notes (stage-0 capture)** section. If omitted, pf0 writes an empty Scratch Notes section with a fill-in prompt.

## Prerequisites

- `epics/{epic-slug}-*/epic.md` exists (the target parent epic). If not, halt and direct the user to `/pe1-define {epic-slug}` first.
- `templates/feature.template.md` exists (the source of truth for feature shape, including the draft-status marker convention).

## Slug resolution

Features are nested folders under epics. pf0 resolves the target epic folder first per §PO-tree resolution, then writes the feature stub under it. The target folder is `epics/{epic-folder}/features/{ID}-{feature-slug}-{brief}/`.

**Slug-collision rule — non-destructive, non-interactive.** pf0 **never overwrites** and **never prompts**. Before writing, check whether `{feature-slug}` already exists globally across the feature tree per §PO-tree resolution (a tree-wide feature glob). If the slug is taken anywhere, halt and ask for a different slug (PO-flow slugs are user-chosen and globally unique, matching `/pe3-decompose` semantics, not `/f0-draft-proposal`'s numeric-suffix fallback).

## Step-by-step

### Step 1 — Resolve the parent epic

1. Resolve `{epic-slug}` to its epic folder per §PO-tree resolution.
2. If not found, halt and direct the user to `/pe1-define {epic-slug}` first.

### Step 2 — Allocate the ticket ID + slug

1. Allocate a ticket ID `T{N}` per [`templates/SHAMT_RULES.template.md`](../../../../templates/SHAMT_RULES.template.md) §**# Ticket IDs** *Allocation*.
2. Confirm the feature slug (derive from the blurb if not given). The slug is globally unique — detect collisions per §PO-tree resolution; halt and ask for a different slug on collision.

### Step 3 — Seed the feature stub

1. Read the feature template (`templates/feature.template.md`) for the current shape.
2. Ask the user for a 2–4-word **brief description** of the feature, or derive it from the blurb if supplied.
3. Create the folder `epics/{epic-folder}/features/{ID}-{feature-slug}-{brief}/` and write `feature.md` with the **identical core stub-section shape the decompose command writes** (per `/pe3-decompose`'s Step 8 stub-section contract):
   - **H1:** `# Feature {feature-slug}`.
   - **Ticket ID line:** `**Ticket ID:** T{N}` (the allocated ID).
   - **Status marker line (additive draft overlay):** `**Status:** Draft (f0 — feature-idea capture, unrefined)` (directly under the `**Ticket ID:**` line; the distinct draft marker, detectable by `/pf1-define` for ingestion).
   - **`## Goal` section:** the one-liner from the blurb.
   - **`## Scope / Non-Scope` section:** an initial boundary (in/out) from the blurb context, or "To be refined by `/pf1-define`" as a placeholder.
   - **`## Decomposition Context` section:** "none" (to be deepened later) or initial breadth bullets (dependencies, shared context, boundary rationale) if known.
   - **`## Open Questions` section:** left empty (to be surfaced by `/pf1-define`).
   - **`## Success Criteria` section:** left empty (to be drafted by `/pf1-define`).
   - **`## Target Stories` section:** left empty (to be filled by `/pf3-decompose`).
   - **`## Sequencing & Parallelization` section:** left empty (to be filled by `/pf3-decompose`).
   - **No** `Validated …` footer — that comes from `/validate-artifact` once `/pf1-define` finishes.
   - **Add the `## Scratch Notes (stage-0 capture)` section** (the shared PO-stage-0 heading string) holding the `blurb` verbatim (or a fill-in prompt if no blurb). **This is the additive draft-only overlay** — `/pf1-define` detects it and strips it on ingestion.

### Step 4 — Append to the parent epic's Target Features list

1. Read the parent epic's `epic.md`.
2. Locate the `## Target Features` section.
3. **Additively append** one line (do not rewrite the section wholesale): `` `{feature-slug}` — {one-line goal} ``.
4. **Do NOT rewrite** `## Sequencing & Parallelization` — additive append only, preserving the existing `Decomposed YYYY-MM-DD — …` parent line format (per proposal regression-risk mitigation).

### Step 5 — Exit

State the exit clearly:

```text
pf0 draft feature captured at epics/{epic-folder}/features/{ID}-{feature-slug}-{brief}/feature.md (Status: Draft (f0 — feature-idea capture, unrefined)).
Appended to parent epic's Target Features list.
Unrefined — no open-questions dialog ran and no Success Criteria were drafted.
Next: /pf1-define {feature-slug} to flesh it out.
```

## Exit criteria

- `epics/{epic-folder}/features/{ID}-{feature-slug}-{brief}/feature.md` exists with the stub shape (Goal, Scope/Non-Scope, Decomposition Context populated or placeholder; Open Questions / Success Criteria / Target Stories / Sequencing empty), the Status draft marker, and a Scratch Notes section.
- Parent epic's `## Target Features` section has the feature appended (one line; no wholesale rewrite).
- No formal open-questions dialog run.
- No `Validated …` footer.

## Notes

- **Single-stub incremental.** This is the feature-level analogue of the former tech-story fast-path (story-level fast-path) — add one more feature without re-decomposing the whole epic.
- **Non-destructive by construction.** The collision halt reflects the PO-flow design where slugs are user-chosen and globally unique.
- **Preserve re-decomposition partition structure.** Step 4's additive-append rule preserves the `Decomposed YYYY-MM-DD — …` line format that `/pe3-decompose` reads on re-entry for the re-decomposition partition logic (Kept / New / Orphaned).
- **Fresh-agent runnable** — the template and the supplied blurb are sufficient. No conversation history required.

---

Created 2026-06-14 — by /f3-implement-update for proposals/26-po-draft-stub-skills-incremental-decomposition.md (Phase 1).

<!-- Managed by Shamt — do not edit. Regenerate from shamt-core/host/templates/claude/commands/pf0-draft.md. -->
