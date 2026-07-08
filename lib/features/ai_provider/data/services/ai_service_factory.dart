import '../../domain/entities/ai_provider.dart';
import '../../domain/repositories/ai_service.dart';
import 'mimo_service.dart';
import 'deepseek_service.dart';

/// AI 服务工厂
class AIServiceFactory {
  /// 创建 AI 服务实例
  static AIService create({
    required ProviderType type,
    required String apiKey,
    String? endpoint,
  }) {
    switch (type) {
      case ProviderType.mimo:
        return MiMoService(apiKey: apiKey, endpoint: endpoint);
      case ProviderType.deepseek:
        return DeepSeekService(apiKey: apiKey, endpoint: endpoint);
      case ProviderType.openai:
        return _OpenAIService(apiKey: apiKey, endpoint: endpoint);
      case ProviderType.claude:
        return _ClaudeService(apiKey: apiKey, endpoint: endpoint);
      case ProviderType.gemini:
        return _GeminiService(apiKey: apiKey, endpoint: endpoint);
      case ProviderType.ollama:
        return _OllamaService(endpoint: endpoint ?? 'http://localhost:11434/api');
      case ProviderType.gateway:
        return _GatewayService(gatewayEndpoint: endpoint!, apiKey: apiKey);
    }
  }

  /// 获取可用模型列表（调用 API，失败时返回默认模型）
  static Future<List<AIModel>> fetchAvailableModels({
    required ProviderType type,
    required String apiKey,
    String? endpoint,
  }) async {
    try {
      final svc = create(type: type, apiKey: apiKey, endpoint: endpoint);
      final models = await svc.getAvailableModels();
      if (models.isNotEmpty) return models;
    } catch (_) {}
    return defaultModelsFor(type);
  }

  /// 获取默认模型列表（离线兜底）
  static List<AIModel> defaultModelsFor(ProviderType type) {
    switch (type) {
      case ProviderType.mimo:
        return const [AIModel(id: 'mimo-v2.5-pro', name: 'MiMo-V2.5-Pro', description: '万亿参数，1M 上下文', contextLength: 1000000), AIModel(id: 'mimo-v2.5', name: 'MiMo-V2.5', description: '全模态感知', contextLength: 1000000)];
      case ProviderType.deepseek:
        return const [AIModel(id: 'deepseek-v4-flash', name: 'DeepSeek-V4-Flash', description: '非思考模式', contextLength: 1000000), AIModel(id: 'deepseek-v4-pro', name: 'DeepSeek-V4-Pro', description: '思考模式', contextLength: 1000000)];
      default:
        return const [];
    }
  }
}

/// OpenAI 服务（简化实现）
class _OpenAIService extends MiMoService {
  _OpenAIService({
    required String apiKey,
    String? endpoint,
  }) : super(
          apiKey: apiKey,
          endpoint: endpoint ?? 'https://api.openai.com/v1',
        );
  
  @override
  ProviderType get type => ProviderType.openai;
  
  @override
  String get name => 'OpenAI';
  
  @override
  Future<List<AIModel>> getAvailableModels() async {
    return const [
      AIModel(id: 'gpt-4o', name: 'GPT-4o', contextLength: 128000),
      AIModel(id: 'gpt-4o-mini', name: 'GPT-4o Mini', contextLength: 128000),
      AIModel(id: 'gpt-4-turbo', name: 'GPT-4 Turbo', contextLength: 128000),
      AIModel(id: 'gpt-3.5-turbo', name: 'GPT-3.5 Turbo', contextLength: 16000),
    ];
  }
}

/// Claude 服务（简化实现）
class _ClaudeService extends MiMoService {
  _ClaudeService({
    required String apiKey,
    String? endpoint,
  }) : super(
          apiKey: apiKey,
          endpoint: endpoint ?? 'https://api.anthropic.com/v1',
        );
  
  @override
  ProviderType get type => ProviderType.claude;
  
  @override
  String get name => 'Claude';
  
  @override
  Future<List<AIModel>> getAvailableModels() async {
    return const [
      AIModel(id: 'claude-3-opus-20240229', name: 'Claude 3 Opus', contextLength: 200000),
      AIModel(id: 'claude-3-sonnet-20240229', name: 'Claude 3 Sonnet', contextLength: 200000),
      AIModel(id: 'claude-3-haiku-20240307', name: 'Claude 3 Haiku', contextLength: 200000),
    ];
  }
}

/// Gemini 服务（简化实现）
class _GeminiService extends MiMoService {
  _GeminiService({
    required String apiKey,
    String? endpoint,
  }) : super(
          apiKey: apiKey,
          endpoint: endpoint ?? 'https://generativelanguage.googleapis.com/v1beta',
        );
  
  @override
  ProviderType get type => ProviderType.gemini;
  
  @override
  String get name => 'Gemini';
  
  @override
  Future<List<AIModel>> getAvailableModels() async {
    return const [
      AIModel(id: 'gemini-pro', name: 'Gemini Pro', contextLength: 32000),
      AIModel(id: 'gemini-pro-vision', name: 'Gemini Pro Vision', contextLength: 32000),
    ];
  }
}

/// Ollama 服务
class _OllamaService extends MiMoService {
  _OllamaService({
    String? endpoint,
  }) : super(
          apiKey: 'ollama',
          endpoint: endpoint ?? 'http://localhost:11434/api',
        );
  
  @override
  ProviderType get type => ProviderType.ollama;
  
  @override
  String get name => 'Ollama';
  
  @override
  Map<String, dynamic> buildRequestBody({
    required List<ChatMessage> messages,
    required String model,
    GenerationParams? params,
  }) {
    return {
      'model': model,
      'messages': messages.map((m) => m.toMap()).toList(),
      'stream': params?.stream ?? true,
      'options': {
        'temperature': params?.temperature ?? 0.7,
        'top_p': params?.topP ?? 1.0,
        'num_predict': params?.maxTokens,
      },
    };
  }
  
  @override
  Future<List<AIModel>> getAvailableModels() async {
    try {
      final response = await dio.get('/tags');
      return (response.data['models'] as List)
          .map((model) => AIModel(
                id: model['name'] as String,
                name: model['name'] as String,
              ))
          .toList();
    } catch (e) {
      return [];
    }
  }
}

/// 网关服务
class _GatewayService extends MiMoService {
  final ProviderType targetType;
  
  _GatewayService({
    required String gatewayEndpoint,
    required String apiKey,
    this.targetType = ProviderType.openai,
  }) : super(
          apiKey: apiKey,
          endpoint: gatewayEndpoint,
        );
  
  @override
  ProviderType get type => ProviderType.gateway;
  
  @override
  String get name => '统一网关';
  
  @override
  Map<String, dynamic> buildRequestBody({
    required List<ChatMessage> messages,
    required String model,
    GenerationParams? params,
  }) {
    return {
      'target_type': targetType.name,
      'model': model,
      'messages': messages.map((m) => m.toMap()).toList(),
      ...(params ?? const GenerationParams()).toMap(),
    };
  }
}
