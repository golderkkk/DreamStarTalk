import 'package:flutter/material.dart';
import '../../core/theme/aurora_theme.dart';

/// 共享头像渐变工具
/// 根据名称哈希生成 8 种不同的渐变色，确保角色颜色一致
class AvatarGradientHelper {
  static const _colors = [
    [Color(0xFF7C6BF0), Color(0xFF5B4ED0)], // 紫色
    [Color(0xFFFFB347), Color(0xFFE89530)], // 橙色
    [Color(0xFF4ECDC4), Color(0xFF3AAFA7)], // 青色
    [Color(0xFFFB7185), Color(0xFFE5576E)], // 粉色
    [Color(0xFF60A5FA), Color(0xFF4A90E2)], // 蓝色
    [Color(0xFF34D399), Color(0xFF22B07D)], // 绿色
    [Color(0xFFFBBF24), Color(0xFFD4A017)], // 金色
    [Color(0xFFA78BFA), Color(0xFF8B6CF0)], // 浅紫
  ];

  /// 根据名称返回渐变颜色列表
  static List<Color> getColors(String name) {
    if (name.isEmpty) return _colors[0];
    final hash = name.codeUnitAt(0) + name.codeUnitAt(name.length - 1);
    return _colors[hash % _colors.length];
  }

  /// 根据名称返回渐变 BoxDecoration
  static BoxDecoration getDecoration(String name, {double radius = 16}) {
    return BoxDecoration(
      gradient: LinearGradient(colors: getColors(name)),
      borderRadius: BorderRadius.circular(radius),
    );
  }
}

/// 快捷颜色常量（保持向后兼容）
class AppGradients {
  static const primary = AuroraColors.gradientPrimary;
}
