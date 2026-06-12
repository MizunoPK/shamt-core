# Tracker Profile — Local

**Conforms to** [`_contract.md`](_contract.md) in shape but is a no-fetch profile: the ticket file is already a local Markdown artifact — authored by the user, or written as a stub by the PO flow's `/p4-decompose-feature` and then fleshed out by `/e1-start-story` (Engineer flow, Phase 1). Set `work_item_tracker: "local"` in [`.shamt-core/shamt-config.json`](../../shamt-config.example.json) to make this the active profile. For a one-off override — e.g., a project configured for `ado` or `github` that wants to skip the external fetch for a single command — pass `--tracker=local` to any slug-taking command (`/e1-start-story`, `/p1-start-epic`, `/p3-start-feature`).

Use this mode when story content lives in-repo as a hand-written `ticket.md` — for example, when the PO flow produced the story locally and no external tracker is involved, or when a project tracks work outside any supported issue tracker (Notion, a wiki, a shared doc, voice memos transcribed into Markdown) and the canonical version is the file on disk.

For the distinction between `local` and `none`, see the [`local` vs `none` note](#local-vs-none) below.

---

## Prereqs

None. This profile uses no external CLI.

---

## Slug resolution

The slug passed to `/e1-start-story {slug}` resolves to a story folder via glob, exactly as it does for fetching profiles:

| Slug form | Resolves to |
|-----------|-------------|
| `{slug}` | the story folder resolved per §PO-tree resolution (tree-wide glob + legacy-flat fallback). If zero or multiple folders match, the command halts with a clear error. |

The numeric-prefix convention used by `ado` and `github` profiles is **optional** in `local` mode — any slug is legal as long as exactly one matching story folder exists. The folder must already contain a `ticket.md` file; `/e1-start-story` does not create one in this mode (it treats the local file as the source of truth).

For the PO-flow commands (`/p1-start-epic` / `/p3-start-feature`), folders resolve per `templates/SHAMT_RULES.template.md` §PO-tree resolution: epics are top-level (`epics/{slug}-*/epic.md`), features nest under their epic (`epics/*/features/{slug}-*/feature.md`), with the legacy-flat fallback. Globally unique slugs; the folder name is `{slug}-{brief}`. Same rule as stories: the file must already exist or be created by the PO-flow command itself.

---

## Primary fetch

None — the file is the source of truth. `/e1-start-story {slug}` reads `stories/{slug}-*/ticket.md` (resolved per §PO-tree resolution) directly and proceeds to the open-questions iterative dialog for any unresolved sections.

If the file is missing, the command halts with an error directing the user to create it (typically by running an upstream PO-flow command, or by writing it by hand from [`templates/ticket.ado.template.md`](../../templates/ticket.ado.template.md) or [`templates/ticket.github.template.md`](../../templates/ticket.github.template.md) — either template works as a freeform skeleton; the `local` profile does not enforce a specific one).

---

## Auxiliary fetches

None. There are no comments, revisions, relations, or attachments to fetch — anything the user wants to capture lives in the file (or alongside it in the story folder, e.g., `raw/notes.md`).

---

## Field mapping

None. The file *is* the unified artifact — no source-to-target translation step. Section headings in the local `ticket.md` should follow the unified shape (`## Title`, `## Description`, `## Acceptance Criteria`, etc.) so the Spec phase reads them consistently, but `local` mode does not enforce structure: the Spec phase will still work against an unstructured ticket via the open-questions iterative dialog.

---

## PR fetch

None — `local` is a work-item-tracker mode only. PR fetching is governed independently by `pr_provider` in `.shamt-core/shamt-config.json` (which may be set to `ado`, `github`, or `none`); see the corresponding tracker profile for PR-fetch details.

---

## PR comment posting

None. Not applicable.

---

## Auth failure modes

None. Not applicable.

---

## Supported work-item types

- **Any** — `local` mode imposes no constraint on work-item type. `/e1-start-story`, `/p3-start-feature`, and `/p1-start-epic` all work, each reading the corresponding local file (`stories/{slug}-*/ticket.md`, `epics/*/features/{slug}-*/feature.md`, `epics/{slug}-*/epic.md`) (resolved per §PO-tree resolution).

Because the `Any` value covers every possible request, the freeform-fallback rule never fires for this profile — every command takes the file-read path.

---

## `local` vs `none`

| Mode | `work_item_tracker` value | Behavior |
|------|---------------------------|----------|
| `local` | `"local"` | Slug → glob resolution against `stories/`, `epics/`, or `features/` per the command. File must exist; command proceeds in file-as-source-of-truth mode. Per-invocation `--tracker=local` is also valid. |
| `none` | `"none"` | Tracker integration is disabled entirely. No profile is consulted. `/e1-start-story` still expects the story folder + `ticket.md` to exist locally (same behavioral result as `local` for the Engineer flow), but `init-shamt.sh` does not surface tracker-related setup at all. No profile doc exists for `none` — it is a config sentinel, not a profile. |

Use `local` when the project occasionally pulls from a tracker via `--tracker=ado|github` overrides but defaults to local files. Use `none` when the project never uses a tracker — the resulting UX skips all tracker prompts and pointers.

---

*Day-one tracker profile. See [`_contract.md`](_contract.md) for the contract this file conforms to.*
