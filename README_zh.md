<p align="center">
  <img src="assets/gemmate_logo.png" width="120" alt="GemMate Logo"/>
</p>




<h1 align="center">GemMate</h1>

<p align="center">
  <strong>您的 AI 学习伙伴 — 由 Gemma 4 提供动力</strong>
</p>

<p align="center">
  <a href="#功能">功能</a> •
  <a href="#架构">架构</a> •
  <a href="#演示">演示</a> •
  <a href="#安装">安装</a> •
  <a href="#技术栈">技术栈</a> •
  <a href="#许可">许可</a>
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

## 🌟 什么是 GemMate？

GemMate 通过将 **Google 的 Gemma 4 E2B** 模型与成熟的学习科学技术相结合，改变了大学生的学习方式。这是一个跨平台的 Flutter 应用程序，**100% 本地运行** Gemma 4 — 无需云端，无需 API 密钥，数据不会离开您的设备。

> 💡 **问题：** 学生们很难从讲义和教科书中创建有效的学习材料。现有的 AI 工具需要云端连接，并引发了隐私担忧。
>
> ✅ **解决方案：** GemMate 在您自己的硬件上运行 Gemma 4 E2B，生成个性化的抽认卡、测试和解释 — 即使在飞机上也能使用。

<p align="center">   <img src="assets/cover.png" width="800" alt="Chat Demo"/> </p>

---

## ✨ 功能

### 🧠 与 Gemma 4 进行 AI 聊天
与 Gemma 4 E2B 聊天以理解复杂的概念。使用 6 种支持的语言中的任何一种提问，并获得针对您的水平量身定制的双语解释。

<p align="center">   <img src="assets/demo1.jpg" width="350" alt="Chat Demo"/> </p>

### 📚 智能抽认卡卡组
从任何聊天对话中生成抽认卡卡组。卡片使用 **SM-2 间隔复习算法** 进行科学优化的复习安排。卡组以美观的扇形卡片堆叠显示，并配有翻转动画。

<div align="center">
  <table>
    <tr>
      <td align="center"><b>正面</b></td>
      <td align="center"><b>背面</b></td>
    </tr>
    <tr>
      <td align="center"><img src="assets/demo7.jpg" width="300"/></td>
      <td align="center"><img src="assets/demo8.jpg" width="300"/></td>
    </tr>
  </table>
</div>

### 📊 互动测试
由 AI 生成的多选题测试，用于检验您的理解程度。错误的回答会自动变成抽认卡，以便进行针对性复习。

<p align="center">   <img src="assets/demo2.jpg" width="260" />   <img src="assets/demo3.jpg" width="260" />   <img src="assets/demo4.jpg" width="260" /> </p>

### 📷 相机 / 文字识别
拍摄教科书页面、讲座幻灯片或手写笔记。Gemma 4 的视觉功能可以提取并解释内容。

<p align="center">   <img src="assets/demo9.jpg" width="350" alt="Chat Demo"/> </p>

### 🎤 语音输入
点击麦克风通过语音提问 — 非常适合解放双手学习。支持中文、英文、日文、韩文、法文和西班牙文。

<p align="center">   <img src="assets/demo10.jpg" width="350" alt="Chat Demo"/> </p>

### 🌍 6 种语言
完整的用户界面本地化和人工智能响应，支持：英语、简体中文、日本語、한국어、Français、Español。

<p align="center">   <img src="assets/languages.jpg" width="350" alt="Chat Demo"/> </p>

### 🔔 智能通知
间隔复习提醒、每日学习提示和不活跃提醒让您保持学习进度。

<p align="center">   <img src="assets/Notifications.jpg" width="350" alt="Chat Demo"/> </p>

### 🗺️ AI 思维导图生成器
一键从您的对话中生成可视化的、彩色编码的思维导图 — 使用贝塞尔曲线渲染，并配有互动式平移/缩放画布。非常适合在考试前组织复杂的主题。

<p align="center"><img src="assets/MindMap.jpg" width="350" alt="Mind Map"/></p>

### 📄 文档导入 (PDF + DOCX)
直接将 PDF 和 Word (.docx) 文件导入聊天。GemMate 提取文本并提供给 AI，因此您可以对任何文档进行提问、生成抽认卡或获取摘要 — 无需上传到云端。

