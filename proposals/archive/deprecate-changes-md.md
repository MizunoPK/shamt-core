# Proposal: deprecate-changes-md

**Created:** 2026-05-29
**Status:** Implemented
**Proposed by:**
**Project context:**

---

## Problem

The framework-update flow's Phase 7 (`/archive-proposal`) maintains a `CHANGES.md` file at the project root as a reverse-chronological log of "upstream-worthy" framework changes. The stated purpose is that child projects, on the next `import-shamt`, can read `CHANGES.md` to see what they are picking up.

In practice this machinery is dead weight:

1. **No `CHANGES.md` has ever been created.** There are no real child projects installed, so the consumer the log is built for does not exist. The file is absent from the master repo root today.
2. **The import script never copies it.** `import-shamt.md:101` already concedes that `import-shamt.sh` does not sync `CHANGES.md` into the child — a child can only read it by browsing `master_url` directly. Git history (`git log` against the clone) carries the same information with more fidelity and no hand-maintenance.
3. **It imposes a recurring decision tax.** Every `/archive-proposal` run forces an "is this upstream-worthy?" `AskUserQuestion` (`archive-proposal.md` Step 3) whose *only* downstream consumer is the `CHANGES.md` append (Step 4). Removing the log removes the question.
4. **It is woven across 13 canonical files** — the `archive-proposal` command + skill carry a full Step 4 plus a description/purpose/notes; `model_selection.md`, `CHEATSHEET.md`, `CLAUDE.md`, and `SHAMT_RULES.template.md` mention it in flow descriptions; `proposals/_template.md`, `propose-update.md`, `implement-update.md` (+ skill), `submit-proposal.md`, and `triage-proposals.md` name it in path-discipline lists or `Proposed by:` attribution notes — each a small maintenance and cognitive cost that pays for nothing.

This proposal removes `CHANGES.md` from the framework: it strips the Step 3 upstream-worthiness gate and Step 4 append from `/archive-proposal` (command + skill), drops `CHANGES.md` from every path-discipline and flow-description reference, and rewrites the `import-shamt` Step 4 so child projects are pointed at `git log` / `import-shamt`'s own new/updated/unchanged/preserved report instead. The `Proposed by:` / `Project context:` provenance headers are **kept** — they have an independent consumer in `/triage-proposals` (filename-prefix stripping on promote) — but the dangling "…and `CHANGES.md`" attribution clauses are dropped.

Cited canonical sources: `host/templates/claude/commands/archive-proposal.md` (Steps 3–4, description, notes), `host/templates/claude/skills/archive-proposal/SKILL.md`, `reference/model_selection.md:62`, `CHEATSHEET.md:173`, `CLAUDE.md:47`, `templates/SHAMT_RULES.template.md:109,433`, `proposals/_template.md:58–59`, `host/templates/claude/commands/{propose-update,implement-update,import-shamt,submit-proposal,triage-proposals}.md`, `host/templates/claude/skills/implement-update/SKILL.md`.

---

## Proposed Changes

> **Phase 3 required — file count 13 > 10.** Run `/plan-update-implementation deprecate-changes-md` before `/implement-update`. The `archive-proposal` command + skill rewrites (removing Step 3 + Step 4 and renumbering) carry the design judgment; Phase 3 produces the exact per-occurrence locate/replace steps.

