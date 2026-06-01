# shamt-core — Master-Dev Primer

This is the canonical home of the **Shamt** framework: rules, references, templates, and Claude Code host wiring that child projects import. Treat this file as the north star for working **on the framework itself**. For day-to-day project work that *uses* Shamt, see `CHEATSHEET.md` (commands + skills + personas) and `templates/SHAMT_RULES.template.md` (the rules a child project installs).

This file is for shamt-core contributors. The repo-root `CLAUDE.md` (one level up, in the v2 development container) is a separate document — it primes the v2-development context and references this folder.

---

## What lives here

```text
shamt-core/
├── CLAUDE.md                       # this file — master-dev primer
├── CHEATSHEET.md                   # hand-written quick reference (commands, skills, personas)
├── templates/                      # artifact skeletons + the child-facing rules template
│   └── SHAMT_RULES.template.md     # canonical rules; rendered into a child's CLAUDE.md
├── reference/                      # expanded examples, standards, recipes
├── host/templates/claude/          # Claude-Code-specific managed-file templates (skills, commands, personas)
└── shamt-config.example.json       # schema-by-example for the per-project config
```

A child project that installs Shamt keeps just two Shamt entries at its project root — `CLAUDE.md` (a managed section rendered from `SHAMT_RULES.template.md`) and the generated `.claude/` directory (which Claude Code requires at the root). Everything else lives under a hidden `.shamt-core/` directory: the copied canonical sources, `shamt-config.json` (initialized from the example), `CHEATSHEET.md`, the `proposals/` working area, and `project-specific-files/{ARCHITECTURE,CODING_STANDARDS}.md`.

---

## The two surfaces

Shamt has **canonical sources** (in this folder) and **generated artifacts** (in child projects). These are not the same thing.

| Surface | Lives in | Edited by | Notes |
|---------|----------|-----------|-------|
| Canonical | `shamt-core/` (this folder) | Framework contributors via the framework-update flow | Single source of truth |
| Generated | A child project's `.claude/`, its managed-section `CLAUDE.md`, its installed `.shamt-core/CHEATSHEET.md` | Never edited directly | Regenerated from canonical sources |

**Hard rule:** Never edit generated files in a child project. All changes go to canonical sources here, then the child re-runs the import script (or `regenerate-framework`) to pick them up. Editing a generated file is always wrong — it will be overwritten on the next regen, and the canonical source still bears the old version.

---

## How changes land

Once Phase 8 is built, the **framework-update flow** is the supported way to change anything in this folder:

1. Author a proposal at `proposals/{slug}.md`.
2. Validate the proposal with `/validate-artifact` (Pattern 1).
3. Implement the change against canonical sources.
4. Run the regen script in `-Check` mode against a known-clean child project to verify generated output stays sync'd.
5. Archive the proposal to `proposals/archive/{slug}.md`.

Until Phase 8 lands, treat this list as the **target shape** — propose changes in chat, validate manually using Pattern 1, edit the canonical file, and note what should later become a `proposals/` entry.

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

Carried forward from v1 lessons (see `../INFRASTRUCTURE.md` for full rationale):

- **No multi-host support.** Claude Code is the only first-class host. Codex / Cursor / IDE integrations are not regenerated. If a second host ever becomes a real need, propose it through the framework-update flow.
- **No MCP server, no OTel collector, no SDK CI templates.** v1 had these and the cost outweighed the use.
- **No rigid stage-gate model.** There is no S1–S11. Stories are the leaf execution unit; epic/feature work is decomposition above them.
- **No SHAMT-N numbering for framework changes.** Proposal slugs are descriptive.
- **No design-doc lifecycle stored in canonical files.** History belongs in git, not in the rules file.

If a request would pull shamt-core back toward any of these, pause and confirm with the user before building.

---

## Commit conventions (TBD)

Not pinned yet. Decide before the first feature commit and document here. The repo-root `CLAUDE.md` calls out the same TBD; resolve them together.

---

## Validation expectations

Every artifact change in this folder goes through a Pattern 1 validation loop before merge. The `templates/SHAMT_RULES.template.md` file defines Pattern 1 normatively — read it once and apply it consistently. Sub-agent confirmations always use cheap-tier (Haiku); a sub-agent finding any issue (even one LOW) resets the validation counter.

---

## Working alongside `_reference/`

While shamt-core is being built inside the `shamt-ai-dev-v2/` development container, the sibling `_reference/` folder (one level up) holds two read-only prior-art trees:

- `_reference/shamt-lite-transfer/` — the lightweight standalone bundle this rewrite is based on. Primary baseline.
- `_reference/shamt-ai-dev/` — the full v1 master repo. Mine for patterns; do not copy structure wholesale.

Both are **gitignored** in v2. Never edit, never stage, never delete. Once shamt-core is extracted into its own repository, `_reference/` won't follow; this folder must stand on its own.
