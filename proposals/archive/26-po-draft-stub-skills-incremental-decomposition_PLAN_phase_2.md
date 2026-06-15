# Implementation Plan — Phase 2: Epic-lane MOVEs

**Proposal:** proposals/26-po-draft-stub-skills-incremental-decomposition.md
**Index:** proposals/26-po-draft-stub-skills-incremental-decomposition_PLAN.md
**Source rows:** 9–12, 17–18 (section B, epic lane)
**Operations:** 6 MOVE (3 commands + 3 mirror skills, each = `git mv` + in-body rewrite)

> Each step is `git mv {old} {new}` **first**, then the enumerated in-body EDITs against the new path. The trailing `Regenerate from …{old}` managed comment is rewritten to the new filename as part of every step. Internal `/pN-...` self-references and cross-references are updated to the grid names. Locate strings below are the **exact** current strings (harvested from the files on disk); replace each occurrence.

## Naming map (applied throughout this phase)

| Old | New |
|---|---|
| `/p1-start-epic` | `/pe1-define` |
| `p1-start-epic` (path/name fragments) | `pe1-define` |
| `/p2-decompose-epic` | `/pe2-decompose` |
| `p2-decompose-epic` | `pe2-decompose` |
| `/p3-start-feature` | `/pf1-define` |
| `/p4-decompose-feature` | `/pf2-decompose` |
| `/p5-finalize-epic` | `/pe3-finalize` |
| `p5-finalize-epic` | `pe3-finalize` |

> Cross-references to feature-lane commands (`/p3-start-feature`, `/p4-decompose-feature`) inside epic-lane bodies are updated to `/pf1-define` / `/pf2-decompose` here too — the feature-lane files themselves are renamed in Phase 3, but the *references* to them from epic-lane files are part of these epic-lane rewrites.

---

## Step 1 — MOVE `commands/p1-start-epic.md` → `commands/pe1-define.md` (row 9)

**Operation:** MOVE (`git mv` + body rewrite)
**1a. Rename:** `git mv shamt-core/host/templates/claude/commands/p1-start-epic.md shamt-core/host/templates/claude/commands/pe1-define.md`

