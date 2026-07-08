import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:dream_startalk/shared/helpers/avatar_gradient.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:dream_startalk/core/theme/aurora_theme.dart';
import '../../domain/entities/conversation.dart';
import '../providers/chat_provider.dart';
import '../../../character/presentation/providers/character_provider.dart';
import '../../../character/domain/entities/character.dart';

class ConversationListPage extends ConsumerStatefulWidget {
  const ConversationListPage({super.key});
  @override ConsumerState<ConversationListPage> createState() => _State();
}

class _State extends ConsumerState<ConversationListPage> {
  final _search = TextEditingController();
  bool _searching = false;

  @override void initState() {
    super.initState();
    Future.microtask(() => ref.read(conversationListProvider.notifier).loadConversations());
  }
  @override void dispose() { _search.dispose(); super.dispose(); }

  @override Widget build(BuildContext context) {
    final s = ref.watch(conversationListProvider);
    return Scaffold(
      backgroundColor: AuroraColors.bg0,
      body: Column(children: [
        // ── 顶部区域 ──
        _buildHeader(s),
        // ── 搜索栏（可折叠） ──
        if (_searching) _buildSearchBar(),
        // ── 内容区 ──
        Expanded(
          child: s.isLoading
              ? _buildSkeleton()
              : s.error != null
                  ? _buildError(s.error!)
                  : s.conversations.isEmpty
                      ? _buildEmpty()
                      : _buildGroupedList(s),
        ),
      ]),
      floatingActionButton: _buildFAB(),
    );
  }

