# Proposal: ps1-define-epic-slug-batch-mode

**Created:** 2026-06-19
**Status:** Draft (f0 — audit capture, unrefined)
**Proposed by:** FantasyFootballHelperScripts
**Project context:** Hit while running `/ps1-define T1` — T1 resolved to an epic, which the current altitude dispatch rejects ("neither own nor parent altitude — nothing to define").

> **f0 DRAFT — unrefined capture.** Quick-captured by the framework audit
> or a user; not yet through the open-questions dialog. Run
> `/f1-propose-update ps1-define-epic-slug-batch-mode` to flesh it out.

---

## Problem

[Deferred to /f1-propose-update — see Scratch Notes below.]

## Scratch Notes (f0 capture)

I want to support providing an **epic** slug to `/ps1-define`, where it causes us to walk through every epic one by one, and the features within one by one, and the stories within one by one.

Context / origin:
- This surfaced running `/ps1-define T1`. `T1` is the top-level epic `T1-win-rate-sim-overhaul-sweep-endless-modes`. The command's Step 2 **altitude dispatch** today only recognizes two altitudes: **own** (slug → a *story* folder → define that one story) and **parent** (slug → a *feature* folder → batch-define every story under the feature). An **epic** slug falls into the "neither" branch and halts with `slug {slug} resolves to neither a story (own altitude) nor a feature (parent altitude) — nothing to define`.
- The ask is to add a **grandparent altitude**: passing an epic slug runs the existing per-feature batch logic across *every* feature under the epic, which in turn runs the per-story define + inline validation across every story under each feature. Effectively a nested fan-out: epic → features (one by one) → stories (one by one).

Likely implicated canonical files (informal — f1 to confirm the real change set):
- `host/templates/claude/commands/ps1-define.md` — extend Step 2 altitude dispatch to recognize the epic altitude, and add an "epic-slug grandparent batch mode" section (mirroring the existing `## Parent-slug batch mode (feature → all stories)` section, one level up). Must stay a **stateless, disk-derived dispatcher** of the existing single-story / feature-batch logic (Principle 1) — derive the feature worklist from the epic's `## Sequencing & Parallelization` / `## Target Features`, then dispatch the existing feature-batch per feature; resumable via the same skip-already-validated check.
- `host/templates/claude/skills/ps1-define/SKILL.md` — its `## Exit criteria` / batch-mode mention may need a one-line note that a parent **epic** slug is now also accepted (keep it a Protocol pointer, no step paraphrase).

Open considerations to resolve in f1 (not decided here):
- Does this also apply to the sibling decompose/define commands that already have feature-slug batch modes (e.g. `/pf1-define`, `/pf2-decompose`, which the rules describe with epic-slug batch behavior) — i.e. is `/ps1-define` just catching up to a pattern the others already have, and should the change be framed as consistency across the PO-flow batch family? The blurb's phrasing ("every epic one by one") hints the user may want this generalized, not just `ps1-define`-local.
- The phrase "every epic one by one" — is the intent a single named epic's full subtree, or literally *all* epics in the tree when no slug is given? Almost certainly the former (one epic slug → its whole subtree), but f1 should confirm.

---

## Proposed Changes

A flat list of canonical files the proposal will touch. **Every file the proposal will edit, create, delete, or move must appear here** — Phase 2 (validate-artifact) and Phase 4 (implement-update) both read this list as the source of truth for change scope.

| # | Canonical path | Operation | One-line change description |
|---|----------------|-----------|------------------------------|
| 1 | `shamt-core/host/templates/claude/commands/...` | EDIT | [f1 to fill] |

---

## Risks

[Deferred to /f1-propose-update.]

---

## Rollback Plan

[Deferred to /f1-propose-update.]

---

## Validation Considerations

[Deferred to /f1-propose-update.]

---

## Open Questions

[Deferred to /f1-propose-update.]

---

## Resolved Questions

[None yet.]
