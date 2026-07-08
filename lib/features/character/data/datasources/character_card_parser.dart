import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import '../../domain/entities/character.dart';
import '../../../world/domain/entities/world.dart';

/// SillyTavern PNG 角色卡/世界书解析器
/// 支持 SillyTavern/TavernAI 格式
class CharacterCardParser {
  static const List<int> _pngSignature = [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A];
  static const List<int> _textChunkType = [0x74, 0x45, 0x58, 0x74]; // tEXt
  static const List<int> _charaKeyword = [0x63, 0x68, 0x61, 0x72, 0x61]; // chara
  
  /// 从 PNG 文件解析角色卡
  static Future<ImportResult?> parseFromPng(String filePath) async {
    try {
      final file = File(filePath);
      final bytes = await file.readAsBytes();
      
      if (!_isValidPng(bytes)) {
        throw Exception('不是有效的 PNG 文件');
      }
      
      // 提取角色数据
      final charaData = _extractData(bytes, _charaKeyword);
      if (charaData == null) {
        throw Exception('未找到角色数据');
      }
      
      final json = jsonDecode(charaData) as Map<String, dynamic>;
      final character = _jsonToCharacter(json);
      
      // 保存头像图片
      final avatarPath = await _saveAvatar(bytes, character.id);
      
      return ImportResult(
        character: character.copyWith(avatar: avatarPath),
        rawJson: json,
      );
    } catch (e) {
      return null;
    }
  }
  
  /// 从 PNG 文件解析世界书（lorebook）
  static Future<World?> parseWorldbookFromPng(String filePath) async {
    try {
      final file = File(filePath);
      final bytes = await file.readAsBytes();
      
      if (!_isValidPng(bytes)) {
        throw Exception('不是有效的 PNG 文件');
      }
      
      // 提取世界书数据
      final charaData = _extractData(bytes, _charaKeyword);
      if (charaData == null) return null;
      
      final json = jsonDecode(charaData) as Map<String, dynamic>;
      return _parseWorldbook(json);
    } catch (e) {
      return null;
    }
  }
  
  /// 验证 PNG 文件
  static bool _isValidPng(Uint8List bytes) {
    if (bytes.length < 8) return false;
    for (var i = 0; i < 8; i++) {
      if (bytes[i] != _pngSignature[i]) return false;
    }
    return true;
  }
  
  /// 提取数据
  static String? _extractData(Uint8List bytes, List<int> keyword) {
    var offset = 8; // 跳过 PNG 签名
    
    while (offset < bytes.length - 12) {
      final length = (bytes[offset] << 24) |
          (bytes[offset + 1] << 16) |
          (bytes[offset + 2] << 8) |
          bytes[offset + 3];
      
      final chunkType = bytes.sublist(offset + 4, offset + 8);
      
      if (_isTextChunk(chunkType)) {
        final chunkData = bytes.sublist(offset + 8, offset + 8 + length);
        final data = _parseTextChunk(chunkData, keyword);
        if (data != null) return data;
      }
      
      offset += 12 + length;
    }
    
    return null;
  }
  
  static bool _isTextChunk(List<int> chunkType) {
    if (chunkType.length != 4) return false;
    for (var i = 0; i < 4; i++) {
      if (chunkType[i] != _textChunkType[i]) return false;
    }
    return true;
  }
  
  static String? _parseTextChunk(List<int> data, List<int> keyword) {
    var nullIndex = -1;
    for (var i = 0; i < data.length; i++) {
      if (data[i] == 0) {
        nullIndex = i;
        break;
      }
    }
    
    if (nullIndex == -1) return null;
    
    final chunkKeyword = data.sublist(0, nullIndex);
    if (!_matchesKeyword(chunkKeyword, keyword)) return null;
    
    final textBytes = data.sublist(nullIndex + 1);
    final text = utf8.decode(textBytes);
    
    try {
      final decoded = base64Decode(text);
      return utf8.decode(decoded);
    } catch (e) {
      return null;
    }
  }
  
  static bool _matchesKeyword(List<int> chunkKeyword, List<int> keyword) {
    if (chunkKeyword.length != keyword.length) return false;
    for (var i = 0; i < keyword.length; i++) {
      if (chunkKeyword[i] != keyword[i]) return false;
    }
    return true;
  }
  
