# Proposal: purge-build-phase-numbers-from-host-bodies

**Created:** 2026-05-31
**Status:** Draft
**Proposed by:**
**Project context:**

---

## Problem

Several shipped host command/skill bodies label the **framework-update flow** with v2-*development* build-sequencing numbers ("Phase 8", "Phase 6 of the build plan") that have no meaning in the shipped framework. The framework-update flow is canonically **Part 3, Phases 1–7** (`shamt-core/CHEATSHEET.md` §"Framework update flow (Part 3 — master-side)": `/f1-propose-update` = Phase 1 … `/f6-archive-proposal` = Phase 7). "Phase 8" is the v2 *build* phase in which that flow was implemented — a dev-primer milestone (`shamt-core/CLAUDE.md` lines 41/49: "Once Phase 8 is built…", "Until Phase 8 lands…"), not a phase of the flow itself.

These dev-build numbers leaked into agent-instruction/Notes prose that **regenerates into every child project's `.claude/`**, where "Phase 8 / build-plan Phase 6" is meaningless and contradicts the canonical numbering. One site is internally self-contradictory: `sync-submit-proposal.md:27` calls the same flow both "**Part 3** framework-update flow" (correct) and "**(Phase 8)**" (dev-build leak) in one sentence.

The master-dev primer `shamt-core/CLAUDE.md` §"How changes land" (lines 41–49) also frames the framework-update flow conditionally — "Once Phase 8 is built…" / "Until Phase 8 lands, treat this list as the target shape — propose changes in chat, validate manually…". That conditional is now satisfied (Phase 8 is built; the flow ships), so the framing is stale and the "until then" manual fallback is obsolete. The same nine-line block carries one more dev-era staleness: step 4 says "Run the regen script in **`-Check`** mode" — a v1-PowerShell flag spelling; the v2 invocation is `scripts/regenerate-framework.sh --check`. Because row 5 already rewrites this block, the `-Check` → `--check` modernization rides along (editing the block twice across separate proposals would collide on the same lines). CLAUDE.md is the dev primer (not a regenerated/shipped body), but it is a canonical source and is refreshed here alongside the shipped-body leaks.

Concrete sites (surfaced by the D10/D11 dimensions of `/f5-audit-framework`):

- `shamt-core/host/templates/claude/commands/sync-triage-proposals.md:9` — "the rest of the framework-update flow **(Phase 8)** runs as separate commands."
- `shamt-core/host/templates/claude/commands/sync-triage-proposals.md:168` — "every other master-side phase in the framework-update flow **(Phase 8)**".
- `shamt-core/host/templates/claude/skills/sync-triage-proposals/SKILL.md:55` — "every other master-side phase in **Phase 8**".
- `shamt-core/host/templates/claude/commands/sync-submit-proposal.md:27` — "the rest of the **Part 3** framework-update flow **(Phase 8)**".
- `shamt-core/host/templates/claude/commands/e3-plan-implementation.md:118` — "`/e4-execute-plan {slug}` (Phase 4, Build — **lands in Phase 6 of the build plan**)".

