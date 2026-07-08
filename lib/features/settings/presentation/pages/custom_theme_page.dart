import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dream_startalk/core/theme/aurora_theme.dart';

import 'package:dream_startalk/core/theme/theme_manager.dart';

/// 自定义主题编辑页面
class CustomThemePage extends ConsumerStatefulWidget {
  const CustomThemePage({super.key});

  @override
  ConsumerState<CustomThemePage> createState() => _CustomThemePageState();
}

class _CustomThemePageState extends ConsumerState<CustomThemePage> {
  late Color _primary;
  late Color _secondary;
  late Color _background;
  late Color _surface;
  late Color _card;
  late Color _textPrimary;
  late Color _textSecondary;
  late Color _accent;

  @override
  void initState() {
    super.initState();
    final themeState = ref.read(themeProvider);
    final colors = themeState.colors;
    _primary = colors.primary;
    _secondary = colors.secondary;
    _background = colors.background;
    _surface = colors.surface;
    _card = colors.card;
    _textPrimary = colors.textPrimary;
    _textSecondary = colors.textSecondary;
    _accent = colors.accent;
  }

  void _applyTheme() {
    final config = CustomThemeConfig(
      primary: _primary,
      secondary: _secondary,
      background: _background,
      surface: _surface,
      card: _card,
      textPrimary: _textPrimary,
      textSecondary: _textSecondary,
      accent: _accent,
    );
    ref.read(themeProvider.notifier).setCustomTheme(config);
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('自定义主题已应用')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AuroraColors.bg0,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(color: AuroraColors.bg0.withOpacity(0.6)),
          ),
        ),
        title: const Text('自定义主题'),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: FilledButton(
              onPressed: _applyTheme,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              child: const Text('应用'),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPreview(),
            const SizedBox(height: 28),

            _buildSectionTitle('颜色配置'),
            const SizedBox(height: 12),
            _buildColorSection(),
            const SizedBox(height: 28),

            _buildSectionTitle('快速选择'),
            const SizedBox(height: 12),
            _buildQuickColors(),
            const SizedBox(height: 28),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _primary = AuroraColors.primary;
                    _secondary = AuroraColors.amber;
                    _background = AuroraColors.bg0;
                    _surface = AuroraColors.bg1;
                    _card = AuroraColors.bg2;
                    _textPrimary = AuroraColors.text1;
                    _textSecondary = AuroraColors.text2;
                    _accent = AuroraColors.cyan;
                  });
                },
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('重置为默认'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AuroraColors.text3, letterSpacing: 0.3));
  }

  Widget _buildPreview() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _textSecondary.withOpacity(0.15), width: 0.5),
        boxShadow: AuroraShadows.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [_primary, _accent]),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(child: Icon(Icons.auto_awesome, color: Colors.white, size: 18)),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('主题预览', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: _textPrimary)),
              const SizedBox(height: 2),
              Text('这是正文内容预览', style: TextStyle(fontSize: 13, color: _textSecondary)),
            ])),
          ]),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [_primary, _primary.withOpacity(0.8)]),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(child: Text('主要按钮', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13))),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _primary.withOpacity(0.5)),
                ),
                child: Center(child: Text('次要按钮', style: TextStyle(color: _primary, fontWeight: FontWeight.w600, fontSize: 13))),
              ),
            ),
          ]),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _textSecondary.withOpacity(0.1), width: 0.5),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('卡片标题', style: TextStyle(fontWeight: FontWeight.w600, color: _textPrimary, fontSize: 14)),
              const SizedBox(height: 4),
              Text('卡片内容预览', style: TextStyle(color: _textSecondary, fontSize: 12)),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildColorSection() {
    return Container(
      decoration: BoxDecoration(
        color: AuroraColors.bg2,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AuroraColors.border.withOpacity(0.25), width: 0.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: [
        _buildColorPicker('主色调', _primary, (c) => setState(() => _primary = c)),
        _buildColorDivider(),
        _buildColorPicker('次要色', _secondary, (c) => setState(() => _secondary = c)),
        _buildColorDivider(),
        _buildColorPicker('强调色', _accent, (c) => setState(() => _accent = c)),
        _buildColorDivider(),
        _buildColorPicker('背景色', _background, (c) => setState(() => _background = c)),
        _buildColorDivider(),
        _buildColorPicker('表面色', _surface, (c) => setState(() => _surface = c)),
        _buildColorDivider(),
        _buildColorPicker('卡片色', _card, (c) => setState(() => _card = c)),
        _buildColorDivider(),
        _buildColorPicker('主文字', _textPrimary, (c) => setState(() => _textPrimary = c)),
        _buildColorDivider(),
        _buildColorPicker('次文字', _textSecondary, (c) => setState(() => _textSecondary = c)),
      ]),
    );
  }

  Widget _buildColorDivider() {
    return Divider(height: 1, indent: 16, endIndent: 16, color: AuroraColors.border.withOpacity(0.2));
  }

  Widget _buildColorPicker(String label, Color current, ValueChanged<Color> onChanged) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showColorPicker(current, onChanged),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(children: [
            Expanded(child: Text(label, style: const TextStyle(fontSize: 14, color: AuroraColors.text1))),
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: current,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AuroraColors.border.withOpacity(0.3), width: 0.5),
                boxShadow: [BoxShadow(color: current.withOpacity(0.3), blurRadius: 6, offset: const Offset(0, 2))],
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: 72,
              child: Text(
                '#${current.value.toRadixString(16).substring(2).toUpperCase()}',
                style: const TextStyle(fontSize: 12, fontFamily: 'monospace', color: AuroraColors.text3),
              ),
            ),
            Icon(Icons.chevron_right, color: AuroraColors.text3.withOpacity(0.4), size: 18),
          ]),
        ),
      ),
    );
  }

  void _showColorPicker(Color current, ValueChanged<Color> onChanged) {
    final colors = [
      Colors.red, Colors.pink, Colors.purple, Colors.deepPurple,
      Colors.indigo, Colors.blue, Colors.lightBlue, Colors.cyan,
      Colors.teal, Colors.green, Colors.lightGreen, Colors.lime,
      Colors.yellow, Colors.amber, Colors.orange, Colors.deepOrange,
      Colors.brown, Colors.grey, Colors.blueGrey, Colors.black,
      Colors.white,
    ];

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: AuroraColors.bg1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text('选择颜色', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AuroraColors.text1)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: colors.map((c) => GestureDetector(
                onTap: () { onChanged(c); Navigator.pop(context); },
                child: Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: c,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: c == current ? AuroraColors.primary : AuroraColors.border.withOpacity(0.3),
                      width: c == current ? 2.5 : 0.5,
                    ),
                    boxShadow: c == current ? [BoxShadow(color: AuroraColors.primary.withOpacity(0.3), blurRadius: 8)] : null,
                  ),
                ),
              )).toList(),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _buildQuickColors() {
    final presets = [
      {'name': '紫色系', 'colors': [const Color(0xFF7C3AED), const Color(0xFFA78BFA)]},
      {'name': '蓝色系', 'colors': [const Color(0xFF3B82F6), const Color(0xFF60A5FA)]},
      {'name': '绿色系', 'colors': [const Color(0xFF10B981), const Color(0xFF34D399)]},
      {'name': '橙色系', 'colors': [const Color(0xFFF59E0B), const Color(0xFFFBBF24)]},
      {'name': '红色系', 'colors': [const Color(0xFFEF4444), const Color(0xFFF87171)]},
      {'name': '粉色系', 'colors': [const Color(0xFFEC4899), const Color(0xFFF472B6)]},
    ];

    return Wrap(
      spacing: 14,
      runSpacing: 14,
      children: presets.map((preset) {
        final colors = preset['colors'] as List<Color>;
        return GestureDetector(
          onTap: () => setState(() { _primary = colors[0]; _accent = colors[1]; }),
          child: Column(children: [
            Container(
              width: 52, height: 52,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: colors, begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(color: colors[0].withOpacity(0.25), blurRadius: 8, offset: const Offset(0, 2))],
              ),
            ),
            const SizedBox(height: 6),
            Text(preset['name'] as String, style: const TextStyle(fontSize: 11, color: AuroraColors.text2)),
          ]),
        );
      }).toList(),
    );
  }
}
