# 技术架构文档

## 1. 架构概述

### 1.1 架构风格
采用 **Clean Architecture** + **Feature-based** 的混合架构风格，确保代码的可维护性、可测试性和可扩展性。

### 1.2 分层结构

```
┌─────────────────────────────────────────────────────────┐
│                    Presentation Layer                    │
│  (UI Components, Pages, View Models)                    │
├─────────────────────────────────────────────────────────┤
│                    Application Layer                    │
│  (Use Cases, Services, State Management)                │
├─────────────────────────────────────────────────────────┤
│                      Domain Layer                       │
│  (Entities, Repositories, Business Logic)               │
├─────────────────────────────────────────────────────────┤
│                  Infrastructure Layer                   │
│  (Data Sources, External Services, Storage)             │
└─────────────────────────────────────────────────────────┘
```

## 2. 核心模块设计

### 2.1 模块依赖关系

```
app
├── core
├── features
│   ├── character
│   │   ├── data
│   │   ├── domain
│   │   └── presentation
│   ├── world
│   │   ├── data
│   │   ├── domain
│   │   └── presentation
│   ├── chat
│   │   ├── data
│   │   ├── domain
│   │   └── presentation
│   ├── settings
│   │   ├── data
│   │   ├── domain
│   │   └── presentation
│   └── ai_provider
│       ├── data
│       ├── domain
│       └── presentation
└── shared
    ├── widgets
    ├── models
    └── services
```

### 2.2 模块职责

#### Core 模块
```dart
// 核心模块提供全局配置和工具
lib/core/
├── constants/
│   ├── app_constants.dart      # 应用常量
│   ├── api_constants.dart      # API 常量
│   └── storage_constants.dart  # 存储常量
├── theme/
│   ├── app_theme.dart          # 主题定义
│   ├── color_schemes.dart      # 颜色方案
│   └── text_styles.dart        # 文字样式
├── utils/
│   ├── logger.dart             # 日志工具
│   ├── validators.dart         # 验证工具
│   └── helpers.dart            # 辅助函数
└── extensions/
    ├── string_extensions.dart  # 字符串扩展
    └── datetime_extensions.dart # 日期扩展
```

#### Character 模块
```dart
// 角色管理模块
lib/features/character/
├── data/
│   ├── datasources/
│   │   ├── character_local_datasource.dart  # 本地数据源
│   │   └── character_card_parser.dart       # 角色卡解析器
│   ├── repositories/
│   │   └── character_repository_impl.dart   # 仓库实现
│   └── models/
│       └── character_model.dart             # 数据模型
├── domain/
│   ├── entities/
│   │   └── character.dart                   # 实体
│   ├── repositories/
│   │   └── character_repository.dart        # 仓库接口
│   └── usecases/
│       ├── get_characters.dart              # 获取角色列表
│       ├── create_character.dart            # 创建角色
│       └── import_character.dart            # 导入角色
└── presentation/
    ├── pages/
    │   ├── character_list_page.dart         # 角色列表页
    │   └── character_edit_page.dart         # 角色编辑页
    ├── widgets/
    │   ├── character_card.dart              # 角色卡片
    │   └── character_form.dart              # 角色表单
    └── providers/
        └── character_provider.dart          # 状态管理
```

#### World 模块
```dart
// 世界观管理模块
lib/features/world/
├── data/
│   ├── datasources/
│   │   └── world_local_datasource.dart      # 本地数据源
│   ├── repositories/
│   │   └── world_repository_impl.dart       # 仓库实现
│   └── models/
│       ├── world_model.dart                 # 世界模型
│       ├── scene_model.dart                 # 场景模型
│       └── npc_model.dart                   # NPC 模型
├── domain/
│   ├── entities/
│   │   ├── world.dart                       # 世界实体
│   │   ├── scene.dart                       # 场景实体
│   │   ├── npc.dart                         # NPC 实体
│   │   └── storyline.dart                   # 剧情实体
│   ├── repositories/
│   │   └── world_repository.dart            # 仓库接口
│   └── usecases/
│       ├── get_worlds.dart                  # 获取世界观列表
│       ├── create_world.dart                # 创建世界观
│       └── manage_npcs.dart                 # 管理 NPC
└── presentation/
    ├── pages/
    │   ├── world_list_page.dart             # 世界观列表页
    │   ├── world_edit_page.dart             # 世界观编辑页
    │   └── scene_edit_page.dart             # 场景编辑页
    ├── widgets/
    │   ├── world_card.dart                  # 世界观卡片
    │   ├── npc_tile.dart                    # NPC 列表项
    │   └── scene_preview.dart               # 场景预览
    └── providers/
        └── world_provider.dart              # 状态管理
```

