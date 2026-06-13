# Proposal: gitignore-shamt-core-on-init

**Created:** 2026-06-11
**Status:** Implemented
**Number:** 19
**Proposed by:** [master-local]
**Project context:** [master-local]

---

## Problem

When Shamt installs into a child project, the install drops a `.shamt-core/`
directory holding a mix of **master-owned, regenerated content** and
**child-owned, authored content** — but nothing tells the child's git which is
which. Today `init-shamt.sh` writes **no `.gitignore` entry** (it only excludes
`*/.git` during the copy). So a child either commits the entire regenerated
framework tree into its own repo (noise — re-pullable from master, overwritten on
every `import-shamt`) or hand-rolls its own ignore rules.

The split is now sharp and well-defined by the sync machinery:

- **Master-owned / regenerated** (`import-shamt`'s sync set — overwritten on every
  pull, so it should **not** be tracked by the child): `MASTER_SYNC_DIRS`
  (`.shamt-core/{scripts,templates,reference,host}/`) + `MASTER_SYNC_FILES`
  (`.shamt-core/{CLAUDE.md,README.md,shamt-config.example.json,init-shamt.sh,import-shamt.sh}`,
  `.shamt-core/proposals/_template.md`).
- **Child-owned / authored** (preserved across imports — the child **does** want
  these tracked): `.shamt-core/shamt-config.json` (its tracker/testing config),
  `.shamt-core/project-specific-files/{ARCHITECTURE,CODING_STANDARDS}.md`,
  child-authored `.shamt-core/proposals/{slug}.md` drafts, and — **after #18
  (`artifacts-must-live-under-shamt-core`)** — the PO/Engineer **work tree**
  (`.shamt-core/{epics,features,stories,code_reviews}/`), which is the child's own
  planning artifacts.
