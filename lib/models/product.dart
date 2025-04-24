class Product {
  final String name;
  final String image;
  final double price;
  final String category;
  final String? details;
  final double? rating;
  final double? originalPrice;
  final int? discount;
  int quantity;

  Product({
    required this.name,
    required this.image,
    required this.price,
    required this.category,
    this.details,
    this.rating,
    this.originalPrice,
    this.discount,
    this.quantity = 1,
  });
}
