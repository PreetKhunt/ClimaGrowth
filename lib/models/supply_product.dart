class SupplyProduct {
  final String id;
  final String name;
  final String brand;
  final String category;
  final double price;
  final double mrp;
  final int discount;
  final String photoUrl;
  final String description;
  final int stock;
  final double rating;
  final int reviewCount;
  final String unit;

  const SupplyProduct({
    required this.id,
    required this.name,
    required this.brand,
    required this.category,
    required this.price,
    required this.mrp,
    required this.discount,
    required this.photoUrl,
    required this.description,
    this.stock = 100,
    this.rating = 4.2,
    this.reviewCount = 0,
    required this.unit,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'brand': brand,
        'category': category,
        'price': price,
        'mrp': mrp,
        'discount': discount,
        'photoUrl': photoUrl,
        'description': description,
        'stock': stock,
        'rating': rating,
        'reviewCount': reviewCount,
        'unit': unit,
      };
}

class CartItem {
  final SupplyProduct product;
  int quantity;
  CartItem({required this.product, this.quantity = 1});
}
