import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/aurora_theme.dart';

class AppShell extends StatefulWidget {
  final StatefulNavigationShell shell;
  const AppShell({super.key, required this.shell});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  @override
  Widget build(BuildContext context) {
    final isSubPage = _isSubPage(context);
    final isDesktop = MediaQuery.of(context).size.width > 1024;

    if (isDesktop) return _buildDesktopLayout();

    return Scaffold(
      body: widget.shell,
      bottomNavigationBar: isSubPage ? null : _buildMobileTabBar(),
    );
  }

  bool _isSubPage(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/chat/') && location != '/chat') return true;
    if (location.startsWith('/characters/') && location != '/characters') return true;
    if (location.startsWith('/worlds/') && location != '/worlds') return true;
    if (location.startsWith('/settings/') && location != '/settings') return true;
    return false;
  }

  /// 移动端底部导航 — Aurora 风格
  Widget _buildMobileTabBar() {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xD90E0E15), // rgba(14,14,21,0.85)
            border: Border(top: BorderSide(color: AuroraColors.border, width: 1)),
          ),
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: 68,
              child: Row(
                children: [
                  _buildTabItem(Icons.chat_bubble_outline, Icons.chat_bubble, '对话', 0),
                  _buildTabItem(Icons.people_alt_outlined, Icons.people_alt, '角色', 1),
                  _buildTabItem(Icons.public_outlined, Icons.public, '世界观', 2),
                  _buildTabItem(Icons.settings_outlined, Icons.settings, '设置', 3),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabItem(IconData icon, IconData activeIcon, String label, int index) {
    final selected = widget.shell.currentIndex == index;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          if (widget.shell.currentIndex != index) widget.shell.goBranch(index);
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 顶部发光指示条
            AnimatedContainer(
              duration: AuroraDuration.normal,
              curve: AuroraCurves.easeOut,
              width: selected ? 24 : 0,
              height: 3,
              margin: const EdgeInsets.only(bottom: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                color: selected ? AuroraColors.primary : Colors.transparent,
                boxShadow: selected ? [BoxShadow(color: AuroraColors.primary.withOpacity(0.6), blurRadius: 8)] : [],
              ),
            ),
            Icon(
              selected ? activeIcon : icon,
              size: 22,
              color: selected ? AuroraColors.primaryGlow : AuroraColors.text4,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                color: selected ? AuroraColors.primaryGlow : AuroraColors.text4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 桌面端三栏布局
  Widget _buildDesktopLayout() {
    return Scaffold(
      body: Row(
        children: [
          // 侧边导航栏
          _buildDesktopSidebar(),
          // 主内容区
          Expanded(child: widget.shell),
        ],
      ),
    );
  }

  Widget _buildDesktopSidebar() {
    return Container(
      width: 260,
      decoration: const BoxDecoration(
        color: AuroraColors.bg1,
        border: Border(right: BorderSide(color: AuroraColors.border, width: 1)),
      ),
      child: Column(
        children: [
          // Logo
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
            child: Row(
              children: [
                Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                    gradient: AuroraColors.gradientGlow,
                    borderRadius: BorderRadius.circular(AuroraRadius.md),
                    boxShadow: AuroraShadows.glow,
                  ),
                  child: const Center(child: Icon(Icons.auto_awesome, color: Colors.white, size: 18)),
                ),
                const SizedBox(width: 10),
                const Text('拾梦·星语', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AuroraColors.text1)),
              ],
            ),
          ),
          // 导航项
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              children: [
                _buildSidebarItem(Icons.chat_bubble_outline, '对话', 0),
                _buildSidebarItem(Icons.people_alt_outlined, '角色', 1),
                _buildSidebarItem(Icons.public_outlined, '世界观', 2),
                _buildSidebarItem(Icons.settings_outlined, '设置', 3),
              ],
            ),
          ),
          const Spacer(),
          // 版本信息
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Aurora v3.0', style: TextStyle(fontSize: 11, color: AuroraColors.text4)),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(IconData icon, String label, int index) {
    final selected = widget.shell.currentIndex == index;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (widget.shell.currentIndex != index) widget.shell.goBranch(index);
          },
          borderRadius: BorderRadius.circular(AuroraRadius.md),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AuroraRadius.md),
              color: selected ? AuroraColors.primarySoft : Colors.transparent,
            ),
            child: Row(
              children: [
                Icon(icon, size: 20, color: selected ? AuroraColors.primaryGlow : AuroraColors.text3),
                const SizedBox(width: 12),
                Text(label, style: TextStyle(
                  fontSize: 14,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  color: selected ? AuroraColors.primaryGlow : AuroraColors.text3,
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
