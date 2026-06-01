# Implementation Plan — Phase 1: Scripts

**Parent plan:** [`dot-shamt-core-layout_PLAN.md`](dot-shamt-core-layout_PLAN.md)
**Proposal:** proposals/dot-shamt-core-layout.md
**Surface:** `init-shamt.sh` (A1 + G1), `import-shamt.sh` (A2), `scripts/regenerate-framework.sh` (A3 — verify-only), `host/templates/claude/statusline.sh` (C3 + D3).

These are logic edits, not pure sweeps. Execute in step order. If any locate string does not match verbatim, **halt** and return to the architect — do not improvise script logic.

## Files manifest

| # | Path | Operation | Notes |
|---|------|-----------|-------|
| 1 | `init-shamt.sh` | EDIT | Precheck reorder; SELF_HOST-gated config write + doc seed relocation; drop redundant root seeds; regen-script branch; completion prompt (G1); comments/usage |
| 2 | `import-shamt.sh` | EDIT | `.shamt-core/` install dir; config path; drop root `_template.md` mirror; already-merged scan under `.shamt-core/proposals/`; preserve-warning label; comments/usage |
| 3 | `scripts/regenerate-framework.sh` | NO-OP (verify) | Name-agnostic; canonical root from script-dir; `.claude/` stays at `<target>/.claude/` |
| 4 | `host/templates/claude/statusline.sh` | EDIT | cwd-relative config read → `.shamt-core/shamt-config.json` (D3); confirm no other child-side `shamt-core/` literal (C3) |

---

## Step 1 — `init-shamt.sh`: move the "already installed" precheck after self-host detection

**Operation:** EDIT
**File:** `init-shamt.sh`

The precheck currently runs *before* self-host detection and tests a fixed root path. The correct config path is now self-host-dependent (root for self-host, `.shamt-core/` otherwise), so the precheck must move below detection. Two edits.

**1a — gut the early precheck (lines ~127–135).**
Locate:
```
# ---- Pre-install checks -----------------------------------------------------

if [ -f "$TARGET_DIR/shamt-config.json" ]; then
  err "Shamt is already installed at: $TARGET_DIR/"
  err "  shamt-config.json exists — refusing to overwrite."
  err "To pull updates, run:"
  err "  bash $TARGET_DIR/shamt-core/import-shamt.sh"
  exit 1
fi
```
Replace:
```
# ---- Pre-install checks -----------------------------------------------------
# The "already installed" config precheck runs AFTER self-host detection below:
# the config path is self-host-dependent (root for self-host, .shamt-core/
# otherwise), so it cannot be tested until SELF_HOST is known.
```

**1b — append the relocated precheck to the self-host detection block (lines ~150–153).**
Locate:
```
if [ "$SELF_HOST" -eq 1 ]; then
  log "Self-host detected: target is the master repo itself."
  log "  shamt-core/ already present — skipping framework-source copy."
fi
```
Replace:
```
if [ "$SELF_HOST" -eq 1 ]; then
  log "Self-host detected: target is the master repo itself."
  log "  shamt-core/ already present — skipping framework-source copy."
fi

# ---- Already-installed guard (config path is self-host-dependent) -----------

if [ "$SELF_HOST" -eq 1 ]; then
  precheck_config="$TARGET_DIR/shamt-config.json"
  precheck_import="$TARGET_DIR/shamt-core/import-shamt.sh"
else
  precheck_config="$TARGET_DIR/.shamt-core/shamt-config.json"
  precheck_import="$TARGET_DIR/.shamt-core/import-shamt.sh"
fi
if [ -f "$precheck_config" ]; then
  err "Shamt is already installed at: $TARGET_DIR/"
  err "  $precheck_config exists — refusing to overwrite."
  err "To pull updates, run:"
  err "  bash $precheck_import"
  exit 1
fi
```

**Verification:**
- `grep -n 'precheck_config' init-shamt.sh` → 4 matches, all *after* the self-host detection block.
- `grep -n 'if \[ -f "\$TARGET_DIR/shamt-config.json" \]' init-shamt.sh` → 0 matches (the old early precheck is gone).

---

## Step 2 — `init-shamt.sh`: relocate the canonical-source copy destination to `.shamt-core/`

**Operation:** EDIT
**File:** `init-shamt.sh`

**Occurrence (lines ~334–336):**
Locate:
```
  log ""
  log "Copying canonical sources to $TARGET_DIR/shamt-core/ …"
  dest_root="$TARGET_DIR/shamt-core"
```
Replace:
```
  log ""
  log "Copying canonical sources to $TARGET_DIR/.shamt-core/ …"
  dest_root="$TARGET_DIR/.shamt-core"
```

