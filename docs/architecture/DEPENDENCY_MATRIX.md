# Dependency matrix (proposed)

Status: **Proposed**. Nothing in this file is added to `pubspec.yaml` until ADRs are approved.

Current **actual** direct dependencies (scaffold only):

| Package | Constraint | Lock | License (pub.dev) | Role |
|---|---|---|---|---|
| flutter | SDK | SDK 3.47.7 | BSD-3-Clause | framework |
| cupertino_icons | ^1.0.8 | 1.0.9 | MIT | icon font |
| flutter_test | SDK | SDK | BSD-3-Clause | tests |
| flutter_lints | ^6.0.0 | (lock) | BSD-3-Clause | analyzer |

Research versions below were read from pub.dev / package docs on 2026-10-10. **They are not installed.** Pins may move before implementation; re-check licenses and platforms then.

## Proposed product stack (after approval)

| Package | Proposed constraint band | Research version | Layer | Platforms claimed by authors | Offline-safe? | License | Decision |
|---|---|---|---|---|---|---|---|
| drift | ^2.35.0 | 2.35.2 | Data | Dart; Flutter via drift_flutter | Yes (local SQLite) | MIT | **Adopt** |
| drift_dev | ^2.35.0 | 2.35.1 | Data (dev) | codegen | Yes | MIT | **Adopt** (dev) |
| drift_flutter | ^0.3.1 | 0.3.1 | Data | Android, iOS, macOS, Windows, Linux, Web (WASM) | Runtime yes; web needs WASM **assets in build** | MIT | **Adopt** |
| sqlite3 | transitive | 3.7.0 | Data | via drift_flutter | Yes | MIT | Transitive only |
| sqlite3_flutter_libs | — | 0.6.0+eol | — | — | — | MIT | **Reject** (EOL; replaced by drift_flutter) |
| flutter_riverpod | ^3.4.0 | 3.4.3 | Presentation / composition | Dart/Flutter | Yes | MIT | **Adopt** |
| go_router | ^18.0.0 | 18.0.2 | Presentation | Flutter including web | Yes | BSD-3-Clause | **Adopt** |
| uuid | ^4.6.0 | 4.6.0 | Domain or Data | Pure Dart | Yes | MIT | **Adopt** |
| file_picker | ^13.1.0 | 13.1.0 | Data adapter | Android, iOS, Web, desktop (verify at add time) | Picker is local; no cloud API | MIT | **Adopt** as adapter |
| path_provider | ^2.1.6 | 2.1.6 | Data adapter | Android, iOS, Linux, macOS, Windows; **not a web filesystem** | Yes | BSD-3-Clause | **Adopt** as adapter |
| url_launcher | ^6.3.3 | 6.3.3 | Data / Presentation adapter | All Flutter platforms | Opens OS browser; does not require our backend | BSD-3-Clause | **Adopt** for external URLs |
| archive | ^4.4.0 | 4.4.0 | Data (backup) | Pure Dart | Yes | Apache-2.0 | **Adopt** for zip backup |
| crypto | ^3.0.7 | 3.0.7 | Data | Pure Dart | Yes | BSD-3-Clause | **Adopt** for checksums |
| mime | ^2.1.0 | 2.1.0 | Data | Pure Dart | Yes | BSD-3-Clause | **Adopt** optional |
| flutter_localizations | SDK | SDK | Presentation | Flutter | Yes | BSD-3-Clause | **Adopt** with gen-l10n |
| intl | SDK-constrained | 0.20.3 typical | Presentation | Dart | Yes | BSD-3-Clause | **Adopt** (SDK pin) |
| shared_preferences | ^2.5.6 | 2.5.6 | Presentation prefs only | All; web uses HTML storage | Tiny prefs only | BSD-3-Clause | **Defer** — only if locale/theme must survive restart without Drift |
| build_runner | ^2.x | (dev) | Data (dev) | codegen | Yes | BSD-3-Clause | **Adopt** (dev) |

## Explicitly not selected

| Package | Research version | Why |
|---|---|---|
| sqflite | 2.4.4+1 | Weaker web/desktop story vs Drift; less type-safe. |
| isar | 3.1.0+1 (stable old) / 4.x-dev | Maintenance risk. |
| objectbox | 5.3.2 | Extra native engine; unused sync product. |
| hive | (not re-pinned) | Not relational; weak migrations. |
| graphview | 1.5.1 (~11 months) | Renderer **deferred to spike**; multi-parent/RTL unproven. |
| open_filex | 4.7.0 | Android/iOS only. |
| provider (v2) | — | Use Riverpod 3 instead. |
| get / getx | — | Conflicts with layering and go_router. |
| flutter_bloc | — | Not needed for v1. |
| easy_localization | — | Use gen-l10n. |
| firebase_*, http backends, analytics, sentry (cloud) | — | Product forbid unless approved. |
| sqlite3_flutter_libs | 0.6.0+eol | EOL. |

## Platform support caveats (facts vs claims)

| Topic | Fact on this host | Package claim | Action |
|---|---|---|---|
| Android minSdk | `flutter.minSdkVersion` default **24**; compile/target **36**; Java 17 | Drift/FFI typically need a modern minSdk; **re-verify when adding** | OPEN_QUESTIONS: freeze min API |
| Android build | SDK/JDK **missing**; no APK was built | N/A | Do not claim Android runtime |
| Web | Chrome/Chromium **missing**; no web run | drift_flutter uses sqlite3 WASM; OPFS/IndexedDB | Do not claim web persistence |
| Windows | Source in tree; **cannot build on Linux** | path_provider/file_picker support Windows | CI/Windows runner is an open question |
| iOS | Source in tree; **cannot build on Linux** | Architectural compatibility only | No IPA |
| Linux | Doctor Linux toolchain pass | Dev target | OK for unit tests / later desktop run |

## Offline policy

Allowed:

- Local SQLite, local files, user-initiated URL open in the system browser.
- WASM/SQLite assets **shipped in the web build**.

Not allowed without approval:

- Calling a Shagara backend.
- Analytics/crash cloud.
- Downloading SQLite WASM from a CDN at runtime.
- In-app AI network calls.

## License roll-up (research)

MIT / BSD-3-Clause / Apache-2.0 only in the proposed set. Re-check LICENSE files at add time. `archive` is Apache-2.0 — compatible with a closed app; keep NOTICE if we redistribute.

## RAM / codegen warning

This host: 7.8 GiB RAM, 0 swap, 2 CPUs. `build_runner` + Drift may need `dart run build_runner build --delete-conflicting-outputs` with no extra heavy processes. Do not start Android emulator on this box without a memory plan.

## What this matrix must not do

- Change `pubspec.yaml` or `pubspec.lock`.
- Vendor these packages into the tree in PRP-01.5.
