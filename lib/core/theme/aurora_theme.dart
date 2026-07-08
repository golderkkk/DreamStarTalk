import 'package:flutter/material.dart';

/// Aurora 设计系统 — 沉浸式极简 · 极光深度
/// 参考: AURORA_DESIGN_SYSTEM.md
class AuroraColors {
  // ── 背景层次 (5 级) ──
  static const bg0 = Color(0xFF08080C);  // 最底层 · 应用背景
  static const bg1 = Color(0xFF0E0E15);  // 表面 1 · 页面
  static const bg2 = Color(0xFF14141E);  // 表面 2 · 卡片
  static const bg3 = Color(0xFF1A1A26);  // 表面 3 · 悬浮 / 激活态
  static const bg4 = Color(0xFF22222F);  // 表面 4 · 弹层

  // ── 主色 — 极光紫罗兰 ──
  static const primary = Color(0xFF7C6BF0);
  static const primaryHover = Color(0xFF8B7BF5);
  static const primaryActive = Color(0xFF6B5AE0);
  static const primaryGlow = Color(0xFF9D8BFF);
  static const primarySoft = Color(0x1F7C6BF0);       // rgba(124,107,240,0.12)
  static const primaryBorder = Color(0x407C6BF0);     // rgba(124,107,240,0.25)

  // ── 强调色 ──
  static const amber = Color(0xFFFFB347);
  static const cyan = Color(0xFF4ECDC4);
  static const rose = Color(0xFFFB7185);

  // ── 语义色 ──
  static const success = Color(0xFF34D399);
  static const warning = Color(0xFFFBBF24);
  static const error = Color(0xFFFB7185);
  static const info = Color(0xFF60A5FA);

  // ── 文字层级 (4 级) ──
  static const text1 = Color(0xFFF5F5F7);  // 主标题 / 正文
  static const text2 = Color(0xFFB4B4C4);  // 次要文字
  static const text3 = Color(0xFF7A7A8E);  // 辅助文字
  static const text4 = Color(0xFF4A4A5C);  // 占位 / 禁用

  // ── 边框 ──
  static const border = Color(0x0FFFFFFF);       // rgba(255,255,255,0.06)
  static const borderStrong = Color(0x1AFFFFFF);  // rgba(255,255,255,0.1)
  static const borderPrimary = Color(0x4D7C6BF0); // rgba(124,107,240,0.3)

  // ── 渐变 ──
  static const gradientPrimary = LinearGradient(
    colors: [primary, primaryActive],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const gradientGlow = LinearGradient(
    colors: [primaryGlow, cyan],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

/// 间距系统 — 4pt 基准网格
class AuroraSpacing {
  static const sp1 = 4.0;
  static const sp2 = 8.0;
  static const sp3 = 12.0;
  static const sp4 = 16.0;
  static const sp5 = 20.0;
  static const sp6 = 24.0;
  static const sp8 = 32.0;
  static const sp10 = 40.0;
  static const sp12 = 48.0;
}

/// 圆角系统
class AuroraRadius {
  static const sm = 8.0;    // 小组件 / Badge
  static const md = 12.0;   // 按钮 / 输入框
  static const lg = 16.0;   // 卡片 / 列表项 / 气泡
  static const xl = 20.0;   // 大卡片 / FAB
  static const xxl = 24.0;  // 弹窗 / 底部面板
  static const full = 9999.0; // 胶囊 / 标签
}

/// 阴影系统
class AuroraShadows {
  static List<BoxShadow> get sm => [
    BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 3, offset: const Offset(0, 1)),
  ];
  static List<BoxShadow> get md => [
    BoxShadow(color: Colors.black.withOpacity(0.35), blurRadius: 12, offset: const Offset(0, 4)),
  ];
  static List<BoxShadow> get lg => [
    BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 32, offset: const Offset(0, 8)),
  ];
  static List<BoxShadow> get glow => [
    BoxShadow(color: AuroraColors.primary.withOpacity(0.15), blurRadius: 24),
  ];
}

/// 动效曲线
class AuroraCurves {
  static const easeOut = Cubic(0.16, 1.0, 0.3, 1.0);
  static const easeSpring = Cubic(0.34, 1.56, 0.64, 1.0);
}

/// 动效时长
class AuroraDuration {
  static const fast = Duration(milliseconds: 150);
  static const normal = Duration(milliseconds: 250);
  static const slow = Duration(milliseconds: 400);
}

/// Aurora 主题
class AuroraTheme {
  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AuroraColors.bg0,
    fontFamily: 'NotoSansSC',
    colorScheme: const ColorScheme.dark(
      primary: AuroraColors.primary,
      secondary: AuroraColors.amber,
      surface: AuroraColors.bg1,
      error: AuroraColors.error,
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onSurface: AuroraColors.text1,
      onError: Colors.white,
    ),

