# Implementation Plan — Phase 5: Docs + status line + audit dimension

**Proposal:** `proposals/21-formalize-testing-standards-and-stages.md`
**Index:** `proposals/21-formalize-testing-standards-and-stages_PLAN.md`
**Phase:** 5 of 5 — final cleanup: `README.md`, `CLAUDE.md`, `host/templates/claude/statusline.sh`
(phase-count logic), `reference/audit_dimensions.md`. Brings the docs + the status line + the audit's
D10 expectation in line with **required** testing and the **three** project docs.
**Depends on:** Phases 1–4 (describes the now-final behavior). **Executor:** `plan-executor`
(`statusline.sh` is `bash -n`-checked + rendered-output verified).

## Files manifest

`README.md`, `CLAUDE.md`, `host/templates/claude/statusline.sh`, `reference/audit_dimensions.md`. All EDIT.

## Review Prevention Gate Mapping

| Gate | Applies? | Plan Step(s) | Verification | N/A reason |
|------|----------|--------------|--------------|------------|
| Regulated / sensitive data | No | — | — | Canonical docs/statusline/reference edits; no data handling. |
| Tenant isolation | No | — | — | No multi-tenant code. |
| Auth / route contract | No | — | — | No auth/route surface. |
| Database read/write | No | — | — | No database access. |
| Infrastructure / deployment | No | — | — | No infra/deploy changes (statusline is a render-only script). |
| Frontend safety | No | — | — | No frontend code. |
| Testing / test data | Yes | Step 1 | `bash -n statusline.sh` + render Standard/Quick fixtures (Step 1 Verification). | — |
| Removed/weakened checks | Yes | Step 1, Step 2, Step 3c | `grep -c '"testing"'`/`grep -c 'TESTING_ENABLED'` → 0 (Step 1); whole-change `grep` sweep (final Verification) confirms the dropped config flag is fully removed, not merely bypassed. | — |

---

## Step 1 — `host/templates/claude/statusline.sh`: phase count by path, not the flag

The status line currently selects a 7- vs 8-phase numbering scheme by **reading the `testing` config flag**
into `TESTING_ENABLED`, then consumes that variable in four phase branches (Finalize/Polish/Review ternaries
+ the Test branch guard). With required testing the scheme is determined by **path**: Quick = 7 phases (no
Plan), Standard = 8 phases (Standard adds Phase 3 Plan). Test is now Phase 5 on Standard / Phase 4 on Quick
and **always present** past Build. The three sub-edits below remove the config read, introduce a path flag, and
rewrite every consuming branch. Implementation-plan presence (the path signal) is detectable with the existing
`has_any_artifact implementation_plan` helper (defined line 111), which is only in scope inside the
story-rendering block — so the path flag is computed there (sub-edit 1c), not at the top of the script.

1a — Locate (lines 37–44):
```
# ---- Numbering scheme (testing enabled = 8 phases, disabled = 7 phases) -----
#
# Engineer flow expands when `testing: "enabled"`:
#   enabled : Intake(1) Spec(2) Plan(3) Build(4) Test(5)  Review(6) Polish(7) Finalize(8)
#   disabled: Intake(1) Spec(2) Plan(3) Build(4)          Review(5) Polish(6) Finalize(7)
#
# Default to the 7-phase scheme so projects without .shamt-core/shamt-config.json (or with
# testing absent / disabled) get the correct numbering shown by default.
```
Replace with:
```
# ---- Numbering scheme (Quick path = 7 phases, Standard path = 8 phases) -----
#
# Testing is a REQUIRED phase (Test) on every story past Build. The phase count is
# determined by PATH, not a config flag:
#   Standard: Intake(1) Spec(2) Plan(3) Build(4) Test(5) Review(6) Polish(7) Finalize(8)
#   Quick   : Intake(1) Spec(2)         Build(3) Test(4) Review(5) Polish(6) Finalize(7)
#
# Standard adds Phase 3 (Plan); Quick has no Plan. Detect Standard by the presence
# of an implementation plan in the resolved story folder (`has_any_artifact
# implementation_plan`); otherwise Quick. Default to Quick so projects without a
# plan artifact get the correct numbering shown by default.
```
1b — Locate (lines 46–55):
```
TESTING_ENABLED=0
# Require the key to be preceded by a JSON object boundary (`{`, `,`, or
# whitespace including a newline). This handles both pretty-printed and compact
# JSON shapes while still rejecting incidental occurrences inside string values
# (JSON forbids unescaped quotes inside strings, so the boundary check is
# sufficient in practice).
if [ -f .shamt-core/shamt-config.json ] \
   && grep -qzE '[{,[:space:]]"testing"[[:space:]]*:[[:space:]]*"enabled"' .shamt-core/shamt-config.json 2>/dev/null; then
  TESTING_ENABLED=1
