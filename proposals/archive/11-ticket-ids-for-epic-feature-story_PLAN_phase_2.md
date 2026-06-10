# Implementation Plan — Phase 2 — ticket-ids-for-epic-feature-story (#11)

**Created:** 2026-06-09
**Index:** `proposals/11-ticket-ids-for-epic-feature-story_PLAN.md`
**Proposal:** `proposals/11-ticket-ids-for-epic-feature-story.md` (Validated 2026-06-08)
**Cuts in this phase:** proposal rows 2–9 (PO commands p1–p4 + skills) and rows 12–13 (epic + feature templates).
**Files edited:** `host/templates/claude/commands/{p1,p2,p3,p4}*.md` + their skills; `templates/epic.template.md`, `templates/feature.template.md`.

> **Deploy order:** runs after Phase 1 (the contract). All edits implement Phase 1's resolver/allocator/naming/back-ref. Re-confirm anchors against the live files.

**Reusable allocation phrase** (used in several steps): *"allocate a ticket ID `T{N}` = `max` of the `^T([0-9]+)-` prefixes across `epics/`, `features/`, and `stories/`, + 1 — per **# Ticket IDs**"*.

---

## Step 1: p1-start-epic command (proposal row 2)
**Operation:** EDIT — `host/templates/claude/commands/p1-start-epic.md`
- **1a — resolution (lines 43–44):**
  - **Locate:** `1. Try \`epics/{slug}/epic.md\` (exact match).
2. If not found, glob \`epics/{slug}-*/epic.md\`.`
  - **Replace:** `1. If \`{id-or-slug}\` is a ticket ID (\`^T[0-9]+$\`), glob \`epics/{ID}-*/epic.md\`; otherwise try \`epics/{slug}/epic.md\` (exact match).
2. If still not found (a slug), glob **both** \`epics/{slug}-*/epic.md\` and \`epics/*-{slug}-*/epic.md\`.`
- **1b — folder + ID allocation (line 63):**
  - **Locate:** `2. Propose \`epics/{slug}-{brief-description-kebab}/\` and ask the user to confirm before creating the directory. Lowercase, hyphen-separated.`
  - **Replace:** `2. Allocate a ticket ID \`T{N}\` (= \`max\` of the \`^T([0-9]+)-\` prefixes across \`epics/\`, \`features/\`, and \`stories/\`, + 1 — per **# Ticket IDs**); propose \`epics/{ID}-{slug}-{brief-description-kebab}/\` and ask the user to confirm before creating the directory; populate the epic's \`**Ticket ID:** T{N}\` header. Lowercase, hyphen-separated.`
- **1c — collision glob (line 121):**
  - **Locate:** `1. Glob \`epics/{slug}-*/\` (and the exact \`epics/{slug}/\`) and confirm only one folder exists for this slug.`
  - **Replace:** `1. Glob \`epics/{ID}-*/\` (for a ticket ID) or, for a slug, **both** \`epics/{slug}-*/\` and \`epics/*-{slug}-*/\` (and the exact \`epics/{slug}/\`), and confirm only one folder exists for this ticket.`

**Verification:** `grep -Fc "epics/{ID}-{slug}-{brief-description-kebab}/" host/templates/claude/commands/p1-start-epic.md` → `1`; `grep -Fc "epics/*-{slug}-*/epic.md" host/templates/claude/commands/p1-start-epic.md` → `1`.

---

## Step 2: p1-start-epic skill (proposal row 3 — mirror)
**Operation:** EDIT — `host/templates/claude/skills/p1-start-epic/SKILL.md`
- **2a (line 33):**
  - **Locate:** `2. **Resolve \`{slug}\`** to \`epics/{slug}/\` (exact) or \`epics/{slug}-*/\` (glob). Halt on multiple matches.`
  - **Replace:** `2. **Resolve \`{id-or-slug}\`** — a ticket ID globs \`epics/{ID}-*/\`; a slug tries \`epics/{slug}/\` (exact) then **both** \`epics/{slug}-*/\` and \`epics/*-{slug}-*/\` (glob). Halt on multiple matches.`
- **2b (line 34):**
  - **Locate:** `3. **For new epics:** ask the user for a 2–4-word brief description; propose and create \`epics/{slug}-{brief}/\`.`
  - **Replace:** `3. **For new epics:** allocate a ticket ID \`T{N}\` (max across \`epics/\`, \`features/\`, \`stories/\` + 1), ask for a 2–4-word brief description, and create \`epics/{ID}-{slug}-{brief}/\` with the \`**Ticket ID:** T{N}\` header.`

