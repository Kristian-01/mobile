import 'package:cloud_firestore/cloud_firestore.dart';

/// Model class representing a product review
class ReviewModel {
  final String id;
  final String productId;
  final String userId;
  final String userName;
  final String? userImage;
  final double rating;
  final String? title;
  final String review;
  final List<String>? images;
  final bool isVerifiedPurchase;
  final int helpfulCount;
  final DateTime createdAt;
  final DateTime? updatedAt;

  ReviewModel({
    required this.id,
    required this.productId,
    required this.userId,
    required this.userName,
    this.userImage,
    required this.rating,
    this.title,
    required this.review,
    this.images,
    this.isVerifiedPurchase = false,
    this.helpfulCount = 0,
    required this.createdAt,
    this.updatedAt,
  });

  /// Empty helper function
  static ReviewModel empty() => ReviewModel(
        id: '',
        productId: '',
        userId: '',
        userName: '',
        rating: 0,
        review: '',
        createdAt: DateTime.now(),
      );

  /// Convert model to JSON structure for storing data in Firebase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'userId': userId,
      'userName': userName,
      'userImage': userImage,
      'rating': rating,
      'title': title,
      'review': review,
      'images': images,
      'isVerifiedPurchase': isVerifiedPurchase,
      'helpfulCount': helpfulCount,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  /// Factory method to create a ReviewModel from a Firebase document snapshot
  factory ReviewModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> document) {
    if (document.data() != null) {
      final data = document.data()!;
      return ReviewModel(
        id: document.id,
        productId: data['productId'] ?? '',
        userId: data['userId'] ?? '',
        userName: data['userName'] ?? '',
        userImage: data['userImage'],
        rating: (data['rating'] ?? 0).toDouble(),
        title: data['title'],
        review: data['review'] ?? '',
        images: data['images'] != null ? List<String>.from(data['images']) : null,
        isVerifiedPurchase: data['isVerifiedPurchase'] ?? false,
        helpfulCount: data['helpfulCount'] ?? 0,
        createdAt: (data['createdAt'] as Timestamp).toDate(),
        updatedAt: data['updatedAt'] != null ? (data['updatedAt'] as Timestamp).toDate() : null,
      );
    } else {
      return ReviewModel.empty();
    }
  }
}

/// Model for product rating summary
class ProductRatingSummary {
  final String productId;
  final double averageRating;
  final int totalReviews;
  final Map<int, int> ratingDistribution; // {5: 10, 4: 5, 3: 2, 2: 1, 1: 0}

  ProductRatingSummary({
    required this.productId,
    required this.averageRating,
    required this.totalReviews,
    required this.ratingDistribution,
  });

  factory ProductRatingSummary.fromReviews(String productId, List<ReviewModel> reviews) {
    if (reviews.isEmpty) {
      return ProductRatingSummary(
        productId: productId,
        averageRating: 0,
        totalReviews: 0,
        ratingDistribution: {5: 0, 4: 0, 3: 0, 2: 0, 1: 0},
      );
    }

    final distribution = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
    double totalRating = 0;

    for (var review in reviews) {
      totalRating += review.rating;
      distribution[review.rating.round()] = (distribution[review.rating.round()] ?? 0) + 1;
    }

    return ProductRatingSummary(
      productId: productId,
      averageRating: totalRating / reviews.length,
      totalReviews: reviews.length,
      ratingDistribution: distribution,
    );
  }
}
