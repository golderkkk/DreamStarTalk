# AI Chat Studio

一个现代化的 AI 角色聊天应用，支持丰富的世界观设定、角色定制和多 AI 提供商接入。

## 🚀 快速开始

### 1. 安装依赖

```bash
cd ai_chat_studio
flutter pub get
```

### 2. 运行应用

```bash
# Web
flutter run -d chrome

# macOS
flutter run -d macos

# Windows
flutter run -d windows

# Linux
flutter run -d linux
```

## 📁 项目结构

```
lib/
├── app/                    # 应用入口和路由
├── core/                   # 核心功能
│   ├── constants/         # 常量定义
│   ├── theme/            # 主题配置
│   ├── utils/            # 工具类
│   └── extensions/       # 扩展方法
├── features/              # 功能模块
│   ├── character/        # 角色系统
│   ├── world/            # 世界观系统
│   ├── chat/             # 对话系统
│   ├── settings/         # 设置系统
│   └── ai_provider/      # AI 提供商
├── shared/                # 共享组件
│   ├── widgets/          # 通用组件
│   ├── models/           # 数据模型
│   └── services/         # 共享服务
└── main.dart             # 应用入口
```

## 📚 文档

- [需求文档](docs/requirements.md)
- [技术架构](docs/architecture.md)
- [开发计划](docs/development-plan.md)
- [AI 提供商接入](docs/ai-providers.md)

## 🛠️ 开发

### 代码生成

```bash
# 运行 build_runner
flutter pub run build_runner build --delete-conflicting-outputs

# 监听文件变化并自动生成
flutter pub run build_runner watch --delete-conflicting-outputs
```

### 测试

```bash
# 运行所有测试
flutter test

# 运行特定测试
flutter test test/app_test.dart
```

### 代码规范

```bash
# 检查代码规范
flutter analyze

# 自动修复
flutter analyze --fix
```

## ✨ 核心功能

### 🎭 角色系统
- 创建和管理 AI 角色
- 支持图片 + 设定模式
- 角色卡导入导出

### 🌍 世界观系统
- 世界背景设定
- NPC 角色管理
- 场景和剧情系统

### 💬 对话系统
- 智能上下文管理
- 世界融合对话
- NSFW 模式支持

### 🤖 AI 提供商
- MiMo（优先支持）
- DeepSeek（优先支持）
- OpenAI, Claude, Gemini
- 本地模型（Ollama）

## 🎨 界面特性

- Material Design 3 风格
- 响应式布局
- 明暗主题切换
- 流畅动画效果

## 📦 依赖

- Flutter 3.12.0+
- Dart 3.12.0+
- Riverpod - 状态管理
- Hive - 本地存储
- Dio - 网络请求
- GoRouter - 路由管理

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

## 📄 许可证

MIT License
