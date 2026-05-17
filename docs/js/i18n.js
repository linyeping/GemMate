/**
 * GemMate i18n — Chinese / English bilingual support
 */
const translations = {
  en: {
    // Nav
    "nav.home": "Home",
    "nav.features": "Features",
    "nav.architecture": "Architecture",
    "nav.about": "About",
    "nav.download": "Download",

    // Hero
    "hero.badge": "Built for Gemma 4 Good Hackathon 2026",
    "hero.title1": "Your AI Study",
    "hero.title2": "Companion",
    "hero.subtitle": "Powered by Google's Gemma 4 — runs 100% on your device. No cloud. No API keys. Your data never leaves your phone.",
    "hero.cta1": "Download APK",
    "hero.cta2": "Watch Demo",
    "hero.stat1": "Features",
    "hero.stat2": "Languages",
    "hero.stat3": "Offline",
    "hero.stat4": "Response",
    "hero.chip1": "Gemma 4 E2B",
    "hero.chip2": "100% Private",
    "hero.chip3": "On-Device AI",

    // Problem / Solution
    "problem.label": "The Problem",
    "problem.title": "Cloud AI Isn't Built for Students",
    "problem.desc": "Existing AI tools require constant internet, charge subscription fees, and send your study data to remote servers. In a library, on a train, or during exams — when you need help most, cloud AI lets you down.",
    "solution.label": "The Solution",
    "solution.title": "GemMate: AI That Lives on Your Phone",
    "solution.desc": "GemMate runs Google's Gemma 4 E2B directly on your device. Generate flashcards, take quizzes, build mind maps — all without internet. Your data never leaves your phone. Zero cost. Zero compromise.",

    // Features overview
    "features.label": "Features",
    "features.title": "Everything You Need to ",
    "features.title-highlight": "Study Smarter",
    "features.subtitle": "12 powerful AI-driven tools, all running locally on your device",
    "features.viewall": "Explore All Features →",

    "feat.chat": "AI Chat",
    "feat.chat.desc": "Chat with Gemma 4 in 6 languages",
    "feat.flashcards": "Smart Flashcards",
    "feat.flashcards.desc": "AI-generated with SM-2 spaced repetition",
    "feat.quiz": "Interactive Quizzes",
    "feat.quiz.desc": "Auto-generated multiple choice tests",
    "feat.ocr": "Camera / OCR",
    "feat.ocr.desc": "Scan textbooks and get AI explanations",
    "feat.voice": "Voice Input",
    "feat.voice.desc": "Hands-free in 6 languages",
    "feat.i18n": "6 Languages",
    "feat.i18n.desc": "Full UI in EN, ZH, JA, KO, FR, ES",
    "feat.notif": "Smart Notifications",
    "feat.notif.desc": "Spaced repetition reminders",
    "feat.mindmap": "Mind Maps",
    "feat.mindmap.desc": "One-tap AI visual knowledge maps",
    "feat.docs": "Document Import",
    "feat.docs.desc": "Import PDF & DOCX files",
    "feat.math": "Math Solver",
    "feat.math.desc": "Camera-based equation solving",
    "feat.qr": "QR Sharing",
    "feat.qr.desc": "Share flashcard decks via QR code",
    "feat.pomodoro": "Pomodoro Timer",
    "feat.pomodoro.desc": "Customizable focus sessions",

    // Demo
    "demo.label": "Demo",
    "demo.title": "See GemMate ",
    "demo.title-highlight": "in Action",
    "demo.also-youtube": "Also available on ",

    // Stats
    "stats.features": "AI-Powered Features",
    "stats.languages": "Languages Supported",
    "stats.offline": "Offline Capable",
    "stats.cost": "Cost to Use",

    // CTA
    "cta.title": "Ready to Study ",
    "cta.title-highlight": "Smarter",
    "cta.subtitle": "Download GemMate and experience AI-powered studying — no internet required.",
    "cta.download": "Download Now",
    "cta.github": "View on GitHub",

    // Footer
    "footer.desc": "AI-powered study companion built with Google's Gemma 4. 100% on-device, 100% private.",
    "footer.hackathon": "Gemma 4 Good Hackathon 2026",
    "footer.product": "Product",
    "footer.resources": "Resources",
    "footer.connect": "Connect",
    "footer.demo": "Demo Video",
    "footer.releases": "Releases",

    // === Architecture Page ===
    "arch.label": "Architecture",
    "arch.title": "How GemMate ",
    "arch.title-highlight": "Works",
    "arch.subtitle": "Smart routing between on-device and local GPU inference",
    "arch.router.title": "Smart Router",
    "arch.router.desc": "GemMate automatically selects the best AI model based on your connectivity and hardware.",
    "arch.ondevice": "On-Device",
    "arch.ondevice.model": "Gemma 4 E2B",
    "arch.ondevice.desc": "Runs directly on your phone via LiteRT-LM. Works offline, 3-8s latency.",
    "arch.ollama": "LAN GPU",
    "arch.ollama.model": "Gemma 4 E4B",
    "arch.ollama.desc": "Connects to Ollama on your laptop via WiFi. Sub-second response.",
    "arch.condition": "Condition",
    "arch.model": "Model",
    "arch.latency": "Latency",
    "arch.c1": "WiFi + Laptop available",
    "arch.c1.model": "Gemma 4 E4B via Ollama",
    "arch.c1.latency": "< 1s",
    "arch.c2": "No WiFi, model installed",
    "arch.c2.model": "Gemma 4 E2B on-device",
    "arch.c2.latency": "3-8s",
    "arch.c3": "WiFi + No laptop",
    "arch.c3.model": "Gemma 4 E2B on-device",
    "arch.c3.latency": "3-8s",
    "arch.c4": "No WiFi, no model",
    "arch.c4.model": "Prompt to download",
    "arch.c4.latency": "—",
    "arch.tech.label": "Tech Stack",
    "arch.tech.title": "Built With ",
    "arch.tech.title-highlight": "Modern Tools",
    "arch.privacy.title": "Privacy by Design",
    "arch.privacy.desc": "Your data never leaves your device. No cloud. No tracking. No API keys. Open source under Apache 2.0.",
    "arch.privacy.1": "Zero data collection — all processing stays on your device",
    "arch.privacy.2": "No API keys needed — Gemma 4 runs locally",
    "arch.privacy.3": "Open source — audit the code yourself on GitHub",

    // === About Page ===
    "about.label": "About",
    "about.title": "Meet the ",
    "about.title-highlight": "Developer",
    "about.name": "YePing Lin",
    "about.role": "Developer & AI Enthusiast",
    "about.university": "Gansu University of Political Science and Law",
    "about.major": "Artificial Intelligence",
    "about.bio": "Passionate about making AI accessible for everyday learning. GemMate was born from the belief that powerful AI tools should work without internet and keep your data private.",
    "about.hackathon.label": "The Hackathon",
    "about.hackathon.title": "Gemma 4 Good Hackathon 2026",
    "about.hackathon.desc": "GemMate was built for the Gemma 4 Good Hackathon 2026, a global challenge to create impactful applications using Google's Gemma 4 models. The goal: leverage on-device AI to solve real-world problems while keeping user data 100% private.",
    "about.project.label": "The Project",
    "about.project.title": "Why GemMate?",
    "about.project.desc": "University students struggle to create effective study materials. Cloud AI tools require subscriptions and internet. GemMate solves this by running Gemma 4 directly on your phone — generating flashcards, quizzes, and mind maps anywhere, anytime, for free.",
    "about.contact.label": "Get in Touch",

    // === Download Page ===
    "dl.label": "Download",
    "dl.title": "Get ",
    "dl.title-highlight": "GemMate",
    "dl.subtitle": "Download the APK and start studying smarter today",
    "dl.btn": "Download Latest APK",
    "dl.version": "Version 1.3.0 · Android 8.0+",
    "dl.source.title": "Build from Source",
    "dl.source.desc": "Want to build GemMate yourself? Clone the repository and build with Flutter.",
    "dl.ollama.title": "Laptop GPU Setup (Optional)",
    "dl.ollama.desc": "For faster AI responses, connect GemMate to Ollama running on your laptop.",
    "dl.model.title": "On-Device Model",
    "dl.model.desc": "Download the Gemma 4 E2B model directly in the app, or push it via ADB.",

    // === Features Detail Page ===
    "fd.label": "Features",
    "fd.title": "Powerful Tools for ",
    "fd.title-highlight": "Smarter Learning",
    "fd.subtitle": "Explore every feature in detail",
    "fd.themes.title": "Beautiful Themes",
    "fd.themes.desc": "8 carefully crafted color schemes with light and dark modes. Neumorphic design for a modern, comfortable experience.",

    // Feature bullets
    "feat.chat.b1": "Natural conversation with Gemma 4 E2B",
    "feat.chat.b2": "Bilingual explanations for deeper understanding",
    "feat.chat.b3": "Context-aware follow-up questions",
    "feat.flashcards.b1": "AI generates flashcards from any topic",
    "feat.flashcards.b2": "SM-2 algorithm optimizes review schedule",
    "feat.flashcards.b3": "Fan-shaped card piles with flip animations",
    "feat.quiz.b1": "AI creates quizzes from your study topics",
    "feat.quiz.b2": "Wrong answers auto-convert to flashcards",
    "feat.quiz.b3": "Score tracking and progress visualization",
    "feat.ocr.b1": "Photograph any textbook page",
    "feat.ocr.b2": "ML Kit OCR extracts text offline",
    "feat.ocr.b3": "Gemma 4 explains the content",
    "feat.voice.b1": "Speech-to-text in 6 languages",
    "feat.voice.b2": "Ask questions without typing",
    "feat.voice.b3": "Perfect for on-the-go studying",
    "feat.i18n.b1": "English, Chinese, Japanese, Korean, French, Spanish",
    "feat.i18n.b2": "Complete UI localization",
    "feat.i18n.b3": "Automatic language detection",
    "feat.notif.b1": "Review reminders based on SM-2 schedule",
    "feat.notif.b2": "Daily study prompts",
    "feat.notif.b3": "Inactivity nudges to keep you on track",
    "feat.mindmap.b1": "AI generates topic mind maps instantly",
    "feat.mindmap.b2": "Bezier curves and interactive canvas",
    "feat.mindmap.b3": "Pan, zoom, and explore connections",
    "feat.docs.b1": "Import PDF files with text extraction",
    "feat.docs.b2": "DOCX support via ZIP/XML parsing",
    "feat.docs.b3": "Generate study materials from your docs",
    "feat.math.b1": "Photograph handwritten equations",
    "feat.math.b2": "Step-by-step AI solutions",
    "feat.math.b3": "Save solutions as flashcards",
    "feat.qr.b1": "Generate QR codes for any flashcard deck",
    "feat.qr.b2": "Scan QR from camera or gallery",
    "feat.qr.b3": "Share study materials with classmates",
    "feat.pomodoro.b1": "Adjustable focus (1-120 min) and break (1-60 min)",
    "feat.pomodoro.b2": "Daily session tracking",
    "feat.pomodoro.b3": "Helps maintain consistent study habits",

    // Theme names
    "theme.ocean": "Ocean",
    "theme.sunset": "Sunset",
    "theme.forest": "Forest",
    "theme.lavender": "Lavender",
    "theme.aurora": "Aurora",
    "theme.cherry": "Cherry",
    "theme.midnight": "Midnight",
    "theme.candy": "Candy",

    // Architecture tech cards
    "arch.app.title": "GemMate App",
    "arch.app.subtitle": "Chat · Flashcards · Quizzes · Mind Maps",
    "arch.tech.ai": "AI Model",
    "arch.tech.runtime": "Runtime",
    "arch.tech.framework": "Framework",
    "arch.tech.algo": "Study Algorithm",
    "arch.tech.ocr": "OCR / Vision",
    "arch.tech.storage": "Storage",

    // Download extras
    "dl.ollama.step1": "Install Ollama",
    "dl.ollama.step2": "Start Ollama Server",
    "dl.ollama.step3": "Connect from GemMate",
    "dl.ollama.step3.desc": "Open GemMate Settings, enter your laptop's IP address (e.g. 192.168.1.100:11434). GemMate will auto-detect and use the faster GPU model when connected.",
    "dl.model.inapp": "In-App Download",
    "dl.model.inapp.desc": "Open GemMate → Settings → Download Model. The app will download and install Gemma 4 E2B automatically.",
    "dl.model.adb": "ADB Push",
  },
  zh: {
    // Nav
    "nav.home": "首页",
    "nav.features": "功能",
    "nav.architecture": "架构",
    "nav.about": "关于",
    "nav.download": "下载",

    // Hero
    "hero.badge": "为 Gemma 4 Good Hackathon 2026 打造",
    "hero.title1": "您的 AI 学习",
    "hero.title2": "伙伴",
    "hero.subtitle": "由 Google Gemma 4 驱动 — 100% 本地运行。无需云端，无需 API 密钥，数据永不离开您的手机。",
    "hero.cta1": "下载 APK",
    "hero.cta2": "观看演示",
    "hero.stat1": "功能",
    "hero.stat2": "语言",
    "hero.stat3": "离线",
    "hero.stat4": "响应",
    "hero.chip1": "Gemma 4 E2B",
    "hero.chip2": "100% 隐私",
    "hero.chip3": "端侧 AI",

    // Problem / Solution
    "problem.label": "痛点",
    "problem.title": "云端 AI 并非为学生而生",
    "problem.desc": "现有 AI 工具需要持续联网、收取订阅费用，并将您的学习数据发送到远程服务器。在图书馆、在地铁上、在考试期间 — 当您最需要帮助时，云端 AI 却无能为力。",
    "solution.label": "解决方案",
    "solution.title": "GemMate：活在手机里的 AI",
    "solution.desc": "GemMate 直接在您的设备上运行 Google Gemma 4 E2B。生成抽认卡、参加测验、构建思维导图 — 全部无需联网。数据永不离开手机。零成本，零妥协。",

    // Features overview
    "features.label": "功能特性",
    "features.title": "你需要的一切，",
    "features.title-highlight": "高效学习利器",
    "features.subtitle": "12 项强大的 AI 驱动工具，全部在本地设备上运行",
    "features.viewall": "探索全部功能 →",

    "feat.chat": "AI 对话",
    "feat.chat.desc": "用 6 种语言与 Gemma 4 对话",
    "feat.flashcards": "智能抽认卡",
    "feat.flashcards.desc": "AI 生成 + SM-2 间隔重复算法",
    "feat.quiz": "互动测验",
    "feat.quiz.desc": "自动生成选择题测试",
    "feat.ocr": "相机 / OCR",
    "feat.ocr.desc": "扫描教科书获取 AI 解析",
    "feat.voice": "语音输入",
    "feat.voice.desc": "6 种语言免手操作",
    "feat.i18n": "6 种语言",
    "feat.i18n.desc": "完整界面：中英日韩法西",
    "feat.notif": "智能提醒",
    "feat.notif.desc": "间隔重复学习提醒",
    "feat.mindmap": "思维导图",
    "feat.mindmap.desc": "一键 AI 生成知识脑图",
    "feat.docs": "文档导入",
    "feat.docs.desc": "导入 PDF 和 DOCX 文件",
    "feat.math": "数学解题",
    "feat.math.desc": "拍照识别手写方程式",
    "feat.qr": "二维码分享",
    "feat.qr.desc": "通过二维码分享抽认卡组",
    "feat.pomodoro": "番茄钟",
    "feat.pomodoro.desc": "可自定义的专注计时",

    // Demo
    "demo.label": "演示",
    "demo.title": "看看 GemMate ",
    "demo.title-highlight": "如何运作",
    "demo.also-youtube": "也可在 ",

    // Stats
    "stats.features": "AI 驱动功能",
    "stats.languages": "支持语言数",
    "stats.offline": "离线可用",
    "stats.cost": "使用成本",

    // CTA
    "cta.title": "准备好",
    "cta.title-highlight": "开启高效学习",
    "cta.subtitle": "下载 GemMate，体验无需联网的 AI 学习助手。",
    "cta.download": "立即下载",
    "cta.github": "在 GitHub 查看",

    // Footer
    "footer.desc": "由 Google Gemma 4 驱动的 AI 学习伴侣。100% 本地运行，100% 隐私保护。",
    "footer.hackathon": "Gemma 4 Good Hackathon 2026",
    "footer.product": "产品",
    "footer.resources": "资源",
    "footer.connect": "联系",
    "footer.demo": "演示视频",
    "footer.releases": "版本发布",

    // === Architecture Page ===
    "arch.label": "架构",
    "arch.title": "GemMate ",
    "arch.title-highlight": "工作原理",
    "arch.subtitle": "端侧推理与局域网 GPU 加速之间的智能路由",
    "arch.router.title": "智能路由",
    "arch.router.desc": "GemMate 根据网络连接和硬件条件，自动选择最佳 AI 模型。",
    "arch.ondevice": "端侧运行",
    "arch.ondevice.model": "Gemma 4 E2B",
    "arch.ondevice.desc": "通过 LiteRT-LM 直接在手机上运行。支持离线，延迟 3-8 秒。",
    "arch.ollama": "局域网 GPU",
    "arch.ollama.model": "Gemma 4 E4B",
    "arch.ollama.desc": "通过 WiFi 连接笔记本上的 Ollama。亚秒级响应。",
    "arch.condition": "条件",
    "arch.model": "模型",
    "arch.latency": "延迟",
    "arch.c1": "WiFi + 笔记本可用",
    "arch.c1.model": "Gemma 4 E4B（Ollama）",
    "arch.c1.latency": "< 1秒",
    "arch.c2": "无WiFi，已安装模型",
    "arch.c2.model": "Gemma 4 E2B（端侧）",
    "arch.c2.latency": "3-8秒",
    "arch.c3": "WiFi + 无笔记本",
    "arch.c3.model": "Gemma 4 E2B（端侧）",
    "arch.c3.latency": "3-8秒",
    "arch.c4": "无WiFi，未安装模型",
    "arch.c4.model": "提示下载",
    "arch.c4.latency": "—",
    "arch.tech.label": "技术栈",
    "arch.tech.title": "采用",
    "arch.tech.title-highlight": "现代技术构建",
    "arch.privacy.title": "隐私至上设计",
    "arch.privacy.desc": "您的数据永远不会离开设备。无云端、无追踪、无 API 密钥。Apache 2.0 开源协议。",
    "arch.privacy.1": "零数据采集 — 所有处理均在设备上完成",
    "arch.privacy.2": "无需 API 密钥 — Gemma 4 本地运行",
    "arch.privacy.3": "开源项目 — 在 GitHub 上审查代码",

    // === About Page ===
    "about.label": "关于",
    "about.title": "认识",
    "about.title-highlight": "开发者",
    "about.name": "林业平",
    "about.role": "开发者 & AI 爱好者",
    "about.university": "甘肃政法大学",
    "about.major": "人工智能专业",
    "about.bio": "热衷于让 AI 技术服务于日常学习。GemMate 诞生于一个信念：强大的 AI 工具应该无需联网就能工作，并且保护用户的数据隐私。",
    "about.hackathon.label": "关于比赛",
    "about.hackathon.title": "Gemma 4 Good Hackathon 2026",
    "about.hackathon.desc": "GemMate 是为 Gemma 4 Good Hackathon 2026 打造的参赛作品。这是一场全球性挑战赛，旨在利用 Google 的 Gemma 4 模型创造有影响力的应用。目标：利用端侧 AI 解决现实世界的问题，同时确保用户数据 100% 私密。",
    "about.project.label": "关于项目",
    "about.project.title": "为什么做 GemMate？",
    "about.project.desc": "大学生在创建有效学习材料时困难重重。云端 AI 工具需要订阅和联网。GemMate 通过直接在手机上运行 Gemma 4 解决了这个问题 — 随时随地免费生成抽认卡、测验和思维导图。",
    "about.contact.label": "联系方式",

    // === Download Page ===
    "dl.label": "下载",
    "dl.title": "获取 ",
    "dl.title-highlight": "GemMate",
    "dl.subtitle": "下载 APK，立即开始更高效地学习",
    "dl.btn": "下载最新 APK",
    "dl.version": "版本 1.3.0 · Android 8.0+",
    "dl.source.title": "从源码构建",
    "dl.source.desc": "想自己构建 GemMate？克隆仓库并使用 Flutter 构建。",
    "dl.ollama.title": "笔记本 GPU 设置（可选）",
    "dl.ollama.desc": "为获得更快的 AI 响应，将 GemMate 连接到笔记本上运行的 Ollama。",
    "dl.model.title": "端侧模型",
    "dl.model.desc": "直接在应用内下载 Gemma 4 E2B 模型，或通过 ADB 推送。",

    // === Features Detail Page ===
    "fd.label": "功能详情",
    "fd.title": "强大的工具助你",
    "fd.title-highlight": "高效学习",
    "fd.subtitle": "深入了解每一项功能",
    "fd.themes.title": "精美主题",
    "fd.themes.desc": "8 套精心设计的配色方案，支持浅色和深色模式。拟物化设计，带来现代舒适的体验。",

    // Feature bullets
    "feat.chat.b1": "与 Gemma 4 E2B 自然对话",
    "feat.chat.b2": "双语解释，加深理解",
    "feat.chat.b3": "上下文感知的智能追问",
    "feat.flashcards.b1": "AI 根据任意主题生成抽认卡",
    "feat.flashcards.b2": "SM-2 算法优化复习计划",
    "feat.flashcards.b3": "扇形卡堆，带翻转动画",
    "feat.quiz.b1": "AI 根据学习主题自动出题",
    "feat.quiz.b2": "错题自动转为抽认卡",
    "feat.quiz.b3": "成绩跟踪与进度可视化",
    "feat.ocr.b1": "拍摄任意教科书页面",
    "feat.ocr.b2": "ML Kit OCR 离线提取文字",
    "feat.ocr.b3": "Gemma 4 解析内容",
    "feat.voice.b1": "支持 6 种语言的语音转文字",
    "feat.voice.b2": "无需打字即可提问",
    "feat.voice.b3": "随时随地学习的完美方式",
    "feat.i18n.b1": "英语、中文、日语、韩语、法语、西班牙语",
    "feat.i18n.b2": "完整的界面本地化",
    "feat.i18n.b3": "自动检测语言",
    "feat.notif.b1": "基于 SM-2 算法的复习提醒",
    "feat.notif.b2": "每日学习提示",
    "feat.notif.b3": "未学习时温馨提醒",
    "feat.mindmap.b1": "AI 即时生成主题思维导图",
    "feat.mindmap.b2": "贝塞尔曲线与交互式画布",
    "feat.mindmap.b3": "平移、缩放，探索知识关联",
    "feat.docs.b1": "导入 PDF 文件并提取文字",
    "feat.docs.b2": "通过 ZIP/XML 解析支持 DOCX",
    "feat.docs.b3": "从文档生成学习材料",
    "feat.math.b1": "拍照识别手写方程式",
    "feat.math.b2": "AI 逐步解题",
    "feat.math.b3": "将解答保存为抽认卡",
    "feat.qr.b1": "为任意抽认卡组生成二维码",
    "feat.qr.b2": "从相机或相册扫描二维码",
    "feat.qr.b3": "与同学分享学习资料",
    "feat.pomodoro.b1": "可调专注时间（1-120分钟）和休息时间（1-60分钟）",
    "feat.pomodoro.b2": "每日学习时段追踪",
    "feat.pomodoro.b3": "帮助养成持续学习的习惯",

    // Theme names
    "theme.ocean": "海洋",
    "theme.sunset": "日落",
    "theme.forest": "森林",
    "theme.lavender": "薰衣草",
    "theme.aurora": "极光",
    "theme.cherry": "樱花",
    "theme.midnight": "午夜",
    "theme.candy": "糖果",

    // Architecture tech cards
    "arch.app.title": "GemMate 应用",
    "arch.app.subtitle": "对话 · 抽认卡 · 测验 · 思维导图",
    "arch.tech.ai": "AI 模型",
    "arch.tech.runtime": "运行时",
    "arch.tech.framework": "开发框架",
    "arch.tech.algo": "学习算法",
    "arch.tech.ocr": "OCR / 视觉",
    "arch.tech.storage": "数据存储",

    // Download extras
    "dl.ollama.step1": "安装 Ollama",
    "dl.ollama.step2": "启动 Ollama 服务",
    "dl.ollama.step3": "从 GemMate 连接",
    "dl.ollama.step3.desc": "打开 GemMate 设置，输入笔记本的 IP 地址（例如 192.168.1.100:11434）。GemMate 会自动检测并使用更快的 GPU 模型。",
    "dl.model.inapp": "应用内下载",
    "dl.model.inapp.desc": "打开 GemMate → 设置 → 下载模型。应用会自动下载并安装 Gemma 4 E2B。",
    "dl.model.adb": "ADB 推送",
  }
};

