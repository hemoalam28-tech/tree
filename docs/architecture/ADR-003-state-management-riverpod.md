# ADR-003: State management — Riverpod 3

- Status: **Proposed** (awaiting approval)
- Date: 2026-10-10
- Deciders: pending product/architecture review
- Tags: state, riverpod, presentation

## Context

The UI will have Tree View, Canvas, editors, and async load/save. Flutter’s default is `setState` (current counter sample). We need:

- Testable state without pumping every widget.
- No global singletons that hide the database.
- Domain remaining free of Flutter.

## Decision (recommendation)

Use **Riverpod 3** (`flutter_riverpod`) as the presentation/application binding:

- `ProviderScope` in `main.dart` (composition root).
- Notifiers / `AsyncNotifier` in Presentation (and thin Application facades if needed).
- Repository implementations injected via Riverpod *in Presentation/composition only*.
- Domain classes stay plain Dart. **Do not** import Riverpod in `lib/domain/`.

Do not use `provider` (v2 package), `GetX`, `Bloc`, or `MobX` unless this ADR is reversed.

UI kit: **Flutter Material 3** (`uses-material-design: true` already in `pubspec.yaml`). No extra widget library in v1.

## Alternatives considered

| Option | Verdict | Why |
|---|---|---|
| `setState` / InheritedWidget only | Reject for app state | Does not scale to graph + files + locale. Fine for tiny local widget state (text fields). |
| `provider` | Reject | Riverpod is the maintained successor pattern; avoid two DI styles. |
| `flutter_bloc` | Reject for v1 | More boilerplate; no stronger fit for local-only graph. |
| GetX | Reject | Magic routing/DI conflicts with go_router and layer rules. |

## Consequences

Positive:

- Overrides in tests (`ProviderScope` overrides) for fake repositories.
- Async loading/error/empty is uniform.

Negative:

- Riverpod 3 has breaking changes vs 2.x; pin a 3.x line in the matrix and do not mix examples from 2.x docs.
- Over-use of providers can leak Data types into widgets — import rules from ADR-001 still apply.

## Facts vs recommendation

| Kind | Statement | Source |
|---|---|---|
| Fact | App state today is `_counter` in `MyHomePage`. | `lib/main.dart` |
| Fact | `flutter_riverpod` 3.4.3 on pub.dev at research time; not in `pubspec.yaml`. | pub.dev |
| Recommendation | Riverpod 3 for UI/app binding; Material 3 widgets; domain stays Riverpod-free. | this ADR |

## Follow-up (not in this task)

- Add `flutter_riverpod` only after approval.
- Widget tests should override repositories; do not hit Drift from Presentation tests.
