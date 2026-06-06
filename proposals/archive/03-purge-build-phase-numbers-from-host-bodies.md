# Proposal: purge-build-phase-numbers-from-host-bodies

**Created:** 2026-05-31
**Status:** Implemented
**Number:** 03
**Proposed by:**
**Project context:**
**Note (2026-06-06, f1 widen):** widened from 5 rows to cover **all** v2 dev-build-phase leaks (not just "Phase 8"): absorbed the `purge-build-phase-numbers-remaining-sites` f0 capture ("Phase 9" ×4 sites, "original Phase 5 path" ×2 sites), corrected the now-false "only Phase 8 / build-plan leaks" completeness claim, stripped the stale `shamt-core/`-prefix from all canonical paths (post-`shamt-core-standalone-repo` layout), and refreshed line numbers against HEAD. Now 11 rows → **Phase 3 required**. The f0 stub `purge-build-phase-numbers-remaining-sites` is rejected as a duplicate (absorbed here).

---

## Problem

Several shipped host command/skill bodies — and the two root docs `CLAUDE.md` and `CHEATSHEET.md` — label framework activity with v2-**development** build-sequencing numbers ("Phase 8", "Phase 9", "Phase 6 of the build plan", "the original Phase 5 path") that have **no meaning in the shipped framework**. These are *dev-primer milestones* (the v2 build phases in which each piece was implemented), not phases of any shipped flow:

- The **framework-update flow** is canonically **Part 3, Phases 1–7** (`CHEATSHEET.md` §"Framework update flow": `/f1-propose-update` = Phase 1 … `/f6-archive-proposal` = Phase 7). "**Phase 8**" is the v2 *build* phase in which that flow was implemented.
- "**Phase 9**" is the v2 *build* phase in which the master/child **sync** (Part 4) was implemented.
- The Engineer flow's **Phase 5 = Test**; "**the original Phase 5 path**" refers to the v2 build phase in which freeform Intake first shipped — so a reader maps it to the wrong shipped phase.
- "**Phase 6 of the build plan**" is a v2 build milestone, not the Engineer flow's Phase 6 (Review).

These dev-build numbers leaked into agent-instruction / Notes / heading prose that **regenerates into every child project's `.claude/`** (for the host bodies) or ships in the primer / cheatsheet, where the dev-build phase number is meaningless and contradicts the canonical numbering. Some sites are internally self-contradictory — `sync-submit-proposal.md:27` calls the same flow both "**Part 3** framework-update flow" (correct) and "**(Phase 8)**" (dev-build leak) in one sentence; `e3-plan-implementation.md:118` mixes the correct "Phase 4, Build" with the stale "Phase 6 of the build plan".

The master-dev primer `CLAUDE.md` §"How changes land" (lines 39–49) additionally frames the framework-update flow **conditionally** — "Once Phase 8 is built…" / "Until Phase 8 lands, treat this list as the target shape — propose changes in chat, validate manually…". That conditional is now satisfied (the flow ships), so the framing is stale and the "until then" manual fallback is obsolete. The same block carries one more dev-era staleness: step 4 says "Run the regen script in **`-Check`** mode" — a v1-PowerShell flag spelling; the v2 invocation is `scripts/regenerate-framework.sh --check`.

**Concrete sites** (surfaced by `/f5-audit-framework` D10/D11; line numbers are HEAD as of 2026-06-06):

*Phase 8 — the framework-update-flow build phase:*

- `host/templates/claude/commands/sync-triage-proposals.md:9` — "the rest of the framework-update flow **(Phase 8)** runs as separate commands."
- `host/templates/claude/commands/sync-triage-proposals.md:170` — "every other master-side phase in the framework-update flow **(Phase 8)**".
- `host/templates/claude/skills/sync-triage-proposals/SKILL.md:55` — "every other master-side phase in **Phase 8**".
- `host/templates/claude/commands/sync-submit-proposal.md:27` — "the rest of the **Part 3** framework-update flow **(Phase 8)**".
- `CLAUDE.md:41` / `:49` — "Once **Phase 8** is built…" / "Until **Phase 8** lands…".

