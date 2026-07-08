# AI Chat Studio — Aurora 设计系统规范

> **版本**: Aurora v3.0 | **日期**: 2026-07-06 | **设计**: UI Designer
> **适用**: Flutter App (移动端优先) + PC 自适应

---

## 一、设计理念

### Aurora — 沉浸式极简 · 极光深度

当前 UI 存在的核心问题：紫黑配色 + 玻璃态是 AI 应用标配，缺乏辨识度；卡片与背景层次扁平，信息层级模糊；交互操作过度依赖底部弹窗，路径冗长。

Aurora 设计语言通过三个核心策略解决这些问题：

| 策略 | 说明 | 解决的问题 |
|------|------|-----------|
| **深度分层** | 5 级背景层次构建空间感，用明度差替代边框 | 层级扁平、卡片不分明 |
| **克制色彩** | 降低主色饱和度，引入暖色强调点缀 | 配色趋同、辨识度低 |
| **就近交互** | 操作按钮贴近内容，减少弹窗跳转 | 交互路径冗长 |

---

## 二、色彩系统

### 2.1 背景层次 (5 级)

```
BG-0  #08080C  ████████  最底层 · 应用背景
BG-1  #0E0E15  ████████  表面 1 · 页面
BG-2  #14141E  ████████  表面 2 · 卡片
BG-3  #1A1A26  ████████  表面 3 · 悬浮 / 激活态
BG-4  #22222F  ████████  表面 4 · 弹层
```

**原则**: 相邻层级明度差 ≥ 5%，确保肉眼可辨。卡片无需粗边框，仅用 `rgba(255,255,255,0.06)` 微边框点缀。

### 2.2 主色 — 极光紫罗兰

```
Primary        #7C6BF0  ████████  主操作色
Primary Hover  #8B7BF5  ████████  悬停态
Primary Active #6B5AE0  ████████  按压态
Primary Glow   #9D8BFF  ████████  发光 / 文字强调
Primary Soft   rgba(124,107,240,0.12)  背景填充
Primary Border rgba(124,107,240,0.25)  聚焦边框
```

**对比旧方案**: 原 `#8B5CF6` 饱和度过高，偏"科技感通用紫"。新 `#7C6BF0` 降低饱和度、微调色相，更具高级感。

### 2.3 强调色 (3 色)

```
Amber  #FFB347  ████████  暖色强调 · 角色 / TTS
Cyan   #4ECDC4  ████████  冷色强调 · 多角色 / 在线
Rose   #FB7185  ████████  警示强调 · 危险 / NSFW
```

**使用规则**: 每屏最多出现 2 种强调色，避免色彩混乱。主色占 60%，强调色占 10%，中性色占 30%。

### 2.4 语义色

```
Success #34D399  ████████  成功 / 在线 / 启用
Warning #FBBF24  ████████  警告
Error   #FB7185  ████████  错误 / 删除
Info    #60A5FA  ████████  信息 / 链接
```

### 2.5 文字层级 (4 级)

```
Text 1  #F5F5F7  ████████  主标题 / 正文 (对比度 17:1)
Text 2  #B4B4C4  ████████  次要文字 (对比度 11:1)
Text 3  #7A7A8E  ████████  辅助文字 (对比度 5.2:1)
Text 4  #4A4A5C  ████████  占位 / 禁用 (装饰性)
```

**WCAG 合规**: Text 1-3 均满足 AA 标准 (4.5:1)。Text 4 仅用于非关键装饰元素。

### 2.6 边框

```
Border         rgba(255,255,255,0.06)   默认边框
Border Strong  rgba(255,255,255,0.10)   悬停边框
Border Primary rgba(124,107,240,0.30)   聚焦边框
```

---

## 三、字体系统

### 3.1 字体族

```
主字体: -apple-system, 'SF Pro Display', 'PingFang SC', 'Microsoft YaHei', sans-serif
等宽:   'SF Mono', 'JetBrains Mono', 'Fira Code', monospace
```

### 3.2 字号阶梯

| 名称 | 字号 | 字重 | 行高 | 字距 | 用途 |
|------|------|------|------|------|------|
| Display | 32px | 700 | 1.2 | -1px | 启动页 / 空状态大标题 |
| H1 | 24px | 700 | 1.3 | -0.5px | 页面主标题 |
| H2 | 18px | 600 | 1.4 | -0.3px | 区块标题 |
| Title | 16px | 600 | 1.4 | 0 | 卡片标题 |
| Body | 14px | 400 | 1.6 | 0 | 正文 / 消息内容 |
| Caption | 12px | 400 | 1.5 | 0 | 辅助说明 / 时间戳 |
| Overline | 11px | 600 | 1.4 | 0.8px | 分组标签 (大写) |

### 3.3 Flutter TextTheme 映射

