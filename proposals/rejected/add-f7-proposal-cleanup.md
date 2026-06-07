# Proposal: add-f7-proposal-cleanup

**Created:** 2026-06-02
**Status:** Draft
**Proposed by:**
**Project context:**

---

## Problem

The framework-update flow (`/f1-propose-update` → `/validate-artifact` → `/f2-plan-update-implementation` → `/f3-implement-update` → `/f4-regen-framework` → `/f5-audit-framework` → `/f6-archive-proposal`) is entirely **single-proposal scoped**. Every command takes one `{slug}` and walks one proposal from draft to archive. There is no command that looks at the *set* of active proposals as a whole.

In practice the active set drifts. Today `proposals/` holds 7 active drafts (`flow-progress-visibility`, `in-place-proposal-amendment`, `po-templates-all-remaining-fields-section`, `proposal-workflow-conventions`, `purge-build-phase-numbers-from-host-bodies`, `standalone-repo-path-and-detection-cleanup`, `wire-or-retire-story-support-reference`). As shamt-core evolves, an active proposal can:

- become **obsolete** — its premise was already addressed by a later commit (e.g. another archived proposal under a different slug solved the same problem), so the Problem section no longer describes reality;
- go **stale** — a recent canonical edit changed the files the proposal's Proposed Changes table targets, so its locate strings / section names / row set no longer match `HEAD` and it would mis-apply if implemented as written;
- **overlap** another active proposal — two drafts touch the same canonical files or solve adjacent problems, and merging them into one change-set would be cleaner and avoid a second regen/audit cycle;
- simply be **not worthwhile** anymore relative to the others, with no signal about which to pursue first.

Nothing in the flow surfaces any of this. The user is left to manually re-read every active proposal against recent git history before deciding what to work on next. The framework already has a precedent for a slugless, framework-wide sweep that is *also runnable standalone* — `/f5-audit-framework` (see `host/templates/claude/commands/f5-audit-framework.md`) sweeps the canonical surface and routes findings. There is no equivalent hygiene pass for the **proposal backlog** itself.

This proposal adds `/f7-proposal-cleanup`: a slugless, standalone backlog-maintenance command (master/self-host only — see Resolved Questions) that reads every active proposal at the master `proposals/` directory, checks each for relevance / staleness against recent shamt-core commits, identifies merge-worthy overlap, offers a gated per-item action (defer / reject / merge), and recommends a pursuit order — so the active set stays up to date, consistent, correct, and worthwhile. It is not a step in the per-proposal lifecycle (which still ends at `/f6-archive-proposal`, Phase 7); it sweeps the *set* of active proposals on demand, the way `/f5-audit-framework` sweeps the canonical surface.

---

## Proposed Changes

| # | Canonical path | Operation | One-line change description |
|---|----------------|-----------|------------------------------|
| 1 | `shamt-core/host/templates/claude/commands/f7-proposal-cleanup.md` | CREATE | The `/f7-proposal-cleanup` slash-command body: slugless, master-only backlog sweep — relevance/staleness/overlap analysis across all active proposals, gated per-item defer/reject/merge actions, and a recommended pursuit order; chat-only output. |
| 2 | `shamt-core/host/templates/claude/skills/f7-proposal-cleanup/SKILL.md` | CREATE | Skill wiring mirroring the command body (frontmatter `name`/`description`/`triggers`, Overview, Protocol summary, Recommended model, Exit criteria). |
| 3 | `shamt-core/CHEATSHEET.md` | EDIT | Add the `/f7-proposal-cleanup` row to the framework-update flow command table (after the `/f6-archive-proposal` Phase 7 row, ~line 171), labeled "backlog maintenance (slugless, standalone)" rather than a phase number. |
| 4 | `shamt-core/reference/model_selection.md` | EDIT | Add a framework-update row for `/f7-proposal-cleanup` to the per-phase guidance table (after the Phase 7 `/f6-archive-proposal` row, ~line 64), labeled "backlog maintenance (slugless)". |

No `.claude/` paths — regen (Phase 5) propagates. The regen script (`scripts/regenerate-framework.sh`) auto-discovers `commands/` and `skills/` subtrees via `find`, so it needs **no** edit to pick up the new files.

---

## Risks

- **Regression risk** — Low. Two new files plus two additive doc rows; no existing command body is modified. The only behavioral surface is the new command itself.
- **Drift risk** — Standard for any new host file: the command + skill must be regenerated into `.claude/` via `/f4-regen-framework`, and the two files must stay mutually consistent (the D2 cross-doc / D9 host↔host audit dimensions will catch a divergence). Easy to forget the skill when editing only the command.
- **Child-project compatibility** — The new managed files import cleanly on the next `import-shamt` (no migration). The command itself is master/self-host only: invoked from a child it halts with a notice (see Resolved Questions), so a child never runs cleanup against its own `.shamt-core/proposals/`. The regenerated child skill/command must make that restriction obvious so a child user is not surprised by the halt.
- **Open-questions debt** — None remaining; all four design questions (action boundary, flow positioning, output medium, surface scope) are resolved below before validation.
- **Scope-creep / silent-mutation risk** — The command *acts* (per Resolved Questions): it can `git mv` proposals to `deferred/`/`rejected/` and draft merged proposals. This must respect the no-silent-edits discipline — **every** mutation gated by an explicit `AskUserQuestion`, dispositions reuse the documented `/f6-archive-proposal` reject/defer convention rather than inventing new ones, and merged drafts route to `/validate-artifact` rather than self-validating. Drafting a merge re-implements part of `/f1-propose-update`'s seed-and-fill behavior; the command body must reference that flow, not fork it.

