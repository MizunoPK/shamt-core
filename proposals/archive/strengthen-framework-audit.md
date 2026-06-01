# Proposal: strengthen-framework-audit

**Created:** 2026-05-29
**Status:** Implemented
**Proposed by:**
**Project context:**

---

## Problem

The framework audit (`/audit-framework`, canonical body at `shamt-core/host/templates/claude/commands/audit-framework.md`, mirrored skill at `shamt-core/host/templates/claude/skills/audit-framework/SKILL.md`) does not feel comprehensive enough. As built it sweeps six dimensions — D1 sync drift, D2 cross-doc consistency, D3 bidirectional coverage, D4 reference validity, D5 template-protocol alignment, D6 project-doc currency — and exits on 2 consecutive clean rounds. Three gaps stand out against the user's stated goals of **completeness, correctness, and consistency**:

1. **Coverage gaps.** The v1 audit (mined from `_reference/shamt-ai-dev/.shamt/guides/audit/`) carried 23 dimensions. Most were v1-specific (file-size caps, S1–S11 stage-flow, MANDATORY READING PROTOCOL / FORBIDDEN SHORTCUTS) and were rightly dropped. But several semantic checks have no v2 equivalent and map directly onto the three C's. **Resolved (Q1): add five new dimensions D7–D11** to the existing D1–D6 (numbers/names of D1–D6 unchanged):
   - **D7 Terminology consistency** — one canonical term per concept across all canonical docs (e.g. "Quick/Standard" never "Small/Full", "Build" never "Implement").
   - **D8 Content completeness** — no stray `TODO` / `TBD` / unfilled `[placeholder]` brackets in canonical content.
   - **D9 Duplication / contradiction detection** — two canonical files must not give conflicting instructions for the same protocol.
   - **D10 Count / claim accuracy** — explicit counts and claims match reality ("6 dimensions" → now 11, "5 patterns", "8 plan dimensions", phase numbers).
   - **D11 Scope-clarity / comprehension risk** — each command and skill states its scope unambiguously near its heading; no leftover migration notes left inline in the agent-instruction path.

   The current D2 (cross-doc consistency) is the nearest analogue to D7/D9 but is scoped to rules↔skill/command agreement; the validator must confirm a clean boundary (Validation Considerations).

2. **No validation loop.** The audit deliberately omits the adversarial sub-agent confirmation that Pattern 1 (`SHAMT_RULES.template.md` §Pattern 1, Steps 6–7) requires of every validated artifact. The command body states outright: *"The audit consecutive-clean rule does not require sub-agent confirmation — that is `/validate-artifact`'s pattern."* **Resolved (Q3): the audit adopts Pattern 1's exit exactly** — **1 primary clean round + 1 adversarial Haiku sub-agent confirmation**, where any sub-agent finding (including a single LOW; no one-LOW allowance for the sub-agent) resets the loop. This replaces the current "2 consecutive clean rounds, no sub-agent" exit, supersedes the command-body rationale note ("2 consecutive clean is deliberate. v1 used 3 rounds; v2 trims this"), and makes the audit's loop semantics word-for-word consistent with Pattern 1 (which D2/D7 then check the framework against).

