import 'package:flutter/material.dart';
import 'package:dream_startalk/core/theme/aurora_theme.dart';
import '../../domain/entities/conversation.dart';

class ConversationSettingsPanel extends StatefulWidget {
  final ConversationSettings settings;
  final Function(ConversationSettings) onSettingsChanged;
  final VoidCallback? onClose;
  const ConversationSettingsPanel({super.key, required this.settings, required this.onSettingsChanged, this.onClose});

  @override State<ConversationSettingsPanel> createState() => _ConversationSettingsPanelState();
}

class _ConversationSettingsPanelState extends State<ConversationSettingsPanel> {
  late ConversationSettings _s;

  @override void initState() { super.initState(); _s = widget.settings; }
  void _update(ConversationSettings s) { setState(() => _s = s); widget.onSettingsChanged(s); }

  @override Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.5),
      decoration: BoxDecoration(color: AuroraColors.bg4, borderRadius: const BorderRadius.vertical(top: Radius.circular(AuroraRadius.xxl))),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 40, height: 4, margin: const EdgeInsets.only(top: 12), decoration: BoxDecoration(color: AuroraColors.text4, borderRadius: BorderRadius.circular(2))),
        Padding(padding: const EdgeInsets.all(16), child: Row(children: [const Text('对话设置', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AuroraColors.text1)), const Spacer(), IconButton(icon: const Icon(Icons.close, size: 20, color: AuroraColors.text3), onPressed: widget.onClose)])),
        const Divider(color: AuroraColors.border, height: 1),
        Flexible(child: ListView(padding: const EdgeInsets.symmetric(horizontal: 16), children: [
          SwitchListTile(title: const Text('NSFW 模式', style: TextStyle(color: AuroraColors.text1)), value: _s.nsfwEnabled, onChanged: (v) => _update(_s.copyWith(nsfwEnabled: v)), activeColor: AuroraColors.error, contentPadding: EdgeInsets.zero),
          _slider('温度 (Temperature)', _s.temperature, 0, 2, (v) => _update(_s.copyWith(temperature: v))),
          _slider('Top P 采样', _s.topP, 0, 1, (v) => _update(_s.copyWith(topP: v))),
          _sliderInt('最大 Token', _s.maxTokens, 256, 8192, (v) => _update(_s.copyWith(maxTokens: v))),
          _sliderInt('上下文窗口', _s.contextWindowSize, 5, 50, (v) => _update(_s.copyWith(contextWindowSize: v))),
        ])),
      ]),
    );
  }

  Widget _slider(String label, double val, double min, double max, Function(double) onChanged) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: const TextStyle(fontSize: 14, color: AuroraColors.text2)), Text(val.toStringAsFixed(2), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AuroraColors.primaryGlow))]),
      Slider(value: val, min: min, max: max, divisions: ((max - min) * 10).toInt(), onChanged: onChanged, activeColor: AuroraColors.primary),
    ]);
  }

  Widget _sliderInt(String label, int val, int min, int max, Function(int) onChanged) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: const TextStyle(fontSize: 14, color: AuroraColors.text2)), Text('$val', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AuroraColors.primaryGlow))]),
      Slider(value: val.toDouble(), min: min.toDouble(), max: max.toDouble(), divisions: max - min, onChanged: (v) => onChanged(v.toInt()), activeColor: AuroraColors.primary),
    ]);
  }
}
