import 'package:easycatalog/models/order.dart';

class OrderService {
  static final OrderService _instance = OrderService._internal();
  factory OrderService() => _instance;
  OrderService._internal();

  final List<Order> _activeOrders = [];
  final List<Order> _historyOrders = [];

  // Counter for unique IDs
  int _orderCounter = 1;

  List<Order> get activeOrders => List.unmodifiable(_activeOrders);
  List<Order> get historyOrders => List.unmodifiable(_historyOrders);

  // New order badge count
  int _newOrderCount = 0;
  int get newOrderCount => _newOrderCount;
  void clearBadge() => _newOrderCount = 0;

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
  int getTotalOrders({String filter = 'semua'}) =>
      getHistory(filter: filter).length;

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
    return _historyOrders
        .where((o) =>
            o.completedAt != null &&
            o.completedAt!.year == now.year &&
            o.completedAt!.month == now.month &&
            o.completedAt!.day == now.day)
        .length;
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
