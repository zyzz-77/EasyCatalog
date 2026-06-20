import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:easycatalog/models/order.dart';

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

  List<MerchantOrder> _allOrders = [];
  StreamSubscription? _ordersSub;
  int _newOrderCount = 0;

  final _changeController = StreamController<void>.broadcast();
  Stream<void> get onChange => _changeController.stream;

  void _listenOrders(String merchantId) {
    _ordersSub?.cancel();
    _ordersSub = _db
        .collection('merchants')
        .doc(merchantId)
        .collection('orders')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snap) {
      final prevActiveIds = _allOrders
          .where((o) => o.status != OrderStatus.selesai)
          .map((o) => o.id)
          .toSet();

      _allOrders =
          snap.docs.map((d) => MerchantOrder.fromFirestore(d)).toList();

      final newActiveIds = _allOrders
          .where((o) => o.status == OrderStatus.menunggu)
          .map((o) => o.id)
          .toSet();
      final freshlyAdded = newActiveIds.difference(prevActiveIds);
      if (freshlyAdded.isNotEmpty) _newOrderCount += freshlyAdded.length;

      _changeController.add(null);
    });
  }

  /// Pastikan data sudah termuat sebelum dashboard pertama kali build.
  Future<void> ensureLoaded() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    if (_ordersSub != null) return;
    final snap = await _db
        .collection('merchants')
        .doc(uid)
        .collection('orders')
        .orderBy('createdAt', descending: true)
        .get();
    _allOrders = snap.docs.map((d) => MerchantOrder.fromFirestore(d)).toList();
    _listenOrders(uid);
  }

  List<MerchantOrder> get activeOrders =>
      _allOrders.where((o) => o.status != OrderStatus.selesai).toList();

  int get newOrderCount => _newOrderCount;

  void clearBadge() {
    _newOrderCount = 0;
  }

  Future<void> confirmOrder(String orderId) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    await _db
        .collection('merchants')
        .doc(uid)
        .collection('orders')
        .doc(orderId)
        .update({'status': 'diproses'});
  }

  Future<void> markReady(String orderId) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    await _db
        .collection('merchants')
        .doc(uid)
        .collection('orders')
        .doc(orderId)
        .update({'status': 'ready'});
  }

  Future<void> markSelesai(String orderId) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    await _db
        .collection('merchants')
        .doc(uid)
        .collection('orders')
        .doc(orderId)
        .update({
      'status': 'selesai',
      'completedAt': FieldValue.serverTimestamp(),
    });
  }

  List<MerchantOrder> getHistory({String filter = 'semua'}) {
    final now = DateTime.now();
    return _allOrders.where((o) {
      if (o.status != OrderStatus.selesai || o.completedAt == null)
        return false;
      switch (filter) {
        case 'hari_ini':
          final start = DateTime(now.year, now.month, now.day);
          return o.completedAt!.isAfter(start);
        case 'minggu_ini':
          final start = now.subtract(const Duration(days: 7));
          return o.completedAt!.isAfter(start);
        case 'bulan_ini':
          final start = DateTime(now.year, now.month, 1);
          return o.completedAt!.isAfter(start);
        default:
          return true;
      }
    }).toList();
  }

  int getTotalOrders({String filter = 'semua'}) =>
      getHistory(filter: filter).length;

  int getTotalRevenue({String filter = 'semua'}) =>
      getHistory(filter: filter).fold(0, (sum, o) => sum + o.total);

  String getTopItem({String filter = 'semua'}) {
    final history = getHistory(filter: filter);
    if (history.isEmpty) return '-';
    final Map<String, int> qtyPerItem = {};
    for (final order in history) {
      for (final item in order.items) {
        qtyPerItem[item.name] = (qtyPerItem[item.name] ?? 0) + item.qty;
      }
    }
    if (qtyPerItem.isEmpty) return '-';
    return qtyPerItem.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
  }
}
