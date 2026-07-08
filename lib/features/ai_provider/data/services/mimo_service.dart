import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import '../../domain/entities/ai_provider.dart';
import '../../domain/repositories/ai_service.dart';

/// MiMo 提供商实现
/// 小米 MiMo API 兼容 OpenAI 格式
/// 官方文档：https://mimo.mi.com/docs/zh-CN/quick-start/first-api-call
class MiMoService implements AIService {
  final String apiKey;
  final String endpoint;
  late final Dio dio;

  /// 规范化端点 URL：去除末尾斜杠
  static String _normalizeEndpoint(String url) => url.trim().replaceAll(RegExp(r'/+$'), '');
  
  MiMoService({
    required this.apiKey,
    String? endpoint,
  }) : endpoint = _normalizeEndpoint((endpoint?.trim().isNotEmpty == true) ? endpoint! : 'https://api.xiaomimimo.com/v1') {
    dio = Dio(BaseOptions(
      baseUrl: this.endpoint,
      headers: {
        'Authorization': 'Bearer $apiKey',
        'api-key': apiKey,       // MiMo 官方文档推荐的认证头
        'Content-Type': 'application/json',
      },
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(minutes: 5),
    ));
    
    // 添加日志拦截器（调试用）
    dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
    ));
    
    // 添加重试拦截器（使用同一个 Dio 实例）
    dio.interceptors.add(RetryInterceptor(
      dio,
      retries: 2,
      retryDelays: const [
        Duration(seconds: 1),
        Duration(seconds: 3),
      ],
    ));
  }
  
  
  ProviderType get type => ProviderType.mimo;
  
  
  String get name => 'MiMo';
  
  
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
  
  
  Future<List<AIModel>> getAvailableModels() async {
    try {
      final response = await dio.get('/models');
      final models = (response.data['data'] as List)
          .map((model) => AIModel(
                id: model['id'] as String,
                name: model['id'] as String,
                description: model['description'] as String?,
                contextLength: model['context_length'] as int?,
              ))
          .toList();
      return models;
    } catch (e) {
      // 返回默认模型列表
      return defaultModels;
    }
  }
  
  
  Future<bool> validateApiKey() async {
    try {
      // MiMo 支持 /models 端点
      final resp = await dio.get('/models');
      if (resp.statusCode == 200) return true;
      throw AIServiceException(message: 'API 响应异常 (${resp.statusCode})', code: 'BAD_STATUS', statusCode: resp.statusCode);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw AIServiceException(message: 'API Key 无效，请检查 Key 是否正确', code: 'INVALID_KEY', statusCode: 401);
      }
      // /models 失败则尝试 /chat/completions
      try {
        final resp = await dio.post('/chat/completions', data: {
          'model': defaultModels.first.id,
          'messages': [{'role': 'user', 'content': 'hi'}],
          'max_completion_tokens': 1,
        });
        return resp.statusCode == 200;
      } on DioException catch (e2) {
        if (e2.response?.statusCode == 401) {
          throw AIServiceException(message: 'API Key 无效，请检查 Key 是否正确', code: 'INVALID_KEY', statusCode: 401);
        }
        throw AIServiceException(message: '连接失败: ${e2.message ?? "网络错误"}', code: 'CONN_ERROR');
      }
    }
  }
  
  /// 构建请求体（MiMo 使用 max_completion_tokens 而非 max_tokens）
  
  Map<String, dynamic> buildRequestBody({
    required List<ChatMessage> messages,
    required String model,
    GenerationParams? params,
  }) {
    final p = params ?? const GenerationParams();
    final body = {
      'model': model,
      'messages': messages.map((m) => m.toMap()).toList(),
      'temperature': p.temperature,
      'top_p': p.topP,
      'stream': p.stream,
      if (p.maxTokens != null) 'max_completion_tokens': p.maxTokens,
      if (p.frequencyPenalty != null) 'frequency_penalty': p.frequencyPenalty,
      if (p.presencePenalty != null) 'presence_penalty': p.presencePenalty,
      if (p.stopSequences != null) 'stop': p.stopSequences,
    };
    return body;
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
        return AIServiceException(message: '无法连接到 API 服务器，请检查：\n1. 网络连接是否正常\n2. API 端点是否正确\n3. 是否需要代理/VPN', code: 'CONNECTION_ERROR');
      case DioExceptionType.unknown:
        return AIServiceException(message: '网络错误: $msg\n请检查：\n1. API 端点是否正确 (如 https://api.xiaomimimo.com/v1)\n2. 网络连接是否正常\n3. 是否需要代理/VPN', code: 'NETWORK_ERROR');
      case DioExceptionType.badCertificate:
        return AIServiceException(message: 'SSL 证书验证失败，API 端点可能使用了无效证书', code: 'BAD_CERTIFICATE');
      case DioExceptionType.transformTimeout:
        return AIServiceException(message: '数据转换超时，请检查网络连接', code: 'TRANSFORM_TIMEOUT');
    }
  }
  
  /// 处理错误响应
  AIServiceException handleBadResponse(Response? response) {
    if (response == null) {
      return const AIServiceException(message: '服务器无响应', code: 'NO_RESPONSE');
    }
    final body = response.data?.toString() ?? '';
    final detail = body.isNotEmpty && body.length < 200 ? '\n响应:\n$body' : '';
    switch (response.statusCode) {
      case 401:
        return AIServiceException(message: 'API Key 无效，请检查 Key 是否正确$detail', code: 'INVALID_API_KEY', statusCode: 401);
      case 403:
        return AIServiceException(message: '访问被拒绝，请检查 API 权限$detail', code: 'FORBIDDEN', statusCode: 403);
      case 404:
        return AIServiceException(message: 'API 端点不存在，请检查 URL 是否正确$detail', code: 'NOT_FOUND', statusCode: 404);
      case 429:
        return AIServiceException(message: '请求过于频繁，请稍后重试$detail', code: 'RATE_LIMIT', statusCode: 429);
      case 500:
      case 502:
      case 503:
        return AIServiceException(message: '服务器错误 (${response.statusCode})，请稍后重试$detail', code: 'SERVER_ERROR', statusCode: response.statusCode);
      default:
        return AIServiceException(message: '请求失败 (${response.statusCode})$detail', code: 'REQUEST_FAILED', statusCode: response.statusCode);
    }
  }
  
  /// MiMo V2.5 系列默认模型
  /// 参考：https://mimo.xiaomi.com
  static const List<AIModel> defaultModels = [
    AIModel(
      id: 'mimo-v2.5-pro',
      name: 'MiMo-V2.5-Pro',
      description: '万亿参数，百万上下文，Agent 旗舰',
      contextLength: 1000000,
    ),
    AIModel(
      id: 'mimo-v2.5',
      name: 'MiMo-V2.5',
      description: '全模态感知，1M 上下文',
      contextLength: 1000000,
    ),
  ];
}

/// 重试拦截器
class RetryInterceptor extends Interceptor {
  final int retries;
  final List<Duration> retryDelays;
  final Dio _dio;
  
  RetryInterceptor(this._dio, {
    this.retries = 2,
    this.retryDelays = const [
      Duration(seconds: 1),
      Duration(seconds: 3),
    ],
  });
  
  
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final retryCount = err.requestOptions.extra['retryCount'] ?? 0;
    
    if (retryCount < retries && shouldRetry(err)) {
      final delay = retryDelays[retryCount];
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
  
  bool shouldRetry(DioException err) {
    return err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        (err.response?.statusCode == 429) ||
        (err.response?.statusCode ?? 0) >= 500;
  }
}
