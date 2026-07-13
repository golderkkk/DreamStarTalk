import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dream_startalk/core/theme/aurora_theme.dart';
import '../../domain/entities/ai_provider.dart';
import '../../domain/repositories/ai_service.dart';
import '../../data/services/ai_service_factory.dart';
import '../providers/ai_provider.dart';

class ProviderConfigPage extends ConsumerStatefulWidget {
  final ProviderType? providerType;
  const ProviderConfigPage({super.key, this.providerType});
  @override ConsumerState<ProviderConfigPage> createState() => _ProviderConfigPageState();
}

class _ProviderConfigPageState extends ConsumerState<ProviderConfigPage> {
  final _key = TextEditingController(), _endpoint = TextEditingController(), _name = TextEditingController();
  ProviderType _type = ProviderType.mimo; String _model = ''; bool _saving = false, _testing = false, _showKey = false;

  @override void initState() { super.initState(); if (widget.providerType != null) _type = widget.providerType!; _defaults(); }
  @override void dispose() { _key.dispose(); _endpoint.dispose(); _name.dispose(); super.dispose(); }

  void _defaults() {
    switch (_type) {
      case ProviderType.mimo:
        _name.text = 'MiMo';
        _endpoint.text = 'https://api.xiaomimimo.com/v1';
        _model = 'mimo-v2.5-pro';
        break;
      case ProviderType.deepseek:
        _name.text = 'DeepSeek';
        _endpoint.text = 'https://api.deepseek.com';
        _model = 'deepseek-v4-flash';
        break;
      case ProviderType.openai:
        _name.text = 'OpenAI';
        _endpoint.text = 'https://api.openai.com/v1';
        _model = 'gpt-4o';
        break;
      case ProviderType.claude:
        _name.text = 'Claude';
        _endpoint.text = 'https://api.anthropic.com/v1';
        _model = 'claude-3-sonnet-20240229';
        break;
      case ProviderType.gemini:
        _name.text = 'Gemini';
        _endpoint.text = 'https://generativelanguage.googleapis.com/v1beta';
        _model = 'gemini-pro';
        break;
      case ProviderType.ollama:
        _name.text = 'Ollama';
        _endpoint.text = 'http://localhost:11434';
        _model = 'llama2';
        break;
      case ProviderType.gateway:
        _name.text = '网关';
        _endpoint.text = '';
        _model = 'gpt-4o';
        break;
    }
  }

