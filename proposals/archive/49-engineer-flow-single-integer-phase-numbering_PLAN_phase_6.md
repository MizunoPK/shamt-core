# Implementation Plan — Phase 6: Root docs + cross-flow references

**Proposal:** proposals/49-engineer-flow-single-integer-phase-numbering.md
**Plan index:** proposals/49-engineer-flow-single-integer-phase-numbering_PLAN.md
**Covers:** Proposed Changes rows 57–61 (README.md, CLAUDE.md, PO + framework-update command bodies)
**Created:** 2026-06-21

## Steps

### Step 6.1 — README.md: rewrite the Engineer-flow command table (e1–e9, drop e3b/e5b, add merged e4)

**Operation:** EDIT
**File:** README.md

**Locate:**
```
| Command | Phase | Status |
|---------|-------|--------|
| `/e1-start-story {slug}` | 1. Intake | shipped |
| `/e2-define-spec {slug}` | 2. Spec | shipped |
| `/e3-plan-implementation {slug}` | 3. Plan (Standard only) | shipped |
| `/e3b-write-testing-plan {slug}` | 3 sub-phase (automated suites present) | shipped |
| `/e4-execute-plan {slug}` | 4. Build | shipped |
| `/e5-execute-tests {slug}` | 5. Test (required) | shipped |
| `/e6-review-changes [{slug}\|--branch=<name>\|--pr=<id>]` | 6. Review — story mode also opens the PR when `pr_provider == github` (push branch + `gh pr create`, confirm-gated) | shipped |
| `/e7-resolve-feedback {slug}` | 7. Polish — iterative: re-pulls the latest PR comments each run + pushes fix commits when `pr_provider == github` (pull-only) | shipped |
| `/e8-finalize-story {slug}` | 8. Finalize | shipped |
| `/e5b-write-manual-testing-plan {slug}` | Post-Build (optional) | shipped |
| `/e-all {slug}` | Meta-driver (spans Phases 1–6, not a numbered phase) — walk a story through every remaining phase up to and including Review (`/e1` → `/e2` → optional `/e3`+`/e3b` on Standard → `/e4` → `/e5` → `/e6`, opening the PR when `pr_provider == github`) by dispatching one independent agent per phase, deriving the start phase from on-disk artifacts, pausing on each interactive gate (Gate 2a design dialog, Gate 2b / Gate 3 approvals) via `AskUserQuestion`, and halting on any failure it cannot resolve. **Stops at the end of Review** — Polish (`/e7`, iterative) and Finalize (`/e8`) are operator-driven, not auto-run. **Child-facing** — runs wherever the Engineer flow runs (every child, and master self-host); no master-only guard | shipped |
| `/validate-artifact <path>` | any | shipped |
```

**Replace:**
```
| Command | Phase | Status |
|---------|-------|--------|
| `/e1-start-story {slug}` | 1. Intake | shipped |
| `/e2-define-spec {slug}` | 2. Spec | shipped |
| `/e3-plan-implementation {slug}` | 3. Plan | shipped |
| `/e4-write-test-plan {slug}` | 4. Test Plan — authors `user_test_plan.md` always + `testing_plan.md` when `TESTING_STANDARDS.md` declares suites | shipped |
| `/e5-execute-plan {slug}` | 5. Build | shipped |
| `/e6-execute-tests {slug}` | 6. Test — `user-simulator` executes `user_test_plan.md`; `test-executor` runs `testing_plan.md` when suites exist | shipped |
| `/e7-review-changes [{slug}\|--branch=<name>\|--pr=<id>]` | 7. Review — story mode also opens the PR when `pr_provider == github` (push branch + `gh pr create`, confirm-gated) | shipped |
| `/e8-resolve-feedback {slug}` | 8. Polish — iterative: re-pulls the latest PR comments each run + pushes fix commits when `pr_provider == github` (pull-only) | shipped |
| `/e9-finalize-story {slug}` | 9. Finalize | shipped |
| `/e-all {slug}` | Meta-driver (spans Phases 1–7, not a numbered phase) — walk a story through every remaining phase up to and including Review (`/e1` → `/e2` → `/e3` → `/e4` → `/e5` → `/e6` → `/e7`, opening the PR when `pr_provider == github`) by dispatching one independent agent per phase, deriving the start phase from on-disk artifacts, pausing on each interactive gate (Gate 2a design dialog, Gate 2b / Gate 3 approvals) via `AskUserQuestion`, and halting on any failure it cannot resolve. **Stops at the end of Review** — Polish (`/e8`, iterative) and Finalize (`/e9`) are operator-driven, not auto-run. **Child-facing** — runs wherever the Engineer flow runs (every child, and master self-host); no master-only guard | shipped |
| `/validate-artifact <path>` | any | shipped |
```

**Verification:** `grep -nE "/e3b|/e5b|Standard only|Post-Build \(optional\)|3 sub-phase" README.md` returns zero matches; `grep -n "/e4-write-test-plan {slug}\|/e5-execute-plan {slug}\|/e6-execute-tests {slug}\|/e7-review-changes\|/e8-resolve-feedback {slug}\|/e9-finalize-story {slug}" README.md` returns the six new rows; `grep -n "spans Phases 1–7" README.md` confirms the renumbered e-all span.

---

### Step 6.2 — README.md: renumber the `/e-all` Principle-1 note (preserve #50 wording)

**Operation:** EDIT
**File:** README.md

**Locate:**
```
> **`/e-all` and Principle 1.** `/e-all` is an **optional** one-shot driver over the Engineer-flow phases through Review (`/e1` … `/e6`) — a convenience layer, not a replacement. It **stops at the end of Review** (opening the PR when `pr_provider == github`); Polish (`/e7`, an iterative human-in-the-loop PR-comment loop) and Finalize (`/e8`, which merges the PR) are operator-driven, invoked by hand. The per-phase commands remain the supported manual path and each stays independently runnable. It honors Principle 1's "no single mega-orchestrator / no state file" because it is a **stateless, disk-derived dispatcher**: it holds no state of its own (it derives its start phase from on-disk artifacts and advances on each dispatched phase agent's report), and it dispatches the canonical phase commands rather than reimplementing them. Unlike master-only `/f-all`, it is **child-facing** (runs wherever the Engineer flow runs) and **gate-heavy** (it pauses on the flow's many interactive gates). The authoritative reconciliation lives beside `/f-all`'s in `CLAUDE.md` §"How changes land".
```

