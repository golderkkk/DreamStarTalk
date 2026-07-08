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

  factory World.fromJson(Map<String, dynamic> json) => World(
    id: json['id'] as String,
    name: json['name'] as String,
    coverImage: json['coverImage'] as String?,
    description: json['description'] as String?,
    rules: json['rules'] as String?,
    history: json['history'] as String?,
    scenes: (json['scenes'] as List<dynamic>?)
        ?.map((s) => Scene.fromJson(s as Map<String, dynamic>))
        .toList() ?? [],
    npcs: (json['npcs'] as List<dynamic>?)
        ?.map((n) => NPC.fromJson(n as Map<String, dynamic>))
        .toList() ?? [],
    storylines: (json['storylines'] as List<dynamic>?)
        ?.map((s) => Storyline.fromJson(s as Map<String, dynamic>))
        .toList() ?? [],
    tags: (json['tags'] as List<dynamic>?)
        ?.map((e) => e as String)
        .toList() ?? [],
    isFavorite: json['isFavorite'] as bool? ?? false,
    currentSceneId: json['currentSceneId'] as String?,
    createdAt: json['createdAt'] != null
        ? DateTime.parse(json['createdAt'] as String)
        : null,
    updatedAt: json['updatedAt'] != null
        ? DateTime.parse(json['updatedAt'] as String)
        : null,
  );

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

  factory Scene.fromJson(Map<String, dynamic> json) => Scene(
    id: json['id'] as String,
    name: json['name'] as String,
    description: json['description'] as String?,
    image: json['image'] as String?,
    time: json['time'] as String?,
    weather: json['weather'] as String?,
    atmosphere: json['atmosphere'] as String?,
    npcs: (json['npcs'] as List<dynamic>?)
        ?.map((e) => e as String)
        .toList() ?? [],
    metadata: json['metadata'] as Map<String, dynamic>?,
  );

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

  factory NPC.fromJson(Map<String, dynamic> json) => NPC(
    id: json['id'] as String,
    name: json['name'] as String,
    avatar: json['avatar'] as String?,
    description: json['description'] as String?,
    personality: json['personality'] as String?,
    backstory: json['backstory'] as String?,
    speakingStyle: json['speakingStyle'] as String?,
    relationship: json['relationship'] as String?,
    tags: (json['tags'] as List<dynamic>?)
        ?.map((e) => e as String)
        .toList() ?? [],
    relationships: (json['relationships'] as Map<String, dynamic>?)
        ?.map((k, v) => MapEntry(k, v as String)),
  );

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

  factory Storyline.fromJson(Map<String, dynamic> json) => Storyline(
    id: json['id'] as String,
    title: json['title'] as String,
    description: json['description'] as String?,
    type: StorylineType.values.byName(json['type'] as String? ?? 'main'),
    status: StorylineStatus.values.byName(json['status'] as String? ?? 'active'),
    nodes: (json['nodes'] as List<dynamic>?)
        ?.map((n) => StoryNode.fromJson(n as Map<String, dynamic>))
        .toList() ?? [],
    currentNodeId: json['currentNodeId'] as String?,
    startedAt: json['startedAt'] != null
        ? DateTime.parse(json['startedAt'] as String)
        : null,
    completedAt: json['completedAt'] != null
        ? DateTime.parse(json['completedAt'] as String)
        : null,
  );

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

  factory StoryNode.fromJson(Map<String, dynamic> json) => StoryNode(
    id: json['id'] as String,
    title: json['title'] as String,
    description: json['description'] as String?,
    content: json['content'] as String?,
    type: StoryNodeType.values.byName(json['type'] as String? ?? 'dialogue'),
    choices: (json['choices'] as List<dynamic>?)
        ?.map((c) => StoryChoice.fromJson(c as Map<String, dynamic>))
        .toList() ?? [],
    nextNodeId: json['nextNodeId'] as String?,
    conditions: json['conditions'] as Map<String, dynamic>?,
    effects: json['effects'] as Map<String, dynamic>?,
  );
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

  factory StoryChoice.fromJson(Map<String, dynamic> json) => StoryChoice(
    id: json['id'] as String,
    text: json['text'] as String,
    description: json['description'] as String?,
    nextNodeId: json['nextNodeId'] as String?,
    conditions: json['conditions'] as Map<String, dynamic>?,
    effects: json['effects'] as Map<String, dynamic>?,
  );
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
