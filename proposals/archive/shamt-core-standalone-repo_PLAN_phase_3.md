# Implementation Plan — Phase 3: CHEATSHEET, references, templates, Engineer + sync commands

**Proposal:** proposals/shamt-core-standalone-repo.md
**Index:** proposals/shamt-core-standalone-repo_PLAN.md
**Created:** 2026-06-01
**Covers:** Proposed Changes rows 4, 5, 6, 7, 8, 9, 10, 15, 16, 17, 18, 19
**Character:** 24 `INFRASTRUCTURE.md` citation removals + 1 carve-out-bullet deletion. Mix of case (a) inline-drops, case (b) standalone-line deletions, and case (c) inlines.

No cross-step ordering constraint. Each sub-edit's locate string is unique within its file.

---

## Step 1 — Sweep `CHEATSHEET.md` (row 4 — 6 sub-edits across 7 lines, removing 9 `INFRASTRUCTURE.md` links)

**Operation:** EDIT
**File:** `CHEATSHEET.md`

> **Count note:** `grep -c "INFRASTRUCTURE" CHEATSHEET.md` = 7 lines (47, 62, 64, 108, 146, 163, 266) — that line count is the completeness-gate metric. The 6 sub-edits below remove 9 distinct `INFRASTRUCTURE.md` hyperlinks (1a §4.8; 1b §4.11 + Part 4; 1c §1.11; 1d §2.1; 1e §2.1 + §2.2 + §2.3; 1f §1.6). **Divergence from the proposal:** row 4's enumeration lists 8 citations and omits §1.6 (CHEATSHEET line 266); this phase removes ALL `INFRASTRUCTURE.md` citations including §1.6 (sub-edit 1f) so the `grep -c "INFRASTRUCTURE" CHEATSHEET.md` → 0 gate is satisfied.

### 1a — line 47 (case (a))
**Locate:**
```
`incoming/` (child-submitted proposals awaiting triage per [§4.8](../INFRASTRUCTURE.md#48-new-artifactsfolders-on-master)), `archive/` (implemented proposals)
```
**Replace:**
```
`incoming/` (child-submitted proposals awaiting triage), `archive/` (implemented proposals)
```

### 1b — lines 62 + 64 (case (a) inline-drop on 62 **and** case (b) standalone-line deletion on 64 — combined)
**Locate:**
```
No bidirectional guide-editing sync. No `export.sh`. The child's project work (stories, epics, features, code reviews) never syncs to master and isn't carried by Shamt at all — it lives in the child's own git repo per [INFRASTRUCTURE.md §4.11](../INFRASTRUCTURE.md#411-cross-machine-sync-for-project-work).

See [INFRASTRUCTURE.md Part 4](../INFRASTRUCTURE.md#part-4-masterchild-sync) for the full design.
```
**Replace:**
```
No bidirectional guide-editing sync. No `export.sh`. The child's project work (stories, epics, features, code reviews) never syncs to master and isn't carried by Shamt at all — it lives in the child's own git repo.
```

### 1c — line 108 (case (a))
**Locate:**
```
Each one mirrors `/e1-start-story`'s tracker plumbing per [INFRASTRUCTURE.md §1.11](../INFRASTRUCTURE.md#111-issue-tracker-integration-ado--github-cli): when the active profile
```
**Replace:**
```
Each one mirrors `/e1-start-story`'s tracker plumbing: when the active profile
```

### 1d — line 146 (case (a)/(c) — the rubric lives in the command body, which remains)
**Locate:**
```
See [INFRASTRUCTURE.md §2.1](../INFRASTRUCTURE.md#21-what-epicfeature-work-actually-needs) for the full rubric, the `/p4-decompose-feature` command body for inline enforcement details.
```
**Replace:**
```
See the `/p4-decompose-feature` command body for the full rubric and inline enforcement details.
```

