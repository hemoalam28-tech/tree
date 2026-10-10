# ADR-007: Localization — gen-l10n, Arabic and English, RTL/LTR

- Status: **Proposed** (awaiting approval)
- Date: 2026-10-10
- Deciders: pending product/architecture review
- Tags: l10n, i18n, rtl, arabic

## Context

The product name is Shagara (شجرة). UI must support **Arabic and English**, including RTL/LTR layout. The scaffold has no `l10n.yaml` and does not yet depend on `flutter_localizations`.

Flutter’s first-party solution is **gen-l10n** (`flutter: generate: true`, ARB files, `flutter_localizations` + `intl`).

## Decision (recommendation)

- Add `flutter_localizations` (SDK) and `intl` when implementation starts.
- ARB files: `lib/l10n/app_en.arb`, `lib/l10n/app_ar.arb`.
- Template locale: `en`. Default device locale: follow OS; fallback `en`.
- `MaterialApp.router` gets `localizationsDelegates`, `supportedLocales: [Locale('en'), Locale('ar')]`.
- Use `Directionality` from locale (Material does this). Do not hard-code `TextDirection.ltr`.
- Canvas/Tree custom painters must honor `Directionality` (mirroring of chrome, not necessarily of user-placed node x).
- User-generated content (node titles) is stored as Unicode; **do not** reverse strings in the database.
- Language switch is a presentation setting (Riverpod + optional prefs). Graph data is language-agnostic.

ICU/plural/select in ARB for counts. No third-party i18n framework (`easy_localization`, `slang`) in v1.

## Alternatives considered

| Option | Verdict |
|---|---|
| Hard-coded English strings | Reject. |
| `easy_localization` | Extra package; gen-l10n is SDK. |
| Separate Arabic fork of the app | Reject. |

## Consequences

Positive:

- Official Flutter toolchain; analyzer-friendly generated `AppLocalizations`.

Negative:

- Custom graph layout RTL needs a spike (OPEN_QUESTIONS).
- `intl` version is constrained by the Flutter SDK pin.

## Facts vs recommendation

| Kind | Statement | Source |
|---|---|---|
| Fact | No l10n config in the scaffold. | `pubspec.yaml`, `lib/` |
| Fact | `intl` 0.20.3 typical with current Flutter; exact pin comes from SDK when added. | pub.dev / Flutter SDK |
| Recommendation | gen-l10n + Material RTL; ARB en/ar; no extra i18n package. | this ADR |
