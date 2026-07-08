import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dream_startalk/core/theme/aurora_theme.dart';
import 'package:dream_startalk/features/settings/presentation/pages/settings_page.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/entities/protagonist.dart';
import '../providers/chat_provider.dart';
import '../../../character/domain/entities/character.dart';
import '../../../character/presentation/providers/character_provider.dart';
import '../../../world/domain/entities/world.dart';
import '../../../world/presentation/providers/world_provider.dart';

class CreateConversationPage extends ConsumerStatefulWidget {
  const CreateConversationPage({super.key});
  @override ConsumerState<CreateConversationPage> createState() => _CreateConversationPageState();
}

class _CustomField {
  final TextEditingController key;
  final TextEditingController value;
  _CustomField() : key = TextEditingController(), value = TextEditingController();
  void dispose() { key.dispose(); value.dispose(); }
}

class _CreateConversationPageState extends ConsumerState<CreateConversationPage> {
  final List<Character> _chars = []; // 多角色选择
  World? _world;
  final _pName = TextEditingController(), _pDesc = TextEditingController(), _pPersonality = TextEditingController();
  final _pAppearance = TextEditingController(), _pBackstory = TextEditingController();
  final _customFields = <_CustomField>[];
  bool _nsfw = false;
  int _step = 0;

  @override void initState() {
    super.initState();
    Future.microtask(() async {
      final charId = ref.read(preselectedCharacterIdProvider);
      if (charId != null) {
        final char = await ref.read(characterProvider(charId).future);
        if (char != null && mounted) setState(() => _chars.add(char));
        ref.read(preselectedCharacterIdProvider.notifier).state = null;
      }
      final worldId = ref.read(preselectedWorldIdProvider);
      if (worldId != null) {
        final world = await ref.read(worldProvider(worldId).future);
        if (world != null && mounted) setState(() => _world = world);
        ref.read(preselectedWorldIdProvider.notifier).state = null;
      }
    });
  }
  @override void dispose() { _pName.dispose(); _pDesc.dispose(); _pPersonality.dispose(); _pAppearance.dispose(); _pBackstory.dispose(); for (final f in _customFields) { f.dispose(); } super.dispose(); }

  void _next() { if (_step < 2) setState(() => _step++); }
  void _prev() { if (_step > 0) setState(() => _step--); }

  bool get _isMultiCharacter => _chars.length > 1;

