# Shamt — Cheatsheet

**Purpose:** Quick reference for the Claude Code host wiring Shamt installs into a child project. Hand-written; updated by hand when commands change. This file is copied into child projects via `import-shamt`.

For the rules a child project must follow, see [`templates/SHAMT_RULES.template.md`](templates/SHAMT_RULES.template.md). For development of the framework itself, see [`CLAUDE.md`](CLAUDE.md).

---

## Host wiring layout

A child project that has installed Shamt looks like this:

```text
<child-project>/
├── CLAUDE.md                       # rendered from SHAMT_RULES.template.md at init
│                                   #   (the ONLY Shamt file left at the project root)
├── .claude/                        # generated wiring (must stay at root — Claude Code requirement)
│   ├── commands/                   # rendered from .shamt-core/host/templates/claude/commands/
│   ├── agents/                     # rendered persona definitions
│   ├── skills/                     # rendered auto-triggered skills
│   ├── statusline.sh               # rendered status-line script
│   └── settings.json               # statusLine entry patched by regen (rest is user-owned)
├── .shamt-core/                    # all other Shamt-owned content (managed; do not hand-edit)
│   ├── CHEATSHEET.md               #   copy of this file
│   ├── shamt-config.json           #   initialized from shamt-config.example.json
│   ├── CLAUDE.md                   #   (master-dev primer)
│   ├── shamt-config.example.json
│   ├── init-shamt.sh               #   (re-init / inspection only — first install ran from master)
│   ├── import-shamt.sh             #   (pulls master HEAD for ongoing updates)
│   ├── scripts/regenerate-framework.sh
│   ├── templates/
│   ├── reference/
│   ├── host/templates/claude/
│   ├── project-specific-files/
│   │   ├── ARCHITECTURE.md         #   required at init (template provided)
│   │   └── CODING_STANDARDS.md     #   required at init (template provided)
│   └── proposals/                  # framework-update proposals (locally authored)
│       ├── _template.md            #   (master-owned — resynced by /sync-import-shamt; do not edit locally)
│       ├── submitted/              # submitted to master, awaiting decision
│       └── already-merged/         # came back via master sync (auto-moved on import)
├── stories/                        # runtime — per-story artifacts
├── epics/                          # runtime — PO-flow artifacts (when used)
├── features/                       # runtime — PO-flow artifacts (when used)
└── code_reviews/                   # formal-mode review output
```

The master repo has additional `proposals/` subfolders that **never appear in a child project**: `incoming/` (child-submitted proposals awaiting triage), `archive/` (implemented proposals), `rejected/` (closed with a top-of-file note), and `deferred/` (on hold). Master's presence is what `/sync-submit-proposal` and `/sync-triage-proposals` use to discriminate the two sides — child projects rely on the absence of `proposals/incoming/` as the master-side check.

