import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/world.dart';
import '../../data/datasources/npc_library_datasource.dart';

final npcLibraryDataSourceProvider = Provider<NPCLibraryDataSource>((ref) => NPCLibraryDataSource());

class NPCLibraryState {
  final List<NPC> npcs; final bool isLoading; final String? error;
  const NPCLibraryState({this.npcs = const [], this.isLoading = true, this.error});
  NPCLibraryState copyWith({List<NPC>? npcs, bool? isLoading, String? error}) => NPCLibraryState(npcs: npcs ?? this.npcs, isLoading: isLoading ?? this.isLoading, error: error);
}

class NPCLibraryNotifier extends StateNotifier<NPCLibraryState> {
  final NPCLibraryDataSource _ds;
  NPCLibraryNotifier(this._ds) : super(const NPCLibraryState());

  Future<void> load() async { state = state.copyWith(isLoading: true, error: null); try { final l = await _ds.getAll(); if (mounted) state = state.copyWith(npcs: l, isLoading: false); } catch (e) { if (mounted) state = state.copyWith(isLoading: false, error: e.toString()); } }
  Future<void> add(NPC n) async { try { await _ds.save(n); await load(); } catch (e) { if (mounted) state = state.copyWith(error: e.toString()); } }
  Future<void> update(NPC n) async { try { await _ds.save(n); await load(); } catch (e) { if (mounted) state = state.copyWith(error: e.toString()); } }
  Future<void> remove(String id) async { try { await _ds.delete(id); await load(); } catch (e) { if (mounted) state = state.copyWith(error: e.toString()); } }
  Future<void> search(String q) async { if (q.isEmpty) { await load(); return; } state = state.copyWith(isLoading: true); try { final l = await _ds.search(q); if (mounted) state = state.copyWith(npcs: l, isLoading: false); } catch (e) { if (mounted) state = state.copyWith(isLoading: false, error: e.toString()); } }
}

final npcLibraryProvider = StateNotifierProvider<NPCLibraryNotifier, NPCLibraryState>((ref) { final ds = ref.read(npcLibraryDataSourceProvider); return NPCLibraryNotifier(ds); });
