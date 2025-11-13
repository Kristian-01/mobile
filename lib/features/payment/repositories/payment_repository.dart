import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../../../data/repository/authentication_repository/authentication_repository.dart';
import '../models/payment_model.dart';

class PaymentRepository extends GetxController {
  static PaymentRepository get instance => Get.find();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Create a payment record
  Future<void> createPayment(PaymentModel payment) async {
    try {
      await _db.collection('Payments').doc(payment.id).set(payment.toJson());
    } catch (e) {
      throw 'Failed to create payment: $e';
    }
  }

  /// Get payment by ID
  Future<PaymentModel> getPayment(String paymentId) async {
    try {
      final snapshot = await _db.collection('Payments').doc(paymentId).get();
      if (snapshot.exists) {
        return PaymentModel.fromSnapshot(snapshot);
      } else {
        throw 'Payment not found';
      }
    } catch (e) {
      throw 'Failed to fetch payment: $e';
    }
  }

  /// Get payment by order ID
  Future<PaymentModel?> getPaymentByOrderId(String orderId) async {
    try {
      final snapshot = await _db
          .collection('Payments')
          .where('orderId', isEqualTo: orderId)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return PaymentModel.fromSnapshot(snapshot.docs.first);
      }
      return null;
    } catch (e) {
      throw 'Failed to fetch payment: $e';
    }
  }

  /// Update payment status
  Future<void> updatePaymentStatus(
    String paymentId,
    PaymentStatus status, {
    String? transactionId,
    DateTime? paidAt,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'status': status.name,
      };

      if (transactionId != null) {
        updateData['transactionId'] = transactionId;
      }

      if (paidAt != null) {
        updateData['paidAt'] = paidAt;
      }

      await _db.collection('Payments').doc(paymentId).update(updateData);
    } catch (e) {
      throw 'Failed to update payment status: $e';
    }
  }

  /// Get user's payment history
  Future<List<PaymentModel>> getUserPayments() async {
    try {
      final userId = AuthenticationRepository.instance.firebaseUser!.uid;
      final snapshot = await _db
          .collection('Payments')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) => PaymentModel.fromSnapshot(doc)).toList();
    } catch (e) {
      throw 'Failed to fetch payment history: $e';
    }
  }

  /// Process COD payment (mark as pending, no actual payment)
  Future<PaymentModel> processCODPayment({
    required String orderId,
    required double amount,
  }) async {
    try {
      final userId = AuthenticationRepository.instance.firebaseUser!.uid;
      final payment = PaymentModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        orderId: orderId,
        userId: userId,
        paymentMethod: PaymentMethod.cod,
        status: PaymentStatus.pending,
        amount: amount,
        currency: 'PHP',
        referenceNumber: 'COD-${DateTime.now().millisecondsSinceEpoch}',
        createdAt: DateTime.now(),
      );

      await createPayment(payment);
      return payment;
    } catch (e) {
      throw 'Failed to process COD payment: $e';
    }
  }

  // NOTE: Only COD (Cash on Delivery) payment is supported.
  // Other payment methods (GCash, PayMaya, Card) have been removed.

  /// Verify payment (webhook callback)
  Future<void> verifyPayment(String paymentId, String transactionId) async {
    try {
      // TODO: Verify with payment provider
      await updatePaymentStatus(
        paymentId,
        PaymentStatus.paid,
        transactionId: transactionId,
        paidAt: DateTime.now(),
      );
    } catch (e) {
      throw 'Failed to verify payment: $e';
    }
  }
}
