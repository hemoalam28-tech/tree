# ADR-005: One graph model; Tree and Canvas as views

- Status: **Proposed** (awaiting approval)
- Date: 2026-10-10
- Deciders: pending product/architecture review
- Tags: domain, graph, canvas, tree

## Context

Product: a student knowledge organizer. Nodes may have **multiple parents**. Tree View and Canvas must show the **same graph**, not two copies that drift. Canvas coordinates are a view concern.

Picking a graph *widget* from screenshots is forbidden. `graphview` 1.5.1 exists on pub.dev (last publish ~11 months at research time) but is **not** selected in this ADR.

## Decision (recommendation)

### Domain graph (source of truth)

Persist in SQLite via Drift (ADR-002):

- `Node`: stable UUID, title, body/metadata, timestamps, optional type.
- `Edge`: `parentId`, `childId`, ordinal, UUID. Unique `(parentId, childId)`.
- Multiple parents = multiple edge rows. Cycles: **reject in Domain** on write (or allow with an explicit flag — see OPEN_QUESTIONS). Default recommendation: **forbid cycles** until a product decision says otherwise.
- A node with zero parents is a root. Multiple roots are allowed.

Domain services:

- Attach / detach parent
- Reorder siblings
- Delete node (policy: block if children exist vs cascade — OPEN_QUESTIONS; default **block** if any child would be orphaned *and* has no other parent; if other parents remain, only remove the edge)

### Views

| View | Reads | Writes | Owns |
|---|---|---|---|
| Tree View | Graph snapshot | Structure edits via Application | Expansion, scroll, highlight |
| Canvas | Same snapshot | Same structure APIs | Camera, zoom, **x/y per node as presentation state** |

Canvas positions:

- **Not** domain fields on `Node`.
- Store as presentation persistence: a side table `canvas_layout(node_id, x, y, updated_at)` in Data is allowed *if* treated as disposable view state (missing layout → auto-layout). Alternatively keep in-memory only for v1 (OPEN_QUESTIONS).
- Changing x/y never changes edges.

Rendering:

- **Do not** add `graphview` / `flame` / custom engine in this PRP.
- Next approved spike should compare: CustomPainter + InteractiveViewer vs a maintained graph package, against **multi-parent** (DAG) requirements. Screenshot-driven choice is invalid.

UI must not query SQLite. Both views consume an Application/Domain graph DTO.

## Alternatives considered

| Option | Verdict |
|---|---|
| Separate tree table vs canvas table as two models | Reject. Diverges. |
| Store x/y on `Node` as required domain data | Reject. Tree does not need it; restore/backup should still work if layout is missing. |
| Adopt `graphview` now | Reject. Unproven for multi-parent + RTL + large graphs; last publish age; no spike. |
| Force a strict tree (single parent) | Rejects the product rule “nodes may have multiple parents”. |

## Consequences

Positive:

- One mutation path; both views stay consistent.
- Layout can be rebuilt without migrating domain schema.

Negative:

- Tree UI of a DAG needs a defined visualization (repeat node under each parent vs unique widget with multi-links). Recommendation: **allow the same node to appear under each parent in the Tree**, identified by node id, not by path id. Path-specific UI state (expansion) is keyed by path. Confirm in OPEN_QUESTIONS.

## Facts vs recommendation

| Kind | Statement | Source |
|---|---|---|
| Fact | No graph code in the repo. | `lib/` |
| Fact | `graphview` 1.5.1 on pub.dev; not a project dependency. | pub.dev |
| Recommendation | Single DAG in Domain; canvas coords are view state; defer renderer package. | this ADR |
| Recommendation | Default: no cycles; delete edge vs delete node as specified. | this ADR |

## Follow-up (not in this task)

- Graph renderer spike after ADR approval.
- Product confirmation on cycles, tree-of-DAG display, layout persistence.
