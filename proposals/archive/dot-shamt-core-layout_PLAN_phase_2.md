# Implementation Plan — Phase 2: Root docs + rules template

**Parent plan:** [`dot-shamt-core-layout_PLAN.md`](dot-shamt-core-layout_PLAN.md)
**Proposal:** proposals/dot-shamt-core-layout.md
**Surface:** `CHEATSHEET.md` (B1), `CLAUDE.md` (B2 — master-dev primer), `templates/SHAMT_RULES.template.md` (B3).

`CHEATSHEET.md` carries a structural layout-diagram rewrite (Step 1) plus prose path sweeps. `CLAUDE.md` is the master-dev primer: only its *child-layout description* changes; its master-side framework-update prose (`proposals/` at master) is left. `SHAMT_RULES.template.md` renders into the child's `CLAUDE.md`, so all its child-context path references are swept.

## Files manifest

| # | Path | Operation | Notes |
|---|------|-----------|-------|
| 1 | `CHEATSHEET.md` | EDIT | Layout-diagram rewrite + install/sync/config/regen prose sweeps |
| 2 | `CLAUDE.md` | EDIT | Child-layout description only (lines 22, 33); master-side prose left |
| 3 | `templates/SHAMT_RULES.template.md` | EDIT | 14 child-context config/doc/proposals references |

---

## Step 1 — `CHEATSHEET.md`: rewrite the host-wiring layout diagram

**Operation:** EDIT
**File:** `CHEATSHEET.md`

**Occurrence (lines ~14–45) — the whole `<child-project>/` tree block.**
Locate:
```
<child-project>/
├── CLAUDE.md                       # rendered from SHAMT_RULES.template.md at init
├── CHEATSHEET.md                   # copy of this file
├── shamt-config.json               # initialized from shamt-config.example.json
├── ARCHITECTURE.md                 # required at init (template provided)
├── CODING_STANDARDS.md             # required at init (template provided)
├── shamt-core/                     # canonical sources pulled from master
│   ├── CLAUDE.md                   #   (master-dev primer)
│   ├── CHEATSHEET.md
│   ├── shamt-config.example.json
│   ├── init-shamt.sh               #   (re-init / inspection only — first install ran from master)
│   ├── import-shamt.sh             #   (pulls master HEAD for ongoing updates)
│   ├── scripts/regenerate-framework.sh
│   ├── templates/
│   ├── reference/
│   ├── host/templates/claude/
│   └── proposals/_template.md
├── .claude/
│   ├── commands/                   # rendered from shamt-core/host/templates/claude/commands/
│   ├── agents/                     # rendered persona definitions
│   ├── skills/                     # rendered auto-triggered skills
│   ├── statusline.sh               # rendered status-line script
│   └── settings.json               # statusLine entry patched by regen (rest is user-owned)
├── stories/                        # runtime — per-story artifacts
├── epics/                          # runtime — PO-flow artifacts (when used)
├── features/                       # runtime — PO-flow artifacts (when used)
├── proposals/                      # framework-update proposals (locally authored)
│   ├── _template.md                #   (master-owned — resynced by /import-shamt; do not edit locally)
│   ├── submitted/                  # submitted to master, awaiting decision
│   └── already-merged/             # came back via master sync (auto-moved on import)
└── code_reviews/                   # formal-mode review output
```
Replace:
```
<child-project>/
├── CLAUDE.md                       # rendered from SHAMT_RULES.template.md at init
│                                   #   (the ONLY Shamt file left at the project root)
├── .claude/                        # generated wiring (must stay at root — Claude Code requirement)
│   ├── commands/                   # rendered from .shamt-core/host/templates/claude/commands/
│   ├── agents/                     # rendered persona definitions
│   ├── skills/                     # rendered auto-triggered skills
│   ├── statusline.sh               # rendered status-line script
│   └── settings.json               # statusLine entry patched by regen (rest is user-owned)
├── .shamt-core/                    # all other Shamt-owned content (managed; do not hand-edit)
│   ├── CHEATSHEET.md               #   copy of this file
│   ├── shamt-config.json           #   initialized from shamt-config.example.json
│   ├── CLAUDE.md                   #   (master-dev primer)
│   ├── shamt-config.example.json
│   ├── init-shamt.sh               #   (re-init / inspection only — first install ran from master)
│   ├── import-shamt.sh             #   (pulls master HEAD for ongoing updates)
│   ├── scripts/regenerate-framework.sh
│   ├── templates/
│   ├── reference/
│   ├── host/templates/claude/
│   ├── project-specific-files/
│   │   ├── ARCHITECTURE.md         #   required at init (template provided)
│   │   └── CODING_STANDARDS.md     #   required at init (template provided)
│   └── proposals/                  # framework-update proposals (locally authored)
│       ├── _template.md            #   (master-owned — resynced by /import-shamt; do not edit locally)
│       ├── submitted/              # submitted to master, awaiting decision
│       └── already-merged/         # came back via master sync (auto-moved on import)
├── stories/                        # runtime — per-story artifacts
├── epics/                          # runtime — PO-flow artifacts (when used)
├── features/                       # runtime — PO-flow artifacts (when used)
└── code_reviews/                   # formal-mode review output
```

