# 需求文档

## 1. 项目概述

### 1.1 项目背景
AI Chat Studio 是一个现代化的 AI 角色聊天应用，旨在提供沉浸式的角色扮演体验。项目参考 SillyTavern 的设计理念，但采用全新的技术架构和现代化的用户界面。

### 1.2 项目目标
- 提供直观的角色创建和管理体验
- 支持丰富的世界观设定系统
- 实现高质量的 AI 对话体验
- 支持多种 AI 提供商
- 提供现代化、美观的用户界面

## 2. 功能需求

### 2.1 角色系统

#### 2.1.1 角色创建
- **基本信息**
  - 角色名称
  - 角色头像（支持上传图片）
  - 角色简介
  - 角色标签

- **详细设定**
  - 性格特征
  - 外貌描述
  - 背景故事
  - 说话风格
  - 口头禅
  - 喜好/厌恶

- **高级设置**
  - 系统提示词
  - 示例对话
  - 初始消息
  - 角色注释

#### 2.1.2 角色管理
- 角色列表展示
- 角色搜索和筛选
- 角色导入/导出
- 角色删除和编辑

#### 2.1.3 角色卡兼容
- 支持 SillyTavern 角色卡格式（PNG/JSON）
- 支持角色卡元数据解析
- 支持角色卡图片提取

### 2.2 世界观系统

#### 2.2.1 世界设定
- **世界背景**
  - 世界名称
  - 世界封面图
  - 世界背景描述
  - 世界规则
  - 世界历史

- **当前场景**
  - 场景名称
  - 场景描述
  - 场景图片
  - 当前时间/天气
  - 场景氛围

#### 2.2.2 NPC 管理
- **NPC 信息**
  - NPC 名称
  - NPC 头像
  - NPC 简介
  - NPC 性格
  - NPC 与主角关系

- **NPC 关系网**
  - 关系类型定义
  - 关系强度
  - 关系历史

#### 2.2.3 剧情系统
- **剧情方向**
  - 主线剧情
  - 支线剧情
  - 剧情节点
  - 剧情分支

- **剧情事件**
  - 事件触发条件
  - 事件描述
  - 事件影响

#### 2.2.4 世界观图片
- 世界背景图上传
- 场景图片上传
- NPC 图片上传
- 图片管理（删除、替换）

### 2.3 对话系统

#### 2.3.1 核心对话
- **消息类型**
  - 文本消息
  - 图片消息
  - 系统消息
  - 动作消息（/me）

- **对话功能**
  - 消息发送
  - 消息编辑
  - 消息删除
  - 消息重发
  - 消息复制

#### 2.3.2 上下文管理
- **上下文窗口**
  - 可配置的上下文长度
  - 智能上下文截断
  - 重要信息保留

- **记忆系统**
  - 短期记忆（当前对话）
  - 长期记忆（跨对话）
  - 记忆检索
  - 记忆编辑

#### 2.3.3 世界融合
- 自动注入世界设定到对话
- 场景感知对话
- NPC 关系感知
- 剧情进展追踪

#### 2.3.4 NSFW 模式
- **模式切换**
  - 全局 NSFW 开关
  - 单对话 NSFW 开关
  - 密码保护（可选）

- **破甲功能**
  - 绕过 AI 内容限制
  - 自定义破甲提示词
  - 破甲强度调节

### 2.4 AI 提供商系统

#### 2.4.1 提供商管理
- **支持的提供商**
  - MiMo（优先支持）
  - DeepSeek（优先支持）
  - OpenAI
  - Claude
  - Gemini
  - 本地模型（Ollama）

- **配置方式**
  - API Key 配置
  - API 端点配置
  - 模型选择
  - 参数调节

#### 2.4.2 接入方式
- **直连模式**
  - 直接调用提供商 API
  - 适合个人使用

- **网关模式**
  - 通过统一代理网关
  - 适合多用户/企业使用
  - 支持负载均衡

#### 2.4.3 请求配置
- **生成参数**
  - Temperature
  - Top P
  - Max Tokens
  - Frequency Penalty
  - Presence Penalty

- **高级配置**
  - 自定义请求头
  - 自定义请求体
  - 流式响应支持

### 2.5 设置系统

#### 2.5.1 界面设置
- **主题定制**
  - 明暗主题切换
  - 主题颜色选择
  - 字体大小调节
  - 聊天气泡样式

- **布局设置**
  - 侧边栏位置
  - 聊天区域比例
  - 响应式布局

#### 2.5.2 对话设置
- **默认参数**
  - 默认 AI 提供商
  - 默认模型
  - 默认生成参数

- **行为设置**
  - 自动保存间隔
  - 消息加载数量
  - 上下文长度

