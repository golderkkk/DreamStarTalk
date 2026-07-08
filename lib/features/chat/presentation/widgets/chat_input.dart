import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dream_startalk/core/theme/aurora_theme.dart';
import '../../domain/entities/conversation.dart';

class ChatInput extends ConsumerStatefulWidget {
  final Function(String content, {String? targetCharacterId}) onSend;
  final VoidCallback? onStop;
  final bool isStreaming;
  final String? hintText;
  final List<CharacterReference>? availableCharacters;
  final FocusNode? focusNode;

  const ChatInput({
    super.key,
    required this.onSend,
    this.onStop,
    this.isStreaming = false,
    this.hintText,
    this.availableCharacters,
    this.focusNode,
  });

  @override
  ConsumerState<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends ConsumerState<ChatInput> {
  final _controller = TextEditingController();
  late final FocusNode _focusNode;
  bool _hasText = false;
  String? _selectedCharacterId;
  List<CharacterReference> _filteredCharacters = [];
  bool _wasComposing = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _controller.addListener(_onTextChanged);
  }

  @override
  void didUpdateWidget(covariant ChatInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isStreaming != widget.isStreaming) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _focusNode.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    if (widget.focusNode == null) _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final isComposing = _controller.value.composing.isValid;
    _hasText = _controller.text.trim().isNotEmpty;

    // 输入法组合中只更新 _hasText 但不触发 setState，防止键盘异常收起
    if (isComposing) {
      _wasComposing = true;
      return;
    }

    // 组合结束，刷新 UI
    _wasComposing = false;

    // @ 在文本中 -> 自动识别角色
    final text = _controller.text;
    final containsAt = text.contains('@');
    List<CharacterReference> newFiltered = [];
    if (containsAt && widget.availableCharacters != null && widget.availableCharacters!.isNotEmpty) {
      final lastAtIndex = text.lastIndexOf('@');
      final query = text.substring(lastAtIndex + 1).toLowerCase();
      newFiltered = widget.availableCharacters!
          .where((c) => c.name.toLowerCase().contains(query))
          .toList();
    }

