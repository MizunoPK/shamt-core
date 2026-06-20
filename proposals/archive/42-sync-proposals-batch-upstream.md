# Proposal: sync-proposals-batch-upstream

**Created:** 2026-06-19
**Status:** Implemented
**Number:** 42
**Proposed by:**
**Project context:**

## Problem

The child-side upstream-submission command is `/sync-submit-proposal {slug}` (canonical body `host/templates/claude/commands/sync-submit-proposal.md`, skill `host/templates/claude/skills/sync-submit-proposal/SKILL.md`). It has two shape limitations the user wants reworked:

1. **One-at-a-time.** It takes a single `{slug}` and prepares exactly one proposal per invocation. A child that has accumulated several local proposals must run the command N times, once per slug. The desired workflow is a single **batch** run that ships **every active child-local proposal** upstream at once.

2. **Validation-gated intake only.** Its Prerequisites hard-require a Phase 2 validation footer (`host/templates/claude/commands/sync-submit-proposal.md` Step 2 / Prerequisites) and refuse to submit anything un-validated. But in practice the child is primarily an *idea-capture* surface: the expected upstream payload is an **f0 draft** (`Status: Draft (f0 — audit capture, unrefined)`, written by `/f0-draft-proposal`), with master doing the f1 fleshing + validation. Validated proposals should *also* be accepted — and so should an in-progress plain-`Draft` — so the batch clears the whole active set; the command must drop the validation-footer gate (see Resolved Q2).

Two further mechanics need defining for the batch/f0 world:

- **Numeric-ID stripping.** Child-side proposals are unnumbered by convention (`shamt-core/CLAUDE.md` §Conventions — numbering is master-only, assigned at `/sync-triage-proposals` promote). A validated proposal that nonetheless carries a numeric identifier (a leading `{NN}-` filename prefix and/or a `**Number:**` header — e.g. one that originated on master, or was hand-numbered) must be **stripped of that number** before going upstream, so master assigns its own at triage and no stale number travels with it.

- **Clearing the child after submission.** The user wants submitted proposals removed from the child's active working set in the same run, so the child does not re-ship the same ideas next time.

The command should be **renamed `/sync-proposals`** (slugless / batch) to reflect the new shape.

This is a command-surface rework, not an incident — there is no bug to root-cause. The change set is broad because the old command name appears in many cross-references across the framework-update and sync command bodies, the README, the two install scripts, and the audit reference doc.

## Proposed Changes

