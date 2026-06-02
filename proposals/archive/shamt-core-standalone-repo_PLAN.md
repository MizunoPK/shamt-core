# Implementation Plan: shamt-core-standalone-repo

**Proposal:** proposals/shamt-core-standalone-repo.md
**Created:** 2026-06-01
**File operations:** 30 (CREATE: 0, EDIT: 30, DELETE: 0, MOVE: 0)
**Phase-decomposed:** index (this file) + 4 phase files

This plan is **phase-decomposed** because a single Phase-4 session executing all 30 file edits (≈75 individual locate/replace operations) would compact. Each phase file is independently executable and independently validated. The phases are ordered by edit character, not by hard dependency — there is **no cross-phase ordering constraint** (every edit is a self-contained citation removal or wording fix; no edit depends on another having landed first). Execute them in any order; the recommended order is 1 → 2 → 3 → 4.

| Phase file | Rows covered | Files | Character |
|------------|--------------|-------|-----------|
| `shamt-core-standalone-repo_PLAN_phase_1.md` | 1, 2, 3, 29, 30 | CLAUDE.md primer, f1 + sync-triage wording, 2 shell scripts | Judgment-heavy: narrative rewrite, structural-detection rewording, script-comment edits |
| `shamt-core-standalone-repo_PLAN_phase_2.md` | 11, 12, 13, 14 | p1/p2/p3/p4 PO commands | 35 citation removals (heaviest) |
| `shamt-core-standalone-repo_PLAN_phase_3.md` | 4, 5, 6, 7, 8, 9, 10, 15, 16, 17, 18, 19 | CHEATSHEET, audit_dimensions, trackers, epic/feature templates, e5/e5b/e6 + sync commands | 24 citation removals + 1 carve-out deletion |
| `shamt-core-standalone-repo_PLAN_phase_4.md` | 20, 21, 22, 23, 24, 25, 26, 27, 28 | test/review-executor personas + 7 mirrored skills | 12 citation removals (incl. frontmatter `description:` wraps) |

## Pre-execution checklist

- [ ] On a clean working tree (or working in a worktree dedicated to this proposal).
- [ ] `proposals/shamt-core-standalone-repo.md` validation footer present (it is — `Validated 2026-06-01 — 3 rounds, 1 adversarial sub-agent confirmed`).
- [ ] All four `_PLAN_phase_*.md` files carry their own validation footers before `/f3-implement-update` runs.
- [ ] Branch created: `framework-update/shamt-core-standalone-repo` from the configured remote development branch.

## Files manifest

