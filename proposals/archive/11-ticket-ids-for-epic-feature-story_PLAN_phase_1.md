# Implementation Plan — Phase 1 — ticket-ids-for-epic-feature-story (#11)

**Created:** 2026-06-09
**Index:** `proposals/11-ticket-ids-for-epic-feature-story_PLAN.md`
**Proposal:** `proposals/11-ticket-ids-for-epic-feature-story.md` (Validated 2026-06-08)
**Cut in this phase:** proposal row 1 — the rules-file **contract** (resolver, allocator, naming, the new `# Ticket IDs` section).
**File edited:** `templates/SHAMT_RULES.template.md` only.

> **Deploy order:** Phase 1 runs first (it defines the contract Phases 2–3 implement). Re-confirm anchors against the live file; cited line numbers are pre-edit/approximate.

---

## Step 0: Create the proposal branch
**Operation:** BRANCH
**Details:**
- Run `git checkout -b proposal/11-ticket-ids-for-epic-feature-story` from `main`. If it exists, stop and report.
- Capture baseline size: `wc -m templates/SHAMT_RULES.template.md` (expect **35147**); record it.

**Verification:** `git branch --show-current` → `proposal/11-ticket-ids-for-epic-feature-story`.

---

## Step 1: Principle 1.2 — the ID-or-slug resolver (proposal row 1a)
**Operation:** EDIT
**File:** `templates/SHAMT_RULES.template.md`
**Details:**
- **Locate:** `2. **Every command takes a slug.** \`/command {slug}\` resolves to a folder via the standard rules (try exact match \`{root}/{slug}/\`, then glob \`{root}/{slug}-*/\`, halt if ambiguous, halt if none).`
- **Replace:** `2. **Every command takes a ticket ID or slug.** \`/command {id-or-slug}\` resolves to a folder: if the key is a ticket ID (matches \`^T[0-9]+$\`), glob \`{root}/{ID}-*/\`. Otherwise treat the key as a slug — try exact \`{root}/{slug}/\`, then glob **both** \`{root}/{slug}-*/\` (slug at the folder start — pre-ID folders) **and** \`{root}/*-{slug}-*/\` (slug after an ID prefix — \`{ID}-{slug}-{brief}/\` folders), unioning the matches. Halt if ambiguous (more than one folder); halt if none. See **# Ticket IDs**.`

**Verification:** `grep -Fc "Every command takes a ticket ID or slug" templates/SHAMT_RULES.template.md` → `1`; `grep -Fc "{root}/*-{slug}-*/" templates/SHAMT_RULES.template.md` → at least `1` (the both-positions glob present); `grep -Fc "Every command takes a slug" templates/SHAMT_RULES.template.md` → `0` (old phrasing replaced, not merely appended).

---

## Step 2: Core files — folder naming with the ID prefix (proposal row 1c, part 1)
**Operation:** EDIT
**File:** `templates/SHAMT_RULES.template.md`
**Details — two replacements:**
- **2a:**
  - **Locate:** `- \`stories/{slug}-{brief-description}/\` — per-story artifacts.`
  - **Replace:** `- \`stories/{ID}-{slug}-{brief-description}/\` — per-story artifacts (the \`{ID}-\` prefix is added to new tickets — see **# Ticket IDs**).`
- **2b:**
  - **Locate:** `- \`epics/{slug}-{brief}/\`, \`features/{slug}-{brief}/\` — PO-flow artifacts.`
  - **Replace:** `- \`epics/{ID}-{slug}-{brief}/\`, \`features/{ID}-{slug}-{brief}/\` — PO-flow artifacts.`

**Verification:** `grep -Fc "stories/{ID}-{slug}-{brief-description}/" templates/SHAMT_RULES.template.md` → at least `1`; `grep -Fc "epics/{ID}-{slug}-{brief}/" templates/SHAMT_RULES.template.md` → `1`.

---

## Step 3: Global Story Invariants — story-folder resolution (proposal row 1b)
**Operation:** EDIT
**File:** `templates/SHAMT_RULES.template.md`
**Details:**
- **Locate:** `- **Story folder resolution.** For \`{slug}\`, resolve the folder using file-based anchors. Try \`stories/{slug}/ticket.md\` first; if not found, glob \`stories/{slug}-*/ticket.md\` and derive the folder from the matched path. Multiple matches → halt and ask. No matches → halt and report.`
- **Replace:** `- **Story folder resolution.** For \`{id-or-slug}\`, resolve the folder using file-based anchors. If the key is a ticket ID (\`^T[0-9]+$\`), glob \`stories/{ID}-*/ticket.md\`. Otherwise (a slug) try \`stories/{slug}/ticket.md\`, then glob **both** \`stories/{slug}-*/ticket.md\` and \`stories/*-{slug}-*/ticket.md\`, deriving the folder from the matched path. Multiple matches → halt and ask. No matches → halt and report.`

**Verification:** `grep -Fc "For \`{id-or-slug}\`, resolve the folder" templates/SHAMT_RULES.template.md` → `1`; `grep -Fc "stories/*-{slug}-*/ticket.md" templates/SHAMT_RULES.template.md` → `1`; `grep -Fc "For \`{slug}\`, resolve the folder" templates/SHAMT_RULES.template.md` → `0` (old phrasing replaced, not merely appended).

