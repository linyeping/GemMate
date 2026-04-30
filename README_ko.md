<p align="center">
  <img src="assets/gemmate_logo.png" width="120" alt="GemMate Logo"/>
</p>




<h1 align="center">GemMate</h1>

<p align="center">
  <strong>당신의 AI 학습 동반자 — Gemma 4 기반</strong>
</p>

<p align="center">
  <a href="#주요-기능">주요 기능</a> •
  <a href="#아키텍처">아키텍처</a> •
  <a href="#데모">데모</a> •
  <a href="#설치-방법">설치 방법</a> •
  <a href="#기술-스택">기술 스택</a> •
  <a href="#라이선스">라이선스</a>
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
  <img src="https://img.shields.io/badge/Privacy-Offline-9C27B0?style=for-the-badge" />
  <img src="https://img.shields.io/badge/License-Apache_2.0-green?style=for-the-badge" />
</p>


---

## 🌟 GemMate란 무엇인가요?

GemMate는 **Google의 Gemma 4 E2B** 모델과 입증된 학습 과학 기술을 결합하여 대학생들의 학습 방식을 혁신합니다. Gemma 4를 **100% 로컬**에서 실행하는 크로스 플랫폼 Flutter 앱으로, 클라우드 연결이나 API 키가 필요 없으며 데이터가 기기 외부로 유출되지 않습니다.

> 💡 **문제점:** 학생들은 강의 내용이나 교과서에서 효과적인 학습 자료를 만드는 데 어려움을 겪습니다. 기존의 AI 도구들은 클라우드 연결을 요구하며 개인정보 보호 문제를 야기합니다.
>
> ✅ **해결책:** GemMate는 사용자 기기에서 Gemma 4 E2B를 실행하여 맞춤형 플래시카드, 퀴즈, 설명을 생성합니다. 비행기 안에서도 사용이 가능합니다.

<p align="center">   <img src="assets/cover.png" width="800" alt="Chat Demo"/> </p>

---

## ✨ 주요 기능

### 🧠 Gemma 4 기반 AI 채팅
Gemma 4 E2B와 채팅하여 복잡한 개념을 이해하세요. 지원되는 6개 언어 중 하나로 질문하면 사용자의 수준에 맞춘 이중 언어 설명을 제공합니다.

<p align="center">   <img src="assets/demo1.jpg" width="350" alt="Chat Demo"/> </p>

### 📚 스마트 플래시카드 덱
채팅 대화 내용에서 플래시카드 덱을 생성합니다. 과학적으로 최적화된 복습 일정을 위해 **SM-2 간격 반복 알고리즘**을 사용합니다. 덱은 플립 애니메이션이 포함된 아름다운 부채꼴 모양의 카드 더미로 표시됩니다.

<div align="center">
  <table>
    <tr>
      <td align="center"><b>앞면</b></td>
      <td align="center"><b>뒷면</b></td>
    </tr>
    <tr>
      <td align="center"><img src="assets/demo7.jpg" width="300"/></td>
      <td align="center"><img src="assets/demo8.jpg" width="300"/></td>
    </tr>
  </table>
</div>

### 📊 대화형 퀴즈
사용자의 이해도를 테스트하는 AI 생성 객관식 퀴즈입니다. 틀린 답변은 자동으로 플래시카드로 만들어져 집중 복습을 돕습니다.

<p align="center">   <img src="assets/demo2.jpg" width="260" />   <img src="assets/demo3.jpg" width="260" />   <img src="assets/demo4.jpg" width="260" /> </p>

### 📷 카메라 / OCR
교과서 페이지, 강의 슬라이드 또는 직접 쓴 노트를 촬영하세요. Gemma 4의 비전 기능이 내용을 추출하고 설명해 드립니다.

<p align="center">   <img src="assets/demo9.jpg" width="350" alt="Chat Demo"/> </p>