**Verification:**
- `grep -n 'dest_root="\$TARGET_DIR/\.shamt-core"' init-shamt.sh` → 1 match.
- `grep -n 'dest_root="\$TARGET_DIR/shamt-core"' init-shamt.sh` → 0 matches.

---

## Step 3 — `init-shamt.sh`: drop the redundant root `CHEATSHEET.md` seed

**Operation:** EDIT
**File:** `init-shamt.sh`

`CHEATSHEET.md` is in `SHAMT_CORE_INSTALL_PATHS`, so it is already copied to `.shamt-core/CHEATSHEET.md` (the new canonical child location). The separate root seed is now redundant. Removing it from inside the `SELF_HOST -eq 0` doc-seed block also keeps self-host untouched.

**Occurrence (lines ~367–373).**
Locate:
```
  cheatsheet_src="$SHAMT_CORE_SRC/CHEATSHEET.md"
  if [ -f "$TARGET_DIR/CHEATSHEET.md" ]; then
    warn "CHEATSHEET.md already exists — preserving."
  elif [ -f "$cheatsheet_src" ]; then
    cp "$cheatsheet_src" "$TARGET_DIR/CHEATSHEET.md"
    log "  seeded  CHEATSHEET.md"
  fi
fi
```
Replace:
```
fi
```

**Verification:**
- `grep -n 'cheatsheet_src' init-shamt.sh` → 0 matches.
- The `if [ "$SELF_HOST" -eq 0 ]; then` block that began at the "Seeding top-level docs" comment now closes immediately after the `CLAUDE.md` seed (the `fi` above). Confirm balanced `if`/`fi` by running `bash -n init-shamt.sh` (Step 9 verification).

---

## Step 4 — `init-shamt.sh`: gate the project-doc seeding on `SELF_HOST -eq 0` and relocate to `.shamt-core/project-specific-files/`

**Operation:** EDIT
**File:** `init-shamt.sh`

The doc seeding currently (a) runs ungated — it would seed on self-host too — and (b) writes to the project root. Wrap it in a `SELF_HOST -eq 0` guard and write to `.shamt-core/project-specific-files/`. This single edit spans the ARCHITECTURE.md + CODING_STANDARDS.md seed blocks **and** the now-redundant root `proposals/_template.md` seed (which is dropped — `proposals/_template.md` is in `SHAMT_CORE_INSTALL_PATHS`, already copied to `.shamt-core/proposals/_template.md`).

**Occurrence (lines ~376–411).**
Locate:
```
arch_src="$SHAMT_CORE_SRC/templates/architecture.template.md"
if [ -f "$TARGET_DIR/ARCHITECTURE.md" ]; then
  warn "ARCHITECTURE.md already exists — preserving."
elif [ -f "$arch_src" ]; then
  seed_doc_with_today "$arch_src" "$TARGET_DIR/ARCHITECTURE.md"
  log "  seeded  ARCHITECTURE.md (Last Updated set to today)"
else
  warn "architecture.template.md not found — ARCHITECTURE.md not seeded."
fi

cs_src="$SHAMT_CORE_SRC/templates/coding_standards.template.md"
if [ -f "$TARGET_DIR/CODING_STANDARDS.md" ]; then
  warn "CODING_STANDARDS.md already exists — preserving."
elif [ -f "$cs_src" ]; then
  seed_doc_with_today "$cs_src" "$TARGET_DIR/CODING_STANDARDS.md"
  log "  seeded  CODING_STANDARDS.md (Last Updated set to today)"
else
  warn "coding_standards.template.md not found — CODING_STANDARDS.md not seeded."
fi

# proposals/_template.md at the project root: /propose-update reads it
# project-relative. Always seed it (it's a tiny canonical reference).
#
# Master-owned: import-shamt.sh resyncs this file from master on every framework
# pull (mirrors shamt-core/proposals/_template.md to the project root so a
# master template edit reaches the child's author surface). Local edits to this
# file will be overwritten by the next /import-shamt — propose changes through
# the framework-update flow instead of editing the root copy.
prop_src="$SHAMT_CORE_SRC/proposals/_template.md"
if [ -f "$prop_src" ]; then
  mkdir -p "$TARGET_DIR/proposals"
  if [ ! -f "$TARGET_DIR/proposals/_template.md" ]; then
    cp "$prop_src" "$TARGET_DIR/proposals/_template.md"
    log "  seeded  proposals/_template.md (master-owned; resynced by /import-shamt)"
  fi
fi
```
Replace:
```
# Project-specific docs live under .shamt-core/project-specific-files/ on a
# child install. Skipped entirely on self-host: the master repo keeps its own
# top-level docs and never grows a .shamt-core/ tree.
#
# proposals/_template.md is NOT seeded here — it is part of SHAMT_CORE_INSTALL_PATHS
# and is copied to .shamt-core/proposals/_template.md by the canonical-source copy
# step above; /propose-update reads it from there.
if [ "$SELF_HOST" -eq 0 ]; then
  psf_dir="$TARGET_DIR/.shamt-core/project-specific-files"
  mkdir -p "$psf_dir"

  arch_src="$SHAMT_CORE_SRC/templates/architecture.template.md"
  if [ -f "$psf_dir/ARCHITECTURE.md" ]; then
    warn "ARCHITECTURE.md already exists — preserving."
  elif [ -f "$arch_src" ]; then
    seed_doc_with_today "$arch_src" "$psf_dir/ARCHITECTURE.md"
    log "  seeded  .shamt-core/project-specific-files/ARCHITECTURE.md (Last Updated set to today)"
  else
    warn "architecture.template.md not found — ARCHITECTURE.md not seeded."
  fi

  cs_src="$SHAMT_CORE_SRC/templates/coding_standards.template.md"
  if [ -f "$psf_dir/CODING_STANDARDS.md" ]; then
    warn "CODING_STANDARDS.md already exists — preserving."
  elif [ -f "$cs_src" ]; then
    seed_doc_with_today "$cs_src" "$psf_dir/CODING_STANDARDS.md"
    log "  seeded  .shamt-core/project-specific-files/CODING_STANDARDS.md (Last Updated set to today)"
  else
    warn "coding_standards.template.md not found — CODING_STANDARDS.md not seeded."
  fi
fi
```