Every file is **EDIT**. No CREATE / DELETE / MOVE anywhere in this plan. Paths are repo-relative (this repo's root is `shamt-core/` itself — it is now a standalone repository, which is the change this proposal documents).

| # | Path | Phase | INFRASTRUCTURE.md citations to remove |
|---|------|-------|----------------------------------------|
| 1 | `CLAUDE.md` | 1 | 1 link (line 73) + container narrative on lines 5, 87, 97–104 (no `INFRASTRUCTURE.md` token but same standalone-repo rewrite) |
| 2 | `host/templates/claude/commands/f1-propose-update.md` | 1 | 0 (structural-detection wording only) |
| 3 | `host/templates/claude/commands/sync-triage-proposals.md` | 1 | 1 (line 27) + false `shamt-core/`-subdirectory parenthetical |
| 4 | `CHEATSHEET.md` | 3 | 7 (lines 47, 62, 64, 108, 146, 163, 266) |
| 5 | `reference/audit_dimensions.md` | 3 | 1 (line 105 — remove the whole carve-out bullet) |
| 6 | `reference/trackers/_contract.md` | 3 | 2 (lines 7, 21) |
| 7 | `reference/trackers/ado.md` | 3 | 1 (line 75) |
| 8 | `reference/trackers/github.md` | 3 | 1 (line 76) |
| 9 | `templates/epic.template.md` | 3 | 1 (line 1) |
| 10 | `templates/feature.template.md` | 3 | 1 (line 1) |
| 11 | `host/templates/claude/commands/p1-start-epic.md` | 2 | 7 (lines 21, 80, 84, 101, 150, 152, 165) |
| 12 | `host/templates/claude/commands/p2-decompose-epic.md` | 2 | 9 (lines 69, 70, 76, 91, 100, 124, 172, 184, 189) |
| 13 | `host/templates/claude/commands/p3-start-feature.md` | 2 | 8 (lines 21, 109, 113, 126, 147, 178, 180, 194) |
| 14 | `host/templates/claude/commands/p4-decompose-feature.md` | 2 | 11 (lines 7, 66, 87, 89, 95, 111, 120, 151, 200, 213, 220) |
| 15 | `host/templates/claude/commands/e5-execute-tests.md` | 3 | 2 (lines 40, 124) |
| 16 | `host/templates/claude/commands/e5b-write-manual-testing-plan.md` | 3 | 3 (lines 7, 64, 77) |
| 17 | `host/templates/claude/commands/e6-review-changes.md` | 3 | 2 (lines 12, 94) |
| 18 | `host/templates/claude/commands/sync-import-shamt.md` | 3 | 1 (line 9) |
| 19 | `host/templates/claude/commands/sync-submit-proposal.md` | 3 | 2 (lines 9, 27) |
| 20 | `host/templates/claude/agents/test-executor.md` | 4 | 1 (line 16) |
| 21 | `host/templates/claude/agents/review-executor.md` | 4 | 1 (line 153) |
| 22 | `host/templates/claude/skills/p1-start-epic/SKILL.md` | 4 | 1 (line 46) |
| 23 | `host/templates/claude/skills/p2-decompose-epic/SKILL.md` | 4 | 2 (lines 38, 47) |
| 24 | `host/templates/claude/skills/p3-start-feature/SKILL.md` | 4 | 1 (line 52) |
| 25 | `host/templates/claude/skills/p4-decompose-feature/SKILL.md` | 4 | 2 (lines 48, 62) |
| 26 | `host/templates/claude/skills/e5b-write-manual-testing-plan/SKILL.md` | 4 | 1 (line 9 — frontmatter `description:`) |
| 27 | `host/templates/claude/skills/sync-import-shamt/SKILL.md` | 4 | 2 (lines 11–12 frontmatter `description:`, line 48 body) |
| 28 | `host/templates/claude/skills/sync-submit-proposal/SKILL.md` | 4 | 1 (line 12 — frontmatter `description:`) |
| 29 | `import-shamt.sh` | 1 | 1 (line 16 comment) |
| 30 | `init-shamt.sh` | 1 | 1 (line 37 comment) |

If a path is not in this manifest, it must not be edited during execution.

## Link-removal policy (from the proposal, applied uniformly)

For each `INFRASTRUCTURE.md` citation, exactly one of:

- **(a) Inline rule already present** — the sentence states the rule and merely cites the log as its source. Drop the citation markup; keep the prose. (Most §1.11 / §1.12 / §1.14 / §1.15 / §2.1 / §2.3 cases.)
- **(b) Bare pointer** — a standalone "see §X for full context" line that now resolves nowhere. Delete the line (and its now-orphaned blank line).
- **(c) Sole carrier of load-bearing rationale** — inline a one-line summary in place of the link.

**No link is repointed.** The dead target (`INFRASTRUCTURE.md`) is gone, not relocated; where a sibling in-repo doc happens to hold the same content, name it in prose (not as a new markdown link) rather than repointing.

## Verification (post-execution — run after ALL four phases land)

- [ ] **Completeness grep (the authoritative gate):**
      `grep -rn "INFRASTRUCTURE\.md" --include="*.md" --include="*.sh" . | grep -v "\.claude/" | grep -v "proposals/"`
      returns **zero lines**. (Excludes generated `.claude/` and the `proposals/` working area, both of which carry historical mentions out of scope. The exclusion patterns are written without a leading `/` because `grep -r .` emits top-level paths — e.g. `proposals/foo.md` — with no leading slash; a `/proposals/` pattern would silently fail to exclude the top-level `proposals/` working area and the gate could never reach zero.)
- [ ] Every row in the Proposed Changes table has a corresponding executed step (one step per row; 30 rows → 30 steps across the 4 phase files).
- [ ] No edits landed in generated `.claude/` paths: `git status --short .claude/` is empty.
- [ ] No container language reintroduced: `grep -rn "v2 development container\|one level up\|sibling \`_reference/\`\|shamt-ai-dev-v2" CLAUDE.md CHEATSHEET.md host/ reference/ templates/` returns zero lines.
- [ ] Mermaid / link / reference targets in edited files still resolve (no edit introduced a broken in-repo link).

## Notes

- **Regen is Phase 5, not this plan.** 20 of the 30 files live under `host/templates/claude/**` and are propagated into a child's `.claude/` by `/f4-regen-framework` *after* `/f3-implement-update`. This plan edits **canonical sources only** and never touches `.claude/`. Rows 29–30 (the two root shell scripts) are copied to children via `/sync-import-shamt`, not regen — they still need their dead citation swept here.
- **Residual bare `§N` section tags are deliberately out of scope.** A few edited sentences leave behind a bare section reference that originally pointed at `INFRASTRUCTURE.md` but carries no `INFRASTRUCTURE.md` token of its own — e.g. `per §1.4` (p3-start-feature line 113), `per §1.12` inside the architecture-consult sub-items (p1/p3 Step 5 item 1), `per §2.3` / `§2.3 resolution` (p2/p4 bodies). The proposal scopes completeness to the `grep "INFRASTRUCTURE\.md"` → 0 outcome and enumerates exactly the `INFRASTRUCTURE.md`-bearing citations per row; touching the bare tags would be scope creep beyond the Proposed Changes table. They are opaque section labels, not dead markdown links, so they do not trip the completeness grep. **Flagged here** so a reviewer can decide whether to spin a follow-up proposal to scrub them — they are intentionally left untouched by this plan to preserve one-to-one row coverage.
- **Self-host meta-edit (row 2).** Phase 1 edits `/f1-propose-update` itself — the command that authored this proposal. The change is wording-only (structural-detection prose) and does not alter the phase-per-command contract or slug resolution. Phase 5 regen + re-confirm the command still resolves slugs from the standalone-repo root.
- **Case-(c) rationale preservation.** The load-bearing rules previously cited from §1.11 (tracker field mapping — the unified-section list), §2.1 (flat layout / global slug uniqueness / folder structure), §1.15 (manual-test-plan dimensions), and §1.12 (architecture/standards PO-threading) are all restated inline in the surrounding prose by these edits — none is dropped silently. The trackers' "What gets unified" section list survives in `reference/trackers/_contract.md` line 21's own enumeration.

---
*Validated 2026-06-01 — 2 rounds, 1 adversarial sub-agent confirmed.*
