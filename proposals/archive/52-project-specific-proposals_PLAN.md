# Implementation Plan: 52-project-specific-proposals

**Proposal:** proposals/52-project-specific-proposals.md
**Created:** 2026-06-22
**File operations:** 11 (CREATE: 0, EDIT: 11, DELETE: 0, MOVE: 0)

## Pre-execution checklist

- [ ] On a clean working tree (or working in a worktree dedicated to this proposal).
- [ ] `proposals/52-project-specific-proposals.md` validation footer present.
- [ ] Branch created by `/f3-implement-update`: `proposal/52-project-specific-proposals` from the base branch (`main`), immediately before the canonical edits. (Authoring/validation/planning happened on the base branch; the architect/builder path's executor creates this branch when it runs this pre-execution checklist at Phase 4.)

## Files manifest

| # | Path | Operation | Sibling / template (if any) |
|---|------|-----------|------------------------------|
| 1 | `host/templates/claude/commands/f1-propose-update.md` | EDIT | — |
| 2 | `host/templates/claude/skills/f1-propose-update/SKILL.md` | EDIT | — |
| 3 | `host/templates/claude/commands/f3-implement-update.md` | EDIT | — |
| 4 | `host/templates/claude/skills/f3-implement-update/SKILL.md` | EDIT | — |
| 5 | `host/templates/claude/commands/f6-archive-proposal.md` | EDIT | — |
| 6 | `host/templates/claude/skills/f6-archive-proposal/SKILL.md` | EDIT | — |
| 7 | `host/templates/claude/commands/sync-proposals.md` | EDIT | — |
| 8 | `host/templates/claude/skills/sync-proposals/SKILL.md` | EDIT | — |
| 9 | `README.md` | EDIT | — |
| 10 | `CLAUDE.md` | EDIT | — |
| 11 | `proposals/_template.md` | EDIT | — |

## Step-by-step

---

### Step 1 — Add child-only routing question and project-specific class to f1-propose-update command

**Operation:** EDIT
**File:** `host/templates/claude/commands/f1-propose-update.md`

**Locate (Prerequisites section — the child-side detection anchor):**
```
## Prerequisites

- Run from the shamt-core repository root (master-side) — the repo with a top-level `proposals/` directory — or from a project with a synced framework + `.shamt-core/proposals/` folder (child-side). If neither exists, halt and direct the user to either run this from the shamt-core repo root or install Shamt first.
- `.shamt-core/proposals/_template.md` must exist. If not, halt and report — the template is the source of truth for proposal shape.
```

**Replace:**
```
## Prerequisites

- Run from the shamt-core repository root (master-side) — the repo with a top-level `proposals/` directory — or from a project with a synced framework + `.shamt-core/proposals/` folder (child-side). If neither exists, halt and direct the user to either run this from the shamt-core repo root or install Shamt first.
- `.shamt-core/proposals/_template.md` must exist. If not, halt and report — the template is the source of truth for proposal shape.

## Proposal class (child-side only)

Shamt supports two proposal classes. **Class is detected by folder, not a status marker** (disk-authoritative, least-machinery):

| Class | Folder | Proposed Changes rows | Goes upstream? |
|-------|--------|-----------------------|----------------|
| **Framework** | `.shamt-core/proposals/{slug}.md` (child) or `proposals/{slug}.md` (master) | Canonical sources only (`shamt-core/templates/`, `shamt-core/reference/`, `shamt-core/host/templates/claude/`, `shamt-core/scripts/`, root docs) — never `.claude/` | Yes — via `/sync-proposals` |
| **Project-specific** | `.shamt-core/proposals/project-specific/{slug}.md` | `.shamt-core/project-specific-files/` only — never canonical sources, never `.claude/` | **Strictly local** — never goes upstream |

**On the master side this distinction does not exist.** Every master-side proposal is a framework proposal. The routing question below is child-side only; master-side runs skip it entirely and proceed as today.
```

**Locate (Step 1 — Seed from the template, immediately after the heading):**
```
### Step 1 — Seed from the template

> **Input Mode 3 (existing f0 draft): skip this step** for the template-seed — the f0 file already follows the template shape — but **still run the master-side number-assignment sub-step (items 5–6 below)**: an f0 draft is unnumbered, so on master it must be numbered + renamed during ingestion. Per Slug resolution, normalize `Status:` to plain `Draft`, drop the f0 banner, and resume at Step 2 using the Scratch Notes as the seed.
```

**Replace with (prepend a new Step 0 before Step 1, and shift the existing Step 1 heading text to follow):**
```
### Step 0 — Routing question (child-side only)

**This step runs only on the child side** (no top-level `proposals/` directory at cwd). Master-side runs skip this step entirely and proceed to Step 1 as today.

Ask via `AskUserQuestion`:

> Is this a **project-specific** change (edit this project's own `.shamt-core/project-specific-files/` docs — ARCHITECTURE.md, CODING_STANDARDS.md, TESTING_STANDARDS.md) or a **framework** change (would benefit master Shamt and every project)?

- **Framework** → proposal at `.shamt-core/proposals/{slug}.md`. Proceed to Step 1 as normal. Proposed Changes rows must target canonical sources only (never `project-specific-files/`, never `.claude/`). Upstream-bound via `/sync-proposals`.
- **Project-specific** → proposal at `.shamt-core/proposals/project-specific/{slug}.md`. Proceed to Step 1 with this alternate path: seed the template there instead. Proposed Changes rows must target `.shamt-core/project-specific-files/` only (never canonical sources, never `.claude/`). **Strictly local** — never submitted upstream; `/sync-proposals` excludes `proposals/project-specific/` (see §"Proposal class" above). The Step 3 path-discipline check (item 2 — "Generated `.claude/` paths never appear") applies equally; the project-specific class's rows are instead validated against the `project-specific-files/`-only whitelist, and `/f3-implement-update` enforces this whitelist at edit time.

The `proposals/project-specific/` folder is created on first use (folders are not committed empty in a child, where `.shamt-core/` is git-ignored). If the folder doesn't exist yet, create it as part of seeding the proposal.

**Reclassification escape hatch (no machinery).** If a project-specific concern turns out to generalize, manually `mv` the file from `proposals/project-specific/` up to top-level `proposals/` and re-run `/f1-propose-update` — folder location alone reclassifies it. No special command.

### Step 1 — Seed from the template

> **Input Mode 3 (existing f0 draft): skip this step** for the template-seed — the f0 file already follows the template shape — but **still run the master-side number-assignment sub-step (items 5–6 below)**: an f0 draft is unnumbered, so on master it must be numbered + renamed during ingestion. Per Slug resolution, normalize `Status:` to plain `Draft`, drop the f0 banner, and resume at Step 2 using the Scratch Notes as the seed.
```

**Locate (Step 6 — Exit gate, the Proposed Changes check):**
```
- [ ] **Proposed Changes** lists at least one row, and every row gives a canonical (non-`.claude/`) path.
```

**Replace:**
```
- [ ] **Proposed Changes** lists at least one row, and every row gives a path appropriate for the proposal class: canonical (non-`.claude/`) path for a framework proposal; `.shamt-core/project-specific-files/` path for a project-specific proposal.
```

**Locate (Step 7 — Suggest the next phase, the row count ≤ 10 branch):**
```
- Row count ≤ 10 → `/clear`, then `/validate-artifact {path}`, where `{path}` is the proposal's actual on-disk path (`proposals/{NN}-{slug}.md` on master, `.shamt-core/proposals/{slug}.md` on child).
- Row count > 10 → `/clear`, then `/validate-artifact {path}` (same path), then `/f2-plan-update-implementation {slug}` (resolves the proposal by bare slug or numbered stem).
```

**Replace:**
```
- Row count ≤ 10 → `/clear`, then `/validate-artifact {path}`, where `{path}` is the proposal's actual on-disk path (`proposals/{NN}-{slug}.md` on master, `.shamt-core/proposals/{slug}.md` on child, `.shamt-core/proposals/project-specific/{slug}.md` for a project-specific proposal).
- Row count > 10 → `/clear`, then `/validate-artifact {path}` (same path), then `/f2-plan-update-implementation {slug}` (resolves the proposal by bare slug or numbered stem).
```

**Locate (Exit criteria):**
```
## Exit criteria

- `.shamt-core/proposals/{slug}.md` exists, non-empty, no open questions, all Proposed Changes rows on canonical paths.
- The next phase has been suggested in chat.
```

**Replace:**
```
## Exit criteria

- The proposal file exists, non-empty, no open questions:
  - Framework class: `.shamt-core/proposals/{slug}.md` (child) or `proposals/{NN}-{slug}.md` (master), all Proposed Changes rows on canonical (non-`.claude/`) paths.
  - Project-specific class: `.shamt-core/proposals/project-specific/{slug}.md`, all Proposed Changes rows on `.shamt-core/project-specific-files/` paths.
- The next phase has been suggested in chat.
```

**Verification:**
- `grep -F 'Step 0 — Routing question' host/templates/claude/commands/f1-propose-update.md` returns one match.
- `grep -F 'project-specific' host/templates/claude/commands/f1-propose-update.md` returns matches in the new Step 0, Exit criteria, and Proposal class section.
- `grep -F 'Project-specific' host/templates/claude/commands/f1-propose-update.md` returns at least one match in the routing question table.

---

### Step 2 — Update f1-propose-update SKILL.md for class-accurate Exit criteria and description

**Operation:** EDIT
**File:** `host/templates/claude/skills/f1-propose-update/SKILL.md`

**Locate (frontmatter description):**
```
description: >
  Author or edit a framework-update proposal at .shamt-core/proposals/{slug}.md. Phase 1
  of the Shamt framework-update flow: seed from the canonical template — from
  scratch, from a free-text [blurb], or by ingesting an existing f0
  audit-capture draft — draft the Problem and Proposed Changes (canonical
  paths only — never .claude/), fill Risks / Rollback / Validation
  Considerations, and apply the open-questions iterative dialog until the Open
  Questions section is empty. For an incident-originated proposal (bug /
  feedback / issue / audit capture) it first drives an independent adversarial
  root-cause diagnosis (Opus root-cause-diagnoser + Haiku zero-bias
  confirmation) before drafting the change set. Invoke when the user wants to propose a framework
  change, write up a framework fix, draft a proposal, flesh out an f0 draft, or
  capture an upstream-worthy idea.
```

**Replace:**
```
description: >
  Author or edit a framework-update proposal at .shamt-core/proposals/{slug}.md
  (framework class) or .shamt-core/proposals/project-specific/{slug}.md
  (project-specific class — child-side only, strictly local). Phase 1 of the
  Shamt framework-update flow: on the child side, first asks whether the change
  is project-specific (edit this project's .shamt-core/project-specific-files/
  docs) or framework (would benefit master Shamt and every project); seed from
  the canonical template — from scratch, from a free-text [blurb], or by
  ingesting an existing f0 audit-capture draft — draft the Problem and Proposed
  Changes (canonical paths only for framework class, project-specific-files/
  only for project-specific class — never .claude/), fill Risks / Rollback /
  Validation Considerations, and apply the open-questions iterative dialog until
  the Open Questions section is empty. For an incident-originated proposal (bug /
  feedback / issue / audit capture) it first drives an independent adversarial
  root-cause diagnosis (Opus root-cause-diagnoser + Haiku zero-bias
  confirmation) before drafting the change set. Invoke when the user wants to propose a framework
  change, write up a framework fix, draft a proposal, flesh out an f0 draft,
  capture an upstream-worthy idea, or update this project's architecture /
  coding-standards / testing-standards docs under a governed proposal loop.
```

**Locate (Exit criteria):**
```
## Exit criteria

`.shamt-core/proposals/{slug}.md` exists, has no open questions, every Proposed Changes row points at a canonical (non-`.claude/`) path, and the next phase has been suggested.
```

**Replace:**
```
## Exit criteria

The proposal file exists and has no open questions:
- Framework class: `.shamt-core/proposals/{slug}.md` (child) or `proposals/{NN}-{slug}.md` (master) — every Proposed Changes row points at a canonical (non-`.claude/`) path.
- Project-specific class (child only): `.shamt-core/proposals/project-specific/{slug}.md` — every Proposed Changes row points at a `.shamt-core/project-specific-files/` path.

The next phase has been suggested in chat.
```

**Verification:**
- `grep -F 'project-specific-files/' host/templates/claude/skills/f1-propose-update/SKILL.md` returns matches in both the description and Exit criteria.
- `grep -F '## Protocol' host/templates/claude/skills/f1-propose-update/SKILL.md` returns one match; read that section to confirm it still reads `Follow the canonical /f1-propose-update command body verbatim` with no numbered step paraphrase added.

---

### Step 3 — Add project-specific class branching to f3-implement-update command

**Operation:** EDIT
**File:** `host/templates/claude/commands/f3-implement-update.md`

**Locate (Arguments section):**
```
- `{slug}` (required) — proposal slug (bare descriptive slug or numbered stem `{NN}-{slug}`). Resolves the proposal exact-then-glob — `proposals/{slug}.md`, then `proposals/*-{slug}.md` (master-side proposals carry a `{NN}-` prefix; matches at most one, halt on multiple) — and the companion `proposals/{NN}-{slug}_PLAN.md` (or phase files) with the same stem.
```

**Replace:**
```
- `{slug}` (required) — proposal slug (bare descriptive slug or numbered stem `{NN}-{slug}`). Resolves the proposal by class:
  - **Framework class:** exact-then-glob — `proposals/{slug}.md`, then `proposals/*-{slug}.md` (master-side proposals carry a `{NN}-` prefix; matches at most one, halt on multiple) — and the companion `proposals/{NN}-{slug}_PLAN.md` (or phase files) with the same stem.
  - **Project-specific class (child only):** exact — `.shamt-core/proposals/project-specific/{slug}.md`. No numbered prefix. A project-specific proposal commonly has no companion `_PLAN.md` (it rarely exceeds 10 file ops); but the >10-row plan gating is class-agnostic — if one ever does, `/f2` runs normally and produces a plan targeting `project-specific-files/` paths, and `/f3` resolves the companion plan the same way it does for framework proposals.
  - Class is determined by location of the resolved file: `proposals/project-specific/` → project-specific; anything else → framework.
```

**Locate (Step 1 — Preflight, item 4 — the canonical-only Hard rule):**
```
4. **Hard rule — canonical-only**: enumerate the set of paths the proposal (or plan) will touch. For every path, confirm it lives under one of:
   - `shamt-core/templates/`
   - `shamt-core/reference/`
   - `shamt-core/host/templates/claude/`
   - `shamt-core/scripts/`
   - `shamt-core/proposals/` (when the proposal itself is updating the proposal template or related folder docs)
   - `shamt-core/CLAUDE.md`, `shamt-core/README.md`, `shamt-core/shamt-config.example.json` (root-level canonical docs)
   - Any path under `shamt-core/` outside the above list **only if** the proposal explicitly justifies it in Validation Considerations or Risks.

   If any path falls under generated `.claude/` (or its child-side equivalent), **halt immediately**. Edits to generated files are always wrong — they get overwritten on the next regen and the canonical source still carries the old version. Fix the offending row to point at the canonical source, strip the proposal's prior footer, and re-run `/validate-artifact` — an **[in-place amendment](f1-propose-update.md#in-place-amendment)** path-correction (the row already exists, so this corrects it rather than appending), no full `/f1-propose-update` re-run.
```

**Replace:**
```
4. **Hard rule — path whitelist (class-dependent):** enumerate the set of paths the proposal (or plan) will touch and apply the whitelist for the resolved class:

   **Framework class whitelist** — every path must live under one of:
   - `shamt-core/templates/`
   - `shamt-core/reference/`
   - `shamt-core/host/templates/claude/`
   - `shamt-core/scripts/`
   - `shamt-core/proposals/` (when the proposal itself is updating the proposal template or related folder docs)
   - `shamt-core/CLAUDE.md`, `shamt-core/README.md`, `shamt-core/shamt-config.example.json` (root-level canonical docs)
   - Any path under `shamt-core/` outside the above list **only if** the proposal explicitly justifies it in Validation Considerations or Risks.

   **Project-specific class whitelist (child only)** — every path must live under:
   - `.shamt-core/project-specific-files/`
   Canonical sources, generated `.claude/`, and `shamt-config.json` are **all off-limits** for this class. Halt immediately on any out-of-whitelist path.

   For either class: if any path falls under generated `.claude/` (or its child-side equivalent), **halt immediately**. Edits to generated files are always wrong — they get overwritten on the next regen and the canonical source still carries the old version. Fix the offending row to point at the correct path, strip the proposal's prior footer, and re-run `/validate-artifact` — an **[in-place amendment](f1-propose-update.md#in-place-amendment)** path-correction, no full `/f1-propose-update` re-run.
```

**Locate (Step 1.5 — Create the proposal branch):**
```
### Step 1.5 — Create the proposal branch

Branch creation moved to this command — it is **not** done at `/f1-propose-update` or `/sync-triage-proposals`. Create the branch from the base branch immediately before applying canonical edits:

- **Branch name:** `proposal/{NN}-{slug}` using the proposal's resolved numbered stem (`proposal/{slug}` for a grandfathered/unnumbered proposal with no `{NN}-` prefix). Read numbered-ness from the resolved filename's leading `^[0-9]+-` run: present = numbered, absent = grandfathered.
- **Inline path:** create it directly — `git checkout -b proposal/{NN}-{slug}` from the base branch (the branch framework changes land on). Halt and report if the branch already exists.
- **Architect/builder path:** do **not** create it here — the validated plan's pre-execution checklist declares the branch, and `plan-executor` creates it when it runs that checklist (pre-flight Step 4). Confirm the plan's pre-execution checklist names `proposal/{NN}-{slug}` before handing off.

Creating a branch is not a commit — the "No commits here" rule (Notes) still holds. The commit + squash-merge happen later at `/f6-archive-proposal` (Phase 7).
```

**Replace:**
```
### Step 1.5 — Create the proposal branch (framework class only)

**This step is skipped for the project-specific class.** A project-specific proposal's edits touch only `.shamt-core/project-specific-files/`, which is git-ignored in a child (`init-shamt.sh` managed `.gitignore` block). There are no tracked canonical edits to branch for, and `/f6-archive-proposal` will skip the squash-merge for this class. Proceed directly to Step 2 for a project-specific proposal.

For the **framework class:** branch creation moved to this command — it is **not** done at `/f1-propose-update` or `/sync-triage-proposals`. Create the branch from the base branch immediately before applying canonical edits:

- **Branch name:** `proposal/{NN}-{slug}` using the proposal's resolved numbered stem (`proposal/{slug}` for a grandfathered/unnumbered proposal with no `{NN}-` prefix). Read numbered-ness from the resolved filename's leading `^[0-9]+-` run: present = numbered, absent = grandfathered.
- **Inline path:** create it directly — `git checkout -b proposal/{NN}-{slug}` from the base branch (the branch framework changes land on). Halt and report if the branch already exists.
- **Architect/builder path:** do **not** create it here — the validated plan's pre-execution checklist declares the branch, and `plan-executor` creates it when it runs that checklist (pre-flight Step 4). Confirm the plan's pre-execution checklist names `proposal/{NN}-{slug}` before handing off.

Creating a branch is not a commit — the "No commits here" rule (Notes) still holds. The commit + squash-merge happen later at `/f6-archive-proposal` (Phase 7).
```

**Locate (Step 5 — Suggest the next phase):**
```
### Step 5 — Suggest the next phase

Suggest a context-clear and the next command:

- `/clear`, then `/f4-regen-framework` (Phase 5 — propagate canonical edits into `.claude/`).
```

**Replace:**
```
### Step 5 — Suggest the next phase

Suggest a context-clear and the next command:

- **Framework class:** `/clear`, then `/f4-regen-framework` (Phase 5 — propagate canonical edits into `.claude/`).
- **Project-specific class:** `/clear`, then `/f6-archive-proposal {slug}` (skip `/f4-regen-framework` — project-specific files are not propagated to `.claude/`). Note to the user that `/f6` will skip the branch squash-merge for this class (nothing tracked to merge).
```

**Locate (Exit criteria):**
```
## Exit criteria

- Every Proposed Changes row covered by a change in the working tree.
- No edits in generated `.claude/` paths.
- The next phase (`/f4-regen-framework`) has been suggested.
```

**Replace:**
```
## Exit criteria

- Every Proposed Changes row covered by a change in the working tree (or confirmed already-correct for each target path).
- No edits in generated `.claude/` paths (either class).
- For the **framework class**: the next phase (`/f4-regen-framework`) has been suggested.
- For the **project-specific class**: the next phase (`/f6-archive-proposal {slug}`) has been suggested, with a note that `/f4` is skipped.
```

**Verification:**
- `grep -F 'project-specific class' host/templates/claude/commands/f3-implement-update.md` returns matches in the Arguments section, Step 1 item 4, Step 1.5, Step 5, and Exit criteria.
- `grep -F 'project-specific-files' host/templates/claude/commands/f3-implement-update.md` returns at least one match in Step 1 item 4.
- `grep -F 'Step 1.5' host/templates/claude/commands/f3-implement-update.md` returns one match with the "framework class only" qualifier present.

---

### Step 4 — Update f3-implement-update SKILL.md for class-accurate description and Exit criteria

**Operation:** EDIT
**File:** `host/templates/claude/skills/f3-implement-update/SKILL.md`

**Locate (frontmatter description):**
```
description: >
  Phase 4 of the Shamt framework-update flow. Read a validated proposal at
  proposals/{slug}.md (and validated proposals/{slug}_PLAN.md when Phase 3
  ran) and apply the canonical edits — either inline by the primary agent
  (≤10 file ops) or via handoff to the plan-executor builder persona
  (architect/builder split, when a plan is present). Hard rule: edits go to
  canonical sources only; generated .claude/ files are NEVER edited
  directly. Invoke when the user wants to implement a framework update,
  apply the proposal, execute the proposal's plan, or land the canonical
  edits for proposals/{slug}.md.
```

**Replace:**
```
description: >
  Phase 4 of the Shamt framework-update flow. Read a validated proposal and
  apply the edits — framework class (proposals/{slug}.md): canonical sources
  only, either inline (≤10 file ops) or via plan-executor (architect/builder
  split); project-specific class (child only,
  proposals/project-specific/{slug}.md): .shamt-core/project-specific-files/
  only (inline or via plan-executor the same way, per row count), no branch
  created, next phase is /f6 (skips /f4 regen). Hard rule: generated .claude/
  files are NEVER edited directly for
  either class. Invoke when the user wants to implement a framework update,
  apply the proposal, execute the proposal's plan, or land the canonical
  edits for any proposal.
```

**Locate (Exit criteria):**
```
## Exit criteria

Every Proposed Changes row covered by a real diff entry; no generated-file edits; `/f4-regen-framework` suggested. This command creates the `proposal/{NN}-{slug}` branch (or `proposal/{slug}` grandfathered) before editing but makes **no commit** — the commit + squash-merge to the base branch land at `/f6-archive-proposal` (Phase 7), after regen.
```

**Replace:**
```
## Exit criteria

Every Proposed Changes row covered by a real diff entry; no generated-file edits.
- **Framework class:** `/f4-regen-framework` suggested; `proposal/{NN}-{slug}` branch created before editing, no commit — commit + squash-merge land at `/f6-archive-proposal` (Phase 7), after regen.
- **Project-specific class (child only):** `/f6-archive-proposal {slug}` suggested (skips `/f4`); no branch created (`.shamt-core/` is git-ignored); no commit.
```

**Locate (Hard rule):**
```
## Hard rule

**Never edit generated `.claude/` files.** Edits go to canonical sources; regen (Phase 5) propagates. Editing a generated file is always wrong — it gets overwritten on the next regen and the canonical source still carries the old version. If a step's path looks like `.claude/...`, halt unconditionally and report the path back as a proposal scope issue.
```

**Replace:**
```
## Hard rule

**Never edit generated `.claude/` files** — for either proposal class. For the **framework class**, edits go to canonical sources; regen (Phase 5) propagates. For the **project-specific class**, edits go to `.shamt-core/project-specific-files/` only; no regen is run. If a step's path looks like `.claude/...`, halt unconditionally and report the path back as a proposal scope issue.
```

**Verification:**
- `grep -F 'project-specific' host/templates/claude/skills/f3-implement-update/SKILL.md` returns matches in the description, Exit criteria, and Hard rule.
- `grep -F '## Protocol' host/templates/claude/skills/f3-implement-update/SKILL.md` returns one match; read that section to confirm it still reads `Follow the canonical /f3-implement-update command body verbatim` with no numbered step paraphrase added.

---

### Step 5 — Add project-specific class branching to f6-archive-proposal command

**Operation:** EDIT
**File:** `host/templates/claude/commands/f6-archive-proposal.md`

**Locate (Arguments section):**
```
- `{slug}` (required) — proposal slug (bare descriptive slug or numbered stem `{NN}-{slug}`). Resolves the implemented proposal exact-then-glob — `proposals/{slug}.md`, then `proposals/*-{slug}.md` (master-side proposals carry a `{NN}-` prefix; matches at most one, halt on multiple) — and archives it to `proposals/archive/{resolved-filename}`, preserving the `{NN}-` prefix (or its absence for a grandfathered proposal).
```

**Replace:**
```
- `{slug}` (required) — proposal slug (bare descriptive slug or numbered stem `{NN}-{slug}`). Resolves the implemented proposal by class:
  - **Framework class:** exact-then-glob — `proposals/{slug}.md`, then `proposals/*-{slug}.md` (master-side proposals carry a `{NN}-` prefix; matches at most one, halt on multiple) — archives to `proposals/archive/{resolved-filename}`, preserving the `{NN}-` prefix.
  - **Project-specific class (child only):** exact — `.shamt-core/proposals/project-specific/{slug}.md` — archives to `.shamt-core/proposals/project-specific/archive/{slug}.md`.
  - Class is determined by location of the resolved file (the same disk-authoritative rule as `/f3-implement-update`).
```

**Locate (Step 2 — Move to archive — items 1–3 hardcode the `proposals/archive/` destination):**
```
### Step 2 — Move to archive

1. Ensure `proposals/archive/` exists. If not, create it.
2. Move the resolved proposal file → `proposals/archive/{same-filename}` (preserving the `{NN}-` prefix when present; use `git mv` when the proposal is tracked, plain `mv` when untracked).
3. Move any companion `{NN}-{slug}_PLAN.md` / `{NN}-{slug}_PLAN_phase_*.md` (or the unnumbered forms for a grandfathered proposal) to `proposals/archive/` alongside the proposal.
```

**Replace (make the archive destination class-dependent):**
```
### Step 2 — Move to archive

**Archive destination is class-dependent** (Step 1 / Arguments determined the class by resolved-file location):
- **Framework class:** `proposals/archive/` (items 1–3 below).
- **Project-specific class (child only):** `.shamt-core/proposals/project-specific/archive/` — substitute this path for `proposals/archive/` throughout items 1–3 (created on first use), move the proposal file plus any companion `_PLAN.md` (rare for this class but produced normally if the proposal ever exceeds 10 file ops — the >10-row plan gating is class-agnostic), and use plain `mv` (the file is git-ignored / untracked in a child).

1. Ensure `proposals/archive/` exists. If not, create it.
2. Move the resolved proposal file → `proposals/archive/{same-filename}` (preserving the `{NN}-` prefix when present; use `git mv` when the proposal is tracked, plain `mv` when untracked).
3. Move any companion `{NN}-{slug}_PLAN.md` / `{NN}-{slug}_PLAN_phase_*.md` (or the unnumbered forms for a grandfathered proposal) to `proposals/archive/` alongside the proposal.
```

**Locate (Step 3 — Commit, squash-merge, and delete the branch — the section heading through its first paragraph):**
```
### Step 3 — Commit, squash-merge, and delete the branch

The archive is the landing point. `/f6-archive-proposal` now commits the change, squash-merges the proposal branch into the base branch, and deletes the branch — replacing the old "suggest a commit, don't run it" behavior. This is an irreversible git-state mutation; evaluate every pre-merge guard before touching git, and **halt** (do not merge) on any failure.
```

**Replace:**
```
### Step 3 — Commit, squash-merge, and delete the branch (framework class only)

**This step is skipped for the project-specific class.** A project-specific proposal's edits touch only `.shamt-core/project-specific-files/`, which is git-ignored in a child. There are no tracked canonical edits to commit and no `proposal/{slug}` branch was created. For a project-specific proposal, skip this step entirely and proceed to Step 4 (Exit).

For the **framework class:** the archive is the landing point. `/f6-archive-proposal` now commits the change, squash-merges the proposal branch into the base branch, and deletes the branch — replacing the old "suggest a commit, don't run it" behavior. This is an irreversible git-state mutation; evaluate every pre-merge guard before touching git, and **halt** (do not merge) on any failure.
```

**Locate (Exit criteria):**
```
## Exit criteria

- `proposals/{slug}.md` (and companions) moved to `proposals/archive/` with validation footers intact, preserving the `{NN}-` prefix.
- The change has been committed and squash-merged to the base branch, and the `proposal/{NN}-{slug}` branch deleted (after all pre-merge guards held).
```

**Replace:**
```
## Exit criteria

- **Framework class:** `proposals/{slug}.md` (and companions) moved to `proposals/archive/` with validation footers intact, preserving the `{NN}-` prefix; the change committed and squash-merged to the base branch, and the `proposal/{NN}-{slug}` branch deleted (after all pre-merge guards held).
- **Project-specific class (child only):** `.shamt-core/proposals/project-specific/{slug}.md` moved to `.shamt-core/proposals/project-specific/archive/{slug}.md` with the validation footer intact and `Status: Implemented`; no branch created, no commit, no squash-merge.
```

**Verification:**
- `grep -F 'project-specific class' host/templates/claude/commands/f6-archive-proposal.md` returns matches in the Arguments section, Step 3 heading, and Exit criteria.
- `grep -F 'project-specific/archive/' host/templates/claude/commands/f6-archive-proposal.md` returns at least two matches — the Arguments destination AND the Step 2 "Move to archive" class-dependent destination.
- `grep -F 'Archive destination is class-dependent' host/templates/claude/commands/f6-archive-proposal.md` returns one match (the Step 2 branch).
- `grep -F 'framework class only' host/templates/claude/commands/f6-archive-proposal.md` returns at least one match (the Step 3 qualifier).

---

### Step 6 — Update f6-archive-proposal SKILL.md for class-accurate description and Exit criteria

**Operation:** EDIT
**File:** `host/templates/claude/skills/f6-archive-proposal/SKILL.md`

**Locate (frontmatter description):**
```
description: >
  Phase 7 of the Shamt framework-update flow. Move proposals/{slug}.md (and
  any companion {slug}_PLAN.md or phase files) to proposals/archive/,
  preserving the validation footer. Updates the proposal's Status header to
  Implemented before the move, then commits the change, squash-merges the
  proposal/{NN}-{slug} branch into the base branch, and deletes the branch —
  behind pre-merge guards (an irreversible git-state mutation). Invoke when
  the user wants to archive a proposal, finalize a proposal, mark a proposal
  implemented, or close out the framework-update flow.
```

**Replace:**
```
description: >
  Phase 7 of the Shamt framework-update flow. Framework class: move
  proposals/{slug}.md (and any companion plan files) to proposals/archive/,
  update Status to Implemented, commit, squash-merge the proposal/{NN}-{slug}
  branch into the base branch, and delete it — behind pre-merge guards (an
  irreversible git-state mutation). Project-specific class (child only): move
  .shamt-core/proposals/project-specific/{slug}.md to
  .shamt-core/proposals/project-specific/archive/{slug}.md, update Status to
  Implemented — no branch, no commit, no squash-merge (the edited files are
  git-ignored in a child). Invoke when the user wants to archive a proposal,
  finalize a proposal, mark a proposal implemented, or close out the
  framework-update flow.
```

**Locate (Exit criteria):**
```
## Exit criteria

Proposal (and companions) at `proposals/archive/{NN}-{slug}.md` with footers intact; the change committed + squash-merged to the base branch and the `proposal/{NN}-{slug}` branch deleted (after all guards held).
```

**Replace:**
```
## Exit criteria

- **Framework class:** proposal (and companions) at `proposals/archive/{NN}-{slug}.md` with footers intact; the change committed + squash-merged to the base branch and the `proposal/{NN}-{slug}` branch deleted (after all guards held).
- **Project-specific class (child only):** proposal at `.shamt-core/proposals/project-specific/archive/{slug}.md` with footer intact and `Status: Implemented`; no branch, no commit.
```

**Verification:**
- `grep -F 'project-specific' host/templates/claude/skills/f6-archive-proposal/SKILL.md` returns matches in the description and Exit criteria.
- `grep -F '## Protocol' host/templates/claude/skills/f6-archive-proposal/SKILL.md` returns one match; read that section to confirm it still reads `Follow the canonical /f6-archive-proposal command body verbatim` with no numbered step paraphrase added.

---

### Step 7 — Make project-specific subfolder exclusion explicit in sync-proposals command

**Operation:** EDIT
**File:** `host/templates/claude/commands/sync-proposals.md`

**Locate (Step 2 — Enumerate the active proposal set, item 2):**
```
2. **Exclude** `_template.md` and anything under the `submitted/`, `archive/`, `already-merged/`, `rejected/`, and `deferred/` subfolders (these are not active — `*.md` is a top-level glob, so subfolders are already excluded; the explicit list documents intent).
```

**Replace:**
```
2. **Exclude** `_template.md` and anything under the `submitted/`, `archive/`, `already-merged/`, `rejected/`, `deferred/`, and **`project-specific/`** subfolders (these are not active — `*.md` is a top-level glob, so subfolders are already excluded; the explicit list documents intent). `project-specific/` proposals are strictly local and are **never** submitted upstream; the existing top-level `*.md` glob already excludes them, and this entry makes that exclusion explicit (mirroring how `submitted/` / `archive/` / `already-merged/` are listed).
```

**Locate (Prerequisites section, the active-proposal existence check):**
```
- At least one active proposal exists at top-level `.shamt-core/proposals/*.md` (excluding `_template.md` and the `submitted/ archive/ already-merged/ rejected/ deferred/` subfolders). If none, report "No active proposals to submit." and exit cleanly.
```

**Replace:**
```
- At least one active proposal exists at top-level `.shamt-core/proposals/*.md` (excluding `_template.md` and the `submitted/ archive/ already-merged/ rejected/ deferred/ project-specific/` subfolders). If none, report "No active proposals to submit." and exit cleanly.
```

**Verification:**
- `grep -F 'project-specific' host/templates/claude/commands/sync-proposals.md` returns matches in both Prerequisites and Step 2 item 2.
- `grep -F 'top-level' host/templates/claude/commands/sync-proposals.md` returns at least one match confirming the top-level glob is described.

---

### Step 8 — Update sync-proposals SKILL.md description for top-level-only scope

**Operation:** EDIT
**File:** `host/templates/claude/skills/sync-proposals/SKILL.md`

**Locate (frontmatter description):**
```
description: >
  Child-side step of the v2 master/child sync. Batch-prepare every active
  child-local proposal under .shamt-core/proposals/ for upstream submission to
  master. Iterates all top-level *.md proposals regardless of status (f0 draft,
  validated, or in-progress Draft — no validation-footer gate), strips any
  numeric ID, reads project_name + master_url from .shamt-core/shamt-config.json,
  and direct-writes each proposal into the local master's
  proposals/incoming/{project}-{slug}.md behind an overwrite guard (prompt on a
  differing target, no-op if identical), then moves each written/unchanged local
  copy to .shamt-core/proposals/submitted/{slug}.md to mark "awaiting decision"
  (a skipped proposal stays active). Assumes a local master_url and halts with
  actionable guidance when it is a git URL or other non-local path — no
  copy-paste fallback. Does NOT push to a remote master, open PRs, or file
  issues; the user reviews / commits / pushes the written files by hand. Invoke
  when the user wants to send proposals upstream, ship proposals to master,
  submit framework changes, or push proposals up.
```

**Replace:**
```
description: >
  Child-side step of the v2 master/child sync. Batch-prepare every active
  top-level child-local proposal under .shamt-core/proposals/*.md for upstream
  submission to master — top-level only, explicitly excluding the
  project-specific/ subfolder (those proposals are strictly local and never go
  upstream). Iterates regardless of status (f0 draft, validated, or in-progress
  Draft — no validation-footer gate), strips any numeric ID, reads project_name
  + master_url from .shamt-core/shamt-config.json, and direct-writes each
  proposal into the local master's proposals/incoming/{project}-{slug}.md
  behind an overwrite guard (prompt on a differing target, no-op if identical),
  then moves each written/unchanged local copy to
  .shamt-core/proposals/submitted/{slug}.md to mark "awaiting decision" (a
  skipped proposal stays active). Assumes a local master_url and halts with
  actionable guidance when it is a git URL or other non-local path — no
  copy-paste fallback. Does NOT push to a remote master, open PRs, or file
  issues; the user reviews / commits / pushes the written files by hand. Invoke
  when the user wants to send proposals upstream, ship proposals to master,
  submit framework changes, or push proposals up.
```

**Verification:**
- `grep -F 'top-level' host/templates/claude/skills/sync-proposals/SKILL.md` returns at least one match in the description.
- `grep -F 'project-specific/' host/templates/claude/skills/sync-proposals/SKILL.md` returns at least one match in the description.
- `grep -F '## Protocol' host/templates/claude/skills/sync-proposals/SKILL.md` returns one match; read that section to confirm it still reads `Follow the canonical /sync-proposals command body verbatim` with no numbered step paraphrase added.

---

### Step 9 — Add project-specific proposal class note to README.md

**Operation:** EDIT
**File:** `README.md`

**Locate (the proposals/ subtree lines in the child directory layout block):**
```
│   ├── proposals/                  # framework-update proposals (locally authored)
│   │   ├── _template.md            #   (master-owned — resynced by /sync-import-shamt; do not edit locally)
│   │   ├── submitted/              # submitted to master, awaiting decision
│   │   └── already-merged/         # came back via master sync (auto-moved on import)
```

**Replace:**
```
│   ├── proposals/                  # framework-update proposals (locally authored)
│   │   ├── _template.md            #   (master-owned — resynced by /sync-import-shamt; do not edit locally)
│   │   ├── submitted/              # submitted to master, awaiting decision
│   │   ├── already-merged/         # came back via master sync (auto-moved on import)
│   │   └── project-specific/       # strictly local proposals (child-only; never go upstream)
│   │       └── archive/            # archived project-specific proposals (/f6 moves here)
```

**Locate (the paragraph starting "The master repo has additional..."):**
```
The master repo has additional `proposals/` subfolders that **never appear in a child project**: `incoming/` (child-submitted proposals awaiting triage), `archive/` (implemented proposals), `rejected/` (closed with a top-of-file note), and `deferred/` (on hold). Master's presence is what `/sync-proposals` and `/sync-triage-proposals` use to discriminate the two sides — child projects rely on the absence of `proposals/incoming/` as the master-side check.
```

**Replace:**
```
The master repo has additional `proposals/` subfolders that **never appear in a child project**: `incoming/` (child-submitted proposals awaiting triage), `archive/` (implemented proposals), `rejected/` (closed with a top-of-file note), and `deferred/` (on hold). Master's presence is what `/sync-proposals` and `/sync-triage-proposals` use to discriminate the two sides — child projects rely on the absence of `proposals/incoming/` as the master-side check.

**Project-specific proposals (child-only).** A child may author a **project-specific** proposal — scoped to its own `.shamt-core/project-specific-files/` docs (ARCHITECTURE.md, CODING_STANDARDS.md, TESTING_STANDARDS.md) rather than the Shamt canonical sources. `/f1-propose-update` asks a routing question at the start (child-side only): *project-specific* (fix it here, in this project's owned docs) or *framework* (would benefit master Shamt and every project)? Project-specific proposals live at `.shamt-core/proposals/project-specific/{slug}.md`, are implemented by `/f3-implement-update` against `project-specific-files/` only (no branch, no regen), archived by `/f6-archive-proposal` to `proposals/project-specific/archive/` (no squash-merge — nothing tracked in a git-ignored child), and are **excluded** from `/sync-proposals` (strictly local, never go upstream). To reclassify a project-specific proposal as a framework change, manually `mv` it from `proposals/project-specific/` up to top-level `proposals/` and re-run `/f1-propose-update` — folder location alone reclassifies it.
```

**Verification:**
- `grep -F 'project-specific/' README.md` returns matches in both the directory layout block and the new paragraph.
- `grep -F 'Project-specific proposals (child-only)' README.md` returns one match.
- `grep -F 'master-side' README.md` — confirm the new paragraph is NOT nested under `§"Framework update flow (Part 3 — master-side)"` by reading 5 lines around any match to verify placement (it should be in the Host wiring layout section, not the framework update table notes).

---

### Step 10 — Acknowledge third category in CLAUDE.md §"The two surfaces"

**Operation:** EDIT
**File:** `CLAUDE.md`

**Locate (the two-surfaces table and the hard rule paragraph):**
```
| Surface | Lives in | Edited by | Notes |
|---------|----------|-----------|-------|
| Canonical | `shamt-core/` (this folder) | Framework contributors via the framework-update flow | Single source of truth |
| Generated | A child project's `.claude/`, its managed-section `CLAUDE.md`, its installed `.shamt-core/README.md` | Never edited directly | Regenerated from canonical sources |

**Hard rule:** Never edit generated files in a child project. All changes go to canonical sources here, then the child re-runs the import script (or `regenerate-framework`) to pick them up. Editing a generated file is always wrong — it will be overwritten on the next regen, and the canonical source still bears the old version.
```

**Replace:**
```
| Surface | Lives in | Edited by | Notes |
|---------|----------|-----------|-------|
| Canonical | `shamt-core/` (this folder) | Framework contributors via the framework-update flow | Single source of truth |
| Generated | A child project's `.claude/`, its managed-section `CLAUDE.md`, its installed `.shamt-core/README.md` | Never edited directly | Regenerated from canonical sources |
| Child-owned | A child project's `.shamt-core/project-specific-files/` (ARCHITECTURE.md, CODING_STANDARDS.md, TESTING_STANDARDS.md) | Via the **project-specific proposal class** — `/f1-propose-update` routes here when the change is scoped to this project only | Neither canonical (not framework sources) nor generated (not regen output); evolved via the project-specific proposal class, archived locally, never go upstream |

**Hard rules — unchanged:**
- Never edit generated files (`.claude/`) in a child project. All framework changes go to canonical sources here, then the child re-runs import + regen. Editing a generated file is always wrong — it will be overwritten on the next regen, and the canonical source still bears the old version.
- Never edit canonical sources in a child project directly. They are read-only copies re-derived from master via `import-shamt`. A change meant for the framework goes through the framework-update flow (upstream via `/sync-proposals`); a change scoped to this project only goes through the project-specific proposal class (see the third row above).
```

**Verification:**
- `grep -F 'Child-owned' CLAUDE.md` returns one match in the surfaces table.
- `grep -F 'project-specific-files' CLAUDE.md` returns at least one match in the new table row.
- `grep -F 'project-specific proposal class' CLAUDE.md` returns at least one match.

---

### Step 11 — Extend proposals/_template.md folder-layout comment with child-side project-specific paths

**Operation:** EDIT
**File:** `proposals/_template.md`

**Locate (the folder-layout comment block at the top of the file):**
```
<!--
proposals/ folder layout (created on first use; folders are not committed empty):

  proposals/                                    (master-side filenames shown; child-side stay unnumbered {slug}.md)
  ├── _template.md                              (this file — copy when authoring a new proposal)
  ├── {NN}-{slug}.md                            (active proposals — Phase 1 through Phase 4)
  ├── {NN}-{slug}_PLAN.md                       (Phase 3 plan, only for proposals >10 file ops)
  ├── archive/{NN}-{slug}.md                    (post-implementation, set by /f6-archive-proposal)
  ├── archive/{NN}-{slug}.draft-{timestamp}.md  (abandoned drafts, set by /f1-propose-update on start-over re-entry)
  ├── rejected/{NN}-{slug}.md                   (explicit rejections with a top-of-file note)
  └── deferred/{NN}-{slug}.md                   (on hold)

Active proposals live at the top level. /f6-archive-proposal moves implemented
proposals (and any companion *_PLAN.md / *_PLAN_phase_N.md files) into
archive/; /f1-propose-update moves abandoned drafts into archive/ with a
.draft-{timestamp} infix when the user picks "start over" on re-entry. The
rejected/ and deferred/ folders are populated manually by the user (or by
/sync-triage-proposals on the master side, when that ships).

Numbering + branch convention (master-side only; see shamt-core/CLAUDE.md
§Conventions): each master-side proposal carries a filename prefix {NN}- and a
matching **Number:** header, assigned as max(existing NN across proposals/,
archive/, deferred/, rejected/) + 1 at /f1-propose-update (master-local) or
/sync-triage-proposals promote (child-submitted). Child-side proposals under
.shamt-core/proposals/ stay unnumbered {slug}.md. /f3-implement-update creates
the proposal/{NN}-{slug} branch; /f6-archive-proposal squash-merges it to the
base branch and deletes it.
-->
```

**Replace:**
```
<!--
proposals/ folder layout (created on first use; folders are not committed empty):

  proposals/                                    (master-side filenames shown; child-side stay unnumbered {slug}.md)
  ├── _template.md                              (this file — copy when authoring a new proposal)
  ├── {NN}-{slug}.md                            (active proposals — Phase 1 through Phase 4)
  ├── {NN}-{slug}_PLAN.md                       (Phase 3 plan, only for proposals >10 file ops)
  ├── archive/{NN}-{slug}.md                    (post-implementation, set by /f6-archive-proposal)
  ├── archive/{NN}-{slug}.draft-{timestamp}.md  (abandoned drafts, set by /f1-propose-update on start-over re-entry)
  ├── rejected/{NN}-{slug}.md                   (explicit rejections with a top-of-file note)
  └── deferred/{NN}-{slug}.md                   (on hold)

  Child-side only (.shamt-core/proposals/ — git-ignored in a child):
  ├── {slug}.md                                 (framework-class proposals — unnumbered; upstream-bound via /sync-proposals)
  ├── submitted/{slug}.md                       (submitted to master, awaiting decision)
  ├── already-merged/{slug}.md                  (came back via master sync — auto-moved on import)
  └── project-specific/                         (project-specific class — strictly local; never go upstream)
      ├── {slug}.md                             (active project-specific proposals — unnumbered)
      └── archive/{slug}.md                     (post-implementation, set by /f6-archive-proposal for this class)

Active proposals live at the top level. /f6-archive-proposal moves implemented
proposals (and any companion *_PLAN.md / *_PLAN_phase_N.md files) into
archive/; /f1-propose-update moves abandoned drafts into archive/ with a
.draft-{timestamp} infix when the user picks "start over" on re-entry. The
rejected/ and deferred/ folders are populated manually by the user (or by
/sync-triage-proposals on the master side, when that ships).

Project-specific proposals (child-only, .shamt-core/proposals/project-specific/):
stay unnumbered; Proposed Changes rows target .shamt-core/project-specific-files/
only; implemented via /f3 (no branch) and archived via /f6 (no squash-merge) to
project-specific/archive/; excluded from /sync-proposals. To reclassify as a
framework proposal, mv the file up to .shamt-core/proposals/ and re-run /f1.

Numbering + branch convention (master-side only; see shamt-core/CLAUDE.md
§Conventions): each master-side proposal carries a filename prefix {NN}- and a
matching **Number:** header, assigned as max(existing NN across proposals/,
archive/, deferred/, rejected/) + 1 at /f1-propose-update (master-local) or
/sync-triage-proposals promote (child-submitted). Child-side proposals under
.shamt-core/proposals/ stay unnumbered {slug}.md. /f3-implement-update creates
the proposal/{NN}-{slug} branch; /f6-archive-proposal squash-merges it to the
base branch and deletes it. (Neither applies to the project-specific class.)
-->
```

**Verification:**
- `grep -F 'project-specific/' proposals/_template.md` returns matches in the folder-layout comment.
- `grep -F 'project-specific/archive/' proposals/_template.md` returns at least one match.
- `grep -F 'never go upstream' proposals/_template.md` returns at least one match.

---

## Verification (post-execution, whole plan)

<!-- Whole-plan / cross-phase invariants — run by the architect at /f3-implement-update post-build (Step 3), never by the builder. -->

- [ ] Every row in the Proposed Changes table has a corresponding step in this plan (11 rows → 11 steps, confirmed by inspection).
- [ ] No step edited any path under `.claude/` — confirm with `git diff --name-only | grep -v '^host/' | grep '\.claude'` returning no output (expected empty: all edits are in canonical `host/templates/claude/` not generated `.claude/`).
- [ ] `grep -rn "Managed by Shamt" host/templates/claude/` — the expected set of files remains unchanged (no new generated files leaked in; compare count before and after with `grep -rl "Managed by Shamt" host/templates/claude/ | wc -l`).
- [ ] All four SKILL.md `## Protocol` sections still contain only the command-body pointer form (no numbered step paraphrase introduced):
  - `grep -A2 '## Protocol' host/templates/claude/skills/f1-propose-update/SKILL.md` — must contain `Follow the canonical /f1-propose-update command body verbatim`.
  - `grep -A2 '## Protocol' host/templates/claude/skills/f3-implement-update/SKILL.md` — must contain `Follow the canonical /f3-implement-update command body verbatim`.
  - `grep -A2 '## Protocol' host/templates/claude/skills/f6-archive-proposal/SKILL.md` — must contain `Follow the canonical /f6-archive-proposal command body verbatim`.
  - `grep -A2 '## Protocol' host/templates/claude/skills/sync-proposals/SKILL.md` — must contain `Follow the canonical /sync-proposals command body verbatim`.
- [ ] `grep -rn 'project-specific' host/templates/claude/commands/f1-propose-update.md host/templates/claude/skills/f1-propose-update/SKILL.md host/templates/claude/commands/f3-implement-update.md host/templates/claude/skills/f3-implement-update/SKILL.md host/templates/claude/commands/f6-archive-proposal.md host/templates/claude/skills/f6-archive-proposal/SKILL.md host/templates/claude/commands/sync-proposals.md host/templates/claude/skills/sync-proposals/SKILL.md README.md CLAUDE.md proposals/_template.md` — returns matches in every one of the 11 files.
- [ ] Mermaid / link targets in edited files still resolve: all `[text](path)` cross-references inside the edited command and skill files remain unchanged (no links were renamed or removed by this proposal).

## Notes

- **Ordering constraint:** Steps 1–8 are pairwise command-then-skill (1→2, 3→4, 5→6, 7→8) but have no interdependency across pairs — they may be applied in any order. Steps 9–11 (README, CLAUDE.md, _template.md) are independent of each other and of steps 1–8. All 11 may be applied in sequence without concern for circular dependencies.
- **No `/f4-regen-framework` skip in this plan:** this proposal edits canonical sources (`host/templates/claude/`), so regen is required (framework class). The project-specific class skipping `/f4` is described in the edited commands, not in this plan.
- **SKILL.md Protocol sections:** all four SKILL.md files have `## Protocol` sections that are pure pointers to the command body. The edits in steps 2, 4, 6, 8 touch only the frontmatter `description`, the `## Exit criteria` section, and (step 4 only) the `## Hard rule` section — never the `## Protocol` section; they must never add numbered step paraphrase to `## Protocol`. The per-step and whole-plan verifications above confirm this.
- **Reclassification escape hatch** is documentation-only (documented in f1 Step 0 and README); it requires no new command or file, and no step in this plan implements any logic for it beyond the text.
- **`proposals/project-specific/archive/` folder** is created on first use by `/f6-archive-proposal` (the same "created on first use" pattern as every other proposals subfolder); no step in this plan creates the folder in advance.

---
Validated 2026-06-22 — 4 rounds, 1 adversarial sub-agent confirmed (validation-checker, zero issues; one HIGH plan-internal inconsistency adjudicated + fixed mid-loop).
