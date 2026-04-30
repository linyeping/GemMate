<p align="center">
  <img src="assets/gemmate_logo.png" width="120" alt="Logo de GemMate"/>
</p>




<h1 align="center">GemMate</h1>

<p align="center">
  <strong>Tu compañero de estudio con IA — Impulsado por Gemma 4</strong>
</p>

<p align="center">
  <a href="#características">Características</a> •
  <a href="#arquitectura">Arquitectura</a> •
  <a href="#demo">Demo</a> •
  <a href="#instalación">Instalación</a> •
  <a href="#stack-tecnológico">Stack Tecnológico</a> •
  <a href="#licencia">Licencia</a>
</p>
<p align="center">
  <img src="https://img.shields.io/badge/version-1.3.0-brightgreen?style=for-the-badge" />
  <img src="https://img.shields.io/badge/Gemma_4-E2B-4361EE?style=for-the-badge&logo=google&logoColor=white" />
  <img src="https://img.shields.io/badge/Flutter-3.41-02569B?style=for-the-badge&logo=flutter&logoColor=white" />
  <img src="https://img.shields.io/badge/Dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white" />
  <img src="https://img.shields.io/badge/Ollama-Local_AI-000000?style=for-the-badge&logo=ollama&logoColor=white" />
</p>
<p align="center">
  <img src="https://img.shields.io/badge/Android-3DDC84?style=for-the-badge&logo=android&logoColor=white" />
  <img src="https://img.shields.io/badge/Privacidad-Offline-9C27B0?style=for-the-badge" />
  <img src="https://img.shields.io/badge/Licencia-Apache_2.0-green?style=for-the-badge" />
</p>


---

## 🌟 ¿Qué es GemMate?

GemMate transforma la forma en que los estudiantes universitarios aprenden combinando el modelo **Gemma 4 E2B de Google** con técnicas probadas de la ciencia del aprendizaje. Es una aplicación Flutter multiplataforma que ejecuta Gemma 4 **100% localmente** — sin nube, sin claves API, y ningún dato sale de tu dispositivo.

> 💡 **El Problema:** Los estudiantes luchan por crear materiales de estudio efectivos a partir de conferencias y libros de texto. Las herramientas de IA existentes requieren conectividad a la nube y plantean preocupaciones de privacidad.
>
> ✅ **La Solución:** GemMate ejecuta Gemma 4 E2B en tu propio hardware, generando flashcards personalizadas, cuestionarios y explicaciones — incluso en un avión.

<p align="center">   <img src="assets/cover.png" width="800" alt="Demo de Chat"/> </p>

---

## ✨ Características

### 🧠 Chat con IA con Gemma 4
Chatea con Gemma 4 E2B para entender conceptos complejos. Haz preguntas en cualquiera de los 6 idiomas admitidos y obtén explicaciones bilingües adaptadas a tu nivel.

<p align="center">   <img src="assets/demo1.jpg" width="350" alt="Demo de Chat"/> </p>

### 📚 Mazos de Flashcards Inteligentes
Genera mazos de flashcards a partir de cualquier conversación de chat. Las tarjetas utilizan el **algoritmo de repetición espaciada SM-2** para programas de revisión científicamente optimizados. Los mazos se muestran como hermosas pilas de tarjetas en forma de abanico con animaciones de giro.

<div align="center">
  <table>
    <tr>
      <td align="center"><b>Frente</b></td>
      <td align="center"><b>Dorso</b></td>
    </tr>
    <tr>
      <td align="center"><img src="assets/demo7.jpg" width="300"/></td>
      <td align="center"><img src="assets/demo8.jpg" width="300"/></td>
    </tr>
  </table>
</div>

### 📊 Cuestionarios Interactivos
Cuestionarios de opción múltiple generados por IA que ponen a prueba tu comprensión. Las respuestas incorrectas se convierten automáticamente en flashcards para una revisión enfocada.

