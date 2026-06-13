# shamt-core — Master-Dev Primer

This is the canonical home of the **Shamt** framework: rules, references, templates, and Claude Code host wiring that child projects import. Treat this file as the north star for working **on the framework itself**. For day-to-day project work that *uses* Shamt, see `README.md` (commands + skills + personas) and `templates/SHAMT_RULES.template.md` (the rules a child project installs).

This file is for shamt-core contributors. shamt-core is its own standalone git repository.

---

## What lives here

```text
shamt-core/
├── CLAUDE.md                       # this file — master-dev primer
├── README.md                       # hand-written quick reference (commands, skills, personas)
├── templates/                      # artifact skeletons + the child-facing rules template
│   └── SHAMT_RULES.template.md     # canonical rules; rendered into a child's CLAUDE.md
├── reference/                      # expanded examples, standards, recipes
├── host/templates/claude/          # Claude-Code-specific managed-file templates (skills, commands, personas)
└── shamt-config.example.json       # schema-by-example for the per-project config
```

A child project that installs Shamt keeps just two Shamt entries at its project root — `CLAUDE.md` (a managed section rendered from `SHAMT_RULES.template.md`) and the generated `.claude/` directory (which Claude Code requires at the root). Everything else lives under a hidden `.shamt-core/` directory: the copied canonical sources, `shamt-config.json` (initialized from the example), `README.md`, the `proposals/` working area, `project-specific-files/{ARCHITECTURE,CODING_STANDARDS}.md`, the PO/Engineer **work tree** (`epics/`, `features/`, `stories/`, `code_reviews/`), and the `shamt-state/` active-item pointers. `.shamt-core/` is the **Shamt work root** in a child — every `epics/`/`features/`/`stories/`/`code_reviews/`/`shamt-state/` path the commands and rules write resolves relative to it (the repo root on master/self-host); the framework never writes a work-tree artifact at a child's project root.

---

## The two surfaces

Shamt has **canonical sources** (in this folder) and **generated artifacts** (in child projects). These are not the same thing.

| Surface | Lives in | Edited by | Notes |
|---------|----------|-----------|-------|
| Canonical | `shamt-core/` (this folder) | Framework contributors via the framework-update flow | Single source of truth |
| Generated | A child project's `.claude/`, its managed-section `CLAUDE.md`, its installed `.shamt-core/README.md` | Never edited directly | Regenerated from canonical sources |

**Hard rule:** Never edit generated files in a child project. All changes go to canonical sources here, then the child re-runs the import script (or `regenerate-framework`) to pick them up. Editing a generated file is always wrong — it will be overwritten on the next regen, and the canonical source still bears the old version.

---

## How changes land

The **framework-update flow** is the supported way to change anything in this folder:

1. Author a proposal at `proposals/{slug}.md`.
2. Validate the proposal with `/validate-artifact` (Pattern 1).
3. Implement the change against canonical sources.
4. Run `scripts/regenerate-framework.sh --check` against a known-clean child project to verify generated output stays sync'd.
5. Archive the proposal to `proposals/archive/{slug}.md`.

---

## Two cross-cutting principles you must follow

Both are normative for any agent doing work in this folder. They are inherited by every flow Shamt defines.

### Phase-per-command + slug resumability

Multi-phase work is broken into one command per phase. Every command takes a `{slug}`. A fresh agent with no conversation history can run any phase by resolving the slug to a folder and reading on-disk artifacts. No mega-orchestrator, no state file.

When you add a new multi-phase flow, follow this pattern. Don't build something that requires conversation memory to resume.

### Open-questions iterative dialog

While drafting any artifact (a proposal, a rules edit, a template), maintain an explicit `## Open Questions` section. Surface each question to the user **one at a time** via `AskUserQuestion` (or equivalent). Update the artifact with the answer before moving to the next question. The artifact is not "drafted" while questions remain.

No bulk question-bombing. No silent assumption-making. No placeholders surviving into validation.

---

## What's deliberately out of scope

Carried forward from v1 lessons:

- **No multi-host support.** Claude Code is the only first-class host. Codex / Cursor / IDE integrations are not regenerated. If a second host ever becomes a real need, propose it through the framework-update flow.
- **No MCP server, no OTel collector, no SDK CI templates.** v1 had these and the cost outweighed the use.
- **No rigid stage-gate model.** There is no S1–S11. Stories are the leaf execution unit; epic/feature work is decomposition above them.
- **No SHAMT-N design-doc lifecycle.** Proposals carry a lightweight filename-prefixed organizational **number** (`{NN}-{slug}.md`, master-side only — see the Conventions section below) purely as a stable, `ls`-ordered identifier. Slugs remain the primary descriptive identifier. This is *not* a revival of v1's heavyweight SHAMT-N design-doc lifecycle (per-doc statuses, state machine, numbering ceremony).
- **No design-doc lifecycle stored in canonical files.** History belongs in git, not in the rules file.

If a request would pull shamt-core back toward any of these, pause and confirm with the user before building.

---

## Conventions

Pinned 2026-06-03 (proposal `proposal-workflow-conventions`). The authoritative mechanics live in the `/f1-propose-update` and `/f6-archive-proposal` command bodies; this section is the concise overview.

- **Commit subject** — one squash commit per proposal: `shamt-core: land #NN {slug} (short description)`. A grandfathered/unnumbered proposal drops the `#NN`: `shamt-core: land {slug} (short description)`.
- **Proposal number** — a lightweight organizational ID, **master-side only**. Proposals are filename-prefixed `proposals/{NN}-{slug}.md` with a matching `**Number:**` header. The number is two-digit zero-padded (`01`, `02`, … widening to three digits only past `99`), assigned at `/f1-propose-update` (master-local) or `/sync-triage-proposals` promote (child-submitted) as `max(existing NN across proposals/, proposals/archive/, proposals/deferred/, proposals/rejected/) + 1`. There is no counter file — the max is scanned from disk, parsing a leading `^[0-9]+-` run on each filename (so unnumbered/grandfathered files contribute nothing and the first number assigned is `01`), and numbers are never reused. Child-side proposals stay unnumbered (`.shamt-core/proposals/{slug}.md`); numbering happens only on master. This is the lightweight org-ID permitted by the out-of-scope note above — **not** a SHAMT-N design-doc lifecycle.
- **Branch per proposal** — `proposal/{NN}-{slug}` (`proposal/{slug}` for a grandfathered/unnumbered proposal), created by `/f3-implement-update` from the base branch immediately before the canonical edits. Authoring, validation, and planning happen on the base branch; the proposal branch exists only for the implement→merge window.
- **Archive commits + merges** — `/f6-archive-proposal` commits the canonical edits + regen output + archive move, squash-merges `proposal/{NN}-{slug}` into the base branch as the single commit above, then deletes the branch.

---

## Validation expectations

Every artifact change in this folder goes through a Pattern 1 validation loop before merge. The `templates/SHAMT_RULES.template.md` file defines Pattern 1 normatively — read it once and apply it consistently. Sub-agent confirmations always use cheap-tier (Haiku); a sub-agent finding any issue (even one LOW) resets the validation counter.

