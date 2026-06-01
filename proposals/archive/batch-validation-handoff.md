# Proposal: batch-validation-handoff

**Created:** 2026-05-30
**Status:** Implemented
**Proposed by:**
**Project context:**

---

## Problem

Several Shamt phases end by producing **more than one artifact that must each go through `/validate-artifact`**, and today the only guidance the producing command gives is a long sequential list of `/clear` + `/validate-artifact <path>` pairs the user must run by hand, one cleared session at a time.

The sharpest case is a **phase-decomposed framework-update plan**: `/f2-plan-update-implementation` (per [`host/templates/claude/commands/f2-plan-update-implementation.md`](../host/templates/claude/commands/f2-plan-update-implementation.md) Step 2's phase-decomposition rule) emits an index file (`{slug}_PLAN.md`) plus N `_PLAN_phase_*.md` files, **each of which is validated independently** — the index under the phase-index dimensions, each phase file under the plan dimensions. Step 4 only suggests `/clear` + `/validate-artifact` (naming the index), so the user is left to run that loop by hand once per file. A five-file plan (index + 4 phases) means five manual cleared sessions. `/sync-triage-proposals` has the same shape when several proposals are promoted in one run (Step 3 prints a per-promoted-slug `/validate-artifact` list). The Engineer flow can hit it too (e.g., an implementation plan plus a separately-validated testing plan).

The sequential-per-session design is deliberate — it respects the single-session sizing constraint (Principle 1): validating one artifact fits a context window; validating many in a single agent session risks compaction. But the **cost is pushed entirely onto the user as manual tedium**: they babysit a queue of near-identical commands. There is no canonical way for a producing phase to hand the *whole batch* to one agent that will validate every artifact correctly (each via the full Pattern 1 loop with its adversarial sub-agent) without the user driving each step.

This proposal adds a reusable **batch-validation handoff prompt**: when a flow ends with multiple artifacts to validate, the producing command emits a **ready-to-paste prompt block** (plaintext the user copies into a fresh Claude Code session) that instructs that fresh agent — the **orchestrator** — to validate each artifact, fanning the work out to one validation sub-agent per artifact so each runs in its own context (honoring single-session sizing), then reporting the aggregate result. The user delegates the batch in one paste instead of running N cleared sessions by hand. The handoff prompt is a **convenience helper, not a slug-resumable phase** — it adds no new command and does not replace the canonical per-artifact `/validate-artifact <path>` commands, which remain the resumable path (Principle 1) and the listed fallback (Q3).

---

## Proposed Changes

| # | Canonical path | Operation | One-line change description |
|---|----------------|-----------|------------------------------|
| 1 | `shamt-core/reference/batch_validation_handoff.md` | CREATE | New reference: the fill-in-the-blanks **handoff-prompt template** (lists the artifacts + each one's governing references) + the **fan-out orchestration** (per artifact the orchestrator spawns a primary validation sub-agent that reads + fixes in its own isolated context and stops at `consecutive_clean = 1` **without** spawning a checker; the orchestrator then spawns the independent `validation-checker` for that artifact (for Standard / risk-triggered artifacts — Quick-path-no-trigger artifacts skip the checker per validate-artifact's path selection; see **Mechanism details**); a checker finding re-spawns that artifact's primary — the per-artifact primary sub-agent gets inline instructions, no new persona) + when-to-emit guidance (≥2 artifacts) + the sequential-list fallback |
| 2 | `shamt-core/host/templates/claude/commands/validate-artifact.md` | EDIT | Add a short "Batch handoff" subsection: when a caller has ≥2 artifacts to validate, point to `reference/batch_validation_handoff.md` for the orchestration + prompt template (the validation primitive documents its own batch story) |
| 3 | `shamt-core/host/templates/claude/skills/validate-artifact/SKILL.md` | EDIT | Mirror the validate-artifact change |
| 4 | `shamt-core/host/templates/claude/commands/f2-plan-update-implementation.md` | EDIT | Step 4: when the plan is phase-decomposed (index + ≥1 phase file → always ≥2 validations), emit the filled handoff prompt as the **recommended** path, with a sequential per-file `/clear` + `/validate-artifact` list (index + each phase file) as the fallback — refining today's single-`{slug}_PLAN.md` suggestion to name every file the user must validate |
| 5 | `shamt-core/host/templates/claude/skills/f2-plan-update-implementation/SKILL.md` | EDIT | Mirror the f2 change |
| 6 | `shamt-core/host/templates/claude/commands/sync-triage-proposals.md` | EDIT | Step 3 summary: when ≥2 proposals were promoted, emit the filled handoff prompt (recommended) alongside the per-promoted-slug sequential list |
| 7 | `shamt-core/host/templates/claude/skills/sync-triage-proposals/SKILL.md` | EDIT | Mirror the sync-triage change |
| 8 | `shamt-core/CHEATSHEET.md` | EDIT | Document the batch-handoff option where validation is described |

**8 file operations → Phase 3 (`/f2-plan-update-implementation`) is NOT required** (threshold is 10). Paired edits move together: validate-artifact cmd↔skill (2↔3), f2 cmd↔skill (4↔5), sync-triage cmd↔skill (6↔7). The new reference (row 1) is the single source every producer cites; CHEATSHEET (8) documents the option. **No new persona** — the per-artifact primary validation sub-agent is spawned with inline instructions; the existing `validation-checker` persona is reused for the adversarial pass. (If a dedicated "validation-primary" persona later proves worthwhile, a follow-up proposal adds it.)

**Mechanism details (proposal-altitude; the full fill-in-the-blanks template text is authored at implementation per row 1).** The orchestrator is a fresh Claude Code session (the only host). It holds **only** the artifact manifest (paths + per-artifact governing references) and each sub-agent's short verdict — it **never loads artifact bodies into its own context**, so single-session sizing is honored at the orchestrator level too, not just inside the sub-agents (a 5-artifact batch does not accumulate the combined size of all five in the orchestrator). Each per-artifact **primary** runs the standard **Pattern 1 primary loop** — Steps 1–6 as defined by `/validate-artifact` (dimension-selection-by-artifact-type, rounds, in-place fixes, up to `consecutive_clean = 1`) — at the standard primary tier (Reasoning), driven by the **inline instructions in the handoff prompt** (it does *not* invoke the `/validate-artifact` command, which would auto-proceed to Step 7 and spawn its own checker — the nesting the design avoids). It **stops before the Step 7 adversarial pass**; the orchestrator then drives that pass by spawning the **checker** — the existing `validation-checker` persona at its fixed Haiku tier — keeping the whole flow within one nesting level. Whether that adversarial pass runs at all follows `/validate-artifact`'s own **path selection**: the orchestrator spawns the checker for **Standard-path or risk-triggered** artifacts and **skips** it for a Quick-path artifact with no risk trigger (which exits after the primary's clean pass, per validate-artifact Step 6 → Step 8). The two currently-wired producers (f2 decomposed plans, sync-triage promoted proposals) emit only non-story framework artifacts, which default to Standard, so the checker always runs there; path-awareness matters only for a future Quick-capable producer that adopts the reference. A checker finding **re-spawns a fresh primary** for that artifact (new context, `consecutive_clean` back to 0 — mirroring single-artifact Pattern 1's "fix and return to Step 1"), after which the orchestrator re-runs the checker; the loop repeats until a checker pass is clean, exactly as the single-artifact command loops (clean exit is the only terminator — no separate retry cap, matching the base primitive). The producer fills the template with the **actual resolved on-disk paths** at emit time (each concrete path inserted, not a blank placeholder), so the prompt is agnostic to the proposal-numbering scheme (it works whether or not `proposal-workflow-conventions` has landed).

---

## Risks

- **Regression risk** — the handoff prompt must not weaken validation rigor: each artifact still needs the full Pattern 1 loop (primary clean round + adversarial sub-agent, no one-LOW allowance). A batch orchestrator that shortcuts the loop would silently lower the bar.
- **Single-session sizing** — the whole point of the existing sequential design is to keep each validation in its own context. The handoff prompt must preserve that (fan-out: one sub-agent per artifact), not collapse N validations into one compacting session.
- **Sub-agent nesting limits** — resolved by the chosen mechanism (Q2): the **orchestrator** (a top-level agent), not the per-artifact primary sub-agent, spawns the independent `validation-checker`, so no nested-sub-agent spawn is required and adversarial independence is preserved. This **intentionally differs** from standard single-artifact `/validate-artifact`, where the primary validator (itself the top-level session agent) spawns its own checker at Step 7; in the batch case the primary *is* a sub-agent, so the checker-spawn is lifted up to the orchestrator to stay within one nesting level. The reference doc must state this explicitly so a producer doesn't naively tell a sub-agent to spawn the checker (which would attempt a second nesting level).
- **Drift risk** — the handoff-prompt template (reference doc) and every producing command that emits it must stay in sync; a producer that hand-rolls a divergent prompt defeats the single-source-of-truth goal.
- **Child-project compatibility** — additive (new reference + command guidance). Children pick it up on the next `/sync-import-shamt`; no manual reconciliation.
- **Coordination with `proposal-workflow-conventions` (in-flight)** — that proposal also edits `f2-plan-update-implementation` and `sync-triage-proposals` (command + skill). The two change sets are independent in *intent* (it changes path-resolution / numbering / branch-merge; this adds a Step-4 / Step-3-summary handoff-prompt emission) but touch the same four files. Whichever lands second must rebaseline its locate strings against the first. **Recommendation:** land `proposal-workflow-conventions` first (it is further along — validated, Phase 3 plan written) and draft this proposal's f2 / sync-triage edits (rows 4–7) against the post-merge bodies. This ordering is a **preference, not a hard precondition** — either proposal can land first; the second simply rebaselines its locate strings (rows 4–7 here, or rows 5/6/11/12 there) against the merged bodies, since the two change sets are independent in intent. Rows 1–3 (reference + validate-artifact cmd/skill) do not overlap with that proposal at all. Row 8 (CHEATSHEET) touches the *same file* as that proposal's CHEATSHEET edit (its row 13), but both are **additive, low-conflict documentation sections** (this one adds the batch-handoff option; that one adds the pinned conventions / numbered-proposal layout) — the second to land appends its subsection without clobbering the other.
- **Open-questions debt** — scope breadth, mechanism, and replace-vs-supplement are resolved in the log below before validation.

---

## Rollback Plan

1. `git revert` the squash-merge commit. The change is additive (one new reference doc + command/skill guidance edits); revert removes the reference and restores the prior "suggest sequential list" wording.
2. Run `/f4-regen-framework` to propagate the revert into `.claude/`.
3. No child-side manual action — children pick up the revert on their next `/sync-import-shamt`.

---

## Validation Considerations

- **Problem clarity** — the friction is *manual tedium*, not a correctness gap; the fix must not trade rigor for convenience. Make clear the batch orchestrator runs the *same* Pattern 1 loop per artifact.
- **Change-list completeness** — every producing command that emits the prompt must point at the single reference template (no divergent copies); validate-artifact command ↔ skill move together; the reference ↔ the commands' pointers agree.
- **Mechanism soundness** — verify the fan-out (one sub-agent per artifact) is expressible in Claude Code and that the adversarial-independence story survives nested-sub-agent limits (Q2). Assessable at the proposal altitude: the orchestrator → per-artifact primary sub-agent → orchestrator-spawned `validation-checker` topology is **one nesting level** (expressible via the Agent / Task tool), and each artifact runs its full Pattern 1 loop (primary clean round, plus the adversarial checker for Standard / risk-triggered artifacts — no one-LOW allowance). The exact fill-in-the-blanks template text is authored at implementation per row 1; the proposal does not inline it. **Implementation guard for row 1:** the template must explicitly instruct the per-artifact primary to **halt after Step 6** (reach `consecutive_clean = 1`; do not spawn its own checker), instruct the orchestrator to **apply `/validate-artifact`'s path selection per artifact** (spawn the checker for Standard / risk-triggered; skip it for Quick with no trigger), and instruct it to **re-spawn a fresh primary, then re-run the checker** on any checker finding — these instructions hold the flow at one nesting level, render the correct Pattern 1 exit per artifact, and preserve the no-one-LOW-allowance rule.
- **Single-session sizing** — confirm the mechanism keeps each artifact's validation context-isolated; it must not reintroduce the compaction the sequential design avoided. This holds at the **orchestrator** level too: the orchestrator holds only the manifest + short per-artifact verdicts and never reads artifact bodies, so it does not accumulate the combined size of all artifacts (see **Mechanism details** under Proposed Changes).
- **Affected surfaces** — new reference; validate-artifact command + skill; the producer command(s) + their skills; cheatsheet. Cross-doc: the producers' "suggest next phase" wording. `reference/validation_exit_criteria.md` was **considered and excluded** — it documents the counter / exit logic, not orchestration; the batch story lives in the new reference (row 1), cross-linked from the validate-artifact command (row 2).
- **Propagation plan** — regen required (host bodies change). No child manual nudge.

---

## Open Questions

*(none — all resolved; see the log below.)*

---

## Resolved Questions

<!-- Drafting-only log — appended as questions resolve. -->

- ~~Q1 scope breadth~~ → A: **Reference + `/f2-plan-update-implementation` + `/sync-triage-proposals`.** Build the reusable reference (row 1) + the validate-artifact pointer (rows 2–3), and wire the two framework/sync-side commands that demonstrably emit a multi-validate list today: f2 (decomposed plans) and sync-triage (multi-promote), each with its mirrored skill. Engineer-flow producers (e3/e3b) and a named SHAMT_RULES convention were considered and deferred — the reference doc is the single source any future producer cites, so generality is preserved without wiring every command now. (Resolved 2026-05-31.)
- ~~Q2 mechanism~~ → A: **Fan-out + independent checker.** The handoff prompt's receiving agent is an **orchestrator**: per artifact it spawns a primary validation sub-agent (reads + fixes in its own isolated context), then the orchestrator itself spawns the independent `validation-checker` for that artifact (when the artifact's path requires it — Standard / risk-triggered; Quick-path-no-trigger skips the checker, per validate-artifact's path selection); a checker finding re-spawns that artifact's primary. Keeps each heavy primary loop context-isolated (honors single-session sizing) **and** preserves true adversarial independence — the most faithful rendering of Pattern 1. The reference doc (row 1) specifies this orchestration; the sub-agent-nesting risk is dissolved because the orchestrator (a top-level agent), not the per-artifact sub-agent, spawns the checker. (Resolved 2026-05-31.)
- ~~Q3 replace-or-supplement~~ → A (decided by the architect, sensible default): **Supplement.** The producing command emits the filled handoff prompt as the **recommended** path for ≥2 artifacts, but still prints the sequential `/clear` + `/validate-artifact` list as the fallback for a user who prefers to drive each step. No rigor difference between the two paths.

---
Validated 2026-05-31 — 10 rounds (5 primary + 5 adversarial), final adversarial sub-agent confirmed. The first four adversarial passes surfaced findings (mechanism precision + handoff-prompt definition; f2-current-behavior accuracy; orchestrator context-load / per-artifact tier; path-aware checker spawning for Quick vs Standard; and the CHEATSHEET-overlap coordination claim); the fifth pass confirmed zero issues.