---

## Step 4: Path-map Intake cells — folder naming (proposal row 1c, part 2)
**Operation:** EDIT (replace_all — the identical Intake cell appears in both the Quick and Standard path-map tables)
**File:** `templates/SHAMT_RULES.template.md`
**Details:**
- **Locate (both occurrences):** `| 1. Intake | \`stories/{slug}-{brief-description}/ticket.md\` | User confirms slug + content |`
- **Replace:** `| 1. Intake | \`stories/{ID}-{slug}-{brief-description}/ticket.md\` | User confirms slug + content |`
- Use a replace-all (both the Quick path map and the Standard path map carry this identical Intake row).

**Verification:** `grep -Fc "stories/{slug}-{brief-description}/ticket.md" templates/SHAMT_RULES.template.md` → `0` (both updated); `grep -Fc "stories/{ID}-{slug}-{brief-description}/ticket.md" templates/SHAMT_RULES.template.md` → `2`.

---

## Step 5: Insert the `# Ticket IDs` section (proposal row 1d)
**Operation:** EDIT (insert before the `# Story Artifact Naming` heading)
**File:** `templates/SHAMT_RULES.template.md`
**Details:**
- **Locate:** `# Story Artifact Naming`
- **Replace:** (the new section + separator, then the original heading)

````
# Ticket IDs

Every epic, feature, and story is a **ticket** with a short, globally-unique **ticket ID** of the form `T{N}` (`T1`, `T2`, …) used alongside its slug. The ID prefixes the folder — `epics/{ID}-{slug}-{brief}/`, `features/{ID}-{slug}-{brief}/`, `stories/{ID}-{slug}-{brief}/` — mirroring the `proposals/{NN}-{slug}.md` convention.

- **Allocation.** A new ticket's ID is `max(existing T-number across epics/, features/, AND stories/) + 1` — **scanned from disk** (parse a leading `^T([0-9]+)-` run on each folder name across all three roots), **no counter file**, never reused. The sequence is **global** (one space across all ticket types — an epic might be `T1`, its feature `T2`, a story `T3`) and **flat** (an ID does not encode its parent). A project with only slug-only folders allocates `T1` first.
- **Addressing.** Commands accept either the ID or the slug — see Principle 1.2's resolver (ID glob `{root}/{ID}-*/`; otherwise the both-positions slug glob `{root}/{slug}-*/` ∪ `{root}/*-{slug}-*/`).
- **New-tickets-only.** Existing slug-only folders are **not** renamed; they keep resolving via the slug glob. IDs accrue as new tickets are created.
- **Stub IDs are preserved.** `/p2-decompose-epic` and `/p4-decompose-feature` allocate each child's ID at stub time; `/p3-start-feature` (fleshing a feature stub) and `/e1-start-story` (fleshing a story stub) **preserve** that ID — they do not re-allocate.
- **Parent back-refs** use `T{N} (slug)` — the stable parent ID plus the slug for readability (e.g. `**Parent Epic:** T1 (auth-overhaul)`).

---

# Story Artifact Naming
````

**Verification:** `grep -Fc "^# Ticket IDs" templates/SHAMT_RULES.template.md` → `1`; `grep -Fc "^# Story Artifact Naming" templates/SHAMT_RULES.template.md` → `1` (still present, now after the new section); `grep -Fc "max(existing T-number across" templates/SHAMT_RULES.template.md` → `1`.

---

## Step 6: D12 budget re-measure (the contract grew)
**Operation:** VERIFY (no edit)
**Details:**
- Run `wc -m templates/SHAMT_RULES.template.md`. The `# Ticket IDs` section + resolver edits add ~+1.5k chars to the 35,147 baseline → expect ~**36,600**.
- **PASS condition:** ≤ **40,000** (the D12 budget — clears D12). If > 40,000, halt and report (the section is larger than estimated; trim or escalate).

**Verification:** `s=$(wc -m < templates/SHAMT_RULES.template.md); [ "$s" -le 40000 ] && echo "PASS $s"`.

---

## Phase 1 exit
- The rules-file contract is in place: Principle 1.2 + Global Story Invariants resolve ID-or-slug (both slug positions); Core files + path-map Intake cells carry `{ID}-{slug}-{brief}/`; the `# Ticket IDs` section defines allocation (global, disk-scanned, 3 roots), addressing, new-tickets-only, stub-ID preservation, and the `T{N} (slug)` back-ref.
- `wc -m` ≤ 40,000 (D12 still cleared).
- **No commit.** Next: Phase 2 (PO commands p1–p4 + templates) — implements this contract.

---

## Notes
- **No rule removed.** Every edit rewords the resolver/naming or ADDS the Ticket-IDs section; no existing normative rule in Principle 1, Global Story Invariants, or Story Artifact Naming is dropped (validation diffs the touched lines).
- Only `templates/SHAMT_RULES.template.md` is edited; it is **not** regenerated (renders into a child at install/`sync-import`). No `.claude/`, no commit.

---
Validated 2026-06-09 — 2 rounds, 1 adversarial sub-agent confirmed
