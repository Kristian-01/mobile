import 'package:cloud_firestore/cloud_firestore.dart';

/// Payment method enum - COD only
enum PaymentMethod {
  cod('Cash on Delivery');

  final String displayName;
  const PaymentMethod(this.displayName);
}

/// Payment status enum
enum PaymentStatus {
  pending('Pending'),
  processing('Processing'),
  paid('Paid'),
  failed('Failed'),
  cancelled('Cancelled'),
  refunded('Refunded');

  final String displayName;
  const PaymentStatus(this.displayName);
}

/// Model class representing a payment transaction
class PaymentModel {
  final String id;
  final String orderId;
  final String userId;
  final PaymentMethod paymentMethod;
  final PaymentStatus status;
  final double amount;
  final String currency;
  final String? transactionId;
  final String? referenceNumber;
  final String? paymentUrl;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime? paidAt;
  final DateTime? expiresAt;

  PaymentModel({
    required this.id,
    required this.orderId,
    required this.userId,
    required this.paymentMethod,
    required this.status,
    required this.amount,
    this.currency = 'PHP',
    this.transactionId,
    this.referenceNumber,
    this.paymentUrl,
    this.metadata,
    required this.createdAt,
    this.paidAt,
    this.expiresAt,
  });

  /// Empty helper function
  static PaymentModel empty() => PaymentModel(
        id: '',
        orderId: '',
        userId: '',
        paymentMethod: PaymentMethod.cod,
        status: PaymentStatus.pending,
        amount: 0,
        createdAt: DateTime.now(),
      );

  /// Convert model to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderId': orderId,
      'userId': userId,
      'paymentMethod': paymentMethod.name,
      'status': status.name,
      'amount': amount,
      'currency': currency,
      'transactionId': transactionId,
      'referenceNumber': referenceNumber,
      'paymentUrl': paymentUrl,
      'metadata': metadata,
      'createdAt': createdAt,
      'paidAt': paidAt,
      'expiresAt': expiresAt,
    };
  }

  /// From Firestore snapshot
  factory PaymentModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> document) {
    if (document.data() != null) {
      final data = document.data()!;
      return PaymentModel(
        id: document.id,
        orderId: data['orderId'] ?? '',
        userId: data['userId'] ?? '',
        paymentMethod: PaymentMethod.values.firstWhere(
          (e) => e.name == data['paymentMethod'],
          orElse: () => PaymentMethod.cod,
        ),
        status: PaymentStatus.values.firstWhere(
          (e) => e.name == data['status'],
          orElse: () => PaymentStatus.pending,
        ),
        amount: (data['amount'] ?? 0).toDouble(),
        currency: data['currency'] ?? 'PHP',
        transactionId: data['transactionId'],
        referenceNumber: data['referenceNumber'],
        paymentUrl: data['paymentUrl'],
        metadata: data['metadata'],
        createdAt: (data['createdAt'] as Timestamp).toDate(),
        paidAt: data['paidAt'] != null ? (data['paidAt'] as Timestamp).toDate() : null,
        expiresAt: data['expiresAt'] != null ? (data['expiresAt'] as Timestamp).toDate() : null,
      );
    } else {
      return PaymentModel.empty();
    }
  }

  /// Copy with method
  PaymentModel copyWith({
    String? id,
    String? orderId,
    String? userId,
    PaymentMethod? paymentMethod,
    PaymentStatus? status,
    double? amount,
    String? currency,
    String? transactionId,
    String? referenceNumber,
    String? paymentUrl,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? paidAt,
    DateTime? expiresAt,
  }) {
    return PaymentModel(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      userId: userId ?? this.userId,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      transactionId: transactionId ?? this.transactionId,
      referenceNumber: referenceNumber ?? this.referenceNumber,
      paymentUrl: paymentUrl ?? this.paymentUrl,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      paidAt: paidAt ?? this.paidAt,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }

  /// Check if payment is completed
  bool get isCompleted => status == PaymentStatus.paid;

  /// Check if payment is pending
  bool get isPending => status == PaymentStatus.pending || status == PaymentStatus.processing;

  /// Check if payment failed
  bool get isFailed => status == PaymentStatus.failed || status == PaymentStatus.cancelled;
}
