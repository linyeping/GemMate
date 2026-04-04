# StudyAgent

AI-powered study companion with smart model routing.

## Project Features
- **Smart Routing**: Automatically decides between on-device Gemma (E2B) and laptop-hosted Gemma (E4B via Ollama) based on task complexity and connectivity.
- **Study Tools**: Create flashcards, quizzes, summaries, and translations.
- **Agentic Function Calling**: Uses LLM to decide which tool to use for a given prompt.
- **Modes**: Capture/OCR, Paper Analysis, Flashcard Review (Spaced Repetition), and Chat.

## Tech Stack
- **Flutter**
- **Ollama** (Gemma 4 E4B on laptop)
- **flutter_gemma** (Gemma 3n E2B on device)
- **Connectivity Plus** for smart routing
- **HTTP** for remote model calls
