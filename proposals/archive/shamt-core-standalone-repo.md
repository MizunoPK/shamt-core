# Proposal: shamt-core-standalone-repo

**Created:** 2026-06-01
**Status:** Implemented
**Proposed by:**
**Project context:**

---

## Problem

`shamt-core` is now its own top-level git repository (`git rev-parse --show-toplevel` → `/home/kai/code/shamt-core`). It is no longer a subdirectory of the `shamt-ai-dev-v2/` development container. The parent container and its siblings are gone: there is no `../INFRASTRUCTURE.md`, no repo-root `../CLAUDE.md` one level up, and no sibling `_reference/` prior-art tree.

The canonical sources still describe the old container layout and link to files that no longer exist relative to the repo:

- **`CLAUDE.md`** (master-dev primer) describes shamt-core as living "inside the `shamt-ai-dev-v2/` development container," references "The repo-root `CLAUDE.md` (one level up …)" (line 5 and line 87), points the out-of-scope rationale at `../INFRASTRUCTURE.md` (line 73), and carries a whole `## Working alongside _reference/` section (lines 97–104) that the file itself flags as obsolete the moment shamt-core is "extracted into its own repository."
- **`../INFRASTRUCTURE.md` is referenced 75 times across 29 canonical files** — 73 in Markdown (CHEATSHEET.md, most `host/templates/claude/commands/*.md` and several skills, `reference/audit_dimensions.md`, `reference/trackers/*.md`, `templates/epic.template.md`, `templates/feature.template.md`), plus 2 in the canonical shell scripts `import-shamt.sh` and `init-shamt.sh`. The references deep-link 15 distinct anchors (e.g. `#21-what-epicfeature-work-actually-needs`, `#111-issue-tracker-integration-ado--github-cli`, `#part-4-masterchild-sync`) and treat the planning log as the authoritative design-rationale source. Every one of these links now resolves outside the repo to a file that no longer exists.
- **Self-host / master-side detection assumes a nested `shamt-core/` subdirectory.** `host/templates/claude/commands/sync-triage-proposals.md` line 27 states "(Both sides have `shamt-core/` as a subdirectory, so its presence is NOT a master indicator.)" and the `/f1-propose-update` command prerequisites say "Run from a project root that has `shamt-core/` (master-side)." With shamt-core standalone, the master *is* the repo — there is no nested `shamt-core/` subdirectory to detect.
- **`reference/audit_dimensions.md` line 105** explicitly scopes "the repo-root `../INFRASTRUCTURE.md` planning log" out of the audit surface — wording that assumes the file sits one level above the canonical tree.

Net effect: a fresh agent reading the primer is told an inaccurate story about where it is, and 75 design-rationale citations across the framework are dead. The exact change set depends on what happened to `INFRASTRUCTURE.md` (resolved below in Resolved Questions).

---

## Proposed Changes

All-in-one scope (Q2): the primer/container narrative, the self-host / master-side detection wording, and the full sweep of dead `../INFRASTRUCTURE.md` deep-links (Markdown **and** the two canonical shell scripts). **30 canonical file operations — Phase 3 required** (see note after the table).

**Link-removal policy (from Q1 — INFRASTRUCTURE.md is abandoned):** for each `INFRASTRUCTURE.md` citation, (a) when the sentence already states the rule inline and merely cites the log as its source, drop the citation and keep the prose; (b) when the citation is a bare "see §X for full context" pointer, drop the pointer (it now resolves nowhere); (c) when the citation is the *sole* carrier of load-bearing design rationale, inline a one-line summary in place of the link. No link is repointed — the target no longer exists in or near the repo.

**Group A — Primer & container narrative**

| # | Canonical path | Operation | One-line change description |
|---|----------------|-----------|------------------------------|
| 1 | `shamt-core/CLAUDE.md` | EDIT | Restate shamt-core as its own standalone repo: drop "repo-root `CLAUDE.md` one level up, in the v2 development container" (line 5) and the matching note in **Commit conventions** (line 87); remove the `../INFRASTRUCTURE.md` rationale link in **What's deliberately out of scope** (line 73); delete the now-obsolete `## Working alongside _reference/` section (lines 97–104) — the only genuine sibling-`_reference/` reference in the canonical surface. |

**Group B — Self-host / master-side detection wording** (master is now the repo itself, not a nested `shamt-core/` subdirectory; the existing `proposals/incoming/`-presence discriminator is unchanged, so these are wording/logic-alignment fixes)