**Verification:**
- `grep -n 'project-specific-files' init-shamt.sh` → at least 5 matches (psf_dir def + 2 paths + 2 log lines).
- `grep -n 'TARGET_DIR/proposals' init-shamt.sh` → 0 matches (root proposals seed dropped).
- `grep -n 'TARGET_DIR/ARCHITECTURE.md\|TARGET_DIR/CODING_STANDARDS.md' init-shamt.sh` → 0 matches (no root-level doc seed remains).

---

## Step 5 — `init-shamt.sh`: write `shamt-config.json` to the self-host-dependent location

**Operation:** EDIT
**File:** `init-shamt.sh`

**Occurrence (lines ~434–446).**
Locate:
```
cat > "$TARGET_DIR/shamt-config.json" <<EOF
{
  "project_name": "$JSON_PROJECT_NAME",
  "work_item_tracker": "$JSON_WORK_ITEM_TRACKER",
  "pr_provider": "$JSON_PR_PROVIDER",
  "testing": "$JSON_TESTING",
  "ai_service": "$JSON_AI_SERVICE",
  "master_url": "$JSON_MASTER_URL",
  "doc_staleness_threshold_days": $DOC_STALENESS
}
EOF
log ""
log "Wrote shamt-config.json"
```
Replace:
```
# Self-host keeps its config at the repo root; a child install puts it under
# .shamt-core/ (the dest_root created by the canonical-source copy step).
if [ "$SELF_HOST" -eq 1 ]; then
  config_dest="$TARGET_DIR/shamt-config.json"
else
  config_dest="$TARGET_DIR/.shamt-core/shamt-config.json"
fi
mkdir -p "$(dirname "$config_dest")"
cat > "$config_dest" <<EOF
{
  "project_name": "$JSON_PROJECT_NAME",
  "work_item_tracker": "$JSON_WORK_ITEM_TRACKER",
  "pr_provider": "$JSON_PR_PROVIDER",
  "testing": "$JSON_TESTING",
  "ai_service": "$JSON_AI_SERVICE",
  "master_url": "$JSON_MASTER_URL",
  "doc_staleness_threshold_days": $DOC_STALENESS
}
EOF
log ""
log "Wrote $config_dest"
```

**Verification:**
- `grep -n 'config_dest' init-shamt.sh` → 5 matches.
- `grep -n 'cat > "\$TARGET_DIR/shamt-config.json"' init-shamt.sh` → 0 matches.

---

## Step 6 — `init-shamt.sh`: point the regen-script path at the self-host-dependent location

**Operation:** EDIT
**File:** `init-shamt.sh`

The current if/else sets both branches to the same `shamt-core/scripts/` path. Self-host keeps `shamt-core/scripts/`; a child install uses `.shamt-core/scripts/`.