### 🎤 음성 입력
마이크 아이콘을 눌러 음성으로 질문하세요 — 손을 자유롭게 쓰고 싶을 때 완벽합니다. 한국어, 중국어, 영어, 일본어, 프랑스어, 스페인어를 지원합니다.

<p align="center">   <img src="assets/demo10.jpg" width="350" alt="Chat Demo"/> </p>

### 🌍 6개 언어 지원
전체 UI 로컬라이징 및 AI 응답 지원: 한국어, 영어, 简体中文, 日本語, Français, Español.

<p align="center">   <img src="assets/languages.jpg" width="350" alt="Chat Demo"/> </p>

### 🔔 스마트 알림
간격 반복 알림, 매일 학습 제안, 미활동 알림을 통해 학습 흐름을 유지하세요.

<p align="center">   <img src="assets/Notifications.jpg" width="350" alt="Chat Demo"/> </p>

### 🗺️ AI 마인드맵 생성기
탭 한 번으로 대화 내용에서 시각적으로 색상화된 마인드맵을 생성합니다. 베지에 곡선으로 렌더링되며 대화형 이동/확대 캔버스를 제공합니다. 시험 전 복잡한 주제를 정리하는 데 최적입니다.

<p align="center"><img src="assets/MindMap.jpg" width="350" alt="Mind Map"/></p>

### 📄 문서 가져오기 (PDF + DOCX)
PDF 및 Word (.docx) 파일을 채팅에 직접 가져오세요. GemMate가 텍스트를 추출하여 AI에게 전달하므로, 어떤 문서에서든 질문하거나 플래시카드를 생성하고 요약본을 받을 수 있습니다. 클라우드 업로드가 필요 없습니다.

<p align="center"><img src="assets/PDF%20%2B%20DOCX.jpg" width="350" alt="PDF and DOCX Import"/></p>

### 📷 카메라 수학 풀이 도우미
카메라 화면을 **수학 풀이** 모드로 전환하여 손으로 쓴 방정식이나 인쇄된 문제를 촬영하세요. AI가 단계별 풀이 과정을 제공하며, 각 단계를 연습용 플래시카드로 저장할 수 있습니다.

<div align="center">
  <table>
    <tr>
      <td align="center"><b>모드 선택</b></td>
      <td align="center"><b>분석 중</b></td>
      <td align="center"><b>단계별 풀이 결과</b></td>
    </tr>
    <tr>
      <td align="center"><img src="assets/Mathematics%20Solver-1.jpg" width="220"/></td>
      <td align="center"><img src="assets/Mathematics%20Solver-2.jpg" width="220"/></td>
      <td align="center"><img src="assets/Mathematics%20Solver-3.jpg" width="220"/></td>
    </tr>
  </table>
</div>

### 🔲 QR 코드 공유 및 갤러리 스캔
생성된 QR 코드를 통해 친구들과 플래시카드 덱을 공유하거나, 갤러리 이미지에서 QR 코드를 스캔하세요. 화면에 카메라를 직접 댈 필요가 없습니다.

<div align="center">
  <table>
    <tr>
      <td align="center"><b>스캔 인터페이스</b></td>
      <td align="center"><b>QR 코드로 공유</b></td>
    </tr>
    <tr>
      <td align="center"><img src="assets/QR%20Code%20Scanning%20Interface.jpg" width="280"/></td>
      <td align="center"><img src="assets/Example%20QR%20Code.jpg" width="280"/></td>
    </tr>
  </table>
</div>

### 🍅 맞춤형 뽀모도로 타이머
홈 화면에서 직접 자신만의 집중 시간과 휴식 시간(1~120분 / 1~60분)을 설정하세요. 숫자를 직접 입력하거나 +/− 버튼을 누르세요. 세션 기록은 매일 추적되어 로컬에 저장됩니다.

<div align="center">
  <table>
    <tr>
      <td align="center"><b>타이머</b></td>
      <td align="center"><b>맞춤 설정</b></td>
    </tr>
    <tr>
      <td align="center"><img src="assets/Pomodoro%20timer%20interface.jpg" width="280"/></td>
      <td align="center"><img src="assets/Pomodoro%20timer%20settings.jpg" width="280"/></td>
    </tr>
  </table>