Files with a `Managed by Shamt` footer (or files in `.shamt-core/`'s master sync set) are owned by master / regen — they get overwritten by `import-shamt` and `/f4-regen-framework`. Files outside that set are user-owned and preserved.

---

## Master / child sync contract

Shamt is a master/child framework with deliberately constrained sync directions:

| Direction | Mechanism | What moves |
|-----------|-----------|------------|
| Child → master | **Proposals only.** Manual copy-paste via `/sync-submit-proposal`. | A single proposal file (`proposals/incoming/{project_name}-{slug}.md` on master). |
| Master → child | **Framework pull only.** Scripted via `/sync-import-shamt`. Always-latest, no pinning. | Master's canonical sources under `shamt-core/`. |

No bidirectional guide-editing sync. No `export.sh`. The child's project work (stories, epics, features, code reviews) never syncs to master and isn't carried by Shamt at all — it lives in the child's own git repo.

---

## Slash commands

### Engineer flow (Part 1 — story-level execution)

| Command | Phase | Status |
|---------|-------|--------|
| `/e1-start-story {slug}` | 1. Intake | shipped |
| `/e2-define-spec {slug}` | 2. Spec | shipped |
| `/e3-plan-implementation {slug}` | 3. Plan (Standard only) | shipped |
| `/e3b-write-testing-plan {slug}` | 3 sub-phase (testing enabled) | shipped |
| `/e4-execute-plan {slug}` | 4. Build | shipped |
| `/e5-execute-tests {slug}` | 5. Test (testing enabled) | shipped |
| `/e6-review-changes [{slug}\|--branch=<name>\|--pr=<id>]` | 6. Review | shipped |
| `/e7-resolve-feedback {slug}` | 7. Polish | shipped |
| `/e5b-write-manual-testing-plan {slug}` | Post-Build (optional) | shipped |
| `/validate-artifact <path>` | any | shipped |

> **Batch handoff (≥2 artifacts).** When a phase leaves two or more artifacts to validate at once — a phase-decomposed framework-update plan (`/f2-plan-update-implementation`: index + N phase files) or several proposals promoted in one `/sync-triage-proposals` run — the producing command emits a copy-paste **batch-validation handoff prompt** (recommended) alongside the sequential `/clear` + `/validate-artifact` fallback. The pasted orchestrator fans out one validation sub-agent per artifact, each running the same Pattern 1 loop in its own context. See [`reference/batch_validation_handoff.md`](reference/batch_validation_handoff.md).

### Product Owner flow (Part 2)

Four commands at two altitudes — Epic (top) and Feature (one level down). Each `start-*` command defines an artifact; each `decompose-*` command breaks it into stubs at the next altitude. The story is the handoff into the Engineer flow.

```text
            Epic                       <-- /p1-start-epic, /p2-decompose-epic
             |
             v   (N features per epic, stub-list pattern)
          Feature                      <-- /p3-start-feature, /p4-decompose-feature
             |
             v   (N stories per feature, stub-list pattern)
           Story                       <-- /e1-start-story (stub-aware), then Engineer flow
```

| Command | Phase | Status |
|---------|-------|--------|
| `/p1-start-epic {slug}` | Epic intake/define | shipped |
| `/p2-decompose-epic {slug}` | Epic → feature stubs | shipped |
| `/p3-start-feature {slug}` | Feature intake/define | shipped |
| `/p4-decompose-feature {slug}` | Feature → story stubs | shipped |

Every command above is **slug-first** and **fresh-agent runnable** per Principle 1: pass a slug, the command resolves the folder, reads on-disk state, executes its phase. Each one mirrors `/e1-start-story`'s tracker plumbing: when the active profile (read from `.shamt-core/shamt-config.json`) declares the matching work-item type (e.g., ADO supports Epic + Feature + Story; GitHub supports Issue only), the slug-to-ID parse and payload fetch happen — otherwise the command falls through to freeform mode with a one-line notice (`tracker profile {name} has no {Type} work-item type — proceeding freeform`).

#### Hierarchy + folder layout

```text
<child-project>/
├── epics/                                # flat, globally unique slugs
│   └── {epic-slug}-{brief}/
│       └── epic.md                       # no raw/ subfolder; All Remaining Fields appendix holds fetched fidelity
├── features/                             # flat, globally unique slugs
│   └── {feature-slug}-{brief}/
│       └── feature.md                    # **Parent Epic:** back-ref header under H1 (blank for standalone)
└── stories/                              # flat, globally unique slugs (Engineer-flow runtime)
    └── {story-slug}-{brief}/
        ├── ticket.md                     # **Parent Feature:** + **Parent Epic:** back-ref headers under H1 when PO-flow-seeded
        ├── raw/                          # tracker payloads (stories only — distinct from epic/feature altitudes)
        ├── spec.md, implementation_plan.md, ...
        └── feedback/, ...
```

Epic and feature folders contain **only the main artifact** — no `raw/`, no `feedback/`, no nested per-story content. Per-story artifacts stay under their own story folder. Slugs are **globally unique at each altitude** (flat layout); collisions across `epics/`, `features/`, `stories/` are surfaced at write time by every command.

#### Back-ref headers and the story handoff

Linking is plain-markdown header lines under the H1 — no parser, no sidecar file:

- `epic.md` has no back-ref (top of the hierarchy).
- `feature.md` carries `**Parent Epic:** {epic-slug}` (blank for standalone features created by `/p3-start-feature` from scratch).
- `ticket.md` (when written by `/p4-decompose-feature`) carries `**Parent Feature:** {feature-slug}` and (when the parent feature has an epic) `**Parent Epic:** {parent-epic-slug}` — the second line is **omitted entirely** for stories under a standalone feature. `/p4-decompose-feature` populates both headers; `/e1-start-story` is **stub-aware** and **preserves them verbatim** when fleshing out the rest of the Intake content (no new command flag — the presence of the back-ref headers is the signal). Pre-existing freeform stories (no headers) behave unchanged.

#### Individually-testable rubric (the hard PO-flow constraint)

`/p4-decompose-feature` enforces this on every story stub it writes:

> A story is **individually testable** when it carries a self-contained verification path (automated or manual) that exercises its own contribution without re-verifying any sibling story's success criterion.
>
> **Rubric exception:** development-order dependencies between siblings are allowed. They live in the parallelization analysis (`Recommended order`), not as a testability violation.

The rubric is the contract between PO flow and Engineer flow. The Engineer flow can refuse a story that violates it; the decomposition exit gate catches violations before stubs land on disk. See the `/p4-decompose-feature` command body for the full rubric and inline enforcement details.

#### Architecture-impact flag

Both `/p1-start-epic` and `/p3-start-feature` consult `.shamt-core/project-specific-files/ARCHITECTURE.md` while drafting. If the epic/feature implies architectural change (new service, new boundary, new data store, new external integration, auth/tenant boundary shift, etc.), the agent flags it **inline** in `Scope / Non-Scope` as `**Architecture impact:** {one-line description}`. Omitted entirely otherwise. **Neither command consults `.shamt-core/project-specific-files/CODING_STANDARDS.md`** — coding style is irrelevant at these altitudes; the story-level Phase 6 / Phase 7 cycle handles coding-standards alignment for any eventual code changes.

#### Status-line PO modes (STORY > FEATURE > EPIC > idle)

The status line surfaces PO-flow context by falling back through altitudes — first-match-wins:

1. **Active story** → `STORY {slug} | P{N} {phase} | feat: {feature-slug} | epic: {epic-slug}` (the `feat:` / `epic:` segments come from the active `ticket.md`'s back-ref headers — omitted when absent).
2. **No active story, active feature** → `FEATURE {feature-slug} | epic: {parent-epic-slug}` (omits the `epic: …` segment for standalone features).
3. **No active story or feature, active epic** → `EPIC {epic-slug}`.
4. Otherwise → `Shamt | idle`.

"Active" at every altitude resolves the same way: `{altitude}/.active` (single-line override pinning a folder) if present, else most-recently-modified subdirectory. See the [Status-line registration](#status-line-registration) table below for the full layout.

### Framework update flow (Part 3 — master-side)

| Command | Purpose | Status |
|---------|---------|--------|
| `/f0-draft-proposal {slug} [blurb]` | Phase 0 (optional) — quick-capture an unrefined DRAFT proposal from a blurb, no open-questions dialog (master **and** child); used by the audit to capture intricate findings | shipped |
| `/f1-propose-update {slug} [blurb]` | Phase 1 — author / edit a proposal (from scratch, a blurb, or by ingesting an f0 draft) | shipped |
| `/validate-artifact proposals/{slug}.md` | Phase 2 — Pattern 1 validation | shipped |
| `/f2-plan-update-implementation {slug}` | Phase 3 (optional, >10 file ops) — architect plan | shipped |
| `/f3-implement-update {slug}` | Phase 4 — apply canonical edits | shipped |
| `/f4-regen-framework` | Phase 5 — propagate canonical edits into `.claude/` | shipped |
| `/f5-audit-framework` | Phase 6 — continuous dual-track D1–D11 sweep: auto-fix simple findings + capture intricate ones as f0 drafts (also standalone). **Master / self-host only** — in a child it halts and redirects to f0 → f1 → `/sync-submit-proposal` | shipped |
| `/f6-archive-proposal {slug}` | Phase 7 — archive the implemented proposal | shipped |

> **Proposal conventions (master-side).** Master-side proposals carry a lightweight organizational **number**: filenames are `proposals/{NN}-{slug}.md` with a matching `**Number:**` header, assigned at `/f1-propose-update` (master-local) or `/sync-triage-proposals` promote (child-submitted) as `max(existing NN across proposals/, archive/, deferred/, rejected/) + 1` (two-digit zero-padded, no counter file, never reused). **Child-side proposals stay unnumbered** (`.shamt-core/proposals/{slug}.md`). Each proposal lands on its own branch `proposal/{NN}-{slug}` (`proposal/{slug}` when grandfathered/unnumbered), created by `/f3-implement-update` from the base branch immediately before the canonical edits; `/f6-archive-proposal` commits the change as `shamt-core: land #{NN} {slug} (…)`, squash-merges the branch into the base branch, and deletes it. See the Conventions section of `CLAUDE.md` and the `/f1-propose-update` / `/f6-archive-proposal` command bodies for the authoritative mechanics.

### Master / child sync (Part 4)

| Command | Side | Purpose | Status |
|---------|------|---------|--------|
| `/sync-submit-proposal {slug}` | Child | Prepare a validated proposal for upstream manual copy. Moves local copy to `.shamt-core/proposals/submitted/`. | shipped |
| `/sync-import-shamt` | Child | Pull master HEAD via `.shamt-core/import-shamt.sh`, then regen. | shipped |
| `/sync-triage-proposals` | Master | Walk `proposals/incoming/`, promote / reject / defer / skip each. | shipped |

---

## Sub-agent personas

| Persona | Tier | Used by | Status |
|---------|------|---------|--------|
| `plan-executor` | Haiku | `/e4-execute-plan` (Standard) and `/f3-implement-update` (architect/builder path) | shipped |
| `validation-checker` | Haiku | Pattern 1 adversarial sub-agent | shipped |
| `audit-checker` | Haiku | `/f5-audit-framework` clean-round adversarial sweep | shipped |
| `test-executor` | Haiku | `/e5-execute-tests` | shipped |
| `review-executor` | Opus | `/e6-review-changes` formal mode | shipped |

---

## Auto-triggered skills

Each slash command above has a corresponding auto-triggered skill with natural-language trigger phrases. Same canonical body, two host wirings. Skills fire when the user phrases their intent in prose ("spec this ticket", "review my branch", "submit the proposal"); slash commands fire on explicit invocation by slug.

Skill wiring is generated from `.shamt-core/host/templates/claude/skills/` during regen.

---

## Configuration

Per-project settings live in `.shamt-core/shamt-config.json`. Initialize from `.shamt-core/shamt-config.example.json` and edit (or let `init-shamt.sh` prompt you). Keys:

| Key | Type | Purpose |
|-----|------|---------|
| `project_name` | string (`^[A-Za-z0-9._-]+$`) | Used by `/sync-submit-proposal` to namespace upstream submissions (`proposals/incoming/{project_name}-{slug}.md` on master) |
| `work_item_tracker` | `"ado"` / `"github"` / `"local"` / `"none"` | Which tracker `/e1-start-story` (etc.) fetches from |
| `pr_provider` | `"ado"` / `"github"` / `"none"` | Which PR provider `/e6-review-changes` formal mode uses |
| `testing` | `"enabled"` / `"disabled"` | Whether Phase 5 (Test) is part of the Engineer flow |
| `ai_service` | `"anthropic"` | Reserved for future multi-host |
| `master_url` | string | Where `import-shamt` pulls from. Git URL (`https://…` / `git@…` / `ssh://…`) → cloned `--depth 1`; absolute local path → used directly |
| `doc_staleness_threshold_days` | integer (default 60) | `/f5-audit-framework` D6: how stale `.shamt-core/project-specific-files/ARCHITECTURE.md` / `.shamt-core/project-specific-files/CODING_STANDARDS.md` can be |

---

## Bootstrap and update scripts

### `init-shamt.sh` — first-time install

Lives in master's `shamt-core/`. Invoked from inside the target project:

```bash
bash /path/to/shamt-core/init-shamt.sh [--target <dir>]
```

Behavior:

- Detects self-host when `<target>/shamt-core/init-shamt.sh` resolves (by realpath) to the running script — in that case the framework-source copy is skipped.
- Halts if the install config already exists (`<target>/shamt-config.json` on self-host, `<target>/.shamt-core/shamt-config.json` otherwise). Re-init is not supported; use `import-shamt.sh` for updates.
- Prompts interactively for every `.shamt-core/shamt-config.json` field (no flag-based unattended mode).
- Copies canonical sources from `<source>/shamt-core/` into `<target>/.shamt-core/` (skipped on self-host).
- Seeds the child's `CLAUDE.md` at `<target>/` (from `templates/SHAMT_RULES.template.md`), and the two project-specific docs `ARCHITECTURE.md` + `CODING_STANDARDS.md` (with `Last Updated` set to today) under `<target>/.shamt-core/project-specific-files/`. `CHEATSHEET.md` and `proposals/_template.md` travel inside the `.shamt-core/` canonical-source copy — they are not separately seeded. Skipped on self-host.
- Writes the install config (`<target>/shamt-config.json` on self-host, `<target>/.shamt-core/shamt-config.json` otherwise) from the prompted answers. Ends with a copy/pastable completion prompt that drives an agent to fill in and `/validate-artifact` both project-specific docs.
- Runs `regenerate-framework.sh --target <target>` to produce `<target>/.claude/`.

### `import-shamt.sh` — framework pull

Installed at `<child>/.shamt-core/import-shamt.sh` by `init-shamt.sh`. Invoked from the child:

```bash
bash <child>/.shamt-core/import-shamt.sh [--target <dir>]
```

Or via `/sync-import-shamt`. Behavior:

- Reads `master_url` from `<target>/.shamt-core/shamt-config.json`.
- Git URL → `git clone --depth 1` to a temp dir. Local path → used directly with no copy.
- Locates master's `shamt-core/` (top-level or one-level-down, depending on whether the master is the extracted repo or the v2-dev container).
- Overwrites every file in master's sync set into `<child>/.shamt-core/` (subtree-level master-wins; not per-file footer-checked — see `commands/sync-import-shamt.md` Notes).
- Preserves (with warnings) any local-only files the child added under the managed subtrees.
- Auto-moves child-local proposals whose slugs match a file in master's `proposals/archive/` into `<child>/.shamt-core/proposals/already-merged/{slug}.md`.
- Re-runs `regenerate-framework.sh --target <child>` after the file sync.
- Self-updating: `import-shamt.sh` is in the sync set; a new version overwrites the on-disk copy and takes effect on the next invocation.

---

## Regen

`.shamt-core/scripts/regenerate-framework.sh` renders canonical Claude wiring (`.shamt-core/host/templates/claude/`) into a child project's `.claude/` directory. Bash-first; a PowerShell wrapper may follow later.

### Modes

| Invocation | Effect |
|------------|--------|
| `regenerate-framework.sh` | Default. Renders canonical → `<cwd>/.claude/`. Writes/overwrites managed files; prunes managed files no longer in canonical; preserves unmanaged user files. |
| `regenerate-framework.sh --check` | Dry-run drift report. Prints `DRIFT <path>` for content mismatch, `STALE <path>` for managed-but-removed-from-canonical, `UNMANAGED <path>` for user-authored files (preserved). Exits 1 on any DRIFT or STALE, 0 otherwise. |
| `regenerate-framework.sh --bootstrap --source <.claude-dir>` | Reverse seed: capture managed files from a hand-built `.claude/` back into `shamt-core/host/templates/claude/`. Used during initial master-dev to round-trip changes. |
| `--target <dir>` | Override the target project directory (default: cwd). Regen writes `<target>/.claude/`. |
| `-h`, `--help` | Show usage. |

PowerShell-style aliases (`-Check`, `-BootstrapTemplates`) are accepted for parity with the lite-transfer regen script.

### Managed-by-Shamt footer contract (for `.claude/`)

Every file the regen script writes ends with a `Managed by Shamt` comment. The script will only **overwrite or prune** files under `.claude/` that carry that marker. Files without it are user-authored and preserved (the `--check` output flags them as `UNMANAGED <path> (preserved)`).

`import-shamt.sh` uses a different, simpler rule for the `.shamt-core/` subtree: subtree-level master-wins for the explicit sync set, preserve everything else. The per-file footer check is `regenerate-framework.sh`'s discipline for `.claude/`, not `import-shamt.sh`'s for `.shamt-core/`. See `commands/sync-import-shamt.md` Notes.

### Status-line registration

The regen script also installs `.claude/statusline.sh` (the active-state renderer) and writes a `statusLine` entry into `.claude/settings.json` pointing at it. If `settings.json` doesn't exist, the script creates a minimal one; if it exists, the script patches the `statusLine` field via `jq` when available, otherwise prints the entry to add manually. `settings.json` is treated as user-owned and is not pruned.

Status-line output formats (live, computed cheaply from filesystem state — no git, no network). Priority order — first match wins:

| Priority | Condition | Output |
|----------|-----------|--------|
| 1 | Active story (folder pinned via `stories/.active` or most-recently-modified `stories/*/`) with a phase artifact | `STORY {slug} \| P{N} {phase-name}` (plus ` \| feat: …` / ` \| epic: …` when ticket.md carries `Parent Feature` / `Parent Epic` headers) |
| 2 | No active story; active feature (`features/.active` or mtime fallback) | `FEATURE {feature-slug}` (plus ` \| epic: {parent-epic-slug}` when feature.md carries `**Parent Epic:**` — omitted for standalone features) |
| 3 | No active story, no active feature; active epic (`epics/.active` or mtime fallback) | `EPIC {epic-slug}` |
| 4 | None of the above | `Shamt \| idle` |

The `.active` override file works the same way at every altitude: a single line containing the active folder's name; if the pinned folder exists, it wins; otherwise the renderer falls back to the most-recently-modified subdirectory. Useful when mtime is misleading (e.g., after a sweeping `git restore`).

Phase detection (story altitude only) cascades from latest-stage artifact. Numbers depend on `.shamt-core/shamt-config.json` `testing`:

| Artifact present | `testing: "enabled"` (7 phases) | `testing: "disabled"` (6 phases) |
|---|---|---|
| `feedback/addressed_feedback.md` | P7 Polish | P6 Polish |
| `feedback/review_v*.md` | P6 Review | P5 Review |
| `testing_plan.md` | P5 Test | *(ignored — no Test phase)* |
| `implementation_plan.md` | P3 Plan | P3 Plan |
| `spec.md` | P2 Spec | P2 Spec |
| `ticket.md` | P1 Intake | P1 Intake |

Phase 4 (Build) has no dedicated artifact; the cascade shows the last-completed artifact's phase while Build is in flight.

---
Validated 2026-05-28 — Phase 12 implementation loop. Touched by Phase 12: PO-flow section back-fill (hierarchy diagram, four-command table, folder layout, back-ref handoff, individually-testable rubric, architecture-impact flag, status-line PO modes subsection); priors preserved from Phase 9.
Touched 2026-06-02 — added `/f0-draft-proposal` (Phase 0 capture) row, gave f1 its `[blurb]`/f0-ingestion form, and reframed the `/f5-audit-framework` row as a continuous dual-track loop that is master/self-host only (child halts → f0 → f1 → sync-submit). Per proposals/audit-continuous-f0-draft-capture.md.
