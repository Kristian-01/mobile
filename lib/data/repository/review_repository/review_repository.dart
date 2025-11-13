import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../../../features/products/models/review_model.dart';
import '../../abstract/base_repository.dart';
import '../authentication_repository/authentication_repository.dart';

class ReviewRepository extends TBaseRepositoryController<ReviewModel> {
  static ReviewRepository get instance => Get.find();

  final String _collectionPath = 'ProductReviews';

  @override
  Future<List<ReviewModel>> fetchAllItems() async {
    final snapshot = await db
        .collection(_collectionPath)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs.map((doc) => ReviewModel.fromSnapshot(doc)).toList();
  }

  @override
  Future<ReviewModel> fetchSingleItem(String id) async {
    final snapshot = await db.collection(_collectionPath).doc(id).get();
    return ReviewModel.fromSnapshot(snapshot);
  }

  @override
  Future<String> addItem(ReviewModel item) async {
    final docRef = await db.collection(_collectionPath).add(item.toJson());
    
    // Update product rating aggregate
    await _updateProductRating(item.productId);
    
    return docRef.id;
  }

  @override
  Future<void> updateItem(ReviewModel item) async {
    await db.collection(_collectionPath).doc(item.id).update(item.toJson());
    
    // Update product rating aggregate
    await _updateProductRating(item.productId);
  }

  @override
  Future<void> updateSingleField(String id, Map<String, dynamic> json) async {
    await db.collection(_collectionPath).doc(id).update(json);
  }

  @override
  Future<void> deleteItem(ReviewModel item) async {
    await db.collection(_collectionPath).doc(item.id).delete();
    
    // Update product rating aggregate
    await _updateProductRating(item.productId);
  }

  @override
  Query getPaginatedQuery(int limit) {
    return db
        .collection(_collectionPath)
        .orderBy('createdAt', descending: true)
        .limit(limit);
  }

  @override
  ReviewModel fromQueryDocSnapshot(QueryDocumentSnapshot<Object?> doc) {
    return ReviewModel.fromSnapshot(doc as DocumentSnapshot<Map<String, dynamic>>);
  }

  /// Fetch reviews for a specific product
  Future<List<ReviewModel>> fetchProductReviews(String productId) async {
    final snapshot = await db
        .collection(_collectionPath)
        .where('productId', isEqualTo: productId)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs.map((doc) => ReviewModel.fromSnapshot(doc)).toList();
  }

  /// Fetch reviews by a specific user
  Future<List<ReviewModel>> fetchUserReviews() async {
    final userId = AuthenticationRepository.instance.getUserID;
    final snapshot = await db
        .collection(_collectionPath)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs.map((doc) => ReviewModel.fromSnapshot(doc)).toList();
  }

  /// Get average rating for a product
  Future<Map<String, dynamic>> getProductRatingStats(String productId) async {
    final reviews = await fetchProductReviews(productId);
    
    if (reviews.isEmpty) {
      return {
        'averageRating': 0.0,
        'totalReviews': 0,
        'ratingDistribution': {5: 0, 4: 0, 3: 0, 2: 0, 1: 0},
      };
    }

    double totalRating = 0;
    Map<int, int> distribution = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};

    for (var review in reviews) {
      totalRating += review.rating;
      int ratingKey = review.rating.round();
      distribution[ratingKey] = (distribution[ratingKey] ?? 0) + 1;
    }

    return {
      'averageRating': totalRating / reviews.length,
      'totalReviews': reviews.length,
      'ratingDistribution': distribution,
    };
  }

  /// Check if user has already reviewed a product
  Future<bool> hasUserReviewedProduct(String productId) async {
    final userId = AuthenticationRepository.instance.getUserID;
    final snapshot = await db
        .collection(_collectionPath)
        .where('productId', isEqualTo: productId)
        .where('userId', isEqualTo: userId)
        .limit(1)
        .get();
    return snapshot.docs.isNotEmpty;
  }

  /// Update product's aggregate rating (stored in Products collection)
  Future<void> _updateProductRating(String productId) async {
    try {
      final stats = await getProductRatingStats(productId);
      
      // Update the product document with rating stats
      await db.collection('Products').doc(productId).update({
        'averageRating': stats['averageRating'],
        'totalReviews': stats['totalReviews'],
      });
    } catch (e) {
      print('Error updating product rating: $e');
      // Don't throw error, just log it
    }
  }
}
