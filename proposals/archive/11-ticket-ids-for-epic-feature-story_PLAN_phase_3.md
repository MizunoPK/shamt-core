# Implementation Plan — Phase 3 — ticket-ids-for-epic-feature-story (#11)

**Created:** 2026-06-09
**Index:** `proposals/11-ticket-ids-for-epic-feature-story_PLAN.md`
**Proposal:** `proposals/11-ticket-ids-for-epic-feature-story.md` (Validated 2026-06-08)
**Cuts in this phase:** proposal rows 10, 11 (e1 command + skill — story ID allocation, stub-ID preservation, resolver) and rows 14–21 (the 8 e-command resolution-restatement updates).
**File(s) edited:** `host/templates/claude/commands/e1-start-story.md` + its skill; `host/templates/claude/commands/{e2,e3,e3b,e4,e5,e5b,e6,e7}*.md`.

> **Deploy order:** runs after Phase 1 (the contract) and Phase 2 (PO commands). All edits implement Phase 1's resolver/allocator/naming. Re-confirm anchors against the live files.

---

## Step 1: e1-start-story command — ID allocation, stub-ID preservation, resolver (proposal row 10)
**Operation:** EDIT
**File:** `host/templates/claude/commands/e1-start-story.md`
**Details — six sub-edits:**

- **1a — argument label (line 21):**
  - **Locate:** `- \`{slug}\` (required) — story slug. Form depends on the active tracker profile:`
  - **Replace:** `- \`{id-or-slug}\` (required) — when resolving an existing story, its ticket ID (\`T{N}\`) or slug; when creating a new freeform story, the slug. Form depends on the active tracker profile:`

- **1b — resolution sub-list (lines 43–44):**
  - **Locate:** `1. Try \`stories/{slug}/ticket.md\` (exact match).
2. If not found, glob \`stories/{slug}-*/ticket.md\`.`
  - **Replace:** `1. If \`{id-or-slug}\` is a ticket ID (\`^T[0-9]+$\`), glob \`stories/{ID}-*/ticket.md\`; otherwise try \`stories/{slug}/ticket.md\` (exact match).
2. If still not found (a slug), glob **both** \`stories/{slug}-*/ticket.md\` and \`stories/*-{slug}-*/ticket.md\`.`

- **1c — Step 3 folder proposal + ID allocation (line 56):**
  - **Locate:** `2. Propose \`stories/{slug}-{brief-description-kebab}/\` and ask the user to confirm before creating directories. Use lowercase, hyphen-separated.`
  - **Replace:** `2. **For a new (non-stub) story, allocate a ticket ID** \`T{N}\` (= \`max\` of the \`^T([0-9]+)-\` prefixes across \`epics/\`, \`features/\`, and \`stories/\`, + 1 — per **# Ticket IDs**) and propose \`stories/{ID}-{slug}-{brief-description-kebab}/\`. **Stub-aware:** if Step 2 marked the invocation stub-aware, the folder already exists with its ID — reuse it; do **not** allocate or re-propose. Ask the user to confirm before creating directories. Use lowercase, hyphen-separated.`

- **1d — slug-collision glob (line 100):**
  - **Locate:** `1. Glob \`stories/{slug}-*/\` (and the exact \`stories/{slug}/\`) and confirm only one folder exists for this slug.`
  - **Replace:** `1. Glob \`stories/{ID}-*/\` (for a ticket ID) or, for a slug, **both** \`stories/{slug}-*/\` and \`stories/*-{slug}-*/\` (and the exact \`stories/{slug}/\`), and confirm only one folder exists for this ticket.`

- **1e — folder summary (line 107):**
  - **Locate:** `- Folder: \`stories/{slug}-{brief}/\``
  - **Replace:** `- Folder: \`stories/{ID}-{slug}-{brief}/\``

- **1f — back-ref format in the stub-aware descriptions (replace_all — appears in lines 79, 94, 127):**
  - **Locate:** `\`**Parent Feature:** {feature-slug}\``
  - **Replace:** `\`**Parent Feature:** T{N} (feature-slug)\``
  - And (replace_all): **Locate** `\`**Parent Epic:** {parent-epic-slug}\`` → **Replace** `\`**Parent Epic:** T{N} (parent-epic-slug)\``

- **1g — folder-path cleanup (replace_all — run LAST, after 1a–1f):** e1 carries several *incidental* literal story-folder references beyond the ones edited above (raw-payload paths, the `ticket.md` write path, exit criteria, the purpose line). Prefix them all with `{ID}-`:
  - **`replace_all`:** `/{slug}-{brief` → `/{ID}-{slug}-{brief`
  - The fragment starts at `/{slug}-{brief`, so it covers `-{brief}` and `-{brief-description-kebab}` uniformly while **not** matching the glob forms (`/{slug}-*/`) or the already-prefixed `/{ID}-{slug}-{brief` produced by 1c/1e.