| # | Canonical path | Op | Change |
|---|----------------|----|--------|
| 1 | `host/templates/claude/commands/sync-proposals.md` | CREATE | New batch command body (rewrite of the old one): slugless `/sync-proposals`; iterate **every active** top-level `.shamt-core/proposals/*.md` regardless of status (f0 / validated / plain-`Draft` — no validation-footer gate; skip `_template.md` + the `submitted/ archive/ already-merged/ rejected/ deferred/` subfolders); per proposal compute master target `proposals/incoming/{project_name}-{slug}.md` (slug = name with any leading `{NN}-` stripped), strip the `**Number:**` header from the emitted content, print one copy-paste block per proposal; then move each to `.shamt-core/proposals/submitted/{slug}.md` (unnumbered name; per Resolved Q1). Master-side guard (presence of `proposals/incoming/`) unchanged. |
| 2 | `host/templates/claude/commands/sync-submit-proposal.md` | DELETE | Replaced by sync-proposals.md (paired with #1 = a MOVE/rename). |
| 3 | `host/templates/claude/skills/sync-proposals/SKILL.md` | CREATE | Skill wrapper for `/sync-proposals`; `## Protocol` stays the pointer form ("Follow the canonical `/sync-proposals` command body verbatim — see `commands/sync-proposals.md`"); frontmatter description rewritten for the batch shape. |
| 4 | `host/templates/claude/skills/sync-submit-proposal/SKILL.md` | DELETE | Replaced by #3 (paired = MOVE/rename). |
| 5 | `host/templates/claude/commands/f0-draft-proposal.md` | EDIT | Exit text (Step 3) + Notes: `/sync-submit-proposal {final-slug}` → `/sync-proposals` (slugless, batch). |
| 6 | `host/templates/claude/commands/f1-propose-update.md` | EDIT | Notes line: "before `/sync-submit-proposal` ships them up" → `/sync-proposals`. |
| 7 | `host/templates/claude/commands/f5-audit-framework.md` | EDIT | Purpose + Step-0 redirect + Notes: child redirect chain `… → /sync-submit-proposal` → `… → /sync-proposals`. |
| 8 | `host/templates/claude/commands/f-all.md` | EDIT | Child-redirect block: `/sync-submit-proposal {slug}` → `/sync-proposals`. |
| 9 | `host/templates/claude/commands/sync-import-shamt.md` | EDIT | "No reverse direction" note: reverse is `/sync-proposals` (batch, manual copy) — drop the per-proposal `{slug}` framing. |
| 10 | `host/templates/claude/commands/sync-triage-proposals.md` | EDIT | Child-detection halt message, the `{project_name}-{slug}.md` naming-rule cross-ref, and the rejection-cleanup note: `/sync-submit-proposal` → `/sync-proposals`. |
| 11 | `host/templates/claude/commands/trim-rules-file.md` | EDIT | Child-redirect chain: `… → /sync-submit-proposal` → `… → /sync-proposals`. |
| 12 | `host/templates/claude/skills/f5-audit-framework/SKILL.md` | EDIT | Frontmatter description redirect chain mention: `/sync-submit-proposal` → `/sync-proposals`. |
| 13 | `host/templates/claude/skills/f-all/SKILL.md` | EDIT | Frontmatter description (if it names the command) → `/sync-proposals`. |
| 14 | `host/templates/claude/skills/sync-import-shamt/SKILL.md` | EDIT | Frontmatter description reverse-direction mention → `/sync-proposals`. |
| 15 | `import-shamt.sh` | EDIT | Header comment block (lines ~26–30) referencing "submitted via /sync-submit-proposal": update to `/sync-proposals`; reconcile the already-merged auto-move source scan with Resolved Q1's disposition (keep scanning `submitted/` if move-to-submitted is chosen). |
| 16 | `init-shamt.sh` | EDIT | `project_name` prompt help text: "Project name (used by /sync-submit-proposal …)" → `/sync-proposals`. |
| 17 | `README.md` | EDIT | Command table row, sync-flow table (Child → master), `project_name` config row, the master-`proposals/` discrimination paragraph, and the f5 row redirect: `/sync-submit-proposal` → `/sync-proposals`; reflect batch + f0-accepted intake. |
| 18 | `reference/audit_dimensions.md` | EDIT | Child-redirect chain (`… → /sync-submit-proposal`) → `/sync-proposals`. |

**Phase 3 required — file count 18 > 10. Run `/f2-plan-update-implementation 42-sync-proposals-batch-upstream` before `/f3-implement-update`.**

> Note: rows #2+#1 and #4+#3 are MOVE pairs (rename of the command + its skill). The `.claude/` generated mirror is **never** edited directly — `/f4-regen-framework` propagates the rename and deletes the stale generated `sync-submit-proposal` command/skill.

## Risks

- **Regression:** the rename breaks any muscle-memory / doc reference to `/sync-submit-proposal`. Mitigated by the exhaustive cross-reference sweep in Proposed Changes (#5–#18) — every canonical mention is updated in the same proposal.
- **Drift (canonical vs. generated `.claude/`):** the old generated `sync-submit-proposal` command + skill must be *removed* from `.claude/`, not just shadowed. `/f4-regen-framework --check` must confirm the stale generated files are gone (regen deletes managed files with no canonical source).
- **Child-project compatibility on next `import-shamt`:** a child mid-flight may have a `proposals/submitted/{slug}.md` from the old command. The new disposition (Resolved Q1) must not orphan those. The import-shamt already-merged auto-move already scans `submitted/`, so existing submitted copies still resolve on the next sync regardless.
- **Data-loss risk (Q1-dependent):** a true hard-delete removes the child's only copy before the user has confirmed the upstream paste landed. Move-to-`submitted/` preserves recovery and the already-merged tracking signal. See Resolved Q1.
- **Open-questions debt:** none at exit (dialog resolved below).

## Rollback Plan

Revert the squash commit, run `/f4-regen-framework` to restore the generated `.claude/sync-submit-proposal` command + skill and remove the new `sync-proposals` ones. No child-side action strictly required (children re-derive on next `/sync-import-shamt`); a child that already adopted `/sync-proposals` would revert to `/sync-submit-proposal` on the next import. Tell: anyone with a child install mid-submission.

## Validation Considerations

- **Easy-to-forget paired edits:** the MOVE pairs (#1/#2, #3/#4) — confirm both the CREATE and the DELETE land, and that the new SKILL `## Protocol` is the pointer form (not a paraphrase of the command steps; D2 rule, `reference/audit_dimensions.md`). Confirm the skill frontmatter descriptions (#3, #12, #13, #14) name the new command.
- **Reference completeness:** the validator should re-run `grep -rn 'sync-submit-proposal'` over canonical sources (`host/templates/`, `reference/`, `templates/`, root docs, `*.sh`) and confirm **zero** live references remain outside `proposals/archive/` (historical proposals are frozen and are correctly left untouched).
- **Surfaces affected:** commands, skills, README, install scripts (`import-shamt.sh`, `init-shamt.sh`), one reference doc. No rules-file (`templates/SHAMT_RULES.template.md`) change — confirm it never named the command (grep shows it does not).
- **Propagation:** `/f4-regen-framework` then `--check` for zero drift, including deletion of the stale generated `sync-submit-proposal` files.
- **Behavioral-contract rows (#1, #15):** validate that the batch-iteration + accept-f0 + strip-number + clear-after-submit semantics in the new body are internally consistent with the import-shamt already-merged auto-move (which keys on a child-side copy existing).

## Open Questions

_None — all resolved below._

## Resolved Questions

~~Q2: eligible intake states — only f0 + validated, or every active proposal?~~ → A: **Every active top-level proposal**, regardless of status (f0 draft, validated, or in-progress plain-`Draft`). The command does not classify or gate on state — it clears out the whole active set. The "expected f0, validated also accepted" framing describes the *common* payloads, not an allowlist; a still-being-fleshed plain-`Draft` is shipped too and master triages whatever arrives. Numeric-ID stripping still applies to any proposal that carries one.

~~Q1: disposition of a submitted proposal on the child — hard-delete vs. move-to-`submitted/`?~~ → A: **Move to `.shamt-core/proposals/submitted/{slug}.md`** (the existing behavior, now applied per-proposal across the batch). "Deleted from the child" means removed from the *active* top-level set, not a hard `rm`: the move preserves recovery and keeps the import-shamt `submitted/ → already-merged/` "landed upstream" auto-move working. The numbered name is normalized to the unnumbered `{slug}.md` on the way into `submitted/` (consistent with the strip-the-number rule).

---
Validated 2026-06-19 — 1 round, 1 adversarial sub-agent confirmed
