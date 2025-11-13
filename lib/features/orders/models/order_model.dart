class OrderModel {
  final String id;
  final String userId;
  final double totalAmount;
  final String orderDate;
  final String paymentMethod;
  final String status; // pending, processing, shipped, delivered, cancelled
  final List<OrderItemModel> items;
  final AddressInfo deliveryAddress;
  final bool stockReduced;

  OrderModel({
    required this.id,
    required this.userId,
    required this.totalAmount,
    required this.orderDate,
    required this.paymentMethod,
    required this.status,
    required this.items,
    required this.deliveryAddress,
    this.stockReduced = false,
  });

  static OrderModel empty() => OrderModel(
        id: '',
        userId: '',
        totalAmount: 0.0,
        orderDate: '',
        paymentMethod: '',
        status: '',
        items: [],
        deliveryAddress: AddressInfo.empty(),
      );

  /// Convert OrderModel to JSON
  /// Note: 'id' is excluded because Firestore generates document IDs automatically
  Map<String, dynamic> toJson() {
    return {
      // Don't include 'id' - Firestore will generate it
      'userId': userId,
      'totalAmount': totalAmount,
      'orderDate': orderDate,
      'paymentMethod': paymentMethod,
      'status': status,
      'items': items.map((e) => e.toJson()).toList(),
      'deliveryAddress': deliveryAddress.toJson(),
      'stockReduced': stockReduced,
    };
  }

  /// Create OrderModel from JSON
  static OrderModel fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      orderDate: json['orderDate'] ?? '',
      paymentMethod: json['paymentMethod'] ?? '',
      status: json['status'] ?? '',
      items: (json['items'] as List? ?? [])
          .map((e) => OrderItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      deliveryAddress: AddressInfo.fromJson(
          json['deliveryAddress'] as Map<String, dynamic>? ?? {}),
      stockReduced: json['stockReduced'] ?? false,
    );
  }

  /// Create OrderModel from Firestore DocumentSnapshot
  factory OrderModel.fromSnapshot(dynamic document) {
    final data = document.data() as Map<String, dynamic>;
    return OrderModel(
      id: document.id, // Use Firestore document ID
      userId: data['userId'] ?? '',
      totalAmount: (data['totalAmount'] ?? 0).toDouble(),
      orderDate: data['orderDate'] ?? '',
      paymentMethod: data['paymentMethod'] ?? '',
      status: data['status'] ?? '',
      items: (data['items'] as List? ?? [])
          .map((e) => OrderItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      deliveryAddress: AddressInfo.fromJson(
          data['deliveryAddress'] as Map<String, dynamic>? ?? {}),
      stockReduced: data['stockReduced'] ?? false,
    );
  }
}

class OrderItemModel {
  final String productId;
  final String productName;
  final String productImage;
  final int quantity;
  final double price;

  OrderItemModel({
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.quantity,
    required this.price,
  });

  /// Convert OrderItemModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'productImage': productImage,
      'quantity': quantity,
      'price': price,
    };
  }

  /// Create OrderItemModel from JSON
  static OrderItemModel fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      productId: json['productId'] ?? '',
      productName: json['productName'] ?? '',
      productImage: json['productImage'] ?? '',
      quantity: json['quantity'] ?? 0,
      price: (json['price'] ?? 0).toDouble(),
    );
  }
}

class AddressInfo {
  final String name;
  final String phone;
  final String address;

  AddressInfo({
    required this.name,
    required this.phone,
    required this.address,
  });

  static AddressInfo empty() => AddressInfo(name: '', phone: '', address: '');

  /// Convert AddressInfo to JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      'address': address,
    };
  }

  /// Create AddressInfo from JSON
  static AddressInfo fromJson(Map<String, dynamic> json) {
    return AddressInfo(
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
    );
  }
}
