import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DataService {
  static final DataService _instance = DataService._internal();
  factory DataService() => _instance;
  DataService._internal();

  static const String _keyRestaurantName = 'resto_name';
  static const String _keyRestaurantLocation = 'resto_location';
  static const String _keyMenu = 'resto_menu';

  String _restaurantName = '';
  String _restaurantLocation = '';
  Map<String, int> _menu = {};

  String get restaurantName => _restaurantName;
  String get restaurantLocation => _restaurantLocation;
  Map<String, int> get menu => _menu;
  bool get hasData => _restaurantName.isNotEmpty && _menu.isNotEmpty;

  /// Dipanggil saat app pertama kali load.
  /// Cek URL parameter ?data=... dulu, kalau tidak ada pakai SharedPreferences.
  Future<void> init() async {
    // Coba baca dari URL (Flutter Web)
    if (kIsWeb) {
      final uri = Uri.base;
      final encoded = uri.queryParameters['data'];
      if (encoded != null && encoded.isNotEmpty) {
        try {
          final json = utf8.decode(base64Url.decode(base64Url.normalize(encoded)));
          await _parseAndSave(json);
          return;
        } catch (_) {}
      }
    }
    // Fallback: load dari SharedPreferences (kunjungan sebelumnya)
    await _loadSaved();
  }

  Future<void> _loadSaved() async {
    final prefs = await SharedPreferences.getInstance();
    _restaurantName = prefs.getString(_keyRestaurantName) ?? '';
    _restaurantLocation = prefs.getString(_keyRestaurantLocation) ?? '';
    final menuJson = prefs.getString(_keyMenu);
    if (menuJson != null) {
      final decoded = jsonDecode(menuJson) as Map<String, dynamic>;
      _menu = decoded.map((k, v) => MapEntry(k, (v as num).toInt()));
    }
  }

  Future<void> _parseAndSave(String jsonStr) async {
    final data = jsonDecode(jsonStr) as Map<String, dynamic>;
    _restaurantName = data['restaurantName'] ?? '';
    _restaurantLocation = data['restaurantLocation'] ?? '';
    final rawMenu = data['menu'] as Map<String, dynamic>? ?? {};
    _menu = rawMenu.map((k, v) => MapEntry(k, (v as num).toInt()));

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyRestaurantName, _restaurantName);
    await prefs.setString(_keyRestaurantLocation, _restaurantLocation);
    await prefs.setString(_keyMenu, jsonEncode(_menu));
  }
}
