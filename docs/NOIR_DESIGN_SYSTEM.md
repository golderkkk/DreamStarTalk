# Noir Design System

> **方案 C** — 暗色奢华 · 香槟金 · 玻璃拟态
> AI Chat Studio 第三套 UI 设计，追求高级感与编辑级审美

---

## 一、设计理念

**Noir** 取自法语"黑"，呼应电影"黑色电影"(Film Noir) 的美学传统：深邃、克制、富有戏剧张力。

在 AI 角色扮演的产品语境下，Noir 用**香槟金作为唯一主色**，搭配**玻璃拟态面板**和**胶片颗粒纹理**，营造出"翻阅一本精装书"的高级阅读体验。

### 三方案定位差异

| 维度 | Aurora (A) | Solace (B) | Noir (C) |
|------|:---:|:---:|:---:|
| 底色 | 冷暗 #08080C | 暖白 #F7F5F0 | 暖暗 #0A0A0C |
| 主色 | 紫罗兰 #7C6BF0 | Teal #0D9488 | 香槟金 #C9A96E |
| 深度手法 | 霓虹光晕 | 暖色阴影 | 玻璃拟态 + 金色辉光 |
| 标题字体 | Inter 无衬线 | Georgia 衬线 | Playfair Display 衬线 |
| 质感隐喻 | 黑曜石 | 纸张 | 胶片 / 精装书 |
| 审美取向 | 科技感 | 文学温暖 | 奢华高级 |
| 纹理 | 无 | 无 | SVG 噪点颗粒 |
| 适用场景 | 夜间沉浸 | 日间阅读 | 全场景 |

---

## 二、色彩系统

### 背景层次

```
Canvas       #0A0A0C    ← 画布底色 (富有暖意的深黑)
Surface      #131318    ← 一级表面
Surface 2    #1C1C24    ← 二级表面 (卡片)
Surface 3    #25252F    ← 三级表面 (凹陷)
Glass        rgba(255,255,255,0.035)  ← 玻璃面板
Glass Strong rgba(255,255,255,0.06)   ← 强玻璃面板
```

### 主色 — 香槟金

```
Gold         #C9A96E    ← 主交互色
Gold Bright  #E0C58A    ← 高亮态 (文字/图标)
Gold Dim     #A08850    ← 按下态
Gold Soft    rgba(201,169,110,0.15)  ← 软背景
Gold Faint   rgba(201,169,110,0.06)  ← 极淡背景
Gold Gradient  linear-gradient(135deg, #E0C58A, #C9A96E, #A08850)
```

### 对比强调色

```
Mint   #7CF5C8    ← 多角色标识 / 成功态
Rose   #F472B6    ← 警告 / 特殊标识
```

### 文字

```
Primary    #F5F3EF    ← 主文字 (暖白)
Secondary  #A09B8E    ← 辅助文字 (暖灰)
Tertiary   #5C574E    ← 次要信息 (暗灰)
Gold Text  #E0C58A    ← 金色文字
```

### 边框与分隔

```
Subtle     rgba(255,255,255,0.04)   ← 分隔线
Default    rgba(255,255,255,0.07)   ← 卡片边框
Strong     rgba(255,255,255,0.12)   ← 输入框边框
Gold       rgba(201,169,110,0.25)   ← 金色边框 (聚焦/悬停)
```

---

## 三、字体系统

### 字体族

```
Display (标题)  'Playfair Display', 'Noto Serif SC', serif
Sans (正文)     'Inter', -apple-system, 'SF Pro Display', sans-serif
Mono (代码)     'SF Mono', 'JetBrains Mono', monospace
```

**设计决策**：Playfair Display 是一款高对比度衬线体，常用于时尚杂志和奢侈品牌，传递"编辑级"审美。与 Inter 的现代无衬线形成"经典 × 当代"的对话感。

### 字号阶梯

