# Proposal: project-specific-proposals

**Created:** 2026-06-22
**Status:** Implemented
**Number:** 52
**Proposed by:**
**Project context:**

---

## Problem

Shamt's framework-update flow (`/f1-propose-update` → `/validate-artifact` → `/f2`/`/f3-implement-update` → `/f4-regen-framework` → `/f6-archive-proposal`) is built for exactly one kind of change: an edit to the **canonical Shamt sources** (`templates/`, `reference/`, `host/templates/claude/`, `scripts/`, the root docs). Its hard rule — stated in `CLAUDE.md` §"The two surfaces", enforced at draft time by `/f1-propose-update` Step 3, again at edit time by `/f3-implement-update` Step 1 item 4 — is **canonical sources only; never edit generated `.claude/` files**. In a child project the canonical sources are themselves read-only copies (never edited directly; re-derived from master via `import-shamt`), so the *only* legitimate output of a child-authored proposal today is an upstream submission: `/f1-propose-update` drafts it, `/sync-proposals` ships it to master, and master implements it. There is **no supported, structured way to evolve a child's own project-owned files** — `.shamt-core/project-specific-files/ARCHITECTURE.md`, `CODING_STANDARDS.md`, `TESTING_STANDARDS.md` (seeded by `init-shamt.sh`, audited for staleness by `/f5-audit-framework` D6, consulted by `/pe1-define`, `/pf1-define`, the Spec/Test phases). These docs are child-owned and genuinely project-specific, but the framework offers no proposal/validate/implement loop for them. Changes to them happen ad hoc and ungoverned, outside the disciplined Pattern-1 loop every other Shamt artifact goes through.