| # | Canonical path | Operation | One-line change description |
|---|----------------|-----------|------------------------------|
| 1 | `shamt-core/host/templates/claude/commands/archive-proposal.md` | EDIT | **Core rewrite.** Remove Step 3 (upstream-worthiness `AskUserQuestion`) and Step 4 (Update CHANGES.md) entirely; renumber the remaining steps (Commit suggestion, Exit) to 3–4. Strip the `CHANGES.md` clauses from the frontmatter `description`, the **Purpose** paragraph, the **Recommended model** line, the Step-5 commit-suggestion `git add` example, the Step-6 exit template, **Exit criteria**, and the two CHANGES-related **Notes** bullets (upstream-worthiness, `Proposed by:` provenance). The archive becomes: move + status update + commit suggestion + exit. |
| 2 | `shamt-core/host/templates/claude/skills/archive-proposal/SKILL.md` | EDIT | Mirror of #1: drop the CHANGES.md sentences from the `description`/triggers frontmatter; remove **both** protocol Step 3 (Upstream-worthiness `AskUserQuestion`) and Step 4 (Update CHANGES.md) from the Protocol summary and renumber the survivors (Commit suggestion 5→3, Exit 6→4); strip CHANGES.md from the **Recommended model**, **Exit criteria**, and commit-suggestion lines. |
| 3 | `shamt-core/reference/model_selection.md` | EDIT | Line 62: drop "+ optional `CHANGES.md` append" from the Phase 7 `/archive-proposal` row description. |
| 4 | `shamt-core/CHEATSHEET.md` | EDIT | Line 173: change the `/archive-proposal` row summary from "archive + optional `CHANGES.md` entry" to just "archive the implemented proposal". |
| 5 | `shamt-core/CLAUDE.md` | EDIT | "How changes land" list (§ around line 47): remove the "Update `CHANGES.md` if the change is upstream-worthy" step and renumber the surrounding steps. |
| 6 | `shamt-core/templates/SHAMT_RULES.template.md` | EDIT | Line 109: drop "+ `CHANGES.md` entries" from the Phase 6 Polish-output cell. Line 433: drop "update `CHANGES.md` when upstream-worthy," from the master-dev framework-update workflow sentence. |
| 7 | `shamt-core/proposals/_template.md` | EDIT | Path-discipline list (lines 58–59): remove the `CHANGES.md` format parenthetical and drop `shamt-core/CHANGES.md` from the root-level canonical-docs enumeration. |
| 8 | `shamt-core/host/templates/claude/commands/propose-update.md` | EDIT | Path-discipline list (lines 66–67): same removal as #7. Line 118: drop the "…and `CHANGES.md` (Phase 7)" clause from the `Proposed by:` provenance note (keep the `/triage-proposals` consumer). |
| 9 | `shamt-core/host/templates/claude/commands/implement-update.md` | EDIT | Line 56: drop `shamt-core/CHANGES.md` from the root-level canonical-docs enumeration. |
| 10 | `shamt-core/host/templates/claude/skills/implement-update/SKILL.md` | EDIT | Line 33: drop `CHANGES.md` from the canonical-roots enumeration. |
| 11 | `shamt-core/host/templates/claude/commands/import-shamt.md` | EDIT | "Step 6 — Suggest follow-ups" list, item 4 (line 101): remove the "read `CHANGES.md` on master" guidance; replace with pointing the user at `git log` against `master_url` and the import report's new/updated/unchanged/preserved counts (already surfaced per the Step-6 summary + Exit criteria) to see what changed. |
| 12 | `shamt-core/host/templates/claude/commands/submit-proposal.md` | EDIT | Line 44: drop the "…and `CHANGES.md`" clause from the `Proposed by:`/`Project context:` rationale (keep the `/triage-proposals` consumer). |
| 13 | `shamt-core/host/templates/claude/commands/triage-proposals.md` | EDIT | Line 159: rewrite the "Provenance preserved" note — `Proposed by:` is still preserved (it drives the promote-time filename-prefix strip), but drop the "which `/archive-proposal` reads later to attribute the change in `CHANGES.md`" tail. |

**Notes on scope:**

- **No file to delete.** No `CHANGES.md` exists at the master root today, so there is no DELETE row. This is purely a reference + machinery removal.
- **Generated `.claude/` mirrors are out of scope** — the `.claude/commands/`, `.claude/skills/` copies (archive-proposal, implement-update, import-shamt, propose-update, submit-proposal, triage-proposals) are regenerated from the host templates above via `/regen-framework` (Phase 5). They are never edited directly.
- **`Proposed by:` / `Project context:` headers survive.** Only their CHANGES.md-attribution clauses are dropped; the headers keep their `/triage-proposals` role. No change to `submit-proposal`/`triage-proposals` behavior beyond the wording.
- **The "upstream-worthy" *concept* is not globally banned — only its CHANGES.md usage.** The word survives legitimately in `propose-update`'s skill trigger ("capture an upstream-worthy idea", `skills/propose-update/SKILL.md:10`), where it means "an idea worth sending upstream to master" (the child→master submission concept), unrelated to the CHANGES.md log. That file is deliberately **not** in the change list; the removal is scoped to the 13 enumerated occurrences and must not blind-sweep every "upstream-worthy" string.
- **Sibling proposal `proposals/flow-phase-command-prefixes.md`** also touches `archive-proposal`; if both land, Phase 3 / implementation must reconcile against whichever merges first (flagged in Risks).

---

## Risks

