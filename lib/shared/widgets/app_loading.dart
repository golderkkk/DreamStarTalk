import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../core/theme/aurora_theme.dart';

/// 统一的加载动画组件
/// 提供多种加载样式，保持应用视觉一致性
class AppLoadingIndicator extends StatelessWidget {
  final double size;
  final Color? color;
  final LoadingStyle style;

  const AppLoadingIndicator({
    super.key,
    this.size = 36,
    this.color,
    this.style = LoadingStyle.pulse,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? AuroraColors.primary;

    switch (style) {
      case LoadingStyle.pulse:
        return SpinKitPulse(color: effectiveColor, size: size);
      case LoadingStyle.dualRing:
        return SpinKitDualRing(color: effectiveColor, size: size, lineWidth: 3);
      case LoadingStyle.fadingCube:
        return SpinKitFadingCube(color: effectiveColor, size: size * 0.6);
      case LoadingStyle.wave:
        return SpinKitWave(color: effectiveColor, size: size * 0.6, itemCount: 5);
      case LoadingStyle.circle:
        return SpinKitCircle(color: effectiveColor, size: size);
      case LoadingStyle.threeBounce:
        return SpinKitThreeBounce(color: effectiveColor, size: size * 0.5);
      case LoadingStyle.rotatingPlain:
        return SpinKitRotatingPlain(color: effectiveColor, size: size);
    }
  }
}

enum LoadingStyle {
  pulse,      // 脉冲效果（默认）
  dualRing,   // 双环
  fadingCube, // 渐隐方块
  wave,       // 波浪
  circle,     // 圆圈
  threeBounce, // 三弹跳
  rotatingPlain, // 旋转平面
}

/// 全屏加载状态
class AppLoadingScreen extends StatelessWidget {
  final String? message;

  const AppLoadingScreen({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const AppLoadingIndicator(size: 48, style: LoadingStyle.dualRing),
          if (message != null) ...[
            const SizedBox(height: 20),
            Text(
              message!,
              style: const TextStyle(
                color: AuroraColors.text2,
                fontSize: 14,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// 按钮内加载指示器
class AppButtonLoading extends StatelessWidget {
  final double size;

  const AppButtonLoading({super.key, this.size = 18});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: const SpinKitCircle(color: Colors.white, size: 16),
    );
  }
}
