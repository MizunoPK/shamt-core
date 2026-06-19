# Proposal: epic-state-tracker

**Created:** 2026-06-18
**Status:** Implemented
**Number:** 40
**Proposed by:**
**Project context:**

---

## Problem

Shamt's PO/Engineer work tree (`epics/ → features/ → stories/`, rooted at `.shamt-core/` in a child) records a work item's lifecycle position only **implicitly**, scattered across per-artifact signals: a `Validated …` footer (stamped by `/validate-artifact` on epics/features and inline by `/ps1-define` on stories), the presence of Engineer-flow artifacts (`spec.md`, `implementation_plan.md`), and the `**Status: Done**` header `/e8-finalize-story` writes into a finalized `ticket.md`. There is **no rollup** that answers, at a glance, "for this epic, what state is every feature and story in?" The only cross-item view today is the single-active-item status line (README.md §"Status-line PO modes"), which renders the *one* active story/feature/epic from `shamt-state/active-*` pointers — not a board of all children.

The user wants a per-epic **state rollup** that surfaces the lifecycle state of every feature and story under that epic, with four states: **New**, **Validated**, **Building**, **Released**. Concretely: within each `epics/{ID}-{slug}-{brief}/` folder, a generated `STATUS.md` rolling up child state so a PO can manage progress without walking the subtree by hand. (The name `STATUS.md` is chosen over "tracker" to avoid colliding with the existing **work-item tracker** profile concept in `reference/trackers/`, which is the external ADO/GitHub/local *source* of ticket content — a different thing.)

