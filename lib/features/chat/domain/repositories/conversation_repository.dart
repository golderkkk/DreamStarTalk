import '../entities/conversation.dart';
import '../entities/message.dart';

/// 对话仓库接口
abstract class ConversationRepository {
  /// 获取所有对话
  Future<List<Conversation>> getConversations({
    String? characterId,
    String? worldId,
  });
  
  /// 获取单个对话
  Future<Conversation?> getConversation(String id);
  
  /// 创建对话
  Future<Conversation> createConversation({
    required String characterId,
    String? characterName,
    String? characterAvatar,
    String? worldId,
    String? worldName,
    ConversationSettings? settings,
  });
  
  /// 更新对话
  Future<Conversation> updateConversation(Conversation conversation);
  
  /// 删除对话
  Future<void> deleteConversation(String id);
  
  /// 添加消息
  Future<Message> addMessage(String conversationId, Message message);
  
  /// 更新消息
  Future<Message> updateMessage(String conversationId, Message message);
  
  /// 删除消息
  Future<void> deleteMessage(String conversationId, String messageId);
  
  /// 清空对话消息
  Future<void> clearMessages(String conversationId);
  
  /// 更新对话设置
  Future<void> updateSettings(String conversationId, ConversationSettings settings);
  
  /// 搜索对话
  Future<List<Conversation>> searchConversations(String query);
  
  /// 获取最近的对话
  Future<List<Conversation>> getRecentConversations({int limit = 20});
  
  /// 监听对话变化
  Stream<Conversation?> watchConversation(String id);
  
  /// 监听对话列表变化
  Stream<List<Conversation>> watchConversations({String? characterId});
}
