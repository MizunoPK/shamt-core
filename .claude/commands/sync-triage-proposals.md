---
description: Master-side. Walk proposals/incoming/ and decide promote / reject / defer for each child-submitted proposal. Promote strips the {project}- filename prefix and moves to proposals/{slug}.md; reject moves to proposals/rejected/ with a top-of-file note; defer moves to proposals/deferred/.
---

# /sync-triage-proposals

**Purpose:** Run the master-side triage step of the v2 master/child sync (Part 4). Walk `proposals/incoming/{project}-{slug}.md` files in alphabetical order, present each to the user, and route per their decision: **promote** (move to `proposals/{NN}-{slug}.md` and hand off to the framework-update flow starting at Phase 2), **reject** (move to `proposals/rejected/{slug}.md` with a top-of-file note), or **defer** (move to `proposals/deferred/{slug}.md`).

Per phase-per-command resumability (Principle 1), triage does not invoke `/validate-artifact` itself — it places the file at the canonical location and suggests the next command. The rest of the framework-update flow (Phase 8) runs as separate commands.

**Recommended model:** Balanced (Sonnet). Reading each proposal, summarizing for the user, and routing one of three actions is light judgment work. The validation, planning, implementation, and audit phases that follow are separate commands with their own model recommendations. See [`reference/model_selection.md`](../../../../reference/model_selection.md).

---

## Usage

```
/sync-triage-proposals
```

## Arguments

- **Slugless.** Triage walks every file under `proposals/incoming/` in alphabetical order.

## Prerequisites

- This command runs **on the master side**. Master vs. child is decided by `proposals/incoming/` presence at the cwd: master has it; child projects never do.
- `proposals/incoming/` exists. If absent, halt with: *"proposals/incoming/ does not exist — this looks like a child project. Use `/sync-submit-proposal {slug}` to send proposals upstream instead."*
- `proposals/incoming/` contains at least one `.md` file (excluding files whose basename starts with `_` or `.`). If empty, report and exit cleanly: *"proposals/incoming/ is empty — nothing to triage."*

## Step-by-step

### Step 1 — Enumerate incoming proposals

1. List `proposals/incoming/*.md` in alphabetical order, excluding any file whose basename starts with `_` or `.`.
2. Report the count to the user: *"N proposals to triage. Walking in alphabetical order."*

### Step 2 — Per-proposal loop

For each incoming file in order, run Steps 2a through 2d.

#### Step 2a — Read and surface the proposal

1. Read the file top-to-bottom.
2. Display in chat:
   - Filename: `proposals/incoming/{filename}`
   - `Proposed by:` and `Project context:` headers (from the proposal body).
   - `Status:` header.
   - The full **Problem** section (verbatim).
   - The **Proposed Changes** table (verbatim).
   - The first 3 entries of **Risks** (full text).
   - Whether a Phase 2 validation footer is present.

   This is enough for the user to decide; do not summarize or rephrase. Verbatim surfaces preserve the author's intent.

#### Step 2b — Compute the canonical slug

1. Extract the `Proposed by:` value from the proposal body. Strip surrounding whitespace.
2. Compute `bare_basename = ${basename%.md}` (filename without the `.md` extension).
3. Verify that `bare_basename` starts with `${Proposed by}-` — i.e., the filename's prefix matches the project name the child declared in the header (per `/sync-submit-proposal`'s `{project_name}-{slug}.md` naming rule).
4. **Slug = `${bare_basename#${Proposed by}-}`** — strip the validated prefix; the remainder is the canonical slug.
5. **Malformed cases** (any of the following) — surface a HIGH-priority warning to the user and ask via `AskUserQuestion` whether to **reject** (treat as malformed), **defer** (await child re-submission), or **promote with a user-supplied slug**:
   - `Proposed by:` is blank or absent.
   - `bare_basename` does not start with `${Proposed by}-` (filename prefix and header disagree — the proposal was either mis-submitted, hand-renamed, or copy-pasted from another project).
   - The computed slug is empty (basename equals `${Proposed by}-` with nothing after).
   - The computed slug does not match `^[a-z0-9][a-z0-9._-]*$` (non-kebab-case identifier; e.g., contains uppercase, leading punctuation, or whitespace). Promoting under a non-conformant slug would put `proposals/{slug}.md` outside the project-wide kebab-case slug convention every other `/{command} {slug}` flow relies on.
