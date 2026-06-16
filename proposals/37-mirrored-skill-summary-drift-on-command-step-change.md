# Proposal: mirrored-skill-summary-drift-on-command-step-change

**Created:** 2026-06-16
**Status:** Draft
**Number:** 37
**Proposed by:**
**Project context:**

---

## Problem

During the `/f-all 31` run (landing proposal `31-whole-plan-verification-ownership`), the Phase-6 audit caught a stale mirror that the proposal's own change list had missed: proposal 31 added a new **Step 3 "Post-build verification"** to `host/templates/claude/commands/f3-implement-update.md` and renumbered the later steps (old 3→4, 4→5), but its 5-row Proposed Changes table never listed the mirrored `host/templates/claude/skills/f3-implement-update/SKILL.md`, whose `## Protocol` "Summary:" section **hand-paraphrases the command's numbered steps**. The SKILL summary therefore jumped from "Apply edits" straight to "Diff coverage gate", silently omitting the new post-build verification step — a canonical file left stale against the command it mirrors. The audit (`/f5-audit-framework` D2) auto-fixed it, but only after the fact.

**Root cause (confirmed by an independent adversarial diagnosis — Opus `root-cause-diagnoser` + Haiku zero-bias confirmation): the *Command ↔ Skill Protocol-Summary mirror* is a real but *uncodified* canonical contract.** Every `host/templates/claude/skills/{name}/SKILL.md` carries a hand-written `## Protocol` numbered-step "Summary:" that mirrors the matching `host/templates/claude/commands/{name}.md` numbered steps, and `scripts/regenerate-framework.sh` copies `SKILL.md` **verbatim** (`skills` is a managed subtree, line 71; `do_regen` copies each relpath with no derivation) — it never re-derives the summary from the command body. So a command-body edit that **adds / removes / renumbers a numbered step** requires a **paired canonical edit** to that command's mirrored `SKILL.md` Protocol Summary. This is a *class* (all ~34 SKILL.md files share the pattern), not an `/f3`-specific quirk.

Because the contract is named nowhere authoritative, the authoring/validation prompts only gesture at it:

- **`host/templates/claude/commands/f1-propose-update.md` Step 3 item 3** asks "For every command edit, ask: does the skill need to change?" — one soft clause in a four-clause cross-check sentence. An author easily answers "no, regen handles the skill", conflating the *generated* `.claude/` skill (which regen does propagate) with the *canonical* `SKILL.md` Protocol Summary (which regen only copies, never re-derives).
- **`proposals/_template.md` Validation Considerations** gives the same weak example ("the command changes but the mirrored skill does not").
- **`host/templates/claude/commands/validate-artifact.md` Step 2** validates a framework-update proposal against "general 5 dimensions + propagation/rollback" but has **no** proposal-specific check requiring a paired SKILL row, so a missing-mirror row is structurally invisible at validation time.
- **`/f3-implement-update`'s diff-coverage gate** is per-row against the Proposed Changes table **by explicit design** (it does not sweep the working tree for un-listed canonical files — that design was landed deliberately so ad-hoc tree state is accepted). A SKILL mirror that should have been edited but isn't in the table cannot surface there.
- **`/f5-audit-framework` D2** (and `reference/audit_dimensions.md`) already names the contract — "step count and order match … the summary is faithful" — so **detection exists post-hoc and worked here.** The gap is upstream **prevention**, not detection.

The fix has two layers (scope confirmed in the dialog: take on the structural change here, not as a follow-up). **Structurally** — eliminate the drift class at its source by **removing the hand-written step paraphrase from every SKILL.md**: each `## Protocol` section keeps only the canonical "follow the command body verbatim — see `commands/{name}.md`" pointer the files already carry, and drops the numbered "Summary:" list (the audit's D2 already blesses this exact pointer form). With nothing duplicated, nothing can drift; no regen-script change is needed (regen keeps copying `SKILL.md` verbatim). **As a forward guard** — flip the now-uncodified contract into an explicit rule: a SKILL `## Protocol` **is** the command-body pointer and **must not** re-introduce a step paraphrase. Name that rule in `reference/audit_dimensions.md` (where D2's language lives, so re-introduction is caught post-hoc) and reference it from authoring (`/f1`), validation (`/validate-artifact`), and the proposal template — the three sites that today only softly gesture at the mirror. The `/f3` diff-coverage gate and the regen script are deliberately **not** touched (the diagnosis confirmed each is correct as-is).

---

## Proposed Changes

> **Phase 3 required — file count 37 > 10. Run /f2-plan-update-implementation 37-mirrored-skill-summary-drift-on-command-step-change before /f3-implement-update.** The change set is one large mechanical migration (33 SKILL.md edits, row 5) plus four small forward-guard edits (rows 1–4). The migration's identical-edit rows are enumerated by the Phase 3 plan; row 5 names the full set + the exact mechanical edit + the whole-plan acceptance invariant.