**Verification:**
- `grep -n '├── \.shamt-core/' CHEATSHEET.md` → 1 match.
- `grep -n 'project-specific-files/' CHEATSHEET.md` → ≥ 1 match (diagram).
- The diagram now shows exactly two root-level Shamt entries (`CLAUDE.md`, `.claude/`) plus runtime dirs (`stories/`, `epics/`, `features/`, `code_reviews/`).

---

## Step 2 — `CHEATSHEET.md`: sweep install / sync / config / regen prose

**Operation:** EDIT
**File:** `CHEATSHEET.md`

Each occurrence below repoints a child-side path. **Left unchanged (master-canonical):** line 60 ("Master's canonical sources under `shamt-core/`"), line 224 ("Lives in master's `shamt-core/`"), line 227 (`bash /path/to/shamt-core/init-shamt.sh` — first install runs from the master source), line 232 (self-host detection `<target>/shamt-core/init-shamt.sh`), line 252 ("Locates master's `shamt-core/`"), line 235 source side (`<source>/shamt-core/`).

**2a (line ~49) — footer-contract note.**
Locate:
```
Files with a `Managed by Shamt` footer (or files in `shamt-core/`'s master sync set) are owned by master / regen — they get overwritten by `import-shamt` and `/regen-framework`. Files outside that set are user-owned and preserved.
```
Replace:
```
Files with a `Managed by Shamt` footer (or files in `.shamt-core/`'s master sync set) are owned by master / regen — they get overwritten by `import-shamt` and `/regen-framework`. Files outside that set are user-owned and preserved.
```

**2b (line ~106) — PO-flow tracker plumbing config read.**
Locate:
```
Each one mirrors `/start-story`'s tracker plumbing per [INFRASTRUCTURE.md §1.11](../INFRASTRUCTURE.md#111-issue-tracker-integration-ado--github-cli): when the active profile (read from `shamt-config.json`) declares the matching work-item type
```
Replace:
```
Each one mirrors `/start-story`'s tracker plumbing per [INFRASTRUCTURE.md §1.11](../INFRASTRUCTURE.md#111-issue-tracker-integration-ado--github-cli): when the active profile (read from `.shamt-core/shamt-config.json`) declares the matching work-item type
```

