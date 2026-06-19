---
description: Phase 1 (Intake) — resolve a slug, fetch the tracker payload (or fall through to freeform), and produce a validated ticket.md
---

# /e1-start-story

**Purpose:** Run Phase 1 of the Engineer flow — Intake. Resolve a slug, fetch the work-item payload from the active tracker profile (or fall through to freeform capture), and produce `stories/{ID}-{slug}-{brief}/ticket.md`.

**Recommended model:** Cheap (Haiku). Intake is mechanical: tracker fetch, file write, slug resolution, freeform capture via the open-questions iterative dialog. See [`reference/model_selection.md`](../../../../reference/model_selection.md).

---

## Usage

```
/e1-start-story {slug} [--tracker={ado|github|local}]
```

## Arguments

- `{id-or-slug}` (required) — when resolving an existing story, its ticket ID (`T{N}`) or slug; when creating a new freeform story, the slug. Form depends on the active tracker profile:
  - **ado / github** — leading-numeric (`1234-foo-bar`) or tracker-native cross-project form (`org/repo#42-foo-bar` for GitHub). See the active profile's `## Slug resolution` section.
  - **local / none** — any slug; resolved by folder glob.
- `--tracker={ado|github|local}` (optional) — one-off override of the project's default `work_item_tracker` for this invocation only. Legal values: any profile file in [`reference/trackers/`](../../../../reference/trackers/) (currently `ado`, `github`, `local`). The default comes from `.shamt-core/shamt-config.json`. Per [`reference/trackers/_contract.md`](../../../../reference/trackers/_contract.md).

## Prerequisites

- `.shamt-core/shamt-config.json` must exist at the project root. If not, halt and direct the user to `init-shamt`.
- If `--tracker=` is passed, the named profile must exist at `reference/trackers/{name}.md`. If not, halt and list the available profiles.

## Step-by-step

### Step 1 — Read configuration

1. Read `.shamt-core/shamt-config.json` from the project root. Extract `work_item_tracker` (one of `ado`, `github`, `local`, `none`).
2. If the user passed `--tracker={name}`, override the value for this invocation.
3. Read the corresponding profile at `reference/trackers/{name}.md` (skip when the resolved value is `none` — see Step 4 fallthrough).

### Step 2 — Resolve the slug to a story folder

Apply the global slug resolution rule from [`SHAMT_RULES.template.md`](../../../../templates/SHAMT_RULES.template.md) (Global Story Invariants):

1. Resolve the story folder per `templates/SHAMT_RULES.template.md` §PO-tree resolution (tree-wide glob + legacy-flat fallback): a ticket ID matches `…/stories/{ID}-*/`, a slug matches `…/stories/{slug}-*/` ∪ `…/stories/*-{slug}-*/` anywhere in the nested tree, with the legacy-flat `stories/{slug}-*/` as fallback. Exactly one match — halt on zero or multiple. `stories/{slug}/` below denotes that resolved folder.
3. **Multiple matches** → halt and ask the user which folder to use.
4. **One match** → that folder is the story folder. **Inspect `ticket.md` to detect the stub case:**
   - **Ready-ticket pickup (PO-flow handoff, validated).** If the resolved nested `ticket.md` carries a Pattern-1 `Validated …` footer, this is a `/ps2-validate`-validated planning ticket. Mark the invocation as **ready-ticket pickup**: do the tracker fetch/reconcile + confirm of Step 4, then **skip re-authoring intake** — proceed straight to the Intake gate (Step 6) without re-running the open-questions dialog (the ticket is already authored and validated). The scope one-liner and `## Decomposition Context` are preserved verbatim.
   - **Bare-stub merge (PO-flow handoff, unvalidated).** If the resolved nested `ticket.md` carries **no** `Validated …` footer, this is a bare stub written by `/pf3-decompose` (or `/ps0-draft`). Mark the invocation as **stub-aware**: the scope one-liner in the body is preserved verbatim throughout the rest of this command. The stub's `## Decomposition Context` (when present — pre-#12 / freeform stubs lack it) seeds the intake deepening as the research starting point; fall back to the scope one-liner alone when absent. Proceed to Step 4 (the rest of the Intake flow — tracker fetch when the active profile supports Story, else freeform open-questions dialog — merges its output into the existing template sections without rewriting the scope one-liner). The Engineer-flow Intake gate (Step 6) still applies. Stub-derived stories are individually testable per `/pf3-decompose`'s exit gate — no rubric re-check at Intake.
   - **Detection is flagless.** The three-way split keys solely on the resolved folder's nested parentage plus the presence/absence of the `Validated …` footer (stamped by `/ps2-validate`, the story-altitude validate stage): **no new command flag, no new template, no new status marker** — consistent with e1's existing flagless stub detection.
   - **Pre-existing freeform case.** A populated `ticket.md` resolving to a flat/non-nested folder is a pre-existing freeform story. Confirm with the user whether to refetch / overwrite, append, or exit, the same as before.
