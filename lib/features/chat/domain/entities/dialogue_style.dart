/// 对话风格设置
/// 基于 SillyTavern 预设系统，支持各种写作风格开关
class DialogueStyleSettings {
  // ── 模型选择 ──
  final String modelType; // 'gemini', 'claude', 'glm'

  // ── 活人感开关 ──
  final bool vividness; // 生动化
  final bool personalitySupplement; // 人格补充
  final bool emotionBaseline; // 情感基准

  // ── 常规功能 ──
  final bool godMode; // 上帝模式
  final bool customChainOfThought; // 自定义思维链
  final String? customCotContent;
  final bool userRoleDefinition; // 用户角色定义
  final String? userRoleName;
  final bool showFang; // 锋芒未露
  final bool bilingualDialogue; // 双语对白
  final String outputLanguage; // 输出语言

  // ── 字数设定 ──
  final bool enableWordCount;
  final int minWordCount;
  final int maxWordCount;

  // ── 特化模式 ──
  final bool romanceMode; // 恋爱文特化
  final bool nsfwMode; // 黄文特化
  final bool nsfwContrast; // 反差特化
  final bool beautification; // 外表美化

  // ── 情感基调（单选）──
  final ToneType? toneType;

  // ── 文风（可多选，按优先级）──
  final List<WritingStyle> writingStyles;

  // ── 人称视角 ──
  final PersonPOV? personPOV;

  // ── User 选项 ──
  final bool userAllTalk; // user 全是话
  final bool userMouthpiece; // user 的嘴替
  final bool mentalPerspective; // 心理透视
  final bool nsfwSelfStitch; // 色情自缝合

  // ── 附加选项 ──
  final bool antiInterrupt; // 防打断
  final bool antiRepeat; // 防复述
  final bool expandAndPush; // 扩写后推进
  final bool expandStrengthen; // 扩写/加强复述

  // ── 补丁模块 ──
  final bool antiOverfitting; // 抗过拟合
  final bool antiDespair; // 抗绝望
  final bool antiInterruption; // 抗抢话
  final bool hachimiInhibitor; // 哈基米抑制器
  final bool fanEnhancement; // 同人增强
  final bool characterShaping; // 人物塑造
  final bool detailControl; // 克-详略得当
  final bool ifStoryline; // IF 剧情线
  final bool breakFourthWall; // 打破第四面墙
  final bool disableWordList; // 禁用词表
  final bool interruptReminder; // 抢话提醒
  final bool addDialogue; // 增加对白
  final bool antiEightLegs; // 杀八股
  final bool deepWriting; // 深度写作

  // ── 自定义系统提示词 ──
  final String? customSystemPrompt;

  const DialogueStyleSettings({
    this.modelType = 'gemini',
    this.vividness = false,
    this.personalitySupplement = false,
    this.emotionBaseline = true,
    this.godMode = false,
    this.customChainOfThought = false,
    this.customCotContent,
    this.userRoleDefinition = false,
    this.userRoleName,
    this.showFang = true,
    this.bilingualDialogue = false,
    this.outputLanguage = 'zh-CN',
    this.enableWordCount = false,
    this.minWordCount = 800,
    this.maxWordCount = 1400,
    this.romanceMode = false,
    this.nsfwMode = false,
    this.nsfwContrast = false,
    this.beautification = false,
    this.toneType,
    this.writingStyles = const [],
    this.personPOV,
    this.userAllTalk = false,
    this.userMouthpiece = false,
    this.mentalPerspective = false,
    this.nsfwSelfStitch = false,
    this.antiInterrupt = false,
    this.antiRepeat = false,
    this.expandAndPush = false,
    this.expandStrengthen = false,
    this.antiOverfitting = false,
    this.antiDespair = false,
    this.antiInterruption = false,
    this.hachimiInhibitor = false,
    this.fanEnhancement = false,
    this.characterShaping = false,
    this.detailControl = false,
    this.ifStoryline = false,
    this.breakFourthWall = false,
    this.disableWordList = false,
    this.interruptReminder = false,
    this.addDialogue = false,
    this.antiEightLegs = false,
    this.deepWriting = false,
    this.customSystemPrompt,
  });

