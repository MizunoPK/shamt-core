# Validation Loop Exit Criteria

**Extends Pattern 1 (Validation Loops) in `SHAMT_RULES.template.md` — read that first.**

**Purpose:** Extended mechanics, counter logic examples, and common mistakes for Shamt validation loops.

---

## The 8-Step Validation Process — per-step mechanics

The rules file keeps Pattern 1's exit criteria, the risk-trigger list, the Step-2 dimension lists (Specs / Plans / Reviews / General), and the footer format block; this is the expanded per-step prose.

**Step 1 — Read and investigate.** Re-read the entire artifact top-to-bottom each round. Research Pending / Open questions and important claims using code, project docs, and other verifiable sources. Cite evidence for resolved answers; if a product / platform decision is required, say so instead of guessing. Update the artifact with verified answers before Step 2.

**Step 2 — Identify issues across dimensions.** First check alignment with `.shamt-core/project-specific-files/ARCHITECTURE.md` and `.shamt-core/project-specific-files/CODING_STANDARDS.md`. Then sweep the dimension list for the artifact type — the per-type dimension lists (Specs: 8; Implementation Plans: 8; Code Reviews: 6; General Artifacts: 5) and their Pattern-3 / Pattern-5 / `reference/review_categories.md` hard checks are kept in the rules file as the normative contract (also mirrored under [Validation Dimensions Quick Reference](#validation-dimensions-quick-reference) below).

**Step 3 — Classify severity.** CRITICAL blocks workflow / causes failure / serious risk. HIGH causes confusion or wrong decisions. MEDIUM noticeably reduces quality. LOW is cosmetic. Borderline cases classify higher.

**Step 4 — Fix all issues immediately.** Do not defer or batch.

**Step 5 — Update `consecutive_clean`.** Clean round = zero issues, or exactly one LOW issue fixed. Not clean = 2+ LOW or any MEDIUM/HIGH/CRITICAL. Clean increments to 1; not clean resets to 0. (See the Counter Logic block below for the full state machine.)

**Step 6 — Check exit.** If `consecutive_clean = 0`, return to Step 1. If `consecutive_clean = 1`, run Step 7. If the sub-agent finds any issue, fix it, reset to 0, and return to Step 1.

**Step 7 — Adversarial review.** Spawn one independent adversarial sub-agent using the configured cheap-tier model (Haiku). Prompt contract: identify the artifact and applicable dimensions; require zero-bias, distrust-by-default reread; verify claims from evidence; report any unsupported assertion, hidden assumption, ambiguity, missing dependency, or edge case; if and only if no issue is found, reply exactly `CONFIRMED: Zero issues found after adversarial review.` **Sub-agents have no one-LOW allowance** (see Sub-Agent Exception Rule and Adversarial Review Posture below).

**Step 8 — Add footer.** When complete, append the footer in the format the rules file specifies (`Validated {date} — N rounds, 1 adversarial sub-agent confirmed`).

---

## Exit Criterion (by path)

- **Standard path:** Primary clean round + **1 independent Haiku adversarial review sub-agent confirmation**. Applies to all Standard-path validation loops (specs, plans, code reviews, and ad-hoc artifacts).
- **Quick path:** A single primary self-review pass. An adversarial sub-agent is only required if a risk trigger applies (e.g. database migrations, security controls, new service creation, auth/tenant boundary changes, etc.).

---

## Counter Logic (Standard path or risk-triggered)

```text
Initial state: consecutive_clean = 0

Round finds 0 issues:
  → consecutive_clean = 1 → trigger adversarial review sub-agent

Round finds exactly 1 LOW issue (and fixes it):
  → consecutive_clean = 1 → trigger adversarial review sub-agent

Round finds 2+ LOW issues:
  → consecutive_clean = 0 → fix all, continue

Round finds any MEDIUM/HIGH/CRITICAL issue:
  → consecutive_clean = 0 → fix all, continue

Sub-agent finds ANY issue (even LOW):
  → consecutive_clean = 0 → fix, continue to next round
```

### Example Sequences

**Scenario 1: Quick exit (2 rounds)**
```
Round 1: 3 MEDIUM issues → consecutive_clean = 0 → Fix → Continue
Round 2: 0 issues → consecutive_clean = 1 → Spawn Haiku adversarial review sub-agent
Sub-agent: 0 issues → COMPLETE
```

**Scenario 2: Sub-agent finds issue (3 rounds)**
```
Round 1: 2 HIGH, 1 MEDIUM → consecutive_clean = 0 → Fix → Continue
Round 2: 1 LOW → consecutive_clean = 1 → Spawn Haiku adversarial review sub-agent
Sub-agent: 1 LOW issue → consecutive_clean = 0 → Fix → Continue
Round 3: 0 issues → consecutive_clean = 1 → Spawn Haiku adversarial review sub-agent
Sub-agent: 0 issues → COMPLETE
```

**Scenario 3: Multiple LOW issues slow exit (3 rounds)**
```
Round 1: 1 HIGH, 2 LOW → consecutive_clean = 0 → Fix → Continue
Round 2: 2 LOW → consecutive_clean = 0 → Fix → Continue
Round 3: 1 LOW → consecutive_clean = 1 → Spawn Haiku adversarial review sub-agent
Sub-agent: 0 issues → COMPLETE
```

---

## Sub-Agent Exception Rule

Sub-agents do NOT get the 1 LOW allowance. ANY issue found by a sub-agent (including LOW) resets `consecutive_clean = 0`.

**Rationale:** The sub-agent is the final verification step with fresh eyes. If it finds anything — even cosmetic — the primary validation missed something. Fix and re-run.

## Adversarial Review Posture

The sub-agent is not a polite confirmer. It is the final adversarial review pass.

Its posture is:

- zero bias toward the artifact author or primary validator
- distrust-by-default for unsupported claims
- disproof-first rather than agreement-first
- active gap hunting under the assumption that important things may have been missed

The sub-agent should especially challenge:

- claims presented as fact without evidence
- references to files, functions, paths, or flows that may not have been checked
- wording that hides unresolved assumptions behind confident language
- missing sections, dependencies, verification steps, or edge cases
- artifacts that appear internally consistent but may still be wrong relative to code or governing docs

Success means the artifact survives an independent attempt to break it, not that it merely feels reasonable on a quick second read.

---

## Fresh Eyes Principle

Re-read the ENTIRE artifact every single round. Do not rely on memory of prior rounds.

**Why:** First-pass reading misses issues that jump out on re-read. Memory-based validation is unreliable — you remember what you wrote, not what's actually there.

**How:** Vary reading patterns across rounds (top-to-bottom, section-by-section, reverse order) to catch different classes of issues.

---

## Common Mistakes

**Exiting after primary clean round:** `consecutive_clean = 1` means trigger the adversarial review sub-agent — it does NOT mean validation is complete. Wait for sub-agent confirmation.

**Deferring issues:** All issues must be fixed immediately before moving to the next round. Never defer or batch fixes.

**Applying the 1 LOW allowance to sub-agents:** Sub-agents report any issue found, no exceptions. No 1 LOW grace period.

**Reading from memory:** Must physically re-read the artifact. Memory validation is unreliable and defeats the purpose of fresh eyes.

**Continuing with unresolved ambiguity:** If an issue is ambiguous (is this HIGH or MEDIUM?), classify higher and fix before continuing.

---

## Validation Dimensions Quick Reference

See Pattern 1 in `SHAMT_RULES.template.md` for the full dimension lists per artifact type:

- Specs: 8 dimensions (Completeness, Correctness, Consistency, Helpfulness, Improvements, Missing proposals, Open questions, Standards & architecture alignment)
- Implementation Plans: 8 dimensions (Step Clarity, Mechanical Executability, File Coverage, Operation Specificity, Verification Completeness, Dependency Ordering, Requirements Alignment, Naming Clarity)
- Code Reviews: 6 dimensions (Correctness, Completeness, Helpfulness, Severity Accuracy, Evidence, Standards & architecture alignment)
- General Artifacts: 5 dimensions (Completeness, Clarity, Accuracy, Actionability, Standards & architecture alignment)

---

*Extends Pattern 1 in `SHAMT_RULES.template.md`.*
