# Proposal: sync-proposals-assume-local-master

**Created:** 2026-06-19
**Status:** Draft (f0 — audit capture, unrefined)
**Proposed by:** FantasyFootballHelperScripts
**Project context:** `/sync-proposals` dumped full proposal contents into chat for manual copy-paste, which is wasted effort when master is a local path on the same machine (it always is here — `master_url` = `/home/kai/code/shamt-core`).

> **f0 DRAFT — unrefined capture.** Quick-captured by the framework audit
> or a user; not yet through the open-questions dialog. Run
> `/f1-propose-update sync-proposals-assume-local-master` to flesh it out.

---

## Problem

[Deferred to /f1-propose-update — see Scratch Notes below.]

## Scratch Notes (f0 capture)

**The ask.** `/sync-proposals` (and the per-proposal `/sync-submit-proposal`) should **always assume master is a local path**. There will always be a local checkout of master on the same machine that we are copying proposals into, and we can assume the user will commit/push from there themselves. So the command should **write each proposal directly into master's `proposals/incoming/{project}-{slug}.md`** instead of printing the full proposal content into chat as a copy-paste block for the user to paste by hand.

**Why this matters (the incident).** Running `/sync-proposals` today, the command body (`host/templates/claude/commands/sync-proposals.md` Step 3) prints the entire contents of every active proposal into chat inside fenced blocks, prefixed with the master target path, expecting the user to manually paste each into the master repo. With three active proposals that was a large, useless wall of text — the user called it a waste of time. The master URL is a **local filesystem path** (`master_url` in `.shamt-core/shamt-config.json` = `/home/kai/code/shamt-core`), so the agent could just `cp` / write each file directly into `/home/kai/code/shamt-core/proposals/incoming/` with zero copy-paste.

**The design tension to resolve in f1.** The current "manual copy-paste" design is **deliberate** — see `sync-proposals.md` Notes ("Manual copy is the design. No automation that pushes to master — that would re-introduce upstream tooling (PR creation, GitHub auth) that v2 explicitly omitted") and `import-shamt.sh` / `sync-import-shamt.md`, which DO already special-case a local-path `master_url` (clone for git URLs, use directly for absolute local paths). So the import direction already distinguishes local vs. remote master; the submit direction does not. The ask is to bring submit into line: **when `master_url` is a local path (or always, per the blurb's "always assume local"), write directly into master's `proposals/incoming/` rather than dumping to chat.** This is NOT the same as "push to master / open a PR" — it is a local file copy the user then reviews/commits/pushes themselves, so it does not reintroduce the upstream tooling v2 omitted. f1 should decide:
  - Always-local vs. detect-and-branch: does the command *always* assume a local master (per the blurb), or read `master_url` and only write-direct when it's a local path, falling back to copy-paste for a git URL? The blurb says "always assume" — but a git-URL master_url would have nowhere local to write. Probably: write-direct when `master_url` resolves to an existing local dir; keep the copy-paste block as a fallback when it doesn't.
  - Confirmation/overwrite behavior: writing into `proposals/incoming/{project}-{slug}.md` on master — overwrite if it exists? Prompt? The incoming file is master's intake, so overwriting a same-named prior submission is probably fine, but confirm.
  - Whether to drop the chat dump entirely or keep a short summary (path written + slug) instead of the full content.

**Implicated canonical files (informal — f1 to confirm the real change set):**
  - `host/templates/claude/commands/sync-proposals.md` — Step 3 (currently "print copy-paste block") and the Notes ("Manual copy is the design"); reconcile with the local-master direct-write behavior.
  - `host/templates/claude/commands/sync-submit-proposal.md` — the per-proposal sibling (preserved local-only here), same copy-paste design; keep both in sync if it stays.
  - `host/templates/claude/skills/sync-proposals/SKILL.md` (+ `sync-submit-proposal/SKILL.md`) — exit-criteria / overview pointers if behavior changes (Protocol pointer only, no paraphrase).
  - possibly `reference/` sync docs and `shamt-config.example.json` if the local-vs-remote `master_url` distinction needs documenting on the submit side the way it is on the import side.

---

## Proposed Changes

| # | Canonical path | Operation | One-line change description |
|---|----------------|-----------|------------------------------|
| 1 | `shamt-core/host/templates/claude/commands/sync-proposals.md` | EDIT | [Deferred to /f1-propose-update] |

---

## Risks

[Deferred to /f1-propose-update.]

---

## Rollback Plan

[Deferred to /f1-propose-update.]

---

## Validation Considerations

[Deferred to /f1-propose-update.]

---

## Open Questions

- [ ] [Deferred to /f1-propose-update — no open-questions dialog runs at f0.]

---

## Resolved Questions

[None yet.]
