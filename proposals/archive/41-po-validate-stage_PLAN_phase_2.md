# Implementation Plan — po-validate-stage — Phase 2 (the 6 MOVEs)

**Proposal:** proposals/41-po-validate-stage.md
**Index:** proposals/41-po-validate-stage_PLAN.md
**Scope:** Proposed Changes rows 7–12 — rename the three commands + three skill folders, each via `git mv` (preserve history), each followed by its internal self-label / cross-reference / regen-pointer edits.

> Execute these 6 steps in order. Each step is `git mv` **then** the internal edits to the moved file. **Always `git mv` — never delete+recreate** (preserves blame; verified by the index's whole-plan `git log --follow` check).
>
> Self-references inside a moved file (e.g. `pe2-decompose.md` mentioning `/pe2-decompose`) are fixed *here*, in the same step that moves the file. References to these commands from *other* files are repointed in Phase 3 (named EDITs) and Phase 4 (sweep).

> **Verification ownership:** per-step verifications below are the builder's. The git-history-preserved and no-old-name-remains invariants are whole-plan checks in the INDEX file.

---

## Step 1 — MOVE `commands/pe2-decompose.md` → `commands/pe3-decompose.md` (row 7)

**Operation:** MOVE (`git mv`) + internal edits
**From:** `host/templates/claude/commands/pe2-decompose.md`
**To:** `host/templates/claude/commands/pe3-decompose.md`

**1. Rename:**
```
git mv host/templates/claude/commands/pe2-decompose.md host/templates/claude/commands/pe3-decompose.md
```

**2. Internal edits to `host/templates/claude/commands/pe3-decompose.md`:**

- **EDIT — frontmatter phase label.**
  **Locate:**
  ```
  description: Phase 2 of the PO flow — break a validated epic into N feature stubs via the stub-list-then-drill-in pattern, gating the whole list once and recording parallelization analysis on the parent epic
  ```
  **Replace:**
  ```
  description: Phase 3 of the PO flow — break a validated epic into N feature stubs via the stub-list-then-drill-in pattern, gating the whole list once and recording parallelization analysis on the parent epic
  ```

- **EDIT — H1 + Purpose self-label.**
  **Locate:**
  ```
  # /pe2-decompose

  **Purpose:** Run Phase 2 of the PO flow.
  ```
  **Replace:**
  ```
  # /pe3-decompose

  **Purpose:** Run Phase 3 of the PO flow.
  ```

- **EDIT — Usage line.**
  **Locate:** `/pe2-decompose {slug} [--allow-unvalidated]`
  **Replace:** `/pe3-decompose {slug} [--allow-unvalidated]`

- **EDIT — `--allow-unvalidated` args description repoint.**
  **Locate:** `rerun `/validate-artifact` afterwards. The recommended path is to validate first.`
  **Replace:** `rerun `/pe2-validate {slug}` after decomposition. The recommended path is to validate first.`

- **EDIT — prerequisite repoint (prereq line → `/pe2-validate`).**
  **Locate:**
  ```
  - `epic.md` should carry a `Validated …` footer. If it does not, halt with a clear message and direct the user to `/validate-artifact epics/{slug}-*/epic.md` — unless `--allow-unvalidated` is passed.
  ```
  **Replace:**
  ```
  - `epic.md` should carry a `Validated …` footer. If it does not, halt with a clear message and direct the user to `/pe2-validate {slug}` (the epic-altitude validate stage) — unless `--allow-unvalidated` is passed.
  ```

- **EDIT — Step 2 halt message repoint.**
  **Locate:**
  ```
  3. Otherwise, **halt** with: `epic.md is not validated — run /validate-artifact epics/{ID}-{slug}-{brief}/epic.md first, or re-invoke with --allow-unvalidated to proceed against the draft.`
  ```
  **Replace:**
  ```
  3. Otherwise, **halt** with: `epic.md is not validated — run /pe2-validate {slug} first, or re-invoke with --allow-unvalidated to proceed against the draft.`
  ```

- **EDIT — `--allow-unvalidated` notice repoint.**
  **Locate:** `4. If `--allow-unvalidated` was passed, surface a one-line notice (`proceeding against an unvalidated epic — re-run /validate-artifact after decomposition`) and continue.`
  **Replace:** `4. If `--allow-unvalidated` was passed, surface a one-line notice (`proceeding against an unvalidated epic — re-run /pe2-validate after decomposition`) and continue.`

- **EDIT — Step 8 feature-stub validation reference.**
  **Locate:** `- No `Validated …` footer — that comes from `/validate-artifact` once `/pf1-define` finishes.`
  **Replace:** `- No `Validated …` footer — that comes from `/pf2-validate {feature-slug}` once `/pf1-define` finishes.`

- **EDIT — next-phase suggestion repoint (Step 11 already points at `/pf1-define`, which is unchanged) AND the Notes line that names `/validate-artifact` as the epic-level validation.**
  **Locate:**
  ```
  - **Decomposition exit gate ≠ `/validate-artifact`.** The gate in Step 6 is a 2-condition stub-batch check run **before** stubs are written; `/validate-artifact` is the full Pattern 1 loop that runs against `epic.md` (already, before `/pe2-decompose`) and against each `feature.md` (later, after `/pf1-define` completes its dialog). Do not conflate the two.
  ```
  **Replace:**
  ```
  - **Decomposition exit gate ≠ `/validate-artifact`.** The gate in Step 6 is a 2-condition stub-batch check run **before** stubs are written; `/validate-artifact` is the full Pattern 1 loop that runs against `epic.md` (already, via `/pe2-validate`, before `/pe3-decompose`) and against each `feature.md` (later, via `/pf2-validate`, after `/pf1-define` completes its dialog). Do not conflate the two.
  ```

- **EDIT — Single-add-alternative Notes line self-reference.**
  **Locate:** `the user wants. Re-running `/pe2-decompose` re-presents and re-gates the *entire* feature list`
  (full line:)
  ```
  - **Single-add alternative — `/pf0-draft`.** To add just **one** feature to an already-decomposed epic, prefer `/pf0-draft {epic-slug}` (the incremental single-stub producer, which appends one feature stub to this epic's `## Target Features` without re-gating) rather than re-running this batch decompose. Re-running `/pe2-decompose` re-presents and re-gates the *entire* feature list (Step 3 re-decomposition partition); the single-add path skips that.
  ```
  **Replace:**
  ```
  - **Single-add alternative — `/pf0-draft`.** To add just **one** feature to an already-decomposed epic, prefer `/pf0-draft {epic-slug}` (the incremental single-stub producer, which appends one feature stub to this epic's `## Target Features` without re-gating) rather than re-running this batch decompose. Re-running `/pe3-decompose` re-presents and re-gates the *entire* feature list (Step 3 re-decomposition partition); the single-add path skips that.
  ```

- **EDIT — regen pointer comment.**
  **Locate:** `<!-- Managed by Shamt — do not edit. Regenerate from shamt-core/host/templates/claude/commands/pe2-decompose.md. -->`
  **Replace:** `<!-- Managed by Shamt — do not edit. Regenerate from shamt-core/host/templates/claude/commands/pe3-decompose.md. -->`

**Verification:**
- `test -f host/templates/claude/commands/pe3-decompose.md && ! test -f host/templates/claude/commands/pe2-decompose.md` (renamed, old gone).
- `grep -c 'pe2-decompose' host/templates/claude/commands/pe3-decompose.md` returns 0 (no self-reference to the old name survives).
- `grep -F '# /pe3-decompose' host/templates/claude/commands/pe3-decompose.md` returns 1.
- `grep -F 'Regenerate from shamt-core/host/templates/claude/commands/pe3-decompose.md' host/templates/claude/commands/pe3-decompose.md` returns 1.
- `grep -c '/pe2-validate' host/templates/claude/commands/pe3-decompose.md` returns ≥5 (args-description line ~22, prereq line ~27, halt message ~45, notice ~46, and Notes conflate-warning ~191 — all `validate-artifact` prereq/halt/notice/args references replaced; Step 8 feature-stub note uses `/pf2-validate` not `/pe2-validate`).
- `grep -c '/pf2-validate' host/templates/claude/commands/pe3-decompose.md` returns ≥1 (Step 8 feature-stub note ~117 and Notes conflate-warning ~191).
- `grep -c 'validate-artifact' host/templates/claude/commands/pe3-decompose.md` returns exactly 4 (two "distinct from" comparisons at lines ~91 and ~95 left as-is, plus the two occurrences on the Notes conflate-warning line ~191 that stay as the tool name but with updated context; no prereq-invocation form survives).

---

## Step 2 — MOVE `commands/pe3-finalize.md` → `commands/pe4-finalize.md` (row 8)

**Operation:** MOVE (`git mv`) + internal edits
**From:** `host/templates/claude/commands/pe3-finalize.md`
**To:** `host/templates/claude/commands/pe4-finalize.md`

**1. Rename:**
```
git mv host/templates/claude/commands/pe3-finalize.md host/templates/claude/commands/pe4-finalize.md
```

**2. Internal edits to `host/templates/claude/commands/pe4-finalize.md`:**

- **EDIT — frontmatter phase label.**
  **Locate:**
  ```
  description: Phase 5 (Finalize) of the Shamt PO flow at the Epic altitude — guard that every child feature/story is finalized, commit, mark the epic done via the active tracker, and move the done epic subtree into epics/archive/ (a whole-subtree move under the nested layout)
  ```
  **Replace:** (only the phase number; keep the rest verbatim)
  ```
  description: Phase 4 (Finalize) of the Shamt PO flow at the Epic altitude — guard that every child feature/story is finalized, commit, mark the epic done via the active tracker, and move the done epic subtree into epics/archive/ (a whole-subtree move under the nested layout)
  ```
  > NOTE: the proposal row 8 says self-labels "Phase 3" → "Phase 4". The frontmatter currently reads "Phase 5". Resolve the *command-stage* label (the `pe{N}` stage number 3→4), which is what the rename encodes; the parenthetical "(Finalize)" prose stage number in the description was already "Phase 5" pre-existing. Update it to "Phase 4" to match the new `pe4` stage so the stage number and the prose number agree. (If a parallel session has already reconciled this differently, accept the in-tree value and only ensure no `pe3-finalize` self-reference survives.)

- **EDIT — H1.**
  **Locate:** `# /pe3-finalize`
  **Replace:** `# /pe4-finalize`

- **EDIT — Usage line.**
  **Locate:** `/pe3-finalize {slug}`
  **Replace:** `/pe4-finalize {slug}`

- **EDIT — regen pointer comment.**
  **Locate:** `<!-- Managed by Shamt — do not edit. Regenerate from shamt-core/host/templates/claude/commands/pe3-finalize.md. -->`
  **Replace:** `<!-- Managed by Shamt — do not edit. Regenerate from shamt-core/host/templates/claude/commands/pe4-finalize.md. -->`

- **NOTE — no prereq reference to the decompose stage exists in this file.** `pe3-finalize.md` does not name `/pe2-decompose` anywhere (confirmed by grep — its only renamed-command hits are its own `pe3-finalize` self-references). So the row-8 "any prereq references to the decompose stage → `/pe3-decompose`" clause is a **no-op for this file**; no such reference exists. Do not invent one.

**Verification:**
- `test -f host/templates/claude/commands/pe4-finalize.md && ! test -f host/templates/claude/commands/pe3-finalize.md`.
- `grep -c 'pe3-finalize' host/templates/claude/commands/pe4-finalize.md` returns 0.
- `grep -F '# /pe4-finalize' host/templates/claude/commands/pe4-finalize.md` returns 1.
- `grep -F 'Regenerate from shamt-core/host/templates/claude/commands/pe4-finalize.md' host/templates/claude/commands/pe4-finalize.md` returns 1.

---

## Step 3 — MOVE `commands/pf2-decompose.md` → `commands/pf3-decompose.md` (row 9)

**Operation:** MOVE (`git mv`) + internal edits
**From:** `host/templates/claude/commands/pf2-decompose.md`
**To:** `host/templates/claude/commands/pf3-decompose.md`

**1. Rename:**
```
git mv host/templates/claude/commands/pf2-decompose.md host/templates/claude/commands/pf3-decompose.md
```

**2. Internal edits to `host/templates/claude/commands/pf3-decompose.md`** — this file has many `pf2-decompose` self-references AND `/pe2-decompose` cross-references (which become `/pe3-decompose`). Apply each:

- **EDIT — H1.**
  **Locate:** `# /pf2-decompose`
  **Replace:** `# /pf3-decompose`

- **EDIT — Usage line.**
  **Locate:** `/pf2-decompose {slug} [--allow-unvalidated]`
  **Replace:** `/pf3-decompose {slug} [--allow-unvalidated]`

- **EDIT — frontmatter / Purpose phase label.** Open the file; in the frontmatter `description:` and the `**Purpose:** Run Phase 4 of the PO flow` line, update the PO-flow phase number consistent with the new stage. The feature-decompose was "Phase 4" in the prose; with validate inserted as a stage the feature-decompose stage becomes `pf3`. Update the **command-stage** numbering in any self-label to read `pf3`/the new stage number; **do not** alter the conceptual "Phase 4 of the PO flow" prose unless it embeds the literal `pf2`/`/pf2-decompose` token. (The load-bearing rename is the `/pf2-decompose` → `/pf3-decompose` token everywhere; the abstract "Phase N" prose count is reconciled by the README phase-number edit in Phase 3 S5.)
  > Builder: the deterministic operation is **replace every literal `pf2-decompose` token with `pf3-decompose`** in this file (covers H1, usage, `--allow-unvalidated` "Same semantics as `/pe2-decompose`'s flag" — that one is a `pe2` ref, handled below — and the regen pointer). The "Phase N" prose has no `pf2` token and is left to the README reconciliation.

- **EDIT — replace every remaining `pf2-decompose` token with `pf3-decompose`, and every `pe2-decompose` cross-reference with `pe3-decompose`.** Concretely (per the plan-time grep — all occurrences in the file not already covered by H1 / Usage / regen-pointer / frontmatter edits above):
  **`pf2-decompose` → `pf3-decompose` occurrences remaining after H1+Usage+regen-pointer edits:**
  - Decomposition exit gate Notes line (~236): `(already, before \`/pf2-decompose\`)` — one token on this line.
  - Single-add `/ps0-draft` Notes line (~241): `Re-running \`/pf2-decompose\` re-presents and re-gates`.
  - Parent-slug batch-mode Notes paragraph (~244): `batch \`/pf2-decompose\` over an epic`.
  **`pe2-decompose` → `pe3-decompose` occurrences** (cross-references to the epic-decompose command, all on separate lines):
  - Recommended model (~9): `Same justification as \`/pe2-decompose\`.`
  - `--allow-unvalidated` description (~22): `Same semantics as \`/pe2-decompose\`'s flag of the same name.`
  - Re-decomposition Step 3 (~68): `Same partition rule as \`/pe2-decompose\` Step 3.`
  - Re-decomposition Step 4 Kept exception (~95): `Same Kept-exception rule as \`/pe2-decompose\`.`
  - Step 9 slug-only format (~158): `Same format as \`/pe2-decompose\` Step 9.`
  - Orphan-warning format (~179): `Same format as \`/pe2-decompose\`'s orphan warning.`
  - Empty-parent message (~218): `run the decompose phase (/pe2-decompose {slug}) first` — covered by the dedicated EDIT below.
  Use `git grep -n 'pf2-decompose\|pe2-decompose' host/templates/claude/commands/pf3-decompose.md` after the rename to confirm the above list is exhaustive; the result must be empty after all edits.

- **EDIT — prerequisite repoint to `/pf2-validate`.** Four locations in the file direct the user to run `/validate-artifact` as a prerequisite or notice — repoint each to `/pf2-validate {slug}`. The "distinct from `/validate-artifact`" comparisons (decomposition exit gate Notes, Step 6 gate text) are **left as-is** — they name the Pattern-1 tool concept, not a user-invoked prereq. Apply exactly these four:
  1. **Prerequisites line** (line ~27): `halt with a clear message and direct the user to \`/validate-artifact\` on the feature's path` → `halt with a clear message and direct the user to \`/pf2-validate {slug}\` (the feature-altitude validate stage)`.
  2. **Step 2.3 halt message** (line ~53): `feature.md is not validated — run /validate-artifact epics/{epic-folder}/features/{ID}-{slug}-{brief}/feature.md first, or re-invoke with --allow-unvalidated to proceed against the draft.` → `feature.md is not validated — run /pf2-validate {slug} first, or re-invoke with --allow-unvalidated to proceed against the draft.`
  3. **Step 2.4 `--allow-unvalidated` notice** (line ~54): `proceeding against an unvalidated feature — re-run /validate-artifact after decomposition` → `proceeding against an unvalidated feature — re-run /pf2-validate after decomposition`.
  4. **Batch mode halt-at-feature** (line ~220): `direct the user to \`/pf1-define {feature-slug}\` + \`/validate-artifact\` it` → `direct the user to \`/pf1-define {feature-slug}\` + \`/pf2-validate {feature-slug}\``.
  Additionally, the conflate-warning Notes line (line ~236, already covered by the `pf2-decompose`→`pf3-decompose` EDIT above) updates its context to "(already, via `/pf2-validate`, before `/pf3-decompose`)".
  Also update the `--allow-unvalidated` Arguments description (line ~22): `rerun \`/validate-artifact\` afterwards` → `rerun \`/pf2-validate {slug}\` after decomposition`.
  > Builder: verify with `git grep -n 'validate-artifact' host/templates/claude/commands/pf3-decompose.md`; the only survivors should be the "distinct from `/validate-artifact`" comparisons at the Step 6 gate check lines (lines ~119 and ~123) — those remain unchanged, naming the tool concept, not a prereq invocation.

- **EDIT — empty-parent message (parent-slug batch mode) decompose-name + cross-name.**
  **Locate:**
  ```
   report `parent {slug} has no children to process — run the decompose phase (/pe2-decompose {slug}) first`
  ```
  **Replace:**
  ```
   report `parent {slug} has no children to process — run the decompose phase (/pe3-decompose {slug}) first`
  ```

- **EDIT — regen pointer comment.**
  **Locate:** `<!-- Managed by Shamt — do not edit. Regenerate from shamt-core/host/templates/claude/commands/pf2-decompose.md. -->`
  **Replace:** `<!-- Managed by Shamt — do not edit. Regenerate from shamt-core/host/templates/claude/commands/pf3-decompose.md. -->`

**Verification:**
- `test -f host/templates/claude/commands/pf3-decompose.md && ! test -f host/templates/claude/commands/pf2-decompose.md`.
- `grep -c 'pf2-decompose' host/templates/claude/commands/pf3-decompose.md` returns 0.
- `grep -c 'pe2-decompose' host/templates/claude/commands/pf3-decompose.md` returns 0 (cross-references repointed to `pe3-decompose`).
- `grep -F '# /pf3-decompose' host/templates/claude/commands/pf3-decompose.md` returns 1.
- `grep -c '/pf2-validate' host/templates/claude/commands/pf3-decompose.md` returns ≥5 (all prereq/halt/notice/batch-halt/args references repointed — lines ~22, ~27, ~53, ~54, ~220 each get one).
- `grep -c 'validate-artifact' host/templates/claude/commands/pf3-decompose.md` returns exactly 4 (the two "distinct from" comparisons left as-is at lines ~119 and ~123, plus the two occurrences in the conflate-warning Notes line ~236 — heading "Decomposition exit gate ≠ \`/validate-artifact\`" and the sentence "\`/validate-artifact\` is the full Pattern 1 loop" — both of which stay but the line's parenthetical context updates to "already, via \`/pf2-validate\`, before \`/pf3-decompose\`"; no prereq-invocation form of \`/validate-artifact\` survives).
- `grep -F 'Regenerate from shamt-core/host/templates/claude/commands/pf3-decompose.md' host/templates/claude/commands/pf3-decompose.md` returns 1.

---

## Step 4 — MOVE `skills/pe2-decompose/` → `skills/pe3-decompose/` (row 10)

**Operation:** MOVE (`git mv` the folder) + internal edits to the single `SKILL.md`
**From:** `host/templates/claude/skills/pe2-decompose/`
**To:** `host/templates/claude/skills/pe3-decompose/`

**1. Rename the folder:**
```
git mv host/templates/claude/skills/pe2-decompose host/templates/claude/skills/pe3-decompose
```

**2. Internal edits to `host/templates/claude/skills/pe3-decompose/SKILL.md`:**

- **EDIT — frontmatter name.**
  **Locate:** `name: pe2-decompose`
  **Replace:** `name: pe3-decompose`

- **EDIT — description phase label.**
  **Locate:** `Run Phase 2 of the Shamt PO flow at the Epic altitude.`
  **Replace:** `Run Phase 3 of the Shamt PO flow at the Epic altitude.`

- **EDIT — description deferral reference (`/pf1-define` unchanged) — no token change needed there. Update the Overview + Protocol pointer.**
  **Locate:**
  ```
  Mirrors the `/pe2-decompose {slug}` slash command. Same canonical body, two host wirings.

  ## Protocol

  Follow the canonical `/pe2-decompose` command body verbatim — see [`commands/pe2-decompose.md`](../../commands/pe2-decompose.md).
  ```
  **Replace:**
  ```
  Mirrors the `/pe3-decompose {slug}` slash command. Same canonical body, two host wirings.

  ## Protocol

  Follow the canonical `/pe3-decompose` command body verbatim — see [`commands/pe3-decompose.md`](../../commands/pe3-decompose.md).
  ```

- **EDIT — Key distinctions "Decomposition exit gate" validate reference.**
  **Locate:**
  ```
  - **Decomposition exit gate ≠ `/validate-artifact`.** The gate is a 2-condition stub-batch check run **before** stubs land on disk. `/validate-artifact` runs the full Pattern 1 loop against `epic.md` (already, before this command) and against each `feature.md` (later, after `/pf1-define` completes its dialog). Do not conflate.
  ```
  **Replace:**
  ```
  - **Decomposition exit gate ≠ `/validate-artifact`.** The gate is a 2-condition stub-batch check run **before** stubs land on disk. `/validate-artifact` runs the full Pattern 1 loop against `epic.md` (already, via `/pe2-validate`, before `/pe3-decompose`) and against each `feature.md` (later, via `/pf2-validate`, after `/pf1-define` completes its dialog). Do not conflate.
  ```

- **EDIT — Key distinctions "No tracker fetch" self-reference.**
  **Locate:** `- **No tracker fetch** at this altitude — `/pe2-decompose` operates entirely on the already-written `epic.md`.`
  **Replace:** `- **No tracker fetch** at this altitude — `/pe3-decompose` operates entirely on the already-written `epic.md`.`

- **EDIT — regen pointer comment.**
  **Locate:** `<!-- Managed by Shamt — do not edit. Regenerate from shamt-core/host/templates/claude/skills/pe2-decompose/SKILL.md. -->`
  **Replace:** `<!-- Managed by Shamt — do not edit. Regenerate from shamt-core/host/templates/claude/skills/pe3-decompose/SKILL.md. -->`

> NOTE — the description triggers (`decompose epic`, `decompose {epic-slug}`, etc.) contain no command-name token and are left unchanged. The `## Recommended model` line cites "Same justification as `/pe2-decompose`" — wait: it does not (that phrasing is in `pf2-decompose`'s skill, not `pe2-decompose`'s). Confirm with the grep below; if any `pe2-decompose` token remains after the edits above, replace it with `pe3-decompose`.

**Verification:**
- `test -f host/templates/claude/skills/pe3-decompose/SKILL.md && ! test -d host/templates/claude/skills/pe2-decompose`.
- `grep -c 'pe2-decompose' host/templates/claude/skills/pe3-decompose/SKILL.md` returns 0.
- `grep -F 'name: pe3-decompose' host/templates/claude/skills/pe3-decompose/SKILL.md` returns 1.
- `grep -F 'Follow the canonical `/pe3-decompose` command body verbatim' host/templates/claude/skills/pe3-decompose/SKILL.md` returns 1 (Protocol stays the pointer).
- `grep -F 'Regenerate from shamt-core/host/templates/claude/skills/pe3-decompose/SKILL.md' host/templates/claude/skills/pe3-decompose/SKILL.md` returns 1.

---

## Step 5 — MOVE `skills/pe3-finalize/` → `skills/pe4-finalize/` (row 11)

**Operation:** MOVE (`git mv` the folder) + internal edits to the single `SKILL.md`
**From:** `host/templates/claude/skills/pe3-finalize/`
**To:** `host/templates/claude/skills/pe4-finalize/`

**1. Rename the folder:**
```
git mv host/templates/claude/skills/pe3-finalize host/templates/claude/skills/pe4-finalize
```

**2. Internal edits to `host/templates/claude/skills/pe4-finalize/SKILL.md`:**

- **EDIT — frontmatter name.**
  **Locate:** `name: pe3-finalize`
  **Replace:** `name: pe4-finalize`

- **EDIT — Overview + Protocol pointer.**
  **Locate:**
  ```
  Mirrors the `/pe3-finalize {slug}` slash command. Same canonical body, two host wirings. The terminal PO-flow command at the Epic altitude, modelled on `/f6-archive-proposal`.

  ## Protocol

  Follow the canonical `/pe3-finalize` command body verbatim — see [`commands/pe3-finalize.md`](../../commands/pe3-finalize.md).
  ```
  **Replace:**
  ```
  Mirrors the `/pe4-finalize {slug}` slash command. Same canonical body, two host wirings. The terminal PO-flow command at the Epic altitude, modelled on `/f6-archive-proposal`.

  ## Protocol

  Follow the canonical `/pe4-finalize` command body verbatim — see [`commands/pe4-finalize.md`](../../commands/pe4-finalize.md).
  ```

- **EDIT — regen pointer comment.**
  **Locate:** `<!-- Managed by Shamt — do not edit. Regenerate from shamt-core/host/templates/claude/skills/pe3-finalize/SKILL.md. -->`
  **Replace:** `<!-- Managed by Shamt — do not edit. Regenerate from shamt-core/host/templates/claude/skills/pe4-finalize/SKILL.md. -->`

> NOTE — the triggers (`finalize the epic`, etc.) carry no command-name token; left unchanged.

**Verification:**
- `test -f host/templates/claude/skills/pe4-finalize/SKILL.md && ! test -d host/templates/claude/skills/pe3-finalize`.
- `grep -c 'pe3-finalize' host/templates/claude/skills/pe4-finalize/SKILL.md` returns 0.
- `grep -F 'name: pe4-finalize' host/templates/claude/skills/pe4-finalize/SKILL.md` returns 1.
- `grep -F 'Follow the canonical `/pe4-finalize` command body verbatim' host/templates/claude/skills/pe4-finalize/SKILL.md` returns 1.
- `grep -F 'Regenerate from shamt-core/host/templates/claude/skills/pe4-finalize/SKILL.md' host/templates/claude/skills/pe4-finalize/SKILL.md` returns 1.

---

## Step 6 — MOVE `skills/pf2-decompose/` → `skills/pf3-decompose/` (row 12)

**Operation:** MOVE (`git mv` the folder) + internal edits to the single `SKILL.md`
**From:** `host/templates/claude/skills/pf2-decompose/`
**To:** `host/templates/claude/skills/pf3-decompose/`

**1. Rename the folder:**
```
git mv host/templates/claude/skills/pf2-decompose host/templates/claude/skills/pf3-decompose
```

**2. Internal edits to `host/templates/claude/skills/pf3-decompose/SKILL.md`** — has both `pf2-decompose` self-refs and `/pe2-decompose` cross-refs and a batch-mode description block:

- **EDIT — frontmatter name.**
  **Locate:** `name: pf2-decompose`
  **Replace:** `name: pf3-decompose`

- **EDIT — description phase label.**
  **Locate:** `Run Phase 4 of the Shamt PO flow at the Feature altitude.`
  **Replace:** `Run Phase 5 of the Shamt PO flow at the Feature altitude.`
  > Builder: the feature-decompose prose phase number was "Phase 4"; with validate inserted the abstract conceptual count shifts. The load-bearing operation is the `pf2-decompose` → `pf3-decompose` token rename; if the "Phase N" prose count is contentious, leave it and let the README reconciliation (Phase 3 S5) govern the canonical phase-number narrative — but DO update the command-name token everywhere. (Accept the in-tree value if a parallel session already reconciled the prose count.)

- **EDIT — description batch-mode `/e1-start-story` deferral + epic-slug clause (no `pf2` token there) — leave. Update the Overview + Protocol pointer:**
  **Locate:**
  ```
  Mirrors the `/pf2-decompose {slug}` slash command. Same canonical body, two host wirings.

  ## Protocol

  Follow the canonical `/pf2-decompose` command body verbatim — see [`commands/pf2-decompose.md`](../../commands/pf2-decompose.md).
  ```
  **Replace:**
  ```
  Mirrors the `/pf3-decompose {slug}` slash command. Same canonical body, two host wirings.

  ## Protocol

  Follow the canonical `/pf3-decompose` command body verbatim — see [`commands/pf3-decompose.md`](../../commands/pf3-decompose.md).
  ```

- **EDIT — Key distinctions "Decomposition exit gate" validate reference.**
  **Locate:**
  ```
  - **Decomposition exit gate ≠ `/validate-artifact`.** The gate is a 2-condition stub-batch check run **before** stubs land on disk. `/validate-artifact` runs the full Pattern 1 loop against `feature.md` (already, before this command) and against each story-level artifact (later, via the Engineer flow). Do not conflate.
  ```
  **Replace:**
  ```
  - **Decomposition exit gate ≠ `/validate-artifact`.** The gate is a 2-condition stub-batch check run **before** stubs land on disk. `/validate-artifact` runs the full Pattern 1 loop against `feature.md` (already, via `/pf2-validate`, before `/pf3-decompose`) and against each story-level artifact (later, via the Engineer flow). Do not conflate.
  ```

- **EDIT — Key distinctions "No tracker fetch" self-reference.**
  **Locate:** `- **No tracker fetch** at this altitude — `/pf2-decompose` operates entirely on the already-written `feature.md`. The active tracker is read only to pick the **ticket template** for the stub bodies (Step 8).`
  **Replace:** `- **No tracker fetch** at this altitude — `/pf3-decompose` operates entirely on the already-written `feature.md`. The active tracker is read only to pick the **ticket template** for the stub bodies (Step 8).`

- **EDIT — `## Recommended model` cross-reference.**
  **Locate:** `all benefit from Opus's reasoning depth. Same justification as `/pe2-decompose`.`
  **Replace:** `all benefit from Opus's reasoning depth. Same justification as `/pe3-decompose`.`

- **EDIT — regen pointer comment.**
  **Locate:** `<!-- Managed by Shamt — do not edit. Regenerate from shamt-core/host/templates/claude/skills/pf2-decompose/SKILL.md. -->`
  **Replace:** `<!-- Managed by Shamt — do not edit. Regenerate from shamt-core/host/templates/claude/skills/pf3-decompose/SKILL.md. -->`

> Builder: after the edits above, run `git grep -n 'pf2-decompose\|pe2-decompose' host/templates/claude/skills/pf3-decompose/SKILL.md`; replace any surviving token (`pf2-decompose`→`pf3-decompose`, `pe2-decompose`→`pe3-decompose`).

**Verification:**
- `test -f host/templates/claude/skills/pf3-decompose/SKILL.md && ! test -d host/templates/claude/skills/pf2-decompose`.
- `grep -c 'pf2-decompose' host/templates/claude/skills/pf3-decompose/SKILL.md` returns 0.
- `grep -c 'pe2-decompose' host/templates/claude/skills/pf3-decompose/SKILL.md` returns 0.
- `grep -F 'name: pf3-decompose' host/templates/claude/skills/pf3-decompose/SKILL.md` returns 1.
- `grep -F 'Follow the canonical `/pf3-decompose` command body verbatim' host/templates/claude/skills/pf3-decompose/SKILL.md` returns 1.
- `grep -F 'Regenerate from shamt-core/host/templates/claude/skills/pf3-decompose/SKILL.md' host/templates/claude/skills/pf3-decompose/SKILL.md` returns 1.

---
Validated 2026-06-19 — 3 rounds, 1 adversarial sub-agent confirmed
