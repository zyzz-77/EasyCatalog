import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DataService {
  static final DataService _instance = DataService._internal();
  factory DataService() => _instance;
  DataService._internal();

  String _restaurantName = '';
  String _restaurantLocation = '';
  String? _merchantId;
  Map<String, int> _menu = {};

  String get restaurantName => _restaurantName;
  String get restaurantLocation => _restaurantLocation;
  String? get merchantId => _merchantId;
  Map<String, int> get menu => _menu;
  bool get hasData => _restaurantName.isNotEmpty && _menu.isNotEmpty;

  Future<void> init() async {
    if (kIsWeb) {
      final uri = Uri.base;
      final encoded = uri.queryParameters['data'];
      if (encoded != null && encoded.isNotEmpty) {
        try {
          final json =
              utf8.decode(base64Url.decode(base64Url.normalize(encoded)));
          await _parseAndSave(json);
          return;
        } catch (_) {}
      }
    }
    await _loadSaved();
  }

  Future<void> _loadSaved() async {
    final prefs = await SharedPreferences.getInstance();
    _restaurantName = prefs.getString('resto_name') ?? '';
    _restaurantLocation = prefs.getString('resto_location') ?? '';
    _merchantId = prefs.getString('merchant_id');
    final menuJson = prefs.getString('resto_menu');
    if (menuJson != null) {
      final decoded = jsonDecode(menuJson) as Map<String, dynamic>;
      _menu = decoded.map((k, v) => MapEntry(k, (v as num).toInt()));
    }
  }

  Future<void> _parseAndSave(String jsonStr) async {
    final data = jsonDecode(jsonStr) as Map<String, dynamic>;
    _restaurantName = data['restaurantName'] ?? '';
    _restaurantLocation = data['restaurantLocation'] ?? '';
    _merchantId = data['merchantId'];
    final rawMenu = data['menu'] as Map<String, dynamic>? ?? {};
    _menu = rawMenu.map((k, v) => MapEntry(k, (v as num).toInt()));

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('resto_name', _restaurantName);
    await prefs.setString('resto_location', _restaurantLocation);
    await prefs.setString('resto_menu', jsonEncode(_menu));
    if (_merchantId != null) await prefs.setString('merchant_id', _merchantId!);
  }
}
