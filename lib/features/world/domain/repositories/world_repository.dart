import '../entities/world.dart';
import '../entities/world_enums.dart';

/// 世界仓库接口
abstract class WorldRepository {
  /// 获取所有世界
  Future<List<World>> getWorlds({
    WorldSortBy sortBy = WorldSortBy.updatedAt,
    bool ascending = false,
  });
  
  /// 获取单个世界
  Future<World?> getWorld(String id);
  
  /// 创建世界
  Future<World> createWorld(World world);
  
  /// 更新世界
  Future<World> updateWorld(World world);
  
  /// 删除世界
  Future<void> deleteWorld(String id);
  
  /// 搜索世界
  Future<List<World>> searchWorlds(String query);
  
  /// 获取收藏世界
  Future<List<World>> getFavoriteWorlds();
  
  /// 切换收藏状态
  Future<void> toggleFavorite(String id);
  
  /// 添加场景
  Future<Scene> addScene(String worldId, Scene scene);
  
  /// 更新场景
  Future<Scene> updateScene(String worldId, Scene scene);
  
  /// 删除场景
  Future<void> deleteScene(String worldId, String sceneId);
  
  /// 设置当前场景
  Future<void> setCurrentScene(String worldId, String sceneId);
  
  /// 添加 NPC
  Future<NPC> addNPC(String worldId, NPC npc);
  
  /// 更新 NPC
  Future<NPC> updateNPC(String worldId, NPC npc);
  
  /// 删除 NPC
  Future<void> deleteNPC(String worldId, String npcId);
  
  /// 更新 NPC 关系
  Future<void> updateNPCRelationship(
    String worldId,
    String npcId,
    Map<String, String> relationships,
  );
  
  /// 添加剧情
  Future<Storyline> addStoryline(String worldId, Storyline storyline);
  
  /// 更新剧情
  Future<Storyline> updateStoryline(String worldId, Storyline storyline);
  
  /// 删除剧情
  Future<void> deleteStoryline(String worldId, String storylineId);
  
  /// 更新剧情节点
  Future<void> updateStoryNode(
    String worldId,
    String storylineId,
    StoryNode node,
  );
  
  /// 监听世界变化
  Stream<World?> watchWorld(String id);
  
  /// 监听世界列表变化
  Stream<List<World>> watchWorlds();
}
