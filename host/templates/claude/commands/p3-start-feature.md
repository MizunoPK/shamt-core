---
description: Phase 3 of the PO flow — flesh out a feature (stub from /p2-decompose-epic, standalone, or tracker-seeded) into a feature.md ready for /validate-artifact
---

# /p3-start-feature

**Purpose:** Run Phase 3 of the PO flow at the **Feature** altitude. Resolve a slug, branch on three input modes (flesh out an existing stub written by `/p2-decompose-epic`, create a standalone feature from scratch, or seed from a tracker work-item payload), drive an open-questions iterative dialog over `Goal`, `Success Criteria`, and `Scope / Non-Scope`, and produce the feature under its parent epic — `epics/{parent-epic-folder}/features/{ID}-{slug}-{brief}/feature.md` (the parent epic is the stub's epic, or the Tech Stories epic for standalone work). Leaves `Target Stories` and `Sequencing & Parallelization` empty — `/p4-decompose-feature` fills them later.

**Recommended model:** Reasoning (Opus). Feature drafting is a design / multi-dimensional scoping task — same justification as `/p1-start-epic`. See [`reference/model_selection.md`](../../../../reference/model_selection.md).

---

## Usage

```
/p3-start-feature {slug} [--tracker={ado|github|local}]
```

## Arguments

- `{slug}` (required) — feature slug. **Globally unique across the tree** (see §PO-tree resolution). Form depends on the active tracker profile:
  - **ado** — leading-numeric (`5102-payments-rewrite`) so the slug can resolve to a Feature work-item ID.
  - **github / local / none** — any descriptive kebab-case slug; resolved by folder glob.
- `--tracker={ado|github|local}` (optional) — one-off override of the project's default `work_item_tracker` for this invocation only. Same semantics as `/e1-start-story` and `/p1-start-epic`. Legal values: any profile file in [`reference/trackers/`](../../../../reference/trackers/). The default comes from `.shamt-core/shamt-config.json`. Per [`reference/trackers/_contract.md`](../../../../reference/trackers/_contract.md).
  - **Note:** the override only changes behavior in **Mode C** (where a tracker fetch actually happens). In **Mode A** (fleshing an existing stub) and **Mode B** (standalone from scratch), no fetch occurs and `--tracker=` is a no-op. Surface a one-line notice (`--tracker={name} is a no-op in Mode {A|B} — no tracker fetch occurs`) if the flag is passed in those modes so the user is not surprised.

## Prerequisites

- `.shamt-core/shamt-config.json` must exist at the project root. If not, halt and direct the user to `init-shamt`.
- If `--tracker=` is passed, the named profile must exist at `reference/trackers/{name}.md`. If not, halt and list the available profiles.

## Step-by-step

### Step 1 — Read configuration

1. Read `.shamt-core/shamt-config.json` from the project root. Extract `work_item_tracker` (one of `ado`, `github`, `local`, `none`).
2. If the user passed `--tracker={name}`, override the value for this invocation.
3. Read the corresponding profile at `reference/trackers/{name}.md` (skip when the resolved value is `none` — see Step 4 fallthrough).

### Step 2 — Resolve the slug to a feature folder

Apply the global slug-resolution rule from [`SHAMT_RULES.template.md`](../../../../templates/SHAMT_RULES.template.md) (Principle 1) — resolve per `templates/SHAMT_RULES.template.md` §PO-tree resolution:

1. Glob the nested feature path: `epics/*/features/{ID}-*/feature.md` (for a ticket ID) or, for a slug, **both** `epics/*/features/{slug}-*/feature.md` and `epics/*/features/*-{slug}-*/feature.md` (tree-wide feature glob). Also check the legacy-flat fallback: `features/{ID}-*/feature.md`, `features/{slug}-*/feature.md`, or `features/*-{slug}-*/feature.md` (for backwards compatibility with flat-layout features).
2. If any match is found, verify it is the only one; if multiple matches exist for the same slug, halt and ask the user which folder to use.
3. **Multiple matches** → halt and ask the user which folder to use.
4. **One match** → that folder is the feature folder. **Detect Mode A vs. re-entry** by inspecting `feature.md`:
   - If `feature.md` has its **decomposition-authored fields** filled — `**Ticket ID:** T{N}` + `## Goal`, plus (on a richer-cataloging stub) `## Scope / Non-Scope` + `## Decomposition Context` — but the **depth sections `## Success Criteria` and `## Open Questions` are still empty** (per the `/p2-decompose-epic` Step 8 contract), this is a **stub** — proceed to **Mode A** under Step 4. (The parent epic is the folder path.)
   - If `feature.md` has its **depth sections drafted** (`## Success Criteria` / `## Open Questions` populated — a prior `/p3-start-feature` deep-dive ran), this is a **re-entry**. Confirm with the user how to proceed. **Available options depend on whether the active tracker actually has a Feature fetch path** (resolved in Step 1 plus the profile's `## Supported work-item types`):
     - **Fetching profile that declares Feature support** (e.g., `ado`): offer all four — **refetch**, **overwrite**, **extend**, **exit**.
     - **Fetching profile that does *not* declare Feature support** (e.g., `github`): same options as `local` / `none` — **overwrite**, **extend**, **exit**. Refetch is suppressed because the profile would just fall through to freeform anyway (per the freeform-fallback rule), making the offered branch pointless.
     - **`local`:** the file is the source of truth. Offer **overwrite**, **extend**, **exit**.
     - **`none`:** no tracker fetch path. Offer **overwrite**, **extend**, **exit**.

     Footer handling per branch (same rules as `/p1-start-epic`):
     - **Refetch** (offered only when the active profile declares Feature support) — re-run the tracker fetch (Step 4 Mode C) and re-author the artifact from scratch. The file is rewritten wholesale; any prior `Validated …` footer is discarded along with the prior content. `/validate-artifact` must re-run. **Note:** if the existing artifact was originally drafted via Mode A (stub-fleshing) or Mode B (standalone), Refetch will replace that hand-authored content with tracker-seeded content — surface a one-line warning (`current artifact was not tracker-seeded — Refetch will replace hand-authored content with tracker payload`) before proceeding so the user can opt for Extend instead.
     - **Overwrite** — start the freeform open-questions dialog (Step 6) from a fresh template. Same wholesale rewrite; prior footer discarded.
     - **Extend** — preserve existing content and add to it. **If a prior `Validated …` footer is present, strip it before continuing** — extension changes the artifact and invalidates the prior pass; `/validate-artifact` must re-run.
     - **Exit** — leave the file untouched and return. No footer change.

     **Preserve the `**Ticket ID:**` header verbatim on re-entry.** The `**Ticket ID:** …` line is never rewritten by `/p3-start-feature` regardless of the chosen branch — it is decomposition-owned per the decomposition step. Only the body sections are touched. (Parentage is the folder path.)
5. **Zero matches** → continue to Step 3 (Mode B or Mode C, decided in Step 4).

### Step 3 — Derive the brief description and propose the folder name

Applies only when the slug does not yet resolve to a folder (i.e., Mode A is ruled out and we are heading into Mode B or Mode C):

1. Ask the user for a 2–4-word **brief description** of the feature, or derive it from the tracker payload's title once fetched (re-propose after Step 4 Mode C).
2. **For a new (non-stub) feature, allocate a ticket ID** `T{N}` (= `max` of the `^T([0-9]+)-` prefixes across `epics/`, `features/`, `stories/`, + 1 — per **# Ticket IDs**) and propose `features/{ID}-{slug}-{brief-description-kebab}/`, populating the `**Ticket ID:** T{N}` header. **Mode A (stub):** the folder + its ID already exist — reuse them, do **not** allocate or re-propose. Ask the user to confirm before creating directories. Lowercase, hyphen-separated.
3. On confirmation, create the folder.

### Step 4 — Branch on input mode

The command supports three input modes. **Mode disambiguation order:**

1. **Mode A — flesh out an existing stub** if Step 2 resolved to a folder whose `feature.md` matches the stub shape (decomposition-authored fields filled — Goal one-liner, plus `## Scope / Non-Scope` + `## Decomposition Context` on a richer-cataloging stub — but the depth sections `## Success Criteria` / `## Open Questions` still empty; parentage is the folder path).
2. **Mode C — tracker-seeded** if Mode A did not apply AND the active tracker profile declares Feature work-item type support AND the slug parses to a tracker ID per the profile's `## Slug resolution` rule.
3. **Mode B — standalone from scratch** otherwise.

#### Mode A — flesh out an existing stub (the common case after `/p2-decompose-epic`)

The folder exists; `feature.md` already carries a populated `## Goal` from `/p2-decompose-epic` Step 8 — and, for a stub created under richer-cataloging decomposition, a populated `## Scope / Non-Scope` boundary and a `## Decomposition Context` section. (The parent epic is the folder path.)

1. **Preserve the `## Goal` verbatim.** Do not rewrite it.
2. **Consume the stub's `## Decomposition Context` as a research seed when present** — a stub created before #12 (or via a path that didn't catalog it) lacks the section, so fall back to the existing `## Goal` alone (and `## Scope / Non-Scope` if it was already populated), with no failure. Then proceed to Step 5 (architecture consult) and Step 6 (open-questions dialog) to populate `Success Criteria` + `Open Questions` and the `## Scope / Non-Scope` boundary — **deepening** it when decomposition pre-populated it (a richer-cataloging stub), or **populating it from scratch** when it is empty (an older stub). The existing `/validate-artifact` handoff at the end of the command is unchanged; validation is not folded in here.
3. Leave `Target Stories` and `Sequencing & Parallelization` empty — those are `/p4-decompose-feature`'s output.
4. **No `## All Remaining Fields` appendix** — there was no tracker fetch in this mode.

#### Mode B — create a standalone feature from scratch

The folder did not exist before Step 3. There is no explicit parent epic input from the user.

1. Write `epics/{parent-epic-folder}/features/{ID}-{slug}-{brief}/feature.md` from [`templates/feature.template.md`](../../../../templates/feature.template.md). After writing feature.md, write its path to `shamt-state/active-feature` (and `shamt-state/active-epic` for its parent epic when nested).
2. **Mode B has no top-level home** — a standalone feature is created under the standing Tech Stories epic (`epics/{parent-epic-folder}/features/{ID}-{slug}-{brief}/feature.md` (here `{parent-epic-folder}` = the Tech Stories epic), per #15). There is no blank-parent / top-level feature. (If #15 has not landed alongside, the executor halts per the index's sequencing precondition.)
3. Proceed to Step 5 (architecture consult), then Step 6 (open-questions dialog) to populate `Goal`, `Success Criteria`, and `Scope / Non-Scope` from scratch.
4. Leave `Target Stories` and `Sequencing & Parallelization` empty.
5. **No `## All Remaining Fields` appendix** — there was no tracker fetch in this mode.

#### Mode C — tracker-seeded

The slug parses to a tracker work-item ID and the active profile declares Feature support.

##### C.1 — Slug-to-ID parse

Apply the profile's `## Slug resolution` rule. If the slug does not parse to a tracker ID (e.g., no leading numeric segment on ADO, or the slug is descriptive-only on a profile that requires IDs), surface a one-line notice — `slug {slug} does not match {profile}'s ID form — proceeding freeform` — and **fall through to Mode B** (Step 4 Mode B sub-step 1).

##### C.2 — Profile-driven fetch

1. Check `## Supported work-item types` in the active profile. `/p3-start-feature` requires **Feature** (or `Any`). If the profile does not declare `Feature` support, surface the **freeform-fallback notice** — instantiate the contract template from [`reference/trackers/_contract.md`](../../../../reference/trackers/_contract.md) freeform-fallback rule (`tracker profile <name> has no <Type> work-item type — proceeding freeform`) with `<Type>` = `Feature` and `<name>` = the active profile's filename stem, yielding: `tracker profile {name} has no Feature work-item type — proceeding freeform`. **Fall through:** if Step 2 resolved to a stub, fall through to **Mode A**; otherwise fall through to **Mode B**.
   - GitHub currently has **no** Feature type — `/p3-start-feature` against the GitHub profile always falls through here.
   - ADO supports Feature natively (`System.WorkItemType = "Feature"`) — fetch proceeds.
2. Run the profile's `## Primary fetch` command, substituting `{id}` from sub-step C.1.
3. **Do not write `raw/issue.json`.** Feature folders contain **only** `feature.md` — no `raw/` subfolder, no `feedback/`. Hold the payload in memory while populating the artifact; the fetched JSON is not persisted to disk. **Same rule as `/p1-start-epic`** — distinct from stories, which *do* have `raw/`.
4. Apply the profile's `## Field mapping` to populate the corresponding sections of [`templates/feature.template.md`](../../../../templates/feature.template.md):
   - **Title / Type / State / Assignee / Project / Iteration/Milestone** → used to seed the H1 line and to inform the agent (not their own section in `feature.template.md`; record them in the **All Remaining Fields** appendix described in sub-step C.5).
   - **Description** → narrative input for the `Goal` section; the agent rewrites it as "what this feature exists to accomplish" rather than verbatim paste.
   - **Acceptance Criteria** → seed for `Success Criteria` bullets.
   - **Parent work-item link** (when the profile surfaces a parent Epic relation) → the parent work-item link determines the feature's nesting parent — create the feature under the matched local epic folder when the parent's slug resolves to one under `epics/`, else under the Tech Stories epic (#15). No back-ref header is written (parentage is the folder path, C3).
   - Apply the markdown normalization rules from [`templates/ticket.ado.template.md`](../../../../templates/ticket.ado.template.md) / [`templates/ticket.github.template.md`](../../../../templates/ticket.github.template.md) (entity decoding, attribute stripping, U+FFFD preservation, long-field rendering).
5. **All Remaining Fields appendix.** Any non-empty payload fields the agent wants to preserve for fidelity (custom fields, long design notes, attachment URLs, etc.) go into a final `## All Remaining Fields` subsection appended **immediately above the validation footer slot** (i.e., below `Sequencing & Parallelization`). Same pattern as `/p1-start-epic` — no `raw/` subfolder. Omit the subsection entirely when there is nothing worth preserving.
6. Detect `## Auth failure modes` patterns. If the primary fetch fails on auth, surface the profile's fallback notice and **fall through to Mode B** (or Mode A if Step 2 resolved to a stub).
7. After populating the seed content, write its path to `shamt-state/active-feature` (and `shamt-state/active-epic` for its parent epic when nested). Then proceed to Step 5 (architecture consult) and Step 6 (open-questions dialog) to fill any gaps the tracker payload does not cover.

### Step 5 — Consult `.shamt-core/project-specific-files/ARCHITECTURE.md` (advisory)

Thread architecture / coding-standards consultation at the PO altitude as follows:

1. Read `.shamt-core/project-specific-files/ARCHITECTURE.md` (project root) while drafting. **If the file does not exist**, note its absence in chat (a single line: `.shamt-core/project-specific-files/ARCHITECTURE.md not found — proceeding without architecture consult; bootstrap via init-shamt is the canonical fix.`) and continue. Do **not** halt — `.shamt-core/project-specific-files/ARCHITECTURE.md` is governing when present (per the SHAMT_RULES Standards check invariant) but the feature-altitude consult is advisory; missing the file degrades the consult, not the command. Per the SHAMT_RULES Global Story Invariants "Standards check" rule.
2. If the feature implies architectural change — a new service, a new boundary, a new data store, a new external integration, an auth/tenant boundary shift, etc. — flag it **inline** in `Scope / Non-Scope` as a single line at the top of that section: `**Architecture impact:** {one-line description of the architectural change implied}`. Omit the flag entirely when no architectural change is implied (or when `.shamt-core/project-specific-files/ARCHITECTURE.md` is absent and the impact cannot be assessed against a baseline — note the same in chat).
3. **Do not consult `.shamt-core/project-specific-files/CODING_STANDARDS.md`** — coding style is irrelevant at the feature altitude. The story-altitude Phase 2 / Phase 6 / Phase 7 cycle handles coding-standards alignment for any code changes the feature eventually produces. Same rule as `/p1-start-epic`.

### Step 6 — Open-questions iterative dialog

Apply [`SHAMT_RULES.template.md`](../../../../templates/SHAMT_RULES.template.md) Principle 2:

1. Maintain the `## Open Questions` section as you draft. Add a checkbox-prefixed entry the moment a question surfaces.
2. Surface each question to the user **one at a time** via `AskUserQuestion` (or equivalent). Never bulk-bomb.
3. Update the feature with each answer **before** moving to the next question. The artifact is not "drafted" while `## Open Questions` is non-empty.
4. Never proceed on a silent assumption. If an answer changes `Goal`, edit it (Mode B and Mode C only — Mode A's Goal is preserved per Step 4 Mode A sub-step 1). If it changes `Success Criteria`, edit them. If it changes `Scope / Non-Scope`, edit it (including the `**Architecture impact:** …` flag).
5. **Do not populate `Target Stories` or `Sequencing & Parallelization`** in this command. Those sections are owned by `/p4-decompose-feature`; leave them present-but-empty per the template.

### Step 7 — Detect slug collisions

After writing the folder and feature:

1. Glob `features/{ID}-*/` (for a ticket ID) or, for a slug, **both** `features/{slug}-*/` and `features/*-{slug}-*/` (and the exact `features/{slug}/`), and confirm only one folder exists for this feature.
2. If multiple folders exist (typically because a different brief was used previously), halt and ask the user to either reuse the existing folder or rename one. Feature slugs are **globally unique**.

### Step 8 — Exit gate

Verify before exiting:

- [ ] `epics/{parent-epic-folder}/features/{ID}-{slug}-{brief}/feature.md` exists and is non-empty (nested).
- [ ] `## Open Questions` is empty (every question resolved, with answers folded into the artifact).
- [ ] `Goal`, `Success Criteria`, and `Scope / Non-Scope` are drafted.
- [ ] `Target Stories` and `Sequencing & Parallelization` are **left empty** (owned by `/p4-decompose-feature`).
- [ ] **Mode A:** the original `## Goal` one-liner from the stub is preserved verbatim.
- [ ] **Mode B:** created under the Tech Stories epic (per #15).
- [ ] **Mode C:** `## All Remaining Fields` appendix is present iff the fetched payload had non-empty fields worth preserving.
- [ ] `shamt-state/active-feature` and `shamt-state/active-epic` pointers have been written.
- [ ] No `Validated …` footer present yet — `/validate-artifact` appends it.
- [ ] User has confirmed the slug + content.

If any item fails, return to the relevant step.

### Step 9 — Suggest the next command

Surface — but do **not** auto-invoke — the next command:

```
/clear
/validate-artifact epics/{parent-epic-folder}/features/{ID}-{slug}-{brief}/feature.md
```

After validation appends the footer, `/p4-decompose-feature {slug}` can run. This command stays independently runnable by a fresh agent off on-disk state per Principle 1 — chaining validation here would couple the two phases.

## Tracker integration

`/p3-start-feature` mirrors `/e1-start-story` and `/p1-start-epic`'s tracker plumbing at the Feature altitude. The active profile's `## Supported work-item types` section is authoritative — if it does not declare **Feature**, this command **falls through to freeform mode** with a one-line notice (the contract template instantiated at this altitude: `tracker profile {name} has no Feature work-item type — proceeding freeform`) and continues per Step 4 Mode A or Mode B (whichever applies given the filesystem state). Per the freeform-fallback rule in [`reference/trackers/_contract.md`](../../../../reference/trackers/_contract.md) (which defines the template generically as `tracker profile <name> has no <Type> work-item type — proceeding freeform`, instantiated here with `<Type>` = `Feature`). Do **not** silently fail; do **not** halt.

When the fetch succeeds, raw payload data is preserved inline in `feature.md`'s **All Remaining Fields** appendix (Step 4 Mode C, sub-step C.5) — there is no `raw/` subfolder at the feature altitude. Same pattern as `/p1-start-epic`.

## Exit criteria

- `features/{ID}-{slug}-{brief}/feature.md` exists, is non-empty, and has `Goal`, `Success Criteria`, `Scope / Non-Scope` drafted.
- `Target Stories` and `Sequencing & Parallelization` remain empty (decomposition output).
- `## Open Questions` is empty.
- Parentage is the folder path; nesting is determined by the input mode: stub's parent (Mode A), Tech Stories epic (Mode B), or tracker-matched epic or Tech Stories (Mode C).
- No validation footer yet — `/validate-artifact` adds it.
- The user has confirmed slug + content; the next command has been suggested in chat.

## Notes

- **Fresh-agent runnable.** Every input lives on disk (`.shamt-core/shamt-config.json`, the tracker profile, `.shamt-core/project-specific-files/ARCHITECTURE.md`, the existing stub or prior draft when re-entering). No conversation history required.
- **Feature-level validation is `/validate-artifact`.** Features have no review phase — Pattern 1 validation only. The decomposition exit gate run inside `/p4-decompose-feature` is a stub-batch check on that command's output and is **distinct from `/validate-artifact`**; do not conflate.
- **No `Target Stories` work here.** This command writes the feature with the decomposition sections empty; `/p4-decompose-feature` fills them. Two reasons: keeps single-session sizing tight (Principle 1 — single-session sizing constraint), and keeps deep dialog at the right altitude per the stub-list-then-drill-in decomposition.
- **No `.shamt-core/project-specific-files/CODING_STANDARDS.md` consult.** Coding style is irrelevant at the feature altitude. Same rule as `/p1-start-epic`.
- **`--tracker=` is one-off, not persisted.** The project default in `.shamt-core/shamt-config.json` is unchanged. The override only affects Mode C; in Mode A and Mode B it is a no-op (a notice is surfaced when the flag is supplied in those modes).
- **The freeform-fallback rule** means future tracker profiles that don't declare `Feature` natively still work — `/p3-start-feature` degrades gracefully with a one-line notice and continues into Mode A or Mode B based on the filesystem state.
- **Mode disambiguation is filesystem-first.** Mode A wins when the stub is present; Mode C wins next when the tracker profile and slug shape align; Mode B is the default fallback. No new flags are needed to pick a mode.

<!-- Managed by Shamt — do not edit. Regenerate from shamt-core/host/templates/claude/commands/p3-start-feature.md. -->
