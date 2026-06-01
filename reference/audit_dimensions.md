# Framework Audit Dimensions (D1–D11)

**Extends the `/f5-audit-framework` command body — read [`host/templates/claude/commands/f5-audit-framework.md`](../host/templates/claude/commands/f5-audit-framework.md) first.**

**Purpose:** Full definitions of the eleven audit dimensions grouped under the three C's (Completeness / Correctness / Consistency), worked examples of the simple-vs-intricate fix-track boundary, and the known-exceptions list of intentional patterns the audit must **not** re-flag on every run.

The command and skill bodies carry the **normative boundary** — the dimension severities and the three simple-fix criteria (mechanical + single-file + uniquely-determined, borderline → intricate). This document only elaborates them with examples; it introduces no new boundary logic an implementing agent has to invent. (Mirrors how Pattern 1 offloads its mechanics to [`validation_exit_criteria.md`](validation_exit_criteria.md).)

---

## The three C's

The audit exists to keep the framework **complete** (it covers what it should, with nothing missing), **correct** (its facts, links, and counts are true), and **consistent** (its docs agree with each other and name each concept one way). Every dimension serves one of the three.

### Completeness

| Dim | Name | What "complete" means here |
|-----|------|----------------------------|
| D3 | Bidirectional coverage | Every documented pattern/rule has a host implementation; every host body cites a pattern/rule it implements. Nothing documented is unimplemented; nothing implemented is undocumented. |
| D5 | Template-protocol alignment | Each template carries every section its producing/consuming protocol writes or reads — and no orphan sections the protocol abandoned. |
| D6 | Project-doc currency | The required project docs (`ARCHITECTURE.md`, `CODING_STANDARDS.md`) exist and are within the staleness threshold — the inputs the Engineer flow depends on are present and fresh. |
| D8 | Content completeness | No half-finished content — no stray `TODO` / `TBD` / `FIXME` / unfilled `[placeholder]` left in a canonical body. |

### Correctness

| Dim | Name | What "correct" means here |
|-----|------|---------------------------|
| D1 | Sync drift | Generated `.claude/` matches canonical sources — regen `--check` exits 0, no `DRIFT` / `STALE`. |
| D4 | Reference validity | Every markdown link, template reference, tracker-profile name, and persona name resolves on disk. |
| D10 | Count / claim accuracy | Every explicit count or enumerated claim matches reality — "11 dimensions", "5 patterns", "8 plan dimensions", phase numbers, persona counts. |

### Consistency