```dart
displayLarge:   32 / w700 / -1.0 / 1.2
displayMedium:  24 / w700 / -0.5 / 1.3
headlineMedium: 20 / w600 / -0.3 / 1.4
titleLarge:     18 / w600 / 0 / 1.4
titleMedium:    16 / w600 / 0 / 1.4
bodyLarge:      16 / w400 / 0 / 1.6
bodyMedium:     14 / w400 / 0 / 1.5
bodySmall:      12 / w400 / 0 / 1.4
labelSmall:     11 / w600 / 0.8 / 1.4 (大写)
```

---

## 四、间距系统

### 4pt 基准网格

```
sp-1   4px    ████        图标内距 / 微间距
sp-2   8px    ████████    元素间距 / 紧凑内距
sp-3  12px    ████████████  卡片内距 / 列表间距
sp-4  16px    ████████████████  标准内距 / 页面边距
sp-5  20px    ████████████████████  卡片间距
sp-6  24px    ████████████████████████  区块间距
sp-8  32px    ████████████████████████████████  大区块间距
sp-12 48px    ████████████████████████████████████████████████████  页面分区
```

---

## 五、圆角系统

```
r-sm    8px    小组件 / Badge / 输入框图标
r-md   12px    按钮 / 输入框 / 小卡片
r-lg   16px    卡片 / 列表项 / 对话气泡
r-xl   20px    大卡片 / FAB
r-2xl  24px    弹窗 / 底部面板
r-full 9999px  胶囊 / 头像组 / 标签
```

**规则**: 元素越大，圆角越大。消息气泡使用非对称圆角 (对角 4px) 指向发送者。

---

## 六、阴影与发光

```
shadow-sm   0 1px 3px rgba(0,0,0,0.3)      卡片默认
shadow-md   0 4px 12px rgba(0,0,0,0.35)     卡片悬停
shadow-lg   0 8px 32px rgba(0,0,0,0.4)      弹层 / 对话框
shadow-glow 0 0 24px rgba(124,107,240,0.15)  主色发光元素
```

**原则**: 深色主题中阴影需更深 (0.3-0.4 透明度)。发光仅用于主色元素，避免滥用。

---

## 七、动效规范

### 7.1 缓动曲线

```
ease-out    cubic-bezier(0.16, 1, 0.3, 1)    状态过渡 (入场 / 消失)
ease-spring cubic-bezier(0.34, 1.56, 0.64, 1) 交互反馈 (按压 / 弹出)
```

### 7.2 时长

```
dur-fast   150ms  微交互 (按钮悬停 / 颜色变化)
dur-normal 250ms  标准过渡 (面板展开 / 卡片移动)
dur-slow   400ms  大范围动画 (页面切换 / 列表入场)
```

### 7.3 交互反馈

| 交互 | 反馈 | 参数 |
|------|------|------|
| 卡片按压 | 缩放 | scale(0.97), 120ms, ease-out |
| 列表项按压 | 缩放 | scale(0.98), 120ms |
| FAB 点击 | 缩放+旋转 | scale(0.88) rotate(90deg), 250ms, spring |
| 发送按钮 | 缩放 | scale(0.85), 150ms |
| 消息入场 | 上移+淡入 | translateY(8px)→0 + opacity, 250ms |
| 打字指示 | 弹跳 | translateY(-4px), 1.2s 循环 |

---

## 八、组件规范

### 8.1 按钮

```
┌─ Primary ──────────────────────┐
│  bg: linear-gradient(135deg, #7C6BF0, #6B5AE0)
│  color: #FFFFFF
│  padding: 10px 18px
│  radius: 12px
│  shadow: 0 4px 12px rgba(124,107,240,0.25)
│  hover: translateY(-1px) + shadow 增强
└────────────────────────────────┘

┌─ Secondary ────────────────────┐
│  bg: #1A1A26 (BG-3)
│  border: 1px solid rgba(255,255,255,0.1)
│  color: #F5F5F7
└────────────────────────────────┘

┌─ Ghost ────────────────────────┐
│  bg: transparent
│  color: #9D8BFF (Primary Glow)
│  hover: bg rgba(124,107,240,0.12)
└────────────────────────────────┘

┌─ Danger ───────────────────────┐
│  bg: rgba(251,113,133,0.12)
│  color: #FB7185
└────────────────────────────────┘
```

### 8.2 消息气泡

```
AI 消息:
  bg: #14141E (BG-2)
  border: 1px solid rgba(255,255,255,0.06)
  radius: 16px (左上角 4px)
  color: #F5F5F7
  padding: 10px 14px

用户消息:
  bg: linear-gradient(135deg, #7C6BF0, #6B5AE0)
  radius: 16px (右上角 4px)
  color: #FFFFFF
  padding: 10px 14px

富文本:
  *动作* → color: #7A7A8E, font-style: italic
  "对话" → color: #9D8BFF (AI) / rgba(255,255,255,0.85) (用户)
```

### 8.3 底部导航 (移动端)

```
高度: 76px (含安全区)
背景: rgba(14,14,21,0.85) + backdrop-blur(24px)
边框: top 1px solid rgba(255,255,255,0.06)

活跃态:
  图标: color #9D8BFF + drop-shadow(0 2px 8px rgba(124,107,240,0.4))
  文字: color #9D8BFF, w500
  指示器: 顶部 24×3px 圆角条 + 发光

非活跃态:
  图标/文字: color #4A4A5C
```

