import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dream_startalk/core/theme/aurora_theme.dart';

import 'package:dream_startalk/core/theme/theme_presets.dart';
import 'package:dream_startalk/core/theme/theme_manager.dart';

/// 主题选择页面
class ThemeSelectionPage extends ConsumerWidget {
  const ThemeSelectionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);
    final presets = AppThemePresets.getAll();

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
        title: const Text('选择主题'),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 4),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AuroraColors.bg2,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AuroraColors.border.withOpacity(0.3), width: 0.5),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(themeState.isDark ? Icons.dark_mode : Icons.light_mode, size: 18, color: AuroraColors.text2),
              const SizedBox(width: 6),
              Switch(
                value: themeState.isDark,
                onChanged: (_) => ref.read(themeProvider.notifier).toggleDarkMode(),
                activeColor: AuroraColors.primary,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ]),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.82,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
        ),
        itemCount: presets.length,
        itemBuilder: (context, index) {
          final entry = presets[index];
          final style = entry.key;
          final colors = entry.value;
          final isSelected = themeState.currentStyle == style;

          return GestureDetector(
            onTap: () {
              ref.read(themeProvider.notifier).setThemeStyle(style);
              ScaffoldMessenger.of(context).clearSnackBars();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('已切换到 ${style.label} 主题')),
              );
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? colors.primary.withOpacity(0.8) : AuroraColors.border.withOpacity(0.3),
                  width: isSelected ? 2 : 0.5,
                ),
                color: colors.background,
                boxShadow: isSelected
                    ? [BoxShadow(color: colors.primary.withOpacity(0.25), blurRadius: 16, offset: const Offset(0, 4))]
                    : AuroraShadows.sm,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 72, height: 72,
                    decoration: BoxDecoration(
                      gradient: colors.gradient,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: colors.primary.withOpacity(0.2), blurRadius: 12, offset: const Offset(0, 4))],
                    ),
                    child: Center(child: Text(style.emoji, style: const TextStyle(fontSize: 32))),
                  ),
                  const SizedBox(height: 14),
                  Text(style.label, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: colors.textPrimary)),
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(style.description, style: TextStyle(fontSize: 11, color: colors.textSecondary), textAlign: TextAlign.center, maxLines: 2),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _colorDot(colors.primary),
                      const SizedBox(width: 5),
                      _colorDot(colors.secondary),
                      const SizedBox(width: 5),
                      _colorDot(colors.accent),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (isSelected)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                      decoration: BoxDecoration(
                        color: colors.primary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text('当前使用', style: TextStyle(fontSize: 11, color: colors.primary, fontWeight: FontWeight.w600)),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _colorDot(Color color) {
    return Container(
      width: 14, height: 14,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(0.25), width: 1),
        boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 4, offset: const Offset(0, 1))],
      ),
    );
  }
}
