# Implementation Plan — Phase 1: forward-guard edits

**Proposal:** proposals/37-mirrored-skill-summary-drift-on-command-step-change.md
**Index:** proposals/37-mirrored-skill-summary-drift-on-command-step-change_PLAN.md
**Created:** 2026-06-16
**Phase scope:** 5 EDIT operations — rows 1, 2, 3, 4, 6 of the Proposed Changes table (steps 1–5 of the manifest).

Whole-plan / cross-phase verification lives in the **index** file's `## Verification (post-execution, whole plan)` section, run by the architect at `/f3` post-build — not here. Each step below carries only its own per-step (builder-owned) verification.

---

## Step-by-step

### Step 1 — Flip the D2 entry to the Command → Skill Protocol pointer rule (row 1)

**Operation:** EDIT
**File:** `reference/audit_dimensions.md`
**Locate:**
```
| D2 | Cross-doc consistency | The rules file and the host body that implements it agree on steps, exit criteria, and naming. (Rules ↔ host.) |
```
**Replace:**
```
| D2 | Cross-doc consistency | The rules file and the host body that implements it agree on steps, exit criteria, and naming. (Rules ↔ host.) **Command → Skill Protocol pointer rule:** a `host/templates/claude/skills/{name}/SKILL.md` `## Protocol` section **is** the canonical "Follow the canonical `/{name}` command body verbatim — see `commands/{name}.md`" pointer and **must not** re-introduce a numbered step-by-step paraphrase of the command body (regen copies `SKILL.md` verbatim and cannot keep such a paraphrase in sync, so it is a drift class). D2 flags any SKILL `## Protocol` that carries a numbered step paraphrase as a finding — pointer form is required, not merely a "faithful" summary. |
```
**Verification:**
- `grep -F 'Command → Skill Protocol pointer rule' reference/audit_dimensions.md` returns one match.
- `grep -F 'pointer form is required, not merely a "faithful" summary' reference/audit_dimensions.md` returns one match.

### Step 2 — Replace the soft skill cross-check clause in /f1 Step 3 item 3 (row 2)

**Operation:** EDIT
**File:** `host/templates/claude/commands/f1-propose-update.md`
**Locate:**
```
3. Cross-check the list. For every rule edit, ask: does the corresponding template need to change? Does the mirrored skill need to change? For every command edit, ask: does the skill need to change? For every reference change, ask: does the rule body that points at it need to change?
```
**Replace:**
```
3. Cross-check the list. For every rule edit, ask: does the corresponding template need to change? Does the mirrored skill need to change? For every reference change, ask: does the rule body that points at it need to change? **Command ↔ skill is a pointer relationship, not a paraphrase one:** a `skills/{name}/SKILL.md` `## Protocol` **is** the command-body pointer ("Follow the canonical `/{name}` command body verbatim — see `commands/{name}.md`") — **never** paraphrase the command's numbered steps there, so a command-step edit needs **no** paired SKILL summary edit (the paraphrase was the drift class removed by proposal #37). When a proposal CREATEs or EDITs a `skills/{name}/SKILL.md`, confirm its `## Protocol` stays the pointer form. See the **Command → Skill Protocol pointer rule** at the D2 entry in [`reference/audit_dimensions.md`](../../../../reference/audit_dimensions.md).
```
**Verification:**
- `grep -F 'Command ↔ skill is a pointer relationship, not a paraphrase one' host/templates/claude/commands/f1-propose-update.md` returns one match.
- `grep -F 'Command → Skill Protocol pointer rule' host/templates/claude/commands/f1-propose-update.md` returns one match.

### Step 3 — Add the pointer-form check to /validate-artifact's framework-proposal row (row 3)

**Operation:** EDIT
**File:** `host/templates/claude/commands/validate-artifact.md`
**Locate:**
```
| Framework-update proposal | general 5 dimensions + proposal-specific checks (affected surfaces, propagation plan, rollback path) |
```
**Replace:**
```
| Framework-update proposal | general 5 dimensions + proposal-specific checks (affected surfaces, propagation plan, rollback path); **flag any Proposed Changes row that would (re-)introduce a numbered step-by-step paraphrase into a `skills/{name}/SKILL.md` `## Protocol`** — SKILL Protocols must stay the command-body pointer form (see the **Command → Skill Protocol pointer rule** at the D2 entry in [`reference/audit_dimensions.md`](../../../../reference/audit_dimensions.md)) |
```
**Verification:**
- `grep -F 'flag any Proposed Changes row that would (re-)introduce a numbered step-by-step paraphrase' host/templates/claude/commands/validate-artifact.md` returns one match.
- `grep -F 'Command → Skill Protocol pointer rule' host/templates/claude/commands/validate-artifact.md` returns one match.

### Step 4 — Point the proposal template's Change-list completeness hint at the pointer rule (row 4)

**Operation:** EDIT
**File:** `proposals/_template.md`
**Locate:**
```
- **Change-list completeness** — [Files that are easy to forget but must be edited together with the listed ones (e.g., the rule changes but the template referenced by the rule does not; the command changes but the mirrored skill does not).]
```
**Replace:**
```
- **Change-list completeness** — [Files that are easy to forget but must be edited together with the listed ones (e.g., the rule changes but the template referenced by the rule does not; the reference doc changes but the rule that points at it does not). Note: a `skills/{name}/SKILL.md` `## Protocol` **is** the command-body pointer, never a step-by-step paraphrase (the **Command → Skill Protocol pointer rule** at the D2 entry in `reference/audit_dimensions.md`) — so a command-step edit needs **no** paired SKILL summary edit; conversely, a Proposed Changes row must never (re-)introduce a numbered paraphrase into a SKILL Protocol.]
```
**Verification:**
- `grep -F 'a `skills/{name}/SKILL.md` `## Protocol` **is** the command-body pointer, never a step-by-step paraphrase' proposals/_template.md` returns one match.
- `grep -F 'Command → Skill Protocol pointer rule' proposals/_template.md` returns one match.

### Step 5 — Flip the operative D2 check in /f5-audit-framework to the pointer-form rule (row 6)

**Operation:** EDIT
**File:** `host/templates/claude/commands/f5-audit-framework.md`
**Locate:**
```
- Step count and order match (or the body explicitly says "Summary: see canonical command body" and the summary is faithful).
```
**Replace:**
```
- Step count and order match. **Command → Skill Protocol pointer rule** (see the D2 entry in [`reference/audit_dimensions.md`](../../../../reference/audit_dimensions.md)): a `skills/{name}/SKILL.md` `## Protocol` **is** the command-body pointer ("Follow the canonical `/{name}` command body verbatim — see `commands/{name}.md`") and **must not** carry a numbered step-by-step paraphrase of the command body; flag any SKILL `## Protocol` that re-introduces a numbered step list as a D2 finding (pointer form is required, not a "faithful" paraphrase).
```
**Verification:**
- `grep -F 'must not** carry a numbered step-by-step paraphrase' host/templates/claude/commands/f5-audit-framework.md` returns one match.
- `grep -F 'the summary is faithful' host/templates/claude/commands/f5-audit-framework.md` returns zero matches (the old allowance is gone).
- `grep -F 'Command → Skill Protocol pointer rule' host/templates/claude/commands/f5-audit-framework.md` returns one match.

---

## Notes (Phase 1)

- All five edits are clarifying-guidance prose flips. None changes a control-flow contract, a report string, or a numbered-step structure.
- The five new references to the **Command → Skill Protocol pointer rule** all point at the D2 entry in `reference/audit_dimensions.md` (created by Step 1) — Step 1 should be applied first so the target wording exists, though the references resolve to the file regardless of intra-file edit order.
- Relative link depth: `commands/*.md` files sit at `host/templates/claude/commands/`, so the path back to `reference/` is `../../../../reference/audit_dimensions.md` (used in steps 2, 3, 5 — matches the existing `validate-artifact.md` link convention). `proposals/_template.md` references the rule by name without a relative link (step 4), consistent with the template's prose style.

---
Validated 2026-06-16 — 2 rounds (primary clean + adversarial validation-checker confirmed: zero issues)
