# Implementation Plan — Phase 2: Config + install

**Proposal:** `proposals/21-formalize-testing-standards-and-stages.md`
**Index:** `proposals/21-formalize-testing-standards-and-stages_PLAN.md`
**Phase:** 2 of 5 — **Config + install.** Drop the `testing` config flag; make `init-shamt.sh` seed
`TESTING_STANDARDS.md` and complete it via the project-doc completion prompt.
**Depends on:** Phase 1 (`templates/testing_standards.template.md` must exist to seed).
**Executor:** `plan-executor` (Cheap). All edits are `bash -n`-checked; no `.claude/`.

## Pre-execution checklist

- [ ] Phase 1 landed: `templates/testing_standards.template.md` exists. (Hard execution-order
  dependency — Phase 2 runs after Phase 1. The Step 7 seed code additionally guards at runtime with
  an `elif`/`warn` branch, mirroring the existing ARCHITECTURE/CODING_STANDARDS seeds, so the generated
  install script stays defensively safe regardless; the two are not in tension.)
- [ ] On branch `proposal/21-formalize-testing-standards-and-stages`.

## Files manifest

| # | File | Op |
|---|---|---|
| 1 | `shamt-config.example.json` | EDIT (drop `testing` key) |
| 2–9 | `init-shamt.sh` | EDIT (remove the `TESTING` plumbing; seed + complete TESTING_STANDARDS.md; staleness ×3; header comment) |

---

## Step 1 — `shamt-config.example.json`: drop the `testing` key

Locate:
```
  "pr_provider": "github",
  "testing": "disabled",
  "ai_service": "anthropic",
```
Replace with:
```
  "pr_provider": "github",
  "ai_service": "anthropic",
```
**Verification:** `grep -c '"testing"' shamt-config.example.json` → `0`; `python3 -c 'import json;
json.load(open("shamt-config.example.json"))'` exits 0 (valid JSON).

---

## Step 2 — `init-shamt.sh`: remove the `TESTING` variable declaration

Locate:
```
PR_PROVIDER=""
TESTING=""
AI_SERVICE="anthropic"
```
Replace with:
```
PR_PROVIDER=""
AI_SERVICE="anthropic"
```

## Step 3 — `init-shamt.sh`: remove the testing init question

Locate (the whole block):
```
prompt_choice TESTING \
  "Automated testing infrastructure present in this project?" \
  "disabled" \
  "enabled" "disabled"

```
Replace with: (nothing — delete the block, including its trailing blank line). The testing approach
is now declared in `TESTING_STANDARDS.md` (authored via the completion prompt below), not asked at init.

## Step 4 — `init-shamt.sh`: extend the staleness question to three docs

Locate:
```
  "ARCHITECTURE.md / CODING_STANDARDS.md staleness threshold (days, integer)" \
```
Replace with:
```
  "ARCHITECTURE.md / CODING_STANDARDS.md / TESTING_STANDARDS.md staleness threshold (days, integer)" \
```

## Step 5 — `init-shamt.sh`: remove the testing JSON-escape + JSON write

5a — Locate:
```
JSON_TESTING="$(json_escape "$TESTING")"
```
Replace with: (delete the line).

5b — Locate (inside the shamt-config.json write block):
```
  "pr_provider": "$JSON_PR_PROVIDER",
  "testing": "$JSON_TESTING",
  "ai_service": "$JSON_AI_SERVICE",
```
Replace with:
```
  "pr_provider": "$JSON_PR_PROVIDER",
  "ai_service": "$JSON_AI_SERVICE",
```
*(The three-line locate above is verbatim from the `cat > "$config_dest" <<EOF` write block at
`init-shamt.sh:477-479`; the replacement deletes only the `  "testing": "$JSON_TESTING",` line, and the
adjacent lines keep their own trailing commas, so the emitted JSON stays valid.)*

## Step 6 — `init-shamt.sh`: remove the testing summary log line

Locate:
```
log "  Testing:       $TESTING"
```
Replace with: (delete the line).

## Step 7 — `init-shamt.sh`: seed `TESTING_STANDARDS.md`

In the project-specific-docs seeding block, after the `CODING_STANDARDS.md` seed (and before the
closing `fi`), add a third doc seed. Locate:
```
    seed_doc_with_today "$cs_src" "$psf_dir/CODING_STANDARDS.md"
    log "  seeded  .shamt-core/project-specific-files/CODING_STANDARDS.md (Last Updated set to today)"
  else
    warn "coding_standards.template.md not found — CODING_STANDARDS.md not seeded."
  fi
fi
```
Replace with:
```
    seed_doc_with_today "$cs_src" "$psf_dir/CODING_STANDARDS.md"
    log "  seeded  .shamt-core/project-specific-files/CODING_STANDARDS.md (Last Updated set to today)"
  else
    warn "coding_standards.template.md not found — CODING_STANDARDS.md not seeded."
  fi

  ts_src="$SHAMT_CORE_SRC/templates/testing_standards.template.md"
  if [ -f "$psf_dir/TESTING_STANDARDS.md" ]; then
    warn "TESTING_STANDARDS.md already exists — preserving."
  elif [ -f "$ts_src" ]; then
    seed_doc_with_today "$ts_src" "$psf_dir/TESTING_STANDARDS.md"
    log "  seeded  .shamt-core/project-specific-files/TESTING_STANDARDS.md (Last Updated set to today)"
  else
    warn "testing_standards.template.md not found — TESTING_STANDARDS.md not seeded."
  fi
fi
```