*Phase 9 — the sync build phase:*

- `host/templates/claude/commands/f1-propose-update.md:153` — "The body is identical on both sides — **Phase 9** wires the child-side submission."
- `host/templates/claude/commands/f4-regen-framework.md:102` — "(`/sync-import-shamt` in child projects, **Phase 9**)".
- `host/templates/claude/commands/sync-import-shamt.md:116` — "The pragmatic **Phase 9** rule is subtree-level…".
- `host/templates/claude/skills/sync-import-shamt/SKILL.md:46` — heading "## Footer contract (**Phase 9** pragmatic rule)".

*Build-plan / original-Phase-5 — other dev-build milestones:*

- `host/templates/claude/commands/e3-plan-implementation.md:118` — "`/e4-execute-plan {slug}` (Phase 4, Build — **lands in Phase 6 of the build plan**)".
- `host/templates/claude/commands/e1-start-story.md:48` — "a pre-existing freeform story (the **original Phase 5 path**)".
- `CHEATSHEET.md:134` — "Pre-existing freeform stories (the **original Phase 5 path**, no headers) behave unchanged."

(Validation-footer lines carrying "Phase 8/9 implementation loop" are a dated historical record of that round and are **out of scope** — they remain true for the round they stamp.)

---

## Proposed Changes

Replacement strategy (uniform): **drop the dev-build-phase parenthetical / label entirely** — the surrounding prose already names the real thing ("the framework-update flow", "Phase 4, Build", "the child-side submission", "Footer contract"). Do **not** substitute another number. Command↔skill pairs are edited together (sync-triage, sync-import). Row count **11 > 10 → Phase 3 (`/f2-plan-update-implementation`) is required** before Phase 4.

| # | Canonical path | Operation | One-line change description |
|---|----------------|-----------|------------------------------|
| 1 | `host/templates/claude/commands/sync-triage-proposals.md` | EDIT | Remove "(Phase 8)" at line 9 ("…framework-update flow runs as separate commands.") and line 170 ("…every other master-side phase in the framework-update flow."). |
| 2 | `host/templates/claude/skills/sync-triage-proposals/SKILL.md` | EDIT | Line 55 "…every other master-side phase in **Phase 8**…" → "…every other master-side phase in the framework-update flow…" (rephrase — "Phase 8" stood in for the flow name here, so it cannot just be deleted). |
| 3 | `host/templates/claude/commands/sync-submit-proposal.md` | EDIT | Remove the redundant "(Phase 8)" at line 27, leaving the already-correct "Part 3 framework-update flow". |
| 4 | `host/templates/claude/commands/e3-plan-implementation.md` | EDIT | Line 118: drop "— lands in Phase 6 of the build plan", leaving "(Phase 4, Build)". |
| 5 | `CLAUDE.md` | EDIT | §"How changes land" (lines 39–49), three exact edits: **(a) line 41** `"Once Phase 8 is built, the **framework-update flow** is the supported way to change anything in this folder:"` → `"The **framework-update flow** is the supported way to change anything in this folder:"` (delete the now-satisfied "Once Phase 8 is built, " conditional prefix; capitalize "The"). **(b) line 49** — **delete the entire sentence** `"Until Phase 8 lands, treat this list as the **target shape** — propose changes in chat, validate manually using Pattern 1, edit the canonical file, and note what should later become a `proposals/` entry."` (plus its preceding blank line): it is the obsolete pre-ship fallback, now dead because the flow ships. **(c) line 46** `"4. Run the regen script in `-Check` mode against a known-clean child project to verify generated output stays sync'd."` → `"4. Run `scripts/regenerate-framework.sh --check` against a known-clean child project to verify generated output stays sync'd."` (only the v1-PowerShell `-Check` → v2 `scripts/regenerate-framework.sh --check` spelling; the rest of the line is untouched). |
| 6 | `host/templates/claude/commands/f1-propose-update.md` | EDIT | Line 153: drop the "— Phase 9 wires the child-side submission" clause, leaving "The body is identical on both sides." Per the uniform drop-don't-substitute strategy, no replacement is needed — the *prior* sentence already names `/sync-submit-proposal` as the child-side mechanism ("…before `/sync-submit-proposal` ships them up"). |
| 7 | `host/templates/claude/commands/f4-regen-framework.md` | EDIT | Line 102: drop ", Phase 9" from "(`/sync-import-shamt` in child projects, Phase 9)". |
| 8 | `host/templates/claude/commands/sync-import-shamt.md` | EDIT | Line 116: "The pragmatic Phase 9 rule is subtree-level…" → "The pragmatic footer-contract rule is subtree-level…" (drop "Phase 9"). |
| 9 | `host/templates/claude/skills/sync-import-shamt/SKILL.md` | EDIT | Line 46 heading "## Footer contract (Phase 9 pragmatic rule)" → "## Footer contract" (drop the dev-build phase label; the "pragmatic rule" detail lives in the section body). |
| 10 | `host/templates/claude/commands/e1-start-story.md` | EDIT | Line 48: drop "(the original Phase 5 path)", leaving "a pre-existing freeform story" (the "no back-ref headers" clause already identifies it). |
| 11 | `CHEATSHEET.md` | EDIT | Line 134: drop "the original Phase 5 path, " from "(the original Phase 5 path, no headers)", leaving "(no headers)". |

