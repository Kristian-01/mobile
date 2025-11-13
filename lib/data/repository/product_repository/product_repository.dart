import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../../../features/products/models/product_model.dart';
import '../../abstract/base_repository.dart';

class ProductRepository extends TBaseRepositoryController<ProductModel> {
  static ProductRepository get instance => Get.find();

  final String _collectionPath = 'Products';
  bool _isPharmacyCategory(String? categoryId) {
    final s = (categoryId ?? '').toLowerCase();
    if (s.isEmpty) return false;
    if (s.contains('food') || s.contains('beverage') || s.contains('snack') || s.contains('household') || s.contains('others') || s.contains('other')) return false;
    const allow = [
      'multivitamins','vitamins',
      'medicines','medicine',
      'topical_oral','topical oral','topical','oral',
      'cough_cold','cough cold','cough','cold',
      'medical_supplies','medical supplies',
      'personal_care','personal care',
      'baby_products','baby products',
      'female_care','female care',
      'feminine_care','feminine care'
    ];
    return allow.any((a) => s.contains(a));
  }

  @override
  Future<List<ProductModel>> fetchAllItems() async {
    final snapshot = await db.collection(_collectionPath).get();
    final list = snapshot.docs.map((doc) => ProductModel.fromSnapshot(doc)).toList();
    return list.where((p) => _isPharmacyCategory(p.categoryId)).toList();
  }

  @override
  Future<ProductModel> fetchSingleItem(String id) async {
    final snapshot = await db.collection(_collectionPath).doc(id).get();
    return ProductModel.fromSnapshot(snapshot);
  }

  @override
  Future<String> addItem(ProductModel item) async {
    final docRef = await db.collection(_collectionPath).add(item.toJson());
    return docRef.id;
  }

  @override
  Future<void> updateItem(ProductModel item) async {
    await db.collection(_collectionPath).doc(item.id).update(item.toJson());
  }

  @override
  Future<void> updateSingleField(String id, Map<String, dynamic> json) async {
    await db.collection(_collectionPath).doc(id).update(json);
  }

  @override
  Future<void> deleteItem(ProductModel item) async {
    await db.collection(_collectionPath).doc(item.id).delete();
  }

  @override
  Query getPaginatedQuery(int limit) {
    return db.collection(_collectionPath).limit(limit);
  }

  @override
  ProductModel fromQueryDocSnapshot(QueryDocumentSnapshot<Object?> doc) {
    return ProductModel.fromSnapshot(doc as DocumentSnapshot<Map<String, dynamic>>);
  }

  // Additional methods for product-specific queries
  Future<List<ProductModel>> fetchProductsByCategory(String categoryId) async {
    final snapshot = await db
        .collection(_collectionPath)
        .where('categoryId', isEqualTo: categoryId)
        .get();
    return snapshot.docs.map((doc) => ProductModel.fromSnapshot(doc)).toList();
  }

  Future<List<ProductModel>> fetchFeaturedProducts() async {
    final snapshot = await db
        .collection(_collectionPath)
        .where('isFeatured', isEqualTo: true)
        .limit(4)
        .get();
    return snapshot.docs.map((doc) => ProductModel.fromSnapshot(doc)).toList();
  }

  Future<List<ProductModel>> fetchPopularProducts() async {
    final snapshot = await db
        .collection(_collectionPath)
        .where('isPopular', isEqualTo: true)
        .limit(4)
        .get();
    return snapshot.docs.map((doc) => ProductModel.fromSnapshot(doc)).toList();
  }

  /// Real-time listener for all products
  Stream<List<ProductModel>> getProductsStream() {
    return db.collection(_collectionPath)
        .snapshots()
        .map((snapshot) {
          final products = snapshot.docs.map((doc) => ProductModel.fromSnapshot(doc)).toList();
          return products.where((p) => _isPharmacyCategory(p.categoryId)).toList();
        });
  }

  /// Real-time listener for products by category
  Stream<List<ProductModel>> getProductsByCategoryStream(String categoryId) {
    print('🔥 Setting up Firebase stream for category: $categoryId');
    return db.collection(_collectionPath)
        .where('categoryId', isEqualTo: categoryId)
        .snapshots()
        .map((snapshot) {
          final now = DateTime.now();
          print('🔥 [${now.hour}:${now.minute}:${now.second}.${now.millisecond}] Firebase snapshot received: ${snapshot.docs.length} products, fromCache: ${snapshot.metadata.isFromCache}, hasPendingWrites: ${snapshot.metadata.hasPendingWrites}');
          final products = snapshot.docs.map((doc) => ProductModel.fromSnapshot(doc)).toList();
          if (products.isNotEmpty) {
            print('   📦 Sample product: ${products.first.title}, stock=${products.first.stock}, price=${products.first.price}');
          }
          return products;
        });
  }

