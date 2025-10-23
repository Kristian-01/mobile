import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../common/widgets/texts/section_heading.dart';
import '../../../data/repository/authentication_repository/authentication_repository.dart';
import '../../../personalization/controllers/address_controller.dart';
import '../../../utils/constants/image_strings.dart';
import '../../../utils/constants/sizes.dart';
import '../../cart/controllers/cart_controller.dart';
import '../../orders/controllers/order_controller.dart';
import '../../orders/models/order_model.dart';
import '../models/payment_method_model.dart';
import '../screens/order_success_screen.dart';
import '../screens/widgets/payment_tile.dart';

class CheckoutController extends GetxController {
  static CheckoutController get instance => Get.find();

  final Rx<PaymentMethodModel> selectedPaymentMethod = PaymentMethodModel.empty().obs;


  @override
  void onInit() {
    selectedPaymentMethod.value = PaymentMethodModel(name: 'Cash on Delivery', image: TImages.creditCard);
    super.onInit();
  }

  Future<dynamic> selectPaymentMethod(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      builder: (_) => SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(TSizes.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const TSectionHeading(title: 'Select Payment Method', showActionButton: false),
              const SizedBox(height: TSizes.spaceBtwSections),
              TPaymentTile(paymentMethod: PaymentMethodModel(name: 'Cash on Delivery', image: TImages.creditCard)),
              const SizedBox(height: TSizes.spaceBtwItems/2),
              const SizedBox(height: TSizes.spaceBtwSections),
            ],
          ),
        ),
      ),
    );
  }

  /// Process Checkout - Handle order placement
  Future<void> processCheckout(double totalAmount) async {
    try {
      // Get cart and address controllers
      final cartController = CartController.instance;
      final addressController = AddressController.instance;

      // Show loading
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      // Process order
      Future.delayed(const Duration(seconds: 1), () async {
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

        // Create new order (Firebase will generate ID)
        final newOrder = OrderModel(
          id: '', // Firebase will generate this
          userId: AuthenticationRepository.instance.getUserID,
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
        );

        // Add order to Firebase via order controller
        final orderController = Get.put(OrderController());
        await orderController.addOrder(newOrder);

        // Clear cart
        cartController.clearCart();

        // Close loading
        Get.back();
        
        // Navigate to Order Success Screen
        Get.off(() => OrderSuccessScreen(
          orderId: newOrder.id,
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
