import 'dart:async';
import 'package:flutter/material.dart';
import 'package:easyorder/utils/app_theme.dart';
import 'package:easyorder/utils/order_service.dart';
import 'package:easyorder/models/models.dart';

class OrderStatusScreen extends StatefulWidget {
  final CustomerOrder order;

  const OrderStatusScreen({super.key, required this.order});

  @override
  State<OrderStatusScreen> createState() => _OrderStatusScreenState();
}

class _OrderStatusScreenState extends State<OrderStatusScreen> {
  final _orderService = OrderService();
  StreamSubscription? _sub;
  late CustomerOrder _order;

  @override
  void initState() {
    super.initState();
    _order = widget.order;
    _sub = _orderService.onChange.listen((_) {
      final updated = _orderService.activeOrders
          .followedBy(_orderService.historyOrders)
          .where((o) => o.id == _order.id);
      if (updated.isNotEmpty && mounted) {
        setState(() => _order = updated.first);
      }
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]}.',
        );
  }

  Color get _statusColor {
    switch (_order.status) {
      case OrderStatus.menunggu:
        return Colors.grey;
      case OrderStatus.diproses:
        return Colors.orange;
      case OrderStatus.ready:
        return Colors.blue;
      case OrderStatus.selesai:
        return Colors.green;
    }
  }

  IconData get _statusIcon {
    switch (_order.status) {
      case OrderStatus.menunggu:
        return Icons.hourglass_empty_rounded;
      case OrderStatus.diproses:
        return Icons.soup_kitchen_rounded;
      case OrderStatus.ready:
        return Icons.notifications_active_rounded;
      case OrderStatus.selesai:
        return Icons.check_circle_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text('Status Pesanan ${_order.customerName}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Status card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _statusColor.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: _statusColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(_statusIcon, color: _statusColor, size: 48),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _order.statusLabel,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: _statusColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _order.statusDesc,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Progress steps
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.divider),
              ),
              child: Column(
                children: [
                  _StepItem(
                    label: 'Menunggu Konfirmasi',
                    desc: 'Menunggu restoran menerima pesanan',
                    done: _order.status != OrderStatus.menunggu,
                    isActive: _order.status == OrderStatus.menunggu,
                    icon: Icons.hourglass_empty_rounded,
                  ),
                  _StepDivider(
                    active: _order.status != OrderStatus.menunggu,
                  ),
                  _StepItem(
                    label: 'Pesanan diterima',
                    desc: 'Pesanan Anda masuk ke restoran',
                    done: _order.status != OrderStatus.menunggu,
                    isActive: false,
                    icon: Icons.receipt_rounded,
                  ),
                  _StepDivider(
                    active: _order.status == OrderStatus.diproses ||
                        _order.status == OrderStatus.ready ||
                        _order.status == OrderStatus.selesai,
                  ),
                  _StepItem(
                    label: 'Diproses',
                    desc: 'Restoran sedang menyiapkan pesanan',
                    done: _order.status == OrderStatus.ready ||
                        _order.status == OrderStatus.selesai,
                    isActive: _order.status == OrderStatus.diproses,
                    icon: Icons.soup_kitchen_rounded,
                  ),
                  _StepDivider(
                    active: _order.status == OrderStatus.ready ||
                        _order.status == OrderStatus.selesai,
                  ),
                  _StepItem(
                    label: 'Siap diambil',
                    desc: 'Pesanan siap! Silakan ambil di restoran',
                    done: _order.status == OrderStatus.ready ||
                        _order.status == OrderStatus.selesai,
                    isActive: _order.status == OrderStatus.ready,
                    icon: Icons.notifications_active_rounded,
                  ),
                  _StepDivider(
                    active: _order.status == OrderStatus.selesai,
                  ),
                  _StepItem(
                    label: 'Selesai',
                    desc: 'Pesanan telah diambil',
                    done: _order.status == OrderStatus.selesai,
                    isActive: _order.status == OrderStatus.selesai,
                    icon: Icons.check_circle_rounded,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Order detail
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.divider),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Detail Pesanan',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                  ..._order.items.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.circle,
                            size: 5,
                            color: AppTheme.textSecondary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${item.name} ×${item.qty}',
                              style: const TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          Text(
                            'Rp ${_formatPrice(item.subtotal)}',
                            style: const TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Divider(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      Text(
                        'Rp ${_formatPrice(_order.total)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primary,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _StepItem extends StatelessWidget {
  final String label;
  final String desc;
  final bool done;
  final bool isActive;
  final IconData icon;

  const _StepItem({
    required this.label,
    required this.desc,
    required this.done,
    required this.isActive,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final highlighted = done || isActive;
    final color = highlighted ? AppTheme.primary : Colors.grey.shade300;
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: highlighted
                ? AppTheme.primary.withOpacity(0.1)
                : Colors.grey.shade100,
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: highlighted
                      ? AppTheme.textPrimary
                      : AppTheme.textSecondary,
                  fontSize: 13,
                ),
              ),
              Text(
                desc,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
        if (done)
          const Icon(
            Icons.check_circle_rounded,
            color: AppTheme.primary,
            size: 18,
          )
        else if (isActive)
          Icon(
            Icons.radio_button_checked_rounded,
            color: AppTheme.primary,
            size: 18,
          ),
      ],
    );
  }
}

class _StepDivider extends StatelessWidget {
  final bool active;
  const _StepDivider({required this.active});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 17, top: 2, bottom: 2),
      child: Container(
        width: 2,
        height: 20,
        color:
            active ? AppTheme.primary.withOpacity(0.3) : Colors.grey.shade200,
      ),
    );
  }
}
