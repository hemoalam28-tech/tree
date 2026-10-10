# Architecture (PRP-01.5)

Proposed ADRs for Shagara. **Not implemented.** Do not add packages or feature code until these are approved.

| Doc | Topic |
|---|---|
| ADR-001-modular-monolith.md | Layers: Presentation → Application → Domain ← Data |
| ADR-002-persistence-drift.md | Drift + SQLite; web via sqlite3 WASM |
| ADR-003-state-management-riverpod.md | Riverpod 3; Material 3 |
| ADR-004-navigation-go-router.md | go_router |
| ADR-005-graph-model-and-views.md | One DAG; Tree + Canvas; defer renderer |
| ADR-006-file-attachments.md | Imported / linked / URL; no large blobs |
| ADR-007-localization-rtl.md | gen-l10n, en/ar, RTL |
| ADR-008-backup-restore-migrations.md | Manual versioned zip |
| DEPENDENCY_MATRIX.md | Proposed vs rejected packages (not in pubspec) |
| OPEN_QUESTIONS.md | Decisions still needed |

Facts vs recommendations are labeled inside each ADR. Host limits: `docs/ENVIRONMENT.md`.
