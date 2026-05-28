import 'package:flutter/material.dart';

class CartItem {
  final dynamic id; // API bisa kirim int atau String
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  int quantity;

  CartItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.quantity = 1,
  });

  /// Bandingkan ID secara aman (handle int vs String)
  bool matchesId(dynamic otherId) {
    return id.toString() == otherId.toString();
  }
}

class CartManager {
  static final ValueNotifier<List<CartItem>> items = ValueNotifier<List<CartItem>>([]);

  static void add(CartItem newItem) {
    final list = List<CartItem>.from(items.value);
    final index = list.indexWhere((item) => item.matchesId(newItem.id));

    if (index >= 0) {
      list[index].quantity += newItem.quantity;
    } else {
      list.add(newItem);
    }
    items.value = list;
  }

  static void remove(dynamic id) {
    final list = List<CartItem>.from(items.value);
    list.removeWhere((item) => item.matchesId(id));
    items.value = list;
  }

  static void clear() {
    items.value = [];
  }

  static double get totalAmount {
    return items.value.fold(0.0, (total, item) => total + (item.price * item.quantity));
  }
}
