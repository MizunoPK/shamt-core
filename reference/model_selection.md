# Model Selection

**Purpose:** one-page lookup for which Claude model tier to use where in Shamt. v2 is opinionated about model choice — every phase, persona, and skill body has a recommended tier.

Adapted from v1's SHAMT-27 (`model_selection.md`); trimmed hard for v2.

---

## Tiers

| Tier | Model | When to use |
|------|-------|-------------|
| **Cheap** | Haiku | File ops, git ops, mechanical execution, sub-agent confirmations, status rollups, intake / freeform ticket capture, test execution |
| **Balanced** | Sonnet | Code reading, structural analysis, spec research, plan creation, medium-complexity validation, formal-mode code review metadata, manual-test-plan drafting |
| **Reasoning** | Opus | Primary validation loops (artifact validation), root-cause analysis, design decisions, multi-dimensional checks, formal-mode review issue-finding, design dialog (Gate 2a), epic/feature decomposition |

**Sub-agent confirmations always use Cheap tier.** These are zero-bias re-reads, not deep reasoning. See `validation_exit_criteria.md`.

---

## Per-persona pinning

| Persona | Tier | Rationale |
|---------|------|-----------|
| `plan-executor` | Cheap (Haiku) | Mechanical implementation-plan execution; no synthesis required |
| `validation-checker` | Cheap (Haiku) | Adversarial sub-agent re-read of a single artifact; fresh eyes, not depth |
| `audit-checker` | Cheap (Haiku) | Adversarial framework-sweep sub-agent for `/f5-audit-framework`'s clean round; zero-bias D1–D11 re-sweep, not depth |
| `test-executor` | Cheap (Haiku) | Runs the testing plan; interprets test output; diagnoses failures vs. infra flakiness |
| `review-executor` | Reasoning (Opus) | Formal-mode code review issue-finding using the 16-category framework |

Personas declare their tier in the persona body (e.g., a frontmatter `model:` field). The defaults above stand unless a flow explicitly overrides.

---

## Per-phase guidance

| Phase | Default tier | Notes |
|-------|--------------|-------|
| 1. Intake | Cheap | Ticket fetch + freeform capture is mechanical |
| 2. Spec — research | Balanced | Code reading and structural analysis |
| 2. Spec — Gate 2a design dialog | Reasoning | Multi-option design comparison |
| 2. Spec — validation loop | Reasoning | Primary; sub-agent always Cheap |
| 3. Plan — drafting | Balanced | Structural step decomposition |
| 3. Plan — validation loop | Reasoning | Primary; sub-agent always Cheap |
| 3. Plan — `testing_plan.md` drafting | Balanced | Same shape as the main plan |
| 4. Build (Quick path) | Balanced | Primary agent executes inline |
| 4. Build (Standard path) | Cheap (`plan-executor`) | Mechanical plan execution by the builder persona; the architect's planning happened in Phase 3 and the architect only re-engages on builder-reported failure / ambiguity |
| 5. Test | Cheap (`test-executor`) | Runs the suite and interprets output |
| 6. Review (story-mode) | Balanced | 16-category sweep at the story altitude |
| 6. Review (formal-mode issue-finding) | Reasoning (`review-executor`) | Dedicated Opus persona for branch / PR review |
| 6. Review (formal-mode git metadata) | Cheap | Fetch branch commits, diff stats, file inventory; mechanical |
| 7. Polish — code edits | Balanced | Apply reviewer feedback; mechanical fixes |
| 7. Polish — root cause / upstream proposals | Reasoning | Generalize recurring feedback into framework-update proposals; multi-piece synthesis |
| Manual-test-plan drafting (`/e5b-write-manual-testing-plan`) | Balanced | Drafting + validation loop per `§1.15` |
| Framework update — Phase 0 (`/f0-draft-proposal`) | Cheap | Quick-capture an unrefined DRAFT proposal from a blurb: resolve a slug, seed a bare file, drop the blurb into Scratch Notes; no design judgment, no open-questions dialog |
| Framework update — Phase 1 (`/f1-propose-update`) | Balanced | Drafting a proposal: structural reading of canonical sources, naming files precisely, applying the open-questions iterative dialog |
| Framework update — Phase 2 (proposal validation via `/validate-artifact`) | Reasoning | Primary Pattern 1 loop; sub-agent (Cheap) via `validation-checker` |
| Framework update — Phase 3 (`/f2-plan-update-implementation`) | Balanced | Architect — mechanical step decomposition of the Proposed Changes table |
| Framework update — Phase 4 (`/f3-implement-update` orchestration) | Balanced | Reads proposal, applies edits inline (≤10 ops) or hands off to the builder; monitors verification |
| Framework update — Phase 4 (Standard path execution via `plan-executor`) | Cheap | Mechanical execution of the validated plan; identical persona contract to story-altitude builder |
| Framework update — Phase 5 (`/f4-regen-framework`) | Cheap | Wrap the regen script, surface output, run `--check` for drift; no design judgment |
| Framework update — Phase 6 (`/f5-audit-framework`) — primary loop | Reasoning | D2 (cross-doc consistency), D3 (bidirectional coverage), D5 (template-protocol alignment), D6 interpretation, D7 (terminology consistency), D9 (duplication/contradiction), D11 (scope-clarity): synthesis across many files |
| Framework update — Phase 6 mechanical sub-checks (D1, D4, D8, D10) | Cheap | Running regen `--check`; walking links, template paths, profile names, persona names; grepping stray `TODO`/`TBD`/placeholders (D8); cross-checking explicit counts against reality (D10) |
| Framework update — Phase 6 adversarial confirmation (`audit-checker`) | Cheap | Zero-bias D1–D11 re-sweep on the clean round; fresh eyes, not depth |
| Framework update — Phase 7 (`/f6-archive-proposal`) | Cheap | File move + status update |

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