<p align="center"><img src="assets/PDF%20%2B%20DOCX.jpg" width="350" alt="PDF and DOCX Import"/></p>

### 📷 相机数学解题器
将相机屏幕切换到**数学解题器**模式，拍摄手写方程或印刷题目。AI 会逐步解答，每一步都可以保存为抽认卡进行强化练习。

<div align="center">
  <table>
    <tr>
      <td align="center"><b>模式选择</b></td>
      <td align="center"><b>正在分析</b></td>
      <td align="center"><b>分步结果</b></td>
    </tr>
    <tr>
      <td align="center"><img src="assets/Mathematics%20Solver-1.jpg" width="220"/></td>
      <td align="center"><img src="assets/Mathematics%20Solver-2.jpg" width="220"/></td>
      <td align="center"><img src="assets/Mathematics%20Solver-3.jpg" width="220"/></td>
    </tr>
  </table>
</div>

### 🔲 二维码共享与相册扫描
通过生成的二维码与同学分享抽认卡卡组，或者从您的相册图像中扫描二维码 — 无需将相机对准屏幕。

<div align="center">
  <table>
    <tr>
      <td align="center"><b>扫描界面</b></td>
      <td align="center"><b>通过二维码分享</b></td>
    </tr>
    <tr>
      <td align="center"><img src="assets/QR%20Code%20Scanning%20Interface.jpg" width="280"/></td>
      <td align="center"><img src="assets/Example%20QR%20Code.jpg" width="280"/></td>
    </tr>
  </table>
</div>

### 🍅 自定义番茄钟
直接从主屏幕设置您自己的专注和休息时长（1–120 分钟 / 1–60 分钟）。直接输入数字或点击 +/-。学习时长每天都会被追踪并存储在本地。

<div align="center">
  <table>
    <tr>
      <td align="center"><b>计时器</b></td>
      <td align="center"><b>自定义设置</b></td>
    </tr>
    <tr>
      <td align="center"><img src="assets/Pomodoro%20timer%20interface.jpg" width="280"/></td>
      <td align="center"><img src="assets/Pomodoro%20timer%20settings.jpg" width="280"/></td>
    </tr>
  </table>
</div>

### 🎨 新拟物化设计
美观的新拟物化用户界面，配有深色/浅色模式、可定制的主题色和可调节的字体大小。

<p align="center">   <img src="assets/theme.jpg" width="350" alt="Chat Demo"/> </p>

---

## 🏗️ 架构

GemMate 使用**智能路由架构**，自动选择最佳的可用 AI 模型：

```
┌─────────────────────────────────────────────────┐
│                  📱 手机                       │
│             GemMate Flutter 应用                │
│                                                 │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐       │
│  │   聊天   │  │   卡片   │  │   测试   │       │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘       │
│       │              │              │           │
│       └──────────────┼──────────────┘           │
│                      │                          │
│              ┌───────▼────────┐                 │
│              │    智能路由器    │                 │
│              └───┬───────┬─-──┘                 │
│                  │       │                      │
│     ┌────────────▼─┐  ┌──▼───────────────┐      │
│     │   设备端     │  │   Ollama HTTP    │      │
│     │  Gemma 4 E2B │  │      连接        │      │
│     │   (离线)     │  │   (WiFi 局域网)   │      │
│     └──────────────┘  └──────┬───────────┘      │
│                              │                  │
└──────────────────────────────┼──────────────────┘
                               │ WiFi (本地网络)
┌──────────────────────────────▼───────────────────┐
│                  💻 笔记本电脑                   │
│           Ollama + Gemma 4 E4B                   │
│         (RTX 4060, <1s 响应)                     │
└──────────────────────────────────────────────────┘
```

### 智能路由逻辑

| 条件 | 使用的模型 | 延迟 |
|-----------|-----------|---------|
| WiFi + 笔记本电脑可用 | 通过 Ollama 使用 Gemma 4 E4B (笔记本 GPU) | <1s |
| 无 WiFi，已安装模型 | 设备端运行 Gemma 4 E2B (手机 CPU) | 3-8s |
| WiFi + 无笔记本电脑 | 设备端运行 Gemma 4 E2B | 3-8s |
| 无 WiFi，无模型 | 提示下载模型 | — |

