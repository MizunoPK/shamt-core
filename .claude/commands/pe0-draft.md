---
description: Epic stage-0 draft — f0-style bare epic-idea capture into `epics/{ID}-{slug}-{brief}/epic.md` (Scratch Notes + draft status), runnable any time; suggests `/pe1-define`
---

# /pe0-draft

**Purpose:** Quickly create a bare-minimum **DRAFT** epic file — a title plus the supplied `blurb` written into a **Scratch Notes (stage-0 capture)** section — marked as an unrefined idea capture. pe0 runs **no** open-questions dialog and writes **no** formal Goal / Success Criteria / Scope structure; it is the fast pre-epic stage. The full drafting pass (Goal + Success Criteria + Scope / Non-Scope, with the open-questions dialog) is deferred to `/pe1-define {slug}`, which ingests a pe0 draft as its intake.

Two callers use pe0:

- **A user**, directly, for fast idea capture — the PO-altitude analogue of `/f0-draft-proposal`.

**Recommended model:** Cheap (Haiku). pe0 is mechanical: resolve a slug, seed a file from the template, drop the blurb into Scratch Notes. No design judgment. See [`reference/model_selection.md`](../../../../reference/model_selection.md).

---

## Usage

```
/pe0-draft {slug} [blurb]
```

## Arguments

- `{slug}` (required) — descriptive kebab-case slug for the epic (e.g., `unified-auth-overhaul`, `mobile-sdk-launch`). Descriptive, globally unique — epics are top-level and have no parent-slug argument.
- `[blurb]` (optional) — free-text describing the epic idea. Written verbatim (or lightly tidied) into the **Scratch Notes (stage-0 capture)** section. May name implicated domains informally. If omitted, pe0 writes an empty Scratch Notes section with a fill-in prompt.

## Prerequisites

- An epics folder is reachable at `epics/` (the project's PO work root). If not, halt and direct the user to run this from a project with Shamt initialized.
- `templates/epic.template.md` exists (the source of truth for epic shape, including the draft-status marker convention).

## Slug resolution

Epics are nested folders, not flat files. pe0 resolves the epics directory (always `epics/` in a Shamt project). The target folder is `epics/{ID}-{slug}-{brief}/` (the `{brief}` suffix is derived from the blurb or the user).

**Slug-collision rule — non-destructive, non-interactive.** pe0 **never overwrites** and **never prompts**. Before writing, check whether `{slug}` already exists globally across the epic tree per §PO-tree resolution (a tree-wide epic glob). If the slug is taken anywhere, halt and ask for a different slug (per the PO-flow no-suffix-fallback rule — slugs are user-chosen and globally unique, unlike `/f0-draft-proposal`'s numeric-suffix fallback).

## Step-by-step

### Step 1 — Resolve the target path

1. Confirm the epics folder exists at `epics/`.
2. Apply the slug-collision rule above to detect a global collision. Record the slug.

### Step 2 — Seed a bare-minimum pe0 draft

1. Read the epic template (`templates/epic.template.md`) for the current shape.
2. Allocate a ticket ID `T{N}` per [`templates/SHAMT_RULES.template.md`](../../../../templates/SHAMT_RULES.template.md) §**# Ticket IDs** *Allocation*.
3. Ask the user for a 2–4-word **brief description** of the epic, or derive it from the blurb if supplied.
4. Create the folder `epics/{ID}-{slug}-{brief}/` and write `epic.md` with:
   - **H1:** `# Epic {slug}`.
   - **Ticket ID line:** `**Ticket ID:** T{N}` (the allocated ID).
   - **Status marker line (additive draft overlay):** `**Status:** Draft (f0 — epic-idea capture, unrefined)` (directly under the `**Ticket ID:**` line; the distinct draft marker, detectable by `/pe1-define` for ingestion).
   - **Banner line** immediately under the Ticket ID + Status block:

     ```text
     > **pe0 DRAFT — unrefined capture.** Quick-captured epic idea;
     > not yet through the open-questions dialog. Run
     > `/pe1-define {slug}` to flesh it out.
     ```

   - **A `## Scratch Notes (stage-0 capture)` section** (the shared PO-stage-0 heading string) holding the `blurb` verbatim (or lightly tidied). If no blurb was supplied, write a one-line fill-in prompt.
   - Leave the formal **Goal**, **Success Criteria**, **Scope / Non-Scope**, **Target Features**, and **Sequencing & Parallelization** sections as template placeholders (not filled). **Do not** run the open-questions dialog, fill structured content, or append a validation footer — all of that is `/pe1-define`'s job.

### Step 3 — Exit

State the exit clearly:

```text
pe0 draft captured at epics/{ID}-{slug}-{brief}/epic.md (Status: Draft (f0 — epic-idea capture, unrefined)).
Unrefined — no open-questions dialog ran and no structured content was filled.
Next: /pe1-define {slug} to flesh it out.
```

## Exit criteria

- `epics/{ID}-{slug}-{brief}/epic.md` exists, non-empty, carrying the Status draft marker, the banner, and a Scratch Notes section.
- No formal Goal / Success Criteria / Scope structure filled.
- No open-questions dialog run.
- No validation footer (that belongs to `/pe1-define` and `/validate-artifact`).

## Notes

- **No open-questions dialog.** pe0 is deliberately fast and unrefined. Surfacing questions one-at-a-time and resolving them is `/pe1-define`'s job (Principle 2 applies there, not here).
- **Non-destructive by construction.** The collision halt (rather than a numeric-suffix fallback, unlike f0) reflects the PO-flow design where slugs are user-chosen and globally unique.
- **Fresh-agent runnable** — the template and the supplied blurb are sufficient. No conversation history required.

---

Created 2026-06-14 — by /f3-implement-update for proposals/26-po-draft-stub-skills-incremental-decomposition.md (Phase 1).

<!-- Managed by Shamt — do not edit. Regenerate from shamt-core/host/templates/claude/commands/pe0-draft.md. -->
