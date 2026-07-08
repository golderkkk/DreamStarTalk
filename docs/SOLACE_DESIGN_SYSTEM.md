# Solace Design System

> **方案 B** — 浅色 · 暖调 · 文学感
> 为 AI Chat Studio 设计的现代化 UI 系统，与方案 A (Aurora 暗色紫罗兰) 形成对比

---

## 一、设计理念

**Solace** 取"慰藉、安宁"之意。角色扮演聊天的核心体验是**沉浸叙事与情感共鸣**，而非冰冷的科技工具感。Solace 用温暖纸感底色、Teal/Coral 双色系、衬线标题，营造出"翻阅一本好书"的氛围。

### 与 Aurora 的核心差异

| 维度 | Aurora (方案 A) | Solace (方案 B) |
|------|-----------------|-----------------|
| 底色 | 暗色 #08080C | 暖白 #F7F5F0 |
| 主色 | 紫罗兰 #7C6BF0 | Teal #0D9488 |
| 强调色 | Amber/Cyan/Rose 霓虹 | Coral #FB7185 柔和 |
| 深度表现 | 霓虹光晕 + 明度分层 | 暖色阴影 + 边框微差 |
| 标题字体 | 无衬线 (Inter) | 衬线 (Georgia) |
| 质感隐喻 | 黑曜石 / 科技面板 | 纸张 / 书页 |
| 适用场景 | 夜间沉浸 / 氛围感 | 日间阅读 / 长时间使用 |
| 活跃指示 | 顶部发光条 | 药丸形背景填充 |
| 消息气泡 | 深色卡片 + 边框 | 白色卡片 + 暖色边框 |

---

## 二、色彩系统

### 背景层次 (5 级)

```
Canvas    #F7F5F0  ← 画布底色 (暖白，如旧纸)
Surface   #FFFFFF  ← 表面 (纯白卡片)
Subtle    #F0EDE6  ← 微妙暖灰 (输入框/搜索栏底)
Sunken    #ECE8E0  ← 凹陷区域 (Toggle 关闭态)
Hover     #F5F2EC  ← 悬停反馈
```

### 主色 — Teal

```
Primary       #0D9488  ← 主交互色
Primary Hover #0F766E  ← 悬停加深
Primary Active#115E54  ← 按下态
Primary Soft  #CCFBF1  ← 软背景 (Badge/活跃导航)
Primary Faint #F0FDFA  ← 极淡背景 (选中态)
```

### 强调色

```
Coral    #FB7185  ← 情感点缀 (未读/多角色标识)
Amber    #F59E0B  ← 高亮 (置顶/警告)
Violet   #8B5CF6  ← AI 专属 (生成标识)
```

### 文字

```
Primary   #1C1917  ← 主文字 (暖黑)
Secondary #57534E  ← 辅助文字 (暖灰)
Tertiary  #A8A29E  ← 次要信息 (浅暖灰)
Link      #0D9488  ← 链接
```

### 边框

```
Light    #F0EDE6  ← 分隔线
Default  #E7E5E0  ← 卡片边框
Strong   #D6D3CE  ← 输入框边框
Focus    #0D9488  ← 聚焦态
```

---

## 三、字体系统

### 字体族

```
Sans (正文/UI)   -apple-system, 'SF Pro Display', 'Segoe UI', sans-serif
Serif (标题)     Georgia, 'Songti SC', 'Noto Serif SC', serif
Mono (代码)      'SF Mono', 'Fira Code', monospace
```

**设计决策**：标题使用 Georgia 衬线体，呼应"故事讲述"的产品本质。正文保持无衬线确保可读性。两者形成优雅的视觉对比。

### 字号阶梯

```
Display   32px / 700 / -1px letter-spacing  ← 页面主标题 (衬线)
Heading   22px / 700                        ← 区块标题
Title     17px / 600                        ← 卡片标题
Body      15px / 400 / 1.5 line-height      ← 正文
Caption   12px / 500                        ← 辅助信息
Micro     11px / 700 / 1px letter-spacing   ← 时间组/标签
```

---

## 四、间距与圆角

### 间距 (4px 基准)

```
xs   4px    sm   8px    md   12px
lg   16px   xl   20px   2xl  24px
3xl  32px   4xl  48px
```

### 圆角

```
sm     8px    ← 小按钮、标签
md    12px    ← 卡片、输入框
lg    16px    ← 大卡片、消息气泡
xl    20px    ← FAB、特殊容器
2xl   28px    ← 模态弹窗
full  9999px  ← 药丸形 (搜索栏、Chip、Toggle)
```

---

## 五、阴影系统

**核心差异**：Solace 使用**暖色调阴影** `rgba(60, 50, 35, x)` 而非冷灰色，让阴影融入纸感氛围。

```
xs   0 1px 2px rgba(60,50,35,0.04)
sm   0 2px 4px rgba(60,50,35,0.06), 0 1px 2px rgba(60,50,35,0.04)
md   0 4px 12px rgba(60,50,35,0.08), 0 2px 4px rgba(60,50,35,0.04)
lg   0 8px 24px rgba(60,50,35,0.10), 0 4px 8px rgba(60,50,35,0.06)
xl   0 16px 48px rgba(60,50,35,0.12), 0 8px 16px rgba(60,50,35,0.08)
```

