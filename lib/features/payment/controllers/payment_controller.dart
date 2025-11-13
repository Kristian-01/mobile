import 'package:get/get.dart';

import '../../../common/widgets/loaders/loaders.dart';
import '../../../data/repository/authentication_repository/authentication_repository.dart';
import '../models/payment_model.dart';
import '../repositories/payment_repository.dart';

class PaymentController extends GetxController {
  static PaymentController get instance => Get.find();

  final RxBool isLoading = false.obs;
  final Rx<PaymentMethod> selectedPaymentMethod = PaymentMethod.cod.obs;
  final Rx<PaymentModel?> currentPayment = Rx<PaymentModel?>(null);
  final RxList<PaymentModel> paymentHistory = <PaymentModel>[].obs;

  final paymentRepository = Get.put(PaymentRepository());

  // NOTE: Payment method is FIXED to COD (Cash on Delivery) only.
  // Other payment methods are not supported.
  // Method selection is disabled.

  /// Process payment - COD (Cash on Delivery) ONLY
  Future<PaymentModel?> processPayment({
    required String orderId,
    required double amount,
  }) async {
    try {
      isLoading.value = true;

      // Only COD is supported
      final payment = await processCOD(orderId: orderId, amount: amount);

      currentPayment.value = payment;
      return payment;
    } catch (e) {
      TLoaders.errorSnackBar(title: 'Payment Error', message: e.toString());
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  /// Process Cash on Delivery
  Future<PaymentModel> processCOD({
    required String orderId,
    required double amount,
  }) async {
    try {
      final payment = await paymentRepository.processCODPayment(
        orderId: orderId,
        amount: amount,
      );

      TLoaders.successSnackBar(
        title: 'Order Placed',
        message: 'Your order will be delivered. Pay upon delivery.',
      );

      return payment;
    } catch (e) {
      throw 'Failed to process COD payment: $e';
    }
  }


  /// Fetch payment history
  Future<void> fetchPaymentHistory() async {
    try {
      isLoading.value = true;
      final payments = await paymentRepository.getUserPayments();
      paymentHistory.assignAll(payments);
    } catch (e) {
      TLoaders.errorSnackBar(title: 'Error', message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// Get payment for order
  Future<PaymentModel?> getPaymentForOrder(String orderId) async {
    try {
      return await paymentRepository.getPaymentByOrderId(orderId);
    } catch (e) {
      return null;
    }
  }

  /// Verify payment callback
  Future<void> verifyPayment(String paymentId, String transactionId) async {
    try {
      await paymentRepository.verifyPayment(paymentId, transactionId);
      TLoaders.successSnackBar(
        title: 'Payment Confirmed',
        message: 'Your payment has been verified!',
      );
    } catch (e) {
      TLoaders.errorSnackBar(title: 'Verification Failed', message: e.toString());
    }
  }

  /// Get payment method icon
  String getPaymentMethodIcon(PaymentMethod method) {
    return '💵'; // COD only
  }

  /// Get payment status color
  String getPaymentStatusColor(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.paid:
        return 'green';
      case PaymentStatus.pending:
      case PaymentStatus.processing:
        return 'orange';
      case PaymentStatus.failed:
      case PaymentStatus.cancelled:
        return 'red';
      case PaymentStatus.refunded:
        return 'blue';
    }
  }
}
