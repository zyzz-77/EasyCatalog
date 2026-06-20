import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:easyorder/models/models.dart';
import 'package:easyorder/utils/data_service.dart';

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

class OrderService {
  static final OrderService _instance = OrderService._internal();
  factory OrderService() => _instance;
  OrderService._internal() {
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user == null) {
        _ordersSub?.cancel();
        _allOrders = [];
      } else {
        _listenOrders(user.uid);
      }
    });
  }

  final _db = FirebaseFirestore.instance;

  List<CustomerOrder> _allOrders = [];
  StreamSubscription? _ordersSub;

  final _changeController = StreamController<void>.broadcast();
  Stream<void> get onChange => _changeController.stream;

  void _listenOrders(String customerId) {
    print('LISTENING ORDERS FOR: $customerId');
    _ordersSub?.cancel();
    _ordersSub = _db
        .collectionGroup('orders')
        .where('customerId', isEqualTo: customerId)
        .snapshots()
        .listen((snap) {
      print('SNAPSHOT RECEIVED: ${snap.docs.length} docs');
      _allOrders = snap.docs.map((d) => CustomerOrder.fromFirestore(d)).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      _changeController.add(null);
    }, onError: (e) {
      print('ORDER STREAM ERROR: $e');
    });
  }

  Future<void> ensureLoaded() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    if (_ordersSub != null) return;
    _listenOrders(uid);
  }

  List<CustomerOrder> get activeOrders =>
      _allOrders.where((o) => o.status != OrderStatus.selesai).toList();

  List<CustomerOrder> get historyOrders =>
      _allOrders.where((o) => o.status == OrderStatus.selesai).toList();

  Future<CustomerOrder> placeOrder(
      String customerName, List<CartItem> cartItems) async {
    final merchantId = DataService().merchantId;
    if (merchantId == null) throw Exception('merchantId tidak ada');
    final customerId = FirebaseAuth.instance.currentUser?.uid ?? '';

    final items = cartItems.map((c) => c.toOrderItem().toMap()).toList();
    final total = cartItems.fold(0, (sum, c) => sum + c.subtotal);

    final ref = await _db
        .collection('merchants')
        .doc(merchantId)
        .collection('orders')
        .add({
      'customerId': customerId,
      'customerName': customerName,
      'merchantId': merchantId,
      'items': items,
      'total': total,
      'status': 'menunggu',
      'createdAt': FieldValue.serverTimestamp(),
      'completedAt': null,
    });

    return CustomerOrder(
      id: ref.id,
      customerName: customerName,
      merchantId: merchantId,
      items: cartItems.map((c) => c.toOrderItem()).toList(),
      status: OrderStatus.menunggu,
      createdAt: DateTime.now(),
    );
  }
}

extension on CartItem {
  OrderItem toOrderItem() => OrderItem(name: name, price: price, qty: qty);
}