### 1e — line 163 (case (b) — standalone pointer line deletion)
**Locate:**
```
"Active" at every altitude resolves the same way: `{altitude}/.active` (single-line override pinning a folder) if present, else most-recently-modified subdirectory. See the [Status-line registration](#status-line-registration) table below for the full layout.

See [INFRASTRUCTURE.md §2.1](../INFRASTRUCTURE.md#21-what-epicfeature-work-actually-needs), [§2.2](../INFRASTRUCTURE.md#22-slash-commands), and [§2.3](../INFRASTRUCTURE.md#23-open-meta-questions-specific-to-this-layer) for the full PO-flow design context.
```
**Replace:**
```
"Active" at every altitude resolves the same way: `{altitude}/.active` (single-line override pinning a folder) if present, else most-recently-modified subdirectory. See the [Status-line registration](#status-line-registration) table below for the full layout.
```

### 1f — line 266 (case (a))
**Locate:**
```
Bash-first per [INFRASTRUCTURE.md §1.6](../INFRASTRUCTURE.md#16-scripts-regen--framework-maintenance); a PowerShell wrapper may follow later.
```
**Replace:**
```
Bash-first; a PowerShell wrapper may follow later.
```

**Verification:** `grep -c "INFRASTRUCTURE" CHEATSHEET.md` returns `0`.

---

## Step 2 — Remove the audit carve-out bullet (row 5)

**Operation:** EDIT
**File:** `reference/audit_dimensions.md`

The "INFRASTRUCTURE.md is out of the audit surface" carve-out is now moot — the repo-root planning log no longer exists. Remove the whole bullet (not just the link), per the proposal. Anchor the locate on the preceding bullet so only the target bullet is removed.

**Locate:**
```
- **Phase count varies with the testing flag.** 6 phases when `testing: "disabled"`, 7 when `"enabled"`. D10 treats both as correct — a body must match the count *for the configuration it describes*, not a single fixed number.
- **INFRASTRUCTURE.md is out of the audit surface.** The audit sweeps `shamt-core/` canonical sources. The repo-root `../INFRASTRUCTURE.md` planning log (with its `Resolved:` / `(was X)` history) is not a regenerated canonical source and is not swept — its historical notes are not D11 findings.
```
**Replace:**
```
- **Phase count varies with the testing flag.** 6 phases when `testing: "disabled"`, 7 when `"enabled"`. D10 treats both as correct — a body must match the count *for the configuration it describes*, not a single fixed number.
```

**Verification:** `grep -c "INFRASTRUCTURE" reference/audit_dimensions.md` returns `0`; `grep -c "out of the audit surface" reference/audit_dimensions.md` returns `0`.

---

## Step 3 — Sweep `reference/trackers/_contract.md` (row 6 — 2 citations)

**Operation:** EDIT
**File:** `reference/trackers/_contract.md`

### 3a — line 7 (case (b) — standalone pointer line deletion)
**Locate:**
```
Future trackers (Jira, Linear, etc.) are added by writing a new file that conforms to this contract — no framework change required.

For background and rationale, see [INFRASTRUCTURE.md §1.11](../../../INFRASTRUCTURE.md#111-issue-tracker-integration-ado--github-cli).
```
**Replace:**
```
Future trackers (Jira, Linear, etc.) are added by writing a new file that conforms to this contract — no framework change required.
```

### 3b — line 21 (case (a) — the unified-section list is enumerated inline right after)
**Locate:**
```
A table mapping the tracker's raw field names to the unified output sections defined in [INFRASTRUCTURE.md §1.11 "What gets unified"](../../../INFRASTRUCTURE.md#what-gets-unified-in-the-ticket-template). At minimum: Title, Type, State, Assignee, Project, Iteration/Milestone, Description, Acceptance Criteria, URL.
```
**Replace:**
```
A table mapping the tracker's raw field names to the unified output sections. At minimum: Title, Type, State, Assignee, Project, Iteration/Milestone, Description, Acceptance Criteria, URL.
```

**Verification:** `grep -c "INFRASTRUCTURE" reference/trackers/_contract.md` returns `0`.

---

## Step 4 — Sweep `reference/trackers/ado.md` (row 7 — 1 citation, case (c) inline)

