import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../../domain/entities/character.dart';
import '../../domain/entities/character_enums.dart';
import '../../domain/repositories/character_repository.dart';
import '../../../world/domain/entities/world.dart';
import '../datasources/character_local_datasource.dart';
import '../datasources/character_card_parser.dart';

/// 角色仓库实现
class CharacterRepositoryImpl implements CharacterRepository {
  final CharacterLocalDataSource _localDataSource;
  
  CharacterRepositoryImpl({
    required CharacterLocalDataSource localDataSource,
  }) : _localDataSource = localDataSource;
  
  @override
  Future<List<Character>> getCharacters({
    CharacterSortBy sortBy = CharacterSortBy.updatedAt,
    bool ascending = false,
  }) async {
    var characters = await _localDataSource.getAll();
    
    characters.sort((a, b) {
      int comparison;
      switch (sortBy) {
        case CharacterSortBy.name:
          comparison = a.name.compareTo(b.name);
        case CharacterSortBy.createdAt:
          comparison = (a.createdAt ?? DateTime.now())
              .compareTo(b.createdAt ?? DateTime.now());
        case CharacterSortBy.updatedAt:
          comparison = (a.updatedAt ?? DateTime.now())
              .compareTo(b.updatedAt ?? DateTime.now());
      }
      return ascending ? comparison : -comparison;
    });
    
    return characters;
  }
  
  @override
  Future<Character?> getCharacter(String id) async {
    return await _localDataSource.getById(id);
  }
  
  @override
  Future<Character> createCharacter(Character character) async {
    final now = DateTime.now();
    final newCharacter = character.copyWith(createdAt: now, updatedAt: now);
    await _localDataSource.save(newCharacter);
    return newCharacter;
  }
  
  @override
  Future<Character> updateCharacter(Character character) async {
    final updatedCharacter = character.copyWith(updatedAt: DateTime.now());
    await _localDataSource.save(updatedCharacter);
    return updatedCharacter;
  }
  
  @override
  Future<void> deleteCharacter(String id) async {
    await _localDataSource.delete(id);
  }
  
  @override
  Future<List<Character>> searchCharacters(String query) async {
    return await _localDataSource.search(query);
  }
  
  @override
  Future<List<Character>> getFavoriteCharacters() async {
    final all = await _localDataSource.getAll();
    return all.where((c) => c.isFavorite).toList();
  }
  
  @override
  Future<void> toggleFavorite(String id) async {
    final character = await _localDataSource.getById(id);
    if (character != null) {
      final updated = character.copyWith(isFavorite: !character.isFavorite);
      await _localDataSource.save(updated);
    }
  }
  
  @override
  Future<Character> importCharacter(
    String filePath,
    CharacterImportFormat format,
  ) async {
    Character character;
    
    switch (format) {
      case CharacterImportFormat.json:
        character = await _importFromJson(filePath);
      case CharacterImportFormat.png:
        character = await importCharacterCard(filePath);
      case CharacterImportFormat.tavernai:
        character = await _importFromTavernAI(filePath);
    }
    
    return await createCharacter(character);
  }
  
  @override
  Future<String> exportCharacter(
    String id,
    CharacterExportFormat format,
  ) async {
    final character = await _localDataSource.getById(id);
    if (character == null) {
      throw Exception('角色不存在');
    }
    
    switch (format) {
      case CharacterExportFormat.json:
        return await _exportToJson(character);
      case CharacterExportFormat.png:
        return await _exportToPng(character, id);
    }
  }

  Future<String> _exportToPng(Character character, String? sourceId) async {
    // Fallback: export as JSON with .json extension when no PNG source
    final dir = await getApplicationDocumentsDirectory();
    final exportDir = Directory('${dir.path}/exports');
    if (!await exportDir.exists()) await exportDir.create(recursive: true);
    final filePath = '${exportDir.path}/${character.name}_${DateTime.now().millisecondsSinceEpoch}.json';
    final file = File(filePath);
    await file.writeAsString(const JsonEncoder.withIndent('  ').convert(character.toJson()));
    return filePath;
  }
  
  @override
  Future<Character> importCharacterCard(String pngPath) async {
    final result = await CharacterCardParser.parseFromPng(pngPath);
    if (result == null) throw Exception('无法解析角色卡');
    return result.character;
  }
  
  /// 从 PNG 导入角色并保存
  Future<Character> importAndSaveFromPng(String pngPath) async {
    final result = await CharacterCardParser.parseFromPng(pngPath);
    if (result == null) throw Exception('无法解析角色卡');
    return await createCharacter(result.character);
  }
  
  /// 从 PNG 导入世界书
  Future<World?> importWorldbookFromPng(String pngPath) async {
    return await CharacterCardParser.parseWorldbookFromPng(pngPath);
  }
  
  @override
  Stream<List<Character>> watchCharacters() => _localDataSource.watch().asyncMap((_) => _localDataSource.getAll());
  
  @override
  Stream<Character?> watchCharacter(String id) => _localDataSource.watchById(id).asyncMap((_) => _localDataSource.getById(id));
  
  Future<Character> _importFromJson(String filePath) async {
    final file = File(filePath);
    final jsonStr = await file.readAsString();
    final data = jsonDecode(jsonStr) as Map<String, dynamic>;
    final character = Character.fromJson(data);
    return character.copyWith(id: 'char_${DateTime.now().millisecondsSinceEpoch}');
  }
  
  Future<Character> _importFromTavernAI(String filePath) async {
    return await importCharacterCard(filePath);
  }
  
  Future<String> _exportToJson(Character character) async {
    final dir = await getApplicationDocumentsDirectory();
    final exportDir = Directory('${dir.path}/exports');
    if (!await exportDir.exists()) await exportDir.create(recursive: true);
    final filePath = '${exportDir.path}/${character.name}_${DateTime.now().millisecondsSinceEpoch}.json';
    final file = File(filePath);
    final jsonStr = const JsonEncoder.withIndent('  ').convert(character.toJson());
    await file.writeAsString(jsonStr);
    return filePath;
  }

  /// 批量导出所有角色为JSON文件
  Future<String> exportAllCharacters() async {
    final all = await _localDataSource.getAll();
    final dir = await getApplicationDocumentsDirectory();
    final exportDir = Directory('${dir.path}/exports');
    if (!await exportDir.exists()) await exportDir.create(recursive: true);
    final filePath = '${exportDir.path}/all_characters_${DateTime.now().millisecondsSinceEpoch}.json';
    final file = File(filePath);
    final data = all.map((c) => c.toJson()).toList();
    await file.writeAsString(const JsonEncoder.withIndent('  ').convert(data));
    return filePath;
  }

  /// 从JSON文件批量导入角色
  Future<int> importCharactersFromJson(String filePath) async {
    final file = File(filePath);
    final jsonStr = await file.readAsString();
    final List<dynamic> data = jsonDecode(jsonStr);
    int count = 0;
    for (final item in data) {
      try {
        final character = Character.fromJson(item as Map<String, dynamic>);
        await createCharacter(character.copyWith(id: 'char_${DateTime.now().millisecondsSinceEpoch}_$count'));
        count++;
      } catch (_) {}
    }
    return count;
  }
}
