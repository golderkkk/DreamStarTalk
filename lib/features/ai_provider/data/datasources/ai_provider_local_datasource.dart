import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../main.dart';
import '../../domain/entities/ai_provider.dart';

class AIProviderLocalDataSource {
  Box _box() => boxAIProviders!;

  Future<List<AIProviderConfig>> getAll() async {
    final b = _box();
    final list = <AIProviderConfig>[];
    for (var i = 0; i < b.length; i++) {
      try {
        final raw = b.getAt(i);
        if (raw == null) continue;
        list.add(AIProviderConfig.fromJson(_toMap(raw)));
      } catch (_) {}
    }
    return list;
  }

  Future<AIProviderConfig?> getById(String id) async {
    final raw = _box().get(id);
    if (raw == null) return null;
    try { return AIProviderConfig.fromJson(_toMap(raw)); } catch (_) { return null; }
  }

  Future<void> save(AIProviderConfig c) async { await _box().put(c.id, c.toJson()); }
  Future<void> delete(String id) async { await _box().delete(id); }

  Map<String, dynamic> _toMap(dynamic raw) {
    if (raw is Map) return raw.map((k, v) => MapEntry(k.toString(), _convertValue(v)));
    try {
      final decoded = jsonDecode(raw.toString());
      if (decoded is Map) return decoded.map((k, v) => MapEntry(k.toString(), _convertValue(v)));
    } catch (_) {}
    return {};
  }

  dynamic _convertValue(dynamic v) {
    if (v is Map) return v.map((k, val) => MapEntry(k.toString(), _convertValue(val)));
    if (v is List) return v.map(_convertValue).toList();
    if (v is bool || v is num || v is String || v == null) return v;
    return v.toString();
  }
}