fi
```
Replace with:
```
# Phase numbering is determined by PATH, not a config flag. The path flag
# (STANDARD_PATH) is computed inside the story-rendering block below, where the
# `has_any_artifact` helper that detects the implementation plan is in scope.
```
(The block is deleted; the config read and the `TESTING_ENABLED` variable are removed entirely. The path flag
is introduced in 1c, scoped to the story block.)
1c — Locate the phase-detection cascade (lines 122–148):
```
  PHASE_NUM=""
  PHASE_NAME=""

  if [ -f "$ACTIVE_STORY_DIR/ticket.md" ] && grep -qE '\*\*Status:.*Done' "$ACTIVE_STORY_DIR/ticket.md" 2>/dev/null; then
    # Finalize is terminal: /e8-finalize-story writes **Status: Done** into
    # ticket.md (profile-independent signal). Checked first — it outranks every
    # earlier-phase artifact a finalized story still carries on disk.
    PHASE_NAME=Finalize
    PHASE_NUM=$([ "$TESTING_ENABLED" -eq 1 ] && echo 8 || echo 7)
  elif [ -f "$ACTIVE_STORY_DIR/feedback/addressed_feedback.md" ]; then
    PHASE_NAME=Polish
    PHASE_NUM=$([ "$TESTING_ENABLED" -eq 1 ] && echo 7 || echo 6)
  elif compgen -G "$ACTIVE_STORY_DIR/feedback/review_v*.md" >/dev/null 2>&1; then
    PHASE_NAME=Review
    PHASE_NUM=$([ "$TESTING_ENABLED" -eq 1 ] && echo 6 || echo 5)
  elif [ "$TESTING_ENABLED" -eq 1 ] && has_any_artifact testing_plan; then
    # testing_plan only signals Test phase when testing is opted in. When
    # testing is disabled, no Test phase exists and any stray testing_plan.md
    # is treated as Plan-phase scaffolding.
    PHASE_NUM=5; PHASE_NAME=Test
  elif has_any_artifact implementation_plan; then
    PHASE_NUM=3; PHASE_NAME=Plan
  elif has_any_artifact spec; then
    PHASE_NUM=2; PHASE_NAME=Spec
  elif [ -f "$ACTIVE_STORY_DIR/ticket.md" ]; then
    PHASE_NUM=1; PHASE_NAME=Intake
  fi
```
Replace with:
```
  PHASE_NUM=""
  PHASE_NAME=""

  # Path detection: Standard iff an implementation plan exists in this story folder
  # (Standard adds Phase 3 Plan → 8 phases; Quick has no Plan → 7).
  STANDARD_PATH=0
  if has_any_artifact implementation_plan; then STANDARD_PATH=1; fi

  if [ -f "$ACTIVE_STORY_DIR/ticket.md" ] && grep -qE '\*\*Status:.*Done' "$ACTIVE_STORY_DIR/ticket.md" 2>/dev/null; then
    # Finalize is terminal: /e8-finalize-story writes **Status: Done** into
    # ticket.md (profile-independent signal). Checked first — it outranks every
    # earlier-phase artifact a finalized story still carries on disk.
    PHASE_NAME=Finalize
    PHASE_NUM=$([ "$STANDARD_PATH" -eq 1 ] && echo 8 || echo 7)
  elif [ -f "$ACTIVE_STORY_DIR/feedback/addressed_feedback.md" ]; then
    PHASE_NAME=Polish
    PHASE_NUM=$([ "$STANDARD_PATH" -eq 1 ] && echo 7 || echo 6)
  elif compgen -G "$ACTIVE_STORY_DIR/feedback/review_v*.md" >/dev/null 2>&1; then
    PHASE_NAME=Review
    PHASE_NUM=$([ "$STANDARD_PATH" -eq 1 ] && echo 6 || echo 5)
  elif has_any_artifact agent_test_session || has_any_artifact testing_plan; then
    # Test is a REQUIRED phase on every story past Build. The agent-as-user run
    # log (agent_test_session.md) signals it always; testing_plan.md is a
    # secondary automated signal. Numbered 5 on Standard, 4 on Quick.
    PHASE_NAME=Test
    PHASE_NUM=$([ "$STANDARD_PATH" -eq 1 ] && echo 5 || echo 4)
  elif has_any_artifact implementation_plan; then
    PHASE_NUM=3; PHASE_NAME=Plan
  elif has_any_artifact spec; then
    PHASE_NUM=2; PHASE_NAME=Spec
  elif [ -f "$ACTIVE_STORY_DIR/ticket.md" ]; then
    PHASE_NUM=1; PHASE_NAME=Intake
  fi
