# Model Selection

**Purpose:** one-page lookup for which Claude model tier to use where in Shamt. v2 is opinionated about model choice — every phase, persona, and skill body has a recommended tier.

Adapted from v1's SHAMT-27 (`model_selection.md`); trimmed hard for v2.

---

## Tiers

| Tier | Model | When to use |
|------|-------|-------------|
| **Cheap** | Haiku | File ops, git ops, mechanical execution, sub-agent confirmations, status rollups, intake / freeform ticket capture, test execution |
| **Balanced** | Sonnet | Code reading, structural analysis, spec research, plan creation, medium-complexity validation, formal-mode code review metadata, user-test-plan drafting |
| **Reasoning** | Opus | Primary validation loops (artifact validation), root-cause analysis, design decisions, multi-dimensional checks, formal-mode review issue-finding, design dialog (Gate 2a), epic/feature decomposition |

**Sub-agent confirmations always use Cheap tier.** These are zero-bias re-reads, not deep reasoning. See `validation_exit_criteria.md`.

---

## Per-persona pinning

| Persona | Tier | Rationale |
|---------|------|-----------|
| `plan-executor` | Cheap (Haiku) | Mechanical implementation-plan execution; no synthesis required |
| `validation-checker` | Cheap (Haiku) | Adversarial sub-agent re-read of a single artifact; fresh eyes, not depth |
| `audit-checker` | Cheap (Haiku) | Adversarial framework-sweep sub-agent for `/f5-audit-framework`'s clean round; zero-bias D1–D12 re-sweep, not depth |
| `test-executor` | Cheap (Haiku) | Runs the automated testing plan; interprets test output; diagnoses failures vs. infra flakiness |
| `user-simulator` | Balanced (Sonnet) | Phase 6 agent-as-user execution — executes `user_test_plan.md`, supplies inputs, judges observed-vs-expected; interpretive, so not Cheap |
| `review-executor` | Reasoning (Opus) | Formal-mode code review issue-finding using the 16-category framework |
| `root-cause-diagnoser` | Reasoning (Opus) | `/f1-propose-update` incident-origin root-cause diagnosis; depth analysis, not a confirmation. Its diagnosis is adversarially confirmed by a Cheap (Haiku) `validation-checker` zero-bias sub-agent, reusing the Pattern 1 Step 7 contract |

Personas declare their tier in the persona body (e.g., a frontmatter `model:` field). The defaults above stand unless a flow explicitly overrides.

---

## Per-phase guidance

