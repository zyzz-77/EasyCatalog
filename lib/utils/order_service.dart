import 'package:easycatalog/models/order.dart';

class OrderService {
  static final OrderService _instance = OrderService._internal();
  factory OrderService() => _instance;
  OrderService._internal();

  final List<Order> _activeOrders = [];
  final List<Order> _historyOrders = [];

  // Dummy customer names
  static const _customers = [
    'Budi Santoso', 'Siti Rahayu', 'Ahmad Fauzi', 'Dewi Lestari',
    'Rizky Pratama', 'Nurul Hidayah', 'Eko Wahyudi', 'Fitri Handayani',
    'Doni Setiawan', 'Rina Kusuma',
  ];

  // Counter for unique IDs
  int _orderCounter = 1;

  List<Order> get activeOrders => List.unmodifiable(_activeOrders);
  List<Order> get historyOrders => List.unmodifiable(_historyOrders);

  // New order badge count
  int _newOrderCount = 0;
  int get newOrderCount => _newOrderCount;
  void clearBadge() => _newOrderCount = 0;

  // Simulate new order coming in
  void simulateNewOrder(Map<String, dynamic> menu) {
    final menuEntries = (menu as Map<String, dynamic>).entries.toList();
    if (menuEntries.isEmpty) return;

    // Pick 1-3 random items
    menuEntries.shuffle();
    final itemCount = (menuEntries.length < 3 ? menuEntries.length : 3);
    final selectedItems = menuEntries.take(itemCount).toList();

    final items = selectedItems.map((e) {
      final price = e.value is int ? e.value as int : (e.value as num).toInt();
      return OrderItem(name: e.key, price: price, qty: 1);
    }).toList();

    _customers.shuffle();
    final order = Order(
      id: 'ORD-${_orderCounter.toString().padLeft(3, '0')}',
      customerName: _customers.first,
      items: items,
      status: OrderStatus.diproses,
      createdAt: DateTime.now(),
    );
    _orderCounter++;
    _activeOrders.insert(0, order);
    _newOrderCount++;
  }

  // Move to ready
  void markReady(String orderId) {
    final order = _activeOrders.firstWhere((o) => o.id == orderId);
    order.status = OrderStatus.ready;
  }

  // Move to selesai → history
  void markSelesai(String orderId) {
    final idx = _activeOrders.indexWhere((o) => o.id == orderId);
    if (idx == -1) return;
    final order = _activeOrders[idx];
    order.status = OrderStatus.selesai;
    order.completedAt = DateTime.now();
    _activeOrders.removeAt(idx);
    _historyOrders.insert(0, order);
  }

  // History filtered
  List<Order> getHistory({String filter = 'semua'}) {
    final now = DateTime.now();
    return _historyOrders.where((o) {
      switch (filter) {
        case 'hari_ini':
          return o.completedAt != null &&
              o.completedAt!.year == now.year &&
              o.completedAt!.month == now.month &&
              o.completedAt!.day == now.day;
        case 'minggu_ini':
          final weekAgo = now.subtract(const Duration(days: 7));
          return o.completedAt != null && o.completedAt!.isAfter(weekAgo);
        case 'bulan_ini':
          return o.completedAt != null &&
              o.completedAt!.year == now.year &&
              o.completedAt!.month == now.month;
        default:
          return true;
      }
    }).toList();
  }

  // Stats
  int getTotalOrders({String filter = 'semua'}) => getHistory(filter: filter).length;

  int getTotalRevenue({String filter = 'semua'}) =>
      getHistory(filter: filter).fold(0, (sum, o) => sum + o.total);

  String getTopItem({String filter = 'semua'}) {
    final orders = getHistory(filter: filter);
    final Map<String, int> counts = {};
    for (final o in orders) {
      for (final item in o.items) {
        counts[item.name] = (counts[item.name] ?? 0) + item.qty;
      }
    }
    if (counts.isEmpty) return '-';
    return counts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  // Today's summary for beranda
  int get todayOrderCount {
    final now = DateTime.now();
    return _historyOrders.where((o) =>
      o.completedAt != null &&
      o.completedAt!.year == now.year &&
      o.completedAt!.month == now.month &&
      o.completedAt!.day == now.day
    ).length;
  }

  int get todayRevenue {
    final now = DateTime.now();
    return _historyOrders
      .where((o) =>
        o.completedAt != null &&
        o.completedAt!.year == now.year &&
        o.completedAt!.month == now.month &&
        o.completedAt!.day == now.day)
      .fold(0, (sum, o) => sum + o.total);
  }
}
