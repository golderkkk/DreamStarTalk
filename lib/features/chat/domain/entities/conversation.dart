import 'protagonist.dart';
import 'message.dart';
import 'dialogue_style.dart';

/// 角色引用（轻量级，用于多角色对话）
class CharacterReference {
  final String id;
  final String name;
  final String? avatar;
  final String? personality;
  final String? speakingStyle;

  const CharacterReference({
    required this.id,
    required this.name,
    this.avatar,
    this.personality,
    this.speakingStyle,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'avatar': avatar,
    'personality': personality,
    'speakingStyle': speakingStyle,
  };

  factory CharacterReference.fromJson(Map<String, dynamic> json) {
    try {
      return CharacterReference(
        id: (json['id'] ?? '').toString(),
        name: (json['name'] ?? '').toString(),
        avatar: json['avatar']?.toString(),
        personality: json['personality']?.toString(),
        speakingStyle: json['speakingStyle']?.toString(),
      );
    } catch (_) {
      return CharacterReference(id: (json['id'] ?? '').toString(), name: (json['name'] ?? '').toString());
    }
  }
}

/// 对话设置
class ConversationSettings {
  final bool nsfwEnabled;
  final bool nsfwPasswordProtected;
  final String? nsfwPassword;
  final double temperature;
  final double topP;
  final int maxTokens;
  final double frequencyPenalty;
  final double presencePenalty;
  final int contextWindowSize;
  final bool includeWorldSetting;
  final bool includeCharacterInfo;
  final bool includeNPCInfo;
  final bool includeProtagonistInfo;
  final bool autoGenerateTitle;
  final String? customSystemPrompt;
  final bool showCharacterNames;
  final bool multiCharacterMode;
  final int maxCharacterResponses;

  const ConversationSettings({
    this.nsfwEnabled = false,
    this.nsfwPasswordProtected = false,
    this.nsfwPassword,
    this.temperature = 0.7,
    this.topP = 1.0,
    this.maxTokens = 4096,
    this.frequencyPenalty = 0.0,
    this.presencePenalty = 0.0,
    this.contextWindowSize = 4096,
    this.includeWorldSetting = true,
    this.includeCharacterInfo = true,
    this.includeNPCInfo = true,
    this.includeProtagonistInfo = true,
    this.autoGenerateTitle = true,
    this.customSystemPrompt,
    this.showCharacterNames = true,
    this.multiCharacterMode = false,
    this.maxCharacterResponses = 3,
    this.dialogueStyle = const DialogueStyleSettings(),
  });

  final DialogueStyleSettings dialogueStyle;

  Map<String, dynamic> toJson() => {
    'nsfwEnabled': nsfwEnabled,
    'nsfwPasswordProtected': nsfwPasswordProtected,
    'nsfwPassword': nsfwPassword,
    'temperature': temperature,
    'topP': topP,
    'maxTokens': maxTokens,
    'frequencyPenalty': frequencyPenalty,
    'presencePenalty': presencePenalty,
    'contextWindowSize': contextWindowSize,
    'includeWorldSetting': includeWorldSetting,
    'includeCharacterInfo': includeCharacterInfo,
    'includeNPCInfo': includeNPCInfo,
    'includeProtagonistInfo': includeProtagonistInfo,
    'autoGenerateTitle': autoGenerateTitle,
    'customSystemPrompt': customSystemPrompt,
    'showCharacterNames': showCharacterNames,
    'multiCharacterMode': multiCharacterMode,
    'maxCharacterResponses': maxCharacterResponses,
    'dialogueStyle': dialogueStyle.toJson(),
  };

  factory ConversationSettings.fromJson(Map<String, dynamic> json) => ConversationSettings(
    nsfwEnabled: json['nsfwEnabled'] as bool? ?? false,
    nsfwPasswordProtected: json['nsfwPasswordProtected'] as bool? ?? false,
    nsfwPassword: json['nsfwPassword'] as String?,
    temperature: (json['temperature'] as num?)?.toDouble() ?? 0.7,
    topP: (json['topP'] as num?)?.toDouble() ?? 1.0,
    maxTokens: json['maxTokens'] as int? ?? 4096,
    frequencyPenalty: (json['frequencyPenalty'] as num?)?.toDouble() ?? 0.0,
    presencePenalty: (json['presencePenalty'] as num?)?.toDouble() ?? 0.0,
    contextWindowSize: json['contextWindowSize'] as int? ?? 4096,
    includeWorldSetting: json['includeWorldSetting'] as bool? ?? true,
    includeCharacterInfo: json['includeCharacterInfo'] as bool? ?? true,
    includeNPCInfo: json['includeNPCInfo'] as bool? ?? true,
    includeProtagonistInfo: json['includeProtagonistInfo'] as bool? ?? true,
    autoGenerateTitle: json['autoGenerateTitle'] as bool? ?? true,
    customSystemPrompt: json['customSystemPrompt'] as String?,
    showCharacterNames: json['showCharacterNames'] as bool? ?? true,
    multiCharacterMode: json['multiCharacterMode'] as bool? ?? false,
    maxCharacterResponses: json['maxCharacterResponses'] as int? ?? 3,
    dialogueStyle: json['dialogueStyle'] != null
        ? DialogueStyleSettings.fromJson(json['dialogueStyle'] as Map<String, dynamic>)
        : const DialogueStyleSettings(),
  );

