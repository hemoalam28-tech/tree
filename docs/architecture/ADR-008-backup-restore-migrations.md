# ADR-008: Manual versioned backup / restore and migrations

- Status: **Proposed** (awaiting approval)
- Date: 2026-10-10
- Deciders: pending product/architecture review
- Tags: backup, restore, migrations, privacy

## Context

Core operation is offline. Backup/restore must be **manual and versioned**. No silent cloud sync. No telemetry. Migrations must be explicit (ADR-002). Restores must not silently drop user data.

## Decision (recommendation)

### Backup artifact

A single user-visible archive (zip), produced on demand:

```
shagara-backup/
  manifest.json
  db.sqlite            # consistent snapshot (checkpoint WAL first)
  files/               # imported attachment bytes keyed as in DB
  canvas_layout.json   # optional view state
```

`manifest.json` (conceptual):

- `formatVersion` (integer, backup format, independent of Drift schema)
- `schemaVersion` (Drift schema version)
- `appVersion` (from `pubspec` version)
- `createdAt` (UTC ISO-8601)
- `platform` (android/windows/web/linux/ios)
- `checksums` (manifest lists SHA-256 of db and files)

Use `package:archive` for zip. User picks destination via `file_picker` / share sheet / desktop save dialog.

### Restore

1. User picks a zip.
2. Read `formatVersion`. Unknown **newer** format → **abort** with an explanation (do not partial-apply).
3. Older format → run documented backup-format migrations **or** open sqlite and run Drift migrations after replace.
4. Replace is transactional at the app level: write to a temp directory, verify checksums, then swap. On failure, keep the previous data.
5. Never `DROP TABLE` as a recovery strategy in release.
6. Linked-local files are **not** inside the zip (they never were app-owned). After restore, mark missing if the path/URI is dead. External URLs restore as strings.
7. Web: backup/download is a user file download; restore is a user file pick. Quota may fail; surface the error.

### Encryption

**Not in v1** unless product requires it (OPEN_QUESTIONS). If added later, it must be user-held key, local only — no cloud KMS.

### What backup is not

- Not automatic Google Drive / iCloud.
- Not git.
- Not unencrypted upload anywhere.

## Alternatives considered

| Option | Verdict |
|---|---|
| Copy the raw DB file only | Misses imported files and WAL; incomplete. |
| JSON dump of all tables | Possible later for interop; v1 zip+sqlite is simpler and preserves indexes. |
| Continuous sync | Forbidden. |

## Consequences

Positive:

- User can move a library between devices they control.
- Schema version is visible in the artifact.

Negative:

- Zip size follows imported files.
- Cross-platform restore of **linked** paths often fails (expected); UX must say so.
- Web quotas and memory when zipping.

## Facts vs recommendation

| Kind | Statement | Source |
|---|---|---|
| Fact | No backup code. | repo |
| Fact | `archive` 4.4.0 on pub.dev at research time. | pub.dev |
| Recommendation | Manual zip + manifest + checksums; abort on newer format; no silent data loss. | this ADR |
| Recommendation | Encryption deferred. | this ADR |

## Follow-up (not in this task)

- Define `formatVersion` 1 schema in implementation PRP.
- Restore tests with old schema fixtures.
