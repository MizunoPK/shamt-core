# Batch-Validation Handoff — Fan-Out Orchestration and Prompt Template

Several Shamt phases end by producing **more than one artifact that must each go through `/validate-artifact`**. The canonical guidance is a sequential list of `/clear` + `/validate-artifact <path>` pairs the user runs by hand, one cleared session at a time — deliberate (it honors the single-session sizing constraint, see `SHAMT_RULES.template.md` Principle 1) but tedious when a phase emits five files at once.

This reference defines the **batch-validation handoff prompt**: a ready-to-paste block a producing command emits so the user can delegate the whole batch to one fresh agent — the **orchestrator** — instead of driving N cleared sessions by hand.

It is a **convenience helper, not a slug-resumable phase.** It adds no new command and does not replace the per-artifact `/validate-artifact <path>` commands, which remain the resumable path (Principle 1) and the listed fallback. The orchestrator runs the **same Pattern 1 loop** per artifact that a single-artifact `/validate-artifact` run would — same dimensions, same exit, same footer. Batching changes who drives the queue, never the rigor of any single validation.

## When to emit

A producing command emits the handoff prompt **only when it leaves ≥2 artifacts to validate**. With a single artifact, emit the ordinary `/clear` + `/validate-artifact <path>` suggestion — there is no batch to orchestrate.

Producers that emit it today:

- `/f2-plan-update-implementation` when the plan is **phase-decomposed** — an index file (`{slug}_PLAN.md`) plus N `_PLAN_phase_*.md` files. That is always ≥2 validations (index under the phase-index dimensions, each phase file under the plan dimensions).
- `/sync-triage-proposals` when **≥2 proposals are promoted** in one run — each promoted `proposals/{slug}.md` is validated independently.

Any future producer that leaves ≥2 artifacts to validate cites this reference rather than hand-rolling a divergent prompt. The single-source-of-truth template here is what keeps producers in sync.

## The orchestration

The orchestrator is a fresh Claude Code session (the only host). It is given the **artifact manifest** — each artifact's on-disk path plus that artifact's governing references — and nothing else.

**The orchestrator never loads artifact bodies into its own context.** It holds only the manifest and each sub-agent's short verdict. A 5-artifact batch therefore does not accumulate the combined size of all five in the orchestrator — the single-session sizing constraint is honored at the orchestrator level too, not just inside the sub-agents.

For each artifact in the manifest, the orchestrator runs this loop:

1. **Spawn a per-artifact primary validation sub-agent.** It reads and fixes the artifact in its own isolated context, running the standard **Pattern 1 primary loop — Steps 1–6 as defined by `/validate-artifact`** (dimension-selection-by-artifact-type, fresh-eyes rounds, in-place fixes, `consecutive_clean` tracking) at the standard primary tier (Reasoning). The primary is driven by the **inline instructions in the handoff prompt** — it does **not** invoke the `/validate-artifact` command itself (that would auto-proceed to the Step 7 adversarial pass and spawn its own checker, the second nesting level this design avoids). The primary **halts after Step 6**, at `consecutive_clean = 1`, **without spawning a checker**, and returns a short verdict.

2. **Apply `/validate-artifact`'s path selection.** Spawn the adversarial checker for a **Standard-path or risk-triggered** artifact; **skip** it for a **Quick-path artifact with no risk trigger** (that artifact exits after the primary's clean pass, per `/validate-artifact` Step 6 → Step 8). The two producers wired today emit only non-story framework artifacts, which default to Standard, so the checker always runs there; path-awareness matters for a future Quick-capable producer that adopts this reference.

3. **The orchestrator — not the primary sub-agent — spawns the checker.** Use the existing `validation-checker` persona at its fixed Haiku tier (do not override). This is the key difference from single-artifact `/validate-artifact`, where the primary validator (itself the top-level session agent) spawns its own checker at Step 7. In the batch case the primary *is* a sub-agent, so the checker-spawn is lifted up to the orchestrator to keep the whole flow at **one nesting level**. Never instruct a sub-agent to spawn the checker — that would attempt a second nesting level.

