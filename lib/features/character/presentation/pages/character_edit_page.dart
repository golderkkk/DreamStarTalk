import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:dream_startalk/shared/widgets/app_loading.dart';
import 'package:dream_startalk/core/theme/aurora_theme.dart';
import 'dart:io';
import '../../domain/entities/character.dart';
import '../providers/character_provider.dart';

class CharacterEditPage extends ConsumerStatefulWidget {
  final String? characterId;
  const CharacterEditPage({super.key, this.characterId});
  @override ConsumerState<CharacterEditPage> createState() => _CharacterEditPageState();
}

class _CharacterEditPageState extends ConsumerState<CharacterEditPage> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController(), _desc = TextEditingController(), _personality = TextEditingController();
  final _speak = TextEditingController(), _backstory = TextEditingController(), _system = TextEditingController();
  final _first = TextEditingController(), _tags = TextEditingController();
  String? _avatar; Character? _c; bool _loading = false, _saving = false;
  bool _dirty = false;
  bool get isNew => widget.characterId == null;

  @override void initState() {
    super.initState();
    for (final ctrl in [_name, _desc, _personality, _speak, _backstory, _system, _first, _tags]) {
      ctrl.addListener(() { if (!_loading) _dirty = true; });
    }
    if (!isNew) _load();
  }
  @override void dispose() { _name.dispose(); _desc.dispose(); _personality.dispose(); _speak.dispose(); _backstory.dispose(); _system.dispose(); _first.dispose(); _tags.dispose(); super.dispose(); }

  Future<bool> _onWillPop() async {
    if (!_dirty || _saving) return true;
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AuroraColors.bg4,
        title: const Text('未保存的修改'),
        content: const Text('你有未保存的修改，确定离开？'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(_, false), child: const Text('继续编辑')),
          TextButton(onPressed: () => Navigator.pop(_, true), style: TextButton.styleFrom(foregroundColor: AuroraColors.rose), child: const Text('离开')),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> _load() async {
    if (mounted) setState(() => _loading = true);
    try {
      final c = await ref.read(characterRepositoryProvider).getCharacter(widget.characterId!);
      if (!mounted) return;
      if (c != null) {
        setState(() { _c = c; _name.text = c.name; _desc.text = c.description ?? ''; _personality.text = c.personality ?? ''; _speak.text = c.speakingStyle ?? ''; _backstory.text = c.backstory ?? ''; _system.text = c.systemPrompt ?? ''; _first.text = c.firstMessage ?? ''; _tags.text = c.tags.join(', '); _avatar = c.avatar; });
      } else {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('角色数据未找到'), backgroundColor: AuroraColors.warning));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('加载失败'), backgroundColor: AuroraColors.error));
      }
    } finally { if (mounted) setState(() => _loading = false); }
  }

  Future<void> _pick() async {
    final p = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 512, maxHeight: 512);
    if (p != null) {
      try {
        final appDir = await getApplicationDocumentsDirectory();
        final avatarsDir = Directory('${appDir.path}/avatars');
        if (!await avatarsDir.exists()) await avatarsDir.create(recursive: true);
        final fileName = 'avatar_${DateTime.now().millisecondsSinceEpoch}${path.extension(p.path)}';
        final savedFile = await File(p.path).copy('${avatarsDir.path}/$fileName');
        setState(() { _avatar = savedFile.path; _dirty = true; });
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('保存图片失败')));
      }
    }
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final tags = _tags.text.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty).toList();
      final repo = ref.read(characterRepositoryProvider);
      if (isNew) {
        await repo.createCharacter(Character(id: 'char_${DateTime.now().millisecondsSinceEpoch}', name: _name.text, description: _desc.text, personality: _personality.text, speakingStyle: _speak.text, backstory: _backstory.text, systemPrompt: _system.text, firstMessage: _first.text, tags: tags, avatar: _avatar));
      } else {
        await repo.updateCharacter(_c!.copyWith(name: _name.text, description: _desc.text, personality: _personality.text, speakingStyle: _speak.text, backstory: _backstory.text, systemPrompt: _system.text, firstMessage: _first.text, tags: tags, avatar: _avatar));
      }
      _dirty = false;
      if (mounted) { ref.read(characterListProvider.notifier).loadCharacters(); ScaffoldMessenger.of(context).clearSnackBars(); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isNew ? '已创建' : '已保存'))); Navigator.pop(context); }
    } catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('保存失败，请重试'))); }
    finally { setState(() => _saving = false); }
  }

  @override Widget build(BuildContext context) {
    if (_loading) return Scaffold(backgroundColor: AuroraColors.bg0, appBar: AppBar(title: Text(isNew ? '创建角色' : '编辑角色')), body: const AppLoadingScreen(message: '加载角色数据...'));
    return PopScope(
      canPop: !_dirty,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) Navigator.pop(context);
      },
      child: Scaffold(
        backgroundColor: AuroraColors.bg0,
        appBar: AppBar(
          title: Text(isNew ? '创建角色' : '编辑角色'),
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 8),
              child: FilledButton(
                onPressed: _saving ? null : _save,
                style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                child: _saving ? const AppButtonLoading() : const Text('保存'),
              ),
            ),
          ],
        ),
        body: Form(
          key: _form,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
            children: [
              _buildAvatarSection(),
              const SizedBox(height: 28),
              _buildSection('基本信息'),
              _buildField(_name, '角色名称 *', '输入角色名称', required: true),
              const SizedBox(height: 14),
              _buildField(_desc, '角色简介', '简短描述这个角色', maxLines: 3),
              const SizedBox(height: 28),
              _buildSection('性格设定'),
              _buildField(_personality, '性格特征', '如：温柔、活泼、冷静', maxLines: 2),
              const SizedBox(height: 14),
              _buildField(_speak, '说话风格', '如：使用敬语、爱说口头禅', maxLines: 2),
              const SizedBox(height: 28),
              _buildSection('背景故事'),
              _buildField(_backstory, '背景故事', '描述角色的背景经历', maxLines: 4),
              const SizedBox(height: 28),
              _buildSection('高级设置'),
              _buildField(_system, '系统提示词', '自定义系统提示词（可选）', maxLines: 4),
              const SizedBox(height: 14),
              _buildField(_first, '初始消息', '角色的第一条消息', maxLines: 2),
              const SizedBox(height: 14),
              _buildField(_tags, '标签', '用逗号分隔，如：奇幻, 冒险'),
              const SizedBox(height: 28),
              _buildSection('示例对话'),
              const SizedBox(height: 12),
              if (_c?.exampleDialogues.isNotEmpty == true)
                ..._c!.exampleDialogues.map((d) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: AuroraColors.bg2, borderRadius: BorderRadius.circular(AuroraRadius.md), border: Border.all(color: AuroraColors.border, width: 1)),
                  child: Text(d, style: const TextStyle(fontSize: 13, color: AuroraColors.text2)),
                )),
              OutlinedButton.icon(onPressed: _addExample, icon: const Icon(Icons.add, size: 18), label: const Text('添加示例对话')),
              const SizedBox(height: 40),
              FilledButton(onPressed: _saving ? null : _save, child: Text(isNew ? '创建角色' : '保存修改')),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarSection() {
    return Center(child: GestureDetector(
      onTap: _pick,
      child: Container(
        width: 108, height: 108,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AuroraRadius.xl),
          border: Border.all(color: AuroraColors.borderPrimary, width: 2),
          gradient: _avatar == null ? LinearGradient(colors: [AuroraColors.primarySoft, AuroraColors.cyan.withOpacity(0.05)]) : null,
        ),
        child: _avatar != null
            ? ClipRRect(borderRadius: BorderRadius.circular(22), child: _avatar!.startsWith('http') ? Image.network(_avatar!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.add_a_photo, color: AuroraColors.text3, size: 32)) : Image.file(File(_avatar!), fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.add_a_photo, color: AuroraColors.text3, size: 32)))
            : const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.add_a_photo, size: 28, color: AuroraColors.primaryGlow), SizedBox(height: 4), Text('上传', style: TextStyle(fontSize: 11, color: AuroraColors.primaryGlow))])),
      ),
    ));
  }

  Widget _buildSection(String title) => Padding(padding: const EdgeInsets.only(bottom: 12), child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AuroraColors.text1)));

  Widget _buildField(TextEditingController ctrl, String label, String hint, {int maxLines = 1, bool required = false}) {
    return TextFormField(
      controller: ctrl,
      maxLines: maxLines,
      style: const TextStyle(color: AuroraColors.text1, fontSize: 15),
      decoration: InputDecoration(labelText: label, hintText: hint),
      validator: required ? (v) => v == null || v.trim().isEmpty ? '请填写$label' : null : null,
    );
  }

  void _addExample() {
    final user = TextEditingController(), ai = TextEditingController();
    showDialog(context: context, builder: (_) => AlertDialog(
      backgroundColor: AuroraColors.bg4,
      title: const Text('添加示例对话'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: user, decoration: const InputDecoration(labelText: '用户说的话', hintText: '示例：你好呀'), maxLines: 2),
        const SizedBox(height: 12),
        TextField(controller: ai, decoration: InputDecoration(labelText: '${_name.text.isNotEmpty ? _name.text : "角色"}的回复', hintText: '示例：你好！'), maxLines: 2),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(_), child: const Text('取消')),
        FilledButton(onPressed: () { if (user.text.trim().isNotEmpty && ai.text.trim().isNotEmpty) { setState(() => _c = (_c ?? Character(id: '', name: '')).copyWith(exampleDialogues: [...(_c?.exampleDialogues ?? []), '{{user}}: ${user.text.trim()}\n{{char}}: ${ai.text.trim()}'])); Navigator.pop(_); } }, child: const Text('添加')),
      ],
    ));
  }
}
