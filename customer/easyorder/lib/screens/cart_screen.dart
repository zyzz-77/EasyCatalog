import 'package:flutter/material.dart';
import 'package:easyorder/utils/app_theme.dart';
import 'package:easyorder/utils/auth_service.dart';
import 'package:easyorder/utils/order_service.dart';
import 'package:easyorder/screens/order_status_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final _cart = CartService();
  final _orderService = OrderService();
  final _auth = AuthService();
  bool _loading = false;

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
  }

  void _placeOrder() async {
    if (_cart.items.isEmpty) return;
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 800));
    final order = _orderService.placeOrder(
      _auth.currentUser?.name ?? 'Pelanggan',
      _cart.items.toList(),
    );
    _cart.clear();
    if (mounted) {
      setState(() => _loading = false);
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => OrderStatusScreen(order: order)),
        (route) => route.isFirst,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = _cart.items;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Keranjang'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: items.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_bag_outlined,
                      size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Keranjang kosong',
                      style: TextStyle(
                          color: AppTheme.textSecondary, fontSize: 16)),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // Customer info
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppTheme.primary, AppTheme.primaryLight],
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.person_rounded,
                                color: Colors.white, size: 20),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Atas nama',
                                    style: TextStyle(
                                        color: Colors.white70, fontSize: 12)),
                                Text(
                                  _auth.currentUser?.name ?? 'Pelanggan',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      const Text('Pesanan Anda',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          )),
                      const SizedBox(height: 10),

                      // Items
                      ...items.map((item) => Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppTheme.divider),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color:
                                        AppTheme.primary.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.fastfood_rounded,
                                      color: AppTheme.primary, size: 18),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(item.name,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              color: AppTheme.textPrimary)),
                                      Text(
                                          'Rp ${_formatPrice(item.price)} × ${item.qty}',
                                          style: const TextStyle(
                                              color: AppTheme.textSecondary,
                                              fontSize: 12)),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () => setState(
                                          () => _cart.removeItem(item.name)),
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color: AppTheme.primary),
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: const Icon(
                                            Icons.remove_rounded,
                                            color: AppTheme.primary,
                                            size: 16),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8),
                                      child: Text('${item.qty}',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 15)),
                                    ),
                                    GestureDetector(
                                      onTap: () => setState(() =>
                                          _cart.addItem(item.name, item.price)),
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: AppTheme.primary,
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: const Icon(Icons.add_rounded,
                                            color: Colors.white, size: 16),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          )),

                      const SizedBox(height: 12),

                      // Total
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppTheme.divider),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Subtotal',
                                    style: TextStyle(
                                        color: AppTheme.textSecondary)),
                                Text('Rp ${_formatPrice(_cart.totalPrice)}',
                                    style: const TextStyle(
                                        color: AppTheme.textPrimary)),
                              ],
                            ),
                            const Divider(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Total',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16,
                                        color: AppTheme.textPrimary)),
                                Text(
                                  'Rp ${_formatPrice(_cart.totalPrice)}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 18,
                                      color: AppTheme.primary),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Checkout button
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                  color: Colors.white,
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _placeOrder,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accent,
                        foregroundColor: Colors.black,
                      ),
                      child: _loading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.black54))
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.check_circle_rounded, size: 20),
                                SizedBox(width: 8),
                                Text('Pesan Sekarang',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700)),
                              ],
                            ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
