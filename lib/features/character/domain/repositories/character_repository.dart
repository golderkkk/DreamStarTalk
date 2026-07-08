import '../entities/character.dart';
import '../entities/character_enums.dart';

/// 角色仓库接口
abstract class CharacterRepository {
  /// 获取所有角色
  Future<List<Character>> getCharacters({
    CharacterSortBy sortBy = CharacterSortBy.updatedAt,
    bool ascending = false,
  });
  
  /// 获取单个角色
  Future<Character?> getCharacter(String id);
  
  /// 创建角色
  Future<Character> createCharacter(Character character);
  
  /// 更新角色
  Future<Character> updateCharacter(Character character);
  
  /// 删除角色
  Future<void> deleteCharacter(String id);
  
  /// 搜索角色
  Future<List<Character>> searchCharacters(String query);
  
  /// 获取收藏角色
  Future<List<Character>> getFavoriteCharacters();
  
  /// 切换收藏状态
  Future<void> toggleFavorite(String id);
  
  /// 导入角色
  Future<Character> importCharacter(String filePath, CharacterImportFormat format);
  
  /// 导出角色
  Future<String> exportCharacter(String id, CharacterExportFormat format);
  
  /// 导入角色卡（PNG）
  Future<Character> importCharacterCard(String pngPath);
  
  /// 监听角色列表变化
  Stream<List<Character>> watchCharacters();
  
  /// 监听单个角色变化
  Stream<Character?> watchCharacter(String id);
}