<p align="center">   <img src="assets/demo2.jpg" width="260" />   <img src="assets/demo3.jpg" width="260" />   <img src="assets/demo4.jpg" width="260" /> </p>

### 📷 Cámara / OCR
Fotografía páginas de libros de texto, diapositivas de conferencias o notas manuscritas. Las capacidades de visión de Gemma 4 extraen y explican el contenido.

<p align="center">   <img src="assets/demo9.jpg" width="350" alt="Demo de Chat"/> </p>

### 🎤 Entrada de Voz
Toca el micrófono para hacer preguntas por voz — perfecto para estudiar con las manos libres. Admite chino, inglés, japonés, coreano, francés y español.

<p align="center">   <img src="assets/demo10.jpg" width="350" alt="Demo de Chat"/> </p>

### 🌍 6 Idiomas
Localización completa de la interfaz de usuario y respuestas de IA en: inglés, chino simplificado, japonés, coreano, francés y español.

<p align="center">   <img src="assets/languages.jpg" width="350" alt="Demo de Chat"/> </p>

### 🔔 Notificaciones Inteligentes
Recordatorios de repetición espaciada, sugerencias de estudio diarias y avisos de inactividad te mantienen en el camino correcto.

<p align="center">   <img src="assets/Notifications.jpg" width="350" alt="Demo de Chat"/> </p>

### 🗺️ Generador de Mapas Mentales con IA
Un toque genera un mapa mental visual y codificado por colores a partir de tu conversación — renderizado con curvas de Bézier y un lienzo interactivo de desplazamiento/zoom. Perfecto para organizar temas complejos antes de un examen.

<p align="center"><img src="assets/MindMap.jpg" width="350" alt="Mapa Mental"/></p>

### 📄 Importación de Documentos (PDF + DOCX)
Importa archivos PDF y Word (.docx) directamente al chat. GemMate extrae el texto y se lo entrega a la IA, para que puedas hacer preguntas, generar flashcards o obtener un resumen de cualquier documento — sin necesidad de subirlo a la nube.

<p align="center"><img src="assets/PDF%20%2B%20DOCX.jpg" width="350" alt="Importación de PDF y DOCX"/></p>

### 📷 Resolvedor de Matemáticas con Cámara
Cambia la pantalla de la cámara al modo **Resolvedor de Matemáticas** para fotografiar ecuaciones escritas a mano o problemas impresos. La IA los resuelve paso a paso, y cada paso puede guardarse como una flashcard para la práctica.

<div align="center">
  <table>
    <tr>
      <td align="center"><b>Selección de Modo</b></td>
      <td align="center"><b>Analizando</b></td>
      <td align="center"><b>Resultado Paso a Paso</b></td>
    </tr>
    <tr>
      <td align="center"><img src="assets/Mathematics%20Solver-1.jpg" width="220"/></td>
      <td align="center"><img src="assets/Mathematics%20Solver-2.jpg" width="220"/></td>
      <td align="center"><img src="assets/Mathematics%20Solver-3.jpg" width="220"/></td>
    </tr>
  </table>
</div>

### 🔲 Compartir Código QR y Escaneo de Galería
Comparte mazos de flashcards con compañeros de clase a través de un código QR generado, o escanea un QR desde una imagen de tu galería — sin necesidad de apuntar la cámara a una pantalla.

<div align="center">
  <table>
    <tr>
      <td align="center"><b>Interfaz de Escaneo</b></td>
      <td align="center"><b>Compartir vía QR</b></td>
    </tr>
    <tr>
      <td align="center"><img src="assets/QR%20Code%20Scanning%20Interface.jpg" width="280"/></td>
      <td align="center"><img src="assets/Example%20QR%20Code.jpg" width="280"/></td>
    </tr>
  </table>
</div>

### 🍅 Temporizador Pomodoro Personalizado
Establece tus propias duraciones de enfoque y descanso (1–120 min / 1–60 min) directamente desde la pantalla de inicio. Escribe el número o toca +/−. Las sesiones se rastrean diariamente y se almacenan localmente.

