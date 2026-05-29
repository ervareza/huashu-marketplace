import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/huashu_theme.dart';
import '../../../core/network/api_service.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';
import '../../product/presentation/catalog_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _api = ApiService();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _fadeController.forward();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _api.dio.post(
        '/api/auth/login',
        data: {
          'email': _emailController.text.trim(),
          'password': _passwordController.text,
        },
      );

      final data = response.data;
      if (data is Map<String, dynamic> &&
          response.statusCode == 200 &&
          data['success'] == true) {
        final responseData = data['data'];
        if (responseData is Map<String, dynamic>) {
          final accessToken = responseData['token']?.toString();
          final refreshToken = responseData['refresh_token']?.toString();
          final userId = responseData['id']?.toString() ?? '';
          final userName = responseData['name']?.toString() ?? '';
          final userRole = responseData['role']?.toString() ?? '';

          if (accessToken != null) {
            await _api.secureStorage.write(key: 'access_token', value: accessToken);
          }
          if (refreshToken != null) {
            await _api.secureStorage.write(key: 'refresh_token', value: refreshToken);
          }
          await _api.secureStorage.write(key: 'user_id', value: userId);
          await _api.secureStorage.write(key: 'user_name', value: userName);
          await _api.secureStorage.write(key: 'user_role', value: userRole);

          if (mounted) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const CatalogScreen()),
              (route) => false,
            );
          }
          return;
        }
      }

      setState(() {
        _errorMessage = (data is Map<String, dynamic>)
            ? data['message']?.toString() ?? 'Login gagal. Format response tidak dikenali.'
            : 'Login gagal. Server mengembalikan response tidak valid.';
      });
    } on DioException catch (e) {
      setState(() {
        _errorMessage = ApiService.extractErrorMessage(
          e,
          fallback: 'Email atau password salah. Harap coba lagi.',
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
    _passwordController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  const SizedBox(height: HuashuTheme.space48),

                  // ─── Header dengan Stempel ───────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'MASUK\nPERAN',
                        style: Theme.of(context).textTheme.displayLarge,
                      ),
                      const HuashuSeal(character: '華'),
                    ],
                  ),

                  const SizedBox(height: HuashuTheme.space12),
                  Text(
                    'Selamat datang kembali di dunia seni.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),

                  const SizedBox(height: HuashuTheme.space48),

                  // ─── Error Message ───────────────────────────
                  if (_errorMessage != null) ...[
                    HuashuStatusBox(
                      message: _errorMessage!,
                      type: HuashuStatusType.error,
                    ),
                    const SizedBox(height: HuashuTheme.space24),
                  ],

                  // ─── Form Fields ─────────────────────────────
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
                      labelText: 'Kata Sandi (Password)',
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
                        return 'Password minimal terdiri dari 6 karakter';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: HuashuTheme.space12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
                        );
                      },
                      child: Text(
                        'Lupa Kata Sandi?',
                        style: GoogleFonts.inter(
                          color: HuashuTheme.charcoalBlack.withValues(alpha: 0.6),
                          decoration: TextDecoration.underline,
                          decorationColor: HuashuTheme.charcoalBlack.withValues(alpha: 0.3),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: HuashuTheme.space24),

                  // ─── Tombol Login ────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _login,
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('MASUK'),
                    ),
                  ),

                  const SizedBox(height: HuashuTheme.space24),

                  // ─── Link Register ──────────────────────────
                  Align(
                    alignment: Alignment.center,
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const RegisterScreen()),
                        );
                      },
                      child: Text(
                        'Belum memiliki akun? Daftarkan diri Anda',
                        style: GoogleFonts.inter(
                          color: HuashuTheme.charcoalBlack.withValues(alpha: 0.6),
                          decoration: TextDecoration.underline,
                          decorationColor: HuashuTheme.charcoalBlack.withValues(alpha: 0.3),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: HuashuTheme.space64),

                  // ─── Footer Watermark ───────────────────────
                  Center(
                    child: Text(
                      '— 華 書 —',
                      style: GoogleFonts.notoSerifSc(
                        fontSize: 14,
                        color: HuashuTheme.lightInkLine,
                        letterSpacing: 8,
                      ),
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