**Paired files:** rows 1↔2 (sync-triage cmd↔skill) and rows 8↔9 (sync-import cmd↔skill) are command↔skill pairs edited together. Rows 5 (`CLAUDE.md`) and 11 (`CHEATSHEET.md`) are **not** regenerated host bodies — they are root canonical docs that ship / sync directly and will **not** appear in the Phase 5 `--check` diff.

---

## Risks

- **Regression risk** — none functional. Every site is prose in Notes / exit-suggestion / heading text; no executable instruction or step ordering changes. Removing the dev-build label cannot alter what an agent does. (Row 9 edits a `##` heading — purely a label; the section body is untouched.)
- **Drift risk** — the host-body rows (1–4, 6–10) are under `host/templates/claude/`, so they must be propagated with `/f4-regen-framework` (Phase 5); skipping regen is itself a D1 finding, mechanically caught by `--check`. Rows 5 (`CLAUDE.md`) and 11 (`CHEATSHEET.md`) are not regenerated and won't appear in the `--check` diff.
- **Child-project compatibility** — children pick up the corrected host bodies on the next `/sync-import-shamt`; `CHEATSHEET.md` lands on the same import. No manual reconciliation; the change only removes confusing text.
- **Completeness** — this proposal supersedes the original 5-row scope, whose Completeness note falsely claimed "the sweep confirmed these are the only 'Phase 8' / 'build plan' leaks." A re-grep of `Phase 8`, `Phase 9`, `build plan`, and `original Phase [0-9]` across `host/templates/claude/`, `CHEATSHEET.md`, and `CLAUDE.md` (2026-06-06) surfaced **13 sites across 11 files** — all listed above. Validation must re-run that grep to confirm zero dev-build-phase leaks remain after the edits (excluding dated validation-footer "implementation loop" lines).
- **Open-questions debt** — none; the widen-vs-separate decision is resolved below.

---

## Rollback Plan

Revert the commit and re-run `/f4-regen-framework`. No child-side action required (purely textual deletions in regenerated host bodies + two root docs).

---

## Validation Considerations

