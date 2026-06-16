# Implementation Plan — Phase 3: SKILL Protocol-summary migration (batch B, 16 of 33)

**Proposal:** proposals/37-mirrored-skill-summary-drift-on-command-step-change.md
**Index:** proposals/37-mirrored-skill-summary-drift-on-command-step-change_PLAN.md
**Created:** 2026-06-16
**Phase scope:** 16 EDIT operations — row 5 of the Proposed Changes table (manifest steps 23–38): the `f6` / `f-all` / `pe*` / `pf*` / `ps*` / `sync-*` / `trim-rules-file` / `validate-artifact` command-backed skills.

**Read the index's "The shared migration contract" section first** — every step here is the same mechanical edit as Phase 2 (strip the trailing ` Summary:` from the pointer line; delete the numbered "Summary:" block from the first blank line after the pointer through the line before the next `## ` heading; leave one blank line before that heading). Only the `## Protocol` section is touched.

Whole-plan / cross-phase verification lives in the **index** file, run by the architect at `/f3` post-build — not here.

**Per-step edit recipe (identical for every step):**
1. Find the **pointer line (before)** (ends in ` Summary:`); remove the trailing ` Summary:` → **pointer line (after)**.
2. Delete every line from the blank line after the pointer line down to (but not including) the **next-heading anchor**.
3. Leave exactly one blank line between the pointer line (after) and the next-heading anchor.
**Per-step verification (identical for every step):**
- `awk '/^## Protocol/{f=1} f&&/^## /&&!/^## Protocol/{exit} f' {file} | grep -E '^[0-9]+\. '` returns no output.
- `grep -F '{pointer line (after)}' {file}` returns one match.
- `grep -c 'Summary:' {file}` returns 0.

---

## Step 23 — f6-archive-proposal

**File:** `host/templates/claude/skills/f6-archive-proposal/SKILL.md`
**Pointer line (before):**
```
Follow the canonical `/f6-archive-proposal` command body verbatim — see [`commands/f6-archive-proposal.md`](../../commands/f6-archive-proposal.md). Summary:
```
**Pointer line (after):**
```
Follow the canonical `/f6-archive-proposal` command body verbatim — see [`commands/f6-archive-proposal.md`](../../commands/f6-archive-proposal.md).
```
**Next-heading anchor:** `## Recommended model`

## Step 24 — f-all

**File:** `host/templates/claude/skills/f-all/SKILL.md`
**Pointer line (before):**
```
Follow the canonical `/f-all` command body verbatim — see [`commands/f-all.md`](../../commands/f-all.md). The one-nesting-level dispatch pattern it reproduces lives in [`reference/batch_validation_handoff.md`](../../../../../reference/batch_validation_handoff.md). Summary:
```
**Pointer line (after):**
```
Follow the canonical `/f-all` command body verbatim — see [`commands/f-all.md`](../../commands/f-all.md). The one-nesting-level dispatch pattern it reproduces lives in [`reference/batch_validation_handoff.md`](../../../../../reference/batch_validation_handoff.md).
```
**Next-heading anchor:** `## Recommended models`
**Note (richer prose — proposal-flagged):** keep the "The one-nesting-level dispatch pattern …" sentence (unique guidance). Only the trailing ` Summary:` and numbered steps 0–5 are deleted.

## Step 25 — pe0-draft

**File:** `host/templates/claude/skills/pe0-draft/SKILL.md`
**Pointer line (before):**
```
Follow the canonical `/pe0-draft` command body verbatim — see [`commands/pe0-draft.md`](../../commands/pe0-draft.md). Summary:
```
**Pointer line (after):**
```
Follow the canonical `/pe0-draft` command body verbatim — see [`commands/pe0-draft.md`](../../commands/pe0-draft.md).
```
**Next-heading anchor:** `## Recommended model`

## Step 26 — pe1-define

**File:** `host/templates/claude/skills/pe1-define/SKILL.md`
**Pointer line (before):**
```
Follow the canonical `/pe1-define` command body verbatim — see [`commands/pe1-define.md`](../../commands/pe1-define.md). Summary:
```
**Pointer line (after):**
```
Follow the canonical `/pe1-define` command body verbatim — see [`commands/pe1-define.md`](../../commands/pe1-define.md).
```
**Next-heading anchor:** `## Tracker fallback`

