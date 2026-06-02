# Proposal: standalone-repo-path-and-detection-cleanup

**Created:** 2026-06-02
**Status:** Draft
**Proposed by:**
**Project context:**

---

## Problem

The `shamt-core-standalone-repo` proposal (now in flight / Phase 6) converted `shamt-core` from a nested subdirectory of the old `shamt-ai-dev-v2/` development container into its own top-level git repository. That proposal correctly swept the dead `../INFRASTRUCTURE.md` citations, removed the container narrative, and reworded self-host / master-side detection in **two** files (`host/templates/claude/commands/f1-propose-update.md`, `host/templates/claude/commands/sync-triage-proposals.md`). A Phase 6 `/f5-audit-framework` sweep found the migration is **incomplete** in two related ways — both rooted in the same stale assumption that `shamt-core/` is a nested subdirectory reachable from a parent working directory.

**① Self-host detection rule still keyed on a nested `shamt-core/` subdirectory.** Two command bodies the standalone proposal did not touch still detect the self-host the old way:

- `host/templates/claude/commands/f4-regen-framework.md:29` — *"the resolved target is the self-host iff `{target}/shamt-core/` exists and the canonical script `{target}/shamt-core/scripts/regenerate-framework.sh` is the same script being invoked…"*
- `host/templates/claude/commands/f5-audit-framework.md:109` and `:127` — *"the resolved target is the shamt-core self-host iff `{target}/shamt-core/` exists and the canonical sources at `{target}/shamt-core/host/templates/claude/` match…"*

In the standalone repo `{target}/shamt-core/` **does not exist** (the canonical sources are at the repo root: `host/`, `templates/`, `scripts/`, `reference/`). So this rule never fires when run from the master repo root → the master is mis-classified as a child project → `/f5-audit-framework` silently drops to **report-only** (auto-fix track disabled) and D6 emits **CRITICAL** ("project misconfigured") instead of the intended **LOW** not-applicable. This directly contradicts the standalone detector the same migration applied to `f1-propose-update.md` (now "the shamt-core repo with a top-level `proposals/`") and `sync-triage-proposals.md` (now `proposals/incoming/` presence). It is a host↔host contradiction (audit D2/D9).

**② Pervasive `shamt-core/`-prefixed operational paths are stale.** ~357 `shamt-core/`-prefixed path references survive across ~30 canonical files. They encode the old container model (cwd = parent container; `shamt-core/` = subdir). At minimum the **executable / master-side operational** ones are outright broken from the repo root — proven during the audit run itself:

- `host/templates/claude/commands/f5-audit-framework.md:62` — the D1 step instructs `bash shamt-core/scripts/regenerate-framework.sh --check`; that path does not exist from the repo root (the audit had to run `scripts/regenerate-framework.sh`).
- `f5-audit-framework.md:34–35` (Prerequisites) — *"reads files under `shamt-core/templates/`, `shamt-core/reference/`, `shamt-core/host/templates/claude/`, and `shamt-core/scripts/`"* and *"`shamt-core/scripts/regenerate-framework.sh` exists"* — none resolve from cwd.

The freshly-rewritten `CLAUDE.md` primer already uses repo-root-relative paths in prose (`templates/SHAMT_RULES.template.md`, `host/templates/claude/`) and reserves `shamt-core/` for the tree-diagram root label — so the broken bodies are also *inconsistent* with the primer's new convention. (Note: `.shamt-core/` **with the dot** — the child-side imported copy — is correct and consistent everywhere and is **not** in scope.)

Net effect: the audit's own self-host detection and regen invocation are broken on the master repo, and a fresh agent reading any of the ~30 affected bodies is sent to paths that do not exist from the repo root.

---

## Proposed Changes

Policy **B (surgical)** from resolved Q1: fix only the master-side **operational/executable** paths and the **detection logic**; **keep** `shamt-core/` (no dot) as the deliberate "upstream master repo" qualifier in prose citations, and keep the managed-file footer as-is. This confines the change to **4 canonical files** (the f4 + f5 command/skill pairs) — **under 10 ops, so no Phase 3**.

