# Proposal: flow-progress-visibility

**Created:** 2026-05-30
**Status:** Draft
**Proposed by:**
**Project context:**

---

## Problem

Shamt's resumability model is **per-artifact**: a `{slug}` resolves to a folder, and a fresh agent reads the on-disk artifacts to infer where a flow stands (`ticket.md` present → Intake done; `spec.md` present → Spec done; etc.). This works well *within* a single slugged artifact's lifecycle. It breaks down in two places, and a real incident just exposed both:

1. **Slugless commands have no flow context.** The framework-update flow's Phase 5 (`/f4-regen-framework`) and Phase 6 (`/f5-audit-framework`) are **slugless** — they take no proposal slug, so they cannot resolve "which flow am I in and what phase comes next" from a folder the way the slugged Engineer/PO commands can. The regen command's Step 5 (`host/templates/claude/commands/f4-regen-framework.md`) asks the agent to distinguish "in the framework-update flow" from "standalone regen" — but gives the agent **no on-disk signal to tell which case applies**. It defaults to the agent's conversational memory, which is exactly what the phase-per-command + `/clear`-between-phases design throws away.

2. **A flow's phase position is not recorded on disk.** A proposal's `Status:` header (`proposals/_template.md`) is `Draft` at authoring and only flips to `Implemented` at `/f6-archive-proposal`. Through Phases 2–6 (validate → plan → implement → regen → audit) the header never moves. There is no durable, agent-readable record that says "this proposal's implementation has landed; regen is done; the audit is the required next step." A fresh agent (post-`/clear`) or a *different session* picking up the work cannot see the flow's true position.

**The incident:** immediately after `/f3-implement-update` landed the `flow-phase-command-prefixes` rename and `/f4-regen-framework` propagated it, the regen agent — having no on-disk flow-state to read — reported the regen as a **standalone** run and told the user the post-implementation audit was *"optional, not a gated step."* In fact this was Phase 5 of an in-flight framework-update flow, and Phase 6 (`/f5-audit-framework`) is the **required** post-implementation verification of that flow (`host/templates/claude/commands/f5-audit-framework.md` Step 6: "When inside the framework-update flow … suggest … `/f6-archive-proposal {slug}`" — i.e., audit-then-archive is the defined tail). The agent under-prompted the required next phase because it had no way to know it was mid-flow.

The fix has two coupled halves: (a) give flows a durable, on-disk notion of **where they are** that survives `/clear` and is visible to any session, and (b) make the post-implementation **audit a stated-required phase** that a slugless regen surfaces as required (not optional) whenever a framework-update flow is in flight. Both are resolved below: a single advisory **flow-state ledger** (`active_flows.md`) records every flow's current phase across the Engineer, PO, and framework-update flows; the framework-update gating commands read it to enforce the required audit.

---

## Proposed Changes

The mechanism is a single, gitignored, **advisory flow-state ledger** that every phase command stamps and that slugless commands and fresh/other-session agents read. The ledger is defined once in a new reference doc; the rules introduce it (reconciling the "no state file" principle into an advisory-index distinction); each phase command gains a uniform stamping step; the three framework-update tail commands (`f4`/`f5`/`f6`) gain the audit-required gate.

**Ledger shape (defined normatively in the new `reference/flow_state_ledger.md`):**

- **Location:** `.shamt-core/active_flows.md` in a child project; `active_flows.md` at the repo root in the shamt-core master self-host (no `.shamt-core/` there). Gitignored in both; created on first use by the first phase command that stamps.
- **Format:** one markdown table; one row per in-flight flow: `flow | slug | phase | updated`.
- **Lifecycle:** each phase command **upserts** its flow's row (match on `slug`) with the new phase + date on completion; the flow's terminal command removes the row. The framework-update terminal is unambiguous — `/f6-archive-proposal` removes the row. The Engineer and PO flows have **no single terminal command**: the Engineer flow loops review (`e6`) ↔ polish (`e7`) and can emit `review_v2/v3`, so removing on every `e7` run would churn (a re-review re-adds the row); the PO flow fans out (one epic → many features → many stories, each its own slug/row) and `p4` emits story stubs that continue *into* the Engineer flow rather than terminating. **`reference/flow_state_ledger.md` (row 1) must therefore define the removal trigger per flow** — what counts as "complete" for the looping Engineer flow and the fan-out PO flow — rather than assuming a single terminal command. Because the ledger is advisory, an Engineer/PO row that lingers or is removed early degrades to "no worse than today," so this is a correctness-of-record concern, not a build-safety one. Re-running a flow with the same slug overwrites the existing row. Abandoned rows are pruned manually (timestamped so staleness is visible) — there is no garbage collector and no `/status` command (read the file directly).
- **Authority:** **advisory index only.** The home artifacts (proposal, ticket, spec, plan, …) remain the authoritative state; the ledger is a passive convenience pointer, never an orchestrator. This framing is what keeps it consistent with Principle 1.