6. **If the user picks "promote with a user-supplied slug"**, ask a second `AskUserQuestion` requesting the slug to use (e.g., *"What slug should this proposal be promoted under? (kebab-case)"*). Validate the answer against `^[a-z0-9][a-z0-9._-]*$`; re-ask on invalid input. The validated answer becomes the slug used by Step 2d's promote action. (The slug regex is intentionally stricter than `init-shamt.sh`'s `project_name` regex `^[A-Za-z0-9._-]+$` — `project_name` is a project identifier that may be mixed-case; a slug is a kebab-case filesystem identifier consumed by every `/{command} {slug}` flow, where lowercase + leading-alphanum is the project-wide convention.)
7. State the resolved slug in chat in one line: `Canonical slug → proposals/{slug}.md`.
8. **Slug to use in Step 2d** (per malformed disposition):
   - **Promote with a user-supplied slug** → use the slug captured in sub-step 6.
   - **Reject** or **defer** → use `bare_basename` (the filename minus `.md`) directly as the destination slug. Preserving the original basename keeps the rejected/deferred record traceable back to the incoming filename even when the canonical slug couldn't be derived. The destination becomes `proposals/rejected/{bare_basename}.md` or `proposals/deferred/{bare_basename}.md` respectively.
9. **Control flow on malformed cases.** The disposition picked in sub-step 5 (reject / defer / promote-with-supplied-slug) IS the final disposition for this file — **skip Step 2c entirely** and jump straight to Step 2d with that disposition and the sub-step 8 slug. Step 2c only runs on well-formed proposals where slug derivation succeeded normally.

#### Step 2c — Ask the disposition

Surface to the user via `AskUserQuestion`:

> **Decision for `{filename}`?** promote / reject / defer / skip

Options:

- **Promote** — accept the proposal; it will be moved to `proposals/{NN}-{slug}.md` and the framework-update flow will resume at Phase 2 (validate-artifact).
- **Reject** — close the proposal with a brief note explaining why. It will be moved to `proposals/rejected/{slug}.md` with the note prepended.
- **Defer** — hold the proposal without rejecting. It will be moved to `proposals/deferred/{slug}.md`.
- **Skip** — leave it in `proposals/incoming/` and continue to the next.

#### Step 2d — Apply the disposition

**Promote:**

1. Ensure `proposals/` exists at the project root (it should, on master).
2. **Assign the master-side number.** Scan every folder a numbered proposal can come to rest in — `proposals/`, `proposals/archive/`, `proposals/deferred/`, `proposals/rejected/` (**not** `proposals/incoming/`, which still holds unnumbered child submissions). Parse the leading `^[0-9]+-` digit run on each filename; the number is `max(parsed NN) + 1`, or `01` when none is numbered. Format two-digit zero-padded (widening to three digits past `99`). **Re-read from disk per promote** — never cache `max(NN)` across promotes, or two proposals promoted in the same run would collide. This is the same algorithm `/f1-propose-update` uses for master-local proposals (one shared master namespace).
3. Halt if `proposals/{slug}.md` or `proposals/*-{slug}.md` already exists — slug collision, the user must resolve manually (rename one or re-author).
4. `git mv proposals/incoming/{filename} proposals/{NN}-{slug}.md` (or plain `mv` if untracked) — apply the `{NN}-` prefix. Also write the `**Number:** {NN}` header into the promoted proposal.
5. Confirm the validation footer (if present) is intact post-move.
6. **No branch.** Branch creation is deferred to `/f3-implement-update` for all proposals (master-local and promoted alike), so triage stays a pure router — it assigns the number and moves the file, nothing more.
7. Note in chat the next command to run: `/validate-artifact proposals/{NN}-{slug}.md`. Do not invoke it from this command — phase-per-command resumability (Principle 1) keeps every phase independently runnable by a fresh agent.

**Reject:**

