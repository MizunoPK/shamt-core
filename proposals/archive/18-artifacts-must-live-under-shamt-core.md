# Proposal: artifacts-must-live-under-shamt-core

**Created:** 2026-06-11
**Status:** Implemented
**Number:** 18
**Proposed by:** [master-local]
**Project context:** [master-local]

---

## Problem

A child project was observed creating `epics/`, `features/`, and `stories/`
folders at its **repo root** — polluting the child's source tree and violating
the layout contract `CLAUDE.md` states plainly: *"the only Shamt thing permitted
at the child project root is the managed-section `CLAUDE.md` and the generated
`.claude/` directory; everything else lives under a hidden `.shamt-core/`
directory."*

This is not a one-off agent mistake — it is what the **current canonical
commands produce**. The `dot-shamt-core-layout` change (archived) moved the
*install-time* Shamt-owned files under `.shamt-core/` (config, `proposals/`,
`project-specific-files/`, the framework tree) and drew an explicit scope
boundary: **child installs are `.shamt-core/`-relative; the master / self-host
keeps root-relative paths.** But it **did not cover the runtime PO/Engineer work
tree**. So today every PO/Engineer command body, the rules file, and the
statusline still address the work tree with **bare root-relative paths**:

- `templates/SHAMT_RULES.template.md` — §PO-tree resolution, the Quick/Standard
  path-map tables, Global Story Invariants, and Core files all write `epics/…`,
  `features/…`, `stories/…` (root-relative). `proposals/` is correctly
  `.shamt-core/proposals/`, but the work tree is not.
- `host/templates/claude/commands/{p1…p6,e1…e8}.md` (+ mirroring skills) — resolve
  and write `epics/{ID}-…/`, `stories/{ID}-…/`, `features/…/` at the root (e.g.
  `e1-start-story.md:43,73,87`; `p1-start-epic.md:43,63,95`).
- `host/templates/claude/statusline.sh` — resolves the active tree from
  `.shamt-state/active-{epic,feature,story}` pointer paths shaped
  `epics/<e>/features/<f>/stories/<s>/` (root-relative).
- `e6-review-changes` formal mode writes `code_reviews/<branch>/` at the root.
- `init-shamt.sh` **and** `import-shamt.sh` both seed the standing Tech Stories
  epic at root-relative `epics/tech-stories/…` (`init-shamt.sh:493`
  `$root/epics/tech-stories`; `import-shamt.sh:374` `$TARGET_DIR/epics/tech-stories`)
  — both must seed under the work root in a child. `import-shamt.sh` already
  **preserves anything outside its sync set** (`:14`, `:289–290`), so the
  relocated work tree is preserved by default — it must simply never be added to
  the sync set.

The fix is to **finish what `dot-shamt-core-layout` started** and apply the
containment rule **uniformly and absolutely**: in a child, the **only** Shamt
entries at the project root are `CLAUDE.md` (the managed rules file) and
`.claude/` (forced to the root by Claude Code — it cannot move). **Everything
else lives under `.shamt-core/`** — canonical sources, config, `proposals/`, the
PO/Engineer work tree (`epics/`, `features/`, `stories/`, `code_reviews/`),
**and the `.shamt-state/` active-item pointers** — all resolving
**`.shamt-core/`-relative in a child** while the master / self-host keeps
root-relative paths. The work root is resolved by **each layer's existing
child-vs-self-host mechanism** (the framework already detects this three ways, by
layer — there is no single uniform signal to invent):
- **agent-run command/skill bodies** — the `/f1`/`/f4`-style signal (self-host iff
  a top-level `proposals/` + canonical roots at the repo root; an installed
  `.shamt-core/` = child) (`f4-regen-framework.md:29`);
- **`statusline.sh`** — keys off `.shamt-core/` presence (it already reads
  `.shamt-core/shamt-config.json`, `:51`);
- **`init-shamt.sh`** — its existing realpath-based `SELF_HOST` flag (`:13–15`);
  the relocation is gated on it.