- **Problem clarity** — the crux is distinguishing **shipped-flow** phases (framework-update Part 3 Phases 1–7; Engineer flow Phases 1–7; sync Part 4) from **v2 dev-build** phase numbers (Phase 8 = framework-update build, Phase 9 = sync build, "build plan" / "original Phase 5 path" = other build milestones). Confirm the validator reads this as "remove dev-build leaks", not "renumber a flow".
- **Change-list completeness** — the highest-risk dimension. The easy-to-miss paired edits are the two skills (rows 2, 9) alongside their commands (rows 1, 8). Re-grep `Phase 8|Phase 9|build plan|original Phase [0-9]` across all shipped host bodies + `CHEATSHEET.md` + `CLAUDE.md`; every non-footer hit must map to a row. (The prior 5-row version's "only Phase 8" claim was false — do not trust it; re-derive from the grep.)
- **Scope boundary** — `CLAUDE.md` (row 5) is a present-tense refresh of the now-satisfied Phase-8 conditionals plus the `-Check`→`--check` spelling fix; row 5 gives exact before/after text for all three sub-edits (line 41 prefix delete, line 49 sentence delete, line 46 spelling). Confirm the line-49 obsolete "validate manually" fallback is **deleted** (not left dangling), and that row 5(c) touches only the `-Check` spelling (the "known-clean child project" method phrasing is intentionally left as-is — out of scope). `CLAUDE.md` and `CHEATSHEET.md` are **not** regenerated — do not expect them in the Phase 5 `--check` diff.
- **Risk coverage** — verify all host-body edits stay purely textual (no accidental step / heading-body removal; row 9 changes only the heading label).
- **Affected surfaces** — host commands + skills (rows 1–4, 6–10) plus the two root canonical docs `CLAUDE.md` (row 5) and `CHEATSHEET.md` (row 11). No rules, references, templates, personas, or scripts.
- **Propagation plan** — requires `/f4-regen-framework` after Phase 4; child projects update on next `/sync-import-shamt`. **Row count 11 > 10 → Phase 3 plan (`/f2-plan-update-implementation`) required** before Phase 4.

---

## Open Questions

(none remaining)

---

## Resolved Questions

<!-- Drafting-only log -->

- ~~Q: Replace the "(Phase 8)" labels with the canonical "Part 3", or remove the parenthetical entirely?~~ → A: Remove entirely — the surrounding prose already names the flow; no number needs to stay in sync. (Applies uniformly to all dev-build-phase labels: Phase 8, Phase 9, build-plan, original-Phase-5.)
- ~~Q: Include `CLAUDE.md`'s now-satisfied "Once Phase 8 is built / Until Phase 8 lands" conditionals in scope?~~ → A: Include them (row 5) — refresh to present tense now that the flow ships; line 49's "until then" manual fallback is obsolete and gets rewritten/removed.
- ~~Q (widen vs. separate, from the `purge-build-phase-numbers-remaining-sites` f0 capture): widen this proposal to absorb the Phase-9 / original-Phase-5 sites, or keep them as a separate complement?~~ → A: **Widen** (user choice, 2026-06-06). The f0 surfaced that this proposal's "only Phase 8 / build plan" completeness claim was false; widening to all 13 sites in one comprehensive purge (one regen/audit cycle) is cleaner than two passes and fixes the false claim. The f0 stub `purge-build-phase-numbers-remaining-sites` is **rejected as a duplicate** (absorbed here). Cost: 11 rows > 10 → Phase 3 required.
- ~~Q (standalone-repo layout): the original draft cited paths as `shamt-core/host/…`; correct?~~ → A: No — post-`shamt-core-standalone-repo` (Implemented 2026-06-01) the canonical sources live at the repo root, so all paths are stripped to `host/templates/claude/…`, `CLAUDE.md`, `CHEATSHEET.md`. Refreshed during this f1 re-entry.

---
Validated 2026-06-06 — 2 rounds, 1 adversarial sub-agent confirmed (2 sub-agent passes; round 1 fixed 1 LOW — a row-6 example that re-added a mention against the uniform drop-don't-substitute strategy; the first sub-agent pass surfaced row 5 specifying its three CLAUDE.md sub-edits goal-style rather than with exact before/after text → rewritten to exact quotes matching the other 10 rows; second pass confirmed all 13 line citations, completeness, pairing, scope, propagation, and rollback)