  /// Real-time listener for products from multiple categories (for parent categories)
  Stream<List<ProductModel>> getProductsByMultipleCategoriesStream(List<String> categoryIds) {
    print('🔥 Setting up Firebase stream for multiple categories: $categoryIds');
    if (categoryIds.isEmpty) {
      return Stream.value([]);
    }
    
    // Firebase 'whereIn' supports up to 10 values
    if (categoryIds.length <= 10) {
      return db.collection(_collectionPath)
          .where('categoryId', whereIn: categoryIds)
          .snapshots()
          .map((snapshot) {
            final now = DateTime.now();
            print('🔥 [${now.hour}:${now.minute}:${now.second}.${now.millisecond}] Firebase snapshot received: ${snapshot.docs.length} products from ${categoryIds.length} categories');
            final products = snapshot.docs.map((doc) => ProductModel.fromSnapshot(doc)).toList();
            if (products.isNotEmpty) {
              print('   📦 Sample product: ${products.first.title}, categoryId=${products.first.categoryId}');
            }
            return products;
          });
    } else {
      // If more than 10 categories, split into multiple queries and merge
      final chunks = <List<String>>[];
      for (var i = 0; i < categoryIds.length; i += 10) {
        chunks.add(categoryIds.sublist(i, (i + 10 > categoryIds.length) ? categoryIds.length : i + 10));
      }
      
      final streams = chunks.map((chunk) => 
        db.collection(_collectionPath)
            .where('categoryId', whereIn: chunk)
            .snapshots()
            .map((snapshot) => snapshot.docs.map((doc) => ProductModel.fromSnapshot(doc)).toList())
      ).toList();
      
      // Merge all streams
      return streams.first.asyncMap((products) async {
        final allProducts = List<ProductModel>.from(products);
        for (var i = 1; i < streams.length; i++) {
          await for (var moreProducts in streams[i]) {
            allProducts.addAll(moreProducts);
            break; // Only take first emission to keep in sync
          }
        }
        return allProducts;
      });
    }
  }

  /// Fetch featured pharmacy products (limit 6)
  Future<List<ProductModel>> fetchFeaturedPharmacyProducts() async {
    final pharmacyCategories = ['multivitamins', 'medicines', 'topical_oral', 'cough_cold'];
    
    final snapshot = await db
        .collection(_collectionPath)
        .where('categoryId', whereIn: pharmacyCategories)
        .where('isFeatured', isEqualTo: true)
        .limit(4)
        .get();
    
    return snapshot.docs.map((doc) => ProductModel.fromSnapshot(doc)).toList();
  }

  /// Fetch popular pharmacy products (different from featured, limit 6)
  Future<List<ProductModel>> fetchPopularPharmacyProducts(List<String> excludeIds) async {
    final pharmacyCategories = ['multivitamins', 'medicines', 'topical_oral', 'cough_cold'];
    
    // Get all pharmacy products
    final snapshot = await db
        .collection(_collectionPath)
        .where('categoryId', whereIn: pharmacyCategories)
        .get();
    
    // Filter out excluded IDs and take 6
    final products = snapshot.docs
        .map((doc) => ProductModel.fromSnapshot(doc))
        .where((product) => !excludeIds.contains(product.id))
        .take(4)
        .toList();
    
    return products;
  }

  /// Real-time stream for featured pharmacy products
  Stream<List<ProductModel>> getFeaturedPharmacyProductsStream() {
    // Get all products and prioritize featured ones
    return db.collection(_collectionPath)
        .snapshots()
        .map((snapshot) {
      var products = snapshot.docs.map((doc) => ProductModel.fromSnapshot(doc)).toList();
      
      // ✅ Use the same global pharmacy filter
      var pharmacyProducts = products.where((p) => _isPharmacyCategory(p.categoryId)).toList();
      
      // If we have featured pharmacy products, return up to 4
      var featured = pharmacyProducts.where((p) => p.isFeatured == true).toList();
      if (featured.isNotEmpty) {
        print('📦 Found ${featured.length} featured pharmacy products');
        return featured.take(4).toList();
      }
      
      // Otherwise return any pharmacy products (up to 4)
      print('📦 No featured pharmacy products, showing first 4 from ${pharmacyProducts.length} pharmacy items');
      return pharmacyProducts.take(4).toList();
    });
  }

  /// Real-time stream for popular pharmacy products
  Stream<List<ProductModel>> getPopularPharmacyProductsStream() {
    return db.collection(_collectionPath)
        .snapshots()
        .map((snapshot) {
      var products = snapshot.docs.map((doc) => ProductModel.fromSnapshot(doc)).toList();
      final filtered = products.where((p) => _isPharmacyCategory(p.categoryId)).toList();
      print('📦 Popular products stream: ${products.length} total → pharmacy ${filtered.length}');
      return filtered;
    });
  }
}