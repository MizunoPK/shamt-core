---
description: Phase 1 of the PO flow — resolve a slug, fetch the tracker payload (or fall through to freeform), and produce an epic.md ready for /validate-artifact
---

# /p1-start-epic

**Purpose:** Run Phase 1 of the PO flow at the **Epic** altitude. Resolve a slug, fetch the work-item payload from the active tracker profile when the profile declares Epic support (or fall through to freeform capture), drive an open-questions iterative dialog over `Goal`, `Success Criteria`, and `Scope / Non-Scope`, and produce `epics/{slug}-{brief}/epic.md`.

**Recommended model:** Reasoning (Opus). Epic drafting is a design / multi-dimensional scoping task — defining the outcome, the success criteria, and the in/out scope warrants the deeper reasoning tier. See [`reference/model_selection.md`](../../../../reference/model_selection.md).

---

## Usage

```
/p1-start-epic {slug} [--tracker={ado|github|local}]
```

## Arguments

- `{slug}` (required) — epic slug. Globally unique across `epics/` (flat layout). Form depends on the active tracker profile:
  - **ado** — leading-numeric (`8421-billing-revamp`) so the slug can resolve to an Epic work-item ID.
  - **github / local / none** — any descriptive kebab-case slug; resolved by folder glob.
- `--tracker={ado|github|local}` (optional) — one-off override of the project's default `work_item_tracker` for this invocation only. Same semantics as `/e1-start-story`'s override. Legal values: any profile file in [`reference/trackers/`](../../../../reference/trackers/). The default comes from `.shamt-core/shamt-config.json`. Per [`reference/trackers/_contract.md`](../../../../reference/trackers/_contract.md).

## Prerequisites

- `.shamt-core/shamt-config.json` must exist at the project root. If not, halt and direct the user to `init-shamt`.
- If `--tracker=` is passed, the named profile must exist at `reference/trackers/{name}.md`. If not, halt and list the available profiles.

## Step-by-step

### Step 1 — Read configuration

1. Read `.shamt-core/shamt-config.json` from the project root. Extract `work_item_tracker` (one of `ado`, `github`, `local`, `none`).
2. If the user passed `--tracker={name}`, override the value for this invocation.
3. Read the corresponding profile at `reference/trackers/{name}.md` (skip when the resolved value is `none` — see Step 4 fallthrough).

### Step 2 — Resolve the slug to an epic folder

Apply the global slug-resolution rule from [`SHAMT_RULES.template.md`](../../../../templates/SHAMT_RULES.template.md) (Principle 1):

1. Try `epics/{slug}/epic.md` (exact match).
2. If not found, glob `epics/{slug}-*/epic.md`.
3. **Multiple matches** → halt and ask the user which folder to use.
4. **One match** → that folder is the epic folder. If `epic.md` is already populated and non-empty, treat this as a re-entry and confirm with the user how to proceed. **Available options depend on the active tracker mode** (resolved in Step 1):
   - **Fetching profiles (`ado` / `github` / any future fetching profile):** offer all four — **refetch**, **overwrite**, **extend**, **exit**.
   - **`local`:** the file is the source of truth and there is nothing to fetch from. Offer **overwrite**, **extend**, **exit**. (Refetch is functionally the same as exit on `local` — the file is unchanged unless edited externally — so it is not surfaced as a distinct option.)
   - **`none`:** no tracker fetch path. Offer **overwrite**, **extend**, **exit**. (Refetch is meaningless without a tracker.)

   Footer handling per branch:
   - **Refetch** (fetching profiles only) — re-run the tracker fetch (Step 4) and re-author the artifact from scratch. The file is rewritten wholesale; any prior `Validated …` footer is discarded along with the prior content. `/validate-artifact` must re-run before the next phase.
   - **Overwrite** — start the freeform open-questions dialog (Step 6) from a fresh template. Same wholesale rewrite; prior footer discarded.
   - **Extend** — preserve existing content and add to it (e.g., new Open Questions, expanded Scope). **If a prior `Validated …` footer is present, strip it before continuing** — extension changes the artifact and invalidates the prior pass; `/validate-artifact` must re-run before the next phase.
   - **Exit** — leave the file untouched and return. No footer change.
