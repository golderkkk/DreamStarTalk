import '../entities/ai_provider.dart';

/// AI 提供商接口
abstract class AIService {
  /// 提供商类型
  ProviderType get type;
  
  /// 提供商名称
  String get name;
  
  /// 发送消息（同步）
  Future<AIResponse> sendMessage({
    required List<ChatMessage> messages,
    required String model,
    GenerationParams? params,
  });
  
  /// 发送消息（流式）
  Stream<AIResponseChunk> sendMessageStream({
    required List<ChatMessage> messages,
    required String model,
    GenerationParams? params,
  });
  
  /// 获取可用模型列表
  Future<List<AIModel>> getAvailableModels();
  
  /// 验证 API Key
  Future<bool> validateApiKey();
}

/// AI 服务异常
class AIServiceException implements Exception {
  final String message;
  final String? code;
  final int? statusCode;
  final dynamic originalError;
  
  const AIServiceException({
    required this.message,
    this.code,
    this.statusCode,
    this.originalError,
  });
  
  @override
  String toString() => 'AIServiceException: $message${code != null ? ' ($code)' : ''}';
}
