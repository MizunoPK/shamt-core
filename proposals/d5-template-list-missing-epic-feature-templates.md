# Proposal: d5-template-list-missing-epic-feature-templates

Created: 2026-06-15
Status: Draft (f0 — audit capture, unrefined)
Proposed by:
Project context:

> **f0 DRAFT — unrefined capture.** Quick-captured by the framework audit
> or a user; not yet through the open-questions dialog. Run
> `/f1-propose-update d5-template-list-missing-epic-feature-templates` to flesh it out.

## Scratch Notes (f0 capture)

The f5 framework audit's **D5 (template-protocol alignment)** dimension table enumerates
the templates D5 must align-check, but the list is **missing two real, actively-consumed
templates**: `templates/epic.template.md` and `templates/feature.template.md`.

- **The gap.** The D5 row in `host/templates/claude/commands/f5-audit-framework.md` (line 46)
  names 14 templates (`spec`, `implementation_plan`, `testing_plan`, `manual_test_plan`,
  `agent_test_session`, `context`, `code_review`, `active_artifacts`, `ticket.ado`,
  `ticket.github`, `architecture`, `coding_standards`, `testing_standards`,
  `proposals/_template.md`) but omits `epic.template.md` and `feature.template.md`. Both
  files exist under `templates/` and are actively consumed by PO-flow producers:
  `/pe0-draft` and `/pe1-define` / `/pe2-decompose` write `epic.md` from
  `templates/epic.template.md`; `/pf0-draft` and `/pf2-decompose` write `feature.md` from
  `templates/feature.template.md`. So the audit's own template-alignment enumeration does
  not cover two templates whose producing/consuming protocols it should be checking — a
  D5/D3-completeness gap in the audit's coverage.
- **Pre-existing.** The omission is identical on `main` (it predates proposal #29); #29
  only sharpened D7/D8/D11 shell-script scope and did not touch the D5 list. Surfaced now
  by the post-#29 audit sweep.
- **Why intricate (not auto-fixed).** Resolving it needs judgment, not a uniquely-determined
  text substitution: decide whether the D5 list is meant to be an *exhaustive* enumeration
  (that must always match the `templates/*.template.md` set) or an *illustrative* sample;
  if exhaustive, add the two rows AND consider whether a D10 count-claim should guard the
  list against future template additions; confirm the `reference/audit_dimensions.md` D5
  mirror stays consistent. Multi-surface + design judgment → borderline → intricate.
- **Proposed direction.** Add `epic.template.md` and `feature.template.md` to the D5
  template enumeration in `host/templates/claude/commands/f5-audit-framework.md` (and verify
  the `reference/audit_dimensions.md` D5 description does not need a matching update), and
  decide whether to pin the list as exhaustive with a guard against silent drift when new
  PO-tree templates are added.

## Proposed Changes

<!-- f0 stub — change list deferred to /f1-propose-update -->

## Risks

<!-- deferred to /f1 -->

## Rollback Plan

<!-- deferred to /f1 -->

## Validation Considerations

<!-- deferred to /f1 -->
