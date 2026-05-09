import 'package:shared_preferences/shared_preferences.dart';
import 'package:easyorder/models/models.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  // Mock user database
  static final List<Map<String, dynamic>> _users = [];
  static int _idCounter = 1;

  Future<void> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');
    if (userId != null) {
      final user = _users.firstWhere(
        (u) => u['id'] == userId,
        orElse: () => {},
      );
      if (user.isNotEmpty) {
        _currentUser = UserModel(
          id: user['id'],
          name: user['name'],
          email: user['email'],
          phone: user['phone'],
        );
      }
    }
  }

  Future<Map<String, dynamic>> register(
      String name, String email, String phone, String password) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final exists = _users.any((u) => u['email'] == email || u['phone'] == phone);
    if (exists) {
      return {'success': false, 'message': 'Email atau no HP sudah terdaftar.'};
    }
    final id = 'user_${_idCounter++}';
    _users.add({
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'password': password,
    });
    _currentUser = UserModel(id: id, name: name, email: email, phone: phone);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_id', id);
    return {'success': true};
  }

  Future<Map<String, dynamic>> login(String emailOrPhone, String password) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final user = _users.firstWhere(
      (u) =>
          (u['email'] == emailOrPhone || u['phone'] == emailOrPhone) &&
          u['password'] == password,
      orElse: () => {},
    );
    if (user.isEmpty) {
      return {'success': false, 'message': 'Email/No HP atau password salah.'};
    }
    _currentUser = UserModel(
      id: user['id'],
      name: user['name'],
      email: user['email'],
      phone: user['phone'],
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_id', user['id']);
    return {'success': true};
  }

  Future<void> updateProfile({String? name, String? email, String? phone}) async {
    await Future.delayed(const Duration(milliseconds: 400));
    if (_currentUser == null) return;
    final idx = _users.indexWhere((u) => u['id'] == _currentUser!.id);
    if (idx == -1) return;
    if (name != null) { _users[idx]['name'] = name; _currentUser!.name = name; }
    if (email != null) { _users[idx]['email'] = email; _currentUser!.email = email; }
    if (phone != null) { _users[idx]['phone'] = phone; _currentUser!.phone = phone; }
  }

  Future<void> deleteAccount() async {
    if (_currentUser == null) return;
    _users.removeWhere((u) => u['id'] == _currentUser!.id);
    await logout();
  }

  Future<void> logout() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_id');
  }
}
