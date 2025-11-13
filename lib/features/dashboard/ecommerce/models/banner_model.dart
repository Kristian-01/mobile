import 'package:cloud_firestore/cloud_firestore.dart';

class BannerModel {
  final String id;
  final String imageUrl;
  final String title;
  final String? subtitle;
  final String? targetScreen;
  final String? categoryId;
  final String? productId;
  final bool isActive;
  final int order;

  BannerModel({
    required this.id,
    required this.imageUrl,
    required this.title,
    this.subtitle,
    this.targetScreen,
    this.categoryId,
    this.productId,
    this.isActive = true,
    this.order = 0,
  });

  /// Empty model
  static BannerModel empty() => BannerModel(
    id: '',
    imageUrl: '',
    title: '',
    isActive: false,
  );

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'imageUrl': imageUrl,
      'title': title,
      'subtitle': subtitle,
      'targetScreen': targetScreen,
      'categoryId': categoryId,
      'productId': productId,
      'isActive': isActive,
      'order': order,
    };
  }

  /// Create from Firestore document
  factory BannerModel.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return BannerModel(
      id: snapshot.id,
      imageUrl: data['imageUrl'] ?? '',
      title: data['title'] ?? '',
      subtitle: data['subtitle'],
      targetScreen: data['targetScreen'],
      categoryId: data['categoryId'],
      productId: data['productId'],
      isActive: data['isActive'] ?? true,
      order: data['order'] ?? 0,
    );
  }

  /// Create from JSON
  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['id'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      title: json['title'] ?? '',
      subtitle: json['subtitle'],
      targetScreen: json['targetScreen'],
      categoryId: json['categoryId'],
      productId: json['productId'],
      isActive: json['isActive'] ?? true,
      order: json['order'] ?? 0,
    );
  }
}
