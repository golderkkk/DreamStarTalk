/// 消息角色
enum MessageRole {
  system,
  user,
  assistant,
}

/// 消息类型
enum MessageType {
  text,
  image,
  action,
  system,
  error,
}

/// 消息实体
class Message {
  final String id;
  final String content;
  final MessageRole role;
  final MessageType type;
  final DateTime timestamp;
  final String? name;
  final String? avatar;
  final bool isEdited;
  final bool isStreaming;
  final String? characterId;
  final String? targetCharacterId;
  final Map<String, dynamic>? metadata;

  const Message({
    required this.id,
    required this.content,
    this.role = MessageRole.user,
    this.type = MessageType.text,
    required this.timestamp,
    this.name,
    this.avatar,
    this.isEdited = false,
    this.isStreaming = false,
    this.characterId,
    this.targetCharacterId,
    this.metadata,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'content': content,
    'role': role.name,
    'type': type.name,
    'timestamp': timestamp.toIso8601String(),
    'name': name,
    'avatar': avatar,
    'isEdited': isEdited,
    'isStreaming': isStreaming,
    'characterId': characterId,
    'targetCharacterId': targetCharacterId,
    'metadata': metadata,
  };

  factory Message.fromJson(Map<String, dynamic> json) => Message(
    id: json['id'] as String,
    content: json['content'] as String,
    role: MessageRole.values.byName(json['role'] as String? ?? 'user'),
    type: MessageType.values.byName(json['type'] as String? ?? 'text'),
    timestamp: DateTime.parse(json['timestamp'] as String),
    name: json['name'] as String?,
    avatar: json['avatar'] as String?,
    isEdited: json['isEdited'] as bool? ?? false,
    isStreaming: json['isStreaming'] as bool? ?? false,
    characterId: json['characterId'] as String?,
    targetCharacterId: json['targetCharacterId'] as String?,
    metadata: json['metadata'] as Map<String, dynamic>?,
  );

  Message copyWith({
    String? id,
    String? content,
    MessageRole? role,
    MessageType? type,
    DateTime? timestamp,
    String? name,
    String? avatar,
    bool? isEdited,
    bool? isStreaming,
    String? characterId,
    String? targetCharacterId,
    Map<String, dynamic>? metadata,
  }) {
    return Message(
      id: id ?? this.id,
      content: content ?? this.content,
      role: role ?? this.role,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      isEdited: isEdited ?? this.isEdited,
      isStreaming: isStreaming ?? this.isStreaming,
      characterId: characterId ?? this.characterId,
      targetCharacterId: targetCharacterId ?? this.targetCharacterId,
      metadata: metadata ?? this.metadata,
    );
  }
}

/// 消息扩展方法
extension MessageExtension on Message {
  bool get isUser => role == MessageRole.user;
  bool get isAssistant => role == MessageRole.assistant;
  bool get isSystem => role == MessageRole.system;
  bool get isAction => type == MessageType.action;
  bool get isError => type == MessageType.error;

  String get displayName {
    if (name != null && name!.isNotEmpty) return name!;
    switch (role) {
      case MessageRole.user:
        return '你';
      case MessageRole.assistant:
        return 'AI';
      case MessageRole.system:
        return '系统';
    }
  }

  String get timeString {
    final hour = timestamp.hour.toString().padLeft(2, '0');
    final minute = timestamp.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String get dateString {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(timestamp.year, timestamp.month, timestamp.day);
    if (messageDate == today) return '今天';
    if (messageDate == today.subtract(const Duration(days: 1))) return '昨天';
    return '${timestamp.month}月${timestamp.day}日';
  }

  bool shouldShowTime(Message? previousMessage) {
    if (previousMessage == null) return true;
    return timestamp.difference(previousMessage.timestamp).inMinutes > 0;
  }

  bool shouldShowDateDivider(Message? previousMessage) {
    if (previousMessage == null) return true;
    final previousDate = DateTime(
      previousMessage.timestamp.year,
      previousMessage.timestamp.month,
      previousMessage.timestamp.day,
    );
    final currentDate = DateTime(
      timestamp.year,
      timestamp.month,
      timestamp.day,
    );
    return currentDate != previousDate;
  }

  bool get hasTargetCharacter => targetCharacterId != null && targetCharacterId!.isNotEmpty;
}

String _generateId() {
  final timestamp = DateTime.now().millisecondsSinceEpoch;
  final random = DateTime.now().microsecondsSinceEpoch % 10000;
  return 'msg_${timestamp}_$random';
}

Message createUserMessage({
  required String content,
  MessageType type = MessageType.text,
  String? targetCharacterId,
}) {
  return Message(
    id: _generateId(),
    content: content,
    role: MessageRole.user,
    type: type,
    timestamp: DateTime.now(),
    targetCharacterId: targetCharacterId,
  );
}

Message createAssistantMessage({
  required String content,
  MessageType type = MessageType.text,
  String? name,
  String? avatar,
  String? characterId,
}) {
  return Message(
    id: _generateId(),
    content: content,
    role: MessageRole.assistant,
    type: type,
    timestamp: DateTime.now(),
    name: name,
    avatar: avatar,
    characterId: characterId,
  );
}

Message createSystemMessage({
  required String content,
  MessageType type = MessageType.system,
}) {
  return Message(
    id: _generateId(),
    content: content,
    role: MessageRole.system,
    type: type,
    timestamp: DateTime.now(),
  );
}

Message createErrorMessage({required String content}) {
  return Message(
    id: _generateId(),
    content: content,
    role: MessageRole.system,
    type: MessageType.error,
    timestamp: DateTime.now(),
  );
}