4. **On any checker finding, re-spawn a fresh primary** for that artifact (new context, `consecutive_clean` back to 0 — mirroring single-artifact Pattern 1's "fix and return to Step 1"), then re-run the checker. Repeat until a checker pass is clean. Clean exit is the only terminator — no separate retry cap, matching the base primitive. **Sub-agents have no one-LOW allowance:** any checker finding, even a single LOW, resets that artifact's loop.

5. **Stamp the footer.** Each artifact gets its own `/validate-artifact` footer on clean exit (Quick: `Validated YYYY-MM-DD — 1 round (Quick path)`; Standard: `Validated YYYY-MM-DD — N rounds, 1 adversarial sub-agent confirmed`), written by the agent that finished it.

After all artifacts are done, the orchestrator reports an aggregate result: per artifact, the path taken and whether it exited clean.

The topology is exactly one nesting level: **orchestrator → per-artifact primary sub-agent**, and separately **orchestrator → `validation-checker`**. Both legs are expressible via the Claude Code Task tool.

## The handoff-prompt template

The producing command fills this in with the **actual resolved on-disk paths** at emit time (each concrete path inserted, not a blank placeholder) and prints it as plaintext for the user to copy into a fresh session. Filling concrete paths keeps the prompt agnostic to any proposal-numbering scheme.

```text
You are the batch-validation orchestrator. Validate each artifact below by
fanning out to sub-agents — do NOT read the artifact bodies into your own
context. Hold only this manifest and each sub-agent's short verdict.

Artifacts to validate:
  1. {path-1}  — governing references: {refs-1}
  2. {path-2}  — governing references: {refs-2}
  ... (one line per artifact)

For EACH artifact, in order:

  A. Spawn a primary validation sub-agent (Reasoning tier) with these
     instructions:
       - Run the Pattern 1 primary loop, Steps 1–6 of /validate-artifact, on
         {path}. Pick the dimension set for this artifact type. Re-read fresh
         each round; classify severity per Pattern 2; fix every issue in place.
       - HALT after Step 6 at consecutive_clean = 1. Do NOT spawn a checker.
         Do NOT invoke the /validate-artifact command. Return a short verdict
         (path taken — Quick or Standard — and consecutive_clean reached).

  B. Apply /validate-artifact path selection. If the artifact is Standard-path
     or risk-triggered, continue to C. If it is Quick-path with no risk
     trigger, skip C: have the primary stamp the Quick-path footer and move on.

  C. YOU (the orchestrator) spawn the validation-checker persona (Haiku) for
     {path}, with its dimension list and governing references. The checker
     re-reads cold and reports ANY issue (no one-LOW allowance). On any
     finding: re-spawn a fresh primary for {path} (Step A), then re-run the
     checker. Repeat until the checker replies
     "CONFIRMED: Zero issues found after adversarial review."
     Then stamp the Standard footer.

After every artifact exits clean, report an aggregate: per artifact, the path
taken and clean/needs-work status.
```

## Sequential-list fallback

The handoff prompt is the **recommended** path for ≥2 artifacts, but it is a supplement, not a replacement. Always also print the canonical sequential list for a user who prefers to drive each step:

```text
/clear
/validate-artifact {path-1}
/clear
/validate-artifact {path-2}
...
```

There is no rigor difference between the two paths — both run the full Pattern 1 loop per artifact. The fallback is the slug-resumable path (Principle 1): each `/validate-artifact <path>` is independently runnable by a fresh agent.

## Relationship to single-artifact validation

This is an orchestration layer over the ordinary `/validate-artifact` loop, not a different loop. Anything true of a single-artifact run is true of each artifact in a batch: same dimensions, same severity rubric, same exit criteria, same footer, same no-one-LOW-allowance on the checker. See `validation_exit_criteria.md` for the counter logic and the `/validate-artifact` command body for the canonical 8-step process. If in doubt, fall back to validating one artifact at a time — the result is identical, only slower.
