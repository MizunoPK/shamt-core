---
description: Stage 2 of the PO flow at the Epic altitude — run the /validate-artifact Pattern-1 loop on the epic's epic.md and stamp the Validated footer (single mode only; epic is the top altitude, no parent to batch from), then refresh the epic STATUS.md
---

# /pe2-validate

**Purpose:** Run Stage 2 of the PO flow at the **Epic** altitude — the dedicated *validate* stage between define (`/pe1-define`) and decompose (`/pe3-decompose`). Resolve the epic slug, run the **`/validate-artifact` Pattern-1 loop** on the epic's `epic.md` (stamping the `Validated …` footer exactly as `/validate-artifact` does), then refresh the epic's `STATUS.md`. Epic is the top altitude — there is **no parent to batch from**, so `/pe2-validate` is **single mode only** (no parent-slug batch section).

**Recommended model:** Reasoning (Opus) — the Pattern-1 validation loop escalates to Reasoning per the `/validate-artifact` guidance. See [`reference/model_selection.md`](../../../../reference/model_selection.md).

---

## Usage

```
/pe2-validate {slug}
```

## Arguments

- `{slug}` (required) — epic slug or ticket ID (`T{N}`). Resolved against `epics/` per [`templates/SHAMT_RULES.template.md`](../../../../templates/SHAMT_RULES.template.md) §PO-tree resolution (`epics/{ID}-*/` · `epics/{slug}-*/` · `epics/*-{slug}-*/`; matches at most one, halt on multiple; `epics/archive/` excluded).

## Prerequisites

- `epics/{slug}-*/epic.md` must exist. If not, halt and direct the user to `/pe1-define {slug}` first.
- `epic.md`'s `## Open Questions` section should be drained (the define stage leaves it empty). If open questions remain, the validation loop will fail them — surface that rather than footering.

## Step-by-step

### Step 1 — Resolve the slug to an epic folder

Resolve `{slug}` to its epic folder per §PO-tree resolution (the same resolution `/pe3-decompose` Step 1 uses). Halt on zero (direct to `/pe1-define {slug}`) or multiple matches.

### Step 2 — Run the `/validate-artifact` Pattern-1 loop on `epic.md`

Run the **same Pattern-1 validation loop `/validate-artifact` runs** against `epics/{epic-folder}/epic.md`. **Cite the sibling command [`validate-artifact.md`](validate-artifact.md) (Steps 1–8) as the source of truth** for the loop mechanics — do **not** re-derive or re-enumerate the Pattern-1 dimensions here. Epic-validate runs the uniform validation exit (primary clean round + one adversarial `validation-checker` Haiku sub-agent confirmation; no one-LOW allowance). On a clean exit, the loop stamps the two-line footer block on `epic.md` exactly as `/validate-artifact` Step 8 does:

```text
---
Validated {YYYY-MM-DD} — N rounds, 1 adversarial sub-agent confirmed
```

### Step 3 — Refresh the epic STATUS.md

After the footer is stamped, **re-derive the epic's `STATUS.md` from disk** per [`commands/po-status.md`](po-status.md) (resolve the epic from the folder path) — the epic's rollup now reflects its `Validated` state. Re-derive the **whole table** (never patch a cell); the rollup is a derived VIEW per [`reference/epic_status_board.md`](../../../../reference/epic_status_board.md).

### Step 4 — Exit

```text
Epic {slug} is validated.
Next: /pe3-decompose {slug} to break it into features.
```

## Exit criteria

- `epics/{epic-folder}/epic.md` carries a `Validated …` footer stamped by this run's Pattern-1 loop.
- The epic's `STATUS.md` has been re-derived.
- The next command (`/pe3-decompose {slug}`) has been suggested in chat.

## Notes

- **Thin wrapper over `/validate-artifact`.** This command adds nothing to the Pattern-1 loop itself — it resolves the epic's `epic.md`, runs `/validate-artifact`'s loop on it, and refreshes `STATUS.md`. The loop mechanics and dimensions are owned by `/validate-artifact`; this command cites them by reference and never re-implements them.
- **Single mode only — no parent-slug batch.** Epic is the top altitude; there is no parent above it to fan out from. `/pf2-validate` and `/ps2-validate` (which *do* have a parent altitude) carry parent-slug batch modes; `/pe2-validate` does not.
- **Validate is its own stage at every altitude.** Define stages (`/pe1-define`) no longer stamp a footer; validation is the dedicated stage 2 (`define → validate → decompose`). This is the uniformity the validate stage establishes.
- **Fresh-agent runnable.** The epic folder + `epic.md` live on disk; no conversation history required.

---

<!-- Managed by Shamt — do not edit. Regenerate from shamt-core/host/templates/claude/commands/pe2-validate.md. -->