## Step 8 — `init-shamt.sh`: extend the completion prompt to three docs

Locate the completion-prompt heredoc and rework it for three docs. Locate:
```
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
```
Replace with:
```
Research this codebase and complete the three Shamt project-specific
documents, then validate each.

1. Read .shamt-core/project-specific-files/ARCHITECTURE.md,
   .shamt-core/project-specific-files/CODING_STANDARDS.md, and
   .shamt-core/project-specific-files/TESTING_STANDARDS.md — all three are
   templates full of placeholders.
2. Explore the repository (entry points, services, data stores, build and
   test tooling, how the project is run/driven as a user, naming and
   structure conventions) and replace every placeholder with content true
   to THIS project. For TESTING_STANDARDS.md specifically: declare whether
   automated tests are Present or None (and the runner/command), and write
   the manual-as-user driving procedures (how to run the project, the
   inputs a real user supplies, what correct behavior looks like) so a
   fresh agent can drive it during the required Phase 5. Keep an explicit
   "Open Questions" list as you draft; ask me each question one at a time
   and fold the answer in before continuing (Shamt Principle 2).
3. When each document is complete, run:
     /validate-artifact .shamt-core/project-specific-files/ARCHITECTURE.md
     /validate-artifact .shamt-core/project-specific-files/CODING_STANDARDS.md
     /validate-artifact .shamt-core/project-specific-files/TESTING_STANDARDS.md
   Resolve every finding until each document carries a validation footer.
```

## Step 9 — `init-shamt.sh`: header comment (step 6) — three docs

Locate (in the `# Behavior:` header comment, the step-6 line edited by #19):
```
#      and seed the two project-specific docs (ARCHITECTURE.md,
#      CODING_STANDARDS.md, Last Updated = today) under
```
Replace with:
```
#      and seed the three project-specific docs (ARCHITECTURE.md,
#      CODING_STANDARDS.md, TESTING_STANDARDS.md, Last Updated = today) under
```

---

## Verification (phase exit)

- `bash -n init-shamt.sh` exits 0.
- `grep -c '"testing"\|TESTING=\|JSON_TESTING\|Testing:' init-shamt.sh` → `0` (no residual testing-flag
  plumbing). *(The `TESTING_STANDARDS` references — `ts_src`, the seed, the prompt — are the new doc,
  not the old flag, and are expected; the grep patterns above target only the old plumbing.)*
- `grep -c "TESTING_STANDARDS.md" init-shamt.sh` ≥ 4 (seed block + log + completion prompt + header).
- `grep -c '"testing"' shamt-config.example.json` → `0`; config is valid JSON.

## Review Prevention Gate Mapping

This phase edits a single shell install script (`init-shamt.sh`) and one config example
(`shamt-config.example.json`) — removing the `testing` config plumbing, seeding a doc template, and
reworking install prompts. No application code, runtime data path, schema, auth, or deployment surface
is touched. No gate applies.

| Gate | Applies? | Plan Step(s) | Verification | N/A / Deferral Reason |
|------|----------|--------------|--------------|------------------------|
| Regulated / sensitive data | No | — | — | Install-time prompts + config seed; no regulated data handled. |
| Tenant isolation | No | — | — | No tenancy in an install script. |
| Auth / route contract | No | — | — | No auth/route surface; install prompts + JSON write only. |
| Database read/write | No | — | — | No database access. |
| Infrastructure / deployment | No | — | — | Seeds project docs; no infra/deploy change. Regen runs later at `/f4`. |
| Frontend safety | No | — | — | No frontend/DOM/fetch surface. |
| Testing / test data | No | — | — | Edits remove the testing config flag and seed a doc template; no executable test/test data introduced. |
| Removed/weakened checks | No | — | — | The dropped `TESTING` question/key is a config branch, not a safety check; JSON validity is re-verified (Step 1 / phase-exit). |

## Notes

- **No legacy migration** (no legacy child projects, per #18) — dropping the `testing` key is clean;
  no script to rewrite existing configs.
- Self-host is unaffected: the doc-seeding block is already gated `SELF_HOST -eq 0`.
- `CODING_STANDARDS Compliance`: N/A — shamt-core's own install script; no project-code conventions apply.

---
Validated 2026-06-13 — 4 rounds, 1 adversarial sub-agent confirmed
