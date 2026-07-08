import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import '../../domain/entities/ai_provider.dart';
import '../../domain/repositories/ai_service.dart';

/// DeepSeek 提供商实现
/// 官方文档：https://api-docs.deepseek.com/
class DeepSeekService implements AIService {
  final String apiKey;
  final String endpoint;
  late final Dio dio;

  /// 规范化端点 URL：去除末尾斜杠和 /v1 后缀
  static String _normalizeEndpoint(String url) {
    url = url.trim().replaceAll(RegExp(r'/+$'), '');
    if (url.endsWith('/v1')) url = url.substring(0, url.length - 3);
    return url;
  }
  
  DeepSeekService({
    required this.apiKey,
    String? endpoint,
  }) : endpoint = _normalizeEndpoint((endpoint?.trim().isNotEmpty == true) ? endpoint! : 'https://api.deepseek.com') {
    dio = Dio(BaseOptions(
      baseUrl: this.endpoint,
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(minutes: 5),
    ));
    
    // 添加重试拦截器（使用同一个 Dio 实例）
    dio.interceptors.add(_RetryInterceptor(dio));
  }
  
  @override
  ProviderType get type => ProviderType.deepseek;
  
  @override
  String get name => 'DeepSeek';
  
  @override
  Future<AIResponse> sendMessage({
    required List<ChatMessage> messages,
    required String model,
    GenerationParams? params,
  }) async {
    try {
      final requestBody = buildRequestBody(
        messages: messages,
        model: model,
        params: params?.copyWith(stream: false),
      );
      
      final response = await dio.post(
        '/chat/completions',
        data: requestBody,
      );
      
      return parseResponse(response.data);
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }
  
  @override
  Stream<AIResponseChunk> sendMessageStream({
    required List<ChatMessage> messages,
    required String model,
    GenerationParams? params,
  }) async* {
    try {
      final requestBody = buildRequestBody(
        messages: messages,
        model: model,
        params: params?.copyWith(stream: true),
      );
      
      final response = await dio.post<ResponseBody>(
        '/chat/completions',
        data: requestBody,
        options: Options(responseType: ResponseType.stream),
      );
      
      yield* parseStreamResponse(response.data!.stream);
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }
  
  @override
  Future<List<AIModel>> getAvailableModels() async {
    try {
      final response = await dio.get('/models');
      final models = (response.data['data'] as List)
          .map((model) => AIModel(
                id: model['id'] as String,
                name: model['id'] as String,
              ))
          .toList();
      return models;
    } catch (e) {
      // 返回默认模型列表
      return defaultModels;
    }
  }
  
  @override
  Future<bool> validateApiKey() async {
    try {
      final resp = await dio.post('/chat/completions', data: {
        'model': defaultModels.first.id,
        'messages': [{'role': 'user', 'content': 'hi'}],
        'max_tokens': 1,
      });
      return resp.statusCode == 200;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw AIServiceException(message: 'API Key 无效，请检查 Key 是否正确', code: 'INVALID_KEY', statusCode: 401);
      }
      if (e.type == DioExceptionType.connectionError) {
        throw AIServiceException(message: '无法连接到 DeepSeek 服务器（${e.message ?? "连接被拒绝"}），请检查网络是否可访问 api.deepseek.com', code: 'CONN_ERROR');
      }
      if (e.type == DioExceptionType.connectionTimeout) {
        throw AIServiceException(message: '连接超时（30秒），请检查网络速度', code: 'TIMEOUT');
      }
      throw AIServiceException(message: '请求失败: ${e.message ?? e.type.name}', code: 'ERROR');
    } catch (e) {
      throw AIServiceException(message: '未知错误: $e', code: 'UNKNOWN');
    }
  }
  
  /// 构建请求体
  Map<String, dynamic> buildRequestBody({
    required List<ChatMessage> messages,
    required String model,
    GenerationParams? params,
  }) {
    return {
      'model': model,
      'messages': messages.map((m) => m.toMap()).toList(),
      ...(params ?? const GenerationParams()).toMap(),
    };
  }
  
  /// 解析响应
  AIResponse parseResponse(Map<String, dynamic> data) {
    final content = data['choices'][0]['message']['content'] as String;
    final model = data['model'] as String?;
    final usage = data['usage'] as Map<String, dynamic>?;
    
    return AIResponse(
      content: content,
      model: model,
      usage: usage != null
          ? Usage(
              promptTokens: usage['prompt_tokens'] as int,
              completionTokens: usage['completion_tokens'] as int,
              totalTokens: usage['total_tokens'] as int,
            )
          : null,
    );
  }
  
  /// 解析流式响应
  Stream<AIResponseChunk> parseStreamResponse(
    Stream<List<int>> stream,
  ) async* {
    String buffer = '';
    
    await for (final chunk in stream) {
      buffer += utf8.decode(chunk);
      
      final lines = buffer.split('\n');
      buffer = lines.removeLast();
      
      for (final line in lines) {
        if (line.startsWith('data: ')) {
          final data = line.substring(6).trim();
          
          if (data == '[DONE]') {
            yield const AIResponseChunk(content: '', isDone: true);
            return;
          }
          
          try {
            final json = jsonDecode(data);
            final delta = json['choices'][0]['delta'];
            final content = delta['content'] as String?;
            
            if (content != null) {
              yield AIResponseChunk(content: content);
            }
          } catch (e) {
            // 忽略解析错误
          }
        }
      }
    }
  }
  
  /// 处理 Dio 错误
  AIServiceException handleDioError(DioException error) {
    final msg = error.message ?? '未知错误';
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return AIServiceException(message: '连接超时（连接服务器超过30秒），请检查网络或 API 端点', code: 'TIMEOUT');
      case DioExceptionType.sendTimeout:
        return AIServiceException(message: '发送超时，请检查网络连接', code: 'SEND_TIMEOUT');
      case DioExceptionType.receiveTimeout:
        return AIServiceException(message: '接收超时（5分钟无响应），请检查网络或减少上下文长度', code: 'RECEIVE_TIMEOUT');
      case DioExceptionType.badResponse:
        return handleBadResponse(error.response);
      case DioExceptionType.cancel:
        return const AIServiceException(message: '请求已取消', code: 'CANCELLED');
      case DioExceptionType.connectionError:
        return AIServiceException(message: '无法连接到 API 服务器，请检查网络和端点配置', code: 'CONNECTION_ERROR');
      case DioExceptionType.unknown:
        return AIServiceException(message: '网络错误: $msg\n请检查 API 端点格式是否正确', code: 'NETWORK_ERROR');
      case DioExceptionType.badCertificate:
        return AIServiceException(message: 'SSL 证书验证失败', code: 'BAD_CERTIFICATE');
      case DioExceptionType.transformTimeout:
        return AIServiceException(message: '数据转换超时，请检查网络连接', code: 'TRANSFORM_TIMEOUT');
    }
  }
  
