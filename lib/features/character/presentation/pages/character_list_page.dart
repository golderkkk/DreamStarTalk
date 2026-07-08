import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dream_startalk/shared/helpers/avatar_gradient.dart';
import '../../data/datasources/character_card_parser.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dream_startalk/core/theme/aurora_theme.dart';
import 'package:dream_startalk/shared/data/preset_data.dart';
import '../../domain/entities/character.dart';
import '../providers/character_provider.dart';
import '../../../chat/presentation/providers/chat_provider.dart';

class CharacterListPage extends ConsumerStatefulWidget {
  const CharacterListPage({super.key});
  @override ConsumerState<CharacterListPage> createState() => _State();
}

class _State extends ConsumerState<CharacterListPage> with TickerProviderStateMixin {
  final _search = TextEditingController();
  late final AnimationController _staggerCtrl;
  bool _staggerStarted = false;
  bool _searching = false;

  @override void initState() {
    super.initState();
    _staggerCtrl = AnimationController(vsync: this, duration: AuroraDuration.slow);
    Future.microtask(() => ref.read(characterListProvider.notifier).loadCharacters());
  }
  @override void dispose() { _search.dispose(); _staggerCtrl.dispose(); super.dispose(); }

  void _startStagger() {
    if (!_staggerStarted) { _staggerStarted = true; _staggerCtrl.forward(); }
  }

