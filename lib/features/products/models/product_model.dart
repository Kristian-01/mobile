import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cwt_starter_template/features/products/models/product_attribute_model.dart';
import 'package:cwt_starter_template/features/products/models/product_variation_model.dart';
import '../../dashboard/ecommerce/models/brand_model.dart';

class ProductModel {
  String id;
  int stock;
  String? sku;
  double price;
  String title;
  DateTime? date;
  double? salePrice;
  String thumbnail;
  bool? isFeatured;
  BrandModel? brand;
  String? description;
  String? categoryId;
  List<String>? images;
  String productType;
  List<ProductAttributeModel>? productAttributes;
  List<ProductVariationModel>? productVariations;

  ProductModel({
    required this.id,
    required this.title,
    required this.stock,
    required this.price,
    required this.thumbnail,
    required this.productType,
    this.sku,
    this.brand,
    this.date,
    this.images,
    this.salePrice,
    this.isFeatured,
    this.categoryId,
    this.description,
    this.productAttributes,
    this.productVariations,
  });

  /// Create Empty func for clean code
  static ProductModel empty() => ProductModel(id: '', title: '', stock: 0, price: 0, thumbnail: '', productType: '');

  /// Convert ProductModel to JSON for Firebase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'stock': stock,
      'price': price,
      'thumbnail': thumbnail,
      'productType': productType,
      'sku': sku,
      'salePrice': salePrice,
      'isFeatured': isFeatured,
      'categoryId': categoryId,
      'description': description,
      'images': images,
      'brand': brand?.toJson(),
      'productAttributes': productAttributes?.map((e) => e.toJson()).toList(),
      'productVariations': productVariations?.map((e) => e.toJson()).toList(),
      'date': date?.toIso8601String(),
    };
  }

  /// Create ProductModel from JSON
  static ProductModel fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      stock: json['stock'] ?? 0,
      price: (json['price'] ?? 0).toDouble(),
      thumbnail: json['thumbnail'] ?? '',
      productType: json['productType'] ?? '',
      sku: json['sku'],
      salePrice: json['salePrice'] != null ? (json['salePrice'] as num).toDouble() : null,
      isFeatured: json['isFeatured'],
      categoryId: json['categoryId'],
      description: json['description'],
      images: json['images'] != null ? List<String>.from(json['images']) : null,
      brand: json['brand'] != null ? BrandModel.fromJson(json['brand']) : null,
      productAttributes: json['productAttributes'] != null 
          ? (json['productAttributes'] as List).map((e) => ProductAttributeModel.fromJson(e)).toList() 
          : null,
      productVariations: json['productVariations'] != null 
          ? (json['productVariations'] as List).map((e) => ProductVariationModel.fromJson(e)).toList() 
          : null,
      date: json['date'] != null ? DateTime.parse(json['date']) : null,
    );
  }

  /// Create ProductModel from Firestore DocumentSnapshot
  factory ProductModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> document) {
    if (document.data() == null) return ProductModel.empty();
    final data = document.data()!;
    return ProductModel(
      id: document.id,
      title: data['title'] ?? '',
      stock: data['stock'] ?? 0,
      price: (data['price'] ?? 0).toDouble(),
      thumbnail: data['thumbnail'] ?? '',
      productType: data['productType'] ?? '',
      sku: data['sku'],
      salePrice: data['salePrice'] != null ? (data['salePrice'] as num).toDouble() : null,
      isFeatured: data['isFeatured'] ?? false,
      categoryId: data['categoryId'],
      description: data['description'],
      images: data['images'] != null ? List<String>.from(data['images']) : null,
      brand: data['brand'] != null ? BrandModel.fromJson(data['brand']) : null,
      date: data['date'] != null ? (data['date'] as Timestamp).toDate() : null,
      productAttributes: data['productAttributes'] != null
          ? (data['productAttributes'] as List).map((e) => ProductAttributeModel.fromJson(e)).toList()
          : null,
      productVariations: data['productVariations'] != null
          ? (data['productVariations'] as List).map((e) => ProductVariationModel.fromJson(e)).toList()
          : null,
    );
  }
}
