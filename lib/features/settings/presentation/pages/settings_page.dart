import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dream_startalk/core/theme/aurora_theme.dart';
import '../../../character/presentation/providers/character_provider.dart';
import '../../../character/data/repositories/character_repository_impl.dart';

/// NSFW 解锁状态
class NSFWUnlockState {
  static bool unlocked = false;
}

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  Timer? _nsfwTimer;
  bool _nsfwUnlocking = false;

  @override void dispose() { _nsfwTimer?.cancel(); super.dispose(); }

  void _startNSFWUnlock() {
    setState(() { _nsfwUnlocking = true; });
    _nsfwTimer?.cancel();
    _nsfwTimer = Timer(const Duration(seconds: 5), () {
      setState(() { _nsfwUnlocking = false; });
      // 全局状态标记 NSFW 已解锁
      NSFWUnlockState.unlocked = true;
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('🔓 NSFW 功能已解锁'), duration: Duration(seconds: 2)));
      }
    });
  }

  void _cancelNSFWUnlock() {
    _nsfwTimer?.cancel();
    setState(() { _nsfwUnlocking = false; });
  }

  @override Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AuroraColors.bg0,
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ListView(
            padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 40, 20, 40),
            children: [
              _buildHeader(context),
              const SizedBox(height: 20),
              _buildSection('AI 服务', [
                _buildTile(context, Icons.smart_toy_outlined, 'AI 服务配置', '提供商、模型、语音合成', iconColor: AuroraColors.primary, onTap: () => context.push('/settings/ai-service')),
              ]),
              _buildSection('数据', [
                _buildTile(context, Icons.download_outlined, '导入角色卡', '从 JSON 或 PNG 文件导入', iconColor: AuroraColors.cyan, onTap: () => _importCharacters(ref)),
                _buildDivider(),
                _buildTile(context, Icons.upload_outlined, '导出全部角色', '保存为 JSON 文件', iconColor: AuroraColors.amber, onTap: () => _exportAll(ref)),
                _buildDivider(),
                _buildTile(context, Icons.ios_share, '分享导出文件', '通过系统分享', iconColor: AuroraColors.cyan, onTap: () => _shareExports(context)),
              ]),
              _buildSection('其他', [
                _buildTile(context, Icons.delete_sweep_outlined, '清理缓存', '临时文件、图片缓存等', iconColor: AuroraColors.warning, onTap: () => _clearCache(context)),
                _buildDivider(),
                _buildTile(context, Icons.info_outline, '拾梦·星语', _nsfwUnlocking ? '请继续按住...' : '版本 2.0 · DreamStarTalk', iconColor: _nsfwUnlocking ? AuroraColors.rose : AuroraColors.primaryGlow, onLongPressStart: _startNSFWUnlock, onLongPressEnd: _cancelNSFWUnlock, onTap: () => _showAbout(context)),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [AuroraColors.primarySoft, AuroraColors.cyan.withOpacity(0.04)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(AuroraRadius.xl),
        border: Border.all(color: AuroraColors.border, width: 1),
      ),
      child: Row(children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AuroraRadius.md),
          child: Image.asset('assets/images/logo.png', width: 52, height: 52, fit: BoxFit.cover),
        ),
        const SizedBox(width: 16),
        const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('拾梦·星语', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AuroraColors.text1, letterSpacing: -0.3)),
          SizedBox(height: 4),
          Text('DreamStarTalk · 沉浸式 AI 角色扮演', style: TextStyle(fontSize: 13, color: AuroraColors.text3)),
        ])),
      ]),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(padding: const EdgeInsets.fromLTRB(4, 0, 16, 10), child: Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AuroraColors.text3, letterSpacing: 0.8))),
      Container(
        decoration: BoxDecoration(color: AuroraColors.bg2, borderRadius: BorderRadius.circular(AuroraRadius.lg), border: Border.all(color: AuroraColors.border, width: 1)),
        clipBehavior: Clip.antiAlias,
        child: Column(children: children),
      ),
      const SizedBox(height: 20),
    ]);
  }

  Widget _buildDivider() => Divider(height: 1, indent: 56, endIndent: 16, color: AuroraColors.border);

  Widget _buildTile(BuildContext context, IconData icon, String title, String subtitle, {Color? iconColor, VoidCallback? onTap, VoidCallback? onLongPressStart, VoidCallback? onLongPressEnd}) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onLongPressStart: onLongPressStart != null ? (_) => onLongPressStart() : null,
      onLongPressEnd: onLongPressEnd != null ? (_) => onLongPressEnd() : null,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(children: [
          Container(width: 36, height: 36, decoration: BoxDecoration(color: (iconColor ?? AuroraColors.text3).withOpacity(0.1), borderRadius: BorderRadius.circular(AuroraRadius.sm)), child: Icon(icon, color: iconColor ?? AuroraColors.text3, size: 20)),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(color: AuroraColors.text1, fontSize: 14, fontWeight: FontWeight.w500)),
            const SizedBox(height: 2),
            Text(subtitle, style: const TextStyle(fontSize: 12, color: AuroraColors.text3)),
          ])),
          const Icon(Icons.chevron_right, color: AuroraColors.text4, size: 20),
        ]),
      ),
    );
  }

  void _clearCache(BuildContext context) async {
    try {
      final dir = await getTemporaryDirectory();
      var count = 0;
      if (await dir.exists()) {
        await for (final entity in dir.list()) {
          if (entity is File) { await entity.delete(); count++; }
        }
      }
      final docDir = await getApplicationDocumentsDirectory();
      final imgDir = Directory('${docDir.path}/chat_images');
      if (await imgDir.exists()) {
        await for (final entity in imgDir.list()) {
          if (entity is File) { await entity.delete(); count++; }
        }
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('已清理 $count 个临时文件')));
      }
    } catch (e) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('清理失败')));
    }
  }

  void _showAbout(BuildContext context) {
    showDialog(context: context, builder: (context) => Dialog(
      backgroundColor: AuroraColors.bg4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AuroraRadius.xxl)),
      child: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: [
        ClipRRect(borderRadius: BorderRadius.circular(AuroraRadius.xl), child: Image.asset('assets/images/logo.png', width: 64, height: 64, fit: BoxFit.cover)),
        const SizedBox(height: 20),
        const Text('拾梦·星语', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AuroraColors.text1)),
        const SizedBox(height: 8),
        const Text('DreamStarTalk v2.0', style: TextStyle(fontSize: 14, color: AuroraColors.text3)),
        const SizedBox(height: 16),
        const Text('沉浸式 AI 角色扮演\n多角色对话 · 世界观构建 · 场景叙事', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: AuroraColors.text2, height: 1.5)),
        const SizedBox(height: 24),
        SizedBox(width: double.infinity, child: FilledButton(onPressed: () => Navigator.pop(context), child: const Text('确定'))),
      ])),
    ));
  }

  Future<void> _importCharacters(WidgetRef ref) async {
    try {
      final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['json', 'png']);
      if (result == null || result.files.isEmpty) return;
      final filePath = result.files.first.path!;
      final repo = ref.read(characterRepositoryProvider);
      if (repo is CharacterRepositoryImpl) {
        final count = await repo.importCharactersFromJson(filePath);
        ref.read(characterListProvider.notifier).loadCharacters();
        if (ref.context.mounted) ScaffoldMessenger.of(ref.context).showSnackBar(SnackBar(content: Text('成功导入 $count 个角色')));
      }
    } catch (e) {
      if (ref.context.mounted) ScaffoldMessenger.of(ref.context).showSnackBar(const SnackBar(content: Text('导入失败，请检查文件格式'), backgroundColor: AuroraColors.error));
    }
  }

  Future<void> _exportAll(WidgetRef ref) async {
    try {
      final repo = ref.read(characterRepositoryProvider);
      if (repo is CharacterRepositoryImpl) {
        final filePath = await repo.exportAllCharacters();
        if (ref.context.mounted) ScaffoldMessenger.of(ref.context).showSnackBar(SnackBar(content: Text('已导出到: $filePath')));
      }
    } catch (e) {
      if (ref.context.mounted) ScaffoldMessenger.of(ref.context).showSnackBar(const SnackBar(content: Text('导出失败，请重试'), backgroundColor: AuroraColors.error));
    }
  }

  Future<void> _shareExports(BuildContext context) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final exportDir = Directory('${dir.path}/exports');
      if (!await exportDir.exists()) {
        if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('还没有导出文件')));
        return;
      }
      final files = exportDir.listSync().whereType<File>().toList();
      if (files.isEmpty) {
        if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('还没有导出文件')));
        return;
      }
      await Share.shareXFiles([XFile(files.last.path)], subject: '拾梦·星语 导出数据');
    } catch (e) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('分享失败，请重试'), backgroundColor: AuroraColors.error));
    }
  }
}
