import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../main.dart';
import '../../domain/entities/character.dart';

class CharacterLocalDataSource {
  Box _box() => boxCharacters!;

  Future<List<Character>> getAll() async {
    final b = _box();
    final list = <Character>[];
    for (var i = 0; i < b.length; i++) {
      try {
        final raw = b.getAt(i);
        if (raw == null) continue;
        final map = _toMap(raw);
        list.add(Character.fromJson(map));
      } catch (e) {
        // Skip corrupt entries silently
      }
    }
    return list;
  }

  Future<Character?> getById(String id) async {
    final raw = _box().get(id);
    if (raw == null) return null;
    try {
      return Character.fromJson(_toMap(raw));
    } catch (_) {
      return null;
    }
  }

  Future<void> save(Character c) async {
    await _box().put(c.id, c.toJson());
  }

  Future<void> delete(String id) async {
    await _box().delete(id);
  }

  Stream<BoxEvent> watch() => _box().watch();
  Stream<BoxEvent> watchById(String id) => _box().watch(key: id);

  Future<List<Character>> search(String query) async {
    final all = await getAll();
    final q = query.toLowerCase();
    return all.where((c) =>
      c.name.toLowerCase().contains(q) ||
      (c.description?.toLowerCase().contains(q) ?? false) ||
      c.tags.any((t) => t.toLowerCase().contains(q))
    ).toList();
  }

  /// Deep conversion: handles Hive's Map<dynamic,dynamic> and nested values
  Map<String, dynamic> _toMap(dynamic raw) {
    if (raw is Map) {
      return raw.map((k, v) => MapEntry(k.toString(), _convertValue(v)));
    }
    try {
      final decoded = jsonDecode(raw.toString());
      if (decoded is Map) return decoded.map((k, v) => MapEntry(k.toString(), _convertValue(v)));
    } catch (_) {}
    return {};
  }

  /// Recursively convert nested Hive values to Dart types
  dynamic _convertValue(dynamic v) {
    if (v is Map) return v.map((k, val) => MapEntry(k.toString(), _convertValue(val)));
    if (v is List) return v.map(_convertValue).toList();
    if (v is bool || v is num || v is String || v == null) return v;
    return v.toString();
  }
}