The fix must distinguish three runtime contexts the regen script can be invoked from, and route the path accordingly:

- **Master self-host** (cwd = the shamt-core repo root) → `scripts/regenerate-framework.sh` (bare; this is what actually exists and what the D1 check runs).
- **Child project** (canonical copy imported under `.shamt-core/`) → `.shamt-core/scripts/regenerate-framework.sh`.
- The stale `shamt-core/scripts/...` (no-dot, nested-subdir) form is the old-container assumption and is removed.

| # | Canonical path | Operation | One-line change description |
|---|----------------|-----------|------------------------------|
| 1 | `host/templates/claude/commands/f5-audit-framework.md` | EDIT | **Detection** (lines 109 & 127): replace `{target}/shamt-core/` exists + `{target}/shamt-core/host/templates/claude/` with the standalone detector — self-host iff the target root directly carries canonical sources (`{target}/host/templates/claude/`, `{target}/templates/`, `{target}/scripts/regenerate-framework.sh`) plus a top-level `{target}/proposals/`; child iff `{target}/.shamt-core/` carries them. Keep :127's "same rule as /f4" cross-reference. **Operational** (Prereq line 35, D1 step line 62): strip the `shamt-core/` prefix → bare `scripts/regenerate-framework.sh` for the self-host context. Prereq line 34 + D4 line 88 ("reads files under `shamt-core/templates/`…" / "every canonical file under `shamt-core/`"): reword to "the canonical root" / repo-root-relative so it resolves from the repo root. |
| 2 | `host/templates/claude/skills/f5-audit-framework/SKILL.md` | EDIT | Mirror row 1: line 42 D1-summary `bash shamt-core/scripts/regenerate-framework.sh` → bare `scripts/regenerate-framework.sh` (self-host) / `.shamt-core/scripts/...` (child) per the same three-context routing. |
| 3 | `host/templates/claude/commands/f4-regen-framework.md` | EDIT | **Detection** (line 29): replace `{target}/shamt-core/` + `{target}/shamt-core/scripts/regenerate-framework.sh` with the same standalone detector as row 1. **Locate-order** (steps 36–37, code blocks 52 & 68): add the master self-host branch (bare `scripts/regenerate-framework.sh` when run from the shamt-core repo root) alongside the existing child `.shamt-core/scripts/...` branch, so the command works from the master root, not only a child/parent context. |
| 4 | `host/templates/claude/skills/f4-regen-framework/SKILL.md` | EDIT | Mirror row 3: line 35 "Resolve script path" gains the self-host branch (bare `scripts/...`) alongside the child `.shamt-core/scripts/...`; lines 37–38 run/check invocations follow the resolved path. |

**Explicitly out of scope under policy B (kept as upstream-qualifier prose / labels):** the ~349 remaining `shamt-core/`-prefixed citations in `CHEATSHEET.md`, `SHAMT_RULES.template.md`, `f1-propose-update.md`, `f3-implement-update.md`, the sync-* bodies, `proposals/_template.md`, references, and templates — these point a reader at *the upstream master repo's* canonical file (distinct from a child's local `.shamt-core/` copy) and are left intact. The managed-file footer (`Regenerate from shamt-core/host/...`) is likewise kept as a human-readable provenance string.

**Path discipline note:** no `.claude/` paths above. All 4 rows are under `host/templates/claude/**` → `/f4-regen-framework` + `--check` required after Phase 4.

---

## Risks

