# Proposal: ps0-draft-story-stub-nesting-path-drops-features-segment

**Created:** 2026-06-14
**Status:** Draft
**Number:** 30
**Proposed by:**
**Project context:**

---

## Problem

`/ps0-draft` (and its mirror skill) write a new story-ticket stub to a path that **drops the `features/` segment** of the canonical nested PO work tree. The command's write/exit path uses a single placeholder `epics/{parent-feature-folder}/stories/{ID}-{story-slug}-{brief}/` — making the feature folder appear as a *direct child of `epics/`*. But a feature folder is never a direct child of `epics/`: it lives at `epics/{epic-folder}/features/{feature-folder}/`, and a story therefore lives at `epics/{epic-folder}/features/{feature-folder}/stories/{ID}-…`. The single `{parent-feature-folder}` placeholder collapses **two** real path levels (`{epic-folder}/features/{feature-folder}`) into one, so a literal read points story stubs at the wrong place. This directly contradicts the stub shape `/ps0-draft` *explicitly claims to mirror* — `/pf2-decompose`, which writes `epics/{epic-folder}/features/{feature-folder}/stories/{ID}-…` (`host/templates/claude/commands/pf2-decompose.md` line 131, exit-gate line 177) — and `/e8-finalize-story`'s Tech-story archive path `epics/{tech-stories-folder}/features/{bugs|quick-wins}/stories/…` (`host/templates/claude/commands/e8-finalize-story.md` line 70). `/ps0-draft` Step 1 already *resolves* the parent feature at the full nested depth correctly; only the write/exit path placeholder is wrong. Introduced by proposal #26 (the PO grid reorg, commit `499acf6`) when `/ps0-draft` absorbed the former Tech Stories fast-path; the collapse slipped past the plan.

The true root cause sits one altitude deeper than the five `/ps0-draft` occurrences the original capture named (adversarial root-cause diagnosis, Opus `root-cause-diagnoser` + Haiku `validation-checker` confirmation). Two findings reframe the scope:

1. **The collapse is not confined to `/ps0-draft`.** The same collapsed `epics/{parent-feature-folder}/stories/…` write form also appears in `/ps1-define` — `host/templates/claude/commands/ps1-define.md` lines 7, 92 and `host/templates/claude/skills/ps1-define/SKILL.md` lines 38, 62 — for a total of **9 live-bug occurrences** across the two story-altitude producers + their skills (ps0 command 60/82/90, ps0 skill 37/60, ps1 command 7/92, ps1 skill 38/62). Fixing only `/ps0-draft` would leave `/ps1-define` writing stories to the same wrong place.