  /// 生成系统提示词
  String toSystemPrompt() {
    final buffer = StringBuffer();

    // 人格补充
    if (personalitySupplement) {
      buffer.writeln(_personalitySupplementPrompt);
    }

    // 情感基准
    if (emotionBaseline) {
      buffer.writeln(_emotionBaselinePrompt);
    }

    // 生动化
    if (vividness) {
      buffer.writeln(_vividnessPrompt);
    }

    // 锋芒未露
    if (showFang) {
      buffer.writeln(_showFangPrompt);
    }

    // 情感基调
    if (toneType != null) {
      buffer.writeln(_tonePrompt(toneType!));
    }

    // 字数要求
    if (enableWordCount) {
      buffer.writeln('<word_count>\n回复字数控制在 $minWordCount-$maxWordCount 字之间。\n</word_count>');
    }

    // 特化模式
    if (romanceMode) {
      buffer.writeln(_romanceModePrompt);
    }

    if (nsfwMode) {
      buffer.writeln(_nsfwModePrompt);
    }

    if (nsfwContrast) {
      buffer.writeln(_nsfwContrastPrompt);
    }

    // 外表美化
    if (beautification) {
      buffer.writeln(_beautificationPrompt);
    }

    // 人称视角
    if (personPOV != null) {
      buffer.writeln(_povPrompt(personPOV!));
    }

    // 附加选项
    if (antiRepeat) {
      buffer.writeln(_antiRepeatPrompt);
    }

    if (addDialogue) {
      buffer.writeln(_addDialoguePrompt);
    }

    if (expandAndPush) {
      buffer.writeln(_expandAndPushPrompt);
    }

    if (expandStrengthen) {
      buffer.writeln(_expandStrengthenPrompt);
    }

    // 补丁模块
    if (antiOverfitting) {
      buffer.writeln(_antiOverfittingPrompt);
    }

    if (antiDespair) {
      buffer.writeln(_antiDespairPrompt);
    }

    if (antiInterruption) {
      buffer.writeln(_antiInterruptionPrompt);
    }

    if (characterShaping) {
      buffer.writeln(_characterShapingPrompt);
    }

    if (detailControl) {
      buffer.writeln(_detailControlPrompt);
    }

    if (deepWriting) {
      buffer.writeln(_deepWritingPrompt);
    }

    if (breakFourthWall) {
      buffer.writeln(_breakFourthWallPrompt);
    }

    // 自定义提示词
    if (customSystemPrompt != null && customSystemPrompt!.isNotEmpty) {
      buffer.writeln(customSystemPrompt);
    }

    return buffer.toString();
  }

  String get _personalitySupplementPrompt => '''<Roleplay_Simulation_Directive>
好好塑造人物。把设定卡揉进当前情节里重新长出来，少写扁平化、刻板印象和硬套模板的东西。

写出性格缝隙：人会有例外和失手，暴躁的人也可能在摆弄细小东西时格外专注。
写出表里反差：外在表现和内在核心可以并不一致。
状态会影响表现：疲惫、发热、濒死、恐慌都会改掉一个人的样子。
</Roleplay_Simulation_Directive>''';

  String get _emotionBaselinePrompt => '''<kanjyoukijun>
正文必须显性呈现人物情绪，不得空泛概括；情绪要落到神态、呼吸、动作控制、心理拉扯、语气变化和行为偏移上。
角色的语言和行为必须带有人设烙印，并受关系与环境共同驱动。
</kanjyoukijun>''';

  String get _vividnessPrompt => '''角色要表现出真实感：
- 使用口语化表达，添加语气词
- 允许叹气、嘀咕、翻白眼等小动作
- 语言要符合角色性格，不要像说明书
''';

  String _tonePrompt(ToneType type) {
    switch (type) {
      case ToneType.healing:
        return '<tone>\n基调：治愈\n积极温暖、理解接纳。故事倾向于从波动回归安定，落脚点通常是人与人之间相互依偎的宁静日常。\n</tone>';
      case ToneType.sad:
        return '<tone>\n基调：伤感\n忧郁感伤、宿命无力。故事倾向于从波动滑向沉寂，落脚点通常是无法挽回的失去。\n</tone>';
      case ToneType.positive:
        return '<tone>\n基调：积极\n积极上扬。故事倾向于消解阴霾，情节始终向着理解、治愈与和解靠拢。\n</tone>';
      case ToneType.negative:
        return '<tone>\n基调：消极\n消极下沉。故事倾向于放大裂痕，情节持续向着孤独与绝望滑落。\n</tone>';
    }
  }

