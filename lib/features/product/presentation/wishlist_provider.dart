import 'package:flutter/material.dart';
import '../../../core/network/api_service.dart';

class WishlistItem {
  final int id;
  final int productId;
  final String name;
  final String description;
  final double price;
  final String imageUrl;

  WishlistItem({
    required this.id,
    required this.productId,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
  });
}

class WishlistProvider extends ChangeNotifier {
  static final WishlistProvider _instance = WishlistProvider._internal();
  factory WishlistProvider() => _instance;
  WishlistProvider._internal();

  final ApiService _api = ApiService();
  
  List<WishlistItem> _items = [];
  List<WishlistItem> get items => _items;
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> fetchWishlist() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _api.dio.get('/api/wishlist');
      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> list = response.data['data'] ?? [];
        _items = list.map((item) {
          final product = item['product'] ?? {};
          return WishlistItem(
            id: item['id'],
            productId: item['product_id'],
            name: product['name']?.toString() ?? 'Produk',
            description: product['description']?.toString() ?? '',
            price: double.tryParse(product['price']?.toString() ?? '0') ?? 0,
            imageUrl: product['image_url']?.toString() ?? '',
          );
        }).toList();
      }
    } catch (e) {
      debugPrint("Gagal mengambil wishlist: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> toggleWishlist(int productId) async {
    final existingIndex = _items.indexWhere((item) => item.productId == productId);
    
    try {
      if (existingIndex >= 0) {
        // Remove
        final wishlistItemId = _items[existingIndex].id;
        final response = await _api.dio.delete('/api/wishlist/$wishlistItemId');
        if (response.statusCode == 200) {
          _items.removeAt(existingIndex);
          notifyListeners();
          return true;
        }
      } else {
        // Add
        final response = await _api.dio.post('/api/wishlist', data: {
          'product_id': productId,
        });
        if (response.statusCode == 200 || response.statusCode == 201) {
          await fetchWishlist();
          return true;
        }
      }
    } catch (e) {
      debugPrint("Gagal toggle wishlist: $e");
    }
    return false;
  }

  bool isWishlisted(int productId) {
    return _items.any((item) => item.productId == productId);
  }

  void clearLocal() {
    _items = [];
    notifyListeners();
  }
}
