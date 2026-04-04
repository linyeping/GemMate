<p align="center">
  <img src="assets/gemmate_logo.png" width="120" alt="GemMate Logo"/>
</p>




<h1 align="center">GemMate</h1>

<p align="center">
  <strong>Your AI Study Companion — Powered by Gemma 4</strong>
</p>

<p align="center">
  <a href="#features">Features</a> •
  <a href="#architecture">Architecture</a> •
  <a href="#demo">Demo</a> •
  <a href="#installation">Installation</a> •
  <a href="#tech-stack">Tech Stack</a> •
  <a href="#license">License</a>
</p>
<p align="center">
  <img src="https://img.shields.io/badge/Gemma_4-E2B-4361EE?style=for-the-badge&logo=google&logoColor=white" />
  <img src="https://img.shields.io/badge/Flutter-3.41-02569B?style=for-the-badge&logo=flutter&logoColor=white" />
  <img src="https://img.shields.io/badge/Dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white" />
  <img src="https://img.shields.io/badge/Ollama-Local_AI-000000?style=for-the-badge&logo=ollama&logoColor=white" />
</p>
<p align="center">
  <img src="https://img.shields.io/badge/Android-3DDC84?style=for-the-badge&logo=android&logoColor=white" />
  <img src="https://img.shields.io/badge/Privacy-Offline-9C27B0?style=for-the-badge" />
  <img src="https://img.shields.io/badge/License-Apache_2.0-green?style=for-the-badge" />
</p>


---

## 🌟 What is GemMate?

GemMate transforms how university students learn by combining **Google's Gemma 4 E2B** model with proven study science techniques. It's a cross-platform Flutter app that runs Gemma 4 **100% locally** — no cloud, no API keys, no data leaves your device.

> 💡 **The Problem:** Students struggle to create effective study materials from lectures and textbooks. Existing AI tools require cloud connectivity and raise privacy concerns.
>
> ✅ **The Solution:** GemMate runs Gemma 4 E2B on your own hardware, generating personalized flashcards, quizzes, and explanations — even on an airplane.

---

## ✨ Features

### 🧠 AI Chat with Gemma 4
Chat with Gemma 4 E2B to understand complex concepts. Ask questions in any of 6 supported languages, and get bilingual explanations tailored to your level.

<p align="center">   <img src="assets/demo1.jpg" width="350" alt="Chat Demo"/> </p>

### 📚 Smart Flashcard Decks
Generate flashcard decks from any chat conversation. Cards use the **SM-2 spaced repetition algorithm** for scientifically-optimized review schedules. Decks are displayed as beautiful fan-shaped card piles with flip animations.

<div align="center">
  <table>
    <tr>
      <td align="center"><b>Front</b></td>
      <td align="center"><b>Back</b></td>
    </tr>
    <tr>
      <td align="center"><img src="assets/demo7.jpg" width="300"/></td>
      <td align="center"><img src="assets/demo8.jpg" width="300"/></td>
    </tr>
  </table>
</div>

### 📊 Interactive Quizzes
AI-generated multiple-choice quizzes that test your understanding. Wrong answers automatically become flashcards for targeted review.

<p align="center">   <img src="assets/demo2.jpg" width="260" />   <img src="assets/demo3.jpg" width="260" />   <img src="assets/demo4.jpg" width="260" /> </p>

### 📷 Camera / OCR
Photograph textbook pages, lecture slides, or handwritten notes. Gemma 4's vision capabilities extract and explain the content.

<p align="center">   <img src="assets/demo9.jpg" width="350" alt="Chat Demo"/> </p>

### 🎤 Voice Input
Tap the microphone to ask questions by voice — perfect for hands-free studying. Supports Chinese, English, Japanese, Korean, French, and Spanish.

<p align="center">   <img src="assets/demo10.jpg" width="350" alt="Chat Demo"/> </p>

### 🌍 6 Languages
Full UI localization and AI responses in: English, 简体中文, 日本語, 한국어, Français, Español.

<p align="center">   <img src="assets/languages.jpg" width="350" alt="Chat Demo"/> </p>

