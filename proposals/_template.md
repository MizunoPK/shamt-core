<!--
proposals/ folder layout (created on first use; folders are not committed empty):

  proposals/                                    (master-side filenames shown; child-side stay unnumbered {slug}.md)
  ├── _template.md                              (this file — copy when authoring a new proposal)
  ├── {NN}-{slug}.md                            (active proposals — Phase 1 through Phase 4)
  ├── {NN}-{slug}_PLAN.md                       (Phase 3 plan, only for proposals >10 file ops)
  ├── archive/{NN}-{slug}.md                    (post-implementation, set by /f6-archive-proposal)
  ├── archive/{NN}-{slug}.draft-{timestamp}.md  (abandoned drafts, set by /f1-propose-update on start-over re-entry)
  ├── rejected/{NN}-{slug}.md                   (explicit rejections with a top-of-file note)
  └── deferred/{NN}-{slug}.md                   (on hold)

Active proposals live at the top level. /f6-archive-proposal moves implemented
proposals (and any companion *_PLAN.md / *_PLAN_phase_N.md files) into
archive/; /f1-propose-update moves abandoned drafts into archive/ with a
.draft-{timestamp} infix when the user picks "start over" on re-entry. The
rejected/ and deferred/ folders are populated manually by the user (or by
/sync-triage-proposals on the master side, when that ships).

Numbering + branch convention (master-side only; see shamt-core/CLAUDE.md
§Conventions): each master-side proposal carries a filename prefix {NN}- and a
matching **Number:** header, assigned as max(existing NN across proposals/,
archive/, deferred/, rejected/) + 1 at /f1-propose-update (master-local) or
/sync-triage-proposals promote (child-submitted). Child-side proposals under
.shamt-core/proposals/ stay unnumbered {slug}.md. /f3-implement-update creates
the proposal/{NN}-{slug} branch; /f6-archive-proposal squash-merges it to the
base branch and deletes it.
-->

# Proposal: {slug}

**Created:** [YYYY-MM-DD]
**Status:** Draft
**Number:** [NN — master-side only; assigned by /f1-propose-update or /sync-triage-proposals promote. Blank/omitted on the child side and for grandfathered proposals.]
**Proposed by:** [Project name, or blank for master-local proposals]
**Project context:** [One-line context for child-submitted proposals; blank for master-local]

<!--
f0-draft capture variant (written by /f0-draft-proposal — a quick, unrefined
idea/audit capture that has NOT been through the open-questions dialog):

  - Status uses the distinct value `Draft (f0 — audit capture, unrefined)` —
    visibly different from a normal in-progress `Draft` so f1's re-entry logic
    (and human readers) never conflate the two.
  - A banner line sits immediately under the header block:

      > **f0 DRAFT — unrefined capture.** Quick-captured by the framework audit
      > or a user; not yet through the open-questions dialog. Run
      > `/f1-propose-update {slug}` to flesh it out — f1 ingests this file as
      > its intake, normalizes the status to plain `Draft`, and develops the
      > Scratch Notes below into a full Problem + Proposed Changes + Risks /
      > Rollback / Validation Considerations.

  - An f0 draft fills only the title and the **Scratch Notes (f0 capture)**
    section (documented under Problem below); it leaves the formal Proposed
    Changes table and Risks / Rollback / Validation Considerations as template
    placeholders for f1.

A normal (non-f0) proposal omits the banner and the Scratch Notes section and
uses the plain `Draft` status.
-->

---

## Problem

[1–3 paragraphs. State the concrete problem in the framework as it exists today: a pattern that is missing, a rule that is wrong or misleading, a template that fails to capture what the protocol requires, a reference doc whose claims have drifted from the canonical source, a host wiring that breaks in a real scenario.

Cite specific files / sections (`shamt-core/templates/SHAMT_RULES.template.md` §Pattern X, `shamt-core/reference/Y.md`, `shamt-core/host/templates/claude/commands/Z.md`) so a fresh agent can verify the problem without context. If the trigger was a story-level incident, link the story slug.]