| # | Canonical path | Operation | One-line change description |
|---|----------------|-----------|------------------------------|
| 2 | `shamt-core/host/templates/claude/commands/f1-propose-update.md` | EDIT | Prereq line 25: replace "Run from a project root that has `shamt-core/` (master-side)" with standalone-repo wording (master-side = running inside the shamt-core repo with top-level `proposals/`; child-side = a synced framework + `.shamt-core/proposals/`). |
| 3 | `shamt-core/host/templates/claude/commands/sync-triage-proposals.md` | EDIT | Line 27: drop the now-false parenthetical "(Both sides have `shamt-core/` as a subdirectory, so its presence is NOT a master indicator.)" and apply the link-removal policy to the `§4.4 / §4.8` INFRASTRUCTURE.md citation; keep the `proposals/incoming/`-presence discriminator. |

**Group C — `../INFRASTRUCTURE.md` dead-link sweep** (apply the link-removal policy per file)

| # | Canonical path | Operation | One-line change description |
|---|----------------|-----------|------------------------------|
| 4 | `shamt-core/CHEATSHEET.md` | EDIT | Remove/inline 7 INFRASTRUCTURE.md citations (§4.8, §4.11, Part 4, §1.11, §2.1×2, §2.2, §2.3). |
| 5 | `shamt-core/reference/audit_dimensions.md` | EDIT | Line 105: the "INFRASTRUCTURE.md is out of the audit surface" carve-out is now moot (the repo-root planning log no longer exists). Remove the carve-out rather than just the link. |
| 6 | `shamt-core/reference/trackers/_contract.md` | EDIT | Remove/inline 2 INFRASTRUCTURE.md citations. |
| 7 | `shamt-core/reference/trackers/ado.md` | EDIT | Remove/inline 1 INFRASTRUCTURE.md citation. |
| 8 | `shamt-core/reference/trackers/github.md` | EDIT | Remove/inline 1 INFRASTRUCTURE.md citation. |
| 9 | `shamt-core/templates/epic.template.md` | EDIT | Remove/inline 1 INFRASTRUCTURE.md citation. |
| 10 | `shamt-core/templates/feature.template.md` | EDIT | Remove/inline 1 INFRASTRUCTURE.md citation. |
| 11 | `shamt-core/host/templates/claude/commands/p1-start-epic.md` | EDIT | Remove/inline 7 INFRASTRUCTURE.md citations (§1.11, §1.12, §2.1×n). |
| 12 | `shamt-core/host/templates/claude/commands/p2-decompose-epic.md` | EDIT | Remove/inline 9 INFRASTRUCTURE.md citations. |
| 13 | `shamt-core/host/templates/claude/commands/p3-start-feature.md` | EDIT | Remove/inline 8 INFRASTRUCTURE.md citations. |
| 14 | `shamt-core/host/templates/claude/commands/p4-decompose-feature.md` | EDIT | Remove/inline 11 INFRASTRUCTURE.md citations. |
| 15 | `shamt-core/host/templates/claude/commands/e5-execute-tests.md` | EDIT | Remove/inline 2 INFRASTRUCTURE.md citations. |
| 16 | `shamt-core/host/templates/claude/commands/e5b-write-manual-testing-plan.md` | EDIT | Remove/inline 3 INFRASTRUCTURE.md citations (§1.15 ×n). |
| 17 | `shamt-core/host/templates/claude/commands/e6-review-changes.md` | EDIT | Remove/inline 2 INFRASTRUCTURE.md citations. |
| 18 | `shamt-core/host/templates/claude/commands/sync-import-shamt.md` | EDIT | Remove/inline 1 INFRASTRUCTURE.md citation. |
| 19 | `shamt-core/host/templates/claude/commands/sync-submit-proposal.md` | EDIT | Remove/inline 2 INFRASTRUCTURE.md citations. |
| 20 | `shamt-core/host/templates/claude/agents/test-executor.md` | EDIT | Remove/inline 1 INFRASTRUCTURE.md citation. |
| 21 | `shamt-core/host/templates/claude/agents/review-executor.md` | EDIT | Remove/inline 1 INFRASTRUCTURE.md citation. |
| 22 | `shamt-core/host/templates/claude/skills/p1-start-epic/SKILL.md` | EDIT | Remove/inline 1 INFRASTRUCTURE.md citation (mirror of row 11). |
| 23 | `shamt-core/host/templates/claude/skills/p2-decompose-epic/SKILL.md` | EDIT | Remove/inline 2 INFRASTRUCTURE.md citations (mirror of row 12). |
| 24 | `shamt-core/host/templates/claude/skills/p3-start-feature/SKILL.md` | EDIT | Remove/inline 1 INFRASTRUCTURE.md citation (mirror of row 13). |
| 25 | `shamt-core/host/templates/claude/skills/p4-decompose-feature/SKILL.md` | EDIT | Remove/inline 2 INFRASTRUCTURE.md citations (mirror of row 14). |
| 26 | `shamt-core/host/templates/claude/skills/e5b-write-manual-testing-plan/SKILL.md` | EDIT | Remove/inline 1 INFRASTRUCTURE.md citation (mirror of row 16). |
| 27 | `shamt-core/host/templates/claude/skills/sync-import-shamt/SKILL.md` | EDIT | Remove/inline 2 INFRASTRUCTURE.md citations (mirror of row 18). |
| 28 | `shamt-core/host/templates/claude/skills/sync-submit-proposal/SKILL.md` | EDIT | Remove/inline 1 INFRASTRUCTURE.md citation (`§4.3 Option B`, line 12; mirror of row 19). |

