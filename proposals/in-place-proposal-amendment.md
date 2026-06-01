# Proposal: in-place-proposal-amendment

**Created:** 2026-05-30
**Status:** Draft
**Proposed by:**
**Project context:**

---

## Problem

When a downstream phase of the framework-update flow discovers that a proposal's **Proposed Changes** table is missing a row — a paired file that was overlooked, a reference site found only while planning or implementing — the canonical policy is to **send the user all the way back to `/propose-update`** to "expand the change list." Five instruction sites in the two framework-update command bodies — plus the one mirrored skill line — enforce this:

- `host/templates/claude/commands/plan-update-implementation.md` Step 1 (line ~60): *"These pairs must already appear as rows in the table — if they don't, halt and direct the user back to `/propose-update` to expand the change list."*
- `host/templates/claude/commands/plan-update-implementation.md` Step 3 cross-check (line ~141): *"Plan steps that don't trace back are scope creep — halt, surface to the user, decide whether to remove the step or extend the proposal via re-baseline."*
- `host/templates/claude/commands/plan-update-implementation.md` Notes (line ~158): *"halt and either resolve the decision now or return to `/propose-update` to expand the proposal."*
- `host/templates/claude/commands/implement-update.md` Step 3 (line ~107): scope mismatch → *"extend the proposal via re-baseline + re-validation"*.
- `host/templates/claude/commands/implement-update.md` Step 1 (line ~59): the `.claude/` bad-path halt → *"Direct the user back to `/propose-update` to correct the change list."* — a **path-correction** variant (the row exists but points at a generated file), not a missing-row case; it shares the same "don't bounce to a full `/propose-update` re-run" friction, so it is brought into the in-place path as *fix-the-row + re-validate*.

The mirrored `host/templates/claude/skills/plan-update-implementation/SKILL.md` (line ~33) repeats the first. So the policy lives at **five instruction sites in two command bodies** (`plan-update-implementation.md` ×3, `implement-update.md` ×2 — four missing-row sites plus the one `.claude/` path-correction site at ~59) plus **one skill mirror** — fixed by rows 3, 5, and 4 below respectively. Rows 1, 2, and 6 are additive: they introduce the canonical "in-place amendment" definition, its skill mirror, and a one-line template pointer.

These are the **scope-increase / missing-row** sites — distinct from the **Re-baseline Protocol** case (a row that is *wrong*), which stays as-is. The two re-baseline sites in `implement-update.md` — Step 2 line ~70 ("if the proposal itself was wrong") and the Notes "Re-baseline protocol" bullet line ~127 ("if a Proposed Changes row turns out wrong mid-implementation") — are intentionally **left unchanged**; row 5 only adds a one-line cross-reference at ~127 so the Notes acknowledge amendment (missing row) and re-baseline (wrong row) as two distinct remedies and do not read as if re-baseline is the only path.

**The mechanism (footer integrity).** In-place amendment must keep the validation footer honest. The canonical procedure — defined once in `propose-update.md` (row 1) and referenced by the downstream sites — is: **strip the prior `Validated …` footer → append the row(s) → re-run `/validate-artifact`** (which re-earns the footer over the whole, now-larger change list). This reuses the footer-stripping rule `propose-update.md` already applies on its own extend re-entry (Slug resolution: *"if a prior Phase 2 validation footer is present, strip it before continuing"*). `/validate-artifact` Step 8 only *appends* a footer; it does not remove a stale one, so the explicit strip step is load-bearing and must appear in every site that authors the amendment path.

Re-invoking `/propose-update {slug}` for a one-row addition is heavyweight: even though its re-entry path skips template-seeding (`propose-update.md` Slug resolution: *"If extending, skip the template-seed step … and resume drafting at Step 2"*), it still forces a full command round-trip — a separate invocation, the extend/overwrite confirmation prompt, and the whole Phase-1 authoring scaffold (Steps 2–7: the open-questions dialog, the exit gate, the next-phase suggestion) — when all the user actually needs is to **append a row to an already-drafted, already-structured proposal**. The `/propose-update` re-entry path already supports "extend the existing proposal," so the capability exists — but the framework routes it through the Phase-1 command rather than letting the change be made **in place at the moment scope increase is discovered**, by whichever downstream phase discovered it.

