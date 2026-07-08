import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dream_startalk/core/theme/aurora_theme.dart';
import 'package:dream_startalk/shared/widgets/app_loading.dart';
import '../../domain/entities/message.dart';
import '../../domain/entities/conversation.dart';
import '../providers/chat_provider.dart';
import '../providers/tts_provider.dart';
import '../../../world/presentation/providers/world_provider.dart';
import '../../../world/domain/entities/world.dart';
import '../widgets/chat_input.dart';
import '../widgets/dialogue_style_panel.dart';

class ChatPage extends ConsumerStatefulWidget {
  final String? conversationId;
  const ChatPage({super.key, this.conversationId});
  @override ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  final _scroll = ScrollController();
  final _searchCtrl = TextEditingController();
  final _inputFocusNode = FocusNode();
  bool _searching = false;
  bool _showTimestamps = false;
  bool _showAuthorsNote = false;
  final _authorsNote = TextEditingController();
  String? _activeScene;
  String? _activeTime;
  String? _activeWeather;
  String? _activeAtmosphere;
  bool _showSceneBanner = false;
  String? _mentionTargetId;
  String _query = '';
  int _matchIndex = 0;
  List<int> _matchIndexes = [];
  String? _ttsPlayingMessageId;
  int _prevMessageCount = 0;
  bool _userScrolledUp = false;
  // 防重复滚动：仅在内容长度变化时才触发滚动
  int _lastScrolledContentLen = 0;

  @override void initState() { super.initState(); _scroll.addListener(_onScroll); }
  @override void dispose() { _scroll.removeListener(_onScroll); _scroll.dispose(); _searchCtrl.dispose(); _authorsNote.dispose(); _inputFocusNode.dispose(); super.dispose(); }

  void _onScroll() {
    if (!_scroll.hasClients) return;
    _userScrolledUp = (_scroll.position.maxScrollExtent - _scroll.position.pixels) > 200;
  }