**Verification:** `grep -oE "stories/\{slug\}-\{brief[a-z-]*\}/" host/templates/claude/commands/e1-start-story.md` → **empty** (no bare folder path survives — all `{ID}-`-prefixed); `grep -Fc "{id-or-slug}" host/templates/claude/commands/e1-start-story.md` → at least `1`; `grep -Fc "stories/{ID}-{slug}-{brief}/" host/templates/claude/commands/e1-start-story.md` → at least `1`; `grep -Fc "do **not** allocate or re-propose" host/templates/claude/commands/e1-start-story.md` → `1` (stub-ID preservation); `grep -Fc "Parent Feature:** {feature-slug}" host/templates/claude/commands/e1-start-story.md` → `0` (old back-ref format gone).

---

## Step 2: e1-start-story skill — mirror (proposal row 11)
**Operation:** EDIT
**File:** `host/templates/claude/skills/e1-start-story/SKILL.md`
**Details — three sub-edits:**
- **2a (line 30):**
  - **Locate:** `2. Resolve \`{slug}\` to \`stories/{slug}/\` (exact) or \`stories/{slug}-*/\` (glob). Halt on multiple matches.`
  - **Replace:** `2. Resolve \`{id-or-slug}\`: a ticket ID globs \`stories/{ID}-*/\`; a slug tries \`stories/{slug}/\` (exact) then **both** \`stories/{slug}-*/\` and \`stories/*-{slug}-*/\` (glob). Halt on multiple matches.`
- **2b (line 31):**
  - **Locate:** `3. For new stories: ask the user for a 2–4-word brief description; propose and create \`stories/{slug}-{brief}/\`.`
  - **Replace:** `3. For new stories: allocate a ticket ID \`T{N}\` (max across \`epics/\`, \`features/\`, \`stories/\` + 1), ask for a 2–4-word brief description, and create \`stories/{ID}-{slug}-{brief}/\`; a PO-flow stub already has its ID — preserve it.`
- **2c (line 45):**
  - **Locate:** `Non-empty \`stories/{slug}-{brief}/ticket.md\` exists and the user has confirmed the slug + content.`
  - **Replace:** `Non-empty \`stories/{ID}-{slug}-{brief}/ticket.md\` exists and the user has confirmed the slug + content.`

**Verification:** `grep -Fc "stories/{ID}-{slug}-{brief}/" host/templates/claude/skills/e1-start-story/SKILL.md` → at least `1`; `grep -Fc "preserve it" host/templates/claude/skills/e1-start-story/SKILL.md` → `1`.

---

## Steps 3–10: the 8 e-command resolution-restatement updates (proposal rows 14–21)

Each command's Arguments/Notes section inline-restates the slug glob; update it to the two-key (ID-or-slug) form, deferring the glob detail to the central Global Story Invariants. One sub-edit per command.

### Step 3 — e2-define-spec (row 14)
- **Locate:** `- Story folder resolves (via \`stories/{slug}/\` exact match or \`stories/{slug}-*/\` glob; halt on multiple or zero matches per the Global Story Invariants in [\`SHAMT_RULES.template.md\`](../../../../templates/SHAMT_RULES.template.md)).`
- **Replace:** `- Story folder resolves by ticket ID or slug (ID glob \`stories/{ID}-*/\`, else the both-positions slug glob \`stories/{slug}-*/\` ∪ \`stories/*-{slug}-*/\`; halt on multiple or zero matches) per the Global Story Invariants in [\`SHAMT_RULES.template.md\`](../../../../templates/SHAMT_RULES.template.md).`

### Step 4 — e3-plan-implementation (row 15)
- **Locate:** `- \`{slug}\` (required) — story slug. Resolved via the global story-folder rules (exact \`stories/{slug}/\`, then \`stories/{slug}-*/\` glob; halt on multiple or zero matches).`
- **Replace:** `- \`{id-or-slug}\` (required) — story ticket ID (\`T{N}\`) or slug. Resolved via the global story-folder rules (ID glob \`stories/{ID}-*/\`, else the both-positions slug glob; halt on multiple or zero matches).`

### Step 5 — e3b-write-testing-plan (row 16)
- **Locate:** `- \`{slug}\` (required) — story slug. Resolved via the global story-folder rules (exact \`stories/{slug}/\`, then \`stories/{slug}-*/\` glob; halt on multiple or zero matches).`
- **Replace:** `- \`{id-or-slug}\` (required) — story ticket ID (\`T{N}\`) or slug. Resolved via the global story-folder rules (ID glob \`stories/{ID}-*/\`, else the both-positions slug glob; halt on multiple or zero matches).`