- **Regression risk** — Group A is behavior-bearing: an incorrect standalone detector would mis-classify *every* invocation (master-as-child or child-as-master), worse than the current single-direction break. The new detector must be tested from both a master checkout and a synced child before archive.
- **Lost-distinction risk** — *mitigated by the resolved policy B:* prose citations keep `shamt-core/` as the upstream-master-repo qualifier, so child-rendered docs (`SHAMT_RULES.template.md` → child `CLAUDE.md`) retain the distinction from a child's local `.shamt-core/` copy. The residual risk is the inverse — an implementer over-reaching and stripping a *prose* citation; Phase 4 must touch only the 4 listed operational/detection files.
- **Drift risk** — Group A row 2 and any `host/templates/claude/**` rows in Group B must be propagated via `/f4-regen-framework`; skipping regen leaves the generated `.claude/` bodies pointing at the stale `shamt-core/` paths (itself a D1 finding next audit).
- **Self-host meta-edit** — this proposal edits `/f4-regen-framework` and `/f5-audit-framework`, the very commands used to land and verify it. Phase 4 must regen and then re-run `/f5-audit-framework` to confirm the new detector resolves the master correctly (D6 → LOW not-applicable, auto-fix track enabled).
- **Child-project compatibility** — installed children pick up the reworded sources on the next `/sync-import-shamt`. Because nothing is repointed to a *new* in-repo target (paths are either stripped or kept as upstream-name qualifiers), no child inherits a fresh dead link.
- **Open-questions debt** — Q1 is the only blocking decision; it is resolved in-dialog before the proposal is considered drafted.

---

## Rollback Plan

1. `git revert <commit-sha>` on the canonical edit commit.
2. Run `/f4-regen-framework` to propagate the revert into `.claude/`.
3. No child-side action required beyond the next routine `/sync-import-shamt`.
4. Communication: none beyond the changelog.

---

## Validation Considerations

- **Problem clarity** — the two findings share one root cause (stale nested-subdir assumption) but are distinct fixes (detection logic vs path-string normalization); verify the validator does not collapse them.
- **Change-list completeness** — the four rows are two command↔skill pairs (f5 cmd ↔ f5 skill, f4 cmd ↔ f4 skill); editing a command without its mirrored skill reintroduces inconsistency. The f5 `:127` detection must stay in lock-step with f4 `:29` ("same rule as /f4"). Completeness is **not** a "grep returns 0" check here — policy B *intentionally* leaves the ~349 prose `shamt-core/` qualifiers in place; the validator confirms only that the 4 operational/detection files no longer carry a master-side path that fails to resolve from the repo root, and that no prose citation outside the 4 files was touched.
- **Self-host detection correctness** — the new detector must (a) classify the master repo root as self-host, (b) classify a synced child (`.shamt-core/` present, no top-level `host/`+`proposals/`) as child, and (c) agree with the f1 / sync-triage detectors the standalone proposal already shipped.
- **Affected surfaces** — commands (f4, f5, + Group B set), the rules template, CHEATSHEET, references, templates, the proposal template, and the two root scripts only if they carry a `shamt-core/` path (they were swept for `INFRASTRUCTURE.md` already — re-grep for `shamt-core/`).
- **Propagation plan** — regen required for the `host/templates/claude/**` rows; `--check` for zero drift after Phase 4; re-audit to confirm the detection fix.

---

## Open Questions

*(none — all resolved)*

---

## Resolved Questions

<!-- Drafting-only log. -->

- ~~Should this be a new proposal or an amendment to the in-flight `shamt-core-standalone-repo` proposal?~~ → A: **New follow-up proposal** (user choice, 2026-06-02). The standalone proposal is already validated and in Phase 6; a clean follow-up keeps its validated change-set and footer intact.
- ~~Q1: How should the ~357 `shamt-core/`-prefixed references be normalized — (A) strip everywhere, (B) strip only operational/master-side paths and keep prose qualifiers, (C) explicit phrase where the distinction matters?~~ → A: **Policy B — surgical** (user choice, 2026-06-02). `shamt-core/` (no dot) is a deliberate "upstream master repo" qualifier, distinct from a child's local `.shamt-core/` (dot) copy, and is **kept** in prose citations and the managed-file footer. Only the master-side operational/executable paths and the self-host detection logic are fixed → scope collapses to the 4 f4/f5 command/skill files; no Phase 3.

---