- **`import-shamt.sh`** — inherently child-side (no detection needed).

**`.shamt-state/` is NOT an exception.** `#14` placed the pointers at the root
solely to dodge `import-shamt` clobbering them — but this proposal already
requires `import-shamt` to **preserve** child-owned content under `.shamt-core/`
(it already preserves `.shamt-core/proposals/` drafts; the relocated work tree
and `.shamt-state/` join that preserved set). With preservation handled, the
root carve-out is unnecessary, so `.shamt-state/` moves under `.shamt-core/` too
and the rule has no special cases. The framework must not produce **any**
root-level Shamt artifact in a child beyond the two forced exceptions.

**Reconciliation (not duplication):** this extends `dot-shamt-core-layout`'s
established boundary to the work tree and is consistent with `#14
po-nested-folder-layout` (which nests the PO tree but is silent on the tree's
*base* directory). It does not re-litigate either.

---

## Proposed Changes

**Mechanism (resolved OQ1):** introduce a single **Shamt work root** convention
— the repo root on master/self-host, `.shamt-core/` in a child — resolved per
layer by each layer's existing child-vs-self-host mechanism (enumerated in the
Problem; no single new signal). All `epics/`, `features/`, `stories/`,
`code_reviews/`, and `shamt-state/` paths are work-root-relative; **bodies keep
their bare paths** (the 293 bare work-tree mentions across 91 command/skill/
agent/template/reference files are reinterpreted by the convention — **not
edited**), and each flow resolves the work root once. No per-path `.shamt-core/`
prefixing, no legacy/root fallback. Per the resolved enforcement decision, the
convention is reinforced with short reminders at the **2–3 highest-traffic
resolution points** every body defers to (Global Story Invariants "Story folder
resolution" + the §PO-tree resolution heading, plus the `review-executor`
`code_reviews/` writer), rather than touching all ~28 bodies.

Concrete edit set (`/f3` implements inline — see "Phase 3 not required" below):

