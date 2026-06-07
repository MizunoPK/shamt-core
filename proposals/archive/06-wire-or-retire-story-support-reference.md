# Proposal: wire-or-retire-story-support-reference

**Created:** 2026-05-31
**Status:** Implemented
**Number:** 06
**Proposed by:**
**Project context:**
**Note (2026-06-07, f1 re-entry — decision flipped to RETIRE):** the original draft resolved the load-bearing wire-vs-retire question as "wire it in (light/central)". On re-examination the content proved **partially redundant** with live bodies (context-clears already instructed in e2/e3/e6; the `addressed_feedback` outline + statuses already in `SHAMT_RULES.template.md` + `/e7-resolve-feedback`; the `stories/{slug}/` layout scattered across two-dozen-plus live files), so an orphaned consolidated copy is a drift liability rather than an asset. Decision flipped to **retire (DELETE)** (user choice, 2026-06-07). Proposed Changes rewritten from 4 wire-citations to a single DELETE; the stale `shamt-core/` path prefixes from the old wire rows are dropped (the only path now is the deleted file, repo-root-relative). Numbered #06.

---

## Problem

`reference/story_support.md` is an **orphaned reference doc** — a D3 (bidirectional-coverage) gap surfaced by `/f5-audit-framework`: nothing in the live canonical surface cites it. Verified by a whole-repo grep, it is referenced **only** by archived proposals under `proposals/archive/`; no host command/skill/persona, the rules file `templates/SHAMT_RULES.template.md`, or any live `reference/` doc points to it.

The 100-line doc (validated 2026-05-27) holds three blocks: per-Gate **context-clear handoff snippets** (Gate 2a / 2b / 3 / Review), **story artifact-layout trees** (Quick clean / Quick with-findings / Standard), and the **`addressed_feedback.md` outline + 7-status list**.

**Why retire rather than wire** (the load-bearing decision): the content is **partially redundant** with material already live elsewhere —

- *Handoff snippets* — `/e2-define-spec` and `/e3-plan-implementation` already instruct "suggest a context-clear breakpoint", and `/e6-review-changes` instructs a `/clear`, at the relevant gates; `story_support.md` only adds the exact snippet wording (convenience, not load-bearing).
- *Artifact-layout trees* — the `stories/{slug}/` structure is already referenced across **two-dozen-plus** live files (the e-flow commands `e1`/`e3`/`e6`/`e7` and most templates — spec / context / active_artifacts / manual_test_plan, etc.); `story_support.md` consolidates but does not originate it. (Exact count varies with grep scope and is immaterial — the point is the layout is documented widely, not only here.)
- *`addressed_feedback` outline + statuses* — already referenced in `templates/SHAMT_RULES.template.md` and `/e7-resolve-feedback` (which lists the statuses).

So the doc is a **consolidated second copy** of scattered live content, with no consumer. Wiring it (the original plan) would create live consumers but also a **drift liability** — a validated-2026-05-27 snapshot the live bodies will diverge from over time. Retiring it removes the maintenance burden; nothing breaks because every concept it covers is already live. The one genuinely-unique bit (the exact handoff-snippet *wording*) is small enough to inline into the relevant e-flow command if ever wanted — out of scope here.

---

## Proposed Changes

Retire the orphan: delete `reference/story_support.md`. It is fully orphaned (zero live consumers — verified), so the DELETE is safe and **no citation needs removing** anywhere.

| # | Canonical path | Operation | One-line change description |
|---|----------------|-----------|------------------------------|
| 1 | `reference/story_support.md` | DELETE | Remove the orphaned reference doc. Verified zero live consumers (whole-repo grep: referenced only by archived proposals). No other file cites it, so there is no companion citation-removal edit. |

Row count: 1 ≤ 10 — no Phase 3 plan required.

**Not regenerated:** `reference/` is not under `host/templates/claude/`, so the deletion does **not** propagate via `/f4-regen-framework` (it won't appear in the `--check` diff). It reaches child projects via the next `/sync-import-shamt`.

---

## Risks

- **Content-loss risk** — deleting discards the validated consolidated reference (handoff snippets, artifact trees, addressed_feedback outline). **Mitigation:** every concept is already covered by live bodies (e2/e3/e6 context-clears; `SHAMT_RULES` + `/e7` for addressed_feedback; two-dozen-plus files for the artifact layout). The only unique loss is the exact handoff-snippet *wording* — convenience material, not an executable instruction; it can be inlined into an e-flow command later if missed. Git history preserves the file (recoverable via `git revert` / `git show`).
- **Regression risk** — none. No live consumer → no broken reference, no executable-instruction change.
- **Child-project compatibility** — `import-shamt` **overwrites** canonical sources from master's sync set but does **not prune** files master removed (no `rsync --delete` / prune step — verified in `import-shamt.sh`). So a child that previously imported `story_support.md` keeps a harmless **orphan copy** under `.shamt-core/reference/` until it deletes it manually (or a future `import-shamt` gains pruning). No breakage — the stale copy is simply uncited, exactly as on master before this change.
- **Drift risk** — none introduced; the deletion *removes* a drift liability (a snapshot doc that duplicates live content).
- **Open-questions debt** — the wire-vs-retire decision is resolved (retire); no open questions remain.

---

## Rollback Plan

`git revert <commit-sha>` restores `reference/story_support.md` verbatim. No `/f4-regen-framework` needed (reference docs are not regenerated). No child-side action required (children retained their copy regardless).

---

## Validation Considerations

- **Orphan completeness (highest-risk)** — re-confirm zero live consumers before deleting: `grep -rl "story_support" .` (excluding `proposals/archive/`, the file itself, and this proposal) must return nothing. If any live file cites it, that file needs a companion citation-removal row and this becomes a >1-row change.
- **Affected surfaces** — one file deleted (`reference/story_support.md`); nothing else. No rules, host bodies, personas, scripts, or other references touched.
- **No regen** — `reference/` is not regenerated; the deletion lands on next `/sync-import-shamt`, not via `--check`.
- **Child-prune caveat** — confirm the `import-shamt` no-prune behavior is acknowledged (children retain a harmless orphan copy); this is a known limitation, not a blocker for the master-side retire.

---

## Open Questions

(none remaining)

---

## Resolved Questions

<!-- Drafting-only log -->

- ~~Q: Wire `reference/story_support.md` into the Engineer flow or retire it?~~ → A: **Retire (DELETE)** (user choice, 2026-06-07; reverses the original draft's "wire it in"). The content is partially redundant with live bodies (context-clears in e2/e3/e6; addressed_feedback in `SHAMT_RULES` + `/e7`; artifact layout across two-dozen-plus files), so an orphaned consolidated copy is a drift liability without a consumer. Retiring removes the maintenance burden; nothing breaks because every concept is already live. The unique handoff-snippet wording is convenience-only and can be inlined later if missed.
- ~~Q (original draft): how extensively to wire — light/central vs. distributed per-breakpoint?~~ → **Moot:** superseded by the retire decision; no wiring is done.

---

---
Validated 2026-06-07 — 3 rounds, 1 adversarial sub-agent confirmed (DELETE/retire proposal, flipped from the original "wire it in" after finding the content partially redundant with live bodies; round 1 corrected the e6 context-clear phrasing — e2/e3 say "context-clear breakpoint", e6 says "/clear" — and a file-count undercount; the sub-agent confirmed the orphan-completeness DELETE safety gate (zero live consumers), the redundancy claims, and the import-shamt no-prune caveat; the brittle file count was dropped to a qualitative "two-dozen-plus")
