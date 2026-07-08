/// 角色实体
class Character {
  final String id;
  final String name;
  final String? avatar;
  final String? description;
  final String? personality;
  final String? backstory;
  final String? speakingStyle;
  final String? systemPrompt;
  final List<String> exampleDialogues;
  final String? firstMessage;
  final List<String> tags;
  final bool isFavorite;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Character({
    required this.id,
    required this.name,
    this.avatar,
    this.description,
    this.personality,
    this.backstory,
    this.speakingStyle,
    this.systemPrompt,
    this.exampleDialogues = const [],
    this.firstMessage,
    this.tags = const [],
    this.isFavorite = false,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'avatar': avatar,
    'description': description,
    'personality': personality,
    'backstory': backstory,
    'speakingStyle': speakingStyle,
    'systemPrompt': systemPrompt,
    'exampleDialogues': exampleDialogues,
    'firstMessage': firstMessage,
    'tags': tags,
    'isFavorite': isFavorite,
    'createdAt': createdAt?.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
  };

  factory Character.fromJson(Map<String, dynamic> json) {
    // Defensive parsing - handle type mismatches from Hive
    final id = json['id']?.toString() ?? '';
    final name = json['name']?.toString() ?? '';
    final avatar = json['avatar']?.toString();
    final description = json['description']?.toString();
    final personality = json['personality']?.toString();
    final backstory = json['backstory']?.toString();
    final speakingStyle = json['speakingStyle']?.toString();
    final systemPrompt = json['systemPrompt']?.toString();
    final firstMessage = json['firstMessage']?.toString();

    final exampleDialogues = _parseStringList(json['exampleDialogues']);
    final tags = _parseStringList(json['tags']);
    final isFavorite = json['isFavorite'] == true || json['isFavorite'] == 1;

    DateTime? createdAt;
    if (json['createdAt'] != null) {
      try { createdAt = DateTime.parse(json['createdAt'].toString()); } catch (_) {}
    }
    DateTime? updatedAt;
    if (json['updatedAt'] != null) {
      try { updatedAt = DateTime.parse(json['updatedAt'].toString()); } catch (_) {}
    }

    return Character(
      id: id, name: name, avatar: avatar, description: description,
      personality: personality, backstory: backstory, speakingStyle: speakingStyle,
      systemPrompt: systemPrompt, exampleDialogues: exampleDialogues,
      firstMessage: firstMessage, tags: tags, isFavorite: isFavorite,
      createdAt: createdAt, updatedAt: updatedAt,
    );
  }

  /// Safe list parser - handles Hive's List<dynamic> and various edge cases
  static List<String> _parseStringList(dynamic raw) {
    if (raw == null) return [];
    if (raw is List) return raw.map((e) => e.toString()).toList();
    if (raw is String && raw.isNotEmpty) {
      try {
        final decoded = List.from(raw.startsWith('[') ? (raw.contains(',') ? raw.split(',').map((s) => s.trim()) : []) : raw.split(',').map((s) => s.trim()));
        return decoded.map((e) => e.toString()).toList();
      } catch (_) {}
    }
    return [];
  }

  Character copyWith({
    String? id, String? name, String? avatar, String? description,
    String? personality, String? backstory, String? speakingStyle,
    String? systemPrompt, List<String>? exampleDialogues, String? firstMessage,
    List<String>? tags, bool? isFavorite, DateTime? createdAt, DateTime? updatedAt,
  }) {
    return Character(
      id: id ?? this.id, name: name ?? this.name, avatar: avatar ?? this.avatar,
      description: description ?? this.description, personality: personality ?? this.personality,
      backstory: backstory ?? this.backstory, speakingStyle: speakingStyle ?? this.speakingStyle,
      systemPrompt: systemPrompt ?? this.systemPrompt, exampleDialogues: exampleDialogues ?? this.exampleDialogues,
      firstMessage: firstMessage ?? this.firstMessage, tags: tags ?? this.tags,
      isFavorite: isFavorite ?? this.isFavorite, createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // ── Computed properties (instance methods, always work) ──
  String get displayName => name.isNotEmpty ? name : '未命名角色';
  String get shortName {
    final n = displayName;
    return n.length > 12 ? '${n.substring(0, 12)}...' : n;
  }
  String get summary {
    if (description != null && description!.isNotEmpty) {
      return description!.length > 100 ? '${description!.substring(0, 100)}...' : description!;
    }
    return '暂无简介';
  }
  bool get hasAvatar => avatar != null && avatar!.isNotEmpty;
  bool get hasSystemPrompt => systemPrompt != null && systemPrompt!.isNotEmpty;
  bool get hasFirstMessage => firstMessage != null && firstMessage!.isNotEmpty;
  bool get hasExampleDialogues => exampleDialogues.isNotEmpty;
}
