# Implementation Plan — Phase 4: Skills

**Parent plan:** [`dot-shamt-core-layout_PLAN.md`](dot-shamt-core-layout_PLAN.md)
**Proposal:** proposals/dot-shamt-core-layout.md
**Surface:** 16 `host/templates/claude/skills/*/SKILL.md` files (Groups C1, C2, D2, E2, F1, F2 — merged per file).

Skill bodies mirror their command counterparts. The four master-side framework-update skills (`triage-proposals`, `archive-proposal`, `implement-update`, `plan-update-implementation`) are **not** in this phase. `audit-framework/SKILL.md` line 38 regen-script path is **left** (architect ruling — `audit-framework` is not in Group C).

## Files manifest

| # | File | Sweeps |
|---|------|--------|
| 1 | `start-epic/SKILL.md` | D + E |
| 2 | `start-feature/SKILL.md` | D + E |
| 3 | `start-story/SKILL.md` | D |
| 4 | `define-spec/SKILL.md` | E |
| 5 | `plan-implementation/SKILL.md` | D |
| 6 | `decompose-feature/SKILL.md` | D |
| 7 | `execute-tests/SKILL.md` | D |
| 8 | `audit-framework/SKILL.md` | D + E (regen-path line 38 left) |
| 9 | `review-changes/SKILL.md` | E |
| 10 | `resolve-feedback/SKILL.md` | E + F2 |
| 11 | `write-testing-plan/SKILL.md` | D + E |
| 12 | `write-manual-testing-plan/SKILL.md` | D |
| 13 | `propose-update/SKILL.md` | F1 |
| 14 | `submit-proposal/SKILL.md` | D + F1 (`incoming/` left) |
| 15 | `import-shamt/SKILL.md` | C1 + D + F1 |
| 16 | `regen-framework/SKILL.md` | C2 (no agent covered it — authored here) |

