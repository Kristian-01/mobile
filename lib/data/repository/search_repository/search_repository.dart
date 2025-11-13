import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../authentication_repository/authentication_repository.dart';

class SearchRepository extends GetxController {
  static SearchRepository get instance => Get.find();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collectionPath = 'SearchHistory';

  /// Get user's search history collection reference
  CollectionReference _getUserSearchCollection() {
    final userId = AuthenticationRepository.instance.getUserID;
    return _db.collection('Users').doc(userId).collection(_collectionPath);
  }

  /// Save search query to history
  Future<void> saveSearchQuery(String query) async {
    try {
      if (query.trim().isEmpty) return;

      final queryLower = query.trim().toLowerCase();
      
      // Check if query already exists
      final existing = await _getUserSearchCollection()
          .where('query', isEqualTo: queryLower)
          .limit(1)
          .get();

      if (existing.docs.isNotEmpty) {
        // Update timestamp and count
        await existing.docs.first.reference.update({
          'lastSearched': FieldValue.serverTimestamp(),
          'searchCount': FieldValue.increment(1),
        });
      } else {
        // Add new search query
        await _getUserSearchCollection().add({
          'query': queryLower,
          'lastSearched': FieldValue.serverTimestamp(),
          'searchCount': 1,
        });
      }
    } catch (e) {
      print('Error saving search query: $e');
    }
  }

  /// Fetch recent search queries
  Future<List<String>> fetchRecentSearches({int limit = 10}) async {
    try {
      final snapshot = await _getUserSearchCollection()
          .orderBy('lastSearched', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .map((data) => data['query'] as String)
          .toList();
    } catch (e) {
      print('Error fetching recent searches: $e');
      return [];
    }
  }

  /// Fetch popular/frequent searches
  Future<List<String>> fetchPopularSearches({int limit = 5}) async {
    try {
      final snapshot = await _getUserSearchCollection()
          .orderBy('searchCount', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .map((data) => data['query'] as String)
          .toList();
    } catch (e) {
      print('Error fetching popular searches: $e');
      return [];
    }
  }

  /// Delete a specific search query
  Future<void> deleteSearchQuery(String query) async {
    try {
      final queryLower = query.trim().toLowerCase();
      final snapshot = await _getUserSearchCollection()
          .where('query', isEqualTo: queryLower)
          .get();

      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      print('Error deleting search query: $e');
    }
  }

  /// Clear all search history
  Future<void> clearSearchHistory() async {
    try {
      final snapshot = await _getUserSearchCollection().get();
      
      final batch = _db.batch();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      
      await batch.commit();
    } catch (e) {
      print('Error clearing search history: $e');
      throw 'Failed to clear search history';
    }
  }

  /// Get search suggestions based on partial query
  Future<List<String>> getSearchSuggestions(String partialQuery) async {
    try {
      if (partialQuery.trim().isEmpty) return [];

      final queryLower = partialQuery.trim().toLowerCase();
      
      final snapshot = await _getUserSearchCollection()
          .orderBy('query')
          .startAt([queryLower])
          .endAt(['$queryLower\uf8ff'])
          .limit(5)
          .get();

      return snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .map((data) => data['query'] as String)
          .toList();
    } catch (e) {
      print('Error getting search suggestions: $e');
      return [];
    }
  }
}
