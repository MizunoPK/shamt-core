# Implementation Plan: dot-shamt-core-layout

**Proposal:** proposals/dot-shamt-core-layout.md
**Created:** 2026-05-28
**File operations:** 49 canonical files (all EDIT; `scripts/regenerate-framework.sh` is a verify-only NO-OP). MOVE/CREATE/DELETE semantics live inside the two `.sh` scripts' runtime logic, not in canonical file ops.

This is an **index plan**, decomposed into five phase files (Principle 1 single-session sizing constraint — the sweep would compact a single Phase-4 session). Each phase file is validated independently via `/validate-artifact` and carries its own footer. Execute the phases in order 1 → 5; there are no cross-phase ordering dependencies beyond "scripts before docs before generated-template sweeps," and no phase reads another phase's output.

| Phase file | Surface | Files | Operation class |
|------------|---------|-------|-----------------|
| [`_PLAN_phase_1.md`](dot-shamt-core-layout_PLAN_phase_1.md) | Scripts | `init-shamt.sh`, `import-shamt.sh`, `scripts/regenerate-framework.sh`, `host/templates/claude/statusline.sh` | Logic edits (gated relocations, precheck reorder, completion prompt) + 1 NO-OP verify |
| [`_PLAN_phase_2.md`](dot-shamt-core-layout_PLAN_phase_2.md) | Root docs + rules template | `CHEATSHEET.md`, `CLAUDE.md`, `templates/SHAMT_RULES.template.md` | Layout-diagram rewrite + path sweeps |
| [`_PLAN_phase_3.md`](dot-shamt-core-layout_PLAN_phase_3.md) | Commands | 18 `host/templates/claude/commands/*.md` | config / doc / proposals / install-path sweeps |
| [`_PLAN_phase_4.md`](dot-shamt-core-layout_PLAN_phase_4.md) | Skills | 16 `host/templates/claude/skills/*/SKILL.md` | config / doc / proposals / install-path sweeps |
| [`_PLAN_phase_5.md`](dot-shamt-core-layout_PLAN_phase_5.md) | Agents + templates + reference | 4 agents, 10 templates, 8 reference docs | config / doc sweeps |

## Pre-execution checklist (applies to every phase)

- [ ] On a clean working tree (or working in a worktree dedicated to this proposal).
- [ ] `proposals/dot-shamt-core-layout.md` validation footer present (it is — `Validated 2026-05-28`).
- [ ] Each phase file carries its own `/validate-artifact` footer before its Phase-4 execution.
- [ ] Branch created: `framework-update/dot-shamt-core-layout` from the configured remote development branch.
- [ ] **Never edit `.claude/`.** Every step below targets canonical sources only; regen (Phase 5 of the framework-update flow, via `/regen-framework`) propagates into `.claude/` afterward.

## Replacement conventions (the four mechanical sweeps)

