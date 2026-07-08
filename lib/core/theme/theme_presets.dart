import 'package:flutter/material.dart';

/// 预设主题风格
enum AppThemeStyle {
  cyberpunk('赛博朋克', '🌃', '霓虹灯下的未来都市'),
  fantasy('奇幻', '🧙', '魔法与冒险的世界'),
  medieval('中世纪', '⚔️', '骑士与城堡的时代'),
  ancient('古风', '🏯', '东方古典韵味'),
  campus('校园', '🎓', '青春洋溢的校园生活'),
  workplace('职场', '💼', '现代都市职场'),
  scifi('科幻', '🚀', '星际探索的未来'),
  horror('恐怖', '👻', '黑暗惊悚风格'),
  romance('浪漫', '💕', '甜蜜浪漫的氛围'),
  minimalist('极简', '✨', '简洁清爽的风格');

  final String label;
  final String emoji;
  final String description;
  const AppThemeStyle(this.label, this.emoji, this.description);
}

/// 主题配色方案
class ThemeColors {
  final Color primary;
  final Color secondary;
  final Color background;
  final Color surface;
  final Color card;
  final Color textPrimary;
  final Color textSecondary;
  final Color accent;
  final Gradient? gradient;
  final Gradient? cardGradient;

  const ThemeColors({
    required this.primary,
    required this.secondary,
    required this.background,
    required this.surface,
    required this.card,
    required this.textPrimary,
    required this.textSecondary,
    required this.accent,
    this.gradient,
    this.cardGradient,
  });
}

/// 预设主题配色
class AppThemePresets {
  // 赛博朋克
  static const cyberpunk = ThemeColors(
    primary: Color(0xFF00FFD4),
    secondary: Color(0xFFFF00FF),
    background: Color(0xFF0A0A1A),
    surface: Color(0xFF141428),
    card: Color(0xFF1A1A35),
    textPrimary: Color(0xFFE0E0FF),
    textSecondary: Color(0xFF8888AA),
    accent: Color(0xFFFF3366),
    gradient: LinearGradient(colors: [Color(0xFF00FFD4), Color(0xFF00AAFF)]),
    cardGradient: LinearGradient(colors: [Color(0xFF1A1A35), Color(0xFF252550)]),
  );

  // 奇幻
  static const fantasy = ThemeColors(
    primary: Color(0xFF9C27B0),
    secondary: Color(0xFFFFD700),
    background: Color(0xFF0D0B1A),
    surface: Color(0xFF1A1530),
    card: Color(0xFF221E3D),
    textPrimary: Color(0xFFE8E0FF),
    textSecondary: Color(0xFF9990BB),
    accent: Color(0xFF7C4DFF),
    gradient: LinearGradient(colors: [Color(0xFF9C27B0), Color(0xFF7C4DFF)]),
    cardGradient: LinearGradient(colors: [Color(0xFF221E3D), Color(0xFF2D2855)]),
  );

  // 中世纪
  static const medieval = ThemeColors(
    primary: Color(0xFF8B4513),
    secondary: Color(0xFFDAA520),
    background: Color(0xFF1A1410),
    surface: Color(0xFF2A2218),
    card: Color(0xFF352B1E),
    textPrimary: Color(0xFFF5E6D3),
    textSecondary: Color(0xFFB8A090),
    accent: Color(0xFFCD853F),
    gradient: LinearGradient(colors: [Color(0xFF8B4513), Color(0xFFCD853F)]),
    cardGradient: LinearGradient(colors: [Color(0xFF352B1E), Color(0xFF4A3C2A)]),
  );

  // 古风
  static const ancient = ThemeColors(
    primary: Color(0xFFB22222),
    secondary: Color(0xFFFFD700),
    background: Color(0xFF1A0F0F),
    surface: Color(0xFF2A1A1A),
    card: Color(0xFF352020),
    textPrimary: Color(0xFFFFF0E0),
    textSecondary: Color(0xFFCCAA88),
    accent: Color(0xFFDC143C),
    gradient: LinearGradient(colors: [Color(0xFFB22222), Color(0xFFDC143C)]),
    cardGradient: LinearGradient(colors: [Color(0xFF352020), Color(0xFF4A2828)]),
  );

