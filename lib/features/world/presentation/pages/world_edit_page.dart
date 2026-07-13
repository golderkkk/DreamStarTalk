import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dream_startalk/core/theme/aurora_theme.dart';
import 'package:dream_startalk/shared/widgets/app_loading.dart';
import '../../domain/entities/world.dart';
import '../providers/world_provider.dart';
import '../widgets/npc_edit_dialog.dart';
import '../widgets/scene_edit_dialog.dart';
import 'npc_library_page.dart';

class WorldEditPage extends ConsumerStatefulWidget {
  final String? worldId;
  const WorldEditPage({super.key, this.worldId});
  @override ConsumerState<WorldEditPage> createState() => _WorldEditPageState();
}

class _WorldEditPageState extends ConsumerState<WorldEditPage> with SingleTickerProviderStateMixin {
  late TabController _tabs;
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController(), _desc = TextEditingController(), _rules = TextEditingController(), _history = TextEditingController();
  bool get isNew => widget.worldId == null;

  @override void initState() { super.initState(); _tabs = TabController(length: 4, vsync: this); if (!isNew) Future.microtask(() => ref.read(worldEditProvider(widget.worldId!).notifier).loadWorld(widget.worldId!)); }
  @override void dispose() { _tabs.dispose(); _name.dispose(); _desc.dispose(); _rules.dispose(); _history.dispose(); super.dispose(); }

