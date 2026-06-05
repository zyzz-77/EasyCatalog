import 'package:flutter/material.dart';
import 'package:easycatalog/utils/api_service.dart';
import 'package:easycatalog/utils/app_theme.dart';

class MenuScreen extends StatefulWidget {
  final Map<String, dynamic>? restaurant;
  final VoidCallback onUpdate;

  const MenuScreen({super.key, required this.restaurant, required this.onUpdate});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final _api = ApiService();
  bool _loading = false;

  Map<String, dynamic> get _menu {
    final m = widget.restaurant?['menu'];
    if (m == null) return {};
    if (m is Map) return Map<String, dynamic>.from(m);
    return {};
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? AppTheme.accent : AppTheme.primary,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  void _showAddDialog() {
    final nameCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.add_circle_rounded, color: AppTheme.primary),
            SizedBox(width: 8),
            Text('Tambah Menu', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
          ],
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nama Menu',
                  prefixIcon: Icon(Icons.fastfood_rounded, color: AppTheme.primary),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: priceCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Harga (Rp)',
                  prefixIcon: Icon(Icons.attach_money_rounded, color: AppTheme.primary),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Wajib diisi';
                  if (int.tryParse(v) == null) return 'Harga harus angka';
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              Navigator.pop(context);
              setState(() => _loading = true);
              try {
                final res = await _api.addMenuItem(
                  nameCtrl.text.trim(),
                  int.parse(priceCtrl.text.trim()),
                );
                if (res['status'] == 201 || res['status'] == 200) {
                  _showSnack('Menu berhasil ditambahkan!');
                  widget.onUpdate();
                } else {
                  _showSnack(res['body']['message'] ?? 'Gagal', isError: true);
                }
              } catch (e) {
                _showSnack('Gagal terhubung', isError: true);
              } finally {
                if (mounted) setState(() => _loading = false);
              }
            },
            child: const Text('Tambah'),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(String oldName, int oldPrice) {
    final nameCtrl = TextEditingController(text: oldName);
    final priceCtrl = TextEditingController(text: oldPrice.toString());
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.edit_rounded, color: AppTheme.accent),
            SizedBox(width: 8),
            Text('Edit Menu', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
          ],
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nama Menu',
                  prefixIcon: Icon(Icons.fastfood_rounded, color: AppTheme.primary),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: priceCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Harga (Rp)',
                  prefixIcon: Icon(Icons.attach_money_rounded, color: AppTheme.primary),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Wajib diisi';
                  if (int.tryParse(v) == null) return 'Harga harus angka';
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              Navigator.pop(context);
              setState(() => _loading = true);
              try {
                final res = await _api.updateMenuItem(
                  oldName,
                  nameCtrl.text.trim(),
                  int.parse(priceCtrl.text.trim()),
                );
                if (res['status'] == 200 || res['status'] == 201) {
                  _showSnack('Menu berhasil diperbarui!');
                  widget.onUpdate();
                } else {
                  _showSnack(res['body']['message'] ?? 'Gagal', isError: true);
                }
              } catch (e) {
                _showSnack('Gagal terhubung', isError: true);
              } finally {
                if (mounted) setState(() => _loading = false);
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(String name) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hapus Menu?', style: TextStyle(fontWeight: FontWeight.w700)),
        content: Text('Apakah Anda yakin ingin menghapus "$name"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);
              setState(() => _loading = true);
              try {
                final res = await _api.deleteMenuItem(name);
                if (res['status'] == 200 || res['status'] == 201) {
                  _showSnack('Menu berhasil dihapus');
                  widget.onUpdate();
                } else {
                  _showSnack(res['body']['message'] ?? 'Gagal', isError: true);
                }
              } catch (e) {
                _showSnack('Gagal terhubung', isError: true);
              } finally {
                if (mounted) setState(() => _loading = false);
              }
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
  }

  @override
  Widget build(BuildContext context) {
    final menu = _menu;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Kelola Menu'),
        automaticallyImplyLeading: false,
        actions: [
          if (_loading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              ),
            ),
        ],
      ),
      floatingActionButton: widget.restaurant != null
          ? FloatingActionButton.extended(
              onPressed: _showAddDialog,
              backgroundColor: AppTheme.accent,
              icon: const Icon(Icons.add_rounded, color: Colors.white),
              label: const Text('Tambah Menu',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            )
          : null,
      body: widget.restaurant == null
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.store_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Buat restoran terlebih dahulu',
                      style: TextStyle(color: AppTheme.textSecondary)),
                ],
              ),
            )
          : menu.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.restaurant_menu_outlined,
                          size: 64, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      const Text('Belum ada menu',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary)),
                      const SizedBox(height: 8),
                      const Text('Tambahkan menu pertama Anda',
                          style: TextStyle(color: AppTheme.textSecondary)),
                    ],
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Summary
                    Container(
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppTheme.primary, AppTheme.primaryDark],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.restaurant_menu_rounded,
                              color: Colors.white, size: 28),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${menu.length} Item Menu',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  )),
                              const Text('Ketuk item untuk edit atau hapus',
                                  style: TextStyle(
                                      color: Colors.white70, fontSize: 12)),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Menu items
                    ...menu.entries.map((entry) {
                      final price = entry.value is int
                          ? entry.value as int
                          : (entry.value as num).toInt();
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppTheme.divider),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          leading: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.fastfood_rounded,
                                color: AppTheme.primary, size: 22),
                          ),
                          title: Text(entry.key,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimary,
                              )),
                          subtitle: Text(
                            'Rp ${_formatPrice(price)}',
                            style: const TextStyle(
                              color: AppTheme.accent,
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit_outlined,
                                    color: AppTheme.primary, size: 20),
                                onPressed: () =>
                                    _showEditDialog(entry.key, price),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline,
                                    color: Colors.red, size: 20),
                                onPressed: () => _confirmDelete(entry.key),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 80),
                  ],
                ),
    );
  }
}