#### 2.5.3 数据管理
- **导入/导出**
  - 角色导入/导出
  - 世界观导入/导出
  - 对话记录导入/导出
  - 设置导入/导出

- **存储管理**
  - 存储空间查看
  - 缓存清理
  - 数据备份

## 3. 非功能需求

### 3.1 性能需求
- 应用启动时间 < 3 秒
- 消息发送响应时间 < 500ms
- 图片加载支持懒加载
- 支持大量对话记录（10000+）

### 3.2 兼容性需求
- **Web 端**
  - Chrome 90+
  - Firefox 90+
  - Safari 15+
  - Edge 90+

- **桌面端**
  - Windows 10+
  - macOS 11+
  - Linux（Ubuntu 20.04+）

- **移动端**
  - Android 10+
  - iOS 14+

### 3.3 安全需求
- API Key 本地加密存储
- NSFW 内容密码保护
- 数据本地存储，不上传云端
- 支持数据导出和删除

### 3.4 可用性需求
- 支持中英文界面
- 支持键盘快捷键
- 支持无障碍访问
- 提供新手引导

## 4. 数据模型

### 4.1 角色模型
```dart
class Character {
  String id;
  String name;
  String avatar; // 图片路径
  String description;
  String personality;
  String backstory;
  String speakingStyle;
  String systemPrompt;
  List<String> exampleDialogues;
  String firstMessage;
  List<String> tags;
  DateTime createdAt;
  DateTime updatedAt;
}
```

### 4.2 世界观模型
```dart
class WorldSetting {
  String id;
  String name;
  String coverImage;
  String description;
  String rules;
  String history;
  List<Scene> scenes;
  List<NPC> npcs;
  List<Storyline> storylines;
  DateTime createdAt;
  DateTime updatedAt;
}

class Scene {
  String id;
  String name;
  String description;
  String image;
  String time;
  String weather;
  String atmosphere;
}

class NPC {
  String id;
  String name;
  String avatar;
  String description;
  String personality;
  String relationship;
  Map<String, String> relationships; // npcId -> relationship type
}
```

### 4.3 对话模型
```dart
class Conversation {
  String id;
  String characterId;
  String? worldId;
  List<Message> messages;
  ConversationSettings settings;
  DateTime createdAt;
  DateTime updatedAt;
}

class Message {
  String id;
  String content;
  MessageRole role; // user, assistant, system
  MessageType type; // text, image, action
  DateTime timestamp;
  Map<String, dynamic>? metadata;
}
```

### 4.4 AI 提供商模型
```dart
class AIProvider {
  String id;
  String name;
  ProviderType type; // mimo, deepseek, openai, claude, etc.
  String apiKey;
  String? endpoint;
  String defaultModel;
  List<String> availableModels;
  Map<String, dynamic> defaultParams;
}
```

## 5. 接口设计

### 5.1 AI 提供商接口
```dart
abstract class AIProviderService {
  Future<String> sendMessage({
    required List<Message> messages,
    required Character character,
    WorldSetting? world,
    required GenerationParams params,
  });

  Stream<String> sendMessageStream({
    required List<Message> messages,
    required Character character,
    WorldSetting? world,
    required GenerationParams params,
  });

  Future<List<String>> getAvailableModels();
}
```

### 5.2 存储接口
```dart
abstract class StorageService {
  // 角色相关
  Future<List<Character>> getCharacters();
  Future<Character?> getCharacter(String id);
  Future<void> saveCharacter(Character character);
  Future<void> deleteCharacter(String id);

  // 世界观相关
  Future<List<WorldSetting>> getWorlds();
  Future<WorldSetting?> getWorld(String id);
  Future<void> saveWorld(WorldSetting world);
  Future<void> deleteWorld(String id);

  // 对话相关
  Future<List<Conversation>> getConversations(String characterId);
  Future<Conversation?> getConversation(String id);
  Future<void> saveConversation(Conversation conversation);
  Future<void> deleteConversation(String id);
}
```

## 6. 用户界面设计

### 6.1 主要页面
1. **首页** - 角色列表、快速开始
2. **角色创建页** - 角色设定编辑
3. **世界观编辑页** - 世界观设定编辑
4. **聊天页** - 对话界面
5. **设置页** - 应用设置

### 6.2 设计原则
- Material Design 3 风格
- 清晰的视觉层次
- 流畅的动画过渡
- 响应式布局
- 暗色主题优先

## 7. 开发里程碑

详见 [开发计划](development-plan.md)

## 8. 风险与挑战

### 8.1 技术风险
- AI 提供商 API 稳定性
- 大量数据本地存储性能
- 跨平台兼容性

### 8.2 应对策略
- 多提供商备份
- 数据分页和懒加载
- 充分的平台测试