2. **The deeper gap is a missing write-side path vocabulary.** `templates/SHAMT_RULES.template.md` §PO-tree resolution defines the *read-side* slug-resolution globs but never pins a normative *write-side* composition vocabulary — there is no canonical statement that a producer writing a child path must spell the full nested form `epics/{epic-folder}/features/{feature-folder}/stories/…` and must not collapse intermediate segments into a single placeholder. Because of that gap, each producer invented its own ad-hoc placeholder name, and two conventions now coexist: the correct two-level `{epic-folder}`/`{feature-folder}` form (`/pe2-decompose` line 111, `/pf0-draft`), and the collapsed/divergent form (`/ps0-draft` + `/ps1-define`'s broken `{parent-feature-folder}`; `/pf1-define`'s `{parent-epic-folder}` and `/pf2-decompose` Step 8's abbreviated `{e}` — both *structurally correct* but vocabulary-divergent, since a feature is only one level deep under an epic). Until the canonical write-vocabulary is homed, the next reorg can re-introduce the collapse.

---

## Proposed Changes

A flat list of canonical files the proposal will touch.

| # | Canonical path | Operation | One-line change description |
|---|----------------|-----------|------------------------------|
| 1 | `shamt-core/host/templates/claude/commands/ps0-draft.md` | EDIT | Replace the 3 collapsed `epics/{parent-feature-folder}/stories/…` write/exit paths (Step 3 line 60, Exit line 82, Exit-criteria line 90) with the full nested `epics/{epic-folder}/features/{feature-folder}/stories/{ID}-…` form. |
| 2 | `shamt-core/host/templates/claude/skills/ps0-draft/SKILL.md` | EDIT | Same fix in the mirror skill (Step 4 line 37, exit-criteria line 60). |
| 3 | `shamt-core/host/templates/claude/commands/ps1-define.md` | EDIT | Replace the 2 collapsed story write paths (Purpose line 7, Step line 92) with the full nested form. |
| 4 | `shamt-core/host/templates/claude/skills/ps1-define/SKILL.md` | EDIT | Same fix in the mirror skill (line 38, exit-criteria line 62). |
| 5 | `shamt-core/host/templates/claude/commands/pf1-define.md` | EDIT | Normalize the divergent (structurally-correct) placeholder `{parent-epic-folder}` → canonical `{epic-folder}` at the feature write/exit paths (lines 7, 96, 97, 156, 175). |
| 6 | `shamt-core/host/templates/claude/skills/pf1-define/SKILL.md` | EDIT | Same `{parent-epic-folder}` → `{epic-folder}` normalization in the mirror skill (lines 39, 47, 59). |
| 7 | `shamt-core/host/templates/claude/commands/pf2-decompose.md` | EDIT | Normalize the abbreviated `{e}` placeholder → canonical `{epic-folder}` at the story write path (line 131). |
| 8 | `shamt-core/templates/SHAMT_RULES.template.md` | EDIT | Add a short normative write-side path-composition statement to §PO-tree resolution: name `{epic-folder}`/`{feature-folder}` as the canonical resolved-folder placeholders and require producers to spell the full nested form when writing a child path (never collapse intermediate segments). |

**Path discipline:** all rows land on canonical sources (`host/templates/claude/` + `templates/`); generated `.claude/` paths are excluded. Regen (Phase 5) propagates the host edits. Row count = 8 (≤ 10) — no Phase 3 plan required.

---

## Risks

- **Regression risk** — Low. Rows 1–4 are a pure path correction toward the form `/pf2-decompose` already uses; the producers' Step 1 resolution is unchanged. Rows 5–7 are placeholder-name normalizations on *structurally-correct* paths (no behavior change). The §PO-tree edit (row 8) is additive normative text.
- **Drift risk** — Standard: the host edits must be propagated via `/f4-regen-framework`, and `regenerate-framework.sh --check` must show zero drift. The command↔skill pairs (rows 1↔2, 3↔4, 5↔6) must be edited together or the regen `--check` will flag asymmetry.
- **Child-project compatibility** — Picked up cleanly on the next `import-shamt` (regenerates `.claude/` + re-renders the rules file into the child `CLAUDE.md`). No manual reconciliation. Existing already-written story stubs in child trees are not relocated by this change — it only corrects the *instruction* for future stubs.
- **Rules-file size budget (D12)** — Row 8 adds bytes to `SHAMT_RULES.template.md`, which is size-budgeted. The statement is held to 2–3 sentences to stay within budget.
- **Open-questions debt** — The three drafting decisions (fix form, scope breadth, process-gap home) are resolved in the dialog below before exit.

---

## Rollback Plan

1. `git revert <commit-sha>` on the canonical edit commit.
2. Run `/f4-regen-framework` to propagate the revert into `.claude/`.
3. No child-side action required beyond the next routine `import-shamt`.
4. Communication: none — internal framework correction.

---

## Validation Considerations

- **Problem clarity** — The distinction between the *live bug* (ps0/ps1 `{parent-feature-folder}`, which drops a real segment) and the *divergent-but-correct* placeholders (pf1 `{parent-epic-folder}`, pf2 `{e}`, which don't drop a segment) is the easiest thing to misread. The validator should confirm rows 5–7 are normalization (D7), not bug fixes.
- **Change-list completeness** — The command↔skill mirror pairs are the classic forget-the-paired-edit trap: ps0 (1↔2), ps1 (3↔4), pf1 (5↔6). Verify all 9 live-bug sites and all divergent sites are covered; grep `epics/{parent-feature-folder}` and `epics/{parent-epic-folder}` and `epics/{e}/` after editing to confirm zero remaining.
- **Risk coverage** — Confirm no *other* PO producer writes a collapsed child path (the grep sweep covered commands + skills; re-verify templates/reference don't repeat the idiom).
- **Affected surfaces** — commands, skills, rules. Cross-doc D2/D9 consistency vs `/pf2-decompose` and `/e8-finalize-story` must hold after the edit.
- **Rollback feasibility** — All EDITs; no DELETE/MOVE; revert is clean.
- **Propagation plan** — Requires `/f4-regen-framework` + `--check`. The §PO-tree rules edit re-renders into every child `CLAUDE.md` on next `import-shamt`.
- **Out of scope (separate capture)** — The f5-audit process gap (D2/D9/D7 don't check path-composition consistency across producers, which is why this drift wasn't caught) is captured as its own f0 draft rather than folded here, keeping this proposal scoped to the path correction.

---

## Open Questions

- [ ] [Resolved in dialog — see Resolved Questions.]

---

## Resolved Questions

<!-- Append as questions resolve. -->

- ~~Q: How should the corrected story write-path be spelled?~~ → A: **Form A — expand the full nested path** (`epics/{epic-folder}/features/{feature-folder}/stories/{ID}-…`) using the canonical `{epic-folder}`/`{feature-folder}` placeholders. Makes the nested shape visible at every read site (the property whose absence let the collapse slip past review); matches `/pf2-decompose` and `/pf0-draft`. Rejected Form B (redefine `{parent-feature-folder}` once) — it hides the structure behind the same placeholder vocabulary that enabled the collapse.
- ~~Q: How broad should the fix scope be?~~ → A: **Full class-closing fix** (rows 1–8): fix the 9 live-bug ps0/ps1 sites (Form A) + normalize pf1's `{parent-epic-folder}` and pf2's `{e}` to canonical `{epic-folder}`/`{feature-folder}` + add the write-vocabulary statement to §PO-tree resolution. Unifies all PO producers on one vocabulary so a future reorg can't re-collapse. Rejected the narrower options — they leave the divergent vocabulary (and thus the re-collapse risk) in place.

---