**2c (line ~148) — architecture-impact flag note (repoint the two file names; leave the `**Architecture impact:**` label).**
Locate:
```
Both `/start-epic` and `/start-feature` consult `ARCHITECTURE.md` while drafting. If the epic/feature implies architectural change (new service, new boundary, new data store, new external integration, auth/tenant boundary shift, etc.), the agent flags it **inline** in `Scope / Non-Scope` as `**Architecture impact:** {one-line description}`. Omitted entirely otherwise. **Neither command consults `CODING_STANDARDS.md`** — coding style is irrelevant at these altitudes; the story-level Phase 6 / Phase 7 cycle handles coding-standards alignment for any eventual code changes.
```
Replace:
```
Both `/start-epic` and `/start-feature` consult `.shamt-core/project-specific-files/ARCHITECTURE.md` while drafting. If the epic/feature implies architectural change (new service, new boundary, new data store, new external integration, auth/tenant boundary shift, etc.), the agent flags it **inline** in `Scope / Non-Scope` as `**Architecture impact:** {one-line description}`. Omitted entirely otherwise. **Neither command consults `.shamt-core/project-specific-files/CODING_STANDARDS.md`** — coding style is irrelevant at these altitudes; the story-level Phase 6 / Phase 7 cycle handles coding-standards alignment for any eventual code changes.
```

**2d (line ~179) — submit-proposal sync table.**
Locate:
```
| `/submit-proposal {slug}` | Child | Prepare a validated proposal for upstream manual copy. Moves local copy to `proposals/submitted/`. | shipped |
```
Replace:
```
| `/submit-proposal {slug}` | Child | Prepare a validated proposal for upstream manual copy. Moves local copy to `.shamt-core/proposals/submitted/`. | shipped |
```

**2e (line ~180) — import-shamt sync table.**
Locate:
```
| `/import-shamt` | Child | Pull master HEAD via `shamt-core/import-shamt.sh`, then regen. | shipped |
```
Replace:
```
| `/import-shamt` | Child | Pull master HEAD via `.shamt-core/import-shamt.sh`, then regen. | shipped |
```

**2f (line ~200) — skill-wiring generation source (child view).**
Locate:
```
Skill wiring is generated from `shamt-core/host/templates/claude/skills/` during regen.
```
Replace:
```
Skill wiring is generated from `.shamt-core/host/templates/claude/skills/` during regen.
```

**2g (line ~206) — config section intro.**
Locate:
```
Per-project settings live in `shamt-config.json` at the project root. Initialize from `shamt-config.example.json` and edit (or let `init-shamt.sh` prompt you). Keys:
```
Replace:
```
Per-project settings live in `.shamt-core/shamt-config.json`. Initialize from `.shamt-core/shamt-config.example.json` and edit (or let `init-shamt.sh` prompt you). Keys:
```

**2h (line ~216) — doc-staleness key row.**
Locate:
```
| `doc_staleness_threshold_days` | integer (default 60) | `/audit-framework` D6: how stale `ARCHITECTURE.md` / `CODING_STANDARDS.md` can be |
```
Replace:
```
| `doc_staleness_threshold_days` | integer (default 60) | `/audit-framework` D6: how stale `.shamt-core/project-specific-files/ARCHITECTURE.md` / `.shamt-core/project-specific-files/CODING_STANDARDS.md` can be |
```

**2i (line ~233) — init behavior: halt condition.**
Locate:
```
- Halts if `<target>/shamt-config.json` already exists. Re-init is not supported; use `import-shamt.sh` for updates.
```
Replace:
```
- Halts if the install config already exists (`<target>/shamt-config.json` on self-host, `<target>/.shamt-core/shamt-config.json` otherwise). Re-init is not supported; use `import-shamt.sh` for updates.
```

