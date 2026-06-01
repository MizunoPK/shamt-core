---
Last Updated: YYYY-MM-DD
Update History:
  - YYYY-MM-DD: Initial creation (project initialization)
Update Triggers: |
  Update this document when:
  - New services, deployment units, or major components are added or removed
  - A data store is added, removed, or changes role (primary, replica, cache)
  - A boundary between components changes (new API contract, new event topic, new shared dependency)
  - An integration with an external system is added, removed, or changes auth/contract
  - A significant cross-cutting dependency is added (auth provider, message bus, observability backend)
  - An architectural decision affects how multiple features are built
How to Update: |
  Open a story (or a framework-update proposal if this is a shamt-core change), follow the
  Engineer flow, and amend the relevant sections of this file. Phase 6 (Review) will flag
  whether a story implies an update; Phase 7 (Polish) applies the update and re-validates.
  Run `/validate-artifact .shamt-core/project-specific-files/ARCHITECTURE.md` after substantive edits. Keep `Last Updated`
  current and add an entry to `Update History` with the triggering story or proposal slug.
---

# Project Architecture

**Purpose:** High-level system overview for context during discovery, planning, and code reviews. Threaded into Phase 2 (Spec) research, Phase 6 (Review) Documentation Impact Assessment, and Phase 7 (Polish) currency review per the Shamt rules.

---

## Overview

[1-3 paragraph description of what this project does, its purpose, and its primary users.]

---

## Tech Stack

| Layer | Technology | Notes |
|-------|------------|-------|
| Language | [e.g., Python 3.11, TypeScript 5.x, Go 1.22] | |
| Framework | [e.g., FastAPI, React, Gin] | |
| Data stores | [e.g., PostgreSQL, Redis, S3] | |
| Testing | [e.g., pytest, jest, go test] | |
| Build / package manager | [e.g., npm, poetry, cargo] | |
| Deployment | [e.g., container runtime, orchestrator, CDN] | |

---

## Project Structure

```
[project root]/
├── [dir/]          — [what it contains]
├── [dir/]          — [what it contains]
└── ...
```

**Key directories:**
- `[dir]/` — [purpose]
- `[dir]/` — [purpose]

---

## Components and Boundaries

For each major component or deployment unit, document its purpose, the boundary it lives behind, and what it owns. A "boundary" is anywhere data, identity, or trust crosses — a network call, a queue, a file write, a process boundary, an OS process, a build/deploy unit.

### Component 1: [Name]

**Purpose:** [what it does]

**Boundary:** [How it is reached — HTTP route, queue subscription, CLI entry, scheduled job. What authenticates the caller.]

**Owns:** [State, data, configuration this component is the source of truth for.]

**Key files:**
- `path/to/file.ext` — [role]

**Dependencies:**
- Internal: [other components]
- External: [libraries, services]

### Component 2: [Name]

[Repeat structure]

---

## Data Stores

Document every persistent store the project owns or relies on. One row per store. Include role (primary / replica / cache / queue / blob), the components that read or write it, and the migration / schema-ownership model.

| Store | Type | Role | Readers | Writers | Schema owner | Notes |
|-------|------|------|---------|---------|--------------|-------|
| [name] | [PostgreSQL / Redis / S3 / Kafka / ...] | [primary / replica / cache / queue / blob] | [components] | [components] | [migration tool / owning component] | [retention, partitioning, RLS, etc.] |

---

## Data Flow

[Describe how data moves through the system from input to output. Reference components by the names defined above.]

**Example flow:**
```
User Input → [Component A] → [Component B] → [Component C] → Output
```

For boundary-crossing flows in active stories, prefer a Mermaid diagram per `reference/mermaid_diagram_standards.md` and link it from the relevant story's `context.md`.

---

## Integration Points

### External Services

- **[Service Name]:** [Purpose, how integrated, auth model, failure-handling notes.]

### APIs

- **[API Name]:** [Inbound vs outbound, endpoints, authentication, contract location.]

### Event / Message Contracts

- **[Topic / Queue Name]:** [Producer(s), consumer(s), payload shape pointer, ordering / delivery guarantees.]

---

## Key Design Decisions

### Decision 1: [Title]

**Context:** [What problem or choice]

**Decision:** [What was chosen]

**Rationale:** [Why]

**Alternatives considered:** [What was rejected and why]

### Decision 2: [Title]

[Repeat structure]

---

## Security Posture

[Authentication methods, authorization patterns, tenant-isolation model, secrets handling, data classification, key security obligations. The detailed per-story enforcement lives in story `context.md`; this section is the standing baseline a story reviewer can check against.]

---

## Performance and Scaling Notes

[Targets (latency, throughput, RPO/RTO), known bottlenecks, caching strategy, scaling axis (vertical / horizontal / sharded).]

---

*Template for project `.shamt-core/project-specific-files/ARCHITECTURE.md` in Shamt. Header metadata block above is required — the framework-update audit reads it (§1.12).*