<div align="center">
  <table>
    <tr>
      <td align="center"><b>Temporizador</b></td>
      <td align="center"><b>Ajustes Personalizados</b></td>
    </tr>
    <tr>
      <td align="center"><img src="assets/Pomodoro%20timer%20interface.jpg" width="280"/></td>
      <td align="center"><img src="assets/Pomodoro%20timer%20settings.jpg" width="280"/></td>
    </tr>
  </table>
</div>

### 🎨 Diseño Neomórfico
Hermosa interfaz de usuario neomórfica con modo oscuro/claro, colores de acento personalizables y tamaños de fuente ajustables.

<p align="center">   <img src="assets/theme.jpg" width="350" alt="Demo de Chat"/> </p>

---

## 🏗️ Arquitectura

GemMate utiliza una **arquitectura de enrutamiento inteligente** que selecciona automáticamente el mejor modelo de IA disponible:

```
┌─────────────────────────────────────────────────┐
│                  📱 TELÉFONO                   │
│             App Flutter GemMate                 │
│                                                 │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐       │
│  │   Chat   │  │ Tarjetas │  │ Cuestion.│       │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘       │
│       │              │              │           │
│       └──────────────┼──────────────┘           │
│                      │                          │
│              ┌───────▼────────┐                 │
│              │ Router Intelig.│                 │
│              └───┬───────┬─-──┘                 │
│                  │       │                      │
│     ┌────────────▼─┐  ┌──▼───────────────┐      │
│     │ En el Dispos.│  │   Conexión       │      │
│     │  Gemma 4 E2B │  │   Ollama HTTP    │      │
│     │  (Offline)   │  │   (WiFi LAN)     │      │
│     └──────────────┘  └──────┬───────────┘      │
│                              │                  │
└──────────────────────────────┼──────────────────┘
                               │ WiFi (Red Local)
┌──────────────────────────────▼───────────────────┐
│                  💻 PORTÁTIL                   │
│           Ollama + Gemma 4 E4B                   │
│         (RTX 4060, respuesta <1s)                │
└──────────────────────────────────────────────────┘
```

### Lógica de Enrutamiento Inteligente

| Condición | Modelo Utilizado | Latencia |
|-----------|-----------|---------|
| WiFi + Portátil disponible | Gemma 4 E4B vía Ollama (GPU portátil) | <1s |
| Sin WiFi, modelo instalado | Gemma 4 E2B en el disp. (CPU teléf.) | 3-8s |
| WiFi + Sin portátil | Gemma 4 E2B en el dispositivo | 3-8s |
| Sin WiFi, sin modelo | Aviso para descargar el modelo | — |

---

## 🎬 Demo