  // 校园
  static const campus = ThemeColors(
    primary: Color(0xFF4A90D9),
    secondary: Color(0xFF50C878),
    background: Color(0xFFF0F4F8),
    surface: Color(0xFFFFFFFF),
    card: Color(0xFFF8FAFC),
    textPrimary: Color(0xFF1E293B),
    textSecondary: Color(0xFF64748B),
    accent: Color(0xFF6366F1),
    gradient: LinearGradient(colors: [Color(0xFF4A90D9), Color(0xFF6366F1)]),
    cardGradient: LinearGradient(colors: [Color(0xFFF8FAFC), Color(0xFFEFF6FF)]),
  );

  // 职场
  static const workplace = ThemeColors(
    primary: Color(0xFF1E3A5F),
    secondary: Color(0xFF3B82F6),
    background: Color(0xFFF5F7FA),
    surface: Color(0xFFFFFFFF),
    card: Color(0xFFFAFBFC),
    textPrimary: Color(0xFF111827),
    textSecondary: Color(0xFF6B7280),
    accent: Color(0xFF2563EB),
    gradient: LinearGradient(colors: [Color(0xFF1E3A5F), Color(0xFF3B82F6)]),
    cardGradient: LinearGradient(colors: [Color(0xFFFAFBFC), Color(0xFFF0F4FF)]),
  );

  // 科幻
  static const scifi = ThemeColors(
    primary: Color(0xFF00BCD4),
    secondary: Color(0xFF3F51B5),
    background: Color(0xFF0A0E1A),
    surface: Color(0xFF111827),
    card: Color(0xFF1A2332),
    textPrimary: Color(0xFFE0F0FF),
    textSecondary: Color(0xFF7B8FA8),
    accent: Color(0xFF00E5FF),
    gradient: LinearGradient(colors: [Color(0xFF00BCD4), Color(0xFF00E5FF)]),
    cardGradient: LinearGradient(colors: [Color(0xFF1A2332), Color(0xFF243044)]),
  );

  // 恐怖
  static const horror = ThemeColors(
    primary: Color(0xFF8B0000),
    secondary: Color(0xFF2D0A0A),
    background: Color(0xFF0A0505),
    surface: Color(0xFF1A0A0A),
    card: Color(0xFF250F0F),
    textPrimary: Color(0xFFE0C0C0),
    textSecondary: Color(0xFF8B6060),
    accent: Color(0xFFFF2020),
    gradient: LinearGradient(colors: [Color(0xFF8B0000), Color(0xFFFF2020)]),
    cardGradient: LinearGradient(colors: [Color(0xFF250F0F), Color(0xFF351515)]),
  );

  // 浪漫
  static const romance = ThemeColors(
    primary: Color(0xFFE91E63),
    secondary: Color(0xFFFF69B4),
    background: Color(0xFFFFF0F5),
    surface: Color(0xFFFFFFFF),
    card: Color(0xFFFFF5F8),
    textPrimary: Color(0xFF4A1030),
    textSecondary: Color(0xFF996080),
    accent: Color(0xFFFF1493),
    gradient: LinearGradient(colors: [Color(0xFFE91E63), Color(0xFFFF69B4)]),
    cardGradient: LinearGradient(colors: [Color(0xFFFFF5F8), Color(0xFFFFE0EC)]),
  );

  // 极简
  static const minimalist = ThemeColors(
    primary: Color(0xFF2D3748),
    secondary: Color(0xFF4A5568),
    background: Color(0xFFFFFFFF),
    surface: Color(0xFFF7FAFC),
    card: Color(0xFFFFFFFF),
    textPrimary: Color(0xFF1A202C),
    textSecondary: Color(0xFF718096),
    accent: Color(0xFF3182CE),
    gradient: LinearGradient(colors: [Color(0xFF2D3748), Color(0xFF4A5568)]),
    cardGradient: LinearGradient(colors: [Color(0xFFFFFFFF), Color(0xFFF7FAFC)]),
  );

  /// 根据主题风格获取配色
  static ThemeColors getColors(AppThemeStyle style) {
    switch (style) {
      case AppThemeStyle.cyberpunk: return cyberpunk;
      case AppThemeStyle.fantasy: return fantasy;
      case AppThemeStyle.medieval: return medieval;
      case AppThemeStyle.ancient: return ancient;
      case AppThemeStyle.campus: return campus;
      case AppThemeStyle.workplace: return workplace;
      case AppThemeStyle.scifi: return scifi;
      case AppThemeStyle.horror: return horror;
      case AppThemeStyle.romance: return romance;
      case AppThemeStyle.minimalist: return minimalist;
    }
  }

  /// 获取所有预设主题
  static List<MapEntry<AppThemeStyle, ThemeColors>> getAll() {
    return AppThemeStyle.values.map((s) => MapEntry(s, getColors(s))).toList();
  }
}
