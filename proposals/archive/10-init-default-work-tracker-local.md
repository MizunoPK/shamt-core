# Proposal: init-default-work-tracker-local

**Created:** 2026-06-07
**Status:** Implemented
**Number:** 10
**Proposed by:**
**Project context:**

---

## Problem

A fresh Shamt install defaults the **work-item tracker to `github`** in two places — the interactive `init-shamt.sh` prompt and the copyable `shamt-config.example.json`. But a brand-new project has no tracker integration wired yet, so defaulting to `github` assumes a GitHub Issues setup the user may not have. Defaulting to **`local`** (the no-fetch profile, where the ticket is a local Markdown artifact authored by the user or stubbed by the PO flow) lets the Engineer flow work out of the box with zero external integration; the user opts *into* `github`/`ado` deliberately when they actually have one.

The two surfaces that set the default value:

- **`init-shamt.sh`** — `prompt_choice WORK_ITEM_TRACKER` (lines 248–251) takes `"github"` as its **default** (the 3rd argument). The choice list `"ado" "github" "local" "none"` is unaffected.
- **`shamt-config.example.json`** (line 4) — `"work_item_tracker": "github"`, the value a user copies to start a config.

Both should default to `local` so the two surfaces agree (user choice, 2026-06-07). The command/skill bodies (`/e1-start-story`, `/p1-start-epic`, `/p3-start-feature` + skills) only describe the *selection mechanism* ("the default comes from `.shamt-core/shamt-config.json`") and the value list — they state no hardcoded default, so they need no change. The README config table lists the legal values without naming a default.

---

## Proposed Changes

| # | Canonical path | Operation | One-line change description |
|---|----------------|-----------|------------------------------|
| 1 | `init-shamt.sh` | EDIT | In the `prompt_choice WORK_ITEM_TRACKER` block (lines 248–251), change the **default** (3rd argument, line 250: `"github"`) → `"local"`. **Disambiguation:** target only the `WORK_ITEM_TRACKER` block — leave `PR_PROVIDER`'s default (also `"github"`, a few lines below) untouched, and leave the `WORK_ITEM_TRACKER` choice list (line 251 `"ado" "github" "local" "none"`) intact (`github` stays a valid choice). |
| 2 | `shamt-config.example.json` | EDIT | Line 4 `"work_item_tracker": "github"` → `"work_item_tracker": "local"`. |

Row count: **2 ≤ 10** — no Phase 3 plan. Neither file is under `host/templates/claude/`, so **`/f4-regen-framework` is a no-op** (init-shamt.sh + shamt-config.example.json are sync-set root docs, not regenerated into `.claude/`); they land in children on next `/sync-import-shamt`.

---

## Risks

- **Behavior change for fresh installs (the intended one).** A new install that accepts the prompt default now gets `local` (no external fetch) instead of `github`. This is the desired behavior — opt-in to a real tracker — but it is a user-visible default change; note it in the change's commit/CHANGELOG sense. Existing projects are unaffected (their `shamt-config.json` is already written).
- **Disambiguation risk (init-shamt.sh).** The literal `"github"` appears as the default for *both* `WORK_ITEM_TRACKER` (line 250) and `PR_PROVIDER` (a few lines below), and again in each choice list. The edit must change **only** the `WORK_ITEM_TRACKER` default. Mitigation: the implementation locates by the surrounding `prompt_choice WORK_ITEM_TRACKER` context (lines 248–251), not a bare `"github"` grep; validation confirms `PR_PROVIDER` still defaults to `"github"`.
- **`local` profile must exist (it does).** Defaulting to `local` is only safe because `reference/trackers/local.md` is a day-one profile. Confirmed present — no new profile needed.
- **Asymmetry with `pr_provider`.** This proposal flips only `work_item_tracker`, not `pr_provider` (which stays `github`). The blurb named only the work tracker; a fresh install with `work_item_tracker: local` + `pr_provider: github` is coherent (the two are read independently per the tracker contract). Documented, accepted.
- **Two-surface consistency.** If only one surface flipped, the init prompt and the example config would disagree — a mild inconsistency a future audit could flag. Both flip together here, so they stay aligned.

---

## Rollback Plan

`git revert <commit-sha>` restores both defaults to `github`. No regen, no `.claude/` propagation. Children pick up the reverted defaults on the next `/sync-import-shamt` (only affects *future* installs / example copies; already-written child configs are untouched either way). No data loss.

---

## Validation Considerations

- **Both surfaces flipped.** Confirm `init-shamt.sh` `prompt_choice WORK_ITEM_TRACKER` default (line 250) is now `"local"` and `shamt-config.example.json` line 4 is `"work_item_tracker": "local"`.
- **PR_PROVIDER untouched (the disambiguation check).** Confirm `prompt_choice PR_PROVIDER`'s default is still `"github"` — the edit must not have flipped it.
- **Choice list intact.** Confirm `WORK_ITEM_TRACKER`'s choice list still reads `"ado" "github" "local" "none"` (`github` remains selectable; `local` was already in the list).
- **JSON validity.** `shamt-config.example.json` remains valid JSON after the edit (`python3 -c "import json; json.load(open('shamt-config.example.json'))"`).
- **`local` profile present.** `reference/trackers/local.md` exists (the default now points at it).
- **No stray default sites.** Re-grep for any other canonical site stating a hardcoded `work_item_tracker` default of `github` — there should be none (command/skill bodies describe the selection mechanism, not a default value; the README config row lists options without a default).
- **Affected surfaces.** `init-shamt.sh` + `shamt-config.example.json` — both root canonical sync-set docs, not regenerated. No `host/templates/claude/` edit → `/f4-regen-framework` is a no-op (run for `no drift` confirmation).

---

## Open Questions

(none remaining)

---

## Resolved Questions

<!-- Drafting-only log -->

- ~~Q (load-bearing): flip `shamt-config.example.json`'s `work_item_tracker` default to `local` too, or change only the interactive `init-shamt.sh` prompt default?~~ → A: **Flip the example config too** (user, 2026-06-07). Both default surfaces agree on `local`; a fresh install defaults to the no-external-tracker workflow whichever path the user takes.
- ~~Q: does `pr_provider` also change?~~ → A (resolved by f1 default): **No — `pr_provider` stays `github`.** The blurb named only the work-item tracker; `pr_provider` is read independently per the tracker contract, so `work_item_tracker: local` + `pr_provider: github` is a coherent fresh-install default. The asymmetry is intentional.
- ~~Q: does the README config table or any command/skill body state a default that needs flipping?~~ → A (researched during drafting): **No.** The README config row (line 214) lists the legal values without naming a default; the `/e1-start-story` / `/p1-start-epic` / `/p3-start-feature` command + skill bodies describe the *selection mechanism* ("the default comes from `.shamt-core/shamt-config.json`") and the value list, not a hardcoded default. Only `init-shamt.sh` and `shamt-config.example.json` set an actual default value.

---

---
Validated 2026-06-08 — 1 round, 1 adversarial sub-agent confirmed (disambiguation verified: WORK_ITEM_TRACKER + PR_PROVIDER both default to "github" at init-shamt.sh:250/255 — the edit targets only the WORK_ITEM_TRACKER block; local.md profile present; no other hardcoded default site; both files root-level → regen no-op).
