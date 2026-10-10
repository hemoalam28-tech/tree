# ADR-001: Modular monolith and layer boundaries

- Status: **Proposed** (awaiting approval)
- Date: 2026-10-10
- Deciders: pending product/architecture review
- Tags: architecture, layering, testability

## Context

Shagara is an offline-first Flutter/Dart knowledge organizer. Product rules forbid a backend, telemetry, cloud accounts, and in-app AI unless explicitly approved. The current tree is the Flutter counter scaffold only (`lib/main.dart`, `test/widget_test.dart`). PRP-01.5 must freeze architecture before packages or feature code are added.

The app must stay testable: domain logic cannot be trapped in widgets or SQL. Tree View and Canvas must share one graph model. UI must not run raw database queries.

## Decision (recommendation)

Use a **modular monolith** in a single Dart package (`shagara`), not microservices and not a plugin-per-feature repo.

Layers and allowed dependencies:

```
Presentation  -->  Application  -->  Domain  <--  Data
```

| Layer | Owns | May import | Must not import |
|---|---|---|---|
| `lib/domain/` | Entities, value objects, graph model, repository *interfaces*, domain errors | Dart core only | Flutter widgets, Drift, file plugins, graph UI packages, Riverpod, go_router |
| `lib/application/` | Use cases / application services, orchestration, transaction boundaries | Domain | Widgets, Drift tables, platform plugins |
| `lib/data/` | Drift schema, DAOs, file/URI adapters, repository *implementations* | Domain, persistence/file packages | Widgets |
| `lib/presentation/` | Screens, widgets, theming, Riverpod UI bindings, go_router | Application, Domain, Flutter | Drift, raw SQL, `package:sqlite3` |

Rules:

1. Presentation talks to Application (or Domain types), never to DAOs.
2. Data implements Domain repository interfaces. Mapping Drift rows to domain entities happens in Data.
3. Canvas coordinates, expansion state, and selection are **presentation state**, not domain fields (see ADR-005).
4. Feature folders may exist *inside* a layer (`presentation/tree/`, `data/graph/`) but a feature must not become a circle of imports across layers.
5. Keep the current package name `shagara` and the existing platform folders. Do not `flutter create` over this tree.

Suggested (not created in this task) layout:

```
lib/
  domain/
  application/
  data/
  presentation/
  main.dart          # composition root only
```

`main.dart` wires implementations (ProviderScope, database, routers). That is the only place allowed to see both Presentation and Data.

## Alternatives considered

| Option | Why not now |
|---|---|
| Clean architecture with many packages (`shagara_domain`, `shagara_data`, …) | Extra publish/path overhead before any feature exists. Can extract later if needed. |
| MVC / “everything in widgets” | Domain and SQL leak into UI; hard to unit test; forbids the “no raw DB in UI” rule. |
| Plugin-per-platform apps | Duplicates the graph model; contradicts one-codebase Android/Windows/Web. |
| Backend + sync | Forbidden by product rules. |

## Consequences

Positive:

- Domain tests run with `dart test` / `flutter test` without a device or SQLite.
- Persistence and file APIs can change without rewriting Tree/Canvas widgets.
- Graph algorithms (cycle checks, multi-parent attachment) live in Domain.

Negative:

- More files than the counter scaffold.
- Reviewers must enforce import rules (analyzer `implementation_imports` / custom lint later; not added in this task).

## Facts vs recommendation

| Kind | Statement | Source |
|---|---|---|
| Fact | Repo is one Flutter package `shagara`, SDK `^3.13.5`, `publish_to: none`. | `pubspec.yaml` |
| Fact | Only `lib/main.dart` exists; no layers yet. | tree listing |
| Fact | Platforms on disk: android, ios, linux, windows, web. | scaffold |
| Recommendation | Modular monolith with the four layers above. | this ADR |
| Recommendation | Do not split into multiple pub packages until a concrete reuse need appears. | this ADR |

## Follow-up (not in this task)

- Add `import` lint or `package:import_lint` only after this ADR is approved.
- Replace the counter `main.dart` only in a later PRP.