#### Chat 模块
```dart
// 对话系统模块
lib/features/chat/
├── data/
│   ├── datasources/
│   │   ├── chat_local_datasource.dart       # 本地数据源
│   │   └── context_manager.dart             # 上下文管理器
│   ├── repositories/
│   │   └── chat_repository_impl.dart        # 仓库实现
│   └── models/
│       ├── conversation_model.dart          # 对话模型
│       └── message_model.dart               # 消息模型
├── domain/
│   ├── entities/
│   │   ├── conversation.dart                # 对话实体
│   │   └── message.dart                     # 消息实体
│   ├── repositories/
│   │   └── chat_repository.dart             # 仓库接口
│   └── usecases/
│       ├── send_message.dart                # 发送消息
│       ├── get_conversations.dart           # 获取对话列表
│       └── manage_context.dart              # 管理上下文
└── presentation/
    ├── pages/
    │   ├── chat_page.dart                   # 聊天页
    │   └── conversation_list_page.dart      # 对话列表页
    ├── widgets/
    │   ├── message_bubble.dart              # 消息气泡
    │   ├── chat_input.dart                  # 聊天输入框
    │   └── context_panel.dart               # 上下文面板
    └── providers/
        ├── chat_provider.dart               # 对话状态
        └── message_provider.dart            # 消息状态
```

#### AI Provider 模块
```dart
// AI 提供商模块
lib/features/ai_provider/
├── data/
│   ├── datasources/
│   │   ├── ai_provider_local_datasource.dart # 本地数据源
│   │   └── api_service.dart                  # API 服务
│   ├── repositories/
│   │   └── ai_provider_repository_impl.dart  # 仓库实现
│   └── models/
│       └── ai_provider_model.dart            # 提供商模型
├── domain/
│   ├── entities/
│   │   ├── ai_provider.dart                  # 提供商实体
│   │   └── generation_params.dart            # 生成参数
│   ├── repositories/
│   │   └── ai_provider_repository.dart       # 仓库接口
│   └── usecases/
│       ├── get_providers.dart                # 获取提供商列表
│       ├── send_message.dart                 # 发送消息
│       └── stream_message.dart               # 流式消息
└── presentation/
    ├── pages/
    │   ├── provider_list_page.dart           # 提供商列表页
    │   └── provider_config_page.dart         # 提供商配置页
    ├── widgets/
    │   ├── provider_card.dart                # 提供商卡片
    │   └── params_slider.dart                # 参数滑块
    └── providers/
        └── ai_provider_provider.dart         # 状态管理
```

## 3. 状态管理

### 3.1 Riverpod 架构

```dart
// 1. Provider 定义
final characterRepositoryProvider = Provider<CharacterRepository>((ref) {
  return CharacterRepositoryImpl(
    localDataSource: ref.read(characterLocalDataSourceProvider),
  );
});

// 2. UseCase Provider
final getCharactersProvider = FutureProvider<List<Character>>((ref) {
  return ref.read(characterRepositoryProvider).getCharacters();
});

// 3. StateNotifier Provider
final characterListProvider = StateNotifierProvider<CharacterListNotifier, CharacterListState>((ref) {
  return CharacterListNotifier(
    getCharacters: ref.read(getCharactersProvider),
  );
});

// 4. State 类
class CharacterListState {
  final List<Character> characters;
  final bool isLoading;
  final String? error;

  const CharacterListState({
    this.characters = const [],
    this.isLoading = false,
    this.error,
  });
}
```

### 3.2 状态管理原则

