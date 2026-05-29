import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../core/theme/huashu_theme.dart';
import '../../../core/network/api_service.dart';
import 'reset_password_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _api = ApiService();
  bool _isLoading = false;
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

  Future<void> _submitForgotPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final response = await _api.dio.post(
        '/api/auth/forgot-password',
        data: {
          'email': _emailController.text.trim(),
        },
      );

      final data = response.data;
      if (data is Map<String, dynamic> && response.statusCode == 200 && data['success'] == true) {
        setState(() {
          _successMessage = data['message'] ?? 'Token reset kata sandi telah dikirimkan.';
        });
        
        if (mounted) {
          // Arahkan ke layar reset password dengan membawa email
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => ResetPasswordScreen(email: _emailController.text.trim()),
                ),
              );
            }
          });
        }
        return;
      }

      setState(() {
        _errorMessage = data is Map<String, dynamic>
            ? data['message']?.toString()
            : 'Gagal mengirimkan permintaan.';
      });
    } on DioException catch (e) {
      setState(() {
        _errorMessage = ApiService.extractErrorMessage(
          e,
          fallback: 'Email tidak terdaftar atau terjadi kesalahan jaringan.',
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
    _emailController.dispose();
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
                          'LUPA\nKATA SANDI',
                          style: Theme.of(context).textTheme.displayLarge,
                        ),
                      ),
                      const HuashuSeal(character: '鑰'), // Kunci
                    ],
                  ),
                  const SizedBox(height: HuashuTheme.space12),
                  Text(
                    'Masukkan alamat email Anda yang terdaftar. Kami akan mengirimkan token untuk mereset kata sandi.',
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
                  const SizedBox(height: HuashuTheme.space48),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading || _successMessage != null ? null : _submitForgotPassword,
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('KIRIM TOKEN'),
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
