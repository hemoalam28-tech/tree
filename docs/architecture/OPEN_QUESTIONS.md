# Open questions (PRP-01.5)

These block or shape implementation. ADRs state a **default recommendation** where one exists. Product/engineering must confirm.

## P0 — need an answer before first persistence/feature PRP

| ID | Question | Default if unanswered | Why it matters |
|---|---|---|---|
| Q1 | Android **minSdk** freeze: keep Flutter default 24, or raise for FFI/SQLite/file_picker? | Keep `flutter.minSdkVersion` (24) until a package forces a raise; document the raise in an ADR amendment. | Cannot verify here (no Android SDK). |
| Q2 | May we install **OpenJDK 17 + Android command-line tools** on this host? | No install until explicit approval. | Disk ~several GB; 8 GiB RAM / 0 swap. |
| Q3 | May we install **Chromium** and set `CHROME_EXECUTABLE`? | No until approval. | Required to prove web Drift WASM / OPFS. |
| Q4 | Web persistence policy: is web a **full peer** (durable library) or a **viewer/demo** with eviction risk? | Treat web as **best-effort**. Show a first-run warning that the browser may delete data. Native remains source of truth via backup zip. | OPFS/IndexedDB eviction, private mode, quotas. |
| Q5 | Graph **cycles**: forbid, or allow with detection? | **Forbid** on write (ADR-005). | Affects Domain invariants and Tree rendering. |
| Q6 | Tree visualization of multi-parent nodes: repeat node under each parent, or unique row with many lines? | **Repeat under each parent**; identity is node UUID. | UX + selection model. |
| Q7 | Delete policy when a node has children. | Delete **edge** always; delete **node** only if it would not orphan a child that has no remaining parent — then **block** with a message (no silent cascade). | Data loss. |
| Q8 | Persist canvas x/y across sessions? | **Yes**, disposable side table; missing layout → auto-layout. Not part of Domain node. | Schema + backup size. |

## P1 — needed before file/backup features

| ID | Question | Default | Notes |
|---|---|---|---|
| Q9 | Web **linked local** files? | **Unsupported on web** (imported or external URL only). | Browsers do not give durable paths. |
| Q10 | Imported file **size cap** (native / web)? | Native: warn above 50 MiB, do not hard-fail until measured. Web: hard cap **TBD** (suggest 5–10 MiB) because of memory/WASM. | No blobs in SQLite rows regardless. |
| Q11 | In-app **PDF/office preview** vs OS open? | **OS open / no preview** in v1. | Avoid extra packages. |
| Q12 | Android persistable `content://` permissions: required for linked files? | Yes when the platform grants them; otherwise mark **relink needed**. | Needs SDK to spike. |
| Q13 | Backup **encryption**? | **No** in v1. | If yes later: user-held passphrase, local only. |
| Q14 | Backup format: zip+sqlite (ADR-008) vs JSON export? | **zip+sqlite**. JSON later if interop is requested. | |
| Q15 | Include canvas layout in backup? | **Yes**, optional file; restore without it is valid. | |

## P2 — platform / process

| ID | Question | Default | Notes |
|---|---|---|---|
| Q16 | Windows **CI runner** for release installers? | Not on this Linux host. Need GitHub Actions `windows-latest` or a Windows machine. | Do not claim Windows binaries. |
| Q17 | iOS / macOS: keep folder only, or also target TestFlight later? | **Architectural compatibility only** until a Mac is available. | |
| Q18 | Locale default for first launch? | Follow OS; if neither `ar` nor `en`, **en**. | ADR-007 |
| Q19 | Should `shared_preferences` store locale/theme, or Drift? | Drift settings table **or** in-memory until settings screen. Prefer one store (Drift) once DB exists. | Avoid two sources of truth. |
| Q20 | Graph renderer after spike: custom vs package? | **Spike required**; `graphview` is not pre-selected. | ADR-005 |
| Q21 | Allow nodes as DAG with **ordered** edges only, or also weighted/typed edges? | **Ordered** (`ordinal` on edge) only in v1. | |
| Q22 | Conflict if restore onto a DB that already has data: replace vs merge? | **Replace after confirm** (destructive, explicit). No silent merge. | ADR-008 |
| Q23 | Root user / Flutter-as-root warning on this host: ignore? | Ignore for this container; do not document running as root as a user instruction in SETUP beyond the existing note. | `docs/ENVIRONMENT.md` |

## Resolved by ADRs (do not re-litigate without amending)

- Modular monolith, four layers (ADR-001).
- Drift + drift_flutter, not sqflite/Isar/ObjectBox (ADR-002).
- Riverpod 3 (ADR-003).
- go_router (ADR-004).
- One graph, canvas coords are view state (ADR-005).
- Hybrid files, no large DB blobs, Android URI ≠ path (ADR-006).
- gen-l10n en/ar (ADR-007).
- Manual versioned zip backup (ADR-008).
- No backend, telemetry, cloud, or in-app AI without new approval.

## Evidence gaps (cannot close on this host)

1. No Android SDK/JDK — minSdk, URI permissions, file_picker Android behavior unverified.
2. No Chrome — wasm sqlite, OPFS, web file picker, storage eviction unverified.
3. No Windows — path lengths, file associations unverified.
4. No iOS — folder exists only.
5. Drift codegen not run — generator RAM cost estimated, not measured on this box.

## How to answer

Reply with `Q# = decision`. After that, a later PRP may add packages and code. Until then, `pubspec.yaml` stays scaffold-only.
