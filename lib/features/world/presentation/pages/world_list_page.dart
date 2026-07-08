import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:dream_startalk/core/theme/aurora_theme.dart';
import 'package:dream_startalk/shared/data/preset_data.dart';
import '../../domain/entities/world.dart';
import '../../../character/presentation/providers/character_provider.dart';
import '../../../character/data/repositories/character_repository_impl.dart';
import '../providers/world_provider.dart';
import '../../../chat/presentation/providers/chat_provider.dart';

class WorldListPage extends ConsumerStatefulWidget {
  const WorldListPage({super.key});
  @override ConsumerState<WorldListPage> createState() => _State();
}

class _State extends ConsumerState<WorldListPage> with TickerProviderStateMixin {
  final _search = TextEditingController();
  late final AnimationController _staggerCtrl;
  bool _staggerStarted = false;
  bool _searching = false;

  @override void initState() {
    super.initState();
    _staggerCtrl = AnimationController(vsync: this, duration: AuroraDuration.slow);
    Future.microtask(() => ref.read(worldListProvider.notifier).loadWorlds());
  }
  @override void dispose() { _search.dispose(); _staggerCtrl.dispose(); super.dispose(); }

  void _startStagger() {
    if (!_staggerStarted) { _staggerStarted = true; _staggerCtrl.forward(); }
  }