Every EDIT step below is one of these deterministic substitutions, applied only to **child-side** occurrences (master-canonical strings — those written with a bare `shamt-core/` prefix describing master's own repo layout — are left unchanged):

1. **CONFIG (Group D):** `shamt-config.json` → `.shamt-core/shamt-config.json`. Never touch `shamt-config.example.json`.
2. **PROJECT DOCS (Group E):** `ARCHITECTURE.md` → `.shamt-core/project-specific-files/ARCHITECTURE.md`; `CODING_STANDARDS.md` → `.shamt-core/project-specific-files/CODING_STANDARDS.md`. The section-label `**Architecture impact:**` is NOT the file — never rewrite it.
3. **PROPOSALS (Group F):** child-side `proposals/…` → `.shamt-core/proposals/…`.
4. **INSTALL-PATH (Group C):** `shamt-core/import-shamt.sh` → `.shamt-core/import-shamt.sh`; child-context `shamt-core/scripts/regenerate-framework.sh` → `.shamt-core/scripts/regenerate-framework.sh`.

## Architect rulings on Phase-3 classification (binding for the executor)

These resolve the ambiguous / dual-context occurrences. Each phase file's steps already encode them; collected here as the authoritative reference and for the Phase-6 gate allow-list.

- **`audit-framework` regen-script paths stay master-canonical.** `audit-framework` is in proposal Groups D (config), E (docs), and F3 (the `proposals/_template.md` D5-list entry) — but **not** Group C. Its `shamt-core/scripts/regenerate-framework.sh` invocations (`audit-framework.md:34`, `:54`; `skills/audit-framework/SKILL.md:38`) audit the framework repo itself and are left at `shamt-core/`. (This is a deliberate scope decision inherited from the proposal's group membership; if it later proves wrong for child-side audits, that is a follow-up proposal, not Phase-3 scope creep.)
- **`validate-artifact` docs repointed, proposals examples left.** `validate-artifact.md:61/67/120/133` (the `ARCHITECTURE.md` / `CODING_STANDARDS.md` governing-reference reads) **are** repointed — proposal Group E1 explicitly enumerates these lines. `validate-artifact.md:28` and `:47` (`proposals/<slug>.md` as an *example* artifact path) are **left bare**: this command's dominant runtime home is the master-side framework-update flow where proposals live at `proposals/`, and the line-47 path-selection logic ("not story-scoped") is prefix-agnostic. Both go on the gate allow-list.
- **`submit-proposal` master-side targets left.** `proposals/incoming/{project}-{slug}.md` (the path on master where a submission lands) and the `proposals/incoming/` detection heuristic are master-canonical throughout `submit-proposal.md` and `skills/submit-proposal/SKILL.md`. Allow-listed.
- **`plan-executor.md` proposals refs left.** Its `proposals/{slug}_PLAN.md` / `proposals/{slug}.md` references describe the master-side framework-update implement role; not in Group F. Allow-listed.
- **Self-host detection rules left.** The `{target}/shamt-core/` keys in `regen-framework.md:29` and `audit-framework.md:101` must stay `shamt-core/` (no dot) so a child install — which has `.shamt-core/` — correctly fails the self-host test. Allow-listed.
- **Headings naming the file are repointed.** `start-epic.md:99` and `start-feature.md:124` (`### Step 5 — Consult \`ARCHITECTURE.md\` (advisory)`) are repointed — they name the consulted file, so they are Group-E references, not bare section labels. (Verification per phase checks no inbound `#consult-architecturemd` anchor link exists.)
- **Project-doc templates repointed.** `architecture.template.md` and `coding_standards.template.md` are in Group E4; their `/validate-artifact` instructions and footer taglines render into the child's actual project docs at `.shamt-core/project-specific-files/`, so they are repointed (not self-referential no-ops).

## Verification (post-execution — run after all five phases)

These are the proposal's Risk-section gate greps (run from the repo root; they intentionally exclude `.claude/` generated copies, `shamt-config.example.json`, and the allow-listed master-canonical occurrences above):

```bash
# Gate D — no child-side bare shamt-config.json remains in swept canonical surfaces.
grep -rnE '(^|[^./a-z-])shamt-config\.json' host/templates templates reference CHEATSHEET.md \
  | grep -v '\.shamt-core/shamt-config' | grep -v 'shamt-config\.example'
# Expect: empty. (CLAUDE.md master-dev primer + the two .sh scripts are reviewed by-hand in Phases 1–2;
#  statusline.sh line 43 comment + 52/53 reads must all read .shamt-core/shamt-config.json.)

# Gate E — no child-side bare ARCHITECTURE.md / CODING_STANDARDS.md remains.
grep -rnE '(^|[^./a-z-])ARCHITECTURE\.md|(^|[^./a-z-])CODING_STANDARDS\.md' host/templates templates reference CHEATSHEET.md \
  | grep -v '\.shamt-core/project-specific-files'
# Expect: ONLY the `**Architecture impact:**` section-label lines (never the file) and init-shamt.sh-adjacent
#  template self-text already repointed. Any other hit is a miss.

# Gate F — no child-side bare proposals/ remains in the repointed flows.
grep -rnE '(^|[^./a-z-])proposals/' host/templates/claude/commands/{propose-update,submit-proposal,import-shamt,resolve-feedback}.md \
  host/templates/claude/skills/{propose-update,submit-proposal,import-shamt,resolve-feedback}/SKILL.md \
  | grep -v '\.shamt-core/proposals' | grep -v 'proposals/incoming' | grep -v 'proposals/archive'
# Expect: empty. (incoming/ + archive/ on master are allow-listed; the four master-side flow files
#  — triage-proposals, archive-proposal, implement-update, plan-update-implementation — are NOT swept.)

# Gate C — no child-side bare install-path remains.
grep -rnE 'shamt-core/import-shamt\.sh|shamt-core/scripts/regenerate' host/templates \
  | grep -v '\.shamt-core/' | grep -v 'Regenerate from shamt-core' | grep -v '{target}/shamt-core' \
  | grep -v 'commands/audit-framework' | grep -v 'skills/audit-framework'
# Expect: empty. (audit-framework regen paths + self-host {target}/ rule are allow-listed.)

# Gate — no edits leaked into generated .claude/.
git status --porcelain .claude/
# Expect: empty.

# Gate — generated-file footer count unchanged (no new managed files leaked into canonical host tree).
grep -rl 'Managed by Shamt' host/templates/claude/ | wc -l
# Expect: unchanged from pre-change count.
```

- [ ] Every row in the proposal's Proposed Changes table (Groups A–G) has corresponding steps across the five phase files (see the per-phase cross-check tables).
- [ ] `init-shamt.sh` self-host run still writes root `shamt-config.json`, seeds no `.shamt-core/project-specific-files/`, and the "already installed" precheck fires on a self-host re-run (Phase 1 manual test).
- [ ] A clean non-self-host `init-shamt.sh` run produces `<child>/.shamt-core/{CHEATSHEET.md,shamt-config.json,proposals/,project-specific-files/{ARCHITECTURE,CODING_STANDARDS}.md,<framework tree>}` and a root holding only `CLAUDE.md` + `.claude/`.
- [ ] Mermaid / relative-link targets in edited files still resolve.

## Notes

- **Fresh-agent runnable.** The proposal (footered) and all canonical files cited live on disk. Each phase file is self-contained.
- **Plan-executor reuse.** Phases 3–5 are pure sweeps the cheap-tier `plan-executor` runs mechanically. Phases 1–2 carry the design judgment (gated relocations, precheck reorder, completion-prompt heredoc, layout-diagram rewrite) — the locate/replace blocks there are exact, but flag back to the architect on any ambiguity rather than improvising.
- **Review Prevention Gate Mapping** and **CODING_STANDARDS Compliance** sections are omitted (N/A at the framework altitude per `/plan-update-implementation` Step 2; `plan-executor` treats both as N/A).
- **Clean break (Q3).** No migration logic is added to `import-shamt.sh`; already-installed children keep their old `shamt-core/` layout in place. The one-time manual migration note is added to `CHANGES.md` at archive time (`/archive-proposal`), not by this plan.
