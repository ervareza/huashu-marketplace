import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/huashu_theme.dart';
import '../../../core/network/api_service.dart';
import 'destination_search_delegate.dart';

class AddressScreen extends StatefulWidget {
  const AddressScreen({super.key});

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  final ApiService _api = ApiService();
  bool _isLoading = true;
  List<dynamic> _addresses = [];

  @override
  void initState() {
    super.initState();
    _fetchAddresses();
  }

  Future<void> _fetchAddresses() async {
    setState(() => _isLoading = true);
    try {
      final response = await _api.dio.get('/api/users/addresses');
      if (response.statusCode == 200 && response.data['success'] == true) {
        setState(() {
          _addresses = response.data['data'] ?? [];
        });
      }
    } catch (e) {
      debugPrint("Gagal mengambil alamat: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _setDefaultAddress(int id) async {
    try {
      final response = await _api.dio.put('/api/users/addresses/$id/set-default');
      if (response.statusCode == 200) {
        _fetchAddresses();
      }
    } catch (e) {
      debugPrint("Gagal set alamat utama: $e");
    }
  }

  void _showAddAddressDialog() {
    final formKey = GlobalKey<FormState>();
    final recipientCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final labelCtrl = TextEditingController(text: 'Rumah');
    final addressCtrl = TextEditingController();
    final cityCtrl = TextEditingController();
    final provinceCtrl = TextEditingController();
    final postalCtrl = TextEditingController();
    int? cityId;
    int? provinceId;
    bool isDefault = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: HuashuTheme.xuanPaperBg,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
                left: 24,
                right: 24,
                top: 24,
              ),
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Tambah Alamat Baru', style: GoogleFonts.notoSerifSc(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: labelCtrl,
                        decoration: const InputDecoration(labelText: 'Label (Kantor/Rumah)'),
                        validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: recipientCtrl,
                        decoration: const InputDecoration(labelText: 'Nama Penerima'),
                        validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: phoneCtrl,
                        decoration: const InputDecoration(labelText: 'Nomor HP'),
                        keyboardType: TextInputType.phone,
                        validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: provinceCtrl,
                        decoration: const InputDecoration(labelText: 'Provinsi', suffixIcon: Icon(Icons.search)),
                        readOnly: true,
                        onTap: () async {
                          final result = await showSearch(
                            context: context,
                            delegate: DestinationSearchDelegate(),
                          );
                          if (result != null) {
                            setModalState(() {
                              cityCtrl.text = result['city'] ?? '';
                              if (result['subdistrict'] != null) {
                                cityCtrl.text = '${result['subdistrict']}, ${result['type']} ${result['city']}';
                              }
                              provinceCtrl.text = result['province'] ?? '';
                              cityId = int.tryParse(result['id'].toString());
                              provinceId = int.tryParse(result['province_id']?.toString() ?? '');
                            });
                          }
                        },
                        validator: (v) => v!.isEmpty ? 'Wajib diisi (tap untuk mencari)' : null,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: cityCtrl,
                        decoration: const InputDecoration(labelText: 'Kota / Kecamatan'),
                        readOnly: true,
                        onTap: () async {
                          final result = await showSearch(
                            context: context,
                            delegate: DestinationSearchDelegate(),
                          );
                          if (result != null) {
                            setModalState(() {
                              cityCtrl.text = result['city'] ?? '';
                              if (result['subdistrict'] != null) {
                                cityCtrl.text = '${result['subdistrict']}, ${result['type']} ${result['city']}';
                              }
                              provinceCtrl.text = result['province'] ?? '';
                              cityId = int.tryParse(result['id'].toString());
                              provinceId = int.tryParse(result['province_id']?.toString() ?? '');
                            });
                          }
                        },
                        validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: postalCtrl,
                        decoration: const InputDecoration(labelText: 'Kode Pos'),
                        keyboardType: TextInputType.number,
                        validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: addressCtrl,
                        decoration: const InputDecoration(labelText: 'Jalan & Detail Alamat'),
                        maxLines: 2,
                        validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                      ),
                      const SizedBox(height: 16),
                      SwitchListTile(
                        title: const Text('Jadikan Alamat Utama'),
                        value: isDefault,
                        activeColor: HuashuTheme.mineralJadeGreen,
                        onChanged: (val) => setModalState(() => isDefault = val),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: HuashuTheme.mineralJadeGreen,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          onPressed: () async {
                            if (!formKey.currentState!.validate()) return;
                            
                            try {
                              final response = await _api.dio.post('/api/users/addresses', data: {
                                'label': labelCtrl.text,
                                'recipient': recipientCtrl.text,
                                'phone': phoneCtrl.text,
                                'address': addressCtrl.text,
                                'city': cityCtrl.text,
                                'city_id': cityId,
                                'province': provinceCtrl.text,
                                'province_id': provinceId,
                                'postal_code': postalCtrl.text,
                                'is_default': isDefault,
                              });

                              if (response.statusCode == 201) {
                                  if (ctx.mounted) Navigator.pop(ctx);
                                  _fetchAddresses();
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Gagal menambah alamat')),
                                  );
                                }
                              }
                            },
                            child: const Text('SIMPAN ALAMAT'),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      );
    }

    Future<void> _deleteAddress(int id) async {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('HAPUS ALAMAT', style: GoogleFonts.notoSerifSc(fontWeight: FontWeight.bold, color: HuashuTheme.stainedCinnabarRed)),
          content: const Text('Apakah Anda yakin ingin menghapus alamat ini?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('BATAL', style: TextStyle(color: HuashuTheme.charcoalBlack)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('HAPUS', style: TextStyle(color: HuashuTheme.stainedCinnabarRed)),
            ),
          ],
        ),
      );

      if (confirm == true) {
        setState(() => _isLoading = true);
        try {
          final response = await _api.dio.delete('/api/users/addresses/$id');
          if (response.statusCode == 200) {
            _fetchAddresses();
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Alamat berhasil dihapus')));
            }
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal menghapus alamat')));
            setState(() => _isLoading = false);
          }
        }
      }
    }

    void _showEditAddressDialog(Map<String, dynamic> addr) {
      final formKey = GlobalKey<FormState>();
      final recipientCtrl = TextEditingController(text: addr['recipient']?.toString() ?? '');
      final phoneCtrl = TextEditingController(text: addr['phone']?.toString() ?? '');
      final labelCtrl = TextEditingController(text: addr['label']?.toString() ?? '');
      final addressCtrl = TextEditingController(text: addr['address']?.toString() ?? '');
      final cityCtrl = TextEditingController(text: addr['city']?.toString() ?? '');
      final provinceCtrl = TextEditingController(text: addr['province']?.toString() ?? '');
      final postalCtrl = TextEditingController(text: addr['postal_code']?.toString() ?? '');
      int? cityId = addr['city_id'] != null ? int.tryParse(addr['city_id'].toString()) : null;
      int? provinceId = addr['province_id'] != null ? int.tryParse(addr['province_id'].toString()) : null;

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: HuashuTheme.xuanPaperBg,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
        builder: (ctx) {
          return StatefulBuilder(
            builder: (context, setModalState) {
              return Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(ctx).viewInsets.bottom,
                  left: 24,
                  right: 24,
                  top: 24,
                ),
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Edit Alamat', style: GoogleFonts.notoSerifSc(fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: labelCtrl,
                          decoration: const InputDecoration(labelText: 'Label (Kantor/Rumah)'),
                          validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: recipientCtrl,
                          decoration: const InputDecoration(labelText: 'Nama Penerima'),
                          validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: phoneCtrl,
                          decoration: const InputDecoration(labelText: 'Nomor HP'),
                          keyboardType: TextInputType.phone,
                          validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: provinceCtrl,
                          decoration: const InputDecoration(labelText: 'Provinsi', suffixIcon: Icon(Icons.search)),
                          readOnly: true,
                          onTap: () async {
                            final result = await showSearch(
                              context: context,
                              delegate: DestinationSearchDelegate(),
                            );
                            if (result != null) {
                              setModalState(() {
                                cityCtrl.text = result['city'] ?? '';
                                if (result['subdistrict'] != null) {
                                  cityCtrl.text = '${result['subdistrict']}, ${result['type']} ${result['city']}';
                                }
                                provinceCtrl.text = result['province'] ?? '';
                                cityId = int.tryParse(result['id'].toString());
                                provinceId = int.tryParse(result['province_id']?.toString() ?? '');
                              });
                            }
                          },
                          validator: (v) => v!.isEmpty ? 'Wajib diisi (tap untuk mencari)' : null,
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: cityCtrl,
                          decoration: const InputDecoration(labelText: 'Kota / Kecamatan'),
                          readOnly: true,
                          onTap: () async {
                            final result = await showSearch(
                              context: context,
                              delegate: DestinationSearchDelegate(),
                            );
                            if (result != null) {
                              setModalState(() {
                                cityCtrl.text = result['city'] ?? '';
                                if (result['subdistrict'] != null) {
                                  cityCtrl.text = '${result['subdistrict']}, ${result['type']} ${result['city']}';
                                }
                                provinceCtrl.text = result['province'] ?? '';
                                cityId = int.tryParse(result['id'].toString());
                                provinceId = int.tryParse(result['province_id']?.toString() ?? '');
                              });
                            }
                          },
                          validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: postalCtrl,
                          decoration: const InputDecoration(labelText: 'Kode Pos'),
                          keyboardType: TextInputType.number,
                          validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: addressCtrl,
                          decoration: const InputDecoration(labelText: 'Jalan & Detail Alamat'),
                          maxLines: 2,
                          validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: HuashuTheme.mineralJadeGreen,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            onPressed: () async {
                              if (!formKey.currentState!.validate()) return;
                              
                              try {
                                final response = await _api.dio.put('/api/users/addresses/${addr['id']}', data: {
                                  'label': labelCtrl.text,
                                  'recipient': recipientCtrl.text,
                                  'phone': phoneCtrl.text,
                                  'address': addressCtrl.text,
                                  'city': cityCtrl.text,
                                  'city_id': cityId,
                                  'province': provinceCtrl.text,
                                  'province_id': provinceId,
                                  'postal_code': postalCtrl.text,
                                });

                                if (response.statusCode == 200) {
                                  if (ctx.mounted) Navigator.pop(ctx);
                                  _fetchAddresses();
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Gagal mengubah alamat')),
                                  );
                                }
                              }
                            },
                            child: const Text('SIMPAN PERUBAHAN'),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      );
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Daftar Alamat',
          style: GoogleFonts.notoSerifSc(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: HuashuTheme.mineralJadeGreen))
          : _addresses.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.location_off_outlined, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text('Belum ada alamat tersimpan', style: GoogleFonts.inter(color: Colors.grey)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _addresses.length,
                  itemBuilder: (context, index) {
                    final addr = _addresses[index];
                    final isDefault = addr['is_default'] == true;
                    
                    return Card(
                      color: HuashuTheme.xuanPaperBg,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          color: isDefault ? HuashuTheme.mineralJadeGreen : HuashuTheme.lightInkLine,
                          width: isDefault ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      addr['label'] ?? 'Alamat',
                                      style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                                    ),
                                    if (isDefault) ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: HuashuTheme.mineralJadeGreen.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          'Utama',
                                          style: GoogleFonts.inter(fontSize: 10, color: HuashuTheme.mineralJadeGreen),
                                        ),
                                      ),
                                    ]
                                  ],
                                ),
                                Row(
                                  children: [
                                    if (!isDefault)
                                      TextButton(
                                        onPressed: () => _setDefaultAddress(addr['id']),
                                        child: const Text('Jadikan Utama', style: TextStyle(color: HuashuTheme.mineralJadeGreen, fontSize: 12)),
                                      ),
                                    PopupMenuButton<String>(
                                      icon: const Icon(Icons.more_vert, size: 20),
                                      onSelected: (val) {
                                        if (val == 'edit') {
                                          _showEditAddressDialog(addr);
                                        } else if (val == 'delete') {
                                          _deleteAddress(addr['id']);
                                        }
                                      },
                                      itemBuilder: (ctx) => [
                                        const PopupMenuItem(
                                          value: 'edit',
                                          child: Text('Edit'),
                                        ),
                                        const PopupMenuItem(
                                          value: 'delete',
                                          child: Text('Hapus', style: TextStyle(color: HuashuTheme.stainedCinnabarRed)),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              addr['recipient'] ?? '',
                              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                            ),
                            Text(
                              addr['phone'] ?? '',
                              style: GoogleFonts.inter(color: HuashuTheme.charcoalBlack.withValues(alpha: 0.7)),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${addr['address']}, ${addr['city']}, ${addr['province']} ${addr['postal_code']}',
                              style: GoogleFonts.inter(fontSize: 13, height: 1.4),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddAddressDialog,
        backgroundColor: HuashuTheme.mineralJadeGreen,
        icon: const Icon(Icons.add),
        label: const Text('Tambah Alamat'),
      ),
    );
  }
}
