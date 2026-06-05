import 'package:easycatalog/utils/auth_service.dart';

class ApiService {
  final AuthService _auth = AuthService();

  Future<Map<String, dynamic>> getMyRestaurant() async {
    await Future.delayed(const Duration(milliseconds: 300));
    final r = _auth.restaurant;
    if (r == null) return {'status': 404, 'body': {'message': 'Not found'}};
    return {'status': 200, 'body': {'restaurant': r}};
  }

  Future<Map<String, dynamic>> updateRestaurant(Map<String, dynamic> data) async {
    await Future.delayed(const Duration(milliseconds: 400));
    _auth.updateRestaurantInfo(
      data['name'] ?? _auth.currentUser?.restaurantName ?? '',
      data['location'] ?? _auth.currentUser?.restaurantLocation ?? '',
    );
    return {'status': 200, 'body': {'message': 'Berhasil diperbarui.'}};
  }

  Future<Map<String, dynamic>> addMenuItem(String name, int price) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final menu = Map<String, dynamic>.from(_auth.currentUser?.menu ?? {});
    if (menu.containsKey(name)) {
      return {'status': 400, 'body': {'message': 'Menu sudah ada.'}};
    }
    menu[name] = price;
    _auth.updateMenu(menu);
    return {'status': 201, 'body': {'message': 'Menu berhasil ditambahkan.'}};
  }

  Future<Map<String, dynamic>> updateMenuItem(String oldName, String newName, int price) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final menu = Map<String, dynamic>.from(_auth.currentUser?.menu ?? {});
    menu.remove(oldName);
    menu[newName] = price;
    _auth.updateMenu(menu);
    return {'status': 200, 'body': {'message': 'Menu berhasil diperbarui.'}};
  }

  Future<Map<String, dynamic>> deleteMenuItem(String name) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final menu = Map<String, dynamic>.from(_auth.currentUser?.menu ?? {});
    menu.remove(name);
    _auth.updateMenu(menu);
    return {'status': 200, 'body': {'message': 'Menu berhasil dihapus.'}};
  }

  Future<Map<String, dynamic>> getProfile() async {
    await Future.delayed(const Duration(milliseconds: 300));
    final u = _auth.currentUser;
    if (u == null) return {'status': 401, 'body': {}};
    return {
      'status': 200,
      'body': {
        'user': {
          'name': u.ownerName,
          'email': u.email,
          'phone': u.phone,
          'restaurantName': u.restaurantName,
          'restaurantLocation': u.restaurantLocation,
        }
      }
    };
  }
}
