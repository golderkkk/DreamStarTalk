import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/character.dart';
import '../../domain/entities/character_enums.dart';
import '../../domain/repositories/character_repository.dart';
import '../../data/datasources/character_local_datasource.dart';
import '../../data/repositories/character_repository_impl.dart';

/// 数据源 Provider（简单同步，已在 main 中初始化）
final characterDataSourceProvider = Provider<CharacterLocalDataSource>((ref) {
  return CharacterLocalDataSource();
});

/// 仓库 Provider
final characterRepositoryProvider = Provider<CharacterRepository>((ref) {
  final ds = ref.read(characterDataSourceProvider);
  return CharacterRepositoryImpl(localDataSource: ds);
});

/// 角色列表状态
class CharacterListState {
  final List<Character> characters;
  final bool isLoading;
  final String? error;

  const CharacterListState({this.characters = const [], this.isLoading = true, this.error});

  CharacterListState copyWith({List<Character>? characters, bool? isLoading, String? error}) {
    return CharacterListState(
      characters: characters ?? this.characters,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// 角色列表 Notifier（延迟加载）
class CharacterListNotifier extends StateNotifier<CharacterListState> {
  final CharacterRepository _repo;
  

  CharacterListNotifier(this._repo) : super(const CharacterListState());

  Future<void> loadCharacters() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final list = await _repo.getCharacters();
      if (mounted) state = state.copyWith(characters: list, isLoading: false);
    } catch (e) {
      if (mounted) state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> searchCharacters(String query) async {
    if (query.isEmpty) { await loadCharacters(); return; }
    state = state.copyWith(isLoading: true, error: null);
    try {
      final list = await _repo.searchCharacters(query);
      if (mounted) state = state.copyWith(characters: list, isLoading: false);
    } catch (e) {
      if (mounted) state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> deleteCharacter(String id) async {
    try {
      await _repo.deleteCharacter(id);
      await loadCharacters();
    } catch (e) {
      if (mounted) state = state.copyWith(error: e.toString());
    }
  }

  Future<void> toggleFavorite(String id) async {
    try {
      await _repo.toggleFavorite(id);
      await loadCharacters();
    } catch (e) {
      if (mounted) state = state.copyWith(error: e.toString());
    }
  }

  Future<void> updateSort(CharacterSortBy sortBy, bool ascending) async {
    final list = await _repo.getCharacters(sortBy: sortBy, ascending: ascending);
    if (mounted) state = state.copyWith(characters: list);
  }
}

/// 角色列表 Provider
final characterListProvider = StateNotifierProvider<CharacterListNotifier, CharacterListState>((ref) {
  final repo = ref.read(characterRepositoryProvider);
  return CharacterListNotifier(repo);
});

/// 单个角色 Provider
final characterProvider = FutureProvider.family<Character?, String>((ref, id) async {
  final repo = ref.read(characterRepositoryProvider);
  return repo.getCharacter(id);
});
