// User model
class UserModel {
  final String id;
  String name;
  String email;
  String phone;

  UserModel({required this.id, required this.name, required this.email, required this.phone});
}

// Cart item
class CartItem {
  final String name;
  final int price;
  int qty;

  CartItem({required this.name, required this.price, this.qty = 1});

  int get subtotal => price * qty;
}

// Order status
enum OrderStatus { diproses, ready, selesai }

// Order item
class OrderItem {
  final String name;
  final int price;
  final int qty;

  OrderItem({required this.name, required this.price, required this.qty});

  int get subtotal => price * qty;
}

// Order
class CustomerOrder {
  final String id;
  final String customerName;
  final List<OrderItem> items;
  OrderStatus status;
  final DateTime createdAt;
  DateTime? completedAt;

  CustomerOrder({
    required this.id,
    required this.customerName,
    required this.items,
    required this.status,
    required this.createdAt,
    this.completedAt,
  });

  int get total => items.fold(0, (sum, item) => sum + item.subtotal);

  String get statusLabel {
    switch (status) {
      case OrderStatus.diproses: return 'Diproses';
      case OrderStatus.ready: return 'Siap Diambil';
      case OrderStatus.selesai: return 'Selesai';
    }
  }

  String get statusDesc {
    switch (status) {
      case OrderStatus.diproses: return 'Pesanan sedang disiapkan...';
      case OrderStatus.ready: return 'Pesanan siap! Silakan ambil di restoran.';
      case OrderStatus.selesai: return 'Pesanan telah selesai.';
    }
  }
}
