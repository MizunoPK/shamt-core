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

A child project that installs Shamt keeps just two Shamt entries at its project root — `CLAUDE.md` (a managed section rendered from `SHAMT_RULES.template.md`) and the generated `.claude/` directory (which Claude Code requires at the root). Everything else lives under a hidden `.shamt-core/` directory: the copied canonical sources, `shamt-config.json` (initialized from the example), `README.md`, the `proposals/` working area, `project-specific-files/{ARCHITECTURE,CODING_STANDARDS,TESTING_STANDARDS}.md`, the PO/Engineer **work tree** (`epics/`, `features/`, `stories/`, `code_reviews/`), and the `shamt-state/` active-item pointers. `.shamt-core/` is the **Shamt work root** in a child — every `epics/`/`features/`/`stories/`/`code_reviews/`/`shamt-state/` path the commands and rules write resolves relative to it (the repo root on master/self-host); the framework never writes a work-tree artifact at a child's project root. A child install **git-ignores** all of this generated footprint — `/.shamt-core/`, `/.claude/`, and the seeded `/CLAUDE.md` (a pre-existing child `CLAUDE.md` is preserved and stays tracked) — via a managed block `init-shamt.sh` adds to the child's `.gitignore`; all of it is re-derivable from master (`import-shamt`) + regen.

---

## The surfaces

Shamt has **canonical sources** (in this folder), **generated artifacts** (in child projects), and a child's **child-owned** project-specific files. These are not the same thing.

| Surface | Lives in | Edited by | Notes |
|---------|----------|-----------|-------|
| Canonical | `shamt-core/` (this folder) | Framework contributors via the framework-update flow | Single source of truth |
| Generated | A child project's `.claude/`, its managed-section `CLAUDE.md`, its installed `.shamt-core/README.md` | Never edited directly | Regenerated from canonical sources |
| Child-owned | A child project's `.shamt-core/project-specific-files/` (ARCHITECTURE.md, CODING_STANDARDS.md, TESTING_STANDARDS.md) | Via the **project-specific proposal class** — `/f1-propose-update` routes here when the change is scoped to this project only | Neither canonical (not framework sources) nor generated (not regen output); evolved via the project-specific proposal class, archived locally, never go upstream |

**Hard rules — unchanged:**
- Never edit generated files (`.claude/`) in a child project. All framework changes go to canonical sources here, then the child re-runs import + regen. Editing a generated file is always wrong — it will be overwritten on the next regen, and the canonical source still bears the old version.
- Never edit canonical sources in a child project directly. They are read-only copies re-derived from master via `import-shamt`. A change meant for the framework goes through the framework-update flow (upstream via `/sync-proposals`); a change scoped to this project only goes through the project-specific proposal class (see the third row above).

---

## How changes land

The **framework-update flow** is the supported way to change anything in this folder:

1. Author a proposal at `proposals/{slug}.md`.
2. Validate the proposal with `/validate-artifact` (Pattern 1).
3. Implement the change against canonical sources.
4. Run `scripts/regenerate-framework.sh --check` against a known-clean child project to verify generated output stays sync'd.
5. Archive the proposal to `proposals/archive/{slug}.md`.

