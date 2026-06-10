# Story {slug} Ticket

<!-- Parent back-refs (optional). Present when this story was created by /p4-decompose-feature; absent for standalone stories. -->
**Parent Feature:** {feature-slug}
**Parent Epic:** {epic-slug}

**Tracker profile:** ADO (see `reference/trackers/ado.md` for fetch commands and field mapping)
**Source:** [Azure DevOps / verbal / etc.]
**Date received:** [YYYY-MM-DD]

---

[Paste ticket content here — any format accepted: ADO HTML export, Slack thread, email, voice memo transcript, or plain text. No structure required for the manual-capture form. The agent extracts structure in the Spec phase.]

The sections below populate automatically when `/e1-start-story {slug}` resolves the slug to an ADO work-item ID and fetches it through the ADO CLI workflow documented in `reference/trackers/ado.md`. Omit them for manual/freeform tickets.

**Source:** Azure DevOps work item {id}
**Fetched:** {YYYY-MM-DD HH:mm local}
**URL:** {`https://dev.azure.com/<org>/<project>/_workitems/edit/{id}`}

## HTML Normalization Rules (when rendering fetched HTML fields)

- **Decode entities.** Convert `&nbsp;`, `&quot;`, `&amp;`, `&lt;`, `&gt;`, and any other named/numeric HTML entities to their literal characters.
- **Strip presentational attributes.** Remove inline `style="..."` and `class="..."` attributes; keep tag structure (`<p>`, `<ul>`, `<li>`, `<b>`, `<a href>`) so paragraph/list/link semantics survive conversion.
- **Preserve encoding artifacts as-is.** Some fetched HTML contains `�` (U+FFFD REPLACEMENT CHARACTER) where the upstream content had smart quotes or em-dashes that did not round-trip cleanly. Keep these characters in the rendered Markdown rather than guessing the intended character. If any field contains `�`, add a one-line note under the affected section: `> Note: this field contains U+FFFD replacement characters where the upstream HTML had encoding artifacts. Preserved as-is; the raw HTML is in raw/issue.json.`
- **Long custom HTML fields (>2 KB).** For custom HTML fields above 2 KB (for example, long design-notes fields), render the converted Markdown in full inside the "All Remaining Fields" section if the content is part of the spec input. Always link to the raw JSON section for fidelity. Do not silently truncate.

## Decomposition Context

<!-- Cataloged at decomposition (/p2-decompose-epic for features, /p4-decompose-feature for stories) — bounded breadth context discovered by researching the whole sibling set. NOT a depth dump (design/acceptance/implementation detail belongs in the depth sections, filled at start-*). /p3-start-feature and /e1-start-story consume this as a research seed. Leave the placeholder bullets if nothing was cataloged. -->

- **Dependencies on siblings:** [which sibling features/stories this one depends on or blocks — "none" if independent]
- **Shared context:** [context spanning the set this child needs — shared modules, data, infra, conventions]
- **Boundary rationale:** [why this child is scoped as drawn rather than merged into a sibling]

## Summary

- **Title:** {`System.Title`}
- **Type:** {`System.WorkItemType`}
- **State:** {`System.State`}
- **Assigned To:** {`System.AssignedTo`}
- **Project:** {`System.TeamProject`} / {`System.AreaPath`}
- **Iteration/Milestone:** {`System.IterationPath`}

## Description

{`System.Description` converted from HTML to readable Markdown/plain text}

## Acceptance Criteria

{`Microsoft.VSTS.Common.AcceptanceCriteria` converted from HTML to readable Markdown/plain text when present}

## Related Work

{`System.Relations` — parent/child links, related work items, pull requests, commits, attachments when present}

## Comments

{Every fetched issue comment from the comments endpoint, preserving author, created/modified dates, and comment text}

## Update History

{Every fetched update event (ADO revision), preserving revision number, changed fields, changed relations, and actor/timestamp metadata}

When an auxiliary fetch (relations, comments, or updates) fails after the primary fetch succeeded, record the failure in the corresponding `raw/<endpoint>.json` file as a JSON object with these keys, and link to it from the matching section above:

```json
{
  "fetch_status": "failed",
  "error": "<exact CLI error message>",
  "attempts": ["<exact command(s) tried>"],
  "note": "<one-line implication, e.g., 'Update history not captured. Issue is at revision N — prior revisions exist but were not retrieved.'>"
}
```

## All Remaining Fields

Every non-empty field from the raw `fields` object not already listed above, including custom fields. Use the durable ADO field reference name as the heading/key.

- `{Field.ReferenceName}`: `{value}`

## Raw Issue JSON

See `raw/issue.json` (full primary work-item payload preserved verbatim from `az boards work-item show --id {id} --expand all`).

## Raw Relation JSON

See `raw/relations.json` (relation/link payload, or failure note).

## Raw Comments JSON

See `raw/comments.json`, or inline below when under 2 KB:

```json
{full paginated output from the documented comments endpoint, or failure note}
```

## Raw Updates JSON

See `raw/updates.json`, or inline below when under 2 KB:

```json
{full paginated output from the documented updates endpoint, or failure note}
```

---

## Open Questions

[Only unresolved questions about the ticket itself — ambiguous acceptance criteria, missing context, conflicting requirements. Per the open-questions iterative-dialog principle in `templates/SHAMT_RULES.template.md`, surface each question to the user one at a time and update this ticket with each answer before moving on. Substantive design questions belong in the spec, not here.]
