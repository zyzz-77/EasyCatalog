import 'package:cloud_firestore/cloud_firestore.dart';

// User model
class UserModel {
  final String id;
  String name;
  String email;
  String phone;

  UserModel(
      {required this.id,
      required this.name,
      required this.email,
      required this.phone});
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
enum OrderStatus { menunggu, diproses, ready, selesai }

// Order item
class OrderItem {
  final String name;
  final int price;
  final int qty;

  OrderItem({required this.name, required this.price, required this.qty});

  int get subtotal => price * qty;

  factory OrderItem.fromMap(Map<String, dynamic> m) => OrderItem(
        name: m['name'] ?? '',
        price: (m['price'] as num?)?.toInt() ?? 0,
        qty: (m['qty'] as num?)?.toInt() ?? 1,
      );

  Map<String, dynamic> toMap() => {'name': name, 'price': price, 'qty': qty};
}

// Order
class CustomerOrder {
  final String id;
  final String customerName;
  final String merchantId;
  final List<OrderItem> items;
  OrderStatus status;
  final DateTime createdAt;
  DateTime? completedAt;

  CustomerOrder({
    required this.id,
    required this.customerName,
    required this.merchantId,
    required this.items,
    required this.status,
    required this.createdAt,
    this.completedAt,
  });

  int get total => items.fold(0, (sum, item) => sum + item.subtotal);

  String get statusLabel {
    switch (status) {
      case OrderStatus.menunggu:
        return 'Menunggu Konfirmasi';
      case OrderStatus.diproses:
        return 'Diproses';
      case OrderStatus.ready:
        return 'Siap Diambil';
      case OrderStatus.selesai:
        return 'Selesai';
    }
  }

  String get statusDesc {
    switch (status) {
      case OrderStatus.menunggu:
        return 'Menunggu konfirmasi dari restoran...';
      case OrderStatus.diproses:
        return 'Diproses';
      case OrderStatus.ready:
        return 'Pesanan siap! Silakan ambil di restoran.';
      case OrderStatus.selesai:
        return 'Pesanan telah selesai.';
    }
  }

  factory CustomerOrder.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    OrderStatus parseStatus(String s) {
      switch (s) {
        case 'diproses':
          return OrderStatus.diproses;
        case 'ready':
          return OrderStatus.ready;
        case 'selesai':
          return OrderStatus.selesai;
        default:
          return OrderStatus.menunggu;
      }
    }

    return CustomerOrder(
      id: doc.id,
      customerName: d['customerName'] ?? '',
      merchantId: d['merchantId'] ?? '',
      items: (d['items'] as List<dynamic>? ?? [])
          .map((i) => OrderItem.fromMap(Map<String, dynamic>.from(i)))
          .toList(),
      status: parseStatus(d['status'] ?? 'menunggu'),
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      completedAt: (d['completedAt'] as Timestamp?)?.toDate(),
    );
  }
}
