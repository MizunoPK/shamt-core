# Proposal: rename-cheatsheet-to-readme

**Created:** 2026-06-07
**Status:** Implemented
**Number:** 07
**Proposed by:**
**Project context:**

---

## Problem

`shamt-core` has **no `README.md`** — the repo has no conventional landing page (GitHub renders nothing as the front page). The hand-written quick-reference `CHEATSHEET.md` (commands + skills + personas) is the most README-like document the repo carries, but it lives under a non-standard name. Renaming `CHEATSHEET.md` → `README.md` gives the repo a proper front page with zero new content to write.

This is a **pure rename** (user choice, 2026-06-07): the content is kept verbatim; only the filename changes, and every reference to it across the canonical surface is repointed. The file **continues to sync into child projects** (user choice) — the master/child sync set arrays in `init-shamt.sh` / `import-shamt.sh` are updated from `"CHEATSHEET.md"` to `"README.md"`, so children receive `.shamt-core/README.md` going forward.

**Reference surface.** A whole-repo grep (excluding `proposals/archive/` and `.claude/`) finds `CHEATSHEET.md` referenced by **13 files beyond the doc itself**: the dev primer `CLAUDE.md` (×4), the rules template, the proposal template, four host commands (`f1`/`f3`/`f5`/`sync-import`) and two skills (`f3`/`sync-import`), a tracker reference doc, `shamt-config.example.json`, and **both root scripts' sync-set arrays** (`init-shamt.sh`, `import-shamt.sh`). All carry the filename and must repoint for the rename to be coherent. Total **14 files** (the MOVE + 13 reference-carriers) → **> 10, so Phase 3 is required.**

---

## Proposed Changes

