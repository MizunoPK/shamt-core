# Implementation Plan — #04 §-citation purge — Phase 4: sync

Scope: the 5 master/child sync canonical files (host commands + skills). Each `§N.N` token in
these files cites a facet of the deleted INFRASTRUCTURE.md Part 4 (master/child sync). Per the
proposal's §-token resolution table and per-site policy, every occurrence is resolved against its
own sentence — re-point to the named v2 sync rule, or delete the dangling `§` where a named
reference / inline statement already co-exists (and rephrase, not bare-delete, the §4.7 site).

All edits are to **canonical** sources only — never `.claude/`. Host bodies regenerate via
`/f4-regen-framework` (Phase 5); the corrected bodies land in children on next `/sync-import-shamt`.

## Files Touched

| Operation | File |
|-----------|------|
| EDIT | `host/templates/claude/commands/sync-import-shamt.md` (§4.7, §4.13) |
| EDIT | `host/templates/claude/commands/sync-submit-proposal.md` (§4.3, §4.4, §4.13) |
| EDIT | `host/templates/claude/skills/sync-import-shamt/SKILL.md` (§4.3) |
| EDIT | `host/templates/claude/skills/sync-submit-proposal/SKILL.md` (§4.4, §4.8) |
| EDIT | `host/templates/claude/skills/sync-triage-proposals/SKILL.md` (§4.4, §4.8) |

## Implementation Steps

### Step 1

**Operation:** EDIT
**File:** `host/templates/claude/commands/sync-import-shamt.md`
**Details:**

- **§4.13 (line 112 — always-latest / no-version-pinning import policy).** The rule is stated
  inline ("Always-latest. No version pinning…"), so drop the leading `Per §4.13, ` and capitalize.
  - **Locate:** `Per §4.13, this is intentional`
  - **Replace:** `This is intentional`

- **§4.7 (line 116 — original per-file footer-check wording).** Not a clean delete — deleting the
  bare `§4.7` leaves broken prose. Rephrase to name the per-file footer check inline.
  - **Locate:** `a tighter rule than the literal §4.7 wording proposed (per-file footer check)`
  - **Replace:** `a tighter rule than the per-file footer check originally proposed`

**Verification:** `grep -cE "§[0-9]+\.[0-9]+" host/templates/claude/commands/sync-import-shamt.md` → `0`

### Step 2

**Operation:** EDIT
**File:** `host/templates/claude/commands/sync-submit-proposal.md`
**Details:**

- **§4.3 / §4.4 (line 28 — `project_name` namespacing convention).** The namespacing rule is stated
  inline at the site; drop the trailing ` per §4.3 / §4.4`.
  - **Locate:** `namespaces upstream submissions per §4.3 / §4.4`
  - **Replace:** `namespaces upstream submissions`

- **§4.13 (line 44 — child-submission attribution).** Attribution rule (`Proposed by` /
  `Project context`) is stated inline; drop the leading `Per §4.13, ` and capitalize.
  - **Locate:** `Per §4.13, child-submitted proposals fill these in`
  - **Replace:** `Child-submitted proposals fill these in`

- **§4.3 (line 108 — manual-copy sync design).** Manual-copy design is stated inline; drop the
  leading `Per §4.3 ` and capitalize.
  - **Locate:** `Per §4.3 the user copies`
  - **Replace:** `The user copies`

**Verification:** `grep -cE "§[0-9]+\.[0-9]+" host/templates/claude/commands/sync-submit-proposal.md` → `0`

### Step 3

**Operation:** EDIT
**File:** `host/templates/claude/skills/sync-import-shamt/SKILL.md`
**Details:**

- **§4.3 (line 52 — manual-copy sync design).** Re-point the dangling `§4.3` to the named v2 home
  so the cross-reference survives.
  - **Locate:** `manual copy per §4.3`
  - **Replace:** `manual copy per the manual-copy sync design`

**Verification:** `grep -cE "§[0-9]+\.[0-9]+" host/templates/claude/skills/sync-import-shamt/SKILL.md` → `0`

### Step 4

**Operation:** EDIT
**File:** `host/templates/claude/skills/sync-submit-proposal/SKILL.md`
**Details:**

- **§4.4 / §4.8 (line 32 — master-vs-child detection).** The detection rule (`proposals/incoming/`
  presence) is stated inline; drop the ` per §4.4 / §4.8`.
  - **Locate:** `master has it per §4.4 / §4.8; child never does`
  - **Replace:** `master has it; child never does`

**Verification:** `grep -cE "§[0-9]+\.[0-9]+" host/templates/claude/skills/sync-submit-proposal/SKILL.md` → `0`

### Step 5

**Operation:** EDIT
**File:** `host/templates/claude/skills/sync-triage-proposals/SKILL.md`
**Details:**

- **§4.4 / §4.8 (line 32 — master-vs-child detection).** The detection rule (`proposals/incoming/`
  presence) is stated inline in the same sentence; drop the ` per §4.4 / §4.8`.
  - **Locate:** `That folder is master's per §4.4 / §4.8; child projects never have it`
  - **Replace:** `That folder is master's; child projects never have it`

**Verification:** `grep -cE "§[0-9]+\.[0-9]+" host/templates/claude/skills/sync-triage-proposals/SKILL.md` → `0`

## Phase-4 final verification

Confirm no `§N.N` citation remains across all 5 sync files (total must be `0`):

```bash
grep -cE "§[0-9]+\.[0-9]+" \
  host/templates/claude/commands/sync-import-shamt.md \
  host/templates/claude/commands/sync-submit-proposal.md \
  host/templates/claude/skills/sync-import-shamt/SKILL.md \
  host/templates/claude/skills/sync-submit-proposal/SKILL.md \
  host/templates/claude/skills/sync-triage-proposals/SKILL.md
```

Every listed file must report `:0`.

---
Validated 2026-06-06 — 1 round, 1 adversarial sub-agent confirmed (batch validation; validation-checker independently verified all locate strings exact + unique against HEAD, replacements clean, and per-file §-coverage → 0)
