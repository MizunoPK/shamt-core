# Tracker Profile — Azure DevOps (ADO)

**Conforms to** [`_contract.md`](_contract.md). Set `work_item_tracker: "ado"` (and/or `pr_provider: "ado"`) in [`.shamt-core/shamt-config.json`](../../shamt-config.example.json) to make this the active profile. For a one-off override, pass `--tracker=ado` to any slug-taking command (`/e1-start-story`, `/p1-start-epic`, `/p3-start-feature`).

This profile fetches Azure DevOps work items via the official `az` CLI and the `azure-devops` extension, then maps them into the unified output sections that [`templates/ticket.ado.template.md`](../../templates/ticket.ado.template.md) populates. The same field mapping will be reused by future PO-flow `epic.md` / `feature.md` artifacts when `/p1-start-epic` and `/p3-start-feature` land — see the [Field mapping](#field-mapping) section below for the cross-altitude notes.

---

## Prereqs

- **`az` CLI** — Microsoft Azure CLI, version 2.40 or newer. Install per [Microsoft docs](https://learn.microsoft.com/cli/azure/install-azure-cli).
- **`azure-devops` extension** — install with:

  ```bash
  az extension add --name azure-devops
  ```

- **Login** — interactive once per environment:

  ```bash
  az login
  az devops login   # paste a PAT scoped to Work Items (Read), Code (Read), Pull Request Threads (Read & Write)
  ```

- **Default org/project** (optional but recommended — avoids passing `--org` / `--project` on every command):

  ```bash
  az devops configure --defaults organization=https://dev.azure.com/<org> project=<project>
  ```

Profiles do not auto-install prereqs; `init-shamt.sh` confirms the active profile and points users at this file when prereqs are missing.

---

## Slug resolution

The slug passed to `/e1-start-story {slug}` (or sibling commands) follows the Engineer-flow convention `{id}-{brief-description}`. The leading numeric segment is the ADO work-item ID.

| Slug form | Resolves to | Example |
|-----------|-------------|---------|
| `1234-foo-bar` | Work-item ID `1234` in the default org/project | `/e1-start-story 1234-add-export` → fetch work item `1234` |
| `1234` | Work-item ID `1234` (no description; rare — folder name still requires a description) | — |

Cross-project work items are not addressable by slug form alone. To pull from a non-default org/project, set the session defaults first (`az devops configure --defaults organization=https://dev.azure.com/<org> project=<project>`) and then run the command normally.

If the slug does not begin with a numeric segment, the command treats it as freeform (no fetch).

---

## Primary fetch

```bash
az boards work-item show --id {id} --expand all --output json
```

`--expand all` returns the work item with `fields`, `relations`, and `_links` populated in a single call. The consuming command writes the verbatim JSON to `stories/{ID}-{slug}-{brief}/raw/issue.json` (or `epics/{ID}-{slug}-{brief}/raw/issue.json` / `features/{ID}-{slug}-{brief}/raw/issue.json` for the PO-flow variants once `/p1-start-epic` and `/p3-start-feature` ship — the folder located by ticket ID or slug per §PO-tree resolution; the feature variant nests under its epic (`epics/*/features/{ID}-{slug}-{brief}/raw/issue.json`)).

---

## Auxiliary fetches

| Endpoint | Command | Raw file | Notes |
|----------|---------|----------|-------|
| Comments | The primary fetch does not include comments; use the REST endpoint via `az rest`: `az rest --method GET --uri "https://dev.azure.com/<org>/<project>/_apis/wit/workItems/{id}/comments?api-version=7.1-preview.4" --output json` | `raw/comments.json` | Paginate via `continuationToken` if `count` exceeds page size. |
| Update history (revisions) | `az boards work-item show --id {id} --expand all --output json` already includes top-level `rev`. Full revision-by-revision history: `az rest --method GET --uri "https://dev.azure.com/<org>/<project>/_apis/wit/workItems/{id}/updates?api-version=7.1" --output json` | `raw/updates.json` | One entry per revision; ADO uses revision-number ordering. |
| Relations / linked items | Included in the primary fetch under `relations`. Extract for `raw/relations.json` with: `jq '.relations' raw/issue.json > raw/relations.json` | `raw/relations.json` | Covers parent/child links, related PRs, commits, attachments. |
| Attachments | Each attachment in `relations` carries a `url` (REST endpoint). Download with: `az rest --method GET --uri "{attachment.url}" --output-file raw/attachments/{filename}` | `raw/attachments/` | Optional; skip for v2 unless the consuming command opts in. |

A failed auxiliary fetch must not abort the command. Per the contract, record the failure in the corresponding `raw/<endpoint>.json` using the failure-object shape documented in [`templates/ticket.ado.template.md`](../../templates/ticket.ado.template.md).

---

## Field mapping

Unified target sections follow the field-mapping contract (Title, Type, State, Assignee, Project, Iteration/Milestone, Description, Acceptance Criteria, URL — defined in `_contract.md`). The same mapping will populate the corresponding sections of `epic.md` / `feature.md` once `/p1-start-epic` / `/p3-start-feature` land — the cross-altitude notes below describe that future reuse, but those commands and their artifact templates are not yet shipped.

| ADO raw field | Target section in unified artifact |
|---------------|------------------------------------|
| `fields["System.Title"]` | **Title** |
| `fields["System.WorkItemType"]` | **Type** (e.g., `Story`, `Feature`, `Epic`, `Bug`, `Task`) |
| `fields["System.State"]` | **State** |
| `fields["System.AssignedTo"]` (object with `displayName`, `uniqueName`) | **Assignee** |
| `fields["System.TeamProject"]` + `fields["System.AreaPath"]` | **Project** (display as `{TeamProject} / {AreaPath}`) |
| `fields["System.IterationPath"]` | **Iteration/Milestone** |
| `fields["System.Description"]` (HTML) | **Description** — convert HTML → Markdown per the ticket template's "HTML Normalization Rules" |
| `fields["Microsoft.VSTS.Common.AcceptanceCriteria"]` (HTML) | **Acceptance Criteria** — same HTML→Markdown conversion |
| `_links.html.href` | **URL** (browser-facing work-item link) |
| Every other non-empty `fields[*]` key | **All Remaining Fields** (use the `Field.ReferenceName` form, e.g., `Microsoft.VSTS.Scheduling.StoryPoints`) |
| `relations[*]` | **Related Work** |
| (comments fetch) | **Comments** |
| (updates fetch) | **Update History** |

**Cross-altitude reuse (forward-looking — `/p1-start-epic` and `/p3-start-feature` not yet shipped):** when those commands land, the `Description` and `Acceptance Criteria` mappings feed the `Goal` and `Success Criteria` sections of `epic.md` / `feature.md` respectively; `Title`, `State`, `Assignee`, `Iteration/Milestone`, and `URL` populate the header metadata block.

---

## PR fetch

```bash
az repos pr show --id {id} --output json
```

For the diff (used by `/e6-review-changes` when needed):

```bash
az repos pr show --id {id} --query "lastMergeSourceCommit.commitId" --output tsv
# then: git diff <baseCommit>..<headCommit>
```

The PR `id` here is the ADO Pull Request ID, distinct from the work-item ID. `pr_provider` is read independently of `work_item_tracker` per the tracker contract, so this fetch may run against ADO even when work items live elsewhere.

---

## PR comment posting

**Not invoked by v2.** Documented for future use only — `/e6-review-changes` produces a local artifact at `code_reviews/` and does not post upstream (resolved open question).

For reference, the command shape is:

```bash
az repos pr comment create --id {pr_id} --content "<markdown body>" --output json
```

Threaded replies use `--parent-comment-id`. When `/e6-review-changes` (or any downstream automation) gains a post-back feature, this is the entry point.

---

## Auth failure modes

| Error pattern | Meaning | Fallback |
|---------------|---------|----------|
| `TF400813` in stderr | The PAT is invalid, expired, or lacks required scope | Skip the affected fetch, log the failure to the matching `raw/<endpoint>.json` per the contract, surface a one-line notice (`ado auth failed — falling back to manual capture for {section}`), and continue. |
| `Unauthorized` or HTTP `401` from `az rest` | Same as above | Same fallback. |
| `TF401019` (project not found) | Default project not set or work item lives in a different project | Surface the error and halt; suggest re-running `az devops configure --defaults organization=https://dev.azure.com/<org> project=<correct>` so the right project becomes the session default. (The slug-taking commands have no `--project` flag; project selection is via `az devops configure --defaults` only.) |
| `ERROR: 'pr' is misspelled or not recognized` | `azure-devops` extension not installed | Halt with prereq pointer (this file's [Prereqs](#prereqs) section). |
| Network timeout / `Could not resolve host` | Transient network or VPN issue | Retry once; on second failure, fall back to manual capture with one-line notice. |

Detection happens by matching the error string against the patterns above; the consuming command does not need to parse error codes.

---

## Supported work-item types

- **Story** — `System.WorkItemType = "User Story"` (Agile process) or `"Product Backlog Item"` (Scrum process) or `"Issue"` (Basic process); the profile treats all three as `Story` for `/e1-start-story` purposes.
- **Feature** — `System.WorkItemType = "Feature"`.
- **Epic** — `System.WorkItemType = "Epic"`.

ADO supports all three natively, so `/e1-start-story`, `/p3-start-feature`, and `/p1-start-epic` all fetch from this profile without falling through to freeform mode.

Other native types (`Bug`, `Task`, `Test Case`, etc.) are not driven by any current v2 command but fetch correctly when referenced — the consuming command's freeform-fallback path simply takes whatever `Type` field comes back and writes it through.

---

*Day-one tracker profile. See [`_contract.md`](_contract.md) for the contract this file conforms to, and [`templates/ticket.ado.template.md`](../../templates/ticket.ado.template.md) for the artifact this profile feeds.*
