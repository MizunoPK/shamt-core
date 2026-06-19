<!-- Per-epic state rollup. Lives at epics/{ID}-{slug}-{brief}/STATUS.md. GENERATED — do not hand-edit; run /po-status {epic-slug} to refresh. A derived VIEW of the artifacts' own on-disk state signals (NOT an authoritative source). See reference/epic_status_board.md for the derivation contract. -->
# STATUS: {epic-slug}

**Generated:** {YYYY-MM-DD} by /po-status — **do not hand-edit.** This is a derived rollup, re-computed from each artifact's on-disk state. Re-run `/po-status {epic-slug}` to refresh; never patch a single cell.

**States:** New (defined, no `Validated` footer) · Validated (footer present) · Building (Engineer-flow artifacts present, not finalized) · Released (`**Status: Done**`).

| Feature / Story | State |
|-----------------|-------|
| `{feature-slug}` | {New \| Validated \| Building \| Released} |
| &nbsp;&nbsp;↳ `{story-slug}` | {New \| Validated \| Building \| Released} |

<!-- One row per feature (rolled up from its child stories per reference/epic_status_board.md), each followed by its nested child-story rows. Whole table re-derived on every refresh. -->
