# Implementation Plan — Phase 5: Reference + template + rules + script cross-ref EDITs

**Proposal:** proposals/26-po-draft-stub-skills-incremental-decomposition.md
**Index:** proposals/26-po-draft-stub-skills-incremental-decomposition_PLAN.md
**Source rows:** 25–37 (sections E + F)
**Operations:** 13 EDIT (README, rules, model_selection, 4 tracker profiles, 4 templates, 2 scripts)

> All renames in Phases 2–3 are already on disk, so every reference below points at a command that now exists under its new name. Naming map (same as Phases 2–3): `/p1-start-epic`→`/pe1-define`, `/p2-decompose-epic`→`/pe2-decompose`, `/p3-start-feature`→`/pf1-define`, `/p4-decompose-feature`→`/pf2-decompose`, `/p5-finalize-epic`→`/pe3-finalize`, `/p6-draft-tech-story`→`/ps0-draft`.

---

## Step 1 — EDIT `README.md` — rewrite the PO-flow section (row 25)

**Operation:** EDIT
**File:** `README.md`

The PO-flow section spans roughly lines 100–164. Rewrite it to the grid model. Concrete edits:
- **Line 102** — Locate this exact verbatim on-disk substring (raw backticks):

  ```text
  Six commands across two altitudes — Epic (top) and Feature (one level down). Each `start-*` command defines an artifact; each `decompose-*` command breaks it into stubs at the next altitude; `/p5-finalize-epic` is the terminal Epic-altitude command, and `/p6-draft-tech-story` is a fast path for one-off work.
  ```

  → Replace with this exact text (raw backticks):

  ```text
  Commands form an **altitude × stage grid** — prefix by altitude (`pe` = epic, `pf` = feature, `ps` = story), number by stage (`0-draft`, `1-define`, `2-decompose`, `3-finalize`). `draft` is an f0-style single-stub / idea capture runnable any time (the incremental-add path); `define` fleshes it out via the open-questions dialog; `decompose` (epic + feature only) batch-creates the next altitude's stubs; `finalize` (epic only) is the terminal Epic-altitude command.
  ```
- **Line 105 — Epic-altitude callout (exact locate/replace).** Locate the exact verbatim line (leading whitespace preserved — 12 spaces before `Epic`): `            Epic                       <-- /p1-start-epic, /p2-decompose-epic` → Replace with: `            Epic                       <-- /pe0-draft, /pe1-define, /pe2-decompose, /pe3-finalize`. (Only the callout span after `<-- ` changes; the `            Epic` label + its trailing-space column are left byte-for-byte intact.)
- **Line 108 — Feature-altitude callout (exact locate/replace).** Locate the exact verbatim line (leading whitespace preserved — 10 spaces before `Feature`): `          Feature                      <-- /p3-start-feature, /p4-decompose-feature` → Replace with: `          Feature                      <-- /pf0-draft, /pf1-define, /pf2-decompose`. (Only the callout span after `<-- ` changes; the `          Feature` label + its trailing-space column are left byte-for-byte intact.)
- **Line 111 — Story-altitude callout (APPEND to the existing line — exact locate/replace).** The Story row already carries a callout (`<-- /e1-start-story (stub-aware), then Engineer flow`); do **not** insert a new line — extend the existing one. Locate the exact verbatim line (leading whitespace preserved — 11 spaces before `Story`): `           Story                       <-- /e1-start-story (stub-aware), then Engineer flow` → Replace with: `           Story                       <-- /ps0-draft, /ps1-define, then /e1-start-story (stub-aware) → Engineer flow`. (The `           Story` label + its trailing-space column are left byte-for-byte intact; only the callout text after `<-- ` changes, prepending the new `/ps0-draft, /ps1-define` story-altitude commands ahead of the existing `/e1-start-story` handoff.)
- **Command table (lines 114–121) — exact locate/replace.** Locate this **complete verbatim** on-disk block (header line, separator line, and the six `/p1`–`/p6` rows — first char of `| Command` to last char of the `/p6` row; no leading/trailing blank lines):

  ```
  | Command | Phase | Status |
  |---------|-------|--------|
  | `/p1-start-epic {slug}` | Epic intake/define | shipped |
  | `/p2-decompose-epic {slug}` | Epic → feature stubs | shipped |
  | `/p3-start-feature {slug}` | Feature intake/define | shipped |
  | `/p4-decompose-feature {slug}` | Feature → story stubs | shipped |
  | `/p5-finalize-epic {slug}` | Epic finalize → `epics/archive/` | shipped |
  | `/p6-draft-tech-story [bugs\|quick-wins] [slug]` | Fast-path: one-off bug/quick-win → Tech Stories epic | shipped |
  ```

  → Replace with this exact replacement table (the old `/p6-draft-tech-story` row is dropped — its role folds into the `/ps0-draft` row):

  ```
  | Command | Phase | Status |
  |---------|-------|--------|
  | `/pe0-draft` | Epic stage-0 draft (idea capture) | shipped |
  | `/pe1-define {slug}` | Epic stage-1 define (intake/flesh-out) | shipped |
  | `/pe2-decompose {slug}` | Epic stage-2 → feature stubs | shipped |
  | `/pe3-finalize {slug}` | Epic stage-3 finalize → `epics/archive/` | shipped |
  | `/pf0-draft {epic-slug}` | Feature stage-0 draft (one stub under an epic) | shipped |
  | `/pf1-define {slug}` | Feature stage-1 define (intake/flesh-out) | shipped |
  | `/pf2-decompose {slug}` | Feature stage-2 → story stubs | shipped |
  | `/ps0-draft {feature-slug \| bugs \| quick-wins}` | Story stage-0 draft (one stub; absorbs the old tech-story fast path) | shipped |
  | `/ps1-define {slug}` | Story stage-1 define (flesh-out **+ inline Pattern-1 validation** → engineer-ready ticket) | shipped |
  ```