  String get _romanceModePrompt => '''<writing_style>
文风: 恋爱
恋爱三要素:
  - 背景: 故事发生的舞台，可以小到具体的场景/地点
  - 角色: 舞台上的演员，是恋爱文的灵魂，故事由人物展开和推动
  - 事件: 纽带, 把角色从互不相识变得千丝万缕, 从相识到相爱的过程
文本特征:
  - 恋爱过程为主: 比起结局, 更加重要的是过程。从互生情愫、各种巧合与缘分、从不在意到在意、从不喜欢到喜欢
  - 内心独白: 以角色视角"讲述"而非"展示"，带有浓烈主观情感的独白占主导地位, 表现性格与感情变化
  - 场景勾勒: 对场景赋予意向意味, 景物与情感形成呼应或反差
  - 动作细化: 从角色的所见所感出发, 制造紧凑的亲密感和心动感
细节准则:
  - 恋爱不是一蹴而就, 在双方探索中逐渐形成和发觉
  - 角色不可能莫名其妙爱上他人, 比起一见钟情, 更多是由双方在探索过程中找到合适答案所致
</writing_style>''';

  String get _nsfwModePrompt => '''<H_novel_addition>
NSFW写作增强模式:
  定义: 在原写作风格基础上, 根据以下要求对相关描写进行满足要求的细节刻画
  核心准则:
    - 感官描写为主: 着重于嗅觉、听觉、视觉、触觉等多感官描写
    - 身体反应细化: 将角色的生理反应、情感波动与行为结合, 写出强度变化
    - 情感驱动: 描写必须服务于角色关系和情感, 写出欲望、羞耻、沉沦与释放
    - 节奏控制: 快慢交替, 张弛有度, 避免平铺直叙
  具体写法:
    - 动作节奏: 从轻触到深入, 从克制到失控, 动作描写要体现角色的心理状态
    - 生理反应: 呼吸急促、心跳加速、体温升高、汗水、颤抖等, 但要自然地融入叙事
    - 语言表达: 羞涩时的欲言又止、沉沦时的呢喃、释放时的呼喊, 语言反映角色当下状态
    - 心理描写: 羞耻与欲望的拉扯、理智与本能的对决、沉沦与清醒的交替
  禁止:
    - 纯机械式的动作罗列
    - 脱离角色性格和关系的空洞描写
    - 使用过于医学术语的解剖式描写
</H_novel_addition>''';

  String get _nsfwContrastPrompt => '''<contrast_close-up>
反差特写:
  定义: 聚焦于角色强烈的反差感描写, 将外表与行为、衣着与状态进行对比以增强张力
  具体写法:
    核心准则:
      相貌与行为反差: 重点刻画角色清纯/高冷/正经的面庞与神态, 与其正在做的行为的反差
      衣着与裸露反差: 聚焦于"半穿半脱"的状态, 强调衣物的遮蔽与暴露的错位感
      感官要求: 主要使用视觉描写, 辅以听觉反差的刻画
    场景时:
      视觉为主: 描写时在"正经的脸部/未脱的衣物"与"状态"之间来回切换
      生理为辅: 将角色的羞耻感、抗拒感, 迅速转化为身体不受控制的快感与本能
</contrast_close-up>''';

  String get _showFangPrompt => '''锋芒未露：
- 角色偶尔展现出与平时不同的一面
- 在关键时刻显露隐藏的能力或性格特质
''';

  String get _beautificationPrompt => '''<beautification_filter>
美型化描写:
  定义: 剔除会引起视觉或感官不适的真实生理细节, 为角色保持一种干净、自然的理想化外观
  具体写法:
    核心准则:
      瑕疵屏蔽: 对设定上有几分姿色的角色, 行文中规避粗糙的生理细节描写
      拒绝浮夸: 严禁使用过度失真的辞藻, 外貌描写点到为止, 保留真实感
      差异化处理: 遇到平庸或丑陋的角色时, 如实描写其粗糙、油腻或瑕疵
    激烈/亲密场景时:
      画面净度控制: 重点刻画动作的张力与情绪的拉扯, 屏蔽过度的狼狈反应
</beautification_filter>''';

  String get _antiRepeatPrompt => '''防复述：
- 紧接着用户输入的内容往后写
- 用户输入的内容不会被重复体现在正文里
- 直接推进剧情，不要总结或复述用户的话
''';

  String get _addDialoguePrompt => '''增加对白：
- 提升文本中的对话比例
- 用对话推动情节发展
- 对话要体现角色性格和情感
''';

