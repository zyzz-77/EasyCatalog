import 'package:flutter/material.dart';
import 'package:easycatalog/utils/api_service.dart';
import 'package:easycatalog/utils/app_theme.dart';

class EditRestaurantScreen extends StatefulWidget {
  final Map<String, dynamic> restaurant;

  const EditRestaurantScreen({super.key, required this.restaurant});

  @override
  State<EditRestaurantScreen> createState() => _EditRestaurantScreenState();
}

class _EditRestaurantScreenState extends State<EditRestaurantScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _locationCtrl;
  bool _loading = false;

  final _api = ApiService();

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.restaurant['name'] ?? '');
    _locationCtrl = TextEditingController(text: widget.restaurant['location'] ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final res = await _api.updateRestaurant({
        'name': _nameCtrl.text.trim(),
        'location': _locationCtrl.text.trim(),
      });
      if (res['status'] == 200 || res['status'] == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Restoran berhasil diperbarui!'),
            backgroundColor: AppTheme.primary,
          ));
          Navigator.pop(context, true);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(res['body']['message'] ?? 'Gagal memperbarui'),
            backgroundColor: AppTheme.accent,
          ));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Gagal terhubung ke server'),
          backgroundColor: AppTheme.accent,
        ));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Edit Restoran')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Current info banner
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.accent.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.accent.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: AppTheme.accent),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Mengubah info untuk "${widget.restaurant['name']}"',
                        style: const TextStyle(
                            color: AppTheme.accent, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              const Text('Edit Informasi',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  )),
              const SizedBox(height: 16),

              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nama Restoran',
                  prefixIcon: Icon(Icons.store_rounded, color: AppTheme.primary),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Nama restoran wajib diisi' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _locationCtrl,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Lokasi / Alamat',
                  prefixIcon: Icon(Icons.location_on_rounded, color: AppTheme.primary),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Lokasi wajib diisi' : null,
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _loading ? null : _submit,
                  icon: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2.5, color: Colors.white),
                        )
                      : const Icon(Icons.save_rounded),
                  label: Text(_loading ? 'Menyimpan...' : 'Simpan Perubahan',
                      style: const TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