All edits apply the [four conventions](dot-shamt-core-layout_PLAN.md#replacement-conventions-the-four-mechanical-sweeps). Locate strings are verbatim from the files.

---

## Step 1 — `start-epic/SKILL.md`

**O1 (7):** `  through to freeform), consults ARCHITECTURE.md for architectural impact, and` → `  through to freeform), consults .shamt-core/project-specific-files/ARCHITECTURE.md for architectural impact, and`
**O2 (32):** ``1. **Read configuration.** `shamt-config.json` → `work_item_tracker`; honor `--tracker={ado|github|local}` override. Read the corresponding profile in [`reference/trackers/`](../../../../../reference/trackers/).`` → `.shamt-core/shamt-config.json`
**O3 (39):** ``5. **Consult `ARCHITECTURE.md`** (advisory). Flag architectural impact inline in `Scope / Non-Scope` as `**Architecture impact:** {…}` when the epic implies a new service / boundary / data store / external integration. **Do NOT consult `CODING_STANDARDS.md`** — coding style is irrelevant at the epic altitude.`` → repoint `ARCHITECTURE.md` and `CODING_STANDARDS.md` (leave `**Architecture impact:**` label)

**Verification:** config regex → 0; docs regex → 0; `grep -c '\.shamt-core/' …/start-epic/SKILL.md` → 3 (escape the dot — an unescaped `.` also matches the footer's bare ` shamt-core/`).

## Step 2 — `start-feature/SKILL.md`

**O1 (9):** `  work-item payload when the active profile (read from shamt-config.json)` → `.shamt-core/shamt-config.json`
**O2 (13):** `  is the default fallback. Consults ARCHITECTURE.md for architectural impact` → `.shamt-core/project-specific-files/ARCHITECTURE.md`
**O3 (36):** ``1. **Read configuration.** `shamt-config.json` → `work_item_tracker`; honor `--tracker={ado|github|local}` override. Read the corresponding profile in [`reference/trackers/`](../../../../../reference/trackers/). The override only affects Mode C — a no-op in Mode A and Mode B (a one-line notice surfaces if the flag is supplied in those modes).`` → `.shamt-core/shamt-config.json`
**O4 (45):** ``5. **Consult `ARCHITECTURE.md`** (advisory). ... **Do NOT consult `CODING_STANDARDS.md`** — coding style is irrelevant at the feature altitude. Same rule as `/start-epic`.`` → repoint both docs (leave `**Architecture impact:**` label)

**Verification:** config regex → 0; docs regex → 0; `grep -c '\.shamt-core/' …/start-feature/SKILL.md` → 4 (escape the dot — an unescaped `.` also matches the footer's bare ` shamt-core/`).

## Step 3 — `start-story/SKILL.md`

**O1 (29):** ``1. Read `shamt-config.json`; honor `--tracker={ado|github|local}` override.`` → `.shamt-core/shamt-config.json`

**Verification:** config regex → 0; `grep -c '.shamt-core/shamt-config.json' …/start-story/SKILL.md` → 1.

## Step 4 — `define-spec/SKILL.md`

**O1 (30):** ``2. **Targeted research** — grep referenced files; read `ARCHITECTURE.md` and `CODING_STANDARDS.md`; capture findings (Standard: `context.md`; Quick: `spec.md` Evidence). Populate the review-prevention risk inventory using [`reference/pr_review_prevention.md`](../../../../../reference/pr_review_prevention.md).`` → repoint both docs

**Verification:** docs regex → 0; `grep -o '\.shamt-core/project-specific-files/' …/define-spec/SKILL.md | wc -l` → 2 (both doc refs sit on the same line 30, so `grep -c` would report 1 line — count occurrences, not lines).

## Step 5 — `plan-implementation/SKILL.md`

**O1 (34):** ``5. **Chain into `/write-testing-plan {slug}`** when `shamt-config.json` sets `testing: "enabled"`. Wait for the testing plan to validate before Gate 3.`` → `.shamt-core/shamt-config.json`

**Verification:** config regex → 0.

## Step 6 — `decompose-feature/SKILL.md`

**O1 (50):** ``8. **Write the story-ticket stubs** from the active tracker's per-provider ticket template — read `work_item_tracker` from `shamt-config.json`:`` → `.shamt-core/shamt-config.json`

**Verification:** config regex → 0.

## Step 7 — `execute-tests/SKILL.md`

**O1 (4):** `  Run Phase 5 (Test) of the Shamt Engineer flow when shamt-config.json sets` → `.shamt-core/shamt-config.json`
**O2 (28):** ``1. **No-op gate** — if `shamt-config.json` sets `testing: "disabled"`, print the one-line skip message and exit. Do not touch any file.`` → `.shamt-core/shamt-config.json`

**Verification:** config regex → 0; `grep -c '.shamt-core/shamt-config.json' …/execute-tests/SKILL.md` → 2.

## Step 8 — `audit-framework/SKILL.md`

**O1 (43):** ``6. **D6 project-doc currency** — `ARCHITECTURE.md` + `CODING_STANDARDS.md` present at the project root; `Last Updated` within `doc_staleness_threshold_days` (default 60 per `shamt-config.json`). Missing required doc = HIGH; stale doc = MEDIUM; not-applicable case for in-development `shamt-core/` = single LOW informational.``
Replace: ``6. **D6 project-doc currency** — `.shamt-core/project-specific-files/ARCHITECTURE.md` + `.shamt-core/project-specific-files/CODING_STANDARDS.md` present in the child project; `Last Updated` within `doc_staleness_threshold_days` (default 60 per `.shamt-core/shamt-config.json`). Missing required doc = HIGH; stale doc = MEDIUM; not-applicable case for in-development `shamt-core/` = single LOW informational.``
*(The trailing `in-development \`shamt-core/\`` is a master-canonical self-reference to the framework repo — left as-is.)*

**Left unchanged:** line 38 (`bash shamt-core/scripts/regenerate-framework.sh --check` — D1 drift check; audit-framework is not in Group C).

**Verification:** config regex → 0; docs regex → 0; `grep -n 'shamt-core/scripts/regenerate' …/audit-framework/SKILL.md` → line 38 present.

## Step 9 — `review-changes/SKILL.md`

**O1 (39):** ``4. **Documentation Impact Assessment** (§1.12) — does the change require `ARCHITECTURE.md` or `CODING_STANDARDS.md` updates? Write `## Documentation Impact` with `Required | Not required` + reason + Polish action.`` → repoint both docs

**Verification:** docs regex → 0.

## Step 10 — `resolve-feedback/SKILL.md`

**O1 (6):** `  ARCHITECTURE.md / CODING_STANDARDS.md updates the Review phase flagged, and` → repoint both docs
**O2 (7):** `  route generalizable root causes to proposals/ rather than patching framework` → `.shamt-core/proposals/`
**O3 (31):** ``4. **Documentation Impact update** — when the Review flagged `Required`, apply the `Polish action` to `ARCHITECTURE.md` / `CODING_STANDARDS.md`, update `Last Updated` + `Update History`, re-validate via `/validate-artifact`. Commit.`` → repoint both docs
**O4 (32):** ``5. **Root-cause / upstream proposals** — generalizable patterns → `proposals/<proposal-slug>.md` (descriptive slug, not the story slug) via the framework-update flow (§1.12 + Part 3 rule). Story-specific patterns stay in-story.`` → `.shamt-core/proposals/<proposal-slug>.md`
**O5 (33):** ``6. **TODO scan** — Global Story Invariants TODO gate; remove or explicitly justify every remaining marker; honour stricter `CODING_STANDARDS.md` rules.`` → `.shamt-core/project-specific-files/CODING_STANDARDS.md`
**O6 (45):** ``...generalizable root causes filed under `proposals/`; user has signalled complete...`` → `.shamt-core/proposals/`

**Verification:** docs regex → 0; `grep -nE '(^|[^./a-z-])proposals/' …/resolve-feedback/SKILL.md | grep -v '.shamt-core/proposals'` → 0.

## Step 11 — `write-testing-plan/SKILL.md`

**O1 (4):** `  Plan sub-phase invoked when shamt-config.json sets testing: "enabled".` → `.shamt-core/shamt-config.json`
**O2 (29):** ``1. **No-op gate** — if `shamt-config.json` sets `testing: "disabled"`, print one line and exit. Do not touch any file.`` → `.shamt-core/shamt-config.json`
**O3 (34):** ``4. **Draft** — each step has an exact invocation and binary pass criterion; cross-reference `ARCHITECTURE.md` and `CODING_STANDARDS.md` for runner / file naming / fixture / assertion conventions. Apply the **open-questions iterative dialog** principle.`` → repoint both docs

**Verification:** config regex → 0; docs regex → 0.

## Step 12 — `write-manual-testing-plan/SKILL.md`

**O1 (8):** `  Orthogonal to shamt-config.json testing — always available, every story. The` → `.shamt-core/shamt-config.json`
**O2 (26):** ``Mirrors the `/write-manual-testing-plan {slug}` slash command. Same canonical body, two host wirings. **Always available** regardless of `shamt-config.json` `testing` — no no-op gate (this is the §1.15 rule that distinguishes it from `/write-testing-plan` and `/execute-tests`).`` → `.shamt-core/shamt-config.json`

**Verification:** config regex → 0.

## Step 13 — `propose-update/SKILL.md` (F1)

**O1 (4):** `  Author or edit a framework-update proposal at proposals/{slug}.md. Phase 1` → `.shamt-core/proposals/{slug}.md`
**O2 (30):** ``1. **Resolve slug** to `proposals/{slug}.md`. Re-entry on an existing draft = confirm extend / overwrite. Halt if `proposals/archive/{slug}.md` already exists unless the user confirms a follow-up.`` → both `proposals/…` → `.shamt-core/proposals/…`
**O3 (31):** ``2. **Seed from template** at [`proposals/_template.md`](../../../../../proposals/_template.md). Fill header (date, status, `Proposed by:` / `Project context:` for child-authored).`` → display text → `.shamt-core/proposals/_template.md` (leave the `../../../../../proposals/_template.md` href as-is — relative link to the synced template within the install)
**O4 (37):** ``8. **Suggest next phase** — `/clear` + `/validate-artifact proposals/{slug}.md` (and `/plan-update-implementation {slug}` when row count > 10).`` → `.shamt-core/proposals/{slug}.md`
**O5 (45):** ``\`proposals/{slug}.md\` exists, has no open questions, every Proposed Changes row points at a canonical (non-`.claude/`) path, and the next phase has been suggested.`` → `.shamt-core/proposals/{slug}.md`

**Verification:** `grep -nE '(^|[^./a-z-])proposals/' …/propose-update/SKILL.md | grep -v '.shamt-core/proposals' | grep -v '\.\./\.\./\.\./\.\./\.\./proposals'` → 0 (the one relative-link href is allow-listed).

## Step 14 — `submit-proposal/SKILL.md` (D + F1; `incoming/` left)

**O1 (5–10, YAML desc — config + child-side submitted path; leave `proposals/incoming/`):**
Locate (multi-line block per the update-flow skill enumeration):
```
  proposal at proposals/{slug}.md for upstream submission to master. Reads
  project_name from shamt-config.json, confirms the proposal carries a Phase 2
  validation footer and child-attribution headers (Proposed by, Project
  context), prints the proposal content with the master-side target path
  (proposals/incoming/{project}-{slug}.md) for manual copy-paste, and moves the
  local copy to proposals/submitted/{slug}.md to mark "awaiting decision". Does
```
Replace:
```
  proposal at .shamt-core/proposals/{slug}.md for upstream submission to master. Reads
  project_name from .shamt-core/shamt-config.json, confirms the proposal carries a Phase 2
  validation footer and child-attribution headers (Proposed by, Project
  context), prints the proposal content with the master-side target path
  (proposals/incoming/{project}-{slug}.md) for manual copy-paste, and moves the
  local copy to .shamt-core/proposals/submitted/{slug}.md to mark "awaiting decision". Does
```
**O2 (17, trigger):** `  - "submit proposals/{slug}.md"` → `  - "submit .shamt-core/proposals/{slug}.md"`
**O3 (33, config):** ``2. **Read shamt-config.json** — extract `project_name`. Halt if missing/empty. Validate it matches `^[A-Za-z0-9._-]+$`.`` → `**Read `.shamt-core/shamt-config.json`**`
**O4 (34):** ``3. **Read and confirm the proposal** — `proposals/{slug}.md` exists with a Phase 2 validation footer...`` → `.shamt-core/proposals/{slug}.md`
**O5 (37):** ``6. **Move the local copy** — `proposals/{slug}.md` → `proposals/submitted/{slug}.md` (`git mv` when tracked). Confirm footer intact post-move. Halt if `proposals/submitted/{slug}.md` already exists.`` → all three → `.shamt-core/proposals/…`
**O6 (46):** ``- `proposals/submitted/{slug}.md` exists with the validation footer intact.`` → `.shamt-core/proposals/submitted/{slug}.md`
**O7 (48):** ``- `proposals/{slug}.md` no longer exists at the original location.`` → `.shamt-core/proposals/{slug}.md`
**O8 (52):** ``If master rejected a prior submission and the user wants to revise: manually move `proposals/submitted/{slug}.md` back to `proposals/{slug}.md`, edit, re-validate via `/validate-artifact`, then re-run `/submit-proposal {slug}`.`` → both → `.shamt-core/proposals/…`
**O9 (56):** ``...auto-moves `proposals/submitted/{slug}.md` → `proposals/already-merged/{slug}.md` when it detects the matching `proposals/archive/{slug}.md` on master...`` → repoint the two child-side paths; **leave** `proposals/archive/{slug}.md on master`

**Left unchanged (master-side):** `proposals/incoming/{project}-{slug}.md` (YAML desc), `proposals/archive/{slug}.md on master` (line 56).

**Verification:** config regex → 0; `grep -nE '(^|[^./a-z-])proposals/' …/submit-proposal/SKILL.md | grep -v '.shamt-core/proposals' | grep -v 'proposals/incoming' | grep -v 'proposals/archive'` → 0.

## Step 15 — `import-shamt/SKILL.md` (C1 + D + F1)

**O1 (4–8, YAML desc — install-dir + config + already-merged; leave `master's proposals/archive/`):**
Locate:
```
  Child-side framework pull for the v2 master/child sync. Wraps shamt-core/
  import-shamt.sh: reads master_url from shamt-config.json (git URL or local
  path), pulls master HEAD, overwrites canonical sources under <child>/
  shamt-core/ from master's sync set, auto-moves child-local proposals whose
  slugs match master's proposals/archive/ into proposals/already-merged/, and
```
Replace:
```
  Child-side framework pull for the v2 master/child sync. Wraps .shamt-core/
  import-shamt.sh: reads master_url from .shamt-core/shamt-config.json (git URL or local
  path), pulls master HEAD, overwrites canonical sources under <child>/
  .shamt-core/ from master's sync set, auto-moves child-local proposals whose
  slugs match master's proposals/archive/ into .shamt-core/proposals/already-merged/, and
```
**O2 (31):** ``1. **Resolve script** — `shamt-core/import-shamt.sh` must exist under the cwd and be executable; if not, halt.`` → `.shamt-core/import-shamt.sh`
**O3 (32):** ``2. **Working tree check** — if the target is a git repo and `shamt-core/` or `.claude/` has uncommitted changes...`` → `.shamt-core/` (leave `.claude/`)
**O4 (33):** ``3. **Run** `bash shamt-core/import-shamt.sh [--target {target_dir}]`. ...`` → `.shamt-core/import-shamt.sh`
**O5 (34):** ``...and each `moved proposals/{slug}.md → proposals/already-merged/…` line so the user can act on each.`` → both → `.shamt-core/proposals/…`
**O6 (48):** ``Files the child adds under `shamt-core/{templates,reference,host,scripts}/` outside that set are preserved with a warning.`` → `.shamt-core/{templates,reference,host,scripts}/`

**Left unchanged (master-side / sync-set):** `master's proposals/archive/` (line 8), `proposals/_template.md` + `shamt-config.example.json` sync-set members (line 48). **Gate-F allow-list note:** line 48's bare `proposals/_template.md` (a sync-set enumeration entry, master-canonical and unchanged — symmetric with the proposal's "`CHEATSHEET.md` sync-set enumerations stay bare" rule) survives the Phase-6 Gate-F grep's `incoming`/`archive`/`.shamt-core/proposals` excludes, so it must be added to the Gate-F allow-list in `dot-shamt-core-layout_PLAN.md` (else Phase 6 reports a spurious bare-`proposals/` hit on this file).

**Verification:** `grep -nE 'shamt-core/import-shamt\.sh|under <child>/\s*shamt-core/' …/import-shamt/SKILL.md | grep -v '.shamt-core'` → 0; config regex → 0; `grep -c '\.shamt-core/' …/import-shamt/SKILL.md` → 9 (escape the dot; post-edit `.shamt-core/` lands on lines 4, 5, 7, 8, 31, 32, 33, 34, 48 = 9 lines).

## Step 16 — `regen-framework/SKILL.md` (C2 — authored here; no agent covered it)

**O1 (35):** ``1. **Resolve script path** at `shamt-core/scripts/regenerate-framework.sh`. Confirm executable.`` → `.shamt-core/scripts/regenerate-framework.sh`
**O2 (37):** ``3. **Run regen** — `bash shamt-core/scripts/regenerate-framework.sh --target {dir}`. Surface `wrote` / `removed` / `WARN:` lines. Special-case warnings: unmanaged file collisions, missing `jq`, broken `settings.json`.`` → `.shamt-core/scripts/regenerate-framework.sh`
**O3 (38):** ``4. **Run drift check** — `bash shamt-core/scripts/regenerate-framework.sh --check --target {dir}`. Expected: `no drift` (exit 0). Any `DRIFT` or `STALE` lines halt Phase 5.`` → `.shamt-core/scripts/regenerate-framework.sh`

**Left unchanged (master-canonical):** line 5 (YAML desc `shamt-core/host/templates/claude/` — describes the canonical wiring tree), line 29 (`shamt-core/host/templates/claude/` narrative), line 51 (`shamt-core/host/templates/claude/` standalone-use note), the footer regenerate-from pointer.

**Note:** unlike `regen-framework.md` (command), this skill body carries **no** self-host detection rule-of-thumb (`{target}/shamt-core/`), so there is no self-host string to preserve here — confirm by grep below.

**Verification:** `grep -nE 'shamt-core/scripts/regenerate' …/regen-framework/SKILL.md | grep -v '.shamt-core/'` → 0; `grep -n '{target}/shamt-core' …/regen-framework/SKILL.md` → 0 (no self-host rule in the skill body); `grep -n 'shamt-core/host/templates/claude/' …/regen-framework/SKILL.md | grep -v 'Regenerate from'` → 3 master-canonical narrative mentions preserved (lines 5, 29, 51; the `grep -v` drops the line-56 footer regenerate-from pointer, which also contains the string).

---

## Cross-check vs Proposed Changes (Phase 4 coverage)

| Proposal row | Covered by |
|---|---|
| D2 (skills config sweep) | Steps 1–3, 5–8, 11–12, 14, 15 |
| E2 (skills doc sweep) | Steps 1, 2, 4, 8, 9, 10, 11 |
| F1 (skills: propose/submit/import) | Steps 13, 14, 15 |
| F2 (resolve-feedback skill) | Step 10 |
| C1 (import-shamt skill install-path) | Step 15 |
| C2 (regen-framework skill install-path) | Step 16 |

---

Validated 2026-05-28 — 3 rounds, 1 adversarial sub-agent confirmed
