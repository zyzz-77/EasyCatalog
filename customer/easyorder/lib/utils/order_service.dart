import 'package:easyorder/models/models.dart';

// Cart
class CartService {
  static final CartService _instance = CartService._internal();
  factory CartService() => _instance;
  CartService._internal();

  final List<CartItem> _items = [];
  List<CartItem> get items => List.unmodifiable(_items);
  int get totalItems => _items.fold(0, (sum, i) => sum + i.qty);
  int get totalPrice => _items.fold(0, (sum, i) => sum + i.subtotal);

  void addItem(String name, int price) {
    final idx = _items.indexWhere((i) => i.name == name);
    if (idx >= 0) {
      _items[idx].qty++;
    } else {
      _items.add(CartItem(name: name, price: price));
    }
  }

  void removeItem(String name) {
    final idx = _items.indexWhere((i) => i.name == name);
    if (idx < 0) return;
    if (_items[idx].qty > 1) {
      _items[idx].qty--;
    } else {
      _items.removeAt(idx);
    }
  }

  void deleteItem(String name) => _items.removeWhere((i) => i.name == name);

  int getQty(String name) {
    final idx = _items.indexWhere((i) => i.name == name);
    return idx >= 0 ? _items[idx].qty : 0;
  }

  void clear() => _items.clear();
}

// Order
class OrderService {
  static final OrderService _instance = OrderService._internal();
  factory OrderService() => _instance;
  OrderService._internal();

  final List<CustomerOrder> _activeOrders = [];
  final List<CustomerOrder> _historyOrders = [];
  int _orderCounter = 1;

  List<CustomerOrder> get activeOrders => List.unmodifiable(_activeOrders);
  List<CustomerOrder> get historyOrders => List.unmodifiable(_historyOrders);

  CustomerOrder placeOrder(String customerName, List<CartItem> cartItems) {
    final items = cartItems
        .map((c) => OrderItem(name: c.name, price: c.price, qty: c.qty))
        .toList();
    final order = CustomerOrder(
      id: 'ORD-${_orderCounter.toString().padLeft(3, '0')}',
      customerName: customerName,
      items: items,
      status: OrderStatus.diproses,
      createdAt: DateTime.now(),
    );
    _orderCounter++;
    _activeOrders.insert(0, order);
    return order;
  }

  // Simulate merchant updating status (for demo)
  void simulateReady(String orderId) {
    final idx = _activeOrders.indexWhere((o) => o.id == orderId);
    if (idx >= 0) _activeOrders[idx].status = OrderStatus.ready;
  }

  void simulateSelesai(String orderId) {
    final idx = _activeOrders.indexWhere((o) => o.id == orderId);
    if (idx < 0) return;
    final order = _activeOrders[idx];
    order.status = OrderStatus.selesai;
    order.completedAt = DateTime.now();
    _activeOrders.removeAt(idx);
    _historyOrders.insert(0, order);
  }
}