**Occurrence (lines ~451–455).**
Locate:
```
regen_script=""
if [ "$SELF_HOST" -eq 1 ]; then
  regen_script="$TARGET_DIR/shamt-core/scripts/regenerate-framework.sh"
else
  regen_script="$TARGET_DIR/shamt-core/scripts/regenerate-framework.sh"
fi
```
Replace:
```
regen_script=""
if [ "$SELF_HOST" -eq 1 ]; then
  regen_script="$TARGET_DIR/shamt-core/scripts/regenerate-framework.sh"
else
  regen_script="$TARGET_DIR/.shamt-core/scripts/regenerate-framework.sh"
fi
```

**Verification:**
- `grep -n 'TARGET_DIR/\.shamt-core/scripts/regenerate-framework.sh' init-shamt.sh` → 1 match.

---

## Step 7 — `init-shamt.sh`: replace the closing summary with the completion prompt (G1)

**Operation:** EDIT
**File:** `init-shamt.sh`

Replace the passive "Next steps" summary with a clearly-delimited, copy/pastable agent prompt that drives an agent to research the project, fill both project-specific docs, and validate each. The prompt is heredoc-quoted with a single-quoted delimiter (`<<'PROMPT'`) so no `$`, backtick, or `EOF` inside it expands or collides. Gated on `SELF_HOST -eq 0` — the master repo already has its own docs and no `.shamt-core/project-specific-files/`.

**Occurrence (lines ~483–488).**
Locate:
```
log ""
log "Next steps:"
log "  - Review and edit ARCHITECTURE.md / CODING_STANDARDS.md."
log "  - Author a first story via: /start-story {slug}"
log "  - To pull master updates later: bash $TARGET_DIR/shamt-core/import-shamt.sh"
log ""
```
Replace:
```
log ""
if [ "$SELF_HOST" -eq 1 ]; then
  import_hint="$TARGET_DIR/shamt-core/import-shamt.sh"
else
  import_hint="$TARGET_DIR/.shamt-core/import-shamt.sh"
fi
log "Next steps:"
log "  - Author a first story via: /start-story {slug}"
log "  - To pull master updates later: bash $import_hint"
log ""
if [ "$SELF_HOST" -eq 0 ]; then
  log "To finish setup, paste the following prompt into a fresh Claude Code"
  log "session at the project root — it fills in the two project-specific docs"
  log "and validates each:"
  log ""
  cat <<'PROMPT'
────────────────────────────────────────────────────────────────────────
Research this codebase and complete the two Shamt project-specific
documents, then validate each.

1. Read .shamt-core/project-specific-files/ARCHITECTURE.md and
   .shamt-core/project-specific-files/CODING_STANDARDS.md — both are
   templates full of placeholders.
2. Explore the repository (entry points, services, data stores, build and
   test tooling, naming and structure conventions) and replace every
   placeholder with content true to THIS project. Keep an explicit "Open
   Questions" list as you draft; ask me each question one at a time and
   fold the answer in before continuing (Shamt Principle 2).
3. When ARCHITECTURE.md is complete, run:
     /validate-artifact .shamt-core/project-specific-files/ARCHITECTURE.md
   When CODING_STANDARDS.md is complete, run:
     /validate-artifact .shamt-core/project-specific-files/CODING_STANDARDS.md
   Resolve every finding until each document carries a validation footer.
────────────────────────────────────────────────────────────────────────
PROMPT
  log ""
fi
```

**Verification:**
- `grep -n "<<'PROMPT'" init-shamt.sh` → 1 match; `grep -n '^PROMPT$' init-shamt.sh` → 1 match (heredoc opens and closes).
- `grep -n 'import_hint' init-shamt.sh` → 3 matches.
- `grep -n 'Review and edit ARCHITECTURE.md' init-shamt.sh` → 0 matches (old summary line gone).
- `bash -n init-shamt.sh` → exits 0 (syntax check; covers Steps 1–7).

---

## Step 8 — `init-shamt.sh`: update header/usage comments for the new layout

**Operation:** EDIT
**File:** `init-shamt.sh`

Documentation-only edits so the header narrative matches the new behavior. Three occurrences.