---

## 🎬 演示

📺 **[观看 3 分钟演示视频 →](https://youtu.be/tLnDOzBy_Kc)**

📦 **[下载 APK →](https://github.com/linyeping/GemMate/releases/latest)**

---

## 🚀 安装

### 前提条件

- Flutter 3.41+ ([安装 Flutter](https://flutter.dev/docs/get-started/install))
- Android 设备 (Android 8.0+) 或模拟器
- 对于笔记本电脑 AI：[Ollama](https://ollama.ai) + `ollama pull gemma4:e2b`

### 从源码构建

```bash
# 克隆仓库
git clone https://github.com/linyeping/GemMate.git
cd GemMate

# 安装依赖
flutter pub get

# 在连接的设备上运行
flutter run

# 构建 APK
flutter build apk --release
```

### 设置笔记本电脑 AI (可选，推荐)

```bash
# 安装 Ollama (https://ollama.ai)
ollama pull gemma4:e2b

# 开启网络访问启动
OLLAMA_HOST=0.0.0.0:11434 ollama serve

# 在 GemMate 设置 → 连接 → 输入笔记本电脑 IP
```

### 安装设备端模型 (可选，用于离线使用)

方案 A：在应用内下载（设置 → 模型管理 → 下载）

方案 B：通过 ADB 手动安装：
```bash
# 从 Hugging Face 镜像（中国）下载
curl -L -o gemma-4-E2B-it.litertlm "https://hf-mirror.com/litert-community/gemma-4-E2B-it-litert-lm/resolve/main/gemma-4-E2B-it.litertlm"

# 推送到手机
adb push gemma-4-E2B-it.litertlm /sdcard/Download/

# 在应用内：设置 → 模型管理 → 从 /sdcard/Download/ 加载
```

---

## 🛠️ 技术栈

| 组件 | 技术 |
|-----------|-----------|
| **AI 模型** | Gemma 4 E2B / Gemma 4 E4B |
| **设备端运行环境** | 通过 flutter_gemma 使用 LiteRT-LM |
| **本地服务器** | Ollama (笔记本电脑，GPU 加速) |
| **应用框架** | Flutter 3.41 / Dart |
| **学习算法** | SM-2 间隔复习 |
| **语音输入** | speech_to_text |
| **文字识别 / 视觉** | ML Kit (离线) + Gemma 4 多模态 (Ollama) |
| **二维码** | mobile_scanner 5.x |
| **文档导入** | pdfx + archive (DOCX ZIP/XML 解析) |
| **思维导图** | CustomPainter + InteractiveViewer |
| **通知** | flutter_local_notifications |
| **存储** | SharedPreferences + JSON |
| **用户界面设计** | 自定义新拟物化组件 |

---

## 📁 项目结构

```
lib/
├── main.dart                          # 应用入口 + 模型初始化
├── app/
│   ├── router.dart                    # 底部导航 + 页面路由
│   └── theme.dart                     # 新拟物化主题 (浅色/深色)
├── core/
│   ├── constants.dart                 # 应用常量 + 颜色
│   ├── json_utils.dart                # JSON 解析工具
│   ├── text_utils.dart                # 文本处理和格式化
│   └── utils.dart                     # 通用辅助函数
├── l10n/
│   ├── app_localizations.dart         # 国际化委托
│   ├── locale_en.dart                 # 英文本地化
│   ├── locale_es.dart                 # 西班牙文本地化
│   ├── locale_fr.dart                 # 法文本地化
│   ├── locale_ja.dart                 # 日文本地化
│   ├── locale_ko.dart                 # 韩文本地化
│   └── locale_zh.dart                 # 中文本地化
├── models/
│   ├── chat_message.dart              # 聊天消息模型
│   ├── chat_session.dart              # 聊天会话模型
│   ├── flashcard.dart                 # 带有 SM-2 字段 + 分组的抽认卡
│   ├── quiz.dart                      # 测试状态模型
│   ├── quiz_question.dart             # 测试题目模型
│   ├── quiz_result.dart               # 已完成测试的摘要和评分
│   └── study_plan.dart                # 间隔复习计划模型
├── screens/
│   ├── capture_screen.dart            # 相机 / 文字识别 (OCR) + 数学解题模式
│   ├── chat_history_screen.dart       # 聊天会话管理
│   ├── chat_screen.dart               # 主聊天 UI + 语音 + 思维导图 + 文档导入
│   ├── deck_study_screen.dart         # 翻卡学习会话
│   ├── exam_history_screen.dart       # 过去考试记录
│   ├── exam_screen.dart               # 定时考试模式
│   ├── flashcard_screen.dart          # 带有扇形堆叠的卡组画廊
│   ├── home_screen.dart               # 仪表板 + 自定义番茄钟
│   ├── mind_map_screen.dart           # AI 生成的互动思维导图
│   ├── onboarding_screen.dart         # 首次启动设置 + 模型下载
│   ├── paper_screen.dart              # 学习试卷的详细查看和导出
│   ├── qr_scan_screen.dart            # 二维码扫描 (相机 + 相册)
│   ├── qr_share_screen.dart           # 卡组的二维码共享
│   ├── quiz_screen.dart               # 互动测试 UI
│   ├── review_screen.dart             # 计划复习仪表板
│   └── settings_screen.dart           # 带有子页面的设置
├── services/
│   ├── flashcard_generator.dart       # AI 驱动的抽认卡创建
│   ├── local_gemma_service.dart       # 通过 flutter_gemma 实现的设备端 Gemma 4
│   ├── model_download_service.dart    # 模型下载 + 镜像支持
│   ├── notification_service.dart      # 学习提醒
│   ├── ollama_service.dart            # Ollama API 的 HTTP 客户端
│   ├── pdf_service.dart               # PDF + DOCX 导入和文本提取
│   ├── quiz_generator.dart            # AI 驱动的测试生成
│   ├── smart_router.dart              # 智能模型选择 + 系统覆盖
│   ├── storage_service.dart           # 本地文件/数据库存储操作
│   ├── streak_service.dart            # 每日坚持 + 番茄钟计数器
│   └── study_tools.dart               # 核心学习算法 (SM-2 等)
├── stores/
│   ├── chat_store.dart                # 聊天会话持久化
│   ├── connection_store.dart          # 连接状态管理
│   ├── flashcard_store.dart           # 抽认卡持久化 + 分组
│   ├── locale_store.dart              # 语言偏好
│   └── theme_store.dart               # 主题 + 字体大小偏好
└── widgets/
    ├── animated_avatar.dart           # AI/用户动画头像
    ├── chat_session_tile.dart         # 聊天历史列表项
    ├── code_block.dart                # 语法高亮的代码显示
    ├── color_scheme_picker.dart       # 主题颜色选择器
    ├── connection_indicator.dart      # 连接状态指示条
    ├── download_progress_widget.dart  # 模型下载进度 UI
    ├── flashcard_widget.dart          # 单个抽认卡 UI
    ├── loading_indicator.dart         # 自定义加载动画
    ├── message_bubble.dart            # 聊天消息气泡
    ├── model_badge.dart               # 模型来源指示 (边缘/笔记本)
    ├── neumorphic_button.dart         # 新拟物化按钮组件
    ├── neumorphic_container.dart      # 新拟物化卡片组件
    ├── quick_action_chips.dart        # 建议提示词碎片
    └── quiz_option_tile.dart          # 测试多选题按钮
```

---

## 👤 关于开发者

**盛伟 & 林业平** — 就读于**甘肃政法大学**，人工智能专业。

过往项目：**InSeeVision** (Gemma 3 无障碍项目)。

- GitHub: [@林业平](https://github.com/linyeping)
- Kaggle: [林业平](https://kaggle.com/linyeping)

---

## 📄 许可

此项目根据 Apache License 2.0 获得许可 — 有关详细信息，请参阅 [LICENSE](LICENSE) 文件。

Gemma 4 模型由 Google 根据 [Gemma 使用条款](https://ai.google.dev/gemma/terms)提供。

---

<p align="center">
  <strong>为 2026 Gemma 4 Good Hackathon 精心打造 ❤️</strong><br/>
  <strong>联系方式：yepinglin20@gmail.com | 201180946@qq.com</strong>
</p>