  @override Widget build(BuildContext context) {
    final s = ref.watch(characterListProvider);
    if (!s.isLoading && s.error == null && s.characters.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _startStagger());
    }
    return Scaffold(
      backgroundColor: AuroraColors.bg0,
      body: Column(children: [
        _buildHeader(s),
        if (_searching) _buildSearchBar(),
        Expanded(child: s.isLoading ? _buildSkeleton() : s.error != null ? _buildError(s.error!) : s.characters.isEmpty ? _buildEmpty() : _buildGrid(s)),
      ]),
      floatingActionButton: _buildFAB(),
    );
  }

  Widget _buildHeader(CharacterListState s) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 12, 20, 4),
      child: Row(children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('角色', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: AuroraColors.text1, letterSpacing: -0.8)),
          if (!s.isLoading && s.characters.isNotEmpty)
            Text('${s.characters.length} 个角色', style: const TextStyle(fontSize: 12, color: AuroraColors.text3)),
        ]),
        const Spacer(),
        _iconBtn(_searching ? Icons.close : Icons.search, () {
          setState(() { _searching = !_searching; if (!_searching) { _search.clear(); ref.read(characterListProvider.notifier).loadCharacters(); } });
        }),
        const SizedBox(width: 6),
        _iconBtn(Icons.upload_file, _importFromPng, tooltip: '导入角色卡'),
        const SizedBox(width: 6),
        _iconBtn(Icons.auto_awesome, _showPresetDialog, tooltip: '从模板创建'),
      ]),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: TextField(
        controller: _search,
        autofocus: true,
        style: const TextStyle(color: AuroraColors.text1, fontSize: 15),
        decoration: InputDecoration(
          hintText: '搜索角色...',
          prefixIcon: const Icon(Icons.search, size: 20, color: AuroraColors.text3),
          suffixIcon: _search.text.isNotEmpty
              ? GestureDetector(
                  onTap: () { _search.clear(); ref.read(characterListProvider.notifier).loadCharacters(); },
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
        onChanged: (q) => ref.read(characterListProvider.notifier).searchCharacters(q),
      ),
    );
  }

  Widget _buildGrid(CharacterListState s) {
    return RefreshIndicator(
      color: AuroraColors.primary,
      backgroundColor: AuroraColors.bg3,
      onRefresh: () async { _staggerStarted = false; _staggerCtrl.reset(); await ref.read(characterListProvider.notifier).loadCharacters(); },
      child: GridView.builder(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.75, crossAxisSpacing: 14, mainAxisSpacing: 14),
        itemCount: s.characters.length,
        itemBuilder: (_, i) => _staggeredCard(s.characters[i], i),
      ),
    );
  }

  Widget _staggeredCard(Character c, int index) {
    final delay = (index * 0.08).clamp(0.0, 0.6);
    final slide = Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero).animate(CurvedAnimation(parent: _staggerCtrl, curve: Interval(delay, (delay + 0.4).clamp(0.0, 1.0), curve: Curves.easeOutCubic)));
    final fade = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _staggerCtrl, curve: Interval(delay, (delay + 0.3).clamp(0.0, 1.0), curve: Curves.easeOut)));
    return AnimatedBuilder(
      key: ValueKey(c.id),
      animation: _staggerCtrl,
      builder: (context, child) => FadeTransition(opacity: fade, child: SlideTransition(position: slide, child: child)),
      child: _card(c),
    );
  }

  Widget _card(Character c) {
    return _PressableCard(
      onTap: () => context.push('/characters/${c.id}'),
      onLongPress: () => _showMenu(c),
      child: Container(
        decoration: BoxDecoration(
          color: AuroraColors.bg2,
          borderRadius: BorderRadius.circular(AuroraRadius.lg),
          border: Border.all(color: AuroraColors.border, width: 1),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(children: [
          Expanded(flex: 5, child: _buildCover(c)),
          Expanded(flex: 3, child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(c.displayName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AuroraColors.text1), maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              Expanded(child: Text(c.summary, style: const TextStyle(fontSize: 11.5, color: AuroraColors.text3, height: 1.4), maxLines: 2, overflow: TextOverflow.ellipsis)),
              if (c.tags.isNotEmpty)
                Padding(padding: const EdgeInsets.only(top: 6), child: Wrap(spacing: 4, runSpacing: 3, children: c.tags.take(2).map((t) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(color: AuroraColors.primarySoft, borderRadius: BorderRadius.circular(AuroraRadius.full)),
                  child: Text(t, style: const TextStyle(fontSize: 9.5, color: AuroraColors.primaryGlow, fontWeight: FontWeight.w500)),
                )).toList())),
            ]),
          )),
        ]),
      ),
    );
  }

  Widget _buildCover(Character c) {
    if (!c.hasAvatar) {
      final colors = AvatarGradientHelper.getColors(c.name);
      return Container(
        decoration: BoxDecoration(gradient: LinearGradient(colors: colors, begin: Alignment.topLeft, end: Alignment.bottomRight)),
        child: Center(child: Container(
          width: 56, height: 56,
          decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.15)),
          child: Center(child: Text(c.name[0].toUpperCase(), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: Colors.white))),
        )),
      );
    }
    final avatar = c.avatar!;
    return avatar.startsWith('http')
        ? CachedNetworkImage(imageUrl: avatar, fit: BoxFit.cover, memCacheWidth: 300, errorWidget: (_, __, ___) => _coverFallback(c))
        : Image.file(File(avatar), fit: BoxFit.cover, errorBuilder: (_, __, ___) => _coverFallback(c));
  }

  Widget _coverFallback(Character c) {
    final colors = AvatarGradientHelper.getColors(c.name);
    return Container(
      decoration: BoxDecoration(gradient: LinearGradient(colors: colors)),
      child: Center(child: Text(c.name[0].toUpperCase(), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: Colors.white))),
    );
  }

  Widget _buildFAB() {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(AuroraRadius.lg), gradient: AuroraColors.gradientPrimary, boxShadow: [BoxShadow(color: AuroraColors.primary.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 6))]),
      child: FloatingActionButton(
        onPressed: () => context.push('/characters/new'),
        backgroundColor: Colors.transparent, elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AuroraRadius.lg)),
        child: const Icon(Icons.add, color: Colors.white, size: 26),
      ),
    );
  }

  Widget _iconBtn(IconData icon, VoidCallback onTap, {String? tooltip}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(width: 36, height: 36, decoration: BoxDecoration(color: AuroraColors.bg2, borderRadius: BorderRadius.circular(AuroraRadius.md)), child: Icon(icon, size: 20, color: AuroraColors.text2)),
    );
  }

  // ── 操作 ──

  void _showMenu(Character c) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AuroraColors.bg4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(AuroraRadius.xxl))),
      builder: (_) => SafeArea(child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 36, height: 4, margin: const EdgeInsets.only(bottom: 12), decoration: BoxDecoration(color: AuroraColors.text4, borderRadius: BorderRadius.circular(2))),
          _menuItem(Icons.edit_outlined, '编辑角色', AuroraColors.primary, () { Navigator.pop(_); context.push('/characters/${c.id}'); }),
          _menuItem(Icons.chat_bubble_outline, '开始对话', AuroraColors.cyan, () { Navigator.pop(_); _startChat(c.id); }),
          _menuItem(Icons.copy_outlined, '复制角色', AuroraColors.info, () { Navigator.pop(_); _copy(c.id); }),
          _menuItem(Icons.image, '导出为 PNG 角色卡', AuroraColors.success, () { Navigator.pop(_); _exportPng(c.id); }),
          _menuItem(Icons.ios_share, '导出为 JSON', AuroraColors.info, () { Navigator.pop(_); _export(c.id); }),
          const Divider(indent: 20, endIndent: 20),
          _menuItem(Icons.delete_outline, '删除角色', AuroraColors.rose, () { Navigator.pop(_); _confirmDelete(c.id); }),
        ]),
      )),
    );
  }

  Widget _menuItem(IconData icon, String title, Color color, VoidCallback onTap) {
    return ListTile(leading: Icon(icon, color: color, size: 22), title: Text(title, style: const TextStyle(fontSize: 15, color: AuroraColors.text1)), onTap: onTap);
  }

  void _confirmDelete(String id) {
    showDialog(context: context, builder: (_) => AlertDialog(
      backgroundColor: AuroraColors.bg4,
      title: const Text('确认删除'), content: const Text('删除后无法恢复，确定继续？'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(_), child: const Text('取消')),
        TextButton(onPressed: () { Navigator.pop(_); _deleteWithUndo(id); }, style: TextButton.styleFrom(foregroundColor: AuroraColors.rose), child: const Text('删除')),
      ],
    ));
  }

  Future<void> _deleteWithUndo(String id) async {
    final repo = ref.read(characterRepositoryProvider);
    final snapshot = await repo.getCharacter(id);
    await repo.deleteCharacter(id);
    ref.read(characterListProvider.notifier).loadCharacters();
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Text('已删除'),
      action: SnackBarAction(label: '撤销', textColor: AuroraColors.amber, onPressed: () async {
        if (snapshot != null) { await repo.createCharacter(snapshot); ref.read(characterListProvider.notifier).loadCharacters(); }
      }),
      duration: const Duration(seconds: 3),
    ));
  }

  Future<void> _copy(String id) async {
    try {
      final c = await ref.read(characterRepositoryProvider).getCharacter(id);
      if (c == null) return;
      await ref.read(characterRepositoryProvider).createCharacter(c.copyWith(id: 'char_${DateTime.now().millisecondsSinceEpoch}', name: '${c.name} (副本)', createdAt: null, updatedAt: null));
      ref.read(characterListProvider.notifier).loadCharacters();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('已复制')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('操作失败，请重试')));
    }
  }

  Future<void> _exportPng(String id) async {
    try {
      final c = await ref.read(characterRepositoryProvider).getCharacter(id);
      if (c == null) return;
      final filePath = await CharacterCardParser.exportToPng(c);
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('PNG 已导出: ${c.name}')));
        await Share.shareXFiles([XFile(filePath)], subject: '${c.name} - 角色卡');
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('导出失败，请重试')));
    }
  }

  Future<void> _export(String id) async {
    try {
      final c = await ref.read(characterRepositoryProvider).getCharacter(id);
      if (c == null) return;
      final dir = await getApplicationDocumentsDirectory();
      final exportDir = Directory('${dir.path}/exports');
      if (!await exportDir.exists()) await exportDir.create(recursive: true);
      final fileName = '${c.name.replaceAll(RegExp(r'[\\/*?:"<>|]'), '_')}.json';
      final file = File('${exportDir.path}/$fileName');
      await file.writeAsString(const JsonEncoder.withIndent('  ').convert(c.toJson()));
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('已导出: ${c.name}.json')));
        await Share.shareXFiles([XFile(file.path)], subject: '${c.name} - 角色卡');
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('操作失败，请重试')));
    }
  }

  Future<void> _startChat(String id) async {
    try {
      final c = await ref.read(characterRepositoryProvider).getCharacter(id);
      if (c == null) return;
      final conv = await ref.read(conversationListProvider.notifier).quickCreateConversation(character: c);
      if (mounted) context.go('/chat/${conv.id}');
    } catch (e) {
      if (mounted) { ScaffoldMessenger.of(context).clearSnackBars(); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('创建失败，请重试'))); }
    }
  }

  void _showPresetDialog() {
    final presets = PresetCharacters.all;
    showModalBottomSheet(
      context: context, isScrollControlled: true,
      backgroundColor: AuroraColors.bg4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(AuroraRadius.xxl))),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.75, minChildSize: 0.3, maxChildSize: 0.9, expand: false,
        builder: (ctx, scrollCtrl) => Column(children: [
          Container(width: 36, height: 4, margin: const EdgeInsets.only(top: 12, bottom: 16), decoration: BoxDecoration(color: AuroraColors.text4, borderRadius: BorderRadius.circular(2))),
          const Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: Row(children: [
            Icon(Icons.auto_awesome, color: AuroraColors.amber, size: 20), SizedBox(width: 8),
            Text('预设角色', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AuroraColors.text1)),
          ])),
          const SizedBox(height: 8),
          Expanded(child: ListView.builder(
            controller: scrollCtrl, padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: presets.length,
            itemBuilder: (ctx, i) {
              final c = presets[i];
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(color: AuroraColors.bg2, borderRadius: BorderRadius.circular(AuroraRadius.lg), border: Border.all(color: AuroraColors.border, width: 1)),
                child: ListTile(
                  leading: Container(width: 44, height: 44, decoration: BoxDecoration(gradient: AuroraColors.gradientPrimary, borderRadius: BorderRadius.circular(AuroraRadius.sm)), child: Center(child: Text(c.name[0], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18)))),
                  title: Text(c.name, style: const TextStyle(fontWeight: FontWeight.w600, color: AuroraColors.text1)),
                  subtitle: Text(c.description ?? '', maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: AuroraColors.text3)),
                  trailing: Wrap(spacing: 4, children: c.tags.take(2).map((t) => Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: AuroraColors.primarySoft, borderRadius: BorderRadius.circular(AuroraRadius.full)), child: Text(t, style: const TextStyle(fontSize: 10, color: AuroraColors.primaryGlow)))).toList()),
                  onTap: () async { Navigator.pop(ctx); await _createFromPreset(c); },
                ),
              );
            },
          )),
        ]),
      ),
    );
  }

  Future<void> _createFromPreset(Character preset) async {
    try {
      final repo = ref.read(characterRepositoryProvider);
      final newChar = preset.copyWith(id: 'char_${DateTime.now().millisecondsSinceEpoch}', createdAt: null, updatedAt: null);
      await repo.createCharacter(newChar);
      ref.read(characterListProvider.notifier).loadCharacters();
      if (mounted) { ScaffoldMessenger.of(context).clearSnackBars(); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('已创建: ${newChar.name}'))); }
    } catch (e) {
      if (mounted) { ScaffoldMessenger.of(context).clearSnackBars(); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('创建失败，请重试'))); }
    }
  }

  Future<void> _importFromPng() async {
    try {
      final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['png']);
      if (result == null || result.files.isEmpty) return;
      final filePath = result.files.first.path;
      if (filePath == null) return;
      final repo = ref.read(characterRepositoryProvider);
      final character = await repo.importCharacterCard(filePath);
      await repo.createCharacter(character);
      ref.read(characterListProvider.notifier).loadCharacters();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('已导入: ${character.name}')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('导入失败，请检查文件格式')));
    }
  }

  // ── 状态 ──
  Widget _buildSkeleton() => GridView.builder(
    padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
    physics: const NeverScrollableScrollPhysics(),
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.75, crossAxisSpacing: 14, mainAxisSpacing: 14),
    itemCount: 6,
    itemBuilder: (_, __) => Container(decoration: BoxDecoration(color: AuroraColors.bg2, borderRadius: BorderRadius.circular(AuroraRadius.lg))),
  );

  Widget _buildEmpty() => Center(child: Padding(padding: const EdgeInsets.all(32), child: Column(mainAxisSize: MainAxisSize.min, children: [
    Container(width: 88, height: 88, decoration: BoxDecoration(shape: BoxShape.circle, color: AuroraColors.primarySoft), child: const Icon(Icons.people_alt_outlined, size: 36, color: AuroraColors.primaryGlow)),
    const SizedBox(height: 24),
    const Text('创建你的第一个角色', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AuroraColors.text1)),
    const SizedBox(height: 8),
    const Text('点击右下角按钮开始，或从模板快速创建', style: TextStyle(color: AuroraColors.text3, fontSize: 14), textAlign: TextAlign.center),
    const SizedBox(height: 28),
    FilledButton.icon(onPressed: _showPresetDialog, icon: const Icon(Icons.auto_awesome, size: 18), label: const Text('从模板创建')),
  ])));

  Widget _buildError(String e) => Center(child: Padding(padding: const EdgeInsets.all(32), child: Column(mainAxisSize: MainAxisSize.min, children: [
    Container(width: 64, height: 64, decoration: BoxDecoration(shape: BoxShape.circle, color: AuroraColors.rose.withOpacity(0.1)), child: const Icon(Icons.error_outline, size: 30, color: AuroraColors.rose)),
    const SizedBox(height: 16),
    Text(e, style: const TextStyle(color: AuroraColors.text2, fontSize: 14), textAlign: TextAlign.center),
    const SizedBox(height: 16),
    OutlinedButton.icon(onPressed: () => ref.read(characterListProvider.notifier).loadCharacters(), icon: const Icon(Icons.refresh, size: 18), label: const Text('重试')),
  ])));
}

class _PressableCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  const _PressableCard({required this.child, this.onTap, this.onLongPress});
  @override State<_PressableCard> createState() => _PressableCardState();
}

class _PressableCardState extends State<_PressableCard> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  @override void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 120), reverseDuration: const Duration(milliseconds: 200));
    _scale = Tween<double>(begin: 1, end: 0.95).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
  }
  @override void dispose() { _ctrl.dispose(); super.dispose(); }

  @override Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) { _ctrl.reverse(); widget.onTap?.call(); },
      onTapCancel: () => _ctrl.reverse(),
      onLongPress: widget.onLongPress,
      child: AnimatedBuilder(animation: _scale, builder: (context, child) => Transform.scale(scale: _scale.value, child: child), child: widget.child),
    );
  }
}