This proposal makes **in-place amendment** a first-class, documented path: when scope increases on an already-created proposal, append the row(s) directly to the Proposed Changes table (with the amendment recorded), then re-validate — **without** re-running `/propose-update`. The downstream halt sites point at this path instead of bouncing the user back to Phase 1.

---

## Proposed Changes

| # | Canonical path | Operation | One-line change description |
|---|----------------|-----------|------------------------------|
| 1 | `host/templates/claude/commands/propose-update.md` | EDIT | Add a dedicated **"In-place amendment"** subsection — the canonical definition of the path, spelling out the three-step procedure (**strip the prior `Validated …` footer → append the row(s) to Proposed Changes → re-run `/validate-artifact`**) and stating that any downstream phase may perform it without a full `/propose-update` re-run. Cross-reference it from the existing Slug-resolution re-entry note (which already strips the footer on extend). |
| 2 | `host/templates/claude/skills/propose-update/SKILL.md` | EDIT | Mirror: one summary line pointing at the new in-place-amendment subsection in the command body (row 1). A pointer suffices — the full strip-footer → append → re-validate procedure lives in the command this skill mirrors, so it is not restated here (unlike row 4, whose command only *references* the procedure). |
| 3 | `host/templates/claude/commands/plan-update-implementation.md` | EDIT | Three sites, each phrased differently in the source — rewrite each to the in-place-amendment path (**append the missing row, strip the prior footer, re-run `/validate-artifact`, then resume planning**, referencing the row-1 subsection): **Step 1 line ~60** *"halt and direct the user back to `/propose-update` to expand the change list"*; **Notes line ~158** *"return to `/propose-update` to expand the proposal"*; **Step 3 cross-check line ~141** *"extend the proposal via re-baseline"* — this last one is additionally corrected from re-baseline to amendment semantics (a *missing* row is appended, not re-baselined). |
| 4 | `host/templates/claude/skills/plan-update-implementation/SKILL.md` | EDIT | Mirror line ~33 to the in-place-amendment wording (append row + strip footer + re-validate, per the row-1 subsection). |
| 5 | `host/templates/claude/commands/implement-update.md` | EDIT | **Step 3 scope-mismatch (line ~107)** — the missing-row case: rewrite to the in-place-amendment path (**append the missing row, strip the prior footer, re-run `/validate-artifact`**, referencing the row-1 subsection) instead of a `/propose-update` re-run. **Step 1 bad-path halt (line ~59)** — the `.claude/` path-correction variant: rewrite to *fix the offending row to point at the canonical source, strip the prior footer, re-run `/validate-artifact`* (still no full re-run; the row already exists, so this corrects rather than appends). **Notes "Re-baseline protocol" bullet (line ~127)** — add one line distinguishing amendment (missing row) from re-baseline (wrong row); the line ~70 and line ~127 re-baseline text itself stays unchanged. |
| 6 | `proposals/_template.md` | EDIT | In the **Proposed Changes** section, right after the existing Phase-3 ">10 file operations" threshold note (line ~63), add one line: a post-validation scope addition is an *in-place amendment* (strip footer → append row → re-run `/validate-artifact`) — no `/propose-update` re-run required. |

**Paired-file check:** rows 1↔2 and 3↔4 are command↔skill pairs. `implement-update` (row 5) has a mirrored skill (`skills/implement-update/SKILL.md`), but its summary carries **no** bounce-back text (verified — it only summarizes Step 3 generically with no `/propose-update` re-run instruction), so no skill edit is paired with row 5 (confirmed by OQ3).

---

## Risks

- **Validation-integrity regression.** The validation footer attests that the *whole* change list was reviewed. If in-place amendment lets a row be added without re-validation, the footer silently lies and `/implement-update` would execute an unvalidated row. **Mitigation:** the path mandates **stripping the prior footer** and re-running `/validate-artifact` before the downstream phase resumes — and because `/validate-artifact` Step 8 only *appends* a footer (it does not remove a stale one), the explicit strip step is authored into every site that defines the amendment path (rows 1, 3, 4, 5), not just described once. The footer is always re-earned over the larger change list. (This is the crux; settled by OQ1 in Resolved Questions.)
- **Phase-boundary blur.** Letting `/plan-update-implementation` or `/implement-update` append a Proposed Changes row crosses into Phase-1 authoring territory. **Mitigation:** the discovering phase only appends the row + halts for re-validation; it does not continue past an unvalidated proposal. Phase-per-command resumability is preserved because re-validation is still its own command.
- **Drift risk.** Pure prose/policy edits to canonical command bodies; standard canonical↔`.claude/` drift if regen is skipped. Mitigated by the Phase 5 `/regen-framework` + `--check`.
- **Child-project compatibility.** Generated `.claude/` command/skill bodies update on the next `import-shamt` + regen. No data loss; no migration.
- **Open-questions debt.** The re-validation requirement and the discovering-command behavior were resolved during drafting (OQ1–OQ3 in Resolved Questions), not deferred — they determine the literal policy wording, so none is left for the implementer to guess.

