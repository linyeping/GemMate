<p align="center">
  <img src="assets/gemmate_logo.png" width="120" alt="Logo GemMate"/>
</p>




<h1 align="center">GemMate</h1>

<p align="center">
  <strong>Votre compagnon d'étude IA — Propulsé par Gemma 4</strong>
</p>

<p align="center">
  <a href="#fonctionnalités">Fonctionnalités</a> •
  <a href="#architecture">Architecture</a> •
  <a href="#démo">Démo</a> •
  <a href="#installation">Installation</a> •
  <a href="#pile-technique">Pile Technique</a> •
  <a href="#licence">Licence</a>
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
  <img src="https://img.shields.io/badge/Confidentialité-Hors--ligne-9C27B0?style=for-the-badge" />
  <img src="https://img.shields.io/badge/Licence-Apache_2.0-green?style=for-the-badge" />
</p>


---

## 🌟 Qu'est-ce que GemMate ?

GemMate transforme la façon dont les étudiants universitaires apprennent en combinant le modèle **Gemma 4 E2B de Google** avec des techniques éprouvées de science de l'apprentissage. C'est une application Flutter multiplateforme qui exécute Gemma 4 **100 % localement** — pas de cloud, pas de clés API, aucune donnée ne quitte votre appareil.

> 💡 **Le Problème :** Les étudiants ont du mal à créer des supports d'étude efficaces à partir de leurs cours et manuels. Les outils IA existants nécessitent une connectivité cloud et soulèvent des questions de confidentialité.
>
> ✅ **La Solution :** GemMate exécute Gemma 4 E2B sur votre propre matériel, générant des flashcards personnalisées, des quiz et des explications — même en avion.

<p align="center">   <img src="assets/cover.png" width="800" alt="Démo Chat"/> </p>

---

## ✨ Fonctionnalités

### 🧠 Chat IA avec Gemma 4
Discutez avec Gemma 4 E2B pour comprendre des concepts complexes. Posez des questions dans l'une des 6 langues prises en charge et obtenez des explications bilingues adaptées à votre niveau.

<p align="center">   <img src="assets/demo1.jpg" width="350" alt="Démo Chat"/> </p>

### 📚 Paquets de Flashcards Intelligents
Générez des paquets de flashcards à partir de n'importe quelle conversation de chat. Les cartes utilisent l'**algorithme de répétition espacée SM-2** pour des programmes de révision scientifiquement optimisés. Les paquets sont affichés sous forme de magnifiques piles de cartes en éventail avec des animations de retournement.

<div align="center">
  <table>
    <tr>
      <td align="center"><b>Recto</b></td>
      <td align="center"><b>Verso</b></td>
    </tr>
    <tr>
      <td align="center"><img src="assets/demo7.jpg" width="300"/></td>
      <td align="center"><img src="assets/demo8.jpg" width="300"/></td>
    </tr>
  </table>
</div>

### 📊 Quiz Interactifs
Des quiz à choix multiples générés par l'IA qui testent votre compréhension. Les mauvaises réponses deviennent automatiquement des flashcards pour une révision ciblée.

<p align="center">   <img src="assets/demo2.jpg" width="260" />   <img src="assets/demo3.jpg" width="260" />   <img src="assets/demo4.jpg" width="260" /> </p>

### 📷 Caméra / OCR
Photographiez des pages de manuels, des diapositives de cours ou des notes manuscrites. Les capacités de vision de Gemma 4 extraient et expliquent le contenu.

<p align="center">   <img src="assets/demo9.jpg" width="350" alt="Démo Chat"/> </p>

### 🎤 Entrée Vocale
Appuyez sur le microphone pour poser des questions par la voix — parfait pour étudier les mains libres. Prend en charge le chinois, l'anglais, le japonais, le coréen, le français et l'espagnol.

<p align="center">   <img src="assets/demo10.jpg" width="350" alt="Démo Chat"/> </p>

### 🌍 6 Langues
Localisation complète de l'interface utilisateur et réponses IA en : Anglais, Chinois simplifié, Japonais, Coréen, Français, Espagnol.

<p align="center">   <img src="assets/languages.jpg" width="350" alt="Démo Chat"/> </p>

### 🔔 Notifications Intelligentes
Des rappels de répétition espacée, des invites d'étude quotidiennes et des rappels d'inactivité vous aident à rester sur la bonne voie.

<p align="center">   <img src="assets/Notifications.jpg" width="350" alt="Démo Chat"/> </p>

### 🗺️ Générateur de Cartes Mentales IA
D'une simple pression, générez une carte mentale visuelle avec code couleur à partir de votre conversation — rendue avec des courbes de Bézier et un canevas interactif de panoramique/zoom. Parfait pour organiser des sujets complexes avant un examen.

