import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/entities/message.dart';
import '../../domain/entities/protagonist.dart';
import '../../data/datasources/conversation_local_datasource.dart';
import '../../data/repositories/conversation_repository_impl.dart';
import '../../data/services/chat_service.dart';
import '../../../ai_provider/presentation/providers/ai_provider.dart';
import '../../../character/domain/entities/character.dart';
import '../../../character/presentation/providers/character_provider.dart';
import '../../../world/domain/entities/world.dart';
import '../../../world/presentation/providers/world_provider.dart';

/// 预选择：从角色/世界列表快捷进入时设置
final preselectedCharacterIdProvider = StateProvider<String?>((ref) => null);
final preselectedWorldIdProvider = StateProvider<String?>((ref) => null);

final conversationDataSourceProvider = Provider<ConversationLocalDataSource>((ref) {
  return ConversationLocalDataSource();
});

final conversationRepositoryProvider = Provider<ConversationRepositoryImpl>((ref) {
  final ds = ref.read(conversationDataSourceProvider);
  return ConversationRepositoryImpl(localDataSource: ds);
});

final chatServiceProvider = Provider<ChatService?>((ref) {
  final ai = ref.read(activeAIServiceProvider);
  if (ai == null) return null;
  return ChatService(aiService: ai);
});

class ConversationListState {
  final List<Conversation> conversations;
  final bool isLoading;
  final String? error;
  const ConversationListState({
    this.conversations = const [],
    this.isLoading = true,
    this.error,
  });
  ConversationListState copyWith({
    List<Conversation>? conversations,
    bool? isLoading,
    String? error,
  }) {
    return ConversationListState(
      conversations: conversations ?? this.conversations,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class ConversationListNotifier extends StateNotifier<ConversationListState> {
  final ConversationRepositoryImpl _repository;
  ConversationListNotifier(this._repository) : super(const ConversationListState());

  Future<void> loadConversations({String? characterId}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final list = await _repository.getConversations(characterId: characterId);
      if (mounted) state = state.copyWith(conversations: list, isLoading: false);
    } catch (e) {
      if (mounted) state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<Conversation> createConversation({
    required String characterId,
    String? characterName,
    String? characterAvatar,
    String? worldId,
    String? worldName,
    ConversationSettings? settings,
    List<CharacterReference>? additionalCharacters,
  }) async {
    try {
      final c = await _repository.createConversation(
        characterId: characterId,
        characterName: characterName,
        characterAvatar: characterAvatar,
        worldId: worldId,
        worldName: worldName,
        settings: settings,
        additionalCharacters: additionalCharacters,
      );
      await loadConversations();
      return c;
    } catch (e) {
      if (mounted) state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  /// 快速创建对话 — 跳过向导，使用默认设置
  Future<Conversation> quickCreateConversation({
    required Character character,
    String? worldId,
    String? worldName,
  }) async {
    final c = await createConversation(
      characterId: character.id,
      characterName: character.name,
      characterAvatar: character.avatar,
      worldId: worldId,
      worldName: worldName,
      settings: const ConversationSettings(),
    );
    // 自动附加主角（使用默认名）
    final repo = _repository;
    final protagonist = Protagonist(
      id: 'prot_${DateTime.now().millisecondsSinceEpoch}',
      name: '你',
    );
    await repo.updateConversation(c.copyWith(protagonist: protagonist));
    return c.copyWith(protagonist: protagonist);
  }

  Future<void> deleteConversation(String id) async {
    try {
      await _repository.deleteConversation(id);
      await loadConversations();
    } catch (e) {
      if (mounted) state = state.copyWith(error: e.toString());
    }
  }

  Future<void> searchConversations(String query) async {
    if (query.isEmpty) { await loadConversations(); return; }
    state = state.copyWith(isLoading: true, error: null);
    try {
      final list = await _repository.searchConversations(query);
      if (mounted) state = state.copyWith(conversations: list, isLoading: false);
    } catch (e) {
      if (mounted) state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final conversationListProvider = StateNotifierProvider<ConversationListNotifier, ConversationListState>((ref) {
  final repo = ref.read(conversationRepositoryProvider);
  return ConversationListNotifier(repo);
});

class ChatState {
  final Conversation? conversation;
  final bool isLoading;
  final bool isSending;
  final bool isStreaming;
  final String? error;
  final String streamingContent;
  final String? activeCharacterId;
  
  const ChatState({
    this.conversation,
    this.isLoading = false,
    this.isSending = false,
    this.isStreaming = false,
    this.error,
    this.streamingContent = '',
    this.activeCharacterId,
  });
  
  ChatState copyWith({
    Conversation? conversation,
    bool? isLoading,
    bool? isSending,
    bool? isStreaming,
    String? error,
    String? streamingContent,
    String? activeCharacterId,
  }) {
    return ChatState(
      conversation: conversation ?? this.conversation,
      isLoading: isLoading ?? this.isLoading,
      isSending: isSending ?? this.isSending,
      isStreaming: isStreaming ?? this.isStreaming,
      error: error,
      streamingContent: streamingContent ?? this.streamingContent,
      activeCharacterId: activeCharacterId ?? this.activeCharacterId,
    );
  }
}

class ChatNotifier extends StateNotifier<ChatState> {
  final Ref _ref;
  final String? conversationId;
  StreamSubscription? _streamSubscription;

  ChatNotifier(this._ref, this.conversationId) : super(const ChatState()) {
    if (conversationId != null) loadConversation(conversationId!);
  }

  Future<void> loadConversation(String id) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final repo = _ref.read(conversationRepositoryProvider);
      var c = await repo.getConversation(id);

      // 新对话时自动注入角色首条消息（参考 SillyTavern 的 greeting 机制）
      if (c != null && c.messages.isEmpty) {
        final charRepo = _ref.read(characterRepositoryProvider);
        final ch = await charRepo.getCharacter(c.characterId);
        if (ch != null && ch.firstMessage != null && ch.firstMessage!.isNotEmpty) {
          final greeting = createAssistantMessage(
            content: ch.firstMessage!,
            name: ch.name,
            avatar: ch.avatar,
            characterId: ch.id,
          );
          await repo.addMessage(c.id, greeting);
          c = c.copyWith(
            messages: [greeting],
            messageCount: 1,
            lastMessageAt: greeting.timestamp,
          );
        }
      }

      if (mounted) state = state.copyWith(conversation: c, isLoading: false);
    } catch (e) {
      if (mounted) state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> sendMessage(String content, {String? targetCharacterId}) async {
    await _ref.read(aiProviderListProvider.notifier).ensureLoaded();
    final svc = _ref.read(chatServiceProvider);
    if (svc == null) {
      state = state.copyWith(error: '请先在 设置 → AI 提供商 中配置并启用一个 AI 服务');
      return;
    }
    if (state.conversation == null) {
      state = state.copyWith(error: '未选择对话');
      return;
    }

    state = state.copyWith(isSending: true, error: null);
    try {
      final userMsg = createUserMessage(
        content: content,
        targetCharacterId: targetCharacterId,
      );

      final repo = _ref.read(conversationRepositoryProvider);
      await repo.addMessage(state.conversation!.id, userMsg);

      var conv = state.conversation!.copyWith(
        messages: [...state.conversation!.messages, userMsg],
        messageCount: state.conversation!.messages.length + 1,
        lastMessageAt: userMsg.timestamp,
      );
      state = state.copyWith(conversation: conv, isStreaming: true, streamingContent: '');

      // 多角色模式：确定需要回复的角色队列
      final isMultiMode = state.conversation!.isMultiCharacterMode;
      final hasTarget = targetCharacterId != null && targetCharacterId.isNotEmpty;
      List<String> pendingCharacterIds = [];
      if (isMultiMode && !hasTarget) {
        // 没有 @mention 指定角色，所有附加角色都需要回复
        pendingCharacterIds = state.conversation!.additionalCharacters
            .map((c) => c.id)
            .toList();
      }

      // 先让主角色回复
      await _sendCharacterResponse(svc, content, targetCharacterId);

      // 多角色模式：让附加角色依次回复
      for (final charId in pendingCharacterIds) {
        if (!mounted) break;
        // 等待一小段时间再发送下一个角色的回复
        await Future.delayed(const Duration(milliseconds: 500));
        try {
          await _sendCharacterResponse(svc, content, charId);
        } catch (e) {
          // 单个角色失败不中断整个流程，继续下一个角色
          if (mounted) {
            final charName = state.conversation?.getCharacterById(charId)?.name ?? '角色';
            state = state.copyWith(error: '$charName 回复失败，已跳过');
          }
        }
      }
    } catch (e) {
      state = state.copyWith(isSending: false, isStreaming: false, error: e.toString());
    }
  }

  /// 发送单个角色的回复
  Future<void> _sendCharacterResponse(ChatService svc, String content, String? characterId) async {
    final conv = state.conversation;
    if (conv == null) return;

    // 获取角色信息
    Character charData;
    if (characterId != null) {
      final charRepo = _ref.read(characterRepositoryProvider);
      final ch = await charRepo.getCharacter(characterId);
      charData = ch ?? Character(id: characterId, name: conv.getCharacterById(characterId)?.name ?? 'AI');
    } else {
      final charRepo = _ref.read(characterRepositoryProvider);
      final ch = await charRepo.getCharacter(conv.characterId);
      charData = ch ?? Character(id: conv.characterId, name: conv.characterName ?? 'AI');
    }

    // 获取世界观信息
    World? worldData;
    if (conv.worldId != null) {
      final wRepo = _ref.read(worldRepositoryProvider);
      worldData = await wRepo.getWorld(conv.worldId!);
    }

    final protagonist = conv.protagonist;
    final providerCfg = _ref.read(activeProviderConfigProvider);

    if (!mounted) return;
    state = state.copyWith(isStreaming: true, streamingContent: '', activeCharacterId: characterId);

    final stream = svc.sendMessageStream(
      conversation: conv,
      character: charData,
      world: worldData,
      protagonist: protagonist,
      content: content,
      model: providerCfg?.defaultModel,
    );

    String full = '';
    final completer = Completer<void>();

    // 取消旧的订阅，避免泄漏
    _streamSubscription?.cancel();
    _streamSubscription = stream.listen(
      (chunk) {
        if (chunk.isDone) {
          _onStreamDone(full, characterId);
          completer.complete();
        } else {
          full += chunk.content;
          if (mounted) state = state.copyWith(streamingContent: full);
        }
      },
      onError: (error) {
        if (mounted) {
          state = state.copyWith(
            isSending: false,
            isStreaming: false,
            error: error.toString(),
          );
        }
        completer.completeError(error);
      },
    );

    await completer.future;
  }

  Future<void> _onStreamDone(String content, String? characterId) async {
    try {
      final conv = state.conversation;
      if (conv == null) return;

      // 获取角色名称
      String? characterName;
      if (characterId != null) {
        final charRef = conv.getCharacterById(characterId);
        characterName = charRef?.name;
      }

      final assistantMsg = createAssistantMessage(
        content: content,
        name: characterName ?? conv.characterName,
        characterId: characterId,
      );


      final repo = _ref.read(conversationRepositoryProvider);
      await repo.addMessage(conv.id, assistantMsg);

      final updatedConv = conv.copyWith(
        messages: [...conv.messages, assistantMsg],
        messageCount: conv.messages.length + 1,
        lastMessageAt: assistantMsg.timestamp,
      );


      state = state.copyWith(
        conversation: updatedConv,
        isSending: false,
        isStreaming: false,
        streamingContent: '',
      );
    } catch (e) {
      state = state.copyWith(isSending: false, isStreaming: false, error: e.toString());
    }
  }

  Future<void> updateSettings(ConversationSettings settings) async {
    if (state.conversation == null) return;
    try {
      final repo = _ref.read(conversationRepositoryProvider);
      await repo.updateSettings(state.conversation!.id, settings);
      state = state.copyWith(conversation: state.conversation!.copyWith(settings: settings));
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> clearConversation() async {
    if (state.conversation == null) return;
    try {
      final repo = _ref.read(conversationRepositoryProvider);
      await repo.clearMessages(state.conversation!.id);
      state = state.copyWith(
        conversation: state.conversation!.copyWith(
          messages: [],
          messageCount: 0,
          lastMessageAt: null,
        ),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> deleteMessage(String messageId) async {
    if (state.conversation == null) return;
    try {
      final repo = _ref.read(conversationRepositoryProvider);
      await repo.deleteMessage(state.conversation!.id, messageId);
      final msgs = state.conversation!.messages.where((m) => m.id != messageId).toList();
      state = state.copyWith(
        conversation: state.conversation!.copyWith(
          messages: msgs,
          messageCount: msgs.length,
        ),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// 重生成最后一条 AI 回复
  Future<void> regenerateLastMessage() async {
    if (state.isStreaming || state.conversation == null) return;
    final msgs = state.conversation!.messages;
    if (msgs.isEmpty) return;

    // 找到最后一条 AI 消息和对应的用户消息
    int lastAiIndex = -1;
    int lastUserIndex = -1;
    for (var i = msgs.length - 1; i >= 0; i--) {
      if (msgs[i].isAssistant && lastAiIndex == -1) lastAiIndex = i;
      if (msgs[i].isUser && lastUserIndex == -1) lastUserIndex = i;
      if (lastAiIndex != -1 && lastUserIndex != -1) break;
    }
    if (lastAiIndex == -1 || lastUserIndex == -1) return;

    final lastUserContent = msgs[lastUserIndex].content;
    final repo = _ref.read(conversationRepositoryProvider);

    // 删除最后一条 AI 消息
    await repo.deleteMessage(state.conversation!.id, msgs[lastAiIndex].id);

    // 更新本地状态
    final remainingMsgs = [...msgs];
    remainingMsgs.removeAt(lastAiIndex);
    state = state.copyWith(
      conversation: state.conversation!.copyWith(messages: remainingMsgs, messageCount: remainingMsgs.length),
    );

    // 重新发送用户消息（不带用户消息本身，避免重复）
    await sendMessage(lastUserContent);
  }

  Future<void> addCharacter(CharacterReference character) async {
    if (state.conversation == null) return;
    try {
      final updatedChars = [...state.conversation!.additionalCharacters, character];
      final updatedConv = state.conversation!.copyWith(additionalCharacters: updatedChars);
      
      final repo = _ref.read(conversationRepositoryProvider);
      await repo.updateConversation(updatedConv);
      
      state = state.copyWith(conversation: updatedConv);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> removeCharacter(String characterId) async {
    if (state.conversation == null) return;
    try {
      final updatedChars = state.conversation!.additionalCharacters
          .where((c) => c.id != characterId)
          .toList();
      final updatedConv = state.conversation!.copyWith(additionalCharacters: updatedChars);
      
      final repo = _ref.read(conversationRepositoryProvider);
      await repo.updateConversation(updatedConv);
      
      state = state.copyWith(conversation: updatedConv);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  void setActiveCharacter(String characterId) {
    state = state.copyWith(activeCharacterId: characterId);
  }

  void stopStreaming() {
    _streamSubscription?.cancel();
    _streamSubscription = null;
    
    if (state.streamingContent.isNotEmpty) {
      _onStreamDone(state.streamingContent, state.activeCharacterId);
    } else {
      state = state.copyWith(isSending: false, isStreaming: false);
    }
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    super.dispose();
  }
}

final chatProvider = StateNotifierProvider.family<ChatNotifier, ChatState, String?>(
  (ref, id) => ChatNotifier(ref, id),
);

final conversationProvider = FutureProvider.family<Conversation?, String>((ref, id) async {
  final repo = ref.read(conversationRepositoryProvider);
  return repo.getConversation(id);
});