**2i-2 (line ~234) — init behavior: config-field prompt.**
Locate:
```
- Prompts interactively for every `shamt-config.json` field (no flag-based unattended mode).
```
Replace:
```
- Prompts interactively for every `.shamt-core/shamt-config.json` field (no flag-based unattended mode).
```
(Consistent with 2g's child-default framing; the self-host root-vs-`.shamt-core/` split is documented in 2i / 2l. Repointing keeps Gate D — see Verification — at 0 rather than leaving a bare child-side `shamt-config.json` between 2i and 2j.)

**2j (line ~235) — init behavior: copy destination (repoint dest only; source stays master).**
Locate:
```
- Copies canonical sources from `<source>/shamt-core/` into `<target>/shamt-core/` (skipped on self-host).
```
Replace:
```
- Copies canonical sources from `<source>/shamt-core/` into `<target>/.shamt-core/` (skipped on self-host).
```

**2k (line ~236) — init behavior: doc seeding.**
Locate:
```
- Seeds top-level docs at `<target>/` when missing: `CLAUDE.md` (from `templates/SHAMT_RULES.template.md`), `CHEATSHEET.md`, `ARCHITECTURE.md` and `CODING_STANDARDS.md` (with `Last Updated` set to today), `proposals/_template.md`.
```
Replace:
```
- Seeds the child's `CLAUDE.md` at `<target>/` (from `templates/SHAMT_RULES.template.md`), and the two project-specific docs `ARCHITECTURE.md` + `CODING_STANDARDS.md` (with `Last Updated` set to today) under `<target>/.shamt-core/project-specific-files/`. `CHEATSHEET.md` and `proposals/_template.md` travel inside the `.shamt-core/` canonical-source copy — they are not separately seeded. Skipped on self-host.
```

**2l (line ~237) — init behavior: config write.**
Locate:
```
- Writes `<target>/shamt-config.json` from the prompted answers.
```
Replace:
```
- Writes the install config (`<target>/shamt-config.json` on self-host, `<target>/.shamt-core/shamt-config.json` otherwise) from the prompted answers. Ends with a copy/pastable completion prompt that drives an agent to fill in and `/validate-artifact` both project-specific docs.
```

**2m (line ~242) — import-shamt install location.**
Locate:
```
Installed at `<child>/shamt-core/import-shamt.sh` by `init-shamt.sh`. Invoked from the child:
```
Replace:
```
Installed at `<child>/.shamt-core/import-shamt.sh` by `init-shamt.sh`. Invoked from the child:
```

**2n (line ~245) — import-shamt invocation block.**
Locate:
```
bash <child>/shamt-core/import-shamt.sh [--target <dir>]
```
Replace:
```
bash <child>/.shamt-core/import-shamt.sh [--target <dir>]
```

**2o (line ~250) — import-shamt config read.**
Locate:
```
- Reads `master_url` from `<target>/shamt-config.json`.
```
Replace:
```
- Reads `master_url` from `<target>/.shamt-core/shamt-config.json`.
```

**2p (line ~253) — import-shamt overwrite destination.**
Locate:
```
- Overwrites every file in master's sync set into `<child>/shamt-core/` (subtree-level master-wins; not per-file footer-checked — see `commands/import-shamt.md` Notes).
```
Replace:
```
- Overwrites every file in master's sync set into `<child>/.shamt-core/` (subtree-level master-wins; not per-file footer-checked — see `commands/import-shamt.md` Notes).
```

**2q (line ~255) — import-shamt already-merged move.**
Locate:
```
- Auto-moves child-local proposals whose slugs match a file in master's `proposals/archive/` into `<child>/proposals/already-merged/{slug}.md`.
```
Replace:
```
- Auto-moves child-local proposals whose slugs match a file in master's `proposals/archive/` into `<child>/.shamt-core/proposals/already-merged/{slug}.md`.
```

**2r (line ~263) — regen section intro (child view: both script path and canonical wiring source).**
Locate:
```
`shamt-core/scripts/regenerate-framework.sh` renders canonical Claude wiring (`shamt-core/host/templates/claude/`) into a child project's `.claude/` directory. Bash-first per [INFRASTRUCTURE.md §1.6](../INFRASTRUCTURE.md#16-scripts-regen--framework-maintenance); a PowerShell wrapper may follow later.
```
Replace:
```
`.shamt-core/scripts/regenerate-framework.sh` renders canonical Claude wiring (`.shamt-core/host/templates/claude/`) into a child project's `.claude/` directory. Bash-first per [INFRASTRUCTURE.md §1.6](../INFRASTRUCTURE.md#16-scripts-regen--framework-maintenance); a PowerShell wrapper may follow later.
```

**2s (line ~281) — regen footer-contract comparison.**
Locate:
```
`import-shamt.sh` uses a different, simpler rule for the `shamt-core/` subtree: subtree-level master-wins for the explicit sync set, preserve everything else. The per-file footer check is `regenerate-framework.sh`'s discipline for `.claude/`, not `import-shamt.sh`'s for `shamt-core/`. See `commands/import-shamt.md` Notes.
```
Replace:
```
`import-shamt.sh` uses a different, simpler rule for the `.shamt-core/` subtree: subtree-level master-wins for the explicit sync set, preserve everything else. The per-file footer check is `regenerate-framework.sh`'s discipline for `.claude/`, not `import-shamt.sh`'s for `.shamt-core/`. See `commands/import-shamt.md` Notes.
```

**2t (line ~298) — status-line phase-detection config note.**
Locate:
```
Phase detection (story altitude only) cascades from latest-stage artifact. Numbers depend on `shamt-config.json` `testing`:
```
Replace:
```
Phase detection (story altitude only) cascades from latest-stage artifact. Numbers depend on `.shamt-core/shamt-config.json` `testing`:
```

**Verification (CHEATSHEET.md):**
- `grep -nE '(^|[^./a-z-])shamt-config\.json' CHEATSHEET.md | grep -v 'shamt-config\.example' | grep -v '─'` → 0 matches. (The `| grep -v '─'` drops the Step-1 layout-diagram tree-node lines, which show bare `shamt-config.json` under its `.shamt-core/` parent node — correct diagram representation, not a prose miss.)
- `grep -nE '(^|[^./a-z-])ARCHITECTURE\.md|(^|[^./a-z-])CODING_STANDARDS\.md' CHEATSHEET.md | grep -v '\.shamt-core/project-specific-files' | grep -v '─'` → 0 matches. (Two exclusions, mirroring the parent global Gate E: `| grep -v '\.shamt-core/project-specific-files'` drops the correctly-repointed prose lines whose bare doc filenames are qualified by the directory elsewhere on the same line — e.g. the 2k seed line "`ARCHITECTURE.md` + `CODING_STANDARDS.md` … under `<target>/.shamt-core/project-specific-files/`", plus 2c/2h; `| grep -v '─'` drops the Step-1 layout-diagram tree nodes for the two docs under `.shamt-core/project-specific-files/`. The `**Architecture impact:**` prose label never matches the regex.)
- `grep -nE 'shamt-core/import-shamt\.sh|shamt-core/scripts/regenerate' CHEATSHEET.md | grep -v '\.shamt-core'` → 0 matches.
- Master-canonical lines preserved: `grep -n "master's \`shamt-core/\`\|/path/to/shamt-core/init-shamt.sh\|<target>/shamt-core/init-shamt.sh\|<source>/shamt-core/\|Master's canonical sources under \`shamt-core/\`" CHEATSHEET.md` → still present.

> **On the `─` exclusion character (read before running the greps).** In `| grep -v '─'`, the `─` is **U+2500 BOX DRAWINGS LIGHT HORIZONTAL** — the exact glyph the tree diagram's `├──` / `└──` connectors are built from. It is **not** an ASCII hyphen (`-`/`0x2D`). Verify with `sed -n '18p' CHEATSHEET.md | xxd` on the pre-edit file: the connector bytes are `e2 94 9c e2 94 80 e2 94 80` (├ ─ ─). Because every diagram node line contains `─` and no prose line does, `grep -v '─'` reliably drops exactly the diagram node lines (confirmed by a live run: it removes the `ARCHITECTURE.md` / `CODING_STANDARDS.md` / `shamt-config.json` tree nodes and nothing else). When copying these commands, preserve the literal `─`; do not retype it as hyphens.
>
> **Parent-plan gate note (cross-artifact).** The post-execution global Gate D / Gate E greps in [`dot-shamt-core-layout_PLAN.md`](dot-shamt-core-layout_PLAN.md) run the same regexes across `CHEATSHEET.md` **without** the `| grep -v '─'` diagram exclusion, so they will surface this Step-1 diagram's `ARCHITECTURE.md` / `CODING_STANDARDS.md` tree nodes (and would only avoid the `shamt-config.json` node by the coincidental `shamt-config.example` filter). Those gates need the same `| grep -v '─'` exclusion (or an explicit diagram-node allow-list entry) before they read clean — flagged for parent-plan follow-up and re-validation; not fixable from this phase file.

---

## Step 3 — `CLAUDE.md` (master-dev primer): update the child-layout description only

**Operation:** EDIT
**File:** `CLAUDE.md`

This file is the master-dev primer. Its master-side framework-update prose (`proposals/{slug}.md` at lines 43/48/50; the master `shamt-core/` tree diagram at lines 14/19) describes the **master** repo and is **left unchanged** per the scope boundary. Only the two child-layout-describing sentences change.

**3a (line ~22) — "what a child install produces" paragraph.**
Locate:
```
A child project that installs Shamt ends up with a `.claude/` directory generated from `host/templates/claude/`, a managed section in its `CLAUDE.md` rendered from `SHAMT_RULES.template.md`, a copy of `CHEATSHEET.md`, and a `shamt-config.json` initialized from the example.
```
Replace:
```
A child project that installs Shamt keeps just two Shamt entries at its project root — `CLAUDE.md` (a managed section rendered from `SHAMT_RULES.template.md`) and the generated `.claude/` directory (which Claude Code requires at the root). Everything else lives under a hidden `.shamt-core/` directory: the copied canonical sources, `shamt-config.json` (initialized from the example), `CHEATSHEET.md`, the `proposals/` working area, and `project-specific-files/{ARCHITECTURE,CODING_STANDARDS}.md`.
```

**3b (line ~33) — the "Generated" surface table row.**
Locate:
```
| Generated | A child project's `.claude/`, its managed-section `CLAUDE.md`, its installed `CHEATSHEET.md` | Never edited directly | Regenerated from canonical sources |
```
Replace:
```
| Generated | A child project's `.claude/`, its managed-section `CLAUDE.md`, its installed `.shamt-core/CHEATSHEET.md` | Never edited directly | Regenerated from canonical sources |
```

**Verification:**
- `grep -n '\.shamt-core/' CLAUDE.md` → 2 matches (lines ~22, ~33).
- `grep -n 'proposals/{slug}.md\|proposals/archive/{slug}.md' CLAUDE.md` → still 2 matches (master-side prose untouched, lines ~43/48).

---

## Step 4 — `templates/SHAMT_RULES.template.md`: sweep child-context config / doc / proposals references

**Operation:** EDIT
**File:** `templates/SHAMT_RULES.template.md`

This template renders into the child's `CLAUDE.md`, so its path references are child-context. **Left unchanged (master-canonical):** line 6 ("Edit only here, in `shamt-core/templates/`" — directs framework devs to master), line 433 ("Edit canonical sources in `shamt-core/`" — the framework-maintenance principle targets master's canonical tree).