</div>

### 🎨 뉴모피즘 디자인
다크/라이트 모드, 맞춤형 강조 색상 및 조절 가능한 글꼴 크기를 갖춘 아름다운 뉴모피즘 UI를 경험하세요.

<p align="center">   <img src="assets/theme.jpg" width="350" alt="Chat Demo"/> </p>

---

## 🏗️ 아키텍처

GemMate는 사용 가능한 최적의 AI 모델을 자동으로 선택하는 **스마트 라우팅 아키텍처**를 사용합니다.

```
┌─────────────────────────────────────────────────┐
│                  📱 스마트폰                    │
│             GemMate Flutter 앱                  │
│                                                 │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐       │
│  │   채팅   │  │   카드   │  │   퀴즈   │       │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘       │
│       │              │              │           │
│       └──────────────┼──────────────┘           │
│                      │                          │
│              ┌───────▼────────┐                 │
│              │  스마트 라우터  │                 │
│              └───┬───────┬─-──┘                 │
│                  │       │                      │
│     ┌────────────▼─┐  ┌──▼───────────────┐      │
│     │  온디바이스  │  │   Ollama HTTP    │      │
│     │  Gemma 4 E2B │  │      연결        │      │
│     │   (오프라인) │  │   (WiFi LAN)     │      │
│     └──────────────┘  └──────┬───────────┘      │
│                              │                  │
└──────────────────────────────┼──────────────────┘
                               │ WiFi (로컬 네트워크)
┌──────────────────────────────▼───────────────────┐
│                  💻 노트북                      │
│           Ollama + Gemma 4 E4B                   │
│         (RTX 4060, <1s 응답)                     │
└──────────────────────────────────────────────────┘
```

### 스마트 라우팅 로직

| 조건 | 사용 모델 | 지연 시간 |
|-----------|-----------|---------|
| WiFi + 노트북 사용 가능 | Ollama를 통한 Gemma 4 E4B (노트북 GPU) | <1s |
| WiFi 없음, 모델 설치됨 | 온디바이스 Gemma 4 E2B (스마트폰 CPU) | 3-8s |
| WiFi 있음 + 노트북 없음 | 온디바이스 Gemma 4 E2B | 3-8s |
| WiFi 없음, 모델 없음 | 모델 다운로드 안내 표시 | — |

---

## 🎬 데모

