

class TPricingCalculator {
  /// -- Calculate Price based on tax and shipping
  static double calculateTotalPrice(double productPrice, String location) {
    double taxRate = getTaxRateForLocation(location);
    double taxAmount = productPrice * taxRate;

    double shippingCost = getShippingCost(location);

    double totalPrice = productPrice + taxAmount + shippingCost;
    return totalPrice;
  }
  // static double calculateTotalPrice(double productPrice, double taxRate, double shippingCost) {
  //   double taxAmount = productPrice * taxRate;
  //   double totalPrice = productPrice + taxAmount + shippingCost;
  //   return double.tryParse(totalPrice.toStringAsFixed(2)) ?? 0.0;
  // }

  static double calculateTotalPriceBasedOnLocation(double productPrice, String location) {
    double taxRate = getTaxRateForLocation(location);
    double taxAmount = productPrice * taxRate;

    double shippingCost = getShippingCost(location);

    double totalPrice = productPrice + taxAmount + shippingCost;
    return double.tryParse(totalPrice.toStringAsFixed(2)) ?? 0.0;
  }

  /// -- Calculate shipping cost
  static String calculateShippingCost(double productPrice, String location) {
    double shippingCost = getShippingCost(location);
    return shippingCost.toStringAsFixed(2);
  }

  /// -- Calculate tax
  static String calculateTax(double productPrice, String location) {
    double taxRate = getTaxRateForLocation(location);
    double taxAmount = productPrice * taxRate;
    return taxAmount.toStringAsFixed(2);
  }

  static double getTaxRateForLocation(String location) {
    // Temporarily set tax rate to 0
    return 0.0;
  }

  static double getShippingCost(String location) {
    // Temporarily set shipping cost to 0
    return 0.0;
  }

  // /// -- Sum all cart values and return total amount
  // static double calculateCartTotal(CartModel cart) {
  //   return cart.items.map((e) => e.price).fold(0, (previousPrice, currentPrice) => previousPrice + (currentPrice));
  // }
}