**对比旧方案**: 旧浮动圆角底栏占用空间大且活跃态不明确。新方案改为贴底半透明栏 + 顶部发光指示条，活跃态一目了然。

### 8.4 桌面侧边栏 (PC 自适应)

```
宽度: 260px
背景: #0E0E15 (BG-1)
右边框: 1px solid rgba(255,255,255,0.06)

导航项:
  padding: 10px 14px
  radius: 12px
  活跃: bg rgba(124,107,240,0.12), color #9D8BFF
  悬停: bg #14141E, color #B4B4C4
```

### 8.5 卡片 (角色卡 / 对话卡)

```
背景: #14141E (BG-2)
边框: 1px solid rgba(255,255,255,0.06)
圆角: 16px
悬停: border rgba(255,255,255,0.1) + translateY(-2px) + shadow-md
按压: scale(0.97)
```

### 8.6 输入框

```
背景: #14141E (BG-2)
边框: 1px solid rgba(255,255,255,0.06)
圆角: 12px
内距: 10px 14px
聚焦: border rgba(124,107,240,0.3) + 无额外阴影 (深色主题)
```

---

## 九、响应式策略

### 9.1 断点

```
Mobile  < 768px    单列布局, 底部导航, FAB
Tablet  768-1024px 双列布局 (列表+详情), 底部导航
Desktop > 1024px   三栏布局 (侧栏+列表+详情), 侧边导航
```

### 9.2 布局适配

| 组件 | Mobile | Desktop |
|------|--------|---------|
| 导航 | 底部 TabBar (4 项) | 左侧 Sidebar (260px) |
| 对话 | 全屏聊天页 | 列表面板 (320px) + 聊天区 |
| 角色 | 2 列网格 | 自适应网格 (minmax 200px) |
| FAB | 右下角浮动 | 融入列表头部按钮 |
| 搜索 | AppBar 内切换 | Topbar 常驻搜索框 |

### 9.3 Flutter 实现要点

```dart
// 使用 LayoutBuilder 判断断点
LayoutBuilder(builder: (context, constraints) {
  final isDesktop = constraints.maxWidth > 1024;
  return isDesktop ? DesktopLayout() : MobileLayout();
});
```

---

## 十、交互改进清单

### 对比旧版的关键改进

| 问题 | 旧方案 | Aurora 方案 |
|------|--------|------------|
| 导航活跃态不明确 | 背景色微变 + 图标变色 | 顶部发光指示条 + 图标投影 |
| 消息操作隐藏 | 长按弹出菜单 | 悬停显示行内操作按钮 |
| 快捷回复无引导 | 无 | 消息下方横向滚动快捷回复 Chips |
| 设置项扁平 | 单一列表 | 分组卡片 + 语义化图标 |
| 多角色标识弱 | 文字 "N人" | 堆叠头像 + 青色标签 |
| 搜索入口隐藏 | AppBar 按钮切换 | 常驻搜索栏 (角色页) / Topbar (桌面) |
| 对话未分组 | 平铺列表 | 按时间分组 (今天/昨天/更早) |

---

## 十一、Flutter 实现映射

### 11.1 Token 转换

```dart
// lib/core/theme/aurora_theme.dart
class AuroraColors {
  // 背景
  static const bg0 = Color(0xFF08080C);
  static const bg1 = Color(0xFF0E0E15);
  static const bg2 = Color(0xFF14141E);
  static const bg3 = Color(0xFF1A1A26);
  static const bg4 = Color(0xFF22222F);

  // 主色
  static const primary = Color(0xFF7C6BF0);
  static const primaryHover = Color(0xFF8B7BF5);
  static const primaryActive = Color(0xFF6B5AE0);
  static const primaryGlow = Color(0xFF9D8BFF);

  // 强调
  static const amber = Color(0xFFFFB347);
  static const cyan = Color(0xFF4ECDC4);
  static const rose = Color(0xFFFB7185);

  // 文字
  static const text1 = Color(0xFFF5F5F7);
  static const text2 = Color(0xFFB4B4C4);
  static const text3 = Color(0xFF7A7A8E);
  static const text4 = Color(0xFF4A4A5C);
}
```

### 11.2 迁移步骤

1. **替换 `app_theme.dart`** 中的 `AppColors` 为 `AuroraColors`
2. **更新 `AppSpacing`** 增加 `sp5 = 20.0`
3. **更新 `AppRadius`** 增加 `rXl = 20.0`, `r2xl = 24.0`
4. **重构底部导航** `shell.dart` — 贴底栏 + 指示条
5. **重构对话列表** — 时间分组 + 堆叠头像
6. **重构聊天页** — 消息悬停操作 + 快捷回复
7. **重构设置页** — 分组卡片 + 语义图标
8. **新增响应式** — `LayoutBuilder` 桌面三栏布局

---

**设计**: UI Designer · Aurora v3.0
**状态**: 已完成，可进入开发对接
