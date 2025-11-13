import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../utils/popups/loaders.dart';
import '../../../data/repository/authentication_repository/authentication_repository.dart';
import '../../../data/repository/user_repository/user_repository.dart';
import '../models/review_model.dart';
import '../repositories/review_repository.dart';

class ReviewController extends GetxController {
  static ReviewController get instance => Get.find();

  final RxBool isLoading = false.obs;
  final RxList<ReviewModel> productReviews = <ReviewModel>[].obs;
  final Rx<ProductRatingSummary> ratingSummary = ProductRatingSummary(
    productId: '',
    averageRating: 0,
    totalReviews: 0,
    ratingDistribution: {5: 0, 4: 0, 3: 0, 2: 0, 1: 0},
  ).obs;

  final reviewRepository = Get.put(ReviewRepository());
  final userRepository = Get.put(UserRepository());

  /// Fetch reviews for a product
  Future<void> fetchProductReviews(String productId) async {
    try {
      isLoading.value = true;
      final reviews = await reviewRepository.getProductReviews(productId);
      productReviews.assignAll(reviews);
      
      // Calculate rating summary
      ratingSummary.value = ProductRatingSummary.fromReviews(productId, reviews);
    } catch (e) {
      TLoaders.errorSnackBar(title: 'Error', message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// Add a new review
  Future<void> addReview({
    required String productId,
    required String productName,
    required double rating,
    String? title,
    required String reviewText,
    List<XFile>? images,
  }) async {
    try {
      isLoading.value = true;

      // Upload images if any
      List<String>? imageUrls;
      if (images != null && images.isNotEmpty) {
        imageUrls = await reviewRepository.uploadReviewImages(images);
      }

      // Get user data
      final user = await userRepository.fetchUserDetails();

      // Check if verified purchase
      final isVerified = await reviewRepository.hasUserPurchasedProduct(productId);

      // Create review
      final review = ReviewModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        productId: productId,
        userId: AuthenticationRepository.instance.firebaseUser!.uid,
        userName: user.fullName,
        userImage: user.profilePicture,
        rating: rating,
        title: title,
        review: reviewText,
        images: imageUrls,
        isVerifiedPurchase: isVerified,
        helpfulCount: 0,
        createdAt: DateTime.now(),
      );

      // Save to Firestore
      await reviewRepository.addReview(review);

      // Refresh reviews
      await fetchProductReviews(productId);

      TLoaders.successSnackBar(
        title: 'Success',
        message: 'Your review has been posted!',
      );

      Get.back(); // Close review screen
    } catch (e) {
      TLoaders.errorSnackBar(title: 'Error', message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// Check if user can review product
  Future<bool> canReviewProduct(String productId) async {
    try {
      // Check if already reviewed
      final hasReviewed = await reviewRepository.hasUserReviewedProduct(productId);
      if (hasReviewed) {
        return false;
      }

      // Check if purchased
      final hasPurchased = await reviewRepository.hasUserPurchasedProduct(productId);
      return hasPurchased;
    } catch (e) {
      return false;
    }
  }

  /// Mark review as helpful
  Future<void> markReviewHelpful(String reviewId, String productId) async {
    try {
      await reviewRepository.markHelpful(reviewId);
      await fetchProductReviews(productId);
      TLoaders.successSnackBar(title: 'Thanks!', message: 'Marked as helpful');
    } catch (e) {
      TLoaders.errorSnackBar(title: 'Error', message: e.toString());
    }
  }

  /// Delete review
  Future<void> deleteReview(String reviewId, String productId) async {
    try {
      isLoading.value = true;
      await reviewRepository.deleteReview(reviewId);
      await fetchProductReviews(productId);
      TLoaders.successSnackBar(title: 'Success', message: 'Review deleted');
    } catch (e) {
      TLoaders.errorSnackBar(title: 'Error', message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// Get rating color
  String getRatingColor(double rating) {
    if (rating >= 4.0) return 'green';
    if (rating >= 3.0) return 'orange';
    return 'red';
  }

  /// Get star icons
  List<bool> getStarIcons(double rating) {
    return List.generate(5, (index) => index < rating.round());
  }
}
