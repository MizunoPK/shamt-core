# Implementation Plan — Phase 3 — rules-file-over-budget (#09)

**Created:** 2026-06-08
**Index:** `proposals/09-rules-file-over-budget_PLAN.md`
**Proposal:** `proposals/09-rules-file-over-budget.md` (Validated 2026-06-07)
**Cuts in this phase:** C4 (Pattern 5 Hard planning checks → normative summary + pointer), C5 (Pattern 1 Step 2 dimension hard-checks → cross-refs to owning homes).
**File edited:** `templates/SHAMT_RULES.template.md` only.

> **Deploy order:** runs after Phase 2. Pattern 1 and Pattern 5 were not touched by Phases 1–2; use the text anchors (line numbers shifted).

---

## Step 1: C4 — condense Pattern 5 Hard planning checks to a normative summary (proposal row 4)
**Operation:** EDIT
**File:** `templates/SHAMT_RULES.template.md`

**Coverage proof (run FIRST):**
```
grep -ciE "writer rout|tenant-A-to-tenant-B|transitive call|byte-for-byte|row-level security|RLS|manifest" reference/implementation_plan_reference.md   # expanded detail lives here → ≥3
```
Must return ≥3. If lower, **halt** — keep the detailed checks inline. The summary below **keeps every MUST** as a one-clause item; only the expanded sub-explanations (already in the reference) are trimmed.

**Details — one block replacement:**
- **Locate** the span from the line `**Hard planning checks:**` through the line ending `…See \`reference/implementation_plan_reference.md\` for expanded examples.` (the bulleted Hard-planning-checks list inside Pattern 5 Step 2).
- **Replace** that entire span with exactly:

````
**Hard planning checks** (each maps to a concrete step, a verification, or an explicit N/A before validation; expanded per-check detail in `reference/implementation_plan_reference.md`):

- every applicable review-prevention item from spec/context is covered;
- DB write paths trace direct **and** transitive writes and decide writer routing before any build step;
- new/changed services or routes have manifest coverage — handler, application module, route module, monitoring template, packaging, environment, IAM/secrets, log retention, networking, deployment/stage — or explicit N/A;
- tenant/path/object/document changes plan a tenant-A-to-tenant-B bypass verification (or state why it cannot run);
- removed/weakened checks get a replacement analysis before the code-edit step;
- new service handlers enumerate the transitive call graph for imported shared utilities, reachable environment-variable keys, and reachable external-resource accesses, adding missing symbol/env/IAM steps before proceeding;
- byte-for-byte copy files verify every called function has identical signature/behavior in every repo maintaining that file (else place the function repo-specifically and record why);
- each applicable `.shamt-core/project-specific-files/CODING_STANDARDS.md` rule maps to a step or explicit N/A in `## CODING_STANDARDS Compliance` (saying it was read is insufficient);
- migration CREATE steps cover table creation, any required row-level-security policy in the same block, and information-schema verification.
````

**Verification (every MUST survives as a summary clause):**
```
grep -c "decide writer routing before any build step" templates/SHAMT_RULES.template.md          # → 1
grep -c "tenant-A-to-tenant-B bypass verification" templates/SHAMT_RULES.template.md             # → 1
grep -c "row-level-security policy in the same block" templates/SHAMT_RULES.template.md           # → 1
grep -c "byte-for-byte copy files verify" templates/SHAMT_RULES.template.md                      # → 1
grep -c "transitive call graph for imported shared utilities" templates/SHAMT_RULES.template.md  # → 1
```

---

## Step 2: C5 — replace Pattern 1 Step 2 dimension hard-checks with cross-refs (proposal row 5)
**Operation:** EDIT
**File:** `templates/SHAMT_RULES.template.md`

**Coverage proof (run FIRST — each cross-ref target must own the rule; an unconfirmed check STAYS INLINE):**
```
grep -c "trace the end-to-end cross-service read and write data lineage" templates/SHAMT_RULES.template.md   # Pattern 3 owns specs data-lineage → ≥1 (after Phase 2)
grep -cE "no optional branches|exact locate string|concrete workspace-relative path" templates/SHAMT_RULES.template.md   # Pattern 5 owns plans checks → ≥1
grep -ci "deleted or weakened security checks require boundary analysis and bypass tracing" reference/review_categories.md   # review_categories owns reviews checks → 1
```
All must pass. If any is 0, keep the affected hard-check **inline** (do not cross-ref it).

**Details — three sub-edits (replace only the "Hard checks: …" tail of each dimension line; keep the dimension-name list intact):**