  Future<void> _test() async {
    if (_key.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('请先输入 API Key'), backgroundColor: AuroraColors.warning));
      return;
    }
    setState(() => _testing = true);
    try {
      final s = AIServiceFactory.create(type: _type, apiKey: _key.text, endpoint: _endpoint.text);
      final ok = await s.validateApiKey();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(ok ? '连接成功' : '连接失败：请检查 API Key 和端点是否正确'),
          backgroundColor: ok ? AuroraColors.success : AuroraColors.error,
        ));
      }
    } on AIServiceException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('连接失败：${e.message}'),
          backgroundColor: AuroraColors.error,
          duration: const Duration(seconds: 6),
        ));
      }
    } catch (e) {
      final msg = e.toString();
      final shortMsg = msg.length > 120 ? '${msg.substring(0, 120)}...' : msg;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('连接失败: $shortMsg'),
          backgroundColor: AuroraColors.error,
          duration: const Duration(seconds: 6),
        ));
      }
    } finally {
      if (mounted) setState(() => _testing = false);
    }
  }

  Future<void> _save() async {
    if (_key.text.isEmpty) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('请输入 API Key'))); return; }
    setState(() => _saving = true);
    try {
      // 先拉取可用模型
      final models = await AIServiceFactory.fetchAvailableModels(type: _type, apiKey: _key.text, endpoint: _endpoint.text);
      final c = AIProviderConfig(
        id: '${_type.name}_${DateTime.now().millisecondsSinceEpoch}',
        type: _type,
        name: _name.text,
        apiKey: _key.text,
        endpoint: _endpoint.text,
        defaultModel: _model.isNotEmpty ? _model : (models.isNotEmpty ? models.first.id : ''),
        availableModels: models.map((m) => m.id).toList(),
      );
      await ref.read(aiProviderListProvider.notifier).addProvider(c);
      if (mounted) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('已添加 · ${models.length} 个模型可用'))); Navigator.pop(context); }
    } catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('保存失败，请重试'))); }
    finally { if (mounted) setState(() => _saving = false); }
  }

  @override Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('配置提供商'), actions: [TextButton(onPressed: _saving ? null : _save, child: _saving ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('保存'))]),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // 类型选择
          Wrap(spacing: 8, runSpacing: 8, children: ProviderType.values.map((t) => ChoiceChip(label: Text(t.label, style: TextStyle(color: _type == t ? Colors.white : AuroraColors.text2, fontSize: 13)), selected: _type == t, onSelected: (_) { setState(() { _type = t; _defaults(); }); }, selectedColor: AuroraColors.primary, backgroundColor: AuroraColors.bg2, side: BorderSide(color: _type == t ? AuroraColors.primary : Colors.white.withOpacity(0.06)))).toList()),
          const SizedBox(height: 20),
          TextFormField(controller: _name, decoration: const InputDecoration(labelText: '名称')), const SizedBox(height: 14),
          TextFormField(controller: _key, obscureText: !_showKey, decoration: InputDecoration(
            labelText: 'API Key',
            hintText: _keyHint(),
            suffixIcon: IconButton(icon: Icon(_showKey ? Icons.visibility_off : Icons.visibility, size: 20), onPressed: () => setState(() => _showKey = !_showKey)),
          )), const SizedBox(height: 14),
          TextFormField(controller: _endpoint, decoration: const InputDecoration(labelText: 'API 端点')), const SizedBox(height: 20),

          // MiMo 配置指南
          if (_type == ProviderType.mimo) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AuroraColors.primary.withOpacity(0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AuroraColors.primary.withOpacity(0.15)),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('MiMo 配置指南', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AuroraColors.primaryGlow)),
                const SizedBox(height: 8),
                const Text('1. 登录 https://mimo.xiaomi.com 控制台', style: TextStyle(fontSize: 12, color: AuroraColors.text3)),
                const Text('2. 创建 API Key（格式：sk-xxx）', style: TextStyle(fontSize: 12, color: AuroraColors.text3)),
                const Text('3. 端点使用：https://api.xiaomimimo.com/v1', style: TextStyle(fontSize: 12, color: AuroraColors.text3)),
                const Text('4. Token Plan 用户使用：https://token-plan-cn.xiaomimimo.com/v1', style: TextStyle(fontSize: 12, color: AuroraColors.text3)),
              ]),
            ),
            const SizedBox(height: 16),
          ],

          const Text('模型', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AuroraColors.text1)), const SizedBox(height: 8),
          ..._models().map((m) => RadioListTile<String>(
            title: Text(m.name, style: TextStyle(fontSize: 14, color: _model == m.id ? AuroraColors.primaryGlow : AuroraColors.text2)),
            subtitle: m.description != null ? Text(m.description!, style: const TextStyle(fontSize: 12, color: AuroraColors.text3)) : null,
            value: m.id, groupValue: _model, onChanged: (v) => setState(() => _model = v!), activeColor: AuroraColors.primary,
            contentPadding: const EdgeInsets.symmetric(horizontal: 0), dense: true, visualDensity: VisualDensity.compact,
          )),
          const SizedBox(height: 20),
          SizedBox(width: double.infinity, child: OutlinedButton.icon(
            onPressed: _testing ? null : _test,
            icon: _testing ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.wifi_tethering),
            label: Text(_testing ? '测试中...' : '测试连接'),
          )),
        ]),
      ),
    );
  }

  String _keyHint() {
    switch (_type) {
      case ProviderType.mimo: return 'sk-xxx（API）或 tp-xxx（Token Plan）';
      case ProviderType.deepseek: return 'sk-xxx';
      case ProviderType.openai: return 'sk-xxx';
      case ProviderType.claude: return 'sk-ant-xxx';
      case ProviderType.gemini: return 'AIza-xxx';
      default: return '输入 API Key';
    }
  }

  List<AIModel> _models() => AIServiceFactory.defaultModelsFor(_type);
}