**1b. In-body EDITs** (against `shamt-core/host/templates/claude/commands/pe1-define.md`):
- **H1** — Locate: `# /p1-start-epic` → Replace: `# /pe1-define`.
- **Add stage-0 draft ingestion input mode** — insert a new `#### Stage-0 draft ingestion (input mode)` subsection into the body of `### Step 4 — Fetch (or fall through to freeform)`, placed **immediately above** the existing `#### A. Slug-to-ID parse` sub-step. The exact locate anchor (the verbatim line the new block is inserted directly before — currently line 74) is:

  ```text
  #### A. Slug-to-ID parse
  ```

  Insert the following EXACT markdown block immediately above that `#### A. Slug-to-ID parse` line (leave one blank line between the inserted block and the anchor):

  ```text
  #### Stage-0 draft ingestion (input mode)

  Before any tracker fetch or freeform capture, check whether the resolved `epic.md` (Step 2 found an existing, populated file) carries the `/pe0-draft` **stage-0 draft marker** — a `**Status:** Draft (f0 — epic-idea capture, unrefined)` header line directly under `**Ticket ID:** T{N}`, written by `/pe0-draft`.

  - **Marker PRESENT → ingest** (do **not** offer the Step 2.4 refetch / overwrite / extend / exit re-entry prompt — ingestion supersedes it). Seed the open-questions dialog (Step 6) from the file's `## Scratch Notes (stage-0 capture)` section as the raw `Goal` / scope input — verify and sharpen it against the architecture consult, do not paste verbatim. **On completion** (before the Step 8 exit gate), **strip both** the `**Status:** Draft (f0 — epic-idea capture, unrefined)` marker line **and** the entire `## Scratch Notes (stage-0 capture)` section, exactly as `/f1-propose-update` Input Mode 3 ingests then clears an f0 draft (normalize the marker away, develop and remove Scratch Notes). Skip the tracker fetch (sub-steps A–B) — the draft is the intake. Then proceed to Step 5 (architecture consult) and Step 6 (dialog).
  - **Marker ABSENT → unchanged.** Fall through to the existing path below (sub-step A tracker parse, or sub-step C freeform / the Step 2.4 re-entry prompt for an already-populated non-draft `epic.md`). Seed-from-scratch behavior is untouched.
  ```

  (Mirrors `/f1-propose-update`'s f0-draft ingestion convention — see [`commands/f1-propose-update.md`](f1-propose-update.md) Input Mode 3. The marker text matches what `/pe0-draft` writes per Phase 1 Step row-1.)
- **Self-reference replacements** — replace every occurrence of `/p1-start-epic` with `/pe1-define` (current `/p1-start-epic` sites: H1 line 5 — covered by the H1 bullet above; usage block line 16 `/p1-start-epic {slug} [--tracker=...]`; line 80 `\`/p1-start-epic\` requires **Epic**`; line 81 `/p1-start-epic against the GitHub profile`; line 151 `/p1-start-epic mirrors`; line 170 `/p1-start-epic degrades gracefully`). These are the only `/p1-start-epic` literal occurrences; the `/p2-decompose-epic` occurrences (lines 115, 131, 147, 166, 167) are handled by the next two bullets.
- **Next-phase suggestion** — Locate (line 147): `After validation appends the footer, /p2-decompose-epic {slug} can run.` (the surrounding sentence) → replace the `/p2-decompose-epic` reference with `/pe2-decompose` so the next-phase points at the renamed decompose command.
- **`/p2-decompose-epic` cross-refs** — perform a **global substitution**: replace EVERY occurrence of the literal `/p2-decompose-epic` with `/pe2-decompose` in this file (5 occurrences, at lines 115, 131, 147, 166, 167 — the line-147 next-phase reference is the same site as the bullet above, the other four are cross-refs). After this substitution, `grep -F '/p2-decompose-epic' …/pe1-define.md` must return zero matches.
- **Footer** — Locate: `Regenerate from shamt-core/host/templates/claude/commands/p1-start-epic.md.` → Replace: `Regenerate from shamt-core/host/templates/claude/commands/pe1-define.md.`

**Verification:**
- `git status --porcelain | grep -E 'R.*p1-start-epic.*pe1-define'` shows the rename (or `git log --follow` resolves history).
- `grep -nE '/p[12]-(start|decompose)' shamt-core/host/templates/claude/commands/pe1-define.md` returns **zero** matches.
- `grep -F 'Regenerate from shamt-core/host/templates/claude/commands/pe1-define.md' shamt-core/host/templates/claude/commands/pe1-define.md` returns one match.
- `test ! -f shamt-core/host/templates/claude/commands/p1-start-epic.md`

---

## Step 2 — MOVE `skills/p1-start-epic/SKILL.md` → `skills/pe1-define/SKILL.md` (row 10)

**Operation:** MOVE
**2a. Rename the skill directory:** `git mv shamt-core/host/templates/claude/skills/p1-start-epic shamt-core/host/templates/claude/skills/pe1-define`