  String get _expandAndPushPrompt => '''扩写后推进：
- 对关键场景进行细节扩写
- 扩写后继续推进剧情，不要停留在原地
- 详略得当，重要场景浓墨重彩
''';

  String get _expandStrengthenPrompt => '''扩写/加强复述：
- 对用户描述的场景进行扩写和增强
- 添加更多感官细节和环境描写
- 丰富角色的动作和心理活动
''';

  String get _antiOverfittingPrompt => '''抗过拟合：
- 避免重复使用相同的句式和描写套路
- 每次回复要有变化，不要模式化
- 避免过度使用"不禁"、"竟然"等高频词
''';

  String get _antiDespairPrompt => '''抗绝望：
- 即使在困境中也要留有一线希望
- 角色不会轻易放弃或绝望
- 情节可以黑暗但不要完全绝望
''';

  String get _antiInterruptionPrompt => '''抗抢话：
- 不要替用户说话或完成用户的句子
- 不要预判用户的下一步行动
- 只写角色自己的行为和反应
''';

  String get _characterShapingPrompt => '''人物塑造：
- 角色行为要符合其背景和性格设定
- 通过细节展现角色的独特性
- 角色要有成长和变化，不要一成不变
''';

  String get _detailControlPrompt => '''详略得当：
- 重要场景详细描写，过渡场景简洁
- 不要在不重要的地方过度展开
- 把笔墨用在关键情节和情感高潮
''';

  String get _deepWritingPrompt => '''深度写作：
- 提升文本的思想深度和文学性
- 探索角色的内心世界和情感层次
- 用隐喻和象征丰富表达
- 描写要有画面感和代入感
''';

  String get _breakFourthWallPrompt => '''打破第四面墙：
- 角色可以偶尔意识到自己在故事中
- 可以对"读者"或"观众"进行暗示
- 保持趣味性，不要过度使用
''';

  String _povPrompt(PersonPOV pov) {
    switch (pov) {
      case PersonPOV.first:
        return '人称视角：第一人称（我）';
      case PersonPOV.second:
        return '人称视角：第二人称（你）';
      case PersonPOV.third:
        return '人称视角：第三人称（他/她）';
      case PersonPOV.nonUser:
        return '人称视角：非 user 视角，叙述中去除 user';
      case PersonPOV.charThird:
        return '人称视角：<char> 的第三人称，称呼 user 为"你"，称呼 char 为"他/她"';
      case PersonPOV.ensemble:
        return '人称视角：群像人称，AI 只支配角色卡里的人物';
    }
  }

  Map<String, dynamic> toJson() => {
    'modelType': modelType,
    'vividness': vividness,
    'personalitySupplement': personalitySupplement,
    'emotionBaseline': emotionBaseline,
    'godMode': godMode,
    'customChainOfThought': customChainOfThought,
    'customCotContent': customCotContent,
    'userRoleDefinition': userRoleDefinition,
    'userRoleName': userRoleName,
    'showFang': showFang,
    'bilingualDialogue': bilingualDialogue,
    'outputLanguage': outputLanguage,
    'enableWordCount': enableWordCount,
    'minWordCount': minWordCount,
    'maxWordCount': maxWordCount,
    'romanceMode': romanceMode,
    'nsfwMode': nsfwMode,
    'nsfwContrast': nsfwContrast,
    'beautification': beautification,
    'toneType': toneType?.name,
    'writingStyles': writingStyles.map((s) => s.name).toList(),
    'personPOV': personPOV?.name,
    'userAllTalk': userAllTalk,
    'userMouthpiece': userMouthpiece,
    'mentalPerspective': mentalPerspective,
    'nsfwSelfStitch': nsfwSelfStitch,
    'antiInterrupt': antiInterrupt,
    'antiRepeat': antiRepeat,
    'expandAndPush': expandAndPush,
    'expandStrengthen': expandStrengthen,
    'antiOverfitting': antiOverfitting,
    'antiDespair': antiDespair,
    'antiInterruption': antiInterruption,
    'hachimiInhibitor': hachimiInhibitor,
    'fanEnhancement': fanEnhancement,
    'characterShaping': characterShaping,
    'detailControl': detailControl,
    'ifStoryline': ifStoryline,
    'breakFourthWall': breakFourthWall,
    'disableWordList': disableWordList,
    'interruptReminder': interruptReminder,
    'addDialogue': addDialogue,
    'antiEightLegs': antiEightLegs,
    'deepWriting': deepWriting,
    'customSystemPrompt': customSystemPrompt,
  };