### Step 6 — e4-execute-plan (row 17)
- **Locate:** `- \`{slug}\` (required) — story slug. Resolved via the global story-folder rules (exact \`stories/{slug}/\`, then \`stories/{slug}-*/\` glob; halt on multiple or zero matches per the Global Story Invariants in [\`SHAMT_RULES.template.md\`](../../../../templates/SHAMT_RULES.template.md#global-story-invariants)).`
- **Replace:** `- \`{id-or-slug}\` (required) — story ticket ID (\`T{N}\`) or slug. Resolved via the global story-folder rules (ID glob \`stories/{ID}-*/\`, else the both-positions slug glob; halt on multiple or zero matches per the Global Story Invariants in [\`SHAMT_RULES.template.md\`](../../../../templates/SHAMT_RULES.template.md#global-story-invariants)).`

### Step 7 — e5-execute-tests (row 18)
- **Locate:** `- \`{slug}\` (required) — story slug. Resolved via the global story-folder rules (exact \`stories/{slug}/\`, then \`stories/{slug}-*/\` glob; halt on multiple or zero matches).`
- **Replace:** `- \`{id-or-slug}\` (required) — story ticket ID (\`T{N}\`) or slug. Resolved via the global story-folder rules (ID glob \`stories/{ID}-*/\`, else the both-positions slug glob; halt on multiple or zero matches).`

### Step 8 — e5b-write-manual-testing-plan (row 19)
- **Locate:** `- \`{slug}\` (required) — story slug. Resolved via the global story-folder rules (exact \`stories/{slug}/\`, then \`stories/{slug}-*/\` glob; halt on multiple or zero matches per the Global Story Invariants in [\`SHAMT_RULES.template.md\`](../../../../templates/SHAMT_RULES.template.md#global-story-invariants)).`
- **Replace:** `- \`{id-or-slug}\` (required) — story ticket ID (\`T{N}\`) or slug. Resolved via the global story-folder rules (ID glob \`stories/{ID}-*/\`, else the both-positions slug glob; halt on multiple or zero matches per the Global Story Invariants in [\`SHAMT_RULES.template.md\`](../../../../templates/SHAMT_RULES.template.md#global-story-invariants)).`

### Step 9 — e6-review-changes (row 20)
- **Locate:** `- \`{slug}\` (story mode) — story slug. Resolved via the global story-folder rules (exact \`stories/{slug}/\`, then \`stories/{slug}-*/\` glob; halt on multiple or zero matches).`
- **Replace:** `- \`{id-or-slug}\` (story mode) — story ticket ID (\`T{N}\`) or slug. Resolved via the global story-folder rules (ID glob \`stories/{ID}-*/\`, else the both-positions slug glob; halt on multiple or zero matches).`

### Step 10 — e7-resolve-feedback (row 21)
- **Locate:** `- \`{slug}\` (required) — story slug. Resolved via the global story-folder rules (exact \`stories/{slug}/\`, then \`stories/{slug}-*/\` glob; halt on multiple or zero matches).`
- **Replace:** `- \`{id-or-slug}\` (required) — story ticket ID (\`T{N}\`) or slug. Resolved via the global story-folder rules (ID glob \`stories/{ID}-*/\`, else the both-positions slug glob; halt on multiple or zero matches).`

**Verification (all 8):**
```
# no stale "stories/{slug}/, then stories/{slug}-*/ glob" remains in the 8 e-commands:
grep -lE "exact .stories/\{slug\}., then .stories/\{slug\}-\*. glob" host/templates/claude/commands/e[2-7]*.md   # → empty (e[2-7]* covers e2,e3,e3b,e4,e5,e5b,e6,e7 — all 8)
# each now references the ID-or-slug resolver:
for c in e2-define-spec e3-plan-implementation e3b-write-testing-plan e4-execute-plan e5-execute-tests e5b-write-manual-testing-plan e6-review-changes e7-resolve-feedback; do
  grep -c "ID glob .stories/{ID}-\*/.\|resolves by ticket ID or slug" "host/templates/claude/commands/$c.md"   # → ≥1 each
done
```

---

## Phase 3 exit
- e1 (command + skill): allocates a ticket ID for a new story, preserves a PO-stub's ID, resolves by ID-or-slug, uses `{ID}-{slug}-{brief}/` folders + the `T{N} (slug)` back-ref format.
- The 8 e-commands resolve by ID-or-slug (the stale inline slug-glob restatements updated).
- **No commit.** All of #11's 21 rows are now implemented across Phases 1–3.

---

## Notes
- The e-command **skills** were verified not to inline-restate resolution (they reference the command body), so they need no edit — only the 8 e-command bodies + e1's command & skill do.
- Edits are agent-instruction prose only; every normative rule (the stub-aware merge, the Intake gate, the per-command protocol) is preserved — only the resolution/naming/back-ref wording changes.
- Only `host/templates/claude/` files are edited → `/f4-regen-framework` propagates them. No `.claude/`, no commit.

---
Validated 2026-06-09 — 2 rounds, 1 adversarial sub-agent confirmed
