import 'package:flutter/material.dart';
import 'package:easycatalog/models/order.dart';
import 'package:easycatalog/utils/order_service.dart';
import 'package:easycatalog/utils/app_theme.dart';

class BerandaScreen extends StatefulWidget {
  final Map<String, dynamic>? restaurant;
  final Map<String, dynamic>? user;
  final VoidCallback onRefresh;
  final VoidCallback onOrderChanged;

  const BerandaScreen({
    super.key,
    required this.restaurant,
    required this.user,
    required this.onRefresh,
    required this.onOrderChanged,
  });

  @override
  State<BerandaScreen> createState() => _BerandaScreenState();
}

class _BerandaScreenState extends State<BerandaScreen> {
  final _orderService = OrderService();

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
  }

  void _markReady(Order order) {
    setState(() => _orderService.markReady(order.id));
    widget.onOrderChanged();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('✅ Notif dikirim ke ${order.customerName}'),
      backgroundColor: Colors.blue,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  void _markSelesai(Order order) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Selesaikan Order?',
            style: TextStyle(fontWeight: FontWeight.w700)),
        content:
            Text('Order ${order.id} dari ${order.customerName} sudah diambil?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _orderService.markSelesai(order.id));
              widget.onOrderChanged();
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: const Text('🎉 Order selesai & masuk history!'),
                backgroundColor: AppTheme.primary,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ));
            },
            child: const Text('Selesai'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeOrders = _orderService.activeOrders;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: RefreshIndicator(
        onRefresh: () async => widget.onRefresh(),
        color: AppTheme.primary,
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar(
              expandedHeight: 140,
              floating: false,
              pinned: true,
              backgroundColor: AppTheme.primary,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppTheme.primary, AppTheme.primaryDark],
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
                              const Text('EasyCatalog',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                  )),
                              IconButton(
                                icon: const Icon(Icons.refresh_rounded,
                                    color: Colors.white),
                                onPressed: widget.onRefresh,
                              ),
                            ],
                          ),
                          Text(
                            'Halo, ${widget.user?['name'] ?? 'Merchant'}! 👋',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w500),
                          ),
                          Text(
                            widget.user?['email'] ?? '',
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.75),
                                fontSize: 12),
                          ),
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
                    // Restaurant card
                    if (widget.restaurant != null)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppTheme.accent, AppTheme.accentLight],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.store_rounded,
                                  color: Colors.white, size: 24),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.restaurant!['name'] ?? '-',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      const Icon(Icons.location_on_outlined,
                                          color: Colors.white70, size: 13),
                                      const SizedBox(width: 2),
                                      Expanded(
                                        child: Text(
                                          widget.restaurant!['location'] ?? '-',
                                          style: const TextStyle(
                                              color: Colors.white70,
                                              fontSize: 12),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Text('Pesanan Aktif',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textPrimary,
                                )),
                            if (activeOrders.isNotEmpty) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppTheme.accent,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '${activeOrders.length}',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Order list
                    if (activeOrders.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppTheme.divider),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.receipt_long_outlined,
                                size: 48, color: Colors.grey[300]),
                            const SizedBox(height: 12),
                            const Text('Belum ada pesanan aktif',
                                style: TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: 14)),
                          ],
                        ),
                      )
                    else
                      ...activeOrders.map((order) => _OrderCard(
                            order: order,
                            onMarkReady: () => _markReady(order),
                            onMarkSelesai: () => _markSelesai(order),
                            formatPrice: _formatPrice,
                          )),

                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Order order;
  final VoidCallback onMarkReady;
  final VoidCallback onMarkSelesai;
  final String Function(int) formatPrice;

  const _OrderCard({
    required this.order,
    required this.onMarkReady,
    required this.onMarkSelesai,
    required this.formatPrice,
  });

  Color get _statusColor {
    switch (order.status) {
      case OrderStatus.diproses:
        return Colors.orange;
      case OrderStatus.ready:
        return Colors.blue;
      case OrderStatus.selesai:
        return AppTheme.primary;
    }
  }

  IconData get _statusIcon {
    switch (order.status) {
      case OrderStatus.diproses:
        return Icons.soup_kitchen_rounded;
      case OrderStatus.ready:
        return Icons.done_all_rounded;
      case OrderStatus.selesai:
        return Icons.check_circle_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(_statusIcon, color: _statusColor, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(order.customerName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: AppTheme.textPrimary,
                          )),
                      Text(order.id,
                          style: const TextStyle(
                              color: AppTheme.textSecondary, fontSize: 12)),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(order.statusLabel,
                      style: TextStyle(
                          color: _statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600)),
                ),
              ],
            ),

            const SizedBox(height: 10),
            const Divider(height: 1),
            const SizedBox(height: 10),

            // Items
            ...order.items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.circle,
                          size: 6, color: AppTheme.textSecondary),
                      const SizedBox(width: 8),
                      Expanded(
                          child: Text('${item.name} x${item.qty}',
                              style: const TextStyle(
                                  fontSize: 13, color: AppTheme.textPrimary))),
                      Text('Rp ${formatPrice(item.subtotal)}',
                          style: const TextStyle(
                              fontSize: 13, color: AppTheme.textSecondary)),
                    ],
                  ),
                )),

            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total',
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary)),
                Text('Rp ${formatPrice(order.total)}',
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppTheme.accent,
                        fontSize: 15)),
              ],
            ),

            const SizedBox(height: 12),

            // Action buttons
            Row(
              children: [
                if (order.status == OrderStatus.diproses)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onMarkReady,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      icon: const Icon(Icons.notifications_rounded, size: 16),
                      label: const Text('Tandai Ready'),
                    ),
                  ),
                if (order.status == OrderStatus.ready) ...[
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onMarkReady,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.blue,
                        side: const BorderSide(color: Colors.blue),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      icon: const Icon(Icons.notifications_active_rounded,
                          size: 16),
                      label: const Text('Kirim Ulang'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onMarkSelesai,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      icon: const Icon(Icons.check_circle_rounded, size: 16),
                      label: const Text('Selesai'),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
