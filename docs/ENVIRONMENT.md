# Shagara Environment Report

Recorded: 2026-10-10. Host: Linux container. Values below are from commands run on this host, not assumptions.

## Host

| Item | Value |
|---|---|
| Distribution | Debian GNU/Linux 12 (bookworm) |
| Kernel | 6.6.116 x86_64 SMP |
| Architecture | x86_64 / amd64 |
| User | uid=0(root) |
| CPU | 2 processors (`nproc`) |
| Memory | 7.8 GiB RAM, 0 swap |
| Disk | `/dev/root` 20G total, ~13G free at inspection |

## Version control

| Item | Value |
|---|---|
| Git | 2.39.5 |
| Repository | `/workspace` is a git work tree |
| Branch | `main` |
| Commits | none (`fatal: your current branch 'main' does not have any commits yet`) |
| Remote | `origin` = `https://github.com/hemoalam28-tech/tree` |
| Work tree | untracked Flutter scaffold files present; no staged files |

History was not reset. No commit was created by this task.

## Flutter / Dart

| Item | Value |
|---|---|
| Flutter binary | `/opt/flutter/bin/flutter` |
| Dart binary | `/opt/flutter/bin/dart` |
| Flutter | 3.47.7, channel `stable` |
| Framework | revision `abaf9c5237` (2026-10-08) |
| Engine | `deb287481e` |
| Dart | 3.13.5 (stable, 2026-09-29) linux_x64 |
| DevTools | 2.60.0 |
| Analytics | disabled (`flutter config` reported analytics reporting disabled) |
| Enabled features | web, linux-desktop (also android/ios/windows/macos flags default on) |
| Login PATH | `/opt/flutter/bin` was **not** on PATH until this bootstrap (`which flutter` failed in a clean login). PATH is now persisted in `/root/.zshrc`, `/root/.bashrc`, and `/root/.profile` with a duplicate-entry guard. |

SDK source: official `https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.47.7-stable.tar.xz`.

## Linux desktop toolchain

Present:

- clang 14.0.6
- cmake 3.25.1
- ninja 1.11.1
- pkg-config 1.8.1
- libgtk-3-dev 3.24.38
- libsqlite3-0 / libsqlite3-dev 3.40.1

`flutter doctor` Linux toolchain: pass, with warning: `eglinfo` unavailable (`mesa-utils` not installed). Connected device: `Linux (desktop) • linux • linux-x64`.

## Android

Not available.

- `java` not on PATH; `/usr/lib/jvm` empty
- `ANDROID_HOME` / `ANDROID_SDK_ROOT` unset
- `adb` / `sdkmanager` not found
- `flutter doctor`: `Unable to locate Android SDK`

Android debug builds were **not** attempted.

Debian packages that exist but were **not** installed by this task: `openjdk-17-jdk`, `openjdk-17-jdk-headless`.

## Web / Chrome

Not available.

- `google-chrome`, `chromium`, `firefox` not on PATH
- `flutter doctor`: `Cannot find Chrome executable at google-chrome`
- `CHROME_EXECUTABLE` unset

Web device was not listed by `flutter devices`. Web builds were **not** executed.

Debian package `chromium` exists in apt but was **not** installed by this task.

## Windows / iOS / macOS

| Target | Host capability |
|---|---|
| Windows release | Cannot be built natively on this Linux host. Needs a Windows machine or Windows CI runner. |
| iOS release | Cannot be built on Linux. Needs macOS + Xcode. |
| macOS desktop | Cannot be built on Linux. |

Project folders `windows/` and `ios/` exist for architectural compatibility only.

## Editor

VS Code / Codium not installed. No Flutter/Dart editor extensions detected on this host. Flutter's own test fixtures under `/opt/flutter/.../vscode*` are not user extensions.

## Other tools

Present: curl, wget, git, unzip, xz, tar, python3 3.11.2, node v22.22.0.

Disk usage at inspection: `/opt/flutter` ~2.3G, `/workspace` ~1.1M.

## Existing project (preserved)

A Flutter app named `shagara` already existed. This task did **not** replace it.

- Package: `shagara` (`pubspec.yaml`)
- Description: Offline-first cross-platform student knowledge organizer
- Version: 1.0.0+1
- SDK constraint: `^3.13.5`
- Platforms on disk: android, ios, linux, windows, web
- Application entry: `lib/main.dart` (default counter sample)
- Tests: `test/widget_test.dart` (default counter smoke test)
- Direct dependencies: `flutter` SDK, `cupertino_icons` ^1.0.8 (lockfile 1.0.9)
- Direct dev dependencies: `flutter_test` SDK, `flutter_lints` ^6.0.0
- `publish_to: none`

No product features, graph code, persistence, or extra packages were added in this bootstrap.

## Doctor summary (actual)

```
[✓] Flutter (Channel stable, 3.47.7, on Debian GNU/Linux 12 (bookworm) 6.6.116, locale C.UTF-8)
[✗] Android toolchain - develop for Android devices
    ✗ Unable to locate Android SDK.
[✗] Chrome - develop for the web (Cannot find Chrome executable at google-chrome)
[✓] Linux toolchain - develop for Linux desktop
    ! Unable to access driver information using 'eglinfo'.
[✓] Connected device (1 available)  Linux (desktop)
[✓] Network resources

Doctor found issues in 2 categories.
```

## Missing prerequisites (unresolved)

1. Android SDK + cmdline-tools + platform-tools + a compatible JDK (OpenJDK 17 is available in apt, not installed).
2. Chrome or Chromium, or `CHROME_EXECUTABLE` pointing at a Chromium binary (needed for `flutter run -d chrome` / web integration tests).
3. Optional: `mesa-utils` for `eglinfo` (doctor warning only).
4. Windows build host or CI runner (cannot produce Windows installers here).
5. macOS + Xcode (cannot produce iOS/macOS binaries here).
6. Physical Android device or emulator (SDK missing).
7. VS Code / Dart-Code extensions (optional).

## Safety notes for this host

- Process runs as root. Flutter prints a non-fatal warning.
- RAM is tight (~8 GiB, no swap). Large Android SDK + emulator installs need a disk/memory plan before proceeding.
- Do not overwrite `/opt/flutter` without approval. Do not run `git clean`, history rewrites, or broad cleanup.
