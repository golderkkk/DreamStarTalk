import '../../domain/entities/world.dart';
import '../../domain/entities/world_enums.dart';
import '../../domain/repositories/world_repository.dart';
import '../datasources/world_local_datasource.dart';

/// 世界仓库实现
class WorldRepositoryImpl implements WorldRepository {
  final WorldLocalDataSource _localDataSource;
  
  WorldRepositoryImpl({
    required WorldLocalDataSource localDataSource,
  }) : _localDataSource = localDataSource;
  
  @override
  Future<List<World>> getWorlds({
    WorldSortBy sortBy = WorldSortBy.updatedAt,
    bool ascending = false,
  }) async {
    var worlds = await _localDataSource.getAll();
    
    // 排序
    worlds.sort((a, b) {
      int comparison;
      switch (sortBy) {
        case WorldSortBy.name:
          comparison = a.name.compareTo(b.name);
          break;
        case WorldSortBy.createdAt:
          comparison = (a.createdAt ?? DateTime.now())
              .compareTo(b.createdAt ?? DateTime.now());
          break;
        case WorldSortBy.updatedAt:
          comparison = (a.updatedAt ?? DateTime.now())
              .compareTo(b.updatedAt ?? DateTime.now());
          break;
      }
      return ascending ? comparison : -comparison;
    });
    
    return worlds;
  }
  
  @override
  Future<World?> getWorld(String id) async {
    return await _localDataSource.getById(id);
  }
  
  @override
  Future<World> createWorld(World world) async {
    final now = DateTime.now();
    final newWorld = world.copyWith(
      createdAt: now,
      updatedAt: now,
    );
    await _localDataSource.save(newWorld);
    return newWorld;
  }
  
  @override
  Future<World> updateWorld(World world) async {
    final updatedWorld = world.copyWith(
      updatedAt: DateTime.now(),
    );
    await _localDataSource.save(updatedWorld);
    return updatedWorld;
  }
  
  @override
  Future<void> deleteWorld(String id) async {
    await _localDataSource.delete(id);
  }
  
  @override
  Future<List<World>> searchWorlds(String query) async {
    final all = await _localDataSource.getAll();
    final lowerQuery = query.toLowerCase();
    return all.where((w) {
      return w.name.toLowerCase().contains(lowerQuery) ||
          (w.description?.toLowerCase().contains(lowerQuery) ?? false) ||
          w.tags.any((t) => t.toLowerCase().contains(lowerQuery));
    }).toList();
  }
  
  @override
  Future<List<World>> getFavoriteWorlds() async {
    final all = await _localDataSource.getAll();
    return all.where((w) => w.isFavorite).toList();
  }
  
  @override
  Future<void> toggleFavorite(String id) async {
    final world = await _localDataSource.getById(id);
    if (world != null) {
      final updated = world.copyWith(isFavorite: !world.isFavorite);
      await _localDataSource.save(updated);
    }
  }
  
  @override
  Future<Scene> addScene(String worldId, Scene scene) async {
    final world = await _localDataSource.getById(worldId);
    if (world == null) throw Exception('世界不存在');
    
    final updatedScenes = [...world.scenes, scene];
    final updated = world.copyWith(
      scenes: updatedScenes,
      updatedAt: DateTime.now(),
    );
    await _localDataSource.save(updated);
    return scene;
  }
  
  @override
  Future<Scene> updateScene(String worldId, Scene scene) async {
    final world = await _localDataSource.getById(worldId);
    if (world == null) throw Exception('世界不存在');
    
    final updatedScenes = world.scenes.map((s) {
      if (s.id == scene.id) return scene;
      return s;
    }).toList();
    
    final updated = world.copyWith(
      scenes: updatedScenes,
      updatedAt: DateTime.now(),
    );
    await _localDataSource.save(updated);
    return scene;
  }
  
  @override
  Future<void> deleteScene(String worldId, String sceneId) async {
    final world = await _localDataSource.getById(worldId);
    if (world == null) throw Exception('世界不存在');
    
    final updatedScenes = world.scenes.where((s) => s.id != sceneId).toList();
    final updated = world.copyWith(
      scenes: updatedScenes,
      currentSceneId: world.currentSceneId == sceneId ? null : world.currentSceneId,
      updatedAt: DateTime.now(),
    );
    await _localDataSource.save(updated);
  }
  
  @override
  Future<void> setCurrentScene(String worldId, String sceneId) async {
    final world = await _localDataSource.getById(worldId);
    if (world == null) throw Exception('世界不存在');
    
    final updated = world.copyWith(
      currentSceneId: sceneId,
      updatedAt: DateTime.now(),
    );
    await _localDataSource.save(updated);
  }
  