3. **Report-only fix policy is too passive.** The audit's current fix policy (`audit-framework.md` Step 3, and the resolved decision in `../INFRASTRUCTURE.md` §3.9: *"report findings with severity; let user decide whether to fix or accept"*) forbids all but mechanical re-verification. The user wants a two-track outcome (**resolved Q2**):
   - **Simple finding → fix immediately, then verify by re-running its dimension.** A finding is *simple* only when the fix is mechanical, single-file, and the correct fix is uniquely determined by the finding — e.g. a broken link path, a count/number correction, terminology normalization to the one canonical term, removing a stray TODO/placeholder. After a canonical edit, the fix-immediately track triggers regen (or re-runs D1) so `.claude/` stays synced.
   - **Intricate finding → spawn a `/propose-update` proposal.** Anything needing design judgment, coordinated multi-file edits (rule↔template↔skill), or protocol-semantic changes. **Borderline → treated as intricate.** The audit drafts/suggests the proposal slug and stops short of editing.
   - **Master-target only (resolved Q5).** The auto-fix track fires **only when the audit's canonical target is master / the shamt-core self-host** (detected via the same self-host rule D6 already uses). When `/audit-framework` runs against a **child project**, its canonical sources under `.shamt-core/` are imported read-only copies of master — auto-fixing them would be clobbered on the next `/import-shamt` and silently diverge the child from master. So in a child context the audit stays **report-only**: findings surface (with a suggestion to route upstream via `/propose-update` → `/submit-proposal`), and only the genuinely-local mechanical re-verifications already permitted today (re-running regen / `--check` for D1) may run. The fix-immediately track does **not** edit a child's imported canonical copies.
   - **Both flow contexts (master target).** On a master target, auto-fix of simple findings runs in both standalone audits and inside the framework-update flow (Phase 6). When in-flow, each simple fix is applied and **logged in chat as an out-of-band correction, explicitly distinct from the in-flight proposal's scope**, so the proposal's validated change-set and footer stay clean.

   This keeps trivial drift from accumulating on master while still routing anything requiring design judgment through the proposal → validate → implement flow, and never touches a child's imported canonical copies. The three criteria above (mechanical + single-file + uniquely-determined) plus the borderline→intricate rule are the **normative boundary**; the new `reference/audit_dimensions.md` (Q4) only elaborates them with worked examples — it does not introduce new boundary logic the implementing agent has to invent.

This proposal reverses two decisions recorded as "Resolved" in `../INFRASTRUCTURE.md` §3.9 (report-only; no sub-agent) and the corresponding note in the audit command body. That reversal is the explicit ask, not an oversight.

---

## Proposed Changes

| # | Canonical path | Operation | One-line change description |
|---|----------------|-----------|------------------------------|
| 1 | `shamt-core/host/templates/claude/commands/audit-framework.md` | EDIT | **Frontmatter `description`:** update "6 audit dimensions" → "11" and "2 consecutive clean rounds" → the Pattern 1 exit phrasing. **Body:** add D7–D11 to the dimension table + Step 2; replace the "2 consecutive clean rounds, no sub-agent" exit (Steps 4–6 + the Notes rationale) with Pattern 1's exit — 1 primary clean round + 1 adversarial Haiku sub-agent confirmation (any finding resets), spawned via the new `audit-checker` persona (Q6); replace the "no silent autopatch" fix policy (Step 3) with the simple-fix-immediately / intricate-routes-to-proposal two-track, **scoped to a master / self-host target** (in a child project the audit stays report-only — see Problem §3 / Q5); on a master target, auto-fix runs in both standalone and in-flow contexts, in-flow simple fixes logged out-of-band. |
| 2 | `shamt-core/host/templates/claude/skills/audit-framework/SKILL.md` | EDIT | **Frontmatter `description`:** mirror the command's "six dimensions … D6" → "D1–D11" and the "2 consecutive clean rounds" → Pattern 1 exit update. **Body:** mirror the expanded D1–D11 summary, the Pattern 1 exit (incl. the `audit-checker` sub-agent), and the new master-target-only two-track fix policy; add links to the new `reference/audit_dimensions.md` and `agents/audit-checker.md`. |
| 3 | `shamt-core/host/templates/claude/agents/audit-checker.md` | CREATE | New adversarial sub-agent persona (Haiku, Q6). Contract: re-run the D1–D11 dimensional sweep across the canonical surface with zero bias; report ANY finding (no one-LOW allowance); reply `CONFIRMED: Zero issues found after adversarial review.` only when it independently finds nothing. Distinct from `validation-checker` (which is single-artifact-scoped) — this persona is framework-sweep-scoped. Regenerates into `.claude/agents/` (managed subtree). |
| 4 | `shamt-core/CHEATSHEET.md` | EDIT | Update the `/audit-framework` row from "D1–D6 sweep" to "D1–D11 sweep", **and add an `audit-checker` row to the Sub-agent personas table** (Haiku; Used by `/audit-framework`). No config-knob row (Q2 chose always-on, not config-gated). |
| 5 | `shamt-core/reference/audit_dimensions.md` | CREATE | New reference: full D1–D11 definitions grouped under Completeness / Correctness / Consistency, the simple-vs-intricate fix-track rubric with worked examples (incl. the master-target-only scope and the child→report-only carve-out), and a known-exceptions section (intentional patterns the expanded audit must not re-flag each run). The inline command/skill criteria remain the normative boundary; this doc only elaborates with examples (mirrors how Pattern 1 offloads to `reference/validation_exit_criteria.md`). Linked from both the command and the skill. |
| 6 | `shamt-core/reference/model_selection.md` | EDIT | Add a row for the audit's new adversarial sub-agent (Cheap / Haiku via the `audit-checker` persona, parallel to the existing Phase 2 `/validate-artifact` `validation-checker` sub-agent row), and refresh the existing Phase 6 primary-loop row's enumerated reasoning dimensions to add the synthesis-heavy new dimensions **D7, D9, D11** (Reasoning); **D8, D10** are mechanical-leaning and join the D1/D4 cheap sub-checks row. |
| 7 | `../INFRASTRUCTURE.md` | EDIT | Three locations: (a) §3.5 — update the dimension table (6 rows → 11) and the "Exit on 2 consecutive clean rounds" line → the Pattern 1 exit (1 primary clean + sub-agent); (b) §3.2 — the "Consecutive-clean exit on audit" row that currently reads "Audit exits on **2** consecutive clean rounds" → the Pattern 1 exit; (c) §3.9 — the **single resolved bullet** "Should `/audit-framework` block on findings or just report?" (whose one answer bundles report-only behavior *and* "Consecutive-clean exit (2 rounds) is the only gate", which together imply no sub-agent) — supersede that one bullet with a note pointing at this proposal. Out-of-`shamt-core/` path — justified in Validation Considerations (it is the documented home for v2 infrastructure decisions). |

