import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:audioplayers/audioplayers.dart';

/// MiMo TTS 语音合成服务
/// 文档：https://mimo.mi.com/docs/zh-CN/api-doc/speech/mimo-v2.5-tts
///
/// 支持三种模型：
/// - mimo-v2.5-tts: 内置音色（9种）
/// - mimo-v2.5-tts-voicedesign: 声音设计
/// - mimo-v2.5-tts-voiceclone: 声音克隆
class MiMoTTSService {
  final String apiKey;
  final String endpoint;
  late final Dio dio;
  final AudioPlayer _player = AudioPlayer();
  String? _currentPlayingId;
  StreamSubscription? _playerSub;
  Function()? _onPlaybackComplete;

  MiMoTTSService({
    required this.apiKey,
    String? endpoint,
  }) : endpoint = endpoint ?? 'https://api.xiaomimimo.com/v1' {
    dio = Dio(BaseOptions(
      baseUrl: this.endpoint,
      headers: {
        'api-key': apiKey,
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(minutes: 2),
    ));
  }

  String? get currentPlayingId => _currentPlayingId;

  /// 文本转语音并播放
  /// [onComplete] 播放完成回调（UI 用于重置状态）
  Future<void> speak({
    required String messageId,
    required String text,
    String voice = 'mimo_default',
    String style = '',
    String format = 'mp3',
    Function()? onComplete,
  }) async {
    if (_currentPlayingId == messageId) {
      await stop();
      return;
    }

    await stop();
    _currentPlayingId = messageId;
    _onPlaybackComplete = onComplete;

    try {
      final audioBytes = await synthesize(
        text: text,
        voice: voice,
        style: style,
        format: format,
      );

      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/tts_$messageId.$format');
      await tempFile.writeAsBytes(audioBytes);

      // 只保留一个播放完成监听
      _playerSub?.cancel();
      _playerSub = _player.onPlayerComplete.listen((_) {
        _currentPlayingId = null;
        _onPlaybackComplete?.call();
        _onPlaybackComplete = null;
      });

      await _player.play(DeviceFileSource(tempFile.path));
    } catch (e) {
      _currentPlayingId = null;
      _onPlaybackComplete = null;
      rethrow;
    }
  }

  /// 停止播放
  Future<void> stop() async {
    await _player.stop();
    _currentPlayingId = null;
  }

  /// 文本转语音（返回音频数据）
  ///
  /// [text] 要合成的文本（放在 assistant 角色中）
  /// [voice] 音色名称，如 'mimo_default', 'male-qn-qingse' 等
  /// [style] 风格指令（放在 user 角色中），如 '用温柔的语气', '语速稍快'
  /// [format] 音频格式：'mp3' 或 'wav'
  Future<Uint8List> synthesize({
    required String text,
    String voice = 'mimo_default',
    String style = '',
    String format = 'mp3',
  }) async {
    final messages = <Map<String, dynamic>>[];

    // user 消息：风格指令（可选）
    if (style.isNotEmpty) {
      messages.add({'role': 'user', 'content': style});
    }

    // assistant 消息：要合成的文本
    messages.add({'role': 'assistant', 'content': text});

    final response = await dio.post(
      '/chat/completions',
      data: {
        'model': 'mimo-v2.5-tts',
        'messages': messages,
        'audio': {
          'format': format,
          'voice': voice,
        },
      },
    );

    final audioData = response.data['choices'][0]['message']['audio']['data'];
    return base64Decode(audioData);
  }

  /// 验证服务是否可用
  Future<bool> validate() async {
    try {
      await synthesize(text: '测试', voice: 'mimo_default');
      return true;
    } catch (_) {
      return false;
    }
  }

  /// 释放资源
  void dispose() {
    _playerSub?.cancel();
    _player.dispose();
  }
}

/// TTS 配置（持久化到 Hive）
class TTSConfig {
  final bool enabled;
  final String apiKey;       // 独立的 TTS API Key
  final String endpoint;     // API 端点
  final String voice;        // 音色
  final String style;        // 风格指令
  final String format;       // 音频格式

  const TTSConfig({
    this.enabled = false,
    this.apiKey = '',
    this.endpoint = 'https://api.xiaomimimo.com/v1',
    this.voice = 'mimo_default',
    this.style = '',
    this.format = 'mp3',
  });

  bool get isConfigured => apiKey.isNotEmpty;

  TTSConfig copyWith({
    bool? enabled,
    String? apiKey,
    String? endpoint,
    String? voice,
    String? style,
    String? format,
  }) {
    return TTSConfig(
      enabled: enabled ?? this.enabled,
      apiKey: apiKey ?? this.apiKey,
      endpoint: endpoint ?? this.endpoint,
      voice: voice ?? this.voice,
      style: style ?? this.style,
      format: format ?? this.format,
    );
  }

  Map<String, dynamic> toJson() => {
    'enabled': enabled,
    'apiKey': apiKey,
    'endpoint': endpoint,
    'voice': voice,
    'style': style,
    'format': format,
  };

  factory TTSConfig.fromJson(Map<String, dynamic> json) => TTSConfig(
    enabled: json['enabled'] as bool? ?? false,
    apiKey: json['apiKey'] as String? ?? '',
    endpoint: json['endpoint'] as String? ?? 'https://api.xiaomimimo.com/v1',
    voice: json['voice'] as String? ?? 'mimo_default',
    style: json['style'] as String? ?? '',
    format: json['format'] as String? ?? 'mp3',
  );
}

/// MiMo TTS 内置音色列表
class MiMoVoices {
  static const List<Map<String, String>> builtIn = [
    {'id': 'mimo_default', 'name': 'MiMo 默认', 'desc': '通用默认音色'},
    {'id': 'male-qn-qingse', 'name': '青涩青年', 'desc': '年轻男声'},
    {'id': 'male-qn-jingying', 'name': '精英青年', 'desc': '成熟男声'},
    {'id': 'male-qn-badao', 'name': '霸道青年', 'desc': '低沉男声'},
    {'id': 'female-shaonv', 'name': '元气少女', 'desc': '活泼女声'},
    {'id': 'female-yujie', 'name': '知性御姐', 'desc': '成熟女声'},
    {'id': 'female-chengshu', 'name': '温柔姐姐', 'desc': '温柔女声'},
    {'id': 'male-qn-daxuesheng', 'name': '阳光男大', 'desc': '阳光男声'},
    {'id': 'female-tianmei', 'name': '甜心小妹', 'desc': '甜美女声'},
  ];

  static String getName(String id) {
    return builtIn.where((v) => v['id'] == id).firstOrNull?['name'] ?? id;
  }
}