  @override Widget build(BuildContext context) {
    final s = ref.watch(worldListProvider);
    if (!s.isLoading && s.error == null && s.worlds.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _startStagger());
    }
    return Scaffold(
      backgroundColor: AuroraColors.bg0,
      body: Column(children: [
        _buildHeader(s),
        if (_searching) _buildSearchBar(),
        Expanded(child: s.isLoading ? _buildSkeleton() : s.error != null ? _buildError(s.error!) : s.worlds.isEmpty ? _buildEmpty() : _buildGrid(s)),
      ]),
      floatingActionButton: _buildFAB(),
    );
  }

  Widget _buildHeader(WorldListState s) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 12, 20, 4),
      child: Row(children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('世界观', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: AuroraColors.text1, letterSpacing: -0.8)),
          if (!s.isLoading && s.worlds.isNotEmpty)
            Text('${s.worlds.length} 个世界观', style: const TextStyle(fontSize: 12, color: AuroraColors.text3)),
        ]),
        const Spacer(),
        _iconBtn(_searching ? Icons.close : Icons.search, () {
          setState(() { _searching = !_searching; if (!_searching) { _search.clear(); ref.read(worldListProvider.notifier).loadWorlds(); } });
        }),
        const SizedBox(width: 6),
        _iconBtn(Icons.auto_awesome, _showPresetDialog, tooltip: '预设世界观'),
        const SizedBox(width: 6),
        _iconBtn(Icons.upload_file, _importFromPng, tooltip: '导入世界观'),
      ]),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: TextField(
        controller: _search,
        style: const TextStyle(color: AuroraColors.text1, fontSize: 15),
        decoration: InputDecoration(
          hintText: '搜索世界观...',
          prefixIcon: const Icon(Icons.search, size: 20, color: AuroraColors.text3),
          suffixIcon: _search.text.isNotEmpty
              ? GestureDetector(
                  onTap: () { _search.clear(); ref.read(worldListProvider.notifier).loadWorlds(); },
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
        onChanged: (q) => ref.read(worldListProvider.notifier).searchWorlds(q),
      ),
    );
  }

  Widget _buildGrid(WorldListState s) {
    return RefreshIndicator(
      color: AuroraColors.primary,
      backgroundColor: AuroraColors.bg3,
      onRefresh: () async { _staggerStarted = false; _staggerCtrl.reset(); await ref.read(worldListProvider.notifier).loadWorlds(); },
      child: GridView.builder(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.75, crossAxisSpacing: 14, mainAxisSpacing: 14),
        itemCount: s.worlds.length,
        itemBuilder: (_, i) => _staggeredCard(s.worlds[i], i),
      ),
    );
  }

  Widget _staggeredCard(World w, int index) {
    final delay = (index * 0.06).clamp(0.0, 0.5);
    final slide = Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero).animate(CurvedAnimation(parent: _staggerCtrl, curve: Interval(delay, (delay + 0.35).clamp(0.0, 1.0), curve: Curves.easeOutCubic)));
    final fade = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _staggerCtrl, curve: Interval(delay, (delay + 0.25).clamp(0.0, 1.0), curve: Curves.easeOut)));
    return AnimatedBuilder(
      key: ValueKey(w.id),
      animation: _staggerCtrl,
      builder: (context, child) => FadeTransition(opacity: fade, child: SlideTransition(position: slide, child: child)),
      child: _card(w),
    );
  }

  Widget _card(World w) {
    return _PressableCard(
      onTap: () => context.push('/worlds/${w.id}'),
      onLongPress: () => _showMenu(w),
      child: Container(
        decoration: BoxDecoration(
          color: AuroraColors.bg2,
          borderRadius: BorderRadius.circular(AuroraRadius.lg),
          border: Border.all(color: AuroraColors.border, width: 1),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(children: [
          // 封面区域
          Container(
            height: 120,
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [AuroraColors.cyan, AuroraColors.primary], begin: Alignment.topLeft, end: Alignment.bottomRight),
            ),
            child: Stack(children: [
              Positioned.fill(child: DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.transparent, AuroraColors.bg2.withOpacity(0.7)], begin: Alignment.topCenter, end: Alignment.bottomCenter, stops: const [0.3, 1.0])))),
              Positioned(left: 10, bottom: 8, child: Text(w.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white, shadows: [Shadow(color: Colors.black54, blurRadius: 6)]), maxLines: 1, overflow: TextOverflow.ellipsis)),
            ]),
          ),
          // 信息区
          Expanded(child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(w.summary, style: const TextStyle(fontSize: 11, color: AuroraColors.text3), maxLines: 2, overflow: TextOverflow.ellipsis),
              const Spacer(),
              Row(children: [
                _stat(Icons.location_on_outlined, '${w.scenes.length}'),
                const SizedBox(width: 10),
                _stat(Icons.people_outline, '${w.npcs.length}'),
              ]),
            ]),
          )),
        ]),
      ),
    );
  }

  Widget _stat(IconData icon, String text) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 13, color: AuroraColors.cyan.withOpacity(0.7)),
      const SizedBox(width: 4),
      Text(text, style: const TextStyle(fontSize: 11, color: AuroraColors.text3, fontWeight: FontWeight.w500)),
    ]);
  }

  Widget _buildFAB() {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(AuroraRadius.lg), gradient: LinearGradient(colors: [AuroraColors.cyan, AuroraColors.primary], begin: Alignment.topLeft, end: Alignment.bottomRight), boxShadow: [BoxShadow(color: AuroraColors.cyan.withOpacity(0.35), blurRadius: 20, offset: const Offset(0, 6))]),
      child: FloatingActionButton(
        onPressed: () => context.push('/worlds/new'),
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

  void _showMenu(World w) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AuroraColors.bg4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(AuroraRadius.xxl))),
      builder: (_) => SafeArea(child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 36, height: 4, margin: const EdgeInsets.only(bottom: 12), decoration: BoxDecoration(color: AuroraColors.text4, borderRadius: BorderRadius.circular(2))),
          _menuItem(Icons.edit_outlined, '编辑世界观', AuroraColors.primary, () { Navigator.pop(_); context.push('/worlds/${w.id}'); }),
          _menuItem(Icons.ios_share, '导出为 JSON', AuroraColors.info, () { Navigator.pop(_); _exportWorld(w.id); }),
          _menuItem(Icons.chat_bubble_outline, '开始对话', AuroraColors.cyan, () { Navigator.pop(_); _startChat(w); }),
          const Divider(indent: 20, endIndent: 20),
          _menuItem(Icons.delete_outline, '删除世界观', AuroraColors.rose, () { Navigator.pop(_); _deleteWorld(w.id); }),
        ]),
      )),
    );
  }

  Widget _menuItem(IconData icon, String title, Color color, VoidCallback onTap) {
    return ListTile(leading: Icon(icon, color: color, size: 22), title: Text(title, style: const TextStyle(fontSize: 15, color: AuroraColors.text1)), onTap: onTap);
  }

  Future<void> _startChat(World w) async {
    try {
      final charState = ref.read(characterListProvider);
      if (charState.characters.isEmpty) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('请先创建角色')));
        return;
      }
      final c = charState.characters.first;
      final conv = await ref.read(conversationListProvider.notifier).quickCreateConversation(character: c, worldId: w.id, worldName: w.name);
      if (mounted) context.go('/chat/${conv.id}');
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('创建失败，请重试')));
    }
  }

  void _showPresetDialog() {
    final presets = PresetWorlds.all;
    showModalBottomSheet(
      context: context, isScrollControlled: true,
      backgroundColor: AuroraColors.bg4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(AuroraRadius.xxl))),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.75, minChildSize: 0.3, maxChildSize: 0.9, expand: false,
        builder: (ctx, scrollCtrl) => Column(children: [
          Container(width: 36, height: 4, margin: const EdgeInsets.only(top: 12, bottom: 16), decoration: BoxDecoration(color: AuroraColors.text4, borderRadius: BorderRadius.circular(2))),
          const Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: Row(children: [
            Icon(Icons.auto_awesome, color: AuroraColors.cyan, size: 20), SizedBox(width: 8),
            Text('预设世界观', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AuroraColors.text1)),
          ])),
          const SizedBox(height: 8),
          Expanded(child: ListView.builder(
            controller: scrollCtrl, padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: presets.length,
            itemBuilder: (ctx, i) {
              final w = presets[i];
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(color: AuroraColors.bg2, borderRadius: BorderRadius.circular(AuroraRadius.lg), border: Border.all(color: AuroraColors.border, width: 1)),
                child: ListTile(
                  leading: Container(width: 44, height: 44, decoration: BoxDecoration(gradient: LinearGradient(colors: [AuroraColors.cyan, AuroraColors.primary], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(AuroraRadius.sm)), child: const Center(child: Icon(Icons.public, color: Colors.white, size: 20))),
                  title: Text(w.name, style: const TextStyle(fontWeight: FontWeight.w600, color: AuroraColors.text1)),
                  subtitle: Text(w.description ?? '', maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: AuroraColors.text3)),
                  onTap: () async { Navigator.pop(ctx); await _createFromPreset(w); },
                ),
              );
            },
          )),
        ]),
      ),
    );
  }

  Future<void> _createFromPreset(World preset) async {
    try {
      final repo = ref.read(worldRepositoryProvider);
      final newWorld = preset.copyWith(id: 'world_${DateTime.now().millisecondsSinceEpoch}', createdAt: null, updatedAt: null);
      await repo.createWorld(newWorld);
      ref.read(worldListProvider.notifier).loadWorlds();
      if (mounted) { ScaffoldMessenger.of(context).clearSnackBars(); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('已创建: ${newWorld.name}'))); }
    } catch (e) {
      if (mounted) { ScaffoldMessenger.of(context).clearSnackBars(); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('创建失败，请重试'))); }
    }
  }

  Future<void> _exportWorld(String id) async {
    try {
      final w = await ref.read(worldRepositoryProvider).getWorld(id);
      if (w == null) return;
      final dir = await getApplicationDocumentsDirectory();
      final exportDir = Directory('${dir.path}/exports');
      if (!await exportDir.exists()) await exportDir.create(recursive: true);
      final fileName = '${w.name.replaceAll(RegExp(r'[\\/*?:"<>|]'), '_')}_world.json';
      final file = File('${exportDir.path}/$fileName');
      await file.writeAsString(const JsonEncoder.withIndent('  ').convert(w.toJson()));
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('已导出: ${w.name}_world.json')));
        await Share.shareXFiles([XFile(file.path)], subject: '${w.name} - 世界观');
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('导出失败')));
    }
  }

  Future<void> _deleteWorld(String id) async {
    showDialog(context: context, builder: (_) => AlertDialog(
      backgroundColor: AuroraColors.bg4,
      title: const Text('确认删除'), content: const Text('删除后无法恢复，确定继续？'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(_), child: const Text('取消')),
        TextButton(onPressed: () async { Navigator.pop(_); await ref.read(worldRepositoryProvider).deleteWorld(id); ref.read(worldListProvider.notifier).loadWorlds(); }, style: TextButton.styleFrom(foregroundColor: AuroraColors.rose), child: const Text('删除')),
      ],
    ));
  }

  Future<void> _importFromPng() async {
    try {
      final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['png']);
      if (result == null || result.files.isEmpty) return;
      final filePath = result.files.first.path;
      if (filePath == null) return;
      final charRepo = ref.read(characterRepositoryProvider);
      final world = charRepo is CharacterRepositoryImpl ? await charRepo.importWorldbookFromPng(filePath) : null;
      if (world != null) {
        await ref.read(worldRepositoryProvider).createWorld(world);
        ref.read(worldListProvider.notifier).loadWorlds();
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('已导入: ${world.name}')));
      } else {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('该文件中未找到世界书数据')));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('导入失败，请检查文件格式')));
    }
  }

  // ── 状态 ──
  Widget _buildSkeleton() => ListView.builder(
    padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
    physics: const NeverScrollableScrollPhysics(),
    itemCount: 4,
    itemBuilder: (_, __) => Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Container(height: 160, decoration: BoxDecoration(color: AuroraColors.bg2, borderRadius: BorderRadius.circular(AuroraRadius.lg))),
    ),
  );

  Widget _buildEmpty() => Center(child: Padding(padding: const EdgeInsets.all(32), child: Column(mainAxisSize: MainAxisSize.min, children: [
    Container(width: 88, height: 88, decoration: BoxDecoration(shape: BoxShape.circle, color: AuroraColors.cyan.withOpacity(0.1)), child: const Icon(Icons.public_outlined, size: 36, color: AuroraColors.cyan)),
    const SizedBox(height: 24),
    const Text('创建你的第一个世界观', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AuroraColors.text1)),
    const SizedBox(height: 8),
    const Text('构建丰富的世界观设定，让对话更加沉浸', style: TextStyle(color: AuroraColors.text3, fontSize: 14), textAlign: TextAlign.center),
    const SizedBox(height: 28),
    FilledButton.icon(onPressed: () => context.push('/worlds/new'), icon: const Icon(Icons.add, size: 18), label: const Text('创建世界观')),
  ])));

  Widget _buildError(String e) => Center(child: Padding(padding: const EdgeInsets.all(32), child: Column(mainAxisSize: MainAxisSize.min, children: [
    Container(width: 64, height: 64, decoration: BoxDecoration(shape: BoxShape.circle, color: AuroraColors.rose.withOpacity(0.1)), child: const Icon(Icons.error_outline, size: 30, color: AuroraColors.rose)),
    const SizedBox(height: 16),
    Text(e, style: const TextStyle(color: AuroraColors.text2, fontSize: 14), textAlign: TextAlign.center),
    const SizedBox(height: 16),
    OutlinedButton.icon(onPressed: () => ref.read(worldListProvider.notifier).loadWorlds(), icon: const Icon(Icons.refresh, size: 18), label: const Text('重试')),
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
    _scale = Tween<double>(begin: 1, end: 0.97).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
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