**2b. In-body EDITs** (against `shamt-core/host/templates/claude/skills/pe1-define/SKILL.md`):
- Front-matter — Locate: `name: p1-start-epic` → Replace: `name: pe1-define`.
- Description block line 10: Locate: `Features and Sequencing & Parallelization empty for /p2-decompose-epic. Invoke` → Replace `/p2-decompose-epic` with `/pe2-decompose`.
- Line 26: Locate: `Mirrors the \`/p1-start-epic {slug}\` slash command.` → replace `/p1-start-epic` with `/pe1-define`.
- Line 30: Locate: `Follow the canonical \`/p1-start-epic\` command body verbatim — see [\`commands/p1-start-epic.md\`](../../commands/p1-start-epic.md).` → replace both `/p1-start-epic`→`/pe1-define`, `commands/p1-start-epic.md`→`commands/pe1-define.md`, and the link target `../../commands/p1-start-epic.md`→`../../commands/pe1-define.md`.
- Line 40: replace `/p2-decompose-epic` → `/pe2-decompose` (the "owned by" clause).
- **Add a one-line stage-0-draft-ingestion note** to the Protocol-summary fetch step (mirrors the command's new input mode). The EXACT locate anchor is the verbatim Protocol-summary step-4 sub-bullet (currently line 38), already rewritten to the new names by the bullets above only if it contained `/pN-` references — it does not, so locate it as-is:

  ```text
     - **`local` / `none`** — freeform capture.
  ```

  Insert the following EXACT line immediately **after** that anchor line (same indentation — three leading spaces, continuing the step-4 sub-list):

  ```text
   - **Stage-0 draft (any tracker)** — when the resolved `epic.md` carries the `**Status:** Draft (f0 — epic-idea capture, unrefined)` marker + a `## Scratch Notes (stage-0 capture)` section, `/pe1-define` **ingests** the `/pe0-draft` draft: seed the dialog from Scratch Notes instead of fetching, and strip both the marker and the `## Scratch Notes (stage-0 capture)` section on completion. See the command body's `#### Stage-0 draft ingestion` sub-step.
  ```
- Footer (line 56): Locate: `Regenerate from shamt-core/host/templates/claude/skills/p1-start-epic/SKILL.md.` → Replace: `Regenerate from shamt-core/host/templates/claude/skills/pe1-define/SKILL.md.`

**Verification:**
- `grep -nE '/p[12]-(start|decompose)' shamt-core/host/templates/claude/skills/pe1-define/SKILL.md` returns **zero** matches.
- `grep -F 'name: pe1-define' shamt-core/host/templates/claude/skills/pe1-define/SKILL.md` returns one match.
- `test ! -d shamt-core/host/templates/claude/skills/p1-start-epic`

---

## Step 3 — MOVE `commands/p2-decompose-epic.md` → `commands/pe2-decompose.md` (row 11)

**Operation:** MOVE
**3a. Rename:** `git mv shamt-core/host/templates/claude/commands/p2-decompose-epic.md shamt-core/host/templates/claude/commands/pe2-decompose.md`

**3b. In-body EDITs** (against `shamt-core/host/templates/claude/commands/pe2-decompose.md`):
- **H1** — Locate: `# /p2-decompose-epic` → Replace: `# /pe2-decompose`.
- **Self-references** `/p2-decompose-epic` → `/pe2-decompose` (current `/p2-decompose-epic` literal sites: H1 line 5 — covered by the H1 bullet above; line 16 usage `/p2-decompose-epic {slug} [--allow-unvalidated]`; line 187. The Purpose-line and Notes references at lines 7 / 191 are `/p3-start-feature` occurrences, handled by the `/p3-start-feature` bullet below; the line-195 `Regenerate from …p2-decompose-epic.md` path is handled by the Footer bullet below.)
- **`/p1-start-epic` cross-refs** → `/pe1-define` (sites: line 26 `direct the user to /p1-start-epic {slug} first`, line 39 `direct the user to /p1-start-epic {slug}`).
- **`/p3-start-feature` cross-refs** → `/pf1-define` — perform a **global substitution**: replace EVERY occurrence of the literal `/p3-start-feature` with `/pf1-define` in this file (14 occurrences, at lines 7, 65, 87, 114, 115, 116, 117, 118, 171, 172, 175, 187, 189, 191). These all point at the feature-lane define command renamed in Phase 3. After this substitution, `grep -F '/p3-start-feature' …/pe2-decompose.md` must return zero matches. (Note: line 189 is also the insert anchor for the `/pf0-draft` Notes bullet below — locate that anchor on its stable prefix `- **No per-feature deep dialog here.**`, which is unaffected by this substitution.)
- **Carry forward re-decomposition logic unchanged** — do **not** alter Step 3 partition logic / Step 9 parent-rewrite mechanics except for the command-name substitutions above.
- **Cross-ref `/pf0-draft` as the single-add alternative** (proposal row 11) — insert a new Notes bullet. The EXACT locate anchor is the existing Notes-section bullet (currently line 189):

  ```text
  - **No per-feature deep dialog here.** That is `/p3-start-feature`'s job per the stub-list-then-drill-in decomposition. Resist the urge to start drafting feature scope or success criteria — it produces low-value batched dialog at this altitude and pre-empts the open-questions iterative dialog at the next altitude.
  ```

  (Note: this anchor line's `/p3-start-feature` is rewritten to `/pf1-define` by the `/p3-start-feature` cross-refs bullet above; perform that substitution first, then locate the rewritten line — or locate on the stable prefix `- **No per-feature deep dialog here.**`.) Insert the following EXACT bullet on a new line immediately **after** that anchor bullet:

  ```text
  - **Single-add alternative — `/pf0-draft`.** To add just **one** feature to an already-decomposed epic, prefer `/pf0-draft {epic-slug}` (the incremental single-stub producer, which appends one feature stub to this epic's `## Target Features` without re-gating) rather than re-running this batch decompose. Re-running `/pe2-decompose` re-presents and re-gates the *entire* feature list (Step 3 re-decomposition partition); the single-add path skips that.
  ```
- **Next-phase** → `/pf1-define` (the per-stub flesh-out suggestion, lines 171–172).
- **Footer** — Locate: `Regenerate from shamt-core/host/templates/claude/commands/p2-decompose-epic.md.` → Replace: `Regenerate from shamt-core/host/templates/claude/commands/pe2-decompose.md.`

**Verification:**
- `grep -nE '/p[1-4]-(start|decompose)' shamt-core/host/templates/claude/commands/pe2-decompose.md` returns **zero** matches.
- `grep -F '/pf0-draft' shamt-core/host/templates/claude/commands/pe2-decompose.md` returns ≥1 match (single-add cross-ref present).
- `grep -F 'Regenerate from shamt-core/host/templates/claude/commands/pe2-decompose.md' shamt-core/host/templates/claude/commands/pe2-decompose.md` returns one match.

---

## Step 4 — MOVE `skills/p2-decompose-epic/SKILL.md` → `skills/pe2-decompose/SKILL.md` (row 12)

**Operation:** MOVE
**4a. Rename:** `git mv shamt-core/host/templates/claude/skills/p2-decompose-epic shamt-core/host/templates/claude/skills/pe2-decompose`

**4b. In-body EDITs** (against `shamt-core/host/templates/claude/skills/pe2-decompose/SKILL.md`):
- Front-matter — `name: p2-decompose-epic` → `name: pe2-decompose`.
- Line 11 description: `feature deep dialog is deferred to /p3-start-feature.` → `/pf1-define`.
- Line 26: `Mirrors the \`/p2-decompose-epic {slug}\` slash command.` → `/pe2-decompose`.
- Line 30: `Follow the canonical \`/p2-decompose-epic\` command body verbatim — see [\`commands/p2-decompose-epic.md\`](../../commands/p2-decompose-epic.md).` → `/pe2-decompose`, `commands/pe2-decompose.md`, link `../../commands/pe2-decompose.md`.
- Line 32: `direct to /p1-start-epic {slug}` → `/pe1-define`.
- **`/p3-start-feature` cross-refs** → `/pf1-define` — perform a **global substitution**: replace EVERY occurrence of the literal `/p3-start-feature` with `/pf1-define` in this file (5 occurrences total; the line-11 occurrence in the description block is the same one covered by the "Line 11 description" bullet above — applying the global substitution satisfies it; the remaining 4 are at lines 36, 42, 46, 49). After this substitution, `grep -F '/p3-start-feature' …/pe2-decompose/SKILL.md` must return zero matches.
- Footer (line 59): `Regenerate from shamt-core/host/templates/claude/skills/p2-decompose-epic/SKILL.md.` → `…/skills/pe2-decompose/SKILL.md.`

**Verification:**
- `grep -nE '/p[1-4]-(start|decompose)' shamt-core/host/templates/claude/skills/pe2-decompose/SKILL.md` returns **zero** matches.
- `grep -F 'name: pe2-decompose' shamt-core/host/templates/claude/skills/pe2-decompose/SKILL.md` returns one match.
- `test ! -d shamt-core/host/templates/claude/skills/p2-decompose-epic`

---

## Step 5 — MOVE `commands/p5-finalize-epic.md` → `commands/pe3-finalize.md` (row 17)

**Operation:** MOVE
**5a. Rename:** `git mv shamt-core/host/templates/claude/commands/p5-finalize-epic.md shamt-core/host/templates/claude/commands/pe3-finalize.md`

**5b. In-body EDITs** (against `shamt-core/host/templates/claude/commands/pe3-finalize.md`):
- **H1** — Locate: `# /p5-finalize-epic` → Replace: `# /pe3-finalize`.
- Usage (line 16): `/p5-finalize-epic {slug}` → `/pe3-finalize {slug}`.
- Any remaining `/p5-finalize-epic` self-references → `/pe3-finalize`.
- **Footer** — Locate: `Regenerate from shamt-core/host/templates/claude/commands/p5-finalize-epic.md.` → Replace: `Regenerate from shamt-core/host/templates/claude/commands/pe3-finalize.md.`

**Verification:**
- `grep -nF '/p5-finalize-epic' shamt-core/host/templates/claude/commands/pe3-finalize.md` returns **zero** matches.
- `grep -F '# /pe3-finalize' shamt-core/host/templates/claude/commands/pe3-finalize.md` returns one match.
- `test ! -f shamt-core/host/templates/claude/commands/p5-finalize-epic.md`

---

## Step 6 — MOVE `skills/p5-finalize-epic/SKILL.md` → `skills/pe3-finalize/SKILL.md` (row 18)

**Operation:** MOVE
**6a. Rename:** `git mv shamt-core/host/templates/claude/skills/p5-finalize-epic shamt-core/host/templates/claude/skills/pe3-finalize`

**6b. In-body EDITs** (against `shamt-core/host/templates/claude/skills/pe3-finalize/SKILL.md`):
- Front-matter — `name: p5-finalize-epic` → `name: pe3-finalize`.
- Line 21: `Mirrors the \`/p5-finalize-epic {slug}\` slash command.` → `/pe3-finalize`.
- Line 25: `Follow the canonical \`/p5-finalize-epic\` command body verbatim — see [\`commands/p5-finalize-epic.md\`](../../commands/p5-finalize-epic.md).` → `/pe3-finalize`, `commands/pe3-finalize.md`, link `../../commands/pe3-finalize.md`.
- Footer (line 45): `Regenerate from shamt-core/host/templates/claude/skills/p5-finalize-epic/SKILL.md.` → `…/skills/pe3-finalize/SKILL.md.`

**Verification:**
- `grep -nF '/p5-finalize-epic' shamt-core/host/templates/claude/skills/pe3-finalize/SKILL.md` returns **zero** matches.
- `grep -F 'name: pe3-finalize' shamt-core/host/templates/claude/skills/pe3-finalize/SKILL.md` returns one match.
- `test ! -d shamt-core/host/templates/claude/skills/p5-finalize-epic`

---

## Row → step mapping (Phase 2)

| Proposal row | Plan step |
|---|---|
| 9 (`p1-start-epic.md` → `pe1-define.md`) | Step 1 |
| 10 (`p1-start-epic/` skill → `pe1-define/`) | Step 2 |
| 11 (`p2-decompose-epic.md` → `pe2-decompose.md`) | Step 3 |
| 12 (`p2-decompose-epic/` skill → `pe2-decompose/`) | Step 4 |
| 17 (`p5-finalize-epic.md` → `pe3-finalize.md`) | Step 5 |
| 18 (`p5-finalize-epic/` skill → `pe3-finalize/`) | Step 6 |

---
Validated 2026-06-14 — batch-validated (Standard path), 1 adversarial sub-agent confirmed