<p align="center"><img src="assets/MindMap.jpg" width="350" alt="Carte Mentale"/></p>

### 📄 Importation de Documents (PDF + DOCX)
Importez des fichiers PDF et Word (.docx) directement dans le chat. GemMate extrait le texte et le transmet à l'IA, afin que vous puissiez poser des questions, générer des flashcards ou obtenir un résumé de n'importe quel document — sans envoi sur le cloud.

<p align="center"><img src="assets/PDF%20%2B%20DOCX.jpg" width="350" alt="Importation PDF et DOCX"/></p>

### 📷 Solveur Mathématique par Caméra
Basculez l'écran de la caméra en mode **Solveur Mathématique** pour photographier des équations manuscrites ou des problèmes imprimés. L'IA les résout étape par étape, et chaque étape peut être enregistrée en tant que flashcard pour l'entraînement.

<div align="center">
  <table>
    <tr>
      <td align="center"><b>Sélection du Mode</b></td>
      <td align="center"><b>Analyse</b></td>
      <td align="center"><b>Résultat Étape par Étape</b></td>
    </tr>
    <tr>
      <td align="center"><img src="assets/Mathematics%20Solver-1.jpg" width="220"/></td>
      <td align="center"><img src="assets/Mathematics%20Solver-2.jpg" width="220"/></td>
      <td align="center"><img src="assets/Mathematics%20Solver-3.jpg" width="220"/></td>
    </tr>
  </table>
</div>

### 🔲 Partage de Code QR et Scan de Galerie
Partagez des paquets de flashcards avec vos camarades via un code QR généré, ou scannez un QR à partir d'une image de votre galerie — pas besoin de pointer la caméra vers un écran.

<div align="center">
  <table>
    <tr>
      <td align="center"><b>Interface de Scan</b></td>
      <td align="center"><b>Partage via QR</b></td>
    </tr>
    <tr>
      <td align="center"><img src="assets/QR%20Code%20Scanning%20Interface.jpg" width="280"/></td>
      <td align="center"><img src="assets/Example%20QR%20Code.jpg" width="280"/></td>
    </tr>
  </table>
</div>

### 🍅 Minuteur Pomodoro Personnalisé
Définissez vos propres durées de concentration et de pause (1–120 min / 1–60 min) directement depuis l'écran d'accueil. Tapez le nombre ou appuyez sur +/−. Les sessions sont suivies quotidiennement et stockées localement.

<div align="center">
  <table>
    <tr>
      <td align="center"><b>Minuteur</b></td>
      <td align="center"><b>Paramètres Personnalisés</b></td>
    </tr>
    <tr>
      <td align="center"><img src="assets/Pomodoro%20timer%20interface.jpg" width="280"/></td>
      <td align="center"><img src="assets/Pomodoro%20timer%20settings.jpg" width="280"/></td>
    </tr>
  </table>
</div>

### 🎨 Design Néomorphique
Magnifique interface utilisateur néomorphique avec mode sombre/clair, couleurs d'accentuation personnalisables et tailles de police ajustables.

<p align="center">   <img src="assets/theme.jpg" width="350" alt="Démo Chat"/> </p>

---

## 🏗️ Architecture

GemMate utilise une **architecture de routage intelligente** qui sélectionne automatiquement le meilleur modèle IA disponible :

```
┌─────────────────────────────────────────────────┐
│                  📱 TÉLÉPHONE                  │
│             Application Flutter GemMate         │
│                                                 │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐       │
│  │   Chat   │  │  Cartes  │  │   Quiz   │       │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘       │
│       │              │              │           │
│       └──────────────┼──────────────┘           │
│                      │                          │
│              ┌───────▼────────┐                 │
│              │ Routeur Intelli│                 │
│              └───┬───────┬─-──┘                 │
│                  │       │                      │
│     ┌────────────▼─┐  ┌──▼───────────────┐      │
│     │ Sur Appareil │  │   Connexion      │      │
│     │  Gemma 4 E2B │  │   Ollama HTTP    │      │
│     │  (Hors ligne)│  │   (WiFi LAN)     │      │
│     └──────────────┘  └──────┬───────────┘      │
│                              │                  │
└──────────────────────────────┼──────────────────┘
                               │ WiFi (Réseau Local)
┌──────────────────────────────▼───────────────────┐
│                  💻 ORDINATEUR                   │
│           Ollama + Gemma 4 E4B                   │
│         (RTX 4060, réponse <1s)                  │
└──────────────────────────────────────────────────┘
```

### Logique de Routage Intelligente