<!--
Optional — f0 capture only. /f0-draft-proposal does NOT fill the formal Problem
above or the Proposed Changes table; instead it writes the raw idea / audit
finding into a **Scratch Notes (f0 capture)** section here, e.g.:

  ## Scratch Notes (f0 capture)

  [The raw blurb / audit-finding text, verbatim or lightly tidied. Implicated
  canonical files may be named informally inline. No formal change list — that
  is f1's job.]

/f1-propose-update consumes this section as the seed when fleshing out an f0
draft, then removes it once the formal Problem + Proposed Changes exist. A
normal proposal omits this section entirely.
-->

---

## Proposed Changes

A flat list of canonical files the proposal will touch. **Every file the proposal will edit, create, delete, or move must appear here** — Phase 2 (validate-artifact) and Phase 4 (implement-update) both read this list as the source of truth for change scope.

| # | Canonical path | Operation | One-line change description |
|---|----------------|-----------|------------------------------|
| 1 | `shamt-core/templates/SHAMT_RULES.template.md` | EDIT | [What changes in this file and why] |
| 2 | `shamt-core/host/templates/claude/commands/...` | CREATE / EDIT / DELETE / MOVE | [What changes in this file and why] |

**Path discipline:**

- **CREATE** must give the exact target path and a one-line content sketch.
- **EDIT** must name the exact section / heading the edit lands in.
- **DELETE** must justify the removal.
- **MOVE** is recorded as paired CREATE + DELETE rows.
- Generated `.claude/` files are **never** listed. Edits go to canonical sources:
  - `shamt-core/templates/`
  - `shamt-core/reference/`
  - `shamt-core/host/templates/claude/`
  - `shamt-core/scripts/`
  - `shamt-core/proposals/` (when the proposal updates the proposal template or folder docs)
  - the root-level canonical docs: `shamt-core/CLAUDE.md`, `shamt-core/README.md`, `shamt-core/shamt-config.example.json`.

  Regen (Phase 5) propagates to `.claude/`. Any path outside this list must be justified in **Validation Considerations** or **Risks**.

If the total row count exceeds **10 canonical file operations**, Phase 3 (`/f2-plan-update-implementation`) is required before Phase 4. The threshold is a framework-altitude expression of the single-session sizing constraint (Principle 1 in [`SHAMT_RULES.template.md`](../templates/SHAMT_RULES.template.md#principle-1-phase-per-command--slug-resumability)).

If a downstream phase later finds this table is *missing* a row (a paired file or reference site surfaced while planning or implementing), add it via an **in-place amendment** — strip the prior `Validated …` footer → append the row → re-run `/validate-artifact` — rather than a full `/f1-propose-update` re-run (see the **In-place amendment** section of `/f1-propose-update`).

---

## Risks

[Bullet list. For each: what could go wrong, who notices, how bad it is.

Cover at least:

- **Regression risk** — what existing flow could the change break?
- **Drift risk** — could canonical and generated `.claude/` get out of sync if regen is missed?
- **Child-project compatibility** — do already-installed child projects pick this up cleanly on the next `import-shamt`, or does it require a manual reconciliation step?
- **Open-questions debt** — does this change introduce questions that should be resolved before merge rather than left to the next agent?]

---

## Rollback Plan

[How to revert if the change goes wrong after merge. Concrete steps:

1. `git revert <commit-sha>` (or equivalent) on the canonical edit commit.
2. Run `/f4-regen-framework` to propagate the revert into `.claude/`.
3. Any child-side action required (e.g., re-run `/sync-import-shamt` on each installed child).
4. Communication: who needs to be told.

For purely additive changes (new file, new section, no edits to existing canonical text), rollback is `git revert` + regen and this section can be one line: `Revert the commit and re-run /f4-regen-framework. No child-side action required.`]

---

## Validation Considerations

Dimension hints for the Phase 2 validation loop (`/validate-artifact proposals/{slug}.md`). Tell the validator where to look hardest.

- **Problem clarity** — [What in the Problem section is most likely to be misread? Any terminology overlap with existing v2 concepts?]
- **Change-list completeness** — [Files that are easy to forget but must be edited together with the listed ones (e.g., the rule changes but the template referenced by the rule does not; the reference doc changes but the rule that points at it does not). Note: a `skills/{name}/SKILL.md` `## Protocol` **is** the command-body pointer, never a step-by-step paraphrase (the **Command → Skill Protocol pointer rule** at the D2 entry in `reference/audit_dimensions.md`) — so a command-step edit needs **no** paired SKILL summary edit; conversely, a Proposed Changes row must never (re-)introduce a numbered paraphrase into a SKILL Protocol.]
- **Risk coverage** — [Specific scenarios the risks list might miss.]
- **Rollback feasibility** — [Anything in the change that would make revert harder than the rollback plan describes — e.g., a destructive DELETE, a MOVE that loses git history.]
- **Affected surfaces** — [Which Shamt surfaces does this touch: rules, references, templates, commands, skills, personas, scripts? Any cross-doc consistency to verify.]
- **Propagation plan** — [Does this require a regen + child import to take effect? Does any already-installed child need a manual nudge?]

---

## Open Questions

Maintain this section as you draft. Surface questions one at a time via `AskUserQuestion` and update the proposal with each answer before moving on. The proposal is not "drafted" while questions remain — per the open-questions iterative dialog principle in [`SHAMT_RULES.template.md`](../templates/SHAMT_RULES.template.md#principle-2-open-questions-iterative-dialog).

- [ ] [Question 1 — what decision is open, and what the answer would change in the proposal]
- [ ] [Question 2 — …]

Resolved questions move to a `## Resolved Questions` log inline (one line each, with the resolution) so future readers can see how the proposal firmed up. The validation footer below is appended only when this **Open Questions** section is empty (the moved-resolved questions in `## Resolved Questions` are a separate log and do not block the footer).

---

## Resolved Questions

<!-- Drafting-only log — consumed by /f1-propose-update during the open-questions
iterative dialog (Phase 1) and read by humans for proposal-history context.
Not consumed by /validate-artifact, /f3-implement-update, or /f6-archive-proposal. -->

[Append as questions resolve. One line each:]

- ~~Q: [original question]~~ → A: [resolution + reason]

---

<!-- Phase 2 validation appends the footer below on a clean exit. Do not pre-fill in a new proposal. -->

<!-- The footer below validates this TEMPLATE itself, not any individual proposal. New proposals start with a clean slate; /validate-artifact appends a fresh per-proposal footer when Phase 2 exits cleanly. -->

---
Validated 2026-05-28 — 4 rounds, 1 adversarial sub-agent confirmed (Phase 8 implementation loop)