---

## Rollback Plan

Revert the commit and re-run `/f4-regen-framework`. The change is purely additive (two new canonical files + two additive doc rows), so revert removes the new `.claude/` artifacts on the next regen. No child-side action required beyond the next routine `/sync-import-shamt`.

---

## Validation Considerations

- **Problem clarity** — Confirm the term "active proposals" is unambiguous: it means `*.md` files at the top level of the master `proposals/` directory, excluding the `archive/`, `rejected/`, `deferred/`, `incoming/`, `submitted/`, `already-merged/` subfolders, `_template.md`, and any `{slug}_PLAN*.md` companions (a plan rides with its proposal, not as an independent backlog item). The command body must state this exclusion set explicitly.
- **Change-list completeness** — The command↔skill pair must be created together (D2/D9). The CHEATSHEET command table and `model_selection.md` phase table are the two doc surfaces that enumerate the f-flow; both must gain a row or D10 (count/claim) and D3 (bidirectional coverage) will flag the omission. Verify no *other* canonical doc enumerates the f-flow phases (the RULES file describes the flow narratively at §"framework-update", without a phase-by-phase list, so it should not need a row — confirm).
- **Master-only restriction** — Confirm the command body uses the **same self-host detection rule** that `/f5-audit-framework` and `/f4-regen-framework` use (target qualifies iff `{target}/shamt-core/` exists and its canonical sources match the ones that produced the command body, by path identity), and that the child-side halt notice is unambiguous. This is the spot most likely to be specified loosely.
- **Risk coverage** — The command *acts* on the backlog, so the body must make every mutation gated (no silent `git mv`, no silent merged-draft creation) and route merges to `/validate-artifact` rather than self-validating. The validator should check that the command does not duplicate/fork `/f1-propose-update` seed logic or `/f6-archive-proposal` reject/defer conventions — it must reference them.
- **Rollback feasibility** — Purely additive; revert + regen is sufficient. No destructive DELETE/MOVE.
- **Affected surfaces** — commands, skills, one reference doc, the CHEATSHEET. No template, persona, or script change (regen auto-discovers).
- **Propagation plan** — Requires `/f4-regen-framework` after the canonical edits. Already-installed children pick it up on the next `/sync-import-shamt`.

---

## Open Questions

_None — all resolved._

---

## Resolved Questions

<!-- Drafting-only log. -->

- ~~Q: Master/self-host only, or also child-side?~~ → A: **Master/self-host only.** The command resolves the active set at the master `proposals/` directory (the shamt-core repo root, which is also the self-host surface) and checks staleness against that single canonical git history. Invoked from a child (where proposals live under `.shamt-core/proposals/`), it **halts with a notice** to run from the shamt-core master repo. Rationale: "most recent commits in shamt-core" has clean single-history semantics only on master, and the child backlog is a transient staging area before `/sync-submit-proposal` ships drafts upstream. This deliberately diverges from `/f1-propose-update` and `/f5-audit-framework` (which run on both surfaces) — the command body must state the master-only restriction explicitly and use the same self-host detection rule those commands use to decide whether the target qualifies.
- ~~Q: Persist a report artifact or chat-only?~~ → A: **Chat-only**, matching `/f5-audit-framework`'s explicit "no log artifact" rule. Findings + recommended pursuit order are surfaced in chat; the durable record is the actual file moves performed and any merged-draft files created. Avoids a self-referential report file that would itself need an exclusion-set carve-out and could go stale.
- ~~Q: Numbered linear phase or slugless standalone command?~~ → A: **Slugless, standalone (like `/f5-audit-framework`).** f7 operates on the whole active set, not one `{slug}`, so it is not a step in the per-proposal lifecycle — the linear flow still ends at `/f6-archive-proposal` (Phase 7). CHEATSHEET and `model_selection.md` rows describe it as "backlog maintenance (slugless, standalone)" with **no** per-proposal phase number. This keeps D10 (count/claim) honest — it does not claim to be "Phase 8 of the flow."
- ~~Q: Report-only or acts on the backlog?~~ → A: **Acts with per-item confirmation.** After analysis, the command offers a gated action per finding — `git mv` obsolete proposals to `deferred/` / `rejected/` (with a top-of-file disposition note, matching the manual convention documented in `/f6-archive-proposal` Notes), and draft a merged proposal for overlapping pairs (seeded from the two sources, footers stripped, then routed to `/validate-artifact`). Every mutation is gated by an explicit `AskUserQuestion`; nothing moves silently. The command reuses the documented dispositions rather than inventing new ones, and hands merged drafts back to `/validate-artifact` rather than self-validating (phase-per-command).

---
