# GemMate v1.2.1 — Voice Input Reliability on Samsung / OneUI

A focused patch release improving voice input on Samsung Galaxy / OneUI devices, where the default recognizer frequently returns an empty locale list and fails with `error_language_not_supported` even when Google Speech Services is installed.

## 🐛 Fixes

### Prefer Google Speech Services over the OEM recognizer
The plugin now initializes with `androidIntentLookup`, so it resolves the recognizer via an intent instead of the direct `SpeechRecognizer` API. On Samsung OneUI this reliably picks **Google Speech Services** over the OEM engine — the OEM engine only supports a narrow set of locales and often reports no enumerated locales at all.

### Use installed offline language packs
`SpeechListenOptions` now sets `onDevice: true`. Previously the plugin defaulted to online recognition against Google servers, which failed with `error_network` for users behind restrictive networks — even when Chinese / English offline packs were already installed on the device. Offline packs are now used directly.

### Smarter locale fallback
Previously, if the app language had no matching system locale (common on Samsung where `zh_CN` is not always enumerated), recognition would fail silently. The fallback chain is now:

1. Preferred locale list for the UI language (e.g. `zh_CN`, `cmn-Hans-CN`)
2. Any locale whose code starts with the UI language (e.g. `zh_TW` for a `zh` UI)
3. Any `en_*` locale (almost universally present)
4. The first enumerated locale on the device
5. System default (empty string)

### Actionable error messages
`error_language_not_supported` and `error_permission` now surface a Snackbar with concrete remediation steps (switch recognizer / grant mic permission) instead of failing silently.

## 📌 Known issue for mainland China users

If Google offline speech packs are not installed **and** the device cannot reach Google's servers, voice input will report `error_network`. Two workarounds:

- Install the offline language pack: *Settings → Speech Services by Google → Offline speech recognition → download Chinese (Simplified)*
- Connect to an international network

This does not affect users outside mainland China.

## 📥 Install

- **APK**: download `app-release.apk` below (Android 8.0+)
- **Source build**: `flutter pub get && flutter build apk --release`

## 🙏 Credits

Built for the **Gemma 4 Good Hackathon 2026** by [@linyeping](https://github.com/linyeping).
