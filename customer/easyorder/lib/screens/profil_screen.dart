import 'package:flutter/material.dart';
import 'package:easyorder/utils/app_theme.dart';
import 'package:easyorder/utils/auth_service.dart';
import 'package:easyorder/utils/order_service.dart';
import 'package:easyorder/models/models.dart';
import 'package:easyorder/screens/login_screen.dart';

class ProfilScreen extends StatefulWidget {
  const ProfilScreen({super.key});

  @override
  State<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> {
  final _auth = AuthService();
  final _orderService = OrderService();
  bool _editMode = false;
  bool _saving = false;
  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _phoneCtrl;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: _auth.currentUser?.name ?? '');
    _emailCtrl = TextEditingController(text: _auth.currentUser?.email ?? '');
    _phoneCtrl = TextEditingController(text: _auth.currentUser?.phone ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    await _auth.updateProfile(
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
    );
    setState(() { _saving = false; _editMode = false; });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Profil berhasil diperbarui!'),
        backgroundColor: AppTheme.primary,
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  void _logout() async {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Keluar?', style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Text('Anda akan keluar dari akun ini.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              await _auth.logout();
              if (mounted) {
                Navigator.pushAndRemoveUntil(context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (_) => false);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade400),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }

  void _deleteAccount() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Akun?',
            style: TextStyle(fontWeight: FontWeight.w700, color: Colors.red)),
        content: const Text('Akun Anda akan dihapus permanen. Tindakan ini tidak dapat dibatalkan.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              await _auth.deleteAccount();
              if (mounted) {
                Navigator.pushAndRemoveUntil(context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (_) => false);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus Akun'),
          ),
        ],
      ),
    );
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
  }

  String _formatTime(DateTime? dt) {
    if (dt == null) return '-';
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}  ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final history = _orderService.historyOrders;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Profil'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Avatar
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primary, AppTheme.primaryLight],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    child: Text(
                      (_auth.currentUser?.name ?? 'P').substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w800),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(_auth.currentUser?.name ?? 'Pelanggan',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(_auth.currentUser?.email ?? '-',
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.8), fontSize: 13)),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Edit profile
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.divider),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
                    child: Row(
                      children: [
                        const Icon(Icons.person_outline, color: AppTheme.primary),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text('Info Akun',
                              style: TextStyle(
                                  fontWeight: FontWeight.w700, fontSize: 15)),
                        ),
                        TextButton(
                          onPressed: () => setState(() => _editMode = !_editMode),
                          child: Text(_editMode ? 'Batal' : 'Edit',
                              style: const TextStyle(color: AppTheme.primaryLight)),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: _editMode
                        ? Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                TextFormField(
                                  controller: _nameCtrl,
                                  decoration: const InputDecoration(
                                    labelText: 'Nama',
                                    prefixIcon: Icon(Icons.person_outline,
                                        color: AppTheme.primary),
                                  ),
                                  validator: (v) =>
                                      v == null || v.isEmpty ? 'Wajib diisi' : null,
                                ),
                                const SizedBox(height: 12),
                                TextFormField(
                                  controller: _emailCtrl,
                                  decoration: const InputDecoration(
                                    labelText: 'Email',
                                    prefixIcon: Icon(Icons.email_outlined,
                                        color: AppTheme.primary),
                                  ),
                                  validator: (v) =>
                                      v == null || v.isEmpty ? 'Wajib diisi' : null,
                                ),
                                const SizedBox(height: 12),
                                TextFormField(
                                  controller: _phoneCtrl,
                                  decoration: const InputDecoration(
                                    labelText: 'No HP',
                                    prefixIcon: Icon(Icons.phone_outlined,
                                        color: AppTheme.primary),
                                  ),
                                  validator: (v) =>
                                      v == null || v.isEmpty ? 'Wajib diisi' : null,
                                ),
                                const SizedBox(height: 14),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: _saving ? null : _saveProfile,
                                    child: Text(_saving ? 'Menyimpan...' : 'Simpan'),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Column(
                            children: [
                              _InfoRow(icon: Icons.person_outline, label: 'Nama', value: _auth.currentUser?.name ?? '-'),
                              const SizedBox(height: 10),
                              _InfoRow(icon: Icons.email_outlined, label: 'Email', value: _auth.currentUser?.email ?? '-'),
                              const SizedBox(height: 10),
                              _InfoRow(icon: Icons.phone_outlined, label: 'No HP', value: _auth.currentUser?.phone ?? '-'),
                            ],
                          ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // History
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.divider),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 14, 16, 14),
                    child: Row(
                      children: [
                        Icon(Icons.history_rounded, color: AppTheme.primary),
                        SizedBox(width: 10),
                        Text('Riwayat Pesanan',
                            style: TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 15)),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  if (history.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(
                          child: Text('Belum ada riwayat pesanan',
                              style: TextStyle(color: AppTheme.textSecondary))),
                    )
                  else
                    ...history.map((order) => _HistoryItem(
                          order: order,
                          formatPrice: _formatPrice,
                          formatTime: _formatTime,
                        )),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Logout
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _logout,
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade400),
                icon: const Icon(Icons.logout_rounded),
                label: const Text('Keluar', style: TextStyle(fontSize: 15)),
              ),
            ),
            const SizedBox(height: 10),

            // Delete account
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: _deleteAccount,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.delete_forever_rounded),
                label: const Text('Hapus Akun', style: TextStyle(fontSize: 15)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.primary, size: 18),
        const SizedBox(width: 10),
        SizedBox(
          width: 60,
          child: Text(label,
              style: const TextStyle(
                  color: AppTheme.textSecondary, fontSize: 13)),
        ),
        Expanded(
          child: Text(value,
              style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textPrimary,
                  fontSize: 13)),
        ),
      ],
    );
  }
}

class _HistoryItem extends StatelessWidget {
  final CustomerOrder order;
  final String Function(int) formatPrice;
  final String Function(DateTime?) formatTime;

  const _HistoryItem({
    required this.order,
    required this.formatPrice,
    required this.formatTime,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.check_circle_rounded,
                color: Colors.green, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(order.id,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                        fontSize: 13)),
                Text('${order.items.length} item · ${formatTime(order.completedAt)}',
                    style: const TextStyle(
                        color: AppTheme.textSecondary, fontSize: 11)),
              ],
            ),
          ),
          Text('Rp ${formatPrice(order.total)}',
              style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primary,
                  fontSize: 13)),
        ],
      ),
    );
  }
}
