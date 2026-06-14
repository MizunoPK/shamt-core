# Proposal: d6-currency-include-testing-standards

**Created:** 2026-06-14
**Status:** Implemented
**Number:** 22
**Proposed by:**
**Project context:**

> **Scope note:** merged per OQ1 — this proposal wires the third project doc
> (`TESTING_STANDARDS.md`, added by #21) into **all** the mechanisms that treat the
> project-specific-files set as a unit: the audit's **D6** currency dimension *and* the
> Engineer-flow **Review/Polish** documentation-impact mechanics (absorbing the former
> `phase6-7-testing-standards-doc-updates` draft).

---

## Problem

Proposal #21 added `TESTING_STANDARDS.md` as a **third** required project-specific doc. It is
seeded at init alongside `ARCHITECTURE.md` / `CODING_STANDARDS.md`, carries the identical
`Last Updated:` header contract (`templates/testing_standards.template.md:2`), and is governed by
the same `doc_staleness_threshold_days` config value — `README.md:235` and `init-shamt.sh` already
describe that threshold as covering **"the three project-specific docs."**

But the third doc was never wired into the mechanisms that operate on the project-doc set as a unit.
Two of them still name only the two original docs:

**1. Audit dimension D6 (project-doc currency)** — the dimension whose job is to confirm the required
project docs exist and are fresh — checks only `ARCHITECTURE.md` and `CODING_STANDARDS.md`. A child
missing `TESTING_STANDARDS.md`, or whose copy has gone stale, passes D6 clean. D6 is defined in three
canonical places, all naming only the two docs:

- `reference/audit_dimensions.md:21` — the Completeness-table D6 row.
- `host/templates/claude/commands/f5-audit-framework.md` — Prerequisites (`:36`), the D6 dimension-table
  row (`:47`), the Step-2 D6 logic (`:125–133`, the **both present / one missing / both missing** branch
  structure + the `Last Updated:` header-contract pointer at `:129`), and the Notes recap (`:231`).
- `host/templates/claude/skills/f5-audit-framework/SKILL.md` — the D6 summary bullet (item 6).

**2. Engineer-flow Review/Polish documentation-impact mechanics.** `testing_standards.template.md:11-16`
("How to Update") promises the same maintenance mechanism its siblings get: *"Phase 6 (Review) flags
whether a story implies an update; Phase 7 (Polish) applies it and re-validates."* But the Phase 6/7
bodies that implement that mechanism enumerate only the two original docs, so `TESTING_STANDARDS.md`
would silently never be updated through the normal flow despite its own template pointing at Phase 6/7:

- `host/templates/claude/commands/e6-review-changes.md` — the `## Standards check` prerequisite (`:45`)
  and the **Documentation Impact Assessment** (`:92–105`: the trigger question + the `## Documentation
  Impact` block, which has rows for only ARCHITECTURE/CODING_STANDARDS at `:103–104`). Skill mirror at
  `e6-review-changes/SKILL.md:39`; the block is written from the `## Documentation Impact` section of
  `templates/code_review.template.md` (`:183–184`), which likewise carries only the two doc rows.
- `host/templates/claude/commands/e7-resolve-feedback.md` — the frontmatter `description` (`:2`), the
  prerequisite (`:33`), and the doc-update step (`:79–80`: apply the Polish action, bump `Last Updated`,
  re-validate) all name only the two docs. Skill mirror (body + its frontmatter `description`) likewise.
  *(e6's command/skill frontmatter and f5's do **not** enumerate the doc pair — only e7's does — so only
  e7 needs a frontmatter edit.)*
- `templates/SHAMT_RULES.template.md` — the rule-level **Standards check** (`:182`, "governing references
  for artifacts and reviews") names only ARCHITECTURE/CODING_STANDARDS; this is the doc-set statement whose
  review-side host mirrors are the in-scope e6/e7 prerequisites. *(The rules file's other two doc-pair
  mentions — the Pattern 1 Step 2 alignment line (`:203`) and the spec-research **digest** (`:343`) — are
  deliberately left untouched per OQ2: each enumerates the same doc pair as an out-of-scope command body
  (`:203` ↔ `validate-artifact.md:67`, a verbatim mirror; `:343` ↔ `e2-define-spec.md:55`, a content
  mirror), so rewording the rule side alone would introduce a rules↔host D2 lag.)*

The fix enumerates / generalizes `TESTING_STANDARDS.md` everywhere the project-doc set is treated as a
unit, preserving each mechanism's existing severity ladder, trigger semantics, and the self-host
not-applicable case.

## Proposed Changes

> ~9 canonical files (≤ 10) — **Phase 3 not required**. The `host/templates/claude/` edits are
> propagated to `.claude/` by `/f4-regen-framework` after `/f3` (not a Proposed Changes row). The
> `SHAMT_RULES.template.md` row uses the single-passage (`:182`) generic reword chosen in OQ2
> (D12-negative — it shrinks the file, currently 39,954 / 40,000).

| File / area | Op | What |
|---|---|---|
| `reference/audit_dimensions.md` | EDIT | D6 Completeness-table row (`:21`): add `TESTING_STANDARDS.md` to the required-docs list. The D6 self-host not-applicable known-exception (`:113`, "no project docs expected") reads generically — no edit. |
| `host/templates/claude/commands/f5-audit-framework.md` | EDIT | D6: (a) Prerequisites (`:36`); (b) dimension-table row (`:47`); (c) Step-2 logic (`:125–133`) — generalize to three docs: **all three present** → per-doc staleness (add `templates/testing_standards.template.md` to the header-contract pointer at `:129`); **any missing (≥1 present)** → HIGH per missing doc; **all three missing** → self-host LOW / child CRITICAL (self-host detection rule unchanged); missing `TESTING_STANDARDS.md` is HIGH by parity; (d) Notes recap (`:231`). |
| `host/templates/claude/skills/f5-audit-framework/SKILL.md` | EDIT | D6 summary bullet (item 6): add `TESTING_STANDARDS.md` + header-contract pointer. |
| `host/templates/claude/commands/e6-review-changes.md` | EDIT | Standards-check prereq (`:45`) + Documentation Impact Assessment (`:92–105`): add a `TESTING_STANDARDS.md` row to the `## Documentation Impact` block and the trigger question. Story-level Doc Impact keeps firing only when the change *touches* the doc (pure staleness stays D6's job, per `:96`). |
| `host/templates/claude/skills/e6-review-changes/SKILL.md` | EDIT | Documentation Impact Assessment bullet (`:39`): add `TESTING_STANDARDS.md`. |
| `templates/code_review.template.md` | EDIT | `## Documentation Impact` block (`:183–184`): add a `TESTING_STANDARDS.md` row mirroring the e6 command's Step-4 block, so the template the Review phase fills carries every row the protocol now writes (D5 template-protocol alignment). |
| `host/templates/claude/commands/e7-resolve-feedback.md` | EDIT | Frontmatter `description` (`:2`, which enumerates the two docs) + Prereq (`:33`) + doc-update step (`:79–80`): name `TESTING_STANDARDS.md` in the description, and apply the Polish action to / bump `Last Updated` on / re-validate it when the review's Documentation Impact block flags it. |
| `host/templates/claude/skills/e7-resolve-feedback/SKILL.md` + frontmatter `description` | EDIT | Name `TESTING_STANDARDS.md` alongside the other two in the doc-update summary. |
| `templates/SHAMT_RULES.template.md` | EDIT | Standards check (`:182`) **only**: replace the explicit "`ARCHITECTURE.md` and `CODING_STANDARDS.md`" pair with the generic "the `.shamt-core/project-specific-files/` docs". Leave the Pattern 1 Step 2 alignment line (`:203`) and the spec-research digest (`:343`) untouched — each enumerates the same doc pair as an out-of-scope command body (`:203` ↔ `validate-artifact.md:67`, a verbatim mirror; `:343` ↔ `e2-define-spec.md:55`, a content mirror), so rewording the rule side alone would create a rules↔host D2 lag (OQ2, narrowed). Genericizing the one `:182` occurrence is D12-negative (shrinks the file); re-measure with `wc -m` at `/f3`. |

**Paired-edit cross-check:** each mechanism's rule ↔ command ↔ skill move together (D2/D9). The D6
reference/command/skill triad; the e6 command ↔ skill ↔ `code_review.template.md` Documentation Impact
block (D5); the e7 command ↔ skill; and the SHAMT_RULES
`:182` Standards-check statement ↔ its e6/e7 prerequisite implementations (`e6:45` / `e7:33`). The rules
file's other two doc-pair mentions (`:203`, `:343`) are intentionally **out of scope** — their host
mirrors (`validate-artifact.md:67`, `e2-define-spec.md:55`) are not edited, so the rule side is left
as-is to keep each rule↔host pair consistent.

## Risks

- **D12 budget breach (the merge's main new risk).** Naming `TESTING_STANDARDS.md` in the
  `SHAMT_RULES.template.md` doc-set passage would push the rules file (39,954 / 40,000) past budget.
  *Mitigation:* resolved by OQ2 (narrowed) — the `:182` Standards-check passage uses the generic "the
  `.shamt-core/project-specific-files/` docs" phrasing, which shrinks the file and decouples the rule
  from the doc count; `:203`/`:343` are left untouched (no growth). Re-measure with `wc -m` at `/f3`.
- **Migration: pre-#21 children.** A child lacking `TESTING_STANDARDS.md` now flags D6 HIGH. *Mitigation:*
  correct behavior — `/sync-import-shamt` seeds it on the next pull; no legacy production children (#21 OQ5).
- **Self-host false positive.** shamt-core has none of the three docs. *Mitigation:* the self-host
  detection rule is untouched; "all three missing on self-host" → single LOW informational.
- **Review-phase noise.** Adding `TESTING_STANDARDS.md` to the Doc Impact block could prompt spurious
  "Required" answers. *Mitigation:* the existing trigger gate (`e6:96` — Doc Impact fires only when the
  change *touches* the doc) applies identically; pure staleness remains D6's responsibility, not Phase 6's.

## Rollback Plan

Single squash commit (`shamt-core: land #22 …`) via `/f6-archive-proposal`; `git revert` restores the
two-doc wording across all touched files. Re-run `/f4-regen-framework` after revert to resync `.claude/`.
No child state, no master data.

## Validation Considerations

- **D2/D9 consistency.** After the change, every in-scope doc-set mechanism (D6 audit triad; e6/e7
  Review/Polish bodies; the SHAMT_RULES `:182` Standards-check statement ↔ its e6/e7 prerequisites)
  agrees that the project-doc set is three docs; a future `/f5` D2/D9 sweep finds no rules↔host lag
  introduced by this change. The rules file's `:203`/`:343` mentions stay aligned with their
  out-of-scope host mirrors (`validate-artifact.md:67`, `e2-define-spec.md:55`) by being left unedited.
- **D5 / template-protocol.** `testing_standards.template.md`'s "How to Update" Phase-6/7 promise is now
  actually implemented by e6/e7 — no template-protocol misalignment. And `code_review.template.md`'s
  `## Documentation Impact` block gains the matching `TESTING_STANDARDS.md` row, so the template carries
  every row e6 Step 4 now writes (no template-missing-section drift).
- **D12 re-measure.** `wc -m templates/SHAMT_RULES.template.md` < 40,000 after the OQ2-chosen edit.
- **D6 branch-logic trace.** all three present + fresh (clean); one stale (MEDIUM); `TESTING_STANDARDS.md`
  missing on a child (HIGH); all three missing on self-host (single LOW); all three missing on a child (CRITICAL).
- **Doc-impact trace.** A story that changes the project's run procedure routes Phase 6 to flag a
  `TESTING_STANDARDS.md` update and Phase 7 to apply + re-validate it.
- **Regen.** `/f4-regen-framework --check` reports zero drift after the host edits.
- This proposal is validated (`/validate-artifact`) before `/f3-implement-update`.

---

## Resolved Questions

- **OQ1 — Scope: stand alone, or merge with `phase6-7-testing-standards-doc-updates`?** *Resolved
  (user):* **Merge both into #22.** Both stem from the same root cause (the third project doc not wired
  into doc-set mechanisms); a single "wire `TESTING_STANDARDS.md` into all doc-set mechanics" proposal
  lands the whole fix in one commit. The `phase6-7-testing-standards-doc-updates` f0 draft is dropped
  (its content is absorbed into the Problem + Proposed Changes above).

- **OQ2 — How should the `SHAMT_RULES.template.md` doc-set passages be edited, given the D12 budget
  (39,954 / 40,000)?** *Resolved (user):* **generic reword, narrowed to `:182` only.** Replace the
  explicit "`ARCHITECTURE.md` and `CODING_STANDARDS.md`" pair in the `:182` Standards-check statement
  with "the `.shamt-core/project-specific-files/` docs" — D12-negative (shrinks the file), future-proof,
  and decoupled from the doc count. The rules file's other two doc-pair mentions — the Pattern 1 Step 2
  alignment line (`:203`) and the spec-research digest (`:343`) — are **left untouched**: each enumerates
  the same doc pair as an out-of-scope command body (`:203` ↔ `validate-artifact.md:67`, a verbatim mirror;
  `:343` ↔ `e2-define-spec.md:55`, a content mirror), so rewording the rule side alone would introduce the
  rules↔host D2 lag this proposal explicitly promises to avoid. (Rejected: the original "genericize all three" reading, which would drag
  `validate-artifact.md` — 3 mention sites at `:67`/`:120`/`:133` — and `e2-define-spec.md:55` into
  scope, pushing the change set past 10 files and triggering a required Phase 3 plan; (B) name-it-plus-trim
  reintroduces D12 pressure; (C) leave `:182` untouched creates a rule↔host lag a future D2 sweep would flag.)

## Open Questions

_(none — all resolved above)_

---
Validated 2026-06-14 — 6 rounds, 1 adversarial sub-agent confirmed