  /// 顶部标题栏
  Widget _buildHeader(ConversationListState s) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 12, 20, 4),
      child: Row(children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('对话', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: AuroraColors.text1, letterSpacing: -0.8)),
          if (!s.isLoading && s.conversations.isNotEmpty)
            Text('${s.conversations.length} 个进行中的对话', style: const TextStyle(fontSize: 12, color: AuroraColors.text3)),
        ]),
        const Spacer(),
        _iconButton(_searching ? Icons.close : Icons.search, () {
          setState(() { _searching = !_searching; if (!_searching) { _search.clear(); ref.read(conversationListProvider.notifier).loadConversations(); } });
        }),
      ]),
    );
  }

  /// 搜索栏 — 可折叠
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: TextField(
        controller: _search,
        style: const TextStyle(color: AuroraColors.text1, fontSize: 15),
        decoration: InputDecoration(
          hintText: '搜索对话...',
          prefixIcon: const Icon(Icons.search, size: 20, color: AuroraColors.text3),
          suffixIcon: _search.text.isNotEmpty
              ? GestureDetector(
                  onTap: () { _search.clear(); ref.read(conversationListProvider.notifier).loadConversations(); },
                  child: const Icon(Icons.close, size: 18, color: AuroraColors.text3),
                )
              : null,
          filled: true,
          fillColor: AuroraColors.bg2,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(AuroraRadius.lg), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AuroraRadius.lg), borderSide: const BorderSide(color: AuroraColors.border, width: 1)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AuroraRadius.lg), borderSide: const BorderSide(color: AuroraColors.borderPrimary, width: 1)),
        ),
        onChanged: (q) => ref.read(conversationListProvider.notifier).searchConversations(q),
      ),
    );
  }

  /// 按时间分组的列表
  Widget _buildGroupedList(ConversationListState s) {
    final groups = _groupByDate(s.conversations);
    return RefreshIndicator(
      color: AuroraColors.primary,
      backgroundColor: AuroraColors.bg3,
      onRefresh: () async {
        await ref.read(conversationListProvider.notifier).loadConversations();
      },
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
        itemCount: groups.length,
        itemBuilder: (_, i) {
          final group = groups[i];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 分组标题
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 16, 0, 10),
                child: Row(children: [
                  Text(group.label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AuroraColors.text3, letterSpacing: 0.8)),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
                    decoration: BoxDecoration(color: AuroraColors.bg2, borderRadius: BorderRadius.circular(AuroraRadius.full)),
                    child: Text('${group.conversations.length}', style: const TextStyle(fontSize: 10, color: AuroraColors.text3)),
                  ),
                ]),
              ),
              // 对话卡片
              ...group.conversations.map((c) => _buildCard(c)),
            ],
          );
        },
      ),
    );
  }

  /// 对话卡片
  Widget _buildCard(Conversation c) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: _PressableTile(
        onTap: () => context.push('/chat/${c.id}'),
        onLongPress: () => _showMenu(c),
        child: Dismissible(
          key: ValueKey(c.id),
          direction: DismissDirection.endToStart,
          background: Container(
            decoration: BoxDecoration(
              color: AuroraColors.rose.withOpacity(0.12),
              borderRadius: BorderRadius.circular(AuroraRadius.lg),
            ),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: const Icon(Icons.delete_outline, color: AuroraColors.rose, size: 22),
          ),
          confirmDismiss: (_) => _confirmDelete(c),
          onDismissed: (_) => _deleteConv(c.id),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AuroraColors.bg2,
              borderRadius: BorderRadius.circular(AuroraRadius.lg),
              border: Border.all(
                color: c.isMultiCharacterMode ? AuroraColors.cyan.withOpacity(0.2) : AuroraColors.border,
                width: 1,
              ),
            ),
            child: Row(children: [
              // 头像
              c.isMultiCharacterMode ? _buildMultiAvatar(c) : _buildAvatar(c),
              const SizedBox(width: 14),
              // 内容
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Expanded(child: Text(
                    c.isMultiCharacterMode ? _multiCharTitle(c) : c.displayTitle,
                    style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600, color: AuroraColors.text1),
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                  )),
                  if (c.isMultiCharacterMode) _buildCyanTag('${c.additionalCharacters.length + 1}人'),
                ]),
                const SizedBox(height: 5),
                Text(c.lastMessagePreview, style: const TextStyle(fontSize: 12.5, color: AuroraColors.text3), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 6),
                Row(children: [
                  Text(c.lastMessageTimeString, style: const TextStyle(fontSize: 11, color: AuroraColors.text4)),
                  if (c.messageCountActual > 0) ...[
                    const SizedBox(width: 10),
                    const Icon(Icons.chat_bubble_outline, size: 11, color: AuroraColors.text4),
                    const SizedBox(width: 3),
                    Text('${c.messageCountActual}', style: const TextStyle(fontSize: 11, color: AuroraColors.text4)),
                  ],
                ]),
              ])),
              const Icon(Icons.chevron_right, color: AuroraColors.text4, size: 20),
            ]),
          ),
        ),
      ),
    );
  }

  /// FAB — Aurora 风格
  Widget _buildFAB() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AuroraRadius.lg),
        gradient: AuroraColors.gradientPrimary,
        boxShadow: [BoxShadow(color: AuroraColors.primary.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 6))],
      ),
      child: FloatingActionButton(
        onPressed: () => _showQuickStartSheet(),
        backgroundColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AuroraRadius.lg)),
        child: const Icon(Icons.add, color: Colors.white, size: 26),
      ),
    );
  }

  /// 头像
  Widget _buildAvatar(Conversation c) {
    final name = c.characterName ?? '';
    final avatarPath = c.characterAvatar;
    final hasAvatar = avatarPath != null && avatarPath.isNotEmpty;
    return Container(
      width: 48, height: 48,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(AuroraRadius.md)),
      clipBehavior: Clip.antiAlias,
      child: hasAvatar
          ? (avatarPath.startsWith('http')
              ? CachedNetworkImage(imageUrl: avatarPath, fit: BoxFit.cover, memCacheWidth: 96, errorWidget: (_, __, ___) => _avatarFallback(name))
              : Image.file(File(avatarPath), fit: BoxFit.cover, errorBuilder: (_, __, ___) => _avatarFallback(name)))
          : _avatarFallback(name),
    );
  }

  Widget _avatarFallback(String name) {
    final colors = AvatarGradientHelper.getColors(name);
    return Container(
      decoration: BoxDecoration(gradient: LinearGradient(colors: colors)),
      child: Center(child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white))),
    );
  }

  /// 多角色堆叠头像
  Widget _buildMultiAvatar(Conversation c) {
    final chars = c.allCharacters.take(2).toList();
    return SizedBox(
      width: 48, height: 48,
      child: Stack(children: List.generate(chars.length, (i) => Positioned(
        left: i * 16.0,
        child: Container(
          width: 32, height: 32,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AuroraRadius.sm),
            border: Border.all(color: AuroraColors.bg2, width: 2),
          ),
          clipBehavior: Clip.antiAlias,
          child: Container(
            decoration: BoxDecoration(gradient: LinearGradient(colors: AvatarGradientHelper.getColors(chars[i].name))),
            child: Center(child: Text(chars[i].name[0].toUpperCase(), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white))),
          ),
        ),
      ))),
    );
  }

  String _multiCharTitle(Conversation c) {
    final names = c.allCharacters.map((ch) => ch.name).toList();
    if (names.length <= 2) return names.join(' & ');
    return '${names.first} 等${names.length}人';
  }

  Widget _buildCyanTag(String text) {
    return Container(
      margin: const EdgeInsets.only(left: 6),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: AuroraColors.cyan.withOpacity(0.12), borderRadius: BorderRadius.circular(5)),
      child: Text(text, style: const TextStyle(fontSize: 10, color: AuroraColors.cyan, fontWeight: FontWeight.w600)),
    );
  }

  Widget _iconButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(color: AuroraColors.bg2, borderRadius: BorderRadius.circular(AuroraRadius.md)),
        child: Icon(icon, size: 20, color: AuroraColors.text2),
      ),
    );
  }

  /// 快速开始
  void _showQuickStartSheet() {
    final charState = ref.read(characterListProvider);
    if (charState.characters.isEmpty) { context.push('/chat/new'); return; }
    showModalBottomSheet(
      context: context,
      backgroundColor: AuroraColors.bg4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(AuroraRadius.xxl))),
      builder: (_) => SafeArea(child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 36, height: 4, margin: const EdgeInsets.only(top: 12, bottom: 16), decoration: BoxDecoration(color: AuroraColors.text4, borderRadius: BorderRadius.circular(2))),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: Row(children: [
            const Icon(Icons.flash_on, color: AuroraColors.amber, size: 20),
            const SizedBox(width: 8),
            const Text('快速开始对话', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AuroraColors.text1)),
            const Spacer(),
            TextButton(onPressed: () { Navigator.pop(_); context.push('/chat/new'); }, child: const Text('完整向导')),
          ])),
          const SizedBox(height: 8),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              children: charState.characters.take(6).map((c) => ListTile(
                leading: Container(width: 40, height: 40, decoration: BoxDecoration(gradient: AuroraColors.gradientPrimary, borderRadius: BorderRadius.circular(AuroraRadius.sm)), child: Center(child: Text(c.name[0], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)))),
                title: Text(c.name, style: const TextStyle(fontWeight: FontWeight.w500, color: AuroraColors.text1)),
                subtitle: Text(c.summary, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: AuroraColors.text3)),
                onTap: () async { Navigator.pop(_); await _quickStart(c); },
              )).toList(),
            ),
          ),
        ]),
      )),
    );
  }

  Future<void> _quickStart(Character c) async {
    HapticFeedback.lightImpact();
    try {
      final conv = await ref.read(conversationListProvider.notifier).quickCreateConversation(character: c);
      if (mounted) context.go('/chat/${conv.id}');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('创建失败，请重试')));
      }
    }
  }

  /// 分组逻辑
  List<_ConvGroup> _groupByDate(List<Conversation> convs) {
    final now = DateTime.now();
    final today = <Conversation>[];
    final yesterday = <Conversation>[];
    final earlier = <Conversation>[];
    final todayDate = DateTime(now.year, now.month, now.day);
    final yesterdayDate = todayDate.subtract(const Duration(days: 1));
    for (final c in convs) {
      final t = c.lastMessageAt ?? c.createdAt ?? now;
      final msgDate = DateTime(t.year, t.month, t.day);
      if (msgDate == todayDate) { today.add(c); }
      else if (msgDate == yesterdayDate) { yesterday.add(c); }
      else { earlier.add(c); }
    }
    final groups = <_ConvGroup>[];
    if (today.isNotEmpty) groups.add(_ConvGroup('今天', today));
    if (yesterday.isNotEmpty) groups.add(_ConvGroup('昨天', yesterday));
    if (earlier.isNotEmpty) groups.add(_ConvGroup('更早', earlier));
    return groups;
  }

  void _showMenu(Conversation c) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AuroraColors.bg4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(AuroraRadius.xxl))),
      builder: (_) => SafeArea(child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 36, height: 4, margin: const EdgeInsets.only(bottom: 12), decoration: BoxDecoration(color: AuroraColors.text4, borderRadius: BorderRadius.circular(2))),
          _menuItem(Icons.chat_bubble_outline, '继续对话', AuroraColors.primary, () { Navigator.pop(_); context.push('/chat/${c.id}'); }),
          if (c.hasWorld) _menuItem(Icons.public, '世界观: ${c.worldName}', AuroraColors.cyan, () {}),
          const Divider(indent: 20, endIndent: 20),
          _menuItem(Icons.delete_outline, '删除对话', AuroraColors.rose, () { Navigator.pop(_); _deleteConv(c.id); }),
        ]),
      )),
    );
  }

  Widget _menuItem(IconData icon, String title, Color color, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: color, size: 22),
      title: Text(title, style: const TextStyle(fontSize: 15, color: AuroraColors.text1)),
      onTap: onTap,
    );
  }

  Future<bool?> _confirmDelete(Conversation c) {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AuroraColors.bg4,
        title: const Text('确认删除'),
        content: const Text('删除后无法恢复，确定继续？'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(_, false), child: const Text('取消')),
          TextButton(onPressed: () => Navigator.pop(_, true), style: TextButton.styleFrom(foregroundColor: AuroraColors.rose), child: const Text('删除')),
        ],
      ),
    );
  }

  Future<void> _deleteConv(String id) async {
    final repo = ref.read(conversationRepositoryProvider);
    final snapshot = await repo.getConversation(id);
    await repo.deleteConversation(id);
    ref.read(conversationListProvider.notifier).loadConversations();
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Text('已删除'),
      action: SnackBarAction(label: '撤销', textColor: AuroraColors.amber, onPressed: () async {
        if (snapshot != null) { await repo.updateConversation(snapshot); ref.read(conversationListProvider.notifier).loadConversations(); }
      }),
      duration: const Duration(seconds: 3),
    ));
  }

  // ── 骨架屏 ──
  Widget _buildSkeleton() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 6,
      itemBuilder: (_, __) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Container(
          height: 80,
          decoration: BoxDecoration(color: AuroraColors.bg2, borderRadius: BorderRadius.circular(AuroraRadius.lg)),
        ),
      ),
    );
  }

  // ── 空状态 ──
  Widget _buildEmpty() {
    return Center(child: Padding(padding: const EdgeInsets.all(32), child: Column(mainAxisSize: MainAxisSize.min, children: [
      Container(
        width: 88, height: 88,
        decoration: BoxDecoration(shape: BoxShape.circle, color: AuroraColors.primarySoft),
        child: const Icon(Icons.forum_outlined, size: 36, color: AuroraColors.primaryGlow),
      ),
      const SizedBox(height: 24),
      const Text('开始新的对话', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AuroraColors.text1)),
      const SizedBox(height: 8),
      const Text('选择角色卡开始角色扮演', style: TextStyle(color: AuroraColors.text3, fontSize: 14)),
      const SizedBox(height: 28),
      FilledButton.icon(onPressed: () => context.push('/chat/new'), icon: const Icon(Icons.add, size: 18), label: const Text('新建对话')),
    ])));
  }

  // ── 错误状态 ──
  Widget _buildError(String e) {
    return Center(child: Padding(padding: const EdgeInsets.all(32), child: Column(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 64, height: 64, decoration: BoxDecoration(shape: BoxShape.circle, color: AuroraColors.rose.withOpacity(0.1)), child: const Icon(Icons.error_outline, size: 30, color: AuroraColors.rose)),
      const SizedBox(height: 16),
      Text(e, style: const TextStyle(color: AuroraColors.text2, fontSize: 14), textAlign: TextAlign.center),
      const SizedBox(height: 16),
      OutlinedButton.icon(onPressed: () => ref.read(conversationListProvider.notifier).loadConversations(), icon: const Icon(Icons.refresh, size: 18), label: const Text('重试')),
    ])));
  }
}

/// 时间分组
class _ConvGroup {
  final String label;
  final List<Conversation> conversations;
  _ConvGroup(this.label, this.conversations);
}

/// 按压缩放
class _PressableTile extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  const _PressableTile({required this.child, this.onTap, this.onLongPress});
  @override State<_PressableTile> createState() => _PressableTileState();
}

class _PressableTileState extends State<_PressableTile> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 120), reverseDuration: const Duration(milliseconds: 200));
    _scale = Tween<double>(begin: 1, end: 0.97).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
  }
  @override void dispose() { _ctrl.dispose(); super.dispose(); }

  @override Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) { _ctrl.reverse(); widget.onTap?.call(); },
      onTapCancel: () => _ctrl.reverse(),
      onLongPress: widget.onLongPress,
      child: AnimatedBuilder(
        animation: _scale,
        builder: (context, child) => Transform.scale(scale: _scale.value, child: child, alignment: Alignment.centerLeft),
        child: widget.child,
      ),
    );
  }
}
