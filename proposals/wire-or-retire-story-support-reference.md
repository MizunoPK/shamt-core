# Proposal: wire-or-retire-story-support-reference

**Created:** 2026-05-31
**Status:** Draft
**Proposed by:**
**Project context:**

---

## Problem

`shamt-core/reference/story_support.md` is an **orphaned reference doc**: nothing in the canonical surface cites it. A `/f5-audit-framework` sweep found it referenced only by archived proposals under `proposals/archive/` — no host command, skill, or persona body; the rules file `templates/SHAMT_RULES.template.md`; or any live reference doc points to it.

The content is real and validated (footer: "Validated 2026-05-27 — 5 rounds, 1 adversarial sub-agent confirmed"): Engineer-flow context-clear handoff snippets (one per Gate 2a / 2b / 3 / Review), Quick/Standard story artifact-layout trees, and the `addressed_feedback.md` outline + allowed-status list. It is useful material — but because nothing wires to it, a fresh agent running the Engineer flow never discovers it, so it neither pulls weight nor gets maintained. That is a bidirectional-coverage gap (D3): a reference with no consumer.

The decision is binary and is the load-bearing open question: **wire it in** (cite it from the Engineer-flow commands/skills whose breakpoints and artifacts it supports) or **retire it** (its content is either redundant with the templates/rules or not worth maintaining). The Proposed Changes table depends entirely on that answer.

---

## Proposed Changes

Light/central wiring — cite `reference/story_support.md` from a few natural hubs so it gains live consumers and becomes discoverable, proportionate to a LOW finding.

| # | Canonical path | Operation | One-line change description |
|---|----------------|-----------|------------------------------|
| 1 | `shamt-core/CHEATSHEET.md` | EDIT | In `### Engineer flow (Part 1 — story-level execution)`, add a one-line pointer to `reference/story_support.md` as the Engineer-flow quick reference (handoff snippets, artifact-layout trees, addressed_feedback outline). Markdown link `[reference/story_support.md](reference/story_support.md)`. |
| 2 | `shamt-core/templates/SHAMT_RULES.template.md` | EDIT | In the Part 3 Engineer-flow narrative, cite `reference/story_support.md` as supporting material for the per-Gate context-clear handoff snippets and the Quick/Standard story artifact layouts (same `reference/X.md` citation style already used for `pr_review_prevention.md`, `question_brainstorm_categories.md`, etc.). |
| 3 | `shamt-core/host/templates/claude/commands/e7-resolve-feedback.md` | EDIT | In Step 2 ("Open or update `addressed_feedback.md`"), cite `reference/story_support.md`'s addressed_feedback outline + allowed-status list as the reference for the row shape and statuses. |
| 4 | `shamt-core/host/templates/claude/skills/e7-resolve-feedback/SKILL.md` | EDIT | Mirror the Step 2 citation so the skill body stays consistent with its command (command ↔ skill pairing). |

Row count: 4 ≤ 10 — no Phase 3 plan required.

---

## Risks

- **Regression risk** — none functional; these are reference citations, not an executable instruction path.
- **Drift risk** — rows 3–4 are under `host/templates/claude/` and need `/f4-regen-framework` (Phase 5); rows 1–2 (`CHEATSHEET.md`, the rules template) are canonical-but-not-`.claude`-managed and do not regenerate. Mechanically caught by the post-edit `--check`.
- **Child-project compatibility** — picked up cleanly on next `import-shamt`; the change only adds discoverability.
- **Open-questions debt** — both the wire-vs-retire decision and the wiring-extent decision are resolved in dialog before this proposal is considered drafted.

---

## Rollback Plan

Revert the commit and re-run `/f4-regen-framework` (if wiring touched host bodies). For a retire, `git revert` restores the file; no child-side action required.

---

## Validation Considerations

- **Change-list completeness** — the easy-to-miss paired edit is the `e7` **skill** (row 4) alongside its command (row 3); both cite the addressed_feedback outline together. The CHEATSHEET (row 1) and rules (row 2) links must use working relative paths (`reference/story_support.md`) — the existing `reference/batch_validation_handoff.md` CHEATSHEET link and the `reference/pr_review_prevention.md` rules citations are the precedent to match.
- **Affected surfaces** — `CHEATSHEET.md`, the rules template, and host command+skill (e7). No personas/scripts; `reference/story_support.md` itself is unchanged (it gains consumers, not edits).
- **Citation accuracy** — confirm each citation actually points at the relevant story_support section: row 3/4 → the addressed_feedback outline; row 2 → the handoff snippets + artifact layouts; row 1 → the doc as a whole.
- **Propagation plan** — rows 3–4 require `/f4-regen-framework` + child import; rows 1–2 take effect on import alone (not regenerated).

---

## Open Questions

(none remaining)

---

## Resolved Questions

<!-- Drafting-only log -->

- ~~Q: Wire `reference/story_support.md` into the Engineer flow or retire it?~~ → A: Wire it in — the content is validated and useful; retiring discards good material. Add citations so it has at least one live consumer and becomes discoverable.
- ~~Q: How extensively to wire — light/central vs. distributed per-breakpoint?~~ → A: Light/central (4 rows: CHEATSHEET Engineer-flow section, rules Part 3 narrative, `/e7-resolve-feedback` command + skill). Proportionate to a LOW finding; gives the doc multiple live consumers without triggering a Phase 3 plan.