**8a (lines ~16–27, behavior comment).**
Locate:
```
#   3. Halt if <target>/shamt-config.json already exists — use import-shamt.sh
#      to pull updates on an already-installed project.
#   4. Prompt interactively for every shamt-config.json field. No flag-based
#      unattended mode (deferred until a real need surfaces).
#   5. Copy canonical sources into <target>/shamt-core/ (skipped on self-host).
#      The set matches what import-shamt.sh syncs going forward, plus
#      init-shamt.sh / import-shamt.sh themselves so re-invocation works.
#   6. Seed top-level docs at <target>/ when missing: CLAUDE.md (from
#      templates/SHAMT_RULES.template.md), CHEATSHEET.md (copy), ARCHITECTURE.md
#      and CODING_STANDARDS.md (from templates with Last Updated = today),
#      proposals/_template.md (copy — /propose-update reads it project-relative).
#   7. Write shamt-config.json from the prompted answers.
```
Replace:
```
#   3. Halt if the install config already exists (root shamt-config.json on
#      self-host, <target>/.shamt-core/shamt-config.json otherwise) — use
#      import-shamt.sh to pull updates on an already-installed project.
#   4. Prompt interactively for every shamt-config.json field. No flag-based
#      unattended mode (deferred until a real need surfaces).
#   5. Copy canonical sources into <target>/.shamt-core/ (skipped on self-host).
#      The set matches what import-shamt.sh syncs going forward, plus
#      init-shamt.sh / import-shamt.sh themselves so re-invocation works.
#      CHEATSHEET.md and proposals/_template.md travel inside this set — they
#      are NOT separately seeded at the project root.
#   6. Seed the child's CLAUDE.md (from templates/SHAMT_RULES.template.md) at
#      <target>/, and the two project-specific docs (ARCHITECTURE.md,
#      CODING_STANDARDS.md, Last Updated = today) under
#      <target>/.shamt-core/project-specific-files/. Skipped on self-host.
#   7. Write shamt-config.json (root on self-host, <target>/.shamt-core/
#      otherwise) from the prompted answers.
```

**8b (lines ~89–90, usage footer).**
Locate:
```
Halts if <target>/shamt-config.json already exists. Use the installed
shamt-core/import-shamt.sh to pull framework updates afterwards.
```
Replace:
```
Halts if the install config already exists (root shamt-config.json on
self-host, <target>/.shamt-core/shamt-config.json otherwise). Use the
installed .shamt-core/import-shamt.sh to pull framework updates afterwards.
```

**Verification:**
- `grep -nc 'Review and edit' init-shamt.sh` → 0.
- `grep -n '\.shamt-core/' init-shamt.sh` → covers comment + logic lines (≥ 12 matches across Steps 1–8).

---

## Step 9 — `init-shamt.sh`: final syntax + self-host safety check

**Operation:** EDIT (verification step — no content change beyond Steps 1–8)
**File:** `init-shamt.sh`

**Verification:**
- `bash -n init-shamt.sh` → exits 0.
- Self-host narrative intact: a self-host run (where `<target>/shamt-core/init-shamt.sh` is this script) must skip the framework copy, write root `shamt-config.json`, seed **no** `.shamt-core/project-specific-files/`, and the relocated precheck must fire on a re-run. Confirm by reading the `SELF_HOST -eq 1` branches in Steps 1b, 5, 6, 7.
- `grep -n 'SHAMT_CORE_INSTALL_PATHS' init-shamt.sh` → array unchanged (still lists `CHEATSHEET.md`, `proposals/_template.md`, etc. — they land under `.shamt-core/` via `dest_root`).

---

## Step 10 — `import-shamt.sh`: relocate the child install dir and config path to `.shamt-core/`

**Operation:** EDIT
**File:** `import-shamt.sh`

**10a (line ~128–129, install-dir resolution).**
Locate:
```
CHILD_SHAMT_CORE="$TARGET_DIR/shamt-core"
[ -d "$CHILD_SHAMT_CORE" ] || { err "target has no shamt-core/ — run init-shamt.sh first"; exit 1; }
```
Replace:
```
CHILD_SHAMT_CORE="$TARGET_DIR/.shamt-core"
[ -d "$CHILD_SHAMT_CORE" ] || { err "target has no .shamt-core/ — run init-shamt.sh first"; exit 1; }
```

**10b (line ~131–132, config path).**
Locate:
```
CONFIG_PATH="$TARGET_DIR/shamt-config.json"
[ -f "$CONFIG_PATH" ] || { err "shamt-config.json not found at $CONFIG_PATH — run init-shamt.sh first"; exit 1; }
```
Replace:
```
CONFIG_PATH="$TARGET_DIR/.shamt-core/shamt-config.json"
[ -f "$CONFIG_PATH" ] || { err "shamt-config.json not found at $CONFIG_PATH — run init-shamt.sh first"; exit 1; }
```

**Verification:**
- `grep -n 'CHILD_SHAMT_CORE="\$TARGET_DIR/\.shamt-core"' import-shamt.sh` → 1 match.
- `grep -n 'CONFIG_PATH="\$TARGET_DIR/\.shamt-core/shamt-config.json"' import-shamt.sh` → 1 match.
- `grep -n '\$CHILD_SHAMT_CORE/scripts/regenerate-framework.sh' import-shamt.sh` → 1 match (line ~366; auto-resolves to `.shamt-core/scripts/` via the variable — no separate edit needed).

