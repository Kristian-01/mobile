// In lib/features/products/controllers/product_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/repository/product_repository/product_repository.dart';
import '../../../utils/constants/sizes.dart';
import '../../../utils/logger_helper.dart';
import '../../cart/controllers/cart_controller.dart';
import '../models/product_model.dart';
import '../models/product_variation_model.dart';

class ProductController extends GetxController {
  static ProductController get instance => Get.find();

  final _productRepository = Get.put(ProductRepository());
  final products = <ProductModel>[].obs;
  final isLoading = false.obs;
  
  // Variables used to keep the selected features.
  RxInt cartQuantity = 0.obs;
  RxString variationStockStatus = ''.obs;
  RxMap selectedAttributes = {}.obs;
  RxString selectedProductImage = ''.obs;
  Rx<ProductVariationModel> selectedVariation = ProductVariationModel.empty().obs;

  @override
  void onInit() {
    listenToProducts();
    super.onInit();
  }

  /// Listen to products real-time updates from Firebase
  void listenToProducts() {
    isLoading.value = true;
    _productRepository.getProductsStream().listen(
      (fetchedProducts) {
        products.value = fetchedProducts;
        isLoading.value = false;
        TLoggerHelper.info('📦 Products updated in real-time: ${fetchedProducts.length}');
      },
      onError: (e) {
        isLoading.value = false;
        Get.snackbar('Error', 'Failed to fetch products: $e');
      },
    );
  }

  /// Fetch products from Firebase (one-time fetch)
  Future<void> fetchProducts() async {
    try {
      isLoading.value = true;
      
      // Fetch from Firebase instead of dummy data
      final fetchedProducts = await _productRepository.getAllItems();
      products.value = fetchedProducts;
      
      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Error', 'Failed to fetch products: $e');
    }
  }

  /// Fetch featured products
  Future<void> fetchFeaturedProducts() async {
    try {
      isLoading.value = true;
      final featured = await _productRepository.fetchFeaturedProducts();
      products.value = featured;
      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Error', 'Failed to fetch featured products: $e');
    }
  }

  /// Fetch products by category
  Future<List<ProductModel>> fetchProductsByCategory(String categoryId) async {
    try {
      return await _productRepository.fetchProductsByCategory(categoryId);
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch products: $e');
      return [];
    }
  }

  /// -- Initialize already added Item's Count in the cart.
  void initializeAlreadyAddedProductCount(ProductModel product) {
    if (product.productVariations == null || product.productVariations!.isEmpty) {
      cartQuantity.value = CartController.instance.calculateSingleProductCartEntries(product.id, '');
    } else {
      final variationId = selectedVariation.value.id;
      if (variationId.isNotEmpty) {
        cartQuantity.value = CartController.instance.calculateSingleProductCartEntries(product.id, variationId);
      } else {
        cartQuantity.value = 0;
      }
    }
  }

  /// -- Get All Images from product and Variations
  List<String> getAllProductImages(ProductModel product) {
    Set<String> images = {};
    images.add(product.thumbnail);
    selectedProductImage.value = product.thumbnail;
    if (product.images != null) {
      images.addAll(product.images!);
    }
    if (product.productVariations != null) {
      images.addAll(product.productVariations!.map((variation) => variation.image));
    }
    return images.toList();
  }

