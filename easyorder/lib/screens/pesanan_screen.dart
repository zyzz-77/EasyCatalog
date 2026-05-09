import 'package:flutter/material.dart';
import 'package:easyorder/utils/app_theme.dart';
import 'package:easyorder/utils/order_service.dart';
import 'package:easyorder/models/models.dart';
import 'package:easyorder/screens/order_status_screen.dart';

class PesananScreen extends StatefulWidget {
  const PesananScreen({super.key});

  @override
  State<PesananScreen> createState() => _PesananScreenState();
}

class _PesananScreenState extends State<PesananScreen> {
  final _orderService = OrderService();

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
  }

  Color _statusColor(OrderStatus s) {
    switch (s) {
      case OrderStatus.diproses: return Colors.orange;
      case OrderStatus.ready: return Colors.blue;
      case OrderStatus.selesai: return Colors.green;
    }
  }

  IconData _statusIcon(OrderStatus s) {
    switch (s) {
      case OrderStatus.diproses: return Icons.soup_kitchen_rounded;
      case OrderStatus.ready: return Icons.notifications_active_rounded;
      case OrderStatus.selesai: return Icons.check_circle_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final active = _orderService.activeOrders;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Pesanan Saya'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: () => setState(() {}),
          ),
        ],
      ),
      body: active.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long_outlined,
                      size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  const Text('Belum ada pesanan aktif',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary)),
                  const SizedBox(height: 8),
                  const Text('Pesan makanan dari tab Menu',
                      style:
                          TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text('${active.length} pesanan aktif',
                    style: const TextStyle(
                        color: AppTheme.textSecondary, fontSize: 13)),
                const SizedBox(height: 12),
                ...active.map((order) => GestureDetector(
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  OrderStatusScreen(order: order)),
                        );
                        setState(() {});
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _statusColor(order.status).withOpacity(0.3),
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: _statusColor(order.status)
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(_statusIcon(order.status),
                                      color: _statusColor(order.status),
                                      size: 20),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(order.id,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w700,
                                              color: AppTheme.textPrimary)),
                                      Text(
                                          '${order.items.length} item · Rp ${_formatPrice(order.total)}',
                                          style: const TextStyle(
                                              color: AppTheme.textSecondary,
                                              fontSize: 12)),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _statusColor(order.status)
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(order.statusLabel,
                                      style: TextStyle(
                                          color: _statusColor(order.status),
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600)),
                                ),
                              ],
                            ),
                            if (order.status == OrderStatus.ready) ...[
                              const SizedBox(height: 10),
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(Icons.notifications_active_rounded,
                                        color: Colors.blue, size: 16),
                                    SizedBox(width: 8),
                                    Text('Pesanan siap! Silakan ambil di restoran',
                                        style: TextStyle(
                                            color: Colors.blue,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500)),
                                  ],
                                ),
                              ),
                            ],
                            const SizedBox(height: 8),
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text('Lihat detail',
                                    style: TextStyle(
                                        color: AppTheme.primaryLight,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600)),
                                SizedBox(width: 4),
                                Icon(Icons.arrow_forward_rounded,
                                    color: AppTheme.primaryLight, size: 14),
                              ],
                            ),
                          ],
                        ),
                      ),
                    )),
              ],
            ),
    );
  }
}
