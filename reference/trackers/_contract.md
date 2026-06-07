# Tracker Profile Contract

**Purpose:** Defines what every tracker profile in this directory must declare. Used by `/e1-start-story`, `/p1-start-epic`, `/p3-start-feature`, and `/e6-review-changes` to fetch work-item content from an external tracker, map it into the unified artifact shape, and degrade gracefully when the active tracker can't cover a requested work-item type.

A profile is a single Markdown file at `reference/trackers/{name}.md`. The active profile is selected by `work_item_tracker` in `.shamt-core/shamt-config.json` (see [`shamt-config.example.json`](../../shamt-config.example.json)). Day-one profiles: [`ado.md`](ado.md), [`github.md`](github.md), [`local.md`](local.md). Future trackers (Jira, Linear, etc.) are added by writing a new file that conforms to this contract — no framework change required.

---

## Required sections

Every profile file must include the following sections, in this order, using h2 headings (`##`). A consuming command (`/e1-start-story` and siblings) reads them by heading and will halt with a clear error if any required section is missing.

| Section | Purpose |
|---------|---------|
| `## Prereqs` | CLI binaries the profile depends on, the auth/login command, and any scope or extension requirements. List exact commands so a fresh user can reproduce. |
| `## Slug resolution` | How to extract a tracker work-item ID from the common slug formats `/e1-start-story` accepts (e.g., `1234-foo-bar` → `1234`, or `org/repo#42` → issue `42`). Cover at least: the leading-numeric form, and any tracker-native cross-project form. |
| `## Primary fetch` | The exact CLI command that returns the full work-item payload, parameterized on `{id}`. The consuming command writes the verbatim output to `raw/issue.json`. |
| `## Auxiliary fetches` | Commands for any payloads the primary fetch does not include — typically comments, update events / revisions / timeline, relations / linked items, attachments. One command per endpoint, each writing to its own `raw/<endpoint>.json`. Failures in auxiliary fetches do not abort the command (see fallback rule below); they are recorded in the corresponding raw file. |
| `## Field mapping` | A table mapping the tracker's raw field names to the unified output sections. At minimum: Title, Type, State, Assignee, Project, Iteration/Milestone, Description, Acceptance Criteria, URL. The same mapping is reused across `ticket.md` / `epic.md` / `feature.md` — the consuming command picks which target sections to populate. |
| `## PR fetch` | CLI to retrieve PR metadata and diff for a given PR ID, parameterized on `{id}`. Used by `/e6-review-changes` when `pr_provider` is set to this tracker. |
| `## PR comment posting` | CLI to post a Markdown comment to a PR. **Documented for future use only — `/e6-review-changes` does not post back to external trackers in v2.** A profile is still required to declare this so the contract surface stays complete for future use. |
| `## Auth failure modes` | The exact error strings or HTTP status patterns that indicate auth failure for the listed CLIs, and what fallback the consuming command should take (typically: skip the fetch and fall through to manual capture, with a one-line notice). |
| `## Supported work-item types` | A bullet list naming which of `Story`, `Feature`, `Epic` (or other agile types this profile recognizes) the tracker supports as native work-item types. This drives the freeform-fallback rule below. Use `Any` for tracker-agnostic profiles (e.g., `local`). |

A profile may add further sections (examples, troubleshooting notes, cross-references). They are not part of the contract.

---

## Freeform-fallback rule

When a command (`/e1-start-story`, `/p1-start-epic`, `/p3-start-feature`) is invoked against an active profile that does **not** declare support for the requested work-item type in its `## Supported work-item types` section, the command **falls through to freeform mode** — identical behavior to when the slug doesn't resolve to a tracker ID at all.

The agent surfaces a one-line notice (template: `tracker profile <name> has no <Type> work-item type — proceeding freeform`) and continues. No error. No halt. The user then captures the artifact content manually via the open-questions iterative dialog, exactly as if `work_item_tracker = "none"`.

This rule is the integration point that lets future trackers be added without modifying any command. GitHub, for instance, supports only `Issue` natively, so `/p3-start-feature` and `/p1-start-epic` against the `github` profile fall through automatically — but `/e1-start-story` still benefits from the GitHub profile's fetch wiring.

---

## Per-invocation tracker override

All slug-taking PO/Engineer commands that consult a tracker profile accept an optional `--tracker={name}` flag. The flag is a one-off override for that invocation only; the default comes from `.shamt-core/shamt-config.json`. Every profile in this directory is a valid value for the flag.

Example: a project configured with `work_item_tracker = "ado"` can still pull a single GitHub issue with `/e1-start-story 42-foo --tracker=github` without editing config.

Each profile file should document the `--tracker={name}` form near the top of its body, naming itself as the legal value.

---

## Where the contract is exercised

| Consumer | Reads | When |
|----------|-------|------|
| `/e1-start-story {slug}` | `## Slug resolution`, `## Primary fetch`, `## Auxiliary fetches`, `## Field mapping`, `## Auth failure modes`, `## Supported work-item types` (filter on `Story`) | Phase 1 (Intake) |
| `/p1-start-epic {slug}` | Same as above, filtered on `Epic` | PO flow |
| `/p3-start-feature {slug}` | Same as above, filtered on `Feature` | PO flow |
| `/e6-review-changes {slug}` | `## PR fetch`, `## Auth failure modes`. Driven by `pr_provider` (which may differ from `work_item_tracker`). | Phase 6 (Review) |

`## PR comment posting` is declared but not invoked by any v2 consumer. It is present so the contract is complete for downstream automation that may want to post review summaries upstream.

---

## Adding a new tracker

1. Create `reference/trackers/{name}.md`.
2. Cover every section in the [Required sections](#required-sections) table above, in the given order, with h2 headings.
3. Declare `## Supported work-item types` honestly — leaving a type out is correct when the tracker has no native concept for it (freeform fallback handles the rest).
4. Add the new `{name}` as a legal value for `work_item_tracker` and/or `pr_provider` in [`shamt-config.example.json`](../../shamt-config.example.json) and the `.shamt-core/shamt-config.json` schema notes in [`README.md`](../../README.md).
5. No regen, command, or template change is required.

---

*Canonical contract for `reference/trackers/`. See `ado.md`, `github.md`, `local.md` for the day-one profiles.*
