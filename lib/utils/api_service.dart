class ApiService {
  static const _mockEmail = 'admin@easycatalog.com';
  static const _mockPassword = 'admin123';
  static const _mockToken = 'mock_access_token_123';
  static const _mockRefreshToken = 'mock_refresh_token_456';

  static Map<String, dynamic> _restaurant = {
    'user_id': 'user_001',
    'name': 'Warung Makan Barokah',
    'location': 'Jl. Sudirman No. 12, Bandung',
    'menu': {
      'Nasi Goreng Special': 25000,
      'Ayam Bakar': 35000,
      'Es Teh Manis': 5000,
      'Soto Ayam': 20000,
    },
    'image_url': null,
  };

  static final Map<String, dynamic> _user = {
    'id': 'user_001',
    'name': 'Admin Barokah',
    'email': _mockEmail,
  };

  Future<Map<String, dynamic>> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 800));
    if (email == _mockEmail && password == _mockPassword) {
      return {
        'status': 201,
        'body': {
          'message': 'Successfully authenticated.',
          'accessToken': _mockToken,
          'refreshToken': _mockRefreshToken,
        }
      };
    }
    return {
      'status': 401,
      'body': {'message': 'Email atau password salah.'}
    };
  }

  Future<Map<String, dynamic>> getMyRestaurant() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return {
      'status': 200,
      'body': {'restaurant': Map<String, dynamic>.from(_restaurant)}
    };
  }

  Future<Map<String, dynamic>> updateRestaurant(Map<String, dynamic> data) async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (data['name'] != null) _restaurant['name'] = data['name'];
    if (data['location'] != null) _restaurant['location'] = data['location'];
    return {
      'status': 200,
      'body': {'message': 'Restoran berhasil diperbarui.'}
    };
  }

  Future<Map<String, dynamic>> addMenuItem(String name, int price) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final menu = Map<String, dynamic>.from(_restaurant['menu'] as Map);
    if (menu.containsKey(name)) {
      return {'status': 400, 'body': {'message': 'Menu sudah ada.'}};
    }
    menu[name] = price;
    _restaurant['menu'] = menu;
    return {'status': 201, 'body': {'message': 'Menu berhasil ditambahkan.'}};
  }

  Future<Map<String, dynamic>> updateMenuItem(String oldName, String newName, int price) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final menu = Map<String, dynamic>.from(_restaurant['menu'] as Map);
    menu.remove(oldName);
    menu[newName] = price;
    _restaurant['menu'] = menu;
    return {'status': 200, 'body': {'message': 'Menu berhasil diperbarui.'}};
  }

  Future<Map<String, dynamic>> deleteMenuItem(String name) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final menu = Map<String, dynamic>.from(_restaurant['menu'] as Map);
    menu.remove(name);
    _restaurant['menu'] = menu;
    return {'status': 200, 'body': {'message': 'Menu berhasil dihapus.'}};
  }

  Future<Map<String, dynamic>> getProfile() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return {
      'status': 200,
      'body': {'user': Map<String, dynamic>.from(_user)}
    };
  }
}