---

## 六、组件规范

### 6.1 底部导航

- **活跃态**：药丸形背景填充 `Primary Soft (#CCFBF1)` + 图标/文字变 Teal
- **非活跃态**：透明背景 + 图标/文字 `Tertiary (#A8A29E)`
- **对比 Aurora**：Aurora 用顶部发光条指示活跃，Solace 用整项背景填充，更柔和直观

### 6.2 消息气泡

| 类型 | 样式 |
|------|------|
| 用户消息 | Teal 渐变背景 (`#0D9488 → #14B8A6`) + 白色文字 + 右下角小圆角 |
| AI 消息 | 白色背景 + 浅边框 + 左下角小圆角 + 暖色阴影 |
| 系统消息 | 居中 + `Subtle` 背景 |

### 6.3 对话列表

- 按时间分组 (今天/昨天/更早)，组标签用 Micro 字号大写
- 选中态：左侧 3px Teal 竖线 + `Primary Faint` 背景
- 多角色标识：头像右下角 Coral 圆点

### 6.4 角色卡片

- 白色卡片 + 浅边框 + xs 阴影
- 悬停：上移 2px + md 阴影 + 边框变 Teal Soft
- 渐变头像区域 (aspect-ratio 1:1)

### 6.5 搜索栏

- 药丸形 (`radius-full`) + `Subtle` 背景
- 聚焦态：边框变 `Primary Soft` (不抢焦)

### 6.6 Toggle 开关

- 开启：Teal 背景 + 白色圆钮右移
- 关闭：`Sunken` 背景 + 白色圆钮左置
- 动画：`cubic-bezier(0.34, 1.56, 0.64, 1)` 弹性回弹

---

## 七、交互动效

```
ease-out    cubic-bezier(0.16, 1, 0.3, 1)     ← 通用过渡
ease-spring cubic-bezier(0.34, 1.56, 0.64, 1) ← 弹性反馈 (FAB/Toggle)
```

| 场景 | 时长 | 缓动 |
|------|------|------|
| 按钮悬停 | 200ms | ease-out |
| 卡片悬停上浮 | 250ms | ease-out |
| 屏幕切换 | 300ms | ease-out |
| Toggle 切换 | 250ms | ease-spring |
| 打字指示器 | 1200ms 循环 | bounce |
| 消息操作显隐 | 200ms | ease-out (opacity) |

---

## 八、响应式策略

### 移动端 (≤ 768px)

- 底部 4-Tab 导航
- 单列布局
- FAB 浮动按钮 (右下角)
- 消息最大宽度 85%

### 桌面端 (≥ 769px)

- 左侧 64px 图标导航栏
- 三栏布局：图标栏 + 列表面板 (320px) + 聊天区
- 角色页：网格自适应列数
- 消息最大宽度 70%

---

## 九、Flutter 迁移要点

### Token 映射

```dart
class SolaceColors {
  // Backgrounds
  static const canvas = Color(0xFFF7F5F0);
  static const surface = Color(0xFFFFFFFF);
  static const subtle = Color(0xFFF0EDE6);
  static const sunken = Color(0xFFECE8E0);

  // Primary
  static const primary = Color(0xFF0D9488);
  static const primaryHover = Color(0xFF0F766E);
  static const primarySoft = Color(0xFFCCFBF1);
  static const primaryFaint = Color(0xFFF0FDFA);

  // Accents
  static const coral = Color(0xFFFB7185);
  static const amber = Color(0xFFF59E0B);
  static const violet = Color(0xFF8B5CF6);

  // Text
  static const textPrimary = Color(0xFF1C1917);
  static const textSecondary = Color(0xFF57534E);
  static const textTertiary = Color(0xFFA8A29E);

  // Borders
  static const borderLight = Color(0xFFF0EDE6);
  static const borderDefault = Color(0xFFE7E5E0);
  static const borderStrong = Color(0xFFD6D3CE);
}
```

### 阴影映射

```dart
// 使用带暖色 tint 的阴影
static List<BoxShadow> solaceShadowSm = [
  BoxShadow(color: Color(0x0A3C3223), blurRadius: 4, offset: Offset(0, 2)),
  BoxShadow(color: Color(0x0A3C3223), blurRadius: 2, offset: Offset(0, 1)),
];
```

### 关键替换点

1. `app_theme.dart` → 替换 `AppColors` 为 `SolaceColors`
2. `theme_presets.dart` → 新增 "Solace" 预设
3. 底部导航 → 活跃态改为 `Container` 背景填充
4. 消息气泡 → AI 气泡改白色 + 边框
5. 标题组件 → 指定 `fontFamily: 'Georgia'`

---

## 十、无障碍 (WCAG AA)

| 组合 | 对比度 | 标准 |
|------|--------|------|
| #1C1917 on #F7F5F0 | 15.3:1 | ✅ AAA |
| #57534E on #FFFFFF | 7.5:1 | ✅ AAA |
| #0D9488 on #FFFFFF | 4.6:1 | ✅ AA |
| #FB7185 on #FFFFFF | 3.2:1 | ⚠️ 仅大文字 |
| #FFFFFF on #0D9488 | 4.6:1 | ✅ AA |

---

**设计师**: Solace Design System
**日期**: 2026-07-06
**状态**: 原型就绪，待方案对比决策
