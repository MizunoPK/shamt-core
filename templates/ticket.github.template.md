# Story {slug} Ticket

<!-- Parent back-refs (optional). Present when this story was created by /p4-decompose-feature; absent for standalone stories. -->
**Parent Feature:** {feature-slug}
**Parent Epic:** {epic-slug}

**Tracker profile:** GitHub (see `reference/trackers/github.md` for fetch commands and field mapping)
**Source:** [GitHub Issues / verbal / etc.]
**Date received:** [YYYY-MM-DD]

---

[Paste ticket content here — any format accepted: GitHub issue body, Slack thread, email, voice memo transcript, or plain text. No structure required for the manual-capture form. The agent extracts structure in the Spec phase.]

The sections below populate automatically when `/e1-start-story {slug}` resolves the slug to a GitHub issue (e.g., `org/repo#42` → issue `42`) and fetches it through the `gh` CLI workflow documented in `reference/trackers/github.md`. Omit them for manual/freeform tickets.

**Source:** GitHub issue {`org/repo#id`}
**Fetched:** {YYYY-MM-DD HH:mm local}
**URL:** {`https://github.com/<org>/<repo>/issues/{id}`}

## Markdown Normalization Rules (when rendering fetched fields)

GitHub returns issue bodies and comments as Markdown (raw, not HTML), so HTML decoding is rarely needed. When it is:

- **Decode entities.** Convert any incidental `&nbsp;`, `&quot;`, `&amp;`, `&lt;`, `&gt;` to their literal characters.
- **Preserve fenced code blocks and tables.** Do not re-flow or re-format; keep the Markdown as-fetched.
- **Image references and attachments.** GitHub renders user uploads as `https://user-images.githubusercontent.com/...` URLs inside the body. Preserve them as-is; do not download.
- **Preserve encoding artifacts as-is.** If a comment contains `�` (U+FFFD REPLACEMENT CHARACTER), keep it and add: `> Note: this field contains U+FFFD replacement characters from upstream encoding artifacts. Preserved as-is; the raw payload is in raw/issue.json.`
- **Long custom fields (>2 KB).** Render in full inside the "All Remaining Fields" section; link to the raw JSON for fidelity. Do not silently truncate.

## Decomposition Context

<!-- Cataloged at decomposition (/p2-decompose-epic for features, /p4-decompose-feature for stories) — bounded breadth context discovered by researching the whole sibling set. NOT a depth dump (design/acceptance/implementation detail belongs in the depth sections, filled at start-*). /p3-start-feature and /e1-start-story consume this as a research seed. Leave the placeholder bullets if nothing was cataloged. -->

- **Dependencies on siblings:** [which sibling features/stories this one depends on or blocks — "none" if independent]
- **Shared context:** [context spanning the set this child needs — shared modules, data, infra, conventions]
- **Boundary rationale:** [why this child is scoped as drawn rather than merged into a sibling]

## Summary

- **Title:** {`title`}
- **Type:** [`Issue` — GitHub Issues has a single work-item type. Repository-defined issue types via the GraphQL `IssueType` field, if used, go here.]
- **State:** {`state`} ({`stateReason`} when present, e.g., `completed`, `not_planned`)
- **Assigned To:** {`assignees[].login`}
- **Project:** {`<org>/<repo>`} (and {`projectItems[].project.title`} when on a Project board)
- **Iteration/Milestone:** {`milestone.title`} (or {`projectItems[].fieldValues` Iteration field when on a Project board)

## Description

{`body` rendered as Markdown — fetched payload is already Markdown}

## Acceptance Criteria

{Extracted from the issue body. GitHub has no first-class Acceptance Criteria field; profile convention (see `reference/trackers/github.md`) is to read an `Acceptance Criteria` section from the body, or an `acceptance-criteria` label-anchored block. If none present, write `Not declared — see Description.`}

## Related Work

{`labels[].name` (all labels); linked pull requests via the GitHub timeline (`cross-referenced` events); linked issues; attached commits; sub-issues / parent issues when present (GitHub's tasklist feature). Include attachments URLs.}

## Comments

{Every comment fetched via `gh issue view {id} --comments`, preserving `author.login`, `createdAt`, `updatedAt`, and body text}

## Update History

{Every relevant update event from the GitHub timeline (`gh api repos/<org>/<repo>/issues/{id}/timeline`), preserving event type (e.g., `labeled`, `unlabeled`, `assigned`, `milestoned`, `closed`, `reopened`, `cross-referenced`, `renamed`), actor, `createdAt`, and event-specific payload. Equivalent to ADO's per-revision changed-fields list.}

When an auxiliary fetch (timeline, comments, or sub-issues) fails after the primary fetch succeeded, record the failure in the corresponding `raw/<endpoint>.json` file as a JSON object with these keys, and link to it from the matching section above:

```json
{
  "fetch_status": "failed",
  "error": "<exact CLI error message>",
  "attempts": ["<exact command(s) tried>"],
  "note": "<one-line implication, e.g., 'Timeline events not captured. Issue update history is unavailable for this fetch.'>"
}
```

## All Remaining Fields

Every non-empty field from the raw issue payload not already listed above, including repository-level custom fields and Project field values. Use the GitHub field path as the heading/key.

- `{field-path}`: `{value}`

Examples of fields that commonly land here:

- `author.login` — issue opener
- `createdAt` / `updatedAt` / `closedAt`
- `reactions.totalCount`
- `projectItems[].fieldValues[]` — Projects v2 custom field values
- repository-defined custom issue types when `IssueType` is in use

## Raw Issue JSON

See `raw/issue.json` (full primary issue payload preserved verbatim from `gh issue view {id} --json <all-fields>`).

## Raw Relation JSON

See `raw/relations.json` (linked PRs, sub-issues, cross-references, or failure note).

## Raw Comments JSON

See `raw/comments.json`, or inline below when under 2 KB:

```json
{full paginated output from `gh issue view {id} --comments`, or failure note}
```

## Raw Updates JSON

See `raw/updates.json`, or inline below when under 2 KB:

```json
{full paginated output from the timeline endpoint, or failure note}
```

---

## Open Questions

[Only unresolved questions about the ticket itself — ambiguous acceptance criteria, missing context, conflicting requirements. Per the open-questions iterative-dialog principle in `templates/SHAMT_RULES.template.md`, surface each question to the user one at a time and update this ticket with each answer before moving on. Substantive design questions belong in the spec, not here.]
