# Proposal: f5-audit-add-path-composition-check

Created: 2026-06-15
Status: Draft (f0 — audit capture, unrefined)
Proposed by:
Project context:

> **f0 DRAFT — unrefined capture.** Quick-captured by the framework audit
> or a user; not yet through the open-questions dialog. Run
> `/f1-propose-update f5-audit-add-path-composition-check` to flesh it out.

## Scratch Notes (f0 capture)

The f5 framework audit's D2 (cross-doc consistency), D9 (duplication / contradiction),
and D7 (terminology consistency) dimensions don't check **path-composition consistency**
across PO-tree producers — which is why proposal #30's ps0/ps1 collapsed write-path
(`epics/{parent-feature-folder}/stories/…`, dropping the `features/` segment) was never
caught by the audit and only surfaced as a downstream incident.

- **The gap.** No audit dimension verifies that every canonical mention of a *write* path
  under the §PO-tree uses the canonical `{epic-folder}` / `{feature-folder}` placeholder
  vocabulary and the **full nested form** — with no collapsed / abbreviated / divergent
  placeholders (`{parent-feature-folder}`, `{parent-epic-folder}`, `{e}`). D2/D9 check
  *instruction* and *contradiction* consistency; D7 checks *terminology* — but none of
  them treats a producer's write-path placeholder as a thing that must match a single
  canonical form, so a producer can silently drift the path shape.
- **Proposed direction.** Add a path-composition sub-check — most naturally to **D7**
  (path placeholders *are* terminology), or to D2/D9 — in
  `host/templates/claude/commands/f5-audit-framework.md` **and its mirror skill**
  `host/templates/claude/skills/f5-audit-framework/SKILL.md`, asserting that all PO
  producers share one write-path vocabulary (`{epic-folder}` / `{feature-folder}`, full
  nested form) and flagging any collapsed / abbreviated / divergent placeholder under
  the §PO-tree.
- **Relationship to #30.** Sibling / follow-up to proposal #30
  (`ps0-draft-story-stub-nesting-path-drops-features-segment`), which **fixes** the
  occurrences and homes the canonical write-vocabulary in §PO-tree resolution. This
  proposal **hardens detection** so the class can't silently re-open the next time a
  producer is added or reorganized. Best sequenced *after* #30 lands (so the canonical
  vocabulary the new check asserts against already exists).
- **Why a separate capture (not folded into #30).** The audit's own detection logic is a
  different surface from the path fix; keeping #30 scoped to the correction and this to
  the audit-hardening keeps each proposal focused (decided in #30's open-questions dialog).

## Proposed Changes

<!-- f0 stub — change list deferred to /f1-propose-update -->

## Risks

<!-- deferred to /f1 -->

## Rollback Plan

<!-- deferred to /f1 -->

## Validation Considerations

<!-- deferred to /f1 -->
