/// AI 提供商类型
enum ProviderType {
  mimo('MiMo'),
  deepseek('DeepSeek'),
  openai('OpenAI'),
  claude('Claude'),
  gemini('Gemini'),
  ollama('Ollama'),
  gateway('统一网关');
  
  final String label;
  const ProviderType(this.label);
}

/// AI 模型
class AIModel {
  final String id;
  final String name;
  final String? description;
  final int? contextLength;
  
  const AIModel({
    required this.id,
    required this.name,
    this.description,
    this.contextLength,
  });
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'contextLength': contextLength,
  };
  
  factory AIModel.fromJson(Map<String, dynamic> json) => AIModel(
    id: json['id'] as String,
    name: json['name'] as String,
    description: json['description'] as String?,
    contextLength: json['contextLength'] as int?,
  );
}

/// AI 提供商配置
class AIProviderConfig {
  final String id;
  final ProviderType type;
  final String name;
  final String apiKey;
  final String? endpoint;
  final String defaultModel;
  final List<String> availableModels;
  final Map<String, dynamic> defaultParams;
  final bool isEnabled;
  
  const AIProviderConfig({
    required this.id,
    required this.type,
    required this.name,
    required this.apiKey,
    this.endpoint,
    required this.defaultModel,
    this.availableModels = const [],
    this.defaultParams = const {},
    this.isEnabled = true,
  });
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'name': name,
    'apiKey': apiKey,
    'endpoint': endpoint,
    'defaultModel': defaultModel,
    'availableModels': availableModels,
    'defaultParams': defaultParams,
    'isEnabled': isEnabled,
  };
  
  factory AIProviderConfig.fromJson(Map<String, dynamic> json) => AIProviderConfig(
    id: json['id'] as String,
    type: ProviderType.values.byName(json['type'] as String),
    name: json['name'] as String,
    apiKey: json['apiKey'] as String,
    endpoint: json['endpoint'] as String?,
    defaultModel: json['defaultModel'] as String,
    availableModels: List<String>.from(json['availableModels'] ?? []),
    defaultParams: Map<String, dynamic>.from(json['defaultParams'] ?? {}),
    isEnabled: json['isEnabled'] as bool? ?? true,
  );
  
  AIProviderConfig copyWith({
    String? id,
    ProviderType? type,
    String? name,
    String? apiKey,
    String? endpoint,
    String? defaultModel,
    List<String>? availableModels,
    Map<String, dynamic>? defaultParams,
    bool? isEnabled,
  }) {
    return AIProviderConfig(
      id: id ?? this.id,
      type: type ?? this.type,
      name: name ?? this.name,
      apiKey: apiKey ?? this.apiKey,
      endpoint: endpoint ?? this.endpoint,
      defaultModel: defaultModel ?? this.defaultModel,
      availableModels: availableModels ?? this.availableModels,
      defaultParams: defaultParams ?? this.defaultParams,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }
}

/// AI 响应
class AIResponse {
  final String content;
  final String? model;
  final Usage? usage;
  final Map<String, dynamic>? metadata;
  
  const AIResponse({
    required this.content,
    this.model,
    this.usage,
    this.metadata,
  });
}

/// AI 响应分块（流式）
class AIResponseChunk {
  final String content;
  final bool isDone;
  final String? model;
  
  const AIResponseChunk({
    required this.content,
    this.isDone = false,
    this.model,
  });
}

/// 使用量统计
class Usage {
  final int promptTokens;
  final int completionTokens;
  final int totalTokens;
  
  const Usage({
    required this.promptTokens,
    required this.completionTokens,
    required this.totalTokens,
  });
}

/// 生成参数
class GenerationParams {
  final double temperature;
  final double topP;
  final int? maxTokens;
  final double? frequencyPenalty;
  final double? presencePenalty;
  final List<String>? stopSequences;
  final bool stream;
  
  const GenerationParams({
    this.temperature = 0.7,
    this.topP = 1.0,
    this.maxTokens,
    this.frequencyPenalty,
    this.presencePenalty,
    this.stopSequences,
    this.stream = true,
  });
  
  Map<String, dynamic> toMap() {
    return {
      'temperature': temperature,
      'top_p': topP,
      if (maxTokens != null) 'max_tokens': maxTokens,
      if (frequencyPenalty != null) 'frequency_penalty': frequencyPenalty,
      if (presencePenalty != null) 'presence_penalty': presencePenalty,
      if (stopSequences != null) 'stop': stopSequences,
      'stream': stream,
    };
  }
  
  GenerationParams copyWith({
    double? temperature,
    double? topP,
    int? maxTokens,
    double? frequencyPenalty,
    double? presencePenalty,
    List<String>? stopSequences,
    bool? stream,
  }) {
    return GenerationParams(
      temperature: temperature ?? this.temperature,
      topP: topP ?? this.topP,
      maxTokens: maxTokens ?? this.maxTokens,
      frequencyPenalty: frequencyPenalty ?? this.frequencyPenalty,
      presencePenalty: presencePenalty ?? this.presencePenalty,
      stopSequences: stopSequences ?? this.stopSequences,
      stream: stream ?? this.stream,
    );
  }
}

/// 聊天消息（支持多模态：文本 + 图片）
class ChatMessage {
  final ChatMessageRole role;
  final String content;
  final String? name;
  final List<String>? imageUrls; // base64 data URIs

  const ChatMessage({
    required this.role,
    required this.content,
    this.name,
    this.imageUrls,
  });

  bool get hasImages => imageUrls != null && imageUrls!.isNotEmpty;

  Map<String, dynamic> toMap() {
    if (hasImages) {
      // 多模态格式：content 是数组
      final parts = <Map<String, dynamic>>[];
      parts.add({'type': 'text', 'text': content});
      for (final url in imageUrls!) {
        parts.add({
          'type': 'image_url',
          'image_url': {'url': url},
        });
      }
      return {
        'role': role.name,
        'content': parts,
        if (name != null) 'name': name,
      };
    }
    return {
      'role': role.name,
      'content': content,
      if (name != null) 'name': name,
    };
  }
}

/// 消息角色（用于 AI API）
enum ChatMessageRole {
  system,
  user,
  assistant,
}