Row count = 7 (2 CREATE, 5 EDIT) — ≤ 10, so Phase 3 (`/plan-update-implementation`) is **not** required.

---

## Risks

- **Regression risk** — Expanding dimensions and adding a sub-agent confirmation lengthens every audit and could surface a flood of pre-existing LOW findings on the first run against current `shamt-core/`. Noticed immediately by whoever runs the next audit. Mitigated by the known-exceptions section in the new `reference/audit_dimensions.md` and by the simple-fix-immediately track clearing trivial drift in-loop.
- **Auto-fix overreach (the central risk)** — If the "simple" boundary is drawn too wide, the audit edits canonical sources that actually warranted a proposal, bypassing `/propose-update` + `/validate-artifact`. This is exactly what the current "no silent autopatch" rule guards against. Mitigation: a crisp, conservative boundary (borderline → treat as intricate → proposal), every auto-fix verified by re-running its dimension, and every auto-fix logged in chat.
- **Drift risk** — An auto-fix to a canonical source under `host/templates/claude/` must be followed by regen or `.claude/` falls out of sync. The fix-immediately track must trigger `/regen-framework` (or re-run D1) after any canonical edit.
- **Bypass-the-flow risk** — Inside the framework-update flow (Phase 6), an in-flight proposal already owns a change scope; auto-patching canonical files mid-audit could muddy that proposal and its validation footer. **Resolved (Q2): auto-fix still runs in-flow**, but each simple fix is logged in chat as an out-of-band correction distinct from the proposal's scope. The implementing agent must make that separation explicit in the command body so a reader can always tell which edits belong to the proposal vs the audit.
- **Child-project compatibility** — `/audit-framework` ships to child projects (D6 runs against their project docs). The new behavior arrives on the next `import-shamt`; no manual reconciliation. **Resolved (Q5): in a child the audit stays report-only** — the auto-fix track fires only on a master / self-host target, so a child never sees auto-edits to its imported `.shamt-core/` canonical copies (which would be clobbered on the next import and diverge from master). A child's findings surface with an upstream-routing suggestion (`/propose-update` → `/submit-proposal`). The implementing agent must encode this target check (reuse the D6 self-host detection rule) in the command body.
- **Open-questions debt** — The six load-bearing decisions (dimension scope Q1, fix boundary + in-flow context Q2, loop shape Q3, reference-doc split Q4, master-vs-child auto-fix target Q5, sub-agent invocation contract Q6) are all resolved in this proposal; none is left for the implementing agent to invent.

