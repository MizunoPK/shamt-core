# Proposal: import-flow-self-overwrite-crash

**Created:** 2026-06-19
**Status:** Draft (f0 — audit capture, unrefined)
**Proposed by:** FantasyFootballHelperScripts
**Project context:** Hit during a routine `/sync-import-shamt` pull from a local-path master.

> **f0 DRAFT — unrefined capture.** Quick-captured by the framework audit
> or a user; not yet through the open-questions dialog. Run
> `/f1-propose-update import-flow-self-overwrite-crash` to flesh it out.

---

## Problem

[Deferred to /f1-propose-update — see Scratch Notes below.]

## Scratch Notes (f0 capture)

**Incident.** During a `/sync-import-shamt` run on this child (FantasyFootballHelperScripts, local-path master at `/home/kai/code/shamt-core`), the **first** invocation of `.shamt-core/import-shamt.sh` crashed partway through with:

```
Syncing canonical sources …
  updated  README.md
  updated  init-shamt.sh
  updated  import-shamt.sh
.shamt-core/import-shamt.sh: line 278: k: command not found   (exit 127)
```

**Root cause (suspected).** `import-shamt.sh` is **in its own sync set**, so the running script overwrote itself on disk mid-run (the `updated  import-shamt.sh` line above). bash does not load a script fully into memory — it seeks the script file by **byte offset** as it executes. When the on-disk file's content/length changed underneath the running process, bash resumed reading at a now-stale offset and landed mid-token in the new content, producing `line 278: k: command not found`. (The error line number / token are artifacts of the offset mismatch, not a real bug at line 278 of either version.)

This directly contradicts the **`sync-import-shamt.md` Notes → "Self-updating"** claim, which asserts: *"A new version overwrites the on-disk copy mid-run. The running script is already in memory and continues with the previous logic; the new version takes effect on the next invocation."* That premise is false for bash when the replacement file differs in length — the run can corrupt and abort.

**Recovery that worked (and why it's safe).** The crashed first run had *already written* the new `import-shamt.sh` to disk before dying. Simply **re-running** `bash .shamt-core/import-shamt.sh` completed cleanly (exit 0, 14 new / 30 updated / 81 unchanged / 8 preserved): on the second run the script overwrites itself with **byte-identical** content (no length change → byte offsets stay valid → no corruption), and the script is idempotent (diffs each file, only rewrites changed ones). So the failure is **transient and self-healing on retry** — but a naive user seeing exit 127 mid-sync might reasonably think the framework is broken or the tree is half-synced.

**What we should fix in the import flow (ideas for f1 to develop).**

- **Re-exec / copy-then-run pattern.** Have `import-shamt.sh` copy itself to a temp location and re-exec from there *before* doing any sync work, so the running process is never the file being overwritten (classic self-updating-installer technique). Or split into a tiny stable bootstrap that never changes + a `_impl.sh` that does the work.
- **Sync `import-shamt.sh` (and `init-shamt.sh`) LAST**, after all other sync-set files, to shrink the window — weaker mitigation; doesn't fully close the hole since the script is still mid-execution when it rewrites itself.
- **Ensure bash reads the whole script first** — wrap the entire script body in a `main() { … }; main "$@"` function with the final line being the call, so bash parses the full file before executing the body. This is the cleanest fix: a fully-parsed function body is immune to later on-disk changes regardless of length. Worth verifying this actually holds across the bash versions in play.
- **Fix the false "Self-updating" Note** in `host/templates/claude/commands/sync-import-shamt.md` (and its SKILL mirror if it repeats the claim) to describe the real behavior + whatever mitigation lands.
- **Optional UX:** on a non-zero exit from the script wrapper, the `/sync-import-shamt` command body could advise "re-run once" rather than treating any failure as fatal — but the durable fix belongs in the script, not the command guidance.

Implicated canonical files (informal — f1 to confirm): `shamt-core/import-shamt.sh`, `shamt-core/init-shamt.sh` (same self-overwrite shape, since it too is in the sync set / re-run on install), `shamt-core/host/templates/claude/commands/sync-import-shamt.md` (the false "Self-updating" Note), and possibly `shamt-core/host/templates/claude/skills/sync-import-shamt/SKILL.md`.

---

## Proposed Changes

| # | Canonical path | Operation | One-line change description |
|---|----------------|-----------|------------------------------|
| 1 | `shamt-core/...` | EDIT | [Deferred to /f1-propose-update] |

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
