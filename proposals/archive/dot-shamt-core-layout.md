# Proposal: dot-shamt-core-layout

**Created:** 2026-05-28
**Status:** Implemented
**Proposed by:**
**Project context:**

---

## Problem

Today `init-shamt.sh` installs the framework tree into a child project at a **visible** top-level directory, `<child>/shamt-core/`, and scatters Shamt-owned files across the **project root** — `CHEATSHEET.md`, `shamt-config.json`, `proposals/`, and the two project-specific documents `ARCHITECTURE.md` / `CODING_STANDARDS.md` (`init-shamt.sh:331–411`, `:434–444`). Three issues follow:

1. **Clutter / discoverability.** The framework install is infrastructure, not project source. A visible `shamt-core/` directory plus a half-dozen loose Shamt files at the top of every child repo sit alongside the project's own source and read as first-class project content. A dot-prefixed `.shamt-core/` holding *all* Shamt-owned content signals "tooling, managed, don't hand-edit" the same way `.claude/`, `.git/`, and `.vscode/` do. The goal: the child's project root contains exactly **one** Shamt file — `CLAUDE.md` — plus the hidden `.claude/` (which Claude Code requires at the root and cannot move). Everything else moves under `.shamt-core/`.
2. **Project-specific docs have no home.** `ARCHITECTURE.md` and `CODING_STANDARDS.md` are the two documents a child is expected to fill in and maintain (consulted by `start-story`, `start-epic`, `start-feature`, `define-spec`, `plan-implementation`, `review-changes`, `resolve-feedback`, `validate-artifact`, and the `audit-framework` D6 currency check). They're loose at the project root. A dedicated `.shamt-core/project-specific-files/` folder gives the "you fill these in" documents one obvious location.
3. **Init ends with a passive instruction, not an actionable handoff.** The current `init-shamt.sh` summary says only "Review and edit ARCHITECTURE.md / CODING_STANDARDS.md" (`init-shamt.sh:485`). The two seeded docs are templates full of placeholders; nothing helps the user actually complete them. A copy/pastable agent prompt — one that drives an agent to research the project, fill in both files, and run a validation loop to solidify the content — turns the dead-end summary into a real next step.

This proposal (a) renames the child install directory to `.shamt-core/` and moves **all** Shamt-owned root files into it (`CHEATSHEET.md`, `shamt-config.json`, `proposals/`), (b) relocates the two project-specific docs into `.shamt-core/project-specific-files/`, and (c) replaces the init script's closing summary with a copy/pastable completion prompt that includes a validation loop.

**Two hard exceptions stay at the project root:** `CLAUDE.md` (Claude Code reads project rules from the root; also the one file the user wants visible) and the generated `.claude/` directory (Claude Code only discovers `.claude/` at the project root or `~/.claude` — it cannot live under `.shamt-core/`). `.claude/` is hidden, so it does not undercut the decluttering goal.

**Scope boundary:** This changes the **child-side install layout** only. The master repo (this folder, eventually extracted as the standalone `shamt-core` repository) keeps its `shamt-core/`-prefixed canonical paths. Proposal path-discipline strings like `shamt-core/templates/…` in `propose-update`, `implement-update`, `validate-artifact`, and `proposals/_template.md` describe **master** canonical locations and are unchanged — child-authored proposals still submit against master's `shamt-core/` paths. Likewise the `init-shamt.sh` self-host case (installing onto the master repo itself) leaves master's layout — `shamt-core/`, root `shamt-config.json` — untouched; the relocation applies only to non-self-host child installs.

---

## Proposed Changes

A child install today produces this layout:

```
<child>/
├── CLAUDE.md, CHEATSHEET.md, shamt-config.json   (root)
├── ARCHITECTURE.md, CODING_STANDARDS.md          (root)
├── proposals/                                     (root)
├── shamt-core/                                    (framework tree)
└── .claude/                                       (generated)
```

After this change:

```
<child>/
├── CLAUDE.md                                      (root — only Shamt file left visible)
├── .claude/                                       (generated — must stay at root)
└── .shamt-core/                                   (all other Shamt-owned content)
    ├── CHEATSHEET.md                              (relocated; already in the synced framework tree)
    ├── shamt-config.json                          (relocated; child-owned, preserved across imports)
    ├── proposals/                                 (relocated; _template.md synced, {slug}.md child-owned)
    ├── project-specific-files/
    │   ├── ARCHITECTURE.md                        (relocated)
    │   └── CODING_STANDARDS.md                    (relocated)
    ├── init-shamt.sh, import-shamt.sh, scripts/, templates/, reference/, host/   (framework tree)
    └── CLAUDE.md                                  (framework master-dev primer — distinct from the child's root CLAUDE.md)
```

> **Phase 3 required — file count ≫ 10.** Run `/plan-update-implementation dot-shamt-core-layout` before `/implement-update`. The `shamt-config.json` references span ~35 canonical files (≈164 occurrences across `host/templates/claude/`, `templates/`, `reference/`, and the root docs — most in Group D, with the `CHEATSHEET.md`/`SHAMT_RULES.template.md` occurrences handled in Group B; the count excludes generated `.claude/` copies and `shamt-config.example.json`), and the doc-path sweep (row group E) touches dozens more; Phase 3 produces the exact per-occurrence locate strings.

Rows are grouped (A–G). Within a group, the listed files all receive the same class of mechanical edit; Phase 3 expands each into per-file, per-occurrence steps.

**Group A — scripts**

| # | Canonical path | Operation | One-line change description |
|---|----------------|-----------|------------------------------|
| A1 | `shamt-core/init-shamt.sh` | EDIT | Install dest `<target>/shamt-core` → `<target>/.shamt-core` (`dest_root`, `regen_script`, self-host candidate, user-facing strings). Write `shamt-config.json` to `.shamt-core/shamt-config.json`, **gated on `SELF_HOST -eq 0`** (self-host keeps the root write). Seed `ARCHITECTURE.md`/`CODING_STANDARDS.md` into `.shamt-core/project-specific-files/`, **also gated on `SELF_HOST -eq 0`**. ⚠ Note the current code: the doc-seeding (`init-shamt.sh:376–394`) and the root `proposals/_template.md` seed (`:404–411`) sit **outside** the `SELF_HOST -eq 0` block (which closes at `:374`) — they run even on self-host today. Phase 3 must therefore **add** the `SELF_HOST -eq 0` gate around the relocated doc-seeding (not merely change the path), so master self-host is unaffected. **Drop** the separate root `CHEATSHEET.md` and root `proposals/_template.md` seed steps for child installs — both already live in the synced framework tree under `.shamt-core/` (for self-host the source files already exist in place, so dropping is safe in both cases). Self-host path unchanged (master keeps `shamt-core/` + root config). **"Already installed" precheck — two-part fix:** the precheck (currently `init-shamt.sh:129`, testing `$TARGET_DIR/shamt-config.json`) runs *before* self-host detection (`:140`), but the correct config path is now self-host-dependent (root for self-host, `.shamt-core/shamt-config.json` otherwise). Phase 3 must **move the precheck to after self-host detection** (or dual-test) so it guards `.shamt-core/shamt-config.json` for non-self-host and root `shamt-config.json` for self-host — otherwise a self-host re-run silently bypasses the guard and clobbers master's root config. Update the precheck's user-facing `import-shamt.sh` hint path to `.shamt-core/` for the non-self-host branch. |
| A2 | `shamt-core/import-shamt.sh` | EDIT | `CHILD_SHAMT_CORE="$TARGET_DIR/shamt-core"` → `.shamt-core`; `CONFIG_PATH`/`read_master_url` read from `.shamt-core/shamt-config.json`; already-merged proposals logic + `CHILD_PROPOSALS` walk `.shamt-core/proposals/`; **drop** the "mirror `_template.md` to project root" step (the synced `.shamt-core/proposals/_template.md` now serves directly); usage/comment/error strings. **No migration logic** (clean break — Q3). Confirm child-owned content (`shamt-config.json`, `proposals/{slug}.md`, `project-specific-files/`) sits outside the master sync set so it is preserved, not overwritten. |
| A3 | `shamt-core/scripts/regenerate-framework.sh` | EDIT | Verify name-agnostic — canonical root is resolved from script dir, and `.claude/` stays at `<target>/.claude/` (the `STATUS_LINE_COMMAND` `$CLAUDE_PROJECT_DIR/.claude/statusline.sh` is unaffected). Likely a no-op beyond comments; confirmed in Phase 3. |