**4a (line ~24) — files list: CHEATSHEET pointer (B3-specific).**
Locate:
```
- `CHEATSHEET.md` — host wiring quick reference (commands, skills, personas).
```
Replace:
```
- `.shamt-core/CHEATSHEET.md` — host wiring quick reference (commands, skills, personas).
```

**4b (line ~29) — files list: proposals.**
Locate:
```
- `proposals/` — framework-update proposals.
```
Replace:
```
- `.shamt-core/proposals/` — framework-update proposals.
```

**4c (line ~30) — files list: config.**
Locate:
```
- `shamt-config.json` — per-project configuration (tracker, testing opt-in, etc.).
```
Replace:
```
- `.shamt-core/shamt-config.json` — per-project configuration (tracker, testing opt-in, etc.).
```

**4d (line ~113) — testing-enabled config read.**
Locate:
```
When `shamt-config.json` sets `testing: "enabled"`, a **Phase 5: Test** is inserted between Build and Review.
```
Replace:
```
When `.shamt-core/shamt-config.json` sets `testing: "enabled"`, a **Phase 5: Test** is inserted between Build and Review.
```

**4e (line ~135) — TODO gate, CODING_STANDARDS.**
Locate:
```
If `CODING_STANDARDS.md` is stricter, follow it.
```
Replace:
```
If `.shamt-core/project-specific-files/CODING_STANDARDS.md` is stricter, follow it.
```

