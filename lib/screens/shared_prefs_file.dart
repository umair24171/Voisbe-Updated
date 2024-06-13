// import 'dart:convert';

// import 'package:shared_preferences/shared_preferences.dart';

// class SharedPrefs {
//   // SharedPreferences prefs =awa SharedPreferences.getInstance()

//   List<CartItem> cartItems = [];
//   String key = 'cartKey';

//   Future<void> _saveCart() async {
//     final prefs = await SharedPreferences.getInstance();
//     final cartData = cartItems.map((item) => jsonEncode(item.toMap())).toList();
//     await prefs.setStringList(key, cartData);
//   }

//   addToCart(CartItem newItem) async {
//     final existingIndex = cartItems.indexWhere((item) => item.id == newItem.id);
//     if (existingIndex != -1) {
//       cartItems[existingIndex].quantity += newItem.quantity;
//     } else {
//       cartItems.add(newItem);
//     }
//     _saveCart();
//   }

//   void _loadCart() async {
//     final prefs = await SharedPreferences.getInstance();
//     final cartData = prefs.getStringList(key);

//     cartItems =
//         cartData?.map((item) => CartItem.fromMap(jsonDecode(item))).toList() ??
//             [];
//   }

//   void clearCart() {
//     cartItems = [];
//     _saveCart();
//   }

//   void removeFromCart(String itemId) {
//     cartItems.removeWhere((item) => item.id == itemId);
//     _saveCart();
//   }
// }

// class CartItem {
//   final String id;
//   final String productName;
//   int quantity;

//   CartItem({required this.id, required this.productName, this.quantity = 1});

//   Map<String, dynamic> toMap() {
//     return {
//       'id': id,
//       'productName': productName,
//       'quantity': quantity,
//     };
//   }

//   factory CartItem.fromMap(Map<String, dynamic> map) {
//     return CartItem(
//       id: map['id'],
//       productName: map['productName'],
//       quantity: map['quantity'],
//     );
//   }
// }