- **2a — Specs dimension (Pattern 1 Step 2).**
  - **Locate:** `Standards/architecture alignment. Hard checks: multi-option designs must give each option explicit pros/cons; Open Questions must first be code-researched and cannot contain answerable file/function/column questions; every applicable review-prevention surface has a spec requirement plus evidence or an explicit N/A or deferred reason; when database schema, tables, or columns are modified or added, the spec must explicitly trace the end-to-end cross-service read and write data lineage of both writes (saving) and reads/queries (loading at runtime), ensuring all backend, admin, and backchannel retrieval paths are accounted for.`
  - **Replace:** `Standards/architecture alignment. Hard checks: per Pattern 3 (Spec Protocol) — multi-option pros/cons (Step 4), Open-Questions-answered-from-code (Step 5), the review-prevention surface inventory and the end-to-end cross-service data-lineage trace for schema changes (Step 5).`

- **2b — Implementation Plans dimension (Pattern 1 Step 2).**
  - **Locate:** `Naming clarity. Hard checks: no optional / if / consider executor branches; EDIT steps need exact locate/replace; CREATE steps need concrete paths; imports listed for a file must be used there; every applicable review-prevention gate maps to concrete implementation step(s), verification, or explicit N/A reason.`
  - **Replace:** `Naming clarity. Hard checks: per Pattern 5 (Implementation Planning) — no optional/if/consider branches, exact locate/replace, concrete CREATE paths, and review-prevention-gate mapping; plus imports listed for a file must be used there.`
  - *(Note: "imports must be used" is kept inline — it is not separately stated in Pattern 5, per the mitigation.)*

- **2c — Code Reviews dimension (Pattern 1 Step 2).**
  - **Locate:** `Standards/architecture alignment. Hard checks: review every changed file/function/branch independently; do not assume parallel files are identical; review removed or weakened security checks and verify equivalent protection still exists; for tenant/path/object/document access changes, explicitly consider a tenant-A-to-tenant-B bypass.`
  - **Replace:** `Standards/architecture alignment. Hard checks: review every changed file/function/branch independently and do not assume parallel files are identical; for removed/weakened security checks and tenant/path/object/document access changes, per \`reference/review_categories.md\` (boundary analysis + tenant-A→B bypass tracing).`
  - *(Note: "review every file independently / do not assume parallel identical" is kept inline — review_categories.md owns the removed-checks/tenant-bypass items, line 29; the independence check stays here.)*

**Verification (cross-refs in place; no rule lost):**
```
grep -c "per Pattern 3 (Spec Protocol)" templates/SHAMT_RULES.template.md     # → 1 (specs cross-ref)
grep -c "per Pattern 5 (Implementation Planning)" templates/SHAMT_RULES.template.md   # → 1 (plans cross-ref)
grep -c "per \`reference/review_categories.md\`" templates/SHAMT_RULES.template.md     # → 1 (reviews cross-ref)
grep -c "imports listed for a file must be used there" templates/SHAMT_RULES.template.md   # → 1 (kept inline)
grep -c "review every changed file/function/branch independently" templates/SHAMT_RULES.template.md   # → 1 (kept inline)
# the data-lineage rule still exists somewhere canonical (Pattern 3 Step 5), now NOT duplicated in Pattern 1:
grep -c "trace the end-to-end cross-service read and write data lineage" templates/SHAMT_RULES.template.md   # → 1 (only Pattern 3 now; the Pattern-1 restatement is gone)
```

---

## Phase 3 exit
- C4: Pattern 5 hard-checks condensed to a MUST-preserving summary + pointer.
- C5: Pattern 1 Step 2 hard-checks cross-ref'd to owning homes (Pattern 3 / Pattern 5 / review_categories.md), with uncertain-owner checks kept inline.
- `wc -m templates/SHAMT_RULES.template.md` ≈ **31,000** (informational). **No commit.** Next: Phase 4 (C6 + final measure).

---

## Notes
- The data-lineage trace now lives **once** (Pattern 3 Step 5) — Phase 2 kept it there, Phase 3 C5 removes the Pattern-1 duplicate via cross-ref. The Phase-3 verification confirms exactly one occurrence remains.
- Only `templates/SHAMT_RULES.template.md` is edited. Cross-ref targets (Pattern 3/5 in-file; `review_categories.md`, `implementation_plan_reference.md`) are not edited. No `.claude/`, no commit.

---
Validated 2026-06-08 — adversarial sub-agent confirmed. C4 condenses Pattern 5's hard-checks to a MUST-preserving summary (every check kept as a clause; expanded detail verified present in implementation_plan_reference.md). C5 cross-refs the Pattern-1 Step-2 hard-checks to their genuine owners (Specs→Pattern 3 Step 5; Plans→Pattern 5 contract; Reviews→reference/review_categories.md — NOT Pattern 4's steps), keeping uncertain-owner checks ("imports must be used", "review every file independently") inline. Data-lineage de-dup verified to leave exactly one canonical occurrence (Pattern 3 Step 5).
