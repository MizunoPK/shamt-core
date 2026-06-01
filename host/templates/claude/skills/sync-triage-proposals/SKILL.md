---
name: sync-triage-proposals
description: >
  Master-side step of the v2 master/child sync. Walk proposals/incoming/ in
  alphabetical order and decide promote / reject / defer / skip for each
  child-submitted proposal. Promote strips the {project}- filename prefix
  (derived from the proposal's Proposed by header) and moves the file to
  proposals/{slug}.md, then suggests /validate-artifact as the next command —
  it does NOT invoke validation itself (phase-per-command resumability per
  Principle 1). Reject moves to proposals/rejected/{slug}.md with a top-of-file
  note explaining why. Defer moves to proposals/deferred/{slug}.md. Skip leaves
  the file in incoming/ for a later pass. Invoke when the user wants to triage
  incoming proposals, walk the incoming queue, promote a child proposal,
  reject / defer a child submission, or process upstream-submitted proposals.
triggers:
  - "triage incoming proposals"
  - "walk proposals/incoming"
  - "process child-submitted proposals"
  - "promote / reject / defer this proposal"
  - "review the incoming proposal queue"
  - "decide on the incoming proposals"
---

## Overview

Mirrors the `/sync-triage-proposals` slash command. Same canonical body, two host wirings.

## Protocol

Follow the canonical `/sync-triage-proposals` command body verbatim — see [`commands/sync-triage-proposals.md`](../../commands/sync-triage-proposals.md). Summary:

1. **Master-side check** — confirm `proposals/incoming/` exists at the cwd. (That folder is master's per §4.4 / §4.8; child projects never have it. Both sides have `shamt-core/`, so its presence is not a master indicator.) Halt and direct to `/sync-submit-proposal` if invoked on a child. (The seven master-side framework-update phases that follow promote are: `/f1-propose-update` ▸ `/validate-artifact` ▸ optional `/f2-plan-update-implementation` ▸ `/f3-implement-update` ▸ `/f4-regen-framework` ▸ `/f5-audit-framework` ▸ `/f6-archive-proposal`.)
2. **Enumerate** — list `proposals/incoming/*.md` in alphabetical order; report count.
3. **Per file** —
   - **Surface verbatim**: `Proposed by`, `Project context`, `Status`, the full Problem section, the full Proposed Changes table, the first 3 Risks, footer presence.
   - **Compute slug**: extract `Proposed by:` from the body, verify `${basename%.md}` begins with `${Proposed by}-`, then strip that prefix; the remainder is the slug. Malformed cases (blank `Proposed by`, filename prefix doesn't match `Proposed by`, the stripped result is empty, OR the derived slug does not match `^[a-z0-9][a-z0-9._-]*$`) → surface options (reject / defer / promote-with-user-supplied-slug). Slug used in Step 2d depends on the chosen disposition: **promote-with-user-supplied-slug** → follow up with a second `AskUserQuestion` to capture the slug (validate `^[a-z0-9][a-z0-9._-]*$` — intentionally stricter than `init-shamt.sh`'s `project_name` regex `^[A-Za-z0-9._-]+$`; project names may be mixed-case identifiers, slugs are lowercase-kebab filesystem identifiers); **reject** or **defer** → fall back to `${basename%.md}` so the original filename is preserved in `proposals/rejected/{bare_basename}.md` or `proposals/deferred/{bare_basename}.md` for traceability. Malformed-case disposition is final: skip the well-formed disposition question and apply it directly in Step 2d.
   - **Ask disposition** via `AskUserQuestion`: promote / reject / defer / skip.
   - **Apply**:
     - Promote → `git mv` (or `mv`) to `proposals/{slug}.md`. Halt on slug collision. State next command: `/clear` then `/validate-artifact proposals/{slug}.md`.
     - Reject → ask for a one-line rejection note; `mv` to `proposals/rejected/{slug}.md` and prepend `<!-- REJECTED YYYY-MM-DD by master triage: {note} -->`. Halt if destination exists.
     - Defer → `mv` to `proposals/deferred/{slug}.md`. Halt if destination exists.
     - Skip → leave in `incoming/`, continue.
4. **Summary** — counts and next-command suggestion. One proposal promoted: the single `/clear` + `/validate-artifact proposals/{slug}.md`. Two or more promoted (a batch): emit a **batch-validation handoff prompt** (recommended) filled with the promoted `proposals/{slug}.md` paths per [`reference/batch_validation_handoff.md`](../../../../../reference/batch_validation_handoff.md), plus the sequential per-slug `/clear` + `/validate-artifact` list as the fallback. Same Pattern 1 rigor per proposal either way.

## Recommended model

Balanced (Sonnet) — reading, surfacing, routing with light judgment per file. See [`reference/model_selection.md`](../../../../../reference/model_selection.md).

## Exit criteria

Every file in `proposals/incoming/` has been dispositioned or explicitly skipped. The triage summary has been printed. Promoted slugs have their next command stated.

## Why no auto-validation

Promote moves the file and stops. `/validate-artifact` is a separate phase, runnable by a fresh agent off `proposals/{slug}.md` alone. This matches every other master-side phase in Phase 8 and keeps the slug-resumability contract intact (Principle 1).

---
Validated 2026-05-28 — 8 rounds (4 primary + 4 adversarial), final adversarial sub-agent confirmed (Phase 9 implementation re-validation). Mirrors the command-side fixes: derived-slug kebab-case check + inline regex-difference note.

<!-- Managed by Shamt — do not edit. Regenerate from shamt-core/host/templates/claude/skills/sync-triage-proposals/SKILL.md. -->