| Condition | Modèle Utilisé | Latence |
|-----------|-----------|---------|
| WiFi + Ordinateur disponible | Gemma 4 E4B via Ollama (GPU ordi) | <1s |
| Pas de WiFi, modèle installé | Gemma 4 E2B sur appareil (CPU tél) | 3-8s |
| WiFi + Pas d'ordinateur | Gemma 4 E2B sur appareil | 3-8s |
| Pas de WiFi, pas de modèle | Invite à télécharger le modèle | — |

---

## 🎬 Démo

📺 **[Voir la vidéo de démo de 3 minutes →](https://youtu.be/tLnDOzBy_Kc)**

📦 **[Télécharger l'APK →](https://github.com/linyeping/GemMate/releases/latest)**

---

## 🚀 Installation

### Prérequis

- Flutter 3.41+ ([Installer Flutter](https://flutter.dev/docs/get-started/install))
- Appareil Android (Android 8.0+) ou émulateur
- Pour l'IA sur ordinateur : [Ollama](https://ollama.ai) + `ollama pull gemma4:e2b`

### Construire à partir des sources

```bash
# Cloner le dépôt
git clone https://github.com/linyeping/GemMate.git
cd GemMate

# Installer les dépendances
flutter pub get

# Exécuter sur l'appareil connecté
flutter run

# Construire l'APK
flutter build apk --release
```

### Configurer l'IA sur ordinateur (Optionnel, Recommandé)

```bash
# Installer Ollama (https://ollama.ai)
ollama pull gemma4:e2b

# Démarrer avec accès réseau
OLLAMA_HOST=0.0.0.0:11434 ollama serve

# Dans Paramètres GemMate → Connexion → Entrer l'IP de l'ordinateur
```

### Installer le modèle sur l'appareil (Optionnel, pour usage hors-ligne)

Option A : Télécharger dans l'application (Paramètres → Gestion du modèle → Télécharger)

Option B : Installation manuelle via ADB :
```bash
# Télécharger depuis le miroir Hugging Face (Chine)
curl -L -o gemma-4-E2B-it.litertlm "https://hf-mirror.com/litert-community/gemma-4-E2B-it-litert-lm/resolve/main/gemma-4-E2B-it.litertlm"

# Pousser vers le téléphone
adb push gemma-4-E2B-it.litertlm /sdcard/Download/

# Dans l'app : Paramètres → Gestion du modèle → Charger depuis /sdcard/Download/
```

---

## 🛠️ Pile Technique

| Composant | Technologie |
|-----------|-----------|
| **Modèle IA** | Gemma 4 E2B / Gemma 4 E4B |
| **Runtime sur appareil** | LiteRT-LM via flutter_gemma |
| **Serveur Local** | Ollama (ordinateur, accéléré par GPU) |
| **Framework App** | Flutter 3.41 / Dart |
| **Algorithme d'Étude** | Répétition espacée SM-2 |
| **Entrée Vocale** | speech_to_text |
| **OCR / Vision** | ML Kit (hors-ligne) + Gemma 4 multimodal (Ollama) |
| **Code QR** | mobile_scanner 5.x |
| **Importation de Documents** | pdfx + archive (parsing DOCX ZIP/XML) |
| **Carte Mentale** | CustomPainter + InteractiveViewer |
| **Notifications** | flutter_local_notifications |
| **Stockage** | SharedPreferences + JSON |
| **Design UI** | Widgets Néomorphiques personnalisés |

---

## 📁 Structure du Projet

```
lib/
├── main.dart                          # Point d'entrée de l'app + initialisation du modèle
├── app/
│   ├── router.dart                    # Navigation inférieure + routage des pages
│   └── theme.dart                     # Thème néomorphique (clair/sombre)
├── core/
│   ├── constants.dart                 # Constantes de l'app + couleurs
│   ├── json_utils.dart                # Utilitaires de parsing JSON
│   ├── text_utils.dart                # Traitement et formatage de texte
│   └── utils.dart                     # Fonctions d'aide générales
├── l10n/
│   ├── app_localizations.dart         # Délégué i18n
│   ├── locale_en.dart                 # Localisation anglaise
│   ├── locale_es.dart                 # Localisation espagnole
│   ├── locale_fr.dart                 # Localisation française
│   ├── locale_ja.dart                 # Localisation japonaise
│   ├── locale_ko.dart                 # Localisation coréenne
│   └── locale_zh.dart                 # Localisation chinoise
├── models/
│   ├── chat_message.dart              # Modèle de message de chat
│   ├── chat_session.dart              # Modèle de session de chat
│   ├── flashcard.dart                 # Flashcard avec champs SM-2 + groupage
│   ├── quiz.dart                      # Modèle d'état de quiz
│   ├── quiz_question.dart             # Modèle de question de quiz
│   ├── quiz_result.dart               # Résumé et score d'un quiz complété
│   └── study_plan.dart                # Modèle de planning de répétition espacée
├── screens/
│   ├── capture_screen.dart            # Caméra / OCR + mode Solveur Math
│   ├── chat_history_screen.dart       # Gestion des sessions de chat
│   ├── chat_screen.dart               # UI chat principal + voix + carte mentale + import doc
│   ├── deck_study_screen.dart         # Session d'étude avec retournement de cartes
│   ├── exam_history_screen.dart       # Records d'examens passés
│   ├── exam_screen.dart               # Mode examen chronométré
│   ├── flashcard_screen.dart          # Galerie de paquets avec piles en éventail
│   ├── home_screen.dart               # Tableau de bord + minuteur Pomodoro personnalisé
│   ├── mind_map_screen.dart           # Carte mentale interactive générée par IA
│   ├── onboarding_screen.dart         # Configuration premier lancement + téléchargement modèle
│   ├── paper_screen.dart              # Vue détaillée et export de supports d'étude
│   ├── qr_scan_screen.dart            # Scan QR (caméra + galerie)
│   ├── qr_share_screen.dart           # Partage de code QR pour les paquets
│   ├── quiz_screen.dart               # UI quiz interactif
│   ├── review_screen.dart             # Tableau de bord de révision planifiée
│   └── settings_screen.dart           # Paramètres avec sous-pages
├── services/
│   ├── flashcard_generator.dart       # Création de flashcards assistée par IA
│   ├── local_gemma_service.dart       # Gemma 4 sur appareil via flutter_gemma
│   ├── model_download_service.dart    # Téléchargement de modèle + support miroir
│   ├── notification_service.dart      # Rappels d'étude
│   ├── ollama_service.dart            # Client HTTP pour l'API Ollama
│   ├── pdf_service.dart               # Importation PDF + DOCX et extraction de texte
│   ├── quiz_generator.dart            # Génération de quiz assistée par IA
│   ├── smart_router.dart              # Sélection intelligente de modèle + overrides système
│   ├── storage_service.dart           # Opérations de stockage local fichier/DB
│   ├── streak_service.dart            # Série quotidienne + compteur Pomodoro
│   └── study_tools.dart               # Algorithmes d'étude de base (SM-2, etc.)
├── stores/
│   ├── chat_store.dart                # Persistance des sessions de chat
│   ├── connection_store.dart          # Gestion de l'état de connexion
│   ├── flashcard_store.dart           # Persistance des flashcards + groupes
│   ├── locale_store.dart              # Préférences de langue
│   └── theme_store.dart               # Préférences de thème + taille de police
└── widgets/
    ├── animated_avatar.dart           # Photo de profil animée IA/Utilisateur
    ├── chat_session_tile.dart         # Élément de liste d'historique de chat
    ├── code_block.dart                # Affichage de code avec coloration syntaxique
    ├── color_scheme_picker.dart       # Sélecteur de couleur de thème
    ├── connection_indicator.dart      # Indicateur d'état de connexion
    ├── download_progress_widget.dart  # UI d'état de téléchargement du modèle
    ├── flashcard_widget.dart          # UI de flashcard individuelle
    ├── loading_indicator.dart         # Animation de chargement personnalisée
    ├── message_bubble.dart            # Bulle de message de chat
    ├── model_badge.dart               # Indicateur de source de modèle (Appareil/Ordi)
    ├── neumorphic_button.dart         # Widget bouton néomorphique
    ├── neumorphic_container.dart      # Widget carte néomorphique
    ├── quick_action_chips.dart        # Puces de suggestions de prompts
    └── quiz_option_tile.dart          # Bouton de choix multiple de quiz
```

---

## 👤 À propos du Développeur

**Sheng Wei** — Étudiant en IA à l'**Université de Sciences Politiques et de Droit de Gansu (GSUPL)** en Chine. Développeur solo.

Projets précédents : **InSeeVision** (projet d'accessibilité Gemma 3).

- GitHub: [@linyeping](https://github.com/linyeping)
- Kaggle: [linyeping](https://kaggle.com/linyeping)

---

## 📄 Licence

Ce projet est sous licence Apache License 2.0 — voir le fichier [LICENSE](LICENSE) pour plus de détails.

Le modèle Gemma 4 est fourni par Google selon les [Conditions d'utilisation de Gemma](https://ai.google.dev/gemma/terms).

---

<p align="center">
  <strong>Conçu avec ❤️ pour le Hackathon Gemma 4 Good 2026</strong><br/>
  <strong>Contact : yepinglin20@gmail.com | 201180946@qq.com</strong>
</p>
