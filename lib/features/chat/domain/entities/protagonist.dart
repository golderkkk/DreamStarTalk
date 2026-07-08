/// 主角实体 - 用户在对话中扮演的角色
class Protagonist {
  final String id;
  final String name;           // 称呼/名字
  final String? avatar;        // 头像
  final String? description;   // 简介/描述
  final String? personality;   // 性格特征
  final String? backstory;     // 背景故事
  final String? gender;        // 性别
  final String? appearance;    // 外貌描述
  final Map<String, String>? customFields; // 自定义字段

  const Protagonist({
    required this.id,
    required this.name,
    this.avatar,
    this.description,
    this.personality,
    this.backstory,
    this.gender,
    this.appearance,
    this.customFields,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'avatar': avatar,
    'description': description,
    'personality': personality,
    'backstory': backstory,
    'gender': gender,
    'appearance': appearance,
    'customFields': customFields,
  };

  factory Protagonist.fromJson(Map<String, dynamic> json) => Protagonist(
    id: json['id'] as String,
    name: json['name'] as String,
    avatar: json['avatar'] as String?,
    description: json['description'] as String?,
    personality: json['personality'] as String?,
    backstory: json['backstory'] as String?,
    gender: json['gender'] as String?,
    appearance: json['appearance'] as String?,
    customFields: (json['customFields'] as Map<String, dynamic>?)
        ?.map((k, v) => MapEntry(k, v as String)),
  );

  Protagonist copyWith({
    String? id,
    String? name,
    String? avatar,
    String? description,
    String? personality,
    String? backstory,
    String? gender,
    String? appearance,
    Map<String, String>? customFields,
  }) {
    return Protagonist(
      id: id ?? this.id,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      description: description ?? this.description,
      personality: personality ?? this.personality,
      backstory: backstory ?? this.backstory,
      gender: gender ?? this.gender,
      appearance: appearance ?? this.appearance,
      customFields: customFields ?? this.customFields,
    );
  }
}

/// 主角扩展方法
extension ProtagonistExtension on Protagonist {
  String get displayName => name.isNotEmpty ? name : '未命名主角';
  
  bool get hasAvatar => avatar != null && avatar!.isNotEmpty;
  
  String get summary {
    final parts = <String>[];
    if (description != null && description!.isNotEmpty) {
      parts.add(description!);
    }
    if (parts.isEmpty) return '暂无简介';
    final text = parts.join('，');
    return text.length > 50 ? '${text.substring(0, 50)}...' : text;
  }
}