There is also a missing **routing decision** at proposal-draft time. When something is wrong or wanted, the author must first answer a question the flow never asks: *is this a project-specific issue (fix it here, in this project's owned docs) or a framework issue (would master Shamt — and therefore every project — benefit from the change)?* Today every proposal is implicitly treated as a framework proposal, so a purely project-specific concern (e.g. "this repo's `CODING_STANDARDS.md` should forbid X") gets mis-modeled as an upstream framework change or, more often, is just edited by hand with no governance at all.

This proposal introduces a **second proposal class — project-specific** — that reuses the existing framework-update flow (author → validate → implement → archive) but is **scoped, routed, and constrained** differently: project-specific proposals live in a dedicated `.shamt-core/proposals/project-specific/` folder, never go upstream, and when implemented may edit **only** the project's own `project-specific-files/` tree. `/f1-propose-update` gains the routing question up front so every proposal is classified before drafting begins.

---

## Design (resolved)

- **Routing (child-only).** At the start of `/f1-propose-update`, **when running child-side**, ask one routing question via `AskUserQuestion`: *is this a **project-specific** change (edit this project's own `.shamt-core/project-specific-files/` docs) or a **framework** change (would benefit master Shamt and every project)?* On the **master** side the question is **not** asked — every master proposal is framework (Q1).
  - **Framework** → unchanged: proposal at `.shamt-core/proposals/{slug}.md`, upstream-bound via `/sync-proposals`.
  - **Project-specific** → proposal at `.shamt-core/proposals/project-specific/{slug}.md`; its Proposed Changes rows target `project-specific-files/` paths; **strictly local** (never goes upstream — Q3).
- **Class detection is by folder, not a status marker** (least-machinery, disk-authoritative): a proposal resolved under `proposals/project-specific/` is project-specific; anything else is framework. No new header field.
- **Edit-time whitelist (Q2).** For a project-specific proposal, `/f3-implement-update` enforces a **`.shamt-core/project-specific-files/`-only** whitelist that *replaces* the canonical-sources whitelist. Canonical sources, generated `.claude/`, and `shamt-config.json` all stay off-limits; both classes still forbid `.claude/`.
- **No git ceremony, no regen for the project-specific class.** In a child, `/.shamt-core/` is git-ignored (`init-shamt.sh` managed `.gitignore` block, proposal #19), so a project-specific proposal's edits to `project-specific-files/` — and the proposal/archive files themselves — are **untracked**. `/f3` therefore **skips** the `proposal/{slug}` branch creation, and `/f6` **skips** the squash-merge — the branch/commit machinery exists only to land *tracked* canonical edits, which this class has none of. `/f4-regen-framework` is **skipped** entirely (project-specific files are not propagated to `.claude/`); the `/f3` next-phase suggestion jumps straight to `/f6`. `/f4` itself needs no edit (it is slugless and simply isn't invoked for this class).
- **Reclassification escape hatch (no machinery).** Strictly local by default; if a project-specific concern turns out to generalize, the user manually `mv`s the file from `proposals/project-specific/` up to top-level `proposals/` and re-runs — folder location alone reclassifies it. Documented in the README, no special command.

## Proposed Changes

| # | Canonical path | Operation | One-line change description |
|---|----------------|-----------|------------------------------|
| 1 | `shamt-core/host/templates/claude/commands/f1-propose-update.md` | EDIT | Add the child-only **routing question** (Step 0, before template seed): project-specific vs framework. Route a project-specific proposal to `.shamt-core/proposals/project-specific/{slug}.md`; branch Slug-resolution + the Step-3 path-discipline / Step-6 exit-gate so project-specific rows are validated against the `project-specific-files/`-only whitelist (never canonical, never `.claude/`); document the class + folder. |
| 2 | `shamt-core/host/templates/claude/skills/f1-propose-update/SKILL.md` | EDIT | Generalize the **Exit criteria** line ("every Proposed Changes row points at a canonical (non-`.claude/`) path") to be class-accurate (canonical for framework proposals; `project-specific-files/` for project-specific); add a one-clause note to the frontmatter `description`. Protocol stays the pointer form. |
| 3 | `shamt-core/host/templates/claude/commands/f3-implement-update.md` | EDIT | Extend Slug resolution to also find `proposals/project-specific/{slug}.md`; in **Step 1 item 4 (Hard rule)** branch on class — project-specific proposals enforce the `.shamt-core/project-specific-files/`-only whitelist (halt on any path outside it); add a **Step 1.5** branch skipping `proposal/{slug}` branch creation for the project-specific (git-ignored) class; point the next-phase suggestion straight at `/f6` (skip `/f4`). |
| 4 | `shamt-core/host/templates/claude/skills/f3-implement-update/SKILL.md` | EDIT | Make the frontmatter `description` + the "Edits go to canonical sources; regen propagates" Exit-criteria note class-accurate (canonical+regen for framework; `project-specific-files/`, no regen, for project-specific). The "never edit `.claude/`" rule is unchanged (true for both). |
| 5 | `shamt-core/host/templates/claude/commands/f6-archive-proposal.md` | EDIT | Branch on class: a project-specific proposal archives to `proposals/project-specific/archive/{slug}.md` and **skips** the branch squash-merge / commit guards (nothing tracked) — flip Status to Implemented and `mv` the file. Framework path unchanged. |
| 6 | `shamt-core/host/templates/claude/skills/f6-archive-proposal/SKILL.md` | EDIT | Note the project-specific archive destination + the no-squash-merge variant in the frontmatter `description` / Exit criteria. Protocol stays the pointer form. |
| 7 | `shamt-core/host/templates/claude/commands/sync-proposals.md` | EDIT | Add `project-specific/` (and its `archive/`) to the **documented** subfolder-exclusion list in Step 2 (Prerequisites bullet 3 + Step 2 item 2) — project-specific proposals are strictly local and never submitted to master. Documentation-only: the Step 2 enumeration already uses a **top-level** `*.md` glob that excludes every subfolder, so `project-specific/` is excluded today; this row makes that exclusion explicit (mirroring how `submitted/`/`archive/`/`already-merged/` are listed), not new filtering logic. |
| 8 | `shamt-core/host/templates/claude/skills/sync-proposals/SKILL.md` | EDIT | Adjust the frontmatter `description` ("every active child-local proposal under `.shamt-core/proposals/`") to say **top-level** proposals, excluding the local-only `project-specific/` subfolder. |
| 9 | `shamt-core/README.md` | EDIT | Add a child-side note on the project-specific proposal class (routing question, `proposals/project-specific/` folder, `project-specific-files/`-only implement, skip regen, strictly local, manual reclassification). Place it where the **child** material lives — the child directory layout (the `proposals/` subtree at lines ~38–41, alongside `submitted/`/`already-merged/`) and/or the "Git-ignored in a child" note — **not** buried under §"Framework update flow (Part 3 — master-side)", which is explicitly master-side; if a pointer is added there, mark it as the child-only variant. |
| 10 | `shamt-core/CLAUDE.md` | EDIT | §"The two surfaces" / "How changes land": acknowledge the **third category** — child-owned `project-specific-files/` (neither canonical nor generated `.claude/`), evolved via the project-specific proposal class; the two existing hard rules (never edit canonical / never edit generated in a child) still stand. |
| 11 | `shamt-core/proposals/_template.md` | EDIT | Extend the top-of-file folder-layout comment to record the child-side `proposals/project-specific/{slug}.md` + `proposals/project-specific/archive/` locations (child-only; unnumbered; strictly local). |

**Phase 3 required — file count 11 > 10. Run `/f2-plan-update-implementation project-specific-proposals` before `/f3-implement-update`.**

---

## Risks

- **Regression risk** — the routing question and the second proposal class add branching to `/f1`, `/f3`, `/f6`. A mis-implemented branch could (a) mis-route a *framework* proposal into the local-only path so it never reaches master, or (b) let a *project-specific* proposal escape its whitelist and edit canonical sources. Mitigation: class is detected by folder, the `/f3` whitelist halts on any out-of-tree path, and the routing question is explicit (not inferred).
- **Drift risk** — project-specific files are *not* regenerated into `.claude/`; `/f4-regen-framework` is skipped for this class. The risk is the inverse of the usual one: an implementer who treats a project-specific proposal like a framework one would create a `proposal/{slug}` branch and try to squash-merge untracked (git-ignored) files. The `/f3`/`/f6` class branches prevent this.
- **Child-project compatibility** — the new `proposals/project-specific/` folder is created on first use (folders are not committed empty); the command/README/primer text propagates to installed children on the next `import-shamt`. Purely additive — the existing child-authored upstream path (top-level proposals → `/sync-proposals`) is untouched for framework-class proposals.
- **Open-questions debt** — none; all three resolved below before the change set was drafted.

---

## Rollback Plan

Revert the commit and re-run `/f4-regen-framework` (propagating the command/skill reverts into `.claude/`). No child-side action required beyond the next routine `import-shamt`. Purely additive folder/flow — no destructive DELETE or MOVE of existing artifacts.

---

## Validation Considerations

- **Change-list completeness** — the routing/class concept must land consistently across `/f1`, `/f3`, `/f6`, `sync-proposals`, README, CLAUDE.md, and the proposals `_template.md` layout. The four paired SKILL edits (rows 2/4/6/8) are **class-accuracy fixes to frontmatter `description` + Exit-criteria summaries only** — confirm each SKILL `## Protocol` stays the pure command-body pointer (no step paraphrase reintroduced — the D2 Command → Skill Protocol pointer rule).
- **Deliberate omission to scrutinize — `SHAMT_RULES.template.md`.** This proposal **does not** edit the rules template. Rationale: the framework-update flow's mechanics are not described in the rules file today (they live in command bodies + README + the primer); the rules file references `.shamt-core/proposals/` only as orientation. Adding the routing/class concept there would spend D12 size-budget for no normative gain. Validate this judgment against D3 (bidirectional coverage) and D12 (size budget) — if the validator deems a one-line layout note warranted, add it as an in-place amendment.
- **`/f4` skip correctness** — confirm that *not* editing `/f4-regen-framework` is correct: it is slugless and simply not invoked for the project-specific class; the skip is documented in `/f1`/`/f3` flow text, not enforced in `/f4` itself.
- **Master-side no-op** — verify the routing question is genuinely gated to child-side only (Q1): a master-side `/f1` run must behave exactly as today, with no new prompt.
- **Git-ceremony claim** — the no-branch/no-squash-merge simplification rests on `/.shamt-core/` being git-ignored in a child (`init-shamt.sh` `.gitignore` block, #19). Confirm that fact still holds in the current `init-shamt.sh`.
- **Affected surfaces** — commands, skills (pointer-only Protocol; description/exit-criteria touched), README, primer, proposal template. No `reference/`, no `scripts/`. **No `import-shamt.sh` change** — and confirm this is correct: `import-shamt.sh`'s already-merged auto-move scans only `proposals/` and `proposals/submitted/` with `find -maxdepth 1`, so the new `proposals/project-specific/` subfolder is naturally excluded (a strictly-local proposal never matches a master archive anyway); the `/sync-import-shamt` master-owned mirror covers `scripts/`/`templates/`/`reference/`/`host/`, not the user-owned `proposals/` subtree. The folder needs no script-level handling.
- **Propagation plan** — regen + child `import-shamt` to take effect; no manual child nudge.

---

## Open Questions

_None — all resolved below._

---

## Resolved Questions

- ~~Q1: Does the project-specific class apply on master too, or child-only?~~ → A: **Child-only.** Master proposals are always framework changes; the routing question, the `proposals/project-specific/` folder, and the local-implement constraint exist only in children. On master, `/f1` behaves as today (no routing prompt) — shamt-core has no `project-specific-files/` dir of its own.
- ~~Q2: Which paths may the implement step write for a project-specific proposal?~~ → A: **`.shamt-core/project-specific-files/` only** — the project docs (ARCHITECTURE/CODING_STANDARDS/TESTING_STANDARDS + any future files added there). Canonical sources, generated `.claude/`, and `shamt-config.json` stay off-limits. This is the new edit-time whitelist `/f3` enforces for the project-specific class, replacing (not extending) the canonical-sources whitelist.
- ~~Q3: Can a project-specific proposal go upstream via `/sync-proposals`, or is it strictly local?~~ → A: **Strictly local.** `/sync-proposals` excludes the `proposals/project-specific/` subfolder; only top-level (framework-class) child proposals are submitted to master. A manual `mv` up to top-level is the only (no-machinery) reclassification path.

---

Validated 2026-06-22 — 3 rounds, 1 adversarial sub-agent confirmed (validation-checker, zero issues).