  /// 处理错误响应
  AIServiceException handleBadResponse(Response? response) {
    if (response == null) return const AIServiceException(message: '服务器无响应', code: 'NO_RESPONSE');
    final body = response.data?.toString() ?? '';
    final detail = body.isNotEmpty && body.length < 200 ? '\n响应:\n$body' : '';
    switch (response.statusCode) {
      case 401: return AIServiceException(message: 'API Key 无效，请检查 Key$detail', code: 'INVALID_API_KEY', statusCode: 401);
      case 403: return AIServiceException(message: '访问被拒绝$detail', code: 'FORBIDDEN', statusCode: 403);
      case 404: return AIServiceException(message: 'API 端点不存在，请检查 URL$detail', code: 'NOT_FOUND', statusCode: 404);
      case 429: return AIServiceException(message: '请求过于频繁$detail', code: 'RATE_LIMIT', statusCode: 429);
      case 500: case 502: case 503: return AIServiceException(message: '服务器错误 (${response.statusCode})$detail', code: 'SERVER_ERROR', statusCode: response.statusCode);
      default: return AIServiceException(message: '请求失败 (${response.statusCode})$detail', code: 'REQUEST_FAILED', statusCode: response.statusCode);
    }
  }
  
  /// DeepSeek 默认模型列表
  /// 参考：https://api-docs.deepseek.com/zh-cn/quick_start/pricing
  /// deepseek-chat 和 deepseek-reasoner 将于 2026/07/24 弃用
  /// 请使用 deepseek-v4-flash 和 deepseek-v4-pro
  static const List<AIModel> defaultModels = [
    AIModel(
      id: 'deepseek-v4-flash',
      name: 'DeepSeek-V4-Flash',
      description: '非思考模式，适合日常对话和写作',
      contextLength: 1000000,
    ),
    AIModel(
      id: 'deepseek-v4-pro',
      name: 'DeepSeek-V4-Pro',
      description: '思考模式，适合数学、代码和复杂推理',
      contextLength: 1000000,
    ),
    // 兼容旧版本（即将弃用）
    AIModel(
      id: 'deepseek-chat',
      name: 'DeepSeek Chat (旧版)',
      description: '即将弃用，请使用 DeepSeek-V4-Flash',
      contextLength: 128000,
    ),
    AIModel(
      id: 'deepseek-reasoner',
      name: 'DeepSeek Reasoner (旧版)',
      description: '即将弃用，请使用 DeepSeek-V4-Pro',
      contextLength: 128000,
    ),
  ];
}

/// 重试拦截器
class _RetryInterceptor extends Interceptor {
  static const int _maxRetries = 2;
  static const List<Duration> _retryDelays = [
    Duration(seconds: 1),
    Duration(seconds: 3),
  ];
  final Dio _dio;
  _RetryInterceptor(this._dio);
  
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final retryCount = err.requestOptions.extra['retryCount'] ?? 0;
    
    if (retryCount < _maxRetries && _shouldRetry(err)) {
      final delay = _retryDelays[retryCount];
      await Future.delayed(delay);
      
      err.requestOptions.extra['retryCount'] = retryCount + 1;
      
      try {
        final response = await _dio.fetch(err.requestOptions);
        handler.resolve(response);
      } catch (e) {
        handler.next(err);
      }
    } else {
      handler.next(err);
    }
  }
  
  bool _shouldRetry(DioException err) {
    return err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        (err.response?.statusCode == 429) ||
        (err.response?.statusCode ?? 0) >= 500;
  }
}
