# Proposal: d5-template-list-missing-epic-feature-templates

**Number:** 32
Created: 2026-06-15
Status: Implemented
Proposed by:
Project context:

## Problem

The `/f5-audit-framework` **D5 (template-protocol alignment)** dimension-table cell freezes a
hardcoded, by-name enumeration of the templates D5 must align-check — and that enumeration is
**incomplete**. The D5 row in `host/templates/claude/commands/f5-audit-framework.md` (line 46)
names 14 templates (`spec`, `implementation_plan`, `testing_plan`, `manual_test_plan`,
`agent_test_session`, `context`, `code_review`, `active_artifacts`, `ticket.ado`, `ticket.github`,
`architecture`, `coding_standards`, `testing_standards`, `proposals/_template.md`) but omits two
real, actively-consumed templates that exist under `templates/`: `epic.template.md` and
`feature.template.md`. Both are written by PO-flow producers (`/pe0-draft` and `/pe1-define`
write `epic.md` from `epic.template.md`; `/pf0-draft`, `/pf1-define`, and `/pe2-decompose` write
`feature.md` from `feature.template.md`). So the audit's own template-alignment enumeration fails
to cover two templates whose producing/consuming protocols D5 exists to check.

**Confirmed root cause (adversarial diagnosis — Opus `root-cause-diagnoser` + Haiku zero-bias
confirmation, 2026-06-15).** The defect is **not** the two specific missing rows, and **not** drift
after a later template addition. Two facts pin a deeper altitude:

- **The list was wrong at the initial commit.** `epic.template.md` and `feature.template.md`
  existed from day one (`git log --diff-filter=A` shows them at the initial commit) — they were
  never *added later*, so nothing ever *drifted*. The enumeration was **born** out of sync with
  the on-disk `templates/` set it claims to cover. A guard that fires on *additions* (e.g. a D10
  count-claim) would never have caught this, because nothing was ever added.
- **The hand-list is redundant.** The D5 *Step 2 detail prose* (line 117 of the same file) is
  **already generic** — "For each template, find the command/skill that produces or consumes it"
  — and so is the companion `reference/audit_dimensions.md` D5 row (line 20: "Each template carries
  every section its producing/consuming protocol writes or reads"). Both already derive D5's target
  set from disk. The table-cell by-name list is a **second, authoritative-looking source** of that
  same set that duplicates the prose and contradicts it whenever the hand-list is wrong — which it
  was, from the start.

So the true root cause is the **existence of a frozen hand-list as a parallel source of D5's target
set** in the dimension table. The class this belongs to: *an audit dimension that checks "every X on
disk" must derive X from disk, never freeze a parallel hand-list — because a hand-list can be (and
here always was) wrong, and the audit that exists to catch staleness cannot catch its own.*

## Proposed Changes

| # | Path | Op | Change |
|---|------|----|--------|
| 1 | `host/templates/claude/commands/f5-audit-framework.md` | EDIT | D5 row of the audit-dimensions table (line 46): replace the frozen 14-name enumeration with **disk-derived phrasing** matching the already-generic Step 2 prose — "Each artifact-producing template — every `templates/*.template.md` a producer/consumer protocol writes or reads (all of them **except** `SHAMT_RULES.template.md`, the rules file checked by D2/D12, not an artifact template), plus `proposals/_template.md` — produces artifacts shaped exactly as the protocol that consumes it expects." Keep the existing `local`-profile no-ticket-template carve-out sentence verbatim. (This automatically pulls `epic.template.md` + `feature.template.md` into D5 scope and makes the list un-driftable.) |
| 2 | `reference/audit_dimensions.md` | EDIT | "Known exceptions — do not re-flag these" section: add a carve-out line, alongside the existing `local`-ticket exception, stating that `SHAMT_RULES.template.md` is the rules file (D2/D12 domain), not an artifact template — D5 records no finding for it. Keeps the command cell and the reference D5 description symmetric so D9 (host↔reference contradiction) stays clean. |

Both rows are deliberate: the disk-derived rephrase closes the whole class (any future
`templates/*.template.md` is in D5 scope automatically; the list can never again be born or drift
wrong), and the reference carve-out keeps the two D5 surfaces from disagreeing about whether the
rules file is a D5 target. **Rejected by the diagnosis:** adding a D10 count-claim guard to pin
"the D5 list has N entries" — it institutionalizes the brittle hand-list pattern the fix removes,
and a cardinality check cannot catch a *membership* error (the right count of the wrong names).

## Risks

- **Regression** — low. The rephrase is a documentation/instruction change to one dimension cell;
  it widens D5's target set to include `epic`/`feature` (correct) and excludes `SHAMT_RULES`
  (correct — it has no artifact producer/consumer). No behavioral logic, script, or interface
  depends on the literal 14-name list (confirmed: nothing in canonical sources parses the cell —
  it is read only as prose by humans/agents).
- **Drift (canonical ↔ generated `.claude/`)** — standard; `/f4-regen-framework` propagates the
  edited command body into `.claude/commands/f5-audit-framework.md`. The `--check` gate confirms
  zero drift.
- **D9 self-consistency** — addressed by row 2: command cell and `reference/audit_dimensions.md`
  D5 description both end up generic + both carry the `SHAMT_RULES`/`local` carve-outs, so the
  audit's own D2/D9 checks will not flag the two D5 surfaces as contradictory.
- **Over-broad sweep** — the chief drafting risk was a naive "every `templates/*.template.md`"
  phrasing wrongly pulling in `SHAMT_RULES.template.md`. Explicitly excluded in both rows.
- **Open-questions debt** — none; the single design decision (carve-out explicitness) is resolved.

## Rollback Plan

Purely a canonical-doc edit: revert the commit and re-run `/f4-regen-framework` to restore the
prior `.claude/` output. No child-side action required (the next `import-shamt` re-syncs either
way). No data migration, no state change.

## Validation Considerations

- **Paired-edit check.** The two rows are a paired set (command cell ↔ reference known-exceptions);
  the validator should confirm both land and stay symmetric — a common forget is editing the
  command cell but leaving the reference D5 surface able to read `SHAMT_RULES` into scope.
- **Surfaces affected:** commands (`f5-audit-framework`) + references (`audit_dimensions.md`). No
  rules-file, template, skill, or persona change. The f5 **skill** body (`SKILL.md`) does not
  restate the dimension table, so it needs no edit — validator should confirm this (no orphaned
  by-name list elsewhere).
- **Set-coverage check.** Verify the new disk-derived phrasing resolves to exactly: the old 14
  **plus** `epic.template.md` + `feature.template.md`. Concretely: all 16 `templates/*.template.md`
  files **minus** `SHAMT_RULES.template.md` (carve-out), **plus** `proposals/_template.md`. The old
  14-list = 16 templates − `epic` − `feature` − `SHAMT_RULES` + `_template`, so the gap was exactly
  `epic` + `feature`.
- **Propagation:** regen `.claude/` + `--check`. No child import needed for correctness.
- **D10 guard explicitly out of scope** — validator should confirm no count-claim was added (its
  absence is intentional per the diagnosis, not an omission).

---
Validated 2026-06-16 — 2 rounds (primary clean + adversarial validation-checker confirmed: zero issues)
