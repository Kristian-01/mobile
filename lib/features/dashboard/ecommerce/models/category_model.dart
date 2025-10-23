import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryModel {
  String id;
  String name;
  String image;
  String? parentId;
  bool? isFeatured;

  CategoryModel({
    required this.id,
    required this.name,
    required this.image,
    this.parentId,
    this.isFeatured,
  });

  static CategoryModel empty() => CategoryModel(id: '', image: '', name: '');

  /// Convert CategoryModel to JSON for Firebase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'parentId': parentId,
      'isFeatured': isFeatured,
    };
  }

  /// Create CategoryModel from JSON
  static CategoryModel fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      image: json['image'] ?? '',
      parentId: json['parentId'],
      isFeatured: json['isFeatured'],
    );
  }

  /// Create CategoryModel from Firestore DocumentSnapshot
  factory CategoryModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data()!;
    return CategoryModel.fromJson(data);
  }
}