  /// 保存头像图片
  static Future<String?> _saveAvatar(Uint8List pngBytes, String characterId) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final avatarDir = Directory('${appDir.path}/avatars');
      if (!await avatarDir.exists()) {
        await avatarDir.create(recursive: true);
      }
      
      final fileName = 'avatar_$characterId.png';
      final filePath = '${avatarDir.path}/$fileName';
      await File(filePath).writeAsBytes(pngBytes);
      return filePath;
    } catch (e) {
      return null;
    }
  }
  
  /// JSON 转 Character
  static Character _jsonToCharacter(Map<String, dynamic> json) {
    return Character(
      id: _generateId(),
      name: json['name'] as String? ?? '未命名角色',
      description: _cleanField(json['description']),
      personality: _cleanField(json['personality']),
      backstory: _cleanField(json['mes_example']),
      speakingStyle: null,
      systemPrompt: _cleanField(json['system_prompt']),
      firstMessage: _cleanField(json['first_mes']),
      exampleDialogues: _parseExampleDialogues(json['mes_example'] as String?),
      tags: _parseTags(json['tags']),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
  
  /// 清理字段值
  static String? _cleanField(dynamic value) {
    if (value == null) return null;
    final str = value.toString().trim();
    if (str.isEmpty || str == 'null') return null;
    return str;
  }
  
  /// 解析示例对话
  static List<String> _parseExampleDialogues(String? example) {
    if (example == null || example.isEmpty) return [];
    final dialogues = example.split('<START>');
    return dialogues
        .where((d) => d.trim().isNotEmpty)
        .map((d) => d.trim())
        .toList();
  }
  
  /// 解析标签
  static List<String> _parseTags(dynamic tags) {
    if (tags == null) return [];
    if (tags is List) {
      return tags.map((t) => t.toString()).toList();
    }
    if (tags is String) {
      return tags.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty).toList();
    }
    return [];
  }
  
  /// 解析世界书
  static World? _parseWorldbook(Map<String, dynamic> json) {
    final lorebook = json['character_book'] as Map<String, dynamic>?;
    if (lorebook == null) return null;
    
    final name = lorebook['name'] as String? ?? '导入的世界观';
    final description = lorebook['description'] as String?;
    final entries = lorebook['entries'] as List<dynamic>? ?? [];
    
    final scenes = <Scene>[];
    final npcs = <NPC>[];
    
    for (final entry in entries) {
      final entryMap = entry as Map<String, dynamic>;
      final content = entryMap['content'] as String? ?? '';
      final comment = entryMap['comment'] as String? ?? '';
      
      // 判断是场景还是 NPC
      if (_isSceneEntry(entryMap)) {
        scenes.add(Scene(
          id: 'scene_${entryMap['id'] ?? scenes.length}',
          name: comment.isNotEmpty ? comment : '场景 ${scenes.length + 1}',
          description: content,
        ));
      } else if (_isNPCEntry(entryMap)) {
        npcs.add(NPC(
          id: 'npc_${entryMap['id'] ?? npcs.length}',
          name: comment.isNotEmpty ? comment : 'NPC ${npcs.length + 1}',
          description: content,
        ));
      }
    }
    
    return World(
      id: 'world_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      description: description,
      scenes: scenes,
      npcs: npcs,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
  
  static bool _isSceneEntry(Map<String, dynamic> entry) {
    final keys = entry.keys.join(' ').toLowerCase();
    return keys.contains('scene') || keys.contains('location') || keys.contains('place');
  }
  
  static bool _isNPCEntry(Map<String, dynamic> entry) {
    final keys = entry.keys.join(' ').toLowerCase();
    return keys.contains('npc') || keys.contains('character') || keys.contains('person');
  }
  
  static String _generateId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = DateTime.now().microsecondsSinceEpoch % 10000;
    return 'char_${timestamp}_$random';
  }

  /// 将角色卡导出为 PNG（SillyTavern TavernCard V2 格式）
  static Future<String> exportToPng(Character character) async {
    final jsonData = utf8.encode(const JsonEncoder.withIndent('  ').convert(character.toJson()));
    final compressed = _compress(jsonData);

    // 构建 PNG with tEXt chunk
    final pngBytes = _buildPngWithText(compressed, character.name);

    final dir = await getApplicationDocumentsDirectory();
    final exportDir = Directory('${dir.path}/character_cards');
    if (!await exportDir.exists()) await exportDir.create(recursive: true);

    final fileName = '${character.name.replaceAll(RegExp(r'[\\/*?:"<>|]'), '_')}.png';
    final file = File('${exportDir.path}/$fileName');
    await file.writeAsBytes(pngBytes);
    return file.path;
  }

  static Uint8List _buildPngWithText(Uint8List textData, String charName) {
    final buf = BytesBuilder();
    // PNG signature
    buf.add(Uint8List.fromList(_pngSignature));

    // IHDR chunk
    final ihdrData = ByteData(13)
      ..setUint32(0, 1) // width
      ..setUint32(4, 1) // height
      ..setUint8(8, 8)  // bit depth
      ..setUint8(9, 2)  // color type (RGB)
      ..setUint8(10, 0) // compression
      ..setUint8(11, 0) // filter
      ..setUint8(12, 0); // interlace
    _writeChunk(buf, [0x49, 0x48, 0x44, 0x52], ihdrData.buffer.asUint8List());

    // tEXt chunk with chara keyword
    final keyword = utf8.encode('chara');
    final nullSeparator = Uint8List(1);
    final chunkData = BytesBuilder()
      ..add(keyword)
      ..add(nullSeparator)
      ..add(textData);
    _writeChunk(buf, _textChunkType, chunkData.toBytes());

    // IDAT chunk (minimal image data)
    final deflated = _deflate(Uint8List.fromList([0, 0]));
    _writeChunk(buf, [0x49, 0x44, 0x41, 0x54], deflated);

    // CRC for IDAT
    final crc = _crc32(_concat([0x49, 0x44, 0x41, 0x54], deflated));
    buf.add(_uint32ToBytes(crc));

    // IEND chunk
    _writeChunk(buf, [0x49, 0x45, 0x4E, 0x44], Uint8List(0));

    return buf.toBytes();
  }

  static void _writeChunk(BytesBuilder buf, List<int> type, Uint8List data) {
    final len = _uint32ToBytes(data.length);
    buf.add(len);
    buf.add(Uint8List.fromList(type));
    buf.add(data);
    final crc = _crc32(_concat(type, data));
    buf.add(_uint32ToBytes(crc));
  }

  static Uint8List _uint32ToBytes(int value) {
    return Uint8List(4)..buffer.asByteData().setUint32(0, value);
  }

  static int _crc32(List<int> data) {
    var crc = 0xFFFFFFFF;
    for (final byte in data) {
      crc ^= byte;
      for (var i = 0; i < 8; i++) {
        if ((crc & 1) != 0) {
          crc = (crc >> 1) ^ 0xEDB88320;
        } else {
          crc >>= 1;
        }
      }
    }
    return crc ^ 0xFFFFFFFF;
  }

  static Uint8List _concat(List<int> a, List<int> b) {
    return Uint8List.fromList([...a, ...b]);
  }

  static Uint8List _compress(Uint8List data) {
    return Uint8List.fromList(data); // 不压缩，保持可读性
  }

  static Uint8List _deflate(Uint8List data) {
    // Minimal deflate: 0x78 0x01 header + data + adler32
    final adler = _adler32(data);
    final buf = BytesBuilder()
      ..addByte(0x78)
      ..addByte(0x01)
      ..add(data)
      ..add(_uint32ToBytes(adler));
    return buf.toBytes();
  }

  static int _adler32(Uint8List data) {
    var a = 1, b = 0;
    for (final byte in data) {
      a = (a + byte) % 65521;
      b = (b + a) % 65521;
    }
    return (b << 16) | a;
  }
}

/// 导入结果
class ImportResult {
  final Character character;
  final Map<String, dynamic> rawJson;
  
  const ImportResult({
    required this.character,
    required this.rawJson,
  });
}
