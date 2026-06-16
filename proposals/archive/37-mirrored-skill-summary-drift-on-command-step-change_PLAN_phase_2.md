# Implementation Plan — Phase 2: SKILL Protocol-summary migration (batch A, 17 of 33)

**Proposal:** proposals/37-mirrored-skill-summary-drift-on-command-step-change.md
**Index:** proposals/37-mirrored-skill-summary-drift-on-command-step-change_PLAN.md
**Created:** 2026-06-16
**Phase scope:** 17 EDIT operations — row 5 of the Proposed Changes table (manifest steps 6–22): the `e*` and `f*` command-backed skills.

**Read the index's "The shared migration contract" section first** — every step here is the same mechanical edit (strip the trailing ` Summary:` from the pointer line; delete the numbered "Summary:" block from the first blank line after the pointer through the line before the next `## ` heading; leave one blank line before that heading). Each step gives the three exact anchors. Only the `## Protocol` section is touched; all other sections, frontmatter, and the managed trailer are preserved.

Whole-plan / cross-phase verification (the two-part zero-paraphrase + pointer-preserved invariant) lives in the **index** file, run by the architect at `/f3` post-build — not here. Each step's per-step (builder-owned) verification confirms that one file.

**Per-step edit recipe (identical for every step):**
1. In the target file, find the **pointer line (before)** — the line ending in ` Summary:`. Remove the trailing ` Summary:` so it becomes the **pointer line (after)**.
2. Delete every line from the blank line immediately after that pointer line down to (but **not** including) the **next-heading anchor** line.
3. Ensure exactly one blank line sits between the pointer line (after) and the next-heading anchor.
**Per-step verification (identical for every step):**
- `awk '/^## Protocol/{f=1} f&&/^## /&&!/^## Protocol/{exit} f' {file} | grep -E '^[0-9]+[a-z]?\. '` returns no output (no numbered paraphrase remains in the Protocol section; the optional `[a-z]?` also catches sub-numbered steps such as e8's `6b.`).
- `grep -F '{pointer line (after)}' {file}` returns one match.
- `grep -c 'Summary:' {file}` returns 0.

---

## Step 6 — e1-start-story

**File:** `host/templates/claude/skills/e1-start-story/SKILL.md`
**Pointer line (before):**
```
Follow the canonical `/e1-start-story` command body verbatim — see [`commands/e1-start-story.md`](../../commands/e1-start-story.md). Summary:
```
**Pointer line (after):**
```
Follow the canonical `/e1-start-story` command body verbatim — see [`commands/e1-start-story.md`](../../commands/e1-start-story.md).
```
**Next-heading anchor:** `## Recommended model`

## Step 7 — e2-define-spec

**File:** `host/templates/claude/skills/e2-define-spec/SKILL.md`
**Pointer line (before):**
```
Follow the canonical `/e2-define-spec` command body verbatim — see [`commands/e2-define-spec.md`](../../commands/e2-define-spec.md). Resolve the story folder per `templates/SHAMT_RULES.template.md` §PO-tree resolution (tree-wide glob + legacy-flat fallback); `stories/{slug}/` below denotes that resolved folder. Summary:
```
**Pointer line (after):**
```
Follow the canonical `/e2-define-spec` command body verbatim — see [`commands/e2-define-spec.md`](../../commands/e2-define-spec.md). Resolve the story folder per `templates/SHAMT_RULES.template.md` §PO-tree resolution (tree-wide glob + legacy-flat fallback); `stories/{slug}/` below denotes that resolved folder.
```
**Next-heading anchor:** `## Recommended models`
**Note:** the "Resolve the story folder …" sentence is unique prose, **not** a step paraphrase — keep it; remove only the trailing ` Summary:` and the numbered list.

## Step 8 — e3-plan-implementation

**File:** `host/templates/claude/skills/e3-plan-implementation/SKILL.md`
**Pointer line (before):**
```
Follow the canonical `/e3-plan-implementation` command body verbatim — see [`commands/e3-plan-implementation.md`](../../commands/e3-plan-implementation.md). Summary:
```
**Pointer line (after):**
```
Follow the canonical `/e3-plan-implementation` command body verbatim — see [`commands/e3-plan-implementation.md`](../../commands/e3-plan-implementation.md).
```
**Next-heading anchor:** `## Recommended models`
**Note:** this Protocol's numbered block contains an interstitial "Resolve the story folder per …" paragraph between steps 2 and 3 — it is part of the step paraphrase block and is deleted with the list.

## Step 9 — e3b-write-testing-plan

**File:** `host/templates/claude/skills/e3b-write-testing-plan/SKILL.md`
**Pointer line (before):**
```
Follow the canonical `/e3b-write-testing-plan` command body verbatim — see [`commands/e3b-write-testing-plan.md`](../../commands/e3b-write-testing-plan.md). Summary:
```
**Pointer line (after):**
```
Follow the canonical `/e3b-write-testing-plan` command body verbatim — see [`commands/e3b-write-testing-plan.md`](../../commands/e3b-write-testing-plan.md).
```
**Next-heading anchor:** `## Recommended models`
**Note:** interstitial "Resolve the story folder per …" paragraph (between steps 2 and 3) is part of the block — deleted with the list.

## Step 10 — e4-execute-plan

**File:** `host/templates/claude/skills/e4-execute-plan/SKILL.md`
**Pointer line (before):**
```
Follow the canonical `/e4-execute-plan` command body verbatim — see [`commands/e4-execute-plan.md`](../../commands/e4-execute-plan.md). Summary:
```
**Pointer line (after):**
```
Follow the canonical `/e4-execute-plan` command body verbatim — see [`commands/e4-execute-plan.md`](../../commands/e4-execute-plan.md).
```
**Next-heading anchor:** `## Recommended models`

## Step 11 — e5-execute-tests

**File:** `host/templates/claude/skills/e5-execute-tests/SKILL.md`
**Pointer line (before):**
```
Follow the canonical `/e5-execute-tests` command body verbatim — see [`commands/e5-execute-tests.md`](../../commands/e5-execute-tests.md). Summary:
```
**Pointer line (after):**
```
Follow the canonical `/e5-execute-tests` command body verbatim — see [`commands/e5-execute-tests.md`](../../commands/e5-execute-tests.md).
```
**Next-heading anchor:** `## Recommended models`

## Step 12 — e5b-write-manual-testing-plan

**File:** `host/templates/claude/skills/e5b-write-manual-testing-plan/SKILL.md`
**Pointer line (before):**
```
Follow the canonical `/e5b-write-manual-testing-plan` command body verbatim — see [`commands/e5b-write-manual-testing-plan.md`](../../commands/e5b-write-manual-testing-plan.md). Resolve the story folder per `templates/SHAMT_RULES.template.md` §PO-tree resolution (tree-wide glob + legacy-flat fallback); `stories/{slug}/` below denotes that resolved folder. Summary:
```
**Pointer line (after):**
```
Follow the canonical `/e5b-write-manual-testing-plan` command body verbatim — see [`commands/e5b-write-manual-testing-plan.md`](../../commands/e5b-write-manual-testing-plan.md). Resolve the story folder per `templates/SHAMT_RULES.template.md` §PO-tree resolution (tree-wide glob + legacy-flat fallback); `stories/{slug}/` below denotes that resolved folder.
```
**Next-heading anchor:** `## Recommended models`
**Note:** keep the "Resolve the story folder …" sentence (unique prose); remove only ` Summary:` and the numbered list.

## Step 13 — e6-review-changes

**File:** `host/templates/claude/skills/e6-review-changes/SKILL.md`
**Pointer line (before):**
```
Follow the canonical `/e6-review-changes` command body verbatim — see [`commands/e6-review-changes.md`](../../commands/e6-review-changes.md). Summary:
```
**Pointer line (after):**
```
Follow the canonical `/e6-review-changes` command body verbatim — see [`commands/e6-review-changes.md`](../../commands/e6-review-changes.md).
```
**Next-heading anchor:** `## Recommended models`
**Note:** this Protocol's paraphrase block is structured under two `### ` sub-headings — `### Story mode` (numbered steps 1–7) and `### Formal mode` (numbered steps 1–3). **Both sub-headings and all their numbered steps are part of the step paraphrase block and are deleted** — the deletion runs from the blank line after the pointer through the line before `## Recommended models`. After the edit the Protocol section contains only the `## Protocol` heading + the pointer line (after).

## Step 14 — e7-resolve-feedback

**File:** `host/templates/claude/skills/e7-resolve-feedback/SKILL.md`
**Pointer line (before):**
```
Follow the canonical `/e7-resolve-feedback` command body verbatim — see [`commands/e7-resolve-feedback.md`](../../commands/e7-resolve-feedback.md). Resolve the story folder per `templates/SHAMT_RULES.template.md` §PO-tree resolution (tree-wide glob + legacy-flat fallback). Summary:
```
**Pointer line (after):**
```
Follow the canonical `/e7-resolve-feedback` command body verbatim — see [`commands/e7-resolve-feedback.md`](../../commands/e7-resolve-feedback.md). Resolve the story folder per `templates/SHAMT_RULES.template.md` §PO-tree resolution (tree-wide glob + legacy-flat fallback).
```
**Next-heading anchor:** `## Recommended models`
**Note:** keep the "Resolve the story folder …" sentence (unique prose); remove only ` Summary:` and the numbered list.

## Step 15 — e8-finalize-story

**File:** `host/templates/claude/skills/e8-finalize-story/SKILL.md`
**Pointer line (before):**
```
Follow the canonical `/e8-finalize-story` command body verbatim — see [`commands/e8-finalize-story.md`](../../commands/e8-finalize-story.md). Summary:
```
**Pointer line (after):**
```
Follow the canonical `/e8-finalize-story` command body verbatim — see [`commands/e8-finalize-story.md`](../../commands/e8-finalize-story.md).
```
**Next-heading anchor:** `## Recommended model`
**Note:** this Protocol's numbered block includes a `6b.` step in addition to `1.`–`7.` — all are deleted with the list.

## Step 16 — e-all

**File:** `host/templates/claude/skills/e-all/SKILL.md`
**Pointer line (before):**
```
Follow the canonical `/e-all` command body verbatim — see [`commands/e-all.md`](../../commands/e-all.md). The one-nesting-level dispatch pattern it reproduces lives in [`reference/batch_validation_handoff.md`](../../../../../reference/batch_validation_handoff.md). Summary:
```
**Pointer line (after):**
```
Follow the canonical `/e-all` command body verbatim — see [`commands/e-all.md`](../../commands/e-all.md). The one-nesting-level dispatch pattern it reproduces lives in [`reference/batch_validation_handoff.md`](../../../../../reference/batch_validation_handoff.md).
```
**Next-heading anchor:** `## Recommended models`
**Note (richer prose — proposal-flagged):** keep the "The one-nesting-level dispatch pattern …" sentence (unique guidance, not a step paraphrase). Only the trailing ` Summary:` and the numbered steps 1–5 are deleted; no other `## Protocol` prose exists to keep beyond that sentence.

## Step 17 — f0-draft-proposal

**File:** `host/templates/claude/skills/f0-draft-proposal/SKILL.md`
**Pointer line (before):**
```
Follow the canonical `/f0-draft-proposal` command body verbatim — see [`commands/f0-draft-proposal.md`](../../commands/f0-draft-proposal.md). Summary:
```
**Pointer line (after):**
```
Follow the canonical `/f0-draft-proposal` command body verbatim — see [`commands/f0-draft-proposal.md`](../../commands/f0-draft-proposal.md).
```
**Next-heading anchor:** `## Recommended model`

## Step 18 — f1-propose-update

**File:** `host/templates/claude/skills/f1-propose-update/SKILL.md`
**Pointer line (before):**
```
Follow the canonical `/f1-propose-update` command body verbatim — see [`commands/f1-propose-update.md`](../../commands/f1-propose-update.md). Summary:
```
**Pointer line (after):**
```
Follow the canonical `/f1-propose-update` command body verbatim — see [`commands/f1-propose-update.md`](../../commands/f1-propose-update.md).
```
**Next-heading anchor:** `## Recommended model`
**Note:** this Protocol's block ends with an `> **In-place amendment** …` block-quote paragraph **after** numbered step 9 and before `## Recommended model`. That block-quote is part of the step-paraphrase block (it restates command-body content) and is deleted along with the numbered list — the deletion runs through the line before `## Recommended model`. (Self-application: this is one of the two dogfooding files; after the edit its Protocol is the pointer form, obeying the new rule.)

## Step 19 — f2-plan-update-implementation

**File:** `host/templates/claude/skills/f2-plan-update-implementation/SKILL.md`
**Pointer line (before):**
```
Follow the canonical `/f2-plan-update-implementation` command body verbatim — see [`commands/f2-plan-update-implementation.md`](../../commands/f2-plan-update-implementation.md). Summary:
```
**Pointer line (after):**
```
Follow the canonical `/f2-plan-update-implementation` command body verbatim — see [`commands/f2-plan-update-implementation.md`](../../commands/f2-plan-update-implementation.md).
```
**Next-heading anchor:** `## Recommended models`

## Step 20 — f3-implement-update

**File:** `host/templates/claude/skills/f3-implement-update/SKILL.md`
**Pointer line (before):**
```
Follow the canonical `/f3-implement-update` command body verbatim — see [`commands/f3-implement-update.md`](../../commands/f3-implement-update.md). Summary:
```
**Pointer line (after):**
```
Follow the canonical `/f3-implement-update` command body verbatim — see [`commands/f3-implement-update.md`](../../commands/f3-implement-update.md).
```
**Next-heading anchor:** `## Recommended models`

## Step 21 — f4-regen-framework

**File:** `host/templates/claude/skills/f4-regen-framework/SKILL.md`
**Pointer line (before):**
```
Follow the canonical `/f4-regen-framework` command body verbatim — see [`commands/f4-regen-framework.md`](../../commands/f4-regen-framework.md). Summary:
```
**Pointer line (after):**
```
Follow the canonical `/f4-regen-framework` command body verbatim — see [`commands/f4-regen-framework.md`](../../commands/f4-regen-framework.md).
```
**Next-heading anchor:** `## Recommended model`

## Step 22 — f5-audit-framework

**File:** `host/templates/claude/skills/f5-audit-framework/SKILL.md`
**Pointer line (before):**
```
Follow the canonical `/f5-audit-framework` command body verbatim — see [`commands/f5-audit-framework.md`](../../commands/f5-audit-framework.md). Full D1–D12 definitions, the fix-track rubric with worked examples, and the known-exceptions list live in [`reference/audit_dimensions.md`](../../../../../reference/audit_dimensions.md). Summary:
```
**Pointer line (after):**
```
Follow the canonical `/f5-audit-framework` command body verbatim — see [`commands/f5-audit-framework.md`](../../commands/f5-audit-framework.md). Full D1–D12 definitions, the fix-track rubric with worked examples, and the known-exceptions list live in [`reference/audit_dimensions.md`](../../../../../reference/audit_dimensions.md).
```
**Next-heading anchor:** `## Recommended models`
**Note:** keep the "Full D1–D12 definitions …" sentence (unique prose). The numbered block here starts at `0.` (Step 0) and runs through `15.` — all deleted with the list.

---

## Notes (Phase 2)

- 17 disjoint single-file EDITs; no intra-phase ordering dependency.
- Files with a kept unique-prose sentence before ` Summary:`: e2 (step 7), e5b (step 12), e7 (step 14), e-all (step 16), f5-audit-framework (step 22). For all of these, **only** the trailing ` Summary:` token plus the numbered list are removed — the preceding sentence stays verbatim.
- Files whose paraphrase block carries non-numbered structure deleted with the list: e6 (step 13 — `### Story mode` / `### Formal mode` sub-headings), f1 (step 18 — trailing `> In-place amendment` block-quote), e8 (step 15 — a `6b.` step), e3/e3b (steps 8/9 — interstitial "Resolve the story folder" paragraph), f5 (step 22 — `0.` step).

---
Validated 2026-06-16 — 3 rounds (primary clean + adversarial validation-checker confirmed: zero issues)
