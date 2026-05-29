import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../core/theme/huashu_theme.dart';
import '../../../core/network/api_service.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;
  const ResetPasswordScreen({super.key, required this.email});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _tokenController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _api = ApiService();
  
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;
  String? _successMessage;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _fadeController.forward();
  }

  Future<void> _submitResetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final response = await _api.dio.post(
        '/api/auth/reset-password',
        data: {
          'email': widget.email,
          'token': _tokenController.text.trim(),
          'new_password': _newPasswordController.text,
        },
      );

      final data = response.data;
      if (data is Map<String, dynamic> && response.statusCode == 200 && data['success'] == true) {
        setState(() {
          _successMessage = data['message'] ?? 'Kata sandi berhasil diatur ulang. Silakan masuk.';
        });
        
        if (mounted) {
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              // Kembali ke halaman Login (berada 2 layar di belakang)
              Navigator.of(context).pop(); 
            }
          });
        }
        return;
      }

      setState(() {
        _errorMessage = data is Map<String, dynamic>
            ? data['message']?.toString()
            : 'Gagal mengatur ulang kata sandi.';
      });
    } on DioException catch (e) {
      setState(() {
        _errorMessage = ApiService.extractErrorMessage(
          e,
          fallback: 'Token tidak valid atau telah kedaluwarsa.',
        );
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Terjadi kesalahan tak terduga: ${e.toString()}';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _tokenController.dispose();
    _newPasswordController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: HuashuTheme.space32,
              vertical: HuashuTheme.space24,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: HuashuTheme.space24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          'ATUR ULANG\nKATA SANDI',
                          style: Theme.of(context).textTheme.displayLarge,
                        ),
                      ),
                      const HuashuSeal(character: '新'), // Baru
                    ],
                  ),
                  const SizedBox(height: HuashuTheme.space12),
                  Text(
                    'Masukkan token yang telah dikirim ke ${widget.email} dan buat kata sandi baru Anda.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: HuashuTheme.space48),

                  if (_errorMessage != null) ...[
                    HuashuStatusBox(
                      message: _errorMessage!,
                      type: HuashuStatusType.error,
                    ),
                    const SizedBox(height: HuashuTheme.space24),
                  ],

                  if (_successMessage != null) ...[
                    HuashuStatusBox(
                      message: _successMessage!,
                      type: HuashuStatusType.success,
                    ),
                    const SizedBox(height: HuashuTheme.space24),
                  ],

                  TextFormField(
                    controller: _tokenController,
                    keyboardType: TextInputType.text,
                    decoration: const InputDecoration(
                      labelText: 'Token Pemulihan',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Token tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: HuashuTheme.space24),

                  TextFormField(
                    controller: _newPasswordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Kata Sandi Baru',
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          color: HuashuTheme.warmStone,
                          size: 20,
                        ),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Kata sandi tidak boleh kosong';
                      }
                      if (value.length < 6) {
                        return 'Kata sandi minimal 6 karakter';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: HuashuTheme.space48),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading || _successMessage != null ? null : _submitResetPassword,
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('SIMPAN KATA SANDI'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
