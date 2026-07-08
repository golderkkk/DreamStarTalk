import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'theme_presets.dart';
import 'aurora_theme.dart';

/// 自定义主题配置
class CustomThemeConfig {
  final Color primary;
  final Color secondary;
  final Color background;
  final Color surface;
  final Color card;
  final Color textPrimary;
  final Color textSecondary;
  final Color accent;

  const CustomThemeConfig({
    required this.primary,
    required this.secondary,
    required this.background,
    required this.surface,
    required this.card,
    required this.textPrimary,
    required this.textSecondary,
    required this.accent,
  });

  Map<String, dynamic> toJson() => {
    'primary': primary.value,
    'secondary': secondary.value,
    'background': background.value,
    'surface': surface.value,
    'card': card.value,
    'textPrimary': textPrimary.value,
    'textSecondary': textSecondary.value,
    'accent': accent.value,
  };

  factory CustomThemeConfig.fromJson(Map<String, dynamic> json) => CustomThemeConfig(
    primary: Color(json['primary'] as int),
    secondary: Color(json['secondary'] as int),
    background: Color(json['background'] as int),
    surface: Color(json['surface'] as int),
    card: Color(json['card'] as int),
    textPrimary: Color(json['textPrimary'] as int),
    textSecondary: Color(json['textSecondary'] as int),
    accent: Color(json['accent'] as int),
  );

  ThemeColors toThemeColors() => ThemeColors(
    primary: primary,
    secondary: secondary,
    background: background,
    surface: surface,
    card: card,
    textPrimary: textPrimary,
    textSecondary: textSecondary,
    accent: accent,
  );
}

/// 主题管理状态
class ThemeState {
  final AppThemeStyle currentStyle;
  final ThemeColors colors;
  final bool isDark;
  final bool isCustom;
  final CustomThemeConfig? customConfig;

  const ThemeState({
    this.currentStyle = AppThemeStyle.cyberpunk,
    required this.colors,
    this.isDark = true,
    this.isCustom = false,
    this.customConfig,
  });

  ThemeState copyWith({
    AppThemeStyle? currentStyle,
    ThemeColors? colors,
    bool? isDark,
    bool? isCustom,
    CustomThemeConfig? customConfig,
  }) {
    return ThemeState(
      currentStyle: currentStyle ?? this.currentStyle,
      colors: colors ?? this.colors,
      isDark: isDark ?? this.isDark,
      isCustom: isCustom ?? this.isCustom,
      customConfig: customConfig ?? this.customConfig,
    );
  }
}

/// 主题管理器
class ThemeNotifier extends StateNotifier<ThemeState> {
  Box? _box;

  ThemeNotifier() : super(ThemeState(colors: AppThemePresets.cyberpunk)) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    _box = await Hive.openBox('theme_settings');
    final styleName = _box?.get('style') as String?;
    final isDark = _box?.get('isDark') as bool? ?? true;
    final isCustom = _box?.get('isCustom') as bool? ?? false;
    final customJson = _box?.get('customConfig') as Map?;

    if (isCustom && customJson != null) {
      final customConfig = CustomThemeConfig.fromJson(Map<String, dynamic>.from(customJson));
      state = ThemeState(
        currentStyle: AppThemeStyle.cyberpunk,
        colors: customConfig.toThemeColors(),
        isDark: isDark,
        isCustom: true,
        customConfig: customConfig,
      );
    } else if (styleName != null) {
      final style = AppThemeStyle.values.where((s) => s.name == styleName).firstOrNull;
      if (style != null) {
        state = ThemeState(
          currentStyle: style,
          colors: AppThemePresets.getColors(style),
          isDark: isDark,
        );
      }
    }
  }

  /// 切换预设主题（实时生效）
  Future<void> setThemeStyle(AppThemeStyle style) async {
    state = ThemeState(
      currentStyle: style,
      colors: AppThemePresets.getColors(style),
      isDark: state.isDark,
      isCustom: false,
    );
    await _box?.put('style', style.name);
    await _box?.put('isCustom', false);
  }

  /// 应用自定义主题（实时生效）
  Future<void> setCustomTheme(CustomThemeConfig config) async {
    state = ThemeState(
      currentStyle: state.currentStyle,
      colors: config.toThemeColors(),
      isDark: state.isDark,
      isCustom: true,
      customConfig: config,
    );
    await _box?.put('isCustom', true);
    await _box?.put('customConfig', config.toJson());
  }

  /// 切换明暗模式（实时生效）
  Future<void> toggleDarkMode() async {
    state = state.copyWith(isDark: !state.isDark);
    await _box?.put('isDark', state.isDark);
  }

  /// 生成 ThemeData — 统一使用 Aurora 设计系统
  /// 保留旧版 ThemeColors 用于自定义主题切换，但基础 ThemeData 始终基于 Aurora
  ThemeData get themeData {
    // 如果是自定义主题，使用自定义颜色生成覆盖的 Aurora 主题
    if (state.isCustom && state.customConfig != null) {
      return _buildCustomAuroraTheme(state.customConfig!);
    }
    // 默认使用 Aurora 暗色主题
    return AuroraTheme.dark;
  }

  /// 基于自定义配置生成 Aurora 风格主题
  ThemeData _buildCustomAuroraTheme(CustomThemeConfig config) {
    return AuroraTheme.dark.copyWith(
      colorScheme: ColorScheme.dark(
        primary: config.primary,
        secondary: config.secondary,
        surface: AuroraColors.bg1,
        error: AuroraColors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.black,
        onSurface: AuroraColors.text1,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: AuroraColors.bg0,
    );
  }
}

/// 主题 Provider
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeState>((ref) {
  return ThemeNotifier();
});
