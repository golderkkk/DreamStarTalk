import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../domain/entities/world.dart';

/// NPC 编辑对话框 - 全功能版
class NPCEditDialog extends StatefulWidget {
  final NPC? npc;
  final Function(NPC) onSave;

  const NPCEditDialog({super.key, this.npc, required this.onSave});

  @override
  State<NPCEditDialog> createState() => _NPCEditDialogState();
}

class _NPCEditDialogState extends State<NPCEditDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _personalityController = TextEditingController();
  final _backstoryController = TextEditingController();
  final _speakingStyleController = TextEditingController();
  final _relationshipController = TextEditingController();
  final _tagsController = TextEditingController();

  String? _avatarPath;
  String? _gender;
  bool _isSaving = false;

  // 性格预设
  static const _personalityPresets = ['开朗', '内向', '温柔', '冷酷', '热血', '冷静', '腹黑', '天真', '成熟', '傲娇', '毒舌', '懒散', '认真', '幽默', '忧郁', '暴躁', '胆怯', '自信'];

  // 关系预设
  static const _relationshipPresets = ['盟友', '朋友', '中立', '对手', '敌人', '家人', '恋人', '导师', '学生', '同事', '部下', '上司', '青梅竹马', '宿敌', '救命恩人'];

  // 性别选项
  static const _genders = ['男', '女', '其他', '不设定'];

  @override
  void initState() {
    super.initState();
    if (widget.npc != null) {
      _nameController.text = widget.npc!.name;
      _descriptionController.text = widget.npc!.description ?? '';
      _personalityController.text = widget.npc!.personality ?? '';
      _backstoryController.text = widget.npc!.backstory ?? '';
      _speakingStyleController.text = widget.npc!.speakingStyle ?? '';
      _relationshipController.text = widget.npc!.relationship ?? '';
      _tagsController.text = widget.npc!.tags.join(', ');
      _avatarPath = widget.npc!.avatar;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _personalityController.dispose();
    _backstoryController.dispose();
    _speakingStyleController.dispose();
    _relationshipController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.gallery, maxWidth: 512, maxHeight: 512);
      if (picked != null && mounted) setState(() => _avatarPath = picked.path);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('选择图片失败')));
    }
  }

  void _handleSave() {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final tags = _tagsController.text.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty).toList();

    final npc = NPC(
      id: widget.npc?.id ?? 'npc_${DateTime.now().millisecondsSinceEpoch}',
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
      personality: _personalityController.text.trim().isEmpty ? null : _personalityController.text.trim(),
      backstory: _backstoryController.text.trim().isEmpty ? null : _backstoryController.text.trim(),
      speakingStyle: _speakingStyleController.text.trim().isEmpty ? null : _speakingStyleController.text.trim(),
      relationship: _relationshipController.text.trim().isEmpty ? null : _relationshipController.text.trim(),
      tags: tags,
      avatar: _avatarPath,
      relationships: widget.npc?.relationships,
    );

    widget.onSave(npc);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isNew = widget.npc == null;

    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.85, maxWidth: 520),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.person_add, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(isNew ? '添加 NPC' : '编辑 NPC',
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 头像
                      _buildAvatarSection(context),
                      const SizedBox(height: 20),

                      // 名称 + 性别
                      _buildSectionLabel(theme, '基本信息'),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: TextFormField(
                              controller: _nameController,
                              decoration: const InputDecoration(hintText: 'NPC 名称 *', prefixIcon: Icon(Icons.person)),
                              validator: (v) => v == null || v.trim().isEmpty ? '请输入名称' : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: DropdownButtonFormField<String>(
                              value: _gender,
                              decoration: const InputDecoration(isDense: true, contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12)),
                              items: _genders.map((g) => DropdownMenuItem(value: g, child: Text(g, style: const TextStyle(fontSize: 13)))).toList(),
                              onChanged: (v) => setState(() => _gender = v),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      _buildSectionLabel(theme, '描述'),
                      const SizedBox(height: 8),
                      TextFormField(controller: _descriptionController, decoration: const InputDecoration(hintText: '简短描述这个 NPC', prefixIcon: Icon(Icons.description), alignLabelWithHint: true), maxLines: 3),
                      const SizedBox(height: 20),

                      _buildSectionLabel(theme, '性格特征'),
                      const SizedBox(height: 8),
                      TextFormField(controller: _personalityController, decoration: const InputDecoration(hintText: '如：温柔、勇敢、狡猾', prefixIcon: Icon(Icons.psychology)), maxLines: 2),
                      const SizedBox(height: 8),
                      _buildPresetChips(controller: _personalityController, presets: _personalityPresets),
                      const SizedBox(height: 16),

                      _buildSectionLabel(theme, '说话风格'),
                      const SizedBox(height: 8),
                      TextFormField(controller: _speakingStyleController, decoration: const InputDecoration(hintText: '如：使用敬语、有口头禅、说话简短', prefixIcon: Icon(Icons.record_voice_over)), maxLines: 2),
                      const SizedBox(height: 20),

                      _buildSectionLabel(theme, '背景故事'),
                      const SizedBox(height: 8),
                      TextFormField(controller: _backstoryController, decoration: const InputDecoration(hintText: '描述 NPC 的背景经历', prefixIcon: Icon(Icons.history_edu), alignLabelWithHint: true), maxLines: 3),
                      const SizedBox(height: 20),

                      _buildSectionLabel(theme, '与主角的关系'),
                      const SizedBox(height: 8),
                      TextFormField(controller: _relationshipController, decoration: const InputDecoration(hintText: '如：生死之交、商业伙伴', prefixIcon: Icon(Icons.link))),
                      const SizedBox(height: 8),
                      _buildPresetChips(controller: _relationshipController, presets: _relationshipPresets, isSmall: true),
                      const SizedBox(height: 16),

                      // 标签
                      _buildSectionLabel(theme, '标签'),
                      const SizedBox(height: 8),
                      TextFormField(controller: _tagsController, decoration: const InputDecoration(hintText: '用逗号分隔，如：商人, 友善, 神秘', prefixIcon: Icon(Icons.label_outline))),
                    ],
                  ),
                ),
              ),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
                  const SizedBox(width: 12),
                  FilledButton.icon(
                    onPressed: _isSaving ? null : _handleSave,
                    icon: _isSaving
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.check, size: 18),
                    label: Text(isNew ? '添加 NPC' : '保存修改'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(ThemeData theme, String title) {
    return Text(title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600, color: theme.colorScheme.primary));
  }

  Widget _buildAvatarSection(BuildContext context) {
    final theme = Theme.of(context);
    final initial = _nameController.text.isNotEmpty ? _nameController.text[0].toUpperCase() : '?';

    return Center(
      child: GestureDetector(
        onTap: _pickAvatar,
        child: Column(
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: theme.colorScheme.outline.withOpacity(0.3), width: 2),
              ),
              child: _avatarPath != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: _avatarPath!.startsWith('http')
                          ? Image.network(_avatarPath!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _buildAvatarPlaceholder(theme, initial))
                          : Image.file(File(_avatarPath!), fit: BoxFit.cover, errorBuilder: (_, __, ___) => _buildAvatarPlaceholder(theme, initial)),
                    )
                  : _buildAvatarPlaceholder(theme, initial),
            ),
            const SizedBox(height: 8),
            Text('点击上传头像', style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.primary)),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarPlaceholder(ThemeData theme, String initial) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [theme.colorScheme.primary.withOpacity(0.7), theme.colorScheme.secondary.withOpacity(0.7)], begin: Alignment.topLeft, end: Alignment.bottomRight),
      ),
      child: Center(child: Text(initial, style: theme.textTheme.headlineMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold))),
    );
  }

  Widget _buildPresetChips({required TextEditingController controller, required List<String> presets, bool isSmall = false}) {
    final currentValue = controller.text;
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Wrap(
      spacing: 4, runSpacing: 4,
      children: presets.map((preset) {
        final selected = currentValue.contains(preset) || currentValue == preset;
        return ActionChip(
          label: Text(preset, style: TextStyle(fontSize: isSmall ? 11 : 12, color: selected ? Colors.white : null)),
          backgroundColor: selected ? cs.primary : null,
          side: selected ? null : BorderSide(color: cs.outline.withOpacity(0.3)),
          padding: EdgeInsets.zero,
          visualDensity: VisualDensity.compact,
          labelPadding: const EdgeInsets.symmetric(horizontal: 8),
          onPressed: () {
            if (controller.text.isNotEmpty) {
              controller.text = '${controller.text}, $preset';
            } else {
              controller.text = preset;
            }
            setState(() {});
          },
        );
      }).toList(),
    );
  }
}

/// 显示 NPC 编辑对话框
void showNPCEditDialog(BuildContext context, {NPC? npc, required Function(NPC) onSave}) {
  showDialog(
    context: context,
    builder: (ctx) => NPCEditDialog(npc: npc, onSave: onSave),
  );
}