**4f (line ~138) — Standards check invariant.**
Locate:
```
- **Standards check.** `ARCHITECTURE.md` and `CODING_STANDARDS.md` are governing references for artifacts and reviews. Note absence only if either file does not exist.
```
Replace:
```
- **Standards check.** `.shamt-core/project-specific-files/ARCHITECTURE.md` and `.shamt-core/project-specific-files/CODING_STANDARDS.md` are governing references for artifacts and reviews. Note absence only if either file does not exist.
```

**4g (line ~159) — Pattern 1 Step 2 alignment check.**
Locate:
```
**Step 2 — Identify issues across dimensions.** First check alignment with `ARCHITECTURE.md` and `CODING_STANDARDS.md`.
```
Replace:
```
**Step 2 — Identify issues across dimensions.** First check alignment with `.shamt-core/project-specific-files/ARCHITECTURE.md` and `.shamt-core/project-specific-files/CODING_STANDARDS.md`.
```

**4h (line ~205) — Pattern 3 Step 2 targeted research.**
Locate:
```
**Step 2 — Targeted research.** Scope research to ticket references, not a broad exploration: grep referenced files / functions / features; read `ARCHITECTURE.md` and `CODING_STANDARDS.md`; skim related code. Record detailed findings in `context.md` (Standard path) or `spec.md` Evidence (Quick path).
```
Replace:
```
**Step 2 — Targeted research.** Scope research to ticket references, not a broad exploration: grep referenced files / functions / features; read `.shamt-core/project-specific-files/ARCHITECTURE.md` and `.shamt-core/project-specific-files/CODING_STANDARDS.md`; skim related code. Record detailed findings in `context.md` (Standard path) or `spec.md` Evidence (Quick path).
```

