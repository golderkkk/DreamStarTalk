import 'package:flutter/material.dart';
import 'aurora_theme.dart';

/// 向后兼容的颜色系统 — 实际值来自 Aurora 设计系统
class AppColors {
  // 背景层次 (映射 Aurora 5 级背景)
  static const scaffold = AuroraColors.bg0;
  static const surface = AuroraColors.bg1;
  static const card = AuroraColors.bg2;
  static const cardElevated = AuroraColors.bg3;

  // 主色调
  static const primary = AuroraColors.primary;
  static const primaryDeep = AuroraColors.primaryActive;
  static const primaryGlow = AuroraColors.primaryGlow;
  static const secondary = AuroraColors.amber;
  static const secondaryGlow = Color(0xFFFBBF24);

  // 功能色
  static const accent = AuroraColors.cyan;
  static const success = AuroraColors.success;
  static const warning = AuroraColors.warning;
  static const error = AuroraColors.error;
  static const info = AuroraColors.info;

  // 文字层级
  static const textPrimary = AuroraColors.text1;
  static const textSecondary = AuroraColors.text2;
  static const textMuted = AuroraColors.text3;
  static const textPlaceholder = AuroraColors.text4;

  // 边框
  static const border = AuroraColors.border;
  static const borderGlow = AuroraColors.borderStrong;

  // 渐变
  static const gradientPrimary = AuroraColors.gradientPrimary;
  static const gradientGold = LinearGradient(
    colors: [Color(0xFFFFB347), Color(0xFFE89530)],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  );
  static const gradientMesh = LinearGradient(
    colors: [Color(0x0A7C6BF0), Color(0x0AFFB347), Color(0x0A4ECDC4)],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  );
}

/// 间距系统
class AppSpacing {
  static const xs = AuroraSpacing.sp1;
  static const sm = AuroraSpacing.sp2;
  static const md = AuroraSpacing.sp4;
  static const lg = AuroraSpacing.sp6;
  static const xl = AuroraSpacing.sp8;
  static const xxl = AuroraSpacing.sp12;
}

/// 圆角系统
class AppRadius {
  static const sm = Radius.circular(AuroraRadius.sm);
  static const md = Radius.circular(AuroraRadius.md);
  static const lg = Radius.circular(AuroraRadius.lg);
  static const xl = Radius.circular(AuroraRadius.xl);
  static const full = Radius.circular(AuroraRadius.full);
}

/// 阴影系统
class AppShadows {
  static List<BoxShadow> get soft => AuroraShadows.sm;
  static List<BoxShadow> get medium => AuroraShadows.md;
  static List<BoxShadow> glow(Color color) => [BoxShadow(color: color.withOpacity(0.15), blurRadius: 24)];
}

class AppTheme {
  static ThemeData get dark => AuroraTheme.dark;
}

/// 预制装饰
class AppDecorations {
  static BoxDecoration glassCard({double radius = AuroraRadius.lg}) => BoxDecoration(
    color: AuroraColors.bg2,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: AuroraColors.border, width: 1),
  );

  static BoxDecoration glowCard({Color glowColor = AuroraColors.primary}) => BoxDecoration(
    color: AuroraColors.bg2,
    borderRadius: BorderRadius.circular(AuroraRadius.lg),
    border: Border.all(color: AuroraColors.border, width: 1),
    boxShadow: [BoxShadow(color: glowColor.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 4))],
  );

  static BoxDecoration gradientTopCard({double radius = AuroraRadius.lg}) => BoxDecoration(
    color: AuroraColors.bg2,
    borderRadius: BorderRadius.circular(radius),
    gradient: const LinearGradient(
      colors: [Color(0x107C6BF0), Color(0x00000000)],
      begin: Alignment.topCenter, end: Alignment.bottomCenter,
    ),
    border: Border.all(color: AuroraColors.border, width: 1),
  );

  static BoxDecoration avatar({double size = 44, Color? color}) => BoxDecoration(
    gradient: AuroraColors.gradientPrimary,
    borderRadius: BorderRadius.circular(size / 3),
  );

  static BoxDecoration emptyIcon({Color? color}) => BoxDecoration(
    shape: BoxShape.circle,
    gradient: LinearGradient(
      colors: [(color ?? AuroraColors.primary).withOpacity(0.12), (color ?? AuroraColors.primary).withOpacity(0.04)],
      begin: Alignment.topCenter, end: Alignment.bottomCenter,
    ),
  );
}
