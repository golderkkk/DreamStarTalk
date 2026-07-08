/// 模型功能用途
enum ModelFunction {
  textChat('文字对话', '用于日常对话和文本生成'),
  imageRecognition('图片识别', '用于分析和理解图片内容'),
  tts('语音合成', '用于将文本转换为语音'),
  codeGeneration('代码生成', '用于编写和调试代码');

  final String label;
  final String description;
  const ModelFunction(this.label, this.description);
}

/// 模型配置
class ModelConfig {
  final ModelFunction function;
  final String providerId;  // 使用的提供商 ID
  final String modelId;     // 使用的模型 ID
  final bool useDefault;    // 是否使用默认模型

  const ModelConfig({
    required this.function,
    required this.providerId,
    required this.modelId,
    this.useDefault = true,
  });

  Map<String, dynamic> toJson() => {
    'function': function.name,
    'providerId': providerId,
    'modelId': modelId,
    'useDefault': useDefault,
  };

  factory ModelConfig.fromJson(Map<String, dynamic> json) => ModelConfig(
    function: ModelFunction.values.byName(json['function'] as String),
    providerId: json['providerId'] as String,
    modelId: json['modelId'] as String,
    useDefault: json['useDefault'] as bool? ?? true,
  );

  ModelConfig copyWith({
    ModelFunction? function,
    String? providerId,
    String? modelId,
    bool? useDefault,
  }) {
    return ModelConfig(
      function: function ?? this.function,
      providerId: providerId ?? this.providerId,
      modelId: modelId ?? this.modelId,
      useDefault: useDefault ?? this.useDefault,
    );
  }
}

/// 全局模型配置
class GlobalModelConfig {
  final Map<ModelFunction, ModelConfig> configs;

  const GlobalModelConfig({
    this.configs = const {},
  });

  /// 获取指定功能的模型配置
  ModelConfig? getConfig(ModelFunction function) => configs[function];

  /// 设置指定功能的模型配置
  GlobalModelConfig setConfig(ModelFunction function, ModelConfig config) {
    return GlobalModelConfig(
      configs: {...configs, function: config},
    );
  }

  Map<String, dynamic> toJson() => {
    'configs': configs.map((k, v) => MapEntry(k.name, v.toJson())),
  };

  factory GlobalModelConfig.fromJson(Map<String, dynamic> json) {
    final configsMap = <ModelFunction, ModelConfig>{};
    final configsJson = json['configs'] as Map<String, dynamic>? ?? {};
    for (final entry in configsJson.entries) {
      final function = ModelFunction.values.byName(entry.key);
      configsMap[function] = ModelConfig.fromJson(entry.value as Map<String, dynamic>);
    }
    return GlobalModelConfig(configs: configsMap);
  }
}
