import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/world.dart';
import '../../domain/entities/world_enums.dart';
import '../../data/datasources/world_local_datasource.dart';
import '../../data/repositories/world_repository_impl.dart';

final worldDataSourceProvider = Provider<WorldLocalDataSource>((ref) {
  return WorldLocalDataSource();
});

final worldRepositoryProvider = Provider<WorldRepositoryImpl>((ref) {
  final ds = ref.read(worldDataSourceProvider);
  return WorldRepositoryImpl(localDataSource: ds);
});

class WorldListState {
  final List<World> worlds;
  final bool isLoading;
  final String? error;

  const WorldListState({this.worlds = const [], this.isLoading = true, this.error});

  WorldListState copyWith({List<World>? worlds, bool? isLoading, String? error}) {
    return WorldListState(worlds: worlds ?? this.worlds, isLoading: isLoading ?? this.isLoading, error: error);
  }
}

class WorldListNotifier extends StateNotifier<WorldListState> {
  final WorldRepositoryImpl _repo;

  WorldListNotifier(this._repo) : super(const WorldListState());

  Future<void> loadWorlds() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final list = await _repo.getWorlds();
      if (mounted) state = state.copyWith(worlds: list, isLoading: false);
    } catch (e) {
      if (mounted) state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> searchWorlds(String query) async {
    if (query.isEmpty) { await loadWorlds(); return; }
    state = state.copyWith(isLoading: true, error: null);
    try {
      final list = await _repo.searchWorlds(query);
      if (mounted) state = state.copyWith(worlds: list, isLoading: false);
    } catch (e) {
      if (mounted) state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> deleteWorld(String id) async {
    try { await _repo.deleteWorld(id); await loadWorlds(); } catch (e) { if (mounted) state = state.copyWith(error: e.toString()); }
  }

  Future<void> toggleFavorite(String id) async {
    try { await _repo.toggleFavorite(id); await loadWorlds(); } catch (e) { if (mounted) state = state.copyWith(error: e.toString()); }
  }

  Future<void> updateSort(WorldSortBy sortBy, bool ascending) async {
    final list = await _repo.getWorlds(sortBy: sortBy, ascending: ascending);
    if (mounted) state = state.copyWith(worlds: list);
  }
}

final worldListProvider = StateNotifierProvider<WorldListNotifier, WorldListState>((ref) {
  final repo = ref.read(worldRepositoryProvider);
  return WorldListNotifier(repo);
});

final worldProvider = FutureProvider.family<World?, String>((ref, id) async {
  final repo = ref.read(worldRepositoryProvider);
  return repo.getWorld(id);
});

// WorldEditState and WorldEditNotifier kept for editing pages
class WorldEditState {
  final World? world;
  final bool isLoading;
  final bool isSaving;
  final String? error;
  final bool isDirty;

  const WorldEditState({this.world, this.isLoading = false, this.isSaving = false, this.error, this.isDirty = false});
  WorldEditState copyWith({World? world, bool? isLoading, bool? isSaving, String? error, bool? isDirty}) {
    return WorldEditState(world: world ?? this.world, isLoading: isLoading ?? this.isLoading, isSaving: isSaving ?? this.isSaving, error: error, isDirty: isDirty ?? this.isDirty);
  }
}

class WorldEditNotifier extends StateNotifier<WorldEditState> {
  final WorldRepositoryImpl _repo;
  final String? worldId;

  WorldEditNotifier(this._repo, this.worldId) : super(const WorldEditState()) {
    if (worldId != null) loadWorld(worldId!);
  }

  Future<void> loadWorld(String id) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final w = await _repo.getWorld(id);
      if (mounted) state = state.copyWith(world: w, isLoading: false);
    } catch (e) {
      if (mounted) state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void updateWorldInfo({String? name, String? description, String? rules, String? history, String? coverImage, List<String>? tags}) {
    if (state.world == null) return;
    final u = state.world!.copyWith(name: name ?? state.world!.name, description: description ?? state.world!.description, rules: rules ?? state.world!.rules, history: history ?? state.world!.history, coverImage: coverImage ?? state.world!.coverImage, tags: tags ?? state.world!.tags);
    state = state.copyWith(world: u, isDirty: true);
  }

  Future<void> saveWorld() async {
    if (state.world == null) return;
    state = state.copyWith(isSaving: true, error: null);
    try {
      final saved = state.world!.createdAt == null ? await _repo.createWorld(state.world!) : await _repo.updateWorld(state.world!);
      if (mounted) state = state.copyWith(world: saved, isSaving: false, isDirty: false);
    } catch (e) {
      if (mounted) state = state.copyWith(isSaving: false, error: e.toString());
    }
  }

  Future<void> addScene(Scene s) async { if (state.world == null) return; try { await _repo.addScene(state.world!.id, s); await loadWorld(state.world!.id); } catch (e) { if (mounted) state = state.copyWith(error: e.toString()); } }
  Future<void> updateScene(Scene s) async { if (state.world == null) return; try { await _repo.updateScene(state.world!.id, s); await loadWorld(state.world!.id); } catch (e) { if (mounted) state = state.copyWith(error: e.toString()); } }
  Future<void> deleteScene(String id) async { if (state.world == null) return; try { await _repo.deleteScene(state.world!.id, id); await loadWorld(state.world!.id); } catch (e) { if (mounted) state = state.copyWith(error: e.toString()); } }
  Future<void> setCurrentScene(String id) async { if (state.world == null) return; try { await _repo.setCurrentScene(state.world!.id, id); await loadWorld(state.world!.id); } catch (e) { if (mounted) state = state.copyWith(error: e.toString()); } }
  Future<void> addNPC(NPC n) async { if (state.world == null) return; try { await _repo.addNPC(state.world!.id, n); await loadWorld(state.world!.id); } catch (e) { if (mounted) state = state.copyWith(error: e.toString()); } }
  Future<void> updateNPC(NPC n) async { if (state.world == null) return; try { await _repo.updateNPC(state.world!.id, n); await loadWorld(state.world!.id); } catch (e) { if (mounted) state = state.copyWith(error: e.toString()); } }
  Future<void> deleteNPC(String id) async { if (state.world == null) return; try { await _repo.deleteNPC(state.world!.id, id); await loadWorld(state.world!.id); } catch (e) { if (mounted) state = state.copyWith(error: e.toString()); } }
  Future<void> addStoryline(Storyline s) async { if (state.world == null) return; try { await _repo.addStoryline(state.world!.id, s); await loadWorld(state.world!.id); } catch (e) { if (mounted) state = state.copyWith(error: e.toString()); } }
  Future<void> updateStoryline(Storyline s) async { if (state.world == null) return; try { await _repo.updateStoryline(state.world!.id, s); await loadWorld(state.world!.id); } catch (e) { if (mounted) state = state.copyWith(error: e.toString()); } }
  Future<void> deleteStoryline(String id) async { if (state.world == null) return; try { await _repo.deleteStoryline(state.world!.id, id); await loadWorld(state.world!.id); } catch (e) { if (mounted) state = state.copyWith(error: e.toString()); } }
}

final worldEditProvider = StateNotifierProvider.family<WorldEditNotifier, WorldEditState, String?>((ref, worldId) {
  final repo = ref.read(worldRepositoryProvider);
  return WorldEditNotifier(repo, worldId);
});