### 🔔 Smart Notifications
Spaced repetition reminders, daily study prompts, and inactivity nudges keep you on track.

<p align="center">   <img src="assets/Notifications.jpg" width="350" alt="Chat Demo"/> </p>

### 🎨 Neomorphic Design
Beautiful neomorphic UI with dark/light mode, customizable accent colors, and adjustable font sizes.

<p align="center">   <img src="assets/theme.jpg" width="350" alt="Chat Demo"/> </p>

---

## 🏗️ Architecture

GemMate uses a **smart routing architecture** that automatically selects the best available AI model:

```
┌─────────────────────────────────────────────────┐
│                  📱 PHONE                       │
│             GemMate Flutter App                 │
│                                                 │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐       │
│  │   Chat   │  │  Cards   │  │   Quiz   │       │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘       │
│       │              │              │           │
│       └──────────────┼──────────────┘           │
│                      │                          │
│              ┌───────▼────────┐                 │
│              │  Smart Router  │                 │
│              └───┬────────┬───┘                 │
│                  │        │                     │
│     ┌────────────▼─┐  ┌──▼───────────────┐      │
│     │  On-Device   │  │   Ollama HTTP    │      │
│     │  Gemma 4 E2B │  │   Connection     │      │
│     │  (Offline)   │  │   (WiFi LAN)     │      │
│     └──────────────┘  └──────┬───────────┘      │
│                              │                  │
└──────────────────────────────┼──────────────────┘
                               │ WiFi (Local Network)
┌──────────────────────────────▼───────────────────┐
│                  💻 LAPTOP                        │
│           Ollama + Gemma 4 E4B                    │
│         (RTX 4060, <1s response)                 │
└──────────────────────────────────────────────────┘
```

### Smart Routing Logic

| Condition | Model Used | Latency |
|-----------|-----------|---------|
| WiFi + Laptop available | Gemma 4 E4B via Ollama (laptop GPU) | <1s |
| No WiFi, model installed | Gemma 4 E2B on-device (phone CPU) | 3-8s |
| WiFi + No laptop | Gemma 4 E2B on-device | 3-8s |
| No WiFi, no model | Prompt to download model | — |

---

## 🎬 Demo