The framework is **disk-authoritative** and explicitly fights dual-source-of-truth "mirror drift" (CLAUDE.md §Three principles; proposal #37 removed a command↔skill paraphrase mirror precisely because it drifted). A hand-maintained state file kept *in parallel* with the artifacts would re-introduce that exact drift class — the rollup and the artifacts' own footers/headers could disagree, and there would be no single source of truth. The dialog therefore settled this decisively (Resolved Q1): `STATUS.md` is a **derived rollup** — re-computed from the artifacts' on-disk signals, never hand-edited — which keeps the artifacts authoritative and makes the rollup drift-free by construction. All four states are 100% disk-derivable (Resolved Q4): **New** (stub/defined, no `Validated` footer) → **Validated** (footer present) → **Building** (Engineer-flow artifacts present, not yet finalized) → **Released** (`**Status: Done**`).

---

## Proposed Changes

> **Design finalized by the Open Questions dialog** (see Resolved Questions): a **derived rollup** `STATUS.md` per epic, re-computed from on-disk state signals; refreshed **on demand** via `/po-status {epic-slug}` **and** auto-refreshed by the five transition commands; **Released = `**Status: Done**`** (finalize/merge); **feature state = rollup of child stories**. Row count is 11 → **Phase 3 (`/f2-plan-update-implementation`) is required**.

| # | Canonical path | Operation | One-line change description |
|---|----------------|-----------|------------------------------|
| 1 | `shamt-core/templates/epic_status.template.md` | CREATE | Per-epic `STATUS.md` artifact skeleton: header + a state table (one row per feature, child story rows nested) with the four states and a "Generated — do not hand-edit; run /po-status to refresh" banner. |
| 2 | `shamt-core/reference/epic_status_board.md` | CREATE | The authoritative state-derivation contract: how New/Validated/Building/Released are computed from on-disk signals for stories and features; refresh semantics; `STATUS.md`'s place in the PO tree. |
| 3 | `shamt-core/templates/SHAMT_RULES.template.md` | EDIT | §PO-tree resolution — add `STATUS.md` to the epic-folder layout and a one-line pointer to `reference/epic_status_board.md` (detail lives in the reference doc to respect the D12 size budget). |
| 4 | `shamt-core/host/templates/claude/commands/po-status.md` | CREATE | New slug-taking command `/po-status {epic-slug}` that (re)derives the epic's `STATUS.md` from on-disk state. The single regenerate entry point. |
| 5 | `shamt-core/host/templates/claude/skills/po-status/SKILL.md` | CREATE | Skill mirror for `/po-status` — `## Protocol` is the canonical pointer form (never a step paraphrase). |
| 6 | `shamt-core/host/templates/claude/commands/pe2-decompose.md` | EDIT | After writing feature stubs, create/refresh the epic `STATUS.md` so every new feature appears as `New`. |
| 7 | `shamt-core/host/templates/claude/commands/pf2-decompose.md` | EDIT | After writing story stubs, refresh the parent epic's `STATUS.md` so new stories appear as `New`. |
| 8 | `shamt-core/host/templates/claude/commands/ps1-define.md` | EDIT | After stamping the story's `Validated` footer, refresh the epic `STATUS.md` (story → `Validated`). |
| 9 | `shamt-core/host/templates/claude/commands/e4-execute-plan.md` | EDIT | On Build entry, refresh the epic `STATUS.md` (story → `Building`). |
| 10 | `shamt-core/host/templates/claude/commands/e8-finalize-story.md` | EDIT | After writing `**Status: Done**`, refresh the epic `STATUS.md` (story → `Released`; recompute feature rollup). |
| 11 | `shamt-core/README.md` | EDIT | Document `STATUS.md` under §"Hierarchy + folder layout" and add `/po-status` to the PO-flow command table. |

**Path discipline:** every row is a canonical (non-`.claude/`) path. The new `templates/epic_status.template.md` automatically enters D5 audit scope (disk-derived template list, post-#32) — no `reference/audit_dimensions.md` edit needed.

**Phase 3 required — file count 11 > 10. Run `/f2-plan-update-implementation epic-state-tracker` before `/f3-implement-update`.**

---

## Risks

- **Mirror-drift regression (the central risk).** The derived-rollup design (Resolved Q1) makes `STATUS.md` a re-computable *view*; re-running `/po-status` always yields truth, so there is no durable drift. The risk surfaces only if an implementer mistakenly has a command *write a hand-authored state* into `STATUS.md` instead of re-deriving it. **Mitigation:** every refresh hook and `/po-status` itself must re-derive the whole table from disk — never patch a single cell — and the template's "Generated — do not hand-edit" banner must be explicit. The reference doc states this as a hard rule.
- **Touch-point sprawl.** Refresh hooks in `/pe2`, `/pf2`, `/ps1`, `/e4`, `/e8` add five edit sites (Resolved Q2 chose hooks for always-live currency). Because each hook *re-derives* (not paraphrases), they don't form a drift class, but they do widen the change surface and the regen blast radius — and a hook that is *omitted* from one command silently lags that transition. The Phase 3 plan must enumerate all five so none is missed.
- **Drift risk (canonical vs `.claude/`).** New command + skill must regenerate cleanly; a missed `/f4-regen-framework` leaves `.claude/` without `/po-status`. Standard mitigation: Phase 5 `--check`.
- **Child-project compatibility.** Purely additive for existing children — they pick up the template, reference doc, command, and command-body edits on the next `import-shamt` + regen. Existing epics gain a `STATUS.md` the first time `/po-status` (or a hooked command) runs in their subtree; none is back-filled automatically. No manual reconciliation required.
- **Open-questions debt.** None — all five design forks resolved during the Phase 1 dialog (see Resolved Questions).

---

## Rollback Plan

1. `git revert <commit-sha>` on the canonical edit commit.
2. Run `/f4-regen-framework` to propagate the revert into `.claude/`.
3. Child-side: re-run `/sync-import-shamt`; existing `STATUS.md` files become orphaned (harmless) and can be deleted by hand. No data loss — `STATUS.md` is derived, so the authoritative state survives in the artifacts.
4. Communication: note to any child maintainers who began relying on `/po-status`.

---

## Validation Considerations

- **Problem clarity** — the name `STATUS.md` was chosen (Resolved Q3) specifically to avoid overloading the existing **work-item tracker** profile concept (`reference/trackers/`, the ADO/GitHub/local *source* of ticket content). The validator must confirm the proposal everywhere distinguishes the new per-epic **status rollup** (a derived `STATUS.md`) from the **work-item tracker** (an external content source) — and that no prose accidentally calls `STATUS.md` a "tracker".
- **Change-list completeness** — auto-refresh hooks (Resolved Q2) mean every transition command must be covered (`/pe2`, `/pf2`, `/ps1`, `/e4`, `/e8`); a missed one yields a `STATUS.md` that silently lags one state. Confirm the new `templates/epic_status.template.md` is shaped exactly as `/po-status` writes it (D5). Each new `SKILL.md` `## Protocol` must be the pointer form, never a step paraphrase (D2 Command→Skill rule).
- **Risk coverage** — the central risk is an implementer patching a single `STATUS.md` cell instead of re-deriving the whole table (which would re-open the drift class the derived model closes); ensure the reference doc + template banner make whole-table re-derivation a hard rule.
- **Rollback feasibility** — fully additive; revert + regen is clean. No destructive DELETE/MOVE.
- **Affected surfaces** — templates, references, rules (§PO-tree), commands, skills, README. Cross-doc: §PO-tree ↔ `reference/epic_status_board.md` ↔ `templates/epic_status.template.md` must agree on the state set, the derivation rules, and folder placement.
- **Propagation plan** — requires regen + child import. No already-installed child needs a manual nudge beyond the normal sync.

---

## Open Questions

_All open questions resolved — see `## Resolved Questions` below._

---

## Resolved Questions

- ~~Q1: Rollup model — derived view or authoritative source?~~ → A: **Derived rollup.** `STATUS.md` is a re-computed VIEW of state the artifacts already carry; `/po-status` re-derives it from on-disk signals. Artifacts stay authoritative; the rollup is drift-free by construction. Honors disk-authoritative, avoids the mirror-drift class.
- ~~Q2: Refresh mechanism — on-demand only vs auto-refresh hooks?~~ → A: **On-demand + auto-refresh hooks.** `/po-status {epic-slug}` re-derives on demand AND the transition commands (`/pe2`, `/pf2`, `/ps1`, `/e4`, `/e8`) each re-derive after their work, so the `STATUS.md` rollup is always live. Hooks re-derive (not paraphrase) → no drift class. Confirms >10 file ops → Phase 3 (`/f2`) required.
- ~~Q3: File name + the "tracker" collision?~~ → A: **`STATUS.md`** (caps, README-style "generated rollup"). Chosen over `tracker.md` to avoid colliding with the external **work-item tracker** profile concept (`reference/trackers/`). Template → `templates/epic_status.template.md`; reference contract → `reference/epic_status_board.md`; command stays `/po-status`.
- ~~Q4: "Released" semantics?~~ → A: **Released = finalized/merged.** Maps to `/e8-finalize-story`'s `**Status: Done**`. No deploy concept introduced; all four states are 100% disk-derived: New (stub/defined, no Validated footer) → Validated (footer present) → Building (Engineer artifacts present, not Done) → Released (`**Status: Done**`).
- ~~Q5: Feature-state rule?~~ → A: **Rollup of child stories.** Feature row state aggregates its stories, with this precedence: any story Building/Released → **Building**; all stories Released (and ≥1 exists) → **Released**; else if `feature.md` carries a Validated footer → **Validated**; else → **New**. The reference doc (`reference/epic_status_board.md`) encodes this precedence verbatim.

---
Validated 2026-06-18 — 2 rounds, 1 adversarial sub-agent confirmed