| # | Canonical path | Operation | One-line change description |
|---|----------------|-----------|------------------------------|
| 1 | `shamt-core/reference/audit_dimensions.md` | EDIT | At the D2 entry, state the **Command → Skill Protocol pointer rule**: a `host/templates/claude/skills/{name}/SKILL.md` `## Protocol` section **is** the canonical "follow the command body verbatim — see `commands/{name}.md`" pointer and **must not** re-introduce a numbered step paraphrase (which regen copies verbatim and cannot keep in sync). D2 flags any SKILL `## Protocol` that re-introduces a step-by-step list as a finding. Replaces the old "summary is faithful" allowance with "pointer form is required." No new dimension. |
| 2 | `shamt-core/host/templates/claude/commands/f1-propose-update.md` | EDIT | Step 3 item 3 (the cross-check): replace the soft conjoined "does the skill need to change?" with the explicit rule — when a proposal CREATEs or EDITs a `skills/{name}/SKILL.md`, its `## Protocol` is the command-body pointer; **never** paraphrase the command's numbered steps there (the paraphrase is the drift class #37 removes). Reference the pointer rule in `reference/audit_dimensions.md`. |
| 3 | `shamt-core/host/templates/claude/commands/validate-artifact.md` | EDIT | In Step 2's **Framework-update proposal** row (proposal-specific checks), add: flag any Proposed Changes row that would (re-)introduce a numbered step paraphrase into a `skills/{name}/SKILL.md` `## Protocol`; SKILL Protocols must stay the command-body pointer form. Reference the pointer rule. |
| 4 | `shamt-core/proposals/_template.md` | EDIT | Validation Considerations §Change-list completeness (line ~151): replace the generic "the command changes but the mirrored skill does not" example with a pointer to the Command → Skill Protocol pointer rule (SKILL `## Protocol` is a pointer, never a step paraphrase — so a command-step edit needs no paired SKILL summary edit). |
| 5 | `shamt-core/host/templates/claude/skills/*/SKILL.md` (**all 33** command-backed skills: `e1-start-story`, `e2-define-spec`, `e3-plan-implementation`, `e3b-write-testing-plan`, `e4-execute-plan`, `e5-execute-tests`, `e5b-write-manual-testing-plan`, `e6-review-changes`, `e7-resolve-feedback`, `e8-finalize-story`, `e-all`, `f0-draft-proposal`, `f1-propose-update`, `f2-plan-update-implementation`, `f3-implement-update`, `f4-regen-framework`, `f5-audit-framework`, `f6-archive-proposal`, `f-all`, `pe0-draft`, `pe1-define`, `pe2-decompose`, `pe3-finalize`, `pf0-draft`, `pf1-define`, `pf2-decompose`, `ps0-draft`, `ps1-define`, `sync-import-shamt`, `sync-submit-proposal`, `sync-triage-proposals`, `trim-rules-file`, `validate-artifact`) | EDIT (×33) | In each file's `## Protocol` section, **remove the numbered "Summary:" step-paraphrase list**, keeping the canonical "Follow the canonical `/{name}` command body verbatim — see [`commands/{name}.md`](…)." pointer line. Preserve all other sections untouched (`## Overview`, `## Recommended model(s)`, `## Exit criteria`, `## Hard rule`, frontmatter, the managed-file trailer). Where a `## Protocol` carries prose beyond the pointer + the numbered summary, keep that prose; only the numbered step list is deleted. |

**Path discipline:** all canonical (`reference/`, `host/templates/claude/commands/`, `host/templates/claude/skills/`, `proposals/`). No `.claude/` paths — regen (Phase 5) propagates the 33 SKILL edits + the 2 command-body edits into `.claude/`.

**Scope boundary (non-scope):** only the `## Protocol` **numbered step paraphrase** is removed. The other short SKILL sections that also lightly restate command content (`## Recommended model(s)`, `## Exit criteria`) are **out of scope** — they do not track command step numbering and were not the drift incident; tightening them (if ever wanted) is a separate proposal.

**Self-application (dogfooding):** `/f1` and `/validate-artifact` (rows 2–3) are themselves command-backed, and their SKILL files are in the row-5 migration set — so under the new pointer rule there is no SKILL step-summary to keep faithful for them either. The mirror-drift question dissolves for the whole framework, this proposal included.

---

## Risks