📺 **[Watch the 3-minute demo video →](https://youtube.com/watch?v=YOUR_VIDEO_ID)**

📦 **[Download APK →](https://github.com/linyeping/GemMate/releases/tag/v1.0.0)**

---

## 🚀 Installation

### Prerequisites

- Flutter 3.41+ ([Install Flutter](https://flutter.dev/docs/get-started/install))
- Android device (Android 8.0+) or emulator
- For laptop AI: [Ollama](https://ollama.ai) + `ollama pull gemma4:e2b`

### Build from Source

```bash
# Clone the repository
git clone https://github.com/linyeping/GemMate.git
cd GemMate

# Install dependencies
flutter pub get

# Run on connected device
flutter run

# Build APK
flutter build apk --release
```

### Set Up Laptop AI (Optional, Recommended)

```bash
# Install Ollama (https://ollama.ai)
ollama pull gemma4:e2b

# Start with network access
OLLAMA_HOST=0.0.0.0:11434 ollama serve

# In GemMate Settings → Connection → Enter laptop IP
```

### Install On-Device Model (Optional, for Offline Use)

Option A: Download in-app (Settings → Model Management → Download)

Option B: Manual install via ADB:
```bash
# Download from Hugging Face mirror (China)
curl -L -o gemma-4-E2B-it.litertlm "https://hf-mirror.com/litert-community/gemma-4-E2B-it-litert-lm/resolve/main/gemma-4-E2B-it.litertlm"

# Push to phone
adb push gemma-4-E2B-it.litertlm /sdcard/Download/

# In app: Settings → Model Management → Load from /sdcard/Download/
```

---

## 🛠️ Tech Stack

| Component | Technology |
|-----------|-----------|
| **AI Model** | Gemma 4 E2B /Gemma 4 E4B |
| **On-Device Runtime** | LiteRT-LM via flutter_gemma |
| **Local Server** | Ollama (laptop, GPU-accelerated) |
| **App Framework** | Flutter 3.41 / Dart |
| **Study Algorithm** | SM-2 Spaced Repetition |
| **Voice Input** | speech_to_text |
| **OCR / Vision** | Gemma 4 multimodal (via Ollama) |
| **Notifications** | flutter_local_notifications |
| **Storage** | SharedPreferences + JSON |
| **UI Design** | Custom Neomorphic widgets |

---

## 📁 Project Structure

```
lib/
├── main.dart                    # App entry point + model initialization
├── app/
│   ├── router.dart              # Bottom navigation + page routing
│   └── theme.dart               # Neomorphic theme (light/dark)
├── core/
│   └── constants.dart           # App constants + colors
├── l10n/
│   ├── app_localizations.dart   # i18n delegate
│   └── locale_*.dart            # EN, ZH, JA, KO, FR, ES
├── models/
│   ├── chat_message.dart        # Chat message model
│   ├── chat_session.dart        # Chat session model
│   ├── flashcard.dart           # Flashcard with SM-2 fields + grouping
│   └── quiz_question.dart       # Quiz question model
├── services/
│   ├── ollama_service.dart      # HTTP client for Ollama API
│   ├── local_gemma_service.dart # On-device Gemma 4 via flutter_gemma
│   ├── smart_router.dart        # Smart model selection logic
│   ├── flashcard_generator.dart # AI-powered flashcard creation
│   ├── quiz_generator.dart      # AI-powered quiz generation
│   ├── model_download_service.dart # Model download + mirror support
│   └── notification_service.dart   # Study reminders
├── stores/
│   ├── chat_store.dart          # Chat session persistence
│   ├── flashcard_store.dart     # Flashcard persistence + groups
│   ├── connection_store.dart    # Connection state management
│   ├── locale_store.dart        # Language preferences
│   └── theme_store.dart         # Theme + font size preferences
├── screens/
│   ├── chat_screen.dart         # Main chat UI + voice input
│   ├── chat_history_screen.dart # Chat session management
│   ├── flashcard_screen.dart    # Deck gallery with fan piles
│   ├── deck_study_screen.dart   # Card flip study session
│   ├── quiz_screen.dart         # Interactive quiz
│   ├── capture_screen.dart      # Camera / OCR
│   ├── settings_screen.dart     # Settings with sub-pages
│   └── onboarding_screen.dart   # First-launch setup + model download
└── widgets/
    ├── neumorphic_container.dart # Neomorphic card widget
    ├── neumorphic_button.dart   # Neomorphic button widget
    ├── message_bubble.dart      # Chat message bubble
    ├── flashcard_widget.dart    # Individual flashcard
    ├── connection_indicator.dart # Connection status pill
    └── model_badge.dart         # Model source badge
```

---

## 🏆 Competition Tracks

This project is submitted to the **Gemma 4 Good Hackathon** on Kaggle:

| Track | How GemMate Qualifies |
|-------|------------------------|
| **Main Track** | Full-featured study app powered by Gemma 4 E2B / Gemma 4 E4B |
| **Future of Education** | AI-powered flashcards, quizzes, and personalized explanations |
| **Ollama Special** | Smart routing between on-device and Ollama-served Gemma 4 |

---

## 👤 About the Developer

AI major at Gansu Political Science and Law University in China. Solo developer.

Previous Projects: **InSeeVision** (Gemma 3 accessibility project).

- GitHub: [@linyeping](https://github.com/linyeping)
- Kaggle: [linyeping](https://kaggle.com/linyeping)

---

## 📄 License

This project is licensed under the Apache License 2.0 — see the [LICENSE](LICENSE) file for details.

The Gemma 4 model is provided by Google under the [Gemma Terms of Use](https://ai.google.dev/gemma/terms).

---

<p align="center">
  <strong>Built with ❤️ for the Gemma 4 Good Hackathon 2026</strong><br/>
  <strong>Contact: yepinglin20@gmail.com | 201180946@qq.com</strong>
</p>
