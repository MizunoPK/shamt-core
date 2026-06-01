---
name: sync-submit-proposal
description: >
  Child-side step of the v2 master/child sync. Prepare a validated, child-local
  proposal at .shamt-core/proposals/{slug}.md for upstream submission to master. Reads
  project_name from .shamt-core/shamt-config.json, confirms the proposal carries a Phase 2
  validation footer and child-attribution headers (Proposed by, Project
  context), prints the proposal content with the master-side target path
  (proposals/incoming/{project}-{slug}.md) for manual copy-paste, and moves the
  local copy to .shamt-core/proposals/submitted/{slug}.md to mark "awaiting decision". Does
  NOT push to master, open PRs, or file issues — the submission is manual copy
  per INFRASTRUCTURE.md §4.3 Option B. Invoke when the user wants to send a
  proposal upstream, ship a proposal to master, submit a framework change, or
  push a proposal up.
triggers:
  - "submit the proposal"
  - "submit .shamt-core/proposals/{slug}.md"
  - "send the proposal upstream"
  - "ship this proposal to master"
  - "push this framework change up"
  - "submit a framework update"
---

## Overview

Mirrors the `/sync-submit-proposal {slug}` slash command. Same canonical body, two host wirings.

## Protocol

Follow the canonical `/sync-submit-proposal` command body verbatim — see [`commands/sync-submit-proposal.md`](../../commands/sync-submit-proposal.md). Summary:

1. **Master-side check** — detect master vs. child by `proposals/incoming/` presence at the cwd (master has it per §4.4 / §4.8; child never does). If master, halt and direct the user to the framework-update flow (`/f1-propose-update` → `/validate-artifact` → … → `/f6-archive-proposal`) instead. Submit is for the child side only.
2. **Read `.shamt-core/shamt-config.json`** — extract `project_name`. Halt if missing/empty. Validate it matches `^[A-Za-z0-9._-]+$`.
3. **Read and confirm the proposal** — `.shamt-core/proposals/{slug}.md` exists with a Phase 2 validation footer. The header carries non-empty `Proposed by:` and `Project context:` (ask the user via `AskUserQuestion` if either is blank).
4. **Compute target path** — `proposals/incoming/{project_name}-{slug}.md` on master. State it in chat.
5. **Output copy-paste content** — print the proposal inside a fenced block with the master-side target path so the user can copy verbatim.
6. **Move the local copy** — `.shamt-core/proposals/{slug}.md` → `.shamt-core/proposals/submitted/{slug}.md` (`git mv` when tracked). Confirm footer intact post-move. Halt if `.shamt-core/proposals/submitted/{slug}.md` already exists.
7. **Exit** — restate the target path and where the local copy now lives. Next action is manual + master-side; no next command on the child.

## Recommended model

Cheap (Haiku) — read a file, check a footer, print, move. Mechanical. See [`reference/model_selection.md`](../../../../../reference/model_selection.md).

## Exit criteria

- `.shamt-core/proposals/submitted/{slug}.md` exists with the validation footer intact.
- A fenced copy-paste block has been printed to chat with the master-side target path stated above it.
- `.shamt-core/proposals/{slug}.md` no longer exists at the original location.

## Re-submission

If master rejected a prior submission and the user wants to revise: manually move `.shamt-core/proposals/submitted/{slug}.md` back to `.shamt-core/proposals/{slug}.md`, edit, re-validate via `/validate-artifact`, then re-run `/sync-submit-proposal {slug}`.

## Already-merged follow-up

After master triages the submitted proposal and (if promoted) implements / archives it, the next `/sync-import-shamt` run on the child auto-moves `.shamt-core/proposals/submitted/{slug}.md` → `.shamt-core/proposals/already-merged/{slug}.md` when it detects the matching `proposals/archive/{slug}.md` on master. No manual cleanup needed for the promoted-and-merged path.

---
Validated 2026-05-28 — 8 rounds (4 primary + 4 adversarial), final adversarial sub-agent confirmed (Phase 9 implementation re-validation). No changes to this file in this round.

<!-- Managed by Shamt — do not edit. Regenerate from shamt-core/host/templates/claude/skills/sync-submit-proposal/SKILL.md. -->