**Replace:**
```
> **`/e-all` and Principle 1.** `/e-all` is an **optional** one-shot driver over the Engineer-flow phases through Review (`/e1` … `/e7`) — a convenience layer, not a replacement. It **stops at the end of Review** (opening the PR when `pr_provider == github`); Polish (`/e8`, an iterative human-in-the-loop PR-comment loop) and Finalize (`/e9`, which merges the PR) are operator-driven, invoked by hand. The per-phase commands remain the supported manual path and each stays independently runnable. It honors Principle 1's "no single mega-orchestrator / no state file" because it is a **stateless, disk-derived dispatcher**: it holds no state of its own (it derives its start phase from on-disk artifacts and advances on each dispatched phase agent's report), and it dispatches the canonical phase commands rather than reimplementing them. Unlike master-only `/f-all`, it is **child-facing** (runs wherever the Engineer flow runs) and **gate-heavy** (it pauses on the flow's many interactive gates). The authoritative reconciliation lives beside `/f-all`'s in `CLAUDE.md` §"How changes land".
```

**Verification:** `grep -n "Polish (\`/e8\`, an iterative human-in-the-loop PR-comment loop) and Finalize (\`/e9\`, which merges the PR) are operator-driven" README.md` confirms the #50 "stops at Review" + PR-merge wording survived with the new numbers; `grep -n "(\`/e1\` … \`/e7\`)" README.md` confirms the renumbered span.

---

### Step 6.3 — README.md: renumber the personas table (user-simulator executes user_test_plan; drop "(Standard)")

**Operation:** EDIT
**File:** README.md

**Locate:**
```
| `plan-executor` | Haiku | `/e4-execute-plan` (Standard) and `/f3-implement-update` (architect/builder path) | shipped |
| `validation-checker` | Haiku | Pattern 1 adversarial sub-agent | shipped |
| `audit-checker` | Haiku | `/f5-audit-framework` clean-round adversarial sweep | shipped |
| `test-executor` | Haiku | `/e5-execute-tests` (automated suites) | shipped |
| `user-simulator` | Sonnet | `/e5-execute-tests` agent-as-user execution | shipped |
| `review-executor` | Opus | `/e6-review-changes` formal mode | shipped |
```

**Replace:**
```
| `plan-executor` | Haiku | `/e5-execute-plan` and `/f3-implement-update` (architect/builder path) | shipped |
| `validation-checker` | Haiku | Pattern 1 adversarial sub-agent | shipped |
| `audit-checker` | Haiku | `/f5-audit-framework` clean-round adversarial sweep | shipped |
| `test-executor` | Haiku | `/e6-execute-tests` (automated suites) | shipped |
| `user-simulator` | Sonnet | `/e6-execute-tests` — executes `user_test_plan.md` (agent-as-user) | shipped |
| `review-executor` | Opus | `/e7-review-changes` formal mode | shipped |
```

**Verification:** `grep -nE "/e4-execute-plan|/e5-execute-tests|/e6-review-changes|\(Standard\)" README.md` returns zero matches in the personas table region; `grep -n "executes \`user_test_plan.md\` (agent-as-user)" README.md` confirms the user-simulator rewrite.

---

### Step 6.4 — README.md: renumber the `pr_provider` config-key description (preserve #50 PR semantics)

**Operation:** EDIT
**File:** README.md

**Locate:**
```
| `pr_provider` | `"ado"` / `"github"` / `"none"` | Which PR provider the PR-aware Engineer phases use. `/e6-review-changes` formal mode uses it for `--pr` fetch; when `pr_provider == github`, story-mode `/e6` opens the PR, `/e7-resolve-feedback` pulls PR comments + pushes fixes (iterative), and `/e8-finalize-story` merges the PR. Independent of `work_item_tracker` (which routes the work-item close). |
```

**Replace:**
```
| `pr_provider` | `"ado"` / `"github"` / `"none"` | Which PR provider the PR-aware Engineer phases use. `/e7-review-changes` formal mode uses it for `--pr` fetch; when `pr_provider == github`, story-mode `/e7` opens the PR, `/e8-resolve-feedback` pulls PR comments + pushes fixes (iterative), and `/e9-finalize-story` merges the PR. Independent of `work_item_tracker` (which routes the work-item close). |
```

**Verification:** `grep -n "story-mode \`/e7\` opens the PR" README.md` confirms PR-open at Review renumbered; `grep -n "\`/e9-finalize-story\` merges the PR" README.md` confirms #50's `gh pr merge` finalize renumbered.

---

### Step 6.5 — README.md: renumber the STATUS-transition engineer-phase pointers (line ~159)

**Operation:** EDIT
**File:** README.md

**Locate:**
```
re-computed from on-disk signals by `/po-status {epic-slug}` and the transition commands (`/pe3-decompose`, `/pf3-decompose`, the `-validate` stage `/pe2-validate` / `/pf2-validate` / `/ps2-validate`, `/e4`, `/e8`); never hand-edited.
```

**Replace:**
```
re-computed from on-disk signals by `/po-status {epic-slug}` and the transition commands (`/pe3-decompose`, `/pf3-decompose`, the `-validate` stage `/pe2-validate` / `/pf2-validate` / `/ps2-validate`, `/e5`, `/e9`); never hand-edited.
```

**Verification:** `grep -n "/pf2-validate\` / \`/ps2-validate\`, \`/e5\`, \`/e9\`" README.md` confirms Build (`/e4`→`/e5`) and Finalize (`/e8`→`/e9`) renumbered in the STATUS-transition list.

---

### Step 6.6 — README.md: renumber the "Phase 6 / Phase 7 cycle" architecture-impact aside (line ~177)

**Operation:** EDIT
**File:** README.md

**Locate:**
```
coding style is irrelevant at these altitudes; the story-level Phase 6 / Phase 7 cycle handles coding-standards alignment for any eventual code changes.
```

**Replace:**
```
coding style is irrelevant at these altitudes; the story-level Phase 7 / Phase 8 cycle handles coding-standards alignment for any eventual code changes.
```

**Verification:** `grep -n "story-level Phase 7 / Phase 8 cycle" README.md` confirms the Review/Polish cycle reference renumbered; `grep -n "Phase 6 / Phase 7 cycle" README.md` returns zero matches.

