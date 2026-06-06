# Implementation Plan — #04 §-citation purge — Phase 3: framework-update / audit

## Files Touched

| Operation | File |
|-----------|------|
| EDIT | `host/templates/claude/commands/f5-audit-framework.md` |
| EDIT | `host/templates/claude/commands/f6-archive-proposal.md` |
| EDIT | `host/templates/claude/skills/f6-archive-proposal/SKILL.md` |

## Implementation Steps

### Step 1

**Operation:** EDIT

**File:** `host/templates/claude/commands/f5-audit-framework.md`

**Details:**

- **§3.6 / §3.9** — the audit no-log-artifact rule is stated inline ("the conversation is the audit record"); the dangling `(§3.6 / §3.9)` is deleted.
  - **Locate:** `the conversation is the audit record (§3.6 / §3.9).`
  - **Replace:** `the conversation is the audit record.`

**Verification:** `grep -cE "§[0-9]+\.[0-9]+" host/templates/claude/commands/f5-audit-framework.md` → `0`

### Step 2

**Operation:** EDIT

**File:** `host/templates/claude/commands/f6-archive-proposal.md`

**Details:**

- **§3.4** — `proposals/_template.md` is already named in the same parenthetical; drop ` and §3.4`, keeping the named reference.
  - **Locate:** `(see `proposals/_template.md` and §3.4)`
  - **Replace:** `(see `proposals/_template.md`)`

**Verification:** `grep -cE "§[0-9]+\.[0-9]+" host/templates/claude/commands/f6-archive-proposal.md` → `0`

### Step 3

**Operation:** EDIT

**File:** `host/templates/claude/skills/f6-archive-proposal/SKILL.md`

**Details:**

- **§3.4** — the `proposals/_template.md` link already co-exists in the sentence ("these folders are documented in [`proposals/_template.md`](…) and `§3.4`."); drop ` and `§3.4``, keeping the named link and a clean sentence end.
  - **Locate:** `[`proposals/_template.md`](../../../../../proposals/_template.md) and `§3.4`.`
  - **Replace:** `[`proposals/_template.md`](../../../../../proposals/_template.md).`

**Verification:** `grep -cE "§[0-9]+\.[0-9]+" host/templates/claude/skills/f6-archive-proposal/SKILL.md` → `0`

## Phase-3 final verification

```sh
grep -cE "§[0-9]+\.[0-9]+" \
  host/templates/claude/commands/f5-audit-framework.md \
  host/templates/claude/commands/f6-archive-proposal.md \
  host/templates/claude/skills/f6-archive-proposal/SKILL.md
```

Each file returns `0` — no `§N.N` citation remains across the three Phase-3 files.

---
Validated 2026-06-06 — 1 round, 1 adversarial sub-agent confirmed (batch validation; validation-checker independently verified all locate strings exact + unique against HEAD, replacements clean, and per-file §-coverage → 0)