5. **Zero matches** → continue to Step 3 (new story).

### Step 3 — Derive the brief description and propose the folder name

When the slug does not yet resolve to a folder:

1. Ask the user for a 2–4-word **brief description** of the story (or derive it from the tracker payload's title once fetched — re-propose after Step 4).
2. For a new story with no PO-flow parent, **halt this intake and hand off** to /ps0-draft (#15) — it seeds the nested ticket stub under the standing Tech Stories epic's Bugs / Quick Wins feature and re-enters the Engineer flow stub-aware. **Do not fall through to the folder-create/confirm steps below** (the stub already exists at its nested path). A story that already resolves to a nested folder (PO-flow stub, or an existing folder) is handled by the stub-aware path; allocate a ticket ID `T{N}` only when creating a genuinely new tracker-backed story whose nested parent epic/feature already exists.
3. On confirmation, create the folder.

### Step 4 — Fetch (or fall through to freeform)

Branch on the resolved tracker value:

- **`none`** — no tracker fetch path. Skip to freeform capture (sub-step C).
- **`local`** — `ticket.md` must already exist under the resolved folder (per [`reference/trackers/local.md`](../../../../reference/trackers/local.md)). If it does, proceed to Step 6 (confirmation). If not, halt and direct the user to either create it manually from a ticket template ([`templates/ticket.ado.template.md`](../../../../templates/ticket.ado.template.md) or [`templates/ticket.github.template.md`](../../../../templates/ticket.github.template.md) — either works as a freeform skeleton) or run an upstream PO-flow command.
- **`ado` / `github` (or any future fetching profile)** — proceed to sub-step A.

#### A. Slug-to-ID parse

Apply the profile's `## Slug resolution` rule (per the profile file). If the slug does not parse to a tracker ID (e.g., no leading numeric segment), surface a one-line notice (`slug {slug} does not match {profile}'s ID form — proceeding freeform`) and skip to sub-step C (freeform).

#### B. Profile-driven fetch

1. Check `## Supported work-item types` in the active profile. `/e1-start-story` requires `Story` (or `Any`). If the profile does not declare `Story` support (and is not `Any`), surface the freeform-fallback notice (template: `tracker profile {name} has no Story work-item type — proceeding freeform`) and skip to sub-step C. Per [`reference/trackers/_contract.md`](../../../../reference/trackers/_contract.md) freeform-fallback rule.
2. Run the profile's `## Primary fetch` command, substituting `{id}` from sub-step A. Write the verbatim output to `stories/{ID}-{slug}-{brief}/raw/issue.json`.
3. Run each `## Auxiliary fetches` command, writing to its own `raw/<endpoint>.json` per the profile. A failed auxiliary fetch is **not** an abort — record the failure object (per the profile's template, e.g., `{"fetch_status": "failed", "error": "<msg>", ...}`) in the corresponding raw file and continue.
4. Detect `## Auth failure modes` patterns. If the primary fetch fails on auth, surface the profile's fallback notice and skip to sub-step C (freeform).
5. Apply the profile's `## Field mapping` to populate `stories/{ID}-{slug}-{brief}/ticket.md` from the appropriate per-provider template ([`templates/ticket.ado.template.md`](../../../../templates/ticket.ado.template.md) or [`templates/ticket.github.template.md`](../../../../templates/ticket.github.template.md)). Preserve markdown normalization rules called out in the template (entity decoding, fenced code blocks, attachment URLs, U+FFFD preservation, long custom-field rendering).

**Stub-aware merge (when Step 2 marked the invocation as stub-aware).** The existing ticket.md carries the scope one-liner from /pf3-decompose in the body intake area, and (on a richer-cataloging stub) a ## Decomposition Context breadth section. Parentage is the folder path — there are no back-ref headers. Merge tracker-fetched fields into the existing template sections **without** rewriting the scope one-liner or the `## Decomposition Context` section (all decomposition-owned):

- **Scope one-liner:** preserved verbatim in its body location.
- **`## Decomposition Context`:** preserved verbatim — decomposition-owned breadth; it *seeds* the deepening (Step 2) but is not rewritten. Absent on pre-#12 / freeform stubs.
- **Tracker-mapped fields** (Title / Type / State / Description / Acceptance Criteria / etc.) populate the corresponding template sections per the `## Field mapping` rule — same as the from-scratch path.
- **Raw payloads** still land in `stories/{ID}-{slug}-{brief}/raw/` as usual.

#### C. Freeform capture

When the fetch path is skipped (or fell through), capture the ticket manually. Write to `stories/{ID}-{slug}-{brief}/ticket.md` (the folder created in Step 3, or the existing stub folder when stub-aware):

1. Pick the freeform template — either [`templates/ticket.github.template.md`](../../../../templates/ticket.github.template.md) or [`templates/ticket.ado.template.md`](../../../../templates/ticket.ado.template.md) — and keep the structural sections (Summary, Description, Acceptance Criteria, Related Work) while leaving fetch-only fields empty.
2. Apply the **open-questions iterative dialog** principle (see [`SHAMT_RULES.template.md`](../../../../templates/SHAMT_RULES.template.md) Principle 2): maintain an `## Open Questions` section as you draft, surface each question to the user **one at a time** via `AskUserQuestion` (or equivalent), and update the ticket with each answer before moving to the next question. The ticket is not "drafted" while open questions remain.
3. The minimum viable ticket is a non-empty `ticket.md` capturing the ask, the acceptance criteria (or an explicit "Not declared" line), links, and any constraints. Do not invent acceptance criteria; if the user does not have any, write `Not declared — see Description.`.

**Stub-aware merge (when Step 2 marked the invocation as stub-aware).** The existing ticket.md from /pf3-decompose already carries the scope one-liner in the body intake area; its parent feature/epic are the folder path, not headers. When present, a ## Decomposition Context breadth section is preserved verbatim — decomposition-owned breadth that seeds the dialog (Step 2); it is not rewritten. The open-questions dialog fleshes out the remaining template sections (Summary, Acceptance Criteria, etc.) — it does not rewrite the scope one-liner or the Decomposition Context.

### Step 5 — Detect slug collisions

After writing the folder and ticket:

1. Confirm §PO-tree resolution matched exactly one story folder for this ticket.
2. If multiple folders exist (typically because a different brief was used previously), halt and ask the user to either reuse the existing folder or rename one.

### Step 6 — Confirm and exit (Gate)

Present an intake summary inline in chat:

- Folder: `stories/{ID}-{slug}-{brief}/`
- Source: `{profile name and link}` or `freeform`
- Ticket title, type, state, assignee (when fetched)
- Acceptance criteria (extracted or `Not declared`)

**Gate:** the user explicitly confirms the slug and ticket content. If the user wants changes, apply them, then re-prompt.

Write the resolved story-folder path to `shamt-state/active-story` (and `shamt-state/active-feature` / `active-epic` for its parents when nested); create `shamt-state/` if absent.

Suggest a context-clear before Phase 2 — `/clear`, then `/e2-define-spec {slug}` — per the context-clear-breakpoints guidance in [`SHAMT_RULES.template.md`](../../../../templates/SHAMT_RULES.template.md).

## Exit criteria

- `stories/{ID}-{slug}-{brief}/ticket.md` exists and is non-empty.
- Raw payloads (when fetched) live in `stories/{ID}-{slug}-{brief}/raw/`.
- The user has confirmed the slug and ticket content.

## Notes

- This command is **fresh-agent runnable**: every input it needs (config, profile, slug, existing files) lives on disk. No conversation history required.
- The `--tracker=` flag is **one-off**, not persisted. The project default in `.shamt-core/shamt-config.json` is unchanged.
- The freeform-fallback rule (per [`reference/trackers/_contract.md`](../../../../reference/trackers/_contract.md)) means future trackers that don't support `Story` natively still work — the command degrades gracefully with a one-line notice.
- **Stub-aware handoff from the PO flow.** When `/pf3-decompose` has already created the nested stub (…/features/<f>/stories/{slug}-*/ticket.md), that stub carries a scope one-liner in the body intake area; its parent feature/epic are the folder path, not headers. `/e1-start-story` **detects the stub state by inspecting the folder path** in Step 2 — nested parentage is the signal. There is **no new command flag and no new template**: the merge rule is:
  - The scope one-liner is preserved verbatim in the body.
  - Tracker-fetched fields (or open-questions answers) populate the remaining template sections per the same rules as the from-scratch path.
  - The `--tracker=` override still applies; fetched fields merge into the existing template.
  - The Engineer-flow Intake gate (Step 6) is unchanged — stub-handling is transparent to the gate. Stub-derived stories are individually testable per `/pf3-decompose`'s exit gate, so no rubric re-check at Intake.
- Phase 2 (Spec) is the next step. Resume with `/e2-define-spec {slug}` after `/clear`.

---
Validated 2026-05-28 — Phase 12 implementation loop. Touched by Phase 12: stub-aware Intake detection in Step 2 + stub-aware merge clauses in Step 4 sub-step B and sub-step C + Notes-section documentation of the path-nesting signal; original Phase 5 flow preserved for freeform stories.

<!-- Managed by Shamt — do not edit. Regenerate from shamt-core/host/templates/claude/commands/e1-start-story.md. -->
