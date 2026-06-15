# Implementation Plan — Phase 3: Feature-lane MOVEs

**Proposal:** proposals/26-po-draft-stub-skills-incremental-decomposition.md
**Index:** proposals/26-po-draft-stub-skills-incremental-decomposition_PLAN.md
**Source rows:** 13–16 (section B, feature lane)
**Operations:** 4 MOVE (2 commands + 2 mirror skills, each = `git mv` + in-body rewrite)

> Same MOVE discipline as Phase 2: `git mv` first, then in-body EDITs against the new path, including the trailing `Regenerate from …` footer. Naming map: `/p3-start-feature` → `/pf1-define`, `/p4-decompose-feature` → `/pf2-decompose`; cross-references to `/p1-start-epic` → `/pe1-define` and `/p2-decompose-epic` → `/pe2-decompose`.

---

## Step 1 — MOVE `commands/p3-start-feature.md` → `commands/pf1-define.md` (row 13)

**Operation:** MOVE
**1a. Rename:** `git mv shamt-core/host/templates/claude/commands/p3-start-feature.md shamt-core/host/templates/claude/commands/pf1-define.md`

**1b. In-body EDITs** (against `shamt-core/host/templates/claude/commands/pf1-define.md`) — this file has the densest reference set (30 `/pN-` hits: 9 `/p3-start-feature` self + 9 `/p1-start-epic` + 7 `/p4-decompose-feature` + 5 `/p2-decompose-epic`, the last counting the front-matter description occurrence). Apply the naming map to **every** occurrence; the enumerated sites below are the current locations. The grep-zero verification (below) is the binding completeness check — the line numbers are a navigation aid:
- **Front-matter `description:`** (line 2) — `flesh out a feature (stub from /p2-decompose-epic, …)` → `/pe2-decompose`; `ready for /validate-artifact` unchanged.
- **H1** (line 5) — `# /p3-start-feature` → `# /pf1-define`.
- **`/p3-start-feature` self-references** → `/pf1-define` (sites — `/p3-start-feature` occurrences only, distinct from the cross-ref sites in the bullets below: lines 5 H1, 16 usage, 49 "a prior /p3-start-feature deep-dive ran", 61, 109, 110, 179 ("mirrors … and /p1-start-epic" — the /p3-start-feature token on that line), 199, 202 footer text). The H1 (line 5) and footer (line 202) are also called out separately above/below for emphasis; apply once per occurrence.
- **`/p2-decompose-epic` cross-refs** → `/pe2-decompose` (sites: line 7 Purpose "existing stub written by /p2-decompose-epic", line 48 "per the /p2-decompose-epic Step 8 contract", line 80 Mode-A heading "the common case after /p2-decompose-epic", line 82).
- **`/p1-start-epic` cross-refs** → `/pe1-define` (sites: line 9 "same justification as /p1-start-epic", line 24, line 55 "same rules as /p1-start-epic", line 113, 120, 130, 179 "mirrors … and /p1-start-epic's tracker plumbing", 181, 197 — every "Same rule as /p1-start-epic"). (Line 179 carries both a /p3-start-feature self-ref and this /p1-start-epic cross-ref — apply each to its own token.)
- **`/p4-decompose-feature` cross-refs** → `/pf2-decompose` (sites: line 7 "Leaves Target Stories … /p4-decompose-feature fills them later", line 86, line 140, line 156, line 175 next-phase, line 195, line 196).
- **Add stage-0 draft ingestion input mode** — the `/pf0-draft` draft is ingested via the **existing Mode-A path** (a `/pf0-draft` feature draft carries the same populated `## Goal` stub shape, so it resolves and disambiguates as Mode A), with a marker-detect → ingest → strip-on-completion sub-flow added. Two exact edits:

  **(i) Mode-disambiguation note.** Locate (Step 4 intro, line 76 — the Mode-A bullet):
  ```
  1. **Mode A — flesh out an existing stub** if Step 2 resolved to a folder whose `feature.md` matches the stub shape (decomposition-authored fields filled — Goal one-liner, plus `## Scope / Non-Scope` + `## Decomposition Context` on a richer-cataloging stub — but the depth sections `## Success Criteria` / `## Open Questions` still empty; parentage is the folder path).
  ```
  Append (immediately after that line, as the new line 77, before the existing Mode-C bullet) this exact text:
  ```
     - **Stage-0 draft variant of Mode A.** A `feature.md` written by `/pf0-draft` is the same shape (populated `## Goal`, depth sections empty) **plus** a stage-0 draft marker — a `**Status:** Draft (f0 — feature-idea capture, unrefined)` header line and a `## Scratch Notes (stage-0 capture)` section. Detect the marker; when present, this is the **draft-ingest** sub-case of Mode A (handled below). When absent, it is the ordinary decompose-stub Mode A. Either way Mode A wins the disambiguation; the marker only selects the sub-case.
  ```

  **(ii) Mode-A ingest + strip sub-step.** Locate (the Mode-A sub-step list — the exact current line 84):
  ```
  1. **Preserve the `## Goal` verbatim.** Do not rewrite it.
  ```
  Insert, immediately **above** that `1.` line (as a new leading paragraph of the Mode-A body, between the Mode-A intro paragraph at line 82 and sub-step 1), this exact text:
  ```
  **Stage-0 draft ingest.** If the resolved `feature.md` carries the `/pf0-draft` stage-0 draft marker (`**Status:** Draft (f0 — feature-idea capture, unrefined)` + a `## Scratch Notes (stage-0 capture)` section), **ingest the draft** the way `/f1-propose-update` ingests an f0 draft: seed the open-questions dialog (Step 6) from the captured `## Scratch Notes (stage-0 capture)` content (and the populated `## Goal`), then **strip both the `**Status:** Draft (f0 …)` marker line and the entire `## Scratch Notes (stage-0 capture)` section on completion** so the finished `feature.md` carries no draft residue. When the marker is **absent** (an ordinary `/pf2-decompose` stub or an older stub), the existing seed-from-`## Decomposition Context` / bare-stub path below is unchanged.
  ```
  (This mirrors the epic-lane `/pe1-define` ingest edit in the Phase-2 plan. `/pf2-decompose` itself stays UNCHANGED — it emits bare, marker-less stubs; only `/pf1-define` gains the detect/ingest/strip.)
- **Next-phase** → `/pf2-decompose` (line 175).
- **Footer** (line 202) — `Regenerate from shamt-core/host/templates/claude/commands/p3-start-feature.md.` → `…/commands/pf1-define.md.`

**Verification:**
- `grep -nE '/p[1-4]-(start|decompose)' shamt-core/host/templates/claude/commands/pf1-define.md` returns **zero** matches.
- `grep -F '# /pf1-define' shamt-core/host/templates/claude/commands/pf1-define.md` returns one match.
- `grep -F 'Regenerate from shamt-core/host/templates/claude/commands/pf1-define.md' shamt-core/host/templates/claude/commands/pf1-define.md` returns one match.
- `test ! -f shamt-core/host/templates/claude/commands/p3-start-feature.md`

---

## Step 2 — MOVE `skills/p3-start-feature/SKILL.md` → `skills/pf1-define/SKILL.md` (row 14)

**Operation:** MOVE
**2a. Rename:** `git mv shamt-core/host/templates/claude/skills/p3-start-feature shamt-core/host/templates/claude/skills/pf1-define`

**2b. In-body EDITs** (against `shamt-core/host/templates/claude/skills/pf1-define/SKILL.md`):
- Front-matter `name: p3-start-feature` → `name: pf1-define`.
- Line 5 description: `flesh out an existing feature stub written by /p2-decompose-epic` → `/pe2-decompose`.
- Line 29: `Mirrors the \`/p3-start-feature {slug}\` slash command.` → `/pf1-define`.
- Line 33: `Follow the canonical \`/p3-start-feature\` command body verbatim — see [\`commands/p3-start-feature.md\`](../../commands/p3-start-feature.md).` → `/pf1-define`, `commands/pf1-define.md`, link `../../commands/pf1-define.md`.
- Line 38: `a prior /p3-start-feature deep-dive ran` → `/pf1-define`.
- Line 42: `Same rule as /p1-start-epic` → `/pe1-define`.
- Line 44: `Same rule as /p1-start-epic` → `/pe1-define`.
- Line 45: `owned by /p4-decompose-feature` → `/pf2-decompose`.
- Line 55: `Same justification as /p1-start-epic` → `/pe1-define`.
- Add a one-line note (in the Mode-A bullet of the Protocol summary, around line 41) that define ingests a `/pf0-draft` stage-0 draft when present — detect the `**Status:** Draft (f0 …)` marker + `## Scratch Notes (stage-0 capture)` section, seed the dialog from it, strip both on completion (mirrors the command body's new input mode). Exact insert text: `When the Mode-A \`feature.md\` carries a \`/pf0-draft\` stage-0 marker (\`**Status:** Draft (f0 …)\` + \`## Scratch Notes (stage-0 capture)\`), ingest it — seed the dialog from the Scratch Notes, then strip the marker + Scratch Notes on completion.`
- Footer (line 61): `Regenerate from shamt-core/host/templates/claude/skills/p3-start-feature/SKILL.md.` → `…/skills/pf1-define/SKILL.md.`

**Verification:**
- `grep -nE '/p[1-4]-(start|decompose)' shamt-core/host/templates/claude/skills/pf1-define/SKILL.md` returns **zero** matches.
- `grep -F 'name: pf1-define' shamt-core/host/templates/claude/skills/pf1-define/SKILL.md` returns one match.
- `grep -F 'Regenerate from shamt-core/host/templates/claude/skills/pf1-define/SKILL.md' shamt-core/host/templates/claude/skills/pf1-define/SKILL.md` returns one match (footer path rewritten — the grep-zero check above does not cover the path-only footer).
- `test ! -d shamt-core/host/templates/claude/skills/p3-start-feature`

---

## Step 3 — MOVE `commands/p4-decompose-feature.md` → `commands/pf2-decompose.md` (row 15)

**Operation:** MOVE
**3a. Rename:** `git mv shamt-core/host/templates/claude/commands/p4-decompose-feature.md shamt-core/host/templates/claude/commands/pf2-decompose.md`

**3b. In-body EDITs** (against `shamt-core/host/templates/claude/commands/pf2-decompose.md`):
- **H1** (line 5) — `# /p4-decompose-feature` → `# /pf2-decompose`.
- **`/p4-decompose-feature` self-references** → `/pf2-decompose` (sites: line 16 usage, line 212, line 223 footer text).
- **`/p3-start-feature` cross-refs** → `/pf1-define` (sites: line 26 "direct the user to /p3-start-feature {slug} first", line 39 "direct to /p3-start-feature {slug}").
- **`/p2-decompose-epic` cross-refs** → `/pe2-decompose` (sites: line 9 "Same justification as /p2-decompose-epic", line 22 "Same semantics as /p2-decompose-epic's flag", line 60 "Same partition rule as /p2-decompose-epic Step 3", line 87 "Same Kept-exception rule as /p2-decompose-epic", line 150 "Same format as /p2-decompose-epic Step 9", line 171 "Same format as /p2-decompose-epic's orphan warning").
- **Carry forward** re-decomposition partition + individually-testable rubric logic unchanged except for command-name substitutions.
- **Cross-ref `/ps0-draft` as the single-add alternative** (proposal row 15) — insert a new Notes bullet. The EXACT locate anchor is the existing Notes-section bullet (currently line 216):

  ```text
  - **No per-story deep dialog here.** That is `/e1-start-story` (stub-aware)'s job per the stub-list-then-drill-in decomposition. Resist the urge to start drafting story acceptance criteria, spec sections, or implementation plans — it produces low-value batched dialog at this altitude and pre-empts the open-questions iterative dialog at the next altitude.
  ```

  (Note: this anchor line's `/e1-start-story` references are **preserved verbatim** in this phase — they are not rewritten by the row scope; locate on the stable prefix `- **No per-story deep dialog here.**`.) Insert the following EXACT bullet on a new line immediately **after** that anchor bullet:

  ```text
  - **Single-add alternative — `/ps0-draft`.** To add just **one** story to an already-decomposed feature, prefer `/ps0-draft {feature-slug}` (the incremental single-stub producer, which appends one story stub to this feature's `## Target Stories` without re-gating) rather than re-running this batch decompose. Re-running `/pf2-decompose` re-presents and re-gates the *entire* story list (Step 3 re-decomposition partition); the single-add path skips that.
  ```
- **Next-phase → `/ps1-define`** — the per-stub PO-flow next-command suggestion (proposal row 15 "next-phase → `/ps1-define`"). **Exact sites — only the two suggested-command lines in the Step 11 code fence (lines 195–196):**
  - line 195: `/e1-start-story {story-slug-1}     # flesh out the first stub` → `/ps1-define {story-slug-1}     # flesh out the first stub`
  - line 196: `/e1-start-story {story-slug-2}     # ...and so on` → `/ps1-define {story-slug-2}     # ...and so on`

  **Every other `/e1-start-story` occurrence stays verbatim** — the remaining occurrences are on lines 7 (×1), 65 (×1), 84 (×1), 107 (×1), 139 (×2), 140 (×1), 141 (×2), 199 (×2 command tokens + 1 file-path mention), 216 (×1), 218 (×1) — **10 lines, 13 command-token occurrences** that document the Engineer-flow handoff / stub-awareness; `/e1` remains the stub-aware Engineer entry. They are NOT rewritten here: the row scope is the PO-flow next-command suggestion only; the `/e1` body itself is edited under proposal row 21 in Phase 4. In particular, leave line 199's "`/e1-start-story` is **stub-aware** … (see `commands/e1-start-story.md`)" prose unchanged.
- **Footer** (line 223) — `Regenerate from shamt-core/host/templates/claude/commands/p4-decompose-feature.md.` → `…/commands/pf2-decompose.md.`

**Verification:**
- `grep -nE '/p[1-4]-(start|decompose)' shamt-core/host/templates/claude/commands/pf2-decompose.md` returns **zero** matches.
- `grep -F '/ps0-draft' shamt-core/host/templates/claude/commands/pf2-decompose.md` returns ≥1 match (single-add cross-ref present).
- `grep -F '/ps1-define {story-slug-1}' shamt-core/host/templates/claude/commands/pf2-decompose.md` returns one match (Step 11 next-command suggestion rewritten).
- `grep -cF '/e1-start-story' shamt-core/host/templates/claude/commands/pf2-decompose.md` returns **exactly `10`** (down from `12` in the pre-MOVE `p4-decompose-feature.md`). `grep -cF` counts **matching lines**: the live file has 12 lines containing `/e1-start-story`; the two Step 11 suggested-command lines (195, 196 — each one occurrence, no other `/e1` text) are rewritten to `/ps1-define`, removing those 2 lines from the match, leaving **10**. The preserved lines are **7, 65, 84, 107, 139, 140, 141, 199, 216, 218** (10 lines; 13 command-token occurrences, since lines 139 and 141 carry the token twice and line 199 twice — line 199's third `/e1-start-story` substring is the file path `commands/e1-start-story.md`, not a command token) — all Engineer-flow handoff / stub-awareness documentation, including line 199's "`/e1-start-story` is **stub-aware** … (see `commands/e1-start-story.md`)" prose, which stays verbatim.
- `grep -F 'Regenerate from shamt-core/host/templates/claude/commands/pf2-decompose.md' shamt-core/host/templates/claude/commands/pf2-decompose.md` returns one match.
- `test ! -f shamt-core/host/templates/claude/commands/p4-decompose-feature.md`

---

## Step 4 — MOVE `skills/p4-decompose-feature/SKILL.md` → `skills/pf2-decompose/SKILL.md` (row 16)

**Operation:** MOVE
**4a. Rename:** `git mv shamt-core/host/templates/claude/skills/p4-decompose-feature shamt-core/host/templates/claude/skills/pf2-decompose`

**4b. In-body EDITs** (against `shamt-core/host/templates/claude/skills/pf2-decompose/SKILL.md`):
- Front-matter `name: p4-decompose-feature` → `name: pf2-decompose`.
- Line 28: `Mirrors the \`/p4-decompose-feature {slug}\` slash command.` → `/pf2-decompose`.
- Line 32: `Follow the canonical \`/p4-decompose-feature\` command body verbatim — see [\`commands/p4-decompose-feature.md\`](../../commands/p4-decompose-feature.md).` → `/pf2-decompose`, `commands/pf2-decompose.md`, link `../../commands/pf2-decompose.md`.
- Line 64: `**No tracker fetch** at this altitude — \`/p4-decompose-feature\` operates entirely on the already-written \`feature.md\`.` → replace the `/p4-decompose-feature` self-ref with `/pf2-decompose` (a third self-reference distinct from lines 28/32). Apply the naming map to **every** `/p4-decompose-feature` / `/p3-start-feature` / `/p2-decompose-epic` occurrence — the grep-zero verification below is the binding completeness check.
- Line 34: `direct to /p3-start-feature {slug}` → `/pf1-define`.
- Line 70: `Same justification as /p2-decompose-epic` → `/pe2-decompose`.
- Footer (line 76): `Regenerate from shamt-core/host/templates/claude/skills/p4-decompose-feature/SKILL.md.` → `…/skills/pf2-decompose/SKILL.md.`

**Verification:**
- `grep -nE '/p[1-4]-(start|decompose)' shamt-core/host/templates/claude/skills/pf2-decompose/SKILL.md` returns **zero** matches.
- `grep -F 'name: pf2-decompose' shamt-core/host/templates/claude/skills/pf2-decompose/SKILL.md` returns one match.
- `grep -F 'Regenerate from shamt-core/host/templates/claude/skills/pf2-decompose/SKILL.md' shamt-core/host/templates/claude/skills/pf2-decompose/SKILL.md` returns one match (footer path rewritten — the grep-zero check above does not cover the path-only footer).
- `test ! -d shamt-core/host/templates/claude/skills/p4-decompose-feature`

---

## Row → step mapping (Phase 3)

| Proposal row | Plan step |
|---|---|
| 13 (`p3-start-feature.md` → `pf1-define.md`) | Step 1 |
| 14 (`p3-start-feature/` skill → `pf1-define/`) | Step 2 |
| 15 (`p4-decompose-feature.md` → `pf2-decompose.md`) | Step 3 |
| 16 (`p4-decompose-feature/` skill → `pf2-decompose/`) | Step 4 |

---
Validated 2026-06-14 — batch-validated (Standard path), 1 adversarial sub-agent confirmed
