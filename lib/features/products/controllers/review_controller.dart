import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/repository/authentication_repository/authentication_repository.dart';
import '../../../data/repository/review_repository/review_repository.dart';
import '../../../personalization/controllers/user_controller.dart';
import '../models/review_model.dart';

class ReviewController extends GetxController {
  static ReviewController get instance => Get.find();

  final _reviewRepository = Get.put(ReviewRepository());
  final reviews = <ReviewModel>[].obs;
  final isLoading = false.obs;
  final averageRating = 0.0.obs;
  final totalReviews = 0.obs;
  final ratingDistribution = <int, int>{}.obs;

  // Form fields
  final reviewTextController = TextEditingController();
  final selectedRating = 0.0.obs;

  /// Fetch reviews for a specific product
  Future<void> fetchProductReviews(String productId) async {
    try {
      isLoading.value = true;
      reviews.value = await _reviewRepository.fetchProductReviews(productId);
      
      // Fetch rating stats
      final stats = await _reviewRepository.getProductRatingStats(productId);
      averageRating.value = stats['averageRating'];
      totalReviews.value = stats['totalReviews'];
      ratingDistribution.value = Map<int, int>.from(stats['ratingDistribution']);
      
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to fetch reviews: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Submit a new review
  Future<void> submitReview(String productId) async {
    try {
      // Validate
      if (selectedRating.value == 0) {
        Get.snackbar(
          'Rating Required',
          'Please select a rating',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      if (reviewTextController.text.trim().isEmpty) {
        Get.snackbar(
          'Review Required',
          'Please write a review',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      // Check if user already reviewed
      final hasReviewed = await _reviewRepository.hasUserReviewedProduct(productId);
      if (hasReviewed) {
        Get.snackbar(
          'Already Reviewed',
          'You have already reviewed this product',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      // Show loading
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      // Get user info
      final user = UserController.instance.user.value;

      // Create review
      final review = ReviewModel(
        id: '',
        productId: productId,
        userId: AuthenticationRepository.instance.getUserID,
        userName: user.fullName,
        userImage: user.profilePicture,
        rating: selectedRating.value,
        comment: reviewTextController.text.trim(),
        createdAt: DateTime.now(),
        isVerifiedPurchase: true, // You can check actual purchase history
      );

      // Submit to Firebase
      await _reviewRepository.addNewItem(review);

      // Refresh reviews
      await fetchProductReviews(productId);

      // Close loading
      Get.back();

      // Clear form
      reviewTextController.clear();
      selectedRating.value = 0.0;

      // Show success
      Get.snackbar(
        'Success',
        'Review submitted successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // Close review dialog/screen
      Get.back();

    } catch (e) {
      Get.back(); // Close loading
      Get.snackbar(
        'Error',
        'Failed to submit review: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// Delete a review (only user's own review)
  Future<void> deleteReview(ReviewModel review) async {
    try {
      // Verify ownership
      if (review.userId != AuthenticationRepository.instance.getUserID) {
        Get.snackbar(
          'Error',
          'You can only delete your own reviews',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      await _reviewRepository.deleteItemRecord(review);
      await fetchProductReviews(review.productId);

      Get.snackbar(
        'Success',
        'Review deleted successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete review: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  void onClose() {
    reviewTextController.dispose();
    super.onClose();
  }
}