    // setState 只在必要时触发
    setState(() => _filteredCharacters = newFiltered);
  }

  void _selectCharacter(CharacterReference character) {
    final text = _controller.text;
    final lastAtIndex = text.lastIndexOf('@');
    if (lastAtIndex >= 0) {
      _controller.text = '${text.substring(0, lastAtIndex)}@${character.name} ';
    } else {
      _controller.text = '$text @${character.name} ';
    }
    _controller.selection = TextSelection.fromPosition(TextPosition(offset: _controller.text.length));
    setState(() {
      _selectedCharacterId = character.id;
      _filteredCharacters = [];
    });
    _focusNode.requestFocus();
  }

  void _dismissMentions() {
    setState(() => _filteredCharacters = []);
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty && _selectedCharacterId == null) return;
    HapticFeedback.lightImpact();

    // 临时移除监听, 防止文本操作触发不必要的 setState
    _controller.removeListener(_onTextChanged);
    try {
      String? targetId = _selectedCharacterId;

      // 解析文本中的 @角色名 提及
      if (widget.availableCharacters != null && widget.availableCharacters!.isNotEmpty) {
        final atIndex = text.indexOf('@');
        if (atIndex >= 0) {
          final afterAt = text.substring(atIndex + 1);
          final spaceIndex = afterAt.indexOf(' ');
          final mention = spaceIndex > 0 ? afterAt.substring(0, spaceIndex) : afterAt;
          if (mention.isNotEmpty) {
            final character = widget.availableCharacters!.where((c) => c.name == mention).firstOrNull;
            if (character != null) {
              targetId = character.id;
              // 拼接 @ 前后文本, 保留 @mention 后面的内容
              final beforeAt = text.substring(0, atIndex);
              final afterMention = afterAt.substring(mention.length);
              final rest = '${beforeAt.trim()} ${afterMention.trim()}'.trim();
              _controller.text = rest;
            }
          }
        }
      }

      final msgText = _controller.text.trim();
      if (msgText.isEmpty && targetId != null) {
        widget.onSend('你好', targetCharacterId: targetId);
      } else if (msgText.isNotEmpty) {
        widget.onSend(msgText, targetCharacterId: targetId);
      }

      // 先置为单个空格防中文输入法关闭, 延迟再清空
      _controller.text = ' ';
      _selectedCharacterId = null;
      _filteredCharacters = [];
      _focusNode.requestFocus();
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          _controller.clear();
          _focusNode.requestFocus();
        }
      });
    } finally {
      _controller.addListener(_onTextChanged);
    }
  }

  @override
  Widget build(BuildContext context) {
    final showMentions = _filteredCharacters.isNotEmpty;

    return Column(children: [
      // @ 提及角色建议条 — 显示匹配的角色供快速选择
      if (showMentions) _buildMentionChips(),
      // Lore 触发提示
      if (_hasText && !showMentions) _buildLoreHints(),
      Container(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 20),
        decoration: const BoxDecoration(
          color: AuroraColors.bg0,
          border: Border(top: BorderSide(color: AuroraColors.border, width: 1)),
        ),
        child: SafeArea(
          top: false,
          child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Expanded(child: Container(
              constraints: const BoxConstraints(maxHeight: 120),
              decoration: BoxDecoration(
                color: AuroraColors.bg2,
                borderRadius: BorderRadius.circular(AuroraRadius.lg),
                border: Border.all(color: AuroraColors.border, width: 1),
              ),
              child: Row(children: [
                if (widget.availableCharacters != null && widget.availableCharacters!.length > 1)
                  IconButton(
                    icon: Icon(Icons.alternate_email, size: 20,
                        color: _selectedCharacterId != null || _filteredCharacters.isNotEmpty
                            ? AuroraColors.cyan
                            : AuroraColors.text3),
                    onPressed: () {
                      if (widget.availableCharacters != null && widget.availableCharacters!.isNotEmpty) {
                        _showCharacterPickerDialog(context);
                      }
                    },
                  ),
                Expanded(child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  maxLines: null,
                  textInputAction: TextInputAction.newline,
                  keyboardType: TextInputType.multiline,
                  style: const TextStyle(fontSize: 14, color: AuroraColors.text1),
                  decoration: InputDecoration(
                    hintText: widget.hintText ?? '输入消息...',
                    hintStyle: const TextStyle(color: AuroraColors.text4),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                    border: InputBorder.none,
                  ),
                )),
              ]),
            )),
            const SizedBox(width: 10),
            // 发送/停止按钮 — 使用 ValueListenableBuilder 避免重建 TextField
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: _controller,
              builder: (context, value, _) {
                final canSend = value.text.trim().isNotEmpty && !widget.isStreaming;
                return GestureDetector(
                  onTap: widget.isStreaming ? widget.onStop : (canSend ? _send : null),
                  child: AnimatedContainer(
                    duration: AuroraDuration.fast,
                    width: 42, height: 42,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AuroraRadius.md),
                      gradient: widget.isStreaming
                          ? null
                          : (canSend ? AuroraColors.gradientPrimary : null),
                      color: widget.isStreaming
                          ? AuroraColors.rose
                          : (canSend ? null : AuroraColors.bg3),
                      boxShadow: (canSend || widget.isStreaming)
                          ? [BoxShadow(color: AuroraColors.primary.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 2))]
                          : [],
                    ),
                    child: Icon(
                      widget.isStreaming ? Icons.stop : Icons.send,
                      size: 18,
                      color: canSend || widget.isStreaming ? Colors.white : AuroraColors.text4,
                    ),
                  ),
                );
              },
            ),
          ]),
        ),
      ),
    ]);
  }

  /// @ 提及角色建议条
  Widget _buildMentionChips() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: const BoxDecoration(
        color: AuroraColors.bg1,
        border: Border(bottom: BorderSide(color: AuroraColors.border, width: 0.5)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
        Row(children: [
          Icon(Icons.alternate_email, size: 12, color: AuroraColors.cyan.withOpacity(0.7)),
          const SizedBox(width: 4),
          Text('选择角色', style: TextStyle(fontSize: 11, color: AuroraColors.cyan.withOpacity(0.7), fontWeight: FontWeight.w500)),
          const Spacer(),
          GestureDetector(
            onTap: _dismissMentions,
            child: Icon(Icons.close, size: 14, color: AuroraColors.text4.withOpacity(0.5)),
          ),
        ]),
        const SizedBox(height: 6),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _filteredCharacters.take(8).map((c) => Padding(
              padding: const EdgeInsets.only(right: 6),
              child: GestureDetector(
                onTap: () => _selectCharacter(c),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: _selectedCharacterId == c.id
                        ? AuroraColors.cyan.withOpacity(0.18)
                        : AuroraColors.bg2,
                    borderRadius: BorderRadius.circular(AuroraRadius.full),
                    border: Border.all(
                      color: _selectedCharacterId == c.id
                          ? AuroraColors.cyan.withOpacity(0.4)
                          : AuroraColors.border,
                      width: 1,
                    ),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Container(
                      width: 18, height: 18,
                      decoration: BoxDecoration(
                        gradient: AuroraColors.gradientPrimary,
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Center(child: Text(c.name[0].toUpperCase(),
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700))),
                    ),
                    const SizedBox(width: 5),
                    Text('@${c.name}',
                        style: const TextStyle(fontSize: 12, color: AuroraColors.text1, fontWeight: FontWeight.w500)),
                  ]),
                ),
              ),
            )).toList(),
          ),
        ),
      ]),
    );
  }

  /// 弹出角色选择对话框
  void _showCharacterPickerDialog(BuildContext context) {
    final chars = widget.availableCharacters ?? [];
    showModalBottomSheet(
      context: context,
      backgroundColor: AuroraColors.bg4,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 36, height: 4, margin: const EdgeInsets.only(top: 12, bottom: 8),
              decoration: BoxDecoration(color: AuroraColors.text4.withOpacity(0.3), borderRadius: BorderRadius.circular(2))),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Text('选择对话角色', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AuroraColors.text1)),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text('选择后将 @角色 插入输入框', style: TextStyle(fontSize: 12, color: AuroraColors.text3)),
          ),
          const SizedBox(height: 8),
          ...chars.map((c) => ListTile(
            leading: CircleAvatar(radius: 18, backgroundColor: AuroraColors.primarySoft,
                child: Text(c.name[0].toUpperCase(), style: const TextStyle(color: AuroraColors.primaryGlow, fontWeight: FontWeight.w600))),
            title: Text(c.name, style: const TextStyle(color: AuroraColors.text1, fontWeight: FontWeight.w500)),
            onTap: () { Navigator.pop(ctx); _selectCharacter(c); },
          )),
          const SizedBox(height: 8),
        ]),
      ),
    );
  }

  void _showAttachmentOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AuroraColors.bg4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(AuroraRadius.xxl))),
      builder: (context) => SafeArea(child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 36, height: 4, margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(color: AuroraColors.text4, borderRadius: BorderRadius.circular(2))),
          _buildAttachmentOption(context, Icons.description_outlined, '发送文件名（仅文本）', AuroraColors.info,
              () { Navigator.pop(context); _pickFile(); }),
        ]),
      )),
    );
  }

  Widget _buildAttachmentOption(BuildContext context, IconData icon, String label, Color color, VoidCallback onTap) {
    return ListTile(
      leading: Container(width: 40, height: 40, decoration: BoxDecoration(
          color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(AuroraRadius.sm)),
          child: Icon(icon, color: color, size: 22)),
      title: Text(label, style: const TextStyle(color: AuroraColors.text1)),
      onTap: onTap,
    );
  }

  /// 显示 Lore 触发提示
  Widget _buildLoreHints() {
    final text = _controller.text.toLowerCase();
    if (text.length < 2) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(children: [
        Icon(Icons.auto_awesome, size: 12, color: AuroraColors.cyan.withOpacity(0.5)),
        const SizedBox(width: 6),
        Text('输入内容会自动匹配世界观中的场景和NPC',
            style: TextStyle(fontSize: 10, color: AuroraColors.cyan.withOpacity(0.5), fontStyle: FontStyle.italic)),
      ]),
    );
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(type: FileType.any, allowMultiple: false);
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (file.path != null) {
          widget.onSend('📎 ${file.name}', targetCharacterId: _selectedCharacterId);
          if (mounted) {
            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('文件已发送: ${file.name}')));
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('选择文件失败')));
      }
    }
  }
}
