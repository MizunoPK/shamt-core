# Proposal: fold-audit-changes-into-framework-update-commit

**Created:** 2026-06-04
**Status:** Draft (f0 — audit capture, unrefined)
**Proposed by:**
**Project context:**

---

> **f0 capture — unrefined.** This is a quick-capture stub. It has **no** resolved Open Questions, **no** formal Proposed Changes table, and **no** validation footer. `/f1-propose-update fold-audit-changes-into-framework-update-commit` ingests it as intake and fleshes it out.

---

## Scratch Notes (f0 capture)

**User intent (verbatim):** "I DO want any changes that came from an audit during a framework update to be included in that framework update's commits and merge."

This **reverses the current rule.** Today, when `/f5-audit-framework` runs as Phase 6 of the framework-update flow, both of its clearing actions (each simple **auto-fix** and each **f0 draft** captured) are logged as **out-of-band activity, explicitly distinct from the in-flight proposal's scope**, so the proposal's validated change-set and validation footer stay "clean." The premise was that audit edits must not contaminate the proposal's commit. The user wants the opposite: audit-originated changes made during a framework update should be **folded into that update's commit and squash-merge**, not separated out.

**Why the user's position is reasonable:** the audit at Phase 6 *is* part of landing that proposal; its auto-fixes are real canonical edits that should travel with the change (and child projects pick them up on the same `import-shamt`). Forcing the user to manually split the working tree before `/f6-archive-proposal` is friction, and a stray un-committed audit fix is itself a future D1 drift risk.

**Tension to resolve in `/f1` (the design judgment):**

- An auto-fix is a concrete canonical edit → folding it into the proposal's commit is natural and arguably *should* be the default.
- A captured **f0 draft** is not an edit to ship — it's a new `proposals/{slug}.md` stub describing *future* work. Folding the **file** into the commit is harmless (it's just a new file landing on the base branch), but it is **not** part of the proposal's semantic change-set. Decide whether f0 stubs also ride along, or only auto-fix edits do.
- The **validation footer / change-set "cleanliness"** rationale needs re-framing: if audit edits are in-scope of the commit, what keeps the proposal's *validated* change-set distinguishable from audit add-ons? Options: a dedicated commit-message trailer/section listing audit-originated changes; or accept that the squash commit simply contains both with a noted breakdown.

**Implicated canonical sites (for `/f1` to re-grep & reconcile — likely a coordinated multi-file edit → intricate):**

- `host/templates/claude/commands/f5-audit-framework.md` — Step 3 "In-flow out-of-band logging" bullet; the Purpose/Notes lines describing out-of-band logging; the Step 6 next-phase suggestion.
- `host/templates/claude/skills/f5-audit-framework/SKILL.md` — the mirrored "out-of-band activity distinct from the in-flight proposal's scope" wording in steps 12 & frontmatter.
- `reference/audit_dimensions.md` — the "### In-flow logging" subsection (same out-of-band framing).
- `host/templates/claude/commands/f6-archive-proposal.md` (+ SKILL) — the archive/commit/squash-merge contract; this is where "fold audit changes into the commit" would actually take effect.
- `CLAUDE.md` §Conventions + `host/templates/claude/commands/f1-propose-update.md` — commit-subject convention (`shamt-core: land #NN {slug} (...)`); may need an audit-changes note/trailer.
- `CHEATSHEET.md` §"Framework update flow" — any summary of the audit-commit relationship.

Edits under `host/templates/claude/` need `/f4-regen-framework` (Phase 5) afterward; `CLAUDE.md`, `CHEATSHEET.md`, and `reference/` edits don't regenerate but land on next `import-shamt`.

**Note:** this stub itself was created during the same session that just ran an audit producing exactly such out-of-band artifacts — a live example of the friction it addresses.

---

## Problem

_(deferred to `/f1-propose-update` — see Scratch Notes above)_

## Proposed Changes

_(deferred to `/f1-propose-update`)_

## Risks

_(deferred)_

## Rollback

_(deferred)_

## Validation Considerations

_(deferred)_

## Open Questions

_(deferred to `/f1-propose-update` — the load-bearing ones: (1) do f0 stubs ride into the commit too, or only auto-fix edits? (2) how is the proposal's validated change-set kept distinguishable from audit add-ons inside one squash commit?)_
