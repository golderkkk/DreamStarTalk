# 拾梦·星语 (DreamStarTalk)

使用 flutter开发的沉浸式 AI 角色扮演应用，支持多角色对话、世界观构建与场景叙事。

## 功能特性

- **多角色对话** — 同时与多个 AI 角色互动，支持 @mention 指定角色回复
- **世界观系统** — 场景管理、NPC 库、剧情线，构建完整的幻想世界
- **角色卡系统** — 25 个内置角色卡，支持 PNG/JSON 导入导出（兼容SillyTavern 格式）
- **多 AI 引擎** — 支持 MiMo、DeepSeek、OpenAI、Claude、Gemini、Ollama 等
- **对话风格** — 写作人称、语气、特化模式，内容控制
- **TTS 语音** — MiMo TTS 集成，9 种内置音色
- **场景系统** — 时间/天气/氛围选择，场景横幅显示

## 快速开始

```bash
# 安装依赖
flutter pub get

# 运行（调试模式）
flutter run

# 构建 Android APK
flutter build apk --release
```

## 项目结构

```
lib/
├── app/                    # 应用入口、路由、Shell 导航
├── core/theme/             # Aurora 主题系统
├── features/
│   ├── ai_provider/        # AI 提供商配置与服务
│   ├── character/          # 角色卡管理
│   ├── chat/               # 对话系统（核心）
│   ├── settings/           # 设置页面
│   └── world/              # 世界观管理
└── shared/
    ├── data/               # 内置预设数据
    └── helpers/            # 共享工具类
```

## 技术栈

- **框架** — Flutter 3.24 + Dart 3.5
- **状态管理** — Riverpod
- **本地存储** — Hive
- **路由** — GoRouter
- **网络** — Dio
- **设计系统** — Aurora（自定义暗色主题）

## 内置预设

### 角色卡（25 个）
现代/奇幻/科幻/历史/都市传说 — 包含犯罪侧写师、宇航员、甜点师、吸血鬼女伯爵、九尾狐妖、赛博黑客、机甲驾驶员、修仙剑仙等

### 世界观（15 个）
冥都（反乌托邦地下城）、霓虹深渊（赛博朋克）、灵竹大陆（修仙）、猫之道（温馨）、时空回廊（穿越双世界）等

## 许可证

MIT License