---

## Step 11 — `import-shamt.sh`: drop the root `proposals/_template.md` mirror

**Operation:** EDIT
**File:** `import-shamt.sh`

`proposals/_template.md` is in `MASTER_SYNC_FILES`, so `apply_one` already syncs it to `$CHILD_SHAMT_CORE/proposals/_template.md` = `.shamt-core/proposals/_template.md` (the new canonical child location). The separate "mirror to project root" block is now redundant and must be removed.

**Occurrence (lines ~303–329).**
Locate:
```
# ---- Sync root-level proposals/_template.md ---------------------------------

# /propose-update reads proposals/_template.md at the project root (not under
# shamt-core/). init-shamt.sh seeded that root-level copy; import-shamt has to
# keep it in lock-step with master so a template edit on master takes effect on
# child proposals authored after the next /import-shamt. The canonical copy
# under shamt-core/proposals/_template.md is already synced above; this step
# mirrors it to the project root.
root_template_src="$MASTER_SHAMT_CORE/proposals/_template.md"
root_template_dst="$TARGET_DIR/proposals/_template.md"
if [ -f "$root_template_src" ]; then
  mkdir -p "$TARGET_DIR/proposals"
  if [ -f "$root_template_dst" ] && cmp -s "$root_template_src" "$root_template_dst"; then
    UNCHANGED_COUNT=$((UNCHANGED_COUNT + 1))
  else
    existed=0
    [ -f "$root_template_dst" ] && existed=1
    cp "$root_template_src" "$root_template_dst"
    if [ "$existed" -eq 1 ]; then
      log "  updated  proposals/_template.md (project root)"
      UPDATED_COUNT=$((UPDATED_COUNT + 1))
    else
      log "  new      proposals/_template.md (project root)"
      NEW_COUNT=$((NEW_COUNT + 1))
    fi
  fi
fi

```
Replace:
```
# (Removed: the root-level proposals/_template.md mirror. Proposals now live
# under .shamt-core/proposals/, and proposals/_template.md is part of
# MASTER_SYNC_FILES — apply_one already syncs it to
# $CHILD_SHAMT_CORE/proposals/_template.md = .shamt-core/proposals/_template.md.
# /propose-update reads it from there.)

```

**Verification:**
- `grep -n 'root_template_src\|root_template_dst' import-shamt.sh` → 0 matches.
- `grep -n 'proposals/_template.md (project root)' import-shamt.sh` → 0 matches.

---

## Step 12 — `import-shamt.sh`: walk already-merged proposals under `.shamt-core/proposals/`

**Operation:** EDIT
**File:** `import-shamt.sh`

**Occurrence (lines ~333).**
Locate:
```
CHILD_PROPOSALS="$TARGET_DIR/proposals"
```
Replace:
```
CHILD_PROPOSALS="$TARGET_DIR/.shamt-core/proposals"
```

The log labels in this block use a `src_label="proposals${scan_rel:+/$scan_rel}/$base"` form. Update that label so the surfaced path matches the new location.

**Occurrence (line ~356).**
Locate:
```
        src_label="proposals${scan_rel:+/$scan_rel}/$base"
```
Replace:
```
        src_label=".shamt-core/proposals${scan_rel:+/$scan_rel}/$base"
```

The destination half of the same `moved` log line carries a bare `proposals/already-merged/$base` literal (line ~357). Repoint it too so the surfaced line reads symmetrically under `.shamt-core/`. The move destination itself (`dest_dir="$CHILD_PROPOSALS/already-merged"`, line ~353) resolves via `$CHILD_PROPOSALS` and needs no edit — only the log literal is bare.

**Occurrence (line ~357).**
Locate:
```
        log "  moved    $src_label → proposals/already-merged/$base (matched master archive)"
```
Replace:
```
        log "  moved    $src_label → .shamt-core/proposals/already-merged/$base (matched master archive)"
```

**Verification:**
- `grep -n 'CHILD_PROPOSALS="\$TARGET_DIR/\.shamt-core/proposals"' import-shamt.sh` → 1 match.
- `grep -n 'src_label="\.shamt-core/proposals' import-shamt.sh` → 1 match.
- `grep -n '→ \.shamt-core/proposals/already-merged/\$base' import-shamt.sh` → 1 match (the `moved` log line now reads symmetrically: `.shamt-core/proposals/{slug}.md → .shamt-core/proposals/already-merged/{slug}.md`).

---

## Step 13 — `import-shamt.sh`: fix the preserve-warning label

**Operation:** EDIT
**File:** `import-shamt.sh`

