import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../core/theme/huashu_theme.dart';
import '../../../core/network/api_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _api = ApiService();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  String? _errorMessage;
  String? _successMessage;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final response = await _api.dio.post(
        '/api/auth/register',
        data: {
          'name': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'password': _passwordController.text,
          'passwordConfirm': _confirmPasswordController.text,
        },
      );

      final data = response.data;
      if (data is Map<String, dynamic> &&
          (response.statusCode == 201 || response.statusCode == 200) &&
          data['success'] == true) {
        setState(() {
          _successMessage = 'Registrasi berhasil! Mengalihkan ke halaman masuk...';
        });
        _nameController.clear();
        _emailController.clear();
        _passwordController.clear();
        _confirmPasswordController.clear();

        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          Navigator.of(context).pop();
        }
        return;
      }

      setState(() {
        _errorMessage = (data is Map<String, dynamic>)
            ? data['message']?.toString() ?? 'Registrasi gagal.'
            : 'Registrasi gagal. Response tidak valid dari server.';
      });
    } on DioException catch (e) {
      setState(() {
        _errorMessage = ApiService.extractErrorMessage(
          e,
          fallback: 'Email sudah terdaftar atau terjadi kesalahan server.',
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
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: HuashuTheme.space32,
            vertical: HuashuTheme.space8,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ─── Header ───────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'DAFTAR\nBARU',
                      style: Theme.of(context).textTheme.displayLarge,
                    ),
                    const HuashuSeal(character: '書'),
                  ],
                ),

                const SizedBox(height: HuashuTheme.space12),
                Text(
                  'Mulai perjalanan Anda bersama kami.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),

                const SizedBox(height: HuashuTheme.space32),

                // ─── Status Messages ──────────────────────────
                if (_errorMessage != null) ...[
                  HuashuStatusBox(message: _errorMessage!, type: HuashuStatusType.error),
                  const SizedBox(height: HuashuTheme.space24),
                ],
                if (_successMessage != null) ...[
                  HuashuStatusBox(message: _successMessage!, type: HuashuStatusType.success),
                  const SizedBox(height: HuashuTheme.space24),
                ],

                // ─── Form Fields ─────────────────────────────
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Lengkap',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Nama lengkap tidak boleh kosong';
                    }
                    if (value.trim().length < 3) {
                      return 'Nama lengkap minimal 3 karakter';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: HuashuTheme.space24),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Surat Elektronik (Email)',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Email tidak boleh kosong';
                    }
                    if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(value.trim())) {
                      return 'Format email tidak valid';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: HuashuTheme.space24),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Kata Sandi',
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
                      return 'Password tidak boleh kosong';
                    }
                    if (value.length < 6) {
                      return 'Password minimal 6 karakter';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: HuashuTheme.space24),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirm,
                  decoration: InputDecoration(
                    labelText: 'Konfirmasi Kata Sandi',
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: HuashuTheme.warmStone,
                        size: 20,
                      ),
                      onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Konfirmasi password tidak boleh kosong';
                    }
                    if (value != _passwordController.text) {
                      return 'Konfirmasi password tidak cocok';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: HuashuTheme.space48),

                // ─── Tombol Daftar ────────────────────────────
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _register,
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('DAFTAR SEKARANG'),
                  ),
                ),
                const SizedBox(height: HuashuTheme.space32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
