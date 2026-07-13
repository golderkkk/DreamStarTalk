# 拾梦·星语 (DreamStarTalk)

沉浸式 AI 角色扮演应用，支持多角色对话、世界观构建与场景叙事。

<p align="center">
  <img src="screenshots/chat.png" width="200" alt="多角色对话" />
  <img src="screenshots/characters.png" width="200" alt="角色列表" />
  <img src="screenshots/worlds.png" width="200" alt="世界观" />
  <img src="screenshots/settings.png" width="200" alt="设置" />
</p>

## 功能特性

- **多角色对话** — @mention 指定回复，流式输出，消息重生成
- **世界观系统** — 场景/NPC/剧情线，Lorebook 动态注入
- **角色卡** — 25 个内置角色，支持 SillyTavern PNG 导入导出
- **多 AI 引擎** — MiMo、DeepSeek、OpenAI、Claude、Gemini、Ollama
- **对话风格** — 写作人称/语气/特化模式自由配置
- **TTS 语音** — MiMo TTS，9 种音色
- **场景系统** — 时间/天气/氛围选择，场景横幅

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

| 类别 | 技术 |
|------|------|
| 框架 | Flutter 3.24 + Dart 3.5 |
| 状态管理 | Riverpod |
| 本地存储 | Hive |
| 路由 | GoRouter v14 |
| 网络 | Dio |
| 设计系统 | Aurora（自定义暗色主题） |

## 内置预设

- **25 个角色卡** — 涵盖现代/奇幻/科幻/武侠/都市传说等题材
- **15 个世界观** — 反乌托邦/赛博朋克/仙侠/深海/校园等设定

## 许可证

MIT License
