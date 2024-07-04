class Product {
  final String name;
  final double price;
  final String image;
  final String category;

  Product({
    required this.name,
    required this.price,
    required this.image,
    required this.category,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      name: json['name'],
      price: json['price'].toDouble(),
      image: json['image'],
      category: json['category'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'price': price,
      'image': image,
      'category': category,
    };
  }
}
