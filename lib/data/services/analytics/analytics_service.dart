import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:get/get.dart';

/// Analytics Service for tracking user behavior and events
class AnalyticsService extends GetxController {
  static AnalyticsService get instance => Get.find();

  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  FirebaseAnalyticsObserver get observer => FirebaseAnalyticsObserver(analytics: _analytics);

  /// Log screen view
  Future<void> logScreenView(String screenName) async {
    await _analytics.logScreenView(
      screenName: screenName,
    );
  }

  /// Log user login
  Future<void> logLogin(String method) async {
    await _analytics.logLogin(loginMethod: method);
  }

  /// Log user signup
  Future<void> logSignUp(String method) async {
    await _analytics.logSignUp(signUpMethod: method);
  }

  /// Log product view
  Future<void> logViewProduct(String productId, String productName, double price) async {
    await _analytics.logViewItem(
      currency: 'PHP',
      value: price,
      items: [
        AnalyticsEventItem(
          itemId: productId,
          itemName: productName,
          price: price,
        ),
      ],
    );
  }

  /// Log add to cart
  Future<void> logAddToCart(String productId, String productName, double price, int quantity) async {
    await _analytics.logAddToCart(
      currency: 'PHP',
      value: price * quantity,
      items: [
        AnalyticsEventItem(
          itemId: productId,
          itemName: productName,
          price: price,
          quantity: quantity,
        ),
      ],
    );
  }

  /// Log remove from cart
  Future<void> logRemoveFromCart(String productId, String productName, double price, int quantity) async {
    await _analytics.logRemoveFromCart(
      currency: 'PHP',
      value: price * quantity,
      items: [
        AnalyticsEventItem(
          itemId: productId,
          itemName: productName,
          price: price,
          quantity: quantity,
        ),
      ],
    );
  }

  /// Log begin checkout
  Future<void> logBeginCheckout(double totalValue, List<Map<String, dynamic>> items) async {
    await _analytics.logBeginCheckout(
      currency: 'PHP',
      value: totalValue,
      items: items.map((item) => AnalyticsEventItem(
        itemId: item['productId'] ?? '',
        itemName: item['title'] ?? '',
        price: (item['price'] ?? 0.0).toDouble(),
        quantity: item['quantity'] ?? 1,
      )).toList(),
    );
  }

  /// Log purchase
  Future<void> logPurchase({
    required String orderId,
    required double totalAmount,
    required String paymentMethod,
    required List<Map<String, dynamic>> items,
  }) async {
    await _analytics.logPurchase(
      currency: 'PHP',
      value: totalAmount,
      transactionId: orderId,
      items: items.map((item) => AnalyticsEventItem(
        itemId: item['productId'] ?? '',
        itemName: item['title'] ?? '',
        price: (item['price'] ?? 0.0).toDouble(),
        quantity: item['quantity'] ?? 1,
      )).toList(),
    );

    // Log payment method
    await _analytics.logEvent(
      name: 'payment_method_selected',
      parameters: {
        'payment_method': paymentMethod,
        'transaction_id': orderId,
        'value': totalAmount,
      },
    );
  }

  /// Log search
  Future<void> logSearch(String searchTerm) async {
    await _analytics.logSearch(searchTerm: searchTerm);
  }

  /// Log add to wishlist
  Future<void> logAddToWishlist(String productId, String productName, double price) async {
    await _analytics.logAddToWishlist(
      currency: 'PHP',
      value: price,
      items: [
        AnalyticsEventItem(
          itemId: productId,
          itemName: productName,
          price: price,
        ),
      ],
    );
  }

  /// Log share
  Future<void> logShare(String contentType, String itemId) async {
    await _analytics.logShare(
      contentType: contentType,
      itemId: itemId,
      method: 'share_button',
    );
  }

  /// Log custom event
  Future<void> logCustomEvent(String eventName, Map<String, dynamic>? parameters) async {
    await _analytics.logEvent(
      name: eventName,
      parameters: parameters != null ? Map<String, Object>.from(parameters) : null,
    );
  }

  /// Set user ID
  Future<void> setUserId(String userId) async {
    await _analytics.setUserId(id: userId);
  }

  /// Set user property
  Future<void> setUserProperty(String name, String value) async {
    await _analytics.setUserProperty(name: name, value: value);
  }

  /// Log app open
  Future<void> logAppOpen() async {
    await _analytics.logAppOpen();
  }

  /// Log tutorial begin
  Future<void> logTutorialBegin() async {
    await _analytics.logTutorialBegin();
  }

  /// Log tutorial complete
  Future<void> logTutorialComplete() async {
    await _analytics.logTutorialComplete();
  }

  /// Log select content (e.g., category, banner)
  Future<void> logSelectContent(String contentType, String itemId) async {
    await _analytics.logSelectContent(
      contentType: contentType,
      itemId: itemId,
    );
  }
}
