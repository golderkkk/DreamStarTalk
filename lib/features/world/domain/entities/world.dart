DateTime? _tryParseDate(dynamic v) {
  if (v == null) return null;
  try { return DateTime.parse(v.toString()); } catch (_) { return null; }
}

/// 世界实体
class World {
  final String id;
  final String name;
  final String? coverImage;
  final String? description;
  final String? rules;
  final String? history;
  final List<Scene> scenes;
  final List<NPC> npcs;
  final List<Storyline> storylines;
  final List<String> tags;
  final bool isFavorite;
  final String? currentSceneId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const World({
    required this.id,
    required this.name,
    this.coverImage,
    this.description,
    this.rules,
    this.history,
    this.scenes = const [],
    this.npcs = const [],
    this.storylines = const [],
    this.tags = const [],
    this.isFavorite = false,
    this.currentSceneId,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'coverImage': coverImage,
    'description': description,
    'rules': rules,
    'history': history,
    'scenes': scenes.map((s) => s.toJson()).toList(),
    'npcs': npcs.map((n) => n.toJson()).toList(),
    'storylines': storylines.map((s) => s.toJson()).toList(),
    'tags': tags,
    'isFavorite': isFavorite,
    'currentSceneId': currentSceneId,
    'createdAt': createdAt?.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
  };

  factory World.fromJson(Map<String, dynamic> json) {
    try {
      return World(
        id: (json['id'] ?? '').toString(),
        name: (json['name'] ?? '').toString(),
        coverImage: json['coverImage']?.toString(),
        description: json['description']?.toString(),
        rules: json['rules']?.toString(),
        history: json['history']?.toString(),
        scenes: (json['scenes'] as List?)
            ?.whereType<Map>()
            .map((s) => Scene.fromJson(Map<String, dynamic>.from(s)))
            .toList() ?? [],
        npcs: (json['npcs'] as List?)
            ?.whereType<Map>()
            .map((n) => NPC.fromJson(Map<String, dynamic>.from(n)))
            .toList() ?? [],
        storylines: (json['storylines'] as List?)
            ?.whereType<Map>()
            .map((s) => Storyline.fromJson(Map<String, dynamic>.from(s)))
            .toList() ?? [],
        tags: (json['tags'] as List?)
            ?.map((e) => e.toString())
            .toList() ?? [],
        isFavorite: json['isFavorite'] == true,
        currentSceneId: json['currentSceneId']?.toString(),
        createdAt: _tryParseDate(json['createdAt']),
        updatedAt: _tryParseDate(json['updatedAt']),
      );
    } catch (_) {
      return World(id: (json['id'] ?? '').toString(), name: (json['name'] ?? '未知').toString());
    }
  }

  World copyWith({
    String? id,
    String? name,
    String? coverImage,
    String? description,
    String? rules,
    String? history,
    List<Scene>? scenes,
    List<NPC>? npcs,
    List<Storyline>? storylines,
    List<String>? tags,
    bool? isFavorite,
    String? currentSceneId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return World(
      id: id ?? this.id,
      name: name ?? this.name,
      coverImage: coverImage ?? this.coverImage,
      description: description ?? this.description,
      rules: rules ?? this.rules,
      history: history ?? this.history,
      scenes: scenes ?? this.scenes,
      npcs: npcs ?? this.npcs,
      storylines: storylines ?? this.storylines,
      tags: tags ?? this.tags,
      isFavorite: isFavorite ?? this.isFavorite,
      currentSceneId: currentSceneId ?? this.currentSceneId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// 场景实体
class Scene {
  final String id;
  final String name;
  final String? description;
  final String? image;
  final String? time;
  final String? weather;
  final String? atmosphere;
  final List<String> npcs;
  final Map<String, dynamic>? metadata;

  const Scene({
    required this.id,
    required this.name,
    this.description,
    this.image,
    this.time,
    this.weather,
    this.atmosphere,
    this.npcs = const [],
    this.metadata,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'image': image,
    'time': time,
    'weather': weather,
    'atmosphere': atmosphere,
    'npcs': npcs,
    'metadata': metadata,
  };

  factory Scene.fromJson(Map<String, dynamic> json) {
    try {
      return Scene(
        id: (json['id'] ?? '').toString(),
        name: (json['name'] ?? '').toString(),
        description: json['description']?.toString(),
        image: json['image']?.toString(),
        time: json['time']?.toString(),
        weather: json['weather']?.toString(),
        atmosphere: json['atmosphere']?.toString(),
        npcs: (json['npcs'] as List?)
            ?.map((e) => e.toString())
            .toList() ?? [],
        metadata: json['metadata'] is Map ? Map<String, dynamic>.from(json['metadata'] as Map) : null,
      );
    } catch (_) {
      return Scene(id: (json['id'] ?? '').toString(), name: (json['name'] ?? '').toString());
    }
  }

  Scene copyWith({
    String? id,
    String? name,
    String? description,
    String? image,
    String? time,
    String? weather,
    String? atmosphere,
    List<String>? npcs,
    Map<String, dynamic>? metadata,
  }) {
    return Scene(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      image: image ?? this.image,
      time: time ?? this.time,
      weather: weather ?? this.weather,
      atmosphere: atmosphere ?? this.atmosphere,
      npcs: npcs ?? this.npcs,
      metadata: metadata ?? this.metadata,
    );
  }
}

/// NPC 实体
class NPC {
  final String id;
  final String name;
  final String? avatar;
  final String? description;
  final String? personality;
  final String? backstory;
  final String? speakingStyle;
  final String? relationship;
  final List<String> tags;
  final Map<String, String>? relationships;

  const NPC({
    required this.id,
    required this.name,
    this.avatar,
    this.description,
    this.personality,
    this.backstory,
    this.speakingStyle,
    this.relationship,
    this.tags = const [],
    this.relationships,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'avatar': avatar,
    'description': description,
    'personality': personality,
    'backstory': backstory,
    'speakingStyle': speakingStyle,
    'relationship': relationship,
    'tags': tags,
    'relationships': relationships,
  };

  factory NPC.fromJson(Map<String, dynamic> json) {
    try {
      return NPC(
        id: (json['id'] ?? '').toString(),
        name: (json['name'] ?? '').toString(),
        avatar: json['avatar']?.toString(),
        description: json['description']?.toString(),
        personality: json['personality']?.toString(),
        backstory: json['backstory']?.toString(),
        speakingStyle: json['speakingStyle']?.toString(),
        relationship: json['relationship']?.toString(),
        tags: (json['tags'] as List?)
            ?.map((e) => e.toString())
            .toList() ?? [],
        relationships: (json['relationships'] as Map<String, dynamic>?)
            ?.map((k, v) => MapEntry(k.toString(), v.toString())),
      );
    } catch (_) {
      return NPC(id: (json['id'] ?? '').toString(), name: (json['name'] ?? '').toString());
    }
  }

  NPC copyWith({
    String? id,
    String? name,
    String? avatar,
    String? description,
    String? personality,
    String? backstory,
    String? speakingStyle,
    String? relationship,
    List<String>? tags,
    Map<String, String>? relationships,
  }) {
    return NPC(
      id: id ?? this.id,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      description: description ?? this.description,
      personality: personality ?? this.personality,
      backstory: backstory ?? this.backstory,
      speakingStyle: speakingStyle ?? this.speakingStyle,
      relationship: relationship ?? this.relationship,
      tags: tags ?? this.tags,
      relationships: relationships ?? this.relationships,
    );
  }
}

/// 剧情实体
enum StorylineType {
  main('主线'),
  side('支线'),
  personal('个人'),
  event('事件');

  final String label;
  const StorylineType(this.label);
}

enum StorylineStatus {
  active('进行中'),
  paused('暂停'),
  completed('已完成'),
  failed('已失败');

  final String label;
  const StorylineStatus(this.label);
}

class Storyline {
  final String id;
  final String title;
  final String? description;
  final StorylineType type;
  final StorylineStatus status;
  final List<StoryNode> nodes;
  final String? currentNodeId;
  final DateTime? startedAt;
  final DateTime? completedAt;

  const Storyline({
    required this.id,
    required this.title,
    this.description,
    this.type = StorylineType.main,
    this.status = StorylineStatus.active,
    this.nodes = const [],
    this.currentNodeId,
    this.startedAt,
    this.completedAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'type': type.name,
    'status': status.name,
    'nodes': nodes.map((n) => n.toJson()).toList(),
    'currentNodeId': currentNodeId,
    'startedAt': startedAt?.toIso8601String(),
    'completedAt': completedAt?.toIso8601String(),
  };

  factory Storyline.fromJson(Map<String, dynamic> json) {
    try {
      return Storyline(
        id: (json['id'] ?? '').toString(),
        title: (json['title'] ?? '').toString(),
        description: json['description']?.toString(),
        type: StorylineType.values.asNameMap()[json['type']?.toString()] ?? StorylineType.main,
        status: StorylineStatus.values.asNameMap()[json['status']?.toString()] ?? StorylineStatus.active,
        nodes: (json['nodes'] as List?)
            ?.whereType<Map>()
            .map((n) => StoryNode.fromJson(Map<String, dynamic>.from(n)))
            .toList() ?? [],
        currentNodeId: json['currentNodeId']?.toString(),
        startedAt: _tryParseDate(json['startedAt']),
        completedAt: _tryParseDate(json['completedAt']),
      );
    } catch (_) {
      return Storyline(id: (json['id'] ?? '').toString(), title: (json['title'] ?? '').toString());
    }
  }

  Storyline copyWith({
    String? id,
    String? title,
    String? description,
    StorylineType? type,
    StorylineStatus? status,
    List<StoryNode>? nodes,
    String? currentNodeId,
    DateTime? startedAt,
    DateTime? completedAt,
  }) {
    return Storyline(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      status: status ?? this.status,
      nodes: nodes ?? this.nodes,
      currentNodeId: currentNodeId ?? this.currentNodeId,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}

/// 剧情节点类型
enum StoryNodeType {
  dialogue('对话'),
  event('事件'),
  choice('选择'),
  battle('战斗'),
  discovery('发现');

  final String label;
  const StoryNodeType(this.label);
}

/// 剧情节点
class StoryNode {
  final String id;
  final String title;
  final String? description;
  final String? content;
  final StoryNodeType type;
  final List<StoryChoice> choices;
  final String? nextNodeId;
  final Map<String, dynamic>? conditions;
  final Map<String, dynamic>? effects;

  const StoryNode({
    required this.id,
    required this.title,
    this.description,
    this.content,
    this.type = StoryNodeType.dialogue,
    this.choices = const [],
    this.nextNodeId,
    this.conditions,
    this.effects,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'content': content,
    'type': type.name,
    'choices': choices.map((c) => c.toJson()).toList(),
    'nextNodeId': nextNodeId,
    'conditions': conditions,
    'effects': effects,
  };

  factory StoryNode.fromJson(Map<String, dynamic> json) {
    try {
      return StoryNode(
        id: (json['id'] ?? '').toString(),
        title: (json['title'] ?? '').toString(),
        description: json['description']?.toString(),
        content: json['content']?.toString(),
        type: StoryNodeType.values.asNameMap()[json['type']?.toString()] ?? StoryNodeType.dialogue,
        choices: (json['choices'] as List?)
            ?.whereType<Map>()
            .map((c) => StoryChoice.fromJson(Map<String, dynamic>.from(c)))
            .toList() ?? [],
        nextNodeId: json['nextNodeId']?.toString(),
        conditions: json['conditions'] is Map ? Map<String, dynamic>.from(json['conditions'] as Map) : null,
        effects: json['effects'] is Map ? Map<String, dynamic>.from(json['effects'] as Map) : null,
      );
    } catch (_) {
      return StoryNode(id: (json['id'] ?? '').toString(), title: (json['title'] ?? '').toString());
    }
  }
}

/// 剧情选择
class StoryChoice {
  final String id;
  final String text;
  final String? description;
  final String? nextNodeId;
  final Map<String, dynamic>? conditions;
  final Map<String, dynamic>? effects;

  const StoryChoice({
    required this.id,
    required this.text,
    this.description,
    this.nextNodeId,
    this.conditions,
    this.effects,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'text': text,
    'description': description,
    'nextNodeId': nextNodeId,
    'conditions': conditions,
    'effects': effects,
  };

  factory StoryChoice.fromJson(Map<String, dynamic> json) {
    try {
      return StoryChoice(
        id: (json['id'] ?? '').toString(),
        text: (json['text'] ?? '').toString(),
        description: json['description']?.toString(),
        nextNodeId: json['nextNodeId']?.toString(),
        conditions: json['conditions'] is Map ? Map<String, dynamic>.from(json['conditions'] as Map) : null,
        effects: json['effects'] is Map ? Map<String, dynamic>.from(json['effects'] as Map) : null,
      );
    } catch (_) {
      return StoryChoice(id: (json['id'] ?? '').toString(), text: (json['text'] ?? '').toString());
    }
  }
}

/// World 扩展方法
extension WorldExtension on World {
  String get displayName => name.isNotEmpty ? name : '未命名世界';

  String get summary {
    if (description != null && description!.isNotEmpty) {
      return description!.length > 100
          ? '${description!.substring(0, 100)}...'
          : description!;
    }
    return '暂无简介';
  }

  bool get hasCoverImage => coverImage != null && coverImage!.isNotEmpty;
  bool get hasScenes => scenes.isNotEmpty;
  bool get hasNPCs => npcs.isNotEmpty;
  bool get hasStorylines => storylines.isNotEmpty;

  Scene? get currentScene {
    if (currentSceneId == null) return null;
    try {
      return scenes.firstWhere((s) => s.id == currentSceneId);
    } catch (e) {
      return null;
    }
  }

  List<Storyline> get activeStorylines {
    return storylines.where((s) => s.status == StorylineStatus.active).toList();
  }

  Storyline? get mainStoryline {
    try {
      return storylines.firstWhere((s) => s.type == StorylineType.main);
    } catch (e) {
      return null;
    }
  }
}

extension SceneExtension on Scene {
  String get displayName => name.isNotEmpty ? name : '未命名场景';
  bool get hasImage => image != null && image!.isNotEmpty;
  bool get hasNPCs => npcs.isNotEmpty;
}

extension NPCExtension on NPC {
  String get displayName => name.isNotEmpty ? name : '未命名 NPC';
  bool get hasAvatar => avatar != null && avatar!.isNotEmpty;

  String get relationshipSummary {
    if (relationship != null && relationship!.isNotEmpty) {
      return relationship!;
    }
    return '暂无关系描述';
  }
}
