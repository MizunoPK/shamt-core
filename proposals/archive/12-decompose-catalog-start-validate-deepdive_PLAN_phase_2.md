# Implementation Plan — Phase 2 — decompose-catalog-start-validate-deepdive (#12)

**Created:** 2026-06-09
**Index:** `proposals/12-decompose-catalog-start-validate-deepdive_PLAN.md`
**Proposal:** `proposals/12-decompose-catalog-start-validate-deepdive.md` (Validated 2026-06-09)
**Cuts in this phase:** proposal rows 4, 5, 6, 7 — the decompose side (`/p2`, `/p4` + skills) populates the breadth boundary + `## Decomposition Context` and strengthens the exit gate.
**Files edited:** `host/templates/claude/commands/{p2-decompose-epic,p4-decompose-feature}.md` + their skills.

> **Deploy order:** runs after Phase 1 (the section now exists in the templates). Re-confirm anchors against the live files.

---

## Step 1: p2-decompose-epic command — populate breadth content (proposal row 4)
**Operation:** EDIT — `host/templates/claude/commands/p2-decompose-epic.md`

- **1a — Step 8: populate `## Scope / Non-Scope` + `## Decomposition Context`.**
  - **Locate:**
````
  - `## Goal` — the one-liner approved by the user in Step 5.
  - All other sections (`Open Questions`, `Success Criteria`, `Scope / Non-Scope`, `Target Stories`, `Sequencing & Parallelization`) are **left empty** — `/p3-start-feature {feature-slug}` and `/p4-decompose-feature {feature-slug}` flesh them out later.
````
  - **Replace:**
````
  - `## Goal` — the one-liner approved by the user in Step 5.
  - `## Scope / Non-Scope` — the feature's breadth **boundary**: what it covers vs. explicitly does not, drawn from the whole-set research (the in/out line, not detailed acceptance criteria). Fill `### In Scope` / `### Out of Scope` with the boundary as understood at decomposition; `/p3-start-feature` refines depth later.
  - `## Decomposition Context` — the bounded breadth bullets (dependencies on siblings, shared context, boundary rationale) discovered while researching the feature set. Replace the placeholder bullets with real content, or mark "none". **NOT a depth dump** — design / acceptance / implementation detail is `/p3-start-feature`'s job.
  - All other sections (`Open Questions`, `Success Criteria`, `Target Stories`, `Sequencing & Parallelization`) are **left empty** — `/p3-start-feature {feature-slug}` deepens `Success Criteria` + `Open Questions`; `/p4-decompose-feature {feature-slug}` fills `Target Stories` + `Sequencing & Parallelization` later.
````

- **1b — Step 6: add a 3rd exit-gate condition (cataloged breadth present).**
  - **Locate:** `2. **Every feature appears in the parent epic's \`Sequencing & Parallelization\` analysis** — either in the \`Recommended order\` enumeration, or in the \`Parallelizable\` callout, or both.`
  - **Replace:** `2. **Every feature appears in the parent epic's \`Sequencing & Parallelization\` analysis** — either in the \`Recommended order\` enumeration, or in the \`Parallelizable\` callout, or both.
3. **Every feature has its breadth content prepared** — a scope boundary (in/out) and the \`## Decomposition Context\` bullets (dependencies, shared context, boundary rationale) are ready to write from the whole-set research, with no blanks/TBD (use "none" where genuinely empty). This is a presence check on the prepared batch — **still distinct from \`/validate-artifact\`**, not a Pattern-1 loop.`

**Verification:** `grep -Fc "the feature's breadth **boundary**" host/templates/claude/commands/p2-decompose-epic.md` → `1`; `grep -Fc "Every feature has its breadth content prepared" host/templates/claude/commands/p2-decompose-epic.md` → `1`; `grep -Fc "Scope / Non-Scope\`, \`Target Stories" host/templates/claude/commands/p2-decompose-epic.md` → `0` (Scope/Non-Scope removed from the "left empty" list).

---

## Step 2: p2-decompose-epic skill — mirror (proposal row 5)
**Operation:** EDIT — `host/templates/claude/skills/p2-decompose-epic/SKILL.md`
- **Locate:** `back-ref + Goal one-liner; all other sections empty)`
- **Replace:** `back-ref + Goal one-liner + a Scope/Non-Scope boundary + a Decomposition Context breadth section; depth sections empty)`

