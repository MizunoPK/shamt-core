# Proposal: rules-file-over-budget

**Status:** Draft (f0 — audit capture, unrefined)

> ⚠️ **f0 draft — unrefined audit capture.** This is a quick-capture stub written by `/f5-audit-framework`'s dual-track loop to record an intricate finding so the audit could continue. It has had **no** open-questions dialog and carries **no** formal Proposed Changes table. Resolving and fleshing it out is `/f1-propose-update`'s job, which ingests this draft as its intake. Do not implement directly from this stub.

---

## Scratch Notes (f0 capture)

**Finding (D12 — rules-file size budget):** `templates/SHAMT_RULES.template.md` is **41953 characters**, over the `rules_size_budget_chars` budget of **40000** by **~1953 chars** (440 lines). The rules file renders into every child `CLAUDE.md`, so its size is a recurring per-interaction context cost. Severity MEDIUM per the f5 D12 definition; **always intricate** (trimming requires judgment — de-duplicate, extract to `reference/`, rephrase, relocate detail into command/skill bodies — and is never auto-fixed).

**Context:** The just-landed proposal 33 (`agents-trust-cross-session-provenance`) added **Principle 3 — Disk-authoritative cross-session work** (~9 lines / ~1.5 KB) to the §Cross-Cutting Design Principles section, which pushed the file from just-under to just-over its 40000-char budget. The over-budget state is small but real. (Proposal 33's own D12 risk note acknowledged the file was "431 lines against its size budget" and that Principle 3 "adds ~12–15 lines"; the addition is the proximate cause of crossing the line.)

**Suggested handling:** Route to `/trim-rules-file` — the dedicated command that analyzes the rules file for size-reduction opportunities (de-dup, extract-to-`reference/`, rephrase, relocate detail into command/skill bodies) and authors the detailed reduction proposal toward the 40000-char budget, without editing the rules file directly. This is the standard D12 follow-up path (cf. archived proposals 08 / 09 / 16, which each trimmed the file back under budget after prior growth).

**Measurement (this audit run):**

```
wc -m templates/SHAMT_RULES.template.md  ->  41953
rules_size_budget_chars (.shamt-core/shamt-config.json)  ->  40000
over by ~1953 chars
```

**Next step:** `/f1-propose-update rules-file-over-budget` (or run `/trim-rules-file` directly) to flesh this into a concrete cut list.