**Occurrence (line ~297).**
Locate:
```
      warn "preserving local file not in master sync set: shamt-core/$sub/$rel"
```
Replace:
```
      warn "preserving local file not in master sync set: .shamt-core/$sub/$rel"
```

**Verification:**
- `grep -n 'preserving local file not in master sync set: \.shamt-core' import-shamt.sh` → 1 match.
- Confirm child-owned content is preserved by construction: `shamt-config.json`, `proposals/{slug}.md`, and `project-specific-files/` are **not** in `MASTER_SYNC_FILES` and **not** under `MASTER_SYNC_DIRS` (`scripts templates reference host`), so neither the apply pass nor the preserve-warning walk touches them. No code change needed — verify by reading the two arrays.

---

## Step 14 — `import-shamt.sh`: update header/usage comments for the new layout

**Operation:** EDIT
**File:** `import-shamt.sh`

Documentation-only. Five occurrences (14a–14e).

**14a (lines ~4–5, usage).**
Locate:
```
# Usage:
#   bash <child>/shamt-core/import-shamt.sh [--target <dir>]
```
Replace:
```
# Usage:
#   bash <child>/.shamt-core/import-shamt.sh [--target <dir>]
```

**14b (lines ~12–14, sync rule comment).**
Locate:
```
# Sync rule (Phase 9): every path in the explicit MASTER_SYNC_PATHS set is
# master-owned. Master wins on every diff. Anything under <child>/shamt-core/
# that is NOT in the sync set is preserved with a warning.
```
Replace:
```
# Sync rule (Phase 9): every path in the explicit MASTER_SYNC_PATHS set is
# master-owned. Master wins on every diff. Anything under <child>/.shamt-core/
# that is NOT in the sync set is preserved with a warning.
```

**14c (lines ~24–32, already-merged + regen comments).**
Locate:
```
# Already-merged proposals: walk both <child>/proposals/{slug}.md
# (locally-authored, not yet submitted) and <child>/proposals/submitted/{slug}.md
# (submitted via /submit-proposal, awaiting master's decision). If a master
# archive entry <master>/proposals/archive/{slug}.md matches the basename, the
# proposal landed upstream and came back via this sync; move the local copy to
# <child>/proposals/already-merged/{slug}.md per §4.7 / §4.9.
#
# After the file sync, the script runs <child>/shamt-core/scripts/
# regenerate-framework.sh --target <child> so <child>/.claude/ stays current.
```
Replace:
```
# Already-merged proposals: walk both <child>/.shamt-core/proposals/{slug}.md
# (locally-authored, not yet submitted) and
# <child>/.shamt-core/proposals/submitted/{slug}.md (submitted via
# /submit-proposal, awaiting master's decision). If a master archive entry
# <master>/proposals/archive/{slug}.md matches the basename, the proposal landed
# upstream and came back via this sync; move the local copy to
# <child>/.shamt-core/proposals/already-merged/{slug}.md per §4.7 / §4.9.
#
# After the file sync, the script runs <child>/.shamt-core/scripts/
# regenerate-framework.sh --target <child> so <child>/.claude/ stays current.
```

**14d (lines ~85–87, usage option text).**
Locate:
```
  --target <dir>   Target project directory. Defaults to the parent of the
                   directory containing this script (i.e., <child> when the
                   script lives at <child>/shamt-core/import-shamt.sh).
```
Replace:
```
  --target <dir>   Target project directory. Defaults to the parent of the
                   directory containing this script (i.e., <child> when the
                   script lives at <child>/.shamt-core/import-shamt.sh).
```

**14e (line ~82, `usage()` heredoc invocation; line ~122, default-target inline comment).**
Two more child-side `<child>/shamt-core/import-shamt.sh` literals carry the install-dir path and must move to `.shamt-core/`. Line ~82 is the path printed by `import-shamt.sh --help`; line ~122 is the comment explaining the default-target derivation. (Both are required by proposal A2 — "usage/comment/error strings" — and 14a–14d miss them.)

The heredoc line (~82) is distinguished from the header-comment copy at line ~5 by its leading two spaces and absence of a `#` prefix; locate it verbatim.

**Occurrence (line ~82).**
Locate:
```
  bash <child>/shamt-core/import-shamt.sh [--target <dir>]
```
Replace:
```
  bash <child>/.shamt-core/import-shamt.sh [--target <dir>]
```

**Occurrence (line ~122).**
Locate:
```
  # invoked as <child>/shamt-core/import-shamt.sh, the target is <child>.
```
Replace:
```
  # invoked as <child>/.shamt-core/import-shamt.sh, the target is <child>.
```