| Phase | Default tier | Notes |
|-------|--------------|-------|
| 1. Intake | Cheap | Ticket fetch + freeform capture is mechanical |
| 2. Spec — research | Balanced | Code reading and structural analysis |
| 2. Spec — Gate 2a design dialog | Reasoning | Multi-option design comparison |
| 2. Spec — validation loop | Reasoning | Primary; sub-agent always Cheap |
| 3. Plan — drafting | Balanced | Structural step decomposition; mandatory for every story |
| 3. Plan — validation loop | Reasoning | Primary; sub-agent always Cheap |
| 4. Test Plan — `user_test_plan.md` drafting | Balanced | Mandatory; spec-derived agent-as-user scenario plan |
| 4. Test Plan — `testing_plan.md` drafting | Balanced | When TESTING_STANDARDS.md declares automated suites; same shape as the main plan |
| 4. Test Plan — validation loop | Reasoning | Primary; sub-agent always Cheap |
| 5. Build (`plan-executor`) | Cheap (`plan-executor`) | Mechanical plan execution by the builder persona; the architect's planning happened in Phases 3–4 and the architect only re-engages on builder-reported failure / ambiguity |
| 6. Test — agent-as-user | Balanced (`user-simulator`) | Mandatory; executes `user_test_plan.md`, driving the project as a user per TESTING_STANDARDS.md |
| 6. Test — automated suites | Cheap (`test-executor`) | When TESTING_STANDARDS.md declares automated tests |
| 7. Review (story-mode) | Balanced | 16-category sweep at the story altitude |
| 7. Review (formal-mode issue-finding) | Reasoning (`review-executor`) | Dedicated Opus persona for branch / PR review |
| 7. Review (formal-mode git metadata) | Cheap | Fetch branch commits, diff stats, file inventory; mechanical |
| 8. Polish — code edits | Balanced | Apply reviewer feedback; mechanical fixes |
| 8. Polish — root cause / upstream proposals | Reasoning | Generalize recurring feedback into framework-update proposals; multi-piece synthesis |
| 9. Finalize (`/e9-finalize-story`) | Cheap | Mechanical: evaluate the guards, scoped commit, `gh pr merge` (when `pr_provider == github`), one tracker-close command, status flip — mirrors `/f6-archive-proposal` |
| PO — Epic finalize (`/pe4-finalize`) | Cheap | Mechanical: children-done guard, tracker close, `epic.md` status flip, folder move into `epics/archive/`, commit |
| PO — Epic draft (`/pe0-draft`) | Cheap | f0-style bare idea capture: seed `epic.md` with Scratch Notes + draft status; no design judgment, no open-questions dialog (mirrors `/f0-draft-proposal`) |
| PO — Epic define (`/pe1-define`) | Balanced | Open-questions iterative dialog over Goal / Success Criteria / Scope; consults ARCHITECTURE.md; ingests a `/pe0-draft` stub when present |
| PO — Epic decompose (`/pe3-decompose`) | Balanced | Stub-list-then-drill-in batch decomposition into feature stubs; parallelization analysis; re-decomposition partition |
| PO — Feature draft (`/pf0-draft`) | Cheap | f0-style single-stub capture under an existing epic; no dialog (mirrors `/f0-draft-proposal`) |
| PO — Feature define (`/pf1-define`) | Balanced | Open-questions iterative dialog over Success Criteria + Scope; consults ARCHITECTURE.md; ingests a `/pf0-draft` stub when present |
| PO — Feature decompose (`/pf3-decompose`) | Balanced | Stub-list-then-drill-in batch decomposition into story stubs; individually-testable rubric; parallelization analysis |
| PO — Story draft (`/ps0-draft`) | Cheap | f0-style single-stub capture under an existing feature (absorbs the old tech-story fast path); no dialog |
| PO — Story define (`/ps1-define`) | Balanced | Open-questions dialog producing the engineer-ready planning ticket — a pure define/dialog stage (validation moved to the `-validate` stage); consistent with `/pe1-define` / `/pf1-define` |
| PO — Epic validate (`/pe2-validate`) | Reasoning | Thin wrapper over the `/validate-artifact` Pattern-1 loop on `epic.md`; the loop escalates to Reasoning (primary) with a Cheap `validation-checker` sub-agent, per the `/validate-artifact` row. Single mode only |
| PO — Feature validate (`/pf2-validate`) | Reasoning | Thin wrapper over `/validate-artifact` on `feature.md`; same loop tiering as the `/validate-artifact` row; a parent epic slug batch-validates all features (stateless disk-derived dispatcher) |
| PO — Story validate (`/ps2-validate`) | Reasoning | Thin wrapper over `/validate-artifact` on `ticket.md` (the inline loop moved out of `/ps1-define`); same loop tiering; a parent feature slug batch-validates all stories |
| Test-plan drafting (`/e4-write-test-plan`) | Balanced | Drafting + validation loop for the mandatory `user_test_plan.md` (always) and `testing_plan.md` (when suites exist) |
| Engineer flow — `/e-all` driver (spans Phases 1–7, through Review) | Balanced | Meta-driver: sequences phases, dispatches one sub-agent per phase, inspects each report, and pauses on each interactive gate / halts on failure. The heavy per-phase reasoning lives in the dispatched agents at their own tiers (spec / plan-validation / test-plan-validation primary Reasoning; `plan-executor` Cheap; `user-simulator` Balanced; `test-executor` / `validation-checker` Cheap; story-review primary Balanced). Child-facing analog of the `/f-all` driver row below |
| Framework update — Phase 0 (`/f0-draft-proposal`) | Cheap | Quick-capture an unrefined DRAFT proposal from a blurb: resolve a slug, seed a bare file, drop the blurb into Scratch Notes; no design judgment, no open-questions dialog |
| Framework update — Phase 1 (`/f1-propose-update`) | Balanced | Drafting a proposal: structural reading of canonical sources, naming files precisely, applying the open-questions iterative dialog |
| Framework update — Phase 2 (proposal validation via `/validate-artifact`) | Reasoning | Primary Pattern 1 loop; sub-agent (Cheap) via `validation-checker` |
| Framework update — Phase 3 (`/f2-plan-update-implementation`) | Balanced | Architect — mechanical step decomposition of the Proposed Changes table |
| Framework update — Phase 4 (`/f3-implement-update` orchestration) | Balanced | Reads proposal, applies edits inline (≤10 ops) or hands off to the builder; monitors verification |
| Framework update — Phase 4 (plan execution via `plan-executor`) | Cheap | Mechanical execution of the validated plan; identical persona contract to story-altitude builder |
| Framework update — Phase 5 (`/f4-regen-framework`) | Cheap | Wrap the regen script, surface output, run `--check` for drift; no design judgment |
| Framework update — Phase 6 (`/f5-audit-framework`) — primary loop | Reasoning | D2 (cross-doc consistency), D3 (bidirectional coverage), D5 (template-protocol alignment), D6 interpretation, D7 (terminology consistency), D9 (duplication/contradiction), D11 (scope-clarity): synthesis across many files |
| Framework update — Phase 6 mechanical sub-checks (D1, D4, D8, D10, D12) | Cheap | Running regen `--check`; walking links, template paths, profile names, persona names; grepping stray `TODO`/`TBD`/placeholders (D8); cross-checking explicit counts against reality (D10); measuring the rules file's size against its budget (D12) |
| Framework update — Phase 6 adversarial confirmation (`audit-checker`) | Cheap | Zero-bias D1–D12 re-sweep on the clean round; fresh eyes, not depth |
| Framework update — Phase 7 (`/f6-archive-proposal`) | Cheap | File move + status update |
| Framework update — `/f-all` driver (spans Phases 2–7) | Balanced | Meta-driver: sequences phases, dispatches one sub-agent per phase, inspects each report, and halts/pauses. The heavy per-phase reasoning lives in the dispatched agents at their own tiers (proposal-validation primary Reasoning; `plan-executor` Cheap; `validation-checker` Cheap; `/f4` / `/f6` Cheap). Mirrors the Phase 4 `/f3-implement-update` orchestration row |

