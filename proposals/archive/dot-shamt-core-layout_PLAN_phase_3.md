# Implementation Plan — Phase 3: Commands

**Parent plan:** [`dot-shamt-core-layout_PLAN.md`](dot-shamt-core-layout_PLAN.md)
**Proposal:** proposals/dot-shamt-core-layout.md
**Surface:** 18 `host/templates/claude/commands/*.md` files (Groups C1, C2, D1, E1, F1, F2, F3 — merged per file).

Pure path sweeps per the [four conventions](dot-shamt-core-layout_PLAN.md#replacement-conventions-the-four-mechanical-sweeps). One step per file; all of a file's edits are merged into its step. The four master-side framework-update commands — `triage-proposals.md`, `archive-proposal.md`, `implement-update.md`, `plan-update-implementation.md` — are **NOT** in this phase (their `proposals/` refs are master-canonical; F1-excl).

## Files manifest

| # | File | Sweeps |
|---|------|--------|
| 1 | `start-epic.md` | D (config ×5) + E (docs) |
| 2 | `start-feature.md` | D (config ×5) + E (docs) |
| 3 | `start-story.md` | D (config ×4) |
| 4 | `define-spec.md` | D (config) + E (docs) |
| 5 | `plan-implementation.md` | D (config) + E (docs) |
| 6 | `execute-plan.md` | D (config) |
| 7 | `execute-tests.md` | D (config) |
| 8 | `decompose-feature.md` | D (config) |
| 9 | `review-changes.md` | D (config) + E (docs) |
| 10 | `resolve-feedback.md` | E (docs) + F2 (proposals) |
| 11 | `write-testing-plan.md` | D (config) + E (docs) |
| 12 | `write-manual-testing-plan.md` | D (config) + E (docs) |
| 13 | `validate-artifact.md` | E (docs ×4); proposals examples left (allow-list) |
| 14 | `audit-framework.md` | D (config) + E (docs) + F3 (`proposals/_template.md`); regen-path left |
| 15 | `propose-update.md` | F1 (proposals) |
| 16 | `submit-proposal.md` | D (config) + F1 (proposals); `incoming/` left |
| 17 | `import-shamt.md` | C1 (install-path) + D (config) + F1 (proposals) |
| 18 | `regen-framework.md` | C2 (install-path) + D (config); self-host rule left |

---

## Step 1 — `start-epic.md`

**Operation:** EDIT · **File:** `host/templates/claude/commands/start-epic.md`

Config occurrences: lines 24, 28, 35, 164, **168**. Doc occurrences: lines 99 (heading — repoint per architect ruling), 103, 104, 105, 164, 167.

**O1 (24):** `The default comes from \`shamt-config.json\`.` → `The default comes from \`.shamt-core/shamt-config.json\`.`
**O2 (28):** ``- `shamt-config.json` must exist at the project root.`` → ``- `.shamt-core/shamt-config.json` must exist at the project root.``
**O3 (35):** ``1. Read `shamt-config.json` from the project root.`` → ``1. Read `.shamt-core/shamt-config.json` from the project root.``
**O4 (99) — heading:**
Locate: `### Step 5 — Consult \`ARCHITECTURE.md\` (advisory)`
Replace: `### Step 5 — Consult \`.shamt-core/project-specific-files/ARCHITECTURE.md\` (advisory)`
**O5 (103):** replace all three `ARCHITECTURE.md` in the line
Locate:
```
1. Read `ARCHITECTURE.md` (project root) while drafting. **If the file does not exist**, note its absence in chat (a single line: `ARCHITECTURE.md not found — proceeding without architecture consult; bootstrap via init-shamt is the canonical fix per §1.12.`) and continue. Do **not** halt — `ARCHITECTURE.md` is governing when present (per the SHAMT_RULES Standards check invariant) but the epic-altitude consult is advisory; missing the file degrades the consult, not the command. Per the SHAMT_RULES Global Story Invariants "Standards check" rule.
```
Replace:
```
1. Read `.shamt-core/project-specific-files/ARCHITECTURE.md` (project root) while drafting. **If the file does not exist**, note its absence in chat (a single line: `.shamt-core/project-specific-files/ARCHITECTURE.md not found — proceeding without architecture consult; bootstrap via init-shamt is the canonical fix per §1.12.`) and continue. Do **not** halt — `.shamt-core/project-specific-files/ARCHITECTURE.md` is governing when present (per the SHAMT_RULES Standards check invariant) but the epic-altitude consult is advisory; missing the file degrades the consult, not the command. Per the SHAMT_RULES Global Story Invariants "Standards check" rule.
```
**O6 (104):** repoint only the `ARCHITECTURE.md` file ref (leave the `**Architecture impact:**` label)
Locate: ``Omit the flag entirely when no architectural change is implied (or when `ARCHITECTURE.md` is absent and the impact cannot be assessed against a baseline — note the same in chat).``
Replace: ``Omit the flag entirely when no architectural change is implied (or when `.shamt-core/project-specific-files/ARCHITECTURE.md` is absent and the impact cannot be assessed against a baseline — note the same in chat).``
**O7 (105):**
Locate: ``3. **Do not consult `CODING_STANDARDS.md`** — coding style is irrelevant at the epic altitude. The story-altitude Phase 2 / Phase 6 / Phase 7 cycle handles coding-standards alignment for any code changes the epic eventually produces.``
Replace: ``3. **Do not consult `.shamt-core/project-specific-files/CODING_STANDARDS.md`** — coding style is irrelevant at the epic altitude. The story-altitude Phase 2 / Phase 6 / Phase 7 cycle handles coding-standards alignment for any code changes the epic eventually produces.``
**O8 (164):** fresh-agent note — repoint both config + doc
Locate: ``- **Fresh-agent runnable.** Every input lives on disk (`shamt-config.json`, the tracker profile, `ARCHITECTURE.md`, the prior draft when re-entering). No conversation history required.``
Replace: ``- **Fresh-agent runnable.** Every input lives on disk (`.shamt-core/shamt-config.json`, the tracker profile, `.shamt-core/project-specific-files/ARCHITECTURE.md`, the prior draft when re-entering). No conversation history required.``
**O9 (167):**
Locate: ``- **No `CODING_STANDARDS.md` consult.** Coding style is irrelevant at the epic altitude per §1.12 PO-threading row. The story-level Phase 2 / 6 / 7 cycle handles coding-standards alignment for the eventual code work.``
Replace: ``- **No `.shamt-core/project-specific-files/CODING_STANDARDS.md` consult.** Coding style is irrelevant at the epic altitude per §1.12 PO-threading row. The story-level Phase 2 / 6 / 7 cycle handles coding-standards alignment for the eventual code work.``
**O10 (168) — the missed config occurrence:**
Locate: ``- The `--tracker=` flag is **one-off**, not persisted. The project default in `shamt-config.json` is unchanged.``
Replace: ``- The `--tracker=` flag is **one-off**, not persisted. The project default in `.shamt-core/shamt-config.json` is unchanged.``

**Verification:**
- `grep -nE '(^|[^./a-z-])shamt-config\.json' host/templates/claude/commands/start-epic.md` → 0
- `grep -nE '(^|[^./a-z-])ARCHITECTURE\.md|(^|[^./a-z-])CODING_STANDARDS\.md' host/templates/claude/commands/start-epic.md` → 0 (the `**Architecture impact:**` label is excluded by the regex)
- `grep -c '#consult-architecturemd' host/templates/claude/commands/start-epic.md` → 0 (no inbound anchor link broken by the heading repoint)

---

## Step 2 — `start-feature.md`

**Operation:** EDIT · **File:** `host/templates/claude/commands/start-feature.md`

Config: 24, 29, 36, 193, **197**. Docs: 124 (heading), 128, 129, 130, 193, 196.

**O1 (24):** `The default comes from \`shamt-config.json\`.` → `.shamt-core/shamt-config.json`
**O2 (29):** ``- `shamt-config.json` must exist at the project root.`` → `.shamt-core/shamt-config.json`
**O3 (36):** ``1. Read `shamt-config.json` from the project root.`` → `.shamt-core/shamt-config.json`
**O4 (124) — heading:** `### Step 5 — Consult \`ARCHITECTURE.md\` (advisory)` → `### Step 5 — Consult \`.shamt-core/project-specific-files/ARCHITECTURE.md\` (advisory)`
**O5 (128):** repoint all three `ARCHITECTURE.md`
Locate:
```
1. Read `ARCHITECTURE.md` (project root) while drafting. **If the file does not exist**, note its absence in chat (a single line: `ARCHITECTURE.md not found — proceeding without architecture consult; bootstrap via init-shamt is the canonical fix per §1.12.`) and continue. Do **not** halt — `ARCHITECTURE.md` is governing when present (per the SHAMT_RULES Standards check invariant) but the feature-altitude consult is advisory; missing the file degrades the consult, not the command. Per the SHAMT_RULES Global Story Invariants "Standards check" rule.
```
Replace:
```
1. Read `.shamt-core/project-specific-files/ARCHITECTURE.md` (project root) while drafting. **If the file does not exist**, note its absence in chat (a single line: `.shamt-core/project-specific-files/ARCHITECTURE.md not found — proceeding without architecture consult; bootstrap via init-shamt is the canonical fix per §1.12.`) and continue. Do **not** halt — `.shamt-core/project-specific-files/ARCHITECTURE.md` is governing when present (per the SHAMT_RULES Standards check invariant) but the feature-altitude consult is advisory; missing the file degrades the consult, not the command. Per the SHAMT_RULES Global Story Invariants "Standards check" rule.
```
**O6 (129):** ``...(or when `ARCHITECTURE.md` is absent...`` → `.shamt-core/project-specific-files/ARCHITECTURE.md` (leave `**Architecture impact:**` label)
Locate: ``Omit the flag entirely when no architectural change is implied (or when `ARCHITECTURE.md` is absent and the impact cannot be assessed against a baseline — note the same in chat).``
Replace: ``Omit the flag entirely when no architectural change is implied (or when `.shamt-core/project-specific-files/ARCHITECTURE.md` is absent and the impact cannot be assessed against a baseline — note the same in chat).``
**O7 (130):**
Locate: ``3. **Do not consult `CODING_STANDARDS.md`** — coding style is irrelevant at the feature altitude. The story-altitude Phase 2 / Phase 6 / Phase 7 cycle handles coding-standards alignment for any code changes the feature eventually produces. Same rule as `/start-epic`.``
Replace: ``3. **Do not consult `.shamt-core/project-specific-files/CODING_STANDARDS.md`** — coding style is irrelevant at the feature altitude. The story-altitude Phase 2 / Phase 6 / Phase 7 cycle handles coding-standards alignment for any code changes the feature eventually produces. Same rule as `/start-epic`.``
**O8 (193):**
Locate: ``- **Fresh-agent runnable.** Every input lives on disk (`shamt-config.json`, the tracker profile, `ARCHITECTURE.md`, the existing stub or prior draft when re-entering). No conversation history required.``
Replace: ``- **Fresh-agent runnable.** Every input lives on disk (`.shamt-core/shamt-config.json`, the tracker profile, `.shamt-core/project-specific-files/ARCHITECTURE.md`, the existing stub or prior draft when re-entering). No conversation history required.``
**O9 (196):**
Locate: ``- **No `CODING_STANDARDS.md` consult.** Coding style is irrelevant at the feature altitude per §1.12 PO-threading row. Same rule as `/start-epic`.``
Replace: ``- **No `.shamt-core/project-specific-files/CODING_STANDARDS.md` consult.** Coding style is irrelevant at the feature altitude per §1.12 PO-threading row. Same rule as `/start-epic`.``
**O10 (197):**
Locate: ``- **`--tracker=` is one-off, not persisted.** The project default in `shamt-config.json` is unchanged. The override only affects Mode C; in Mode A and Mode B it is a no-op (a notice is surfaced when the flag is supplied in those modes).``
Replace: ``- **`--tracker=` is one-off, not persisted.** The project default in `.shamt-core/shamt-config.json` is unchanged. The override only affects Mode C; in Mode A and Mode B it is a no-op (a notice is surfaced when the flag is supplied in those modes).``

**Verification:** `grep -nE '(^|[^./a-z-])shamt-config\.json' …/start-feature.md` → 0; `grep -nE '(^|[^./a-z-])ARCHITECTURE\.md|(^|[^./a-z-])CODING_STANDARDS\.md' …/start-feature.md` → 0; `grep -c '#consult-architecturemd' …/start-feature.md` → 0.

---

## Step 3 — `start-story.md`

**Operation:** EDIT · **File:** `host/templates/claude/commands/start-story.md` · Config: 24, 28, 35, 125.

**O1 (24):** `The default comes from \`shamt-config.json\`.` → `.shamt-core/shamt-config.json`
**O2 (28):** ``- `shamt-config.json` must exist at the project root.`` → `.shamt-core/shamt-config.json`
**O3 (35):** ``1. Read `shamt-config.json` from the project root.`` → `.shamt-core/shamt-config.json`
**O4 (125):**
Locate: ``- The `--tracker=` flag is **one-off**, not persisted. The project default in `shamt-config.json` is unchanged.``
Replace: ``- The `--tracker=` flag is **one-off**, not persisted. The project default in `.shamt-core/shamt-config.json` is unchanged.``

**Verification:** `grep -nE '(^|[^./a-z-])shamt-config\.json' …/start-story.md` → 0; `grep -c '.shamt-core/shamt-config.json' …/start-story.md` → 4.

---

## Step 4 — `define-spec.md`

**Operation:** EDIT · **File:** `host/templates/claude/commands/define-spec.md` · Docs: 33, 55. Config: 102.

**O1 (33):** ``- `ARCHITECTURE.md` and `CODING_STANDARDS.md` exist at the project root.`` (repoint both)
Locate: ``- `ARCHITECTURE.md` and `CODING_STANDARDS.md` exist at the project root. Note their absence inline if either is missing (per the **Standards check** invariant in [`SHAMT_RULES.template.md`](../../../../templates/SHAMT_RULES.template.md#global-story-invariants)) and continue.``
Replace: ``- `.shamt-core/project-specific-files/ARCHITECTURE.md` and `.shamt-core/project-specific-files/CODING_STANDARDS.md` exist at the project root. Note their absence inline if either is missing (per the **Standards check** invariant in [`SHAMT_RULES.template.md`](../../../../templates/SHAMT_RULES.template.md#global-story-invariants)) and continue.``
**O2 (55):**
Locate: ``2. Read the project rules file (rendered from [`SHAMT_RULES.template.md`](../../../../templates/SHAMT_RULES.template.md)) plus `ARCHITECTURE.md` and `CODING_STANDARDS.md` per Pattern 3 Step 2. Record story-specific standards / architecture notes for reuse.``
Replace: ``2. Read the project rules file (rendered from [`SHAMT_RULES.template.md`](../../../../templates/SHAMT_RULES.template.md)) plus `.shamt-core/project-specific-files/ARCHITECTURE.md` and `.shamt-core/project-specific-files/CODING_STANDARDS.md` per Pattern 3 Step 2. Record story-specific standards / architecture notes for reuse.``
**O3 (102):**
Locate: ``- **`Test Strategy`** (when `shamt-config.json` sets `testing: "enabled"`) — see [`SHAMT_RULES.template.md`](../../../../templates/SHAMT_RULES.template.md#when-automated-testing-is-enabled).``
Replace: ``- **`Test Strategy`** (when `.shamt-core/shamt-config.json` sets `testing: "enabled"`) — see [`SHAMT_RULES.template.md`](../../../../templates/SHAMT_RULES.template.md#when-automated-testing-is-enabled).``
*(Note: O3's locate string is the whole bullet; truncate the trailing prose if the executor's Edit needs the full line — match from `- **\`Test Strategy\`**` through `#when-automated-testing-is-enabled).`.)*

**Verification:** `grep -nE '(^|[^./a-z-])shamt-config\.json' …/define-spec.md` → 0; docs regex → 0.

---

## Step 5 — `plan-implementation.md`

**Operation:** EDIT · **File:** `host/templates/claude/commands/plan-implementation.md` · Config: 7, 103. Docs: 90.

**O1 (7):** ``...When `shamt-config.json` sets `testing: "enabled"`, this command also invokes `/write-testing-plan {slug}`...`` → `.shamt-core/shamt-config.json`
Locate: ``**Purpose:** Run the Pattern 5 Implementation Planning protocol on a story whose spec has been approved at Gate 2b. Produce a mechanical, validated `implementation_plan.md` ready for builder handoff. When `shamt-config.json` sets `testing: "enabled"`, this command also invokes `/write-testing-plan {slug}` as a sub-phase before exit.``
Replace: ``**Purpose:** Run the Pattern 5 Implementation Planning protocol on a story whose spec has been approved at Gate 2b. Produce a mechanical, validated `implementation_plan.md` ready for builder handoff. When `.shamt-core/shamt-config.json` sets `testing: "enabled"`, this command also invokes `/write-testing-plan {slug}` as a sub-phase before exit.``
**O2 (90):**
Locate: ``- `CODING_STANDARDS.md`: map each applicable rule to an existing step, new step, or explicit N/A in `## CODING_STANDARDS Compliance`. Merely saying it was read is insufficient.``
Replace: ``- `.shamt-core/project-specific-files/CODING_STANDARDS.md`: map each applicable rule to an existing step, new step, or explicit N/A in `## CODING_STANDARDS Compliance`. Merely saying it was read is insufficient.``
**O3 (103):**
Locate: ``Read `shamt-config.json` → `testing`. If `enabled`, invoke `/write-testing-plan {slug}` as a sub-phase.`` (this leading sentence is unique to line 103 — line 7's mention is worded differently, so this substring alone disambiguates)
Replace: leading `Read `.shamt-core/shamt-config.json` → `testing`.` (same trailing text)

**Verification:** config regex → 0; docs regex → 0.

---

## Step 6 — `execute-plan.md`

**Operation:** EDIT · **File:** `host/templates/claude/commands/execute-plan.md` · Config: 98.

**O1 (98):**
Locate: ``Suggest the next phase based on the project's `shamt-config.json`:``
Replace: ``Suggest the next phase based on the project's `.shamt-core/shamt-config.json`:``

**Verification:** config regex → 0; `grep -c '.shamt-core/shamt-config.json' …/execute-plan.md` → 1.

---

## Step 7 — `execute-tests.md`

**Operation:** EDIT · **File:** `host/templates/claude/commands/execute-tests.md` · Config: 7, 32, 36.

**O1 (7):**
Locate: ``**Purpose:** Run Phase 5 of the Engineer flow when `shamt-config.json` sets `testing: "enabled"`.`` (match full line through `reports \`PASS\`**.`)
Replace: leading `**Purpose:** Run Phase 5 of the Engineer flow when `.shamt-core/shamt-config.json` sets `testing: "enabled"`.` (same trailing text)
**O2 (32):** ``Read `shamt-config.json` → `testing`.`` → ``Read `.shamt-core/shamt-config.json` → `testing`.``
**O3 (36):**
Locate: ``  Testing is disabled in shamt-config.json — Phase 5 is not part of this project's flow. Run /review-changes {slug} next.``
Replace: ``  Testing is disabled in .shamt-core/shamt-config.json — Phase 5 is not part of this project's flow. Run /review-changes {slug} next.``

**Verification:** config regex → 0; `grep -c '.shamt-core/shamt-config.json' …/execute-tests.md` → 3.

---

## Step 8 — `decompose-feature.md`

**Operation:** EDIT · **File:** `host/templates/claude/commands/decompose-feature.md` · Config: 83, 130, 212.

**O1 (83):** ``...(read `work_item_tracker` from `shamt-config.json`):`` → `.shamt-core/shamt-config.json`
Locate: ``   - `{story-slug}` — kebab-case from the title. Form depends on the active tracker (read `work_item_tracker` from `shamt-config.json`):``
Replace: ``   - `{story-slug}` — kebab-case from the title. Form depends on the active tracker (read `work_item_tracker` from `.shamt-core/shamt-config.json`):``
**O2 (130):**
Locate: ``- **New partition (per Step 3) — and every story on first decomposition:** create `stories/{story-slug}-{brief}/ticket.md` from the active tracker's per-provider ticket template. **Template selection rule:** read `work_item_tracker` from `shamt-config.json`:``
Replace: same with `.shamt-core/shamt-config.json`
**O3 (212):**
Locate: ``- **Fresh-agent runnable.** Every input lives on disk (`feature.md`, the active tracker's ticket template, the existing `stories/` tree, `shamt-config.json`). No conversation history required.``
Replace: same with `.shamt-core/shamt-config.json`

**Verification:** config regex → 0; `grep -c '.shamt-core/shamt-config.json' …/decompose-feature.md` → 3.

---

## Step 9 — `review-changes.md`

**Operation:** EDIT · **File:** `host/templates/claude/commands/review-changes.md` · Docs: 41, 45, 94, 103, 104, 155, 165. Config: 96, 145.

**O1 (41) — `--base` from ARCHITECTURE.md (architect-confirmed repoint):**
Locate: ``- `--base=<name>` — explicit review base. When omitted, the base is resolved per the rule in [`SHAMT_RULES.template.md`](../../../../templates/SHAMT_RULES.template.md#pattern-4-code-review-process) — (a) PR target branch when available, (b) project default formal-review base from `ARCHITECTURE.md`, (c) repository default branch.``
Replace: same with `.shamt-core/project-specific-files/ARCHITECTURE.md`
**O2 (45):**
Locate: ``- `ARCHITECTURE.md` and `CODING_STANDARDS.md` exist at the project root (note their absence inline if missing — `## Standards check` invariant — and continue).``
Replace: repoint both
**O3 (94):**
Locate: ``Per INFRASTRUCTURE.md §1.12 — at the end of the sweep, answer **explicitly**: does this change require an `ARCHITECTURE.md` or `CODING_STANDARDS.md` update?``
Replace: repoint both
**O4 (96) — config staleness (architect-confirmed repoint):**
Locate: ``or this change actually touches a doc whose `Last Updated` field is stale (older than `shamt-config.json` → `doc_staleness_threshold_days`).`` (a unique substring of line 96)
Replace: same with `.shamt-core/shamt-config.json`
**O5 (103–104) — Documentation Impact block labels:**
Locate:
```
- **ARCHITECTURE.md:** Required | Not required — <one-line reason>
- **CODING_STANDARDS.md:** Required | Not required — <one-line reason>
```
Replace:
```
- **.shamt-core/project-specific-files/ARCHITECTURE.md:** Required | Not required — <one-line reason>
- **.shamt-core/project-specific-files/CODING_STANDARDS.md:** Required | Not required — <one-line reason>
```
**O6 (145) — config:**
Locate: ``1. If `--pr=<id>` was provided, read `shamt-config.json` → `pr_provider`, then read `reference/trackers/<provider>.md`'s `## PR fetch` command and run it to get head branch + target branch.`` (match through `pass `--branch` explicitly.`)
Replace: leading clause with `.shamt-core/shamt-config.json`
**O7 (155):**
Locate: ``- `governing_refs` (`ARCHITECTURE.md`, `CODING_STANDARDS.md`).``
Replace: ``- `governing_refs` (`.shamt-core/project-specific-files/ARCHITECTURE.md`, `.shamt-core/project-specific-files/CODING_STANDARDS.md`).``
**O8 (165):**
Locate: ``  governing_refs: [ARCHITECTURE.md, CODING_STANDARDS.md]``
Replace: ``  governing_refs: [.shamt-core/project-specific-files/ARCHITECTURE.md, .shamt-core/project-specific-files/CODING_STANDARDS.md]``

**Verification:** config regex → 0; docs regex → 0.

---

## Step 10 — `resolve-feedback.md`

**Operation:** EDIT · **File:** `host/templates/claude/commands/resolve-feedback.md` · Docs: 2, 33, 79, 80, 103. Proposals (F2): 12, 69, 89, 112, 123.

**O1 (2) — frontmatter:**
Locate: ``description: Phase 7 (Polish) — apply review feedback to code, log each comment's disposition in addressed_feedback.md, apply any flagged ARCHITECTURE.md / CODING_STANDARDS.md updates, surface root-cause proposals to the framework-update flow``
Replace: ``description: Phase 7 (Polish) — apply review feedback to code, log each comment's disposition in addressed_feedback.md, apply any flagged .shamt-core/project-specific-files/ARCHITECTURE.md / .shamt-core/project-specific-files/CODING_STANDARDS.md updates, surface root-cause proposals to the framework-update flow``
**O2 (12) — model-tier description proposals ref (architect-confirmed F2 repoint):**
Locate: ``- Root-cause / upstream-proposal synthesis (recurring findings → `proposals/<proposal-slug>.md` — descriptive slug, not the story slug): Reasoning (Opus).``
Replace: same with `.shamt-core/proposals/<proposal-slug>.md`
**O3 (33):**
Locate: ``- `ARCHITECTURE.md` and `CODING_STANDARDS.md` paths are known (read the active review's `## Documentation Impact` block to learn whether either needs an update).``
Replace: repoint both
**O4 (69):**
Locate: ``   - **Defer** — only when the user explicitly accepts deferral. Capture the reason and a forward link (e.g., `Deferred — captured at proposals/<slug>.md` or `Deferred — tracker work-item <id>`).``
Replace: same with `.shamt-core/proposals/<slug>.md`
**O5 (79):**
Locate: ``1. Apply the `Polish action` from that block to `ARCHITECTURE.md` and/or `CODING_STANDARDS.md`. Update the `Last Updated` field; append a one-line entry to `Update History` referencing this story's slug.``
Replace: repoint both
**O6 (80):**
Locate: ``2. Re-validate the touched doc via `/validate-artifact ARCHITECTURE.md` (or `/validate-artifact CODING_STANDARDS.md`). Uses the 5 general dimensions. Footer.``
Replace: ``2. Re-validate the touched doc via `/validate-artifact .shamt-core/project-specific-files/ARCHITECTURE.md` (or `/validate-artifact .shamt-core/project-specific-files/CODING_STANDARDS.md`). Uses the 5 general dimensions. Footer.``
**O7 (89) — proposals:**
Locate: ``...Create a `proposals/<proposal-slug>.md` rather than patching framework files directly...`` (within the long line 89; match a unique substring `Create a \`proposals/<proposal-slug>.md\` rather than patching framework files directly`)
Replace: same substring with `.shamt-core/proposals/<proposal-slug>.md`
**O8 (103):**
Locate: ``If `CODING_STANDARDS.md` is stricter (e.g., no TODOs in production code at all), follow the stricter rule.``
Replace: same with `.shamt-core/project-specific-files/CODING_STANDARDS.md`
**O9 (112) — proposals:**
Locate: ``- Any root-cause proposals are filed under `proposals/` as `proposals/<proposal-slug>.md` (descriptive slug per Step 5, not the story slug).``
Replace: ``- Any root-cause proposals are filed under `.shamt-core/proposals/` as `.shamt-core/proposals/<proposal-slug>.md` (descriptive slug per Step 5, not the story slug).``
**O10 (123) — proposals:**
Locate: ``- Generalizable root causes are filed under `proposals/`.``
Replace: ``- Generalizable root causes are filed under `.shamt-core/proposals/`.``

**Verification:** docs regex → 0; `grep -nE '(^|[^./a-z-])proposals/' …/resolve-feedback.md | grep -v '.shamt-core/proposals'` → 0.

---

## Step 11 — `write-testing-plan.md`

**Operation:** EDIT · **File:** `host/templates/claude/commands/write-testing-plan.md` · Config: 7, 30 (×2). Docs: 33, 56.

**O1 (7):**
Locate: ``**Purpose:** Produce and validate the testing plan for a story whose spec is approved at Gate 2b. Invoked automatically by `/plan-implementation` when `testing: "enabled"` is set in `shamt-config.json`. Also runnable standalone for re-planning after the Plan phase (e.g., test strategy changes mid-Build).``
Replace: same with `.shamt-core/shamt-config.json`
**O2 (30) — two config occurrences on one line:**
Locate: ``- `shamt-config.json` exists. Read `testing`. If `disabled`, **this command is a no-op**: print one line — `Testing is disabled in shamt-config.json — no testing plan needed.` — and exit. Do not create or modify any file.``
Replace: ``- `.shamt-core/shamt-config.json` exists. Read `testing`. If `disabled`, **this command is a no-op**: print one line — `Testing is disabled in .shamt-core/shamt-config.json — no testing plan needed.` — and exit. Do not create or modify any file.``
**O3 (33):**
Locate: ``- If `ARCHITECTURE.md` and `CODING_STANDARDS.md` exist, read them for test runner / file naming / fixture / assertion conventions.``
Replace: repoint both
**O4 (56):**
Locate: ``2. Cross-reference with `ARCHITECTURE.md` and `CODING_STANDARDS.md` for any test-related rules.``
Replace: repoint both

**Verification:** config regex → 0; docs regex → 0.

---

## Step 12 — `write-manual-testing-plan.md`

**Operation:** EDIT · **File:** `host/templates/claude/commands/write-manual-testing-plan.md` · Config: 7, 36, 150. Docs: 60, 99.

**O1 (7):** repoint the `shamt-config.json` inside "(no `shamt-config.json` no-op check ...)"
Locate: ``**Purpose:** Produce and validate `stories/{slug}/manual_test_plan.md` — a human-walkthrough artifact for verification that automated tests cannot cover. Per INFRASTRUCTURE.md §1.15: invocable any time after Phase 4 (Build) completes, **orthogonal to the project-level automated-testing opt-in** (no `shamt-config.json` no-op check — this command is always available).``
Replace: same with `.shamt-core/shamt-config.json`
**O2 (36):**
Locate: ``- **No `shamt-config.json` `testing` check.** This command does **not** no-op on `testing: "disabled"` — it is independently available on every story.``
Replace: same with `.shamt-core/shamt-config.json`
**O3 (60):**
Locate: ``6. Read `ARCHITECTURE.md` and `CODING_STANDARDS.md` for any project-level UI / infra / multi-user conventions the walkthrough must respect.``
Replace: repoint both
**O4 (99):**
Locate: ``  - `governing_references`: active `spec.md`, active `implementation_plan.md` (when present), `ARCHITECTURE.md`, `CODING_STANDARDS.md`, [`reference/severity_classification.md`](../../../../reference/severity_classification.md)``
Replace: repoint both `ARCHITECTURE.md` / `CODING_STANDARDS.md`
**O5 (150):**
Locate: ``- **No `shamt-config.json` no-op gate.** Unlike `/execute-tests` and `/write-testing-plan`, this command does **not** check `testing` and does **not** print a no-op message. It is always available, on every story, per §1.15.``
Replace: same with `.shamt-core/shamt-config.json`

**Verification:** config regex → 0; docs regex → 0.

---

## Step 13 — `validate-artifact.md`

**Operation:** EDIT · **File:** `host/templates/claude/commands/validate-artifact.md` · Docs (E1, architect-confirmed): 61, 67, 120, 133. **Proposals examples (28, 47) left bare — allow-listed** (dual-context; this command's home is the master framework-update flow).

**O1 (61):**
Locate: ``While reading, research any Pending / Open questions and any factual claims against the codebase, project docs (`ARCHITECTURE.md`, `CODING_STANDARDS.md`), tracker payload (`raw/issue.json` when present), or other verifiable sources.`` (match a unique substring through `or other verifiable sources.`)
Replace: ``...project docs (`.shamt-core/project-specific-files/ARCHITECTURE.md`, `.shamt-core/project-specific-files/CODING_STANDARDS.md`), tracker payload...`` (same surrounding text)
**O2 (67):**
Locate: ``Pick the dimension set that matches the artifact. First check alignment with `ARCHITECTURE.md` and `CODING_STANDARDS.md`.``
Replace: ``Pick the dimension set that matches the artifact. First check alignment with `.shamt-core/project-specific-files/ARCHITECTURE.md` and `.shamt-core/project-specific-files/CODING_STANDARDS.md`.``
**O3 (120):**
Locate: ``- the path to `ARCHITECTURE.md` and `CODING_STANDARDS.md` for context,``
Replace: ``- the path to `.shamt-core/project-specific-files/ARCHITECTURE.md` and `.shamt-core/project-specific-files/CODING_STANDARDS.md` for context,``
**O4 (133) — no backticks here:**
Locate: ``  Governing references: ARCHITECTURE.md, CODING_STANDARDS.md, {any others}``
Replace: ``  Governing references: .shamt-core/project-specific-files/ARCHITECTURE.md, .shamt-core/project-specific-files/CODING_STANDARDS.md, {any others}``

**Verification:**
- `grep -nE '(^|[^./a-z-])ARCHITECTURE\.md|(^|[^./a-z-])CODING_STANDARDS\.md' …/validate-artifact.md` → 0
- `grep -n 'proposals/<slug>.md' …/validate-artifact.md` → still 2 matches (lines 28, 47 — deliberately bare, allow-listed).

---

## Step 14 — `audit-framework.md`

**Operation:** EDIT · **File:** `host/templates/claude/commands/audit-framework.md` · Config: 35, 97. Docs: 35, 46, 98, 159. F3 proposals: 45 (`proposals/_template.md`). **regen-script paths (34, 54) LEFT — not Group C (architect ruling).**

**O1 (35) — config + both docs on one line:**
Locate: ``- For D6 (project-doc currency), `shamt-config.json` exists at the project root and either declares `doc_staleness_threshold_days` (integer) or implicitly uses the default of **60 days**. If both `ARCHITECTURE.md` and `CODING_STANDARDS.md` are missing (legitimate for an in-development shamt-core), D6 reports a structured `not-applicable` finding rather than a HIGH miss — see Step 2 (D6) below.``
Replace: ``- For D6 (project-doc currency), `.shamt-core/shamt-config.json` exists at `.shamt-core/` and either declares `doc_staleness_threshold_days` (integer) or implicitly uses the default of **60 days**. If both `.shamt-core/project-specific-files/ARCHITECTURE.md` and `.shamt-core/project-specific-files/CODING_STANDARDS.md` are missing (legitimate for an in-development shamt-core), D6 reports a structured `not-applicable` finding rather than a HIGH miss — see Step 2 (D6) below.``
**O2 (45) — D5 table, repoint only `proposals/_template.md` (architect-confirmed F3 child-context):**
Locate: ``architecture.template.md`, `coding_standards.template.md`, `proposals/_template.md`) produces artifacts shaped exactly`` (unique substring of the long D5 row)
Replace: ``architecture.template.md`, `coding_standards.template.md`, `.shamt-core/proposals/_template.md`) produces artifacts shaped exactly``
**O3 (46) — D6 table row docs:**
Locate: ``| D6 | Project-doc currency | `ARCHITECTURE.md` and `CODING_STANDARDS.md` exist at the project root; their `Last Updated:` header is within `doc_staleness_threshold_days` (default 60)`` (match the unique table-row prefix)
Replace: ``| D6 | Project-doc currency | `.shamt-core/project-specific-files/ARCHITECTURE.md` and `.shamt-core/project-specific-files/CODING_STANDARDS.md` exist; their `Last Updated:` header is within `doc_staleness_threshold_days` (default 60)``
**O4 (97) — config:**
Locate: ``1. Read `shamt-config.json`. Resolve `doc_staleness_threshold_days` (default 60).``
Replace: ``1. Read `.shamt-core/shamt-config.json`. Resolve `doc_staleness_threshold_days` (default 60).``
**O5 (98) — docs:**
Locate: ``2. Check for `ARCHITECTURE.md` and `CODING_STANDARDS.md` at the project root.``
Replace: ``2. Check for `.shamt-core/project-specific-files/ARCHITECTURE.md` and `.shamt-core/project-specific-files/CODING_STANDARDS.md`.``
**O6 (159) — docs:**
Locate: ``Other projects must have both `ARCHITECTURE.md` and `CODING_STANDARDS.md` per the templates' seed-at-init contract.``
Replace: ``Other projects must have both `.shamt-core/project-specific-files/ARCHITECTURE.md` and `.shamt-core/project-specific-files/CODING_STANDARDS.md` per the templates' seed-at-init contract.``

**Left unchanged (architect ruling):** lines 34, 54 (`shamt-core/scripts/regenerate-framework.sh`); line 101 (`{target}/shamt-core/` self-host rule); line 80 (`canonical file under \`shamt-core/\``); line 33 master-canonical path-discipline list.

**Verification:** config regex → 0; docs regex → 0; `grep -n 'shamt-core/scripts/regenerate' …/audit-framework.md` → still present (lines 34, 54); `grep -n '{target}/shamt-core/' …/audit-framework.md` → line 101 present.

---

## Step 15 — `propose-update.md` (F1 proposals; master-canonical path-discipline left)

**Operation:** EDIT · **File:** `host/templates/claude/commands/propose-update.md`

Repoint these child-side `proposals/…` occurrences (verbatim locate/replace per the update-flow command enumeration): lines 2, 7, 21, 25 (the `proposals/` folder mention only — `shamt-core/` detection terms left), 26, 32, 33, 35, 41, 42, 93, 107–108, 112. **Left unchanged:** the `shamt-core/proposals/` and `shamt-core/{CLAUDE.md,…}` path-discipline list around lines 64–68, and the two `shamt-core/` master-side detection mentions on line 25.

Apply the substitution `proposals/` → `.shamt-core/proposals/` to each of the following exact lines:

- **2:** `description: Phase 1 of the framework-update flow — author or edit a proposal at proposals/{slug}.md, applying the open-questions iterative dialog as the change set firms up`
- **7:** `**Purpose:** Run Phase 1 of the framework-update flow. Resolve a slug to \`proposals/{slug}.md\`, draft (or edit) the proposal against the canonical template, and apply the open-questions iterative dialog until every question is resolved and every affected canonical file is listed.`
- **21:** `- \`{slug}\` (required) — descriptive kebab-case slug for the proposal (e.g., \`fix-spec-template-missing-section\`, \`add-mermaid-recipe\`). The slug becomes the filename \`proposals/{slug}.md\`. Slugs are descriptive, not numbered — there is no SHAMT-N convention in v2.`
- **25:** `- Run from a project root that has \`shamt-core/\` (master-side) or a synced framework + \`proposals/\` folder (child-side). If neither exists, halt and direct the user to either run this from \`shamt-core/\` or install Shamt first.` → repoint **only** the `\`proposals/\`` folder mention to `\`.shamt-core/proposals/\``; leave both `\`shamt-core/\`` master-side terms.
- **26:** `- \`proposals/_template.md\` must exist. If not, halt and report — the template is the source of truth for proposal shape.`
- **32:** `- Try \`proposals/{slug}.md\` (exact match).`
- **33:** `...move the abandoned draft to \`proposals/archive/{slug}.draft-{timestamp}.md\` (using \`git mv\` when tracked) before overwriting...` (repoint the one `proposals/archive/...draft...` path within the long line)
- **35:** `- **\`proposals/archive/{slug}.md\` exists** — a proposal with this slug was already implemented...`
- **41:** `1. Read [\`proposals/_template.md\`](../../../../proposals/_template.md) top-to-bottom.` → display text **and** href: `[\`.shamt-core/proposals/_template.md\`](../../../../.shamt-core/proposals/_template.md)`
- **42:** `2. Copy it to \`proposals/{slug}.md\`.`
- **93:** `- [ ] Proposal exists at \`proposals/{slug}.md\` and is non-empty.`
- **107–108:** `- Row count ≤ 10 → \`/clear\`, then \`/validate-artifact proposals/{slug}.md\`.` and `- Row count > 10 → \`/clear\`, then \`/validate-artifact proposals/{slug}.md\`, then \`/plan-update-implementation {slug}\`.`
- **112:** `- \`proposals/{slug}.md\` exists, non-empty, no open questions, all Proposed Changes rows on canonical paths.`

**Verification:** after the sweep, `grep -nE '(^|[^./a-z-])proposals/' …/propose-update.md | grep -v '\.shamt-core/proposals'` → **empty** (all 14 bare child-side `proposals/` occurrences are repointed; the master-canonical `shamt-core/proposals/` on line 66 is `/`-preceded and is therefore *not* matched by the bare-proposals regex — it never appears in this grep); `grep -c '\.shamt-core/proposals/' …/propose-update.md` → **14** (the 14 repointed lines; line 66 stays bare `shamt-core/proposals/`, which the escaped-dot pattern does not match).

---

## Step 16 — `submit-proposal.md` (D config + F1 proposals; `proposals/incoming/` left)

**Operation:** EDIT · **File:** `host/templates/claude/commands/submit-proposal.md`

**Config (D):** lines 28, 34 (heading), 36, 37, 112 — `shamt-config.json` → `.shamt-core/shamt-config.json`.
**Proposals (F1):** repoint every **child-side** `proposals/{slug}.md`, `proposals/submitted/…`, `proposals/already-merged/…` (lines 2, 7, 23, 29, 30, 42, 68, 76, 77, 82, 83, 91, 102, 104, 111, **112**) → `.shamt-core/proposals/…`. (Line 83 — ``The submitted copy stays in `proposals/submitted/` `` — is child-side and was previously dropped; it must repoint or Step 16's `grep … | grep -v incoming → 0` verification cannot pass. Line 112 is a **dual config+proposals** line — its `proposals/{slug}.md` part repoints here in addition to its config part; see the per-line 112 bullet below, which repoints **both**.)
**Left unchanged (master-side, allow-listed):** every `proposals/incoming/{project}-{slug}.md` and the `proposals/incoming/` detection heuristic (lines 2, 7, 27, 38, 51, 57, 65, 92).

Apply per the update-flow command enumeration (exact lines verbatim). Representative occurrences:
- **28:** `- \`shamt-config.json\` exists at the project root and declares \`project_name\`...` → `.shamt-core/shamt-config.json`
- **34:** `### Step 1 — Read shamt-config.json` → `### Step 1 — Read .shamt-core/shamt-config.json`
- **36:** `1. Read \`shamt-config.json\` at the project root.` → `.shamt-core/shamt-config.json`
- **37:** `2. Extract \`project_name\`. If empty or missing, halt with: *"shamt-config.json must declare project_name — set it and re-run."*` → repoint the `shamt-config.json` mention
- **112:** `- **Fresh-agent runnable.** \`shamt-config.json\` + \`proposals/{slug}.md\` are sufficient. No conversation history required.` → repoint BOTH (`.shamt-core/shamt-config.json` + `.shamt-core/proposals/{slug}.md`)
- proposals lines 2, 7, 23, 29, 30, 42, 68, 76, 77, 82, 83, 91, 102, 104, 111, 112: substitute child-side `proposals/…` → `.shamt-core/proposals/…` (leave any `proposals/incoming/` in the same line).

**Verification:** `grep -nE '(^|[^./a-z-])shamt-config\.json' …/submit-proposal.md` → 0; `grep -nE '(^|[^./a-z-])proposals/' …/submit-proposal.md | grep -v '.shamt-core/proposals' | grep -v 'proposals/incoming'` → 0; `grep -c 'proposals/incoming/' …/submit-proposal.md` → unchanged (8) (lines 2, 7, 27, 38, 51, 57, 65, 92).

---

## Step 17 — `import-shamt.md` (C1 install-path + D config + F1 proposals)

**Operation:** EDIT · **File:** `host/templates/claude/commands/import-shamt.md`

**Install-path (C1):** every child-side `shamt-core/import-shamt.sh` and `<child>/shamt-core/` → `.shamt-core/` (lines 2, 7, 24, 28 ×2, 30, 36 ×2, 41 [`git status --porcelain shamt-core/ .claude/`], 53, 98 [`git diff shamt-core/ .claude/`], 116 [`shamt-core/{templates,reference,host,scripts}/`]). **Leave `.claude/` segments.**
**Config (D):** lines 29, 58, 118 → `.shamt-core/shamt-config.json`.
**Proposals (F1):** child-side `proposals/already-merged/`, `proposals/{slug}.md`, and the synced template member `proposals/_template.md` (lines 2, 7, 60, 62, 83) → `.shamt-core/proposals/…`. On **line 60** repoint **only** the `proposals/_template.md` member (its child location is `.shamt-core/proposals/_template.md`, matching `propose-update.md`'s repointed line 41) — leave the sibling sync-set names `CHEATSHEET.md`/`init-shamt.sh`/`import-shamt.sh` bare. On **line 62** repoint `proposals/already-merged/` and **leave** the master-side `master's proposals/archive/`. (Line 60 was previously left bare, which would trip the parent `_PLAN.md` Gate F — it whitelists only `proposals/incoming` and `proposals/archive`, not this sync-set member.)

Apply per the update-flow command enumeration (exact lines verbatim).

**Verification:** `grep -nE 'shamt-core/import-shamt\.sh|<child>/shamt-core/' …/import-shamt.md | grep -v '\.shamt-core'` → 0; `grep -nE '(^|[^./a-z-])shamt-config\.json' …/import-shamt.md` → 0; `grep -nE '(^|[^./a-z-])proposals/' …/import-shamt.md | grep -v '\.shamt-core/proposals' | grep -v 'proposals/archive'` → 0 (all child-side proposals incl. line 60's `_template.md` repointed; only line 62's master `proposals/archive/` stays bare and is whitelisted); `grep -c 'proposals/archive/' …/import-shamt.md` → 1 (line 62, master-side).

---

## Step 18 — `regen-framework.md` (C2 install-path + D config; self-host rule left)

**Operation:** EDIT · **File:** `host/templates/claude/commands/regen-framework.md`

**Install-path (C2):** lines 26, 37, 52, 68 — `shamt-core/scripts/regenerate-framework.sh` → `.shamt-core/scripts/regenerate-framework.sh`.
**Config (D):** line 38 — `shamt-config.json` → `.shamt-core/shamt-config.json`.
**Left unchanged (architect ruling):** line 29 self-host detection (`{target}/shamt-core/` and `{target}/shamt-core/scripts/regenerate-framework.sh` — must stay `shamt-core/` so a child with `.shamt-core/` fails the test); lines 7, 27, 101 master-canonical `shamt-core/host/templates/claude/` / dev-context narrative.

- **26:** `- \`shamt-core/scripts/regenerate-framework.sh\` exists and is executable. If not, halt and report.` → `.shamt-core/scripts/...`
- **37:** `   1. \`shamt-core/scripts/regenerate-framework.sh\` (relative to repo root when run from a child project's parent context, or directly when run from inside \`shamt-core/\`).` → repoint **only** the first `shamt-core/scripts/...` path; leave the trailing `inside \`shamt-core/\`` dev-context mention.
- **38:** `   2. An installed copy at the path documented in the project's \`shamt-config.json\` (when available).` → `.shamt-core/shamt-config.json`
- **52:** `bash shamt-core/scripts/regenerate-framework.sh --target {target_dir}` → `.shamt-core/scripts/...`
- **68:** `bash shamt-core/scripts/regenerate-framework.sh --check --target {target_dir}` → `.shamt-core/scripts/...`

**Verification:** `grep -nE 'shamt-core/scripts/regenerate' …/regen-framework.md | grep -v '.shamt-core/' | grep -v '{target}/shamt-core'` → 0; `grep -n '{target}/shamt-core/' …/regen-framework.md` → line 29 present; config regex → 0.

---

## Cross-check vs Proposed Changes (Phase 3 coverage)

| Proposal row | Covered by |
|---|---|
| D1 (commands config sweep) | Steps 1–9, 11–12, 14, 16, 18 (every command that reads config) |
| E1 (commands doc sweep, incl. `validate-artifact`) | Steps 1, 2, 4, 5, 9, 10, 11, 12, 13, 14 |
| F1 (`propose-update`, `submit-proposal`, `import-shamt` proposals) | Steps 15, 16, 17 |
| F1-excl (triage/archive/implement/plan-update — NO edit) | Not in this phase (master-canonical) |
| F2 (`resolve-feedback` proposals) | Step 10 |
| F3 (`validate-artifact`, `audit-framework` dual-context) | Steps 13 (docs repointed, proposals left), 14 (`proposals/_template.md` repointed) |
| C1 (`import-shamt.md` install-path) | Step 17 |
| C2 (`regen-framework.md` install-path) | Step 18 |

---

*Phase 3's 18 files have the highest occurrence density — validation re-grepped every file against the four gate patterns. Every cited config/doc line number matched ground truth exactly; the coverage fixes this loop were `submit-proposal.md:83` and `:112` (dropped child-side proposals refs), `import-shamt.md:60` (sync-set `proposals/_template.md` left bare, would have tripped parent Gate F), plus corrected verification counts in Steps 15/16 and a stale locate-hint in Step 5.*

---
Validated 2026-05-28 — 3 rounds, 1 adversarial sub-agent confirmed
