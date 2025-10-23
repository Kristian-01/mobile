

class CartItemModel {
  int quantity;
  String productId;
  String variationId;
  double? price;
  String? image;
  String? title;
  String? brandName;
  Map<String, String>? selectedVariation;

  CartItemModel({
    required this.quantity,
    required this.productId,
    required this.variationId,
    this.image,
    this.price,
    this.title,
    this.brandName,
    this.selectedVariation,
  });

  static CartItemModel empty() => CartItemModel(productId: '', variationId: '', quantity: 0);

  /// Convert model to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'quantity': quantity,
      'productId': productId,
      'variationId': variationId,
      'price': price,
      'image': image,
      'title': title,
      'brandName': brandName,
      'selectedVariation': selectedVariation,
    };
  }

  /// Create model from JSON
  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      quantity: json['quantity'] ?? 0,
      productId: json['productId'] ?? '',
      variationId: json['variationId'] ?? '',
      price: json['price']?.toDouble(),
      image: json['image'],
      title: json['title'],
      brandName: json['brandName'],
      selectedVariation: json['selectedVariation'] != null
          ? Map<String, String>.from(json['selectedVariation'])
          : null,
    );
  }
}
