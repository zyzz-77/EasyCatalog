enum OrderStatus { diproses, ready, selesai }

class OrderItem {
  final String name;
  final int price;
  final int qty;

  OrderItem({required this.name, required this.price, required this.qty});

  int get subtotal => price * qty;
}

class Order {
  final String id;
  final String customerName;
  final List<OrderItem> items;
  OrderStatus status;
  final DateTime createdAt;
  DateTime? completedAt;

  Order({
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
      case OrderStatus.ready: return 'Ready';
      case OrderStatus.selesai: return 'Selesai';
    }
  }
}