  void _scrollDown({bool force = false}) {
    if (!_scroll.hasClients) return;
    if (!force && _userScrolledUp) return;
    _scroll.animateTo(_scroll.position.maxScrollExtent, duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
  }

  void _startSearch() => setState(() { _searching = true; _query = ''; _matchIndex = 0; _matchIndexes = []; _searchCtrl.clear(); });

  void _doSearch(String q) {
    setState(() {
      _query = q; _matchIndexes = []; _matchIndex = 0;
      if (q.isEmpty) return;
      final msgs = ref.read(chatProvider(widget.conversationId!)).conversation?.messages ?? [];
      for (var i = 0; i < msgs.length; i++) {
        if (msgs[i].content.toLowerCase().contains(q.toLowerCase())) _matchIndexes.add(i);
      }
    });
  }

  void _nextMatch() { if (_matchIndexes.isEmpty) return; setState(() => _matchIndex = (_matchIndex + 1) % _matchIndexes.length); _scrollToIndex(_matchIndexes[_matchIndex]); }
  void _prevMatch() { if (_matchIndexes.isEmpty) return; setState(() => _matchIndex = (_matchIndex - 1 + _matchIndexes.length) % _matchIndexes.length); _scrollToIndex(_matchIndexes[_matchIndex]); }

  void _scrollToIndex(int index) {
    if (!_scroll.hasClients) return;
    final total = ref.read(chatProvider(widget.conversationId!)).conversation?.messages.length ?? 1;
    final max = _scroll.position.maxScrollExtent;
    _scroll.animateTo((max / total * index).clamp(0, max), duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
  }

  @override Widget build(BuildContext context) {
    if (widget.conversationId == null) return _buildEmpty();
    final s = ref.watch(chatProvider(widget.conversationId!));
    final currentCount = s.conversation?.messages.length ?? 0;
    if (currentCount > _prevMessageCount) { _prevMessageCount = currentCount; WidgetsBinding.instance.addPostFrameCallback((_) => _scrollDown()); }
    // 仅在流式内容增长时触发滚动，避免 build 中反复注册回调
    if (s.isStreaming && !_userScrolledUp) {
      final streamLen = s.streamingContent.length;
      if (streamLen > _lastScrolledContentLen) {
        _lastScrolledContentLen = streamLen;
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollDown());
      }
    } else {
      _lastScrolledContentLen = 0;
    }
    final quickReplies = _generateQuickReplies(s.conversation?.messages ?? []);

    // 使用标准 Scaffold + AppBar 结构
    return Scaffold(
      backgroundColor: AuroraColors.bg0,
      resizeToAvoidBottomInset: true,
      appBar: _buildAppBar(s.conversation),
      body: _searching
          ? _buildSearchOverlay(s)
          : s.isLoading
              ? const AppLoadingScreen(message: '加载中...')
              : s.error != null
                  ? _buildError(s.error!)
                  : s.conversation == null
                      ? _buildEmpty()
                      : _buildChat(s, quickReplies),
    );
  }

  // ── AppBar ──
  PreferredSizeWidget _buildAppBar(Conversation? c) {
    if (c == null) return AppBar(backgroundColor: AuroraColors.bg0, title: const Text('对话'));
    final isMulti = c.isMultiCharacterMode || c.allCharacters.length > 1;
    return AppBar(
      backgroundColor: AuroraColors.bg0,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(margin: const EdgeInsets.all(8), decoration: BoxDecoration(color: AuroraColors.bg2, borderRadius: BorderRadius.circular(AuroraRadius.sm)), child: const Icon(Icons.arrow_back_ios_new, size: 16, color: AuroraColors.text2)),
      ),
      title: Row(children: [
        isMulti ? _buildMultiAvatarAppBar(c) : _buildSingleAvatarAppBar(c),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(isMulti ? '${c.characterName} 等${c.allCharacters.length}人' : (c.characterName ?? 'AI'), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AuroraColors.text1), maxLines: 1, overflow: TextOverflow.ellipsis),
          if (c.hasWorld) Text(c.worldName ?? '', style: const TextStyle(fontSize: 11, color: AuroraColors.text3), maxLines: 1, overflow: TextOverflow.ellipsis),
          if (isMulti) Text(c.allCharacters.map((ch) => ch.name).join('、'), style: const TextStyle(fontSize: 10, color: AuroraColors.text3), maxLines: 1, overflow: TextOverflow.ellipsis),
        ])),
      ]),
      actions: [
        _iconBtn(Icons.auto_fix_high, () => _showDialogueStyleSettings()),
        _iconBtn(Icons.schedule, () => setState(() => _showTimestamps = !_showTimestamps), color: _showTimestamps ? AuroraColors.primary : AuroraColors.text2),
        _iconBtn(Icons.location_on_outlined, () => _showScenePicker(c), color: _activeScene != null ? AuroraColors.cyan : AuroraColors.text2),
        _iconBtn(Icons.search, _startSearch),
      ],
    );
  }

  Widget _buildSingleAvatarAppBar(Conversation c) {
    return GestureDetector(
      onLongPress: () => _showDialogueStyleSettings(),
      child: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(gradient: AuroraColors.gradientPrimary, borderRadius: BorderRadius.circular(AuroraRadius.md), boxShadow: [BoxShadow(color: AuroraColors.primary.withOpacity(0.25), blurRadius: 8, offset: const Offset(0, 2))]),
        child: Center(child: Text(c.characterName?.isNotEmpty == true ? c.characterName![0].toUpperCase() : '?', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15))),
      ),
    );
  }

  Widget _buildMultiAvatarAppBar(Conversation c) {
    return SizedBox(width: 40, child: Stack(children: List.generate(c.allCharacters.take(2).length, (i) => Positioned(
      left: i * 16.0,
      child: GestureDetector(
        onTap: () {
          final char = c.allCharacters[i];
          setState(() => _mentionTargetId = _mentionTargetId == char.id ? null : char.id);
          if (_mentionTargetId != null) {
            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('已选择 @${char.name}'), duration: const Duration(seconds: 2)));
          }
        },
        child: Container(width: 30, height: 30, decoration: BoxDecoration(
          gradient: LinearGradient(colors: _mentionTargetId == c.allCharacters[i].id ? [AuroraColors.cyan, AuroraColors.primary] : [AuroraColors.primaryActive, AuroraColors.primary]),
          borderRadius: BorderRadius.circular(AuroraRadius.sm),
          border: Border.all(color: _mentionTargetId == c.allCharacters[i].id ? AuroraColors.cyan : AuroraColors.bg0, width: 1.5),
        ), child: Center(child: Text(c.allCharacters[i].name[0].toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12)))),
      ),
    ))));
  }

  Widget _msgActionBtn(IconData icon, String tooltip, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(AuroraRadius.sm)),
        child: Icon(icon, size: 14, color: color),
      ),
    );
  }

  Widget _iconBtn(IconData icon, VoidCallback onTap, {Color? color}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(width: 32, height: 32, margin: const EdgeInsets.symmetric(horizontal: 2), decoration: BoxDecoration(color: AuroraColors.bg2, borderRadius: BorderRadius.circular(AuroraRadius.sm)), child: Icon(icon, size: 18, color: color ?? AuroraColors.text2)),
    );
  }

  // ── 聊天主体 ──
  Widget _buildChat(ChatState state, List<String> quickReplies) {
    final msgs = state.conversation!.messages;
    final showSending = state.isSending && !state.isStreaming;
    final extraItems = (state.isStreaming ? 1 : 0) + (showSending ? 1 : 0);

    return Column(children: [
      // 场景横幅
      if (_activeScene != null && _showSceneBanner) _buildSceneBanner(),
      Expanded(child: GestureDetector(
        onTap: () {
          // 仅在点击消息列表空白处时收起键盘
          if (_inputFocusNode.hasFocus) return;
          FocusScope.of(context).unfocus();
        },
        child: ListView.builder(
          controller: _scroll,
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.manual,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          itemCount: msgs.length + extraItems,
          itemBuilder: (_, i) {
            if (showSending && i == msgs.length) return _buildSendingIndicator();
            final avatar = state.conversation?.characterAvatar;
            if (state.isStreaming && i == msgs.length + (showSending ? 1 : 0)) {
              final streamCharName = state.activeCharacterId != null
                  ? state.conversation?.getCharacterById(state.activeCharacterId!)?.name
                  : state.conversation?.characterName;
              return _buildBubble(Message(id: 's', content: state.streamingContent, role: MessageRole.assistant, type: MessageType.text, timestamp: DateTime.now(), name: streamCharName), streaming: true, characterAvatar: avatar);
            }
            return _buildBubble(msgs[i], prev: i > 0 ? msgs[i - 1] : null, highlight: _matchIndexes.contains(i), characterAvatar: avatar);
          },
        ),
      )),
      if (state.isStreaming) _buildStreamingIndicator(state),
      if (!state.isStreaming && !state.isSending && quickReplies.isNotEmpty) _buildQuickReplies(quickReplies),
      // Author's Note — 可折叠的临时指令输入区
      if (_showAuthorsNote) _buildAuthorsNote(state),
      // @mention 标签
      if (_mentionTargetId != null) _buildMentionTag(state.conversation!),
      ChatInput(
        key: const ValueKey('chatInput'),
        focusNode: _inputFocusNode,
      onSend: (c, {String? targetCharacterId}) {
        final effectiveTarget = _mentionTargetId ?? targetCharacterId;
        ref.read(chatProvider(widget.conversationId!).notifier).sendMessage(c, targetCharacterId: effectiveTarget);
        if (_mentionTargetId != null) setState(() => _mentionTargetId = null);
        // 发送后保持键盘打开
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) _inputFocusNode.requestFocus();
        });
      },
        onStop: state.isStreaming ? () => ref.read(chatProvider(widget.conversationId!).notifier).stopStreaming() : null,
        isStreaming: state.isStreaming,
        hintText: _activeScene != null
            ? '${_activeScene} · ${_activeTime ?? ""}  | 对 ${state.conversation?.characterName ?? "AI"} 说...'
            : _mentionTargetId != null
                ? '对 ${state.conversation?.allCharacters.firstWhere((ch) => ch.id == _mentionTargetId, orElse: () => state.conversation!.allCharacters.first).name} 说...'
                : '对 ${state.conversation?.characterName ?? "AI"} 说...',
        availableCharacters: state.conversation?.allCharacters,
      ),
    ]);
  }

  // ── 消息气泡 — Aurora 风格 ──
  Widget _buildBubble(Message m, {Message? prev, bool streaming = false, bool highlight = false, String? characterAvatar}) {
    if (m.isSystem) {
      return Center(child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(color: AuroraColors.bg2, borderRadius: BorderRadius.circular(AuroraRadius.md), border: Border.all(color: AuroraColors.border, width: 0.5)),
        child: Text(m.content, style: const TextStyle(fontSize: 12, color: AuroraColors.text3)),
      ));
    }
    if (m.isError) {
      return Center(child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(color: AuroraColors.rose.withOpacity(0.08), borderRadius: BorderRadius.circular(AuroraRadius.md), border: Border.all(color: AuroraColors.rose.withOpacity(0.2), width: 0.5)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.error_outline, size: 16, color: AuroraColors.rose),
          const SizedBox(width: 8),
          Flexible(child: Text(m.content, style: const TextStyle(fontSize: 13, color: AuroraColors.rose))),
        ]),
      ));
    }

    final isUser = m.isUser;
    final showDate = prev != null ? m.shouldShowDateDivider(prev) : true;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Column(children: [
        // 日期分隔
        if (showDate) Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(children: [
            const Expanded(child: Divider(color: AuroraColors.border, height: 1)),
            Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Text(m.dateString, style: const TextStyle(fontSize: 11, color: AuroraColors.text4, fontWeight: FontWeight.w500))),
            const Expanded(child: Divider(color: AuroraColors.border, height: 1)),
          ]),
        ),
        // 多角色名称 — 移除顶部独立标签，合并到气泡内部
        // 气泡行
        Row(
          mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!isUser) ...[_buildMsgAvatar(characterAvatar, m.name), const SizedBox(width: 8)],
            Flexible(child: Container(
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.72),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                gradient: isUser ? AuroraColors.gradientPrimary : null,
                color: isUser ? null : AuroraColors.bg2,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(isUser ? AuroraRadius.lg : 4),
                  topRight: Radius.circular(isUser ? 4 : AuroraRadius.lg),
                  bottomLeft: const Radius.circular(AuroraRadius.lg),
                  bottomRight: const Radius.circular(AuroraRadius.lg),
                ),
                border: isUser ? null : Border.all(color: highlight ? AuroraColors.borderPrimary : AuroraColors.border, width: 1),
                boxShadow: isUser ? [BoxShadow(color: AuroraColors.primary.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 2))] : null,
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                // 角色名 — 气泡内部左侧
                if (!isUser && m.name != null && m.name!.isNotEmpty)
                  Row(children: [
                    Container(width: 6, height: 6, decoration: BoxDecoration(color: AuroraColors.cyan, borderRadius: BorderRadius.circular(3))),
                    const SizedBox(width: 6),
                    Text(m.name!, style: const TextStyle(fontSize: 11, color: AuroraColors.cyan, fontWeight: FontWeight.w600)),
                  ]),
                if (!isUser && m.name != null && m.name!.isNotEmpty) const SizedBox(height: 6),
                streaming && m.content.isEmpty
                    ? _buildTypingIndicator()
                    : _RichMessageText(content: m.content, textColor: isUser ? Colors.white : AuroraColors.text1, isUser: isUser),
                if (!isUser && !streaming && m.content.isNotEmpty)
                  Padding(padding: const EdgeInsets.only(top: 6), child: Row(mainAxisSize: MainAxisSize.min, children: [
                    _msgActionBtn(Icons.volume_up_outlined, '朗读', _ttsPlayingMessageId == m.id ? AuroraColors.rose : AuroraColors.text3, () => _toggleTTS(m)),
                    const SizedBox(width: 2),
                    _msgActionBtn(Icons.refresh, '重生成', AuroraColors.text3, () {
                      HapticFeedback.lightImpact();
                      ref.read(chatProvider(widget.conversationId!).notifier).regenerateLastMessage();
                    }),
                    const SizedBox(width: 2),
                    _msgActionBtn(Icons.copy, '复制', AuroraColors.text3, () {
                      Clipboard.setData(ClipboardData(text: m.content));
                      ScaffoldMessenger.of(context).clearSnackBars();
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('已复制'), duration: Duration(seconds: 1)));
                    }),
                  ])),
                if (isUser && !streaming && m.content.isNotEmpty)
                  Padding(padding: const EdgeInsets.only(top: 4), child: GestureDetector(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: m.content));
                      ScaffoldMessenger.of(context).clearSnackBars();
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('已复制'), duration: Duration(seconds: 1)));
                    },
                    child: Icon(Icons.copy, size: 13, color: Colors.white.withOpacity(0.4)),
                  )),
              ]),
            )),
          ],
        ),
        // 时间戳
        if (_showTimestamps && !streaming)
          Padding(padding: EdgeInsets.only(top: 4, left: isUser ? 0 : 40, right: isUser ? 4 : 0), child: Text(m.timeString, style: const TextStyle(fontSize: 10, color: AuroraColors.text4), textAlign: isUser ? TextAlign.right : TextAlign.left)),
      ]),
    );
  }

  Widget _buildMsgAvatar(String? avatarPath, String? name) {
    return Container(
      width: 32, height: 32,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(AuroraRadius.sm), boxShadow: [BoxShadow(color: AuroraColors.primary.withOpacity(0.15), blurRadius: 4, offset: const Offset(0, 1))]),
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(gradient: AuroraColors.gradientPrimary),
        child: Center(child: Text(name?.isNotEmpty == true ? name![0].toUpperCase() : 'AI', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12))),
      ),
    );
  }

  // ── 发送指示器 ──
  Widget _buildSendingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(left: 40, top: 8, bottom: 8),
      child: Row(children: [
        Container(width: 32, height: 32, decoration: BoxDecoration(gradient: AuroraColors.gradientPrimary, borderRadius: BorderRadius.circular(AuroraRadius.sm)), child: const Center(child: AppLoadingIndicator(size: 16, style: LoadingStyle.circle, color: Colors.white))),
        const SizedBox(width: 10),
        const Text('正在思考...', style: TextStyle(fontSize: 13, color: AuroraColors.text3, fontStyle: FontStyle.italic)),
      ]),
    );
  }

  // ── 流式指示器 ──
  Widget _buildStreamingIndicator(ChatState state) {
    final activeName = state.activeCharacterId != null
        ? state.conversation?.getCharacterById(state.activeCharacterId!)?.name ?? 'AI'
        : (state.conversation?.characterName ?? 'AI');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(children: [
        const AppLoadingIndicator(size: 20, style: LoadingStyle.wave, color: AuroraColors.primary),
        const SizedBox(width: 12),
        Text('$activeName 正在生成...', style: const TextStyle(fontSize: 13, color: AuroraColors.text3, fontWeight: FontWeight.w500)),
        const Spacer(),
        TextButton.icon(
          onPressed: () => ref.read(chatProvider(widget.conversationId!).notifier).stopStreaming(),
          icon: const Icon(Icons.stop_circle_outlined, size: 16),
          label: const Text('停止'),
          style: TextButton.styleFrom(foregroundColor: AuroraColors.rose, textStyle: const TextStyle(fontSize: 13)),
        ),
      ]),
    );
  }

  // ── 打字指示器 ──
  Widget _buildTypingIndicator() {
    return _TypingIndicator();
  }

  // ── 快捷回复 ──
  Widget _buildQuickReplies(List<String> replies) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(children: replies.map((r) => Padding(
          padding: const EdgeInsets.only(right: 8),
          child: GestureDetector(
            onTap: () { HapticFeedback.lightImpact(); ref.read(chatProvider(widget.conversationId!).notifier).sendMessage(r); },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(color: AuroraColors.bg2, borderRadius: BorderRadius.circular(AuroraRadius.full), border: Border.all(color: AuroraColors.border, width: 1)),
              child: Text(r, style: const TextStyle(fontSize: 13, color: AuroraColors.text2)),
            ),
          ),
        )).toList()),
      ),
    );
  }

  List<String> _generateQuickReplies(List<Message> msgs) {
    if (msgs.isEmpty || msgs.last.isUser) return [];
    final content = msgs.last.content;
    if (content.endsWith('？') || content.endsWith('?') || content.contains('吗？')) return ['嗯，好的', '让我想想', '当然可以'];
    if (content.length > 100) return ['继续说', '然后呢？', '后来怎么样了？'];
    if (content.contains('*') && content.indexOf('*') != content.lastIndexOf('*')) return ['回应一下', '我也做点什么', '继续观察'];
    return ['继续', '告诉我更多', '换个话题吧'];
  }

  // ── 场景/时间选择器 ──

  void _showScenePicker(Conversation c) {
    if (!c.hasWorld) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('当前对话未关联世界观，请先创建或选择世界观')));
      return;
    }
    // 异步加载世界观数据
    final wRepo = ref.read(worldRepositoryProvider);
    wRepo.getWorld(c.worldId!).then((world) {
      if (world == null || !mounted) return;
      _showScenePickerSheet(world);
    });
  }

  void _showScenePickerSheet(World world) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AuroraColors.bg4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(AuroraRadius.xxl))),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSheetState) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(width: 36, height: 4, margin: const EdgeInsets.only(top: 12, bottom: 16, left: 160, right: 160), decoration: BoxDecoration(color: AuroraColors.text4, borderRadius: BorderRadius.circular(2))),
              const Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: Row(children: [
                Icon(Icons.location_on_outlined, color: AuroraColors.cyan, size: 20), SizedBox(width: 8),
                Text('选择场景 & 时间', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AuroraColors.text1)),
              ])),
              const SizedBox(height: 8),
              // 时间选择
              const Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: Text('时间', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AuroraColors.text3, letterSpacing: 0.5))),
              const SizedBox(height: 8),
              SizedBox(height: 36, child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: ['清晨', '上午', '正午', '下午', '傍晚', '黄昏', '夜晚', '深夜', '凌晨'].map((t) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setSheetState(() {}),
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _activeTime = t);
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).clearSnackBars();
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('时间已设为: $t'), duration: const Duration(seconds: 1)));
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: _activeTime == t ? AuroraColors.cyan.withOpacity(0.15) : AuroraColors.bg2,
                          borderRadius: BorderRadius.circular(AuroraRadius.full),
                          border: Border.all(color: _activeTime == t ? AuroraColors.cyan : AuroraColors.border, width: 1),
                        ),
                        child: Center(child: Text(t, style: TextStyle(fontSize: 13, color: _activeTime == t ? AuroraColors.cyan : AuroraColors.text2))),
                      ),
                    ),
                  ),
                )).toList(),
              )),
              const SizedBox(height: 16),
              // 场景选择
              const Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: Text('场景', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AuroraColors.text3, letterSpacing: 0.5))),
              const SizedBox(height: 8),
              ...world.scenes.map((scene) => ListTile(
                leading: Container(width: 40, height: 40, decoration: BoxDecoration(
                  color: _activeScene == scene.name ? AuroraColors.cyan.withOpacity(0.15) : AuroraColors.bg2,
                  borderRadius: BorderRadius.circular(AuroraRadius.sm),
                  border: Border.all(color: _activeScene == scene.name ? AuroraColors.cyan : AuroraColors.border, width: 1),
                ), child: Icon(Icons.location_on, size: 20, color: _activeScene == scene.name ? AuroraColors.cyan : AuroraColors.text3)),
                title: Text(scene.name, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: _activeScene == scene.name ? AuroraColors.cyan : AuroraColors.text1)),
                subtitle: Text(scene.description ?? '无描述', style: const TextStyle(fontSize: 12, color: AuroraColors.text3), maxLines: 1, overflow: TextOverflow.ellipsis),
                trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                  if (scene.weather != null) _sceneChip(scene.weather!, AuroraColors.warning),
                  if (scene.atmosphere != null) _sceneChip(scene.atmosphere!, AuroraColors.primary),
                ]),
                onTap: () {
                setState(() {
                  _activeScene = scene.name;
                  _activeWeather = scene.weather;
                  _activeAtmosphere = scene.atmosphere;
                  _showSceneBanner = true;
                });
                Navigator.pop(ctx);
                _insertSceneChangeMessage(scene.name);
                },
              )),
              // 天气和氛围快速选择
              const Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: Text('天气 & 氛围', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AuroraColors.text3, letterSpacing: 0.5))),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Wrap(spacing: 8, runSpacing: 8, children: [
                  _quickChip('晴', Icons.wb_sunny, AuroraColors.warning, () { setState(() => _activeWeather = '晴'); Navigator.pop(ctx); }),
                  _quickChip('雨', Icons.water_drop, AuroraColors.info, () { setState(() => _activeWeather = '雨'); Navigator.pop(ctx); }),
                  _quickChip('阴', Icons.cloud, AuroraColors.text3, () { setState(() => _activeWeather = '阴'); Navigator.pop(ctx); }),
                  _quickChip('雾', Icons.foggy, AuroraColors.text4, () { setState(() => _activeWeather = '雾'); Navigator.pop(ctx); }),
                  _quickChip('轻松', Icons.sentiment_satisfied, AuroraColors.success, () { setState(() => _activeAtmosphere = '轻松'); Navigator.pop(ctx); }),
                  _quickChip('紧张', Icons.sentiment_neutral, AuroraColors.rose, () { setState(() => _activeAtmosphere = '紧张'); Navigator.pop(ctx); }),
                  _quickChip('浪漫', Icons.favorite, AuroraColors.rose, () { setState(() => _activeAtmosphere = '浪漫'); Navigator.pop(ctx); }),
                ]),
              ),
              const SizedBox(height: 8),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _sceneChip(String text, Color color) {
    return Container(
      margin: const EdgeInsets.only(left: 4),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(AuroraRadius.full)),
      child: Text(text, style: TextStyle(fontSize: 10, color: color)),
    );
  }

  Widget _quickChip(String label, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(color: AuroraColors.bg2, borderRadius: BorderRadius.circular(AuroraRadius.full), border: Border.all(color: AuroraColors.border, width: 1)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 12, color: color)),
        ]),
      ),
    );
  }

  /// 场景横幅
  Widget _buildSceneBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [AuroraColors.cyan.withOpacity(0.08), AuroraColors.primary.withOpacity(0.04)]),
        border: const Border(bottom: BorderSide(color: AuroraColors.border, width: 1)),
      ),
      child: Row(children: [
        Container(
          width: 32, height: 32,
          decoration: BoxDecoration(color: AuroraColors.cyan.withOpacity(0.15), borderRadius: BorderRadius.circular(AuroraRadius.sm)),
          child: const Icon(Icons.location_on, size: 18, color: AuroraColors.cyan),
        ),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(_activeScene ?? '', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AuroraColors.text1)),
          if (_activeTime != null || _activeWeather != null || _activeAtmosphere != null)
            Text([
              if (_activeTime != null) _activeTime,
              if (_activeWeather != null) _activeWeather,
              if (_activeAtmosphere != null) _activeAtmosphere,
            ].join(' · '), style: const TextStyle(fontSize: 11, color: AuroraColors.text3)),
        ])),
        GestureDetector(
          onTap: () {
            setState(() { _activeScene = null; _activeTime = null; _activeWeather = null; _activeAtmosphere = null; _showSceneBanner = false; });
            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('场景已清除'), duration: Duration(seconds: 1)));
          },
          child: const Icon(Icons.close, size: 16, color: AuroraColors.text4),
        ),
      ]),
    );
  }

  /// 插入场景切换系统消息
  void _insertSceneChangeMessage(String sceneName) {
    final repo = ref.read(conversationRepositoryProvider);
    final conv = ref.read(chatProvider(widget.conversationId!)).conversation;
    if (conv == null) return;
    final timeStr = _activeTime != null ? '的${_activeTime}' : '';
    final weatherStr = _activeWeather != null ? '，天气${_activeWeather}' : '';
    final atmStr = _activeAtmosphere != null ? '，氛围${_activeAtmosphere}' : '';
    final msg = createSystemMessage(content: '📍 场景切换至「$sceneName」$timeStr$weatherStr$atmStr');
    repo.addMessage(conv.id, msg);
    _scrollDown(force: true);
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('场景切换至: $sceneName'), duration: const Duration(seconds: 1)));
  }

  // ── Author's Note ──
  Widget _buildAuthorsNote(ChatState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: const BoxDecoration(
        color: AuroraColors.bg1,
        border: Border(top: BorderSide(color: AuroraColors.border, width: 1), bottom: BorderSide(color: AuroraColors.border, width: 1)),
      ),
      child: Row(children: [
        const Icon(Icons.edit_note, size: 16, color: AuroraColors.amber),
        const SizedBox(width: 8),
        Expanded(child: TextField(
          controller: _authorsNote,
          maxLines: 2,
          style: const TextStyle(fontSize: 13, color: AuroraColors.text1),
          decoration: const InputDecoration(
            hintText: '临时指令（Author\'s Note）...',
            border: InputBorder.none,
            isDense: true,
            contentPadding: EdgeInsets.symmetric(vertical: 6),
            hintStyle: TextStyle(color: AuroraColors.text4, fontSize: 13),
          ),
          onChanged: (v) {
            // 实时保存到对话设置
            final conv = ref.read(chatProvider(widget.conversationId!)).conversation;
            if (conv != null) {
              ref.read(chatProvider(widget.conversationId!).notifier).updateSettings(
                conv.settings.copyWith(customSystemPrompt: v.isEmpty ? null : v),
              );
            }
          },
        )),
        GestureDetector(
          onTap: () { _authorsNote.clear(); setState(() => _showAuthorsNote = false); },
          child: const Padding(padding: EdgeInsets.all(4), child: Icon(Icons.close, size: 18, color: AuroraColors.text3)),
        ),
      ]),
    );
  }

  // ── @mention 标签 ──
  Widget _buildMentionTag(Conversation c) {
    final char = c.allCharacters.firstWhere((ch) => ch.id == _mentionTargetId, orElse: () => c.allCharacters.first);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: GestureDetector(
        onTap: () => setState(() => _mentionTargetId = null),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(color: AuroraColors.cyan.withOpacity(0.12), borderRadius: BorderRadius.circular(AuroraRadius.sm)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Text('@${char.name}', style: const TextStyle(fontSize: 12, color: AuroraColors.cyan, fontWeight: FontWeight.w500)),
            const SizedBox(width: 6),
            const Icon(Icons.close, size: 14, color: AuroraColors.cyan),
          ]),
        ),
      ),
    );
  }

  // ── 其他 ──
  void _showDialogueStyleSettings() {
    final conv = ref.read(chatProvider(widget.conversationId!)).conversation;
    if (conv == null) return;
    showDialogueStylePanel(context,
      initialSettings: conv.settings.dialogueStyle,
      nsfwEnabled: conv.settings.nsfwEnabled,
      onNSFWPolicyChanged: (v) {
        final currentC = ref.read(chatProvider(widget.conversationId!)).conversation;
        if (currentC == null) return;
        ref.read(chatProvider(widget.conversationId!).notifier).updateSettings(
          currentC.settings.copyWith(nsfwEnabled: v),
        );
      },
      onSettingsChanged: (newStyle) {
        final currentConv = ref.read(chatProvider(widget.conversationId!)).conversation;
        if (currentConv == null) return;
        ref.read(chatProvider(widget.conversationId!).notifier).updateSettings(currentConv.settings.copyWith(dialogueStyle: newStyle));
      },
    );
  }

  Future<void> _toggleTTS(Message m) async {
    if (_ttsPlayingMessageId == m.id) {
      await ref.read(ttsServiceProvider)?.stop();
      if (mounted) setState(() => _ttsPlayingMessageId = null);
      return;
    }
    final ttsService = ref.read(ttsServiceProvider);
    final ttsConfig = ref.read(ttsConfigProvider);
    if (ttsService == null) {
      if (mounted) { ScaffoldMessenger.of(context).clearSnackBars(); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ttsConfig.isConfigured ? '请先启用 TTS' : '请先配置 TTS'))); }
      return;
    }
    setState(() => _ttsPlayingMessageId = m.id);
    try {
      await ttsService.speak(messageId: m.id, text: m.content, voice: ttsConfig.voice, style: ttsConfig.style, onComplete: () { if (mounted) setState(() => _ttsPlayingMessageId = null); });
    } catch (e) {
      if (mounted) { setState(() => _ttsPlayingMessageId = null); ScaffoldMessenger.of(context).clearSnackBars(); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('语音生成失败'))); }
    }
  }

  Widget _buildEmpty() => Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
    Container(width: 88, height: 88, decoration: BoxDecoration(shape: BoxShape.circle, color: AuroraColors.primarySoft), child: const Icon(Icons.forum_outlined, size: 36, color: AuroraColors.primaryGlow)),
    const SizedBox(height: 24),
    const Text('开始新对话', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AuroraColors.text1)),
    const SizedBox(height: 8),
    const Text('点击下方对话列表选择一个对话', style: TextStyle(color: AuroraColors.text3, fontSize: 14)),
  ]));

  Widget _buildError(String error) => Center(child: Padding(padding: const EdgeInsets.all(32), child: Column(mainAxisSize: MainAxisSize.min, children: [
    Container(width: 64, height: 64, decoration: BoxDecoration(shape: BoxShape.circle, color: AuroraColors.rose.withOpacity(0.1)), child: const Icon(Icons.error_outline, size: 30, color: AuroraColors.rose)),
    const SizedBox(height: 16),
    Text(error, style: const TextStyle(color: AuroraColors.text2, fontSize: 14), textAlign: TextAlign.center),
    const SizedBox(height: 16),
    OutlinedButton.icon(onPressed: () => ref.read(chatProvider(widget.conversationId!).notifier).loadConversation(widget.conversationId!), icon: const Icon(Icons.refresh, size: 18), label: const Text('重试')),
  ])));

  Widget _buildSearchOverlay(ChatState state) {
    return Column(children: [
      ClipRect(child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16), child: Container(
        padding: const EdgeInsets.all(12),
        color: AuroraColors.bg1.withOpacity(0.9),
        child: Row(children: [
          Expanded(child: Container(
            decoration: BoxDecoration(color: AuroraColors.bg2, borderRadius: BorderRadius.circular(AuroraRadius.md), border: Border.all(color: AuroraColors.border, width: 1)),
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: TextField(controller: _searchCtrl, autofocus: true, style: const TextStyle(color: AuroraColors.text1, fontSize: 15), decoration: const InputDecoration(hintText: '搜索消息...', hintStyle: TextStyle(color: AuroraColors.text4), border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10)), onChanged: _doSearch),
          )),
          if (_matchIndexes.isNotEmpty) Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: Text('${_matchIndex + 1}/${_matchIndexes.length}', style: const TextStyle(fontSize: 12, color: AuroraColors.text3))),
          _iconBtn(Icons.keyboard_arrow_up, _prevMatch),
          _iconBtn(Icons.keyboard_arrow_down, _nextMatch),
          _iconBtn(Icons.close, () => setState(() => _searching = false)),
        ]),
      ))),
      if (_query.isNotEmpty && _matchIndexes.isEmpty) const Padding(padding: EdgeInsets.all(32), child: Text('没有找到匹配消息', style: TextStyle(color: AuroraColors.text3))),
      if (_query.isEmpty || _matchIndexes.isNotEmpty) Expanded(child: _buildChat(state, [])),
    ]);
  }
}

