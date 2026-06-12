---
description: Fast-path PO command — file a one-off bug or quick win directly under the standing Tech Stories epic's Bugs / Quick Wins feature, bypassing the epic→feature→story decomposition cascade, then hand to /e1-start-story (stub-aware)
---

# /p6-draft-tech-story

**Purpose:** The fast-path entry into the PO/Engineer flow for work that does **not** belong to any real initiative — one-off bug fixes and small standalone improvements. Instead of the full `/p1`→`/p2`→`/p3`→`/p4` drill-down, it seeds a single story-ticket stub directly under the standing **Tech Stories** epic's **Bugs** or **Quick Wins** feature, then hands off to `/e1-start-story` for intake. Reuses the stub-then-drill-in pattern of `/p2-decompose-epic` / `/p4-decompose-feature`.

**Recommended model:** Cheap (Haiku). Mechanical: pick a feature, allocate an ID, write a stub from the active tracker's ticket template, hand off. No design judgment. See [`reference/model_selection.md`](../../../../reference/model_selection.md).

---

## Usage

```
/p6-draft-tech-story [bugs|quick-wins] [slug] [blurb]
```

## Arguments

- `[bugs|quick-wins]` (optional) — which standing feature to file under. If omitted, ask the user to pick.
- `[slug]` (optional) — kebab-case slug for the new story. If omitted, derive it from the blurb / prompt and confirm.
- `[blurb]` (optional) — a one-line description of the bug / quick win, used as the scope one-liner in the stub.

## Prerequisites

- `.shamt-core/shamt-config.json` exists (for the `work_item_tracker` default).
- The standing **Tech Stories** epic exists at `epics/{tech-stories-folder}/` with `features/bugs/` and `features/quick-wins/` (seeded by `init-shamt.sh` / `import-shamt.sh`). If absent, halt and direct the user to re-run `import-shamt` (which seeds it) — `/p6` does not create the standing containers itself.

## Step-by-step

### Step 1 — Pick the feature

Resolve the target feature folder via §PO-tree resolution under the Tech Stories epic: `epics/{tech-stories-folder}/features/bugs/` or `epics/{tech-stories-folder}/features/quick-wins/`. If the user did not pass `bugs` / `quick-wins`, ask which one (a one-line `AskUserQuestion`). **Bugs** = something is broken; **Quick Wins** = a small standalone improvement.

### Step 2 — Allocate the ticket ID + slug

1. Allocate the ticket ID `T{N}` per the **# Ticket IDs** rules (`max` across the whole epic/feature/story tree + 1, scanned from disk).
2. Confirm the slug (derive from the blurb if not given). The slug is globally unique — detect collisions per §PO-tree resolution; halt and ask for a different slug on collision.

### Step 3 — Write the ticket stub

Create `epics/{tech-stories-folder}/features/{bugs|quick-wins}/stories/{ID}-{slug}-{brief}/ticket.md` from the active tracker's per-provider ticket template. **Template selection** — read `work_item_tracker` from `.shamt-core/shamt-config.json`:

- **ado** → [`templates/ticket.ado.template.md`](../../../../templates/ticket.ado.template.md)
- **github** → [`templates/ticket.github.template.md`](../../../../templates/ticket.github.template.md)
- **local** → a minimal hand-authored stub (no per-provider template).

Populate the **scope one-liner** (the blurb) in the body intake area. Parentage is the folder path — no back-ref headers. Leave every other template section empty for `/e1-start-story` to flesh out. (No `## Decomposition Context` — there is no decomposition cascade here.)

### Step 4 — Hand off to the Engineer flow

Hand off to `/e1-start-story {slug}` (stub-aware): it resolves the stub by §PO-tree resolution, detects the nested-stub state by the path, and runs Intake on the seeded ticket. The story then proceeds through the normal Engineer flow (`/e2`…`/e8`).

## Exit criteria

- A story-ticket stub exists at `epics/{tech-stories-folder}/features/{bugs|quick-wins}/stories/{ID}-{slug}-{brief}/ticket.md` with the scope one-liner populated.
- `/e1-start-story {slug}` has been suggested (or run) for intake.

## Notes

- **Bypasses the decompose cascade.** This is the only PO entry point that does not require an epic/feature drill-down — the Tech Stories epic + its two features are standing fixtures, so one-off work files directly.
- **Completion archive.** When the finished tech-story is finalized via `/e8-finalize-story`, it is moved into `epics/{tech-stories-folder}/features/{bugs|quick-wins}/archive/` — keeping the standing features from growing without bound.
- **Local-only containers.** The Tech Stories epic + Bugs/Quick Wins features never map to tracker work items; only the individual tickets filed under them map to tracker issues per the active profile.
- **Fresh-agent runnable** — the standing epic, config, and tracker templates are sufficient. No conversation history required.

---

<!-- Managed by Shamt — do not edit. Regenerate from shamt-core/host/templates/claude/commands/p6-draft-tech-story.md. -->
