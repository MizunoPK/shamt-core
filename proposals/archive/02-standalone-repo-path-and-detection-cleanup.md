# Proposal: standalone-repo-path-and-detection-cleanup

**Created:** 2026-06-02
**Status:** Implemented
**Number:** 02
**Proposed by:**
**Project context:**
**Note (2026-06-05, f1 re-entry):** refreshed the f5 line-number citations after `audit-continuous-f0-draft-capture` (Implemented 2026-06-03) rewrote `f5-audit-framework.md` — detection 109/127→62/130, D1 step 62→83, D4 ref 88→109, f5-skill D1-summary 42→48; updated the standalone-repo status (in-flight→Implemented). f4/f5 line numbers verified against HEAD. No design change — policy B and the change-set scope are unchanged.

---

## Problem

The `shamt-core-standalone-repo` proposal (Implemented 2026-06-01) converted `shamt-core` from a nested subdirectory of the old `shamt-ai-dev-v2/` development container into its own top-level git repository. That proposal correctly swept the dead `../INFRASTRUCTURE.md` citations, removed the container narrative, and reworded self-host / master-side detection in **two** files (`host/templates/claude/commands/f1-propose-update.md`, `host/templates/claude/commands/sync-triage-proposals.md`). A Phase 6 `/f5-audit-framework` sweep found the migration is **incomplete** in two related ways — both rooted in the same stale assumption that `shamt-core/` is a nested subdirectory reachable from a parent working directory.

**① Self-host detection rule still keyed on a nested `shamt-core/` subdirectory.** Two command bodies the standalone proposal did not touch still detect the self-host the old way:

- `host/templates/claude/commands/f4-regen-framework.md:29` — *"the resolved target is the self-host iff `{target}/shamt-core/` exists and the canonical script `{target}/shamt-core/scripts/regenerate-framework.sh` is the same script being invoked…"*
- `host/templates/claude/commands/f5-audit-framework.md:62` (Step 0 target context) and `:130` (D6 "both missing") — *"the resolved target is the shamt-core self-host iff `{target}/shamt-core/` exists and the canonical sources at `{target}/shamt-core/host/templates/claude/` match…"*

In the standalone repo `{target}/shamt-core/` **does not exist** (the canonical sources are at the repo root: `host/`, `templates/`, `scripts/`, `reference/`). So this rule never fires when run from the master repo root → the master is mis-classified as a child project → `/f5-audit-framework` silently drops to **report-only** (auto-fix track disabled) and D6 emits **CRITICAL** ("project misconfigured") instead of the intended **LOW** not-applicable. This directly contradicts the standalone detector the same migration applied to `f1-propose-update.md` (now "the shamt-core repo with a top-level `proposals/`") and `sync-triage-proposals.md` (now `proposals/incoming/` presence). It is a host↔host contradiction (audit D2/D9).

**② Pervasive `shamt-core/`-prefixed operational paths are stale.** Many **no-dot** `shamt-core/`-prefixed references survive across the canonical surface. The exact count is **immaterial to this proposal and methodology-sensitive** — it swings with the grep flavor (whether `-o` adjacency is handled, lookbehind vs. consumed-char exclusion of the dot form, which sub-tree is scanned) — so it is deliberately **not** asserted as a figure. What matters is the *shape*: the **dot-prefixed** child-side `.shamt-core/` form (correct, and explicitly **out of scope**) dominates the surface and must be excluded from any no-dot count; of the no-dot `shamt-core/` hits that remain, the large majority are managed-file footer provenance strings (`Regenerate from shamt-core/host/…`) and prose qualifiers — **all of which policy B deliberately keeps**. Only a handful are master-side **operational/executable** paths or **detection** logic — and those are the entire scope of this fix. They encode the old container model (cwd = parent container; `shamt-core/` = subdir). At minimum the **executable / master-side operational** ones are outright broken from the repo root — proven during the audit run itself:

- `host/templates/claude/commands/f5-audit-framework.md:83` — the D1 step instructs `bash shamt-core/scripts/regenerate-framework.sh --check`; that path does not exist from the repo root (the audit had to run `scripts/regenerate-framework.sh`).
- `f5-audit-framework.md:34–35` (Prerequisites) — *"reads files under `shamt-core/templates/`, `shamt-core/reference/`, `shamt-core/host/templates/claude/`, and `shamt-core/scripts/`"* and *"`shamt-core/scripts/regenerate-framework.sh` exists"* — none resolve from cwd.

The freshly-rewritten `CLAUDE.md` primer already uses repo-root-relative paths in prose (`templates/SHAMT_RULES.template.md`, `host/templates/claude/`) and reserves `shamt-core/` for the tree-diagram root label — so the broken bodies are also *inconsistent* with the primer's new convention. (Note: `.shamt-core/` **with the dot** — the child-side imported copy — is correct and consistent everywhere and is **not** in scope.)

