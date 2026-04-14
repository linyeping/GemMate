# GemMate v1.2.0 — Offline Stability & Full i18n

This release focuses on making **on-device Gemma 4 E2B** actually usable end-to-end, fixing several crashes that appeared when users ran fully offline, and closing long-standing gaps in localization.

## 🐛 Critical Fixes

### On-device model no longer crashes on long inputs
- Context window raised from **1024 → 2048 tokens** so realistic prompts (OCR text + instructions) no longer blow past the limit.
- Fixed a latent bug where the shared singleton model session was being closed after every request, corrupting the next call with `INTERNAL: Failed to invoke the compiled model`. We now close only the per-request chat, never the model.
- OCR text is capped at 3500 chars before being fed to the local model, preventing textbook-page prompts from overflowing.

### Downloaded model now loads correctly on cold start
- `flutter_gemma`'s `fromNetwork().install()` silently stores weights under a `repo/` directory and registers **the directory** as the active model path — which crashes the native engine with `Unsupported model format: .../app_flutter/repo`. GemMate now detects this after download, copies the weights to a canonical `.litertlm` path, and re-registers via `fromFile()`.
- Startup logic was hardened with a size-based fallback: if no canonical file exists, scan the app directory for any file >50 MB and recover from it. The old behavior would wrongly mark the model as uninstalled and ask the user to re-download 3 GB.

### Download mirror switched to hf-mirror.com
- The previous China mirror (`modelscope.cn/api/v1/.../repo`) was unstable on multi-GB downloads — connections were dropped by the CDN at 70–80% with `unexpected end of stream`.
- We now default to **hf-mirror.com**, a static-file CDN that supports proper HTTP range requests and resumable downloads.

## ✨ Features

### Offline flashcards & quizzes
Previously, flashcard and quiz generation required a laptop connection. They now automatically fall back to the on-device Gemma 4 E2B when offline, so students can build study materials anywhere.

### AI responses respect UI language (offline path)
The on-device model's system prompt now injects the current locale instruction on every call, so switching the UI to 中文 / 日本語 / 한국어 / Français / Español also changes the AI's reply language — matching the behavior of the online path.

## 🌍 Localization

Added **100+ missing translation keys** across Spanish, French, and Korean — including the entire Onboarding flow, Study Camera screen, Model Management page, and Hugging Face login dialog. All six locales (en / zh / ja / ko / fr / es) are now fully aligned.

## 📥 Install

- **APK**: download `app-release.apk` below (Android 8.0+)
- **Source build**: `flutter pub get && flutter build apk --release`
- **Optional on-device model** (~3 GB, enables offline mode):
  - In-app: Settings → Model Management → Download
  - Manual: `adb push gemma-4-E2B-it.litertlm /sdcard/Download/` then import in Settings

## 🙏 Credits

Built for the **Gemma 4 Good Hackathon 2026** by [@linyeping](https://github.com/linyeping).
