# Proposal: purge-stale-section-number-citations

**Created:** 2026-06-03
**Status:** Implemented
**Number:** 04
**Proposed by:**
**Project context:**
**Note (2026-06-06, f1 ingest of f0 capture):** developed from the `/f5-audit-framework` f0 capture. Load-bearing decision resolved: **abolish `§N.N` citations** in favor of v2 named cross-references (user choice, 2026-06-06). Scope re-grepped against HEAD: **71 `§N.N` citations across 35 files** (17 distinct tokens). 35 rows > 10 → **Phase 3 required**.
**Audit-fold (2026-06-06, Phase 6 / f5):** the post-implementation audit surfaced 4 **`§Name`** (non-numeric) citations of the same `§` cross-reference family that the `§[0-9]+\.[0-9]+` scope grep did not match — `§Pattern X` (`f1-propose-update.md`), `§Pattern 1` (`f5-audit-framework.md`), `§Conventions` (`f6-archive-proposal.md`, `CHEATSHEET.md`). Their targets resolve (real named sections), so they were a D7 consistency wart rather than a D4 break; folded in here (dropped the `§` → bare named ref / prose, e.g. "the Conventions section of `CLAUDE.md`") so the canonical surface is **fully `§`-free**. These 4 simple auto-fixes ride into this proposal's `/f6` landing commit per the audit dual-track policy.

---

## Problem

Shipped canonical bodies carry **71 dangling `§N.N` citations** across **35 files** (host commands/skills, templates, references, and `CHEATSHEET.md`) that point to the section numbering of the **now-deleted `INFRASTRUCTURE.md`** planning doc from the old `shamt-ai-dev-v2/` container. The 17 distinct tokens in use: `§1.4 §1.11 §1.12 §1.14 §1.15 §2.1 §2.2 §2.3 §3.4 §3.5 §3.6 §3.9 §4.3 §4.4 §4.7 §4.8 §4.13`.

**The §-scheme has no definition anywhere in the standalone repo.** A whole-tree grep finds **zero** `§`-numbered section *headings* — the only `§`-bearing heading (`CHEATSHEET.md:146`, "Architecture-impact flag (§1.12 PO-threading)") is itself a *citation*, not a definition. So a fresh agent reading "per §2.1" or "the §1.12 + Part 3 lesson" is sent **nowhere**, and these citations **regenerate into every child project's `.claude/`** (host bodies) or ship in the templates/references/cheatsheet. This is a **D4 (reference validity)** + **D11 (scope-clarity)** finding surfaced by `/f5-audit-framework`.

