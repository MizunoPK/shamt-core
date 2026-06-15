# Proposal: ps0-draft-story-stub-nesting-path-drops-features-segment

Created: 2026-06-14
Status: Draft (f0 — audit capture, unrefined)
Proposed by:
Project context:

> **f0 DRAFT — unrefined capture.** Quick-captured by the framework audit
> or a user; not yet through the open-questions dialog. Run
> `/f1-propose-update ps0-draft-story-stub-nesting-path-drops-features-segment` to flesh it out.

## Scratch Notes (f0 capture)

`/ps0-draft` writes its story-ticket stub to a path that drops the `features/`
segment of the canonical PO tree, contradicting `/pf2-decompose` (the batch
producer whose stub shape `/ps0-draft` explicitly claims to mirror) and the
canonical §PO-tree resolution / rules-file nesting layout.

- **The drift.** `/ps0-draft` (both `host/templates/claude/commands/ps0-draft.md`
  and `host/templates/claude/skills/ps0-draft/SKILL.md`) writes the stub to
  `epics/{parent-feature-folder}/stories/{ID}-{story-slug}-{brief}/` — appearing
  as a direct child of `epics/`. But `/pf2-decompose` nests stories at
  `epics/{epic-folder}/features/{feature-folder}/stories/{ID}-...`, and `/e8-finalize-story`'s
  tech-story archive path is `epics/{tech-stories-folder}/features/{bugs|quick-wins}/stories/…`.
  A feature folder is never a direct child of `epics/` — it lives under
  `epics/{epic-folder}/features/{feature-folder}/`. So the ps0 path placeholder
  `{parent-feature-folder}` collapses the two real path levels into one and a
  literal read of it points stubs at the wrong place.
- **Occurrences** (5, across the command + mirror skill): `commands/ps0-draft.md`
  Step 3 line 60, Exit line 82, Exit-criteria line 90; `skills/ps0-draft/SKILL.md`
  Step 4 line 37, exit-criteria line 60.
- **Step 1 already resolves correctly.** `/ps0-draft` Step 1 resolves the parent
  feature (feature-parent mode) or the standing Tech Stories feature
  (`epics/{tech-stories-folder}/features/{bugs|quick-wins}/`) — both at the full
  nested depth. Only the *write/exit* path placeholder is wrong.
- **Why intricate (not auto-fixed).** Multi-file (command + skill), and the
  correct replacement form is a design choice: either expand to
  `epics/{epic-folder}/features/{parent-feature-folder}/stories/...` everywhere,
  OR redefine `{parent-feature-folder}` as the *full resolved path to the parent
  feature folder* (and state that definition once). Both span the command+skill
  pair and should land coherently — a coordinated, judgment-bearing edit. Pick
  the form, apply it to all 5 occurrences, then re-verify D2/D9 vs `/pf2-decompose`
  and `/e8-finalize-story`, and regen (`host/templates/claude/` edits).
- Introduced by proposal #26 (the PO grid reorg) when `/ps0-draft` absorbed the
  former tech-story fast-path; the path collapse slipped past the plan.

## Proposed Changes

<!-- f0 stub — change list deferred to /f1-propose-update -->

## Risks

<!-- deferred to /f1 -->

## Rollback Plan

<!-- deferred to /f1 -->

## Validation Considerations

<!-- deferred to /f1 -->
