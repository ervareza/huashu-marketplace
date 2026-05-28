import 'package:flutter/material.dart';
import '../../../core/network/api_service.dart';

class CartItem {
  final int id; // Cart item ID from API
  final int productId; // Actual product ID
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  int quantity;

  CartItem({
    required this.id,
    required this.productId,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.quantity = 1,
  });
}

class CartProvider extends ChangeNotifier {
  static final CartProvider _instance = CartProvider._internal();
  factory CartProvider() => _instance;
  CartProvider._internal();

  final ApiService _api = ApiService();
  
  List<CartItem> _items = [];
  List<CartItem> get items => _items;
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  double get totalAmount {
    return _items.fold(0.0, (total, item) => total + (item.price * item.quantity));
  }

  Future<void> fetchCart() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _api.dio.get('/api/cart');
      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> cartItems = response.data['data']['items'] ?? [];
        _items = cartItems.map((item) {
          final product = item['product'] ?? {};
          return CartItem(
            id: item['id'],
            productId: item['product_id'],
            name: product['name']?.toString() ?? 'Produk',
            description: product['description']?.toString() ?? '',
            price: double.tryParse(product['price']?.toString() ?? '0') ?? 0,
            imageUrl: product['image_url']?.toString() ?? '',
            quantity: item['quantity'] ?? 1,
          );
        }).toList();
      }
    } catch (e) {
      debugPrint("Gagal mengambil keranjang: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addToCart(int productId, int quantity) async {
    try {
      final response = await _api.dio.post('/api/cart', data: {
        'product_id': productId,
        'quantity': quantity,
      });
      if (response.statusCode == 200 || response.statusCode == 201) {
        await fetchCart();
        return true;
      }
    } catch (e) {
      debugPrint("Gagal tambah ke keranjang: $e");
    }
    return false;
  }

  Future<bool> updateQuantity(int cartItemId, int newQuantity) async {
    try {
      final response = await _api.dio.put('/api/cart/$cartItemId', data: {
        'quantity': newQuantity,
      });
      if (response.statusCode == 200) {
        await fetchCart();
        return true;
      }
    } catch (e) {
      debugPrint("Gagal update keranjang: $e");
    }
    return false;
  }

  Future<bool> remove(int cartItemId) async {
    try {
      final response = await _api.dio.delete('/api/cart/$cartItemId');
      if (response.statusCode == 200) {
        await fetchCart();
        return true;
      }
    } catch (e) {
      debugPrint("Gagal hapus keranjang: $e");
    }
    return false;
  }

  void clearLocal() {
    _items = [];
    notifyListeners();
  }
}