**4i (line ~256) — formal-mode review base resolution.**
Locate:
```
Resolve the review base in this order: explicit user-provided base; active PR target branch when available; project default formal-review base from `ARCHITECTURE.md`; repository default branch otherwise.
```
Replace:
```
Resolve the review base in this order: explicit user-provided base; active PR target branch when available; project default formal-review base from `.shamt-core/project-specific-files/ARCHITECTURE.md`; repository default branch otherwise.
```

**4j (line ~309) — implementation-plan CODING_STANDARDS mapping.**
Locate:
```
- `CODING_STANDARDS.md`: map each applicable rule to an existing step, new step, or explicit N/A in `## CODING_STANDARDS Compliance`; merely saying it was read is insufficient.
```
Replace:
```
- `.shamt-core/project-specific-files/CODING_STANDARDS.md`: map each applicable rule to an existing step, new step, or explicit N/A in `## CODING_STANDARDS Compliance`; merely saying it was read is insufficient.
```

**4k (line ~332) — research-once digest rule.**
Locate:
```
- Read `ARCHITECTURE.md` and `CODING_STANDARDS.md` once during research, record story-specific standards digest inline, and reuse the digest.
```
Replace:
```
- Read `.shamt-core/project-specific-files/ARCHITECTURE.md` and `.shamt-core/project-specific-files/CODING_STANDARDS.md` once during research, record story-specific standards digest inline, and reuse the digest.
```

**4l (line ~374) — Phase 1 Intake tracker-id config.**
Locate:
```
Ask for slug; resolve optional issue-tracker ID per `shamt-config.json`; derive a 2–4 word brief description; check for slug collision; fetch tracker payload or capture manual content; confirm.
```
Replace:
```
Ask for slug; resolve optional issue-tracker ID per `.shamt-core/shamt-config.json`; derive a 2–4 word brief description; check for slug collision; fetch tracker payload or capture manual content; confirm.
```

**4m (line ~384) — Phase 6 Review Documentation Impact.**
Locate:
```
Story-mode review includes the Plan Alignment pre-pass and a Documentation Impact Assessment (does this change require an `ARCHITECTURE.md` or `CODING_STANDARDS.md` update? If yes, the update is part of Polish).
```
Replace:
```
Story-mode review includes the Plan Alignment pre-pass and a Documentation Impact Assessment (does this change require an `.shamt-core/project-specific-files/ARCHITECTURE.md` or `.shamt-core/project-specific-files/CODING_STANDARDS.md` update? If yes, the update is part of Polish).
```

**4n (line ~386) — Phase 7 Polish root-cause proposals.**
Locate:
```
Root-cause proposals that generalize beyond the current story route through the framework-update flow at `proposals/{slug}.md` rather than direct edits.
```
Replace:
```
Root-cause proposals that generalize beyond the current story route through the framework-update flow at `.shamt-core/proposals/{slug}.md` rather than direct edits.
```

**Verification (SHAMT_RULES.template.md):**
- `grep -nE '(^|[^./a-z-])shamt-config\.json' templates/SHAMT_RULES.template.md` → 0 matches.
- `grep -nE '(^|[^./a-z-])ARCHITECTURE\.md|(^|[^./a-z-])CODING_STANDARDS\.md' templates/SHAMT_RULES.template.md` → 0 matches.
- `grep -nE '(^|[^./a-z-])proposals/\{slug\}\.md' templates/SHAMT_RULES.template.md` → 0 matches.
- Master-canonical lines preserved: `grep -n 'shamt-core/templates/\|Edit canonical sources in \`shamt-core/\`' templates/SHAMT_RULES.template.md` → 2 matches (lines ~6, ~433).

---

## Cross-check vs Proposed Changes (Phase 2 coverage)

| Proposal row | Covered by |
|---|---|
| B1 (`CHEATSHEET.md` — layout diagram, install/sync paths, config/proposals/project-specific-files locations, completion-prompt note) | Steps 1–2 |
| B2 (`CLAUDE.md` — child-layout description) | Step 3 |
| B3 (`SHAMT_RULES.template.md` — doc/config refs, `:24` CHEATSHEET pointer, proposals-path) | Step 4 |

---

Validated 2026-05-28 — 4 rounds, 1 adversarial sub-agent confirmed. Fixes this loop: **F1** added sub-step **2i-2** for the omitted CHEATSHEET.md `shamt-config.json` field-prompt reference (line ~234); **F2/F3** corrected the CHEATSHEET.md Verification block — Step-1's new layout diagram introduces bare `ARCHITECTURE.md` / `CODING_STANDARDS.md` / `shamt-config.json` tree nodes under their `.shamt-core/` parents, so the doc-gate grep gained `| grep -v '\.shamt-core/project-specific-files' | grep -v '─'` (mirroring the parent global Gate E) and the config-gate grep gained `| grep -v '─'`. A first adversarial sub-agent raised a `─`-vs-ASCII-hyphen concern that was **disproven empirically** (`xxd` shows the diagram connectors are U+2500 box-drawing chars; a live `grep -v '─'` filters the node lines) — that prompted a clarifying note pinning the character down, after which a second sub-agent independently confirmed zero issues. Cross-artifact flag recorded: the parent plan's post-execution global Gate D/E greps need the same `| grep -v '─'` diagram exclusion before they read clean.
