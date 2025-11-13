import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../../../data/repository/authentication_repository/authentication_repository.dart';
import '../../../utils/local_storage/storage_utility.dart';
import '../../products/models/product_model.dart';
import '../../products/models/product_variation_model.dart';
import '../models/cart_item_model.dart';

class CartController extends GetxController {
  static CartController get instance => Get.find();

  RxList<CartItemModel> cartItems = <CartItemModel>[].obs;
  RxDouble totalCartPrice = 0.0.obs;
  RxBool isLoading = false.obs;

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _cartStorageKey = 'user_cart';

  // RxMap<String, int> productQuantities = <String, int>{}.obs; // Use to count each product quantity [ID: quantity]

  /// -- Initialize and load saved cart
  @override
  void onInit() {
    super.onInit();
    loadCart();
  }

  void addSingleItemToCart(ProductModel product, ProductVariationModel variation) {
    // Check if product is out of stock
    if (product.stock <= 0) {
      Get.snackbar(
        'Out of Stock',
        'Sorry, ${product.title} is currently out of stock',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
      return;
    }

    // If the product is already added then increment the count else add new product
    final cartItem = cartItems.firstWhere(
      (item) => item.productId == product.id && item.variationId == variation.id,
      orElse: () => CartItemModel(
        productId: product.id,
        variationId: variation.id,
        quantity: 0,
        title: product.title,
        image: product.thumbnail,
        price: product.salePrice ?? product.price,
        brandName: product.brand?.name ?? 'Nine27Pharmacy',
      ),
    );

    // Check if adding one more exceeds available stock
    if (cartItem.quantity >= product.stock) {
      Get.snackbar(
        'Stock Limit Reached',
        'Only ${product.stock} items available in stock',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
      return;
    }

    // If its a new product then add it to the cart.
    if (cartItem.quantity == 0) {
      cartItems.add(cartItem);
    }

    // Increment Cart
    cartItem.quantity += 1;
    // Increment Total Cart Price
    totalCartPrice.value += calculateSingleProductTotal(product.price, 1);
    // Increment Product Quantities
    // productQuantities[product.id] = (productQuantities[product.id] ?? 0) + 1;

    // Must use .refresh() when list or Modal is Observable to change UI
    cartItems.refresh();
    
    // Auto-save cart after modification
    saveCart();
  }

  void addMultipleItemsToCart(ProductModel product, ProductVariationModel variation, int quantity) {
    // Determine available stock (use variation stock if it has variation, otherwise product stock)
    final availableStock = variation.id.isNotEmpty ? variation.stock : product.stock;
    
    // Check if product/variation is out of stock
    if (availableStock <= 0) {
      Get.snackbar(
        'Out of Stock',
        'Sorry, ${product.title} is currently out of stock',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
      return;
    }
    
    // Check if requested quantity exceeds available stock
    if (quantity > availableStock) {
      Get.snackbar(
        'Stock Limit Exceeded',
        'Only ${availableStock} items available in stock',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
      return;
    }

    // If the product is already added then increment the count else add new product
    final cartItem = cartItems.firstWhere(
      (item) => item.productId == product.id && item.variationId == variation.id,
      orElse: () => CartItemModel(
        productId: product.id,
        variationId: variation.id,
        quantity: 0,
        title: product.title,
        image: variation.id.isEmpty ? product.thumbnail : variation.image,
        price: variation.id.isEmpty ? product.salePrice ?? product.price : variation.salePrice ?? variation.price,
        brandName: product.brand?.name ?? 'Nine27Pharmacy',
        selectedVariation: variation.id.isNotEmpty ? variation.attributeValues : null,
      ),
    );

    // If its a new product Simply add quantity
    if (cartItem.quantity == 0) {
      // Increment Cart
      cartItem.quantity = quantity;
      cartItems.add(cartItem);
      // Increment Total Cart Price
      totalCartPrice.value += calculateSingleProductTotal(product.price, quantity);
      // Increment Product Quantities
      // productQuantities[product.id] = quantity;
    } else {
      // Check if you need to remove or add items to the cart
      if (cartItem.quantity > quantity) {
        // Subtract
        totalCartPrice.value -= calculateSingleProductTotal(cartItem.price!, quantity);
        // Set the new quantity of productQuantities
        // if (productQuantities.containsKey(product.id)) {
        //   productQuantities[product.id] = (productQuantities[product.id] ?? 0) - quantity;
        // }
      } else {
        // Increment
        totalCartPrice.value += calculateSingleProductTotal(product.price, quantity);
        // if (productQuantities.containsKey(product.id)) {
        //   productQuantities[product.id] = (productQuantities[product.id] ?? 0) + quantity;
        // }
      }

      cartItem.quantity = quantity;
    }

    // Must use .refresh() when list or Modal is Observable to change UI
    cartItems.refresh();
    
    // Auto-save cart after modification
    saveCart();
  }

  void removeItemFromCart(CartItemModel cartItem) {
    Get.defaultDialog(
      title: 'Remove Product',
      middleText: 'Are you sure you want to remove this product?',
      onConfirm: () {
        // Remove the item from the cart
        cartItems.remove(cartItem);
        // Remove that product from the Product Quantities.
        // productQuantities.remove(cartItem.productId);
        // Remove the price from the total
        totalCartPrice.value -= calculateSingleProductTotal(cartItem.price!, cartItem.quantity);
        cartItems.refresh();
        
        // Auto-save cart after removal
        saveCart();
        
        Get.back();
      },
      barrierDismissible: true,
    );
  }

  void updateCartItemQuantity(CartItemModel cartItem, int newQuantity) {
    if (newQuantity.isEqual(0)) {
      removeItemFromCart(cartItem);
    } else {
      // If new Quantity is greater means add & if less then [cartItem.quantity] means subtract
      if (cartItem.quantity < newQuantity) {
        // Add
        totalCartPrice.value += calculateSingleProductTotal(cartItem.price!, 1);
        // Increment the quantity in the product Quantities
        // productQuantities[cartItem.productId] = (productQuantities[cartItem.productId] ?? 0) + 1;
      } else if (cartItem.quantity > newQuantity) {
        // Subtract
        totalCartPrice.value -= calculateSingleProductTotal(cartItem.price!, 1);
        // Decrement the quantity from the product Quantities
        // if (productQuantities.containsKey(cartItem.productId)) {
        //   // productQuantities[cartItem.productId] = (productQuantities[cartItem.productId] ?? 0) - 1;
        // }
      }
      cartItem.quantity = newQuantity;
      cartItems.refresh();
      
      // Auto-save cart after quantity update
      saveCart();
    }
  }

  double calculateSingleProductTotal(double productPrice, int quantity) {
    return productPrice * quantity;
  }

  String calculateTotalCartItems() {
    return cartItems
        .map((element) => element.quantity)
        .fold(0, (previousValue, element) => previousValue + element)
        .toString();
  }

  int calculateSingleProductCartEntries(String productId, String variationId) {
    int cartEntries = 0;

    // If variation is not null get variation total
    if (variationId.isEmpty) {
      cartEntries = cartItems
          .where((item) => item.productId == productId)
          .map((e) => e.quantity)
          .fold(0, (previousQuantity, nextQuantity) => previousQuantity + nextQuantity);
    } else {
      cartEntries = cartItems
          .where((item) => item.productId == productId && item.variationId == variationId)
          .map((e) => e.quantity)
          .fold(0, (previousQuantity, nextQuantity) => previousQuantity + nextQuantity);
    }

    return cartEntries;
  }

  /// Clear all items from cart
  void clearCart() {
    cartItems.clear();
    totalCartPrice.value = 0.0;
    saveCart(); // Save the empty cart
  }

  // ==================== CART PERSISTENCE METHODS ====================

  /// Load cart from local storage and Firestore (Hybrid approach)
  Future<void> loadCart() async {
    try {
      isLoading.value = true;

      // 1. Try to load from LOCAL STORAGE first (Fast, offline-capable)
      final localData = TLocalStorage.instance().readData<List>(_cartStorageKey);
      if (localData != null && localData.isNotEmpty) {
        cartItems.value = localData
            .map((item) => CartItemModel.fromJson(Map<String, dynamic>.from(item)))
            .toList();
        _recalculateTotalPrice();
      }

      // 2. Try to load from FIRESTORE (Cloud backup, sync across devices)
      final userId = AuthenticationRepository.instance.getUserID;
      if (userId.isNotEmpty) {
        final cartDoc = await _db.collection('Carts').doc(userId).get();
        
        if (cartDoc.exists) {
          final cloudData = cartDoc.data();
          if (cloudData != null && cloudData['items'] != null) {
            final cloudItems = (cloudData['items'] as List)
                .map((item) => CartItemModel.fromJson(Map<String, dynamic>.from(item)))
                .toList();
            
            // Merge cloud cart with local cart (cloud takes precedence if newer)
            if (cloudItems.isNotEmpty) {
              cartItems.value = cloudItems;
              _recalculateTotalPrice();
              // Update local storage with cloud data
              await _saveToLocalStorage();
            }
          }
        }
      }
    } catch (e) {
      print('Error loading cart: \$e');
      // If error, keep whatever is in cartItems (could be empty or from local)
    } finally {
      isLoading.value = false;
    }
  }

  /// Save cart to both local storage and Firestore
  Future<void> saveCart() async {
    try {
      // 1. Save to LOCAL STORAGE (Fast, always works)
      await _saveToLocalStorage();

      // 2. Save to FIRESTORE (Cloud backup, requires auth)
      await _saveToFirestore();
    } catch (e) {
      print('Error saving cart: \$e');
    }
  }

  /// Save to local storage (Private, per-user)
  Future<void> _saveToLocalStorage() async {
    try {
      final cartJson = cartItems.map((item) => item.toJson()).toList();
      await TLocalStorage.instance().writeData(_cartStorageKey, cartJson);
    } catch (e) {
      print('Error saving to local storage: \$e');
    }
  }

  /// Save to Firestore (Cloud backup, user-isolated)
  Future<void> _saveToFirestore() async {
    try {
      final userId = AuthenticationRepository.instance.getUserID;
      if (userId.isEmpty) return; // Not logged in, skip cloud save

      final cartJson = cartItems.map((item) => item.toJson()).toList();
      
      await _db.collection('Carts').doc(userId).set({
        'items': cartJson,
        'totalPrice': totalCartPrice.value,
        'itemCount': cartItems.length,
        'lastUpdated': FieldValue.serverTimestamp(),
        'userId': userId, // For security rules
      });
    } catch (e) {
      print('Error saving to Firestore: \$e');
      // Don't throw - local storage already saved
    }
  }

  /// Recalculate total price from cart items
  void _recalculateTotalPrice() {
    totalCartPrice.value = cartItems
        .map((e) => calculateSingleProductTotal(e.price ?? 0, e.quantity))
        .fold(0, (previous, current) => previous + current);
  }
}