**Verification:** `grep -Fc "epics/{ID}-{slug}-{brief}/" host/templates/claude/skills/p1-start-epic/SKILL.md` → at least `1`.

---

## Step 3: p2-decompose-epic command (proposal row 4)
**Operation:** EDIT — `host/templates/claude/commands/p2-decompose-epic.md`
- **3a — resolution (lines 35–36):**
  - **Locate:** `1. Try \`epics/{slug}/epic.md\` (exact match).
2. If not found, glob \`epics/{slug}-*/epic.md\`.`
  - **Replace:** `1. If \`{id-or-slug}\` is a ticket ID (\`^T[0-9]+$\`), glob \`epics/{ID}-*/epic.md\`; otherwise try \`epics/{slug}/epic.md\` (exact match).
2. If still not found (a slug), glob **both** \`epics/{slug}-*/epic.md\` and \`epics/*-{slug}-*/epic.md\`.`
- **3b — Step 8 stub creation + ID (line 110):**
  - **Locate:** `- **New partition (per Step 3) — and every feature on first decomposition:** create \`features/{feature-slug}-{brief}/feature.md\` from [\`templates/feature.template.md\`](../../../../templates/feature.template.md). Populate **only** these fields:`
  - **Replace:** `- **New partition (per Step 3) — and every feature on first decomposition:** allocate a ticket ID \`T{N}\` for the feature (= \`max\` of the \`^T([0-9]+)-\` prefixes across \`epics/\`, \`features/\`, \`stories/\`, + 1 — per **# Ticket IDs**) and create \`features/{ID}-{feature-slug}-{brief}/feature.md\` from [\`templates/feature.template.md\`](../../../../templates/feature.template.md). Populate **only** these fields:`