5. **Zero matches** → continue to Step 3 (new epic).

### Step 3 — Derive the brief description and propose the folder name

When the slug does not yet resolve to a folder:

1. Ask the user for a 2–4-word **brief description** of the epic, or derive it from the tracker payload's title once fetched (re-propose after Step 4).
2. Propose `epics/{slug}-{brief-description-kebab}/` and ask the user to confirm before creating the directory. Lowercase, hyphen-separated.
3. On confirmation, create the folder.

### Step 4 — Fetch (or fall through to freeform)

Branch on the resolved tracker value:

- **`none`** — no tracker fetch path. Skip to freeform capture (sub-step C).
- **`local`** — `epic.md` must already exist under the resolved folder (per [`reference/trackers/local.md`](../../../../reference/trackers/local.md)). If it does, proceed to Step 5 (architecture consult); if not, halt and direct the user to create it manually from [`templates/epic.template.md`](../../../../templates/epic.template.md) or run upstream PO-flow tooling.
- **`ado` / `github` (or any future fetching profile)** — proceed to sub-step A.

#### A. Slug-to-ID parse

Apply the profile's `## Slug resolution` rule. If the slug does not parse to a tracker ID (e.g., no leading numeric segment on ADO, or the slug is descriptive-only on a profile that requires IDs), surface a one-line notice — `slug {slug} does not match {profile}'s ID form — proceeding freeform` — and skip to sub-step C.

#### B. Profile-driven fetch

1. Check `## Supported work-item types` in the active profile. `/p1-start-epic` requires **Epic** (or `Any`). If the profile does not declare `Epic` support, surface the **freeform-fallback notice** — instantiate the contract template from [`reference/trackers/_contract.md`](../../../../reference/trackers/_contract.md) freeform-fallback rule (`tracker profile <name> has no <Type> work-item type — proceeding freeform`) with `<Type>` = `Epic` and `<name>` = the active profile's filename stem, yielding: `tracker profile {name} has no Epic work-item type — proceeding freeform`. Skip to sub-step C. Same instantiation pattern as `/e1-start-story` (which substitutes `<Type>` = `Story`); see the parallel check in [`commands/e1-start-story.md`](e1-start-story.md) under `### Step 4 — Fetch (or fall through to freeform)` → `#### B. Profile-driven fetch` (numbered item 1).
   - GitHub currently has **no** native Epic type — `/p1-start-epic` against the GitHub profile always falls through here.
   - ADO supports Epic natively (`System.WorkItemType = "Epic"`) — fetch proceeds.
2. Run the profile's `## Primary fetch` command, substituting `{id}` from sub-step A.
3. **Do not write `raw/issue.json`.** Epic folders contain **only** `epic.md` — no `raw/` subfolder, no `feedback/`. Hold the payload in memory while populating the artifact; the fetched JSON is not persisted to disk.
4. Apply the profile's `## Field mapping` to populate the corresponding sections of [`templates/epic.template.md`](../../../../templates/epic.template.md):
   - **Title / Type / State / Assignee / Project / Iteration/Milestone** → used to seed the H1 line and to inform the agent (not their own section in `epic.template.md`; record them in the **All Remaining Fields** appendix described in sub-step (5)).
   - **Description** → narrative input for the `Goal` section; the agent rewrites it as "what this epic exists to accomplish" rather than verbatim paste.
   - **Acceptance Criteria** → seed for `Success Criteria` bullets.
   - Apply the markdown normalization rules from [`templates/ticket.ado.template.md`](../../../../templates/ticket.ado.template.md) / [`templates/ticket.github.template.md`](../../../../templates/ticket.github.template.md) (entity decoding, attribute stripping, U+FFFD preservation, long-field rendering).