📺 **[Mira el video de demostración de 3 minutos →](https://youtu.be/tLnDOzBy_Kc)**

📦 **[Descargar APK →](https://github.com/linyeping/GemMate/releases/latest)**

---

## 🚀 Instalación

### Requisitos Previos

- Flutter 3.41+ ([Instalar Flutter](https://flutter.dev/docs/get-started/install))
- Dispositivo Android (Android 8.0+) o emulador
- Para IA en portátil: [Ollama](https://ollama.ai) + `ollama pull gemma4:e2b`

### Construir desde el Código Fuente

```bash
# Clonar el repositorio
git clone https://github.com/linyeping/GemMate.git
cd GemMate

# Instalar dependencias
flutter pub get

# Ejecutar en el dispositivo conectado
flutter run

# Construir APK
flutter build apk --release
```

### Configurar IA en Portátil (Opcional, Recomendado)

```bash
# Instalar Ollama (https://ollama.ai)
ollama pull gemma4:e2b

# Iniciar con acceso a la red
OLLAMA_HOST=0.0.0.0:11434 ollama serve

# En Ajustes de GemMate → Conexión → Introducir IP del portátil
```

### Instalar Modelo en el Dispositivo (Opcional, para uso offline)

Opción A: Descargar en la aplicación (Ajustes → Gestión de Modelos → Descargar)

Opción B: Instalación manual vía ADB:
```bash
# Descargar desde el espejo de Hugging Face (China)
curl -L -o gemma-4-E2B-it.litertlm "https://hf-mirror.com/litert-community/gemma-4-E2B-it-litert-lm/resolve/main/gemma-4-E2B-it.litertlm"

# Subir al teléfono
adb push gemma-4-E2B-it.litertlm /sdcard/Download/

# En la app: Ajustes → Gestión de Modelos → Cargar desde /sdcard/Download/
```

---

## 🛠️ Stack Tecnológico

| Componente | Tecnología |
|-----------|-----------|
| **Modelo de IA** | Gemma 4 E2B / Gemma 4 E4B |
| **Runtime en Disp.** | LiteRT-LM vía flutter_gemma |
| **Servidor Local** | Ollama (portátil, acelerado por GPU) |
| **Framework de App** | Flutter 3.41 / Dart |
| **Algoritmo de Estudio** | Repetición Espaciada SM-2 |
| **Entrada de Voz** | speech_to_text |
| **OCR / Visión** | ML Kit (offline) + Gemma 4 multimodal (Ollama) |
| **Código QR** | mobile_scanner 5.x |
| **Importación de Doc.** | pdfx + archive (parseo de DOCX ZIP/XML) |
| **Mapa Mental** | CustomPainter + InteractiveViewer |
| **Notificaciones** | flutter_local_notifications |
| **Almacenamiento** | SharedPreferences + JSON |
| **Diseño de UI** | Widgets neomórficos personalizados |

---

## 📁 Estructura del Proyecto

```
lib/
├── main.dart                          # Punto de entrada de la app + inicialización del modelo
├── app/
│   ├── router.dart                    # Navegación inferior + enrutamiento de páginas
│   └── theme.dart                     # Tema neomórfico (claro/oscuro)
├── core/
│   ├── constants.dart                 # Constantes de la app + colores
│   ├── json_utils.dart                # Utilidades de parseo JSON
│   ├── text_utils.dart                # Procesamiento y formateo de texto
│   └── utils.dart                     # Funciones auxiliares generales
├── l10n/
│   ├── app_localizations.dart         # Delegado de i18n
│   ├── locale_en.dart                 # Localización en inglés
│   ├── locale_es.dart                 # Localización en español
│   ├── locale_fr.dart                 # Localización en francés
│   ├── locale_ja.dart                 # Localización en japonés
│   ├── locale_ko.dart                 # Localización en coreano
│   └── locale_zh.dart                 # Localización en chino
├── models/
│   ├── chat_message.dart              # Modelo de mensaje de chat
│   ├── chat_session.dart              # Modelo de sesión de chat
│   ├── flashcard.dart                 # Flashcard con campos SM-2 + agrupación
│   ├── quiz.dart                      # Modelo de estado de cuestionario
│   ├── quiz_question.dart             # Modelo de pregunta de cuestionario
│   ├── quiz_result.dart               # Resumen y puntuación de un cuestionario completado
│   └── study_plan.dart                # Modelo de horario de repetición espaciada
├── screens/
│   ├── capture_screen.dart            # Cámara / OCR + modo Resolvedor de Matemáticas
│   ├── chat_history_screen.dart       # Gestión de sesiones de chat
│   ├── chat_screen.dart               # UI de chat principal + voz + mapa mental + importación doc
│   ├── deck_study_screen.dart         # Sesión de estudio de giro de tarjetas
│   ├── exam_history_screen.dart       # Registros de exámenes pasados
│   ├── exam_screen.dart               # Modo de examen con tiempo
│   ├── flashcard_screen.dart          # Galería de mazos con pilas en abanico
│   ├── home_screen.dart               # Panel de control + temporizador Pomodoro personalizado
│   ├── mind_map_screen.dart           # Mapa mental interactivo generado por IA
│   ├── onboarding_screen.dart         # Configuración inicial + descarga de modelo
│   ├── paper_screen.dart              # Vista detallada y exportación de papeles de estudio
│   ├── qr_scan_screen.dart            # Escaneo QR (cámara + galería)
│   ├── qr_share_screen.dart           # Compartir código QR para mazos
│   ├── quiz_screen.dart               # UI de cuestionario interactivo
│   ├── review_screen.dart             # Panel de revisión programada
│   └── settings_screen.dart           # Ajustes con subpáginas
├── services/
│   ├── flashcard_generator.dart       # Creación de flashcards impulsada por IA
│   ├── local_gemma_service.dart       # Gemma 4 en el dispositivo vía flutter_gemma
│   ├── model_download_service.dart    # Descarga de modelo + soporte de espejo
│   ├── notification_service.dart      # Recordatorios de estudio
│   ├── ollama_service.dart            # Cliente HTTP para la API de Ollama
│   ├── pdf_service.dart               # Importación de PDF + DOCX y extracción de texto
│   ├── quiz_generator.dart            # Generación de cuestionarios impulsada por IA
│   ├── smart_router.dart              # Selección inteligente de modelo + overrides del sistema
│   ├── storage_service.dart           # Operaciones de almacenamiento local de archivos/DB
│   ├── streak_service.dart            # Racha diaria + contador Pomodoro
│   └── study_tools.dart               # Algoritmos de estudio principales (SM-2, etc.)
├── stores/
│   ├── chat_store.dart                # Persistencia de sesiones de chat
│   ├── connection_store.dart          # Gestión del estado de conexión
│   ├── flashcard_store.dart           # Persistencia de flashcards + grupos
│   ├── locale_store.dart              # Preferencias de idioma
│   └── theme_store.dart               # Preferencias de tema + tamaño de fuente
└── widgets/
    ├── animated_avatar.dart           # Imagen de perfil animada de IA/Usuario
    ├── chat_session_tile.dart         # Elemento de lista de historial de chat
    ├── code_block.dart                # Visualización de código con resaltado de sintaxis
    ├── color_scheme_picker.dart       # Selector de esquema de colores del tema
    ├── connection_indicator.dart      # Indicador de estado de conexión
    ├── download_progress_widget.dart  # UI de estado de descarga del modelo
    ├── flashcard_widget.dart          # UI de flashcard individual
    ├── loading_indicator.dart         # Animación de carga personalizada
    ├── message_bubble.dart            # Burbuja de mensaje de chat
    ├── model_badge.dart               # Indicador de fuente de modelo (Disp./Portátil)
    ├── neumorphic_button.dart         # Widget de botón neomórfico
    ├── neumorphic_container.dart      # Widget de tarjeta neomórfica
    ├── quick_action_chips.dart        # Chips de sugerencias de prompts
    └── quiz_option_tile.dart          # Botón de opción múltiple de cuestionario
```

---

## 👤 Sobre el Desarrollador

**Sheng Wei** — Estudiante de IA en la **Universidad de Ciencias Políticas y Derecho de Gansu (GSUPL)** en China. Desarrollador independiente.

Proyectos Anteriores: **InSeeVision** (proyecto de accesibilidad de Gemma 3).

- GitHub: [@linyeping](https://github.com/linyeping)
- Kaggle: [linyeping](https://kaggle.com/linyeping)

---

## 📄 Licencia

Este proyecto está bajo la Licencia Apache 2.0; consulta el archivo [LICENSE](LICENSE) para más detalles.

El modelo Gemma 4 es proporcionado por Google bajo los [Términos de Uso de Gemma](https://ai.google.dev/gemma/terms).

---

<p align="center">
  <strong>Creado con ❤️ para el Hackathon Gemma 4 Good 2026</strong><br/>
  <strong>Contacto: yepinglin20@gmail.com | 201180946@qq.com</strong>
</p>