- **Regression risk** — low for behavior, but **breadth is the real risk**: row 5 touches 33 files mechanically. The danger is an *inconsistent* migration — a SKILL left with a partial paraphrase, or a pointer line accidentally deleted. Mitigated by the whole-plan acceptance invariant (Validation Considerations) and the Phase 3 plan enumerating each file. Rows 1–4 are clarifying guidance prose; none changes a control-flow contract, a report string, or a numbered-step structure.
- **Content-loss risk** — deleting the numbered summary removes the standalone quick-reference some readers used (accepted in the dialog: the command body is the source of truth and the pointer reaches it). The migration must **only** delete the numbered step list — never any `## Protocol` prose that is not a pure command-body restatement, and never another section. A few SKILLs (`f-all`, `e-all`) carry richer `## Protocol` prose; the per-file plan must confirm what is deleted is the step summary, not unique guidance.
- **Drift risk** — row 5 (33 skills) + rows 2–3 (two command bodies) regenerate `.claude/` copies via `/f4-regen-framework`; skipping regen leaves a large generated/canonical mismatch. Standard regen covers it; `--check` zero-drift confirms. (Row 1 reference doc and row 4 proposal template are not host-templated — no `.claude/` output.)
- **Self-consistency** — `/f1` and `/validate-artifact` are in the migration set, so the proposal obeys its own new pointer rule; there is no residual mirror to keep faithful anywhere. Verify no row re-introduces a paraphrase.
- **Child-project compatibility** — children pick up the 33 regenerated skills + the two command bodies + the template on next `import-shamt`; no artifact migration (this changes generated-doc content, not any on-disk work-artifact shape).
- **Open-questions debt** — both load-bearing decisions (scope: structural here; mechanism: A — drop the paraphrase) are resolved in the dialog before drafting completes.

---

## Rollback Plan

1. `git revert <commit-sha>` on the canonical edit commit (reverts all 37 file edits atomically — the proposal lands as one squash commit).
2. Run `/f4-regen-framework` to propagate the revert into `.claude/` (the 33 skills + the two command bodies).
3. Child-side: none required for the revert itself (re-sync picks up the reverted bodies on next `import-shamt`).
4. Communication: standard archive note.

---

## Validation Considerations

- **Problem clarity** — the subtle point is *prevention vs. detection*: the audit (D2) already **detects** this post-hoc and worked on `/f-all 31`; #37 closes the gap at its source (remove the paraphrase) + flips D2 to require the pointer form so re-introduction is still caught. Verify the Problem keeps that distinction and does not imply the audit is broken.
- **Change-list completeness** — confirm row 5's set is exactly the **33** command-backed skills (a `skills/{name}/` with a matching `commands/{name}.md`); confirm no command-backed SKILL is omitted and no non-command skill is wrongly included. Confirm rows 1–4 are mutually reinforcing (the reference names the pointer rule; `/f1`, `/validate-artifact`, and the template each reference it).
- **Whole-plan acceptance invariant (load-bearing — this is exactly the architect-owned cross-phase verification #31 just formalized):** after the migration, `grep -rnE '^[0-9]+\. ' host/templates/claude/skills/*/SKILL.md` returns **zero** matches under each `## Protocol` (no SKILL retains a numbered step paraphrase), **and** every migrated SKILL still contains its "Follow the canonical `/{name}` command body verbatim — see [`commands/{name}.md`]" pointer line. Both halves must hold across all 33 files. The Phase 3 plan homes this in the index's `## Verification (post-execution, whole plan)` section, run by the architect post-build.
- **Risk coverage** — confirm the breadth/partial-migration and content-loss risks are addressed (the invariant above covers the first; the per-file "delete only the step summary" rule covers the second).
- **Rollback feasibility** — trivial; all EDITs (no DELETE of a whole file, no MOVE), fully reverted by `git revert` + regen.
- **Affected surfaces** — one reference doc (`audit_dimensions.md`), two command bodies (`/f1`, `/validate-artifact`) + their regenerated skills, the proposal template, and **all 33** SKILL files + their regenerated `.claude/` copies. Cross-doc consistency: the pointer-rule wording in `reference/audit_dimensions.md` reads parallel to the D2 language it replaces; the `/f1` + `/validate-artifact` references point at it by name.
- **Propagation plan** — requires `/f4-regen-framework` (33 skills + two command bodies) + child `import-shamt`. **Phase 3 required (37 file ops > 10).**

---

## Open Questions

_None — all resolved (see below)._

---

## Resolved Questions

- ~~OQ1 — Scope: prevention-codification now, or also pursue the structural regen-derive alternative?~~ → A: **Expand — take on the structural fix in this proposal** (not a separate follow-up). So #37 keeps the four forward-guard edits **and** adds the structural migration that makes the mirror un-driftable at the source. This pushes the proposal past 10 file ops, so **Phase 3 (`/f2-plan-update-implementation`) is required**.
- ~~OQ2 — Which structural mechanism makes the mirror un-driftable?~~ → A: **Mechanism A — drop the paraphrase (pointer form).** Remove the numbered `## Protocol` "Summary:" step list from all 33 command-backed SKILL files, keeping the canonical "follow the command body verbatim — see `commands/{name}.md`" pointer. Chosen over Mechanism B (regen *derives* the summary from a machine-readable block in each command body) because A needs **no** regen-script change, is the lowest-risk mechanical sweep, and the audit's D2 already blesses the pointer form — whereas the summaries are editorial condensations that don't track command step headings 1:1, so B's header-extraction would degrade them and B costs ~66 edits + a script extension. Accepted trade-off: SKILL.md loses its standalone quick-reference summary (the command body remains the source of truth, reached via the pointer).

---