- **Line 141** — Locate this exact verbatim substring (no backticks in span):

  ```text
  # finalized epics (/p5-finalize-epic); excluded from active-epic resolution
  ```

  Replace `/p5-finalize-epic` → `/pe3-finalize` (substring substitution; the rest of the line intact).
- **Line 143** — Locate this exact verbatim substring (raw backticks):

  ```text
  is the home for one-off bugs / quick wins filed via `/p6-draft-tech-story`.
  ```

  Replace `/p6-draft-tech-story` → `/ps0-draft` (the raw-backtick wrapping is preserved: result is `` `/ps0-draft` ``).
- **Lines 154 & 160** — Locate these two exact verbatim substrings (raw backticks):

  ```text
  `/p4-decompose-feature` enforces this on every story stub it writes:
  ```

  ```text
  See the `/p4-decompose-feature` command body for the full rubric
  ```

  Replace `/p4-decompose-feature` → `/pf2-decompose` in both (raw-backtick wrapping preserved).
- **Line 164** — Locate this exact verbatim substring (raw backticks):

  ```text
  Both `/p1-start-epic` and `/p3-start-feature` consult
  ```

  → Replace with (raw backticks):

  ```text
  Both `/pe1-define` and `/pf1-define` consult
  ```

**Verification:**
- `grep -nE '/p[1-6]-(start|decompose|finalize|draft)' README.md` returns **zero** matches (full names).
- `grep -nE '/p[1-6]([^a-z-]|$)' README.md` returns **zero** matches (bare tokens — README has none today, so any hit means the rewrite reintroduced one).
- `grep -F '/pe0-draft' README.md` returns ≥1 match; `grep -F '/ps0-draft' README.md` returns ≥1 match; `grep -F '/pe3-finalize' README.md` returns ≥1 match (grid table + finalize callout + tech-stories note all updated).

---

## Step 2 — EDIT `templates/SHAMT_RULES.template.md` (row 26)

**Operation:** EDIT
**File:** `templates/SHAMT_RULES.template.md`
**Size note:** this file is size-budgeted (D12). Keep the edits **name-for-name substitutions** — do not expand prose.

- **Line 19** (PO-flow overview) — Locate this exact verbatim on-disk substring (bare `/pN` tokens wrapped in raw backticks):

  ```text
  see the `/p2`/`/p4` decompose and `/p3`/`/e1` start command bodies for per-altitude detail.
  ```

  → Replace with (raw backticks):

  ```text
  see the `/pe2-decompose`/`/pf2-decompose` decompose and `/pf1-define`/`/e1` start command bodies for per-altitude detail.
  ```

  (Map only the three bare PO tokens: `/p2`→`/pe2-decompose`, `/p4`→`/pf2-decompose`, `/p3`→`/pf1-define`. **Leave `/e1` exactly as-is** — it is not a PO command and is out of scope for this rename.) *(This line carries only bare `/pN` tokens, not full `/pN-{stage}` names, so the verification grep below must also scan for bare tokens — see Verification.)*
