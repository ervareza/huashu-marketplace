import 'package:flutter/material.dart';

class CartItem {
  final int id;
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
}

class CartManager {
  static final ValueNotifier<List<CartItem>> items = ValueNotifier<List<CartItem>>([]);

  static void add(CartItem newItem) {
    final list = List<CartItem>.from(items.value);
    final index = list.indexWhere((item) => item.id == newItem.id);

    if (index >= 0) {
      list[index].quantity += newItem.quantity;
    } else {
      list.add(newItem);
    }
    items.value = list;
  }

  static void remove(int id) {
    final list = List<CartItem>.from(items.value);
    list.removeWhere((item) => item.id == id);
    items.value = list;
  }

  static void clear() {
    items.value = [];
  }

  static double get totalAmount {
    return items.value.fold(0.0, (total, item) => total + (item.price * item.quantity));
  }
}
