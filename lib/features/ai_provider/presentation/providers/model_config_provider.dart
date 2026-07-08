import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/entities/model_config.dart';
import '../../domain/repositories/ai_service.dart';
import '../../data/services/ai_service_factory.dart';
import 'ai_provider.dart';

/// 全局模型配置 Provider
final globalModelConfigProvider = StateNotifierProvider<GlobalModelConfigNotifier, GlobalModelConfig>((ref) {
  return GlobalModelConfigNotifier(ref);
});

class GlobalModelConfigNotifier extends StateNotifier<GlobalModelConfig> {
  final Ref _ref;
  Box? _box;

  GlobalModelConfigNotifier(this._ref) : super(const GlobalModelConfig()) {
    _load();
  }

  Future<void> _load() async {
    try {
      _box = await Hive.openBox('model_config');
      final raw = _box?.get('config');
      if (raw != null && raw is Map) {
        final json = _convertMap(raw);
        state = GlobalModelConfig.fromJson(json);
      }
    } catch (e) {}
  }

  /// 递归转换 Hive 的 Map<dynamic, dynamic> 为 Map<String, dynamic>
  static Map<String, dynamic> _convertMap(Map<dynamic, dynamic> map) {
    return map.map((k, v) {
      if (v is Map) return MapEntry(k.toString(), _convertMap(v));
      if (v is List) return MapEntry(k.toString(), v.map((e) => e is Map ? _convertMap(e) : e).toList());
      return MapEntry(k.toString(), v);
    });
  }

  Future<void> updateConfig(ModelFunction function, ModelConfig config) async {
    state = state.setConfig(function, config);
    await _box?.put('config', state.toJson());
  }

  /// 获取指定功能的模型，如果没有配置则返回默认模型
  String getModelForFunction(ModelFunction function) {
    final config = state.getConfig(function);
    if (config != null && !config.useDefault) {
      return config.modelId;
    }
    
    // 返回默认模型
    final providerState = _ref.read(aiProviderListProvider);
    final activeProvider = providerState.providers.where((p) => p.isEnabled).firstOrNull;
    return activeProvider?.defaultModel ?? 'mimo-v2.5-pro';
  }
}

/// 获取指定功能的 AI 服务
final aiServiceForFunctionProvider = FutureProvider.family<AIService?, ModelFunction>((ref, function) async {
  final config = ref.watch(globalModelConfigProvider).getConfig(function);
  
  if (config != null && !config.useDefault) {
    // 使用指定的提供商
    final providerState = ref.watch(aiProviderListProvider);
    final provider = providerState.providers
        .where((p) => p.id == config.providerId && p.isEnabled)
        .firstOrNull;
    
    if (provider != null) {
      return AIServiceFactory.create(
        type: provider.type,
        apiKey: provider.apiKey,
        endpoint: provider.endpoint,
      );
    }
  }
  
  // 使用默认提供商
  return ref.watch(activeAIServiceProvider);
});