The `e3` case mixes a correct user-facing label ("Phase 4, Build" — the Engineer flow's Phase 4) with the stale dev-build aside ("Phase 6 of the build plan"), which reads as a contradiction mid-instruction.

---

## Proposed Changes

| # | Canonical path | Operation | One-line change description |
|---|----------------|-----------|------------------------------|
| 1 | `shamt-core/host/templates/claude/commands/sync-triage-proposals.md` | EDIT | Remove the stale "(Phase 8)" dev-build label at line 9 ("…framework-update flow runs as separate commands.") and line 168 ("…every other master-side phase in the framework-update flow…"). |
| 2 | `shamt-core/host/templates/claude/skills/sync-triage-proposals/SKILL.md` | EDIT | Remove the stale "Phase 8" label at line 55 ("…every other master-side phase in the framework-update flow…"). |
| 3 | `shamt-core/host/templates/claude/commands/sync-submit-proposal.md` | EDIT | Remove the redundant "(Phase 8)" at line 27, leaving the already-correct "Part 3 framework-update flow". |
| 4 | `shamt-core/host/templates/claude/commands/e3-plan-implementation.md` | EDIT | Drop the "— lands in Phase 6 of the build plan" aside at line 118, leaving "(Phase 4, Build)". |
| 5 | `shamt-core/CLAUDE.md` | EDIT | §"How changes land" (lines 41–49): (a) line 41 "Once Phase 8 is built, the framework-update flow is the supported way…" → present tense (the flow now ships); (b) line 49 "Until Phase 8 lands, treat this list as the target shape — propose changes in chat, validate manually…" describes a now-obsolete manual fallback — rewrite/remove it; (c) step 4 line 46 "Run the regen script in `-Check` mode" → the v2 `scripts/regenerate-framework.sh --check` spelling (v1-PowerShell `-Check` is stale). |

Row count: 5 ≤ 10 — no Phase 3 plan required.

**Replacement strategy:** drop the dev-build-phase parenthetical entirely (the surrounding prose already names "the framework-update flow" / "Phase 4, Build"); do **not** substitute another number. The `sync-triage` command and skill are edited as a pair. The CLAUDE.md edit (row 5) is a present-tense refresh, not a number-deletion: Phase 8 is now built, so the "once built / until lands" conditional framing is obsolete. See Resolved Questions for both decisions.

---

## Risks

- **Regression risk** — none functional. These are prose asides in Notes/exit-suggestion text; no executable instruction or step ordering changes. Removing them cannot alter what an agent does.
- **Drift risk** — rows 1–4 are under `host/templates/claude/`, so those edits must be propagated with `/f4-regen-framework` (Phase 5); skipping regen would itself be a D1 finding. Low risk, mechanically caught by the post-edit `--check`. Row 5 (`CLAUDE.md`) is not regenerated and won't appear in the `--check` diff.
- **Child-project compatibility** — child projects pick the corrected bodies up cleanly on the next `import-shamt`; no manual reconciliation. The change only removes confusing text.
- **Open-questions debt** — none; the two drafting questions are resolved below.
- **Completeness risk** — the sweep confirmed these are the only "Phase 8" / "build plan" leaks in shipped host bodies (`sync-submit` and `e3` skills are clean). `CLAUDE.md`'s two uses (lines 41/49) are included as row 5; no other canonical file carries the dev-build "Phase 8" reference.
- **CLAUDE.md scope** — the row 5 edit is the only non-host-body change. It is a tense/framing refresh (the flow now ships), not a dev-build-number deletion, and CLAUDE.md is not regenerated, so it needs no `--check` propagation.

---

## Rollback Plan

Revert the commit and re-run `/f4-regen-framework`. No child-side action required. (Purely textual deletions in regenerated host bodies.)

---

## Validation Considerations

- **Problem clarity** — the distinction between the **flow's** phases (Part 3, Phases 1–7) and the **v2 dev-build** phase numbers ("Phase 8", "build-plan Phase 6") is the crux; confirm the validator reads the Problem as "remove dev-build leaks from shipped bodies", not "renumber the flow".
- **Change-list completeness** — the easy-to-miss paired edit is the `sync-triage` **skill** (row 2) alongside its command (row 1); both must lose the label together. Confirm no other shipped host body contains "Phase 8" or "build plan" (verified at draft time; re-confirm).
- **Scope boundary** — `shamt-core/CLAUDE.md` lines 41–49 are **in scope** as row 5: a present-tense refresh of the Phase-8 conditionals (not a number deletion) plus the `-Check` → `--check` spelling fix in step 4. Confirm the implementer rewrites line 49's now-obsolete "Until Phase 8 lands… propose changes in chat, validate manually" fallback rather than leaving a dangling conditional, and that the `-Check` rider is the only non-Phase-8 change. CLAUDE.md is **not** regenerated — do not expect it in the Phase 5 `--check` diff.
- **Risk coverage** — verify the four host-body edits stay purely textual (no accidental step/heading removal) and that row 5 is the only non-host change.
- **Affected surfaces** — host commands + skills (rows 1–4) plus the master-dev primer CLAUDE.md (row 5). No rules, references, templates, personas, or scripts.
- **Propagation plan** — requires `/f4-regen-framework` after Phase 4; child projects update on next `import-shamt`.

---

## Open Questions

(none remaining)

---

## Resolved Questions

<!-- Drafting-only log -->

- ~~Q: Replace the "(Phase 8)" labels with the canonical "Part 3", or remove the parenthetical entirely?~~ → A: Remove entirely — the surrounding prose already names the flow ("framework-update flow" / "Phase 4, Build"), so the parenthetical adds nothing and no number needs to stay in sync.
- ~~Q: Include `CLAUDE.md`'s now-satisfied "Once Phase 8 is built / Until Phase 8 lands" conditionals in scope, or keep this proposal to the shipped host bodies only?~~ → A: Include them (row 5) — refresh the dated conditionals to present tense now that the flow ships; line 49's "until then" manual fallback is obsolete and gets rewritten/removed.