1. **单一数据源**：每个状态只有一个 Provider 负责
2. **不可变状态**：状态对象使用 immutable 类
3. **单向数据流**：UI → Action → State → UI
4. **依赖注入**：通过 Riverpod 注入依赖

## 4. 数据流设计

### 4.1 消息发送流程

```
用户输入
    ↓
ChatInput Widget
    ↓
ChatProvider.sendMessage()
    ↓
SendMessage UseCase
    ↓
ChatRepository.sendMessage()
    ↓
AIProviderService.sendMessage()
    ↓
┌─────────────────┐
│   AI Provider   │
│  (MiMo/DeepSeek)│
└─────────────────┘
    ↓
Response Stream
    ↓
ChatRepository (保存消息)
    ↓
ChatProvider (更新状态)
    ↓
UI 更新
```

### 4.2 上下文管理流程

```
对话开始
    ↓
ContextManager.initialize()
    ↓
┌─────────────────────────────────────────┐
│           上下文构建                      │
├─────────────────────────────────────────┤
│ 1. 系统提示词 (角色设定)                  │
│ 2. 世界设定 (如果存在)                    │
│ 3. 场景描述 (如果存在)                    │
│ 4. NPC 信息 (如果存在)                    │
│ 5. 历史消息 (最近 N 条)                   │
│ 6. 用户当前输入                           │
└─────────────────────────────────────────┘
    ↓
发送到 AI Provider
    ↓
获取响应
    ↓
更新上下文窗口
```

## 5. 存储架构

### 5.1 存储方案

```dart
// Hive - 轻量级键值存储
class HiveStorageService {
  // 用于：设置、缓存、临时数据
  static const String settingsBox = 'settings';
  static const String cacheBox = 'cache';
}

// SQLite - 结构化数据存储
class SqliteStorageService {
  // 用于：角色、世界观、对话记录
  static const String dbName = 'ai_chat_studio.db';
  static const int dbVersion = 1;
}
```

### 5.2 数据库表设计

```sql
-- 角色表
CREATE TABLE characters (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  avatar TEXT,
  description TEXT,
  personality TEXT,
  backstory TEXT,
  speaking_style TEXT,
  system_prompt TEXT,
  example_dialogues TEXT, -- JSON
  first_message TEXT,
  tags TEXT, -- JSON
  created_at TIMESTAMP,
  updated_at TIMESTAMP
);

-- 世界观表
CREATE TABLE worlds (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  cover_image TEXT,
  description TEXT,
  rules TEXT,
  history TEXT,
  created_at TIMESTAMP,
  updated_at TIMESTAMP
);

-- 场景表
CREATE TABLE scenes (
  id TEXT PRIMARY KEY,
  world_id TEXT NOT NULL,
  name TEXT NOT NULL,
  description TEXT,
  image TEXT,
  time TEXT,
  weather TEXT,
  atmosphere TEXT,
  FOREIGN KEY (world_id) REFERENCES worlds(id)
);

-- NPC 表
CREATE TABLE npcs (
  id TEXT PRIMARY KEY,
  world_id TEXT NOT NULL,
  name TEXT NOT NULL,
  avatar TEXT,
  description TEXT,
  personality TEXT,
  relationship TEXT,
  FOREIGN KEY (world_id) REFERENCES worlds(id)
);

-- NPC 关系表
CREATE TABLE npc_relationships (
  id TEXT PRIMARY KEY,
  npc_id TEXT NOT NULL,
  related_npc_id TEXT NOT NULL,
  relationship_type TEXT,
  relationship_strength INTEGER,
  FOREIGN KEY (npc_id) REFERENCES npcs(id),
  FOREIGN KEY (related_npc_id) REFERENCES npcs(id)
);

-- 对话表
CREATE TABLE conversations (
  id TEXT PRIMARY KEY,
  character_id TEXT NOT NULL,
  world_id TEXT,
  settings TEXT, -- JSON
  created_at TIMESTAMP,
  updated_at TIMESTAMP,
  FOREIGN KEY (character_id) REFERENCES characters(id),
  FOREIGN KEY (world_id) REFERENCES worlds(id)
);

-- 消息表
CREATE TABLE messages (
  id TEXT PRIMARY KEY,
  conversation_id TEXT NOT NULL,
  content TEXT NOT NULL,
  role TEXT NOT NULL, -- user, assistant, system
  type TEXT NOT NULL, -- text, image, action
  timestamp TIMESTAMP,
  metadata TEXT, -- JSON
  FOREIGN KEY (conversation_id) REFERENCES conversations(id)
);

-- AI 提供商表
CREATE TABLE ai_providers (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  type TEXT NOT NULL,
  api_key TEXT,
  endpoint TEXT,
  default_model TEXT,
  available_models TEXT, -- JSON
  default_params TEXT, -- JSON
  created_at TIMESTAMP,
  updated_at TIMESTAMP
);
```

