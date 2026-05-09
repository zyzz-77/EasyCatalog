import 'package:flutter/material.dart';
import 'package:easyorder/utils/app_theme.dart';
import 'package:easyorder/utils/auth_service.dart';
import 'package:easyorder/utils/order_service.dart';
import 'package:easyorder/utils/data_service.dart';
import 'package:easyorder/screens/cart_screen.dart';


class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final _cart = CartService();
  final _auth = AuthService();
  final _data = DataService();

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
  }

  void _openCart() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CartScreen()),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final menu = _data.menu;
    final totalItems = _cart.totalItems;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 150,
            floating: false,
            pinned: true,
            backgroundColor: AppTheme.primary,
            automaticallyImplyLeading: false,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppTheme.primary, AppTheme.primaryLight],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(_data.restaurantName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                  )),
                            ),
                            // Cart button
                            Stack(
                              children: [
                                IconButton(
                                  onPressed: totalItems > 0 ? _openCart : null,
                                  icon: Icon(
                                    Icons.shopping_bag_rounded,
                                    color: totalItems > 0
                                        ? Colors.white
                                        : Colors.white38,
                                    size: 28,
                                  ),
                                ),
                                if (totalItems > 0)
                                  Positioned(
                                    right: 6,
                                    top: 6,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: AppTheme.accent,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Text(
                                        '$totalItems',
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Halo, ${_auth.currentUser?.name ?? 'Pelanggan'}! 👋',
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.85),
                              fontSize: 14),
                        ),
                        const Text('Mau makan apa hari ini?',
                            style: TextStyle(
                                color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Menu',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      )),
                  const SizedBox(height: 12),
                  ...menu.entries.map((entry) => _MenuItem(
                        name: entry.key,
                        price: entry.value,
                        qty: _cart.getQty(entry.key),
                        formatPrice: _formatPrice,
                        onAdd: () {
                          setState(() => _cart.addItem(entry.key, entry.value));
                        },
                        onRemove: () {
                          setState(() => _cart.removeItem(entry.key));
                        },
                      )),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      // Floating cart button
      floatingActionButton: totalItems > 0
          ? GestureDetector(
              onTap: _openCart,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.shopping_bag_rounded,
                        color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Text('$totalItems item',
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w600)),
                    const SizedBox(width: 12),
                    Container(
                      width: 1,
                      height: 16,
                      color: Colors.white38,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Rp ${_formatPrice(_cart.totalPrice)}',
                      style: const TextStyle(
                          color: AppTheme.accent, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward_rounded,
                        color: Colors.white, size: 18),
                  ],
                ),
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class _MenuItem extends StatelessWidget {
  final String name;
  final int price;
  final int qty;
  final String Function(int) formatPrice;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const _MenuItem({
    required this.name,
    required this.price,
    required this.qty,
    required this.formatPrice,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: qty > 0
              ? AppTheme.primaryLight.withOpacity(0.4)
              : AppTheme.divider,
          width: qty > 0 ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.fastfood_rounded,
                color: AppTheme.primary, size: 26),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                        fontSize: 14)),
                const SizedBox(height: 4),
                Text('Rp ${formatPrice(price)}',
                    style: const TextStyle(
                        color: AppTheme.primaryLight,
                        fontWeight: FontWeight.w700,
                        fontSize: 14)),
              ],
            ),
          ),
          if (qty == 0)
            GestureDetector(
              onTap: onAdd,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
              ),
            )
          else
            Row(
              children: [
                GestureDetector(
                  onTap: onRemove,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppTheme.primary),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.remove_rounded,
                        color: AppTheme.primary, size: 18),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text('$qty',
                      style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: AppTheme.textPrimary)),
                ),
                GestureDetector(
                  onTap: onAdd,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.add_rounded,
                        color: Colors.white, size: 18),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