**Why the prior migration missed it.** The archived `shamt-core-standalone-repo` proposal swept the **markdown-link** form (`[..](../INFRASTRUCTURE.md#anchor)`) but the **prose** form (`per §2.1`, `the §1.12 + Part 3 lesson`) is a different syntactic shape the link-sweep never matched. The implemented `standalone-repo-path-and-detection-cleanup` (#02) was scoped (Policy B) to `shamt-core/`-prefixed *paths* and self-host *detection* — it did not touch `§`-citations. The implemented `purge-build-phase-numbers-from-host-bodies` (#03) removed *dev-build phase numbers* — a different stale-reference class. This proposal closes the remaining stale-cross-reference class.

**The fix: abolish, don't re-number.** The v2 framework already uses a clean **named** cross-reference convention — `templates/SHAMT_RULES.template.md` defines `## Principle 1/2`, `## Pattern 1–5`, `# Part 1–4` (titled, stable). Named references do not break on renumbering — which is exactly what broke the `§`-scheme. So each `§N.N` citation is **re-pointed to its v2 named home** (a Pattern / Principle / Part / flow name / reference doc) or, where a named reference already co-exists beside the `§` (very common — e.g. "§1.11 / Pattern 4", "§1.12 + Part 3 lesson", "see `proposals/_template.md` and §3.4", "PO flow (§2.2)", "the audit record (§3.6 / §3.9)") or the rule is stated inline, the **dangling `§` is simply deleted**. Adopting a new stable `§`-numbering scheme was rejected (Resolved Questions) — it re-introduces the brittle numbered-citation pattern that just failed.

**Related facet — overloaded "Part N" token (rides along where it overlaps `§`-sites).** "Part N" resolves to two different things: `CHEATSHEET.md` Part 3 = "Framework update flow"; `SHAMT_RULES.template.md:370` Part 3 = "Engineer Flow — Phase Narratives". Most host citations self-disambiguate by naming the flow, but two bare combos overlap the `§`-sites and share the same root cause — `e7-resolve-feedback.md:92` "the §1.12 + Part 3 lesson" and `e7-resolve-feedback/SKILL.md:32` "(§1.12 + Part 3 rule)". Both **already** say "via the framework-update flow" in the same sentence, so the parenthetical "(§1.12 + Part 3 …)" is deleted outright. A broader audit of *all* bare "Part N" tokens across the canonical surface is **out of scope** here (separate finding) — only the two that overlap `§`-citation sites are touched.

---

## §-token resolution table (the design — abolish to v2 named homes)

Each row gives the concept the token backs and its v2 replacement. **"Delete"** = a named reference already co-exists in the sentence (or the rule is stated inline), so the dangling `§` is removed with no substitute. **"Re-point"** = the `§` is the only reference; replace it with the named v2 home. A few tokens are **per-site** (the right named home depends on the specific sentence) — the Phase-3 plan resolves each occurrence exactly.

| Token | Concept it backs | v2 named home | Default treatment |
|-------|------------------|---------------|-------------------|
| `§1.4` | story-vs-feature artifact layout ("stories *do* have `raw/`", unlike feature folders) | (inline artifact-discipline rule; no separate v2 section) | **Delete** the bare "per §1.4" (rule stated inline: "stories, which *do* have `raw/`") |
| `§1.11` | issue-tracker integration / no-postback | the active **tracker profile** (`reference/trackers/_contract.md`); **Pattern 4** for review-postback | Delete where Pattern 4 co-named; else re-point to "the tracker contract" |
| `§1.12` | architecture-impact / standards maintenance / "improvements via proposals" | the **Standards check** (`ARCHITECTURE.md` / `CODING_STANDARDS.md` governing refs); the **framework-update flow** for the proposals lesson | **Per-site**: re-point to "the architecture-impact / Standards check" or "the framework-update flow"; delete where Part 3 co-named |
| `§1.14` | **per-site** — testing facets: testing-plan escalation threshold (e5:49), environmental-issue resolution (test-executor:93, e5-skill:37), Phase-5 execution-blocking (testing_plan template:74) | the **testing rules** (`/e3b` escalation; the `/e5` test-executor environmental-resolution contract; Phase-5 blocking) | **Per-site**: re-point to the specific testing rule the sentence backs |
| `§1.15` | **per-site** — manual-test-plan facets: the rule itself / when required (e5b, model_selection), its risk-triggered validation sub-agent (e5b:103) | the **manual-test-plan rule** (the optional-post-build-artifact section of `SHAMT_RULES.template.md` + `/e5b`); **Pattern 1** for the validation-sub-agent facet | **Per-site**: re-point to "the manual-test-plan rule" or "Pattern 1's risk-triggered sub-agent" per the sentence |
| `§2.1` | "16-category review stays story-level" / "stub-list-then-drill-in" / flat layout | **Pattern 4** (review scope) **or** the PO flow's **stub-list-then-drill-in decomposition** | **Per-site**: re-point to whichever named concept the sentence backs |
| `§2.2` | "PO flow" | the **PO flow** (named) | **Delete** (PO flow co-named) |
| `§2.3` | decomposition independence / parallelization analysis | the **decomposition + parallelization-analysis** step (`/p2`, `/p4`) | Re-point to "the decomposition / parallelization step"; delete where co-named |
| `§3.4` | `proposals/rejected/` + `proposals/deferred/` folders | **`proposals/_template.md`** (folder docs) | **Delete** (`proposals/_template.md` co-named) |
| `§3.5` | Documentation Impact Assessment / doc-currency triggers | the **Documentation Impact Assessment** (`/e6`); audit **D6** (project-doc currency) | Re-point to "the Documentation Impact Assessment / audit D6" |
| `§3.6` / `§3.9` | "the conversation is the audit record / no log artifact" | (audit no-log-artifact rule, stated inline in `/f5`) | **Delete** (rule stated inline) |
| `§4.3` | manual-copy sync design **and** upstream-submission namespacing (`project_name`) — appears in both contexts (sometimes in a `§4.3 / §4.4` combo) | the **master/child sync** (Part 4): manual-copy design / `project_name` namespacing (`/sync-submit-proposal`) | **Per-site**: re-point to "the manual-copy sync design" or "the `project_name` namespacing convention" per the sentence; delete where co-named |
| `§4.4` / `§4.8` | **per-site** — `§4.4` backs both `project_name` submission namespacing (sync-submit, with `§4.3`) **and** master-vs-child detection (skills, with `§4.8`); `§4.8` = detection | the **master/child sync** (Part 4): the `proposals/incoming/` master-vs-child detection rule **or** the `project_name` namespacing convention | **Per-site**: re-point to whichever the sentence backs (detection vs namespacing); delete where co-named |
| `§4.7` | the *original* per-file footer-check wording (contrasted with v2's subtree-level rule) | (the per-file-footer-check concept, named inline) | **Rephrase** (not a clean delete): "the literal §4.7 wording proposed (per-file footer check)" → "the per-file footer check originally proposed" |
| `§4.13` | **per-site** — child-submission attribution (`Proposed by`/`Project context`, sync-submit:44) **and** the always-latest / no-version-pinning import policy (sync-import:112) | the **master/child sync** (Part 4): child-submission attribution **or** the always-latest import policy | **Per-site**: re-point to whichever the sentence backs; delete where co-named |

> **Per-site vs. single-concept (important — most tokens are per-site).** Each `§N.N` cited into a *broad* INFRASTRUCTURE.md section that covered several rules, so the same token often backs different claims at different sites. Classify:
> - **Per-site** (the v2 home depends on the specific sentence — the Phase-3 plan resolves each occurrence individually, re-pointing to the named v2 rule or deleting where a named reference / inline statement co-exists): **`§1.12`, `§1.14`, `§1.15`, `§2.1`, `§4.3`, `§4.4`, `§4.8`, `§4.13`**. The `§4.x` set spans Part 4 (master/child sync) facets — manual-copy, `project_name` namespacing, detection, footer contract, always-latest, attribution.
> - **Single-concept** (one consistent claim across its sites → uniform treatment): `§1.4` (delete), `§1.11` (tracker integration → tracker contract / delete where Pattern 4 co-named), `§2.2` (delete), `§2.3` (decomposition → re-point/delete), `§3.4` (delete), `§3.5` (Documentation Impact / D6 → re-point), `§3.6`/`§3.9` (delete), `§4.7` (rephrase).
>
> The rows above give the v2 area(s) per token; the **Phase-3 plan quotes each of the 71 occurrences' full sentence and resolves it exactly** — this proposal fixes the policy (abolish → named refs) and the per-token homes, not the 71 exact strings.

---

## Proposed Changes

One row per canonical file; each applies the resolution table above to that file's `§`-citations (tokens listed). **No `.claude/` paths** — host bodies regenerate via `/f4-regen-framework` (Phase 5); `templates/`, `reference/`, and `CHEATSHEET.md` are not regenerated and land on next `/sync-import-shamt`. **35 rows > 10 → Phase 3 (`/f2-plan-update-implementation`) required.** Per-site exact locate/replace is the Phase-3 plan's job; this table fixes the per-file scope + treatment. **The Notes column is *indicative*** — for the per-site tokens (`§1.12`, `§1.14`, `§1.15`, `§2.1`, `§4.x`) the authoritative treatment is the `§`-resolution table + per-site classification above; the Phase-3 plan resolves each occurrence against its actual sentence.

| # | Canonical path | Tokens | Notes |
|---|----------------|--------|-------|
| 1 | `host/templates/claude/commands/p1-start-epic.md` | §1.12, §2.1 | per-site (§1.12 architecture-impact; §2.1 stub-list) |
| 2 | `host/templates/claude/commands/p2-decompose-epic.md` | §1.11, §2.1, §2.3 | §1.11 freeform-fallback→tracker profile; §2.1/§2.3 decomposition |
| 3 | `host/templates/claude/commands/p3-start-feature.md` | §1.4, §1.12, §2.1 | §1.4 delete; §1.12/§2.1 per-site |
| 4 | `host/templates/claude/commands/p4-decompose-feature.md` | §1.11, §2.1, §2.3 | same pattern as row 2 |
| 5 | `host/templates/claude/commands/e5-execute-tests.md` | §1.14 | →testing-plan escalation threshold |
| 6 | `host/templates/claude/commands/e5b-write-manual-testing-plan.md` | §1.15 | §1.15 per-site (the manual-test-plan rule / model-tier facets + the validation-sub-agent facet at :103 → Pattern 1) — see §-table |
| 7 | `host/templates/claude/commands/e6-review-changes.md` | §1.11, §3.5 | §1.11→Pattern 4 (co-named); §3.5→Documentation Impact / D6 |
| 8 | `host/templates/claude/commands/e7-resolve-feedback.md` | §1.12 | delete "(§1.12 + Part 3 lesson)" — "framework-update flow" co-named (Part-N facet) |
| 9 | `host/templates/claude/commands/f5-audit-framework.md` | §3.6, §3.9 | delete (audit no-log-artifact rule inline) |
| 10 | `host/templates/claude/commands/f6-archive-proposal.md` | §3.4 | delete (`proposals/_template.md` co-named) |
| 11 | `host/templates/claude/commands/sync-import-shamt.md` | §4.7, §4.13 | §4.7 rephrase ("the literal §4.7 wording proposed (per-file footer check)" → "the per-file footer check originally proposed"); §4.13→attribution rule |
| 12 | `host/templates/claude/commands/sync-submit-proposal.md` | §4.3, §4.4, §4.13 | →sync manual-copy design / detection / attribution |
| 13 | `host/templates/claude/agents/test-executor.md` | §1.14 | →testing rule |
| 14 | `host/templates/claude/skills/p2-decompose-epic/SKILL.md` | §2.1 | mirror row 2 |
| 15 | `host/templates/claude/skills/p3-start-feature/SKILL.md` | §2.1 | mirror row 3 |
| 16 | `host/templates/claude/skills/p4-decompose-feature/SKILL.md` | §2.1, §2.3 | mirror row 4 |
| 17 | `host/templates/claude/skills/e5-execute-tests/SKILL.md` | §1.14 | §1.14 per-site (environmental-resolution facet here, not the threshold) |
| 18 | `host/templates/claude/skills/e5b-write-manual-testing-plan/SKILL.md` | §1.15 | §1.15 per-site (see §-table) — mirror row 6 |
| 19 | `host/templates/claude/skills/e6-review-changes/SKILL.md` | §1.11, §1.12 | mirror row 7 + §1.12 |
| 20 | `host/templates/claude/skills/e7-resolve-feedback/SKILL.md` | §1.12 | mirror row 8 (Part-N facet) |
| 21 | `host/templates/claude/skills/f6-archive-proposal/SKILL.md` | §3.4 | mirror row 10 |
| 22 | `host/templates/claude/skills/sync-import-shamt/SKILL.md` | §4.3 | →sync design |
| 23 | `host/templates/claude/skills/sync-submit-proposal/SKILL.md` | §4.4, §4.8 | →master-vs-child detection |
| 24 | `host/templates/claude/skills/sync-triage-proposals/SKILL.md` | §4.4, §4.8 | →master-vs-child detection |
| 25 | `templates/architecture.template.md` | §1.12 | →Standards check / architecture-impact |
| 26 | `templates/coding_standards.template.md` | §1.12 | →Standards check |
| 27 | `templates/epic.template.md` | §1.12 | →architecture-impact |
| 28 | `templates/feature.template.md` | §1.12, §2.3 | →architecture-impact / decomposition |
| 29 | `templates/testing_plan.template.md` | §1.14 | §1.14 per-site (Phase-5 execution-blocking facet here, not the threshold) |
| 30 | `reference/model_selection.md` | §1.15 | §1.15 per-site (manual-test-plan model-tier facet here → "the manual-test-plan rule", not Pattern 1) |
| 31 | `reference/trackers/_contract.md` | §2.2 | delete (PO flow co-named) |
| 32 | `reference/trackers/ado.md` | §1.11, §2.1 | →tracker contract / decomposition |
| 33 | `reference/trackers/github.md` | §1.11, §2.1 | mirror row 32 |
| 34 | `reference/trackers/local.md` | §2.1 | →decomposition |
| 35 | `CHEATSHEET.md` | §1.12 | the `CHEATSHEET.md:146` heading "Architecture-impact flag (§1.12 PO-threading)" → drop "(§1.12 PO-threading)" or "Architecture-impact flag" alone |

**Paired files:** the e5/e5b/e6/e7/p2/p3/p4/sync-* command↔skill pairs (rows 5↔17, 6↔18, 7↔19, 8↔20, 10↔21, 2↔14, 3↔15, 4↔16, 11/12↔22/23/24) must lose the same citations together. Every command with `§`-citations and a mirrored skill has both listed above.

---

## Risks

- **Mis-pointing risk (the main one).** A re-point that names the *wrong* v2 concept is worse than a dangling `§` — it sends a reader confidently to the wrong place. Mitigated by the per-site resolution: the Phase-3 plan quotes each citation's full sentence and the resolution-table mapping, and where a token is **per-site** (`§1.12`, `§2.1`, `§2.3`) each occurrence is resolved individually (not bulk-substituted). Validation re-reads each re-point against the cited sentence's actual claim.
- **Over-deletion risk.** Deleting a `§` where it was the *only* reference would drop the cross-reference entirely. Mitigated: "Delete" treatments apply **only** where a named reference co-exists in the sentence or the rule is stated inline at the citation site (verified per token in the resolution table); everything else is a re-point.
- **Regression risk** — none functional. Every edit is prose in Notes / instruction / heading text; no executable step changes.
- **Drift risk** — host-body rows (1–24) need `/f4-regen-framework` (Phase 5); skipping regen is a D1 finding caught by `--check`. Rows 25–35 (`templates/`, `reference/`, `CHEATSHEET.md`) are not regenerated and won't appear in the `--check` diff.
- **Child-project compatibility** — children pick up corrected host bodies on next `/sync-import-shamt`; templates/references/cheatsheet land on the same import. No manual reconciliation.
- **Completeness risk** — the 71/35 scope is a HEAD grep of `§[0-9]+\.[0-9]+`; validation must re-run it and confirm every hit maps to a row, and that **zero** `§N.N` citations remain post-edit.

---

## Rollback Plan

Revert the commit and re-run `/f4-regen-framework`. No child-side action required (purely textual edits in regenerated host bodies + templates/references/cheatsheet).

---

## Validation Considerations

- **Problem clarity** — confirm the validator reads this as "abolish dangling `§N.N` → v2 named references", not "renumber". The `§`-scheme = deleted INFRASTRUCTURE.md numbering (proven by archived-proposal anchor links: `#112-…` = §1.12, `#21-…` = §2.1, etc.).
- **Resolution correctness (highest-risk)** — for each of the 17 tokens, verify the v2 named home in the resolution table actually makes the claim the citation backs. Spot-check the per-site tokens (`§1.12`, `§2.1`, `§2.3`): each occurrence must re-point to the concept *its* sentence backs, not a blanket substitution.
- **Change-list completeness** — re-grep `§[0-9]+\.[0-9]+` across `host/templates/claude/`, `templates/`, `reference/`, `CHEATSHEET.md`; every hit maps to one of the 35 rows; the command↔skill pairs are both covered.
- **Delete-vs-re-point audit** — confirm every "Delete" treatment has a co-existing named reference (or inline rule) at the site, so no cross-reference is silently lost.
- **Affected surfaces** — host commands/skills + 5 templates + 5 reference docs + `CHEATSHEET.md`. No rules-file (`SHAMT_RULES.template.md`) edit (it defines the named homes; it carries no `§N.N` citations — confirm), no personas beyond `test-executor`, no scripts.
- **Propagation plan** — `/f4-regen-framework` after Phase 4; child update on next `/sync-import-shamt`. **35 rows > 10 → Phase 3 plan required.**

---

## Open Questions

(none remaining)

---

## Resolved Questions

<!-- Drafting-only log -->

- ~~Load-bearing: adopt a stable `§`/section-numbering scheme so future citations resolve, or abolish `§N.N` citations in favor of named cross-references?~~ → A: **Abolish** (user choice, 2026-06-06). The v2 framework already uses named, titled references (`Pattern N`, `Principle N`, `Part N`, flow names, reference docs); named refs don't break on renumbering — which is exactly what broke the `§`-scheme. Each `§N.N` is re-pointed to its v2 named home or deleted where a named reference already co-exists.
- ~~Scope of the "Part N" overloaded-token facet?~~ → A: **Only the two bare "Part 3" sites that overlap `§`-citations** (`e7-resolve-feedback.md:92`, `e7-resolve-feedback/SKILL.md:32`) — both already name "the framework-update flow", so the parenthetical is deleted. A broader audit of all bare "Part N" tokens is a separate finding, out of scope here.
- ~~Standalone-repo layout: cite paths with `shamt-core/` prefix?~~ → A: No — post-`shamt-core-standalone-repo` (Implemented 2026-06-01), canonical sources are at the repo root; all paths here are repo-root-relative.

---
Validated 2026-06-06 — 6 rounds, 1 adversarial sub-agent confirmed (deep per-site iteration: rounds 1–5 progressively corrected the §-token resolution table as the per-site nature surfaced — §4.7 is a rephrase not a delete; §1.4 concept fix; §4.3/§4.4/§4.13 tangled across sync facets; §1.14/§1.15 tangled across testing / manual-test facets — culminating in a per-site-vs-single-concept classification, an indicative-Notes caveat, and corrected per-site row Notes; the sub-agent independently confirmed the 71-citation / 35-file / 17-token inventory, clean-delete safety, the §4.7 rephrase, and abolish-policy soundness)
