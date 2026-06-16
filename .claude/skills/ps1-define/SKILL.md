---
name: ps1-define
description: >
  Run Stage 1 of the Shamt PO flow at the story altitude. Three input modes:
  (A) ingest an existing /ps0-draft stub (detect the Status: Draft marker +
  Scratch Notes section) — seed from Scratch Notes, deepen via open-questions
  dialog, strip the marker + Scratch Notes on completion (f1-style ingestion);
  (B) create a standalone story from scratch; (C) seed from a tracker
  work-item payload when the active profile supports the Story type. Mode
  disambiguation is filesystem-first: Mode A wins when the draft marker is
  present, Mode C wins next when tracker + slug shape align, Mode B is the
  default fallback. Consults .shamt-core/project-specific-files/ARCHITECTURE.md
  for architectural impact. Unlike /pe1-define and /pf1-define
  (which defer validation to /validate-artifact), /ps1-define runs an INLINE
  Pattern-1 validation loop so the command stamps the Validated footer itself
  — the readiness signal /e1-start-story keys on. Invoke when the user wants
  to define, flesh out, or polish a story planning ticket.
triggers:
  - "define a story"
  - "flesh out a ticket"
  - "polish the planning ticket"
  - "ready a story for the engineer"
  - "ingest a story draft"
---

## Overview

Mirrors the `/ps1-define {slug} [--tracker={ado|github|local}]` slash command. Same canonical body, two host wirings.

## Protocol

Follow the canonical `/ps1-define` command body verbatim — see [`commands/ps1-define.md`](../../commands/ps1-define.md). Summary:

1. **Read configuration** — `.shamt-core/shamt-config.json` → `work_item_tracker`; honor `--tracker={ado|github|local}` override. Read the corresponding profile in [`reference/trackers/`](../../../../../reference/trackers/). The override only affects Mode C (no-op in Mode A and B).
2. **Resolve `{slug}`** — resolve per `templates/SHAMT_RULES.template.md` §PO-tree resolution (tree-wide story glob) and legacy-flat fallback. Halt on multiple matches. On a one-match resolution, **inspect `ticket.md`** to decide Mode A vs. re-entry:
   - Draft marker present (`**Status:** Draft (f0 — story-idea capture, unrefined)` + `## Scratch Notes (stage-0 capture)` section) → Mode A (ingest; seed from Scratch Notes).
   - Depth sections drafted (a prior `/ps1-define` deep-dive ran) → re-entry. Confirm refetch / overwrite / extend / exit. **Preserve `**Ticket ID:**` header verbatim** regardless of branch; strip any prior `Validated …` footer when extending.
3. **For new stories** (zero matches): ask the user for a 2–4-word brief description; propose and create `epics/{epic-folder}/features/{feature-folder}/stories/{ID}-{slug}-{brief}/`. Mode B nests under the parent feature; Mode C nests under matched or parent feature per tracker + slug shape.
4. **Mode disambiguation order** (filesystem-first):
   - **Mode A** — draft marker + Scratch Notes present. Seed from Scratch Notes. Deepen via open-questions dialog. On completion, **strip the marker + Scratch Notes** (f1-style ingestion).
   - **Mode C** — no draft marker, but active profile supports Story AND slug parses to a tracker ID. Fetch the payload, apply field mapping, nest under matched epic (or default per tracker). **No `raw/` subfolder** — preserve fidelity inline in `## All Remaining Fields` appendix (above the eventual validation footer). Write `shamt-state/active-story` and `shamt-state/active-feature` pointers.
   - **Mode B** — no draft marker, tracker doesn't apply. Create from active tracker's per-provider ticket template, nest under resolved or default parent feature. Write `shamt-state/active-story` and `shamt-state/active-feature` pointers.
5. **Consult `.shamt-core/project-specific-files/ARCHITECTURE.md`** (advisory). Flag architectural impact inline when the story implies new service / boundary / data store / external integration.
6. **Open-questions iterative dialog** ([Principle 2](../../../../../templates/SHAMT_RULES.template.md#principle-2-open-questions-iterative-dialog)) — surface each question one at a time, update the ticket, drain the section. Focus on scope, spec readiness, acceptance criteria — not implementation detail (that is `/e1-start-story`'s job). **Mode A: after the dialog, strip the marker + Scratch Notes.**
7. **Inline Pattern-1 validation loop** — primary agent self-reviews `ticket.md` against Pattern-1 dimensions (per `templates/SHAMT_RULES.template.md` Pattern 1), then spawns one independent adversarial `validation-checker` sub-agent (Haiku tier) for Standard-path confirmation. **No one-LOW allowance** — any sub-agent finding resets and returns to primary. On clean + CONFIRMED, stamp the two-line footer (the `---` delimiter + `Validated {YYYY-MM-DD} — N rounds, 1 adversarial sub-agent confirmed` line). Loop mechanics and dimensions cited from sibling `validate-artifact.md` (Steps 1–8) — do not re-derive.
8. **Exit** — on successful validation (footer stamped), suggest `/e1-start-story {slug}` (stub-aware) next. The `/e1-start-story` ready-ticket pickup branch keys on the `Validated …` footer's presence.

## Mode A (draft ingestion)

When the draft marker + Scratch Notes are detected (Step 2), the command seeds from Scratch Notes (Mode A input), drives the open-questions dialog (Step 6), **strips the marker + Scratch Notes on completion** (before the inline validation loop), then validates and stamps the footer.

## Tracker fallback

When the active profile lacks Story support, surface the one-line freeform-fallback notice and fall through to Mode A (if a stub exists) or Mode B. **Do not silently fail; do not halt.** Per the freeform-fallback rule in [`reference/trackers/_contract.md`](../../../../../reference/trackers/_contract.md).

## Recommended model

Reasoning (Opus) — design/dialog task + inline validation loop; see [`reference/model_selection.md`](../../../../../reference/model_selection.md).

## Exit criteria

Non-empty `epics/{epic-folder}/features/{feature-folder}/stories/{ID}-{slug}-{brief}/ticket.md` with ticket metadata + body intake area populated (scope one-liner, draft-mode seeds, deepened by dialog) + spec structure drafted; `## Open Questions` empty; other template sections (Summary, Description, Acceptance Criteria, etc.) left as template placeholders (Engineer flow's responsibility); nesting reflects the input mode (draft's parent in Mode A, resolved or default parent in Mode B/C); `shamt-state/active-story` and `shamt-state/active-feature` pointers written (Mode B/C only); **two-line footer block stamped** (`---` + `Validated {YYYY-MM-DD} — N rounds, 1 adversarial sub-agent confirmed`); user has confirmed scope + content.

---

<!-- Managed by Shamt — do not edit. Regenerate from shamt-core/host/templates/claude/skills/ps1-define/SKILL.md. -->