Per-flow overrides live in skill bodies and persona definitions — that is where deviations from this table are declared. The table above is the default; check the individual skill body for the authoritative tier for a given phase.

---

## Token-cost framing

Choosing tier well is the single biggest lever on per-story cost in Shamt.

- **A single Opus validation loop costs more than 10 Haiku sub-agent passes.** Reserve Opus for primary loops, design dialog, and root-cause work.
- **A Sonnet code read costs a fraction of an Opus code read** and is usually sufficient — Opus pays off when synthesis across many pieces is required, not when reading one module.
- **Sub-agent confirmations are always Cheap.** The sub-agent's job is fresh-eyes adversarial re-read, not deep reasoning — Haiku does that as well as Opus does and costs ~10×–20× less.
- **Builders are always Cheap.** A validated implementation plan is mechanically executable; spending Opus tokens to follow steps is waste.

When in doubt, drop one tier and check the output: if quality holds, the cheaper tier was right. If quality drops, escalate back. Do not pre-emptively burn Opus tokens on a task a smaller model can finish.

---

## Sub-agent contract

Every sub-agent invocation explicitly states the tier in the prompt or the persona reference. The agent invoking a sub-agent reads `validation_exit_criteria.md` and follows the contract — including the no-LOW-allowance rule. Mis-tiering a sub-agent (e.g., spawning Sonnet for an adversarial re-read) is a configuration finding, not a quality finding; fix the tier and re-run.

---
Validated 2026-05-27 — 5 rounds, 1 adversarial sub-agent confirmed (Phase 2 reference-library loop)
Touched 2026-05-28 — added framework-update phase rows (Phase 1 `/f1-propose-update` through Phase 7 `/f6-archive-proposal`) to the per-phase guidance table. Re-validated under the Phase 8 implementation loop.
Touched 2026-06-02 — added the Phase 0 (`/f0-draft-proposal`, Cheap) row to the framework-update per-phase guidance table. Per proposals/audit-continuous-f0-draft-capture.md (change-list amended to row 11).
