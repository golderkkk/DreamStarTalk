import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/ai_provider.dart';
import '../../domain/repositories/ai_service.dart';
import '../../data/datasources/ai_provider_local_datasource.dart';
import '../../data/services/ai_service_factory.dart';

final aiProviderDataSourceProvider = Provider<AIProviderLocalDataSource>((ref) {
  return AIProviderLocalDataSource();
});

class AIProviderListState {
  final List<AIProviderConfig> providers;
  final bool isLoading;
  final String? error;
  const AIProviderListState({this.providers = const [], this.isLoading = true, this.error});
  AIProviderListState copyWith({List<AIProviderConfig>? providers, bool? isLoading, String? error}) {
    return AIProviderListState(providers: providers ?? this.providers, isLoading: isLoading ?? this.isLoading, error: error);
  }
}

class AIProviderListNotifier extends StateNotifier<AIProviderListState> {
  final AIProviderLocalDataSource _ds;
  bool _loaded = false;

  AIProviderListNotifier(this._ds) : super(const AIProviderListState());

  Future<void> loadProviders() async {
    _loaded = true;
    state = state.copyWith(isLoading: true, error: null);
    try {
      final list = await _ds.getAll();
      if (mounted) state = state.copyWith(providers: list, isLoading: false);
    } catch (e) {
      if (mounted) state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> ensureLoaded() async { if (!_loaded) await loadProviders(); }

  Future<void> addProvider(AIProviderConfig c) async { try { await _ds.save(c); await loadProviders(); } catch (e) { if (mounted) state = state.copyWith(error: e.toString()); } }
  Future<void> updateProvider(AIProviderConfig c) async { try { await _ds.save(c); await loadProviders(); } catch (e) { if (mounted) state = state.copyWith(error: e.toString()); } }
  Future<void> deleteProvider(String id) async { try { await _ds.delete(id); await loadProviders(); } catch (e) { if (mounted) state = state.copyWith(error: e.toString()); } }
  Future<void> toggleEnabled(String id) async {
    try {
      final p = await _ds.getById(id);
      if (p != null) { await _ds.save(p.copyWith(isEnabled: !p.isEnabled)); await loadProviders(); }
    } catch (e) { if (mounted) state = state.copyWith(error: e.toString()); }
  }
}

final aiProviderListProvider = StateNotifierProvider<AIProviderListNotifier, AIProviderListState>((ref) {
  final ds = ref.read(aiProviderDataSourceProvider);
  return AIProviderListNotifier(ds);
});

final activeAIServiceProvider = Provider<AIService?>((ref) {
  final state = ref.watch(aiProviderListProvider);
  final c = state.providers.where((p) => p.isEnabled).firstOrNull;
  if (c == null) return null;
  return AIServiceFactory.create(type: c.type, apiKey: c.apiKey, endpoint: c.endpoint);
});

final activeProviderConfigProvider = Provider<AIProviderConfig?>((ref) {
  final state = ref.watch(aiProviderListProvider);
  return state.providers.where((p) => p.isEnabled).firstOrNull;
});