- **Line 138** — Name-only substring substitution (the rest of the line's body text is untouched). Locate this exact verbatim on-disk substring (note the leading `- ` bullet marker and raw backticks):

  ```text
  - **`/p5-finalize-epic {slug}`**
  ```

  → Replace with (raw backticks, leading `- ` preserved):

  ```text
  - **`/pe3-finalize {slug}`**
  ```

  (This substring is unique in the file; replacing just the command-name span leaves the trailing ` — the PO flow's terminal command at the Epic altitude:` and the remainder of line 138 intact.)
- **Line 167** — Locate this exact verbatim substring (raw backticks):

  ```text
  Seeded once (create-if-absent) by the install/sync flow (`init-shamt.sh` / `import-shamt.sh`), never per-initiative by `/p1-start-epic`;
  ```

  Replace `/p1-start-epic` → `/pe1-define` (raw-backtick wrapping preserved; the rest of the line intact).
- **Line 169** — Locate this exact **complete** verbatim on-disk line (leading `- ` bullet, raw backticks, full line through the terminal period — note it continues past the semicolon):

  ```text
  - **Entry + archive.** `/p6-draft-tech-story [bugs|quick-wins]` seeds a ticket stub under the chosen feature and hands to `/e1-start-story` (bypassing the `/p1`→`/p4` cascade); on finalize, `/e8-finalize-story` moves the folder into the feature's `archive/`. See those command bodies for the mechanics.
  ```

  → Replace with (raw backticks, leading `- ` preserved, full line preserved):

  ```text
  - **Entry + archive.** `/ps0-draft [bugs|quick-wins]` seeds a ticket stub under the chosen feature and hands to `/e1-start-story` (bypassing the `/pe1-define`→`/pf2-decompose` cascade); on finalize, `/e8-finalize-story` moves the folder into the feature's `archive/`. See those command bodies for the mechanics.
  ```

  (Two deterministic substitutions: `/p6-draft-tech-story [bugs|quick-wins]`→`/ps0-draft [bugs|quick-wins]`, and the bare-token cascade `/p1`→`/p4` becomes `/pe1-define`→`/pf2-decompose`. `/e1-start-story` and `/e8-finalize-story` are unchanged — out of scope. The cascade tokens are bare `/pN` — covered by the bare-token verification grep below.)
- **Line 404** — Locate this exact verbatim on-disk substring (leading `- ` bullet marker and raw backticks):

  ```text
  - **Stub IDs are preserved.** `/p2-decompose-epic` and `/p4-decompose-feature` allocate each child's ID at stub time; `/p3-start-feature` (fleshing a feature stub) and `/e1-start-story` (fleshing a story stub) **preserve** that ID — they do not re-allocate.
  ```

  → Replace with (raw backticks, leading `- ` preserved):

  ```text
  - **Stub IDs are preserved.** `/pe2-decompose` and `/pf2-decompose` allocate each child's ID at stub time; `/pf1-define` (fleshing a feature stub) and `/e1-start-story` (fleshing a story stub) **preserve** that ID — they do not re-allocate.
  ```

  (Three substitutions: `/p2-decompose-epic`→`/pe2-decompose`, `/p4-decompose-feature`→`/pf2-decompose`, `/p3-start-feature`→`/pf1-define`. `/e1-start-story` unchanged.)

**Verification:**
- `grep -nE '/p[1-6]-(start|decompose|finalize|draft)' templates/SHAMT_RULES.template.md` returns **zero** matches (catches full `/pN-{stage}` names).
- `grep -nE '/p[1-6]([^a-z-]|$)' templates/SHAMT_RULES.template.md` returns **zero** matches (catches the **bare** `/p2`/`/p3`/`/p4` tokens on line 19 and the bare `/p1`→`/p4` cascade on line 169 — the full-name grep above cannot see these). Any hit here means a bare token was missed.
- `git diff --stat templates/SHAMT_RULES.template.md` shows a small net line delta (size budget honored — substitution, not expansion).

---

## Step 3 — EDIT `reference/model_selection.md` (row 27)

**Operation:** EDIT
**File:** `reference/model_selection.md`

- **Line 58 (rename in place)** — Locate this exact verbatim on-disk line (raw backticks):

  ```text
  | PO — Epic finalize (`/p5-finalize-epic`) | Cheap | Mechanical: children-done guard, tracker close, `epic.md` status flip, folder move into `epics/archive/`, commit |
  ```

  Replace `/p5-finalize-epic` → `/pe3-finalize` (raw-backtick wrapping preserved; the description text is unchanged).
- **Insert the new grid rows immediately after the (renamed) line-58 row**, in this exact order and text (proposal row 27 — "add rows for the new draft/define/decompose grid commands with recommended tiers"). The table at line 58 has **no** `/p1`–`/p4` rows present (the prior grep confirmed only the `/p5` row existed), so all PO define/decompose grid commands are **added**, not renamed:

  ```
  | PO — Epic draft (`/pe0-draft`) | Cheap | f0-style bare idea capture: seed `epic.md` with Scratch Notes + draft status; no design judgment, no open-questions dialog (mirrors `/f0-draft-proposal`) |
  | PO — Epic define (`/pe1-define`) | Balanced | Open-questions iterative dialog over Goal / Success Criteria / Scope; consults ARCHITECTURE.md; ingests a `/pe0-draft` stub when present |
  | PO — Epic decompose (`/pe2-decompose`) | Balanced | Stub-list-then-drill-in batch decomposition into feature stubs; parallelization analysis; re-decomposition partition |
  | PO — Feature draft (`/pf0-draft`) | Cheap | f0-style single-stub capture under an existing epic; no dialog (mirrors `/f0-draft-proposal`) |
  | PO — Feature define (`/pf1-define`) | Balanced | Open-questions iterative dialog over Success Criteria + Scope; consults ARCHITECTURE.md; ingests a `/pf0-draft` stub when present |
  | PO — Feature decompose (`/pf2-decompose`) | Balanced | Stub-list-then-drill-in batch decomposition into story stubs; individually-testable rubric; parallelization analysis |
  | PO — Story draft (`/ps0-draft`) | Cheap | f0-style single-stub capture under an existing feature (absorbs the old tech-story fast path); no dialog |
  | PO — Story define (`/ps1-define`) | Reasoning | Open-questions dialog **plus** an inline Pattern-1 validation loop producing the engineer-ready planning ticket (mirrors the story-altitude design+validation tiers) |
  ```

  Tier rationale (do not editorialize beyond the text above): the three `*0-draft` rows are **Cheap** (mechanical capture, mirroring `/f0-draft-proposal`); the define/decompose rows are **Balanced** (dialog / structural decomposition, matching the existing Phase-1/Phase-3 PO altitudes); `/ps1-define` is **Reasoning** because it folds the inline validation loop (matching the spec/plan validation-loop rows already in this table).

**Verification:**
- `grep -nE '/p[1-6]-(start|decompose|finalize|draft)' reference/model_selection.md` returns **zero** matches.
- `grep -F '/ps1-define' reference/model_selection.md` returns ≥1 match (new define row present).

---

## Step 4 — EDIT `reference/trackers/_contract.md` (row 28)

**Operation:** EDIT
**File:** `reference/trackers/_contract.md`

- **Line 3** — Locate this exact verbatim substring (raw backticks):

  ```text
  Used by `/e1-start-story`, `/p1-start-epic`, `/p3-start-feature`, and `/e6-review-changes`
  ```

  Replace `/p1-start-epic` → `/pe1-define`, `/p3-start-feature` → `/pf1-define` (raw-backtick wrapping preserved; `/e1-start-story` and `/e6-review-changes` unchanged).
- **Line 31** — Locate this exact verbatim substring (raw backticks):

  ```text
  When a command (`/e1-start-story`, `/p1-start-epic`, `/p3-start-feature`)
  ```

  Replace `/p1-start-epic` → `/pe1-define`, `/p3-start-feature` → `/pf1-define`.
- **Line 35** — Locate this exact verbatim substring (raw backticks):

  ```text
  so `/p3-start-feature` and `/p1-start-epic` against the `github` profile fall through
  ```

  Replace `/p3-start-feature` → `/pf1-define`, `/p1-start-epic` → `/pe1-define`.
- **Lines 54–55** (supported-types table) — Locate these two exact verbatim on-disk lines (raw backticks):

  ```text
  | `/p1-start-epic {slug}` | Same as above, filtered on `Epic` | PO flow |
  ```

  ```text
  | `/p3-start-feature {slug}` | Same as above, filtered on `Feature` | PO flow |
  ```

  Replace `/p1-start-epic` → `/pe1-define` (line 54) and `/p3-start-feature` → `/pf1-define` (line 55).

**Verification:**
- `grep -nE '/p[1-6]-(start|decompose|finalize|draft)' reference/trackers/_contract.md` returns **zero** matches.

---

## Step 5 — EDIT `reference/trackers/ado.md` (row 29)

**Operation:** EDIT
**File:** `reference/trackers/ado.md`
All sites carry **raw** backticks. Six per-line substring substitutions (`/p1-start-epic` → `/pe1-define`, `/p3-start-feature` → `/pf1-define`); each line carries **both** old names:

- **Line 3** — Locate this exact verbatim substring (raw backticks):

  ```text
  pass `--tracker=ado` to any slug-taking command (`/e1-start-story`, `/p1-start-epic`, `/p3-start-feature`).
  ```

  → Replace with (raw backticks):

  ```text
  pass `--tracker=ado` to any slug-taking command (`/e1-start-story`, `/pe1-define`, `/pf1-define`).
  ```
- **Line 5** — Locate this exact verbatim substring (raw backticks):

  ```text
  will be reused by future PO-flow `epic.md` / `feature.md` artifacts when `/p1-start-epic` and `/p3-start-feature` land
  ```

  → Replace with (raw backticks):

  ```text
  will be reused by future PO-flow `epic.md` / `feature.md` artifacts when `/pe1-define` and `/pf1-define` land
  ```
- **Line 56** — Locate this exact verbatim substring (raw backticks):

  ```text
  for the PO-flow variants once `/p1-start-epic` and `/p3-start-feature` ship
  ```

  → Replace with (raw backticks):

  ```text
  for the PO-flow variants once `/pe1-define` and `/pf1-define` ship
  ```
- **Line 75** — Locate this exact verbatim substring (raw backticks):

  ```text
  sections of `epic.md` / `feature.md` once `/p1-start-epic` / `/p3-start-feature` land
  ```

  → Replace with (raw backticks):

  ```text
  sections of `epic.md` / `feature.md` once `/pe1-define` / `/pf1-define` land
  ```
- **Line 93** — Locate this exact verbatim substring (raw backticks):

  ```text
  **Cross-altitude reuse (forward-looking — `/p1-start-epic` and `/p3-start-feature` not yet shipped):**
  ```

  → Replace with (raw backticks):

  ```text
  **Cross-altitude reuse (forward-looking — `/pe1-define` and `/pf1-define` not yet shipped):**
  ```
- **Line 148** — Locate this exact verbatim substring (raw backticks; note the reversed order — `/p3-start-feature` precedes `/p1-start-epic` on this line):

  ```text
  ADO supports all three natively, so `/e1-start-story`, `/p3-start-feature`, and `/p1-start-epic` all fetch from this profile without falling through to freeform mode.
  ```

  → Replace with (raw backticks):

  ```text
  ADO supports all three natively, so `/e1-start-story`, `/pf1-define`, and `/pe1-define` all fetch from this profile without falling through to freeform mode.
  ```

**Verification:** `grep -nE '/p[1-6]-(start|decompose|finalize|draft)' reference/trackers/ado.md` returns **zero** matches.

---

## Step 6 — EDIT `reference/trackers/github.md` (row 30)

**Operation:** EDIT
**File:** `reference/trackers/github.md`
All sites carry **raw** backticks. Seven per-line substring substitutions (`/p1-start-epic` → `/pe1-define`, `/p3-start-feature` → `/pf1-define`); each line carries **both** old names:

- **Line 3** — Locate this exact verbatim substring (raw backticks):

  ```text
  pass `--tracker=github` to any slug-taking command (`/e1-start-story`, `/p1-start-epic`, `/p3-start-feature`).
  ```

  → Replace with (raw backticks):

  ```text
  pass `--tracker=github` to any slug-taking command (`/e1-start-story`, `/pe1-define`, `/pf1-define`).
  ```
- **Line 5** — Locate this exact verbatim substring (raw backticks):

  ```text
  would extend to PO-flow `epic.md` / `feature.md` artifacts once `/p1-start-epic` and `/p3-start-feature` land
  ```

  → Replace with (raw backticks):

  ```text
  would extend to PO-flow `epic.md` / `feature.md` artifacts once `/pe1-define` and `/pf1-define` land
  ```
- **Line 7** — Locate this exact verbatim substring (raw backticks; note the reversed order — `/p3-start-feature` precedes `/p1-start-epic` on this line):

  ```text
  It has no first-class `Feature` or `Epic` type, so `/p3-start-feature` and `/p1-start-epic` against this profile fall through to freeform mode
  ```

  → Replace with (raw backticks):

  ```text
  It has no first-class `Feature` or `Epic` type, so `/pf1-define` and `/pe1-define` against this profile fall through to freeform mode
  ```
- **Line 50** — Locate this exact verbatim substring (raw backticks):

  ```text
  do not apply here, because `/p1-start-epic` and `/p3-start-feature` against this profile fall through to freeform mode
  ```

  → Replace with (raw backticks):

  ```text
  do not apply here, because `/pe1-define` and `/pf1-define` against this profile fall through to freeform mode
  ```
- **Line 76** — Locate this exact verbatim substring (raw backticks):

  ```text
  (Forward-looking: when `/p1-start-epic` / `/p3-start-feature` land, the same mapping would feed `epic.md` / `feature.md`
  ```

  → Replace with (raw backticks):

  ```text
  (Forward-looking: when `/pe1-define` / `/pf1-define` land, the same mapping would feed `epic.md` / `feature.md`
  ```
- **Line 94** — Locate this exact verbatim substring (raw backticks):

  ```text
  wants those treated as such by a future `/p1-start-epic` / `/p3-start-feature` invocation
  ```

  → Replace with (raw backticks):

  ```text
  wants those treated as such by a future `/pe1-define` / `/pf1-define` invocation
  ```
- **Line 152** — Locate this exact verbatim substring (raw backticks; note the reversed order — `/p3-start-feature` precedes `/p1-start-epic` on this line):

  ```text
  GitHub has **no** native `Feature` or `Epic` work-item types. `/p3-start-feature` and `/p1-start-epic` invoked against this profile fall through to freeform mode
  ```

  → Replace with (raw backticks):

  ```text
  GitHub has **no** native `Feature` or `Epic` work-item types. `/pf1-define` and `/pe1-define` invoked against this profile fall through to freeform mode
  ```

**Verification:** `grep -nE '/p[1-6]-(start|decompose|finalize|draft)' reference/trackers/github.md` returns **zero** matches.

---

## Step 7 — EDIT `reference/trackers/local.md` (row 31)

**Operation:** EDIT
**File:** `reference/trackers/local.md`
- **Line 3** — Locate these two exact verbatim substrings (raw backticks):

  ```text
  written as a stub by the PO flow's `/p4-decompose-feature` and then fleshed out by `/e1-start-story`
  ```

  ```text
  (`/e1-start-story`, `/p1-start-epic`, `/p3-start-feature`)
  ```

  Replace `/p4-decompose-feature` → `/pf2-decompose` (first); `/p1-start-epic` → `/pe1-define`, `/p3-start-feature` → `/pf1-define` (second). `/e1-start-story` unchanged.
- **Line 27** — Locate this exact verbatim substring (raw backticks):

  ```text
  For the PO-flow commands (`/p1-start-epic` / `/p3-start-feature`),
  ```

  Replace `/p1-start-epic` → `/pe1-define`, `/p3-start-feature` → `/pf1-define`.
- **Line 71** — Locate this exact verbatim substring (raw backticks):

  ```text
  `/e1-start-story`, `/p3-start-feature`, and `/p1-start-epic` all work
  ```

  Replace `/p3-start-feature` → `/pf1-define`, `/p1-start-epic` → `/pe1-define`. `/e1-start-story` unchanged.

**Verification:** `grep -nE '/p[1-6]-(start|decompose|finalize|draft)' reference/trackers/local.md` returns **zero** matches.

---

## Step 8 — EDIT `templates/epic.template.md` (row 32)

**Operation:** EDIT
**File:** `templates/epic.template.md`
- **Line 26** — Locate this exact verbatim substring (raw backticks):

  ```text
  present only when `/p1-start-epic` consulted
  ```

  Replace `/p1-start-epic` → `/pe1-define`.
- **Line 40** — Locate this exact verbatim on-disk line (raw backticks):

  ```text
  [Populated by `/p2-decompose-epic`. Left empty on `/p1-start-epic` exit. Each line: feature slug + one-line goal.]
  ```

  Replace `/p2-decompose-epic` → `/pe2-decompose`, `/p1-start-epic` → `/pe1-define`.
- **Line 48** — Locate this exact verbatim on-disk line (raw backticks):

  ```text
  [Populated by `/p2-decompose-epic`. Left empty on `/p1-start-epic` exit.]
  ```

  Replace `/p2-decompose-epic` → `/pe2-decompose`, `/p1-start-epic` → `/pe1-define`.
- **Document the stage-0 draft-capture convention** (proposal row 32) — add a short template comment that `/pe0-draft` writes a `## Scratch Notes (stage-0 capture)` section + the `Draft (f0 — epic-idea capture, unrefined)` status, ingested by `/pe1-define`.

**Verification:**
- `grep -nE '/p[1-6]-(start|decompose|finalize|draft)' templates/epic.template.md` returns **zero** matches.
- `grep -F '/pe0-draft' templates/epic.template.md` returns ≥1 match (draft convention documented).

---

## Step 9 — EDIT `templates/feature.template.md` (row 33)

**Operation:** EDIT
**File:** `templates/feature.template.md`
- **Line 26** — Locate this exact verbatim substring (raw backticks):

  ```text
  present only when `/p3-start-feature` consulted
  ```

  Replace `/p3-start-feature` → `/pf1-define`.
- **Line 40** — Locate the exact verbatim on-disk comment (it uses an em-dash `—`, not an ellipsis; full text): `<!-- Cataloged at decomposition (/p2-decompose-epic for features, /p4-decompose-feature for stories) — bounded breadth context discovered by researching the whole sibling set. NOT a depth dump (design/acceptance/implementation detail belongs in the depth sections, filled at start-*). /p3-start-feature and /e1-start-story consume this as a research seed. Leave the placeholder bullets if nothing was cataloged. -->` → Replace with the same line, three name-for-name substitutions only (`/p2-decompose-epic`→`/pe2-decompose`, `/p4-decompose-feature`→`/pf2-decompose`, `/p3-start-feature`→`/pf1-define`): `<!-- Cataloged at decomposition (/pe2-decompose for features, /pf2-decompose for stories) — bounded breadth context discovered by researching the whole sibling set. NOT a depth dump (design/acceptance/implementation detail belongs in the depth sections, filled at start-*). /pf1-define and /e1-start-story consume this as a research seed. Leave the placeholder bullets if nothing was cataloged. -->` (the `start-*` glob and `/e1-start-story` are unchanged — out of scope for this PO rename).
- **Line 50** — Locate this exact verbatim on-disk line (raw backticks):

  ```text
  [Populated by `/p4-decompose-feature`. Left empty on `/p3-start-feature` exit. Each line: story slug + one-line scope.]
  ```

  Replace `/p4-decompose-feature` → `/pf2-decompose`, `/p3-start-feature` → `/pf1-define`.
- **Line 58** — Locate this exact verbatim on-disk line (raw backticks):

  ```text
  [Populated by `/p4-decompose-feature`. Left empty on `/p3-start-feature` exit.]
  ```

  Replace `/p4-decompose-feature` → `/pf2-decompose`, `/p3-start-feature` → `/pf1-define`.
- **Document the stage-0 draft-capture convention** — add a comment that `/pf0-draft` writes the feature stub (incremental single-add) ingested by `/pf1-define`.

**Verification:**
- `grep -nE '/p[1-6]-(start|decompose|finalize|draft)' templates/feature.template.md` returns **zero** matches.
- `grep -F '/pf0-draft' templates/feature.template.md` returns ≥1 match.

---

## Step 10 — EDIT `templates/ticket.ado.template.md` (row 34)

**Operation:** EDIT
**File:** `templates/ticket.ado.template.md`
- **Line 26** — Locate the exact verbatim on-disk comment (em-dash `—`, not an ellipsis; full text — identical to the feature-template comment): `<!-- Cataloged at decomposition (/p2-decompose-epic for features, /p4-decompose-feature for stories) — bounded breadth context discovered by researching the whole sibling set. NOT a depth dump (design/acceptance/implementation detail belongs in the depth sections, filled at start-*). /p3-start-feature and /e1-start-story consume this as a research seed. Leave the placeholder bullets if nothing was cataloged. -->` → Replace with the same line, three name-for-name substitutions only (`/p2-decompose-epic`→`/pe2-decompose`, `/p4-decompose-feature`→`/pf2-decompose`, `/p3-start-feature`→`/pf1-define`): `<!-- Cataloged at decomposition (/pe2-decompose for features, /pf2-decompose for stories) — bounded breadth context discovered by researching the whole sibling set. NOT a depth dump (design/acceptance/implementation detail belongs in the depth sections, filled at start-*). /pf1-define and /e1-start-story consume this as a research seed. Leave the placeholder bullets if nothing was cataloged. -->` (the `start-*` glob and `/e1-start-story` are unchanged — out of scope for this PO rename).
- **Note the stage-0 story-draft capture convention** (proposal row 34) — add a comment that `/ps0-draft` seeds the story-ticket stub (incremental / tech-story fast path).

**Verification:**
- `grep -nE '/p[1-6]-(start|decompose|finalize|draft)' templates/ticket.ado.template.md` returns **zero** matches.
- `grep -F '/ps0-draft' templates/ticket.ado.template.md` returns ≥1 match.

---

## Step 11 — EDIT `templates/ticket.github.template.md` (row 35)

**Operation:** EDIT
**File:** `templates/ticket.github.template.md`
- **Line 29** — same catalog comment as Step 10 (verbatim on-disk, em-dash `—`, full text). Locate: `<!-- Cataloged at decomposition (/p2-decompose-epic for features, /p4-decompose-feature for stories) — bounded breadth context discovered by researching the whole sibling set. NOT a depth dump (design/acceptance/implementation detail belongs in the depth sections, filled at start-*). /p3-start-feature and /e1-start-story consume this as a research seed. Leave the placeholder bullets if nothing was cataloged. -->` → Replace with the same line, three name-for-name substitutions only (`/p2-decompose-epic`→`/pe2-decompose`, `/p4-decompose-feature`→`/pf2-decompose`, `/p3-start-feature`→`/pf1-define`): `<!-- Cataloged at decomposition (/pe2-decompose for features, /pf2-decompose for stories) — bounded breadth context discovered by researching the whole sibling set. NOT a depth dump (design/acceptance/implementation detail belongs in the depth sections, filled at start-*). /pf1-define and /e1-start-story consume this as a research seed. Leave the placeholder bullets if nothing was cataloged. -->` (the `start-*` glob and `/e1-start-story` are unchanged — out of scope for this PO rename).
- **Note the stage-0 story-draft capture convention** — add the `/ps0-draft` comment.

**Verification:**
- `grep -nE '/p[1-6]-(start|decompose|finalize|draft)' templates/ticket.github.template.md` returns **zero** matches.
- `grep -F '/ps0-draft' templates/ticket.github.template.md` returns ≥1 match.

---

## Step 12 — EDIT `init-shamt.sh` (row 36)

**Operation:** EDIT
**File:** `init-shamt.sh`
The seeded Tech Stories `epic.md` / `feature.md` heredocs hardcode the deleted command. Replace each:
- **Line 515** — Name-only substring substitution (no backticks in this span; it is outside the heredoc). Locate this exact verbatim on-disk line:

  ```text
  # The home for one-off bugs / quick wins filed via /p6-draft-tech-story. Fixed
  ```

  Replace `/p6-draft-tech-story` → `/ps0-draft` (substring substitution; the `# The home for one-off bugs / quick wins ` prefix and ` . Fixed` tail intact).
- **Line 531** — On-disk this line carries **raw** backticks (not escaped). Locate this exact verbatim substring (raw backticks):

  ```text
  once at install. File work under it with `/p6-draft-tech-story [bugs|quick-wins]`.
  ```

  Replace `/p6-draft-tech-story [bugs|quick-wins]` → `/ps0-draft [bugs|quick-wins]` (raw-backtick wrapping preserved).
- **Line 544** — On-disk this line sits inside a shell heredoc, so its backticks are backslash-escaped (`` \` ``) in the file. Locate this exact verbatim on-disk substring (backslash-escaped backticks, reproduced literally below):

  ```text
  \`/p6-draft-tech-story $f\`
  ```

  → Replace with (keep the same backslash-escaped-backtick wrapping; only the command-name span changes):

  ```text
  \`/ps0-draft $f\`
  ```

  The rest of the line — the leading `Tickets are filed here via ` and the trailing ` and archived into ` + the escaped `` \`archive/\` `` + ` on finalize.` — is left intact.

**Verification:** `grep -nE '/p[1-6]-(start|decompose|finalize|draft)' init-shamt.sh` returns **zero** matches; `grep -F '/ps0-draft' init-shamt.sh` returns 3 matches.

---

## Step 13 — EDIT `import-shamt.sh` (row 37)

**Operation:** EDIT
**File:** `import-shamt.sh`
- **Line 385** — On-disk this line carries **raw** backticks (not escaped). Locate this exact verbatim substring (raw backticks):

  ```text
  `/p6-draft-tech-story [bugs|quick-wins]`. A local-only organizational container.
  ```

  Replace `/p6-draft-tech-story [bugs|quick-wins]` → `/ps0-draft [bugs|quick-wins]` (raw-backtick wrapping preserved).
- **Line 397** — On-disk this line sits inside a shell heredoc, so its backticks are backslash-escaped (`` \` ``) in the file. Locate this exact verbatim on-disk substring (backslash-escaped backticks, reproduced literally below):

  ```text
  \`/p6-draft-tech-story $_f\`
  ```

  → Replace with (keep the same backslash-escaped-backtick wrapping; only the command-name span changes):

  ```text
  \`/ps0-draft $_f\`
  ```

  The leading `Standing Tech Stories feature. Tickets are filed via ` text is left intact.

**Verification:** `grep -nE '/p[1-6]-(start|decompose|finalize|draft)' import-shamt.sh` returns **zero** matches; `grep -F '/ps0-draft' import-shamt.sh` returns 2 matches.

---

## Final whole-tree sweep (run after every Phase-5 step, proposal Validation Considerations (b))

```
grep -rnE '/p[1-6]-(start|decompose|finalize|draft)' README.md templates reference host/templates init-shamt.sh import-shamt.sh
grep -rnE '/p[1-6]([^a-z-]|$)' README.md templates reference host/templates init-shamt.sh import-shamt.sh
```
Expected: **zero** matches from **both** greps. The first catches full `/pN-{stage}` command names; the second catches **bare** `/pN` tokens (e.g. the `/p2`/`/p3`/`/p4` and `/p1`→`/p4` cascade in `SHAMT_RULES.template.md` lines 19/169) that the first grep structurally cannot see. Any hit is either a step regression (fix it) or a *new* reference site not covered by a Proposed Changes row → the executor halts and the architect performs an in-place amendment (append the row, strip the proposal footer, re-validate) per `/f2` Step 3. Do **not** silently add an off-plan edit.

> Archived/historical references under `proposals/archive/` are intentionally **not** swept or rewritten (proposal Risks → Archived-history references).

---

## Row → step mapping (Phase 5)

| Proposal row | Plan step |
|---|---|
| 25 (`README.md`) | Step 1 |
| 26 (`SHAMT_RULES.template.md`) | Step 2 |
| 27 (`model_selection.md`) | Step 3 |
| 28 (`trackers/_contract.md`) | Step 4 |
| 29 (`trackers/ado.md`) | Step 5 |
| 30 (`trackers/github.md`) | Step 6 |
| 31 (`trackers/local.md`) | Step 7 |
| 32 (`epic.template.md`) | Step 8 |
| 33 (`feature.template.md`) | Step 9 |
| 34 (`ticket.ado.template.md`) | Step 10 |
| 35 (`ticket.github.template.md`) | Step 11 |
| 36 (`init-shamt.sh`) | Step 12 |
| 37 (`import-shamt.sh`) | Step 13 |

---
Validated 2026-06-14 — batch-validated (Standard path), 1 adversarial sub-agent confirmed