**Pure rename.** `git mv CHEATSHEET.md README.md`; the content (including its `# Shamt — Cheatsheet` title and the word "cheatsheet" where it describes the *content type*) stays — only the **filename** changes everywhere. Repoint every `CHEATSHEET.md` filename / path / markdown-link reference to `README.md`; the few **bare-noun** mentions that name the doc (e.g. f5's "the CHEATSHEET table") become "README". The host-body rows (5–10) regenerate into `.claude/` via `/f4-regen-framework`; the root-doc / template / reference / script / config rows do not regenerate and land on next `/sync-import-shamt`.

| # | Canonical path | Operation | One-line change description |
|---|----------------|-----------|------------------------------|
| 1 | `CHEATSHEET.md` → `README.md` | MOVE + EDIT | `git mv CHEATSHEET.md README.md`, then repoint the moved file's **2 internal `CHEATSHEET.md` filename self-references** → `README.md`: the child-layout tree-diagram row (line 24: `│   ├── CHEATSHEET.md   # copy of this file` → `│   ├── README.md   # copy of this file`) and the init-shamt seeding prose (line 238: `` `CHEATSHEET.md` and `proposals/_template.md` travel inside… `` → `` `README.md` ``). The `# Shamt — Cheatsheet` title and the word "cheatsheet" (content-type wording) stay — only filename references change. |
| 2 | `CLAUDE.md` | EDIT | Repoint the 4 `CHEATSHEET.md` references → `README.md`: the §intro pointer (line 3), the `what lives here` tree-diagram row (line 14: `├── CHEATSHEET.md` → `├── README.md`), the install-layout list (line 22), and the two-surfaces table's `.shamt-core/CHEATSHEET.md` (line 33). |
| 3 | `templates/SHAMT_RULES.template.md` | EDIT | Line 24 `.shamt-core/CHEATSHEET.md` → `.shamt-core/README.md` (host-wiring quick-reference pointer). |
| 4 | `proposals/_template.md` | EDIT | Line 110 canonical-roots list `shamt-core/CHEATSHEET.md` → `shamt-core/README.md`. |
| 5 | `host/templates/claude/commands/f1-propose-update.md` | EDIT | Line 100 canonical-roots list `shamt-core/CHEATSHEET.md` → `shamt-core/README.md`. |
| 6 | `host/templates/claude/commands/f3-implement-update.md` | EDIT | Line 56 canonical-roots list `shamt-core/CHEATSHEET.md` → `shamt-core/README.md`. |
| 7 | `host/templates/claude/commands/f5-audit-framework.md` | EDIT | Line 140 "persona counts in the CHEATSHEET table" → "…in the README table" (bare-noun doc reference). |
| 8 | `host/templates/claude/commands/sync-import-shamt.md` | EDIT | Line 60 sync-set list `(\`CLAUDE.md\`, \`CHEATSHEET.md\`, …)` → `README.md`. |
| 9 | `host/templates/claude/skills/f3-implement-update/SKILL.md` | EDIT | Line 33 canonical-roots list `CHEATSHEET.md` → `README.md` (mirrors row 6). |
| 10 | `host/templates/claude/skills/sync-import-shamt/SKILL.md` | EDIT | Line 48 sync-set list `CHEATSHEET.md` → `README.md` (mirrors row 8). |
| 11 | `reference/trackers/_contract.md` | EDIT | Line 67 markdown link `[CHEATSHEET.md](../../CHEATSHEET.md)` → `[README.md](../../README.md)` (both link text and target). |
| 12 | `shamt-config.example.json` | EDIT | Line 2 `"…marked optional in shamt-core/CHEATSHEET.md."` → `shamt-core/README.md`. |
| 13 | `init-shamt.sh` | EDIT | The sync-set array entry (line 281) `"CHEATSHEET.md"` → `"README.md"`, and the comment (line 24) `# CHEATSHEET.md and proposals/_template.md travel inside this set` → `README.md`. |
| 14 | `import-shamt.sh` | EDIT | The sync-set array entry (line 212) `"CHEATSHEET.md"` → `"README.md"`. |

Row count: **14 > 10 → Phase 3 (`/f2-plan-update-implementation`) required.**

**Paired files:** rows 6↔9 (`f3` command↔skill) and rows 8↔10 (`sync-import` command↔skill) are command↔skill pairs — both repoint together. Rows 13↔14 (`init-shamt.sh` / `import-shamt.sh`) carry the **same sync-set array** and must change together (a half-renamed sync set would copy the wrong filename).

---

## Risks

- **Sync-set integrity (the load-bearing one)** — the rename is only coherent if **both** `init-shamt.sh` and `import-shamt.sh` sync-set arrays change from `"CHEATSHEET.md"` to `"README.md"` together. If one is missed, `import-shamt` would either fail to copy the renamed file or copy a non-existent `CHEATSHEET.md`. Validation must confirm both arrays repoint (rows 13–14).
- **Child orphan-on-rename** — `import-shamt` **overwrites but does not prune** (no `rsync --delete`; verified in `import-shamt.sh`). A child that previously imported `.shamt-core/CHEATSHEET.md` keeps that **stale orphan copy** *and* gains `.shamt-core/README.md` on the next import. No breakage — the old copy is simply uncited — but children carry both until they delete the old one manually (or a future `import-shamt` gains pruning). Acceptable per the keep-syncing decision.
- **`.shamt-core/README.md` oddity** — a `README.md` inside the hidden `.shamt-core/` import dir is slightly unconventional (READMEs usually sit at a project root). Harmless: it does not collide with a child's own top-level `README.md` (different directory) and is purely documentation.
- **Regression risk** — none functional. Every edit is a filename / path / link string; the file content and all executable instructions are unchanged.
- **Drift risk** — host-body rows (5–10) need `/f4-regen-framework` (Phase 5); skipping regen leaves the generated `.claude/` bodies pointing at the old name (a D1 finding next audit), mechanically caught by `--check`. Root-doc / template / reference / script / config rows do not regenerate.
- **Self-reference / title** — the moved file keeps its `# Shamt — Cheatsheet` title and any "cheatsheet" content wording (it remains a cheatsheet; only the filename changes), but it carries **2 internal `CHEATSHEET.md` *filename* self-references** (the tree-diagram at line 24 and the seeding prose at line 238) that **do** repoint to `README.md` — captured in row 1's MOVE + EDIT. Missing them would leave the renamed file pointing at its own old name (a self-broken reference the completeness grep catches). Verify the MOVE does not strip the validation footer the doc carries.
- **Open-questions debt** — the two load-bearing decisions (pure rename vs reframe; keep-syncing vs repo-front-page-only) are resolved below; none deferred.

---

## Rollback Plan

`git revert <commit-sha>` restores `CHEATSHEET.md` and all reference edits, then `/f4-regen-framework` re-propagates the host bodies. Children pick up the reverted name on the next `/sync-import-shamt` (and keep the harmless `.shamt-core/README.md` orphan from the brief window, symmetric to the forward orphan). No data loss.

---

## Validation Considerations

- **Reference completeness (highest-risk)** — after the edits, `grep -rn "CHEATSHEET" .` (excluding `proposals/archive/`, `proposals/rejected/`, and this proposal) must return **zero** results. Any surviving `CHEATSHEET` reference = a missed repoint (broken link or stale path). Re-grep across `host/templates/claude/`, `templates/`, `reference/`, root docs, `*.sh`, `*.json`.
- **Sync-set parity** — confirm `init-shamt.sh` and `import-shamt.sh` **both** list `"README.md"` (not `"CHEATSHEET.md"`) in their sync-set arrays (rows 13–14); these are the load-bearing executable references.
- **Command↔skill pairing** — rows 6↔9 and 8↔10 must repoint together; an unpaired edit reintroduces an inconsistency the next D2 audit flags.
- **Markdown-link target** — row 11's `_contract.md` link must repoint **both** the link text and the relative target (`(../../CHEATSHEET.md)` → `(../../README.md)`), and the new target must resolve on disk after the MOVE.
- **Affected surfaces** — root docs (`README.md`, `CLAUDE.md`, `shamt-config.example.json`), the rules + proposal templates, four host commands + two skills, one reference doc, and the two root scripts. The two root scripts (`init-shamt.sh`, `import-shamt.sh`) are canonical sources outside the usual `scripts/` root — **justified here** because they carry the load-bearing sync-set arrays the rename depends on. No personas; `scripts/regenerate-framework.sh` is unaffected (it does not reference `CHEATSHEET.md`).
- **Propagation plan** — `/f4-regen-framework` after Phase 4 for the host-body rows; root-doc / template / reference / script / config rows land on next `/sync-import-shamt`. **14 rows > 10 → Phase 3 plan required.**

---

## Open Questions

(none remaining)

---

## Resolved Questions

<!-- Drafting-only log -->

- ~~Q (load-bearing): pure rename, or reframe the content into a conventional README (overview / install at the top, cheatsheet below)?~~ → A: **Pure rename** (user choice, 2026-06-07). Keep the content verbatim; only the filename changes + all references repoint. A content reframe is a separate authoring effort, out of scope here.
- ~~Q (load-bearing): after the rename, keep syncing the doc to child projects, or make `README.md` shamt-core's repo front page only (drop it from the child sync set)?~~ → A: **Keep syncing** (user choice, 2026-06-07). Update both sync-set arrays to `"README.md"`; children receive `.shamt-core/README.md`. (A `README.md` inside the hidden `.shamt-core/` dir is slightly odd but harmless and does not collide with a child's own root README.)

---
Validated 2026-06-07 — 2 rounds, 1 adversarial sub-agent confirmed