/// 打字指示器
class _TypingIndicator extends StatefulWidget {
  @override State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator> with TickerProviderStateMixin {
  late final List<AnimationController> _controllers;
  late final List<Animation<double>> _animations;

  @override void initState() {
    super.initState();
    _controllers = List.generate(3, (i) => AnimationController(vsync: this, duration: const Duration(milliseconds: 500)));
    _animations = _controllers.map((c) => Tween<double>(begin: 0, end: -6).animate(CurvedAnimation(parent: c, curve: Curves.easeInOut))).toList();
    _startBounce();
  }

  void _startBounce() async {
    for (var i = 0; i < 3; i++) { await Future.delayed(const Duration(milliseconds: 150)); if (mounted) _controllers[i].repeat(reverse: true); }
  }

  @override void dispose() { for (final c in _controllers) { c.dispose(); } super.dispose(); }

  @override Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(mainAxisSize: MainAxisSize.min, children: List.generate(3, (i) => AnimatedBuilder(
        animation: _animations[i],
        builder: (_, __) => Transform.translate(
          offset: Offset(0, _animations[i].value),
          child: Container(width: 7, height: 7, margin: EdgeInsets.only(right: i < 2 ? 5 : 0), decoration: BoxDecoration(shape: BoxShape.circle, color: AuroraColors.text3.withOpacity(0.5))),
        ),
      ))),
    );
  }
}

