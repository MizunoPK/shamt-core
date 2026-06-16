# Proposal: f5-audit-add-path-composition-check

**Created:** 2026-06-15
**Status:** Draft
**Number:** 35
**Proposed by:**
**Project context:**

---

## Problem

The `/f5-audit-framework` sweep (twelve dimensions D1–D12; canonical body at `host/templates/claude/commands/f5-audit-framework.md`, full definitions at `reference/audit_dimensions.md`) **failed to detect a real path-composition bug across PO-tree producers**. Proposal #30 (`proposals/30-ps0-draft-story-stub-nesting-path-drops-features-segment.md`) documents that `/ps0-draft` and `/ps1-define` (commands + mirror skills) write story-ticket stubs to a **collapsed** path `epics/{parent-feature-folder}/stories/…` that *drops the `features/` segment* — 9 live-bug occurrences — and that `/pf1-define` (`{parent-epic-folder}`) and `/pf2-decompose` (`{e}`) spell the same resolved-folder concept with *divergent placeholder vocabulary*. The canonical correct form is the full nested `epics/{epic-folder}/features/{feature-folder}/stories/…` used by `/pf2-decompose` and `/pf0-draft`. This drift was never caught by the audit and surfaced only as a downstream incident. #30 **fixes** the occurrences and **homes** a normative write-side path-composition vocabulary in `templates/SHAMT_RULES.template.md` §PO-tree resolution (its row 8). This proposal is the sibling that **hardens the audit's detection** so the class cannot silently re-open the next time a producer is added or reorganized — explicitly carved out of #30 (see #30's resolved-question 3) because the audit's own detection logic is a different surface from the path fix.

The true root cause sits one altitude above "the audit has no path check" (adversarial root-cause diagnosis, Opus `root-cause-diagnoser` + Haiku zero-bias confirmation). Once #30 pins the canonical `{epic-folder}` / `{feature-folder}` write-form in §PO-tree resolution, the relationship a divergent producer placeholder *breaks* is **rules ↔ host**: the host body **fails to implement a rules-file statement**. By `reference/audit_dimensions.md`'s own boundary — "D2 is **vertical** (does the host body faithfully implement the rules-file pattern?), D7 is **lexical** (is each concept *named* one way?), D9 is **horizontal** (do two non-rules files contradict?)" — that is **D2 (cross-doc consistency)**, not D7. The audit missed it because D2's *scope*, as worded in `host/templates/claude/commands/f5-audit-framework.md` Step 2 D2 (the "Naming matches (artifact names, phase names, tier names, persona names)" bullet) and in `reference/audit_dimensions.md`'s boundary text, **never signals that write-path placeholder vocabulary is in scope** — it enumerates structural identifiers (phase/artifact/persona names) but no path-template variable like `{epic-folder}` vs `{parent-feature-folder}`. So a primary audit agent walking §PO-tree does not see the drift as a D2 finding even though the relationship broken is exactly D2's.

The fix is therefore a **scope clarification to an existing dimension (D2)**, not a new sub-check buried under D7 and not a new dimension D13. D2 is already Reasoning-tier and already owns "naming matches"; the clarification extends that bullet to write-path placeholder vocabulary and anchors it on §PO-tree's write-vocabulary statement, with a one-line "see D2" carve-out added to D7 so the same finding is never counted under two dimensions (honoring the audit's "no finding under more than one dimension" rule). Choosing D2-extend over a new D13 also keeps every "12 dimensions" count (command, skill frontmatter, README, `audit_dimensions.md` table) **unchanged** — no count churn.

---

## Proposed Changes

A flat list of canonical files the proposal will touch.

| # | Canonical path | Operation | One-line change description |
|---|----------------|-----------|------------------------------|
| 1 | `shamt-core/host/templates/claude/commands/f5-audit-framework.md` | EDIT | In Step 2 **D2 — Cross-doc consistency**: extend the "Naming matches" sub-check to include **write-path placeholder vocabulary** — host PO-tree producers must spell §PO-tree resolution's canonical `{epic-folder}` / `{feature-folder}` full nested write-form; a producer writing `epics/{parent-feature-folder}/stories/…` (collapsed) or a divergent placeholder where §PO-tree pins `epics/{epic-folder}/features/{feature-folder}/stories/…` is a **HIGH** D2 finding. Add the matching mismatch example. In Step 2 **D7 — Terminology consistency**: add a one-line carve-out that path-template placeholders pinned by the rules file's §PO-tree write-vocabulary are checked by **D2 (rules ↔ host), not D7** (per the boundary in `reference/audit_dimensions.md`). |
| 2 | `shamt-core/host/templates/claude/skills/f5-audit-framework/SKILL.md` | EDIT | Mirror the same two edits in the summary: extend the D2 summary item (line ~49) with the write-path placeholder-vocabulary check anchored on §PO-tree, and add the "see D2" carve-out to the D7 summary item (line ~54). Paired edit with row 1 (command ↔ skill must stay symmetric or regen `--check` flags it). |
| 3 | `shamt-core/reference/audit_dimensions.md` | EDIT | In §"D2 vs D7/D9 — the clean boundary": append a sentence stating that a host body using a write-path placeholder that diverges from the rules-pinned §PO-tree vocabulary is **D2** (the rules-side statement makes it vertical), not D7. Add one worked example to the **intricate** fix-track table: a PO producer writing the collapsed `epics/{parent-feature-folder}/stories/…` where §PO-tree pins the full nested form → intricate (multi-file command ↔ skill + judgment) → f0-capture, not auto-fix. |