```
(`STANDARD_PATH` is declared and used only inside this story-rendering block — the only place it is read — so
no top-level declaration is needed. The Plan branch keeps `PHASE_NUM=3` — Plan only exists on Standard, so it
is unconditionally 3.)

**Verification:** `bash -n host/templates/claude/statusline.sh`; `grep -c '"testing"' host/templates/claude/statusline.sh`
→ `0` (no config-flag read); `grep -c 'TESTING_ENABLED' host/templates/claude/statusline.sh` → `0` (variable
fully removed). Render against a Standard fixture (story folder with `implementation_plan.md` + `ticket.md`)
→ `P3 Plan`; add `testing_plan.md` → `P5 Test`; add `feedback/review_v1.md` → `P6 Review`. Against a Quick
fixture (no plan; `spec.md` + `ticket.md` + `agent_test_session.md`) → `P4 Test`.

## Step 2 — `reference/audit_dimensions.md:117`: D10 phase-count expectation

Locate:
```
- **Phase count varies with the testing flag.** 7 phases when `testing: "disabled"`, 8 when `"enabled"` (the terminal phase is Finalize, `/e8-finalize-story`). D10 treats both as correct — a body must match the count *for the configuration it describes*, not a single fixed number.
```
Replace with:
```
- **Phase count varies by path.** Testing is a required phase, so the count is 7 on the Quick path and 8 on the Standard path (Standard adds Phase 3 Plan; the terminal phase is Finalize, `/e8-finalize-story`). D10 treats both as correct — a body must match the count *for the path it describes*, not a single fixed number, and there is no `testing` config flag.
```

## Step 3 — `README.md`: command tables, config table, project-doc count

3a — `:88` `| `/e3b-write-testing-plan {slug}` | 3 sub-phase (testing enabled) | shipped |` → `… | 3 sub-phase (automated suites present) | shipped |`.
3b — `:90` `| `/e5-execute-tests {slug}` | 5. Test (testing enabled) | shipped |` → `… | 5. Test (required) | shipped |`.
3c-i — `:230–231` — **delete** the dropped `testing` config-table row (the key is dropped; `TESTING_STANDARDS.md` is the source of truth). The row sits between the `pr_provider` row (`:230`) and the `ai_service` row (`:232`); locate both the `pr_provider` row and the `testing` row together and replace with just the `pr_provider` row so the `testing` line is removed and the table stays contiguous.
Locate:
```
| `pr_provider` | `"ado"` / `"github"` / `"none"` | Which PR provider `/e6-review-changes` formal mode uses |
| `testing` | `"enabled"` / `"disabled"` | Whether Phase 5 (Test) is part of the Engineer flow |
```
Replace with:
```
| `pr_provider` | `"ado"` / `"github"` / `"none"` | Which PR provider `/e6-review-changes` formal mode uses |
```
3c-ii — `:235–237` — add the governing-doc sentence immediately under the config table (after the `rules_size_budget_chars` row, before the `---` separator).
Locate:
```
| `rules_size_budget_chars` | integer (default 40000, optional) | `/f5-audit-framework` D12: max chars for `templates/SHAMT_RULES.template.md` (the rules file rendered into each child `CLAUDE.md`) before a size finding fires |

---
```
Replace with:
```
| `rules_size_budget_chars` | integer (default 40000, optional) | `/f5-audit-framework` D12: max chars for `templates/SHAMT_RULES.template.md` (the rules file rendered into each child `CLAUDE.md`) before a size finding fires |