- **3c — back-ref + Ticket ID header (line 111):**
  - **Locate:** `  - \`**Parent Epic:** {epic-slug}\` — back-ref header line directly under the H1. Plain markdown; no parser.`
  - **Replace:** (two bullets replacing the one — both indented **2 spaces**, matching the source bullet's indent)
```
  - `**Ticket ID:** T{N}` — the feature's allocated ID; a header line directly under the H1.
  - `**Parent Epic:** T{N} ({epic-slug})` — back-ref to the parent epic (its ID + slug), a header line directly under the H1. Plain markdown; no parser.
```
  - *(Note: the source bullet is indented **2 spaces**; both replacement bullets keep that 2-space indent.)*
- **3d — Kept-partition both-positions glob (line 69):**
  - **Locate:** `Resolve the existing folder via \`features/{feature-slug}-*/\` glob`
  - **Replace:** `Resolve the existing folder via the both-positions slug glob \`features/{feature-slug}-*/\` ∪ \`features/*-{feature-slug}-*/\` (the latter finds an ID-prefixed Kept folder)`

**Verification:** `grep -Fc "features/{ID}-{feature-slug}-{brief}/feature.md" host/templates/claude/commands/p2-decompose-epic.md` → `1`; `grep -Fc "Parent Epic:** T{N} ({epic-slug})" host/templates/claude/commands/p2-decompose-epic.md` → `1`; `grep -Fc "features/*-{feature-slug}-*/" host/templates/claude/commands/p2-decompose-epic.md` → at least `1`.

---

## Step 4: p2-decompose-epic skill (proposal row 5 — mirror)
**Operation:** EDIT — `host/templates/claude/skills/p2-decompose-epic/SKILL.md`
- **4a (line 33):**
  - **Locate:** `1. **Resolve \`{slug}\`** to \`epics/{slug}/\` (exact) or \`epics/{slug}-*/\` (glob). Halt if missing — direct to \`/p1-start-epic {slug}\`.`
  - **Replace:** `1. **Resolve \`{id-or-slug}\`** — a ticket ID globs \`epics/{ID}-*/\`; a slug tries \`epics/{slug}/\` (exact) then **both** \`epics/{slug}-*/\` and \`epics/*-{slug}-*/\` (glob). Halt if missing — direct to \`/p1-start-epic {slug}\`. Each New feature gets an allocated ticket ID (\`T{N}\`) + a \`**Parent Epic:** T{N} (slug)\` back-ref.`

**Verification:** `grep -Fc "epics/*-{slug}-*/" host/templates/claude/skills/p2-decompose-epic/SKILL.md` → at least `1`.

---

## Step 5: p3-start-feature command (proposal row 6)
**Operation:** EDIT — `host/templates/claude/commands/p3-start-feature.md`
- **5a — resolution (lines 44–45):**
  - **Locate:** `1. Try \`features/{slug}/feature.md\` (exact match).
2. If not found, glob \`features/{slug}-*/feature.md\`.`
  - **Replace:** `1. If \`{id-or-slug}\` is a ticket ID (\`^T[0-9]+$\`), glob \`features/{ID}-*/feature.md\`; otherwise try \`features/{slug}/feature.md\` (exact match).
2. If still not found (a slug), glob **both** \`features/{slug}-*/feature.md\` and \`features/*-{slug}-*/feature.md\`.`
- **5b — stub-detection back-ref format (line 48):**
  - **Locate:** `   - If \`feature.md\` has **only** \`**Parent Epic:** {epic-slug}\` and \`## Goal\` filled in (every other section empty per the \`/p2-decompose-epic\` Step 8 contract), this is a **stub** — proceed to **Mode A** under Step 4.`
  - **Replace:** `   - If \`feature.md\` has **only** \`**Ticket ID:** T{N}\` + \`**Parent Epic:** T{N} ({epic-slug})\` + \`## Goal\` filled in (every other section empty per the \`/p2-decompose-epic\` Step 8 contract), this is a **stub** — proceed to **Mode A** under Step 4.`
- **5c — folder + ID allocation / stub preservation (line 69):**
  - **Locate:** `2. Propose \`features/{slug}-{brief-description-kebab}/\` and ask the user to confirm before creating the directory. Lowercase, hyphen-separated.`
  - **Replace:** `2. **For a new (non-stub) feature, allocate a ticket ID** \`T{N}\` (= \`max\` of the \`^T([0-9]+)-\` prefixes across \`epics/\`, \`features/\`, \`stories/\`, + 1 — per **# Ticket IDs**) and propose \`features/{ID}-{slug}-{brief-description-kebab}/\`, populating the \`**Ticket ID:** T{N}\` header. **Mode A (stub):** the folder + its ID already exist — reuse them, do **not** allocate or re-propose. Ask the user to confirm before creating directories. Lowercase, hyphen-separated.`
- **5d — preserve the Ticket ID header on re-entry (line 61):**
  - **Locate:** `**Preserve back-ref headers verbatim on re-entry.** \`**Parent Epic:** …\` and (when present) \`**Parent Feature:** …\` lines are never rewritten by \`/p3-start-feature\` regardless of the chosen branch — they are decomposition-owned per the decomposition step. Only the body sections are touched.`
  - **Replace:** `**Preserve the \`**Ticket ID:**\` and back-ref headers verbatim on re-entry.** The \`**Ticket ID:** …\`, \`**Parent Epic:** …\` and (when present) \`**Parent Feature:** …\` lines are never rewritten by \`/p3-start-feature\` regardless of the chosen branch — they are decomposition-owned per the decomposition step. Only the body sections are touched.`
- **5e — slug-collision glob (line 146) — widen to both positions:** mirrors the p1/p2/p4 collision fix so a new feature slug cannot silently collide with an ID-prefixed existing folder.
  - **Locate:** `1. Glob \`features/{slug}-*/\` (and the exact \`features/{slug}/\`) and confirm only one folder exists for this slug.`
  - **Replace:** `1. Glob \`features/{ID}-*/\` (for a ticket ID) or, for a slug, **both** \`features/{slug}-*/\` and \`features/*-{slug}-*/\` (and the exact \`features/{slug}/\`), and confirm only one folder exists for this feature.`

**Verification:** `grep -Fc "features/{ID}-{slug}-{brief-description-kebab}/" host/templates/claude/commands/p3-start-feature.md` → `1`; `grep -Fc "do **not** allocate or re-propose" host/templates/claude/commands/p3-start-feature.md` → `1`; `grep -Fc "features/*-{slug}-*/feature.md" host/templates/claude/commands/p3-start-feature.md` → `1`; `grep -Fc "confirm only one folder exists for this feature" host/templates/claude/commands/p3-start-feature.md` → `1` (collision glob widened).

---

## Step 6: p3-start-feature skill (proposal row 7 — mirror)
**Operation:** EDIT — `host/templates/claude/skills/p3-start-feature/SKILL.md`
- **6a (line 37):**
  - **Locate:** `2. **Resolve \`{slug}\`** to \`features/{slug}/\` (exact) or \`features/{slug}-*/\` (glob). Halt on multiple matches. On a one-match resolution, **inspect \`feature.md\`** to decide Mode A vs. re-entry:`
  - **Replace:** `2. **Resolve \`{id-or-slug}\`** — a ticket ID globs \`features/{ID}-*/\`; a slug tries \`features/{slug}/\` (exact) then **both** \`features/{slug}-*/\` and \`features/*-{slug}-*/\` (glob). Halt on multiple matches. A new feature gets an allocated ticket ID; a Mode A stub preserves its ID. On a one-match resolution, **inspect \`feature.md\`** to decide Mode A vs. re-entry:`

**Verification:** `grep -Fc "features/*-{slug}-*/" host/templates/claude/skills/p3-start-feature/SKILL.md` → at least `1`.

---

## Step 7: p4-decompose-feature command (proposal row 8)
**Operation:** EDIT — `host/templates/claude/commands/p4-decompose-feature.md`
- **7a — resolution (lines 35–36):**
  - **Locate:** `1. Try \`features/{slug}/feature.md\` (exact match).
2. If not found, glob \`features/{slug}-*/feature.md\`.`
  - **Replace:** `1. If \`{id-or-slug}\` is a ticket ID (\`^T[0-9]+$\`), glob \`features/{ID}-*/feature.md\`; otherwise try \`features/{slug}/feature.md\` (exact match).
2. If still not found (a slug), glob **both** \`features/{slug}-*/feature.md\` and \`features/*-{slug}-*/feature.md\`.`
- **7b — Step 8 stub creation + ID (line 130):**
  - **Locate:** `- **New partition (per Step 3) — and every story on first decomposition:** create \`stories/{story-slug}-{brief}/ticket.md\` from the active tracker's per-provider ticket template. **Template selection rule:** read \`work_item_tracker\` from \`.shamt-core/shamt-config.json\`:`
  - **Replace:** `- **New partition (per Step 3) — and every story on first decomposition:** allocate a ticket ID \`T{N}\` for the story (= \`max\` of the \`^T([0-9]+)-\` prefixes across \`epics/\`, \`features/\`, \`stories/\`, + 1 — per **# Ticket IDs**) and create \`stories/{ID}-{story-slug}-{brief}/ticket.md\` from the active tracker's per-provider ticket template. **Template selection rule:** read \`work_item_tracker\` from \`.shamt-core/shamt-config.json\`:`
- **7c — Parent Feature back-ref (line 137):**
  - **Locate:** `    - \`**Parent Feature:** {feature-slug}\` — required for every stub written by this command.`
  - **Replace:** `    - \`**Parent Feature:** T{N} ({feature-slug})\` (the parent feature's ID + slug) — required for every stub written by this command.`
  - *(Note: the bullet is indented **4 spaces** — match exactly.)*
- **7d — Parent Epic back-ref (line 138):**
  - **Locate:** `    - \`**Parent Epic:** {parent-epic-slug}\` — populated from the parent feature's \`**Parent Epic:**\` header (read in Step 4 sub-step 1).`
  - **Replace:** `    - \`**Parent Epic:** T{N} ({parent-epic-slug})\` — populated from the parent feature's \`**Parent Epic:**\` header (read in Step 4 sub-step 1).`
  - *(Note: the bullet is indented **4 spaces** — match exactly.)*
- **7e — Kept-partition both-positions glob (line 87):**
  - **Locate:** `Resolve the existing folder via \`stories/{story-slug}-*/\` glob`
  - **Replace:** `Resolve the existing folder via the both-positions slug glob \`stories/{story-slug}-*/\` ∪ \`stories/*-{story-slug}-*/\` (the latter finds an ID-prefixed Kept folder)`

**Verification:** `grep -Fc "stories/{ID}-{story-slug}-{brief}/ticket.md" host/templates/claude/commands/p4-decompose-feature.md` → `1`; `grep -Fc "Parent Feature:** T{N} ({feature-slug})" host/templates/claude/commands/p4-decompose-feature.md` → `1`; `grep -Fc "stories/*-{story-slug}-*/" host/templates/claude/commands/p4-decompose-feature.md` → at least `1`.

---

## Step 8: p4-decompose-feature skill (proposal row 9 — mirror)
**Operation:** EDIT — `host/templates/claude/skills/p4-decompose-feature/SKILL.md`
- **8a (line 35):**
  - **Locate:** `1. **Resolve \`{slug}\`** to \`features/{slug}/\` (exact) or \`features/{slug}-*/\` (glob). Halt if missing — direct to \`/p3-start-feature {slug}\`.`
  - **Replace:** `1. **Resolve \`{id-or-slug}\`** — a ticket ID globs \`features/{ID}-*/\`; a slug tries \`features/{slug}/\` (exact) then **both** \`features/{slug}-*/\` and \`features/*-{slug}-*/\` (glob). Halt if missing — direct to \`/p3-start-feature {slug}\`. Each New story gets an allocated ticket ID (\`T{N}\`) + \`**Parent Feature:** T{N} (slug)\` (+ \`**Parent Epic:** T{N} (slug)\` when present) back-refs.`

**Verification:** `grep -Fc "features/*-{slug}-*/" host/templates/claude/skills/p4-decompose-feature/SKILL.md` → at least `1`.

---

## Step 9: epic.template.md (proposal row 12)
**Operation:** EDIT — `templates/epic.template.md`
- **9a — layout comment (line 1):**
  - **Locate:** `<!-- Epic artifact. Lives at epics/{slug}-{brief}/epic.md (flat layout; globally unique slug). -->`
  - **Replace:** `<!-- Epic artifact. Lives at epics/{ID}-{slug}-{brief}/epic.md ({ID}- prefix is the ticket ID; globally unique slug). -->`
- **9b — H1 + Ticket ID header (line 2):**
  - **Locate:** `# Epic {slug}`
  - **Replace:** `# Epic {slug}

**Ticket ID:** {ID}`

**Verification:** `grep -Fc "**Ticket ID:** {ID}" templates/epic.template.md` → `1`; `grep -Fc "epics/{ID}-{slug}-{brief}/epic.md" templates/epic.template.md` → `1`.

---

## Step 10: feature.template.md (proposal row 13)
**Operation:** EDIT — `templates/feature.template.md`
- **10a — layout comment (line 1):**
  - **Locate:** `<!-- Feature artifact. Lives at features/{slug}-{brief}/feature.md (flat layout; globally unique slug). -->`
  - **Replace:** `<!-- Feature artifact. Lives at features/{ID}-{slug}-{brief}/feature.md ({ID}- prefix is the ticket ID; globally unique slug). -->`
- **10b — H1 + Ticket ID header (line 2):**
  - **Locate:** `# Feature {slug}`
  - **Replace:** `# Feature {slug}

**Ticket ID:** {ID}`
- **10c — Parent Epic back-ref format (line 4):**
  - **Locate:** `**Parent Epic:** [{epic-slug} — leave blank for standalone features created via \`/p3-start-feature\` from scratch (no parent epic). Plain markdown; no parser.]`
  - **Replace:** `**Parent Epic:** [T{N} ({epic-slug}) — the parent epic's ticket ID + slug; leave blank for standalone features created via \`/p3-start-feature\` from scratch (no parent epic). Plain markdown; no parser.]`

**Verification:** `grep -Fc "**Ticket ID:** {ID}" templates/feature.template.md` → `1`; `grep -Fc "Parent Epic:** [T{N} ({epic-slug})" templates/feature.template.md` → `1`.

---

## Step 11: p2/p4 Step-7 collision globs — widen to both positions (fixes a validation finding)
**Operation:** EDIT
A New slug must not silently collide with an existing **ID-prefixed** folder of the same slug, so the collision glob must also check the slug-after-prefix position.
- **11a — p2 (`host/templates/claude/commands/p2-decompose-epic.md`, Step 7 line ~102):**
  - **Locate:** `glob \`features/{feature-slug}-*/\` and \`features/{feature-slug}/\`. If **any** candidate slug collides with an existing feature folder`
  - **Replace:** `glob \`features/{feature-slug}-*/\`, \`features/*-{feature-slug}-*/\` (ID-prefixed folders), and \`features/{feature-slug}/\`. If **any** candidate slug collides with an existing feature folder`
- **11b — p4 (`host/templates/claude/commands/p4-decompose-feature.md`, Step 7 line ~122):**
  - **Locate:** `glob \`stories/{story-slug}-*/\` and \`stories/{story-slug}/\`. If **any** candidate slug collides with an existing story folder`
  - **Replace:** `glob \`stories/{story-slug}-*/\`, \`stories/*-{story-slug}-*/\` (ID-prefixed folders), and \`stories/{story-slug}/\`. If **any** candidate slug collides with an existing story folder`

**Verification:** `grep -Fc 'features/*-{feature-slug}-*/' host/templates/claude/commands/p2-decompose-epic.md` → at least `1`; `grep -Fc 'stories/*-{story-slug}-*/' host/templates/claude/commands/p4-decompose-feature.md` → at least `1`.

---

## Step 12: folder-path cleanup — prefix ALL remaining literal folder references with `{ID}-` (fixes a validation finding)
**Operation:** EDIT (`replace_all`) — run **LAST** in each file (after that file's targeted edits above), so it only catches the *incidental* folder-path references the targeted steps did not touch (raw-payload paths, write paths, exit criteria, purpose lines, skill frontmatter). The replace fragment starts with `/{…slug}-{brief` so it does **not** match the glob forms (`/{…slug}-*/`) or the already-prefixed `/{ID}-{…slug}-{brief` produced by the targeted steps.

Apply the `replace_all` substitution(s) listed **per file** below. The fragment ends at `-{brief` so it uniformly covers `-{brief}`, `-{brief-description}`, and `-{brief-description-kebab}` variants. Each listed (file, fragment) pair is verified on disk to have **≥1 match after the targeted edits above** — so none is a no-op. The fragments differ per file because the p2/p4 skills carry only the `{feature-slug}`/`{story-slug}` folder form, not `{slug}`. Paths are under `host/templates/claude/`; each fragment maps to its `/{ID}-…` form (e.g. `/{slug}-{brief` → `/{ID}-{slug}-{brief`).

| File | `replace_all` fragment(s) |
|------|---------------------------|
| `commands/p1-start-epic.md` | `/{slug}-{brief` |
| `skills/p1-start-epic/SKILL.md` | `/{slug}-{brief` |
| `commands/p2-decompose-epic.md` | `/{slug}-{brief` **and** `/{feature-slug}-{brief` |
| `skills/p2-decompose-epic/SKILL.md` | `/{feature-slug}-{brief` (only) |
| `commands/p3-start-feature.md` | `/{slug}-{brief` |
| `skills/p3-start-feature/SKILL.md` | `/{slug}-{brief` |
| `commands/p4-decompose-feature.md` | `/{slug}-{brief` **and** `/{story-slug}-{brief` |
| `skills/p4-decompose-feature/SKILL.md` | `/{story-slug}-{brief` (only) |

If any single listed fragment unexpectedly has **zero** matches, halt and report — do not improvise.

**Verification (per file — no bare folder path survives, only `{ID}-`-prefixed ones):**
```
# apply to each of the 8 files above (path shown for p1 command):
grep -oE "(stories|epics|features)/\{(slug|feature-slug|story-slug)\}-\{brief[a-z-]*\}/" host/templates/claude/commands/p1-start-epic.md   # → empty (all now ID-prefixed)
```
Run that grep against every command + skill listed above; each must return **empty**. Globs (`/{slug}-*/`) and resolution patterns are unaffected.

---

## Phase 2 exit
- p1–p4 (commands + skills): allocate ticket IDs (single for p1/p3, per-child in the p2/p4 decompose Step 8), create `{ID}-{slug}-{brief}/` folders, resolve by ID-or-slug (both positions), and widen the Kept-partition + collision globs. The **`**Ticket ID:** T{N}` header line** is written into the **epic** (p1) and **feature** (p2 stub / p3) artifacts — its template carries the field (Steps 9, 10); **stories** carry only the `{ID}-` folder prefix + `T{N} (slug)` back-refs (p4 writes the `**Parent Feature:**`/`**Parent Epic:**` back-refs; the tracker-specific `ticket.{ado,github}.template.md` story templates are out of this proposal's scope, so no story header line).
- epic/feature templates carry the `**Ticket ID:** {ID}` header + the `T{N} (slug)` Parent-Epic back-ref.
- **No commit.** Phase 3 (e1 + e-commands) is the remaining phase.

---

## Notes
- **Stub-ID preservation:** p3 Mode A (5c, 5d) and p4/p2 Kept partitions reuse the existing folder + ID; only New children allocate. Validation must confirm the new-vs-stub branch never re-allocates a stub's ID.
- **Collision globs:** Step 1c widens p1's collision glob; **Step 11** explicitly widens the p2/p4 Step-7 global-slug-collision globs to both positions so a New slug doesn't silently collide with an ID-prefixed existing folder; the Kept-glob edits 3d/7e cover the re-decomposition path.
- Agent-instruction prose only; every normative rule (decomposition gate, Kept/New/Orphaned partitioning, rubric, validation hand-offs) is preserved — only naming/resolution/back-ref wording changes. No `.claude/`, no commit.

---
Validated 2026-06-09 — 4 rounds, 1 adversarial sub-agent confirmed
