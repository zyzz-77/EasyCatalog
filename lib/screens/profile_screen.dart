import 'package:flutter/material.dart';
import 'package:easycatalog/utils/app_theme.dart';
import 'package:easycatalog/utils/api_service.dart';

class ProfileScreen extends StatefulWidget {
  final Map<String, dynamic>? user;
  final Map<String, dynamic>? restaurant;
  final VoidCallback onLogout;
  final VoidCallback onRestaurantUpdated;

  const ProfileScreen({
    super.key,
    required this.user,
    required this.restaurant,
    required this.onLogout,
    required this.onRestaurantUpdated,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _api = ApiService();
  final _nameCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _editMode = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl.text = widget.restaurant?['name'] ?? '';
    _locationCtrl.text = widget.restaurant?['location'] ?? '';
  }

  @override
  void didUpdateWidget(ProfileScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_editMode) {
      _nameCtrl.text = widget.restaurant?['name'] ?? '';
      _locationCtrl.text = widget.restaurant?['location'] ?? '';
    }
  }

  Future<void> _saveRestaurant() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await _api.updateRestaurant({
        'name': _nameCtrl.text.trim(),
        'location': _locationCtrl.text.trim(),
      });
      setState(() { _editMode = false; _saving = false; });
      widget.onRestaurantUpdated();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Info restoran berhasil diperbarui!'),
        backgroundColor: AppTheme.primary,
        behavior: SnackBarBehavior.floating,
      ));
    } catch (e) {
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  colors: [AppTheme.primary, AppTheme.primaryDark],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    child: Text(
                      (widget.user?['name'] ?? 'M').substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w800),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(widget.user?['name'] ?? 'Merchant',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(widget.user?['email'] ?? '-',
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.8), fontSize: 13)),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text('🏪 Merchant',
                        style: TextStyle(color: Colors.white, fontSize: 12)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Edit Restoran
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
                        const Icon(Icons.store_rounded, color: AppTheme.primary),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text('Info Restoran',
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                  color: AppTheme.textPrimary)),
                        ),
                        TextButton(
                          onPressed: () => setState(() => _editMode = !_editMode),
                          child: Text(_editMode ? 'Batal' : 'Edit',
                              style: const TextStyle(color: AppTheme.primary)),
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
                                    labelText: 'Nama Restoran',
                                    prefixIcon: Icon(Icons.store_rounded,
                                        color: AppTheme.primary),
                                  ),
                                  validator: (v) => v == null || v.isEmpty
                                      ? 'Wajib diisi'
                                      : null,
                                ),
                                const SizedBox(height: 12),
                                TextFormField(
                                  controller: _locationCtrl,
                                  maxLines: 2,
                                  decoration: const InputDecoration(
                                    labelText: 'Lokasi',
                                    prefixIcon: Icon(Icons.location_on_rounded,
                                        color: AppTheme.primary),
                                  ),
                                  validator: (v) => v == null || v.isEmpty
                                      ? 'Wajib diisi'
                                      : null,
                                ),
                                const SizedBox(height: 14),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: _saving ? null : _saveRestaurant,
                                    child: Text(_saving ? 'Menyimpan...' : 'Simpan'),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Column(
                            children: [
                              _InfoRow(
                                  label: 'Nama',
                                  value: widget.restaurant?['name'] ?? '-'),
                              const SizedBox(height: 8),
                              _InfoRow(
                                  label: 'Lokasi',
                                  value: widget.restaurant?['location'] ?? '-'),
                            ],
                          ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Logout
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: widget.onLogout,
                style:
                    ElevatedButton.styleFrom(backgroundColor: Colors.red.shade400),
                icon: const Icon(Icons.logout_rounded),
                label: const Text('Keluar', style: TextStyle(fontSize: 15)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 70,
          child: Text(label,
              style: const TextStyle(
                  color: AppTheme.textSecondary, fontSize: 13)),
        ),
        const Text(': ',
            style: TextStyle(color: AppTheme.textSecondary)),
        Expanded(
          child: Text(value,
              style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w500,
                  fontSize: 13)),
        ),
      ],
    );
  }
}