Testing is governed by `.shamt-core/project-specific-files/TESTING_STANDARDS.md` (a project doc), not a config key — see [`reference/testing.md`](reference/testing.md).

---
```
3d — `:234` — locate `how stale `.shamt-core/project-specific-files/ARCHITECTURE.md` / `.shamt-core/project-specific-files/CODING_STANDARDS.md` can be` → `how stale the three project-specific docs (`.shamt-core/project-specific-files/ARCHITECTURE.md` / `.shamt-core/project-specific-files/CODING_STANDARDS.md` / `.shamt-core/project-specific-files/TESTING_STANDARDS.md`) can be`.
3e — `:255` (init-steps enum, #19-touched) `the two project-specific docs `ARCHITECTURE.md` + `CODING_STANDARDS.md`` → `the three project-specific docs `ARCHITECTURE.md` + `CODING_STANDARDS.md` + `TESTING_STANDARDS.md``.
3f — `:256` `fill in and `/validate-artifact` both project-specific docs` → `… all three project-specific docs`.
3g — `:318–328` — locate the phase-detection intro sentence + the phase-detection table:
```
Phase detection (story altitude only) cascades from latest-stage artifact. Numbers depend on `.shamt-core/shamt-config.json` `testing`:

| Artifact present | `testing: "enabled"` (8 phases) | `testing: "disabled"` (7 phases) |
|---|---|---|
| `ticket.md` carries `**Status: Done**` | P8 Finalize | P7 Finalize |
| `feedback/addressed_feedback.md` | P7 Polish | P6 Polish |
| `feedback/review_v*.md` | P6 Review | P5 Review |
| `testing_plan.md` | P5 Test | *(ignored — no Test phase)* |
| `implementation_plan.md` | P3 Plan | P3 Plan |
| `spec.md` | P2 Spec | P2 Spec |
| `ticket.md` | P1 Intake | P1 Intake |
```
Replace with:
```
Phase detection (story altitude only) cascades from latest-stage artifact. Numbers depend on the **path** — Standard (an implementation plan is present) is 8 phases; Quick (no plan) is 7. Test is a required phase on both:

| Artifact present | Standard path (8 phases) | Quick path (7 phases) |
|---|---|---|
| `ticket.md` carries `**Status: Done**` | P8 Finalize | P7 Finalize |
| `feedback/addressed_feedback.md` | P7 Polish | P6 Polish |
| `feedback/review_v*.md` | P6 Review | P5 Review |
| `agent_test_session.md` or `testing_plan.md` | P5 Test | P4 Test |
| `implementation_plan.md` | P3 Plan | *(n/a — Quick has no Plan)* |
| `spec.md` | P2 Spec | P2 Spec |
| `ticket.md` | P1 Intake | P1 Intake |
```

## Step 4 — `CLAUDE.md:22`: three project docs

Locate `project-specific-files/{ARCHITECTURE,CODING_STANDARDS}.md` and replace with
`project-specific-files/{ARCHITECTURE,CODING_STANDARDS,TESTING_STANDARDS}.md`.

---

## Verification (P5 exit + whole-change backstop)

- `grep -rnE 'testing: "enabled"|testing: "disabled"|when testing is enabled' templates/ host/templates/claude/ reference/ README.md CLAUDE.md shamt-config.example.json init-shamt.sh`
  → **only** the new TESTING_STANDARDS / required-testing wording remains; **zero** old `testing` config-flag
  references anywhere (the whole-change completeness assertion).
- `bash -n host/templates/claude/statusline.sh`; status line renders 7 phases (Quick, Test at P4) / 8 phases (Standard, Test at P5).
- README config table has no `testing` row; the three project docs appear in the staleness + init-steps lines.

## Notes

- After P5, `/f4-regen-framework` propagates the `host/templates/claude/` edits (statusline + all the e*
  command/skill bodies + the new `user-simulator` persona) into `.claude/`; then `/f5-audit-framework`'s
  D2/D9/D10 sweep is the final consistency backstop (zero residual flag; phase counts consistent;
  cross-refs to `reference/testing.md` resolve).
- `CODING_STANDARDS Compliance`: N/A — canonical docs/statusline/reference.

---
Validated 2026-06-13 — 6 rounds, 1 adversarial sub-agent confirmed
