import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dream_startalk/core/theme/aurora_theme.dart';

import '../../domain/entities/ai_provider.dart';
import '../../data/services/ai_service_factory.dart';
import '../providers/ai_provider.dart';
import '../../../chat/presentation/providers/tts_provider.dart';
import '../../../chat/data/services/tts_service.dart';

/// AI 服务配置页面 - 统一管理提供商、模型、TTS
class AIServicePage extends ConsumerStatefulWidget {
  const AIServicePage({super.key});

  @override
  ConsumerState<AIServicePage> createState() => _AIServicePageState();
}

class _AIServicePageState extends ConsumerState<AIServicePage> {
  List<AIModel> _availableModels = [];
  bool _loadingModels = false;
  String? _lastFetchedProviderId;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(aiProviderListProvider.notifier).loadProviders());
  }

  @override
  Widget build(BuildContext context) {
    final providerState = ref.watch(aiProviderListProvider);
    final ttsConfig = ref.watch(ttsConfigProvider);

    return Scaffold(
      backgroundColor: AuroraColors.bg0,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(color: AuroraColors.bg0.withOpacity(0.6)),
          ),
        ),
        title: const Text('AI 服务配置'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
        children: [
          _buildSectionHeader('AI 提供商', '管理 MiMo / DeepSeek 等'),
          _buildProviderList(context, providerState),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => context.push('/settings/providers'),
              icon: const Icon(Icons.settings, size: 18),
              label: const Text('管理提供商'),
            ),
          ),

          const SizedBox(height: 28),

          _buildSectionHeader('当前模型', '选择对话使用的 AI 模型'),
          _buildModelSelector(context, providerState),

          const SizedBox(height: 28),

          _buildSectionHeader('语音合成 (TTS)', 'AI 消息朗读功能'),
          _buildTTSSettings(context, ttsConfig),
        ],
      ),
    );
  }

  Future<void> _fetchModels(AIProviderConfig provider) async {
    setState(() => _loadingModels = true);
    try {
      final models = await AIServiceFactory.fetchAvailableModels(
        type: provider.type,
        apiKey: provider.apiKey,
        endpoint: provider.endpoint,
      );
      if (mounted) setState(() { _availableModels = models; _loadingModels = false; });
    } catch (_) {
      if (mounted) setState(() => _loadingModels = false);
    }
  }

  Future<void> _onModelChanged(AIProviderConfig provider, String newModel) async {
    await ref.read(aiProviderListProvider.notifier).updateProvider(provider.copyWith(defaultModel: newModel));
    if (mounted) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('已切换到 ${newModel.split('/').last}'), duration: const Duration(seconds: 1)));
    }
  }

  Widget _buildModelSelector(BuildContext context, AIProviderListState providerState) {
    final activeProvider = providerState.providers.where((p) => p.isEnabled).firstOrNull;
    if (activeProvider == null) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AuroraColors.bg2,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AuroraColors.border.withOpacity(0.25), width: 0.5),
        ),
        child: const Center(child: Text('请先启用一个 AI 提供商', style: TextStyle(color: AuroraColors.text3))),
      );
    }

    final models = _availableModels.isNotEmpty ? _availableModels : AIServiceFactory.defaultModelsFor(activeProvider.type);
    final currentModel = activeProvider.defaultModel;

    // 首次加载或切换提供商时动态拉取模型
    if (_lastFetchedProviderId != activeProvider.id && !_loadingModels) {
      _lastFetchedProviderId = activeProvider.id;
      _fetchModels(activeProvider);
    }

    return Container(
      decoration: BoxDecoration(
        color: AuroraColors.bg2,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AuroraColors.border.withOpacity(0.25), width: 0.5),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: _getProviderColor(activeProvider.type).withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(_getProviderIcon(activeProvider.type), color: _getProviderColor(activeProvider.type), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(activeProvider.name, style: const TextStyle(fontWeight: FontWeight.w600, color: AuroraColors.text1)),
            Row(children: [
              Text(activeProvider.type.label, style: const TextStyle(fontSize: 12, color: AuroraColors.text3)),
              if (_loadingModels) ...[const SizedBox(width: 8), const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 1.5))],
              if (!_loadingModels && _availableModels.isNotEmpty) ...[const SizedBox(width: 8), Text('${_availableModels.length} 个模型可用', style: const TextStyle(fontSize: 10, color: AuroraColors.primaryGlow))],
            ]),
          ])),
        ]),
        const SizedBox(height: 16),
        const Text('选择模型', style: TextStyle(fontSize: 13, color: AuroraColors.text2)),
        const SizedBox(height: 8),
        ...models.map((m) => RadioListTile<String>(
          value: m.id,
          groupValue: currentModel,
          onChanged: (v) {
            if (v != null) _onModelChanged(activeProvider, v);
          },
          title: Text(m.name, style: const TextStyle(fontSize: 14, color: AuroraColors.text1)),
          subtitle: m.description != null ? Text(m.description!, style: const TextStyle(fontSize: 12, color: AuroraColors.text3)) : null,
          activeColor: AuroraColors.primary,
          contentPadding: EdgeInsets.zero,
          dense: true,
        )),
      ]),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AuroraColors.text3, letterSpacing: 0.3)),
          const SizedBox(height: 2),
          Text(subtitle, style: const TextStyle(fontSize: 12, color: AuroraColors.text4)),
        ],
      ),
    );
  }

  Widget _buildProviderList(BuildContext context, AIProviderListState state) {
    if (state.isLoading) {
      return Container(
        height: 100,
        decoration: BoxDecoration(
          color: AuroraColors.bg2,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AuroraColors.border.withOpacity(0.25), width: 0.5),
        ),
        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    if (state.providers.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: AuroraColors.bg2,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AuroraColors.border.withOpacity(0.25), width: 0.5),
        ),
        child: Column(children: [
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(
              color: AuroraColors.text3.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.cloud_outlined, size: 28, color: AuroraColors.text3.withOpacity(0.5)),
          ),
          const SizedBox(height: 14),
          const Text('还没有配置 AI 提供商', style: TextStyle(color: AuroraColors.text3, fontSize: 14)),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => context.push('/settings/providers'),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('添加提供商'),
          ),
        ]),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AuroraColors.bg2,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AuroraColors.border.withOpacity(0.25), width: 0.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: state.providers.map((p) {
        final color = _getProviderColor(p.type);
        return Column(children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(_getProviderIcon(p.type), color: color, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(p.name, style: const TextStyle(fontWeight: FontWeight.w600, color: AuroraColors.text1, fontSize: 14)),
                const SizedBox(height: 2),
                Text('${p.type.label} · ${p.defaultModel}', style: const TextStyle(fontSize: 12, color: AuroraColors.text3)),
              ])),
              Switch(
                value: p.isEnabled,
                onChanged: (v) => ref.read(aiProviderListProvider.notifier).toggleEnabled(p.id),
                activeColor: AuroraColors.primary,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ]),
          ),
          if (p != state.providers.last)
            Divider(height: 1, indent: 70, endIndent: 16, color: AuroraColors.border.withOpacity(0.2)),
        ]);
      }).toList()),
    );
  }

  Widget _buildTTSSettings(BuildContext context, TTSConfig ttsConfig) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AuroraColors.bg2,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AuroraColors.border.withOpacity(0.25), width: 0.5),
      ),
      child: Column(children: [
        // 启用开关
        Row(children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: AuroraColors.cyan.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.volume_up_outlined, color: AuroraColors.cyan, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('语音合成 (TTS)', style: TextStyle(fontWeight: FontWeight.w500, color: AuroraColors.text1)),
            const SizedBox(height: 2),
            Text(
              ttsConfig.enabled && ttsConfig.isConfigured
                  ? '已启用 · ${MiMoVoices.getName(ttsConfig.voice)}'
                  : ttsConfig.isConfigured
                      ? '已配置 · 未启用'
                      : '未配置',
              style: TextStyle(fontSize: 12, color: ttsConfig.enabled ? AuroraColors.success : AuroraColors.text3),
            ),
          ])),
          Switch(
            value: ttsConfig.enabled,
            onChanged: ttsConfig.isConfigured
                ? (v) => ref.read(ttsConfigProvider.notifier).toggleEnabled(v)
                : null,
            activeColor: AuroraColors.primary,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ]),

        // 配置详情（已启用或已配置时显示）
        if (ttsConfig.isConfigured) ...[
          Divider(height: 24, color: AuroraColors.border.withOpacity(0.2)),
          // API Key 状态
          _buildTtsInfoRow(Icons.key, 'API Key', '${ttsConfig.apiKey.substring(0, 8)}...'),
          const SizedBox(height: 8),
          // 音色
          _buildTtsInfoRow(Icons.record_voice_over, '音色', MiMoVoices.getName(ttsConfig.voice)),
          if (ttsConfig.style.isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildTtsInfoRow(Icons.tune, '风格', ttsConfig.style),
          ],
        ],

        // 配置按钮
        Divider(height: 24, color: AuroraColors.border.withOpacity(0.2)),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _showTTSConfigDialog(context),
            icon: Icon(ttsConfig.isConfigured ? Icons.edit : Icons.add, size: 18),
            label: Text(ttsConfig.isConfigured ? '修改 TTS 配置' : '配置 TTS'),
          ),
        ),
      ]),
    );
  }

  Widget _buildTtsInfoRow(IconData icon, String label, String value) {
    return Row(children: [
      Icon(icon, size: 16, color: AuroraColors.text3),
      const SizedBox(width: 8),
      Text('$label: ', style: const TextStyle(fontSize: 13, color: AuroraColors.text3)),
      Expanded(child: Text(value, style: const TextStyle(fontSize: 13, color: AuroraColors.text1))),
    ]);
  }

  void _showTTSConfigDialog(BuildContext context) {
    final ttsConfig = ref.read(ttsConfigProvider);
    final apiKeyController = TextEditingController(text: ttsConfig.apiKey);
    String selectedVoice = ttsConfig.voice;
    final styleController = TextEditingController(text: ttsConfig.style);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          backgroundColor: AuroraColors.bg1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    color: AuroraColors.cyan.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.volume_up_outlined, color: AuroraColors.cyan, size: 24),
                ),
                const SizedBox(height: 16),
                const Text('TTS 语音合成配置', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AuroraColors.text1)),
                const SizedBox(height: 8),
                Text('使用 MiMo V2.5 TTS 朗读 AI 回复', style: TextStyle(fontSize: 13, color: AuroraColors.text3), textAlign: TextAlign.center),
                const SizedBox(height: 24),

                // API Key
                TextField(
                  controller: apiKeyController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'MiMo API Key',
                    hintText: 'sk-xxxx',
                    prefixIcon: Icon(Icons.key),
                    helperText: '登录 platform.xiaomimimo.com 获取',
                  ),
                ),
                const SizedBox(height: 20),

                // 音色选择
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('音色选择', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AuroraColors.text2)),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: MiMoVoices.builtIn.map((v) {
                    final isSelected = selectedVoice == v['id'];
                    return ChoiceChip(
                      label: Text(v['name']!),
                      selected: isSelected,
                      onSelected: (_) => setDialogState(() => selectedVoice = v['id']!),
                      selectedColor: AuroraColors.cyan,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : AuroraColors.text2,
                        fontSize: 13,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),

                // 风格指令
                TextField(
                  controller: styleController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: '风格指令（可选）',
                    hintText: '如：用温柔的语气、语速稍快、带点撒娇的感觉',
                    prefixIcon: Icon(Icons.auto_fix_high),
                    helperText: '通过 user 消息传入 MiMo TTS，控制语气/情感/语速',
                  ),
                ),
                const SizedBox(height: 24),

                // 测试按钮
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: apiKeyController.text.isNotEmpty
                        ? () async {
                            final svc = MiMoTTSService(apiKey: apiKeyController.text);
                            try {
                              await svc.speak(
                                messageId: 'test_${DateTime.now().millisecondsSinceEpoch}',
                                text: '你好，这是语音合成测试。',
                                voice: selectedVoice,
                                style: styleController.text,
                              );
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).clearSnackBars();
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('测试播放中...')));
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).clearSnackBars();
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('测试失败: $e'), backgroundColor: AuroraColors.error));
                              }
                            } finally {
                              svc.dispose();
                            }
                          }
                        : null,
                    icon: const Icon(Icons.play_circle_outline, size: 18),
                    label: const Text('测试播放'),
                  ),
                ),
                const SizedBox(height: 16),

                // 保存/取消
                Row(children: [
                  Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text('取消'))),
                  const SizedBox(width: 12),
                  Expanded(child: FilledButton(
                    onPressed: apiKeyController.text.isNotEmpty
                        ? () {
                            ref.read(ttsConfigProvider.notifier).update(TTSConfig(
                              enabled: true,
                              apiKey: apiKeyController.text,
                              voice: selectedVoice,
                              style: styleController.text,
                            ));
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).clearSnackBars();
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('TTS 配置已保存')));
                          }
                        : null,
                    child: const Text('保存'),
                  )),
                ]),
              ]),
            ),
          ),
        ),
      ),
    );
  }

  Color _getProviderColor(ProviderType type) {
    switch (type) {
      case ProviderType.mimo: return AuroraColors.primary;
      case ProviderType.deepseek: return AuroraColors.info;
      case ProviderType.openai: return AuroraColors.success;
      case ProviderType.claude: return Colors.purple;
      case ProviderType.gemini: return AuroraColors.error;
      case ProviderType.ollama: return Colors.teal;
      case ProviderType.gateway: return Colors.indigo;
    }
  }

  IconData _getProviderIcon(ProviderType type) {
    switch (type) {
      case ProviderType.mimo: return Icons.auto_awesome;
      case ProviderType.deepseek: return Icons.psychology;
      case ProviderType.openai: return Icons.smart_toy;
      case ProviderType.claude: return Icons.android;
      case ProviderType.gemini: return Icons.diamond;
      case ProviderType.ollama: return Icons.computer;
      case ProviderType.gateway: return Icons.language;
    }
  }
}
