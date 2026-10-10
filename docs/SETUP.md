# Shagara Linux Setup Guide

Reproducible setup for the current host class: Debian 12 amd64, Flutter stable. This document records what was verified on 2026-10-10 and what still needs approval before install.

## Already present on this host

Do **not** re-download Flutter. Official SDK is at `/opt/flutter`:

- Flutter 3.47.7 stable
- Dart 3.13.5
- Linux desktop toolchain: clang, cmake, ninja, pkg-config, GTK 3

PATH is persisted without duplicates:

```bash
if [ -d /opt/flutter/bin ]; then
  case ":$PATH:" in
    *:/opt/flutter/bin:*) ;;
    *) export PATH="/opt/flutter/bin:$PATH" ;;
  esac
  export FLUTTER_ROOT=/opt/flutter
fi
```

Applied in `/root/.zshrc`, `/root/.bashrc`, and `/root/.profile`.

Git `safe.directory` for `/opt/flutter` is set so the SDK can be used as root.

Telemetry: `flutter --disable-analytics` has been run. PRP-00 forbids embedding backend/telemetry in the app; this only disables the Flutter tool reporter.

## If Flutter is missing on a new Debian 12 machine

Use the official Linux tarball only. Do not run unverified install scripts.

Estimated disk: Flutter SDK ~2.3G extracted; tarball ~1.5G during download. Keep ~5G free before starting.

```bash
# Confirm official current stable archive name first:
# https://storage.googleapis.com/flutter_infra_release/releases/releases_linux.json

sudo mkdir -p /opt
curl -fsSL -o /tmp/flutter_linux_stable.tar.xz \
  "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.47.7-stable.tar.xz"
sudo tar -xJf /tmp/flutter_linux_stable.tar.xz -C /opt
git config --global --add safe.directory /opt/flutter
```

Linux desktop packages (official distro packages, not random binaries):

```bash
sudo apt-get update
sudo apt-get install -y clang cmake ninja-build pkg-config libgtk-3-dev liblzma-dev unzip xz-utils git curl ca-certificates libsqlite3-dev
```

Then add `/opt/flutter/bin` to PATH as above, and:

```bash
flutter --disable-analytics
flutter config --no-analytics --enable-web --enable-linux-desktop
flutter doctor -v
```

Do not overwrite an existing SDK without a backup and explicit approval.

## Project bootstrap (already done; preserve it)

The repository already contains a Flutter app named `shagara` created with:

```bash
flutter create --org com.shagara --project-name shagara \
  --platforms android,windows,web,linux \
  --description "Offline-first cross-platform student knowledge organizer" .
flutter create --platforms=ios .
```

Do **not** run `flutter create` again over this tree. It would replace unmanaged files.

Valid Dart package name: `shagara`.

Platform folders present: `android/`, `ios/`, `linux/`, `windows/`, `web/`.

iOS folder exists for architectural compatibility. iOS binaries cannot be produced on Linux.

## Dependency policy (bootstrap)

Only Flutter template dependencies are allowed at this stage:

| Package | Role | License (pub.dev) | Offline |
|---|---|---|---|
| flutter (SDK) | framework | BSD-3-Clause | yes |
| cupertino_icons ^1.0.8 | icon font | MIT | yes |
| flutter_test (SDK) | tests | BSD-3-Clause | yes |
| flutter_lints ^6.0.0 | analysis | BSD-3-Clause | yes |

`pubspec.lock` pins exact versions. Do not add Riverpod, Drift, go_router, or other product packages in bootstrap. Future packages need maintenance, license, platform, and offline review per PRP-00.

## Verification commands

From `/workspace`, with Flutter on PATH:

```bash
flutter --version
dart --version
flutter doctor -v
flutter devices
flutter pub get
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
```

Linux desktop run (when a display is available):

```bash
flutter run -d linux
```

Android debug build: **not authorized until JDK + Android SDK are installed**. Proposed later (needs approval; uses official sources only):

```bash
sudo apt-get install -y openjdk-17-jdk-headless
# Then install Android command-line tools from https://developer.android.com/studio#command-tools
# Set ANDROID_HOME, accept licenses with sdkmanager, then:
flutter config --android-sdk "$ANDROID_HOME"
flutter doctor --android-licenses
flutter build apk --debug
```

Disk estimate for a command-line Android SDK (platforms + build-tools, no Android Studio, no emulator image): several GB. Full Studio + emulator is much larger. This host has ~13G free and ~8 GiB RAM / 0 swap; approve a plan before downloading.

Web:

```bash
sudo apt-get install -y chromium
export CHROME_EXECUTABLE="$(command -v chromium)"
flutter run -d chrome
flutter build web
```

Chromium was **not** installed in this task.

## Platform limitations (facts)

- This host can develop and (given a display / headless config) build **Linux desktop**.
- **Web** source is present; run/build needs Chrome/Chromium (missing).
- **Android** source is present; SDK and JDK are missing. No Android build was run.
- **Windows** source is present. A Windows release cannot be built natively on Linux.
- **iOS** source is present. An iOS release cannot be built on Linux; use macOS + Xcode.

Do not claim a platform works without running the corresponding build or documenting the gap.

## Environment variables

| Variable | Purpose |
|---|---|
| `PATH` including `/opt/flutter/bin` | flutter/dart on PATH |
| `FLUTTER_ROOT=/opt/flutter` | optional, set by shell rc |
| `ANDROID_HOME` / `ANDROID_SDK_ROOT` | required for Android; currently unset |
| `JAVA_HOME` | required for Android; currently unset |
| `CHROME_EXECUTABLE` | required for web device; currently unset |
| `PUB_HOSTED_URL` / `FLUTTER_STORAGE_BASE_URL` | do not set unless using an approved mirror |

Do not embed API keys or secrets in the repository.

## Git

Repository is initialized on `main` with no commits. Remote `origin` is configured. This task does not create commits.

Suggested first commit after review: scaffold + this documentation only.

## What this bootstrap must not do

- Implement product features
- Add speculative pub packages
- Overwrite `/opt/flutter` or project files
- Reset git history
- Run `sudo` package installs for Android/Chrome without approval
- Download unverified scripts or random binaries