**Verification:** `grep -Fc "Decomposition Context breadth section" host/templates/claude/skills/p2-decompose-epic/SKILL.md` → `1`.

---

## Step 3: p4-decompose-feature command — populate breadth content (proposal row 6)
**Operation:** EDIT — `host/templates/claude/commands/p4-decompose-feature.md`

- **3a — Step 8: populate `## Decomposition Context`** (the scope one-liner already populated above is the story's breadth boundary; the ticket template has no `## Scope / Non-Scope` section).
  - **Locate:** `  - Other template sections (Summary, Description, Acceptance Criteria, Related Work, Comments, Update History, All Remaining Fields, Open Questions, etc.) are **left empty / placeholder** as they appear in the template. This matches how a freeform \`/e1-start-story\` would leave them; \`/e1-start-story\` (stub-aware) fills them in later.`
  - **Replace:** `  - **\`## Decomposition Context\` section:** populate the bounded breadth bullets (dependencies on siblings, shared context, boundary rationale) discovered while researching the story set; replace the placeholder bullets or mark "none". **NOT a depth dump** — acceptance / spec detail is the Engineer flow's job. (The scope one-liner written above is this story's breadth boundary — the ticket template has no \`## Scope / Non-Scope\` section.)
  - Other template sections (Summary, Description, Acceptance Criteria, Related Work, Comments, Update History, All Remaining Fields, Open Questions, etc.) are **left empty / placeholder** as they appear in the template. This matches how a freeform \`/e1-start-story\` would leave them; \`/e1-start-story\` (stub-aware) fills them in later.`

- **3b — Step 6: add a 3rd exit-gate condition.**
  - **Locate:** `2. **Every story appears in the parent feature's \`Sequencing & Parallelization\` analysis** — either in the \`Recommended order\` enumeration, or in the \`Parallelizable\` callout, or both.`
  - **Replace:** `2. **Every story appears in the parent feature's \`Sequencing & Parallelization\` analysis** — either in the \`Recommended order\` enumeration, or in the \`Parallelizable\` callout, or both.
3. **Every story has its breadth content prepared** — the scope one-liner (its breadth boundary) and the \`## Decomposition Context\` bullets (dependencies, shared context, boundary rationale) are ready to write from the whole-set research, no blanks/TBD (use "none" where empty). Presence check on the prepared batch — **still distinct from \`/validate-artifact\`**.`

**Verification:** `grep -Fc "the bounded breadth bullets (dependencies on siblings" host/templates/claude/commands/p4-decompose-feature.md` → `1`; `grep -Fc "Every story has its breadth content prepared" host/templates/claude/commands/p4-decompose-feature.md` → `1`.

---

## Step 4: p4-decompose-feature skill — mirror (proposal row 7)
**Operation:** EDIT — `host/templates/claude/skills/p4-decompose-feature/SKILL.md`
- **Locate:** `H1 plus the scope one-liner in the body intake area; all other template`
- **Replace:** `H1 plus the scope one-liner in the body intake area + a Decomposition Context breadth section; all other template`

**Verification:** `grep -Fc "Decomposition Context breadth section" host/templates/claude/skills/p4-decompose-feature/SKILL.md` → `1`.

---

## Phase 2 exit
- `/p2` populates each feature stub's `## Scope / Non-Scope` boundary + `## Decomposition Context`; `/p4` populates each story stub's scope one-liner (boundary) + `## Decomposition Context`. Both Step-6 exit gates gained a 3rd condition (breadth content prepared), still distinct from `/validate-artifact`. Skills mirror.
- **No commit.** Phase 3 (start-* consumes the seed) is the remaining phase.

---

## Notes
- **No normative rule dropped.** The edits expand the "Populate only these fields" lists + add an exit-gate condition; the Kept/New partitioning, template-selection rule, and "do not conflate the gate with /validate-artifact" notes are untouched.
- Only `host/templates/claude/` files edited → `/f4-regen-framework` propagates them. No `.claude/`, no commit.

---
Validated 2026-06-09 — 1 round, 1 adversarial sub-agent confirmed
