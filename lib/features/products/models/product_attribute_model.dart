class ProductAttributeModel {
  String? name;
  final List<String>? values;

  ProductAttributeModel({this.name, this.values});

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'values': values,
    };
  }

  /// Map Json oriented document snapshot from Firebase to Model
  factory ProductAttributeModel.fromJson(Map<String, dynamic> document) {
    return ProductAttributeModel(
      name: document['name'],
      values: document['values'] != null ? List<String>.from(document['values']) : null,
    );
  }
}
