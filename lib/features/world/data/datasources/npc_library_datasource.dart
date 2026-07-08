import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../main.dart';
import '../../../world/domain/entities/world.dart';

class NPCLibraryDataSource {
  Box _box() => boxNPCLibrary!;

  Future<List<NPC>> getAll() async {
    final b = _box();
    final list = <NPC>[];
    for (var i = 0; i < b.length; i++) {
      try {
        final raw = b.getAt(i);
        if (raw == null) continue;
        list.add(NPC.fromJson(_toMap(raw)));
      } catch (_) {}
    }
    return list;
  }

  Future<NPC?> getById(String id) async {
    final raw = _box().get(id);
    if (raw == null) return null;
    try { return NPC.fromJson(_toMap(raw)); } catch (_) { return null; }
  }

  Future<void> save(NPC n) async { await _box().put(n.id, n.toJson()); }
  Future<void> delete(String id) async { await _box().delete(id); }

  Future<List<NPC>> search(String query) async {
    final all = await getAll();
    final q = query.toLowerCase();
    return all.where((n) => n.name.toLowerCase().contains(q) || (n.description?.toLowerCase().contains(q) ?? false) || n.tags.any((t) => t.toLowerCase().contains(q))).toList();
  }

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