> Note: every "master-side" / "child-side" mention that is a *role label* (a semantic actor in the sync flow, not a "has a nested `shamt-core/` subdirectory" structural claim) is retained across all files — only the dead INFRASTRUCTURE.md citations and the structural-subdirectory wording are swept. `sync-submit-proposal/SKILL.md` is edited (row 28) because it does carry an `INFRASTRUCTURE.md §4.3` citation, not only the role label.

**Group D — Canonical shell scripts** (root-level scripts copied into a child's `.shamt-core/` on `/sync-import-shamt`; NOT regenerated into `.claude/`, so these two need no `/f4-regen-framework` step — but the dead citation must still be swept)

| # | Canonical path | Operation | One-line change description |
|---|----------------|-----------|------------------------------|
| 29 | `shamt-core/import-shamt.sh` | EDIT | Line 16 comment cites `INFRASTRUCTURE.md §4.7`. Apply link-removal policy case (a) — keep the inline rationale, drop the dead reference. |
| 30 | `shamt-core/init-shamt.sh` | EDIT | Line 37 comment cites `INFRASTRUCTURE.md §4.12`. Apply link-removal policy case (a) — keep the inline rationale, drop the dead reference. |

**Phase 3 required — file count 30 > 10. Run `/f2-plan-update-implementation shamt-core-standalone-repo` before `/f3-implement-update`.**

---

## Risks

- **Regression risk** — most edits are pure citation removal and carry no behavioral change. The genuine risk is *lost rationale*: when policy-case (c) applies (the citation was the sole carrier of a load-bearing rule), a careless strip would delete meaning the framework relies on (e.g. the tracker field-mapping rules cited from §1.11, the epic/feature folder-structure rules cited from §2.1). Phase 3 must flag each case-(c) citation explicitly so the inline summary is written, not dropped.
- **Drift risk** — 20 of the 30 files live under `host/templates/claude/**` and must be propagated via `/f4-regen-framework`; skipping regen leaves the generated `.claude/` bodies pointing at the dead `../../../../../INFRASTRUCTURE.md` paths. The 2 root scripts (rows 29–30) are copied into a child's `.shamt-core/` on `/sync-import-shamt` rather than regenerated, so they need no `/f4-regen-framework` step.
- **Command ↔ skill pairing** — rows 11–14, 16, 18, 19 (PO + e5b + sync-import + sync-submit commands) each have a mirrored SKILL.md (rows 22–28); editing the command without its skill (or vice versa) reintroduces inconsistency. Pairs are enumerated in the table so the validator can cross-check.
- **Child-project compatibility** — installed children pick up the reworded sources on the next `/sync-import-shamt`; because no link is repointed (the target is gone, not relocated), there is no risk of children inheriting a fresh dead link to an in-repo file.
- **Open-questions debt** — both questions (INFRASTRUCTURE.md fate, proposal scope) are resolved below; the link-removal policy and the self-host detection fix follow deterministically, so no decision is deferred to the next agent.
- **Self-host meta-edit** — row 2 edits `/f1-propose-update` itself, the command authoring this proposal. The change is wording-only and does not alter the phase-per-command contract, but Phase 4 should regen and re-confirm the command still resolves slugs from the standalone-repo root.

---

## Rollback Plan

1. `git revert <commit-sha>` on the canonical edit commit.
2. Run `/f4-regen-framework` to propagate the revert into `.claude/`.
3. No child-side action required beyond the next routine `/sync-import-shamt`.
4. Communication: none beyond the changelog.

---

## Validation Considerations

- **Problem clarity** — "standalone repo" vs. the old "container subdirectory" framing. Verify the rewrite does not reintroduce container language ("one level up", "v2 development container", "sibling `_reference/`") anywhere, and that "master-side" survives only as a *role label*, never as a "has a nested `shamt-core/` subdirectory" structural claim.
- **Change-list completeness** — the sweep must be exhaustive: a stray `INFRASTRUCTURE.md` citation left in any canonical file (Markdown **or** shell script) is a dead reference. Re-run `grep -rn "INFRASTRUCTURE\.md"` over the canonical surface (all file types — `*.md` and `*.sh`; excluding `.claude/` and `proposals/`) after implementation — the expected count is **0**. The 30-row table is the authoritative set; the per-file ref counts (CHEATSHEET 7, p4 11, p2 9, p3 8, p1 7, sync-submit SKILL 1, scripts 1 each …) let the validator confirm no file was under-edited.
- **Mirrored-skill check** — for each PO/e5b/sync-import/sync-submit command edited (rows 11–14, 16, 18, 19), confirm its paired SKILL.md (rows 22–28) was edited consistently. Look hardest at p2/p4 where the skill carries 2 citations, and at sync-submit (row 19 ↔ row 28) where the skill citation was originally missed.
- **Case-(c) rationale preservation** — the validator should confirm that load-bearing rules previously cited from §1.11 (tracker field mapping), §2.1 (epic/feature/story folder structure), §1.15 (manual testing plan), and §1.12 (architecture/standards threading) are still discoverable in canonical prose after the link is dropped — not silently lost with the citation.
- **Rollback feasibility** — purely a docs/reference edit; revert is clean (`git revert` + regen).
- **Affected surfaces** — primer (CLAUDE.md), CHEATSHEET, references (audit_dimensions, trackers), templates (epic/feature), commands, skills, personas (test/review-executor), and the root canonical scripts `import-shamt.sh` / `init-shamt.sh` (rows 29–30). No `shamt-config.example.json` change. Cross-doc consistency: CLAUDE.md ↔ audit_dimensions.md on INFRASTRUCTURE.md's status (both must stop treating it as an existing-but-external file).
- **Propagation plan** — regen + child import required: 20 of 30 files are `host/templates/claude/**`. Run `/f4-regen-framework` after Phase 4, then `--check` for zero drift. The 2 root scripts (rows 29–30) propagate to children via `/sync-import-shamt`, not regen. No already-installed child needs a manual nudge beyond the next routine `/sync-import-shamt`.

---

## Open Questions

*(none — all resolved)*

---

## Resolved Questions

- ~~Q1: What happened to INFRASTRUCTURE.md? (moved in-repo / abandoned / kept external)~~ → A: **Abandoned / left behind.** The planning log stayed with the old container and is gone. The 75 citations now point at a nonexistent external file and should be removed; where a link is the *sole* source of load-bearing design rationale, inline a one-line summary in place of the link rather than dropping the meaning.
- ~~Q2: One proposal for everything, or split the INFRASTRUCTURE.md cleanup out?~~ → A: **All in one proposal.** Primer/container narrative + self-host/master-side detection wording + the full INFRASTRUCTURE.md dead-link sweep land together. Accepts that the 30-file scope forces a Phase 3 implementation plan.
- ~~Q3 (raised during validation): Do the two canonical shell scripts (`import-shamt.sh` §4.7, `init-shamt.sh` §4.12) that cite INFRASTRUCTURE.md belong in scope, given the original "no script change" framing?~~ → A: **Yes — add to scope.** Both are swept under the link-removal policy (Group D, rows 29–30), and the completeness grep is broadened from `--include="*.md"` to all file types so the expected-count-**0** check covers the scripts. Leaving them would defeat the proposal's own dead-citation-elimination goal.

---

Validated 2026-06-01 — 3 rounds, 1 adversarial sub-agent confirmed
