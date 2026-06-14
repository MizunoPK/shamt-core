# Proposal: po-draft-stub-skills-incremental-decomposition

**Created:** 2026-06-12
**Status:** Draft
**Number:** 26
**Proposed by:**
**Project context:**

---

## Problem

The PO flow today produces stubs only as a **one-shot batch** and names its commands in a flat, altitude-mixed sequence (`/p1`–`/p6`). `/p2-decompose-epic` writes the full set of feature stubs under an epic in a single gated pass (`host/templates/claude/commands/p2-decompose-epic.md` Steps 5–9), and `/p4-decompose-feature` does the same for story stubs under a feature. There is no first-class, lightweight entry point for the *incremental* case the PO actually hits in practice: "this epic already exists — draft **one more** feature under it" or "this feature already exists — draft **one more** story under it."

The only existing path for adding to an already-decomposed parent is the **re-decomposition** branch (`/p2-decompose-epic` Step 3 / `/p4-decompose-feature` Step 3 — the Kept / New / Orphaned partition). That path is heavyweight and wrong-shaped for a single addition: it re-presents and re-gates the *entire* list, wholesale-rewrites the parent's `## Target Features` / `## Target Stories` + `## Sequencing & Parallelization` sections (Step 9), and emits orphan warnings for anything dropped. Adding one item should not require re-asserting the whole decomposition.

There is also no quick **idea-capture** stage in the PO flow. The framework-update flow has `/f0-draft-proposal` (`host/templates/claude/commands/f0-draft-proposal.md`): a bare-bones capture of a raw idea that `/f1-propose-update` later *ingests* and fleshes out. The PO flow has no equivalent — `/p1-start-epic` / `/p3-start-feature` jump straight into the full open-questions dialog, and `/p6-draft-tech-story` is the only single-stub fast path but is hard-wired to the standing Tech Stories epic's `bugs`/`quick-wins` features (`host/templates/claude/commands/p6-draft-tech-story.md`), not generalizable to arbitrary parents.

**This proposal reorganizes the PO flow into a uniform altitude × stage grid** and adds the missing draft (idea-capture) and incremental single-stub paths. Commands become `/p{e|f|s}{N}-{stage}` — prefix by altitude (`pe` = epic, `pf` = feature, `ps` = story), number by stage:

| altitude | stage 0 — `draft` | stage 1 — `define` | stage 2 — `decompose` | stage 3 — `finalize` |
|---|---|---|---|---|
| **epic** (`pe`) | `/pe0-draft` | `/pe1-define` | `/pe2-decompose` | `/pe3-finalize` |
| **feature** (`pf`) | `/pf0-draft` | `/pf1-define` | `/pf2-decompose` | — |
| **story** (`ps`) | `/ps0-draft` | `/ps1-define` | — | — |

- **draft (stage 0)** — an `/f0`-style bare-bones capture of the user's raw idea, runnable **at any point**. `/pf0-draft {epic-slug}` and `/ps0-draft {feature-slug | bugs | quick-wins}` take a slug naming the parent to place the new stub under; `/pe0-draft` (epics are top-level) takes none. This is what delivers the incremental need — a single feature/story stub can be drafted under an existing parent any time, without re-running decompose. The define stage *ingests* a stage-0 draft the way `/f1-propose-update` ingests an f0 draft.
- **define (stage 1)** — flesh out that file via the open-questions iterative dialog. The PO is a manager writing/polishing a ticket for an engineer: `/ps1-define` runs the dialog **plus a Pattern-1 validation loop**, producing a ready, validated planning `ticket.md`. Define is also runnable standalone (no prior draft) — it then seeds + fleshes from scratch the way `/p1-start-epic` / `/p3-start-feature` do today.
- **decompose (stage 2)** — epic & feature only; batch-create the next altitude's stub files (today's `/p2` / `/p4`, including the re-decomposition partition logic, carried forward unchanged). Decompose is the *batch* producer; draft is the *single* producer — both emit the same stub shape that define ingests.
- **finalize (stage 3)** — epic only; today's `/p5-finalize-epic`, renamed for grid consistency.

