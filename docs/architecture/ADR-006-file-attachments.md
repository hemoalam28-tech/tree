# ADR-006: Hybrid file attachments (imported, linked, external URL)

- Status: **Proposed** (awaiting approval)
- Date: 2026-10-10
- Deciders: pending product/architecture review
- Tags: files, android-uri, storage, offline

## Context

Attachments are hybrid:

1. **Imported** — app copies bytes into app-controlled storage.
2. **Linked** — app stores a local URI or filesystem path; bytes stay outside.
3. **External URL** — app stores an https (or http) URL; open in browser / `url_launcher`. No crawl, no backend fetch-to-store unless approved.

Constraints:

- Do not store large binaries in SQLite rows.
- Android content URIs are **not** filesystem paths. `file://` and `/storage/...` are not interchangeable with `content://`.
- Web has no durable arbitrary filesystem; imported files must use web storage APIs (or download/user file picker each time). Native vs web adapters must differ.
- `open_filex` 4.7.0 is Android/iOS only — not a Windows/Linux/Web solution.

## Decision (recommendation)

### Domain

`Attachment` value object:

- `id` (UUID)
- `nodeId`
- `kind`: `imported` | `linkedLocal` | `externalUrl`
- `displayName`
- `mimeType` (optional, from picker / `package:mime` later)
- `locator`: opaque string interpreted **only in Data adapters**
  - imported: relative storage key (not a raw OS path in Domain)
  - linkedLocal: platform locator (URI or path) + platform tag
  - externalUrl: normalized URI string
- `byteLength` optional for imported
- `checksum` optional (e.g. SHA-256 via `package:crypto`) for imported integrity

Domain never opens files.

### Data adapters

| Package (proposed) | Role | Platforms |
|---|---|---|
| `file_picker` | User picks files | Android, iOS, Web, desktop (verify per version) |
| `path_provider` | App documents/support directories | IO platforms; **limited/no-op on web** |
| `url_launcher` | Open external URLs | All, with per-platform config |
| `mime` / `crypto` | Type + checksum | Pure Dart |

Do **not** put `file_picker` in Domain. Wrap in `FilePickerPort` / `LocalStorePort`.

Imported files:

- Copy into an app directory (`path_provider` application support) using a UUID filename + original extension.
- Record relative key in DB.
- Backup (ADR-008) includes those files.

Linked files:

- Store the picker result as given: on Android prefer **persistable content URI** + `takePersistableUriPermission` when the platform allows it. If permission cannot be persisted, treat as ephemeral and show a user-visible “relink needed” state — never pretend a `content://` URI is a path.
- On Windows/Linux, store the absolute path; if the file moves, mark missing.
- On Web, linked local files are generally **not durable**; v1 recommendation: **imported or external URL only on web** (OPEN_QUESTIONS).

External URLs:

- Store URL only. Opening uses `url_launcher`. Offline: show stored metadata; do not silently download.

Preview:

- Images: Flutter `Image` from imported bytes/file.
- PDF/office: **out of scope until a spike**; do not add a PDF package in this PRP.
- Missing file: explicit UI state, no crash, no silent delete of the DB row.

## Alternatives considered

| Option | Verdict |
|---|---|
| BLOBs in SQLite | Reject. Size and web WASM memory. |
| Only filesystem paths | Breaks Android URI and web. |
| `open_filex` as the only opener | Android/iOS only; skip as a cross-platform core dep. |
| Cloud object storage | Forbidden. |

## Consequences

Positive:

- Graph DB stays small.
- Platform differences isolated in Data.

Negative:

- Linked Android URIs can die after reboot/reinstall if persistable permission is missing.
- Web imported files need a dedicated store (OPFS alongside SQLite, or Drift blob **only for small web imports** — default still **no large blobs**; OPEN_QUESTIONS for web import cap).

## Facts vs recommendation

| Kind | Statement | Source |
|---|---|---|
| Fact | No file packages in `pubspec.yaml`. | scaffold |
| Fact | `file_picker` 13.1.0, `path_provider` 2.1.6, `url_launcher` 6.3.3, `mime` 2.1.0, `crypto` 3.0.7, `open_filex` 4.7.0 (Android/iOS) at research time. | pub.dev |
| Recommendation | Three kinds; adapters; no large DB blobs; Android URI ≠ path. | this ADR |
| Recommendation | Web v1: no durable linked-local files. | this ADR |

## Follow-up (not in this task)

- Android persistable URI spike (needs SDK).
- Web import size cap and OPFS file store spike (needs Chromium).