**Verification:**
- `grep -nE 'shamt-core/import-shamt\.sh|<child>/shamt-core/' import-shamt.sh | grep -v '\.shamt-core'` → **1 match** — the master-canonical managed footer at line ~389 (`Regenerate from shamt-core/import-shamt.sh`), which stays per the proposal's scope boundary (analogous to Step 16's C3 footer handling). No other bare child-side `shamt-core/` literal remains.
- `grep -c '<child>/\.shamt-core/import-shamt.sh' import-shamt.sh` → 4 — the four occurrences that name the full script path are lines ~5 (14a), ~87 (14d), ~82 and ~122 (14e). (14b and 14c repoint `<child>/shamt-core/` paths that do not include `import-shamt.sh`, so they do not add to this count.)
- `bash -n import-shamt.sh` → exits 0.

---

## Step 15 — `scripts/regenerate-framework.sh`: confirm name-agnostic (NO-OP / verify)

**Operation:** NO-OP (verification only)
**File:** `scripts/regenerate-framework.sh`

The script resolves `SHAMT_CORE_ROOT` from its own physical location (`SCRIPT_DIR/..`) and `CANONICAL_ROOT="$SHAMT_CORE_ROOT/host/templates/claude"`; `TARGET_CLAUDE_DIR="$TARGET_DIR/.claude"`. There is no literal child-side `shamt-core/` path. `STATUS_LINE_COMMAND='bash $CLAUDE_PROJECT_DIR/.claude/statusline.sh'` is unaffected. The only `shamt-core` literal is the header comment line 2 (`Render shamt-core/host/templates/claude/`), which describes the master canonical tree — master-canonical, left unchanged.

**Verification:**
- `grep -n 'shamt-core' scripts/regenerate-framework.sh` → 1 match (line 2 header comment only).
- `grep -n 'TARGET_CLAUDE_DIR="\$TARGET_DIR/\.claude"' scripts/regenerate-framework.sh` → 1 match (`.claude/` stays at `<target>/.claude/`).
- No edit applied.

---

## Step 16 — `host/templates/claude/statusline.sh`: repoint the cwd-relative config read (D3) + confirm C3

**Operation:** EDIT
**File:** `host/templates/claude/statusline.sh`

The status line runs with `cwd = PROJECT_DIR` (project root), so the prefixed relative path `.shamt-core/shamt-config.json` resolves. Two reads (lines 52–53) plus the explanatory comment (line 43). The `stories/`, `features/`, `epics/` globs stay root-relative — those runtime dirs are **not** moved by this proposal.

**16a (line ~43, comment).**
Locate:
```
# Default to the 6-phase scheme so projects without shamt-config.json (or with
```
Replace:
```
# Default to the 6-phase scheme so projects without .shamt-core/shamt-config.json (or with
```

**16b (lines ~52–53, the reads).**
Locate:
```
if [ -f shamt-config.json ] \
   && grep -qzE '[{,[:space:]]"testing"[[:space:]]*:[[:space:]]*"enabled"' shamt-config.json 2>/dev/null; then
```
Replace:
```
if [ -f .shamt-core/shamt-config.json ] \
   && grep -qzE '[{,[:space:]]"testing"[[:space:]]*:[[:space:]]*"enabled"' .shamt-core/shamt-config.json 2>/dev/null; then
```

**Verification:**
- `grep -nE '(^|[^./-])shamt-config\.json' host/templates/claude/statusline.sh` → 0 matches.
- `grep -c '\.shamt-core/shamt-config.json' host/templates/claude/statusline.sh` → 3.
- C3 confirm: `grep -n 'shamt-core/' host/templates/claude/statusline.sh | grep -v '\.shamt-core'` → 1 match only (the line-190 `Regenerate from shamt-core/...` managed footer — master-canonical, left).
- `bash -n host/templates/claude/statusline.sh` → exits 0.

---

## Cross-check vs Proposed Changes (Phase 1 coverage)

| Proposal row | Covered by |
|---|---|
| A1 (`init-shamt.sh` — dest, config gating, doc seed gating+relocate, drop root CHEATSHEET + proposals seed, precheck reorder, regen branch) | Steps 1–6, 8, 9 |
| A2 (`import-shamt.sh` — `.shamt-core/`, config path, drop root `_template.md` mirror, already-merged walk, preserve check) | Steps 10–14 |
| A3 (`scripts/regenerate-framework.sh` — verify name-agnostic) | Step 15 (NO-OP) |
| C3 (`statusline.sh` — no substantive `shamt-core/` literal) | Step 16 verification |
| D3 (`statusline.sh` — cwd-relative config read) | Step 16 |
| G1 (`init-shamt.sh` closing completion prompt) | Step 7 |

---

---
Validated 2026-05-28 — 2 rounds, 1 adversarial sub-agent confirmed