`/p6-draft-tech-story` is **deprecated and folded into `/ps0-draft`** (a tech story is just a story drafted under the Tech Stories epic's `bugs`/`quick-wins` feature). Old `/p1`–`/p6` are cleanly replaced (renamed/deleted) with no legacy aliases. On the consumer side, `/e1-start-story` stays the Engineer-flow entry but gains a **ready-ticket pickup branch**: when it detects a `/ps1-define`-validated planning ticket it does tracker fetch/reconcile + confirm instead of re-authoring intake (full freeform/tracker intake still applies for ad-hoc, non-PO stories).

The reorganization must reconcile against the nested-folder layout (proposal #14, `templates/SHAMT_RULES.template.md` §PO-tree resolution): global slug uniqueness, ticket-ID allocation (`# Ticket IDs`), parentage-is-the-path, the `## Decomposition Context` breadth section, and the `Decomposed YYYY-MM-DD — …` parent line must all be honored when a single stub is appended into an existing subtree.

---

## Proposed Changes

> **Row count > 10 — Phase 3 required.** Run `/f2-plan-update-implementation 26-po-draft-stub-skills-incremental-decomposition` (after validation) to mechanically decompose this table before `/f3-implement-update`.
>
> **MOVE convention:** each `MOVE` row is a `git mv` (to preserve history) **plus a body rewrite** to the new stage semantics; per the template's path discipline a MOVE decomposes into paired CREATE + DELETE — Phase 3 will expand them. Each command rename is paired with its mirrored skill rename.

### A. New command + skill pairs (draft / new-define)

| # | Canonical path | Operation | One-line change description |
|---|----------------|-----------|------------------------------|
| 1 | `shamt-core/host/templates/claude/commands/pe0-draft.md` | CREATE | Epic stage-0 draft: f0-style bare epic-idea capture into `epics/{ID}-{slug}-{brief}/epic.md` (Scratch Notes + draft status), runnable any time; suggests `/pe1-define`. |
| 2 | `shamt-core/host/templates/claude/skills/pe0-draft/SKILL.md` | CREATE | Mirror skill for `/pe0-draft`. |
| 3 | `shamt-core/host/templates/claude/commands/pf0-draft.md` | CREATE | Feature stage-0 draft under an existing epic: `/pf0-draft {epic-slug}` writes one feature stub (Goal/idea + `## Decomposition Context`) and appends it to the parent epic's Target Features without re-gating the batch. |
| 4 | `shamt-core/host/templates/claude/skills/pf0-draft/SKILL.md` | CREATE | Mirror skill for `/pf0-draft`. |
| 5 | `shamt-core/host/templates/claude/commands/ps0-draft.md` | CREATE | Story stage-0 draft under an existing feature: `/ps0-draft {feature-slug \| bugs \| quick-wins}` writes one story-ticket stub and appends to the parent feature. **Absorbs `/p6-draft-tech-story`** (tech story = story drafted under Tech Stories `bugs`/`quick-wins`). |
| 6 | `shamt-core/host/templates/claude/skills/ps0-draft/SKILL.md` | CREATE | Mirror skill for `/ps0-draft`. |
| 7 | `shamt-core/host/templates/claude/commands/ps1-define.md` | CREATE | Story stage-1 define: flesh out the planning `ticket.md` via the open-questions dialog **plus a Pattern-1 validation loop**, producing a ready-for-engineer validated ticket; ingests a `/ps0-draft` stub when present; suggests `/e1-start-story`. |
| 8 | `shamt-core/host/templates/claude/skills/ps1-define/SKILL.md` | CREATE | Mirror skill for `/ps1-define`. |

### B. Renamed command + skill pairs (git mv + body rewrite)

| # | Canonical path | Operation | One-line change description |
|---|----------------|-----------|------------------------------|
| 9 | `commands/p1-start-epic.md` → `commands/pe1-define.md` | MOVE | Epic define; add stage-0-draft ingestion input mode; update self-references + next-phase suggestion to `/pe2-decompose`. |
| 10 | `skills/p1-start-epic/` → `skills/pe1-define/` (SKILL.md) | MOVE | Mirror skill rename + body update. |
| 11 | `commands/p2-decompose-epic.md` → `commands/pe2-decompose.md` | MOVE | Epic decompose (batch); carry forward re-decomposition logic; cross-ref `/pf0-draft` as the single-add alternative; next-phase → `/pf1-define`. |
| 12 | `skills/p2-decompose-epic/` → `skills/pe2-decompose/` (SKILL.md) | MOVE | Mirror skill rename + body update. |
| 13 | `commands/p3-start-feature.md` → `commands/pf1-define.md` | MOVE | Feature define; add stage-0-draft ingestion; update self-refs + next-phase → `/pf2-decompose`. |
| 14 | `skills/p3-start-feature/` → `skills/pf1-define/` (SKILL.md) | MOVE | Mirror skill rename + body update. |
| 15 | `commands/p4-decompose-feature.md` → `commands/pf2-decompose.md` | MOVE | Feature decompose (batch); carry forward re-decomposition + individually-testable rubric; cross-ref `/ps0-draft`; next-phase → `/ps1-define`. |
| 16 | `skills/p4-decompose-feature/` → `skills/pf2-decompose/` (SKILL.md) | MOVE | Mirror skill rename + body update. |
| 17 | `commands/p5-finalize-epic.md` → `commands/pe3-finalize.md` | MOVE | Epic finalize, renamed for grid consistency; update self-refs. |
| 18 | `skills/p5-finalize-epic/` → `skills/pe3-finalize/` (SKILL.md) | MOVE | Mirror skill rename + body update. |

### C. Deletions

| # | Canonical path | Operation | One-line change description |
|---|----------------|-----------|------------------------------|
| 19 | `shamt-core/host/templates/claude/commands/p6-draft-tech-story.md` | DELETE | Folded into `/ps0-draft` (rows 5–6); the standing-feature archive note moves into `/ps0-draft` + the rules §Standing Tech Stories epic. |
| 20 | `shamt-core/host/templates/claude/skills/p6-draft-tech-story/SKILL.md` | DELETE | Mirror skill removed. |

### D. Consumer-side edits (Engineer-flow boundary)

| # | Canonical path | Operation | One-line change description |
|---|----------------|-----------|------------------------------|
| 21 | `shamt-core/host/templates/claude/commands/e1-start-story.md` | EDIT | Add the **ready-ticket pickup branch** (detect a `/ps1-define`-validated planning ticket → tracker fetch/reconcile + confirm, skip re-authoring); update `/p4`/`/p6` references to `/pf2-decompose` / `/ps0-draft`. |
| 22 | `shamt-core/host/templates/claude/skills/e1-start-story/SKILL.md` | EDIT | Mirror the e1 body changes. |
| 23 | `shamt-core/host/templates/claude/commands/e8-finalize-story.md` | EDIT | Update tech-stories archive + `/p6`/`/p4` references to the new command names. |
| 24 | `shamt-core/host/templates/claude/skills/e8-finalize-story/SKILL.md` | EDIT | Mirror the e8 body changes. |

### E. Reference + template + rules cross-refs

| # | Canonical path | Operation | One-line change description |
|---|----------------|-----------|------------------------------|
| 25 | `shamt-core/README.md` | EDIT | Rewrite the PO-flow section: grid diagram + command table (`pe/pf/ps` × stages), tech-stories note (`/p6` → `/ps0-draft`), hierarchy/parentage references. |
| 26 | `shamt-core/templates/SHAMT_RULES.template.md` | EDIT | Update the PO-flow overview, §Standing Tech Stories epic (entry now `/ps0-draft`), and §"Stub IDs are preserved" (producer commands renamed). |
| 27 | `shamt-core/reference/model_selection.md` | EDIT | Replace the `/p5-finalize-epic` row; add rows for the new draft/define/decompose grid commands with recommended tiers. |
| 28 | `shamt-core/reference/trackers/_contract.md` | EDIT | Update command references + the supported-types table rows (`/p1-start-epic` → `/pe1-define`, `/p3-start-feature` → `/pf1-define`). |
| 29 | `shamt-core/reference/trackers/ado.md` | EDIT | Update `/p1-start-epic` / `/p3-start-feature` references to the new names. |
| 30 | `shamt-core/reference/trackers/github.md` | EDIT | Update `/p1-start-epic` / `/p3-start-feature` references to the new names. |
| 31 | `shamt-core/reference/trackers/local.md` | EDIT | Update `/p1-start-epic` / `/p3-start-feature` / `/p4-decompose-feature` references to the new names. |
| 32 | `shamt-core/templates/epic.template.md` | EDIT | Update decomposition-owner references (`/p2` → `/pe2-decompose`); document the stage-0 draft-capture convention (Scratch Notes + draft status, ingested by `/pe1-define`). |
| 33 | `shamt-core/templates/feature.template.md` | EDIT | Update owner references (`/p3` → `/pf1-define`, `/p4` → `/pf2-decompose`); document the stage-0 draft-capture convention. |
| 34 | `shamt-core/templates/ticket.ado.template.md` | EDIT | Update PO-flow command references; note the stage-0 story-draft capture convention. |
| 35 | `shamt-core/templates/ticket.github.template.md` | EDIT | Update PO-flow command references; note the stage-0 story-draft capture convention. |

**Path discipline:** all paths are canonical (no `.claude/`). Every renamed/new command is paired with its mirrored skill. The draft↔define ingestion convention mirrors the existing f0→f1 pattern.

---

## Risks

- **Regression risk (decompose vs. draft overlap)** — both decompose (batch) and draft (single) now write stubs the define stage ingests; the stub shapes must stay identical or define will mishandle one. The incremental-add path in `/pf0-draft` / `/ps0-draft` must append to the parent's `## Target Features` / `## Target Stories` + `Decomposed …` line without corrupting the format the re-decomposition partition (carried forward in `/pe2-decompose` / `/pf2-decompose`) reads.
- **Engineer-boundary regression** — the new `/e1-start-story` ready-ticket pickup branch must not break the existing freeform/tracker intake for ad-hoc stories. Misdetection (treating an ad-hoc ticket as a ready planning ticket, or vice-versa) would skip or duplicate intake.
- **Drift risk** — 8 new + 10 renamed command/skill files plus deletions; canonical ↔ generated `.claude/` parity is large-surface. Every rename must move *both* the command and its skill, and `/f4-regen-framework --check` must show zero drift.
- **Cross-reference completeness** — `/p1`–`/p6` are referenced across README, the rules template, model_selection, all four tracker profiles, epic/feature/ticket templates, and the e1/e8 bodies. A missed reference leaves a dangling command name (D4 reference-validity audit finding).
- **Child-project compatibility** — installed children lose the old `/p1`–`/p6` names on the next `import-shamt` and gain the new grid. Any child docs/muscle-memory referencing old names break; this is an intentional clean cutover (no aliases). Call it out in the changelog so child maintainers re-learn the grid.
- **Archived-history references** — `proposals/archive/*` and other historical docs reference `/p1`–`/p6`; these are **not** rewritten (history is immutable). Only active canonical surfaces are updated.
- **Open-questions debt** — all architecture decisions are resolved below; none deferred to the implementer.

---

## Rollback Plan

1. `git revert` the canonical-edit commit (or `git reset` the proposal branch before merge).
2. Run `/f4-regen-framework` to propagate the revert into `.claude/` — restoring the old `/p1`–`/p6` command + skill set and removing the new grid files.
3. Child-side: each installed child re-runs `/sync-import-shamt` to restore the prior command set. Because the cutover is a clean rename, a child mid-flight on an old-named command at revert time finishes against the reverted (old) names — no artifact migration is needed (the on-disk `epic.md` / `feature.md` / `ticket.md` artifacts are unchanged by the command rename; only command names and a draft-capture convention move).
4. Communicate the revert to child maintainers (same audience told about the cutover).

Not a one-line additive rollback — this proposal renames/deletes existing commands, so revert must restore them and regen must run.

---

## Validation Considerations

- **Problem clarity** — the sharpest confusion is *decompose (batch) vs. draft (single)* and *re-decomposition vs. incremental draft*. The validator should confirm the proposal states precisely when each is used and that draft/decompose emit an identical stub shape.
- **Change-list completeness** — the highest-risk omissions: (a) a renamed command whose **mirrored skill** rename is missing; (b) a `/p1`–`/p6` reference site not in the table — re-grep the full tree (`grep -rn '/p[1-6]\b\|p[1-6]-\(start\|decompose\|finalize\|draft\)'`) at validation time and amend in place if any new site appears; (c) the e1 ready-ticket branch's mirror in `e1-start-story/SKILL.md`. Tracker profiles, model_selection, epic/feature/ticket templates, README, and rules are all listed — verify none were dropped.
- **Risk coverage** — confirm the e1 misdetection scenario and the parent-line-corruption scenario are addressed by the eventual command bodies.
- **Rollback feasibility** — the renames are `git mv` (history-preserving) + rewrite; verify revert restores both files per rename and that no DELETE loses unrecoverable content (`/p6` content is preserved by being folded into `/ps0-draft`, not lost).
- **Affected surfaces** — commands, skills, references (trackers + model_selection), templates (epic/feature/ticket), rules, README. PO altitude only on the producer side; one consumer-side touch (e1/e8). No scripts or statusline (statusline reads pointers, not command names — verified).
- **Propagation plan** — requires `/f4-regen-framework` + child `import-shamt`. Phase 3 (`/f2-plan-update-implementation`) is **required** (row count 35 > 10) before `/f3-implement-update`.

---

## Open Questions

_None — all resolved (see below)._

---

## Resolved Questions

- ~~Q: New `draft-*` commands vs. additive mode on existing decompose commands vs. lean on re-decomposition?~~ → A: Neither in isolation — the user rescoped to a full reorganization of the PO flow into a uniform `p{e|f|s}{N}-{stage}` grid (draft / define / decompose), where the stage-0 **draft** command is the lightweight single-stub / idea-capture producer and **decompose** stays the batch producer.
- ~~Q: Command grid + stage numbering?~~ → A: Confirmed: `pe`/`pf`/`ps` prefixes; stages `0-draft`, `1-define`, `2-decompose`. Epic + feature have all three; story has draft + define only (story is the leaf — no decompose).
- ~~Q: How does `/ps1-define` relate to `/e1-start-story`?~~ → A: `/ps1-define` is the manager polishing the ticket — open-questions dialog **+ a Pattern-1 validation loop** producing a ready, validated planning ticket. `/e1-start-story` stays as the Engineer-flow entry.
- ~~Q: After `/ps1-define`, where does the engineer pick up, and what happens to `/e1-start-story`?~~ → A: Keep `/e1` as a lightweight **ready-ticket pickup** (detect the validated PO ticket → tracker fetch/reconcile + confirm → `/e2`…`/e8`); `/e1` retains full intake for ad-hoc, non-PO stories.
- ~~Q: Where does epic finalize (`/p5-finalize-epic`) go?~~ → A: Folded into the grid as stage 3: `/pe3-finalize` (epic lane). Feature has no finalize; story finalize stays `/e8`.
- ~~Q: How are the old `/p1`–`/p6` commands retired?~~ → A: Clean replacement — rename command + skill files to the grid names, rewrite bodies, delete `/p6` (folded into `/ps0-draft`). No legacy aliases; archived/historical references are left untouched.
- ~~Q: (derived) Draft-stage shape + define ingestion?~~ → A: Per the user's "similar to a `/f0` call" — draft writes a bare file (Scratch-Notes-style idea capture + a distinct draft status), and define **ingests** it the way `/f1-propose-update` ingests an f0 draft; define is also runnable standalone (seed + flesh from scratch) when no prior draft exists.
