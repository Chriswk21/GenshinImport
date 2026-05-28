import 'package:flutter/material.dart';
import '../models/item.dart';
import '../services/api_service.dart';

class CartItem {
  final Item item;
  int quantity;

  CartItem({required this.item, required this.quantity});
}

class CartProvider extends ChangeNotifier {
  final Map<int, CartItem> _items = {};
  bool _isCheckingOut = false;
  String? _checkoutError;

  Map<int, CartItem> get items => {..._items};
  bool get isCheckingOut => _isCheckingOut;
  String? get checkoutError => _checkoutError;

  int get totalItemsCount {
    return _items.values.fold(0, (sum, cartItem) => sum + cartItem.quantity);
  }

  double get totalAmount {
    return _items.values.fold(
      0.0,
      (sum, cartItem) => sum + (cartItem.item.price * cartItem.quantity),
    );
  }

  
  String? addItem(Item item, int quantity) {
    if (quantity <= 0) {
      return 'Quantity must be at least 1.';
    }

    if (item.stock == 0) {
      return 'Sorry, "${item.name}" is completely out of stock.';
    }

    if (_items.containsKey(item.id)) {
      final existingQty = _items[item.id]!.quantity;
      final newQty = existingQty + quantity;
      
      if (newQty > item.stock) {
        return 'Cannot add more. Stock limit reached. You have $existingQty in cart. Remaining stock: ${item.stock}.';
      }
      
      _items[item.id]!.quantity = newQty;
    } else {
      if (quantity > item.stock) {
        return 'Cannot add $quantity. Available stock: ${item.stock}.';
      }
      _items[item.id] = CartItem(item: item, quantity: quantity);
    }
    
    notifyListeners();
    return null; 
  }

  
  String? updateQuantity(int itemId, int quantity) {
    if (!_items.containsKey(itemId)) return 'Item not in cart.';

    if (quantity <= 0) {
      removeItem(itemId);
      return null;
    }

    final item = _items[itemId]!.item;
    if (quantity > item.stock) {
      return 'Cannot update quantity. Available stock: ${item.stock}.';
    }

    _items[itemId]!.quantity = quantity;
    notifyListeners();
    return null;
  }

  
  void removeItem(int itemId) {
    _items.remove(itemId);
    notifyListeners();
  }

  
  void clearCart() {
    _items.clear();
    _checkoutError = null;
    notifyListeners();
  }

  
  Future<bool> checkout(String token) async {
    if (_items.isEmpty) {
      _checkoutError = 'Your cart is empty.';
      notifyListeners();
      return false;
    }

    _isCheckingOut = true;
    _checkoutError = null;
    notifyListeners();

    
    final cartPayload = _items.values.map((cartItem) {
      return {
        'id': cartItem.item.id,
        'quantity': cartItem.quantity
      };
    }).toList();

    final result = await ApiService.buyItems(token, cartPayload);

    _isCheckingOut = false;
    if (result['success'] == true) {
      _items.clear();
      notifyListeners();
      return true;
    } else {
      _checkoutError = result['message'] ?? 'Checkout failed.';
      notifyListeners();
      return false;
    }
  }
}