- **Regression risk — `/archive-proposal` step renumbering.** Removing Steps 3 and 4 means the surviving Commit-suggestion and Exit steps renumber. A botched renumber leaves dangling cross-references ("see Step 4"). Mitigation: Phase 3 enumerates every intra-file "Step N" cross-reference in both the command and the skill; a post-edit grep for stale step numbers gates implementation.
- **Regression risk — over-removal.** A naive sweep could (a) strip `Proposed by:` / `Project context:` entirely, breaking `/triage-proposals`' promote-time filename-prefix strip, or (b) strip the legitimate "upstream-worthy" trigger phrase from `propose-update`'s skill (`skills/propose-update/SKILL.md:10`), which names the surviving child→master submission concept. Mitigation: the change list explicitly scopes #8/#12/#13 to dropping only the CHANGES.md *clause* (keeping the headers and their triage role), and `skills/propose-update/SKILL.md` is deliberately excluded from the list (see Notes on scope); Validation Considerations calls completeness out as the highest-risk dimension.
- **Drift risk.** Edits to the six host-template command/skill bodies require `/regen-framework` to propagate into `.claude/`. Missing regen leaves canonical and generated bodies out of sync. Standard Phase 5 step covers this; an `/audit-framework` D1 sweep confirms.
- **Child-project compatibility.** No real children are installed and `import-shamt.sh` never synced `CHANGES.md`, so blast radius is zero. A child that had manually created a `CHANGES.md` keeps its file untouched (it sits outside the master sync set); it simply stops being appended to. No migration needed.
- **Completeness risk — missed reference.** A surviving `CHANGES.md` mention in a flow description would misdirect a future agent toward a removed step. Mitigation: a post-implementation `grep -rn 'CHANGES' shamt-core` (excluding `.claude/` generated copies, `_reference/`, `proposals/archive/`, and this proposal) must return empty across canonical sources; this gates Phase 6.
- **Cross-proposal collision.** `flow-phase-command-prefixes.md` (active, sibling) also edits `archive-proposal`. If it lands first, the locate strings here shift. Mitigation: re-confirm locate strings at `/implement-update` time against the then-current file.
- **Open-questions debt.** Resolved below before exit (the replacement-story and removal-depth questions are settled in the dialog).

---

## Rollback Plan

1. `git revert <commit-sha>` on the canonical edit commit.
2. Run `/regen-framework` to propagate the revert into `.claude/`.
3. Child-side action: none — `CHANGES.md` was never synced to children, so no child picks up or loses anything.
4. Communication: note in the revert commit that the CHANGES.md machinery was restored. Purely a reference/machinery change; revert is clean (no destructive DELETE — no file ever existed to lose).

---

## Validation Considerations

- **Problem clarity** — confirm the rationale (no consumer exists; git log + import report supersede the log) reads cleanly, and that the kept-vs-dropped split for provenance headers is unambiguous.
- **Change-list completeness** — the highest-risk dimension. Verify: (a) the `archive-proposal` command↔skill pair both get the **Step 3 (upstream-worthiness) + Step 4 (CHANGES.md)** removal + renumber — the skill's Protocol summary carries the same two steps as the command, so neither edit can drop only one; (b) the path-discipline canonical-docs list appears in **four** files (`proposals/_template.md`, `propose-update.md`, `implement-update.md` command, `implement-update` skill) — all four must drop `CHANGES.md`, none missed; (c) the three provenance-attribution references (`propose-update:118`, `submit-proposal:44`, `triage-proposals:159`) drop only the CHANGES.md clause and keep the headers/triage role.
- **Risk coverage** — verify the provenance-over-removal risk and the step-renumber risk are both backstopped by greps, and that `import-shamt` Step 4's replacement guidance is accurate (the script genuinely does not sync CHANGES.md, and the new/updated/unchanged/preserved report genuinely exists).
- **Rollback feasibility** — trivial: no DELETE, no MOVE, no file existed; plain revert + regen.
- **Affected surfaces** — root docs (CHEATSHEET, CLAUDE), rules template, one reference doc, proposal template, six command bodies, two skill bodies. Broad but shallow except for the `archive-proposal` pair.
- **Propagation plan** — requires `/regen-framework` (host-template edits) to update `.claude/`. No child import needed (nothing synced).
- **Completeness backstop** — the Phase-6 gate grep (`grep -rn 'CHANGES' shamt-core`, scoped to canonical sources) must read empty.

---

## Open Questions

*(none — all resolved; see below)*

---

## Resolved Questions

<!-- Appended as questions resolve. -->

- ~~Q1: When `CHANGES.md` is gone, what does `import-shamt` Step 4 point a child at?~~ → A: **Both `git log` and the import report.** Step 4's replacement guidance points the child at `git log` against `master_url` for the change history and notes that `import-shamt` already surfaces new/updated/unchanged/preserved counts. Both already exist; no hand-maintained log is needed. (Row #11 already reflects this.)
- ~~Q2: Full removal vs. soft-deprecate?~~ → A: **Full removal.** Drop the Step 3 upstream-worthiness `AskUserQuestion` and the Step 4 append from `/archive-proposal` entirely, and remove every `CHANGES.md` reference across all 13 canonical files. The concept disappears from the framework — matching the "no longer useful" rationale. (The change list already reflects full removal.)

---
Validated 2026-05-29 — 2 rounds, 1 adversarial sub-agent confirmed