| File | Op | What |
|---|---|---|
| `templates/SHAMT_RULES.template.md` | EDIT | Add the **Shamt work root** convention statement (in §PO-tree resolution): `epics/`, `features/`, `stories/`, `code_reviews/`, `shamt-state/` are work-root-relative (`.` self-host / `.shamt-core/` child). Update the §PO-tree **Active-item pointers** paragraph (pointers at `{work-root}/shamt-state/`, work-root-relative content) + Core files. Add the **high-traffic reminders** to the Global Story Invariants "Story folder resolution" bullet + the §PO-tree heading. **D12: re-measure at `/f3`; compensating trim if the convention line breaches the ~146-char margin.** |
| `host/templates/claude/statusline.sh` | EDIT | Bash (doesn't apply the convention): resolve the work root (root self-host / `.shamt-core/` child, via `.shamt-core/` presence); read pointers from `{work-root}/shamt-state/active-{epic,feature,story}`; prepend the work root when resolving the folder on disk. |
| `host/templates/claude/agents/review-executor.md` | EDIT | High-traffic reminder: the formal-mode `code_reviews/<sanitized-branch>/` output is work-root-relative (`.shamt-core/` in a child). (A sub-agent persona — reinforces the convention at the sole `code_reviews/` writer.) |
| `init-shamt.sh` | EDIT | In a child (gated `SELF_HOST -eq 0`), seed the standing **Tech Stories** epic under `.shamt-core/` (`:493` `$root/epics/tech-stories` → work root); create `.shamt-core/shamt-state/` on demand. Self-host path unchanged. |
| `import-shamt.sh` | EDIT | Relocate import-shamt's own Tech Stories seed (`:374` `$TARGET_DIR/epics/tech-stories`) under `.shamt-core/`. Work tree + `shamt-state/` are already preserved by default (outside the sync set — `:14`, `:289–290`); ensure they are **never** added to the sync set and preserve without spurious warnings. |
| `CLAUDE.md` (root canonical doc) | EDIT | State the uniform containment rule: in a child the only root entries are `CLAUDE.md` + `.claude/`; the work tree + `shamt-state/` join the enumerated `.shamt-core/` contents. |
| `README.md` | EDIT | Fix the absolute-location claim at `:161` (`.shamt-state/active-*` described as "root-level") → `{work-root}/shamt-state/`; confirm `:16`'s "only Shamt file at the project root" statement stays consistent. |

**Convention-covered — NO edit (verified):** the ~28 `p1…p6` / `e1…e8`
command+skill bodies and the `reference/trackers/*.md` raw-payload paths keep
their bare `epics/`/`stories/`/`code_reviews/` paths (they resolve "per §PO-tree
resolution" or use bare inline globs — both reinterpreted by the convention).
Reconcile the `reference/trackers/*.md` + `README.md` touch with the pending
`sync-tracker-refs-readme-to-ticket-id-naming` proposal so the two don't collide.

**Phase 3 not required.** 7 concrete files ≤ 10 → `/f3-implement-update` reads
this proposal directly and applies the edits inline (no
`/f2-plan-update-implementation` decomposition). `/f2` was invoked and **declined**
on the mechanism-A re-scope: the original area-level table's command/skill-body
rows are covered by the global convention, not per-path edits.

---

## Risks

- **`import-shamt` data loss (HIGH).** `import-shamt` **preserves outside-sync-set
  content by default**, so the relocated work tree + `shamt-state/` are safe by
  design — the residual risk is a *misimplementation* that adds the work tree to
  the sync set (→ overwritten) or a deletion path that reaches outside it.
  *Mitigation:* never add the work tree to the sync set; the import-shamt
  preservation test (Validation Considerations) simulates a sync against a
  populated work tree and asserts zero loss.
- **Statusline regression.** Work-root resolution in `statusline.sh` must work in
  both contexts (root self-host / `.shamt-core/` child) or the status line breaks
  or silently shows nothing. *Mitigation:* test both; the script already reads
  `.shamt-core/shamt-config.json`, so the `.shamt-core/` signal is available.
- **Self-host / master regression.** The work root must resolve to the repo root
  on self-host so master's own paths are unchanged. *Mitigation:* reuse the
  existing self-host detection signal verbatim; verify this very repo still
  resolves root-relative after the change.
- **D12 budget breach.** The rules-file convention line plus the pointer-paragraph
  edit could push past 40,000. *Mitigation:* mechanism A is one convention line;
  re-measure with `wc -m` at `/f3`; pull a compensating trim if needed.
- **Convention not applied to a bare path (the original failure mode).** Because
  bodies keep their bare paths, an agent (or the `review-executor` sub-agent)
  could ignore the convention and still write to the root — exactly what caused
  this bug. *Mitigation:* the high-traffic reminders at the resolution points
  every body defers to (Global Story Invariants + §PO-tree + `review-executor`);
  post-implementation `/f5-audit-framework` D2/D4 sweep + a grep asserting no body
  writes a bare root-relative work-tree path against a `.shamt-core/` child fixture.

## Rollback Plan

Single squash commit (`shamt-core: land #18 …`) via `/f6-archive-proposal`;
`git revert` restores root-relative resolution everywhere. No master-side data
involved. **Caveat:** any child that *installed* the new layout between landing
and revert would have its work tree under `.shamt-core/`; reverting flips
resolution back to root, so that child would need to move its tree back (or
re-sync). Because no legacy/parallel children exist yet (resolved OQ-migration),
this window is effectively empty at landing time.

## Validation Considerations

- **Self-host invariance.** After the change, confirm this repo (self-host) still
  resolves `epics/`/`stories/`/`proposals/` at the root — the work-root convention
  must be a no-op on master.
- **Simulated child.** Construct a `.shamt-core/`-layout fixture and confirm the
  PO/Engineer commands resolve + write under `.shamt-core/`, the statusline reads
  `.shamt-core/shamt-state/`, and **nothing** lands at the fixture root but
  `CLAUDE.md` + `.claude/`.
- **`import-shamt` preservation test (gating).** Populate a child work tree +
  `shamt-state/`, run an import, assert the work tree and pointers survive
  untouched while canonical sources update.
- **D2/D4/D12 post-impl sweep.** `/f5-audit-framework` confirms no body still
  writes a bare root-relative work-tree path, every cross-reference resolves, and
  the rules file stays under budget.
- This (re-scoped) proposal is re-validated (`/validate-artifact`) before `/f3`;
  there is **no Phase 3 plan** (7 files ≤ 10 — `/f2` declined on the mechanism-A
  re-scope).

---

## Resolved Questions

- **OQ1 — Path-expression mechanism.** *Resolved:* **Work-root convention
  (mechanism A).** State once that `epics/`, `features/`, `stories/`,
  `code_reviews/` resolve relative to the **Shamt work root** — the repo root on
  master/self-host, `.shamt-core/` in a child (same self-host signal as
  `proposals/`). Bodies keep bare `epics/`/`stories/` paths interpreted against
  that root; a resolver step makes it concrete. Mirrors the existing `proposals/`
  handling.
- **OQ5 — D12 budget.** *Resolved by OQ1:* mechanism A adds a **single
  convention statement** to the rules file (not per-path prefixes), so the
  ~146-char margin under the 40,000 budget holds. The implementation re-measures
  with `wc -m` at `/f3`; if the convention line plus any §PO-tree tweak would
  breach, a compensating trim is pulled in (deferred candidates exist).

- **OQ-scope — Relocated set.** *Resolved (corrected per user — no root
  exceptions):* `epics/`, `features/`, `stories/`, `code_reviews/`, **and
  `.shamt-state/`** move under the work root (`proposals/` already done); `raw/`
  rides along inside story folders. The only root entries left in a child are
  `CLAUDE.md` and `.claude/`. `import-shamt` must **preserve** the relocated
  child-owned content (work tree + `.shamt-state/`), as it already does for
  `.shamt-core/proposals/` drafts.

- **OQ-pointer — pointer content path-shape.** *Resolved as a corollary of OQ1
  (mechanism A):* pointers move to `.shamt-core/shamt-state/` and store
  **work-root-relative** paths (`epics/<e>/features/<f>/stories/<s>/`, identical
  master vs child); the statusline applies the work root once (prepends
  `.shamt-core/` in a child) when resolving the folder on disk. Keeps everything
  work-root-relative with a single resolution point; avoids a master-vs-child
  path-shape divergence in the statusline.

- **OQ-migration — existing root-level trees.** *Resolved (user):* **no legacy
  projects exist — no migration, no legacy fallback.** The resolvers use the
  clean work-root-relative location only; there is no root-vs-`.shamt-core/`
  dual-resolution to carry. (Orthogonal: `#14`'s flat-vs-nested fallback is a
  different axis, already landed, untouched here.)
- **OQ-enforcement — convention robustness (raised at `/f2`).** *Resolved
  (user):* **convention + high-traffic reminders.** The global convention
  reinterprets all 293 bare work-tree mentions; short reminders are added only at
  the 2–3 highest-traffic resolution points (Global Story Invariants "Story
  folder resolution" + §PO-tree heading + `review-executor`), not to all ~28
  bodies — belt-and-suspenders against the recurrence of the exact bug without
  per-body churn.
- **OQ-phase3 — is Phase 3 warranted? (resolved at `/f2`).** *Resolved:* **No.**
  Mechanism A means the concrete edit set is **7 files** (not the 30+ the
  area-level table implied), because the command/skill bodies are convention-
  covered, not per-path-edited. 7 ≤ 10 → `/f2` declined; `/f3-implement-update`
  applies the edits inline. The Proposed Changes table was re-scoped accordingly
  (footer stripped → re-validation pending).

## Open Questions

None — all resolved above.

---
Validated 2026-06-12 — re-validated after the `/f2` mechanism-A re-scope (Phase 3
declined; table reduced to 7 concrete files); 1 round, 1 adversarial sub-agent confirmed.
