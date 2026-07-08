import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dream_startalk/core/theme/aurora_theme.dart';
import '../../domain/entities/model_config.dart';
import '../../domain/entities/ai_provider.dart';
import '../../data/services/ai_service_factory.dart';
import '../providers/ai_provider.dart';
import '../providers/model_config_provider.dart';

/// 模型配置页面
class ModelConfigPage extends ConsumerStatefulWidget {
  const ModelConfigPage({super.key});

  @override
  ConsumerState<ModelConfigPage> createState() => _ModelConfigPageState();
}

class _ModelConfigPageState extends ConsumerState<ModelConfigPage> {
  @override
  Widget build(BuildContext context) {
    final config = ref.watch(globalModelConfigProvider);
    final providerState = ref.watch(aiProviderListProvider);
    final providers = providerState.providers;

    return Scaffold(
      appBar: AppBar(
        title: const Text('模型配置'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 说明卡片
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AuroraColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AuroraColors.primary.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: AuroraColors.primary, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '为不同功能配置不同的 AI 模型，可以针对特定任务优化效果。',
                    style: TextStyle(
                      fontSize: 14,
                      color: AuroraColors.text2,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 功能配置列表
          ...ModelFunction.values.map((function) {
            final modelConfig = config.getConfig(function);
            return _buildFunctionCard(context, function, modelConfig, providers);
          }),
        ],
      ),
    );
  }

  Widget _buildFunctionCard(
    BuildContext context,
    ModelFunction function,
    ModelConfig? config,
    List<AIProviderConfig> providers,
  ) {
    final isConfigured = config != null && !config.useDefault;
    final currentProvider = providers
        .where((p) => p.id == config?.providerId)
        .firstOrNull;
    final currentModel = config?.modelId;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getIconForFunction(function),
                  color: AuroraColors.primary,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        function.label,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AuroraColors.text1,
                        ),
                      ),
                      Text(
                        function.description,
                        style: TextStyle(
                          fontSize: 12,
                          color: AuroraColors.text3,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: isConfigured,
                  onChanged: (value) {
                    if (value) {
                      // 启用自定义配置
                      _showModelSelector(context, function, providers);
                    } else {
                      // 使用默认配置
                      ref.read(globalModelConfigProvider.notifier).updateConfig(
                        function,
                        ModelConfig(
                          function: function,
                          providerId: '',
                          modelId: '',
                          useDefault: true,
                        ),
                      );
                    }
                  },
                  activeColor: AuroraColors.primary,
                ),
              ],
            ),
            if (isConfigured) ...[
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.cloud, size: 16, color: AuroraColors.text3),
                  const SizedBox(width: 8),
                  Text(
                    '提供商: ${currentProvider?.name ?? "未配置"}',
                    style: TextStyle(
                      fontSize: 13,
                      color: AuroraColors.text2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.smart_toy, size: 16, color: AuroraColors.text3),
                  const SizedBox(width: 8),
                  Text(
                    '模型: $currentModel',
                    style: TextStyle(
                      fontSize: 13,
                      color: AuroraColors.text2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => _showModelSelector(context, function, providers),
                icon: const Icon(Icons.edit, size: 16),
                label: const Text('修改配置'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getIconForFunction(ModelFunction function) {
    switch (function) {
      case ModelFunction.textChat:
        return Icons.chat;
      case ModelFunction.imageRecognition:
        return Icons.image;
      case ModelFunction.tts:
        return Icons.volume_up;
      case ModelFunction.codeGeneration:
        return Icons.code;
    }
  }

  void _showModelSelector(
    BuildContext context,
    ModelFunction function,
    List<AIProviderConfig> providers,
  ) {
    String? selectedProviderId;
    String? selectedModelId;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final selectedProvider = providers
              .where((p) => p.id == selectedProviderId)
              .firstOrNull;
          final availableModels = selectedProvider != null
              ? (selectedProvider.availableModels.isNotEmpty
                  ? selectedProvider.availableModels.map((id) => AIModel(id: id, name: id)).toList()
                  : AIServiceFactory.defaultModelsFor(selectedProvider.type))
              : <AIModel>[];

          return AlertDialog(
            title: Text('配置 ${function.label}'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 选择提供商
                DropdownButtonFormField<String>(
                  value: selectedProviderId,
                  decoration: const InputDecoration(
                    labelText: '选择提供商',
                    border: OutlineInputBorder(),
                  ),
                  items: providers.map((p) {
                    return DropdownMenuItem(
                      value: p.id,
                      child: Text(p.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setDialogState(() {
                      selectedProviderId = value;
                      selectedModelId = null;
                    });
                  },
                ),
                const SizedBox(height: 16),

                // 选择模型
                if (availableModels.isNotEmpty)
                  DropdownButtonFormField<String>(
                    value: selectedModelId,
                    decoration: const InputDecoration(
                      labelText: '选择模型',
                      border: OutlineInputBorder(),
                    ),
                    items: availableModels.map((m) {
                      return DropdownMenuItem(
                        value: m.id,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(m.name),
                            if (m.description != null)
                              Text(
                                m.description!,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AuroraColors.text3,
                                ),
                              ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setDialogState(() => selectedModelId = value);
                    },
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('取消'),
              ),
              FilledButton(
                onPressed: selectedProviderId != null && selectedModelId != null
                    ? () {
                        ref.read(globalModelConfigProvider.notifier).updateConfig(
                          function,
                          ModelConfig(
                            function: function,
                            providerId: selectedProviderId!,
                            modelId: selectedModelId!,
                            useDefault: false,
                          ),
                        );
                        Navigator.pop(context);
                      }
                    : null,
                child: const Text('保存'),
              ),
            ],
          );
        },
      ),
    );
  }

  List<AIModel> _getModelsForProvider(ProviderType type) => AIServiceFactory.defaultModelsFor(type);
}