**Group B — root canonical docs + rules template**

| # | Canonical path | Operation | One-line change description |
|---|----------------|-----------|------------------------------|
| B1 | `shamt-core/CHEATSHEET.md` | EDIT | Install/sync section: `<child>/shamt-core/` → `.shamt-core/`; init/import invocation paths; new locations for `shamt-config.json`, `proposals/`, `project-specific-files/`; document the new init completion prompt + validation loop. |
| B2 | `shamt-core/CLAUDE.md` | EDIT | "What lives here" / child-layout description: child install is `.shamt-core/`; root holds only `CLAUDE.md` + `.claude/`; all other Shamt content (config, proposals, project docs, CHEATSHEET) lives under `.shamt-core/`. |
| B3 | `shamt-core/templates/SHAMT_RULES.template.md` | EDIT | Update every `ARCHITECTURE.md`/`CODING_STANDARDS.md` reference → `.shamt-core/project-specific-files/…`; every `shamt-config.json` reference → `.shamt-core/shamt-config.json`; **the `CHEATSHEET.md` pointer (`SHAMT_RULES.template.md:24`, "`CHEATSHEET.md` — host wiring quick reference") → `.shamt-core/CHEATSHEET.md`** (this template renders into the child's *root* `CLAUDE.md`, so a bare `CHEATSHEET.md` resolves to the now-empty project root); any child-layout / proposals-path mention. |

**Group C — child-side install-path references (`shamt-core/` install dir → `.shamt-core/`)**

| # | Canonical path | Operation | One-line change description |
|---|----------------|-----------|------------------------------|
| C1 | `shamt-core/host/templates/claude/commands/import-shamt.md` + `skills/import-shamt/SKILL.md` | EDIT | Child-side script path `shamt-core/import-shamt.sh` → `.shamt-core/import-shamt.sh` in Prerequisites / Steps / examples. |
| C2 | `shamt-core/host/templates/claude/commands/regen-framework.md` + `skills/regen-framework/SKILL.md` | EDIT | **Dual-context — Phase 3 distinguishes.** Child-context regen invocation / prerequisite paths (`regen-framework.md:26`, `:37`, `:52`, `:68` — `shamt-core/scripts/regenerate-framework.sh`) become `.shamt-core/scripts/regenerate-framework.sh` for a child install. **Do NOT change** the self-host detection rule of thumb (`:29`), which keys off `{target}/shamt-core/` to identify the master self-host: a child install has `.shamt-core/` (not `shamt-core/`), so it correctly fails that test and is treated as a consumer. Mirror in the skill body. |
| C3 | `shamt-core/host/templates/claude/statusline.sh` | EDIT | Update any literal `shamt-core/` child-path reference. **Likely a no-op:** statusline's only `shamt-core/` literal is the master-canonical `Regenerate from shamt-core/host/templates/claude/statusline.sh` footer (stays). The substantive statusline edit is the `shamt-config.json` read in D3. |

**Group D — `shamt-config.json`-path sweep (`→ .shamt-core/shamt-config.json`)** *(the bulk of the ≈164 canonical config occurrences; Phase 3 enumerates the exact per-file/per-occurrence list)*

| # | Canonical path | Operation | One-line change description |
|---|----------------|-----------|------------------------------|
| D1 | `shamt-core/host/templates/claude/commands/{audit-framework,decompose-feature,define-spec,execute-plan,execute-tests,import-shamt,plan-implementation,regen-framework,review-changes,start-epic,start-feature,start-story,submit-proposal,write-manual-testing-plan,write-testing-plan}.md` | EDIT | Repoint every `shamt-config.json` read to `.shamt-core/shamt-config.json`. |
| D2 | `shamt-core/host/templates/claude/skills/{audit-framework,decompose-feature,execute-tests,import-shamt,plan-implementation,start-epic,start-feature,start-story,submit-proposal,write-manual-testing-plan,write-testing-plan}/SKILL.md` | EDIT | Mirror of D1 for each skill body. |
| D3 | `shamt-core/host/templates/claude/statusline.sh` | EDIT | Repoint the `shamt-config.json` read. **Nuance:** the read is **cwd-relative** at `statusline.sh:52`–`53` (`[ -f shamt-config.json ]` and `grep … shamt-config.json`) — both occurrences must become `.shamt-core/shamt-config.json` (the statusline runs with cwd = project root, where `.shamt-core/` is a subdir, so the prefixed relative path resolves). A missed occurrence does not error — it silently falls through to the default 6-phase scheme (see the `statusline.sh:43` comment), which makes the regression easy to overlook; the Phase-6 config gate grep must cover `statusline.sh`. |
| D4 | `shamt-core/reference/{story_support,trackers/_contract,trackers/ado,trackers/github,trackers/local}.md` | EDIT | Repoint `shamt-config.json` references. |
| D5 | `shamt-core/templates/{spec,testing_plan,manual_test_plan}.template.md` | EDIT | Repoint `shamt-config.json` references (SHAMT_RULES handled in B3). |

**Group E — `ARCHITECTURE.md` / `CODING_STANDARDS.md` doc-path sweep (`→ .shamt-core/project-specific-files/…`)**

| # | Canonical path | Operation | One-line change description |
|---|----------------|-----------|------------------------------|
| E1 | `shamt-core/host/templates/claude/commands/{start-epic,start-feature,define-spec,plan-implementation,review-changes,resolve-feedback,audit-framework,validate-artifact,write-testing-plan,write-manual-testing-plan}.md` | EDIT | Doc-path sweep. (**`validate-artifact` was the one omission** — it reads `ARCHITECTURE.md` / `CODING_STANDARDS.md` at `validate-artifact.md:61`, `:67`, `:120`, `:133`, all child-context, so it joins the sweep. Excluded after per-file confirmation: `start-story` carries no doc reference; `decompose-epic`/`decompose-feature` reference an epic *section* named "Architecture impact", not the `ARCHITECTURE.md` file.) |
| E2 | `shamt-core/host/templates/claude/skills/{start-epic,start-feature,define-spec,resolve-feedback,audit-framework,review-changes,write-testing-plan}/SKILL.md` | EDIT | Mirror of E1 for each skill body. (Per-file confirmed: of the E1 commands, only these seven have a doc reference in their *skill* body; `plan-implementation`, `start-story`, `validate-artifact`, and `write-manual-testing-plan` reference the docs in the command body only.) |
| E3 | `shamt-core/host/templates/claude/agents/{plan-executor,review-executor,test-executor,validation-checker}.md` | EDIT | Doc-path sweep in persona bodies. |
| E4 | `shamt-core/templates/{spec,context,code_review,implementation_plan,epic,feature,testing_plan,architecture,coding_standards}.template.md` + `shamt-core/reference/{implementation_plan_reference,mermaid_diagram_standards,review_categories}.md` | EDIT | Doc-path sweep across templates and reference docs that name the two project docs. |

**Group F — proposals-path sweep (project-root `proposals/` → `.shamt-core/proposals/`)**

| # | Canonical path | Operation | One-line change description |
|---|----------------|-----------|------------------------------|
| F1 | `shamt-core/host/templates/claude/commands/{propose-update,submit-proposal,import-shamt}.md` + `skills/{propose-update,submit-proposal,import-shamt}/SKILL.md` | EDIT | Repoint child-side project-root `proposals/` references (`proposals/{slug}.md`, `proposals/submitted/`, `proposals/already-merged/`, `proposals/_template.md`) to `.shamt-core/proposals/…`. These three flows act on the **child's local** proposals dir. **Master-canonical** path-discipline strings inside the same bodies (e.g. `propose-update`'s `shamt-core/proposals/` list describing master's layout) stay unchanged per the scope boundary — Phase 3 distinguishes child-side from master-canonical occurrences. |
| F1-excl | `triage-proposals`, `archive-proposal`, `implement-update`, `plan-update-implementation` (commands + skills) | NO EDIT | **Deliberately excluded — these four are the master-side-only steps of the framework-update flow** (the flow's authoring/submission steps — `propose-update`, `submit-proposal` — run child-side and ARE repointed, in F1). These four run only against master's `shamt-core/proposals/` (master keeps the `shamt-core/` layout), so their `proposals/` references are master-canonical and are **not** repointed. (`archive-proposal` was previously mis-listed in F1 skills — removed; it has no child-side proposals reference.) Phase 6's proposals gate grep must whitelist these files' `proposals/` occurrences as master-canonical. |
| F2 | `shamt-core/host/templates/claude/commands/resolve-feedback.md` + `skills/resolve-feedback/SKILL.md` | EDIT | Engineer-flow Phase 7 (child-only): repoint its `proposals/<slug>.md` root-cause-capture references → `.shamt-core/proposals/<slug>.md`. Occurrences: `resolve-feedback.md:12`, `:69`, `:89`, `:112`, `:123`; `resolve-feedback/SKILL.md:7`, `:32`, `:45`. These pointers are descriptive (the actual write is delegated to `/propose-update`), but must match the new location so they don't misdirect. |
| F3 | `shamt-core/host/templates/claude/commands/{validate-artifact,audit-framework}.md` | EDIT | **Dual-context descriptive references — Phase 3 judges.** `validate-artifact.md:28` and `:47` list `proposals/<slug>.md` as an example artifact path; `audit-framework.md:45` names `proposals/_template.md` in its D5 template list. Both commands run on master *and* child; on a child these resolve under `.shamt-core/`. Repoint only if Phase 3 confirms the occurrence is child-context (an example a child agent would follow), else leave master-canonical. |

**Group G — closing completion prompt**

| # | Canonical path | Operation | One-line change description |
|---|----------------|-----------|------------------------------|
| G1 | `shamt-core/init-shamt.sh` (closing block) | EDIT | Replace the closing "Next steps" summary with a clearly-delimited, copy/pastable prompt: instruct an agent to research the codebase, fill in `.shamt-core/project-specific-files/ARCHITECTURE.md` and `CODING_STANDARDS.md` (resolving open questions one at a time per Principle 2), then run `/validate-artifact .shamt-core/project-specific-files/ARCHITECTURE.md` and the same for `CODING_STANDARDS.md`. Literal `.shamt-core/…` paths so it works pasted into a fresh agent. Heredoc-safe (no unescaped `$`/backtick/`EOF` collisions). |

**`CHEATSHEET.md`-path sweep (small).** Because `CHEATSHEET.md` moves from the project root to `.shamt-core/CHEATSHEET.md` (A1 drops the root seed), a reference pointing a reader at a root-relative `CHEATSHEET.md` goes stale. The one confirmed child-facing occurrence is in `SHAMT_RULES.template.md` (handled in B3 — it renders into the child's root `CLAUDE.md`). Other `CHEATSHEET.md` mentions in canonical bodies are either relative links within `shamt-core/` (e.g. `reference/trackers/_contract.md`'s `../../CHEATSHEET.md`) or sync-set enumerations, all master-canonical and unchanged. Phase 3 runs a confirming grep for bare child-facing `CHEATSHEET.md`.

*(A1 & G1 are the same file — `init-shamt.sh` — split across groups for readability; Phase 3 collapses them into one per-file step list. Several command/skill files appear in more than one group, e.g. `start-story` in D and E — Phase 3 merges all edits to a given file into a single step.)*

---

## Risks

- **Regression risk — broken script paths.** The rename touches every literal `shamt-core/` child path in both scripts. A missed occurrence (e.g., the `regen_script` path or self-host candidate in `init-shamt.sh`) breaks install or regen silently. Mitigation: Phase 3 enumerates every literal; a self-host + clean-child install test in Validation Considerations.
- **Regression risk — `shamt-config.json` path sweep (highest-volume).** ~164 occurrences across ~30 files read the config. A single missed reader points at a now-absent root path and silently degrades (e.g. tracker detection falls through to freeform, testing gate misreads). Mitigation: Group D is enumerated mechanically in Phase 3; a post-implementation grep for bare `shamt-config.json` not prefixed by `.shamt-core/` (excluding `shamt-config.example.json` and master-self-host references) gates Phase 6.
- **Regression risk — doc-path & proposals references.** Commands/skills/agents that consult `ARCHITECTURE.md` at the root, or the proposals surface (`propose/submit/triage/archive/import`) pointing at root `proposals/`, will read a now-absent path if a reference is missed. Mitigation: exhaustive grep sweep, cross-checked command↔skill pairs (Groups E, F), **plus a Phase-6 gate grep symmetric with Group D's** — fail the gate on any child-side bare `ARCHITECTURE.md` / `CODING_STANDARDS.md` not prefixed by `.shamt-core/project-specific-files/`, and any child-side bare `proposals/` not prefixed by `.shamt-core/` (both excluding master-canonical / self-host occurrences the scope boundary preserves; Phase 3 enumerates the allow-list of occurrences that must stay bare). The doc list is precisely the kind of surface that is easy to under-enumerate, so a mechanical backstop — not just a manual sweep — gates Groups E and F.
- **`.claude/` must not be moved.** A tempting "tidy everything under `.shamt-core/`" reading would relocate `.claude/` too — that breaks Claude Code, which only discovers `.claude/` at the project root or `~/.claude`. The proposal explicitly keeps `.claude/` at root (Problem § "two hard exceptions"); Group A3 verifies regen still writes `<target>/.claude/`.
- **import-shamt preserve behavior for child-owned content.** With `shamt-config.json`, `proposals/{slug}.md`, and `project-specific-files/` now living *inside* `.shamt-core/`, the sync must not overwrite or delete them. They sit outside `MASTER_SYNC_FILES` and the `MASTER_SYNC_DIRS` (`scripts/templates/reference/host`) walk, so they are preserved by construction — but A2 must confirm this and ensure no spurious "preserving local file" warnings or accidental pruning. The synced `.shamt-core/proposals/_template.md` (master-owned) coexisting with child `proposals/{slug}.md` in the same dir must be verified.
- **Drift risk.** Host-template edits (Groups C, D, E, F) require `/regen-framework` to propagate into `.claude/`. Missing the regen leaves canonical and generated bodies out of sync. Standard Phase 5 step covers this.
- **Child-project compatibility (clean break — Q3).** Already-installed children have `shamt-core/` + root-level files. `import-shamt.sh` will NOT migrate them; the old layout keeps working in place until manually migrated. There are no real children installed yet, so blast radius is effectively zero today; the manual migration steps are documented in `CHANGES.md` at archive time.
- **Self-host special case.** `init-shamt.sh` self-host (installing onto the master repo) skips the framework copy and doc seeding and must keep master's `shamt-core/` layout + root `shamt-config.json`. Self-host detection keys off `<target>/shamt-core/init-shamt.sh`; master stays `shamt-core/`, so detection is unaffected — but this must be verified, and the config-write relocation (A1) must be gated on `SELF_HOST -eq 0`. **Precheck ordering trap:** the "already installed" precheck currently precedes self-host detection in `init-shamt.sh`, yet the config path it must test is now self-host-dependent. Repointing the precheck naively to `.shamt-core/shamt-config.json` would stop detecting master's root config on a self-host re-run, silently bypassing the overwrite guard. Mitigation: A1 moves the precheck after self-host detection (or dual-tests both paths); the self-host + clean-child install test must exercise a **re-run** against an already-installed target of each kind to confirm the guard still fires.

---

## Rollback Plan

1. `git revert <commit-sha>` on the canonical edit commit.
2. Run `/regen-framework` to propagate the revert into `.claude/`.
3. Child-side: any child that ran `init-shamt.sh` against the new version (creating `.shamt-core/` with config/proposals/project docs inside it) keeps that install; re-running `import-shamt.sh` from a reverted master will not move content back to the root automatically. New installs revert cleanly. Document the manual layout reversal in the revert commit message.
4. Communication: note in `CHANGES.md` that the install layout changed (and reverted), since it's a breaking layout change other children would feel.

---

## Validation Considerations

- **Problem clarity** — confirm the scope boundary (child-side only; master canonical paths stay `shamt-core/`) reads unambiguously. Terminology risk: "shamt-core" now means both the master repo name AND (formerly) the child dir; the proposal must keep those distinct.
- **Change-list completeness** — easy-to-miss paired edits: every command↔skill pair across Groups C/D/E/F; files appearing in *multiple* groups (e.g. `start-epic`/`start-feature` each take a config-path edit (D) AND a doc-path edit (E); `import-shamt` takes a config-path edit (D) AND a proposals-path edit (F)) must get every edit in one Phase-3 step; the two scripts' *internal* literals vs. their *user-facing message* literals (both must change); `regenerate-framework.sh` (A3) is the likely no-op — verify it resolves canonical root by script-dir and never names the child dir literally. The doc-sweep list (Group E) is per-file confirmed: `validate-artifact` joins E1 (its command body references the docs); `start-story`, `decompose-epic`, and `decompose-feature` do **not** reference the `ARCHITECTURE.md` / `CODING_STANDARDS.md` *files* (decompose names an epic *section* called "Architecture impact") and stay out; only the seven E2 skills carry a doc reference in their skill body.
- **Config-sweep precision (Group D)** — the highest-risk dimension. Confirm Phase 3 catches all ~164 occurrences and that NO occurrence is a *master-canonical* / self-host reference that must stay `shamt-config.json` at root (e.g. master-dev `CLAUDE.md`, `shamt-config.example.json` mentions). The Phase-6 gate grep must distinguish child-side from master-side.
- **Proposals consolidation (Group F)** — verify the child-side `proposals/` references repoint while master-canonical path-discipline `shamt-core/proposals/` strings stay. Confirm dropping the init root-seed + import root-mirror steps doesn't strand `/propose-update`, which must now read `.shamt-core/proposals/_template.md`.
- **Risk coverage** — verify the self-host path: master-repo self-install must still detect correctly, keep `shamt-core/` + root `shamt-config.json`, and NOT relocate anything. ⚠ Note the project-doc seeding (`init-shamt.sh:376–394`) and root `proposals/_template.md` seed (`:404–411`) are currently **ungated** (they run on self-host too), so A1's relocation must **add** a `SELF_HOST -eq 0` gate to preserve master's behaviour — verify the self-host run after the change still seeds at root (or, per A1, leaves master's existing root docs untouched) and does not create `.shamt-core/project-specific-files/` on master. Confirm `.claude/` is never moved.
- **Rollback feasibility** — the change is a MOVE of content into a renamed dir at install time, not a destructive canonical DELETE; canonical rollback is a plain revert. No git-history loss in canonical sources.
- **Affected surfaces** — scripts, root docs (CHEATSHEET, CLAUDE), rules template, commands, skills, personas, templates, reference docs, tracker references. Broad but mechanical.
- **Propagation plan** — requires `/regen-framework` (host-template edits) + a fresh `init-shamt.sh` run to see the new layout. Per Q3 (clean break), already-installed children are not migrated.
- **Completion-prompt correctness** — verify the pasted prompt's `/validate-artifact .shamt-core/project-specific-files/…` paths match the new seed location exactly, and that the prompt survives heredoc quoting in `init-shamt.sh` (no unescaped `$`, backticks, or `EOF` collisions in the closing block).

---

## Open Questions

*(none — all resolved; see below)*

---

## Resolved Questions

<!-- Appended as questions resolve. -->

- ~~Q1: Does the rename apply to child-install paths only, or also to master-canonical proposal path-discipline strings?~~ → A: **Child install only (A).** Rename the child install dir + child-facing script invocations to `.shamt-core/`; leave master-canonical `shamt-core/…` path-discipline strings unchanged so child proposals still submit against master's layout.
- ~~Q2: How far does the relocation into `.shamt-core/` go?~~ → A (revised): **Everything under `.shamt-core/`.** Only `CLAUDE.md` stays at the child project root; `.claude/` also stays at root as an unavoidable hard exception (Claude Code requires it there). All other Shamt-owned content moves under `.shamt-core/`: `CHEATSHEET.md`, `shamt-config.json`, `proposals/`, and `project-specific-files/{ARCHITECTURE,CODING_STANDARDS}.md`. *(Supersedes the initial "just the two docs / config + proposals stay at root" answer.)*
- ~~Q3: Clean break vs. auto-migrate existing children?~~ → A: **Clean break, new installs only.** `import-shamt.sh` does not migrate legacy `shamt-core/` installs. Document a one-time manual migration note in `CHANGES.md` at archive time.
- ~~Q4: Completion-prompt validation-loop shape?~~ → A: **Reuse `/validate-artifact`.** The pasted prompt drives the agent to fill both docs (research the codebase; resolve open questions one at a time per Principle 2), then run `/validate-artifact .shamt-core/project-specific-files/ARCHITECTURE.md` and `/validate-artifact .shamt-core/project-specific-files/CODING_STANDARDS.md` to solidify the content. No bespoke loop — leans on existing Pattern 1 machinery.

---

Validated 2026-05-28 — Standard path, final adversarial sub-agent confirmed (multiple primary + adversarial rounds). Substantive fixes this loop: **Group E** — added `validate-artifact` (the one genuine doc-path omission); confirmed `start-story`/`decompose-epic`/`decompose-feature` carry no `ARCHITECTURE.md`/`CODING_STANDARDS.md` *file* reference and excluded them. **Group F** — added `resolve-feedback` (F2) and dual-context `validate-artifact`/`audit-framework` (F3) with grep-verified line citations; re-scoped F1 to the three genuinely child-side flows and added F1-excl for the four master-side framework-update commands (removing a prior `archive-proposal` mis-listing). **Group A1** — fixed the self-host "already installed" precheck ordering trap, and gated the relocated doc-seeding on `SELF_HOST -eq 0` (the current seeding at `init-shamt.sh:376–394`/`:404–411` is ungated, so Phase 3 must ADD the gate). **C2** corrected the regen-framework dual-context detection; **B3** added the `SHAMT_RULES.template.md:24` CHEATSHEET repoint; **D3** captured the cwd-relative `statusline.sh:52–53` config read; **Risk coverage** corrected the inaccurate "master doesn't seed the project docs" note; the ≈164 config-occurrence figure was scoped to canonical sources. Per-occurrence locate strings remain deferred to Phase 3 (`/plan-update-implementation`) by design. NOTE: this validation session experienced intermittent tool-output rendering corruption; some mid-loop false edits were made and reverted once clean reads were re-established, and every file/line citation above was independently re-verified with deterministic `grep`/`awk`/`sed` commands and reconfirmed by the final adversarial sub-agent.