  ConversationSettings copyWith({
    bool? nsfwEnabled,
    bool? nsfwPasswordProtected,
    String? nsfwPassword,
    double? temperature,
    double? topP,
    int? maxTokens,
    double? frequencyPenalty,
    double? presencePenalty,
    int? contextWindowSize,
    bool? includeWorldSetting,
    bool? includeCharacterInfo,
    bool? includeNPCInfo,
    bool? includeProtagonistInfo,
    bool? autoGenerateTitle,
    String? customSystemPrompt,
    bool? showCharacterNames,
    bool? multiCharacterMode,
    int? maxCharacterResponses,
    DialogueStyleSettings? dialogueStyle,
  }) {
    return ConversationSettings(
      nsfwEnabled: nsfwEnabled ?? this.nsfwEnabled,
      nsfwPasswordProtected: nsfwPasswordProtected ?? this.nsfwPasswordProtected,
      nsfwPassword: nsfwPassword ?? this.nsfwPassword,
      temperature: temperature ?? this.temperature,
      topP: topP ?? this.topP,
      maxTokens: maxTokens ?? this.maxTokens,
      frequencyPenalty: frequencyPenalty ?? this.frequencyPenalty,
      presencePenalty: presencePenalty ?? this.presencePenalty,
      contextWindowSize: contextWindowSize ?? this.contextWindowSize,
      includeWorldSetting: includeWorldSetting ?? this.includeWorldSetting,
      includeCharacterInfo: includeCharacterInfo ?? this.includeCharacterInfo,
      includeNPCInfo: includeNPCInfo ?? this.includeNPCInfo,
      includeProtagonistInfo: includeProtagonistInfo ?? this.includeProtagonistInfo,
      autoGenerateTitle: autoGenerateTitle ?? this.autoGenerateTitle,
      customSystemPrompt: customSystemPrompt ?? this.customSystemPrompt,
      showCharacterNames: showCharacterNames ?? this.showCharacterNames,
      multiCharacterMode: multiCharacterMode ?? this.multiCharacterMode,
      maxCharacterResponses: maxCharacterResponses ?? this.maxCharacterResponses,
      dialogueStyle: dialogueStyle ?? this.dialogueStyle,
    );
  }
}

DateTime? _tryParseDate(dynamic v) {
  if (v == null) return null;
  try { return DateTime.parse(v.toString()); } catch (_) { return null; }
}

/// 对话实体
class Conversation {
  final String id;
  final String characterId;
  final String? characterName;
  final String? characterAvatar;
  final List<CharacterReference> additionalCharacters;
  final String? worldId;
  final String? worldName;
  final Protagonist? protagonist;
  final List<Message> messages;
  final ConversationSettings settings;
  final String? title;
  final String? summary;
  final int messageCount;
  final DateTime? lastMessageAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Conversation({
    required this.id,
    required this.characterId,
    this.characterName,
    this.characterAvatar,
    this.additionalCharacters = const [],
    this.worldId,
    this.worldName,
    this.protagonist,
    this.messages = const [],
    this.settings = const ConversationSettings(),
    this.title,
    this.summary,
    this.messageCount = 0,
    this.lastMessageAt,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'characterId': characterId,
    'characterName': characterName,
    'characterAvatar': characterAvatar,
    'additionalCharacters': additionalCharacters.map((c) => c.toJson()).toList(),
    'worldId': worldId,
    'worldName': worldName,
    'protagonist': protagonist?.toJson(),
    'messages': messages.map((m) => m.toJson()).toList(),
    'settings': settings.toJson(),
    'title': title,
    'summary': summary,
    'messageCount': messageCount,
    'lastMessageAt': lastMessageAt?.toIso8601String(),
    'createdAt': createdAt?.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
  };

  factory Conversation.fromJson(Map<String, dynamic> json) {
    try {
      return Conversation(
        id: (json['id'] ?? '').toString(),
        characterId: (json['characterId'] ?? '').toString(),
        characterName: json['characterName']?.toString(),
        characterAvatar: json['characterAvatar']?.toString(),
        additionalCharacters: (json['additionalCharacters'] as List?)
            ?.whereType<Map>()
            .map((e) => CharacterReference.fromJson(Map<String, dynamic>.from(e)))
            .toList() ?? [],
        worldId: json['worldId']?.toString(),
        worldName: json['worldName']?.toString(),
        protagonist: json['protagonist'] is Map
            ? Protagonist.fromJson(Map<String, dynamic>.from(json['protagonist'] as Map))
            : null,
        messages: (json['messages'] as List?)
            ?.whereType<Map>()
            .map((e) => Message.fromJson(Map<String, dynamic>.from(e)))
            .toList() ?? [],
        settings: json['settings'] is Map
            ? ConversationSettings.fromJson(Map<String, dynamic>.from(json['settings'] as Map))
            : const ConversationSettings(),
        title: json['title']?.toString(),
        summary: json['summary']?.toString(),
        messageCount: (json['messageCount'] as num?)?.toInt() ?? 0,
        lastMessageAt: _tryParseDate(json['lastMessageAt']),
        createdAt: _tryParseDate(json['createdAt']),
        updatedAt: _tryParseDate(json['updatedAt']),
      );
    } catch (_) {
      return Conversation(
        id: (json['id'] ?? '').toString(),
        characterId: (json['characterId'] ?? '').toString(),
      );
    }
  }

  Conversation copyWith({
    String? id,
    String? characterId,
    String? characterName,
    String? characterAvatar,
    List<CharacterReference>? additionalCharacters,
    String? worldId,
    String? worldName,
    Protagonist? protagonist,
    List<Message>? messages,
    ConversationSettings? settings,
    String? title,
    String? summary,
    int? messageCount,
    DateTime? lastMessageAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Conversation(
      id: id ?? this.id,
      characterId: characterId ?? this.characterId,
      characterName: characterName ?? this.characterName,
      characterAvatar: characterAvatar ?? this.characterAvatar,
      additionalCharacters: additionalCharacters ?? this.additionalCharacters,
      worldId: worldId ?? this.worldId,
      worldName: worldName ?? this.worldName,
      protagonist: protagonist ?? this.protagonist,
      messages: messages ?? this.messages,
      settings: settings ?? this.settings,
      title: title ?? this.title,
      summary: summary ?? this.summary,
      messageCount: messageCount ?? this.messageCount,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // ── Computed properties (instance methods) ──
  String get displayTitle {
    if (title != null && title!.isNotEmpty) return title!;
    if (characterName != null) return characterName!;
    return '新对话';
  }

  String get lastMessagePreview {
    if (messages.isEmpty) return '暂无消息';
    final lastMessage = messages.last;
    final prefix = lastMessage.isUser ? '你: ' : '';
    final content = lastMessage.content;
    if (content.length > 50) {
      return '$prefix${content.substring(0, 50)}...';
    }
    return '$prefix$content';
  }

  String get lastMessageTimeString {
    if (lastMessageAt == null) return '';
    final now = DateTime.now();
    final diff = now.difference(lastMessageAt!);
    if (diff.inMinutes < 1) return '刚刚';
    if (diff.inMinutes < 60) return '${diff.inMinutes}分钟前';
    if (diff.inHours < 24) {
      final hour = lastMessageAt!.hour.toString().padLeft(2, '0');
      final minute = lastMessageAt!.minute.toString().padLeft(2, '0');
      return '今天 $hour:$minute';
    }
    if (diff.inDays < 2) return '昨天';
    if (diff.inDays < 7) return '${diff.inDays}天前';
    return '${lastMessageAt!.month}/${lastMessageAt!.day}';
  }

  bool get hasWorld => worldId != null && worldId!.isNotEmpty;
  bool get hasProtagonist => protagonist != null;
  bool get isNSFWEnabled => settings.nsfwEnabled;
  bool get needsNSFWPassword =>
      settings.nsfwPasswordProtected && settings.nsfwPassword != null;
  int get messageCountActual => messages.where((m) => !m.isSystem).length;
  bool get isMultiCharacterMode => settings.multiCharacterMode;

  /// 获取所有角色（主角色 + 附加角色）
  List<CharacterReference> get allCharacters {
    final chars = <CharacterReference>[
      CharacterReference(
        id: characterId,
        name: characterName ?? '未知角色',
        avatar: characterAvatar,
      ),
    ];
    chars.addAll(additionalCharacters);
    return chars;
  }

  /// 根据ID获取角色
  CharacterReference? getCharacterById(String id) {
    if (id == characterId) {
      return CharacterReference(
        id: characterId,
        name: characterName ?? '未知角色',
        avatar: characterAvatar,
      );
    }
    return additionalCharacters.where((c) => c.id == id).firstOrNull;
  }

  Message? get lastNonSystemMessage {
    for (var i = messages.length - 1; i >= 0; i--) {
      if (!messages[i].isSystem) {
        return messages[i];
      }
    }
    return null;
  }
}
