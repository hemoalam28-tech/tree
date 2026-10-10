# ADR-002: Persistence — Drift + SQLite (native and web WASM)

- Status: **Proposed** (awaiting approval)
- Date: 2026-10-10
- Deciders: pending product/architecture review
- Tags: persistence, sqlite, drift, web, migrations

## Context

Shagara must store a knowledge graph and node metadata **on device**, with explicit schema migrations and stable IDs. Large file binaries must not live in database rows (ADR-006). There is no server.

The Flutter SDK on this host is 3.47.7 / Dart 3.13.5. Linux has `libsqlite3` 3.40.1. Android SDK and Chrome are **not** installed, so Android/web persistence cannot be executed here today.

## Decision (recommendation)

Use **Drift** as the type-safe Dart layer over **SQLite**:

| Package | Proposed role | Do not add until approved |
|---|---|---|
| `drift` | Schema, queries, migrations | yes |
| `drift_dev` + `build_runner` (dev) | Codegen | yes |
| `drift_flutter` | Official Flutter opener: native FFI SQLite on IO, **sqlite3 WASM** on web | yes |
| `sqlite3` (transitive) | Dart bindings | via drift_flutter |
| `uuid` | Stable public IDs (text primary keys) | yes |

Do **not** depend on `sqlite3_flutter_libs` as a direct package. Pub.dev marks `sqlite3_flutter_libs` **0.6.0+eol** (end-of-life). `drift_flutter` is the supported replacement for bundling SQLite.

IDs: store **stable string UUIDs** (v4 or v7) as primary keys. Never reuse IDs. Integer rowids may exist internally but must not be the public identity in backups or graph edges.

Migrations: **explicit, versioned Drift migrations only**. No `onUpgrade` that drops user tables. No silent destructive fallback in release. Schema version is part of backup metadata (ADR-008).

Web: persist with Drift’s web backend (sqlite3 WASM + OPFS where available, IndexedDB fallback). Bundle WASM/worker assets in the app; do not fetch SQLite WASM from a CDN at runtime (that would break true offline after first load). Document that **browser storage can be evicted** and is not equivalent to a native file.

Blobs: metadata and paths/URIs only. No PDF/image bytes in SQLite rows.

Web vs native is **not** the same persistence guarantee. See OPEN_QUESTIONS.md.

## Alternatives considered

| Option | Verdict | Notes (pub.dev / docs, not installed) |
|---|---|---|
| **sqflite** 2.4.4+1 | Reject for new code | Android/iOS/macOS oriented; web is not first-class; less type-safe than Drift. |
| **Isar** 3.1.0+1 / 4.x-dev | Reject | 3.x last stable ~3 years; 4.x still dev. Risk for a new app. |
| **ObjectBox** 5.3.2 | Reject | Extra native lib; license/sync product surface we do not need; web story differs. |
| **Hive / shared_preferences** | Reject as graph store | No relational queries, weak migrations. `shared_preferences` 2.5.6 may be used later only for tiny UI prefs, not the graph. |
| Raw `sqlite3` + SQL strings | Reject | Drift gives migrations, types, and test in-memory DBs. |
| JSON files only | Reject | Poor query/index story for a graph with many edges and attachments. |

## Consequences

Positive:

- One query API on Android, Linux, Windows, and Web.
- In-memory Drift database for Data-layer tests without Android.
- Migrations are code-reviewed artifacts.

Negative:

- `build_runner` + Drift codegen is RAM-heavy on this 8 GiB / 0-swap host.
- Web: WASM size, OPFS/IndexedDB quotas, private-mode failures.
- First-run web still needs the WASM asset present in the build (offline *runtime*, not “zero-byte first paint without assets”).

## Facts vs recommendation

| Kind | Statement | Source |
|---|---|---|
| Fact | No persistence code or extra packages exist in the scaffold. | `pubspec.yaml` |
| Fact | Host has `libsqlite3-0` / `libsqlite3-dev` 3.40.1. | `docs/ENVIRONMENT.md` |
| Fact | `drift` 2.35.2, `drift_dev` 2.35.1, `drift_flutter` 0.3.1, `sqlite3` 3.7.0 listed on pub.dev at research time. | pub.dev |
| Fact | `sqlite3_flutter_libs` 0.6.0+eol. | pub.dev |
| Fact | Chrome/Chromium missing; web persistence unverified on this host. | `flutter doctor` |
| Recommendation | Drift + `drift_flutter`; UUID string PKs; explicit migrations; no blobs in rows. | this ADR |
| Recommendation | Do not treat web OPFS/IndexedDB as durable as a native SQLite file. | this ADR |

## Follow-up (not in this task)

- After approval: add packages, generate the first schema, write a migration test that refuses destructive upgrades.
- Spike web: OPFS availability, private window, storage eviction messaging (OPEN_QUESTIONS).
