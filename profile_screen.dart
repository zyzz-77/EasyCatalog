import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:easycatalog/utils/app_theme.dart';
import 'package:easycatalog/utils/auth_service.dart';

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
  final _auth = AuthService();

  // Profile edit
  final _ownerNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _restaurantNameCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _profileFormKey = GlobalKey<FormState>();
  bool _editMode = false;
  bool _savingProfile = false;

  // Change password
  final _oldPassCtrl = TextEditingController();
  final _newPassCtrl = TextEditingController();
  final _passFormKey = GlobalKey<FormState>();
  bool _showChangePass = false;
  bool _savingPass = false;
  bool _obscureOld = true;
  bool _obscureNew = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final u = _auth.currentUser;
    _ownerNameCtrl.text = u?.ownerName ?? '';
    _emailCtrl.text = u?.email ?? '';
    _phoneCtrl.text = u?.phone ?? '';
    _restaurantNameCtrl.text = u?.restaurantName ?? '';
    _locationCtrl.text = u?.restaurantLocation ?? '';
  }

  @override
  void didUpdateWidget(ProfileScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_editMode) _loadData();
  }

  @override
  void dispose() {
    _ownerNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _restaurantNameCtrl.dispose();
    _locationCtrl.dispose();
    _oldPassCtrl.dispose();
    _newPassCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_profileFormKey.currentState!.validate()) return;
    setState(() => _savingProfile = true);
    await _auth.updateProfile(
      ownerName: _ownerNameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      restaurantName: _restaurantNameCtrl.text.trim(),
      restaurantLocation: _locationCtrl.text.trim(),
    );
    setState(() {
      _savingProfile = false;
      _editMode = false;
    });
    widget.onRestaurantUpdated();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Profil berhasil diperbarui!'),
        backgroundColor: AppTheme.primary,
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  Future<void> _changePassword() async {
    if (!_passFormKey.currentState!.validate()) return;
    setState(() => _savingPass = true);
    final res = await _auth.changePassword(
      _oldPassCtrl.text,
      _newPassCtrl.text,
    );
    setState(() => _savingPass = false);
    if (mounted) {
      if (res['success']) {
        _oldPassCtrl.clear();
        _newPassCtrl.clear();
        setState(() => _showChangePass = false);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Password berhasil diubah!'),
          backgroundColor: AppTheme.primary,
          behavior: SnackBarBehavior.floating,
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(res['message']),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final u = _auth.currentUser;

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
                      (u?.ownerName ?? 'M').substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w800),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(u?.ownerName ?? 'Merchant',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(u?.email ?? '-',
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.8), fontSize: 13)),
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('🏪 ${u?.restaurantName ?? '-'}',
                        style:
                            const TextStyle(color: Colors.white, fontSize: 12)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Edit Info
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
                        const Icon(Icons.edit_note_rounded,
                            color: AppTheme.primary),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text('Info Akun & Restoran',
                              style: TextStyle(
                                  fontWeight: FontWeight.w700, fontSize: 15)),
                        ),
                        TextButton(
                          onPressed: () => setState(() {
                            _editMode = !_editMode;
                            if (!_editMode) _loadData();
                          }),
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
                            key: _profileFormKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const _SectionLabel(label: 'Data Pemilik'),
                                const SizedBox(height: 10),
                                TextFormField(
                                  controller: _ownerNameCtrl,
                                  decoration: const InputDecoration(
                                    labelText: 'Nama Pemilik',
                                    prefixIcon: Icon(Icons.person_outline,
                                        color: AppTheme.primary),
                                  ),
                                  validator: (v) => v == null || v.isEmpty
                                      ? 'Wajib diisi'
                                      : null,
                                ),
                                const SizedBox(height: 10),
                                TextFormField(
                                  controller: _emailCtrl,
                                  decoration: const InputDecoration(
                                    labelText: 'Email',
                                    prefixIcon: Icon(Icons.email_outlined,
                                        color: AppTheme.primary),
                                  ),
                                  validator: (v) {
                                    if (v == null || v.isEmpty)
                                      return 'Wajib diisi';
                                    if (!v.contains('@'))
                                      return 'Email tidak valid';
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 10),
                                TextFormField(
                                  controller: _phoneCtrl,
                                  decoration: const InputDecoration(
                                    labelText: 'Nomor Telepon',
                                    prefixIcon: Icon(Icons.phone_outlined,
                                        color: AppTheme.primary),
                                  ),
                                  validator: (v) => v == null || v.isEmpty
                                      ? 'Wajib diisi'
                                      : null,
                                ),
                                const SizedBox(height: 16),
                                const _SectionLabel(label: 'Data Restoran'),
                                const SizedBox(height: 10),
                                TextFormField(
                                  controller: _restaurantNameCtrl,
                                  decoration: const InputDecoration(
                                    labelText: 'Nama Restoran',
                                    prefixIcon: Icon(Icons.store_rounded,
                                        color: AppTheme.primary),
                                  ),
                                  validator: (v) => v == null || v.isEmpty
                                      ? 'Wajib diisi'
                                      : null,
                                ),
                                const SizedBox(height: 10),
                                TextFormField(
                                  controller: _locationCtrl,
                                  maxLines: 2,
                                  decoration: const InputDecoration(
                                    labelText: 'Lokasi / Alamat',
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
                                    onPressed:
                                        _savingProfile ? null : _saveProfile,
                                    child: Text(_savingProfile
                                        ? 'Menyimpan...'
                                        : 'Simpan'),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Column(
                            children: [
                              _InfoRow(
                                  label: 'Nama Pemilik',
                                  value: u?.ownerName ?? '-'),
                              _InfoRow(label: 'Email', value: u?.email ?? '-'),
                              _InfoRow(
                                  label: 'No. Telp', value: u?.phone ?? '-'),
                              const Divider(height: 20),
                              _InfoRow(
                                  label: 'Nama Restoran',
                                  value: u?.restaurantName ?? '-'),
                              _InfoRow(
                                  label: 'Lokasi',
                                  value: u?.restaurantLocation ?? '-'),
                            ],
                          ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Ganti Password
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
                        const Icon(Icons.lock_outline, color: AppTheme.primary),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text('Ganti Password',
                              style: TextStyle(
                                  fontWeight: FontWeight.w700, fontSize: 15)),
                        ),
                        TextButton(
                          onPressed: () => setState(() {
                            _showChangePass = !_showChangePass;
                            _oldPassCtrl.clear();
                            _newPassCtrl.clear();
                          }),
                          child: Text(_showChangePass ? 'Batal' : 'Ubah',
                              style: const TextStyle(color: AppTheme.primary)),
                        ),
                      ],
                    ),
                  ),
                  if (_showChangePass) ...[
                    const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Form(
                        key: _passFormKey,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _oldPassCtrl,
                              obscureText: _obscureOld,
                              decoration: InputDecoration(
                                labelText: 'Password Lama',
                                prefixIcon: const Icon(Icons.lock_outline,
                                    color: AppTheme.primary),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                      _obscureOld
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      color: AppTheme.textSecondary),
                                  onPressed: () => setState(
                                      () => _obscureOld = !_obscureOld),
                                ),
                              ),
                              validator: (v) =>
                                  v == null || v.isEmpty ? 'Wajib diisi' : null,
                            ),
                            const SizedBox(height: 10),
                            TextFormField(
                              controller: _newPassCtrl,
                              obscureText: _obscureNew,
                              decoration: InputDecoration(
                                labelText: 'Password Baru',
                                prefixIcon: const Icon(Icons.lock_rounded,
                                    color: AppTheme.primary),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                      _obscureNew
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      color: AppTheme.textSecondary),
                                  onPressed: () => setState(
                                      () => _obscureNew = !_obscureNew),
                                ),
                              ),
                              validator: (v) {
                                if (v == null || v.isEmpty)
                                  return 'Wajib diisi';
                                if (v.length < 6) return 'Minimal 6 karakter';
                                return null;
                              },
                            ),
                            const SizedBox(height: 14),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _savingPass ? null : _changePassword,
                                child: Text(_savingPass
                                    ? 'Menyimpan...'
                                    : 'Ubah Password'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),

            // QR Code Section
            _QrSection(user: _auth.currentUser),

            const SizedBox(height: 20),

            // Logout
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: widget.onLogout,
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade400),
                icon: const Icon(Icons.logout_rounded),
                label: const Text('Keluar', style: TextStyle(fontSize: 15)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _QrSection extends StatelessWidget {
  final MerchantUser? user;
  const _QrSection({required this.user});

  String _buildQrData() {
    if (user == null) return '';
    final data = {
      'merchantId': FirebaseAuth.instance.currentUser?.uid ?? '',
      'restaurantName': user!.restaurantName,
      'restaurantLocation': user!.restaurantLocation,
      'menu': user!.menu,
    };
    final jsonStr = jsonEncode(data);
    final encoded = base64Url.encode(utf8.encode(jsonStr));
    return 'https://easycatalog-app.web.app/?data=$encoded';
  }

  @override
  Widget build(BuildContext context) {
    final qrData = _buildQrData();
    final hasMenu = user?.menu.isNotEmpty ?? false;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Row(
              children: [
                const Icon(Icons.qr_code_rounded, color: AppTheme.primary),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('QR Code Restoran',
                          style: TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 15)),
                      Text('Bagikan ke pelanggan untuk scan menu',
                          style: TextStyle(
                              color: AppTheme.textSecondary, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(20),
            child: hasMenu
                ? Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppTheme.divider),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: QrImageView(
                          data: qrData,
                          version: QrVersions.auto,
                          size: 200,
                          eyeStyle: const QrEyeStyle(
                            eyeShape: QrEyeShape.square,
                            color: AppTheme.primaryDark,
                          ),
                          dataModuleStyle: const QrDataModuleStyle(
                            dataModuleShape: QrDataModuleShape.square,
                            color: AppTheme.primaryDark,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        user?.restaurantName ?? '',
                        style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: AppTheme.textPrimary),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${user?.menu.length ?? 0} item menu tersedia',
                        style: const TextStyle(
                            color: AppTheme.textSecondary, fontSize: 13),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: qrData));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Data QR disalin!'),
                                backgroundColor: AppTheme.primary,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                            );
                          },
                          icon: const Icon(Icons.copy_rounded, size: 16),
                          label: const Text('Salin Data QR'),
                        ),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      Icon(Icons.qr_code_2_rounded,
                          size: 64, color: Colors.grey[300]),
                      const SizedBox(height: 12),
                      const Text(
                        'QR belum tersedia',
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Tambahkan menu di tab Menu terlebih dahulu\nagar QR code bisa digenerate',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: AppTheme.textSecondary, fontSize: 13),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(label,
        style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppTheme.textSecondary,
            fontSize: 12));
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label,
                style: const TextStyle(
                    color: AppTheme.textSecondary, fontSize: 13)),
          ),
          const Text(': ', style: TextStyle(color: AppTheme.textSecondary)),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w500,
                    fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