## 6. 网络架构

### 6.1 Dio 配置

```dart
class DioClient {
  static Dio createDio({
    required String baseUrl,
    Map<String, dynamic>? headers,
  }) {
    final dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(minutes: 5),
      headers: headers,
    ));

    // 添加拦截器
    dio.interceptors.addAll([
      LogInterceptor(
        requestBody: true,
        responseBody: true,
      ),
      RetryInterceptor(
        retries: 3,
        retryDelays: const [
          Duration(seconds: 1),
          Duration(seconds: 2),
          Duration(seconds: 3),
        ],
      ),
    ]);

    return dio;
  }
}
```

### 6.2 流式响应处理

```dart
class StreamResponseHandler {
  Stream<String> handleStream(Response<ResponseBody> response) async* {
    final stream = response.data!.stream;
    
    await for (final chunk in stream) {
      final text = utf8.decode(chunk);
      final lines = text.split('\n');
      
      for (final line in lines) {
        if (line.startsWith('data: ')) {
          final data = line.substring(6);
          if (data == '[DONE]') break;
          
          try {
            final json = jsonDecode(data);
            final content = json['choices'][0]['delta']['content'];
            if (content != null) {
              yield content;
            }
          } catch (e) {
            // 忽略解析错误
          }
        }
      }
    }
  }
}
```

## 7. 安全架构

### 7.1 API Key 加密存储

```dart
class SecureStorageService {
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  Future<void> saveApiKey(String providerId, String apiKey) async {
    // 使用 AES 加密
    final encrypted = _encrypt(apiKey);
    await _storage.write(
      key: 'api_key_$providerId',
      value: encrypted,
    );
  }

  Future<String?> getApiKey(String providerId) async {
    final encrypted = await _storage.read(key: 'api_key_$providerId');
    if (encrypted == null) return null;
    return _decrypt(encrypted);
  }

  String _encrypt(String data) {
    // AES 加密实现
    final key = Key.fromSecureRandom(32);
    final iv = IV.fromSecureRandom(16);
    final encrypter = Encrypter(AES(key));
    return encrypter.encrypt(data, iv: iv).base64;
  }

  String _decrypt(String data) {
    // AES 解密实现
    // ...
  }
}
```

### 7.2 NSFW 模式安全

```dart
class NSFWManager {
  static const String _passwordKey = 'nsfw_password';
  static const String _enabledKey = 'nsfw_enabled';

  Future<bool> enableNSFW(String password) async {
    final storedPassword = await _getStoredPassword();
    if (storedPassword == null) {
      // 首次设置密码
      await _savePassword(password);
      await _setEnabled(true);
      return true;
    }
    // 验证密码
    if (password == storedPassword) {
      await _setEnabled(true);
      return true;
    }
    return false;
  }

  Future<bool> isNSFWEnabled() async {
    return await _getEnabled();
  }
}
```

## 8. 测试策略

### 8.1 测试金字塔

```
         /\
        /  \        E2E Tests (10%)
       /    \       - 关键用户流程
      /------\
     /        \     Integration Tests (20%)
    /          \    - 模块间交互
   /------------\
  /              \  Unit Tests (70%)
 /                \ - 业务逻辑
/                  \- 数据转换
```

### 8.2 测试示例

