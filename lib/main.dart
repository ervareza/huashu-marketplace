import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'core/theme/huashu_theme.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/product/presentation/catalog_screen.dart';
import 'core/network/global_socket_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Marketplace Huashu',
      theme: HuashuTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: const SessionCheckScreen(),
    );
  }
}

class SessionCheckScreen extends StatefulWidget {
  const SessionCheckScreen({super.key});

  @override
  State<SessionCheckScreen> createState() => _SessionCheckScreenState();
}

class _SessionCheckScreenState extends State<SessionCheckScreen> {
  final _secureStorage = const FlutterSecureStorage();
  bool _checking = true;
  bool _hasSession = false;

  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    final token = await _secureStorage.read(key: 'access_token');
    if (token != null) {
      await GlobalSocketService().initSocket();
    }
    setState(() {
      _hasSession = token != null;
      _checking = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: HuashuTheme.mineralJadeGreen),
        ),
      );
    }
    return _hasSession ? const CatalogScreen() : const LoginScreen();
  }
}
