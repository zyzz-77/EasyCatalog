import 'package:cloud_firestore/cloud_firestore.dart';

enum OrderStatus { menunggu, diproses, ready, selesai }

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

/// Dinamai MerchantOrder (bukan "Order") agar tidak bertabrakan
/// dengan class Order bawaan package cloud_firestore.
class MerchantOrder {
  final String id;
  final String customerName;
  final List<OrderItem> items;
  OrderStatus status;
  final DateTime createdAt;
  DateTime? completedAt;

  MerchantOrder({
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
      case OrderStatus.menunggu:
        return 'Menunggu Konfirmasi';
      case OrderStatus.diproses:
        return 'Diproses';
      case OrderStatus.ready:
        return 'Ready';
      case OrderStatus.selesai:
        return 'Selesai';
    }
  }

  factory MerchantOrder.fromFirestore(DocumentSnapshot doc) {
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

    final rawItems = (d['items'] as List<dynamic>? ?? []);
    return MerchantOrder(
      id: doc.id,
      customerName: d['customerName'] ?? '',
      items: rawItems
          .map((i) => OrderItem.fromMap(Map<String, dynamic>.from(i)))
          .toList(),
      status: parseStatus(d['status'] ?? 'menunggu'),
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      completedAt: (d['completedAt'] as Timestamp?)?.toDate(),
    );
  }
}