  /// -- Show Image Popup
  void showEnlargedImage(String image) {
    Get.to(
      fullscreenDialog: true,
      () => Dialog.fullscreen(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: TSizes.defaultSpace * 2, horizontal: TSizes.defaultSpace),
                child: Image(image: AssetImage(image)),
              ),
              const SizedBox(height: TSizes.spaceBtwSections),
              Align(
                alignment: Alignment.bottomCenter,
                child: SizedBox(
                  width: 150,
                  child: OutlinedButton(onPressed: () => Get.back(), child: const Text('Close')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// -- Get Single Price Or Price Range in case of variations ₱5 - ₱29.99
  String getProductPrice(ProductModel product) {
    double smallestPrice = double.infinity;
    double largestPrice = 0.0;
    if (product.productVariations == null) {
      return (product.salePrice ?? product.price).toString();
    } else {
      for (var variation in product.productVariations!) {
        double priceToConsider = variation.salePrice ?? variation.price;
        if (priceToConsider < smallestPrice) {
          smallestPrice = priceToConsider;
        }
        if (priceToConsider > largestPrice) {
          largestPrice = priceToConsider;
        }
      }
      if (smallestPrice.isEqual(largestPrice)) {
        return largestPrice.toString();
      } else {
        return '₱$smallestPrice - ₱$largestPrice';
      }
    }
  }

  /// -- Calculate Discount Percentage
  String? calculateSalePercentage(double originalPrice, double? salePrice) {
    if(salePrice == null) return null;
    if (originalPrice <= 0 || salePrice <= 0) return null;
    double percentage = ((originalPrice - salePrice) / originalPrice) * 100;
    return percentage.toStringAsFixed(0);
  }

  /// -- Check Product Stock Status
  String getProductStockStatus(ProductModel product){
    return product.stock > 0 ? 'In Stock' : 'Out of Stock';
  }

  /// -- Check Product Variation Stock Status
  void getProductVariationStockStatus(){
    variationStockStatus.value = selectedVariation.value.stock > 0 ? 'In Stock' : 'Out of Stock';
  }

  /// -- Select Attribute, and Variation
  void onAttributeSelected(ProductModel product, attributeName, attributeValue) {
    final selectedAttributes = Map<String, dynamic>.from(this.selectedAttributes);
    selectedAttributes[attributeName] = attributeValue;
    this.selectedAttributes[attributeName] = attributeValue;

    final ProductVariationModel selectedVariation = product.productVariations!.firstWhere(
      (variation) => _isSameAttributeValues(variation.attributeValues, selectedAttributes),
      orElse: () => ProductVariationModel.empty(),
    );

    if (selectedVariation.image.isNotEmpty) {
      selectedProductImage.value = selectedVariation.image;
    }

    if (selectedVariation.id.isNotEmpty) {
      cartQuantity.value = CartController.instance.calculateSingleProductCartEntries(product.id, selectedVariation.id);
    }

    this.selectedVariation.value = selectedVariation;
    getProductVariationStockStatus();
  }

  /// -- Check If selected attributes matches any variation attributes
  bool _isSameAttributeValues(Map<String, dynamic> variationAttributes, Map<String, dynamic> selectedAttributes) {
    if (variationAttributes.length != selectedAttributes.length) return false;
    for (final key in variationAttributes.keys) {
      if (variationAttributes[key] != selectedAttributes[key]) return false;
    }
    return true;
  }

  /// -- Check Attribute availability / Stock in Variation
  Set<String?> getAttributesAvailabilityInVariation(List<ProductVariationModel> variations, String attributeName) {
    final availableVariationAttributeValues = variations
        .where((variation) =>
            variation.attributeValues[attributeName] != null &&
            variation.attributeValues[attributeName]!.isNotEmpty &&
            variation.stock > 0)
        .map((variation) => variation.attributeValues[attributeName])
        .toSet();
    return availableVariationAttributeValues;
  }

  /// -- Add selected variation to cart
  void addProductToCart(ProductModel product) {
    if (product.productVariations == null) {
      CartController.instance.addMultipleItemsToCart(product, ProductVariationModel.empty(), cartQuantity.value);
      Get.back();
    } else {
      final variation = selectedVariation.value;
      if (variation.id.isEmpty) {
        Get.snackbar(
            'Select Variation', 'To add items in the cart you first have to select a Variation of this product.',
            snackPosition: SnackPosition.BOTTOM);
        return;
      } else {
        CartController.instance.addMultipleItemsToCart(product, variation, cartQuantity.value);
        Get.back();
      }
    }
  }

}