**Operation:** EDIT
**File:** `reference/trackers/ado.md`

The dead link headed the "unified target sections" reference. Inline the section list (which now lives in `_contract.md`'s own `## Field mapping` row) as prose — name `_contract.md`, do not add a markdown link to it.

**Locate:**
```
Unified target sections follow [INFRASTRUCTURE.md §1.11 "What gets unified"](../../../INFRASTRUCTURE.md#what-gets-unified-in-the-ticket-template). The same mapping will populate the corresponding sections of `epic.md` / `feature.md` once `/p1-start-epic` / `/p3-start-feature` land — the cross-altitude notes below describe that future reuse, but those commands and their artifact templates are not yet shipped.
```
**Replace:**
```
Unified target sections follow the field-mapping contract (Title, Type, State, Assignee, Project, Iteration/Milestone, Description, Acceptance Criteria, URL — defined in `_contract.md`). The same mapping will populate the corresponding sections of `epic.md` / `feature.md` once `/p1-start-epic` / `/p3-start-feature` land — the cross-altitude notes below describe that future reuse, but those commands and their artifact templates are not yet shipped.
```

**Verification:** `grep -c "INFRASTRUCTURE" reference/trackers/ado.md` returns `0`.

---

## Step 5 — Sweep `reference/trackers/github.md` (row 8 — 1 citation, case (c) inline)

**Operation:** EDIT
**File:** `reference/trackers/github.md`

**Locate:**
```
Unified target sections follow [INFRASTRUCTURE.md §1.11 "What gets unified"](../../../INFRASTRUCTURE.md#what-gets-unified-in-the-ticket-template). The mapping populates the `ticket.md` sections that [`templates/ticket.github.template.md`](../../templates/ticket.github.template.md) defines. (Forward-looking: when `/p1-start-epic` / `/p3-start-feature` land, the same mapping would feed `epic.md` / `feature.md` for profiles that support those types — which on GitHub does not apply, since both fall through to freeform per the rule below.)
```
**Replace:**
```
Unified target sections follow the field-mapping contract (Title, Type, State, Assignee, Project, Iteration/Milestone, Description, Acceptance Criteria, URL — defined in `_contract.md`). The mapping populates the `ticket.md` sections that [`templates/ticket.github.template.md`](../../templates/ticket.github.template.md) defines. (Forward-looking: when `/p1-start-epic` / `/p3-start-feature` land, the same mapping would feed `epic.md` / `feature.md` for profiles that support those types — which on GitHub does not apply, since both fall through to freeform per the rule below.)
```

**Verification:** `grep -c "INFRASTRUCTURE" reference/trackers/github.md` returns `0`.

---

## Step 6 — Sweep `templates/epic.template.md` (row 9 — 1 citation)

**Operation:** EDIT
**File:** `templates/epic.template.md`

**Locate:**
```
<!-- Epic artifact. Lives at epics/{slug}-{brief}/epic.md (flat layout; globally unique slug per INFRASTRUCTURE.md §2.1). -->
```
**Replace:**
```
<!-- Epic artifact. Lives at epics/{slug}-{brief}/epic.md (flat layout; globally unique slug). -->
```

**Verification:** `grep -c "INFRASTRUCTURE" templates/epic.template.md` returns `0`.

---

## Step 7 — Sweep `templates/feature.template.md` (row 10 — 1 citation)

**Operation:** EDIT
**File:** `templates/feature.template.md`

**Locate:**
```
<!-- Feature artifact. Lives at features/{slug}-{brief}/feature.md (flat layout; globally unique slug per INFRASTRUCTURE.md §2.1). -->
```
**Replace:**
```
<!-- Feature artifact. Lives at features/{slug}-{brief}/feature.md (flat layout; globally unique slug). -->
```

**Verification:** `grep -c "INFRASTRUCTURE" templates/feature.template.md` returns `0`.

---

## Step 8 — Sweep `e5-execute-tests.md` (row 15 — 2 citations)

**Operation:** EDIT
**File:** `host/templates/claude/commands/e5-execute-tests.md`

### 8a — line 40 (case (a) — keep the surviving SHAMT_RULES link, drop the §1.14)
**Locate:**
```
Per INFRASTRUCTURE.md §1.14 / [`SHAMT_RULES.template.md`](../../../../templates/SHAMT_RULES.template.md#when-automated-testing-is-enabled), this command is safe to invoke unconditionally — the no-op keeps automation simple.
```
**Replace:**
```
Per [`SHAMT_RULES.template.md`](../../../../templates/SHAMT_RULES.template.md#when-automated-testing-is-enabled), this command is safe to invoke unconditionally — the no-op keeps automation simple.
```

### 8b — line 124 (case (a) — the rule is stated inline)
**Locate:**
```
- **Blocks-until-pass is intentional** — INFRASTRUCTURE.md §1.14 explicitly forbids "if failure appears environmental, document and skip." Resolve the environment instead.
```
**Replace:**
```
- **Blocks-until-pass is intentional** — the framework explicitly forbids "if failure appears environmental, document and skip." Resolve the environment instead.
```

**Verification:** `grep -c "INFRASTRUCTURE" host/templates/claude/commands/e5-execute-tests.md` returns `0`.

---

## Step 9 — Sweep `e5b-write-manual-testing-plan.md` (row 16 — 3 citations)

**Operation:** EDIT
**File:** `host/templates/claude/commands/e5b-write-manual-testing-plan.md`

### 9a — line 7 (case (a))
**Locate:**
```
Per INFRASTRUCTURE.md §1.15: invocable any time after Phase 4 (Build) completes, **orthogonal to the project-level automated-testing opt-in** (no `.shamt-core/shamt-config.json` no-op check — this command is always available).
```
**Replace:**
```
Invocable any time after Phase 4 (Build) completes, **orthogonal to the project-level automated-testing opt-in** (no `.shamt-core/shamt-config.json` no-op check — this command is always available).
```

### 9b — line 64 (case (a))
**Locate:**
```
Write `stories/{slug}/manual_test_plan.md` from [`templates/manual_test_plan.template.md`](../../../../templates/manual_test_plan.template.md). Required sections (per [INFRASTRUCTURE.md §1.15](../../../../../INFRASTRUCTURE.md#115-manual-testing-plan-optional-story-level)):
```
**Replace:**
```
Write `stories/{slug}/manual_test_plan.md` from [`templates/manual_test_plan.template.md`](../../../../templates/manual_test_plan.template.md). Required sections:
```

### 9c — line 77 (case (a) — keep the surviving template link, drop the §1.15)
**Locate:**
```
Run Pattern 1 inline — do **not** delegate to `/validate-artifact` here, because the dimension set is artifact-specific. Per [INFRASTRUCTURE.md §1.15](../../../../../INFRASTRUCTURE.md#validation-dimensions) and [`templates/manual_test_plan.template.md`](../../../../templates/manual_test_plan.template.md), the 4 dimensions are:
```
**Replace:**
```
Run Pattern 1 inline — do **not** delegate to `/validate-artifact` here, because the dimension set is artifact-specific. Per [`templates/manual_test_plan.template.md`](../../../../templates/manual_test_plan.template.md), the 4 dimensions are:
```

**Verification:** `grep -c "INFRASTRUCTURE" host/templates/claude/commands/e5b-write-manual-testing-plan.md` returns `0`.

---

## Step 10 — Sweep `e6-review-changes.md` (row 17 — 2 citations)

**Operation:** EDIT
**File:** `host/templates/claude/commands/e6-review-changes.md`

### 10a — line 12 (case (a) — keep the surviving SHAMT_RULES link, drop the §1.11)
**Locate:**
```
Even when the active tracker profile documents a PR-comment command, this command does not invoke it (per [`SHAMT_RULES.template.md`](../../../../templates/SHAMT_RULES.template.md#pattern-4-code-review-process) and INFRASTRUCTURE.md §1.11).
```
**Replace:**
```
Even when the active tracker profile documents a PR-comment command, this command does not invoke it (per [`SHAMT_RULES.template.md`](../../../../templates/SHAMT_RULES.template.md#pattern-4-code-review-process)).
```

### 10b — line 94 (case (a) — the rule is stated inline)
**Locate:**
```
Per INFRASTRUCTURE.md §1.12 — at the end of the sweep, answer **explicitly**: does this change require an `.shamt-core/project-specific-files/ARCHITECTURE.md` or `.shamt-core/project-specific-files/CODING_STANDARDS.md` update?
```
**Replace:**
```
At the end of the sweep, answer **explicitly**: does this change require an `.shamt-core/project-specific-files/ARCHITECTURE.md` or `.shamt-core/project-specific-files/CODING_STANDARDS.md` update?
```

**Verification:** `grep -c "INFRASTRUCTURE" host/templates/claude/commands/e6-review-changes.md` returns `0`.

---

## Step 11 — Sweep `sync-import-shamt.md` (row 18 — 1 sub-edit on 1 line, removing 3 `INFRASTRUCTURE.md` links: §4.5 / §4.6 / §4.13)

**Operation:** EDIT
**File:** `host/templates/claude/commands/sync-import-shamt.md`

**Locate:**
```
Per [INFRASTRUCTURE.md §4.5 / §4.6 / §4.13](../../../../../INFRASTRUCTURE.md#45-master--child-framework-pull), the pull is **always-latest**: it pulls master HEAD with no version pinning.
```
**Replace:**
```
The pull is **always-latest**: it pulls master HEAD with no version pinning.
```

**Verification:** `grep -c "INFRASTRUCTURE" host/templates/claude/commands/sync-import-shamt.md` returns `0`.

---

## Step 12 — Sweep `sync-submit-proposal.md` (row 19 — 2 sub-edits across 2 lines, removing 3 `INFRASTRUCTURE.md` links: 12a §4.3; 12b §4.4 + §4.8)

**Operation:** EDIT
**File:** `host/templates/claude/commands/sync-submit-proposal.md`

### 12a — line 9 (case (a))
**Locate:**
```
The submission itself is **manual copy-paste** per [INFRASTRUCTURE.md §4.3 Option B](../../../../../INFRASTRUCTURE.md#43-child--master-proposal-submission). This command does not push to master
```
**Replace:**
```
The submission itself is **manual copy-paste**. This command does not push to master
```

### 12b — line 27 (case (a) — keep the `proposals/incoming/` discriminator)
**Locate:**
```
Detect master vs. child by checking for `proposals/incoming/` at the cwd: the incoming folder is master's per [§4.4 / §4.8](../../../../../INFRASTRUCTURE.md#44-masters-handling-of-imported-proposals), and child projects never have it.
```
**Replace:**
```
Detect master vs. child by checking for `proposals/incoming/` at the cwd: the incoming folder is master's, and child projects never have it.
```

**Verification:** `grep -c "INFRASTRUCTURE" host/templates/claude/commands/sync-submit-proposal.md` returns `0`.

---

## Phase 3 cross-check

- Rows covered: 4, 5, 6, 7, 8, 9, 10, 15, 16, 17, 18, 19 — one step each (Steps 1–12). ✓
- All EDIT; no CREATE / DELETE / MOVE; no `.claude/` path touched. ✓
- `grep -rn "INFRASTRUCTURE\.md" CHEATSHEET.md reference/audit_dimensions.md reference/trackers/_contract.md reference/trackers/ado.md reference/trackers/github.md templates/epic.template.md templates/feature.template.md host/templates/claude/commands/e5-execute-tests.md host/templates/claude/commands/e5b-write-manual-testing-plan.md host/templates/claude/commands/e6-review-changes.md host/templates/claude/commands/sync-import-shamt.md host/templates/claude/commands/sync-submit-proposal.md` returns zero lines after this phase.

---
*Validated 2026-06-01 — 4 rounds, 1 adversarial sub-agent confirmed.*
