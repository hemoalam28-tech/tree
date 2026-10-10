# ADR-004: Navigation — go_router

- Status: **Proposed** (awaiting approval)
- Date: 2026-10-10
- Deciders: pending product/architecture review
- Tags: navigation, routing, web

## Context

Shagara targets Android, Windows, and Web (Linux for development; iOS source for compatibility). Web needs URL-addressable screens. Named routes with `Navigator.push` do not give browser history for free.

No product screens exist yet (counter demo only).

## Decision (recommendation)

Use **go_router** for declarative routes:

- Route table in Presentation.
- Paths for: shell (tree/canvas), node detail, settings, backup/restore.
- Web: path URLs (`/node/:id`), not hash-only unless a spike shows a host constraint.
- Deep links are optional later; do not add Firebase Dynamic Links or any cloud linker.

Keep `MaterialApp.router`. Do not mix ad-hoc `Navigator.push` for primary app flows.

go_router must not contain SQL or file I/O. Routes pass **IDs**, not Drift rows.

## Alternatives considered

| Option | Verdict |
|---|---|
| `Navigator` 1.0 + `routes:` map | Weak web history and typed args. |
| `auto_route` | Extra codegen; defer until go_router is proven insufficient. |
| `beamer` | Smaller community; no need. |

## Consequences

Positive:

- One routing model on mobile, desktop, and web.
- Testable with `go_router`’s test helpers.

Negative:

- Web URL persistence of canvas position should **not** be the source of truth (ADR-005). Query params for view state are optional and presentation-only.

## Facts vs recommendation

| Kind | Statement | Source |
|---|---|---|
| Fact | Current app uses `MaterialApp(home: MyHomePage(...))`. | `lib/main.dart` |
| Fact | `go_router` 18.0.2 on pub.dev at research time; not in `pubspec.yaml`. | pub.dev |
| Recommendation | Adopt go_router after approval; IDs in routes only. | this ADR |
