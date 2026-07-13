import '../../domain/entities/conversation.dart';
import '../../domain/entities/message.dart';
import '../../domain/repositories/conversation_repository.dart';
import '../datasources/conversation_local_datasource.dart';

/// 对话仓库实现
class ConversationRepositoryImpl implements ConversationRepository {
  final ConversationLocalDataSource _localDataSource;
  
  ConversationRepositoryImpl({
    required ConversationLocalDataSource localDataSource,
  }) : _localDataSource = localDataSource;
  
  @override
  Future<List<Conversation>> getConversations({
    String? characterId,
    String? worldId,
  }) async {
    var conversations = await _localDataSource.getAll();
    
    // 按角色筛选
    if (characterId != null) {
      conversations = conversations
          .where((c) => c.characterId == characterId)
          .toList();
    }
    
    // 按世界筛选
    if (worldId != null) {
      conversations = conversations
          .where((c) => c.worldId == worldId)
          .toList();
    }
    
    // 按最后消息时间排序
    conversations.sort((a, b) {
      final aTime = a.lastMessageAt ?? a.createdAt ?? DateTime.now();
      final bTime = b.lastMessageAt ?? b.createdAt ?? DateTime.now();
      return bTime.compareTo(aTime);
    });
    
    return conversations;
  }
  
  @override
  Future<Conversation?> getConversation(String id) async {
    return await _localDataSource.getById(id);
  }
  
  @override
  Future<Conversation> createConversation({
    required String characterId,
    String? characterName,
    String? characterAvatar,
    String? worldId,
    String? worldName,
    ConversationSettings? settings,
    List<CharacterReference>? additionalCharacters,
  }) async {
    final now = DateTime.now();
    final id = 'conv_${now.millisecondsSinceEpoch}_${now.microsecondsSinceEpoch % 10000}';

    final conversation = Conversation(
      id: id,
      characterId: characterId,
      characterName: characterName,
      characterAvatar: characterAvatar,
      worldId: worldId,
      worldName: worldName,
      settings: settings ?? const ConversationSettings(),
      additionalCharacters: additionalCharacters ?? [],
      createdAt: now,
      updatedAt: now,
    );

    await _localDataSource.save(conversation);
    return conversation;
  }
  
  @override
  Future<Conversation> updateConversation(Conversation conversation) async {
    final updated = conversation.copyWith(
      updatedAt: DateTime.now(),
    );
    await _localDataSource.save(updated);
    return updated;
  }
  
  @override
  Future<void> deleteConversation(String id) async {
    await _localDataSource.delete(id);
  }
  
  @override
  Future<Message> addMessage(String conversationId, Message message) async {
    final conversation = await _localDataSource.getById(conversationId);
    if (conversation == null) {
      throw Exception('对话不存在');
    }


    final updatedMessages = [...conversation.messages, message];
    final updated = conversation.copyWith(
      messages: updatedMessages,
      messageCount: updatedMessages.length,
      lastMessageAt: message.timestamp,
      updatedAt: DateTime.now(),
    );


    // 自动生成标题
    if (updated.title == null && updatedMessages.length <= 2) {
      final title = _generateTitle(updatedMessages);
      final updatedWithTitle = updated.copyWith(title: title);
      await _localDataSource.save(updatedWithTitle);
      return message;
    }

    await _localDataSource.save(updated);
    return message;
  }
  
  @override
  Future<Message> updateMessage(String conversationId, Message message) async {
    final conversation = await _localDataSource.getById(conversationId);
    if (conversation == null) {
      throw Exception('对话不存在');
    }
    
    final updatedMessages = conversation.messages.map((m) {
      if (m.id == message.id) {
        return message;
      }
      return m;
    }).toList();
    
    final updated = conversation.copyWith(
      messages: updatedMessages,
      updatedAt: DateTime.now(),
    );
    
    await _localDataSource.save(updated);
    return message;
  }
  
  @override
  Future<void> deleteMessage(String conversationId, String messageId) async {
    final conversation = await _localDataSource.getById(conversationId);
    if (conversation == null) {
      throw Exception('对话不存在');
    }
    
    final updatedMessages = conversation.messages
        .where((m) => m.id != messageId)
        .toList();
    
    final updated = conversation.copyWith(
      messages: updatedMessages,
      messageCount: updatedMessages.length,
      updatedAt: DateTime.now(),
    );
    
    await _localDataSource.save(updated);
  }
  
  @override
  Future<void> clearMessages(String conversationId) async {
    final conversation = await _localDataSource.getById(conversationId);
    if (conversation == null) {
      throw Exception('对话不存在');
    }
    
    final updated = conversation.copyWith(
      messages: [],
      messageCount: 0,
      lastMessageAt: null,
      updatedAt: DateTime.now(),
    );
    
    await _localDataSource.save(updated);
  }
  
  @override
  Future<void> updateSettings(String conversationId, ConversationSettings settings) async {
    final conversation = await _localDataSource.getById(conversationId);
    if (conversation == null) {
      throw Exception('对话不存在');
    }
    
    final updated = conversation.copyWith(
      settings: settings,
      updatedAt: DateTime.now(),
    );
    
    await _localDataSource.save(updated);
  }
  
  @override
  Future<List<Conversation>> searchConversations(String query) async {
    final all = await _localDataSource.getAll();
    final lowerQuery = query.toLowerCase();
    
    return all.where((c) {
      // 搜索标题
      if (c.title != null && c.title!.toLowerCase().contains(lowerQuery)) {
        return true;
      }
      
      // 搜索角色名称
      if (c.characterName != null && 
          c.characterName!.toLowerCase().contains(lowerQuery)) {
        return true;
      }
      
      // 搜索消息内容
      return c.messages.any((m) => 
          m.content.toLowerCase().contains(lowerQuery));
    }).toList();
  }
  
  @override
  Future<List<Conversation>> getRecentConversations({int limit = 20}) async {
    final all = await _localDataSource.getAll();
    
    // 按最后消息时间排序
    all.sort((a, b) {
      final aTime = a.lastMessageAt ?? a.createdAt ?? DateTime.now();
      final bTime = b.lastMessageAt ?? b.createdAt ?? DateTime.now();
      return bTime.compareTo(aTime);
    });
    
    return all.take(limit).toList();
  }
  
  @override
  Stream<Conversation?> watchConversation(String id) {
    return _localDataSource.watchById(id).map((event) {
      if (event.value == null) return null;
      return Conversation.fromJson(Map<String, dynamic>.from(event.value as Map));
    });
  }
  
  @override
  Stream<List<Conversation>> watchConversations({String? characterId}) async* {
    yield await getConversations(characterId: characterId);
    await for (final _ in _localDataSource.watch()) {
      yield await getConversations(characterId: characterId);
    }
  }
  
  /// 生成对话标题
  String _generateTitle(List<Message> messages) {
    if (messages.isEmpty) return '新对话';
    
    // 找到第一条用户消息
    final firstUserMessage = messages.firstWhere(
      (m) => m.isUser,
      orElse: () => messages.first,
    );
    
    // 截取前 20 个字符作为标题
    final content = firstUserMessage.content;
    if (content.length <= 20) {
      return content;
    }
    return '${content.substring(0, 20)}...';
  }
}