// ---- Language engine ----
const I18n = {
  currentLang: 'en',

  init() {
    const saved = localStorage.getItem('gemmate-lang');
    if (saved && translations[saved]) {
      this.currentLang = saved;
    } else if (navigator.language && navigator.language.startsWith('zh')) {
      this.currentLang = 'zh';
    }
    this.apply();
    this.updateToggle();
  },

  setLang(lang) {
    if (!translations[lang]) return;
    this.currentLang = lang;
    localStorage.setItem('gemmate-lang', lang);
    document.documentElement.lang = lang === 'zh' ? 'zh-CN' : 'en';
    this.apply();
    this.updateToggle();
  },

  apply() {
    const t = translations[this.currentLang];
    document.querySelectorAll('[data-i18n]').forEach(el => {
      const key = el.getAttribute('data-i18n');
      if (t[key] !== undefined) {
        el.textContent = t[key];
      }
    });
    // Update page title based on current page
    document.documentElement.lang = this.currentLang === 'zh' ? 'zh-CN' : 'en';
  },

  updateToggle() {
    document.querySelectorAll('.lang-toggle__btn').forEach(btn => {
      btn.classList.toggle('is-active', btn.dataset.lang === this.currentLang);
    });
  }
};

// Bind toggle buttons
document.addEventListener('DOMContentLoaded', () => {
  document.querySelectorAll('.lang-toggle__btn').forEach(btn => {
    btn.addEventListener('click', () => {
      I18n.setLang(btn.dataset.lang);
    });
  });
});