```
Display   30px / 600 / -0.5px  ← 页面主标题 (衬线)
Heading   22px / 700           ← 区块标题
Title     17px / 600           ← 卡片标题
Body      15px / 400 / 1.5     ← 正文
Caption   12px / 500           ← 辅助信息
Micro     10px / 700 / 1.5px   ← 时间组/标签 (大写)
```

---

## 四、间距与圆角

### 间距 (4px 基准)

```
4 · 8 · 12 · 16 · 20 · 24 · 32 · 48 · 64
```

### 圆角

```
sm    8px    ← 小按钮、标签
md   14px    ← 卡片、输入框、头像
lg   18px    ← 大卡片、消息气泡
xl   24px    ← FAB、Profile 卡片
2xl  32px    ← 模态弹窗
full 9999px  ← 药丸形
```

---

## 五、阴影与质感

### 阴影系统

```
sm       0 1px 3px rgba(0,0,0,0.4)
md       0 4px 16px rgba(0,0,0,0.35), 0 1px 3px rgba(0,0,0,0.3)
lg       0 12px 40px rgba(0,0,0,0.4), 0 4px 12px rgba(0,0,0,0.3)
gold     0 4px 20px rgba(201,169,110,0.15)       ← 金色元素投影
gold-glow 0 0 24px rgba(201,169,110,0.2)         ← 金色辉光 (悬停)
```

### 胶片颗粒纹理

全局 SVG 噪点叠加，opacity 3%，mix-blend-mode: overlay，模拟胶片颗粒感：

```css
body::before {
  background-image: url("data:image/svg+xml,...feTurbulence...");
  opacity: 0.03;
  mix-blend-mode: overlay;
}
```

**效果**：消除数字界面的"塑料感"，增添物理材质的温度。

### 玻璃拟态

```css
.glass-panel {
  background: rgba(255, 255, 255, 0.035);
  backdrop-filter: blur(12px);
  border: 1px solid rgba(255, 255, 255, 0.07);
}
```

**使用场景**：顶部导航栏、聊天头部、输入栏、设置卡片、AI 消息气泡。

---

## 六、组件规范

### 6.1 消息气泡

| 类型 | 背景 | 边框 | 圆角 |
|------|------|------|------|
| 用户消息 | 香槟金渐变 | 无 | 18px (右下 6px) |
| AI 消息 | 玻璃面板 + blur | 左侧 2px 金色竖线 | 18px (左下 6px) |

**关键差异**：AI 气泡的**左侧金色竖线**是 Noir 的标志性元素，既作为视觉锚点，又暗示"AI 的声音"。

### 6.2 底部导航

- **活跃态**：`Gold Soft` 背景填充 + 图标/文字变 `Gold Bright`
- **非活跃态**：透明 + `Tertiary` 色
- 背景使用 `backdrop-filter: blur(24px)` 玻璃效果

### 6.3 FAB 浮动按钮

- 香槟金渐变背景 + 金色投影
- 悬停：`scale(1.06) rotate(90deg)` — 旋转动效是 Noir 独有
- 暗色背景上的金色光点，视觉焦点

### 6.4 对话列表

- 选中态：左侧 3px 金色渐变竖线 + `Gold Faint` 背景
- 多角色标识：头像右下角 Mint 色圆点 + 发光效果
- 未读 Badge：金色渐变 + 金色投影

### 6.5 角色卡片

- 玻璃面板背景 + 浅边框
- 悬停：上浮 3px + 金色边框 + 金色辉光 (`sh-glow-gold`)
- 头像区域底部渐变遮罩，增加深度

### 6.6 Toggle 开关

- 开启：香槟金渐变 + 金色投影
- 关闭：`Surface 3` 暗灰
- 圆钮：开启时变 `Canvas` 色（金底反白），关闭时 `Primary` 色

---

## 七、交互动效

```
ease-luxe    cubic-bezier(0.16, 1, 0.3, 1)     ← 通用过渡 (丝滑)
ease-spring  cubic-bezier(0.34, 1.56, 0.64, 1) ← 弹性反馈
```