/// 富文本消息 — Aurora 增强版
class _RichMessageText extends StatelessWidget {
  final String content;
  final Color textColor;
  final bool isUser;
  const _RichMessageText({required this.content, required this.textColor, this.isUser = false});

  @override Widget build(BuildContext context) {
    return RichText(text: _buildTextSpan(), softWrap: true);
  }

  TextSpan _buildTextSpan() {
    final spans = <TextSpan>[];
    final regex = RegExp(r'\*([^*]+)\*|"([^"]+?)"|\*\*([^*]+)\*\*|`([^`]+)`');
    int lastEnd = 0;
    for (final match in regex.allMatches(content)) {
      if (match.start > lastEnd) spans.add(TextSpan(text: content.substring(lastEnd, match.start), style: _normal()));
      if (match.group(1) != null) spans.add(TextSpan(text: '*${match.group(1)}*', style: _action()));
      else if (match.group(2) != null) spans.add(TextSpan(text: '"${match.group(2)}"', style: _dialogue()));
      else if (match.group(3) != null) spans.add(TextSpan(text: match.group(3)!, style: _bold()));
      else if (match.group(4) != null) spans.add(TextSpan(text: match.group(4)!, style: _code()));
      lastEnd = match.end;
    }
    if (lastEnd < content.length) spans.add(TextSpan(text: content.substring(lastEnd), style: _normal()));
    if (spans.isEmpty) spans.add(TextSpan(text: content, style: _normal()));
    return TextSpan(children: spans);
  }

  TextStyle _normal() => TextStyle(fontSize: 13.5, color: textColor, height: 1.6);
  TextStyle _action() => TextStyle(fontSize: 13.5, color: textColor.withOpacity(0.65), fontStyle: FontStyle.italic, height: 1.6);
  TextStyle _dialogue() => TextStyle(fontSize: 13.5, color: isUser ? Colors.white.withOpacity(0.85) : AuroraColors.primaryGlow, fontWeight: FontWeight.w500, height: 1.6);
  TextStyle _bold() => TextStyle(fontSize: 13.5, color: textColor, fontWeight: FontWeight.w700, height: 1.6);
  TextStyle _code() => TextStyle(fontSize: 12.5, color: AuroraColors.amber, backgroundColor: AuroraColors.bg2, fontFamily: 'monospace', height: 1.5);
}