These phases are decomposed one-command-per-phase per Principle 1, each run by hand (the supported manual path). `/f-all {slug}` is an **optional** one-shot driver that walks a proposal through every remaining phase end-to-end (validate → optional `/f2`+plan-validation → `/f3` → `/f4` → `/f5-audit-framework` → `/f6`; `/f5-audit-framework` runs in-chain as Phase 6, between `/f4` and `/f6`, via `/f-all`'s driver-lifted `audit-checker` topology, its auto-fixes + this-run f0 captures folding into the `/f6` squash commit) by dispatching one independent agent per phase. **Master / self-host only.**

**`/f-all` and Principle 1 — the authoritative reconciliation** (the carve-out a future `/f5-audit-framework` D9 contradiction sweep consults). Principle 1 forbids a "single mega-orchestrator" and a "state file." `/f-all` is neither: it is a **stateless, disk-derived *dispatcher* of the canonical phase commands**, not a state-holding monolith that reimplements them. It holds no state of its own — it derives its start phase from on-disk artifacts (a single launch-time derivation, the resumability guarantee) and advances on each dispatched phase agent's returned report — and every underlying `/fX` command remains independently runnable by a fresh agent. So `/f-all` is a convenience layer *over* the phase-per-command decomposition, honoring Principle 1 rather than contradicting it. (It is a master-side framework-update concept and is deliberately **not** added to `templates/SHAMT_RULES.template.md`, which is size-budgeted (D12) and never carries master-only flow detail; this primer — the doc that already states the three principles are "inherited by every flow Shamt defines" — is where the reconciliation is homed.)

**`/e-all` and Principle 1 — the authoritative reconciliation** (homed here beside `/f-all`'s so a future `/f5-audit-framework` D9 contradiction sweep consults both flow-drivers' carve-outs in one place). `/e-all {slug}` is the Engineer flow's analog of `/f-all`: an **optional** one-shot driver that walks a single story through every remaining Engineer-flow phase **up to and including Review** (`/e1` → `/e2` → `/e3` → `/e4` → `/e5` → `/e6` → `/e7`, opening the PR when `pr_provider == github`) by dispatching one independent agent per phase. It **stops at the end of Review** — Polish (`/e8`, an iterative human-in-the-loop PR-comment loop) and Finalize (`/e9`, which merges the PR when `pr_provider == github`) are **operator-driven, not auto-run by `/e-all`** (Polish is no longer a single pass, so it cannot be chained unattended). It honors Principle 1 by the same argument: it is a **stateless, disk-derived *dispatcher* of the canonical Engineer-phase commands**, not a state-holding monolith — it derives its start phase from on-disk artifacts under `stories/{slug}/` (using a working-tree **gate** for `/e5`, which records no durable artifact, exactly as `/f-all` gates `/f3` and `/f4`) and advances on each dispatched phase agent's report, and every underlying `/eX` command stays independently runnable. It differs from `/f-all` in three structural ways: it is **child-facing** (it runs wherever the Engineer flow runs — every child project, and master self-host — so there is **no** master-only guard); it is **gate-heavy** (it pauses on the Engineer flow's many interactive gates — Gate 2a design dialog, Gate 2b / Gate 3 approvals — each lifted to the user via `AskUserQuestion`, never a design call the driver makes itself); and it spans more inner personas (`validation-checker`, `plan-executor`, `user-simulator`, `test-executor`), each lifted up to the driver under the same one-nesting-level rule. Because it stops at Review, its terminal dispatched phase is `/e7` (which opens the PR behind `/e7`'s own explicit-confirm guard when `pr_provider == github`); the later `/e9` PR merge is operator-driven and user-gated by `/e9`'s own explicit-confirm guard — strictly safer than `/f-all`'s autonomous squash-merge. (Like `/f-all`, it is deliberately **not** added to `templates/SHAMT_RULES.template.md` — the size-budgeted (D12) child rules file does not carry flow-driver detail; this primer is where the reconciliation is homed. A short pointer lives in the README §"Engineer flow (Part 1 — story-level execution)" note.)

---

## Three cross-cutting principles you must follow

All are normative for any agent doing work in this folder. They are inherited by every flow Shamt defines.

### Phase-per-command + slug resumability

Multi-phase work is broken into one command per phase. Every command takes a `{slug}`. A fresh agent with no conversation history can run any phase by resolving the slug to a folder and reading on-disk artifacts. No mega-orchestrator, no state file.

When you add a new multi-phase flow, follow this pattern. Don't build something that requires conversation memory to resume.

### Open-questions iterative dialog

While drafting any artifact (a proposal, a rules edit, a template), maintain an explicit `## Open Questions` section. Surface each question to the user **one at a time** via `AskUserQuestion` (or equivalent). Update the artifact with the answer before moving to the next question. The artifact is not "drafted" while questions remain.

No bulk question-bombing. No silent assumption-making. No placeholders surviving into validation.

### Disk-authoritative cross-session work

Shamt is multi-session and parallel by design — multiple agents author and update artifacts, run personas, and advance work concurrently — so the on-disk artifacts, not any one agent's conversation history, are the authoritative record of work performed.

An agent must not treat the fact that it "did not perform or observe X this session" as evidence that X never happened, and must never distrust, revert, rename-back, or delete an artifact on that basis. A parallel session does real work the current session has no visibility into, so a provenance claim recorded in an artifact (a validation footer, an f0 capture banner, a `Confirmed root cause (adversarial diagnosis — …)` line) is presumed genuine. If such a claim genuinely needs verifying, the evidence is git history across branches, the cited artifact/folder, or the user — never silent deletion.

This does **not** relax Pattern 1: its adversarial validation still distrusts unsupported claims about reality (code, governing docs) and verifies them from evidence, **and agents still never fabricate a claim of work they did not do**. Session-absence is simply not the evidence Pattern 1 demands.

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

