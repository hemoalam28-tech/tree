# Shagara (شجرة)

Offline-first, cross-platform student knowledge organizer.

This repository currently contains the Flutter application scaffold required by PRP-00 / PRP-01. Product features are not implemented yet.

## Status

- Package name: `shagara`
- Flutter 3.47.7 stable / Dart 3.13.5
- Platforms in tree: Android, Windows, Web, Linux, iOS (iOS is architectural compatibility only)
- Persistence: none yet (no backend, no telemetry)
- Localization, graph, storage, and backup: not in this bootstrap

See:

- `docs/ENVIRONMENT.md` — host inspection, doctor output, missing tools
- `docs/SETUP.md` — reproducible Linux setup and verification commands
- `docs/architecture/` — PRP-01.5 proposed ADRs, dependency matrix, open questions (not implemented; awaiting approval)
- PRP-00 product rules remain in force for later tasks

## Host facts (Linux)

This development host is Debian 12 amd64.

Can be verified here today:

- Flutter/Dart toolchain
- Linux desktop toolchain (`flutter doctor` Linux section)
- `flutter pub get`, `dart format`, `flutter analyze`, `flutter test`

Cannot be claimed on this host without more tooling:

- Android APK/AAB (no Android SDK, no JDK)
- Web run via Chrome (Chrome/Chromium not installed)
- Windows installer (needs a Windows build environment or CI runner)
- iOS IPA (needs macOS and Xcode)

## Verify

```bash
flutter --version
dart --version
flutter doctor -v
flutter pub get
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
```

The only automated test in the empty scaffold is `test/widget_test.dart`, which exercises the default counter sample.

## Dependencies

Direct:

- `flutter` (SDK)
- `cupertino_icons`

Dev:

- `flutter_test` (SDK)
- `flutter_lints`

Versions are pinned in `pubspec.lock`. Do not add the future product stack during bootstrap.

## License / privacy

Core operation must remain offline. Do not add a backend, analytics, or cloud dependency without explicit approval.