---

### Step 6.7 — README.md: collapse the phase-detection cascade preamble to uniform 9 phases

**Operation:** EDIT
**File:** README.md

**Locate:**
```
Phase detection (story altitude only) cascades from latest-stage artifact. Numbers depend on the **path** — Standard (an implementation plan is present) is 8 phases; Quick (no plan) is 7. Test is a required phase on both:
```

**Replace:**
```
Phase detection (story altitude only) cascades from the latest-stage artifact. The flow is a single uniform 9-phase sequence (every stage mandatory — no Quick/Standard split):
```

**Verification:** `grep -nE "Quick|Standard" README.md | grep -v "Quick reference"` returns zero matches across the whole file (line 3's "Quick reference" tagline is the only allowed remnant); `grep -n "single uniform 9-phase sequence" README.md` confirms the new preamble.

---

### Step 6.8 — README.md: replace the phase-detection cascade table with the uniform 9-phase mapping

**Operation:** EDIT
**File:** README.md

**Locate:**
```
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

**Replace:**
```
| Artifact present | Phase |
|---|---|
| `ticket.md` carries `**Status: Done**` | P9 Finalize |
| `feedback/addressed_feedback.md` | P8 Polish |
| `feedback/review_v*.md` | P7 Review |
| `agent_test_session.md` | P6 Test |
| `user_test_plan.md` or `testing_plan.md` | P4 Test Plan |
| `implementation_plan.md` | P3 Plan |
| `spec.md` | P2 Spec |
| `ticket.md` | P1 Intake |
```

**Verification:** `grep -nE "Standard path|Quick path|n/a — Quick has no Plan" README.md` returns zero matches; `grep -n "\`user_test_plan.md\` or \`testing_plan.md\` | P4 Test Plan" README.md` confirms the new P4 Test-Plan row with the renamed artifact; `grep -n "\`agent_test_session.md\` | P6 Test" README.md` confirms Test maps to P6.

---

### Step 6.9 — README.md: update the post-table "Build has no artifact" caveat to P5

**Operation:** EDIT
**File:** README.md

**Locate:**
```
Phase 4 (Build) has no dedicated artifact; the cascade shows the last-completed artifact's phase while Build is in flight.
```

**Replace:**
```
Phase 5 (Build) has no dedicated artifact; the cascade shows the last-completed artifact's phase while Build is in flight.
```

**Verification:** `grep -n "Phase 5 (Build) has no dedicated artifact" README.md` confirms Build renumbered to P5; `grep -n "Phase 4 (Build) has no dedicated artifact" README.md` returns zero matches.

---

### Step 6.10 — CLAUDE.md: renumber the `/e-all` reconciliation paragraph (preserve #50; do NOT revert to e1→e9 driven)

**Operation:** EDIT
**File:** CLAUDE.md

**Locate:**
```
**`/e-all` and Principle 1 — the authoritative reconciliation** (homed here beside `/f-all`'s so a future `/f5-audit-framework` D9 contradiction sweep consults both flow-drivers' carve-outs in one place). `/e-all {slug}` is the Engineer flow's analog of `/f-all`: an **optional** one-shot driver that walks a single story through every remaining Engineer-flow phase **up to and including Review** (`/e1` → `/e2` → optional `/e3`+`/e3b` on the Standard path → `/e4` → `/e5` → `/e6`, opening the PR when `pr_provider == github`) by dispatching one independent agent per phase. It **stops at the end of Review** — Polish (`/e7`, an iterative human-in-the-loop PR-comment loop) and Finalize (`/e8`, which merges the PR when `pr_provider == github`) are **operator-driven, not auto-run by `/e-all`** (Polish is no longer a single pass, so it cannot be chained unattended). It honors Principle 1 by the same argument: it is a **stateless, disk-derived *dispatcher* of the canonical Engineer-phase commands**, not a state-holding monolith — it derives its start phase from on-disk artifacts under `stories/{slug}/` (using a working-tree **gate** for `/e4`, which records no durable artifact, exactly as `/f-all` gates `/f3` and `/f4`) and advances on each dispatched phase agent's report, and every underlying `/eX` command stays independently runnable. It differs from `/f-all` in three structural ways: it is **child-facing** (it runs wherever the Engineer flow runs — every child project, and master self-host — so there is **no** master-only guard); it is **gate-heavy** (it pauses on the Engineer flow's many interactive gates — Gate 2a design dialog, Gate 2b / Gate 3 approvals — each lifted to the user via `AskUserQuestion`, never a design call the driver makes itself); and it spans more inner personas (`validation-checker`, `plan-executor`, `user-simulator`, `test-executor`), each lifted up to the driver under the same one-nesting-level rule. Because it stops at Review, its terminal dispatched phase is `/e6` (which opens the PR behind `/e6`'s own explicit-confirm guard when `pr_provider == github`); the later `/e8` PR merge is operator-driven and user-gated by `/e8`'s own explicit-confirm guard — strictly safer than `/f-all`'s autonomous squash-merge. (Like `/f-all`, it is deliberately **not** added to `templates/SHAMT_RULES.template.md` — the size-budgeted (D12) child rules file does not carry flow-driver detail; this primer is where the reconciliation is homed. A short pointer lives in the README §"Engineer flow (Part 1 — story-level execution)" note.)
```

**Replace:**
```
**`/e-all` and Principle 1 — the authoritative reconciliation** (homed here beside `/f-all`'s so a future `/f5-audit-framework` D9 contradiction sweep consults both flow-drivers' carve-outs in one place). `/e-all {slug}` is the Engineer flow's analog of `/f-all`: an **optional** one-shot driver that walks a single story through every remaining Engineer-flow phase **up to and including Review** (`/e1` → `/e2` → `/e3` → `/e4` → `/e5` → `/e6` → `/e7`, opening the PR when `pr_provider == github`) by dispatching one independent agent per phase. It **stops at the end of Review** — Polish (`/e8`, an iterative human-in-the-loop PR-comment loop) and Finalize (`/e9`, which merges the PR when `pr_provider == github`) are **operator-driven, not auto-run by `/e-all`** (Polish is no longer a single pass, so it cannot be chained unattended). It honors Principle 1 by the same argument: it is a **stateless, disk-derived *dispatcher* of the canonical Engineer-phase commands**, not a state-holding monolith — it derives its start phase from on-disk artifacts under `stories/{slug}/` (using a working-tree **gate** for `/e5`, which records no durable artifact, exactly as `/f-all` gates `/f3` and `/f4`) and advances on each dispatched phase agent's report, and every underlying `/eX` command stays independently runnable. It differs from `/f-all` in three structural ways: it is **child-facing** (it runs wherever the Engineer flow runs — every child project, and master self-host — so there is **no** master-only guard); it is **gate-heavy** (it pauses on the Engineer flow's many interactive gates — Gate 2a design dialog, Gate 2b / Gate 3 approvals — each lifted to the user via `AskUserQuestion`, never a design call the driver makes itself); and it spans more inner personas (`validation-checker`, `plan-executor`, `user-simulator`, `test-executor`), each lifted up to the driver under the same one-nesting-level rule. Because it stops at Review, its terminal dispatched phase is `/e7` (which opens the PR behind `/e7`'s own explicit-confirm guard when `pr_provider == github`); the later `/e9` PR merge is operator-driven and user-gated by `/e9`'s own explicit-confirm guard — strictly safer than `/f-all`'s autonomous squash-merge. (Like `/f-all`, it is deliberately **not** added to `templates/SHAMT_RULES.template.md` — the size-budgeted (D12) child rules file does not carry flow-driver detail; this primer is where the reconciliation is homed. A short pointer lives in the README §"Engineer flow (Part 1 — story-level execution)" note.)
```

**Verification:** `grep -nE "Quick|Standard|/e3b" CLAUDE.md` returns zero matches; `grep -n "\`/e1\` → \`/e2\` → \`/e3\` → \`/e4\` → \`/e5\` → \`/e6\` → \`/e7\`, opening the PR" CLAUDE.md` confirms the renumbered terminal-at-Review chain (and that it was NOT rewritten as an "e1→e9 driven" chain — it still ends at `/e7`); `grep -n "Polish (\`/e8\`, an iterative human-in-the-loop PR-comment loop) and Finalize (\`/e9\`, which merges the PR" CLAUDE.md` confirms #50's iterative-Polish + PR-merge detail survived; `grep -n "terminal dispatched phase is \`/e7\`" CLAUDE.md` confirms the terminal-at-Review (renumbered) preservation.

---

### Step 6.11 — CLAUDE.md: Validation-expectations line (confirming no-op)

**Operation:** EDIT (confirming no-op — no Quick/Standard present)
**File:** CLAUDE.md

**Locate:** the §"Validation expectations" paragraph:
```
Every artifact change in this folder goes through a Pattern 1 validation loop before merge. The `templates/SHAMT_RULES.template.md` file defines Pattern 1 normatively — read it once and apply it consistently. Sub-agent confirmations always use cheap-tier (Haiku); a sub-agent finding any issue (even one LOW) resets the validation counter.
```

**Replace:** *(unchanged — this line already describes uniform validation with no Quick/Standard rigor selector; no edit needed)*

**Verification:** `grep -nE "Quick|Standard" CLAUDE.md` returns zero matches file-wide after Step 6.10, proving the Validation-expectations line carries no Quick/Standard remnant (it never did). No textual change is required for this site; row 58's "update the Validation expectations line to uniform" is already satisfied at HEAD.

---

### Step 6.12 — pe2-validate.md: remove the Standard-path rigor selection (row 59 file 1/3)

**Operation:** EDIT
**File:** host/templates/claude/commands/pe2-validate.md

**Locate:**
```
Epic-validate always takes the **Standard** path (primary clean round + one adversarial `validation-checker` Haiku sub-agent confirmation; no one-LOW allowance). On a clean exit, the loop stamps the two-line footer block on `epic.md` exactly as `/validate-artifact` Step 8 does:
```

**Replace:**
```
Epic-validate runs the uniform validation exit (primary clean round + one adversarial `validation-checker` Haiku sub-agent confirmation; no one-LOW allowance). On a clean exit, the loop stamps the two-line footer block on `epic.md` exactly as `/validate-artifact` Step 8 does:
```

**Verification:** `grep -nE "Quick|Standard" host/templates/claude/commands/pe2-validate.md` returns zero matches; `grep -n "runs the uniform validation exit" host/templates/claude/commands/pe2-validate.md` confirms the rewrite.

---

### Step 6.13 — pf2-validate.md: remove the Standard-path rigor selection (row 59 file 2/3)

**Operation:** EDIT
**File:** host/templates/claude/commands/pf2-validate.md

**Locate:**
```
Standard path (primary clean round + one adversarial `validation-checker` Haiku sub-agent; no one-LOW allowance). On a clean exit, stamp the two-line footer block on `feature.md` exactly as `/validate-artifact` Step 8 does.
```

**Replace:**
```
Uniform validation exit (primary clean round + one adversarial `validation-checker` Haiku sub-agent; no one-LOW allowance). On a clean exit, stamp the two-line footer block on `feature.md` exactly as `/validate-artifact` Step 8 does.
```

**Verification:** `grep -nE "Quick|Standard" host/templates/claude/commands/pf2-validate.md` returns zero matches; `grep -n "Uniform validation exit" host/templates/claude/commands/pf2-validate.md` confirms the rewrite.

---

### Step 6.14 — ps2-validate.md: remove the "Standard exit (not Quick)" rigor selection (row 59 file 3/3)

**Operation:** EDIT
**File:** host/templates/claude/commands/ps2-validate.md

**Locate:**
```
2. **Standard exit (not Quick)** — story-validate always takes the **Standard** path: on `consecutive_clean = 1` it spawns **one independent adversarial `validation-checker` sub-agent (Haiku tier)** that re-reads `ticket.md` from scratch with zero bias and replies `CONFIRMED: Zero issues found after adversarial review.` only if clean — mirroring `/validate-artifact` Step 7. **No one-LOW allowance**: any sub-agent finding (even a single LOW) resets `consecutive_clean = 0` and returns to the primary round.
```

**Replace:**
```
2. **Uniform adversarial exit** — story-validate runs the single uniform validation exit: on `consecutive_clean = 1` it spawns **one independent adversarial `validation-checker` sub-agent (Haiku tier)** that re-reads `ticket.md` from scratch with zero bias and replies `CONFIRMED: Zero issues found after adversarial review.` only if clean — mirroring `/validate-artifact` Step 7. **No one-LOW allowance**: any sub-agent finding (even a single LOW) resets `consecutive_clean = 0` and returns to the primary round.
```

**Verification:** `grep -nE "Quick|Standard" host/templates/claude/commands/ps2-validate.md` returns zero matches; `grep -n "Uniform adversarial exit" host/templates/claude/commands/ps2-validate.md` confirms the rewrite.

---

### Step 6.15 — f1-propose-update.md: renumber the incident-origin phase pointer (Phase-5 test failure → Phase-6; `/e7`→`/e8`) (row 60 file 1/5)

**Operation:** EDIT
**File:** host/templates/claude/commands/f1-propose-update.md

**Locate:**
```
1. **Detect incident origin.** The proposal is incident-originated when its trigger is a **bug, a piece of feedback, or an issue** rather than a clean-slate idea — concretely: a Phase-5 test failure routed here by `/e7-resolve-feedback`, a recurring review finding, a child-submitted issue, or an audit capture (an f0 draft ingested via Input Mode 3).
```

**Replace:**
```
1. **Detect incident origin.** The proposal is incident-originated when its trigger is a **bug, a piece of feedback, or an issue** rather than a clean-slate idea — concretely: a Phase-6 test failure routed here by `/e8-resolve-feedback`, a recurring review finding, a child-submitted issue, or an audit capture (an f0 draft ingested via Input Mode 3).
```

**Verification:** `grep -n "Phase-6 test failure routed here by \`/e8-resolve-feedback\`" host/templates/claude/commands/f1-propose-update.md` confirms Test (Phase 5→6) and Polish (`/e7`→`/e8`) renumbered.

---

### Step 6.16 — f1-propose-update.md: renumber the root-cause incident-context phase attribution (`/e7`→`/e8`) (row 60 file 1/5)

**Operation:** EDIT
**File:** host/templates/claude/commands/f1-propose-update.md

**Locate:**
```
   - `incident` — the triggering bug / review finding / issue / audit capture and its context (e.g., the `/e7` phase-attributed root cause, the f0 Scratch Notes).
```

**Replace:**
```
   - `incident` — the triggering bug / review finding / issue / audit capture and its context (e.g., the `/e8` phase-attributed root cause, the f0 Scratch Notes).
```

**Verification:** `grep -n "the \`/e8\` phase-attributed root cause" host/templates/claude/commands/f1-propose-update.md` confirms the Polish renumber; `grep -nE "/e7\b|Phase-5 test|Quick|Standard" host/templates/claude/commands/f1-propose-update.md` returns zero matches.

---

### Step 6.17 — f2-plan-update-implementation.md (confirming no-op — row 60 file 2/5)

**Operation:** EDIT (confirming no-op — no Quick/Standard, e3b/e5b, or renamed-phase mentions present)
**File:** host/templates/claude/commands/f2-plan-update-implementation.md

**Locate:** *(none — the only `/eX` reference is `skills/e1-start-story/SKILL.md` at line 59, an unchanged `e1` sibling-shape example; there are no Quick/Standard validation-rigor references, no `e3b`/`e5b`, and no renamed engineer-phase pointers)*

**Replace:** *(no edit)*

**Verification:** `grep -nE "Quick|Standard|e3b|e5b|/e[2-9]|manual_test" host/templates/claude/commands/f2-plan-update-implementation.md` returns zero relevant matches (the sole `/e`-ish hit is `skills/e1-start-story/SKILL.md`, an `e1` reference that does not change). This file genuinely has nothing to change — row 60's listing of it is over-inclusive.

---

### Step 6.18 — f3-implement-update.md: reword "Standard-path orchestration" to drop the retired term (row 60 file 3/5)

**Operation:** EDIT
**File:** host/templates/claude/commands/f3-implement-update.md

**Locate:**
```
- Standard-path orchestration (when Phase 3 ran): Balanced (Sonnet) — same architect/builder split as the story-level Build phase; the architect monitors the builder.
```

**Replace:**
```
- Plan-present orchestration (when Phase 3 ran): Balanced (Sonnet) — same architect/builder split as the story-level Build phase; the architect monitors the builder.
```

**Verification:** `grep -nE "Quick|Standard" host/templates/claude/commands/f3-implement-update.md` returns zero matches; `grep -n "Plan-present orchestration (when Phase 3 ran)" host/templates/claude/commands/f3-implement-update.md` confirms the rewrite.

---

### Step 6.19 — f3-implement-update.md: renumber the `/e4-execute-plan` cross-reference (Build e4→e5) (row 60 file 3/5)

**Operation:** EDIT
**File:** host/templates/claude/commands/f3-implement-update.md

**Locate:**
```
the architect (this orchestrator) **independently** runs the plan's post-execution `## Verification` section — mirroring `/e4-execute-plan` Step 4:
```

**Replace:**
```
the architect (this orchestrator) **independently** runs the plan's post-execution `## Verification` section — mirroring `/e5-execute-plan` Step 4:
```

**Verification:** `grep -n "mirroring \`/e5-execute-plan\` Step 4" host/templates/claude/commands/f3-implement-update.md` confirms the Build-command rename propagated; `grep -nE "/e4-execute-plan" host/templates/claude/commands/f3-implement-update.md` returns zero matches.

---

### Step 6.20 — f5-audit-framework.md: replace the D7 canonical-term example (table row) (row 60 file 4/5)

**Operation:** EDIT
**File:** host/templates/claude/commands/f5-audit-framework.md

**Locate:**
```
| D7 | Terminology consistency | One canonical term per concept across all canonical docs — e.g. "Quick"/"Standard" never "Small"/"Full", "Build" never "Implement", "Engineer flow" / "PO flow" used consistently. A concept named two ways in two canonical files is a finding | Reasoning |
```

**Replace:**
```
| D7 | Terminology consistency | One canonical term per concept across all canonical docs — e.g. "Build" never "Implement", "Test Plan" never "test-plan stage", "Engineer flow" / "PO flow" used consistently. A concept named two ways in two canonical files is a finding | Reasoning |
```

**Verification:** `grep -n '"Quick"/"Standard" never "Small"/"Full"' host/templates/claude/commands/f5-audit-framework.md` returns zero matches; `grep -n '"Build" never "Implement", "Test Plan" never "test-plan stage"' host/templates/claude/commands/f5-audit-framework.md` confirms the replacement D7 example.

---

### Step 6.21 — f5-audit-framework.md: reword the D2 "Standard-path loop" mismatch example (row 60 file 4/5)

**Operation:** EDIT
**File:** host/templates/claude/commands/f5-audit-framework.md

**Locate:**
```
- Mismatch examples: Pattern 1 says a Standard-path loop needs an adversarial sub-agent confirmation but a command body omits it; rules name a phase "Build" but a skill calls it "Implement"; §PO-tree pins the nested write-form `epics/{epic-folder}/features/{feature-folder}/stories/…` but a PO-tree producer writes the collapsed `epics/{parent-feature-folder}/stories/…` (drops `features/`). These are HIGH.
```

**Replace:**
```
- Mismatch examples: Pattern 1 says the validation loop needs an adversarial sub-agent confirmation but a command body omits it; rules name a phase "Build" but a skill calls it "Implement"; §PO-tree pins the nested write-form `epics/{epic-folder}/features/{feature-folder}/stories/…` but a PO-tree producer writes the collapsed `epics/{parent-feature-folder}/stories/…` (drops `features/`). These are HIGH.
```

**Verification:** `grep -n "Pattern 1 says the validation loop needs an adversarial sub-agent confirmation" host/templates/claude/commands/f5-audit-framework.md` confirms the rewrite; `grep -n "Standard-path loop" host/templates/claude/commands/f5-audit-framework.md` returns zero matches.

---

### Step 6.22 — f5-audit-framework.md: replace the D7 prose canonical-term list (row 60 file 4/5)

**Operation:** EDIT
**File:** host/templates/claude/commands/f5-audit-framework.md

**Locate:**
```
The canonical terms are fixed by `templates/SHAMT_RULES.template.md` and the reference catalog: "Quick" / "Standard" (never "Small" / "Full"), "Build" (never "Implement" as a phase name), "Engineer flow" / "Product Owner (PO) flow", "finding" / "issue" (interchangeable by design — not a violation).
```

**Replace:**
```
The canonical terms are fixed by `templates/SHAMT_RULES.template.md` and the reference catalog: "Build" (never "Implement" as a phase name), "Test Plan" (the Phase-4 stage; never "test-plan stage"), "Engineer flow" / "Product Owner (PO) flow", "finding" / "issue" (interchangeable by design — not a violation).
```

**Verification:** `grep -nE "Quick|Standard" host/templates/claude/commands/f5-audit-framework.md` returns zero matches file-wide; `grep -n '"Build" (never "Implement" as a phase name), "Test Plan"' host/templates/claude/commands/f5-audit-framework.md` confirms the rewrite.

---

### Step 6.23 — f-all.md: drop the "(Standard)" validation-rigor qualifier (row 60 file 5/5)

**Operation:** EDIT
**File:** host/templates/claude/commands/f-all.md

**Locate:**
```
A sub-agent cannot spawn another sub-agent, yet `/validate-artifact` (Standard) needs `validation-checker` and `/f3` may hand off to `plan-executor`.
```

**Replace:**
```
A sub-agent cannot spawn another sub-agent, yet `/validate-artifact` needs `validation-checker` and `/f3` may hand off to `plan-executor`.
```

**Verification:** `grep -nE "Quick|Standard" host/templates/claude/commands/f-all.md` returns zero matches (the framework-update Phase 2–7 numbers in this file are framework-update-flow phases, not Engineer-flow phases, so they are untouched); `grep -n "yet \`/validate-artifact\` needs \`validation-checker\`" host/templates/claude/commands/f-all.md` confirms the rewrite.

---

### Step 6.24 — pe3-decompose.md: renumber the Review cross-reference (`/e6`→`/e7`) (row 61 file 1/5)

**Operation:** EDIT
**File:** host/templates/claude/commands/pe3-decompose.md

**Locate:**
```
- **No epic-level review phase.** Per Pattern 4, the 16-category code-review framework stays story-level. This command does not invoke `/e6-review-changes`.
```

**Replace:**
```
- **No epic-level review phase.** Per Pattern 4, the 16-category code-review framework stays story-level. This command does not invoke `/e7-review-changes`.
```

**Verification:** `grep -n "does not invoke \`/e7-review-changes\`" host/templates/claude/commands/pe3-decompose.md` confirms the Review renumber; `grep -nE "Quick|Standard|/e6-review|manual_test" host/templates/claude/commands/pe3-decompose.md` returns zero matches.

---

### Step 6.25 — pe4-finalize.md: renumber the four `/e8-finalize-story` pointers (Finalize e8→e9) (row 61 file 2/5)

**Operation:** EDIT
**File:** host/templates/claude/commands/pe4-finalize.md

**Locate:**
```
2. For each child, confirm it is finalized: its artifact carries `**Status: Done**` (written by `/e8-finalize-story` for stories; features close implicitly when all their stories are done — confirm each child story of each child feature is `**Status: Done**`).
3. If any child is not finalized, **halt** and list the unfinished children with their remediation (`/e8-finalize-story {story-slug}` for each). Do not proceed.
```

**Replace:**
```
2. For each child, confirm it is finalized: its artifact carries `**Status: Done**` (written by `/e9-finalize-story` for stories; features close implicitly when all their stories are done — confirm each child story of each child feature is `**Status: Done**`).
3. If any child is not finalized, **halt** and list the unfinished children with their remediation (`/e9-finalize-story {story-slug}` for each). Do not proceed.
```

**Verification:** `grep -n "written by \`/e9-finalize-story\` for stories" host/templates/claude/commands/pe4-finalize.md` and `grep -n "remediation (\`/e9-finalize-story {story-slug}\`" host/templates/claude/commands/pe4-finalize.md` confirm both renumbered.

---

### Step 6.26 — pe4-finalize.md: renumber the `/e8-finalize-story` parenthetical (commit-vs-merge aside) (row 61 file 2/5)

**Operation:** EDIT
**File:** host/templates/claude/commands/pe4-finalize.md

**Locate:**
```
Stage the epic finalize (the `epic.md` status flip + the archive move) and commit. Commit subject: `{ticket-id-or-slug}: finalize epic — {one-line summary}`. The user's signing / hook setup applies. (Like `/e8-finalize-story`, this commits but does not squash-merge a branch.)
```

**Replace:**
```
Stage the epic finalize (the `epic.md` status flip + the archive move) and commit. Commit subject: `{ticket-id-or-slug}: finalize epic — {one-line summary}`. The user's signing / hook setup applies. (Like `/e9-finalize-story`, this commits but does not squash-merge a branch.)
```

**Verification:** `grep -n "(Like \`/e9-finalize-story\`, this commits but does not squash-merge a branch.)" host/templates/claude/commands/pe4-finalize.md` confirms the renumber.

---

### Step 6.27 — pe4-finalize.md: renumber the "Stories finalize via" Notes pointer (row 61 file 2/5)

**Operation:** EDIT
**File:** host/templates/claude/commands/pe4-finalize.md

**Locate:**
```
- **Epic only.** There is no per-feature finalize command; features close implicitly when their stories are finalized. Stories finalize via `/e8-finalize-story`.
```

**Replace:**
```
- **Epic only.** There is no per-feature finalize command; features close implicitly when their stories are finalized. Stories finalize via `/e9-finalize-story`.
```

**Verification:** `grep -n "Stories finalize via \`/e9-finalize-story\`" host/templates/claude/commands/pe4-finalize.md` confirms the renumber; `grep -nE "/e8-finalize-story|Quick|Standard|manual_test" host/templates/claude/commands/pe4-finalize.md` returns zero matches.

---

### Step 6.28 — pf3-decompose.md: rename the manual-test-plan reference (manual→user) (row 61 file 3/5)

**Operation:** EDIT
**File:** host/templates/claude/commands/pf3-decompose.md

**Locate:**
```
   > - "Verification path" can be a unit test, an integration test, a manual checklist step from a `manual_test_plan.md`, or any other observable check the engineer can run to confirm the story's scope.
```

**Replace:**
```
   > - "Verification path" can be a unit test, an integration test, a user-checklist step from a `user_test_plan.md`, or any other observable check the engineer can run to confirm the story's scope.
```

**Verification:** `grep -n "a user-checklist step from a \`user_test_plan.md\`" host/templates/claude/commands/pf3-decompose.md` confirms the rename; `grep -nE "manual_test_plan|manual checklist" host/templates/claude/commands/pf3-decompose.md` returns zero matches.

---

### Step 6.29 — pf3-decompose.md: renumber the Review cross-reference (`/e6`→`/e7`) (row 61 file 3/5)

**Operation:** EDIT
**File:** host/templates/claude/commands/pf3-decompose.md

**Locate:**
```
- **No feature-level review phase.** Per Pattern 4, the 16-category code-review framework stays story-level. This command does not invoke `/e6-review-changes`.
```

**Replace:**
```
- **No feature-level review phase.** Per Pattern 4, the 16-category code-review framework stays story-level. This command does not invoke `/e7-review-changes`.
```

**Verification:** `grep -n "does not invoke \`/e7-review-changes\`" host/templates/claude/commands/pf3-decompose.md` confirms the Review renumber; `grep -nE "Quick|Standard|/e6-review|manual_test" host/templates/claude/commands/pf3-decompose.md` returns zero matches.

---

### Step 6.30 — ps0-draft.md: renumber the tech-story finalize pointer in Tech-story mode (Finalize e8→e9) (row 61 file 4/5)

**Operation:** EDIT
**File:** host/templates/claude/commands/ps0-draft.md

**Locate:**
```
its standing-fixture prerequisite check (halt + direct to re-run `import-shamt` if the standing containers are absent), and its completion-archive note (finalize via `/e8-finalize-story` moves the story into the feature's `archive/`).
```

**Replace:**
```
its standing-fixture prerequisite check (halt + direct to re-run `import-shamt` if the standing containers are absent), and its completion-archive note (finalize via `/e9-finalize-story` moves the story into the feature's `archive/`).
```

**Verification:** `grep -n "finalize via \`/e9-finalize-story\` moves the story into the feature's \`archive/\`" host/templates/claude/commands/ps0-draft.md` confirms the renumber.

---

### Step 6.31 — ps0-draft.md: renumber the completion-archive Notes pointer (Finalize e8→e9) (row 61 file 4/5)

**Operation:** EDIT
**File:** host/templates/claude/commands/ps0-draft.md

**Locate:**
```
- **Completion archive for tech stories.** When a tech story is finalized via `/e8-finalize-story`, it is moved into the feature's `archive/` folder — keeping the standing features from growing without bound (same semantics as the former fast-path).
```

**Replace:**
```
- **Completion archive for tech stories.** When a tech story is finalized via `/e9-finalize-story`, it is moved into the feature's `archive/` folder — keeping the standing features from growing without bound (same semantics as the former fast-path).
```

**Verification:** `grep -n "When a tech story is finalized via \`/e9-finalize-story\`" host/templates/claude/commands/ps0-draft.md` confirms the renumber; `grep -nE "/e8-finalize-story" host/templates/claude/commands/ps0-draft.md` returns zero matches (the remaining "Quick" hits are the `quick-wins` standing-feature name + "Quickly"/"fast-path" prose, not the retired Quick/Standard path).

---

### Step 6.32 — ps1-define.md (confirming no-op — row 61 file 5/5)

**Operation:** EDIT (confirming no-op — no Quick/Standard, manual_test_plan, or renamed-phase mentions present)
**File:** host/templates/claude/commands/ps1-define.md

**Locate:** *(none — every `/eX` reference in this file is `/e1-start-story`, which is unchanged in the renumber; there are no Quick/Standard story-sizing references, no `manual_test_plan` references, and no renamed downstream engineer-phase pointers)*

**Replace:** *(no edit)*

**Verification:** `grep -nE "Quick|Standard|manual_test|/e[2-9]|e3b|e5b" host/templates/claude/commands/ps1-define.md` returns zero matches. This file genuinely has nothing to change — row 61's listing of it is over-inclusive (its only engineer-flow pointers are to the unchanged `/e1-start-story`).

---

## Phase notes

### Rolled-up-row expansion (which step covers which file)

**Row 57 — README.md (EDIT):** Steps 6.1–6.9 (9 steps).
- 6.1 Engineer-flow command table → e1–e9 (drop e3b/e5b rows, add merged e4-write-test-plan; e-all chain renumbered to `e1 → … → e7`, span "Phases 1–7").
- 6.2 `/e-all` Principle-1 note renumbered, **#50 "stops at Review" + PR-merge wording preserved** (Polish `/e8`, Finalize `/e9`).
- 6.3 personas table (plan-executor `/e5-execute-plan`, drop "(Standard)"; test-executor + user-simulator `/e6-execute-tests`; user-simulator now "executes `user_test_plan.md`"; review-executor `/e7-review-changes`).
- 6.4 `pr_provider` config-key description renumbered, **#50 PR-open / PR-merge semantics preserved** (`/e7` opens PR, `/e9` merges).
- 6.5 STATUS-transition pointer list (`/e4`→`/e5`, `/e8`→`/e9`).
- 6.6 architecture-impact aside ("Phase 6 / Phase 7 cycle" → "Phase 7 / Phase 8 cycle").
- 6.7 phase-detection preamble → uniform 9-phase, Quick/Standard removed.
- 6.8 phase-detection cascade **table** → single-column uniform 9-phase mapping with `user_test_plan.md` at P4 Test Plan and `agent_test_session.md` at P6 Test.
- 6.9 post-table Build caveat (P4→P5).
- *No separate Engineer-flow ASCII/mermaid diagram exists in README* — the command table (Step 6.1) is the flow's diagrammatic representation; row 57's "update the flow diagram" is satisfied by the table rewrite. (Confirmed via `grep` for `mermaid|graph |Intake →` — only the table + status-line cascade exist.)

**Row 58 — CLAUDE.md (EDIT):** Steps 6.10–6.11 (2 steps).
- 6.10 `/e-all` reconciliation paragraph renumbered: chain `e1 → … → e7` **terminal at Review**, merged e4 (dropped "optional `/e3`+`/e3b` on the Standard path"), Polish `/e8` + Finalize `/e9` operator-driven; **#50 PR-open / PR-merge / iterative-Polish detail preserved**; gate-file pointer `/e4`→`/e5`; terminal dispatched phase `/e6`→`/e7`, PR-merge `/e8`→`/e9`. **Does NOT revert to "e1→e9 driven"** (verification grep asserts the chain still ends at `/e7`).
- 6.11 Validation-expectations line = **confirming no-op** (already uniform at HEAD; no Quick/Standard present). Row 58's "update the Validation expectations line to uniform" is already satisfied — verified by a file-wide zero-Quick/Standard grep after 6.10.

**Row 59 — PO validation stages (3 files, EDIT each):** Steps 6.12–6.14.
- 6.12 pe2-validate.md ("Standard path" → "uniform validation exit").
- 6.13 pf2-validate.md ("Standard path" → "Uniform validation exit").
- 6.14 ps2-validate.md ("Standard exit (not Quick)" → "Uniform adversarial exit").

**Row 60 — framework-update flow (5 files, EDIT each):** Steps 6.15–6.23.
- 6.15 + 6.16 f1-propose-update.md — renumber two engineer-phase pointers (Phase-5/`/e7` → Phase-6/`/e8`; `/e7` → `/e8`). No Quick/Standard present.
- 6.17 f2-plan-update-implementation.md — **confirming no-op** (no Quick/Standard, e3b/e5b, or renamed-phase refs; only an unchanged `e1` sibling-shape example).
- 6.18 + 6.19 f3-implement-update.md — "Standard-path orchestration" → "Plan-present orchestration"; `/e4-execute-plan` → `/e5-execute-plan`.
- 6.20 + 6.21 + 6.22 f5-audit-framework.md — D7 table example, D2 "Standard-path loop" mismatch example, and D7 prose canonical-term list all de-Quick/Standard'd (replaced with surviving canonical-term examples).
- 6.23 f-all.md — drop "(Standard)" from the `/validate-artifact` validation-rigor qualifier. (Its Phase 2–7 numbers are framework-update-flow phases, untouched.)

**Row 61 — PO decompose/draft (5 files, EDIT each):** Steps 6.24–6.32.
- 6.24 pe3-decompose.md — `/e6-review-changes` → `/e7-review-changes`.
- 6.25 + 6.26 + 6.27 pe4-finalize.md — three sites: `/e8-finalize-story` → `/e9-finalize-story` (×4 pointers across the three sites).
- 6.28 + 6.29 pf3-decompose.md — `manual_test_plan.md`/"manual checklist" → `user_test_plan.md`/"user-checklist"; `/e6-review-changes` → `/e7-review-changes`.
- 6.30 + 6.31 ps0-draft.md — two `/e8-finalize-story` → `/e9-finalize-story` pointers. (Its "Quick"/"quick-wins"/"fast-path" hits are the standing-feature name + prose, NOT the retired Quick/Standard path — no change.)
- 6.32 ps1-define.md — **confirming no-op** (no Quick/Standard, manual_test_plan, or renamed-phase refs; its only engineer pointers are to the unchanged `/e1-start-story`).

### #50 preservation summary (rows 57, 58)

README and CLAUDE.md carry, at HEAD (post-#50, commit ca37b5e), the e-all "terminal at Review" + PR-open / PR-merge / iterative-Polish wording. This phase **relabels only** — `/e6`→`/e7` (Review, opens PR), `/e7`→`/e8` (Polish, iterative pull-only PR-comment loop), `/e8`→`/e9` (Finalize, `gh pr merge`) — and for the `/e-all` chain keeps it terminal at Review (`e1 → … → e7`). Every step touching #50 wording carries an explicit verification grep asserting the renumbered #50 sentence survived (Steps 6.2, 6.4, 6.10). CLAUDE.md Step 6.10's verification additionally asserts the chain still ends at `/e7` (NOT rewritten as "e1→e9 driven").

### Confirming-no-op files (verified zero relevant matches)

- **f2-plan-update-implementation.md** (row 60) — Step 6.17: no Quick/Standard, e3b/e5b, or renamed-phase refs.
- **ps1-define.md** (row 61) — Step 6.32: no Quick/Standard, manual_test_plan, or renamed-phase refs.
- **CLAUDE.md Validation-expectations line** (row 58) — Step 6.11: already uniform at HEAD; no Quick/Standard present.

### Step count

32 steps (Step 6.1 – Step 6.32), of which 3 are confirming no-ops with zero-match grep verification (6.11, 6.17, 6.32).

---
Validated 2026-06-21 — 2 rounds, 1 adversarial sub-agent confirmed