  Future<void> _pickCover() async {
    final p = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 1024, maxHeight: 576);
    if (p != null && !isNew) ref.read(worldEditProvider(widget.worldId!).notifier).updateWorldInfo(coverImage: p.path);
  }

  Future<void> _create() async {
    if (!_formKey.currentState!.validate()) return;
    try {
      final w = World(id: 'world_${DateTime.now().millisecondsSinceEpoch}', name: _name.text, description: _desc.text.isEmpty ? null : _desc.text, rules: _rules.text.isEmpty ? null : _rules.text, history: _history.text.isEmpty ? null : _history.text);
      final saved = await ref.read(worldRepositoryProvider).createWorld(w);
      if (mounted) { ref.read(worldListProvider.notifier).loadWorlds(); ScaffoldMessenger.of(context).clearSnackBars(); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('已创建'))); context.replace('/worlds/${saved.id}'); }
    } catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('创建失败，请重试'))); }
  }

  @override Widget build(BuildContext context) {
    if (isNew) return _newWorld();
    final state = ref.watch(worldEditProvider(widget.worldId!));
    return Scaffold(
      backgroundColor: AuroraColors.bg0,
      appBar: AppBar(
        title: const Text('编辑世界观'),
        actions: [if (state.isDirty) TextButton(onPressed: state.isSaving ? null : () => ref.read(worldEditProvider(widget.worldId!).notifier).saveWorld(), child: state.isSaving ? const AppButtonLoading() : const Text('保存'))],
        bottom: TabBar(
          controller: _tabs,
          tabs: const [
            Tab(text: '信息', icon: Icon(Icons.info_outline, size: 18)),
            Tab(text: '场景', icon: Icon(Icons.location_on_outlined, size: 18)),
            Tab(text: 'NPC', icon: Icon(Icons.people_outline, size: 18)),
            Tab(text: '剧情', icon: Icon(Icons.auto_stories, size: 18)),
          ],
        ),
      ),
      body: state.isLoading
          ? const AppLoadingScreen(message: '加载世界观...')
          : state.error != null
              ? Center(child: Text(state.error!, style: const TextStyle(color: AuroraColors.error)))
              : state.world != null
                  ? TabBarView(controller: _tabs, children: [
                      _infoTab(state.world!),
                      _scenesTab(state.world!),
                      _npcsTab(state.world!),
                      _storylinesTab(state.world!),
                    ])
                  : const Center(child: Text('未找到世界')),
    );
  }

  Widget _newWorld() => Scaffold(
    appBar: AppBar(title: const Text('创建世界观'), actions: [TextButton(onPressed: _create, child: const Text('创建'))]),
    body: Form(key: _formKey, child: ListView(padding: const EdgeInsets.all(20), children: [
      _sect('基本信息'),
      TextFormField(controller: _name, decoration: const InputDecoration(labelText: '世界名称 *'), validator: (v) => v == null || v.trim().isEmpty ? '必填' : null), const SizedBox(height: 14),
      TextFormField(controller: _desc, decoration: const InputDecoration(labelText: '世界描述', hintText: '描述这个世界的背景'), maxLines: 5), const SizedBox(height: 28),
      _sect('世界规则'), TextFormField(controller: _rules, decoration: const InputDecoration(labelText: '世界规则', hintText: '如：魔法世界的法则'), maxLines: 3), const SizedBox(height: 14),
      TextFormField(controller: _history, decoration: const InputDecoration(labelText: '世界历史', hintText: '这个世界的历史背景'), maxLines: 3), const SizedBox(height: 40),
      FilledButton(onPressed: _create, child: const Text('创建世界观')),
    ])),
  );

  Widget _sect(String t) => Padding(padding: const EdgeInsets.only(bottom: 12), child: Text(t, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AuroraColors.text1)));

  Widget _infoTab(World w) => ListView(padding: const EdgeInsets.all(20), children: [
    GestureDetector(onTap: _pickCover, child: Container(height: 180, decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), color: AuroraColors.bg2), child: w.hasCoverImage ? ClipRRect(borderRadius: BorderRadius.circular(16), child: Image.network(w.coverImage!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _coverPlaceholder())) : _coverPlaceholder())),
    const SizedBox(height: 12), TextButton.icon(onPressed: _pickCover, icon: const Icon(Icons.image), label: const Text('更换封面')),
    const SizedBox(height: 28),
    _sect('基本信息'),
    TextFormField(initialValue: w.name, decoration: const InputDecoration(labelText: '世界名称'), onChanged: (v) => ref.read(worldEditProvider(widget.worldId!).notifier).updateWorldInfo(name: v)), const SizedBox(height: 14),
    TextFormField(initialValue: w.description, decoration: const InputDecoration(labelText: '世界描述'), maxLines: 5, onChanged: (v) => ref.read(worldEditProvider(widget.worldId!).notifier).updateWorldInfo(description: v)), const SizedBox(height: 28),
    _sect('世界规则'), TextFormField(initialValue: w.rules, decoration: const InputDecoration(labelText: '世界规则'), maxLines: 3, onChanged: (v) => ref.read(worldEditProvider(widget.worldId!).notifier).updateWorldInfo(rules: v)), const SizedBox(height: 14),
    TextFormField(initialValue: w.history, decoration: const InputDecoration(labelText: '世界历史'), maxLines: 3, onChanged: (v) => ref.read(worldEditProvider(widget.worldId!).notifier).updateWorldInfo(history: v)),
  ]);

  Widget _coverPlaceholder() => Center(child: Column(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.image_outlined, size: 40, color: AuroraColors.text3), const SizedBox(height: 8), const Text('点击上传封面图', style: TextStyle(color: AuroraColors.text3))]));

  Widget _scenesTab(World w) {
    final notifier = ref.read(worldEditProvider(widget.worldId!).notifier);
    return w.scenes.isEmpty ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 72, height: 72, decoration: BoxDecoration(shape: BoxShape.circle, color: AuroraColors.cyan.withOpacity(0.1)), child: const Icon(Icons.location_on_outlined, size: 32, color: AuroraColors.cyan)),
      const SizedBox(height: 16), const Text('还没有场景', style: TextStyle(color: AuroraColors.text2)), const SizedBox(height: 24),
      FilledButton.icon(onPressed: () => showSceneEditDialog(context, worldNPCs: w.npcs, onSave: (s) => notifier.addScene(s)), icon: const Icon(Icons.add), label: const Text('添加场景')),
    ]))
    : Stack(children: [
      ListView.builder(padding: const EdgeInsets.all(16), itemCount: w.scenes.length, itemBuilder: (_, i) => GestureDetector(
        onTap: () => showSceneEditDialog(context, scene: w.scenes[i], worldNPCs: w.npcs, onSave: (s) => notifier.updateScene(s)),
        onLongPress: () => showModalBottomSheet(context: context, backgroundColor: AuroraColors.bg1, builder: (_) => SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(leading: const Icon(Icons.edit, color: AuroraColors.primary), title: const Text('编辑'), onTap: () { Navigator.pop(_); showSceneEditDialog(context, scene: w.scenes[i], worldNPCs: w.npcs, onSave: (s) => notifier.updateScene(s)); }),
          ListTile(leading: const Icon(Icons.check_circle, color: AuroraColors.success), title: const Text('设为当前场景'), onTap: () { Navigator.pop(_); notifier.setCurrentScene(w.scenes[i].id); }),
          ListTile(leading: const Icon(Icons.delete, color: AuroraColors.error), title: const Text('删除'), onTap: () { Navigator.pop(_); _confirmDelete('场景', () => notifier.deleteScene(w.scenes[i].id)); }),
        ]))),
        child: Container(margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: AuroraColors.bg2, borderRadius: BorderRadius.circular(16), border: Border.all(color: w.currentSceneId == w.scenes[i].id ? AuroraColors.primary.withOpacity(0.4) : Colors.white.withOpacity(0.04))), child: Row(children: [
          Container(width: 48, height: 48, decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: AuroraColors.cyan.withOpacity(0.15)), child: const Icon(Icons.location_on, color: AuroraColors.cyan, size: 24)),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(w.scenes[i].displayName, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AuroraColors.text1)),
            if (w.scenes[i].description != null) Text(w.scenes[i].description!, style: const TextStyle(fontSize: 13, color: AuroraColors.text3), maxLines: 2, overflow: TextOverflow.ellipsis),
          ])),
          if (w.currentSceneId == w.scenes[i].id) Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: AuroraColors.primary.withOpacity(0.2), borderRadius: BorderRadius.circular(8)), child: const Text('当前', style: TextStyle(fontSize: 11, color: AuroraColors.primaryGlow))),
        ])),
      )),
      Positioned(bottom: 80, right: 20, child: FloatingActionButton.small(onPressed: () => showSceneEditDialog(context, worldNPCs: w.npcs, onSave: (s) => notifier.addScene(s)), backgroundColor: AuroraColors.primary, child: const Icon(Icons.add))),
    ]);
  }

  Widget _npcsTab(World w) {
    final notifier = ref.read(worldEditProvider(widget.worldId!).notifier);
    return w.npcs.isEmpty ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 72, height: 72, decoration: BoxDecoration(shape: BoxShape.circle, color: AuroraColors.primary.withOpacity(0.1)), child: const Icon(Icons.people_outline, size: 32, color: AuroraColors.primary)),
      const SizedBox(height: 16), const Text('还没有 NPC', style: TextStyle(color: AuroraColors.text2)), const SizedBox(height: 24),
      FilledButton.icon(onPressed: () => showNPCEditDialog(context, onSave: (n) => notifier.addNPC(n)), icon: const Icon(Icons.add), label: const Text('添加 NPC')),
      const SizedBox(height: 12),
      OutlinedButton.icon(onPressed: () => _importFromLibrary(notifier), icon: const Icon(Icons.folder_open), label: const Text('从 NPC 库导入')),
    ]))
    : Stack(children: [
      ListView.builder(padding: const EdgeInsets.all(16), itemCount: w.npcs.length, itemBuilder: (_, i) => GestureDetector(
        onTap: () => showNPCEditDialog(context, npc: w.npcs[i], onSave: (n) => notifier.updateNPC(n)),
        onLongPress: () => showModalBottomSheet(context: context, backgroundColor: AuroraColors.bg1, builder: (_) => SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(leading: const Icon(Icons.edit, color: AuroraColors.primary), title: const Text('编辑'), onTap: () { Navigator.pop(_); showNPCEditDialog(context, npc: w.npcs[i], onSave: (n) => notifier.updateNPC(n)); }),
          ListTile(leading: const Icon(Icons.delete, color: AuroraColors.error), title: const Text('删除'), onTap: () { Navigator.pop(_); _confirmDelete('NPC', () => notifier.deleteNPC(w.npcs[i].id)); }),
        ]))),
        child: Container(margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: AuroraColors.bg2, borderRadius: BorderRadius.circular(16)), child: Row(children: [
          CircleAvatar(radius: 22, backgroundColor: AuroraColors.primary.withOpacity(0.2), child: Text(w.npcs[i].name.isNotEmpty ? w.npcs[i].name[0] : '?', style: const TextStyle(color: AuroraColors.primaryGlow))),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(w.npcs[i].displayName, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AuroraColors.text1)),
            if (w.npcs[i].description != null) Text(w.npcs[i].description!, style: const TextStyle(fontSize: 13, color: AuroraColors.text3), maxLines: 2, overflow: TextOverflow.ellipsis),
          ])),
          if (w.npcs[i].relationship != null) Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: AuroraColors.cyan.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Text(w.npcs[i].relationship!, style: const TextStyle(fontSize: 11, color: AuroraColors.cyan))),
        ])),
      )),
      Positioned(
        bottom: 80, right: 20,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          FloatingActionButton.small(heroTag: 'add_npc', onPressed: () => showNPCEditDialog(context, onSave: (n) => notifier.addNPC(n)), backgroundColor: AuroraColors.primary, child: const Icon(Icons.add)),
          const SizedBox(height: 12),
          FloatingActionButton.small(heroTag: 'import_npc', onPressed: () => _importFromLibrary(notifier), backgroundColor: AuroraColors.cyan, child: const Icon(Icons.folder_open)),
        ]),
      ),
    ]);
  }

  Widget _storylinesTab(World w) {
    final notifier = ref.read(worldEditProvider(widget.worldId!).notifier);
    return w.storylines.isEmpty ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 72, height: 72, decoration: BoxDecoration(shape: BoxShape.circle, color: AuroraColors.warning.withOpacity(0.1)), child: const Icon(Icons.auto_stories, size: 32, color: AuroraColors.warning)),
      const SizedBox(height: 16), const Text('还没有剧情', style: TextStyle(color: AuroraColors.text2)), const SizedBox(height: 24),
      FilledButton.icon(onPressed: () => _showStorylineDialog(context, null, notifier), icon: const Icon(Icons.add), label: const Text('添加剧情')),
    ]))
    : Stack(children: [
      ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: w.storylines.length,
        itemBuilder: (_, i) => _storylineItem(w.storylines[i], notifier),
      ),
      Positioned(bottom: 80, right: 20, child: FloatingActionButton.small(onPressed: () => _showStorylineDialog(context, null, notifier), backgroundColor: AuroraColors.primary, child: const Icon(Icons.add))),
    ]);
  }

  Widget _storylineItem(Storyline s, WorldEditNotifier notifier) {
    final sc = s.status == StorylineStatus.active ? AuroraColors.success : s.status == StorylineStatus.completed ? AuroraColors.info : AuroraColors.warning;
    return GestureDetector(
      onTap: () => _showStorylineDialog(context, s, notifier),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AuroraColors.bg2, borderRadius: BorderRadius.circular(16)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Text(s.title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AuroraColors.text1))),
            Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: AuroraColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Text(s.type.label, style: const TextStyle(fontSize: 11, color: AuroraColors.primaryGlow))),
            const SizedBox(width: 6),
            Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: sc.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Text(s.status.label, style: TextStyle(fontSize: 11, color: sc))),
          ]),
          if (s.description != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text(s.description!, style: const TextStyle(fontSize: 13, color: AuroraColors.text3), maxLines: 2)),
          Padding(padding: const EdgeInsets.only(top: 4), child: Text('${s.nodes.length} 个节点', style: const TextStyle(fontSize: 11, color: AuroraColors.text3))),
        ]),
      ),
    );
  }

  void _showStorylineDialog(BuildContext ctx, Storyline? sl, WorldEditNotifier notifier) {
    final title = TextEditingController(text: sl?.title ?? ''), desc = TextEditingController(text: sl?.description ?? '');
    var type = sl?.type ?? StorylineType.main, status = sl?.status ?? StorylineStatus.active;
    showDialog(context: context, builder: (_) => StatefulBuilder(builder: (_, ss) => AlertDialog(
      backgroundColor: AuroraColors.bg1,
      title: Text(sl == null ? '添加剧情' : '编辑剧情'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: title, decoration: const InputDecoration(labelText: '剧情标题')), const SizedBox(height: 12),
        TextField(controller: desc, decoration: const InputDecoration(labelText: '剧情描述'), maxLines: 3), const SizedBox(height: 12),
        DropdownButtonFormField<StorylineType>(value: type, decoration: const InputDecoration(labelText: '类型'), items: StorylineType.values.map((t) => DropdownMenuItem(value: t, child: Text(t.label))).toList(), onChanged: (v) => ss(() => type = v!)),
        if (sl != null) ...[const SizedBox(height: 12), DropdownButtonFormField<StorylineStatus>(value: status, decoration: const InputDecoration(labelText: '状态'), items: StorylineStatus.values.map((s) => DropdownMenuItem(value: s, child: Text(s.label))).toList(), onChanged: (v) => ss(() => status = v!))],
        if (sl != null) ...[
          const SizedBox(height: 16),
          Row(children: [
            const Text('剧情节点', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AuroraColors.text1)),
            const Spacer(),
            Text('${sl.nodes.length} 个', style: const TextStyle(fontSize: 12, color: AuroraColors.text3)),
            const SizedBox(width: 8),
            TextButton(onPressed: () { Navigator.pop(_); _showNodeManager(context, sl, notifier); }, child: const Text('管理')),
          ]),
        ],
      ]),
      actions: [
        if (sl != null) TextButton(onPressed: () { Navigator.pop(_); _confirmDelete('剧情线', () => notifier.deleteStoryline(sl.id)); }, style: TextButton.styleFrom(foregroundColor: AuroraColors.error), child: const Text('删除')),
        TextButton(onPressed: () => Navigator.pop(_), child: const Text('取消')),
        FilledButton(onPressed: () { if (title.text.trim().isEmpty) return; final s = Storyline(id: sl?.id ?? 'storyline_${DateTime.now().millisecondsSinceEpoch}', title: title.text.trim(), description: desc.text.trim().isEmpty ? null : desc.text.trim(), type: type, status: status, nodes: sl?.nodes ?? []); Navigator.pop(_); sl == null ? notifier.addStoryline(s) : notifier.updateStoryline(s); }, child: Text(sl == null ? '添加' : '保存')),
      ],
    )));
  }

  Future<void> _importFromLibrary(WorldEditNotifier notifier) async {
    final result = await Navigator.push<List<NPC>>(context, MaterialPageRoute(builder: (_) => const NPCLibraryPage(selectionMode: true)));
    if (result == null || result.isEmpty) return;
    for (final libNpc in result) {
      final newNpc = libNpc.copyWith(id: 'npc_${DateTime.now().millisecondsSinceEpoch}_${libNpc.id}');
      await notifier.addNPC(newNpc);
    }
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('已导入 ${result.length} 个 NPC')));
  }

  void _showNodeManager(BuildContext ctx, Storyline sl, WorldEditNotifier notifier) {
    showDialog(context: context, builder: (_) => StatefulBuilder(builder: (_, ss) => AlertDialog(
      backgroundColor: AuroraColors.bg1,
      title: Text('节点管理 - ${sl.title}'),
      content: SizedBox(
        width: double.maxFinite,
        child: sl.nodes.isEmpty
          ? Padding(padding: const EdgeInsets.symmetric(vertical: 24), child: Column(children: [const Icon(Icons.route, size: 40, color: AuroraColors.text3), const SizedBox(height: 12), const Text('还没有节点', style: TextStyle(color: AuroraColors.text3))]))
          : ListView.builder(shrinkWrap: true, itemCount: sl.nodes.length, itemBuilder: (_, i) {
              final node = sl.nodes[i];
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AuroraColors.bg2, borderRadius: BorderRadius.circular(12)),
                child: Row(children: [
                  Container(width: 32, height: 32, decoration: BoxDecoration(color: AuroraColors.primary.withOpacity(0.15), borderRadius: BorderRadius.circular(8)), child: Center(child: Text('${i + 1}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AuroraColors.primary)))),
                  const SizedBox(width: 10),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(node.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AuroraColors.text1)),
                    Text(node.type.label, style: const TextStyle(fontSize: 11, color: AuroraColors.text3)),
                  ])),
                  IconButton(icon: const Icon(Icons.edit, size: 18, color: AuroraColors.primary), onPressed: () { Navigator.pop(_); _showNodeEditor(context, sl, node, notifier); }),
                  IconButton(icon: const Icon(Icons.delete, size: 18, color: AuroraColors.error), onPressed: () { final updated = List<StoryNode>.from(sl.nodes)..removeAt(i); notifier.updateStoryline(sl.copyWith(nodes: updated)); }),
                ]),
              );
            }),
      ),
      actions: [
        OutlinedButton.icon(onPressed: () { Navigator.pop(_); _showNodeEditor(context, sl, null, notifier); }, icon: const Icon(Icons.add, size: 16), label: const Text('添加节点')),
        const SizedBox(width: 8),
        FilledButton(onPressed: () => Navigator.pop(_), child: const Text('完成')),
      ],
    )));
  }

  void _showNodeEditor(BuildContext ctx, Storyline sl, StoryNode? node, WorldEditNotifier notifier) {
    final nameCtrl = TextEditingController(text: node?.title ?? ''), contentCtrl = TextEditingController(text: node?.content ?? '');
    var type = node?.type ?? StoryNodeType.dialogue;
    showDialog(context: context, builder: (_) => StatefulBuilder(builder: (_, ss) => AlertDialog(
      backgroundColor: AuroraColors.bg1,
      title: Text(node == null ? '添加节点' : '编辑节点'),
      content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: '节点标题', hintText: '如：初入城堡')), const SizedBox(height: 12),
        DropdownButtonFormField<StoryNodeType>(value: type, decoration: const InputDecoration(labelText: '节点类型'), items: StoryNodeType.values.map((t) => DropdownMenuItem(value: t, child: Text(t.label))).toList(), onChanged: (v) => ss(() => type = v!)), const SizedBox(height: 12),
        TextField(controller: contentCtrl, decoration: const InputDecoration(labelText: '节点内容', hintText: '描述此节点发生的内容...'), maxLines: 4),
      ])),
      actions: [
        TextButton(onPressed: () => Navigator.pop(_), child: const Text('取消')),
        FilledButton(onPressed: () {
          if (nameCtrl.text.trim().isEmpty) return;
          final newNode = StoryNode(id: node?.id ?? 'node_${DateTime.now().millisecondsSinceEpoch}', title: nameCtrl.text.trim(), content: contentCtrl.text.trim().isEmpty ? null : contentCtrl.text.trim(), type: type);
          if (node == null) {
            sl.nodes.add(newNode);
          } else {
            final idx = sl.nodes.indexWhere((n) => n.id == node.id);
            if (idx >= 0) sl.nodes[idx] = newNode;
          }
          notifier.updateStoryline(sl);
          Navigator.pop(_);
        }, child: const Text('保存')),
      ],
    )));
  }

  void _confirmDelete(String itemName, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('删除$itemName'),
        content: Text('确定删除此$itemName？此操作无法撤销。'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(_), child: const Text('取消')),
          TextButton(
            onPressed: () { Navigator.pop(_); onConfirm(); },
            style: TextButton.styleFrom(foregroundColor: AuroraColors.error),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }
}