  factory DialogueStyleSettings.fromJson(Map<String, dynamic> json) => DialogueStyleSettings(
    modelType: json['modelType'] as String? ?? 'gemini',
    vividness: json['vividness'] as bool? ?? false,
    personalitySupplement: json['personalitySupplement'] as bool? ?? false,
    emotionBaseline: json['emotionBaseline'] as bool? ?? true,
    godMode: json['godMode'] as bool? ?? false,
    customChainOfThought: json['customChainOfThought'] as bool? ?? false,
    customCotContent: json['customCotContent'] as String?,
    userRoleDefinition: json['userRoleDefinition'] as bool? ?? false,
    userRoleName: json['userRoleName'] as String?,
    showFang: json['showFang'] as bool? ?? true,
    bilingualDialogue: json['bilingualDialogue'] as bool? ?? false,
    outputLanguage: json['outputLanguage'] as String? ?? 'zh-CN',
    enableWordCount: json['enableWordCount'] as bool? ?? false,
    minWordCount: json['minWordCount'] as int? ?? 800,
    maxWordCount: json['maxWordCount'] as int? ?? 1400,
    romanceMode: json['romanceMode'] as bool? ?? false,
    nsfwMode: json['nsfwMode'] as bool? ?? false,
    nsfwContrast: json['nsfwContrast'] as bool? ?? false,
    beautification: json['beautification'] as bool? ?? false,
    toneType: json['toneType'] != null ? ToneType.values.byName(json['toneType'] as String) : null,
    writingStyles: (json['writingStyles'] as List<dynamic>?)
        ?.map((s) => WritingStyle.values.byName(s as String))
        .toList() ?? [],
    personPOV: json['personPOV'] != null ? PersonPOV.values.byName(json['personPOV'] as String) : null,
    userAllTalk: json['userAllTalk'] as bool? ?? false,
    userMouthpiece: json['userMouthpiece'] as bool? ?? false,
    mentalPerspective: json['mentalPerspective'] as bool? ?? false,
    nsfwSelfStitch: json['nsfwSelfStitch'] as bool? ?? false,
    antiInterrupt: json['antiInterrupt'] as bool? ?? false,
    antiRepeat: json['antiRepeat'] as bool? ?? false,
    expandAndPush: json['expandAndPush'] as bool? ?? false,
    expandStrengthen: json['expandStrengthen'] as bool? ?? false,
    antiOverfitting: json['antiOverfitting'] as bool? ?? false,
    antiDespair: json['antiDespair'] as bool? ?? false,
    antiInterruption: json['antiInterruption'] as bool? ?? false,
    hachimiInhibitor: json['hachimiInhibitor'] as bool? ?? false,
    fanEnhancement: json['fanEnhancement'] as bool? ?? false,
    characterShaping: json['characterShaping'] as bool? ?? false,
    detailControl: json['detailControl'] as bool? ?? false,
    ifStoryline: json['ifStoryline'] as bool? ?? false,
    breakFourthWall: json['breakFourthWall'] as bool? ?? false,
    disableWordList: json['disableWordList'] as bool? ?? false,
    interruptReminder: json['interruptReminder'] as bool? ?? false,
    addDialogue: json['addDialogue'] as bool? ?? false,
    antiEightLegs: json['antiEightLegs'] as bool? ?? false,
    deepWriting: json['deepWriting'] as bool? ?? false,
    customSystemPrompt: json['customSystemPrompt'] as String?,
  );

