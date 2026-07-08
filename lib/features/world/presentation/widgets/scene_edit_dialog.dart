import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../domain/entities/world.dart';

/// 场景编辑对话框 - 全功能版
class SceneEditDialog extends StatefulWidget {
  final Scene? scene;
  final List<NPC> worldNPCs; // 世界中已有的 NPC，用于关联
  final Function(Scene) onSave;

  const SceneEditDialog({
    super.key,
    this.scene,
    this.worldNPCs = const [],
    required this.onSave,
  });

  @override
  State<SceneEditDialog> createState() => _SceneEditDialogState();
}

class _SceneEditDialogState extends State<SceneEditDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _timeController = TextEditingController();
  final _weatherController = TextEditingController();
  final _atmosphereController = TextEditingController();
  
  String? _imagePath;
  List<String> _selectedNPCs = [];
  bool _isSaving = false;

  // 预设时间选项
  static const _timePresets = ['清晨', '上午', '正午', '下午', '黄昏', '傍晚', '深夜', '午夜'];
  
  // 预设天气选项
  static const _weatherPresets = ['晴朗', '多云', '阴天', '小雨', '大雨', '暴雨', '小雪', '大雪', '雾霾', '沙尘', '微风', '大风', '台风'];
  
  // 预设氛围选项
  static const _atmospherePresets = ['温馨', '紧张', '神秘', '恐怖', '浪漫', '悲伤', '欢快', '庄严', '宁静', '喧闹', '压抑', '轻松'];

  @override
  void initState() {
    super.initState();
    if (widget.scene != null) {
      _nameController.text = widget.scene!.name;
      _descriptionController.text = widget.scene!.description ?? '';
      _timeController.text = widget.scene!.time ?? '';
      _weatherController.text = widget.scene!.weather ?? '';
      _atmosphereController.text = widget.scene!.atmosphere ?? '';
      _imagePath = widget.scene!.image;
      _selectedNPCs = List.from(widget.scene!.npcs);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _timeController.dispose();
    _weatherController.dispose();
    _atmosphereController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 768,
      );
      if (picked != null && mounted) {
        setState(() => _imagePath = picked.path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('选择图片失败')),
        );
      }
    }
  }

  void _handleSave() {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final scene = Scene(
      id: widget.scene?.id ?? 'scene_${DateTime.now().millisecondsSinceEpoch}',
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
      image: _imagePath,
      time: _timeController.text.trim().isEmpty ? null : _timeController.text.trim(),
      weather: _weatherController.text.trim().isEmpty ? null : _weatherController.text.trim(),
      atmosphere: _atmosphereController.text.trim().isEmpty ? null : _atmosphereController.text.trim(),
      npcs: _selectedNPCs,
      metadata: widget.scene?.metadata,
    );

    widget.onSave(scene);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isNew = widget.scene == null;

    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
          maxWidth: 520,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.location_on, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(isNew ? '添加场景' : '编辑场景',
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
                      _buildImageSection(context),
                      const SizedBox(height: 20),
                      _buildSectionLabel(theme, '场景名称'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          hintText: '如：皇宫大殿、迷雾森林、热闹的酒馆',
                          prefixIcon: Icon(Icons.edit_location_alt),
                        ),
                        validator: (v) => v == null || v.trim().isEmpty ? '请输入场景名称' : null,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 16),
                      _buildSectionLabel(theme, '场景描述'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          hintText: '描述场景的细节，帮助 AI 理解环境',
                          prefixIcon: Icon(Icons.description),
                          alignLabelWithHint: true,
                        ),
                        maxLines: 4,
                      ),
                      const SizedBox(height: 20),
                      _buildSectionLabel(theme, '时间'),
                      _buildPresetChips(
                        context,
                        controller: _timeController,
                        presets: _timePresets,
                      ),
                      const SizedBox(height: 16),
                      _buildSectionLabel(theme, '天气'),
                      _buildPresetChips(
                        context,
                        controller: _weatherController,
                        presets: _weatherPresets,
                      ),
                      const SizedBox(height: 16),
                      _buildSectionLabel(theme, '氛围'),
                      _buildPresetChips(
                        context,
                        controller: _atmosphereController,
                        presets: _atmospherePresets,
                      ),
                      if (widget.worldNPCs.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        _buildSectionLabel(theme, '出现的 NPC'),
                        const SizedBox(height: 8),
                        _buildNPCSelector(context),
                      ],
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
                    label: Text(isNew ? '添加场景' : '保存修改'),
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

  Widget _buildImageSection(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        width: double.infinity,
        height: 140,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.colorScheme.outline.withOpacity(0.3)),
        ),
        child: _imagePath != null
            ? Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: _imagePath!.startsWith('http')
                        ? Image.network(_imagePath!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _buildImagePlaceholder(context))
                        : Image.file(File(_imagePath!), fit: BoxFit.cover, errorBuilder: (_, __, ___) => _buildImagePlaceholder(context)),
                  ),
                  Positioned(
                    right: 8, bottom: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(8)),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.edit, size: 14, color: Colors.white),
                          SizedBox(width: 4),
                          Text('更换', style: TextStyle(color: Colors.white, fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            : _buildImagePlaceholder(context),
      ),
    );
  }

  Widget _buildImagePlaceholder(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.add_photo_alternate_outlined, size: 36, color: theme.colorScheme.primary.withOpacity(0.5)),
        const SizedBox(height: 8),
        Text('点击上传场景图片', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.5))),
        const SizedBox(height: 4),
        Text('推荐 16:9 比例', style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.3))),
      ],
    );
  }

  Widget _buildPresetChips(BuildContext context, {required TextEditingController controller, required List<String> presets}) {
    final currentValue = controller.text;
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        SizedBox(
          width: 120,
          child: TextField(
            controller: controller,
            decoration: const InputDecoration(isDense: true, contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10), border: OutlineInputBorder()),
            style: const TextStyle(fontSize: 13),
          ),
        ),
        const SizedBox(width: 4),
        ...presets.map((preset) {
          final selected = currentValue == preset;
          return ActionChip(
            label: Text(preset, style: TextStyle(fontSize: 12, color: selected ? Colors.white : null)),
            backgroundColor: selected ? Theme.of(context).colorScheme.primary : null,
            side: selected ? null : BorderSide(color: Theme.of(context).colorScheme.outline.withOpacity(0.3)),
            padding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
            onPressed: () {
              controller.text = preset;
              setState(() {});
            },
          );
        }),
      ],
    );
  }

  Widget _buildNPCSelector(BuildContext context) {
    final theme = Theme.of(context);

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: widget.worldNPCs.map((npc) {
        final selected = _selectedNPCs.contains(npc.id);
        return FilterChip(
          label: Text(npc.displayName, style: TextStyle(fontSize: 12)),
          selected: selected,
          avatar: CircleAvatar(radius: 10,
            backgroundColor: selected ? theme.colorScheme.primary : theme.colorScheme.surfaceContainerHighest,
            child: Text(npc.name.isNotEmpty ? npc.name[0] : '?', style: TextStyle(fontSize: 10, color: selected ? Colors.white : null)),
          ),
          onSelected: (val) {
            setState(() {
              if (val) { _selectedNPCs.add(npc.id); } else { _selectedNPCs.remove(npc.id); }
            });
          },
        );
      }).toList(),
    );
  }
}

/// 显示场景编辑对话框
void showSceneEditDialog(BuildContext context, {Scene? scene, List<NPC> worldNPCs = const [], required Function(Scene) onSave}) {
  showDialog(
    context: context,
    builder: (ctx) => SceneEditDialog(scene: scene, worldNPCs: worldNPCs, onSave: onSave),
  );
}