    // AppBar
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: AuroraColors.text1,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: AuroraColors.text1,
        letterSpacing: -0.5,
      ),
    ),

    // 页面过渡
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
      },
    ),

    // 卡片
    cardTheme: CardTheme(
      color: AuroraColors.bg2,
      elevation: 0,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AuroraRadius.lg),
        side: const BorderSide(color: AuroraColors.border, width: 1),
      ),
      margin: EdgeInsets.zero,
    ),

    // 输入框
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AuroraColors.bg2,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AuroraRadius.md),
        borderSide: const BorderSide(color: AuroraColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AuroraRadius.md),
        borderSide: const BorderSide(color: AuroraColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AuroraRadius.md),
        borderSide: const BorderSide(color: AuroraColors.borderPrimary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AuroraRadius.md),
        borderSide: const BorderSide(color: AuroraColors.error),
      ),
      labelStyle: const TextStyle(color: AuroraColors.text3, fontSize: 14),
      hintStyle: const TextStyle(color: AuroraColors.text4, fontSize: 14),
      floatingLabelStyle: const TextStyle(color: AuroraColors.primary, fontSize: 14),
    ),

    // 按钮
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AuroraColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AuroraRadius.md)),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AuroraColors.text2,
        side: const BorderSide(color: AuroraColors.borderStrong),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AuroraRadius.md)),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AuroraColors.primaryGlow,
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),

    // Chips
    chipTheme: ChipThemeData(
      backgroundColor: AuroraColors.bg3,
      selectedColor: AuroraColors.primarySoft,
      labelStyle: const TextStyle(color: AuroraColors.text2, fontSize: 13),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AuroraRadius.full),
        side: const BorderSide(color: AuroraColors.border),
      ),
    ),

    // 底部导航
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AuroraColors.bg1,
      indicatorColor: AuroraColors.primarySoft,
      elevation: 0,
      height: 64,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      iconTheme: WidgetStateProperty.resolveWith((s) => IconThemeData(
        color: s.contains(WidgetState.selected) ? AuroraColors.primaryGlow : AuroraColors.text4,
        size: 24,
      )),
      labelTextStyle: WidgetStateProperty.resolveWith((s) => TextStyle(
        fontSize: 11,
        fontWeight: s.contains(WidgetState.selected) ? FontWeight.w600 : FontWeight.w400,
        color: s.contains(WidgetState.selected) ? AuroraColors.primaryGlow : AuroraColors.text4,
      )),
    ),

    // Dialog
    dialogTheme: DialogTheme(
      backgroundColor: AuroraColors.bg4,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AuroraRadius.xxl)),
      titleTextStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AuroraColors.text1),
    ),

    // SnackBar
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AuroraColors.bg3,
      contentTextStyle: const TextStyle(color: AuroraColors.text1, fontSize: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AuroraRadius.md)),
      behavior: SnackBarBehavior.floating,
    ),

    // TabBar
    tabBarTheme: const TabBarTheme(
      labelColor: AuroraColors.primaryGlow,
      unselectedLabelColor: AuroraColors.text4,
      indicatorColor: AuroraColors.primary,
      indicatorSize: TabBarIndicatorSize.label,
      labelStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      unselectedLabelStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
      dividerColor: Colors.transparent,
    ),

    dividerTheme: const DividerThemeData(color: AuroraColors.border, space: 1, thickness: 1),

    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AuroraColors.primary,
      linearTrackColor: AuroraColors.bg3,
    ),

    // 文字系统
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: AuroraColors.text1, letterSpacing: -1, height: 1.2),
      displayMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AuroraColors.text1, letterSpacing: -0.5, height: 1.3),
      headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AuroraColors.text1, letterSpacing: -0.3, height: 1.4),
      titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AuroraColors.text1, height: 1.4),
      titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AuroraColors.text1, height: 1.4),
      bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: AuroraColors.text1, height: 1.6),
      bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: AuroraColors.text2, height: 1.5),
      bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: AuroraColors.text3, height: 1.4),
      labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AuroraColors.text1),
      labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AuroraColors.text2),
      labelSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AuroraColors.text3, letterSpacing: 0.8),
    ),
  );
}
