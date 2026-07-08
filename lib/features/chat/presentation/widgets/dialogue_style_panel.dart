import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dream_startalk/core/theme/aurora_theme.dart';
import 'package:dream_startalk/features/settings/presentation/pages/settings_page.dart';
import '../../domain/entities/dialogue_style.dart';

/// 对话风格设置面板
class DialogueStylePanel extends ConsumerStatefulWidget {
  final DialogueStyleSettings initialSettings;
  final Function(DialogueStyleSettings) onSettingsChanged;
  final bool nsfwEnabled;
  final Function(bool)? onNSFWPolicyChanged;
  final VoidCallback? onClose;

  const DialogueStylePanel({
    super.key,
    required this.initialSettings,
    required this.onSettingsChanged,
    this.nsfwEnabled = false,
    this.onNSFWPolicyChanged,
    this.onClose,
  });

  @override
  ConsumerState<DialogueStylePanel> createState() => _DialogueStylePanelState();
}

class _DialogueStylePanelState extends ConsumerState<DialogueStylePanel> {
  late DialogueStyleSettings _settings;
  late bool _nsfwEnabled;

  @override
  void initState() {
    super.initState();
    _settings = widget.initialSettings;
    _nsfwEnabled = widget.nsfwEnabled;
  }

  void _update(DialogueStyleSettings Function(DialogueStyleSettings) updater) {
    setState(() {
      _settings = updater(_settings);
    });
    widget.onSettingsChanged(_settings);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: AuroraColors.bg4,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AuroraRadius.xxl)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 拖动条
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              color: AuroraColors.text4,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // 标题
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.tune, color: AuroraColors.primaryGlow, size: 24),
                const SizedBox(width: 8),
                const Text('对话风格设置', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AuroraColors.text1)),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, color: AuroraColors.text3),
                  onPressed: widget.onClose,
                ),
              ],
            ),
          ),
          const Divider(color: AuroraColors.border),
          // 设置内容
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                // 活人感
                _buildSection('活人感'),
                _buildSwitch('人格补充', '让角色更立体，避免刻板印象', _settings.personalitySupplement, (v) => _update((s) => s.copyWith(personalitySupplement: v))),
                _buildSwitch('情感基准', '显性呈现人物情绪', _settings.emotionBaseline, (v) => _update((s) => s.copyWith(emotionBaseline: v))),
                _buildSwitch('生动化', '口语化表达，增加真实感', _settings.vividness, (v) => _update((s) => s.copyWith(vividness: v))),
                
                const SizedBox(height: 16),
                // 情感基调
                _buildSection('情感基调'),
                _buildToneSelector(),
                
                const SizedBox(height: 16),
                // 字数设定
                _buildSection('字数设定'),
                _buildSwitch('启用字数限制', '控制回复长度', _settings.enableWordCount, (v) => _update((s) => s.copyWith(enableWordCount: v))),
                if (_settings.enableWordCount) ...[
                  Row(
                    children: [
                      Expanded(child: _buildNumberField('最少', _settings.minWordCount, (v) => _update((s) => s.copyWith(minWordCount: v)))),
                      const SizedBox(width: 16),
                      Expanded(child: _buildNumberField('最多', _settings.maxWordCount, (v) => _update((s) => s.copyWith(maxWordCount: v)))),
                    ],
                  ),
                ],
                
                const SizedBox(height: 16),
                // 附加选项
                _buildSection('附加选项'),
                _buildSwitch('防复述', '不重复用户输入内容', _settings.antiRepeat, (v) => _update((s) => s.copyWith(antiRepeat: v))),
                _buildSwitch('增加对白', '提升对话比例', _settings.addDialogue, (v) => _update((s) => s.copyWith(addDialogue: v))),
                _buildSwitch('深度写作', '提升思想深度', _settings.deepWriting, (v) => _update((s) => s.copyWith(deepWriting: v))),

                const SizedBox(height: 16),
                // 人称视角
                _buildSection('人称视角'),
                _buildPOVSelector(),

                const SizedBox(height: 24),
                // ── NSFW 模式区（策略 + 特化集中管理，需解锁） ──
                if (NSFWUnlockState.unlocked) Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AuroraColors.rose.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(AuroraRadius.lg),
                    border: Border.all(color: AuroraColors.rose.withOpacity(0.15), width: 1),
                  ),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      const Icon(Icons.whatshot, color: AuroraColors.rose, size: 18),
                      const SizedBox(width: 8),
                      const Text('NSFW 模式', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AuroraColors.rose)),
                    ]),
                    const SizedBox(height: 4),
                    Text('以下设置集中管理所有 NSFW 相关功能', style: TextStyle(fontSize: 11, color: AuroraColors.text4)),
                    const SizedBox(height: 12),
                    // NSFW 策略（内容过滤总开关）
                    Row(children: [
                      const Icon(Icons.shield, color: AuroraColors.amber, size: 18),
                      const SizedBox(width: 8),
                      Text('NSFW 策略', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _nsfwEnabled ? AuroraColors.rose : AuroraColors.text3)),
                      const Spacer(),
                      Switch(
                        value: _nsfwEnabled,
                        onChanged: (v) {
                          setState(() => _nsfwEnabled = v);
                          widget.onNSFWPolicyChanged?.call(v);
                        },
                        activeColor: AuroraColors.rose,
                      ),
                    ]),
                    Text(_nsfwEnabled ? '已开启 — 允许所有内容类型，无限制' : '关闭 — AI 将执行内容审查', style: TextStyle(fontSize: 11, color: _nsfwEnabled ? AuroraColors.rose.withOpacity(0.7) : AuroraColors.text4)),
                    const Divider(height: 16, color: AuroraColors.border),
                    // NSFW 特化（写作风格）
                    _buildSwitch('NSFW 特化', '多感官描写、情感驱动、节奏控制', _settings.nsfwMode, (v) => _update((s) => s.copyWith(nsfwMode: v))),
                    const Divider(height: 16, color: AuroraColors.border),
                    _buildSwitch('恋爱文特化', '丰富的内心独白、场景勾勒、动作细化', _settings.romanceMode, (v) => _update((s) => s.copyWith(romanceMode: v))),
                    const Divider(height: 16, color: AuroraColors.border),
                    _buildSwitch('反差特化', '外表与行为的强烈反差对比描写', _settings.nsfwContrast, (v) => _update((s) => s.copyWith(nsfwContrast: v))),
                    const Divider(height: 16, color: AuroraColors.border),
                    _buildSwitch('外表美化', '屏蔽生理瑕疵，保持角色外观干净平滑', _settings.beautification, (v) => _update((s) => s.copyWith(beautification: v))),
                  ]),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: AuroraColors.primaryGlow,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSwitch(String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return SwitchListTile(
      title: Text(title, style: const TextStyle(color: AuroraColors.text1, fontSize: 15)),
      subtitle: Text(subtitle, style: const TextStyle(color: AuroraColors.text3, fontSize: 12)),
      value: value,
      onChanged: onChanged,
      activeColor: AuroraColors.primary,
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildToneSelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildToneChip(null, '无', Icons.block),
        _buildToneChip(ToneType.healing, '治愈', Icons.favorite),
        _buildToneChip(ToneType.sad, '伤感', Icons.water_drop),
        _buildToneChip(ToneType.positive, '积极', Icons.wb_sunny),
        _buildToneChip(ToneType.negative, '消极', Icons.nights_stay),
      ],
    );
  }

  Widget _buildToneChip(ToneType? type, String label, IconData icon) {
    final selected = _settings.toneType == type;
    return ChoiceChip(
      avatar: Icon(icon, size: 16, color: selected ? Colors.white : AuroraColors.text3),
      label: Text(label),
      selected: selected,
      selectedColor: AuroraColors.primary,
      onSelected: (v) {
        _update((s) => s.copyWith(toneType: type));
      },
    );
  }

  Widget _buildPOVSelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildPOVChip(null, '默认'),
        ...PersonPOV.values.map((pov) => _buildPOVChip(pov, pov.label)),
      ],
    );
  }

  Widget _buildPOVChip(PersonPOV? pov, String label) {
    final selected = _settings.personPOV == pov;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      selectedColor: AuroraColors.primary,
      onSelected: (v) {
        _update((s) => s.copyWith(personPOV: pov));
      },
    );
  }

  Widget _buildNumberField(String label, int value, ValueChanged<int> onChanged) {
    return TextFormField(
      initialValue: value.toString(),
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        helperText: '最少 100 字',
      ),
      onChanged: (v) {
        final parsed = int.tryParse(v);
        if (parsed != null && parsed >= 100) {
          onChanged(parsed);
        }
      },
    );
  }
}

/// 显示对话风格设置面板
void showDialogueStylePanel(
  BuildContext context, {
  required DialogueStyleSettings initialSettings,
  required Function(DialogueStyleSettings) onSettingsChanged,
  bool nsfwEnabled = false,
  Function(bool)? onNSFWPolicyChanged,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => DialogueStylePanel(
      initialSettings: initialSettings,
      onSettingsChanged: (settings) {
        onSettingsChanged(settings);
      },
      nsfwEnabled: nsfwEnabled,
      onNSFWPolicyChanged: onNSFWPolicyChanged,
      onClose: () => Navigator.pop(context),
    ),
  );
}
