# Tracker Profile — GitHub (CLI)

**Conforms to** [`_contract.md`](_contract.md). Set `work_item_tracker: "github"` (and/or `pr_provider: "github"`) in [`.shamt-core/shamt-config.json`](../../shamt-config.example.json) to make this the active profile. For a one-off override, pass `--tracker=github` to any slug-taking command (`/e1-start-story`, `/p1-start-epic`, `/p3-start-feature`).

This profile fetches GitHub Issues and Pull Requests via the official `gh` CLI, then maps them into the unified output sections that [`templates/ticket.github.template.md`](../../templates/ticket.github.template.md) populates. The same field mapping would extend to PO-flow `epic.md` / `feature.md` artifacts once `/p1-start-epic` and `/p3-start-feature` land — but per [Supported work-item types](#supported-work-item-types) below, those commands fall through to freeform mode on this profile anyway.

GitHub Issues has a **single native work-item type** (`Issue`). It has no first-class `Feature` or `Epic` type, so `/p3-start-feature` and `/p1-start-epic` against this profile fall through to freeform mode per the freeform-fallback rule in [`_contract.md`](_contract.md#freeform-fallback-rule). `/e1-start-story` is fully supported.

---

## Prereqs

- **`gh` CLI** — GitHub's official CLI, version 2.40 or newer. Install per [GitHub docs](https://cli.github.com/).
- **`jq`** — recommended for any post-processing of `--json` output. Usually preinstalled on Linux/macOS.
- **Login** — interactive once per environment:

  ```bash
  gh auth login
  ```

  Choose **HTTPS** as the protocol and authorize with scopes `repo` (full) and `read:org` at minimum. The PAT or browser-flow token is cached by `gh`; no further env setup needed.

- **Repo context** — `gh` resolves the active repository from the current working directory's `git remote`. Outside a clone, all commands must take an explicit `--repo <org>/<repo>` argument. The fetches below show the explicit form; the consuming command supplies `--repo` from `git remote get-url origin` when one is configured.

Profiles do not auto-install prereqs; `init-shamt.sh` confirms the active profile and points users at this file when prereqs are missing.

---

## Slug resolution

The slug passed to `/e1-start-story {slug}` follows the Engineer-flow convention `{id}-{brief-description}`. GitHub issue numbers are repo-scoped, so two forms are accepted:

| Slug form | Resolves to | Example |
|-----------|-------------|---------|
| `42-foo-bar` | Issue `42` in the repository inferred from the local `git remote` (`origin`) | `/e1-start-story 42-add-export` → fetch issue `42` from the current repo |
| `org/repo#42-foo-bar` | Issue `42` in `<org>/<repo>` (cross-repo form) | `/e1-start-story acme/widgets#42-cross-repo-fix` → fetch issue `42` from `acme/widgets` |
| `42` | Issue `42` in the inferred repo (no description; rare — folder name still requires a description) | — |

If the slug does not begin with a numeric segment (or with `<org>/<repo>#<number>`), the command treats it as freeform (no fetch).

---

## Primary fetch

```bash
gh issue view {id} --repo <org>/<repo> \
  --json number,title,body,state,stateReason,labels,milestone,assignees,author,url,createdAt,updatedAt,closedAt,projectItems,reactionGroups
```

The consuming command writes the verbatim JSON to `stories/{slug}-*/raw/issue.json`. PO-flow variants (`epics/{slug}-*/raw/issue.json`, `features/{slug}-*/raw/issue.json` — flat folder layout) do not apply here, because `/p1-start-epic` and `/p3-start-feature` against this profile fall through to freeform mode (see [Supported work-item types](#supported-work-item-types) below).

Custom issue types (the repo-level GraphQL `IssueType` field, in repos that have opted into the feature) are not exposed by `gh issue view --json` as of this writing; if a project depends on them, augment with the GraphQL form:

```bash
gh api graphql -f query='query($owner:String!,$repo:String!,$number:Int!){repository(owner:$owner,name:$repo){issue(number:$number){issueType{name}}}}' \
  -F owner=<org> -F repo=<repo> -F number={id}
```

---

## Auxiliary fetches

| Endpoint | Command | Raw file | Notes |
|----------|---------|----------|-------|
| Comments | `gh issue view {id} --repo <org>/<repo> --json comments` (or `gh api repos/<org>/<repo>/issues/{id}/comments` for full pagination) | `raw/comments.json` | The `--json comments` form returns all comments inline. |
| Timeline / update events | `gh api repos/<org>/<repo>/issues/{id}/timeline --paginate` | `raw/updates.json` | Equivalent to ADO's revisions. Includes `labeled`, `unlabeled`, `assigned`, `milestoned`, `closed`, `reopened`, `cross-referenced`, `renamed`, `referenced`, `committed`, `connected`, `disconnected` events. |
| Relations / linked items | Linked PRs and cross-references are captured by the timeline fetch above — `connected` events represent Development-panel links (the "Closes #N" / linked-PR sidebar), and `cross-referenced` events represent inbound mentions. No additional command is needed for this row; just extract the relevant timeline entries from `raw/updates.json` into `raw/relations.json`. Sub-issues / tasklist parents: `gh api graphql` with the `subIssues` / `parent` connections when the repo has tasklists enabled. | `raw/relations.json` | GitHub has no single "relations" endpoint; this file aggregates from the timeline plus tasklist GraphQL. Note: `gh pr list --search "linked:issue"` exists but is a has-any-link boolean filter, not an issue-ID match — do not use it for this row. |
| Attachments | GitHub user uploads live at `https://user-images.githubusercontent.com/...` (or `https://github.com/user-attachments/...`) and are embedded in `body` / `comments[*].body` as Markdown image/link syntax. Per the ticket template, preserve URLs in place and do **not** download. | n/a | No separate fetch. |

A failed auxiliary fetch must not abort the command. Per the contract, record the failure in the corresponding `raw/<endpoint>.json` using the failure-object shape documented in [`templates/ticket.github.template.md`](../../templates/ticket.github.template.md).

---

## Field mapping

Unified target sections follow the field-mapping contract (Title, Type, State, Assignee, Project, Iteration/Milestone, Description, Acceptance Criteria, URL — defined in `_contract.md`). The mapping populates the `ticket.md` sections that [`templates/ticket.github.template.md`](../../templates/ticket.github.template.md) defines. (Forward-looking: when `/p1-start-epic` / `/p3-start-feature` land, the same mapping would feed `epic.md` / `feature.md` for profiles that support those types — which on GitHub does not apply, since both fall through to freeform per the rule below.)

| GitHub raw field | Target section in unified artifact |
|------------------|------------------------------------|
| `title` | **Title** |
| `labels[]` filtered by name prefix `type:` (e.g., `type:story`, `type:bug`), with fallback `"Issue"` when no `type:*` label is present | **Type** |
| `state` (`OPEN` / `CLOSED`); append `stateReason` in parens when present (`completed`, `not_planned`, `reopened`) | **State** |
| `assignees[].login` (join with `, ` for multiple) | **Assignee** |
| `<org>/<repo>` (from `--repo` arg or inferred from `git remote`); append `projectItems[].project.title` when the issue is on a Projects v2 board | **Project** |
| `milestone.title`; or `projectItems[].fieldValues[]` entry whose `field.name == "Iteration"` for Projects v2 iteration fields | **Iteration/Milestone** |
| `body` (Markdown — fetched payload is already Markdown, no HTML decode needed) | **Description** |
| Section of `body` whose header matches `^#{1,3}\s*Acceptance Criteria\s*$` (case-insensitive); or content of any tasklist block following such a header; if none present, write the literal string `Not declared — see Description.` | **Acceptance Criteria** |
| `url` | **URL** |
| Every other non-empty top-level field from the primary fetch | **All Remaining Fields** (e.g., `author.login`, `createdAt`, `updatedAt`, `closedAt`, `reactionGroups`, `projectItems[].fieldValues[]`) |
| `labels[].name` (all), plus linked PRs/issues from the timeline | **Related Work** |
| (comments fetch) | **Comments** |
| (timeline fetch) | **Update History** |

If a project tags issues with `type:epic` / `type:feature` labels and wants those treated as such by a future `/p1-start-epic` / `/p3-start-feature` invocation, the resulting `Type` field is just a string, not a native GitHub work-item type — the freeform-fallback rule still fires because the profile does not declare the type as supported.

---

## PR fetch

```bash
gh pr view {id} --repo <org>/<repo> \
  --json number,title,body,state,headRefName,baseRefName,headRefOid,baseRefOid,commits,files,labels,milestone,assignees,reviewRequests,reviews,url
```

For the diff (used by `/e6-review-changes`):

```bash
gh pr diff {id} --repo <org>/<repo>
```

`pr_provider` is read independently of `work_item_tracker` per the tracker contract. This fetch may run against GitHub even when work items live in ADO.

---

## PR comment posting

**Not invoked by v2.** Documented for future use only — `/e6-review-changes` produces a local artifact at `code_reviews/` and does not post upstream (resolved open question).

For reference, the command shapes are:

```bash
# Single comment on the PR conversation (not a review)
gh pr comment {id} --repo <org>/<repo> --body "<markdown body>"

# A full review with comments (preferred for /e6-review-changes findings if/when posting is added)
gh pr review {id} --repo <org>/<repo> --comment --body "<markdown body>"
```

Per-line/file comments require the GraphQL `addPullRequestReviewComment` mutation via `gh api graphql`; documented here only as the entry point for future automation.

---

## Auth failure modes

| Error pattern | Meaning | Fallback |
|---------------|---------|----------|
| `gh: Resource not accessible by integration` | Token lacks required scope on the target repo (typically `repo`) | Skip the affected fetch, log the failure to the matching `raw/<endpoint>.json` per the contract, surface a one-line notice (`github auth failed — falling back to manual capture for {section}`), and continue. |
| `HTTP 401: Bad credentials` | Token expired or revoked | Same fallback; suggest `gh auth refresh -s repo` in the notice. |
| `HTTP 403: API rate limit exceeded` | Hit the unauthenticated or per-token rate limit | Same fallback; rate-limit reset time is in the response header `x-ratelimit-reset`. |
| `HTTP 404: Not Found` on the primary fetch | Issue/PR doesn't exist, or the repo is private and the token can't see it | Halt; the user likely has a wrong slug or wrong repo. Do **not** fall back silently — a missing primary fetch is a hard error per the contract. |
| `gh: command not found` | `gh` CLI not installed | Halt with prereq pointer (this file's [Prereqs](#prereqs) section). |
| Network timeout / `dial tcp: lookup api.github.com` | Transient network or DNS issue | Retry once; on second failure, fall back to manual capture with one-line notice. |

Detection happens by matching the error string against the patterns above; the consuming command does not need to parse error codes.

---

## Supported work-item types

- **Story** — GitHub Issues are the only native item type; this profile treats any GitHub issue as a `Story` for `/e1-start-story` purposes. Repo-level `type:story` labels (when used) further confirm intent but are not required.

GitHub has **no** native `Feature` or `Epic` work-item types. `/p3-start-feature` and `/p1-start-epic` invoked against this profile fall through to freeform mode per the [freeform-fallback rule](_contract.md#freeform-fallback-rule) — the agent surfaces a one-line notice (`tracker profile github has no Feature work-item type — proceeding freeform` or the Epic equivalent) and the user captures content manually via the open-questions iterative dialog.

GitHub's repo-level `IssueType` field (org-defined custom types) can carry strings like `Feature` or `Epic` when a project chooses to use them, but the values are repo-/org-configured rather than first-class agile concepts and `gh issue view --json` does not expose them. If a project standardizes on `IssueType` for Feature/Epic semantics, update this section and add the corresponding GraphQL augmentation to [Primary fetch](#primary-fetch).

---

*Day-one tracker profile. See [`_contract.md`](_contract.md) for the contract this file conforms to, and [`templates/ticket.github.template.md`](../../templates/ticket.github.template.md) for the artifact this profile feeds.*