| 场景 | 时长 | 缓动 | 特效 |
|------|------|------|------|
| 按钮悬停 | 250ms | ease-luxe | translateY(-1px) + 金色辉光 |
| 卡片悬停 | 300ms | ease-luxe | translateY(-3px) + 金色边框 |
| FAB 悬停 | 300ms | ease-spring | scale(1.06) + rotate(90deg) |
| Toggle | 300ms | ease-spring | 圆钮滑动 |
| 打字指示 | 1200ms | bounce | 金色圆点弹跳 |
| 消息操作 | 250ms | ease-luxe | opacity 0→1 |

---

## 八、Noir 的"高级感"从何而来

### 1. 单色策略
全界面只有**一个主色**（香槟金），不使用多色拼接。高级感来自克制，不是堆砌。

### 2. 渐变运用
金色以**渐变**形态出现（`#E0C58A → #C9A96E → #A08850`），而非纯色平涂。渐变模拟金属光泽，增加材质感。

### 3. 玻璃拟态
`backdrop-filter: blur()` 在深色画布上营造毛玻璃面板，层次丰富但色调统一。

### 4. 胶片纹理
全局 3% 噪点叠加，消除数字界面的"过于干净"感，增添物理材质的温度。

### 5. 编辑级排版
Playfair Display 衬线标题传递"出版物"气质，与产品的"角色扮演叙事"本质深度契合。

### 6. 金色辉光
关键交互元素（FAB、发送按钮、活跃指示）带有柔和的金色 `box-shadow`，模拟金属反光。

### 7. 充足留白
即使暗色主题也保持慷慨间距（页面标题 30px + 22px padding），避免拥挤感。

---

## 九、Flutter 迁移要点

### Token 映射

```dart
class NoirColors {
  static const canvas = Color(0xFF0A0A0C);
  static const surface = Color(0xFF131318);
  static const surface2 = Color(0xFF1C1C24);
  static const surface3 = Color(0xFF25252F);

  static const gold = Color(0xFFC9A96E);
  static const goldBright = Color(0xFFE0C58A);
  static const goldDim = Color(0xFFA08850);

  static const mint = Color(0xFF7CF5C8);
  static const rose = Color(0xFFF472B6);

  static const textPrimary = Color(0xFFF5F3EF);
  static const textSecondary = Color(0xFFA09B8E);
  static const textTertiary = Color(0xFF5C574E);
}

// 玻璃面板
Widget glassPanel({double blur = 12}) => ClipRRect(
  borderRadius: BorderRadius.circular(18),
  child: BackdropFilter(
    filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.035),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
    ),
  ),
);

// 金色渐变
const goldGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFFE0C58A), Color(0xFFC9A96E), Color(0xFFA08850)],
);
```

### 关键替换点

1. `app_theme.dart` → 替换为 `NoirColors`
2. `theme_presets.dart` → 新增 "Noir" 预设
3. 卡片组件 → 使用 `BackdropFilter` + 半透明背景
4. AI 消息气泡 → 添加左侧 2px 金色 `Border`
5. FAB → 添加 `rotate` 动画到 90°
6. 标题组件 → `fontFamily: 'Playfair Display'`
7. 全局 → 叠加 `NoiseTexture` widget (opacity 0.03)

---

## 十、无障碍 (WCAG AA)

| 组合 | 对比度 | 标准 |
|------|--------|------|
| #F5F3EF on #0A0A0C | 18.2:1 | ✅ AAA |
| #A09B8E on #0A0A0C | 7.8:1 | ✅ AAA |
| #C9A96E on #0A0A0C | 7.1:1 | ✅ AAA |
| #E0C58A on #131318 | 8.5:1 | ✅ AAA |
| #0A0A0C on #C9A96E | 7.1:1 | ✅ AAA |
| #5C574E on #0A0A0C | 2.8:1 | ⚠️ 仅装饰性 |

---

**设计师**: Noir Design System
**日期**: 2026-07-06
**状态**: 原型就绪，三方案对比完成
