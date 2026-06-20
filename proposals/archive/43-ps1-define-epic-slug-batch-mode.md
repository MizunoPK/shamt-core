# Proposal: ps1-define-epic-slug-batch-mode

**Created:** 2026-06-19
**Number:** 43
**Status:** Implemented
**Proposed by:** FantasyFootballHelperScripts
**Project context:** Hit while running `/ps1-define T1` — T1 resolved to an epic, which the current altitude dispatch rejects ("neither own nor parent altitude — nothing to define").

---

## Problem

`/ps1-define`'s Step 2 **altitude dispatch** (`host/templates/claude/commands/ps1-define.md`, lines 42–46) recognizes exactly two altitudes for the slug it is handed:

- **Own** — the slug resolves to a *story* folder → define that one story (the common case).
- **Parent** — the slug resolves to a *feature* folder → enter `## Parent-slug batch mode (feature → all stories)` and define every story under that feature, sequentially (added by #39).

A slug that resolves to an **epic** falls into the explicit "neither" branch and halts: `slug {slug} resolves to neither a story (own altitude) nor a feature (parent altitude) — nothing to define`. A child (FantasyFootballHelperScripts) hit exactly this running `/ps1-define T1`, where `T1` is the top-level epic `T1-win-rate-sim-overhaul-sweep-endless-modes`.

The user wants to point `/ps1-define` at an **epic** and have it define every story in that epic's whole subtree — i.e. a **grandparent altitude**: for each feature under the epic, run the existing feature→stories parent batch, which in turn runs single-story define per story. This is a *nested dispatch of `/ps1-define`'s own single-story define logic*, reaching every story two structural levels down, run as one phase (story-define).

This sits on a real framework fault line that the proposal must respect. The existing parent-slug batch pattern is documented as **horizontal sibling fan-out at one altitude — explicitly "not vertical chaining"** (`pf1-define.md` Notes, line 223: a batch `/pf1-define` over an epic "still does **not** decompose those features (that stays `/pf3-decompose`); it only runs the *same* define phase across siblings"). A grandparent mode must stay inside that discipline: it runs **only the story-define phase** across the epic's entire story set — it does **not** define the epic's features (that is `/pf1-define`'s job), does **not** decompose anything (`/pf3-decompose`), and does **not** validate (`/ps2-validate`). It crosses a structural *level* (feature → story) but never a *phase*, so it remains a stateless, disk-derived dispatcher of `/ps1-define`'s own logic and honors Principle 1, exactly like the existing feature→stories parent batch. (`/ps1-define {epic}` defines-only and `/ps2-validate {epic}` validates-only stay two **distinct single-phase commands** the user runs in sequence — neither one chains into the other — so the define→validate pair at the epic grain does not constitute the forbidden vertical cross-phase pipeline.)

(The f0 capture's loose phrasing — "the features within one by one" — and its "per-story define + inline validation" note are both imprecise: defining features is not `/ps1-define`'s job, and `/ps1-define` no longer runs inline validation since #41 moved that to `/ps2-validate`. The dialog below pins down the true intent.)

---

## Proposed Changes

A flat list of canonical files the proposal will touch. **Every file the proposal will edit, create, delete, or move must appear here** — Phase 2 (validate-artifact) and Phase 4 (implement-update) both read this list as the source of truth for change scope.

| # | Canonical path | Operation | One-line change description |
|---|----------------|-----------|------------------------------|
| 1 | `shamt-core/host/templates/claude/commands/ps1-define.md` | EDIT | Extend Step 2 altitude dispatch (lines 42–46) to a third branch — **grandparent (epic) altitude**. **Change the dispatch conditional itself, not just the halt message:** the current "neither" branch reads "the slug resolves to **no story and no feature, or to an epic**" (line 46) — an epic currently falls into "neither" and halts. Rewrite it so an epic no longer lands in "neither": add a grandparent branch (`the slug resolves to an *epic* folder` → enter `## Grandparent-slug batch mode (epic → all stories)`), and tighten the "neither" branch to "the slug resolves to **no story, no feature, and no epic**" so a truly-unresolved slug (typo / unknown) still halts while an epic routes to the new branch; update the halt message to match. Add the new section (mirrors `## Parent-slug batch mode`, one level up): derive the feature worklist from the epic's `## Sequencing & Parallelization` / `## Target Features`, then dispatch the existing feature→stories parent batch per feature; resumable via the same skip-already-defined check; add a Notes bullet reaffirming Principle 1 (nested horizontal fan-out of the single-story define phase, never cross-phase chaining). |
| 2 | `shamt-core/host/templates/claude/commands/ps2-validate.md` | EDIT | Same grandparent (epic → all stories) batch addition for the validate stage: extend Step 1 altitude dispatch to a grandparent branch + add a `## Grandparent-slug batch mode (epic → all stories)` section that dispatches the existing feature→stories validate batch per feature, so `/ps2-validate {epic-slug}` validates the epic's entire story set after `/ps1-define {epic-slug}` defines it. Keeps the define/validate sibling pair symmetric (both got the feature→stories parent batch together in #39). |
| 3 | `shamt-core/host/templates/claude/skills/ps1-define/SKILL.md` | EDIT | **(a)** Add the grandparent-epic-slug note to the frontmatter `description:` **and** a matching `define all stories in the epic` trigger; **(b)** correct the **stale #41 claims** this SKILL still carries — the **same false claim recurs in four places**: the `description:`, `## Mode A`, `## Recommended model`, and `## Exit criteria`. All assert `/ps1-define` "runs an INLINE Pattern-1 validation loop / stamps the Validated footer itself" and that the batch "defines **+ validates** every story." Both are false post-#41: the canonical command body (`commands/ps1-define.md` line 7) says `/ps1-define` **defers validation to `/ps2-validate`** and does **not** stamp a footer, and the proposal's own Problem (line 24) cites this. Rewrite **all four sections** to match the command body — define-only, defers validation to `/ps2-validate`, no footer; the batch **defines** (not validates); `## Recommended model` → Balanced (no inline loop); `## Exit criteria` → no footer stamped + grandparent batch outcome — so the grandparent note ships beside accurate text rather than known-false claims throughout the file. This is a whole-file #41-staleness correction on a file already in scope (the staleness is more pervasive than the frontmatter), **not** a new change set; `## Protocol` stays the command-body pointer untouched — no step paraphrase (D2 Command→Skill pointer rule). |
| 4 | `shamt-core/host/templates/claude/skills/ps2-validate/SKILL.md` | EDIT | Add the grandparent-epic-slug note to the frontmatter `description:`, the matching `validate all stories in the epic` trigger, and the grandparent-batch outcome to `## Exit criteria` (symmetric to row 3's grandparent additions). **No #41 correction needed** — this SKILL's description is already accurate post-#41 (it correctly states ps2-validate runs the inline loop and stamps the footer). `## Protocol` stays the pointer — no step paraphrase. |
| 5 | `shamt-core/README.md` | EDIT | Reflect grandparent (epic) batch mode in the quick reference: extend the `/ps1-define` and `/ps2-validate` command-table rows (lines ~129–130) to note that a parent **epic** slug also processes the epic's whole story subtree, and update the **Parent-slug batch mode** callout (line ~135) so its "horizontal sibling fan-out at one altitude / one altitude up / does not chain into the next altitude's command" framing accommodates `/ps1-define` and `/ps2-validate`'s new grandparent (epic → all stories) **nested** fan-out — still single-*phase* (story-define / story-validate only), still not vertical cross-*phase* chaining, but now reaching two structural levels down. Keep the README's existing Principle-1 framing intact and consistent with the command-body Notes added by rows 1–2. |

---

## Risks

- **Regression:** the Step 2 dispatch is load-bearing — the "neither" branch must still halt for a slug that resolves to *nothing* (typo / unknown slug). The grandparent branch only fires when the slug resolves to an *epic* folder; the genuine "resolves to no story, no feature, no epic" case must keep its halt. Mitigated by keeping the halt message precise (epic now dispatched, truly-unresolved still halts).
- **Drift (canonical vs. generated `.claude/`):** both `commands/` and `skills/` edits must regen cleanly; `/f4-regen-framework --check` must show zero drift. SKILL.md edits must stay pointer-form (no paraphrase) or the D2 audit dimension flags drift.
- **Principle-1 boundary:** a grandparent batch is the deepest fan-out the parent-batch pattern has taken (two structural levels). The framing must be airtight that it runs only one *phase* across the epic's story set — otherwise it reads as the forbidden vertical cross-phase pipeline (`/e-all`-style), which belongs to a driver, not a define command. Mitigated by the explicit Notes reconciliation bullet and by NOT touching feature-define or decompose.
- **Child-project compatibility on next `import-shamt`:** purely additive (a new dispatch branch + section); existing own/parent invocations are unchanged. No child action required.
- **Open-questions debt:** none outstanding — shape (grandparent batch, single-phase), scope (ps1 + ps2), and epic-grain (single named epic per invocation) are all resolved in Resolved Questions.

---

## Rollback Plan

Purely additive to two command bodies + their skill pointers. Rollback = revert the land commit, re-run `/f4-regen-framework` to restore `.claude/`. No child-side action required (children pick up the prior behavior on next `import-shamt`); no data migration. Who to tell: the submitting child (FantasyFootballHelperScripts) if reverted.

---

## Validation Considerations

Dimension hints for Phase 2:

- **Paired-edit completeness (easy to forget):** each `commands/{name}.md` edit pairs with a `skills/{name}/SKILL.md` description touch (rows 1↔3, 2↔4). Confirm the SKILL `## Protocol` stays a pointer (no step paraphrase) — D2 Command→Skill pointer rule.
- **Row 3 whole-file #41-staleness correction (D2/D6 alignment):** row 3 does more than add the grandparent note — it corrects the stale #41 claim that recurs in **four** sections of the `ps1-define` SKILL (`description:`, `## Mode A`, `## Recommended model`, `## Exit criteria`), each of which still asserts the pre-#41 "INLINE Pattern-1 validation loop / stamps the Validated footer / defines + validates" model that `commands/ps1-define.md` line 7 and the proposal's Problem (line 24) contradict. The validator should confirm **all four** rewritten sections match the command body (define-only, defers validation to `/ps2-validate`, no footer stamp; Balanced model; exit criteria says no footer + grandparent outcome) — D2 cross-doc consistency / D6 doc currency. Row 4 (`ps2-validate` SKILL) carries **no** analogous #41 fix: its description is already accurate post-#41 (it correctly states ps2-validate runs the inline loop and stamps the footer), so row 4 adds only the grandparent note + trigger + exit-criteria outcome.
- **Symmetry check (ps1 + ps2):** verify the grandparent section in both commands reads identically modulo define↔validate verbs and the next-command suggestion, exactly as #39 kept the feature→stories parent batch symmetric across the pair.
- **Principle-1 framing:** the validator should read the new section + Notes bullet hardest for any wording that implies cross-phase chaining (defining features, decomposing, validating) — the whole proposal hinges on this staying single-phase nested fan-out.
- **Dispatch correctness:** confirm the truly-unresolved-slug halt survives and only an *epic*-resolving slug enters the grandparent branch; confirm the empty/un-decomposed-epic case exits cleanly (no-op) rather than halting, mirroring the parent-batch "empty parent" rule.
- **Surfaces affected:** commands + skills (host templates) + the hand-written `README.md` quick reference (the `/ps1-define` / `/ps2-validate` table rows + the **Parent-slug batch mode** callout, which both currently describe only the parent-feature batch and would be left stale by the grandparent addition). No rules-file (`SHAMT_RULES.template.md`) change — this is per-command flow detail, not a child-rules concern (size budget D12). Propagation: regen + child import (README is hand-written canonical — no regen needed for it, but it must be edited directly since it is not template-generated).
- **README batch-mode callout reconciliation:** the README's existing callout asserts the parent-slug batch is "horizontal sibling fan-out at one altitude" and "does **not** chain into the next altitude's command." The grandparent mode reaches two structural levels (epic → feature → story). The README edit must reconcile this exactly as the command-body Notes do — single *phase* (story-define / story-validate), nested fan-out, never vertical cross-*phase* chaining — so the README does not read as contradicting the new mode.

---

## Open Questions

*(none — all resolved below)*

---

## Resolved Questions

~~OQ-1 (shape): grandparent batch for `/ps1-define`, or a full vertical cross-phase pipeline?~~ → A: **Grandparent batch for `/ps1-define`** — epic slug → define every story under every feature, run as the single story-define phase via nested dispatch of ps1's own logic. Does **not** define features, decompose, or validate. Stays inside the "horizontal fan-out, not vertical chaining" discipline (Principle 1). The Problem section already frames this; the vertical-pipeline reading is explicitly out of scope.

~~OQ-2 (scope): grandparent mode on `/ps1-define` only, or also `/ps2-validate`?~~ → A: **Both `/ps1-define` and `/ps2-validate`** — keep the define/validate sibling pair symmetric (they received the feature→stories parent batch together in #39), giving a complete define→validate cycle at the epic grain (`/ps1-define {epic}` then `/ps2-validate {epic}`). Proposed Changes rows 2 & 4 are firm. Generalization is bounded to the story-altitude pair — the feature commands have no grandparent above epic.

~~OQ-3 (single epic vs. all epics): does "every epic one by one" mean one named epic's subtree or a slugless all-epics sweep?~~ → A: **Single named epic's full subtree per invocation** — `/ps1-define {epic-slug}` processes that one epic; run again with another slug for another epic. Matches the existing required-slug signature. No slugless "sweep all epics" mode is added (that would be a separate, larger proposal beyond the parent-batch pattern).

---
Validated 2026-06-20 — 1 round, 1 adversarial sub-agent confirmed
