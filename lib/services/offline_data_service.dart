import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/exhibition.dart';

class OfflineDataService {
  static final OfflineDataService _instance = OfflineDataService._();
  factory OfflineDataService() => _instance;
  OfflineDataService._();

  static const String _exhibitionsKey = 'offline_exhibitions';
  static const String _favoritesKey = 'offline_favorites';
  static const String _lastSyncKey = 'last_sync_timestamp';

  Future<void> cacheExhibitions(List<Exhibition> exhibitions) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = exhibitions.map((e) => jsonEncode(e.toFirestore())).toList();
    await prefs.setStringList(_exhibitionsKey, jsonList);
    await prefs.setInt(_lastSyncKey, DateTime.now().millisecondsSinceEpoch);
  }

  Future<List<Exhibition>> getCachedExhibitions() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_exhibitionsKey) ?? [];
    return jsonList.map((json) => Exhibition.fromFirestore(
      jsonDecode(json) as Map<String, dynamic>,
      '',
    )).toList();
  }

  Future<void> cacheFavorites(List<String> favoriteIds) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_favoritesKey, favoriteIds);
  }

  Future<List<String>> getCachedFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_favoritesKey) ?? [];
  }

  Future<DateTime?> getLastSyncTime() async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getInt(_lastSyncKey);
    if (timestamp != null) {
      return DateTime.fromMillisecondsSinceEpoch(timestamp);
    }
    return null;
  }

  Future<bool> isCacheStale({Duration maxAge = const Duration(hours: 24)}) async {
    final lastSync = await getLastSyncTime();
    if (lastSync == null) return true;
    return DateTime.now().difference(lastSync) > maxAge;
  }

  Future<int> getCacheSize() async {
    final prefs = await SharedPreferences.getInstance();
    final exhibitions = prefs.getStringList(_exhibitionsKey) ?? [];
    final favorites = prefs.getStringList(_favoritesKey) ?? [];
    
    int size = 0;
    for (final e in exhibitions) size += e.length;
    for (final f in favorites) size += f.length;
    return size;
  }

  Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_exhibitionsKey);
    await prefs.remove(_favoritesKey);
    await prefs.remove(_lastSyncKey);
  }

  Future<Map<String, dynamic>> getCacheStats() async {
    final prefs = await SharedPreferences.getInstance();
    final exhibitions = prefs.getStringList(_exhibitionsKey) ?? [];
    final favorites = prefs.getStringList(_favoritesKey) ?? [];
    final lastSync = await getLastSyncTime();
    final size = await getCacheSize();

    return {
      'exhibitions_count': exhibitions.length,
      'favorites_count': favorites.length,
      'last_sync': lastSync?.toIso8601String() ?? 'Never',
      'size_bytes': size,
      'size_formatted': _formatBytes(size),
    };
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  Future<void> addToFavoritesOffline(String exhibitionId) async {
    final favorites = await getCachedFavorites();
    if (!favorites.contains(exhibitionId)) {
      favorites.add(exhibitionId);
      await cacheFavorites(favorites);
    }
  }

  Future<void> removeFromFavoritesOffline(String exhibitionId) async {
    final favorites = await getCachedFavorites();
    favorites.remove(exhibitionId);
    await cacheFavorites(favorites);
  }
}