import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/repository/authentication_repository/authentication_repository.dart';
import '../../../personalization/controllers/address_controller.dart';
import '../../../utils/constants/image_strings.dart';
import '../../cart/controllers/cart_controller.dart';
import '../../orders/controllers/order_controller.dart';
import '../../orders/models/order_model.dart';
import '../models/payment_method_model.dart';
import '../screens/order_success_screen.dart';

class CheckoutController extends GetxController {
  static CheckoutController get instance => Get.find();

  final Rx<PaymentMethodModel> selectedPaymentMethod = PaymentMethodModel.empty().obs;


  @override
  void onInit() {
    // Set default payment method to COD (Cash on Delivery)
    // This is the ONLY payment method supported
    selectedPaymentMethod.value = PaymentMethodModel(name: 'Cash on Delivery', image: TImages.creditCard);
    super.onInit();
  }

  // NOTE: Payment method selection is disabled.
  // Only COD (Cash on Delivery) is available.
  // GCash, PayMaya, and Card payments are NOT supported.

  /// Reduce product stock after order is placed
  Future<void> _reduceProductStock(List<OrderItemModel> orderItems) async {
    try {
      final db = FirebaseFirestore.instance;
      
      for (var item in orderItems) {
        if (item.productId.isEmpty || item.quantity <= 0) continue;
        
        try {
          // Get current product stock
          final productDoc = await db.collection('Products').doc(item.productId).get();
          
          if (!productDoc.exists) {
            print('❌ Product ${item.productId} not found');
            continue;
          }
          
          final productData = productDoc.data();
          final currentStock = (productData?['stock'] ?? 0) as int;
          final newStock = (currentStock - item.quantity).clamp(0, double.infinity).toInt();
          
          // Update product stock
          await db.collection('Products').doc(item.productId).update({
            'stock': newStock,
          });
          
          print('✅ Reduced stock for ${item.productName}: $currentStock → $newStock (qty: ${item.quantity})');
        } catch (e) {
          print('❌ Error reducing stock for ${item.productId}: $e');
          // Continue with other items even if one fails
        }
      }
    } catch (e) {
      print('❌ Error in _reduceProductStock: $e');
      // Don't throw - order was already placed successfully
    }
  }

  /// Process Checkout - Handle order placement
  Future<void> processCheckout(double totalAmount) async {
    try {
      // Get cart and address controllers
      final cartController = CartController.instance;
      final addressController = AddressController.instance;

      // Validation 1: Check if cart has products
      if (cartController.cartItems.isEmpty) {
        Get.snackbar(
          'Cart is Empty',
          'Please add products to your cart before checkout',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        return;
      }

      // Validation 2: Check if address is selected
      if (addressController.selectedAddress.value.id.isEmpty) {
        Get.snackbar(
          'No Address Selected',
          'Please add and select a delivery address before checkout',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        return;
      }

      // Show loading
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      // Process order
      Future.delayed(const Duration(seconds: 1), () async {
        // Get user ID first and log it
        final userId = AuthenticationRepository.instance.getUserID;
        print('🆔 Creating order for user: $userId');
        
        if (userId.isEmpty) {
          Get.back(); // Close loading
          Get.snackbar(
            'Error',
            'User not logged in. Please log in and try again.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          return;
        }
        
        // Create order items from cart
        final orderItems = cartController.cartItems.map((cartItem) {
          return OrderItemModel(
            productId: cartItem.productId ?? '',
            productName: cartItem.title ?? '',
            productImage: cartItem.image ?? '',
            quantity: cartItem.quantity,
            price: cartItem.price ?? 0.0,
          );
        }).toList();
        
        print('📦 Creating order with ${orderItems.length} items');

        // Create new order (Firebase will generate ID)
        final newOrder = OrderModel(
          id: '', // Firebase will generate this
          userId: userId,
          totalAmount: totalAmount,
          orderDate: DateTime.now().toIso8601String(), // Full timestamp for sorting
          paymentMethod: selectedPaymentMethod.value.name,
          status: 'pending', // Start as pending until desktop confirms
          items: orderItems,
          deliveryAddress: AddressInfo(
            name: addressController.selectedAddress.value.name,
            phone: addressController.selectedAddress.value.phoneNumber,
            address: addressController.selectedAddress.value.toString(),
          ),
          stockReduced: true, // Mark that stock will be reduced by mobile app
        );
        
        print('📝 Order details: userId=$userId, total=₱$totalAmount, items=${orderItems.length}');

        // Add order to Firebase via order controller and get the generated ID
        final orderController = Get.put(OrderController());
        print('🚀 Saving order to Firebase...');
        final orderId = await orderController.addOrder(newOrder);
        
        if (orderId == null || orderId.isEmpty) {
          Get.back(); // Close loading
          Get.snackbar(
            'Error',
            'Failed to create order. Please try again.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          return;
        }
        
        print('✅ Order created with ID: $orderId');

        // 🔔 Create a notification for order placed (pending)
        try {
          await FirebaseFirestore.instance.collection('Notifications').add({
            'title': 'Order Placed',
            'body': 'Your order $orderId was placed and is now pending.',
            'senderId': userId,
            'recipientIds': [userId],
            'type': 'order_pending',
            'createdAt': FieldValue.serverTimestamp(),
            'seenBy': {},
            'route': '/orders-screen',
            'routeId': orderId,
            'isBroadcast': false,
          });
          print('✅ Order placed notification created');
        } catch (e) {
          print('⚠️ Failed to create order placed notification: $e');
        }

        // Reduce stock for each product in the order
        print('📉 Reducing stock for ${orderItems.length} products...');
        await _reduceProductStock(orderItems);

        // Clear cart
        print('🧹 Clearing cart...');
        cartController.clearCart();

        // Close loading
        Get.back();
        
        print('🎉 Order placement complete! Navigating to success screen...');
        
        // Navigate to Order Success Screen with the actual order ID
        Get.off(() => OrderSuccessScreen(
          orderId: orderId,
          totalAmount: totalAmount,
        ));
      });
    } catch (e) {
      Get.back();
      Get.snackbar(
        'Error',
        'Failed to place order. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
