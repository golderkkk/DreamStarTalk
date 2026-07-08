import 'dart:async';
import '../../domain/entities/conversation.dart';
import '../../domain/entities/message.dart';
import '../../domain/entities/context_manager.dart';
import '../../domain/entities/protagonist.dart';
import '../../../ai_provider/domain/entities/ai_provider.dart';
import '../../../ai_provider/domain/repositories/ai_service.dart';
import '../../../character/domain/entities/character.dart';
import '../../../world/domain/entities/world.dart';

/// 聊天服务
class ChatService {
  final AIService _aiService;

  ChatService({
    required AIService aiService,
  }) : _aiService = aiService;

  /// 发送消息并获取响应
  Future<Message> sendMessage({
    required Conversation conversation,
    required Character character,
    World? world,
    Protagonist? protagonist,
    required String content,
    MessageType type = MessageType.text,
    String? model,
  }) async {
    // conversation.messages 已包含最新的 user 消息，无需重复添加
    final context = ContextManager.buildContext(
      messages: conversation.messages,
      character: character,
      world: world,
      protagonist: protagonist,
      settings: conversation.settings,
    );

    final effectiveModel = model ?? 'mimo-v2.5-pro';

    // 发送到 AI
    final response = await _aiService.sendMessage(
      messages: context,
      model: effectiveModel,
      params: GenerationParams(
        temperature: conversation.settings.temperature,
        topP: conversation.settings.topP,
        maxTokens: conversation.settings.maxTokens,
        frequencyPenalty: conversation.settings.frequencyPenalty,
        presencePenalty: conversation.settings.presencePenalty,
        stream: false,
      ),
    );
    
    // 4. 创建助手消息
    final assistantMessage = createAssistantMessage(
      content: response.content,
      name: character.name,
      avatar: character.avatar,
    );
    
    return assistantMessage;
  }
  
  /// 发送消息并获取流式响应
  Stream<MessageChunk> sendMessageStream({
    required Conversation conversation,
    required Character character,
    World? world,
    Protagonist? protagonist,
    required String content,
    MessageType type = MessageType.text,
    String? model,
  }) async* {
    // conversation.messages 已包含最新的 user 消息，无需重复添加
    final context = ContextManager.buildContext(
      messages: conversation.messages,
      character: character,
      world: world,
      protagonist: protagonist,
      settings: conversation.settings,
    );

    final effectiveModel = model ?? 'mimo-v2.5-pro';

    // 发送到 AI（流式）
    await for (final chunk in _aiService.sendMessageStream(
      messages: context,
      model: effectiveModel,
      params: GenerationParams(
        temperature: conversation.settings.temperature,
        topP: conversation.settings.topP,
        maxTokens: conversation.settings.maxTokens,
        frequencyPenalty: conversation.settings.frequencyPenalty,
        presencePenalty: conversation.settings.presencePenalty,
        stream: true,
      ),
    )) {
      if (chunk.isDone) {
        yield MessageChunk(content: '', isDone: true);
      } else {
        yield MessageChunk(content: chunk.content, isDone: false);
      }
    }
  }
  
  /// 获取默认模型
  String _getDefaultModel() {
    // 这里应该从配置中获取默认模型
    return 'mimo-v2.5-pro';
  }
  
  /// 验证 NSFW 密码
  bool verifyNSFWPassword(Conversation conversation, String password) {
    if (!conversation.settings.nsfwPasswordProtected) {
      return true;
    }
    return conversation.settings.nsfwPassword == password;
  }
  
  /// 启用 NSFW 模式
  ConversationSettings enableNSFW(ConversationSettings settings, {String? password}) {
    return settings.copyWith(
      nsfwEnabled: true,
      nsfwPasswordProtected: password != null,
      nsfwPassword: password,
    );
  }
  
  /// 禁用 NSFW 模式
  ConversationSettings disableNSFW(ConversationSettings settings) {
    return settings.copyWith(
      nsfwEnabled: false,
    );
  }
}

/// 消息分块
class MessageChunk {
  final String content;
  final bool isDone;
  
  const MessageChunk({
    required this.content,
    required this.isDone,
  });
}