---

## Rollback Plan

1. `git revert <commit-sha>` on the canonical edit commit.
2. Run `/regen-framework` to propagate the revert into `.claude/`.
3. No child-side action beyond the next routine `/import-shamt`.
4. Communication: note in the revert commit message; children pick it up on next import.

---

## Validation Considerations

Dimension hints for the Phase 2 validation loop (`/validate-artifact proposals/in-place-proposal-amendment.md`).

- **Problem clarity** — confirm the five command-body sites are quoted accurately and that "in-place amendment" is clearly distinguished from the existing **Re-baseline Protocol** (re-baseline = a row was *wrong*; amendment = a row was *missing*). The two must not be conflated — `implement-update.md` line ~70 and line ~127 ("if the proposal itself was wrong" / "a Proposed Changes row turns out wrong") are correctly left as re-baseline, with row 5 adding only a one-line cross-reference at ~127.
- **Change-list completeness** — the highest-risk dimension. Every command body whose bounce-back text changes must have its mirrored skill checked for the same text (rows 1↔2, 3↔4; row 5's skill verified clean). All six bounce-back sites are covered: the four missing-row sites (plan-update-implementation lines ~60/~141/~158 by row 3; implement-update line ~107 by row 5), the one `.claude/` path-correction site (implement-update line ~59 by row 5), and the one skill mirror (line ~33 by row 4). **Footer-strip propagation:** verify the strip-footer step is authored into rows 1/3/4/5, not only into `propose-update.md` — `/validate-artifact` does not remove a stale footer, so a site that says "re-validate" without "strip first" is incomplete. The grep behind this proposal covered `host/templates/claude/`, `templates/`, `reference/`, `CHEATSHEET.md`, `proposals/_template.md`; `reference/` has zero bounce-back sites.
- **Risk coverage** — the validation-integrity risk is load-bearing; confirm the chosen re-validation policy (OQ1, Resolved Questions: strip footer + full re-validate) actually closes it.
- **Rollback feasibility** — pure EDITs, no MOVE/DELETE; revert is clean.
- **Affected surfaces** — commands, skills, the canonical proposal template. No reference/, persona, or script changes (the policy lives in command bodies + template).
- **Propagation plan** — requires `/regen-framework` after edits; children pick it up on next `/import-shamt`.

---

## Open Questions

_(none — all resolved; see Resolved Questions)_

---

## Resolved Questions

<!-- Append as questions resolve. -->

- ~~OQ1: After an in-place amendment, full re-validate or lighter touch?~~ → A: **Full re-validate.** Appending a row strips the validation footer; `/validate-artifact` re-runs on the whole proposal before the downstream phase proceeds. This removes the `/propose-update` re-run, not the validation — the footer keeps meaning "every row reviewed in one pass," closing the validation-integrity risk.
- ~~OQ2: Who appends the missing row when a downstream phase discovers it?~~ → A: **The discovering command appends it, then halts.** `/plan-update-implementation` or `/implement-update` adds the row (it already knows the exact path + operation it found), strips the footer, and halts directing the user to re-run `/validate-artifact`. The command does the mechanical edit but does not proceed past an unvalidated proposal — phase-per-command resumability holds because re-validation remains its own command.
- ~~OQ3: Explicit amendment log, and does implement-update's skill need a paired edit?~~ → A: **Footer line only; no implement-update skill edit.** Traceability rides on the existing re-validation footer convention (`Re-validated YYYY-MM-DD — added {row}`); no new `## Amendments` template section. `skills/implement-update/SKILL.md` carries no bounce-back text, so it needs no paired change — row 5 stays skill-less. (No change to the Proposed Changes table results from this answer.)

---

<!-- Phase 2 validation appends the footer below on a clean exit. Do not pre-fill. -->

---
Validated 2026-05-30 — 4 rounds, 1 adversarial sub-agent confirmed
