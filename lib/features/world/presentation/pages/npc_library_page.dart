import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dream_startalk/core/theme/aurora_theme.dart';

import 'package:dream_startalk/shared/widgets/app_loading.dart';
import '../../domain/entities/world.dart';
import '../providers/npc_library_provider.dart';
import '../widgets/npc_edit_dialog.dart';

/// NPC 库页面 - 独立的共享 NPC 池
class NPCLibraryPage extends ConsumerStatefulWidget {
  final bool selectionMode;
  const NPCLibraryPage({super.key, this.selectionMode = false});

  @override ConsumerState<NPCLibraryPage> createState() => _NPCLibraryPageState();
}

class _NPCLibraryPageState extends ConsumerState<NPCLibraryPage> {
  final _search = TextEditingController(); bool _searching = false;
  final _selected = <String>{};

  @override void initState() { super.initState(); Future.microtask(() => ref.read(npcLibraryProvider.notifier).load()); }
  @override void dispose() { _search.dispose(); super.dispose(); }

  @override Widget build(BuildContext context) {
    final s = ref.watch(npcLibraryProvider);
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: _searching ? TextField(controller: _search, autofocus: true, style: const TextStyle(color: AuroraColors.text1), decoration: const InputDecoration(hintText: '搜索 NPC...', border: InputBorder.none), onChanged: (q) => ref.read(npcLibraryProvider.notifier).search(q)) : const Text('NPC 库'),
        actions: [
          if (widget.selectionMode && _selected.isNotEmpty)
            TextButton(onPressed: () { Navigator.pop(context, s.npcs.where((n) => _selected.contains(n.id)).toList()); }, child: Text('导入 (${_selected.length})')),
          IconButton(icon: Icon(_searching ? Icons.close : Icons.search, size: 22, color: AuroraColors.text2), onPressed: () { setState(() => _searching = !_searching); if (!_searching) { _search.clear(); ref.read(npcLibraryProvider.notifier).load(); } }),
        ],
      ),
      body: s.isLoading ? const AppLoadingScreen(message: '加载 NPC 库...')
        : s.error != null ? Center(child: Text(s.error!, style: const TextStyle(color: AuroraColors.error)))
        : s.npcs.isEmpty ? _empty()
        : _list(s),
      floatingActionButton: widget.selectionMode ? null : FloatingActionButton(onPressed: () {
        showNPCEditDialog(context, onSave: (npc) => ref.read(npcLibraryProvider.notifier).add(npc));
      }, backgroundColor: AuroraColors.primary, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)), child: const Icon(Icons.add, color: Colors.white)),
    );
  }

  Widget _empty() => Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
    Container(width: 96, height: 96, decoration: BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: [AuroraColors.primary.withOpacity(0.12), AuroraColors.primary.withOpacity(0.04)], begin: Alignment.topCenter, end: Alignment.bottomCenter)), child: const Icon(Icons.people_outline, size: 40, color: AuroraColors.primaryGlow)),
    const SizedBox(height: 28), Text('NPC 库为空', style: Theme.of(context).textTheme.headlineMedium),
    const SizedBox(height: 8), const Text('添加 NPC 后可在多个世界中复用', style: TextStyle(color: AuroraColors.text3, fontSize: 14)),
  ]));

  Widget _list(state) => RefreshIndicator(color: AuroraColors.primary, onRefresh: () => ref.read(npcLibraryProvider.notifier).load(),
    child: ListView.builder(padding: const EdgeInsets.all(16), itemCount: state.npcs.length, itemBuilder: (_, i) => _tile(state.npcs[i])),
  );

  Widget _tile(NPC n) {
    final isSel = _selected.contains(n.id);
    return GestureDetector(
      onTap: widget.selectionMode
        ? () { setState(() { if (isSel) _selected.remove(n.id); else _selected.add(n.id); }); }
        : () => showNPCEditDialog(context, npc: n, onSave: (updated) => ref.read(npcLibraryProvider.notifier).update(updated)),
      onLongPress: widget.selectionMode ? null : () => _menu(n),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSel ? AuroraColors.primary.withOpacity(0.1) : AuroraColors.bg2,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSel ? AuroraColors.primary.withOpacity(0.4) : AuroraColors.border.withOpacity(0.3), width: isSel ? 1.5 : 0.5),
        ),
        child: Row(children: [
          Container(width: 44, height: 44, decoration: BoxDecoration(gradient: AuroraColors.gradientPrimary, borderRadius: BorderRadius.circular(44 / 3)), child: Center(child: Text(n.name.isNotEmpty ? n.name[0].toUpperCase() : '?', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)))),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(n.displayName, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AuroraColors.text1)),
            if (n.description != null && n.description!.isNotEmpty) Text(n.description!, style: const TextStyle(fontSize: 12, color: AuroraColors.text3), maxLines: 2, overflow: TextOverflow.ellipsis),
            if (n.tags.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 4), child: Wrap(spacing: 4, children: n.tags.map((t) => Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: AuroraColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(5)), child: Text(t, style: const TextStyle(fontSize: 10, color: AuroraColors.primaryGlow)))).toList())),
          ])),
          if (isSel) const Icon(Icons.check_circle, color: AuroraColors.primary, size: 24),
          if (!widget.selectionMode) const Icon(Icons.chevron_right, color: AuroraColors.text3, size: 20),
        ]),
      ),
    );
  }

  void _menu(NPC n) => showModalBottomSheet(context: context, backgroundColor: AuroraColors.bg1, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))), builder: (_) => SafeArea(child: Padding(padding: const EdgeInsets.only(bottom: 16), child: Column(mainAxisSize: MainAxisSize.min, children: [
    Container(width: 36, height: 4, margin: const EdgeInsets.only(bottom: 8), decoration: BoxDecoration(color: AuroraColors.text3.withOpacity(0.3), borderRadius: BorderRadius.circular(2))),
    ListTile(leading: const Icon(Icons.edit_outlined, color: AuroraColors.primary, size: 22), title: const Text('编辑'), onTap: () { Navigator.pop(_); showNPCEditDialog(context, npc: n, onSave: (updated) => ref.read(npcLibraryProvider.notifier).update(updated)); }),
    ListTile(leading: const Icon(Icons.delete_outline, color: AuroraColors.error, size: 22), title: const Text('删除'), onTap: () { Navigator.pop(_); ref.read(npcLibraryProvider.notifier).remove(n.id); }),
  ]))));
}