**Path discipline:** all rows land on canonical sources (`host/templates/claude/` + `reference/`); generated `.claude/` paths are excluded; regen (Phase 5) propagates the host edits. **This proposal does NOT touch `templates/SHAMT_RULES.template.md`** — the §PO-tree write-vocabulary statement the D2 check asserts against is added by **#30** (its row 8), keeping #35 off the size-budgeted rules file and avoiding overlap with #30. Row count = 3 (≤ 10) — no Phase 3 plan required.

---

## Risks

- **Regression risk** — Low. All three rows are additive scope clarifications (extend a D2 sub-check, add a D7 carve-out, append boundary text + one worked example). No existing dimension behavior is removed; no count changes, so no D10 fallout.
- **#30 sequencing dependency (the key risk)** — #35's D2 check **asserts against §PO-tree's write-vocabulary statement, which #30 adds**. #35 must land **after #30, or together with it**. If #35 landed first, the D2 paragraph would reference a §PO-tree statement that does not yet exist — a D4 broken-reference / D2-vs-reality finding the audit would itself flag on the next run. Absent #30 the check degrades to a weaker **D9 (host ↔ host)** uniformity check (no producer is privileged as canonical, so the audit could only say "these disagree," not "this one is wrong"). Mitigation: sequence #35 after/with #30; the Problem + this risk state the dependency explicitly.
- **D2/D7 double-counting risk** — Extending D2 to placeholders could invite counting the same finding under both D2 and D7. Mitigation: the explicit D7 "see D2" carve-out (row 1) + the `audit_dimensions.md` boundary sentence (row 3) keep path-placeholder findings squarely in D2, honoring the audit's "no finding under more than one dimension" rule.
- **Drift risk** — Standard: the host edits must be propagated via `/f4-regen-framework`, with `regenerate-framework.sh --check` showing zero drift. The command ↔ skill pair (rows 1 ↔ 2) must be edited together or `--check` flags the asymmetry.
- **Child-project compatibility** — Picked up cleanly on the next `import-shamt` (regenerates `.claude/`). The audit is master / self-host only, so the regenerated child `.claude/` f5 copies are inert managed files; no functional impact and no manual reconciliation.
- **Self-consistency** — The audit's own D2/D7/D9 checks run against these edited bodies; the new text must be internally consistent (D2 vertical, D7 deferring to D2) so the next audit does not flag it as a self-contradiction. Validation covers this.
- **Open-questions debt** — Resolved: dimension ownership (→ D2), breadth (→ concrete §PO-tree anchor), and the #30 dependency framing (→ sequencing, not absolute blocker) are all settled below before exit.

---

## Rollback Plan

Purely additive scope clarification. Revert the commit and re-run `/f4-regen-framework`. No child-side action required beyond the next routine `import-shamt`.

---

## Validation Considerations

- **Problem clarity** — The D2-not-D7 classification is the easiest thing to misread. Confirm the proposal *justifies* (not merely asserts) D2: the §PO-tree rules statement is what makes the relationship vertical (rules ↔ host), and the D7 "see D2" carve-out is what prevents double-counting.
- **Change-list completeness** — The command ↔ skill mirror pair (rows 1 ↔ 2) is the classic forget-the-paired-edit trap. Verify **both** the D2 extension and the D7 carve-out land in **both** files, and that `audit_dimensions.md` (row 3) gets both the boundary sentence and the worked example.
- **Risk coverage** — The #30 sequencing dependency is the load-bearing risk; confirm the proposal states #35 lands after/with #30 and degrades to D9 absent #30.
- **Affected surfaces** — commands, skills, references (**not** rules — that is #30's job). Verify no count claim ("12 dimensions") anywhere needs changing (the reason D2-extend was chosen over D13) — a D10 cross-check.
- **Self-consistency** — Confirm the edited f5 bodies remain internally consistent under the audit's own D2/D7/D9 dimensions (the new text must not read as a self-contradiction).
- **Rollback feasibility** — All EDITs, additive; clean `git revert`.
- **Propagation plan** — Requires `/f4-regen-framework` + `--check`. No child nudge (audit is master / self-host only; regenerated child copies are inert).

---

## Open Questions

_(none — all resolved; see Resolved Questions.)_

---

## Resolved Questions

<!-- Append as questions resolve. -->

- ~~Q: Which audit dimension should own the new path-composition / placeholder-vocabulary check — D2, D7, or a new D13?~~ → A: **Extend D2 (rules ↔ host)** (user-decided). Once #30 pins §PO-tree's canonical `{epic-folder}` / `{feature-folder}` write-form, a divergent producer placeholder *fails to implement a rules-file statement* = D2 (vertical) by `audit_dimensions.md`'s own boundary. Extend D2's "Naming matches" sub-check + add a one-line "see D2" carve-out to D7 (no double-counting). Rejected **D7** (lexical — weaker once a privileged canonical form exists; would reach the same conclusion only by ignoring that the rules file now states the canonical form) and a **new D13** (count-churning — every "12 dimensions" claim would become 13 — and a heavier surface for a class D2 already owns).
- ~~Q: Scope the check concretely to §PO-tree, or generalize to "any canonical write-path vocabulary"?~~ → A: **Concrete §PO-tree anchor.** §PO-tree is the only documented instance, and D2's general "naming matches" framing already extends to any future rules-pinned write-vocabulary without a fresh f5 edit — so no vague open-class language is needed (which the adversarial confirmation flagged as under-specified). Generalize later, when a second concrete instance emerges, via `/f1-propose-update`.
- ~~Q: Is #30 a hard blocker, or can #35 land independently?~~ → A: **Sequencing dependency, not an absolute blocker.** #35's D2 framing asserts against §PO-tree's write-vocabulary (#30's row 8), so #35 lands after/with #30; absent #30 the check degrades to a weaker D9 (host ↔ host) uniformity check with no privileged canonical. #30's own resolved-question 3 already anticipated this sequencing.

---
