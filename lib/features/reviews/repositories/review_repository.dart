import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../data/repository/authentication_repository/authentication_repository.dart';
import '../models/review_model.dart';

class ReviewRepository extends GetxController {
  static ReviewRepository get instance => Get.find();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Add a review
  Future<void> addReview(ReviewModel review) async {
    try {
      await _db.collection('Reviews').doc(review.id).set(review.toJson());
    } catch (e) {
      throw 'Failed to add review: $e';
    }
  }

  /// Upload review images
  Future<List<String>> uploadReviewImages(List<XFile> images) async {
    try {
      final userId = AuthenticationRepository.instance.firebaseUser!.uid;
      final uploadedUrls = <String>[];

      for (int i = 0; i < images.length; i++) {
        final fileName = 'review_${DateTime.now().millisecondsSinceEpoch}_$i.jpg';
        final ref = _storage.ref().child('reviews/$userId/$fileName');
        
        // Handle web and mobile platforms differently
        if (kIsWeb) {
          final bytes = await images[i].readAsBytes();
          await ref.putData(bytes);
        } else {
          await ref.putFile(File(images[i].path));
        }
        
        final downloadUrl = await ref.getDownloadURL();
        uploadedUrls.add(downloadUrl);
      }

      return uploadedUrls;
    } catch (e) {
      throw 'Failed to upload review images: $e';
    }
  }

  /// Get reviews for a product
  Future<List<ReviewModel>> getProductReviews(String productId) async {
    try {
      final snapshot = await _db
          .collection('Reviews')
          .where('productId', isEqualTo: productId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) => ReviewModel.fromSnapshot(doc)).toList();
    } catch (e) {
      throw 'Failed to fetch reviews: $e';
    }
  }

  /// Stream reviews for a product
  Stream<List<ReviewModel>> streamProductReviews(String productId) {
    try {
      return _db
          .collection('Reviews')
          .where('productId', isEqualTo: productId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) =>
              snapshot.docs.map((doc) => ReviewModel.fromSnapshot(doc)).toList());
    } catch (e) {
      throw 'Failed to stream reviews: $e';
    }
  }

  /// Get user's reviews
  Future<List<ReviewModel>> getUserReviews() async {
    try {
      final userId = AuthenticationRepository.instance.firebaseUser!.uid;
      final snapshot = await _db
          .collection('Reviews')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) => ReviewModel.fromSnapshot(doc)).toList();
    } catch (e) {
      throw 'Failed to fetch user reviews: $e';
    }
  }

  /// Update review
  Future<void> updateReview(String reviewId, Map<String, dynamic> data) async {
    try {
      await _db.collection('Reviews').doc(reviewId).update(data);
    } catch (e) {
      throw 'Failed to update review: $e';
    }
  }

  /// Delete review
  Future<void> deleteReview(String reviewId) async {
    try {
      await _db.collection('Reviews').doc(reviewId).delete();
    } catch (e) {
      throw 'Failed to delete review: $e';
    }
  }

  /// Mark review as helpful
  Future<void> markHelpful(String reviewId) async {
    try {
      await _db.collection('Reviews').doc(reviewId).update({
        'helpfulCount': FieldValue.increment(1),
      });
    } catch (e) {
      throw 'Failed to mark review as helpful: $e';
    }
  }

  /// Check if user has purchased product (can review)
  Future<bool> hasUserPurchasedProduct(String productId) async {
    try {
      final userId = AuthenticationRepository.instance.firebaseUser!.uid;
      final snapshot = await _db
          .collection('Orders')
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: 'Delivered')
          .get();

      for (var order in snapshot.docs) {
        final items = order.data()['items'] as List?;
        if (items != null) {
          for (var item in items) {
            if (item['productId'] == productId) {
              return true;
            }
          }
        }
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  /// Check if user has already reviewed product
  Future<bool> hasUserReviewedProduct(String productId) async {
    try {
      final userId = AuthenticationRepository.instance.firebaseUser!.uid;
      final snapshot = await _db
          .collection('Reviews')
          .where('productId', isEqualTo: productId)
          .where('userId', isEqualTo: userId)
          .get();

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}