```dart
// 单元测试
void main() {
  group('Character Entity', () {
    test('should create character with required fields', () {
      final character = Character(
        id: '1',
        name: 'Test Character',
        description: 'A test character',
      );
      
      expect(character.name, 'Test Character');
      expect(character.id, '1');
    });
  });
}

// Widget 测试
void main() {
  testWidgets('CharacterCard displays character info', (tester) async {
    final character = Character(
      id: '1',
      name: 'Test Character',
      description: 'A test character',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: CharacterCard(character: character),
      ),
    );

    expect(find.text('Test Character'), findsOneWidget);
  });
}

// 集成测试
void main() {
  testWidgets('Send message flow', (tester) async {
    await tester.pumpWidget(MyApp());
    
    // 选择角色
    await tester.tap(find.text('Test Character'));
    await tester.pumpAndSettle();
    
    // 输入消息
    await tester.enterText(find.byType(TextField), 'Hello');
    await tester.tap(find.byIcon(Icons.send));
    await tester.pumpAndSettle();
    
    // 验证消息已发送
    expect(find.text('Hello'), findsOneWidget);
  });
}
```

## 9. 部署架构

### 9.1 Web 部署

```yaml
# GitHub Actions 部署配置
name: Deploy Web

on:
  push:
    branches: [main]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.12.0'
      - run: flutter build web --release
      - uses: peaceiris/actions-gh-pages@v3
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          publish_dir: ./build/web
```

### 9.2 桌面应用打包

```yaml
# macOS 打包
- name: Build macOS
  run: flutter build macos --release

# Windows 打包
- name: Build Windows
  run: flutter build windows --release

# Linux 打包
- name: Build Linux
  run: flutter build linux --release
```

## 10. 性能优化

### 10.1 图片优化

```dart
class ImageOptimizer {
  // 图片压缩
  static Future<File> compressImage(File file, {int quality = 85}) async {
    final result = await FlutterImageCompress.compressAndGetFile(
      file.path,
      '${file.path}_compressed.jpg',
      quality: quality,
    );
    return File(result!.path);
  }

  // 图片缓存
  static Widget cachedImage(String url) {
    return CachedNetworkImage(
      imageUrl: url,
      placeholder: (context, url) => CircularProgressIndicator(),
      errorWidget: (context, url, error) => Icon(Icons.error),
      memCacheWidth: 300, // 限制内存缓存大小
    );
  }
}
```

### 10.2 列表优化

```dart
class OptimizedListView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: items.length,
      // 使用 findChildIndexCallback 优化重建
      findChildIndexCallback: (key) {
        final valueKey = key as ValueKey;
        return items.indexWhere((item) => item.id == valueKey.value);
      },
      itemBuilder: (context, index) {
        return ItemWidget(
          key: ValueKey(items[index].id),
          item: items[index],
        );
      },
    );
  }
}
```

## 11. 错误处理

### 11.1 错误类型

```dart
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  const AppException({
    required this.message,
    this.code,
    this.originalError,
  });
}

class NetworkException extends AppException {
  const NetworkException({
    required super.message,
    super.code,
    super.originalError,
  });
}

class StorageException extends AppException {
  const StorageException({
    required super.message,
    super.code,
    super.originalError,
  });
}

class AIProviderException extends AppException {
  const AIProviderException({
    required super.message,
    super.code,
    super.originalError,
  });
}
```

### 11.2 错误处理策略

```dart
class ErrorHandler {
  static void handle(dynamic error, StackTrace stackTrace) {
    if (error is AppException) {
      _handleAppException(error);
    } else {
      _handleUnknownError(error, stackTrace);
    }
  }

  static void _handleAppException(AppException exception) {
    // 记录日志
    Logger.error(exception.message, exception.originalError);
    
    // 显示用户友好的错误信息
    switch (exception.runtimeType) {
      case NetworkException:
        showErrorSnackbar('网络连接失败，请检查网络设置');
        break;
      case StorageException:
        showErrorSnackbar('数据存储失败');
        break;
      case AIProviderException:
        showErrorSnackbar('AI 服务调用失败: ${exception.message}');
        break;
    }
  }
}
```