Net effect: the audit's own self-host detection and regen invocation are broken on the master repo, and a fresh agent reading any of the affected bodies is sent to paths that do not exist from the repo root.

---

## Proposed Changes

Policy **B (surgical)** from resolved Q1: fix only the master-side **operational/executable** paths and the **detection logic**; **keep** `shamt-core/` (no dot) as the deliberate "upstream master repo" qualifier in prose citations, and keep the managed-file footer as-is. This confines the change to **4 canonical files** (the f4 + f5 command/skill pairs) — **under 10 ops, so no Phase 3**.

The fix must distinguish three runtime contexts the regen script can be invoked from, and route the path accordingly:

- **Master self-host** (cwd = the shamt-core repo root) → `scripts/regenerate-framework.sh` (bare; this is what actually exists and what the D1 check runs).
- **Child project** (canonical copy imported under `.shamt-core/`) → `.shamt-core/scripts/regenerate-framework.sh`.
- The stale `shamt-core/scripts/...` (no-dot, nested-subdir) form is the old-container assumption and is removed.

**Which rows use which:** the master-vs-child routing applies to `/f4-regen-framework` (rows 3–4), which legitimately runs in **both** contexts. `/f5-audit-framework` is **master / self-host only** (Step 0 halts in a child and redirects), so its D1 regen invocation (rows 1–2) always uses the bare master form `scripts/regenerate-framework.sh` — **no child branch**. Both commands still keep the *detection* rule itself, since f5 must be able to detect a child in order to halt.

| # | Canonical path | Operation | One-line change description |
|---|----------------|-----------|------------------------------|
| 1 | `host/templates/claude/commands/f5-audit-framework.md` | EDIT | **Detection** (line 62 Step-0 target context & line 130 D6 "both missing"): replace the `{target}/shamt-core/`-exists rule with the **f1-aligned** standalone detector — lead with the *same* discriminator `f1-propose-update` and `sync-triage-proposals` already ship (self-host iff a top-level `{target}/proposals/` directory is present; child iff `{target}/.shamt-core/` carries the imported copy), **corroborated** by canonical sources at the root (`{target}/host/templates/claude/`, `{target}/templates/`, `{target}/scripts/regenerate-framework.sh`). The corroboration replaces the old "by path identity" phrasing and must **not** become a *stricter* primary signal than f1's — a detector that diverged from f1 would re-introduce the very host↔host detection contradiction this proposal removes (finding ①). Keep line 130's "same rule as /f4" cross-reference. **Operational** (Prereq line 35, D1 step line 83): strip the `shamt-core/` prefix → bare `scripts/regenerate-framework.sh`. **Prose rewords** — Prereq line 34 (`reads files under shamt-core/templates/, shamt-core/reference/, …`) → *"reads files under `templates/`, `reference/`, `host/templates/claude/`, and `scripts/`"*; D4 line 109 (`every canonical file under shamt-core/`) → *"every canonical file under the repo root"*. |
| 2 | `host/templates/claude/skills/f5-audit-framework/SKILL.md` | EDIT | Mirror row 1: line 48 D1-summary `bash shamt-core/scripts/regenerate-framework.sh` → bare `scripts/regenerate-framework.sh`. f5 is **master / self-host only** (Step 0 halts in a child), so the D1 regen invocation always uses the master form — **no `.shamt-core/` child branch and no multi-context routing here** (that routing is f4's concern, rows 3–4). |
| 3 | `host/templates/claude/commands/f4-regen-framework.md` | EDIT | **Detection** (line 29): replace `{target}/shamt-core/` + `{target}/shamt-core/scripts/regenerate-framework.sh` with the same **f1-aligned** standalone detector as row 1 (top-level `proposals/` ⇒ self-host / `.shamt-core/` ⇒ child, corroborated by root canonical sources). **Locate-order** (steps 36–37, code blocks 52 & 68): add the master self-host branch (bare `scripts/regenerate-framework.sh` when run from the shamt-core repo root) alongside the existing child `.shamt-core/scripts/...` branch, so the command works from the master root, not only a child/parent context. |
| 4 | `host/templates/claude/skills/f4-regen-framework/SKILL.md` | EDIT | Mirror row 3: line 35 "Resolve script path" gains the self-host branch (bare `scripts/...`) alongside the child `.shamt-core/scripts/...`; lines 37–38 run/check invocations follow the resolved path. |

**Explicitly out of scope under policy B (kept as upstream-qualifier prose / labels):** the remaining `shamt-core/`-prefixed citations (the large majority of the references above) in `CHEATSHEET.md`, `SHAMT_RULES.template.md`, `f1-propose-update.md`, `f3-implement-update.md`, the sync-* bodies, `proposals/_template.md`, references, and templates — these point a reader at *the upstream master repo's* canonical file (distinct from a child's local `.shamt-core/` copy) and are left intact. The managed-file footer (`Regenerate from shamt-core/host/...`) is likewise kept as a human-readable provenance string.

