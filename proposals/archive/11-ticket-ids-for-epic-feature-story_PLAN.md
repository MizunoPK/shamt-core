# Implementation Plan (Index) — ticket-ids-for-epic-feature-story (#11)

**Created:** 2026-06-09
**Proposal:** `proposals/11-ticket-ids-for-epic-feature-story.md` (Validated 2026-06-08)
**Altitude:** Framework-update (Part 3). Executor: `plan-executor` (Haiku) via `/f3-implement-update`, **one phase at a time in deploy order**.
**Base branch:** `main`

---

## Planning Status

- **Phase-decomposed** — 3 phase files (21 Proposed-Changes rows). Decomposed because the change introduces new addressing logic (resolver + ID allocator) and touches 21 files; it would compact a single Phase-4 session.
- **Ready for mechanical validation:** [x] **All 3 phase files authored** with exact locate/replace; every locate verified unique on disk.

---

## Deploy order

The rules file (Phase 1) defines the **contract** — the resolver, the ID allocator, the folder naming, and the Ticket-IDs section. Phases 2–3 implement it in the command/skill/template bodies. **Phase 1 must land first** so the contract exists; Phases 2–3 reference it.

| Phase | File | Proposal rows | What it does | Status |
|-------|------|---------------|--------------|--------|
| 1 | `…_PLAN_phase_1.md` | 1 | Rules-file contract: Principle 1.2 resolver, Global Story Invariants story-folder resolution, Core-files + path-map naming, the new **# Ticket IDs** section (allocator + naming + back-ref + new-tickets-only) | **authored** |
| 2 | `…_PLAN_phase_2.md` | 2–9, 12, 13 | PO commands p1–p4 (+skills) — ID allocation (incl. per-child allocation in the p2/p4 decompose Step 8 + Kept-partition both-positions glob), `{ID}-{slug}-{brief}/` folders, `T{N} (slug)` back-refs, ID-or-slug resolution; + epic/feature templates (`**Ticket ID:**` header, back-ref format) | **authored** |
| 3 | `…_PLAN_phase_3.md` | 10, 11, 14–21 | e1 (+skill) — story ID allocation + stub-ID preservation + resolver; + the 8 e-command resolution-restatement updates (e2/e3/e3b/e4/e5/e5b/e6/e7) | **authored** |

---

## Authoring status (transparency)

**All three phase files are authored** with exact locate/replace (every locate verified unique on disk): Phase 1 = the keystone rules-file contract (resolver, allocator, naming, the `# Ticket IDs` section); Phase 2 = the PO commands p1–p4 (+skills) with per-child ID allocation in the p2/p4 decompose Step 8, the Kept-partition both-positions globs, the `T{N} (slug)` back-ref writing, and the two PO templates; Phase 3 = e1 (command + skill — ID allocation, stub-ID preservation, both-positions resolver) + the 8 e-command resolution-restatement updates. **Next:** batch-validate all three phase files + this index (≥2 artifacts → batch handoff), then `/f3-implement-update` runs them one phase at a time in deploy order (1 → 2 → 3).

---

## Pre-Execution Checklist

- [ ] **Proposal branch** `proposal/11-ticket-ids-for-epic-feature-story` created from `main` (Phase 1, Step 0). Halt if it already exists.
- [ ] All 21 affected paths exist on disk (verified at proposal time).
- [ ] **Hard rule:** edits go to canonical sources only — **never** `.claude/`. Phase 1 edits `templates/SHAMT_RULES.template.md`; Phases 2–3 edit `host/templates/claude/` bodies + `templates/epic.template.md` + `templates/feature.template.md`.
- [ ] Review-Prevention Gate Mapping: **N/A at framework altitude** (documentation / agent-instruction edits — no app code, data, auth, tenancy, infra, tests).
- [ ] Each phase file validated (Phase 2 footer present) before its execution.

---

## Files Touched (manifest)

| Operation | Path | Phase |
|-----------|------|-------|
| BRANCH | `proposal/11-ticket-ids-for-epic-feature-story` (from `main`) | 1 |
| EDIT | `templates/SHAMT_RULES.template.md` | 1 |
| EDIT | `host/templates/claude/commands/p1-start-epic.md` + `skills/p1-start-epic/SKILL.md` | 2 |
| EDIT | `host/templates/claude/commands/p2-decompose-epic.md` + `skills/p2-decompose-epic/SKILL.md` | 2 |
| EDIT | `host/templates/claude/commands/p3-start-feature.md` + `skills/p3-start-feature/SKILL.md` | 2 |
| EDIT | `host/templates/claude/commands/p4-decompose-feature.md` + `skills/p4-decompose-feature/SKILL.md` | 2 |
| EDIT | `templates/epic.template.md`, `templates/feature.template.md` | 2 |
| EDIT | `host/templates/claude/commands/e1-start-story.md` + `skills/e1-start-story/SKILL.md` | 3 |
| EDIT | `host/templates/claude/commands/{e2-define-spec,e3-plan-implementation,e3b-write-testing-plan,e4-execute-plan,e5-execute-tests,e5b-write-manual-testing-plan,e6-review-changes,e7-resolve-feedback}.md` | 3 |

No other path is created or edited.

---

## Global guardrail (every phase)

- **Backward-compat resolver.** The slug glob must match the slug at the folder start (`{slug}-*/`, old folders) AND after an ID prefix (`*-{slug}-*/`, new folders). Never break addressing a pre-existing slug-only folder by its bare slug.
- **Allocator scans all three roots.** `max(T№ across epics/ + features/ + stories/) + 1`, parsing `^T([0-9]+)-`, no counter file — a scan missing a root would reuse an ID.
- **Stub-ID preservation.** `/p3` (Mode A) and `/e1` (PO stub) must PRESERVE a child's already-allocated ID, never re-allocate.
- **Folder-path completeness.** Every *literal* folder reference (`{root}/{slug}-{brief}/`, not the `-*/` globs) in each touched command/skill must carry the `{ID}-` prefix — the targeted edits cover the creation/resolution sites; a final per-file `replace_all` cleanup step (Phase 2 Step 12; Phase 3 Step 1g) catches the incidental path references (raw payloads, write paths, exit criteria).
- **Collision globs widened.** The p1/p2/p3/p4/e1 slug-collision globs (and the Kept-partition globs) must check both positions so a New slug cannot silently collide with an ID-prefixed existing folder (Phase 2 Steps 1c [p1], 5e [p3], 11 [p2/p4], 3d/7e [Kept]; Phase 3 Step 1d [e1]).
- **No rule lost.** The rules-file edits (Phase 1) reword the resolver/naming and ADD the Ticket-IDs section; they remove no existing normative rule. Every other normative rule in the touched sections stays.

---

## Notes

- **No `.claude/` edits.** Phases 2–3 edit `host/templates/claude/` bodies → `/f4-regen-framework` propagates them. Phase 1 (`templates/SHAMT_RULES.template.md`) + the two `templates/*.template.md` are not regenerated (they render into a child at install/`sync-import`).
- **D12 size:** Phase 1 adds the `# Ticket IDs` section (~+1.5k chars) to the rules file (currently 35,147) → ~36.6k, still under the 40,000 budget. Phase 1's final step re-measures `wc -m` to confirm ≤ 40,000.
- **No commit in Phase 4 builds.** The commit + squash-merge land at `/f6-archive-proposal`.

---
Validated 2026-06-09 — 4 rounds, 1 adversarial sub-agent confirmed