  @override Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AuroraColors.bg0,
      appBar: AppBar(
        title: const Text('创建新对话'),
        actions: [
          if (_canCreate())
            TextButton(onPressed: _create, child: const Text('开始对话')),
        ],
      ),
      body: Column(
        children: [
          // Step indicator
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(children: List.generate(3, (i) => Expanded(child: Padding(padding: EdgeInsets.only(right: i < 2 ? 8 : 0), child: Column(children: [
              Container(height: 4, decoration: BoxDecoration(borderRadius: BorderRadius.circular(2), color: i <= _step ? AuroraColors.primary : AuroraColors.bg3)),
              const SizedBox(height: 6),
              Text(['选择角色', '选择世界观', '主角设置'][i], style: TextStyle(fontSize: 11, color: i <= _step ? AuroraColors.primary : AuroraColors.text4)),
            ]))))),
          ),
          // 已选角色提示
          if (_chars.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Row(children: [
                Icon(Icons.people, size: 16, color: AuroraColors.primary),
                const SizedBox(width: 6),
                Text('已选 ${_chars.length} 个角色${_isMultiCharacter ? "（多角色模式）" : ""}', style: TextStyle(fontSize: 12, color: _isMultiCharacter ? AuroraColors.primary : AuroraColors.text3)),
                const Spacer(),
                if (_chars.length > 1)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: AuroraColors.primarySoft, borderRadius: BorderRadius.circular(AuroraRadius.sm)),
                    child: const Text('多角色', style: TextStyle(fontSize: 11, color: AuroraColors.primaryGlow, fontWeight: FontWeight.w600)),
                  ),
              ]),
            ),
          Expanded(child: [_charStep(), _worldStep(), _protagonistStep()][_step]),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(children: [
              if (_step > 0) Expanded(child: OutlinedButton(onPressed: _prev, child: const Text('上一步'))),
              if (_step > 0) const SizedBox(width: 12),
              Expanded(child: FilledButton(
                onPressed: _step < 2 ? _next : (_canCreate() ? _create : null),
                child: Text(_step < 2 ? '下一步' : '开始对话${_isMultiCharacter ? "（多角色）" : ""}'),
              )),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _charStep() {
    final state = ref.watch(characterListProvider);
    return state.characters.isEmpty
        ? _emptyState(Icons.person_add, '还没有角色卡', '先去创建角色卡吧')
        : ListView(padding: const EdgeInsets.symmetric(horizontal: 20), children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: TextField(
                decoration: const InputDecoration(hintText: '搜索角色...', prefixIcon: Icon(Icons.search)),
                onChanged: (q) => ref.read(characterListProvider.notifier).searchCharacters(q),
              ),
            ),
            // 多角色提示
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AuroraColors.cyan.withOpacity(0.06),
                borderRadius: BorderRadius.circular(AuroraRadius.md),
                border: Border.all(color: AuroraColors.cyan.withOpacity(0.15), width: 0.5),
              ),
              child: Row(children: [
                Icon(Icons.info_outline, size: 16, color: AuroraColors.cyan),
                const SizedBox(width: 8),
                Expanded(child: Text('可选择多个角色进行多角色对话，点击角色卡片进行选择/取消', style: const TextStyle(fontSize: 12, color: AuroraColors.text3))),
              ]),
            ),
            ...state.characters.map((c) {
              final isSelected = _chars.any((sc) => sc.id == c.id);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _chars.removeWhere((sc) => sc.id == c.id);
                    } else {
                      _chars.add(c);
                    }
                  });
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isSelected ? AuroraColors.primarySoft : AuroraColors.bg2,
                    borderRadius: BorderRadius.circular(AuroraRadius.lg),
                    border: Border.all(
                      color: isSelected ? AuroraColors.borderPrimary : AuroraColors.border,
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Row(children: [
                    // 多选指示器
                    Container(
                      width: 24, height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected ? AuroraColors.primary : Colors.transparent,
                        border: Border.all(color: isSelected ? AuroraColors.primary : AuroraColors.text4, width: 1.5),
                      ),
                      child: isSelected ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
                    ),
                    const SizedBox(width: 12),
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: AuroraColors.primarySoft,
                      child: Text(c.name.isNotEmpty ? c.name[0] : '?', style: const TextStyle(color: AuroraColors.primaryGlow, fontWeight: FontWeight.w700)),
                    ),
                    const SizedBox(width: 14),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(c.name, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: isSelected ? AuroraColors.primaryGlow : AuroraColors.text1)),
                      const SizedBox(height: 4),
                      Text(c.summary, style: const TextStyle(fontSize: 12, color: AuroraColors.text3), maxLines: 2, overflow: TextOverflow.ellipsis),
                    ])),
                    // 选中序号
                    if (isSelected)
                      Container(
                        width: 24, height: 24,
                        decoration: const BoxDecoration(color: AuroraColors.primary, shape: BoxShape.circle),
                        child: Center(child: Text('${_chars.indexWhere((sc) => sc.id == c.id) + 1}', style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w700))),
                      ),
                  ]),
                ),
              );
            }),
          ]);
  }

  Widget _worldStep() {
    final state = ref.watch(worldListProvider);
    return ListView(padding: const EdgeInsets.symmetric(horizontal: 20), children: [
      GestureDetector(
        onTap: () { setState(() => _world = null); _next(); },
        child: Container(margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: _world == null ? AuroraColors.primarySoft : AuroraColors.bg2, borderRadius: BorderRadius.circular(AuroraRadius.lg), border: Border.all(color: _world == null ? AuroraColors.borderPrimary : AuroraColors.border)), child: Row(children: [
          const Icon(Icons.skip_next, color: AuroraColors.text3), const SizedBox(width: 12), const Expanded(child: Text('跳过，不使用世界观', style: TextStyle(color: AuroraColors.text2))),
          if (_world == null) const Icon(Icons.check_circle, color: AuroraColors.primary),
        ])),
      ),
      TextField(decoration: const InputDecoration(hintText: '搜索世界观...', prefixIcon: Icon(Icons.search)), onChanged: (q) => ref.read(worldListProvider.notifier).searchWorlds(q)),
      const SizedBox(height: 12),
      if (state.worlds.isEmpty)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Column(children: [
            Icon(Icons.public, size: 40, color: AuroraColors.text4.withOpacity(0.5)),
            const SizedBox(height: 12),
            Text('暂无世界观', style: const TextStyle(color: AuroraColors.text3, fontSize: 14)),
            const SizedBox(height: 4),
            Text('可以跳过此步，稍后在世界观页面创建', style: TextStyle(color: AuroraColors.text4, fontSize: 12)),
          ]),
        ),
      if (state.worlds.isNotEmpty)
        ...state.worlds.map((w) => GestureDetector(
          onTap: () => setState(() => _world = w),
          child: Container(margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: _world?.id == w.id ? AuroraColors.cyan.withOpacity(0.12) : AuroraColors.bg2, borderRadius: BorderRadius.circular(AuroraRadius.lg), border: Border.all(color: _world?.id == w.id ? AuroraColors.cyan.withOpacity(0.4) : AuroraColors.border)), child: Row(children: [
            const Icon(Icons.public, color: AuroraColors.cyan), const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(w.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AuroraColors.text1)), Text(w.summary, style: const TextStyle(fontSize: 12, color: AuroraColors.text3), maxLines: 2)])),
            if (_world?.id == w.id) const Icon(Icons.check_circle, color: AuroraColors.cyan),
          ])),
        )),
    ]);
  }

  Widget _protagonistStep() {
    return ListView(padding: const EdgeInsets.all(20), children: [
      Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: AuroraColors.primarySoft, borderRadius: BorderRadius.circular(AuroraRadius.md)), child: const Row(children: [Icon(Icons.info_outline, color: AuroraColors.primaryGlow, size: 20), SizedBox(width: 12), Expanded(child: Text('设置你在对话中的角色信息，AI 会根据这些信息与你互动', style: TextStyle(fontSize: 13, color: AuroraColors.text2)))])),
      const SizedBox(height: 24),
      TextFormField(controller: _pName, decoration: const InputDecoration(labelText: '你的称呼 *', hintText: '对话中 AI 如何称呼你', prefixIcon: Icon(Icons.person)), onChanged: (_) => setState(() {})), const SizedBox(height: 16),
      TextFormField(controller: _pDesc, decoration: const InputDecoration(labelText: '简介', hintText: '简单介绍一下自己'), maxLines: 2), const SizedBox(height: 16),
      TextFormField(controller: _pPersonality, decoration: const InputDecoration(labelText: '性格', hintText: '如：开朗、内向'), maxLines: 2), const SizedBox(height: 16),
      TextFormField(controller: _pAppearance, decoration: const InputDecoration(labelText: '外貌', hintText: '描述你的外貌特征'), maxLines: 2), const SizedBox(height: 16),
      TextFormField(controller: _pBackstory, decoration: const InputDecoration(labelText: '背景故事', hintText: '你的角色背景'), maxLines: 3), const SizedBox(height: 24),
      ..._customFields.asMap().entries.map((e) => Padding(padding: const EdgeInsets.only(bottom: 12), child: Row(children: [Expanded(flex: 2, child: TextFormField(controller: e.value.key, decoration: const InputDecoration(labelText: '字段名', isDense: true))), const SizedBox(width: 8), Expanded(flex: 3, child: TextFormField(controller: e.value.value, decoration: const InputDecoration(labelText: '字段值', isDense: true))), IconButton(onPressed: () { setState(() { e.value.dispose(); _customFields.removeAt(e.key); }); }, icon: const Icon(Icons.delete_outline, size: 20, color: AuroraColors.rose))]))),
      OutlinedButton.icon(onPressed: () => setState(() => _customFields.add(_CustomField())), icon: const Icon(Icons.add, size: 18), label: const Text('添加自定义字段')),
      const SizedBox(height: 24),
      if (NSFWUnlockState.unlocked)
      SwitchListTile(value: _nsfw, onChanged: (v) => setState(() => _nsfw = v), title: const Text('NSFW 模式'), subtitle: const Text('启用成人内容'), activeColor: AuroraColors.error, secondary: Icon(Icons.warning_amber, color: _nsfw ? AuroraColors.error : AuroraColors.text4), contentPadding: EdgeInsets.zero),
    ]);
  }

  Widget _emptyState(IconData icon, String title, String subtitle) => Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
    Container(width: 72, height: 72, decoration: const BoxDecoration(shape: BoxShape.circle, color: AuroraColors.primarySoft), child: Icon(icon, size: 32, color: AuroraColors.primaryGlow)),
    const SizedBox(height: 16), Text(title, style: const TextStyle(color: AuroraColors.text2)), const SizedBox(height: 8), Text(subtitle, style: const TextStyle(fontSize: 12, color: AuroraColors.text3)),
    const SizedBox(height: 20),
    FilledButton.icon(onPressed: () => context.push('/characters/new'), icon: const Icon(Icons.add, size: 18), label: const Text('去创建角色')),
  ]));

  bool _canCreate() => _chars.isNotEmpty && _pName.text.trim().isNotEmpty;

  Future<void> _create() async {
    if (!_canCreate()) {
      if (_pName.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('请填写你的称呼'), backgroundColor: AuroraColors.warning));
      }
      return;
    }
    final custom = <String, String>{};
    for (final f in _customFields) { if (f.key.text.trim().isNotEmpty && f.value.text.trim().isNotEmpty) custom[f.key.text.trim()] = f.value.text.trim(); }
    final prot = Protagonist(id: 'prot_${DateTime.now().millisecondsSinceEpoch}', name: _pName.text.trim(), description: _pDesc.text.trim().isEmpty ? null : _pDesc.text.trim(), personality: _pPersonality.text.trim().isEmpty ? null : _pPersonality.text.trim(), appearance: _pAppearance.text.trim().isEmpty ? null : _pAppearance.text.trim(), backstory: _pBackstory.text.trim().isEmpty ? null : _pBackstory.text.trim(), customFields: custom.isNotEmpty ? custom : null);

    final primaryChar = _chars.first;
    final additionalChars = _chars.length > 1
        ? _chars.skip(1).map((c) => CharacterReference(id: c.id, name: c.name, avatar: c.avatar)).toList()
        : <CharacterReference>[];

    final s = ConversationSettings(
      nsfwEnabled: _nsfw,
      includeWorldSetting: _world != null,
      includeCharacterInfo: true,
      includeNPCInfo: _world != null,
      includeProtagonistInfo: true,
      multiCharacterMode: _isMultiCharacter,
    );

    try {
      final conv = await ref.read(conversationListProvider.notifier).createConversation(
        characterId: primaryChar.id,
        characterName: primaryChar.name,
        characterAvatar: primaryChar.avatar,
        worldId: _world?.id,
        worldName: _world?.name,
        settings: s,
        additionalCharacters: additionalChars,
      );
      final repo = ref.read(conversationRepositoryProvider);
      await repo.updateConversation(conv.copyWith(protagonist: prot));
      if (mounted) context.go('/chat/${conv.id}');
    } catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('创建失败，请重试'))); }
  }
}