**Path discipline note:** no `.claude/` paths above. All 4 rows are under `host/templates/claude/**` → `/f4-regen-framework` + `--check` required after Phase 4.

---

## Risks

- **Regression risk** — the standalone-detector change (rows 1 & 3) is behavior-bearing: an incorrect detector would mis-classify *every* invocation (master-as-child or child-as-master), worse than the current single-direction break. The new detector must be tested from both a master checkout and a synced child before archive.
- **Lost-distinction risk** — *mitigated by the resolved policy B:* prose citations keep `shamt-core/` as the upstream-master-repo qualifier, so child-rendered docs (`SHAMT_RULES.template.md` → child `CLAUDE.md`) retain the distinction from a child's local `.shamt-core/` copy. The residual risk is the inverse — an implementer over-reaching and stripping a *prose* citation; Phase 4 must touch only the 4 listed operational/detection files.
- **Drift risk** — all four rows edit `host/templates/claude/**` files and must be propagated via `/f4-regen-framework`; skipping regen leaves the generated `.claude/` bodies pointing at the stale `shamt-core/` paths (itself a D1 finding next audit).
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
- **Change-list completeness** — the four rows are two command↔skill pairs (f5 cmd ↔ f5 skill, f4 cmd ↔ f4 skill); editing a command without its mirrored skill reintroduces inconsistency. The f5 `:130` detection must stay in lock-step with f4 `:29` ("same rule as /f4"). Completeness is **not** a "grep returns 0" check here — policy B *intentionally* leaves the prose `shamt-core/` qualifiers in place; the validator confirms only that the 4 operational/detection files no longer carry a master-side path that fails to resolve from the repo root, and that no prose citation outside the 4 files was touched.
- **Self-host detection correctness** — the new detector must (a) classify the master repo root as self-host, (b) classify a synced child (`.shamt-core/` present, no top-level `host/`+`proposals/`) as child, and (c) **agree with the f1 / sync-triage detectors by construction** — it leads with the *same* primary discriminator (top-level `proposals/` ⇒ self-host; `.shamt-core/` ⇒ child), with canonical-source presence as corroboration only. It must **not** be specified as *stricter* than f1's signal: a detector that classified a dir as child where f1 calls it master would re-create the host↔host detection contradiction this proposal exists to remove (finding ①). The validator confirms the f4/f5 detector and the f1/sync-triage detectors cannot disagree on the `proposals/`-vs-`.shamt-core/` signal.
- **Affected surfaces** — exactly the four f4/f5 command + skill files (policy B). The rules template, CHEATSHEET, references, templates, the proposal template, and the root scripts are **out of scope** — their `shamt-core/` mentions are deliberately-kept upstream-master-repo prose qualifiers (the root scripts were already swept for `INFRASTRUCTURE.md` during the standalone migration). The validator confirms nothing outside the four files was touched.
- **Propagation plan** — regen required for the `host/templates/claude/**` rows; `--check` for zero drift after Phase 4; re-audit to confirm the detection fix.

---

## Open Questions

*(none — all resolved)*

---

## Resolved Questions

<!-- Drafting-only log. -->

- ~~Should this be a new proposal or an amendment to the in-flight `shamt-core-standalone-repo` proposal?~~ → A: **New follow-up proposal** (user choice, 2026-06-02). The standalone proposal is already validated and in Phase 6; a clean follow-up keeps its validated change-set and footer intact.
- ~~Q1: How should the pervasive `shamt-core/`-prefixed references be normalized — (A) strip everywhere, (B) strip only operational/master-side paths and keep prose qualifiers, (C) explicit phrase where the distinction matters?~~ → A: **Policy B — surgical** (user choice, 2026-06-02). `shamt-core/` (no dot) is a deliberate "upstream master repo" qualifier, distinct from a child's local `.shamt-core/` (dot) copy, and is **kept** in prose citations and the managed-file footer. Only the master-side operational/executable paths and the self-host detection logic are fixed → scope collapses to the 4 f4/f5 command/skill files; no Phase 3.

---
Validated 2026-06-05 — 7 rounds, 1 adversarial sub-agent confirmed (5 sub-agent passes; earlier passes caught: a brittle, methodology-sensitive `shamt-core/` count claim → removed as immaterial and non-reproducible; an f5-skill `.shamt-core/` child branch that cannot apply to the master-only f5 → corrected to the bare master form; a proposed f4/f5 detector specified *stricter* than f1's → realigned to lead with f1's `proposals/`-vs-`.shamt-core/` discriminator, with canonical sources as corroboration; vague prose-reword guidance → made concrete; plus the f1-re-entry refresh of all f5 line numbers after the audit-continuous rewrite)
