import 'package:shared_preferences/shared_preferences.dart';

class MerchantUser {
  final String id;
  String ownerName;
  String email;
  String phone;
  String password;
  String restaurantName;
  String restaurantLocation;
  Map<String, dynamic> menu;

  MerchantUser({
    required this.id,
    required this.ownerName,
    required this.email,
    required this.phone,
    required this.password,
    required this.restaurantName,
    required this.restaurantLocation,
    this.menu = const {},
  });
}

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  MerchantUser? _currentUser;
  MerchantUser? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  static final List<MerchantUser> _users = [];
  static int _idCounter = 1;

  Future<void> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('merchant_user_id');
    if (userId != null) {
      final user = _users.where((u) => u.id == userId).firstOrNull;
      if (user != null) _currentUser = user;
    }
  }

  Future<Map<String, dynamic>> register({
    required String ownerName,
    required String email,
    required String phone,
    required String password,
    required String restaurantName,
    required String restaurantLocation,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final exists = _users.any((u) => u.email == email);
    if (exists) {
      return {'success': false, 'message': 'Email sudah terdaftar.'};
    }
    final id = 'merchant_${_idCounter++}';
    final user = MerchantUser(
      id: id,
      ownerName: ownerName,
      email: email,
      phone: phone,
      password: password,
      restaurantName: restaurantName,
      restaurantLocation: restaurantLocation,
      menu: {},
    );
    _users.add(user);
    _currentUser = user;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('merchant_user_id', id);
    return {'success': true};
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final user = _users.where((u) => u.email == email && u.password == password).firstOrNull;
    if (user == null) {
      return {'success': false, 'message': 'Email atau password salah.'};
    }
    _currentUser = user;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('merchant_user_id', user.id);
    return {'success': true};
  }

  Future<void> updateProfile({
    String? ownerName,
    String? email,
    String? phone,
    String? restaurantName,
    String? restaurantLocation,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    if (_currentUser == null) return;
    if (ownerName != null) _currentUser!.ownerName = ownerName;
    if (email != null) _currentUser!.email = email;
    if (phone != null) _currentUser!.phone = phone;
    if (restaurantName != null) _currentUser!.restaurantName = restaurantName;
    if (restaurantLocation != null) _currentUser!.restaurantLocation = restaurantLocation;
  }

  Future<Map<String, dynamic>> changePassword(String oldPassword, String newPassword) async {
    await Future.delayed(const Duration(milliseconds: 400));
    if (_currentUser == null) return {'success': false, 'message': 'Tidak ada user.'};
    if (_currentUser!.password != oldPassword) {
      return {'success': false, 'message': 'Password lama salah.'};
    }
    _currentUser!.password = newPassword;
    return {'success': true};
  }

  Future<void> logout() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('merchant_user_id');
  }

  // Restaurant methods
  Map<String, dynamic>? get restaurant {
    if (_currentUser == null) return null;
    return {
      'name': _currentUser!.restaurantName,
      'location': _currentUser!.restaurantLocation,
      'menu': _currentUser!.menu,
    };
  }

  void updateRestaurantInfo(String name, String location) {
    _currentUser?.restaurantName = name;
    _currentUser?.restaurantLocation = location;
  }

  void updateMenu(Map<String, dynamic> menu) {
    _currentUser?.menu = menu;
  }
}