- **Transient session state**: `.shamt-core/shamt-state/` (active-item pointers,
  #18) — ephemeral, should **not** be tracked.

So the f0's open question — *gitignore the whole `.shamt-core/` or only part?* —
resolves to **selective**: a **blanket `.shamt-core/` ignore would untrack the
child's own work tree, config, and authored docs** (regression, especially
post-#18). `init-shamt.sh` should write a **managed `.gitignore` block** that
ignores the regenerated sync set + transient state while leaving the child's
authored content tracked — gated to child installs (self-host's own `.gitignore`
is hand-maintained).

The exact ignore/track boundary, the gitignore structure (deny-list vs
allow-list), whether the regenerated root `.claude/` is also covered, and the
write mechanism (idempotent managed block; refresh on `import-shamt`?) are settled
in the Open Questions below before the change set is fixed.

---

## Proposed Changes

**Resolved approach:** on a **child** install (`SELF_HOST -eq 0`), `init-shamt.sh`
appends a managed, idempotent block to the child's root `.gitignore`
(create-if-absent) that ignores Shamt-generated content:

```gitignore
# >>> Shamt (managed) — generated/regenerated content; not tracked in the child repo.
#     Restore .shamt-core/ via import-shamt; regenerate .claude/ via /f4-regen-framework.
/.shamt-core/
/.claude/
/CLAUDE.md          # ← only when init SEEDED CLAUDE.md (full Shamt rules); omitted
                    #    when init preserved a pre-existing child CLAUDE.md
# <<< Shamt
```

**`/CLAUDE.md` is conditional.** `init-shamt.sh:375–378` `cp`s the full
`SHAMT_RULES.template.md` to `CLAUDE.md` **only when none exists**; if the child
already has a `CLAUDE.md`, init **preserves** it (warns; the user merges the rules
by hand). In that preserve case the file is the **child's own content** —
gitignoring it would untrack their file. So `/CLAUDE.md` is added to the block
**only in init's `cp` (seeded) branch**, never in the preserve branch.
`.shamt-core/` and `.claude/` are always Shamt-created dirs, so they are always
ignored.

| File | Op | What |
|---|---|---|
| `init-shamt.sh` | EDIT | Add a child-gated (`SELF_HOST -eq 0`) step that appends the managed Shamt block to `<child>/.gitignore`: create the file if absent; **idempotent** — skip if a `# >>> Shamt (managed)` marker is already present (re-init / re-run safe); append (never rewrite the child's existing `.gitignore`). The static lines `/.shamt-core/` + `/.claude/` always; add `/CLAUDE.md` **only in the seeded-CLAUDE.md branch** (`:378` `cp`), not the preserve branch (`:375–376`). Log the action. **Self-host is skipped** — the shamt-core repo tracks its own canonical sources, `CLAUDE.md`, and `.claude/`. |
| `README.md` | EDIT | In the child-layout section (the `<child-project>/` tree), annotate that `.shamt-core/`, `CLAUDE.md`, and `.claude/` are **git-ignored in a child** (Shamt-generated; restored by `import-shamt` / `/f4-regen-framework`), so the child repo tracks none of them. |
| `CLAUDE.md` (master-dev primer) | EDIT | Append one sentence to the **"What lives here" child-layout paragraph** (`CLAUDE.md:~22`, the `.shamt-core/` containment paragraph #18 last edited) noting the install gitignores `.shamt-core/`, `.claude/`, and the seeded `CLAUDE.md` in a child (so the child repo tracks none of Shamt's generated footprint). |

Three canonical files (`init-shamt.sh` is the behavioral change; the two docs keep
the layout description accurate). Row count ≤ 10 → no Phase 3.

---

## Risks

- **Already-tracked content in an existing child (HIGH for retrofits).** A
  `.gitignore` entry does **not** untrack files git already tracks. A child that
  installed Shamt *before* this change and committed `.shamt-core/` / `CLAUDE.md` /
  `.claude/` would keep tracking them; the ignore only takes effect after a
  `git rm -r --cached` of those paths. *Mitigation:* this proposal targets the
  **fresh-install** path (init writes the ignore before anything is committed, so
  it's never tracked); the log line / README note can mention the
  `git rm --cached` retrofit for existing children. Not auto-run (touching the
  child's git index is the child's call).
- **Self-host regression (CRITICAL if mis-gated).** If the gitignore write ran on
  the self-host, it would tell shamt-core's own repo to ignore its canonical
  sources, `CLAUDE.md`, and `.claude/` — corrupting the master repo. *Mitigation:*
  the step is gated on `SELF_HOST -eq 0`, like the Tech Stories seed; validation
  verifies the self-host path is untouched.
- **Fresh clone is non-functional until regen.** With `.claude/` ignored, a clone
  of the child repo has no Shamt commands until `/f4-regen-framework` (or
  `import-shamt`) runs. *Mitigation:* accepted at OQ3; the managed block's comment
  states how to restore. Onboarding docs (out of scope) could note it.
- **`.claude/` holds some user-owned content.** Regen only patches the `statusLine`
  entry of `.claude/settings.json` and preserves user-authored `.claude/` files;
  blanket-ignoring `.claude/` therefore also untracks a team's shared
  `settings.json` and any custom commands they keep there. *Mitigation:* accepted
  under OQ3's "ignore `.claude/` too" directive; flagged here so a future
  proposal can carve out `!/.claude/settings.json` if a team wants its shared
  config tracked. Not done here (keeps the user's blanket directive intact).
- **Clobbering the child's `.gitignore`.** A naive write could overwrite existing
  rules. *Mitigation:* append-only + idempotent marker check; never rewrite.

## Rollback Plan

Single squash commit (`shamt-core: land #19 …`) via `/f6-archive-proposal`;
`git revert` removes the init `.gitignore` step + the doc notes. No master data
involved. A child that already installed the new init keeps its `.gitignore`
block (a harmless few lines it can delete manually); reverting only stops *future*
installs from writing it.

## Validation Considerations

- **Self-host untouched (gating).** Confirm the gitignore step is gated
  `SELF_HOST -eq 0` and that a self-host `init-shamt.sh` run writes **nothing** to
  the repo's `.gitignore`.
- **Idempotency.** A second child `init` (or a re-init) must **not** duplicate the
  managed block — verify the marker check.
- **Append, not clobber.** With a pre-existing child `.gitignore`, the block is
  appended and the prior content is intact.
- **Root-anchored patterns.** `/.shamt-core/`, `/.claude/`, `/CLAUDE.md` match only
  the root install footprint (not a nested same-named file).
- **Conditional `/CLAUDE.md` (the Round-1 correctness fix).** Verify `/CLAUDE.md`
  is added to the block **only** when init seeded the file (the `cp` branch), and
  is **omitted** when init preserved a pre-existing child `CLAUDE.md` — so a child's
  own `CLAUDE.md` is never untracked. `.shamt-core/` + `.claude/` are always
  ignored.
- **Doc accuracy (D-consistency).** The `README.md` child-layout tree and the
  `CLAUDE.md` note agree on what is ignored; reconcile with #18's just-landed
  layout edits.
- This proposal is validated (`/validate-artifact`) before `/f3`.

---

## Resolved Questions

- **OQ1 — Ignore/track split.** *Resolved (user):* **blanket ignore.** The
  **entire `.shamt-core/`** plus the root **`CLAUDE.md`** are gitignored in a child
  — including the PO/Engineer **work tree** (`epics/features/stories/code_reviews`,
  #18). Confirmed intended: Shamt artifacts (including planning specs/plans/reviews)
  are tooling/working state, not the child's project source, and don't belong in
  its git history; planning lives in the working tree and upstream in the tracker.
- **OQ2 — Deny-list vs allow-list.** *Moot under OQ1:* a blanket `.shamt-core/`
  ignore is two static lines that need no enumeration and never go stale as the
  sync set grows — so no deny/allow-list and no `import-shamt` refresh of the
  block is required.

- **OQ3 — `.claude/` scope.** *Resolved (user):* **ignore `.claude/` too.** All
  Shamt-generated content is ignored — `.shamt-core/`, `CLAUDE.md`, **and**
  `.claude/`. Accepted trade-off: a fresh clone of the child repo has no Shamt
  wiring until a `/f4-regen-framework` (or `import-shamt`) regenerates `.claude/`.
- **OQ4 — Write mechanism.** *Resolved (determined by best practice):* a
  **managed, idempotent block** appended to the child's root `.gitignore`
  (create-if-absent), **gated to child installs** (`SELF_HOST -eq 0` — the
  shamt-core self-host tracks its own canonical sources, `CLAUDE.md`, and
  `.claude/`, so it must be skipped). Patterns are **root-anchored** (`/.shamt-core/`,
  `/.claude/`, `/CLAUDE.md`) so they match only the install's footprint, not a
  same-named file elsewhere in the child. No `import-shamt` refresh is needed (a
  static blanket ignore never goes stale).

## Open Questions

None — all resolved above.

---
Validated 2026-06-13 — 3 rounds, 1 adversarial sub-agent confirmed