## Step 27 — pe2-decompose

**File:** `host/templates/claude/skills/pe2-decompose/SKILL.md`
**Pointer line (before):**
```
Follow the canonical `/pe2-decompose` command body verbatim — see [`commands/pe2-decompose.md`](../../commands/pe2-decompose.md). Summary:
```
**Pointer line (after):**
```
Follow the canonical `/pe2-decompose` command body verbatim — see [`commands/pe2-decompose.md`](../../commands/pe2-decompose.md).
```
**Next-heading anchor:** `## Key distinctions`

## Step 28 — pe3-finalize

**File:** `host/templates/claude/skills/pe3-finalize/SKILL.md`
**Pointer line (before):**
```
Follow the canonical `/pe3-finalize` command body verbatim — see [`commands/pe3-finalize.md`](../../commands/pe3-finalize.md). Summary:
```
**Pointer line (after):**
```
Follow the canonical `/pe3-finalize` command body verbatim — see [`commands/pe3-finalize.md`](../../commands/pe3-finalize.md).
```
**Next-heading anchor:** `## Recommended model`

## Step 29 — pf0-draft

**File:** `host/templates/claude/skills/pf0-draft/SKILL.md`
**Pointer line (before):**
```
Follow the canonical `/pf0-draft` command body verbatim — see [`commands/pf0-draft.md`](../../commands/pf0-draft.md). Summary:
```
**Pointer line (after):**
```
Follow the canonical `/pf0-draft` command body verbatim — see [`commands/pf0-draft.md`](../../commands/pf0-draft.md).
```
**Next-heading anchor:** `## Recommended model`

## Step 30 — pf1-define

**File:** `host/templates/claude/skills/pf1-define/SKILL.md`
**Pointer line (before):**
```
Follow the canonical `/pf1-define` command body verbatim — see [`commands/pf1-define.md`](../../commands/pf1-define.md). Summary:
```
**Pointer line (after):**
```
Follow the canonical `/pf1-define` command body verbatim — see [`commands/pf1-define.md`](../../commands/pf1-define.md).
```
**Next-heading anchor:** `## Tracker fallback`
**Note:** numbered steps 1–8 here contain nested sub-bullets (Mode A / B / C) — all part of the numbered block, deleted with the list.

## Step 31 — pf2-decompose

**File:** `host/templates/claude/skills/pf2-decompose/SKILL.md`
**Pointer line (before):**
```
Follow the canonical `/pf2-decompose` command body verbatim — see [`commands/pf2-decompose.md`](../../commands/pf2-decompose.md). Summary:
```
**Pointer line (after):**
```
Follow the canonical `/pf2-decompose` command body verbatim — see [`commands/pf2-decompose.md`](../../commands/pf2-decompose.md).
```
**Next-heading anchor:** `## Key distinctions`
**Note:** step 4's numbered block contains an embedded block-quote (the individually-testable rubric, `> A story is individually testable …`) and nested template-path sub-bullets in step 8 — all part of the step-paraphrase block, deleted with the list.

## Step 32 — ps0-draft

**File:** `host/templates/claude/skills/ps0-draft/SKILL.md`
**Pointer line (before):**
```
Follow the canonical `/ps0-draft` command body verbatim — see [`commands/ps0-draft.md`](../../commands/ps0-draft.md). Summary:
```
**Pointer line (after):**
```
Follow the canonical `/ps0-draft` command body verbatim — see [`commands/ps0-draft.md`](../../commands/ps0-draft.md).
```
**Next-heading anchor:** `## Two parent modes`

## Step 33 — ps1-define

**File:** `host/templates/claude/skills/ps1-define/SKILL.md`
**Pointer line (before):**
```
Follow the canonical `/ps1-define` command body verbatim — see [`commands/ps1-define.md`](../../commands/ps1-define.md). Summary:
```
**Pointer line (after):**
```
Follow the canonical `/ps1-define` command body verbatim — see [`commands/ps1-define.md`](../../commands/ps1-define.md).
```
**Next-heading anchor:** `## Mode A (draft ingestion)`
**Note:** numbered steps 1–8 contain nested Mode A / B / C sub-bullets — all part of the block, deleted with the list.