**Illustrative reconciliation (non-binding — Phase 4 finalizes the exact prose; rows 2–3 apply this framing).** Principle 1's "No state file, no orchestrator memory. State lives in the filesystem." is *reframed, not deleted*: the on-disk home artifacts remain the single authoritative state and no command is *driven* by a stored cursor; the advisory ledger is permitted as a **passive, derived index** that mirrors what the artifacts already imply and is never consulted in preference to them. The line that resolves the anti-pattern: a forbidden *state file* is the **sole authority a flow cannot proceed without**, and one that — if lost or wrong — silently yields a wrong result. The ledger is **advisory and derived**: *two* gates read it — `/f4-regen-framework`'s mid-flow check (row 4) and `/f6-archive-proposal`'s audit-required check (row 6) — and **both degrade gracefully when it is missing or stale, never to a silently-wrong build.** f4 without the ledger falls back to today's behavior — it cannot prove it is mid-flow, so it under-states the audit; that is "no worse than today" (the very status quo this proposal improves on, not a regression it introduces), and the present-ledger case is the *improvement*. f6 without the ledger falls back to the documented user-confirmation override (row 6); the authoritative fact — *did `/f5-audit-framework` run clean?* — stays derivable from the audit's own output and knowable to the user, so f6's *correct outcome* is preserved and only the *automation* is lost. The validator can check the eventual rows-2–3 wording against this test: (1) do the home artifacts — and, for the audit gate, the audit's own result — stay the sole authority, with the ledger never more than a derived cache; and (2) does losing the ledger only *degrade* each reader (f4 → status-quo guidance, f6 → manual confirmation), never flip a gate to a silently-wrong outcome? Advisory-and-derived holds iff both are true — which is also why a missed or wrong stamp is "no worse than today," not a corrupt build.

> Path discipline: canonical sources only — never `.claude/`. The ledger file itself is **runtime state, not a template**, so it lives under no `host/templates/` path; only its *contract* is canonical.

### A. New reference doc

| # | Canonical path | Operation | One-line change description |
|---|----------------|-----------|------------------------------|
| 1 | `reference/flow_state_ledger.md` | CREATE | The single source of truth for the ledger: location-per-context, table schema, upsert/remove lifecycle, staleness handling, the advisory-index framing, and the read contract for slugless commands + fresh agents. |

### B. Principle reconciliation (rules + master-dev primer)

| # | Canonical path | Operation | One-line change description |
|---|----------------|-----------|------------------------------|
| 2 | `templates/SHAMT_RULES.template.md` | EDIT | Principle 1 ("Phase-per-command + slug resumability"): introduce the advisory flow-state ledger as a **complement** to slug-resumability (not a contradiction) — every phase command stamps it, fresh agents read it, home artifacts stay authoritative; link `reference/flow_state_ledger.md`. Add a one-line statement of the framework-update audit-required gate. |
| 3 | `CLAUDE.md` (shamt-core master-dev primer) | EDIT | Reconcile its Principle-1 "No mega-orchestrator, no state file" wording the same way — distinguish an advisory ledger from an orchestrator state file so the framework does not self-contradict (would be a D9 finding otherwise). |

### C. Framework-update tail — the audit-required gate

