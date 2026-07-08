import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dream_startalk/core/theme/aurora_theme.dart';
import '../../domain/entities/ai_provider.dart';
import '../providers/ai_provider.dart';
import 'provider_config_page.dart';

class ProviderListPage extends ConsumerStatefulWidget {
  const ProviderListPage({super.key});
  @override ConsumerState<ProviderListPage> createState() => _ProviderListPageState();
}

class _ProviderListPageState extends ConsumerState<ProviderListPage> {
  @override void initState() { super.initState(); Future.microtask(() => ref.read(aiProviderListProvider.notifier).loadProviders()); }

  @override Widget build(BuildContext context) {
    final state = ref.watch(aiProviderListProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('AI 提供商'), actions: [IconButton(icon: const Icon(Icons.add), onPressed: () => _add())]),
      body: state.isLoading ? const Center(child: CircularProgressIndicator())
        : state.providers.isEmpty ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 72, height: 72, decoration: BoxDecoration(shape: BoxShape.circle, color: AuroraColors.primary.withOpacity(0.1)), child: const Icon(Icons.cloud_outlined, size: 32, color: AuroraColors.primary)),
            const SizedBox(height: 16), const Text('还没有 AI 提供商', style: TextStyle(color: AuroraColors.text2)),
            const SizedBox(height: 24), FilledButton.icon(onPressed: _add, icon: const Icon(Icons.add), label: const Text('添加提供商')),
          ]))
        : ListView.builder(padding: const EdgeInsets.all(16), itemCount: state.providers.length, itemBuilder: (_, i) {
            final p = state.providers[i]; final color = [AuroraColors.primary, AuroraColors.info, AuroraColors.success, Colors.purple, AuroraColors.error, Colors.teal, Colors.indigo][p.type.index % 7];
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AuroraColors.bg2, borderRadius: BorderRadius.circular(16)),
              child: Row(children: [
                Container(width: 44, height: 44, decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(12)), child: Icon(_icon(p.type), color: color, size: 24)),
                const SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(p.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AuroraColors.text1)),
                  Text(p.type.label, style: const TextStyle(fontSize: 13, color: AuroraColors.text3)),
                ])),
                Switch(value: p.isEnabled, onChanged: (_) => ref.read(aiProviderListProvider.notifier).toggleEnabled(p.id), activeColor: AuroraColors.success),
                IconButton(icon: const Icon(Icons.delete_outline, size: 18, color: AuroraColors.text3), onPressed: () {
                  showDialog(context: context, builder: (_) => AlertDialog(
                    backgroundColor: AuroraColors.bg1,
                    title: Text('删除 ${p.name}'),
                    content: const Text('确定删除此提供商？相关配置将丢失。'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(_), child: const Text('取消')),
                      TextButton(onPressed: () { Navigator.pop(_); ref.read(aiProviderListProvider.notifier).deleteProvider(p.id); }, style: TextButton.styleFrom(foregroundColor: AuroraColors.error), child: const Text('删除')),
                    ],
                  ));
                }),
              ]),
            );
          }),
    );
  }

  IconData _icon(ProviderType t) {
    return switch (t) { ProviderType.mimo => Icons.auto_awesome, ProviderType.deepseek => Icons.psychology, ProviderType.openai => Icons.smart_toy, ProviderType.claude => Icons.android, ProviderType.gemini => Icons.diamond, ProviderType.ollama => Icons.computer, ProviderType.gateway => Icons.language };
  }

  void _add() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AuroraColors.bg1,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (ctx, scrollCtrl) => Column(children: [
          Container(width: 40, height: 4, margin: const EdgeInsets.only(top: 12), decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(2))),
          const Padding(padding: EdgeInsets.all(16), child: Text('选择提供商', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AuroraColors.text1))),
          Expanded(child: ListView.builder(
            controller: scrollCtrl,
            itemCount: ProviderType.values.length,
            itemBuilder: (ctx, i) {
              final t = ProviderType.values[i];
              return ListTile(leading: Icon(_icon(t)), title: Text(t.label), onTap: () { Navigator.pop(ctx); Navigator.push(context, MaterialPageRoute(builder: (_) => ProviderConfigPage(providerType: t))); });
            },
          )),
        ]),
      ),
    );
  }
}