## Step 34 — sync-import-shamt

**File:** `host/templates/claude/skills/sync-import-shamt/SKILL.md`
**Pointer line (before):**
```
Follow the canonical `/sync-import-shamt` command body verbatim — see [`commands/sync-import-shamt.md`](../../commands/sync-import-shamt.md). Summary:
```
**Pointer line (after):**
```
Follow the canonical `/sync-import-shamt` command body verbatim — see [`commands/sync-import-shamt.md`](../../commands/sync-import-shamt.md).
```
**Next-heading anchor:** `## Recommended model`

## Step 35 — sync-submit-proposal

**File:** `host/templates/claude/skills/sync-submit-proposal/SKILL.md`
**Pointer line (before):**
```
Follow the canonical `/sync-submit-proposal` command body verbatim — see [`commands/sync-submit-proposal.md`](../../commands/sync-submit-proposal.md). Summary:
```
**Pointer line (after):**
```
Follow the canonical `/sync-submit-proposal` command body verbatim — see [`commands/sync-submit-proposal.md`](../../commands/sync-submit-proposal.md).
```
**Next-heading anchor:** `## Recommended model`

## Step 36 — sync-triage-proposals

**File:** `host/templates/claude/skills/sync-triage-proposals/SKILL.md`
**Pointer line (before):**
```
Follow the canonical `/sync-triage-proposals` command body verbatim — see [`commands/sync-triage-proposals.md`](../../commands/sync-triage-proposals.md). Summary:
```
**Pointer line (after):**
```
Follow the canonical `/sync-triage-proposals` command body verbatim — see [`commands/sync-triage-proposals.md`](../../commands/sync-triage-proposals.md).
```
**Next-heading anchor:** `## Recommended model`
**Note:** numbered steps 1–4 contain nested "Per file" / "Apply" sub-bullets — all part of the block, deleted with the list.

## Step 37 — trim-rules-file

**File:** `host/templates/claude/skills/trim-rules-file/SKILL.md`
**Pointer line (before):**
```
Follow the canonical `/trim-rules-file` command body verbatim — see [`commands/trim-rules-file.md`](../../commands/trim-rules-file.md). Summary:
```
**Pointer line (after):**
```
Follow the canonical `/trim-rules-file` command body verbatim — see [`commands/trim-rules-file.md`](../../commands/trim-rules-file.md).
```
**Next-heading anchor:** `## Recommended model`

## Step 38 — validate-artifact

**File:** `host/templates/claude/skills/validate-artifact/SKILL.md`
**Pointer line (before):**
```
Follow the canonical `/validate-artifact` command body verbatim — see [`commands/validate-artifact.md`](../../commands/validate-artifact.md). Summary:
```
**Pointer line (after):**
```
Follow the canonical `/validate-artifact` command body verbatim — see [`commands/validate-artifact.md`](../../commands/validate-artifact.md).
```
**Next-heading anchor:** `## Batch handoff (≥2 artifacts)`
**Note:** this is the second dogfooding file (with f1-propose-update in Phase 2). After the edit its Protocol is the pointer form, obeying the new rule the proposal codifies.

---

## Notes (Phase 3)

- 16 disjoint single-file EDITs; no intra-phase ordering dependency.
- File with a kept unique-prose sentence before ` Summary:`: f-all (step 24 — "The one-nesting-level dispatch pattern …"). For it, only the trailing ` Summary:` and the numbered list are removed.
- Files whose numbered block carries nested sub-bullets / block-quotes deleted with the list: pf1 (step 30), pf2 (step 31 — testability rubric block-quote), ps1 (step 33), sync-triage-proposals (step 36). In every case the deletion runs to the line before the named next `## ` heading, so all nested structure inside the Protocol's numbered block is removed.

---
Validated 2026-06-16 — 2 rounds (primary clean + adversarial validation-checker confirmed: zero issues)