  DialogueStyleSettings copyWith({
    String? modelType,
    bool? vividness,
    bool? personalitySupplement,
    bool? emotionBaseline,
    bool? godMode,
    bool? customChainOfThought,
    String? customCotContent,
    bool? userRoleDefinition,
    String? userRoleName,
    bool? showFang,
    bool? bilingualDialogue,
    String? outputLanguage,
    bool? enableWordCount,
    int? minWordCount,
    int? maxWordCount,
    bool? romanceMode,
    bool? nsfwMode,
    bool? nsfwContrast,
    bool? beautification,
    ToneType? toneType,
    List<WritingStyle>? writingStyles,
    PersonPOV? personPOV,
    bool? userAllTalk,
    bool? userMouthpiece,
    bool? mentalPerspective,
    bool? nsfwSelfStitch,
    bool? antiInterrupt,
    bool? antiRepeat,
    bool? expandAndPush,
    bool? expandStrengthen,
    bool? antiOverfitting,
    bool? antiDespair,
    bool? antiInterruption,
    bool? hachimiInhibitor,
    bool? fanEnhancement,
    bool? characterShaping,
    bool? detailControl,
    bool? ifStoryline,
    bool? breakFourthWall,
    bool? disableWordList,
    bool? interruptReminder,
    bool? addDialogue,
    bool? antiEightLegs,
    bool? deepWriting,
    String? customSystemPrompt,
  }) {
    return DialogueStyleSettings(
      modelType: modelType ?? this.modelType,
      vividness: vividness ?? this.vividness,
      personalitySupplement: personalitySupplement ?? this.personalitySupplement,
      emotionBaseline: emotionBaseline ?? this.emotionBaseline,
      godMode: godMode ?? this.godMode,
      customChainOfThought: customChainOfThought ?? this.customChainOfThought,
      customCotContent: customCotContent ?? this.customCotContent,
      userRoleDefinition: userRoleDefinition ?? this.userRoleDefinition,
      userRoleName: userRoleName ?? this.userRoleName,
      showFang: showFang ?? this.showFang,
      bilingualDialogue: bilingualDialogue ?? this.bilingualDialogue,
      outputLanguage: outputLanguage ?? this.outputLanguage,
      enableWordCount: enableWordCount ?? this.enableWordCount,
      minWordCount: minWordCount ?? this.minWordCount,
      maxWordCount: maxWordCount ?? this.maxWordCount,
      romanceMode: romanceMode ?? this.romanceMode,
      nsfwMode: nsfwMode ?? this.nsfwMode,
      nsfwContrast: nsfwContrast ?? this.nsfwContrast,
      beautification: beautification ?? this.beautification,
      toneType: toneType ?? this.toneType,
      writingStyles: writingStyles ?? this.writingStyles,
      personPOV: personPOV ?? this.personPOV,
      userAllTalk: userAllTalk ?? this.userAllTalk,
      userMouthpiece: userMouthpiece ?? this.userMouthpiece,
      mentalPerspective: mentalPerspective ?? this.mentalPerspective,
      nsfwSelfStitch: nsfwSelfStitch ?? this.nsfwSelfStitch,
      antiInterrupt: antiInterrupt ?? this.antiInterrupt,
      antiRepeat: antiRepeat ?? this.antiRepeat,
      expandAndPush: expandAndPush ?? this.expandAndPush,
      expandStrengthen: expandStrengthen ?? this.expandStrengthen,
      antiOverfitting: antiOverfitting ?? this.antiOverfitting,
      antiDespair: antiDespair ?? this.antiDespair,
      antiInterruption: antiInterruption ?? this.antiInterruption,
      hachimiInhibitor: hachimiInhibitor ?? this.hachimiInhibitor,
      fanEnhancement: fanEnhancement ?? this.fanEnhancement,
      characterShaping: characterShaping ?? this.characterShaping,
      detailControl: detailControl ?? this.detailControl,
      ifStoryline: ifStoryline ?? this.ifStoryline,
      breakFourthWall: breakFourthWall ?? this.breakFourthWall,
      disableWordList: disableWordList ?? this.disableWordList,
      interruptReminder: interruptReminder ?? this.interruptReminder,
      addDialogue: addDialogue ?? this.addDialogue,
      antiEightLegs: antiEightLegs ?? this.antiEightLegs,
      deepWriting: deepWriting ?? this.deepWriting,
      customSystemPrompt: customSystemPrompt ?? this.customSystemPrompt,
    );
  }
}

/// 情感基调
enum ToneType {
  healing('治愈'),
  sad('伤感'),
  positive('积极'),
  negative('消极');

  final String label;
  const ToneType(this.label);
}

/// 文风
enum WritingStyle {
  romance('恋爱'),
  fantasy('奇幻'),
  scifi('科幻'),
  horror('恐怖'),
  comedy('喜剧'),
  drama('剧情'),
  action('动作'),
  mystery('悬疑');

  final String label;
  const WritingStyle(this.label);
}

/// 人称视角
enum PersonPOV {
  first('第一人称'),
  second('第二人称'),
  third('第三人称'),
  nonUser('非 user 视角'),
  charThird('char 第三人称'),
  ensemble('群像人称');

  final String label;
  const PersonPOV(this.label);
}