| # | Canonical path | Operation | One-line change description |
|---|----------------|-----------|------------------------------|
| 4 | `host/templates/claude/commands/f4-regen-framework.md` | EDIT | Step 5: read the ledger; when a framework-update flow is mid-flight, state the audit is **REQUIRED** (not "optional") before the flow completes. Stamp the slug's row `regen-done, audit-pending`. The ledger is f4's mid-flow signal, **not a hard dependency**: if it is absent (deleted / first run), f4 cannot prove mid-flow and degrades to its current standalone-default behavior — "no worse than today," never a wrong gate. f4 must not *assume* mid-flow without the ledger row. |
| 5 | `host/templates/claude/commands/f5-audit-framework.md` | EDIT | Step 6: on a clean exit, stamp the slug's row `audited-clean` (this is what archive's gate reads). |
| 6 | `host/templates/claude/commands/f6-archive-proposal.md` | EDIT | **Refuse to archive** until the ledger shows `audited-clean` for the slug — replacing the current "Recommended (not enforced)" precondition (`f6-archive-proposal.md` Prerequisites). Document a manual-override path broad enough to preserve **every** legitimate archive-despite-not-clean case f6 currently allows: not only "the audit routed an intricate finding to a new proposal," but also the user consciously accepting lingering findings that are out of scope for this proposal. The override must keep the existing latitude — the gate guards against *skipping* the audit, not against an informed decision to archive anyway. **Override mechanism:** an explicit user confirmation recorded in chat (consistent with Shamt's agent-prose command style — no CLI flag or header field); f6 surfaces the block and its reason, and proceeds only on the user's informed go-ahead. Remove the slug's ledger row on successful archive. |
| 7 | `host/templates/claude/commands/f1-propose-update.md`, `f2-plan-update-implementation.md`, `f3-implement-update.md` | EDIT | Uniform stamping at each phase (`proposed`, `plan-validated`, `implementing` / `implemented, regen-pending`). |

### D. Uniform ledger stamping — Engineer + PO + cross-cutting commands

| # | Canonical path | Operation | One-line change description |
|---|----------------|-----------|------------------------------|
| 8 | Engineer commands `e1-start-story.md`, `e2-define-spec.md`, `e3-plan-implementation.md`, `e3b-write-testing-plan.md`, `e4-execute-plan.md`, `e5-execute-tests.md`, `e5b-write-manual-testing-plan.md`, `e6-review-changes.md`, `e7-resolve-feedback.md` | EDIT | Each stamps its flow's row with its phase on completion (per the reference contract). Row **removal** at Engineer-flow completion follows the per-flow terminal condition defined in `reference/flow_state_ledger.md` (row 1) — **not** a naive "every `e7` run removes the row," since review (`e6`) ↔ polish (`e7`) can loop. |
| 9 | PO commands `p1-start-epic.md`, `p2-decompose-epic.md`, `p3-start-feature.md`, `p4-decompose-feature.md` | EDIT | Each stamps its flow's row on completion. |
| 10 | `host/templates/claude/commands/validate-artifact.md` | EDIT | Stamp the validated slug's row `validated` where validation acts as a flow phase (Engineer Gate 2b, framework-update Phase 2). |

### E. Mirrored skills

| # | Canonical path | Operation | One-line change description |
|---|----------------|-----------|------------------------------|
| 11 | `host/templates/claude/skills/*/SKILL.md` (the mirrors of every command edited in C/D) | EDIT | Keep the strict command↔skill mirror: where a skill's summary states phase transitions or the flow tail (at minimum the `f4`/`f5`/`f6` skills, which name the audit/archive sequence), update it to match the new gate + stamping. Skills whose summary only says "follow the canonical command body verbatim" need no change. |

### F. Host wiring doc

| # | Canonical path | Operation | One-line change description |
|---|----------------|-----------|------------------------------|
| 12 | `CHEATSHEET.md` | EDIT | Document the flow-state ledger (location, schema, read-the-file discovery), the framework-update audit-required gate, and the archive hard-block. |

### G. Persistence plumbing

| # | Canonical path | Operation | One-line change description |
|---|----------------|-----------|------------------------------|
| 13 | `.gitignore` (master, `shamt-core/.gitignore`) | EDIT | Ignore the master self-host ledger (`active_flows.md`). |
| 14 | `init-shamt.sh` | EDIT | Add `.shamt-core/active_flows.md` to the child's gitignore handling on install; do **not** seed the file (created on first use). |
| 15 | `import-shamt.sh` | EDIT (verify-first) | Confirm the ledger is neither overwritten by the canonical-import sync set nor pruned by regen (it is runtime state, outside both); add a preserve note only if inspection shows a collision. |

**Phase 3 required — file count far exceeds 10.** The rows above name every *category* of edit and the authoritative ledger contract; the exact per-file / per-line stamping step (especially the uniform §D edits and the §E mirror sweep) is produced by `/f2-plan-update-implementation flow-progress-visibility` before `/f3-implement-update`.

**Out of scope (non-canonical / working docs):** the v2-dev-container `../CLAUDE.md` and `../INFRASTRUCTURE.md` state the old "no state file" principle and would now read as stale, but they are not in the `shamt-core/` sync set or the regenerated framework, so they are **not** change-table rows (consistent with the `flow-phase-command-prefixes` precedent). The implementer may optionally refresh the container primer's resumability bullet for currency.

**Out of scope (deliberate flow exclusion):** the child↔master **sync flow** (`sync-import-shamt`, `sync-submit-proposal`, `sync-triage-proposals`) is intentionally **not** ledger-stamped. Per OQ1 the ledger spans the three multi-phase, `/clear`-resumable flows (Engineer, PO, framework-update); the sync commands are one-shot operations (a single pull / a single hand-off / a master-side queue walk) with no multi-phase resumable position for a slugless or fresh agent to misread, so they fall outside the mechanism's purpose. Row 11's "mirrors of every command edited in C/D" therefore does not reach the sync-* skills (they mirror no C/D command).

---

## Risks

- **Anti-pattern tension (the headline risk).** The ledger is precisely the "state file" `CLAUDE.md` and `SHAMT_RULES.template.md` Principle 1 caution against. If agents start trusting the ledger *over* the home artifacts, it becomes a drifting second source of truth — the exact failure the original principle was written to prevent. Mitigated by the advisory-index framing (home artifacts authoritative, ledger passive), the principle reconciliation (rows 2–3), and removal-on-completion. Residual risk flagged for the validator: confirm the reconciled wording genuinely removes the contradiction rather than papering over it.
- **Regression — stamping coverage.** Every phase command across three flows gains a stamping step; a command that forgets to stamp, or stamps the wrong phase, desyncs the ledger from reality and a slugless `f4`/`f6` then mis-gates. Mitigated by defining the contract once in `reference/flow_state_ledger.md` and enumerating each command's step in the Phase 3 plan; and by the ledger being advisory (a stale row degrades to "no worse than today," not a wrong build).
- **Archive hard-gate false block.** `/f6-archive-proposal` refusing until `audited-clean` is correct when the audit simply hasn't run — but two legitimate cases must not deadlock: (a) the audit routed an intricate finding to a new proposal (so it can never reach clean for *this* slug), and (b) the user consciously accepts lingering out-of-scope findings, which f6 explicitly permits today ("does not block on the audit … accept lingering findings that are out of scope"). Both require the documented manual-override of row 6; the gate must enforce "don't *skip* the audit" without removing f6's existing latitude to archive on an informed decision.
- **Staleness / abandonment.** No GC and no `/status` command: an abandoned flow leaves a stale row until manually pruned. Mitigated by timestamps (staleness is visible) and same-slug overwrite on restart. Accepted as a known limitation; a GC/status helper is a possible follow-up, deliberately out of scope here.
- **Drift risk.** The ledger file is gitignored runtime state and is **not** regenerated, so it introduces no canonical↔`.claude/` drift of its own. The canonical edits (reference doc, command bodies, rules, CHEATSHEET, scripts) do require the standard `/f4-regen-framework` + `--check`.
- **Child-project compatibility.** Existing children pick up the new command bodies on the next `/sync-import-shamt` + regen, but the gitignore entry for `.shamt-core/active_flows.md` only lands automatically on *new* installs (row 14). Already-installed children need the one-line gitignore add — a small manual nudge, noted in the propagation plan.
- **Open-questions debt.** Resolved in full below (OQ1–OQ5); none deferred to the implementer.

---

## Rollback Plan

1. `git revert <commit-sha>` on the canonical-edit commit (the reference doc, rules/primer reconciliation, all command/skill edits, CHEATSHEET, and script/gitignore changes land together).
2. Re-run regen to restore the prior command/skill bodies in `.claude/` — **invoke the script directly** (`bash scripts/regenerate-framework.sh`) since the slugless command bodies themselves are being reverted.
3. Delete any `active_flows.md` ledgers (master root and/or child `.shamt-core/`). They are gitignored local runtime state — safe to remove with no history impact.
4. Child-side: each installed child re-runs `/sync-import-shamt` (or `bash shamt-core/import-shamt.sh`) to pick up the revert; remove the gitignore line and any local ledger.
5. Communication: the `git revert` commit message records the change; children pick it up on the next import (git history is the record — `CHANGES.md` no longer exists per `deprecate-changes-md`).

---

## Validation Considerations

Dimension hints for the Phase 2 validation loop (`/validate-artifact proposals/flow-progress-visibility.md`).

- **Problem clarity** — confirm the two-halves framing (slugless-commands-have-no-context + phase-not-recorded-on-disk) maps cleanly onto the two-halves fix (ledger + audit gate), and that the ledger's "advisory, not authoritative" stance is unambiguous.
- **Change-list completeness** — the highest-risk dimension. (1) Every phase command across all three flows must gain stamping — verify none of e1–e7/e3b/e5b, p1–p4, f1–f6, or validate-artifact is omitted. (2) The three framework-update tail commands (f4 state-required, f5 stamp-clean, f6 hard-gate+remove-row) carry asymmetric special behavior beyond uniform stamping — confirm all three are present and mutually consistent (f5 writes the token f6 reads). (3) The mirrored-skill invariant (row 11) — any skill whose summary states the flow tail must move with its command.
- **Risk coverage / D9 contradiction** — the central check: confirm rows 2–3 actually reconcile the "no state file / no orchestrator" principle in **both** `SHAMT_RULES.template.md` and shamt-core `CLAUDE.md` consistently, so the framework no longer contradicts itself once the ledger exists.
- **Cross-doc consistency (D2)** — the audit-required gate must read identically across the f4 body, f5 body, f6 body, the rules statement, and the CHEATSHEET note.
- **Rollback feasibility** — the ledger is gitignored runtime state (deletable); confirm nothing in the change makes revert harder than a single `git revert` + regen + ledger delete.
- **Affected surfaces** — rules, a new reference doc, 20 commands (9 Engineer: e1–e7 + e3b + e5b; 4 PO: p1–p4; 6 framework-update: f1–f6; plus validate-artifact) + mirrored skills, CHEATSHEET, scripts (`init-shamt.sh`, `import-shamt.sh`, `.gitignore`); **no** artifact templates and **no** change to the proposal `Status:` lifecycle (the ledger, not the Status header, carries phase). Out-of-canonical container docs (`../CLAUDE.md`, `../INFRASTRUCTURE.md`) are excluded by precedent.
- **Propagation plan** — requires `/f4-regen-framework` + `--check` after edits; each installed child needs `/sync-import-shamt` plus the one-line gitignore add for already-installed children.

---

## Open Questions

_(none — all resolved; see Resolved Questions)_

---

## Resolved Questions

<!-- Append as questions resolve. One line each. -->

- ~~OQ1: Narrow audit-gate fix, framework-update only — or a general flow-progress mechanism across all three flows?~~ → A: **General flow-progress mechanism spanning Engineer, PO, and framework-update flows.** One consistent mechanism addresses the root cause everywhere (per-artifact resumability gives no flow-position record that survives `/clear` or crosses sessions); the audit-required-after-regen gate is its first concrete application.
- ~~OQ2: Live concurrent-session awareness (markers/locks) or durable flow-phase position a later/fresh agent reads?~~ → A: **Durable flow-phase position — no locks, no heartbeats.** Sequential handoff via on-disk state that survives `/clear` and is readable by any session. Stays within Shamt's on-disk-artifact philosophy and avoids the "state file / orchestrator" anti-pattern; covers the incident (a slugless regen reading where the flow stands).
- ~~OQ3: Phase header + /status command, phase header only, or a dedicated ledger file?~~ → A: **Dedicated flow-state ledger file** (`active_flows.md`). Every phase command appends/updates its `{flow, slug, phase, timestamp}` row; slugless commands (regen/audit) read it directly to learn they are mid-flow; completion/archive removes the row. One read gives the whole cross-flow picture. **Consequence (handled in this proposal):** `CLAUDE.md` (+ shamt-core primer) and `SHAMT_RULES.template.md` Principle 1 say "no state file, no orchestrator that has to remember where you are." The ledger is reconciled as an **advisory index** (passive, stamped by each command, never authoritative — home artifacts stay authoritative) so the framework does not self-contradict; the principle wording is edited to carve out the distinction.
- ~~OQ4: Audit-required — state it only, hard-gate at archive, or both?~~ → A: **Both — state required + archive enforces.** (1) `/f4-regen-framework` reads the ledger; when a framework-update flow is mid-flight it states the audit is **REQUIRED** (not optional). (2) `/f6-archive-proposal` **refuses to archive** until the ledger shows `/f5-audit-framework` ran clean for that slug. Two enforcement points so the required audit cannot be skipped by accident.
- ~~OQ5: Is the ledger committed shared state or local working state?~~ → A: **Local working state — gitignored**, at `.shamt-core/active_flows.md` (child) / `active_flows.md` repo root (master self-host), created on first use. Per-developer; survives `/clear` and separate same-machine sessions; no merge conflicts on a churny state file; matches the "any session" (not cross-developer) intent of OQ2. Adds a `.gitignore` line + `init-shamt.sh` install handling; the file is not seeded.

---

<!-- Phase 2 validation appends the footer below on a clean exit. Do not pre-fill. -->

---
Validated 2026-05-30 — 5 rounds, 1 adversarial sub-agent confirmed