📺 **[3분 데모 비디오 시청하기 →](https://youtu.be/tLnDOzBy_Kc)**

📦 **[APK 다운로드 →](https://github.com/linyeping/GemMate/releases/latest)**

---

## 🚀 설치 방법

### 사전 요구 사항

- Flutter 3.41+ ([Flutter 설치하기](https://flutter.dev/docs/get-started/install))
- Android 기기 (Android 8.0 이상) 또는 에뮬레이터
- 노트북 AI 사용 시: [Ollama](https://ollama.ai) + `ollama pull gemma4:e2b`

### 소스에서 빌드하기

```bash
# 저장소 복제
git clone https://github.com/linyeping/GemMate.git
cd GemMate

# 종속성 설치
flutter pub get

# 연결된 기기에서 실행
flutter run

# APK 빌드
flutter build apk --release
```

### 노트북 AI 설정 (선택 사항, 권장)

```bash
# Ollama 설치 (https://ollama.ai)
ollama pull gemma4:e2b

# 네트워크 액세스 허용하여 시작
OLLAMA_HOST=0.0.0.0:11434 ollama serve

# GemMate 설정 → 연결 → 노트북 IP 주소 입력
```

### 온디바이스 모델 설치 (선택 사항, 오프라인용)

방법 A: 앱 내에서 다운로드 (설정 → 모델 관리 → 다운로드)

방법 B: ADB를 통한 수동 설치:
```bash
# Hugging Face 미러(중국)에서 다운로드
curl -L -o gemma-4-E2B-it.litertlm "https://hf-mirror.com/litert-community/gemma-4-E2B-it-litert-lm/resolve/main/gemma-4-E2B-it.litertlm"

# 기기로 전송
adb push gemma-4-E2B-it.litertlm /sdcard/Download/

# 앱 내: 설정 → 모델 관리 → /sdcard/Download/에서 불러오기
```

---

## 🛠️ 기술 스택

| 컴포넌트 | 기술 |
|-----------|-----------|
| **AI 모델** | Gemma 4 E2B / Gemma 4 E4B |
| **온디바이스 런타임** | flutter_gemma를 통한 LiteRT-LM |
| **로컬 서버** | Ollama (노트북, GPU 가속) |
| **앱 프레임워크** | Flutter 3.41 / Dart |
| **학습 알고리즘** | SM-2 간격 반복 |
| **음성 입력** | speech_to_text |
| **OCR / 비전** | ML Kit (오프라인) + Gemma 4 멀티모달 (Ollama) |
| **QR 코드** | mobile_scanner 5.x |
| **문서 가져오기** | pdfx + archive (DOCX ZIP/XML 파싱) |
| **마인드맵** | CustomPainter + InteractiveViewer |
| **알림** | flutter_local_notifications |
| **데이터 저장** | SharedPreferences + JSON |
| **UI 디자인** | 맞춤형 뉴모피즘 위젯 |

---

## 📁 프로젝트 구조

```
lib/
├── main.dart                          # 앱 진입점 + 모델 초기화
├── app/
│   ├── router.dart                    # 하단 네비게이션 + 페이지 라우팅
│   └── theme.dart                     # 뉴모피즘 테마 (라이트/다크)
├── core/
│   ├── constants.dart                 # 앱 상수 + 색상
│   ├── json_utils.dart                # JSON 파싱 유틸리티
│   ├── text_utils.dart                # 텍스트 처리 및 포맷팅
│   └── utils.dart                     # 일반 헬퍼 함수
├── l10n/
│   ├── app_localizations.dart         # i18n 델리게이트
│   ├── locale_en.dart                 # 영어 로컬라이징
│   ├── locale_es.dart                 # 스페인어 로컬라이징
│   ├── locale_fr.dart                 # 프랑스어 로컬라이징
│   ├── locale_ja.dart                 # 일본어 로컬라이징
│   ├── locale_ko.dart                 # 한국어 로컬라이징
│   └── locale_zh.dart                 # 중국어 로컬라이징
├── models/
│   ├── chat_message.dart              # 채팅 메시지 모델
│   ├── chat_session.dart              # 채팅 세션 모델
│   ├── flashcard.dart                 # SM-2 필드 + 그룹화 기능 포함 플래시카드
│   ├── quiz.dart                      # 퀴즈 상태 모델
│   ├── quiz_question.dart             # 퀴즈 질문 모델
│   ├── quiz_result.dart               # 완료된 퀴즈 요약 및 점수
│   └── study_plan.dart                # 간격 반복 일정 모델
├── screens/
│   ├── capture_screen.dart            # 카메라 / OCR + 수학 풀이 모드
│   ├── chat_history_screen.dart       # 채팅 세션 관리
│   ├── chat_screen.dart               # 메인 채팅 UI + 음성 + 마인드맵 + 문서 가져오기
│   ├── deck_study_screen.dart         # 카드 플립 학습 세션
│   ├── exam_history_screen.dart       # 과거 시험 기록
│   ├── exam_screen.dart               # 시간 제한 시험 모드
│   ├── flashcard_screen.dart          # 부채꼴 카드 더미가 있는 덱 갤러리
│   ├── home_screen.dart               # 대시보드 + 맞춤형 뽀모도로 타이머
│   ├── mind_map_screen.dart           # AI 생성 대화형 마인드맵
│   ├── onboarding_screen.dart         # 첫 실행 설정 + 모델 다운로드
│   ├── paper_screen.dart              # 학습 페이퍼 상세 보기 및 내보내기
│   ├── qr_scan_screen.dart            # QR 스캔 (카메라 + 갤러리)
│   ├── qr_share_screen.dart           # 덱용 QR 코드 공유
│   ├── quiz_screen.dart               # 대화형 퀴즈 UI
│   ├── review_screen.dart             # 예약된 복습 대시보드
│   └── settings_screen.dart           # 하위 페이지가 있는 설정
├── services/
│   ├── flashcard_generator.dart       # AI 기반 플래시카드 생성
│   ├── local_gemma_service.dart       # flutter_gemma를 통한 온디바이스 Gemma 4
│   ├── model_download_service.dart    # 모델 다운로드 + 미러 지원
│   ├── notification_service.dart      # 학습 알림
│   ├── ollama_service.dart            # Ollama API용 HTTP 클라이언트
│   ├── pdf_service.dart               # PDF + DOCX 가져오기 및 텍스트 추출
│   ├── quiz_generator.dart            # AI 기반 퀴즈 생성
│   ├── smart_router.dart              # 스마트 모델 선택 + 시스템 오버라이드
│   ├── storage_service.dart           # 로컬 파일/DB 저장소 작업
│   ├── streak_service.dart            # 일일 스트릭 + 뽀모도로 카운터
│   └── study_tools.dart               # 핵심 학습 알고리즘 (SM-2 등)
├── stores/
│   ├── chat_store.dart                # 채팅 세션 유지
│   ├── connection_store.dart          # 연결 상태 관리
│   ├── flashcard_store.dart           # 플래시카드 유지 + 그룹
│   ├── locale_store.dart              # 언어 기본 설정
│   └── theme_store.dart               # 테마 + 글꼴 크기 기본 설정
└── widgets/
    ├── animated_avatar.dart           # AI/사용자 애니메이션 프로필 사진
    ├── chat_session_tile.dart         # 채팅 기록 목록 항목
    ├── code_block.dart                # 구문 강조 코드 표시
    ├── color_scheme_picker.dart       # 테마 색상 선택기
    ├── connection_indicator.dart      # 연결 상태 표시 바
    ├── download_progress_widget.dart  # 모델 다운로드 상태 UI
    ├── flashcard_widget.dart          # 개별 플래시카드 UI
    ├── loading_indicator.dart         # 맞춤형 로딩 애니메이션
    ├── message_bubble.dart            # 채팅 메시지 말풍선
    ├── model_badge.dart               # 모델 소스 표시기 (기기/노트북)
    ├── neumorphic_button.dart         # 뉴모피즘 버튼 위젯
    ├── neumorphic_container.dart      # 뉴모피즘 카드 위젯
    ├── quick_action_chips.dart        # 제안된 프롬프트 칩
    └── quiz_option_tile.dart          # 퀴즈 객관식 버튼
```

---

## 👤 개발자 소개

**Sheng Wei** — 중국 **감숙정법대학 (GSUPL)** AI 전공. 1인 개발자.

이전 프로젝트: **InSeeVision** (Gemma 3 접근성 프로젝트).

- GitHub: [@linyeping](https://github.com/linyeping)
- Kaggle: [linyeping](https://kaggle.com/linyeping)

---

## 📄 라이선스

이 프로젝트는 Apache License 2.0에 따라 라이선스가 부여됩니다 — 자세한 내용은 [LICENSE](LICENSE) 파일을 참조하세요.

Gemma 4 모델은 Google에서 [Gemma 이용 약관](https://ai.google.dev/gemma/terms)에 따라 제공합니다.

---

<p align="center">
  <strong>Gemma 4 Good Hackathon 2026을 위해 ❤️으로 제작되었습니다.</strong><br/>
  <strong>문의: yepinglin20@gmail.com | 201180946@qq.com</strong>
</p>