  @override
  Future<NPC> addNPC(String worldId, NPC npc) async {
    final world = await _localDataSource.getById(worldId);
    if (world == null) throw Exception('世界不存在');
    
    final updatedNPCs = [...world.npcs, npc];
    final updated = world.copyWith(
      npcs: updatedNPCs,
      updatedAt: DateTime.now(),
    );
    await _localDataSource.save(updated);
    return npc;
  }
  
  @override
  Future<NPC> updateNPC(String worldId, NPC npc) async {
    final world = await _localDataSource.getById(worldId);
    if (world == null) throw Exception('世界不存在');
    
    final updatedNPCs = world.npcs.map((n) {
      if (n.id == npc.id) return npc;
      return n;
    }).toList();
    
    final updated = world.copyWith(
      npcs: updatedNPCs,
      updatedAt: DateTime.now(),
    );
    await _localDataSource.save(updated);
    return npc;
  }
  
  @override
  Future<void> deleteNPC(String worldId, String npcId) async {
    final world = await _localDataSource.getById(worldId);
    if (world == null) throw Exception('世界不存在');
    
    final updatedNPCs = world.npcs.where((n) => n.id != npcId).toList();
    final updated = world.copyWith(
      npcs: updatedNPCs,
      updatedAt: DateTime.now(),
    );
    await _localDataSource.save(updated);
  }
  
  @override
  Future<void> updateNPCRelationship(
    String worldId,
    String npcId,
    Map<String, String> relationships,
  ) async {
    final world = await _localDataSource.getById(worldId);
    if (world == null) throw Exception('世界不存在');
    
    final updatedNPCs = world.npcs.map((n) {
      if (n.id == npcId) {
        return n.copyWith(relationships: relationships);
      }
      return n;
    }).toList();
    
    final updated = world.copyWith(
      npcs: updatedNPCs,
      updatedAt: DateTime.now(),
    );
    await _localDataSource.save(updated);
  }
  
  @override
  Future<Storyline> addStoryline(String worldId, Storyline storyline) async {
    final world = await _localDataSource.getById(worldId);
    if (world == null) throw Exception('世界不存在');
    
    final updatedStorylines = [...world.storylines, storyline];
    final updated = world.copyWith(
      storylines: updatedStorylines,
      updatedAt: DateTime.now(),
    );
    await _localDataSource.save(updated);
    return storyline;
  }
  
  @override
  Future<Storyline> updateStoryline(String worldId, Storyline storyline) async {
    final world = await _localDataSource.getById(worldId);
    if (world == null) throw Exception('世界不存在');
    
    final updatedStorylines = world.storylines.map((s) {
      if (s.id == storyline.id) return storyline;
      return s;
    }).toList();
    
    final updated = world.copyWith(
      storylines: updatedStorylines,
      updatedAt: DateTime.now(),
    );
    await _localDataSource.save(updated);
    return storyline;
  }
  
  @override
  Future<void> deleteStoryline(String worldId, String storylineId) async {
    final world = await _localDataSource.getById(worldId);
    if (world == null) throw Exception('世界不存在');
    
    final updatedStorylines = world.storylines
        .where((s) => s.id != storylineId)
        .toList();
    
    final updated = world.copyWith(
      storylines: updatedStorylines,
      updatedAt: DateTime.now(),
    );
    await _localDataSource.save(updated);
  }
  
  @override
  Future<void> updateStoryNode(
    String worldId,
    String storylineId,
    StoryNode node,
  ) async {
    final world = await _localDataSource.getById(worldId);
    if (world == null) throw Exception('世界不存在');
    
    final updatedStorylines = world.storylines.map((s) {
      if (s.id == storylineId) {
        final updatedNodes = s.nodes.map((n) {
          if (n.id == node.id) return node;
          return n;
        }).toList();
        return s.copyWith(nodes: updatedNodes);
      }
      return s;
    }).toList();
    
    final updated = world.copyWith(
      storylines: updatedStorylines,
      updatedAt: DateTime.now(),
    );
    await _localDataSource.save(updated);
  }
  
  @override
  Stream<World?> watchWorld(String id) {
    return _localDataSource.watchById(id).map((event) {
      if (event.value == null) return null;
      return World.fromJson(Map<String, dynamic>.from(event.value as Map));
    });
  }
  
  @override
  Stream<List<World>> watchWorlds() {
    return _localDataSource.watch().map((_) {
      // 简化实现，实际应该异步获取
      return [];
    });
  }
}