5. **All Remaining Fields appendix.** Any non-empty payload fields the agent wants to preserve for fidelity (custom fields, long design notes, attachment URLs, etc.) go into a final `## All Remaining Fields` subsection appended **immediately above the validation footer slot** (i.e., below `Sequencing & Parallelization`). Same pattern the story ticket templates use for long custom fields — no `raw/` subfolder. Omit the subsection entirely when there is nothing worth preserving.
6. Detect `## Auth failure modes` patterns. If the primary fetch fails on auth, surface the profile's fallback notice and skip to sub-step C (freeform).

#### C. Freeform capture

When the fetch path is skipped (or fell through), capture the epic manually. Write to `epics/{slug}-{brief}/epic.md` (the folder created in Step 3) from [`templates/epic.template.md`](../../../../templates/epic.template.md). The `## All Remaining Fields` appendix described in sub-step B.5 is **omitted in freeform mode** — there is no fetched payload to preserve.

The freeform path is **not** field-by-field paste; it is the open-questions iterative dialog (Step 6) drafting `Goal`, `Success Criteria`, and `Scope / Non-Scope` from scratch.

### Step 5 — Consult `.shamt-core/project-specific-files/ARCHITECTURE.md` (advisory)

Thread architecture / coding-standards consultation at the PO altitude as follows:

1. Read `.shamt-core/project-specific-files/ARCHITECTURE.md` (project root) while drafting. **If the file does not exist**, note its absence in chat (a single line: `.shamt-core/project-specific-files/ARCHITECTURE.md not found — proceeding without architecture consult; bootstrap via init-shamt is the canonical fix per §1.12.`) and continue. Do **not** halt — `.shamt-core/project-specific-files/ARCHITECTURE.md` is governing when present (per the SHAMT_RULES Standards check invariant) but the epic-altitude consult is advisory; missing the file degrades the consult, not the command. Per the SHAMT_RULES Global Story Invariants "Standards check" rule.
2. If the epic implies architectural change — a new service, a new boundary, a new data store, a new external integration, an auth/tenant boundary shift, etc. — flag it **inline** in `Scope / Non-Scope` as a single line at the top of that section: `**Architecture impact:** {one-line description of the architectural change implied}`. Omit the flag entirely when no architectural change is implied (or when `.shamt-core/project-specific-files/ARCHITECTURE.md` is absent and the impact cannot be assessed against a baseline — note the same in chat).
3. **Do not consult `.shamt-core/project-specific-files/CODING_STANDARDS.md`** — coding style is irrelevant at the epic altitude. The story-altitude Phase 2 / Phase 6 / Phase 7 cycle handles coding-standards alignment for any code changes the epic eventually produces.

### Step 6 — Open-questions iterative dialog

Apply [`SHAMT_RULES.template.md`](../../../../templates/SHAMT_RULES.template.md) Principle 2:

1. Maintain the `## Open Questions` section as you draft. Add a checkbox-prefixed entry the moment a question surfaces.
2. Surface each question to the user **one at a time** via `AskUserQuestion` (or equivalent). Never bulk-bomb.
3. Update the epic with each answer **before** moving to the next question. The artifact is not "drafted" while `## Open Questions` is non-empty.
4. Never proceed on a silent assumption. If an answer changes `Goal`, edit it. If it changes `Success Criteria`, edit them. If it changes `Scope / Non-Scope`, edit it (including the `**Architecture impact:** …` flag).
5. **Do not populate `Target Features` or `Sequencing & Parallelization`** in this command. Those sections are owned by `/p2-decompose-epic`; leave them present-but-empty per the template.

### Step 7 — Detect slug collisions

After writing the folder and epic:

1. Glob `epics/{slug}-*/` (and the exact `epics/{slug}/`) and confirm only one folder exists for this slug.
2. If multiple folders exist (typically because a different brief was used previously), halt and ask the user to either reuse the existing folder or rename one.