---

## Rollback Plan

1. `git revert <commit-sha>` on the canonical edit commit (audit command + skill, the new `audit-checker` persona, CHEATSHEET, the new `reference/audit_dimensions.md`, `reference/model_selection.md`, and the `../INFRASTRUCTURE.md` edits — all in one commit).
2. Run `/regen-framework` to propagate the command + skill + persona revert into `.claude/` (regen prunes the now-canonically-absent `audit-checker` persona from `.claude/agents/`; CHEATSHEET + the reference docs are canonical sources, not `.claude/` targets — see the Propagation plan note).
3. The `../INFRASTRUCTURE.md` revert (§3.2, §3.5, §3.9) rides the same commit revert in step 1.
4. Child-side: re-run `/import-shamt` on each installed child to restore the prior audit body. No data migration — the audit writes no artifacts.
5. Communication: note in CHANGES that the audit reverted to the 6-dimension report-only shape.

---

## Validation Considerations

Dimension hints for the Phase 2 validation loop (`/validate-artifact proposals/strengthen-framework-audit.md`):

- **Problem clarity** — The new dimensions overlap conceptually with the existing D2 (cross-doc consistency). The validator should confirm the proposal draws a clean line between D2's rules↔host agreement and the new terminology/duplication/contradiction checks, with no double-counting.
- **Change-list completeness** — The command body and the mirrored skill must change together (D2-style paired edit), **including each file's frontmatter `description`** (both currently advertise "six dimensions … D6" and "2 consecutive clean rounds" — these regenerate into the child skill registry and would otherwise become a self-inflicted D10 count-accuracy finding); the CHEATSHEET `/audit-framework` row must track the new dimension count (D1–D6 → D1–D11); the new `reference/audit_dimensions.md` must be linked from both the command and the skill (else D4 reference validity trips); the **new `audit-checker` persona (row 3) must be referenced consistently** by the command, the skill, the CHEATSHEET personas table (row 4), and the `model_selection.md` sub-agent row (row 6) — a four-way paired edit, else D3/D4 trips; `reference/model_selection.md` must gain a row for the new `audit-checker` sub-agent and refresh the Phase 6 dimension tiering (the tier table is the source of truth `/validate-artifact` and the audit both cite); and the `../INFRASTRUCTURE.md` edit must hit **all three** stale spots (§3.2 row, §3.5 table + exit line, §3.9 resolved decisions), not just §3.5/§3.9. No config-knob edit is in scope (Q2 chose always-on), so there is no `shamt-config.example.json` / CHEATSHEET-config paired edit to verify.
- **Risk coverage** — The auto-fix boundary is the highest-risk surface. The validator should stress-test the "simple" definition against adversarial examples (a one-line terminology fix that is actually load-bearing; a "broken link" whose correct target is ambiguous) and confirm borderline → intricate → proposal holds. Also confirm the **master-vs-child target check** (Q5) is unambiguous: the auto-fix track must reuse the D6 self-host detection rule so it cannot fire against a child's imported `.shamt-core/` canonical copies.
- **Rollback feasibility** — The CREATE of a new reference doc reverts cleanly; the `../INFRASTRUCTURE.md` edits are in-place text changes (no MOVE, no history loss).
- **Affected surfaces** — commands, skills, **personas** (the new `audit-checker`), references, the CHEATSHEET, and the out-of-tree planning doc `../INFRASTRUCTURE.md`. The rules template (`SHAMT_RULES.template.md`) is **not** expected to change — the audit is a command, not a rules-file pattern — and the resolved Q3 answer (audit reuses Pattern 1's exit verbatim) means the audit *cites* Pattern 1 rather than redefining it, so no rules edit is needed. Confirm that holds.
- **Sub-agent reference (D4)** — the audit now spawns an adversarial cheap-tier sub-agent on the clean round via the **new `audit-checker` persona** (resolved Q6 — a dedicated framework-sweep-scoped persona, distinct from the single-artifact-scoped `validation-checker`). The validator must confirm every reference to `audit-checker` resolves (the command body, the skill body, the CHEATSHEET personas table, and the `model_selection.md` row all name it; the file is created at `host/templates/claude/agents/audit-checker.md` by row 3), and that the new D11 scope-clarity check would not trip on the audit body or the new persona body itself.
- **Out-of-`shamt-core/` path justification** — `../INFRASTRUCTURE.md` lives one level above `shamt-core/` and is **not** a regenerated canonical source; it is the live v2 infrastructure-decision log that CLAUDE.md instructs agents to keep current "as decisions land." It is edited here for that reason, not regenerated. It will not follow `shamt-core/` when extracted to its own repo.
- **Propagation plan** — Requires `/regen-framework` after the canonical edits to render the **command + skill + the new `audit-checker` persona** into `.claude/` (`commands`, `skills`, and `agents` are the managed regen subtrees; run regen `--check` to confirm zero drift). CHEATSHEET and the reference docs (`audit_dimensions.md`, `model_selection.md`) are canonical sources, **not** `.claude/` targets — regen does not touch them. Already-installed children pick up all six in-tree edited/created files on the next `/import-shamt`, which copies canonical sources into the child's `.shamt-core/` and re-runs regen.

---

## Open Questions

*All resolved — see Resolved Questions below.*

---

## Resolved Questions

<!-- Append as questions resolve. -->

- ~~Q1: How far to expand beyond the current 6 dimensions?~~ → A: Broader +5 — add D7 Terminology consistency, D8 Content completeness, D9 Duplication/contradiction, D10 Count/claim accuracy, D11 Scope-clarity/comprehension risk. Keep D1–D6 names/numbers.
- ~~Q2: Simple-vs-intricate fix boundary + where auto-fix applies?~~ → A: Boundary = simple is mechanical/single-file/uniquely-determined (fix + verify in-loop); everything else and borderline → /propose-update. Auto-fix runs in **both** standalone and in-flow contexts; in-flow simple fixes are logged as out-of-band corrections distinct from the proposal scope.
- ~~Q3: Validation-loop shape?~~ → A: Mirror Pattern 1 exactly — 1 primary clean round + 1 adversarial Haiku sub-agent confirmation; any sub-agent finding (incl. one LOW) resets. Replaces the 2-consecutive-clean exit.
- ~~Q4: Dedicated reference doc, or inline?~~ → A: Add `reference/audit_dimensions.md` (full D1–D11 definitions, fix-track rubric with examples, known-exceptions section); keep the command + skill lean and link out. No config knob (Q2 chose always-on).
- ~~Q5: How should the auto-fix track behave when the audit target is a child project (imported canonical copies), not master?~~ → A: **Master / self-host target only.** Auto-fix fires solely when the target is master / the shamt-core self-host (detected via the D6 self-host rule). Against a child project the audit stays report-only — findings surface with an upstream-routing suggestion (`/propose-update` → `/submit-proposal`); the audit never auto-edits a child's imported `.shamt-core/` canonical copies (they would be clobbered on the next import and diverge from master).
- ~~Q6: How does the audit spawn its adversarial Haiku sub-agent — reuse `validation-checker`, inline contract, or a new persona?~~ → A: **New dedicated `audit-checker` persona** (`host/templates/claude/agents/audit-checker.md`, Haiku). `validation-checker` is single-artifact-scoped ("re-read the entire artifact"); the audit is a framework-wide D1–D11 sweep, so it gets a sweep-scoped persona with its own contract. Added as change-list row 3, referenced by the command, skill, CHEATSHEET personas table, and `model_selection.md`.

---
Validated 2026-05-30 — 5 rounds, 1 adversarial sub-agent confirmed