| Dim | Name | What "consistent" means here |
|-----|------|------------------------------|
| D2 | Cross-doc consistency | The rules file and the host body that implements it agree on steps, exit criteria, and naming. (Rules ↔ host.) |
| D7 | Terminology consistency | One canonical term per concept across all canonical docs. |
| D9 | Duplication / contradiction | No two canonical files give conflicting instructions for the same protocol. (Host ↔ host, reference ↔ reference — the contradiction neither side of which is the rules file; that case is D2's.) |
| D11 | Scope-clarity | Each command/skill states its scope unambiguously near its heading; no leftover migration notes or stale "(was X)" parentheticals inline in the instruction path. |

**D2 vs D7/D9 — the clean boundary.** D2 is vertical: does the *host body* faithfully implement the *rules-file pattern*? D7 is lexical: is each concept *named* one way everywhere? D9 is horizontal: do two *non-rules* files contradict each other? A command body that says "2 consecutive clean rounds" while the rules file's Pattern 1 says "1 primary clean + sub-agent" is **D2**. Two command bodies that disagree with *each other* about whether the audit needs a sub-agent is **D9**. The word "Implement" used where the canonical phase name is "Build" is **D7**. No finding should be counted under more than one dimension — classify by the relationship it breaks.

### The canonical-term table (D7)

| Concept | Canonical term | Never |
|---------|----------------|-------|
| Story complexity tier | Quick / Standard | Small / Full (those are v1 lane names) |
| Phase 4 | Build | Implement |
| Role flows | Engineer flow / Product Owner (PO) flow | "lite mode" / "full mode" |
| An audit observation | finding (audit) / issue (Pattern 1) | *interchangeable by design — not a violation* |

---

## The simple-vs-intricate fix-track boundary (master / self-host target)

On a **master / self-host** target the audit auto-fixes *simple* findings and routes *intricate* ones to `/f1-propose-update`. Against a **child project** the audit is report-only — see the carve-out below. A finding is **simple** only when **all three** hold:

1. **Mechanical** — the edit is a text substitution, not a design decision.
2. **Single-file** — the fix lives entirely in one canonical file.
3. **Uniquely determined** — the finding itself fixes the correct value; there is no choice to make.

**Borderline → intricate.** If any of the three is in doubt, route to a proposal.

### Worked examples — simple (auto-fix + re-verify the dimension)

| Finding | Why simple |
|---------|-----------|
| D4: a markdown link points at `reference/audit_dimension.md` but the file is `audit_dimensions.md` | Mechanical, single-file, the correct target is unambiguous on disk. |
| D10: a skill `description` says "six dimensions" after the table grew to eleven | Mechanical; the table is the source of truth, so the number is uniquely determined. |
| D7: one body writes "Small Story Lane" where every other body says "Quick path" | Normalizing to the single canonical term; no judgment. |
| D8: a stray `TODO: fill in later` left in a reference body | Removal (or completion if the surrounding text determines it) is mechanical and single-file. |

After any auto-fix, **re-run that finding's dimension** to confirm it clears. If the edited file is under `host/templates/claude/`, follow with `/f4-regen-framework` (or re-run D1) — an unsynced auto-fix is itself a D1 finding.

### Worked examples — intricate (route to `/f1-propose-update`, do not edit)

| Finding | Why intricate |
|---------|--------------|
| D9: two command bodies give genuinely different step orders for the same protocol | The "correct" order is a design decision; picking one silently could break the other's callers. |
| D4: a link is broken and *two* plausible targets exist | Not uniquely determined — which target is right is a judgment call. |
| D2: a rule and its skill disagree, and it's unclear whether the rule or the skill is wrong | Resolving it is a coordinated rule↔skill edit — multi-file, design judgment. |
| D7: a "terminology" fix that is actually load-bearing (the two words name two genuinely different things) | Not mechanical — renaming would erase a real distinction. |

The audit suggests a descriptive proposal slug and stops short of editing. Borderline cases (e.g., "is this one word a synonym or a real distinction?") resolve to **intricate**.

### In-flow logging

When the audit runs as Phase 6 of the framework-update flow, a proposal is already in flight. Auto-fixes still run on a master target, but **each is logged in chat as an out-of-band correction, explicitly distinct from the in-flight proposal's scope** — so the proposal's validated change-set and footer stay clean and a reader can always separate proposal edits from audit edits.

### Child-target carve-out (report-only)

When `/f5-audit-framework` runs against a **child project**, its canonical sources under `.shamt-core/` are read-only imported copies of master. Auto-fixing them would be clobbered on the next `/sync-import-shamt` and silently diverge the child from master. So in a child context the audit stays **report-only**: every finding surfaces with its severity, anything upstream-worthy carries a suggestion to route it via `/f1-propose-update` → `/sync-submit-proposal`, and the only edits permitted are the genuinely-local mechanical re-verifications allowed everywhere (re-running regen / `--check` for D1). The fix-immediately track never edits a child's imported canonical copies. The master-vs-child decision reuses the **D6 self-host detection rule** — there is no second detection mechanism to keep in sync.

---

## Known exceptions — do not re-flag these

These are intentional patterns. The expanded audit must recognize them and record **no finding** (or only the documented informational LOW) each run:

- **D6 self-host not-applicable.** When the target is the shamt-core development repo itself (no project docs expected), D6 records a single LOW informational finding, not a HIGH miss.
- **D8 template fill-in placeholders.** Intentional fill-in tokens inside `templates/*.template.md` and the host template bodies — `{slug}`, `{date}`, `[one-line description]`, `{N}`, and similar — are the templates doing their job, **not** stray markers. D8 flags `TODO` / `TBD` / `FIXME` / unfilled brackets only in non-template canonical prose (or in a template's *instructional* prose, where they would be a real omission).
- **"finding" vs "issue".** The audit says "finding"; Pattern 1 says "issue". They are interchangeable by design (stated in the command body) — **not** a D7 terminology violation.
- **`local` tracker profile has no ticket template.** D5 records no finding for the absence of a `ticket.local.template.md` — the `local` ticket is hand-authored or PO-flow-produced.
- **Phase count varies with the testing flag.** 6 phases when `testing: "disabled"`, 7 when `"enabled"`. D10 treats both as correct — a body must match the count *for the configuration it describes*, not a single fixed number.
- **INFRASTRUCTURE.md is out of the audit surface.** The audit sweeps `shamt-core/` canonical sources. The repo-root `../INFRASTRUCTURE.md` planning log (with its `Resolved:` / `(was X)` history) is not a regenerated canonical source and is not swept — its historical notes are not D11 findings.

When a genuinely-new intentional pattern emerges that the audit keeps re-flagging, add it here through `/f1-propose-update` rather than weakening a dimension.

---
