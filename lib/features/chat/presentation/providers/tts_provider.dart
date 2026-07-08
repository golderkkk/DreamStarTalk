import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../data/services/tts_service.dart';

/// TTS 配置 Provider（持久化到 Hive）
final ttsConfigProvider = StateNotifierProvider<TTSConfigNotifier, TTSConfig>((ref) {
  return TTSConfigNotifier();
});

class TTSConfigNotifier extends StateNotifier<TTSConfig> {
  Box? _box;

  TTSConfigNotifier() : super(const TTSConfig()) {
    _load();
  }

  Future<void> _load() async {
    try {
      _box = await Hive.openBox('tts_config');
      final raw = _box?.get('settings');
      if (raw != null && raw is Map) {
        final json = raw.map((k, v) => MapEntry(k.toString(), v));
        state = TTSConfig.fromJson(json);
      }
    } catch (e) {
    }
  }

  Future<void> update(TTSConfig config) async {
    state = config;
    await _box?.put('settings', config.toJson());
  }

  Future<void> toggleEnabled(bool enabled) async {
    await update(state.copyWith(enabled: enabled));
  }

  Future<void> setApiKey(String key) async {
    await update(state.copyWith(apiKey: key));
  }

  Future<void> setVoice(String voice) async {
    await update(state.copyWith(voice: voice));
  }

  Future<void> setStyle(String style) async {
    await update(state.copyWith(style: style));
  }
}

/// TTS 服务 Provider
final ttsServiceProvider = Provider<MiMoTTSService?>((ref) {
  final config = ref.watch(ttsConfigProvider);
  if (!config.enabled || !config.isConfigured) return null;

  final service = MiMoTTSService(
    apiKey: config.apiKey,
    endpoint: config.endpoint,
  );
  ref.onDispose(() => service.dispose());
  return service;
});

/// 当前正在播放 TTS 的消息 ID
final ttsPlayingMessageIdProvider = StateProvider<String?>((ref) => null);
