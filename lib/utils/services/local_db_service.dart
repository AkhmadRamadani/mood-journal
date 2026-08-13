import 'dart:developer';
import 'package:hive_flutter/hive_flutter.dart';

class LocalDbService {
  static final LocalDbService _instance = LocalDbService._internal();
  factory LocalDbService() => _instance;
  LocalDbService._internal();

  static const String authBoxName = 'auth';
  static const String cacheBoxName = 'api_cache';
  static const String waterBoxName = 'water';

  final Map<String, Box> _boxes = {};

  Future<void> init() async {
    await Hive.initFlutter();
    await _openBox(authBoxName);
    await _openBox(cacheBoxName);
    await _openBox(waterBoxName);
  }

  Future<Box> _openBox(String name) async {
    if (_boxes.containsKey(name) && _boxes[name]!.isOpen) {
      return _boxes[name]!;
    }
    final box = await Hive.openBox(name);
    _boxes[name] = box;
    return box;
  }

  Box getBox(String name) {
    if (_boxes.containsKey(name) && _boxes[name]!.isOpen) {
      return _boxes[name]!;
    }
    final box = Hive.box(name);
    _boxes[name] = box;
    return box;
  }

  // ── Generic Key-Value Storage Methods ───────────────────────────────────────

  Future<void> save(String boxName, String key, dynamic value) async {
    if (key.isEmpty) return;
    try {
      await getBox(boxName).put(key, value);
    } catch (e) {
      log('LocalDb error saving [$key] in [$boxName]: $e');
    }
  }

  dynamic get(String boxName, String key, {dynamic defaultValue}) {
    if (key.isEmpty) return defaultValue;
    try {
      return getBox(boxName).get(key, defaultValue: defaultValue);
    } catch (e) {
      log('LocalDb error reading [$key] from [$boxName]: $e');
      return defaultValue;
    }
  }

  Future<void> delete(String boxName, String key) async {
    if (key.isEmpty) return;
    try {
      await getBox(boxName).delete(key);
    } catch (e) {
      log('LocalDb error deleting [$key] from [$boxName]: $e');
    }
  }

  Future<void> clearBox(String boxName) async {
    try {
      await getBox(boxName).clear();
    } catch (e) {
      log('LocalDb error clearing [$boxName]: $e');
    }
  }

  // ── API Cache Helper Methods ───────────────────────────────────────────────

  Future<void> saveCache(String key, String data) async {
    await save(cacheBoxName, key, data);
  }

  String? getCache(String key) {
    return get(cacheBoxName, key) as String?;
  }

  Future<void> deleteCache(String key) async {
    await delete(cacheBoxName, key);
  }

  Future<void> clearCache() async {
    await clearBox(cacheBoxName);
  }

  // ── Auth Helper Methods ────────────────────────────────────────────────────

  Future<void> saveAuth(String key, dynamic data) async {
    await save(authBoxName, key, data);
  }

  dynamic getAuth(String key) {
    return get(authBoxName, key);
  }

  Future<void> deleteAuth(String key) async {
    await delete(authBoxName, key);
  }

  Future<void> clearAuth() async {
    await clearBox(authBoxName);
  }

  // ── Water Helper Methods ───────────────────────────────────────────────────

  Future<void> clearWater() async {
    await clearBox(waterBoxName);
  }
}
