import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'global_socket_service.dart';
import '../../features/order/presentation/cart_provider.dart';
import '../../features/product/presentation/wishlist_provider.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../theme/huashu_theme.dart';

final GlobalKey<NavigatorState> globalNavigatorKey = GlobalKey<NavigatorState>();

class AuthHelper {
  static Future<void> forceLogoutAndRedirect([String reason = '']) async {
    const storage = FlutterSecureStorage();
    await storage.deleteAll();
    
    // Clear Providers
    CartProvider().clearLocal();
    WishlistProvider().clearLocal();

    // Disconnect Socket
    GlobalSocketService().disposeSocket();

    final ctx = globalNavigatorKey.currentContext;
    if (ctx == null) return;

    if (reason.isNotEmpty) {
      ScaffoldMessenger.of(ctx).showSnackBar(
        SnackBar(
          content: Text(reason),
          backgroundColor: HuashuTheme.stainedCinnabarRed,
        )
      );
    }
    Navigator.of(ctx).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }
}
