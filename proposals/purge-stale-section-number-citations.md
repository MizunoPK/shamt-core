# Proposal: purge-stale-section-number-citations

**Created:** 2026-06-03
**Status:** Draft (f0 — audit capture, unrefined)
**Proposed by:**
**Project context:**

---

> **f0 capture — unrefined.** This is a quick audit-capture stub from `/f5-audit-framework`. It has **no** resolved Open Questions, **no** formal Proposed Changes table, and **no** validation footer. `/f1-propose-update purge-stale-section-number-citations` ingests it as intake and fleshes it out.

---

## Scratch Notes (f0 capture)

Shipped canonical bodies carry **~70 dangling `§N.N` citations** (`§1.4`, `§1.11`, `§1.12`, `§1.14`, `§1.15`, `§2.1`, `§2.2`, `§2.3`, `§3.4`, `§3.5`, `§3.6`, `§3.9`, `§4.3`, `§4.4`, `§4.7`, `§4.8`, `§4.13`, …) across **~35 files** — host commands/skills, templates, references, and `CHEATSHEET.md` — that point to the section numbering of the **now-deleted `INFRASTRUCTURE.md`** planning doc from the old `shamt-ai-dev-v2/` container.

**Evidence the §-scheme = INFRASTRUCTURE.md numbering:** archived proposal links (under `proposals/archive/`) prove the mapping — `INFRASTRUCTURE.md#112-architecture--coding-standards-maintenance` = §1.12, `#21-what-epicfeature-work-actually-needs` = §2.1, `#111-issue-tracker-integration` = §1.11, `#23-open-meta-questions` = §2.3, etc. And the citation contexts match those anchor titles (e.g. `e7-resolve-feedback` cites §1.12 for "durable framework improvements happen via proposals" = the architecture/standards-maintenance section).

**Why it's a finding (D4 reference validity + D11 scope-clarity):** no `§`-numbered section exists anywhere in the standalone repo to resolve these against (the only `§`-heading line, `CHEATSHEET.md:146`, is itself a *citation* of §1.12, not a definition). So a fresh agent reading "per §2.1" or "the §1.12 + Part 3 lesson" is sent **nowhere** — and these citations **regenerate into every child project's `.claude/`**. Surfaced by the `/f5-audit-framework` D4/D11 dimensions.

**Why the prior migration missed it:** the archived `shamt-core-standalone-repo` proposal swept the **markdown-link** form (`[..](../INFRASTRUCTURE.md#anchor)`) but the **prose** form (`per §2.1`, `the §1.12 + Part 3 lesson`) is a different syntactic shape the link-sweep never matched. The in-flight `standalone-repo-path-and-detection-cleanup` proposal is scoped (Policy B, surgical) to `shamt-core/`-prefixed *paths* and self-host *detection* in the f4/f5 pairs only — it does **not** touch the §-citations.

**Related facet — overloaded "Part N" cross-reference token (D11/D7):** the token "Part N" resolves to two different things depending on which canonical doc the reader consults — `CHEATSHEET.md` Part 3 = "Framework update flow", while `templates/SHAMT_RULES.template.md:370` Part 3 = "Engineer Flow — Phase Narratives" (Part 1/2/4 likewise differ between the two docs). Most host citations self-disambiguate by naming the flow ("Part 3 framework-update flow", "Part 3's Engineer Flow phase narratives"), but the bare combos do not — e.g. `e7-resolve-feedback.md:92` "the §1.12 + Part 3 lesson" and `e7-resolve-feedback/SKILL.md:32` "§1.12 + Part 3 rule". Because these bare "Part 3" sites overlap the §-citation sites and share the same root cause (a stale numbered-spec cross-reference scheme), disambiguate "Part N" in the **same pass**.

**Shape of the fix (intricate — for `/f1-propose-update` to resolve):** each of the ~70 sites needs a **per-site judgment** to either re-point the citation to its v2 canonical home (a Part / Pattern / Principle in `SHAMT_RULES.template.md`, a numbered section in `CHEATSHEET.md`, or a `reference/` doc) or remove the citation where no v2 equivalent exists. Decide once whether v2 should *adopt* a stable `§`/section-numbering scheme (so future citations resolve) or *abolish* `§N.N` citations entirely in favor of named cross-references ("Pattern 1", "Principle 2", "the framework-update flow"). Rows under `host/templates/claude/` will need `/f4-regen-framework` (Phase 5) afterward; `templates/` / `reference/` / `CHEATSHEET.md` edits do not regenerate but land on next `import-shamt`.

**Affected-file inventory (starting point — `/f1` should re-grep `§[0-9]+\.[0-9]+` to confirm):** 35 files carry §-citations — host commands `e5-execute-tests`, `e5b-write-manual-testing-plan`, `e6-review-changes`, `e7-resolve-feedback`, `f5-audit-framework`, `f6-archive-proposal`, `p1`–`p4`, `sync-import-shamt`, `sync-submit-proposal`; the mirrored skills; `agents/test-executor.md`; templates `architecture`, `coding_standards`, `epic`, `feature`, `testing_plan`; references `model_selection`, `trackers/{ado,github,local,_contract}`; and `CHEATSHEET.md`.

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

_(deferred to `/f1-propose-update` — the load-bearing one: adopt a stable section-numbering scheme vs. abolish `§N.N` citations in favor of named cross-references)_
