import 'package:flutter/material.dart';
import 'package:easycatalog/models/order.dart';
import 'package:easycatalog/utils/order_service.dart';
import 'package:easycatalog/utils/app_theme.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _orderService = OrderService();
  String _filter = 'semua';

  final _filterOptions = [
    {'key': 'semua', 'label': 'Semua'},
    {'key': 'hari_ini', 'label': 'Hari Ini'},
    {'key': 'minggu_ini', 'label': 'Minggu Ini'},
    {'key': 'bulan_ini', 'label': 'Bulan Ini'},
  ];

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
  }

  String _formatTime(DateTime? dt) {
    if (dt == null) return '-';
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final history = _orderService.getHistory(filter: _filter);
    final totalOrders = _orderService.getTotalOrders(filter: _filter);
    final totalRevenue = _orderService.getTotalRevenue(filter: _filter);
    final topItem = _orderService.getTopItem(filter: _filter);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('History Pesanan'),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _filterOptions.map((opt) {
                final isSelected = _filter == opt['key'];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(opt['label']!),
                    selected: isSelected,
                    onSelected: (_) => setState(() => _filter = opt['key']!),
                    selectedColor: AppTheme.primary.withOpacity(0.15),
                    checkmarkColor: AppTheme.primary,
                    labelStyle: TextStyle(
                      color: isSelected ? AppTheme.primary : AppTheme.textSecondary,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                    side: BorderSide(
                      color: isSelected ? AppTheme.primary : AppTheme.divider,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),

          // Summary cards
          Row(
            children: [
              Expanded(
                child: _SummaryCard(
                  icon: Icons.receipt_long_rounded,
                  label: 'Total Order',
                  value: '$totalOrders',
                  color: AppTheme.primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SummaryCard(
                  icon: Icons.payments_rounded,
                  label: 'Pendapatan',
                  value: 'Rp ${_formatPrice(totalRevenue)}',
                  color: AppTheme.accent,
                  smallText: true,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SummaryCard(
                  icon: Icons.star_rounded,
                  label: 'Terlaris',
                  value: topItem,
                  color: Colors.amber[700]!,
                  smallText: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // History list
          if (history.isEmpty)
            Container(
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.divider),
              ),
              child: Column(
                children: [
                  Icon(Icons.history_rounded, size: 48, color: Colors.grey[300]),
                  const SizedBox(height: 12),
                  const Text('Belum ada history',
                      style: TextStyle(color: AppTheme.textSecondary)),
                ],
              ),
            )
          else
            ...history.map((order) => _HistoryCard(
                  order: order,
                  formatPrice: _formatPrice,
                  formatTime: _formatTime,
                )),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool smallText;

  const _SummaryCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.smallText = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: smallText ? 12 : 18,
              color: AppTheme.textPrimary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(
                  color: AppTheme.textSecondary, fontSize: 11)),
        ],
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final Order order;
  final String Function(int) formatPrice;
  final String Function(DateTime?) formatTime;

  const _HistoryCard({
    required this.order,
    required this.formatPrice,
    required this.formatTime,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.check_circle_rounded,
                    color: AppTheme.primary, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(order.customerName,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary)),
                    Text('${order.id} · ${formatTime(order.completedAt)}',
                        style: const TextStyle(
                            color: AppTheme.textSecondary, fontSize: 11)),
                  ],
                ),
              ),
              Text('Rp ${formatPrice(order.total)}',
                  style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppTheme.accent,
                      fontSize: 14)),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(height: 1),
          const SizedBox(height: 8),
          ...order.items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Row(
                  children: [
                    const Icon(Icons.circle,
                        size: 5, color: AppTheme.textSecondary),
                    const SizedBox(width: 6),
                    Expanded(
                        child: Text('${item.name} x${item.qty}',
                            style: const TextStyle(
                                fontSize: 12, color: AppTheme.textSecondary))),
                    Text('Rp ${formatPrice(item.subtotal)}',
                        style: const TextStyle(
                            fontSize: 12, color: AppTheme.textSecondary)),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