### Step 8 — Exit gate

Verify before exiting:

- [ ] `epics/{slug}-{brief}/epic.md` exists and is non-empty.
- [ ] `## Open Questions` is empty (every question resolved, with answers folded into the artifact).
- [ ] `Goal`, `Success Criteria`, and `Scope / Non-Scope` are drafted.
- [ ] `Target Features` and `Sequencing & Parallelization` are **left empty** (owned by `/p2-decompose-epic`).
- [ ] No `Validated …` footer present yet — `/validate-artifact` appends it.
- [ ] User has confirmed the slug + content.

If any item fails, return to the relevant step.

### Step 9 — Suggest the next command

Surface — but do **not** auto-invoke — the next command:

```
/clear
/validate-artifact epics/{slug}-{brief}/epic.md
```

After validation appends the footer, `/p2-decompose-epic {slug}` can run. This command stays independently runnable by a fresh agent off on-disk state per Principle 1 — chaining validation here would couple the two phases.

## Tracker integration

`/p1-start-epic` mirrors `/e1-start-story`'s tracker plumbing at the Epic altitude. The active profile's `## Supported work-item types` section is authoritative — if it does not declare **Epic**, this command **falls through to freeform mode** with a one-line notice (the contract template instantiated at this altitude: `tracker profile {name} has no Epic work-item type — proceeding freeform`) and continues per Step 4 sub-step C. Per the freeform-fallback rule in [`reference/trackers/_contract.md`](../../../../reference/trackers/_contract.md) (which defines the template generically as `tracker profile <name> has no <Type> work-item type — proceeding freeform`, instantiated here with `<Type>` = `Epic`). Do **not** silently fail; do **not** halt.

When the fetch succeeds, raw payload data is preserved inline in `epic.md`'s **All Remaining Fields** appendix (Step 4 sub-step B.5) — there is no `raw/` subfolder at the epic altitude.

## Exit criteria

- `epics/{slug}-{brief}/epic.md` exists, is non-empty, and has `Goal`, `Success Criteria`, `Scope / Non-Scope` drafted.
- `Target Features` and `Sequencing & Parallelization` remain empty (decomposition output).
- `## Open Questions` is empty.
- No validation footer yet — `/validate-artifact` adds it.
- The user has confirmed slug + content; the next command has been suggested in chat.

## Notes

- **Fresh-agent runnable.** Every input lives on disk (`.shamt-core/shamt-config.json`, the tracker profile, `.shamt-core/project-specific-files/ARCHITECTURE.md`, the prior draft when re-entering). No conversation history required.
- **Epic-level validation is `/validate-artifact`.** Epics have no review phase — Pattern 1 validation only. The decomposition exit gate run inside `/p2-decompose-epic` is a stub-batch check on that command's output and is **distinct from `/validate-artifact`**; do not conflate.
- **No `Target Features` work here.** This command writes the epic with the decomposition sections empty; `/p2-decompose-epic` fills them. Two reasons: keeps single-session sizing tight (Principle 1 — single-session sizing constraint), and keeps deep dialog at the right altitude per §2.1 stub-list-then-drill-in.
- **No `.shamt-core/project-specific-files/CODING_STANDARDS.md` consult.** Coding style is irrelevant at the epic altitude per §1.12 PO-threading row. The story-level Phase 2 / 6 / 7 cycle handles coding-standards alignment for the eventual code work.
- The `--tracker=` flag is **one-off**, not persisted. The project default in `.shamt-core/shamt-config.json` is unchanged.
- The freeform-fallback rule means future tracker profiles that don't declare `Epic` natively still work — `/p1-start-epic` degrades gracefully with a one-line notice and continues into the open-questions dialog.

<!-- Managed by Shamt — do not edit. Regenerate from shamt-core/host/templates/claude/commands/p1-start-epic.md. -->