1. Ask the user via `AskUserQuestion` for a brief one-line rejection note (the **why**).
2. Ensure `proposals/rejected/` exists.
3. Halt if `proposals/rejected/{slug}.md` already exists.
4. Prepend a top-of-file note to the proposal content:

   ```markdown
   <!-- REJECTED YYYY-MM-DD by master triage: {note} -->

   ```

   Then write the original proposal content beneath.
5. `git mv` (or `mv`) `proposals/incoming/{filename}` → `proposals/rejected/{slug}.md`, then apply the prepended note. (If `git mv` was used, the prepend is a follow-up edit; commit-time the rename + edit collapse into a single change set.)
6. Note in chat that the rejection is recorded.

**Defer:**

1. Ensure `proposals/deferred/` exists.
2. Halt if `proposals/deferred/{slug}.md` already exists.
3. `git mv` (or `mv`) `proposals/incoming/{filename}` → `proposals/deferred/{slug}.md`.
4. Note in chat that the proposal is deferred. No note required (defer is "not now", not "no").

**Skip:**

1. Take no action. Continue to the next file in Step 2.

### Step 3 — Summary

After the loop, print:

```text
Triage summary:
  promoted: N  (next: /validate-artifact for each)
  rejected: N
  deferred: N
  skipped:  N  (still in proposals/incoming/)
```

Then suggest how to validate the promoted proposals:

- **Exactly one promoted** — list the single next command:

  ```text
  Next:
    /clear
    /validate-artifact proposals/{NN}-{slug}.md
  ```

- **Two or more promoted** — this is a batch. Emit a **batch-validation handoff prompt** as the **recommended** path — fill the template in [`reference/batch_validation_handoff.md`](../../../../reference/batch_validation_handoff.md) with the actual promoted `proposals/{NN}-{slug}.md` paths (each with its governing references), and print it for the user to paste into a fresh session. Also print the **sequential per-slug fallback**:

  ```text
  Next (fallback — drive each step yourself):
    /clear
    /validate-artifact proposals/{NN}-{slug-1}.md
    /clear
    /validate-artifact proposals/{NN}-{slug-2}.md
    ...
  ```

Both paths run the same Pattern 1 loop per proposal — there is no rigor difference. Order matters only insofar as each phase is independently runnable; the user can run them in any order, sequentially or in parallel sessions per the slug-resumability rule.

## Exit criteria

- Every file in `proposals/incoming/` has been either dispositioned (promoted / rejected / deferred) or explicitly skipped.
- The triage summary has been printed.
- For each promoted slug, the next command (`/validate-artifact proposals/{NN}-{slug}.md`) has been stated.

## Notes

- **No bulk-disposition.** Each proposal gets its own decision via `AskUserQuestion`. Bulk auto-decisions risk silent acceptances of proposals the user would have rejected on a closer read.
- **No automatic validation invocation.** Promote moves the file and stops. The user runs `/validate-artifact` next — possibly after `/clear` to start fresh. This matches every other master-side phase in the framework-update flow (Phase 8) and keeps each phase independently runnable.
- **Provenance preserved.** The promoted proposal still carries its `Proposed by:` and `Project context:` headers. The `Proposed by:` header drives the promote-time filename-prefix strip (the `{project}-` prefix is derived from it).
- **Rejection notes are for the master's record.** Children are informed out-of-band (chat, email, etc.). v2 does not include a notification mechanism — `/sync-submit-proposal` warned the user that rejections require manual cleanup of `proposals/submitted/{slug}.md` on the child side.
- **Order of files.** Alphabetical order is deterministic and lets a fresh agent resume the loop predictably across sessions if the user skipped some. There is no priority field on incoming proposals; chronological prioritization happens by hand.
- **Fresh-agent runnable.** `proposals/incoming/` contents are sufficient. No conversation history required.

---
Validated 2026-05-28 — 8 rounds (4 primary + 4 adversarial), final adversarial sub-agent confirmed (Phase 9 implementation re-validation). Fixes since prior round: derived slug now treated as a malformed case when it fails `^[a-z0-9][a-z0-9._-]*$`; inline note added clarifying the intentional regex difference vs. `init-shamt.sh`'s `project_name` validator.

<!-- Managed by Shamt — do not edit. Regenerate from shamt-core/host/templates/claude/commands/sync-triage-proposals.md. -->
